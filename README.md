# Campaign Request

🔗 [Landing page](https://osherma-rgb.github.io/campaign-request/)

An email-campaign agent for monday.com Lifecycle Marketing that automates:
`monday item → Figma design → HTML → upload to Braze (later: HubSpot)`.

Built step by step, one phase at a time:

- **Phase 1** (current): trigger manually, focused on Braze. The full chain now runs
  end to end for a single monday item: **monday item → Figma → HTML → ZIP → Email
  Localization Uploads board → the real n8n EN Thin Flow → live Braze template.**
  [`skills/campaign-pipeline/`](skills/campaign-pipeline/SKILL.md) orchestrates the three
  skills that each own one stage — **Monday reader**
  ([`skills/monday-reader/`](skills/monday-reader/SKILL.md)), **Figma → HTML**
  ([`skills/figma-to-html/`](skills/figma-to-html/SKILL.md)), and **Email localization
  upload** ([`skills/email-localization-upload/`](skills/email-localization-upload/SKILL.md))
  — end to end tested against a real monday item + Figma design — see
  [`skills/figma-to-html/examples/`](skills/figma-to-html/examples/). This chain is
  **Braze only** — HubSpot has no equivalent localization-board path yet (see Phase 4).
- **Phase 2**: trigger automatically when a monday item is opened.
- **Phase 3**: connect new agent content to Figma.
- **Phase 4**: support HubSpot.

## Layout

```
skills/
├── campaign-pipeline/          — orchestrates the full monday item → Braze template chain
│                                  by running the three skills below in order (Braze only)
├── monday-reader/               — resolves the Figma URL + CTA link from a monday campaign item
├── figma-to-html/                — converts an approved Figma email design into send-ready,
│                                    Braze-compatible HTML, cross-checked against monday-reader's
│                                    CTA link (Phase 1 scope)
└── email-localization-upload/    — uploads the finished ZIP to the monday Email Localization
                                     Uploads board and triggers the real n8n pipeline that
                                     builds the live Braze template — no reimplementation of
                                     that pipeline
```

Knowledge files under `skills/figma-to-html/knowledge/` (design tokens, email shell,
approved component snippets, asset index) are a point-in-time snapshot copied from the
org's `marketing-cookbook` repo's `lifecycle-marketing/email-design` skill — re-sync from
there if that library changes. `braze-liquid-tags.md` is new to this repo: the
liquid-tag/content-block substitutions required for this pipeline's Braze conventions.
