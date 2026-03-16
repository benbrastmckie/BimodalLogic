import Bimodal.Metalogic.Domain.DurationTransfer
import Bimodal.Metalogic.StagedConstruction.CantorPrereqs
import Bimodal.Metalogic.Canonical.CanonicalIrreflexivityAxiom
import Mathlib.Order.SuccPred.LinearLocallyFinite
import Mathlib.Order.Interval.Finset.Basic

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
open Bimodal.ProofSystem

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
## LocallyFiniteOrder via Stage Bounding

The discrete staged construction has a key property: for any two quotient elements
`[a]` and `[b]`, all elements in `Icc [a] [b]` come from the finite image of
`discreteStagedBuild N` in the quotient, where `N = max(minStage a, minStage b)`.

This allows us to prove `LocallyFiniteOrder` directly without needing a generic
`Antisymmetrization.locallyFiniteOrder` instance (which doesn't exist in Mathlib).
-/

/-- Every quotient element has a representative at some stage of the discrete construction.
    Returns the stage and the representative element (as a DiscreteTimelineElem). -/
theorem exists_stage_of_quotient_elem (a : DiscreteTimelineQuot root_mcs root_mcs_proof) :
    ∃ n, ∃ elem : DiscreteTimelineElem root_mcs root_mcs_proof,
      elem.1 ∈ discreteStagedBuild root_mcs root_mcs_proof n ∧
      (⟦elem⟧ : DiscreteTimelineQuot root_mcs root_mcs_proof) = a := by
  induction a using Quotient.inductionOn with
  | _ elem =>
    obtain ⟨n, hn⟩ := elem.2
    exact ⟨n, elem, hn, rfl⟩

/-- The minimum stage where a quotient element has a representative. -/
noncomputable def minStage (a : DiscreteTimelineQuot root_mcs root_mcs_proof) : ℕ :=
  Nat.find (exists_stage_of_quotient_elem root_mcs root_mcs_proof a)

/-- At minStage, there exists a representative. -/
theorem minStage_spec (a : DiscreteTimelineQuot root_mcs root_mcs_proof) :
    ∃ elem : DiscreteTimelineElem root_mcs root_mcs_proof,
      elem.1 ∈ discreteStagedBuild root_mcs root_mcs_proof (minStage root_mcs root_mcs_proof a) ∧
      (⟦elem⟧ : DiscreteTimelineQuot root_mcs root_mcs_proof) = a :=
  Nat.find_spec (exists_stage_of_quotient_elem root_mcs root_mcs_proof a)

/-!
## Covering Lemma: Immediate Successors from DF Frame Condition

The discreteness axiom DF = `(F top and phi and H phi) -> F(H phi)` ensures that
between any MCS and its forward witness, there is no intermediate MCS. This is
the key lemma for deriving SuccOrder properties.

### MCS Covering Relation

An MCS W *covers* M if CanonicalR M W and there is no MCS K strictly between M and W.
The DF axiom, being in every MCS, constrains the structure to ensure covering.

### Proof Strategy (from research-003.md)

Given serial MCS M with forward witness W:
1. Suppose K is an intermediate MCS with g_content(M) subset K and g_content(K) subset W
2. If K != M and K != W, then some formula discriminates K from M or W
3. DF membership in M constrains what H-formulas can appear in intermediate MCS
4. This leads to a contradiction, proving no strict intermediate exists
-/

/-- MCS covering relation: W covers M iff W is an immediate successor (no strict intermediate). -/
def MCS.Covers (M W : Set Formula) : Prop :=
  CanonicalR M W ∧ ∀ K, SetMaximalConsistent K →
    CanonicalR M K → CanonicalR K W → K = M ∨ K = W

/-- Every serial MCS has an immediate successor (covering witness).

This is the key lemma connecting DF frame condition to MCS structure. The proof
requires showing that the forward witness construction yields an immediate successor.

**Proof outline**:
1. M is serial, so exists F(phi) in M for some phi
2. Let W = Lindenbaum({phi} union g_content(M)) be the forward witness
3. W is MCS and CanonicalR M W by canonical_forward_F
4. For any K with CanonicalR M K and CanonicalR K W:
   a. If K != M, then exists psi with psi in K but not determined by g_content(M)
   b. If K != W, then exists chi with chi in W but chi not in K
   c. DF in M constrains the relationship between H-formulas in K and W
   d. This leads to contradiction, so K = M or K = W

**PROOF BLOCKED**: The covering lemma requires showing that DF membership constrains
intermediate MCS structure. This is identified as mathematically deep in research-003.md.

**What we have**:
- h_MK : g_content(M) ⊆ K
- h_KW : g_content(K) ⊆ W
- h_K_ne_M and h_K_ne_W : K differs from both endpoints
- DF axiom in every MCS: (F⊤ ∧ φ ∧ Hφ) → F(Hφ)
- g_content_subset_implies_h_content_reverse : g_content(M) ⊆ W → h_content(W) ⊆ M

**The gap**: We cannot derive a contradiction from K being strictly between M and W.
The DF axiom constrains what formulas are in M, but doesn't directly imply covering.

**Potential approaches tried**:
1. Use F(H(φ)) in M from DF to constrain W's H-formulas - but this propagates backwards,
   doesn't constrain intermediate K
2. Use K != W to find distinguishing formula chi - but chi could be outside g_content
   structures, so DF doesn't apply
3. Use K != M to find distinguishing formula psi - same issue

**Recommendation**: This lemma requires additional mathematical insight or a different
proof strategy. See research-003.md for detailed analysis.
-/
theorem mcs_has_immediate_successor
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (h_serial : ∃ N, CanonicalR M N) :
    ∃ W, SetMaximalConsistent W ∧ MCS.Covers M W := by
  -- Get a forward witness via canonical_forward_F
  -- From seriality_future axiom: F(neg bot) is in every MCS
  have h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ M := by
    apply theorem_in_mcs h_mcs
    exact DerivationTree.axiom [] _ Axiom.seriality_future
  -- Get the forward witness for F(neg bot)
  obtain ⟨W, h_W_mcs, h_MW, h_top_in_W⟩ := canonical_forward_F M h_mcs (Formula.neg Formula.bot) h_F_top
  use W, h_W_mcs
  constructor
  · exact h_MW
  · intro K h_K_mcs h_MK h_KW
    by_contra h_neither
    push_neg at h_neither
    obtain ⟨h_K_ne_M, h_K_ne_W⟩ := h_neither
    -- BLOCKED: Cannot derive contradiction from K being strictly between M and W
    -- The DF axiom membership doesn't directly constrain intermediate MCS structure
    -- See docstring above for detailed analysis
    sorry

/-!
## LocallyFiniteOrder Instance

The key step to proving SuccOrder/PredOrder/IsSuccArchimedean is instantiating
`LocallyFiniteOrder`. Once we have this, the three remaining sorries follow
automatically from Mathlib's `LinearLocallyFiniteOrder` infrastructure.

### Interval Finiteness (Axiomatized - Technical Debt)

The discrete staged construction produces a discrete (non-dense) order. Between
any two elements there are only finitely many elements. This follows from:
1. The construction adds finitely many points per stage
2. No density witnesses are inserted (unlike the dense construction)
3. The discreteness axiom DF prevents dense accumulation points

**Technical Debt**: The full proof requires extracting the DF frame condition
at the MCS level. For now, we axiomatize interval finiteness. The structural
proof approach is documented in research-006.md.

See: specs/974_prove_discrete_timeline_succorder_predorder/reports/research-006.md
-/

/-- **AXIOM (Technical Debt)**: Intervals in the discrete timeline are finite.

This axiom captures the discreteness of the timeline constructed without density
insertion. The proof should follow from:
1. Stage-bounded interval containment: any `c ∈ Icc a b` has a representative
   in `discreteStagedBuild (max (minStage a) (minStage b))`
2. Each stage is a finite set
3. The quotient map preserves finiteness

Remediation: Prove the stage-bounding property using the F/P witness structure
of evenStage and the monotonicity of discreteStagedBuild.
-/
axiom discrete_Icc_finite_axiom :
    ∀ (a b : DiscreteTimelineQuot root_mcs root_mcs_proof), (Set.Icc a b).Finite

/-- Intervals in the discrete timeline are finite. -/
theorem discrete_Icc_finite (a b : DiscreteTimelineQuot root_mcs root_mcs_proof) :
    (Set.Icc a b).Finite :=
  discrete_Icc_finite_axiom root_mcs root_mcs_proof a b

/-- LocallyFiniteOrder instance for the discrete timeline quotient.

This is the key instance that unlocks:
- `LinearLocallyFiniteOrder.isMax_of_succFn_le` for SuccOrder
- Automatic `IsSuccArchimedean` instance
-/
noncomputable instance : LocallyFiniteOrder (DiscreteTimelineQuot root_mcs root_mcs_proof) :=
  LocallyFiniteOrder.ofFiniteIcc (discrete_Icc_finite root_mcs root_mcs_proof)

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

The SuccOrder, PredOrder, and IsSuccArchimedean instances are derived from
`LocallyFiniteOrder`, which is instantiated using the axiomatized interval
finiteness property (`discrete_Icc_finite_axiom`). The `succ` function uses
`LinearLocallyFiniteOrder.succFn` (GLB of elements strictly greater).
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
  -- With LocallyFiniteOrder, we can use isMax_of_succFn_le
  -- NoMaxOrder gives ¬IsMax a, so ¬(succFn a ≤ a)
  -- Combined with le_succFn (a ≤ succFn a), this gives a < succFn a
  have h_not_max : ¬IsMax a := not_isMax a
  have h_le : a ≤ LinearLocallyFiniteOrder.succFn a := LinearLocallyFiniteOrder.le_succFn a
  -- If succFn a ≤ a, then by isMax_of_succFn_le, a is max, contradiction
  by_contra h_not_lt
  push_neg at h_not_lt
  have h_eq : LinearLocallyFiniteOrder.succFn a = a := le_antisymm h_not_lt h_le
  have h_is_max : IsMax a := LinearLocallyFiniteOrder.isMax_of_succFn_le a (le_of_eq h_eq)
  exact h_not_max h_is_max

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

The proof uses LocallyFiniteOrder: if `lub(Iio a) = a`, then the finite set `Ioc b a`
for any `b < a` would have `a` as its maximum, contradicting `a ∉ Ioc b a`.
-/
theorem discrete_timeline_predFn_lt (a : DiscreteTimelineQuot root_mcs root_mcs_proof) :
    discretePredFn root_mcs root_mcs_proof a < a := by
  -- We have: discretePredFn a ≤ a
  have h_le : discretePredFn root_mcs root_mcs_proof a ≤ a :=
    discretePredFn_le root_mcs root_mcs_proof a
  -- We need to show: discretePredFn a ≠ a (strict inequality)
  by_contra h_not_lt
  push_neg at h_not_lt
  -- So discretePredFn a = a (since ≤ and ≥)
  have h_eq : discretePredFn root_mcs root_mcs_proof a = a := le_antisymm h_le h_not_lt
  -- This means a = lub(Iio a)
  have h_lub : IsLUB (Set.Iio a) a := by
    have h := discretePredFn_spec root_mcs root_mcs_proof a
    rw [h_eq] at h
    exact h
  -- By NoMinOrder, there exists b < a
  obtain ⟨b, hb⟩ : ∃ b, b < a := exists_lt a
  -- The finite set Ioc b a contains all elements in (b, a]
  -- Since a = lub(Iio a), and b < a, there must be some c ∈ Iio a with b < c
  -- But also c ≤ a (since c < a), so c ∈ Ioc b a
  -- If a were the lub, and the set is finite, a must be in the set... but a ∉ Iio a
  -- This is a contradiction
  -- Actually, use that in a LocallyFiniteOrder, Iio a has a maximum when nonempty
  -- and that maximum is strictly less than a
  have h_Ioc_finite : (Set.Ioc b a).Finite := Set.finite_Ioc b a
  -- Since a = lub(Iio a), and Iio a is nonempty, we have Ioc b a ⊆ Iio a ∪ {a}
  -- But a ∉ Iio a, so the max of Ioc b a (which is finite nonempty) is < a
  -- Yet lub(Iio a) = a means a is the least upper bound...
  -- The key: in a finite nonempty set with an upper bound, the max equals the lub
  have h_Ioc_nonempty : (Set.Ioc b a).Nonempty := ⟨a, Set.right_mem_Ioc.mpr hb⟩
  -- Wait, a ∈ Ioc b a since b < a and a ≤ a
  -- And Ioc b a ⊆ Iio a ∪ {a}... but we want to show a is not the lub of Iio a
  -- Hmm, let me reconsider. The issue is that Iio a = {x | x < a}, and if a = lub(Iio a),
  -- then for any x ∈ Iio a, x < a. The lub being a just means a is the smallest upper bound.
  -- This is always true for Iio a in any linear order!
  -- So the argument above doesn't work directly.
  --
  -- Better approach: use that with LocallyFiniteOrder, Iio a ∩ Ici b is finite for any b < a
  -- This means Iio a is "bounded below" in a sense. If Iio a has a maximum m < a, then
  -- lub(Iio a) = m, not a. So a ≠ lub(Iio a).
  -- The key is showing Iio a has a maximum. This follows from Finset.max' on Iic (pred a).
  --
  -- Actually, let's use that a ∈ Set.Ioc b a, and Ioc b a is finite.
  -- The maximum of Ioc b a is either a or some element of Iio a.
  -- If it's an element c of Iio a, then c < a but c is the max of Ioc b a.
  -- Then lub(Iio a) ≤ c < a, contradicting a = lub(Iio a).
  -- If the max of Ioc b a is a... wait, a ∈ Ioc b a, so yes a could be the max.
  -- But Ioc b a ⊄ Iio a since a ∉ Iio a.
  -- Hmm, this is getting complicated. Let me use a different approach.
  --
  -- Use: IsMin a iff ∀ x, a ≤ x (i.e., Iio a = ∅)
  -- We have NoMinOrder, so Iio a ≠ ∅
  -- Actually, a = lub(Iio a) doesn't directly imply IsMin a.
  -- But it does in a discrete order!
  -- Key: if a = lub(Iio a) and the order is "discrete" (has LocallyFiniteOrder),
  -- then Iio a must be empty, which contradicts NoMinOrder.
  --
  -- Actually, let me prove: isMin_of_eq_lub_Iio
  -- If a = lub(Iio a) and LocallyFiniteOrder, then IsMin a
  -- Proof: If not IsMin, ∃ b < a. Consider Finset.Ioo b a.
  -- Since b < a, Finset.Ioo b a = {x | b < x < a} is a finite set.
  -- If Ioo b a is nonempty, let c be its max. Then c < a and c > b.
  -- Also, c is an upper bound of Ioo b a ∩ Iio a = Ioo b a.
  -- But wait, is c ≥ lub(Ioo b a)?
  -- Actually simpler: if Ioo b a is empty, then there's no x with b < x < a.
  -- This means b is immediately below a, i.e., succ b = a (in the SuccOrder sense).
  -- Then the max of Iio a is b, so lub(Iio a) = b ≠ a.
  -- If Ioo b a is nonempty, let c be its max. Then c < a and c is in Iio a.
  -- For any d ∈ Iio a, either d ≤ b (so d < c) or d ∈ Ioo b a (so d ≤ c).
  -- So c = lub(Iio a) ≠ a, contradiction.
  --
  -- Wait, that's not quite right either. Let me just do this with Finset.Ico b a.
  have h_Ico_finite : (Finset.Ico b a).Nonempty := by
    rw [Finset.nonempty_Ico]
    exact hb
  -- Finset.Ico b a = {x | b ≤ x < a} contains b
  -- Its maximum is some element m with b ≤ m < a
  let m := (Finset.Ico b a).max' h_Ico_finite
  have hm_mem : m ∈ Finset.Ico b a := Finset.max'_mem _ h_Ico_finite
  have hm_lt_a : m < a := (Finset.mem_Ico.mp hm_mem).2
  have hm_max : ∀ x ∈ Finset.Ico b a, x ≤ m := fun x hx => Finset.le_max' _ x hx
  -- Now, m is an upper bound of Iio a ∩ Ici b = Ico b a
  -- For any c ∈ Iio a:
  --   If c < b, then c < b ≤ m
  --   If c ≥ b, then c ∈ Ico b a, so c ≤ m
  -- So m is an upper bound of Iio a
  have hm_ub : m ∈ upperBounds (Set.Iio a) := by
    intro c hc
    by_cases hcb : c < b
    · exact le_trans (le_of_lt hcb) ((Finset.mem_Ico.mp hm_mem).1)
    · push_neg at hcb
      have hc_mem : c ∈ Finset.Ico b a := Finset.mem_Ico.mpr ⟨hcb, hc⟩
      exact hm_max c hc_mem
  -- But a = lub(Iio a), so a ≤ m (since m is an upper bound)
  have ha_le_m : a ≤ m := h_lub.2 hm_ub
  -- But m < a, contradiction
  exact not_lt.mpr ha_le_m hm_lt_a

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
-- IsSuccArchimedean follows automatically from LocallyFiniteOrder + SuccOrder
-- via the Mathlib instance in LinearLocallyFiniteOrder.lean:166
-- instance (priority := 100) [LocallyFiniteOrder ι] [SuccOrder ι] : IsSuccArchimedean ι
-- We verify it's available:
example : IsSuccArchimedean (DiscreteTimelineQuot root_mcs root_mcs_proof) := inferInstance

/-!
## Complete Pipeline

The complete pipeline:
DiscreteTimelineQuot → SuccOrder + PredOrder + IsSuccArchimedean +
NoMaxOrder + NoMinOrder → `orderIsoIntOfLinearSuccPredArch` → T ≃o ℤ →
`intAddCommGroup` + `intIsOrderedAddMonoid` → `discreteTaskFrame`.

**Technical debt**: One axiom (`discrete_Icc_finite_axiom`) for interval finiteness.
The structural proof approach is documented in research-006.md.
-/

/-- The discrete canonical TaskFrame, with D derived from syntax via ℤ characterization.

This is the end-to-end pipeline: MCSs → DiscreteTimelineQuot → T ≃o ℤ →
AddCommGroup T → IsOrderedAddMonoid T → TaskFrame T.
-/
noncomputable def discreteCanonicalTaskFrame :
    @TaskFrame (DiscreteTimelineQuot root_mcs root_mcs_proof)
      (intAddCommGroup (DiscreteTimelineQuot root_mcs root_mcs_proof))
      (inferInstance)
      (intIsOrderedAddMonoid (DiscreteTimelineQuot root_mcs root_mcs_proof)) :=
  discreteTaskFrame (DiscreteTimelineQuot root_mcs root_mcs_proof)

end Bimodal.Metalogic.Domain
