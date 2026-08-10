---
name: monday-reader
description: >
  Use when given a monday.com campaign item URL/ID for an email and asked to find its
  Figma design link or its CTA link, as the input step before running figma-to-html, or
  when a monday item has no Figma link and you need to tell apart a genuine gap from a
  recognized no-design request type (check the Design column first).
status: draft
owner: osherma@monday.com
---

# Skill: Monday Reader (Phase 1 — input step for figma-to-html)

**Pipeline stage:** monday item → Figma URL + CTA link. This is the input step in the
email-campaign agent (monday item → Figma → HTML → Braze). It hands off two values —
the Figma design URL and the CTA link — to the `figma-to-html` skill; it does not touch
Figma or HTML itself.

## When to Use

- Given a monday.com item link/ID for an email campaign, asked to find its Figma design
- Asked "what's the CTA link for this campaign item"
- As the first step before running `figma-to-html`, whenever the input is a monday item
  rather than a Figma URL directly

## Workflow

1. **MCP to monday.** Extract the board ID and item ID from the given monday URL
   (`https://<account>.monday.com/boards/<boardId>/pulses/<itemId>`). Call `query_items`
   (or `get_board_items_page`) with that item ID and `include_relations: true`, and call
   `get_updates` on the item (`includeReplies: true`) — campaign detail is often posted as
   freeform update text (`Figma link: ...`, `CTA link: ...`) rather than structured columns.

2. **Look for the Figma URL.** Check, in order:
   - A link-type column whose value is a `figma.com` URL (structured data, most reliable).
   - Update text containing a `Figma link:` line.
   If more than one distinct `figma.com` URL turns up across columns/updates, don't guess
   — ask the user which one is current.

   If neither turns up anything, **before concluding there's no design**, check the item's
   **Design** column (on board `112753365` this is column id `single_select_MjigC4Bz`) for
   the exact text **"Generic email template"**. That's a recognized request type with no
   per-item Figma design — hand off `is_generic_template: true` plus the item's own copy
   (from `long_text` or an update's `Content:` line) instead of `figma_url`, per
   `figma-to-html`'s `knowledge/generic-email-template.md`. Only report "no Figma design
   found" if the Design column doesn't say this (or doesn't exist on a different board).

3. **Get the CTA link.** Same approach — a link-type column meant for the campaign's CTA
   (e.g. a "CTA link" or the touchpoint's primary link column), or update text containing
   a `CTA link:` line. This is the source-of-truth link that `figma-to-html`'s primary
   button must match exactly once the HTML is assembled — it is not necessarily the same
   as a `monday.com` tracked link (e.g. it may be an external webinar/event registration
   URL).

4. **Hand off.** Report back the resolved `{item_name, figma_url, cta_link}` — or, for the
   generic-template case, `{item_name, is_generic_template: true, content, cta_link}`. If
   the CTA link can't be found, or no Figma URL exists AND the Design column doesn't say
   "Generic email template", stop and say what's missing rather than guessing or inventing
   one.

## DOs

- ✅ Prefer structured column values over update text when both exist — columns are less
  likely to drift out of date.
- ✅ Treat every board's column IDs as unverified until checked — this skill doesn't
  hardcode column IDs for one specific board (unlike a skill scoped to a single known
  board); different Lifecycle boards use different column setups. Use `get_board_info` if
  you need to confirm a column's type before trusting its value.
- ✅ If the item has a linked/related item (`board_relation` column) that itself carries a
  Figma link or CTA link, treat that as a secondary source when the item alone doesn't have one.

## DON'Ts

- ❌ Don't fabricate a Figma URL or CTA link when neither is present — ask the user.
- ❌ Don't resolve ambiguity (multiple candidate links) by picking one silently.
- ❌ Don't build the HTML here — that's `figma-to-html`'s job, not this skill's.

## Common Mistakes

| Mistake | What it looks like | Fix |
|---|---|---|
| Treating "no Figma URL" as always meaning "no design exists, stop here" | Real example: item `12669890031`, a $50-incentive research-recruitment email — `link32` empty, update text has a blank "Figma link:" line. This actually IS a recognized type (Design column = "Generic email template"), not a genuine gap — an earlier version of this skill wrongly stopped and reported it as missing | Check the Design column for "Generic email template" before concluding there's no design — see step 2 and `generic-email-template.md` |

## Related

- [figma-to-html](../figma-to-html/SKILL.md) — consumes this skill's `{figma_url, cta_link}` output
