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
## SuccOrder from Discreteness Axiom (TODO)

The key construction: define `Order.succ` on `DiscreteTimelineQuot` using
the immediate successor in the canonical relation.

Given [M] in the quotient, the successor is the unique [N] such that:
- CanonicalR(M, N) (N is a future of M)
- There is no W with CanonicalR(M, W) ∧ CanonicalR(W, N) ∧ [W] ≠ [M] ∧ [W] ≠ [N]
  (N is the IMMEDIATE future, no strict intermediate exists)

The discreteness axiom DF ensures this immediate successor exists and is unique
(up to equivalence).

### Proof Strategy

1. From seriality: F(⊤) ∈ M, so ∃N with CanonicalR(M, N)
2. If all intermediates are equivalent to M or N, then [N] = succ([M])
3. If an intermediate [W] exists with [M] < [W] < [N], iterate to find
   the immediate successor. By well-foundedness (Noetherian argument on
   the finite number of formulas distinguishing MCSs), this terminates.
4. The discreteness axiom DF ensures that the coverness property holds
   in the canonical model.

### Implementation Plan

```
noncomputable instance : SuccOrder (DiscreteTimelineQuot root_mcs root_mcs_proof) where
  succ := fun a => ...  -- immediate successor in the quotient
  le_succ := ...        -- a ≤ succ(a)
  max_of_succ_le := ... -- if succ(a) ≤ a then a is max (vacuous: NoMaxOrder)
  succ_le_of_lt := ...  -- a < b → succ(a) ≤ b (coverness)
```

Similarly for PredOrder and IsSuccArchimedean.
-/

-- Placeholder: SuccOrder construction requires the coverness proof from DF
-- This is the main technical challenge for the discrete case.

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

/-!
## Complete Pipeline (Pending)

Once SuccOrder, PredOrder, IsSuccArchimedean, NoMaxOrder, NoMinOrder are
established, the complete pipeline is:

```
noncomputable def discreteCanonicalTaskFrame :
    @TaskFrame (DiscreteTimelineQuot root_mcs root_mcs_proof)
      (intAddCommGroup (DiscreteTimelineQuot root_mcs root_mcs_proof))
      (inferInstance)
      (intIsOrderedAddMonoid (DiscreteTimelineQuot root_mcs root_mcs_proof)) :=
  discreteTaskFrame (DiscreteTimelineQuot root_mcs root_mcs_proof)
```
-/

end Bimodal.Metalogic.Domain
