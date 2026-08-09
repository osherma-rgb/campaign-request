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
triggered and Braze-only — it does not read the Figma URL out of a monday item, and it
does not upload the result anywhere; it hands back finished HTML for the user to ship.

## When to Use

- Given a Figma file/frame URL for a Lifecycle Marketing email, asked to turn it into HTML
- "Build/convert/code this Figma design into an email"
- "Turn this Figma into something I can paste into Braze"

## Workflow

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
- **First name**: apply the substitution in `knowledge/braze-liquid-tags.md` §1.
- **`monday.com`**: apply the tracked-anchor substitution in
  `knowledge/braze-liquid-tags.md` §2, picking the color variant that matches the
  background noted in step 1.
- **Magic link**: apply the content-block substitution in
  `knowledge/braze-liquid-tags.md` §3 for any sign-in/deep-link CTA.
- **Footer**: apply the content-block substitution in `knowledge/braze-liquid-tags.md` §4
  — inserted right before `</body>`, no inlined footer markup.
- **Visual sanity check**: compare the assembled HTML against the Figma screenshot from
  step 1 — same content, same order, same approximate layout.

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
- ❌ Don't read the Figma URL from a monday.com item, and don't upload the result to
  Braze — both are separate, later steps in this agent, out of scope here.

## Related

- [Design tokens](knowledge/design-tokens.md) — typography, colors, spacing, button variants
- [Email shell](knowledge/email-shell.md) · [Component snippets](knowledge/components/)
- [Braze liquid tags](knowledge/braze-liquid-tags.md) — the four required substitutions
- [Asset index](references/asset-index.md) — real logo/icon assets and where they live
