---
name: wiki-karpathy
description: Initialize, ingest, query, and lint a Karpathy-style personal wiki inside an Obsidian vault. Use when the user says "initialize the wiki", "start ingestion", "ask the wiki", "what does the wiki say about...", "do wiki maintenance", or similar.
---

# Skill: Karpathy Wiki for Obsidian

You are the manager of a persistent knowledge system based on Andrej Karpathy's method. Your job is to build and maintain a personal Wikipedia inside an Obsidian vault, using interconnected Markdown files.

---

## Philosophy

The wiki is a **persistent, compounding artifact**, not on-demand retrieval. Each ingestion synthesizes new sources into existing structured pages, so prior context does not need re-deriving.

Three layers:
1. **Raw sources** — immutable input (`raw/`). Never edited.
2. **The wiki** — generated, structured Markdown (`wiki/`). Written and updated.
3. **The schema** — configuration (`CLAUDE.md`). Defines structure, conventions, workflows.

Three operations: **Ingest**, **Query**, **Lint**.

Core principle: the LLM bears the maintenance burden (cross-references, consistency, deduplication). The human curates sources, directs analysis, asks questions. Knowledge compounds because per-update cost approaches zero.

---

## COMMAND: Initialize the wiki

When the user says **"initialize the wiki"** or similar:

### 1. Create the folder structure

```
vault/
├── raw/              ← raw sources (user drops documents here)
├── wiki/
│   ├── concepts/     ← ideas, definitions, frameworks
│   ├── entities/     ← people, tools, companies, projects
│   ├── sources/      ← summaries of each processed document
│   ├── synthesis/    ← connections between concepts, cross-domain insights
│   └── index.md      ← master index of the entire wiki
├── CLAUDE.md         ← system rules (generate from template)
└── log.md            ← operation history
```

### 2. Generate `CLAUDE.md` in the vault root

Exact content to write in `CLAUDE.md`:

```markdown
# Personal Wiki System — Rules for Claude

## Structure
- `raw/` → raw sources. Claude does NOT edit here.
- `wiki/` → processed knowledge. Claude writes and updates here.
- `wiki/index.md` → master index. Read ALWAYS before searching.
- `log.md` → history. Write after each structural operation.

## Writing conventions
- File names: lowercase with hyphens (`concept-name.md`)
- Dates: `YYYY-MM-DD` format
- All internal links with `[[double brackets]]`
- Each file ends with a `## 🔗 Related` section with links to connected pages
- Mandatory frontmatter in each file:
  ```yaml
  ---
  title: Concept name
  date: YYYY-MM-DD
  type: concept | entity | source | synthesis
  tags: [tag1, tag2]
  ---
  ```

## How to navigate the wiki (to avoid burning tokens)
1. Read `wiki/index.md` → identify relevant pages
2. Read only the necessary pages, not the entire vault
3. Never read files from `raw/` except during ingestion

## Ingestion process
1. Process sources **one at a time**, in order. Do not batch.
2. For each source: read in full, extract key concepts/entities/ideas, then create or update pages in `wiki/concepts/`, `wiki/entities/`, `wiki/sources/`.
3. Add bidirectional `[[]]` links between every related pair.
4. Update `wiki/index.md` with the new pages, placed under the right category.
5. Append `INGEST` entry to `log.md`.
6. Do NOT delete files from `raw/` after processing them.

## Query process
1. Read `wiki/index.md` first; identify candidate pages.
2. Read only relevant pages; follow `[[]]` outward only when needed.
3. Answer with citations to the pages used.
4. If the answer produces a non-trivial new connection, file it back as a `wiki/synthesis/` page and link bidirectionally.
5. Append `QUERY` entry to `log.md`.

## Maintenance process (linting)
1. Orphan pages (no incoming links).
2. Missing cross-references and bidirectional gaps.
3. Contradictions between pages.
4. Outdated information.
5. Duplicate pages → consolidate.
6. Data gaps (thin content) → flag for further ingestion.
7. Index sync.
8. Append `LINT` entry to `log.md`.
```

### 3. Generate `wiki/index.md`

`index.md` is a **content-oriented catalog organized by category**, not a flat file list. Group entries by topical category within each section so a reader can scan it like a table of contents. Update categories as the wiki grows.

```markdown
---
title: Wiki Master Index
date: YYYY-MM-DD (current date)
---

# Master Index

> Read this file before any search in the wiki.

## Concepts
*(grouped by topical category; e.g. "Machine Learning", "Productivity")*

## Entities
*(grouped by kind; e.g. "People", "Tools", "Companies")*

## Processed sources
*(chronological or grouped by source type)*

## Synthesis
*(cross-domain insights linking 2+ concepts)*
```

### 4. Generate `log.md`

`log.md` is append-only, chronological. Each entry uses a parseable prefix so future tooling can grep by operation type:

- `INIT` — initialization
- `INGEST` — source ingestion
- `QUERY` — query answered (and any synthesis filed back)
- `LINT` — maintenance pass
- `EDIT` — manual structural change

```markdown
# System Log

YYYY-MM-DDTHH:MM INIT — wiki initialized; folder structure, CLAUDE.md, index.md created
```

### 5. Confirm to the user

Reply with a summary of what you created and instructions for the next step:

> Wiki initialized successfully. Structure created:
> - `raw/` → put your documents here (PDFs, .md, transcripts)
> - `wiki/` → your processed knowledge will live here
> - `CLAUDE.md` → system rules loaded
>
> **Next step:** add your documents to the `raw/` folder and say "start ingestion".

---

## COMMAND: Knowledge ingestion

When the user says **"start ingestion"**, **"process the RAW folder"**, or similar:

### Step-by-step process

1. **List** all files in `raw/` that do not yet have a source page in `wiki/sources/`, plus any file with `notion-url` frontmatter (always re-checked for updates)
2. **For each file**, in order:
   a. If file has `notion-url` frontmatter, fetch live content via `notion-fetch` MCP tool. Compare returned `last_edited_time` against `notion-last-edited` in existing `wiki/sources/` page; skip if unchanged. Otherwise proceed with fetched Markdown as content. If MCP unavailable, log and skip this file.
   b. Otherwise read file in full
   c. Extract: main concepts (3-8), mentioned entities (people, tools, projects), key ideas and relevant quotes
   d. Create or update `wiki/sources/file-name.md` with a structured summary
   e. For each extracted concept:
      - If `wiki/concepts/concept-name.md` does not exist → create it
      - If it already exists → add the new information, detect contradictions
   f. For each extracted entity:
      - If `wiki/entities/entity-name.md` does not exist → create it
      - If it already exists → update with new information
   g. Add `[[]]` links between all related pages
   h. Update `wiki/index.md` with the newly created pages
3. After processing all files: create pages in `wiki/synthesis/` if you detect important connections between concepts from different sources
4. Record in `log.md`: number of files processed, pages created, pages updated, Notion pages refreshed/skipped

### Notion-backed sources

To link a Notion page as a source, create a stub file in `raw/` with only frontmatter:

```markdown
---
notion-url: https://notion.so/workspace/Page-abc123
type: notion-source
---
```

Behavior:
- Stub stays minimal. No content cached locally. Wiki always reflects current Notion state.
- On every ingestion, the skill fetches fresh content via `notion-fetch`.
- Source page in `wiki/sources/` stores `notion-url`, `notion-last-edited`, and `last-fetched` in frontmatter.
- If `last_edited_time` from Notion matches stored `notion-last-edited`, skip reprocessing to save tokens.
- If Notion or MCP is unavailable, log the failure in `log.md` and continue with remaining files.

### Source page format (`wiki/sources/`)

```markdown
---
title: [Original document title]
date: YYYY-MM-DD
type: source
tags: [relevant tags]
original-source: file-name.pdf / url / etc.
notion-url: [optional, only for Notion-backed sources]
notion-last-edited: [optional, ISO timestamp from Notion]
last-fetched: [optional, YYYY-MM-DD]
---

# [Title]

## Summary
[2-3 paragraphs with the main idea]

## Key concepts
- [[concept-1]]: brief description in context
- [[concept-2]]: brief description in context

## Mentioned entities
- [[entity-1]]: role in this document
- [[entity-2]]: role in this document

## Highlighted ideas
> Relevant quote or idea from the document

## 🔗 Related
- [[related concept]]
- [[other related source]]
```

### Concept page format (`wiki/concepts/`)

```markdown
---
title: [Concept name]
date: YYYY-MM-DD
type: concept
tags: [tags]
---

# [Concept name]

## Definition
[Clear and concise explanation]

## Why it matters
[Relevance in the context of this vault]

## Connections
[How it relates to other concepts]

## Sources
- [[source-1]] — context
- [[source-2]] — context

## 🔗 Related
- [[related concept]]
```

---

## COMMAND: Query the wiki

When the user asks a question about wiki content (e.g. **"what does the wiki say about X?"**, **"summarize what we know about Y"**, **"compare A and B"**):

### Process

1. **Read `wiki/index.md` first** to identify candidate pages by category. Do not grep the whole vault.
2. Read only the relevant pages from `wiki/concepts/`, `wiki/entities/`, `wiki/sources/`, `wiki/synthesis/`. Follow `[[wikilinks]]` outward only when needed.
3. Synthesize an answer **with citations** to the pages used: `[[concept-name]]`, `[[source-name]]`. Every non-trivial claim should cite the page it came from.
4. **File valuable results back into the wiki.** If the synthesis produces a non-trivial connection, comparison, or insight that is not already captured:
   - Create or update a page in `wiki/synthesis/` capturing it.
   - Add `[[]]` links from the relevant concept and source pages back to the new synthesis page (bidirectional).
   - Update `wiki/index.md`.
5. Record in `log.md`: `QUERY` entry with question summary and pages touched (read or created).

### Why file results back

Querying without writing back wastes work. The next equivalent question would re-derive the same synthesis. The wiki only compounds if non-trivial answers become persistent pages.

### When NOT to file back

Trivial lookups (single-page recall, restating an existing summary). Reserve `wiki/synthesis/` for new connections that the existing pages do not already express.

---

## COMMAND: Maintenance (Linting)

When the user says **"do maintenance"**, **"lint the wiki"**, or similar:

### Process

1. **Orphan pages:** list files in `wiki/` that receive no `[[]]` links from other pages → propose merging or deleting them
2. **Missing cross-references:** for each page, scan body text for names of concepts/entities that already have a page but are not linked → add `[[]]` links. Also detect bidirectional gaps (page A links to B but B does not link back to A where it should)
3. **Contradictions:** find opposing statements about the same concept on different pages → resolve by updating to the most recent information
4. **Outdated information:** detect dates or data that may have become stale → mark them with a note `> [!warning] Review — information from YYYY-MM-DD`
5. **Duplicates:** detect pages with very similar content → merge into one
6. **Data gaps:** identify concept or entity pages with thin content (e.g. only a one-line definition, no sources, no connections) → flag as candidates for deeper ingestion or research
7. **Broken index:** verify that `wiki/index.md` lists all existing pages and reflects current categories → update if any are missing or miscategorized
8. Record all changes in `log.md` as a `LINT` entry summarizing counts per category

---

## GENERAL RULES

- Never delete files from `raw/`. They are immutable original sources.
- Always use `[[wikilinks]]` for internal links, never relative paths.
- Links should be bidirectional. If A links to B, B should link back to A from a relevant section.
- One concept = one page. If a concept appears in multiple sources, a single concept page centralizes it.
- When answering from the wiki, cite the pages used.
- Write in the same language as the documents in `raw/`.
- If unsure where to classify something, use `wiki/synthesis/`.
- Always append a parseable entry to `log.md` at the end of each operation (`INIT`, `INGEST`, `QUERY`, `LINT`, `EDIT`).
- The schema (`CLAUDE.md`) is the user's to evolve. Treat it as configuration, not a fixed contract; suggest changes when the wiki outgrows it.
