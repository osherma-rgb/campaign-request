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

Any plain "monday.com" text or link found in the Figma design must be replaced with the
tracked anchor below. Pick the color variant that matches the surrounding text color in
that section of the design — never leave `monday.com` as bare, un-tracked text.

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
