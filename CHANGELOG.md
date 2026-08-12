# Changelog

All notable changes to this repo are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows
[Semantic Versioning](https://semver.org/) (`MAJOR.MINOR.PATCH`): MAJOR for a breaking change
to a skill's documented contract, MINOR for a new skill or capability, PATCH for a fix that
doesn't change any documented interface.

**Every commit from here forward must add an entry to this file** — a new dated version
section, under the category that fits (Added / Changed / Fixed). No exceptions: a commit
without a matching changelog entry is incomplete, the same bar as a commit that fails a
verification step.

## [Unreleased]

### Fixed

- **Tracked `monday.com` anchors keep their light-mode black color in dark mode on the
  Email Love shell path.** Caught on a real Braze send for monday item `12669890031`
  ("Trial joiners interviews #2"): the shell's `.mj-w .text` dark-mode rule flips the
  surrounding paragraph white, but doesn't reach a descendant `<a>` that already carries
  its own explicit inline `color:#000000` — so the link stayed black-on-#1f1f1f, nearly
  unreadable. The shell's dark-mode CSS already ships a scoped `.mj-w .link` rule for
  exactly this case; it just needs the anchor to carry `class="link"`, which
  `braze-liquid-tags.md` §2 never told assemblers to add. Documented in
  `skills/figma-to-html/knowledge/braze-liquid-tags.md` §2 and
  `skills/figma-to-html/knowledge/email-love-shell.md`'s class-scaffolding table.

## [0.2.1] - 2026-08-12

### Fixed

- **Subject/preheader div must use plain characters, never HTML entities.** Caught on a real
  Braze preview render for monday item `12759914421`: the hidden
  `{subject}###{preheader}` div right after `<body>` is extracted by the pipeline as raw
  text, so an entity like `&#39;` never decodes — it rendered literally as `&#39;` in Braze's
  Subject line field instead of becoming an apostrophe. `figma-to-html`'s character-encoding
  rule (escape every non-ASCII punctuation mark) now explicitly excludes this one div; every
  other text node is unaffected. Documented in
  `skills/figma-to-html/knowledge/email-love-shell.md` → "Subject line + preheader",
  `skills/figma-to-html/SKILL.md` (verify/fix loop + Common Mistakes), and
  `skills/figma-to-html/design.md`.
- **Never carry an ALL-CAPS word into the subject/preheader div.** Same real-send review
  flagged "FREE" and "NOW" rendering as shouting caps in the subject line / preview text.
  Source copy (a monday item's Subject line / Preview text fields, or Figma) may have a
  capitalized word for emphasis in the visible design — lowercase it specifically when
  placing it into the hidden subject/preheader div. Visible body copy is unaffected.

## [0.2.0] - 2026-08-12

### Added

- **`skills/campaign-pipeline/`** — a new orchestrator skill that chains `monday-reader` →
  `figma-to-html` → `email-localization-upload` for a single monday item, so the full
  monday item → Figma → HTML → ZIP → live Braze template chain runs from one instruction
  instead of three manual skill invocations. Braze only (HubSpot has no localization-board
  equivalent). Exactly one checkpoint (Braze vs. HubSpot, asked once at the start) — every
  step after that runs automatically, reusing the real n8n pipeline rather than
  reimplementing any part of it.
- `skills/email-localization-upload/SKILL.md`'s "only writes" group is now caller-scoped: a
  human submitter still uses `group_mm64c9pb` ("Email Requests"); the new
  `campaign-pipeline` orchestrator always uses the dedicated `group_mm655ecf`
  ("Campaign Request") group, so agent-created items never mix with human-submitted ones on
  the shared localization board.
- README now documents `email-localization-upload/` (previously in the repo but missing from
  the Layout tree) and the new `campaign-pipeline/`, and describes Phase 1 as running the
  full chain end to end for Braze.

### Verified

- End-to-end run against real monday item `12759914421` ("Nonprofit academy 48"): resolved
  the Figma design and the ticket's actual CTA link (a `forms.monday.com` registration URL,
  distinct from the generic catalog link baked into the Figma file — confirmed via the
  item's raw request update, which explicitly labels `CTA link:`), corrected the primary
  button to match it, built and validated the ZIP, created the item in `group_mm655ecf`,
  uploaded the ZIP, and triggered `Run EN-US` — producing a live Braze template. (The
  0.2.1 fixes above were found reviewing this same run's Braze preview.)

## [0.1.0] - 2026-08-11

### Added

Baseline established before changelog tracking began — summarized from prior commit history,
not itemized per-commit:

- `skills/monday-reader/` — resolves a Figma design URL + CTA link from a monday.com
  campaign item, including the "Generic email template" no-Figma-design case.
- `skills/figma-to-html/` — converts an approved Figma email design into send-ready HTML for
  Braze (via the Email Love shell / ZIP-localization-pipeline path) or HubSpot, with a
  verify/fix loop (character encoding, button spec fidelity, dark-mode scaffolding, CTA
  cross-check) and a running fixes log (`design.md`).
- `skills/email-localization-upload/` — uploads a finished ZIP to the monday Email
  Localization Uploads board and triggers the real n8n EN Thin Flow, rather than
  reimplementing any of that pipeline.
- `braze-liquid-tags.md`, `hubspot-tags.md`, `design-tokens.md`, `email-love-shell.md`, and
  the approved component snippet library under `knowledge/components/`.
- Landing page (`index.html`) and GitHub Pages setup.
