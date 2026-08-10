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
fill. Don't add a dark-mode class to either variant — see `email-shell.md` for why this
shell doesn't do CSS-media-query-based dark mode at all.

**On a light background (black text):**
```html
<a href="https://monday.com/?utm_medium=email&utm_source=braze&utm_campaign=multi-en-other-multi-n/a-email" style="text-decoration: none; color:#000000; cursor: auto; white-space:nowrap">monday.com</a>
```

**On a dark background (white text):**
```html
<a href="https://monday.com/?utm_medium=email&utm_source=braze&utm_campaign=multi-en-other-multi-n/a-email" style="text-decoration: none; color:#FFFFFF; cursor: auto; white-space:nowrap">monday.com</a>
```

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

Do not inline footer markup. Instead, insert the footer content-block reference
immediately before the closing `</body>` tag, verbatim (this is a real Braze content-block
key, not a typo — do not "fix" the spelling):

```
{{content_blocks.${fotter_with_monday_logo}}}
```
