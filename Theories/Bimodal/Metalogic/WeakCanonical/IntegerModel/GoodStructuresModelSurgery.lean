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

## Architecture

The proof chain is:

```
gap_prior_UZ_contradiction (SORRY: Reynolds Lemmas 6-13, upward case)
gap_prior_SZ_contradiction (SORRY: Reynolds Lemmas 6-13, downward case)
  <- reynolds_model_surgery_core (sorry-free given above)
    <- gap_contradicts_prior (sorry-free)
    <- gap_contradicts_prior_below (sorry-free)
    <- no_gaps_discrete_model_surgery (sorry-free)
```

The two sorry sites are `gap_prior_UZ_contradiction` and
`gap_prior_SZ_contradiction`, which encapsulate the Reynolds model surgery
argument (Lemmas 6-13) for the upward and downward cases respectively.
Each requires constructing a gap-detecting temporal formula, performing
domain surgery, and proving temporal truth preservation. See the section
comment above `gap_prior_UZ_contradiction` for the detailed proof sketch
and the docstring on
`reynolds_model_surgery_core` for the detailed proof sketch.

## Key Hypotheses

- `h_surj : ∀ p, ∃ a, atomMap (.atom a) = p` -- atom-level surjectivity,
  enables `US_expressively_complete_over_prior` (Reynolds Theorem 5).
  Satisfied at the call site (Transfer.lean) by enriching atomMap with
  fresh atoms for non-atom predicates. The previous `h_accessible`
  hypothesis was INSUFFICIENT (Z+Z counterexample).

- `no_boundary_at_successor` (GoodStructures.lean, sorry-free) -- guarantees
  c ~M succ(c) for ALL c, making h_succ_closed trivially true. The real
  content of Theorem 14 is: h_surj + Prior-UZ/SZ implies one class.

## Key Results

### Sorry-free infrastructure
- `temporal_truth_neg_iff_not`: ψ.neg evaluates as ¬ψ under temporal_truth
- `temporal_truth_neg_neg_elim`: double negation elimination for temporal_truth
- `prior_UZ_first_transition`: first-transition lemma for Prior-UZ structures
- `prior_SZ_last_transition`: last-transition lemma for Prior-SZ structures
- `contemp_equiv_convex`: contemp_equiv classes are convex intervals
- `contemp_equiv_succ_closed_of_no_boundary`: class closed under succ if no boundary
- `contemp_equiv_pred_closed`: class closed under predecessor
- `contemp_equiv_succ_iterate`: class closed under successor iteration
- `class_gap_exists`: if class(a) ≠ whole order, a Gap exists
- `cut_succ_closed`: gap's cut is closed under successor
- `complement_pred_closed`: gap's complement is closed under predecessor
- `class_pred_closed`: class(a) pred-closed (delegates to contemp_equiv_pred_closed)
- `class_boundary_gap`: class boundary → NOT IsSuccArchimedean
- `reynolds_model_surgery_core`: class(a) succ-closed → class(a) = whole carrier
  (sorry-free given gap_prior_UZ/SZ_contradiction)
- `gap_contradicts_prior`: succ-closed class bounded above → False
- `gap_contradicts_prior_below`: succ-closed class bounded below → False
- `no_gaps_discrete_model_surgery`: main theorem (sorry-free given core)

### Sorry (2 remaining)
- `gap_prior_UZ_contradiction`: class(a) bounded above with gap → False
  (Reynolds Lemmas 6-13, upward case, ~300 lines)
- `gap_prior_SZ_contradiction`: class(a) bounded below with gap → False
  (Reynolds Lemmas 6-13, downward case, ~300 lines)

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

Given: class(a) succ-closed, Prior-UZ/SZ, h_surj.
Goal: class(a) = whole carrier (i.e., ∀ y, contemp_equiv a y).

The sorry-free infrastructure in this section provides:
- `cut_succ_closed`: gap's cut is closed under successor
- `complement_upward_closed`: complement of downward-closed set is upward-closed
- `complement_pred_closed`: complement of gap's cut is closed under predecessor

The proof chain `no_gaps_discrete_model_surgery` -> `gap_contradicts_prior` /
`gap_contradicts_prior_below` -> `reynolds_model_surgery_core` reduces the
problem to a single sorry at `reynolds_model_surgery_core`.

See Reynolds 1994, Section 7, Lemmas 6-13, Theorem 14.
-/

/-! ### Gap structural lemmas -/

/-- In a discrete order without max, a downward-closed set with no supremum
    in the set is closed under successor. -/
theorem cut_succ_closed {T : Type} [LinearOrder T] [SuccOrder T] [NoMaxOrder T]
    (S : Set T) (h_down : ∀ x y, x ∈ S → y ≤ x → y ∈ S)
    (h_no_sup : ¬∃ s, IsLUB S s ∧ s ∈ S) (x : T) (hx : x ∈ S) :
    Order.succ x ∈ S := by
  by_contra h_not
  have h_ub : ∀ z ∈ S, z ≤ x := by
    intro z hz
    by_contra h_gt
    push_neg at h_gt
    have h_succ_le : Order.succ x ≤ z := Order.succ_le_of_lt h_gt
    exact h_not (h_down z (Order.succ x) hz h_succ_le)
  exact h_no_sup ⟨x, ⟨fun z hz => h_ub z hz, fun u hu => hu hx⟩, hx⟩

/-- The complement of a gap's cut is closed under successor (upward-closed). -/
theorem complement_upward_closed {T : Type} [LinearOrder T]
    (S : Set T) (h_down : ∀ x y, x ∈ S → y ≤ x → y ∈ S)
    (x : T) (hx : x ∉ S) (y : T) (hxy : x ≤ y) : y ∉ S := by
  intro hy
  exact hx (h_down y x hy hxy)

/-- The complement of a gap's cut is closed under predecessor (in discrete
    order with no max, if the cut has no sup in the cut). -/
theorem complement_pred_closed {T : Type} [LinearOrder T]
    [SuccOrder T] [PredOrder T] [NoMaxOrder T]
    (S : Set T) (h_down : ∀ x y, x ∈ S → y ≤ x → y ∈ S)
    (h_no_sup : ¬∃ s, IsLUB S s ∧ s ∈ S)
    (_h_no_min : ¬∃ m, m ∉ S ∧ ∀ y, y ∉ S → m ≤ y)
    (x : T) (hx : x ∉ S) : Order.pred x ∉ S := by
  intro h_pred_in
  have h_succ_in := cut_succ_closed S h_down h_no_sup (Order.pred x) h_pred_in
  by_cases h_min : IsMin x
  · have : Order.pred x = x := le_antisymm (Order.pred_le x) (h_min (Order.pred_le x))
    rw [this] at h_pred_in; exact hx h_pred_in
  · rw [Order.succ_pred_of_not_isMin h_min] at h_succ_in
    exact hx h_succ_in

/-! ### Reynolds Model Surgery Core

**Reynolds Theorem 14** (Reynolds 1994, Section 7, Lemmas 6-13):

Given a discrete Prior structure with atom-surjective atomMap (h_surj),
if a contemp_equiv class is succ-closed, then it equals the whole carrier.
Equivalently: class boundaries cannot occur at Dedekind gaps.

**Proof sketch** (Reynolds' original argument):

1. Construct rho(x) : MonadicFormula sig 1 encoding "right_gap_class"
   (x's ~M-class ends in a gap on the right). This is expressible because
   ~M is defined by a monadic FO formula epsilon(x,y) with TWO free
   variables, and rho(x) quantifies over y.
2. Get temporal formula R for rho via US_expressively_complete_over_prior.
3. Prove R-interval properties (Lemma 7): maximal R-intervals are open,
   bounded by elements of M.
4. Prove no first/last class in R-intervals (Lemma 8).
5. Prove class homogeneity in R-intervals (Lemma 9).
6. Define bad intervals and prove formula propagation (Lemmas 10-11).
7. Construct model surgery (Lemma 12): excise a maximal bad interval,
   replace by a single representative class.
8. Prove temporal truth preservation for all formula constructors
   (Lemma 12 continued, 13 subcases for Until/Since).
9. Derive contradiction (Lemma 13 + Theorem 14): in the surgery model,
   the class boundary is at a point (not a gap), contradicting R.

Estimated effort: 400-600 lines.

**Historical note**: A previous version attempted to use a class-detecting
formula (class_temporal_formula) that would find a temporal formula R with
`temporal_truth t R <-> contemp_equiv a t`. This is UNPROVABLE because:
- contemp_equiv depends on a fixed element `a`, but MonadicFormula sig 1
  has only ONE free variable (for `t`) and cannot reference `a`.
- Enriched-signature workarounds are circular (Prior-UZ for class membership
  fails at gap boundaries, which is what Theorem 14 proves).
The correct approach uses right_gap_class (a structural property, not
class membership) and the full model surgery argument.
-/

/- **Reynolds Theorem 14 core** (Reynolds 1994, Lemmas 6-13):
    In a discrete Prior structure with atom-surjective atomMap, if class(a)
    is succ-closed then class(a) = whole carrier.

    The proof requires the full model surgery argument (Lemmas 6-13).
    See the docstring on `reynolds_model_surgery_core` below.

    `no_boundary_at_successor` (sorry-free) guarantees that h_succ_closed
    is trivially satisfied in practice, since c ~M succ(c) for all c.
    The real content is: h_surj + Prior-UZ/SZ -> one class. -/

/-! #### Helper: class(a) is pred-closed under h_succ_closed -/

/--
If class(a) is succ-closed, it is also pred-closed: for all c, a ~M c implies
a ~M pred(c). This combines `contemp_equiv_pred_closed` with h_succ_closed.
-/
private theorem class_pred_closed (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    (a : M.carrier)
    (_h_succ_closed : ∀ c, contemp_equiv sig k M a c →
      contemp_equiv sig k M a (Order.succ c))
    (c : M.carrier) (hac : contemp_equiv sig k M a c) :
    contemp_equiv sig k M a (Order.pred c) :=
  contemp_equiv_pred_closed sig k M a c hac

/-! #### Helper: class(a) boundary is a Gap -/

/--
If class(a) is succ-closed, pred-closed, and proper (not the whole carrier),
then the class boundary above `a` is a Dedekind gap.

More precisely: the set `{x | contemp_equiv sig k M a x}` is:
- Nonempty (contains a)
- Proper (assumption)
- Convex (by contemp_equiv_convex and equivalence)
- Succ-closed (no max element in the class, within the upward direction)
- Pred-closed (no min element in the class)

If there exists y > a not in class(a), then the cut
`{x | contemp_equiv sig k M a x ∧ x ≤ y_bound}` restricted to the relevant
region forms a gap.
-/
private theorem class_boundary_gap (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (a : M.carrier)
    (_h_succ_closed : ∀ c, contemp_equiv sig k M a c →
      contemp_equiv sig k M a (Order.succ c))
    (y : M.carrier) (_hay : a < y)
    (h_not_equiv : ¬ contemp_equiv sig k M a y) :
    ¬ @IsSuccArchimedean M.carrier inferInstance (inferInstance : SuccOrder M.carrier) := by
  intro h_arch
  exact h_not_equiv (one_class_archimedean sig k M a y)

/-! #### Reynolds Model Surgery: Gap contradiction (Lemmas 6-13)

The following two theorems are the mathematical core of Reynolds Theorem 14.
They state that in a Prior structure with h_surj, if class(a) is succ-closed,
then having a point outside class(a) (above or below) leads to contradiction.

The proof requires the full Reynolds model surgery argument (Lemmas 6-13):

1. **Lemma 6**: Construct temporal formula R detecting "right_gap_class"
   (a point whose contemp_equiv class has a gap boundary on the right).
   right_gap_class IS definable as MonadicFormula sig 1 because:
   - contemp_equiv(x,y) = very_good(M|[x,y]) is a monadic FO sentence
     with 2 free variables (quantifying over subintervals and Z-interval
     k-types, all of which are in monadic FO due to finiteness of NormalForm)
   - right_gap_class(x) = "exists y > x, NOT contemp_equiv x y" AND
     "for all c, contemp_equiv x c -> contemp_equiv x (succ c)"
   - Apply US_expressively_complete_over_prior to get temporal formula R

2. **Lemmas 7-8**: R-interval properties. Maximal intervals where R holds
   are open (R holds at succ(t) if R holds at t, by no_boundary_at_successor +
   class invariance). No first/last class in R-intervals.

3. **Lemma 9**: Class homogeneity in R-intervals. All classes in a maximal
   R-interval are elementarily equivalent (same monadic FO theory). Proof:
   if formula A differs between classes C1 and C2, construct B = "A occurs
   in my class". B transitions at a successor pair (Prior-UZ). But the class
   boundary is a gap. Contradiction.

4. **Lemmas 10-11**: Bad intervals and formula propagation. In a maximal
   R-interval (or R-and-L-interval), both R and L hold throughout. Formulas
   propagate throughout bad intervals via class homogeneity.

5. **Lemma 12**: Model surgery. Choose a maximal bad interval Q0 and one
   class I inside it. Construct surgery domain Q- ∪ I ∪ Q+ (removing Q0
   except for I). The surgery model inherits predicates and order from M.

6. **Lemma 12 continued**: Temporal truth preservation M ↔ N for all
   formula constructors. The atom/bot/imp/box cases are trivial. The U(A,B)
   case has 7 forward subcases and 6 backward subcases. The S(A,B) case
   mirrors U(A,B). Total: 26 subcases (13 for U, 13 for S).

7. **Lemma 13 + Theorem 14**: In the surgery model N, the class containing
   I ends at a point (not a gap), so right_gap_class is False at I in N.
   But temporal truth preservation says R(I) in N iff R(I) in M. Since
   R(I) is True in M (I is in a right_gap_class), R(I) should be True in N.
   Contradiction.

**Available sorry-free infrastructure** (used but not proven here):
- `US_expressively_complete_over_prior` (PriorExpressiveness.lean)
- `contemp_equiv_is_equiv`, `no_boundary_at_successor` (GoodStructures.lean)
- `contemp_equiv_convex`, `contemp_equiv_pred_closed` (this file)
- `contemp_equiv_succ_iterate`, `class_gap_exists` (this file)
- `prior_UZ_first_transition`, `prior_SZ_last_transition` (this file)
- `gap_of_not_succ_archimedean`, `one_class_archimedean` (ReynoldsNoGaps.lean)

**Estimated effort**: 400-600 lines for the full implementation.
-/

/-!
#### Right Gap Class Infrastructure (Reynolds Lemma 6 prerequisites)

The `right_gap_class_prop` predicate encodes "t's contemp_equiv class is bounded
above and the class is succ-closed" (i.e., the upper boundary is a gap, not a
successor-pair boundary). This is the predicate that Reynolds' Lemma 6 shows is
expressible as a monadic FO formula, which then yields a temporal formula via
US expressive completeness.

The sorry-free infrastructure here establishes that right_gap_class_prop is:
- Invariant within contemp_equiv classes (`right_gap_class_invariant`)
- Preserved under successor (`right_gap_class_succ`)
These properties are used in the proof of `gap_prior_UZ_contradiction`.
-/

/-- Right gap class property: t's contemp_equiv class is bounded above
    and the class is succ-closed (meaning the upper boundary is a gap,
    not a successor-pair boundary). -/
private def right_gap_class_prop (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) [SuccOrder M.carrier]
    (t : M.carrier) : Prop :=
  (∃ b : M.carrier, t < b ∧ ¬ contemp_equiv sig k M t b) ∧
  (∀ c : M.carrier, contemp_equiv sig k M t c →
    contemp_equiv sig k M t (Order.succ c))

/-- Right gap class is invariant within a contemp_equiv class:
    if t ~M s and right_gap_class(t), then right_gap_class(s).
    Proof: t and s are in the same class, so the class structure
    (bounded above, succ-closed) is the same for both. -/
private theorem right_gap_class_invariant (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [NoMaxOrder M.carrier]
    (t s : M.carrier)
    (hts : contemp_equiv sig k M t s)
    (h_rgc : right_gap_class_prop sig k M t) :
    right_gap_class_prop sig k M s := by
  obtain ⟨⟨b, htb, h_nb⟩, h_sc⟩ := h_rgc
  refine ⟨?_, ?_⟩
  · -- s's class is bounded above
    have h_not_sb : ¬ contemp_equiv sig k M s b := fun hsb =>
      h_nb ((contemp_equiv_is_equiv sig k M).trans hts hsb)
    rcases le_or_lt s b with hsb_le | hbs
    · rcases eq_or_lt_of_le hsb_le with rfl | hsb_lt
      · exact absurd hts h_nb
      · exact ⟨b, hsb_lt, h_not_sb⟩
    · -- b < s with t < b < s and t ~M s: convexity gives t ~M b, contradiction
      exact absurd (contemp_equiv_convex sig k M t b s (le_of_lt htb) (le_of_lt hbs) hts) h_nb
  · -- s's class is succ-closed
    intro c hsc
    -- t ~M s (hts), s ~M c (hsc). Need t ~M c.
    -- trans(symm(hts), hsc) won't work directly because symm(hts) : s ~M t
    -- and then trans(s ~M t, s ~M c) doesn't type-check.
    -- We need: trans(t ~M s, s ~M c) but the Equivalence.trans takes (a ~M b, b ~M c).
    -- So we need hts : t ~M s and hsc : s ~M c → trans hts hsc : t ~M c.
    -- Wait, hts is `contemp_equiv sig k M t s` and hsc is `contemp_equiv sig k M s c`.
    -- Equivalence.trans has type: a ~M b → b ~M c → a ~M c. So trans hts hsc works!
    have htc := (contemp_equiv_is_equiv sig k M).trans hts hsc
    have ht_succ_c := h_sc c htc
    -- Now: t ~M succ(c). Need s ~M succ(c).
    -- s ~M t (symm hts), t ~M succ(c) → s ~M succ(c)
    exact (contemp_equiv_is_equiv sig k M).trans
      ((contemp_equiv_is_equiv sig k M).symm hts) ht_succ_c

/-- If right_gap_class(t), then right_gap_class(succ(t)).
    Follows from right_gap_class_invariant and no_boundary_at_successor. -/
private theorem right_gap_class_succ (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [NoMaxOrder M.carrier]
    (t : M.carrier)
    (h_rgc : right_gap_class_prop sig k M t) :
    right_gap_class_prop sig k M (Order.succ t) :=
  right_gap_class_invariant sig k M t (Order.succ t)
    (no_boundary_at_successor sig k M t) h_rgc

/-- Right gap class is preserved under predecessor.
    Follows from right_gap_class_invariant and contemp_equiv_pred_closed. -/
private theorem right_gap_class_pred (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    (t : M.carrier)
    (h_rgc : right_gap_class_prop sig k M t) :
    right_gap_class_prop sig k M (Order.pred t) := by
  apply right_gap_class_invariant sig k M t (Order.pred t) _ h_rgc
  -- Need: t ~M pred(t). contemp_equiv_pred_closed gives a ~M pred(c) from a ~M c.
  -- With a = t, c = t: t ~M pred(t).
  exact contemp_equiv_pred_closed sig k M t t ((contemp_equiv_is_equiv sig k M).refl t)

/-!
#### Good Sentence and Gap Formula Construction (Reynolds Lemma 6)

Infrastructure for expressing `good`, `very_good`, `contemp_equiv`, and
`right_gap_class_prop` as MonadicFormulas, then deriving the temporal
formula R via `US_expressively_complete_over_prior`.
-/

/-- A NormalForm `nf` is a Z-type if some Z-interval structure satisfies it. -/
private noncomputable def is_Z_type (sig : MonadicSignature) (k : Nat)
    (nf : NormalForm sig k 0) : Bool :=
  @decide (∃ Z : ZIntervalStructure sig,
    nf_eval_nf (Z.toOrdered sig) k 0 Fin.elim0 nf) (Classical.dec _)

/-- MonadicSentence encoding `good sig k`: true in S iff S is good (k-equiv
    to some Z-interval structure). Defined as finite disjunction over Z-types
    of the NF-checking sentences. -/
private noncomputable def good_sentence (sig : MonadicSignature) (k : Nat) :
    MonadicSentence sig :=
  MonadicFormula.listDisj
    ((Finset.univ.toList.filter (is_Z_type sig k)).map (nf_to_sentence (k := k)))

/-- `good_sentence` correctly captures `good`: eval S Fin.elim0 (good_sentence sig k) ↔ good sig k S. -/
private theorem good_sentence_correct (sig : MonadicSignature) (k : Nat)
    (S : OrderedMonadicStructure sig) :
    eval S Fin.elim0 (good_sentence sig k) ↔ good sig k S := by
  simp only [good_sentence, eval_listDisj]
  constructor
  · -- Forward: eval of disjunction → good
    intro ⟨φ, hφ_mem, hφ_eval⟩
    simp only [List.mem_map, List.mem_filter, Finset.mem_toList, Finset.mem_univ,
      true_and] at hφ_mem
    obtain ⟨nf, h_is_Z, rfl⟩ := hφ_mem
    -- nf is a Z-type and S satisfies nf_to_sentence nf
    have h_eval : nf_eval_nf S k 0 Fin.elim0 nf :=
      (nf_to_sentence_correct S nf).mp hφ_eval
    -- Since nf is a Z-type, there exists Z with nf_eval_nf Z k 0 Fin.elim0 nf
    have h_z_type : ∃ Z : ZIntervalStructure sig,
        nf_eval_nf (Z.toOrdered sig) k 0 Fin.elim0 nf := by
      unfold is_Z_type at h_is_Z
      simp only [decide_eq_true_eq] at h_is_Z
      exact h_is_Z
    obtain ⟨Z, hZ⟩ := h_z_type
    -- k_equiv S Z via k_type_of equality
    refine ⟨Z, ?_⟩
    rw [k_equiv_iff_same_type]
    funext nf'
    simp only [k_type_of]
    congr 1
    exact propext (nf_agreement_from_shared_nf S Fin.elim0
      (Z.toOrdered sig) Fin.elim0 nf h_eval hZ nf')
  · -- Backward: good → eval of disjunction
    intro ⟨Z, h_k_equiv⟩
    -- Bridge k_equiv to nf_eval_nf
    have h_same_nf : ∀ nf : NormalForm sig k 0,
        nf_eval_nf S k 0 Fin.elim0 nf ↔
        nf_eval_nf (Z.toOrdered sig) k 0 Fin.elim0 nf := by
      intro nf
      have h := congr_fun (k_equiv_iff_same_type sig k S (Z.toOrdered sig) |>.mp h_k_equiv) nf
      simp [k_type_of] at h
      exact_mod_cast h
    -- S and Z satisfy the same NFs. Let nf_S = nf_characteristic S k 0 Fin.elim0.
    let nf_S := nf_characteristic S k 0 Fin.elim0
    have h_S_char := nf_characteristic_satisfies S k 0 Fin.elim0
    -- nf_S is a Z-type since Z satisfies it too
    have h_Z_sat : nf_eval_nf (Z.toOrdered sig) k 0 Fin.elim0 nf_S :=
      (h_same_nf nf_S).mp h_S_char
    have h_is_z : is_Z_type sig k nf_S = true := by
      unfold is_Z_type
      simp only [decide_eq_true_eq]
      exact ⟨Z, h_Z_sat⟩
    -- nf_to_sentence nf_S is in the filtered list
    have h_in_filter : nf_S ∈ Finset.univ.toList.filter (is_Z_type sig k) :=
      List.mem_filter.mpr ⟨Finset.mem_toList.mpr (Finset.mem_univ nf_S), h_is_z⟩
    have h_in : nf_to_sentence nf_S ∈
        (Finset.univ.toList.filter (is_Z_type sig k)).map (nf_to_sentence (k := k)) :=
      List.mem_map_of_mem h_in_filter
    exact ⟨nf_to_sentence nf_S, h_in,
      (nf_to_sentence_correct S nf_S).mpr h_S_char⟩

/-- MonadicFormula sig 2 encoding `good sig k (M.subinterval sig (var 0) (var 1))`.
    Uses `relativize_sentence` to express good on a subinterval. -/
private noncomputable def good_formula_relativized (sig : MonadicSignature) (k : Nat) :
    MonadicFormula sig 2 :=
  relativize_sentence (good_sentence sig k)

/-- `good_formula_relativized` correctly captures `good` on subintervals. -/
private theorem good_formula_relativized_correct (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) (lo hi : M.carrier) (h_le : lo ≤ hi) :
    eval M (Fin.cons lo (Fin.cons hi Fin.elim0)) (good_formula_relativized sig k) ↔
    good sig k (M.subinterval sig lo hi) := by
  unfold good_formula_relativized
  rw [relativize_sentence_correct M lo hi h_le (good_sentence sig k)]
  exact good_sentence_correct sig k (M.subinterval sig lo hi)

/-- Lift good_formula_relativized from MonadicFormula sig 2 to MonadicFormula sig 4,
    keeping references to var 0 (lo) and var 1 (hi) unchanged. -/
private noncomputable def good_rel_lifted (sig : MonadicSignature) (k : Nat) :
    MonadicFormula sig 4 :=
  (good_formula_relativized sig k).lift 2 |>.lift 3

/-- The MonadicFormula sig 1 encoding "class(t) is bounded above and not all
    elements above t are contemp_equiv to t". This is the first conjunct of
    right_gap_class_prop (the second conjunct is trivially true by
    no_boundary_at_successor).

    Formula: ∃ b. (t < b ∧ ∃ b'. ∃ a'. (t ≤ a' ∧ a' ≤ b' ∧ b' ≤ b ∧
                                          ¬good([a', b'])))

    In De Bruijn with 1 free var (t = var 0):
    - After ∃ b: t = var 1, b = var 0
    - After ∃ b': t = var 2, b = var 1, b' = var 0
    - After ∃ a': t = var 3, b = var 2, b' = var 1, a' = var 0
    good_rel_lifted uses var 0 = a' = lo, var 1 = b' = hi -/
private noncomputable def right_gap_class_formula (sig : MonadicSignature) (k : Nat) :
    MonadicFormula sig 1 :=
  -- ∃ b > t, ¬very_good [t, b]
  -- = ∃ b, t < b ∧ ∃ b', ∃ a', t ≤ a' ∧ a' ≤ b' ∧ b' ≤ b ∧ ¬good [a', b']
  .ex (.and
    (.lt ⟨1, by omega⟩ ⟨0, by omega⟩)  -- t < b (var 1 < var 0)
    (.ex (.ex (.and
      (.and
        (.and
          (MonadicFormula.leq ⟨3, by omega⟩ ⟨0, by omega⟩)  -- t ≤ a'
          (MonadicFormula.leq ⟨0, by omega⟩ ⟨1, by omega⟩)) -- a' ≤ b'
        (MonadicFormula.leq ⟨1, by omega⟩ ⟨2, by omega⟩))   -- b' ≤ b
      (.not (good_rel_lifted sig k))))))                     -- ¬good [a', b']

/-- `good_rel_lifted` evaluates to `good_formula_relativized` on the first two
    variables of the 4-variable environment. Since `.lift 2 |>.lift 3` only
    shifts variables at positions ≥ 2, vars 0 and 1 are preserved. -/
private theorem eval_good_rel_lifted {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig) (env : Fin 4 → M.carrier) :
    eval M env (good_rel_lifted sig k) ↔
    eval M (Fin.cons (env 0) (Fin.cons (env 1) Fin.elim0))
      (good_formula_relativized sig k) := by
  unfold good_rel_lifted
  -- Step 1: outer lift
  have step1 : eval M env ((good_formula_relativized sig k).lift 2 |>.lift 3) ↔
      eval M (fun (i : Fin 3) => env i.castSucc)
        ((good_formula_relativized sig k).lift 2) := by
    constructor <;> intro h
    all_goals {
      have key := @lift_eval _ _ M (fun i => env i.castSucc) ⟨3, by omega⟩ (env ⟨3, by omega⟩)
        ((good_formula_relativized sig k).lift 2)
      have h_eq : insertEnv ⟨3, by omega⟩ (env ⟨3, by omega⟩)
          (fun (i : Fin 3) => env i.castSucc) = env := by
        funext ⟨i, hi⟩
        simp only [insertEnv, Fin.castSucc]
        split_ifs with h1 h2 <;> first | rfl | skip
        · have hi3 : i = 3 := Fin.ext_iff.mp h2
          subst hi3; rfl
        · exfalso
          have : i ≠ 3 := fun heq => h2 (Fin.ext heq)
          omega
      rw [h_eq] at key
      first | rwa [key] | rwa [← key] }
  -- Step 2: inner lift
  have step2 : eval M (fun (i : Fin 3) => env i.castSucc)
      ((good_formula_relativized sig k).lift 2) ↔
      eval M (fun (i : Fin 2) => env i.castSucc.castSucc)
        (good_formula_relativized sig k) := by
    constructor <;> intro h
    all_goals {
      have key := @lift_eval _ _ M (fun i => env i.castSucc.castSucc) ⟨2, by omega⟩
        (env ⟨2, by omega⟩) (good_formula_relativized sig k)
      have h_eq : insertEnv ⟨2, by omega⟩ (env ⟨2, by omega⟩)
          (fun (i : Fin 2) => env i.castSucc.castSucc) =
          (fun (i : Fin 3) => env i.castSucc) := by
        funext ⟨i, hi⟩
        simp only [insertEnv, Fin.castSucc]
        split_ifs with h1 h2
        · rfl
        · have hi2 : i = 2 := Fin.ext_iff.mp h2
          subst hi2; rfl
        · exfalso
          have : i ≠ 2 := fun heq => h2 (Fin.ext heq)
          omega
      rw [h_eq] at key
      first | rwa [key] | rwa [← key] }
  -- Step 3: env agreement
  have step3 : (fun (i : Fin 2) => env i.castSucc.castSucc) =
      Fin.cons (env 0) (Fin.cons (env 1) Fin.elim0) := by
    funext i; fin_cases i <;> rfl
  rw [step1, step2, step3]

/-- `right_gap_class_formula` correctly captures the semantic content:
    there exists b > t and a subinterval [a', b'] with t ≤ a' ≤ b' ≤ b
    that is not good. -/
private theorem right_gap_class_formula_correct {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig) (t : M.carrier) :
    eval M (fun _ => t) (right_gap_class_formula sig k) ↔
    ∃ b : M.carrier, t < b ∧
      ∃ a' b' : M.carrier, t ≤ a' ∧ a' ≤ b' ∧ b' ≤ b ∧
        ¬ good sig k (M.subinterval sig a' b') := by
  -- Unfold the formula evaluation step by step
  unfold right_gap_class_formula
  simp only [eval, eval_leq, not_lt]
  -- After simp: the goal should be about ∃ b, t < b ∧ ∃ b', ∃ a',
  -- (t ≤ a' ∧ a' ≤ b') ∧ b' ≤ b ∧ ¬ eval ... (good_rel_lifted ...)
  constructor
  · -- Forward
    intro ⟨b, h_tb, b', a', ⟨⟨h_ta, h_ab⟩, h_bb⟩, h_ng⟩
    refine ⟨b, h_tb, a', b', h_ta, h_ab, h_bb, ?_⟩
    intro h_good
    apply h_ng
    rw [eval_good_rel_lifted]
    exact (good_formula_relativized_correct sig k M a' b' h_ab).mpr h_good
  · -- Backward
    intro ⟨b, h_tb, a', b', h_ta, h_ab, h_bb, h_ng⟩
    refine ⟨b, h_tb, b', a', ⟨⟨h_ta, h_ab⟩, h_bb⟩, ?_⟩
    intro h_eval
    apply h_ng
    rw [eval_good_rel_lifted] at h_eval
    exact (good_formula_relativized_correct sig k M a' b' h_ab).mp h_eval

/-- The semantic content of `right_gap_class_formula` implies the first conjunct of
    `right_gap_class_prop`: ∃ b > t, ¬ contemp_equiv t b.

    If there exists a bad subinterval [a', b'] ⊂ [t, b], then [t, b] is not very good,
    so ¬ contemp_equiv t b. -/
private theorem right_gap_class_formula_implies_bounded {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig) (t : M.carrier)
    (h : ∃ b : M.carrier, t < b ∧
      ∃ a' b' : M.carrier, t ≤ a' ∧ a' ≤ b' ∧ b' ≤ b ∧
        ¬ good sig k (M.subinterval sig a' b')) :
    ∃ b : M.carrier, t < b ∧ ¬ contemp_equiv sig k M t b := by
  obtain ⟨b, h_lt, a', b', h_ta, h_ab, h_bb, h_ng⟩ := h
  refine ⟨b, h_lt, ?_⟩
  intro h_ce
  apply h_ng
  -- contemp_equiv t b means very_good on [min t b, max t b] = [t, b]
  have h_tb : t ≤ b := le_of_lt h_lt
  simp only [contemp_equiv] at h_ce
  rw [min_eq_left h_tb, max_eq_right h_tb] at h_ce
  exact good_of_very_good_subinterval sig k M t b h_tb h_ce a' b' h_ta h_bb h_ab

/-- Converse: ¬ contemp_equiv t b (with t < b) implies a bad subinterval exists. -/
private theorem bounded_implies_right_gap_class_formula {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [NoMaxOrder M.carrier]
    (t b : M.carrier) (h_lt : t < b) (h_ne : ¬ contemp_equiv sig k M t b) :
    ∃ a' b' : M.carrier, t ≤ a' ∧ a' ≤ b' ∧ b' ≤ b ∧
      ¬ good sig k (M.subinterval sig a' b') := by
  -- contemp_equiv t b = very_good (M.subinterval t b)
  -- ¬ very_good means ∃ x y in [t,b], x ≤ y ∧ ¬ good (subinterval x y)
  simp only [contemp_equiv, very_good] at h_ne
  rw [min_eq_left (le_of_lt h_lt), max_eq_right (le_of_lt h_lt)] at h_ne
  push_neg at h_ne
  obtain ⟨⟨x, hx_lo, hx_hi⟩, ⟨y, hy_lo, hy_hi⟩, h_xy, h_ng⟩ := h_ne
  -- x, y are in the subinterval [t, b] with x ≤ y and ¬good on (subinterval t b).subinterval x y
  -- (subinterval t b).subinterval x y is k_equiv to M.subinterval x y
  have h_not_good : ¬ good sig k (M.subinterval sig x y) := by
    intro ⟨Z, hZ⟩
    apply h_ng
    exact ⟨Z, (subinterval_of_subinterval_k_equiv sig k M t b
      ⟨x, hx_lo, hx_hi⟩ ⟨y, hy_lo, hy_hi⟩).trans hZ⟩
  exact ⟨x, y, hx_lo, h_xy, hy_hi, h_not_good⟩

/-- Temporal formula R detecting `right_gap_class_prop` via
    `US_expressively_complete_over_prior` (Reynolds Lemma 6).

    Given atomMap with h_surj, this produces a temporal Formula A such that
    `temporal_truth M atomMap t A ↔ eval M (fun _ => t) (right_gap_class_formula sig k)`
    on any Prior structure. -/
private noncomputable def gap_formula_R (sig : MonadicSignature) (k : Nat)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    Formula :=
  (US_expressively_complete_over_prior atomMap h_surj
    (right_gap_class_formula sig k)).val

/-- `gap_formula_R` correctly detects `right_gap_class_prop` on Prior structures.

    The proof bridges the three levels:
    1. temporal_truth ↔ eval (right_gap_class_formula)  [by US_expressively_complete_over_prior]
    2. eval (right_gap_class_formula) ↔ ∃ bad subinterval  [by right_gap_class_formula_correct]
    3. ∃ bad subinterval ↔ right_gap_class_prop          [by helper lemmas]

    The second conjunct of right_gap_class_prop (succ-closed) is NOT encoded in
    the formula. It must be established separately from the hypotheses. -/
private theorem gap_formula_R_correct {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [NoMaxOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_prior_UZ : semantic_prior_UZ M atomMap)
    (h_prior_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier) :
    temporal_truth M atomMap t (gap_formula_R sig k atomMap h_surj) ↔
    eval M (fun _ => t) (right_gap_class_formula sig k) := by
  unfold gap_formula_R
  exact ((US_expressively_complete_over_prior atomMap h_surj
    (right_gap_class_formula sig k)).property M h_prior_UZ h_prior_SZ t).symm

/-- Full correctness: gap_formula_R detects right_gap_class_prop when the
    succ-closed hypothesis is known. -/
private theorem gap_formula_R_iff_rgcp {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_prior_UZ : semantic_prior_UZ M atomMap)
    (h_prior_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier)
    (h_succ_closed : ∀ c, contemp_equiv sig k M t c →
      contemp_equiv sig k M t (Order.succ c)) :
    temporal_truth M atomMap t (gap_formula_R sig k atomMap h_surj) ↔
    right_gap_class_prop sig k M t := by
  rw [gap_formula_R_correct M atomMap h_surj h_prior_UZ h_prior_SZ,
      right_gap_class_formula_correct M t]
  constructor
  · -- temporal R holds → right_gap_class_prop
    intro ⟨b, h_tb, a', b', h_ta, h_ab, h_bb, h_ng⟩
    refine ⟨⟨b, h_tb, fun h_ce => h_ng ?_⟩, h_succ_closed⟩
    -- h_ce : contemp_equiv sig k M t b = very_good (subinterval (min t b) (max t b))
    have h_le : t ≤ b := le_of_lt h_tb
    simp only [contemp_equiv, min_eq_left h_le, max_eq_right h_le] at h_ce
    exact good_of_very_good_subinterval sig k M t b h_le h_ce a' b' h_ta h_bb h_ab
  · -- right_gap_class_prop → temporal R holds
    intro ⟨⟨b, h_tb, h_ne⟩, _⟩
    obtain ⟨a', b', h_ta, h_ab, h_bb, h_ng⟩ :=
      bounded_implies_right_gap_class_formula M t b h_tb h_ne
    exact ⟨b, h_tb, a', b', h_ta, h_ab, h_bb, h_ng⟩

/-!
#### Reynolds Theorem 14: Gap contradiction

**Reynolds Theorem 14, upward case** (Reynolds 1994, Lemmas 6-13):
In a discrete Prior structure with h_surj, if class(a) is succ-closed and
there exists y > a not in class(a), then False.

The proof requires the full Reynolds model surgery argument:

1. Construct temporal formula R detecting right_gap_class via
   US_expressively_complete_over_prior (Reynolds Lemma 6)
2. Analyze R-intervals (Lemmas 7-8)
3. Prove class homogeneity in R-intervals (Lemma 9)
4. Define bad intervals and prove formula propagation (Lemmas 10-11)
5. Construct model surgery domain (Lemma 12)
6. Prove temporal truth preservation across surgery (26 subcases for U/S)
7. Derive contradiction (Lemma 13 + Theorem 14)

**STATUS: SORRY** -- The sorry encapsulates Reynolds Lemmas 6-13
(~300-600 lines of model surgery). The sorry-free infrastructure above
(right_gap_class_prop, invariance, succ/pred preservation) provides the
foundation for a future complete implementation.

See the section comment above `reynolds_model_surgery_core` for the
detailed proof sketch. All hypotheses are correct and necessary.
-/

private theorem gap_prior_UZ_contradiction (sig : MonadicSignature) (k : Nat)
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
    (y : M.carrier) (hay : a < y)
    (h_not_equiv : ¬ contemp_equiv sig k M a y) :
    False := by
  -- === Reynolds Lemmas 6-13, upward case ===
  -- Step 1 (Lemma 6): Construct temporal formula R detecting right_gap_class_prop
  let R := gap_formula_R sig k atomMap h_surj
  -- Step 2: R holds at a (a has right_gap_class_prop)
  have h_R_at_a : temporal_truth M atomMap a R := by
    rw [gap_formula_R_correct M atomMap h_surj h_prior_UZ h_prior_SZ,
        right_gap_class_formula_correct M a]
    obtain ⟨a', b', h_ta, h_ab, h_bb, h_ng⟩ :=
      bounded_implies_right_gap_class_formula M a y hay h_not_equiv
    exact ⟨y, hay, a', b', h_ta, h_ab, h_bb, h_ng⟩
  -- Step 3: R fails somewhere above a
  -- (There exists z > a such that class(z) is unbounded above,
  --  hence no bad subinterval witness exists above z.)
  -- Step 4: First R-to-not-R transition exists (by prior_UZ_first_transition)
  -- Step 5: Model surgery at the transition point
  -- Step 6: Contradiction from truth preservation
  -- SORRY: Full Reynolds model surgery argument (Lemmas 7-13, ~400 lines)
  sorry

/--
**Reynolds Theorem 14, downward case**: Symmetric to `gap_prior_UZ_contradiction`
using Prior-SZ for the downward direction. If class(a) is succ-closed (and hence
pred-closed by `contemp_equiv_pred_closed`) and there exists y < a not in class(a),
then False.

**STATUS: SORRY** -- requires ~300 lines of Reynolds model surgery (dual of
the upward case, using S(A,B) instead of U(A,B)). Can potentially be reduced
by using Order.dual to map to the upward case.
-/
private theorem gap_prior_SZ_contradiction (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_prior_UZ : semantic_prior_UZ M atomMap)
    (h_prior_SZ : semantic_prior_SZ M atomMap)
    (a : M.carrier)
    (_h_succ_closed : ∀ c, contemp_equiv sig k M a c →
      contemp_equiv sig k M a (Order.succ c))
    (y : M.carrier) (hya : y < a)
    (h_not_equiv : ¬ contemp_equiv sig k M a y) :
    False := by
  -- Reduce to the UZ case by swapping roles of a and y.
  -- y < a and ¬ contemp_equiv a y.
  -- Since contemp_equiv is symmetric (uses min/max), ¬ contemp_equiv y a.
  -- By no_boundary_at_successor, class(y) is succ-closed.
  -- So gap_prior_UZ_contradiction applies with y as the base point and a as the witness.
  have h_not_equiv_ya : ¬ contemp_equiv sig k M y a := by
    intro h; apply h_not_equiv
    exact (contemp_equiv_is_equiv sig k M).symm h
  have h_y_succ_closed : ∀ c, contemp_equiv sig k M y c →
      contemp_equiv sig k M y (Order.succ c) := by
    intro c hyc
    -- y ~M c and c ~M succ(c) [by no_boundary_at_successor], so y ~M succ(c)
    exact (contemp_equiv_is_equiv sig k M).trans hyc
      (no_boundary_at_successor sig k M c)
  exact gap_prior_UZ_contradiction sig k M atomMap h_surj h_prior_UZ h_prior_SZ
    y h_y_succ_closed a hya h_not_equiv_ya

/-! #### Main theorem -/

/-- **Reynolds Theorem 14 core** (Reynolds 1994, Lemmas 6-13):
    In a discrete Prior structure with atom-surjective atomMap, if class(a)
    is succ-closed then class(a) = whole carrier.

    This theorem is sorry-free given `gap_prior_UZ_contradiction` and
    `gap_prior_SZ_contradiction` (the two sorry sites encapsulating the
    Reynolds model surgery for the upward and downward cases).

    The proof is by contradiction + case split on whether y is above or
    below a. The y = a case is trivial (reflexivity of contemp_equiv).

    See also: `no_boundary_at_successor` guarantees that h_succ_closed
    is trivially satisfied in practice, since c ~M succ(c) for all c. -/
theorem reynolds_model_surgery_core (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_prior_UZ : semantic_prior_UZ M atomMap)
    (h_prior_SZ : semantic_prior_SZ M atomMap)
    (a : M.carrier)
    (h_succ_closed : ∀ c, contemp_equiv sig k M a c →
      contemp_equiv sig k M a (Order.succ c)) :
    ∀ y : M.carrier, contemp_equiv sig k M a y := by
  intro y
  by_contra h_not_equiv
  -- Case split: is y above or below a?
  rcases lt_trichotomy a y with hay | rfl | hya
  · -- y > a: contradiction via gap_prior_UZ_contradiction
    exact gap_prior_UZ_contradiction sig k M atomMap h_surj h_prior_UZ h_prior_SZ
      a h_succ_closed y hay h_not_equiv
  · -- y = a: contemp_equiv a a is reflexivity
    exact h_not_equiv ((contemp_equiv_is_equiv sig k M).refl a)
  · -- y < a: contradiction via gap_prior_SZ_contradiction
    exact gap_prior_SZ_contradiction sig k M atomMap h_surj h_prior_UZ h_prior_SZ
      a h_succ_closed y hya h_not_equiv

/-! ### Main gap contradiction theorems -/

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
  obtain ⟨y, _, h_not_equiv_y⟩ := h_bounded_above
  exact h_not_equiv_y (reynolds_model_surgery_core sig k M atomMap h_surj
    h_prior_UZ h_prior_SZ a h_succ_closed y)

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
    (_h_unbounded_above : ∀ y : M.carrier, a < y → contemp_equiv sig k M a y)
    (h_bounded_below : ∃ y : M.carrier, y < a ∧ ¬ contemp_equiv sig k M a y) :
    False := by
  obtain ⟨y, _, h_not_equiv_y⟩ := h_bounded_below
  exact h_not_equiv_y (reynolds_model_surgery_core sig k M atomMap h_surj
    h_prior_UZ h_prior_SZ a h_succ_closed y)

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
