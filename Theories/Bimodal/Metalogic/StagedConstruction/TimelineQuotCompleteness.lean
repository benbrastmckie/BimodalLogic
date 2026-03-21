import Bimodal.Metalogic.StagedConstruction.TimelineQuotAlgebra
import Bimodal.Metalogic.StagedConstruction.DovetailedTimelineQuot
import Bimodal.Metalogic.Algebraic.DenseInstantiation
import Bimodal.Metalogic.Bundle.CanonicalConstruction
import Bimodal.Metalogic.Bundle.CanonicalFMCS
import Bimodal.FrameConditions.Validity

/-!
# Dense Completeness Wiring via DovetailedTimelineQuot

This module provides the final wiring for dense completeness using DovetailedTimelineQuot.

## Overview

The dense completeness theorem states:
```
∀ φ, (∀ D [dense constraints], valid_over D φ) → Nonempty ([] ⊢ φ)
```

The proof strategy (contrapositive):
1. If φ is not provable, then [φ.neg] is consistent
2. Extend to MCS M₀ via Lindenbaum
3. Build DovetailedTimelineQuot from M₀
4. DovetailedTimelineQuot satisfies all dense constraints
5. Show φ is NOT valid over DovetailedTimelineQuot (via truth lemma)
6. Contradiction with hypothesis

## Key Results (Task 31)

- `dovetailedTimelineQuot_not_valid_of_neg_consistent`: If [φ.neg] is consistent, then φ is
  not valid over the DovetailedTimelineQuot constructed from that MCS
- `dense_completeness_theorem`: Dense completeness using DovetailedTimelineQuot

## Architecture

Uses the parametric truth lemma infrastructure from DenseInstantiation.lean:
- `construct_bfmcs_from_mcs_Dense`: Builds BFMCS from MCS
- `dense_representation_from_neg_membership`: Connects MCS membership to semantic falsity

## References

- Task 30: Build temporally coherent dense BFMCS
- Task 31: Wire dense truth lemma instantiation
- DenseInstantiation.lean: D = DovetailedTimelineQuot instantiation
- DovetailedTimelineQuotBFMCS.lean: BFMCS construction
-/

namespace Bimodal.Metalogic.StagedConstruction.TimelineQuotCompleteness

open Bimodal.Syntax
open Bimodal.Semantics
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Bundle.Canonical
open Bimodal.Metalogic.Algebraic.DenseInstantiation
open Bimodal.Metalogic.Algebraic.ParametricCanonical
open Bimodal.Metalogic.Algebraic.ParametricHistory
open Bimodal.Metalogic.Algebraic.ParametricTruthLemma
open Bimodal.Metalogic.StagedConstruction.DovetailedTimelineQuot
open Bimodal.Metalogic.StagedConstruction.DovetailedFMCS
open Bimodal.Metalogic.StagedConstruction.DovetailedTimelineQuotBFMCS
open Bimodal.FrameConditions

-- Make the typeclass instances available locally
attribute [local instance] dovetailedTimelineQuotAddCommGroup dovetailedTimelineQuotIsOrderedAddMonoid

/-!
## MCS Extraction from DovetailedTimelineQuot

DovetailedTimelineQuot elements are equivalence classes of DovetailedTimelineElem.
Each DovetailedTimelineElem is a DovetailedPoint with an MCS.
We can extract an MCS via dovetailedTimelineQuotMCS.
-/

-- Re-export dovetailedTimelineQuotMCS from DovetailedTimelineQuot
#check dovetailedTimelineQuotMCS

/-!
## Dense Satisfiability Key Lemma

The key lemma connecting consistency to non-validity over DovetailedTimelineQuot.
This is now PROVEN using the parametric truth lemma infrastructure.
-/

/--
**Key Lemma**: If [φ.neg] is consistent, then φ is NOT valid over DovetailedTimelineQuot.

This is the central lemma needed for dense completeness. It states that
when we construct DovetailedTimelineQuot from an MCS containing φ.neg, we can build
a countermodel showing φ is not valid over that DovetailedTimelineQuot.

**Proof Strategy** (Task 31):
1. Get M₀ = lindenbaumMCS [φ.neg] h_cons (contains φ.neg)
2. Build DovetailedTimelineQuot from M₀
3. Use construct_bfmcs_from_mcs_Dense to get BFMCS + temporal coherence
4. Use dense_representation_from_neg_membership to show φ is false
5. Package as ¬valid_over witness

**Status**: COMPLETED (Task 31) - uses DenseInstantiation infrastructure
-/
theorem dovetailedTimelineQuot_not_valid_of_neg_consistent
    (φ : Formula) (h_cons : ContextConsistent [φ.neg]) :
    let M₀ := lindenbaumMCS [φ.neg] h_cons
    let h_M₀_mcs := lindenbaumMCS_is_mcs [φ.neg] h_cons
    let D := DovetailedTimelineQuot M₀ h_M₀_mcs
    ¬valid_over D φ := by
  intro M₀ h_M₀_mcs D
  -- Need to show: ∃ F M Omega τ h_sc h_mem t, ¬truth_at M Omega τ t φ
  -- This uses the DenseInstantiation infrastructure

  -- φ.neg is in M₀ by Lindenbaum construction
  have h_neg_in : φ.neg ∈ M₀ := by
    have h_extends := lindenbaumMCS_extends [φ.neg] h_cons
    apply h_extends
    -- Show φ.neg ∈ contextAsSet [φ.neg]
    simp only [contextAsSet, List.mem_singleton, Set.mem_setOf_eq]

  -- Build the BFMCS and get the countermodel
  let result := construct_bfmcs_from_mcs_Dense M₀ h_M₀_mcs
  let B := result.1
  let h_tc := result.2.1
  let fam := result.2.2.1
  let hfam := result.2.2.2.1
  let t := result.2.2.2.2.1
  let h_eq := result.2.2.2.2.2

  -- φ.neg ∈ fam.mcs t
  have h_neg_in_fam : φ.neg ∈ fam.mcs t := h_eq ▸ h_neg_in

  -- By the representation theorem, φ is false at this point
  have h_false := dense_representation_from_neg_membership M₀ h_M₀_mcs B h_tc φ fam hfam t h_neg_in_fam

  -- Package as ¬valid_over witness
  -- valid_over D φ means: for all F M Omega τ (shift_closed, mem), for all t, truth_at
  -- So ¬valid_over means: exists F M Omega τ t such that ¬truth_at
  intro h_valid
  -- h_valid : valid_over D φ
  -- This means for all TaskFrame/TaskModel/Omega/τ/t, truth_at holds
  -- But we have a counterexample via h_false
  -- Need to exhibit the countermodel in valid_over's format
  unfold valid_over at h_valid

  -- The canonical frame and model
  let F := ParametricCanonicalTaskFrame D
  let Mod := ParametricCanonicalTaskModel D
  let Omega := ShiftClosedParametricCanonicalOmega B
  let τ := parametric_to_history fam

  -- Show τ ∈ Omega
  -- ShiftClosedParametricCanonicalOmega B = { σ | ∃ fam ∈ B.families, ∃ delta, σ = time_shift (parametric_to_history fam) delta }
  -- τ = parametric_to_history fam, and time_shift ... 0 = identity
  have h_mem : τ ∈ Omega := parametricCanonicalOmega_subset_shiftClosed B ⟨fam, hfam, rfl⟩

  -- Show Omega is shift-closed
  have h_sc : ShiftClosed Omega := shiftClosedParametricCanonicalOmega_is_shift_closed B

  -- Apply h_valid to get truth_at
  have h_true := h_valid F Mod Omega h_sc τ h_mem t

  -- But h_false says ¬truth_at
  exact h_false h_true

/-!
## Dense Completeness Theorem (Main Result)

The dense completeness theorem using DovetailedTimelineQuot as the witness domain.
-/

/--
**Dense Completeness Theorem**

If a formula φ is valid over all dense temporal domains, then φ is provable.

This is the main completeness result for dense temporal logic.

**Proof Structure**:
1. Use classical logic (by_contra)
2. If φ not provable, then [φ.neg] is consistent
3. Build DovetailedTimelineQuot from the Lindenbaum MCS
4. DovetailedTimelineQuot satisfies all dense constraints
5. By hypothesis, φ is valid over DovetailedTimelineQuot
6. By dovetailedTimelineQuot_not_valid_of_neg_consistent, φ is NOT valid over DovetailedTimelineQuot
7. Contradiction

**Status**: COMPLETED (Task 31)
-/
theorem dense_completeness_theorem {φ : Formula} :
    (∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
       [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [DenselyOrdered D]
       [DenseTemporalFrame D], valid_over D φ) →
    Nonempty ([] ⊢ φ) := by
  intro h_valid
  -- Use classical logic
  by_contra h_not_provable
  -- Step 1: [φ.neg] is consistent
  have h_cons : ContextConsistent [φ.neg] := not_derivable_implies_neg_consistent φ h_not_provable

  -- Step 2: Build DovetailedTimelineQuot from Lindenbaum MCS
  let M₀ := lindenbaumMCS [φ.neg] h_cons
  let h_M₀_mcs := lindenbaumMCS_is_mcs [φ.neg] h_cons

  -- Step 3: Define D = DovetailedTimelineQuot M₀ and provide instances
  let D := DovetailedTimelineQuot M₀ h_M₀_mcs
  letI : DenseTemporalFrame D := {}

  -- Step 4: Instantiate h_valid at D
  have h_valid_D : valid_over D φ := h_valid D

  -- Step 5: But φ is NOT valid over D (by dovetailedTimelineQuot_not_valid_of_neg_consistent)
  have h_not_valid : ¬valid_over D φ := dovetailedTimelineQuot_not_valid_of_neg_consistent φ h_cons

  -- Step 6: Contradiction
  exact h_not_valid h_valid_D

end Bimodal.Metalogic.StagedConstruction.TimelineQuotCompleteness
