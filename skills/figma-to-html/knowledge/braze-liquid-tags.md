# Braze liquid-tag substitutions — required for every Figma → HTML conversion

These are the current, correct Braze conventions for this pipeline (confirmed 2026-08-09).
They differ from the older inlined-footer convention used by marketing-cookbook's
`email-design` skill — that convention is **not** used here. Apply all four below in the
verify/fix loop, every time, regardless of what the Figma design literally contains.

## 1. First name personalization

Any literal greeting name pulled from the Figma copy (e.g. "Hi Yaniv", "Hey there Osher")
must be replaced with the dynamic tag, defaulting to "there" when Braze has no name on
file:

```
{{${first_name} | default: 'there'}}
```

## 2. `monday.com` mentions → tracked anchor

**Every** plain "monday.com" mention found in the Figma design must be wrapped in the
tracked anchor below — no exceptions for mentions that read as plain prose (e.g. "...at
monday.com's NYC Office"), and regardless of whether Figma itself had that text set up as
a link. This is not just a tracking nicety: most email clients auto-linkify bare text that
looks like a domain, and without explicit styling that renders as a default blue,
underlined link — visually broken against the surrounding copy. Wrapping it yourself is
the only way to control how it looks. Never leave `monday.com` as bare, untracked text.

Pick the color variant that matches the surrounding text color in that section of the
design — black text on a light/white background, white text on a dark/colored section
fill.

**On the `email-love-shell.md` / ZIP pipeline path, add `class="link"` to the anchor.**
Confirmed via a real Braze test send (2026-08-12): the shell's dark-mode block already
ships a scoped rule for exactly this, `.mj-w .link,.mj-w .link>div { color:#ffffff
!important }` (see `references/email-love-head.html`), but it only fires if the anchor
carries `class="link"`. Without it, the anchor's own inline `color:#000000` sets the
`<a>` element's color directly — the container's `.mj-w .text` dark-mode rule flips the
surrounding text white, but doesn't reach a descendant that already has its own explicit
color — so the link renders as barely-visible black-on-#1f1f1f in dark mode while the rest
of the paragraph goes white. This is not the same failure mode as the shell's warning
against *inventing* an unscoped rule (see `email-love-shell.md`) — `.link` is real,
pre-existing, scoped scaffolding; using it is required, not optional.
On the legacy hand-paste path (`email-shell.md`, no dark-mode CSS at all), there is no
`.link` class to hook — leave the anchor as-is there.

**On a light background (black text):**
```html
<a href="https://monday.com/?utm_medium=email&amp;utm_source=braze&amp;utm_campaign=multi-en-other-multi-n/a-email" style="text-decoration: none; color:#000000; cursor: auto; white-space:nowrap">monday.com</a>
```

**On a dark background (white text):**
```html
<a href="https://monday.com/?utm_medium=email&amp;utm_source=braze&amp;utm_campaign=multi-en-other-multi-n/a-email" style="text-decoration: none; color:#FFFFFF; cursor: auto; white-space:nowrap">monday.com</a>
```

Note the `&amp;` between query params — a literal `&` inside an HTML attribute value is technically invalid HTML, and per this session's character-encoding rule (`figma-to-html/SKILL.md`), every attribute value gets the same entity treatment as visible text.

## 3. Magic link CTA

Any sign-in / deep-link CTA identified from the Figma design (a "magic link" that logs the
recipient straight into their account) must use the Braze content block reference instead
of a literal href:

```
{{content_blocks.${magic_link_marketing_braze_api}}}
```

Use this as the `href` value (or the whole CTA element's link target) — do not hand-write
a URL for a magic link.

## 4. Footer

**Legacy hand-paste path (`email-shell.md`) only.** Do not inline footer markup. Instead,
insert the footer content-block reference immediately before the closing `</body>` tag,
verbatim (this is a real Braze content-block key, not a typo — do not "fix" the spelling):

```
{{content_blocks.${fotter_with_monday_logo}}}
```

**Never add this on the `email-love-shell.md` / ZIP / localization-pipeline path.**
Confirmed via a real Braze test send (2026-08-12, monday item 12782188111): the Email
Localization Uploads board's own automation already appends the footer content block to
every template it builds. Adding the reference yourself doubles it — the rendered email
showed two footers stacked back to back. On that path the export simply ends at the last
design section; see `email-love-shell.md` → "What the export does NOT contain."
