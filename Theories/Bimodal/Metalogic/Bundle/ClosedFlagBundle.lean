import Bimodal.Metalogic.Bundle.WitnessFamilyBundle
import Mathlib.Order.Zorn

/-!
# Closed Flag Bundle Construction (Task 1003 Phase 2)

This module implements the closure construction for multi-flag BFMCS bundles.
The key idea is to start with an initial set of Flags and iteratively add
Flags containing witnesses for all Diamond obligations.

## Overview

A **closed set of Flags** is one where every Diamond obligation in any Flag
has its witness contained in some Flag in the set. This ensures modal saturation
when we construct the BFMCS from these Flags.

## Main Definitions

- `initialFlags`: Set of Flags containing a given root MCS
- `addWitnessFlags`: One-step closure adding witness-containing Flags
- `ClosedFlagSet`: Predicate for witness-closed sets of Flags
- `closedFlags`: The minimal closed set of Flags containing the initial Flags

## Key Property

For every Diamond(psi) in any MCS in any Flag in `closedFlags M0`, there exists
a Flag in `closedFlags M0` containing a witness MCS with psi.

## References

- Task 1003 plan v2: specs/1003_implement_modal_coherence/plans/02_multi-family-plan.md
- WitnessFamilyBundle.lean: witness_exists_for_diamond
- ChainFMCS.lean: canonicalMCS_in_some_flag
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## Initial Flags

The initial set of Flags contains all Flags that include a given root MCS.
By Zorn's lemma (Flag.exists_mem), every MCS is in at least one Flag.
-/

/--
Initial Flags: all Flags containing a given root MCS.

This set is nonempty by `Flag.exists_mem` (Zorn's lemma application).
-/
def initialFlags (M0 : CanonicalMCS) : Set (Flag CanonicalMCS) :=
  { flag | M0 ∈ flag }

/--
The initial Flags set is nonempty.

By `Flag.exists_mem`, every element of CanonicalMCS is contained in some Flag.
-/
theorem initialFlags_nonempty (M0 : CanonicalMCS) : (initialFlags M0).Nonempty := by
  obtain ⟨flag, h_mem⟩ := Flag.exists_mem M0
  exact ⟨flag, h_mem⟩

/--
The root MCS is in any Flag from initialFlags.
-/
theorem root_in_initialFlags (M0 : CanonicalMCS) (flag : Flag CanonicalMCS)
    (h_flag : flag ∈ initialFlags M0) : M0 ∈ flag :=
  h_flag

/-!
## Witness Flag Existence

For every Diamond obligation, there exists a Flag containing the witness MCS.
-/

/--
For every Diamond(psi) in an MCS M, there exists a Flag containing a witness MCS with psi
that preserves BoxContent from M.

This combines `witness_preserves_boxcontent` (witness MCS exists with BoxContent)
with `canonicalMCS_in_some_flag` (every MCS is in some Flag).
-/
theorem witness_flag_exists (M : CanonicalMCS) (psi : Formula)
    (h_diamond : psi.diamond ∈ M.world) :
    ∃ (flag : Flag CanonicalMCS) (W : CanonicalMCS),
      W ∈ flag ∧ psi ∈ W.world ∧ MCSBoxContent M.world ⊆ W.world := by
  -- Get witness MCS with BoxContent preservation
  obtain ⟨W, h_psi, h_box⟩ := witness_preserves_boxcontent M psi h_diamond
  -- Get Flag containing W
  obtain ⟨flag, h_mem⟩ := canonicalMCS_in_some_flag W
  exact ⟨flag, W, h_mem, h_psi, h_box⟩

/-!
## Closed Flag Set Predicate

A set of Flags is "closed" if every Diamond obligation in any MCS in any Flag
has a witness in some MCS in some Flag in the set.
-/

/--
A set of Flags is closed under modal witnesses with BoxContent preservation.

For every Flag in the set, every MCS in that Flag, and every Diamond(psi) in that MCS,
there exists a Flag in the set containing an MCS W with:
- psi in W.world (the witness satisfies the formula)
- MCSBoxContent M.world ⊆ W.world (BoxContent is preserved for accessibility)
-/
def ClosedFlagSet (flags : Set (Flag CanonicalMCS)) : Prop :=
  ∀ flag ∈ flags, ∀ M : CanonicalMCS, M ∈ flag →
    ∀ psi : Formula, psi.diamond ∈ M.world →
      ∃ flag' ∈ flags, ∃ W : CanonicalMCS, W ∈ flag' ∧ psi ∈ W.world ∧
        MCSBoxContent M.world ⊆ W.world

/--
The set of all Flags is closed (trivially, by witness_flag_exists).
-/
theorem allFlags_closed : ClosedFlagSet Set.univ := by
  intro flag _ M _ psi h_diamond
  obtain ⟨flag', W, h_mem, h_psi, h_box⟩ := witness_flag_exists M psi h_diamond
  exact ⟨flag', Set.mem_univ flag', W, h_mem, h_psi, h_box⟩

/-!
## One-Step Closure Operator

Add Flags containing witnesses for all current Diamond obligations.
-/

/--
One-step closure: add all Flags containing witnesses for Diamond obligations.

Given a set of Flags, return the union with all Flags that contain witnesses
for Diamond formulas in MCSes in the current Flags.
-/
def addWitnessFlags (flags : Set (Flag CanonicalMCS)) : Set (Flag CanonicalMCS) :=
  flags ∪ { flag' | ∃ flag ∈ flags, ∃ M : CanonicalMCS, M ∈ flag ∧
    ∃ psi : Formula, psi.diamond ∈ M.world ∧
    ∃ W : CanonicalMCS, W ∈ flag' ∧ psi ∈ W.world }

/--
The one-step closure is monotone: flags ⊆ addWitnessFlags flags.
-/
theorem addWitnessFlags_mono (flags : Set (Flag CanonicalMCS)) :
    flags ⊆ addWitnessFlags flags :=
  Set.subset_union_left

/--
Adding witness Flags preserves nonemptiness.
-/
theorem addWitnessFlags_nonempty (flags : Set (Flag CanonicalMCS)) (h : flags.Nonempty) :
    (addWitnessFlags flags).Nonempty := by
  obtain ⟨flag, h_flag⟩ := h
  exact ⟨flag, addWitnessFlags_mono flags h_flag⟩

/-!
## Closed Flag Bundle: Infinite Union Construction

The closed set of Flags is the union of all finite iterations of addWitnessFlags.
This is the standard transfinite closure construction.
-/

/--
Iterate addWitnessFlags n times starting from initial Flags.
-/
def iterateWitnessFlags (M0 : CanonicalMCS) : ℕ → Set (Flag CanonicalMCS)
  | 0 => initialFlags M0
  | n + 1 => addWitnessFlags (iterateWitnessFlags M0 n)

/--
The closed Flags: union of all finite iterations.

This set contains all Flags reachable by finitely many steps of witness addition.
-/
def closedFlags (M0 : CanonicalMCS) : Set (Flag CanonicalMCS) :=
  ⋃ n : ℕ, iterateWitnessFlags M0 n

/--
Initial Flags are in the closed set.
-/
theorem initialFlags_subset_closedFlags (M0 : CanonicalMCS) :
    initialFlags M0 ⊆ closedFlags M0 := by
  intro flag h_flag
  simp only [closedFlags]
  exact Set.mem_iUnion.mpr ⟨0, h_flag⟩

/--
The closed Flags set is nonempty.
-/
theorem closedFlags_nonempty (M0 : CanonicalMCS) : (closedFlags M0).Nonempty := by
  have h := initialFlags_nonempty M0
  obtain ⟨flag, h_flag⟩ := h
  exact ⟨flag, initialFlags_subset_closedFlags M0 h_flag⟩

/--
Each iteration is a subset of the closed Flags.
-/
theorem iterateWitnessFlags_subset_closedFlags (M0 : CanonicalMCS) (n : ℕ) :
    iterateWitnessFlags M0 n ⊆ closedFlags M0 := by
  intro flag h_flag
  simp only [closedFlags]
  exact Set.mem_iUnion.mpr ⟨n, h_flag⟩

/--
Iterations are monotone.
-/
theorem iterateWitnessFlags_mono (M0 : CanonicalMCS) (n : ℕ) :
    iterateWitnessFlags M0 n ⊆ iterateWitnessFlags M0 (n + 1) := by
  simp only [iterateWitnessFlags]
  exact addWitnessFlags_mono (iterateWitnessFlags M0 n)

/--
Iterations are monotone for any m ≥ n.
-/
theorem iterateWitnessFlags_mono_le (M0 : CanonicalMCS) {n m : ℕ} (h : n ≤ m) :
    iterateWitnessFlags M0 n ⊆ iterateWitnessFlags M0 m := by
  induction h with
  | refl => exact Set.Subset.rfl
  | step _ ih => exact Set.Subset.trans ih (iterateWitnessFlags_mono M0 _)

/-!
## Key Theorem: Closed Flags are Witness-Closed

The closed Flags set satisfies the ClosedFlagSet property.
-/

/--
**Key Theorem**: The closed Flags set is witness-closed with BoxContent preservation.

For every Diamond(psi) in any MCS in any Flag in closedFlags M0,
there exists a Flag in closedFlags M0 containing a witness MCS W with:
- psi in W.world
- MCSBoxContent M.world ⊆ W.world (preserving accessibility)
-/
theorem closedFlags_closed_under_witnesses (M0 : CanonicalMCS) :
    ClosedFlagSet (closedFlags M0) := by
  intro flag h_flag M h_M_in_flag psi h_diamond
  -- flag is in closedFlags, so it's in some iterateWitnessFlags n
  simp only [closedFlags] at h_flag
  obtain ⟨n, h_n⟩ := Set.mem_iUnion.mp h_flag
  -- Get witness MCS and its Flag with BoxContent preservation
  obtain ⟨flag', W, h_W_in_flag', h_psi, h_box⟩ := witness_flag_exists M psi h_diamond
  -- flag' is in iterateWitnessFlags (n + 1) by addWitnessFlags construction
  have h_flag'_in_next : flag' ∈ iterateWitnessFlags M0 (n + 1) := by
    simp only [iterateWitnessFlags, addWitnessFlags]
    right
    exact ⟨flag, h_n, M, h_M_in_flag, psi, h_diamond, W, h_W_in_flag', h_psi⟩
  -- Hence flag' is in closedFlags
  exact ⟨flag', iterateWitnessFlags_subset_closedFlags M0 (n + 1) h_flag'_in_next,
         W, h_W_in_flag', h_psi, h_box⟩

/--
The root MCS is in some Flag in closedFlags.
-/
theorem root_in_closedFlags (M0 : CanonicalMCS) :
    ∃ flag ∈ closedFlags M0, M0 ∈ flag := by
  obtain ⟨flag, h_flag⟩ := initialFlags_nonempty M0
  exact ⟨flag, initialFlags_subset_closedFlags M0 h_flag, h_flag⟩

/-!
## Alternative: Direct Closure via All Flags

For a simpler construction, we could use all Flags directly.
This is guaranteed closed but may include unnecessary Flags.
-/

/--
Using all Flags gives a closed set (trivially).
-/
theorem allFlags_closed' : ClosedFlagSet (@Set.univ (Flag CanonicalMCS)) :=
  allFlags_closed

end Bimodal.Metalogic.Bundle
