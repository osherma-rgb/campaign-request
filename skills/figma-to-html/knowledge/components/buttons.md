<!-- Snapshot copied from marketing-cookbook domains/lifecycle-marketing/skills/email-design on 2026-08-09. Re-sync from there if that library changes. -->

# buttons (email HTML — copy the fenced block)

```html
<!--
  Button snippets — the 4 pre-approved variants (see ../design-tokens.md for when to use
  each). Swap the href and the link text only. Keep the Outlook VML fallback for the
  pill-shaped buttons — Outlook desktop doesn't support CSS border-radius, so without it
  the button renders as a square in Outlook.

  Variant 4's text is wrapped in <span class="text"> — its #45454A color has no built-in
  contrast against the shell's dark-mode black background (email-shell.md) without that
  class forcing it white. Variants 1–3 don't need it: their colors (white-on-black,
  black-on-cream, brand purple-on-transparent) already work in both modes as authored.
-->

<!-- 1. PRIMARY CTA — solid black pill. Use once per email/touchpoint, the one action that matters most. -->
<table align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" style="width:100%;">
  <tbody><tr><td align="center" style="padding:24px 40px;">
    <!--[if mso]><v:roundrect xmlns:v="urn:schemas-microsoft-com:vml" xmlns:w="urn:schemas-microsoft-com:office:word" style="height:46px;v-text-anchor:middle;width:180px;" arcsize="50%" stroke="f" fill="t" fillcolor="#000000"><w:anchorlock/><center style="color:#FFFFFF;font-family:Poppins, Arial;font-size:16px;font-weight:400;mso-line-height-rule:exactly">
      <span>Primary CTA text</span>
    </center></v:roundrect><![endif]-->
    <!--[if !mso]><!-->
    <table border="0" cellpadding="0" cellspacing="0" role="presentation" style="border-collapse:separate;line-height:100%;">
      <tbody><tr>
        <td align="center" bgcolor="#000000" role="presentation" style="border:0px;border-radius:9999px;cursor:auto;font-style:normal;text-align:center;background:#000000;" valign="middle">
          <a href="https://monday.com/?utm_campaign=REPLACE&utm_medium=email&utm_source=braze" target="_blank" style="display:inline-block;background:#000000;color:#FFFFFF;font-family:Poppins, Arial;font-size:16px;font-style:normal;font-weight:400;line-height:140%;margin:0;text-decoration:none;text-transform:none;padding:12px 24px;border-radius:9999px;">Primary CTA text</a>
        </td>
      </tr></tbody>
    </table>
    <!--<![endif]-->
  </td></tr></tbody>
</table>

<!-- 2. SECONDARY BUTTON — rectangular, cream fill, for a secondary/resource-style action (e.g. "Video tutorials >") -->
<table align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" style="width:100%;">
  <tbody><tr><td align="center" style="padding:0px 40px 24px;">
    <table border="0" cellpadding="0" cellspacing="0" role="presentation" style="border-collapse:separate;width:100%;max-width:560px;line-height:100%;">
      <tbody><tr>
        <td align="center" bgcolor="#F6F1EE" role="presentation" style="border:0px;border-radius:8px;cursor:auto;font-style:normal;text-align:left;background:#F6F1EE;" valign="middle">
          <a href="https://monday.com/?utm_campaign=REPLACE&utm_medium=email&utm_source=braze" target="_blank" style="display:inline-block;width:100%;background:#F6F1EE;color:#000000;font-family:Poppins, Arial;font-size:15px;font-style:normal;font-weight:400;line-height:140%;margin:0;text-decoration:none;text-transform:none;padding:8px 29px 8px 16px;border-radius:8px;">Secondary button text ></a>
        </td>
      </tr></tbody>
    </table>
  </td></tr></tbody>
</table>

<!-- 3. OUTLINE / UNDERLINE LINK — softer secondary CTA (e.g. "Learn more >") -->
<table align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" style="width:100%;">
  <tbody><tr><td align="center" style="padding:0px 40px 24px;">
    <!--[if mso]><v:roundrect xmlns:v="urn:schemas-microsoft-com:vml" xmlns:w="urn:schemas-microsoft-com:office:word" style="height:22px;v-text-anchor:middle;width:104px;" arcsize="0%" stroke="t" strokecolor="#6161FF" strokeweight="1px" fill="f"><w:anchorlock/><center style="color:#6161FF;font-family:Poppins, Arial;font-size:16px;font-weight:400;mso-line-height-rule:exactly">
      <span>Outline link text</span>
    </center></v:roundrect><![endif]-->
    <!--[if !mso]><!-->
    <table border="0" cellpadding="0" cellspacing="0" role="presentation" style="border-collapse:separate;line-height:100%;">
      <tbody><tr>
        <td align="center" bgcolor="transparent" role="presentation" style="border:0px;border-bottom:1px solid #6161FF;cursor:auto;font-style:normal;text-align:center;background:transparent;" valign="middle">
          <a href="https://monday.com/?utm_campaign=REPLACE&utm_medium=email&utm_source=braze" target="_blank" style="display:inline-block;background:transparent;color:#6161FF;font-family:Poppins, Arial;font-size:16px;font-style:normal;font-weight:400;line-height:140%;margin:0;text-decoration:none;text-transform:none;padding:0px;">Outline link text ></a>
        </td>
      </tr></tbody>
    </table>
    <!--<![endif]-->
  </td></tr></tbody>
</table>

<!-- 4. SMALL ICON TEXT-LINK — compact inline link, e.g. "Integrate Gmail >" — icon is optional, drop the <img> if not needed -->
<table align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" style="width:100%;">
  <tbody><tr><td align="center" style="padding:0px 40px 12px;">
    <table border="0" cellpadding="0" cellspacing="0" role="presentation" style="border-collapse:separate;line-height:100%;">
      <tbody><tr>
        <td align="center" bgcolor="transparent" role="presentation" style="border:0px;border-radius:100px;cursor:auto;font-style:normal;text-align:left;background:transparent;" valign="middle">
          <a href="https://monday.com/?utm_campaign=REPLACE&utm_medium=email&utm_source=braze" target="_blank" style="display:inline-block;background:transparent;color:#45454A;font-family:Poppins, Arial;font-size:15px;font-style:normal;font-weight:400;line-height:140%;margin:0;text-decoration:none;text-transform:none;padding:1px 0px;border-radius:100px;">
            <img src="REPLACE_ICON.png" alt="" style="vertical-align: middle; margin-top: -3px; margin-right:4px;"><span class="text">Icon link text ></span></a>
        </td>
      </tr></tbody>
    </table>
  </td></tr></tbody>
</table>
```
