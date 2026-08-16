---
name: braze-email-templates
description: >
  Uploads an EmailLove/MJML zip export (HTML + Images folder) as a new Braze email
  template, or edits copy (CTA text, headline, any visible text) in an existing Braze
  email template — always via Braze's REST API directly with curl, never through the
  braze MCP server's create_media_library_asset / create_email_template tools. Those
  MCP tools require the image bytes or HTML body to be retyped into a tool-call
  parameter, which silently corrupts binary/large payloads; this skill routes bytes
  straight from disk into the HTTP request instead. Use whenever asked to upload a zip
  as a Braze template, push an email export into Braze, build/create an email template,
  change a CTA or button copy on an existing template, or edit any text in a
  live/uploaded Braze email — even if the user doesn't say "REST API" or mention the
  corruption risk themselves.
metadata:
  status: draft
  owner: yanivdm@monday.com
---

# Braze Email Templates

**Domain:** Marketing / Lifecycle / Braze
**Owner:** Yaniv Dmoch

Two workflows: **A** uploads a new zip export as a Braze template from scratch, **B**
edits copy on a template that's already live. Both end the same way — push via curl,
then fetch the result back and diff it against the local source. The upload path is far
more reliable than retyping bytes through a tool call, but "far more reliable" isn't
"guaranteed," so every write gets verified, not just trusted because it returned 200/201.

## Setup this depends on

- `~/.braze_secrets` — `export BRAZE_API_KEY="..."` (chmod 600). Never `cat`/`echo`/print
  this file's contents in any output; scripts `source` it internally so the key is used
  but never displayed.
- REST endpoint: `https://rest.iad-06.braze.com`
- `app_group_id` for monday.com Prod: `609909f4cde3c93ffa1267cb` (default baked into the
  scripts below). For a different workspace, call the `braze` MCP server's
  `get_workspaces` tool (read-only, fine to use directly) and pass its `id` as the
  second argument to `upload_asset.sh`.
- `scripts/` in this skill directory has everything that touches the network or does
  non-trivial text surgery — use them rather than re-deriving the curl invocations or
  the HTML-parsing logic inline. They're plain bash/python, read them if you want to see
  exactly what they do.

### First-time setup on a new machine/account

If `~/.braze_secrets` doesn't exist yet:
1. Get a Braze REST API key scoped to the monday.com Prod workspace (`app_group_id
   609909f4cde3c93ffa1267cb`) — from Braze's dashboard under Settings → APIs and
   Identifiers, or from whoever administers your team's Braze access. It needs at least
   the `templates.email.create`, `templates.email.update`, `templates.email.info`, and
   `media_library.create` permissions.
2. Run the setup script once and paste the key when prompted (input is hidden, never
   printed or logged):
   ```bash
   ./scripts/setup_credentials.sh
   ```
   This writes `~/.braze_secrets` with the right permissions (`chmod 600`) for you. The
   key is deliberately never embedded anywhere in this skill's own files — it's a live
   credential, and this skill (like any file) can end up shared, forwarded, or committed
   somewhere unintended, so it only ever lives in the local secrets file this script
   creates on your machine.
3. That's it — every other script in this skill reads the key from that file at call
   time. Different people on different machines each run their own setup with their own
   key; nothing in this skill is shared or synced between installs.

## Workflow A — upload a new zip export as a template

1. **Unzip and inspect.** A standard EmailLove/MJML export is one HTML file plus an
   `Images/` folder, with the HTML referencing images by relative path
   (`Images/foo.png`). List what's in `Images/` against what the HTML references —
   confirm a 1:1 mapping and check each image path's occurrence count in the HTML
   (usually exactly 1). If the counts don't line up, stop and look — that usually means
   a duplicated image or an export that isn't the standard shape.

2. **Upload every image**, one call per file:
   ```bash
   ./scripts/upload_asset.sh "Images/foo.png"
   ```
   Pull the CDN url out of each response's `new_assets[0].url`.

3. **Swap image paths for CDN urls** in the HTML — an exact-match string replace per
   image, after confirming the occurrence count, not a blanket regex. Do this in a
   small Python script (or inline) rather than by hand; there are usually 4-10 images
   and hand-editing invites a missed one.

4. **Ask about the three optional transforms** — see
   [references/optional-transforms.md](references/optional-transforms.md) for the full
   detail on each, including the dark-mode judgment call on transform 3 (the outer
   background color). None of these three are ever assumed; ask every time via
   `AskUserQuestion` (or equivalent) with concrete options rather than guessing:
   - wrap "monday.com" mentions in the tracked UTM link
   - insert the `{{content_blocks.${fotter_with_monday_logo}}}` footer reference
   - set the outer page background to `#f3f4f5`

5. **Get the template identity.** Ask whether this is a new template (need a name) or
   an update to an existing one (need its `email_template_id` — if so, skip to Workflow
   B's push/verify steps instead). Braze rejects a blank subject, and these exports
   often ship with an empty `<title>`, so if there's no subject in hand, ask for one
   (offering the template name as a quick default, but let the user override it — the
   template name and the subject line are different things and shouldn't be conflated
   without asking).

   Also ask for the preview/preheader text (the snippet inboxes show next to the
   subject line) — unlike the subject, Braze doesn't require this, so offer "leave it
   blank for now" as one of the options rather than forcing an answer. The EmailLove
   export has no dedicated preview-text field to fall back on, so if the user wants one
   set, it has to come from them.

6. **Create it:**
   ```bash
   ./scripts/create_template.sh final_email.html "template name" "subject line" "preview text"
   ```
   Omit the fourth argument (or pass `""`) to leave the preheader unset. Grab
   `email_template_id` from the response.

7. **Verify:**
   ```bash
   ./scripts/verify_template.sh <email_template_id> final_email.html
   ```
   A non-clean diff means something about the upload went wrong — treat it as a bug to
   investigate (check for encoding issues, a stray character in the payload build), not
   something to shrug off because the create call itself returned success.

## Workflow B — edit copy on an existing template

Same idea, smaller scope: find the target text, confirm you know exactly how many times
it appears and why, replace it, push, verify. The one thing that reliably trips this up
is button text getting duplicated by the Outlook-safe rendering pattern — read
[references/copy-edit-gotchas.md](references/copy-edit-gotchas.md) before doing a bulk
replace on anything that lives inside a button, so the Outlook fallback and the live
version change together instead of drifting apart.

```bash
./scripts/update_template.sh final_email.html <email_template_id>
./scripts/verify_template.sh <email_template_id> final_email.html
```

`update_template.sh` takes an optional third argument (subject) and fourth argument
(preheader) to change those in the same call.

## Common gotchas (apply to both workflows)

- **Braze's media library caps individual images at 5MB.** A 3200×4010 hero image was
  rejected until downscaled to 1021×1280. If `upload_asset.sh` fails on a large image,
  downscale it first (dimensions, not just re-compression) rather than assuming the
  upload call itself is broken.
- Multipart upload field is `asset_file`, not `file` — Braze returns a clear `400` if
  this is wrong, cheap to notice and fix.
- Reads from Braze can lag a write by a few seconds. If a verify diff fails right after
  a write, wait a few moments and re-fetch before assuming the write itself was bad.
- Variation in one file (a non-standard dark-mode background value, an unusual export
  structure) is a signal to stop and look, not to force the standard pattern onto it.
