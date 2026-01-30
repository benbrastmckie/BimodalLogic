import Bimodal.Semantics
import Bimodal.Metalogic.FMP.FiniteWorldState
import Bimodal.Metalogic.FMP.BoundedTime
import Bimodal.Metalogic.FMP.SemanticCanonicalModel
import Mathlib.Data.Nat.Cast.Order.Ring

/-!
# Semantic Task Frame for Truth Correspondence

This module constructs a TaskFrame (with Int as time domain) from the semantic
world state construction. This enables bridging `valid` (universal validity)
to `semantic_weak_completeness` (truth at SemanticWorldStates).

## Overview

The key insight is that instead of trying to prove the forward truth lemma
(arbitrary model truth implies semantic truth, which is impossible), we:
1. Build a specific TaskModel from the SemanticWorldState construction
2. Prove truth correspondence IN THIS MODEL (both directions work)
3. Instantiate the universal `valid` quantification with this specific model

## Main Definitions

- `SemanticTaskFrame`: TaskFrame with Int time domain and FiniteWorldState worlds
- `SemanticTaskModel`: Model with valuation from FiniteWorldState.models
- `worldStateToHistory`: Maps SemanticWorldState to WorldHistory

## Design Notes

- Uses `Int` as the time domain (required by `valid` which needs AddCommGroup)
- BoundedTime is Fin (2*k+1), which is not a group, so cannot be used directly
- Histories have domain limited to bounded range [-k, k] for temporal depth k
- The task relation is trivially true (all transitions allowed) for simplicity

## References

- Task 779: Research on bridging valid to semantic_weak_completeness
- Task 776: Metalogic refactoring
-/

namespace Bimodal.Metalogic.FMP

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics

/-!
## Semantic Task Frame

A task frame built specifically for the truth correspondence proof.
We use Int as the time domain because valid requires an AddCommGroup.
-/

/--
Semantic task frame for a formula phi.

The frame has:
- `Int` as the time domain (required by valid's polymorphic quantification)
- `FiniteWorldState phi` as world states (finite, decidable)
- Trivial task relation (all transitions allowed)

The trivial task relation works because we only need to show that
truth_at in THIS specific model corresponds to semantic_truth_at_v2.
-/
def SemanticTaskFrame (phi : Formula) : TaskFrame Int where
  WorldState := FiniteWorldState phi
  task_rel := fun _ _ _ => True
  nullity := fun _ => trivial
  compositionality := fun _ _ _ _ _ _ _ => trivial

/--
Semantic task model for a formula phi.

The valuation queries the FiniteWorldState.models function:
- For atoms in the closure, returns the world state's truth assignment
- For atoms outside the closure, returns false
-/
noncomputable def SemanticTaskModel (phi : Formula) : TaskModel (SemanticTaskFrame phi) where
  valuation := fun w p =>
    if h : Formula.atom p ∈ closure phi
    then w.models (Formula.atom p) h
    else False

/-!
## World State to History Mapping

We need to map SemanticWorldStates to WorldHistories. The key insight is that
we use a constant history: the same world state at all times in the bounded range.
-/

/--
The bounded domain predicate: times in range [-k, k].
-/
def boundedDomain (k : Nat) (t : Int) : Prop :=
  -(k : Int) ≤ t ∧ t ≤ (k : Int)

/--
The bounded domain is convex (no gaps).
-/
theorem boundedDomain_convex (k : Nat) (x z : Int)
    (hx : boundedDomain k x) (hz : boundedDomain k z)
    (y : Int) (hxy : x ≤ y) (hyz : y ≤ z) : boundedDomain k y := by
  constructor
  · exact le_trans hx.1 hxy
  · exact le_trans hyz hz.2

/--
The origin (0) is in the bounded domain for any k.
-/
theorem origin_in_boundedDomain (k : Nat) : boundedDomain k 0 := by
  constructor
  · simp only [Left.neg_nonpos_iff]
    exact Nat.cast_nonneg' k
  · exact Nat.cast_nonneg' k

/--
Convert a SemanticWorldState to a constant WorldHistory.

The history:
- Has domain {t : Int | -k ≤ t ≤ k} where k = temporalBound phi
- Maps every time in domain to the same world state
- Trivially respects the task relation (which is always true)
-/
def worldStateToHistory (phi : Formula) (sw : SemanticWorldState phi) :
    WorldHistory (SemanticTaskFrame phi) where
  domain := boundedDomain (temporalBound phi)
  convex := boundedDomain_convex (temporalBound phi)
  states := fun _ _ => SemanticWorldState.toFiniteWorldState sw
  respects_task := fun _ _ _ _ _ => trivial

/--
The origin is in the domain of worldStateToHistory.
-/
theorem worldStateToHistory_domain_origin (phi : Formula) (sw : SemanticWorldState phi) :
    (worldStateToHistory phi sw).domain 0 :=
  origin_in_boundedDomain (temporalBound phi)

/--
The state at origin equals the underlying FiniteWorldState.
-/
theorem worldStateToHistory_states_origin (phi : Formula) (sw : SemanticWorldState phi) :
    (worldStateToHistory phi sw).states 0 (worldStateToHistory_domain_origin phi sw) =
    SemanticWorldState.toFiniteWorldState sw := rfl

/-!
## History from Arbitrary World State

We also need to construct histories from arbitrary FiniteWorldStates (not just
SemanticWorldStates). This is needed for the box case of truth correspondence.
-/

/--
Convert a FiniteWorldState to a constant WorldHistory.
-/
def finiteWorldStateToHistory (phi : Formula) (w : FiniteWorldState phi) :
    WorldHistory (SemanticTaskFrame phi) where
  domain := boundedDomain (temporalBound phi)
  convex := boundedDomain_convex (temporalBound phi)
  states := fun _ _ => w
  respects_task := fun _ _ _ _ _ => trivial

/--
Domain membership for finiteWorldStateToHistory.
-/
theorem finiteWorldStateToHistory_domain_origin (phi : Formula) (w : FiniteWorldState phi) :
    (finiteWorldStateToHistory phi w).domain 0 :=
  origin_in_boundedDomain (temporalBound phi)

/-!
## Bounded Time to Int Conversion

For correspondence proofs, we need to relate BoundedTime values to Int.
-/

/--
A BoundedTime value is in the bounded domain when converted to Int.
-/
theorem boundedTime_toInt_in_domain (phi : Formula)
    (t : BoundedTime (temporalBound phi)) :
    boundedDomain (temporalBound phi) t.toInt := by
  exact BoundedTime.toInt_range t

/--
Int value in bounded domain can be converted to BoundedTime.
-/
noncomputable def intToBoundedTime (phi : Formula) (t : Int)
    (h : boundedDomain (temporalBound phi) t) : BoundedTime (temporalBound phi) :=
  let k := temporalBound phi
  -- t is in [-k, k], so t + k is in [0, 2k]
  let i := t + k
  have hi_nonneg : 0 ≤ i := by
    have := h.1
    omega
  have hi_bound : i < 2 * (k : Int) + 1 := by
    have := h.2
    omega
  ⟨i.toNat, by
    have h1 : (i.toNat : Int) = i := Int.toNat_of_nonneg hi_nonneg
    have h2 : i.toNat < 2 * k + 1 := by omega
    exact h2⟩

/--
Round-trip: intToBoundedTime followed by toInt returns the original value.
-/
theorem intToBoundedTime_toInt (phi : Formula) (t : Int)
    (h : boundedDomain (temporalBound phi) t) :
    (intToBoundedTime phi t h).toInt = t := by
  unfold intToBoundedTime BoundedTime.toInt
  simp only
  have h1 : 0 ≤ t + (temporalBound phi : Int) := by
    have := h.1
    omega
  simp only [Int.toNat_of_nonneg h1]
  omega

/-!
## Model Properties

Basic properties of the semantic task model.
-/

/--
The valuation returns the FiniteWorldState.models value for atoms in closure.
-/
theorem SemanticTaskModel_valuation_of_mem (phi : Formula)
    (w : FiniteWorldState phi) (p : String)
    (h : Formula.atom p ∈ closure phi) :
    (SemanticTaskModel phi).valuation w p ↔ w.models (Formula.atom p) h := by
  unfold SemanticTaskModel
  simp only [dif_pos h]

/--
The valuation returns False for atoms outside the closure.
-/
theorem SemanticTaskModel_valuation_of_not_mem (phi : Formula)
    (w : FiniteWorldState phi) (p : String)
    (h : Formula.atom p ∉ closure phi) :
    (SemanticTaskModel phi).valuation w p = False := by
  unfold SemanticTaskModel
  simp only [dif_neg h]

end Bimodal.Metalogic.FMP
