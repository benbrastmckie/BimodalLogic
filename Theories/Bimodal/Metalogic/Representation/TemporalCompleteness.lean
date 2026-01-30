import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Metalogic.Representation.IndexedMCSFamily
import Mathlib.Algebra.Order.Group.Defs

/-!
# Temporal Completeness for Indexed MCS Families

This module provides the infrastructure for the backward direction of the Truth Lemma
temporal cases.

## Status: NOT REQUIRED FOR COMPLETENESS

The backward Truth Lemma temporal cases (TruthLemma.lean lines 423, 441) are **not used**
by the representation theorem. The completeness proof only requires the forward direction.

This module documents the proof approach and provides the lemma signatures, but the
core H/G-completeness lemmas have `sorry` due to a fundamental limitation:

**The Omega-Rule Problem**: Proving `(forall s < t, psi in mcs(s)) -> H psi in mcs(t)`
requires deriving `H psi` from infinitely many instances of `psi`. Standard proof systems
(including TM logic) lack this "omega-rule". The IndexedMCSFamily coherence conditions
only guarantee the CONVERSE direction.

## Core Problem

The backward Truth Lemma needs to prove:
- `(forall s <= t, truth_at s psi) -> H psi in mcs(t)`
- `(forall s >= t, truth_at s psi) -> G psi in mcs(t)`

The proof strategy uses the **contrapositive**:
1. Assume `H psi not-in mcs(t)`
2. Extract a witness: `exists s < t. psi not-in mcs(s)`
3. Use forward IH + negation completeness to get contradiction

Step 2 requires "H-completeness", which is blocked by the omega-rule issue.

## Architectural Options for Future Work

1. **Extend IndexedMCSFamily**: Add H/G-completeness as axioms in the structure
2. **Construction-specific proof**: Prove for specific constructions (e.g., CoherentConstruction)
3. **Semantic bridge**: Use canonical model truth to derive membership (may be circular)
4. **Finite witness bounds**: For bounded domains, the omega-rule becomes finite

## Main Definitions

- `H_completeness`: If psi in every past MCS, then H psi in current MCS (SORRY)
- `G_completeness`: Symmetric for future direction (SORRY)
- `witness_from_not_H`: Corollary - direct witness extraction (depends on H_completeness)
- `witness_from_not_G`: Symmetric for future direction (depends on G_completeness)

## References

- Research: specs/741_.../reports/research-001.md (Approach analysis)
- Plan: specs/741_.../plans/implementation-001.md
- Boneyard: Boneyard/Metalogic_v3/TruthLemma/BackwardDirection.lean
- TruthLemma.lean backward temporal cases: lines 423, 441
-/

namespace Bimodal.Metalogic.Representation

open Bimodal.Syntax
open Bimodal.Metalogic.Core

variable (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-!
## H-Completeness Lemma

The key insight is that if psi is in every past MCS, then the formula H psi cannot
be absent from the current MCS without creating a contradiction.

**Status**: SORRY - requires omega-rule or construction-specific argument.

**Proof Approach**:
1. Assume H psi not-in mcs(t) (for contradiction)
2. By MCS negation completeness: neg(H psi) in mcs(t)
3. Need: derive contradiction from neg(H psi) and forall s < t, psi in mcs(s)

**Why This Is Hard**:
The IndexedMCSFamily coherence only guarantees:
- `backward_H`: H psi in mcs(t) -> psi in mcs(s) for s < t

It does NOT guarantee the converse. Proving the converse requires deriving H psi
from infinitely many psi instances, which needs an omega-rule that TM logic lacks.

**Potential Solutions**:
1. Add H/G-completeness as axioms to IndexedMCSFamily structure
2. Prove for specific constructions (CoherentConstruction over Z)
3. Use finite domain restriction where omega becomes finite conjunction
-/

/--
H-completeness: if psi is in every strictly past MCS, then H psi is in the current MCS.

**Status**: SORRY - blocked by omega-rule limitation.

The contrapositive `H psi not-in mcs(t) -> exists s < t. psi not-in mcs(s)` is what
the backward Truth Lemma needs. However, proving H-completeness requires deriving
H psi from universal psi-membership, which standard proof systems cannot do.

**NOT REQUIRED FOR COMPLETENESS**: The representation theorem only uses
`truth_lemma_forward`, not the backward direction.
-/
lemma H_completeness (family : IndexedMCSFamily D) (t : D) (psi : Formula)
    (h_all_past : forall s, s < t -> psi ∈ family.mcs s) : Formula.all_past psi ∈ family.mcs t := by
  -- Proof by contradiction setup
  by_contra h_not_H
  -- By MCS negation completeness: neg(H psi) in mcs(t)
  have h_neg_H : (Formula.all_past psi).neg ∈ family.mcs t := by
    cases set_mcs_negation_complete (family.is_mcs t) (Formula.all_past psi) with
    | inl h => exact absurd h h_not_H
    | inr h => exact h
  -- We have: neg(H psi) in mcs(t) and forall s < t, psi in mcs(s)
  -- Need to derive contradiction.
  --
  -- BLOCKED: This requires the omega-rule to derive H psi from infinitely many psi instances.
  -- The coherence conditions only provide backward_H (the other direction).
  --
  -- Alternative approaches documented in:
  -- - specs/741_.../reports/research-001.md
  -- - Boneyard/Metalogic_v3/TruthLemma/BackwardDirection.lean
  sorry

/--
G-completeness: if psi is in every strictly future MCS, then G psi is in the current MCS.

**Status**: SORRY - blocked by omega-rule limitation (symmetric to H_completeness).

**NOT REQUIRED FOR COMPLETENESS**: The representation theorem only uses
`truth_lemma_forward`, not the backward direction.
-/
lemma G_completeness (family : IndexedMCSFamily D) (t : D) (psi : Formula)
    (h_all_future : forall s, t < s -> psi ∈ family.mcs s) : Formula.all_future psi ∈ family.mcs t := by
  by_contra h_not_G
  have h_neg_G : (Formula.all_future psi).neg ∈ family.mcs t := by
    cases set_mcs_negation_complete (family.is_mcs t) (Formula.all_future psi) with
    | inl h => exact absurd h h_not_G
    | inr h => exact h
  -- BLOCKED: Same omega-rule issue as H_completeness (symmetric case)
  sorry

/-!
## Witness Extraction Lemmas

These are direct corollaries of H/G-completeness via contrapositive.
They provide the existential witnesses needed in the backward Truth Lemma cases.
-/

/--
Witness extraction from H psi not-in mcs(t): there exists s < t with psi not-in mcs(s).

This is the contrapositive of H_completeness, made explicit for use in TruthLemma.lean.
-/
lemma witness_from_not_H (family : IndexedMCSFamily D) (t : D) (psi : Formula)
    (h_not_H : Formula.all_past psi ∉ family.mcs t) :
    exists s, s < t ∧ psi ∉ family.mcs s := by
  -- Contrapositive of H_completeness
  by_contra h_no_witness
  push_neg at h_no_witness
  -- h_no_witness : forall s < t, psi in mcs(s)
  have h_H := H_completeness D family t psi h_no_witness
  exact h_not_H h_H

/--
Witness extraction from G psi not-in mcs(t): there exists s > t with psi not-in mcs(s).

Symmetric to witness_from_not_H for the future direction.
-/
lemma witness_from_not_G (family : IndexedMCSFamily D) (t : D) (psi : Formula)
    (h_not_G : Formula.all_future psi ∉ family.mcs t) :
    exists s, t < s ∧ psi ∉ family.mcs s := by
  by_contra h_no_witness
  push_neg at h_no_witness
  have h_G := G_completeness D family t psi h_no_witness
  exact h_not_G h_G

end Bimodal.Metalogic.Representation
