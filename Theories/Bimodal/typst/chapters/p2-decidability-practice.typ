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


== The Finite Model Property <sec:fmp-resolution>

The completeness side of the decision procedure rests on a finite model property, developed in `Metalogic/Decidability/FMP/`.
The entire `Metalogic/Decidability/` tree, including all seven `FMP/` files, is sorry-free, and the central theorem is `fmp_completeness` (`Decidability/Correctness.lean:123`):

#theorem("FMP-Based Completeness")[
  If $φ$ is a member of every closure maximal-consistent-set bundle for $φ$, then $φ$ is derivable at frame class `Base`.#footnote[`fmp_completeness (φ : Formula) : (∀ (S : FMP.ClosureMCSBundle φ), φ ∈ S.carrier) → Nonempty (DerivationTree FrameClass.Base [] φ)`, `Metalogic/Decidability/Correctness.lean:123-126`, proved (sorry-free) by `FMP.fmp_contrapositive` (`FMP/FMP.lean:206`), itself built from `FMP.mcs_finite_model_property` (`FMP/FMP.lean:193`) over the finite quotient type `FilteredWorld` (`FMP/Filtration.lean:152`, finiteness witnessed sorry-free by `FilteredWorld.finite`, `FMP/FiniteModel.lean:131`).]
]

The antecedent quantifies over `FMP.ClosureMCSBundle φ` -- a *finite, syntactic* filtration structure (`Filtration.lean:114`: a carrier set plus an `is_mcs` witness) -- not directly over semantic validity $tack.r.double φ$ across every task model of every duration type.
The finite-filtration completeness argument is therefore complete as it stands, while the bridge connecting "true in every closure MCS bundle" to semantic validity in the task-frame sense of @sec:truth is an open problem.
The distinction matters when citing the result: `fmp_completeness` is a theorem about the filtration structure, not a theorem about task-frame validity.

=== The Filtration Construction

The finiteness argument follows the classical filtration pattern, specialized to closure MCSs.
Everything is relativized to the input formula $φ$: the *subformula closure* of $φ$ collects its subformulas and their negations, a finite set; a *closure MCS* is a maximal consistent set restricted to that closure (`ClosureMCS`, with the bundled form `ClosureMCSBundle` pairing a carrier set with its maximality witness, `Filtration.lean:114`).
Two closure MCSs are *filtration-equivalent* when they agree on every closure formula, and the quotient of bundles by this equivalence is the finite world type:

#leansrc("Bimodal.Metalogic.Decidability.FMP", "FilteredWorld")
```
def FilteredWorld (phi : Formula) : Type :=
  Quotient (ClosureMCSSetoid phi)
```

The number of equivalence classes is bounded by $2^(|op("closure")(φ)|)$, and finiteness is witnessed constructively by `FilteredWorld.finite` (`FMP/FiniteModel.lean:131`).
From there, `FMP.mcs_finite_model_property` (`FMP/FMP.lean:193`) shows that a formula outside some closure MCS fails in the induced finite structure, and `FMP.fmp_contrapositive` (`FMP/FMP.lean:206`) turns this into the completeness form quoted above: membership in *every* closure MCS bundle forces derivability.
Truth preservation across the quotient is handled in `FMP/TruthPreservation.lean`, and the dense and discrete refinements live in `FMP/DenseFMP.lean` and `FMP/DiscreteFMP.lean`.
The construction is thus a complete, self-contained finite combinatorics of the proof system; what it does not supply -- the open bridge noted above -- is the semantic step identifying "true in every closure MCS bundle" with task-frame validity.

== The Decision Procedure

`decide` is the top-level entry point:

#leansrc("Bimodal.Metalogic.Decidability", "decide")
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
- `validity_decidable` (`Decidability/Correctness.lean:72`): stated as `(⊨ φ) ∨ ¬(⊨ φ)`. Its proof is literally `Classical.em (⊨ φ)` -- this is *not* a constructive decidability result and should never be cited as one; it is a vacuous classical tautology, included in the file for documentation purposes only.
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
    [Constructive validity decidability], [Open problem (`validity_decidable` is vacuous)],
    [Fully automated decidable fragment], [Open problem],
    table.hline(),
  ),
  caption: [Decidability status summary.],
)
