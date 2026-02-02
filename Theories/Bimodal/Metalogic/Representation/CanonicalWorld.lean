import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Syntax.Formula
import Mathlib.Algebra.Order.Group.Defs

/-!
# Canonical World Structure for Universal Parametric Canonical Model

This module defines the `CanonicalWorld` structure that pairs maximal consistent sets
with abstract time points from a totally ordered additive commutative group D.

## Overview

The key insight of the universal parametric approach is that we don't need to
extract the time type D from syntax. Instead, we construct canonical worlds
that work for ANY D by pairing:
1. A maximal consistent set (MCS) of formulas
2. An abstract time point from D

This allows the canonical model to be parametric over any temporal structure.

## Main Definitions

- `CanonicalWorld D`: Structure pairing MCS with time point from D
- Basic projections and accessors
- MCS property inheritance lemmas

## References

- Research report: specs/654_.../reports/research-003.md
- Implementation plan: specs/654_.../plans/implementation-003.md
-/

namespace Bimodal.Metalogic.Representation

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Core

/-!
## Canonical World Structure
-/

/--
A canonical world pairs a maximal consistent set with an abstract time point.

**Type Parameters**:
- `D`: Duration/time type with ordered additive group structure

**Fields**:
- `mcs`: The maximal consistent set of formulas representing the world's truths
- `time`: The time point in the abstract ordered group D
- `is_mcs`: Proof that the formula set is indeed maximal consistent

**Key Properties**:
- The MCS determines which formulas are "true" at this world
- The time point positions the world temporally
- The construction is parametric over D, not committed to any concrete time type
-/
structure CanonicalWorld (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  /-- The maximal consistent set of formulas -/
  mcs : Set Formula
  /-- Time point in the abstract ordered group -/
  time : D
  /-- Proof that the formula set is maximal consistent -/
  is_mcs : SetMaximalConsistent mcs

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-!
## Basic Accessors and Projections
-/

/-- The formula set of a canonical world is consistent. -/
lemma CanonicalWorld.consistent (w : CanonicalWorld D) : SetConsistent w.mcs :=
  w.is_mcs.1

/-- The formula set of a canonical world is maximal (cannot be consistently extended). -/
lemma CanonicalWorld.maximal (w : CanonicalWorld D) :
    ∀ φ : Formula, φ ∉ w.mcs → ¬SetConsistent (insert φ w.mcs) :=
  w.is_mcs.2

/-!
## MCS Property Inheritance

These lemmas expose the key MCS properties that will be used in the
truth lemma and task relation proofs.
-/

/--
Canonical worlds are negation complete: for any formula φ, either φ ∈ mcs or ¬φ ∈ mcs.

This is a crucial property for the truth lemma: if φ is not in the MCS,
then its negation must be.
-/
lemma CanonicalWorld.neg_complete (w : CanonicalWorld D) (φ : Formula) :
    φ ∈ w.mcs ∨ Formula.neg φ ∈ w.mcs := by
  by_cases h : φ ∈ w.mcs
  · left; exact h
  · right
    -- Use the MCS theory: if φ ∉ w.mcs, then insert φ is inconsistent
    have h_incons : ¬SetConsistent (insert φ w.mcs) := w.maximal φ h
    -- Need to derive ¬φ ∈ w.mcs from this
    -- This requires showing that the deduction theorem argument works for sets
    -- For now, use a classical argument
    by_contra h_neg_not_in
    -- If neither φ nor ¬φ is in w.mcs, we have a contradiction with MCS maximality
    -- Actually, we need a more direct argument
    -- From h_incons, we know adding φ is inconsistent
    -- From h_neg_not_in, we could add ¬φ, but by maximality that should also be inconsistent
    have h_neg_incons : ¬SetConsistent (insert (Formula.neg φ) w.mcs) := w.maximal (Formula.neg φ) h_neg_not_in
    -- But this contradicts the fact that one of them must be addable to a consistent set
    -- Actually this argument is getting circular. Let's use a different approach.
    -- We use the fact that MCS + deduction theorem gives us negation completeness
    -- This is already proven in the Boneyard MCS theory for list-based MCS
    -- For set-based, we need to adapt the proof
    sorry -- TODO: Complete this proof using set-based MCS properties

/--
Canonical worlds are deductively closed for finite derivations.

If a finite list L ⊆ mcs derives φ, then φ ∈ mcs.
-/
lemma CanonicalWorld.deductively_closed (w : CanonicalWorld D) (L : List Formula)
    (hL : ∀ ψ ∈ L, ψ ∈ w.mcs) (φ : Formula) (h_deriv : Bimodal.ProofSystem.DerivationTree L φ) :
    φ ∈ w.mcs := by
  -- By contradiction: assume φ ∉ w.mcs
  by_contra h_not_in
  -- By maximality, insert φ w.mcs is inconsistent
  have h_incons : ¬SetConsistent (insert φ w.mcs) := w.maximal φ h_not_in
  -- So there exists some finite M ⊆ insert φ w.mcs that derives ⊥
  unfold SetConsistent at h_incons
  push_neg at h_incons
  obtain ⟨M, hM_sub, hM_incons⟩ := h_incons
  -- Filter out φ from M to get M' ⊆ w.mcs
  let M' := M.filter (· ≠ φ)
  have hM'_sub : ∀ ψ ∈ M', ψ ∈ w.mcs := by
    intro ψ hψ
    have hψ' := List.mem_filter.mp hψ
    have hψM := hψ'.1
    have hψne : ψ ≠ φ := by simpa using hψ'.2
    have := hM_sub ψ hψM
    simp [Set.mem_insert_iff] at this
    rcases this with rfl | h
    · exact absurd rfl hψne
    · exact h
  -- M ⊆ φ :: M', so we can weaken the derivation of ⊥
  have hM_sub' : M ⊆ φ :: M' := by
    intro ψ hψ
    by_cases hψφ : ψ = φ
    · simp [hψφ]
    · simp only [List.mem_cons]
      right
      exact List.mem_filter.mpr ⟨hψ, by simpa⟩
  -- Get derivation of ⊥ from M
  have ⟨d_bot⟩ := inconsistent_derives_bot hM_incons
  -- Weaken to φ :: M'
  have d_bot' := Bimodal.ProofSystem.DerivationTree.weakening M (φ :: M') Formula.bot d_bot hM_sub'
  -- By deduction theorem, M' ⊢ ¬φ
  have d_neg := Bimodal.Metalogic.Core.deduction_theorem M' φ Formula.bot d_bot'
  -- Weaken L ⊢ φ to M' ⊢ φ (if L ⊆ M')
  -- Actually we need L ⊆ M' or similar, which may not hold directly
  -- The proof is more subtle - we need to combine the derivations properly
  sorry -- TODO: Complete using proper derivation combination

/--
Theorems (formulas derivable from empty context) are in every canonical world.
-/
lemma CanonicalWorld.theorem_mem (w : CanonicalWorld D) (φ : Formula)
    (h_deriv : Bimodal.ProofSystem.DerivationTree [] φ) : φ ∈ w.mcs :=
  theorem_in_mcs w.is_mcs h_deriv

/-!
## Formula Membership Lemmas

These lemmas characterize membership for compound formulas.
-/

/--
If φ → ψ ∈ mcs and φ ∈ mcs, then ψ ∈ mcs (modus ponens closure).
-/
lemma CanonicalWorld.modus_ponens_closure (w : CanonicalWorld D)
    (φ ψ : Formula) (h_imp : Formula.imp φ ψ ∈ w.mcs) (h_φ : φ ∈ w.mcs) :
    ψ ∈ w.mcs := by
  -- Build a derivation of ψ from [φ → ψ, φ]
  have d_imp : Bimodal.ProofSystem.DerivationTree [Formula.imp φ ψ, φ] (Formula.imp φ ψ) :=
    Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
  have d_φ : Bimodal.ProofSystem.DerivationTree [Formula.imp φ ψ, φ] φ :=
    Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
  have d_ψ : Bimodal.ProofSystem.DerivationTree [Formula.imp φ ψ, φ] ψ :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ d_imp d_φ
  -- Apply deductive closure
  apply w.deductively_closed [Formula.imp φ ψ, φ]
  · intro χ hχ
    simp at hχ
    rcases hχ with rfl | rfl
    · exact h_imp
    · exact h_φ
  · exact d_ψ

/-!
## World Equality

Two canonical worlds are equal if they have the same MCS and time.
-/

/--
Canonical world equality extensionality.
-/
theorem CanonicalWorld.ext {w v : CanonicalWorld D}
    (h_mcs : w.mcs = v.mcs) (h_time : w.time = v.time) : w = v := by
  cases w
  cases v
  simp only at h_mcs h_time
  subst h_mcs h_time
  rfl

/-!
## Constructor from Lindenbaum Extension

Given a consistent set and a time point, we can construct a canonical world
by extending the set to an MCS via Lindenbaum's lemma.
-/

/--
Helper: Extract an MCS extending a consistent set (using choice).
-/
noncomputable def extendToMCS (S : Set Formula) (hS : SetConsistent S) : Set Formula :=
  Classical.choose (set_lindenbaum S hS)

/--
Helper: The extended MCS contains S.
-/
lemma extendToMCS_contains (S : Set Formula) (hS : SetConsistent S) :
    S ⊆ extendToMCS S hS :=
  (Classical.choose_spec (set_lindenbaum S hS)).1

/--
Helper: The extended set is maximal consistent.
-/
lemma extendToMCS_is_mcs (S : Set Formula) (hS : SetConsistent S) :
    SetMaximalConsistent (extendToMCS S hS) :=
  (Classical.choose_spec (set_lindenbaum S hS)).2

/--
Construct a canonical world from a consistent set by extending to MCS.

This is noncomputable because Lindenbaum's lemma uses Zorn's lemma (choice).
-/
noncomputable def CanonicalWorld.fromConsistent
    (S : Set Formula) (hS : SetConsistent S) (t : D) : CanonicalWorld D :=
  { mcs := extendToMCS S hS
    time := t
    is_mcs := extendToMCS_is_mcs S hS }

/--
The constructed canonical world contains the original consistent set.
-/
lemma CanonicalWorld.fromConsistent_contains
    (S : Set Formula) (hS : SetConsistent S) (t : D) (φ : Formula) (hφ : φ ∈ S) :
    φ ∈ (CanonicalWorld.fromConsistent S hS t).mcs :=
  extendToMCS_contains S hS hφ

end Bimodal.Metalogic.Representation
