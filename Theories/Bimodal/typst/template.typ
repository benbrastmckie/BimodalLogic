// ============================================================================
// template.typ
// Shared template with theorem environments for all chapters
//
// Styling follows the AMS/journal aesthetic: austere, black-only body text,
// no background colors on theorem environments. Link colors (URLblue) are
// preserved for digital usability.
// ============================================================================

#import "@preview/thmbox:0.3.0" as thmbox
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "notation/bimodal-notation.typ": *

// ============================================================================
// Color Definitions
// ============================================================================

// URLblue color for hyperlinks (matches LogosReference.tex)
#let URLblue = rgb(30, 144, 255)  // Light blue (Dodger Blue)

// ============================================================================
// thmbox initialization function
// ============================================================================

// thmbox-init sets up the theorem environment system
#let thmbox-show = thmbox.thmbox-init()

// ============================================================================
// Custom Theorem Environment Styling
// ============================================================================

// Journal-style theorem environments - AMS aesthetic with no background colors
// Link colors are preserved separately in BimodalReference.typ (URLblue)
//
// AMS convention:
// - Theorems/lemmas: italic body text (plain style)
// - Definitions: upright body, defined terms in italic (definition style)
// - Remarks: upright body, less prominent (remark style)

#let theorem-style = (
  fill: none,
  stroke: none,
  bodyfmt: it => emph(it),  // Italic body per AMS plain style
)

#let definition-style = (
  fill: none,
  stroke: none,
  // Upright body (thmbox default) per AMS definition style
)

#let axiom-style = (
  fill: none,
  stroke: none,
  bodyfmt: it => emph(it),  // Italic body like theorems
)

#let remark-style = (
  fill: none,
  stroke: none,
  // Upright body (thmbox default) per AMS remark style
)

// ============================================================================
// Theorem Environments (using thmbox predefined environments with custom styling)
// ============================================================================

// Re-export thmbox environments with custom styling
// Chapters use: definition, theorem, lemma, axiom, remark, proof
#let definition = thmbox.definition.with(..definition-style)
#let theorem = thmbox.theorem.with(..theorem-style)
#let lemma = thmbox.lemma.with(..theorem-style)
#let axiom = thmbox.axiom.with(..axiom-style)
#let remark = thmbox.remark.with(..remark-style)
#let proof = thmbox.proof

// ============================================================================
// Ported Environments (from Logos manual template.typ:54-60,93-96,111-130,
// 136-171,183-216,219-250) -- extends the theorem-environment vocabulary
// without touching definition/theorem/lemma/axiom/remark/proof above.
// ============================================================================

#let example-style = (
  fill: none,
  stroke: none,
  // Upright body, matches remark-style
)

#let proposition = thmbox.proposition.with(..theorem-style)
#let corollary = thmbox.corollary.with(..theorem-style)
#let example = thmbox.example.with(..example-style)
#let notation-env = thmbox.remark.with(title: "Notation", ..remark-style)

// --- Lean source / reference helpers ---

// Lean source reference block (module + declaration name, rendered as a
// blockquote-style raw line). Usage: #leansrc("Metalogic.Soundness", "soundness")
#let leansrc(module, name) = block(above: 1.0em, below: 1.0em, raw(block: true, "> " + module + "." + name + "."))

// Inline Lean identifier reference (monospace, no path).
#let leanref(name) = raw(name)

// --- Chapter header (dependencies / Logos-connection metadata block) ---

#let chapter-header(description: none, dependencies: none, connections: none) = {
  set par(first-line-indent: 0em)
  block(spacing: 0.8em)[
    #if description != none {
      block(below: 1.2em)[
        #emph[#description]
      ]
    }
    #if dependencies != none {
      block(above: 0.4em, below: 1.0em)[
        #strong[Dependencies]: #dependencies
      ]
    }
    #if connections != none {
      block(above: 0.4em, below: 1.0em)[
        #strong[Logos Connection]: #connections
      ]
    }
  ]
}

// --- Items list environment (consistent bullet/enum styling) ---

#let items(body) = block(
  above: 0.8em,
  below: 0.8em,
)[
  #set list(marker: [--], indent: 0.5em, body-indent: 0.5em, spacing: 0.65em)
  #set enum(numbering: "(1)", indent: 0.5em, body-indent: 0.5em, spacing: 0.65em)
  #body
]

#let item(body) = block(spacing: 0.65em)[
  -- #body
]

// --- Principles list environment (auto-labeled axiom/principle lists) ---

#let principles(body) = block(
  above: 0.8em,
  below: 0.8em,
  body
)

#let principle(number, name: none, body) = {
  let label-text = if name != none {
    "pr-" + lower(name.replace(" ", "-").replace("'", ""))
  } else {
    none
  }

  block(spacing: 0.8em)[
    #sym.bullet #h(0.3em) *#number* #body #h(1fr) #if name != none { [(#name)] }
    #if label-text != none { label(label-text) }
  ]
}

// Note: uses `link` (not `ref`) because the target is an inline sequence
// inside a #principle block, not a headed/figure/equation element that
// typst's `ref` can number -- `link` to a label resolves generically.
#let pr(name) = {
  let label-text = "pr-" + lower(name.replace(" ", "-").replace("'", ""))
  link(label(label-text))[(#name)]
}

// --- Fletcher diagram helpers (extension/dependency node boxes) ---

#let extension-colors = (
  foundation: blue.lighten(80%),
  modular: gray.lighten(85%),
  projection: gray.lighten(85%),
)

#let extension-node(pos, title, operators, kind: "foundation") = {
  let fill-color = if kind == "foundation" {
    blue.lighten(85%)
  } else {
    white
  }
  let stroke-color = gray.darken(20%)
  node(
    pos,
    align(center)[*#title* \ #text(size: 0.8em)[#operators]],
    fill: fill-color,
    stroke: 0.5pt + stroke-color,
    corner-radius: 4pt,
    inset: 8pt,
  )
}

// ============================================================================
// Part Divider Page (Bimodal-specific)
//
// Full-page divider for the book's part structure: part number, title, and
// a short scope paragraph.
// ============================================================================

#let part-divider(number, title, scope) = {
  page(numbering: none)[
    #v(1fr)
    #align(center)[
      #text(size: 12pt, tracking: 2pt)[PART #number]
      #v(0.5cm)
      #text(size: 22pt, weight: "bold")[#title]
      #v(1cm)
      #block(width: 80%)[
        #set par(first-line-indent: 0em, justify: true)
        #scope
      ]
    ]
    #v(1.5fr)
  ]
}
