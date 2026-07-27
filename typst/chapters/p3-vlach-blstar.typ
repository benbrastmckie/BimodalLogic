// ============================================================================
// p3-vlach-blstar.typ
// Part I chapter -- Vlach Operators and the BL* Tower
//
// Citation scoping: the expressive-completeness theorem is cited to kamp1968
// (+ rabinovich2014); kamp1971formalproperties is cited only for the "now"
// operator. Paper clauses follow possible_worlds.tex:1007-1060, 1246-1256.
// ============================================================================

#import "../template.typ": *

= Vlach Operators and the BL#super[⋆] Tower <ch:vlach-blstar>

#chapter-header(
  description: [The store/recall operators that extend the bimodal language with cross-referencing power over both times and worlds, the resulting language BL#super[⋆], and the hybrid-logic prior art against which both are positioned -- including Kamp's expressive-completeness theorem, correctly scoped.],
  dependencies: [Chapters 1--3 (syntax, semantics, proof theory); @sec:design-choices for the strict-semantics convention.],
)


== Why Cross-Reference?

The systems developed so far -- *TM* over the tense basis and *TM*#super[+] over the Until/Since basis -- are expressive enough for a wide range of temporal-modal reasoning, yet they lack the means by which to cross reference either times or worlds @brastmckie2026possibleworlds.
Natural language routinely performs exactly this kind of cross-referencing.
Consider the sentence "Once, everyone now alive hadn't yet been born."
Its truth conditions require evaluating "now alive" at the utterance time even though the phrase sits under a past-tense operator that has shifted the evaluation time; no nesting of $P$, $F$, $S$, and $U$ reproduces this behavior, because every operator of *TM*#super[+] shifts the point of evaluation without remembering where evaluation began.
Kamp introduced the rigid _now_ operator to handle such sentences @kamp1971formalproperties, and Vlach generalized the idea with a _then_ operator that recalls a previously stored time @vlach1973nowandthen.
The same phenomenon arises in the world dimension: hypothetical and modal discourse refers back to the world of evaluation from within the scope of a modal.

== The Store and Recall Operators

Following @brastmckie2026possibleworlds, the point of evaluation is extended with a vector $arrow(v) = chevron.l v_1, v_2, dots chevron.r$ of stored times and a vector $arrow(mu) = chevron.l mu_1, mu_2, dots chevron.r$ of stored worlds.
Four indexed families of operators read and write these registers, for each $i in NN$:

#definition("Store and Recall")[
  Writing $arrow(v)[i arrow.r.bar x]$ for the result of overwriting the $i$#super[th] coordinate of $arrow(v)$ with $x$ (and similarly for $arrow(mu)$):
  $
    cal(M), tau, x, arrow(v), arrow(mu) &tack.r.double arrow.t^i phi.alt &&<==> cal(M), tau, x, arrow(v)[i arrow.r.bar x], arrow(mu) tack.r.double phi.alt \
    cal(M), tau, x, arrow(v), arrow(mu) &tack.r.double arrow.b^i phi.alt &&<==> cal(M), tau, v_i, arrow(v), arrow(mu) tack.r.double phi.alt \
    cal(M), tau, x, arrow(v), arrow(mu) &tack.r.double arrow.t.double^i phi.alt &&<==> cal(M), tau, x, arrow(v), arrow(mu)[i arrow.r.bar tau] tack.r.double phi.alt \
    cal(M), tau, x, arrow(v), arrow(mu) &tack.r.double arrow.b.double^i phi.alt &&<==> cal(M), mu_i, x, arrow(v), arrow(mu) tack.r.double phi.alt
  $
  The *time-store* operator $arrow.t^i$ writes the evaluation time into register $v_i$; the *time-recall* operator $arrow.b^i$ shifts the evaluation time to the stored value $v_i$.
  The *world-store* operator $arrow.t.double^i$ writes the evaluation world into register $mu_i$; the *world-recall* operator $arrow.b.double^i$ shifts the evaluation world to the stored value $mu_i$.
]

#notation-env[
  The paper writes the four families as a single arrow pair subscripted by the coordinate being stored ($arrow.t_"T"^i$/$arrow.b_"T"^i$ for times, $arrow.t_"M"^i$/$arrow.b_"M"^i$ for worlds); this chapter uses single and double arrows instead, so that the coordinate is visible in the glyph.
]

These operators generalize Vlach's single now/then pair in two directions at once: the single pair becomes an indexed family, so that arbitrarily many times can be stored and recalled, and the mechanism is duplicated in the world coordinate, which Vlach's tense-anaphora setting did not require @vlach1973nowandthen.
Apart from threading $arrow(v)$ and $arrow(mu)$ through the point of evaluation, the semantics of the base language is unchanged: the truth conditions of @sec:truth carry over verbatim, ignoring the new parameters.

== Worked Evaluations

The register mechanics are best absorbed through small computations.
Fix a model, a history $tau$, and a time $x$, and abbreviate the extended evaluation point as $(tau, x, arrow(v), arrow(mu))$.

*Store-then-recall collapses.*
Consider $arrow.t^0 F arrow.b^0 phi.alt$ ("store now; at some future time, recall and check $phi.alt$").
Unfolding: the store writes $x$ into $v_0$; the $F$ shifts evaluation to some $y > x$; the recall shifts it back to $v_0 = x$.
The whole formula is therefore true at $(tau, x)$ iff $phi.alt$ is true at $(tau, x)$ and some strictly future time exists -- and seriality guarantees the latter, so $arrow.t^0 F arrow.b^0 phi.alt$ is equivalent to $phi.alt$.
Storing a point and recalling it under a single shift undoes the shift.

*Cross-referencing under a guard.*
Now interleave material between shift and recall: $arrow.t^0 G(phi.alt arrow.r arrow.b^0 psi)$ says "for every future time at which $phi.alt$ holds, $psi$ held back at the start".
Unfolding gives: for all $y > x$, if $phi.alt$ at $(tau, y)$ then $psi$ at $(tau, x)$ -- equivalent to $F phi.alt arrow.r psi$.
In the world coordinate the same pattern reads $arrow.t.double^0 diamond.stroked (phi.alt and arrow.b.double^0 psi)$: "some possible world verifies $phi.alt$ while the *original* world verifies $psi$", equivalent to $psi and diamond.stroked phi.alt$.

Each of these small patterns reduces to a register-free formula, which is precisely the wrong induction to draw from them: the reductions work because a single stored point is recalled under a single shift.
Nested patterns that store several points and recall them across each other's scopes resist such flattening, and Cresswell's argument shows the situation is not remediable by fixing any finite register discipline in advance @cresswell1990entities: natural-language cross-reference eventually demands as much power as explicit quantification over times and worlds.
The natural-language sentence of the opening section is the canonical illustration -- its "now" must survive under a past-tense shift *and* interact with a quantifier's restrictor, which is exactly the combination the flattening tricks cannot reach.

== The Stability Operator and BL#super[⋆]

The full extension tower also includes a restricted modality.
Given a world $tau in H_(cal(F))$ and time $x : D$, let $chevron.l tau chevron.r_x := { sigma in H_(cal(F)) | sigma(x) = tau(x) }$ be the set of possible worlds that intersect $tau$ at $x$.

#definition("Stability")[
  $cal(M), tau, x tack.r.double dot.square phi.alt <==> cal(M), sigma, x tack.r.double phi.alt$ for all $sigma in chevron.l tau chevron.r_x$.
]

The *stability* operator $dot.square$ quantifies over the worlds occupying the same world state as the world of evaluation at the time of evaluation.
Since intersection-at-$x$ is an equivalence relation on $H_(cal(F))$, the monomodal logic of $dot.square$ is again S5; and for non-temporal $phi.alt$, truth at $chevron.l cal(M), tau, x chevron.r$ depends only on the world state $tau(x)$, so $phi.alt arrow.r dot.square phi.alt$ is valid on that fragment -- stability collapses to the trivial modality on non-temporal formulas @brastmckie2026possibleworlds.
Letting $diamond.stroked.dot phi.alt := not dot.square not phi.alt$, the stability operators make _Will_ and _Could_ modals definable ($dot.square G phi.alt$, $dot.square F phi.alt$, $diamond.stroked.dot G phi.alt$, $diamond.stroked.dot F phi.alt$): what will or could unfold from the present world state.
Restricting the intersection set forward or backward yields the open-future and open-past sets $lr(|tau chevron.r)_x := { sigma in H_(cal(F)) | sigma(y) = tau(y) "for all" y lt.eq x }$ and $lr(chevron.l tau|)_x := { sigma in H_(cal(F)) | sigma(y) = tau(y) "for all" y gt.eq x }$, with corresponding operators quantifying over the worlds that share the evaluation world's past or future.
The philosophical payoff is that all three restricted quantifier domains are _definable_ from the construction of possible worlds -- provably $lr(|tau chevron.r)_x subset.eq chevron.l tau chevron.r_x$ and $lr(chevron.l tau|)_x subset.eq chevron.l tau chevron.r_x$ with $lr(|tau chevron.r)_x inter lr(chevron.l tau|)_x = {tau}$ -- whereas a semantics over structureless points would have to posit primitive accessibility relations and then impose frame constraints to keep them aligned with their intended readings @brastmckie2026possibleworlds.

The language that collects all of these resources is
$ "BL"^star := chevron.l "SL", bot, arrow.r, square.stroked, S, U, dot.square, arrow.t^i, arrow.b^i, arrow.t.double^i, arrow.b.double^i chevron.r, $
the terminus of the extension tower that begins with the tense basis and passes through the Until/Since basis.
The paper explicitly declines to axiomatize BL#super[⋆] -- extending *TM* to a proof system for it is outside that paper's scope @brastmckie2026possibleworlds -- and this book inherits the same boundary: no proof system for BL#super[⋆] is presented here, and none is formalized.
The paper's one worked use of the Vlach operators is its analysis of the open future, for which see @brastmckie2026possibleworlds and the closing remark of the semantics chapter on the determined/deterministic distinction.

== Prior Art: From "Now" to Hybrid Binders

The store/recall pattern has a well-charted history, and BL#super[⋆] is best understood as its two-coordinate generalization.

- *Kamp 1971* introduced _now_ as a rigid temporal reference point: however deeply embedded, _now_ returns evaluation to the utterance time @kamp1971formalproperties.
- *Vlach 1973* added _then_, making the reference point programmable: a storage operator marks a time, and _then_ recalls it -- the first genuine store/recall pair @vlach1973nowandthen.
- *Cresswell 1990* argued that the general case requires unboundedly many stored indices: two, three, or any fixed number of registers eventually fails, so storage operators approach full explicit quantification over times @cresswell1990entities.
- *Hybrid logic* systematizes the pattern with the $arrow.b$-binder, which names the current point, and the "at" operator, which returns evaluation to a named point @blackburn2000hybrid.
- *Goranko's reference pointers* are the direct temporal-logic ancestor of the indexed-register formulation used here @goranko1996.

Against this backdrop, the Vlach families of BL#super[⋆] are hybrid-style binders over the time _and_ world coordinates, with an indexed register vector in place of hybrid logic's named variables.
That identification cuts both ways: the hybrid $arrow.b$-binder has a well-known cost profile -- undecidability in general, with tamer behavior only in bounded or linearly-ordered fragments -- and that profile is what makes the ceiling-and-descent narrative of @sec:decidability-frontier the expected one for the BL#super[⋆] tower.
No results are stated here; the frontier chapter surveys the published landscape.

== Kamp's Theorem, Correctly Scoped

The deepest expressiveness fact in this neighborhood concerns the Until/Since basis itself, and it is worth stating with both of its scope conditions explicit.

#theorem("Expressive Completeness (Kamp)")[
  Over Dedekind-complete flows of time, the temporal language with _Until_ and _Since_ in their strict readings is expressively complete for the first-order theory of linear order: every first-order condition on a linear order with monadic predicates, in one free variable, is equivalent to a temporal formula.#footnote[Kamp's 1968 dissertation @kamp1968; the modern model-theoretic proof is due to Rabinovich @rabinovich2014. This is a paper-side theorem with no Lean anchor in this repository; see the formalization-frontier note below.]
]

Two conditions do real work.
First, the operators must be _strict_: they quantify over strictly earlier and strictly later times, excluding the present.
*TM* uses exactly this convention natively (@sec:design-choices), so the theorem speaks directly to the book's language rather than to a variant of it.
Second, the flow of time must be _Dedekind complete_; over arbitrary linear orders the result fails, which is why the completeness property of the paper's frame-constraint hierarchy earns its keep.
The theorem is frequently miscited to Kamp's 1971 _Theoria_ paper; that paper introduces the _now_ operator (its role in the prior-art narrative above) and does not contain the expressive-completeness theorem.

A completing note explains a difference from LTL that the next chapter revisits: over discrete, future-only, $NN$-like flows, the past-free fragment already suffices for first-order expressive completeness @gpss1980.
This is why LTL can afford to be a future-only language.
*TM* keeps its past operators because its flows are arbitrary ordered abelian groups, where no such reduction is available.

== The Formalization Frontier

A machine-checked Kamp theorem is an open problem.
`Metalogic/WeakCanonical/Kamp/` develops the Rabinovich proof chain @rabinovich2014 toward it: the target statement `kampPriorExpressiveCompleteness` says that every `MonadicFormula` with one free variable has an Until/Since-equivalent formula on Prior structures, with the translation implemented as `rabinovich_translate`.
The end-to-end theorem remains open.
