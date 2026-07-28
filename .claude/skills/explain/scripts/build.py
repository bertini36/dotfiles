#!/usr/bin/env python3
"""Assemble an explainer page, screenshot it for review, and open it in Chrome.

Build the page, then look at the screenshots before opening anything:

    build.py build --content frag.html --title "..." --lede "..." \
             --source-url https://example.com/post --source-label "Example" \
             --slug my-topic
    build.py open ~/explains/2026-07-27-my-topic/index.html

`build` writes index.html plus .preview/light.png and .preview/dark.png, and
refuses to write a page that would execute script or fetch from the network.
"""

import argparse
import datetime
import html
import os
import pathlib
import re
import subprocess
import sys
from html.parser import HTMLParser
from urllib.parse import urlparse

ASSETS = pathlib.Path(__file__).resolve().parent.parent / "assets"
OUT_ROOT = pathlib.Path.home() / "explains"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

DIR_MODE = 0o700
FILE_MODE = 0o600

# Tags that execute, fetch, or submit. None of them belong in an explainer.
BLOCKED_TAGS = {"script", "iframe", "object", "embed", "link", "base", "meta",
                "form", "input", "textarea", "button", "applet", "frame", "frameset"}

# Only a plain link may point off-machine: the reader clicks it deliberately.
# Anything else carrying a remote target fetches it on load.
REMOTE_OK_TAGS = {"a"}

URL_ATTRS = {"href", "src", "xlink:href", "srcset", "data", "poster",
             "formaction", "action", "background"}


def fail(message):
    sys.exit(f"build.py: {message}")


class InertPageChecker(HTMLParser):
    """Flags markup that would execute or reach the network when the page loads.

    This enforces the skill's no-JavaScript, no-remote-resource promise on
    content written from an untrusted source document. It guards against
    markup copied out of that source; it is not a hardened sanitiser and will
    not stop a determined mutation-XSS payload.
    """

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.problems = []
        self._in_style = False

    def _flag(self, what):
        self.problems.append(f"line {self.getpos()[0]}: {what}")

    def handle_starttag(self, tag, attrs):
        if tag in BLOCKED_TAGS:
            self._flag(f"<{tag}> is not allowed")
        if tag == "style":
            self._in_style = True
        for raw_name, raw_value in attrs:
            name = (raw_name or "").lower()
            value = (raw_value or "").strip()
            if name.startswith("on"):
                self._flag(f"<{tag} {name}=...> is an event handler")
            elif name == "style" and self._loads_remote_css(value):
                self._flag(f"<{tag} style=...> loads a remote resource")
            elif name in URL_ATTRS:
                self._check_url(tag, name, value)

    def handle_startendtag(self, tag, attrs):
        self.handle_starttag(tag, attrs)
        if tag == "style":
            self._in_style = False

    def handle_endtag(self, tag):
        if tag == "style":
            self._in_style = False

    def handle_data(self, data):
        if self._in_style and self._loads_remote_css(data):
            self._flag("<style> loads a remote resource")

    @staticmethod
    def _loads_remote_css(text):
        low = text.lower()
        return "@import" in low or bool(re.search(r"url\(\s*['\"]?(?:https?:)?//", low))

    def _check_url(self, tag, name, value):
        # Browsers ignore whitespace inside a scheme, so strip it before testing.
        target = "".join(value.split()).lower()
        if target.startswith(("javascript:", "vbscript:")):
            self._flag(f"<{tag} {name}=...> is a script URL")
        elif target.startswith("data:") and not target.startswith("data:image/"):
            self._flag(f"<{tag} {name}=...> is a non-image data URL")
        elif target.startswith(("http://", "https://", "//")) and tag not in REMOTE_OK_TAGS:
            self._flag(f"<{tag} {name}=...> fetches from the network on load")


def assert_inert(label, markup):
    checker = InertPageChecker()
    checker.feed(markup)
    checker.close()
    if checker.problems:
        listing = "\n  ".join(checker.problems)
        fail(
            f"{label} would not render inert, so nothing was written:\n  {listing}\n"
            "An explainer page runs no script and fetches nothing. If this markup came\n"
            "from the source document, describe what it does instead of copying it."
        )


def restrict(path, mode):
    """Explainer pages hold internal document content, so keep them owner-only."""
    try:
        os.chmod(path, mode)
    except OSError:
        pass


def fill(template, values):
    """Substitute {{NAME}} in one pass, so inserted content is never rescanned."""
    return re.sub(r"\{\{(\w+)\}\}", lambda m: values.get(m.group(1), m.group(0)), template)


def source_anchor(url, label):
    scheme = urlparse(url).scheme.lower()
    if scheme not in ("http", "https"):
        fail(f"--source-url must be http or https, got {scheme or 'no scheme'!r}")
    return f'<a href="{html.escape(url, quote=True)}">{html.escape(label)}</a>'


def screenshot(page, target, theme, width, height):
    """Render `page` with a forced theme. Returns True when Chrome produced a file."""
    forced = page.parent / f".preview/_{theme}.html"
    forced.write_text(
        page.read_text(encoding="utf-8").replace(
            '<html lang="en">', f'<html lang="en" data-theme="{theme}">', 1
        ),
        encoding="utf-8",
    )
    restrict(forced, FILE_MODE)
    try:
        subprocess.run(
            [CHROME, "--headless", "--disable-gpu", "--hide-scrollbars",
             "--force-color-profile=srgb", f"--window-size={width},{height}",
             f"--screenshot={target}", forced.as_uri()],
            capture_output=True,
            timeout=90,
        )
    except subprocess.TimeoutExpired:
        print(f"warning: Chrome timed out rendering the {theme} preview", file=sys.stderr)
        return False
    finally:
        forced.unlink(missing_ok=True)
    if target.exists():
        restrict(target, FILE_MODE)
        return True
    return False


def cmd_build(args):
    shell = ASSETS / "shell.html"
    css = ASSETS / "page.css"
    for path in (shell, css):
        if not path.is_file():
            fail(f"missing asset {path}")

    content_path = pathlib.Path(args.content)
    if not content_path.is_file():
        fail(f"content fragment not found: {content_path}")

    content = content_path.read_text(encoding="utf-8")
    assert_inert("the content fragment", content)
    assert_inert("the lede", args.lede)

    source = source_anchor(args.source_url, args.source_label)

    slug = re.sub(r"[^a-z0-9]+", "-", args.slug.lower()).strip("-") or "explainer"
    date = datetime.date.today().isoformat()
    out_dir = OUT_ROOT / f"{date}-{slug}"
    preview = out_dir / ".preview"
    preview.mkdir(parents=True, exist_ok=True)
    for directory in (OUT_ROOT, out_dir, preview):
        restrict(directory, DIR_MODE)

    page = fill(shell.read_text(encoding="utf-8"), {
        "CSS": css.read_text(encoding="utf-8"),
        "TITLE": html.escape(args.title),
        "LEDE": html.escape(args.lede),
        "SOURCE": source,
        "DATE": date,
        "CONTENT": content,
    })

    index = out_dir / "index.html"
    index.write_text(page, encoding="utf-8")
    restrict(index, FILE_MODE)

    shots = []
    if pathlib.Path(CHROME).exists():
        for theme in ("light", "dark"):
            target = preview / f"{theme}.png"
            if screenshot(index, target, theme, args.width, args.height):
                shots.append(target)
    else:
        print(f"warning: Chrome not found at {CHROME}, skipping screenshots", file=sys.stderr)

    print(index)
    for shot in shots:
        print(shot)


def cmd_open(args):
    page = pathlib.Path(args.page).expanduser()
    if not page.is_file():
        fail(f"page not found: {page}")
    subprocess.run(["open", "-a", "Google Chrome", str(page)], check=True)
    print(f"opened {page}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="cmd", required=True)

    b = sub.add_parser("build", help="assemble the page and screenshot it")
    b.add_argument("--content", required=True, help="HTML fragment holding the sections")
    b.add_argument("--title", required=True)
    b.add_argument("--lede", required=True, help="one sentence stating the core claim")
    b.add_argument("--source-url", required=True, help="the link being explained")
    b.add_argument("--source-label", required=True, help="how to name the source in the page")
    b.add_argument("--slug", required=True)
    b.add_argument("--width", type=int, default=960)
    b.add_argument("--height", type=int, default=3000)
    b.set_defaults(func=cmd_build)

    o = sub.add_parser("open", help="open a built page in Chrome")
    o.add_argument("page")
    o.set_defaults(func=cmd_open)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
