import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.Formula

/-!
# FMCS: Family of Maximal Consistent Sets

This module defines the `FMCS` (Family of Maximal Consistent Sets) structure
that assigns a maximal consistent set (MCS) to each time point in D, with temporal
coherence conditions ensuring proper formula propagation.

## FMCS Indexing Type

The type parameter `D` in `FMCS D` is the **indexing type** for the family. For
proper temporal model construction, `D` should be a temporal domain such as:
- `Int` or `Nat` for discrete time
- `TimelineQuot` or `Rat` for dense time (Cantor domain)
- Any type with `AddCommGroup + LinearOrder` for duration arithmetic

**Correct Approach**: The SuccChain construction (SuccChainFMCS.lean) uses D=Int
with proper temporal coherence. This is the canonical implementation for discrete
completeness.

**Archived Pattern**: The D=CanonicalMCS pattern (former CanonicalFMCS.lean)
has been removed. It was architecturally confused: using all MCS as the indexing type
created an identity mapping `mcs(w) = w.world` that trivialized F/P witness obligations
rather than proving them.

**WARNING: W=D Conflation Error**: Never conflate world states (MCS)
with time indices. World states describe WHAT is true; time indices describe WHEN.
D must be a proper timeline type (Int, Rat, TimelineQuot), not CanonicalMCS.

## Terminology

- **FMCS**: A SINGLE time-indexed family of MCS (Family of MCS)
- **BFMCS**: A BUNDLE (set) of FMCS families with modal coherence
- **MCS**: A single maximal consistent set

## Overview

Build a family of MCS indexed by time, where each time point has its own
MCS connected to adjacent times via temporal coherence conditions.

**Design Evolution**: TM logic uses REFLEXIVE temporal operators with T-axioms
(`G phi -> phi`, `H phi -> phi`) to enable coherence proofs.

## Main Definitions

- `FMCS D`: Structure pairing each time `t : D` with an MCS, plus coherence
- `forward_G`: G formulas at t propagate to all times t' >= t (including t itself via T-axiom)
- `backward_H`: H formulas at t propagate to all times t' <= t (including t itself via T-axiom)

## Design Note

The structure previously included `forward_H` and `backward_G` fields. These were
removed because:
1. The TruthLemma does NOT use them (verified by grep)
2. They existed only because constant-family constructions provided them trivially
3. Removing them simplifies all downstream family constructions
4. The temporal backward properties (G backward, H backward) are proven via
   contraposition using `forward_F`/`backward_P` from `TemporalCoherentFamily`

## References

-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core

/-!
## FMCS Structure
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
- Reflexivity enables Preorder generalization

**Terminology**:
- FMCS = Family of MCS (single family)
- BFMCS = Bundle of FMCSs (collection of families)
-/
structure FMCS where
  /-- The MCS assignment: each time t gets an MCS -/
  mcs : D -> Set Formula
  /-- Each assigned set is maximal consistent -/
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  /--
  Forward G coherence: G phi at time t implies phi at all future times t' >= t.

  Semantic justification: With reflexive semantics, `G phi` means "phi at all times s >= t".
  If `G phi` is in the MCS at t, then phi must be in the MCS at any t' >= t.
  By T-axiom, this includes phi ∈ mcs t (taking t' = t).
  -/
  forward_G : forall t t' phi, t ≤ t' -> Formula.all_future phi ∈ mcs t -> phi ∈ mcs t'
  /--
  Backward H coherence: H phi at time t implies phi at all past times t' <= t.

  Semantic justification: With reflexive semantics, `H phi` means "phi at all times s <= t".
  If `H phi` is in the MCS at t, then phi must be in the MCS at any t' <= t.
  By T-axiom, this includes phi ∈ mcs t (taking t' = t).
  -/
  backward_H : forall t t' phi, t' ≤ t -> Formula.all_past phi ∈ mcs t -> phi ∈ mcs t'

variable {D : Type*} [Preorder D]

-- Unused convenience definitions removed:
-- FMCS.at, FMCS.consistent, FMCS.maximal, FMCS.forward_G_chain, FMCS.backward_H_chain,
-- FMCS.GG_to_G, FMCS.HH_to_H, FMCS.theorem_mem, FMCS.G_implies_future_phi,
-- FMCS.H_implies_past_phi, IsConstantFamily
-- These were thin wrappers around structure fields that were never used.

end Bimodal.Metalogic.Bundle
