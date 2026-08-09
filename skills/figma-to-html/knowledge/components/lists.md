<!-- Snapshot copied from marketing-cookbook domains/lifecycle-marketing/skills/email-design on 2026-08-09. Re-sync from there if that library changes. -->

# lists (email HTML — copy the fenced block)

```html
<!--
  List item snippet — bold lead-in + regular continuation, both 15px, with a small
  marker icon (21x20px, typically a checkmark). Repeat the <tr> block once per item.
  Use the inline brand-accent span for at most one key phrase per item, not every item.
-->
<table align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" style="width:100%;">
  <tbody><tr><td style="padding:0px 40px;">
    <table border="0" cellpadding="0" cellspacing="0" role="presentation" width="100%">
      <tbody>

        <!-- repeat this row per list item -->
        <tr>
          <td width="21" valign="top" style="padding:4px 12px 4px 0px;">
            <img src="REPLACE_CHECK_ICON.png" alt="" width="21" height="20" style="border:0;display:block;">
          </td>
          <td style="font-family: Poppins, Arial; font-size: 15px; font-weight: 400; letter-spacing: 0px; line-height: 140%; color: #000000; padding:4px 0px;">
            <span style="font-weight: 600;">Bold lead-in phrase</span> — regular continuation text describing it, or <span style="color: #6161FF;">an emphasized link</span> if this item points somewhere.
          </td>
        </tr>
        <!-- /repeat -->

      </tbody>
    </table>
  </td></tr></tbody>
</table>
```
