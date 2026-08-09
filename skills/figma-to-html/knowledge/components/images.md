<!-- Snapshot copied from marketing-cookbook domains/lifecycle-marketing/skills/email-design on 2026-08-09. Re-sync from there if that library changes. -->

# images (email HTML — copy the fenced block)

```html
<!--
  Image snippets — two variants. Swap src, alt, and width/height to match the real asset.
  Never reuse a placeholder stock photo from the source components — these are sizing/
  radius patterns only, not brand imagery.
-->

<!-- Full-bleed — spans the whole 640px email width, no radius, no side padding -->
<table align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" style="width:100%;">
  <tbody><tr><td style="padding:0px;text-align:center;">
    <img src="REPLACE.png" alt="REPLACE alt text" width="640" style="border:0;display:block;outline:none;text-decoration:none;width:100%;max-width:100%;height:auto;">
  </td></tr></tbody>
</table>

<!-- Inset / card — 560px content width, 16px rounded corners -->
<table align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" style="width:100%;">
  <tbody><tr><td style="padding:16px 40px;text-align:center;">
    <table align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" style="width:100%;max-width:560px;border-radius:16px;overflow:hidden;border-collapse:separate;">
      <tbody><tr><td style="border-radius:16px;">
        <img src="REPLACE.png" alt="REPLACE alt text" width="560" style="border:0;display:block;outline:none;text-decoration:none;width:100%;max-width:100%;height:auto;">
      </td></tr></tbody>
    </table>
  </td></tr></tbody>
</table>
```
