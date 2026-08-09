# Campaign Request

An email-campaign agent for monday.com Lifecycle Marketing that automates:
`monday item → Figma design → HTML → upload to Braze (later: HubSpot)`.

Built step by step, one phase at a time:

- **Phase 1** (current): trigger manually, focused on Braze. Only the **Figma → HTML**
  step is implemented so far — see [`skills/figma-to-html/`](skills/figma-to-html/SKILL.md).
- **Phase 2**: trigger automatically when a monday item is opened.
- **Phase 3**: connect new agent content to Figma.
- **Phase 4**: support HubSpot.

## Layout

```
skills/
└── figma-to-html/     — converts an approved Figma email design into send-ready,
                          Braze-compatible HTML (Phase 1 scope)
```

Knowledge files under `skills/figma-to-html/knowledge/` (design tokens, email shell,
approved component snippets, asset index) are a point-in-time snapshot copied from the
org's `marketing-cookbook` repo's `lifecycle-marketing/email-design` skill — re-sync from
there if that library changes. `braze-liquid-tags.md` is new to this repo: the
liquid-tag/content-block substitutions required for this pipeline's Braze conventions.
