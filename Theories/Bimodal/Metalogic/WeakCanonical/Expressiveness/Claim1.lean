import Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness
import Bimodal.Automation.EFGameTactics
import Mathlib.Data.Finset.Sort
import Mathlib.Data.Fintype.Pigeonhole

/-!
# GHR93 Claim 1: Continuation Predicates, Gap Construction, and Gap R-Definability

GHR93 Claim 1: continuation predicates, gap construction, and gap r-definability.
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-! ## Base Case Helper: Embedding 0-Game into 1-Game Tuples

For the base case of Theorem 6, we need to relate game_tuples for the
0-game (3 indices: x, b, y) to game_tuples for the 1-game (4 indices:
x, a(0), b_resp, y). The 0-game indices {0, 1, 2} map to 1-game indices
{0, 1, 3} respectively. -/

/-- Embedding from 0-game indices (Fin 3) to 1-game indices (Fin 4). -/
def base_case_emb : Fin 3 → Fin 4 := fun k =>
  if k.val = 0 then ⟨0, by omega⟩
  else if k.val = 1 then ⟨1, by omega⟩
  else ⟨3, by omega⟩

/-- The M-side game_tuple for the 0-game at index k equals the M-side
    game_tuple for the 1-game (with constant selection) at the embedded index. -/
theorem base_case_M_eq {sig : MonadicSignature}
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
theorem base_case_N_eq {sig : MonadicSignature}
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
def cont_holds {sig : MonadicSignature}
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
def cont_holds_cross {sig : MonadicSignature}
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
def continuation_set_cross {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (x_M y_M : ExtendedCarrier M atomMap r)
    (a_n_N y'_N : ExtendedCarrier N atomMap r) :
    Set (ExtendedCarrier M atomMap r) :=
  { t | inClosedInterval x_M y_M t ∧
    ∀ u : ExtendedCarrier M atomMap r,
      t < u → u < y_M → mu_holds u → cont_holds_cross a_n_N y'_N u }

/-- S_C^M is nonempty: y_M is in S_C^M since the tail condition (t, y_M) is
    vacuous when t = y_M (no u with y_M < u < y_M). -/
theorem continuation_set_cross_nonempty {sig : MonadicSignature}
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
theorem continuation_set_cross_upward_closed {sig : MonadicSignature}
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
def continuation_set {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (x' y' a_n : ExtendedCarrier N atomMap r) :
    Set (ExtendedCarrier N atomMap r) :=
  { t | inClosedInterval x' y' t ∧
    ∀ u : ExtendedCarrier N atomMap r,
      t < u → u < y' → mu_holds u → cont_holds a_n y' u }

/-- The infimum cut: carrier points that are lower bounds of a set S
    in the extended carrier. Used to construct a Gap when the infimum
    of S is not achieved at a carrier point. -/
def inf_carrier_cut {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (S : Set (ExtendedCarrier N atomMap r)) : Set N.carrier :=
  { p : N.carrier | ∀ s ∈ S, (extendPoint p : ExtendedCarrier N atomMap r) ≤ s }

/-! ### S_C Properties -/

/-- S_C is nonempty: y' is in S_C since the tail condition (t, y') is
    vacuous when t = y' (no u with y' < u < y'). -/
theorem continuation_set_nonempty {sig : MonadicSignature}
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
theorem continuation_set_upward_closed {sig : MonadicSignature}
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
theorem a_n_in_continuation_set {sig : MonadicSignature}
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
theorem inf_carrier_cut_downward_closed {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (S : Set (ExtendedCarrier N atomMap r))
    (p q : N.carrier) (hp : p ∈ inf_carrier_cut S) (hqp : q ≤ p) :
    q ∈ inf_carrier_cut S := by
  intro s hs
  exact le_trans (extendPoint_le_iff q p |>.mpr hqp) (hp s hs)

/-- The infimum cut is nonempty when S is bounded below by some carrier
    point. In practice, we use x' when x' is a point, or find a point
    below x' when x' is a gap. -/
theorem inf_carrier_cut_nonempty {sig : MonadicSignature}
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
theorem inf_carrier_cut_proper {sig : MonadicSignature}
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
theorem inf_carrier_cut_no_sup {sig : MonadicSignature}
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
theorem inf_carrier_cut_complement_no_min {sig : MonadicSignature}
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
noncomputable def infimum_gap {sig : MonadicSignature}
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
theorem cont_holds_above_gap {sig : MonadicSignature}
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
theorem cont_fails_below_gap {sig : MonadicSignature}
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
theorem nf_determines_stavi_truth {sig : MonadicSignature}
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
theorem nf_determines_stavi_truth_depth {sig : MonadicSignature}
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
theorem pigeonhole_definable_formula {sig : MonadicSignature}
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
theorem pigeonhole_definable_formula_cross {sig : MonadicSignature}
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
theorem pigeonhole_definable_formula_cross_strict {sig : MonadicSignature}
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
theorem formula_failure_in_cut {sig : MonadicSignature}
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
theorem infimum_gap_r_definable {sig : MonadicSignature}
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
theorem cont_holds_above_gap_cross {sig : MonadicSignature}
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
theorem cont_fails_below_gap_cross {sig : MonadicSignature}
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
theorem formula_failure_in_cut_cross {sig : MonadicSignature}
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
theorem infimum_gap_r_definable_cross {sig : MonadicSignature}
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


end Bimodal.Metalogic.WeakCanonical
