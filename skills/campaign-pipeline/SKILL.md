---
name: campaign-pipeline
description: >
  Use when given a monday.com campaign item URL/ID and asked to run the full email pipeline
  end to end — "run the full campaign pipeline", "create the Braze template for this
  campaign", "build and ship this email", or "take this monday item all the way to Braze".
  Chains monday-reader, figma-to-html, and braze-email-templates in order so the whole
  monday item → Figma → HTML → Braze template chain runs from one instruction, writing
  directly to Braze via its REST API rather than going through the monday Email
  Localization Uploads board.
status: draft
owner: osherma@monday.com
---

# Skill: Campaign Pipeline (Phase 1 — full-chain orchestrator, Braze only)

**Pipeline stage:** monday item → Figma → HTML → Braze template, end to end. This skill
does not do any of that work itself — it calls existing skills' documented workflows, in
order, and does not reimplement Figma reading, HTML assembly, or Braze API calls. If any
of those skills change, this skill's behavior changes with them automatically; don't fork
logic from them into this file.

**Why this exists:** `monday-reader`, `figma-to-html`, and `braze-email-templates` each
already do their piece correctly, but nothing chained them for a single monday item —
running the full pipeline meant manually invoking each one, one at a time. This skill is
that chain.

**Braze only.** `braze-email-templates` talks to Braze's REST API directly; there is no
HubSpot equivalent, so this skill cannot complete the HubSpot path — see Step 0.

## Change of record (2026-08-16)

**As of 2026-08-16, this pipeline writes directly to Braze via `braze-email-templates`
and no longer uses the monday Email Localization Uploads board (`email-localization-upload`,
board `18409935750`).** That board-based path is being kept in the repo as a legacy/rollback
option, but is no longer the default this skill calls. If you're looking for the
board-upload behavior this skill used before, see `email-localization-upload`'s own SKILL.md
— it's still fully functional standalone, just no longer wired into this orchestrator's
Step 4.

This means every run of this skill now needs a one-time, per-machine setup: `~/.braze_secrets`
must exist (see `braze-email-templates`'s "First-time setup" section) before Step 4 can run.
If it doesn't exist yet, stop at Step 4 and tell the user to run `setup_credentials.sh`
themselves in a real terminal — never attempt to supply or type the API key on their behalf.

## When to Use

- Given a monday.com campaign item URL/ID and asked to run the whole pipeline, not just one
  step of it
- "Create the Braze template for this campaign", "build and ship this email",
  "take this monday item all the way to Braze"

## The only checkpoint

Unlike `figma-to-html` and `braze-email-templates` run standalone (which each pause for a
review before their own writes), this skill asks **one question, at the very start, and
nothing else** — see Step 0. Every step after that runs fully automatically, including the
steps that would otherwise pause: `figma-to-html`'s "show the HTML, get a go-ahead before
finalizing" and `braze-email-templates`'s "ask about the three optional transforms" (still
asked, since those are genuine content decisions, not a go-ahead pause — see Step 4) and its
"new template vs. update" identity check. Treat only the go-ahead-style pauses as
automatically accepted for this caller — see each skill's own DOs for the caller-scoped
language covering this.

All of `figma-to-html`'s *content-correctness* checks (encoding, button spec, dark-mode
scaffolding, CTA cross-check) still run in full and must still pass — only the human pause
is skipped, not the verification. Likewise `braze-email-templates`'s own verify-after-write
step (`verify_template.sh`) always runs — that's a correctness check, not a pause, and is
never skipped.

## Workflow

### Step 0 — Braze or HubSpot (the only checkpoint)

Ask which platform, using the same neutral phrasing `figma-to-html` uses — never mark either
as default, since the requester already knows which platform this campaign targets.

- **If HubSpot:** stop here. Say explicitly that this skill is Braze-only — there is no
  HubSpot equivalent of the direct-to-Braze REST path. Point the user at running
  `figma-to-html` directly for its HubSpot hand-paste output instead. Do not invent a
  HubSpot equivalent of Step 4.
- **If Braze:** continue to Step 1. Do not ask again at any later step — this answer covers
  the whole run.

### Step 1 — Resolve the monday item (`monday-reader`)

Run `monday-reader`'s workflow on the given item to resolve `{item_name, figma_url,
cta_link, subject_line, preview_text}` (or, for a generic-template item, `{item_name,
is_generic_template: true, content, cta_link}`). Follow that skill's own DOs/DON'Ts exactly
— in particular, check the Design column for "Generic email template" before concluding
there's no Figma design.

If a Figma URL/CTA can't be resolved and the Design column doesn't say "Generic email
template," **stop and report what's missing.** Don't guess a link or invent placeholder copy.

Carry `subject_line` and `preview_text` through to Step 4 — `braze-email-templates`'s own
workflow asks for these when creating a new template, but here they're already known from the
monday item, so answer that ask directly with the resolved values instead of re-prompting the
user for them.

### Step 2 — Build the HTML (`figma-to-html`)

Run `figma-to-html`'s workflow using the Step 1 output as input. Platform is already decided
(Step 0) — skip its Step 0. Run its full verify/fix loop (character encoding, button spec
fidelity, dark-mode scaffolding via the real `email-love-shell.md` structure — including both
the fixed-background-card and border-only-card class="text" rules — CTA link cross-check
against Step 1's `cta_link`) exactly as documented. Treat its "show the HTML, get a go-ahead"
checkpoint as automatically accepted — do not actually pause for the user here.

Build the HTML + `Images/` folder exactly per `figma-to-html`'s asset-handling steps: every
image downloaded from Figma and re-pathed to a local `Images/<file>`, no leftover
`figma.com/api/mcp/asset/…` URLs. There's no ZIP-packaging step needed for this path —
`braze-email-templates` uploads each image individually rather than consuming a ZIP.

### Step 3 — Verify credentials are ready

Check `~/.braze_secrets` exists (existence only — never read or print its contents). If it's
missing, **stop here** and tell the user this is a one-time setup they need to do themselves:
run `braze-email-templates/scripts/setup_credentials.sh` in a real terminal shell (never an
AI/chat panel — pasting an API key into a chat box logs it in plain text; a real incident on
2026-08-16 required rotating a key exposed exactly this way). Do not attempt to proceed to
Step 4 without it, and do not offer to run the setup script's interactive prompt on the
user's behalf — it needs their own hidden keyboard input.

### Step 4 — Create/update the Braze template (`braze-email-templates`)

Run `braze-email-templates`'s Workflow A end to end:

1. Confirm the 1:1 mapping between `Images/` files and the HTML's `src="Images/…"`
   references (already true after Step 2, but re-check per that skill's own step 1).
2. Upload every image individually via `upload_asset.sh`, collect each CDN URL. If any
   upload fails on the 5MB media-library size cap, downscale that image's dimensions and
   retry — don't treat it as an upload-call bug.
3. Swap every local `Images/…` path for its CDN URL in the HTML — exact-match per image,
   confirmed occurrence count, not a blanket regex.
4. **Still ask about the three optional transforms every time** — this is a genuine content
   decision per campaign, not a pause to skip: wrap `monday.com` mentions in the tracked
   link, insert the `{{content_blocks.${fotter_with_monday_logo}}}` footer reference (default
   yes on this path — there is no board automation here to supply one, unlike the retired
   board path, so skipping it ships an email with no footer at all), and whether to set the
   outer background to `#f3f4f5`.
5. This is always a **new template** for this orchestrator — campaign-pipeline runs are
   never "edit an existing template" calls, so skip `braze-email-templates`'s new-vs-update
   question and go straight to `create_template.sh` with Step 1's `subject_line` and
   `preview_text` already in hand (see Step 1 note above — don't re-ask for these).
6. Create via `create_template.sh <html> "<item name>" "<subject_line>" "<preview_text>"`,
   capture the returned `email_template_id`.
7. **Always verify** via `verify_template.sh <email_template_id> <html>` — never skip this
   because the create call returned success.

### Step 5 — Report the result

Report the `email_template_id` plainly — there's no monday board item in this path anymore,
so there's no separate "search Braze for this number" fallback number to report alongside it;
the `email_template_id` *is* the thing to search Braze by, and it's also usable directly to
open `https://dashboard-06.braze.com/engagement/templates_and_media/media_library/609909f4cde3c93ffa1267cb`
and search by name or ID.

If `verify_template.sh` reports a mismatch, treat it as a real bug — investigate (encoding
issue, a stray character introduced during the CDN-URL swap) rather than reporting success
anyway.

## DOs

- ✅ Ask Braze vs. HubSpot once, at the very start, and nowhere else in the run.
- ✅ Delegate every actual capability (Figma reading, HTML assembly, Braze API calls) to the
  skill that already owns it — this skill only sequences and reports.
- ✅ Check `~/.braze_secrets` exists before Step 4, every run — don't assume it's already
  there because a prior run in the same conversation succeeded on a different machine/session.
- ✅ Still ask about `braze-email-templates`'s three optional transforms every time — these
  are content decisions, not the kind of go-ahead pause this skill auto-accepts.
- ✅ Always run `verify_template.sh` after `create_template.sh` — never skip verification.
- ✅ Stop and report clearly if Step 1 can't resolve a Figma URL/CTA, or if Step 2's
  verify/fix loop can't reach a clean pass after its capped retries — don't force a broken
  result through to Step 4.

## DON'Ts

- ❌ Don't re-ask Braze vs. HubSpot at Step 2 or any later step — Step 0 already answered it.
- ❌ Don't route through `email-localization-upload` / the monday board — that path is
  retired for this orchestrator as of 2026-08-16 (see "Change of record" above). Only use it
  if the user explicitly asks to run that legacy path by name.
- ❌ Don't reimplement any logic from `monday-reader`, `figma-to-html`, or
  `braze-email-templates` inline in this skill — always defer to their own documented
  workflows so a change to one of them doesn't silently drift out of sync here.
- ❌ Don't skip `figma-to-html`'s content-correctness checks just because the human-review
  pause is skipped — encoding, button spec, dark-mode scaffolding, and the CTA cross-check
  all still have to pass.
- ❌ Don't attempt to run `setup_credentials.sh`'s interactive prompt on the user's behalf,
  or ask them to paste their API key into this chat — it must go directly into the script's
  own hidden terminal prompt, in a real terminal, never through any chat interface.
- ❌ Don't skip the three optional-transforms questions just because this orchestrator
  otherwise runs unattended — they're content decisions specific to each campaign, not a
  review-pause.

## Related

- [monday-reader](../monday-reader/SKILL.md) — Step 1
- [figma-to-html](../figma-to-html/SKILL.md) — Step 2
- [braze-email-templates](../braze-email-templates/SKILL.md) — Steps 3–4, the direct-to-Braze
  REST path that replaced the monday-board upload
- [email-localization-upload](../email-localization-upload/SKILL.md) — retired from this
  orchestrator's default flow as of 2026-08-16; still usable standalone if explicitly asked for
