import Bimodal.Metalogic.WeakCanonical.PriorExpressiveness
import Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructures
import Bimodal.Metalogic.WeakCanonical.EFGames.Defs

/-!
# Reynolds No-Gaps Theorem and Archimedean One-Class Theorem

This file provides the key theorems needed to close the sorry sites in the
Reynolds completeness pipeline:

1. `one_class_archimedean`: In any discrete archimedean linear order with
   successor/predecessor, all points are contemporaneously equivalent.
   This does NOT require Prior-UZ/SZ -- the archimedean property suffices.

2. `no_gaps_discrete_archimedean`: The archimedean specialization of
   `no_gaps_discrete`. Since all points are equivalent, the premise
   (a ≁ b) is vacuously false.

3. `gap_of_not_succ_archimedean`: If NOT IsSuccArchimedean, there exists a Gap
   (Dedekind cut with no maximum and no minimum in complement).

4. `no_gaps_prior`: In a Prior structure with sufficiently rich signature,
   there are no gaps (Dedekind cuts). Combined with discreteness, this gives
   IsSuccArchimedean. This is the core of Reynolds Theorem 14.

## Mathematical Content

In an `IsSuccArchimedean` discrete linear order:
- Every closed interval [a,b] is finite (by `subinterval_finite_of_succ_archimedean`)
- Every finite structure is good (by `finite_structures_good`)
- Therefore every subinterval is good, hence every structure is very good
- Therefore all points are contemporaneously equivalent

For the converse (Prior => IsSuccArchimedean), the argument is:
1. If NOT IsSuccArchimedean, there exists a Gap (Dedekind cut).
2. In a discrete order, the Gap is defined by a successor-closed downward set.
3. By Reynolds Theorem 5 (US expressive completeness), the Gap is detectable
   by a temporal formula (the gap formula R).
4. Model surgery (Reynolds Lemmas 10-13) shows the Gap leads to contradiction.

## References

- Reynolds 1994, Section 7, Theorem 14 (general version)
- Reynolds 1994, Section 8, Theorem 15 (one-class theorem)
- Doets 1989, Theorem 1.1 (finite structures are good)
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-! ## Archimedean Very-Good Theorem

In an archimedean discrete linear order, every structure is very good.
-/

/--
In a successor-archimedean discrete linear order, every subinterval is finite,
hence good. Therefore every structure is very good.
-/
theorem very_good_of_archimedean (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) [SuccOrder M.carrier]
    [IsSuccArchimedean M.carrier] :
    very_good sig k M := by
  intro a b hab
  -- The subinterval [a,b] is finite in an archimedean order
  haveI h_fin : Finite (M.subinterval sig a b).carrier :=
    subinterval_finite_of_succ_archimedean sig M a b hab
  haveI : Fintype (M.subinterval sig a b).carrier := Fintype.ofFinite _
  -- good requires k-equiv to a Z-interval; finite structures are good
  exact finite_structures_good sig k _

/--
**Archimedean One-Class Theorem**: In any discrete archimedean linear order
without endpoints, all points are contemporaneously equivalent.

This is a consequence of the fact that in archimedean orders, all subintervals
are finite, hence good, hence every structure is very good.

No Prior-UZ/SZ hypotheses are needed -- the archimedean property alone suffices.
-/
theorem one_class_archimedean (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) [SuccOrder M.carrier]
    [IsSuccArchimedean M.carrier] :
    ∀ (a b : M.carrier), contemp_equiv sig k M a b := by
  intro a b
  simp only [contemp_equiv, very_good]
  intro x y hxy
  -- x, y are in (M.subinterval sig (min a b) (max a b)).carrier
  -- Need: good sig k of the sub-subinterval
  -- By subinterval_of_subinterval_k_equiv, the sub-subinterval is k-equiv to
  -- M.subinterval sig x.val y.val
  have h_k_equiv := subinterval_of_subinterval_k_equiv sig k M (min a b) (max a b) x y
  -- M.subinterval sig x.val y.val is finite (archimedean)
  have hxy_val : x.val ≤ y.val := hxy
  haveI : Finite (M.subinterval sig x.val y.val).carrier :=
    subinterval_finite_of_succ_archimedean sig M x.val y.val hxy_val
  haveI : Fintype (M.subinterval sig x.val y.val).carrier := Fintype.ofFinite _
  -- Finite structures are good
  obtain ⟨Z, hZ⟩ := finite_structures_good sig k (M.subinterval sig x.val y.val)
  exact ⟨Z, h_k_equiv.trans hZ⟩

/--
**Archimedean No-Gaps Theorem**: Specialization of `no_gaps_discrete` for
archimedean orders. The premise ¬contemp_equiv a b is always false
(by `one_class_archimedean`), so the conclusion holds vacuously.

This version does NOT require Prior-UZ/SZ. It can be used in place of
`no_gaps_discrete` wherever the underlying order is archimedean.
-/
theorem no_gaps_discrete_archimedean (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    [IsSuccArchimedean M.carrier]
    (a b : M.carrier) (h_diff_class : ¬ contemp_equiv sig k M a b) :
    ∃ (c : M.carrier), contemp_equiv sig k M a c ∧
      ¬ contemp_equiv sig k M a (Order.succ c) := by
  -- The premise is always false: all points are contemp_equiv in archimedean orders
  exact absurd (one_class_archimedean sig k M a b) h_diff_class

/-! ## Gap Existence from Non-Archimedean

If a discrete linear order without endpoints is NOT IsSuccArchimedean,
then there exists a Dedekind gap (a `Gap` in the EF game framework sense).

The gap is constructed from the successor orbit of a point that cannot
reach some larger point: cut = {x : ∃ n, x ≤ succ^[n] a}.
-/

/-- Helper: the successor orbit set {x : ∃ n, x ≤ succ^[n] a} is closed under
    successor: if x ∈ orbit_le, then succ(x) ∈ orbit_le. -/
private theorem orbit_le_succ_closed {T : Type} [LinearOrder T] [SuccOrder T]
    [NoMaxOrder T] (a : T) :
    ∀ x : T, (∃ n : Nat, x ≤ Order.succ^[n] a) →
      (∃ n : Nat, Order.succ x ≤ Order.succ^[n] a) := by
  intro x ⟨n, hx⟩
  rcases eq_or_lt_of_le hx with hx_eq | hx_lt
  · -- x = succ^[n] a. Then succ(x) = succ^[n+1] a.
    exact ⟨n + 1, by rw [Function.iterate_succ']; exact le_of_eq (congrArg Order.succ hx_eq)⟩
  · -- x < succ^[n] a. Then succ(x) ≤ succ^[n] a (by succ_le_of_lt).
    exact ⟨n, Order.succ_le_of_lt hx_lt⟩

/--
**Gap Existence**: If a discrete linear order without endpoints is NOT
IsSuccArchimedean, then there exists a Dedekind Gap.

The gap is constructed as follows: given a, b with succ^[n](a) ≠ b for all n
(witnessed by ¬IsSuccArchimedean), define

  cut = {x : ∃ n, x ≤ succ^[n] a}

This set is nonempty (contains a), proper (excludes b), downward-closed,
has no supremum in the cut (successor closure), and its complement has no
minimum (pred of any complement point is in the cut, and succ(pred) = that
point, giving contradiction).
-/
theorem gap_of_not_succ_archimedean {T : Type} [LinearOrder T]
    [SuccOrder T] [PredOrder T] [NoMaxOrder T] [NoMinOrder T]
    (h_not_arch : ¬ @IsSuccArchimedean T inferInstance inferInstance) :
    Nonempty (Gap T) := by
  -- NOT IsSuccArchimedean: ∃ a b, a ≤ b, ∀ n, succ^[n] a ≠ b
  -- Unfold the negation of the class
  have h_exists : ∃ a b : T, a ≤ b ∧ ∀ n : Nat, Order.succ^[n] a ≠ b := by
    by_contra h_all
    push_neg at h_all
    exact h_not_arch ⟨fun {a b} hab => h_all a b hab⟩
  obtain ⟨a, b, hab, h_unreach⟩ := h_exists
  -- All successor iterates of a are strictly below b
  have h_lt : ∀ n : Nat, Order.succ^[n] a < b := by
    intro n
    induction n with
    | zero => simp; exact lt_of_le_of_ne hab (h_unreach 0)
    | succ n ih =>
      -- succ^[n] a < b, so succ(succ^[n] a) ≤ b
      have h_le : Order.succ^[n + 1] a ≤ b := by
        rw [Function.iterate_succ']
        exact Order.succ_le_of_lt ih
      exact lt_of_le_of_ne h_le (h_unreach (n + 1))
  -- Define the cut: {x : ∃ n, x ≤ succ^[n] a}
  let cut : Set T := {x | ∃ n : Nat, x ≤ Order.succ^[n] a}
  -- Build the Gap
  refine ⟨⟨cut, ?_, ?_, ?_, ?_, ?_⟩⟩
  · -- nonempty: a ∈ cut
    exact ⟨a, 0, le_refl a⟩
  · -- proper: cut ≠ Set.univ (b ∉ cut)
    intro h_all
    have hb : b ∈ cut := h_all ▸ Set.mem_univ b
    obtain ⟨n, hn⟩ := hb
    exact not_le.mpr (h_lt n) hn
  · -- downward_closed
    intro x y ⟨n, hx⟩ hyx
    exact ⟨n, le_trans hyx hx⟩
  · -- no_sup: no s ∈ cut that is the LUB
    intro ⟨s, h_lub, hs⟩
    -- s ∈ cut, so s ≤ succ^[n] a for some n
    obtain ⟨n, hsn⟩ := hs
    -- succ(s) is also in cut: s ≤ succ^[n] a implies succ(s) ≤ succ^[n+1] a
    have h_succ_in : Order.succ s ∈ cut :=
      ⟨n + 1, by rw [Function.iterate_succ']; exact Order.succ_le_succ hsn⟩
    have h_succ_gt : s < Order.succ s := Order.lt_succ_of_not_isMax (not_isMax s)
    -- s is supposed to be an upper bound of cut, but succ(s) ∈ cut and succ(s) > s
    exact not_le.mpr h_succ_gt (h_lub.1 h_succ_in)
  · -- complement_no_min: complement has no minimum
    intro ⟨m, hm_not, hm_min⟩
    -- m ∉ cut, so ∀ n, ¬(m ≤ succ^[n] a), i.e., succ^[n] a < m for all n
    have hm_above : ∀ n : Nat, Order.succ^[n] a < m := by
      intro n
      by_contra h
      push_neg at h
      exact hm_not ⟨n, h⟩
    -- pred(m) < m, so pred(m) might be in cut
    -- In a discrete order: succ(pred(m)) = m (since m is not min)
    have h_not_min : ¬ IsMin m := by
      intro h_min
      exact not_isMin_of_lt (hm_above 0) h_min
    have h_succ_pred : Order.succ (Order.pred m) = m :=
      Order.succ_pred_of_not_isMin h_not_min
    -- pred(m) < m, so we check if pred(m) ∈ cut
    have h_pred_lt : Order.pred m < m := Order.pred_lt_of_not_isMin h_not_min
    -- pred(m) must be in cut (since m is the min of complement, and pred(m) < m)
    have h_pred_in : Order.pred m ∈ cut := by
      by_contra h_pred_not
      -- pred(m) ∉ cut, and pred(m) < m. But m is the min of complement.
      -- So pred(m) ≥ m (by hm_min). But pred(m) < m. Contradiction.
      exact not_le.mpr h_pred_lt (hm_min (Order.pred m) h_pred_not)
    -- pred(m) ∈ cut: ∃ n, pred(m) ≤ succ^[n] a
    obtain ⟨n, hn⟩ := h_pred_in
    -- succ(pred(m)) = m ≤ succ(succ^[n] a) = succ^[n+1] a
    have : m ≤ Order.succ^[n + 1] a := by
      rw [← h_succ_pred, Function.iterate_succ']
      exact Order.succ_le_succ hn
    -- But succ^[n+1] a < m (from hm_above)
    exact not_le.mpr (hm_above (n + 1)) this

/-! ## Prior-UZ/SZ Implies No Gaps (Reynolds Theorem 14)

In a discrete linear order satisfying Prior-UZ and Prior-SZ, there are no
Dedekind gaps. Combined with `gap_of_not_succ_archimedean` (contrapositive),
this gives `IsSuccArchimedean`.

The proof uses Reynolds' model surgery argument (Lemmas 6-13):
1. (Theorem 5) US expressive completeness: gap formula R exists
2. (Lemmas 7-8) R-intervals are open with no first/last class
3. (Lemma 9) Classes in R-intervals are elementarily equivalent
4. (Lemmas 10-13) Model surgery: replace bad interval by one class,
   temporal truth is preserved, leading to contradiction

**Status**: The key mathematical lemma `no_gaps_prior` encapsulates the
Reynolds model surgery argument. It is sorry'd pending full formalization
of Lemmas 6-13.
-/

/--
**Reynolds Theorem 14 (no gaps in Prior structures)**: In a discrete linear order
without endpoints satisfying Prior-UZ and Prior-SZ, there are no Dedekind gaps.

This is the core content of Reynolds 1994, Theorem 14, pp.124-129.
The proof requires the full model surgery argument (Lemmas 6-13).

The hypothesis h_surj (atomMap surjective onto sig.preds) is essential:
without it, the temporal formulas may not have enough expressive power
to detect the gap. The US expressive completeness theorem (Theorem 5)
requires h_surj to guarantee that every monadic FO formula has a
temporal equivalent.

**Mathematical argument**:
Suppose for contradiction that γ is a Gap. By US expressive completeness
(requiring h_surj), there exists a temporal formula R equivalent to the
FO formula ρ(x) = "x's equivalence class ends at γ on the right." Since
Prior-UZ gives first-occurrence properties, R holds at points near the gap.
Model surgery (Lemmas 10-13) replaces the bad interval near γ with a single
equivalence class, preserving temporal truth. In the surgery model, R holds
at the chosen class, but its class cannot end at a gap (the gap was removed).
Contradiction.
-/
theorem no_gaps_prior (sig : MonadicSignature) (k : Nat) (hk : k ≥ 1)
    (M : OrderedMonadicStructure sig) [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_prior_UZ : semantic_prior_UZ M atomMap)
    (h_prior_SZ : semantic_prior_SZ M atomMap) :
    IsEmpty (Gap M.carrier) := by
  -- Reynolds Theorem 14: model surgery argument
  -- The proof requires formalizing Lemmas 6-13 from Reynolds 1994.
  -- Key steps:
  -- 1. Construct gap formula R via US_expressively_complete_over_prior (Theorem 5)
  -- 2. Prove R-interval properties (Lemmas 7-9)
  -- 3. Model surgery (Lemmas 10-13)
  -- 4. Derive contradiction from R holding in surgery model
  sorry

/--
**Prior Implies Succ-Archimedean**: In a discrete linear order without endpoints
satisfying Prior-UZ and Prior-SZ, the order is IsSuccArchimedean.

This combines `no_gaps_prior` (no Dedekind gaps in Prior structures) with
`gap_of_not_succ_archimedean` (NOT archimedean implies gap exists).

Requires h_surj (atomMap surjective onto sig.preds) for the expressive
completeness argument in no_gaps_prior.
-/
theorem prior_implies_succ_archimedean (sig : MonadicSignature) (k : Nat) (hk : k ≥ 1)
    (M : OrderedMonadicStructure sig) [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_prior_UZ : semantic_prior_UZ M atomMap)
    (h_prior_SZ : semantic_prior_SZ M atomMap) :
    @IsSuccArchimedean M.carrier inferInstance (inferInstance : SuccOrder M.carrier) := by
  -- By contrapositive: if NOT archimedean, then gap exists.
  -- But no_gaps_prior says no gaps. Contradiction.
  by_contra h_not_arch
  have ⟨γ⟩ := gap_of_not_succ_archimedean h_not_arch
  exact (no_gaps_prior sig k hk M atomMap h_surj h_prior_UZ h_prior_SZ).elim γ

/--
**One-Class Implies Succ-Archimedean (revised)**: Derives IsSuccArchimedean from
Prior-UZ/SZ hypotheses. Requires h_surj for the expressive completeness argument.

This replaces the earlier version that lacked h_surj (which was mathematically
incorrect: constant-predicate structures can satisfy Prior-UZ/SZ and one_class
without being archimedean).
-/
theorem one_class_implies_succ_archimedean (sig : MonadicSignature) (k : Nat) (hk : k ≥ 1)
    (M : OrderedMonadicStructure sig) [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_prior_UZ : semantic_prior_UZ M atomMap)
    (h_prior_SZ : semantic_prior_SZ M atomMap) :
    @IsSuccArchimedean M.carrier inferInstance (inferInstance : SuccOrder M.carrier) :=
  prior_implies_succ_archimedean sig k hk M atomMap h_surj h_prior_UZ h_prior_SZ

end Bimodal.Metalogic.WeakCanonical
