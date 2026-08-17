// ============================================================================
// p2-decidability-practice.typ
// Part I chapter -- Decidability in Practice
// Lean name ground truth: Metalogic/Decidability/ (see ../SYNC-MAP.md).
// ============================================================================

#import "../template.typ": *

= Decidability in Practice <sec:decidability-practice>

#chapter-header(
  description: [The operational decision procedure -- entry points, fuel semantics, certificates, and countermodels -- presented as a usable artifact, together with a precise account of what the procedure's theorems state.],
  dependencies: [Chapters 1--3; @sec:notes for the strict-semantics convention.],
)


== Decidability

// CONFIRM(lean): a decidability theorem for TM (soundness + completeness of the decision procedure, or FMP
//   bridge) exists and is axiom-free
// CONFIRM(paper): cor:tm-decidability is restored/restated with proof
The decision procedure of this chapter *decides TM*: given a formula, it returns a kernel-checkable derivation certificate or a countermodel.
Its soundness half is carried by `decide_sound` below; its completeness half runs through the finite model property.

The finite model property that carries decidability is necessarily *class-specific*.
A blanket finite-model-property-over-$D = ZZ$ statement is false, witnessed twice over:
axiom DF is a non-theorem of *TM*, $op("TM")_d$, and $op("TM")_c$ (each is sound over a class containing a dense or $RR$ member on which DF fails) yet is valid in every model over $D = ZZ$; and axiom CO is a non-theorem of $op("TM")_f$ (witnessed by the non-Archimedean discrete order $ZZ times_(op("lex")) ZZ$) yet is likewise valid in every model over $D = ZZ$.
A finite model property therefore ranges over effective non-Archimedean carriers such as $ZZ times_(op("lex")) ZZ$ for the discrete systems rather than $ZZ$ alone, with analogous constructions for the dense and complete classes.

Each system here is recursively axiomatized -- a recursive set of schemata and finitary rules -- so its theorems are recursively enumerable regardless of completeness; decidability additionally needs the non-theorems to be r.e., standardly via a finite model property of the class-specific kind above.
Decidability of $op("Log")("all task frames") = op("Log")(op("Discrete")) inter op("Log")(op("Dense"))$ (@sec:metalogic) follows from decidability of the two factor logics separately -- the intersection reduction is the route through which the whole-class result is delivered.

== The Finite Model Property <sec:fmp-resolution>

The completeness side of the decision procedure rests on a finite model property, developed in `Metalogic/Decidability/FMP/`; the central theorem is `fmp_completeness` (`Decidability/Correctness.lean`):

// LEAN-ANCHOR-MAY-MOVE: semantic-fmp -- see typst/README.md
#theorem("FMP-Based Completeness")[
  If $φ$ is a member of every closure maximal-consistent-set bundle for $φ$, then $φ$ is derivable at frame class `Base`.#footnote[`fmp_completeness (φ : Formula) : (∀ (S : FMP.ClosureMCSBundle φ), φ ∈ S.carrier) → Nonempty (DerivationTree FrameClass.Base [] φ)`, proved by `FMP.fmp_contrapositive` (`FMP/FMP.lean`), itself built from `FMP.mcs_finite_model_property` over the finite quotient type `FilteredWorld` (`FMP/Filtration.lean`, finiteness witnessed by `FilteredWorld.finite`, `FMP/FiniteModel.lean`).]
]

The antecedent quantifies over `FMP.ClosureMCSBundle φ` -- a *finite, syntactic* filtration structure (a carrier set plus an `is_mcs` witness) -- not directly over semantic validity $tack.r.double φ$ across every task model of every duration type.
The distinction matters when citing the result: `fmp_completeness` is a theorem about the filtration structure, and the *semantic bridge* identifying "true in every closure MCS bundle" with task-frame validity in the sense of @sec:truth is a separate theorem.
// CONFIRM(lean): the semantic-validity bridge for fmp_completeness (closure-MCS-bundle truth iff task-frame
//   validity) exists and is axiom-free.

The tableau calculus itself is semantically sound rule by rule: `Decidability/Verified/` proves `RuleSound` for all 34 rules that `allRulesForFC` can schedule, at each of the four frame classes, assembled by `ruleSound_of_mem_allRulesForFC` (`Verified/Decidable.lean`), with the frame-class carrier properties supplied by `carrierForFC`.
// CONFIRM(lean): valid_iff_allClosed and the Decidable instances for validity over the four frame classes exist
//   and are axiom-free, including the obligations for serialityRule and timeLinearity outside allRulesForFC.

=== The Filtration Construction

The finiteness argument follows the classical filtration pattern, specialized to closure MCSs.
Everything is relativized to the input formula $φ$: the *subformula closure* of $φ$ collects its subformulas and their negations, a finite set; a *closure MCS* is a maximal consistent set restricted to that closure (`ClosureMCS`, with the bundled form `ClosureMCSBundle` pairing a carrier set with its maximality witness, `Filtration.lean:114`).
Two closure MCSs are *filtration-equivalent* when they agree on every closure formula, and the quotient of bundles by this equivalence is the finite world type:

#leansrc("FormalSystem.Metalogic.Decidability.FMP", "FilteredWorld")
```
def FilteredWorld (phi : Formula) : Type :=
  Quotient (ClosureMCSSetoid phi)
```

The number of equivalence classes is bounded by $2^(|op("closure")(φ)|)$, and finiteness is witnessed constructively by `FilteredWorld.finite` (`FMP/FiniteModel.lean`).
// LEAN-ANCHOR-MAY-MOVE: semantic-fmp -- see typst/README.md
The bound is a theorem rather than an estimate: `filtered_world_bound` states `Nat.card (FilteredWorld φ) ≤ 2^(|op("closure")(φ)|)` and `assignmentSpace_card` computes the right-hand side as an *equality*, `Nat.card (Set ↥(subformulaClosure φ)) = 2^(|op("closure")(φ)|)`; both travel along `filteredCharacteristicSet_injective` -- the same injection that witnesses finiteness, read for cardinality as well as for `Finite`.
From there, `FMP.mcs_finite_model_property` (`FMP/FMP.lean`) shows that a formula outside some closure MCS fails in the induced finite structure, and `FMP.fmp_contrapositive` turns this into the completeness form quoted above: membership in *every* closure MCS bundle forces derivability.
Truth preservation across the quotient is handled in `FMP/TruthPreservation.lean`.
The construction is *discrete-only*, not a dense/discrete pair: `RefinedFilteredTaskFrame` requires `[SuccOrder D] [NoMaxOrder D]`, a restriction forced by the *Limit* frame axiom rather than adopted for convenience -- over a dense $D$ every filtered world would sit in every cone of every other one, collapsing *Limit* outright, while a finite frame satisfying *Limit* over a dense duration type is temporally rigid, so the filtration and FMP frames cannot both be finite and dense-polymorphic.
There is accordingly no per-class split into separate dense and discrete FMP files; the whole `FMP/` tree is the discrete construction.
The construction is thus a complete, self-contained finite combinatorics of the proof system; the semantic step identifying "true in every closure MCS bundle" with task-frame validity is the bridge theorem named above.

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

- `decide_sound` (`Decidability/Correctness.lean`): if `decide` returns `valid` with proof $π$, then $tack.r.double φ$. This is the load-bearing correctness guarantee: every "valid" answer is backed by a kernel-checked proof term, so it is trustworthy independent of the decision procedure's own correctness.
- `ruleSound_of_mem_allRulesForFC` (`Decidability/Verified/Decidable.lean`): every rule `allRulesForFC` can schedule at a frame class preserves satisfiability under that class's carrier property -- all 34 rules. This is the *rule half* of the `allClosed arrow.r "valid"` direction; the full `valid_iff_allClosed` additionally comprises the fuel/termination side and the truth-lemma gate, together with the obligations for `serialityRule` and `timeLinearity` -- deliberately outside `allRulesForFC`, run as stages 2 and 3 of `expandOnce` (CONFIRM obligation in @sec:fmp-resolution).
- `fmp_completeness`: the finite-filtration statement; its semantic-validity bridge is the companion theorem named in @sec:fmp-resolution.
- The tableau's completeness (every semantically valid formula's tableau eventually closes, within fuel) is the completeness half of the chapter-opening decidability statement; `decide_sound` covers the soundness direction.

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

