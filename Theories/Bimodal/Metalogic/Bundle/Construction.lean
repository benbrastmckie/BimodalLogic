import Bimodal.Metalogic.Bundle.BMCS
import Bimodal.Metalogic.Bundle.IndexedMCSFamily
import Bimodal.Metalogic.Bundle.ModalSaturation
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.Formula

/-!
# BMCS Construction Primitives

This module provides primitive building blocks for BMCS construction:
- `ContextConsistent`: Consistency predicate for list contexts
- `contextAsSet` / `list_consistent_to_set_consistent`: Bridge from list to set consistency
- `constantIndexedMCSFamily`: A family assigning the same MCS at every time (T-axiom coherence)
- `singleFamilyBMCS`: Single-family BMCS wrapper (1 sorry in modal_backward)
- `lindenbaumMCS` / `lindenbaumMCS_set`: Lindenbaum's lemma helpers

## Design Note: Single-Family Modal Backward

The `modal_backward` condition requires: if phi is in ALL families' MCS, then Box phi
is in each family's MCS. For a single-family BMCS, this becomes: phi in MCS implies
Box phi in MCS, which is NOT valid in general modal logic.

A **modally saturated** BMCS (see `ModalSaturation.lean`) satisfies modal_backward
by construction. The `fully_saturated_bmcs_exists_int` axiom in
`TemporalCoherentConstruction.lean` provides a correct multi-family BMCS that does
not need the single-family modal backward sorry.

## History

- Task 812: Original single-family construction with FALSE `singleFamily_modal_backward_axiom`
- Task 905: Removed FALSE axiom, replaced with sorry
- Task 912: Removed dead code (`construct_bmcs`, `construct_bmcs_from_set`), kept
  `singleFamilyBMCS` because `construct_temporal_bmcs` still depends on it

## References

- Modal saturation theory: Bimodal.Metalogic.Bundle.ModalSaturation
- Active completeness chain: Bimodal.Metalogic.Bundle.TemporalCoherentConstruction
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-!
## Stage 1: Extending Context to MCS

Use Lindenbaum's lemma to extend a consistent context to a maximal consistent set.
-/

/--
Convert a list context to a set for use with set-based Lindenbaum.
-/
def contextAsSet (Gamma : List Formula) : Set Formula := {phi | phi ∈ Gamma}

/--
A list context is set-consistent if listing its elements doesn't derive bot.
This follows from list consistency plus finite subset property.
-/
lemma list_consistent_to_set_consistent {Gamma : List Formula}
    (h_cons : Consistent Gamma) :
    SetConsistent (contextAsSet Gamma) := by
  intro L hL
  intro ⟨d⟩
  apply h_cons
  -- L is a list with all elements in Gamma (as a set)
  -- Weaken derivation from L to Gamma
  exact ⟨Bimodal.ProofSystem.DerivationTree.weakening L Gamma Formula.bot d hL⟩

/-!
## Stage 2: Building IndexedMCSFamily from MCS

We create a constant IndexedMCSFamily where the same MCS is used at every time point.
This satisfies all temporal coherence conditions trivially.
-/

/--
Build a constant IndexedMCSFamily from a single MCS.

The family assigns the same MCS to every time point. All temporal coherence
conditions hold trivially because the MCS is the same at all times.

**Key Property**: For this family:
- forward_G: G phi at t and t < t' implies phi at t' - by T-axiom (G phi -> phi)
- backward_H: H phi at t and t' < t implies phi at t' - by T-axiom (H phi -> phi)
-/
noncomputable def constantIndexedMCSFamily (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    IndexedMCSFamily D where
  mcs := fun _ => M
  is_mcs := fun _ => h_mcs
  forward_G := fun t t' phi _ hG =>
    -- G phi in M and t < t' - need phi in M
    -- Use T-axiom: G phi -> phi
    let h_T := Bimodal.ProofSystem.DerivationTree.axiom []
      (phi.all_future.imp phi) (Bimodal.ProofSystem.Axiom.temp_t_future phi)
    let h_T_in_M := theorem_in_mcs h_mcs h_T
    set_mcs_implication_property h_mcs h_T_in_M hG
  backward_H := fun t t' phi _ hH =>
    -- H phi in M and t' < t - need phi in M
    -- Use T-axiom: H phi -> phi
    let h_T := Bimodal.ProofSystem.DerivationTree.axiom []
      (phi.all_past.imp phi) (Bimodal.ProofSystem.Axiom.temp_t_past phi)
    let h_T_in_M := theorem_in_mcs h_mcs h_T
    set_mcs_implication_property h_mcs h_T_in_M hH

/--
The MCS at any time in a constant family is the original MCS.
-/
lemma constantIndexedMCSFamily_mcs_eq (M : Set Formula) (h_mcs : SetMaximalConsistent M) (t : D) :
    (constantIndexedMCSFamily M h_mcs (D := D)).mcs t = M := rfl

/-!
## Stage 3: Constructing BMCS

Build a BMCS with a single family. Modal coherence conditions become:
- modal_forward: Box phi in M implies phi in M (T-axiom)
- modal_backward: phi in M implies Box phi in M (only if phi in ALL families, but we have one)

For a single-family BMCS:
- modal_forward is just the T-axiom
- modal_backward requires: if phi in M (the only family), then Box phi in M
  This does NOT generally hold! We need to prove this specially.

**Key Insight**: For modal_backward to work with one family, we use MCS maximality:
If phi is in M and Box phi is not in M, then by maximality neg (Box phi) is in M.
But neg (Box phi) = Diamond (neg phi), which should imply neg phi is consistent with M.
However, if neg phi is in M then we get phi and neg phi both in M, contradiction.

Actually, the modal_backward condition is:
  forall fam in families, forall phi t, (forall fam' in families, phi in fam'.mcs t) -> Box phi in fam.mcs t

With ONE family, this becomes: phi in M -> Box phi in M

This is NOT a theorem in general modal logic! In S5 we have Box phi <-> phi for necessary
truths, but not for arbitrary phi.

**Resolution**: We strengthen the construction requirement. For completeness, we need
a BMCS where the original context Gamma is preserved. The modal_backward condition
is PART OF THE CONSTRUCTION SPECIFICATION, not something we prove from first principles.

For single-family BMCS, we accept modal_backward via an axiom (justified by canonical model theory).
This is acceptable because:
1. The TRUTH LEMMA is the critical result, and it uses modal_forward/backward as hypotheses
2. A proper multi-family construction would satisfy these automatically
3. Single-family is a simplification for the existence proof
-/

-- ============================================================================
-- NOTE: singleFamily_modal_backward_axiom has been REMOVED (task 905)
-- ============================================================================

/-!
### singleFamily_modal_backward_axiom (REMOVED)

The FALSE axiom `singleFamily_modal_backward_axiom` was removed in task 905.
It claimed: phi in fam.mcs t -> Box phi in fam.mcs t, which is FALSE for
non-necessary formulas.

**REPLACEMENT**: Use `fully_saturated_bmcs_exists` from `TemporalCoherentConstruction.lean`
instead, which asserts the existence of a modally saturated BMCS.

See task 903 for the completeness proof restructuring that eliminates the need
for single-family modal backward entirely.
-/

/--
Build a BMCS from a single IndexedMCSFamily.

**DEPRECATED**: The `modal_backward` field uses sorry because the single-family
approach cannot prove modal backward from first principles. Use
`construct_temporal_bmcs` from `TemporalCoherentConstruction.lean` for new code,
which uses the correct `fully_saturated_bmcs_exists` axiom instead.
-/
noncomputable def singleFamilyBMCS (fam : IndexedMCSFamily D) : BMCS D where
  families := {fam}
  nonempty := ⟨fam, Set.mem_singleton fam⟩
  modal_forward := fun fam' hfam' phi t hBox fam'' hfam'' =>
    -- fam' and fam'' are both in {fam}, so both equal fam
    have h_eq' : fam' = fam := Set.mem_singleton_iff.mp hfam'
    have h_eq'' : fam'' = fam := Set.mem_singleton_iff.mp hfam''
    -- Need: phi in fam''.mcs t = phi in fam.mcs t
    -- Have: Box phi in fam'.mcs t = Box phi in fam.mcs t
    -- Use T-axiom: Box phi -> phi
    let h_mcs := fam.is_mcs t
    let h_T := Bimodal.ProofSystem.DerivationTree.axiom []
      ((Formula.box phi).imp phi) (Bimodal.ProofSystem.Axiom.modal_t phi)
    let h_T_in_mcs := theorem_in_mcs h_mcs h_T
    h_eq'' ▸ set_mcs_implication_property h_mcs h_T_in_mcs (h_eq' ▸ hBox)
  modal_backward := fun _fam' _hfam' _phi _t _h_all =>
    -- SORRY: Single-family modal backward is not provable from first principles.
    -- The FALSE axiom singleFamily_modal_backward_axiom was removed in task 905.
    -- Use fully_saturated_bmcs_exists from TemporalCoherentConstruction.lean instead.
    sorry
  eval_family := fam
  eval_family_mem := Set.mem_singleton fam

/--
The evaluation family of a single-family BMCS is the original family.
-/
lemma singleFamilyBMCS_eval_family_eq (fam : IndexedMCSFamily D) :
    (singleFamilyBMCS fam (D := D)).eval_family = fam := rfl

/-!
## Core Definitions

These definitions are used by the active completeness chain.
-/

/--
A context is consistent if no derivation of bot exists.
-/
def ContextConsistent (Gamma : List Formula) : Prop :=
  ¬Nonempty (Bimodal.ProofSystem.DerivationTree Gamma Formula.bot)

/--
Helper: Extract MCS from Lindenbaum result for a list context.

Given a consistent context Gamma, returns the MCS that extends it.
-/
noncomputable def lindenbaumMCS (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    Set Formula :=
  let h_set_cons : SetConsistent (contextAsSet Gamma) := list_consistent_to_set_consistent h_cons
  Classical.choose (set_lindenbaum (contextAsSet Gamma) h_set_cons)

/--
The Lindenbaum MCS contains the original context.
-/
lemma lindenbaumMCS_extends (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    contextAsSet Gamma ⊆ lindenbaumMCS Gamma h_cons :=
  let h_set_cons : SetConsistent (contextAsSet Gamma) := list_consistent_to_set_consistent h_cons
  (Classical.choose_spec (set_lindenbaum (contextAsSet Gamma) h_set_cons)).1

/--
The Lindenbaum MCS is maximal consistent.
-/
lemma lindenbaumMCS_is_mcs (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    SetMaximalConsistent (lindenbaumMCS Gamma h_cons) :=
  let h_set_cons : SetConsistent (contextAsSet Gamma) := list_consistent_to_set_consistent h_cons
  (Classical.choose_spec (set_lindenbaum (contextAsSet Gamma) h_set_cons)).2

/--
Helper: Extract MCS from Lindenbaum result for a set.
-/
noncomputable def lindenbaumMCS_set (S : Set Formula) (h_cons : SetConsistent S) :
    Set Formula :=
  Classical.choose (set_lindenbaum S h_cons)

/--
The Lindenbaum MCS (set version) contains the original set.
-/
lemma lindenbaumMCS_set_extends (S : Set Formula) (h_cons : SetConsistent S) :
    S ⊆ lindenbaumMCS_set S h_cons :=
  (Classical.choose_spec (set_lindenbaum S h_cons)).1

/--
The Lindenbaum MCS (set version) is maximal consistent.
-/
lemma lindenbaumMCS_set_is_mcs (S : Set Formula) (h_cons : SetConsistent S) :
    SetMaximalConsistent (lindenbaumMCS_set S h_cons) :=
  (Classical.choose_spec (set_lindenbaum S h_cons)).2

/-!
## Summary

This module provides:
- `ContextConsistent`: Consistency predicate for list contexts
- `contextAsSet`, `list_consistent_to_set_consistent`: Set-based consistency bridge
- `constantIndexedMCSFamily`: Constant-time MCS family (temporal coherence via T-axioms)
- `singleFamilyBMCS`: Single-family BMCS construction (1 sorry in modal_backward)
- `lindenbaumMCS` / `lindenbaumMCS_set`: Lindenbaum's lemma helpers

**Sorry Status**: ONE sorry (`modal_backward` in `singleFamilyBMCS`).
Single-family modal backward (phi in MCS -> Box phi in MCS) is not provable from
first principles. This sorry is inherited by `construct_temporal_bmcs` in
`TemporalCoherentConstruction.lean`. The `fully_saturated_bmcs_exists_int` axiom
provides a correct alternative that replaces this sorry for the completeness chain.

**Deprecation Note (tasks 905, 912)**:
The `construct_bmcs` and `construct_bmcs_from_set` functions were removed in task 912
as they are superseded by `construct_saturated_bmcs_int` from
`TemporalCoherentConstruction.lean`. The `singleFamilyBMCS` definition is retained
because `construct_temporal_bmcs` still depends on it.
-/

end Bimodal.Metalogic.Bundle
