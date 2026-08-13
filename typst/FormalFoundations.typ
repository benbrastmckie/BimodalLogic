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

== Existence, Soundness, Correspondence

Every partial history extends to a total one by a Step Lemma#footnote[`lem:step`, the sole *Spherical* application site. @brastmckie2026possibleworlds] driving a Zorn's-lemma argument (`thm:extension`), hence `cor:occurrence`; both are ZFC results, not choice-free. This matters for a Lean/paper mismatch worth flagging once: "choice-free" in the paper's sense means *no further use of AC given classical logic*, whereas Lean's single `Classical.choice` axiom already yields both excluded middle and choice jointly, so `#print axioms` cannot express the paper's finer distinction directly -- this repository has separately machine-checked that *Spherical* on a finite carrier implies weak excluded middle, so no `Classical.choice`-free Lean proof of `thm:extension` could exist even for the finite case.

#theorem("Soundness")[If $tack.r phi.alt$ then $#satisfies phi.alt$, for TM and each of its four frame-class extensions.]#footnote[`thm:TM-soundness`. Representative validity proofs: `thm:M5-valid` ($#satisfies diamond.stroked square.stroked phi.alt arrow.r square.stroked phi.alt$, via $square.stroked$'s universal quantification over the evaluation set $H_(#taskframe)$ itself), plus TD, TA, TL, MF. @brastmckie2026possibleworlds]

The three correspondence theorems are compressed to statement and one-line idea -- these are *not* the "give in full" exceptions (@sec:split-validity's dichotomy and (DD) are):

#figure(
  table(
    columns: 2, stroke: none, align: (left,left),
    table.hline(), table.header([*Correspondence*],[*Idea*]), table.hline(),
    [DF valid over $#taskframe$ iff $#Dur$ Discrete], [both directions via the translation-flow frame $W=D$, $w arrow.r.double.long_d u :<=> u=w+d$],
    [DN valid over $#taskframe$ iff $#Dur$ Dense], [same frame, DN forces/is forced by an interpolant],
    [CO valid over $#taskframe$ iff $#Dur$ Complete], [same frame with $|p| = L$ for a Dedekind cut $(L,U)$],
    table.hline(),
  ),
  caption: [The three frame-property correspondences (`app:discrete`, `app:dense`, `app:complete`), against the four frame-class predicates of `def:frame-properties`.],
)#footnote[@brastmckie2026possibleworlds]

== Perpetuity and the Collapse Theorems

The perpetuity principles P1-P6 and TF ($square.stroked phi.alt arrow.r #allfuture square.stroked phi.alt$) follow from MF and MT by short classical chains at `sub:Logic`; four modal-temporal collapses are worth naming, since they bound the language's real expressive complexity: $#sometimes square.stroked phi.alt arrow.l.r square.stroked phi.alt$ (Pthm:13), $#always square.stroked phi.alt arrow.l.r square.stroked phi.alt$ (Pthm:14), $square.stroked #always phi.alt arrow.l.r square.stroked phi.alt$ (Pthm:18), $diamond.stroked phi.alt arrow.l.r diamond.stroked #sometimes phi.alt$ (Pthm:20) -- each a short ($lt.eq 6$-line) chain from P1-P6, TF, MN, MK, M5.#footnote[Untracked, cited by key; paraphrased, not quoted verbatim. @brastmckie2026possibleworlds]

By Hölder's theorem, a nontrivial *discrete* Archimedean totally ordered abelian group is isomorphic to $ZZ$, and a nontrivial *Dedekind-complete* one is Archimedean hence isomorphic to $ZZ$ or $RR$ -- so the complete class is exactly ${ZZ, RR}$ up to isomorphism, and the dense-and-complete class is exactly $RR$.#footnote[`def:TMplus-f`, `def:TMplus-c` footnotes. @brastmckie2026possibleworlds The paper names Hölder's theorem without a bibliography entry, a standard-result convention this report matches.]

== Completeness -- Stated Exactly, Unsoftened <sec:completeness-status>

#theorem("Completeness")[
  TM, $op("TM")_f$, $op("TM")_d$, $op("TM")_c$, $op("TM")_(d c)$ are sound over their respective classes of all, discrete, dense, complete, and dense-and-complete task frames, but *none is complete*. Completeness is instead carried by $op("BL")^+$ systems: $op("TM")^+_d$ is weakly complete over the full Dense class (machine-checked, sorry-free); $op("TM")^+_f$ is weakly complete over $ZZ$-time (machine-checked over the successor-Archimedean class); $op("TM")^+_c$ is weakly complete over the dense-and-complete class, exactly $RR$ (machine-checked); $op("TM")^+$'s weak completeness over *all* task frames is the stated formalization *target*, with one proof obligation outstanding -- *not* an established theorem.
]#footnote[`cor:tm-completeness`. @brastmckie2026possibleworlds]

*Strong* completeness -- consequence from a possibly infinite premise set -- is the aim for $op("TM")^+$ and $op("TM")^+_d$, with no known obstruction to a fully compact treatment of the base and dense classes; it *provably fails* for $ZZ$-time and for the dense-and-complete class $RR$, where compactness fails. Nothing is asserted about compactness of the full discrete class in either direction, or about $op("TM")_c$'s completeness over ${ZZ,RR}$, which is not claimed even weakly.

The former conservative-extension theorem is deleted from the paper; its replacement is a four-part footnote at `def:TMplus`: the *backward* direction ($op("BL")$-theorems of TM/$op("TM")_f$/$op("TM")_d$/$op("TM")_c$ remain theorems of $op("TM")^+$ and its extensions) holds unconditionally, since $op("BL")$ embeds into $op("BL")^+$; the *forward* direction fails for the base case, witnessed by (DD) (@sec:split-validity); fails unconditionally for the discrete extension via TMP-Z1 over $ZZ times_"lex" ZZ$; and remains *open* for the dense and complete extensions, with no known counterexample. No conservativity claim is made for $op("TM")^+$ over TM.

== Decidability -- Faithfully Open

#theorem("Decidability")[Whether TM, $op("TM")_f$, $op("TM")_d$, $op("TM")_c$, $op("TM")_(d c)$ are decidable is *open*.]#footnote[`cor:tm-decidability`. @brastmckie2026possibleworlds]

A recursively axiomatized system's theorems are recursively enumerable regardless of completeness status; decidability additionally needs the *non*-theorems to be r.e., standardly secured via a finite model property (FMP). A former blanket FMP-over-$D=ZZ$ premise is *retracted as false*, witnessed twice: DF is a non-theorem of TM, $op("TM")_d$, $op("TM")_c$, $op("TM")_(d c)$ yet valid in every model over $D=ZZ$; CO is a non-theorem of $op("TM")_f$, witnessed by $ZZ times_"lex" ZZ$, yet likewise valid over $D=ZZ$. A repaired FMP must therefore be *class-specific*, ranging over effective non-Archimedean carriers such as $ZZ times_"lex" ZZ$. What exists: a verified sound tableau procedure, and ongoing formalization of a semantic, truth-connected FMP for the $ZZ$-time discrete case (@sec:construction). What would suffice: the two intersection reductions -- $op("Log")("all task frames") = op("Log")("Discrete") inter op("Log")("Dense")$ and $op("Log")("complete frames") = op("Th")(ZZ) inter op("Th")(RR)$ -- each reducing decidability to that of the two factor logics. This is a target *strategy*, not a result; no decidability theorem is proposed here.

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
