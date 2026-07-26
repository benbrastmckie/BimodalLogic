/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Bimodal.Metalogic.WeakCanonical.Kamp.ExistsForallNF
import Bimodal.Metalogic.WeakCanonical.PriorDefs

/-!
# Abstract INF Hypothesis and Prior Instantiation

Defines the abstract first/last-occurrence hypotheses `HasDefinableINF` and
`HasDefinableSUP`, following Rabinovich 2014 Section 5. These capture the
property that for any TL-definable predicate, first (resp. last) occurrences
in an interval are "definable" in a sense adequate for the negation closure
argument.

## Abstract Hypotheses

The key property needed for Rabinovich's negation closure (Lemma 5.1) is:
given a TL-definable predicate P and an interval (z0, z1), if P occurs
somewhere in (z0, z1), then there exists a "definable infimum point" r0
near the first occurrence satisfying:
- z0 < r0 <= z1
- P does not hold in (z0, r0) (or more precisely, in the open interval)
- Either P(r0) holds (attained infimum) or K+(P)(r0) holds (P holds
  arbitrarily close from above)

where K+(P) is the "holds arbitrarily soon after" operator, TL-definable
as ¬(⊤ U ¬P) ∧ ¬P (i.e., P is dense to the right but does not hold at
the point itself). See Rabinovich eq 5.2.

## Prior Instantiation

For Prior structures (satisfying `semantic_prior_UZ`), first occurrences
are attained: the UZ axiom directly gives a point where P holds, with ¬P
between the current point and that first occurrence. The P(r0) disjunct
holds outright, and the K+ disjunct is vacuous.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Section 5, eq (5.2)
- Rabinovich 2014, Proposition 4.2 (negation closure uses INF/SUP)
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## K+ operator (holds arbitrarily soon after)

Rabinovich eq (5.2): K+(P)(t) = ¬P(t) ∧ ¬(⊤ U ¬P)(t)
= "P does not hold at t, but P holds at points arbitrarily close above t"
= "on every open interval (t, s), P holds somewhere (but not at t itself)"

In temporal logic terms: ¬P ∧ ¬F(¬P ... wait, that's G(P)).
Actually: K+(P)(t) = ¬P(t) ∧ G(P)(t)... no.
Let me re-derive: ¬(⊤ U ¬P) means "it's not the case that there exists s > t
such that ¬P holds throughout (t, s)" = "for all s > t, P holds somewhere in (t, s)"
= "P is dense above t". Combined with ¬P(t), this is K+(P)(t).

TL encoding: K+(P) = ¬P ∧ ¬(¬P U ⊤)... wait, let me be careful.

(⊤ U ¬P)(t) = ∃ s > t, ⊤(s) ∧ ∀ r ∈ (t,s), ¬P(r)
            = ∃ s > t, ∀ r ∈ (t,s), ¬P(r)

Hmm, that says "there exists a future point s such that ¬P holds throughout (t, s)".
This is NOT the same as F(¬P). It's a "gap in P" condition.

¬(⊤ U ¬P)(t) = ∀ s > t, ∃ r ∈ (t,s), P(r)
             = "P is dense above t" (no gap in P starting from t)

So K+(P) = ¬P ∧ ¬(⊤ U ¬P) = "P doesn't hold here, but P holds somewhere
in every interval (t, s) above t".

Actually wait, the Rabinovich paper uses the notation differently. Let me
check: his equation (5.2) defines K+(P) as what is TL-definable. For the
formal definition below, we use the semantic characterization directly.
-/

/-- K+(P)(t): P holds arbitrarily soon after t, but not at t itself.
    Semantically: ¬P(t) ∧ ∀ s > t, ∃ r ∈ (t, s), P(r).
    This is TL-definable: K+(P) = P.neg ∧ ¬(⊤ U P.neg). -/
def kplus {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : Formula) (t : M.carrier) : Prop :=
  ¬temporal_truth M atomMap t P ∧
  ∀ s : M.carrier, t < s → ∃ r : M.carrier, t < r ∧ r < s ∧ temporal_truth M atomMap r P

/-- K+(P) is TL-definable: the formula P.neg ∧ ¬(⊤ U P.neg). -/
noncomputable def kplus_formula (P : Formula) : Formula :=
  Formula.and P.neg (Formula.imp (Formula.untl Formula.top P.neg) Formula.bot)

/-- K-(P)(t): dual of K+, for the Since direction.
    P holds arbitrarily close before t, but not at t itself. -/
def kminus {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : Formula) (t : M.carrier) : Prop :=
  ¬temporal_truth M atomMap t P ∧
  ∀ s : M.carrier, s < t → ∃ r : M.carrier, s < r ∧ r < t ∧ temporal_truth M atomMap r P

/-! ## Abstract INF/SUP Hypotheses -/

/-- A structure has definable infima for TL-predicates:
    for any TL-definable predicate P and interval (z0, z1),
    if P occurs somewhere in (z0, z1), then there exists r0 with z0 < r0 ≤ z1
    such that P does not hold in (z0, r0) and either P(r0) or K+(P)(r0).

    Note: r0 < z1 is the strict version (adequate for the proof when z1 is
    the right boundary). We use r0 ≤ z1 to handle the case where the first
    occurrence is at the right boundary. -/
structure HasDefinableINF {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) : Prop where
  /-- For any TL-definable predicate P and interval (z0, z1), if P occurs
      somewhere in (z0, z1), then there is a first-occurrence point r0. -/
  first_occ : ∀ (P : Formula) (z0 z1 : M.carrier),
    z0 < z1 →
    (∃ x : M.carrier, z0 < x ∧ x < z1 ∧ temporal_truth M atomMap x P) →
    ∃ r0 : M.carrier, z0 < r0 ∧ r0 ≤ z1 ∧
      (∀ y : M.carrier, z0 < y → y < r0 → ¬temporal_truth M atomMap y P) ∧
      (temporal_truth M atomMap r0 P ∨ kplus M atomMap P r0)

/-- A structure has definable suprema for TL-predicates:
    dual of `HasDefinableINF`, for the Since direction. -/
structure HasDefinableSUP {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) : Prop where
  /-- For any TL-definable predicate P and interval (z0, z1), if P occurs
      somewhere in (z0, z1), then there is a last-occurrence point r0. -/
  last_occ : ∀ (P : Formula) (z0 z1 : M.carrier),
    z0 < z1 →
    (∃ x : M.carrier, z0 < x ∧ x < z1 ∧ temporal_truth M atomMap x P) →
    ∃ r0 : M.carrier, z0 ≤ r0 ∧ r0 < z1 ∧
      (∀ y : M.carrier, r0 < y → y < z1 → ¬temporal_truth M atomMap y P) ∧
      (temporal_truth M atomMap r0 P ∨ kminus M atomMap P r0)

/-! ## Prior Structure Instantiation -/

/-- Prior structures (satisfying `semantic_prior_UZ`) have definable infima.

    **Proof**: The UZ axiom directly gives an attained first occurrence.
    Given P occurring in (z0, z1), apply UZ at z0 with P to get r0 > z0
    where P(r0) holds and ¬P on (z0, r0). Since z0 < x < z1 for some x
    with P(x), the first occurrence r0 satisfies r0 ≤ x < z1, so r0 < z1
    (hence r0 ≤ z1). The P(r0) disjunct holds outright; K+(P)(r0) is vacuous. -/
theorem prior_hasDefinableINF {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_UZ : semantic_prior_UZ M atomMap) :
    HasDefinableINF M atomMap where
  first_occ := by
    intro P z0 z1 _h_lt ⟨x, h_z0_x, h_x_z1, h_Px⟩
    -- Apply semantic_prior_UZ at z0 with formula P
    have h_exists : ∃ s, z0 < s ∧ temporal_truth M atomMap s P := ⟨x, h_z0_x, h_Px⟩
    obtain ⟨r0, h_z0_r0, h_Pr0, h_neg⟩ := h_UZ z0 P h_exists
    -- r0 is the first occurrence of P above z0
    -- We need r0 ≤ z1. Since P(r0) and r0 is the FIRST occurrence above z0,
    -- and x > z0 with P(x), we have r0 ≤ x < z1.
    have h_r0_le_x : r0 ≤ x := by
      by_contra h_gt
      push Not at h_gt
      -- r0 > x, but h_neg says ¬P on (z0, r0), and z0 < x < r0, so ¬P(x)
      have := h_neg x h_z0_x h_gt
      -- But h_neg gives temporal_truth at P.neg, which is ¬temporal_truth at P
      simp only [Formula.neg, temporal_truth] at this
      exact this h_Px
    exact ⟨r0, h_z0_r0, le_trans h_r0_le_x (le_of_lt h_x_z1),
           fun y hy1 hy2 => by
             have := h_neg y hy1 hy2
             simp only [Formula.neg, temporal_truth] at this
             exact this,
           Or.inl h_Pr0⟩

/-- Prior structures (satisfying `semantic_prior_SZ`) have definable suprema.
    Dual of `prior_hasDefinableINF`. -/
theorem prior_hasDefinableSUP {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_SZ : semantic_prior_SZ M atomMap) :
    HasDefinableSUP M atomMap where
  last_occ := by
    intro P z0 z1 _h_lt ⟨x, h_z0_x, h_x_z1, h_Px⟩
    -- Apply semantic_prior_SZ at z1 with formula P
    have h_exists : ∃ s, s < z1 ∧ temporal_truth M atomMap s P := ⟨x, h_x_z1, h_Px⟩
    obtain ⟨r0, h_r0_z1, h_Pr0, h_neg⟩ := h_SZ z1 P h_exists
    -- r0 is the last occurrence of P below z1
    -- We need z0 ≤ r0. Since P(r0) is the last occ and x < z1 with P(x), r0 ≥ x > z0.
    have h_x_le_r0 : x ≤ r0 := by
      by_contra h_gt
      push Not at h_gt
      have := h_neg x h_gt h_x_z1
      simp only [Formula.neg, temporal_truth] at this
      exact this h_Px
    exact ⟨r0, le_trans (le_of_lt h_z0_x) h_x_le_r0, h_r0_z1,
           fun y hy1 hy2 => by
             have := h_neg y hy1 hy2
             simp only [Formula.neg, temporal_truth] at this
             exact this,
           Or.inl h_Pr0⟩

/-! ## Attained INF (Specialized for Prior Structures)

For Prior structures, the first occurrence is always attained (P(r0) holds directly).
The K+ disjunct is vacuous. This simplification avoids the limit-point case analysis
needed for general Dedekind-complete chains. -/

/-- A structure has attained infima: like `HasDefinableINF`, but the first occurrence
    is always attained (P(r0) holds). No K+ case. Strictly stronger than `HasDefinableINF`. -/
structure HasAttainedINF {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) : Prop where
  /-- For any TL-definable predicate P and interval (z0, z1), if P occurs
      somewhere in (z0, z1), then there is an attained first-occurrence point r0
      with P(r0) and ¬P on (z0, r0). -/
  first_occ : ∀ (P : Formula) (z0 z1 : M.carrier),
    z0 < z1 →
    (∃ x : M.carrier, z0 < x ∧ x < z1 ∧ temporal_truth M atomMap x P) →
    ∃ r0 : M.carrier, z0 < r0 ∧ r0 < z1 ∧
      (∀ y : M.carrier, z0 < y → y < r0 → ¬temporal_truth M atomMap y P) ∧
      temporal_truth M atomMap r0 P

/-- `HasAttainedINF` implies `HasDefinableINF`. -/
theorem HasAttainedINF.toHasDefinableINF {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h : HasAttainedINF M atomMap) : HasDefinableINF M atomMap where
  first_occ P z0 z1 h_lt h_occ := by
    obtain ⟨r0, hr0_above, hr0_below, h_no_before, h_P_r0⟩ := h.first_occ P z0 z1 h_lt h_occ
    exact ⟨r0, hr0_above, le_of_lt hr0_below, h_no_before, Or.inl h_P_r0⟩

/-- Prior structures have attained infima.
    This is strictly stronger than `prior_hasDefinableINF`: the K+ case never arises. -/
theorem prior_hasAttainedINF {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_UZ : semantic_prior_UZ M atomMap) :
    HasAttainedINF M atomMap where
  first_occ := by
    intro P z0 z1 _h_lt ⟨x, h_z0_x, h_x_z1, h_Px⟩
    have h_exists : ∃ s, z0 < s ∧ temporal_truth M atomMap s P := ⟨x, h_z0_x, h_Px⟩
    obtain ⟨r0, h_z0_r0, h_Pr0, h_neg⟩ := h_UZ z0 P h_exists
    have h_r0_le_x : r0 ≤ x := by
      by_contra h_gt
      push Not at h_gt
      have := h_neg x h_z0_x h_gt
      simp only [Formula.neg, temporal_truth] at this
      exact this h_Px
    exact ⟨r0, h_z0_r0, lt_of_le_of_lt h_r0_le_x h_x_z1,
           fun y hy1 hy2 => by
             have := h_neg y hy1 hy2
             simp only [Formula.neg, temporal_truth] at this
             exact this,
           h_Pr0⟩

/-! ## Attained SUP (Specialized for Prior Structures)

Mirror of `HasAttainedINF` for the Since direction.
For Prior structures, the last occurrence is always attained (P(r0) holds directly).
The K- disjunct is vacuous. This is the surrogate for the Dedekind-completeness
sup in Rabinovich's Corollary 5.4(2) / Lemma 5.1 Case 3 mirror. -/

/-- A structure has attained suprema: like `HasDefinableSUP`, but the last occurrence
    is always attained (P(r0) holds). No K- case. Strictly stronger than `HasDefinableSUP`. -/
structure HasAttainedSUP {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) : Prop where
  /-- For any TL-definable predicate P and interval (z0, z1), if P occurs
      somewhere in (z0, z1), then there is an attained last-occurrence point r0
      with P(r0) and ¬P on (r0, z1). -/
  last_occ : ∀ (P : Formula) (z0 z1 : M.carrier),
    z0 < z1 →
    (∃ x : M.carrier, z0 < x ∧ x < z1 ∧ temporal_truth M atomMap x P) →
    ∃ r0 : M.carrier, z0 < r0 ∧ r0 < z1 ∧
      (∀ y : M.carrier, r0 < y → y < z1 → ¬temporal_truth M atomMap y P) ∧
      temporal_truth M atomMap r0 P

/-- Prior structures have attained suprema.
    Mechanical mirror of `prior_hasAttainedINF`, consuming `semantic_prior_SZ`
    in place of `semantic_prior_UZ`. The K- case never arises. -/
theorem prior_hasAttainedSUP {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_SZ : semantic_prior_SZ M atomMap) :
    HasAttainedSUP M atomMap where
  last_occ := by
    intro P z0 z1 _h_lt ⟨x, h_z0_x, h_x_z1, h_Px⟩
    have h_exists : ∃ s, s < z1 ∧ temporal_truth M atomMap s P := ⟨x, h_x_z1, h_Px⟩
    obtain ⟨r0, h_r0_z1, h_Pr0, h_neg⟩ := h_SZ z1 P h_exists
    have h_x_le_r0 : x ≤ r0 := by
      by_contra h_gt
      push Not at h_gt
      have := h_neg x h_gt h_x_z1
      simp only [Formula.neg, temporal_truth] at this
      exact this h_Px
    exact ⟨r0, lt_of_lt_of_le h_z0_x h_x_le_r0, h_r0_z1,
           fun y hy1 hy2 => by
             have := h_neg y hy1 hy2
             simp only [Formula.neg, temporal_truth] at this
             exact this,
           h_Pr0⟩

end Bimodal.Metalogic.WeakCanonical.Kamp
