---
name: figma-to-html
description: >
  Use when given a Figma file/frame URL (or a monday.com campaign item) for a Lifecycle
  Marketing email and asked to turn it into HTML for Braze or HubSpot, build/convert/code
  a Figma design into an email, or paste something into Braze/HubSpot — including a
  monday item that has no Figma link but its Design column says "Generic email template."
  Always confirm with the user which platform (Braze or HubSpot) the campaign targets
  before generating HTML, since the two need different substitutions. Also use when an
  already-assembled Braze or HubSpot email looks broken — invisible/white-on-white text
  or a shapeless button after a real Braze send (not just a dark-mode preview), garbled
  punctuation (mojibake) after pasting, "monday.com" showing up as a stray blue underlined
  link, a button that looks bigger/bolder than it should, or a HubSpot email missing its
  preview text / personalization token / monday.com span.
status: draft
owner: osherma@monday.com
---

# Skill: Figma to HTML (Phase 1 — manual trigger, Braze or HubSpot)

**Pipeline stage:** Figma design → HTML (and, for Braze, a ZIP). This is one step in a larger
email-campaign agent (monday item → Figma → HTML → Braze/HubSpot). Phase 1 is manually
triggered. It does not upload the result anywhere; it hands back the finished artifact.
When the input is a monday item rather than a bare Figma URL, it delegates to
`monday-reader` (see step 0b) rather than reading the item itself.

**Two Braze destinations — pick one before assembling:**

| Destination | Output | Shell | Then |
|---|---|---|---|
| **Localization pipeline** (preferred) | **ZIP**: one root `.html` + `Images/` | `knowledge/email-love-shell.md` | hand to `email-localization-upload`, which uploads it and runs EN-US; the pipeline slices the HTML into content blocks, hosts images on Cloudinary, and builds the Braze template |
| Hand-paste into Braze (legacy) | raw HTML | `knowledge/email-shell.md` | user pastes it themselves |

Prefer the pipeline path. It removes the two failure modes that bit us hardest: images stop
depending on expiring Figma URLs (Cloudinary hosts them), and the Braze template is built by
the same tooling every other Lifecycle email goes through instead of by hand.

## When to Use

- Given a Figma file/frame URL for a Lifecycle Marketing email, asked to turn it into HTML
- Given a monday.com campaign item and asked to build/send its email
- "Build/convert/code this Figma design into an email"
- "Turn this Figma into something I can paste into Braze" or "...into HubSpot"
- Given a already-assembled HTML and asked to adapt/fix it for Braze or HubSpot

## Workflow

### 0. Ask which platform this campaign is going to — every time

**Always** ask the user whether this campaign is going to **Braze** or **HubSpot** before
doing anything else, even if the request looks unambiguous. Never guess from the campaign
type or monday board alone — Braze and HubSpot need different substitutions (step 3), and
applying the wrong platform's tags produces broken output (a `personalization_token(...)`
call means nothing in Braze; a raw `{{${first_name}...}}` tag means nothing in HubSpot).

- Ask neutrally — **never mark either platform as a default or "recommended" option**.
  The person requesting the campaign already knows which platform it's going to (it's
  determined by the campaign type they're building, e.g. Invitation/Feedback/Newsletter
  vs. Confirmation/Reminder/Follow-up), so present Braze and HubSpot as two equal choices,
  not a chosen default with an alternative.
- If the user already stated the platform in the same message (e.g. "give me the HubSpot
  HTML for this item"), that counts as confirmation — no need to ask again.
- Carry the answer through to step 3: it determines which tag file applies.

### 0b. Resolve the Figma URL (if starting from a monday item)

If given a monday.com item instead of a Figma URL directly, run the `monday-reader` skill
first to resolve `{figma_url, cta_link}` from that item. Carry the `cta_link` through to
step 3's CTA cross-check below. If given a Figma URL directly (no monday item), skip this
step — there's no CTA link to cross-check against, so step 3's CTA check is skipped too.

If `monday-reader` instead returns `{is_generic_template: true, content, cta_link}` (no
`figma_url` — the item's Design column says "Generic email template"), skip step 1
entirely and assemble directly from `knowledge/generic-email-template.md` using `content`
as the copy and `cta_link` for the button, then go straight to step 3's checks.

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
- Assemble inside **`knowledge/email-love-shell.md`** — the structure the localization
  pipeline expects, with the `b bBg` / `r mj-w` / `mj-b` / `text` class scaffolding and the
  verbatim head from `references/email-love-head.html`. Put each section in its own
  `r mj-w` wrapper, in the same reading order as the Figma frame. Swap in only content
  (text/href/image src) — reuse `knowledge/design-tokens.md` values for anything not
  directly given by the Figma design. Never invent a new button shape, font, color, or
  spacing.

### 2b. Download the images and re-path them

The pipeline hosts images itself (Cloudinary), but only for files that are actually inside
the ZIP. A Figma asset URL left in the HTML expires in ~7 days and would bake a broken image
into a live Braze template.

- Call `download_assets` on the Figma node to get the real image bytes (`rawImages` for
  photos/screenshots, `svgAssets` for icons/logos, `export` for a whole-node render).
- Save each into an `Images/` folder (capital I), named descriptively
  (`<email-name>_Image_<n>.<ext>`) using the `format` field for the correct extension.
- Rewrite every `src` in the HTML to the relative form `Images/<filename>` — no absolute
  URLs, no `./` prefix, no leftover `figma.com/api/mcp/asset/…`.

### 3. Verify & fix — loop until clean

Check all of the following; on any failure, fix it and re-check from the top. Cap at a
few passes — if something still fails after that, stop and surface the remaining issue to
the user instead of looping forever.

- **HTML well-formedness**: every tag closed, valid nested `<table>` structure (this is
  email HTML — tables and inline styles, not divs/flexbox/grid).
- **Dark mode via the real scaffolding — never a hand-written rule**: use
  `knowledge/email-love-shell.md`'s structure (`b bBg` on the body wrapper, `r mj-w` on each
  section, `mj-b` on button wrappers, `text` on text nodes) and copy the dark-mode CSS from
  `references/email-love-head.html` verbatim. Those rules are *scoped* (`.mj-w .text`,
  `.mj-b>table>tbody>tr>td>a`), which is what makes them safe. **Never write your own
  unscoped rule like `.text { color:#fff }`** — a real Braze test send proved Braze's CSS
  inliner flattens a simple selector like that onto every element regardless of the media
  query, giving white-on-white text and an invisible button in normal light-mode viewing.
  Scoped rules can't be mis-flattened that way: with no `.mj-w` ancestor they simply never
  match. Either reproduce the scaffolding faithfully or omit the dark-mode block entirely —
  the one thing that breaks sends is inventing a selector in between.
- **Button spec fidelity**: the primary CTA must match `buttons.md`'s documented values
  EXACTLY — `font-size:16px`, `font-weight:400`, `padding:12px 24px`. A real test caught an
  unflagged drift to 18px/weight 600/padding 15px 40px ("make it stand out more" is not a
  reason to deviate). More generally: this library never uses `font-weight:700` (true
  bold) anywhere — only 400 (regular) or 600 (semibold), per `design-tokens.md`.
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
  Separately: a literal `&` inside any **attribute value** (`href`, `src`, `alt`) is
  invalid HTML regardless of whether it's followed by punctuation — every tracked link in
  this pipeline has multiple `&` between query params (`?utm_medium=email&utm_source=...`).
  Escape those as `&amp;` too; don't assume "most clients tolerate it" is good enough after
  what CSS inlining already did to the dark-mode rule.
- **Platform-specific substitutions**: apply the file matching the platform confirmed in
  step 0 — never both, never guess.

  **If Braze** (`knowledge/braze-liquid-tags.md`):
  - **First name**: apply §1.
  - **`monday.com`**: apply the tracked-anchor substitution in §2 to **every** plain
    "monday.com" mention, picking the color variant that matches the background noted in
    step 1. No exceptions for mentions that read as plain prose (e.g. a venue name like
    "monday.com's NYC Office") — email clients auto-linkify bare domain-looking text into
    an ugly default blue underlined link regardless of whether Figma had it set up as a
    link, so leaving it bare is a rendering bug, not a neutral choice. Scan every
    occurrence in the assembled HTML, not just ones that look like CTAs.
  - **Magic link**: apply the content-block substitution in §3 for any sign-in/deep-link
    CTA.
  - **Footer**: apply the content-block substitution in §4 — inserted right before
    `</body>`, no inlined footer markup.

  **Braze, ZIP/localization-pipeline path only** — when the output is a ZIP for
  `email-localization-upload` rather than HTML to paste into Braze by hand, two of the above
  behave differently, verified against a real Email Love export:
  - **Liquid tags come from Figma, not from you.** The designer authors
    `{{${first_name} | default: 'there'}}` as literal text in the design, so it rides through
    the export. Carry through whatever Figma has rather than injecting it. Do still *complete*
    an incomplete tag (Figma sometimes has a bare `{{${first_name}}}` with no default) per §1,
    and say that you did.
  - **The footer is an open question — do not silently assume.** A real Email Love export
    contains no footer block at all, so something downstream (the Braze master template, or
    the canvas) must supply it. Whether the EN Thin Flow injects
    `{{content_blocks.${fotter_with_monday_logo}}}` is **not documented and not yet
    verified**. This is CAN-SPAM compliance content, not styling — so if the Figma design has
    no footer, flag it to the user and ask before shipping, rather than adding it (risking a
    duplicate footer) or omitting it (risking a non-compliant send).

  **If HubSpot** (`knowledge/hubspot-tags.md`):
  - **First name**: apply §1, but only if a literal greeting name actually appears in the
    copy — don't add it otherwise.
  - **`monday.com`**: apply the styled-`<span>` substitution in §2 (not an anchor — HubSpot's
    convention doesn't link out), but only if "monday.com" actually appears in the copy —
    don't add it otherwise.
  - **Preview text**: apply §3 unconditionally, regardless of whether the copy contains a
    name or a "monday.com" mention — every HubSpot email gets this block, inserted right
    after the first `</table></td>` near the top of the HTML.
  - **Footer**: per §4, every HubSpot email keeps the HubSpot footer from the Figma
    design — check the full Figma file for it even if the frame you extracted from was
    cropped to just the body content, and flag it to the user rather than dropping it
    silently if the Figma design truly has no footer frame.
- **Visual sanity check**: compare the assembled HTML against the Figma screenshot from
  step 1 — same content, same order, same approximate layout.
- **CTA link cross-check** (only when step 0b supplied a `cta_link` from `monday-reader`):
  the primary CTA button's `href` in the assembled HTML must equal that `cta_link`
  exactly. If it doesn't, fix the HTML's href (never the monday item's value) and recheck.
  State the match explicitly in the handoff — don't just assume it.

### 4. Package the ZIP (when the destination is the localization pipeline)

If the output is going to `email-localization-upload` rather than being pasted into Braze by
hand, package it in the exact layout a real Email Love export uses (see
`knowledge/email-love-shell.md` → "ZIP layout"):

```
<campaign-name>.zip
├── <campaign-name>.html      ← single .html at ZIP root; NOT necessarily "index.html"
└── Images/                    ← capital I, only if the HTML references images
```

Before handing off, verify: exactly one root-level `.html`; every `src="Images/…"` resolves
to a file that exists; no `figma.com/api/mcp/asset/…` URLs survive anywhere; nothing in
`Images/` is unreferenced.

Present the final result to the user before calling it done — the assembled HTML for review,
and the ZIP path if you built one. Phase 1 is manual: always show the result, don't ship it
silently. Uploading to the board is `email-localization-upload`'s job, not this skill's.

## DOs

- ✅ Reuse exact values from `knowledge/design-tokens.md` — if a value isn't documented,
  ask or use the closest documented one and say so.
- ✅ Reuse the real product logos/icons in `references/asset-index.md` — genuine brand
  assets, not placeholders.
- ✅ On Braze, apply all four `knowledge/braze-liquid-tags.md` substitutions every time,
  even if the Figma design doesn't obviously call for one (e.g. add the footer content
  block even if Figma has no footer frame).
- ✅ On HubSpot, always add the `knowledge/hubspot-tags.md` §3 preview-text block, and add
  §1/§2 only when a first name / "monday.com" actually appears in the copy.
- ✅ Pick component variants by what the content needs, not the first snippet in the file.

## DON'Ts

- ❌ Don't skip asking which platform (Braze or HubSpot) this campaign targets — even when
  the request seems obvious from context.
- ❌ Don't mix platform substitutions — never apply a Braze tag to HubSpot HTML or vice
  versa.
- ❌ Don't invent a new button shape, font, color, or spacing "in the spirit of" the brand.
- ❌ Don't inline a footer block — always use the `{{content_blocks.${fotter_with_monday_logo}}}`
  reference instead (Braze only — HubSpot has no equivalent footer substitution here).
- ❌ Don't hand-write a URL for a magic-link CTA — always use the content-block reference
  (Braze only).
- ❌ Don't leave a bare `monday.com` mention un-tracked, on either platform.
- ❌ Don't upload the result to Braze or HubSpot — that's a separate, later step in this
  agent, out of scope here.
- ❌ Don't silently skip the CTA cross-check when a `cta_link` was supplied — a mismatch
  means the HTML is wrong, not the monday item.
- ❌ Don't hand-write a dark-mode rule. Either reproduce `email-love-shell.md`'s scaffolding
  and copy the scoped CSS verbatim from `references/email-love-head.html`, or leave dark mode
  out. An invented unscoped selector (`.text { color:#fff }`) is what broke a real send.
- ❌ Don't ship a ZIP whose HTML still references `figma.com/api/mcp/asset/…` — those URLs
  expire in about a week and would leave a live Braze template with broken images.
- ❌ Don't resize, rebold, or repad the primary button "to make it pop" — match
  `buttons.md`'s documented values exactly. Never use `font-weight:700` anywhere.

## Common Mistakes

Found via real end-to-end runs against live monday items, not hypothetically — each one
looked fine until viewed in the actual failure condition.

| Mistake | What it looks like | Fix |
|---|---|---|
| Writing your own **unscoped** dark-mode rule (`.text { color:#fff }`) with `class="text"` hooks but none of the surrounding MJML structure | Confirmed via a real Braze test send: white-on-white text and a shapeless button in NORMAL (light) rendering, every send — Braze's CSS inliner flattens a simple one-class selector onto every match, ignoring the media-query boundary. Later root-caused against a real Email Love export: the genuine rules are *scoped* (`.mj-w .text`, `.mj-b>table>…>a`), so they can't be flattened that way — and without an `.mj-w` ancestor they never match at all | Reproduce `email-love-shell.md`'s `b bBg`/`r mj-w`/`mj-b`/`text` scaffolding and copy the CSS verbatim from `references/email-love-head.html`, or omit dark mode entirely. Never invent a selector in between |
| Assuming the Figma export's HTML file is `index.html` | `how-to-email.md` documents `index.html`, but a real Email Love export is named after the email (`Email 2_7_6_2026_.html`) — a check hard-coded to `index.html` would reject every genuine export | Accept any single root-level `.html` file |
| Sizing/bolding/repadding the primary button beyond `buttons.md`'s documented spec | An assembled email used 18px/weight 600/padding 15px 40px instead of the approved 16px/weight 400/padding 12px 24px — an unflagged, unintentional drift | Match the documented button spec exactly; never use `font-weight:700` anywhere in this library |
| Leaving raw Unicode punctuation (`·`, `–`, `—`, `→`) in copy or `alt` text | Mojibake garbage (e.g. `·` renders as `¬∑`) once pasted into an editor that doesn't honor UTF-8 | Use HTML entities instead: `&middot;`, `&ndash;`, `&mdash;`, `&rarr;` |
| Deciding a "monday.com" mention doesn't need wrapping because it reads as plain prose (e.g. a venue name) rather than a designed link | Email client auto-linkifies it into a default blue underlined link, regardless of Figma's intent | Wrap **every** plain-text "monday.com" mention, no exceptions — see `braze-liquid-tags.md` §2 |
| Leaving a literal `&` between query params inside `href`/`src` values (every tracked link has several) | Invalid HTML — usually silently tolerated, but not guaranteed, especially after CSS inlining already showed this pipeline can't be trusted to degrade gracefully | Escape every attribute-value `&` as `&amp;`, not just visible text |

## Related

- [monday-reader](../monday-reader/SKILL.md) — resolves the Figma URL + CTA link from a monday item, feeds this skill
- [email-localization-upload](../email-localization-upload/SKILL.md) — takes this skill's ZIP, uploads it to the localization board, runs EN-US
- [Generic email template](knowledge/generic-email-template.md) — for requests with no Figma design at all
- [Design tokens](knowledge/design-tokens.md) — typography, colors, spacing, button variants
- [Email Love shell](knowledge/email-love-shell.md) — pipeline/ZIP path (preferred) · [verbatim head](references/email-love-head.html)
- [Email shell](knowledge/email-shell.md) — legacy hand-paste path · [Component snippets](knowledge/components/)
- [Braze liquid tags](knowledge/braze-liquid-tags.md) — the four required Braze substitutions
- [HubSpot tags](knowledge/hubspot-tags.md) — the three required HubSpot substitutions
- [Asset index](references/asset-index.md) — real logo/icon assets and where they live
