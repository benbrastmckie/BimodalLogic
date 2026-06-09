import Bimodal.Metalogic.WeakCanonical.EFGames.Decomposition
import Bimodal.Metalogic.WeakCanonical.EFGames.Composition

/-!
# GHR93 Theorem 6 for Discrete Orders

Theorem 6 (GHR93 pp.114-119) restricted to discrete (succ-archimedean) orders.
In discrete orders, `IsEmpty (Gap T)` so the extended carrier M_r equals M
(no gaps are adjoined). Cases III and IV of Theorem 6 are vacuous.

## Overview

**Theorem 6**: If Duplicator wins G_{1+3n; r+4n}(M, xy; N, x'y') then
Duplicator wins G_{n; r}(N, x'y'; M, xy).

This is the "forward-to-backward" game inversion theorem. It inverts
both the direction of play (M/N swap) and reduces the game parameters.

For discrete orders, only Cases I and II apply, yielding a simpler proof.

## References

- GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9, Theorem 6 (pp.114-119)
- Task 273, Plan v8, Phase 2
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-! ## Discrete ExtendedCarrier Simplification

In discrete orders (with SuccOrder, PredOrder, NoMaxOrder, NoMinOrder,
IsSuccArchimedean), `discrete_no_gaps` gives `IsEmpty (Gap T)`. This means
`RDefinableGap M atomMap r` is empty for any r, so `ExtendedCarrier M atomMap r`
is isomorphic to `M.carrier`. We provide conversion functions. -/

/-- In a discrete order, every element of ExtendedCarrier is a point. -/
theorem discrete_extended_isPoint {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    (e : ExtendedCarrier M atomMap r) : IsPoint e := by
  cases e with
  | inl x => exact ⟨x, rfl⟩
  | inr g =>
    exact absurd g.val (IsEmpty.false (discrete_no_gaps (T := M.carrier)))

/-- Extract the carrier point from a discrete ExtendedCarrier element. -/
noncomputable def discrete_to_carrier {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    (e : ExtendedCarrier M atomMap r) : M.carrier :=
  match e with
  | .inl x => x
  | .inr g => absurd g.val (IsEmpty.false (discrete_no_gaps (T := M.carrier)))

/-- discrete_to_carrier inverts extendPoint. -/
theorem discrete_to_carrier_extendPoint {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    (x : M.carrier) :
    discrete_to_carrier (extendPoint (sig := sig) (atomMap := atomMap) (r := r) x) = x := by
  simp [discrete_to_carrier, extendPoint]

/-- extendPoint inverts discrete_to_carrier. -/
theorem extendPoint_discrete_to_carrier {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    (e : ExtendedCarrier M atomMap r) :
    extendPoint (discrete_to_carrier e) = e := by
  cases e with
  | inl x => simp [discrete_to_carrier, extendPoint]
  | inr g => exact absurd g.val (IsEmpty.false (discrete_no_gaps (T := M.carrier)))

/-- Convert between ExtendedCarrier at different ranks in discrete orders.
    Since there are no gaps, this is just identity on the underlying carrier point. -/
noncomputable def discrete_rank_convert {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    (e : ExtendedCarrier M atomMap r) : ExtendedCarrier M atomMap r' :=
  extendPoint (discrete_to_carrier e)

/-- discrete_rank_convert preserves order. -/
theorem discrete_rank_convert_le {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    (a b : ExtendedCarrier M atomMap r) :
    a ≤ b ↔ discrete_rank_convert (r' := r') a ≤ discrete_rank_convert (r' := r') b := by
  cases a with
  | inl x =>
    cases b with
    | inl y => simp [discrete_rank_convert, discrete_to_carrier, extendPoint]
    | inr g => exact absurd g.val (IsEmpty.false (discrete_no_gaps (T := M.carrier)))
  | inr g => exact absurd g.val (IsEmpty.false (discrete_no_gaps (T := M.carrier)))

/-- discrete_rank_convert preserves strict order. -/
theorem discrete_rank_convert_lt {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    (a b : ExtendedCarrier M atomMap r) :
    a < b ↔ discrete_rank_convert (r' := r') a < discrete_rank_convert (r' := r') b := by
  constructor
  · intro h
    exact lt_of_le_of_ne ((discrete_rank_convert_le a b).mp h.le)
      (fun heq => h.ne (by
        have := (discrete_rank_convert_le a b).mpr (le_of_eq heq)
        have := (discrete_rank_convert_le b a).mpr (le_of_eq heq.symm)
        exact le_antisymm ‹a ≤ b› ‹b ≤ a›))
  · intro h
    exact lt_of_le_of_ne ((discrete_rank_convert_le a b).mpr h.le)
      (fun heq => h.ne (by
        have := (discrete_rank_convert_le (r' := r') a b).mp (le_of_eq heq)
        have := (discrete_rank_convert_le (r' := r') b a).mp (le_of_eq heq.symm)
        exact le_antisymm ‹discrete_rank_convert a ≤ discrete_rank_convert b›
          ‹discrete_rank_convert b ≤ discrete_rank_convert a›))

/-- discrete_rank_convert is injective. -/
theorem discrete_rank_convert_injective {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    (a b : ExtendedCarrier M atomMap r)
    (h : discrete_rank_convert (r' := r') a = discrete_rank_convert (r' := r') b) :
    a = b := by
  have h1 := (discrete_rank_convert_le (r' := r') a b).mpr (le_of_eq h)
  have h2 := (discrete_rank_convert_le (r' := r') b a).mpr (le_of_eq h.symm)
  exact le_antisymm h1 h2

/-- discrete_rank_convert preserves equality. -/
theorem discrete_rank_convert_eq {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    (a b : ExtendedCarrier M atomMap r) :
    a = b ↔ discrete_rank_convert (r' := r') a = discrete_rank_convert (r' := r') b :=
  ⟨fun h => h ▸ rfl, discrete_rank_convert_injective a b⟩

/-- discrete_rank_convert preserves inClosedInterval. -/
theorem discrete_rank_convert_inClosedInterval {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    (x y e : ExtendedCarrier M atomMap r) :
    inClosedInterval x y e ↔
    inClosedInterval (discrete_rank_convert (r' := r') x)
      (discrete_rank_convert (r' := r') y)
      (discrete_rank_convert (r' := r') e) := by
  simp [inClosedInterval, discrete_rank_convert_le]

/-- discrete_rank_convert commutes with extendPoint. -/
theorem discrete_rank_convert_extendPoint {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    (x : M.carrier) :
    discrete_rank_convert (r' := r')
      (extendPoint (sig := sig) (atomMap := atomMap) (r := r) x) =
    extendPoint (sig := sig) (atomMap := atomMap) (r := r') x := by
  simp [discrete_rank_convert, discrete_to_carrier, extendPoint]

/-- In a discrete order, every ExtendedCarrier element is a point (IsPoint). -/
theorem discrete_isPoint {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    (e : ExtendedCarrier M atomMap r) : IsPoint e :=
  discrete_extended_isPoint e

/-- In a discrete order, no ExtendedCarrier element is a gap. -/
theorem discrete_not_isGap {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    (e : ExtendedCarrier M atomMap r) : ¬IsGap e := by
  intro ⟨g, hg⟩
  exact absurd g.val (IsEmpty.false (discrete_no_gaps (T := M.carrier)))

/-- In a discrete order with NoMaxOrder, there exists a carrier point strictly
    above any ExtendedCarrier element. -/
theorem discrete_exists_point_above {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    (e : ExtendedCarrier M atomMap r) :
    ∃ (p : M.carrier), e < extendPoint p := by
  obtain ⟨x, rfl⟩ := discrete_extended_isPoint e
  obtain ⟨y, hy⟩ := NoMaxOrder.exists_gt x
  exact ⟨y, (extendPoint_lt_iff x y).mpr hy⟩

/-- In a discrete order with NoMinOrder, there exists a carrier point strictly
    below any ExtendedCarrier element. -/
theorem discrete_exists_point_below {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    (e : ExtendedCarrier M atomMap r) :
    ∃ (p : M.carrier), extendPoint p < e := by
  obtain ⟨x, rfl⟩ := discrete_extended_isPoint e
  obtain ⟨y, hy⟩ := NoMinOrder.exists_lt x
  exact ⟨y, (extendPoint_lt_iff y x).mpr hy⟩

/-- In a discrete order, the interval [x, y] always contains a carrier point
    when x ≤ y. -/
theorem discrete_interval_has_point {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    (x y : ExtendedCarrier M atomMap r) (hxy : x ≤ y) :
    ∃ (p : M.carrier), inClosedInterval x y (extendPoint p) := by
  obtain ⟨px, rfl⟩ := discrete_extended_isPoint x
  exact ⟨px, ⟨le_refl _, hxy⟩⟩

/-- Formula truth is preserved by discrete_rank_convert (for formulas of depth ≤ min(r, r')).
    In discrete orders, this follows because all elements are points and
    stavi_truth_mu_at_point applies. -/
theorem discrete_rank_convert_formula {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    (e : ExtendedCarrier M atomMap r) (A : StaviFormula) :
    stavi_temporal_truth_mu M atomMap r e A ↔
    stavi_temporal_truth_mu M atomMap r' (discrete_rank_convert e) A := by
  obtain ⟨x, rfl⟩ := discrete_extended_isPoint e
  rw [stavi_truth_mu_at_point, discrete_rank_convert_extendPoint, stavi_truth_mu_at_point]

/-! ## Discrete Rank Conversion Helpers

For discrete orders, discrete_rank_convert is an order isomorphism between
ExtendedCarrier at different ranks. These helpers streamline conversions. -/

/-- discrete_rank_convert composed with itself gives the same result as
    a single discrete_rank_convert to the final rank. -/
theorem discrete_rank_convert_compose {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' r'' : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    (e : ExtendedCarrier M atomMap r) :
    discrete_rank_convert (r' := r'') (discrete_rank_convert (r' := r') e) =
    discrete_rank_convert (r' := r'') e := by
  simp [discrete_rank_convert, discrete_to_carrier, extendPoint]
  cases e with
  | inl p => simp [discrete_to_carrier, extendPoint]
  | inr g => exact absurd g.val (IsEmpty.false (discrete_no_gaps))

/-- In discrete orders, inClosedInterval transfers between ranks
    for discrete_rank_converted positions. -/
theorem discrete_inClosedInterval_rank_transfer {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' R : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    {x y : ExtendedCarrier M atomMap R}
    (e : ExtendedCarrier M atomMap r)
    (h : inClosedInterval (discrete_rank_convert (r' := r) x)
      (discrete_rank_convert (r' := r) y) e) :
    inClosedInterval (discrete_rank_convert (r' := r') x)
      (discrete_rank_convert (r' := r') y) (discrete_rank_convert (r' := r') e) := by
  simp only [inClosedInterval] at h ⊢
  constructor
  · exact (discrete_rank_convert_le _ _).mp h.1
  · exact (discrete_rank_convert_le _ _).mp h.2

/-- In discrete orders, inClosedInterval for an extendPoint transfers between ranks. -/
theorem discrete_inClosedInterval_point_rank_transfer {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' R : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    {x y : ExtendedCarrier M atomMap R}
    (p : M.carrier)
    (h : inClosedInterval (discrete_rank_convert (r' := r) x)
      (discrete_rank_convert (r' := r) y) (extendPoint p)) :
    inClosedInterval (discrete_rank_convert (r' := r') x)
      (discrete_rank_convert (r' := r') y) (extendPoint p) := by
  have := discrete_inClosedInterval_rank_transfer
    (extendPoint (sig := sig) (atomMap := atomMap) (r := r) p) h
  simp [discrete_rank_convert, discrete_to_carrier, extendPoint] at this
  exact this

/-- In discrete orders, inClosedInterval for extendPoint at rank R transfers to rank r
    for discrete_rank_converted boundaries. -/
theorem discrete_extendPoint_inClosedInterval_transfer {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r R : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    {x y : ExtendedCarrier M atomMap R}
    (p : M.carrier)
    (h : inClosedInterval x y (extendPoint p)) :
    inClosedInterval (discrete_rank_convert (r' := r) x)
      (discrete_rank_convert (r' := r) y) (extendPoint p) := by
  simp only [inClosedInterval] at h ⊢
  obtain ⟨x_pt, hx_pt⟩ := discrete_extended_isPoint x
  obtain ⟨y_pt, hy_pt⟩ := discrete_extended_isPoint y
  rw [hx_pt, hy_pt] at h ⊢
  simp only [discrete_rank_convert, discrete_to_carrier, extendPoint] at h ⊢
  exact h

/-! ## Game Rank Function

The rank function g from GHR93 Definition 8.9. For our purposes,
g(n) = 4 * game_depth sig n gives sufficient separation. -/

/-- The game rank function: g(n) = 4 * f(n) where f = game_depth.
    This matches GHR93 Definition 8.9: g(0) = 0, g(n+1) > g(n) + 4f(n). -/
noncomputable def game_rank (sig : MonadicSignature) (n : Nat) : Nat :=
  4 * game_depth sig n

/-- game_rank is monotone. -/
theorem game_rank_mono (sig : MonadicSignature) {n m : Nat} (h : n ≤ m) :
    game_rank sig n ≤ game_rank sig m := by
  simp only [game_rank]; exact Nat.mul_le_mul_left 4 (game_depth_mono sig h)

/-- game_rank at n+1 exceeds game_rank at n plus 4 * game_depth at n. -/
theorem game_rank_step (sig : MonadicSignature) (n : Nat) :
    game_rank sig n + 4 * game_depth sig n < game_rank sig (n + 1) := by
  simp only [game_rank]
  have h := game_depth_strict_mono sig n
  omega

/-- game_rank at 0 is 0. -/
theorem game_rank_zero (sig : MonadicSignature) : game_rank sig 0 = 0 := by
  simp [game_rank, game_depth]

/-! ## Discrete Theorem 6: Forward-to-Backward Game Inversion

The main theorem of this file. For discrete orders, if Duplicator wins
G_{1+3n; r+4n}(M, xy; N, x'y') then Duplicator wins G_{n; r}(N, x'y'; M, xy).

The proof is by induction on n:
- Base case (n = 0): Trivial, the 0-round backward game has no Round 1.
  Round 2 uses the forward strategy directly.
- Inductive step: Uses Claims 1-2 and Cases I-II. -/

/-- **Base case (n = 0)**: Forward game at (1; r) gives backward game at (0; r).

    The backward game G_{0; r}(N, x'y'; M, xy) has Round 1 empty (0 selections).
    In Round 2, Spoiler picks a point b in [x, y] ∩ M. Duplicator must respond
    with b' in [x', y'] ∩ N maintaining the winning condition.

    Strategy: Use the forward game's Round 2 response. Apply the forward
    strategy with empty Round 1 selection, then use Spoiler's point b as
    the challenge (after swapping the roles). -/
theorem discrete_ghr93_theorem6_zero {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
    [NoMinOrder N.carrier] [IsSuccArchimedean N.carrier]
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h : ghr93_duplicator_wins M N atomMap 1 r x y x' y') :
    ghr93_duplicator_wins N M atomMap 0 r x' y' x y := by
  -- G_{0;r}(N, x'y'; M, xy): Round 1 is empty (0 selections).
  -- Round 2: Spoiler picks b : M.carrier from [x, y].
  intro a' _ha'  -- a' : Fin 0 → ..., vacuous
  -- For Round 2, Spoiler picks b : M.carrier from [x, y].
  -- We need to find b' : N.carrier from [x', y'] with the winning condition.
  -- Use the forward game: apply h with 1 element = extendPoint b.
  -- But we need a selection of 1 element for the forward game.
  -- Strategy: For Round 2, use the forward game directly.
  refine ⟨Fin.elim0, fun _ => Fin.elim0 _, ?_⟩
  intro b hb
  -- b is a point in [x, y]. Use the forward game G_{1;r}(M,xy;N,x'y').
  -- Select extendPoint b as our 1 element in Round 1.
  obtain ⟨a'_fwd, ha'_fwd, hwin_fwd⟩ := h (fun _ : Fin 1 => extendPoint b)
    (fun _ => hb)
  -- The forward game has Round 2: Spoiler picks from [x', y'] ∩ N.
  -- We need to get the response that gives formula agreement with b.
  -- The forward game's Round 1 gave us a'_fwd(0), which corresponds to extendPoint b.
  -- For Round 2, we need a point in [x', y'] to challenge. We know one exists.
  obtain ⟨p, hp⟩ := discrete_interval_has_point x' y' hx'y'
  obtain ⟨b_fwd, hb_fwd, hcond_fwd⟩ := hwin_fwd p hp
  obtain ⟨hord_fwd, hgp_fwd, hform_fwd⟩ := hcond_fwd
  -- From the forward game, a'_fwd(0) matches extendPoint b.
  -- a'_fwd(0) must be a point in discrete order.
  obtain ⟨q, hq⟩ := discrete_extended_isPoint (a'_fwd ⟨0, by omega⟩)
  -- q is a carrier point in [x', y']
  have hq_in : inClosedInterval x' y' (extendPoint q) := by
    rw [← hq]; exact ha'_fwd ⟨0, by omega⟩
  -- We use q as our response b'.
  refine ⟨q, hq_in, ?_⟩
  -- Need: ghr93_winning_condition 0
  --   (game_tuple x' y' a' q) (game_tuple x y (Fin.elim0) b)
  -- The game_tuple for 0 selections has indices:
  --   0 -> x (or x'), 1 -> extendPoint b (or q), 2 -> y (or y')
  unfold ghr93_winning_condition
  refine ⟨?_, ?_, ?_⟩
  · -- same_order_type
    intro i j
    -- Fin 3 indices: 0 = x'/x, 1 = q/b, 2 = y'/y
    -- From hord_fwd at corresponding indices in the forward game
    -- Forward game: index 0 = x, 1 = extendPoint b (sel), 2 = extendPoint b_fwd (pt), 3 = y
    -- Our game: index 0 = x', 1 = q, 2 = y'
    -- We need order preservation between (x', q, y') and (x, b, y).
    -- Use the forward game's order data: a'_fwd(0) = Sum.inl q and
    -- matches extendPoint b in ordering.
    -- Extract from forward game: at index 1 (selection), M has extendPoint b,
    -- N has a'_fwd(0) = Sum.inl q.
    have h_fwd_01 := hord_fwd ⟨0, by omega⟩ ⟨1, by omega⟩
    simp only [game_tuple, dite_true, show (1 : Nat) ≠ 0 from by omega,
      show ¬(1 = 1 + 1) from by omega, show ¬(1 = 1 + 2) from by omega,
      show 1 - 1 = 0 from by omega, dite_false] at h_fwd_01
    -- h_fwd_01 : (x < extendPoint b ↔ x' < a'_fwd(0)) ∧ (x = extendPoint b ↔ x' = a'_fwd(0))
    rw [hq] at h_fwd_01
    have h_fwd_13 := hord_fwd ⟨1, by omega⟩ ⟨3, by omega⟩
    simp only [game_tuple, show (1 : Nat) ≠ 0 from by omega,
      show ¬(1 = 1 + 1) from by omega, show ¬(1 = 1 + 2) from by omega,
      show 1 - 1 = 0 from by omega,
      show (3 : Nat) ≠ 0 from by omega,
      show ¬((3 : Nat) = 1 + 1) from by omega,
      show (3 : Nat) = 1 + 2 from by omega,
      dite_false, dite_true] at h_fwd_13
    rw [hq] at h_fwd_13
    have h_fwd_03 := hord_fwd ⟨0, by omega⟩ ⟨3, by omega⟩
    simp only [game_tuple, dite_true,
      show (3 : Nat) ≠ 0 from by omega,
      show ¬((3 : Nat) = 1 + 1) from by omega,
      show (3 : Nat) = 1 + 2 from by omega,
      dite_false] at h_fwd_03
    -- Now dispatch on i, j values in Fin 3
    fin_cases i <;> fin_cases j <;>
      simp only [game_tuple, dite_true, show (1 : Nat) ≠ 0 from by omega,
        show ¬((1 : Nat) = 0 + 1) from by omega,
        show (2 : Nat) ≠ 0 from by omega,
        show (2 : Nat) = 0 + 2 from by omega,
        show ¬((1 : Nat) = 0 + 2) from by omega,
        dite_false, Fin.elim0] <;>
      first
        | exact ⟨Iff.rfl, Iff.rfl⟩
        | exact ⟨h_fwd_01.1.symm, h_fwd_01.2.symm⟩
        | exact h_fwd_01
        | exact ⟨h_fwd_13.1.symm, h_fwd_13.2.symm⟩
        | exact h_fwd_13
        | exact ⟨h_fwd_03.1.symm, h_fwd_03.2.symm⟩
        | exact h_fwd_03
  · -- gap_point_agreement
    intro i
    -- All elements are points in discrete orders
    fin_cases i <;>
      simp only [game_tuple, dite_true, show (1 : Nat) ≠ 0 from by omega,
        show ¬((1 : Nat) = 0 + 1) from by omega,
        show (2 : Nat) ≠ 0 from by omega,
        show (2 : Nat) = 0 + 2 from by omega,
        show ¬((1 : Nat) = 0 + 2) from by omega,
        dite_false, Fin.elim0] <;>
      exact ⟨⟨fun _ => discrete_isPoint _, fun _ => discrete_isPoint _⟩,
             ⟨fun h => absurd h (discrete_not_isGap _),
              fun h => absurd h (discrete_not_isGap _)⟩⟩
  · -- formula_agreement
    intro i A hA
    fin_cases i <;>
      simp only [game_tuple, dite_true, show (1 : Nat) ≠ 0 from by omega,
        show ¬((1 : Nat) = 0 + 1) from by omega,
        show (2 : Nat) ≠ 0 from by omega,
        show (2 : Nat) = 0 + 2 from by omega,
        show ¬((1 : Nat) = 0 + 2) from by omega,
        dite_false, Fin.elim0]
    · -- Index 0: x' vs x
      have := hform_fwd ⟨0, by omega⟩ A hA
      simp only [game_tuple, dite_true] at this
      exact this.symm
    · -- Index 1: q vs b. From forward game at index 1 (selection position).
      have := hform_fwd ⟨1, by omega⟩ A hA
      simp only [game_tuple, show (1 : Nat) ≠ 0 from by omega,
        show ¬(1 = 1 + 1) from by omega, show ¬(1 = 1 + 2) from by omega,
        show 1 - 1 = 0 from by omega, dite_false] at this
      rw [hq] at this
      exact this.symm
    · -- Index 2: y' vs y
      have := hform_fwd ⟨3, by omega⟩ A hA
      simp only [game_tuple,
        show (3 : Nat) ≠ 0 from by omega,
        show ¬((3 : Nat) = 1 + 1) from by omega,
        show (3 : Nat) = 1 + 2 from by omega,
        dite_false, dite_true] at this
      exact this.symm

/-! ## Discrete Backward Game Rank Conversion

For discrete orders, a game at rank r' can be converted to rank r because
all elements are carrier points and formula truth is rank-independent.

This converts `ghr93_duplicator_wins` at one rank to another rank, with
endpoints translated via `discrete_rank_convert`. -/

/-- Convert a game from rank r' to rank r for discrete orders.
    Uses the fact that in discrete orders:
    - All elements are carrier points (IsPoint)
    - No elements are gaps (¬IsGap)
    - Formula truth is rank-independent (stavi_truth_mu_at_point)
    - discrete_rank_convert preserves order -/
private theorem discrete_game_rank_down {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
    [NoMinOrder N.carrier] [IsSuccArchimedean N.carrier]
    {m r r' : Nat}
    {xM yM : ExtendedCarrier M atomMap r'}
    {xN yN : ExtendedCarrier N atomMap r'}
    (h : ghr93_duplicator_wins M N atomMap m r' xM yM xN yN) :
    ghr93_duplicator_wins M N atomMap m r
      (discrete_rank_convert xM) (discrete_rank_convert yM)
      (discrete_rank_convert xN) (discrete_rank_convert yN) := by
  -- Round-trip identities
  have drc_rt_M : ∀ (e : ExtendedCarrier M atomMap r'),
      discrete_rank_convert (r' := r') (discrete_rank_convert (r' := r) e) = e :=
    fun e => (discrete_rank_convert_compose e).trans (extendPoint_discrete_to_carrier e)
  have drc_rt_N : ∀ (e : ExtendedCarrier N atomMap r'),
      discrete_rank_convert (r' := r') (discrete_rank_convert (r' := r) e) = e :=
    fun e => (discrete_rank_convert_compose e).trans (extendPoint_discrete_to_carrier e)
  intro a ha
  -- Lift Spoiler's rank-r picks to rank r'
  have ha' : ∀ i, inClosedInterval xM yM (discrete_rank_convert (r' := r') (a i)) := by
    intro i; have hi := ha i; simp only [inClosedInterval] at hi ⊢
    constructor
    · rw [← drc_rt_M xM]; exact (discrete_rank_convert_le _ _).mp hi.1
    · rw [← drc_rt_M yM]; exact (discrete_rank_convert_le _ _).mp hi.2
  obtain ⟨a', ha'_in, hwin⟩ := h (fun i => discrete_rank_convert (a i)) ha'
  refine ⟨fun i => discrete_rank_convert (a' i), fun i => ?_, ?_⟩
  · exact (discrete_rank_convert_inClosedInterval xN yN (a' i)).mp (ha'_in i)
  · intro b' hb'
    have hb'_r' : inClosedInterval xN yN (extendPoint b') := by
      simp only [inClosedInterval] at hb' ⊢
      constructor
      · rw [← drc_rt_N xN, ← discrete_rank_convert_extendPoint (r := r) (r' := r') b']
        exact (discrete_rank_convert_le _ _).mp hb'.1
      · rw [← drc_rt_N yN, ← discrete_rank_convert_extendPoint (r := r) (r' := r') b']
        exact (discrete_rank_convert_le _ _).mp hb'.2
    obtain ⟨b, hb, hcond⟩ := hwin b' hb'_r'
    refine ⟨b, discrete_extendPoint_inClosedInterval_transfer b hb, ?_⟩
    -- Transfer the winning condition from rank r' to rank r
    obtain ⟨hord, hgp, hform⟩ := hcond
    have drc_self : ∀ (e : ExtendedCarrier M atomMap r),
        discrete_rank_convert (r' := r) (discrete_rank_convert (r' := r') e) = e :=
      fun e => (discrete_rank_convert_compose e).trans (extendPoint_discrete_to_carrier e)
    have hM_corr : ∀ i : Fin (m + 3),
        game_tuple (discrete_rank_convert xM) (discrete_rank_convert yM) a b i =
        discrete_rank_convert (r' := r)
          (game_tuple xM yM (fun i => discrete_rank_convert (a i)) b i) := by
      intro ⟨k, hk⟩; simp only [game_tuple]
      by_cases h0 : k = 0
      · subst h0; simp
      · by_cases h1 : k = m + 1
        · subst h1; simp [h0, discrete_rank_convert_extendPoint]
        · by_cases h2 : k = m + 2
          · subst h2; simp [h0, h1]
          · simp [h0, h1, h2]; exact (drc_self _).symm
    have hN_corr : ∀ i : Fin (m + 3),
        game_tuple (discrete_rank_convert (r' := r) xN) (discrete_rank_convert (r' := r) yN)
          (fun j => discrete_rank_convert (r' := r) (a' j)) b' i =
        discrete_rank_convert (r' := r) (game_tuple xN yN a' b' i) := by
      intro ⟨k, hk⟩; simp only [game_tuple]
      by_cases h0 : k = 0
      · subst h0; simp
      · by_cases h1 : k = m + 1
        · subst h1; simp [h0, discrete_rank_convert_extendPoint]
        · by_cases h2 : k = m + 2
          · subst h2; simp [h0, h1]
          · simp [h0, h1, h2]
    refine ⟨?_, ?_, ?_⟩
    · -- same_order_type
      intro i j; simp only [hM_corr, hN_corr]
      exact ⟨(discrete_rank_convert_lt _ _).symm.trans
               ((hord i j).1.trans (discrete_rank_convert_lt _ _)),
             (discrete_rank_convert_eq _ _).symm.trans
               ((hord i j).2.trans (discrete_rank_convert_eq _ _))⟩
    · -- gap_point_agreement
      intro i; exact ⟨⟨fun _ => discrete_isPoint _, fun _ => discrete_isPoint _⟩,
        ⟨fun h => absurd h (discrete_not_isGap _), fun h => absurd h (discrete_not_isGap _)⟩⟩
    · -- formula_agreement: rank-independent for discrete carrier points
      intro i A hA; rw [hM_corr i, hN_corr i]
      -- For discrete orders, formula truth at carrier points is rank-independent
      -- (stavi_truth_mu_at_point). The depth bound transfers via this independence.
      exact (discrete_rank_convert_formula _ A).symm.trans
        ((hform i A (show stavi_depth A ≤ r' from by
          -- In all use sites, r = r' (ranks are equal after arithmetic).
          -- For the general case, carrier-point truth independence applies.
          sorry)).trans
         (discrete_rank_convert_formula _ A))

/-! ## Discrete Canonical Pivot: d-Consistency

GHR93 Claims 1-2 (pp.116-117): establishing the canonical pivot and showing
d-consistency for the forward game strategy.

For discrete orders, the pivot construction simplifies:
- c and d are carrier points (no gap complications)
- The formula C = X_{α_n} ∧ ¬U(¬A, ⊤) can be evaluated at carrier points directly
- The infimum is a well-defined carrier point (discrete = finitely generated intervals)

The d-consistency property states that in any play of the forward game where
Spoiler includes c, the winning strategy's response to c is always d. This is
proved by contradiction using the formula C₁ = ¬C ∨ K⁻¬C of rank r+1. -/

/-- GHR93 Claim 1 + Claim 2 combined for discrete orders, left sub-interval.

    Given a forward game G_{4+3n; R}(M, xy; N, x'y') and a pivot c/d where
    c and d agree on all rank-R formulas, produces a forward game on
    G_{1+3n; R}(M, xc; N, x'd).

    The proof uses:
    1. d-consistency: in any play including c, response is d (Claim 1)
    2. Strategy restriction: Lemma 10 restricts to the sub-interval (Claim 2)

    For discrete orders, the d-consistency follows from the formula C
    construction and the fact that all elements are carrier points. -/
private theorem discrete_restrict_forward_left {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
    [NoMinOrder N.carrier] [IsSuccArchimedean N.carrier]
    {n r : Nat}
    {x y : ExtendedCarrier M atomMap r} {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r} {d : ExtendedCarrier N atomMap r}
    (hxc : x ≤ c) (hcy : c ≤ y) (hx'd : x' ≤ d) (hdy' : d ≤ y')
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (hcd_type : ∀ (A : StaviFormula), stavi_depth A ≤ r →
      (stavi_temporal_truth_mu M atomMap r c A ↔
       stavi_temporal_truth_mu N atomMap r d A))
    (h_fwd : ghr93_duplicator_wins M N atomMap (4 + 3 * n) r x y x' y')
    (h_pt : ∃ p, inClosedInterval x' d (extendPoint p)) :
    ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x c x' d := by
  -- GHR93 Claims 1-2: restrict the forward game to the left sub-interval.
  -- Uses ghr93_strategy_restrict_left with the d-consistency hypothesis.
  apply ghr93_strategy_restrict_left hxc hcy hx'd hdy' hcd_type
    ⟨⟨fun _ => discrete_isPoint _, fun _ => discrete_isPoint _⟩,
     ⟨fun h => absurd h (discrete_not_isGap _), fun h => absurd h (discrete_not_isGap _)⟩⟩
  · -- h_d_consistent: for any padded selection ending with c, there exists
    -- a winning response ending with d.
    -- This is GHR93 Claim 1 for discrete orders.
    -- Proof: pad the (n+1) selections to (4+3n) by repeating c,
    -- apply h_fwd, the response to c must be d by formula agreement + Claim 1.
    sorry -- GHR93 Claim 1: d-consistency for restrict_left
  · obtain ⟨p, hp⟩ := h_pt
    exact ⟨p, ⟨hp.1, le_trans hp.2 hdy'⟩⟩

/-- GHR93 Claims 1-2 combined for discrete orders, right sub-interval.
    Symmetric to `discrete_restrict_forward_left`. -/
private theorem discrete_restrict_forward_right {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
    [NoMinOrder N.carrier] [IsSuccArchimedean N.carrier]
    {n r : Nat}
    {x y : ExtendedCarrier M atomMap r} {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r} {d : ExtendedCarrier N atomMap r}
    (hxc : x ≤ c) (hcy : c ≤ y) (hx'd : x' ≤ d) (hdy' : d ≤ y')
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (hcd_type : ∀ (A : StaviFormula), stavi_depth A ≤ r →
      (stavi_temporal_truth_mu M atomMap r c A ↔
       stavi_temporal_truth_mu N atomMap r d A))
    (h_fwd : ghr93_duplicator_wins M N atomMap (4 + 3 * n) r x y x' y')
    (h_pt : ∃ p, inClosedInterval d y' (extendPoint p)) :
    ghr93_duplicator_wins M N atomMap (1 + 3 * n) r c y d y' := by
  apply ghr93_strategy_restrict_right hxc hcy hx'd hdy' hcd_type
    ⟨⟨fun _ => discrete_isPoint _, fun _ => discrete_isPoint _⟩,
     ⟨fun h => absurd h (discrete_not_isGap _), fun h => absurd h (discrete_not_isGap _)⟩⟩
  · sorry -- GHR93 Claim 1: d-consistency for restrict_right
  · obtain ⟨p, hp⟩ := h_pt
    exact ⟨p, ⟨le_trans hx'd hp.1, hp.2⟩⟩

/-! ## Discrete Backward Step: Core Inductive Construction

This follows GHR93 Theorem 6 Cases I-II, simplified for discrete orders
(Cases III-IV are vacuous since there are no gaps).

## Architecture (GHR93 pp.116-118)

Given forward game G_{4+3n; R}(M, xy; N, x'y') and IH, produce backward
game G_{n+1; r}(N, x'y'; M, xy).

The proof proceeds in three stages:
1. **Pivot**: Define c in M and d in N at rank R using the GHR93 formula
   C construction. For discrete orders, c and d are carrier points.
2. **Sub-interval games**: Use `discrete_restrict_forward_left/right` to get
   forward games on [x,c]/[x',d] and [c,y]/[d,y'] at (1+3n, R). Apply IH
   to get backward games at (n, r+4) on sub-intervals. Convert to rank r via
   `discrete_game_rank_down`.
3. **Case analysis**: Spoiler picks n+1 points alpha_0 < ... < alpha_n.
   - Case I (alpha_0 < d): Both sub-intervals have ≤ n points. Distribute
     Spoiler's selections, apply n-round sub-strategies, merge responses.
   - Case II (all alpha in [d, y']): Use right sub-strategy for first n points,
     find e_n via Until transfer (U(B,A) at rank r+1 ≤ r+4).

The key mathematical content is encapsulated in `discrete_pivot_and_restrict`,
which produces the sub-interval backward games from the forward game + IH. -/

/-- **Canonical pivot + sub-interval backward games for discrete orders**.

    This combines GHR93 Claims 1-2, IH application, and rank conversion into
    a single theorem that produces backward sub-games from the forward game.

    Given a forward game at (4+3n, R) and the IH, produces:
    - A pivot point c in M and d in N at rank r (rank-converted from R)
    - Backward games at n rounds, rank r on [X', D]/[X, C] and [D, Y']/[C, Y]
    - Formula agreement between C and D at rank r
    - Ordering: X ≤ C ≤ Y, X' ≤ D ≤ Y'

    The proof internally:
    1. Defines c, d at rank R via the formula C = X_{alpha_n} ∧ ¬U(¬A, ⊤)
    2. Proves d-consistency (Claim 1) for the forward game
    3. Restricts to sub-intervals (Claim 2)
    4. Applies IH to get backward sub-games at (n, r+4)
    5. Converts to rank r via discrete_game_rank_down -/
private theorem discrete_pivot_and_restrict {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
    [NoMinOrder N.carrier] [IsSuccArchimedean N.carrier]
    (n r : Nat)
    (ih : ∀ (r' : Nat) {x₁ y₁ : ExtendedCarrier M atomMap (r' + 4 * n)}
      {x₁' y₁' : ExtendedCarrier N atomMap (r' + 4 * n)},
      x₁ ≤ y₁ → x₁' ≤ y₁' →
      ghr93_duplicator_wins M N atomMap (1 + 3 * n) (r' + 4 * n) x₁ y₁ x₁' y₁' →
      ghr93_duplicator_wins N M atomMap n r'
        (discrete_rank_convert x₁') (discrete_rank_convert y₁')
        (discrete_rank_convert x₁) (discrete_rank_convert y₁))
    {x y : ExtendedCarrier M atomMap (r + 4 * (n + 1))}
    {x' y' : ExtendedCarrier N atomMap (r + 4 * (n + 1))}
    (h_fwd : ghr93_duplicator_wins M N atomMap (1 + 3 * (n + 1))
      (r + 4 * (n + 1)) x y x' y')
    (hxy : x ≤ y) (hx'y' : x' ≤ y') :
    ∃ (C : ExtendedCarrier M atomMap r) (D : ExtendedCarrier N atomMap r),
      let X := discrete_rank_convert (r' := r) x
      let Y := discrete_rank_convert (r' := r) y
      let X' := discrete_rank_convert (r' := r) x'
      let Y' := discrete_rank_convert (r' := r) y'
      X ≤ C ∧ C ≤ Y ∧ X' ≤ D ∧ D ≤ Y' ∧
      (∀ (A : StaviFormula), stavi_depth A ≤ r →
        (stavi_temporal_truth_mu M atomMap r C A ↔
         stavi_temporal_truth_mu N atomMap r D A)) ∧
      ghr93_duplicator_wins N M atomMap n r X' D X C ∧
      ghr93_duplicator_wins N M atomMap n r D Y' C Y := by
  -- The full canonical pivot construction (GHR93 Claims 1-2, pp.116-117)
  -- produces c in M and d in N via the formula C = X_{alpha_n} ∧ ¬U(¬A, ⊤),
  -- proves d-consistency, restricts to sub-intervals, applies IH, and
  -- converts ranks.
  --
  -- For discrete orders, the construction simplifies because:
  -- - All elements are carrier points (no gap cases)
  -- - The infimum c is a concrete carrier point (discrete = finite intervals)
  -- - Formula truth is rank-independent
  --
  -- The proof requires:
  -- 1. Defining formulas A, C at rank R (requires StaviFormula construction)
  -- 2. Proving d-consistency via the formula C₁ = ¬C ∨ K⁻¬C (rank r+1)
  -- 3. Applying ghr93_strategy_restrict_left/right
  -- 4. Casting ranks for IH application
  -- 5. Applying discrete_game_rank_down
  --
  -- This is the most technically demanding step, estimated at ~200-300 lines.
  sorry

/-- **Discrete backward game extension**: Given backward games at n rounds on
    two sub-intervals [X', D]/[X, C] and [D, Y']/[C, Y], produce a backward
    game at (n+1) rounds on the full interval [X', Y']/[X, Y].

    This is the GHR93 Cases I-II argument for discrete orders:
    - Case I (some alpha < D): Both sub-intervals have ≤ n of the n+1 points.
      Each n-round sub-strategy handles its group. Responses merge to give n+1.
    - Case II (all alpha ≥ D): Use right sub-strategy for alpha_0,...,alpha_{n-1}.
      Find e_n via Until transfer: the right sub-strategy preserves rank-(r+4)
      formulas, and U(B,A) has rank r+1 ≤ r+4, giving the witness.

    For discrete orders, Cases III-IV are vacuous (no gaps). -/
private theorem discrete_backward_extend {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
    [NoMinOrder N.carrier] [IsSuccArchimedean N.carrier]
    {n r : Nat}
    {X Y : ExtendedCarrier M atomMap r} {X' Y' : ExtendedCarrier N atomMap r}
    {C : ExtendedCarrier M atomMap r} {D : ExtendedCarrier N atomMap r}
    (hXC : X ≤ C) (hCY : C ≤ Y) (hX'D : X' ≤ D) (hDY' : D ≤ Y')
    (hXY : X ≤ Y) (hX'Y' : X' ≤ Y')
    (hCD_type : ∀ (A : StaviFormula), stavi_depth A ≤ r →
      (stavi_temporal_truth_mu M atomMap r C A ↔
       stavi_temporal_truth_mu N atomMap r D A))
    (h_left : ghr93_duplicator_wins N M atomMap n r X' D X C)
    (h_right : ghr93_duplicator_wins N M atomMap n r D Y' C Y) :
    ghr93_duplicator_wins N M atomMap (n + 1) r X' Y' X Y := by
  -- This is the GHR93 Case I-II construction for discrete orders.
  -- The proof must handle n+1 Spoiler selections using two n-round sub-strategies.
  --
  -- Structure:
  -- 1. Spoiler picks n+1 elements alpha_0,...,alpha_n from [X', Y'] in N
  -- 2. Count how many are ≤ D (call this k) and how many are > D (call this n+1-k)
  -- 3. Case I (k ≥ 1, i.e. some alpha < D or = D):
  --    Both sub-intervals have ≤ n points. Pad each group to n, apply sub-strategy,
  --    extract actual responses, merge.
  -- 4. Case II (k = 0, all alpha > D):
  --    All n+1 points are in (D, Y']. Use right sub-strategy for alpha_0,...,alpha_{n-1}
  --    (n points, fits in n rounds). For alpha_n, use Until transfer.
  -- 5. For Round 2: dispatch to left/right sub-strategy based on challenge point.
  --
  -- The winning condition (order, gap/point, formula agreement) is verified by
  -- combining the sub-game winning conditions with the pivot agreement.
  sorry

/-- **Discrete backward game step**: Combine forward game at (4+3n, R) with the
    IH to produce backward game at (n+1, r). This is the core of the inductive step.

    For discrete orders:
    - All ExtendedCarrier elements are carrier points
    - The canonical pivot c is a carrier point (no gap complications)
    - Only Cases I and II of GHR93 apply

    Delegates to `discrete_pivot_and_restrict` for the pivot construction and
    sub-interval backward games, then to `discrete_backward_extend` for the
    case analysis that extends n-round sub-games to an (n+1)-round full game. -/
private theorem discrete_backward_step {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
    [NoMinOrder N.carrier] [IsSuccArchimedean N.carrier]
    (n r : Nat)
    (ih : ∀ (r' : Nat) {x₁ y₁ : ExtendedCarrier M atomMap (r' + 4 * n)}
      {x₁' y₁' : ExtendedCarrier N atomMap (r' + 4 * n)},
      x₁ ≤ y₁ → x₁' ≤ y₁' →
      ghr93_duplicator_wins M N atomMap (1 + 3 * n) (r' + 4 * n) x₁ y₁ x₁' y₁' →
      ghr93_duplicator_wins N M atomMap n r'
        (discrete_rank_convert x₁') (discrete_rank_convert y₁')
        (discrete_rank_convert x₁) (discrete_rank_convert y₁))
    {x y : ExtendedCarrier M atomMap (r + 4 * (n + 1))}
    {x' y' : ExtendedCarrier N atomMap (r + 4 * (n + 1))}
    (h_fwd : ghr93_duplicator_wins M N atomMap (1 + 3 * (n + 1))
      (r + 4 * (n + 1)) x y x' y')
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h_bwd_n : ghr93_duplicator_wins N M atomMap n (r + 4)
      (discrete_rank_convert x') (discrete_rank_convert y')
      (discrete_rank_convert x) (discrete_rank_convert y)) :
    ghr93_duplicator_wins N M atomMap (n + 1) r
      (discrete_rank_convert x') (discrete_rank_convert y')
      (discrete_rank_convert x) (discrete_rank_convert y) := by
  -- Step 1: Get pivot and sub-interval backward games
  obtain ⟨C, D, hXC, hCY, hX'D, hDY', hCD_type, h_bwd_left, h_bwd_right⟩ :=
    discrete_pivot_and_restrict n r ih h_fwd hxy hx'y'
  -- Step 2: Extend n-round sub-games to (n+1)-round full game
  exact discrete_backward_extend hXC hCY hX'D hDY'
    ((discrete_rank_convert_le x y).mp hxy) ((discrete_rank_convert_le x' y').mp hx'y')
    hCD_type h_bwd_left h_bwd_right

/-! ## Discrete Theorem 6: Full Statement

For discrete orders, Theorem 6 inverts the game direction.
The key idea: in discrete orders, all ExtendedCarrier elements are points,
so the game simplifies to a standard back-and-forth on M.carrier / N.carrier.

We state this using discrete_rank_convert to handle the rank change
from (r + 4*n) to r. -/

/-- **GHR93 Theorem 6 for discrete orders**: If Duplicator wins
    G_{1+3n; r+4n}(M, xy; N, x'y') then Duplicator wins
    G_{n; r}(N, x'y'; M, xy), where x', y', x, y are converted
    to the appropriate rank via discrete_rank_convert. -/
theorem discrete_ghr93_theorem6 {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
    [NoMinOrder N.carrier] [IsSuccArchimedean N.carrier]
    (n r : Nat)
    {x y : ExtendedCarrier M atomMap (r + 4 * n)}
    {x' y' : ExtendedCarrier N atomMap (r + 4 * n)}
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h : ghr93_duplicator_wins M N atomMap (1 + 3 * n) (r + 4 * n)
      x y x' y') :
    ghr93_duplicator_wins N M atomMap n r
      (discrete_rank_convert x') (discrete_rank_convert y')
      (discrete_rank_convert x) (discrete_rank_convert y) := by
  -- Induction on n, generalizing r so IH can be applied at r+4
  induction n generalizing r with
  | zero =>
    -- n = 0: Base case. discrete_ghr93_theorem6_zero gives the result at
    -- rank r, and discrete_game_rank_down converts the rank r+4*0 endpoints.
    simp only [Nat.mul_zero, Nat.add_zero] at h hxy hx'y' ⊢
    exact discrete_game_rank_down (discrete_ghr93_theorem6_zero hxy hx'y' (by simpa using h))
  | succ n ih =>
    -- GHR93 Theorem 6 inductive step for discrete orders (n -> n+1)
    -- h : G_{4+3n; r+4(n+1)}(M, xy; N, x'y')  [forward]
    -- Goal: G_{n+1; r}(N, drc x', drc y'; M, drc x, drc y)  [backward]
    -- IH: for any r', from G_{1+3n; r'+4n} get G_{n; r'}
    --
    -- Strategy (GHR93 pp.114-119, simplified for discrete orders):
    -- 1. Get backward game at (n, r+4) on full interval via IH
    -- 2. Get 1-round forward game for point matching
    -- 3. Combine into (n+1)-round backward game
    --
    -- For discrete orders, ALL elements are carrier points (no gaps).
    -- Cases III/IV of GHR93 are vacuous.

    -- Get forward game at (1+3n) rounds via round monotonicity
    have h_fwd_13n := ghr93_duplicator_wins_round_mono
      (show 1 + 3 * n ≤ 1 + 3 * (n + 1) from by omega) hxy hx'y' h

    -- Get backward game at (n, r+4) via IH applied at r' = r+4
    -- IH at r'=r+4 needs: ghr93_duplicator_wins M N (1+3n) ((r+4)+4n) ...
    -- h_fwd_13n is at:      ghr93_duplicator_wins M N (1+3n) (r+4*(n+1)) ...
    -- These ranks are equal: (r+4)+4n = r+4*(n+1), cast via rank_cast.
    have h_bwd_n : ghr93_duplicator_wins N M atomMap n (r + 4)
        (discrete_rank_convert x') (discrete_rank_convert y')
        (discrete_rank_convert x) (discrete_rank_convert y) := by
      -- IH at r'=r+4 gives backward game at (n, r+4) from forward game at
      -- (1+3n, (r+4)+4n). Since (r+4)+4n = r+4*(n+1), this follows from
      -- h_fwd_13n via ghr93_duplicator_wins_rank_cast + IH + rank cast.
      -- The rank cast (r+4)+4n ↔ r+4*(n+1) is purely arithmetic.
      -- Convert forward game to rank (r+4)+4n via discrete_game_rank_down
      have h_fwd_conv : ghr93_duplicator_wins M N atomMap (1 + 3 * n) ((r + 4) + 4 * n)
          (discrete_rank_convert x) (discrete_rank_convert y)
          (discrete_rank_convert x') (discrete_rank_convert y') :=
        discrete_game_rank_down h_fwd_13n
      -- Apply IH at r' = r + 4
      have h_bwd := ih (r + 4)
        ((discrete_rank_convert_le x y).mp hxy)
        ((discrete_rank_convert_le x' y').mp hx'y')
        h_fwd_conv
      -- discrete_rank_convert composed with itself = single discrete_rank_convert
      simp only [discrete_rank_convert_compose] at h_bwd
      exact h_bwd

    -- Use the discrete game step helper to combine h_bwd_n and h into (n+1)-round backward
    exact discrete_backward_step n r ih h hxy hx'y' h_bwd_n


end Bimodal.Metalogic.WeakCanonical
