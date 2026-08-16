#!/usr/bin/env python3
"""
Wrap plain-text "monday.com" mentions in the standard tracked UTM link.

Walks the HTML as text nodes (via HTMLParser) rather than doing a blind
regex-replace over the raw markup, so it never touches:
  - text that's already inside an <a> tag (any href) — skipped entirely, no
    nesting or overwriting an existing link
  - attribute values (href, alt, src, etc.)
  - <script>, <style>, <title> contents, or HTML comments

Original casing inside the link text is preserved (e.g. "Monday.com" stays
"Monday.com") even though the match itself is case-insensitive.

Usage: wrap_monday_link.py <input.html> <output.html>
Prints the number of replacements made to stderr.
"""
import re
import sys
from html.parser import HTMLParser

LINK_HTML = (
    '<a href="https://monday.com/?utm_medium=email&utm_source=braze&utm_campaign='
    'multi-en-other-multi-n/a-email" style="text-decoration: none; color:#000000; '
    'cursor: auto; white-space:nowrap">{text}</a>'
)
SKIP_TAGS = {"a", "script", "style", "title"}


class TextNodeFinder(HTMLParser):
    def __init__(self, raw):
        super().__init__(convert_charrefs=False)
        self.raw = raw
        self.skip_depth = 0
        self.replacements = []

    def _offset(self, pos):
        line, col = pos
        lines = self.raw.split("\n")
        return sum(len(l) + 1 for l in lines[: line - 1]) + col

    def handle_starttag(self, tag, attrs):
        if tag.lower() in SKIP_TAGS:
            self.skip_depth += 1

    def handle_endtag(self, tag):
        if tag.lower() in SKIP_TAGS and self.skip_depth > 0:
            self.skip_depth -= 1

    def handle_data(self, data):
        if self.skip_depth > 0 or "monday.com" not in data.lower():
            return
        start_offset = self._offset(self.getpos())
        for m in re.finditer(r"monday\.com", data, re.IGNORECASE):
            self.replacements.append(
                (start_offset + m.start(), start_offset + m.end(), m.group(0))
            )


def wrap_monday_dot_com(raw_html):
    parser = TextNodeFinder(raw_html)
    parser.feed(raw_html)
    parser.close()
    reps = sorted(parser.replacements, key=lambda r: r[0])
    out, last = [], 0
    for start, end, matched_text in reps:
        out.append(raw_html[last:start])
        out.append(LINK_HTML.format(text=matched_text))
        last = end
    out.append(raw_html[last:])
    return "".join(out), len(reps)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: wrap_monday_link.py <input.html> <output.html>", file=sys.stderr)
        sys.exit(1)
    src, dst = sys.argv[1], sys.argv[2]
    html = open(src, encoding="utf-8").read()
    wrapped, count = wrap_monday_dot_com(html)
    open(dst, "w", encoding="utf-8").write(wrapped)
    print(f"wrapped {count} occurrence(s) of monday.com", file=sys.stderr)
