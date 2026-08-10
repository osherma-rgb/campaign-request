# Generic email template — for requests with no Figma design

Some campaign requests on the "🪩 Email campaigns requests" board (boardId `112753365`)
arrive with **no Figma link at all** — just plain-text copy (in the `long_text` column or
an update's `Content:` line) and a CTA link. These are not a gap to report and stop on;
they're a recognized, common request type that always resolves to the same base
structure, confirmed against real examples:
[22865:1240](https://www.figma.com/design/b55DMxunhfbb39ruV63LQR/Drafts---email-requests?node-id=22865-1240)
(no button) and
[23006:1629](https://www.figma.com/design/b55DMxunhfbb39ruV63LQR/Drafts---email-requests?node-id=23006-1629)
(with button — this one's content matches monday item `12669890031` almost verbatim).

## How to recognize this request type

Check the item's **Design** column (on board `112753365` this is column id
`single_select_MjigC4Bz`) for the exact text **"Generic email template"**. When that's set
and `monday-reader` finds no Figma URL, this is that recognized type — assemble directly
from this template instead of stopping. (If the Design column says something else, or the
column doesn't exist on a different board, fall back to `monday-reader`'s normal
"no Figma URL found" behavior — don't assume every design-less item is this type.)

## Structure

1. **Spacer** — 40px tall, full 640px width, sitting on a `#f3f4f5` background (this is the
   only place that background color appears; everything below is white).
2. **Header** — white background, 640px wide, `padding: 38px 40px`, the monday.com main
   brand logo (`monday-com.png` from `references/asset-index.md`; the two live examples
   used a Figma-hosted crop at 176×31px — same size/centering, just source the real logo
   asset instead of the temporary Figma URL), centered.
3. **Body text** (one or more blocks) — white background, 640px wide,
   `padding: 24px 56px`, `font: 15px/150% Poppins regular, color:#000000`, left-aligned.
   This is the item's own copy, taken verbatim from its `Content:` text — don't rewrite
   it, just:
   - Replace the literal greeting placeholder (`Hi [First Name],` / `Dear {{...}}`) with
     the first-name substitution (`braze-liquid-tags.md` §1).
   - Wrap every `monday.com` mention per `braze-liquid-tags.md` §2 — the live examples
     don't wrap it themselves (Figma drafts predate this rule), don't copy that habit.
   - If the copy contains a bracket placeholder for a link (`[Link to book a time]`,
     `[CTA]`, `[Link]`), remove that placeholder text and represent it as the button in
     step 4 instead — don't leave it as inline placeholder text or a bare inline link.
4. **Button** (only if the item's copy actually calls for one — some requests, like the
   legal-notice example, have no CTA at all) — white background, 640px wide, centered.
   Reuse `components/buttons.md`'s PRIMARY CTA variant as-is (solid black pill,
   auto-width) rather than the live examples' fixed 248×44px/60px-radius button — same
   visual effect, but it keeps this template on the same single source of truth as every
   other email instead of a second button style to maintain. `href` = `monday-reader`'s
   resolved `cta_link`. Button label: a short imperative phrase matching what the link
   actually does (the examples used "Schedule a call" for a Calendly link) — infer it from
   the copy's context, don't default to generic "Click here."
5. **Closing text** — same styling as step 3, the copy's own sign-off (name, title,
   "monday.com" wrapped per step 3's rule) plus any fine-print note (the examples used
   `color:#777` for something like "*Your gift card will be sent within 1 week").
6. **Mandatory footer** — `braze-liquid-tags.md` §4, exactly as in every other email from
   this pipeline. The live Figma drafts don't show it (drafts predate send-time assembly),
   but the shipped HTML always needs it — this isn't optional just because the reference
   design omits it.

## What NOT to do

- Don't go hunting for a matching Figma URL when the Design column already says "Generic
  email template" and none exists — that's the signal this template applies, not a data
  gap.
- Don't invent new styling "in the spirit of" these examples — reuse
  `knowledge/design-tokens.md` and `knowledge/components/` exactly like every other
  conversion; this template only fixes the *layout*, not a license to skip the shared
  component library.
