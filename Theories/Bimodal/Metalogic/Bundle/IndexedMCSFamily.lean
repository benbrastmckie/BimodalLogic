import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.Formula
import Mathlib.Algebra.Order.Group.Defs

/-!
# Indexed MCS Family for Bundle Completeness

This module defines the `IndexedMCSFamily` structure that assigns a maximal consistent
set (MCS) to each time point in D, with temporal coherence conditions ensuring
proper formula propagation.

## Overview

This is a streamlined version for the Bundle completeness proof, extracted from
the Boneyard infrastructure to avoid broken import dependencies.

**Design Evolution**: TM logic uses REFLEXIVE temporal operators with T-axioms
(`G phi -> phi`, `H phi -> phi`) to enable coherence proofs.

**Solution**: Build a family of MCS indexed by time, where each time point has its own
MCS connected to adjacent times via temporal coherence conditions.

## Main Definitions

- `IndexedMCSFamily D`: Structure pairing each time `t : D` with an MCS, plus coherence
- `forward_G`: G formulas at t propagate to all future t' > t
- `backward_H`: H formulas at t propagate to all past t' < t
- `forward_H`: H formulas at future times connect to past
- `backward_G`: G formulas at past times connect to future

## References

- Research report: specs/812_canonical_model_completeness/reports/research-007.md
- Original: Bimodal.Boneyard.Metalogic_v5.Representation.IndexedMCSFamily
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core

/-!
## Indexed MCS Family Structure
-/

variable (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/--
A family of maximal consistent sets indexed by time, with temporal coherence.

**Type Parameters**:
- `D`: Duration/time type with ordered additive group structure

**Fields**:
- `mcs`: Function assigning an MCS to each time point
- `is_mcs`: Proof that each assigned set is maximal consistent
- `forward_G`: G formulas propagate to strictly future times
- `backward_H`: H formulas propagate to strictly past times
- `forward_H`: H formulas at future times connect back to present
- `backward_G`: G formulas at past times connect forward to present

**Key Properties**:
- The coherence conditions use STRICT inequalities (< not <=)
- This matches TM's temporal operator semantics
- The T-axiom is used for reflexivity within a single MCS

**Design Note**:
The `forward_X` conditions handle propagation FROM time t TO future times.
The `backward_X` conditions handle propagation FROM time t TO past times.
Both directions (forward/backward in coherence name) are needed for compositionality.
-/
structure IndexedMCSFamily where
  /-- The MCS assignment: each time t gets an MCS -/
  mcs : D -> Set Formula
  /-- Each assigned set is maximal consistent -/
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  /--
  Forward G coherence: G phi at time t implies phi at all strictly future times.

  Semantic justification: If `G phi` means "phi at all future times",
  and `G phi` is in the MCS at t, then phi must be in the MCS at any t' > t.
  -/
  forward_G : forall t t' phi, t < t' -> Formula.all_future phi ∈ mcs t -> phi ∈ mcs t'
  /--
  Backward H coherence: H phi at time t implies phi at all strictly past times.

  Semantic justification: If `H phi` means "phi at all past times",
  and `H phi` is in the MCS at t, then phi must be in the MCS at any t' < t.
  -/
  backward_H : forall t t' phi, t' < t -> Formula.all_past phi ∈ mcs t -> phi ∈ mcs t'
  /--
  Forward H coherence: H phi at a future time t' implies phi at present time t.

  This is the "looking back from the future" condition. If at some future time t' > t
  we have "phi was always true in the past", then phi must have been true at t.
  -/
  forward_H : forall t t' phi, t < t' -> Formula.all_past phi ∈ mcs t' -> phi ∈ mcs t
  /--
  Backward G coherence: G phi at a past time t' implies phi at present time t.

  This is the "looking forward from the past" condition. If at some past time t' < t
  we have "phi will always be true in the future", then phi must be true at t.
  -/
  backward_G : forall t t' phi, t' < t -> Formula.all_future phi ∈ mcs t' -> phi ∈ mcs t

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-!
## Basic Accessors
-/

/-- Get the MCS at a specific time -/
def IndexedMCSFamily.at (family : IndexedMCSFamily D) (t : D) : Set Formula :=
  family.mcs t

/-- The MCS at any time is consistent -/
lemma IndexedMCSFamily.consistent (family : IndexedMCSFamily D) (t : D) :
    SetConsistent (family.mcs t) :=
  (family.is_mcs t).1

/-- The MCS at any time is maximal (cannot be consistently extended) -/
lemma IndexedMCSFamily.maximal (family : IndexedMCSFamily D) (t : D) :
    forall phi : Formula, phi ∉ family.mcs t -> ¬SetConsistent (insert phi (family.mcs t)) :=
  (family.is_mcs t).2

/-!
## Derived Coherence Lemmas

These lemmas follow from the basic coherence conditions and are useful for proofs.
-/

/--
G phi propagates transitively through future times.

If `G phi ∈ mcs(t)` and `t < t' < t''`, then `phi ∈ mcs(t')` and `phi ∈ mcs(t'')`.
-/
lemma IndexedMCSFamily.forward_G_chain (family : IndexedMCSFamily D)
    {t t' : D} (htt' : t < t') (phi : Formula) (hG : Formula.all_future phi ∈ family.mcs t) :
    phi ∈ family.mcs t' :=
  family.forward_G t t' phi htt' hG

/--
H phi propagates transitively through past times.

If `H phi ∈ mcs(t)` and `t'' < t' < t`, then `phi ∈ mcs(t')` and `phi ∈ mcs(t'')`.
-/
lemma IndexedMCSFamily.backward_H_chain (family : IndexedMCSFamily D)
    {t t' : D} (ht't : t' < t) (phi : Formula) (hH : Formula.all_past phi ∈ family.mcs t) :
    phi ∈ family.mcs t' :=
  family.backward_H t t' phi ht't hH

/--
GG phi implies G phi propagation (using Temporal 4 axiom).

If `G(G phi) ∈ mcs(t)` and `t < t'`, then `G phi ∈ mcs(t')`.

This uses the Temporal 4 axiom `G phi -> GG phi` in the contrapositive direction:
From `GG phi ∈ mcs(t)`, we have `G phi` will be at all strictly future times.
-/
lemma IndexedMCSFamily.GG_to_G (family : IndexedMCSFamily D)
    {t t' : D} (htt' : t < t') (phi : Formula)
    (hGG : Formula.all_future (Formula.all_future phi) ∈ family.mcs t) :
    Formula.all_future phi ∈ family.mcs t' :=
  family.forward_G t t' (Formula.all_future phi) htt' hGG

/--
HH phi implies H phi propagation (using Temporal 4 dual for H).

If `H(H phi) ∈ mcs(t)` and `t' < t`, then `H phi ∈ mcs(t')`.
-/
lemma IndexedMCSFamily.HH_to_H (family : IndexedMCSFamily D)
    {t t' : D} (ht't : t' < t) (phi : Formula)
    (hHH : Formula.all_past (Formula.all_past phi) ∈ family.mcs t) :
    Formula.all_past phi ∈ family.mcs t' :=
  family.backward_H t t' (Formula.all_past phi) ht't hHH

/-!
## Theorem Membership in Family MCS

Theorems (provable formulas) are in every MCS of the family.
-/

/--
Theorems are in every MCS of the family.
-/
lemma IndexedMCSFamily.theorem_mem (family : IndexedMCSFamily D)
    (t : D) (phi : Formula) (h_deriv : Bimodal.ProofSystem.DerivationTree [] phi) :
    phi ∈ family.mcs t :=
  theorem_in_mcs (family.is_mcs t) h_deriv

/-!
## Properties for Task Relation

These lemmas will be used when proving the canonical task relation properties.
-/

/--
If G phi is in the MCS at time t, then for any strictly future time t' > t,
phi is in the MCS at t'.

This is just a restatement of forward_G for clarity in task relation proofs.
-/
lemma IndexedMCSFamily.G_implies_future_phi (family : IndexedMCSFamily D)
    {t t' : D} (hlt : t < t') {phi : Formula} (hG : Formula.all_future phi ∈ family.mcs t) :
    phi ∈ family.mcs t' :=
  family.forward_G t t' phi hlt hG

/--
If H phi is in the MCS at time t, then for any strictly past time t' < t,
phi is in the MCS at t'.

This is just a restatement of backward_H for clarity in task relation proofs.
-/
lemma IndexedMCSFamily.H_implies_past_phi (family : IndexedMCSFamily D)
    {t t' : D} (hlt : t' < t) {phi : Formula} (hH : Formula.all_past phi ∈ family.mcs t) :
    phi ∈ family.mcs t' :=
  family.backward_H t t' phi hlt hH

end Bimodal.Metalogic.Bundle
