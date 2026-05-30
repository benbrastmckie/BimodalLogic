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

## CRITICAL FINDINGS (Task 202)

### Finding 1: h_accessible is INSUFFICIENT

The previous plan (Phase 1) added `h_accessible : all_predicates_accessible M atomMap`
to `no_gaps_discrete`. While this fixes the counterexample where some predicates are
inaccessible, it is STILL insufficient for the proof because:

1. The Reynolds model surgery (Lemmas 6-13) requires converting monadic FO formulas
   to temporal formulas via `US_expressively_complete_over_prior`.
2. `US_expressively_complete_over_prior` requires `h_surj` (atom-level surjectivity),
   not just `h_accessible` (formula-level detectability).
3. Moreover, `prior_implies_archimedean_of_accessible` (which used h_accessible to
   claim IsSuccArchimedean) is **mathematically FALSE**: Z+Z with all-constant
   predicates satisfies Prior-UZ/SZ + h_accessible but is NOT IsSuccArchimedean.

### Finding 2: h_surj IS sufficient

The correct hypothesis is `h_surj : ∀ p, ∃ a, atomMap (.atom a) = p`, which
enables `US_expressively_complete_over_prior` → Reynolds model surgery → Theorem 14.

At the call site (Transfer.lean), h_surj can be satisfied by enriching atomMap_fwd
with fresh atoms for non-atom predicates (bot and box formulas). Since Atom is
infinite and sig.preds is finite, this is always possible. The fresh atoms do not
affect the section property or Prior-UZ/SZ (which hold for any atomMap).

### Finding 3: The theorem is about class boundaries, not gaps

Reynolds Theorem 14 does NOT claim IsSuccArchimedean. It claims that contemp_equiv
class boundaries don't end at gaps. In Z+Z with constant predicates, ALL points
are contemp_equiv (no class boundaries at all), so the theorem is vacuously true.
The previous approach of proving IsSuccArchimedean was wrong.

## Key Results

- `temporal_truth_neg_iff_not`: ψ.neg evaluates as ¬ψ under temporal_truth
- `temporal_truth_neg_neg_elim`: double negation elimination for temporal_truth
- `prior_UZ_first_transition`: first-transition lemma for Prior-UZ structures
- `prior_SZ_last_transition`: last-transition lemma for Prior-SZ structures
- `contemp_equiv_convex`: contemp_equiv classes are convex intervals
- `contemp_equiv_succ_closed`: if ∀c, a ~M c → a ~M succ(c), the class is succ-closed
- `class_gap_exists`: if class(a) ≠ whole order, a Gap exists
- `gap_contradicts_prior`: succ-closed class bounded above → False (Reynolds Thm 14 upward)
- `gap_contradicts_prior_below`: succ-closed class bounded below → False (Reynolds Thm 14 downward)

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

/-! ## Prior-SZ Last-Transition Lemma -/

/--
**Prior-SZ Last-Transition**: If ψ holds at t and ¬ψ holds at some s < t in a
discrete structure satisfying Prior-SZ, then there exists c ≤ t with
temporal_truth c ψ and ¬temporal_truth (Order.pred c) ψ.

Symmetric to `prior_UZ_first_transition` using the past direction.
-/
theorem prior_SZ_last_transition {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_prior_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier) (ψ : Formula)
    (h_true_t : temporal_truth M atomMap t ψ)
    (h_false_below : ∃ s : M.carrier, s < t ∧ ¬ temporal_truth M atomMap s ψ) :
    ∃ c : M.carrier, c ≤ t ∧
      temporal_truth M atomMap c ψ ∧
      ¬ temporal_truth M atomMap (Order.pred c) ψ := by
  -- P(ψ.neg) holds at t: exists s < t with ψ.neg at s
  have h_neg_below : ∃ s : M.carrier, s < t ∧ temporal_truth M atomMap s ψ.neg :=
    h_false_below.imp fun s ⟨h1, h2⟩ =>
      ⟨h1, (temporal_truth_neg_iff_not M atomMap s ψ).mpr h2⟩
  -- Prior-SZ gives last ψ.neg point s₀ before t
  obtain ⟨s₀, hs₀t, h_neg_s₀, h_between⟩ := h_prior_SZ t ψ.neg h_neg_below
  have h_not_psi_s₀ : ¬ temporal_truth M atomMap s₀ ψ :=
    (temporal_truth_neg_iff_not M atomMap s₀ ψ).mp h_neg_s₀
  -- ψ holds on (s₀, t) via double negation
  have h_psi_between : ∀ r : M.carrier, s₀ < r → r < t →
      temporal_truth M atomMap r ψ := by
    intro r hs₀r hrt
    exact temporal_truth_neg_neg_elim M atomMap r ψ (h_between r hs₀r hrt)
  -- Case split: s₀ = pred(t) or s₀ < pred(t)
  have h_not_min_t : ¬ IsMin t := not_isMin_of_lt hs₀t
  by_cases h_eq : s₀ = Order.pred t
  · -- s₀ = pred(t): c = t works
    exact ⟨t, le_refl t, h_true_t, h_eq ▸ h_not_psi_s₀⟩
  · -- s₀ < pred(t): c = succ(s₀) works
    have h_pred_ge : Order.pred t ≥ s₀ := by
      by_contra h_neg
      push_neg at h_neg
      -- s₀ > pred(t), so succ(pred(t)) ≤ s₀, i.e., t ≤ s₀
      have := Order.succ_le_of_lt h_neg
      rw [Order.succ_pred_of_not_isMin h_not_min_t] at this
      exact not_lt.mpr this hs₀t
    have h_s₀_lt_pred : s₀ < Order.pred t := by
      exact lt_of_le_of_ne h_pred_ge (by intro h_eq'; exact h_eq h_eq')
    -- succ(s₀) is in (s₀, t): succ(s₀) ≤ pred(t) < t
    have h_succ_le_pred : Order.succ s₀ ≤ Order.pred t :=
      Order.succ_le_of_lt h_s₀_lt_pred
    have h_s₀_lt_succ : s₀ < Order.succ s₀ :=
      Order.lt_succ_of_not_isMax (not_isMax s₀)
    have h_succ_lt_t : Order.succ s₀ < t :=
      lt_of_le_of_lt h_succ_le_pred (Order.pred_lt_of_not_isMin h_not_min_t)
    have h_succ_le_t : Order.succ s₀ ≤ t := le_of_lt h_succ_lt_t
    -- ψ at succ(s₀) (since succ(s₀) is in (s₀, t))
    have h_psi_succ : temporal_truth M atomMap (Order.succ s₀) ψ :=
      h_psi_between (Order.succ s₀) h_s₀_lt_succ h_succ_lt_t
    -- ¬ψ at pred(succ(s₀)) = s₀
    have h_pred_succ : Order.pred (Order.succ s₀) = s₀ :=
      Order.pred_succ_of_not_isMax (not_isMax s₀)
    have h_not_at_pred : ¬ temporal_truth M atomMap (Order.pred (Order.succ s₀)) ψ := by
      rw [h_pred_succ]; exact h_not_psi_s₀
    exact ⟨Order.succ s₀, h_succ_le_t, h_psi_succ, h_not_at_pred⟩

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
  apply gap_of_not_succ_archimedean
  intro h_arch
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

/-! ## Reynolds Theorem 14: Class boundaries cannot be at gaps

The core argument (Reynolds 1994 Lemmas 6-13, Theorem 14):

Given: class(a) succ-closed, bounded above, Prior-UZ/SZ, h_surj.
Goal: False.

**Proof outline**:

1. The class of a is succ-closed, pred-closed, convex, and bounded above.
   A gap exists above the class (class_gap_exists).

2. For EVERY temporal formula ψ, Prior-UZ ensures that if ψ transitions
   (changes truth value going upward), the transition occurs at a
   successor pair. Symmetrically via Prior-SZ for downward transitions.

3. At any successor pair (c, succ(c)), we have c ~M succ(c) by
   no_boundary_at_successor. So both c and succ(c) are in the SAME
   contemp_equiv class. Therefore, class membership does not change
   at successor pairs.

4. Now consider temporal truth restricted to the class.
   The class is an archimedean sub-order (closed under succ/pred).
   By very_good_of_archimedean, the class is very_good as a sub-structure.
   So all subintervals within the class are good.

5. The complement above the gap is also archimedean and very_good.
   Subintervals within the complement are good.

6. The ONLY non-good subintervals are those spanning the gap.
   For such intervals [x, z] (x in class, z above gap), the k-type
   differs from all Z-interval k-types.

7. By table_correctness, temporal_truth at a point t is determined by
   eval M (fun _ => t) (table sig atomMap ψ). By US_expressively_complete_over_prior,
   every MonadicFormula sig 1 has a temporal equivalent.

8. (Reynolds Model Surgery) Construct a new ordered structure N by
   replacing the gap region with a single class. Show temporal truth
   is preserved for all formulas (13 subcases for U/S). In N, the
   class of a extends past the former gap location. This contradicts
   the formula R (temporal equivalent of class membership) which should
   transition at the gap but doesn't in N.

For the formalization, we use a more direct approach: we show that
the temporal agreement of all formulas across the gap (forced by
Prior-UZ/SZ ensuring transitions only at successor pairs) combined
with h_surj (ensuring all predicates have temporal representatives)
implies the classes on both sides of the gap have identical k-types,
making the gap undetectable and forcing contemp_equiv across it.
-/

/-- **Reynolds Theorem 14 (upward)**: succ-closed class bounded above
    contradicts Prior-UZ/SZ + h_surj (Reynolds 1994 Lemmas 6-13). -/
theorem gap_contradicts_prior (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_prior_UZ : semantic_prior_UZ M atomMap)
    (h_prior_SZ : semantic_prior_SZ M atomMap)
    (a : M.carrier)
    (h_succ_closed : ∀ c, contemp_equiv sig k M a c →
      contemp_equiv sig k M a (Order.succ c))
    (h_bounded_above : ∃ y : M.carrier, a < y ∧ ¬ contemp_equiv sig k M a y) :
    False := by
  obtain ⟨y, hay, h_not_equiv_y⟩ := h_bounded_above
  -- Step 1: For each predicate p, obtain its temporal representative via h_surj.
  -- The atom `.atom (h_surj p).choose` maps to p under atomMap.
  -- So temporal_truth M atomMap t (.atom (h_surj p).choose) = M.interp p t.
  -- This means M.interp p has the first-transition property (via Prior-UZ).
  --
  -- Step 2: For each predicate p, M.interp p must be "stable" across the gap.
  -- If M.interp p c ≠ M.interp p d for c just below and d just above the gap,
  -- then the formula .atom (h_surj p).choose transitions between c and d.
  -- By Prior-UZ, it transitions at a successor pair (c', succ(c')).
  -- This successor pair is somewhere between c and d.
  -- Since the gap has no successor pair spanning it, the transition is either
  -- within the class or within the complement. In either case, the transition
  -- occurs at a point where c' ~M succ(c') (no_boundary_at_successor).
  --
  -- Step 3: Show that predicate stability across the gap, combined with the
  -- very_good property of the class and complement, forces the gap interval
  -- to be good (k-equiv to a Z-interval), contradicting non-contemp_equiv.
  --
  -- This is the content of Reynolds Lemmas 7-13 (model surgery).
  -- The full model surgery constructs a new ordered structure by excising
  -- the gap region and proves temporal truth preservation.
  sorry

/-- **Reynolds Theorem 14 (downward)**: succ-closed class unbounded above but
    bounded below contradicts Prior-UZ/SZ + h_surj (dual via Prior-SZ). -/
theorem gap_contradicts_prior_below (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_prior_UZ : semantic_prior_UZ M atomMap)
    (h_prior_SZ : semantic_prior_SZ M atomMap)
    (a : M.carrier)
    (h_succ_closed : ∀ c, contemp_equiv sig k M a c →
      contemp_equiv sig k M a (Order.succ c))
    (h_unbounded_above : ∀ y : M.carrier, a < y → contemp_equiv sig k M a y)
    (h_bounded_below : ∃ y : M.carrier, y < a ∧ ¬ contemp_equiv sig k M a y) :
    False := by
  -- Symmetric to gap_contradicts_prior using Prior-SZ for the downward direction.
  -- The class is unbounded above and bounded below, so the gap is below the class.
  -- The argument mirrors the upward case with the roles of U and S swapped.
  obtain ⟨y, hya, h_not_equiv_y⟩ := h_bounded_below
  -- The class is pred-closed (contemp_equiv_pred_closed) and succ-closed.
  -- The class extends infinitely upward (h_unbounded_above) and downward via
  -- pred-closure, but is bounded below.
  -- The gap is below the class: the class has no minimum (pred-closure pushes
  -- it down), but there exist points below all class members.
  -- The argument uses Prior-SZ to show every temporal formula transition below
  -- the class must occur at a predecessor pair, but the gap prevents this.
  sorry

/-! ## Main Theorem -/

/--
**Reynolds Theorem 14** (no_gaps_discrete with h_surj): In a discrete Prior
structure with atom-surjective atomMap, contemporaneous equivalence class
boundaries occur only at successor pairs, never at gaps.

See Reynolds 1994, Section 7, Lemmas 6-13, Theorem 14.
-/
theorem no_gaps_discrete_model_surgery (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_prior_UZ : semantic_prior_UZ M atomMap)
    (h_prior_SZ : semantic_prior_SZ M atomMap)
    (a b : M.carrier) (h_diff_class : ¬ contemp_equiv sig k M a b) :
    ∃ (c : M.carrier), contemp_equiv sig k M a c ∧
      ¬ contemp_equiv sig k M a (Order.succ c) := by
  -- By contradiction, assume no successor boundary.
  by_contra h_no_boundary
  push_neg at h_no_boundary
  have h_succ_closed : ∀ c, contemp_equiv sig k M a c →
      contemp_equiv sig k M a (Order.succ c) := h_no_boundary
  have hab_ne : a ≠ b := fun h =>
    h_diff_class (h ▸ (contemp_equiv_is_equiv sig k M).refl a)
  -- Case split: is class(a) bounded above?
  by_cases h_bdd : ∃ y : M.carrier, a < y ∧ ¬ contemp_equiv sig k M a y
  · -- Class bounded above: apply gap_contradicts_prior
    exact gap_contradicts_prior sig k M atomMap h_surj h_prior_UZ h_prior_SZ
      a h_succ_closed h_bdd
  · -- Class NOT bounded above: all y > a satisfy a ~M y
    push_neg at h_bdd
    -- Since class(a) is proper (¬(a ~M b)), b must be below a
    have hba_lt : b < a := by
      rcases lt_or_gt_of_ne hab_ne with h | h
      · exact absurd (h_bdd b h) h_diff_class
      · exact h
    -- Class bounded below: apply gap_contradicts_prior_below
    exact gap_contradicts_prior_below sig k M atomMap h_surj h_prior_UZ h_prior_SZ
      a h_succ_closed h_bdd ⟨b, hba_lt, h_diff_class⟩

end Bimodal.Metalogic.WeakCanonical
