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
reynolds_model_surgery_core (SORRY: Reynolds Lemmas 6-13, ~400-600 lines)
  <- gap_contradicts_prior (sorry-free)
  <- gap_contradicts_prior_below (sorry-free)
  <- no_gaps_discrete_model_surgery (sorry-free)
```

The single sorry is at `reynolds_model_surgery_core`, which states:
given h_surj + Prior-UZ/SZ + h_succ_closed, class(a) = whole carrier.
This requires the full Reynolds model surgery argument (constructing a
right_gap_class formula, analyzing R-intervals, performing domain surgery,
and proving temporal truth preservation). See the docstring on
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
- `gap_contradicts_prior`: succ-closed class bounded above → False
- `gap_contradicts_prior_below`: succ-closed class bounded below → False
- `no_gaps_discrete_model_surgery`: main theorem (sorry-free given core)

### Sorry (1 remaining)
- `reynolds_model_surgery_core`: class(a) succ-closed → class(a) = whole carrier

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

/-- **Reynolds Theorem 14 core** (Reynolds 1994, Lemmas 6-13):
    In a discrete Prior structure with atom-surjective atomMap, if class(a)
    is succ-closed then class(a) = whole carrier.

    **STATUS: SORRY -- requires Reynolds model surgery (Lemmas 6-13)**

    This is the mathematical core of Reynolds Theorem 14. The proof requires
    implementing the full model surgery argument:

    1. Construct right_gap_class formula rho(x) via MonadicFormula sig 1
    2. Convert to temporal formula R via US_expressively_complete_over_prior
    3. Analyze R-intervals (Lemmas 7-9: open intervals, no first/last class,
       class homogeneity)
    4. Define bad intervals and prove formula propagation (Lemmas 10-11)
    5. Construct surgery model N by excising a bad interval (Lemma 12)
    6. Prove temporal truth preservation M <-> N (13 subcases for U/S)
    7. Derive contradiction: R holds in N but class boundary is at a point

    All hypotheses (h_surj, h_prior_UZ, h_prior_SZ, h_succ_closed) are
    needed and correct. The sorry is purely due to implementation effort
    (~400-600 lines of Lean code for Lemmas 6-13).

    See also: `no_boundary_at_successor` (sorry-free) guarantees that
    h_succ_closed is trivially satisfied in practice, since c ~M succ(c)
    for all c. The real content is: h_surj + Prior-UZ/SZ -> one class. -/
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
  sorry

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
