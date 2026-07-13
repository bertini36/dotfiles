---
name: tldr
description: Use when the user runs /tldr with a URL or asks for a quick bullet summary of an article, blog post, YouTube video, or any web page.
---

# TL;DR

Fetch the URL's content and return a fixed-shape summary: a title line plus 5-7 single-sentence bullets. Nothing else.

## Getting the content

1. **Article / blog / generic page**: WebFetch the URL. If blocked (paywall, JS-only page, 403), retry with `curl -sL <url>`; if still empty, WebSearch the page title and summarize from coverage, noting in the title line that the source was indirect.
2. **YouTube** (`youtube.com`, `youtu.be`): WebFetch the video page for title and description. If `yt-dlp` is installed, pull the transcript with `yt-dlp --skip-download --write-auto-subs --sub-langs "en.*" -o "<scratchpad>/tldr" <url>` and Read the subtitle file. Otherwise summarize from title, description, and a WebSearch of the video title.
3. **PDF**: download to the scratchpad with `curl -sL`, then Read it.

## Output contract

The entire response is:

```
**<Title>** (<domain>)

- <sentence>
- <sentence>
...
```

- Exactly 5 bullets.
- Each bullet is one complete sentence stating one key point.
- Bullets are ordered by importance: the first bullet alone should work as a one-line TLDR.
- Keep numbers, names, and dates concrete (say "scored 54, fourth overall", not "scored well").
- A flat list only: no headers, no sections, no nested bullets, no intro or closing text, no commentary about how the content was fetched.

If the content cannot be retrieved at all, reply with one line saying so instead of guessing.
