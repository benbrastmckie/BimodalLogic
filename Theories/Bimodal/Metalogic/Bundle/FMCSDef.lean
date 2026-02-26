import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.Formula

/-!
# BFMCS: Family of Maximal Consistent Sets

This module defines the `BFMCS` (Family of Maximal Consistent Sets) structure
that assigns a maximal consistent set (MCS) to each time point in D, with temporal
coherence conditions ensuring proper formula propagation.

## Terminology (Task 925)

- **FMCS** / **BFMCS**: A SINGLE time-indexed family of MCS. The preferred name
  is `FMCS` (see `FMCS.lean`); `BFMCS` is retained for backward compatibility.
- **BMCS**: A BUNDLE (set) of families with modal coherence.

The "B" in "BFMCS" historically stood for "Bundled" in the Lean4 sense (bundling
data with proofs), NOT for collecting multiple families. To avoid confusion, new
code should prefer the `FMCS` alias defined in `FMCS.lean`.

## Overview

Build a family of MCS indexed by time, where each time point has its own
MCS connected to adjacent times via temporal coherence conditions.

**Design Evolution**: TM logic uses REFLEXIVE temporal operators with T-axioms
(`G phi -> phi`, `H phi -> phi`) to enable coherence proofs.

## Main Definitions

- `BFMCS D`: Structure pairing each time `t : D` with an MCS, plus coherence
- `forward_G`: G formulas at t propagate to all future t' >= t
- `backward_H`: H formulas at t propagate to all past t' <= t

## Design Note (Task 843)

The structure previously included `forward_H` and `backward_G` fields. These were
removed because:
1. The TruthLemma does NOT use them (verified by grep)
2. They existed only because constant-family constructions provided them trivially
3. Removing them simplifies all downstream family constructions
4. The temporal backward properties (G backward, H backward) are proven via
   contraposition using `forward_F`/`backward_P` from `TemporalCoherentFamily`

## References

- Research report: specs/812_canonical_model_completeness/reports/research-007.md
- Original: Bimodal.Boneyard.Metalogic_v5.Representation.BFMCS
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core

/-!
## BFMCS Structure
-/

variable (D : Type*) [Preorder D]

/--
A family of maximal consistent sets indexed by time, with temporal coherence.

**Type Parameters**:
- `D`: Duration/time type with preorder structure

**Fields**:
- `mcs`: Function assigning an MCS to each time point
- `is_mcs`: Proof that each assigned set is maximal consistent
- `forward_G`: G formulas propagate to future times (reflexive)
- `backward_H`: H formulas propagate to past times (reflexive)

**Key Properties**:
- The coherence conditions use REFLEXIVE inequalities (<= not <)
- This matches TM's temporal operator semantics with T-axioms
- Reflexivity enables Preorder generalization (Task 922)

**Terminology (Task 925)**:
- BFMCS = FMCS = Family of MCS (single family)
- BMCS = Bundle of MCS (collection of families)
-/
structure BFMCS where
  /-- The MCS assignment: each time t gets an MCS -/
  mcs : D -> Set Formula
  /-- Each assigned set is maximal consistent -/
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  /--
  Forward G coherence: G phi at time t implies phi at all future times t' >= t.

  Semantic justification: If `G phi` means "phi at all future times",
  and `G phi` is in the MCS at t, then phi must be in the MCS at any t' >= t.
  -/
  forward_G : forall t t' phi, t ≤ t' -> Formula.all_future phi ∈ mcs t -> phi ∈ mcs t'
  /--
  Backward H coherence: H phi at time t implies phi at all past times t' ≤ t.

  Semantic justification: If `H phi` means "phi at all past times",
  and `H phi` is in the MCS at t, then phi must be in the MCS at any t' ≤ t.
  -/
  backward_H : forall t t' phi, t' ≤ t -> Formula.all_past phi ∈ mcs t -> phi ∈ mcs t'

variable {D : Type*} [Preorder D]

/-!
## Basic Accessors
-/

/-- Get the MCS at a specific time -/
def BFMCS.at (family : BFMCS D) (t : D) : Set Formula :=
  family.mcs t

/-- The MCS at any time is consistent -/
lemma BFMCS.consistent (family : BFMCS D) (t : D) :
    SetConsistent (family.mcs t) :=
  (family.is_mcs t).1

/-- The MCS at any time is maximal (cannot be consistently extended) -/
lemma BFMCS.maximal (family : BFMCS D) (t : D) :
    forall phi : Formula, phi ∉ family.mcs t -> ¬SetConsistent (insert phi (family.mcs t)) :=
  (family.is_mcs t).2

/-!
## Derived Coherence Lemmas

These lemmas follow from the basic coherence conditions and are useful for proofs.
-/

/--
G phi propagates to future times.

If `G phi ∈ mcs(t)` and `t ≤ t'`, then `phi ∈ mcs(t')`.
-/
lemma BFMCS.forward_G_chain (family : BFMCS D)
    {t t' : D} (htt' : t ≤ t') (phi : Formula) (hG : Formula.all_future phi ∈ family.mcs t) :
    phi ∈ family.mcs t' :=
  family.forward_G t t' phi htt' hG

/--
H phi propagates to past times.

If `H phi ∈ mcs(t)` and `t' ≤ t`, then `phi ∈ mcs(t')`.
-/
lemma BFMCS.backward_H_chain (family : BFMCS D)
    {t t' : D} (ht't : t' ≤ t) (phi : Formula) (hH : Formula.all_past phi ∈ family.mcs t) :
    phi ∈ family.mcs t' :=
  family.backward_H t t' phi ht't hH

/--
GG phi implies G phi propagation (using Temporal 4 axiom).

If `G(G phi) ∈ mcs(t)` and `t ≤ t'`, then `G phi ∈ mcs(t')`.
-/
lemma BFMCS.GG_to_G (family : BFMCS D)
    {t t' : D} (htt' : t ≤ t') (phi : Formula)
    (hGG : Formula.all_future (Formula.all_future phi) ∈ family.mcs t) :
    Formula.all_future phi ∈ family.mcs t' :=
  family.forward_G t t' (Formula.all_future phi) htt' hGG

/--
HH phi implies H phi propagation (using Temporal 4 dual for H).

If `H(H phi) ∈ mcs(t)` and `t' ≤ t`, then `H phi ∈ mcs(t')`.
-/
lemma BFMCS.HH_to_H (family : BFMCS D)
    {t t' : D} (ht't : t' ≤ t) (phi : Formula)
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
lemma BFMCS.theorem_mem (family : BFMCS D)
    (t : D) (phi : Formula) (h_deriv : Bimodal.ProofSystem.DerivationTree [] phi) :
    phi ∈ family.mcs t :=
  theorem_in_mcs (family.is_mcs t) h_deriv

/-!
## Properties for Task Relation

These lemmas will be used when proving the canonical task relation properties.
-/

/--
If G phi is in the MCS at time t, then for any future time t' >= t,
phi is in the MCS at t'.
-/
lemma BFMCS.G_implies_future_phi (family : BFMCS D)
    {t t' : D} (hle : t ≤ t') {phi : Formula} (hG : Formula.all_future phi ∈ family.mcs t) :
    phi ∈ family.mcs t' :=
  family.forward_G t t' phi hle hG

/--
If H phi is in the MCS at time t, then for any past time t' <= t,
phi is in the MCS at t'.
-/
lemma BFMCS.H_implies_past_phi (family : BFMCS D)
    {t t' : D} (hle : t' ≤ t) {phi : Formula} (hH : Formula.all_past phi ∈ family.mcs t) :
    phi ∈ family.mcs t' :=
  family.backward_H t t' phi hle hH

end Bimodal.Metalogic.Bundle
