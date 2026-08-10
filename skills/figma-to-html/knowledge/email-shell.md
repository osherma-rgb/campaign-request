<!-- Snapshot copied from marketing-cookbook domains/lifecycle-marketing/skills/email-design on 2026-08-09. Re-sync from there if that library changes. -->

# email-shell (email HTML — copy the fenced block)

```html
<!--
  Email shell — wrap every assembled email in this doctype/head/body.
  Insert component snippets (see components/*.html) inside the marked body region,
  in the order the touchpoint's content calls for, then close with the mandatory
  footer from components/footer-divider-spacer.html.

  Content width system: 640px total email width, 40px side padding, 560px effective
  content width. Every component snippet already follows this — don't change it per
  email.

  Dark mode: deliberately NOT handled via a custom @media (prefers-color-scheme: dark)
  override — an earlier version of this shell had one (flipping text/buttons to white via
  class="text"/class="mj-b"), but a real Braze test send proved it actively breaks every
  send: Braze's CSS inliner ("CSS inlining enabled" in its editor) inlines whatever a
  selector matches without respecting the @media boundary, so the dark-mode-only rule got
  applied unconditionally — white text on a white background, and a button whose black
  pill turned white and vanished, in NORMAL (light) rendering, not just in actual dark
  mode. The `:root{color-scheme:light;supported-color-schemes:light;}` declaration below
  is the correct, safe mitigation instead — it tells compliant clients this email is
  light-only and they shouldn't auto-invert it at all, with no inlining risk since it's a
  `:root` rule, not a class other markup depends on. Don't reintroduce a dark-mode class
  override here or in any component snippet.
-->
<!doctype html>
<html lang="en" dir="auto" xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">
  <head>
    <title></title>
    <!--[if !mso]><!-->
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <!--<![endif]-->
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style type="text/css">
      #outlook a { padding:0; }
      body { margin:0;padding:0;-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%; }
      table, td { border-collapse:collapse;mso-table-lspace:0pt;mso-table-rspace:0pt; }
      img { border:0;height:auto;line-height:100%; outline:none;text-decoration:none;-ms-interpolation-mode:bicubic; }
      p { display:block;margin:13px 0; }
    </style>
    <!--[if mso]>
    <noscript>
    <xml>
    <o:OfficeDocumentSettings>
      <o:AllowPNG/>
      <o:PixelsPerInch>96</o:PixelsPerInch>
    </o:OfficeDocumentSettings>
    </xml>
    </noscript>
    <![endif]-->
    <!--[if lte mso 11]>
    <style type="text/css">
      .mj-outlook-group-fix { width:100% !important; }
    </style>
    <![endif]-->
    <!--[if !mso]><!-->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap" rel="stylesheet" type="text/css">
    <style type="text/css">
      @import url(https://fonts.googleapis.com/css2?family=Poppins:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap);
    </style>
    <!--<![endif]-->
    <style type="text/css">
      @media only screen and (min-width:480px) {
        .mj-column-per-100 { width:100% !important; max-width: 100%; }
      }
    </style>
    <style media="screen and (min-width:480px)">
      .moz-text-html .mj-column-per-100 { width:100% !important; max-width: 100%; }
    </style>
    <style type="text/css">@media only screen and (min-width: 320px){body::-webkit-scrollbar{display:none !important;}p, a{margin:0 !important;}} </style>
    <style type="text/css">:root{color-scheme:light;supported-color-schemes:light;}</style>
  </head>
  <body style="word-spacing:normal;background-color:#ffffff;">
    <div aria-roledescription="email" class="b bBg" style="margin: auto; background-color: #ffffff;" role="article" lang="und" dir="auto">

      <!-- ==================== BODY COMPONENTS GO HERE ==================== -->
      <!-- Insert one component snippet per content block, in the order the   -->
      <!-- touchpoint calls for (heading, body text, image, buttons, etc.)   -->
      <!-- ==================================================================== -->

      <!-- Mandatory: append components/footer-divider-spacer.html's FOOTER block -->
      <!-- (not the divider/spacer utilities — the actual compliance footer) here -->

    </div>
  </body>
</html>
```
