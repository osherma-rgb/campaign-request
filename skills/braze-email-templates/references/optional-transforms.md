# Optional transforms — ask every time, never apply by default

There are four standing optional transforms sometimes wanted on a zip export before it
goes into Braze. None of them are implied by "upload this as a template" — a given
export might be for a different brand surface, a different link destination, or already
final, so ask about each one (via `AskUserQuestion`, multiple choice) every time rather
than assuming last time's answer still applies, and regardless of who's running this
skill.

## 1. Wrap "monday.com" mentions in the tracked UTM link

Use `scripts/wrap_monday_link.py <input.html> <output.html>` — don't hand-roll this
with a regex-replace-all over the raw markup. A blind replace would happily rewrite
text sitting inside an existing `<a>` tag (nesting a link inside a link), an `alt`
attribute, or a `<style>` block, all of which read as "monday.com" as plain text to a
regex but aren't safe to touch. The script walks actual text nodes via `HTMLParser` and
skips anything inside `<a>`, `<script>`, `<style>`, or `<title>`.

Target link (exact, including the `style` attribute — this is the confirmed-working
version for monday.com sends):
```html
<a href="https://monday.com/?utm_medium=email&utm_source=braze&utm_campaign=multi-en-other-multi-n/a-email" style="text-decoration: none; color:#000000; cursor: auto; white-space:nowrap">monday.com</a>
```

Original casing is preserved inside the link text (`Monday.com` stays `Monday.com`),
only the wrapping is added. After running the script, diff the output against the
pre-transform file and confirm only the reported number of "monday.com" occurrences
changed — nothing else should move.

## 2. Insert the footer content-block reference

Exact literal string (Braze Liquid syntax referencing a content block by name — do
not "fix" the block name even if `fotter` looks like a typo for `footer`; it has to
match the actual content block name configured in Braze):
```
{{content_blocks.${fotter_with_monday_logo}}}
```

Placement: its own line, between `</body>` and `</html>`:
```html
  </body>
{{content_blocks.${fotter_with_monday_logo}}}
</html>
```

Before inserting, confirm `</html>` appears exactly once in the document (a full HTML
document only ever has one). It's a plain string insertion, not something that needs a
parser — just confirm the count first and diff after to confirm only that one insertion
landed.

## 3. Outer page background → `#f3f4f5`

This is about the "generic background" — the area visible around the email card, not
any white content-card section inside it. A standard EmailLove/MJML export touches
exactly 3 spots for this:

1. `<body style="word-spacing:normal;background-color:#ffffff;">` → `background-color:#f3f4f5;`
2. The outer wrapper, typically `<div aria-roledescription="email" class="b bBg" style="...background-color: #ffffff;" role="article" ...>` → `background-color: #f3f4f5;`
3. The dark-mode override inside the `<style>` block, typically `.b{background-color:#ffffff !important;}` → `.b{background-color:#f3f4f5 !important;}`

**Before touching spot 3, read its current value — don't assume it matches spot 1/2.**
The point of spot 3 is to keep the outer area visually consistent when a client
switches to dark mode. That only holds if the export's dark-mode override currently
matches light mode (`#ffffff`) — in that case all three flip together safely.

But some exports (confirmed on the `webinar 2 test` template, 2026-08-16) already ship
a genuinely different, non-white value for spot 3 — e.g. `.b{background-color:#1f1f1
!important;}` (note: also a malformed 5-hex-digit color, an export quirk on top of
being intentionally dark). A non-white spot 3 means the email's design already commits
to a dark outer background in dark mode on purpose. Overwriting it to `#f3f4f5` would
force a light gray background into what was meant to look dark — that's a real design
change, not a mechanical sync, so **stop and ask the user** how to handle it:
- light-mode only (leave the dark-mode override as-is)
- force light everywhere (flip it to `#f3f4f5` anyway)
- skip the background change entirely

Never touch the many other legitimate white content-card backgrounds elsewhere in the
document — this transform is scoped to exactly these 3 spots. Confirm each target
string occurs exactly once before replacing it (a plain string count, not a regex/sed
sweep on `#ffffff`, since that string legitimately appears dozens of times for the
white content cards). Diff after to confirm only these lines changed.

**Established default for the HR1/HR2/HR3 email series** (confirmed by Yaniv,
2026-08-18): these exports already ship spot 1/spot 2 (body + outer wrapper) as
`#f3f4f5` — the transform's target value — with nothing left to change there, and spot 3
(dark-mode override) already as `#000`. The confirmed standing decision for this exact
pattern (light already `#f3f4f5`, dark already `#000`) is **leave the dark-mode override
as `#000`** — do not overwrite it, and don't re-ask for this series. This does not
relax the stop-and-ask rule above for a genuinely different non-white value (e.g. a
color other than `#000`) or for exports outside this series — those still warrant a
fresh judgment call.

## 4. Insert the magic-link marketing content-block reference

Exact literal string (Braze Liquid syntax referencing a content block by name — do not
"fix" the block name; it has to match the actual content block name configured in
Braze):
```
{{content_blocks.${magic_link_marketing_braze_api}}}
```

Placement: its own line, at the very top of the file, immediately before the opening
`<html>` tag (after `<!doctype html>` if present):
```html
<!doctype html>
{{content_blocks.${magic_link_marketing_braze_api}}}
<html lang="und" ...>
```

Before inserting, confirm `<html` appears exactly once in the document. Plain string
insertion right before that first occurrence — no parser needed — and diff after to
confirm only that one insertion landed.

Added 2026-08-18 at Yaniv's request (HR3), alongside the transform-3 dark-mode default
above.
