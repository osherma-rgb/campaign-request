# HubSpot substitutions — required for every HubSpot Figma → HTML conversion

These are the current, correct HubSpot conventions for this pipeline (confirmed
2026-08-11). They are **not** interchangeable with `braze-liquid-tags.md` — HubSpot uses
different personalization syntax and a different `monday.com` markup, and has one
substitution (preview text) that Braze doesn't need at all. Always confirm the target
platform before applying either file's substitutions (see SKILL.md step 0).

## 1. First name personalization — only if a name appears

Only applies if the Figma copy has a literal greeting name (e.g. "Hi Yaniv", "Hey there").
If present, replace it with:

```
{{ personalization_token('contact.firstname', 'there') }}
```

If no first name appears anywhere in the copy, don't add this — unlike the other two
substitutions below, this one is conditional on the text actually containing a name.

## 2. `monday.com` mentions → styled span — only if it appears

Only applies if the literal text "monday.com" appears in the copy. If present, wrap
**every** plain mention in the span below — no exceptions for mentions that read as plain
prose. Unlike the Braze convention, this is a `<span>`, not an `<a>` — HubSpot's version
does not link out, it only prevents the client's auto-linkify behavior and controls the
visual break between "monday" and ".com":

```html
<span style="text-decoration: none; color: var(--color-pecan); cursor: auto; white-space:nowrap">monday&#8203;.com</span>
```

If "monday.com" doesn't appear in the copy, don't add this.

## 3. Preview text — always add, regardless of content

Unlike the two substitutions above, this one is unconditional — add it to every HubSpot
email regardless of what the Figma copy contains. Insert immediately after the first
`</table></td>` near the top of the assembled HTML (typically within the first
100–150 lines, right after the outer wrapper table's first cell closes):

```html
<div id="preview_text" style="display:none;font-size:1px;color:{{background_color}};line-height:1px;max-height:0px;max-width:0px;opacity:0;overflow:hidden;">{% text "preview_text" label="Preview Text", value="", no_wrapper=True %}</div>
```

## 4. HubSpot footer — always keep it, regardless of the Figma frame's crop

Every HubSpot email needs the HubSpot footer. Unlike the other three substitutions,
there's no content-block token to insert — the footer is part of the Figma design itself
(confirmed via the reminder example:
`https://monday.monday.com/boards/112753365/pulses/12578982117`). The failure mode is
dropping it, not needing to add it: when the Figma frame you're extracting from is
cropped to just the hero/body content, don't stop there — check the full Figma
file/frame for a footer section and carry it into the assembled HTML exactly as designed.
If a given monday item's Figma link truly has no footer frame at all, flag that to the
user rather than silently shipping without one — don't assume it's optional.

## Also always cross-check the CTA link

This applies on HubSpot the same as it does on Braze (see SKILL.md's CTA link
cross-check in step 3): the primary CTA's `href` in the assembled HTML must match the
`cta_link` resolved from the monday item exactly, not just visually resemble the Figma
button. A mismatch means the HTML is wrong — fix the HTML, never the monday item's value.
