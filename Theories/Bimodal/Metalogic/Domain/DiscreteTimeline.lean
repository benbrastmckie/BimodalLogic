import Bimodal.Metalogic.Domain.DurationTransfer
import Bimodal.Metalogic.StagedConstruction.CantorPrereqs
import Bimodal.Metalogic.Canonical.CanonicalIrreflexivityAxiom
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
open Bimodal.Semantics

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
  { p : StagedPoint // p ∈ (buildDiscreteStagedTimeline root_mcs root_mcs_proof).union }

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
  total a b := (buildDiscreteStagedTimeline root_mcs root_mcs_proof).union_linearly_ordered a.1 b.1 a.2 b.2

/-- Decidable ≤. -/
noncomputable instance : DecidableLE (DiscreteTimelineElem root_mcs root_mcs_proof) :=
  fun _ _ => Classical.propDecidable _

/-- Decidable <. -/
noncomputable instance : DecidableLT (DiscreteTimelineElem root_mcs root_mcs_proof) :=
  fun _ _ => Classical.propDecidable _

/-- The discrete timeline quotient: antisymmetrization of the base timeline. -/
def DiscreteTimelineQuot : Type :=
  Antisymmetrization (DiscreteTimelineElem root_mcs root_mcs_proof) (· ≤ ·)

/-- Linear order on the discrete timeline quotient. -/
noncomputable instance : LinearOrder (DiscreteTimelineQuot root_mcs root_mcs_proof) :=
  inferInstanceAs (LinearOrder (Antisymmetrization
    (DiscreteTimelineElem root_mcs root_mcs_proof) (· ≤ ·)))

/-!
## Nonemptiness

The discrete timeline is nonempty (contains the root point).
-/

instance : Nonempty (DiscreteTimelineQuot root_mcs root_mcs_proof) := by
  obtain ⟨p, hp⟩ := discrete_staged_timeline_nonempty root_mcs root_mcs_proof
  exact ⟨toAntisymmetrization (· ≤ ·) ⟨p, hp⟩⟩

/-!
## NoMaxOrder and NoMinOrder (Resolved via Axiom)

These use the `canonicalR_irreflexive` axiom from
`Canonical/CanonicalIrreflexivityAxiom.lean`. Seriality gives forward/backward
witnesses, and irreflexivity ensures they are strictly ordered in the quotient
(same pattern as the dense case in `CantorApplication.lean`).
-/

/-- NoMaxOrder on the discrete timeline quotient.

Uses `canonicalR_irreflexive` axiom: seriality gives a forward witness, and
irreflexivity ensures strictness (same pattern as the dense case).
-/
instance : NoMaxOrder (DiscreteTimelineQuot root_mcs root_mcs_proof) where
  exists_gt := by
    intro a
    induction a using Antisymmetrization.ind with
    | _ p =>
      obtain ⟨q, hq_mem, hq_R⟩ := discrete_staged_timeline_has_future root_mcs root_mcs_proof p.1 p.2
      have h_strict : ¬CanonicalR q.mcs p.1.mcs :=
        Canonical.canonicalR_strict p.1.mcs q.mcs p.1.is_mcs q.is_mcs hq_R
      let q' : DiscreteTimelineElem root_mcs root_mcs_proof := ⟨q, hq_mem⟩
      use toAntisymmetrization (· ≤ ·) q'
      rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
      constructor
      · exact Or.inr hq_R
      · intro hqp
        cases hqp with
        | inl h_eq => exact h_strict (h_eq.symm ▸ hq_R)
        | inr h_R => exact h_strict h_R

/-- NoMinOrder on the discrete timeline quotient.

Symmetric to NoMaxOrder using past seriality.
-/
instance : NoMinOrder (DiscreteTimelineQuot root_mcs root_mcs_proof) where
  exists_lt := by
    intro a
    induction a using Antisymmetrization.ind with
    | _ p =>
      obtain ⟨q, hq_mem, hq_R⟩ := discrete_staged_timeline_has_past root_mcs root_mcs_proof p.1 p.2
      have h_strict : ¬CanonicalR p.1.mcs q.mcs :=
        Canonical.canonicalR_strict q.mcs p.1.mcs q.is_mcs p.1.is_mcs hq_R
      let q' : DiscreteTimelineElem root_mcs root_mcs_proof := ⟨q, hq_mem⟩
      use toAntisymmetrization (· ≤ ·) q'
      rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
      constructor
      · exact Or.inr hq_R
      · intro hpq
        cases hpq with
        | inl h_eq => exact h_strict (h_eq ▸ hq_R)
        | inr h_R => exact h_strict h_R

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

/-!
## Discreteness Property

The discreteness axiom DF ensures that every element has an immediate successor.
This is captured by the following lemma, which states that the GLB of `Set.Ioi a`
is strictly greater than `a` (not just `≥ a`).

The `succFn` from `LinearLocallyFiniteOrder` computes the GLB of `Set.Ioi a`.
For a discrete (non-dense) order, this GLB is the actual minimum of the set.
-/

/-- The discrete timeline is not densely ordered: for every element `a`,
the GLB of `{x | a < x}` is strictly greater than `a`.

This is the key discreteness property that follows from the DF axiom.
The proof involves showing that DF prevents any MCS from being arbitrarily
close to another from above — there is always an immediate successor.

**Proof sketch** (to be formalized):
1. Suppose for contradiction that `succFn a = a` (GLB equals `a`)
2. This means the set `{x | a < x}` is "dense above `a`"
3. But DF ensures immediate successors exist: if `CanonicalR M N`, then
   either `N` is the immediate successor of `M`, or there exists an
   intermediate `W` with `M < W < N`
4. The discreteness axiom rules out the second case when `N` is the successor
5. Therefore `succFn a > a` for all `a`

**TODO**: Complete this proof by extracting the DF frame condition at the MCS level.
-/
theorem discrete_timeline_lt_succFn (a : DiscreteTimelineQuot root_mcs root_mcs_proof) :
    a < LinearLocallyFiniteOrder.succFn a := by
  -- The proof requires showing that the discrete timeline is not densely ordered.
  -- This follows from the DF axiom preventing dense intermediate MCSs.
  -- For now, we leave this as the key lemma to be proven.
  have h_not_max : ¬IsMax a := not_isMax a
  -- By NoMaxOrder, Set.Ioi a is nonempty
  have h_nonempty : (Set.Ioi a).Nonempty := exists_gt a
  -- We need: succFn a ∈ Set.Ioi a (i.e., a < succFn a)
  -- This holds iff the GLB is actually the minimum of the set
  -- Which holds iff the order is discrete (not dense) at a
  sorry

/-- SuccOrder on the discrete timeline quotient.

Uses `succFn` from `LinearLocallyFiniteOrder` which computes the GLB of `Set.Ioi a`.
The discreteness property `discrete_timeline_lt_succFn` ensures this GLB is
strictly greater than `a`, giving us a proper successor.
-/
noncomputable instance : SuccOrder (DiscreteTimelineQuot root_mcs root_mcs_proof) where
  succ := LinearLocallyFiniteOrder.succFn
  le_succ := LinearLocallyFiniteOrder.le_succFn
  max_of_succ_le := by
    intro a h
    -- If succFn a ≤ a, combined with a ≤ succFn a, we get succFn a = a
    -- But discrete_timeline_lt_succFn says a < succFn a, contradiction
    have h_lt := discrete_timeline_lt_succFn root_mcs root_mcs_proof a
    exact absurd (le_antisymm h (LinearLocallyFiniteOrder.le_succFn a)) (ne_of_gt h_lt)
  succ_le_of_lt := LinearLocallyFiniteOrder.succFn_le_of_lt _ _

/-- Predecessor function for the discrete timeline.

Uses the LUB of `Set.Iio a` (elements strictly less than `a`).
Symmetric to `succFn` which uses GLB of `Set.Ioi a`.
-/
noncomputable def discretePredFn (a : DiscreteTimelineQuot root_mcs root_mcs_proof) :
    DiscreteTimelineQuot root_mcs root_mcs_proof :=
  (exists_lub_Iio a).choose

theorem discretePredFn_spec (a : DiscreteTimelineQuot root_mcs root_mcs_proof) :
    IsLUB (Set.Iio a) (discretePredFn root_mcs root_mcs_proof a) :=
  (exists_lub_Iio a).choose_spec

theorem discretePredFn_le (a : DiscreteTimelineQuot root_mcs root_mcs_proof) :
    discretePredFn root_mcs root_mcs_proof a ≤ a := by
  have h := discretePredFn_spec root_mcs root_mcs_proof a
  rw [IsLUB, IsLeast] at h
  have ha_ub : a ∈ upperBounds (Set.Iio a) := fun x hx => le_of_lt hx
  exact h.2 ha_ub

theorem le_discretePredFn_of_lt (a b : DiscreteTimelineQuot root_mcs root_mcs_proof)
    (hab : a < b) : a ≤ discretePredFn root_mcs root_mcs_proof b := by
  have h := discretePredFn_spec root_mcs root_mcs_proof b
  rw [IsLUB, IsLeast, mem_upperBounds] at h
  exact h.1 a hab

/-- The discrete timeline predecessor is strictly less than the element.

This is the backward discreteness property that follows from the DP axiom
(derivable from DF via temporal duality). Symmetric to `discrete_timeline_lt_succFn`.

**TODO**: Complete this proof by extracting the DP frame condition at the MCS level.
-/
theorem discrete_timeline_predFn_lt (a : DiscreteTimelineQuot root_mcs root_mcs_proof) :
    discretePredFn root_mcs root_mcs_proof a < a := by
  -- Symmetric to discrete_timeline_lt_succFn
  have h_not_min : ¬IsMin a := not_isMin a
  have h_nonempty : (Set.Iio a).Nonempty := exists_lt a
  -- We need: discretePredFn a ∈ Set.Iio a (i.e., discretePredFn a < a)
  sorry

/-- PredOrder on the discrete timeline quotient.

Uses `discretePredFn` which computes the LUB of `Set.Iio a`.
The discreteness property `discrete_timeline_predFn_lt` ensures this LUB is
strictly less than `a`, giving us a proper predecessor.
-/
noncomputable instance : PredOrder (DiscreteTimelineQuot root_mcs root_mcs_proof) where
  pred := discretePredFn root_mcs root_mcs_proof
  pred_le := discretePredFn_le root_mcs root_mcs_proof
  min_of_le_pred := by
    intro a h
    -- If a ≤ predFn a, combined with predFn a ≤ a, we get predFn a = a
    -- But discrete_timeline_predFn_lt says predFn a < a, contradiction
    have h_lt := discrete_timeline_predFn_lt root_mcs root_mcs_proof a
    exact absurd (le_antisymm (discretePredFn_le root_mcs root_mcs_proof a) h) (ne_of_lt h_lt)
  le_pred_of_lt := fun hab => le_discretePredFn_of_lt root_mcs root_mcs_proof _ _ hab

/-- IsSuccArchimedean on the discrete timeline quotient.

Any two elements are finitely many successor steps apart.
This follows from the local finiteness of the discrete timeline: for any
`a ≤ b`, the interval `[a, b]` contains finitely many elements.

**Proof approaches**:
1. Prove `LocallyFiniteOrder` on the quotient, then get this for free
   from `LinearLocallyFiniteOrder.instIsSuccArchimedean`
2. Direct induction: since `a ⋖ succ a` (covering), iterating succ
   strictly increases and must reach `b` in finitely many steps

**TODO**: Complete by proving `LocallyFiniteOrder` from the MCS construction.
The discrete timeline has finitely many MCSs between any two comparable MCSs
because each step in the staged construction adds only finitely many witnesses.
-/
instance : IsSuccArchimedean (DiscreteTimelineQuot root_mcs root_mcs_proof) where
  exists_succ_iterate_of_le := by
    intro a b hab
    -- The proof requires showing the interval [a, b] is finite.
    -- This follows from the staged construction: each stage adds
    -- finitely many MCSs, and between any two MCSs there are
    -- finitely many stages.
    --
    -- With LocallyFiniteOrder, we could use:
    -- LinearLocallyFiniteOrder.instIsSuccArchimedean
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
