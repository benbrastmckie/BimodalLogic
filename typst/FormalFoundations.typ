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

The two primitives are written infix and are *guard-first*: in $phi.alt #since psi$ the guard is
$phi.alt$, holding throughout an interval, and the event is $psi$, witnessed at its far endpoint.#footnote[The paper's base language $#BL$ takes the one-place $#allpast$ and $#allfuture$ as primitive instead; it embeds into $#BLplus$ under @def-operators, and is not used below.]

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
    + *Segment*: $[w, v]_x^y := "Fib"(w, x) inter "Fib"(v, -y)$, for $x, y gt.eq 0$.#footnote[The relation is primitive only on $D^+$; negative durations are defined, not given.]
  ]
]
#leansrc("Semantics.TaskFrame", "Fib")
#leansrc("Semantics.TaskFrame", "cone")
#leansrc("Semantics.TaskFrame", "Seg")

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
      $w arrow.r.double.long_(x) u$ and $u arrow.r.double.long_(y) v$ for some $u in #worldstate$.#footnote[Compositionality is a biconditional, load-bearing in both directions.]
    + *Seriality*: $w arrow.r.double.long_(x) u$ and $v arrow.r.double.long_(x) w$ for some
      $u, v in #worldstate$.
    + *Limit*: $inter.big_(x > 0) (w)_x = {w}$.
    + *Spherical*: $inter.big cal(S) eq.not emptyset$ for any $supset.eq$-directed family $cal(S)$
      of nonempty fibers and segments.
  ]
]
#leansrc("Semantics", "TaskFrame")

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

#definition("Constraints")[
  For a partial history $tau : X arrow.r #worldstate$ over a frame
  $#taskframe = (#worldstate, #Dur, arrow.r.double.long)$ and duration $z in D without X$, the
  *constraints on $z$* are the segments $[tau(t), tau(s)]_(z-t)^(s-z)$ for times $t, s in X$ where
  $t < z < s$ when both $t, s in X$, and the fibers $"Fib"(tau(t), z-t)$ for $t in X$ otherwise.
]

#lemma("Directedness")[
  For any partial history $tau : X arrow.r #worldstate$ over a frame $#taskframe$ and duration
  $z in D without X$, the constraints imposed on $z$ form a $supset.eq$-directed family of nonempty
  sets.
]
#proof[
  Every constraint imposed on $z$ is nonempty: a fiber $"Fib"(tau(t), z-t)$ is nonempty by
  *Seriality*, and a segment $[tau(t), tau(s)]_(z-t)^(s-z)$ for $t < z < s$ is nonempty by
  *Compositionality* applied to $tau(t) arrow.r.double.long_(s-t) tau(s)$, which holds since $tau$
  is a partial history and $s - t = (z-t) + (s-z)$.

  For directedness, split $X$ into $A := {t in X : t < z}$ and $C := {s in X : s > z}$, so the
  constraints imposed on $z$ are the segments $S_(t,s) := [tau(t), tau(s)]_(z-t)^(s-z)$ for
  $(t,s) in A times C$ when both are nonempty, and the fibers $F_t := "Fib"(tau(t), z-t)$ for
  $t in X$ otherwise. First, the fibers nest: for $t lt.eq t' < z$ in $X$, any
  $u in "Fib"(tau(t'), z-t')$ satisfies $tau(t) arrow.r.double.long_(z-t) u$ by *Compositionality*
  applied to $tau(t) arrow.r.double.long_(t'-t) tau(t')$, so
  $"Fib"(tau(t'), z-t') subset.eq "Fib"(tau(t), z-t)$, and symmetrically for $z < t' lt.eq t$ in
  $X$ using the converse convention. Segments nest factorwise from the same inclusion. Given two
  segments $S_(t,s)$ and $S_(t',s')$, the times $t'' := max(t,t')$ and $s'' := min(s,s')$ lie in
  $A$ and $C$ respectively, and $S_(t'',s'') subset.eq S_(t,s) inter S_(t',s')$ by nesting. Given
  two fibers $F_t$ and $F_(t')$, the times $t$ and $t'$ lie on the same side of $z$, so the fiber
  nearer $z$ is included in the other by nesting, hence in $F_t inter F_(t')$.
]

#lemma("Admissibility")[
  For any partial history $tau : X arrow.r #worldstate$ over a frame $#taskframe$ and duration
  $z in D without X$, the function $tau union {(z,u)}$ is a partial history on $X union {z}$ just
  in case $u$ belongs to every member of the constraints imposed on $z$.
]
#proof[
  The constraints among the times in $X$ are inherited from $tau$, and the instance at $z$ itself
  is the zero loop $u arrow.r.double.long_0 u$ given by *Nullity*, so $tau union {(z,u)}$ is a
  partial history on $X union {z}$ just in case $u in "Fib"(tau(t), z-t)$ for every $t in X$. When
  the assignments in $X$ lie on one side of $z$, the constraints imposed on $z$ are exactly these
  fibers, and the two conditions coincide. When assignments flank $z$, the constraints are instead
  the segments $[tau(t), tau(s)]_(z-t)^(s-z) = "Fib"(tau(t), z-t) inter "Fib"(tau(s), z-s)$ for
  $t < z < s$ in $X$: if $u$ lies in every fiber then it lies in every segment, and conversely if
  $u$ lies in every segment then, fixing any $t < z$ and any $s > z$ in $X$, the segment
  $S_(t,s) subset.eq "Fib"(tau(t), z-t)$ places $u$ in that fiber, symmetrically for $t > z$.
]

#lemma("Step")[
  Every partial history $tau : X arrow.r #worldstate$ over a frame $#taskframe$ extends to a
  partial history on $X union {z}$ for any duration $z in D$.
]
#proof[
  If $z in X$, then $tau$ extends itself. Otherwise the constraints imposed on $z$ form a directed
  family of nonempty fibers and segments by *Directedness*, so *Spherical* provides some
  $u in #worldstate$ belonging to every member, whence $tau union {(z,u)}$ is a partial history on
  $X union {z}$ extending $tau$ by *Admissibility*. When the family has a $subset.eq$-least
  member --- as the nesting argument inside *Directedness* provides whenever $X$ contains an
  assignment nearest to $z$ on each side it occupies --- that member already supplies a candidate
  and *Spherical* is not needed.
]

#theorem("Extension")[
  Every partial history over a frame is extended by a possible world.
]
#leansrc("Semantics.PartialHistory", "extension")
#proof[
  The partial histories extending $tau$ are partially ordered by extension, and every chain among
  them is bounded above by its union, which restricts on any pair of times to a single member of
  the chain and so is itself a partial history. By Zorn's lemma, there is a maximal partial
  history $sigma : T arrow.r #worldstate$ extending $tau$. If $T eq.not D$, then $sigma$ extends
  to a partial history on $T union {z}$ for any $z in D without T$ by the *Step* Lemma,
  contradicting maximality. Thus $T = D$, whence $sigma in H_(#taskframe)$ is a total world
  history extending $tau$.
]

#corollary("Occurrence")[
  For every frame $#taskframe$, world state $w in W$, and time $x in D$, there is some possible world $tau in H_(#taskframe)$ which has
  $tau(x) = w$. In particular $H_(#taskframe) eq.not emptyset$.
]
#leansrc("Semantics.PartialHistory", "occurrence")

The Step Lemma above is the sole application site of *Spherical*, and Extension is the sole
consumer of the Step Lemma; every appeal to *Spherical* in the semantics passes through this one
point.#footnote[*Spherical* is not needed when the $supset.eq$-directed family has a $subset.eq$-least member, and on a finite carrier it holds outright and choice-free.] Extension and Occurrence are theorems of ZFC, in contrast with Nullity. That
localization is what makes *Spherical* the identified obstruction of @sec:representation.

The cones are a basis for a topology on world states, and that topology is separated.#footnote[The topology is carried by the world states, not by $H_(#taskframe)$ or by $D$.]

#definition("Task Topology")[
  Given a frame $#taskframe$:
  #items[
    + *Basic Opens*: $B_(#taskframe) := {(w)_x : w in #worldstate "and" x in D "with" x > 0}$.
    + *Topology*: $cal(T)_(#taskframe) := (#worldstate, cal(O)_(#taskframe))$ where
      $cal(O)_(#taskframe)$ is the closure of $B_(#taskframe)$ under arbitrary union and finite
      intersection.
    + *Closure*: $overline(S) := {w in #worldstate : O inter S eq.not emptyset "for every open"
      O in cal(T)_(#taskframe) "where" w in O}$ for $S subset.eq #worldstate$.
    + *T1*: $cal(T)_(#taskframe)$ is *T1* just in case $overline({w}) = {w}$ for all
      $w in #worldstate$.
    + *R0*: $cal(T)_(#taskframe)$ is *R0* just in case $w in overline({u})$ iff
      $u in overline({w})$ for all $w, u in #worldstate$.
  ]
]

#theorem("Separation")[$cal(T)_(#taskframe)$ is T1, and hence R0, for every frame $#taskframe$.]
#proof[
  ${u} subset.eq overline({u})$ is immediate. Conversely let $w in overline({u})$. By Nullity
  every basic open $(w)_x$ contains $w$, so $u in (w)_x$ for every $x > 0$.
  Hence for each such $x$ there is $y$ with $|y| < x$ and $w arrow.r.double.long_(y) u$, so $u arrow.r.double.long_(-y) w$
  by the converse convention and $w in (u)_x$.
  Thus $w in inter.big_(x>0)(u)_x = {u}$ by *Limit*, and so R0 follows.
]

#remark[
  Extension makes every partial history a restriction of a possible world, and Separation shows the
  cone topology distinguishes world states.
  Whether these results license *defining* a partial
  history as a restriction of a possible world, instead of defining it independently and proving
  Extension, is a question about the order of the theory and not about its content: the two
  definitions agree extensionally, by Extension.
  They differ in what must be assumed at the outset.
  The restriction definition makes $H_(#taskframe)$ prior and hides the appeal to *Spherical*
  inside the existence of the objects it quantifies over; the order taken here keeps *Spherical*
  visible at the single site where it is used.
]

== Models and Truth

#definition("Model")[
  A *model* is a structure $#model = (#worldstate, #Dur, arrow.r.double.long, |dot.c|)$ where
  $(#worldstate, #Dur, arrow.r.double.long)$ is a frame and $|p_i| subset.eq #worldstate$ for every
  sentence letter $p_i$.#footnote[An interpretation assigns each sentence letter a set of *world states*. Truth at a time is mediated entirely by the world state the history occupies there; this is the content of the atomic clause below, and it is what makes a possible world a trajectory through a fixed state space and not an independent index.]
]
#leansrc("Semantics", "TaskModel")

#definition("Truth")[
  *Truth* in a model $#model$ at a possible world $tau in H_(#taskframe)$ and time $x in D$ is defined recursively as follows:#footnote[Evaluating at a possible world paired with a time, with truth at that time mediated by the world state occupied there, is an instance of Scott's proposal @scott1970advice that the index of evaluation be a structured point of reference and not a bare world.]
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

The semantic clause for $square.stroked$ quantifies over all possible worlds of the frame.
It is not a relational modality with an accessibility relation to be tuned: the frame fixes $H_(#taskframe)$, and $square.stroked$ ranges over that set entire.
Its logic is correspondingly S5, and @sec:objective-modality takes up what else, beyond being S5, is needed to single it out.

#definition("Frame Properties")[
  A frame is *Discrete* if every $x in D$ having some $y > x$ has a least such; *Dense* if
  $x < z < y$ for some $z$ whenever $x < y$; *Complete* if every nonempty subset of $D$ bounded
  above has a least upper bound; and *Deterministic* if $w arrow.r.double.long_(x) u$ and
  $w arrow.r.double.long_(x) v$ imply $u = v$.#footnote[The first three constrain $#Dur$; the fourth constrains $arrow.r.double.long$.]
]
#leansrc("FrameConditions", "DenseTemporalFrame")
#leansrc("FrameConditions", "DiscreteTemporalFrame")
#leansrc("FrameConditions", "DedekindTemporalFrame")

#definition("Validity and Consequence")[
  $#taskframe #satisfies phi.alt$ just in case $#model, tau, x #satisfies phi.alt$ for every model
  $#model$ on $#taskframe$, every $tau in H_(#taskframe)$, and every $x in D$. And
  $Gamma #satisfies phi.alt$ just in case $phi.alt$ is true in every model, at every possible world, and time at which every
  member of $Gamma$ is true; $phi.alt$ is *valid* when $#satisfies phi.alt$.
]
#leansrc("Semantics", "valid")
#leansrc("Semantics", "SemanticConsequence")

By Occurrence $H_(#taskframe)$ is never empty, so frame validity is never vacuous and
$#taskframe #notsatisfies bot$ for every frame. Fixing $H_(#taskframe)$ with the frame does not
make $#taskframe$ a *general frame* in the sense of Blackburn, de Rijke, and Venema
@blackburnderijkevenema2001: a general frame restricts the admissible valuations to a designated
subalgebra, whereas here every $|p_i| subset.eq #worldstate$ is admissible. What the frame
constrains is the points of evaluation, not the propositions.

== Proof Systems

#definition("S5")[
  *S5* is the smallest extension of classical propositional logic CPL closed under the following
  schemata, rule, and metarule:
  #items[
    + *MK*: $square.stroked(phi.alt arrow.r psi) arrow.r (square.stroked phi.alt arrow.r square.stroked psi)$.
    + *MT*: $square.stroked phi.alt arrow.r phi.alt$.
    + *M5*: $diamond.stroked square.stroked phi.alt arrow.r square.stroked phi.alt$.
    + *MP*: $phi.alt, phi.alt arrow.r psi tack.r psi$.
    + *MN*: if $tack.r phi.alt$ then $tack.r square.stroked phi.alt$.
  ]
  MK, MT, and M5 are axiom schemata, MP is a rule, and MN is a metarule.
]

#definition("BX")[
  Let $phi.alt_(chevron.l "S"|"U" chevron.r)$ denote the result of swapping all occurrences of
  $#since$ and $#until$ in $phi.alt$. The *Base Burgess--Xu Tense Logic* is the smallest
  extension of CPL closed under all instances of the following rules and axiom schemata:
  #items[
    + *TN*: if $tack.r phi.alt$ then $tack.r #allfuture phi.alt$.
    + *TD*: if $tack.r phi.alt$ then $tack.r phi.alt_(chevron.l "S"|"U" chevron.r)$.
    + *TB*: $#somefuture top$.
    + *TL*: $(#somefuture phi.alt and #somefuture psi) arrow.r [#somefuture (phi.alt and psi) or #somefuture (phi.alt and #somefuture psi) or #somefuture (#somefuture phi.alt and psi)]$.
    + *CN*: $[(phi.alt #until psi) and (chi #until theta)] arrow.r [(phi.alt and chi) #until (psi and theta) or (phi.alt and chi) #until (psi and chi) or (phi.alt and chi) #until (phi.alt and theta)]$.
    + *TA*: $phi.alt arrow.r #allfuture #somepast phi.alt$.
    + *UE*: $(phi.alt #until psi) arrow.r #somefuture psi$.
    + *UT*: $#somefuture phi.alt arrow.r (top #until phi.alt)$.
    + *UI*: $phi.alt #until (phi.alt and (phi.alt #until psi)) arrow.r phi.alt #until psi$.
    + *UC*: $#allfuture (phi.alt arrow.r psi) arrow.r ((chi #until phi.alt) arrow.r (chi #until psi))$.
    + *UF*: $(phi.alt #until psi) arrow.r (phi.alt and (phi.alt #until psi)) #until psi$.
    + *UG*: $#allfuture (phi.alt arrow.r chi) arrow.r ((phi.alt #until psi) arrow.r (chi #until psi))$.
    + *SU*: $theta and (phi.alt #until psi) arrow.r phi.alt #until (psi and (phi.alt #since theta))$.
    + *NP*: $#Nxt top arrow.r #Prev top$.
    + *NF*: $#Nxt top arrow.r #somefuture #Nxt top$.
    + *NA*: $#Nxt top arrow.r #somepast #Nxt top$.
    + *NB*: $#Nxt top arrow.r square.stroked #Nxt top$.
  ]
  TB, TL, and CN state seriality, linearity, and connectedness respectively; TA, UE, UT, UI, UC,
  UF, UG, and SU are the primary Since/Until axioms; NP, NF, NA, and NB are the uniformity axioms,
  holding vacuously unless the order is discrete. In every case the past/since direction is
  derived from the future/until direction by TD, not separately postulated -- only the
  future/until direction is stated above. NB is stated here as it belongs to BX in the paper, even
  though $square.stroked$ is only interpreted once S5 is fused with BX below.#footnote[Seventeen named keys: two rules (TN, TD), three seriality/linearity/connectedness axioms (TB, TL, CN), eight primary Since/Until axioms (TA, UE, UT, UI, UC, UF, UG, SU), and four uniformity axioms (NP, NF, NA, NB).]
]

#definition($op("TM")^+$)[
  $op("TM")^+$, the base logic for $#BLplus$, is the smallest extension of S5 and BX to include
  all instances of the sole bimodal-interaction axiom:
  #items[
    + *MF*: $square.stroked phi.alt arrow.r square.stroked #allfuture phi.alt$.
  ]
]

#definition($"BX"_f$)[
  The *Discrete Burgess--Xu Tense Logic* $"BX"_f$ is the smallest extension of BX to include all
  instances of:
  #items[
    + *UZ*: $#somefuture phi.alt arrow.r (not phi.alt #until phi.alt)$.
    + *Z1*: $#allfuture (#allfuture phi.alt arrow.r phi.alt) arrow.r (#somefuture #allfuture phi.alt arrow.r #allfuture phi.alt)$.
  ]
  UZ asserts that if $phi.alt$ holds at some future time, there is a *nearest* future
  $phi.alt$-time with $not phi.alt$ throughout the intervening interval. Z1 is a backward
  induction principle characteristic of successor-Archimedean frames: by Hölder's theorem a
  nontrivial discrete Archimedean totally ordered abelian group is isomorphic to $ZZ$, so the
  successor-Archimedean discrete class to which $"BX"_f$ and $op("TM")^+_f$ are sound and
  complete is exactly $ZZ$-time.
]

#definition($"BX"_d$)[
  The *Dense Burgess--Xu Tense Logic* $"BX"_d$ is the smallest extension of BX to include all
  instances of:
  #items[
    + *DN*: $#allfuture #allfuture phi.alt arrow.r #allfuture phi.alt$.
    + *NN*: $not #Nxt top$.
  ]
  DN coincides with TM's DN below; NN is specific to the $#BLplus$ level and asserts that no time
  has an immediate successor.
]

#definition($"BX"_c$)[
  Let $K^+ phi.alt := not (not phi.alt #until top)$ and $K^- phi.alt := not (not phi.alt #since top)$,
  read *"$phi.alt$ recurs arbitrarily soon in the future"* and *"$phi.alt$ recurred arbitrarily
  recently in the past"* respectively. The *Complete Burgess--Xu Tense Logic* $"BX"_c$ is the
  smallest extension of BX to include all instances of:
  #items[
    + *Prior-U*: $(phi.alt #until top) and #somefuture not phi.alt arrow.r phi.alt #until (not phi.alt or K^+ not phi.alt)$.
    + *Sep*: $K^+ phi.alt and not K^+ (phi.alt and (not phi.alt #until phi.alt)) arrow.r K^+ (K^+ phi.alt and K^- phi.alt)$.
  ]
  Only the future/until direction of Prior-U is stated; its past/since direction follows by TD.
  The following restates CO from TM below, and is a *derived theorem* of $"BX"_c$ from Prior-U
  and the base BX axioms, not a further axiom, so it may be omitted from the extension:
  #items[
    + *CO*: $#always (#somepast phi.alt arrow.r #somefuture #somepast phi.alt) arrow.r (#somepast phi.alt arrow.r #allfuture phi.alt)$.
  ]
]

Similarly, $op("TM")^+_f$, $op("TM")^+_d$, and $op("TM")^+_c$ extend $op("TM")^+$ with the
additional axioms that distinguish $"BX"_f$, $"BX"_d$, and $"BX"_c$ respectively: $op("TM")^+_f$
adds UZ and Z1, $op("TM")^+_d$ adds DN and NN, and $op("TM")^+_c$ adds Prior-U and Sep.#footnote[Whether CO alone axiomatizes the same $#BLplus$-logic as Prior-U and Sep together is open.]

#figure(
  table(
    columns: 2, stroke: none, align: (left,left),
    table.hline(), table.header([*System*],[*Additional axioms*]), table.hline(),
    [$op("TM")^+_f$], [UZ, Z1 (backward induction; successor-Archimedean, hence $ZZ$-time by Hölder's theorem)],
    [$op("TM")^+_d$], [DN ($#allfuture#allfuture phi.alt arrow.r #allfuture phi.alt$), NN ($not #Nxt top$)],
    [$op("TM")^+_c$], [Prior-U, Sep; CO is a derived theorem, not a further axiom],
    table.hline(),
  ),
  caption: [The three frame-class extensions of $op("TM")^+$.],
)
#leansrc("ProofSystem", "FrameClass")

By Hölder's theorem a nontrivial discrete Archimedean totally ordered abelian group is isomorphic
to $ZZ$, and a nontrivial Dedekind-complete one is Archimedean and so isomorphic to $ZZ$ or $RR$.
The complete class is therefore exactly ${ZZ, RR}$ up to isomorphism, and the dense-and-complete
class exactly $RR$.

#definition("TM")[
  *TM*, the *Logic of Tense and Modality* for $#BL$, is the smallest extension of CPL closed
  under all instances of the following rules and axiom schemata:
  #items[
    + *MP*: $phi.alt, phi.alt arrow.r psi tack.r psi$.
    + *MN*: if $tack.r phi.alt$ then $tack.r square.stroked phi.alt$.
    + *MK*: $square.stroked(phi.alt arrow.r psi) arrow.r (square.stroked phi.alt arrow.r square.stroked psi)$.
    + *MT*: $square.stroked phi.alt arrow.r phi.alt$.
    + *M5*: $diamond.stroked square.stroked phi.alt arrow.r square.stroked phi.alt$.
    + *MF*: $square.stroked phi.alt arrow.r square.stroked #allfuture phi.alt$.
    + *TD*: if $tack.r phi.alt$ then $tack.r phi.alt_(chevron.l "P"|"F" chevron.r)$, where
      $phi.alt_(chevron.l "P"|"F" chevron.r)$ swaps all occurrences of $#allpast$ and $#allfuture$
      in $phi.alt$.
    + *TK*: $#allfuture (phi.alt arrow.r psi) arrow.r (#allfuture phi.alt arrow.r #allfuture psi)$.
    + *T4*: $#allfuture phi.alt arrow.r #allfuture #allfuture phi.alt$.
    + *TB*: $#somefuture top$.
    + *TA*: $phi.alt arrow.r #allfuture #somepast phi.alt$.
    + *TL*: $(#somefuture phi.alt and #somefuture psi) arrow.r [#somefuture (#somefuture phi.alt and psi) or #somefuture (phi.alt and psi) or #somefuture (phi.alt and #somefuture psi)]$.
  ]
  MP and MN are rules; MK, MT, M5, MF, TK, T4, TB, TA, and TL are axiom schemata; TD is a rule
  making the logic symmetric with respect to past and future at each time. TM's TL lists the same
  three disjuncts as BX's TL above but in a different order; this is the paper's own presentation
  and not a discrepancy to normalize.
]

TM is strengthened by constraining the temporal order $#Dur$ to be Discrete, Dense, or Complete
per the Frame Properties above, each characterized by a single axiom:
#items[
  + *DF*: $(#allpast phi.alt and phi.alt and #somefuture top) arrow.r #somefuture #allpast phi.alt$.
  + *DN*: $#allfuture #allfuture phi.alt arrow.r #allfuture phi.alt$.
  + *CO*: $#always (#somepast phi.alt arrow.r #somefuture #somepast phi.alt) arrow.r (#somepast phi.alt arrow.r #allfuture phi.alt)$.
]
Letting $op("TM")_f$ extend TM to include all instances of DF, $op("TM")_d$ to include all
instances of DN, and $op("TM")_c$ to include all instances of CO, $op("TM")_(d c)$ is the minimal
extension of $op("TM")_d$ and $op("TM")_c$, corresponding to the continuous temporal orders that
are both dense and Dedekind complete. Since no temporal order is both Discrete and Dense, TM
cannot be extended to include both DF and DN while remaining consistent.

#definition("Derivability")[
  The *derivation relation* $tack.r$ for TM is the smallest relation closed under the axioms and
  rules for TM given above.
]

= Completeness and Decidability <sec:key-theorems>

This section covers five results. Soundness holds for TM and its four frame-class extensions, and
three axioms correspond exactly to frame conditions: DF to Discrete, DN to Dense, and CO to
Complete. The perpetuity principles then show that a modality prefixed by a tense operator, or a
tense operator prefixed by $square.stroked$, collapses to the modality alone, which bounds what the
bimodal language expresses beyond its two fragments. Completeness itself is asymmetric: nothing
positive is known at the $#BL$ level, while three weak completeness results are machine-checked at
the $#BLplus$ level, with the base frame class left as an outstanding proof obligation. Decidability
is open throughout; the uniform finite model property over $D = ZZ$ that would settle it fails, and
the live strategy is the reduction $op("Log")("all task frames") = op("Log")("Discrete") inter
op("Log")("Dense")$, which is a target rather than a result.

== Soundness and Correspondence

#theorem("Soundness")[
  If $tack.r phi.alt$ then $#satisfies phi.alt$, for TM and for each of its four frame-class
  extensions $op("TM")_f$, $op("TM")_d$, $op("TM")_c$, $op("TM")_(d c)$ over its own class.#footnote[The characteristic case is M5, $#satisfies diamond.stroked square.stroked phi.alt arrow.r square.stroked phi.alt$, which holds because $square.stroked$ quantifies over $H_(#taskframe)$ entire and so is insensitive to the possible world at which it is evaluated.]
]
#leansrc("FrameConditions", "soundness_linear")
#leansrc("FrameConditions", "soundness_dense")
#leansrc("FrameConditions", "soundness_discrete")
#leansrc("FrameConditions", "soundness_Int")

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
]

A modality prefixed by a tense operator, or a tense operator prefixed by $square.stroked$, is
therefore no stronger than the modality alone.#footnote[Each is a chain of at most six lines from the perpetuity principles P1--P6 and TF ($square.stroked phi.alt arrow.r #allfuture square.stroked phi.alt$), which follow in turn from MF and MT.] This bounds what the bimodal language can express
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

The fourth result, over *all* task frames, is the stated formalization target and is not a theorem.#footnote[The `sorryAx` traces to a single dependency, `countermodel_discrete`, which is dead code: the live replacement `countermodel_discrete_reynolds_v2` is what `completeness_discrete` actually calls (@sec:construction). The obligation is therefore narrow and identified, which is not the same as discharged.]

#theorem("Base-class completeness (outstanding)")[
  Weak completeness over all task frames, for the Base frame class, is stated in the development as
  `completeness`, with one proof obligation outstanding. Its axiom report contains `sorryAx`. It
  is not an established theorem and is not used below.
]
#leansrc("Metalogic.BXCanonical", "completeness")
#leansrc("Metalogic.WeakCanonical", "countermodel_discrete_reynolds_v2")

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
  counterexample.#footnote[The paper's former conservative-extension theorem has been deleted; this footnote's four parts replace it.]
]

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
]

The failure is not incidental: $ZZ$ is a discrete carrier and bears no relation to the frame
classes of the three non-discrete systems, so no property of models over $ZZ$ could have decided
them.#footnote[A repaired finite model property must be class-specific, ranging over effective non-Archimedean carriers such as $ZZ times_"lex" ZZ$ and not over $ZZ$ alone.] What exists in the development is a tableau procedure whose *soundness* is machine-checked,
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

#lemma("Lindenbaum")[
  Every consistent set of sentences is contained in a maximal consistent set of the same frame
  class.
]
#leansrc("Metalogic.Core", "set_lindenbaum")
The proof is Zorn's lemma over the consistent supersets, whose chains are bounded by their unions;
finitary consistency is what makes a union of a chain of consistent sets consistent.#footnote[Consistency is defined on finite subsets, so the set-level layer is finitary even though the sets themselves are infinite.]

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
      belongs to each family's set at $t$.#footnote[The structure also designates an evaluation family, the one containing the original consistent set.]
  ]
]
#leansrc("Metalogic.Bundle", "BFMCS")

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
is deterministic, so its fibers are subsingletons, and a $supset.eq$-directed family of nonempty subsingletons
has nonempty intersection outright.#footnote[`multiFamGen_spherical`, via the reusable helper `sInter_nonempty_of_directed_subsingleton`. The argument sees only the shape of the fibers, so it applies to every deterministic frame. Contrast the finite-carrier discharge (`cor:spherical-finite`) and the Zorn route through the Step Lemma (`thm:extension`); this third pattern is what @sec:representation returns to.]

== The Dense Branch

#definition("Chronicle")[
  A *chronicle* over a maximal consistent set $A$ assigns a maximal consistent set to each point of
  a domain $X subset.eq QQ$, subject to coherence conditions C0--C5 relating the assignments at
  distinct points to the Since and Until sentences they contain. It is built as the limit of an
  $omega$-chain: the *singleton chronicle* maps $0$ to $A$; each successor step eliminates one
  potential counterexample, enumerated from $QQ times "Formula" times "Formula" times "Bool"$; and
  the limit is the union of the chain.#footnote[Countability of the enumeration is what makes an $omega$-chain sufficient.]
]
#leansrc("Metalogic.BXCanonical.Chronicle", "singletonChronicle")
#leansrc("Metalogic.BXCanonical.Chronicle", "omegaChain")

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
  $k$-equivalence.#footnote[The decomposition technique is Doets's @doets1987; the step-by-step k-equivalence argument for Until/Since is Reynolds's @reynolds1992, as developed in Gabbay, Hodkinson, and Reynolds @gabbayhodkinsonreynolds1994.]
]
#leansrc("Metalogic.WeakCanonical", "one_class")
#leansrc("Metalogic.WeakCanonical", "VeryGood")
#leansrc("Metalogic.WeakCanonical", "good")
#leansrc("Metalogic.WeakCanonical", "limitdom_is_good")
#leansrc("Metalogic.WeakCanonical", "truth_transfer")

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

The engine is `completeness_dedekind_engine`.#footnote[The basis is Prior-U and Sep, with CO derived.] Its consequence form,
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
  $G lt.eq #Dur$ --- and $tau(x) arrow.r.double.long_(y-x) tau(y)$ for all $x, y in X$.#footnote[Cosets and not subgroups: a family of translates is closed under ambient translation and so preserves MF and the perpetuity principles, which the subgroup formulation loses.] Consequence
  is then defined over the irregular and the possible worlds alike.
]

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
]

Parts (i)--(iii) are severe: they cost the three theorems that make the frame-class hierarchy
mean anything.#footnote[Parts (i)--(iii) are the paper's own; its verdict there is that "these considerations recommend possible over irregular worlds." Part (iv) is this document's addition, grounded in the Strongest Objective Normal Modal Operator definition and the Existence theorem below together with the observation that broadening the consequence relation changes which operator is $prec.eq$-least; the paper's sentence stating it is commented out in the live source and is not cited as paper text.] What is bought is contingency in the *structure and cardinality* of the time
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

#theorem("Existence")[$op("Str")^O_L (B m)$: the meet operator is a strongest objective normal modal operator, so $L$ contains one.#footnote[Clause (1) is the second conjunct of O-Meet, clause (2) follows from the first, and T, N, K, and necessitation-closure follow by detaching O-Fac, O-Ax, and O-Nec at $B m$.]]

#theorem("Uniqueness and logic")[
  Any two strongest objective normal modal operators are provably equivalent. If
  $op("Str")^O_L (Q)$ then $Q$ satisfies S4 and B. In particular, under the hypothesis
  $op("Str")^O_L (square.stroked)$, the logic of $square.stroked$ is S5.#footnote[Under the hypothesis, the uniqueness lemma gives $tack.r forall p(square.stroked p arrow.l.r B m p)$, and factivity and necessitation follow by detaching O-Fac and O-Nec.]
]

Being S5 is not enough to identify $square.stroked$, and the paper supplies its own counterexample.

#proposition("Orthogonality")[
  A strictly narrower accessibility relation can carry a strictly stronger logic. The *Stability*
  operator --- $#model, tau, x #satisfies "Stability" phi.alt$ iff $phi.alt$ holds at $x$ in every
  possible world occupying the same world state as $tau$ at $x$ --- is S5, since its accessibility
  is the equivalence relation $sigma tilde.op_x tau$ iff $sigma(x) = tau(x)$. Yet on non-temporal
  sentences $phi.alt arrow.r "Stability" phi.alt$ is valid, so Stability collapses to the trivial
  modality on that fragment.#footnote[The general lesson drawn in the statement is this document's own; the paper's sentence stating it generally is commented out in the live source and is not cited as paper text.]
]

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

"Representation theorem" has been asked to name four different things here, and the section below
keeps conflating them. Distinguish:
#items[
  + *An algebraic representation*: an embedding $A arrow.r.hook op("Em")(A)$ of an abstract
    algebra into the complex algebra of its own ultrafilter frame.
  + *A duality*: a categorical dual equivalence $op("BAO")_tau tilde.equiv op("DGF")_tau^op("op")$
    between algebras of a similarity type $tau$ and a class of topological (general) frames.
  + *A task-frame representation*: a construction carrying every abstract algebra of the right
    kind to a genuine task frame $#taskframe$ of @sec:system, and back, inverse up to isomorphism.
  + *A first-order axiomatization*: a two-sorted first-order theory whose models correspond to
    task models, so that the class of task models is captured by compactness in the usual sense.
]
What strong completeness for the base and dense classes needs is specifically the third: a
model-existence theorem, every consistent set satisfiable in a frame of the class, and none of the
countermodel engines of @sec:construction delivers one, since each refutes a single sentence. The
first two are available, off the shelf, for BAOs of any similarity type; what is not available off
the shelf is the passage from a duality to a *task-frame* representation, because a general frame
is not the same structure as a task frame, and that gap is where the section's difficulty actually
lives.#footnote[An earlier unpublished draft sketched a representation theorem and is superseded; its canonical order was hard-coded to $ZZ$ instead of parametric in $D$, and it asserted TM sound *and complete* over all task frames, which `cor:tm-completeness` refutes. No definition, statement, or proof step from it is used here.]

The difficulty resolves into six rungs, of markedly different status.

#figure(
  table(
    columns: 3, stroke: none, align: (left, left, left),
    table.hline(),
    table.header([*Rung*], [*Statement*], [*Status for TM*]),
    table.hline(),
    [1. Lindenbaum--Tarski algebra], [exists, Boolean, ultrafilters $tilde.equiv$ MCSs], [done in Lean, sorry-free],
    [2. BAO for the full similarity type], [$\{square.stroked, G, H, until, since\}$, normal and additive], [not done -- no $G$ on the quotient, no normality/additivity lemma],
    [3. Jónsson--Tarski], [$A arrow.r.hook op("Em")(A)$; canonical frame $tilde.equiv$ ultrafilter frame], [available off the shelf; the ultrafilter/MCS half is Lean-verified],
    [4. Full duality], [$op("BAO")_tau tilde.equiv op("DGF")_tau^op("op")$, descriptive general frames], [available off the shelf],
    [5. Dual Kripke reduct is a task frame], [*Compositionality*, *Seriality*, *Limit*, *Spherical*], [blocked at *Spherical*],
    [6. Per-class refinement], [discrete / dense / Dedekind-complete], [elementary and reachable for dense; out of first-order reach for the discrete and complete classes],
    table.hline(),
  ),
  caption: [The six-rung ladder toward a task-frame representation theorem for TM.],
)

#figure(
  cetz.canvas({
    import cetz.draw: *
    let dy = 1.0
    let r1 = (0, 4*dy)
    let r2 = (0, 3*dy)
    let r3 = (0, 2*dy)
    let r4 = (0, 1*dy)
    let r5 = (0, 0*dy)
    let boxstyle(fill-c, stroke-c) = (fill: fill-c, stroke: (paint: stroke-c, thickness: 1pt), inset: 5pt, radius: 3pt, width: 9cm)
    content(r1, box(..boxstyle(green.transparentize(85%), green.darken(20%)))[#align(center)[#text(size: 7pt)[Rung 1: Lindenbaum--Tarski algebra, ultrafilters $tilde.equiv$ MCSs -- *live, sorry-free*]]])
    line(r1, r2, stroke: (paint: gray.darken(20%), thickness: 1pt), mark: (end: ">"))
    content(r2, box(..boxstyle(red.transparentize(88%), red.darken(20%)))[#align(center)[#text(size: 7pt)[Rung 2: BAO for $\{square.stroked, G, H, until, since\}$ -- *not done: no $G$, no normality/additivity*]]])
    line(r2, r3, stroke: (paint: gray.darken(20%), thickness: 1pt), mark: (end: ">"))
    content(r3, box(..boxstyle(orange.transparentize(85%), orange.darken(20%)))[#align(center)[#text(size: 7pt)[Rung 3: Jónsson--Tarski embedding $A arrow.r.hook op("Em")(A)$ -- *off the shelf*]]])
    line(r3, r4, stroke: (paint: gray.darken(20%), thickness: 1pt), mark: (end: ">"))
    content(r4, box(..boxstyle(orange.transparentize(85%), orange.darken(20%)))[#align(center)[#text(size: 7pt)[Rung 4: duality $op("BAO")_tau tilde.equiv op("DGF")_tau^op("op")$ -- *off the shelf*]]])
    line(r4, r5, stroke: (paint: gray.darken(20%), thickness: 1pt, dash: "dashed"), mark: (end: ">"))
    content(r5, box(..boxstyle(red.transparentize(88%), red.darken(20%)))[#align(center)[#text(size: 7pt)[Rung 5: dual Kripke reduct is a *task frame* -- *blocked at* Spherical]]])
  }),
  caption: [Rungs 1--5 of the ladder. Solid arrows mark a step available now, in Lean or off the shelf; the dashed arrow marks the blocked step. Rung 6, the per-class refinement discussed in @sec:representation's closing subsection, is not pictured, since its status splits by frame class rather than forming a single further step.],
)

== The Algebraic Layer

One route has live, sorry-free groundwork.

#definition("The Lindenbaum--Tarski Algebra")[
  Quotient the sentences of $#BLplus$ by provable equivalence. The result carries a Boolean algebra
  structure induced by the connectives, on which $#allpast$ and $#allfuture$ act as *interior
  operators*: each is monotone, deflationary on the relevant order, and idempotent, so each is
  determined by its algebra of fixed points. The ultrafilters of this algebra correspond
  bijectively to the maximal consistent sets of @sec:construction.#footnote[The flow-frame engine of @sec:construction lives alongside them in `FlowFrame.lean`. All five measure sorry-free.]
]
#leansrc("Metalogic.Algebraic.LindenbaumQuotient", "LindenbaumAlg")
#leansrc("Metalogic.Algebraic.InteriorOperators", "boxInterior")
#leansrc("Metalogic.Algebraic.UltrafilterMCS", "mcsToUltrafilter")

#remark[
  The correspondence is Stone's @stone1936, specialized: points of the dual space are ultrafilters
  and the modal operators become operations on that space. What the layer supplies is one half of a
  duality --- the passage from syntax to an algebra and from the algebra to a space of points. What
  it does not yet supply is the passage back, from an abstract algebra to a *task frame*, which is
  where the frame axioms of @sec:system enter and where the difficulty is.
]

The Jónsson--Tarski route @jonssontarski1951 @jonssontarski1952 --- the complex algebra
$"Cm"(#taskframe)$ of a frame, the ultrafilter frame $"Uf"(A)$ of an abstract algebra, and the
canonical embedding $eta(a) = {U : a in U}$ --- was moved out of the live tree into an archived
subtree, and nothing under it is live. What it leaves undone, and the diagnosis of the block at
rung 5, are taken up below.

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
