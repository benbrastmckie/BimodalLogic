// ============================================================================
// BimodalReference.typ
// Bimodal TM Logic: A Reference Manual
//
// This document provides the formal specification of the Bimodal TM logic,
// a bimodal logic combining S5 metaphysical modality with linear temporal
// operators, as implemented in the Bimodal/ directory.
// ============================================================================

// Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
// Released under Apache 2.0 license as described in the file LICENSE.

// ============================================================================
// Package Imports
// ============================================================================

#import "@preview/cetz:0.3.4"

// Local notation and template (includes thmbox theorem environments)
#import "notation/bimodal-notation.typ": *
#import "template.typ": thmbox-show, URLblue, definition, theorem, lemma, axiom, remark, proof, part-divider

// ============================================================================
// Document Configuration
// ============================================================================

#set document(
  title: "Bimodal Reference Manual",
  author: "Benjamin Brast-McKie",
)

// Typography settings - LaTeX-like appearance
#set text(font: "New Computer Modern", size: 11pt)
#set heading(numbering: "1.1")
#set par(
  justify: true,
  leading: 0.55em,        // Tight line spacing like LaTeX
  spacing: 0.55em,        // Paragraph spacing
  first-line-indent: 1.8em,  // First-line indent like LaTeX
)

// Page layout with LaTeX-like margins
#set page(
  numbering: "1",
  number-align: center,
  margin: 1.75in,  // Match LaTeX 11pt article class defaults
)

// Heading spacing
#show heading: set block(above: 1.4em, below: 1em)

// Level-1 headings carry the "Chapter" supplement (ported from
// LogosManual.typ:40-51), so @-references to chapters render as
// "Chapter N" rather than the bare heading text.
#show heading.where(level: 1): set heading(supplement: "Chapter")

#show ref: it => {
  let el = it.element
  if el != none and el.func() == heading and el.level == 1 {
    link(it.target)[Chapter~#numbering("1", ..counter(heading).at(el.location()))]
  } else {
    it
  }
}

// Automatically bold "TM" throughout the document
#show "TM": strong

// ============================================================================
// Theorem Environment Initialization
// ============================================================================

#show: thmbox-show

// Style hyperlinks in URLblue color
#show link: set text(fill: URLblue)

// Allow theorem boxes to break across pages
#show figure.where(kind: "thmbox"): set block(breakable: true)

// ============================================================================
// Custom Commands
// ============================================================================

// Horizontal rule
#let HRule = line(length: 100%, stroke: 0.5pt)

// ============================================================================
// Title Page
// ============================================================================

#page(numbering: none)[
  #v(2cm)
  #align(center)[
    #HRule
    #v(0.4cm)
    #text(size: 24pt, weight: "bold")[Bimodal Reference Manual]
    #v(0.2cm)
    #HRule
    #v(.5cm)

    #text(size: 18pt, style: "italic")[A Logic for Tense and Modality]
    #v(1cm)

    #text(size: 12pt, style: "italic")[Benjamin Brast-McKie]
    #v(0.0cm)
    #link("https://www.benbrastmckie.com")[#raw("www.benbrastmckie.com")]
    #v(0.0cm)
    --- #datetime.today().display("[month repr:long] [day], [year]") ---
    #v(0.3cm)
    #text(size: 9pt)[© 2026 Benjamin Brast-McKie. Licensed under the #link("https://www.apache.org/licenses/LICENSE-2.0")[Apache License, Version 2.0].]
    #v(1cm)

    #v(1fr)

    #text(size: 12pt, weight: "bold")[Sources:]
    #v(0.3cm)
    #block(width: 80%)[
      #set align(left)
      + #link("https://benbrastmckie.com/wp-content/uploads/2026/07/possible_worlds.pdf")[_"The Construction of Possible Worlds"_], Brast-McKie, _Journal of Philosophical Logic_, forthcoming.
      + The #proofchecker Lean 4 repository, `FormalSystem/` -- ground truth for all formal claims.
    ]
    #v(1cm)
  ]
]

// ============================================================================
// Abstract
// ============================================================================

#page(numbering: none)[
  #v(1em)
  #align(center)[
    #text(size: 14pt, weight: "bold")[Abstract]
  ]
  #v(1em)

  This book presents the Bimodal logic *TM* for tense and modality, formalized in the #proofchecker Lean 4 project.
  *TM* combines an S5 historical-necessity operator with linear temporal operators for past and future tense, axiomatized by the Burgess-Xu (BX) proof system over Since/Until primitives and interpreted over task-frame semantics.
  The system's metatheory delivers soundness for all four frame classes, the deduction theorem, the Lindenbaum lemma, and the perpetuity principles.
  // CONFIRM(lean): the set-premise strong completeness theorems for FrameClass.Base and FrameClass.Dense named in
  //   the metalogic chapter's CONFIRM obligations exist and are axiom-free, backing the abstract's completeness claims.
  Completeness holds in the strongest form each frame class admits: *TM* is strongly complete over all task frames and *TM*#sub[d] over the dense frames, while *TM*#sub[f] and *TM*#sub[c] are weakly complete over $ZZ$-time and the dense-and-complete (real-flow) class respectively --- where strong completeness *provably fails*, by non-compactness.

  *Part I* (The Bimodal System) presents the formal system in full -- syntax, semantics, proof theory, frame classes, metalogic, the operational decision procedure, and the derived-theorem library -- and closes by positioning *TM* among richer temporal-modal logics (Vlach store/recall operators, the BL#super[⋆] tower, the decidability frontier).
  *Part II* (Applications) presents the proof-automation tactics, the dual-signal (proof-trace / countermodel) training-data pipeline, and worked dual-verification examples drawn directly from the Lean formalization.

  #v(1cm)

  // Styled Contents header
  #align(center)[
    #text(size: 14pt, weight: "bold")[Contents]
  ]
  #v(1em)

  // Bold chapter entries (level 1), normal weight for sections/subsections
  #show outline.entry.where(level: 1): it => {
    v(0.5em)
    strong(it)
  }
  #outline(title: none, indent: auto)
]

#pagebreak()

// ============================================================================
// Content -- Two-Part Reference
//
// Order: bimodal system -> applications.
// ============================================================================

// ---- Front Matter -----------------------------------------------------------

#include "chapters/00-introduction.typ"

// ---- Part I: The Bimodal System --------------------------------------------

#part-divider(
  "I",
  "The Bimodal System",
  [
    The formal specification of *TM*: syntax, task-frame semantics, the
    Burgess-Xu proof system, frame classes and their extensions, the
    metalogic, the operational decision procedure, and the derived-theorem
    library, followed by the system's position among neighboring
    temporal-modal logics and the decidability frontier for its extensions.
    The formal claims in this part resolve to live Lean source under
    `FormalSystem/`.
  ],
)

#include "chapters/01-syntax.typ"
#include "chapters/02-semantics.typ"
#include "chapters/03-proof-theory.typ"
#include "chapters/p2-frame-classes.typ"
#include "chapters/04-metalogic.typ"
#include "chapters/p2-decidability-practice.typ"
#include "chapters/05-theorems.typ"
#include "chapters/p3-ltl-to-tm.typ"
#include "chapters/p3-vlach-blstar.typ"
#include "chapters/p3-decidability-frontier.typ"

// ---- Part II: Applications --------------------------------------------------

#part-divider(
  "II",
  "Applications",
  [
    Proof automation tactics and the bounded proof-search engine; the
    dual-signal training-data pipeline (proof traces to policy,
    countermodels to value, every output deterministically checkable); and
    dual-verification worked examples drawn from the `Examples/` library.
  ],
)

#include "chapters/p4-proof-automation.typ"
#include "chapters/p4-dataset-pipeline.typ"
#include "chapters/p4-dual-verification.typ"

// ---- Back Matter ------------------------------------------------------------

#include "chapters/06-notes.typ"
#include "chapters/ax-machine-appendix.typ"

// ============================================================================
// Bibliography
// ============================================================================

#pagebreak()
#heading(numbering: none)[References]
#bibliography("bibliography.bib", style: "ieee")
