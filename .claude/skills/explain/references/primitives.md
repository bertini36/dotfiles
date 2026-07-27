# Diagram primitives

Exact markup for every primitive in `assets/page.css`. Compose from these rather than inventing structure, so pages share one house style.

Every primitive is theme-aware already. Never add inline `style` for colour.

## Colour variables

Paint with these only, in CSS and in SVG alike.

| Variable | Use |
|---|---|
| `--ink` | body text |
| `--muted` | secondary text, axis labels, gridlines |
| `--bg` | page background, and text sitting on a filled `--accent` shape |
| `--panel` | card and box fills |
| `--line` | borders, rules, inactive strokes |
| `--accent` | the thing the reader should look at first |
| `--accent-soft` | a highlighted region's fill |
| `--ok`, `--ok-soft` | the healthy or chosen option |
| `--warn`, `--warn-soft` | the risk, the limit, the deprecated path |

Use `--accent` sparingly. When everything is accented, nothing is.

## flow, a sequential process

```html
<div class="flow">
  <div class="step">
    <span class="k">1</span>
    <span class="v">User deletes a scenario</span>
    <span class="n">webapp action</span>
  </div>
  <div class="step">
    <span class="k">2</span>
    <span class="v">Row dropped in Postgres</span>
    <span class="n">transactional</span>
  </div>
</div>
```

`.k` is the step marker, `.v` the action, `.n` an optional qualifier. Chevrons are drawn by `clip-path`, so the first and last steps square off automatically. Keep to 5 steps; beyond that use `.timeline`.

## layers, one thing sitting on another

```html
<div class="layers">
  <div class="layer"><span class="name">Webapp</span><span class="desc">Reads variable values</span></div>
  <div class="layer hot"><span class="name">Redis DAFS</span><span class="desc">87 percent full, nothing evictable</span></div>
  <div class="layer"><span class="name">Postgres</span><span class="desc">Source of truth</span></div>
</div>
```

Order top to bottom as the reader would draw it. Add `hot` to the one layer where the problem lives.

## cards, the concepts

```html
<div class="cards">
  <div class="card">
    <div class="term">volatile-lru</div>
    <div class="mean">Evicts only keys carrying a TTL. Engine keys have none, so writes fail at 100 percent while reads keep working.</div>
  </div>
</div>
```

`.term` is the exact name the source uses, `.mean` is plain language. 3 to 6 cards; a seventh means two of them are the same idea.

## stats, the numbers

```html
<div class="stats">
  <div class="stat"><b>87%</b><span>memory used</span></div>
  <div class="stat"><b>18.4<small> GiB</small></b><span>reclaimable</span></div>
</div>
```

Units go in `<small>` so the figure dominates. Only for figures the source states.

## compare, two options or before against after

```html
<div class="compare">
  <div class="side bad">
    <h4>Delete orphans now</h4>
    <ul><li>Frees 18.4 GiB</li><li>Irreversible on a Friday</li></ul>
  </div>
  <div class="side good">
    <h4>Scale the instance</h4>
    <ul><li>Under a minute of downtime</li><li>Costs $1.3k a month</li></ul>
  </div>
</div>
```

`good` and `bad` are optional. Omit both when the comparison is genuinely neutral.

## timeline, ordered in time

```html
<ul class="timeline">
  <li class="mark">
    <span class="when">12:00 CEST</span>
    <span class="what">Datadog fires on Redis memory</span>
    <span class="why">78 GB of 100, up 15 percent in 45 minutes</span>
  </li>
  <li>
    <span class="when">17:15</span>
    <span class="what">Upgrade window opens</span>
  </li>
</ul>
```

Add `mark` to the moments that matter. `.why` is optional.

## tree, nested structure

```html
<ul class="tree">
  <li><span class="node">variable_daf:{org}</span> <span class="gloss">per organisation</span>
    <ul>
      <li><span class="node">:{module}</span> <span class="gloss">orphaned when the module dies</span></li>
    </ul>
  </li>
</ul>
```

Good for key schemas, config shapes, and file layouts. Two levels read well, three is the limit.

## swimlane, several actors acting in turn

```html
<div class="swimlane">
  <div class="lane">
    <div class="who">Engine</div>
    <div class="acts"><span class="act">Stops the DAS</span><span class="act key">Takes a snapshot</span></div>
  </div>
  <div class="lane">
    <div class="who">Infra</div>
    <div class="acts"><span class="act">Applies the instance change</span></div>
  </div>
</div>
```

Steps read left to right within a lane. `key` marks the critical action.

## Callouts, tables, open questions

```html
<div class="note"><p>Reads keep working at 100 percent memory. Only writes fail.</p></div>
<div class="warn"><p>One doubling of headroom remains.</p></div>

<table>
  <tr><th>Origin</th><th>Keys</th><th>Size</th></tr>
  <tr><td>Deleted scenarios</td><td class="num">3,508,870</td><td class="num">13.1 GiB</td></tr>
</table>

<ul class="open">
  <li>Who owns deleting the dead DAF write path now that it targets S3?</li>
</ul>
```

Put `num` on numeric cells so digits align.

## Inline SVG

For proportion and for non-grid topology. Conventions:

- Always set `viewBox`, never `width` or `height`. The stylesheet makes SVG fluid.
- Paint with `fill="var(--accent)"` and friends, so the diagram follows the theme.
- Keep text at 11 to 13 px in viewBox units and set it in `var(--sans)`.
- Label directly on the shape. A legend forces the eye to bounce.
- Give the root `role="img"` and an `aria-label` stating what the diagram shows.
- Nudge a wide diagram to `viewBox="0 0 820 H"`, which matches the content column.

A proportion bar, the most useful shape:

```html
<figure>
<svg viewBox="0 0 820 76" role="img" aria-label="Orphans hold a third of the keyspace">
  <text x="0" y="14" fill="var(--muted)" font-size="12" font-family="var(--sans)">KEYSPACE 12.75M keys</text>
  <rect x="0" y="24" width="820" height="44" rx="6" fill="var(--panel)" stroke="var(--line)"/>
  <rect x="1" y="25" width="271" height="42" rx="5" fill="var(--accent-soft)" stroke="var(--accent)"/>
  <text x="16" y="44" fill="var(--accent)" font-size="13" font-weight="600" font-family="var(--sans)">4.77M orphans</text>
  <text x="16" y="60" fill="var(--accent)" font-size="11" font-family="var(--sans)">18.4 GiB reclaimable</text>
  <text x="290" y="52" fill="var(--ink)" font-size="13" font-family="var(--sans)">7.98M live keys</text>
</svg>
<figcaption>Deleted scenarios alone account for 13.1 GiB of the reclaimable total.</figcaption>
</figure>
```

Arrowheads need a `marker` whose `path` carries an explicit `fill`, because `currentColor` does not inherit into marker content reliably:

```html
<defs>
  <marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto">
    <path d="M0 0 L10 5 L0 10 z" fill="var(--muted)"/>
  </marker>
</defs>
<line x1="0" y1="20" x2="200" y2="20" stroke="var(--muted)" stroke-width="2" marker-end="url(#arrow)"/>
```

Give every `marker` and gradient a unique `id` when a page holds more than one SVG.
