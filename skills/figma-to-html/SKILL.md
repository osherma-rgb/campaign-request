---
name: figma-to-html
description: >
  Converts an approved Lifecycle Marketing email design in Figma into send-ready,
  Braze-compatible HTML — mapping each section of the Figma frame to monday.com's
  approved email components, applying required Braze personalization/liquid-tag
  substitutions, and validating the HTML before handoff. Use when given a Figma
  file/frame URL for an email and asked to turn it into HTML for Braze.
status: draft
owner: osherma@monday.com
---

# Skill: Figma to HTML (Phase 1 — manual trigger, Braze only)

**Pipeline stage:** Figma design → HTML. This is one step in a larger email-campaign
agent (monday item → Figma → HTML → Braze, later HubSpot). Phase 1 is manually
triggered and Braze-only. It does not upload the result anywhere; it hands back finished
HTML for the user to ship. When the input is a monday item rather than a bare Figma URL,
it delegates to `monday-reader` (see step 0) rather than reading the item itself.

## When to Use

- Given a Figma file/frame URL for a Lifecycle Marketing email, asked to turn it into HTML
- Given a monday.com campaign item and asked to build/send its email
- "Build/convert/code this Figma design into an email"
- "Turn this Figma into something I can paste into Braze"

## Workflow

### 0. Resolve the Figma URL (if starting from a monday item)

If given a monday.com item instead of a Figma URL directly, run the `monday-reader` skill
first to resolve `{figma_url, cta_link}` from that item. Carry the `cta_link` through to
step 3's CTA cross-check below. If given a Figma URL directly (no monday item), skip this
step — there's no CTA link to cross-check against, so step 3's CTA check is skipped too.

### 1. Read the Figma design (mcp to Figma)

- Load the `figma:figma-design-to-code` skill first — mandatory prerequisite before any
  `get_design_context` call.
- Call `get_design_context` on the given Figma URL/node; also call `get_screenshot` for a
  visual reference to check the assembled HTML against later.
- Walk the frame top-to-bottom and extract, per section: section type (headline / body
  text / CTA button / image / columns / list / header-logo), literal text content, and any
  link href already set in Figma. Note the background (light/dark) each section sits on —
  needed for step 3's `monday.com` color-matching.

### 2. Map to approved components → assemble HTML

- For each extracted section, pick the matching snippet from `knowledge/components/`:
  headline → `headings.md`, body copy → `body-text.md`, the CTA → `buttons.md` (exactly
  one primary button per email), images → `images.md`, feature trios → `columns.md`,
  benefit lists → `lists.md`, product logos → `header-logos.md` +
  `references/asset-index.md` for which real asset to use.
- Assemble inside `knowledge/email-shell.md` (640px table shell, inline styles) in the
  same reading order as the Figma frame. Swap in only content (text/href/image src) —
  reuse `knowledge/design-tokens.md` values for anything not directly given by the Figma
  design. Never invent a new button shape, font, color, or spacing.

### 3. Verify & fix — loop until clean

Check all of the following; on any failure, fix it and re-check from the top. Cap at a
few passes — if something still fails after that, stop and surface the remaining issue to
the user instead of looping forever.

- **HTML well-formedness**: every tag closed, valid nested `<table>` structure (this is
  email HTML — tables and inline styles, not divs/flexbox/grid).
- **Dark-mode contrast**: `knowledge/email-shell.md`'s CSS forces the email background to
  black in dark mode but only flips elements carrying `class="text"` to white — anything
  else with a hardcoded dark color (e.g. `color: #000000`) goes invisible against that
  black background. Scan every text node in the assembled HTML (not just the ones you
  wrote by hand — copied component snippets can have the same gap) and confirm each one
  either carries `class="text"` or uses a color that's already legible on both a white and
  a black background. Separately, check every *solid-background* element (not just text) —
  a solid black button (the primary CTA) has legible white text but no visible shape once
  the page behind it also turns black; that button's wrapping `<td>` must carry
  `class="mj-b"` (see `knowledge/email-shell.md` and `buttons.md`'s primary variant) so
  dark mode flips it to a white pill instead of vanishing. If a snippet in
  `knowledge/components/` is missing either escape, fix the knowledge file itself, not just
  this one output — otherwise the same email breaks in dark mode again next time.
- **Character encoding**: Figma text often contains raw Unicode punctuation — `·` (middle
  dot separators), `–`/`—` (en/em dashes), `→` (arrows), curly quotes. Many ESPs/editors
  don't reliably honor the `<meta charset="UTF-8">` tag once HTML is pasted or imported,
  and raw Unicode punctuation can mojibake into garbage (e.g. `·` renders as `¬∑`). Replace
  every non-ASCII punctuation character in rendered text — including `alt` attributes,
  which still render if an image fails to load — with its HTML entity equivalent
  (`&middot;`, `&ndash;`, `&mdash;`, `&rarr;`, `&rsquo;`/`&lsquo;`, `&rdquo;`/`&ldquo;`)
  before handoff. Scan the *whole* assembled HTML for this, not just the text you typed by
  hand — copied Figma text and image alt text need the same treatment. Plain ASCII text
  (including inside HTML comments, which never render) doesn't need this.
- **First name**: apply the substitution in `knowledge/braze-liquid-tags.md` §1.
- **`monday.com`**: apply the tracked-anchor substitution in
  `knowledge/braze-liquid-tags.md` §2 to **every** plain "monday.com" mention, picking the
  color variant that matches the background noted in step 1. No exceptions for mentions
  that read as plain prose (e.g. a venue name like "monday.com's NYC Office") — email
  clients auto-linkify bare domain-looking text into an ugly default blue underlined link
  regardless of whether Figma had it set up as a link, so leaving it bare is a rendering
  bug, not a neutral choice. Scan every occurrence in the assembled HTML, not just ones
  that look like CTAs.
- **Magic link**: apply the content-block substitution in
  `knowledge/braze-liquid-tags.md` §3 for any sign-in/deep-link CTA.
- **Footer**: apply the content-block substitution in `knowledge/braze-liquid-tags.md` §4
  — inserted right before `</body>`, no inlined footer markup.
- **Visual sanity check**: compare the assembled HTML against the Figma screenshot from
  step 1 — same content, same order, same approximate layout.
- **CTA link cross-check** (only when step 0 supplied a `cta_link` from `monday-reader`):
  the primary CTA button's `href` in the assembled HTML must equal that `cta_link`
  exactly. If it doesn't, fix the HTML's href (never the monday item's value) and recheck.
  State the match explicitly in the handoff — don't just assume it.

Present the final HTML to the user before calling it done (Phase 1 is manual — always
show the result, don't ship it silently).

## DOs

- ✅ Reuse exact values from `knowledge/design-tokens.md` — if a value isn't documented,
  ask or use the closest documented one and say so.
- ✅ Reuse the real product logos/icons in `references/asset-index.md` — genuine brand
  assets, not placeholders.
- ✅ Apply all four `knowledge/braze-liquid-tags.md` substitutions every time, even if the
  Figma design doesn't obviously call for one (e.g. add the footer content block even if
  Figma has no footer frame).
- ✅ Pick component variants by what the content needs, not the first snippet in the file.

## DON'Ts

- ❌ Don't invent a new button shape, font, color, or spacing "in the spirit of" the brand.
- ❌ Don't inline a footer block — always use the `{{content_blocks.${fotter_with_monday_logo}}}`
  reference instead.
- ❌ Don't hand-write a URL for a magic-link CTA — always use the content-block reference.
- ❌ Don't leave a bare `monday.com` mention un-tracked.
- ❌ Don't upload the result to Braze — that's a separate, later step in this agent, out
  of scope here.
- ❌ Don't silently skip the CTA cross-check when a `cta_link` was supplied — a mismatch
  means the HTML is wrong, not the monday item.

## Related

- [monday-reader](../monday-reader/SKILL.md) — resolves the Figma URL + CTA link from a monday item, feeds this skill
- [Design tokens](knowledge/design-tokens.md) — typography, colors, spacing, button variants
- [Email shell](knowledge/email-shell.md) · [Component snippets](knowledge/components/)
- [Braze liquid tags](knowledge/braze-liquid-tags.md) — the four required substitutions
- [Asset index](references/asset-index.md) — real logo/icon assets and where they live
