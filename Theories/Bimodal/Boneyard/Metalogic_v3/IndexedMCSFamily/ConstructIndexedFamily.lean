/-!
# ARCHIVED: Alternative Family Construction (Incomplete)

**Archived from**: `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean`
**Archived by**: Task 760
**Date**: 2026-01-29
**Reason**: Dead code - 4 sorries, not used in completeness proof
**Status**: Superseded by `CoherentConstruction.construct_coherent_family`

## Background

This file contains the `construct_indexed_family` function which attempted to build
an IndexedMCSFamily using independent Lindenbaum extensions at each time point.

## Why This Approach Failed

The independent Lindenbaum extension approach cannot prove the required coherence
conditions because:

1. Each time point's MCS is constructed independently via Lindenbaum's lemma
2. Independent extensions can add conflicting formulas between time points
3. If `Gphi in mcs(t)` but `Gphi not in Gamma`, there is no guarantee `phi in mcs(t')`
   for t' > t because mcs(t') was constructed without knowing about mcs(t)'s G formulas

The four coherence conditions (`forward_G`, `backward_H`, `forward_H`, `backward_G`)
all have `sorry` because they are fundamentally unprovable with this approach.

## Recommended Alternative

Use `CoherentConstruction.construct_coherent_family` instead, which:
1. Builds coherence INTO the construction itself (single Lindenbaum chain)
2. Bridges to `IndexedMCSFamily` trivially via `coherent_to_indexed_family`
3. All coherence conditions are proven without `sorry`

## Contents

- `construct_indexed_family` - The incomplete IndexedMCSFamily construction (4 sorries)
- `construct_indexed_family_origin` - Origin property lemma (proven)
- `construct_indexed_family_origin_extends` - Origin extends Gamma (proven)

The helper lemmas are proven but the core construction's coherence fields cannot be.
-/

-- NOTE: This file is archived and intentionally NOT compiled.
-- It documents the failed approach for historical reference.
-- The imports and code below are for documentation only.

/-
Original imports:
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Metalogic.Representation.CanonicalWorld
import Bimodal.Syntax.Formula
import Bimodal.Theorems.GeneralizedNecessitation
import Bimodal.Semantics.Truth
import Mathlib.Algebra.Order.Group.Defs

namespace Bimodal.Boneyard.Metalogic_v3.IndexedMCSFamily

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

variable (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

-- Assumes these definitions from the main IndexedMCSFamily.lean:
-- - time_seed
-- - mcs_at_time
-- - mcs_at_time_contains_seed
-- - mcs_at_time_is_mcs

/-!
## Alternative Construction (Incomplete)

**Note**: The `construct_indexed_family` function below uses an independent Lindenbaum
extension approach that cannot prove the required coherence conditions.

**Limitation**: Independent Lindenbaum extensions at each time point can add conflicting formulas.
If `Gphi in mcs(t)` but `Gphi not in Gamma`, there is no guarantee `phi in mcs(t')` for t' > t.
The four coherence conditions cannot be proven after construction.

**Recommended**: Use `CoherentConstruction.construct_coherent_family` instead, which builds coherence
into the construction itself, then bridges to `IndexedMCSFamily` trivially.
-/

/--
Construct an indexed MCS family from a root MCS at the origin.

**Note**: Use `CoherentConstruction.construct_coherent_family` instead for proven coherence.
This construction's coherence conditions cannot be proven with the current approach.

**Construction**:
- `mcs(t)` = extend time_seed to MCS via Lindenbaum
- Coherence conditions follow from seed definitions and Lindenbaum extension

**Usage**: Given a consistent formula phi, extend {phi} to an MCS Gamma
that does not contain G bot or H bot, then `construct_indexed_family` gives
a family where phi is true at the origin.

**Hypotheses**:
- `h_no_G_bot`: G bot not in Gamma (ensures forward temporal extension)
- `h_no_H_bot`: H bot not in Gamma (ensures backward temporal extension)

These conditions ensure the MCS is satisfiable in an UNBOUNDED temporal model.
For MCS containing G bot or H bot, a different construction (bounded endpoint) is needed.
-/
noncomputable def construct_indexed_family
    (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot not in Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot not in Gamma) :
    IndexedMCSFamily D where
  mcs := mcs_at_time D Gamma h_mcs h_no_G_bot h_no_H_bot
  is_mcs := mcs_at_time_is_mcs D Gamma h_mcs h_no_G_bot h_no_H_bot

  -- Forward G coherence: G phi in mcs(t) -> phi in mcs(t') for t < t'
  forward_G := by
    intro t t' phi hlt hG
    -- Use CoherentConstruction.construct_coherent_family for proven coherence
    sorry

  -- Backward H coherence: H phi in mcs(t) -> phi in mcs(t') for t' < t
  backward_H := by
    intro t t' phi hlt hH
    -- Use CoherentConstruction.construct_coherent_family for proven coherence
    sorry

  -- Forward H coherence: H phi in mcs(t') -> phi in mcs(t) for t < t'
  forward_H := by
    intro t t' phi hlt hH
    -- Use CoherentConstruction.construct_coherent_family for proven coherence
    sorry

  -- Backward G coherence: G phi in mcs(t') -> phi in mcs(t) for t' < t
  backward_G := by
    intro t t' phi hlt hG
    -- Use CoherentConstruction.construct_coherent_family for proven coherence
    sorry

/-!
### Properties of the Constructed Family
-/

/--
The MCS at the origin is exactly the extended root MCS.

At t = 0, time_seed returns Gamma directly, so mcs(0) is
the Lindenbaum extension of Gamma, which contains Gamma.
-/
lemma construct_indexed_family_origin (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot not in Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot not in Gamma)
    (phi : Formula) (h_phi : phi in Gamma) :
    phi in (construct_indexed_family D Gamma h_mcs h_no_G_bot h_no_H_bot).mcs 0 := by
  -- mcs(0) = extendToMCS (time_seed D Gamma 0)
  -- time_seed D Gamma 0 = Gamma (by definition, when t = 0)
  -- extendToMCS contains the seed
  have h_seed : phi in time_seed D Gamma 0 := by
    simp only [time_seed, ↓reduceIte]
    exact h_phi
  exact mcs_at_time_contains_seed D Gamma h_mcs h_no_G_bot h_no_H_bot 0 h_seed

/--
At the origin, the constructed family's MCS extends Gamma.
-/
lemma construct_indexed_family_origin_extends (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot not in Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot not in Gamma) :
    Gamma subseteq (construct_indexed_family D Gamma h_mcs h_no_G_bot h_no_H_bot).mcs 0 := by
  intro phi h_phi
  exact construct_indexed_family_origin D Gamma h_mcs h_no_G_bot h_no_H_bot phi h_phi

end Bimodal.Boneyard.Metalogic_v3.IndexedMCSFamily
-/
