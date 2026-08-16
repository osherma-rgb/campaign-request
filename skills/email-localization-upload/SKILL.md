---
name: email-localization-upload
description: >
  Use when a Lifecycle Marketing email ZIP (HTML + Images/) is ready and needs to go onto
  monday's Email Localization Uploads board to be built into a Braze template, or when asked
  to "upload the ZIP", "run EN-US", "send this email to the localization board", or to get a
  Braze Template Link for a campaign request. English-only sends; does not localize.
status: draft
owner: osherma@monday.com
---

# Skill: Email Localization Upload (English-only)

**⚠️ Legacy as of 2026-08-16.** `campaign-pipeline` no longer calls this skill by default —
it now writes directly to Braze via `braze-email-templates`' REST API path instead of going
through this board. This skill is kept fully functional for standalone/explicit use (e.g. if
someone specifically asks to "upload to the localization board" or "run EN-US" by name), and
as a rollback option if the direct-to-Braze path needs to be reverted. See
`campaign-pipeline`'s "Change of record (2026-08-16)" section for the reasoning.

**Pipeline stage:** ZIP → monday Email Localization Uploads board → n8n EN Thin Flow → Braze
template. Before 2026-08-16 this was the final step of the campaign-request pipeline. It
replaces manually pasting HTML into Braze: the n8n pipeline slices the HTML into Braze
content blocks, hosts the images on Cloudinary (so no more expiring Figma asset URLs), and
builds the Braze template, writing the link back to the item.

## When to Use

- A ZIP from `figma-to-html` (or an Email Love export) is ready to become a Braze template
- "Upload the ZIP", "run EN-US", "put this on the localization board"
- Asked for the Braze Template Link for a campaign request

## The only writes this skill is allowed to make

These values are fixed. They are not parameters to infer per run, and nothing about a
request should change them. The group is the one exception — it's fixed **per caller**,
not per run: which of the two groups below applies depends on who invoked this skill, never
on anything in the request itself.

| What | Value |
|---|---|
| Board | `18409935750` — Email Localization Uploads (Subitem method) |
| Group | See table below — depends on the caller |
| ZIP column | `file_mm24s6ep` — "ZIP File" |
| Trigger | `color_mm2fex1q` — "Run en-US", label **`Run EN-US`** |

| Caller | Group |
|---|---|
| Human submitter (this skill invoked directly/manually) | `group_mm64c9pb` — "Email Requests" |
| [`campaign-pipeline`](../campaign-pipeline/SKILL.md) orchestrator (agent-created, no human ZIP review) | `group_mm655ecf` — "Campaign Request" |

The two groups exist precisely so agent-created items never mix with human-submitted ones on
the same shared board. If it's ambiguous which caller this is, ask rather than guessing.

Anything outside that set is out of scope for this skill — see DON'Ts.

## Workflow

### 1. Confirm the ZIP is well-formed before touching monday

Validate locally first — a malformed ZIP that reaches the board fires a pipeline run that
then fails, which is noisier and harder to unwind than just checking up front:

- Exactly one `.html` file, at the ZIP root (any filename — **not** necessarily `index.html`).
- An `Images/` folder (capital I) if the HTML references any images.
- Every `src="Images/…"` in the HTML resolves to a file that exists in `Images/`.
- No absolute `file://` or local paths, and no leftover temporary Figma asset URLs
  (`figma.com/api/mcp/asset/…`) — those expire and would bake a broken image into Braze.

### 2. Create the item

`create_item` on board `18409935750` with the `group_id` for this caller — see the table
above (`group_mm64c9pb` for a human submitter, `group_mm655ecf` when invoked from
`campaign-pipeline`). Name it after the email/campaign — reuse the campaign request item's
name so the two boards line up.

**Check for an existing item with that name in that group first.** If one exists *and this is
a first-time submission* (not a follow-up fix to something already run), stop and ask rather
than creating a near-duplicate — this board is shared team infrastructure with 200+ items
feeding live Braze templates. But if the existing item is a prior run of the **same**
correction workflow (per step 3b — you're uploading a fix after an earlier run of this exact
campaign), creating another same-named item is expected, not a mistake — don't stop and ask
in that case, just proceed.

### 3. Upload the ZIP

Three steps, in order:
1. `get_asset_upload_url` with the filename, `contentType: "application/zip"`, and the real
   byte size.
2. `PUT` the file to the returned `upload_url` with `--data-binary`, capturing the `ETag`
   response header (use `curl -i` so headers are visible).
3. `finalize_asset_upload` with the `upload_id`, `etag`, `boardId`, `itemId`, and
   `columnId: "file_mm24s6ep"`.

Confirm the column actually shows the file before moving on. Don't trigger a run against an
item whose ZIP column is empty.

### 3b. Every fix gets a brand-new item — never patch an existing one

**Per explicit instruction (2026-08-13): after any change to the HTML/ZIP — a bug fix, a
subject-line edit, anything — always create a fresh item on this board and run the normal
Steps 2–4 on it. Never go back and modify the ZIP column (or anything else) on a
previously-created item, even one this skill itself created.**

This was tried the other way first (clear `file_mm24s6ep` to `null`, then re-upload the
corrected ZIP onto the same item) after discovering the column has no per-file delete
mutation and a same-item re-upload without clearing first just adds a second file
(confirmed 2026-08-13, monday item 12792404696). That clear-then-reuse approach worked
mechanically, but the user's explicit direction going forward is simpler and safer: skip
the reuse path entirely and always create a new item per correction. Every run — first
attempt or fifth fix — is Steps 2–4 verbatim on a fresh item; there is no separate
"re-upload" procedure anymore.

One practical consequence: the localization board will accumulate one item per correction
for the same campaign (e.g. three "NPO #13" items after two fixes). That's expected — it's
the same tradeoff `campaign-pipeline`'s `group_mm655ecf` lane already makes (agent runs
never confused with human ones), just applied at finer grain. If the trail of superseded
items for one campaign gets confusing, that's a call for the user to archive old ones, not
a reason to start patching items in place again.

### 4. Trigger EN-US — and only EN-US

Set `color_mm2fex1q` to the label `Run EN-US`. That fires the Monday automation → the EN Thin
Flow (`yHcq5fS6Yn1G8OrV`), which extracts the ZIP, slices the HTML into content blocks,
uploads images to Cloudinary, and creates the Braze master template.

### 5. Report, don't poll aggressively

The run takes roughly 5 minutes for EN. Watch the item's en-US subitem `Pipeline Status`
(`color_mm2pgycv`) progress toward `Done` / `Done (No Images)`, then read both of these off
the parent item and hand them back together:

- `link_mm32jmjx` ("Braze Template Link")
- `pulse_id_mm3qydpj` ("Search Braze For") — the monday item's own numeric ID, always
  present regardless of run outcome. **The direct Braze link sometimes redirects to the
  Braze homepage instead of the template** (confirmed 2026-08-13) — this number is the
  reliable fallback: paste it into Braze's own search to find the template by hand. Always
  report it alongside the link, phrased for a human, not as the raw column name — e.g.
  "The email template number for **{item name}** is: **{number}** — search this in Braze if
  the link above lands on the homepage instead of the template." Report it every time, not
  only on success — include it even when reporting an error below.

If it lands on `Error` / `Error in Braze` / `Exhausted — Needs Re-run`, report the status,
the `pulse_id_mm3qydpj` value (same phrasing as above), and the subitem's execution link.
Don't retry the trigger more than once — repeated failures are a pipeline issue for Netanel
Darshan (`netanelda@monday.com`), and re-firing just adds runs.

## DOs

- ✅ Validate the ZIP locally before creating anything on the board.
- ✅ For a human submitter: show the user what you're about to do (item name, group,
  filename) and get a go-ahead before the first write — this is shared team infrastructure
  wired to live Braze sends, the same bar `campaign-brief` applies to publishing on a shared
  board. For the `campaign-pipeline` orchestrator: no go-ahead pause — its dedicated
  `group_mm655ecf` lane is the safety boundary instead, by that skill's own design.
- ✅ Reuse the campaign request's item name so the request board and this board correspond.

## DON'Ts

- ❌ **Never set any other Run column.** `color_mm25henb` (pt-BR), `color_mm3b8f63` (de-DE),
  `color_mm3nk1hp` (fr-FR), `color_mm3psm5j` (ja-JP), `color_mm3r373` (es-MX),
  `color_mm3rmtx` (Tier 2 — fans out to all five), `color_mm3r2d2j` (Pre-Localized),
  `color_mm3r2k70` (Tier 3). Each one starts a real AI translation pipeline with real cost
  and a real Braze write. These emails are English-only; there is never a reason to touch them.
  `color_mm3r373` (es-MX) is the easiest to hit by mistake — "ES" and "EN" are one keystroke
  apart and a prior instruction in this project's history contained exactly that slip.
- ❌ **Never create an item in any group but the two listed above** (`group_mm64c9pb` or
  `group_mm655ecf`, chosen by caller). The other groups (Winback, Agents Trial Onboarding,
  Newsletter, …) are live campaign sequences owned by other people.
- ❌ **Never modify an existing item on this board, full stop** — not its ZIP, not its Run
  columns, not its name. Not even an item this skill (or `campaign-pipeline`) created
  earlier in the same conversation. Every correction is a brand-new item running Steps
  2–4 fresh — see step 3b. This applies doubly to an item someone else submitted; existing
  items of any origin map to live Braze templates.
- ❌ Don't set subitem columns (`Create Template`, `Pipeline Status`, …). Those are
  automation-owned; writing them by hand fights the pipeline and can publish to Braze
  unreviewed.
- ❌ Don't touch the QA Results board (`18403977089`) — no approving, no recalling. For
  English there is no approval gate to click; the EN Thin Flow templates directly.
- ❌ Don't upload to `file_mm3rmmac` (Pre-Localized ZIP) — that column pairs with the
  Pre-Localized trigger and bypasses the EN flow entirely.

## Common Mistakes

| Mistake | What it looks like | Fix |
|---|---|---|
| Assuming the HTML must be `index.html` | `how-to-email.md` says `index.html`, but real Email Love exports are named `Email 2_7_6_2026_.html` — a validator hard-checking for `index.html` would reject every genuine export | Accept any single root-level `.html` file |
| Shipping a ZIP whose HTML still points at `figma.com/api/mcp/asset/…` URLs | Images render during review, then 404 about a week later — after the Braze template is live | Re-path every image to `Images/<file>` and confirm the file exists in the ZIP |
| Reading "ES" as the target locale | Fires the full es-MX AI translation pipeline instead of the EN Thin Flow | These sends are English-only. Only `color_mm2fex1q`, ever |
| Uploading a corrected ZIP onto the same existing item instead of creating a new one | The column ended up holding both the buggy and the fixed ZIP (monday item 12792404696, 2026-08-13) — ambiguous which one a re-run actually reads | Always create a brand-new item for every fix and run Steps 2–4 on it; never touch a prior item's ZIP column — see step 3b |

## Related

- [figma-to-html](../figma-to-html/SKILL.md) — produces the ZIP this skill uploads
- [monday-reader](../monday-reader/SKILL.md) — resolves the campaign request's Figma URL + CTA link
- [campaign-pipeline](../campaign-pipeline/SKILL.md) — used to run this skill as its final step; as of 2026-08-16 it calls `braze-email-templates` instead (see that skill's "Change of record")
- [braze-email-templates](../braze-email-templates/SKILL.md) — the direct-to-Braze REST path that replaced this skill in `campaign-pipeline`'s default flow
- [Email Love shell](../figma-to-html/knowledge/email-love-shell.md) — the HTML structure the pipeline expects
