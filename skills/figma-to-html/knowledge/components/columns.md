<!-- Snapshot copied from marketing-cookbook domains/lifecycle-marketing/skills/email-design on 2026-08-09. Re-sync from there if that library changes. -->

# columns (email HTML — copy the fenced block)

```html
<!--
  Column layouts. All within the 640px total / 560px content width system.
  Pick the ratio based on content, not by default — an icon+label pairing wants an
  asymmetric split (~32/68), not an even 50/50.

  Every text node below is wrapped in <span class="text"> — required so the shell's
  dark-mode override (email-shell.md) flips it to white; without that class it stays
  #000000 and goes invisible once the shell forces the background black in dark mode.
  Keep this wrapper when you edit these snippets.
-->

<!-- SINGLE COLUMN — 100% width, the default wrapper for any standalone content block -->
<table align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" style="width:100%;">
  <tbody><tr><td style="padding:24px 40px;">
    <!-- content goes here -->
  </td></tr></tbody>
</table>

<!-- TWO COLUMN — near-even split (~50/50), side by side on desktop, stacks on mobile -->
<table align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" style="width:100%;">
  <tbody><tr>
    <td valign="top" style="width:50%;padding:24px 12px 24px 40px;" class="mobile-stack">
      <!-- left column content -->
    </td>
    <td valign="top" style="width:50%;padding:24px 40px 24px 12px;" class="mobile-stack">
      <!-- right column content -->
    </td>
  </tr></tbody>
</table>

<!-- TWO COLUMN — asymmetric icon+label split (~32/68), for an icon or small graphic next to a label/link -->
<table align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" style="width:100%;">
  <tbody><tr>
    <td valign="middle" align="center" style="width:32%;padding:24px 0px 24px 40px;">
      <img src="REPLACE_ICON.png" alt="" width="60" style="border:0;display:block;margin:0 auto;">
    </td>
    <td valign="middle" style="width:68%;padding:24px 40px 24px 12px;font-family: Poppins, Arial; font-size: 15px; font-weight: 400; color: #000000;">
      <span class="text">Label or link text goes here</span>
    </td>
  </tr></tbody>
</table>

<!-- THREE COLUMN — equal thirds, the standard feature/benefit grid (see real trial-onboarding examples: "Move business forward" / "Keep your competitive edge" / "From meeting to ready-to-build") -->
<table align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" style="width:100%;">
  <tbody><tr>
    <td valign="top" style="width:33.33%;padding:24px 8px 24px 40px;">
      <div style="font-family: Poppins, Arial; font-size: 16px; font-weight: 600; letter-spacing: 0px; line-height: 140%; color: #000000; text-align:left;"><span class="text">Feature one headline</span></div>
      <div style="font-family: Poppins, Arial; font-size: 14px; font-weight: 400; letter-spacing: 0px; line-height: 150%; color: #000000; text-align:left; padding-top:8px;"><span class="text">One sentence describing it.</span></div>
    </td>
    <td valign="top" style="width:33.33%;padding:24px 8px;">
      <div style="font-family: Poppins, Arial; font-size: 16px; font-weight: 600; letter-spacing: 0px; line-height: 140%; color: #000000; text-align:left;"><span class="text">Feature two headline</span></div>
      <div style="font-family: Poppins, Arial; font-size: 14px; font-weight: 400; letter-spacing: 0px; line-height: 150%; color: #000000; text-align:left; padding-top:8px;"><span class="text">One sentence describing it.</span></div>
    </td>
    <td valign="top" style="width:33.33%;padding:24px 40px 24px 8px;">
      <div style="font-family: Poppins, Arial; font-size: 16px; font-weight: 600; letter-spacing: 0px; line-height: 140%; color: #000000; text-align:left;"><span class="text">Feature three headline</span></div>
      <div style="font-family: Poppins, Arial; font-size: 14px; font-weight: 400; letter-spacing: 0px; line-height: 150%; color: #000000; text-align:left; padding-top:8px;"><span class="text">One sentence describing it.</span></div>
    </td>
  </tr></tbody>
</table>
<!-- Note: multi-column tables don't stack automatically without the mj-column media-query classes
     from a real MJML build. If mobile stacking matters for this send, compile through MJML/Braze's
     drag-and-drop editor rather than hand-editing — see SKILL.md. -->
```
