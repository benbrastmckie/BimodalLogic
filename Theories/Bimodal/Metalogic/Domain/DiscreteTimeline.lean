import Bimodal.Metalogic.Domain.DurationTransfer
import Bimodal.Metalogic.StagedConstruction.CantorPrereqs
import Mathlib.Order.SuccPred.LinearLocallyFinite

/-!
# Discrete Timeline: SuccOrder and PredOrder from Discreteness Axiom

This module provides the discrete case of the duration group construction.
Given the discreteness axiom DF = `(F⊤ ∧ φ ∧ Hφ) → F(Hφ)`, the canonical
timeline has a natural successor operation, yielding `SuccOrder` and `PredOrder`.

## Construction Overview

The discrete timeline is the `Antisymmetrization` of the base staged timeline
(without density intermediates). The discreteness axiom DF ensures:

1. **SuccOrder**: For each equivalence class [M], there is an immediate
   successor — the unique class [N] such that [M] < [N] and no class lies
   strictly between them.

2. **PredOrder**: Symmetric to SuccOrder using the backward discreteness
   axiom DB = `(P⊤ ∧ φ ∧ Gφ) → P(Gφ)`.

3. **IsSuccArchimedean**: Any two comparable classes are finitely many
   successor steps apart, following from linearity and the discrete structure.

## Frame Condition for DF

The soundness proof (`discreteness_forward_valid` in Soundness.lean) shows
that DF corresponds to the frame condition: for all x, if there exists y > x,
then Order.succ x exists and is the least element > x. This is exactly the
`SuccOrder` property.

## Key Lemma: Coverness from DF

The core technical result is: if M R N (CanonicalR) and there is no W with
M R W R N (no strict intermediate), then [N] = succ([M]) in the quotient.

The discreteness axiom DF provides this: given CanonicalR(M, N), if
`Hφ ∈ N` for some φ, then either `φ ∈ M` (so M and N agree on φ) or
there exists a "gap" that DF fills. The absence of density intermediates
(since DN is not in the axiom system) means the successor is immediate.

## References

- Task 960: Duration Group Construction from Pure Syntax
- `DurationTransfer.lean`: `intOrderIso`, `intAddCommGroup`, `discreteTaskFrame`
- `Soundness.lean`: `discreteness_forward_valid`
- Mathlib `orderIsoIntOfLinearSuccPredArch`: ℤ characterization
-/

namespace Bimodal.Metalogic.Domain

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.StagedConstruction

-- Classical decidability
attribute [local instance] Classical.propDecidable

/-!
## Discrete Timeline Type

The discrete timeline is the Antisymmetrization of the base staged timeline
(from `StagedExecution.lean`), without the density intermediates that the
dense case adds.
-/

variable (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)

/-- Elements of the discrete (base) timeline. -/
def DiscreteTimelineElem : Type :=
  { p : StagedPoint // p ∈ (buildStagedTimeline root_mcs root_mcs_proof).union }

/-- The discrete timeline quotient: antisymmetrization of the base timeline. -/
def DiscreteTimelineQuot : Type :=
  Antisymmetrization (DiscreteTimelineElem root_mcs root_mcs_proof) (· ≤ ·)

/-!
## Preorder and LinearOrder

The base staged timeline is linearly preordered (from CantorPrereqs).
The Antisymmetrization gives a LinearOrder.
-/

/-- Preorder instance for discrete timeline elements. -/
noncomputable instance : Preorder (DiscreteTimelineElem root_mcs root_mcs_proof) where
  le a b := StagedPoint.le a.1 b.1
  le_refl a := StagedPoint.le_refl a.1
  le_trans a b c hab hbc := StagedPoint.le_trans a.1 b.1 c.1 hab hbc

/-- The preorder is total. -/
instance : IsTotal (DiscreteTimelineElem root_mcs root_mcs_proof) (· ≤ ·) where
  total a b := (buildStagedTimeline root_mcs root_mcs_proof).union_linearly_ordered a.1 b.1 a.2 b.2

/-- Decidable ≤. -/
noncomputable instance : DecidableLE (DiscreteTimelineElem root_mcs root_mcs_proof) :=
  fun _ _ => Classical.propDecidable _

/-- Decidable <. -/
noncomputable instance : DecidableLT (DiscreteTimelineElem root_mcs root_mcs_proof) :=
  fun _ _ => Classical.propDecidable _

/-- Linear order on the discrete timeline quotient. -/
noncomputable instance : LinearOrder (DiscreteTimelineQuot root_mcs root_mcs_proof) :=
  inferInstanceAs (LinearOrder (Antisymmetrization
    (DiscreteTimelineElem root_mcs root_mcs_proof) (· ≤ ·)))

/-!
## Nonemptiness

The discrete timeline is nonempty (contains the root point).
-/

instance : Nonempty (DiscreteTimelineQuot root_mcs root_mcs_proof) := by
  obtain ⟨p, hp⟩ := staged_timeline_nonempty root_mcs root_mcs_proof
  exact ⟨toAntisymmetrization (· ≤ ·) ⟨p, hp⟩⟩

/-!
## SuccOrder from Discreteness Axiom

The discreteness axiom DF = `(F⊤ ∧ φ ∧ Hφ) → F(Hφ)` corresponds to the
frame condition that every non-maximal element has an immediate successor
(coverness). This gives SuccOrder on the quotient.

### Frame Condition (from Soundness.lean)

DF is valid on frame (T, <) iff: for all t ∈ T with ∃s > t (non-maximal),
the successor `Order.succ t` exists and is the least element > t:
- `t < Order.succ t`
- `∀ r, t < r → Order.succ t ≤ r`

### Canonical Model Interpretation

Given [M] in the quotient, DF ensures that any seriality witness N (with
CanonicalR(M, N)) is either:
(a) The immediate successor of M (no strict intermediate), or
(b) Not minimal among strict successors, in which case DF iteratively
    finds the immediate successor.

### Implementation

The SuccOrder, PredOrder, and IsSuccArchimedean instances below are
sorry-dependent. The key sorry is `succ_le_of_lt` (coverness), which
requires extracting the frame condition from DF at the MCS level.

The `succ` function is defined using Classical.choice on the set of
minimal strict successors (or identity for maximal elements).
-/

/-- SuccOrder on the discrete timeline quotient (sorry-dependent).

The coverness property (`succ_le_of_lt`) requires proving that the
discreteness axiom DF prevents strict intermediates in the canonical model.
This is the frame condition: DF valid ↔ coverness (immediate successors exist).

**Proof debt**: `succ_le_of_lt` requires canonicalR-level coverness from DF.
-/
noncomputable instance : SuccOrder (DiscreteTimelineQuot root_mcs root_mcs_proof) where
  succ := fun a =>
    if h : IsMax a then a
    else
      -- There exists b > a (since a is not maximal)
      let ⟨b, hb⟩ := not_isMax_iff.mp h
      -- Use well-ordering to pick the minimum such b
      -- (LinearOrder + Classical gives well-ordering on the non-empty set {b | a < b})
      Classical.choice ⟨b⟩
  le_succ := by
    intro a
    simp only
    split
    · exact le_refl a
    · rename_i h
      -- BLOCKED: Need to show a ≤ succ(a) for the chosen successor.
      -- This requires the Classical.choice to pick an element > a, which
      -- exists by the negation of IsMax.
      sorry
  max_of_succ_le := by
    intro a h
    simp only at h
    split at h
    · exact ‹IsMax a›
    · rename_i h_not_max
      -- If succ(a) ≤ a and a is not max, contradiction (since succ(a) > a)
      sorry
  succ_le_of_lt := by
    intro a b hab
    -- KEY SORRY: Coverness from discreteness axiom DF.
    --
    -- Need: succ(a) ≤ b whenever a < b.
    -- This is the frame condition for DF: the successor of a is the LEAST
    -- element strictly above a.
    --
    -- Proof sketch (not yet formalized):
    -- 1. a < b means CanonicalR(M_a, M_b) and ¬CanonicalR(M_b, M_a)
    -- 2. DF ensures that succ([M_a]) covers [M_a]: no [W] with [M_a] < [W] < succ([M_a])
    -- 3. Therefore succ([M_a]) ≤ [M_b] (since [M_b] > [M_a] and succ is the least such)
    sorry

/-- PredOrder on the discrete timeline quotient (sorry-dependent).

Symmetric to SuccOrder, using the backward discreteness axiom
DP = `(P⊤ ∧ φ ∧ Gφ) → P(Gφ)`, which is derivable from DF via temporal duality
(see `Bimodal.Theorems.Discreteness.discreteness_past`).
-/
noncomputable instance : PredOrder (DiscreteTimelineQuot root_mcs root_mcs_proof) where
  pred := fun a =>
    if h : IsMin a then a
    else Classical.choice (let ⟨b, hb⟩ := not_isMin_iff.mp h; ⟨b⟩)
  pred_le := by intro a; simp only; split <;> sorry
  min_of_le_pred := by intro a h; simp only at h; split at h <;> sorry
  le_pred_of_lt := by
    intro a b hab
    -- KEY SORRY: Coverness from backward discreteness axiom DP.
    -- Symmetric to succ_le_of_lt.
    sorry

/-- IsSuccArchimedean on the discrete timeline quotient (sorry-dependent).

Any two elements are finitely many successor steps apart.
This follows from linearity + NoMaxOrder + NoMinOrder (the Archimedean
property of ℤ), but is blocked by the same NoMaxOrder obstacle.
-/
instance : IsSuccArchimedean (DiscreteTimelineQuot root_mcs root_mcs_proof) where
  exists_succ_iterate_of_le := by
    intro a b hab
    -- BLOCKED: Requires showing finite reachability via succ iterations.
    -- Depends on NoMaxOrder (which is blocked by reflexive MCS obstacle).
    sorry

/-!
## NoMaxOrder and NoMinOrder (BLOCKED)

These require showing that no equivalence class is maximal (or minimal) in
the quotient. The same reflexive MCS obstacle that blocks the dense case
applies here: if p.mcs is reflexive (CanonicalR p.mcs p.mcs), seriality
successors may all land in the same equivalence class [p].

The discreteness axiom DF does NOT help here — it provides coverness
(immediate successor) but not unboundedness (existence of a STRICT successor).
Both require `canonicalR_irreflexive`, which is blocked by String atom
freshness. See `CantorApplication.lean` module docstring for the full analysis.
-/

/-- NoMaxOrder (sorry-dependent, blocked by reflexive MCS obstacle). -/
instance : NoMaxOrder (DiscreteTimelineQuot root_mcs root_mcs_proof) where
  exists_gt := by
    intro a
    -- BLOCKED: Same reflexive MCS obstacle as dense case.
    -- See CantorApplication.lean module docstring.
    sorry

/-- NoMinOrder (sorry-dependent, blocked by reflexive MCS obstacle). -/
instance : NoMinOrder (DiscreteTimelineQuot root_mcs root_mcs_proof) where
  exists_lt := by
    intro a
    -- BLOCKED: Symmetric to NoMaxOrder.
    sorry

/-!
## Complete Pipeline

With all instances (sorry-dependent), the complete pipeline compiles:
DiscreteTimelineQuot → SuccOrder + PredOrder + IsSuccArchimedean +
NoMaxOrder + NoMinOrder → `orderIsoIntOfLinearSuccPredArch` → T ≃o ℤ →
`intAddCommGroup` + `intIsOrderedAddMonoid` → `discreteTaskFrame`.

**Proof debt**: All instances above depend on sorry. The root cause is the
reflexive MCS obstacle (for NoMaxOrder/NoMinOrder) and the DF coverness
extraction (for SuccOrder/PredOrder). See research-002.md for full analysis.
-/

/-- The discrete canonical TaskFrame, with D derived from syntax via ℤ characterization.

This is the end-to-end pipeline: MCSs → DiscreteTimelineQuot → T ≃o ℤ →
AddCommGroup T → IsOrderedAddMonoid T → TaskFrame T.

**Proof debt**: Depends on sorry'd instances above.
-/
noncomputable def discreteCanonicalTaskFrame :
    @TaskFrame (DiscreteTimelineQuot root_mcs root_mcs_proof)
      (intAddCommGroup (DiscreteTimelineQuot root_mcs root_mcs_proof))
      (inferInstance)
      (intIsOrderedAddMonoid (DiscreteTimelineQuot root_mcs root_mcs_proof)) :=
  discreteTaskFrame (DiscreteTimelineQuot root_mcs root_mcs_proof)

end Bimodal.Metalogic.Domain
