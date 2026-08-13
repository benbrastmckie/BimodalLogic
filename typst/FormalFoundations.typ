// ============================================================================
// FormalFoundations.typ
// Formal Foundations of Bimodal TM Logic: Completeness and Representation
//
// A standalone research report on the formal foundations of the bimodal logic
// TM: a compressed system overview, the three pain points of the axiomatization
// (temporal-axiom contingency, split-validity incompleteness, the axiomatization
// of the strongest objective modality), the completeness construction as
// actually implemented in FormalSystem/Metalogic/, and a reasoned outline of
// the way forward toward a general representation theorem.
//
// This document is NOT a chapter of BimodalReference.typ and is not #include'd
// by it. It imports the book's notation and template modules so that notation
// cannot drift between this report and the book, and cites the book's shared
// bibliography.
// ============================================================================

// Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
// Released under Apache 2.0 license as described in the file LICENSE.

// ============================================================================
// Package Imports
// ============================================================================

#import "@preview/cetz:0.3.4"

// Local notation and template (includes thmbox theorem environments)
#import "notation/bimodal-notation.typ": *
#import "template.typ": thmbox-show, URLblue, definition, theorem, lemma, axiom, remark, proof, corollary, proposition

// ============================================================================
// Document Configuration -- matches BimodalReference.typ's type settings
// verbatim, so a "~10 pages of body text" budget is measured on the same
// scale as the book.
// ============================================================================

#set document(
  title: "Formal Foundations of Bimodal TM Logic: Completeness and Representation",
  author: "Benjamin Brast-McKie",
)

#set text(font: "New Computer Modern", size: 11pt)
#set heading(numbering: "1.1")
#set par(
  justify: true,
  leading: 0.55em,
  spacing: 0.55em,
  first-line-indent: 1.8em,
)

#set page(
  numbering: "1",
  number-align: center,
  margin: 1.75in,
)

#show heading: set block(above: 1.4em, below: 1em)

// Automatically bold "TM" throughout the document, matching the book.
#show "TM": strong

// ============================================================================
// Theorem Environment Initialization
// ============================================================================

#show: thmbox-show

#show link: set text(fill: URLblue)
#show figure.where(kind: "thmbox"): set block(breakable: true)

#let HRule = line(length: 100%, stroke: 0.5pt)

// ============================================================================
// Title Block
// ============================================================================

#align(center)[
  #HRule
  #v(0.3cm)
  #text(size: 18pt, weight: "bold")[Formal Foundations of Bimodal TM Logic]
  #v(0.15cm)
  #text(size: 13pt, style: "italic")[Completeness and Representation]
  #v(0.3cm)
  #HRule
  #v(0.4cm)
  #text(size: 11pt, style: "italic")[Benjamin Brast-McKie]
  #v(0.1cm)
  --- #datetime.today().display("[month repr:long] [day], [year]") ---
]

#v(0.6cm)

*Abstract.*
This report states, precisely and compressed, what is actually proved about the bimodal logic
*TM* -- a fusion of S5 metaphysical modality with a Burgess--Xu tense logic over task-frame
semantics -- what is not, and what it would take to close the gap. Section 1 compresses the
system; Section 2 states the load-bearing theorems and the exact completeness and decidability
status, unsoftened. Sections 3-5 are the three genuine pain points of the axiomatization: the
metaphysical contingency of the temporal axioms, a sharp split-validity incompleteness result for
*TM* itself, and the higher-order cost of axiomatizing the strongest objective modality. Section 6
gives an honest, measured account of the completeness construction as it is actually implemented
in this repository's Lean 4 development, and Section 7 closes with the early steps toward a
representation theorem and a reasoned outline of the way forward for a general, weaker base
bimodal logic assuming neither density nor discreteness nor Dedekind-completeness.

#v(0.3cm)

= The System, Compressed <sec:system>

// PHASE-3-PLACEHOLDER: content added in a later phase.

= Key Theorems, Completeness Status, and Decidability <sec:key-theorems>

// PHASE-4-PLACEHOLDER: content added in a later phase.

= Pain Point One: The Contingency of the Temporal Axioms <sec:contingency>

// PHASE-5-PLACEHOLDER: content added in a later phase.

= Pain Point Two: Split Validity and TM's Semantic Incompleteness <sec:split-validity>

// PHASE-6-PLACEHOLDER: content added in a later phase.

= Pain Point Three: Axiomatizing the Strongest Objective Modality <sec:objective-modality>

// PHASE-7-PLACEHOLDER: content added in a later phase.

= The Completeness Construction as Implemented Here <sec:construction>

// PHASE-8-PLACEHOLDER: content added in a later phase.

= Early Representation Work and the Way Forward <sec:representation>

// PHASE-9-PLACEHOLDER: content added in a later phase.

#bibliography("bibliography.bib")
