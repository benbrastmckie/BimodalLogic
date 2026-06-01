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
  simp only [eval, eval_leq]
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
#### Contemp_equiv as MonadicFormula (for class spread)

Encode `contemp_equiv sig k M x y` as a MonadicFormula sig 2. The encoding uses
the universal quantifier form:

  contemp_equiv(x, y) ↔ ∀ c d, min(x,y) ≤ c → c ≤ d → d ≤ max(x,y) → good([c,d])

By choosing ∀ d ∀ c (binding d first, then c), we get c at var 0 and d at var 1
in the innermost scope, which matches `good_rel_lifted`'s convention
(var 0 = lo, var 1 = hi). The guard `min(x,y) ≤ c` is encoded as `x ≤ c ∨ y ≤ c`
and `d ≤ max(x,y)` as `d ≤ x ∨ d ≤ y`.
-/

/-- MonadicFormula sig 2 encoding `contemp_equiv sig k M (var 0) (var 1)`.
    After two universal quantifiers (∀ d then ∀ c):
    sig 4 context: c=var0, d=var1, x=var2, y=var3.
    Guard: (x ≤ c ∨ y ≤ c) ∧ c ≤ d ∧ (d ≤ x ∨ d ≤ y).
    Body: good([c, d]) via good_rel_lifted. -/
private noncomputable def contemp_eq_body (sig : MonadicSignature) (k : Nat) :
    MonadicFormula sig 2 :=
  .all (.all (MonadicFormula.imp
    (.and (.and
      (.or (MonadicFormula.leq ⟨2, by omega⟩ ⟨0, by omega⟩)   -- x ≤ c
           (MonadicFormula.leq ⟨3, by omega⟩ ⟨0, by omega⟩))  -- y ≤ c
      (MonadicFormula.leq ⟨0, by omega⟩ ⟨1, by omega⟩))       -- c ≤ d
      (.or (MonadicFormula.leq ⟨1, by omega⟩ ⟨2, by omega⟩)   -- d ≤ x
           (MonadicFormula.leq ⟨1, by omega⟩ ⟨3, by omega⟩)))  -- d ≤ y
    (good_rel_lifted sig k)))

/-- Helper: the guard condition in contemp_eq_body is equivalent to
    min(x,y) ≤ c ∧ c ≤ d ∧ d ≤ max(x,y). -/
private theorem contemp_guard_iff {α : Type} [LinearOrder α] (x y c d : α) :
    ((x ≤ c ∨ y ≤ c) ∧ c ≤ d ∧ (d ≤ x ∨ d ≤ y)) ↔
    (min x y ≤ c ∧ c ≤ d ∧ d ≤ max x y) := by
  simp only [min_le_iff, le_max_iff]

/-- Correctness of `contemp_eq_body`: evaluates to `contemp_equiv`.

    The formula `contemp_eq_body sig k` uses `∀ d ∀ c` with guard
    `(x ≤ c ∨ y ≤ c) ∧ c ≤ d ∧ (d ≤ x ∨ d ≤ y)` and body `good_rel_lifted`,
    which encodes `very_good(M.subinterval (min x y) (max x y))` = `contemp_equiv x y`.

    The proof bridges the formula evaluation (via `eval_good_rel_lifted` and
    `good_formula_relativized_correct`) to the semantic `contemp_equiv` definition.
    Fin.cons lookups at non-canonical indices (2, 3) are handled via `show` and
    definitional equality rather than simp reduction. -/
private theorem contemp_eq_body_correct (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) (x y : M.carrier) :
    eval M (Fin.cons x (Fin.cons y Fin.elim0)) (contemp_eq_body sig k) ↔
    contemp_equiv sig k M x y := by
  -- contemp_eq_body = .all (.all (imp guard (good_rel_lifted sig k)))
  -- After two ∀ quantifiers: env4 = Fin.cons c (Fin.cons d (Fin.cons x (Fin.cons y Fin.elim0)))
  -- with c=var0, d=var1, x=var2, y=var3.
  --
  -- Strategy: unfold eval to get ∀ d c, guard → good_rel_eval, then
  -- rewrite guard using contemp_guard_iff and good_rel using eval_good_rel_lifted
  -- + good_formula_relativized_correct. The key conversion between
  -- very_good(M.subinterval(min x y, max x y)) and ∀ c d, min(x,y)≤c ∧ c≤d ∧ d≤max(x,y)
  -- → good(M.subinterval c d) uses good_of_very_good_subinterval.
  -- Strategy: Convert via a suffices that states the semantic content directly.
  -- Then bridge between the formula eval and the semantic statement using
  -- definitional equality of Fin.cons lookups and eval_good_rel_lifted.
  suffices h_main : (∀ (d c : M.carrier),
      (x ≤ c ∨ y ≤ c) ∧ c ≤ d ∧ (d ≤ x ∨ d ≤ y) →
      good sig k (M.subinterval sig c d)) ↔
      contemp_equiv sig k M x y by
    constructor
    · intro h_formula
      apply h_main.mp
      intro d c h_guard
      -- h_formula : eval M (Fin.cons x (Fin.cons y Fin.elim0)) (contemp_eq_body sig k)
      -- = ∀ d', ∀ c', eval env4 (imp guard good_rel_lifted)
      -- We need to specialize and extract the conclusion.
      have h_spec : eval M (Fin.cons c (Fin.cons d (Fin.cons x (Fin.cons y Fin.elim0))))
          (MonadicFormula.imp
            (.and (.and
              (.or (MonadicFormula.leq ⟨2, by omega⟩ ⟨0, by omega⟩)
                   (MonadicFormula.leq ⟨3, by omega⟩ ⟨0, by omega⟩))
              (MonadicFormula.leq ⟨0, by omega⟩ ⟨1, by omega⟩))
              (.or (MonadicFormula.leq ⟨1, by omega⟩ ⟨2, by omega⟩)
                   (MonadicFormula.leq ⟨1, by omega⟩ ⟨3, by omega⟩)))
            (good_rel_lifted sig k)) := h_formula d c
      rw [eval_imp] at h_spec
      -- Build the eval guard from the semantic guard
      have h_eval_guard : eval M (Fin.cons c (Fin.cons d (Fin.cons x (Fin.cons y Fin.elim0))))
          (.and (.and
            (.or (MonadicFormula.leq ⟨2, by omega⟩ ⟨0, by omega⟩)
                 (MonadicFormula.leq ⟨3, by omega⟩ ⟨0, by omega⟩))
            (MonadicFormula.leq ⟨0, by omega⟩ ⟨1, by omega⟩))
            (.or (MonadicFormula.leq ⟨1, by omega⟩ ⟨2, by omega⟩)
                 (MonadicFormula.leq ⟨1, by omega⟩ ⟨3, by omega⟩))) := by
        simp only [eval, eval_leq, eval_or]
        -- After simp, the goal has Fin.cons lookups at ⟨0,_⟩..⟨3,_⟩ which are
        -- definitionally c,d,x,y. The goal is ((x≤c ∨ y≤c) ∧ c≤d) ∧ (d≤x ∨ d≤y)
        -- which we provide from h_guard with ∧-reassociation.
        exact ⟨⟨h_guard.1, h_guard.2.1⟩, h_guard.2.2⟩
      have h_body := h_spec h_eval_guard
      rw [eval_good_rel_lifted] at h_body
      -- h_body now has Fin.cons (env 0) (Fin.cons (env 1) Fin.elim0) which is
      -- definitionally Fin.cons c (Fin.cons d Fin.elim0).
      -- Use `show` to normalize, then apply good_formula_relativized_correct.
      have h_body' : eval M (Fin.cons c (Fin.cons d Fin.elim0))
          (good_formula_relativized sig k) := h_body
      rw [good_formula_relativized_correct sig k M c d h_guard.2.1] at h_body'
      exact h_body'
    · intro h_ce d c
      -- Need: eval M env4 (imp guard good_rel_lifted)
      rw [eval_imp]
      intro h_eval_guard
      -- Extract semantic guard from eval guard.
      -- After eval_imp, h_eval_guard has type:
      --   eval M env4 (.and (.and (.or (leq 2 0) (leq 3 0)) (leq 0 1)) (.or (leq 1 2) (leq 1 3)))
      -- which unfolds to ((env2 ≤ env0 ∨ env3 ≤ env0) ∧ env0 ≤ env1) ∧ (env1 ≤ env2 ∨ env1 ≤ env3)
      -- By definitional equality of Fin.cons lookups, this equals
      --   ((x ≤ c ∨ y ≤ c) ∧ c ≤ d) ∧ (d ≤ x ∨ d ≤ y).
      -- We re-associate the ∧ to get the target form.
      simp only [eval, eval_leq, eval_or] at h_eval_guard
      have h_guard : (x ≤ c ∨ y ≤ c) ∧ c ≤ d ∧ (d ≤ x ∨ d ≤ y) :=
        ⟨h_eval_guard.1.1, h_eval_guard.1.2, h_eval_guard.2⟩
      -- Need: eval M env4 (good_rel_lifted sig k)
      -- Use eval_good_rel_lifted which gives eval on (env 0, env 1) = (c, d)
      rw [eval_good_rel_lifted]
      -- Goal: eval M (Fin.cons (env 0) (Fin.cons (env 1) Fin.elim0)) (good_formula_relativized sig k)
      -- where env 0 = c, env 1 = d definitionally.
      -- Use `show` to normalize the env to Fin.cons c (Fin.cons d Fin.elim0)
      show eval M (Fin.cons c (Fin.cons d Fin.elim0)) (good_formula_relativized sig k)
      rw [good_formula_relativized_correct sig k M c d h_guard.2.1]
      exact h_main.mpr h_ce d c h_guard
  -- Now prove h_main: the purely semantic equivalence
  constructor
  · -- Forward: ∀ c d, guard → good(subinterval c d) implies contemp_equiv x y
    intro h_all
    -- contemp_equiv x y = very_good(M.subinterval(min x y, max x y))
    -- = ∀ c' d' ∈ carrier, c' ≤ d' → good(sub.subinterval c' d')
    -- By subinterval_of_subinterval_k_equiv, this reduces to good(M.subinterval c d).
    unfold contemp_equiv very_good
    intro ⟨c, hc_lo, hc_hi⟩ ⟨d, hd_lo, hd_hi⟩ hcd
    -- hcd : ⟨c, _⟩ ≤ ⟨d, _⟩ i.e. c ≤ d
    -- Need: good((M.subinterval(min x y, max x y)).subinterval ⟨c,_⟩ ⟨d,_⟩)
    -- By subinterval_of_subinterval_k_equiv, k_equiv with M.subinterval c d.
    let c' : (M.subinterval sig (min x y) (max x y)).carrier := ⟨c, hc_lo, hc_hi⟩
    let d' : (M.subinterval sig (min x y) (max x y)).carrier := ⟨d, hd_lo, hd_hi⟩
    have h_sub_equiv := subinterval_of_subinterval_k_equiv sig k M (min x y) (max x y) c' d'
    -- h_sub_equiv : k_equiv (sub.sub c' d') (M.sub c d)
    -- From h_all: good(M.subinterval c d) = ∃ Z, k_equiv (M.sub c d) Z.toOrdered
    have h_guard : (x ≤ c ∨ y ≤ c) ∧ c ≤ d ∧ (d ≤ x ∨ d ≤ y) :=
      (contemp_guard_iff x y c d).mpr ⟨hc_lo, hcd, hd_hi⟩
    obtain ⟨Z, hZ⟩ := h_all d c h_guard
    exact ⟨Z, h_sub_equiv.trans hZ⟩
  · -- Backward: contemp_equiv → ∀ c d, guard → good(subinterval c d)
    intro h_ce d c h_guard
    have h_minmax := (contemp_guard_iff x y c d).mp h_guard
    exact good_of_very_good_subinterval sig k M (min x y) (max x y)
      min_le_max h_ce c d h_minmax.1 h_minmax.2.2 h_guard.2.1

/-- MonadicFormula sig 1 encoding "∃ y ~M x, A(y)" where A is a temporal formula.
    This is the "spread formula" used in Reynolds Lemma 9.1.
    After .ex: sig 2 with y=var0, x=var1.
    Body: contemp_eq_body(x, y) ∧ (table A)(y). -/
private noncomputable def spread_formula (sig : MonadicSignature) (k : Nat)
    (atomMap : Formula → sig.preds) (A : Formula) : MonadicFormula sig 1 :=
  .ex (.and (contemp_eq_body sig k) ((table sig atomMap A).lift 1))

/-!
#### Reynolds Theorem 14: Gap contradiction

**Reynolds Theorem 14, upward case** (Reynolds 1994, Lemmas 6-13):
In a discrete Prior structure with h_surj, if class(a) is succ-closed and
there exists y > a not in class(a), then False.

The proof proceeds through:

1. Construct temporal formula R detecting right_gap_class_prop (Lemma 6)
2. Prove R holds everywhere (Lemmas 7-8)
3. Prove invariant_formula_constant (Lemma 9 generalization)
4. Construct surgery model N = class(a) restriction (Lemma 12 setup)
5. Prove class spread using contemp_eq_body encoding (Lemma 9.1)
6. Prove temporal truth preservation M ↔ N (Lemma 12)
7. Derive contradiction: R true in N but right_gap_class_prop false (Lemma 13)
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
  -- Step 3: R holds everywhere.
  -- Claim: R cannot fail at any point of M.
  -- If R fails at some z > a, prior_UZ_first_transition gives a transition point c
  -- with R at c and ¬R at succ(c). But c ~M succ(c) by no_boundary_at_successor,
  -- so right_gap_class_invariant gives R at c iff R at succ(c). Contradiction.
  -- Similarly for z < a using prior_SZ_last_transition.
  -- Helper: any class is succ-closed (by no_boundary_at_successor + transitivity)
  have any_succ_closed : ∀ (t : M.carrier),
      ∀ d, contemp_equiv sig k M t d → contemp_equiv sig k M t (Order.succ d) :=
    fun t d hd => (contemp_equiv_is_equiv sig k M).trans hd
      (no_boundary_at_successor sig k M d)
  -- Helper: R ↔ right_gap_class_prop at any point
  have h_R_iff_rgcp : ∀ (t : M.carrier),
      temporal_truth M atomMap t R ↔ right_gap_class_prop sig k M t :=
    fun t => gap_formula_R_iff_rgcp M atomMap h_surj h_prior_UZ h_prior_SZ t
      (any_succ_closed t)
  have h_R_everywhere : ∀ z : M.carrier, temporal_truth M atomMap z R := by
    by_contra h_not_all
    push_neg at h_not_all
    obtain ⟨z, h_not_R_z⟩ := h_not_all
    -- R at a, ¬R at z. Cases: z > a, z = a, z < a.
    rcases lt_trichotomy a z with haz | rfl | hza
    · -- z > a: prior_UZ_first_transition gives c with R at c, ¬R at succ(c).
      obtain ⟨c, _, h_R_c, h_not_R_sc⟩ :=
        prior_UZ_first_transition M atomMap h_prior_UZ a R h_R_at_a ⟨z, haz, h_not_R_z⟩
      -- c ~M succ(c), so right_gap_class_prop is the same at both.
      have h_ce := no_boundary_at_successor sig k M c
      have h_rgc_c := (h_R_iff_rgcp c).mp h_R_c
      have h_rgc_sc := right_gap_class_invariant sig k M c (Order.succ c) h_ce h_rgc_c
      exact h_not_R_sc ((h_R_iff_rgcp (Order.succ c)).mpr h_rgc_sc)
    · exact h_not_R_z h_R_at_a
    · -- z < a: prior_SZ_last_transition gives c with R at c, ¬R at pred(c).
      obtain ⟨c, _, h_R_c, h_not_R_pc⟩ :=
        prior_SZ_last_transition M atomMap h_prior_SZ a R h_R_at_a ⟨z, hza, h_not_R_z⟩
      -- pred(c) ~M c (need c not IsMin; if c were IsMin, pred c = c, ¬R c contradicts R c)
      have h_not_min : ¬ IsMin c := by
        intro h_min
        have : Order.pred c = c := le_antisymm (Order.pred_le c) (h_min (Order.pred_le c))
        rw [this] at h_not_R_pc; exact h_not_R_pc h_R_c
      have h_ce : contemp_equiv sig k M (Order.pred c) c := by
        have := no_boundary_at_successor sig k M (Order.pred c)
        rw [Order.succ_pred_of_not_isMin h_not_min] at this; exact this
      have h_rgc_c := (h_R_iff_rgcp c).mp h_R_c
      have h_ce_rev := (contemp_equiv_is_equiv sig k M).symm h_ce
      have h_rgc_pc := right_gap_class_invariant sig k M c (Order.pred c) h_ce_rev h_rgc_c
      exact h_not_R_pc ((h_R_iff_rgcp (Order.pred c)).mpr h_rgc_pc)
  -- Step 4: R holds everywhere → every class has the same restricted k-type.
  -- For any MonadicFormula sig 1 φ, if φ is contemp_equiv-invariant,
  -- then the corresponding temporal formula T_φ cannot transition
  -- (same argument as Step 3). So φ is constant on M.
  --
  -- Class-restricted evaluation: for a sentence ψ and point t,
  -- "ψ holds on class(t)" is contemp_equiv-invariant because
  -- class(t) = class(s) when t ~M s.
  --
  -- Since every class-restricted sentence is constant, all classes
  -- satisfy the same monadic FO theory. In particular, all classes
  -- are k-equivalent as structures.
  --
  -- Step 5: Cross-gap subintervals are good when both sides have
  -- the same k-type. This makes M very_good, giving contemp_equiv a y.
  -- Contradiction with h_not_equiv.

  -- For any MonadicFormula sig 1 φ, if φ(t) ↔ φ(s) whenever t ~M s,
  -- then φ is constant on M.
  -- Proof: same as h_R_everywhere proof but for general invariant φ.
  have invariant_formula_constant :
      ∀ (φ : MonadicFormula sig 1),
      (∀ t s, contemp_equiv sig k M t s →
        (eval M (fun _ => t) φ ↔ eval M (fun _ => s) φ)) →
      (∀ t, eval M (fun _ => t) φ) ∨ (∀ t, ¬ eval M (fun _ => t) φ) := by
    intro φ h_inv
    -- Get temporal formula T_φ via US_expressively_complete_over_prior
    let T_φ := (US_expressively_complete_over_prior atomMap h_surj φ).val
    have h_T_correct : ∀ t, eval M (fun _ => t) φ ↔ temporal_truth M atomMap t T_φ :=
      fun t => (US_expressively_complete_over_prior atomMap h_surj φ).property
        M h_prior_UZ h_prior_SZ t
    -- If φ is not constant, there exist t₁ with φ(t₁) and t₂ with ¬φ(t₂)
    by_contra h_not_const
    simp only [not_or, not_forall] at h_not_const
    obtain ⟨⟨t₂, h_t₂⟩, ⟨t₁, h_t₁⟩⟩ := h_not_const
    simp only [not_not] at h_t₁
    -- T_φ at t₁, ¬T_φ at t₂
    have h_T_t₁ : temporal_truth M atomMap t₁ T_φ := (h_T_correct t₁).mp h_t₁
    have h_not_T_t₂ : ¬ temporal_truth M atomMap t₂ T_φ :=
      fun h => h_t₂ ((h_T_correct t₂).mpr h)
    -- Find transition point using Prior-UZ or Prior-SZ
    rcases lt_trichotomy t₁ t₂ with h12 | rfl | h21
    · -- t₁ < t₂: use prior_UZ_first_transition
      obtain ⟨c, _, h_T_c, h_not_T_sc⟩ :=
        prior_UZ_first_transition M atomMap h_prior_UZ t₁ T_φ h_T_t₁
          ⟨t₂, h12, h_not_T_t₂⟩
      -- c ~M succ(c)
      have h_ce := no_boundary_at_successor sig k M c
      -- φ(c) ↔ φ(succ(c)) by invariance
      have h_φ_c := (h_T_correct c).mpr h_T_c
      have h_φ_sc := (h_inv c (Order.succ c) h_ce).mp h_φ_c
      exact h_not_T_sc ((h_T_correct (Order.succ c)).mp h_φ_sc)
    · exact h_not_T_t₂ h_T_t₁
    · -- t₂ < t₁: use prior_SZ_last_transition
      obtain ⟨c, _, h_T_c, h_not_T_pc⟩ :=
        prior_SZ_last_transition M atomMap h_prior_SZ t₁ T_φ h_T_t₁
          ⟨t₂, h21, h_not_T_t₂⟩
      -- pred(c) ~M c
      have h_not_min : ¬ IsMin c := by
        intro h_min
        have : Order.pred c = c := le_antisymm (Order.pred_le c) (h_min (Order.pred_le c))
        rw [this] at h_not_T_pc; exact h_not_T_pc h_T_c
      have h_ce : contemp_equiv sig k M (Order.pred c) c := by
        have := no_boundary_at_successor sig k M (Order.pred c)
        rw [Order.succ_pred_of_not_isMin h_not_min] at this; exact this
      -- φ(pred c) ↔ φ(c) by invariance (with symmetry)
      have h_φ_c := (h_T_correct c).mpr h_T_c
      have h_ce_sym := (contemp_equiv_is_equiv sig k M).symm h_ce
      have h_φ_pc := (h_inv c (Order.pred c) h_ce_sym).mp h_φ_c
      exact h_not_T_pc ((h_T_correct (Order.pred c)).mp h_φ_pc)
  -- === Reynolds Lemma 9.1 + 12-13: Model Surgery ===
  -- Step 5: Construct surgery model N = restriction of M to class(a).
  -- N is an OrderedMonadicStructure on the carrier {x | contemp_equiv sig k M a x}.
  -- Step 6: Prove temporal truth preservation (M ↔ N at points of class(a)).
  -- Step 7: Derive contradiction: R holds in N (truth preservation) but
  --   right_gap_class_formula is false in N (N has only one class, no gaps).

  -- === Step 5: Surgery model N ===
  -- Define the carrier of N as the subtype of points contemp_equiv to a.
  let classA := {x : M.carrier // contemp_equiv sig k M a x}
  -- N inherits order from M (subtype of linearly ordered type).
  -- Define N as an OrderedMonadicStructure.
  let N : OrderedMonadicStructure sig := {
    carrier := classA
    interp := fun p x => M.interp p x.val
    carrier_order := inferInstance
  }
  -- Class(a) is convex: if a ~M x and a ~M z and x ≤ y ≤ z, then a ~M y.
  have class_convex : ∀ (x y z : M.carrier), contemp_equiv sig k M a x →
      contemp_equiv sig k M a z → x ≤ y → y ≤ z → contemp_equiv sig k M a y := by
    intro x y z hax haz hxy hyz
    -- a ~M z, x ≤ y ≤ z. We need a ~M y.
    -- By contemp_equiv_convex: a ~M z and a ≤ ... depends on ordering of a, y, z.
    -- Use transitivity: a ~M x and a ~M z. Also x ≤ y ≤ z.
    -- If a ≤ x: a ≤ x ≤ y ≤ z. a ~M z and a ≤ y ≤ z → a ~M y by convexity.
    -- If x ≤ a ≤ z: then a ≤ y or y ≤ a.
    -- General argument: a ~M z means very_good([min a z, max a z]).
    -- [min a z, max a z] contains y (since min a z ≤ min(x,y) ≤ y and y ≤ max(x,z) ≤ max a z).
    -- So a ~M y follows from a ~M z by sub-interval very_good property.
    rcases le_or_gt a y with hay | hya
    · -- a ≤ y: need a ~M y. We have a ~M z with a ≤ y ≤ z (if a ≤ z).
      rcases le_or_gt a z with haz_le | hza
      · exact contemp_equiv_convex sig k M a y z hay hyz haz
      · -- z < a, but a ≤ y ≤ z < a, contradiction
        exact absurd (lt_of_le_of_lt (le_trans hay hyz) hza) (lt_irrefl a)
    · -- a > y: need a ~M y. We have a ~M x.
      -- x ≤ y < a. So y ∈ [x, a].
      -- a ~M x means contemp_equiv a x. Since y ∈ [x, a], by convexity: a ~M y.
      rcases le_or_gt x a with hxa | hax
      · -- x ≤ a: use contemp_equiv_convex with a ~M x (symm of hax), x ≤ y ≤ a
        have h_sym := (contemp_equiv_is_equiv sig k M).symm hax
        -- h_sym : contemp_equiv x a. Need contemp_equiv a y.
        -- x ≤ y (hxy) and y ≤ a (le_of_lt hya).
        -- contemp_equiv_convex: x ~M a, x ≤ y ≤ a → x ~M y
        have hxy_equiv := contemp_equiv_convex sig k M x y a hxy (le_of_lt hya) h_sym
        -- hxy_equiv : contemp_equiv x y. Need contemp_equiv a y.
        exact (contemp_equiv_is_equiv sig k M).trans hax hxy_equiv
      · -- a < x: but a ~M x, a < x ≤ y, so use convexity a ~M x, a ≤ y
        -- a ≤ x (le_of_lt hax), x ≤ y (hxy). a ~M x.
        -- a ~M z, need a ~M y. a ≤ x ≤ y ≤ z. Use a ~M z.
        rcases le_or_gt a z with haz_le | hza
        · exact contemp_equiv_convex sig k M a y z (le_trans (le_of_lt hax) hxy) hyz haz
        · -- z < a, but a < x ≤ y ≤ z < a, contradiction
          exact absurd (lt_of_le_of_lt (le_trans (le_of_lt hax) (le_trans hxy hyz)) hza)
            (lt_irrefl a)
  -- N has SuccOrder: class(a) is succ-closed, so succ of a class member is in the class.
  have h_N_succ : ∀ (x : classA), contemp_equiv sig k M a (Order.succ x.val) :=
    fun x => any_succ_closed a x.val x.property
  -- N has PredOrder: class(a) is pred-closed.
  have h_N_pred : ∀ (x : classA), contemp_equiv sig k M a (Order.pred x.val) :=
    fun x => contemp_equiv_pred_closed sig k M a x.val x.property
  -- Class(a) has no max: succ(x) > x and succ(x) is in class.
  have h_N_no_max : ∀ (x : classA), ∃ (y : classA), x < y := by
    intro ⟨x, hx⟩
    exact ⟨⟨Order.succ x, h_N_succ ⟨x, hx⟩⟩,
      Order.lt_succ_of_not_isMax (not_isMax x)⟩
  -- Class(a) has no min: pred(x) < x and pred(x) is in class.
  have h_N_no_min : ∀ (x : classA), ∃ (y : classA), y < x := by
    intro ⟨x, hx⟩
    have : ¬ IsMin x := by
      intro h_min
      have h_pred_eq : Order.pred x = x :=
        le_antisymm (Order.pred_le x) (h_min (Order.pred_le x))
      -- x is min of M.carrier, contradicting NoMinOrder
      exact not_isMin x h_min
    exact ⟨⟨Order.pred x, h_N_pred ⟨x, hx⟩⟩,
      Order.pred_lt_of_not_isMin this⟩
  -- All points in N are contemp_equiv to each other (single class).
  have h_N_one_class : ∀ (x y : classA), contemp_equiv sig k M x.val y.val := by
    intro ⟨x, hx⟩ ⟨y, hy⟩
    exact (contemp_equiv_is_equiv sig k M).trans
      ((contemp_equiv_is_equiv sig k M).symm hx) hy
  -- N's subintervals are the same as M's subintervals (convexity of class).
  -- Since all points in N are contemp_equiv in M, all N-subintervals are very_good.
  have h_N_very_good : ∀ (x y : classA), x.val ≤ y.val →
      good sig k (M.subinterval sig x.val y.val) := by
    intro ⟨x, hx⟩ ⟨y, hy⟩ hxy
    -- x ~M y (both in class(a)), so contemp_equiv x y
    have hce := h_N_one_class ⟨x, hx⟩ ⟨y, hy⟩
    -- contemp_equiv x y = very_good([min x y, max x y]) = very_good([x, y])
    simp only [contemp_equiv, min_eq_left hxy, max_eq_right hxy] at hce
    -- hce : very_good(M.subinterval sig x y)
    -- Use good_of_very_good_subinterval with c = x, d = y
    exact good_of_very_good_subinterval sig k M x y hxy hce x y
      (le_refl x) (le_refl y) hxy

  -- === Step 6: Class spread (Reynolds Lemma 9.1) ===
  -- For any temporal formula A, if A holds at some point of M,
  -- then A holds at some point of every contemp_equiv class.
  -- Proof: The spread formula φ_spread = .ex (.and contemp_eq_body (table A).lift 1)
  -- encodes "∃ y ~M x, A(y)". This is contemp_equiv-invariant and hence constant
  -- on M by invariant_formula_constant.
  have class_spread : ∀ (A : Formula) (s : M.carrier),
      temporal_truth M atomMap s A →
      ∀ (t : M.carrier), ∃ (t' : M.carrier),
        contemp_equiv sig k M t t' ∧ temporal_truth M atomMap t' A := by
    intro A s h_A_s t
    by_cases h_same : contemp_equiv sig k M t s
    · exact ⟨s, h_same, h_A_s⟩
    -- Construct the spread formula φ_spread : MonadicFormula sig 1
    -- encoding "∃ y ~M x, A(y)".
    let φ_spread := spread_formula sig k atomMap A
    -- Helper: the two natural representations of a 2-element env are equal
    have env2_eq : ∀ (v u : M.carrier),
        (Fin.cons v (fun (_ : Fin 1) => u) : Fin 2 → M.carrier) =
        Fin.cons v (Fin.cons u Fin.elim0) := by
      intro v u; funext i; fin_cases i <;> rfl
    -- Helper: lift eval for table formulas in .ex context
    have table_lift : ∀ (v u : M.carrier),
        eval M (Fin.cons v (fun (_ : Fin 1) => u)) ((table sig atomMap A).lift 1) ↔
        temporal_truth M atomMap v A := by
      intro v u
      rw [env2_eq]
      -- Goal: eval M (Fin.cons v (Fin.cons u Fin.elim0)) ((table A).lift 1)
      --   ↔ temporal_truth v A
      -- lift_eval: eval M (insertEnv c x env) (α.lift c.val) = eval M env α
      -- insertEnv 1 u (fun _ => v) = Fin.cons v (Fin.cons u Fin.elim0)
      have h_ins : insertEnv ⟨1, by omega⟩ u (fun (_ : Fin 1) => v) =
          Fin.cons v (Fin.cons u Fin.elim0) := by
        funext i; fin_cases i
        · -- i = 0: insertEnv at 0 < 1 gives env 0 = v. Fin.cons v _ 0 = v
          simp [insertEnv]
        · -- i = 1: insertEnv at 1 = 1 gives x = u. Fin.cons v (Fin.cons u _) 1 = u
          simp [insertEnv, Fin.cons_zero]
      rw [← h_ins]
      -- Goal: eval M (insertEnv ⟨1, _⟩ u (fun _ => v)) ((table A).lift 1) ↔ ...
      -- lift_eval: eval M (insertEnv c x env) (α.lift c.val) = eval M env α
      -- with c = ⟨1, _⟩, x = u, env = (fun _ => v)
      -- c.val = 1, which matches .lift 1
      have h_le := lift_eval M (fun (_ : Fin 1) => v) ⟨1, by omega⟩ u (table sig atomMap A)
      -- h_le : eval ... (table.lift 1) = eval (fun _ => v) (table)
      -- But 1 = (⟨1, _⟩ : Fin 2).val, so .lift 1 = .lift (⟨1,_⟩.val)
      rw [h_le]
      exact table_correctness M atomMap v A
    -- Helper: contemp_eq_body at (v, u) env ↔ contemp_equiv v u
    have ce_eval : ∀ (v u : M.carrier),
        eval M (Fin.cons v (fun (_ : Fin 1) => u)) (contemp_eq_body sig k) ↔
        contemp_equiv sig k M v u := by
      intro v u
      rw [env2_eq]
      exact contemp_eq_body_correct sig k M v u
    -- Correctness: eval M (fun _ => x) φ_spread ↔ ∃ y ~M x, A(y)
    have h_spread_correct : ∀ (u : M.carrier),
        eval M (fun _ => u) φ_spread ↔
        ∃ v, contemp_equiv sig k M u v ∧ temporal_truth M atomMap v A := by
      intro u
      simp only [φ_spread, spread_formula, eval]
      constructor
      · intro ⟨v, h_ce_eval, h_A_eval⟩
        exact ⟨v, (contemp_equiv_is_equiv sig k M).symm ((ce_eval v u).mp h_ce_eval),
          (table_lift v u).mp h_A_eval⟩
      · intro ⟨v, h_ce, h_A_v⟩
        exact ⟨v, (ce_eval v u).mpr ((contemp_equiv_is_equiv sig k M).symm h_ce),
          (table_lift v u).mpr h_A_v⟩
    -- φ_spread is contemp_equiv-invariant
    have h_spread_inv : ∀ (u v : M.carrier), contemp_equiv sig k M u v →
        (eval M (fun _ => u) φ_spread ↔ eval M (fun _ => v) φ_spread) := by
      intro u v h_uv
      rw [h_spread_correct u, h_spread_correct v]
      constructor
      · intro ⟨w, h_uw, h_Aw⟩
        exact ⟨w, (contemp_equiv_is_equiv sig k M).trans
          ((contemp_equiv_is_equiv sig k M).symm h_uv) h_uw, h_Aw⟩
      · intro ⟨w, h_vw, h_Aw⟩
        exact ⟨w, (contemp_equiv_is_equiv sig k M).trans h_uv h_vw, h_Aw⟩
    -- Apply invariant_formula_constant: φ_spread is constant on M
    rcases invariant_formula_constant φ_spread h_spread_inv with h_all | h_none
    · -- φ_spread true everywhere → holds at t
      exact ((h_spread_correct t).mp (h_all t))
    · -- φ_spread false everywhere → contradiction (it holds at s via s itself)
      exfalso
      exact (h_none s) ((h_spread_correct s).mpr
        ⟨s, (contemp_equiv_is_equiv sig k M).refl s, h_A_s⟩)
  -- === Step 6b: Ordered class spread (Reynolds Lemma 11 density) ===
  -- If A holds at some class(a) point, then for any t ∈ class(a),
  -- A holds at some class(a) point ABOVE t, and BELOW t.
  --
  -- Proof: Use Prior-UZ to get first A above t. If in class(a), done.
  -- If not, construct monadic formula spread_below_A, get its temporal
  -- formula T, show T transitions TRUE→FALSE across the gap, contradicting
  -- Prior-UZ via no_boundary_at_successor.

  -- Helper: env2_eq (reused from class_spread)
  have env2_eq : ∀ (v u : M.carrier),
      (Fin.cons v (fun (_ : Fin 1) => u) : Fin 2 → M.carrier) =
      Fin.cons v (Fin.cons u Fin.elim0) := by
    intro v u; funext i; fin_cases i <;> rfl
  -- Helper: table_lift (reused from class_spread)
  have table_lift : ∀ (A : Formula) (v u : M.carrier),
      eval M (Fin.cons v (fun (_ : Fin 1) => u)) ((table sig atomMap A).lift 1) ↔
      temporal_truth M atomMap v A := by
    intro A v u
    rw [env2_eq]
    have h_ins : insertEnv ⟨1, by omega⟩ u (fun (_ : Fin 1) => v) =
        Fin.cons v (Fin.cons u Fin.elim0) := by
      funext i; fin_cases i <;> simp [insertEnv, Fin.cons_zero]
    rw [← h_ins]
    have h_le := lift_eval M (fun (_ : Fin 1) => v) ⟨1, by omega⟩ u (table sig atomMap A)
    rw [h_le]
    exact table_correctness M atomMap v A
  -- Helper: ce_eval (reused from class_spread)
  have ce_eval : ∀ (v u : M.carrier),
      eval M (Fin.cons v (fun (_ : Fin 1) => u)) (contemp_eq_body sig k) ↔
      contemp_equiv sig k M v u := by
    intro v u
    rw [env2_eq]
    exact contemp_eq_body_correct sig k M v u

  -- Ordered spread above: if A at s' ∈ class(a) with s' ≤ t, and
  -- A at s with s > t and s ∉ class(a), then A at some w > t in class(a).
  have ordered_spread_above : ∀ (A : Formula) (t : M.carrier)
      (h_t : contemp_equiv sig k M a t) (s : M.carrier)
      (h_ts : t < s) (h_φ_s : temporal_truth M atomMap s A)
      (h_s_not : ¬ contemp_equiv sig k M a s)
      (s' : M.carrier) (h_s'_class : contemp_equiv sig k M a s')
      (h_φ_s' : temporal_truth M atomMap s' A)
      (h_s't : s' ≤ t),
      ∃ w, contemp_equiv sig k M a w ∧ t < w ∧ temporal_truth M atomMap w A := by
    intro A t h_t s h_ts h_φ_s h_s_not s' h_s'_class h_φ_s' h_s't
    -- Apply Prior-UZ for first A above t.
    obtain ⟨s₀, h_ts₀, h_φ_s₀, h_neg_s₀⟩ := h_prior_UZ t A ⟨s, h_ts, h_φ_s⟩
    have h_not_A_between : ∀ r, t < r → r < s₀ →
        ¬ temporal_truth M atomMap r A := by
      intro r htr hrs₀ h_A_r
      exact (temporal_truth_neg_iff_not M atomMap r A).mp
        (h_neg_s₀ r htr hrs₀) h_A_r
    by_cases h_s₀_class : contemp_equiv sig k M a s₀
    · exact ⟨s₀, h_s₀_class, h_ts₀, h_φ_s₀⟩
    · -- s₀ ∉ class(a): derive contradiction.
      exfalso
      -- All class(a) above t are below s₀.
      have h_class_below_s₀ : ∀ w, contemp_equiv sig k M a w →
          t < w → w < s₀ := by
        intro w hw htw
        by_contra h_ge; push_neg at h_ge
        rcases eq_or_gt_of_le h_ge with rfl | h_gt
        · exact h_s₀_class hw
        · exact h_s₀_class (class_convex t s₀ w h_t hw
            (le_of_lt h_ts₀) (le_of_lt h_gt))
      -- All class(s₀) members > t (by convexity of contemp_equiv).
      -- w ~M s₀, w ≤ t < s₀ => contemp_equiv_convex gives w ~M t.
      -- Then s₀ ~M w ~M t ~M a, so s₀ ∈ class(a). Contradiction.
      have h_class_s₀_above_t : ∀ w, contemp_equiv sig k M s₀ w → t < w := by
        intro w hw
        by_contra h_le; push_neg at h_le
        -- w ≤ t < s₀. w ~M s₀. By contemp_equiv_convex: w ~M t.
        have h_wt : contemp_equiv sig k M w t :=
          contemp_equiv_convex sig k M w t s₀ h_le (le_of_lt h_ts₀)
            ((contemp_equiv_is_equiv sig k M).symm hw)
        -- a ~M t (h_t), t ~M w (symm h_wt), w ~M s₀ (symm hw).
        -- So a ~M s₀. Contradiction with h_s₀_class.
        exact h_s₀_class ((contemp_equiv_is_equiv sig k M).trans h_t
          ((contemp_equiv_is_equiv sig k M).trans
            ((contemp_equiv_is_equiv sig k M).symm h_wt)
            ((contemp_equiv_is_equiv sig k M).symm hw)))
      -- Construct monadic formula Ψ encoding "∃ y ~M x, y < x, A(y)".
      let Ψ : MonadicFormula sig 1 :=
        .ex (.and (.and (contemp_eq_body sig k)
          (.lt ⟨0, by omega⟩ ⟨1, by omega⟩))
          ((table sig atomMap A).lift 1))
      -- Get temporal formula T_Ψ via US_expressively_complete_over_prior.
      let T_Ψ := (US_expressively_complete_over_prior atomMap h_surj Ψ).val
      have h_T_correct : ∀ z, eval M (fun _ => z) Ψ ↔
          temporal_truth M atomMap z T_Ψ :=
        fun z => (US_expressively_complete_over_prior atomMap h_surj Ψ).property
          M h_prior_UZ h_prior_SZ z
      -- Ψ correctness: Ψ(x) ↔ ∃ y ~M x, y < x, A(y).
      have h_Ψ_correct : ∀ z, eval M (fun _ => z) Ψ ↔
          ∃ y, contemp_equiv sig k M z y ∧ y < z ∧
            temporal_truth M atomMap y A := by
        intro z
        simp only [Ψ, eval]
        constructor
        · intro ⟨y, ⟨h_ce, h_lt⟩, h_A⟩
          exact ⟨y, (contemp_equiv_is_equiv sig k M).symm
            ((ce_eval y z).mp h_ce), h_lt, (table_lift A y z).mp h_A⟩
        · intro ⟨y, h_ce, h_lt, h_A⟩
          exact ⟨y, ⟨(ce_eval y z).mpr
            ((contemp_equiv_is_equiv sig k M).symm h_ce), h_lt⟩,
            (table_lift A y z).mpr h_A⟩
      -- T_Ψ is TRUE at succ(t) (witness: s' < succ(t) in class(a)).
      have h_succ_t_class := h_N_succ ⟨t, h_t⟩
      have h_T_true : temporal_truth M atomMap (Order.succ t) T_Ψ := by
        rw [← h_T_correct]
        exact (h_Ψ_correct (Order.succ t)).mpr
          ⟨s', (contemp_equiv_is_equiv sig k M).trans
            ((contemp_equiv_is_equiv sig k M).symm h_succ_t_class) h_s'_class,
            lt_of_le_of_lt h_s't (Order.lt_succ_of_not_isMax (not_isMax t)),
            h_φ_s'⟩
      -- T_Ψ is FALSE at pred(s₀): no A below pred(s₀) in class(s₀).
      have h_not_min_s₀ : ¬ IsMin s₀ := not_isMin_of_lt h_ts₀
      have h_pred_class_s₀ : contemp_equiv sig k M s₀ (Order.pred s₀) := by
        have := no_boundary_at_successor sig k M (Order.pred s₀)
        rw [Order.succ_pred_of_not_isMin h_not_min_s₀] at this
        exact (contemp_equiv_is_equiv sig k M).symm this
      have h_pred_s₀_above_t : t < Order.pred s₀ := by
        by_contra h_le; push_neg at h_le
        -- pred(s₀) ≤ t. succ(pred(s₀)) = s₀. So s₀ ≤ succ(t).
        -- succ(t) ≤ s₀ (from h_ts₀ and succ). So s₀ = succ(t) ∈ class(a). Contradiction.
        have : s₀ = Order.succ t := le_antisymm
          ((Order.succ_pred_of_not_isMin h_not_min_s₀).symm ▸
            Order.succ_le_succ h_le)
          (Order.succ_le_of_lt h_ts₀)
        exact h_s₀_class (this ▸ h_succ_t_class)
      have h_T_false : ¬ temporal_truth M atomMap (Order.pred s₀) T_Ψ := by
        rw [← h_T_correct]
        intro h_eval
        obtain ⟨y, h_ce, h_lt, h_A_y⟩ := (h_Ψ_correct _).mp h_eval
        -- y < pred(s₀), y ~M pred(s₀) ~M s₀. y ∈ class(s₀). y > t.
        have h_y_above_t := h_class_s₀_above_t y
          ((contemp_equiv_is_equiv sig k M).trans h_pred_class_s₀ h_ce)
        exact h_not_A_between y h_y_above_t
          (lt_trans h_lt (Order.pred_lt_of_not_isMin h_not_min_s₀)) h_A_y
      -- succ(t) < pred(s₀): succ(t) ∈ class(a), pred(s₀) < s₀, both > t.
      have h_st_lt_ps₀ : Order.succ t < Order.pred s₀ := by
        by_contra h_ge; push_neg at h_ge
        -- pred(s₀) ≤ succ(t). So s₀ ≤ succ(succ(t)).
        -- And succ(t) < s₀. So succ(succ(t)) ≤ s₀. s₀ = succ(succ(t)).
        -- succ(succ(t)) ∈ class(a). Contradiction.
        have h_ss := h_N_succ ⟨Order.succ t, h_succ_t_class⟩
        have : s₀ = Order.succ (Order.succ t) := le_antisymm
          ((Order.succ_pred_of_not_isMin h_not_min_s₀).symm ▸
            Order.succ_le_succ h_ge)
          (Order.succ_le_of_lt (h_class_below_s₀ (Order.succ t) h_succ_t_class
            (Order.lt_succ_of_not_isMax (not_isMax t))))
        exact h_s₀_class (this ▸ h_ss)
      -- prior_UZ_first_transition on T_Ψ from succ(t).
      obtain ⟨c, _, h_T_c, h_not_T_sc⟩ :=
        prior_UZ_first_transition M atomMap h_prior_UZ (Order.succ t) T_Ψ
          h_T_true ⟨Order.pred s₀, h_st_lt_ps₀, h_T_false⟩
      -- c ~M succ(c). T_Ψ(c) and ¬T_Ψ(succ(c)).
      -- T_Ψ(c): ∃ y < c in class(c) with A(y).
      obtain ⟨y₀, h_ce_y₀, h_y₀_lt_c, h_A_y₀⟩ :=
        (h_Ψ_correct c).mp ((h_T_correct c).mpr h_T_c)
      -- ¬T_Ψ(succ(c)): no y < succ(c) in class(succ(c)) with A(y).
      -- But y₀ < c < succ(c) and y₀ ~M c ~M succ(c). Contradiction.
      exact h_not_T_sc ((h_T_correct (Order.succ c)).mp
        ((h_Ψ_correct (Order.succ c)).mpr ⟨y₀,
          (contemp_equiv_is_equiv sig k M).trans
            ((contemp_equiv_is_equiv sig k M).symm
              (no_boundary_at_successor sig k M c))
            h_ce_y₀,
          lt_trans h_y₀_lt_c (Order.lt_succ_of_not_isMax (not_isMax c)),
          h_A_y₀⟩))

  -- Symmetric: ordered spread below.
  have ordered_spread_below : ∀ (A : Formula) (t : M.carrier)
      (h_t : contemp_equiv sig k M a t) (s : M.carrier)
      (h_st : s < t) (h_φ_s : temporal_truth M atomMap s A)
      (h_s_not : ¬ contemp_equiv sig k M a s)
      (s' : M.carrier) (h_s'_class : contemp_equiv sig k M a s')
      (h_φ_s' : temporal_truth M atomMap s' A)
      (h_s't : t ≤ s'),
      ∃ w, contemp_equiv sig k M a w ∧ w < t ∧ temporal_truth M atomMap w A := by
    intro A t h_t s h_st h_φ_s h_s_not s' h_s'_class h_φ_s' h_s't
    -- Apply Prior-SZ for last A below t.
    obtain ⟨s₀, h_s₀t, h_φ_s₀, h_neg_s₀⟩ := h_prior_SZ t A ⟨s, h_st, h_φ_s⟩
    have h_not_A_between : ∀ r, s₀ < r → r < t →
        ¬ temporal_truth M atomMap r A := by
      intro r hsr hrt h_A_r
      exact (temporal_truth_neg_iff_not M atomMap r A).mp
        (h_neg_s₀ r hsr hrt) h_A_r
    by_cases h_s₀_class : contemp_equiv sig k M a s₀
    · exact ⟨s₀, h_s₀_class, h_s₀t, h_φ_s₀⟩
    · exfalso
      -- All class(a) below t are above s₀.
      have h_class_above_s₀ : ∀ w, contemp_equiv sig k M a w →
          w < t → s₀ < w := by
        intro w hw hwt
        by_contra h_ge; push_neg at h_ge
        rcases eq_or_gt_of_le h_ge with rfl | h_gt
        · exact h_s₀_class hw
        · exact h_s₀_class (class_convex w s₀ t hw h_t
            (le_of_lt h_gt) (le_of_lt h_s₀t))
      -- All class(s₀) members < t (by convexity + contemp_equiv_convex).
      have h_class_s₀_below_t : ∀ w, contemp_equiv sig k M s₀ w → w < t := by
        intro w hw
        by_contra h_ge; push_neg at h_ge
        -- w ≥ t. s₀ < t ≤ w. s₀ ~M w. t between s₀ and w.
        -- By contemp_equiv_convex: s₀ ~M t. Then a ~M t ~M s₀. s₀ ∈ class(a).
        exact h_s₀_class ((contemp_equiv_is_equiv sig k M).trans h_t
          ((contemp_equiv_is_equiv sig k M).symm
            (contemp_equiv_convex sig k M s₀ t w (le_of_lt h_s₀t) h_ge hw)))
      -- Construct spread_above formula: ∃ y ~M x, x < y, A(y).
      let Ψ' : MonadicFormula sig 1 :=
        .ex (.and (.and (contemp_eq_body sig k)
          (.lt ⟨1, by omega⟩ ⟨0, by omega⟩))
          ((table sig atomMap A).lift 1))
      let T_Ψ' := (US_expressively_complete_over_prior atomMap h_surj Ψ').val
      have h_T_correct : ∀ z, eval M (fun _ => z) Ψ' ↔
          temporal_truth M atomMap z T_Ψ' :=
        fun z => (US_expressively_complete_over_prior atomMap h_surj Ψ').property
          M h_prior_UZ h_prior_SZ z
      have h_Ψ_correct : ∀ z, eval M (fun _ => z) Ψ' ↔
          ∃ y, contemp_equiv sig k M z y ∧ z < y ∧
            temporal_truth M atomMap y A := by
        intro z
        simp only [Ψ', eval]
        constructor
        · intro ⟨y, ⟨h_ce, h_lt⟩, h_A⟩
          exact ⟨y, (contemp_equiv_is_equiv sig k M).symm
            ((ce_eval y z).mp h_ce), h_lt, (table_lift A y z).mp h_A⟩
        · intro ⟨y, h_ce, h_lt, h_A⟩
          exact ⟨y, ⟨(ce_eval y z).mpr
            ((contemp_equiv_is_equiv sig k M).symm h_ce), h_lt⟩,
            (table_lift A y z).mpr h_A⟩
      -- T_Ψ' TRUE at pred(t) (witness: s' ≥ t > pred(t)).
      have h_pred_t_class := h_N_pred ⟨t, h_t⟩
      have h_T_true : temporal_truth M atomMap (Order.pred t) T_Ψ' := by
        rw [← h_T_correct]
        exact (h_Ψ_correct (Order.pred t)).mpr
          ⟨s', (contemp_equiv_is_equiv sig k M).trans
            ((contemp_equiv_is_equiv sig k M).symm h_pred_t_class) h_s'_class,
            lt_of_lt_of_le (Order.pred_lt_of_not_isMin (not_isMin t)) h_s't,
            h_φ_s'⟩
      -- T_Ψ' FALSE at succ(s₀): no A above succ(s₀) in class(s₀).
      have h_not_max_s₀ : ¬ IsMax s₀ := not_isMax_of_lt h_s₀t
      have h_succ_s₀_class_s₀ : contemp_equiv sig k M s₀ (Order.succ s₀) :=
        no_boundary_at_successor sig k M s₀
      have h_succ_s₀_below_t : Order.succ s₀ < t := by
        by_contra h_ge; push_neg at h_ge
        -- succ(s₀) ≥ t. s₀ < t. So s₀ < t ≤ succ(s₀). pred(succ(s₀)) = s₀.
        -- t ≤ succ(s₀). succ(s₀) ≥ t. pred(t) ≤ s₀.
        -- Actually: s₀ < t ≤ succ(s₀) → t = succ(s₀) (discrete order).
        -- Then s₀ = pred(t). pred(t) ∈ class(a). s₀ ∈ class(a). Contradiction.
        -- s₀ < t ≤ succ(s₀). In discrete order with SuccOrder:
        -- t ≤ succ(s₀) and s₀ < t means t = succ(s₀).
        -- Then pred(t) = s₀. pred(t) ∈ class(a). s₀ ∈ class(a). Contradiction.
        -- s₀ < t ≤ succ(s₀). In discrete order: t = succ(s₀).
        -- Then pred(t) = s₀. pred(t) ∈ class(a). s₀ ∈ class(a). Contradiction.
        have h_t_eq : t = Order.succ s₀ :=
          le_antisymm h_ge (Order.succ_le_of_lt h_s₀t)
        have : Order.pred t = s₀ := by rw [h_t_eq, Order.pred_succ]
        exact h_s₀_class (this ▸ h_pred_t_class)
      have h_T_false : ¬ temporal_truth M atomMap (Order.succ s₀) T_Ψ' := by
        rw [← h_T_correct]
        intro h_eval
        obtain ⟨y, h_ce, h_lt, h_A_y⟩ := (h_Ψ_correct _).mp h_eval
        have h_y_below_t := h_class_s₀_below_t y
          ((contemp_equiv_is_equiv sig k M).trans h_succ_s₀_class_s₀ h_ce)
        exact h_not_A_between y
          (lt_trans (Order.lt_succ_of_not_isMax h_not_max_s₀) h_lt)
          h_y_below_t h_A_y
      -- Use prior_SZ_last_transition on T_Ψ'.neg from pred(t).
      -- T_Ψ'.neg false at pred(t) (T_Ψ' true). T_Ψ'.neg true at succ(s₀) (T_Ψ' false).
      -- succ(s₀) < pred(t).
      have h_ss₀_lt_pt : Order.succ s₀ < Order.pred t := by
        by_contra h_ge; push_neg at h_ge
        have h_pp := h_N_pred ⟨Order.pred t, h_pred_t_class⟩
        have : t = Order.succ (Order.succ s₀) := le_antisymm
          ((Order.succ_pred_of_not_isMin (not_isMin t)).symm ▸
            Order.succ_le_succ h_ge)
          (Order.succ_le_of_lt h_succ_s₀_below_t)
        -- t = succ(succ(s₀)). pred(t) = succ(s₀).
        have h_pred_eq : Order.pred t = Order.succ s₀ := by rw [this]; exact Order.pred_succ _
        exact h_s₀_class ((contemp_equiv_is_equiv sig k M).trans
          (h_pred_eq ▸ h_pred_t_class)
          ((contemp_equiv_is_equiv sig k M).symm h_succ_s₀_class_s₀))
      -- Use prior_UZ_first_transition on T_Ψ'.neg starting from succ(s₀).
      have h_Tneg_true : temporal_truth M atomMap (Order.succ s₀) T_Ψ'.neg :=
        (temporal_truth_neg_iff_not M atomMap _ _).mpr h_T_false
      obtain ⟨c, _, h_Tneg_c, h_not_Tneg_sc⟩ :=
        prior_UZ_first_transition M atomMap h_prior_UZ (Order.succ s₀) T_Ψ'.neg
          h_Tneg_true ⟨Order.pred t, h_ss₀_lt_pt,
            fun h => (temporal_truth_neg_iff_not M atomMap _ _).mp h h_T_true⟩
      -- ¬T_Ψ'(c) and T_Ψ'(succ(c)).
      have h_not_T_c : ¬ temporal_truth M atomMap c T_Ψ' :=
        (temporal_truth_neg_iff_not M atomMap c T_Ψ').mp h_Tneg_c
      have h_T_sc : temporal_truth M atomMap (Order.succ c) T_Ψ' :=
        temporal_truth_neg_neg_elim M atomMap (Order.succ c) T_Ψ' h_not_Tneg_sc
      obtain ⟨y₀, h_ce_y₀, h_sc_lt_y₀, h_A_y₀⟩ :=
        (h_Ψ_correct (Order.succ c)).mp ((h_T_correct (Order.succ c)).mpr h_T_sc)
      -- y₀ > succ(c) > c. y₀ ~M succ(c) ~M c. A(y₀).
      -- But ¬T_Ψ'(c): no y > c in class(c) with A(y). Contradiction.
      exact h_not_T_c ((h_T_correct c).mp ((h_Ψ_correct c).mpr ⟨y₀,
        (contemp_equiv_is_equiv sig k M).trans
          (no_boundary_at_successor sig k M c) h_ce_y₀,
        lt_trans (Order.lt_succ_of_not_isMax (not_isMax c)) h_sc_lt_y₀,
        h_A_y₀⟩))

  -- === Step 7: Truth preservation (M ↔ N) by structural induction ===
  -- Both directions simultaneously; the imp case needs both.
  have truth_pres : ∀ (B : Formula) (t : M.carrier) (h_t : contemp_equiv sig k M a t),
      temporal_truth M atomMap t B ↔ temporal_truth N atomMap ⟨t, h_t⟩ B := by
    intro B
    induction B with
    | atom α => intro t h_t; exact Iff.rfl
    | bot => intro t h_t; exact Iff.rfl
    | imp φ ψ ih_φ ih_ψ =>
      intro t h_t
      exact ⟨fun h_M h_N_φ => (ih_ψ t h_t).mp (h_M ((ih_φ t h_t).mpr h_N_φ)),
             fun h_N h_M_φ => (ih_ψ t h_t).mpr (h_N ((ih_φ t h_t).mp h_M_φ))⟩
    | box φ => intro t h_t; exact Iff.rfl
    | untl φ ψ ih_φ ih_ψ =>
      intro t h_t
      constructor
      · -- Forward: M → N
        intro ⟨s, h_ts, h_φ_s, h_ψ_between⟩
        by_cases h_s_class : contemp_equiv sig k M a s
        · -- s ∈ class(a): direct transfer via convexity
          exact ⟨⟨s, h_s_class⟩, h_ts, (ih_φ s h_s_class).mp h_φ_s,
            fun ⟨r, h_r⟩ h_tr h_rs => (ih_ψ r h_r).mp (h_ψ_between r h_tr h_rs)⟩
        · -- s ∉ class(a): all class(a) above t are below s.
          -- ψ holds at all intermediate M-points, including all class(a) above t.
          -- Need φ above t in class(a): use class_spread.
          obtain ⟨s', h_s'_class, h_φ_s'⟩ := class_spread φ s h_φ_s a
          by_cases h_s't : t < s'
          · -- s' > t: use it
            have h_s'_lt_s : s' < s := by
              by_contra h_ge; push_neg at h_ge
              rcases eq_or_gt_of_le h_ge with rfl | h_gt
              · exact h_s_class h_s'_class
              · exact h_s_class (class_convex t s s' h_t h_s'_class
                  (le_of_lt h_ts) (le_of_lt h_gt))
            exact ⟨⟨s', h_s'_class⟩, h_s't, (ih_φ s' h_s'_class).mp h_φ_s',
              fun ⟨r, h_r⟩ h_tr h_rs' =>
                (ih_ψ r h_r).mp (h_ψ_between r h_tr (lt_trans h_rs' h_s'_lt_s))⟩
          · -- s' ≤ t: use ordered_spread_above (Reynolds Lemma 11).
            push_neg at h_s't
            obtain ⟨w, hw_class, h_tw, h_φ_w⟩ :=
              ordered_spread_above φ t h_t s h_ts h_φ_s h_s_class
                s' h_s'_class h_φ_s' h_s't
            have h_w_lt_s : w < s := by
              by_contra h_ge; push_neg at h_ge
              rcases eq_or_gt_of_le h_ge with rfl | h_gt
              · exact h_s_class hw_class
              · exact h_s_class (class_convex t s w h_t hw_class
                  (le_of_lt h_ts) (le_of_lt h_gt))
            exact ⟨⟨w, hw_class⟩, h_tw, (ih_φ w hw_class).mp h_φ_w,
              fun ⟨r, h_r⟩ h_tr h_rw =>
                (ih_ψ r h_r).mp (h_ψ_between r h_tr (lt_trans h_rw h_w_lt_s))⟩
      · -- Backward: N → M
        intro ⟨⟨s, h_s⟩, h_ts, h_φ_s, h_ψ_between⟩
        exact ⟨s, h_ts, (ih_φ s h_s).mpr h_φ_s, fun r h_tr h_rs => by
          have h_r_class := class_convex t r s h_t h_s (le_of_lt h_tr) (le_of_lt h_rs)
          exact (ih_ψ r h_r_class).mpr (h_ψ_between ⟨r, h_r_class⟩ h_tr h_rs)⟩
    | snce φ ψ ih_φ ih_ψ =>
      intro t h_t
      constructor
      · -- Forward: M → N (mirror of Until)
        intro ⟨s, h_st, h_φ_s, h_ψ_between⟩
        by_cases h_s_class : contemp_equiv sig k M a s
        · exact ⟨⟨s, h_s_class⟩, h_st, (ih_φ s h_s_class).mp h_φ_s,
            fun ⟨r, h_r⟩ h_sr h_rt => (ih_ψ r h_r).mp (h_ψ_between r h_sr h_rt)⟩
        · obtain ⟨s', h_s'_class, h_φ_s'⟩ := class_spread φ s h_φ_s a
          by_cases h_s't : s' < t
          · have h_s_lt_s' : s < s' := by
              by_contra h_ge; push_neg at h_ge
              rcases eq_or_gt_of_le h_ge with rfl | h_gt
              · exact h_s_class h_s'_class
              · exact h_s_class (class_convex s' s t h_s'_class h_t
                  (le_of_lt h_gt) (le_of_lt h_st))
            exact ⟨⟨s', h_s'_class⟩, h_s't, (ih_φ s' h_s'_class).mp h_φ_s',
              fun ⟨r, h_r⟩ h_s'r h_rt =>
                (ih_ψ r h_r).mp (h_ψ_between r (lt_trans h_s_lt_s' h_s'r) h_rt)⟩
          · -- s' ≥ t: use ordered_spread_below (Reynolds Lemma 11).
            push_neg at h_s't
            obtain ⟨w, hw_class, h_wt, h_φ_w⟩ :=
              ordered_spread_below φ t h_t s h_st h_φ_s h_s_class
                s' h_s'_class h_φ_s' h_s't
            have h_s_lt_w : s < w := by
              by_contra h_ge; push_neg at h_ge
              rcases eq_or_gt_of_le h_ge with rfl | h_gt
              · exact h_s_class hw_class
              · exact h_s_class (class_convex w s t hw_class h_t
                  (le_of_lt h_gt) (le_of_lt h_st))
            exact ⟨⟨w, hw_class⟩, h_wt, (ih_φ w hw_class).mp h_φ_w,
              fun ⟨r, h_r⟩ h_wr h_rt =>
                (ih_ψ r h_r).mp (h_ψ_between r (lt_trans h_s_lt_w h_wr) h_rt)⟩
      · -- Backward: N → M
        intro ⟨⟨s, h_s⟩, h_st, h_φ_s, h_ψ_between⟩
        exact ⟨s, h_st, (ih_φ s h_s).mpr h_φ_s, fun r h_sr h_rt => by
          have h_r_class := class_convex s r t h_s h_t (le_of_lt h_sr) (le_of_lt h_rt)
          exact (ih_ψ r h_r_class).mpr (h_ψ_between ⟨r, h_r_class⟩ h_sr h_rt)⟩
  -- === Step 8: Prior-UZ/SZ on N (from truth preservation) ===
  have h_a_class : contemp_equiv sig k M a a := (contemp_equiv_is_equiv sig k M).refl a
  have h_prior_UZ_N : semantic_prior_UZ N atomMap := by
    intro ⟨t, h_t⟩ ψ ⟨⟨s, h_s⟩, h_ts, h_ψ_s⟩
    -- Need first occurrence of ψ above t in N.
    -- Transfer to M: ψ holds at s (in N) → ψ holds at s (in M).
    have h_ψ_s_M := (truth_pres ψ s h_s).mpr h_ψ_s
    -- Apply Prior-UZ on M
    obtain ⟨s₀, h_ts₀, h_ψ_s₀, h_neg_between⟩ :=
      h_prior_UZ t ψ ⟨s, h_ts, h_ψ_s_M⟩
    -- s₀ > t, ψ(s₀), ¬ψ between t and s₀ in M.
    -- Is s₀ in class(a)?
    -- s₀ is between t and s (t < s₀ ≤ s since s₀ is the first occurrence).
    -- Actually s₀ ≤ s by first-occurrence. t < s₀ ≤ s. Both t and s are in class(a).
    -- By convexity: s₀ ∈ class(a) (since t ≤ s₀ ≤ s, both endpoints in class(a)).
    have h_s₀_le_s : s₀ ≤ s := by
      by_contra h_gt; push_neg at h_gt
      -- s₀ > s. ψ.neg between t and s₀ (including at s). But ψ holds at s. Contradiction.
      -- h_neg_between s h_ts h_gt : temporal_truth M atomMap s ψ.neg = ¬ temporal_truth M ψ
      exact (h_neg_between s h_ts h_gt) h_ψ_s_M
    have h_s₀_class : contemp_equiv sig k M a s₀ :=
      class_convex t s₀ s h_t h_s (le_of_lt h_ts₀) h_s₀_le_s
    -- Transfer s₀ to N
    refine ⟨⟨s₀, h_s₀_class⟩, h_ts₀, (truth_pres ψ s₀ h_s₀_class).mp h_ψ_s₀, ?_⟩
    -- ¬ψ between t and s₀ in N
    intro ⟨r, h_r⟩ h_tr h_rs₀
    exact (truth_pres ψ.neg r h_r).mp (h_neg_between r h_tr h_rs₀)
  have h_prior_SZ_N : semantic_prior_SZ N atomMap := by
    intro ⟨t, h_t⟩ ψ ⟨⟨s, h_s⟩, h_st, h_ψ_s⟩
    have h_ψ_s_M := (truth_pres ψ s h_s).mpr h_ψ_s
    obtain ⟨s₀, h_s₀t, h_ψ_s₀, h_neg_between⟩ :=
      h_prior_SZ t ψ ⟨s, h_st, h_ψ_s_M⟩
    have h_s_le_s₀ : s ≤ s₀ := by
      by_contra h_gt; push_neg at h_gt
      exact (h_neg_between s h_gt h_st) h_ψ_s_M
    have h_s₀_class : contemp_equiv sig k M a s₀ :=
      class_convex s s₀ t h_s h_t h_s_le_s₀ (le_of_lt h_s₀t)
    refine ⟨⟨s₀, h_s₀_class⟩, h_s₀t, (truth_pres ψ s₀ h_s₀_class).mp h_ψ_s₀, ?_⟩
    intro ⟨r, h_r⟩ h_s₀r h_rt
    exact (truth_pres ψ.neg r h_r).mp (h_neg_between r h_s₀r h_rt)
  -- === Step 9: R holds on N (by forward truth preservation) ===
  have h_R_on_N : ∀ (t : M.carrier) (h_t : contemp_equiv sig k M a t),
      temporal_truth N atomMap ⟨t, h_t⟩ R := by
    intro t h_t
    exact (truth_pres R t h_t).mp (h_R_everywhere t)
  -- === Step 10: right_gap_class_formula is FALSE on N ===
  -- All N-subintervals are good, so no bad subintervals exist.
  -- right_gap_class_formula on N: ∃ b > t (b ∈ N), ∃ a' b' (∈ N), guard ∧ ¬good(N.sub a' b')
  -- Since N.sub a' b' is k-equiv to M.sub a'.val b'.val (by subinterval_of_subinterval
  -- and convexity of class(a)), and M.sub a'.val b'.val is good (h_N_very_good),
  -- the formula is false.
  have h_rgcf_false_N : ∀ (t : M.carrier) (h_t : contemp_equiv sig k M a t),
      ¬ eval N (fun _ => ⟨t, h_t⟩) (right_gap_class_formula sig k) := by
    intro t h_t h_eval
    -- Unfold the formula evaluation on N step by step
    simp only [right_gap_class_formula, eval, eval_leq] at h_eval
    -- h_eval : ∃ b : N.carrier, t_N < b ∧ ∃ b' a' : N.carrier, guard ∧ ¬ eval N env4 (good_rel_lifted)
    obtain ⟨b, h_tb, b', a', ⟨⟨h_ta', h_a'b'⟩, h_b'b⟩, h_not_good⟩ := h_eval
    -- a', b' ∈ N.carrier = classA with a' ≤ b'.
    -- ¬ eval N env4 (good_rel_lifted sig k)
    -- eval_good_rel_lifted on N: eval N env4 (good_rel_lifted) ↔ eval N (Fin.cons a' (Fin.cons b' Fin.elim0)) (good_formula_relativized)
    rw [eval_good_rel_lifted] at h_not_good
    -- good_formula_relativized_correct on N: eval N (...) ↔ good(N.subinterval a' b')
    -- But good_formula_relativized_correct requires a'.val ≤ b'.val (h_a'b')
    -- Actually h_a'b' is the N-order: a' ≤ b' (subtype order = underlying order).
    -- Need: good(N.subinterval sig a' b')
    -- Use show to normalize the env after eval_good_rel_lifted
    have h_eval_form : eval N (Fin.cons a' (Fin.cons b' Fin.elim0))
        (good_formula_relativized sig k) := by
      -- After eval_good_rel_lifted, the env has Fin.cons (env 0) (Fin.cons (env 1) Fin.elim0)
      -- where env 0 = a' and env 1 = b' definitionally.
      show eval N (Fin.cons a' (Fin.cons b' Fin.elim0)) (good_formula_relativized sig k)
      rw [good_formula_relativized_correct sig k N a' b' h_a'b']
      -- Need: good(N.subinterval sig a' b')
      -- N.subinterval a' b' has carrier {x : N.carrier // a' ≤ x ∧ x ≤ b'}
      -- M.subinterval a'.val b'.val has carrier {x : M.carrier // a'.val ≤ x ∧ x ≤ b'.val}
      -- These are isomorphic via the inclusion (convexity ensures all intermediate
      -- M-points are in class(a)).
      have h_M_good := h_N_very_good a' b' h_a'b'
      -- h_M_good : good(M.subinterval sig a'.val b'.val)
      -- Transfer: N.subinterval a' b' ≃ M.subinterval a'.val b'.val
      obtain ⟨Z, hZ⟩ := h_M_good
      refine ⟨Z, ?_⟩
      -- Build k_equiv between N.subinterval a' b' and Z.toOrdered
      -- by composing: N.sub ≃ M.sub a'.val b'.val ≃k Z.toOrdered
      -- The first iso follows from convexity of class(a).
      let f : (N.subinterval sig a' b').carrier ≃o (M.subinterval sig a'.val b'.val).carrier := {
        toEquiv := {
          toFun := fun ⟨⟨x, hx_class⟩, ha'x, hxb'⟩ => ⟨x, ha'x, hxb'⟩
          invFun := fun ⟨x, ha'x, hxb'⟩ =>
            ⟨⟨x, class_convex a'.val x b'.val a'.property b'.property ha'x hxb'⟩, ha'x, hxb'⟩
          left_inv := by intro ⟨⟨_, _⟩, _, _⟩; rfl
          right_inv := by intro ⟨_, _, _⟩; rfl
        }
        map_rel_iff' := by intro ⟨⟨_, _⟩, _, _⟩ ⟨⟨_, _⟩, _, _⟩; exact Iff.rfl
      }
      exact (k_equiv_of_iso sig k _ _ f (fun p ⟨⟨_, _⟩, _, _⟩ => Iff.rfl)).trans hZ
    exact h_not_good h_eval_form
  -- === Step 11: R on N ↔ right_gap_class_formula on N ===
  -- Use US_expressively_complete_over_prior.property directly (doesn't need SuccOrder on N).
  have h_R_iff_rgcf_N : ∀ (t : M.carrier) (h_t : contemp_equiv sig k M a t),
      eval N (fun _ => ⟨t, h_t⟩) (right_gap_class_formula sig k) ↔
      temporal_truth N atomMap ⟨t, h_t⟩ R := by
    intro t h_t
    exact (US_expressively_complete_over_prior atomMap h_surj
      (right_gap_class_formula sig k)).property N h_prior_UZ_N h_prior_SZ_N ⟨t, h_t⟩
  -- === Step 12: Contradiction ===
  exact h_rgcf_false_N a h_a_class ((h_R_iff_rgcf_N a h_a_class).mpr (h_R_on_N a h_a_class))

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
