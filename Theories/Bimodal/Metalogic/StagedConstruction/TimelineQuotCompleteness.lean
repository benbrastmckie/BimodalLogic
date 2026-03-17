import Bimodal.Metalogic.StagedConstruction.TimelineQuotAlgebra
import Bimodal.Metalogic.Bundle.CanonicalConstruction
import Bimodal.Metalogic.Bundle.CanonicalFMCS
import Bimodal.FrameConditions.Validity

/-!
# TimelineQuot Completeness Wiring

This module provides the final wiring for dense completeness using TimelineQuot.

## Overview

The dense completeness theorem states:
```
∀ φ, (∀ D [dense constraints], valid_over D φ) → Nonempty ([] ⊢ φ)
```

The proof strategy (contrapositive):
1. If φ is not provable, then [φ.neg] is consistent
2. Extend to MCS M₀ via Lindenbaum
3. Build TimelineQuot from M₀
4. TimelineQuot satisfies all dense constraints
5. Show φ is NOT valid over TimelineQuot (via truth lemma-like argument)
6. Contradiction with hypothesis

## Key Result

- `timelineQuot_not_valid_of_neg_consistent`: If [φ.neg] is consistent, then φ is not valid
  over the TimelineQuot constructed from that MCS

## Architecture Gap

The existing truth lemma infrastructure is for `D = Int`. For TimelineQuot-based
completeness, we need either:
1. A truth lemma over TimelineQuot (requires significant infrastructure)
2. A satisfiability transfer theorem (TimelineQuot ≃o Rat ≃o Int quotients)
3. A direct semantic argument using MCS membership

This module documents the gap and provides the connection infrastructure.

## References

- Task 982: Wire dense completeness domain connection
- TimelineQuotAlgebra.lean: TimelineQuot algebraic instances
- CantorApplication.lean: TimelineQuot ≃o Q
-/

namespace Bimodal.Metalogic.StagedConstruction.TimelineQuotCompleteness

open Bimodal.Syntax
open Bimodal.Semantics
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Bundle.Canonical
open Bimodal.FrameConditions

/-!
## MCS Extraction from TimelineQuot

TimelineQuot elements are equivalence classes of DenseTimelineElem.
Each DenseTimelineElem is a StagedPoint with an MCS.
We can extract an MCS from a TimelineQuot element via ofAntisymmetrization.
-/

/--
Extract an MCS from a TimelineQuot element.

Uses `ofAntisymmetrization` to get a representative from the equivalence class,
then extracts the StagedPoint's MCS.
-/
noncomputable def timelineQuotMCS
    (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)
    (t : TimelineQuot root_mcs root_mcs_proof) : Set Formula :=
  (ofAntisymmetrization (· ≤ ·) t).1.mcs

/--
The extracted MCS is maximal consistent.
-/
theorem timelineQuotMCS_is_mcs
    (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)
    (t : TimelineQuot root_mcs root_mcs_proof) :
    SetMaximalConsistent (timelineQuotMCS root_mcs root_mcs_proof t) :=
  (ofAntisymmetrization (· ≤ ·) t).1.is_mcs

/-!
## Dense Satisfiability Key Lemma

The key lemma connecting consistency to non-validity over TimelineQuot.
-/

/--
**Key Gap Lemma**: If [φ.neg] is consistent, then φ is NOT valid over TimelineQuot.

This is the central lemma needed for dense completeness. It states that
when we construct TimelineQuot from an MCS containing φ.neg, we can build
a countermodel showing φ is not valid over that TimelineQuot.

**Proof Status**: SORRY - requires truth lemma infrastructure over TimelineQuot

**Resolution Path**:
The proof requires constructing:
1. A TaskFrame over TimelineQuot (can use denseCanonicalTaskFrame from Domain/)
2. A TaskModel with valuation reflecting MCS membership
3. An Omega set (shift-closed) containing a witness history
4. A history τ and time t where φ evaluates to false

The existing Int-based infrastructure (canonical_truth_lemma, shifted_truth_lemma)
provides the template. Adapting it to TimelineQuot requires either:
- Building FMCS/BFMCS indexed by TimelineQuot directly, or
- Proving a transfer theorem that maps Int models to TimelineQuot models

**Mathematical Content**: The lemma is TRUE - it follows from standard completeness
arguments. The gap is purely in the Lean mechanization.
-/
theorem timelineQuot_not_valid_of_neg_consistent
    (φ : Formula) (h_cons : ContextConsistent [φ.neg]) :
    let M₀ := lindenbaumMCS [φ.neg] h_cons
    let h_M₀_mcs := lindenbaumMCS_is_mcs [φ.neg] h_cons
    let D := TimelineQuot M₀ h_M₀_mcs
    let acg := timelineQuotAddCommGroup M₀ h_M₀_mcs
    let oam := timelineQuotIsOrderedAddMonoid M₀ h_M₀_mcs
    ¬@valid_over D acg inferInstance oam φ := by
  intro M₀ h_M₀_mcs D acg oam
  -- Need to show: ∃ F M Omega τ h_sc h_mem t, ¬truth_at M Omega τ t φ
  -- This requires the truth lemma infrastructure
  sorry

/-!
## Dense Completeness Theorem (Main Result)

The dense completeness theorem using TimelineQuot as the witness domain.
-/

/--
**Dense Completeness Theorem**

If a formula φ is valid over all dense temporal domains, then φ is provable.

This is the main completeness result for dense temporal logic.

**Proof Structure**:
1. Use classical logic (by_contra)
2. If φ not provable, then [φ.neg] is consistent
3. Build TimelineQuot from the Lindenbaum MCS
4. TimelineQuot satisfies all dense constraints
5. By hypothesis, φ is valid over TimelineQuot
6. By timelineQuot_not_valid_of_neg_consistent, φ is NOT valid over TimelineQuot
7. Contradiction
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

  -- Step 2: Build TimelineQuot from Lindenbaum MCS
  let M₀ := lindenbaumMCS [φ.neg] h_cons
  let h_M₀_mcs := lindenbaumMCS_is_mcs [φ.neg] h_cons

  -- Step 3: Define D = TimelineQuot M₀ and provide instances
  let D := TimelineQuot M₀ h_M₀_mcs
  letI acg : AddCommGroup D := timelineQuotAddCommGroup M₀ h_M₀_mcs
  letI oam : IsOrderedAddMonoid D := timelineQuotIsOrderedAddMonoid M₀ h_M₀_mcs
  letI : DenseTemporalFrame D := {}

  -- Step 4: Instantiate h_valid at D
  have h_valid_D : valid_over D φ := h_valid D

  -- Step 5: But φ is NOT valid over D (by timelineQuot_not_valid_of_neg_consistent)
  have h_not_valid : ¬valid_over D φ := by
    -- Need to use timelineQuot_not_valid_of_neg_consistent
    -- The issue is that the instances need to match exactly
    have key := timelineQuot_not_valid_of_neg_consistent φ h_cons
    simp only at key
    convert key

  -- Step 6: Contradiction
  exact h_not_valid h_valid_D

end Bimodal.Metalogic.StagedConstruction.TimelineQuotCompleteness
