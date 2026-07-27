#!/usr/bin/env python3
"""Assemble an explainer page, screenshot it for review, and open it in Chrome.

Build the page, then look at the screenshots before opening anything:

    build.py build --content frag.html --title "..." --lede "..." \
             --source '<a href="URL">LABEL</a>' --slug my-topic
    build.py open ~/explains/2026-07-27-my-topic/index.html

`build` writes index.html plus .preview/light.png and .preview/dark.png.
"""

import argparse
import datetime
import html
import pathlib
import re
import shutil
import subprocess
import sys

ASSETS = pathlib.Path(__file__).resolve().parent.parent / "assets"
OUT_ROOT = pathlib.Path.home() / "explains"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"


def fail(message):
    sys.exit(f"build.py: {message}")


def fill(template, values):
    """Substitute {{NAME}} in one pass, so inserted content is never rescanned."""
    return re.sub(r"\{\{(\w+)\}\}", lambda m: values.get(m.group(1), m.group(0)), template)


def screenshot(page, target, theme, width, height):
    """Render `page` with a forced theme. Returns True when Chrome produced a file."""
    forced = page.parent / f".preview/_{theme}.html"
    forced.write_text(
        page.read_text(encoding="utf-8").replace(
            '<html lang="en">', f'<html lang="en" data-theme="{theme}">', 1
        ),
        encoding="utf-8",
    )
    subprocess.run(
        [CHROME, "--headless", "--disable-gpu", "--hide-scrollbars",
         "--force-color-profile=srgb", f"--window-size={width},{height}",
         f"--screenshot={target}", forced.as_uri()],
        capture_output=True,
        timeout=90,
    )
    forced.unlink(missing_ok=True)
    return target.exists()


def cmd_build(args):
    shell = ASSETS / "shell.html"
    css = ASSETS / "page.css"
    for path in (shell, css):
        if not path.is_file():
            fail(f"missing asset {path}")

    content = pathlib.Path(args.content)
    if not content.is_file():
        fail(f"content fragment not found: {content}")

    slug = re.sub(r"[^a-z0-9]+", "-", args.slug.lower()).strip("-") or "explainer"
    date = datetime.date.today().isoformat()
    out_dir = OUT_ROOT / f"{date}-{slug}"
    (out_dir / ".preview").mkdir(parents=True, exist_ok=True)

    page = fill(shell.read_text(encoding="utf-8"), {
        "CSS": css.read_text(encoding="utf-8"),
        "TITLE": html.escape(args.title),
        "LEDE": args.lede,
        "SOURCE": args.source,
        "DATE": date,
        "CONTENT": content.read_text(encoding="utf-8"),
    })

    index = out_dir / "index.html"
    index.write_text(page, encoding="utf-8")

    shots = []
    if shutil.which(CHROME) or pathlib.Path(CHROME).exists():
        for theme in ("light", "dark"):
            target = out_dir / ".preview" / f"{theme}.png"
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
    b.add_argument("--source", required=True, help="source attribution, may contain an <a>")
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
