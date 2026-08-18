/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.DecisionProcedure
import FormalSystem.Metalogic.Decidability.FMP.FMP
import FormalSystem.Metalogic.Soundness

/-!
# Correctness of the Decision Procedure

This module proves properties of the tableau decision procedure.

## Main Theorems

- `decide_sound`: A derivation produced by `decide` yields semantic validity
- `decide_result_exclusive`: Decision results are mutually exclusive
- `not_undecided_of_extractionFailed`: A closed tableau is never reported as undecided

See "`validity_decidable` / `validity_has_decision_procedure` — Retired as vacuous", below, for
the two theorems that used to head this list, why their names overclaimed what their proofs
established, and what is still owed before an `isValid`-shaped decidability statement can stand.

## Implementation Notes

The `soundness` theorem in `Soundness.lean` proves `Γ ⊢[Base] φ → Γ ⊨ φ`, i.e.,
derivability from context `Γ` at `FrameClass.Base` implies semantic consequence.
The `FrameClass.Base` parameter structurally excludes axioms with
`minFrameClass > Base` (density, Prior-UZ/SZ, z1) via the `h_fc` gate.

- `decide_sound`: If `decide φ` returns `.valid proof`, then `⊨ φ` (semantic validity)
- Frame-class specific soundness is available via `soundness_dense`, `soundness_discrete`

## References

* Wu, M. Verified Decision Procedures for Modal Logics
* Gore, R. (1999). Tableau Methods for Modal and Temporal Logics
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Semantics
open FormalSystem.Metalogic

/-!
## Soundness of the Decision Procedure
-/

/--
Soundness of the decision procedure: if a formula has a `FrameClass.Base`
derivation (as produced by `decide` returning `.valid proof`), then the
formula is semantically valid.

This follows immediately from the `soundness` theorem with empty context,
where the context hypothesis is vacuously satisfied.
-/
theorem decide_sound (φ : Formula) (d : ⊢ φ) : ⊨ φ := by
  intro D _ _ _ _ F M τ h_mem t
  exact soundness [] φ d D F M τ h_mem t (by simp)

/--
Variant of `decide_sound` that extracts the proof from a `DecisionResult.valid`.
-/
theorem decide_sound' (φ : Formula) (searchDepth tableauFuel : Nat)
    (fc : FrameClass) (proof : ⊢ φ)
    (_h : decide φ searchDepth tableauFuel fc = .valid proof) : ⊨ φ :=
  decide_sound φ proof

/-!
## `validity_decidable` / `validity_has_decision_procedure` — Retired as vacuous

Two theorems used to stand here under the names above, and they are recorded as retired rather
than deleted quietly, because their *names* claimed a decidability result their *proofs* did not
contain.

`validity_decidable (φ : Formula) : (⊨ φ) ∨ ¬(⊨ φ)` was proved by `exact Classical.em (⊨ φ)`.
That is an instance of excluded middle for an arbitrary proposition; it holds of any predicate
whatsoever and says nothing about `⊨` in particular, about tableaux, or about computation. It is
in no sense a decidability statement: it produces no procedure and no `Decidable` instance.

`validity_has_decision_procedure (φ : Formula) : ∃ decision : Bool, decision = true ↔ ⊨ φ` was
proved by `by_cases h : (⊨ φ)` supplying `true` or `false` accordingly. The existential is
therefore witnessed non-constructively by the truth value one is trying to compute; it is
`Classical.em` again with a `Bool` wrapped around it. In particular it is not the statement that
`isValid` (`DecisionProcedure.lean`) is that `decision`, which is the content one would want.

**What actually holds, and is proved.** `decide_sound` (this file) is the real one-directional
fact: a `⊢ φ` derivation — the witness `decide` returns in its `.valid` constructor — yields
`⊨ φ`. On the tableau side, `ruleSound_of_mem_allRulesForFC`
(`Verified/Decidable.lean`) is the rule half of the `allClosed → valid` direction: every rule
`allRulesForFC` can schedule at a frame class preserves satisfiability under that class's carrier
property, all 34 of them, sorry-free.

**What is still owed, and is deliberately not stated here.** The replacement these names should
eventually have — `isValid φ fc = true ↔ ⊨ φ`, and the `Decidable (⊨ φ)` instances for the four
frame classes — requires `valid_iff_allClosed`, which needs the fuel/termination side and the
truth-lemma gate on top of the rule half above, and it must also account for the two rules
scheduled outside `allRulesForFC` (`serialityRule` and `timeLinearity`, stages 2 and 3 of
`expandOnce`). That obligation is open. Stating an `isValid`-shaped `iff` before it is discharged
would reproduce exactly the defect this retirement removes: a true-looking name over a proof that
does not reach it. No such statement is written here until it can be proved.
-/

/-!
## Statistics and Properties
-/

/--
Properties of the decision result.

Post-R7 this is a four-way exclusivity statement: the former `timeout` constructor was split
into `fuelExhausted` (validity genuinely undetermined) and `extractionFailed` (the tableau
closed, so the formula is valid, but no proof term was reconstructed).
-/
theorem decide_result_exclusive (φ : Formula) (searchDepth tableauFuel : Nat)
    (fc : FrameClass := .Base) :
    let r := decide φ searchDepth tableauFuel fc
    (r.isValid ∧ ¬r.isInvalid ∧ ¬r.isFuelExhausted ∧ ¬r.isExtractionFailed) ∨
    (¬r.isValid ∧ r.isInvalid ∧ ¬r.isFuelExhausted ∧ ¬r.isExtractionFailed) ∨
    (¬r.isValid ∧ ¬r.isInvalid ∧ r.isFuelExhausted ∧ ¬r.isExtractionFailed) ∨
    (¬r.isValid ∧ ¬r.isInvalid ∧ ¬r.isFuelExhausted ∧ r.isExtractionFailed) := by
  simp only [DecisionResult.isValid, DecisionResult.isInvalid,
    DecisionResult.isFuelExhausted, DecisionResult.isExtractionFailed]
  cases decide φ searchDepth tableauFuel fc <;> simp

/--
Honest reporting (R7): a closed tableau is never reported as undecided.

`isUndecided` holds only of `fuelExhausted`; in particular `extractionFailed` — the case in
which every tableau branch closed but proof-term reconstruction was incomplete — does not
count as undecided. This is the property the pre-R7 single `timeout` constructor made
unstatable.
-/
theorem not_undecided_of_extractionFailed (φ : Formula) (searchDepth tableauFuel : Nat)
    (fc : FrameClass := .Base)
    (h : (decide φ searchDepth tableauFuel fc).isExtractionFailed) :
    ¬(decide φ searchDepth tableauFuel fc).isUndecided := by
  revert h
  simp only [DecisionResult.isExtractionFailed, DecisionResult.isUndecided]
  cases decide φ searchDepth tableauFuel fc <;> simp

/--
Every `extractionFailed` result is a known-valid result: the tableau closed.
-/
theorem isKnownValid_of_extractionFailed (φ : Formula) (searchDepth tableauFuel : Nat)
    (fc : FrameClass := .Base)
    (h : (decide φ searchDepth tableauFuel fc).isExtractionFailed) :
    (decide φ searchDepth tableauFuel fc).isKnownValid := by
  revert h
  simp only [DecisionResult.isExtractionFailed, DecisionResult.isKnownValid]
  cases decide φ searchDepth tableauFuel fc <;> simp

/-!
## Completeness via FMP

The Finite Model Property provides completeness: if φ is valid,
then φ is provable. This is because:
1. If φ is not provable, then ¬φ is consistent
2. By FMP, there exists a finite model where ¬φ is true
3. Therefore φ is not valid in all models (contradiction)

Taking the contrapositive: valid → provable.
-/

/--
FMP-based completeness: If φ is true in all closure MCS,
then φ is provable from the empty context.

This is the key completeness theorem connecting semantic validity
(via MCS membership) to syntactic provability.

**Why `FrameClass.Base` is essential here**: this is a restatement of `FMP.fmp_contrapositive`,
one of the three FMP results that are theorems *about the base system*; its statement is
preserved verbatim. `ClosureMCSBundle` and `FilteredWorld` are now `fc`-parameterised with
`FrameClass.Base` as the default, so the `Base` reading of this statement is unchanged.
-/
theorem fmp_completeness (φ : Formula) :
    (∀ (S : FMP.ClosureMCSBundle φ), φ ∈ S.carrier) →
    Derivable FrameClass.Base [] φ :=
  FMP.fmp_contrapositive φ

/--
FMP-based incompleteness witness: If φ is not provable,
then there exists a finite model (closure MCS) where φ fails.

This is the contrapositive of completeness.

**Why `FrameClass.Base` is essential here**: as with `fmp_completeness`, this restates
`FMP.mcs_finite_model_property`, a preserved theorem about the base system. The finiteness of
`FilteredWorld φ` it reports is likewise the `Base` instance of the now-parameterised
world type.
-/
theorem fmp_incompleteness_witness (φ : Formula) :
    ¬Derivable FrameClass.Base [] φ →
    ∃ (S : FMP.ClosureMCSBundle φ), φ ∉ S.carrier ∧
    Finite (FMP.FilteredWorld φ) :=
  FMP.mcs_finite_model_property φ

/--
The filtered model is finite, providing a bound on countermodel size.
-/
theorem countermodel_size_bound (φ : Formula) :
    Finite (FMP.FilteredWorld φ) :=
  FMP.FilteredWorld.finite φ

end FormalSystem.Metalogic.Decidability
