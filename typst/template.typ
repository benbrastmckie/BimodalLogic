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

// thmbox's own default sans-fonts/title-fonts is ("New Computer Modern Sans",),
// not installed in this build environment (only the serif "New Computer Modern"
// and "New Computer Modern Math" are), which is what raised the two
// "unknown font family" compile warnings. There is no installed sans
// companion to New Computer Modern; "Noto Sans" is the closest-named match
// but is a variable font, which Typst warns about separately ("variable
// fonts are not currently supported"). "DejaVu Sans" is a real static family
// (separate Regular/Bold/Oblique/BoldOblique files) with no such warning, so
// it is used instead and applied uniformly below so every environment's
// title bar and (where sans is enabled, the thmbox default) body font
// resolve cleanly.
#let thmbox-sans-fonts = ("DejaVu Sans",)

#let theorem-style = (
  fill: none,
  stroke: none,
  bodyfmt: it => emph(it),  // Italic body per AMS plain style
  sans-fonts: thmbox-sans-fonts,
  title-fonts: thmbox-sans-fonts,
)

#let definition-style = (
  fill: none,
  stroke: none,
  // Upright body (thmbox default) per AMS definition style
  sans-fonts: thmbox-sans-fonts,
  title-fonts: thmbox-sans-fonts,
)

#let axiom-style = (
  fill: none,
  stroke: none,
  bodyfmt: it => emph(it),  // Italic body like theorems
  sans-fonts: thmbox-sans-fonts,
  title-fonts: thmbox-sans-fonts,
)

#let remark-style = (
  fill: none,
  stroke: none,
  // Upright body (thmbox default) per AMS remark style
  sans-fonts: thmbox-sans-fonts,
  title-fonts: thmbox-sans-fonts,
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
// proof (unlike the five above) is not built on thmbox's generic box
// constructor and has no sans-fonts/title-fonts parameters of its own -- it
// never raised either warning, and its rest-argument catch-all silently
// absorbs these without using them -- but it is given the same partial-application
// treatment for consistency with every other environment here and as a
// guard against a future thmbox version adding such parameters to it.
#let proof = thmbox.proof.with(sans-fonts: thmbox-sans-fonts, title-fonts: thmbox-sans-fonts)

// ============================================================================
// Ported Environments (from Logos manual template.typ:54-60,93-96,111-130,
// 136-171,183-216,219-250) -- extends the theorem-environment vocabulary
// without touching definition/theorem/lemma/axiom/remark/proof above.
// ============================================================================

#let example-style = (
  fill: none,
  stroke: none,
  // Upright body, matches remark-style
  sans-fonts: thmbox-sans-fonts,
  title-fonts: thmbox-sans-fonts,
)

#let proposition = thmbox.proposition.with(..theorem-style)
#let corollary = thmbox.corollary.with(..theorem-style)
#let example = thmbox.example.with(..example-style)
#let notation-env = thmbox.remark.with(title: "Notation", ..remark-style)

// --- Lean code environment (block excerpts and didactic examples) ---
//
// One environment for every Lean (and JSON/Python/shell) code block in the
// reference manual, in two kinds selected by the `source` argument:
//   - source excerpt (source: (module, name)): quotes the live source,
//     verbatim up to whitespace, docstrings omitted, lines re-broken at
//     whitespace only (never altering a token) to fit the column budget
//     below. Renders the module-qualified label and the code as one
//     unbreakable unit, the label visibly closer to its code (a small
//     fixed gap, lean-code-label-gap) than the code is to the surrounding
//     prose (lean-code-space, the same magnitude on both sides of the
//     whole block).
//   - didactic example (source: none, the default): a worked example
//     written for this manual, no label, same visible family.
// A block's own language (JSON, Python, Lean) is carried by the fence's own
// language tag (json, python, or a bare fence with no tag for Lean) -- the
// environment needs no separate language parameter, since the same fence
// mechanism already selects it and highlighting is disabled uniformly
// below regardless of that tag.
//
// GEOMETRY, decided by rendering candidates against the manual's real
// content rather than by estimating: raw text at lean-code-size (8pt), in
// the explicit font lean-code-font ("DejaVu Sans Mono") -- not raw()'s
// implicit default, whose per-glyph width was measured uneven across the
// manual's Lean unicode operators, making column-budget arithmetic against
// it unreliable. DejaVu Sans Mono was confirmed by a rendered glyph-table
// check to cover every non-ASCII symbol appearing inside a code block
// across the manual (¬ ↑ → ↔ ∀ ∃ ∈ ∧ ≤ ⊆ ⊢ ⊨ □ △ ▽ ◇ ⟨ ⟩ ₁ ₂ Γ Δ σ τ φ ψ)
// with no missing-glyph fallback.
//
// COLUMN BUDGET: lean-code-column-budget (63) monospace columns. This is
// ONE number applied book-wide, not a tiered plain/nested pair, derived
// from the narrowest real case: a block nested inside #example/#definition
// (thmbox's fill:none insets narrow the 343.28pt plain text width to
// 321.28pt there), combined with lean-code-indent's own 1em left inset.
// A rendered boundary sweep of real appendix content at that width found
// 64 columns fit and 65 wraps; 63 keeps a one-column safety margin. Every
// plain top-level block has strictly more headroom at the same budget.
//
// SPACING: lean-code-space (11pt) above and below the whole block, in
// absolute units, not em -- em inside a raw show rule resolves to the 8pt
// code size, not the document's 11pt body size, which would visibly
// undershoot the intended gap.
//
// BREAKABILITY: unbreakable by default (breakable: false); pass
// breakable: true to opt out for a listing too long to fit one page.
//
// HIGHLIGHTING: uniform, black-only, no syntax highlighting for any
// language (set raw(theme: none) applies inside the block's own scope),
// matching the template's stated austere, black-only, no-fills aesthetic.
// Before this decision, JSON/Python rendered auto-highlighted (colored by
// their fence's own lang tag) while Lean rendered plain black in the same
// visual family -- an accident of Typst's default behavior, not a design
// choice; after, all three render identically in black.
//
// SEPARATION: lean-code-indent (1em) left inset, not a left rule -- a rule
// was found, by rendered comparison, to visually compete with thmbox's own
// colored left bar already marking #example/#definition/etc., which reads
// as confusing when a code block sits inside one of those environments (a
// rule inside a rule).
//
// FIDELITY POLICY: an excerpt is verbatim up to whitespace; docstrings are
// omitted; a line exceeding the column budget is re-broken at whitespace
// only, one consistent layout for a declaration (name and parameters, then
// hypotheses, then conclusion), never altering a token.
#let lean-code-size = 8pt
#let lean-code-font = "DejaVu Sans Mono"
#let lean-code-column-budget = 63
#let lean-code-space = 11pt
#let lean-code-indent = 1em
#let lean-code-label-gap = 3pt

// Raw label line only (no block wrapper) -- shared by the standalone
// leansrc() below (kept for typst/FormalFoundations.typ compatibility) and
// by lean-code()'s own source-excerpt kind, which supplies its own
// spacing around it.
#let lean-code-label-raw(module, name) = raw(block: true, theme: none, "> " + (module + "." + name).replace(".", "." + sym.zws) + ".")

#let lean-code(source: none, breakable: false, body) = block(
  above: lean-code-space,
  below: lean-code-space,
  breakable: breakable,
  inset: (left: lean-code-indent),
)[
  #set raw(theme: none)
  #show raw.where(block: true): set text(size: lean-code-size, font: lean-code-font)
  #if source != none [
    #block(below: lean-code-label-gap, lean-code-label-raw(source.at(0), source.at(1)))
  ]
  #body
]

// --- Lean source / reference helpers ---

// Lean source reference block (module + declaration name, rendered as a
// blockquote-style raw line). Usage: #leansrc("Metalogic.Soundness", "soundness")
// Kept exported with this exact two-argument signature for
// typst/FormalFoundations.typ, whose ~67 call sites are attribution-only
// (never followed by a code block) and must keep compiling unchanged. A
// thin wrapper over the same label text lean-code() renders internally.
#let leansrc(module, name) = block(above: 1.0em, below: 1.0em, lean-code-label-raw(module, name))

// Inline Lean identifier reference: same explicit monospace font as the
// lean-code() block environment (lean-code-font), for visual consistency
// between an inline citation of a live declaration and a quoted block
// excerpt -- it marks the name as a deliberate cross-reference rather than
// an arbitrary inline code span. Adopted narrowly: no existing inline
// backtick span in the manual is converted to it, and Check 1 of
// scripts/typst-sync-check.sh keeps resolving every one of them unchanged.
#let leanref(name) = text(font: lean-code-font, raw(name))

// Dotted Lean declaration name as inline raw text, with a zero-width space
// inserted after each "." so a long dotted name wraps at a dot boundary
// instead of overflowing a table cell. Promoted from 03-proof-theory.typ's
// former chapter-local definition (see STYLE.md rule 8); identical in
// behavior to that definition.
#let derivation-tree-rule(name) = raw(name.replace(".", "." + sym.zws))

// --- Generated-data formatting helpers ---

// Thousands-separator for line counts (max value in practice is a handful of
// digits, but this handles any width via a single recursive comma
// insertion). Promoted from p4-proof-automation.typ's former chapter-local
// definition (see STYLE.md rule 8); identical in behavior to that
// definition.
#let fmt-lines(n) = {
  let s = str(n)
  if s.len() > 3 {
    fmt-lines(int(s.slice(0, s.len() - 3))) + "," + s.slice(s.len() - 3)
  } else {
    s
  }
}

// Look up a generated module-map row's line count by path, for inline prose
// that cites a module-map count without hand-copying it. Generalized from
// p4-proof-automation.typ's former chapter-local `module-lines(path)` (see
// STYLE.md rule 8), which closed over that chapter's own imported
// `automation-module-map` -- this version takes the map explicitly so any
// chapter with a generated module-map data file (of the same
// `(path, lines, sorry-free, ..)` row shape) can use it. A chapter switching
// from its own local `module-lines(path)` to this one updates its call
// sites from `module-lines(path)` to `module-lines(the-module-map, path)`.
#let module-lines(map, path) = map.find(row => row.at(0) == path).at(1)

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
//
// DEPRECATED per STYLE.md rule 6: the reference manual's chapters use
// native Typst list syntax (`- item`, `+ item`) exclusively and none of
// them call `items`/`item` any longer. The two definitions below are
// retained, unchanged, because other documents in this repository may
// still reference them -- do not delete without checking for other callers
// first.

#let items(body) = block(
  above: 0.8em,
  below: 0.8em,
)[
  #set list(marker: [--], indent: 0.5em, body-indent: 0.5em, spacing: 0.65em)
  #set enum(numbering: "(1)", indent: 0.5em, body-indent: 0.5em, spacing: 0.65em)
  #body
]

// Routed through Typst's native list function rather than a manual block
// plus a literal dash, so a wrapped line hangs indented to the body (aligned
// under the marker's text, not back at the margin) and inherits whatever
// marker/indent/spacing the enclosing items block's list styling above
// establishes -- no call-site changes needed.
#let item(body) = list(body)

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
