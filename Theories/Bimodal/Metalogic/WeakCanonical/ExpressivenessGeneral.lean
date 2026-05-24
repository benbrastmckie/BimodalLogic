import Bimodal.Metalogic.WeakCanonical.EFGames
import Bimodal.Automation.EFGameTactics
import Mathlib.Data.Finset.Sort
import Mathlib.Data.Fintype.Pigeonhole

/-!
# GHR93 Theorem 6: Forward-to-Backward Game Transfer

This file contains Theorem 6 from GHR93 (Gabbay, Hodkinson, Reynolds, 1994),
Chapter 9, Section 8: the forward-to-backward theorem for custom EF games.

## Statement

(*)_n: For all n, r: if Duplicator wins G_{1+3n; r}(M, xy; N, x'y'),
then she wins G_{n; r}(N, x'y'; M, xy).

This is stated at a uniform rank r for both games. The full GHR93 statement
uses rank r+4n for the forward game and rank r for the backward game;
that version requires an embedding between ExtendedCarrier types at
different ranks. This uniform-rank version suffices when combined with
Lemma 10 (round monotonicity).

## References

- GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9, Theorem 6
- Task 155 plan: Phase 4C, Task 4C.1
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-! ## Base Case Helper: Embedding 0-Game into 1-Game Tuples

For the base case of Theorem 6, we need to relate game_tuples for the
0-game (3 indices: x, b, y) to game_tuples for the 1-game (4 indices:
x, a(0), b_resp, y). The 0-game indices {0, 1, 2} map to 1-game indices
{0, 1, 3} respectively. -/

/-- Embedding from 0-game indices (Fin 3) to 1-game indices (Fin 4). -/
private def base_case_emb : Fin 3 → Fin 4 := fun k =>
  if k.val = 0 then ⟨0, by omega⟩
  else if k.val = 1 then ⟨1, by omega⟩
  else ⟨3, by omega⟩

/-- The M-side game_tuple for the 0-game at index k equals the M-side
    game_tuple for the 1-game (with constant selection) at the embedded index. -/
private theorem base_case_M_eq {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (x y : ExtendedCarrier M atomMap r) (b_sp : M.carrier) (b_resp : M.carrier)
    (k : Fin 3) :
    game_tuple x y Fin.elim0 b_sp k =
    game_tuple x y (fun _ : Fin 1 => extendPoint b_sp) b_resp (base_case_emb k) := by
  simp only [game_tuple, base_case_emb]
  have hk := k.isLt
  by_cases h0 : k.val = 0
  · simp [h0]
  · by_cases h1 : k.val = 1
    · simp [h1, show ¬(1 : Nat) = 0 from by omega,
            show ¬(1 : Nat) = 1 + 1 from by omega,
            show ¬(1 : Nat) = 1 + 2 from by omega]
    · -- k = 2 -> emb(k) = 3
      have hk2 : k.val = 2 := by omega
      simp [hk2, show ¬(2 : Nat) = 0 from by omega,
            show ¬(2 : Nat) = 1 from by omega]

/-- The N-side game_tuple for the 0-game at index k equals the N-side
    game_tuple for the 1-game at the embedded index, given that the
    selection a'_resp(0) equals extendPoint q. -/
private theorem base_case_N_eq {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (x' y' : ExtendedCarrier N atomMap r) (q : N.carrier) (p : N.carrier)
    (a'_resp : Fin 1 → ExtendedCarrier N atomMap r)
    (hq_eq : a'_resp ⟨0, by omega⟩ = extendPoint q)
    (k : Fin 3) :
    game_tuple x' y' Fin.elim0 q k =
    game_tuple x' y' a'_resp p (base_case_emb k) := by
  simp only [game_tuple, base_case_emb]
  have hk := k.isLt
  by_cases h0 : k.val = 0
  · simp [h0]
  · by_cases h1 : k.val = 1
    · simp [h1, show ¬(1 : Nat) = 0 from by omega,
            show ¬(1 : Nat) = 1 + 1 from by omega,
            show ¬(1 : Nat) = 1 + 2 from by omega]
      exact hq_eq.symm
    · have hk2 : k.val = 2 := by omega
      simp [hk2, show ¬(2 : Nat) = 0 from by omega,
            show ¬(2 : Nat) = 1 from by omega]

/-! ## GHR93 Claim 1 Infrastructure: Continuation Predicate and Gap Construction

Definitions and properties needed for the infimum-based split point
construction (GHR93, Chapter 9, Section 8, pp. 27-28).

The continuation predicate C(t) captures "t satisfies every rank-r formula
that holds throughout (a_n, y')". The continuation set S_C collects all
points in [x',y'] where C holds at every mu-point in the tail (t, y'].
The infimum of S_C determines the split point d.

### References

- GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9, Section 8, Claim 1
- Task 155 plan: Phase 4C-W1, Task W1.2a-c
-/

/-- The continuation predicate C (Prop-level, GHR93 p.115).
    C(t) holds iff t satisfies every rank-r formula that holds throughout
    the mu-points of (a_n, y').
    This captures the interval type X_{(a_n, y')} without materializing
    it as a single formula. -/
private def cont_holds {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (a_n y' : ExtendedCarrier N atomMap r)
    (t : ExtendedCarrier N atomMap r) : Prop :=
  ∀ A : StaviFormula, stavi_depth A ≤ r →
    (∀ v : ExtendedCarrier N atomMap r,
      a_n < v → v < y' → mu_holds v →
      stavi_temporal_truth_mu N atomMap r v A) →
    stavi_temporal_truth_mu N atomMap r t A

/-- Cross-structure continuation predicate (GHR93 p.115-116).
    Like cont_holds, but the hypothesis checks truth in N (the interval
    (a_n_N, y'_N)) while the conclusion evaluates in M at t_M.
    GHR93 defines the continuation set S_C^M from N-side interval type
    evaluated in M. -/
private def cont_holds_cross {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (a_n_N y'_N : ExtendedCarrier N atomMap r)
    (t_M : ExtendedCarrier M atomMap r) : Prop :=
  ∀ A : StaviFormula, stavi_depth A ≤ r →
    (∀ v : ExtendedCarrier N atomMap r,
      a_n_N < v → v < y'_N → mu_holds v →
      stavi_temporal_truth_mu N atomMap r v A) →
    stavi_temporal_truth_mu M atomMap r t_M A

/-- Cross-structure continuation set S_C^M (GHR93 p.115-116).
    Collects all points t in [x_M, y_M] (in M) where cont_holds_cross
    holds at every mu-point in the tail (t, y_M).
    The interval type is checked in N (via a_n_N, y'_N) but truth is
    evaluated in M. -/
private def continuation_set_cross {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (x_M y_M : ExtendedCarrier M atomMap r)
    (a_n_N y'_N : ExtendedCarrier N atomMap r) :
    Set (ExtendedCarrier M atomMap r) :=
  { t | inClosedInterval x_M y_M t ∧
    ∀ u : ExtendedCarrier M atomMap r,
      t < u → u < y_M → mu_holds u → cont_holds_cross a_n_N y'_N u }

/-- S_C^M is nonempty: y_M is in S_C^M since the tail condition (t, y_M) is
    vacuous when t = y_M (no u with y_M < u < y_M). -/
private theorem continuation_set_cross_nonempty {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {x_M y_M : ExtendedCarrier M atomMap r}
    {a_n_N y'_N : ExtendedCarrier N atomMap r}
    (hxy : x_M ≤ y_M) :
    (continuation_set_cross x_M y_M a_n_N y'_N).Nonempty := by
  refine ⟨y_M, ⟨hxy, le_refl y_M⟩, ?_⟩
  intro u hyu huy' _
  exact absurd (lt_trans hyu huy') (lt_irrefl y_M)

/-- S_C^M is upward-closed within [x_M, y_M]: if t ∈ S_C^M and t ≤ t' ≤ y_M
    with x_M ≤ t', then t' ∈ S_C^M. -/
private theorem continuation_set_cross_upward_closed {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {x_M y_M : ExtendedCarrier M atomMap r}
    {a_n_N y'_N : ExtendedCarrier N atomMap r}
    {t t' : ExtendedCarrier M atomMap r}
    (ht : t ∈ continuation_set_cross x_M y_M a_n_N y'_N)
    (htt' : t ≤ t') (ht'y : t' ≤ y_M) (hxt' : x_M ≤ t') :
    t' ∈ continuation_set_cross x_M y_M a_n_N y'_N := by
  refine ⟨⟨hxt', ht'y⟩, ?_⟩
  intro u ht'u huy hmu
  exact ht.2 u (lt_of_le_of_lt htt' ht'u) huy hmu

/-- The continuation set S_C (GHR93 p.115).
    S_C = {t ∈ [x',y'] : C holds at all mu-points in (t, y')}.
    Note: uses the OPEN interval (t, y') to avoid an edge case at y'
    where cont_holds cannot be derived from the interval hypothesis alone. -/
private def continuation_set {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (x' y' a_n : ExtendedCarrier N atomMap r) :
    Set (ExtendedCarrier N atomMap r) :=
  { t | inClosedInterval x' y' t ∧
    ∀ u : ExtendedCarrier N atomMap r,
      t < u → u < y' → mu_holds u → cont_holds a_n y' u }

/-- The infimum cut: carrier points that are lower bounds of a set S
    in the extended carrier. Used to construct a Gap when the infimum
    of S is not achieved at a carrier point. -/
private def inf_carrier_cut {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (S : Set (ExtendedCarrier N atomMap r)) : Set N.carrier :=
  { p : N.carrier | ∀ s ∈ S, (extendPoint p : ExtendedCarrier N atomMap r) ≤ s }

/-! ### S_C Properties -/

/-- S_C is nonempty: y' is in S_C since the tail condition (t, y') is
    vacuous when t = y' (no u with y' < u < y'). -/
private theorem continuation_set_nonempty {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {x' y' a_n : ExtendedCarrier N atomMap r}
    (hx'y' : x' ≤ y') :
    (continuation_set x' y' a_n).Nonempty := by
  refine ⟨y', ⟨hx'y', le_refl y'⟩, ?_⟩
  intro u hyu huy' _
  exact absurd (lt_trans hyu huy') (lt_irrefl y')

/-- S_C is upward-closed within [x',y']: if t ∈ S_C and t ≤ t' ≤ y'
    with x' ≤ t', then t' ∈ S_C. This holds because the tail (t', y']
    is a subset of (t, y']. -/
private theorem continuation_set_upward_closed {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {x' y' a_n : ExtendedCarrier N atomMap r}
    {t t' : ExtendedCarrier N atomMap r}
    (ht : t ∈ continuation_set x' y' a_n)
    (htt' : t ≤ t') (ht'y' : t' ≤ y') (hx't' : x' ≤ t') :
    t' ∈ continuation_set x' y' a_n := by
  refine ⟨⟨hx't', ht'y'⟩, ?_⟩
  intro u ht'u huy' hmu
  exact ht.2 u (lt_of_le_of_lt htt' ht'u) huy' hmu

/-- a_n is in S_C when a_n ∈ [x', y']: the continuation predicate C holds
    at all mu-points in (a_n, y') by definition (the universal quantifier
    in cont_holds is over formulas holding on (a_n, y'), which is self-referential
    and therefore trivially satisfied).

    With the open-interval definition (t, y'), the edge case u = y' never arises:
    u is strictly between a_n and y', so hforall applies directly. -/
private theorem a_n_in_continuation_set {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {x' y' a_n : ExtendedCarrier N atomMap r}
    (ha_n : inClosedInterval x' y' a_n) :
    a_n ∈ continuation_set x' y' a_n := by
  refine ⟨ha_n, ?_⟩
  intro u hanu huy' hmu
  -- u is a mu-point with a_n < u < y'. We need cont_holds a_n y' u.
  -- cont_holds a_n y' u says: for all A with depth ≤ r, if A holds at all
  -- mu-points v in (a_n, y'), then A holds at u.
  intro A hA hforall
  -- u is in (a_n, y') (since a_n < u and u < y'), so hforall applies directly
  exact hforall u hanu huy' hmu

/-! ### Gap Construction from Infimum Cut -/

/-- The infimum cut is downward-closed: if p is a lower bound of S and
    q ≤ p, then q is also a lower bound of S. -/
private theorem inf_carrier_cut_downward_closed {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (S : Set (ExtendedCarrier N atomMap r))
    (p q : N.carrier) (hp : p ∈ inf_carrier_cut S) (hqp : q ≤ p) :
    q ∈ inf_carrier_cut S := by
  intro s hs
  exact le_trans (extendPoint_le_iff q p |>.mpr hqp) (hp s hs)

/-- The infimum cut is nonempty when S is bounded below by some carrier
    point. In practice, we use x' when x' is a point, or find a point
    below x' when x' is a gap. -/
private theorem inf_carrier_cut_nonempty {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {S : Set (ExtendedCarrier N atomMap r)}
    {lb : ExtendedCarrier N atomMap r}
    (h_lb : ∀ s ∈ S, lb ≤ s)
    (h_ne : S.Nonempty)
    (h_pt_below : ∃ p : N.carrier, (extendPoint p : ExtendedCarrier N atomMap r) ≤ lb) :
    (inf_carrier_cut S).Nonempty := by
  obtain ⟨p, hp⟩ := h_pt_below
  exact ⟨p, fun s hs => le_trans hp (h_lb s hs)⟩

/-- The infimum cut is proper (not all of N.carrier) when S contains
    an actual point. If extendPoint q ∈ S then q ∉ inf_carrier_cut S
    (since extendPoint q ≤ extendPoint q but q would need to be strictly
    below itself). Actually, q IS in inf_carrier_cut if extendPoint q ≤ s
    for all s ∈ S, so we need a point ABOVE the infimum to witness properness. -/
private theorem inf_carrier_cut_proper {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {S : Set (ExtendedCarrier N atomMap r)}
    (h_above : ∃ (q : N.carrier) (s : S), (extendPoint q : ExtendedCarrier N atomMap r) > s.val) :
    inf_carrier_cut S ≠ Set.univ := by
  obtain ⟨q, ⟨s, hs⟩, hqs⟩ := h_above
  intro h_all
  have hq_in : q ∈ inf_carrier_cut S := h_all ▸ Set.mem_univ q
  have hq_le : (extendPoint q : ExtendedCarrier N atomMap r) ≤ s := hq_in s hs
  exact absurd hqs (not_lt.mpr hq_le)

/-- The infimum cut has no supremum in the cut when the infimum of S is
    NOT an actual carrier point.

    Proof idea: if p were the supremum of inf_carrier_cut and p ∈ inf_carrier_cut,
    then extendPoint p would be a lower bound of S that is in the cut.
    For any q ∈ inf_carrier_cut, extendPoint q ≤ extendPoint p (since p is sup).
    So extendPoint p = glb of S among carrier points. If extendPoint p is a lower
    bound of S, then either extendPoint p ∈ S (making inf S a point, contradiction)
    or extendPoint p < inf S. But since p is the supremum of the cut, any carrier
    point above p is NOT in the cut, meaning there exists s ∈ S with
    extendPoint q > s — but q is above p... The argument needs the negated
    hypothesis that inf S is not a point. -/
private theorem inf_carrier_cut_no_sup {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {S : Set (ExtendedCarrier N atomMap r)}
    (h_ne : S.Nonempty)
    (h_not_point_glb : ¬ ∃ p : N.carrier,
      (∀ s ∈ S, (extendPoint p : ExtendedCarrier N atomMap r) ≤ s) ∧
      (∀ q : N.carrier, (∀ s ∈ S, (extendPoint q : ExtendedCarrier N atomMap r) ≤ s) →
        (extendPoint q : ExtendedCarrier N atomMap r) ≤ extendPoint p)) :
    ¬∃ sup, IsLUB (inf_carrier_cut S) sup ∧ sup ∈ inf_carrier_cut S := by
  intro ⟨sup, ⟨h_ub, h_least⟩, h_sup_in⟩
  apply h_not_point_glb
  refine ⟨sup, ?_, ?_⟩
  · -- sup is a lower bound of S (since sup ∈ inf_carrier_cut S)
    exact h_sup_in
  · -- sup is the greatest such: if q is a lower bound of S among carrier points,
    -- then q ∈ inf_carrier_cut, so q ≤ sup (since sup is the LUB of inf_carrier_cut)
    intro q hq
    have hq_in : q ∈ inf_carrier_cut S := fun s hs => hq s hs
    exact extendPoint_le_iff q sup |>.mpr (h_ub hq_in)

/-- The complement of the infimum cut has no minimum when the infimum
    of S is not an actual carrier point.

    Proof idea: if m were the minimum of the complement, then m ∉ inf_carrier_cut,
    meaning ∃ s ∈ S with extendPoint m > s. But every q < m has q ∈ inf_carrier_cut
    (since m is the minimum of the complement). So extendPoint m is the infimum of S
    among carrier points — contradicting h_not_point_glb. -/
private theorem inf_carrier_cut_complement_no_min {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {S : Set (ExtendedCarrier N atomMap r)}
    (h_ne : S.Nonempty)
    (h_not_point_glb : ¬ ∃ p : N.carrier,
      (∀ s ∈ S, (extendPoint p : ExtendedCarrier N atomMap r) ≤ s) ∧
      (∀ q : N.carrier, (∀ s ∈ S, (extendPoint q : ExtendedCarrier N atomMap r) ≤ s) →
        (extendPoint q : ExtendedCarrier N atomMap r) ≤ extendPoint p)) :
    ¬∃ m, m ∉ inf_carrier_cut S ∧ ∀ y, y ∉ inf_carrier_cut S → m ≤ y := by
  intro ⟨m, hm_not_in, hm_min⟩
  -- m ∉ inf_carrier_cut means ∃ s₀ ∈ S with ¬(extendPoint m ≤ s₀), i.e., s₀ < extendPoint m.
  simp only [inf_carrier_cut, Set.mem_setOf_eq] at hm_not_in
  push_neg at hm_not_in
  obtain ⟨s₀, hs₀_in, hm_gt⟩ := hm_not_in
  -- For all q < m: q ∈ inf_carrier_cut (since m is min of complement).
  have h_below_in_cut : ∀ q : N.carrier, q < m → q ∈ inf_carrier_cut S := by
    intro q hqm
    by_contra hq_not_in
    exact absurd (hm_min q hq_not_in) (not_le.mpr hqm)
  -- In particular, for all q < m, extendPoint q ≤ s₀.
  have h_below_le_s0 : ∀ q : N.carrier, q < m → (extendPoint q : ExtendedCarrier N atomMap r) ≤ s₀ := by
    intro q hqm
    exact h_below_in_cut q hqm s₀ hs₀_in
  -- s₀ is sandwiched: extendPoint q ≤ s₀ and ¬(extendPoint m ≤ s₀).
  -- Case split: s₀ is a point or a gap.
  rcases isPoint_or_isGap s₀ with ⟨p₀, hp₀⟩ | ⟨g₀, hg₀⟩
  · -- s₀ = extendPoint p₀: p₀ is a carrier point below m.
    -- p₀ < m since extendPoint p₀ = s₀ and s₀ < extendPoint m ↔ p₀ < m
    rw [hp₀] at hm_gt
    have hp₀m : p₀ < m := (extendPoint_lt_iff p₀ m).mp hm_gt
    -- p₀ ∈ inf_carrier_cut (since p₀ < m)
    have hp₀_in_cut := h_below_in_cut p₀ hp₀m
    -- p₀ is a lower bound of S
    -- p₀ is the greatest carrier-point lower bound:
    -- for any q ∈ inf_carrier_cut, extendPoint q ≤ s₀ = extendPoint p₀,
    -- so q ≤ p₀.
    apply h_not_point_glb
    refine ⟨p₀, hp₀_in_cut, ?_⟩
    intro q hq_lb
    -- q is a carrier-point lower bound of S. So q ∈ inf_carrier_cut.
    -- extendPoint q ≤ s₀ = extendPoint p₀.
    have hq_le_s₀ : (extendPoint q : ExtendedCarrier N atomMap r) ≤ s₀ :=
      hq_lb s₀ hs₀_in
    rw [hp₀] at hq_le_s₀
    exact hq_le_s₀
  · -- s₀ = Sum.inr g₀: s₀ is a gap in the extended carrier.
    -- g₀.val.cut ⊇ { q : q < m } (from h_below_le_s0, since
    -- extendPoint q ≤ Sum.inr g₀ means q ∈ g₀.val.cut).
    -- Also m ∉ g₀.val.cut (from s₀ < extendPoint m, which means
    -- Sum.inr g₀ < Sum.inl m, i.e., m ∉ g₀.val.cut).
    rw [hg₀] at hm_gt
    -- extendPoint m > Sum.inr g₀ means Sum.inr g₀ < Sum.inl m
    -- In the extended order: Sum.inr g ≤ Sum.inl x iff x ∉ g.val.cut
    -- and Sum.inl x ≤ Sum.inr g iff x ∈ g.val.cut
    -- So Sum.inr g₀ < Sum.inl m means m ∉ g₀.val.cut (first part of lt)
    have hm_not_in_g0 : m ∉ g₀.val.cut := by
      -- Sum.inr g₀ < Sum.inl m means ¬(Sum.inl m ≤ Sum.inr g₀)
      -- Sum.inl m ≤ Sum.inr g₀ iff m ∈ g₀.val.cut
      intro hm_in
      -- If m ∈ g₀.val.cut, then extendPoint m ≤ Sum.inr g₀, contradicting hm_gt
      exact absurd (show (extendPoint m : ExtendedCarrier N atomMap r) ≤ Sum.inr g₀ from hm_in)
        (not_le.mpr (hg₀ ▸ hm_gt))
    -- g₀.val.cut ⊇ { q : q < m }
    have hq_in_g0 : ∀ q : N.carrier, q < m → q ∈ g₀.val.cut := by
      intro q hqm
      have h := h_below_le_s0 q hqm
      rw [hg₀] at h
      -- extendPoint q ≤ Sum.inr g₀ means q ∈ g₀.val.cut
      exact h
    -- But g₀.val is a valid Gap, so its complement has no minimum.
    -- The complement of g₀.val.cut has no minimum (Gap axiom).
    -- But m ∉ g₀.val.cut and for all q < m, q ∈ g₀.val.cut.
    -- So m is a minimum of the complement (since for any y ∉ g₀.val.cut,
    -- ¬(y < m) because y < m → y ∈ g₀.val.cut → contradiction).
    have hm_min_g0 : ∀ y : N.carrier, y ∉ g₀.val.cut → m ≤ y := by
      intro y hy_not_in
      by_contra hym
      push_neg at hym
      exact hy_not_in (hq_in_g0 y hym)
    exact absurd ⟨m, hm_not_in_g0, hm_min_g0⟩ g₀.val.complement_no_min

/-- Package: the infimum cut defines a valid Gap when the infimum of S
    is not achieved at a carrier point. Bundles the 5 Gap axioms.

    Hypotheses:
    - S is nonempty
    - S has a carrier-point lower bound (for cut nonemptiness)
    - S has a carrier-point upper bound that is NOT a lower bound (for cut properness)
    - The infimum of S is not achieved at any carrier point (for no_sup and complement_no_min)
-/
private noncomputable def infimum_gap {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {S : Set (ExtendedCarrier N atomMap r)}
    (h_ne : S.Nonempty)
    (h_pt_below : ∃ p : N.carrier, ∀ s ∈ S,
      (extendPoint p : ExtendedCarrier N atomMap r) ≤ s)
    (h_above : ∃ (q : N.carrier) (s : S),
      (extendPoint q : ExtendedCarrier N atomMap r) > s.val)
    (h_not_point_glb : ¬ ∃ p : N.carrier,
      (∀ s ∈ S, (extendPoint p : ExtendedCarrier N atomMap r) ≤ s) ∧
      (∀ q : N.carrier, (∀ s ∈ S, (extendPoint q : ExtendedCarrier N atomMap r) ≤ s) →
        (extendPoint q : ExtendedCarrier N atomMap r) ≤ extendPoint p)) :
    Gap N.carrier where
  cut := inf_carrier_cut S
  nonempty := by
    obtain ⟨p, hp⟩ := h_pt_below
    exact ⟨p, fun s hs => hp s hs⟩
  proper := inf_carrier_cut_proper h_above
  downward_closed := fun x y hx hyx => inf_carrier_cut_downward_closed S x y hx hyx
  no_sup := inf_carrier_cut_no_sup h_ne h_not_point_glb
  complement_no_min := inf_carrier_cut_complement_no_min h_ne h_not_point_glb

/-! ### Gap r-Definability (Sub-phase W1.2d)

The gap constructed from inf S_C is r-definable (GHR93 p.116).
The defining formula D witnesses gap_definable_on_right:
- Above the gap: all carrier points satisfy cont_holds, so D holds
- Below the gap: cont_holds fails cofinally, and by pigeonhole over
  finitely many rank_types (NormalForm finiteness), a single formula D
  fails cofinally in the cut.

### References

- GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9, Section 8, p.116
- Task 155 plan: Phase 4C-W1, Sub-phase W1.2d
-/

/-- Above the gap, every carrier point is above some element of S_C,
    hence (by upward-closedness) in S_C, hence satisfies cont_holds.

    More precisely: if p ∉ inf_carrier_cut S_C (i.e., p is above the gap),
    then there exists s ∈ S_C with s < extendPoint p, so extendPoint p is
    in S_C (by upward-closedness), so cont_holds holds at extendPoint p.

    From cont_holds, we get: for every A : StaviFormula with stavi_depth A ≤ r,
    if A holds at all mu-points in (a_n, y'), then A holds at extendPoint p.
    Via stavi_truth_mu_at_point, this gives stavi_temporal_truth N atomMap p A. -/
private theorem cont_holds_above_gap {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {x' y' a_n : ExtendedCarrier N atomMap r}
    {p : N.carrier}
    (h_not_in_cut : p ∉ inf_carrier_cut (continuation_set x' y' a_n))
    (hx'y' : x' ≤ y')
    (hp_lt_y' : (extendPoint p : ExtendedCarrier N atomMap r) < y')
    (hx'_le_p : x' ≤ (extendPoint p : ExtendedCarrier N atomMap r))
    (A : StaviFormula) (hA : stavi_depth A ≤ r)
    (hA_interval : ∀ v : ExtendedCarrier N atomMap r,
      a_n < v → v < y' → mu_holds v →
      stavi_temporal_truth_mu N atomMap r v A) :
    stavi_temporal_truth N atomMap p A := by
  -- p ∉ inf_carrier_cut S_C means ∃ s ∈ S_C, ¬(extendPoint p ≤ s)
  simp only [inf_carrier_cut, Set.mem_setOf_eq] at h_not_in_cut
  push_neg at h_not_in_cut
  obtain ⟨s, hs_in, hs_lt⟩ := h_not_in_cut
  -- s ∈ continuation_set x' y' a_n and s < extendPoint p
  -- extendPoint p is in [x', y'] and above s, so by upward-closedness
  -- extendPoint p ∈ S_C
  have hp_in_sc : (extendPoint p : ExtendedCarrier N atomMap r) ∈
      continuation_set x' y' a_n :=
    continuation_set_upward_closed hs_in (le_of_lt hs_lt) (le_of_lt hp_lt_y') hx'_le_p
  -- s ∈ S_C and s < extendPoint p. Since extendPoint p < y' and
  -- extendPoint p is a mu-point, s.2 gives cont_holds at extendPoint p.
  have h_mu : mu_holds (extendPoint p : ExtendedCarrier N atomMap r) :=
    mu_holds_point p
  have h_cont := hs_in.2 (extendPoint p) hs_lt hp_lt_y' h_mu
  -- h_cont : cont_holds a_n y' (extendPoint p)
  -- Apply cont_holds to our formula A
  have h_mu_truth := h_cont A hA hA_interval
  -- h_mu_truth : stavi_temporal_truth_mu N atomMap r (extendPoint p) A
  exact (stavi_truth_mu_at_point p A).mp h_mu_truth

/-- Below the gap, for any carrier point in the cut satisfying x' ≤ extendPoint p,
    cont_holds fails at some mu-point strictly above p and strictly below y'.

    extendPoint p ∈ [x',y'] ∧ p ∈ inf_carrier_cut S_C implies extendPoint p ∉ S_C
    (since p ∈ cut means extendPoint p is a lower bound of S_C, but p is NOT the
    greatest lower bound since h_not_point_glb holds). Being outside S_C with
    extendPoint p ∈ [x',y'] means ∃ u in (extendPoint p, y') where cont_holds
    fails. Unwinding cont_holds: ∃ A with stavi_depth A ≤ r, A holds on (a_n, y'),
    but ¬A at u. Via stavi_truth_mu_at_point on the mu-point u, this gives a
    carrier-level witness. -/
private theorem cont_fails_below_gap {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {x' y' a_n : ExtendedCarrier N atomMap r}
    {p : N.carrier}
    (h_in_cut : p ∈ inf_carrier_cut (continuation_set x' y' a_n))
    (hx'y' : x' ≤ y')
    (hx'_le_p : x' ≤ (extendPoint p : ExtendedCarrier N atomMap r))
    (hp_le_y' : (extendPoint p : ExtendedCarrier N atomMap r) ≤ y')
    (h_not_point_glb : ¬ ∃ p' : N.carrier,
      (∀ s ∈ continuation_set x' y' a_n,
        (extendPoint p' : ExtendedCarrier N atomMap r) ≤ s) ∧
      (∀ q : N.carrier,
        (∀ s ∈ continuation_set x' y' a_n,
          (extendPoint q : ExtendedCarrier N atomMap r) ≤ s) →
        (extendPoint q : ExtendedCarrier N atomMap r) ≤ extendPoint p')) :
    ∃ (u : ExtendedCarrier N atomMap r),
      (extendPoint p : ExtendedCarrier N atomMap r) < u ∧ u < y' ∧
      mu_holds u ∧ ¬ cont_holds a_n y' u := by
  -- Proof by contradiction: assume all mu-points in (extendPoint p, y') satisfy
  -- cont_holds. Then extendPoint p ∈ S_C (since the open-interval tail condition
  -- is satisfied). But p is also a lower bound of S_C (h_in_cut), so p is the
  -- greatest carrier-point lower bound, contradicting h_not_point_glb.
  by_contra h_no_witness
  push_neg at h_no_witness
  -- h_no_witness : ∀ u, extendPoint p < u → u < y' → mu_holds u →
  --               cont_holds a_n y' u
  -- This means extendPoint p ∈ S_C (since it's in [x',y'] and
  -- cont_holds holds at all mu-points in (extendPoint p, y'))
  have hp_in_sc : (extendPoint p : ExtendedCarrier N atomMap r) ∈
      continuation_set x' y' a_n := by
    refine ⟨⟨hx'_le_p, hp_le_y'⟩, ?_⟩
    exact h_no_witness
  -- Now p is a carrier-point lower bound of S_C AND extendPoint p ∈ S_C.
  -- In particular, p is the greatest carrier-point lower bound:
  -- for any q with extendPoint q ≤ all s ∈ S_C, in particular
  -- extendPoint q ≤ extendPoint p (since extendPoint p ∈ S_C).
  apply h_not_point_glb
  exact ⟨p, h_in_cut, fun q hq => hq (extendPoint p) hp_in_sc⟩

/-- NormalForm-to-StaviFormula bridge: carrier points with the same NormalForm
    characteristic at depth r (over `muSig sig` / `extendedStructureWithMu`)
    agree on all StaviFormula truth values at depth ≤ r.

    This bridges the NormalForm finiteness theory (NormalForm.lean) with the
    StaviFormula truth (EFGames.lean). The key is `stavi_table_mu`, which
    translates StaviFormulas to `MonadicFormula (muSig sig) 1` whose truth
    on `extendedStructureWithMu` equals `stavi_temporal_truth_mu`.

    Proof path:
    1. Same nf_characteristic on extendedStructureWithMu
    2. → by nf_agreement_from_shared_nf, same nf_eval_nf on all NFs
    3. → by doets_lemma_1_1, same eval on all depth-≤-r MonadicFormula (muSig sig) 1
    4. → in particular on stavi_table_mu A (depth ≤ r by stavi_table_mu_depth)
    5. → by stavi_table_mu_correct, same stavi_temporal_truth_mu
    6. → by stavi_truth_mu_at_point, same stavi_temporal_truth -/
private theorem nf_determines_stavi_truth {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {p q : N.carrier}
    (h_same_nf : nf_characteristic (extendedStructureWithMu N atomMap r) r 1
        (fun _ => extendPoint p) =
      nf_characteristic (extendedStructureWithMu N atomMap r) r 1
        (fun _ => extendPoint q))
    (A : StaviFormula) (hA : stavi_fo_depth A ≤ r) :
    stavi_temporal_truth N atomMap p A ↔
    stavi_temporal_truth N atomMap q A := by
  -- The proof uses the chain:
  --   same nf_characteristic on extendedStructureWithMu
  --   → same eval on all depth-≤-r MonadicFormula (muSig sig) 1
  --   → same eval on stavi_table_mu A
  --   → same stavi_temporal_truth_mu (by stavi_table_mu_correct)
  --   → same stavi_temporal_truth (by stavi_truth_mu_at_point)
  --
  -- Step 1: From nf_characteristic equality, derive nf_eval_nf agreement
  -- nf_characteristic_satisfies gives that each env satisfies its own characteristic.
  -- Since the characteristics are equal (h_same_nf), both envs satisfy the same NF.
  have h_p_nf := nf_characteristic_satisfies (extendedStructureWithMu N atomMap r) r 1
    (fun _ => extendPoint p)
  have h_q_nf := nf_characteristic_satisfies (extendedStructureWithMu N atomMap r) r 1
    (fun _ => extendPoint q)
  -- q satisfies q's characteristic, which equals p's characteristic
  have h_q_nf_as_p : nf_eval_nf (extendedStructureWithMu N atomMap r) r 1
      (fun _ => extendPoint q)
      (nf_characteristic (extendedStructureWithMu N atomMap r) r 1 (fun _ => extendPoint p)) :=
    h_same_nf ▸ h_q_nf
  -- Step 2: Agreement on all NFs at depth r
  have h_nf_agree := nf_agreement_from_shared_nf
    (extendedStructureWithMu N atomMap r) (fun _ => extendPoint p)
    (extendedStructureWithMu N atomMap r) (fun _ => extendPoint q)
    _ h_p_nf h_q_nf_as_p
  -- Step 3: By doets_lemma_1_1, agreement on stavi_table_mu A
  have h_eval_agree := doets_lemma_1_1 r 1 (stavi_table_mu atomMap A)
    (le_trans (stavi_table_mu_depth A) hA)
    (extendedStructureWithMu N atomMap r) (extendedStructureWithMu N atomMap r)
    (fun _ => extendPoint p) (fun _ => extendPoint q)
    h_nf_agree
  -- Step 4-5: Chain through stavi_table_mu_correct and stavi_truth_mu_at_point
  exact (stavi_truth_mu_at_point p A).symm.trans
    ((stavi_table_mu_correct (extendPoint p) A).symm.trans
      (h_eval_agree.trans
        ((stavi_table_mu_correct (extendPoint q) A).trans
          (stavi_truth_mu_at_point q A))))

/-- Variant of nf_determines_stavi_truth using NF at depth 2*r to handle
    formulas with stavi_depth ≤ r (whose stavi_fo_depth may be up to 2*r).
    The key insight: stavi_fo_depth A ≤ 2 * stavi_depth A (by stavi_fo_depth_le_twice_depth),
    so stavi_depth A ≤ r implies stavi_fo_depth A ≤ 2*r, and NF at depth 2*r
    captures the truth of stavi_table_mu A via doets_lemma_1_1. -/
private theorem nf_determines_stavi_truth_depth {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {p q : N.carrier}
    (h_same_nf : nf_characteristic (extendedStructureWithMu N atomMap r) (2 * r) 1
        (fun _ => extendPoint p) =
      nf_characteristic (extendedStructureWithMu N atomMap r) (2 * r) 1
        (fun _ => extendPoint q))
    (A : StaviFormula) (hA : stavi_depth A ≤ r) :
    stavi_temporal_truth N atomMap p A ↔
    stavi_temporal_truth N atomMap q A := by
  -- stavi_fo_depth A ≤ 2 * stavi_depth A ≤ 2 * r
  have hA_fo : stavi_fo_depth A ≤ 2 * r :=
    le_trans (stavi_fo_depth_le_twice_depth A) (Nat.mul_le_mul_left 2 hA)
  -- Same proof structure as nf_determines_stavi_truth but at depth 2*r
  have h_p_nf := nf_characteristic_satisfies (extendedStructureWithMu N atomMap r) (2 * r) 1
    (fun _ => extendPoint p)
  have h_q_nf := nf_characteristic_satisfies (extendedStructureWithMu N atomMap r) (2 * r) 1
    (fun _ => extendPoint q)
  have h_q_nf_as_p : nf_eval_nf (extendedStructureWithMu N atomMap r) (2 * r) 1
      (fun _ => extendPoint q)
      (nf_characteristic (extendedStructureWithMu N atomMap r) (2 * r) 1 (fun _ => extendPoint p)) :=
    h_same_nf ▸ h_q_nf
  have h_nf_agree := nf_agreement_from_shared_nf
    (extendedStructureWithMu N atomMap r) (fun _ => extendPoint p)
    (extendedStructureWithMu N atomMap r) (fun _ => extendPoint q)
    _ h_p_nf h_q_nf_as_p
  have h_eval_agree := doets_lemma_1_1 (2 * r) 1 (stavi_table_mu atomMap A)
    (le_trans (stavi_table_mu_depth A) hA_fo)
    (extendedStructureWithMu N atomMap r) (extendedStructureWithMu N atomMap r)
    (fun _ => extendPoint p) (fun _ => extendPoint q)
    h_nf_agree
  exact (stavi_truth_mu_at_point p A).symm.trans
    ((stavi_table_mu_correct (extendPoint p) A).symm.trans
      (h_eval_agree.trans
        ((stavi_table_mu_correct (extendPoint q) A).trans
          (stavi_truth_mu_at_point q A))))

/-- Pigeonhole extraction: from the fact that cont_holds fails cofinally
    below the gap, extract a SINGLE formula D of depth ≤ r that holds on
    the interval but fails cofinally in the cut.

    By contradiction: if every formula eventually holds, we build an ascending
    chain of failure points with pairwise distinct NormalForm types (at depth
    2*r over muSig sig). Since NormalForm (muSig sig) (2*r) 1 is Fintype,
    the chain length exceeds the cardinality, giving a contradiction.

    Uses nf_determines_stavi_truth_depth for the key step:
    same NF type → same truth → the "old" formula still holds → new failure
    must have a different NF type. -/
private theorem pigeonhole_definable_formula {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {x' y' a_n : ExtendedCarrier N atomMap r}
    (hx'y' : x' ≤ y')
    (h_cut_start : ∃ p₀ : N.carrier,
      p₀ ∈ inf_carrier_cut (continuation_set x' y' a_n) ∧
      x' ≤ (extendPoint p₀ : ExtendedCarrier N atomMap r))
    (h_cofinal_failure :
      ∀ p : N.carrier, p ∈ inf_carrier_cut (continuation_set x' y' a_n) →
        x' ≤ (extendPoint p : ExtendedCarrier N atomMap r) →
        (extendPoint p : ExtendedCarrier N atomMap r) ≤ y' →
        ∃ (u : N.carrier),
          p ≤ u ∧
          u ∈ inf_carrier_cut (continuation_set x' y' a_n) ∧
          ∃ (A : StaviFormula),
            stavi_depth A ≤ r ∧
            (∀ v : ExtendedCarrier N atomMap r,
              a_n < v → v < y' → mu_holds v →
              stavi_temporal_truth_mu N atomMap r v A) ∧
            ¬ stavi_temporal_truth N atomMap u A) :
    ∃ (D : StaviFormula),
      stavi_depth D ≤ r ∧
      (∀ v : ExtendedCarrier N atomMap r,
        a_n < v → v < y' → mu_holds v →
        stavi_temporal_truth_mu N atomMap r v D) ∧
      (∀ t : N.carrier, t ∈ inf_carrier_cut (continuation_set x' y' a_n) →
        x' ≤ (extendPoint t : ExtendedCarrier N atomMap r) →
        (extendPoint t : ExtendedCarrier N atomMap r) ≤ y' →
        ∃ u : N.carrier, t ≤ u ∧
          u ∈ inf_carrier_cut (continuation_set x' y' a_n) ∧
          ¬ stavi_temporal_truth N atomMap u D) := by
  -- Cut points are below y' (since y' ∈ S_C and cut points are lower bounds of S_C)
  have cut_le_y' : ∀ p, p ∈ inf_carrier_cut (continuation_set x' y' a_n) →
      (extendPoint p : ExtendedCarrier N atomMap r) ≤ y' := by
    intro p hp
    obtain ⟨s₀, hs₀⟩ := continuation_set_nonempty hx'y' (a_n := a_n)
    exact le_trans (hp s₀ hs₀) hs₀.1.2
  -- By contradiction: suppose no single formula fails cofinally.
  by_contra h_no_cofinal
  push_neg at h_no_cofinal
  -- Pigeonhole over NormalForm types at depth 2*r (to handle stavi_fo_depth gap).
  -- nf_determines_stavi_truth_depth: same NF at depth 2*r → same truth for stavi_depth ≤ r.
  let K := Fintype.card (NormalForm (muSig sig) (2 * r) 1)
  obtain ⟨p₀, hp₀_cut, hx'_p₀⟩ := h_cut_start
  -- One-step: from a cut point with x' ≤ extendPoint, produce failure data + next floor
  have one_step : ∀ (f : N.carrier),
      f ∈ inf_carrier_cut (continuation_set x' y' a_n) →
      x' ≤ (extendPoint f : ExtendedCarrier N atomMap r) →
      ∃ (u : N.carrier) (A : StaviFormula) (t nf : N.carrier),
        f ≤ u ∧ u ∈ inf_carrier_cut (continuation_set x' y' a_n) ∧
        stavi_depth A ≤ r ∧
        (∀ v : ExtendedCarrier N atomMap r,
          a_n < v → v < y' → mu_holds v → stavi_temporal_truth_mu N atomMap r v A) ∧
        ¬ stavi_temporal_truth N atomMap u A ∧
        (∀ w, t ≤ w → w ∈ inf_carrier_cut (continuation_set x' y' a_n) →
          stavi_temporal_truth N atomMap w A) ∧
        nf ∈ inf_carrier_cut (continuation_set x' y' a_n) ∧
        x' ≤ (extendPoint nf : ExtendedCarrier N atomMap r) ∧
        u ≤ nf ∧ t ≤ nf := by
    intro f hf_cut hx'f
    obtain ⟨u, hfu, hu_cut, A, hA_depth, hA_interval, hA_fail⟩ :=
      h_cofinal_failure f hf_cut hx'f (cut_le_y' f hf_cut)
    obtain ⟨t, ht_cut, hx't, _, h_bound⟩ := h_no_cofinal A hA_depth hA_interval
    rcases le_total u t with hut | htu
    · exact ⟨u, A, t, t, hfu, hu_cut, hA_depth, hA_interval, hA_fail, h_bound,
        ht_cut, hx't, hut, le_refl t⟩
    · exact ⟨u, A, t, u, hfu, hu_cut, hA_depth, hA_interval, hA_fail, h_bound,
        hu_cut, le_trans hx'f ((extendPoint_le_iff _ _).mpr hfu),
        le_refl u, htu⟩
  -- Build chain by Nat.rec on a bundled floor state.
  -- State = { f // f ∈ Cut ∧ x' ≤ extendPoint f }
  -- At each step, one_step picks (u, A, t, next_floor) with properties.
  -- We define the chain as a single Nat-indexed function returning all data.
  -- Chain state type
  let S := { f : N.carrier // f ∈ inf_carrier_cut (continuation_set x' y' a_n) ∧
      x' ≤ (extendPoint f : ExtendedCarrier N atomMap r) }
  -- Chain output type (data at each step, bundled with properties)
  -- We define the chain function using Classical.indefiniteDescription
  -- to pick witnesses from the existential in one_step.
  -- step : S → (u × A × t × S) with all properties
  -- Actually, let's define sequences directly using Nat.rec
  -- and use Classical.choice at each step.
  -- Build the chain: at each Nat, produce (floor, u, A, t, next_floor)
  -- Using a stream of states
  -- chain : Nat → S defined by chain 0 = ⟨p₀, ...⟩, chain (n+1) = next_floor from one_step at chain n
  -- u_seq, A_seq : Nat → ... defined from one_step applied to chain n
  -- Since one_step is existential, we use Classical.choice to pick witnesses.
  -- Package everything into a single recursive structure.
  -- Define: chain_data n = (floor_n, u_n, A_n, t_n, next_floor_n) with all properties
  -- Then chain_data (n+1).floor = chain_data n.next_floor
  -- We use a recursive definition with Nat.rec on a Sigma type.
  -- Actually, the simplest way: define a stream of "states" and "outputs" simultaneously.
  -- state : Nat → S (the floor at each step)
  -- output : Nat → (u, A, t, props) (the data from one_step at each step)
  -- We define state by recursion and output as a function of state.
  -- Since one_step gives an existential, we use Classical.indefiniteDescription.
  -- First, wrap one_step into a choice function:
  have choose_witness (f : N.carrier)
      (hf : f ∈ inf_carrier_cut (continuation_set x' y' a_n))
      (hx'f : x' ≤ (extendPoint f : ExtendedCarrier N atomMap r)) :
      { w : N.carrier × StaviFormula × N.carrier × N.carrier //
        f ≤ w.1 ∧ w.1 ∈ inf_carrier_cut (continuation_set x' y' a_n) ∧
        stavi_depth w.2.1 ≤ r ∧
        (∀ v : ExtendedCarrier N atomMap r,
          a_n < v → v < y' → mu_holds v → stavi_temporal_truth_mu N atomMap r v w.2.1) ∧
        ¬ stavi_temporal_truth N atomMap w.1 w.2.1 ∧
        (∀ w', w.2.2.1 ≤ w' → w' ∈ inf_carrier_cut (continuation_set x' y' a_n) →
          stavi_temporal_truth N atomMap w' w.2.1) ∧
        w.2.2.2 ∈ inf_carrier_cut (continuation_set x' y' a_n) ∧
        x' ≤ (extendPoint w.2.2.2 : ExtendedCarrier N atomMap r) ∧
        w.1 ≤ w.2.2.2 ∧ w.2.2.1 ≤ w.2.2.2 } := by
    have h_ex := one_step f hf hx'f
    exact Classical.indefiniteDescription _ (by
      obtain ⟨u, A, t, nf, hp⟩ := h_ex
      exact ⟨(u, A, t, nf), hp⟩)
  -- Define state sequence (floors) by recursion
  let state : Nat → S := Nat.rec ⟨p₀, hp₀_cut, hx'_p₀⟩ fun n prev =>
    let w := choose_witness prev.1 prev.2.1 prev.2.2
    ⟨w.1.2.2.2, w.2.2.2.2.2.2.2.1, w.2.2.2.2.2.2.2.2.1⟩
  -- Define output at each step
  let output (n : Nat) := choose_witness (state n).1 (state n).2.1 (state n).2.2
  -- Extract individual sequences
  let u_seq (n : Nat) : N.carrier := (output n).1.1
  let A_seq (n : Nat) : StaviFormula := (output n).1.2.1
  let t_seq (n : Nat) : N.carrier := (output n).1.2.2.1
  -- Extract properties
  have props (n : Nat) :
      (state n).1 ≤ u_seq n ∧
      u_seq n ∈ inf_carrier_cut (continuation_set x' y' a_n) ∧
      stavi_depth (A_seq n) ≤ r ∧
      (∀ v : ExtendedCarrier N atomMap r,
        a_n < v → v < y' → mu_holds v →
        stavi_temporal_truth_mu N atomMap r v (A_seq n)) ∧
      ¬ stavi_temporal_truth N atomMap (u_seq n) (A_seq n) ∧
      (∀ w, t_seq n ≤ w → w ∈ inf_carrier_cut (continuation_set x' y' a_n) →
        stavi_temporal_truth N atomMap w (A_seq n)) ∧
      u_seq n ≤ (state (n + 1)).1 ∧
      t_seq n ≤ (state (n + 1)).1 := by
    have h := (output n).2
    exact ⟨h.1, h.2.1, h.2.2.1, h.2.2.2.1, h.2.2.2.2.1, h.2.2.2.2.2.1,
      h.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2⟩
  -- Monotonicity: u_seq is increasing
  have u_mono : ∀ n, u_seq n ≤ u_seq (n + 1) := fun n =>
    le_trans (props n).2.2.2.2.2.2.1 (props (n + 1)).1
  -- Transitivity: for i ≤ j, u_seq i ≤ u_seq j
  have u_mono_le : ∀ i j, i ≤ j → u_seq i ≤ u_seq j := by
    intro i j hij
    induction hij with
    | refl => exact le_refl _
    | step _ ih => exact le_trans ih (u_mono _)
  -- Key bound: for j > i, t_seq i ≤ u_seq j (so A_i holds at u_j)
  have bound_le : ∀ i j, i < j → t_seq i ≤ u_seq j := fun i j hij =>
    le_trans (props i).2.2.2.2.2.2.2 (le_trans (props (i + 1)).1 (u_mono_le (i + 1) j hij))
  -- A_i holds at u_j for j > i (via the bound property)
  have holds_later : ∀ i j, i < j →
      stavi_temporal_truth N atomMap (u_seq j) (A_seq i) := fun i j hij =>
    (props i).2.2.2.2.2.1 (u_seq j) (bound_le i j hij) (props j).2.1
  -- A_i fails at u_i
  have fails_at : ∀ i, ¬ stavi_temporal_truth N atomMap (u_seq i) (A_seq i) := fun i =>
    (props i).2.2.2.2.1
  -- NF map: Fin (K+1) → NormalForm (muSig sig) (2*r) 1
  let nf_map : Fin (K + 1) → NormalForm (muSig sig) (2 * r) 1 := fun i =>
    nf_characteristic (extendedStructureWithMu N atomMap r) (2 * r) 1
      (fun _ => extendPoint (u_seq i))
  -- Pigeonhole: K+1 > K → two indices have same NF
  have h_card : Fintype.card (NormalForm (muSig sig) (2 * r) 1) <
      Fintype.card (Fin (K + 1)) := by
    simp only [Fintype.card_fin]
    exact Nat.lt_succ_of_le (le_refl K)
  obtain ⟨i, j, hij, h_same_nf⟩ := Fintype.exists_ne_map_eq_of_card_lt nf_map h_card
  -- WLOG i < j (or j < i)
  rcases lt_or_gt_of_ne hij with h_ij | h_ij
  · -- i < j: A_i holds at u_j but fails at u_i
    exact (fails_at i) ((nf_determines_stavi_truth_depth h_same_nf
      (A_seq i) (props i).2.2.1).mpr (holds_later i j h_ij))
  · -- j < i: A_j holds at u_i but fails at u_j
    exact (fails_at j) ((nf_determines_stavi_truth_depth (Eq.symm h_same_nf)
      (A_seq j) (props j).2.2.1).mpr (holds_later j i h_ij))

/-- Cross-structure pigeonhole extraction: MIRROR of pigeonhole_definable_formula
    for the M-side continuation set S_C^M.

    The key difference from the N-side version:
    - Takes TWO structures M and N
    - The "continuation formula" hypothesis checks N:
      ∀ v : ExtendedCarrier N, a_n_N < v → v < y'_N → mu_holds v → truth_mu N v A
    - The failure conclusion checks M: ¬ stavi_temporal_truth M atomMap u A
    - The pigeonhole chain uses M-side NormalForms
    - nf_determines_stavi_truth_depth is structure-parametric (works for M)
    - inf_carrier_cut operates on continuation_set_cross

    Used in GHR93 Claim 1 Direction 2: extracting a single formula D_M of
    depth ≤ r that holds on (a_n, y') in N but fails cofinally below c_inf in M. -/
private theorem pigeonhole_definable_formula_cross {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {x y : ExtendedCarrier M atomMap r}
    {a_n_N y'_N : ExtendedCarrier N atomMap r}
    (hxy : x ≤ y)
    (h_cut_start : ∃ p₀ : M.carrier,
      p₀ ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) ∧
      x ≤ (extendPoint p₀ : ExtendedCarrier M atomMap r))
    (h_cofinal_failure :
      ∀ p : M.carrier, p ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) →
        x ≤ (extendPoint p : ExtendedCarrier M atomMap r) →
        (extendPoint p : ExtendedCarrier M atomMap r) ≤ y →
        ∃ (u : M.carrier),
          p ≤ u ∧
          u ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) ∧
          ∃ (A : StaviFormula),
            stavi_depth A ≤ r ∧
            (∀ v : ExtendedCarrier N atomMap r,
              a_n_N < v → v < y'_N → mu_holds v →
              stavi_temporal_truth_mu N atomMap r v A) ∧
            ¬ stavi_temporal_truth M atomMap u A) :
    ∃ (D : StaviFormula),
      stavi_depth D ≤ r ∧
      (∀ v : ExtendedCarrier N atomMap r,
        a_n_N < v → v < y'_N → mu_holds v →
        stavi_temporal_truth_mu N atomMap r v D) ∧
      (∀ t : M.carrier, t ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) →
        x ≤ (extendPoint t : ExtendedCarrier M atomMap r) →
        (extendPoint t : ExtendedCarrier M atomMap r) ≤ y →
        ∃ u : M.carrier, t ≤ u ∧
          u ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) ∧
          ¬ stavi_temporal_truth M atomMap u D) := by
  -- Cut points are below y (since y ∈ S_C_M and cut points are lower bounds of S_C_M)
  have cut_le_y : ∀ p, p ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) →
      (extendPoint p : ExtendedCarrier M atomMap r) ≤ y := by
    intro p hp
    obtain ⟨s₀, hs₀⟩ := continuation_set_cross_nonempty hxy (a_n_N := a_n_N) (y'_N := y'_N)
    exact le_trans (hp s₀ hs₀) hs₀.1.2
  -- By contradiction: suppose no single formula fails cofinally.
  by_contra h_no_cofinal
  push_neg at h_no_cofinal
  -- Pigeonhole over NormalForm types at depth 2*r (to handle stavi_fo_depth gap).
  -- nf_determines_stavi_truth_depth: same NF at depth 2*r → same truth for stavi_depth ≤ r.
  let K := Fintype.card (NormalForm (muSig sig) (2 * r) 1)
  obtain ⟨p₀, hp₀_cut, hx_p₀⟩ := h_cut_start
  -- One-step: from a cut point with x ≤ extendPoint, produce failure data + next floor
  have one_step : ∀ (f : M.carrier),
      f ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) →
      x ≤ (extendPoint f : ExtendedCarrier M atomMap r) →
      ∃ (u : M.carrier) (A : StaviFormula) (t nf : M.carrier),
        f ≤ u ∧ u ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) ∧
        stavi_depth A ≤ r ∧
        (∀ v : ExtendedCarrier N atomMap r,
          a_n_N < v → v < y'_N → mu_holds v → stavi_temporal_truth_mu N atomMap r v A) ∧
        ¬ stavi_temporal_truth M atomMap u A ∧
        (∀ w, t ≤ w → w ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) →
          stavi_temporal_truth M atomMap w A) ∧
        nf ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) ∧
        x ≤ (extendPoint nf : ExtendedCarrier M atomMap r) ∧
        u ≤ nf ∧ t ≤ nf := by
    intro f hf_cut hxf
    obtain ⟨u, hfu, hu_cut, A, hA_depth, hA_interval, hA_fail⟩ :=
      h_cofinal_failure f hf_cut hxf (cut_le_y f hf_cut)
    obtain ⟨t, ht_cut, hxt, _, h_bound⟩ := h_no_cofinal A hA_depth hA_interval
    rcases le_total u t with hut | htu
    · exact ⟨u, A, t, t, hfu, hu_cut, hA_depth, hA_interval, hA_fail, h_bound,
        ht_cut, hxt, hut, le_refl t⟩
    · exact ⟨u, A, t, u, hfu, hu_cut, hA_depth, hA_interval, hA_fail, h_bound,
        hu_cut, le_trans hxf ((extendPoint_le_iff _ _).mpr hfu),
        le_refl u, htu⟩
  -- Build chain by Nat.rec on a bundled floor state.
  let S := { f : M.carrier // f ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) ∧
      x ≤ (extendPoint f : ExtendedCarrier M atomMap r) }
  -- Wrap one_step into a choice function:
  have choose_witness (f : M.carrier)
      (hf : f ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N))
      (hxf : x ≤ (extendPoint f : ExtendedCarrier M atomMap r)) :
      { w : M.carrier × StaviFormula × M.carrier × M.carrier //
        f ≤ w.1 ∧ w.1 ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) ∧
        stavi_depth w.2.1 ≤ r ∧
        (∀ v : ExtendedCarrier N atomMap r,
          a_n_N < v → v < y'_N → mu_holds v → stavi_temporal_truth_mu N atomMap r v w.2.1) ∧
        ¬ stavi_temporal_truth M atomMap w.1 w.2.1 ∧
        (∀ w', w.2.2.1 ≤ w' → w' ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) →
          stavi_temporal_truth M atomMap w' w.2.1) ∧
        w.2.2.2 ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) ∧
        x ≤ (extendPoint w.2.2.2 : ExtendedCarrier M atomMap r) ∧
        w.1 ≤ w.2.2.2 ∧ w.2.2.1 ≤ w.2.2.2 } := by
    have h_ex := one_step f hf hxf
    exact Classical.indefiniteDescription _ (by
      obtain ⟨u, A, t, nf, hp⟩ := h_ex
      exact ⟨(u, A, t, nf), hp⟩)
  -- Define state sequence (floors) by recursion
  let state : Nat → S := Nat.rec ⟨p₀, hp₀_cut, hx_p₀⟩ fun n prev =>
    let w := choose_witness prev.1 prev.2.1 prev.2.2
    ⟨w.1.2.2.2, w.2.2.2.2.2.2.2.1, w.2.2.2.2.2.2.2.2.1⟩
  -- Define output at each step
  let output (n : Nat) := choose_witness (state n).1 (state n).2.1 (state n).2.2
  -- Extract individual sequences
  let u_seq (n : Nat) : M.carrier := (output n).1.1
  let A_seq (n : Nat) : StaviFormula := (output n).1.2.1
  let t_seq (n : Nat) : M.carrier := (output n).1.2.2.1
  -- Extract properties
  have props (n : Nat) :
      (state n).1 ≤ u_seq n ∧
      u_seq n ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) ∧
      stavi_depth (A_seq n) ≤ r ∧
      (∀ v : ExtendedCarrier N atomMap r,
        a_n_N < v → v < y'_N → mu_holds v →
        stavi_temporal_truth_mu N atomMap r v (A_seq n)) ∧
      ¬ stavi_temporal_truth M atomMap (u_seq n) (A_seq n) ∧
      (∀ w, t_seq n ≤ w → w ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) →
        stavi_temporal_truth M atomMap w (A_seq n)) ∧
      u_seq n ≤ (state (n + 1)).1 ∧
      t_seq n ≤ (state (n + 1)).1 := by
    have h := (output n).2
    exact ⟨h.1, h.2.1, h.2.2.1, h.2.2.2.1, h.2.2.2.2.1, h.2.2.2.2.2.1,
      h.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2⟩
  -- Monotonicity: u_seq is increasing
  have u_mono : ∀ n, u_seq n ≤ u_seq (n + 1) := fun n =>
    le_trans (props n).2.2.2.2.2.2.1 (props (n + 1)).1
  -- Transitivity: for i ≤ j, u_seq i ≤ u_seq j
  have u_mono_le : ∀ i j, i ≤ j → u_seq i ≤ u_seq j := by
    intro i j hij
    induction hij with
    | refl => exact le_refl _
    | step _ ih => exact le_trans ih (u_mono _)
  -- Key bound: for j > i, t_seq i ≤ u_seq j (so A_i holds at u_j)
  have bound_le : ∀ i j, i < j → t_seq i ≤ u_seq j := fun i j hij =>
    le_trans (props i).2.2.2.2.2.2.2 (le_trans (props (i + 1)).1 (u_mono_le (i + 1) j hij))
  -- A_i holds at u_j for j > i (via the bound property)
  have holds_later : ∀ i j, i < j →
      stavi_temporal_truth M atomMap (u_seq j) (A_seq i) := fun i j hij =>
    (props i).2.2.2.2.2.1 (u_seq j) (bound_le i j hij) (props j).2.1
  -- A_i fails at u_i
  have fails_at : ∀ i, ¬ stavi_temporal_truth M atomMap (u_seq i) (A_seq i) := fun i =>
    (props i).2.2.2.2.1
  -- NF map: Fin (K+1) → NormalForm (muSig sig) (2*r) 1
  -- Key: NF evaluation uses M (since u_seq are M.carrier points)
  let nf_map : Fin (K + 1) → NormalForm (muSig sig) (2 * r) 1 := fun i =>
    nf_characteristic (extendedStructureWithMu M atomMap r) (2 * r) 1
      (fun _ => extendPoint (u_seq i))
  -- Pigeonhole: K+1 > K → two indices have same NF
  have h_card : Fintype.card (NormalForm (muSig sig) (2 * r) 1) <
      Fintype.card (Fin (K + 1)) := by
    simp only [Fintype.card_fin]
    exact Nat.lt_succ_of_le (le_refl K)
  obtain ⟨i, j, hij, h_same_nf⟩ := Fintype.exists_ne_map_eq_of_card_lt nf_map h_card
  -- WLOG i < j (or j < i)
  rcases lt_or_gt_of_ne hij with h_ij | h_ij
  · -- i < j: A_i holds at u_j but fails at u_i
    -- nf_determines_stavi_truth_depth applied to M gives truth equivalence at M carrier points
    exact (fails_at i) ((nf_determines_stavi_truth_depth h_same_nf
      (A_seq i) (props i).2.2.1).mpr (holds_later i j h_ij))
  · -- j < i: A_j holds at u_i but fails at u_j
    exact (fails_at j) ((nf_determines_stavi_truth_depth (Eq.symm h_same_nf)
      (A_seq j) (props j).2.2.1).mpr (holds_later j i h_ij))

/-- Strict variant of `pigeonhole_definable_formula_cross`:
    The cofinal failure hypothesis and conclusion are restricted to cut points
    STRICTLY below an upper bound. This is needed when the infimum c_inf of
    S_C_M is a carrier-point minimum: cont_holds_cross may hold at c_inf itself,
    but failures are cofinal strictly below c_inf.

    The proof is identical to `pigeonhole_definable_formula_cross` — the chain
    stays strictly below `upper` throughout, and the pigeonhole argument
    (NormalForm finiteness + nf_determines_stavi_truth_depth) is unchanged. -/
private theorem pigeonhole_definable_formula_cross_strict {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {x y : ExtendedCarrier M atomMap r}
    {a_n_N y'_N : ExtendedCarrier N atomMap r}
    {upper : ExtendedCarrier M atomMap r}
    (hxy : x ≤ y)
    (h_cut_start : ∃ p₀ : M.carrier,
      p₀ ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) ∧
      x ≤ (extendPoint p₀ : ExtendedCarrier M atomMap r) ∧
      (extendPoint p₀ : ExtendedCarrier M atomMap r) < upper)
    (h_cofinal_failure :
      ∀ p : M.carrier, p ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) →
        x ≤ (extendPoint p : ExtendedCarrier M atomMap r) →
        (extendPoint p : ExtendedCarrier M atomMap r) < upper →
        ∃ (u : M.carrier),
          p ≤ u ∧
          u ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) ∧
          (extendPoint u : ExtendedCarrier M atomMap r) < upper ∧
          ∃ (A : StaviFormula),
            stavi_depth A ≤ r ∧
            (∀ v : ExtendedCarrier N atomMap r,
              a_n_N < v → v < y'_N → mu_holds v →
              stavi_temporal_truth_mu N atomMap r v A) ∧
            ¬ stavi_temporal_truth M atomMap u A) :
    ∃ (D : StaviFormula),
      stavi_depth D ≤ r ∧
      (∀ v : ExtendedCarrier N atomMap r,
        a_n_N < v → v < y'_N → mu_holds v →
        stavi_temporal_truth_mu N atomMap r v D) ∧
      (∀ t : M.carrier, t ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) →
        x ≤ (extendPoint t : ExtendedCarrier M atomMap r) →
        (extendPoint t : ExtendedCarrier M atomMap r) < upper →
        ∃ u : M.carrier, t ≤ u ∧
          u ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) ∧
          (extendPoint u : ExtendedCarrier M atomMap r) < upper ∧
          ¬ stavi_temporal_truth M atomMap u D) := by
  -- By contradiction: suppose no single formula fails cofinally below upper.
  by_contra h_no_cofinal
  push_neg at h_no_cofinal
  -- Pigeonhole over NormalForm types at depth 2*r.
  let K := Fintype.card (NormalForm (muSig sig) (2 * r) 1)
  obtain ⟨p₀, hp₀_cut, hx_p₀, hp₀_lt_upper⟩ := h_cut_start
  -- One-step: from a cut point with x ≤ extendPoint and extendPoint < upper,
  -- produce failure data + next floor (also < upper).
  have one_step : ∀ (f : M.carrier),
      f ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) →
      x ≤ (extendPoint f : ExtendedCarrier M atomMap r) →
      (extendPoint f : ExtendedCarrier M atomMap r) < upper →
      ∃ (u : M.carrier) (A : StaviFormula) (t nf : M.carrier),
        f ≤ u ∧ u ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) ∧
        (extendPoint u : ExtendedCarrier M atomMap r) < upper ∧
        stavi_depth A ≤ r ∧
        (∀ v : ExtendedCarrier N atomMap r,
          a_n_N < v → v < y'_N → mu_holds v → stavi_temporal_truth_mu N atomMap r v A) ∧
        ¬ stavi_temporal_truth M atomMap u A ∧
        (∀ w, t ≤ w → w ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) →
          (extendPoint w : ExtendedCarrier M atomMap r) < upper →
          stavi_temporal_truth M atomMap w A) ∧
        nf ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) ∧
        x ≤ (extendPoint nf : ExtendedCarrier M atomMap r) ∧
        (extendPoint nf : ExtendedCarrier M atomMap r) < upper ∧
        u ≤ nf ∧ t ≤ nf := by
    intro f hf_cut hxf hf_lt
    obtain ⟨u, hfu, hu_cut, hu_lt, A, hA_depth, hA_interval, hA_fail⟩ :=
      h_cofinal_failure f hf_cut hxf hf_lt
    obtain ⟨t, ht_cut, hxt, ht_lt, h_bound⟩ := h_no_cofinal A hA_depth hA_interval
    rcases le_total u t with hut | htu
    · exact ⟨u, A, t, t, hfu, hu_cut, hu_lt, hA_depth, hA_interval, hA_fail, h_bound,
        ht_cut, hxt, ht_lt, hut, le_refl t⟩
    · exact ⟨u, A, t, u, hfu, hu_cut, hu_lt, hA_depth, hA_interval, hA_fail, h_bound,
        hu_cut, le_trans hxf ((extendPoint_le_iff _ _).mpr hfu), hu_lt,
        le_refl u, htu⟩
  -- Build chain by Nat.rec on a bundled floor state.
  let S := { f : M.carrier // f ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) ∧
      x ≤ (extendPoint f : ExtendedCarrier M atomMap r) ∧
      (extendPoint f : ExtendedCarrier M atomMap r) < upper }
  -- Wrap one_step into a choice function:
  have choose_witness (f : M.carrier)
      (hf : f ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N))
      (hxf : x ≤ (extendPoint f : ExtendedCarrier M atomMap r))
      (hf_lt : (extendPoint f : ExtendedCarrier M atomMap r) < upper) :
      { w : M.carrier × StaviFormula × M.carrier × M.carrier //
        f ≤ w.1 ∧ w.1 ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) ∧
        (extendPoint w.1 : ExtendedCarrier M atomMap r) < upper ∧
        stavi_depth w.2.1 ≤ r ∧
        (∀ v : ExtendedCarrier N atomMap r,
          a_n_N < v → v < y'_N → mu_holds v → stavi_temporal_truth_mu N atomMap r v w.2.1) ∧
        ¬ stavi_temporal_truth M atomMap w.1 w.2.1 ∧
        (∀ w', w.2.2.1 ≤ w' → w' ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) →
          (extendPoint w' : ExtendedCarrier M atomMap r) < upper →
          stavi_temporal_truth M atomMap w' w.2.1) ∧
        w.2.2.2 ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) ∧
        x ≤ (extendPoint w.2.2.2 : ExtendedCarrier M atomMap r) ∧
        (extendPoint w.2.2.2 : ExtendedCarrier M atomMap r) < upper ∧
        w.1 ≤ w.2.2.2 ∧ w.2.2.1 ≤ w.2.2.2 } := by
    have h_ex := one_step f hf hxf hf_lt
    exact Classical.indefiniteDescription _ (by
      obtain ⟨u, A, t, nf, hp⟩ := h_ex
      exact ⟨(u, A, t, nf), hp⟩)
  -- Define state sequence (floors) by recursion
  let state : Nat → S := Nat.rec ⟨p₀, hp₀_cut, hx_p₀, hp₀_lt_upper⟩ fun n prev =>
    let w := choose_witness prev.1 prev.2.1 prev.2.2.1 prev.2.2.2
    ⟨w.1.2.2.2, w.2.2.2.2.2.2.2.2.1, w.2.2.2.2.2.2.2.2.2.1, w.2.2.2.2.2.2.2.2.2.2.1⟩
  -- Define output at each step
  let output (n : Nat) := choose_witness (state n).1 (state n).2.1 (state n).2.2.1 (state n).2.2.2
  -- Extract individual sequences
  let u_seq (n : Nat) : M.carrier := (output n).1.1
  let A_seq (n : Nat) : StaviFormula := (output n).1.2.1
  let t_seq (n : Nat) : M.carrier := (output n).1.2.2.1
  -- Extract properties
  have props (n : Nat) :
      (state n).1 ≤ u_seq n ∧
      u_seq n ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) ∧
      (extendPoint (u_seq n) : ExtendedCarrier M atomMap r) < upper ∧
      stavi_depth (A_seq n) ≤ r ∧
      (∀ v : ExtendedCarrier N atomMap r,
        a_n_N < v → v < y'_N → mu_holds v →
        stavi_temporal_truth_mu N atomMap r v (A_seq n)) ∧
      ¬ stavi_temporal_truth M atomMap (u_seq n) (A_seq n) ∧
      (∀ w, t_seq n ≤ w → w ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) →
        (extendPoint w : ExtendedCarrier M atomMap r) < upper →
        stavi_temporal_truth M atomMap w (A_seq n)) ∧
      u_seq n ≤ (state (n + 1)).1 ∧
      t_seq n ≤ (state (n + 1)).1 := by
    have h := (output n).2
    exact ⟨h.1, h.2.1, h.2.2.1, h.2.2.2.1, h.2.2.2.2.1, h.2.2.2.2.2.1, h.2.2.2.2.2.2.1,
      h.2.2.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.2.2⟩
  -- Monotonicity: u_seq is increasing
  have u_mono : ∀ n, u_seq n ≤ u_seq (n + 1) := fun n =>
    le_trans (props n).2.2.2.2.2.2.2.1 (props (n + 1)).1
  -- Transitivity: for i ≤ j, u_seq i ≤ u_seq j
  have u_mono_le : ∀ i j, i ≤ j → u_seq i ≤ u_seq j := by
    intro i j hij
    induction hij with
    | refl => exact le_refl _
    | step _ ih => exact le_trans ih (u_mono _)
  -- Key bound: for j > i, t_seq i ≤ u_seq j (so A_i holds at u_j)
  have bound_le : ∀ i j, i < j → t_seq i ≤ u_seq j := fun i j hij =>
    le_trans (props i).2.2.2.2.2.2.2.2 (le_trans (props (i + 1)).1 (u_mono_le (i + 1) j hij))
  -- A_i holds at u_j for j > i (via the bound property)
  have holds_later : ∀ i j, i < j →
      stavi_temporal_truth M atomMap (u_seq j) (A_seq i) := fun i j hij =>
    (props i).2.2.2.2.2.2.1 (u_seq j) (bound_le i j hij) (props j).2.1 (props j).2.2.1
  -- A_i fails at u_i
  have fails_at : ∀ i, ¬ stavi_temporal_truth M atomMap (u_seq i) (A_seq i) := fun i =>
    (props i).2.2.2.2.2.1
  -- NF map: Fin (K+1) → NormalForm (muSig sig) (2*r) 1
  let nf_map : Fin (K + 1) → NormalForm (muSig sig) (2 * r) 1 := fun i =>
    nf_characteristic (extendedStructureWithMu M atomMap r) (2 * r) 1
      (fun _ => extendPoint (u_seq i))
  -- Pigeonhole: K+1 > K → two indices have same NF
  have h_card : Fintype.card (NormalForm (muSig sig) (2 * r) 1) <
      Fintype.card (Fin (K + 1)) := by
    simp only [Fintype.card_fin]
    exact Nat.lt_succ_of_le (le_refl K)
  obtain ⟨i, j, hij, h_same_nf⟩ := Fintype.exists_ne_map_eq_of_card_lt nf_map h_card
  -- WLOG i < j (or j < i)
  rcases lt_or_gt_of_ne hij with h_ij | h_ij
  · exact (fails_at i) ((nf_determines_stavi_truth_depth h_same_nf
      (A_seq i) (props i).2.2.2.1).mpr (holds_later i j h_ij))
  · exact (fails_at j) ((nf_determines_stavi_truth_depth (Eq.symm h_same_nf)
      (A_seq j) (props j).2.2.2.1).mpr (holds_later j i h_ij))

/-- Bridge lemma: from cont_fails_below_gap (which gives an extended carrier
    mu-point where cont_holds fails) to a carrier-level formula failure
    at a carrier point in the cut.

    Given p in the cut with x' ≤ p ≤ y', cont_fails_below_gap gives
    u : ExtendedCarrier with extendPoint p < u, u ≤ y', mu_holds u,
    ¬cont_holds at u. Since mu_holds u, u = extendPoint u' for some
    u' : N.carrier. Unwinding ¬cont_holds gives A with depth ≤ r,
    A holds on (a_n, y'), ¬A^mu at u = extendPoint u'.
    Via stavi_truth_mu_at_point: ¬stavi_temporal_truth N atomMap u' A.
    Also u' is in the cut: since extendPoint u' = u ≤ y' and
    extendPoint u' > extendPoint p which is a lower bound of S_C,
    we need u' to be a lower bound of S_C too. Actually u' is above p
    but still below the infimum of S_C (since u ≤ y' and u is between
    p and the gap). Wait — u could be ABOVE the gap (between the gap
    and y'). In that case u' would NOT be in the cut.

    In fact, cont_fails_below_gap gives u in (extendPoint p, y'] where
    cont_holds fails. This u could be above the infimum. But if u is
    above the infimum and is a mu-point, then u is in S_C (by
    upward-closedness), so cont_holds holds at u — contradiction.

    Therefore u must be below the infimum, i.e., u' is in the cut. -/
private theorem formula_failure_in_cut {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {x' y' a_n : ExtendedCarrier N atomMap r}
    {p : N.carrier}
    (h_in_cut : p ∈ inf_carrier_cut (continuation_set x' y' a_n))
    (hx'y' : x' ≤ y')
    (hx'_le_p : x' ≤ (extendPoint p : ExtendedCarrier N atomMap r))
    (hp_le_y' : (extendPoint p : ExtendedCarrier N atomMap r) ≤ y')
    (h_not_point_glb : ¬ ∃ p' : N.carrier,
      (∀ s ∈ continuation_set x' y' a_n,
        (extendPoint p' : ExtendedCarrier N atomMap r) ≤ s) ∧
      (∀ q : N.carrier,
        (∀ s ∈ continuation_set x' y' a_n,
          (extendPoint q : ExtendedCarrier N atomMap r) ≤ s) →
        (extendPoint q : ExtendedCarrier N atomMap r) ≤ extendPoint p')) :
    ∃ (u : N.carrier),
      p ≤ u ∧
      u ∈ inf_carrier_cut (continuation_set x' y' a_n) ∧
      ∃ (A : StaviFormula),
        stavi_depth A ≤ r ∧
        (∀ v : ExtendedCarrier N atomMap r,
          a_n < v → v < y' → mu_holds v →
          stavi_temporal_truth_mu N atomMap r v A) ∧
        ¬ stavi_temporal_truth N atomMap u A := by
  -- Step 1: Get extended-carrier witness from cont_fails_below_gap
  obtain ⟨u, hpu, huy', hmu, hcont_fail⟩ :=
    cont_fails_below_gap h_in_cut hx'y' hx'_le_p hp_le_y' h_not_point_glb
  -- Step 2: Since mu_holds u, u is a carrier point: u = extendPoint u'
  obtain ⟨u', hu'⟩ := hmu
  -- Save mu_holds u for later use
  have hmu_u : mu_holds u := ⟨u', hu'⟩
  -- Step 3: Unwind ¬cont_holds at u to get a specific formula failure
  -- Save ¬cont_holds before destructuring
  have hcont_fail_orig : ¬ cont_holds a_n y' u := hcont_fail
  simp only [cont_holds] at hcont_fail
  push_neg at hcont_fail
  obtain ⟨A, hA_depth, hA_interval, hA_fail⟩ := hcont_fail
  -- Step 4: Bridge stavi_temporal_truth_mu to stavi_temporal_truth at carrier point
  rw [hu'] at hA_fail
  have hA_fail_carrier : ¬ stavi_temporal_truth N atomMap u' A := by
    intro h_holds
    exact hA_fail ((stavi_truth_mu_at_point u' A).mpr h_holds)
  -- Step 5: Show u' is in the cut
  -- u' is a carrier point with extendPoint u' = u, and u is between
  -- extendPoint p and y'. We need to show u' ∈ inf_carrier_cut S_C,
  -- i.e., extendPoint u' is a lower bound of S_C.
  -- If ∃ s ∈ S_C with s < extendPoint u' = u, then hs.2 gives
  -- cont_holds at u (since s < u < y' and mu_holds u).
  -- This contradicts hcont_fail_orig.
  have hu'_in_cut : u' ∈ inf_carrier_cut (continuation_set x' y' a_n) := by
    intro s hs
    by_contra h_not_le
    push_neg at h_not_le
    -- h_not_le : s < extendPoint u'
    have h_s_lt_u : s < u := hu' ▸ h_not_le
    have h_cont_at_u := hs.2 u h_s_lt_u huy' hmu_u
    exact hcont_fail_orig (hu' ▸ h_cont_at_u)
  -- Step 6: Show p ≤ u'
  have hpu' : p ≤ u' := by
    rw [← extendPoint_le_iff p u']
    exact le_of_lt (hu' ▸ hpu)
  exact ⟨u', hpu', hu'_in_cut, A, hA_depth, hA_interval, hA_fail_carrier⟩

/-- The infimum gap is r-definable: there exists a StaviFormula D of
    depth ≤ r satisfying gap_definable_on_right for the infimum gap.

    The argument follows GHR93 p.116: "c is a gap definable on the right by C."

    Key steps:
    1. Extract D via pigeonhole: a single formula of depth ≤ r that holds
       on (a_n, y') but fails cofinally below the gap.
    2. First conjunct of gap_definable_on_right: D holds at all carrier
       points above the gap (via cont_holds_above_gap).
    3. Second conjunct: D does NOT hold on any final segment of the cut
       (since D fails cofinally in the cut).

    All steps are sorry-free, including the pigeonhole extraction which uses
    NormalForm finiteness at depth 2*r via nf_determines_stavi_truth_depth. -/
private theorem infimum_gap_r_definable {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {x' y' a_n : ExtendedCarrier N atomMap r}
    (hx'y' : x' ≤ y')
    (ha_n : inClosedInterval x' y' a_n)
    (h_ne : (continuation_set x' y' a_n).Nonempty)
    (h_pt_below : ∃ p : N.carrier, ∀ s ∈ continuation_set x' y' a_n,
      (extendPoint p : ExtendedCarrier N atomMap r) ≤ s)
    (h_above : ∃ (q : N.carrier) (s : ↥(continuation_set x' y' a_n)),
      (extendPoint q : ExtendedCarrier N atomMap r) > s.val)
    (h_not_point_glb : ¬ ∃ p : N.carrier,
      (∀ s ∈ continuation_set x' y' a_n,
        (extendPoint p : ExtendedCarrier N atomMap r) ≤ s) ∧
      (∀ q : N.carrier,
        (∀ s ∈ continuation_set x' y' a_n,
          (extendPoint q : ExtendedCarrier N atomMap r) ≤ s) →
        (extendPoint q : ExtendedCarrier N atomMap r) ≤ extendPoint p))
    -- Bound hypothesis: there exists a carrier point in the cut above x'
    (hx'_bound : ∃ p₀ : N.carrier,
      p₀ ∈ inf_carrier_cut (continuation_set x' y' a_n) ∧
      x' ≤ (extendPoint p₀ : ExtendedCarrier N atomMap r))
    -- Witness above gap: there exists a carrier point above the gap and strictly
    -- below y'. This holds in the typical case where a_n < y' (since a_n ∈ S_C
    -- and a_n < y' means the infimum is ≤ a_n < y', giving carrier points between).
    (h_above_gap_below_y' : ∃ q₀ : N.carrier,
      q₀ ∉ inf_carrier_cut (continuation_set x' y' a_n) ∧
      (extendPoint q₀ : ExtendedCarrier N atomMap r) < y' ∧
      x' ≤ (extendPoint q₀ : ExtendedCarrier N atomMap r)) :
    r_definable_gap N atomMap
      (infimum_gap h_ne h_pt_below h_above h_not_point_glb) r := by
  -- The gap gamma has gamma.cut = inf_carrier_cut (continuation_set x' y' a_n).
  -- We abbreviate S_C = continuation_set x' y' a_n and
  -- gamma = infimum_gap h_ne h_pt_below h_above h_not_point_glb.
  set gamma := infimum_gap h_ne h_pt_below h_above h_not_point_glb with gamma_def
  -- Step 1: Establish cofinal formula failure below the gap.
  -- For every p in gamma.cut with x' ≤ p ≤ y', formula_failure_in_cut gives
  -- u ≥ p in gamma.cut and A with depth ≤ r, A holds on (a_n, y'), ¬A at u.
  have h_cofinal : ∀ p : N.carrier,
      p ∈ gamma.cut →
      x' ≤ (extendPoint p : ExtendedCarrier N atomMap r) →
      (extendPoint p : ExtendedCarrier N atomMap r) ≤ y' →
      ∃ (u : N.carrier), p ≤ u ∧ u ∈ gamma.cut ∧
        ∃ (A : StaviFormula), stavi_depth A ≤ r ∧
          (∀ v : ExtendedCarrier N atomMap r,
            a_n < v → v < y' → mu_holds v →
            stavi_temporal_truth_mu N atomMap r v A) ∧
          ¬ stavi_temporal_truth N atomMap u A := by
    intro p hp hx'p hpy'
    -- gamma.cut = inf_carrier_cut S_C, so hp : p ∈ inf_carrier_cut S_C
    exact formula_failure_in_cut hp hx'y' hx'p hpy' h_not_point_glb
  -- Step 2: Apply pigeonhole to extract a single formula D.
  have h_cofinal' : ∀ p : N.carrier,
      p ∈ inf_carrier_cut (continuation_set x' y' a_n) →
      x' ≤ (extendPoint p : ExtendedCarrier N atomMap r) →
      (extendPoint p : ExtendedCarrier N atomMap r) ≤ y' →
      ∃ (u : N.carrier), p ≤ u ∧
        u ∈ inf_carrier_cut (continuation_set x' y' a_n) ∧
        ∃ (A : StaviFormula), stavi_depth A ≤ r ∧
          (∀ v : ExtendedCarrier N atomMap r,
            a_n < v → v < y' → mu_holds v →
            stavi_temporal_truth_mu N atomMap r v A) ∧
          ¬ stavi_temporal_truth N atomMap u A := h_cofinal
  obtain ⟨D, hD_depth, hD_interval, hD_cofinal⟩ :=
    pigeonhole_definable_formula hx'y' hx'_bound h_cofinal'
  -- Step 3: Show D satisfies gap_definable_on_right.
  -- r_definable_gap = ∃ D, depth D ≤ r ∧ (left ∨ right)
  refine ⟨D, hD_depth, Or.inr ?_⟩
  -- gap_definable_on_right gamma D =
  --   (∃ t ∉ cut, ∀ u ∉ cut, u ≤ t → truth u D) ∧
  --   ¬(∃ t ∈ cut, ∀ u ≥ t, u ∈ cut → truth u D)
  constructor
  · -- First conjunct: D holds at all carrier points above the gap and ≤ t.
    -- Use q₀ from h_above_gap_below_y' as witness t.
    -- q₀ ∉ gamma.cut and extendPoint q₀ < y' and x' ≤ extendPoint q₀.
    -- For any u ∉ gamma.cut with u ≤ q₀:
    --   extendPoint u ≤ extendPoint q₀ < y', so extendPoint u < y'
    --   u ∉ gamma.cut means ∃ s ∈ S_C with s < extendPoint u, so x' ≤ s < extendPoint u
    --   Therefore cont_holds_above_gap applies (with strict inequality avoiding y' edge case)
    obtain ⟨q₀, hq₀_not_cut, hq₀_lt_y', hx'_le_q₀⟩ := h_above_gap_below_y'
    refine ⟨q₀, hq₀_not_cut, ?_⟩
    intro u hu_not_cut hu_le_q₀
    -- gamma.cut = inf_carrier_cut S_C (by infimum_gap definition)
    -- Convert u ∉ gamma.cut to u ∉ inf_carrier_cut S_C
    have hu_not_cut' : u ∉ inf_carrier_cut (continuation_set x' y' a_n) := hu_not_cut
    -- u ∉ inf_carrier_cut S_C means ∃ s ∈ S_C with s < extendPoint u
    -- Therefore x' ≤ s < extendPoint u, giving x' ≤ extendPoint u
    have hx'_le_u : x' ≤ (extendPoint u : ExtendedCarrier N atomMap r) := by
      simp only [inf_carrier_cut, Set.mem_setOf_eq] at hu_not_cut'
      push_neg at hu_not_cut'
      obtain ⟨s, hs_in, hs_lt⟩ := hu_not_cut'
      exact le_trans hs_in.1.1 (le_of_lt hs_lt)
    -- extendPoint u ≤ extendPoint q₀ < y'
    have hu_lt_y' : (extendPoint u : ExtendedCarrier N atomMap r) < y' :=
      lt_of_le_of_lt (extendPoint_le_iff u q₀ |>.mpr hu_le_q₀) hq₀_lt_y'
    -- Apply cont_holds_above_gap with strict inequality (no y' edge case).
    exact cont_holds_above_gap hu_not_cut' hx'y' hu_lt_y' hx'_le_u D hD_depth hD_interval
  · -- Second conjunct: ¬(∃ t ∈ cut, ∀ u ≥ t, u ∈ cut → truth u D).
    -- This follows from D failing cofinally in the cut.
    intro ⟨t, ht_in_cut, ht_final⟩
    -- D holds on the final segment [t, ∞) ∩ cut.
    -- But hD_cofinal says: for every t' ∈ cut with x' ≤ t' ≤ y',
    -- ∃ u ≥ t' in cut with ¬truth u D.
    -- We need t to have x' ≤ t and t ≤ y' (it's in the cut so t ≤ y').
    -- For x' ≤ t: use hx'_bound to get p₀ ∈ cut with x' ≤ p₀.
    -- Since cut is downward-closed and p₀ ∈ cut, if t ≥ p₀ then x' ≤ p₀ ≤ t.
    -- If t < p₀, then take p₀ as the starting point.
    obtain ⟨p₀, hp₀_in, hx'_le_p₀⟩ := hx'_bound
    -- t ∈ cut, so extendPoint t ≤ all s ∈ S_C, hence extendPoint t ≤ y'
    have ht_le_y' : (extendPoint t : ExtendedCarrier N atomMap r) ≤ y' := by
      have h_sc_ne := continuation_set_nonempty hx'y' (a_n := a_n)
      obtain ⟨s₀, hs₀⟩ := h_sc_ne
      exact le_trans (ht_in_cut s₀ hs₀) hs₀.1.2
    -- Find the right starting point for cofinal failure
    -- Use max(t, p₀) which is in the cut and has x' ≤ max(t, p₀) ≤ y'
    rcases le_total t p₀ with htp₀ | hp₀t
    · -- t ≤ p₀: use p₀ as starting point
      have hp₀_le_y' : (extendPoint p₀ : ExtendedCarrier N atomMap r) ≤ y' := by
        have h_sc_ne := continuation_set_nonempty hx'y' (a_n := a_n)
        obtain ⟨s₀, hs₀⟩ := h_sc_ne
        exact le_trans (hp₀_in s₀ hs₀) hs₀.1.2
      obtain ⟨u, hp₀u, hu_in_cut, hu_fail⟩ :=
        hD_cofinal p₀ hp₀_in hx'_le_p₀ hp₀_le_y'
      -- u ≥ p₀ ≥ t and u ∈ cut, so ht_final gives D holds at u
      have h_holds := ht_final u (le_trans htp₀ hp₀u) hu_in_cut
      exact hu_fail h_holds
    · -- p₀ ≤ t: use t as starting point (x' ≤ p₀ ≤ t)
      have hx'_le_t : x' ≤ (extendPoint t : ExtendedCarrier N atomMap r) :=
        le_trans hx'_le_p₀ ((extendPoint_le_iff p₀ t).mpr hp₀t)
      obtain ⟨u, htu, hu_in_cut, hu_fail⟩ :=
        hD_cofinal t ht_in_cut hx'_le_t ht_le_y'
      have h_holds := ht_final u htu hu_in_cut
      exact hu_fail h_holds

/-! ### Cross-Structure Gap R-Definability (M-side)

The M-side gap (infimum of S_C^M) is r-definable using M-side formula
evaluation. The argument mirrors `infimum_gap_r_definable` but with:
- `continuation_set_cross` instead of `continuation_set`
- `cont_holds_cross` instead of `cont_holds`
- `pigeonhole_definable_formula_cross` for extracting the single formula D

Key conceptual point: the continuation formula A holds on (a_n_N, y'_N) in N
but is evaluated for truth in M. The gap_definable_on_right uses M-side truth. -/

/-- Cross-version of cont_holds_above_gap: if p is a carrier point in M
    NOT in the cut of inf(S_C^M), then p is above some element of S_C^M,
    hence in S_C^M by upward-closedness, and cont_holds_cross holds at p.
    So for any formula A of depth ≤ r that holds on (a_n_N, y'_N) in N,
    A also holds at extendPoint p in M. -/
private theorem cont_holds_above_gap_cross {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {x y : ExtendedCarrier M atomMap r}
    {a_n_N y'_N : ExtendedCarrier N atomMap r}
    {p : M.carrier}
    (h_not_in_cut : p ∉ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N))
    (hxy : x ≤ y)
    (hp_lt_y : (extendPoint p : ExtendedCarrier M atomMap r) < y)
    (hx_le_p : x ≤ (extendPoint p : ExtendedCarrier M atomMap r))
    (A : StaviFormula) (hA : stavi_depth A ≤ r)
    (hA_interval : ∀ v : ExtendedCarrier N atomMap r,
      a_n_N < v → v < y'_N → mu_holds v →
      stavi_temporal_truth_mu N atomMap r v A) :
    stavi_temporal_truth M atomMap p A := by
  -- p ∉ inf_carrier_cut S_C_M means ∃ s ∈ S_C_M, ¬(extendPoint p ≤ s)
  simp only [inf_carrier_cut, Set.mem_setOf_eq] at h_not_in_cut
  push_neg at h_not_in_cut
  obtain ⟨s, hs_in, hs_lt⟩ := h_not_in_cut
  -- extendPoint p ∈ S_C_M by upward-closedness
  have hp_in_sc : (extendPoint p : ExtendedCarrier M atomMap r) ∈
      continuation_set_cross x y a_n_N y'_N :=
    continuation_set_cross_upward_closed hs_in (le_of_lt hs_lt) (le_of_lt hp_lt_y) hx_le_p
  -- s < extendPoint p < y and extendPoint p is mu. Apply hs_in.2.
  have h_mu : mu_holds (extendPoint p : ExtendedCarrier M atomMap r) :=
    mu_holds_point p
  have h_cont := hs_in.2 (extendPoint p) hs_lt hp_lt_y h_mu
  -- h_cont : cont_holds_cross a_n_N y'_N (extendPoint p)
  have h_mu_truth := h_cont A hA hA_interval
  exact (stavi_truth_mu_at_point p A).mp h_mu_truth

/-- Cross-version of cont_fails_below_gap: if p is in the cut of
    inf(S_C^M), then there exists a mu-point u strictly above extendPoint p
    and below y where cont_holds_cross fails. -/
private theorem cont_fails_below_gap_cross {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {x y : ExtendedCarrier M atomMap r}
    {a_n_N y'_N : ExtendedCarrier N atomMap r}
    {p : M.carrier}
    (h_in_cut : p ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N))
    (hxy : x ≤ y)
    (hx_le_p : x ≤ (extendPoint p : ExtendedCarrier M atomMap r))
    (hp_le_y : (extendPoint p : ExtendedCarrier M atomMap r) ≤ y)
    (h_not_point_glb : ¬ ∃ p' : M.carrier,
      (∀ s ∈ continuation_set_cross x y a_n_N y'_N,
        (extendPoint p' : ExtendedCarrier M atomMap r) ≤ s) ∧
      (∀ q : M.carrier,
        (∀ s ∈ continuation_set_cross x y a_n_N y'_N,
          (extendPoint q : ExtendedCarrier M atomMap r) ≤ s) →
        (extendPoint q : ExtendedCarrier M atomMap r) ≤ extendPoint p')) :
    ∃ (u : ExtendedCarrier M atomMap r),
      (extendPoint p : ExtendedCarrier M atomMap r) < u ∧ u < y ∧
      mu_holds u ∧ ¬ cont_holds_cross a_n_N y'_N u := by
  by_contra h_no_witness
  push_neg at h_no_witness
  have hp_in_sc : (extendPoint p : ExtendedCarrier M atomMap r) ∈
      continuation_set_cross x y a_n_N y'_N := by
    refine ⟨⟨hx_le_p, hp_le_y⟩, ?_⟩
    exact h_no_witness
  apply h_not_point_glb
  exact ⟨p, h_in_cut, fun q hq => hq (extendPoint p) hp_in_sc⟩

/-- Cross-version of formula_failure_in_cut: for a carrier point p in the
    cut of inf(S_C^M) with x ≤ p ≤ y, there exists u ≥ p in the cut and
    a formula A of depth ≤ r that holds on (a_n_N, y'_N) in N but fails
    at u in M. -/
private theorem formula_failure_in_cut_cross {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {x y : ExtendedCarrier M atomMap r}
    {a_n_N y'_N : ExtendedCarrier N atomMap r}
    {p : M.carrier}
    (h_in_cut : p ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N))
    (hxy : x ≤ y)
    (hx_le_p : x ≤ (extendPoint p : ExtendedCarrier M atomMap r))
    (hp_le_y : (extendPoint p : ExtendedCarrier M atomMap r) ≤ y)
    (h_not_point_glb : ¬ ∃ p' : M.carrier,
      (∀ s ∈ continuation_set_cross x y a_n_N y'_N,
        (extendPoint p' : ExtendedCarrier M atomMap r) ≤ s) ∧
      (∀ q : M.carrier,
        (∀ s ∈ continuation_set_cross x y a_n_N y'_N,
          (extendPoint q : ExtendedCarrier M atomMap r) ≤ s) →
        (extendPoint q : ExtendedCarrier M atomMap r) ≤ extendPoint p')) :
    ∃ (u : M.carrier),
      p ≤ u ∧
      u ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) ∧
      ∃ (A : StaviFormula),
        stavi_depth A ≤ r ∧
        (∀ v : ExtendedCarrier N atomMap r,
          a_n_N < v → v < y'_N → mu_holds v →
          stavi_temporal_truth_mu N atomMap r v A) ∧
        ¬ stavi_temporal_truth M atomMap u A := by
  obtain ⟨u, hpu, huy, hmu, hcont_fail⟩ :=
    cont_fails_below_gap_cross h_in_cut hxy hx_le_p hp_le_y h_not_point_glb
  obtain ⟨u', hu'⟩ := hmu
  have hmu_u : mu_holds u := ⟨u', hu'⟩
  have hcont_fail_orig : ¬ cont_holds_cross a_n_N y'_N u := hcont_fail
  simp only [cont_holds_cross] at hcont_fail
  push_neg at hcont_fail
  obtain ⟨A, hA_depth, hA_interval, hA_fail⟩ := hcont_fail
  rw [hu'] at hA_fail
  have hA_fail_carrier : ¬ stavi_temporal_truth M atomMap u' A := by
    intro h_holds
    exact hA_fail ((stavi_truth_mu_at_point u' A).mpr h_holds)
  have hu'_in_cut : u' ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) := by
    intro s hs
    by_contra h_not_le
    push_neg at h_not_le
    have h_s_lt_u : s < u := hu' ▸ h_not_le
    have h_cont_at_u := hs.2 u h_s_lt_u huy hmu_u
    exact hcont_fail_orig (hu' ▸ h_cont_at_u)
  have hpu' : p ≤ u' := by
    rw [← extendPoint_le_iff p u']
    exact le_of_lt (hu' ▸ hpu)
  exact ⟨u', hpu', hu'_in_cut, A, hA_depth, hA_interval, hA_fail_carrier⟩

/-- The M-side infimum gap is r-definable (cross-structure version).
    Mirrors `infimum_gap_r_definable` but for `continuation_set_cross`:
    the defining formula D holds on (a_n_N, y'_N) in N but evaluates
    M-side truth for gap_definable_on_right. -/
private theorem infimum_gap_r_definable_cross {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {x y : ExtendedCarrier M atomMap r}
    {a_n_N y'_N : ExtendedCarrier N atomMap r}
    (hxy : x ≤ y)
    (h_ne : (continuation_set_cross x y a_n_N y'_N).Nonempty)
    (h_pt_below : ∃ p : M.carrier, ∀ s ∈ continuation_set_cross x y a_n_N y'_N,
      (extendPoint p : ExtendedCarrier M atomMap r) ≤ s)
    (h_above : ∃ (q : M.carrier) (s : ↥(continuation_set_cross x y a_n_N y'_N)),
      (extendPoint q : ExtendedCarrier M atomMap r) > s.val)
    (h_not_point_glb : ¬ ∃ p : M.carrier,
      (∀ s ∈ continuation_set_cross x y a_n_N y'_N,
        (extendPoint p : ExtendedCarrier M atomMap r) ≤ s) ∧
      (∀ q : M.carrier,
        (∀ s ∈ continuation_set_cross x y a_n_N y'_N,
          (extendPoint q : ExtendedCarrier M atomMap r) ≤ s) →
        (extendPoint q : ExtendedCarrier M atomMap r) ≤ extendPoint p))
    (hx_bound : ∃ p₀ : M.carrier,
      p₀ ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) ∧
      x ≤ (extendPoint p₀ : ExtendedCarrier M atomMap r))
    (h_above_gap_below_y : ∃ q₀ : M.carrier,
      q₀ ∉ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) ∧
      (extendPoint q₀ : ExtendedCarrier M atomMap r) < y ∧
      x ≤ (extendPoint q₀ : ExtendedCarrier M atomMap r)) :
    r_definable_gap M atomMap
      (infimum_gap h_ne h_pt_below h_above h_not_point_glb) r := by
  set gamma := infimum_gap h_ne h_pt_below h_above h_not_point_glb with gamma_def
  -- Step 1: Establish cofinal formula failure below the gap.
  have h_cofinal : ∀ p : M.carrier,
      p ∈ gamma.cut →
      x ≤ (extendPoint p : ExtendedCarrier M atomMap r) →
      (extendPoint p : ExtendedCarrier M atomMap r) ≤ y →
      ∃ (u : M.carrier), p ≤ u ∧ u ∈ gamma.cut ∧
        ∃ (A : StaviFormula), stavi_depth A ≤ r ∧
          (∀ v : ExtendedCarrier N atomMap r,
            a_n_N < v → v < y'_N → mu_holds v →
            stavi_temporal_truth_mu N atomMap r v A) ∧
          ¬ stavi_temporal_truth M atomMap u A := by
    intro p hp hxp hpy
    exact formula_failure_in_cut_cross hp hxy hxp hpy h_not_point_glb
  -- Step 2: Apply pigeonhole to extract a single formula D.
  have h_cofinal' : ∀ p : M.carrier,
      p ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) →
      x ≤ (extendPoint p : ExtendedCarrier M atomMap r) →
      (extendPoint p : ExtendedCarrier M atomMap r) ≤ y →
      ∃ (u : M.carrier), p ≤ u ∧
        u ∈ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) ∧
        ∃ (A : StaviFormula), stavi_depth A ≤ r ∧
          (∀ v : ExtendedCarrier N atomMap r,
            a_n_N < v → v < y'_N → mu_holds v →
            stavi_temporal_truth_mu N atomMap r v A) ∧
          ¬ stavi_temporal_truth M atomMap u A := h_cofinal
  obtain ⟨D, hD_depth, hD_interval, hD_cofinal⟩ :=
    pigeonhole_definable_formula_cross hxy hx_bound h_cofinal'
  -- Step 3: Show D satisfies gap_definable_on_right.
  refine ⟨D, hD_depth, Or.inr ?_⟩
  constructor
  · -- First conjunct: D holds at all carrier points above the gap and ≤ q₀.
    obtain ⟨q₀, hq₀_not_cut, hq₀_lt_y, hx_le_q₀⟩ := h_above_gap_below_y
    refine ⟨q₀, hq₀_not_cut, ?_⟩
    intro u hu_not_cut hu_le_q₀
    have hu_not_cut' : u ∉ inf_carrier_cut (continuation_set_cross x y a_n_N y'_N) := hu_not_cut
    have hx_le_u : x ≤ (extendPoint u : ExtendedCarrier M atomMap r) := by
      simp only [inf_carrier_cut, Set.mem_setOf_eq] at hu_not_cut'
      push_neg at hu_not_cut'
      obtain ⟨s, hs_in, hs_lt⟩ := hu_not_cut'
      exact le_trans hs_in.1.1 (le_of_lt hs_lt)
    have hu_lt_y : (extendPoint u : ExtendedCarrier M atomMap r) < y :=
      lt_of_le_of_lt (extendPoint_le_iff u q₀ |>.mpr hu_le_q₀) hq₀_lt_y
    exact cont_holds_above_gap_cross hu_not_cut' hxy hu_lt_y hx_le_u D hD_depth hD_interval
  · -- Second conjunct: ¬(∃ t ∈ cut, ∀ u ≥ t, u ∈ cut → truth u D).
    intro ⟨t, ht_in_cut, ht_final⟩
    obtain ⟨p₀, hp₀_in, hx_le_p₀⟩ := hx_bound
    have ht_le_y : (extendPoint t : ExtendedCarrier M atomMap r) ≤ y := by
      obtain ⟨s₀, hs₀⟩ := continuation_set_cross_nonempty hxy (a_n_N := a_n_N) (y'_N := y'_N)
      exact le_trans (ht_in_cut s₀ hs₀) hs₀.1.2
    rcases le_total t p₀ with htp₀ | hp₀t
    · have hp₀_le_y : (extendPoint p₀ : ExtendedCarrier M atomMap r) ≤ y := by
        obtain ⟨s₀, hs₀⟩ := continuation_set_cross_nonempty hxy (a_n_N := a_n_N) (y'_N := y'_N)
        exact le_trans (hp₀_in s₀ hs₀) hs₀.1.2
      obtain ⟨u, hp₀u, hu_in_cut, hu_fail⟩ :=
        hD_cofinal p₀ hp₀_in hx_le_p₀ hp₀_le_y
      have h_holds := ht_final u (le_trans htp₀ hp₀u) hu_in_cut
      exact hu_fail h_holds
    · have hx_le_t : x ≤ (extendPoint t : ExtendedCarrier M atomMap r) :=
        le_trans hx_le_p₀ ((extendPoint_le_iff p₀ t).mpr hp₀t)
      obtain ⟨u, htu, hu_in_cut, hu_fail⟩ :=
        hD_cofinal t ht_in_cut hx_le_t ht_le_y
      have h_holds := ht_final u htu hu_in_cut
      exact hu_fail h_holds

/-! ## GHR93 Claim 1: D-Consistency of Strategy Responses

GHR93 Chapter 9, Section 8, Claim 1 (p.28): if Duplicator has a winning strategy
for G_{m;r'}(M, xy; N, x'y') with r' ≥ r, and c is a split point in [x,y] with
formula-agreement partner d in [x',y'], then any winning response at the boundary
position (where c is placed) must equal d.

The proof in GHR93 uses the infimum construction: d is the infimum of S_C.
In our simplified setting where d = a_bwd(n) (Spoiler's last backward pick),
we use the formula agreement and order transfer to show the response must match d.

### Key Argument (GHR93 Claim 1, simplified)

Given: A winning strategy for G_{n+1;r}(M,xy;N,x'y'). Spoiler places c at the
boundary. The response d' := a'_full(boundary) satisfies:
1. d' ∈ [x',y'] (from inClosedInterval)
2. formula_agreement(c, d') (from winning condition)
3. same gap/point status as c (from winning condition)
4. same ordering relative to x',y' as c has to x,y (from same_order_type)

Since c has the same formula_agreement with d (by hcd_form), and the same
gap/point status (by hcd_gp), d' must have the same rank_type as d.
By same_order_type, d' must occupy the same position relative to x',y' as d.

The full uniqueness requires showing that no two distinct elements of [x',y']
can have the same rank_type AND the same ordering relative to endpoints, which
follows from the infimum properties of d (GHR93 Claim 1 proof, p.28-29).
-/

/-- D-consistency (left boundary, existential form): for any Spoiler
    selection ending with c at position n, there exists a Duplicator response
    satisfying bounds, winning condition, AND having d at position n.

    This existential form is weaker than the universal form (which would
    require ALL winning responses to have d at position n). The existential
    suffices for `ghr93_strategy_restrict_left` which only needs ONE response
    with the d-consistency property.

    The proof applies the forward strategy h_fwd to obtain a candidate response,
    then verifies a'_full(n) = d using boundary correspondence from
    same_order_type. Boundary cases (x'=d, d=y') are fully proved.
    Interior case uses the forward strategy's response directly (sorry-free
    for boundary cases; interior case sorry'd pending Claim 1). -/
private theorem d_consistency_left {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {n r : Nat}
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r}
    {d : ExtendedCarrier N atomMap r}
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (hc_interval : inClosedInterval x y c)
    (hd_interval : inClosedInterval x' y' d)
    (hcd_form : ∀ (A : StaviFormula), stavi_depth A ≤ r →
      (stavi_temporal_truth_mu M atomMap r c A ↔
       stavi_temporal_truth_mu N atomMap r d A))
    (hcd_gp : (IsPoint c ↔ IsPoint d) ∧ (IsGap c ↔ IsGap d))
    (hcd_boundary : (x = c ↔ x' = d) ∧ (c = y ↔ d = y'))
    (h_fwd : ghr93_duplicator_wins M N atomMap (n + 1) r x y x' y')
    (h_fwd_r1 : ghr93_duplicator_wins M N atomMap (n + 1) (r + 2)
      (rank_embed (by omega : r ≤ r + 2) x) (rank_embed (by omega : r ≤ r + 2) y)
      (rank_embed (by omega : r ≤ r + 2) x') (rank_embed (by omega : r ≤ r + 2) y'))
    (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p))
    -- GHR93 Claim 1 (interior case): when d is strictly interior to [x',y'],
    -- the rank-r forward game response at position n equals d.
    -- This replaces the false universal h_d_unique with a direct d-consistency
    -- guarantee constructed via rank_down(h_fwd_r1) + K⁻(¬D) at the call site.
    (h_interior_d : x' ≠ d → d ≠ y' →
      ∀ (a_pad : Fin (n + 1) → ExtendedCarrier M atomMap r),
        (∀ i, inClosedInterval x y (a_pad i)) →
        a_pad ⟨n, by omega⟩ = c →
        ∃ (a'_full : Fin (n + 1) → ExtendedCarrier N atomMap r),
          (∀ i, inClosedInterval x' y' (a'_full i)) ∧
          (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
            ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
              ghr93_winning_condition (n + 1)
                (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) ∧
          a'_full ⟨n, by omega⟩ = d) :
    ∀ (a_pad : Fin (n + 1) → ExtendedCarrier M atomMap r),
      (∀ i, inClosedInterval x y (a_pad i)) →
      a_pad ⟨n, by omega⟩ = c →
      ∃ (a'_full : Fin (n + 1) → ExtendedCarrier N atomMap r),
        (∀ i, inClosedInterval x' y' (a'_full i)) ∧
        (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
          ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
            ghr93_winning_condition (n + 1)
              (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) ∧
        a'_full ⟨n, by omega⟩ = d := by
  intro a_pad ha_pad hc_last
  -- Boundary case 1: x' = d
  by_cases hx'd : x' = d
  · -- Apply the forward strategy for the boundary case
    obtain ⟨a'_full, ha'_full, hwin_full⟩ := h_fwd a_pad ha_pad
    set t := a'_full ⟨n, by omega⟩ with ht_def
    obtain ⟨p₀, hp₀⟩ := h_pt
    obtain ⟨b₀, hb₀, hcond₀⟩ := hwin_full p₀ hp₀
    obtain ⟨hord₀, _, _⟩ := hcond₀
    have heq_0_n1 := (hord₀ ⟨0, by omega⟩ ⟨n + 1, by omega⟩).2
    simp only [game_tuple, show (0 : Nat) = 0 from rfl, dite_true,
               show (n + 1 : Nat) ≠ 0 from by omega,
               show (n + 1 : Nat) ≠ (n + 1) + 1 from by omega,
               show (n + 1 : Nat) ≠ (n + 1) + 2 from by omega, dite_false,
               show n + 1 - 1 = n from by omega] at heq_0_n1
    rw [hc_last] at heq_0_n1
    have hxc : x = c := hcd_boundary.1.mpr hx'd
    have hx't : x' = t := heq_0_n1.mp hxc
    have ht_eq_d : t = d := hx't.symm.trans hx'd
    exact ⟨a'_full, ha'_full, hwin_full, ht_def ▸ ht_eq_d⟩
  · by_cases hdy' : d = y'
    · -- Apply the forward strategy for the boundary case
      obtain ⟨a'_full, ha'_full, hwin_full⟩ := h_fwd a_pad ha_pad
      set t := a'_full ⟨n, by omega⟩ with ht_def
      obtain ⟨p₀, hp₀⟩ := h_pt
      obtain ⟨b₀, hb₀, hcond₀⟩ := hwin_full p₀ hp₀
      obtain ⟨hord₀, _, _⟩ := hcond₀
      have heq_n1_n3 := (hord₀ ⟨n + 1, by omega⟩ ⟨(n + 1) + 2, by omega⟩).2
      simp only [game_tuple, show (n + 1 : Nat) ≠ 0 from by omega,
                 show (n + 1 : Nat) ≠ (n + 1) + 1 from by omega,
                 show (n + 1 : Nat) ≠ (n + 1) + 2 from by omega, dite_false,
                 show n + 1 - 1 = n from by omega,
                 show ((n + 1) + 2 : Nat) ≠ 0 from by omega,
                 show ¬((n + 1 + 2 : Nat) = (n + 1) + 1) from by omega,
                 show (n + 1 + 2 : Nat) = (n + 1) + 2 from by omega, dite_true] at heq_n1_n3
      rw [hc_last] at heq_n1_n3
      have hcy : c = y := hcd_boundary.2.mpr hdy'
      have hty' : t = y' := heq_n1_n3.mp hcy
      have ht_eq_d : t = d := hty'.trans hdy'.symm
      exact ⟨a'_full, ha'_full, hwin_full, ht_def ▸ ht_eq_d⟩
    · -- Interior case: x' < d < y'. Delegate to h_interior_d.
      exact h_interior_d hx'd hdy' a_pad ha_pad hc_last

/-- D-consistency (right boundary, existential form): dual of
    d_consistency_left for the right sub-interval, where c is placed at
    position 0. For any Spoiler selection starting with c, there exists a
    response satisfying bounds, winning condition, AND having d at position 0.

    Boundary cases proved; interior case sorry'd (same blocker as left). -/
private theorem d_consistency_right {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {n r : Nat}
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r}
    {d : ExtendedCarrier N atomMap r}
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (hc_interval : inClosedInterval x y c)
    (hd_interval : inClosedInterval x' y' d)
    (hcd_form : ∀ (A : StaviFormula), stavi_depth A ≤ r →
      (stavi_temporal_truth_mu M atomMap r c A ↔
       stavi_temporal_truth_mu N atomMap r d A))
    (hcd_gp : (IsPoint c ↔ IsPoint d) ∧ (IsGap c ↔ IsGap d))
    (hcd_boundary : (x = c ↔ x' = d) ∧ (c = y ↔ d = y'))
    (h_fwd : ghr93_duplicator_wins M N atomMap (n + 1) r x y x' y')
    (h_fwd_r1 : ghr93_duplicator_wins M N atomMap (n + 1) (r + 2)
      (rank_embed (by omega : r ≤ r + 2) x) (rank_embed (by omega : r ≤ r + 2) y)
      (rank_embed (by omega : r ≤ r + 2) x') (rank_embed (by omega : r ≤ r + 2) y'))
    (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p))
    -- GHR93 Claim 1 (interior case, right boundary): when d is strictly
    -- interior to [x',y'], the rank-r forward game response at position 0
    -- equals d. Constructed via rank_down(h_fwd_r1) + K⁻(¬D) at the call site.
    (h_interior_d : x' ≠ d → d ≠ y' →
      ∀ (a_pad : Fin (n + 1) → ExtendedCarrier M atomMap r),
        (∀ i, inClosedInterval x y (a_pad i)) →
        a_pad ⟨0, by omega⟩ = c →
        ∃ (a'_full : Fin (n + 1) → ExtendedCarrier N atomMap r),
          (∀ i, inClosedInterval x' y' (a'_full i)) ∧
          (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
            ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
              ghr93_winning_condition (n + 1)
                (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) ∧
          a'_full ⟨0, by omega⟩ = d) :
    ∀ (a_pad : Fin (n + 1) → ExtendedCarrier M atomMap r),
      (∀ i, inClosedInterval x y (a_pad i)) →
      a_pad ⟨0, by omega⟩ = c →
      ∃ (a'_full : Fin (n + 1) → ExtendedCarrier N atomMap r),
        (∀ i, inClosedInterval x' y' (a'_full i)) ∧
        (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
          ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
            ghr93_winning_condition (n + 1)
              (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) ∧
        a'_full ⟨0, by omega⟩ = d := by
  intro a_pad ha_pad hc_first
  -- Boundary case 1: x' = d
  by_cases hx'd : x' = d
  · obtain ⟨a'_full, ha'_full, hwin_full⟩ := h_fwd a_pad ha_pad
    set t := a'_full ⟨0, by omega⟩ with ht_def
    obtain ⟨p₀, hp₀⟩ := h_pt
    obtain ⟨b₀, hb₀, hcond₀⟩ := hwin_full p₀ hp₀
    obtain ⟨hord₀, _, _⟩ := hcond₀
    have heq_0_1 := (hord₀ ⟨0, by omega⟩ ⟨1, by omega⟩).2
    simp only [game_tuple, show (0 : Nat) = 0 from rfl, dite_true,
               show (1 : Nat) ≠ 0 from by omega,
               show (1 : Nat) ≠ (n + 1) + 1 from by omega,
               show (1 : Nat) ≠ (n + 1) + 2 from by omega, dite_false,
               show 1 - 1 = 0 from by omega] at heq_0_1
    rw [hc_first] at heq_0_1
    have hxc : x = c := hcd_boundary.1.mpr hx'd
    have hx't : x' = t := heq_0_1.mp hxc
    have ht_eq_d : t = d := hx't.symm.trans hx'd
    exact ⟨a'_full, ha'_full, hwin_full, ht_def ▸ ht_eq_d⟩
  · by_cases hdy' : d = y'
    · obtain ⟨a'_full, ha'_full, hwin_full⟩ := h_fwd a_pad ha_pad
      set t := a'_full ⟨0, by omega⟩ with ht_def
      obtain ⟨p₀, hp₀⟩ := h_pt
      obtain ⟨b₀, hb₀, hcond₀⟩ := hwin_full p₀ hp₀
      obtain ⟨hord₀, _, _⟩ := hcond₀
      have heq_1_n3 : c = y ↔ t = y' := by
        have h := (hord₀ ⟨1, by omega⟩ ⟨(n + 1) + 2, by omega⟩).2
        simp only [game_tuple, show (1 : Nat) ≠ 0 from by omega,
                   show (1 : Nat) ≠ (n + 1) + 1 from by omega,
                   show (1 : Nat) ≠ (n + 1) + 2 from by omega, dite_false,
                   show 1 - 1 = 0 from by omega,
                   show ((n + 1) + 2 : Nat) ≠ 0 from by omega,
                   show ¬((n + 1 + 2 : Nat) = (n + 1) + 1) from by omega,
                   show (n + 1 + 2 : Nat) = (n + 1) + 2 from by omega, dite_true] at h
        rwa [show a_pad ⟨1 - 1, by omega⟩ = c from hc_first] at h
      have hcy : c = y := hcd_boundary.2.mpr hdy'
      have hty' : t = y' := heq_1_n3.mp hcy
      have ht_eq_d : t = d := hty'.trans hdy'.symm
      exact ⟨a'_full, ha'_full, hwin_full, ht_def ▸ ht_eq_d⟩
    · -- Interior case: x' < d < y'. Delegate to h_interior_d.
      exact h_interior_d hx'd hdy' a_pad ha_pad hc_first


/-! ## Game Rank Downward Transport (GHR93 Lemma 10, rank part)

If Duplicator wins the game at rank r' with rank-embedded positions from
rank r, she also wins at rank r. This is the rank-monotonicity part of
GHR93 Lemma 10: the rank-r' game with rank-embedded endpoints involves
more carrier elements (more gaps) but also a stronger winning condition
(formula agreement at depth ≤ r' ≥ r). Crucially, Duplicator's responses
can always be chosen from rank r, because formula agreement forces gap
responses to be r-definable (via the K⁺/K⁻ characterization of gaps). -/

/-- **GHR93 Lemma 10** (Game rank downward transport):
    If Duplicator wins G_{m;r'}(M, xy; N, x'y') with rank-embedded positions
    (r + 2 ≤ r'), then she wins G_{m;r}(M, xy; N, x'y').

    The proof uses GHR93's K⁺/K⁻ gap characterization formula D' of depth
    ≤ r+2 ≤ r' to transfer gap definability from Spoiler's picks to
    Duplicator's responses. Gap responses at rank r' are shown r-definable
    by formula agreement, then projected to rank r.

    Hypothesis r + 2 ≤ r' is needed because gap_char_formula D has
    stavi_depth = stavi_depth(D) + 2, and formula agreement covers depth ≤ r'. -/
private theorem ghr93_duplicator_wins_rank_down {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {m r r' : Nat} (hle : r ≤ r') (h2 : r + 2 ≤ r')
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h : ghr93_duplicator_wins M N atomMap m r'
           (rank_embed hle x) (rank_embed hle y)
           (rank_embed hle x') (rank_embed hle y')) :
    ghr93_duplicator_wins M N atomMap m r x y x' y' := by
  -- Spoiler picks m elements from [x,y] at rank r.
  intro a ha
  -- Embed Spoiler's picks to rank r'.
  have ha' : ∀ i, inClosedInterval (rank_embed hle x) (rank_embed hle y)
      (rank_embed hle (a i)) := by
    intro i; exact (rank_embed_inClosedInterval hle x y (a i)).mpr (ha i)
  -- Apply the rank-r' strategy.
  obtain ⟨a'_r', ha'_r'_in, hwin_r'⟩ := h (fun i => rank_embed hle (a i)) ha'
  -- Case split: does [x', y'] contain a carrier point?
  by_cases h_pt : ∃ (p₀ : N.carrier), inClosedInterval x' y' (extendPoint p₀)
  · -- Case 1: carrier point p₀ ∈ [x', y']. Use it to extract winning conditions.
    obtain ⟨p₀, hp₀⟩ := h_pt
    -- Embed p₀ to rank r'
    have hp₀' : inClosedInterval (rank_embed hle x') (rank_embed hle y')
        (extendPoint p₀) := by
      rw [← rank_embed_point hle p₀]
      exact (rank_embed_inClosedInterval hle x' y' (extendPoint p₀)).mpr hp₀
    -- Extract winning condition using p₀
    obtain ⟨b₀, hb₀, hcond₀⟩ := hwin_r' p₀ hp₀'
    obtain ⟨hord₀, hgp₀, hform₀⟩ := hcond₀
    -- Extract formula agreement at selection positions from the winning condition.
    -- Position i+1 in game tuple: M-side = rank_embed(a(i)), N-side = a'_r'(i)
    have hform_sel : ∀ (i : Fin m) (A : StaviFormula), stavi_depth A ≤ r' →
        (stavi_temporal_truth_mu M atomMap r' (rank_embed hle (a i)) A ↔
         stavi_temporal_truth_mu N atomMap r' (a'_r' i) A) := by
      intro i A hA
      have h := hform₀ ⟨1 + i.val, by omega⟩ A hA
      simp only [game_tuple] at h
      simp only [show (1 + i.val : Nat) ≠ 0 from by omega,
                 show ¬((1 + i.val : Nat) = m + 1) from by { have := i.isLt; omega },
                 show ¬((1 + i.val : Nat) = m + 2) from by { have := i.isLt; omega },
                 dite_false, show 1 + i.val - 1 = i.val from by omega] at h
      exact h
    -- Extract gap/point agreement at selection positions
    have hgp_sel : ∀ (i : Fin m),
        (IsPoint (rank_embed hle (a i)) ↔ IsPoint (a'_r' i)) ∧
        (IsGap (rank_embed hle (a i)) ↔ IsGap (a'_r' i)) := by
      intro i
      have h := hgp₀ ⟨1 + i.val, by omega⟩
      simp only [game_tuple] at h
      simp only [show (1 + i.val : Nat) ≠ 0 from by omega,
                 show ¬((1 + i.val : Nat) = m + 1) from by { have := i.isLt; omega },
                 show ¬((1 + i.val : Nat) = m + 2) from by { have := i.isLt; omega },
                 dite_false, show 1 + i.val - 1 = i.val from by omega] at h
      exact h
    -- For each gap response, show it is r-definable via gap_char_formula transfer.
    -- If a(i) is a gap at rank r defined by D (depth ≤ r), then gap_char_formula(D)
    -- has depth r + 2 ≤ r'. It holds at rank_embed(a(i)) and transfers to a'_r'(i).
    have h_gap_r_def : ∀ (i : Fin m) (g : RDefinableGap N atomMap r'),
        a'_r' i = Sum.inr g → r_definable_gap N atomMap g.val r := by
      intro i g hg
      -- a'_r'(i) is a gap. By gap/point agreement, rank_embed(a(i)) is a gap.
      have h_gp := (hgp_sel i).2.mpr ⟨g, hg⟩
      -- Case split on a(i) to determine if it's a point or gap.
      cases ha_i : a i with
      | inl q =>
        -- a(i) is a carrier point. rank_embed(a(i)) = extendPoint q at rank r'.
        -- gap/point says IsGap(extendPoint q at r') iff IsGap(a'_r'(i)).
        -- a'_r'(i) is a gap. So IsGap(extendPoint q) must hold.
        -- But extendPoint q = Sum.inl q, which is NOT a gap. Contradiction.
        exfalso
        have : IsPoint (rank_embed hle (a i)) := by
          rw [ha_i]; simp [rank_embed, Sum.map, IsPoint, extendPoint]
        have : ¬IsGap (rank_embed hle (a i)) := by
          intro ⟨g', hg'⟩; rw [ha_i] at hg'; simp [rank_embed, Sum.map, extendPoint] at hg'
        exact this h_gp
      | inr g_r =>
        -- a(i) = Sum.inr g_r, an r-definable gap at rank r.
        -- g_r : RDefinableGap M atomMap r. g_r.prop : r_definable_gap M atomMap g_r.val r.
        obtain ⟨D, hD_depth, hD_def⟩ := g_r.prop
        -- gap_char_formula(D) holds at g_r at rank r
        have h_char_M : stavi_temporal_truth_mu M atomMap r (Sum.inr g_r)
            (gap_char_formula D) :=
          gap_char_formula_holds g_r D hD_depth hD_def
        -- By rank_embed_stavi_truth_mu, it holds at rank_embed(a(i)) at rank r'
        have h_char_M' : stavi_temporal_truth_mu M atomMap r'
            (rank_embed hle (a i)) (gap_char_formula D) := by
          rw [ha_i, rank_embed_gap_eq]
          exact (rank_embed_stavi_truth_mu hle (Sum.inr g_r) (gap_char_formula D)).mpr h_char_M
        -- Transfer via formula agreement: depth(gap_char_formula D) ≤ r + 2 ≤ r'
        have h_depth_ok : stavi_depth (gap_char_formula D) ≤ r' :=
          le_trans (stavi_depth_gap_char_formula_le hD_depth) h2
        have h_char_N : stavi_temporal_truth_mu N atomMap r' (a'_r' i)
            (gap_char_formula D) :=
          (hform_sel i (gap_char_formula D) h_depth_ok).mp h_char_M'
        -- gap_char_formula_implies_definable: g is definable by D
        have h_char_g : stavi_temporal_truth_mu N atomMap r' (Sum.inr g)
            (gap_char_formula D) := hg ▸ h_char_N
        have h_def := gap_char_formula_implies_definable g D h_char_g
        -- D has depth ≤ r, so g is r-definable
        exact ⟨D, hD_depth, h_def⟩
    -- Define projection: rank r' elements → rank r elements
    -- Points project to the same carrier point. Gaps project using r-definability.
    let proj : (i : Fin m) → ExtendedCarrier N atomMap r := fun i =>
      match h_eq : a'_r' i with
      | .inl q => extendPoint q
      | .inr g => Sum.inr ⟨g.val, h_gap_r_def i g h_eq⟩
    -- proj(i) ∈ [x', y'] at rank r
    have hproj_in : ∀ i, inClosedInterval x' y' (proj i) := by
      intro i
      have h_in := ha'_r'_in i
      -- h_in : inClosedInterval (rank_embed hle x') (rank_embed hle y') (a'_r' i)
      simp only [proj]
      split
      · case h_1 q h_eq =>
        -- a'_r'(i) = Sum.inl q at rank r'. proj(i) = extendPoint q at rank r.
        -- Sum.inl q = extendPoint q = rank_embed(extendPoint q at rank r)
        rw [h_eq] at h_in
        -- h_in : inClosedInterval (rank_embed hle x') (rank_embed hle y') (Sum.inl q)
        -- Sum.inl q at rank r' = rank_embed(Sum.inl q at rank r) by rank_embed_point
        have h_re : (Sum.inl q : ExtendedCarrier N atomMap r') =
            rank_embed hle (extendPoint q : ExtendedCarrier N atomMap r) := by
          simp [rank_embed, Sum.map, extendPoint]
        rw [h_re] at h_in
        exact (rank_embed_inClosedInterval hle x' y' (extendPoint q)).mp h_in
      · case h_2 g h_eq =>
        -- a'_r'(i) = Sum.inr g at rank r'. proj(i) = Sum.inr ⟨g.val, _⟩ at rank r.
        -- Since rank_embed(proj(i)) = a'_r'(i) (shown in hN_eq below), we have
        -- rank_embed(x') ≤ a'_r'(i) ≤ rank_embed(y') at rank r'.
        -- Since rank_embed(proj(i)) = a'_r'(i), and rank_embed preserves ≤:
        -- x' ≤ proj(i) ≤ y' at rank r.
        rw [h_eq] at h_in
        -- rank_embed(Sum.inr ⟨g.val, _⟩) = Sum.inr g (same underlying gap)
        have h_re : rank_embed hle (Sum.inr ⟨g.val, h_gap_r_def i g h_eq⟩ :
            ExtendedCarrier N atomMap r) = (Sum.inr g : ExtendedCarrier N atomMap r') := by
          simp [rank_embed, Sum.map, rank_embed_gap, Subtype.ext_iff]
        have h_in' : inClosedInterval (rank_embed hle x') (rank_embed hle y')
            (rank_embed hle (Sum.inr ⟨g.val, h_gap_r_def i g h_eq⟩ :
              ExtendedCarrier N atomMap r)) := h_re ▸ h_in
        exact (rank_embed_inClosedInterval hle x' y' _).mp h_in'
    -- Provide the projected responses and prove the winning condition.
    refine ⟨proj, hproj_in, ?_⟩
    intro b' hb'
    -- Embed b' to rank r'
    have hb'' : inClosedInterval (rank_embed hle x') (rank_embed hle y')
        (extendPoint b') := by
      rw [← rank_embed_point hle b']
      exact (rank_embed_inClosedInterval hle x' y' (extendPoint b')).mpr hb'
    obtain ⟨b, hb, hcond⟩ := hwin_r' b' hb''
    -- b is in [rank_embed(x), rank_embed(y)] at rank r', so b ∈ [x, y] at rank r
    have hb_r : inClosedInterval x y (extendPoint b) := by
      rw [← rank_embed_point hle b] at hb
      exact (rank_embed_inClosedInterval hle x y (extendPoint b)).mp hb
    refine ⟨b, hb_r, ?_⟩
    obtain ⟨hord, hgp, hform⟩ := hcond
    -- Key helper: M-side game tuple at rank r' = rank_embed of M-side at rank r.
    have hM_eq : ∀ (k : Fin (m + 3)),
        game_tuple (rank_embed hle x) (rank_embed hle y)
          (fun i => rank_embed hle (a i)) b k =
        rank_embed hle (game_tuple x y a b k) := by
      intro k
      simp only [game_tuple]
      split_ifs with h0 hn1 hn2
      · -- k = 0: rank_embed(x) = rank_embed(x) ✓
        rfl
      · -- k = m+1: extendPoint b at rank r' = rank_embed(extendPoint b at rank r)
        exact (rank_embed_point hle b).symm
      · -- k = m+2: rank_embed(y) = rank_embed(y) ✓
        rfl
      · -- 1 ≤ k ≤ m: rank_embed(a(k-1)) = rank_embed(a(k-1)) ✓
        rfl
    -- Key helper: N-side game tuple at rank r' = rank_embed of N-side at rank r.
    -- For each position k: game_tuple_N_r'(k) = rank_embed(game_tuple_N_r(k)).
    have hN_eq : ∀ (k : Fin (m + 3)),
        game_tuple (rank_embed hle x') (rank_embed hle y') a'_r' b' k =
        rank_embed hle (game_tuple x' y' proj b' k) := by
      intro k
      simp only [game_tuple]
      split_ifs with h0 hn1 hn2
      · rfl  -- k=0: rank_embed(x') = rank_embed(x')
      · exact (rank_embed_point hle b').symm  -- k=m+1: extendPoint b'
      · rfl  -- k=m+2: rank_embed(y') = rank_embed(y')
      · -- Selection: a'_r'(k-1) = rank_embed(proj(k-1))
        have hk : k.val - 1 < m := by omega
        simp only [proj]
        split
        · case h_1 q h_eq =>
          rw [show Fin.mk (k.val - 1) (by omega) = ⟨k.val - 1, hk⟩ from rfl] at h_eq
          rw [h_eq]; exact (rank_embed_point hle q).symm
        · case h_2 g h_eq =>
          -- h_eq : a'_r' ⟨k.val - 1, _⟩ = Sum.inr g
          -- Goal: a'_r' ⟨k.val - 1, _⟩ = rank_embed hle (Sum.inr ⟨g.val, _⟩)
          -- Both Fin indices have the same val; use proof irrelevance via trans
          have h1 : a'_r' ⟨k.val - 1, by omega⟩ = Sum.inr g := h_eq
          have h2 : (Sum.inr g : ExtendedCarrier N atomMap r') =
              rank_embed hle (Sum.inr ⟨g.val, h_gap_r_def ⟨k.val - 1, by omega⟩ g h_eq⟩ :
                ExtendedCarrier N atomMap r) := by
            simp [rank_embed, Sum.map, rank_embed_gap, Subtype.ext_iff]
          exact h1.trans h2
    -- Now prove the three winning condition components using hM_eq and hN_eq.
    -- Both sides of the game tuple are rank_embed of their rank-r counterparts,
    -- so rank_embed preserves <, =, IsPoint, IsGap, and formula truth.
    refine ⟨?_, ?_, ?_⟩
    · -- same_order_type at rank r
      intro i j
      have h_ij := hord i j
      rw [hM_eq i, hM_eq j] at h_ij
      rw [hN_eq i, hN_eq j] at h_ij
      exact ⟨(rank_embed_lt hle _ _).symm.trans (h_ij.1.trans (rank_embed_lt hle _ _)),
             ⟨fun h => rank_embed_injective hle _ _ (h_ij.2.mp (congrArg _ h)),
              fun h => rank_embed_injective hle _ _ (h_ij.2.mpr (congrArg _ h))⟩⟩
    · -- gap_point_agreement at rank r
      intro k
      have h_gp_k := hgp k
      rw [hM_eq k, hN_eq k] at h_gp_k
      -- IsPoint transfer: rank_embed_isPoint gives the bridge
      have h_pt : IsPoint (game_tuple x y a b k) ↔ IsPoint (game_tuple x' y' proj b' k) :=
        (rank_embed_isPoint hle _).symm.trans (h_gp_k.1.trans (rank_embed_isPoint hle _))
      -- IsGap: derive from IsPoint using the fact that elements are either points or gaps
      have h_gap : IsGap (game_tuple x y a b k) ↔ IsGap (game_tuple x' y' proj b' k) := by
        constructor
        · intro ⟨g, hg⟩
          -- M-side is a gap, so NOT a point
          have h_not_pt_M : ¬IsPoint (game_tuple x y a b k) := by
            intro ⟨q, hq⟩; rw [hg] at hq; cases hq
          -- N-side is also NOT a point (by h_pt)
          have h_not_pt_N : ¬IsPoint (game_tuple x' y' proj b' k) :=
            fun hp => h_not_pt_M (h_pt.mpr hp)
          -- N-side must be a gap
          rcases isPoint_or_isGap (game_tuple x' y' proj b' k) with hp | hg'
          · exact absurd hp h_not_pt_N
          · exact hg'
        · intro ⟨g, hg⟩
          have h_not_pt_N : ¬IsPoint (game_tuple x' y' proj b' k) := by
            intro ⟨q, hq⟩; rw [hg] at hq; cases hq
          have h_not_pt_M : ¬IsPoint (game_tuple x y a b k) :=
            fun hp => h_not_pt_N (h_pt.mp hp)
          rcases isPoint_or_isGap (game_tuple x y a b k) with hp | hg'
          · exact absurd hp h_not_pt_M
          · exact hg'
      exact ⟨h_pt, h_gap⟩
    · -- formula_agreement at rank r (depth ≤ r)
      intro k A hA
      have hA' : stavi_depth A ≤ r' := le_trans hA hle
      have h_form_k := hform k A hA'
      rw [hM_eq k, hN_eq k] at h_form_k
      exact (rank_embed_stavi_truth_mu hle _ A).symm.trans
        (h_form_k.trans (rank_embed_stavi_truth_mu hle _ A))
  · -- Case 2: no carrier point in [x', y']. The winning condition is vacuously true.
    push_neg at h_pt
    refine ⟨fun _ => x', fun _ => ⟨le_refl _, hx'y'⟩, ?_⟩
    intro b' hb'; exact absurd hb' (h_pt b')

/-! ## GHR93 Theorem 6: Inductive Step Infrastructure

The inductive step of Theorem 6 converts a forward (4+3n)-round strategy
into a backward (n+1)-round strategy. The proof introduces key quantities
from the GHR93 argument:

- **d**: A "split point" in N_r that separates the interval [x',y'] based on
  where the forward strategy's type pattern changes. Formally, d is defined
  using the interval type A = X_{(a_{n-1}, a_n)} and a continuation formula C.

- **c**: The corresponding split point in M_r, obtained by applying the
  forward strategy to d.

- **σ, τ**: Backward strategies on sub-intervals [x',d]/[x,c] and
  [d,y']/[c,y], obtained by restricting the master forward strategy and
  applying the inductive hypothesis (*)_n.

The proof then splits into four cases based on the nature of a_n (Spoiler's
last selection in the backward game). -/

/-- Properties of the split points c, d that are needed for the case analysis.

    These encapsulate the key facts established in the GHR93 proof about
    the relationship between c, d, the forward strategy, and the IH.
    All properties are sorry'd pending the full infimum/strategy-restriction
    infrastructure.

    The record bundles:
    - Interval containment: d ∈ [x',y'], c ∈ [x,y]
    - Position bound: d ≤ a_n (Spoiler's last pick is past the split)
    - Sub-interval backward strategies σ, τ from the IH -/
structure SplitPointProps {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (n : Nat)
    (x y : ExtendedCarrier M atomMap r)
    (x' y' : ExtendedCarrier N atomMap r)
    (c : ExtendedCarrier M atomMap r)
    (d : ExtendedCarrier N atomMap r)
    (a_bwd : Fin (n + 1) → ExtendedCarrier N atomMap r) where
  /-- c is in [x, y] -/
  hc_interval : inClosedInterval x y c
  /-- d is in [x', y'] -/
  hd_interval : inClosedInterval x' y' d
  /-- The split point d is ≤ a_n (Spoiler's last backward pick).
      When d = infimum of continuation_set (GHR93 d̄), this holds because
      a_bwd(n) ∈ continuation_set and the infimum ≤ every member.
      Case I uses ≤ only. Case II is restructured to work without =. -/
  hd_le_an : d ≤ a_bwd ⟨n, by omega⟩
  /-- x ≤ c (for sub-interval well-formedness) -/
  hxc : x ≤ c
  /-- c ≤ y (for sub-interval well-formedness) -/
  hcy : c ≤ y
  /-- x' ≤ d (for sub-interval well-formedness) -/
  hx'd : x' ≤ d
  /-- d ≤ y' (for sub-interval well-formedness) -/
  hdy' : d ≤ y'
  /-- There exists an actual M-point in [x, c], or x = c (and x' = d) with c a gap.
      Degenerate case: GHR93 allows the sub-interval to be a single gap point.
      The x' = d condition ensures the N-side sub-interval is also degenerate. -/
  h_pt_xc : (∃ (p : M.carrier), inClosedInterval x c (extendPoint p)) ∨
             (x = c ∧ x' = d ∧ IsGap c ∧ IsGap d)
  /-- There exists an actual M-point in [c, y], or c = y (and d = y') with c a gap.
      Degenerate case: GHR93 allows the sub-interval to be a single gap point.
      The d = y' condition ensures the N-side sub-interval is also degenerate. -/
  h_pt_cy : (∃ (p : M.carrier), inClosedInterval c y (extendPoint p)) ∨
             (c = y ∧ d = y' ∧ IsGap c ∧ IsGap d)
  /-- Formula agreement between c and d at rank r.
      Used in degenerate gap cases (GHR93 implicit: game on [d,d] vs [c,c]). -/
  hcd_form : ∀ (A : StaviFormula), stavi_depth A ≤ r →
      (stavi_temporal_truth_mu M atomMap r c A ↔
       stavi_temporal_truth_mu N atomMap r d A)
  /-- Gap/point correspondence between c and d.
      Used in degenerate gap cases and Case II point derivation. -/
  hcd_gp : (IsPoint c ↔ IsPoint d) ∧ (IsGap c ↔ IsGap d)
  /-- Backward strategy σ on the left sub-interval:
      Duplicator wins G_{n;r}(N, x'd; M, xc) -/
  sigma : ghr93_duplicator_wins N M atomMap n r x' d x c
  /-- Backward strategy τ on the right sub-interval:
      Duplicator wins G_{n;r}(N, dy'; M, cy) -/
  tau : ghr93_duplicator_wins N M atomMap n r d y' c y
  /-- (n+1)-round forward strategy on the full interval.
      Derived from the (4+3n)-round forward strategy via round_mono.
      Used in Case II to construct e_n and establish ordering compatibility. -/
  h_fwd_n1 : ghr93_duplicator_wins M N atomMap (n + 1) r x y x' y'

/-- Obtain the split point properties. This is the core setup lemma for
    the inductive step, combining strategy restriction and IH application.

    **Approach** (simplified from GHR93, avoids infimum infrastructure):

    1. Set d = a_bwd(n) — Spoiler's last backward pick. Then hd_eq_an is rfl.
    2. Play the forward (4+3n)-round strategy with 1 element from [x,y] to find a
       compatible point c. Specifically, use round_mono to get a 1-round strategy,
       then play it to find c such that c and d have the same rank_type and
       gap/point status.
    3. Apply strategy_restrict_left/right with c,d to restrict the forward strategy
       from [x,y] to [x,c] and [c,y] (consuming one round each).
    4. Apply round_mono to reduce rounds to 1+3n.
    5. Apply the generalized IH on the sub-intervals to get sigma and tau.

    The generalized IH is universally quantified over endpoints, so it can be
    applied to sub-intervals [x,c]/[x',d] and [c,y]/[d,y'].

    Key insight: We do NOT need to compute an infimum. Setting d = a_bwd(n)
    and obtaining c from the forward strategy is sufficient. The winning
    condition of the forward game guarantees that c and d are compatible
    (same rank_type, same gap/point status).

    NOTE: Steps 2-5 are sorry'd pending full proofs of strategy_restrict_left/right
    and the sub-interval h_pt witness (existence of an actual point in each
    sub-interval). The construction is structurally correct — the sorry's are
    in the strategy restriction lemma and the sub-interval point existence.  -/
private theorem obtain_split_point_props {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {n r : Nat}
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p))
    (h_pt_M : ∃ (p : M.carrier), inClosedInterval x y (extendPoint p))
    (ih : ∀ {x₀ y₀ : ExtendedCarrier M atomMap r}
            {x₀' y₀' : ExtendedCarrier N atomMap r},
          x₀ ≤ y₀ → x₀' ≤ y₀' →
          (∃ p, inClosedInterval x₀' y₀' (extendPoint p)) →
          ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x₀ y₀ x₀' y₀' →
          ghr93_duplicator_wins N M atomMap n r x₀' y₀' x₀ y₀)
    (h_fwd : ghr93_duplicator_wins M N atomMap (4 + 3 * n) r x y x' y')
    (h_fwd_r1 : ghr93_duplicator_wins M N atomMap (4 + 3 * n) (r + 2)
      (rank_embed (by omega : r ≤ r + 2) x) (rank_embed (by omega : r ≤ r + 2) y)
      (rank_embed (by omega : r ≤ r + 2) x') (rank_embed (by omega : r ≤ r + 2) y'))
    (a_bwd : Fin (n + 1) → ExtendedCarrier N atomMap r)
    (ha_bwd : ∀ i, inClosedInterval x' y' (a_bwd i)) :
    ∃ (c : ExtendedCarrier M atomMap r) (d : ExtendedCarrier N atomMap r),
      SplitPointProps n x y x' y' c d a_bwd := by
  -- Step 1: Set d = inf(continuation_set) — the GHR93 d̄.
  -- S_C = {t ∈ [x',y'] : cont_holds at all mu-points in (t, y')}
  -- a_bwd(n) ∈ S_C. d = inf(S_C) ≤ a_bwd(n).
  -- The infimum is either a carrier point (if S_C has a point minimum)
  -- or a gap (constructed via infimum_gap).
  -- For this refactoring, we sorry-construct the infimum with its key properties.
  -- The infrastructure for the full construction exists (infimum_gap,
  -- infimum_gap_r_definable, inf_carrier_cut, etc.) and is sorry-free.
  -- Construct d as the infimum of S_C within [x', y'].
  -- Case split: either a_bwd(n) is the minimum of S_C, or S_C has elements
  -- strictly below a_bwd(n) (requiring gap/point infimum construction).
  set S_C := continuation_set x' y' (a_bwd ⟨n, by omega⟩) with S_C_def
  have h_an_in_SC : a_bwd ⟨n, by omega⟩ ∈ S_C :=
    a_n_in_continuation_set (ha_bwd ⟨n, by omega⟩)
  obtain ⟨d, hd_interval, hd_glb, hd_le_an_proof, hd_is_inf⟩ :
      ∃ d : ExtendedCarrier N atomMap r,
        inClosedInterval x' y' d ∧
        (∀ s ∈ S_C, d ≤ s) ∧
        d ≤ a_bwd ⟨n, by omega⟩ ∧
        -- d is the greatest lower bound (infimum) of S_C:
        (∀ e : ExtendedCarrier N atomMap r, (∀ s ∈ S_C, e ≤ s) → e ≤ d) := by
    -- Construct d as the infimum of S_C (GHR93 d̄).
    -- Case split: does S_C have a carrier-point minimum?
    -- A carrier-point minimum p has extendPoint p ∈ S_C and extendPoint p ≤ all s ∈ S_C.
    by_cases h_has_pt_min : ∃ (p : N.carrier),
        (extendPoint p : ExtendedCarrier N atomMap r) ∈ S_C ∧
        ∀ s ∈ S_C, (extendPoint p : ExtendedCarrier N atomMap r) ≤ s
    · -- Point minimum case: d = extendPoint p
      obtain ⟨p, hp_in_SC, hp_lb⟩ := h_has_pt_min
      refine ⟨extendPoint p, ?_, hp_lb, hp_lb _ h_an_in_SC, ?_⟩
      · -- inClosedInterval x' y' (extendPoint p): follows from p ∈ S_C ⊆ [x',y']
        exact hp_in_SC.1
      · -- GLB: if e ≤ all s ∈ S_C, then e ≤ extendPoint p (since extendPoint p ∈ S_C)
        intro e he; exact he _ hp_in_SC
    · -- No carrier-point minimum. Sub-split on carrier-point GLB existence.
      push_neg at h_has_pt_min
      -- h_has_pt_min : ∀ p, extendPoint p ∈ S_C → ∃ s ∈ S_C, s < extendPoint p
      -- (i.e., no carrier point that's both IN S_C and ≤ all of S_C)
      have h_ne : S_C.Nonempty := continuation_set_nonempty hx'y'
      -- h_pt_below: ∃ carrier-point lower bound of S_C.
      have h_pt_below : ∃ p : N.carrier, ∀ s ∈ S_C,
          (extendPoint p : ExtendedCarrier N atomMap r) ≤ s := by
        rcases isPoint_or_isGap x' with ⟨px, hpx⟩ | ⟨gx, hgx⟩
        · refine ⟨px, fun s hs => ?_⟩; rw [show (extendPoint px : ExtendedCarrier N atomMap r) = x' from hpx.symm]; exact hs.1.1
        · obtain ⟨q, hq⟩ := gx.val.nonempty
          refine ⟨q, fun s hs => ?_⟩
          have hq_le_x' : (extendPoint q : ExtendedCarrier N atomMap r) ≤ x' := by
            rw [hgx]; exact (hq : q ∈ gx.val.cut)
          exact le_trans hq_le_x' hs.1.1
      -- 3-way case split: Case 2 (carrier-point GLB exists) vs Case 3 (no GLB).
      by_cases h_has_glb : ∃ (p : N.carrier),
          (∀ s ∈ S_C, (extendPoint p : ExtendedCarrier N atomMap r) ≤ s) ∧
          (∀ q : N.carrier, (∀ s ∈ S_C,
            (extendPoint q : ExtendedCarrier N atomMap r) ≤ s) →
            (extendPoint q : ExtendedCarrier N atomMap r) ≤ extendPoint p)
      · -- Case 2: Carrier-point GLB p exists but p ∉ S_C.
        -- d = extendPoint p is the infimum of S_C in the full extended order.
        obtain ⟨p, hp_lb, hp_greatest⟩ := h_has_glb
        -- p ∉ S_C: if extendPoint p ∈ S_C, h_has_pt_min gives ∃ s < extendPoint p,
        -- contradicting hp_lb.
        have hp_not_in : (extendPoint p : ExtendedCarrier N atomMap r) ∉ S_C := by
          intro hp_in
          obtain ⟨s, hs_in, hs_lt⟩ := h_has_pt_min p hp_in
          exact absurd (hp_lb s hs_in) (not_le.mpr hs_lt)
        refine ⟨extendPoint p, ?_, hp_lb, hp_lb _ h_an_in_SC, ?_⟩
        · -- inClosedInterval x' y' (extendPoint p):
          -- x' ≤ extendPoint p: In a linear order, either x' ≤ extendPoint p or
          -- extendPoint p < x'. If extendPoint p < x', then since x' ≤ s for all
          -- s ∈ S_C (from S_C ⊆ [x',y']), we have extendPoint p < x' ≤ s for all s.
          -- But x' itself is a lb of S_C. If x' is a point x' = extendPoint px,
          -- then px is a carrier-point lb with extendPoint p < extendPoint px,
          -- contradicting hp_greatest (since px would give extendPoint px ≤ extendPoint p).
          -- If x' is a gap, any q in x'.cut has extendPoint q ≤ x' ≤ s, so q is a
          -- carrier-point lb, hence extendPoint q ≤ extendPoint p. In particular
          -- x' has all its cut members ≤ p. But x' > extendPoint p means p is in x'.cut
          -- (since extendPoint p ≤ x' = gap means p ∈ cut). And the complement of
          -- x'.cut has no minimum, so there exist points above p still in the cut... wait.
          -- Actually: extendPoint p < x' means extendPoint p ≤ x'. If x' = Sum.inr gx,
          -- then extendPoint p ≤ Sum.inr gx means p ∈ gx.cut. So p is in the cut.
          -- p is the greatest carrier-point lb. All carrier-point lbs q have q ≤ p.
          -- gx.cut is downward-closed and contains p. Now: does gx.cut contain all
          -- q ≤ p? Yes (downward-closed). Does it contain anything above p? If not,
          -- then p is a maximum of gx.cut, but it's also in the cut, so it would be
          -- the LUB of gx.cut and in the cut — violating the gap no_sup axiom.
          -- So gx.cut must contain some q > p. But then extendPoint q ≤ Sum.inr gx ≤ s
          -- for all s ∈ S_C, making q a carrier-point lb with q > p, contradicting
          -- hp_greatest. Contradiction! So extendPoint p ≥ x'.
          constructor
          · by_contra h_lt
            push_neg at h_lt
            -- extendPoint p < x'
            rcases isPoint_or_isGap x' with ⟨px, hpx⟩ | ⟨gx, hgx⟩
            · -- x' is a point: px is a carrier-point lb above p
              have : (extendPoint px : ExtendedCarrier N atomMap r) ≤ extendPoint p := by
                apply hp_greatest
                intro s hs
                have : x' ≤ s := hs.1.1
                rw [hpx] at this; exact this
              rw [hpx] at h_lt
              exact absurd this (not_le.mpr h_lt)
            · -- x' is a gap gx. extendPoint p < x' means p ∈ gx.cut.
              rw [hgx] at h_lt
              have hp_in_cut : p ∈ gx.val.cut :=
                le_of_lt h_lt
              -- All carrier-point lbs q have extendPoint q ≤ extendPoint p, so q ≤ p.
              -- gx.cut is downward-closed and contains p. So gx.cut ⊇ {q : q ≤ p}.
              -- We show gx.cut ⊆ {q : q ≤ p}: if q ∈ gx.cut, then extendPoint q ≤ x',
              -- and x' ≤ s for all s ∈ S_C, so q is a carrier-point lb, hence q ≤ p.
              have h_cut_sub : ∀ q : N.carrier, q ∈ gx.val.cut → q ≤ p := by
                intro q hq_cut
                have hq_lb : ∀ s ∈ S_C, (extendPoint q : ExtendedCarrier N atomMap r) ≤ s := by
                  intro s hs
                  have : (extendPoint q : ExtendedCarrier N atomMap r) ≤ x' := by
                    rw [hgx]; exact hq_cut
                  exact le_trans this hs.1.1
                exact (extendPoint_le_iff q p).mp (hp_greatest q hq_lb)
              -- So p is a maximum of gx.cut: p ∈ gx.cut and ∀ q ∈ gx.cut, q ≤ p.
              -- This makes p an upper bound of gx.cut that's IN the cut,
              -- violating the gap's no_sup axiom.
              have h_p_lub : IsLUB gx.val.cut p ∧ p ∈ gx.val.cut :=
                ⟨⟨fun q hq => h_cut_sub q hq, fun _ hb => hb hp_in_cut⟩, hp_in_cut⟩
              exact absurd ⟨p, h_p_lub⟩ gx.val.no_sup
          · exact le_trans (hp_lb _ h_an_in_SC) (ha_bwd ⟨n, by omega⟩).2
        · -- GLB in full extended order: if e ≤ all s ∈ S_C, then e ≤ extendPoint p.
          -- For carrier-point e = extendPoint q: q is a carrier-point lb, so q ≤ p
          -- by hp_greatest, so e ≤ extendPoint p.
          -- For gap e = Sum.inr g: g's cut ⊆ {q : q is carrier-point lb of S_C} ⊆ {q : q ≤ p}.
          -- If p were in g.cut, then p is a maximum of g.cut (since g.cut ⊆ {q : q ≤ p}
          -- and p ∈ g.cut), violating g's no_sup axiom. So p ∉ g.cut, meaning
          -- Sum.inr g ≤ extendPoint p.
          intro e he
          rcases isPoint_or_isGap e with ⟨q, hq⟩ | ⟨g, hg⟩
          · -- e is a carrier point
            rw [hq]; exact hp_greatest q (fun s hs => by rw [show (extendPoint q : ExtendedCarrier N atomMap r) = e from hq.symm]; exact he s hs)
          · -- e is a gap g. Show Sum.inr g ≤ extendPoint p.
            rw [hg]
            -- g.cut ⊆ {q : q ≤ p}: if q ∈ g.cut, then extendPoint q ≤ Sum.inr g ≤ s
            -- for all s ∈ S_C, so q is a carrier-point lb, hence q ≤ p.
            have h_g_cut_sub : ∀ q : N.carrier, q ∈ g.val.cut → q ≤ p := by
              intro q hq_cut
              have hq_lb : ∀ s ∈ S_C, (extendPoint q : ExtendedCarrier N atomMap r) ≤ s := by
                intro s hs
                exact le_trans (show (extendPoint q : ExtendedCarrier N atomMap r) ≤ Sum.inr g from hq_cut)
                  (hg ▸ he s hs)
              exact (extendPoint_le_iff q p).mp (hp_greatest q hq_lb)
            -- Show p ∉ g.cut (otherwise p is max of g.cut, violating no_sup)
            by_contra h_not_le
            push_neg at h_not_le
            -- ¬(Sum.inr g ≤ extendPoint p) means extendPoint p < Sum.inr g,
            -- i.e., extendPoint p ≤ Sum.inr g, i.e., p ∈ g.cut
            have hp_in_g : p ∈ g.val.cut := le_of_lt h_not_le
            have h_p_lub : IsLUB g.val.cut p ∧ p ∈ g.val.cut :=
              ⟨⟨fun q hq => h_g_cut_sub q hq, fun _ hb => hb hp_in_g⟩, hp_in_g⟩
            exact absurd ⟨p, h_p_lub⟩ g.val.no_sup
      · -- Case 3: No carrier-point GLB. Construct d as a gap via infimum_gap.
        -- Step 3.1: Derive h_above (needed for inf_carrier_cut_proper).
        have h_above : ∃ (q : N.carrier) (s : ↥S_C),
            (extendPoint q : ExtendedCarrier N atomMap r) > s.val := by
          obtain ⟨s₀, hs₀⟩ := h_ne
          rcases isPoint_or_isGap s₀ with ⟨p₀, hp₀⟩ | ⟨g₀, hg₀⟩
          · -- s₀ is carrier point: h_has_pt_min gives t ∈ S_C with t < s₀
            have hs₀' : (extendPoint p₀ : ExtendedCarrier N atomMap r) ∈ S_C := by
              rw [show (extendPoint p₀ : ExtendedCarrier N atomMap r) = s₀ from hp₀.symm]; exact hs₀
            obtain ⟨t, ht_in, ht_lt⟩ := h_has_pt_min p₀ hs₀'
            exact ⟨p₀, ⟨t, ht_in⟩, ht_lt⟩
          · -- s₀ is a gap: use g₀.proper to find q ∉ g₀.cut
            have h_proper := g₀.val.proper
            rw [Set.ne_univ_iff_exists_not_mem] at h_proper
            obtain ⟨q, hq_not_in⟩ := h_proper
            have hq_ge : (extendPoint q : ExtendedCarrier N atomMap r) ≥ s₀ := hg₀ ▸ hq_not_in
            have hq_ne : (extendPoint q : ExtendedCarrier N atomMap r) ≠ s₀ := by
              rw [hg₀]; exact fun h => absurd h (by simp [extendPoint])
            exact ⟨q, ⟨s₀, hs₀⟩, lt_of_le_of_ne hq_ge (Ne.symm hq_ne)⟩
        -- Step 3.2: Construct the gap and package as RDefinableGap.
        set gamma := infimum_gap h_ne h_pt_below h_above h_has_glb with gamma_def
        -- Step 3.3: Three-way case split on boundary structure (GHR93 p.116).
        -- Key: does ∃ p₀ in the cut with x' ≤ extendPoint p₀?
        by_cases hx'_bound : ∃ p₀ : N.carrier,
            p₀ ∈ inf_carrier_cut S_C ∧
            x' ≤ (extendPoint p₀ : ExtendedCarrier N atomMap r)
        · -- hx'_bound: gamma strictly above x'. Second split on h_abv.
          by_cases h_abv : ∃ q₀ : N.carrier,
              q₀ ∉ inf_carrier_cut S_C ∧
              (extendPoint q₀ : ExtendedCarrier N atomMap r) < y' ∧
              x' ≤ (extendPoint q₀ : ExtendedCarrier N atomMap r)
          · -- Sub-case (b): r-definable gap. Apply infimum_gap_r_definable.
            have h_rdef := infimum_gap_r_definable hx'y'
              (ha_bwd ⟨n, by omega⟩) h_ne h_pt_below h_above h_has_glb
              hx'_bound h_abv
            have h_gamma_lb_pt : ∀ (ps : N.carrier),
                (extendPoint ps : ExtendedCarrier N atomMap r) ∈ S_C →
                ps ∉ gamma.cut := by
              intro ps hps h_in
              obtain ⟨s, hs_in, hs_lt⟩ := h_has_pt_min ps hps
              exact absurd ((h_in : ps ∈ inf_carrier_cut S_C) s hs_in) (not_le.mpr hs_lt)
            have h_gamma_lb_gap : ∀ (gs : RDefinableGap N atomMap r),
                (Sum.inr gs : ExtendedCarrier N atomMap r) ∈ S_C →
                gamma.cut ⊆ gs.val.cut := by
              intro gs hgs q hq; exact (hq : q ∈ inf_carrier_cut S_C) _ hgs
            refine ⟨Sum.inr ⟨gamma, h_rdef⟩, ⟨?_, ?_⟩, ?_, ?_, ?_⟩
            · -- x' ≤ d
              obtain ⟨p₀, hp₀_cut, hx'_le⟩ := hx'_bound
              exact le_trans hx'_le (hp₀_cut : p₀ ∈ inf_carrier_cut S_C)
            · -- d ≤ y': via d ≤ a_bwd(n) ≤ y'
              apply le_trans _ (ha_bwd ⟨n, by omega⟩).2
              match h_eq : a_bwd ⟨n, by omega⟩, h_an_in_SC with
              | Sum.inl pa, hs => exact h_gamma_lb_pt pa hs
              | Sum.inr ga, hs => exact h_gamma_lb_gap ga hs
            · -- ∀ s ∈ S_C, d ≤ s
              intro s hs; match s, hs with
              | Sum.inl ps, hs => exact h_gamma_lb_pt ps hs
              | Sum.inr gs, hs => exact h_gamma_lb_gap gs hs
            · -- d ≤ a_bwd(n)
              match h_eq : a_bwd ⟨n, by omega⟩, h_an_in_SC with
              | Sum.inl pa, hs => exact h_gamma_lb_pt pa hs
              | Sum.inr ga, hs => exact h_gamma_lb_gap ga hs
            · -- GLB: ∀ e, (∀ s ∈ S_C, e ≤ s) → e ≤ d
              intro e he; match e, he with
              | Sum.inl pe, he => exact he
              | Sum.inr ge, he =>
                intro q hq s hs
                exact le_trans (hq : (extendPoint q : ExtendedCarrier N atomMap r) ≤ Sum.inr ge) (he s hs)
          · -- Sub-case (c): gamma = y' (as gaps), d = y'.
            push_neg at h_abv
            have h_y'_gap : IsGap y' := by
              rcases isPoint_or_isGap y' with ⟨py', hpy'⟩ | hg
              · exfalso
                have hpy'_not_cut : py' ∉ gamma.cut := by
                  intro h_in
                  have h_y'_in_SC : (extendPoint py' : ExtendedCarrier N atomMap r) ∈ S_C := by
                    rw [show (extendPoint py' : ExtendedCarrier N atomMap r) = y' from hpy'.symm]
                    exact ⟨⟨hx'y', le_refl y'⟩, fun u hyu huy' _ => absurd (lt_trans hyu huy') (lt_irrefl _)⟩
                  obtain ⟨s, hs_in, hs_lt⟩ := h_has_pt_min py' h_y'_in_SC
                  exact absurd ((h_in : py' ∈ inf_carrier_cut S_C) s hs_in) (not_le.mpr hs_lt)
                have : ¬ (∀ q, q ∉ gamma.cut → py' ≤ q) :=
                  fun h => gamma.complement_no_min ⟨py', hpy'_not_cut, h⟩
                push_neg at this
                obtain ⟨q', hq'_not_cut, hq'_lt⟩ := this
                obtain ⟨p₀, hp₀_cut, hx'_le_p₀⟩ := hx'_bound
                have hq'_lt_y' : (extendPoint q' : ExtendedCarrier N atomMap r) < y' := by
                  rw [hpy']; exact (extendPoint_lt_iff q' py').mpr hq'_lt
                have hq'_lt_x' := h_abv q' (hq'_not_cut : q' ∉ inf_carrier_cut S_C) hq'_lt_y'
                have : ¬ (q' ≤ p₀) := fun h => hq'_not_cut (gamma.downward_closed p₀ q' hp₀_cut h)
                have hx'_le_q' := le_trans hx'_le_p₀
                  ((extendPoint_le_iff p₀ q').mpr (le_of_lt (not_le.mp this)))
                exact absurd hx'_le_q' (not_le.mpr hq'_lt_x')
              · exact hg
            obtain ⟨gy', hgy'⟩ := h_y'_gap
            have h_cut_eq : gamma.cut = gy'.val.cut := by
              ext q; constructor
              · intro hq
                have h1 := (hq : q ∈ inf_carrier_cut S_C) _ h_an_in_SC
                have h2 := (ha_bwd ⟨n, by omega⟩).2
                rw [hgy'] at h2; exact le_trans h1 h2
              · intro hq; by_contra hq_not
                obtain ⟨p₀, hp₀_cut, hx'_le_p₀⟩ := hx'_bound
                have hq_lt_y' : (extendPoint q : ExtendedCarrier N atomMap r) < y' := by
                  rw [hgy']; exact ⟨hq, fun h => absurd hq h⟩
                have hq_lt_x' := h_abv q (hq_not : q ∉ inf_carrier_cut S_C) hq_lt_y'
                have : ¬ (q ≤ p₀) := fun h => hq_not (gamma.downward_closed p₀ q hp₀_cut h)
                have hx'_le_q := le_trans hx'_le_p₀
                  ((extendPoint_le_iff p₀ q).mpr (le_of_lt (not_le.mp this)))
                exact absurd hx'_le_q (not_le.mpr hq_lt_x')
            refine ⟨y', ⟨hx'y', le_refl y'⟩, ?_, ?_, ?_⟩
            · -- ∀ s ∈ S_C, y' ≤ s
              intro s hs; match s, hs with
              | Sum.inl ps, hs =>
                rw [hgy']
                have : ps ∉ gamma.cut := by
                  intro h_in; obtain ⟨t, ht_in, ht_lt⟩ := h_has_pt_min ps hs
                  exact absurd ((h_in : ps ∈ inf_carrier_cut S_C) t ht_in) (not_le.mpr ht_lt)
                rwa [h_cut_eq] at this
              | Sum.inr gs, hs =>
                rw [hgy']; intro q hq; rw [← h_cut_eq] at hq
                exact (hq : q ∈ inf_carrier_cut S_C) _ hs
            · -- y' ≤ a_bwd(n)
              match h_eq : a_bwd ⟨n, by omega⟩, h_an_in_SC with
              | Sum.inl pa, hs =>
                rw [hgy']
                have : pa ∉ gamma.cut := by
                  intro h_in; obtain ⟨t, ht_in, ht_lt⟩ := h_has_pt_min pa hs
                  exact absurd ((h_in : pa ∈ inf_carrier_cut S_C) t ht_in) (not_le.mpr ht_lt)
                rwa [h_cut_eq] at this
              | Sum.inr ga, hs =>
                rw [hgy']; intro q hq; rw [← h_cut_eq] at hq
                exact (hq : q ∈ inf_carrier_cut S_C) _ hs
            · -- GLB
              intro e he; exact le_trans (he _ h_an_in_SC) (ha_bwd ⟨n, by omega⟩).2
        · -- ¬hx'_bound: gamma = x' (as gaps), d = x'.
          push_neg at hx'_bound
          have hx'_gap : IsGap x' := by
            rcases isPoint_or_isGap x' with ⟨px', hpx'⟩ | hg
            · exfalso
              have h_px'_cut : px' ∈ inf_carrier_cut S_C := by
                intro s hs
                rw [show (extendPoint px' : ExtendedCarrier N atomMap r) = x' from hpx'.symm]
                exact hs.1.1
              exact absurd (hx'_bound px' h_px'_cut) (not_lt.mpr (hpx' ▸ le_refl _))
            · exact hg
          obtain ⟨gx', hgx'⟩ := hx'_gap
          have h_cut_eq : gamma.cut = gx'.val.cut := by
            ext q; constructor
            · intro hq; by_contra h_not_in
              exact absurd (hx'_bound q hq) (not_lt.mpr
                (show x' ≤ (extendPoint q : ExtendedCarrier N atomMap r) by rw [hgx']; exact h_not_in))
            · intro hq s hs
              exact le_trans
                (show (extendPoint q : ExtendedCarrier N atomMap r) ≤ x' by rw [hgx']; exact hq) hs.1.1
          refine ⟨x', ⟨le_refl _, hx'y'⟩, ?_, (ha_bwd ⟨n, by omega⟩).1, ?_⟩
          · intro s hs; exact hs.1.1
          · intro e he
            rcases isPoint_or_isGap e with ⟨pe, hpe⟩ | ⟨ge, hge⟩
            · rw [hpe, hgx']
              have hmem : pe ∈ gamma.cut := by rw [hpe] at he; exact he
              rw [h_cut_eq] at hmem; exact hmem
            · rw [hge, hgx']
              have hmem : ge.val.cut ⊆ gamma.cut := by
                intro q hq; rw [hge] at he
                intro s hs
                exact le_trans
                  (hq : (extendPoint q : ExtendedCarrier N atomMap r) ≤ Sum.inr ge) (he s hs)
              intro q hq; exact (h_cut_eq ▸ hmem hq : q ∈ gx'.val.cut)
  -- Step 2: Construct c = inf(S_C^M) — the M-side infimum (GHR93 p.115-116).
  -- S_C^M = { t ∈ [x,y] : cont_holds_cross at all mu-points in (t, y) in M }.
  -- The continuation predicate uses N-side interval type (a_bwd(n), y') but
  -- evaluates truth in M. This mirrors d = inf(S_C^N) exactly.
  set S_C_M := continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y' with S_C_M_def
  have h_y_in_SC_M : y ∈ S_C_M := by
    refine ⟨⟨hxy, le_refl y⟩, ?_⟩
    intro u hyu huy _
    exact absurd (lt_trans hyu huy) (lt_irrefl y)
  obtain ⟨c_inf, hc_inf_interval, hc_inf_glb, hc_inf_is_inf⟩ :
      ∃ c_inf : ExtendedCarrier M atomMap r,
        inClosedInterval x y c_inf ∧
        (∀ s ∈ S_C_M, c_inf ≤ s) ∧
        (∀ e : ExtendedCarrier M atomMap r, (∀ s ∈ S_C_M, e ≤ s) → e ≤ c_inf) := by
    -- Mirror the d = inf(S_C^N) construction (3-way case split).
    by_cases h_has_pt_min_M : ∃ (p : M.carrier),
        (extendPoint p : ExtendedCarrier M atomMap r) ∈ S_C_M ∧
        ∀ s ∈ S_C_M, (extendPoint p : ExtendedCarrier M atomMap r) ≤ s
    · -- Case 1: Carrier-point minimum exists.
      obtain ⟨p, hp_in, hp_lb⟩ := h_has_pt_min_M
      exact ⟨extendPoint p, hp_in.1, hp_lb, fun e he => he _ hp_in⟩
    · push_neg at h_has_pt_min_M
      -- h_has_pt_min_M : ∀ p, extendPoint p ∈ S_C_M → ∃ s ∈ S_C_M, s < extendPoint p
      have h_ne_M : S_C_M.Nonempty := ⟨y, h_y_in_SC_M⟩
      have h_pt_below_M : ∃ p : M.carrier, ∀ s ∈ S_C_M,
          (extendPoint p : ExtendedCarrier M atomMap r) ≤ s := by
        rcases isPoint_or_isGap x with ⟨px, hpx⟩ | ⟨gx, hgx⟩
        · refine ⟨px, fun s hs => ?_⟩
          rw [show (extendPoint px : ExtendedCarrier M atomMap r) = x from hpx.symm]
          exact hs.1.1
        · obtain ⟨q, hq⟩ := gx.val.nonempty
          refine ⟨q, fun s hs => ?_⟩
          have hq_le_x : (extendPoint q : ExtendedCarrier M atomMap r) ≤ x := by
            rw [hgx]; exact (hq : q ∈ gx.val.cut)
          exact le_trans hq_le_x hs.1.1
      by_cases h_has_glb_M : ∃ (p : M.carrier),
          (∀ s ∈ S_C_M, (extendPoint p : ExtendedCarrier M atomMap r) ≤ s) ∧
          (∀ q : M.carrier, (∀ s ∈ S_C_M,
            (extendPoint q : ExtendedCarrier M atomMap r) ≤ s) →
            (extendPoint q : ExtendedCarrier M atomMap r) ≤ extendPoint p)
      · -- Case 2: Carrier-point GLB p exists but p ∉ S_C_M.
        obtain ⟨p, hp_lb, hp_greatest⟩ := h_has_glb_M
        have hp_not_in : (extendPoint p : ExtendedCarrier M atomMap r) ∉ S_C_M := by
          intro hp_in
          obtain ⟨s, hs_in, hs_lt⟩ := h_has_pt_min_M p hp_in
          exact absurd (hp_lb s hs_in) (not_le.mpr hs_lt)
        refine ⟨extendPoint p, ?_, hp_lb, ?_⟩
        · constructor
          · by_contra h_lt
            push_neg at h_lt
            rcases isPoint_or_isGap x with ⟨px, hpx⟩ | ⟨gx, hgx⟩
            · have : (extendPoint px : ExtendedCarrier M atomMap r) ≤ extendPoint p := by
                apply hp_greatest
                intro s hs
                have : x ≤ s := hs.1.1
                rw [hpx] at this; exact this
              rw [hpx] at h_lt
              exact absurd this (not_le.mpr h_lt)
            · rw [hgx] at h_lt
              have hp_in_cut : p ∈ gx.val.cut := le_of_lt h_lt
              have h_cut_sub : ∀ q : M.carrier, q ∈ gx.val.cut → q ≤ p := by
                intro q hq_cut
                have hq_lb : ∀ s ∈ S_C_M, (extendPoint q : ExtendedCarrier M atomMap r) ≤ s := by
                  intro s hs
                  have : (extendPoint q : ExtendedCarrier M atomMap r) ≤ x := by
                    rw [hgx]; exact hq_cut
                  exact le_trans this hs.1.1
                exact (extendPoint_le_iff q p).mp (hp_greatest q hq_lb)
              have h_p_lub : IsLUB gx.val.cut p ∧ p ∈ gx.val.cut :=
                ⟨⟨fun q hq => h_cut_sub q hq, fun _ hb => hb hp_in_cut⟩, hp_in_cut⟩
              exact absurd ⟨p, h_p_lub⟩ gx.val.no_sup
          · exact le_trans (hp_lb _ h_y_in_SC_M) h_y_in_SC_M.1.2
        · intro e he
          rcases isPoint_or_isGap e with ⟨q, hq⟩ | ⟨g, hg⟩
          · rw [hq]; exact hp_greatest q (fun s hs => by rw [show (extendPoint q : ExtendedCarrier M atomMap r) = e from hq.symm]; exact he s hs)
          · rw [hg]
            have h_g_cut_sub : ∀ q : M.carrier, q ∈ g.val.cut → q ≤ p := by
              intro q hq_cut
              have hq_lb : ∀ s ∈ S_C_M, (extendPoint q : ExtendedCarrier M atomMap r) ≤ s := by
                intro s hs
                exact le_trans (show (extendPoint q : ExtendedCarrier M atomMap r) ≤ Sum.inr g from hq_cut)
                  (hg ▸ he s hs)
              exact (extendPoint_le_iff q p).mp (hp_greatest q hq_lb)
            by_contra h_not_le
            push_neg at h_not_le
            have hp_in_g : p ∈ g.val.cut := le_of_lt h_not_le
            have h_p_lub : IsLUB g.val.cut p ∧ p ∈ g.val.cut :=
              ⟨⟨fun q hq => h_g_cut_sub q hq, fun _ hb => hb hp_in_g⟩, hp_in_g⟩
            exact absurd ⟨p, h_p_lub⟩ g.val.no_sup
      · -- Case 3: No carrier-point GLB. Construct c_inf as a gap (mirrors N-side Case 3).
        -- Step 3.1: Derive h_above_M.
        have h_above_M : ∃ (q : M.carrier) (s : ↥S_C_M),
            (extendPoint q : ExtendedCarrier M atomMap r) > s.val := by
          obtain ⟨s₀, hs₀⟩ := h_ne_M
          rcases isPoint_or_isGap s₀ with ⟨p₀, hp₀⟩ | ⟨g₀, hg₀⟩
          · have hs₀' : (extendPoint p₀ : ExtendedCarrier M atomMap r) ∈ S_C_M := by
              rw [show (extendPoint p₀ : ExtendedCarrier M atomMap r) = s₀ from hp₀.symm]; exact hs₀
            obtain ⟨t, ht_in, ht_lt⟩ := h_has_pt_min_M p₀ hs₀'
            exact ⟨p₀, ⟨t, ht_in⟩, ht_lt⟩
          · have h_proper := g₀.val.proper
            rw [Set.ne_univ_iff_exists_not_mem] at h_proper
            obtain ⟨q, hq_not_in⟩ := h_proper
            have hq_ge : (extendPoint q : ExtendedCarrier M atomMap r) ≥ s₀ := hg₀ ▸ hq_not_in
            have hq_ne : (extendPoint q : ExtendedCarrier M atomMap r) ≠ s₀ := by
              rw [hg₀]; exact fun h => absurd h (by simp [extendPoint])
            exact ⟨q, ⟨s₀, hs₀⟩, lt_of_le_of_ne hq_ge (Ne.symm hq_ne)⟩
        -- Step 3.2: Construct the gap.
        set gamma_M := infimum_gap h_ne_M h_pt_below_M h_above_M h_has_glb_M with gamma_M_def
        -- Step 3.3: Three-way case split (mirror of N-side).
        by_cases hx_bound : ∃ p₀ : M.carrier,
            p₀ ∈ inf_carrier_cut S_C_M ∧
            x ≤ (extendPoint p₀ : ExtendedCarrier M atomMap r)
        · -- hx_bound: gamma_M strictly above x.
          -- Further split: is there a carrier point above the gap and strictly below y?
          by_cases h_abv_M : ∃ q₀ : M.carrier,
              q₀ ∉ inf_carrier_cut S_C_M ∧
              (extendPoint q₀ : ExtendedCarrier M atomMap r) < y ∧
              x ≤ (extendPoint q₀ : ExtendedCarrier M atomMap r)
          · -- Sub-case (b): r-definable gap. Apply infimum_gap_r_definable_cross.
            have h_rdef := infimum_gap_r_definable_cross hxy
              h_ne_M h_pt_below_M h_above_M h_has_glb_M
              hx_bound h_abv_M
            have h_gamma_lb_pt : ∀ (ps : M.carrier),
                (extendPoint ps : ExtendedCarrier M atomMap r) ∈ S_C_M →
                ps ∉ gamma_M.cut := by
              intro ps hps h_in
              obtain ⟨s, hs_in, hs_lt⟩ := h_has_pt_min_M ps hps
              exact absurd ((h_in : ps ∈ inf_carrier_cut S_C_M) s hs_in) (not_le.mpr hs_lt)
            have h_gamma_lb_gap : ∀ (gs : RDefinableGap M atomMap r),
                (Sum.inr gs : ExtendedCarrier M atomMap r) ∈ S_C_M →
                gamma_M.cut ⊆ gs.val.cut := by
              intro gs hgs q hq; exact (hq : q ∈ inf_carrier_cut S_C_M) _ hgs
            refine ⟨Sum.inr ⟨gamma_M, h_rdef⟩, ⟨?_, ?_⟩, ?_, ?_⟩
            · -- x ≤ c_inf
              obtain ⟨p₀, hp₀_cut, hx_le⟩ := hx_bound
              exact le_trans hx_le (hp₀_cut : p₀ ∈ inf_carrier_cut S_C_M)
            · -- c_inf ≤ y: via c_inf ≤ y (y ∈ S_C_M)
              match h_eq : y, h_y_in_SC_M with
              | Sum.inl py, hy => exact h_gamma_lb_pt py hy
              | Sum.inr gy, hy => exact h_gamma_lb_gap gy hy
            · -- ∀ s ∈ S_C_M, c_inf ≤ s
              intro s hs; match s, hs with
              | Sum.inl ps, hs => exact h_gamma_lb_pt ps hs
              | Sum.inr gs, hs => exact h_gamma_lb_gap gs hs
            · -- GLB: ∀ e, (∀ s ∈ S_C_M, e ≤ s) → e ≤ c_inf
              intro e he; match e, he with
              | Sum.inl pe, he => exact he
              | Sum.inr ge, he =>
                intro q hq s hs
                exact le_trans (hq : (extendPoint q : ExtendedCarrier M atomMap r) ≤ Sum.inr ge) (he s hs)
          · -- Sub-case (c): gamma_M = y (as gaps), c_inf = y.
            push_neg at h_abv_M
            have h_y_gap : IsGap y := by
              rcases isPoint_or_isGap y with ⟨py, hpy⟩ | hg
              · exfalso
                have hpy_not_cut : py ∉ gamma_M.cut := by
                  intro h_in
                  have h_y_in_SC' : (extendPoint py : ExtendedCarrier M atomMap r) ∈ S_C_M := by
                    rw [show (extendPoint py : ExtendedCarrier M atomMap r) = y from hpy.symm]
                    exact h_y_in_SC_M
                  obtain ⟨s, hs_in, hs_lt⟩ := h_has_pt_min_M py h_y_in_SC'
                  exact absurd ((h_in : py ∈ inf_carrier_cut S_C_M) s hs_in) (not_le.mpr hs_lt)
                have : ¬ (∀ q, q ∉ gamma_M.cut → py ≤ q) :=
                  fun h => gamma_M.complement_no_min ⟨py, hpy_not_cut, h⟩
                push_neg at this
                obtain ⟨q', hq'_not_cut, hq'_lt⟩ := this
                obtain ⟨p₀, hp₀_cut, hx_le_p₀⟩ := hx_bound
                have hq'_lt_y : (extendPoint q' : ExtendedCarrier M atomMap r) < y := by
                  rw [hpy]; exact (extendPoint_lt_iff q' py).mpr hq'_lt
                have hq'_lt_x := h_abv_M q' (hq'_not_cut : q' ∉ inf_carrier_cut S_C_M) hq'_lt_y
                have : ¬ (q' ≤ p₀) := fun h => hq'_not_cut (gamma_M.downward_closed p₀ q' hp₀_cut h)
                have hx_le_q' := le_trans hx_le_p₀
                  ((extendPoint_le_iff p₀ q').mpr (le_of_lt (not_le.mp this)))
                exact absurd hx_le_q' (not_le.mpr hq'_lt_x)
              · exact hg
            obtain ⟨gy, hgy⟩ := h_y_gap
            have h_cut_eq_M' : gamma_M.cut = gy.val.cut := by
              ext q; constructor
              · intro hq
                have h1 := (hq : q ∈ inf_carrier_cut S_C_M) _ h_y_in_SC_M
                rw [hgy] at h1; exact h1
              · intro hq; by_contra hq_not
                obtain ⟨p₀, hp₀_cut, hx_le_p₀⟩ := hx_bound
                have hq_lt_y : (extendPoint q : ExtendedCarrier M atomMap r) < y := by
                  rw [hgy]; exact ⟨hq, fun h => absurd hq h⟩
                have hq_lt_x := h_abv_M q (hq_not : q ∉ inf_carrier_cut S_C_M) hq_lt_y
                have : ¬ (q ≤ p₀) := fun h => hq_not (gamma_M.downward_closed p₀ q hp₀_cut h)
                have hx_le_q := le_trans hx_le_p₀
                  ((extendPoint_le_iff p₀ q).mpr (le_of_lt (not_le.mp this)))
                exact absurd hx_le_q (not_le.mpr hq_lt_x)
            refine ⟨y, ⟨hxy, le_refl y⟩, ?_, ?_⟩
            · -- ∀ s ∈ S_C_M, y ≤ s
              intro s hs; match s, hs with
              | Sum.inl ps, hs =>
                rw [hgy]
                have : ps ∉ gamma_M.cut := by
                  intro h_in; obtain ⟨t, ht_in, ht_lt⟩ := h_has_pt_min_M ps hs
                  exact absurd ((h_in : ps ∈ inf_carrier_cut S_C_M) t ht_in) (not_le.mpr ht_lt)
                rwa [h_cut_eq_M'] at this
              | Sum.inr gs, hs =>
                rw [hgy]; intro q hq; rw [← h_cut_eq_M'] at hq
                exact (hq : q ∈ inf_carrier_cut S_C_M) _ hs
            · -- GLB
              intro e he; exact he _ h_y_in_SC_M
        · -- ¬hx_bound: gamma_M = x (as gaps), c_inf = x.
          push_neg at hx_bound
          have hx_gap : IsGap x := by
            rcases isPoint_or_isGap x with ⟨px, hpx⟩ | hg
            · exfalso
              have h_px_cut : px ∈ inf_carrier_cut S_C_M := by
                intro s hs
                rw [show (extendPoint px : ExtendedCarrier M atomMap r) = x from hpx.symm]
                exact hs.1.1
              exact absurd (hx_bound px h_px_cut) (not_lt.mpr (hpx ▸ le_refl _))
            · exact hg
          obtain ⟨gx, hgx⟩ := hx_gap
          have h_cut_eq_M : gamma_M.cut = gx.val.cut := by
            ext q; constructor
            · intro hq; by_contra h_not_in
              exact absurd (hx_bound q hq) (not_lt.mpr
                (show x ≤ (extendPoint q : ExtendedCarrier M atomMap r) by rw [hgx]; exact h_not_in))
            · intro hq s hs
              exact le_trans
                (show (extendPoint q : ExtendedCarrier M atomMap r) ≤ x by rw [hgx]; exact hq) hs.1.1
          refine ⟨x, ⟨le_refl _, hxy⟩, ?_, ?_⟩
          · intro s hs; exact hs.1.1
          · intro e he
            rcases isPoint_or_isGap e with ⟨pe, hpe⟩ | ⟨ge, hge⟩
            · rw [hpe, hgx]
              have hmem : pe ∈ gamma_M.cut := by rw [hpe] at he; exact he
              rw [h_cut_eq_M] at hmem; exact hmem
            · rw [hge, hgx]
              have hmem : ge.val.cut ⊆ gamma_M.cut := by
                intro q hq; rw [hge] at he
                intro s hs
                exact le_trans
                  (hq : (extendPoint q : ExtendedCarrier M atomMap r) ≤ Sum.inr ge) (he s hs)
              intro q hq; exact (h_cut_eq_M ▸ hmem hq : q ∈ gx.val.cut)
  -- c_inf ∈ S_C^M: for any mu u > c_inf in M, u is not a lower bound of S_C^M,
  -- so ∃ s ∈ S_C^M with s < u, giving cont_holds_cross at u from s's tail.
  have hc_inf_in_SC_M : c_inf ∈ S_C_M := by
    refine ⟨hc_inf_interval, ?_⟩
    intro u hcu huy hmu
    have : ¬ (∀ s ∈ S_C_M, u ≤ s) := by
      intro h_lb
      exact absurd (hc_inf_is_inf u h_lb) (not_le.mpr hcu)
    push_neg at this
    obtain ⟨s₀, hs₀_in, hs₀_lt⟩ := this
    exact hs₀_in.2 u hs₀_lt huy hmu
  -- Cofinal cont_holds_cross failure below c_inf: for any s ∈ [x, y] with s < c_inf,
  -- ∃ mu-point u in M with s < u ≤ c_inf, u < y, and ¬cont_holds_cross at u.
  have h_cofinal_failure_below_c_inf :
      ∀ (s : ExtendedCarrier M atomMap r),
        inClosedInterval x y s → s < c_inf →
        ∃ (u : ExtendedCarrier M atomMap r),
          s < u ∧ u ≤ c_inf ∧ u < y ∧
          mu_holds u ∧ ¬ cont_holds_cross (a_bwd ⟨n, by omega⟩) y' u := by
    intro s hs_interval hs_lt_c
    have hs_not_SC_M : s ∉ S_C_M := by
      intro hs_in; exact absurd (hc_inf_glb s hs_in) (not_le.mpr hs_lt_c)
    have : ¬ (∀ u : ExtendedCarrier M atomMap r,
        s < u → u < y → mu_holds u →
        cont_holds_cross (a_bwd ⟨n, by omega⟩) y' u) := by
      intro h_all; exact hs_not_SC_M ⟨hs_interval, h_all⟩
    push_neg at this
    obtain ⟨v, hsv, hvy, hmu_v, h_not_cont_v⟩ := this
    rcases le_or_gt v c_inf with hv_le_c | hv_gt_c
    · exact ⟨v, hsv, hv_le_c, hvy, hmu_v, h_not_cont_v⟩
    · exact absurd (hc_inf_in_SC_M.2 v hv_gt_c hvy hmu_v) h_not_cont_v
  -- Step 3: Get a 1-round forward strategy for game-based properties.
  have h1 : ghr93_duplicator_wins M N atomMap 1 r x y x' y' :=
    ghr93_duplicator_wins_round_mono (by omega : 1 ≤ 4 + 3 * n) hxy hx'y' h_fwd
  -- Step 4-5: Prove c satisfies the suffices requirements.
  -- c = inf(S_C^M) has interval and infimum properties.
  -- Formula agreement, gap/point, and boundary correspondence require
  -- the game to connect c (M-side infimum) with d (N-side infimum).
  suffices h_exists : ∃ c : ExtendedCarrier M atomMap r,
      inClosedInterval x y c ∧
      (∀ (A : StaviFormula), stavi_depth A ≤ r →
        (stavi_temporal_truth_mu M atomMap r c A ↔
         stavi_temporal_truth_mu N atomMap r d A)) ∧
      ((IsPoint c ↔ IsPoint d) ∧ (IsGap c ↔ IsGap d)) ∧
      -- Boundary order correspondence: c's position relative to x,y
      -- mirrors d's position relative to x',y'. This is essential for
      -- the degenerate interval cases (x'=d or d=y') where we need to
      -- derive x=c or c=y to apply ghr93_duplicator_wins_degenerate_gap.
      ((x = c ↔ x' = d) ∧ (c = y ↔ d = y')) ∧
      -- GHR93 Claim 1 interior: for the left boundary (a_pad ends with c),
      -- a response exists with d at position 1+3n. Proved inside suffices
      -- where c = c_inf gives access to the K⁻(¬D) argument at rank r+2.
      (x' ≠ d → d ≠ y' →
        ∀ (a_pad : Fin (1 + 3 * n + 1) → ExtendedCarrier M atomMap r),
          (∀ i, inClosedInterval x y (a_pad i)) →
          a_pad ⟨1 + 3 * n, by omega⟩ = c →
          ∃ (a'_full : Fin (1 + 3 * n + 1) → ExtendedCarrier N atomMap r),
            (∀ i, inClosedInterval x' y' (a'_full i)) ∧
            (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
              ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
                ghr93_winning_condition (1 + 3 * n + 1)
                  (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) ∧
            a'_full ⟨1 + 3 * n, by omega⟩ = d) ∧
      -- GHR93 Claim 1 interior: for the right boundary (a_pad starts with c),
      -- a response exists with d at position 0.
      (x' ≠ d → d ≠ y' →
        ∀ (a_pad : Fin (1 + 3 * n + 1) → ExtendedCarrier M atomMap r),
          (∀ i, inClosedInterval x y (a_pad i)) →
          a_pad ⟨0, by omega⟩ = c →
          ∃ (a'_full : Fin (1 + 3 * n + 1) → ExtendedCarrier N atomMap r),
            (∀ i, inClosedInterval x' y' (a'_full i)) ∧
            (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
              ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
                ghr93_winning_condition (1 + 3 * n + 1)
                  (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) ∧
            a'_full ⟨0, by omega⟩ = d) by
    obtain ⟨c, hc_interval, hcd_form, hcd_gp, hcd_boundary,
            h_interior_d_left_from_suffices, h_interior_d_right_from_suffices⟩ := h_exists
    refine ⟨c, d, ?_⟩
    -- Step 4-5: Apply strategy restriction + IH to get sigma and tau
    -- Forward strategy: (4+3n) rounds on [x,y] vs [x',y']
    -- By round_mono: (n+2) rounds on [x,y] (since n+2 ≤ 4+3n for n ≥ 0)
    -- By strategy_restrict_left: (n+1) rounds on [x,c] vs [x',d]
    -- By round_mono: (1+3n) rounds on [x,c] vs [x',d] (since 1+3n ≤ n+1+... wait)
    --
    -- Actually: we need (1+3n) rounds on the sub-interval for the IH.
    -- strategy_restrict consumes 1 round: (k+1) → k on sub-interval.
    -- So we need at least (2+3n) rounds on the full interval.
    -- We have (4+3n) rounds. By round_mono: (2+3n) rounds.
    -- By strategy_restrict: (1+3n) rounds on sub-interval. OK.
    have h_mono_left : ghr93_duplicator_wins M N atomMap (1 + 3 * n + 1) r x y x' y' :=
      ghr93_duplicator_wins_round_mono (by omega : 1 + 3 * n + 1 ≤ 4 + 3 * n) hxy hx'y' h_fwd
    have h_mono_left_r1 : ghr93_duplicator_wins M N atomMap (1 + 3 * n + 1) (r + 2)
        (rank_embed (by omega : r ≤ r + 2) x) (rank_embed (by omega : r ≤ r + 2) y)
        (rank_embed (by omega : r ≤ r + 2) x') (rank_embed (by omega : r ≤ r + 2) y') :=
      ghr93_duplicator_wins_round_mono (by omega : 1 + 3 * n + 1 ≤ 4 + 3 * n)
        ((rank_embed_le (by omega : r ≤ r + 2) x y).mpr hxy)
        ((rank_embed_le (by omega : r ≤ r + 2) x' y').mpr hx'y') h_fwd_r1
    -- D-consistency (existential form) and strategy restriction.
    -- d_consistency_left/right provide: for any padded selection ending/starting
    -- with c, there EXISTS a response with bounds + winning + d at boundary.
    -- ghr93_strategy_restrict_left/right consume this directly.
    -- GHR93 Claim 1: d is uniquely determined among elements with the same
    -- rank-r type, gap/point status, and boundary position.
    -- This follows from the infimum construction of d and the rank-(r+2)
    -- forward strategy (h_fwd_r1). The proof requires constructing the
    -- rank-(r+2) formula K⁻(¬D) = neg(std_snce(neg(base .bot), D)) where
    -- D is the pigeonhole formula with stavi_depth D ≤ r. The formula
    -- K⁻(¬D) has depth r+2 (within the rank budget after the r+1→r+2 bump).
    -- Key fact: d ∈ S_C (tail condition from GLB property).
    have hd_in_SC : d ∈ S_C := by
      refine ⟨hd_interval, ?_⟩
      intro u hdu huy' hmu
      have : ¬ (∀ s ∈ S_C, u ≤ s) := by
        intro h_lb
        exact absurd (hd_is_inf u h_lb) (not_le.mpr hdu)
      push_neg at this
      obtain ⟨s₀, hs₀_in, hs₀_lt⟩ := this
      exact hs₀_in.2 u hs₀_lt huy' hmu
    -- Cofinal failure below d: for any element s ∈ [x', y'] with s < d,
    -- there exists a mu-point u with s < u ≤ d, u < y', where
    -- cont_holds fails. This follows from s ∉ S_C (since d = inf(S_C))
    -- and d ∈ S_C (which rules out failures above d).
    have h_cofinal_failure_below_d :
        ∀ (s : ExtendedCarrier N atomMap r),
          inClosedInterval x' y' s → s < d →
          ∃ (u : ExtendedCarrier N atomMap r),
            s < u ∧ u ≤ d ∧ u < y' ∧
            mu_holds u ∧ ¬ cont_holds (a_bwd ⟨n, by omega⟩) y' u := by
      intro s hs_interval hs_lt_d
      -- s < d = inf(S_C), so s ∉ S_C
      have hs_not_SC : s ∉ S_C := by
        intro hs_in; exact absurd (hd_glb s hs_in) (not_le.mpr hs_lt_d)
      -- s ∈ [x', y'] and s ∉ S_C: tail condition fails
      have : ¬ (∀ u : ExtendedCarrier N atomMap r,
          s < u → u < y' → mu_holds u →
          cont_holds (a_bwd ⟨n, by omega⟩) y' u) := by
        intro h_all; exact hs_not_SC ⟨hs_interval, h_all⟩
      push_neg at this
      obtain ⟨v, hsv, hvy', hmu_v, h_not_cont_v⟩ := this
      -- v is a mu-point with s < v < y' and ¬cont_holds at v.
      -- Show v ≤ d: if v > d, then v ∈ (d, y') and d ∈ S_C gives
      -- cont_holds at v, contradicting h_not_cont_v.
      rcases le_or_gt v d with hv_le_d | hv_gt_d
      · exact ⟨v, hsv, hv_le_d, hvy', hmu_v, h_not_cont_v⟩
      · -- v > d: contradiction from d ∈ S_C
        exact absurd (hd_in_SC.2 v hv_gt_d hvy' hmu_v) h_not_cont_v
    -- GHR93 Claim 1 interior case: use rank_down(h_mono_left_r1) to construct
    -- responses where the boundary position equals d. This replaces the
    -- mathematically false h_d_unique universal claim.
    -- The proof uses ghr93_duplicator_wins_rank_down which projects rank r+2
    -- responses to rank r. The key property is that all projected responses
    -- come from the rank r+2 game, so the position corresponding to c
    -- (mapped to rank_embed(c) at rank r+2) gets a response that projects to d.
    -- GHR93 Claim 1 interior case (left/right):
    -- Construct response with position n = d (left) or position 0 = d (right).
    -- The proof inlines ghr93_duplicator_wins_rank_down's construction:
    -- embed Spoiler's selection to rank r+2, play through h_mono_left_r1,
    -- project responses back. The K⁻(¬D) argument (already proved in the
    -- Claim 1 block below) shows the rank r+2 response at the boundary
    -- position equals rank_embed(d), so the projection gives d.
    -- GHR93 Claim 1 interior case: proved in the suffices block where c = c_inf
    -- gives access to the full K⁻(¬D) argument at rank r+2.
    have h_interior_d_left := h_interior_d_left_from_suffices
    have h_interior_d_right := h_interior_d_right_from_suffices
    have h_d_consistent_left :=
      d_consistency_left hxy hx'y' hc_interval hd_interval
        hcd_form hcd_gp hcd_boundary h_mono_left h_mono_left_r1 h_pt h_interior_d_left
    have h_d_consistent_right :=
      d_consistency_right hxy hx'y' hc_interval hd_interval
        hcd_form hcd_gp hcd_boundary h_mono_left h_mono_left_r1 h_pt h_interior_d_right
    have h_restrict_left : ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x c x' d :=
      ghr93_strategy_restrict_left
        hc_interval.1 hc_interval.2 hd_interval.1 hd_interval.2
        hcd_form hcd_gp h_d_consistent_left h_pt
    have h_restrict_right : ghr93_duplicator_wins M N atomMap (1 + 3 * n) r c y d y' :=
      ghr93_strategy_restrict_right
        hc_interval.1 hc_interval.2 hd_interval.1 hd_interval.2
        hcd_form hcd_gp h_d_consistent_right h_pt
    -- Construct sigma: backward n-round on [x',d] vs [x,c]
    -- Two cases: degenerate (x' = d, both gaps) or non-degenerate (∃ point in [x',d])
    have sigma : ghr93_duplicator_wins N M atomMap n r x' d x c := by
      by_cases hx'd_eq : x' = d
      · -- Degenerate: x' = d. By boundary correspondence, x = c.
        have hxc_eq : x = c := hcd_boundary.1.mpr hx'd_eq
        -- Both d and c must be gaps (if x' = d, x' is a gap or point;
        -- if x' is a point, then x' itself witnesses [x',d], contradiction
        -- with the degenerate case needing special handling. Actually:
        -- x' = d means the interval is degenerate. d could be a point or gap.
        -- If d is a point, then d itself is in [x',d], so the sub-interval
        -- has a witness and the IH works. So degenerate = x'=d AND d is a gap.
        rcases isPoint_or_isGap d with ⟨p_d, hp_d⟩ | ⟨g_d, hg_d⟩
        · -- d is a point: [x',d] = [d,d] with d a point, so d witnesses itself
          have h_pt_sub : ∃ p, inClosedInterval x' d (extendPoint p) := by
            rw [hx'd_eq, hp_d]; exact ⟨p_d, le_refl _, le_refl _⟩
          exact ih hc_interval.1 hd_interval.1 h_pt_sub h_restrict_left
        · -- d is a gap, x' = d: fully degenerate. By gap agreement, c is a gap.
          have hc_gap : IsGap c := hcd_gp.2.mpr ⟨g_d, hg_d⟩
          obtain ⟨g_c, hg_c⟩ := hc_gap
          -- Use degenerate gap lemma with d and c, then rewrite endpoints.
          have h_degen : ghr93_duplicator_wins N M atomMap n r d d c c :=
            ghr93_duplicator_wins_degenerate_gap (n := n)
              ⟨g_d, hg_d⟩ ⟨g_c, hg_c⟩
              (fun A hA => (hcd_form A hA).symm) ⟨hcd_gp.1.symm, hcd_gp.2.symm⟩
          rwa [hx'd_eq, hxc_eq]
      · -- Non-degenerate: x' ≠ d, so x' < d (strict).
        have hx'd_lt : x' < d := lt_of_le_of_ne hd_interval.1 hx'd_eq
        -- Find a point witness in [x', d]
        have h_pt_sub : ∃ p, inClosedInterval x' d (extendPoint p) := by
          rcases isPoint_or_isGap d with ⟨p_d, hp_d⟩ | ⟨g_d, hg_d⟩
          · rw [hp_d] at hd_interval ⊢
            exact ⟨p_d, hd_interval.1, le_refl _⟩
          · rcases isPoint_or_isGap x' with ⟨x_pt, hx_pt⟩ | ⟨g_x, hg_x⟩
            · rw [hx_pt] at hd_interval ⊢
              exact ⟨x_pt, le_refl _, hd_interval.1⟩
            · rw [hg_x] at hx'd_lt ⊢; rw [hg_d] at hx'd_lt ⊢
              exact point_between_strict_gaps rfl rfl hx'd_lt
        exact ih hc_interval.1 hd_interval.1 h_pt_sub h_restrict_left
    -- Construct tau: backward n-round on [d,y'] vs [c,y]
    have tau : ghr93_duplicator_wins N M atomMap n r d y' c y := by
      by_cases hdy'_eq : d = y'
      · -- Degenerate: d = y'. By boundary correspondence, c = y.
        have hcy_eq : c = y := hcd_boundary.2.mpr hdy'_eq
        rcases isPoint_or_isGap d with ⟨p_d, hp_d⟩ | ⟨g_d, hg_d⟩
        · have h_pt_sub : ∃ p, inClosedInterval d y' (extendPoint p) :=
            ⟨p_d, le_of_eq hp_d, le_of_eq (show extendPoint p_d = y' from hp_d.symm.trans hdy'_eq)⟩
          exact ih hc_interval.2 hd_interval.2 h_pt_sub h_restrict_right
        · have hc_gap : IsGap c := hcd_gp.2.mpr ⟨g_d, hg_d⟩
          obtain ⟨g_c, hg_c⟩ := hc_gap
          -- d = y' and c = y, both are gaps.
          -- Goal: ghr93_duplicator_wins N M atomMap n r d y' c y
          -- Use ghr93_duplicator_wins_degenerate_gap with d and c
          -- Goal: ghr93_duplicator_wins N M atomMap n r d y' c y
          -- Since d = y' and c = y, convert to ghr93_duplicator_wins N M atomMap n r d d c c
          have h1 : d = y' := hdy'_eq
          have h2 : c = y := hcy_eq
          rw [h1, h2]
          exact ghr93_duplicator_wins_degenerate_gap (n := n)
            ⟨g_d, h1 ▸ hg_d⟩ ⟨g_c, h2 ▸ hg_c⟩
            (fun A hA => by rw [← h1, ← h2]; exact (hcd_form A hA).symm)
            ⟨by rw [← h1, ← h2]; exact hcd_gp.1.symm,
             by rw [← h1, ← h2]; exact hcd_gp.2.symm⟩
      · have hdy'_lt : d < y' := lt_of_le_of_ne hd_interval.2 hdy'_eq
        have h_pt_sub : ∃ p, inClosedInterval d y' (extendPoint p) := by
          rcases isPoint_or_isGap d with ⟨p_d, hp_d⟩ | ⟨g_d, hg_d⟩
          · exact ⟨p_d, le_of_eq hp_d,
              le_of_lt (show extendPoint p_d < y' by rw [show extendPoint p_d = d from hp_d.symm]; exact hdy'_lt)⟩
          · rcases isPoint_or_isGap y' with ⟨y_pt, hy_pt⟩ | ⟨g_y, hg_y⟩
            · exact ⟨y_pt,
                le_of_lt (show d < extendPoint y_pt by rw [show extendPoint y_pt = y' from hy_pt.symm]; exact hdy'_lt),
                le_of_eq (show extendPoint y_pt = y' from hy_pt.symm)⟩
            · rw [hg_d] at hdy'_lt ⊢; rw [hg_y] at hdy'_lt ⊢
              exact point_between_strict_gaps rfl rfl hdy'_lt
        exact ih hc_interval.2 hd_interval.2 h_pt_sub h_restrict_right
    -- M-side sub-interval point witnesses (for SplitPointProps)
    -- Disjunctive form: either a carrier point exists in the sub-interval,
    -- or the sub-interval is degenerate (x = c or c = y) with c a gap.
    have h_pt_xc_w : (∃ p, inClosedInterval x c (extendPoint p)) ∨
        (x = c ∧ x' = d ∧ IsGap c ∧ IsGap d) := by
      by_cases hxc_eq : x = c
      · rcases isPoint_or_isGap c with ⟨p_c, hp_c⟩ | ⟨g_c, hg_c⟩
        · left; rw [hxc_eq, hp_c]; exact ⟨p_c, le_refl _, le_refl _⟩
        · right
          have hx'd_eq : x' = d := hcd_boundary.1.mp hxc_eq
          have hd_gap : IsGap d := hcd_gp.2.mp ⟨g_c, hg_c⟩
          exact ⟨hxc_eq, hx'd_eq, ⟨g_c, hg_c⟩, hd_gap⟩
      · left
        rcases isPoint_or_isGap c with ⟨p_c, hp_c⟩ | ⟨g_c, hg_c⟩
        · rw [hp_c] at hc_interval ⊢
          exact ⟨p_c, hc_interval.1, le_refl _⟩
        · obtain ⟨p_M, hp_M⟩ := h_pt_M
          rcases le_or_lt (extendPoint p_M) c with h | h
          · exact ⟨p_M, hp_M.1, h⟩
          · rcases isPoint_or_isGap x with ⟨x_pt, hx_pt⟩ | ⟨g_x, hgx⟩
            · rw [hx_pt] at hc_interval ⊢
              exact ⟨x_pt, le_refl _, hc_interval.1⟩
            · have hxc_lt : x < c := lt_of_le_of_ne hc_interval.1 hxc_eq
              rw [hgx] at hxc_lt ⊢; rw [hg_c] at hxc_lt ⊢
              exact point_between_strict_gaps rfl rfl hxc_lt
    have h_pt_cy_w : (∃ p, inClosedInterval c y (extendPoint p)) ∨
        (c = y ∧ d = y' ∧ IsGap c ∧ IsGap d) := by
      by_cases hcy_eq : c = y
      · rcases isPoint_or_isGap c with ⟨p_c, hp_c⟩ | ⟨g_c, hg_c⟩
        · left; rw [← hcy_eq, hp_c]; exact ⟨p_c, le_refl _, le_refl _⟩
        · right
          have hdy'_eq : d = y' := hcd_boundary.2.mp hcy_eq
          have hd_gap : IsGap d := hcd_gp.2.mp ⟨g_c, hg_c⟩
          exact ⟨hcy_eq, hdy'_eq, ⟨g_c, hg_c⟩, hd_gap⟩
      · left
        rcases isPoint_or_isGap c with ⟨p_c, hp_c⟩ | ⟨g_c, hg_c⟩
        · rw [hp_c] at hc_interval ⊢
          exact ⟨p_c, le_refl _, hc_interval.2⟩
        · obtain ⟨p_M, hp_M⟩ := h_pt_M
          rcases le_or_lt c (extendPoint p_M) with h | h
          · exact ⟨p_M, h, hp_M.2⟩
          · rcases isPoint_or_isGap y with ⟨y_pt, hy_pt⟩ | ⟨g_y, hgy⟩
            · rw [hy_pt] at hc_interval ⊢
              exact ⟨y_pt, hc_interval.2, le_refl _⟩
            · have hcy_lt : c < y := lt_of_le_of_ne hc_interval.2 hcy_eq
              rw [hg_c] at hcy_lt ⊢; rw [hgy] at hcy_lt ⊢
              exact point_between_strict_gaps rfl rfl hcy_lt
    exact {
      hc_interval := hc_interval
      hd_interval := hd_interval
      hd_le_an := hd_le_an_proof
      hxc := hc_interval.1
      hcy := hc_interval.2
      hx'd := hd_interval.1
      hdy' := hd_interval.2
      h_pt_xc := h_pt_xc_w
      h_pt_cy := h_pt_cy_w
      hcd_form := hcd_form
      hcd_gp := hcd_gp
      sigma := sigma
      tau := tau
      h_fwd_n1 := ghr93_duplicator_wins_round_mono (by omega : n + 1 ≤ 4 + 3 * n) hxy hx'y' h_fwd
    }
  -- Prove the existence of c with the needed properties using c_inf = inf(S_C^M).
  -- GHR93 Claim 1: Use the rank-(r+2) game h_fwd_r1 to show that the game
  -- response to rank_embed(c_inf) equals rank_embed(d). This gives formula
  -- agreement at depth r+2 between rank_embed(c_inf) and rank_embed(d), which
  -- projects to depth-r agreement between c_inf and d via rank_embed_stavi_truth_mu.
  -- Gap/point and boundary are derived from the rank-(r+2) game's winning condition.
  -- This completely bypasses the rank-r game and t_game, avoiding the depth
  -- mismatch that makes t_game = d unprovable via hform_1 (depth r only).
  --
  -- Step 1: Reduce h_fwd_r1 to 1 round at rank r+2
  have h1_r2 : ghr93_duplicator_wins M N atomMap 1 (r + 2)
      (rank_embed (by omega : r ≤ r + 2) x)
      (rank_embed (by omega : r ≤ r + 2) y)
      (rank_embed (by omega : r ≤ r + 2) x')
      (rank_embed (by omega : r ≤ r + 2) y') :=
    ghr93_duplicator_wins_round_mono (by omega : 1 ≤ 4 + 3 * n)
      ((rank_embed_le (by omega : r ≤ r + 2) x y).mpr hxy)
      ((rank_embed_le (by omega : r ≤ r + 2) x' y').mpr hx'y') h_fwd_r1
  -- Step 2: Play with rank_embed(c_inf)
  have hc_inf_r2 : inClosedInterval
      (rank_embed (by omega : r ≤ r + 2) x)
      (rank_embed (by omega : r ≤ r + 2) y)
      (rank_embed (by omega : r ≤ r + 2) c_inf) :=
    (rank_embed_inClosedInterval (by omega : r ≤ r + 2) x y c_inf).mpr hc_inf_interval
  obtain ⟨a'_r2, ha'_r2, hwin_r2⟩ := h1_r2
    (fun _ => rank_embed (by omega : r ≤ r + 2) c_inf) (fun _ => hc_inf_r2)
  set r2_resp := a'_r2 ⟨0, by omega⟩ with r2_resp_def
  -- Step 3: Direction 2 at rank r+2 (r2_resp ≥ rank_embed(d))
  -- r2_resp ∈ S_C at rank r+2, hence rank_embed(d) ≤ r2_resp.
  -- Proof mirrors h_t_game_in_SC: for mu u > r2_resp in N at rank r+2,
  -- play Round 2 to get M-side point above rank_embed(c_inf),
  -- then use c_inf ∈ S_C_M and formula transfer.
  -- Re-derive d ∈ S_C and cofinal failure below d (these were proved in the
  -- suffices branch but are not in scope here).
  have hd_in_SC : d ∈ S_C := by
    refine ⟨hd_interval, ?_⟩
    intro u hdu huy' hmu
    have : ¬ (∀ s ∈ S_C, u ≤ s) := by
      intro h_lb
      exact absurd (hd_is_inf u h_lb) (not_le.mpr hdu)
    push_neg at this
    obtain ⟨s₀, hs₀_in, hs₀_lt⟩ := this
    exact hs₀_in.2 u hs₀_lt huy' hmu
  have h_cofinal_failure_below_d :
      ∀ (s : ExtendedCarrier N atomMap r),
        inClosedInterval x' y' s → s < d →
        ∃ (u : ExtendedCarrier N atomMap r),
          s < u ∧ u ≤ d ∧ u < y' ∧
          mu_holds u ∧ ¬ cont_holds (a_bwd ⟨n, by omega⟩) y' u := by
    intro s hs_interval hs_lt_d
    have hs_not_SC : s ∉ S_C := by
      intro hs_in; exact absurd (hd_glb s hs_in) (not_le.mpr hs_lt_d)
    have : ¬ (∀ u : ExtendedCarrier N atomMap r,
        s < u → u < y' → mu_holds u →
        cont_holds (a_bwd ⟨n, by omega⟩) y' u) := by
      intro h_all; exact hs_not_SC ⟨hs_interval, h_all⟩
    push_neg at this
    obtain ⟨v, hsv, hvy', hmu_v, h_not_cont_v⟩ := this
    rcases le_or_gt v d with hv_le_d | hv_gt_d
    · exact ⟨v, hsv, hv_le_d, hvy', hmu_v, h_not_cont_v⟩
    · exact absurd (hd_in_SC.2 v hv_gt_d hvy' hmu_v) h_not_cont_v
  -- Steps 3-5 combined: r2_resp = rank_embed(d)
  -- GHR93 Claim 1: the game response must equal rank_embed of the infimum.
  --
  -- Direction 1 (r2_resp ≤ rank_embed(d)): K⁻(¬D_M) argument.
  --   Apply pigeonhole_definable_formula_cross to S_C_M to get D_M of depth ≤ r
  --   that holds on (a_bwd(n), y') in N but fails cofinally below c_inf in M.
  --   Construct K⁻(¬D_M) = neg(std_snce(base(⊤), D_M)) of depth ≤ r + 2.
  --   K⁻(¬D_M)(c_inf) = TRUE (¬D_M cofinal below c_inf in M).
  --   Transfer via hform_r2_1 at depth r+2: K⁻(¬D_M)(r2_resp) = TRUE.
  --   If r2_resp > rank_embed(d): D_M holds on (d, y') (from d ∈ S_C),
  --   so Since(⊤, D_M)(r2_resp) = TRUE, contradicting K⁻(¬D_M)(r2_resp).
  --
  -- Direction 2 (rank_embed(d) ≤ r2_resp): game Round 2 argument.
  --   For any mu p with r2_resp < extendPoint p < y' (at rank r+2):
  --   play p in Round 2, get M-side b with c_inf < b < y, cont_holds_cross at b,
  --   formula transfer gives cont_holds at p. So cont_holds above r2_resp.
  --   By contradiction: if r2_resp < rank_embed(d), find failure between
  --   r2_resp and d (from cofinal failure), contradicting cont_holds above r2_resp.
  --   The carrier-point case gives contradiction directly; the gap case
  --   follows from Direction 1 giving r2_resp ≤ rank_embed(d).
  --
  -- We prove both directions and combine.
  -- Direction 2 helper: cont_holds transfer via game Round 2.
  -- For any carrier point p of N with r2_resp < extendPoint p (at rank r+2)
  -- and extendPoint p < y' (at rank r), cont_holds holds at extendPoint p.
  have h_cont_transfer : ∀ (p : N.carrier),
      r2_resp < (extendPoint p : ExtendedCarrier N atomMap (r + 2)) →
      (extendPoint p : ExtendedCarrier N atomMap r) < y' →
      cont_holds (a_bwd ⟨n, by omega⟩) y' (extendPoint p) := by
    intro p hr2_lt_p hp_lt_y'
    -- Play p in Round 2 of the rank-(r+2) game
    have hp_in_r2 : inClosedInterval
        (rank_embed (by omega : r ≤ r + 2) x')
        (rank_embed (by omega : r ≤ r + 2) y')
        (extendPoint p : ExtendedCarrier N atomMap (r + 2)) := by
      constructor
      · -- rank_embed(x') ≤ extendPoint(p) at rank r+2
        -- From ha'_r2: rank_embed(x') ≤ r2_resp, and r2_resp < extendPoint(p)
        exact le_trans (ha'_r2 ⟨0, by omega⟩).1 (le_of_lt hr2_lt_p)
      · -- extendPoint(p) ≤ rank_embed(y') at rank r+2
        -- hp_lt_y' : extendPoint(p) < y' at rank r
        -- rank_embed preserves: rank_embed(extendPoint(p)) < rank_embed(y')
        rw [← rank_embed_point (by omega : r ≤ r + 2) p]
        exact le_of_lt ((rank_embed_lt (by omega : r ≤ r + 2)
          (extendPoint p) y').mpr hp_lt_y')
    obtain ⟨b_u, hb_u_in, hcond_u⟩ := hwin_r2 p hp_in_r2
    obtain ⟨hord_u, _hgp_u, hform_u⟩ := hcond_u
    -- Extract order at index (1,2): rank_embed(c_inf) vs extendPoint(b_u)
    have hord_12 := hord_u ⟨1, by omega⟩ ⟨2, by omega⟩
    simp only [game_tuple, show (1 : Nat) ≠ 0 from by omega,
               show (1 : Nat) ≠ 1 + 1 from by omega,
               show (1 : Nat) ≠ 1 + 2 from by omega, dite_false,
               show 1 - 1 = 0 from by omega,
               show (2 : Nat) ≠ 0 from by omega,
               show (2 : Nat) = 1 + 1 from by omega, dite_true] at hord_12
    -- c_inf < extendPoint b_u at rank r (from order type)
    have hc_lt_bu_r : c_inf < (extendPoint b_u : ExtendedCarrier M atomMap r) := by
      have : rank_embed (by omega : r ≤ r + 2) c_inf <
          (extendPoint b_u : ExtendedCarrier M atomMap (r + 2)) := by
        rw [← rank_embed_point (by omega : r ≤ r + 2) p] at hr2_lt_p
        exact hord_12.1.mpr hr2_lt_p
      rw [← rank_embed_point (by omega : r ≤ r + 2) b_u] at this
      exact (rank_embed_lt (by omega : r ≤ r + 2) c_inf (extendPoint b_u)).mp this
    -- Extract order at index (2,3): extendPoint(b_u) vs rank_embed(y)
    have hord_23 := hord_u ⟨2, by omega⟩ ⟨3, by omega⟩
    simp only [game_tuple, show (2 : Nat) ≠ 0 from by omega,
               show (2 : Nat) = 1 + 1 from by omega, dite_true,
               show (3 : Nat) ≠ 0 from by omega,
               show ¬((3 : Nat) = 1 + 1) from by omega,
               show (3 : Nat) = 1 + 2 from by omega, dite_true] at hord_23
    -- extendPoint(b_u) < y at rank r
    have hbu_lt_y : (extendPoint b_u : ExtendedCarrier M atomMap r) < y := by
      have hp_lt_y'_r2 : (extendPoint p : ExtendedCarrier N atomMap (r + 2)) <
          rank_embed (by omega : r ≤ r + 2) y' := by
        rw [← rank_embed_point (by omega : r ≤ r + 2) p]
        exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint p) y').mpr hp_lt_y'
      have : (extendPoint b_u : ExtendedCarrier M atomMap (r + 2)) <
          rank_embed (by omega : r ≤ r + 2) y := hord_23.1.mpr hp_lt_y'_r2
      rw [← rank_embed_point (by omega : r ≤ r + 2) b_u] at this
      exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint b_u) y).mp this
    -- c_inf ∈ S_C_M: cont_holds_cross at extendPoint b_u
    have hmu_bu : mu_holds (extendPoint (sig := sig) (atomMap := atomMap) (r := r) b_u) :=
      ⟨b_u, rfl⟩
    have h_cont_cross_bu : cont_holds_cross (a_bwd ⟨n, by omega⟩) y' (extendPoint b_u) :=
      hc_inf_in_SC_M.2 (extendPoint b_u) hc_lt_bu_r hbu_lt_y hmu_bu
    -- Transfer: for any A with depth ≤ r, if A holds at all mu in (a_bwd(n), y'),
    -- then A holds at extendPoint(b_u) in M (from cont_holds_cross),
    -- then A holds at extendPoint(p) in N (from formula agreement).
    intro A hA h_all_mu
    have hA_bu : stavi_temporal_truth_mu M atomMap r (extendPoint b_u) A :=
      h_cont_cross_bu A hA h_all_mu
    -- Formula agreement at index 2, depth ≤ r+2
    have hform_2 := hform_u ⟨2, by omega⟩ A (le_trans hA (by omega : r ≤ r + 2))
    simp only [game_tuple, show (2 : Nat) ≠ 0 from by omega, dite_false,
               show (2 : Nat) = 1 + 1 from by omega, dite_true] at hform_2
    -- Bridge from rank r to rank r+2 via rank_embed_stavi_truth_mu.
    -- hform_2 : truth M (r+2) (extendPoint b_u) A ↔ truth N (r+2) (extendPoint p) A
    -- We need: truth N r (extendPoint p) A
    -- extendPoint b_u at rank r+2 = rank_embed(extendPoint b_u at rank r) by rank_embed_point.
    -- So truth M (r+2) (extendPoint b_u) A ↔ truth M r (extendPoint b_u) A.
    -- Similarly for p on the N side.
    have hM_bridge : stavi_temporal_truth_mu M atomMap (r + 2)
        (extendPoint b_u : ExtendedCarrier M atomMap (r + 2)) A ↔
        stavi_temporal_truth_mu M atomMap r (extendPoint b_u : ExtendedCarrier M atomMap r) A := by
      conv_lhs => rw [show (extendPoint b_u : ExtendedCarrier M atomMap (r + 2)) =
        rank_embed (by omega : r ≤ r + 2) (extendPoint b_u : ExtendedCarrier M atomMap r) from
        (rank_embed_point (by omega : r ≤ r + 2) b_u).symm]
      exact rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) (extendPoint b_u) A
    have hN_bridge : stavi_temporal_truth_mu N atomMap (r + 2)
        (extendPoint p : ExtendedCarrier N atomMap (r + 2)) A ↔
        stavi_temporal_truth_mu N atomMap r (extendPoint p : ExtendedCarrier N atomMap r) A := by
      conv_lhs => rw [show (extendPoint p : ExtendedCarrier N atomMap (r + 2)) =
        rank_embed (by omega : r ≤ r + 2) (extendPoint p : ExtendedCarrier N atomMap r) from
        (rank_embed_point (by omega : r ≤ r + 2) p).symm]
      exact rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) (extendPoint p) A
    exact hN_bridge.mp (hform_2.mp (hM_bridge.mpr hA_bu))
  -- Direction 1: r2_resp ≤ rank_embed(d)
  -- GHR93 Claim 1 Step 2.2: K⁻(¬D_M) argument.
  -- Apply pigeonhole_definable_formula_cross to get D_M, construct K⁻(¬D_M),
  -- transfer via game, derive bound.
  have h_r2_resp_le_d : r2_resp ≤ rank_embed (by omega : r ≤ r + 2) d := by
    -- By contradiction: assume rank_embed(d) < r2_resp.
    by_contra h_not_le
    push_neg at h_not_le
    -- h_not_le : rank_embed d < r2_resp
    -- GHR93 Claim 1, Direction 1: K⁻(¬D) argument.
    -- Extract order agreement at indices (0,1) from the game.
    -- Instantiate hwin_r2 with any carrier point from h_pt to get winning condition.
    obtain ⟨p_N, hp_N⟩ := h_pt
    have hp_N_r2 : inClosedInterval
        (rank_embed (by omega : r ≤ r + 2) x')
        (rank_embed (by omega : r ≤ r + 2) y')
        (extendPoint p_N : ExtendedCarrier N atomMap (r + 2)) := by
      rw [← rank_embed_point (by omega : r ≤ r + 2) p_N]
      exact (rank_embed_inClosedInterval (by omega : r ≤ r + 2) x' y'
        (extendPoint p_N)).mpr hp_N
    obtain ⟨b_w, hb_w_in, hcond_w⟩ := hwin_r2 p_N hp_N_r2
    obtain ⟨hord_w, _, hform_w⟩ := hcond_w
    -- Order agreement at index (0,1): rank_embed(x) < rank_embed(c_inf) ↔ rank_embed(x') < r2_resp
    have hord_01 := hord_w ⟨0, by omega⟩ ⟨1, by omega⟩
    simp only [game_tuple, show (0 : Nat) = 0 from rfl, dite_true,
               show (1 : Nat) ≠ 0 from by omega,
               show (1 : Nat) ≠ 1 + 1 from by omega,
               show (1 : Nat) ≠ 1 + 2 from by omega, dite_false,
               show 1 - 1 = 0 from by omega] at hord_01
    -- hord_01 : rank_embed x < rank_embed c_inf ↔ rank_embed x' < r2_resp
    -- Also extract (1,3): rank_embed(c_inf) < rank_embed(y) ↔ r2_resp < rank_embed(y')
    have hord_13 := hord_w ⟨1, by omega⟩ ⟨3, by omega⟩
    simp only [game_tuple, show (1 : Nat) ≠ 0 from by omega,
               show (1 : Nat) ≠ 1 + 1 from by omega,
               show (1 : Nat) ≠ 1 + 2 from by omega, dite_false,
               show 1 - 1 = 0 from by omega,
               show (3 : Nat) ≠ 0 from by omega,
               show ¬((3 : Nat) = 1 + 1) from by omega,
               show (3 : Nat) = 1 + 2 from by omega, dite_true] at hord_13
    -- Use the game Round 2 response to derive contradiction via cont_holds transfer.
    -- For any carrier point q in N with r2_resp < extendPoint(q) at rank r+2 and
    -- extendPoint(q) < y' at rank r, h_cont_transfer gives cont_holds at q.
    -- From d ∈ S_C: cont_holds at all mu above d and below y'.
    -- Key: play Round 2 with a carrier point p' above d.
    -- The game response b gives formula agreement between b (M) and p' (N).
    -- If b ≤ c_inf: cont_holds_cross at b (from formula agreement with p' where
    -- cont_holds holds), then the infimum property gives contradiction with failures
    -- below c_inf.
    --
    -- Step 1: Find a carrier point p' with d < extendPoint(p') < y' in N.
    -- From hd_in_SC and d being the infimum: d ≤ a_bwd(n) and a_bwd(n) ∈ S_C.
    -- If d < a_bwd(n): then between d and a_bwd(n) there might be carrier points.
    -- Actually use h_pt: there exists p in [x', y'].
    -- If extendPoint(p_N) > d: take p' = p_N.
    -- If extendPoint(p_N) ≤ d: need another carrier point above d.
    -- From h_an_in_SC: a_bwd(n) ∈ S_C means a_bwd(n) ∈ [x', y'].
    -- a_bwd(n) might or might not be a carrier point.
    -- Use a separate argument: Since(⊤, D) semantics.
    --
    -- Actually, the simplest contradiction comes from the order agreement itself.
    -- If c_inf = x: order (0,1) gives rank_embed(x) = rank_embed(c_inf), so
    -- ¬(rank_embed(x) < rank_embed(c_inf)). By iff: ¬(rank_embed(x') < r2_resp).
    -- So r2_resp ≤ rank_embed(x') ≤ rank_embed(d). Contradicts h_not_le.
    -- If c_inf > x: we need the K⁻(¬D) argument.
    rcases eq_or_lt_of_le hc_inf_interval.1 with hx_eq_c | hx_lt_c
    · -- Case: x = c_inf
      -- Order (0,1) equality iff: x = c_inf → x' = r2_resp
      have h_x_eq : rank_embed (by omega : r ≤ r + 2) x =
          rank_embed (by omega : r ≤ r + 2) c_inf := by rw [hx_eq_c]
      have h_x'_eq : rank_embed (by omega : r ≤ r + 2) x' = a'_r2 ⟨0, by omega⟩ :=
        hord_01.2.mp h_x_eq
      -- So r2_resp = rank_embed(x')
      have h_r2_eq_x' : r2_resp = rank_embed (by omega : r ≤ r + 2) x' :=
        h_x'_eq.symm
      -- rank_embed(x') ≤ rank_embed(d) (since x' ≤ d from hd_interval)
      have hx'_le_d : rank_embed (by omega : r ≤ r + 2) x' ≤
          rank_embed (by omega : r ≤ r + 2) d :=
        (rank_embed_le (by omega : r ≤ r + 2) x' d).mpr hd_interval.1
      -- r2_resp = rank_embed(x') ≤ rank_embed(d), contradicting h_not_le
      exact absurd (h_r2_eq_x' ▸ hx'_le_d) (not_le.mpr h_not_le)
    · -- Case: x < c_inf. GHR93 Claim 1 K⁻(¬D_M) argument.
      -- Case split: does cont_holds_cross hold at c_inf itself?
      -- (A) If yes: strict failures exist below c_inf → K⁻ pigeonhole argument.
      -- (B) If no: use the failing formula A directly (depth ≤ r).
      by_cases h_cont_c : cont_holds_cross (a_bwd ⟨n, by omega⟩) y' c_inf
      · -- (A) cont_holds_cross holds at c_inf. K⁻ argument via strict pigeonhole.
        have h_strict_failure :
            ∀ (s : ExtendedCarrier M atomMap r),
              inClosedInterval x y s → s < c_inf →
              ∃ (u : ExtendedCarrier M atomMap r),
                s < u ∧ u < c_inf ∧ u < y ∧
                mu_holds u ∧ ¬ cont_holds_cross (a_bwd ⟨n, by omega⟩) y' u := by
          intro s hs hs_lt_c
          obtain ⟨v, hsv, hv_le_c, hvy, hmu_v, h_not_cont_v⟩ :=
            h_cofinal_failure_below_c_inf s hs hs_lt_c
          rcases lt_or_eq_of_le hv_le_c with hv_lt | hv_eq
          · exact ⟨v, hsv, hv_lt, hvy, hmu_v, h_not_cont_v⟩
          · exact absurd h_cont_c (hv_eq ▸ h_not_cont_v)
        -- Bridge to strict pigeonhole precondition:
        have h_strict_bridge :
            ∀ p : M.carrier, p ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') →
              x ≤ (extendPoint p : ExtendedCarrier M atomMap r) →
              (extendPoint p : ExtendedCarrier M atomMap r) < c_inf →
              ∃ (u : M.carrier),
                p ≤ u ∧
                u ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') ∧
                (extendPoint u : ExtendedCarrier M atomMap r) < c_inf ∧
                ∃ (A : StaviFormula),
                  stavi_depth A ≤ r ∧
                  (∀ v : ExtendedCarrier N atomMap r,
                    a_bwd ⟨n, by omega⟩ < v → v < y' → mu_holds v →
                    stavi_temporal_truth_mu N atomMap r v A) ∧
                  ¬ stavi_temporal_truth M atomMap u A := by
          intro p hp_cut hxp hp_lt_c
          have hp_interval : inClosedInterval x y (extendPoint p : ExtendedCarrier M atomMap r) :=
            ⟨hxp, le_trans (le_of_lt hp_lt_c) hc_inf_interval.2⟩
          obtain ⟨v, hpv, hv_lt_c, _, hmu_v, h_not_cont_v⟩ :=
            h_strict_failure (extendPoint p) hp_interval hp_lt_c
          obtain ⟨q, hq_eq⟩ := hmu_v
          rw [hq_eq] at hpv hv_lt_c h_not_cont_v
          have hq_cut : q ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
            intro s hs; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb s hs)
          have hp_le_q : p ≤ q := (extendPoint_le_iff p q).mp (le_of_lt hpv)
          simp only [cont_holds_cross] at h_not_cont_v
          push_neg at h_not_cont_v
          obtain ⟨B, hB_depth, hB_interval, hB_fail⟩ := h_not_cont_v
          have hB_fail_carrier : ¬ stavi_temporal_truth M atomMap q B :=
            fun h => hB_fail ((stavi_truth_mu_at_point q B).mpr h)
          exact ⟨q, hp_le_q, hq_cut, hv_lt_c, B, hB_depth, hB_interval, hB_fail_carrier⟩
        -- Get starting point for strict pigeonhole.
        obtain ⟨u₀, hx_lt_u₀, hu₀_lt_c, _, hmu_u₀, _⟩ :=
          h_strict_failure x ⟨le_refl x, hxy⟩ hx_lt_c
        obtain ⟨q₀, hq₀⟩ := hmu_u₀
        rw [hq₀] at hx_lt_u₀ hu₀_lt_c
        have hq₀_cut : q₀ ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
          intro s hs; exact le_trans (le_of_lt hu₀_lt_c) (hc_inf_glb s hs)
        -- Starting point is strictly below c_inf: apply strict pigeonhole.
        obtain ⟨D_M, hD_depth, hD_interval, hD_cofinal⟩ :=
          pigeonhole_definable_formula_cross_strict hxy
            ⟨q₀, hq₀_cut, le_of_lt hx_lt_u₀, hu₀_lt_c⟩ h_strict_bridge
        -- D_M: depth ≤ r, holds at all mu in (a_n, y') in N,
        -- fails cofinally below c_inf with ep_u < c_inf strictly.
        --
        -- K⁻(¬D_M) argument:
        -- (1) Since(⊤, D_M) FALSE at c_inf (D_M fails in every open (s, c_inf)).
        -- (2) Transfer neg(Since(⊤, D_M)) via rank_embed + formula_agreement.
        -- (3) Since(⊤, D_M) TRUE at r2_resp (D_M holds on (a_bwd(n), y') in N).
        -- (4) Contradiction.
        --
        -- Define K⁻(¬D_M) = neg(std_snce(neg(base .bot), D_M))
        -- neg(base .bot) is always true (= ⊤), depth 0.
        -- std_snce has depth max(0, depth D_M) + 2 = r + 2 (since D_M depth ≤ r).
        -- neg preserves depth. So K⁻(¬D_M) has depth r + 2.
        let K_minus := StaviFormula.neg (StaviFormula.std_snce (StaviFormula.neg (.base .bot)) D_M)
        have hK_depth : stavi_depth K_minus ≤ r + 2 := by
          simp only [K_minus, stavi_depth, operator_depth]
          omega
        -- (1) Since(⊤, D_M) FALSE at c_inf in M at rank r.
        -- For any mu-point s < c_inf, hD_cofinal gives a failure of D_M in (s, c_inf).
        -- First we need a starting cut point. We have q₀ with ep < c_inf.
        -- Actually, hD_cofinal gives: for any cut point t with x ≤ ep(t) < c_inf,
        -- ∃ u ≥ t in cut with ep(u) < c_inf and ¬D_M(u).
        -- We need: ¬ std_snce(neg .bot, D_M)(c_inf) in M at rank r.
        -- I.e., ¬ (∃ mu s < c_inf, neg(.bot)(s) ∧ ∀ mu u ∈ (s, c_inf), D_M(u)).
        -- Equivalently: ∀ mu s < c_inf, ∃ mu u ∈ (s, c_inf), ¬D_M(u).
        have h_since_false_c : ¬ stavi_temporal_truth_mu M atomMap r c_inf
            (StaviFormula.std_snce (StaviFormula.neg (.base .bot)) D_M) := by
          simp only [stavi_temporal_truth_mu]
          push_neg
          intro s hs_lt_c _hmu_s _h_neg_bot
          -- Need: ∃ mu u ∈ (s, c_inf), ¬D_M(u).
          -- From h_strict_failure at s (if s ∈ [x, y]):
          -- Use hD_cofinal to get a cut point where D_M fails.
          -- But hD_cofinal takes a cut point, not an arbitrary mu-point.
          -- We need to connect s to a cut point below it.
          -- Actually, we use h_strict_failure to get a mu-point above s
          -- where cont_holds_cross fails, then the pigeonhole formula D_M
          -- also fails at some point above s.
          --
          -- Alternative: from hD_cofinal, get a chain of D_M failures.
          -- hD_cofinal says: for any cut point t with x ≤ ep(t) < c_inf,
          -- ∃ u ≥ t with ep(u) < c_inf and ¬D_M(u).
          -- We need to find u with s < ep(u) < c_inf and ¬D_M(u).
          --
          -- From q₀ (our starting cut point with ep(q₀) < c_inf):
          -- If s < ep(q₀): use hD_cofinal at q₀ to get u ≥ q₀ with
          --   ep(u) < c_inf and ¬D_M(u). Then s < ep(q₀) ≤ ep(u) < c_inf.
          -- If ep(q₀) ≤ s: need a cut point above s.
          --   From h_strict_failure at s (with s ∈ [x,y], s < c_inf):
          --   get v with s < v < c_inf and mu_holds v and ¬cont_holds_cross v.
          --   Then v = ep(q') for some q'. q' is in cut, ep(q') < c_inf.
          --   Apply hD_cofinal at q' to get u ≥ q' with ¬D_M(u).
          --   s < ep(q') ≤ ep(u) < c_inf. Done.
          --
          -- First, establish s ∈ [x, y]:
          -- s < c_inf ≤ y, so s < y.
          -- We need x ≤ s. s is a mu-point in M. We need it in [x, y].
          -- Actually s could be anywhere < c_inf. But we can handle s < x too:
          -- if s < x < c_inf, use h_strict_failure at x.
          rcases le_or_lt x s with hxs | hsx
          · -- x ≤ s < c_inf
            have hs_interval : inClosedInterval x y s :=
              ⟨hxs, le_trans (le_of_lt hs_lt_c) hc_inf_interval.2⟩
            obtain ⟨v, hsv, hv_lt_c, _, hmu_v, _⟩ :=
              h_strict_failure s hs_interval hs_lt_c
            obtain ⟨q', hq'_eq⟩ := hmu_v
            rw [hq'_eq] at hsv hv_lt_c
            have hq'_cut : q' ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
              intro t ht; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb t ht)
            obtain ⟨u, hq'_le_u, _, hu_lt_c, hD_fail⟩ :=
              hD_cofinal q' hq'_cut (le_trans hxs (le_of_lt hsv)) hv_lt_c
            refine ⟨extendPoint u, hsv.trans_le ((extendPoint_le_iff q' u).mpr hq'_le_u),
                    hu_lt_c, ⟨u, rfl⟩, ?_⟩
            exact fun h => hD_fail ((stavi_truth_mu_at_point u D_M).mp h)
          · -- s < x < c_inf: use x as stepping stone
            obtain ⟨v, hxv, hv_lt_c, _, hmu_v, _⟩ :=
              h_strict_failure x ⟨le_refl x, hxy⟩ hx_lt_c
            obtain ⟨q', hq'_eq⟩ := hmu_v
            rw [hq'_eq] at hxv hv_lt_c
            have hq'_cut : q' ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
              intro t ht; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb t ht)
            obtain ⟨u, hq'_le_u, _, hu_lt_c, hD_fail⟩ :=
              hD_cofinal q' hq'_cut (le_of_lt hxv) hv_lt_c
            refine ⟨extendPoint u, lt_trans hsx (hxv.trans_le ((extendPoint_le_iff q' u).mpr hq'_le_u)),
                    hu_lt_c, ⟨u, rfl⟩, ?_⟩
            exact fun h => hD_fail ((stavi_truth_mu_at_point u D_M).mp h)
        -- K⁻(¬D_M) TRUE at c_inf in M at rank r:
        have hK_true_c : stavi_temporal_truth_mu M atomMap r c_inf K_minus :=
          h_since_false_c
        -- (2) Transfer K⁻(¬D_M) from c_inf (M) to r2_resp (N) via rank_embed
        -- and formula_agreement at rank r+2.
        -- formula_agreement at index 1 gives:
        --   truth M (r+2) (rank_embed c_inf) A ↔ truth N (r+2) r2_resp A
        -- for all A with depth ≤ r+2.
        -- rank_embed_stavi_truth_mu gives:
        --   truth M (r+2) (rank_embed c_inf) A ↔ truth M r c_inf A
        -- Combining: truth M r c_inf K_minus → truth N (r+2) r2_resp K_minus
        have hform_1 := hform_w ⟨1, by omega⟩ K_minus (by exact hK_depth)
        simp only [game_tuple, show (1 : Nat) ≠ 0 from by omega,
                   show (1 : Nat) ≠ 1 + 1 from by omega,
                   show (1 : Nat) ≠ 1 + 2 from by omega, dite_false,
                   show 1 - 1 = 0 from by omega] at hform_1
        have hM_bridge_K : stavi_temporal_truth_mu M atomMap (r + 2)
            (rank_embed (by omega : r ≤ r + 2) c_inf) K_minus ↔
            stavi_temporal_truth_mu M atomMap r c_inf K_minus :=
          rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) c_inf K_minus
        have hK_true_r2 : stavi_temporal_truth_mu N atomMap (r + 2) r2_resp K_minus :=
          hform_1.mp (hM_bridge_K.mpr hK_true_c)
        -- (3) Since(⊤, D_M) TRUE at r2_resp in N at rank r+2 (for contradiction).
        -- hK_true_r2 gives K_minus = neg(Since(⊤, D_M)), so Since FALSE at r2_resp.
        -- We show Since TRUE at r2_resp: witness s = rank_embed(d) when d is a point.
        -- Unfold K_minus to get ¬∃ form.
        simp only [K_minus, stavi_temporal_truth_mu] at hK_true_r2
        -- hK_true_r2 : ¬∃ s < r2_resp, mu_holds s ∧ ¬(.bot)(s) ∧ ∀ mu u ∈ (s,r2_resp), D_M(u)
        -- Case-split: is d a carrier point or a gap?
        rcases isPoint_or_isGap d with ⟨p_d, hp_d⟩ | ⟨g_d, hg_d⟩
        · -- d = extendPoint p_d: rank_embed d = extendPoint p_d at rank r+2
          apply hK_true_r2
          refine ⟨rank_embed (by omega : r ≤ r + 2) d, h_not_le, ?_, ?_, ?_⟩
          · -- mu_holds (rank_embed d): d is a carrier point, so rank_embed d is too
            exact (rank_embed_mu_holds (by omega : r ≤ r + 2) d).mpr ⟨p_d, hp_d⟩
          · -- ¬ temporal_truth_mu N atomMap (r+2) (rank_embed d) .bot = ¬ False
            simp [temporal_truth_mu]
          · -- ∀ mu u ∈ (rank_embed d, r2_resp), D_M(u) at rank r+2
            intro u hu_gt hu_lt hmu_u
            -- u is a mu-point in (rank_embed d, r2_resp) at rank r+2.
            -- mu_holds u means u = extendPoint q for some q : N.carrier.
            obtain ⟨q, hq⟩ := hmu_u
            rw [hq] at hu_gt hu_lt ⊢
            -- extendPoint q at rank r+2 is Sum.inl q. We need D_M at q.
            -- Use rank_embed_stavi_truth_mu: truth at rank r+2 ↔ truth at rank r.
            -- Sum.inl q = extendPoint q = rank_embed (extendPoint q).
            have hq_eq : (Sum.inl q : ExtendedCarrier N atomMap (r + 2)) =
                rank_embed (by omega : r ≤ r + 2)
                  (extendPoint q : ExtendedCarrier N atomMap r) :=
              (rank_embed_point (by omega : r ≤ r + 2) q).symm
            rw [hq_eq, rank_embed_stavi_truth_mu]
            -- Goal: stavi_temporal_truth_mu N atomMap r (extendPoint q) D_M
            -- rank_embed d < rank_embed (extendPoint q), so d < extendPoint q.
            have hd_lt_q : d < (extendPoint q : ExtendedCarrier N atomMap r) := by
              rw [hq_eq] at hu_gt
              exact (rank_embed_lt (by omega : r ≤ r + 2) d (extendPoint q)).mp hu_gt
            -- extendPoint q < r2_resp ≤ rank_embed y', so extendPoint q < y' at rank r.
            have hr2_le_y' : r2_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
              (ha'_r2 ⟨0, by omega⟩).2
            have hq_lt_y' : (extendPoint q : ExtendedCarrier N atomMap r) < y' := by
              have h1 : rank_embed (by omega : r ≤ r + 2) (extendPoint q : ExtendedCarrier N atomMap r) <
                  rank_embed (by omega : r ≤ r + 2) y' := by
                rw [rank_embed_point]; exact lt_of_lt_of_le hu_lt hr2_le_y'
              exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q) y').mp h1
            -- d ∈ S_C: cont_holds at all mu in (d, y'). Apply to extendPoint q.
            exact hd_in_SC.2 (extendPoint q) hd_lt_q hq_lt_y' (mu_holds_point q) D_M hD_depth hD_interval
        · -- d is a gap: find a carrier point strictly above d and below r2_resp
          -- at rank r+2, then use it as the Since witness.
          -- Since rank_embed d < r2_resp, and rank_embed d is a gap at rank r+2,
          -- there exists a carrier point between them.
          -- Case split on r2_resp: carrier point vs gap at rank r+2.
          rcases isPoint_or_isGap r2_resp with ⟨q_r2, hq_r2⟩ | ⟨g_r2, hg_r2⟩
          · -- r2_resp = extendPoint q_r2 at rank r+2.
            -- q_r2 ∉ (rank_embed_gap g_d).cut (since r2_resp > rank_embed d).
            -- By complement_no_min on rank_embed_gap g_d at rank r+2:
            -- ∃ q' ∉ (rank_embed_gap g_d).cut with q' < q_r2.
            -- Then extendPoint q' at rank r+2 is between rank_embed d and r2_resp.
            have hq_r2_not_cut : q_r2 ∉ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut := by
              rw [rank_embed_gap_cut]
              intro h_in
              have : (extendPoint q_r2 : ExtendedCarrier N atomMap (r + 2)) ≤
                  rank_embed (by omega : r ≤ r + 2) d := by
                rw [hg_d]; exact h_in
              rw [hq_r2] at h_not_le
              exact absurd this (not_le.mpr h_not_le)
            have : ¬ (∀ q, q ∉ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut → q_r2 ≤ q) :=
              fun h => (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.complement_no_min
                ⟨q_r2, hq_r2_not_cut, h⟩
            push_neg at this
            obtain ⟨q', hq'_not_cut, hq'_lt⟩ := this
            have hq'_not_cut_r : q' ∉ g_d.val.cut := by
              rwa [rank_embed_gap_cut] at hq'_not_cut
            -- extendPoint q' > rank_embed d and < r2_resp at rank r+2
            have hq'_gt_d : rank_embed (by omega : r ≤ r + 2) d <
                (extendPoint q' : ExtendedCarrier N atomMap (r + 2)) := by
              rw [show rank_embed (by omega : r ≤ r + 2) d =
                (Sum.inr (rank_embed_gap (by omega : r ≤ r + 2) g_d) :
                  ExtendedCarrier N atomMap (r + 2)) from by rw [hg_d]; rfl]
              constructor
              · exact (show q' ∉ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut from hq'_not_cut)
              · exact (show ¬(q' ∈ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut) from
                  fun h => absurd h (by rwa [rank_embed_gap_cut]))
            have hq'_lt_r2 : (extendPoint q' : ExtendedCarrier N atomMap (r + 2)) < r2_resp := by
              rw [show r2_resp = (Sum.inl q_r2 : ExtendedCarrier N atomMap (r + 2)) from hq_r2]
              exact (extendPoint_lt_iff q' q_r2).mpr hq'_lt
            -- Project to rank r: d < extendPoint q' < y'
            have hd_lt_q'_r : d < (extendPoint q' : ExtendedCarrier N atomMap r) := by
              exact (rank_embed_lt (by omega : r ≤ r + 2) d (extendPoint q')).mp
                (by rw [rank_embed_point]; exact hq'_gt_d)
            have hq'_lt_y'_r : (extendPoint q' : ExtendedCarrier N atomMap r) < y' := by
              have hr2_le_y' : r2_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
                (ha'_r2 ⟨0, by omega⟩).2
              have : (extendPoint q' : ExtendedCarrier N atomMap (r + 2)) <
                  rank_embed (by omega : r ≤ r + 2) y' :=
                lt_of_lt_of_le hq'_lt_r2 hr2_le_y'
              rw [← rank_embed_point (by omega : r ≤ r + 2) q'] at this
              exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q') y').mp this
            -- Use extendPoint q' at rank r+2 as Since witness
            apply hK_true_r2
            refine ⟨extendPoint q', hq'_lt_r2, ⟨q', rfl⟩, ?_, ?_⟩
            · simp [temporal_truth_mu]
            · -- ∀ mu u ∈ (extendPoint q', r2_resp), D_M(u) at rank r+2
              intro u hu_gt hu_lt hmu_u
              obtain ⟨q_u, hq_u⟩ := hmu_u
              rw [hq_u] at hu_gt hu_lt ⊢
              have hq_eq : (Sum.inl q_u : ExtendedCarrier N atomMap (r + 2)) =
                  rank_embed (by omega : r ≤ r + 2)
                    (extendPoint q_u : ExtendedCarrier N atomMap r) :=
                (rank_embed_point (by omega : r ≤ r + 2) q_u).symm
              rw [hq_eq, rank_embed_stavi_truth_mu]
              -- d < extendPoint q' < extendPoint q_u at rank r
              have hd_lt_qu : d < (extendPoint q_u : ExtendedCarrier N atomMap r) := by
                have : (extendPoint q' : ExtendedCarrier N atomMap (r + 2)) <
                    (extendPoint q_u : ExtendedCarrier N atomMap (r + 2)) := hu_gt
                rw [← rank_embed_point (by omega : r ≤ r + 2) q',
                    ← rank_embed_point (by omega : r ≤ r + 2) q_u] at this
                exact lt_trans hd_lt_q'_r
                  ((rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q') (extendPoint q_u)).mp this)
              have hqu_lt_y' : (extendPoint q_u : ExtendedCarrier N atomMap r) < y' := by
                have hr2_le_y' : r2_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
                  (ha'_r2 ⟨0, by omega⟩).2
                have : rank_embed (by omega : r ≤ r + 2) (extendPoint q_u : ExtendedCarrier N atomMap r) <
                    rank_embed (by omega : r ≤ r + 2) y' := by
                  rw [rank_embed_point]; exact lt_of_lt_of_le hu_lt hr2_le_y'
                exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_u) y').mp this
              exact hd_in_SC.2 (extendPoint q_u) hd_lt_qu hqu_lt_y' (mu_holds_point q_u) D_M hD_depth hD_interval
          · -- r2_resp is a gap g_r2 at rank r+2.
            -- g_d.cut ⊂ g_r2.cut (since rank_embed d < r2_resp means the gap is strictly smaller).
            -- Find q ∈ g_r2.cut \ g_d.cut (equivalently, q ∈ g_r2.cut and q ∉ g_d.cut).
            -- Then extendPoint q < r2_resp and extendPoint q > rank_embed d at rank r+2.
            -- First: rank_embed d < Sum.inr g_r2 means (rank_embed_gap g_d).cut ⊆ g_r2.cut
            -- strictly. We need a concrete witness.
            -- g_r2.cut has no supremum in cut (no_sup). g_d.cut ⊂ g_r2.cut.
            -- complement_no_min on rank_embed_gap g_d at rank r+2 says no minimum of
            -- complement. But g_r2.cut \ g_d.cut elements are in the complement of g_d
            -- intersected with g_r2.cut.
            -- Alternative approach: g_r2.cut is proper (≠ univ). g_d.cut ⊂ g_r2.cut.
            -- So ∃ q ∈ g_r2.cut \ g_d.cut. But how to prove this?
            -- Since rank_embed d = Sum.inr (rank_embed_gap g_d) < Sum.inr g_r2 = r2_resp,
            -- we have: (rank_embed_gap g_d).cut ⊂ g_r2.cut.
            -- Specifically, since rank_embed d < r2_resp, there exists q such that
            -- q ∈ g_r2.cut but q ∉ (rank_embed_gap g_d).cut.
            -- The gap ordering Sum.inr g1 < Sum.inr g2 means g1.cut ⊂ g2.cut strictly.
            rw [hg_d] at h_not_le
            -- h_not_le : Sum.inr (rank_embed_gap ... g_d) < Sum.inr g_r2
            -- By gap ordering, (rank_embed_gap g_d).cut ⊊ g_r2.cut
            rw [hg_r2] at h_not_le
            -- Get a carrier point in g_r2.cut \ (rank_embed_gap g_d).cut
            have h_strict_sub : ∃ q, q ∈ g_r2.val.cut ∧ q ∉ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut := by
              by_contra h_eq
              push_neg at h_eq
              -- h_eq : ∀ q, q ∈ g_r2.cut → q ∈ (rank_embed_gap g_d).cut
              -- So g_r2.cut ⊆ (rank_embed_gap g_d).cut
              -- Combined with the ordering, this contradicts strict inclusion.
              -- From h_not_le: Sum.inr (rank_embed_gap g_d) < Sum.inr g_r2
              -- This means (rank_embed_gap g_d).cut ⊂ g_r2.cut or there's a gap ordering.
              -- Actually, the extended ordering for gaps: Sum.inr g1 < Sum.inr g2 iff
              -- g1.cut ⊂ g2.cut (strict). If h_eq gives g_r2.cut ⊆ (rank_embed_gap g_d).cut,
              -- and the ordering gives (rank_embed_gap g_d).cut ⊆ g_r2.cut (from ≤),
              -- then g_r2.cut = (rank_embed_gap g_d).cut. But strict < means ≠.
              -- Actually, let's look at the gap ordering more carefully.
              -- Sum.inr g1 ≤ Sum.inr g2 iff g1.cut ⊆ g2.cut.
              -- So h_not_le says ¬ (Sum.inr g_r2 ≤ Sum.inr (rank_embed_gap g_d)).
              -- Wait, h_not_le says Sum.inr (rank_embed_gap g_d) < Sum.inr g_r2.
              -- The actual definition: Sum.inr g1 ≤ Sum.inr g2 iff g1.cut ⊆ g2.cut.
              -- From h_not_le (< version): (rank_embed_gap g_d).cut ⊆ g_r2.cut and
              --   ¬(g_r2.cut ⊆ (rank_embed_gap g_d).cut).
              -- But h_eq says g_r2.cut ⊆ (rank_embed_gap g_d).cut. Contradiction.
              -- h_not_le : rank_embed d < Sum.inr g_r2
              -- h_eq : g_r2.cut ⊆ (rank_embed_gap g_d).cut
              -- le_of_lt h_not_le: rank_embed d ≤ Sum.inr g_r2
              -- These combine to show rank_embed d = Sum.inr g_r2, contradicting strict <.
              exact absurd (le_antisymm (le_of_lt h_not_le) h_eq) (ne_of_lt h_not_le)
            obtain ⟨q_w, hq_w_in, hq_w_not⟩ := h_strict_sub
            have hq_w_not_gd : q_w ∉ g_d.val.cut := by
              rwa [rank_embed_gap_cut] at hq_w_not
            -- extendPoint q_w at rank r+2 satisfies:
            -- extendPoint q_w < r2_resp (since q_w ∈ g_r2.cut and r2_resp = Sum.inr g_r2)
            -- extendPoint q_w > rank_embed d (since q_w ∉ (rank_embed_gap g_d).cut)
            have hq_w_lt_r2 : (extendPoint q_w : ExtendedCarrier N atomMap (r + 2)) < r2_resp := by
              rw [show r2_resp = (Sum.inr g_r2 : ExtendedCarrier N atomMap (r + 2)) from hg_r2]
              constructor
              · exact (show q_w ∈ g_r2.val.cut from hq_w_in)
              · exact (show ¬(q_w ∉ g_r2.val.cut) from not_not.mpr hq_w_in)
            have hq_w_gt_d_r2 : rank_embed (by omega : r ≤ r + 2) d <
                (extendPoint q_w : ExtendedCarrier N atomMap (r + 2)) := by
              rw [show rank_embed (by omega : r ≤ r + 2) d =
                (Sum.inr (rank_embed_gap (by omega : r ≤ r + 2) g_d) :
                  ExtendedCarrier N atomMap (r + 2)) from by rw [hg_d]; rfl]
              constructor
              · exact (show q_w ∉ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut from hq_w_not)
              · exact (show ¬(q_w ∈ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut) from
                  fun h => absurd h (by rwa [rank_embed_gap_cut]))
            -- Project to rank r
            have hd_lt_qw : d < (extendPoint q_w : ExtendedCarrier N atomMap r) := by
              exact (rank_embed_lt (by omega : r ≤ r + 2) d (extendPoint q_w)).mp
                (by rw [rank_embed_point]; exact hq_w_gt_d_r2)
            have hqw_lt_y' : (extendPoint q_w : ExtendedCarrier N atomMap r) < y' := by
              have hr2_le_y' : r2_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
                (ha'_r2 ⟨0, by omega⟩).2
              have : (extendPoint q_w : ExtendedCarrier N atomMap (r + 2)) <
                  rank_embed (by omega : r ≤ r + 2) y' :=
                lt_of_lt_of_le hq_w_lt_r2 hr2_le_y'
              rw [← rank_embed_point (by omega : r ≤ r + 2) q_w] at this
              exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_w) y').mp this
            -- Use extendPoint q_w as Since witness
            apply hK_true_r2
            refine ⟨extendPoint q_w, hq_w_lt_r2, ⟨q_w, rfl⟩, ?_, ?_⟩
            · simp [temporal_truth_mu]
            · intro u hu_gt hu_lt hmu_u
              obtain ⟨q_u, hq_u⟩ := hmu_u
              rw [hq_u] at hu_gt hu_lt ⊢
              have hq_eq : (Sum.inl q_u : ExtendedCarrier N atomMap (r + 2)) =
                  rank_embed (by omega : r ≤ r + 2)
                    (extendPoint q_u : ExtendedCarrier N atomMap r) :=
                (rank_embed_point (by omega : r ≤ r + 2) q_u).symm
              rw [hq_eq, rank_embed_stavi_truth_mu]
              have hd_lt_qu : d < (extendPoint q_u : ExtendedCarrier N atomMap r) := by
                have : (extendPoint q_w : ExtendedCarrier N atomMap (r + 2)) <
                    (extendPoint q_u : ExtendedCarrier N atomMap (r + 2)) := hu_gt
                rw [← rank_embed_point (by omega : r ≤ r + 2) q_w,
                    ← rank_embed_point (by omega : r ≤ r + 2) q_u] at this
                exact lt_trans hd_lt_qw
                  ((rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_w) (extendPoint q_u)).mp this)
              have hqu_lt_y' : (extendPoint q_u : ExtendedCarrier N atomMap r) < y' := by
                have hr2_le_y' : r2_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
                  (ha'_r2 ⟨0, by omega⟩).2
                have : rank_embed (by omega : r ≤ r + 2) (extendPoint q_u : ExtendedCarrier N atomMap r) <
                    rank_embed (by omega : r ≤ r + 2) y' := by
                  rw [rank_embed_point]; exact lt_of_lt_of_le hu_lt hr2_le_y'
                exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_u) y').mp this
              exact hd_in_SC.2 (extendPoint q_u) hd_lt_qu hqu_lt_y' (mu_holds_point q_u) D_M hD_depth hD_interval
      · -- (B) cont_holds_cross FAILS at c_inf. Direct formula argument.
        -- ¬cont_holds_cross gives A of depth ≤ r with A at all mu in (a_n, y')
        -- but ¬A at c_inf. Formula agreement forces A to fail at r2_resp.
        -- For carrier-point r2_resp above d: A holds (from hd_in_SC.2), contradiction.
        -- For gap r2_resp: requires formula materialization (GHR93 uses C as a
        -- formula, but the Lean code uses a universally-quantified predicate).
        -- This edge case (¬cont_holds_cross at c_inf AND gap r2_resp) requires
        -- materializing the continuation predicate as a single StaviFormula,
        -- which is a blocked dependency (report 39: circularity at this proof stage).
        simp only [cont_holds_cross] at h_cont_c
        push_neg at h_cont_c
        obtain ⟨A_fail, hA_depth, hA_interval, hA_fail_c⟩ := h_cont_c
        -- Formula agreement at index 1: A_fail at rank_embed(c_inf) ↔ A_fail at r2_resp
        have hform_1_A := hform_w ⟨1, by omega⟩ A_fail (le_trans hA_depth (by omega : r ≤ r + 2))
        simp only [game_tuple, show (1 : Nat) ≠ 0 from by omega,
                   show (1 : Nat) ≠ 1 + 1 from by omega,
                   show (1 : Nat) ≠ 1 + 2 from by omega, dite_false,
                   show 1 - 1 = 0 from by omega] at hform_1_A
        -- rank_embed bridge: A_fail at c_inf (rank r) ↔ A_fail at rank_embed(c_inf) (rank r+2)
        have hM_bridge_A : stavi_temporal_truth_mu M atomMap (r + 2)
            (rank_embed (by omega : r ≤ r + 2) c_inf) A_fail ↔
            stavi_temporal_truth_mu M atomMap r c_inf A_fail :=
          rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) c_inf A_fail
        -- A_fail fails at c_inf → fails at rank_embed(c_inf) → fails at r2_resp
        have hA_fail_r2 : ¬ stavi_temporal_truth_mu N atomMap (r + 2) r2_resp A_fail :=
          fun h => hA_fail_c (hM_bridge_A.mp (hform_1_A.mpr h))
        -- Show A_fail holds at r2_resp: case split on carrier point vs gap.
        rcases isPoint_or_isGap r2_resp with ⟨q_r2, hq_r2⟩ | ⟨g_r2, _hg_r2⟩
        · -- r2_resp = extendPoint q_r2 (carrier point). Project to rank r.
          have hd_lt_q : d < (extendPoint q_r2 : ExtendedCarrier N atomMap r) := by
            have : rank_embed (by omega : r ≤ r + 2) d < r2_resp := h_not_le
            rw [hq_r2] at this
            exact (rank_embed_lt (by omega : r ≤ r + 2) d (extendPoint q_r2)).mp
              (by rw [rank_embed_point]; exact this)
          have hq_lt_y' : (extendPoint q_r2 : ExtendedCarrier N atomMap r) < y' := by
            have hr2_le_y' : r2_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
              (ha'_r2 ⟨0, by omega⟩).2
            -- If r2_resp = rank_embed y', then extendPoint q_r2 = y' at rank r.
            -- But then d < y' and a_bwd n < y'. We need STRICT inequality.
            -- From the game: r2_resp is in the closed interval, but we need to
            -- handle the boundary. If extendPoint q_r2 = y', use hd_in_SC differently.
            -- Actually, rank_embed(y') = y' at rank r+2 for carrier/gap points.
            -- If r2_resp < rank_embed(y'): project and we're done.
            -- If r2_resp = rank_embed(y'): need separate argument.
            rcases eq_or_lt_of_le hr2_le_y' with h_eq | h_lt
            · -- r2_resp = rank_embed y'. Show contradiction via order agreement.
              -- rank_embed(c_inf) < r2_resp = rank_embed(y'), so c_inf < y.
              -- order (1,3): rank_embed(c_inf) < rank_embed(y) ↔ r2_resp < rank_embed(y').
              -- r2_resp = rank_embed(y'), so r2_resp < rank_embed(y') is FALSE.
              -- So rank_embed(c_inf) < rank_embed(y) is FALSE, i.e., y ≤ c_inf.
              -- But c_inf ≤ y (from hc_inf_interval.2). So c_inf = y.
              -- hx_lt_c : x < c_inf = y. So x < y and c_inf = y.
              -- c_inf = y means S_C_M's infimum is y. Since y ∈ S_C_M, every
              -- element ≤ y is a lower bound. So c_inf = y only if S_C_M = {y}.
              -- This means cont_holds_cross fails at ALL mu in (x, y).
              -- But h_cofinal_failure_below_c_inf with s = x gives v with x < v ≤ c_inf = y.
              -- If c_inf = y: v ≤ y, so v ∈ [x, y]. ¬cont_holds_cross at v.
              -- This is consistent. But we're trying to show r2_resp ≤ rank_embed(d)
              -- and h_not_le says rank_embed(d) < r2_resp = rank_embed(y').
              -- So d < y'. And d ∈ S_C: cont_holds at all mu in (d, y') in N.
              -- The formula agreement at (0,1) gives:
              --   rank_embed(x) < rank_embed(c_inf) ↔ rank_embed(x') < r2_resp.
              -- Since x < c_inf: rank_embed(x) < rank_embed(c_inf). So rank_embed(x') < r2_resp.
              -- r2_resp = rank_embed(y'). So x' < y'.
              -- At position 1: order (1,3): rank_embed(c_inf) vs rank_embed(y).
              exfalso
              have h_c_eq_y : c_inf = y := by
                apply le_antisymm hc_inf_interval.2
                by_contra h_lt_y
                push_neg at h_lt_y
                have : rank_embed (by omega : r ≤ r + 2) c_inf <
                    rank_embed (by omega : r ≤ r + 2) y :=
                  (rank_embed_lt (by omega : r ≤ r + 2) c_inf y).mpr h_lt_y
                have h13 := (hord_13.1.mp this)
                exact absurd (h_eq ▸ h13) (lt_irrefl _)
              rw [h_c_eq_y] at hx_lt_c
              -- x < y = c_inf. hx_eq_c case was already handled, so this is the
              -- strict case. We need to derive contradiction.
              -- c_inf = y: order (0,1) gives x < y ↔ x' < r2_resp.
              -- We have x < y. So x' < r2_resp = rank_embed(y').
              -- i.e., x' < y'. Also, rank_embed(d) < r2_resp = rank_embed(y'), so d < y'.
              -- Use hA_fail_r2: A_fail fails at r2_resp = rank_embed(y').
              -- But A_fail holds at all mu in (a_bwd n, y') in N (from hA_interval).
              -- If y' is a carrier point at rank r: rank_embed(y') = extendPoint(q_r2)
              -- at rank r+2. Projecting: extendPoint(q_r2) = y' at rank r.
              -- But we need A_fail to hold at y', which requires y' to be in
              -- (a_bwd n, y'), which is vacuous (y' is not < y').
              -- This sub-case needs the game's winning condition more carefully.
              -- For now, this is an edge case within an edge case.
              -- The r2_resp = rank_embed(y') case forces c_inf = y, and the
              -- argument needs either the full formula materialization or a
              -- dedicated boundary lemma.
              sorry
            · -- r2_resp < rank_embed y'. Project to rank r.
              have hr2_lt : r2_resp < rank_embed (by omega : r ≤ r + 2) y' := h_lt
              have : rank_embed (by omega : r ≤ r + 2)
                  (extendPoint q_r2 : ExtendedCarrier N atomMap r) <
                  rank_embed (by omega : r ≤ r + 2) y' := by
                rw [rank_embed_point]
                rw [show r2_resp = (extendPoint q_r2 : ExtendedCarrier N atomMap (r + 2)) from hq_r2] at hr2_lt
                exact hr2_lt
              exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_r2) y').mp this
          -- A_fail holds at extendPoint q_r2 at rank r (from hd_in_SC.2)
          have hA_holds_q : stavi_temporal_truth_mu N atomMap r
              (extendPoint q_r2 : ExtendedCarrier N atomMap r) A_fail :=
            hd_in_SC.2 (extendPoint q_r2) hd_lt_q hq_lt_y' (mu_holds_point q_r2)
              A_fail hA_depth hA_interval
          -- Bridge to rank r+2
          have hN_bridge : stavi_temporal_truth_mu N atomMap (r + 2)
              (extendPoint q_r2 : ExtendedCarrier N atomMap (r + 2)) A_fail ↔
              stavi_temporal_truth_mu N atomMap r
                (extendPoint q_r2 : ExtendedCarrier N atomMap r) A_fail := by
            conv_lhs => rw [show (extendPoint q_r2 : ExtendedCarrier N atomMap (r + 2)) =
              rank_embed (by omega : r ≤ r + 2)
                (extendPoint q_r2 : ExtendedCarrier N atomMap r) from
              (rank_embed_point (by omega : r ≤ r + 2) q_r2).symm]
            exact rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) (extendPoint q_r2) A_fail
          -- A_fail holds at r2_resp at rank r+2
          have hA_holds_r2 : stavi_temporal_truth_mu N atomMap (r + 2) r2_resp A_fail := by
            rw [hq_r2]; exact hN_bridge.mpr hA_holds_q
          exact hA_fail_r2 hA_holds_r2
        · -- r2_resp is a gap at rank r+2.
          -- This edge case (¬cont_holds_cross at c_inf + gap r2_resp) requires
          -- materializing the continuation predicate as a formula (GHR93 uses C
          -- as a concrete formula, but the Lean code uses a predicate).
          -- Blocked: report 39 confirms formula materialization is circular.
          sorry
  -- Direction 2: rank_embed(d) ≤ r2_resp
  -- GHR93 Claim 1 Step 2.3: game Round 2 argument.
  have h_r2_resp_ge_d : rank_embed (by omega : r ≤ r + 2) d ≤ r2_resp := by
    -- By contradiction: assume r2_resp < rank_embed(d).
    by_contra h_not_le
    push_neg at h_not_le
    -- h_not_le : r2_resp < rank_embed d
    -- From h_cont_transfer: any mu p with r2_resp < extendPoint(p) and p < y'
    -- satisfies cont_holds at p.
    -- From h_cofinal_failure_below_d: for any s < d, ∃ mu v with s < v ≤ d,
    -- v < y', ¬cont_holds v.
    -- Case split on whether r2_resp is a carrier point or gap.
    rcases isPoint_or_isGap r2_resp with ⟨p_resp, hp_resp⟩ | ⟨g_resp, hg_resp⟩
    · -- r2_resp = extendPoint(p_resp): carrier point case.
      -- extendPoint(p_resp) < rank_embed(d) at rank r+2.
      -- Project to rank r: extendPoint(p_resp) < d.
      have hp_lt_d : (extendPoint p_resp : ExtendedCarrier N atomMap r) < d := by
        -- r2_resp < rank_embed(d) at rank r+2, and r2_resp = extendPoint(p_resp) at rank r+2
        -- extendPoint(p_resp) at rank r+2 = rank_embed(extendPoint(p_resp) at rank r)
        -- So rank_embed(extendPoint(p_resp)) < rank_embed(d), hence extendPoint(p_resp) < d
        have : r2_resp < rank_embed (by omega : r ≤ r + 2) d := h_not_le
        rw [hp_resp] at this
        -- this : Sum.inl p_resp < rank_embed d, where Sum.inl p_resp = extendPoint p_resp at rank r+2
        -- = rank_embed (extendPoint p_resp at rank r) by rank_embed_point
        exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint p_resp) d).mp
          (show rank_embed (by omega : r ≤ r + 2) (extendPoint p_resp : ExtendedCarrier N atomMap r)
            < rank_embed (by omega : r ≤ r + 2) d from by
              simp only [rank_embed_point]; exact this)
      -- extendPoint(p_resp) ∈ [x', y']
      have hp_in : inClosedInterval x' y' (extendPoint p_resp : ExtendedCarrier N atomMap r) := by
        have h_r2 := ha'_r2 ⟨0, by omega⟩
        rw [show a'_r2 ⟨0, by omega⟩ = r2_resp from r2_resp_def.symm, hp_resp] at h_r2
        constructor
        · exact (rank_embed_le (by omega : r ≤ r + 2) x' (extendPoint p_resp)).mp
            (show rank_embed (by omega : r ≤ r + 2) x' ≤
              rank_embed (by omega : r ≤ r + 2) (extendPoint p_resp : ExtendedCarrier N atomMap r) from by
              simp only [rank_embed_point]; exact h_r2.1)
        · exact (rank_embed_le (by omega : r ≤ r + 2) (extendPoint p_resp) y').mp
            (show rank_embed (by omega : r ≤ r + 2) (extendPoint p_resp : ExtendedCarrier N atomMap r) ≤
              rank_embed (by omega : r ≤ r + 2) y' from by
              simp only [rank_embed_point]; exact h_r2.2)
      -- Cofinal failure: ∃ mu v with extendPoint(p_resp) < v ≤ d, ¬cont_holds v
      obtain ⟨v, hpv, hv_le_d, hvy', hmu_v, h_not_cont_v⟩ :=
        h_cofinal_failure_below_d (extendPoint p_resp) hp_in hp_lt_d
      obtain ⟨q, hq⟩ := hmu_v
      rw [hq] at hpv hv_le_d hvy' h_not_cont_v
      -- rank_embed(extendPoint(q)) > r2_resp at rank r+2
      have hr2_lt_q : r2_resp < (extendPoint q : ExtendedCarrier N atomMap (r + 2)) := by
        rw [hp_resp]
        show (extendPoint p_resp : ExtendedCarrier N atomMap (r + 2)) <
          (extendPoint q : ExtendedCarrier N atomMap (r + 2))
        have h := (rank_embed_lt (by omega : r ≤ r + 2)
          (extendPoint p_resp : ExtendedCarrier N atomMap r)
          (extendPoint q : ExtendedCarrier N atomMap r)).mpr hpv
        simp only [rank_embed_point] at h
        exact h
      -- h_cont_transfer gives cont_holds at q, contradicting ¬cont_holds
      exact h_not_cont_v (h_cont_transfer q hr2_lt_q hvy')
    · -- r2_resp is a gap, r2_resp < rank_embed(d). Use order agreement.
      -- Extract order agreement for boundary analysis.
      obtain ⟨p_N₂, hp_N₂⟩ := h_pt
      have hp_N₂_r2 : inClosedInterval
          (rank_embed (by omega : r ≤ r + 2) x')
          (rank_embed (by omega : r ≤ r + 2) y')
          (extendPoint p_N₂ : ExtendedCarrier N atomMap (r + 2)) := by
        rw [← rank_embed_point (by omega : r ≤ r + 2) p_N₂]
        exact (rank_embed_inClosedInterval (by omega : r ≤ r + 2) x' y'
          (extendPoint p_N₂)).mpr hp_N₂
      obtain ⟨b_w₂, _, hcond_w₂⟩ := hwin_r2 p_N₂ hp_N₂_r2
      obtain ⟨hord_w₂, _, _⟩ := hcond_w₂
      -- Order (1,3): rank_embed(c_inf) < rank_embed(y) ↔ r2_resp < rank_embed(y')
      have hord_13₂ := hord_w₂ ⟨1, by omega⟩ ⟨3, by omega⟩
      simp only [game_tuple, show (1 : Nat) ≠ 0 from by omega,
                 show (1 : Nat) ≠ 1 + 1 from by omega,
                 show (1 : Nat) ≠ 1 + 2 from by omega, dite_false,
                 show 1 - 1 = 0 from by omega,
                 show (3 : Nat) ≠ 0 from by omega,
                 show ¬((3 : Nat) = 1 + 1) from by omega,
                 show (3 : Nat) = 1 + 2 from by omega, dite_true] at hord_13₂
      -- Also extract (0,1)
      have hord_01₂ := hord_w₂ ⟨0, by omega⟩ ⟨1, by omega⟩
      simp only [game_tuple, show (0 : Nat) = 0 from rfl, dite_true,
                 show (1 : Nat) ≠ 0 from by omega,
                 show (1 : Nat) ≠ 1 + 1 from by omega,
                 show (1 : Nat) ≠ 1 + 2 from by omega, dite_false,
                 show 1 - 1 = 0 from by omega] at hord_01₂
      -- Case split: c_inf = y (right boundary) or c_inf < y
      rcases eq_or_lt_of_le hc_inf_interval.2 with hc_eq_y | hc_lt_y
      · -- c_inf = y: order (1,3) equality gives r2_resp = rank_embed(y')
        have h_eq : rank_embed (by omega : r ≤ r + 2) c_inf =
            rank_embed (by omega : r ≤ r + 2) y := by rw [hc_eq_y]
        have h_r2_eq_y' : a'_r2 ⟨0, by omega⟩ = rank_embed (by omega : r ≤ r + 2) y' :=
          hord_13₂.2.mp h_eq
        -- r2_resp = rank_embed(y') ≥ rank_embed(d)
        have : r2_resp = rank_embed (by omega : r ≤ r + 2) y' := h_r2_eq_y'
        have hd_le_y' : rank_embed (by omega : r ≤ r + 2) d ≤
            rank_embed (by omega : r ≤ r + 2) y' :=
          (rank_embed_le (by omega : r ≤ r + 2) d y').mpr hd_interval.2
        exact absurd (this ▸ hd_le_y') (not_le.mpr h_not_le)
      · -- c_inf < y and c_inf > x (interior case)
        -- c_inf = x boundary case
        rcases eq_or_lt_of_le hc_inf_interval.1 with hx_eq_c | hx_lt_c
        · -- x = c_inf: order (0,1) equality gives r2_resp = rank_embed(x')
          have h_eq : rank_embed (by omega : r ≤ r + 2) x =
              rank_embed (by omega : r ≤ r + 2) c_inf := by rw [hx_eq_c]
          have h_r2_eq_x' : rank_embed (by omega : r ≤ r + 2) x' = a'_r2 ⟨0, by omega⟩ :=
            hord_01₂.2.mp h_eq
          -- r2_resp = rank_embed(x') ≤ rank_embed(d)
          have hx'_le_d : rank_embed (by omega : r ≤ r + 2) x' ≤
              rank_embed (by omega : r ≤ r + 2) d :=
            (rank_embed_le (by omega : r ≤ r + 2) x' d).mpr hd_interval.1
          -- h_not_le : r2_resp < rank_embed(d)
          -- This is consistent with r2_resp ≤ rank_embed(d). No contradiction here.
          -- But: r2_resp is a gap (Sum.inr g_resp).
          -- rank_embed(x') might equal rank_embed(d) or be strictly less.
          -- If r2_resp = rank_embed(x') and x' = d: r2_resp = rank_embed(d).
          -- Contradicts h_not_le: r2_resp < rank_embed(d).
          -- If x' < d: r2_resp = rank_embed(x') < rank_embed(d). Consistent.
          -- r2_resp = rank_embed(x') (from h_r2_eq_x') and r2_resp < rank_embed(d),
          -- so rank_embed(x') < rank_embed(d) hence x' < d.
          -- Use h_cofinal_failure_below_d to get a mu-point u with x' < u < y' and ¬cont_holds.
          -- Since r2_resp = rank_embed(x') < rank_embed(u) (carrier point above x'),
          -- h_cont_transfer gives cont_holds at u. Contradiction.
          have hx'_lt_d : x' < d := by
            have : rank_embed (by omega : r ≤ r + 2) x' < rank_embed (by omega : r ≤ r + 2) d := by
              calc rank_embed (by omega : r ≤ r + 2) x' = a'_r2 ⟨0, by omega⟩ := h_r2_eq_x'
                _ = r2_resp := r2_resp_def.symm
                _ < rank_embed (by omega : r ≤ r + 2) d := h_not_le
            exact (rank_embed_lt (by omega : r ≤ r + 2) x' d).mp this
          obtain ⟨u, hx'u, hud, huy', hmu_u, h_not_cont_u⟩ :=
            h_cofinal_failure_below_d x' ⟨le_refl x', hx'y'⟩ hx'_lt_d
          obtain ⟨q_u, hq_u⟩ := hmu_u
          rw [hq_u] at hx'u huy' h_not_cont_u
          -- r2_resp = rank_embed(x') < extendPoint(q_u) at rank r+2
          have hr2_lt_qu : r2_resp <
              (extendPoint q_u : ExtendedCarrier N atomMap (r + 2)) := by
            calc r2_resp = a'_r2 ⟨0, by omega⟩ := r2_resp_def.symm
              _ = rank_embed (by omega : r ≤ r + 2) x' := h_r2_eq_x'.symm
              _ < rank_embed (by omega : r ≤ r + 2) (extendPoint q_u) := by
                  exact (rank_embed_lt (by omega : r ≤ r + 2) x' (extendPoint q_u)).mpr hx'u
              _ = extendPoint q_u := rank_embed_point (by omega : r ≤ r + 2) q_u
          exact h_not_cont_u (h_cont_transfer q_u hr2_lt_qu huy')
        · -- Interior case: x < c_inf < y, gap, r2_resp < rank_embed(d).
          -- Strategy: find carrier point q ∉ g_resp.val.cut with extendPoint q < d,
          -- then h_cofinal_failure_below_d gives failure u above q. By downward-closure
          -- of the gap's cut, u's carrier point is also ∉ cut, so r2_resp < u at rank r+2.
          -- h_cont_transfer gives cont_holds at u, contradicting the failure.
          --
          -- Step 1: x' < d from order agreement
          have hx'_lt_d : x' < d := by
            have hx_lt_c_r2 : rank_embed (by omega : r ≤ r + 2) x <
                rank_embed (by omega : r ≤ r + 2) c_inf :=
              (rank_embed_lt (by omega : r ≤ r + 2) x c_inf).mpr hx_lt_c
            have hx'_lt_r2 : rank_embed (by omega : r ≤ r + 2) x' < r2_resp := by
              rw [show r2_resp = a'_r2 ⟨0, by omega⟩ from r2_resp_def.symm]
              exact hord_01₂.1.mp hx_lt_c_r2
            exact (rank_embed_lt (by omega : r ≤ r + 2) x' d).mp
              (lt_trans hx'_lt_r2 h_not_le)
          -- Step 2: Find a carrier point q ∉ g_resp.val.cut with extendPoint q < d.
          -- Case split on d being a point or gap.
          rcases isPoint_or_isGap d with ⟨p_d, hp_d⟩ | ⟨g_d, hg_d⟩
          · -- d = extendPoint p_d (carrier point)
            -- p_d ∉ g_resp.val.cut (since r2_resp < rank_embed(d) = extendPoint p_d)
            have hp_d_not_cut : p_d ∉ g_resp.val.cut := by
              intro hp_d_in
              -- extendPoint p_d ≤ Sum.inr g_resp = r2_resp
              have h_le : (extendPoint p_d : ExtendedCarrier N atomMap (r + 2)) ≤ r2_resp := by
                rw [hg_resp]; exact hp_d_in
              -- r2_resp < rank_embed(d) = extendPoint p_d
              have h_eq : rank_embed (by omega : r ≤ r + 2) d =
                  (extendPoint p_d : ExtendedCarrier N atomMap (r + 2)) := by
                rw [hp_d]; exact rank_embed_point (by omega : r ≤ r + 2) p_d
              exact absurd (h_eq ▸ h_not_le) (not_lt.mpr h_le)
            -- complement_no_min: ∃ q < p_d with q ∉ cut
            have h_comp_no_min := g_resp.val.complement_no_min
            push_neg at h_comp_no_min
            -- h_comp_no_min says: no minimum in complement.
            -- Since p_d ∉ cut: ∃ q ∉ cut, q < p_d.
            -- Actually complement_no_min = ¬∃ m, m ∉ cut ∧ ∀ y, y ∉ cut → m ≤ y
            -- We need to extract: ∃ q ∉ cut, q < p_d.
            -- From complement_no_min applied to p_d:
            obtain ⟨q, hq_not_cut, hq_lt_pd⟩ :
                ∃ q : N.carrier, q ∉ g_resp.val.cut ∧ q < p_d := by
              by_contra h_all
              push_neg at h_all
              -- h_all : ∀ q, q ∉ g_resp.val.cut → p_d ≤ q
              -- So p_d is a minimum of the complement
              exact g_resp.val.complement_no_min ⟨p_d, hp_d_not_cut, h_all⟩
            -- extendPoint q < d at rank r
            have hq_lt_d : (extendPoint q : ExtendedCarrier N atomMap r) < d := by
              rw [hp_d]
              exact (extendPoint_lt_iff q p_d).mpr hq_lt_pd
            -- r2_resp < extendPoint q at rank r+2
            have hr2_lt_q : r2_resp <
                (extendPoint q : ExtendedCarrier N atomMap (r + 2)) := by
              rw [hg_resp]; exact lt_of_not_ge (fun h => hq_not_cut h)
            -- x' < extendPoint q
            have hx'_lt_q : x' < (extendPoint q : ExtendedCarrier N atomMap r) := by
              have : rank_embed (by omega : r ≤ r + 2) x' <
                  (extendPoint q : ExtendedCarrier N atomMap (r + 2)) := by
                exact lt_trans (by
                  rw [show r2_resp = a'_r2 ⟨0, by omega⟩ from r2_resp_def.symm]
                  exact hord_01₂.1.mp
                    ((rank_embed_lt (by omega : r ≤ r + 2) x c_inf).mpr hx_lt_c))
                  hr2_lt_q
              rw [← rank_embed_point (by omega : r ≤ r + 2) q] at this
              exact (rank_embed_lt (by omega : r ≤ r + 2) x' (extendPoint q)).mp this
            -- extendPoint q ∈ [x', y']
            have hq_interval : inClosedInterval x' y'
                (extendPoint q : ExtendedCarrier N atomMap r) :=
              ⟨le_of_lt hx'_lt_q, le_trans (le_of_lt hq_lt_d) hd_interval.2⟩
            -- Apply h_cofinal_failure_below_d at extendPoint q
            obtain ⟨u, hqu, hud, huy', hmu_u, h_not_cont_u⟩ :=
              h_cofinal_failure_below_d (extendPoint q) hq_interval hq_lt_d
            obtain ⟨q_u, hq_u⟩ := hmu_u
            rw [hq_u] at hqu hud huy' h_not_cont_u
            -- q < q_u (from extendPoint q < extendPoint q_u)
            have hq_lt_qu : q < q_u := (extendPoint_lt_iff q q_u).mp hqu
            -- q_u ∉ g_resp.val.cut (downward-closure contrapositive)
            have hqu_not_cut : q_u ∉ g_resp.val.cut := by
              intro hqu_in
              exact hq_not_cut (g_resp.val.downward_closed q_u q hqu_in (le_of_lt hq_lt_qu))
            -- r2_resp < extendPoint q_u at rank r+2
            have hr2_lt_qu : r2_resp <
                (extendPoint q_u : ExtendedCarrier N atomMap (r + 2)) := by
              rw [hg_resp]; exact lt_of_not_ge (fun h => hqu_not_cut h)
            -- h_cont_transfer gives cont_holds at q_u
            exact h_not_cont_u (h_cont_transfer q_u hr2_lt_qu huy')
          · -- d = Sum.inr g_d (gap case)
            -- r2_resp < rank_embed(d) where both are gaps.
            -- rank_embed(d) = Sum.inr (rank_embed_gap g_d) with same cut as g_d.
            -- g_resp.val.cut ⊊ g_d.val.cut (from r2_resp < rank_embed(d)).
            -- Extract q ∈ g_d.val.cut \ g_resp.val.cut.
            -- Extract q ∈ g_d.val.cut \ g_resp.val.cut from strict gap ordering.
            -- r2_resp < rank_embed(d) at rank r+2, with both being gaps.
            -- This means g_resp.val.cut ⊂ g_d.val.cut (via rank_embed_gap_cut).
            obtain ⟨q, hq_in_gd, hq_not_gr⟩ : ∃ q, q ∈ g_d.val.cut ∧ q ∉ g_resp.val.cut := by
              -- r2_resp ≤ rank_embed(d) gives g_resp.val.cut ⊆ g_d.val.cut (via rank_embed_gap_cut)
              -- r2_resp < rank_embed(d) gives ¬(g_d.val.cut ⊆ g_resp.val.cut) (strict)
              -- So ∃ q ∈ g_d.val.cut \ g_resp.val.cut
              by_contra h_all
              push_neg at h_all
              -- h_all : ∀ q ∈ g_d.val.cut, q ∈ g_resp.val.cut, i.e., g_d.val.cut ⊆ g_resp.val.cut
              -- Combined with g_resp.val.cut ⊆ g_d.val.cut (from ≤): cuts are equal
              -- Equal cuts at rank r+2 means equal gaps, so r2_resp = rank_embed(d), contradicting <
              have h_cut_eq : g_resp.val.cut = g_d.val.cut := by
                apply Set.Subset.antisymm
                · -- g_resp ⊆ g_d: from r2_resp ≤ rank_embed(d), le part
                  intro p hp
                  -- hp : p ∈ g_resp.val.cut, meaning extendPoint p ≤ r2_resp
                  -- From r2_resp ≤ rank_embed(d) and transitivity:
                  -- extendPoint p ≤ rank_embed(d) = Sum.inr (rank_embed_gap g_d)
                  -- So p ∈ (rank_embed_gap g_d).val.cut = g_d.val.cut
                  have h1 : (extendPoint p : ExtendedCarrier N atomMap (r + 2)) ≤ r2_resp := by
                    rw [hg_resp]; exact hp
                  have h2 : (extendPoint p : ExtendedCarrier N atomMap (r + 2)) ≤
                      rank_embed (by omega : r ≤ r + 2) d := le_trans h1 (le_of_lt h_not_le)
                  rw [hg_d, rank_embed_gap_eq] at h2
                  rwa [show (extendPoint p : ExtendedCarrier N atomMap (r + 2)) ≤
                      (Sum.inr (rank_embed_gap (by omega : r ≤ r + 2) g_d) :
                      ExtendedCarrier N atomMap (r + 2)) ↔
                      p ∈ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut from Iff.rfl,
                    rank_embed_gap_cut] at h2
                · exact h_all
              -- Equal cuts means equal gaps (gap_ext), so r2_resp = rank_embed(d)
              have h_gap_eq : g_resp = rank_embed_gap (by omega : r ≤ r + 2) g_d := by
                exact Subtype.ext (gap_ext g_resp.val (rank_embed_gap (by omega : r ≤ r + 2) g_d).val
                  (by rw [rank_embed_gap_cut]; exact h_cut_eq))
              have h_eq : r2_resp = rank_embed (by omega : r ≤ r + 2) d := by
                rw [hg_resp, hg_d, rank_embed_gap_eq]
                exact congrArg Sum.inr h_gap_eq
              exact absurd h_eq (ne_of_lt h_not_le)
            -- extendPoint q < d at rank r (since q ∈ g_d.val.cut)
            have hq_lt_d : (extendPoint q : ExtendedCarrier N atomMap r) < d := by
              rw [hg_d]
              -- q ∈ g_d.val.cut means extendPoint q ≤ Sum.inr g_d
              -- strict because Sum.inl ≠ Sum.inr
              have h_le : (extendPoint q : ExtendedCarrier N atomMap r) ≤ Sum.inr g_d := hq_in_gd
              have h_ne : (extendPoint q : ExtendedCarrier N atomMap r) ≠ Sum.inr g_d := by
                simp [extendPoint]
              exact lt_of_le_of_ne h_le h_ne
            -- r2_resp < extendPoint q at rank r+2
            have hr2_lt_q : r2_resp <
                (extendPoint q : ExtendedCarrier N atomMap (r + 2)) := by
              rw [hg_resp]; exact lt_of_not_ge (fun h => hq_not_gr h)
            -- x' < extendPoint q
            have hx'_lt_q : x' < (extendPoint q : ExtendedCarrier N atomMap r) := by
              have : rank_embed (by omega : r ≤ r + 2) x' <
                  (extendPoint q : ExtendedCarrier N atomMap (r + 2)) := by
                exact lt_trans (by
                  rw [show r2_resp = a'_r2 ⟨0, by omega⟩ from r2_resp_def.symm]
                  exact hord_01₂.1.mp
                    ((rank_embed_lt (by omega : r ≤ r + 2) x c_inf).mpr hx_lt_c))
                  hr2_lt_q
              rw [← rank_embed_point (by omega : r ≤ r + 2) q] at this
              exact (rank_embed_lt (by omega : r ≤ r + 2) x' (extendPoint q)).mp this
            -- extendPoint q ∈ [x', y']
            have hq_interval : inClosedInterval x' y'
                (extendPoint q : ExtendedCarrier N atomMap r) :=
              ⟨le_of_lt hx'_lt_q, le_trans (le_of_lt hq_lt_d) hd_interval.2⟩
            -- Apply h_cofinal_failure_below_d
            obtain ⟨u, hqu, hud, huy', hmu_u, h_not_cont_u⟩ :=
              h_cofinal_failure_below_d (extendPoint q) hq_interval hq_lt_d
            obtain ⟨q_u, hq_u⟩ := hmu_u
            rw [hq_u] at hqu hud huy' h_not_cont_u
            have hq_lt_qu : q < q_u := (extendPoint_lt_iff q q_u).mp hqu
            have hqu_not_cut : q_u ∉ g_resp.val.cut := by
              intro hqu_in
              exact hq_not_gr (g_resp.val.downward_closed q_u q hqu_in (le_of_lt hq_lt_qu))
            have hr2_lt_qu : r2_resp <
                (extendPoint q_u : ExtendedCarrier N atomMap (r + 2)) := by
              rw [hg_resp]; exact lt_of_not_ge (fun h => hqu_not_cut h)
            exact h_not_cont_u (h_cont_transfer q_u hr2_lt_qu huy')
  have h_r2_eq : r2_resp = rank_embed (by omega : r ≤ r + 2) d :=
    le_antisymm h_r2_resp_le_d h_r2_resp_ge_d
  -- Step 6: Get winning condition from rank-(r+2) game for extraction.
  obtain ⟨p_N, hp_N⟩ := h_pt
  have hp_N_r2 : inClosedInterval
      (rank_embed (by omega : r ≤ r + 2) x')
      (rank_embed (by omega : r ≤ r + 2) y')
      (extendPoint p_N) := by
    rw [← rank_embed_point (by omega : r ≤ r + 2) p_N]
    exact (rank_embed_inClosedInterval (by omega : r ≤ r + 2) x' y'
      (extendPoint p_N)).mpr hp_N
  obtain ⟨b_play, hb_play, hcond_play⟩ := hwin_r2 p_N hp_N_r2
  obtain ⟨hord_play, hgp_play, hform_play⟩ := hcond_play
  -- game_tuple indices for k=1 at rank r+2:
  -- 0 = rank_embed(x) / rank_embed(x')
  -- 1 = rank_embed(c_inf) / r2_resp
  -- 2 = extendPoint(b_play) / extendPoint(p_N)
  -- 3 = rank_embed(y) / rank_embed(y')
  -- Extract formula agreement at index 1 at depth r+2:
  have hform_r2_1 : ∀ A : StaviFormula, stavi_depth A ≤ r + 2 →
      (stavi_temporal_truth_mu M atomMap (r + 2)
        (rank_embed (by omega : r ≤ r + 2) c_inf) A ↔
       stavi_temporal_truth_mu N atomMap (r + 2) r2_resp A) := by
    intro A hA
    have h := hform_play ⟨1, by omega⟩ A hA
    simp only [game_tuple, show (1 : Nat) ≠ 0 from by omega,
               show (1 : Nat) ≠ 1 + 1 from by omega,
               show (1 : Nat) ≠ 1 + 2 from by omega, dite_false,
               show 1 - 1 = 0 from by omega] at h
    exact h
  -- Rewrite using h_r2_eq: r2_resp = rank_embed(d)
  rw [h_r2_eq] at hform_r2_1
  -- Step 8: Project formula agreement from rank r+2 to rank r via rank_embed_stavi_truth_mu.
  have hform_cd : ∀ A : StaviFormula, stavi_depth A ≤ r →
      (stavi_temporal_truth_mu M atomMap r c_inf A ↔
       stavi_temporal_truth_mu N atomMap r d A) := by
    intro A hA
    have h_depth_r2 : stavi_depth A ≤ r + 2 := le_trans hA (by omega)
    calc stavi_temporal_truth_mu M atomMap r c_inf A
        ↔ stavi_temporal_truth_mu M atomMap (r + 2)
            (rank_embed (by omega : r ≤ r + 2) c_inf) A :=
          (rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) c_inf A).symm
      _ ↔ stavi_temporal_truth_mu N atomMap (r + 2)
            (rank_embed (by omega : r ≤ r + 2) d) A :=
          hform_r2_1 A h_depth_r2
      _ ↔ stavi_temporal_truth_mu N atomMap r d A :=
          rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) d A
  -- Step 9: Gap/point agreement from rank-(r+2) game, projected to rank r.
  -- rank_embed preserves IsPoint: IsPoint(rank_embed e) ↔ IsPoint e
  -- IsGap = ¬IsPoint (from isPoint_or_isGap), so IsGap also preserved.
  have hgp_r2_1 := hgp_play ⟨1, by omega⟩
  simp only [game_tuple, show (1 : Nat) ≠ 0 from by omega,
             show (1 : Nat) ≠ 1 + 1 from by omega,
             show (1 : Nat) ≠ 1 + 2 from by omega, dite_false,
             show 1 - 1 = 0 from by omega] at hgp_r2_1
  have h_a'_r2_eq_d : a'_r2 ⟨0, by omega⟩ = rank_embed (by omega : r ≤ r + 2) d :=
    r2_resp_def ▸ h_r2_eq
  rw [h_a'_r2_eq_d] at hgp_r2_1
  have hgp_cd : (IsPoint c_inf ↔ IsPoint d) ∧ (IsGap c_inf ↔ IsGap d) := by
    refine ⟨(rank_embed_isPoint _ c_inf).symm.trans
      (hgp_r2_1.1.trans (rank_embed_isPoint _ d)), ?_⟩
    cases c_inf with
    | inl x =>
      cases d with
      | inl y => simp [IsGap]
      | inr g =>
        exfalso
        have := hgp_r2_1.1.mp ⟨x, rfl⟩
        exact (by simp [rank_embed, IsPoint] at this : False)
    | inr g =>
      cases d with
      | inl y =>
        exfalso
        have := hgp_r2_1.1.mpr ⟨y, rfl⟩
        exact (by simp [rank_embed, IsPoint] at this : False)
      | inr g' => simp [IsGap]
  -- Step 10: Boundary correspondence from rank-(r+2) game, projected to rank r.
  have hord_r2_01 := hord_play ⟨0, by omega⟩ ⟨1, by omega⟩
  simp only [game_tuple, show (0 : Nat) = 0 from rfl, dite_true,
             show (1 : Nat) ≠ 0 from by omega,
             show (1 : Nat) ≠ 1 + 1 from by omega,
             show (1 : Nat) ≠ 1 + 2 from by omega, dite_false,
             show 1 - 1 = 0 from by omega] at hord_r2_01
  have hord_r2_13 := hord_play ⟨1, by omega⟩ ⟨3, by omega⟩
  simp only [game_tuple, show (1 : Nat) ≠ 0 from by omega,
             show (1 : Nat) ≠ 1 + 1 from by omega,
             show (1 : Nat) ≠ 1 + 2 from by omega, dite_false,
             show 1 - 1 = 0 from by omega,
             show (3 : Nat) ≠ 0 from by omega,
             show ¬((3 : Nat) = 1 + 1) from by omega,
             show (3 : Nat) = 1 + 2 from by omega, dite_true] at hord_r2_13
  rw [h_a'_r2_eq_d] at hord_r2_01 hord_r2_13
  -- Project boundary from rank r+2 to rank r using rank_embed injectivity.
  have hbdy_cd : (x = c_inf ↔ x' = d) ∧ (c_inf = y ↔ d = y') := by
    have re_eq : ∀ (S : OrderedMonadicStructure sig) (aM : Formula → sig.preds)
        (a b : ExtendedCarrier S aM r),
        rank_embed (by omega : r ≤ r + 2) a = rank_embed (by omega : r ≤ r + 2) b ↔ a = b := by
      intro S aM a b
      constructor
      · intro h
        exact le_antisymm ((rank_embed_le _ a b).mp (le_of_eq h))
          ((rank_embed_le _ b a).mp (le_of_eq h.symm))
      · intro h; rw [h]
    constructor
    · rw [← re_eq M atomMap x c_inf, ← re_eq N atomMap x' d]
      exact hord_r2_01.2
    · rw [← re_eq M atomMap c_inf y, ← re_eq N atomMap d y']
      exact hord_r2_13.2
  -- Step 11: GHR93 Claim 1 interior case (left).
  -- For any Spoiler selection a_pad ending with c_inf, construct Duplicator's
  -- response with d at position 1+3n using rank_down + K⁻(¬D) position tracking.
  have h_interior_left : x' ≠ d → d ≠ y' →
      ∀ (a_pad : Fin (1 + 3 * n + 1) → ExtendedCarrier M atomMap r),
        (∀ i, inClosedInterval x y (a_pad i)) →
        a_pad ⟨1 + 3 * n, by omega⟩ = c_inf →
        ∃ (a'_full : Fin (1 + 3 * n + 1) → ExtendedCarrier N atomMap r),
          (∀ i, inClosedInterval x' y' (a'_full i)) ∧
          (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
            ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
              ghr93_winning_condition (1 + 3 * n + 1)
                (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) ∧
          a'_full ⟨1 + 3 * n, by omega⟩ = d := by
    intro _hx'd _hdy' a_pad ha_pad hc_last
    -- Step 1: Play the multi-round rank r+2 game with rank_embed(a_pad).
    have h_mr1 : ghr93_duplicator_wins M N atomMap (1 + 3 * n + 1) (r + 2)
        (rank_embed (by omega : r ≤ r + 2) x) (rank_embed (by omega : r ≤ r + 2) y)
        (rank_embed (by omega : r ≤ r + 2) x') (rank_embed (by omega : r ≤ r + 2) y') :=
      ghr93_duplicator_wins_round_mono (by omega : 1 + 3 * n + 1 ≤ 4 + 3 * n)
        ((rank_embed_le (by omega : r ≤ r + 2) x y).mpr hxy)
        ((rank_embed_le (by omega : r ≤ r + 2) x' y').mpr hx'y') h_fwd_r1
    -- Embed a_pad to rank r+2
    have ha_pad_r2 : ∀ i, inClosedInterval
        (rank_embed (by omega : r ≤ r + 2) x) (rank_embed (by omega : r ≤ r + 2) y)
        (rank_embed (by omega : r ≤ r + 2) (a_pad i)) :=
      fun i => (rank_embed_inClosedInterval (by omega : r ≤ r + 2) x y (a_pad i)).mpr (ha_pad i)
    obtain ⟨a'_mr, ha'_mr_in, hwin_mr⟩ := h_mr1
      (fun i => rank_embed (by omega : r ≤ r + 2) (a_pad i)) ha_pad_r2
    -- Step 2: The rank r+2 response at position 1+3n agrees with
    -- rank_embed(c_inf) on depth r+2 formulas (from winning condition).
    -- Combined with hform_r2_1, it agrees with rank_embed(d) at depth r+2.
    -- By the SAME K⁻(¬D) argument that proved h_r2_eq, this response
    -- must equal rank_embed(d).
    -- We use rank_down as a theorem to get rank-r bounds + winning condition,
    -- and separately track position 1+3n.
    -- Step 3: Apply rank_down to get rank-r responses with bounds and winning.
    have h_rank_r : ghr93_duplicator_wins M N atomMap (1 + 3 * n + 1) r x y x' y' :=
      ghr93_duplicator_wins_rank_down (by omega : r ≤ r + 2) (by omega : r + 2 ≤ r + 2)
        hxy hx'y' h_mr1
    obtain ⟨a'_rd, ha'_rd, hwin_rd⟩ := h_rank_r a_pad ha_pad
    -- We have a'_rd with bounds and winning at rank r.
    -- We also have a'_mr (rank r+2 response from h_mr1 played with rank_embed(a_pad)).
    -- The rank_down theorem internally projects a'_mr to get a'_rd.
    -- Since rank_down is opaque, we can't access this relationship directly.
    -- Instead, we construct a'_full that agrees with a'_rd at all positions
    -- except potentially 1+3n, where we set it to d.
    -- But we need the winning condition to still hold.
    -- The key: a'_rd(1+3n) and d agree on all rank-r formulas and gap/point,
    -- so the winning condition is preserved under substitution IF the order
    -- type is preserved. This is the GHR93 Claim 1 argument.
    --
    -- Actually, the cleanest approach: just return a'_rd and prove a'_rd(1+3n) = d.
    -- This requires the K⁻(¬D) argument showing the rank r+2 response at
    -- position 1+3n is rank_embed(d), which projects to d.
    -- But rank_down is opaque, so we can't directly access the rank r+2 response.
    --
    -- ALTERNATIVE: Extract formula agreement from hwin_rd at position 1+3n
    -- and use hform_r2_1 to show agreement at depth r+2, then Claim 1.
    -- But hwin_rd gives depth r agreement (not r+2).
    --
    -- CONCLUSION: We must bypass rank_down and directly construct a'_full
    -- by inlining the projection. This is too complex for this session.
    -- Return a'_rd as the response (bounds + winning are satisfied)
    -- and defer the position constraint.
    exact ⟨a'_rd, ha'_rd, hwin_rd, sorry⟩
  -- Step 12: GHR93 Claim 1 interior case (right). Mirror of left.
  have h_interior_right : x' ≠ d → d ≠ y' →
      ∀ (a_pad : Fin (1 + 3 * n + 1) → ExtendedCarrier M atomMap r),
        (∀ i, inClosedInterval x y (a_pad i)) →
        a_pad ⟨0, by omega⟩ = c_inf →
        ∃ (a'_full : Fin (1 + 3 * n + 1) → ExtendedCarrier N atomMap r),
          (∀ i, inClosedInterval x' y' (a'_full i)) ∧
          (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
            ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
              ghr93_winning_condition (1 + 3 * n + 1)
                (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) ∧
          a'_full ⟨0, by omega⟩ = d := by
    intro _hx'd _hdy' a_pad ha_pad hc_first
    -- Mirror of h_interior_left with position 0 instead of 1+3n.
    have h_mr1 : ghr93_duplicator_wins M N atomMap (1 + 3 * n + 1) (r + 2)
        (rank_embed (by omega : r ≤ r + 2) x) (rank_embed (by omega : r ≤ r + 2) y)
        (rank_embed (by omega : r ≤ r + 2) x') (rank_embed (by omega : r ≤ r + 2) y') :=
      ghr93_duplicator_wins_round_mono (by omega : 1 + 3 * n + 1 ≤ 4 + 3 * n)
        ((rank_embed_le (by omega : r ≤ r + 2) x y).mpr hxy)
        ((rank_embed_le (by omega : r ≤ r + 2) x' y').mpr hx'y') h_fwd_r1
    have h_rank_r : ghr93_duplicator_wins M N atomMap (1 + 3 * n + 1) r x y x' y' :=
      ghr93_duplicator_wins_rank_down (by omega : r ≤ r + 2) (by omega : r + 2 ≤ r + 2)
        hxy hx'y' h_mr1
    obtain ⟨a'_rd, ha'_rd, hwin_rd⟩ := h_rank_r a_pad ha_pad
    exact ⟨a'_rd, ha'_rd, hwin_rd, sorry⟩
  -- Step 13: Provide the suffices witness directly from the rank-(r+2) game.
  -- This bypasses t_game entirely — no rank mismatch.
  refine ⟨c_inf, hc_inf_interval, hform_cd, hgp_cd, hbdy_cd, h_interior_left, h_interior_right⟩

/-! ### Case I: The Split Case

When at least one of Spoiler's backward selections a_0,...,a_n lies below
the split point d, Duplicator uses a "split" strategy: she applies the
backward strategy σ (on [x',d]/[x,c]) to selections below d, and the
backward strategy τ (on [d,y']/[c,y]) to selections above d. The responses
are combined into a single (n+1)-element response.

This is the simplest case because it doesn't construct new StaviFormulas.
It reduces to combining two backward strategies, each of which was obtained
from the IH.

Note: In Case I, the "split" means we partition the n+1 selections into
those ≤ d (at most n of them) and those > d (at most n of them). Since
σ and τ each handle n-round backward games, and at most n elements fall
on each side, round monotonicity (Lemma 10) allows the sub-strategies to
handle their portions. -/

set_option maxHeartbeats 800000

/-- **Case I helper**: Given backward strategies σ on [x',d]/[x,c] and
    τ on [d,y']/[c,y], if Spoiler's n+1 selections split across d
    (at least one below d and at least one at or above d), construct
    Duplicator's combined response.

    The key insight is that among n+1 selections, if some are below d
    and some are at or above d, then each side has at most n selections.
    Since σ and τ handle n-round games, round monotonicity applies.

    Sorry'd: The combination of σ and τ responses requires careful index
    manipulation to merge two partial responses into a single (n+1)-element
    response while preserving order type, gap/point agreement, and formula
    agreement. This is the content of Phase 4C.3. -/
private theorem ghr93_case_I {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {n r : Nat}
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r}
    {d : ExtendedCarrier N atomMap r}
    {a_bwd : Fin (n + 1) → ExtendedCarrier N atomMap r}
    (props : SplitPointProps n x y x' y' c d a_bwd)
    (ha_bwd : ∀ i, inClosedInterval x' y' (a_bwd i))
    (h_split : ∃ i : Fin (n + 1), a_bwd i < d) :
    ∃ (a'_resp : Fin (n + 1) → ExtendedCarrier M atomMap r),
      (∀ i, inClosedInterval x y (a'_resp i)) ∧
      ∀ (b_sp : M.carrier),
        inClosedInterval x y (extendPoint b_sp) →
        ∃ (b_resp : N.carrier),
          inClosedInterval x' y' (extendPoint b_resp) ∧
          ghr93_winning_condition (n + 1)
            (game_tuple x' y' a_bwd b_resp)
            (game_tuple x y a'_resp b_sp) := by
  -- ---------------------------------------------------------------
  -- Step 0: Handle n = 0 by contradiction
  -- When n = 0, Fin 1 has one index ⟨0, _⟩. h_split says a_bwd ⟨0,_⟩ < d,
  -- but hd_le_an gives d ≤ a_bwd ⟨0,_⟩. Contradiction.
  -- ---------------------------------------------------------------
  obtain ⟨i_split, hi_split⟩ := h_split
  by_cases hn : n = 0
  · subst hn
    have : i_split = ⟨0, by omega⟩ := by ext; omega
    rw [this] at hi_split
    exact absurd props.hd_le_an (not_le.mpr hi_split)
  -- ---------------------------------------------------------------
  -- Step 1: Partition indices into L (below d) and R (at or above d)
  -- ---------------------------------------------------------------
  have hn_pos : 0 < n := Nat.pos_of_ne_zero hn
  let L := Finset.univ.filter (fun i : Fin (n + 1) => a_bwd i < d)
  let R := Finset.univ.filter (fun i : Fin (n + 1) => ¬ a_bwd i < d)
  have hL_nonempty : L.Nonempty :=
    ⟨i_split, Finset.mem_filter.mpr ⟨Finset.mem_univ _, hi_split⟩⟩
  have hR_nonempty : R.Nonempty := by
    refine ⟨⟨n, by omega⟩, Finset.mem_filter.mpr ⟨Finset.mem_univ _, ?_⟩⟩
    exact not_lt.mpr props.hd_le_an
  have hLR_card : L.card + R.card = n + 1 := by
    have := Finset.card_filter_add_card_filter_not (s := Finset.univ)
      (p := fun i : Fin (n + 1) => a_bwd i < d)
    simp only [Finset.card_univ, Fintype.card_fin] at this
    exact this
  have hL_pos : 0 < L.card := Finset.Nonempty.card_pos hL_nonempty
  have hR_pos : 0 < R.card := Finset.Nonempty.card_pos hR_nonempty
  have hL_le : L.card ≤ n := by omega
  have hR_le : R.card ≤ n := by omega
  -- ---------------------------------------------------------------
  -- Step 2: Enumerate L and R, build sub-selections
  -- ---------------------------------------------------------------
  have hL_card_eq : L.card = L.card := rfl
  have hR_card_eq : R.card = R.card := rfl
  let eL := L.orderEmbOfFin hL_card_eq
  let eR := R.orderEmbOfFin hR_card_eq
  let a_sigma : Fin L.card → ExtendedCarrier N atomMap r :=
    fun k => a_bwd (eL k)
  have ha_sigma : ∀ k, inClosedInterval x' d (a_sigma k) := by
    intro k
    have hk_mem := Finset.orderEmbOfFin_mem L hL_card_eq k
    have hlt := (Finset.mem_filter.mp hk_mem).2
    exact ⟨(ha_bwd _).1, le_of_lt hlt⟩
  let a_tau : Fin R.card → ExtendedCarrier N atomMap r :=
    fun k => a_bwd (eR k)
  have ha_tau : ∀ k, inClosedInterval d y' (a_tau k) := by
    intro k
    have hk_mem := Finset.orderEmbOfFin_mem R hR_card_eq k
    have hge := not_lt.mp (Finset.mem_filter.mp hk_mem).2
    exact ⟨hge, (ha_bwd _).2⟩
  -- ---------------------------------------------------------------
  -- Step 3: Apply round monotonicity and play sub-games
  -- ---------------------------------------------------------------
  have sigma_reduced : ghr93_duplicator_wins N M atomMap L.card r x' d x c :=
    ghr93_duplicator_wins_round_mono hL_le props.hx'd props.hxc props.sigma
  have tau_reduced : ghr93_duplicator_wins N M atomMap R.card r d y' c y :=
    ghr93_duplicator_wins_round_mono hR_le props.hdy' props.hcy props.tau
  obtain ⟨resp_L, hresp_L_in, hwin_L⟩ := sigma_reduced a_sigma ha_sigma
  obtain ⟨resp_R, hresp_R_in, hwin_R⟩ := tau_reduced a_tau ha_tau
  -- ---------------------------------------------------------------
  -- Step 4: Build inverse maps using orderIsoOfFin
  -- ---------------------------------------------------------------
  let isoL := L.orderIsoOfFin hL_card_eq
  let isoR := R.orderIsoOfFin hR_card_eq
  -- ---------------------------------------------------------------
  -- Step 5: Merge responses into a'_resp : Fin (n+1) → M
  -- ---------------------------------------------------------------
  let a'_resp : Fin (n + 1) → ExtendedCarrier M atomMap r := fun i =>
    if h : a_bwd i < d then
      resp_L (isoL.symm ⟨i, Finset.mem_filter.mpr ⟨Finset.mem_univ _, h⟩⟩)
    else
      resp_R (isoR.symm ⟨i, Finset.mem_filter.mpr ⟨Finset.mem_univ _, h⟩⟩)
  have ha'_resp_in : ∀ i, inClosedInterval x y (a'_resp i) := by
    intro i; simp only [a'_resp]
    split
    case isTrue h =>
      have hi_L : i ∈ L := Finset.mem_filter.mpr ⟨Finset.mem_univ _, h⟩
      have := hresp_L_in (isoL.symm ⟨i, hi_L⟩)
      exact ⟨this.1, le_trans this.2 props.hcy⟩
    case isFalse h =>
      have hi_R : i ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, h⟩
      have := hresp_R_in (isoR.symm ⟨i, hi_R⟩)
      exact ⟨le_trans props.hxc this.1, this.2⟩
  -- Key interval facts for cross-partition ordering:
  -- L-responses are in [x, c], R-responses are in [c, y]
  have hresp_L_le_c : ∀ k, resp_L k ≤ c := fun k => (hresp_L_in k).2
  have hc_le_resp_R : ∀ k, c ≤ resp_R k := fun k => (hresp_R_in k).1
  -- ---------------------------------------------------------------
  -- Step 6: Provide a'_resp and handle Round 2
  -- ---------------------------------------------------------------
  -- Key fact: eL (isoL.symm ⟨j, hj⟩) = j (the orderEmb∘iso.symm is identity on values)
  have heL_inv : ∀ (j : Fin (n + 1)) (hj : j ∈ L),
      eL (isoL.symm ⟨j, hj⟩) = j := by
    intro j hj
    have h1 : isoL (isoL.symm ⟨j, hj⟩) = ⟨j, hj⟩ := OrderIso.apply_symm_apply _ _
    exact Fin.ext (by rw [show (eL (isoL.symm ⟨j, hj⟩)).val =
      (isoL (isoL.symm ⟨j, hj⟩)).val from rfl, h1])
  have heR_inv : ∀ (j : Fin (n + 1)) (hj : j ∈ R),
      eR (isoR.symm ⟨j, hj⟩) = j := by
    intro j hj
    have h1 : isoR (isoR.symm ⟨j, hj⟩) = ⟨j, hj⟩ := OrderIso.apply_symm_apply _ _
    exact Fin.ext (by rw [show (eR (isoR.symm ⟨j, hj⟩)).val =
      (isoR (isoR.symm ⟨j, hj⟩)).val from rfl, h1])
  refine ⟨a'_resp, ha'_resp_in, ?_⟩
  intro b_sp hb_sp
  by_cases hbc : extendPoint b_sp ≤ c
  · -- b_sp in [x, c]: delegate to σ's Round 2
    obtain ⟨b_resp_L, hb_resp_L_in, hcond_L⟩ :=
      hwin_L b_sp ⟨hb_sp.1, hbc⟩
    refine ⟨b_resp_L, ⟨hb_resp_L_in.1, le_trans hb_resp_L_in.2 props.hdy'⟩, ?_⟩
    -- ---------------------------------------------------------------
    -- Winning condition transfer (left case)
    -- ---------------------------------------------------------------
    -- Instantiate tau with a point from [c,y] to get R-side data.
    -- In the degenerate case (c = y, d = y', both gaps), derive R-side
    -- data directly from hcd_form/hcd_gp since no carrier point exists in [c,c].
    obtain ⟨hord_L, hgp_L, hform_L⟩ := hcond_L
    -- Obtain R-side gap/point and formula data for selection indices and boundaries.
    -- These are extracted from tau instantiation (non-degenerate) or from hcd_form/hcd_gp
    -- (degenerate: c = y, d = y', both gaps, all R-selections collapse to d/c).
    have hgp_R_sel : ∀ (k : Fin R.card),
        (IsPoint (a_tau k) ↔ IsPoint (resp_R k)) ∧
        (IsGap (a_tau k) ↔ IsGap (resp_R k)) := by
      rcases props.h_pt_cy with ⟨p_cy, hp_cy⟩ | ⟨hcy_eq, hdy'_eq, hgap_c, hgap_d⟩
      · intro k
        obtain ⟨_, _, hcond⟩ := hwin_R p_cy hp_cy
        obtain ⟨_, hgp_aux, _⟩ := hcond
        have := hgp_aux ⟨1 + k.val, by omega⟩
        simp only [game_tuple,
          show (1 + k.val : Nat) ≠ 0 from by omega,
          show ¬((1 + ↑k : Nat) = R.card + 1) from by { have := k.isLt; omega },
          show ¬((1 + ↑k : Nat) = R.card + 2) from by { have := k.isLt; omega },
          dite_false, show 1 + ↑k - 1 = k.val from by omega] at this
        exact this
      · intro k
        -- Degenerate: a_tau k = d (forced by [d,d]), resp_R k = c (forced by [c,c])
        have ha_eq : a_tau k = d := le_antisymm
          (hdy'_eq ▸ (ha_tau k).2) (ha_tau k).1
        have hr_eq : resp_R k = c := le_antisymm
          (hcy_eq ▸ (hresp_R_in k).2) (hresp_R_in k).1
        rw [ha_eq, hr_eq]; exact ⟨props.hcd_gp.1.symm, props.hcd_gp.2.symm⟩
    have hform_R_sel : ∀ (k : Fin R.card) (A : StaviFormula), stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r (a_tau k) A ↔
         stavi_temporal_truth_mu M atomMap r (resp_R k) A) := by
      rcases props.h_pt_cy with ⟨p_cy, hp_cy⟩ | ⟨hcy_eq, hdy'_eq, hgap_c, hgap_d⟩
      · intro k A hA
        obtain ⟨_, _, hcond⟩ := hwin_R p_cy hp_cy
        obtain ⟨_, _, hform_aux⟩ := hcond
        have := hform_aux ⟨1 + k.val, by omega⟩ A hA
        simp only [game_tuple,
          show (1 + k.val : Nat) ≠ 0 from by omega,
          show ¬((1 + ↑k : Nat) = R.card + 1) from by { have := k.isLt; omega },
          show ¬((1 + ↑k : Nat) = R.card + 2) from by { have := k.isLt; omega },
          dite_false, show 1 + ↑k - 1 = k.val from by omega] at this
        exact this
      · intro k A hA
        have ha_eq : a_tau k = d := le_antisymm
          (hdy'_eq ▸ (ha_tau k).2) (ha_tau k).1
        have hr_eq : resp_R k = c := le_antisymm
          (hcy_eq ▸ (hresp_R_in k).2) (hresp_R_in k).1
        rw [ha_eq, hr_eq]; exact (props.hcd_form A hA).symm
    have hgp_y_data : (IsPoint y' ↔ IsPoint y) ∧ (IsGap y' ↔ IsGap y) := by
      rcases props.h_pt_cy with ⟨p_cy, hp_cy⟩ | ⟨hcy_eq, hdy'_eq, hgap_c, hgap_d⟩
      · obtain ⟨_, _, hcond⟩ := hwin_R p_cy hp_cy
        obtain ⟨_, hgp_aux, _⟩ := hcond
        have := hgp_aux ⟨R.card + 2, by omega⟩
        simp only [game_tuple, show (R.card + 2 : Nat) ≠ 0 from by omega,
          show ¬((R.card + 2 : Nat) = R.card + 1) from by omega,
          show (R.card + 2 : Nat) = R.card + 2 from rfl, dite_true, dite_false] at this
        exact this
      · rw [← hdy'_eq, ← hcy_eq]; exact ⟨props.hcd_gp.1.symm, props.hcd_gp.2.symm⟩
    have hform_y_data : ∀ A, stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r y' A ↔ stavi_temporal_truth_mu M atomMap r y A) := by
      rcases props.h_pt_cy with ⟨p_cy, hp_cy⟩ | ⟨hcy_eq, hdy'_eq, hgap_c, hgap_d⟩
      · intro A hA
        obtain ⟨_, _, hcond⟩ := hwin_R p_cy hp_cy
        obtain ⟨_, _, hform_aux⟩ := hcond
        have := hform_aux ⟨R.card + 2, by omega⟩ A hA
        simp only [game_tuple, show (R.card + 2 : Nat) ≠ 0 from by omega,
          show ¬((R.card + 2 : Nat) = R.card + 1) from by omega,
          show (R.card + 2 : Nat) = R.card + 2 from rfl, dite_true, dite_false] at this
        exact this
      · intro A hA; rw [← hdy'_eq, ← hcy_eq]; exact (props.hcd_form A hA).symm
    -- Tau ordering data for R-selections (for same_order_type)
    have tau_d_y_data : (d < y' ↔ c < y) ∧ (d = y' ↔ c = y) := by
      rcases props.h_pt_cy with ⟨p_cy, hp_cy⟩ | ⟨hcy_eq, hdy'_eq, _, _⟩
      · obtain ⟨_, _, hcond⟩ := hwin_R p_cy hp_cy
        obtain ⟨hord_aux, _, _⟩ := hcond
        have h := hord_aux ⟨0, by omega⟩ ⟨R.card + 2, by omega⟩
        simp_game_tuple at h; exact h
      · exact ⟨⟨fun h => absurd hdy'_eq (ne_of_lt h), fun h => absurd hcy_eq (ne_of_lt h)⟩,
               ⟨fun _ => hcy_eq, fun _ => hdy'_eq⟩⟩
    have tau_d_sel_data : ∀ (k : Fin R.card),
        (d < a_tau k ↔ c < resp_R k) ∧ (d = a_tau k ↔ c = resp_R k) := by
      rcases props.h_pt_cy with ⟨p_cy, hp_cy⟩ | ⟨hcy_eq, hdy'_eq, _, _⟩
      · intro k
        obtain ⟨_, _, hcond⟩ := hwin_R p_cy hp_cy
        obtain ⟨hord_aux, _, _⟩ := hcond
        have h := hord_aux ⟨0, by omega⟩ ⟨1 + k.val, by omega⟩
        simp_game_tuple at h; exact h
      · intro k
        have ha_eq : a_tau k = d := le_antisymm (hdy'_eq ▸ (ha_tau k).2) (ha_tau k).1
        have hr_eq : resp_R k = c := le_antisymm (hcy_eq ▸ (hresp_R_in k).2) (hresp_R_in k).1
        exact ⟨⟨fun h => absurd ha_eq (ne_of_lt h).symm, fun h => absurd hr_eq (ne_of_lt h).symm⟩,
               ⟨fun _ => hr_eq.symm, fun _ => ha_eq.symm⟩⟩
    have tau_sel_y_data : ∀ (k : Fin R.card),
        (a_tau k < y' ↔ resp_R k < y) ∧ (a_tau k = y' ↔ resp_R k = y) := by
      rcases props.h_pt_cy with ⟨p_cy, hp_cy⟩ | ⟨hcy_eq, hdy'_eq, _, _⟩
      · intro k
        obtain ⟨_, _, hcond⟩ := hwin_R p_cy hp_cy
        obtain ⟨hord_aux, _, _⟩ := hcond
        have h := hord_aux ⟨1 + k.val, by omega⟩ ⟨R.card + 2, by omega⟩
        simp_game_tuple at h; exact h
      · intro k
        have ha_eq : a_tau k = d := le_antisymm (hdy'_eq ▸ (ha_tau k).2) (ha_tau k).1
        have hr_eq : resp_R k = c := le_antisymm (hcy_eq ▸ (hresp_R_in k).2) (hresp_R_in k).1
        rw [ha_eq, hdy'_eq, hr_eq, hcy_eq]
        exact ⟨⟨fun h => absurd rfl (ne_of_lt h), fun h => absurd rfl (ne_of_lt h)⟩,
               ⟨fun _ => rfl, fun _ => rfl⟩⟩
    have tau_sel_sel_data : ∀ (k k' : Fin R.card),
        (a_tau k < a_tau k' ↔ resp_R k < resp_R k') ∧
        (a_tau k = a_tau k' ↔ resp_R k = resp_R k') := by
      rcases props.h_pt_cy with ⟨p_cy, hp_cy⟩ | ⟨hcy_eq, hdy'_eq, _, _⟩
      · intro k k'
        obtain ⟨_, _, hcond⟩ := hwin_R p_cy hp_cy
        obtain ⟨hord_aux, _, _⟩ := hcond
        have h := hord_aux ⟨1 + k.val, by omega⟩ ⟨1 + k'.val, by omega⟩
        simp_game_tuple at h; exact h
      · intro k k'
        have ha_eq : a_tau k = d := le_antisymm (hdy'_eq ▸ (ha_tau k).2) (ha_tau k).1
        have ha_eq' : a_tau k' = d := le_antisymm (hdy'_eq ▸ (ha_tau k').2) (ha_tau k').1
        have hr_eq : resp_R k = c := le_antisymm (hcy_eq ▸ (hresp_R_in k).2) (hresp_R_in k).1
        have hr_eq' : resp_R k' = c := le_antisymm (hcy_eq ▸ (hresp_R_in k').2) (hresp_R_in k').1
        rw [ha_eq, ha_eq', hr_eq, hr_eq']
        exact ⟨⟨fun h => absurd rfl (ne_of_lt h), fun h => absurd rfl (ne_of_lt h)⟩,
               ⟨fun _ => rfl, fun _ => rfl⟩⟩
    -- Interval facts for N-side values
    have hN_L_le_d : ∀ (j : Fin (n + 1)), a_bwd j < d → a_bwd j ≤ d :=
      fun j h => le_of_lt h
    have hN_R_ge_d : ∀ (j : Fin (n + 1)), ¬ a_bwd j < d → d ≤ a_bwd j :=
      fun j h => not_lt.mp h
    -- Interval facts for M-side values
    -- All full-game M-values fall into [x,c] or [c,y]
    -- L-responses ≤ c, R-responses ≥ c (already have hresp_L_le_c, hc_le_resp_R)
    -- b_sp ≤ c (from hbc), b_resp_L ≤ d (from hb_resp_L_in)
    -- ----- Per-index: gap_point and formula -----
    -- For each full-game index i, we classify it and transfer from the sub-game.
    -- Helper: for selection index j, the sub-game's gap/point data at j
    have hgp_sel : ∀ (j : Fin (n + 1)),
        (IsPoint (a_bwd j) ↔ IsPoint (a'_resp j)) ∧
        (IsGap (a_bwd j) ↔ IsGap (a'_resp j)) := by
      intro j
      by_cases hjd : a_bwd j < d
      · -- j ∈ L
        have hj_mem : j ∈ L := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd⟩
        simp only [a'_resp, hjd, dite_true]
        set k := isoL.symm ⟨j, hj_mem⟩ with hk_def
        -- From sigma's gap_point at selection index 1 + k.val
        have hsig_gp := hgp_L ⟨1 + k.val, by omega⟩
        -- Simplify sigma's game_tuple at index 1 + k.val
        simp only [game_tuple,
          show (1 + k.val : Nat) ≠ 0 from by omega,
          show ¬((1 + ↑k : Nat) = L.card + 1) from by { have := k.isLt; omega },
          show ¬((1 + ↑k : Nat) = L.card + 2) from by { have := k.isLt; omega },
          dite_false, show 1 + ↑k - 1 = k.val from by omega] at hsig_gp
        -- N-side: a_sigma k = a_bwd (eL k) = a_bwd j
        have hN_eq : a_sigma k = a_bwd j := by
          simp only [a_sigma]
          congr 1; exact heL_inv j hj_mem
        -- M-side: resp_L k
        rw [hN_eq] at hsig_gp
        exact hsig_gp
      · -- j ∈ R
        have hj_mem : j ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd⟩
        simp only [a'_resp, hjd, dite_false]
        set k := isoR.symm ⟨j, hj_mem⟩ with hk_def
        have htau_gp := hgp_R_sel k
        have hN_eq : a_tau k = a_bwd j := by
          simp only [a_tau]
          congr 1; exact heR_inv j hj_mem
        rw [hN_eq] at htau_gp
        exact htau_gp
    -- Helper: for selection index j, formula agreement
    have hform_sel : ∀ (j : Fin (n + 1)) (A : StaviFormula), stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r (a_bwd j) A ↔
         stavi_temporal_truth_mu M atomMap r (a'_resp j) A) := by
      intro j A hA
      by_cases hjd : a_bwd j < d
      · have hj_mem : j ∈ L := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd⟩
        simp only [a'_resp, hjd, dite_true]
        set k := isoL.symm ⟨j, hj_mem⟩ with hk_def
        have hsig_form := hform_L ⟨1 + k.val, by omega⟩ A hA
        simp only [game_tuple,
          show (1 + k.val : Nat) ≠ 0 from by omega,
          show ¬((1 + ↑k : Nat) = L.card + 1) from by { have := k.isLt; omega },
          show ¬((1 + ↑k : Nat) = L.card + 2) from by { have := k.isLt; omega },
          dite_false, show 1 + ↑k - 1 = k.val from by omega] at hsig_form
        have hN_eq : a_sigma k = a_bwd j := by
          simp only [a_sigma]; congr 1; exact heL_inv j hj_mem
        rw [hN_eq] at hsig_form; exact hsig_form
      · have hj_mem : j ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd⟩
        simp only [a'_resp, hjd, dite_false]
        set k := isoR.symm ⟨j, hj_mem⟩ with hk_def
        have htau_form := hform_R_sel k A hA
        have hN_eq : a_tau k = a_bwd j := by
          simp only [a_tau]; congr 1; exact heR_inv j hj_mem
        rw [hN_eq] at htau_form; exact htau_form
    -- Boundary gap/point data
    have hgp_x : (IsPoint x' ↔ IsPoint x) ∧ (IsGap x' ↔ IsGap x) := by
      have := hgp_L ⟨0, by omega⟩
      simp only [game_tuple, show (0 : Nat) ≠ L.card + 1 from by omega,
        show (0 : Nat) ≠ L.card + 2 from by omega, dite_true] at this
      exact this
    have hgp_y : (IsPoint y' ↔ IsPoint y) ∧ (IsGap y' ↔ IsGap y) := hgp_y_data
    -- Boundary formula data
    have hform_x : ∀ A, stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r x' A ↔ stavi_temporal_truth_mu M atomMap r x A) := by
      intro A hA
      have := hform_L ⟨0, by omega⟩ A hA
      simp only [game_tuple, show (0 : Nat) ≠ L.card + 1 from by omega,
        show (0 : Nat) ≠ L.card + 2 from by omega, dite_true] at this
      exact this
    have hform_y : ∀ A, stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r y' A ↔ stavi_temporal_truth_mu M atomMap r y A) :=
      hform_y_data
    -- b-index gap/point: both are extendPoint, so both are points
    have hgp_b : (@IsPoint sig N atomMap r (extendPoint b_resp_L) ↔
                  @IsPoint sig M atomMap r (extendPoint b_sp)) ∧
                 (@IsGap sig N atomMap r (extendPoint b_resp_L) ↔
                  @IsGap sig M atomMap r (extendPoint b_sp)) := by
      constructor
      · exact ⟨fun _ => ⟨b_sp, rfl⟩, fun _ => ⟨b_resp_L, rfl⟩⟩
      · exact ⟨fun ⟨g, hg⟩ => absurd hg.symm Sum.inr_ne_inl,
               fun ⟨g, hg⟩ => absurd hg.symm Sum.inr_ne_inl⟩
    -- b-index formula: from sigma at the b-index
    have hform_b : ∀ A, stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r (extendPoint b_resp_L) A ↔
         stavi_temporal_truth_mu M atomMap r (extendPoint b_sp) A) := by
      intro A hA
      have := hform_L ⟨L.card + 1, by omega⟩ A hA
      simp only [game_tuple, show (L.card + 1 : Nat) ≠ 0 from by omega,
        show (L.card + 1 : Nat) = L.card + 1 from rfl, dite_true] at this
      exact this
    -- ----- same_order_type: ordering of selections via sub-game -----
    -- Helper: ordering of two selections in the full game
    -- Deferred to a separate sorry — the proof requires complex index mapping
    -- between full-game and sub-game game_tuples via boundary-pivot argument.
    -- ----- Assemble the winning condition -----
    refine ⟨?_, ?_, ?_⟩
    · -- same_order_type (n+1): ordering via pivot chain through d/c
      -- Extract value-level ordering from sigma's same_order_type
      -- sigma maps: 0→x'/x, 1+k→a_sigma(k)/resp_L(k), L.card+1→b_resp_L/b_sp, L.card+2→d/c
      have sig_ord := fun a₁ a₂ : Fin (L.card + 3) => hord_L a₁ a₂
      -- Pre-extract sigma boundary orderings (as value-level facts)
      have sig_x_d : (x' < d ↔ x < c) ∧ (x' = d ↔ x = c) := by
        have h := sig_ord ⟨0, by omega⟩ ⟨L.card + 2, by omega⟩
        simp_game_tuple at h; exact h
      have sig_b_d : (extendPoint b_resp_L < d ↔ extendPoint b_sp < c) ∧
                     (extendPoint b_resp_L = d ↔ extendPoint b_sp = c) := by
        have h := sig_ord ⟨L.card + 1, by omega⟩ ⟨L.card + 2, by omega⟩
        simp_game_tuple at h; exact h
      have tau_d_y : (d < y' ↔ c < y) ∧ (d = y' ↔ c = y) := tau_d_y_data
      -- Extract sigma ordering for L-selection k vs other sigma values
      have sig_x_sel : ∀ (k : Fin L.card),
          (x' < a_sigma k ↔ x < resp_L k) ∧ (x' = a_sigma k ↔ x = resp_L k) := by
        intro k; have h := sig_ord ⟨0, by omega⟩ ⟨1 + k.val, by omega⟩
        simp_game_tuple at h; exact h
      have sig_sel_d : ∀ (k : Fin L.card),
          (a_sigma k < d ↔ resp_L k < c) ∧ (a_sigma k = d ↔ resp_L k = c) := by
        intro k; have h := sig_ord ⟨1 + k.val, by omega⟩ ⟨L.card + 2, by omega⟩
        simp_game_tuple at h; exact h
      have sig_b_sel : ∀ (k : Fin L.card),
          (extendPoint b_resp_L < a_sigma k ↔ extendPoint b_sp < resp_L k) ∧
          (extendPoint b_resp_L = a_sigma k ↔ extendPoint b_sp = resp_L k) := by
        intro k; have h := sig_ord ⟨L.card + 1, by omega⟩ ⟨1 + k.val, by omega⟩
        simp_game_tuple at h; exact h
      have sig_sel_b : ∀ (k : Fin L.card),
          (a_sigma k < extendPoint b_resp_L ↔ resp_L k < extendPoint b_sp) ∧
          (a_sigma k = extendPoint b_resp_L ↔ resp_L k = extendPoint b_sp) := by
        intro k; have h := sig_ord ⟨1 + k.val, by omega⟩ ⟨L.card + 1, by omega⟩
        simp_game_tuple at h; exact h
      have sig_sel_sel : ∀ (k k' : Fin L.card),
          (a_sigma k < a_sigma k' ↔ resp_L k < resp_L k') ∧
          (a_sigma k = a_sigma k' ↔ resp_L k = resp_L k') := by
        intro k k'; have h := sig_ord ⟨1 + k.val, by omega⟩ ⟨1 + k'.val, by omega⟩
        simp_game_tuple at h; exact h
      have sig_x_b : (x' < extendPoint b_resp_L ↔ x < extendPoint b_sp) ∧
                     (x' = extendPoint b_resp_L ↔ x = extendPoint b_sp) := by
        have h := sig_ord ⟨0, by omega⟩ ⟨L.card + 1, by omega⟩
        simp_game_tuple at h; exact h
      -- Extract tau ordering for R-selection k vs other tau values
      have tau_d_sel : ∀ (k : Fin R.card),
          (d < a_tau k ↔ c < resp_R k) ∧ (d = a_tau k ↔ c = resp_R k) :=
        tau_d_sel_data
      have tau_sel_y : ∀ (k : Fin R.card),
          (a_tau k < y' ↔ resp_R k < y) ∧ (a_tau k = y' ↔ resp_R k = y) :=
        tau_sel_y_data
      have tau_sel_sel : ∀ (k k' : Fin R.card),
          (a_tau k < a_tau k' ↔ resp_R k < resp_R k') ∧
          (a_tau k = a_tau k' ↔ resp_R k = resp_R k') :=
        tau_sel_sel_data
      -- Interval bounds needed for pivot_chain_order
      -- a_sigma(k) ≤ d (since a_sigma(k) = a_bwd(eL(k)) and eL(k) ∈ L means a_bwd < d)
      have ha_sig_le_d : ∀ (k : Fin L.card), a_sigma k ≤ d :=
        fun k => le_of_lt ((Finset.mem_filter.mp (Finset.orderEmbOfFin_mem L hL_card_eq k)).2)
      have hresp_L_le_c : ∀ (k : Fin L.card), resp_L k ≤ c := fun k => (hresp_L_in k).2
      have hd_le_a_tau : ∀ (k : Fin R.card), d ≤ a_tau k :=
        fun k => not_lt.mp ((Finset.mem_filter.mp (Finset.orderEmbOfFin_mem R hR_card_eq k)).2)
      have hc_le_rR : ∀ (k : Fin R.card), c ≤ resp_R k := fun k => (hresp_R_in k).1
      -- Now prove same_order_type by intro + split_ifs on game_tuple
      intro i j; simp only [game_tuple]; split_ifs with
        hi0 hj0 _ _ _ hjb _ hjy _ hjd _ _ hib hj0 _ _ _ hjb _ hjy _ hjd _ _
        hiy hj0 _ _ _ hjb _ hjy _ hjd _ _ _ hid hj0 _ _ _ hjb _ hjy _ hjd _ _
      -- After split_ifs, we have 16 goals corresponding to the 4×4 grid of
      -- index categories: {x=0, b=n+2, y=n+3, sel} × {x=0, b=n+2, y=n+3, sel}
      -- Goal 1: x vs x
      · order_refl
      -- Goal 2: x vs b
      · exact sig_x_b
      -- Goal 3: x vs y
      · exact pivot_chain_order' props.hx'd props.hdy' props.hxc props.hcy
          sig_x_d tau_d_y
      -- Goal 4: x vs sel(j)
      · set j' : Fin (n + 1) := ⟨j.val - 1, by omega⟩
        by_cases hjd' : a_bwd j' < d
        · have hj_mem : j' ∈ L := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd'⟩
          simp only [a'_resp, hjd', dite_true]
          set k := isoL.symm ⟨j', hj_mem⟩
          have : a_bwd j' = a_sigma k := by
            simp only [a_sigma]; congr 1; exact (heL_inv j' hj_mem).symm
          rw [this]; exact sig_x_sel k
        · have hj_mem : j' ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd'⟩
          simp only [a'_resp, hjd', dite_false]
          set k := isoR.symm ⟨j', hj_mem⟩
          have : a_bwd j' = a_tau k := by
            simp only [a_tau]; congr 1; exact (heR_inv j' hj_mem).symm
          rw [this]
          exact pivot_chain_order' props.hx'd (hd_le_a_tau k)
            props.hxc (hc_le_rR k) sig_x_d (tau_d_sel k)
      -- Goal 5: b vs x
      · have h := sig_ord ⟨L.card + 1, by omega⟩ ⟨0, by omega⟩
        simp_game_tuple at h; exact h
      -- Goal 6: b vs b
      · order_refl
      -- Goal 7: b vs y
      · exact pivot_chain_order' hb_resp_L_in.2 props.hdy' hbc props.hcy
          sig_b_d tau_d_y
      -- Goal 8: b vs sel(j)
      · set j' : Fin (n + 1) := ⟨j.val - 1, by omega⟩
        by_cases hjd' : a_bwd j' < d
        · have hj_mem : j' ∈ L := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd'⟩
          simp only [a'_resp, hjd', dite_true]
          set k := isoL.symm ⟨j', hj_mem⟩
          have : a_bwd j' = a_sigma k := by
            simp only [a_sigma]; congr 1; exact (heL_inv j' hj_mem).symm
          rw [this]; exact sig_b_sel k
        · have hj_mem : j' ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd'⟩
          simp only [a'_resp, hjd', dite_false]
          set k := isoR.symm ⟨j', hj_mem⟩
          have : a_bwd j' = a_tau k := by
            simp only [a_tau]; congr 1; exact (heR_inv j' hj_mem).symm
          rw [this]
          exact pivot_chain_order' hb_resp_L_in.2 (hd_le_a_tau k)
            hbc (hc_le_rR k) sig_b_d (tau_d_sel k)
      -- Goal 9: y vs x
      · exact pivot_chain_order_rev' props.hdy' props.hx'd props.hcy props.hxc
          tau_d_y sig_x_d
      -- Goal 10: y vs b
      · exact pivot_chain_order_rev' props.hdy' hb_resp_L_in.2 props.hcy hbc
          tau_d_y sig_b_d
      -- Goal 11: y vs y
      · order_refl
      -- Goal 12: y vs sel(j)
      · set j' : Fin (n + 1) := ⟨j.val - 1, by omega⟩
        by_cases hjd' : a_bwd j' < d
        · have hj_mem : j' ∈ L := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd'⟩
          simp only [a'_resp, hjd', dite_true]
          set k := isoL.symm ⟨j', hj_mem⟩
          have : a_bwd j' = a_sigma k := by
            simp only [a_sigma]; congr 1; exact (heL_inv j' hj_mem).symm
          rw [this]
          exact pivot_chain_order_rev' props.hdy' (ha_sig_le_d k)
            props.hcy (hresp_L_le_c k) tau_d_y (sig_sel_d k)
        · have hj_mem : j' ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd'⟩
          simp only [a'_resp, hjd', dite_false]
          set k := isoR.symm ⟨j', hj_mem⟩
          have : a_bwd j' = a_tau k := by
            simp only [a_tau]; congr 1; exact (heR_inv j' hj_mem).symm
          rw [this]
          have htsy := tau_sel_y k
          exact ⟨⟨fun h => absurd h (not_lt.mpr (ha_tau k).2),
                  fun h => absurd h (not_lt.mpr (hresp_R_in k).2)⟩,
                 ⟨fun h => (htsy.2.mp h.symm).symm,
                  fun h => (htsy.2.mpr h.symm).symm⟩⟩
      -- Goal 13: sel(i) vs x
      · set i' : Fin (n + 1) := ⟨i.val - 1, by omega⟩
        by_cases hid' : a_bwd i' < d
        · have hi_mem : i' ∈ L := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hid'⟩
          simp only [a'_resp, hid', dite_true]
          set k := isoL.symm ⟨i', hi_mem⟩
          have : a_bwd i' = a_sigma k := by
            simp only [a_sigma]; congr 1; exact (heL_inv i' hi_mem).symm
          rw [this]
          have h := sig_ord ⟨1 + k.val, by omega⟩ ⟨0, by omega⟩
          simp_game_tuple at h; exact h
        · have hi_mem : i' ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hid'⟩
          simp only [a'_resp, hid', dite_false]
          set k := isoR.symm ⟨i', hi_mem⟩
          have : a_bwd i' = a_tau k := by
            simp only [a_tau]; congr 1; exact (heR_inv i' hi_mem).symm
          rw [this]
          exact pivot_chain_order_rev' (hd_le_a_tau k) props.hx'd
            (hc_le_rR k) props.hxc (tau_d_sel k) sig_x_d
      -- Goal 14: sel(i) vs b
      · set i' : Fin (n + 1) := ⟨i.val - 1, by omega⟩
        by_cases hid' : a_bwd i' < d
        · have hi_mem : i' ∈ L := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hid'⟩
          simp only [a'_resp, hid', dite_true]
          set k := isoL.symm ⟨i', hi_mem⟩
          have : a_bwd i' = a_sigma k := by
            simp only [a_sigma]; congr 1; exact (heL_inv i' hi_mem).symm
          rw [this]; exact sig_sel_b k
        · have hi_mem : i' ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hid'⟩
          simp only [a'_resp, hid', dite_false]
          set k := isoR.symm ⟨i', hi_mem⟩
          have : a_bwd i' = a_tau k := by
            simp only [a_tau]; congr 1; exact (heR_inv i' hi_mem).symm
          rw [this]
          exact pivot_chain_order_rev' (hd_le_a_tau k) hb_resp_L_in.2
            (hc_le_rR k) hbc (tau_d_sel k) sig_b_d
      -- Goal 15: sel(i) vs y
      · set i' : Fin (n + 1) := ⟨i.val - 1, by omega⟩
        by_cases hid' : a_bwd i' < d
        · have hi_mem : i' ∈ L := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hid'⟩
          simp only [a'_resp, hid', dite_true]
          set k := isoL.symm ⟨i', hi_mem⟩
          have : a_bwd i' = a_sigma k := by
            simp only [a_sigma]; congr 1; exact (heL_inv i' hi_mem).symm
          rw [this]
          exact pivot_chain_order' (ha_sig_le_d k) props.hdy'
            (hresp_L_le_c k) props.hcy (sig_sel_d k) tau_d_y
        · have hi_mem : i' ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hid'⟩
          simp only [a'_resp, hid', dite_false]
          set k := isoR.symm ⟨i', hi_mem⟩
          have : a_bwd i' = a_tau k := by
            simp only [a_tau]; congr 1; exact (heR_inv i' hi_mem).symm
          rw [this]; exact tau_sel_y k
      -- Goal 16: sel(i) vs sel(j)
      · set i' : Fin (n + 1) := ⟨i.val - 1, by omega⟩
        set j' : Fin (n + 1) := ⟨j.val - 1, by omega⟩
        by_cases hid' : a_bwd i' < d
        · have hi_mem : i' ∈ L := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hid'⟩
          simp only [a'_resp, hid', dite_true]
          set ki := isoL.symm ⟨i', hi_mem⟩
          have hi_eq : a_bwd i' = a_sigma ki := by
            simp only [a_sigma]; congr 1; exact (heL_inv i' hi_mem).symm
          rw [hi_eq]
          by_cases hjd' : a_bwd j' < d
          · have hj_mem : j' ∈ L := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd'⟩
            simp only [a'_resp, hjd', dite_true]
            set kj := isoL.symm ⟨j', hj_mem⟩
            have hj_eq : a_bwd j' = a_sigma kj := by
              simp only [a_sigma]; congr 1; exact (heL_inv j' hj_mem).symm
            rw [hj_eq]; exact sig_sel_sel ki kj
          · have hj_mem : j' ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd'⟩
            simp only [a'_resp, hjd', dite_false]
            set kj := isoR.symm ⟨j', hj_mem⟩
            have hj_eq : a_bwd j' = a_tau kj := by
              simp only [a_tau]; congr 1; exact (heR_inv j' hj_mem).symm
            rw [hj_eq]
            exact pivot_chain_order' (ha_sig_le_d ki) (hd_le_a_tau kj)
              (hresp_L_le_c ki) (hc_le_rR kj) (sig_sel_d ki) (tau_d_sel kj)
        · have hi_mem : i' ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hid'⟩
          simp only [a'_resp, hid', dite_false]
          set ki := isoR.symm ⟨i', hi_mem⟩
          have hi_eq : a_bwd i' = a_tau ki := by
            simp only [a_tau]; congr 1; exact (heR_inv i' hi_mem).symm
          rw [hi_eq]
          by_cases hjd' : a_bwd j' < d
          · have hj_mem : j' ∈ L := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd'⟩
            simp only [a'_resp, hjd', dite_true]
            set kj := isoL.symm ⟨j', hj_mem⟩
            have hj_eq : a_bwd j' = a_sigma kj := by
              simp only [a_sigma]; congr 1; exact (heL_inv j' hj_mem).symm
            rw [hj_eq]
            exact pivot_chain_order_rev' (hd_le_a_tau ki) (ha_sig_le_d kj)
              (hc_le_rR ki) (hresp_L_le_c kj) (tau_d_sel ki) (sig_sel_d kj)
          · have hj_mem : j' ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd'⟩
            simp only [a'_resp, hjd', dite_false]
            set kj := isoR.symm ⟨j', hj_mem⟩
            have hj_eq : a_bwd j' = a_tau kj := by
              simp only [a_tau]; congr 1; exact (heR_inv j' hj_mem).symm
            rw [hj_eq]; exact tau_sel_sel ki kj
    · -- gap_point_agreement (n+1)
      exact gap_point_agreement_of_cases hgp_x hgp_b hgp_y hgp_sel
    · -- formula_agreement (n+1)
      exact formula_agreement_of_cases hform_x hform_b hform_y hform_sel
  · -- b_sp in (c, y]: delegate to τ's Round 2
    push_neg at hbc
    obtain ⟨b_resp_R, hb_resp_R_in, hcond_R⟩ :=
      hwin_R b_sp ⟨le_of_lt hbc, hb_sp.2⟩
    refine ⟨b_resp_R, ⟨le_trans props.hx'd hb_resp_R_in.1, hb_resp_R_in.2⟩, ?_⟩
    -- ---------------------------------------------------------------
    -- Winning condition transfer (right case): symmetric to left case.
    -- ---------------------------------------------------------------
    -- Instantiate sigma with a point from [x,c] for L-side data.
    -- In the degenerate case (x = c, x' = d, both gaps), derive L-side
    -- data directly from hcd_form/hcd_gp.
    obtain ⟨hord_R, hgp_R, hform_R⟩ := hcond_R
    -- L-side gap/point and formula data for selection indices and boundaries
    have hgp_L_sel_R : ∀ (k : Fin L.card),
        (IsPoint (a_sigma k) ↔ IsPoint (resp_L k)) ∧
        (IsGap (a_sigma k) ↔ IsGap (resp_L k)) := by
      rcases props.h_pt_xc with ⟨p_xc, hp_xc⟩ | ⟨hxc_eq, hx'd_eq, hgap_c, hgap_d⟩
      · intro k
        obtain ⟨_, _, hcond⟩ := hwin_L p_xc hp_xc
        obtain ⟨_, hgp_aux, _⟩ := hcond
        have := hgp_aux ⟨1 + k.val, by omega⟩
        simp only [game_tuple,
          show (1 + k.val : Nat) ≠ 0 from by omega,
          show ¬((1 + ↑k : Nat) = L.card + 1) from by { have := k.isLt; omega },
          show ¬((1 + ↑k : Nat) = L.card + 2) from by { have := k.isLt; omega },
          dite_false, show 1 + ↑k - 1 = k.val from by omega] at this
        exact this
      · intro k
        have ha_eq : a_sigma k = d := le_antisymm
          (ha_sigma k).2 (hx'd_eq ▸ (ha_sigma k).1)
        have hr_eq : resp_L k = c := le_antisymm
          (hresp_L_in k).2 (hxc_eq ▸ (hresp_L_in k).1)
        rw [ha_eq, hr_eq]; exact ⟨props.hcd_gp.1.symm, props.hcd_gp.2.symm⟩
    have hform_L_sel_R : ∀ (k : Fin L.card) (A : StaviFormula), stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r (a_sigma k) A ↔
         stavi_temporal_truth_mu M atomMap r (resp_L k) A) := by
      rcases props.h_pt_xc with ⟨p_xc, hp_xc⟩ | ⟨hxc_eq, hx'd_eq, hgap_c, hgap_d⟩
      · intro k A hA
        obtain ⟨_, _, hcond⟩ := hwin_L p_xc hp_xc
        obtain ⟨_, _, hform_aux⟩ := hcond
        have := hform_aux ⟨1 + k.val, by omega⟩ A hA
        simp only [game_tuple,
          show (1 + k.val : Nat) ≠ 0 from by omega,
          show ¬((1 + ↑k : Nat) = L.card + 1) from by { have := k.isLt; omega },
          show ¬((1 + ↑k : Nat) = L.card + 2) from by { have := k.isLt; omega },
          dite_false, show 1 + ↑k - 1 = k.val from by omega] at this
        exact this
      · intro k A hA
        have ha_eq : a_sigma k = d := le_antisymm
          (ha_sigma k).2 (hx'd_eq ▸ (ha_sigma k).1)
        have hr_eq : resp_L k = c := le_antisymm
          (hresp_L_in k).2 (hxc_eq ▸ (hresp_L_in k).1)
        rw [ha_eq, hr_eq]; exact (props.hcd_form A hA).symm
    have hgp_x_data_R : (IsPoint x' ↔ IsPoint x) ∧ (IsGap x' ↔ IsGap x) := by
      rcases props.h_pt_xc with ⟨p_xc, hp_xc⟩ | ⟨hxc_eq, hx'd_eq, hgap_c, hgap_d⟩
      · obtain ⟨_, _, hcond⟩ := hwin_L p_xc hp_xc
        obtain ⟨_, hgp_aux, _⟩ := hcond
        have := hgp_aux ⟨0, by omega⟩
        simp only [game_tuple, show (0 : Nat) ≠ L.card + 1 from by omega,
          show (0 : Nat) ≠ L.card + 2 from by omega, dite_true] at this
        exact this
      · rw [hx'd_eq, hxc_eq]; exact ⟨props.hcd_gp.1.symm, props.hcd_gp.2.symm⟩
    have hform_x_data_R : ∀ A, stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r x' A ↔ stavi_temporal_truth_mu M atomMap r x A) := by
      rcases props.h_pt_xc with ⟨p_xc, hp_xc⟩ | ⟨hxc_eq, hx'd_eq, hgap_c, hgap_d⟩
      · intro A hA
        obtain ⟨_, _, hcond⟩ := hwin_L p_xc hp_xc
        obtain ⟨_, _, hform_aux⟩ := hcond
        have := hform_aux ⟨0, by omega⟩ A hA
        simp only [game_tuple, show (0 : Nat) ≠ L.card + 1 from by omega,
          show (0 : Nat) ≠ L.card + 2 from by omega, dite_true] at this
        exact this
      · intro A hA; rw [hx'd_eq, hxc_eq]; exact (props.hcd_form A hA).symm
    -- Sigma ordering data for L-selections
    have sig_x_d_data_R : (x' < d ↔ x < c) ∧ (x' = d ↔ x = c) := by
      rcases props.h_pt_xc with ⟨p_xc, hp_xc⟩ | ⟨hxc_eq, hx'd_eq, _, _⟩
      · obtain ⟨_, _, hcond⟩ := hwin_L p_xc hp_xc
        obtain ⟨hord_aux, _, _⟩ := hcond
        have h := hord_aux ⟨0, by omega⟩ ⟨L.card + 2, by omega⟩
        simp only [game_tuple_zero_eq, game_tuple_y_eq] at h; exact h
      · exact ⟨⟨fun h => absurd hx'd_eq (ne_of_lt h), fun h => absurd hxc_eq (ne_of_lt h)⟩,
               ⟨fun _ => hxc_eq, fun _ => hx'd_eq⟩⟩
    have sig_sel_d_data_R : ∀ (k : Fin L.card),
        (a_sigma k < d ↔ resp_L k < c) ∧ (a_sigma k = d ↔ resp_L k = c) := by
      rcases props.h_pt_xc with ⟨p_xc, hp_xc⟩ | ⟨hxc_eq, hx'd_eq, _, _⟩
      · intro k
        obtain ⟨_, _, hcond⟩ := hwin_L p_xc hp_xc
        obtain ⟨hord_aux, _, _⟩ := hcond
        have h := hord_aux ⟨1 + k.val, by omega⟩ ⟨L.card + 2, by omega⟩
        simp only [game_tuple_sel_eq, game_tuple_y_eq] at h; exact h
      · intro k
        have ha_eq : a_sigma k = d := le_antisymm (ha_sigma k).2 (hx'd_eq ▸ (ha_sigma k).1)
        have hr_eq : resp_L k = c := le_antisymm (hresp_L_in k).2 (hxc_eq ▸ (hresp_L_in k).1)
        rw [ha_eq, hr_eq]
        exact ⟨⟨fun h => absurd rfl (ne_of_lt h), fun h => absurd rfl (ne_of_lt h)⟩,
               ⟨fun _ => rfl, fun _ => rfl⟩⟩
    have sig_x_sel_data_R : ∀ (k : Fin L.card),
        (x' < a_sigma k ↔ x < resp_L k) ∧ (x' = a_sigma k ↔ x = resp_L k) := by
      rcases props.h_pt_xc with ⟨p_xc, hp_xc⟩ | ⟨hxc_eq, hx'd_eq, _, _⟩
      · intro k
        obtain ⟨_, _, hcond⟩ := hwin_L p_xc hp_xc
        obtain ⟨hord_aux, _, _⟩ := hcond
        have h := hord_aux ⟨0, by omega⟩ ⟨1 + k.val, by omega⟩
        simp only [game_tuple_zero_eq, game_tuple_sel_eq] at h; exact h
      · intro k
        have ha_eq : a_sigma k = d := le_antisymm (ha_sigma k).2 (hx'd_eq ▸ (ha_sigma k).1)
        have hr_eq : resp_L k = c := le_antisymm (hresp_L_in k).2 (hxc_eq ▸ (hresp_L_in k).1)
        rw [ha_eq, hx'd_eq, hr_eq, hxc_eq]
        exact ⟨⟨fun h => absurd rfl (ne_of_lt h), fun h => absurd rfl (ne_of_lt h)⟩,
               ⟨fun _ => rfl, fun _ => rfl⟩⟩
    have sig_sel_sel_data_R : ∀ (k k' : Fin L.card),
        (a_sigma k < a_sigma k' ↔ resp_L k < resp_L k') ∧
        (a_sigma k = a_sigma k' ↔ resp_L k = resp_L k') := by
      rcases props.h_pt_xc with ⟨p_xc, hp_xc⟩ | ⟨hxc_eq, hx'd_eq, _, _⟩
      · intro k k'
        obtain ⟨_, _, hcond⟩ := hwin_L p_xc hp_xc
        obtain ⟨hord_aux, _, _⟩ := hcond
        have h := hord_aux ⟨1 + k.val, by omega⟩ ⟨1 + k'.val, by omega⟩
        simp only [game_tuple_sel_eq] at h; exact h
      · intro k k'
        have ha_eq : a_sigma k = d := le_antisymm (ha_sigma k).2 (hx'd_eq ▸ (ha_sigma k).1)
        have ha_eq' : a_sigma k' = d := le_antisymm (ha_sigma k').2 (hx'd_eq ▸ (ha_sigma k').1)
        have hr_eq : resp_L k = c := le_antisymm (hresp_L_in k).2 (hxc_eq ▸ (hresp_L_in k).1)
        have hr_eq' : resp_L k' = c := le_antisymm (hresp_L_in k').2 (hxc_eq ▸ (hresp_L_in k').1)
        rw [ha_eq, ha_eq', hr_eq, hr_eq']
        exact ⟨⟨fun h => absurd rfl (ne_of_lt h), fun h => absurd rfl (ne_of_lt h)⟩,
               ⟨fun _ => rfl, fun _ => rfl⟩⟩
    -- ----- Per-index: gap_point and formula (right case) -----
    have hgp_sel_R : ∀ (j : Fin (n + 1)),
        (IsPoint (a_bwd j) ↔ IsPoint (a'_resp j)) ∧
        (IsGap (a_bwd j) ↔ IsGap (a'_resp j)) := by
      intro j
      by_cases hjd : a_bwd j < d
      · have hj_mem : j ∈ L := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd⟩
        simp only [a'_resp, hjd, dite_true]
        set k := isoL.symm ⟨j, hj_mem⟩
        have hsig_gp := hgp_L_sel_R k
        have hN_eq : a_sigma k = a_bwd j := by
          simp only [a_sigma]; congr 1; exact heL_inv j hj_mem
        rw [hN_eq] at hsig_gp; exact hsig_gp
      · have hj_mem : j ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd⟩
        simp only [a'_resp, hjd, dite_false]
        set k := isoR.symm ⟨j, hj_mem⟩
        have htau_gp := hgp_R ⟨1 + k.val, by omega⟩
        simp only [game_tuple,
          show (1 + k.val : Nat) ≠ 0 from by omega,
          show ¬((1 + ↑k : Nat) = R.card + 1) from by { have := k.isLt; omega },
          show ¬((1 + ↑k : Nat) = R.card + 2) from by { have := k.isLt; omega },
          dite_false, show 1 + ↑k - 1 = k.val from by omega] at htau_gp
        have hN_eq : a_tau k = a_bwd j := by
          simp only [a_tau]; congr 1; exact heR_inv j hj_mem
        rw [hN_eq] at htau_gp; exact htau_gp
    have hform_sel_R : ∀ (j : Fin (n + 1)) (A : StaviFormula), stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r (a_bwd j) A ↔
         stavi_temporal_truth_mu M atomMap r (a'_resp j) A) := by
      intro j A hA
      by_cases hjd : a_bwd j < d
      · have hj_mem : j ∈ L := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd⟩
        simp only [a'_resp, hjd, dite_true]
        set k := isoL.symm ⟨j, hj_mem⟩
        have hsig_form := hform_L_sel_R k A hA
        have hN_eq : a_sigma k = a_bwd j := by
          simp only [a_sigma]; congr 1; exact heL_inv j hj_mem
        rw [hN_eq] at hsig_form; exact hsig_form
      · have hj_mem : j ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd⟩
        simp only [a'_resp, hjd, dite_false]
        set k := isoR.symm ⟨j, hj_mem⟩
        have htau_form := hform_R ⟨1 + k.val, by omega⟩ A hA
        simp only [game_tuple,
          show (1 + k.val : Nat) ≠ 0 from by omega,
          show ¬((1 + ↑k : Nat) = R.card + 1) from by { have := k.isLt; omega },
          show ¬((1 + ↑k : Nat) = R.card + 2) from by { have := k.isLt; omega },
          dite_false, show 1 + ↑k - 1 = k.val from by omega] at htau_form
        have hN_eq : a_tau k = a_bwd j := by
          simp only [a_tau]; congr 1; exact heR_inv j hj_mem
        rw [hN_eq] at htau_form; exact htau_form
    -- Boundary gap/point and formula (from sigma_aux and tau)
    have hgp_x_R : (IsPoint x' ↔ IsPoint x) ∧ (IsGap x' ↔ IsGap x) := hgp_x_data_R
    have hgp_y_R : (IsPoint y' ↔ IsPoint y) ∧ (IsGap y' ↔ IsGap y) := by
      have := hgp_R ⟨R.card + 2, by omega⟩
      simp only [game_tuple, show (R.card + 2 : Nat) ≠ 0 from by omega,
        show ¬((R.card + 2 : Nat) = R.card + 1) from by omega,
        show (R.card + 2 : Nat) = R.card + 2 from rfl, dite_true, dite_false] at this
      exact this
    have hgp_b_R : (@IsPoint sig N atomMap r (extendPoint b_resp_R) ↔
                    @IsPoint sig M atomMap r (extendPoint b_sp)) ∧
                   (@IsGap sig N atomMap r (extendPoint b_resp_R) ↔
                    @IsGap sig M atomMap r (extendPoint b_sp)) := by
      constructor
      · exact ⟨fun _ => ⟨b_sp, rfl⟩, fun _ => ⟨b_resp_R, rfl⟩⟩
      · exact ⟨fun ⟨g, hg⟩ => absurd hg.symm Sum.inr_ne_inl,
               fun ⟨g, hg⟩ => absurd hg.symm Sum.inr_ne_inl⟩
    have hform_x_R : ∀ A, stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r x' A ↔ stavi_temporal_truth_mu M atomMap r x A) :=
      hform_x_data_R
    have hform_y_R : ∀ A, stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r y' A ↔ stavi_temporal_truth_mu M atomMap r y A) := by
      intro A hA
      have := hform_R ⟨R.card + 2, by omega⟩ A hA
      simp only [game_tuple, show (R.card + 2 : Nat) ≠ 0 from by omega,
        show ¬((R.card + 2 : Nat) = R.card + 1) from by omega,
        show (R.card + 2 : Nat) = R.card + 2 from rfl, dite_true, dite_false] at this
      exact this
    have hform_b_R : ∀ A, stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r (extendPoint b_resp_R) A ↔
         stavi_temporal_truth_mu M atomMap r (extendPoint b_sp) A) := by
      intro A hA
      have := hform_R ⟨R.card + 1, by omega⟩ A hA
      simp only [game_tuple, show (R.card + 1 : Nat) ≠ 0 from by omega,
        show (R.card + 1 : Nat) = R.card + 1 from rfl, dite_true] at this
      exact this
    -- ----- Assemble the winning condition (right case) -----
    refine ⟨?_, ?_, ?_⟩
    · -- same_order_type (n+1): symmetric to left case, with b in tau's sub-game
      -- Extract value-level orderings from sub-game same_order_types
      have tau_ord := fun a₁ a₂ : Fin (R.card + 3) => hord_R a₁ a₂
      -- Sigma boundary orderings
      have sig_x_d : (x' < d ↔ x < c) ∧ (x' = d ↔ x = c) := sig_x_d_data_R
      -- Tau boundary orderings
      have tau_d_y : (d < y' ↔ c < y) ∧ (d = y' ↔ c = y) := by
        have h := tau_ord ⟨0, by omega⟩ ⟨R.card + 2, by omega⟩
        simp only [game_tuple_zero_eq, game_tuple_y_eq] at h; exact h
      -- Tau: b_resp_R vs d ↔ b_sp vs c (b is in tau at index R.card+1 vs index 0)
      have tau_d_b : (d < extendPoint b_resp_R ↔ c < extendPoint b_sp) ∧
                     (d = extendPoint b_resp_R ↔ c = extendPoint b_sp) := by
        have h := tau_ord ⟨0, by omega⟩ ⟨R.card + 1, by omega⟩
        simp only [game_tuple_zero_eq, game_tuple_b_eq] at h; exact h
      -- Sigma: L-selection orderings
      have sig_x_sel : ∀ (k : Fin L.card),
          (x' < a_sigma k ↔ x < resp_L k) ∧ (x' = a_sigma k ↔ x = resp_L k) :=
        sig_x_sel_data_R
      have sig_sel_d : ∀ (k : Fin L.card),
          (a_sigma k < d ↔ resp_L k < c) ∧ (a_sigma k = d ↔ resp_L k = c) :=
        sig_sel_d_data_R
      have sig_sel_sel : ∀ (k k' : Fin L.card),
          (a_sigma k < a_sigma k' ↔ resp_L k < resp_L k') ∧
          (a_sigma k = a_sigma k' ↔ resp_L k = resp_L k') :=
        sig_sel_sel_data_R
      -- Tau: R-selection orderings
      have tau_d_sel : ∀ (k : Fin R.card),
          (d < a_tau k ↔ c < resp_R k) ∧ (d = a_tau k ↔ c = resp_R k) := by
        intro k; have h := tau_ord ⟨0, by omega⟩ ⟨1 + k.val, by omega⟩
        simp only [game_tuple_zero_eq, game_tuple_sel_eq] at h; exact h
      have tau_sel_y : ∀ (k : Fin R.card),
          (a_tau k < y' ↔ resp_R k < y) ∧ (a_tau k = y' ↔ resp_R k = y) := by
        intro k; have h := tau_ord ⟨1 + k.val, by omega⟩ ⟨R.card + 2, by omega⟩
        simp only [game_tuple_sel_eq, game_tuple_y_eq] at h; exact h
      have tau_sel_sel : ∀ (k k' : Fin R.card),
          (a_tau k < a_tau k' ↔ resp_R k < resp_R k') ∧
          (a_tau k = a_tau k' ↔ resp_R k = resp_R k') := by
        intro k k'; have h := tau_ord ⟨1 + k.val, by omega⟩ ⟨1 + k'.val, by omega⟩
        simp only [game_tuple_sel_eq] at h; exact h
      -- Tau: b vs selection
      have tau_b_sel : ∀ (k : Fin R.card),
          (extendPoint b_resp_R < a_tau k ↔ extendPoint b_sp < resp_R k) ∧
          (extendPoint b_resp_R = a_tau k ↔ extendPoint b_sp = resp_R k) := by
        intro k; have h := tau_ord ⟨R.card + 1, by omega⟩ ⟨1 + k.val, by omega⟩
        simp only [game_tuple_b_eq, game_tuple_sel_eq] at h; exact h
      have tau_sel_b : ∀ (k : Fin R.card),
          (a_tau k < extendPoint b_resp_R ↔ resp_R k < extendPoint b_sp) ∧
          (a_tau k = extendPoint b_resp_R ↔ resp_R k = extendPoint b_sp) := by
        intro k; have h := tau_ord ⟨1 + k.val, by omega⟩ ⟨R.card + 1, by omega⟩
        simp only [game_tuple_sel_eq, game_tuple_b_eq] at h; exact h
      have tau_b_y : (extendPoint b_resp_R < y' ↔ extendPoint b_sp < y) ∧
                     (extendPoint b_resp_R = y' ↔ extendPoint b_sp = y) := by
        have h := tau_ord ⟨R.card + 1, by omega⟩ ⟨R.card + 2, by omega⟩
        simp only [game_tuple_b_eq, game_tuple_y_eq] at h; exact h
      -- Interval bounds
      have ha_sig_le_d : ∀ (k : Fin L.card), a_sigma k ≤ d :=
        fun k => le_of_lt ((Finset.mem_filter.mp (Finset.orderEmbOfFin_mem L hL_card_eq k)).2)
      have hresp_L_le_c' : ∀ (k : Fin L.card), resp_L k ≤ c := fun k => (hresp_L_in k).2
      have hd_le_a_tau : ∀ (k : Fin R.card), d ≤ a_tau k :=
        fun k => not_lt.mp ((Finset.mem_filter.mp (Finset.orderEmbOfFin_mem R hR_card_eq k)).2)
      have hc_le_rR : ∀ (k : Fin R.card), c ≤ resp_R k := fun k => (hresp_R_in k).1
      -- Prove same_order_type by split_ifs
      intro i j; simp only [game_tuple]; split_ifs with
        hi0 hj0 _ _ _ hjb _ hjy _ hjd _ _ hib hj0 _ _ _ hjb _ hjy _ hjd _ _
        hiy hj0 _ _ _ hjb _ hjy _ hjd _ _ _ hid hj0 _ _ _ hjb _ hjy _ hjd _ _
      -- Goal 1: x vs x
      · exact ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
               ⟨fun _ => rfl, fun _ => rfl⟩⟩
      -- Goal 2: x vs b — pivot chain through d/c
      · exact pivot_chain_order props.hx'd hb_resp_R_in.1 props.hxc (le_of_lt hbc)
          sig_x_d.1 sig_x_d.2 tau_d_b.1 tau_d_b.2
      -- Goal 3: x vs y
      · exact pivot_chain_order props.hx'd props.hdy' props.hxc props.hcy
          sig_x_d.1 sig_x_d.2 tau_d_y.1 tau_d_y.2
      -- Goal 4: x vs sel(j)
      · set j' : Fin (n + 1) := ⟨j.val - 1, by omega⟩
        by_cases hjd' : a_bwd j' < d
        · have hj_mem : j' ∈ L := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd'⟩
          simp only [a'_resp, hjd', dite_true]
          set k := isoL.symm ⟨j', hj_mem⟩
          have : a_bwd j' = a_sigma k := by
            simp only [a_sigma]; congr 1; exact (heL_inv j' hj_mem).symm
          rw [this]; exact sig_x_sel k
        · have hj_mem : j' ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd'⟩
          simp only [a'_resp, hjd', dite_false]
          set k := isoR.symm ⟨j', hj_mem⟩
          have : a_bwd j' = a_tau k := by
            simp only [a_tau]; congr 1; exact (heR_inv j' hj_mem).symm
          rw [this]
          exact pivot_chain_order props.hx'd (hd_le_a_tau k)
            props.hxc (hc_le_rR k) sig_x_d.1 sig_x_d.2
            (tau_d_sel k).1 (tau_d_sel k).2
      -- Goal 5: b vs x — pivot chain reversed
      · exact pivot_chain_order_rev hb_resp_R_in.1 props.hx'd (le_of_lt hbc) props.hxc
          tau_d_b.1 tau_d_b.2 sig_x_d.1 sig_x_d.2
      -- Goal 6: b vs b
      · exact ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
               ⟨fun _ => rfl, fun _ => rfl⟩⟩
      -- Goal 7: b vs y — from tau (b is in tau)
      · exact tau_b_y
      -- Goal 8: b vs sel(j)
      · set j' : Fin (n + 1) := ⟨j.val - 1, by omega⟩
        by_cases hjd' : a_bwd j' < d
        · -- j' ∈ L: b > c > resp_L, b_resp > d > a_sigma
          have hj_mem : j' ∈ L := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd'⟩
          simp only [a'_resp, hjd', dite_true]
          set k := isoL.symm ⟨j', hj_mem⟩
          have : a_bwd j' = a_sigma k := by
            simp only [a_sigma]; congr 1; exact (heL_inv j' hj_mem).symm
          rw [this]
          exact pivot_chain_order_rev hb_resp_R_in.1 (ha_sig_le_d k)
            (le_of_lt hbc) (hresp_L_le_c' k)
            tau_d_b.1 tau_d_b.2 (sig_sel_d k).1 (sig_sel_d k).2
        · -- j' ∈ R: direct from tau
          have hj_mem : j' ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd'⟩
          simp only [a'_resp, hjd', dite_false]
          set k := isoR.symm ⟨j', hj_mem⟩
          have : a_bwd j' = a_tau k := by
            simp only [a_tau]; congr 1; exact (heR_inv j' hj_mem).symm
          rw [this]; exact tau_b_sel k
      -- Goal 9: y vs x
      · exact pivot_chain_order_rev props.hdy' props.hx'd props.hcy props.hxc
          tau_d_y.1 tau_d_y.2 sig_x_d.1 sig_x_d.2
      -- Goal 10: y vs b — from tau reversed
      · have h := tau_ord ⟨R.card + 2, by omega⟩ ⟨R.card + 1, by omega⟩
        simp only [game_tuple_y_eq, game_tuple_b_eq] at h; exact h
      -- Goal 11: y vs y
      · exact ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
               ⟨fun _ => rfl, fun _ => rfl⟩⟩
      -- Goal 12: y vs sel(j)
      · set j' : Fin (n + 1) := ⟨j.val - 1, by omega⟩
        by_cases hjd' : a_bwd j' < d
        · have hj_mem : j' ∈ L := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd'⟩
          simp only [a'_resp, hjd', dite_true]
          set k := isoL.symm ⟨j', hj_mem⟩
          have : a_bwd j' = a_sigma k := by
            simp only [a_sigma]; congr 1; exact (heL_inv j' hj_mem).symm
          rw [this]
          exact pivot_chain_order_rev props.hdy' (ha_sig_le_d k)
            props.hcy (hresp_L_le_c' k) tau_d_y.1 tau_d_y.2
            (sig_sel_d k).1 (sig_sel_d k).2
        · have hj_mem : j' ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd'⟩
          simp only [a'_resp, hjd', dite_false]
          set k := isoR.symm ⟨j', hj_mem⟩
          have : a_bwd j' = a_tau k := by
            simp only [a_tau]; congr 1; exact (heR_inv j' hj_mem).symm
          rw [this]
          have htsy := tau_sel_y k
          exact ⟨⟨fun h => absurd h (not_lt.mpr (ha_tau k).2),
                  fun h => absurd h (not_lt.mpr (hresp_R_in k).2)⟩,
                 ⟨fun h => (htsy.2.mp h.symm).symm,
                  fun h => (htsy.2.mpr h.symm).symm⟩⟩
      -- Goal 13: sel(i) vs x
      · set i' : Fin (n + 1) := ⟨i.val - 1, by omega⟩
        by_cases hid' : a_bwd i' < d
        · have hi_mem : i' ∈ L := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hid'⟩
          simp only [a'_resp, hid', dite_true]
          set k := isoL.symm ⟨i', hi_mem⟩
          have : a_bwd i' = a_sigma k := by
            simp only [a_sigma]; congr 1; exact (heL_inv i' hi_mem).symm
          rw [this]
          -- Ordering: a_sigma k vs x' ↔ resp_L k vs x
          rcases props.h_pt_xc with ⟨p_xc, hp_xc⟩ | ⟨hxc_eq, hx'd_eq, _, _⟩
          · obtain ⟨_, _, hcond⟩ := hwin_L p_xc hp_xc
            obtain ⟨hord_aux, _, _⟩ := hcond
            have h := hord_aux ⟨1 + k.val, by omega⟩ ⟨0, by omega⟩
            simp only [game_tuple_sel_eq, game_tuple_zero_eq] at h; exact h
          · have ha_eq : a_sigma k = d := le_antisymm (ha_sigma k).2 (hx'd_eq ▸ (ha_sigma k).1)
            have hr_eq : resp_L k = c := le_antisymm (hresp_L_in k).2 (hxc_eq ▸ (hresp_L_in k).1)
            rw [ha_eq, hx'd_eq, hr_eq, hxc_eq]
            exact ⟨⟨fun h => absurd rfl (ne_of_lt h), fun h => absurd rfl (ne_of_lt h)⟩,
                   ⟨fun _ => rfl, fun _ => rfl⟩⟩
        · have hi_mem : i' ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hid'⟩
          simp only [a'_resp, hid', dite_false]
          set k := isoR.symm ⟨i', hi_mem⟩
          have : a_bwd i' = a_tau k := by
            simp only [a_tau]; congr 1; exact (heR_inv i' hi_mem).symm
          rw [this]
          exact pivot_chain_order_rev (hd_le_a_tau k) props.hx'd
            (hc_le_rR k) props.hxc
            (tau_d_sel k).1 (tau_d_sel k).2 sig_x_d.1 sig_x_d.2
      -- Goal 14: sel(i) vs b
      · set i' : Fin (n + 1) := ⟨i.val - 1, by omega⟩
        by_cases hid' : a_bwd i' < d
        · have hi_mem : i' ∈ L := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hid'⟩
          simp only [a'_resp, hid', dite_true]
          set k := isoL.symm ⟨i', hi_mem⟩
          have : a_bwd i' = a_sigma k := by
            simp only [a_sigma]; congr 1; exact (heL_inv i' hi_mem).symm
          rw [this]
          exact pivot_chain_order (ha_sig_le_d k) hb_resp_R_in.1
            (hresp_L_le_c' k) (le_of_lt hbc)
            (sig_sel_d k).1 (sig_sel_d k).2 tau_d_b.1 tau_d_b.2
        · have hi_mem : i' ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hid'⟩
          simp only [a'_resp, hid', dite_false]
          set k := isoR.symm ⟨i', hi_mem⟩
          have : a_bwd i' = a_tau k := by
            simp only [a_tau]; congr 1; exact (heR_inv i' hi_mem).symm
          rw [this]; exact tau_sel_b k
      -- Goal 15: sel(i) vs y
      · set i' : Fin (n + 1) := ⟨i.val - 1, by omega⟩
        by_cases hid' : a_bwd i' < d
        · have hi_mem : i' ∈ L := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hid'⟩
          simp only [a'_resp, hid', dite_true]
          set k := isoL.symm ⟨i', hi_mem⟩
          have : a_bwd i' = a_sigma k := by
            simp only [a_sigma]; congr 1; exact (heL_inv i' hi_mem).symm
          rw [this]
          exact pivot_chain_order (ha_sig_le_d k) props.hdy'
            (hresp_L_le_c' k) props.hcy
            (sig_sel_d k).1 (sig_sel_d k).2 tau_d_y.1 tau_d_y.2
        · have hi_mem : i' ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hid'⟩
          simp only [a'_resp, hid', dite_false]
          set k := isoR.symm ⟨i', hi_mem⟩
          have : a_bwd i' = a_tau k := by
            simp only [a_tau]; congr 1; exact (heR_inv i' hi_mem).symm
          rw [this]; exact tau_sel_y k
      -- Goal 16: sel(i) vs sel(j)
      · set i' : Fin (n + 1) := ⟨i.val - 1, by omega⟩
        set j' : Fin (n + 1) := ⟨j.val - 1, by omega⟩
        by_cases hid' : a_bwd i' < d
        · have hi_mem : i' ∈ L := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hid'⟩
          simp only [a'_resp, hid', dite_true]
          set ki := isoL.symm ⟨i', hi_mem⟩
          have hi_eq : a_bwd i' = a_sigma ki := by
            simp only [a_sigma]; congr 1; exact (heL_inv i' hi_mem).symm
          rw [hi_eq]
          by_cases hjd' : a_bwd j' < d
          · have hj_mem : j' ∈ L := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd'⟩
            simp only [a'_resp, hjd', dite_true]
            set kj := isoL.symm ⟨j', hj_mem⟩
            have hj_eq : a_bwd j' = a_sigma kj := by
              simp only [a_sigma]; congr 1; exact (heL_inv j' hj_mem).symm
            rw [hj_eq]; exact sig_sel_sel ki kj
          · have hj_mem : j' ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd'⟩
            simp only [a'_resp, hjd', dite_false]
            set kj := isoR.symm ⟨j', hj_mem⟩
            have hj_eq : a_bwd j' = a_tau kj := by
              simp only [a_tau]; congr 1; exact (heR_inv j' hj_mem).symm
            rw [hj_eq]
            exact pivot_chain_order (ha_sig_le_d ki) (hd_le_a_tau kj)
              (hresp_L_le_c' ki) (hc_le_rR kj)
              (sig_sel_d ki).1 (sig_sel_d ki).2
              (tau_d_sel kj).1 (tau_d_sel kj).2
        · have hi_mem : i' ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hid'⟩
          simp only [a'_resp, hid', dite_false]
          set ki := isoR.symm ⟨i', hi_mem⟩
          have hi_eq : a_bwd i' = a_tau ki := by
            simp only [a_tau]; congr 1; exact (heR_inv i' hi_mem).symm
          rw [hi_eq]
          by_cases hjd' : a_bwd j' < d
          · have hj_mem : j' ∈ L := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd'⟩
            simp only [a'_resp, hjd', dite_true]
            set kj := isoL.symm ⟨j', hj_mem⟩
            have hj_eq : a_bwd j' = a_sigma kj := by
              simp only [a_sigma]; congr 1; exact (heL_inv j' hj_mem).symm
            rw [hj_eq]
            exact pivot_chain_order_rev (hd_le_a_tau ki) (ha_sig_le_d kj)
              (hc_le_rR ki) (hresp_L_le_c' kj)
              (tau_d_sel ki).1 (tau_d_sel ki).2
              (sig_sel_d kj).1 (sig_sel_d kj).2
          · have hj_mem : j' ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd'⟩
            simp only [a'_resp, hjd', dite_false]
            set kj := isoR.symm ⟨j', hj_mem⟩
            have hj_eq : a_bwd j' = a_tau kj := by
              simp only [a_tau]; congr 1; exact (heR_inv j' hj_mem).symm
            rw [hj_eq]; exact tau_sel_sel ki kj
    · -- gap_point_agreement (n+1)
      exact gap_point_agreement_of_cases hgp_x_R hgp_b_R hgp_y_R hgp_sel_R
    · -- formula_agreement (n+1)
      exact formula_agreement_of_cases hform_x_R hform_b_R hform_y_R hform_sel_R

/-! ### Case II: a_n is a Point

When ALL of Spoiler's backward selections a_0,...,a_n lie in [d,y']
and a_n (= d) is an actual point, Duplicator applies τ to the init
sub-sequence a_0,...,a_{n-1} (n elements, fitting τ's n-round game
on [d,y']/[c,y]).  For the last selection a_n = d, Duplicator responds
with c (the corresponding split point in M).

Since d = a_bwd(n) from obtain_split_point_props, and d is a point,
the gap/point and formula agreement at the n-th position follow from
the properties established during the split point construction.

Round 2 is delegated to τ when b_sp ∈ [c,y], and to σ when b_sp ∈ [x,c).
The winning condition is assembled from τ's winning condition at the
init indices plus the (c,d) correspondence at the n-th index. -/

set_option maxHeartbeats 1600000

/-- **Case II helper**: When all selections lie in [d,y'] and a_n is a
    point, construct Duplicator's response using τ on the init sub-sequence
    and c as the response for a_n = d.

    The proof applies τ to a_0,...,a_{n-1}, sets a'_resp(n) = c,
    and transfers the winning condition from τ's n-round game to the
    full (n+1)-round game by injecting the (c,d) boundary pair. -/
private theorem ghr93_case_II {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {n r : Nat}
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r}
    {d : ExtendedCarrier N atomMap r}
    {a_bwd : Fin (n + 1) → ExtendedCarrier N atomMap r}
    (props : SplitPointProps n x y x' y' c d a_bwd)
    (ha_bwd : ∀ i, inClosedInterval x' y' (a_bwd i))
    (h_no_split : ∀ i : Fin (n + 1), d ≤ a_bwd i)
    (h_point : IsPoint (a_bwd ⟨n, by omega⟩)) :
    ∃ (a'_resp : Fin (n + 1) → ExtendedCarrier M atomMap r),
      (∀ i, inClosedInterval x y (a'_resp i)) ∧
      ∀ (b_sp : M.carrier),
        inClosedInterval x y (extendPoint b_sp) →
        ∃ (b_resp : N.carrier),
          inClosedInterval x' y' (extendPoint b_resp) ∧
          ghr93_winning_condition (n + 1)
            (game_tuple x' y' a_bwd b_resp)
            (game_tuple x y a'_resp b_sp) := by
  -- GHR93 Case II: all a_bwd(i) ≥ d, a_bwd(n) is a point.
  -- Step 1: Build init sub-sequence (first n elements, all in [d, y'])
  let a_init : Fin n → ExtendedCarrier N atomMap r :=
    fun k => a_bwd ⟨k.val, by omega⟩
  have ha_init : ∀ k, inClosedInterval d y' (a_init k) := by
    intro k
    exact ⟨h_no_split ⟨k.val, by omega⟩, (ha_bwd ⟨k.val, by omega⟩).2⟩
  -- Step 2: Apply τ to the init sub-sequence
  obtain ⟨resp_tau, hresp_tau_in, hwin_tau⟩ := props.tau a_init ha_init
  -- resp_tau : Fin n → ExtendedCarrier M atomMap r, all in [c, y]
  -- Step 3: Construct e_n using the (n+1)-round forward game.
  -- a_bwd(n) is a carrier point p_n in [d, y'] ⊆ [x', y'].
  obtain ⟨p_n, hp_n⟩ := h_point
  have hp_n_in : inClosedInterval x' y' (extendPoint p_n) := by
    have := ha_bwd ⟨n, by omega⟩; rw [hp_n] at this; exact this
  -- Build M-side selections: resp_tau(i) for i < n, then c at position n.
  -- This allows the forward game to produce N-side responses that correspond
  -- to the tau sub-game, then we use round 2 with p_n for the e_n match.
  let a_M : Fin (n + 1) → ExtendedCarrier M atomMap r := fun i =>
    if h : i.val < n then resp_tau ⟨i.val, h⟩ else c
  have ha_M : ∀ i, inClosedInterval x y (a_M i) := by
    intro i; simp only [a_M]
    split
    case isTrue h =>
      have := hresp_tau_in ⟨i.val, h⟩
      exact ⟨le_trans props.hxc this.1, this.2⟩
    case isFalse _ => exact props.hc_interval
  -- Play the (n+1)-round forward game
  obtain ⟨a_N, ha_N, hwin_fwd⟩ := props.h_fwd_n1 a_M ha_M
  -- Challenge round 2 with p_n (carrier point of a_bwd(n)) to get e_n_pt
  obtain ⟨e_n_pt, he_n_pt_in, hcond_fwd⟩ := hwin_fwd p_n hp_n_in
  let e_n : ExtendedCarrier M atomMap r := extendPoint e_n_pt
  have he_n_in : inClosedInterval x y e_n := he_n_pt_in
  -- hcond_fwd gives the FORWARD winning condition:
  -- ghr93_winning_condition (n+1) (game_tuple x y a_M e_n_pt) (game_tuple x' y' a_N p_n)
  -- By symmetry, we also get:
  -- ghr93_winning_condition (n+1) (game_tuple x' y' a_N p_n) (game_tuple x y a_M e_n_pt)
  have hcond_sym := (ghr93_winning_condition_symm _ _).mp hcond_fwd
  -- Extract formula agreement at position n+1 (e_n vs a_bwd(n))
  obtain ⟨hord_fwd, hgp_fwd, hform_fwd⟩ := hcond_fwd
  have hform_en_an : ∀ (A : StaviFormula), stavi_depth A ≤ r →
      (stavi_temporal_truth_mu M atomMap r e_n A ↔
       stavi_temporal_truth_mu N atomMap r (a_bwd ⟨n, by omega⟩) A) := by
    intro A hA
    have h := hform_fwd ⟨n + 2, by omega⟩ A hA
    simp only [game_tuple, show (n + 2 : Nat) ≠ 0 from by omega,
               show (n + 2 : Nat) = (n + 1) + 1 from by omega,
               show (n + 2 : Nat) ≠ (n + 1) + 2 from by omega,
               dite_true, dite_false] at h
    rw [hp_n]; exact h
  -- The full winning condition assembly (sorry'd — see below for plan):
  -- The forward winning condition relates (a_M, e_n_pt) to (a_N, p_n).
  -- We need to relate (a_bwd, b_resp) to (merged_resp, b_sp).
  -- The key gap: a_N ≠ a_bwd in general, so the forward winning condition
  -- doesn't directly give us the backward winning condition.
  -- The assembly requires combining tau's ordering with the e_n ordering.
  obtain ⟨e_n, he_n_in, he_n_props⟩ :
      ∃ e_n : ExtendedCarrier M atomMap r,
        inClosedInterval x y e_n ∧
        (∀ (b_sp : M.carrier), inClosedInterval x y (extendPoint b_sp) →
          ∃ (b_resp : N.carrier), inClosedInterval x' y' (extendPoint b_resp) ∧
            ghr93_winning_condition (n + 1)
              (game_tuple x' y' a_bwd b_resp)
              (game_tuple x y (fun i => if h : i.val < n then resp_tau ⟨i.val, h⟩ else e_n) b_sp)) := by
    refine ⟨e_n, he_n_in, ?_⟩
    intro b_sp hb_sp
    -- Case split on b_sp vs c for round-2 delegation
    by_cases hbc : extendPoint (sig := sig) (atomMap := atomMap) (r := r) b_sp ≤ c
    · -- Case A: b_sp ∈ [x, c]. Use sigma for round 2.
      have hd_in_x'd : inClosedInterval x' d d := ⟨props.hx'd, le_refl d⟩
      obtain ⟨_resp_sig, _, hwin_sig⟩ :=
        props.sigma (fun _ : Fin n => d) (fun _ => hd_in_x'd)
      obtain ⟨b_resp, hb_resp_in, hcond_sig⟩ :=
        hwin_sig b_sp ⟨hb_sp.1, hbc⟩
      -- b_resp ∈ [x', d] ⊆ [x', y']
      refine ⟨b_resp, ⟨hb_resp_in.1, le_trans hb_resp_in.2 props.hdy'⟩, ?_⟩
      -- Assemble winning condition from tau + sigma + e_n data.
      -- b_resp comes from sigma (in [x',d]), tau provides positions 1..n.
      -- For tau ordering at positions 1..n, use an arbitrary point in [c,y]
      -- to instantiate hwin_tau and extract ordering/formula data.
      obtain ⟨hord_sig, hgp_sig, hform_sig⟩ := hcond_sig
      -- Extract tau winning condition at inner positions by instantiating
      -- hwin_tau with an arbitrary carrier point in [c, y].
      -- In Case II, the degenerate case (c = y gap) is impossible because
      -- d = y' and a_bwd(n) is a point, but d would be a gap — contradiction.
      have ⟨p_cy, hp_cy⟩ : ∃ (p : M.carrier), inClosedInterval c y (extendPoint p) := by
        rcases props.h_pt_cy with ⟨p_cy, hp_cy⟩ | ⟨_, hdy'_eq, _, hgap_d⟩
        · exact ⟨p_cy, hp_cy⟩
        · -- d = y', d is gap, but a_bwd(n) ∈ [d, y'] = [d, d] is a point — contradiction
          obtain ⟨g_d, hg_d⟩ := hgap_d
          have ha_eq : a_bwd ⟨n, by omega⟩ = d :=
            le_antisymm (hdy'_eq ▸ (ha_bwd ⟨n, by omega⟩).2) (h_no_split ⟨n, by omega⟩)
          -- a_bwd(n) = extendPoint p_n, so d = extendPoint p_n, but d = Sum.inr g_d
          have : d = extendPoint p_n := ha_eq ▸ hp_n
          exact absurd (this.symm ▸ hg_d : extendPoint p_n = Sum.inr g_d) (by simp [extendPoint])
      obtain ⟨_b_tau, _hb_tau_in, hcond_tau_aux⟩ := hwin_tau p_cy hp_cy
      obtain ⟨hord_tau_aux, hgp_tau_aux, hform_tau_aux⟩ := hcond_tau_aux
      -- hgp_tau_aux/hform_tau_aux at positions 1..n give a_init(k)/resp_tau(k)
      -- agreement, independent of the Round 2 point p_cy.
      refine ⟨?_, ?_, ?_⟩
      · -- same_order_type (n+1): sigma sub-case
        -- Uses task 195 tactics: same_order_type_grid, order_refl,
        -- simp_game_tuple, pivot_chain_order'
        have hab_n : a_bwd ⟨n, by omega⟩ = extendPoint p_n := hp_n
        have hab_eq : ∀ (k : Nat) (hk : k < n + 1), ¬(k < n) →
            a_bwd ⟨k, hk⟩ = extendPoint p_n := by
          intro k hk hkn
          have : k = n := Nat.eq_of_lt_succ_of_not_lt hk hkn
          subst this; exact hp_n
        -- Extract orderings from three sub-games using simp_game_tuple
        have fwd_x_b : (x < e_n ↔ x' < extendPoint p_n) ∧
            (x = e_n ↔ x' = extendPoint p_n) := by
          have h := hord_fwd ⟨0, by omega⟩ ⟨n + 1 + 1, by omega⟩
          simp_game_tuple at h; exact h
        have fwd_x_y : (x < y ↔ x' < y') ∧ (x = y ↔ x' = y') := by
          have h := hord_fwd ⟨0, by omega⟩ ⟨n + 1 + 2, by omega⟩
          simp_game_tuple at h; exact h
        have fwd_b_y : (e_n < y ↔ extendPoint p_n < y') ∧
            (e_n = y ↔ extendPoint p_n = y') := by
          have h := hord_fwd ⟨n + 1 + 1, by omega⟩ ⟨n + 1 + 2, by omega⟩
          simp_game_tuple at h; exact h
        have sig_x_b : (x' < extendPoint b_resp ↔ x < extendPoint b_sp) ∧
            (x' = extendPoint b_resp ↔ x = extendPoint b_sp) := by
          have h := hord_sig ⟨0, by omega⟩ ⟨n + 1, by omega⟩
          simp_game_tuple at h; exact h
        have sig_x_d : (x' < d ↔ x < c) ∧ (x' = d ↔ x = c) := by
          have h := hord_sig ⟨0, by omega⟩ ⟨n + 2, by omega⟩
          simp_game_tuple at h; exact h
        have sig_b_d : (extendPoint b_resp < d ↔ extendPoint b_sp < c) ∧
            (extendPoint b_resp = d ↔ extendPoint b_sp = c) := by
          have h := hord_sig ⟨n + 1, by omega⟩ ⟨n + 2, by omega⟩
          simp_game_tuple at h; exact h
        have tau_d_y' : (d < y' ↔ c < y) ∧ (d = y' ↔ c = y) := by
          have h := hord_tau_aux ⟨0, by omega⟩ ⟨n + 2, by omega⟩
          simp_game_tuple at h; exact h
        have tau_d_sel : ∀ (k : Fin n),
            (d < a_init k ↔ c < resp_tau k) ∧
            (d = a_init k ↔ c = resp_tau k) := by
          intro k; have h := hord_tau_aux ⟨0, by omega⟩ ⟨1 + k.val, by omega⟩
          simp_game_tuple at h; exact h
        have tau_sel_y : ∀ (k : Fin n),
            (a_init k < y' ↔ resp_tau k < y) ∧
            (a_init k = y' ↔ resp_tau k = y) := by
          intro k; have h := hord_tau_aux ⟨1 + k.val, by omega⟩ ⟨n + 2, by omega⟩
          simp_game_tuple at h; exact h
        have tau_sel_sel : ∀ (k k' : Fin n),
            (a_init k < a_init k' ↔ resp_tau k < resp_tau k') ∧
            (a_init k = a_init k' ↔ resp_tau k = resp_tau k') := by
          intro k k'
          have h := hord_tau_aux ⟨1 + k.val, by omega⟩ ⟨1 + k'.val, by omega⟩
          simp_game_tuple at h; exact h
        have hd_le_sel : ∀ (k : Fin n), d ≤ a_init k :=
          fun k => (ha_init k).1
        have hc_le_rtau : ∀ (k : Fin n), c ≤ resp_tau k :=
          fun k => (hresp_tau_in k).1
        -- Dispatch all N×N grid cases
        same_order_type_grid <;>
          -- Rewrite a_bwd(k) to extendPoint p_n when k = n
          (try rw [hab_eq _ _ (by assumption)]) <;>
          (try rw [hab_eq _ _ (by assumption)]) <;>
          first
          | order_refl
          | exact sig_x_b | exact ⟨sig_x_b.1.symm, sig_x_b.2.symm⟩
          | exact fwd_x_y | exact ⟨fwd_x_y.1.symm, fwd_x_y.2.symm⟩
          | exact fwd_b_y | exact ⟨fwd_b_y.1.symm, fwd_b_y.2.symm⟩
          | exact ⟨fwd_x_b.1.symm, fwd_x_b.2.symm⟩ | exact fwd_x_b
          -- b vs y pivot through d/c
          | exact pivot_chain_order' hb_resp_in.2 props.hdy' hbc props.hcy
              sig_b_d tau_d_y'
          | exact pivot_chain_order_rev' props.hdy' hb_resp_in.2 props.hcy hbc
              tau_d_y' sig_b_d
          -- x vs b pivot through x'/x
          | exact pivot_chain_order' props.hx'd hb_resp_in.1 props.hxc hb_sp.1
              sig_x_d sig_x_b
          | exact pivot_chain_order_rev' hb_resp_in.1 props.hx'd hb_sp.1 props.hxc
              sig_x_b sig_x_d
          -- x vs y pivot through d/c
          | exact pivot_chain_order_rev' props.hdy' props.hx'd props.hcy props.hxc
              tau_d_y' sig_x_d
          | exact pivot_chain_order' props.hx'd props.hdy' props.hxc props.hcy
              sig_x_d tau_d_y'
          -- tau selection vs y
          | exact tau_sel_y ⟨_, ‹_›⟩
          | exact ⟨(tau_sel_y ⟨_, ‹_›⟩).1.symm, (tau_sel_y ⟨_, ‹_›⟩).2.symm⟩
          -- tau selection vs selection
          | exact tau_sel_sel ⟨_, ‹_›⟩ ⟨_, ‹_›⟩
          -- x vs selection pivot through d/c
          | exact pivot_chain_order' props.hx'd (hd_le_sel ⟨_, ‹_›⟩) props.hxc
              (hc_le_rtau ⟨_, ‹_›⟩) sig_x_d (tau_d_sel ⟨_, ‹_›⟩)
          | exact pivot_chain_order_rev' (hd_le_sel ⟨_, ‹_›⟩) props.hx'd
              (hc_le_rtau ⟨_, ‹_›⟩) props.hxc (tau_d_sel ⟨_, ‹_›⟩) sig_x_d
          -- b vs selection pivot through d/c
          | exact pivot_chain_order' hb_resp_in.2 (hd_le_sel ⟨_, ‹_›⟩) hbc
              (hc_le_rtau ⟨_, ‹_›⟩) sig_b_d (tau_d_sel ⟨_, ‹_›⟩)
          | exact pivot_chain_order_rev' (hd_le_sel ⟨_, ‹_›⟩) hb_resp_in.2
              (hc_le_rtau ⟨_, ‹_›⟩) hbc (tau_d_sel ⟨_, ‹_›⟩) sig_b_d
          -- selection vs y pivot through d/c
          | exact pivot_chain_order_rev' props.hdy' (hd_le_sel ⟨_, ‹_›⟩)
              props.hcy (hc_le_rtau ⟨_, ‹_›⟩) tau_d_y' (tau_d_sel ⟨_, ‹_›⟩)
          | exact pivot_chain_order' (hd_le_sel ⟨_, ‹_›⟩) props.hdy'
              (hc_le_rtau ⟨_, ‹_›⟩) props.hcy (tau_d_sel ⟨_, ‹_›⟩) tau_d_y'
          -- selection vs p_n/e_n pivot through d/c then d/c→p_n/e_n via fwd_x_b
          | (exact pivot_chain_order' (hd_le_sel ⟨_, ‹_›⟩)
              (le_trans (h_no_split ⟨_, by omega⟩)
                (by rw [← hab_n]; exact le_refl _))
              (hc_le_rtau ⟨_, ‹_›⟩) he_n_in.1
              (tau_d_sel ⟨_, ‹_›⟩) fwd_x_b)
          | (exact pivot_chain_order_rev'
              (le_trans (h_no_split ⟨_, by omega⟩)
                (by rw [← hab_n]; exact le_refl _))
              (hd_le_sel ⟨_, ‹_›⟩) he_n_in.1 (hc_le_rtau ⟨_, ‹_›⟩)
              fwd_x_b (tau_d_sel ⟨_, ‹_›⟩))
          -- Remaining impossible-direction goals (both sides False for <)
          -- b_resp vs x (b_resp ≥ x', b_sp ≥ x)
          | (exact ⟨⟨fun h => absurd (lt_of_lt_of_le h hb_resp_in.1) (lt_irrefl _),
                     fun h => absurd (lt_of_lt_of_le h hb_sp.1) (lt_irrefl _)⟩,
                    ⟨fun h => by rw [h] at hb_resp_in; exact absurd
                       (lt_of_lt_of_le (sig_x_b.1.mpr (lt_of_le_of_eq hb_sp.1
                         (sig_x_b.2.mp hb_resp_in.1.symm).symm)) hb_resp_in.1)
                       (lt_irrefl _),
                     fun h => by rw [h] at hb_sp; exact absurd
                       (lt_of_lt_of_le (sig_x_b.1.mp (lt_of_le_of_eq hb_resp_in.1
                         (sig_x_b.2.mpr hb_sp.1.symm).symm)) hb_sp.1)
                       (lt_irrefl _)⟩⟩)
          -- y' vs a_init(k) (a_init(k) ≤ y', resp_tau(k) ≤ y; both < False)
          | (exact ⟨⟨fun h => absurd (lt_of_lt_of_le h (ha_bwd ⟨_, by omega⟩).2)
                       (lt_irrefl _),
                     fun h => absurd (lt_of_lt_of_le h (hresp_tau_in ⟨_, ‹_›⟩).2)
                       (lt_irrefl _)⟩,
                    ⟨fun h => ((tau_sel_y ⟨_, ‹_›⟩).2.mp (by
                       convert h.symm using 2; congr 1; exact Fin.ext (by omega))).symm,
                     fun h => by
                       have := (tau_sel_y ⟨_, ‹_›⟩).2.mpr h.symm
                       convert this.symm using 2; congr 1; exact Fin.ext (by omega)⟩⟩)
          -- y' vs p_n (p_n ≤ y', e_n ≤ y; both < False)
          | (exact ⟨⟨fun h => absurd (lt_of_lt_of_le h hp_n_in.2) (lt_irrefl _),
                     fun h => absurd (lt_of_lt_of_le h he_n_in.2) (lt_irrefl _)⟩,
                    ⟨fun h => (fwd_b_y.2.mpr h.symm).symm,
                     fun h => (fwd_b_y.2.mp h.symm).symm⟩⟩)
          -- p_n vs x' (p_n ≥ x', e_n ≥ x; both < False)
          | (exact ⟨⟨fun h => absurd (lt_of_lt_of_le h hp_n_in.1) (lt_irrefl _),
                     fun h => absurd (lt_of_lt_of_le h he_n_in.1) (lt_irrefl _)⟩,
                    ⟨fun h => (fwd_x_b.2.mpr h.symm).symm,
                     fun h => (fwd_x_b.2.mp h.symm).symm⟩⟩)
          -- Remaining goals involving p_n/e_n cross-boundary orderings.
          -- These require c ≤ e_n (or equivalent) which is not available
          -- from the current sub-game data. Closing these goals depends on
          -- h_d_unique (GHR93 Claim 1) or a restructured forward game
          -- argument. See handoff for details.
          | sorry
      · -- gap_point_agreement (n+1)
        intro i
        simp only [game_tuple]
        split_ifs with h0 hn1 hn2 h0' hlt
        · -- i=0: x'/x — from forward game at position 0
          have hfwd0 := hgp_fwd ⟨0, by omega⟩
          simp only [game_tuple, dite_true] at hfwd0
          exact ⟨hfwd0.1.symm, hfwd0.2.symm⟩
        · -- i=n+2: extendPoint b_resp / extendPoint b_sp (both are Sum.inl)
          constructor
          · exact ⟨fun _ => ⟨b_sp, rfl⟩, fun _ => ⟨b_resp, rfl⟩⟩
          · constructor <;> intro ⟨g, hg⟩ <;> cases hg
        · -- i=n+3: y'/y — from forward game at last position
          have hfwd_last := hgp_fwd ⟨n + 1 + 2, by omega⟩
          simp only [game_tuple, show (n + 1 + 2 : Nat) ≠ 0 from by omega,
                     show (n + 1 + 2 : Nat) ≠ n + 1 + 1 from by omega,
                     dite_false, dite_true] at hfwd_last
          exact ⟨hfwd_last.1.symm, hfwd_last.2.symm⟩
        · -- i inner, i-1 < n: a_bwd(i-1)/resp_tau(i-1) — from tau aux at position i
          have htau_i := hgp_tau_aux ⟨i.val, by omega⟩
          simp only [game_tuple, show i.val ≠ 0 from h0,
                     show i.val ≠ n + 1 from by omega,
                     show i.val ≠ n + 2 from by omega,
                     dite_false] at htau_i
          convert htau_i using 2 <;> congr 1 <;> exact Fin.ext (by omega)
        · -- i inner, i-1=n: a_bwd(n)/e_n — both are Sum.inl (point)
          have hi_eq : i.val - 1 = n := by omega
          have hab : (a_bwd ⟨i.val - 1, by omega⟩ : ExtendedCarrier N atomMap r) =
                     a_bwd ⟨n, by omega⟩ := by congr 1; exact Fin.ext hi_eq
          rw [hab, hp_n]
          constructor
          · exact ⟨fun _ => ⟨e_n_pt, rfl⟩, fun _ => ⟨p_n, rfl⟩⟩
          · constructor <;> intro ⟨g, hg⟩ <;> exact (Sum.inl_ne_inr hg).elim
      · -- formula_agreement (n+1)
        intro i A hA
        simp only [game_tuple]
        split_ifs with h0 hn1 hn2 h0' hlt
        · -- i=0: x'/x — from forward game at position 0
          have hfwd0 := hform_fwd ⟨0, by omega⟩ A hA
          simp only [game_tuple, dite_true] at hfwd0
          exact hfwd0.symm
        · -- i=n+2: extendPoint b_resp / extendPoint b_sp — from sigma at position n+1
          have hsig_n1 := hform_sig ⟨n + 1, by omega⟩ A hA
          simp only [game_tuple, show (n + 1 : Nat) ≠ 0 from by omega,
                     show (n + 1 : Nat) = n + 1 from rfl,
                     dite_false, dite_true] at hsig_n1
          exact hsig_n1
        · -- i=n+3: y'/y — from forward game at last position
          have hfwd_last := hform_fwd ⟨n + 1 + 2, by omega⟩ A hA
          simp only [game_tuple, show (n + 1 + 2 : Nat) ≠ 0 from by omega,
                     show (n + 1 + 2 : Nat) ≠ n + 1 + 1 from by omega,
                     dite_false, dite_true] at hfwd_last
          exact hfwd_last.symm
        · -- i inner, i-1 < n: a_bwd(i-1)/resp_tau(i-1) — from tau aux at position i
          have htau_i := hform_tau_aux ⟨i.val, by omega⟩ A hA
          simp only [game_tuple, show i.val ≠ 0 from h0,
                     show i.val ≠ n + 1 from by omega,
                     show i.val ≠ n + 2 from by omega,
                     dite_false] at htau_i
          convert htau_i using 2 <;> congr 1 <;> exact Fin.ext (by omega)
        · -- i inner, i-1=n: a_bwd(n)/e_n — from hform_en_an
          have hi_eq : i.val - 1 = n := by omega
          have hab : (a_bwd ⟨i.val - 1, by omega⟩ : ExtendedCarrier N atomMap r) =
                     a_bwd ⟨n, by omega⟩ := by congr 1; exact Fin.ext hi_eq
          rw [hab]
          exact (hform_en_an A hA).symm
    · -- Case B: b_sp > c, i.e., b_sp ∈ (c, y]. Use tau for round 2.
      push_neg at hbc
      have hc_lt_bsp : c < extendPoint (sig := sig) (atomMap := atomMap) (r := r) b_sp := hbc
      have hb_sp_cy : inClosedInterval c y (extendPoint b_sp) :=
        ⟨le_of_lt hc_lt_bsp, hb_sp.2⟩
      obtain ⟨b_resp, hb_resp_in, hcond_tau⟩ := hwin_tau b_sp hb_sp_cy
      -- b_resp ∈ [d, y'] ⊆ [x', y']
      refine ⟨b_resp, ⟨le_trans props.hx'd hb_resp_in.1, hb_resp_in.2⟩, ?_⟩
      -- Assemble winning condition from tau + e_n data.
      -- The target: ghr93_winning_condition (n+1)
      --   (game_tuple x' y' a_bwd b_resp)
      --   (game_tuple x y merged_resp b_sp)
      -- where merged_resp(i) = resp_tau(i) for i < n, merged_resp(n) = e_n.
      --
      -- We have hcond_tau: winning condition on (n)-round game
      --   (game_tuple d y' a_init b_resp) vs (game_tuple c y resp_tau b_sp)
      -- and hform_en_an: e_n and a_bwd(n) agree on rank-r formulas.
      --
      -- The (n+1)-round game tuple extends the tau game with:
      --   position 0: x'/x (instead of d/c)
      --   position n+1: a_bwd(n)/e_n (new position)
      --
      -- The ordering, gp, and formula properties at the tau-covered positions
      -- follow from hcond_tau (shifted). At position n+1 they follow from
      -- the forward game properties.
      obtain ⟨hord_tau, hgp_tau, hform_tau⟩ := hcond_tau
      refine ⟨?_, ?_, ?_⟩
      · -- same_order_type (n+1): tau sub-case
        -- Round 9 finding: The block-commented proofs relied on simp_all which
        -- behaves differently in file vs multi_attempt context due to hypothesis
        -- rewriting. Additionally, the proofs had sorry fallbacks (not fully
        -- verified). The pivot_chain_order approach needs (x' < d ↔ x < c)
        -- which requires instantiating the sigma strategy. Deferred.
        sorry
        /- Dead code preserved for reference (tau ordering extractions):
        have hd_le_an := props.hd_le_an
        -- Forward game orderings
        have fwd_x_b : (x < e_n ↔ x' < extendPoint p_n) ∧
            (x = e_n ↔ x' = extendPoint p_n) := by
          have h := hord_fwd ⟨0, by omega⟩ ⟨n + 1 + 1, by omega⟩
          simp only [game_tuple_zero_eq, game_tuple_b_eq] at h; exact h
        have fwd_x_y : (x < y ↔ x' < y') ∧ (x = y ↔ x' = y') := by
          have h := hord_fwd ⟨0, by omega⟩ ⟨n + 1 + 2, by omega⟩
          simp only [game_tuple_zero_eq, game_tuple_y_eq] at h; exact h
        have fwd_b_y : (e_n < y ↔ extendPoint p_n < y') ∧
            (e_n = y ↔ extendPoint p_n = y') := by
          have h := hord_fwd ⟨n + 1 + 1, by omega⟩ ⟨n + 1 + 2, by omega⟩
          simp only [game_tuple_b_eq, game_tuple_y_eq] at h; exact h
        -- Tau game orderings
        have tau_d_b : (d < extendPoint b_resp ↔ c < extendPoint b_sp) ∧
            (d = extendPoint b_resp ↔ c = extendPoint b_sp) := by
          have h := hord_tau ⟨0, by omega⟩ ⟨n + 1, by omega⟩
          simp only [game_tuple_zero_eq, game_tuple_b_eq] at h; exact h
        have tau_d_y' : (d < y' ↔ c < y) ∧ (d = y' ↔ c = y) := by
          have h := hord_tau ⟨0, by omega⟩ ⟨n + 2, by omega⟩
          simp only [game_tuple_zero_eq, game_tuple_y_eq] at h; exact h
        have tau_b_y' : (extendPoint b_resp < y' ↔ extendPoint b_sp < y) ∧
            (extendPoint b_resp = y' ↔ extendPoint b_sp = y) := by
          have h := hord_tau ⟨n + 1, by omega⟩ ⟨n + 2, by omega⟩
          simp only [game_tuple_b_eq, game_tuple_y_eq] at h; exact h
        have tau_d_sel : ∀ (k : Fin n),
            (d < a_init k ↔ c < resp_tau k) ∧ (d = a_init k ↔ c = resp_tau k) := by
          intro k; have h := hord_tau ⟨0, by omega⟩ ⟨1 + k.val, by omega⟩
          simp only [game_tuple_zero_eq, game_tuple_sel_eq] at h; exact h
        have tau_sel_b : ∀ (k : Fin n),
            (a_init k < extendPoint b_resp ↔ resp_tau k < extendPoint b_sp) ∧
            (a_init k = extendPoint b_resp ↔ resp_tau k = extendPoint b_sp) := by
          intro k; have h := hord_tau ⟨1 + k.val, by omega⟩ ⟨n + 1, by omega⟩
          simp only [game_tuple_sel_eq, game_tuple_b_eq] at h; exact h
        have tau_sel_y : ∀ (k : Fin n),
            (a_init k < y' ↔ resp_tau k < y) ∧
            (a_init k = y' ↔ resp_tau k = y) := by
          intro k; have h := hord_tau ⟨1 + k.val, by omega⟩ ⟨n + 2, by omega⟩
          simp only [game_tuple_sel_eq, game_tuple_y_eq] at h; exact h
        have tau_sel_sel : ∀ (k k' : Fin n),
            (a_init k < a_init k' ↔ resp_tau k < resp_tau k') ∧
            (a_init k = a_init k' ↔ resp_tau k = resp_tau k') := by
          intro k k'; have h := hord_tau ⟨1 + k.val, by omega⟩ ⟨1 + k'.val, by omega⟩
          simp only [game_tuple_sel_eq] at h; exact h
        have tau_b_sel : ∀ (k : Fin n),
            (extendPoint b_resp < a_init k ↔ extendPoint b_sp < resp_tau k) ∧
            (extendPoint b_resp = a_init k ↔ extendPoint b_sp = resp_tau k) := by
          intro k; have h := hord_tau ⟨n + 1, by omega⟩ ⟨1 + k.val, by omega⟩
          simp only [game_tuple_b_eq, game_tuple_sel_eq] at h; exact h
        -- Main split: delta + split_ifs + simp_all, then close remaining goals.
        -- NOTE: hab_n is NOT in context yet — simp_all cannot rewrite it.
        sorry
        -- NOTE: Round 9 analysis found the block-commented proof had a sorry
        -- fallback. The proof needs (x' < d ↔ x < c) for pivot_chain_order
        -- but this is not directly available from forward or tau games.
        -- A sigma-game instantiation or alternative approach is needed.
        -- G0: x' vs b_resp — pivot through d/c
        · exact pivot_chain_order props.hx'd hb_resp_in.1
            props.hxc (le_of_lt hc_lt_bsp) tau_d_b.1 tau_d_b.2
            (by rw [hab_n]; exact fwd_x_b.1) (by rw [hab_n]; exact fwd_x_b.2)
        -- G1: x' vs y' — from forward game
        · exact fwd_x_y
        -- G2: x' vs sel(j) — split on j-1<n
        · split_ifs with hjn
          · exact pivot_chain_order props.hx'd (h_no_split ⟨_, by omega⟩)
              props.hxc (hresp_tau_in ⟨_, hjn⟩).1
              (by rw [hab_n]; exact fwd_x_b.1) (by rw [hab_n]; exact fwd_x_b.2)
              (tau_d_sel ⟨_, hjn⟩).1 (tau_d_sel ⟨_, hjn⟩).2
          · rw [show a_bwd ⟨j.val - 1, _⟩ = a_bwd ⟨n, by omega⟩ from
              by congr 1; exact Fin.ext (by omega), hab_n]
            exact ⟨fwd_x_b.1.symm, fwd_x_b.2.symm⟩
        -- G3: b_resp vs x' — reverse of G0
        · exact pivot_chain_order_rev hb_resp_in.1 props.hx'd
            (le_of_lt hc_lt_bsp) props.hxc
            tau_d_b.1 tau_d_b.2
            (by rw [hab_n]; exact fwd_x_b.1) (by rw [hab_n]; exact fwd_x_b.2)
        -- G4: b_resp vs y' — from tau
        · exact tau_b_y'
        -- G5: b_resp vs sel(j)
        · split_ifs with hjn
          · exact tau_b_sel ⟨_, hjn⟩
          · rw [show a_bwd ⟨j.val - 1, _⟩ = a_bwd ⟨n, by omega⟩ from
              by congr 1; exact Fin.ext (by omega), hab_n]
            exact pivot_chain_order_rev hb_resp_in.1
              (by rw [hab_n] at hd_le_an ⊢; exact hd_le_an)
              (le_of_lt hc_lt_bsp) he_n_in.1
              tau_d_b.1 tau_d_b.2
              (by rw [hab_n]; exact fwd_x_b.1) (by rw [hab_n]; exact fwd_x_b.2)
        -- G6: y' vs x' — reverse of G1
        · exact ⟨fwd_x_y.1.symm, fwd_x_y.2.symm⟩
        -- G7: y' vs b_resp — reverse of G4
        · exact ⟨tau_b_y'.1.symm, tau_b_y'.2.symm⟩
        -- G8: y' vs sel(j)
        · split_ifs with hjn
          · exact pivot_chain_order_rev props.hdy' (h_no_split ⟨_, by omega⟩)
              props.hcy (hresp_tau_in ⟨_, hjn⟩).1
              tau_d_y'.1 tau_d_y'.2
              (tau_d_sel ⟨_, hjn⟩).1 (tau_d_sel ⟨_, hjn⟩).2
          · rw [show a_bwd ⟨j.val - 1, _⟩ = a_bwd ⟨n, by omega⟩ from
              by congr 1; exact Fin.ext (by omega), hab_n]
            exact ⟨fwd_b_y.1.symm, fwd_b_y.2.symm⟩
        -- G9: sel(i) vs x'
        · split_ifs with hin
          · exact pivot_chain_order_rev (h_no_split ⟨_, by omega⟩) props.hx'd
              (hresp_tau_in ⟨_, hin⟩).1 props.hxc
              (tau_d_sel ⟨_, hin⟩).1 (tau_d_sel ⟨_, hin⟩).2
              (by rw [hab_n]; exact fwd_x_b.1) (by rw [hab_n]; exact fwd_x_b.2)
          · rw [show a_bwd ⟨i.val - 1, _⟩ = a_bwd ⟨n, by omega⟩ from
              by congr 1; exact Fin.ext (by omega), hab_n]
            exact ⟨fwd_x_b.1, fwd_x_b.2⟩
        -- G10: sel(i) vs b_resp
        · split_ifs with hin
          · exact tau_sel_b ⟨_, hin⟩
          · rw [show a_bwd ⟨i.val - 1, _⟩ = a_bwd ⟨n, by omega⟩ from
              by congr 1; exact Fin.ext (by omega), hab_n]
            exact pivot_chain_order
              (by rw [hab_n] at hd_le_an ⊢; exact hd_le_an) hb_resp_in.1
              he_n_in.1 (le_of_lt hc_lt_bsp)
              (by rw [hab_n]; exact ⟨fun h => fwd_x_b.1.mp (lt_of_le_of_lt props.hx'd h),
                fun h => fwd_x_b.1.mpr (lt_of_le_of_lt props.hxc h)⟩)
              (by rw [hab_n]; exact ⟨fun h => (fwd_x_b.2.mp (le_antisymm props.hx'd
                (h ▸ hd_le_an))).trans h,
                fun h => (fwd_x_b.2.mpr (le_antisymm props.hxc (h ▸ he_n_in.1))).trans h⟩)
              tau_d_b.1 tau_d_b.2
        -- G11: sel(i) vs y'
        · split_ifs with hin
          · exact tau_sel_y ⟨_, hin⟩
          · rw [show a_bwd ⟨i.val - 1, _⟩ = a_bwd ⟨n, by omega⟩ from
              by congr 1; exact Fin.ext (by omega), hab_n]
            exact fwd_b_y
        -- G12: sel(i) vs sel(j)
        · split_ifs with hin hjn
          · exact tau_sel_sel ⟨_, hin⟩ ⟨_, hjn⟩
          · rw [show a_bwd ⟨j.val - 1, _⟩ = a_bwd ⟨n, by omega⟩ from
              by congr 1; exact Fin.ext (by omega), hab_n]
            exact pivot_chain_order ((ha_init ⟨_, hin⟩).1)
              (by rw [hab_n] at hd_le_an ⊢; exact hd_le_an)
              (hresp_tau_in ⟨_, hin⟩).1 he_n_in.1
              (tau_d_sel ⟨_, hin⟩).1 (tau_d_sel ⟨_, hin⟩).2
              (by rw [hab_n]; exact fwd_x_b.1) (by rw [hab_n]; exact fwd_x_b.2)
          · rw [show a_bwd ⟨i.val - 1, _⟩ = a_bwd ⟨n, by omega⟩ from
              by congr 1; exact Fin.ext (by omega), hab_n]
            exact pivot_chain_order_rev
              (by rw [hab_n] at hd_le_an ⊢; exact hd_le_an)
              ((ha_init ⟨_, hjn⟩).1)
              he_n_in.1 (hresp_tau_in ⟨_, hjn⟩).1
              (by rw [hab_n]; exact fwd_x_b.1) (by rw [hab_n]; exact fwd_x_b.2)
              (tau_d_sel ⟨_, hjn⟩).1 (tau_d_sel ⟨_, hjn⟩).2
          · rw [show a_bwd ⟨i.val - 1, _⟩ = a_bwd ⟨n, by omega⟩ from
              by congr 1; exact Fin.ext (by omega),
              show a_bwd ⟨j.val - 1, _⟩ = a_bwd ⟨n, by omega⟩ from
              by congr 1; exact Fin.ext (by omega)]
            exact ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
                   ⟨fun _ => rfl, fun _ => rfl⟩⟩
        -/
      · -- gap_point_agreement (n+1): for all positions
        intro i
        simp only [game_tuple]
        split_ifs with h0 hn1 hn2 h0' hlt
        · -- i=0: x'/x — from forward game at position 0
          have hfwd0 := hgp_fwd ⟨0, by omega⟩
          simp only [game_tuple, dite_true] at hfwd0
          exact ⟨hfwd0.1.symm, hfwd0.2.symm⟩
        · -- i=n+2: extendPoint b_resp / extendPoint b_sp
          -- Both are Sum.inl, hence both are points and neither is a gap
          constructor
          · exact ⟨fun _ => ⟨b_sp, rfl⟩, fun _ => ⟨b_resp, rfl⟩⟩
          · constructor <;> intro ⟨g, hg⟩ <;> cases hg
        · -- i=n+3: y'/y — from forward game at last position
          have hfwd_last := hgp_fwd ⟨n + 1 + 2, by omega⟩
          simp only [game_tuple, show (n + 1 + 2 : Nat) ≠ 0 from by omega,
                     show (n + 1 + 2 : Nat) ≠ n + 1 + 1 from by omega,
                     dite_false, dite_true] at hfwd_last
          exact ⟨hfwd_last.1.symm, hfwd_last.2.symm⟩
        · -- i inner, i-1 < n: a_bwd(i-1) / resp_tau(i-1) — from tau at position i
          have htau_i := hgp_tau ⟨i.val, by omega⟩
          simp only [game_tuple, show i.val ≠ 0 from h0,
                     show i.val ≠ n + 1 from by omega,
                     show i.val ≠ n + 2 from by omega,
                     dite_false] at htau_i
          convert htau_i using 2 <;> congr 1 <;> exact Fin.ext (by omega)
        · -- i inner, i-1=n: a_bwd(n)/e_n — both are Sum.inl (point)
          have hi_eq : i.val - 1 = n := by omega
          have hab : (a_bwd ⟨i.val - 1, by omega⟩ : ExtendedCarrier N atomMap r) =
                     a_bwd ⟨n, by omega⟩ := by congr 1; exact Fin.ext hi_eq
          rw [hab, hp_n]
          -- Now: (IsPoint (Sum.inl p_n) ↔ IsPoint e_n) ∧ (IsGap (Sum.inl p_n) ↔ IsGap e_n)
          -- Both sides are Sum.inl, so both are points and neither is a gap
          constructor
          · exact ⟨fun _ => ⟨e_n_pt, rfl⟩, fun _ => ⟨p_n, rfl⟩⟩
          · constructor <;> intro ⟨g, hg⟩ <;> exact (Sum.inl_ne_inr hg).elim
      · -- formula_agreement (n+1): for all positions and formulas
        intro i A hA
        simp only [game_tuple]
        split_ifs with h0 hn1 hn2 h0' hlt
        · -- i=0: x'/x — from forward game at position 0
          have hfwd0 := hform_fwd ⟨0, by omega⟩ A hA
          simp only [game_tuple, dite_true] at hfwd0
          exact hfwd0.symm
        · -- i=n+2: extendPoint b_resp / extendPoint b_sp — from tau at position n+1
          have htau_n1 := hform_tau ⟨n + 1, by omega⟩ A hA
          simp only [game_tuple, show (n + 1 : Nat) ≠ 0 from by omega,
                     show (n + 1 : Nat) = n + 1 from rfl,
                     dite_false, dite_true] at htau_n1
          exact htau_n1
        · -- i=n+3: y'/y — from forward game at last position
          have hfwd_last := hform_fwd ⟨n + 1 + 2, by omega⟩ A hA
          simp only [game_tuple, show (n + 1 + 2 : Nat) ≠ 0 from by omega,
                     show (n + 1 + 2 : Nat) ≠ n + 1 + 1 from by omega,
                     dite_false, dite_true] at hfwd_last
          exact hfwd_last.symm
        · -- i inner, i-1 < n: a_bwd(i-1) / resp_tau(i-1) — from tau at position i
          have htau_i := hform_tau ⟨i.val, by omega⟩ A hA
          simp only [game_tuple, show i.val ≠ 0 from h0,
                     show i.val ≠ n + 1 from by omega,
                     show i.val ≠ n + 2 from by omega,
                     dite_false] at htau_i
          convert htau_i using 2 <;> congr 1 <;> exact Fin.ext (by omega)
        · -- i inner, i-1=n: a_bwd(n)/e_n — from hform_en_an
          have hi_eq : i.val - 1 = n := by omega
          have hab : (a_bwd ⟨i.val - 1, by omega⟩ : ExtendedCarrier N atomMap r) =
                     a_bwd ⟨n, by omega⟩ := by congr 1; exact Fin.ext hi_eq
          rw [hab]
          exact (hform_en_an A hA).symm
  -- Step 4: Build merged response
  let a'_resp : Fin (n + 1) → ExtendedCarrier M atomMap r := fun i =>
    if h : i.val < n then resp_tau ⟨i.val, h⟩
    else e_n
  have ha'_resp_in : ∀ i, inClosedInterval x y (a'_resp i) := by
    intro i; simp only [a'_resp]
    split
    case isTrue h =>
      have := hresp_tau_in ⟨i.val, h⟩
      exact ⟨le_trans props.hxc this.1, this.2⟩
    case isFalse _ => exact he_n_in
  -- Step 5: Provide response with winning condition
  exact ⟨a'_resp, ha'_resp_in, fun b_sp hb_sp => he_n_props b_sp hb_sp⟩
  /-  OLD CASE II PROOF (used hd_eq_an, incompatible with d = infimum)
  have hd_eq_an : d = a_bwd ⟨n, by omega⟩ := props.hd_eq_an
  -- d is a point
  obtain ⟨p_d, hp_d⟩ := h_point
  -- So d = extendPoint p_d
  have hd_pt : d = extendPoint p_d := hd_eq_an ▸ hp_d
  -- ---------------------------------------------------------------
  -- Step 1: Build the init sub-sequence a_init : Fin n → ExtendedCarrier N
  -- ---------------------------------------------------------------
  let a_init : Fin n → ExtendedCarrier N atomMap r :=
    fun k => a_bwd ⟨k.val, by omega⟩
  have ha_init : ∀ k, inClosedInterval d y' (a_init k) := by
    intro k
    exact ⟨h_no_split ⟨k.val, by omega⟩, (ha_bwd ⟨k.val, by omega⟩).2⟩
  -- ---------------------------------------------------------------
  -- Step 2: Play τ with the init sub-sequence
  -- ---------------------------------------------------------------
  obtain ⟨resp_tau, hresp_tau_in, hwin_tau⟩ := props.tau a_init ha_init
  -- resp_tau : Fin n → ExtendedCarrier M atomMap r, all in [c, y]
  -- ---------------------------------------------------------------
  -- Step 3: Build the merged response a'_resp
  -- ---------------------------------------------------------------
  -- a'_resp(i) = resp_tau(i) for i < n
  -- a'_resp(n) = c
  let a'_resp : Fin (n + 1) → ExtendedCarrier M atomMap r := fun i =>
    if h : i.val < n then resp_tau ⟨i.val, h⟩
    else c
  have ha'_resp_in : ∀ i, inClosedInterval x y (a'_resp i) := by
    intro i; simp only [a'_resp]
    split
    case isTrue h =>
      have := hresp_tau_in ⟨i.val, h⟩
      exact ⟨le_trans props.hxc this.1, this.2⟩
    case isFalse _ =>
      exact props.hc_interval
  -- ---------------------------------------------------------------
  -- Step 4: Provide a'_resp and handle Round 2
  -- ---------------------------------------------------------------
  -- ---------------------------------------------------------------
  -- Pre-extract tau and sigma boundary data (needed for gap_point at j=n)
  -- ---------------------------------------------------------------
  obtain ⟨p_cy, hp_cy⟩ := props.h_pt_cy
  obtain ⟨b_resp_tau_aux, _, hcond_tau_aux⟩ := hwin_tau p_cy hp_cy
  obtain ⟨_, hgp_tau_aux, _⟩ := hcond_tau_aux
  -- Extract gap/point agreement at tau boundary (index 0 = d/c)
  have hgp_dc : (IsPoint d ↔ IsPoint c) ∧ (IsGap d ↔ IsGap c) := by
    have := hgp_tau_aux ⟨0, by omega⟩
    simp only [game_tuple, dite_true] at this; exact this
  -- Since d = extendPoint p_d, d is a point, so c is a point too
  have hc_point : IsPoint c := hgp_dc.1.mp ⟨p_d, hd_pt⟩
  have hc_not_gap : ¬IsGap c := by
    intro hgap_c
    have hgap_d : IsGap d := hgp_dc.2.mpr hgap_c
    obtain ⟨g', hg'⟩ := hgap_d
    -- d = Sum.inr g', but d = extendPoint p_d = Sum.inl p_d
    simp [hd_pt, extendPoint] at hg'
  -- Also pre-extract sigma data for x'/x boundary
  have hd_in_x'd : inClosedInterval x' d d := ⟨props.hx'd, le_refl d⟩
  obtain ⟨resp_sig_aux, _, hwin_sig_aux⟩ :=
    props.sigma (fun _ : Fin n => d) (fun _ => hd_in_x'd)
  obtain ⟨p_xc, hp_xc⟩ := props.h_pt_xc
  obtain ⟨_, _, hcond_sig_aux⟩ := hwin_sig_aux p_xc hp_xc
  obtain ⟨_, hgp_sig_aux, _⟩ := hcond_sig_aux
  refine ⟨a'_resp, ha'_resp_in, ?_⟩
  intro b_sp hb_sp
  by_cases hbc : extendPoint b_sp ≤ c
  · -- b_sp in [x, c]: delegate to σ's Round 2
    obtain ⟨resp_sig, _, hwin_sig⟩ :=
      props.sigma (fun _ : Fin n => d) (fun _ => hd_in_x'd)
    obtain ⟨b_resp_sig, hb_resp_sig_in, hcond_sig⟩ :=
      hwin_sig b_sp ⟨hb_sp.1, hbc⟩
    -- b_resp_sig is in [x',d] ⊂ [x',y']
    refine ⟨b_resp_sig, ⟨hb_resp_sig_in.1, le_trans hb_resp_sig_in.2 props.hdy'⟩, ?_⟩
    -- ---------------------------------------------------------------
    -- Winning condition transfer (b_sp ≤ c case)
    -- ---------------------------------------------------------------
    -- Re-extract tau's winning condition (with p_cy as Round 2 point)
    obtain ⟨_, _, hcond_tau⟩ := hwin_tau p_cy hp_cy
    obtain ⟨hord_tau, hgp_tau, hform_tau⟩ := hcond_tau
    obtain ⟨hord_sig, hgp_sig, hform_sig⟩ := hcond_sig
    -- Helper: tau maps index 0→d/c, 1+k→a_init(k)/resp_tau(k),
    --         n+1→p_cy/b_tau_resp(?), n+2→y'/y
    -- sigma maps index 0→x'/x, 1+k→d/resp_sig(k),
    --         n+1→b_sp/b_resp_sig, n+2→d/c
    -- Extract boundary orderings from tau
    have tau_d_y : (d < y' ↔ c < y) ∧ (d = y' ↔ c = y) := by
      have h := hord_tau ⟨0, by omega⟩ ⟨n + 2, by omega⟩
      simp only [game_tuple_zero_eq, game_tuple_y_eq] at h; exact h
    have tau_d_sel : ∀ (k : Fin n),
        (d < a_init k ↔ c < resp_tau k) ∧ (d = a_init k ↔ c = resp_tau k) := by
      intro k; have h := hord_tau ⟨0, by omega⟩ ⟨1 + k.val, by omega⟩
      simp only [game_tuple_zero_eq, game_tuple_sel_eq] at h; exact h
    have tau_sel_y : ∀ (k : Fin n),
        (a_init k < y' ↔ resp_tau k < y) ∧ (a_init k = y' ↔ resp_tau k = y) := by
      intro k; have h := hord_tau ⟨1 + k.val, by omega⟩ ⟨n + 2, by omega⟩
      simp only [game_tuple_sel_eq, game_tuple_y_eq] at h; exact h
    have tau_sel_sel : ∀ (k k' : Fin n),
        (a_init k < a_init k' ↔ resp_tau k < resp_tau k') ∧
        (a_init k = a_init k' ↔ resp_tau k = resp_tau k') := by
      intro k k'; have h := hord_tau ⟨1 + k.val, by omega⟩ ⟨1 + k'.val, by omega⟩
      simp only [game_tuple_sel_eq] at h; exact h
    -- Extract boundary orderings from sigma
    have sig_x_d : (x' < d ↔ x < c) ∧ (x' = d ↔ x = c) := by
      have h := hord_sig ⟨0, by omega⟩ ⟨n + 2, by omega⟩
      simp only [game_tuple_zero_eq, game_tuple_y_eq] at h; exact h
    have sig_x_b : (x' < extendPoint b_resp_sig ↔ x < extendPoint b_sp) ∧
                   (x' = extendPoint b_resp_sig ↔ x = extendPoint b_sp) := by
      have h := hord_sig ⟨0, by omega⟩ ⟨n + 1, by omega⟩
      simp only [game_tuple_zero_eq, game_tuple_b_eq] at h; exact h
    have sig_b_d : (extendPoint b_resp_sig < d ↔ extendPoint b_sp < c) ∧
                   (extendPoint b_resp_sig = d ↔ extendPoint b_sp = c) := by
      have h := hord_sig ⟨n + 1, by omega⟩ ⟨n + 2, by omega⟩
      simp only [game_tuple_b_eq, game_tuple_y_eq] at h; exact h
    -- Interval bounds
    have hd_le_init : ∀ (k : Fin n), d ≤ a_init k := fun k => (ha_init k).1
    have hc_le_tau : ∀ (k : Fin n), c ≤ resp_tau k := fun k => (hresp_tau_in k).1
    have hresp_tau_le_y : ∀ (k : Fin n), resp_tau k ≤ y := fun k => (hresp_tau_in k).2
    -- gap_point at selections
    have hgp_sel : ∀ (j : Fin (n + 1)),
        (IsPoint (a_bwd j) ↔ IsPoint (a'_resp j)) ∧
        (IsGap (a_bwd j) ↔ IsGap (a'_resp j)) := by
      intro j
      by_cases hjn : j.val < n
      · -- j < n: from tau at selection index 1 + j.val
        simp only [a'_resp, hjn, dite_true]
        have htau_gp := hgp_tau ⟨1 + j.val, by omega⟩
        simp only [game_tuple,
          show (1 + j.val : Nat) ≠ 0 from by omega,
          show ¬((1 + j.val : Nat) = n + 1) from by omega,
          show ¬((1 + j.val : Nat) = n + 2) from by omega,
          dite_false, show 1 + j.val - 1 = j.val from by omega] at htau_gp
        -- N-side: a_init ⟨j.val, hjn⟩ = a_bwd j
        have hN_eq : a_init ⟨j.val, hjn⟩ = a_bwd j := by
          simp [a_init]
        rw [hN_eq] at htau_gp; exact htau_gp
      · -- j = n: d/c, gap/point from tau boundary
        simp only [a'_resp, show ¬(j.val < n) from hjn, dite_false]
        rw [show a_bwd j = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
        rw [← hd_eq_an, hd_pt]
        constructor
        · exact ⟨fun _ => hc_point, fun _ => ⟨p_d, rfl⟩⟩
        · exact ⟨fun ⟨g, hg⟩ => absurd hg.symm Sum.inr_ne_inl,
                 fun h => absurd h hc_not_gap⟩
    -- formula at selections
    have hform_sel : ∀ (j : Fin (n + 1)) (A : StaviFormula), stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r (a_bwd j) A ↔
         stavi_temporal_truth_mu M atomMap r (a'_resp j) A) := by
      intro j A hA
      by_cases hjn : j.val < n
      · simp only [a'_resp, hjn, dite_true]
        have htau_form := hform_tau ⟨1 + j.val, by omega⟩ A hA
        simp only [game_tuple,
          show (1 + j.val : Nat) ≠ 0 from by omega,
          show ¬((1 + j.val : Nat) = n + 1) from by omega,
          show ¬((1 + j.val : Nat) = n + 2) from by omega,
          dite_false, show 1 + j.val - 1 = j.val from by omega] at htau_form
        have hN_eq : a_init ⟨j.val, hjn⟩ = a_bwd j := by
          simp [a_init]
        rw [hN_eq] at htau_form; exact htau_form
      · -- j = n: formula agreement between d and c from tau boundary
        simp only [a'_resp, show ¬(j.val < n) from hjn, dite_false]
        rw [show a_bwd j = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
        rw [← hd_eq_an]
        -- From tau: index 0 maps d/c
        have htau_form_d := hform_tau ⟨0, by omega⟩ A hA
        simp only [game_tuple, dite_true] at htau_form_d
        exact htau_form_d
    -- Boundary gap/point and formula
    have hgp_x : (IsPoint x' ↔ IsPoint x) ∧ (IsGap x' ↔ IsGap x) := by
      -- From sigma at index 0
      have := hgp_sig ⟨0, by omega⟩
      simp only [game_tuple, show (0 : Nat) ≠ n + 1 from by omega,
        show (0 : Nat) ≠ n + 2 from by omega, dite_true] at this
      exact this
    have hgp_y : (IsPoint y' ↔ IsPoint y) ∧ (IsGap y' ↔ IsGap y) := by
      have := hgp_tau ⟨n + 2, by omega⟩
      simp only [game_tuple, show (n + 2 : Nat) ≠ 0 from by omega,
        show ¬((n + 2 : Nat) = n + 1) from by omega,
        show (n + 2 : Nat) = n + 2 from rfl, dite_true, dite_false] at this
      exact this
    have hgp_b : (@IsPoint sig N atomMap r (extendPoint b_resp_sig) ↔
                  @IsPoint sig M atomMap r (extendPoint b_sp)) ∧
                 (@IsGap sig N atomMap r (extendPoint b_resp_sig) ↔
                  @IsGap sig M atomMap r (extendPoint b_sp)) := by
      constructor
      · exact ⟨fun _ => ⟨b_sp, rfl⟩, fun _ => ⟨b_resp_sig, rfl⟩⟩
      · exact ⟨fun ⟨g, hg⟩ => absurd hg.symm Sum.inr_ne_inl,
               fun ⟨g, hg⟩ => absurd hg.symm Sum.inr_ne_inl⟩
    have hform_x : ∀ A, stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r x' A ↔ stavi_temporal_truth_mu M atomMap r x A) := by
      intro A hA
      have := hform_sig ⟨0, by omega⟩ A hA
      simp only [game_tuple, show (0 : Nat) ≠ n + 1 from by omega,
        show (0 : Nat) ≠ n + 2 from by omega, dite_true] at this
      exact this
    have hform_y : ∀ A, stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r y' A ↔ stavi_temporal_truth_mu M atomMap r y A) := by
      intro A hA
      have := hform_tau ⟨n + 2, by omega⟩ A hA
      simp only [game_tuple, show (n + 2 : Nat) ≠ 0 from by omega,
        show ¬((n + 2 : Nat) = n + 1) from by omega,
        show (n + 2 : Nat) = n + 2 from rfl, dite_true, dite_false] at this
      exact this
    have hform_b : ∀ A, stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r (extendPoint b_resp_sig) A ↔
         stavi_temporal_truth_mu M atomMap r (extendPoint b_sp) A) := by
      intro A hA
      have := hform_sig ⟨n + 1, by omega⟩ A hA
      simp only [game_tuple, show (n + 1 : Nat) ≠ 0 from by omega,
        show (n + 1 : Nat) = n + 1 from rfl, dite_true] at this
      exact this
    -- ----- Assemble the winning condition -----
    refine ⟨?_, ?_, ?_⟩
    · -- same_order_type (n+1)
      -- Full game has n+4 indices: 0→x'/x, 1..n→a_bwd(0..n-1)/a'_resp(0..n-1),
      --   n+1→a_bwd(n)/a'_resp(n)=d/c, n+2→b_resp_sig/b_sp, n+3→y'/y
      -- tau maps: 0→d/c, 1+k→a_init(k)/resp_tau(k), n+1→p_cy/?, n+2→y'/y
      -- sigma maps: 0→x'/x, 1+k→d/resp_sig(k), n+1→b_sp/b_resp_sig, n+2→d/c
      -- For cross-boundary ordering, use pivot through d/c
      intro i j; simp only [game_tuple]; split_ifs with
        hi0 hj0 _ _ _ hjb _ hjy _ hjd _ _ hib hj0 _ _ _ hjb _ hjy _ hjd _ _
        hiy hj0 _ _ _ hjb _ hjy _ hjd _ _ _ hid hj0 _ _ _ hjb _ hjy _ hjd _ _
      -- Goal 1: x vs x
      · exact ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
               ⟨fun _ => rfl, fun _ => rfl⟩⟩
      -- Goal 2: x vs b
      · exact sig_x_b
      -- Goal 3: x vs y
      · exact pivot_chain_order props.hx'd props.hdy' props.hxc props.hcy
          sig_x_d.1 sig_x_d.2 tau_d_y.1 tau_d_y.2
      -- Goal 4: x vs sel(j)
      · set j' : Fin (n + 1) := ⟨j.val - 1, by omega⟩
        by_cases hjn : j'.val < n
        · -- j' < n: tau selection
          simp only [a'_resp, hjn, dite_true]
          have : a_bwd j' = a_init ⟨j'.val, hjn⟩ := by
            simp [a_init]
          rw [this]
          exact pivot_chain_order props.hx'd (hd_le_init ⟨j'.val, hjn⟩)
            props.hxc (hc_le_tau ⟨j'.val, hjn⟩) sig_x_d.1 sig_x_d.2
            (tau_d_sel ⟨j'.val, hjn⟩).1 (tau_d_sel ⟨j'.val, hjn⟩).2
        · -- j' = n: a_bwd(n) = d, a'_resp(n) = c
          simp only [a'_resp, show ¬(j'.val < n) from hjn, dite_false]
          rw [show a_bwd j' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
          rw [← hd_eq_an]
          exact sig_x_d
      -- Goal 5: b vs x
      · have h := hord_sig ⟨n + 1, by omega⟩ ⟨0, by omega⟩
        simp only [game_tuple_b_eq, game_tuple_zero_eq] at h; exact h
      -- Goal 6: b vs b
      · exact ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
               ⟨fun _ => rfl, fun _ => rfl⟩⟩
      -- Goal 7: b vs y
      · exact pivot_chain_order hb_resp_sig_in.2 props.hdy' hbc props.hcy
          sig_b_d.1 sig_b_d.2 tau_d_y.1 tau_d_y.2
      -- Goal 8: b vs sel(j)
      · set j' : Fin (n + 1) := ⟨j.val - 1, by omega⟩
        by_cases hjn : j'.val < n
        · simp only [a'_resp, hjn, dite_true]
          have : a_bwd j' = a_init ⟨j'.val, hjn⟩ := by
            simp [a_init]
          rw [this]
          exact pivot_chain_order hb_resp_sig_in.2 (hd_le_init ⟨j'.val, hjn⟩)
            hbc (hc_le_tau ⟨j'.val, hjn⟩)
            sig_b_d.1 sig_b_d.2 (tau_d_sel ⟨j'.val, hjn⟩).1 (tau_d_sel ⟨j'.val, hjn⟩).2
        · simp only [a'_resp, show ¬(j'.val < n) from hjn, dite_false]
          rw [show a_bwd j' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
          rw [← hd_eq_an]
          exact sig_b_d
      -- Goal 9: y vs x
      · exact pivot_chain_order_rev props.hdy' props.hx'd props.hcy props.hxc
          tau_d_y.1 tau_d_y.2 sig_x_d.1 sig_x_d.2
      -- Goal 10: y vs b
      · exact pivot_chain_order_rev props.hdy' hb_resp_sig_in.2 props.hcy hbc
          tau_d_y.1 tau_d_y.2 sig_b_d.1 sig_b_d.2
      -- Goal 11: y vs y
      · exact ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
               ⟨fun _ => rfl, fun _ => rfl⟩⟩
      -- Goal 12: y vs sel(j) — y' ≥ sel ≥ d and y ≥ resp ≥ c
      · set j' : Fin (n + 1) := ⟨j.val - 1, by omega⟩
        by_cases hjn : j'.val < n
        · simp only [a'_resp, hjn, dite_true]
          have : a_bwd j' = a_init ⟨j'.val, hjn⟩ := by
            simp [a_init]
          rw [this]
          have htsy := tau_sel_y ⟨j'.val, hjn⟩
          exact ⟨⟨fun h => absurd h (not_lt.mpr (ha_init ⟨j'.val, hjn⟩).2),
                  fun h => absurd h (not_lt.mpr (hresp_tau_in ⟨j'.val, hjn⟩).2)⟩,
                 ⟨fun h => (htsy.2.mp h.symm).symm,
                  fun h => (htsy.2.mpr h.symm).symm⟩⟩
        · -- j' = n: y' vs d / y vs c
          simp only [a'_resp, show ¬(j'.val < n) from hjn, dite_false]
          rw [show a_bwd j' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
          rw [← hd_eq_an]
          exact ⟨⟨fun h => absurd h (not_lt.mpr props.hdy'),
                  fun h => absurd h (not_lt.mpr props.hcy)⟩,
                 ⟨fun h => (tau_d_y.2.mp h.symm).symm,
                  fun h => (tau_d_y.2.mpr h.symm).symm⟩⟩
      -- Goal 13: sel(i) vs x
      · set i' : Fin (n + 1) := ⟨i.val - 1, by omega⟩
        by_cases hin : i'.val < n
        · simp only [a'_resp, hin, dite_true]
          have : a_bwd i' = a_init ⟨i'.val, hin⟩ := by
            simp [a_init]
          rw [this]
          exact pivot_chain_order_rev (hd_le_init ⟨i'.val, hin⟩) props.hx'd
            (hc_le_tau ⟨i'.val, hin⟩) props.hxc
            (tau_d_sel ⟨i'.val, hin⟩).1 (tau_d_sel ⟨i'.val, hin⟩).2
            sig_x_d.1 sig_x_d.2
        · simp only [a'_resp, show ¬(i'.val < n) from hin, dite_false]
          rw [show a_bwd i' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
          rw [← hd_eq_an]
          have h := hord_sig ⟨n + 2, by omega⟩ ⟨0, by omega⟩
          simp only [game_tuple_y_eq, game_tuple_zero_eq] at h; exact h
      -- Goal 14: sel(i) vs b
      · set i' : Fin (n + 1) := ⟨i.val - 1, by omega⟩
        by_cases hin : i'.val < n
        · simp only [a'_resp, hin, dite_true]
          have : a_bwd i' = a_init ⟨i'.val, hin⟩ := by
            simp [a_init]
          rw [this]
          exact pivot_chain_order_rev (hd_le_init ⟨i'.val, hin⟩) hb_resp_sig_in.2
            (hc_le_tau ⟨i'.val, hin⟩) hbc
            (tau_d_sel ⟨i'.val, hin⟩).1 (tau_d_sel ⟨i'.val, hin⟩).2
            sig_b_d.1 sig_b_d.2
        · simp only [a'_resp, show ¬(i'.val < n) from hin, dite_false]
          rw [show a_bwd i' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
          rw [← hd_eq_an]
          have h := hord_sig ⟨n + 2, by omega⟩ ⟨n + 1, by omega⟩
          simp only [game_tuple_y_eq, game_tuple_b_eq] at h; exact h
      -- Goal 15: sel(i) vs y
      · set i' : Fin (n + 1) := ⟨i.val - 1, by omega⟩
        by_cases hin : i'.val < n
        · simp only [a'_resp, hin, dite_true]
          have : a_bwd i' = a_init ⟨i'.val, hin⟩ := by
            simp [a_init]
          rw [this]; exact tau_sel_y ⟨i'.val, hin⟩
        · simp only [a'_resp, show ¬(i'.val < n) from hin, dite_false]
          rw [show a_bwd i' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
          rw [← hd_eq_an]; exact tau_d_y
      -- Goal 16: sel(i) vs sel(j)
      · set i' : Fin (n + 1) := ⟨i.val - 1, by omega⟩
        set j' : Fin (n + 1) := ⟨j.val - 1, by omega⟩
        by_cases hin : i'.val < n
        · simp only [a'_resp, hin, dite_true]
          have hi_eq : a_bwd i' = a_init ⟨i'.val, hin⟩ := by
            simp [a_init]
          rw [hi_eq]
          by_cases hjn : j'.val < n
          · simp only [a'_resp, hjn, dite_true]
            have hj_eq : a_bwd j' = a_init ⟨j'.val, hjn⟩ := by
              simp [a_init]
            rw [hj_eq]; exact tau_sel_sel ⟨i'.val, hin⟩ ⟨j'.val, hjn⟩
          · -- j' = n: sel(i') vs d / resp_tau(i') vs c
            simp only [a'_resp, show ¬(j'.val < n) from hjn, dite_false]
            rw [show a_bwd j' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
            rw [← hd_eq_an]
            -- a_init(i') ≥ d and resp_tau(i') ≥ c, so < is impossible
            -- = follows from tau_d_sel reversed
            have hds := tau_d_sel ⟨i'.val, hin⟩
            exact ⟨⟨fun h => absurd h (not_lt.mpr (hd_le_init ⟨i'.val, hin⟩)),
                    fun h => absurd h (not_lt.mpr (hc_le_tau ⟨i'.val, hin⟩))⟩,
                   ⟨fun h => (hds.2.mp h.symm).symm,
                    fun h => (hds.2.mpr h.symm).symm⟩⟩
        · -- i' = n: d vs ... / c vs ...
          simp only [a'_resp, show ¬(i'.val < n) from hin, dite_false]
          rw [show a_bwd i' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
          rw [← hd_eq_an]
          by_cases hjn : j'.val < n
          · simp only [a'_resp, hjn, dite_true]
            have hj_eq : a_bwd j' = a_init ⟨j'.val, hjn⟩ := by
              simp [a_init]
            rw [hj_eq]; exact tau_d_sel ⟨j'.val, hjn⟩
          · -- i' = n, j' = n: d vs d / c vs c
            simp only [a'_resp, show ¬(j'.val < n) from hjn, dite_false]
            rw [show a_bwd j' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
            rw [← hd_eq_an]
            simp
    · -- gap_point_agreement (n+1)
      exact gap_point_agreement_of_cases hgp_x hgp_b hgp_y hgp_sel
    · -- formula_agreement (n+1)
      exact formula_agreement_of_cases hform_x hform_b hform_y hform_sel
  · -- b_sp in (c, y]: delegate to τ's Round 2
    push_neg at hbc
    obtain ⟨b_resp_tau, hb_resp_tau_in, hcond_tau⟩ := hwin_tau b_sp ⟨le_of_lt hbc, hb_sp.2⟩
    refine ⟨b_resp_tau, ⟨le_trans props.hx'd hb_resp_tau_in.1, hb_resp_tau_in.2⟩, ?_⟩
    -- ---------------------------------------------------------------
    -- Winning condition transfer (b_sp > c case)
    -- ---------------------------------------------------------------
    obtain ⟨hord_tau, hgp_tau, hform_tau⟩ := hcond_tau
    -- Also get sigma's data for x'/x boundary
    have hd_in_x'd : inClosedInterval x' d d := ⟨props.hx'd, le_refl d⟩
    obtain ⟨resp_sig, _, hwin_sig⟩ :=
      props.sigma (fun _ : Fin n => d) (fun _ => hd_in_x'd)
    obtain ⟨p_xc, hp_xc⟩ := props.h_pt_xc
    obtain ⟨_, _, hcond_sig⟩ := hwin_sig p_xc hp_xc
    obtain ⟨hord_sig, hgp_sig, hform_sig⟩ := hcond_sig
    -- Extract orderings from tau
    have tau_d_y : (d < y' ↔ c < y) ∧ (d = y' ↔ c = y) := by
      have h := hord_tau ⟨0, by omega⟩ ⟨n + 2, by omega⟩
      simp only [game_tuple_zero_eq, game_tuple_y_eq] at h; exact h
    have tau_d_sel : ∀ (k : Fin n),
        (d < a_init k ↔ c < resp_tau k) ∧ (d = a_init k ↔ c = resp_tau k) := by
      intro k; have h := hord_tau ⟨0, by omega⟩ ⟨1 + k.val, by omega⟩
      simp only [game_tuple_zero_eq, game_tuple_sel_eq] at h; exact h
    have tau_sel_y : ∀ (k : Fin n),
        (a_init k < y' ↔ resp_tau k < y) ∧ (a_init k = y' ↔ resp_tau k = y) := by
      intro k; have h := hord_tau ⟨1 + k.val, by omega⟩ ⟨n + 2, by omega⟩
      simp only [game_tuple_sel_eq, game_tuple_y_eq] at h; exact h
    have tau_sel_sel : ∀ (k k' : Fin n),
        (a_init k < a_init k' ↔ resp_tau k < resp_tau k') ∧
        (a_init k = a_init k' ↔ resp_tau k = resp_tau k') := by
      intro k k'; have h := hord_tau ⟨1 + k.val, by omega⟩ ⟨1 + k'.val, by omega⟩
      simp only [game_tuple_sel_eq] at h; exact h
    have tau_d_b : (d < extendPoint b_resp_tau ↔ c < extendPoint b_sp) ∧
                   (d = extendPoint b_resp_tau ↔ c = extendPoint b_sp) := by
      have h := hord_tau ⟨0, by omega⟩ ⟨n + 1, by omega⟩
      simp only [game_tuple_zero_eq, game_tuple_b_eq] at h; exact h
    have tau_b_y : (extendPoint b_resp_tau < y' ↔ extendPoint b_sp < y) ∧
                   (extendPoint b_resp_tau = y' ↔ extendPoint b_sp = y) := by
      have h := hord_tau ⟨n + 1, by omega⟩ ⟨n + 2, by omega⟩
      simp only [game_tuple_b_eq, game_tuple_y_eq] at h; exact h
    have tau_b_sel : ∀ (k : Fin n),
        (extendPoint b_resp_tau < a_init k ↔ extendPoint b_sp < resp_tau k) ∧
        (extendPoint b_resp_tau = a_init k ↔ extendPoint b_sp = resp_tau k) := by
      intro k; have h := hord_tau ⟨n + 1, by omega⟩ ⟨1 + k.val, by omega⟩
      simp only [game_tuple_b_eq, game_tuple_sel_eq] at h; exact h
    have tau_sel_b : ∀ (k : Fin n),
        (a_init k < extendPoint b_resp_tau ↔ resp_tau k < extendPoint b_sp) ∧
        (a_init k = extendPoint b_resp_tau ↔ resp_tau k = extendPoint b_sp) := by
      intro k; have h := hord_tau ⟨1 + k.val, by omega⟩ ⟨n + 1, by omega⟩
      simp only [game_tuple_sel_eq, game_tuple_b_eq] at h; exact h
    -- Extract sigma orderings for x boundary
    have sig_x_d : (x' < d ↔ x < c) ∧ (x' = d ↔ x = c) := by
      have h := hord_sig ⟨0, by omega⟩ ⟨n + 2, by omega⟩
      simp only [game_tuple_zero_eq, game_tuple_y_eq] at h; exact h
    -- Interval bounds
    have hd_le_init : ∀ (k : Fin n), d ≤ a_init k := fun k => (ha_init k).1
    have hc_le_tau : ∀ (k : Fin n), c ≤ resp_tau k := fun k => (hresp_tau_in k).1
    -- gap_point at selections
    have hgp_sel : ∀ (j : Fin (n + 1)),
        (IsPoint (a_bwd j) ↔ IsPoint (a'_resp j)) ∧
        (IsGap (a_bwd j) ↔ IsGap (a'_resp j)) := by
      intro j
      by_cases hjn : j.val < n
      · simp only [a'_resp, hjn, dite_true]
        have htau_gp := hgp_tau ⟨1 + j.val, by omega⟩
        simp only [game_tuple,
          show (1 + j.val : Nat) ≠ 0 from by omega,
          show ¬((1 + j.val : Nat) = n + 1) from by omega,
          show ¬((1 + j.val : Nat) = n + 2) from by omega,
          dite_false, show 1 + j.val - 1 = j.val from by omega] at htau_gp
        have hN_eq : a_init ⟨j.val, hjn⟩ = a_bwd j := by
          simp [a_init]
        rw [hN_eq] at htau_gp; exact htau_gp
      · simp only [a'_resp, show ¬(j.val < n) from hjn, dite_false]
        rw [show a_bwd j = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
        rw [← hd_eq_an, hd_pt]
        constructor
        · exact ⟨fun _ => hc_point, fun _ => ⟨p_d, rfl⟩⟩
        · exact ⟨fun ⟨g, hg⟩ => absurd hg.symm Sum.inr_ne_inl,
                 fun h => absurd h hc_not_gap⟩
    have hform_sel : ∀ (j : Fin (n + 1)) (A : StaviFormula), stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r (a_bwd j) A ↔
         stavi_temporal_truth_mu M atomMap r (a'_resp j) A) := by
      intro j A hA
      by_cases hjn : j.val < n
      · simp only [a'_resp, hjn, dite_true]
        have htau_form := hform_tau ⟨1 + j.val, by omega⟩ A hA
        simp only [game_tuple,
          show (1 + j.val : Nat) ≠ 0 from by omega,
          show ¬((1 + j.val : Nat) = n + 1) from by omega,
          show ¬((1 + j.val : Nat) = n + 2) from by omega,
          dite_false, show 1 + j.val - 1 = j.val from by omega] at htau_form
        have hN_eq : a_init ⟨j.val, hjn⟩ = a_bwd j := by
          simp [a_init]
        rw [hN_eq] at htau_form; exact htau_form
      · simp only [a'_resp, show ¬(j.val < n) from hjn, dite_false]
        rw [show a_bwd j = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
        rw [← hd_eq_an]
        have htau_form_d := hform_tau ⟨0, by omega⟩ A hA
        simp only [game_tuple, dite_true] at htau_form_d
        exact htau_form_d
    -- Boundary data
    have hgp_x : (IsPoint x' ↔ IsPoint x) ∧ (IsGap x' ↔ IsGap x) := by
      have := hgp_sig ⟨0, by omega⟩
      simp only [game_tuple, show (0 : Nat) ≠ n + 1 from by omega,
        show (0 : Nat) ≠ n + 2 from by omega, dite_true] at this
      exact this
    have hgp_y : (IsPoint y' ↔ IsPoint y) ∧ (IsGap y' ↔ IsGap y) := by
      have := hgp_tau ⟨n + 2, by omega⟩
      simp only [game_tuple, show (n + 2 : Nat) ≠ 0 from by omega,
        show ¬((n + 2 : Nat) = n + 1) from by omega,
        show (n + 2 : Nat) = n + 2 from rfl, dite_true, dite_false] at this
      exact this
    have hgp_b : (@IsPoint sig N atomMap r (extendPoint b_resp_tau) ↔
                  @IsPoint sig M atomMap r (extendPoint b_sp)) ∧
                 (@IsGap sig N atomMap r (extendPoint b_resp_tau) ↔
                  @IsGap sig M atomMap r (extendPoint b_sp)) := by
      constructor
      · exact ⟨fun _ => ⟨b_sp, rfl⟩, fun _ => ⟨b_resp_tau, rfl⟩⟩
      · exact ⟨fun ⟨g, hg⟩ => absurd hg.symm Sum.inr_ne_inl,
               fun ⟨g, hg⟩ => absurd hg.symm Sum.inr_ne_inl⟩
    have hform_x : ∀ A, stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r x' A ↔ stavi_temporal_truth_mu M atomMap r x A) := by
      intro A hA
      have := hform_sig ⟨0, by omega⟩ A hA
      simp only [game_tuple, show (0 : Nat) ≠ n + 1 from by omega,
        show (0 : Nat) ≠ n + 2 from by omega, dite_true] at this
      exact this
    have hform_y : ∀ A, stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r y' A ↔ stavi_temporal_truth_mu M atomMap r y A) := by
      intro A hA
      have := hform_tau ⟨n + 2, by omega⟩ A hA
      simp only [game_tuple, show (n + 2 : Nat) ≠ 0 from by omega,
        show ¬((n + 2 : Nat) = n + 1) from by omega,
        show (n + 2 : Nat) = n + 2 from rfl, dite_true, dite_false] at this
      exact this
    have hform_b : ∀ A, stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r (extendPoint b_resp_tau) A ↔
         stavi_temporal_truth_mu M atomMap r (extendPoint b_sp) A) := by
      intro A hA
      have := hform_tau ⟨n + 1, by omega⟩ A hA
      simp only [game_tuple, show (n + 1 : Nat) ≠ 0 from by omega,
        show (n + 1 : Nat) = n + 1 from rfl, dite_true] at this
      exact this
    -- ----- Assemble the winning condition (right case) -----
    refine ⟨?_, ?_, ?_⟩
    · -- same_order_type (n+1)
      intro i j; simp only [game_tuple]; split_ifs with
        hi0 hj0 _ _ _ hjb _ hjy _ hjd _ _ hib hj0 _ _ _ hjb _ hjy _ hjd _ _
        hiy hj0 _ _ _ hjb _ hjy _ hjd _ _ _ hid hj0 _ _ _ hjb _ hjy _ hjd _ _
      -- Goal 1: x vs x
      · exact ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
               ⟨fun _ => rfl, fun _ => rfl⟩⟩
      -- Goal 2: x vs b
      · exact pivot_chain_order props.hx'd hb_resp_tau_in.1 props.hxc (le_of_lt hbc)
          sig_x_d.1 sig_x_d.2 tau_d_b.1 tau_d_b.2
      -- Goal 3: x vs y
      · exact pivot_chain_order props.hx'd props.hdy' props.hxc props.hcy
          sig_x_d.1 sig_x_d.2 tau_d_y.1 tau_d_y.2
      -- Goal 4: x vs sel(j)
      · set j' : Fin (n + 1) := ⟨j.val - 1, by omega⟩
        by_cases hjn : j'.val < n
        · simp only [a'_resp, hjn, dite_true]
          have : a_bwd j' = a_init ⟨j'.val, hjn⟩ := by
            simp [a_init]
          rw [this]
          exact pivot_chain_order props.hx'd (hd_le_init ⟨j'.val, hjn⟩)
            props.hxc (hc_le_tau ⟨j'.val, hjn⟩) sig_x_d.1 sig_x_d.2
            (tau_d_sel ⟨j'.val, hjn⟩).1 (tau_d_sel ⟨j'.val, hjn⟩).2
        · simp only [a'_resp, show ¬(j'.val < n) from hjn, dite_false]
          rw [show a_bwd j' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
          rw [← hd_eq_an]
          exact sig_x_d
      -- Goal 5: b vs x
      · exact pivot_chain_order_rev hb_resp_tau_in.1 props.hx'd (le_of_lt hbc) props.hxc
          tau_d_b.1 tau_d_b.2 sig_x_d.1 sig_x_d.2
      -- Goal 6: b vs b
      · exact ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
               ⟨fun _ => rfl, fun _ => rfl⟩⟩
      -- Goal 7: b vs y
      · exact tau_b_y
      -- Goal 8: b vs sel(j)
      · set j' : Fin (n + 1) := ⟨j.val - 1, by omega⟩
        by_cases hjn : j'.val < n
        · simp only [a'_resp, hjn, dite_true]
          have : a_bwd j' = a_init ⟨j'.val, hjn⟩ := by
            simp [a_init]
          rw [this]; exact tau_b_sel ⟨j'.val, hjn⟩
        · -- j' = n: b vs d / b_sp vs c — b ≥ d and b_sp > c
          simp only [a'_resp, show ¬(j'.val < n) from hjn, dite_false]
          rw [show a_bwd j' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
          rw [← hd_eq_an]
          exact ⟨⟨fun h => absurd h (not_lt.mpr hb_resp_tau_in.1),
                  fun h => absurd h (not_lt.mpr (le_of_lt hbc))⟩,
                 ⟨fun h => (tau_d_b.2.mp h.symm).symm,
                  fun h => (tau_d_b.2.mpr h.symm).symm⟩⟩
      -- Goal 9: y vs x
      · exact pivot_chain_order_rev props.hdy' props.hx'd props.hcy props.hxc
          tau_d_y.1 tau_d_y.2 sig_x_d.1 sig_x_d.2
      -- Goal 10: y vs b
      · have h := hord_tau ⟨n + 2, by omega⟩ ⟨n + 1, by omega⟩
        simp only [game_tuple_y_eq, game_tuple_b_eq] at h; exact h
      -- Goal 11: y vs y
      · exact ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
               ⟨fun _ => rfl, fun _ => rfl⟩⟩
      -- Goal 12: y vs sel(j)
      · set j' : Fin (n + 1) := ⟨j.val - 1, by omega⟩
        by_cases hjn : j'.val < n
        · simp only [a'_resp, hjn, dite_true]
          have : a_bwd j' = a_init ⟨j'.val, hjn⟩ := by
            simp [a_init]
          rw [this]
          have := tau_sel_y ⟨j'.val, hjn⟩
          exact ⟨⟨fun h => absurd h (not_lt.mpr (ha_init ⟨j'.val, hjn⟩).2),
                  fun h => absurd h (not_lt.mpr (hresp_tau_in ⟨j'.val, hjn⟩).2)⟩,
                 ⟨fun h => (this.2.mp h.symm).symm,
                  fun h => (this.2.mpr h.symm).symm⟩⟩
        · simp only [a'_resp, show ¬(j'.val < n) from hjn, dite_false]
          rw [show a_bwd j' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
          rw [← hd_eq_an]
          exact ⟨⟨fun h => absurd h (not_lt.mpr props.hdy'),
                  fun h => absurd h (not_lt.mpr props.hcy)⟩,
                 ⟨fun h => (tau_d_y.2.mp h.symm).symm,
                  fun h => (tau_d_y.2.mpr h.symm).symm⟩⟩
      -- Goal 13: sel(i) vs x
      · set i' : Fin (n + 1) := ⟨i.val - 1, by omega⟩
        by_cases hin : i'.val < n
        · simp only [a'_resp, hin, dite_true]
          have : a_bwd i' = a_init ⟨i'.val, hin⟩ := by
            simp [a_init]
          rw [this]
          exact pivot_chain_order_rev (hd_le_init ⟨i'.val, hin⟩) props.hx'd
            (hc_le_tau ⟨i'.val, hin⟩) props.hxc
            (tau_d_sel ⟨i'.val, hin⟩).1 (tau_d_sel ⟨i'.val, hin⟩).2
            sig_x_d.1 sig_x_d.2
        · simp only [a'_resp, show ¬(i'.val < n) from hin, dite_false]
          rw [show a_bwd i' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
          rw [← hd_eq_an]
          have h := hord_sig ⟨n + 2, by omega⟩ ⟨0, by omega⟩
          simp only [game_tuple_y_eq, game_tuple_zero_eq] at h; exact h
      -- Goal 14: sel(i) vs b
      · set i' : Fin (n + 1) := ⟨i.val - 1, by omega⟩
        by_cases hin : i'.val < n
        · simp only [a'_resp, hin, dite_true]
          have : a_bwd i' = a_init ⟨i'.val, hin⟩ := by
            simp [a_init]
          rw [this]; exact tau_sel_b ⟨i'.val, hin⟩
        · simp only [a'_resp, show ¬(i'.val < n) from hin, dite_false]
          rw [show a_bwd i' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
          rw [← hd_eq_an]
          have h := hord_tau ⟨0, by omega⟩ ⟨n + 1, by omega⟩
          simp only [game_tuple_zero_eq, game_tuple_b_eq] at h; exact h
      -- Goal 15: sel(i) vs y
      · set i' : Fin (n + 1) := ⟨i.val - 1, by omega⟩
        by_cases hin : i'.val < n
        · simp only [a'_resp, hin, dite_true]
          have : a_bwd i' = a_init ⟨i'.val, hin⟩ := by
            simp [a_init]
          rw [this]; exact tau_sel_y ⟨i'.val, hin⟩
        · simp only [a'_resp, show ¬(i'.val < n) from hin, dite_false]
          rw [show a_bwd i' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
          rw [← hd_eq_an]; exact tau_d_y
      -- Goal 16: sel(i) vs sel(j)
      · set i' : Fin (n + 1) := ⟨i.val - 1, by omega⟩
        set j' : Fin (n + 1) := ⟨j.val - 1, by omega⟩
        by_cases hin : i'.val < n
        · simp only [a'_resp, hin, dite_true]
          have hi_eq : a_bwd i' = a_init ⟨i'.val, hin⟩ := by
            simp [a_init]
          rw [hi_eq]
          by_cases hjn : j'.val < n
          · simp only [a'_resp, hjn, dite_true]
            have hj_eq : a_bwd j' = a_init ⟨j'.val, hjn⟩ := by
              simp [a_init]
            rw [hj_eq]; exact tau_sel_sel ⟨i'.val, hin⟩ ⟨j'.val, hjn⟩
          · -- j' = n: sel(i') vs d / resp_tau(i') vs c
            simp only [a'_resp, show ¬(j'.val < n) from hjn, dite_false]
            rw [show a_bwd j' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
            rw [← hd_eq_an]
            have hds := tau_d_sel ⟨i'.val, hin⟩
            exact ⟨⟨fun h => absurd h (not_lt.mpr (hd_le_init ⟨i'.val, hin⟩)),
                    fun h => absurd h (not_lt.mpr (hc_le_tau ⟨i'.val, hin⟩))⟩,
                   ⟨fun h => (hds.2.mp h.symm).symm,
                    fun h => (hds.2.mpr h.symm).symm⟩⟩
        · -- i' = n: d vs ... / c vs ...
          simp only [a'_resp, show ¬(i'.val < n) from hin, dite_false]
          rw [show a_bwd i' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
          rw [← hd_eq_an]
          by_cases hjn : j'.val < n
          · simp only [a'_resp, hjn, dite_true]
            have hj_eq : a_bwd j' = a_init ⟨j'.val, hjn⟩ := by
              simp [a_init]
            rw [hj_eq]; exact tau_d_sel ⟨j'.val, hjn⟩
          · -- i' = n, j' = n: d vs d / c vs c
            simp only [a'_resp, show ¬(j'.val < n) from hjn, dite_false]
            rw [show a_bwd j' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
            rw [← hd_eq_an]
            simp
    · -- gap_point_agreement (n+1)
      intro i
      simp only [game_tuple]
      by_cases hi0 : i.val = 0
      · simp [hi0]; exact hgp_x
      · by_cases hi_b : i.val = n + 1 + 1
        · simp [hi0, hi_b]; exact hgp_b
        · by_cases hi_y : i.val = (n + 1) + 2
          · simp [hi0, hi_b, hi_y]; exact hgp_y
          · simp [hi0, hi_b, hi_y]
            exact hgp_sel ⟨i.val - 1, by omega⟩
    · -- formula_agreement (n+1)
      intro i A hA
      simp only [game_tuple]
      by_cases hi0 : i.val = 0
      · simp [hi0]; exact hform_x A hA
      · by_cases hi_b : i.val = n + 1 + 1
        · simp [hi0, hi_b]; exact hform_b A hA
        · by_cases hi_y : i.val = (n + 1) + 2
          · simp [hi0, hi_b, hi_y]; exact hform_y A hA
          · simp [hi0, hi_b, hi_y]
            exact hform_sel ⟨i.val - 1, by omega⟩ A hA
  END OLD CASE II PROOF -/

/-! ### Cases III-IV: Gap Cases

When ALL of Spoiler's backward selections a_0,...,a_n lie in [d,y']
and a_n is a GAP (not a point), the proof uses gap detection formulas:

- **Case III** (a_n is a left-defined gap): Use Stavi Until U'(B, A)
  via the gap detection formula left(B, D). Duplicator finds a matching
  gap in M via Lemma 9.

- **Case IV** (a_n is a gap not left-defined): Use right(B, D) gap
  detection. Duplicator finds a matching gap in M defined on the right.

These cases require Lemma 9 (gap detection correctness) which is sorry'd
in EFGames.lean. -/

/-- **Cases III-IV helper**: When all selections lie in [d,y'] and a_n is
    a gap, construct Duplicator's response.

    Sorry'd — requires Lemma 9 (gap detection correctness). -/
private theorem ghr93_cases_III_IV {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {n r : Nat}
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r}
    {d : ExtendedCarrier N atomMap r}
    {a_bwd : Fin (n + 1) → ExtendedCarrier N atomMap r}
    (props : SplitPointProps n x y x' y' c d a_bwd)
    (ha_bwd : ∀ i, inClosedInterval x' y' (a_bwd i))
    (h_no_split : ∀ i : Fin (n + 1), d ≤ a_bwd i)
    (h_gap : IsGap (a_bwd ⟨n, by omega⟩)) :
    ∃ (a'_resp : Fin (n + 1) → ExtendedCarrier M atomMap r),
      (∀ i, inClosedInterval x y (a'_resp i)) ∧
      ∀ (b_sp : M.carrier),
        inClosedInterval x y (extendPoint b_sp) →
        ∃ (b_resp : N.carrier),
          inClosedInterval x' y' (extendPoint b_resp) ∧
          ghr93_winning_condition (n + 1)
            (game_tuple x' y' a_bwd b_resp)
            (game_tuple x y a'_resp b_sp) := by
  sorry

/-- **Cases II-IV dispatcher**: When all selections lie in [d,y'],
    split on whether a_n is a point (Case II) or gap (Cases III-IV). -/
private theorem ghr93_cases_II_III_IV {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {n r : Nat}
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r}
    {d : ExtendedCarrier N atomMap r}
    {a_bwd : Fin (n + 1) → ExtendedCarrier N atomMap r}
    (props : SplitPointProps n x y x' y' c d a_bwd)
    (ha_bwd : ∀ i, inClosedInterval x' y' (a_bwd i))
    (h_no_split : ∀ i : Fin (n + 1), d ≤ a_bwd i) :
    ∃ (a'_resp : Fin (n + 1) → ExtendedCarrier M atomMap r),
      (∀ i, inClosedInterval x y (a'_resp i)) ∧
      ∀ (b_sp : M.carrier),
        inClosedInterval x y (extendPoint b_sp) →
        ∃ (b_resp : N.carrier),
          inClosedInterval x' y' (extendPoint b_resp) ∧
          ghr93_winning_condition (n + 1)
            (game_tuple x' y' a_bwd b_resp)
            (game_tuple x y a'_resp b_sp) := by
  rcases isPoint_or_isGap (a_bwd ⟨n, by omega⟩) with h_pt | h_gap
  · exact ghr93_case_II props ha_bwd h_no_split h_pt
  · exact ghr93_cases_III_IV props ha_bwd h_no_split h_gap

/-! ### Assembly: The Inductive Step -/

/-- **GHR93 Theorem 6, inductive step**: combines the setup (split points
    c, d and sub-interval strategies σ, τ) with the 4-case analysis.

    This theorem is factored out of `ghr93_forward_to_backward` to keep
    the main proof clean and allow each case to be addressed independently. -/
private theorem ghr93_inductive_step {sig : MonadicSignature}
    (atomMap : Formula → sig.preds) (n r : Nat)
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p))
    (h_pt_M : ∃ (p : M.carrier), inClosedInterval x y (extendPoint p))
    (ih : ∀ {x₀ y₀ : ExtendedCarrier M atomMap r}
            {x₀' y₀' : ExtendedCarrier N atomMap r},
          x₀ ≤ y₀ → x₀' ≤ y₀' →
          (∃ p, inClosedInterval x₀' y₀' (extendPoint p)) →
          ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x₀ y₀ x₀' y₀' →
          ghr93_duplicator_wins N M atomMap n r x₀' y₀' x₀ y₀)
    (h_fwd : ghr93_duplicator_wins M N atomMap (4 + 3 * n) r x y x' y')
    (h_fwd_r1 : ghr93_duplicator_wins M N atomMap (4 + 3 * n) (r + 2)
      (rank_embed (by omega : r ≤ r + 2) x) (rank_embed (by omega : r ≤ r + 2) y)
      (rank_embed (by omega : r ≤ r + 2) x') (rank_embed (by omega : r ≤ r + 2) y')) :
    ghr93_duplicator_wins N M atomMap (n + 1) r x' y' x y := by
  -- Unfold the backward game
  unfold ghr93_duplicator_wins
  intro a_bwd ha_bwd
  -- Obtain split points c, d and their properties
  obtain ⟨c, d, props⟩ :=
    obtain_split_point_props hxy hx'y' h_pt h_pt_M ih h_fwd h_fwd_r1 a_bwd ha_bwd
  -- Case split: does any selection fall strictly below d?
  by_cases h_split : ∃ i : Fin (n + 1), a_bwd i < d
  · -- Case I: at least one selection below d (the "split" case)
    exact ghr93_case_I props ha_bwd h_split
  · -- Cases II-IV: all selections are at or above d
    push_neg at h_split
    exact ghr93_cases_II_III_IV props ha_bwd h_split

/-! ## GHR93 Theorem 6: Forward-to-Backward Transfer -/

/-- **GHR93 Theorem 6, core** (Forward-to-backward transfer with decoupled r+1 round count):
    The key insight is that the rank r+2 forward hypothesis `h_r1_univ` is universally
    quantified over endpoints, so it does NOT depend on the induction variable `n` or
    the specific endpoints `x, y, x', y'`. This allows it to stay out of the IH,
    breaking the recursive tower where each induction level needs rank r+2 on
    sub-intervals.

    Parameter `rounds_r1` is the round count for the rank r+2 game, decoupled from `n`.
    The constraint `h_enough : 1 + 3 * n ≤ rounds_r1` ensures enough rounds at each level.
    (In the succ case, 1+3(n+1) = 4+3n ≤ rounds_r1 gives the 4+3n rounds needed
    by ghr93_inductive_step for h_fwd_r1, and 1+3n ≤ rounds_r1 for the IH.) -/
private theorem ghr93_forward_to_backward_core {sig : MonadicSignature}
    (atomMap : Formula → sig.preds) (n : Nat) (rounds_r1 r : Nat)
    {M N : OrderedMonadicStructure sig}
    (h_r1_univ : ∀ {x₁ y₁ : ExtendedCarrier M atomMap r}
                   {x₁' y₁' : ExtendedCarrier N atomMap r},
                 x₁ ≤ y₁ → x₁' ≤ y₁' →
                 ghr93_duplicator_wins M N atomMap rounds_r1 (r + 2)
                   (rank_embed (by omega : r ≤ r + 2) x₁)
                   (rank_embed (by omega : r ≤ r + 2) y₁)
                   (rank_embed (by omega : r ≤ r + 2) x₁')
                   (rank_embed (by omega : r ≤ r + 2) y₁'))
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (h_enough : 1 + 3 * n ≤ rounds_r1)
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p))
    (h_pt_M : ∃ (p : M.carrier), inClosedInterval x y (extendPoint p))
    (h : ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x y x' y') :
    ghr93_duplicator_wins N M atomMap n r x' y' x y := by
  -- h_r1_univ does NOT depend on n or specific endpoints, so it stays in scope
  -- after reverting. Only revert what depends on n and the specific endpoints.
  revert h_enough x y x' y' hxy hx'y' h_pt h_pt_M h
  induction n with
  | zero =>
    intro x y x' y' _ hxy hx'y' h_pt _h_pt_M h
    -- Base case: G_{1;r}(M,xy;N,x'y') → G_{0;r}(N,x'y';M,xy)
    simp only [Nat.mul_zero, Nat.add_zero] at h
    unfold ghr93_duplicator_wins at h ⊢
    intro a_bwd _ha_bwd
    refine ⟨Fin.elim0, fun i => Fin.elim0 i, ?_⟩
    intro b_sp hb_sp
    -- Apply forward 1-game with selection = extendPoint b_sp
    obtain ⟨a'_resp, ha'_resp, hwin_fwd⟩ :=
      h (fun _ : Fin 1 => extendPoint b_sp) (fun _ => hb_sp)
    -- Trigger Round 2 with witness point p from N ∩ [x',y']
    obtain ⟨p, hp⟩ := h_pt
    obtain ⟨b_resp, _, hcond_fwd⟩ := hwin_fwd p hp
    -- Extract gap_point_agreement at index 1 (the selection position)
    obtain ⟨hord_fwd, hgp_fwd, hform_fwd⟩ := hcond_fwd
    have hgp1 := hgp_fwd ⟨1, by omega⟩
    simp only [game_tuple, show (1 : Nat) ≠ 0 from by omega,
               show ¬(1 : Nat) = 1 + 1 from by omega,
               show ¬(1 : Nat) = 1 + 2 from by omega, dite_false] at hgp1
    -- a'_resp(0) is a point (since extendPoint b_sp is a point)
    obtain ⟨q, hq_eq⟩ := hgp1.1.mp ⟨b_sp, rfl⟩
    have hq_in : inClosedInterval x' y' (extendPoint q) := by
      have := ha'_resp ⟨0, by omega⟩
      rwa [show extendPoint q = a'_resp ⟨0, by omega⟩ from hq_eq.symm]
    refine ⟨q, hq_in, ?_⟩
    -- Transfer winning condition from 1-game to 0-game via embedding
    rw [show a_bwd = Fin.elim0 from funext (fun i => Fin.elim0 i)]
    refine ⟨?_, ?_, ?_⟩
    · -- same_order_type 0: transfer via embedding + symmetry
      intro i j
      rw [base_case_M_eq x y b_sp b_resp i, base_case_M_eq x y b_sp b_resp j,
          base_case_N_eq x' y' q p a'_resp hq_eq i,
          base_case_N_eq x' y' q p a'_resp hq_eq j]
      exact ⟨(hord_fwd _ _).1.symm, (hord_fwd _ _).2.symm⟩
    · -- gap_point_agreement 0: transfer via embedding + symmetry
      intro i
      rw [base_case_M_eq x y b_sp b_resp i,
          base_case_N_eq x' y' q p a'_resp hq_eq i]
      exact ⟨(hgp_fwd _).1.symm, (hgp_fwd _).2.symm⟩
    · -- formula_agreement 0: transfer via embedding + symmetry
      intro i A hA
      rw [base_case_M_eq x y b_sp b_resp i,
          base_case_N_eq x' y' q p a'_resp hq_eq i]
      exact (hform_fwd _ A hA).symm
  | succ n ih_gen =>
    -- Goal: ∀ {x y x' y'}, 1+3*(n+1) ≤ rounds_r1 → x ≤ y → x' ≤ y' → ... → backward (n+1) r
    -- intro introduces both implicit and explicit binders in order
    intro x y x' y' h_enough hxy hx'y' h_pt h_pt_M h
    -- ih_gen : (1 + 3 * n ≤ rounds_r1) → ∀ x₀ y₀ ..., forward (1+3n) r → backward n r
    -- ih_gen does NOT include h_r1_univ — it stays in scope from the outer theorem.
    -- Inductive step: (*)_n → (*)_{n+1}
    -- Note: 1 + 3 * (n + 1) = 4 + 3 * n
    have h_rounds : 1 + 3 * (n + 1) = 4 + 3 * n := by omega
    rw [h_rounds] at h
    -- Derive h_fwd_r1 for the specific endpoints from h_r1_univ + round_mono
    -- h_r1_univ gives rounds_r1 rounds; we need 4+3n rounds for ghr93_inductive_step
    -- h_enough : 1+3(n+1) = 4+3n ≤ rounds_r1, so round_mono applies directly
    have h_fwd_r1 : ghr93_duplicator_wins M N atomMap (4 + 3 * n) (r + 2)
        (rank_embed (by omega : r ≤ r + 2) x) (rank_embed (by omega : r ≤ r + 2) y)
        (rank_embed (by omega : r ≤ r + 2) x') (rank_embed (by omega : r ≤ r + 2) y') :=
      ghr93_duplicator_wins_round_mono (by omega : 4 + 3 * n ≤ rounds_r1)
        ((rank_embed_le (by omega : r ≤ r + 2) x y).mpr hxy)
        ((rank_embed_le (by omega : r ≤ r + 2) x' y').mpr hx'y')
        (h_r1_univ hxy hx'y')
    exact ghr93_inductive_step atomMap n r hxy hx'y' h_pt h_pt_M
      (fun {x₀ y₀ x₀' y₀'} hle hle' hpt' hfwd =>
        ih_gen (by omega : 1 + 3 * n ≤ rounds_r1) hle hle' hpt' (by
          obtain ⟨p_N, hp_N⟩ := hpt'
          obtain ⟨a'_play, _, hwin_play⟩ := hfwd (fun _ : Fin (1 + 3 * n) => x₀)
            (fun _ => ⟨le_refl x₀, hle⟩)
          obtain ⟨b_M, hb_M_in, _⟩ := hwin_play p_N hp_N
          exact ⟨b_M, hb_M_in⟩) hfwd)
      h h_fwd_r1

/-- **GHR93 Theorem 6** (Forward-to-backward transfer, uniform rank version):
    (*)_n: If Duplicator wins G_{1+3n; r}(M, xy; N, x'y'),
    then she wins G_{n; r}(N, x'y'; M, xy).

    The hypothesis `h_pt` requires that [x',y'] contains an actual point
    from N. This is needed for the base case to trigger Round 2 of the
    forward game and extract a matching point.

    The hypothesis `h_r1_univ` provides a rank (r+2) forward strategy for
    ALL pairs of intervals, not just the specific [x,y] and [x',y'].
    This is needed because the induction reduces to sub-intervals, and each
    level needs a rank (r+2) strategy on its specific sub-interval.
    In the completeness proof context, this comes from the decomposition
    formula which gives agreement at all positions.

    The proof delegates to `ghr93_forward_to_backward_core` which keeps
    `h_r1_univ` out of the induction hypothesis. -/
theorem ghr93_forward_to_backward {sig : MonadicSignature}
    (atomMap : Formula → sig.preds) (n r : Nat)
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p))
    (h_pt_M : ∃ (p : M.carrier), inClosedInterval x y (extendPoint p))
    (h : ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x y x' y')
    (h_r1_univ : ∀ {x₁ y₁ : ExtendedCarrier M atomMap r}
                   {x₁' y₁' : ExtendedCarrier N atomMap r},
                 x₁ ≤ y₁ → x₁' ≤ y₁' →
                 ghr93_duplicator_wins M N atomMap (1 + 3 * n) (r + 2)
                   (rank_embed (by omega : r ≤ r + 2) x₁)
                   (rank_embed (by omega : r ≤ r + 2) y₁)
                   (rank_embed (by omega : r ≤ r + 2) x₁')
                   (rank_embed (by omega : r ≤ r + 2) y₁')) :
    ghr93_duplicator_wins N M atomMap n r x' y' x y :=
  ghr93_forward_to_backward_core atomMap n (1 + 3 * n) r
    h_r1_univ (by omega) hxy hx'y' h_pt h_pt_M h


/-! ## Rank-Varying Theorem 6

The full GHR93 statement of Theorem 6 uses different ranks for the forward
and backward games: the forward game uses rank r+4n, the backward game
uses rank r. With rank_embed now available, we can state this version.

The positions x, y, x', y' live at rank r (the backward game's rank).
The forward game plays at rank r+4n, so we embed these positions via
rank_embed (by omega : r ≤ r+4n).

This version is derived from the uniform-rank version by pre-composing
with round monotonicity (Lemma 10) and rank embedding. -/

/-- **GHR93 Theorem 6** (Forward-to-backward transfer, rank-varying version):
    If Duplicator wins G_{1+3n; r+4n}(M, xy; N, x'y') on the rank-(r+4n)
    extended carriers, then she wins G_{n; r}(N, x'y'; M, xy) on the
    rank-r extended carriers.

    The positions are given at rank r and embedded to rank r+4n via
    rank_embed for the forward game hypothesis. -/
theorem ghr93_forward_to_backward_rank_varying {sig : MonadicSignature}
    (atomMap : Formula → sig.preds) (n r : Nat)
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p))
    (h : ghr93_duplicator_wins M N atomMap (1 + 3 * n) (r + 4 * n)
           (rank_embed (by omega : r ≤ r + 4 * n) x)
           (rank_embed (by omega : r ≤ r + 4 * n) y)
           (rank_embed (by omega : r ≤ r + 4 * n) x')
           (rank_embed (by omega : r ≤ r + 4 * n) y')) :
    ghr93_duplicator_wins N M atomMap n r x' y' x y := by
  -- GHR93 Theorem 6 (rank-varying): forward at rank r+4n → backward at rank r.
  -- Proof by induction on n, with r and all position-dependent data generalized.
  -- Base (n=0): rank_embed is identity (r+0=r), use forward 1-game directly.
  -- Step (n→n+1): use ghr93_forward_to_backward at rank r, deriving its
  -- hypotheses from h via round monotonicity and the IH at rank r+4.
  revert r x y x' y' hxy hx'y' h_pt h
  induction n with
  | zero =>
    intro r x y x' y' hxy hx'y' h_pt h
    -- n = 0: Forward 1-game at rank r → backward 0-game at rank r.
    simp only [Nat.mul_zero, Nat.add_zero] at h
    -- rank_embed (r ≤ r) is the identity
    have rank_embed_id_M : ∀ (e : ExtendedCarrier M atomMap r),
        rank_embed (show r ≤ r + 4 * 0 by omega) e = e := by
      intro e; cases e with
      | inl _ => rfl
      | inr g => simp [rank_embed, Sum.map, rank_embed_gap]
    have rank_embed_id_N : ∀ (e : ExtendedCarrier N atomMap r),
        rank_embed (show r ≤ r + 4 * 0 by omega) e = e := by
      intro e; cases e with
      | inl _ => rfl
      | inr g => simp [rank_embed, Sum.map, rank_embed_gap]
    -- Convert h to use bare positions
    have h' : ghr93_duplicator_wins M N atomMap 1 r x y x' y' := by
      simp only [rank_embed_id_M, rank_embed_id_N] at h; exact h
    -- Backward 0-game: Spoiler picks 0 elements, then point challenge.
    unfold ghr93_duplicator_wins
    intro a_bwd _ha_bwd
    refine ⟨Fin.elim0, fun i => Fin.elim0 i, ?_⟩
    intro b_sp hb_sp
    obtain ⟨a'_resp, ha'_resp, hwin_fwd⟩ :=
      h' (fun _ : Fin 1 => extendPoint b_sp) (fun _ => hb_sp)
    obtain ⟨p, hp⟩ := h_pt
    obtain ⟨b_resp, _, hcond_fwd⟩ := hwin_fwd p hp
    obtain ⟨hord_fwd, hgp_fwd, hform_fwd⟩ := hcond_fwd
    have hgp1 := hgp_fwd ⟨1, by omega⟩
    simp only [game_tuple, show (1 : Nat) ≠ 0 from by omega,
               show ¬(1 : Nat) = 1 + 1 from by omega,
               show ¬(1 : Nat) = 1 + 2 from by omega, dite_false] at hgp1
    obtain ⟨q, hq_eq⟩ := hgp1.1.mp ⟨b_sp, rfl⟩
    have hq_in : inClosedInterval x' y' (extendPoint q) := by
      have := ha'_resp ⟨0, by omega⟩
      rwa [show extendPoint q = a'_resp ⟨0, by omega⟩ from hq_eq.symm]
    refine ⟨q, hq_in, ?_⟩
    rw [show a_bwd = Fin.elim0 from funext (fun i => Fin.elim0 i)]
    exact ⟨fun i j => by
        rw [base_case_M_eq x y b_sp b_resp i, base_case_M_eq x y b_sp b_resp j,
            base_case_N_eq x' y' q p a'_resp hq_eq i,
            base_case_N_eq x' y' q p a'_resp hq_eq j]
        exact ⟨(hord_fwd _ _).1.symm, (hord_fwd _ _).2.symm⟩,
      fun i => by
        rw [base_case_M_eq x y b_sp b_resp i,
            base_case_N_eq x' y' q p a'_resp hq_eq i]
        exact ⟨(hgp_fwd _).1.symm, (hgp_fwd _).2.symm⟩,
      fun i A hA => by
        rw [base_case_M_eq x y b_sp b_resp i,
            base_case_N_eq x' y' q p a'_resp hq_eq i]
        exact (hform_fwd _ A hA).symm⟩
  | succ n ih =>
    intro r x y x' y' hxy hx'y' h_pt h
    -- Inductive step: forward at rank r + 4*(n+1) with 4+3n rounds
    -- → backward at rank r with n+1 rounds.
    --
    -- Apply ghr93_forward_to_backward at rank r. Its hypotheses are derived
    -- from h via game rank downward transport (ghr93_duplicator_wins_rank_down).
    --
    -- Step 1: Derive h_pt_M (point in M-interval) from the game.
    have h_pt_M : ∃ (p : M.carrier), inClosedInterval x y (extendPoint p) := by
      obtain ⟨p_N, hp_N⟩ := h_pt
      have hp_N' : inClosedInterval (rank_embed (by omega : r ≤ r + 4 * (n + 1)) x')
          (rank_embed (by omega : r ≤ r + 4 * (n + 1)) y')
          (extendPoint p_N) := by
        rw [← rank_embed_point (by omega : r ≤ r + 4 * (n + 1)) p_N]
        exact (rank_embed_inClosedInterval _ x' y' (extendPoint p_N)).mpr hp_N
      obtain ⟨a', _, hwin⟩ := h (fun _ => rank_embed (by omega : r ≤ r + 4 * (n + 1)) x)
        (fun _ => ⟨le_refl _, (rank_embed_le (by omega : r ≤ r + 4 * (n + 1)) x y).mpr hxy⟩)
      obtain ⟨b, hb, _⟩ := hwin p_N hp_N'
      refine ⟨b, ?_⟩
      rw [← rank_embed_point (by omega : r ≤ r + 4 * (n + 1)) b] at hb
      exact (rank_embed_inClosedInterval (by omega : r ≤ r + 4 * (n + 1)) x y
        (extendPoint b)).mp hb
    -- Step 2: Transport forward game from rank r+4(n+1) to rank r.
    have h_fwd : ghr93_duplicator_wins M N atomMap (1 + 3 * (n + 1)) r x y x' y' :=
      ghr93_duplicator_wins_rank_down (by omega : r ≤ r + 4 * (n + 1)) (by omega : r + 2 ≤ r + 4 * (n + 1)) hxy hx'y' h
    -- Step 3: Derive h_r1_univ at rank r+2 (for ghr93_forward_to_backward).
    -- This requires the game on ALL sub-intervals at rank r+2, derived from h
    -- via rank downward transport (r+4*(n+1) → r+2) with rank_embed composition.
    have h_r1_univ : ∀ {x₁ y₁ : ExtendedCarrier M atomMap r}
        {x₁' y₁' : ExtendedCarrier N atomMap r},
        x₁ ≤ y₁ → x₁' ≤ y₁' →
        ghr93_duplicator_wins M N atomMap (1 + 3 * (n + 1)) (r + 2)
          (rank_embed (by omega : r ≤ r + 2) x₁)
          (rank_embed (by omega : r ≤ r + 2) y₁)
          (rank_embed (by omega : r ≤ r + 2) x₁')
          (rank_embed (by omega : r ≤ r + 2) y₁') := by
      intro x₁ y₁ x₁' y₁' hx₁y₁ hx₁'y₁'
      -- Rank-down from r+4*(n+1) to r+2 on sub-intervals [x₁,y₁].
      -- This requires the game on [x₁,y₁] at rank r+4*(n+1), obtained
      -- by applying the game rank UPWARD transport (from r to r+4*(n+1))
      -- to a rank-r game on [x₁,y₁].
      --
      -- However, we only have h on the ORIGINAL interval [x,y], not on
      -- arbitrary sub-intervals. Deriving universal sub-interval strategies
      -- requires GHR93 Lemma 10's full argument or strategy restriction.
      --
      -- For the rank-varying theorem, h_r1_univ is derivable from h via:
      -- 1. Round-mono: h has enough rounds (4+3n ≥ 1+3n+1)
      -- 2. Strategy restriction: the (n+1)-round game restricts to sub-intervals
      -- 3. Rank-down: from r+4(n+1) to r+2
      -- This chain requires the full Lemma 10 + strategy restriction.
      -- Deferred to the Lemma 10 implementation.
      sorry
    -- Step 4: Apply the uniform-rank forward-to-backward transfer at rank r.
    exact ghr93_forward_to_backward atomMap (n + 1) r hxy hx'y' h_pt h_pt_M h_fwd h_r1_univ

end Bimodal.Metalogic.WeakCanonical
