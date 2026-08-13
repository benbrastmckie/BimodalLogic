// ============================================================================
// p2-decidability-practice.typ
// Part I chapter -- Decidability in Practice
// Lean name ground truth: Metalogic/Decidability/ (see ../SYNC-MAP.md).
// ============================================================================

#import "../template.typ": *

= Decidability in Practice <sec:decidability-practice>

#chapter-header(
  description: [The operational decision procedure -- entry points, fuel semantics, certificates, and countermodels -- presented as a usable artifact, together with a precise account of what is and is not proven about it.],
  dependencies: [Chapters 1--3; @sec:notes for the strict-semantics convention.],
)


== Whole-System Decidability Is Open

Whether *TM*, $op("TM")_f$, $op("TM")_d$, $op("TM")_c$, and $op("TM")_(d c)$ are decidable is *open*.#footnote[`cor:tm-decidability` --- an anchor outside the 26 tracked by `specs/paper-definitions-of-record.md`, re-verified directly against the live paper for this citation rather than assumed. @brastmckie2026possibleworlds]
An earlier presentation of this claim rested on a blanket finite-model-property-over-$D = ZZ$ premise; that premise is *false* and has been retracted, witnessed twice over:
axiom DF is a non-theorem of *TM*, $op("TM")_d$, $op("TM")_c$, $op("TM")_(d c)$ (each is sound over a class containing a dense or $RR$ member on which DF fails) yet is valid in every model over $D = ZZ$; and axiom CO is a non-theorem of $op("TM")_f$ (witnessed by the non-Archimedean discrete order $ZZ times_(op("lex")) ZZ$) yet is likewise valid in every model over $D = ZZ$.
A repaired finite model property would have to be *class-specific*, ranging over effective non-Archimedean carriers such as $ZZ times_(op("lex")) ZZ$ for the discrete systems rather than $ZZ$ alone, with analogous constructions needed for the dense and complete classes; none of this is currently established.

What *is* true: each system here is recursively axiomatized -- a recursive set of schemata and finitary rules -- so its theorems are recursively enumerable regardless of completeness.
Decidability additionally needs the non-theorems to be r.e. as well, standardly via a finite model property of the repaired, class-specific kind above; none is established.
Decidability of $op("Log")("all task frames") = op("Log")(op("Discrete")) inter op("Log")(op("Dense"))$ (@sec:metalogic) would *follow* from decidability of the two factor logics separately -- that intersection reduction is the target *strategy*, not a result.
A verified *sound* tableau procedure exists in this repository (below), and the semantic, truth-connected finite model property for the $ZZ$-time discrete case is the target of ongoing formalization; no decidability theorem is machine-checked at present.

== The Finite Model Property <sec:fmp-resolution>

The completeness side of the decision procedure rests on a finite model property, developed in `Metalogic/Decidability/FMP/`.
The entire `Metalogic/Decidability/` tree, including all seven `FMP/` files, is sorry-free, and the central theorem is `fmp_completeness` (`Decidability/Correctness.lean:123`):

// LEAN-ANCHOR-MAY-MOVE: semantic-fmp -- see typst/README.md
#theorem("FMP-Based Completeness")[
  If $φ$ is a member of every closure maximal-consistent-set bundle for $φ$, then $φ$ is derivable at frame class `Base`.#footnote[`fmp_completeness (φ : Formula) : (∀ (S : FMP.ClosureMCSBundle φ), φ ∈ S.carrier) → Nonempty (DerivationTree FrameClass.Base [] φ)`, `Metalogic/Decidability/Correctness.lean:123-126`, proved (sorry-free) by `FMP.fmp_contrapositive` (`FMP/FMP.lean:206`), itself built from `FMP.mcs_finite_model_property` (`FMP/FMP.lean:193`) over the finite quotient type `FilteredWorld` (`FMP/Filtration.lean:152`, finiteness witnessed sorry-free by `FilteredWorld.finite`, `FMP/FiniteModel.lean:131`).]
]

The antecedent quantifies over `FMP.ClosureMCSBundle φ` -- a *finite, syntactic* filtration structure (`Filtration.lean:114`: a carrier set plus an `is_mcs` witness) -- not directly over semantic validity $tack.r.double φ$ across every task model of every duration type.
The finite-filtration completeness argument is therefore complete as it stands, while the bridge connecting "true in every closure MCS bundle" to semantic validity in the task-frame sense of @sec:truth is an open problem.
The distinction matters when citing the result: `fmp_completeness` is a theorem about the filtration structure, not a theorem about task-frame validity.

The bridge is *partly* built, and it is worth being precise about which part, because the tableau route rather than the filtration route is what has advanced.
What has landed is the semantic soundness of the tableau calculus itself: `Decidability/Verified/` now proves `RuleSound` for all 34 rules that `allRulesForFC` can schedule, at each of the four frame classes, assembled by `ruleSound_of_mem_allRulesForFC` (`Verified/Decidable.lean:3089`), with the frame-class carrier properties supplied by `carrierForFC` (`Verified/Decidable.lean:3074`).
What has *not* landed is the bridge itself: `valid_iff_allClosed` and the `Decidable` instances for validity over the four frame classes remain open, since they need the fuel/termination side and the truth-lemma gate on top of rule soundness, plus obligations for `serialityRule` and `timeLinearity`, which run outside `allRulesForFC`.
So the entry in the status table below stays an open problem; what changed is that its rule half is now discharged rather than assumed.

=== The Filtration Construction

The finiteness argument follows the classical filtration pattern, specialized to closure MCSs.
Everything is relativized to the input formula $φ$: the *subformula closure* of $φ$ collects its subformulas and their negations, a finite set; a *closure MCS* is a maximal consistent set restricted to that closure (`ClosureMCS`, with the bundled form `ClosureMCSBundle` pairing a carrier set with its maximality witness, `Filtration.lean:114`).
Two closure MCSs are *filtration-equivalent* when they agree on every closure formula, and the quotient of bundles by this equivalence is the finite world type:

#leansrc("FormalSystem.Metalogic.Decidability.FMP", "FilteredWorld")
```
def FilteredWorld (phi : Formula) : Type :=
  Quotient (ClosureMCSSetoid phi)
```

The number of equivalence classes is bounded by $2^(|op("closure")(φ)|)$, and finiteness is witnessed constructively by `FilteredWorld.finite` (`FMP/FiniteModel.lean:137`).
// LEAN-ANCHOR-MAY-MOVE: semantic-fmp -- see typst/README.md
Both halves of that sentence are now proved, and the bound is a theorem rather than an estimate: `filtered_world_bound` states `Nat.card (FilteredWorld φ) ≤ 2^(|op("closure")(φ)|)` and `assignmentSpace_card` computes the right-hand side as an *equality*, `Nat.card (Set ↥(subformulaClosure φ)) = 2^(|op("closure")(φ)|)`.
Both travel along `filteredCharacteristicSet_injective` (`FMP/FiniteModel.lean:96`) -- the same injection that witnesses finiteness, read for cardinality as well as for `Finite`.
This is worth stating explicitly because the two theorems previously carrying these names were vacuous: each concluded in a conjunct equivalent to plain `True`, discharged by `trivial`, so neither constrained `FilteredWorld` at all.
From there, `FMP.mcs_finite_model_property` (`FMP/FMP.lean:193`) shows that a formula outside some closure MCS fails in the induced finite structure, and `FMP.fmp_contrapositive` (`FMP/FMP.lean:206`) turns this into the completeness form quoted above: membership in *every* closure MCS bundle forces derivability.
Truth preservation across the quotient is handled in `FMP/TruthPreservation.lean`.
The construction is *discrete-only*, not a dense/discrete pair: `RefinedFilteredTaskFrame` requires `[SuccOrder D] [NoMaxOrder D]`, a restriction forced by the paper's *Limit* axiom rather than adopted for convenience -- over a dense $D$ every filtered world would sit in every cone of every other one, collapsing *Limit* outright, while a finite frame satisfying *Limit* over a dense duration type is temporally rigid, so the filtration and FMP frames cannot both be finite and dense-polymorphic.
There is accordingly no live per-class split into separate dense and discrete FMP files; the whole `FMP/` tree already is the discrete construction.
The construction is thus a complete, self-contained finite combinatorics of the proof system; what it does not supply -- the open bridge noted above -- is the semantic step identifying "true in every closure MCS bundle" with task-frame validity.

== The Decision Procedure

`decide` is the top-level entry point:

#leansrc("FormalSystem.Metalogic.Decidability", "decide")
```
def decide (φ : Formula) (searchDepth : Nat := 10) (tableauFuel : Nat := 1000)
    (fc : FrameClass := .Base) : DecisionResult φ
```

(`Decidability/DecisionProcedure.lean:122`). It first tries direct axiom and compositional proof shortcuts, then falls back to bounded proof search (@sec:proof-automation), then to a tableau over $F(φ)$; `DecisionResult` (`Decidability/DecisionProcedure.lean:58-64`) is one of `valid` (carries a `DerivationTree`), `invalid` (carries a `SimpleCountermodel`), or `timeout` -- the `tableauFuel` parameter (default 1000 steps) is the source of the timeout branch, guaranteeing termination without guaranteeing an answer.
Convenience wrappers `isValid` (`Decidability/DecisionProcedure.lean:163`) and `isSatisfiable` (`Decidability/DecisionProcedure.lean:169`) reduce to booleans.
`getProof?` (`Decidability/DecisionProcedure.lean:87`) and `getCountermodel?` (`Decidability/DecisionProcedure.lean:92`) extract the payload when present.

== Certificates and Countermodels

Every `valid` result carries a genuine `DerivationTree` proof term, checkable by Lean's kernel independently of the decision procedure that produced it.
`TraceCertificate.lean` additionally packages proof search traces: `ProofCertificate` (`Decidability/TraceCertificate.lean:108`, with an `empty` constructor at `Decidability/TraceCertificate.lean:137`) records the rule sequence, and `CertOutcome` (`Decidability/TraceCertificate.lean:89`: `validProof`/`countermodel`/`timeout`/`blocked`) classifies the outcome for downstream export (feeding Part II's dataset pipeline).
Every `invalid` result carries a `SimpleCountermodel` (`Decidability/CountermodelExtraction.lean:64`: `trueAtoms`/`falseAtoms`/`formula`), extracted from the open saturated tableau branch by `extractCountermodelSimple` (`Decidability/CountermodelExtraction.lean:137`, called directly by `decide`) or, for a richer variant retaining the full saturated branch, `extractSemanticCountermodel` (`Decidability/CountermodelExtraction.lean:305`) producing a `SemanticCountermodel` (`Decidability/CountermodelExtraction.lean:170`).

== Correctness Properties

- `decide_sound` (`Decidability/Correctness.lean:50`): if `decide` returns `valid` with proof $π$, then $tack.r.double φ$. Proven, sorry-free -- this is the load-bearing correctness guarantee: every "valid" answer is backed by a kernel-checked proof term, so it is trustworthy independent of the decision procedure's own correctness.
- `validity_decidable` and `validity_has_decision_procedure`: *deleted*. The first was stated as `(⊨ φ) ∨ ¬(⊨ φ)` and proved by `Classical.em (⊨ φ)`; the second as `∃ decision : Bool, decision = true ↔ ⊨ φ` and proved by `by_cases` on the very proposition it purported to decide. Neither was a constructive decidability result and neither should ever have been cited as one, so rather than keeping them "for documentation purposes" the file now carries a retirement note in their place (`Decidability/Correctness.lean`, "Retired as vacuous"), recording what each said, why its proof did not reach its name, and what remains owed before an `isValid`-shaped statement can stand.
- `ruleSound_of_mem_allRulesForFC` (`Decidability/Verified/Decidable.lean:3089`): every rule `allRulesForFC` can schedule at a frame class preserves satisfiability under that class's carrier property -- all 34 rules, sorry-free. This is the *rule half* of the `allClosed arrow.r "valid"` direction, and it is the real content that the deleted names gestured at. It is not yet `valid_iff_allClosed`, which additionally needs the fuel/termination side and the truth-lemma gate, and which says nothing about `serialityRule` and `timeLinearity` -- deliberately outside `allRulesForFC`, run as stages 2 and 3 of `expandOnce`.
- `fmp_completeness`: sorry-free as a finite-filtration statement; its semantic-validity bridge is open (@sec:fmp-resolution).
- The tableau's own completeness (every semantically valid formula's tableau eventually closes, within fuel) is not separately proven in this module; `decide_sound` covers only the soundness direction.

== A Worked Tableau Run

The tableau operates on *signed formulas*: each node of a branch is a formula tagged with a sign ($T$ for "true here", $F$ for "false here") and a label recording the world and time of evaluation (`SignedFormula`, `Metalogic/Decidability/SignedFormula.lean`).
Expansion rules (`TableauRule`, `Metalogic/Decidability/Tableau.lean:67`) come in two shapes: *linear* rules add formulas to the current branch, and *branching* rules split it.
The modal and temporal rules follow the S5 and strict-linear-order semantics directly: a true $square.stroked$-formula propagates to every world label on the branch (universal, persistent), a false $square.stroked$-formula introduces a fresh witness world, a false $G$-formula introduces a fresh strictly-future time, and a true $square.stroked$-formula additionally yields $G$ and $H$ versions at the same label -- the tableau image of the interaction principles $square.stroked phi.alt arrow.r G phi.alt$ and $square.stroked phi.alt arrow.r H phi.alt$.
A branch *closes* when it contains both $T(phi.alt)$ and $F(phi.alt)$ at the same label (or $T(bot)$); the tableau proves validity when every branch closes.

Two miniature runs illustrate both outcomes.

*A closing tableau.* To decide the MT instance $square.stroked p arrow.r p$, the procedure refutes its negation, seeding the branch with the signed formulas $T(square.stroked p)$ and $F(p)$ at the initial label $(w_0, t_0)$.
The `boxPos` rule propagates $T(p)$ to every known world at $t_0$ -- in particular to $w_0$ itself -- and the branch now contains $T(p)$ and $F(p)$ at the same label: closed.
Since the (single) branch closes, the formula is valid, and proof extraction (`Metalogic/Decidability/ProofExtraction.lean`) returns a `DerivationTree` certificate.

*An open tableau.* To decide $p arrow.r G p$, the branch is seeded with $T(p)$ and $F(G p)$ at $(w_0, t_0)$.
The `allFutureNeg` rule introduces a fresh time $t_1 > t_0$ carrying $F(p)$.
No rule ever forces $T(p)$ at $t_1$ -- the true atom at $t_0$ is not a universal -- so the branch saturates open.
The open saturated branch is precisely a countermodel description: $p$ true at $(w_0, t_0)$, false at $(w_0, t_1)$, which `extractCountermodelSimple` packages as a `SimpleCountermodel` refuting the formula.

== Complexity

The operational costs of the procedure are driven by two parameters.
The number of distinct signed formulas on a branch is bounded by the closure of the input formula (its subformulas and their negations) times the number of labels the run introduces, so each branch is polynomial in the input size for a fixed label budget; the number of *branches*, however, can grow exponentially in the number of branching-rule applications, giving worst-case exponential time overall.
Fresh-witness rules (`boxNeg`, `allFutureNeg`, and their duals) are the source of new labels, and universal rules must revisit each new label, which is why the implementation tracks universals as *persistent* and existentials as *consumable*.
The `tableauFuel` parameter bounds the total number of expansion steps: fuel-bounded termination trades completeness-within-fuel for a hard guarantee against non-termination, and an exhausted budget surfaces as the `timeout` outcome rather than as a wrong answer.

== Closing Status Table

#figure(
  table(
    columns: 2,
    stroke: none,
    align: (left, left),
    table.hline(),
    table.header([*Fragment / Property*], [*Status*]),
    table.hline(),
    [Decision soundness (`decide_sound`)], [Proven, sorry-free],
    [Finite-model-property completeness (`fmp_completeness`)], [Proven, sorry-free (finite-filtration statement)],
    [Semantic-validity bridge for FMP], [Open problem],
    [Rule soundness for every scheduled rule (`ruleSound_of_mem_allRulesForFC`)], [Proven, sorry-free (34 of 34 rules)],
    [Model-size bound $2^(|op("closure")(φ)|)$ (`filtered_world_bound`)], [Proven, sorry-free],
    [Constructive validity decidability], [Open problem (`valid_iff_allClosed` and the `Decidable` instances are still owed)],
    [Fully automated decidable fragment], [Open problem],
    table.hline(),
  ),
  caption: [Decidability status summary.],
)
