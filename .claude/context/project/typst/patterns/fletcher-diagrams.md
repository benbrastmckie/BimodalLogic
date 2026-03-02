# Fletcher Diagram Patterns

**Created**: 2026-02-25
**Purpose**: Reference for using the Fletcher package for flowcharts and dependency graphs in Typst

---

## Overview

Fletcher is a Typst package for creating diagrams with arrows, boxes, and edges. It is built on CeTZ and provides high-level abstractions for flowcharts, commutative diagrams, and dependency graphs.

### Package Import

```typst
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
```

**Version pinning**: Always pin the version to avoid breaking changes. As of 2026-02, version 0.5.8 is stable.

---

## Core API

### diagram()

Container for all diagram elements.

```typst
#fletcher.diagram(
  cell-size: (14mm, 10mm),    // Grid cell dimensions
  spacing: (12pt, 18pt),      // Gap between cells (x, y)
  node-stroke: 0.5pt,         // Default node border
  node-fill: none,            // Default node fill
  node-corner-radius: 3pt,    // Default corner radius
  edge-stroke: 0.7pt,         // Line thickness
  edge-corner-radius: 5pt,    // Rounded edge corners
  mark-scale: 80%,            // Arrow head size

  // nodes and edges go here
)
```

### node()

Creates a labeled box at a grid position.

```typst
node(
  (row, col),                 // Grid position (row, column)
  [Content],                  // Label content
  name: <label>,              // Named reference for edges
  shape: rect,                // rect, circle, diamond, pill, hexagon
  fill: blue.lighten(80%),    // Background color
  stroke: 0.5pt + blue,       // Border (thickness + color)
  corner-radius: 4pt,         // Rounded corners
  width: 2.8cm,               // Fixed width
  height: auto,               // Height (auto by default)
  inset: 6pt,                 // Internal padding
)
```

**Grid coordinates**: `(row, col)` where row increases downward, column increases rightward. Fractional values work for fine positioning.

### edge()

Connects nodes with arrows.

```typst
edge(
  <from>,                     // Source node name
  <to>,                       // Target node name
  "->",                       // Arrow direction marker
  stroke: 0.7pt,              // Line styling
  label: [text],              // Edge label (optional)
  label-pos: 0.5,             // Position along edge (0-1)
  bend: 0deg,                 // Curve angle
)
```

**Arrow markers**:
- `"->"` - Arrow to target
- `"<-"` - Arrow from target
- `"<->"` - Bidirectional
- `"--"` - No arrows (plain line)

**Dashed edges** for partial dependencies:
```typst
edge(<ch1>, <ch4>, "->", stroke: (dash: "dashed"))
```

---

## Common Patterns

### Color-Coded Node Groups

For dependency diagrams with grouped nodes (e.g., book parts):

```typst
#let chapter-node(pos, number, title, name, part: 1) = {
  let colors = (
    blue.lighten(80%),    // Part I
    green.lighten(80%),   // Part II
    orange.lighten(80%)   // Part III
  )
  node(
    pos,
    align(center)[*Ch #number* \ #text(size: 0.85em)[#title]],
    name: name,
    fill: colors.at(part - 1),
    stroke: 0.5pt + colors.at(part - 1).darken(40%),
    corner-radius: 4pt,
    width: 2.8cm,
    inset: 6pt,
  )
}
```

### Dependency Flowchart

For chapter/topic dependency visualization:

```typst
#let topic-dependency-diagram() = {
  figure(
    fletcher.diagram(
      spacing: (14pt, 20pt),
      edge-stroke: 0.7pt,
      edge-corner-radius: 5pt,
      mark-scale: 80%,

      // Part I: Foundations (blue)
      chapter-node((0, 0), 1, [Type Theory], <ch1>, part: 1),
      chapter-node((0, 1), 2, [Order Theory], <ch2>, part: 1),
      chapter-node((0, 2), 3, [Categories], <ch3>, part: 1),

      // Part II: Algebraic (green)
      chapter-node((1, 0.5), 4, [Groups], <ch4>, part: 2),
      chapter-node((1, 1.5), 5, [Lattices], <ch5>, part: 2),

      // Solid edges = required dependencies
      edge(<ch1>, <ch2>, "->"),
      edge(<ch1>, <ch3>, "->"),
      edge(<ch2>, <ch5>, "->"),

      // Dashed edges = partial dependencies
      edge(<ch1>, <ch4>, "->", stroke: (dash: "dashed")),

      // Labeled edges for section-specific deps
      edge(<ch2>, <ch4>, "->", label: [Sec 4.4], label-pos: 0.6),
    ),
    caption: [Topic Dependencies. Solid arrows = required; dashed = partial.]
  )
}
```

### Edge Routing

Fletcher auto-routes edges, but manual hints help with complex diagrams:

```typst
// Force edge to go right then down
edge(<a>, <b>, "->", vertices: ((0, 1), (1, 1)))

// Bend edge to avoid overlaps
edge(<a>, <c>, "->", bend: 20deg)
```

---

## Accessibility Considerations

### Stroke Differentiation

For colorblind readers, distinguish edges by stroke style, not just color:

```typst
// Required dependency: solid line
edge(<ch1>, <ch2>, "->", stroke: 0.8pt)

// Partial dependency: dashed line
edge(<ch1>, <ch4>, "->", stroke: (dash: "dashed", thickness: 0.8pt))

// Optional dependency: dotted line
edge(<ch1>, <ch7>, "->", stroke: (dash: "dotted", thickness: 0.8pt))
```

### Caption Descriptions

Always explain visual encoding in the figure caption:

```typst
caption: [Solid arrows indicate required prerequisites;
          dashed arrows indicate partial dependencies.
          Colors: blue (Foundations), green (Algebraic),
          orange (Metric).]
```

### Grayscale Testing

Verify diagrams remain readable in grayscale by:
1. Using distinct stroke styles (solid/dashed/dotted)
2. Ensuring sufficient contrast between fill colors
3. Including redundant text labels where helpful

---

## Legend Components

Complex diagrams benefit from explicit legends that explain visual encoding. Legends improve accessibility by making color and stroke meanings explicit rather than relying solely on captions.

### Dependency Diagram Legend

A reusable legend component for dependency diagrams:

```typst
#let dependency-legend() = {
  block(
    width: 100%,
    stroke: 0.5pt + gray.lighten(40%),
    inset: 8pt,
    radius: 4pt,
  )[
    *Legend*
    #v(4pt)
    #grid(
      columns: (auto, 1fr, auto, 1fr),
      gutter: 8pt,
      // Edge types
      line(length: 1.5cm, stroke: 0.7pt), [Required],
      line(length: 1.5cm, stroke: (dash: "dashed", thickness: 0.7pt)), [Partial],
      // Part colors
      rect(width: 1em, height: 1em, fill: blue.lighten(80%), stroke: 0.5pt), [Part I: Foundations],
      rect(width: 1em, height: 1em, fill: green.lighten(80%), stroke: 0.5pt), [Part II: Algebraic],
      rect(width: 1em, height: 1em, fill: orange.lighten(80%), stroke: 0.5pt), [Part III: Metric],
    )
  ]
}
```

### Usage

Place the legend below or beside the main diagram:

```typst
#figure(
  stack(
    dir: ttb,
    spacing: 12pt,
    topic-dependency-diagram(),
    dependency-legend(),
  ),
  caption: [Topic Dependency Map with legend.]
)
```

### Customization Notes

- **Edge types**: Match `line()` stroke styles to your actual edge strokes (solid, dashed, dotted)
- **Node colors**: Match `rect()` fills to your actual node fills
- **Grid layout**: Adjust `columns` for more/fewer legend items
- **Labels**: Keep legend labels consistent with figure caption terminology

---

## Reader Pathway Guides

For textbooks with multiple reading paths, a sidebar guide helps readers identify their track through the material without cluttering the main diagram.

### Pathway Sidebar Box

A dedicated box listing reading paths with chapter sequences:

```typst
#let reader-pathways-box() = {
  block(
    width: 100%,
    stroke: 0.5pt + gray.lighten(40%),
    inset: 8pt,
    radius: 4pt,
  )[
    *Reader Pathways*
    #v(4pt)
    - *Minimal* (Manual Ch 2-3): 1 -> 2 -> 5 -> 6
    - *With Dynamics* (Manual Ch 4): + Ch 4
    - *Categorical* (Manual Ch 6): 1 -> 3 -> 4 -> 8
    - *Full Spatial* (All): Chapters 1-9
  ]
}
```

### Usage

Place the pathway box before or after the dependency diagram:

```typst
#figure(
  stack(
    dir: ttb,
    spacing: 12pt,
    topic-dependency-diagram(),
    grid(
      columns: (1fr, 1fr),
      gutter: 12pt,
      dependency-legend(),
      reader-pathways-box(),
    ),
  ),
  caption: [Topic Dependency Map with legend and reader pathways.]
)
```

### Design Decision

The sidebar approach (Option C) was chosen over alternatives:

- **Option A (Separate highlighted diagrams)**: Would duplicate the diagram multiple times with different highlighting, increasing document length and maintenance burden
- **Option B (Multi-color overlay highlighting)**: Would create visual clutter with overlapping colors on the same diagram, reducing readability

The sidebar box keeps the main diagram clean while providing clear guidance for different reader tracks. Pathway sequences use simple arrow notation (`1 -> 2 -> 5`) that mirrors the diagram's edge semantics.

---

## Integration with CeTZ

Fletcher builds on CeTZ, so both can coexist. The project's `template.typ` already imports CeTZ:

```typst
#import "@preview/cetz:0.3.4"
```

Fletcher diagrams can be placed inside CeTZ canvases if needed, though this is rarely necessary. For simple flowcharts, use Fletcher directly.

---

## Examples in Project

### Logos Appendix

The `typst/appendix/` uses Fletcher for the Topic Dependency Map in the preface:

- Import: `template.typ` imports Fletcher
- Usage: `topic-dependency-diagram()` function
- Location: `chapters/00-preface.typ`

### Related CeTZ Utilities

Existing CeTZ-based diagrams in `template.typ`:
- `hasse-diagram()` - Generic Hasse diagrams for posets
- `four-bilattice-diagram()` - FOUR bilattice visualization
- `commutative-diagram()` - Category theory diagrams
- `naturality-square()` - Naturality squares

---

## References

- [Fletcher on Typst Universe](https://typst.app/universe/package/fletcher/)
- [Fletcher GitHub](https://github.com/Jollywatt/typst-fletcher)
- [CeTZ Documentation](https://cetz-package.github.io/)
