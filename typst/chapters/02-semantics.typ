// ============================================================================
// 02-semantics.typ
// Semantics chapter for Bimodal TM Logic Reference Manual
// ============================================================================

#import "../template.typ": *

= Task Semantics


== Task Frames

Task frames are the fundamental semantic structures for *TM*; the semantics presented in this chapter follows @brastmckie2026possibleworlds.
They abstract from universal laws governing transitions between world states while still retaining the temporal duration for a transition to complete.

The following primitives are required to define a task frame:

#figure(
  table(
    columns: 3,
    stroke: none,
    table.hline(),
    table.header(
      [*Primitive*], [*Type*], [*Description*],
    ),
    table.hline(),
    [$W$], [Type], [World states (nonempty)],
    [$D$], [Temporal order], [Durations --- a nontrivial totally ordered abelian group],
    [$w #overset($arrow.r.double.long$, $x$) u$], [$W arrow.r D^+ arrow.r W arrow.r "Prop"$], [Task relation, primitive on the positive cone $D^+$ and extended below],
    table.hline(),
  ),
  caption: none,
)

#definition("Temporal Order")[
  A *temporal order* is a nontrivial totally ordered abelian group $D = (D, +, 0, lt.eq)$ with *positive cone* $D^+ := { x in D : x gt.eq 0 }$.#footnote[`def:temporal-order`; source text pinned verbatim in `specs/paper-definitions-of-record.md`. @brastmckie2026possibleworlds]
]

This algebraic choice is not incidental to the rest of the book: the discrete-or-dense dichotomy driving the completeness architecture of @sec:metalogic depends on $D$ being an ordered abelian group and *fails* for a bare linear order (translation invariance is what globalizes a local gap or density witness).
The Lean structure `TaskFrame` (`Semantics/TaskFrame.lean`) requires exactly this: `D` carries `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`, and `Nontrivial` instances, matching `def:temporal-order` field for field.

#definition("Task Relation")[
  A *task relation* on a nonempty set of world states $W$ over a temporal order $D$ is any parameterized relation $w arrow.r.double.long_x u$ for $w, u in W$ and $x in D^+$, extended to negative durations by the *converse convention*
  $ w arrow.r.double.long_(-x) u := u arrow.r.double.long_x w quad "for" x gt.eq 0, $
  determining, for any world states $w, v in W$ and durations $x, y in D$:
  - *Fiber*: $"Fib"(w, x) := { u in W : w arrow.r.double.long_x u }$.
  - *Cone*: $(w)_x := union.big_(|y| < x) "Fib"(w, y)$ where $x > 0$.
  - *Segment*: $[w, v]_x^y := "Fib"(w, x) inter "Fib"(v, -y)$ where $x, y gt.eq 0$.
]#footnote[`def:task-relation`; source text pinned verbatim in `specs/paper-definitions-of-record.md`. @brastmckie2026possibleworlds]

There is therefore no separate *Reflection* axiom: the equivalence $w arrow.r.double.long_x u arrow.l.r.double u arrow.r.double.long_(-x) w$ is built into the task relation's definition by the converse convention above, not imposed as a further constraint on frames.
Any converse operation written explicitly in this book uses a superscript inverse ($arrow.r.double.long^(-1)$), never the relation-algebra breve or smile common in the arrow-logic literature; the paper itself introduces no operator symbol for the convention at all, writing it only as subscript negation.

#definition("Directed Family")[
  A nonempty family of sets $S$ is *directed* just in case $S' subset.eq S_1 inter S_2$ for some $S' in S$ whenever $S_1, S_2 in S$.
]#footnote[`def:directed`; source text pinned verbatim in `specs/paper-definitions-of-record.md`. @brastmckie2026possibleworlds]

#definition("Frame")[
  A *frame* is any $cal(F) = (W, D, arrow.r.double.long)$ where $W$ is a nonempty set of world states, $D$ is a temporal order, and $arrow.r.double.long$ is a task relation satisfying the following for $x, y gt.eq 0$:
  + *Compositionality*: $w arrow.r.double.long_(x+y) v$ if and only if $w arrow.r.double.long_x u$ and $u arrow.r.double.long_y v$ for some $u in W$.
  + *Seriality*: $w arrow.r.double.long_x u$ and $v arrow.r.double.long_x w$ for some $u, v in W$.
  + *Limit*: $inter.big_(x > 0) (w)_x = {w}$.
  + *Spherical*: $inter.big S eq.not emptyset$ for any directed family $S$ of nonempty fibers and segments.
]#footnote[`def:frame`; source text pinned verbatim in `specs/paper-definitions-of-record.md`. @brastmckie2026possibleworlds Compositionality is a *biconditional*, load bearing in both directions.]

*Compositionality* ensures that executing tasks sequentially yields results consistent with a single task of combined duration, in both directions.
*Seriality* ensures every world state has a successor and a predecessor at every nonnegative duration.
*Limit* ensures that shrinking the duration bound around $w$ pins down $w$ uniquely --- no other world state lies in every cone around it.
*Spherical* is what makes the extension machinery of @sec:world-histories go through: it guarantees that a directed family of nonempty fibers and segments --- the constraints a new time imposes on a partial history, kept as two separate classes, never conflated --- has a common point.
Fibers and segments range over *two separate classes* in *Spherical*; the retired device by which fibers were folded into a one-sided case of segments is not current notation.

Nullity is conspicuously absent from this list because it is not an axiom:

#lemma("Nullity")[
  $w arrow.r.double.long_0 w$ for every world state $w in W$ in every frame $cal(F) = (W, D, arrow.r.double.long)$.
]#footnote[`lem:nullity`; source text pinned verbatim in `specs/paper-definitions-of-record.md`. @brastmckie2026possibleworlds]

The proof is choice-free and short: instantiate *Seriality* at $x = 0$ to get some $u in W$ with $w arrow.r.double.long_0 u$; *Limit* at $x arrow.r 0^+$ then forces $u = w$, since $w$ is the unique point in every cone around itself.
This is worth pausing on, because demoting Nullity from axiom to lemma is a genuine simplification, not mere reshuffling: *Seriality* and *Limit* alone suffice, so a frame satisfying the four axioms above automatically satisfies Nullity, and nothing is lost by not stating it separately.

The Lean structure `TaskFrame` (`Semantics/TaskFrame.lean`) packages this presentation field-for-field, and the correspondence is one of *agreement*, not divergence: the primitive `TaskRel` relation carries #leanComp, the paper's biconditional *Compositionality* in full (of which the composition, i.e. $arrow.l$, direction is projected out separately as #leanForwardComp, restricted to $x, y gt.eq 0$ exactly as `def:frame` states it); #leanConverse packages the *converse convention* of `def:task-relation` as structure data, since a two-sided Lean relation cannot carry the convention in its type, so the pair (two-sided `TaskRel`, #leanConverse) *is* the paper's extended relation over a primitive relation on $D^+$, constraining rather than adding to it; #leanSerial is *Seriality* verbatim, stated by citation as `TaskFrame.Serial TaskRel`; #leanLimit is *Limit* verbatim, in the literal transcribed shape; and #leanSpherical is *Spherical* verbatim, stated by citation as `TaskFrame.Spherical TaskRel` so that fibers and segments remain two separate classes, exactly as `def:directed` and `def:frame` require --- this field is what the Step Lemma of @sec:world-histories consumes.
#leanNullityDerived (`TaskRel w 0 w`) is *derived* from these fields via #leanNullityIdentity, matching `lem:nullity`'s derived status in the paper.

One open point should be recorded rather than smoothed over: #leanNullityIdentity is stated as an *iff* ($w arrow.r.double.long_0 u arrow.l.r.double w = u$), which is strictly stronger than `lem:nullity`'s reflexivity-only conclusion --- it additionally asserts injectivity at zero duration. The Lean module documents this as an open design question, not yet settled jointly with other in-flight formalization work, and it is left as-is here; no Lean change is made by this revision.

== World Histories <sec:world-histories>

A world history is a function from times to world states that respects the task relation over a convex temporal domain.
World histories represent possible paths through the space of world states.

#definition("Convex Domain")[
  A domain $"dom" : D arrow.r "Prop"$ is *convex* if whenever $a, c in "dom"$ with $a lt.eq c$, every time $b$ with $a lt.eq b lt.eq c$ is also in $"dom"$.
  More precisely, for all $a, b, c : D$, if $"dom"(a)$ and $"dom"(c)$ and $a lt.eq b lt.eq c$, then $"dom"(b)$.
  Convexity ensures the domain has no temporal gaps.
]

#definition("World History")[
  A *world history* in a task frame $cal(F)$ is a dependent function $tau : (x : D) arrow.r "dom"(x) arrow.r W$ where $"dom" : D arrow.r "Prop"$ is a convex subset of $D$ and $tau(x) arrow.r.double.long_(y-x) tau(y)$ for all times $x, y : D$ with $"dom"(x)$, $"dom"(y)$, and $x lt.eq y$.
  We write $H_(cal(F))$ for all world histories over frame $cal(F)$.
]

== Task Models

A task model extends a task frame with an interpretation function that assigns truth values to sentence letters at world states.
*Propositions* are subsets of $W$ representing instantaneous ways for the system to be.
Sentence letters express propositions, which can be realized by zero or more world states.
World states themselves are specific configurations of the total system at an instant.

#definition("Task Model")[
  A *task model* defined over a frame $cal(F)$ is a pair $cal(M) = (cal(F), I)$ where the *interpretation function* $I : W arrow.r "Atom" arrow.r "Prop"$ assigns to each world state $w : W$ and sentence letter $p : "Atom"$ a truth value $I(w, p) : "Prop"$.
  We write $I(w, p)$ to indicate that sentence letter $p$ is true at $w$.
]

== Truth Conditions <sec:truth>

Truth is evaluated relative to a model $cal(M)$ providing the interpretation, a world history $tau$ representing a possible path through the space of world states, and a time $x : D$.
Whereas the model fixes the interpretation of the language, the contextual parameters $tau$ and $x$ determine the truth value of every sentence of the language.

#definition("Truth")[
  For model $cal(M)$, history $tau : H_(cal(F))$, and time $x : D$, truth is defined by recursion on the six primitive constructors:#footnote[`TruthAt` in `Semantics/Truth.lean`.]
  $
    cal(M), tau, x tack.r.double p &#Iff x in "dom"(tau) "and" I(tau(x), p) \
    cal(M), tau, x tack.r.double.not bot \
    cal(M), tau, x tack.r.double phi.alt arrow.r psi &#Iff
      cal(M), tau, x tack.r.double.not phi.alt "or" cal(M), tau, x tack.r.double psi \
    cal(M), tau, x tack.r.double square.stroked phi.alt &#Iff
      cal(M), sigma, x tack.r.double phi.alt "for all" sigma : H_(cal(F)) \
    cal(M), tau, x tack.r.double U(phi.alt, psi) &#Iff
      "for some" y : D "with" x < y "we have" cal(M), tau, y tack.r.double phi.alt \
      &quad "and" cal(M), tau, z tack.r.double psi "for all" z : D "where" x < z < y \
    cal(M), tau, x tack.r.double S(phi.alt, psi) &#Iff
      "for some" y : D "with" y < x "we have" cal(M), tau, y tack.r.double phi.alt \
      &quad "and" cal(M), tau, z tack.r.double psi "for all" z : D "where" y < z < x
  $
]

Until and Since use a *strict witness* with an *open guard*: the witness time $y$ is strictly future (respectively strictly past), and the guard $psi$ is required only on the open interval strictly between $x$ and $y$.
The derived tense operators then receive their expected *strict* truth conditions as characterization theorems:#footnote[`future_iff`, `past_iff`, and companions in `Semantics/Truth.lean`; the semantics is irreflexive: G and H exclude the present moment, so the temporal T-axioms $G phi.alt arrow.r phi.alt$ and $H phi.alt arrow.r phi.alt$ are not valid.]

#theorem("Derived Truth Conditions")[
  $
    cal(M), tau, x tack.r.double H phi.alt &#Iff
      cal(M), tau, y tack.r.double phi.alt "for all" y : D "where" y < x \
    cal(M), tau, x tack.r.double G phi.alt &#Iff
      cal(M), tau, y tack.r.double phi.alt "for all" y : D "where" x < y \
    cal(M), tau, x tack.r.double P phi.alt &#Iff
      cal(M), tau, y tack.r.double phi.alt "for some" y : D "where" y < x \
    cal(M), tau, x tack.r.double F phi.alt &#Iff
      cal(M), tau, y tack.r.double phi.alt "for some" y : D "where" x < y
  $
]

The modal operator $square.stroked$ quantifies over all world histories $sigma : H_(cal(F))$ at the current time $x : D$.
The temporal operators quantify over all earlier and later times $y : D$ --- over the whole temporal order, not merely the history's domain, so atoms are false (rather than undefined) at times outside $"dom"(tau)$.


== Time-Shift

The time-shift operation is used to establish the *perpetuity principles*:
- P1: $square.stroked phi.alt arrow.r triangle.stroked.t phi.alt$ (what is necessary is always the case)
- P2: $triangle.stroked.b phi.alt arrow.r diamond.stroked phi.alt$ (what is sometimes the case is possible)

It is natural to assume that whatever is necessary is always the case, or equivalently, whatever is sometimes the case is possible.
Time-shift enables the validity proof of the bimodal interaction axiom MF ($square.stroked phi.alt arrow.r square.stroked G phi.alt$); together with the derived theorem TF ($square.stroked phi.alt arrow.r G square.stroked phi.alt$) it yields the perpetuity principles.

#definition("Time-Shift")[
  For $tau, sigma in H_(cal(F))$ and $x, y : D$, world histories $tau$ and $sigma$ are *time-shifted from $y$ to $x$*, written $tau #timeshift($y$, $x$) sigma$, if and only if there exists an order automorphism $overline(a) : D arrow.r D$ where $y = overline(a)(x)$, $"dom"_sigma = overline(a)^(-1)("dom"_tau)$, and $sigma(z) = tau(overline(a)(z))$ for all $z in "dom"_sigma$.
]

Time-shifting preserves the essential structure of histories:

#theorem("Convexity Preservation")[
  If $tau$ has a convex domain and $tau #timeshift($y$, $x$) sigma$, then $sigma$ has a convex domain.
]

#theorem("Task Preservation")[
  If $tau$ respects the task relation and $tau #timeshift($y$, $x$) sigma$, then $sigma$ respects the task relation.
]

== Logical Consequence and Validity

Logical consequence and validity are defined uniformly across all temporal types, frames, models, histories, and times.

#definition("Logical Consequence")[
  A formula $phi.alt$ is a *logical consequence* of $Gamma$ (written $Gamma tack.r.double phi.alt$) just in case for every temporal type $D : "Type"$, frame $cal(F) : "TaskFrame"(D)$, model $cal(M) : "TaskModel"(cal(F))$, history $tau in H_(cal(F))$, and time $x : D$, if $cal(M), tau, x tack.r.double psi$ for all $psi in Gamma$, then $cal(M), tau, x tack.r.double phi.alt$.
]

#definition("Validity")[
  A formula $phi.alt$ is *valid* (written $tack.r.double phi.alt$) just in case $phi.alt$ is a logical consequence of the empty set: $emptyset tack.r.double phi.alt$.
  Equivalently, $phi.alt$ is true at every model-history-time triple.
]

#definition("Satisfiability")[
  A context $Gamma$ is *satisfiable* in temporal type $D : "Type"$ if there exist a frame $cal(F) : "TaskFrame"(D)$, model $cal(M) : "TaskModel"(cal(F))$, history $tau in H_(cal(F))$, and time $x : D$ such that $cal(M), tau, x tack.r.double psi$ for all $psi in Gamma$.
]

#theorem("Monotonicity")[
  If $Gamma subset.eq Delta$ and $Gamma tack.r.double phi.alt$, then $Delta tack.r.double phi.alt$.
]

#remark("Determined and Deterministic")[
  The task-frame setting supports a distinction between a history's future being *determined* (every history through the present world state agrees on it) and the frame being *deterministic* (the task relation is functional), developed together with actuality operators in @brastmckie2026possibleworlds.
  Neither notion has a formal Lean counterpart in this repository; both belong to the semantic framework's paper-side development.
]
