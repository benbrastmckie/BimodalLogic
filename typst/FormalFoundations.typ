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
#import "template.typ": thmbox-show, URLblue, definition, theorem, lemma, axiom, remark, proof, corollary, proposition, leansrc, items

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
// Local notation for this report
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

// FIX: no indent here, and smaller font, creating an environment as appropriate
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
]#footnote[`def:BLplus-language`. @brastmckie2026possibleworlds The paper's base language $#BL$ replaces $#since$ and $#until$ with the one-place operators $#allpast$ and $#allfuture$ taken as primitive; $#BL$ embeds into $#BLplus$ under the definitions of @def-operators, and every $#BL$-theorem is recovered. Nothing below depends on the base language, and it is not used again. The paper is @brastmckie2026possibleworlds, available at #link("https://benbrastmckie.com/publications/possible_worlds.pdf")[benbrastmckie.com].]

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
] <def-operators>#footnote[`def:BLplus-defined`. @brastmckie2026possibleworlds]

Each defined operator has the clause its name advertises: $#allpast$ and $#allfuture$ are the
universal past and future tenses, and over a discrete order $#Nxt phi.alt$ holds exactly when
$phi.alt$ holds at the immediate successor, while $#Nxt phi.alt$ is equivalent to $bot$ at any time
lacking one.#footnote[`thm:BLplus-PastFuture`, `thm:BLplus-NextPrevious`. @brastmckie2026possibleworlds The guard $bot$ in $#Nxt phi.alt := bot #until phi.alt$ forces the open interval to the witness to be empty, which over a discrete order means the witness is the immediate successor.]
The sentence $#Nxt top$ therefore *says* that the present moment has an immediate successor. That
one sentence is what separates $#BLplus$ from $#BL$ everywhere below: it is the
discreteness indicator on which the completeness construction of @sec:construction case-splits, and
its absence from $#BL$ is what produces the split validity of @sec:dichotomy.

== Frames

#definition("Temporal Order")[
  A *temporal order* is a nontrivial totally ordered abelian group $#Dur = (D, +, 0, lt.eq)$ with
  *positive cone* $D^+ := {x in D : x gt.eq 0}$.
]#footnote[`def:temporal-order`. @brastmckie2026possibleworlds]

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
]#footnote[`def:task-relation`. @brastmckie2026possibleworlds The relation is primitive only on $D^+$; negative durations are defined, not given.]

#definition("Directed Family")[
  A nonempty family of sets $cal(S)$ is *directed* just in case $S subset.eq S_1 inter S_2$ for
  some $S in cal(S)$ whenever $S_1, S_2 in cal(S)$.
]#footnote[`def:directed`. @brastmckie2026possibleworlds]

#definition("Frame")[
  A *frame* is any $#taskframe = (#worldstate, #Dur, arrow.r.double.long)$ where $#worldstate$ is a
  nonempty set of world states, $#Dur$ is a temporal order, and $arrow.r.double.long$ is a task
  relation satisfying, for $x, y gt.eq 0$:
  #items[
    + *Compositionality*: $w arrow.r.double.long_(x+y) v$ if and only if
      $w arrow.r.double.long_(x) u$ and $u arrow.r.double.long_(y) v$ for some $u in #worldstate$.
    + *Seriality*: $w arrow.r.double.long_(x) u$ and $v arrow.r.double.long_(x) w$ for some
      $u, v in #worldstate$.
    + *Limit*: $inter.big_(x > 0) (w)_x = {w}$.
    + *Spherical*: $inter.big cal(S) eq.not emptyset$ for any directed family $cal(S)$ of nonempty
      fibers and segments.
  ]
]#footnote[`def:frame`. @brastmckie2026possibleworlds Compositionality is a biconditional, load-bearing in both directions.]

#lemma("Nullity")[$w arrow.r.double.long_(0) w$ for every world state $w$ of every frame.]#footnote[`lem:nullity`. @brastmckie2026possibleworlds]
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
    + A *partial history* is a function $tau : X arrow.r #worldstate$ on a nonempty $X subset.eq D$
      with $tau(x) arrow.r.double.long_(y-x) tau(y)$ for all $x, y in X$.
    + A *world history* is a partial history whose domain is *convex*: $y in X$ whenever
      $x, z in X$ and $x < y < z$.
    + A world history is *total* --- equivalently, a *possible world* --- just in case $X = D$.
    + $sigma$ *extends* $tau$ just in case $"dom"(tau) subset.eq "dom"(sigma)$ and
      $tau(x) = sigma(x)$ throughout $"dom"(tau)$.
    + $H_(#taskframe)$ is the set of all total world histories over $#taskframe$.
  ]
]#footnote[`def:world-history`. @brastmckie2026possibleworlds]

#theorem("Extension")[
  Every partial history over a frame is extended by some total world history.
]#footnote[`thm:extension`. @brastmckie2026possibleworlds]
#proof[
  The partial histories extending $tau$ are ordered by extension, and every chain is bounded above
  by its union, which is again a partial history since any two of its times already lie in a common
  member of the chain. Zorn's lemma yields a maximal $sigma : T arrow.r #worldstate$ extending
  $tau$. Were $T eq.not D$, the Step Lemma would extend $sigma$ to $T union {z}$ for
  $z in D without T$, against maximality; so $T = D$.
]

#corollary("Occurrence")[
  For every frame $#taskframe$, world state $w$, and time $x$, some $tau in H_(#taskframe)$ has
  $tau(x) = w$. In particular $H_(#taskframe) eq.not emptyset$.
]#footnote[`cor:occurrence`. @brastmckie2026possibleworlds]

The Step Lemma is the sole application site of *Spherical* in the paper, and Extension is the sole
consumer of the Step Lemma; every appeal to *Spherical* in the semantics passes through this one
point.#footnote[`lem:step`. @brastmckie2026possibleworlds The Step Lemma's own proof notes that *Spherical* is not needed when the directed family has a $subset.eq$-least member. On a finite carrier *Spherical* holds outright and choice-free (`cor:spherical-finite`), so the Zorn appeal is the general case only.] Extension and Occurrence are theorems of ZFC, in contrast with Nullity. That
localization is what makes *Spherical* the identified obstruction of @sec:representation.

The cones are a basis for a topology on world states, and that topology is separated.

#definition("Task Topology")[
  For a frame $#taskframe$, let $B_(#taskframe) := {(w)_x : w in #worldstate, x in D, x > 0}$ and
  let $cal(O)_(#taskframe)$ be the closure of $B_(#taskframe)$ under arbitrary union and finite
  intersection; write $cal(T)_(#taskframe) := (#worldstate, cal(O)_(#taskframe))$. For
  $S subset.eq #worldstate$, $overline(S) := {w : O inter S eq.not emptyset$ for every open $O in.rev w}$.
  The topology is *T1* just in case $overline({w}) = {w}$ for all $w$, and *R0* just in case
  $w in overline({u})$ iff $u in overline({w})$ for all $w, u$.
]#footnote[`def:task-topology`. @brastmckie2026possibleworlds The topology is carried by the world states, not by $H_(#taskframe)$ or by $D$.]

#theorem("Separation")[$cal(T)_(#taskframe)$ is T1, and hence R0, for every frame $#taskframe$.]#footnote[`app:topology-t1`, `app:topology-r0`. @brastmckie2026possibleworlds]
#proof[
  ${u} subset.eq overline({u})$ is immediate. Conversely let $w in overline({u})$. By Nullity
  every basic open $(w)_x$ contains $w$, so $u in (w)_x$ for every $x > 0$; hence for each such $x$
  there is $y$ with $|y| < x$ and $w arrow.r.double.long_(y) u$, so $u arrow.r.double.long_(-y) w$
  by the converse convention and $w in (u)_x$. *Limit* then gives
  $w in inter.big_(x>0)(u)_x = {u}$. R0 follows at once.
]

#remark[
  Extension makes every partial history a restriction of a possible world, and Separation shows the
  cone topology distinguishes world states. Whether these results license *defining* a partial
  history as a restriction of a possible world, instead of defining it independently and proving
  Extension, is a question about the order of the theory and not about its content: the two
  definitions agree extensionally, by Extension. They differ in what must be assumed at the outset.
  The restriction definition makes $H_(#taskframe)$ prior and hides the appeal to *Spherical*
  inside the existence of the objects it quantifies over; the order taken here keeps *Spherical*
  visible at the single site where it is used.
]

== Models and Truth

#definition("Model")[
  A *model* is a structure $#model = (#worldstate, #Dur, arrow.r.double.long, |dot.c|)$ where
  $(#worldstate, #Dur, arrow.r.double.long)$ is a frame and $|p_i| subset.eq #worldstate$ for every
  sentence letter $p_i$.
]#footnote[`def:BL-model`. @brastmckie2026possibleworlds An interpretation assigns each sentence letter a set of *world states*. Truth at a time is mediated entirely by the world state the history occupies there; this is the content of the atomic clause below, and it is what makes a possible world a trajectory through a fixed state space and not an independent index.]

#definition("Truth")[
  Truth in a model $#model$ at a possible world $tau in H_(#taskframe)$ and a time $x in D$ is
  defined by:
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
]#footnote[`def:BL-semantics`, `def:BLplus-semantics`. @brastmckie2026possibleworlds The two share their models; the extended language adds only the last two clauses.]

$square.stroked$ quantifies over the possible worlds of the frame at the *same* time, and over all
of them. It is not a relational modality with an accessibility relation to be tuned: the frame
fixes $H_(#taskframe)$, and $square.stroked$ ranges over that set entire. Its logic is
correspondingly S5, and @sec:objective-modality takes up what else, beyond being S5, is needed to
single it out.

#definition("Frame Properties")[
  A frame is *Discrete* if every $x in D$ having some $y > x$ has a least such; *Dense* if
  $x < z < y$ for some $z$ whenever $x < y$; *Complete* if every nonempty subset of $D$ bounded
  above has a least upper bound; and *Deterministic* if $w arrow.r.double.long_(x) u$ and
  $w arrow.r.double.long_(x) v$ imply $u = v$.
]#footnote[`def:frame-properties`. @brastmckie2026possibleworlds The first three constrain $#Dur$; the fourth constrains $arrow.r.double.long$.]

#definition("Validity and Consequence")[
  $#taskframe #satisfies phi.alt$ just in case $#model, tau, x #satisfies phi.alt$ for every model
  $#model$ on $#taskframe$, every $tau in H_(#taskframe)$, and every $x in D$. And
  $Gamma #satisfies phi.alt$ just in case, for every model, possible world, and time at which every
  member of $Gamma$ is true, $phi.alt$ is true; $phi.alt$ is *valid* when $emptyset #satisfies phi.alt$.
]#footnote[`def:frame-validity`, `def:logical-consequence`. @brastmckie2026possibleworlds]

By Occurrence $H_(#taskframe)$ is never empty, so frame validity is never vacuous and
$#taskframe #notsatisfies bot$ for every frame. Fixing $H_(#taskframe)$ with the frame does not
make $#taskframe$ a *general frame* in the sense of Blackburn, de Rijke, and Venema
@blackburnderijkevenema2001: a general frame restricts the admissible valuations to a designated
subalgebra, whereas here every $|p_i| subset.eq #worldstate$ is admissible. What the frame
constrains is the points of evaluation, not the propositions.

== Proof Systems

#definition("S5")[
  The smallest extension of classical propositional logic closed under MK
  ($square.stroked(phi.alt arrow.r psi) arrow.r (square.stroked phi.alt arrow.r square.stroked psi)$),
  MT ($square.stroked phi.alt arrow.r phi.alt$), M5
  ($diamond.stroked square.stroked phi.alt arrow.r square.stroked phi.alt$), modus ponens, and
  necessitation.
]#footnote[`def:S5`. @brastmckie2026possibleworlds]

#definition("BX")[
  The *Base Burgess--Xu Tense Logic*: the rules TN (temporal necessitation) and TD (the rule
  swapping $#since$ and $#until$ throughout a theorem); the seriality, linearity, and connectedness
  axioms TB, TL, CN; the primary Since/Until axioms TA, UE, UT, UI, UC, UF, UG, SU; and the
  uniformity axioms NP, NF, NA, NB, which are vacuous unless the order is discrete.
]#footnote[`def:BX`. @brastmckie2026possibleworlds Seventeen named keys. The past direction of each axiom is derived from the future direction by TD, not postulated.]

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
)#footnote[`def:TMplus`, `def:TMplus-f`, `def:TMplus-d`, `def:TMplus-c`. @brastmckie2026possibleworlds Whether CO alone axiomatizes the same $#BLplus$-logic as the full Reynolds triple is open.]

By Hölder's theorem a nontrivial discrete Archimedean totally ordered abelian group is isomorphic
to $ZZ$, and a nontrivial Dedekind-complete one is Archimedean and so isomorphic to $ZZ$ or $RR$.
The complete class is therefore exactly ${ZZ, RR}$ up to isomorphism, and the dense-and-complete
class exactly $RR$.

= What Is Proved: Completeness and Decidability <sec:key-theorems>

#remark[
  Soundness fixes the direction from proof to truth and is settled for every system named above.
  Completeness is the converse direction, and what it would buy is the licence to reason about
  task frames --- objects with a group-valued duration parameter, a topology, and a Zorn-backed
  existence theorem --- by manipulating finite derivations instead. The results below say that
  this licence is available at the $#BLplus$ level for three frame classes and is not yet
  available at the $#BL$ level for any, and @sec:construction says why the extra sentence
  $#Nxt top$ is what makes the difference.
]

== Soundness and Correspondence

#theorem("Soundness")[
  If $tack.r phi.alt$ then $#satisfies phi.alt$, for TM and for each of its four frame-class
  extensions $op("TM")_f$, $op("TM")_d$, $op("TM")_c$, $op("TM")_(d c)$ over its own class.
]#footnote[`thm:TM-soundness`. @brastmckie2026possibleworlds The characteristic case is M5, $#satisfies diamond.stroked square.stroked phi.alt arrow.r square.stroked phi.alt$, which holds because $square.stroked$ quantifies over $H_(#taskframe)$ entire and so is insensitive to the possible world at which it is evaluated.]

The three frame properties that separate the extensions are each characterized by a single axiom.
These correspondences are what make the extensions extensions *of a frame class* and not merely of
a proof system, and @sec:contingency's argument turns on all three holding together.

#proposition("Correspondence")[
  Over any frame $#taskframe$: DF is valid iff $#Dur$ is Discrete; DN is valid iff $#Dur$ is
  Dense; and CO is valid iff $#Dur$ is Complete.
]#footnote[`app:discrete`, `app:dense`, `app:complete`, against `def:frame-properties`. @brastmckie2026possibleworlds]

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
]#footnote[Pthm:13, Pthm:14, Pthm:18, Pthm:20, each a chain of at most six lines from the perpetuity principles P1--P6 and TF ($square.stroked phi.alt arrow.r #allfuture square.stroked phi.alt$), which follow in turn from MF and MT. @brastmckie2026possibleworlds]

A modality prefixed by a tense operator, or a tense operator prefixed by $square.stroked$, is
therefore no stronger than the modality alone. This bounds what the bimodal language can express
beyond its two fragments, and it is the reason the completeness constructions below need only
manage the interaction axiom MF and not an open-ended supply of mixed principles.

== Completeness <sec:completeness-status>

Completeness is stated per system and per class. At the $#BL$ level there is no positive result.

#theorem("Incompleteness at the base level")[
  None of TM, $op("TM")_f$, $op("TM")_d$, $op("TM")_c$, $op("TM")_(d c)$ is complete over its
  class.
]#footnote[`cor:tm-completeness`. @brastmckie2026possibleworlds]

@sec:dichotomy gives the argument for TM itself. $op("TM")_c$ fails identically over ${ZZ, RR}$.
$op("TM")_f$ is the one case that must not be lumped in with the others: it is sound over every
discrete frame, since DF is valid there, but whether it is complete over that class is *open*, and
no counterexample is known. The paper offers no separate incompleteness argument for
$op("TM")_d$ either; its status is covered only by the headline above.

At the $#BLplus$ level three positive results are machine-checked, each in the form
$"Valid"_cal(C) phi.alt arrow.r "Derivable"_cal(C) phi.alt$ for the frame class $cal(C)$ named.

#theorem("Weak completeness, dense class")[
  $op("TM")^+_d$ is weakly complete over the class of all dense task frames.
]
#leansrc("Metalogic.BXCanonical", "completeness_dense")
Axioms: exactly `propext`, `Classical.choice`, `Quot.sound`; no `sorryAx`.

#theorem("Weak completeness, discrete class")[
  $op("TM")^+_f$ is weakly complete over $ZZ$-time, in its successor-Archimedean formulation.
]
#leansrc("Metalogic.BXCanonical", "completeness_discrete")
Axioms: exactly `propext`, `Classical.choice`, `Quot.sound`; no `sorryAx`.

#theorem("Weak completeness, dense-and-complete class")[
  $op("TM")^+_c$ is weakly complete over the dense-and-complete class, which by Hölder's theorem
  is exactly $RR$.
]
#leansrc("Metalogic.BXCanonical", "completeness_dedekind_engine")
Axioms: exactly `propext`, `Classical.choice`, `Quot.sound`; no `sorryAx`.

The fourth result, over *all* task frames, is the stated formalization target and is not a theorem.

#theorem("Base-class completeness (outstanding)")[
  $op("TM")^+$'s weak completeness over all task frames is stated in the development as
  `completeness`, with one proof obligation outstanding. Its axiom report contains `sorryAx`. It
  is not an established theorem and is not used below.
]#footnote[The `sorryAx` traces to a single dependency, `countermodel_discrete` in `WeakCanonical/Transfer.lean`, which is dead code: the live replacement `countermodel_discrete_reynolds_v2` is what `completeness_discrete` actually calls (@sec:construction). The obligation is therefore narrow and identified, which is not the same as discharged.]

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
]#footnote[`def:TMplus`. @brastmckie2026possibleworlds The paper's former conservative-extension theorem has been deleted; this footnote's four parts replace it.]

== Decidability

#theorem("Decidability")[
  Whether TM, $op("TM")_f$, $op("TM")_d$, $op("TM")_c$, $op("TM")_(d c)$ are decidable is open.
]#footnote[`cor:tm-decidability`. @brastmckie2026possibleworlds]

Each system is recursively axiomatized, so its theorems are recursively enumerable whatever its
completeness status. Decidability needs the non-theorems recursively enumerable as well, and the
standard route is a finite model property: every non-theorem fails in some effectively enumerable
finite model @chagrovzakharyaschev1997 @goldblatt1992logics. The premise that a finite model
property over $D = ZZ$ delivers this uniformly is false, and is retracted with two witnesses.

#proposition("Failure of a uniform finite model property over $ZZ$")[
  DF is a non-theorem of TM, $op("TM")_d$, $op("TM")_c$, and $op("TM")_(d c)$, yet is valid in
  every model over $D = ZZ$. And CO is a non-theorem of $op("TM")_f$, witnessed by
  $ZZ times_"lex" ZZ$, yet is likewise valid in every model over $D = ZZ$.
]#footnote[`cor:tm-decidability`'s proof. @brastmckie2026possibleworlds A repaired finite model property must be class-specific, ranging over effective non-Archimedean carriers such as $ZZ times_"lex" ZZ$ and not over $ZZ$ alone.]

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
]#footnote[`SetConsistent` and `SetMaximalConsistent` in `Metalogic/Core/MaximalConsistent.lean`. Consistency is defined on finite subsets, so the set-level layer is finitary even though the sets themselves are infinite.]

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
]#footnote[Part of `cor:tm-completeness`'s proof. @brastmckie2026possibleworlds]
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
  caption: [The case split on $#Nxt top$. The dense-and-complete branch of @sec:completeness-status is the dense branch specialized to $RR$, where the split is not needed at all: over the Dedekind class the dense indicator is available unconditionally.],
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
]#footnote[`BFMCS` in `Metalogic/Bundle/BFMCS.lean`, fields `modal_forward` and `modal_backward`; the structure also designates an evaluation family, the one containing the original consistent set.]

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
]#footnote[`singletonChronicle` and `omegaChain` in `Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean`. Countability of the enumeration is what makes an $omega$-chain sufficient.]

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
]#footnote[`one_class` (`WeakCanonical/IntegerModel/NoGapsDiscreteProof.lean`), `VeryGood` (`IntegerModel/GoodStructures.lean`), `good` (`RealModel/DoetsTheorem.lean`), `limitdom_is_good` and `truth_transfer` (`WeakCanonical/Transfer.lean`). The decomposition technique is Doets's @doets1987; the step-by-step k-equivalence argument for Until/Since is Reynolds's @reynolds1992, as developed in Gabbay, Hodkinson, and Reynolds @gabbayhodkinsonreynolds1994.]

Transfer is sound because $k$-equivalence preserves the truth of every formula of quantifier depth
at most $k$, and the refuted sentence has a fixed depth. The resulting countermodel over $ZZ$ is
`countermodel_discrete_reynolds_v2`, and it is what `completeness_discrete` calls.

#remark[
  This is *not* an application of Kamp's theorem. Kamp's expressive-completeness result --- that
  over Dedekind-complete flows the strict Until/Since language captures every first-order condition
  on a linear order with monadic predicates in one free variable --- is a different statement, and
  it is not machine-checked here.#footnote[Kamp's 1968 dissertation @kamp1968; the modern model-theoretic proof is Rabinovich's @rabinovich2014. The result is frequently attributed to Kamp's 1971 _Theoria_ paper @kamp1971formalproperties, which introduces the *now* operator and does not contain it. Both of Kamp's scope conditions do real work: the operators must be strict, which is the convention used throughout here, and the flow must be Dedekind complete, since the result fails over arbitrary linear orders.] `Metalogic/WeakCanonical/Kamp/` develops toward the statement
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
]#footnote[`RealModel/DoetsTheorem.lean`, `Shuffle.lean`, `ShuffleReal.lean`, `EpsilonDense.lean`, and `OrderIsoReal.lean`. The basis is the Reynolds triple Prior-U, Prior-S, and Sep, with CO derived.]

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

== The Contingency of the Temporal Axioms <sec:contingency>

// FIX: the quality of this section is very poor, and can likely be tightened considerably, and improved by setting up the problem formally. EVERY ISSUE should be introduced through a formal lens. No vague glosses or empty words should be included anywhere.

The three frame conditions Discrete/Dense/Complete (`def:frame-properties`) are characterized by axioms DF, DN, CO respectively (`app:discrete`, `app:dense`, `app:complete`), giving systems $op("TM")_f, op("TM")_d, op("TM")_c$, with $op("TM")_(d c)$ the minimal common extension of $op("TM")_d$ and $op("TM")_c$. No temporal order is both discrete and dense, so TM cannot consistently contain both DF and DN.

*The worry, at full strength.* Since every possible world is defined over the frame's own temporal order $#Dur$, the structure $#Dur$ has -- discrete or dense, and in either case Dedekind complete or not -- holds *of metaphysical necessity* for that system: if $#Dur$ is dense, DN and its necessitation $square.stroked(#allfuture#allfuture phi.alt arrow.r #allfuture phi.alt)$ are both valid over that frame. This is not idiosyncratic to task semantics; it is an instance of frame validity being closed under necessitation (the Kripke B/symmetry precedent: over symmetric frames, B and its necessitation are both valid, so symmetry is necessary-if-true wherever it holds). Dorr and Goodman @dorr2020diamonds express sympathy for an account of metaphysical modality able to express theses about the contingency of the structure of time -- a real cost, not a strawman, and one the present framework must answer.

*The irregular-worlds response*, quoted in full since the price must be stated exactly:

#quote(block: true, quotes: false)[
  "Within the present framework one might give voice to such contingency by relaxing totality, admitting *irregular worlds* -- functions $tau : X arrow.r W$ where $X subset.neq D$ is a *coset domain*, a translate $G+c$ of a nontrivial subgroup $G lt.eq #Dur$, and $tau(x) arrow.r.double.long_(y-x) tau(y)$ for all $x,y in X$ -- and defining consequence over the irregular and possible worlds alike. Cosets rather than subgroups, since a family of translates is closed under ambient translation and so preserves MF and the perpetuity principles, which the subgroup formulation loses. The price is exact: every nontrivial ordered abelian group contains a discrete cyclic subgroup, so DN is then valid over no frame whatever, and DF fails over discrete orders possessing a subgroup that is itself dense, such as $QQ times_"lex" ZZ$, so the correspondence results of `app:discrete`, `app:dense`, and `app:complete` collapse together. These considerations recommend possible over irregular worlds."
]
#footnote[Quoted verbatim from the live footnote at `sub:Extension` (unlabeled -- no `\label` exists to track via `specs/paper-definitions-of-record.md`'s mechanism, so this quote is re-verified directly against the paper at authoring time rather than pinned). @brastmckie2026possibleworlds]

*The price, stated exactly*: (i) DN is valid over *no* frame whatever, since every nontrivial ordered abelian group contains a discrete cyclic subgroup; (ii) DF fails over discrete orders possessing a dense subgroup, such as $QQ times_"lex" ZZ$; (iii) `app:discrete`, `app:dense`, `app:complete` *lapse together*; (iv) the broadened operator, while still factive, normal, and closed under necessitation relative to the broadened consequence relation, is *displaced* from its standing as the strongest objective modality. Point (iv) is this report's own analysis, not a paper quotation -- the paper's sentence stating it is currently commented out in the live source (`sub:Extension`, immediately following the footnote above) and must not be cited as live text; it is grounded here directly in `def:strongest`/`thm:exist` (@sec:objective-modality) plus the observation that broadening the consequence relation changes which operator is $prec.eq$-least.

*The defense*, live paper text quotable directly: necessity-if-true of density is an instance of the general fact that frame validity is closed under necessitation, with the Kripke B/symmetry precedent above; structural disputes about metaphysical accessibility (S4 vs.~S5, closure under converses validating B) are already conducted as questions about which frame class and logic are correct, never as claims that transitivity or symmetry is itself metaphysically contingent; since possible worlds are only ever defined over a single frame, no modality quantifies across frames.#footnote[@brastmckie2026possibleworlds `sub:Extension`, live prose.]

*What irregular worlds do and do not deliver*: contingency in the *structure and cardinality* of the time series -- but not composition contingency of the catastrophe or proper-initial-segment kind, since a difference-closed domain is a subgroup (or a translate of one) and so unbounded in both directions either way.

*The residual question*, stated, not resolved: is there a semantics recovering temporal-structure contingency without lapsing the correspondence results? The paper's own target is a semantic class *closed under disjoint union*, under which the Halldén phenomenon of @sec:dichotomy dissolves structurally -- @sec:dichotomy develops exactly why the unrestricted class is *not* such a class, and @sec:representation returns to this target directly.

== The Strongest Objective Modality <sec:objective-modality>

$op("BL")$ is extended with a primitive propositional identity operator $equiv$ and higher-order quantifiers: `def:id`'s Ref, Imp, LL axiomatize $equiv$ minimally (not assumed Boolean), and operator variables range over an unrestricted domain of operations on propositions.#footnote[@brastmckie2026possibleworlds] The objective modalities are *axiomatized* by a primitive predicate $O$ on operator terms, following the theory of necessities in Bacon @bacon2022necessities, rather than *defined* outright -- *predicativity* (operator comprehension confined to formulas with no operator variables and no occurrence of $O$) blocks Russell--Myhill and keeps the system consistent with a fine-grained identity; Walsh @walsh2016predicativity proves consistency of a predicative restriction of Church's intensional logic. Predicativity could be dropped by strengthening the theory of identity instead, since coarse-grained identity also blocks Russell--Myhill.

$Q$ is a *strongest objective normal modal operator in $L$* -- $op("Str")^O_L (Q)$ -- iff (1) $tack.r O(Q)$ and (2) $tack.r forall P [O(P) arrow.r (Q prec.eq P)]$, with $prec.eq$ the dominance ordering; objectivity and normality need not be stated separately, since clause (1) already entails them.#footnote[`def:strongest`. @brastmckie2026possibleworlds] $op("Str")^O_L (B m)$: the meet operator witnesses *existence* -- clause (1) is the second conjunct of O-Meet, clause (2) follows from the first, T/N/K/necessitation-closure obtained by detaching O-Fac, O-Ax, O-Nec at $B m$.#footnote[`thm:exist`, *replacing* reliance on the separate, weaker `cor:exists` route (gated by a coarse-grained identity the paper does not assume) -- `cor:exists` is not the paper's existence result. @brastmckie2026possibleworlds]

Any two strongest objective normal modal operators are provably equivalent (`lem:uniq`); $op("Str")^O_L (Q)$ yields S4 for $Q$ (`thm:s4`) and B/Symmetry for $Q$ (`thm:sym`, a $tilde.op 15$-line chain compressed here to result-and-cite). Under $op("Str")^O_L (square.stroked)$: `lem:uniq` gives $tack.r forall p (square.stroked p arrow.l.r B m p)$, `thm:s4` gives S4, `thm:sym` gives B, factivity and necessitation follow by detaching O-Fac and O-Nec -- together delivering an S5 logic for $square.stroked$.#footnote[@brastmckie2026possibleworlds]

*The orthogonality point*, foregrounded: S5-hood alone cannot single $square.stroked$ out. The paper's own restricted case is the counterexample -- the *Stability* modality ($M,tau,x #satisfies "Stability" phi.alt$ iff $phi.alt$ holds at every $sigma$ agreeing with $tau$ at $x$) is likewise S5, since its accessibility partitions $H_(#taskframe)$ into equivalence classes, yet on non-temporal formulas $phi.alt arrow.r "Stability" phi.alt$ is valid, collapsing it to the trivial modality on that fragment.#footnote[Live `Stability` footnote, immediately following its semantic clause at `sub:RestrictedModalities`. @brastmckie2026possibleworlds] A strictly narrower accessibility relation can carry a strictly stronger logic; it is $prec.eq$-leastness, not S5-hood, that picks $square.stroked$ out. This general lesson is this report's *own analysis*, grounded in the live *Stability* footnote plus `def:strongest`/`thm:exist` -- the paper's own sentence stating the lesson generally is currently commented out in the live source (immediately after the *Stability* footnote's citing site) and must not be cited as paper text.

*The pain, stated plainly*: what is axiomatized is a *higher-order* theory of the objective modalities, not a $op("BL")$- or $op("BL")^+$-level proof system -- the connection between the two levels is a *hypothesis* ($op("Str")^O_L (square.stroked)$) adopted afresh for each system under study, not a theorem of TM or $op("TM")^+$. Left open: whether the leastness characterization is expressible or derivable at the propositional level at all; what a propositional axiomatization would have to add; whether the frame-relative plurality of $square.stroked$ operators is genuinely benign (the paper argues it is, since no cross-frame rival is formulable within the theory, and a reader wanting absoluteness may take the universal system); and how @sec:contingency's irregular-worlds broadening interacts, given that it *displaces* $square.stroked$ from its standing as $op("Str")^O_L (square.stroked)$ -- these two pain points are *not independent*.

= Toward a Representation Theorem <sec:representation>

// FIX: similar remarks apply here as well. ALL that is needed are the precise formal mechanics briefly introduced, where remarks are only to be included to expose the most substantive points about which to reflect.

== A Superseded Waypoint, Heeded

An earlier, unpublished draft (`metalogic.tex`, not `\input`-ed by the live paper) sketched a Representation Theorem; it is cited here only as a historical waypoint, with its defects named rather than any content lifted: (1) its canonical temporal order is hard-coded to $ZZ$, not $D$-parametric, unlike the live construction (@sec:construction); (2) its representation theorem and frame-characterization corollary assert TM is sound *and complete* over the class of all task semantic frames, directly contradicting `cor:tm-completeness`; (3) its Truth Lemma's $square.stroked$ case assumes global agreement across all canonical histories directly from the S5 axioms, rather than deriving it from an accessibility/modal-saturation construction -- the live architecture instead routes through BFMCS `modal_forward`/`modal_backward` coherence (@sec:construction), a materially different and actually-discharged argument; (4) its weak- and strong-completeness claims for TM are exactly what `cor:tm-completeness` and `StrongCompleteness.lean`'s docstring both refute. No definition, theorem statement, or proof step from this draft is restated here.

== What Actually Exists: The Algebraic Layer, and Only It

Of three candidate "early representation work" items, exactly *one* is live Lean development: `Metalogic/Algebraic/` (`BooleanStructure.lean`, `LindenbaumQuotient.lean`, `UltrafilterMCS.lean`, `InteriorOperators.lean`, `FlowFrame.lean`) -- the Lindenbaum--Tarski algebra, its ultrafilters, and an interior-operator treatment of the modalities, measured sorry-free (@sec:construction). The other two are targets, not existing work, and are stated as such below.

*The shift-set representation programme* is *not started*: no `ShiftSet` or `shiftSet` identifier exists anywhere under `FormalSystem/`. What exists is a design document stating the target in both directions: a shift set $chevron.l Omega, D, "sh", A chevron.r$ ($D$ an ordered abelian group, $Omega$ a nonempty type carrying a $D$-action via $"sh" : Omega arrow.r D arrow.r Omega$, $A : "Atom" arrow.r Omega arrow.r "Prop"$) would induce a task model by construction, and conversely; the payoff would be first-order axiomatizability of the task-model class over the two-sorted signature $chevron.l Omega, D; <, +, 0, "sh", (A_p) chevron.r$, since the frame's algebraic content reaches truth only through the atom clause. The design document's literal Lean snippets predate the completed total-history refactor and would need restatement (the underlying argument is recorded as surviving; the exact signature does not). Shift-set names are ordinary math and prose here, not Lean identifiers, and are never backticked as such.

*The Jönsson--Tarski programme* -- the complex algebra $"Cm"(cal(F))$ of a task frame, the ultrafilter frame $"Uf"(A)$ of an abstract algebra, and the canonical embedding $eta(a) = {U : a in U}$ -- is an *archived target*: this material was moved out of the live tree into an archived subtree, with revival tracked only as an unstarted future item. No content under that archived subtree is live. The important obstruction on revival: *Spherical* for an ultrafilter frame is a genuinely nontrivial *new* obligation, and the finite-$W$ discharge pattern (`cor:spherical-finite`) does not apply -- ultrafilter frames are typically infinite.

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
    content(algEnd, box(..boxstyle(green.transparentize(85%), green.darken(20%)))[#align(center)[#text(size: 6.5pt)[ultrafilters, interior ops -- *live*]]])
    line(algEnd, jtEnd, stroke: (paint: gray.darken(20%), thickness: 1pt, dash: "dashed"), mark: (end: ">"))
    content(jtEnd, box(..boxstyle(red.transparentize(88%), red.darken(20%)))[#align(center)[#text(size: 6.5pt)[Jönsson--Tarski duality -- *archived target*]]])
    line(start, ssMid, stroke: (paint: gray.darken(20%), thickness: 1pt), mark: (end: ">"))
    content(ssMid, box(..boxstyle(orange.transparentize(85%), orange.darken(20%)))[#align(center)[#text(size: 6.5pt)[shift-set design doc -- *target*]]])
    line(ssMid, ssEnd, stroke: (paint: gray.darken(20%), thickness: 1pt, dash: "dashed"), mark: (end: ">"))
    content(ssEnd, box(..boxstyle(orange.transparentize(85%), orange.darken(20%)))[#align(center)[#text(size: 6.5pt)[ultraproduct pipeline -- *not started*]]])
  }),
  caption: [The representation-theorem landscape: two routes, each starting live and ending in a target. Solid arrows mark completed steps; dashed arrows mark the gap.],
)

== The Way Forward

*(a) What must be weakened.* Of `def:frame`'s four axioms, *Spherical* is the prime suspect -- hardest to discharge at infinite carriers, and exactly where the Jönsson--Tarski route stumbles. Three discharge patterns are known (finite-$W$ choice-free, general Zorn, the $D$-parametric deterministic-fiber argument of @sec:construction); whether a weaker saturation condition suffices for the Step Lemma (`lem:step`) is open.

*(b) The group structure as crux, both ways -- this report's single most valuable analysis.* The discrete-or-dense dichotomy (@sec:dichotomy) is a theorem about ordered abelian *groups* and fails for bare linear orders, so dropping $D$ to a linearly ordered set (or a monoid, or a partially ordered group) *dissolves the (DD) obstruction outright*. The cost: MF and the perpetuity principles depend on translation invariance; the converse convention depends on negation; Compositionality is stated in terms of addition. What survives each weakening is exactly what a general representation theorem must reckon with, and is not yet worked out.

*(c) Disjoint-union closure.* Is the coset-domain construction of @sec:contingency the right route -- whose price is precisely a loss of the correspondence results a representation theorem would want -- or is a genuinely multi-frame semantics needed, and what would $square.stroked$ then quantify over? Open.

*(d) Algebraic vs.~shift-set.* The shift-set route's payoff is first-order axiomatizability and hence a compactness/ultraproduct argument; the Jönsson--Tarski route's payoff is a canonical embedding and duality. The design document's own recorded route: a feasibility gate, a bespoke two-sorted ultraproduct (Mathlib's single-sorted `FirstOrder.Language` was rejected as an encoding target), a Łoś lemma for truth, model existence/compactness, then per-class strong completeness -- with four named risks: the dependent ultraproduct of carriers as the largest unknown; the box case of Łoś needing a choice-function argument; a `Type`-vs-`Type*` universe constraint that must be asserted early; and the honest verdict "promising, not certain." Whether the two routes are the same theorem twice is itself open.

*(e) What would count as adequate.* Quoted from the in-tree acceptance standard directly: a sorry-free Lean statement of *both* directions with `#print axioms` reporting no `sorryAx`. A statement that type-checks with a sorry body does not count; one direction does not count; a prose argument does not count.

*(f) What is foreclosed.* Genuine strong completeness is *impossible* for $ZZ$-time and for $RR$ (compactness fails; an explicit non-compactness witness exists for the successor-Archimedean discrete case, and Reynolds @reynolds1992 establishes the analogous failure over $RR$). Base and Dense are *open*, not settled -- the missing piece is a model-existence theorem (every consistent set satisfiable in a class frame), which does not follow from the single-formula countermodel engines already built. Any way forward promising strong completeness for $ZZ$-time or $RR$ is wrong on arrival.

#bibliography("bibliography.bib")
