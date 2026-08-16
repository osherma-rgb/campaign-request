# Editing copy in an already-uploaded template

The most common ask here is "change this CTA button's text" or "update the headline
copy" on a template that's already live in Braze. The mechanics are simple (find the
text, replace it, push, verify) but one rendering pattern makes a naive find-and-replace
unsafe if you don't account for it first.

## The bulletproof-button duplication

MJML/EmailLove renders buttons using the "bulletproof button" pattern for Outlook
compatibility: an Outlook-only VML fallback (wrapped in `<!--[if mso]>...<![endif]-->`
conditional comments, using a `<v:roundrect>` element) sits right next to the real
`<a>` tag that every other email client renders. Both copies carry the same visible
text, usually in a `<span class="text-btn-XXXXX">` with a matching class-name suffix
shared between the two copies of one button.

Practical effect: a CTA's visible text will typically appear **twice** in the raw HTML
per button instance — once in the VML fallback, once in the live anchor. If a page has
2 visually distinct CTA buttons with the same label ("Register for free" appearing on
both), that's 4 raw occurrences of the string, not 2.

**Before doing a bulk replace, look at the surrounding context of every match, not just
the occurrence count.** Grep for the target string, then read a bit of HTML around each
hit to see whether it's a VML-fallback span, a live-anchor span, or something else
entirely that just happens to contain the same words (e.g. plain body copy that
mentions the same phrase). Grouping the matches by the shared `text-btn-XXXXX` class
suffix will show you whether you're looking at N buttons × 2 copies each, and confirms
you're not about to touch some unrelated sentence that coincidentally matches.

Once you know the true multiplier, do a straightforward string replace on the full
matched text (`>Register for free<` → `>Osher is the best<`, for instance) so the
VML fallback and the live version change together — a client that falls back to VML
should show the same words as one that renders the `<a>` directly.

## Workflow

1. Get the current body — either the last-known-good local copy from this session, or
   fetch fresh via `templates/email/info?email_template_id=...` (extract the `body`
   field to a file).
2. Grep for the target text, inspect context around every hit (see above), confirm the
   exact occurrence count you expect before replacing.
3. Do the replace on the local file.
4. Push with `scripts/update_template.sh <html_file> <email_template_id>`.
5. Verify with `scripts/verify_template.sh <email_template_id> <html_file>` — same
   fetch-back-and-diff check as a fresh upload. A copy edit is just as easy to get
   subtly wrong (missed one of the duplicated spans, matched an unrelated sentence) as
   a full upload, so it gets the same verification, not a lighter-touch skip.
