import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Representation.IndexedMCSFamily
import Bimodal.Syntax.Formula
import Bimodal.Boneyard.Metalogic.Completeness
import Mathlib.Algebra.Order.Group.Defs

/-!
# Coherent Indexed MCS Family Construction

This module implements a coherent construction approach for IndexedMCSFamily
that guarantees temporal coherence by building it into the construction rather
than trying to prove it after the fact.

## Design Approach

The key insight from research-001.md: Independent Lindenbaum extensions at each
time point cannot guarantee coherence because each makes independent choices about
which formulas to add beyond the seed. The solution is to define coherence
RELATIONALLY between neighboring MCS pairs, adapted from the Boneyard's
`canonical_task_rel` pattern.

## Construction Strategy

1. Define `coherent_at` relation between MCS pairs that encodes all four
   IndexedMCSFamily coherence conditions
2. Define `CoherentIndexedFamily` structure using pairwise coherence
3. Prove forward/backward extension existence lemmas
4. Prove that pairwise coherence implies transitivity
5. Construct a complete family from a root MCS
6. Bridge to IndexedMCSFamily by proving coherence conditions follow from
   pairwise coherence

## References

- Research report: specs/681_.../reports/research-001.md
- Implementation plan: specs/681_.../plans/implementation-001.md
- Boneyard pattern: Theories/Bimodal/Boneyard/Metalogic/Completeness.lean:2055-2581
-/

namespace Bimodal.Metalogic.Representation

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic_v2.Core

variable (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-!
## Coherent Relation Definition

The `coherent_at` relation defines what it means for two MCS to be coherent
at their respective time points. This encodes all four IndexedMCSFamily coherence
conditions in a single relational definition.
-/

/--
Two MCS are coherent at times t and t' if they satisfy temporal transfer conditions.

This relation captures the four IndexedMCSFamily coherence conditions:
1. Forward G: If t < t', then G φ at t implies φ at t'
2. Backward H: If t' < t, then H φ at t implies φ at t'
3. Forward H: If t < t', then H φ at t' implies φ at t ("looking back")
4. Backward G: If t' < t, then G φ at t' implies φ at t ("looking forward")

**Key Design**: The conditions are IMPLICATIONS guarded by time ordering.
This makes the relation reflexive at equal times (all implications vacuous).
-/
def coherent_at (mcs_t : Set Formula) (mcs_t' : Set Formula) (t t' : D) : Prop :=
  (t < t' → ∀ φ, Formula.all_future φ ∈ mcs_t → φ ∈ mcs_t') ∧
  (t' < t → ∀ φ, Formula.all_past φ ∈ mcs_t → φ ∈ mcs_t') ∧
  (t < t' → ∀ φ, Formula.all_past φ ∈ mcs_t' → φ ∈ mcs_t) ∧
  (t' < t → ∀ φ, Formula.all_future φ ∈ mcs_t' → φ ∈ mcs_t)

/-!
## Coherent Indexed Family Structure

A `CoherentIndexedFamily` is an indexed family of MCS where pairwise coherence
is guaranteed by construction. This is stronger than `IndexedMCSFamily` because
it requires coherence between ALL pairs, not just specific patterns.
-/

/--
An indexed family of MCS with pairwise temporal coherence.

**Structure**:
- `mcs`: Assignment of MCS to each time point
- `is_mcs`: Proof that each assigned set is maximal consistent
- `pairwise_coherent`: All pairs of time points have coherent MCS

**Key Property**: The `pairwise_coherent` field is the construction constraint.
By requiring coherence at construction time, we avoid the impossible task of
proving it after independent Lindenbaum extensions.
-/
structure CoherentIndexedFamily where
  /-- MCS assignment to each time point -/
  mcs : D → Set Formula
  /-- Each assigned set is maximal consistent -/
  is_mcs : ∀ t, SetMaximalConsistent (mcs t)
  /-- Pairwise temporal coherence between all time points -/
  pairwise_coherent : ∀ t t', coherent_at D (mcs t) (mcs t') t t'

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-!
## Basic Properties of Coherent Relation
-/

/--
Reflexivity: Any MCS is coherent with itself at the same time.

**Proof**: All four conditions are vacuous when t = t' (no strict inequality).
-/
theorem coherent_at_refl (S : Set Formula) (t : D) :
    coherent_at D S S t t := by
  unfold coherent_at
  refine ⟨?_, ?_, ?_, ?_⟩
  -- Forward G: t < t → ... (vacuous, t < t is false)
  · intro h_lt
    exfalso
    exact lt_irrefl t h_lt
  -- Backward H: t < t → ... (vacuous, t < t is false)
  · intro h_lt
    exfalso
    exact lt_irrefl t h_lt
  -- Forward H: t < t → ... (vacuous, t < t is false)
  · intro h_lt
    exfalso
    exact lt_irrefl t h_lt
  -- Backward G: t < t → ... (vacuous, t < t is false)
  · intro h_lt
    exfalso
    exact lt_irrefl t h_lt

/--
Coherence conditions are symmetric in a specific sense: if S is coherent with T
at times (t, t'), then T is coherent with S at times (t', t) with swapped
directions.

This is not quite symmetry (coherent_at S T t t' ↔ coherent_at T S t' t)
but rather a relationship between the conditions.
-/
theorem coherent_at_swap (S T : Set Formula) (t t' : D)
    (h : coherent_at D S T t t') :
    coherent_at D T S t' t := by
  unfold coherent_at at *
  obtain ⟨h_fwd_G, h_bwd_H, h_fwd_H, h_bwd_G⟩ := h
  refine ⟨?_, ?_, ?_, ?_⟩
  -- Forward G for (T, S) at (t', t): t' < t → G φ ∈ T → φ ∈ S
  -- This is exactly h_bwd_G (backward G for (S, T) at (t, t'))
  · exact h_bwd_G
  -- Backward H for (T, S) at (t', t): t < t' → H φ ∈ T → φ ∈ S
  -- This is exactly h_fwd_H (forward H for (S, T) at (t, t'))
  · intro h_lt
    exact h_fwd_H h_lt
  -- Forward H for (T, S) at (t', t): t' < t → H φ ∈ S → φ ∈ T
  -- This is exactly h_bwd_H (backward H for (S, T) at (t, t'))
  · exact h_bwd_H
  -- Backward G for (T, S) at (t', t): t < t' → G φ ∈ S → φ ∈ T
  -- This is exactly h_fwd_G (forward G for (S, T) at (t, t'))
  · intro h_lt
    exact h_fwd_G h_lt

/-!
## Properties of CoherentIndexedFamily
-/

/--
Get the MCS at a specific time from a coherent family.
-/
def CoherentIndexedFamily.at (family : CoherentIndexedFamily D) (t : D) : Set Formula :=
  family.mcs t

/--
The MCS at any time in a coherent family is consistent.
-/
lemma CoherentIndexedFamily.consistent (family : CoherentIndexedFamily D) (t : D) :
    SetConsistent (family.mcs t) :=
  (family.is_mcs t).1

/--
The MCS at any time in a coherent family is maximal.
-/
lemma CoherentIndexedFamily.maximal (family : CoherentIndexedFamily D) (t : D) :
    ∀ φ : Formula, φ ∉ family.mcs t → ¬SetConsistent (insert φ (family.mcs t)) :=
  (family.is_mcs t).2

end Bimodal.Metalogic.Representation
