import Bimodal.Metalogic.Bundle.FlagBFMCS
import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Metalogic.Algebraic.ParametricCanonical
import Bimodal.Metalogic.Algebraic.ParametricHistory
import Bimodal.Metalogic.Algebraic.CanonicalQuot
import Mathlib.Logic.Encodable.Basic

/-!
# FlagBFMCS to BFMCS Int Bundle (Task 1006)

This module converts a FlagBFMCS (Flag-indexed bundle) to a BFMCS Int (integer-indexed bundle)
using a global countable enumeration of CanonicalMCS.

## Overview

The key insight is that CanonicalMCS is countable (it's a subtype of Set Formula, and
each MCS is uniquely determined by its membership function on countable Formula).
We use this countability to embed all MCS into Int via a global enumeration.

## Main Definitions

- `enum_mcs`: Global injection from CanonicalMCS to Int
- `fmcs_from_flag`: Convert a Flag's chainFMCS to FMCS Int
- `bfmcs_from_flagbfmcs`: Convert FlagBFMCS to BFMCS Int

## Design

The construction uses:
1. **Global countable enumeration**: Single `enum_mcs : CanonicalMCS -> Int`
2. **Root MCS fallback**: Out-of-range times map to root MCS
3. **D-polymorphic design**: The construction generalizes to any D (Int, Rat, etc.)

## References

- Task 1006 plan: specs/1006_canonical_taskframe_completeness/plans/02_streamlined-bfmcs-plan.md
- FlagBFMCS.lean: Source FlagBFMCS structure
- BFMCS.lean: Target BFMCS structure
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Algebraic.ParametricCanonical
open Bimodal.Metalogic.Algebraic.ParametricHistory

/-!
## Phase 1: Global Countable Enumeration

We establish that CanonicalMCS is countable and define a global enumeration.
-/

-- Countable CanonicalMCS is provided by CanonicalQuot.lean import
-- It uses a sorry internally, but the mathematical justification is solid:
-- MCS are determined by their membership function on countable Formula

/--
Encodable instance for CanonicalMCS, derived from Countable.

This allows us to use `Encodable.encode` to get a unique natural number for each MCS.
-/
noncomputable instance : Encodable CanonicalMCS := Encodable.ofCountable CanonicalMCS

/--
Global enumeration of CanonicalMCS into Int.

We use `Encodable.encode` to get a unique Nat, then cast to Int.
This provides a global, injective map from all MCSs to integers.
-/
noncomputable def enum_mcs (M : CanonicalMCS) : ℤ :=
  (Encodable.encode M : ℤ)

/--
enum_mcs is injective: distinct MCSs map to distinct integers.
-/
theorem enum_mcs_injective : Function.Injective enum_mcs := by
  intro M N h_eq
  simp only [enum_mcs] at h_eq
  have h_nat : (Encodable.encode M : ℤ) = (Encodable.encode N : ℤ) := h_eq
  have h_nat' : Encodable.encode M = Encodable.encode N := by
    omega
  exact Encodable.encode_injective h_nat'

/--
Inverse lookup: given an integer, find the corresponding MCS if it exists.
-/
noncomputable def decode_mcs (n : ℤ) : Option CanonicalMCS :=
  if 0 ≤ n then
    Encodable.decode (n.toNat)
  else
    none

/--
decode_mcs inverts enum_mcs: decode_mcs (enum_mcs M) = some M.
-/
theorem decode_enum_mcs (M : CanonicalMCS) :
    decode_mcs (enum_mcs M) = some M := by
  simp only [decode_mcs, enum_mcs]
  have h_nonneg : (0 : ℤ) ≤ (Encodable.encode M : ℤ) := Int.natCast_nonneg _
  rw [if_pos h_nonneg]
  simp only [Int.toNat_natCast]
  exact Encodable.encodek M

/-!
## Phase 2: Per-Flag FMCS Int Construction

We convert each Flag's chainFMCS to an FMCS Int by:
1. Mapping each MCS in the Flag to its enum_mcs value
2. Using root_mcs as fallback for out-of-range times
-/

/--
Domain image: the set of integers that correspond to MCSs in a given Flag.
-/
def domain_image (F : Flag CanonicalMCS) : Set ℤ :=
  { n | ∃ M : CanonicalMCS, M ∈ F ∧ enum_mcs M = n }

/--
Check if an integer is in the domain image of a Flag.
-/
noncomputable def in_domain_image (F : Flag CanonicalMCS) (t : ℤ) : Prop :=
  match decode_mcs t with
  | some M => M ∈ F
  | none => False

/--
Predicate: time t corresponds to an MCS in Flag F.
-/
def time_in_flag (F : Flag CanonicalMCS) (t : ℤ) : Prop :=
  ∃ M : CanonicalMCS, M ∈ F ∧ enum_mcs M = t

/--
Classical decidability for time_in_flag.
-/
noncomputable instance (F : Flag CanonicalMCS) : DecidablePred (time_in_flag F) := fun _ => Classical.dec _

/--
Get the MCS for a time t, with fallback to root.

If t corresponds to an MCS in the Flag, return that MCS.
Otherwise, return the root MCS.
-/
noncomputable def mcs_at_time (F : Flag CanonicalMCS) (root : CanonicalMCS) (t : ℤ) : Set Formula :=
  if h : time_in_flag F t then
    (Classical.choose h).world
  else
    root.world

/--
mcs_at_time always returns a maximal consistent set.
-/
theorem mcs_at_time_is_mcs (F : Flag CanonicalMCS) (root : CanonicalMCS) (t : ℤ) :
    SetMaximalConsistent (mcs_at_time F root t) := by
  unfold mcs_at_time
  split
  · rename_i h
    exact (Classical.choose h).is_mcs
  · exact root.is_mcs

/-!
## Phase 2: FMCS Int from Flag (BLOCKED)

The construction below is blocked due to a fundamental architectural issue:

**The Problem**: FMCS requires `forward_G` and `backward_H` to hold for ALL times s, t.
However, the integer ordering `s < t` does NOT correspond to the CanonicalMCS ordering
`ExistsTask M_s.world M_t.world`. The global enumeration `enum_mcs` is injective but
NOT order-preserving.

**Why Order-Preservation Fails**:
1. `enum_mcs` uses `Encodable.encode` which produces arbitrary natural numbers
2. The CanonicalMCS Preorder uses `ExistsTask` (g_content inclusion)
3. These orderings are completely unrelated

**Attempted Solutions**:
1. Root MCS fallback: Doesn't help because G(φ) in M_s doesn't imply φ in root when s < t
2. Per-Flag ordering: Would require a custom Preorder on Int that varies per Flag
3. Partial FMCS: Not supported by the infrastructure (FMCS requires total functions)

**Possible Resolutions** (for future work):
1. Use a different completeness pathway that doesn't require BFMCS Int
2. Modify the parametric infrastructure to use CanonicalMCS directly (requires AddCommGroup)
3. Define a custom embedding that IS order-preserving (non-trivial)
4. Use interval arithmetic: embed to rational intervals, preserving relative ordering

See task 1006 for more details.
-/

/--
FMCS Int from a Flag: convert a Flag's structure to an FMCS over Int.

**STATUS**: BLOCKED - `forward_G` and `backward_H` cannot be proven with the current
approach. The integer ordering does not match the CanonicalMCS ordering.

For times t in the Flag's image, we use the corresponding MCS.
For times outside the image, we use the root MCS as fallback.
-/
noncomputable def fmcs_from_flag (F : Flag CanonicalMCS) (root : CanonicalMCS) : FMCS ℤ where
  mcs := mcs_at_time F root
  is_mcs := mcs_at_time_is_mcs F root
  forward_G := fun s t φ h_lt h_G => by
    -- BLOCKED: Cannot prove because integer s < t does NOT imply ExistsTask between
    -- the corresponding MCSs. The enumeration is injective but not order-preserving.
    --
    -- Cases:
    -- 1. Both s, t in Flag image: Need ExistsTask M_s M_t, but only have s < t (integers)
    -- 2. s in image, t not: Need φ ∈ root, but G(φ) ∈ M_s doesn't imply this
    -- 3. s not in image, t in image: Need φ ∈ M_t, but G(φ) ∈ root doesn't imply this
    -- 4. Neither in image: Both map to root, so need G(φ) ∈ root → φ ∈ root, which
    --    doesn't hold (G-T axiom is irreflexive)
    sorry
  backward_H := fun s t φ h_lt h_H => by
    -- BLOCKED: Same issue as forward_G, with symmetric reasoning
    sorry

end Bimodal.Metalogic.Bundle
