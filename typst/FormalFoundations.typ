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

== Languages

The base language is $#taskframe = chevron.l "SL", bot, arrow.r, square.stroked, allpast, allfuture chevron.r$ where $"SL" := {p_i : i in NN}$#footnote[`sub:Logic` (untracked prose, cited by key only -- no environment block exists at this site to quote). @brastmckie2026possibleworlds] -- one-place *Past* ($#allpast$) and *Future* ($#allfuture$) as primitives, alongside classical connectives and the S5 necessity operator $square.stroked$.
The extended language replaces $#allpast$/$#allfuture$ with binary *Since* / *Until*:

#definition("Language of BL+")[
  $ op("BL")^+ = chevron.l "SL", bot, arrow.r, square.stroked, S, U chevron.r $
  with $S(phi.alt, psi)$ ("$psi$ since $phi.alt$") and $U(phi.alt, psi)$ ("$psi$ until $phi.alt$") in the Burgess *event-first* convention: $phi.alt$ is the event, true at some witness time, $psi$ the guard, true throughout the intervening interval.
]#footnote[`def:BLplus-language`. @brastmckie2026possibleworlds]

$#allpast, #allfuture, #somepast, #somefuture, #always, #sometimes$ and the propositional connectives are then *defined* operators of $op("BL")^+$#footnote[`def:BLplus-defined`. @brastmckie2026possibleworlds] (e.g. $#allfuture phi.alt := not U(not phi.alt, top)$), and $op("BL")$ embeds into $op("BL")^+$ unconditionally: every $op("BL")$-theorem is recovered under the Past/Future reduction.#footnote[`thm:BLplus-PastFuture` (untracked, cited by key). @brastmckie2026possibleworlds] Over discrete frames, $op("BL")^+$ additionally defines *Next* / *Previous* operators witnessing the immediate successor/predecessor.#footnote[`thm:BLplus-NextPrevious` (untracked, cited by key). @brastmckie2026possibleworlds]

== Task-Frame Semantics

#definition("Temporal Order")[
  A *temporal order* is a nontrivial totally ordered abelian group $#Dur = (D, +, 0, lt.eq)$ with *positive cone* $D^+ := {x in D : x gt.eq 0}$.
]#footnote[`def:temporal-order`. @brastmckie2026possibleworlds]

#definition("Task Relation")[
  A *task relation* on world states $#worldstate$ over $#Dur$ is $w arrow.r.double.long_(x) u$ for $x in D^+$, extended by the *converse convention* $w arrow.r.double.long_(-x) u := u arrow.r.double.long_(x) w$, determining $"Fib"(w,x) := {u : w arrow.r.double.long_(x) u}$, the cone $(w)_x := union.big_(|y|<x) "Fib"(w,y)$, and the segment $[w,v]_x^y := "Fib"(w,x) inter "Fib"(v,-y)$.
]#footnote[`def:task-relation`. @brastmckie2026possibleworlds]

#definition("Frame")[
  A *frame* $#taskframe = (#worldstate, #Dur, arrow.r.double.long_(dot.c))$ satisfies, for $x, y gt.eq 0$:
  + *Compositionality* (biconditional): $w arrow.r.double.long_(x+y) v$ iff $w arrow.r.double.long_(x) u$ and $u arrow.r.double.long_(y) v$ for some $u$.
  + *Seriality*: some $u, v in W$ have $w arrow.r.double.long_(x) u$ and $v arrow.r.double.long_(x) w$.
  + *Limit*: $inter.big_(x>0) (w)_x = {w}$.
  + *Spherical*: $inter.big cal(S) eq.not emptyset$ for any directed family $cal(S)$#footnote[Directed: `def:directed`. @brastmckie2026possibleworlds] of nonempty fibers and segments.
]#footnote[`def:frame` (all four sub-anchors). @brastmckie2026possibleworlds Compositionality is a biconditional, load-bearing in both directions.]

Nullity ($w arrow.r.double.long_(0) w$) is *derived* from Seriality (at $x=0$) and Limit, not a fifth axiom:

#lemma("Nullity")[$w arrow.r.double.long_(0) w$ for every $w in W$ in every frame.]#footnote[`lem:nullity`, derived, choice-free. @brastmckie2026possibleworlds]

#definition("World History")[
  A *partial history* over $#taskframe$ is $tau : X arrow.r #worldstate$ on nonempty $X subset.eq D$ with $tau(x) arrow.r.double.long_(y-x) tau(y)$; a *world history* has convex domain; a world history is *total* -- equivalently a *possible world* -- iff $X = D$. $H_(#taskframe)$ denotes all total world histories.
]#footnote[`def:world-history`. @brastmckie2026possibleworlds]

Every partial history extends to a total world history (`thm:extension`, by Zorn's lemma), hence to a world state occurring at any prescribed time (`cor:occurrence`) -- both ZFC results, unlike Nullity's choice-free derivation; a frame with *finite* $W$ satisfies *Spherical* choice-free instead (`cor:spherical-finite`).#footnote[@brastmckie2026possibleworlds Both anchors tracked.] Truth is evaluated at a model, a possible world, and a time:

#definition("BL Truth, BL Model")[
  A model $#model = (#worldstate, #Dur, arrow.r.double.long_(dot.c), |dot.c|)$ interprets atoms $|p| subset.eq H_(#taskframe) times D$; $#model, tau, x #satisfies square.stroked phi.alt$ iff $#model, sigma, x #satisfies phi.alt$ for every $sigma in H_(#taskframe)$ -- $square.stroked$ quantifies over *all* total world histories, the very set at which sentences are evaluated.
]#footnote[`def:BL-model`, `def:BL-semantics` (box clause). @brastmckie2026possibleworlds]

Validity over a frame ($#taskframe #satisfies phi.alt$), logical consequence ($Gamma #satisfies phi.alt$), and global validity ($#satisfies phi.alt$, valid over every frame) close the semantic layer.#footnote[`def:frame-validity`, `def:logical-consequence`. @brastmckie2026possibleworlds]

== Proof Systems

#definition("S5")[The smallest CPL-extension closed under MK, MT, M5, MP, MN.]#footnote[`def:S5`. @brastmckie2026possibleworlds]

#definition("BX")[The *Base Burgess--Xu Tense Logic*: TN, TD (temporal necessitation, past/future duality); the seriality/linearity/connectedness triple TB, TL, CN; the primary Since/Until axioms TA, UE, UT, UI, UC, UF, UG, SU; and uniformity axioms NP, NF, NA, NB, vacuous unless discrete.]#footnote[`def:BX`. @brastmckie2026possibleworlds]

$op("TM")^+$, the base logic for $op("BL")^+$, is $"S5" + "BX" + "MF"$ ($square.stroked phi.alt arrow.r square.stroked #allfuture phi.alt$), with discrete/dense/complete extensions adding the axioms distinguishing $op("BX")_f$/$op("BX")_d$/$op("BX")_c$:

#figure(
  table(
    columns: 2, stroke: none, align: (left,left),
    table.hline(), table.header([*System*],[*Additional axioms*]), table.hline(),
    [$op("BX")_f$ / $op("TM")^+_f$], [UZ, Z1 (backward induction; successor-Archimedean, i.e. $ZZ$-time, by Hölder)],
    [$op("BX")_d$ / $op("TM")^+_d$], [DN ($#allfuture#allfuture phi.alt arrow.r #allfuture phi.alt$), NN ($not "Next"top$)],
    [$op("BX")_c$ / $op("TM")^+_c$], [Prior-U, Sep (the *Reynolds triple*, with Prior-S the TD-mirror of Prior-U); CO is a *derived theorem* from Prior-U alone, not a further axiom],
    table.hline(),
  ),
  caption: [The three frame-class extensions of $op("TM")^+$.],
)#footnote[`def:TMplus-f`, `def:TMplus-d`, `def:TMplus-c`, `def:TMplus`. @brastmckie2026possibleworlds Whether TMP-CO alone axiomatizes the same $op("BL")^+$-logic as the full Reynolds triple is *open* (conjectured to fail, via an unformalized pen-and-paper sketch; not established).]

The *BL-level* system this report's pain points concern is $op("TM")$ itself, the smallest CPL-extension closed under MP, MN, MK, MT, M5 (S5, as above), MF (the sole bimodal-interaction axiom), and TD, TK, T4, TB, TA, TL (temporal necessitation, future-K, transitivity, seriality, past/future exchange, linearity) -- axiomatized directly over $#allpast$/$#allfuture$, with no Since/Until primitives.#footnote[Untracked prose (`sub:Logic`), cited by key only -- these twelve axiom/rule keys are not individually quoted verbatim here. @brastmckie2026possibleworlds] Its discrete/dense/complete extensions $op("TM")_f, op("TM")_d, op("TM")_c, op("TM")_(d c)$ add DF, DN, CO respectively (@sec:contingency). $op("TM")$ is the paper's *economical* presentation; $op("BX")$ is the Lean development's more fine-grained, frame-class-parameterized proof system (@sec:construction) -- the two are related but not silently identified (@sec:construction states the open cross-reference precisely).

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
