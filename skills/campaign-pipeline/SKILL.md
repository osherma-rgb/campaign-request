---
name: campaign-pipeline
description: >
  Use when given a monday.com campaign item URL/ID and asked to run the full email pipeline
  end to end — "run the full campaign pipeline", "create the Braze template for this
  campaign", "build and ship this email", or "take this monday item all the way to Braze".
  Chains monday-reader, figma-to-html, and email-localization-upload in order so the whole
  monday item → Figma → HTML → ZIP → Braze template chain runs from one instruction, reusing
  the real n8n localization pipeline rather than reimplementing any part of it.
status: draft
owner: osherma@monday.com
---

# Skill: Campaign Pipeline (Phase 1 — full-chain orchestrator, Braze only)

**Pipeline stage:** monday item → Figma → HTML → ZIP → Braze template, end to end. This
skill does not do any of that work itself — it calls three existing skills' documented
workflows, in order, and does not reimplement Figma reading, HTML assembly, board writes, or
n8n triggering. If any of those skills change, this skill's behavior changes with them
automatically; don't fork logic from them into this file.

**Why this exists:** `monday-reader`, `figma-to-html`, and `email-localization-upload` each
already do their piece correctly, but nothing chained them for a single monday item — running
the full pipeline meant manually invoking all three, one at a time. This skill is that chain.

**Braze only.** The monday Email Localization Uploads board (and the n8n pipeline behind it)
has no HubSpot equivalent, so this skill cannot complete the HubSpot path — see Step 0.

## When to Use

- Given a monday.com campaign item URL/ID and asked to run the whole pipeline, not just one
  step of it
- "Create the Braze template for this campaign", "build and ship this email",
  "take this monday item all the way to Braze"

## The only checkpoint

Unlike `figma-to-html` and `email-localization-upload` run standalone (which each pause for a
review before their own writes), this skill asks **one question, at the very start, and
nothing else** — see Step 0. Every step after that runs fully automatically, including the
steps that would otherwise pause: `figma-to-html`'s "show the HTML, get a go-ahead before
packaging the ZIP" and `email-localization-upload`'s "get a go-ahead before creating the board
item." Both are treated as automatically accepted for this caller specifically — see each
skill's own DOs for the caller-scoped language covering this.

This is deliberate, not a shortcut: the safety net for unattended writes is the dedicated
`group_mm655ecf` ("Campaign Request") group on the localization board (see Step 4) — agent
runs never land in the same group as human-submitted requests, so a bad run is easy to spot
and never confused with real human work. All of `figma-to-html`'s *content-correctness*
checks (encoding, button spec, dark-mode scaffolding, CTA cross-check) still run in full and
must still pass — only the human pause is skipped, not the verification.

## Workflow

### Step 0 — Braze or HubSpot (the only checkpoint)

Ask which platform, using the same neutral phrasing `figma-to-html` uses — never mark either
as default, since the requester already knows which platform this campaign targets.

- **If HubSpot:** stop here. Say explicitly that this skill is Braze-only, because the
  localization board (and the n8n pipeline behind it) has no HubSpot path — there is nowhere
  for a HubSpot ZIP to go in Step 4. Point the user at running `figma-to-html` directly for
  its HubSpot hand-paste output instead. Do not invent a HubSpot equivalent of Steps 3–4.
- **If Braze:** continue to Step 1. Do not ask again at any later step — this answer covers
  the whole run.

### Step 1 — Resolve the monday item (`monday-reader`)

Run `monday-reader`'s workflow on the given item to resolve `{item_name, figma_url,
cta_link}` (or, for a generic-template item, `{item_name, is_generic_template: true, content,
cta_link}`). Follow that skill's own DOs/DON'Ts exactly — in particular, check the Design
column for "Generic email template" before concluding there's no Figma design.

If a Figma URL/CTA can't be resolved and the Design column doesn't say "Generic email
template," **stop and report what's missing.** Don't guess a link or invent placeholder copy.

### Step 2 — Build the HTML (`figma-to-html`, Braze/ZIP path)

Run `figma-to-html`'s workflow for the localization-pipeline (ZIP) Braze path, using the
Step 1 output as input. Platform is already decided (Step 0) — skip its Step 0. Run its full
verify/fix loop (character encoding, button spec fidelity, dark-mode scaffolding via the real
`email-love-shell.md` structure, CTA link cross-check against Step 1's `cta_link`) exactly as
documented. Treat its "show the HTML, get a go-ahead" checkpoint as automatically accepted —
do not actually pause for the user here.

### Step 3 — Package the ZIP

Package the assembled HTML + downloaded images exactly per `figma-to-html`'s ZIP-packaging
step: one root-level `.html`, an `Images/` folder, every `src="Images/…"` resolving to a real
file, no leftover `figma.com/api/mcp/asset/…` URLs.

### Step 4 — Upload to the localization board (`email-localization-upload`)

Run `email-localization-upload`'s workflow with one change from its documented default: use
**`group_mm655ecf`** ("Campaign Request") as the group, not `group_mm64c9pb` — this is the
group reserved specifically for this orchestrator, per that skill's caller-scoped group table.
Everything else follows that skill exactly:

1. Validate the ZIP locally (already true after Step 3, but re-check per that skill's step 1).
2. Check for an existing item with this name in `group_mm655ecf` first — if one exists, stop
   and ask rather than creating a near-duplicate, same as that skill's own rule.
3. Create the item in `group_mm655ecf`, upload the ZIP to `file_mm24s6ep`, confirm the column
   shows the file.
4. Set `color_mm2fex1q` → `Run EN-US`. Treat the "get a go-ahead before the first write"
   checkpoint as automatically accepted for this caller — do not actually pause here either.

### Step 5 — Report the result

Watch the item's en-US subitem `Pipeline Status` (`color_mm2pgycv`) without polling
aggressively, the same cadence `email-localization-upload` step 5 uses. When it reaches
`Done` / `Done (No Images)`, read all of the following off the parent item and hand them
back together as the final result:

- `link_mm32jmjx` ("Braze Template Link")
- `pulse_id_mm3qydpj` ("Search Braze For") — the monday item's own numeric ID; always
  report this, success or failure, since it's what a human uses to find the item again
- the monday item URL created in `group_mm655ecf`

If it lands on `Error` / `Error in Braze` / `Exhausted — Needs Re-run`, report the status,
the `pulse_id_mm3qydpj` value, and the subitem's execution link rather than retrying — same
escalation path as `email-localization-upload` (Netanel Darshan, `netanelda@monday.com`).

## DOs

- ✅ Ask Braze vs. HubSpot once, at the very start, and nowhere else in the run.
- ✅ Delegate every actual capability (Figma reading, HTML assembly, ZIP packaging, board
  writes) to the skill that already owns it — this skill only sequences and reports.
- ✅ Always target `group_mm655ecf` on board `18409935750`, never `group_mm64c9pb`.
- ✅ Stop and report clearly if Step 1 can't resolve a Figma URL/CTA, or if Step 2's
  verify/fix loop can't reach a clean pass after its capped retries — don't force a broken
  result through to Step 4.

## DON'Ts

- ❌ Don't re-ask Braze vs. HubSpot at Step 2 or any later step — Step 0 already answered it.
- ❌ Don't implement a HubSpot version of Steps 3–4 — there is no localization-board
  equivalent for HubSpot; stop at Step 0 instead.
- ❌ Don't reimplement any logic from `monday-reader`, `figma-to-html`, or
  `email-localization-upload` inline in this skill — always defer to their own documented
  workflows so a change to one of them doesn't silently drift out of sync here.
- ❌ Don't create the board item in `group_mm64c9pb` — that group is for human submitters
  only; this skill always uses `group_mm655ecf`.
- ❌ Don't skip `figma-to-html`'s content-correctness checks just because the human-review
  pause is skipped — encoding, button spec, dark-mode scaffolding, and the CTA cross-check
  all still have to pass.

## Related

- [monday-reader](../monday-reader/SKILL.md) — Step 1
- [figma-to-html](../figma-to-html/SKILL.md) — Step 2 (Braze/ZIP path) and Step 3
- [email-localization-upload](../email-localization-upload/SKILL.md) — Step 4, using the
  `group_mm655ecf` lane reserved for this orchestrator
