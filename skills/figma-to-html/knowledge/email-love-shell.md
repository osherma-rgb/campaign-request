# Email Love shell — the structure the localization pipeline expects

**This replaces the old hand-rolled `email-shell.md` for anything going through the
Email Localization Upload board.** It is reverse-engineered from a real Email Love plugin
export (`EmailLove_7_6_2026_55_local.zip`, inspected 2026-08-11), not written from scratch.

## Why this exists

The old shell was a simplified reconstruction. It carried `class="text"` but none of the
surrounding MJML scaffolding, and paired it with an **unscoped** `.text { color:#fff }`
dark-mode rule. Braze's CSS inliner flattened that rule onto every matching element
regardless of the media query, producing white-on-white text and an invisible button on a
real test send. Deleting the dark-mode CSS made those sends readable but gave up dark mode
entirely.

The real Email Love output has neither problem, because its dark-mode rules are **scoped to
a class scaffolding that only exists inside the MJML structure**:

```css
.mj-w .text, .mj-w .text>div, .mj-w p   { color:#ffffff !important }
.mj-b>table>tbody>tr>td>a               { background:#ffffff !important; color:#000000 !important }
.b                                      { background-color:#1f1f1f !important }
```

A bare `.text` with no `.mj-w` ancestor never matches, so there is nothing for an inliner to
mis-flatten. Reproduce the scaffolding and dark mode works correctly; omit it and the rules
are simply inert — which is safe. **The failure mode only appears if you invent your own
unscoped rule. Don't.**

## Required class scaffolding

| Class | Goes on | Why |
|---|---|---|
| `b bBg` | the single outermost `<div>` inside `<body>` | dark-mode background target |
| `r mj-w` | each section wrapper `<div>` (one per content block) | scopes every dark-mode text rule |
| `mj-b` | the wrapper `<div>` around a button | flips the button to a white pill in dark mode |
| `text` | each text-bearing `<div>` | the actual text-color target (needs an `.mj-w` ancestor) |
| `link` | any inline `<a>` that carries its own explicit `color:` (e.g. a tracked `monday.com` mention, `braze-liquid-tags.md` §2) | flips that link's own color in dark mode — a parent `.mj-w .text` rule doesn't reach a descendant with its own explicit color, so links need this separately |
| `mj-column-per-100 mj-outlook-group-fix f mj-c nc` | a full-width column `<div>` | MJML column contract |

Real exports additionally stamp a random per-element hash class (`cac-76`, `ab0-73`) on each
of these, purely to hang generated CSS rules on. **We use inline styles instead, so the hash
classes are unnecessary — omit them.** Keep only the semantic classes above.

## Fixed-background sections never get `class="text"` or `class="link"`

A section can have its own explicit, non-flipping background color (e.g. a light-grey
`#F6F7FB` info card sitting inside an otherwise-white `.mj-w` wrapper). That background never
flips in dark mode — only the outer `.mj-w`-scoped backgrounds do (see the scaffolding table
above). If the text inside that card still carries `class="text"`, dark mode flips *only the
text* to white while the card's own background stays exactly where it was — white text on a
light-grey card, unreadable. Confirmed via a real Braze preview (2026-08-13, monday item
12793052638/NPO #13): three info cards with a `#F6F7FB` background had `class="text"` on
their headline/body divs, and dark mode rendered them invisible.

The fix: don't stamp `class="text"`/`class="link"` on any text/link sitting on a section with
its own fixed background that isn't meant to flip. Leave its color exactly as designed in
both modes. Only text on a background that *is* meant to flip (the `.mj-w`-level white/black
body background) should carry `class="text"`.

Multi-column layouts need a matching generated `.mj-column-per-<pct>` rule in the head
(Email Love emits e.g. `.mj-column-per-88-02920532226562`). If a design genuinely needs an
uneven split, either add the matching class + head rule or flag it — don't approximate it
with a bare percentage that has no head rule.

## Section wrapper pattern

Every content block sits in this wrapper. The MSO conditional comments are load-bearing for
Outlook desktop — keep them.

```html
<!--[if mso | IE]><table align="center" border="0" cellpadding="0" cellspacing="0" class="r-outlook mj-w-outlook" role="presentation" style="width:640px;" width="640" bgcolor="#FFFFFF"><tr><td style="line-height:0px;font-size:0px;mso-line-height-rule:exactly;"><![endif]-->
<div class="r mj-w" style="background:#FFFFFF;background-color:#FFFFFF;margin:0px auto;max-width:640px;">
  <table align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" style="background:#FFFFFF;background-color:#FFFFFF;width:100%;">
    <tbody><tr><td style="direction:ltr;font-size:0px;padding:0px;text-align:center;">

      <!-- section content: text / image / button -->

    </td></tr></tbody>
  </table>
</div>
<!--[if mso | IE]></td></tr></table><![endif]-->
```

Text inside a section:

```html
<div style="font-family: Poppins, Arial; font-size:15px; font-weight:400; line-height:150%; text-align:left; color:#000000;" class="text">Copy goes here</div>
```

Button inside a section (note `mj-b` on the wrapper):

```html
<div class="mj-b">
  <table align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" style="border-collapse:separate;line-height:100%;">
    <tbody><tr>
      <td align="center" bgcolor="#000000" role="presentation" style="border:0px;border-radius:9999px;cursor:auto;font-style:normal;text-align:center;background:#000000;" valign="middle">
        <a href="REPLACE" target="_blank" style="display:inline-block;background:#000000;color:#FFFFFF;font-family:Poppins, Arial;font-size:16px;font-style:normal;font-weight:400;line-height:140%;margin:0;text-decoration:none;text-transform:none;padding:12px 24px;border-radius:9999px;">Button text</a>
      </td>
    </tr></tbody>
  </table>
</div>
```

## Head

Use the head from `references/email-love-head.html` verbatim. It contains, in order: the
MJML reset, the MSO group fix, the Poppins webfont (`<link>` + `@import` + `@font-face`),
`.mj-column-per-100` responsive rules, mobile full-width rules, scrollbar/margin resets,
breakpoint rules, and **the dark-mode block**. Do not hand-edit the dark-mode block — copy it
as-is. It is the one part of this file where "close enough" has already cost us a broken send.

## Subject line + preheader

Right after `<body>` opens (before the visible content), the real export carries the
subject line and preheader as a single hidden `div`, joined by a literal `###`:

```html
<div style="display:none;font-size:1px;color:#ffffff;line-height:1px;max-height:0px;max-width:0px;opacity:0;overflow:hidden;">{subject}###{preheader}</div>
```

Two rules for what goes inside it, both confirmed against a real Braze preview render
(2026-08-12, monday item 12759914421):

- **Plain characters only — never an HTML entity. This includes emoji.** The pipeline
  extracts this div as raw text, not rendered HTML, so entities are never decoded. A real
  send showed the literal string `You&#39;re invited...` in the Subject line field of
  Braze's preview — the `&#39;` never became an apostrophe. Use a plain `'` and a plain `&`
  here even though that makes this one div's inner text not strictly-valid HTML by itself;
  that trade-off is intentional and confined to this div only. **The same applies to emoji:
  a literal `🍹` must stay a literal `🍹`, never `&#127865;`** — a real bug (confirmed
  2026-08-13, monday item 12761404720) shipped the numeric-entity form here on the theory
  that "non-ASCII punctuation gets entity-escaped," but this div is never rendered as HTML,
  so the entity shows up as literal garbled text (`&#127865;`) in Braze's subject-line
  preview instead of the emoji. Every *other* text node in the email still needs full
  entity escaping per the Character encoding rule below — this is the one exception, and it
  exists because this div is never rendered as HTML in the first place.
- **Lowercase only a word that is ALL CAPS in full — never touch normal sentence case.**
  Subject and preheader must not shout, so a source word in full caps (e.g. "FREE", "NOW",
  "TODAY") gets lowercased when placed in this div. But this rule targets *individual fully
  capitalized words*, not the sentence as a whole: a normal title/sentence-case subject
  like "Good conversations. Great cocktails. One day only." has no ALL-CAPS word in it and
  must be copied verbatim, capital letters and all — do not lowercase the whole string on
  the assumption that every leading capital is "shouting." A real bug (confirmed
  2026-08-13, monday item 12761404720) lowercased that entire sentence to "good
  conversations. great cocktails. one day only." even though none of its words were
  ALL-CAPS. This rule applies only to the hidden subject/preheader div, not to visible body
  copy elsewhere in the email, which follows the design as given.

## What the export does NOT contain

Verified against the real ZIP — all absent:

- **No Liquid tags.** `{{${first_name} | default: 'there'}}` and friends are authored as
  literal text *in the Figma design* by the designer, so they ride through the export as
  plain text. Don't inject them; carry through whatever Figma has. If Figma has an
  incomplete tag (e.g. `{{${first_name}}}` with no default), complete it per
  `braze-liquid-tags.md` §1 and flag that you did.
- **No footer content block — and don't add one.** The export ends at the last design
  section. Confirmed via a real Braze test send (2026-08-12, monday item 12782188111): the
  Email Localization Uploads board's own automation already appends
  `{{content_blocks.${fotter_with_monday_logo}}}` to every template it builds downstream.
  Adding that reference yourself in the HTML produces two stacked footers in the live
  template. This was previously an open, unverified question (see prior revisions) — it is
  now settled: never add the footer block on this path. `braze-liquid-tags.md` §4 is
  legacy-hand-paste-only for this reason.
- **No `index.html`.** The HTML file is named after the email (`Email 2_7_6_2026_.html`).
  `how-to-email.md` says `index.html` — that is wrong; the real export does not use it.

## ZIP layout

```
<anything>.zip
├── Email 2_7_6_2026_.html      ← at root, any filename, must end .html
└── Images/                      ← capital I
    ├── Email_2_Image_87f2a58c-….png
    └── …
```

HTML references images as `src="Images/<filename>"` — relative, no leading `./`, no absolute
URL. Every image referenced must exist in `Images/`, and nothing in `Images/` should be
unreferenced.
