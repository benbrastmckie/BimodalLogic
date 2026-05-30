import Bimodal.Metalogic.WeakCanonical.PriorExpressiveness
import Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructures
import Bimodal.Metalogic.WeakCanonical.IntegerModel.ReynoldsNoGaps
import Bimodal.Metalogic.WeakCanonical.EFGames.Defs
import Bimodal.Metalogic.WeakCanonical.NEquivalence

/-!
# Reynolds Model Surgery: no_gaps_discrete via Prior-UZ/SZ

This file provides infrastructure for proving `no_gaps_discrete` (Reynolds 1994,
Theorem 14 adapted to the `OrderedMonadicStructure` level): in a discrete linear
order satisfying semantic Prior-UZ/SZ, contemporaneous equivalence class boundaries
cannot occur at Dedekind gaps.

## CRITICAL FINDING (Task 202, Plan v13, Phase 1)

The existing signature of `no_gaps_discrete` in GoodStructures.lean:820 is
**incomplete**: it is missing a predicate accessibility condition. Without such
a condition, the theorem is FALSE.

**Counterexample**: Let M = ℤ + ℤ (two copies of integers). Let sig have two
predicates p₁, p₂ where only p₁ is temporally accessible (∃f, atomMap f = p₁).
Let p₁ be constant (true everywhere) and p₂ differ across the gap (true in copy 1,
false in copy 2). Then:
- Prior-UZ/SZ is satisfied (all temporal formulas are constant, since p₂ is inaccessible)
- ¬(a ~M b) for a in copy 1, b in copy 2 (k-types differ due to p₂)
- No successor boundary exists (both copies are individually archimedean)

The fix is to add `h_accessible : all_predicates_accessible M atomMap` to the
theorem signature. This condition is satisfied at all actual call sites (Transfer.lean)
where the atomMap is constructed to cover all sig.preds.

## Key Results

- `temporal_truth_neg_iff_not`: ψ.neg evaluates as ¬ψ under temporal_truth
- `temporal_truth_neg_neg_elim`: double negation elimination for temporal_truth
- `prior_UZ_first_transition`: first-transition lemma for Prior-UZ structures
- `contemp_equiv_convex`: contemp_equiv classes are convex intervals
- `contemp_equiv_succ_closed`: if ∀c, a ~M c → a ~M succ(c), the class is succ-closed
- `class_gap_exists`: if class(a) ≠ whole order, a Gap exists

## References

- Reynolds 1994, Section 7, Lemmas 6-13, Theorem 14
- Reynolds 1994, Theorem 5 (US expressive completeness, PriorExpressiveness.lean)
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-! ## Temporal Truth Helpers -/

/-- temporal_truth of ψ.neg is ¬(temporal_truth of ψ). -/
theorem temporal_truth_neg_iff_not {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) (ψ : Formula) :
    temporal_truth M atomMap t ψ.neg ↔ ¬ temporal_truth M atomMap t ψ := by
  simp only [Formula.neg, temporal_truth]

/-- Double negation elimination for temporal_truth. -/
theorem temporal_truth_neg_neg_elim {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) (ψ : Formula)
    (h : temporal_truth M atomMap t ψ.neg.neg) :
    temporal_truth M atomMap t ψ := by
  rw [temporal_truth_neg_iff_not, temporal_truth_neg_iff_not, Classical.not_not] at h
  exact h

/-! ## Prior-UZ First-Transition Lemma -/

/--
**Prior-UZ First-Transition**: If ψ holds at t and ¬ψ holds at some s > t in a
discrete structure satisfying Prior-UZ, then there exists c ≥ t with
temporal_truth c ψ and ¬temporal_truth (succ c) ψ.

This is a direct consequence of Prior-UZ: the first occurrence of ¬ψ after t
provides the transition point, and in a discrete order, the point just before
the first ¬ψ occurrence is a successor boundary.
-/
theorem prior_UZ_first_transition {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_prior_UZ : semantic_prior_UZ M atomMap)
    (t : M.carrier) (ψ : Formula)
    (h_true_t : temporal_truth M atomMap t ψ)
    (h_false_above : ∃ s : M.carrier, t < s ∧ ¬ temporal_truth M atomMap s ψ) :
    ∃ c : M.carrier, t ≤ c ∧
      temporal_truth M atomMap c ψ ∧
      ¬ temporal_truth M atomMap (Order.succ c) ψ := by
  -- F(ψ.neg) holds at t
  have h_neg_above : ∃ s : M.carrier, t < s ∧ temporal_truth M atomMap s ψ.neg :=
    h_false_above.imp fun s ⟨h1, h2⟩ =>
      ⟨h1, (temporal_truth_neg_iff_not M atomMap s ψ).mpr h2⟩
  -- Prior-UZ gives first ψ.neg point s₀ after t
  obtain ⟨s₀, hts₀, h_neg_s₀, h_between⟩ := h_prior_UZ t ψ.neg h_neg_above
  have h_not_psi_s₀ : ¬ temporal_truth M atomMap s₀ ψ :=
    (temporal_truth_neg_iff_not M atomMap s₀ ψ).mp h_neg_s₀
  -- ψ holds on (t, s₀) via double negation
  have h_psi_between : ∀ r : M.carrier, t < r → r < s₀ →
      temporal_truth M atomMap r ψ := by
    intro r htr hrs₀
    exact temporal_truth_neg_neg_elim M atomMap r ψ (h_between r htr hrs₀)
  -- Case split: s₀ = succ(t) or s₀ > succ(t)
  by_cases h_eq : s₀ = Order.succ t
  · -- s₀ = succ(t): c = t works
    exact ⟨t, le_refl t, h_true_t, h_eq ▸ h_not_psi_s₀⟩
  · -- s₀ > succ(t): c = pred(s₀) works
    have h_succ_le : Order.succ t ≤ s₀ := Order.succ_le_of_lt hts₀
    have h_succ_lt : Order.succ t < s₀ := lt_of_le_of_ne h_succ_le (Ne.symm h_eq)
    have h_not_min_s₀ : ¬ IsMin s₀ := not_isMin_of_lt hts₀
    -- pred(s₀) > t
    have h_t_lt_pred : t < Order.pred s₀ := by
      have h_succ_le_pred : Order.succ t ≤ Order.pred s₀ := by
        by_contra h_neg
        push_neg at h_neg
        have h_ps_lt_st : Order.pred s₀ < Order.succ t := h_neg
        have : Order.pred s₀ ≤ t := Order.le_of_lt_succ h_ps_lt_st
        have : s₀ ≤ Order.succ t := by
          calc s₀ = Order.succ (Order.pred s₀) := (Order.succ_pred_of_not_isMin h_not_min_s₀).symm
          _ ≤ Order.succ t := Order.succ_le_succ this
        exact not_lt.mpr this h_succ_lt
      exact lt_of_lt_of_le (Order.lt_succ_of_not_isMax (not_isMax t)) h_succ_le_pred
    -- ψ at pred(s₀), ¬ψ at succ(pred(s₀)) = s₀
    have h_pred_lt_s₀ : Order.pred s₀ < s₀ := Order.pred_lt_of_not_isMin h_not_min_s₀
    have h_psi_pred : temporal_truth M atomMap (Order.pred s₀) ψ :=
      h_psi_between (Order.pred s₀) h_t_lt_pred h_pred_lt_s₀
    have h_succ_pred : Order.succ (Order.pred s₀) = s₀ :=
      Order.succ_pred_of_not_isMin h_not_min_s₀
    have h_not_at_succ : ¬ temporal_truth M atomMap (Order.succ (Order.pred s₀)) ψ := by
      rw [h_succ_pred]; exact h_not_psi_s₀
    exact ⟨Order.pred s₀, le_of_lt h_t_lt_pred, h_psi_pred, h_not_at_succ⟩

/-! ## Contemp Equiv Properties -/

/--
Contemporaneous equivalence classes are convex: if a ~M c and a ≤ b ≤ c,
then a ~M b.

Proof: contemp_equiv a c means [a,c] is very_good. [a,b] ⊆ [a,c], so every
subinterval of [a,b] is a subinterval of [a,c], hence good.
-/
theorem contemp_equiv_convex (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    (a b c : M.carrier) (hab : a ≤ b) (hbc : b ≤ c)
    (hac : contemp_equiv sig k M a c) :
    contemp_equiv sig k M a b := by
  have hac_le : a ≤ c := le_trans hab hbc
  simp only [contemp_equiv] at hac ⊢
  intro x y hxy
  have h_k_equiv := subinterval_of_subinterval_k_equiv sig k M (min a b) (max a b) x y
  have h_vg_ac : very_good sig k (M.subinterval sig (min a c) (max a c)) := hac
  have hx_ge : min a c ≤ x.val := by
    calc min a c = a := min_eq_left hac_le
    _ ≤ min a b := le_min (le_refl a) hab
    _ ≤ x.val := x.property.1
  have hy_le : y.val ≤ max a c := by
    calc y.val ≤ max a b := y.property.2
    _ ≤ max a c := max_le_max_left a hbc
  have h_good_xy := good_of_very_good_subinterval sig k M (min a c) (max a c)
    (min_le_max) h_vg_ac x.val y.val hx_ge hy_le hxy
  obtain ⟨Z, hZ⟩ := h_good_xy
  exact ⟨Z, h_k_equiv.trans hZ⟩

/--
If no successor boundary exists for class(a), then the class is closed under
successor: for all c, a ~M c → a ~M succ(c).
-/
theorem contemp_equiv_succ_closed_of_no_boundary (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [NoMaxOrder M.carrier]
    (a : M.carrier)
    (h_no_boundary : ¬ ∃ c : M.carrier, contemp_equiv sig k M a c ∧
      ¬ contemp_equiv sig k M a (Order.succ c)) :
    ∀ c : M.carrier, contemp_equiv sig k M a c → contemp_equiv sig k M a (Order.succ c) := by
  intro c hac
  by_contra h_not
  exact h_no_boundary ⟨c, hac, h_not⟩

/--
If class(a) is closed under successor, it is also closed under predecessor
(using `no_boundary_at_successor` and transitivity).
-/
theorem contemp_equiv_pred_closed (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    (a c : M.carrier)
    (hac : contemp_equiv sig k M a c) :
    contemp_equiv sig k M a (Order.pred c) := by
  by_cases h_min : IsMin c
  · -- c is min, so pred(c) ≤ c. But also c ≤ pred(c) (since IsMin c means c ≤ x for all x).
    -- Actually, pred of min may equal min in PredOrder. Use le_antisymm.
    have : Order.pred c = c := le_antisymm (Order.pred_le c) (h_min (Order.pred_le c))
    rw [this]; exact hac
  · have h_sp : Order.succ (Order.pred c) = c := Order.succ_pred_of_not_isMin h_min
    have h_pc_c : contemp_equiv sig k M (Order.pred c) c := by
      have := no_boundary_at_successor sig k M (Order.pred c)
      rw [h_sp] at this; exact this
    -- a ~M c and c ~M pred(c) (symmetry of pred(c) ~M c), so a ~M pred(c)
    have h_c_pc : contemp_equiv sig k M c (Order.pred c) :=
      (contemp_equiv_is_equiv sig k M).symm h_pc_c
    exact (contemp_equiv_is_equiv sig k M).trans hac h_c_pc

/--
The class of a is closed under successor iteration: a ~M succ^[n](a).
-/
theorem contemp_equiv_succ_iterate (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [NoMaxOrder M.carrier]
    (a : M.carrier)
    (h_succ_closed : ∀ c, contemp_equiv sig k M a c → contemp_equiv sig k M a (Order.succ c))
    (n : Nat) : contemp_equiv sig k M a (Order.succ^[n] a) := by
  induction n with
  | zero => exact (contemp_equiv_is_equiv sig k M).refl a
  | succ n ih => rw [Function.iterate_succ']; exact h_succ_closed _ ih

/-! ## Gap Construction from Closed Class -/

/--
If a ~M succ^[n](a) for all n and ¬(a ~M b) with a < b, then a Dedekind Gap
exists in M.carrier: the class of a (restricted to [a, ∞)) forms a proper
initial segment closed under successor.
-/
theorem class_gap_exists (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (a b : M.carrier) (hab : a < b)
    (h_diff : ¬ contemp_equiv sig k M a b)
    (h_succ_closed : ∀ c, contemp_equiv sig k M a c → contemp_equiv sig k M a (Order.succ c)) :
    Nonempty (Gap M.carrier) := by
  -- The class of a is closed under succ and pred
  -- Define cut = {x | ∃ n, x ≤ succ^[n](a)} ∪ {x | x < a ∧ a ~M x}
  -- Actually, simpler: use gap_of_not_succ_archimedean.
  -- We need to show the order is NOT IsSuccArchimedean.
  -- If it were, then a ~M b (by one_class_archimedean), contradicting h_diff.
  -- But one_class_archimedean requires IsSuccArchimedean + SuccOrder.
  -- The issue is: we need ¬IsSuccArchimedean to get a gap.
  --
  -- Direct approach: Show ¬IsSuccArchimedean by showing a and b cannot be
  -- connected by a successor chain.
  -- If succ^[n](a) = b for some n, then a ~M b (by contemp_equiv_succ_iterate
  -- + h_succ_closed), contradicting h_diff.
  apply gap_of_not_succ_archimedean
  intro h_arch
  -- With IsSuccArchimedean, all structures are very_good
  have := one_class_archimedean sig k M a b
  exact h_diff this

/-! ## Predicate Accessibility -/

/--
A predicate is temporally accessible if there exists a formula whose temporal
truth at any point equals the predicate's interpretation.
-/
def predicate_accessible {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (p : sig.preds) : Prop :=
  ∃ f : Formula, ∀ t : M.carrier,
    temporal_truth M atomMap t f ↔ M.interp p t

/--
All predicates are temporally accessible.
-/
def all_predicates_accessible {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) : Prop :=
  ∀ p : sig.preds, predicate_accessible M atomMap p

/-! ## Main Theorem -/

/--
Helper: In a discrete Prior structure with accessible predicates, if the order
is not IsSuccArchimedean, derive False. This is the core of Reynolds Theorem 14.

The argument: ¬IsSuccArchimedean → gap exists. The gap's cut C is closed under
successor (proved from the Gap axioms + SuccOrder). By h_accessible, every
predicate is detectable by a temporal formula. The model surgery argument shows
that the gap is incompatible with Prior-UZ/SZ.

**Status**: sorry'd pending full Reynolds model surgery (Lemmas 6-13).
-/
private theorem prior_implies_archimedean_of_accessible (sig : MonadicSignature)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_prior_UZ : semantic_prior_UZ M atomMap)
    (h_prior_SZ : semantic_prior_SZ M atomMap)
    (h_accessible : all_predicates_accessible M atomMap)
    (h_not_arch : ¬ @IsSuccArchimedean M.carrier inferInstance inferInstance) :
    False := by
  -- If not archimedean, gap exists
  have ⟨γ⟩ := gap_of_not_succ_archimedean h_not_arch
  -- The gap γ has cut C that is:
  -- - nonempty, proper, downward-closed
  -- - no supremum in C (so C has no maximum)
  -- - complement has no minimum
  --
  -- In a SuccOrder, C is closed under successor:
  --   If x ∈ C and succ(x) ∉ C, then for all y ∉ C, x < y (downward-closed C).
  --   So succ(x) ≤ y for all y ∉ C, making succ(x) the minimum of the complement.
  --   But complement has no minimum, contradiction.
  --
  -- The full Reynolds model surgery (Lemmas 6-13) shows this gap is
  -- incompatible with Prior-UZ/SZ + h_accessible:
  -- 1. Construct temporal formula R detecting "in C" via US_expressively_complete
  -- 2. R transitions at a successor pair (by Prior-UZ)
  -- 3. But C is succ-closed, so R can't transition out of C at a successor pair
  -- 4. Model surgery: replace interval by single class, preserving temporal truth
  -- 5. Contradiction: R holds in the replaced class but the class ends at a
  --    successor pair (not a gap) in the surgery model
  sorry

/--
**no_gaps_discrete with accessibility** (Reynolds Theorem 14): In a discrete Prior
structure where all predicates are temporally accessible, contemporaneous equivalence
class boundaries occur only at successor pairs, never at gaps.

The proof: by `prior_implies_archimedean_of_accessible`, the order is IsSuccArchimedean.
By `one_class_archimedean`, all points are contemp_equiv. This contradicts h_diff_class.

**Sorry status**: inherits sorry from `prior_implies_archimedean_of_accessible`, which
requires the full Reynolds model surgery (Lemmas 6-13).
-/
theorem no_gaps_discrete_model_surgery (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_prior_UZ : semantic_prior_UZ M atomMap)
    (h_prior_SZ : semantic_prior_SZ M atomMap)
    (h_accessible : all_predicates_accessible M atomMap)
    (a b : M.carrier) (h_diff_class : ¬ contemp_equiv sig k M a b) :
    ∃ (c : M.carrier), contemp_equiv sig k M a c ∧
      ¬ contemp_equiv sig k M a (Order.succ c) := by
  -- By contradiction: assume no successor boundary
  by_contra h_no_boundary
  -- The order must be IsSuccArchimedean (by prior_implies_archimedean_of_accessible)
  -- If archimedean, then one_class_archimedean gives a ~M b, contradicting h_diff_class
  have h_arch : @IsSuccArchimedean M.carrier inferInstance inferInstance := by
    by_contra h_not_arch
    exact prior_implies_archimedean_of_accessible sig M atomMap h_prior_UZ h_prior_SZ
      h_accessible h_not_arch
  exact h_diff_class (one_class_archimedean sig k M a b)

end Bimodal.Metalogic.WeakCanonical
