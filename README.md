# Campaign Request

🔗 [Landing page](https://osherma-rgb.github.io/campaign-request/)

An email-campaign agent for monday.com Lifecycle Marketing that automates:
`monday item → Figma design → HTML → upload to Braze (later: HubSpot)`.

Built step by step, one phase at a time:

- **Phase 1** (current): trigger manually, focused on Braze. Both **Monday reader**
  ([`skills/monday-reader/`](skills/monday-reader/SKILL.md)) and **Figma → HTML**
  ([`skills/figma-to-html/`](skills/figma-to-html/SKILL.md)) are implemented and
  end-to-end tested against a real monday item + Figma design — see
  [`skills/figma-to-html/examples/`](skills/figma-to-html/examples/).
- **Phase 2**: trigger automatically when a monday item is opened.
- **Phase 3**: connect new agent content to Figma.
- **Phase 4**: support HubSpot.

## Layout

```
skills/
├── monday-reader/      — resolves the Figma URL + CTA link from a monday campaign item
└── figma-to-html/       — converts an approved Figma email design into send-ready,
                            Braze-compatible HTML, cross-checked against monday-reader's
                            CTA link (Phase 1 scope)
```

Knowledge files under `skills/figma-to-html/knowledge/` (design tokens, email shell,
approved component snippets, asset index) are a point-in-time snapshot copied from the
org's `marketing-cookbook` repo's `lifecycle-marketing/email-design` skill — re-sync from
there if that library changes. `braze-liquid-tags.md` is new to this repo: the
liquid-tag/content-block substitutions required for this pipeline's Braze conventions.
