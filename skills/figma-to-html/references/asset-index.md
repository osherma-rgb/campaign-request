<!-- Snapshot copied from marketing-cookbook domains/lifecycle-marketing/skills/email-design on 2026-08-09. Re-sync from there if that library changes. -->

# Real asset index — logos and icons

These are genuine monday.com brand assets from the approved component library
(2026-07-28), not placeholders. **Binary files can't live in this repo** (CI forbids
images in content folders), so this index catalogs what exists and where to get it:
the team's component-library export ("Email-componants-html.zip" / Header Logos +
Buttons folders), the Braze media library (for hosted URLs — which sent emails need
anyway), or the local skill copy at `~/.claude/skills/lifecycle-email-design/assets/`.

## Logos

Each product lockup exists twice (two crops/variants pulled from the source library) —
open both before picking one, they aren't guaranteed identical.

| File | Product |
|---|---|
| `monday-crm.png` / `monday-crm-2.png` | monday CRM |
| `monday-service.png` / `monday-service-2.png` | monday service |
| `monday-dev.png` / `monday-dev-2.png` | monday dev |
| `monday-workforms.png` / `monday-workforms-2.png` | monday workforms |
| `monday-work-management.png` / `monday-work-management-2.png` | monday work management |
| `monday-sidekick.png` / `monday-sidekick-2.png` | monday sidekick |
| `monday-vibe.png` / `monday-vibe-2.png` | monday vibe |
| `monday-notetaker.png` / `monday-notetaker-2.png` | monday notetaker |
| `monday-workflows.png` / `monday-workflows-2.png` | monday workflows |
| `monday-agents.png` / `monday-agents-2.png` | monday agents |
| `monday-campaigns.png` / `monday-campaigns-2.png` | monday campaigns |
| `monday-partnerships.png` / `monday-partnerships-2.png` | monday partnerships |
| `monday-com.png` / `monday-com-2.png` | monday.com (main brand) |

Use in `components/header-logos.html` — swap the `REPLACE_LOGO.png` src for whichever
product logo matches the touchpoint's subject (e.g. an agents-focused send uses
`monday-agents.png`).

## Icons

| File | Depicts |
|---|---|
| `gmail-icon.png` / `gmail-icon-2.png` | Gmail logo |
| `word-icon.png` | Microsoft Word logo |
| `play-icon.png` | Play/video triangle |
| `edit-icon.png` | Edit/pencil |
| `help-icon.png` | Help/question mark |

Use in `components/buttons.html`'s small icon text-link variant, or inline next to list
items in `components/lists.html` where a specific integration/action needs a recognizable
icon (e.g. "Connect Gmail" pairs with `gmail-icon.png`).

## New images not in this set

If a touchpoint needs an image that isn't one of the logos/icons above (a new product
screenshot, a customer photo, a new icon), this skill can't generate or host it — that
needs to come from wherever your team's actual image assets live (Figma exports, a DAM,
etc.) and then get uploaded to Braze's asset library so it has a stable, publicly
reachable URL. A local file path won't render in a sent email. Ask the user for the
hosted URL, or flag that the image needs to be uploaded before the HTML can go live.
