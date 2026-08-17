---
name: hubspot-email-templates
description: >
  IN PROGRESS — not yet ready for the full upload/create workflow. Currently
  only covers one-time credential setup and a connectivity test for a
  HubSpot Private App access token. Use when asked to connect HubSpot, test
  a HubSpot Personal Access Key/token, or set up this skill for the first
  time. Do not use yet for actually creating/uploading a HubSpot marketing
  email — that part hasn't been built or scoped out.
metadata:
  status: draft
  owner: osherma@monday.com
---

# HubSpot Email Templates (in progress)

**Domain:** Marketing / Lifecycle / HubSpot
**Status:** credential setup + connectivity test only. The actual "upload/create a
marketing email" workflow (the HubSpot equivalent of `braze-email-templates`'
Workflow A/B) has not been built yet — it needs the HubSpot Marketing Email API
scoped out first (which endpoint, what payload shape, what the Personal Access Key's
granted scopes actually allow) before writing those scripts.

This skill mirrors `braze-email-templates`' architecture on purpose: same credential
model, same "never embed, never share, one setup per person per machine" guarantee.

## Setup this depends on

- `~/.hubspot_secrets` — `export HUBSPOT_ACCESS_TOKEN="..."` (chmod 600). Never
  `cat`/`echo`/print this file's contents in any output; scripts `source` it
  internally so the token is used but never displayed.
- A HubSpot **Private App access token** (what HubSpot calls this used to be called
  a "Personal Access Key" — same thing, current HubSpot UI calls it a Private App
  token). Created per-account under Settings → Integrations → Private Apps.

## Critical: this key is personal, never shared

**No one else's setup should ever use another person's HubSpot token.** Exactly the
same rule as `braze-email-templates`, explicitly re-confirmed for this skill
(2026-08-17):
- The token is never embedded anywhere in this skill's files.
- It lives only in `~/.hubspot_secrets`, created locally by each person running
  `setup_credentials.sh` themselves, with their own token.
- Nothing in this skill syncs or shares that file between people or machines.
- An assistant/agent helping with this skill must never ask the user to paste their
  token into a chat interface — only into the script's own hidden terminal prompt, in
  a real terminal (not any AI/chat panel). A real incident with the equivalent Braze
  setup (2026-08-16) is exactly the failure mode to avoid: a key typed into a chat
  panel gets logged in plain text and must be rotated.

### First-time setup on a new machine/account

1. Get a HubSpot Private App access token from Settings → Integrations → Private
   Apps in your own HubSpot account (or create a new Private App and grant it the
   scopes needed once the actual email-creation workflow is scoped out).
2. Run the setup script yourself, in a real terminal, and paste the token when
   prompted (input is hidden, never printed or logged):
   ```bash
   ./scripts/setup_credentials.sh
   ```
3. Verify the connection:
   ```bash
   ./scripts/test_connection.sh
   ```
   This calls HubSpot's access-token introspection endpoint
   (`GET /oauth/v1/access-tokens/{token}`), which works for both Private App tokens
   and OAuth tokens and needs no specific scope beyond being a valid token. On
   success it prints the Hub ID, hub domain, App ID, and the token's granted scopes
   — useful for confirming this is the right HubSpot account and checking what
   scopes are actually available before building the upload workflow against them.
   It never prints the token itself.

## What's not built yet

- Uploading images to HubSpot's File Manager (the equivalent of
  `upload_asset.sh` → Braze's media library).
- Creating a marketing email from local HTML (the equivalent of
  `create_template.sh`) — needs the Marketing Email API's actual payload shape
  scoped out (content groups, email type, etc.), which differs meaningfully from
  Braze's simpler `templates/email/create`.
- Editing an existing HubSpot marketing email's copy (the equivalent of
  `update_template.sh` + `copy-edit-gotchas.md`) — HubSpot's own equivalent of the
  bulletproof-button duplication pattern hasn't been checked yet.
- A verify-after-write step (the equivalent of `verify_template.sh`).

Do not attempt to build these by guessing HubSpot's API shape — check the granted
scopes via `test_connection.sh` first, then confirm the correct endpoint/payload
against HubSpot's own API reference before writing any script that writes data.

## Related

- [braze-email-templates](../braze-email-templates/SKILL.md) — the Braze equivalent
  this skill's architecture mirrors
- [figma-to-html](../figma-to-html/SKILL.md) — HubSpot substitution rules
  (`knowledge/hubspot-tags.md`) already exist there for the hand-paste path; this
  skill is about automating the upload once HTML is assembled, not about the
  HubSpot-specific liquid/token substitutions themselves
