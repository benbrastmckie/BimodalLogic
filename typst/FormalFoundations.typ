// ============================================================================
// FormalFoundations.typ
// Formal Foundations of Bimodal TM Logic: Completeness and Representation
//
// A standalone research report on the formal foundations of the bimodal logic
// TM, in five sections: the system (semantics first, then the proof systems);
// what is proved, stated per system and per frame class; the completeness
// construction as implemented in FormalSystem/Metalogic/; the two costs the
// semantics incurs; and the routes toward a representation theorem.
//
// This document is NOT a chapter of BimodalReference.typ and is not #include'd
// by it. It imports the book's notation and template modules so that notation
// cannot drift between the two, and cites the book's shared bibliography.
// ============================================================================

// Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
// Released under Apache 2.0 license as described in the file LICENSE.

// ============================================================================
// Package Imports
// ============================================================================

#import "@preview/cetz:0.3.4"

// Local notation and template (includes thmbox theorem environments)
#import "notation/bimodal-notation.typ": *
#import "template.typ": thmbox-show, URLblue, definition, theorem, lemma, axiom, remark, proof, corollary, proposition, leansrc, items

// ============================================================================
// Document Configuration -- matches BimodalReference.typ's type settings
// verbatim, so the page count is on the same scale as the book. Body runs
// ~26pp: the definition/theorem presentation costs roughly ten pages over the
// prior prose version. That cost is the point of the rewrite, not a defect.
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
// Local notation for this document
//
// The paper writes Since and Until infix, as \lhd and \rhd, and guard-first:
// in "phi S psi" the guard is phi and the event is psi. These are the paper's
// own glyphs and argument order. (The Lean tree's snce/untl constructors are
// event-first; that internal convention is not used here.)
// ============================================================================

#let BL = $op("BL")$
#let BLplus = $op("BL")^+$
#let since = $lt.tri$
#let until = $gt.tri$
#let Nxt = $op("Next")$
#let Prev = $op("Prev")$

// Abstract environment: no first-line indent, one point below the body size.
#let abstract-block(body) = block(above: 0.6cm, below: 0.6cm, width: 100%)[
  #set par(first-line-indent: 0em, justify: true)
  #set text(size: 10pt)
  #body
]


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

#abstract-block[
  *Abstract.* This report states what is proved about the bimodal logic *TM* --- a fusion of S5
  metaphysical modality with a Burgess--Xu tense logic over task-frame semantics --- and what is
  not. Section 1 gives the semantics and the proof systems, including the task topology and the
  separation result that bear on whether a partial history should be identified with a restriction
  of a possible world. Section 2 states soundness, the three frame-property correspondences,
  completeness per system and per frame class with the axiom report of each machine-checked claim,
  and the open status of decidability. Section 3 gives the completeness construction: maximal
  consistent sets, the discreteness dichotomy and the case split it licenses, the coherence
  conditions that discharge the modal case of the truth lemma, and the three canonical
  constructions with their sources. Section 4 states the two costs the semantics incurs --- the
  necessity of temporal structure, and the higher-order character of the condition singling out
  $square.stroked$ --- and where the two meet. Section 5 assesses the three candidate routes to a
  representation theorem, commits to the one with live groundwork, and closes with the single
  obstruction the others share. Complexity as distinct from decidability, interpolation, and finite
  axiomatizability are known open and are not treated here.

  This document reports what is machine-checked in `FormalSystem/`, following the presentation of
  Brast-McKie's task-frame semantics @brastmckie2026possibleworlds, available at
  #link("https://benbrastmckie.com/publications/possible_worlds.pdf")[benbrastmckie.com].
]

#v(0.3cm)

= The System <sec:system>

The order of exposition is the paper's own: the frame structures and the truth definition first,
the proof systems that answer to them last.

== The Language

#definition("Language")[
  $#BLplus := chevron.l "SL", bot, arrow.r, square.stroked, #since, #until chevron.r$, where
  $"SL" := {p_i : i in NN}$ is a countable set of sentence letters and the remaining symbols denote
  falsity, material implication, metaphysical necessity, *since*, and *until*. Well-formed
  sentences are given by
  $ phi.alt, psi ::= p_i | bot | phi.alt arrow.r psi | square.stroked phi.alt | phi.alt #since psi | phi.alt #until psi. $
]
#leansrc("Syntax", "Formula")
#footnote[The paper's base language $#BL$ takes the one-place $#allpast$ and $#allfuture$ as primitive instead; it embeds into $#BLplus$ under @def-operators, and is not used below.]

The two primitives are written infix and are *guard-first*: in $phi.alt #since psi$ the guard is
$phi.alt$, holding throughout an interval, and the event is $psi$, witnessed at its far endpoint.

#definition("Defined Operators")[
  #items[
    + $#somepast phi.alt := top #since phi.alt$ and $#somefuture phi.alt := top #until phi.alt$.
    + $#allpast phi.alt := not #somepast not phi.alt$ and $#allfuture phi.alt := not #somefuture not phi.alt$.
    + $#always phi.alt := #allpast phi.alt and phi.alt and #allfuture phi.alt$ and
      $#sometimes phi.alt := #somepast phi.alt or phi.alt or #somefuture phi.alt$.
    + $#Prev phi.alt := bot #since phi.alt$ and $#Nxt phi.alt := bot #until phi.alt$.
  ]
] <def-operators>

Each defined operator has the clause its name advertises: $#allpast$ and $#allfuture$ are the
universal past and future tenses, and over a discrete order $#Nxt phi.alt$ holds exactly when
$phi.alt$ holds at the immediate successor, while $#Nxt phi.alt$ is equivalent to $bot$ at any time
lacking one.#footnote[The guard $bot$ in $#Nxt phi.alt := bot #until phi.alt$ forces the open interval to the witness to be empty, which over a discrete order means the witness is the immediate successor.]
The sentence $#Nxt top$ therefore *says* that the present moment has an immediate successor. That
one sentence is what separates $#BLplus$ from $#BL$ everywhere below: it is the
discreteness indicator on which the completeness construction of @sec:construction case-splits, and
its absence from $#BL$ is what produces the split validity of @sec:dichotomy.

== Frames

#definition("Temporal Order")[
  A *temporal order* is a nontrivial totally ordered abelian group $#Dur = (D, +, 0, lt.eq)$ with
  *positive cone* $D^+ := {x in D : x gt.eq 0}$.
]

#definition("Task Relation")[
  A *task relation* on a nonempty set $#worldstate$ of *world states* over a temporal order $#Dur$
  is a parameterized relation $w arrow.r.double.long_(x) u$ for $w, u in #worldstate$ and
  $x in D^+$, extended to negative durations by the *converse convention*
  $ w arrow.r.double.long_(-x) u := u arrow.r.double.long_(x) w quad (x gt.eq 0), $
  and determining, for $w, v in #worldstate$ and $x, y in D$:
  #items[
    + *Fiber*: $"Fib"(w, x) := {u in #worldstate : w arrow.r.double.long_(x) u}$.
    + *Cone*: $(w)_x := union.big_(|y| < x) "Fib"(w, y)$, for $x > 0$.
    + *Segment*: $[w, v]_x^y := "Fib"(w, x) inter "Fib"(v, -y)$, for $x, y gt.eq 0$.
  ]
]
#leansrc("Semantics.TaskFrame", "Fib")
#leansrc("Semantics.TaskFrame", "cone")
#leansrc("Semantics.TaskFrame", "Seg")
#footnote[The relation is primitive only on $D^+$; negative durations are defined, not given.]

#definition("Directed Family")[
  A nonempty family of sets $cal(S)$ is *directed* just in case $S subset.eq S_1 inter S_2$ for
  some $S in cal(S)$ whenever $S_1, S_2 in cal(S)$.
]
#leansrc("Semantics.TaskFrame", "DirectedFamily")

#definition("Frame")[
  A *frame* is any $#taskframe = (#worldstate, #Dur, arrow.r.double.long)$ where $#worldstate$ is a
  nonempty set of world states, $#Dur$ is a temporal order consisting of durations, and $arrow.r.double.long$ is a task
  relation satisfying the following constraints for all $x, y gt.eq 0$:
  #items[
    + *Compositionality*: $w arrow.r.double.long_(x+y) v$ if and only if
      $w arrow.r.double.long_(x) u$ and $u arrow.r.double.long_(y) v$ for some $u in #worldstate$.
    + *Seriality*: $w arrow.r.double.long_(x) u$ and $v arrow.r.double.long_(x) w$ for some
      $u, v in #worldstate$.
    + *Limit*: $inter.big_(x > 0) (w)_x = {w}$.
    + *Spherical*: $inter.big cal(S) eq.not emptyset$ for any directed family $cal(S)$ of nonempty
      fibers and segments.
  ]
]
#leansrc("Semantics", "TaskFrame")
#footnote[Compositionality is a biconditional, load-bearing in both directions.]

#lemma("Nullity")[$w arrow.r.double.long_(0) w$ for every world state $w$ of every frame.]
#leansrc("Semantics.TaskFrame", "nullity")
#proof[
  *Seriality* at $x = 0$ gives $u$ with $w arrow.r.double.long_(0) u$. Since $|0| < x$ for every
  $x > 0$, $u in (w)_x$ for every such $x$, so $u in inter.big_(x>0)(w)_x = {w}$ by *Limit*, whence
  $u = w$.
]

Nullity is derived, not postulated, and its derivation uses no choice. The distinction matters
below: two of the three results in @sec:histories are theorems of ZFC.

== Histories and the Task Topology <sec:histories>

#definition("History")[
  Let $#taskframe = (#worldstate, #Dur, arrow.r.double.long)$ be a frame.
  #items[
    + A *partial history* is a function $tau : X arrow.r #worldstate$ on a nonempty set of durations $X subset.eq D$
      with $tau(x) arrow.r.double.long_(y-x) tau(y)$ for all $x, y in X$.
    + A *world history* is a partial history whose domain is *convex* so that $y in X$ whenever
      $x, z in X$ and $x < y < z$.
    + A *possible world* is a world history that is *total* where $X = D$.
    + $sigma$ *extends* $tau$ just in case $"dom"(tau) subset.eq "dom"(sigma)$ and
      $tau(x) = sigma(x)$ throughout $"dom"(tau)$.
    + $H_(#taskframe)$ is the set of all possible worlds over $#taskframe$.
  ]
]
#leansrc("Semantics", "PartialHistory")
#leansrc("Semantics", "WorldHistory")

#theorem("Extension")[
  Every partial history over a frame is extended by a possible world.
]
#leansrc("Semantics.PartialHistory", "extension")
// #proof[
//   // FIX: this proof is inadequate and should be fixed by including the lemmas it needs to cite, drawing on /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex where these results are established
//   The partial histories extending $tau$ are ordered by extension, and every chain is bounded above
//   by its union, which is again a partial history since any two of its times already lie in a common
//   member of the chain. Zorn's lemma yields a maximal $sigma : T arrow.r #worldstate$ extending
//   $tau$. Were $T eq.not D$, the Step Lemma would extend $sigma$ to $T union {z}$ for
//   $z in D without T$, against maximality; so $T = D$.
// ]

#corollary("Occurrence")[
  For every frame $#taskframe$, world state $w in W$, and time $x in D$, there is some possible world $tau in H_(#taskframe)$ which has
  $tau(x) = w$. In particular $H_(#taskframe) eq.not emptyset$.
]
#leansrc("Semantics.PartialHistory", "occurrence")

The Step Lemma is the sole application site of *Spherical* in the paper, and Extension is the sole
consumer of the Step Lemma; every appeal to *Spherical* in the semantics passes through this one
point.#footnote[`lem:step`. @brastmckie2026possibleworlds *Spherical* is not needed when the directed family has a $subset.eq$-least member, and on a finite carrier it holds outright and choice-free (`cor:spherical-finite`).] Extension and Occurrence are theorems of ZFC, in contrast with Nullity. That
localization is what makes *Spherical* the identified obstruction of @sec:representation.

The cones are a basis for a topology on world states, and that topology is separated.

#definition("Task Topology")[
  // FIX: this needs to be expanded to be easier to read, including indented definitions here as in the definitions above
  For a frame $#taskframe$, let $B_(#taskframe) := {(w)_x : w in #worldstate, x in D, x > 0}$ and
  let $cal(O)_(#taskframe)$ be the closure of $B_(#taskframe)$ under arbitrary union and finite
  intersection, writing $cal(T)_(#taskframe) := (#worldstate, cal(O)_(#taskframe))$. For
  $S subset.eq #worldstate$, $overline(S) := {w : O inter S eq.not emptyset$ for every open $O in.rev w}$.
  The topology is *T1* just in case $overline({w}) = {w}$ for all $w$, and *R0* just in case
  $w in overline({u})$ iff $u in overline({w})$ for all $w, u$.
]#footnote[The topology is carried by the world states, not by $H_(#taskframe)$ or by $D$.]

#theorem("Separation")[$cal(T)_(#taskframe)$ is T1, and hence R0, for every frame $#taskframe$.]
// FIX: 
// #proof[
//   ${u} subset.eq overline({u})$ is immediate. Conversely let $w in overline({u})$. By Nullity
//   every basic open $(w)_x$ contains $w$, so $u in (w)_x$ for every $x > 0$.
//   Hence for each such $x$ there is $y$ with $|y| < x$ and $w arrow.r.double.long_(y) u$, so $u arrow.r.double.long_(-y) w$
//   by the converse convention and $w in (u)_x$.
//   Thus $w in inter.big_(x>0)(u)_x = {u}$ by *Limit*, and so R0 follows.
// ]

// #remark[
//   Extension makes every partial history a restriction of a possible world, and Separation shows the
//   cone topology distinguishes world states.
//   Whether these results license *defining* a partial
//   history as a restriction of a possible world, instead of defining it independently and proving
//   Extension, is a question about the order of the theory and not about its content: the two
//   definitions agree extensionally, by Extension.
//   They differ in what must be assumed at the outset.
//   The restriction definition makes $H_(#taskframe)$ prior and hides the appeal to *Spherical*
//   inside the existence of the objects it quantifies over; the order taken here keeps *Spherical*
//   visible at the single site where it is used.
// ]

== Models and Truth

#definition("Model")[
  A *model* is a structure $#model = (#worldstate, #Dur, arrow.r.double.long, |dot.c|)$ where
  $(#worldstate, #Dur, arrow.r.double.long)$ is a frame and $|p_i| subset.eq #worldstate$ for every
  sentence letter $p_i$.
]
#leansrc("Semantics", "TaskModel")
#footnote[An interpretation assigns each sentence letter a set of *world states*. Truth at a time is mediated entirely by the world state the history occupies there; this is the content of the atomic clause below, and it is what makes a possible world a trajectory through a fixed state space and not an independent index.]

#definition("Truth")[
  *Truth* in a model $#model$ at a possible world $tau in H_(#taskframe)$ and time $x in D$ is defined recursively as follows:
  #items[
    + $#model, tau, x #satisfies p_i$ iff $tau(x) in |p_i|$.
    + $#model, tau, x #notsatisfies bot$.
    + $#model, tau, x #satisfies phi.alt arrow.r psi$ iff $#model, tau, x #notsatisfies phi.alt$ or
      $#model, tau, x #satisfies psi$.
    + $#model, tau, x #satisfies square.stroked phi.alt$ iff $#model, sigma, x #satisfies phi.alt$
      for every $sigma in H_(#taskframe)$.
    + $#model, tau, x #satisfies phi.alt #since psi$ iff $#model, tau, z #satisfies psi$ for some
      $z < x$ with $#model, tau, y #satisfies phi.alt$ for all $y$ with $z < y < x$.
    + $#model, tau, x #satisfies phi.alt #until psi$ iff $#model, tau, z #satisfies psi$ for some
      $z > x$ with $#model, tau, y #satisfies phi.alt$ for all $y$ with $x < y < z$.
  ]
]
#leansrc("Semantics", "TruthAt")
#footnote[Evaluating at a possible world paired with a time, with truth at that time mediated by the world state occupied there, is an instance of Scott's proposal @scott1970advice that the index of evaluation be a structured point of reference and not a bare world.]

// FIX:
// The semantic clause for $square.stroked$ quantifies over all possible worlds of the frame.
// It is not a relational modality with an accessibility relation to be tuned: the frame fixes $H_(#taskframe)$, and $square.stroked$ ranges over that set entire.
// Its logic is correspondingly S5, and @sec:objective-modality takes up what else, beyond being S5, is needed to single it out.

#definition("Frame Properties")[
  A frame is *Discrete* if every $x in D$ having some $y > x$ has a least such; *Dense* if
  $x < z < y$ for some $z$ whenever $x < y$; *Complete* if every nonempty subset of $D$ bounded
  above has a least upper bound; and *Deterministic* if $w arrow.r.double.long_(x) u$ and
  $w arrow.r.double.long_(x) v$ imply $u = v$.
]
#leansrc("FrameConditions", "DenseTemporalFrame")
#leansrc("FrameConditions", "DiscreteTemporalFrame")
#leansrc("FrameConditions", "DedekindTemporalFrame")
#footnote[The first three constrain $#Dur$; the fourth constrains $arrow.r.double.long$.]

#definition("Validity and Consequence")[
  // $#taskframe #satisfies phi.alt$ just in case $#model, tau, x #satisfies phi.alt$ for every model
  // $#model$ on $#taskframe$, every $tau in H_(#taskframe)$, and every $x in D$. And
  $Gamma #satisfies phi.alt$ just in case $phi.alt$ is true in every model, at every possible world, and time at which every
  member of $Gamma$ is true; $phi.alt$ is *valid* when $#satisfies phi.alt$.
]
#leansrc("Semantics", "valid")
#leansrc("Semantics", "SemanticConsequence")

// FIX:
// By Occurrence $H_(#taskframe)$ is never empty, so frame validity is never vacuous and
// $#taskframe #notsatisfies bot$ for every frame. Fixing $H_(#taskframe)$ with the frame does not
// make $#taskframe$ a *general frame* in the sense of Blackburn, de Rijke, and Venema
// @blackburnderijkevenema2001: a general frame restricts the admissible valuations to a designated
// subalgebra, whereas here every $|p_i| subset.eq #worldstate$ is admissible. What the frame
// constrains is the points of evaluation, not the propositions.

== Proof Systems

#definition("S5")[
  // FIX: indent the axioms and formalize all of them to improve readability
  *S5* is the smallest extension of classical propositional logic closed under MK
  ($square.stroked(phi.alt arrow.r psi) arrow.r (square.stroked phi.alt arrow.r square.stroked psi)$),
  MT ($square.stroked phi.alt arrow.r phi.alt$), M5
  ($diamond.stroked square.stroked phi.alt arrow.r square.stroked phi.alt$), modus ponens, and
  necessitation.
]

#definition("BX")[
  // FIX: this is unreadable and needs to be expanded so this document is self-contained rather than requiring the reader to look these up elsewhere
  The *Base Burgess--Xu Tense Logic*: the rules TN (temporal necessitation) and TD (the rule
  swapping $#since$ and $#until$ throughout a theorem); the seriality, linearity, and connectedness
  axioms TB, TL, CN; the primary Since/Until axioms TA, UE, UT, UI, UC, UF, UG, SU; and the
  uniformity axioms NP, NF, NA, NB, which are vacuous unless the order is discrete.
]#footnote[Seventeen named keys. The past direction of each axiom is derived from the future direction by TD, not postulated.]

// FIX: everything in the remainder of this section is inadequate and needs to do a much better job of presenting what is carefully presented in /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex to provide a systematic account of the various proof systems, clearly defining each.
$op("TM")^+$, the base logic for $#BLplus$, is $"S5" + "BX" + "MF"$, where MF is
$square.stroked phi.alt arrow.r square.stroked #allfuture phi.alt$, the sole bimodal-interaction
axiom. Its three frame-class extensions add the axioms below.

#figure(
  table(
    columns: 2, stroke: none, align: (left,left),
    table.hline(), table.header([*System*],[*Additional axioms*]), table.hline(),
    [$op("TM")^+_f$], [UZ, Z1 (backward induction; successor-Archimedean, hence $ZZ$-time by Hölder's theorem)],
    [$op("TM")^+_d$], [DN ($#allfuture#allfuture phi.alt arrow.r #allfuture phi.alt$), NN ($not #Nxt top$)],
    [$op("TM")^+_c$], [the *Reynolds triple* Prior-U, Prior-S, Sep; CO is a derived theorem, not a further axiom],
    table.hline(),
  ),
  caption: [The three frame-class extensions of $op("TM")^+$.],
)
#leansrc("ProofSystem", "FrameClass")
#footnote[Whether CO alone axiomatizes the same $#BLplus$-logic as the full Reynolds triple is open.]

By Hölder's theorem a nontrivial discrete Archimedean totally ordered abelian group is isomorphic
to $ZZ$, and a nontrivial Dedekind-complete one is Archimedean and so isomorphic to $ZZ$ or $RR$.
The complete class is therefore exactly ${ZZ, RR}$ up to isomorphism, and the dense-and-complete
class exactly $RR$.

= Completeness and Decidability <sec:key-theorems>

// FIX: some introduction would be good but this is not it. Avoid platitudes, providing a brief overview of what the section covers.
// #remark[
//   Soundness fixes the direction from proof to truth and is settled for every system named above.
//   Completeness is the converse direction, and what it would buy is the licence to reason about
//   task frames --- objects with a group-valued duration parameter, a topology, and a Zorn-backed
//   existence theorem --- by manipulating finite derivations instead. The results below say that
//   this licence is available at the $#BLplus$ level for three frame classes and is not yet
//   available at the $#BL$ level for any, and @sec:construction says why the extra sentence
//   $#Nxt top$ is what makes the difference.
// ]

== Soundness and Correspondence

#theorem("Soundness")[
  If $tack.r phi.alt$ then $#satisfies phi.alt$, for TM and for each of its four frame-class
  extensions $op("TM")_f$, $op("TM")_d$, $op("TM")_c$, $op("TM")_(d c)$ over its own class.
]
#leansrc("FrameConditions", "soundness_linear")
#leansrc("FrameConditions", "soundness_dense")
#leansrc("FrameConditions", "soundness_discrete")
#leansrc("FrameConditions", "soundness_Int")
#footnote[The characteristic case is M5, $#satisfies diamond.stroked square.stroked phi.alt arrow.r square.stroked phi.alt$, which holds because $square.stroked$ quantifies over $H_(#taskframe)$ entire and so is insensitive to the possible world at which it is evaluated.]

The three frame properties that separate the extensions are each characterized by a single axiom.
These correspondences are what make the extensions extensions *of a frame class* and not merely of
a proof system, and @sec:contingency's argument turns on all three holding together.

#proposition("Correspondence")[
  Over any frame $#taskframe$: DF is valid iff $#Dur$ is Discrete; DN is valid iff $#Dur$ is
  Dense; and CO is valid iff $#Dur$ is Complete.
]

Each direction is witnessed on the *translation flow* over $#Dur$ --- the frame with
$#worldstate = D$ and $w arrow.r.double.long_(d) u$ iff $u = w + d$ --- which is a frame for every
temporal order and whose possible worlds are exactly the translations of the identity. Validity of
the axiom then reduces to the order-theoretic property outright, the Complete case by interpreting
an atom as the lower half $L$ of a Dedekind cut $(L, U)$, so that CO fails precisely when the cut
has no supremum.

== Perpetuity and Collapse

#proposition("Collapse")[
  $#sometimes square.stroked phi.alt arrow.l.r square.stroked phi.alt$,
  $#always square.stroked phi.alt arrow.l.r square.stroked phi.alt$,
  $square.stroked #always phi.alt arrow.l.r square.stroked phi.alt$, and
  $diamond.stroked phi.alt arrow.l.r diamond.stroked #sometimes phi.alt$ are all theorems of TM.
]#footnote[Each is a chain of at most six lines from the perpetuity principles P1--P6 and TF ($square.stroked phi.alt arrow.r #allfuture square.stroked phi.alt$), which follow in turn from MF and MT.]

A modality prefixed by a tense operator, or a tense operator prefixed by $square.stroked$, is
therefore no stronger than the modality alone. This bounds what the bimodal language can express
beyond its two fragments, and it is the reason the completeness constructions below need only
manage the interaction axiom MF and not an open-ended supply of mixed principles.

== Completeness <sec:completeness-status>

Completeness is stated per system and per class. At the $#BL$ level there is no positive result.

#theorem("Incompleteness at the base level")[
  None of TM, $op("TM")_f$, $op("TM")_d$, $op("TM")_c$, $op("TM")_(d c)$ is complete over its
  class.
]

@sec:dichotomy gives the argument for TM itself. $op("TM")_c$ fails identically over ${ZZ, RR}$.
$op("TM")_f$ is the one case that must not be lumped in with the others: it is sound over every
discrete frame, since DF is valid there, but whether it is complete over that class is *open*, and
no counterexample is known. The paper offers no separate incompleteness argument for
$op("TM")_d$ either; its status is covered only by the headline above.

At the $#BLplus$ level three positive results are machine-checked, each of the form
$"Valid"_cal(C) phi.alt arrow.r "Derivable"_cal(C) phi.alt$. They are stated here in the
development's own frame-class vocabulary. The paper attributes them to its systems
$op("TM")^+_d$, $op("TM")^+_f$, $op("TM")^+_c$; that identification is a conjecture, and
@sec:construction says why it is left as one.

#theorem("Weak completeness, dense class")[
  Every sentence valid over every dense task frame is derivable in the Dense frame class.
]
#leansrc("Metalogic.BXCanonical", "completeness_dense")
Axioms: exactly `propext`, `Classical.choice`, `Quot.sound`; no `sorryAx`.

#theorem("Weak completeness, discrete class")[
  Every sentence valid over $ZZ$-time, in its successor-Archimedean formulation, is derivable in
  the Discrete frame class.
]
#leansrc("Metalogic.BXCanonical", "completeness_discrete")
Axioms: exactly `propext`, `Classical.choice`, `Quot.sound`; no `sorryAx`.

#theorem("Weak completeness, dense-and-complete class")[
  Every sentence valid over the dense-and-complete class, which by Hölder's theorem is exactly
  $RR$, is derivable in the Dedekind frame class.
]
#leansrc("Metalogic.BXCanonical", "completeness_dedekind_engine")
Axioms: exactly `propext`, `Classical.choice`, `Quot.sound`; no `sorryAx`.

The fourth result, over *all* task frames, is the stated formalization target and is not a theorem.

#theorem("Base-class completeness (outstanding)")[
  Weak completeness over all task frames, for the Base frame class, is stated in the development as
  `completeness`, with one proof obligation outstanding. Its axiom report contains `sorryAx`. It
  is not an established theorem and is not used below.
]
#leansrc("Metalogic.BXCanonical", "completeness")
#leansrc("Metalogic.WeakCanonical", "countermodel_discrete_reynolds_v2")
#footnote[The `sorryAx` traces to a single dependency, `countermodel_discrete`, which is dead code: the live replacement `countermodel_discrete_reynolds_v2` is what `completeness_discrete` actually calls (@sec:construction). The obligation is therefore narrow and identified, which is not the same as discharged.]

Two further remarks bound what the four results above claim. First, the axiom reports quoted here
are Lean's, and Lean's single `Classical.choice` axiom yields excluded middle and choice
jointly, so an axiom report cannot express the paper's finer distinction between a choice-free
argument and a ZFC one; where that distinction matters it is drawn on the paper side, as in
@sec:histories.#footnote[The development has separately machine-checked that *Spherical* on a finite carrier implies weak excluded middle, so no `Classical.choice`-free Lean proof of Extension could exist even in the finite case.] Second, *strong* completeness --- consequence from a possibly infinite premise
set --- is the aim for $op("TM")^+$ and $op("TM")^+_d$, with no known obstruction over the base and
dense classes; it *provably fails* for $ZZ$-time and for $RR$, where compactness fails. Nothing is
asserted about compactness of the full discrete class in either direction.

#remark[
  No conservativity claim is made for $op("TM")^+$ over TM. The backward direction holds
  unconditionally, since $#BL$ embeds into $#BLplus$. The forward direction fails for the base
  case, witnessed by (DD) in @sec:dichotomy, and fails for the discrete extension via Z1 over
  $ZZ times_"lex" ZZ$; for the dense and complete extensions it is open, with no known
  counterexample.
]#footnote[The paper's former conservative-extension theorem has been deleted; this footnote's four parts replace it.]

== Decidability

#theorem("Decidability")[
  Whether TM, $op("TM")_f$, $op("TM")_d$, $op("TM")_c$, $op("TM")_(d c)$ are decidable is open.
]

Each system is recursively axiomatized, so its theorems are recursively enumerable whatever its
completeness status. Decidability needs the non-theorems recursively enumerable as well, and the
standard route is a finite model property: every non-theorem fails in some effectively enumerable
finite model @chagrovzakharyaschev1997 @goldblatt1992logics. The premise that a finite model
property over $D = ZZ$ delivers this uniformly is false, and is retracted with two witnesses.

#proposition("Failure of a uniform finite model property over $ZZ$")[
  DF is a non-theorem of TM, $op("TM")_d$, $op("TM")_c$, and $op("TM")_(d c)$, yet is valid in
  every model over $D = ZZ$. And CO is a non-theorem of $op("TM")_f$, witnessed by
  $ZZ times_"lex" ZZ$, yet is likewise valid in every model over $D = ZZ$.
]#footnote[A repaired finite model property must be class-specific, ranging over effective non-Archimedean carriers such as $ZZ times_"lex" ZZ$ and not over $ZZ$ alone.]

The failure is not incidental: $ZZ$ is a discrete carrier and bears no relation to the frame
classes of the three non-discrete systems, so no property of models over $ZZ$ could have decided
them. What exists in the development is a tableau procedure whose *soundness* is machine-checked,
together with ongoing work on a semantic, truth-connected finite model property for the $ZZ$-time
discrete case (@sec:construction). No decidability theorem is machine-checked.

#remark[
  The available strategy is reduction. $op("Log")("all task frames") = op("Log")("Discrete") inter op("Log")("Dense")$
  by the dichotomy of @sec:dichotomy, and $op("Log")("complete frames") = op("Th")(ZZ) inter op("Th")(RR)$
  by Hölder's theorem; each identity reduces decidability of the left side to decidability of the
  two factors. This is a target, not a result: neither factor logic is known decidable, and the
  reduction supplies no decision procedure by itself.
]

= The Completeness Construction <sec:construction>

Every completeness result of @sec:completeness-status is proved by contraposition, on the same
plan: an underivable $phi.alt$ makes ${not phi.alt}$ consistent, Lindenbaum extends it to a maximal
consistent set, and a countermodel is read off that set. What differs between the three results is
only the *shape of the flow* the countermodel is built on, and the choice of shape is forced by a
single sentence in the maximal consistent set. This section gives that machinery.

== Consistency and Maximal Consistent Sets

#definition("Consistent and Maximal Consistent Sets")[
  Relative to a frame class $cal(C)$, a set $S$ of $#BLplus$-sentences is *consistent* just in case
  no finite subset of $S$ derives $bot$ in the proof system for $cal(C)$, and *maximal consistent*
  just in case it is consistent and *negation-complete*: $phi.alt in S$ or $not phi.alt in S$ for
  every sentence $phi.alt$.
]
#leansrc("Metalogic.Core", "SetConsistent")
#leansrc("Metalogic.Core", "SetMaximalConsistent")
#footnote[Consistency is defined on finite subsets, so the set-level layer is finitary even though the sets themselves are infinite.]

#lemma("Lindenbaum")[
  Every consistent set of sentences is contained in a maximal consistent set of the same frame
  class.
]
#leansrc("Metalogic.Core", "set_lindenbaum")
The proof is Zorn's lemma over the consistent supersets, whose chains are bounded by their unions;
finitary consistency is what makes a union of a chain of consistent sets consistent.

Write $M$ for a maximal consistent set. Negation-completeness is used below exactly as a
decision procedure: for any sentence $psi$ of interest, $M$ has already settled $psi$ one way or
the other, and the construction may branch on which.

== The Discreteness Dichotomy <sec:dichotomy>

The sentence the construction branches on is $#Nxt top$, and the reason a branch on it is
exhaustive is a fact about temporal orders, not about the logic.

#theorem("Dichotomy")[
  Every temporal order is either discrete or dense, and never both.
]
#proof[
  Suppose $#Dur$ has no least positive element and let $x < y$. Then $y - x$ is not least positive,
  so some $e$ has $0 < e < y - x$, and translation invariance gives $x < x + e < y$; so $#Dur$ is
  dense. Conversely a least positive $e$ admits nothing strictly between $x$ and $x + e$, so
  $#Dur$ is not dense. The argument uses the *group* structure twice, to translate a witness found
  at $0$ to an arbitrary interval and to form the difference $y - x$; it fails for a bare linear
  order, as a copy of $ZZ$ followed by a copy of $QQ$ shows.
]

#corollary[
  $op("Log")("all task frames") = op("Log")("Discrete") inter op("Log")("Dense")$.
]

So the class of all task frames is a disjoint union of two incompatible subclasses and is not
closed under disjoint union. In $#BLplus$ the dichotomy is *internal*: the uniformity axiom NB
($#Nxt top arrow.r square.stroked #Nxt top$) and M5 together give
$ tack.r_(op("TM")^+) square.stroked #Nxt top or square.stroked not #Nxt top, $
so every maximal consistent set contains one of the two disjuncts, and which one it contains fixes
the shape of the flow its countermodel must be built on.

#remark[
  $#BL$ has no sentence naming discreteness, and this is what its incompleteness comes to. The
  disjunction above is available there only as the schema
  $square.stroked phi.alt_(op("DF")) or square.stroked psi_(op("DN")) $, valid over every task
  frame yet TM-unprovable, since a structure with one $ZZ$ fibre and one $RR$ fibre and
  $square.stroked$ read across both is TM-sound while refuting both disjuncts. The same dichotomy
  that leaves $#BL$ with an unprovable validity gives $#BLplus$ a theorem to case-split on. Nothing
  below uses the $#BL$-level schema.
]

== The Three-Way Case Split

#theorem("Case Split")[
  Let $M$ be a maximal consistent set. Then exactly one of the following holds:
  #items[
    + *Dense*: $square.stroked not #Nxt top in M$, and the countermodel is built over $QQ$.
    + *Discrete*: $square.stroked #Nxt top in M$, and the countermodel is built over $ZZ$.
  ]
  The remaining case, in which $M$ contains neither, is impossible.
]
#leansrc("Metalogic.BXCanonical.Chronicle", "mcs_mixed_case_absurd")
The mixed case is eliminated from the axiom NB alone: were $not square.stroked #Nxt top$ and
$not square.stroked not #Nxt top$ both in $M$, contraposing NB and necessitating would put $bot$
in $M$. A maximal consistent set cannot be undecided about discreteness.

#figure(
  cetz.canvas({
    import cetz.draw: *
    let root = (0, 1.5)
    let dense = (-3.3, 0)
    let discrete = (0, 0)
    let mixed = (3.3, 0)
    line(root, dense, stroke: (paint: gray.darken(20%), thickness: 1pt))
    line(root, discrete, stroke: (paint: gray.darken(20%), thickness: 1pt))
    line(root, mixed, stroke: (paint: gray.darken(20%), thickness: 1pt))
    content(root, box(fill: white, stroke: (paint: black, thickness: 1pt), inset: 5pt, radius: 3pt)[
      #text(size: 7.5pt)[MCS $M$: decide $#Nxt top$]
    ])
    content(dense, box(fill: blue.transparentize(85%), stroke: (paint: blue.darken(20%), thickness: 1pt), inset: 5pt, radius: 3pt, width: 3cm)[
      #align(center)[#text(size: 7pt)[Dense \ $square.stroked not #Nxt top in M$ \ chronicle over $QQ$]]
    ])
    content(discrete, box(fill: orange.transparentize(85%), stroke: (paint: orange.darken(20%), thickness: 1pt), inset: 5pt, radius: 3pt, width: 3cm)[
      #align(center)[#text(size: 7pt)[Discrete \ $square.stroked #Nxt top in M$ \ Reynolds/Doets over $ZZ$]]
    ])
    content(mixed, box(fill: red.transparentize(88%), stroke: (paint: red.darken(20%), thickness: 1pt), inset: 5pt, radius: 3pt, width: 3cm)[
      #align(center)[#text(size: 7pt)[Mixed \ eliminated by NB]]
    ])
  }),
  caption: [The case split on $#Nxt top$. The Dedekind class needs no split: there the dense indicator is derivable unconditionally, so the branch that the Base and Discrete arguments must discharge does not arise.],
)

== Coherent Families and the Truth Lemma

A countermodel must interpret $square.stroked$, which quantifies over *all* possible worlds of the
frame at the evaluation time. A single maximal consistent set per time is therefore not enough; the
construction carries a family of them, one indexed history per possible world, and constrains the
family so that the box clause comes out right by fiat.

#definition("Bundled Family of MCSs")[
  A *bundled family* over a duration type $D$ assigns to each family index a map from $D$ to
  maximal consistent sets, subject to two coherence conditions:
  #items[
    + *Forward*: if $square.stroked phi.alt$ belongs to some family's set at time $t$, then
      $phi.alt$ belongs to *every* family's set at $t$.
    + *Backward*: if $phi.alt$ belongs to every family's set at $t$, then $square.stroked phi.alt$
      belongs to each family's set at $t$.
  ]
]
#leansrc("Metalogic.Bundle", "BFMCS")
#footnote[The structure also designates an evaluation family, the one containing the original consistent set.]

The two conditions are exactly the two directions of the box clause, transposed from truth to
membership. Together they discharge the modal case of the truth lemma without any appeal to an
accessibility relation: reflexivity of $square.stroked$, for instance, falls out of Forward applied
to the family itself.

#theorem("Truth Lemma, D-parametric form")[
  A coherent bundled family over any duration type $D$ induces a task frame whose possible worlds
  are the family's indexed histories, and in the induced model a sentence is true at a family and
  time exactly when it belongs to that family's maximal consistent set there.
]
#leansrc("Metalogic.Algebraic", "multiFamTaskFrameGen")
The construction is generic in $D$: it is performed once and instantiated at $QQ$, at $ZZ$, and at
$RR$ by the three branches below. Its frame axioms are discharged separately, and *Spherical* is
discharged by a *third* pattern, distinct from the two of @sec:histories. The induced task relation
is deterministic, so its fibers are subsingletons, and a directed family of nonempty subsingletons
has nonempty intersection outright.#footnote[`multiFamGen_spherical`, via the reusable helper `sInter_nonempty_of_directed_subsingleton`. The argument sees only the shape of the fibers, so it applies to every deterministic frame. Contrast the finite-carrier discharge (`cor:spherical-finite`) and the Zorn route through the Step Lemma (`thm:extension`); this third pattern is what @sec:representation returns to.]

== The Dense Branch

#definition("Chronicle")[
  A *chronicle* over a maximal consistent set $A$ assigns a maximal consistent set to each point of
  a domain $X subset.eq QQ$, subject to coherence conditions C0--C5 relating the assignments at
  distinct points to the Since and Until sentences they contain. It is built as the limit of an
  $omega$-chain: the *singleton chronicle* maps $0$ to $A$; each successor step eliminates one
  potential counterexample, enumerated from $QQ times "Formula" times "Formula" times "Bool"$; and
  the limit is the union of the chain.
]
#leansrc("Metalogic.BXCanonical.Chronicle", "singletonChronicle")
#leansrc("Metalogic.BXCanonical.Chronicle", "omegaChain")
#footnote[Countability of the enumeration is what makes an $omega$-chain sufficient.]

The obligation the chain exists to discharge is *eventuality-filling*. A sentence
$phi.alt #until psi$ in a chronicle's set at $t$ is a promise that $psi$ holds at some later
point of the domain with $phi.alt$ throughout the interval; a chronicle need not keep such a
promise, and a countermodel must. Each step of the chain keeps one promise, and because every
potential counterexample is enumerated, the limit keeps them all.#footnote[`limit_satisfies_c5_strong` and its Since mirror `limit_satisfies_c5'_strong`, in the same module. The construction is Burgess's @burgess1982axioms, whose $omega$-chain over $QQ$ is what makes density available: a new witness can always be inserted between two existing points.]

The limit chronicle induces a bundled family over $QQ$ satisfying the coherence conditions of the
previous subsection, and the truth lemma then gives a countermodel. This is `completeness_dense`.

== The Discrete Branch

Over $ZZ$ no witness can be inserted between adjacent points, so the chronicle chain is
unavailable and the argument runs the other way: build a structure first, then show it is
*indistinguishable* from one over $ZZ$.

#definition("The Reynolds pipeline")[
  For a fixed quantifier depth $k$, a linearly ordered structure with monadic predicates is *good*
  when it is $k$-equivalent to a structure assembled from finitely many one-class pieces, and
  *very good* when that decomposition is uniform. The pipeline shows the chronicle's limit domain
  is good, extracts a $k$-equivalent interval of $ZZ$, and transfers satisfiability across the
  $k$-equivalence.
]
#leansrc("Metalogic.WeakCanonical", "one_class")
#leansrc("Metalogic.WeakCanonical", "VeryGood")
#leansrc("Metalogic.WeakCanonical", "good")
#leansrc("Metalogic.WeakCanonical", "limitdom_is_good")
#leansrc("Metalogic.WeakCanonical", "truth_transfer")
#footnote[The decomposition technique is Doets's @doets1987; the step-by-step k-equivalence argument for Until/Since is Reynolds's @reynolds1992, as developed in Gabbay, Hodkinson, and Reynolds @gabbayhodkinsonreynolds1994.]

Transfer is sound because $k$-equivalence preserves the truth of every formula of quantifier depth
at most $k$, and the refuted sentence has a fixed depth. The resulting countermodel over $ZZ$ is
`countermodel_discrete_reynolds_v2`, and it is what `completeness_discrete` calls.

#remark[
  This is *not* an application of Kamp's theorem. Kamp's expressive-completeness result --- that
  over Dedekind-complete flows the strict Until/Since language captures every first-order condition
  on a linear order with monadic predicates in one free variable --- is a different statement, and
  it is not machine-checked here.#footnote[Kamp's 1968 dissertation @kamp1968, with the modern proof due to Rabinovich @rabinovich2014; it is frequently attributed to Kamp's 1971 _Theoria_ paper @kamp1971formalproperties, which introduces the *now* operator and does not contain it. Both scope conditions do work: the operators must be strict, as they are here, and the flow must be Dedekind complete.] `Metalogic/WeakCanonical/Kamp/` develops toward the statement
  `kampPriorExpressiveCompleteness`, which remains open. The discrete branch depends on none of it:
  $k$-equivalence is a coarser tool, and coarser is enough when only one sentence must be refuted.
]

== The Dedekind Branch

Over $RR$ the case split is not needed at all: the class is dense, so the dense indicator is
available unconditionally and the branch that the base and discrete arguments must discharge does
not arise.

#definition("The real-model construction")[
  A good structure over a dense order is *shuffled* into a structure over $RR$: the one-class
  pieces are interleaved densely, and the result is shown order-isomorphic to $RR$ by a
  back-and-forth argument. Truth transfers along the isomorphism.
]
#leansrc("Metalogic.WeakCanonical", "doets_theorem_dense")
#leansrc("Metalogic.WeakCanonical", "reynolds_lemma13")
#leansrc("Metalogic.WeakCanonical", "kEquiv_shuffle_shuffleReal")
#leansrc("Metalogic.WeakCanonical", "epsDense_isContempEquiv")
#leansrc("Metalogic.WeakCanonical", "orderIsoRealOfDedekindDenseSeparable")
#footnote[The basis is the Reynolds triple Prior-U, Prior-S, and Sep, with CO derived.]

The engine is `completeness_dedekind_engine`. Its consequence form,
`consequence_completeness_dedekind`, is what the development calls *consequence completeness*
and not strong completeness: a derivation's context is a finite list, so a finite-context
consequence result is inter-derivable with weak completeness by the deduction theorem, and the
term *strong* is reserved for consequence from a possibly infinite premise set.

== Machine-Checked Status

The axiom reports below were taken at commit 7aae4e51c via `scripts/typst-status-counts.sh`.

#figure(
  table(
    columns: 4, stroke: none, align: (left, left, left, left),
    table.hline(),
    table.header([*Declaration*], [*Module*], [*Axioms*], [*`sorryAx`*]),
    table.hline(),
    [`completeness_dense`], [`BXCanonical/Completeness.lean`], [`propext`, `Classical.choice`, `Quot.sound`], [no],
    [`completeness_discrete`], [`BXCanonical/Completeness.lean`], [same], [no],
    [`countermodel_dense`], [`Chronicle/ChronicleToCountermodelBasic.lean`], [same], [no],
    [`completeness_dedekind_engine`], [`BXCanonical/CompletenessDedekind.lean`], [same], [no],
    [`completeness`], [`BXCanonical/Completeness.lean`], [same, plus `sorryAx`], [*yes*],
    table.hline(),
  ),
  caption: [Axiom reports for the four completeness results and the shared dense countermodel.],
)

Outside `Boneyard/`, the development contains exactly one structural `sorry`, and it is the source
of the single `sorryAx` above: `countermodel_discrete` in `WeakCanonical/Transfer.lean`. It is dead
code. `completeness_discrete` routes through `countermodel_discrete_reynolds_v2` instead, which is
a different theorem and is sorry-free; the dead chain was excised precisely because the bypass
made it unreachable. What the `sorryAx` on the general Base-frame `completeness` records is
therefore a stale dependency edge, not an unproved mathematical step in any result stated in this
report --- but the edge is real, and until it is cut the theorem's axiom report says so.

The algebraic layer of @sec:representation measures zero sorries.

#remark[
  The vocabulary above is the development's own: `FrameClass.Base`, `Dense`, `Discrete`,
  `Dedekind`. It is not silently identified with the paper's $op("TM")^+$, $op("TM")^+_d$,
  $op("TM")^+_f$, $op("TM")^+_c$. The two axiomatizations do line up in shape --- the paper states
  eleven primary Since/Until axioms and derives their past mirrors by the rule TD, while the
  development has no TD rule and states all twenty-two explicitly, one pair per paper axiom --- but
  no theorem establishes that they prove the same sentences, and the uniformity layer does not even
  match in count. The identification is a conjecture and is treated as one throughout.
]

Decidability's two machine-checked components are narrower than the open question of
@sec:key-theorems: `decide_sound` establishes that the tableau procedure never accepts a
non-theorem, and `fmp_completeness` is a finite-filtration statement whose bridge to semantic
validity is a separate, open obligation.#footnote[Both in `Metalogic/Decidability/Correctness.lean`. Soundness of a decision procedure without the matching completeness bridge does not yield a decision procedure.]

= Two Costs of the Semantics <sec:costs>

The construction of @sec:construction buys completeness at a price paid in the semantics, not in
the proof theory, and the price has two components. The first is that the structure of time comes
out necessary. The second is that the operator $square.stroked$ is picked out by a higher-order
condition that the object language cannot state. They are not independent, and the closing remark
of this section says where they meet.

== The Contingency of the Temporal Axioms <sec:contingency>

By @sec:key-theorems's Correspondence proposition, each of Discrete, Dense, and Complete is
characterized by an axiom, giving the systems $op("TM")_f$, $op("TM")_d$, $op("TM")_c$, with
$op("TM")_(d c)$ the minimal common extension of the last two. By the Dichotomy no temporal order
is both discrete and dense, so no consistent system contains both DF and DN.

#proposition("Necessity of temporal structure")[
  If $#taskframe #satisfies phi.alt$ then $#taskframe #satisfies square.stroked phi.alt$. In
  particular, over a dense frame both DN and $square.stroked "DN"$ are valid.
]
#proof[
  Immediate from the truth clause for $square.stroked$: it quantifies over $H_(#taskframe)$, so if
  $phi.alt$ holds at every possible world and time of every model on $#taskframe$, then so does
  $square.stroked phi.alt$.
]

So whichever structure $#Dur$ has --- discrete or dense, Dedekind complete or not --- it holds of
metaphysical necessity in that system. Dorr and Goodman @dorr2020diamonds express sympathy for an
account of metaphysical modality able to express theses about the contingency of the structure of
time, and this is the cost that view charges here.

#remark[
  The phenomenon is not special to task semantics. It is an instance of frame validity being
  closed under necessitation, and the Kripke case supplies the precedent: over symmetric frames
  the axiom B and its necessitation are both valid, so symmetry is necessary-if-true wherever it
  holds. Structural disputes about metaphysical modality are already conducted in this key ---
  whether S4 or S5 is the correct logic for $square.stroked$, whether the objective modalities
  are closed under converses and so validate B --- and never as claims that transitivity or
  symmetry is itself metaphysically contingent. Since possible worlds are only ever defined over
  a single frame, no modality of the theory quantifies across frames, and so none can express the
  contingency in question.
]

The response available inside the framework is to relax totality.

#definition("Irregular World")[
  An *irregular world* over a frame $#taskframe$ is a function $tau : X arrow.r #worldstate$ where
  $X subset.neq D$ is a *coset domain* --- a translate $G + c$ of a nontrivial subgroup
  $G lt.eq #Dur$ --- and $tau(x) arrow.r.double.long_(y-x) tau(y)$ for all $x, y in X$. Consequence
  is then defined over the irregular and the possible worlds alike.
]#footnote[Cosets and not subgroups: a family of translates is closed under ambient translation and so preserves MF and the perpetuity principles, which the subgroup formulation loses.]

#proposition("The price of irregular worlds")[
  Under the broadened consequence relation:
  #items[
    + DN is valid over *no* frame whatever, since every nontrivial ordered abelian group contains a
      discrete cyclic subgroup.
    + DF fails over discrete orders possessing a subgroup that is itself dense, such as
      $QQ times_"lex" ZZ$.
    + The three correspondences of @sec:key-theorems therefore lapse together.
    + $square.stroked$ remains factive, normal, and closed under necessitation relative to the
      broadened consequence relation, but is *displaced* from its standing as the strongest
      objective modality.
  ]
]#footnote[Parts (i)--(iii) are the paper's own; its verdict there is that "these considerations recommend possible over irregular worlds." Part (iv) is this document's addition, grounded in the Strongest Objective Normal Modal Operator definition and the Existence theorem below together with the observation that broadening the consequence relation changes which operator is $prec.eq$-least; the paper's sentence stating it is commented out in the live source and is not cited as paper text.]

Parts (i)--(iii) are severe: they cost the three theorems that make the frame-class hierarchy
mean anything. What is bought is contingency in the *structure and cardinality* of the time
series, and not composition contingency of the catastrophe or proper-initial-segment kind, since a
difference-closed domain is a subgroup or a translate of one and so is unbounded in both
directions either way.

#remark[
  The question this leaves open is whether some semantics recovers temporal-structure contingency
  without lapsing the correspondences. The target is a class of frames closed under disjoint
  union: by the Dichotomy the unrestricted class is not one, and @sec:representation returns to
  what a class that is one would have to look like.
]

== The Strongest Objective Modality <sec:objective-modality>

The apparatus needed is higher-order. $#BL$ is extended with a primitive propositional identity
operator $equiv$, axiomatized minimally by Ref, Imp, and LL and not assumed Boolean, together with
quantifiers over an unrestricted domain of operations on propositions. The objective modalities are
*axiomatized* by a primitive predicate $O$ on operator terms, following Bacon's theory of
necessities @bacon2022necessities, and not defined outright.#footnote[*Predicativity* --- operator comprehension restricted to formulas with no operator variables and no occurrence of $O$ --- blocks Russell--Myhill while keeping a fine-grained identity; Walsh @walsh2016predicativity proves consistency for a predicative restriction of Church's intensional logic. It could be traded for a coarse-grained identity, which blocks Russell--Myhill too.]

#definition("Strongest Objective Normal Modal Operator")[
  $Q$ is a *strongest objective normal modal operator in $L$* --- written $op("Str")^O_L (Q)$ ---
  iff (1) $tack.r O(Q)$ and (2) $tack.r forall P [O(P) arrow.r (Q prec.eq P)]$, where $prec.eq$ is
  the dominance ordering. Objectivity and normality are not stated separately: clause (1) entails
  them.
]

#theorem("Existence")[$op("Str")^O_L (B m)$: the meet operator is a strongest objective normal modal operator, so $L$ contains one.]#footnote[Clause (1) is the second conjunct of O-Meet, clause (2) follows from the first, and T, N, K, and necessitation-closure follow by detaching O-Fac, O-Ax, and O-Nec at $B m$.]

#theorem("Uniqueness and logic")[
  Any two strongest objective normal modal operators are provably equivalent. If
  $op("Str")^O_L (Q)$ then $Q$ satisfies S4 and B. In particular, under the hypothesis
  $op("Str")^O_L (square.stroked)$, the logic of $square.stroked$ is S5.
]#footnote[Under the hypothesis, the uniqueness lemma gives $tack.r forall p(square.stroked p arrow.l.r B m p)$, and factivity and necessitation follow by detaching O-Fac and O-Nec.]

Being S5 is not enough to identify $square.stroked$, and the paper supplies its own counterexample.

#proposition("Orthogonality")[
  A strictly narrower accessibility relation can carry a strictly stronger logic. The *Stability*
  operator --- $#model, tau, x #satisfies "Stability" phi.alt$ iff $phi.alt$ holds at $x$ in every
  possible world occupying the same world state as $tau$ at $x$ --- is S5, since its accessibility
  is the equivalence relation $sigma tilde.op_x tau$ iff $sigma(x) = tau(x)$. Yet on non-temporal
  sentences $phi.alt arrow.r "Stability" phi.alt$ is valid, so Stability collapses to the trivial
  modality on that fragment.
]#footnote[The general lesson drawn in the statement is this document's own; the paper's sentence stating it generally is commented out in the live source and is not cited as paper text.]

It is $prec.eq$-leastness, and not S5-hood, that picks $square.stroked$ out.

#remark[
  The cost is that leastness is a condition of the higher-order theory, and the link between the
  two levels is a *hypothesis*, $op("Str")^O_L (square.stroked)$, adopted afresh for each system
  under study and never a theorem of TM or $op("TM")^+$. Whether the characterization is
  expressible or derivable at the propositional level at all is open, as is what a propositional
  axiomatization would have to add.
]

#remark[
  The two costs meet at part (iv) of the price above. Broadening the consequence relation to admit
  irregular worlds is exactly what displaces $square.stroked$ from $op("Str")^O_L (square.stroked)$,
  so the move that would answer the first cost forfeits the hypothesis on which the second cost's
  only positive result rests. Any semantics recovering temporal contingency must therefore say
  which operator is strongest under the broadened relation, and that question is not addressed by
  either cost taken alone.
]

= Toward a Representation Theorem <sec:representation>

A representation theorem here would characterize the class of task models abstractly: an
algebraic or first-order description, together with constructions carrying each description to a
task model and each task model to a description, inverse up to the appropriate equivalence. What
makes this the live question is not tidiness. Strong completeness for the base and dense classes
needs a model-existence theorem --- every consistent set satisfiable in a frame of the class ---
and none of the countermodel engines of @sec:construction delivers one, since each refutes a
single sentence. A representation theorem is the standard route to model existence, by way of
compactness.#footnote[An earlier unpublished draft sketched a representation theorem and is superseded; its canonical order was hard-coded to $ZZ$ instead of parametric in $D$, and it asserted TM sound *and complete* over all task frames, which `cor:tm-completeness` refutes. No definition, statement, or proof step from it is used here.]

== The Algebraic Layer

One route has live, sorry-free groundwork.

#definition("The Lindenbaum--Tarski Algebra")[
  Quotient the sentences of $#BLplus$ by provable equivalence. The result carries a Boolean algebra
  structure induced by the connectives, on which $#allpast$ and $#allfuture$ act as *interior
  operators*: each is monotone, deflationary on the relevant order, and idempotent, so each is
  determined by its algebra of fixed points. The ultrafilters of this algebra correspond
  bijectively to the maximal consistent sets of @sec:construction.
]
#leansrc("Metalogic.Algebraic.LindenbaumQuotient", "LindenbaumAlg")
#leansrc("Metalogic.Algebraic.InteriorOperators", "boxInterior")
#leansrc("Metalogic.Algebraic.UltrafilterMCS", "mcsToUltrafilter")
#footnote[The flow-frame engine of @sec:construction lives alongside them in `FlowFrame.lean`. All five measure sorry-free.]

#remark[
  The correspondence is Stone's @stone1936, specialized: points of the dual space are ultrafilters
  and the modal operators become operations on that space. What the layer supplies is one half of a
  duality --- the passage from syntax to an algebra and from the algebra to a space of points. What
  it does not yet supply is the passage back, from an abstract algebra to a *task frame*, which is
  where the frame axioms of @sec:system enter and where the difficulty is.
]

Three candidate routes exist and are not equally positioned.

#figure(
  table(
    columns: 3, stroke: none, align: (left, left, left),
    table.hline(),
    table.header([*Route*], [*State*], [*Blocking condition*]),
    table.hline(),
    [Lindenbaum--Tarski algebra, ultrafilters, interior operators], [live, sorry-free], [supplies one direction only],
    [Jónsson--Tarski completion: complex algebra, ultrafilter frame, canonical embedding], [archived], [*Spherical* at infinite carriers],
    [Shift sets and the two-sorted ultraproduct], [design only; no identifier exists], [feasibility not yet tested],
    table.hline(),
  ),
  caption: [The three routes toward a representation theorem.],
)

The Jónsson--Tarski route @jonssontarski1951 @jonssontarski1952 --- the complex algebra
$"Cm"(#taskframe)$ of a frame, the ultrafilter frame $"Uf"(A)$ of an abstract algebra, and the
canonical embedding $eta(a) = {U : a in U}$ --- was moved out of the live tree into an archived
subtree, and nothing under it is live. The obstruction on revival is stated below and is the same
one the whole section turns on.

#figure(
  cetz.canvas({
    import cetz.draw: *
    let start = (-4.4, 0)
    let algMid = (-1.3, 1.0)
    let algEnd = (1.5, 1.0)
    let jtEnd = (4.2, 1.0)
    let ssMid = (-1.3, -1.0)
    let ssEnd = (4.2, -1.0)
    let boxstyle(fill-c, stroke-c) = (fill: fill-c, stroke: (paint: stroke-c, thickness: 1pt), inset: 4pt, radius: 3pt, width: 2.5cm)
    content(start, box(fill: white, stroke: (paint: black, thickness: 1pt), inset: 4pt, radius: 3pt)[#text(size: 7pt)[task-model class]])
    line(start, algMid, stroke: (paint: gray.darken(20%), thickness: 1pt), mark: (end: ">"))
    content(algMid, box(..boxstyle(green.transparentize(85%), green.darken(20%)))[#align(center)[#text(size: 6.5pt)[Lindenbaum--Tarski algebra -- *live*]]])
    line(algMid, algEnd, stroke: (paint: gray.darken(20%), thickness: 1pt), mark: (end: ">"))
    content(algEnd, box(..boxstyle(green.transparentize(85%), green.darken(20%)))[#align(center)[#text(size: 6.5pt)[ultrafilters, interior operators -- *live*]]])
    line(algEnd, jtEnd, stroke: (paint: gray.darken(20%), thickness: 1pt, dash: "dashed"), mark: (end: ">"))
    content(jtEnd, box(..boxstyle(red.transparentize(88%), red.darken(20%)))[#align(center)[#text(size: 6.5pt)[Jönsson--Tarski duality -- *archived*]]])
    line(start, ssMid, stroke: (paint: gray.darken(20%), thickness: 1pt), mark: (end: ">"))
    content(ssMid, box(..boxstyle(orange.transparentize(85%), orange.darken(20%)))[#align(center)[#text(size: 6.5pt)[shift-set design -- *target*]]])
    line(ssMid, ssEnd, stroke: (paint: gray.darken(20%), thickness: 1pt, dash: "dashed"), mark: (end: ">"))
    content(ssEnd, box(..boxstyle(orange.transparentize(85%), orange.darken(20%)))[#align(center)[#text(size: 6.5pt)[ultraproduct pipeline -- *not started*]]])
  }),
  caption: [Both routes begin in live, sorry-free work and end in a target. Solid arrows mark completed steps; dashed arrows mark the gap.],
)


== The Shift-Set Target

#definition("Shift set")[
  A *shift set* is a structure $(Omega, D, "sh", A)$ where $D$ is an ordered abelian group,
  $Omega$ is a nonempty set carrying a $D$-action $"sh" : Omega times D arrow.r Omega$, and $A$
  assigns to each sentence letter a subset of $Omega$.
]

The target is a pair of constructions: every shift set induces a task model, and every task model
arises from one, so that the class of task models is captured by a first-order theory in the
two-sorted signature $(Omega, D; <, +, 0, "sh", (A_p))$. The payoff is exactly first-order
axiomatizability, and the reason to expect it is that the frame's algebraic content reaches truth
only through the atom clause: by @sec:system a sentence's truth at $(tau, x)$ depends on the frame
only via the world state $tau(x)$, so a structure that records where the action sends each point
records everything truth can see.

Shift sets are ordinary mathematics here, not names in the development: no such identifier exists
anywhere in the tree, and the programme is not started. The design document's own Lean signatures
predate the total-history refactor and would need restating; the argument they encode is what
survives, not the signatures.

#remark[
  This is the project's declared gate. The expensive semantic-compactness programme --- an
  ultraproduct of carriers, a Łoś lemma for truth, compactness, and per-class strong completeness
  --- is deliberately not authorized until the shift-set representation theorem lands sorry-free in
  *both* directions with a clean axiom report. If either direction is refuted, the route is
  cancelled and not retried. The gate is cheap and the programme behind it is not, which is why the
  ordering matters.
]

#remark[
  Expressive completeness is not representation, and the distinction is worth keeping because the
  machinery of @sec:construction invites confusion. Kamp's theorem says a *language* captures every
  first-order condition over a class of flows; a representation theorem says a *class of
  structures* is the image of a construction from abstract data. The first is used inside the
  discrete branch's neighborhood as an expressiveness fact about Until and Since; the second is
  what is wanted here, and no amount of the first yields it. Metric tense operators --- indexed
  operators saying that $phi.alt$ holds exactly $d$ hence --- bear on the second, not the first:
  they would put $D$ into the object language, which is precisely the two-sorted signature above
  made internal, and would make the first-order axiomatizability claim a statement about the logic
  itself and not about a metatheoretic signature. The cost is that they change the logic: the systems
  of @sec:system have no metric operators and their completeness results would not transfer, so
  this is a proposal about the representation target and not a repair to what is already proved.
]

== The Obstruction

Two arguments carry the weight. The first identifies which frame axiom is the difficulty.

Of the four axioms of @sec:system, *Spherical* is the one that resists. Three discharge patterns
are known and none covers the case needed: the finite-carrier argument, which is choice-free but
requires finiteness; the Zorn argument through the Step Lemma, which is general but yields no
construction; and the deterministic-fiber argument of @sec:construction, which is constructive but
requires determinism. Ultrafilter frames are typically infinite and are not deterministic, so the
Jónsson--Tarski route meets all three at once and clears none.

The second argument locates the crux one level down, in the group structure.

The Dichotomy of @sec:dichotomy is a theorem about ordered abelian *groups*, and its proof uses
translation invariance and the existence of differences. It fails for a bare linear order. So
weakening $D$ --- to a linearly ordered set, a monoid, or a partially ordered group --- dissolves
the discreteness obstruction outright. The cost is precise and is charged to the parts of the
theory that use the group operations: MF and the perpetuity principles depend on translation
invariance, the converse convention depends on negation, and *Compositionality* is stated in terms
of addition. What survives each weakening is what a general representation theorem must be stated
over, and it is not yet worked out.

#remark[
  Three further points collapse into one. Whether the algebraic and shift-set routes are the same
  theorem twice is open; whether the coset-domain construction of @sec:contingency is the route to
  disjoint-union closure, at the price of the correspondences, is open; and strong completeness is
  *foreclosed* for $ZZ$-time and for $RR$, where compactness fails, so any proposal promising it
  there is wrong on arrival.#footnote[The development records an explicit non-compactness witness for the successor-Archimedean discrete case, and Reynolds @reynolds1992 establishes the analogous failure over $RR$.]
]

The section closes with the question the rest of it reduces to.

#remark[
  *Open question.* Is there a condition $Phi$ on task relations that (a) holds of every frame with
  finite carrier and of every deterministic frame, (b) suffices in place of *Spherical* for the
  Step Lemma, and (c) is preserved under the passage from an algebra to its ultrafilter frame? An
  affirmative answer revives the Jónsson--Tarski route and, with it, the duality that the algebraic
  layer currently supplies in one direction only. A negative answer would show the obstruction is
  not an artifact of how *Spherical* is stated, and would make the shift-set route the only one
  left.
]


#bibliography("bibliography.bib")
