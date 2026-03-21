import Bimodal.Metalogic.Bundle.SuccChainFMCS
import Bimodal.Semantics.TaskFrame

/-!
# CanonicalTask TaskFrame Instantiation

This module instantiates the TaskFrame structure using the CanonicalTask relation
from Task 11 (CanonicalTaskRelation.lean). The TaskFrame uses:
- WorldState := Set Formula (MCS states)
- task_rel := CanonicalTask
- Time type := Int

## Main Definitions

- `CanonicalTaskTaskFrame`: TaskFrame Int with CanonicalTask as task relation

## Axioms Required

The TaskFrame axioms (nullity_identity, forward_comp, converse) are derived from
the corresponding CanonicalTask theorems proven in CanonicalTaskRelation.lean.

## References

- Task 11: CanonicalTaskRelation.lean - CanonicalTask definition and axioms
- Task 14: SuccChainFMCS.lean - FMCS family construction
- Bimodal.Semantics.TaskFrame - TaskFrame structure definition
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Semantics

/-!
## TaskFrame Instantiation

We create a TaskFrame over Int using CanonicalTask as the task relation.
The world states are maximal consistent sets (Set Formula).
-/

/--
CanonicalTask satisfies nullity identity: CanonicalTask w 0 u ↔ w = u.

This is directly `CanonicalTask_nullity_identity` from CanonicalTaskRelation.lean.
-/
theorem CanonicalTask_nullity_for_frame (w u : Set Formula) :
    CanonicalTask w 0 u ↔ w = u :=
  CanonicalTask_nullity_identity w u

/--
CanonicalTask satisfies forward compositionality for non-negative durations.

For x, y ≥ 0 (as Int), if CanonicalTask w x u and CanonicalTask u y v,
then CanonicalTask w (x + y) v.

We convert from Nat-based forward_comp to Int-based forward_comp.
-/
theorem CanonicalTask_forward_comp_for_frame (w u v : Set Formula) (x y : Int)
    (hx : 0 ≤ x) (hy : 0 ≤ y)
    (h1 : CanonicalTask w x u) (h2 : CanonicalTask u y v) :
    CanonicalTask w (x + y) v := by
  -- Convert x and y to Nat
  obtain ⟨xn, hxn⟩ := Int.eq_ofNat_of_zero_le hx
  obtain ⟨yn, hyn⟩ := Int.eq_ofNat_of_zero_le hy
  subst hxn hyn
  -- Use CanonicalTask_forward_comp_int
  have h_eq : ((xn + yn : Nat) : Int) = (xn : Int) + (yn : Int) := by omega
  rw [← h_eq]
  exact CanonicalTask_forward_comp_int w u v xn yn h1 h2

/--
CanonicalTask satisfies converse: CanonicalTask w d u ↔ CanonicalTask u (-d) w.

This is directly `CanonicalTask_converse` from CanonicalTaskRelation.lean.
-/
theorem CanonicalTask_converse_for_frame (w : Set Formula) (d : Int) (u : Set Formula) :
    CanonicalTask w d u ↔ CanonicalTask u (-d) w :=
  CanonicalTask_converse w u d

/--
The CanonicalTask TaskFrame over Int.

This packages the CanonicalTask relation as a TaskFrame satisfying
the three axioms: nullity_identity, forward_comp, and converse.

**WorldState**: Set Formula (maximal consistent sets)
**task_rel**: CanonicalTask w n u (w reaches u in n steps via Succ chain)
**Time type**: Int (discrete integer time)
-/
def CanonicalTaskTaskFrame : TaskFrame Int where
  WorldState := Set Formula
  task_rel := CanonicalTask
  nullity_identity := CanonicalTask_nullity_for_frame
  forward_comp := CanonicalTask_forward_comp_for_frame
  converse := CanonicalTask_converse_for_frame

end Bimodal.Metalogic.Bundle
