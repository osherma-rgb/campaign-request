# Email design — fixes & running memory

Running log of real failures caught on live Figma → Braze/HubSpot builds, and the fix
applied for each. Read this before assembling a new email — it's the fastest way to avoid
repeating a bug that already cost a real send or a real review round.

## 1. Dark mode: never apply `.text`/`.link` classes to text on a fixed-background card

**Symptom:** Text and its background render in the same color — most often white-on-white
or white-on-light-gray — but only in dark mode / dark-mode preview. Looks fine in the
normal light-mode editor, which is why it slips through.

**Root cause:** The Email Love shell's dark-mode CSS block flips any element carrying
`class="text"` (or `class="link"`) to white whenever it sits inside an `.mj-w` wrapper —
regardless of that specific element's own background color. Most content sits directly on
the page's white/dark `bBg` background, so the flip is correct there. But a section with
its **own fixed background** (a callout card, a `#F3F4F5` highlight box, anything that
does not itself flip color with the page) breaks: the surrounding card stays light, the
text inside it turns white, and it becomes unreadable.

**Real instance:** August Nonprofit Update email (monday item 12670417054). The webinar
block ("Webinar: How to use monday agents" / "Join the live webinar" / "Register here >")
sits on a fixed `#F3F4F5` card. It had `class="text"` / `class="link"` applied, so dark
mode turned all of that text white against the still-light card — invisible. Everything
else in the same email (page-background text, the primary CTA) flipped correctly, because
those sit on the page's own flippable background.

**Fix:** Before applying `class="text"`/`class="link"` to any text or link element, check
what it's sitting on:
- Directly on the page's white/dark background → apply the class, it will flip correctly.
- On a section with its own fixed (non-flipping) background color → do **not** apply the
  class. Hardcode the color inline instead (`style="color:#000000 !important;"` etc. on
  that element only — not a new stylesheet rule; a hand-written unscoped selector is a
  separate, worse failure mode, see §2).

**Verification step to actually catch this next time:** render the assembled HTML in a
browser with `prefers-color-scheme: dark` (and separately `light`) before calling the
build done. A visual pass in light mode alone will not surface this bug — it only shows
under the dark-mode media query.

## 2. Never hand-write an unscoped dark-mode rule

**Symptom:** White-on-white text and an invisible/shapeless button in **normal light-mode
rendering**, on every send — not just a dark-mode preview.

**Root cause:** A rule like `.text { color:#fff }` with no `.mj-w` ancestor scoping is
flattened by Braze's CSS inliner onto every matching element, ignoring the media-query
boundary entirely.

**Fix:** Reproduce the real Email Love shell scaffolding (`b bBg` / `r mj-w` / `mj-b` /
`text`, see `knowledge/email-love-shell.md`) and copy the dark-mode CSS block verbatim from
the real export (`references/email-love-head.html`). Never invent a new selector in
between. If dark mode isn't needed, omit the block entirely rather than approximating it —
an omitted block is inert; an invented one is what broke a real send.

## 3. A Figma link that only covers part of the email — expand to the full design

**Symptom:** The HTML is built and looks clean, but it's missing sections the subject line
or update thread clearly referenced (other CTAs, other product blocks).

**Root cause:** A monday item's Figma link column can point to a node that is only one
module/section nested inside a much larger design (e.g. a small "mj-wrapper" positioned
deep inside a taller parent frame), not the full email.

**Real instance:** Same August Nonprofit Update item — the item's linked node was just the
"Webinar" section (y-offset 2340 inside a ~2800px-tall parent). Building only that node
would have shipped an email missing the hero copy and all four agent-template feature
blocks that the subject line and update thread referenced.

**Fix:** After pulling design context for a given node, sanity-check its size/position
against what the subject line, item copy, or update thread implies. If the node looks like
a sub-module (small, named like a component, nonzero y-offset inside a taller frame), check
the parent/ancestor frame before building, or ask the user for the correct top-level node —
don't silently build just the linked fragment.

## 4. Other standing rules (carried from feedback memory)

- **No base64 images** — data URIs don't survive Braze sends. Always download real image
  bytes into the ZIP's `Images/` folder and reference them with a relative
  `src="Images/<filename>"`, never inline base64.
- **Email wrapper max-width** — cap the outer wrapper at `max-width:640px` or desktop
  Braze rendering stretches full-bleed.
- **Subject line vs in-body headline must always differ** — don't reuse the subject line
  text as the first on-page headline.
- **No em dash (—) in copy** — never use it in email body copy or subject/preview text.
- **Button spec fidelity** — primary CTA font-size:16px / weight:400 / padding:12px 24px,
  exactly, every time. Never `font-weight:700` anywhere in this library.
- **Every plain "monday.com" mention** gets wrapped in the tracked anchor (Braze) or styled
  span (HubSpot) — no exceptions for mentions that read as plain prose.
