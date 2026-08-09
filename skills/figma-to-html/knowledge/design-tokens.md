<!-- Snapshot copied from marketing-cookbook domains/lifecycle-marketing/skills/email-design on 2026-08-09. Re-sync from there if that library changes. -->

# Design tokens — extracted from the pre-approved component library

Source: `Email-componants-html.zip` (9 real Braze/MJML-exported component files: Buttons,
Header Logos, Images, texts, Footer | Dividers | spacer, Lists, Single/Two/Three column),
pulled 2026-07-28. These are values *observed in the actual approved components*, not
guesses — if a value you need isn't listed here, don't invent one; ask, or pick the
closest documented value and flag the choice.

## Layout system

- Total email width: **640px**
- Side padding: **40px** each side → **560px** effective content width
- Inset/card elements (rounded images, callout boxes) sit inside the 560px content
  width with their own border-radius, not full-bleed to 640px
- Full-bleed images span the full 640px with no side padding and no radius
- Section vertical padding: 24px top/bottom is the default; 16px is used for tighter
  sections (e.g. between an image and the text below it)
- Divider: full content width (560px), `border-top: solid 1px #CACBCD`
- Spacer heights in use: 8px (tight), 24px (standard section gap)

## Typography — Poppins, Arial fallback, always

Every size below has been used in both a semibold (600) and regular (400) cut. Pick
weight based on emphasis needed, not automatically defaulting to one.

| Role | Size | Weight | Line-height | Letter-spacing | Align |
|---|---|---|---|---|---|
| Hero / display title | 56px | 600 or 400 | 110% | -1px (600) / -0.01em (400) | center |
| H1 | 48px | 600 or 400 | 130% | -1px (600) / -0.01em (400) | center |
| H2 | 40px | 600 or 400 | 130% | -1px (600) / -0.01em (400) | center |
| H3 | 32px | 600 or 400 | 130% | 0px | center |
| H4 / stat callout | 24px | 600 or 400 | 130% | 0px | center |
| Small eyebrow heading | 24px | 600 | 130% | 0px | center |
| Lead / emphasis body | 16px | 600 or 400 | 140% | 0px | center |
| Body paragraph | 15px | 400 | 140% | 0px | left |
| Small body / caption | 14px | 400 | 150% | 0px | center or left |
| Micro (inside callout cards) | 12px | 400 | 150% | 0px | left |

Color is `#000000` for all text by default. There is a dark-mode override in the shell
CSS that flips text to `#ffffff` and backgrounds to `#1f1f1f` automatically — don't
hand-author a separate dark variant, the shell already handles it.

## Color palette

| Token | Hex | Use |
|---|---|---|
| Ink (primary text/bg) | `#000000` | Body text, primary CTA background, primary CTA text-on-black |
| White | `#FFFFFF` | Page background, text on black/purple |
| Secondary button fill | `#F6F1EE` | Rectangular secondary buttons (icon + text, e.g. "Video tutorials >") |
| Callout card fill | `#F7F3EA` | Highlight/callout box background |
| Callout card border | `#F2E7D6` | 1px border on callout boxes |
| Brand accent | `#6161FF` | Outline/underline CTA text+border, inline emphasis in list/body text, links |
| Secondary text-link | `#45454A` | Small icon+text link buttons (no fill) |
| Divider | `#CACBCD` | Horizontal rule |
| Footer background | `#f3f4f5` | Footer section only |
| Footer link | `#1f76c2` | Footer unsubscribe/settings links only — do not use this blue elsewhere, it's specific to the mandatory footer block |

## Button variants (see `components/buttons.html` for full markup)

1. **Primary CTA** — solid pill, `bgcolor:#000000`, `border-radius:9999px`, padding `12px 24px`, text `16px/400` white, centered. The one CTA per email/touchpoint that matters most.
2. **Secondary button** — rectangular, `bgcolor:#F6F1EE`, `border-radius:8px`, padding `8px 29px 8px 16px` (asymmetric to fit a leading icon), text `15px/400` black. Used for secondary/resource-style actions (e.g. "Video tutorials >").
3. **Outline/underline link** — transparent background, `border-bottom:1px solid #6161FF` only, text `16px/400` in `#6161FF`. Used for a softer secondary CTA (e.g. "Learn more >").
4. **Small icon text-link** — transparent background, pill radius but no visible fill, text `15px/400` in `#45454A` with a small leading icon. Used for compact inline links (e.g. "Integrate Gmail >").

## Images

- Full-bleed: `width:640px`, no radius, no side padding — spans the whole email
- Inset/card: `width:560px` inside the standard 40px side padding, `border-radius:16px`, `overflow:hidden`
- The photos used as image src placeholders in the `Images`/`Two colomn`/`Three colomn`
  source components are **generic stock photos** — never reuse those specific images,
  only their sizing/radius pattern. This does NOT apply to the logos and icons below,
  which are real assets, not placeholders.

## Real reusable assets — logos and icons

Unlike the stock photos above, these ARE genuine monday.com brand assets pulled from the
component library — use them directly by copying the file into wherever the email will be
hosted (or reference them if already hosted at a stable URL) rather than treating them as
throwaway placeholders. Binaries can't live in this repo — see
`references/asset-index.md` for the catalog and where the files are hosted.

- **Logos** — 13 distinct monday.com product sub-brand lockups (monday CRM, monday
  service, monday dev, monday workforms, monday work management, monday sidekick, monday
  vibe, monday notetaker, monday workflows, monday agents, monday campaigns, monday
  partnerships, monday.com), each present twice (two crops/variants — check both before
  picking one for a specific layout)
- **Icons** — small inline icons for button/list use: Gmail logo, Microsoft Word
  logo, play/video icon, edit/pencil icon, help/question icon (plus a second Gmail crop)

## Lists

- Bold lead-in phrase (`font-weight:600`) + regular continuation, both at `15px`, left-aligned
- Small marker icon per item, `21px × 20px` (or 21×21), left of the text
- Inline emphasis within list/body text uses the brand accent color `#6161FF` for a key phrase or link, not bold — don't bold and color the same span

## Header logos

- Logo/lockup images at `560px` width inside the standard content width
- Used for partner/integration logo rows (paired contextually with "Integrate X" buttons in the source file)

## Column layouts

- **Single column**: 100% width, standard content block
- **Two column**: several ratios exist in the source (near-even ~50/50, and an asymmetric ~32/68 icon+text split) — pick based on content, don't force a 50/50 split on an icon+label pairing
- **Three column**: equal thirds (~33.33/33.33/33.33) — the standard feature/benefit grid pattern (see the real trial-onboarding examples: "Move business forward" / "Keep your competitive edge" / "From meeting to ready-to-build")

## The footer block — mandatory, verbatim

`components/footer-divider-spacer.html` contains the exact, legally-required footer used
in real monday.com sends: unsubscribe + notification-settings links (Braze liquid tags),
"manage your work on the go" app-store badges, copyright + CAN-SPAM postal address, and
the closing logo image. **Never paraphrase, shorten, or omit this block** — it's
compliance content, not stylistic filler. The only thing that should ever change is
which Braze liquid variables are populated at send time, not the surrounding copy or
structure.
