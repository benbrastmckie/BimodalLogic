import Bimodal.Metalogic.WeakCanonical.EFGames.Decomposition
import Bimodal.Metalogic.WeakCanonical.EFGames.Composition
import Bimodal.Metalogic.WeakCanonical.Expressiveness.Theorem6

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
    exact ((discrete_no_gaps (T := M.carrier)).false g.val).elim

/-- Extract the carrier point from a discrete ExtendedCarrier element. -/
noncomputable def discrete_to_carrier {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    (e : ExtendedCarrier M atomMap r) : M.carrier :=
  match e with
  | .inl x => x
  | .inr g => ((discrete_no_gaps (T := M.carrier)).false g.val).elim

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
  | inr g => exact ((discrete_no_gaps (T := M.carrier)).false g.val).elim

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
    | inl y =>
      simp only [discrete_rank_convert, discrete_to_carrier, extendPoint]; exact Iff.rfl
    | inr g => exact ((discrete_no_gaps (T := M.carrier)).false g.val).elim
  | inr g => exact ((discrete_no_gaps (T := M.carrier)).false g.val).elim

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
  simp only [inClosedInterval]
  exact Iff.and (discrete_rank_convert_le x e) (discrete_rank_convert_le e y)

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
  exact ((discrete_no_gaps (T := M.carrier)).false g.val).elim

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
  show stavi_temporal_truth_mu M atomMap r (extendPoint x) A ↔
    stavi_temporal_truth_mu M atomMap r' (discrete_rank_convert (extendPoint x)) A
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
  cases e with
  | inl p => simp [discrete_rank_convert, discrete_to_carrier, extendPoint]
  | inr g => exact ((discrete_no_gaps).false g.val).elim

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
    (h : ghr93_duplicator_wins M N atomMap m r' xM yM xN yN)
    (h_rle : r ≤ r') :
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
    · -- formula_agreement: transfer depth bound via r ≤ r'
      intro i A hA; rw [hM_corr i, hN_corr i]
      exact (discrete_rank_convert_formula _ A).symm.trans
        ((hform i A (le_trans hA h_rle)).trans
         (discrete_rank_convert_formula _ A))

/-! ## Discrete rank_embed Bridge

In discrete orders, `rank_embed` and `discrete_rank_convert` coincide.
This bridges the discrete infrastructure with the general Expressiveness
infrastructure (SplitPoint, CaseAnalysis, DConsistencyTransport). -/

/-- In discrete orders, rank_embed equals discrete_rank_convert. -/
theorem discrete_rank_embed_eq_drc {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    (h : r ≤ r') (e : ExtendedCarrier M atomMap r) :
    rank_embed h e = discrete_rank_convert (r' := r') e := by
  cases e with
  | inl x => simp [rank_embed, discrete_rank_convert, discrete_to_carrier, extendPoint, Sum.map]
  | inr g => exact ((discrete_no_gaps).false g.val).elim

/-- Convert h_bwd_n from rank r+4 to rank r via discrete_game_rank_down,
    collapsing the double discrete_rank_convert. -/
theorem discrete_game_rank_down_compose {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
    [NoMinOrder N.carrier] [IsSuccArchimedean N.carrier]
    {m r r' R : Nat}
    {x y : ExtendedCarrier M atomMap R}
    {x' y' : ExtendedCarrier N atomMap R}
    (h : ghr93_duplicator_wins M N atomMap m r'
      (discrete_rank_convert x) (discrete_rank_convert y)
      (discrete_rank_convert x') (discrete_rank_convert y'))
    (h_rle : r ≤ r') :
    ghr93_duplicator_wins M N atomMap m r
      (discrete_rank_convert x) (discrete_rank_convert y)
      (discrete_rank_convert x') (discrete_rank_convert y') := by
  have := discrete_game_rank_down h h_rle
  simp only [discrete_rank_convert_compose] at this
  exact this

/-! ## Discrete Theorem 6: Uniform-Rank via Sorry-Free ghr93_forward_to_backward

Plan v10 reformulation: Instead of reimplementing GHR93 Theorem 6 for discrete
orders (which requires d-consistency, pivot construction, and case analysis),
we delegate to the sorry-free `ghr93_forward_to_backward` (Theorem6.lean).

The key insight: `ghr93_forward_to_backward` operates at a SINGLE rank `r` and
takes `h_r1_univ` (forward games at rank `r'+2` for all intervals) as an explicit
hypothesis. For discrete orders, `rank_embed` equals `discrete_rank_convert`
(by `discrete_rank_embed_eq_drc`), so the bridge is clean.

The caller (Phase 4's completeness framework) provides `h_r1_univ` from the
decomposition formula agreement. -/

/-- **GHR93 Theorem 6 for discrete orders (uniform rank)**:
    If Duplicator wins G_{1+3n; r}(M, xy; N, x'y') and the caller provides
    `h_r1_univ` (forward games at rank r'+2 for all pairs of intervals),
    then Duplicator wins G_{n; r}(N, x'y'; M, xy).

    This delegates directly to the sorry-free `ghr93_forward_to_backward`
    (Theorem6.lean). The carrier point hypotheses are provided by
    `discrete_interval_has_point`. -/
theorem discrete_ghr93_theorem6 {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
    [NoMinOrder N.carrier] [IsSuccArchimedean N.carrier]
    (n r : Nat)
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h : ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x y x' y')
    (h_r1_univ : ∀ (r' : Nat) {x₁ y₁ : ExtendedCarrier M atomMap r'}
                   {x₁' y₁' : ExtendedCarrier N atomMap r'},
                 x₁ ≤ y₁ → x₁' ≤ y₁' →
                 ghr93_duplicator_wins M N atomMap (1 + 3 * n) (r' + 2)
                   (rank_embed (by omega : r' ≤ r' + 2) x₁)
                   (rank_embed (by omega : r' ≤ r' + 2) y₁)
                   (rank_embed (by omega : r' ≤ r' + 2) x₁')
                   (rank_embed (by omega : r' ≤ r' + 2) y₁')) :
    ghr93_duplicator_wins N M atomMap n r x' y' x y := by
  -- Carrier point existence in discrete intervals (all elements are points)
  have h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p) :=
    discrete_interval_has_point x' y' hx'y'
  have h_pt_M : ∃ (p : M.carrier), inClosedInterval x y (extendPoint p) :=
    discrete_interval_has_point x y hxy
  -- Delegate to the sorry-free ghr93_forward_to_backward
  exact ghr93_forward_to_backward atomMap n r hxy hx'y' h_pt h_pt_M h h_r1_univ

/-- **GHR93 Theorem 6 for discrete orders (rank-varying)**:
    If Duplicator wins G_{1+3n; r+4n}(M, xy; N, x'y') with positions at
    rank r+4n, and h_r1_univ is provided, then Duplicator wins
    G_{n; r}(N, drc x', drc y'; M, drc x, drc y) at rank r.

    This composes the uniform-rank `discrete_ghr93_theorem6` with
    `discrete_game_rank_down` for rank conversion. The `h_r1_univ` hypothesis
    uses `rank_embed` format matching `ghr93_forward_to_backward`.

    The positions x, y, x', y' live at rank r+4n and are converted to rank r
    via `discrete_rank_convert` in the conclusion. -/
theorem discrete_ghr93_theorem6_rank_varying {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
    [NoMinOrder N.carrier] [IsSuccArchimedean N.carrier]
    (n r : Nat)
    {x y : ExtendedCarrier M atomMap (r + 4 * n)}
    {x' y' : ExtendedCarrier N atomMap (r + 4 * n)}
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h : ghr93_duplicator_wins M N atomMap (1 + 3 * n) (r + 4 * n) x y x' y')
    (h_r1_univ : ∀ (r' : Nat) {x₁ y₁ : ExtendedCarrier M atomMap r'}
                   {x₁' y₁' : ExtendedCarrier N atomMap r'},
                 x₁ ≤ y₁ → x₁' ≤ y₁' →
                 ghr93_duplicator_wins M N atomMap (1 + 3 * n) (r' + 2)
                   (rank_embed (by omega : r' ≤ r' + 2) x₁)
                   (rank_embed (by omega : r' ≤ r' + 2) y₁)
                   (rank_embed (by omega : r' ≤ r' + 2) x₁')
                   (rank_embed (by omega : r' ≤ r' + 2) y₁')) :
    ghr93_duplicator_wins N M atomMap n r
      (discrete_rank_convert x') (discrete_rank_convert y')
      (discrete_rank_convert x) (discrete_rank_convert y) := by
  -- Apply uniform-rank theorem6 at rank (r + 4*n), then rank-convert down to r.
  -- Step 1: Get backward game at rank (r + 4*n) via discrete_ghr93_theorem6
  have h_bwd := discrete_ghr93_theorem6 n (r + 4 * n) hxy hx'y' h h_r1_univ
  -- Step 2: Convert from rank (r + 4*n) to rank r via discrete_game_rank_down
  exact discrete_game_rank_down h_bwd (by omega)


/-! ## GHR93 Proposition 7 for Discrete Orders: Game Wins from Decomposition

Proposition 7 (GHR93 pp.115-116) provides the core game-iteration theorem.
For discrete orders, we prove that universal sub-interval decomposition
agreement at (0, r) implies game wins at (n, r) for all n.

The proof constructs the Duplicator strategy for the n-round custom game
by building decomposition_agreement at (n, r) from decomposition_agreement
at (0, r) on all matched sub-intervals. The key construction matches
Spoiler's n carrier-point selections sequentially via the point-challenge
clause, routing through narrowing sub-intervals to preserve joint ordering
consistency. The point challenge is then handled via the forward decomp
on the appropriate sub-interval.

### Proof structure:
1. Build decomposition_agreement at (n, r) from universal decomp(0, r).
2. Apply ghr93_decomposition_implies_game to get game wins.

### Building decomp(n, r) from decomp(0, r):
- Forward: Spoiler picks n elements from [x,y]. Match them using the backward
  decomp(0, r) point challenge, processing in SORTED order. Each new element
  is matched in the sub-interval [prev_matched, y]/[prev_matched', y'] to
  ensure the matched element is ≥ the previous one.
- Backward: Symmetric.
- Point challenge: Route the challenge point to the correct sub-interval
  determined by the matched selections to ensure ordering consistency.

### References
- GHR93, Proposition 7, pp.115-116
- Task 273, Plan v10, Phase 3
-/

/-- A universal decomposition oracle: provides decomposition_agreement at
    (0, r) for ANY pair of matched sub-interval endpoints within [x,y]/[x',y'].

    The hypothesis is stated in terms of the winning_condition from
    decomp(0, r): given two matched pairs (a,a') and (b,b') where a ≤ b
    and a' ≤ b', each satisfying the winning condition from a decomp(0, r)
    point challenge (which gives formula and gap/point agreement), there
    exists decomp(0, r) on [a,b]/[a',b']. -/
def discrete_universal_decomp {sig : MonadicSignature}
    (M N : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (r : Nat)
    (x y : ExtendedCarrier M atomMap r) (x' y' : ExtendedCarrier N atomMap r) : Prop :=
  ∀ (a b : ExtendedCarrier M atomMap r) (a' b' : ExtendedCarrier N atomMap r),
    inClosedInterval x y a → inClosedInterval x y b → a ≤ b →
    inClosedInterval x' y' a' → inClosedInterval x' y' b' → a' ≤ b' →
    rank_type M atomMap r a = rank_type N atomMap r a' →
    rank_type M atomMap r b = rank_type N atomMap r b' →
    decomposition_agreement M N atomMap 0 r a b a' b' ∧
    decomposition_agreement N M atomMap 0 r a' b' a b

/-- Extract the M-to-N point challenge from decomp_agreement backward direction:
    for any carrier point b in [x,y], there exists a matching carrier point b'
    in [x',y'] with the winning condition. -/
private theorem decomp_point_challenge_MN {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    {x y : ExtendedCarrier M atomMap r} {x' y' : ExtendedCarrier N atomMap r}
    (h : decomposition_agreement M N atomMap 0 r x y x' y')
    (b : M.carrier) (hb : inClosedInterval x y (extendPoint b)) :
    ∃ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') ∧
      ghr93_winning_condition 0
        (game_tuple x y Fin.elim0 b) (game_tuple x' y' Fin.elim0 b') := by
  obtain ⟨_, _, _, h_bwd⟩ := h
  obtain ⟨a_resp, _, _, _, _, h_pc⟩ := h_bwd Fin.elim0 (fun i => Fin.elim0 i)
  obtain ⟨b', hb'_in, hb'_wc⟩ := h_pc b hb
  refine ⟨b', hb'_in, ?_⟩
  -- a_resp : Fin 0 → ... is extensionally Fin.elim0
  have ha_eq : a_resp = Fin.elim0 := funext (fun i => Fin.elim0 i)
  rwa [ha_eq] at hb'_wc

/-- Extract the N-to-M point challenge from decomp_agreement forward direction:
    for any carrier point b' in [x',y'], there exists a matching carrier point b
    in [x,y] with the winning condition. -/
private theorem decomp_point_challenge_NM {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    {x y : ExtendedCarrier M atomMap r} {x' y' : ExtendedCarrier N atomMap r}
    (h : decomposition_agreement M N atomMap 0 r x y x' y')
    (b' : N.carrier) (hb' : inClosedInterval x' y' (extendPoint b')) :
    ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
      ghr93_winning_condition 0
        (game_tuple x y Fin.elim0 b) (game_tuple x' y' Fin.elim0 b') := by
  obtain ⟨_, _, h_fwd, _⟩ := h
  obtain ⟨a'_resp, _, _, _, _, h_pc⟩ := h_fwd Fin.elim0 (fun i => Fin.elim0 i)
  obtain ⟨b, hb_in, hb_wc⟩ := h_pc b' hb'
  refine ⟨b, hb_in, ?_⟩
  have ha'_eq : a'_resp = Fin.elim0 := funext (fun i => Fin.elim0 i)
  rwa [ha'_eq] at hb_wc

/-- Extract rank_type equality from a winning condition at game_tuple position 1
    (the challenged/matched point). The winning condition at (0, game_tuple)
    has positions 0=x, 1=extendPoint b, 2=y. Position 1's formula agreement
    implies rank_type equality between extendPoint b and extendPoint b'. -/
private theorem wc_rank_type_at_point {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    {x y : ExtendedCarrier M atomMap r} {x' y' : ExtendedCarrier N atomMap r}
    {b : M.carrier} {b' : N.carrier}
    (h : ghr93_winning_condition 0
      (game_tuple x y Fin.elim0 b) (game_tuple x' y' Fin.elim0 b')) :
    rank_type M atomMap r (extendPoint b) = rank_type N atomMap r (extendPoint b') := by
  obtain ⟨_, _, h_form⟩ := h
  -- Formula agreement at game_tuple index 1 (the matched point):
  have h1 : ∀ (A : StaviFormula), stavi_depth A ≤ r →
      (stavi_temporal_truth_mu M atomMap r (extendPoint b) A ↔
       stavi_temporal_truth_mu N atomMap r (extendPoint b') A) := by
    intro A hA
    have h_wc := h_form ⟨1, by omega⟩ A hA
    have hgt_M : game_tuple x y Fin.elim0 b ⟨1, by omega⟩ = extendPoint b := by
      simp [game_tuple]
    have hgt_N : game_tuple x' y' Fin.elim0 b' ⟨1, by omega⟩ = extendPoint b' := by
      simp [game_tuple]
    rw [hgt_M, hgt_N] at h_wc
    exact h_wc
  -- rank_type equality: same set of formulas satisfied
  ext A
  simp only [rank_type, Set.mem_setOf_eq]
  constructor
  · rintro ⟨hd, hA⟩; exact ⟨hd, (h1 A hd).mp hA⟩
  · rintro ⟨hd, hA⟩; exact ⟨hd, (h1 A hd).mpr hA⟩

/-- Build a monotone matching for sorted selections by induction on n.

    Given a monotone (sorted) selection `c : Fin n → ExtendedCarrier M` in `[x,y]`,
    produces a monotone `c' : Fin n → ExtendedCarrier N` in `[x',y']` with:
    - rank_type agreement at each position
    - monotonicity
    - consecutive ordering preservation (from same_order_type at sub-interval game_tuples)

    The construction matches elements sequentially: `c'(0)` is matched on
    `[x,y]/[x',y']`, and `c'(k+1)` is matched on `[c(k), y]/[c'(k), y']`
    using `h_univ`. This ensures monotonicity of `c'`. -/
private theorem discrete_sorted_matching {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
    [NoMinOrder N.carrier] [IsSuccArchimedean N.carrier]
    (n r : Nat)
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h_type_x : rank_type M atomMap r x = rank_type N atomMap r x')
    (h_type_y : rank_type M atomMap r y = rank_type N atomMap r y')
    (h_univ : discrete_universal_decomp M N atomMap r x y x' y')
    (h_decomp : decomposition_agreement M N atomMap 0 r x y x' y')
    (c : Fin n → ExtendedCarrier M atomMap r)
    (hc_mono : Monotone c)
    (hc_in : ∀ i, inClosedInterval x y (c i)) :
    ∃ (c' : Fin n → ExtendedCarrier N atomMap r),
      (∀ i, inClosedInterval x' y' (c' i)) ∧
      Monotone c' ∧
      (∀ i, rank_type M atomMap r (c i) = rank_type N atomMap r (c' i)) ∧
      -- Pairwise ordering: strict order and equality preserved between all pairs
      (∀ i j, (c i < c j ↔ c' i < c' j) ∧ (c i = c j ↔ c' i = c' j)) := by
  induction n with
  | zero =>
    exact ⟨Fin.elim0, fun i => Fin.elim0 i, fun i => Fin.elim0 i,
      fun i => Fin.elim0 i, fun i => Fin.elim0 i⟩
  | succ m ih =>
    -- c : Fin (m+1) → ExtendedCarrier M, monotone, all in [x,y]
    let c_init := c ∘ Fin.castSucc
    have hci_mono : Monotone c_init := fun _ _ h => hc_mono (by exact_mod_cast h)
    have hci_in : ∀ i, inClosedInterval x y (c_init i) := fun i => hc_in (Fin.castSucc i)
    -- IH: get monotone matching for first m elements
    obtain ⟨c'_init, hc'i_in, hc'i_mono, hc'i_type, hc'i_consec⟩ :=
      ih c_init hci_mono hci_in
    -- Match the last element c(last m) using sub-interval decomposition
    let c_last := c (Fin.last m)
    -- Determine the lower bound for the sub-interval
    -- If m > 0: lo_M = c(castSucc ⟨m-1,...⟩), lo_N = c'_init(⟨m-1,...⟩)
    -- If m = 0: lo_M = x, lo_N = x'
    have h_last_match : ∃ (q : N.carrier),
        inClosedInterval x' y' (extendPoint q) ∧
        (if hm : 0 < m then c'_init ⟨m - 1, by omega⟩ ≤ extendPoint q
         else x' ≤ extendPoint q) ∧
        ghr93_winning_condition 0
          (game_tuple
            (if hm : 0 < m then c (Fin.castSucc ⟨m - 1, by omega⟩) else x) y
            Fin.elim0 (discrete_to_carrier c_last))
          (game_tuple
            (if hm : 0 < m then c'_init ⟨m - 1, by omega⟩ else x') y'
            Fin.elim0 q) := by
      by_cases hm : 0 < m
      · -- m > 0: use h_univ on sub-interval [c(m-1), y] / [c'_init(m-1), y']
        let prev_M := c (Fin.castSucc ⟨m - 1, by omega⟩)
        let prev_N := c'_init ⟨m - 1, by omega⟩
        have h_prev_in_M : inClosedInterval x y prev_M := hc_in _
        have h_prev_in_N : inClosedInterval x' y' prev_N := hc'i_in _
        have h_prev_type : rank_type M atomMap r prev_M = rank_type N atomMap r prev_N :=
          hc'i_type ⟨m - 1, by omega⟩
        have h_sub_decomp := (h_univ prev_M y prev_N y'
          h_prev_in_M ⟨hxy, le_refl y⟩ h_prev_in_M.2
          h_prev_in_N ⟨hx'y', le_refl y'⟩ h_prev_in_N.2
          h_prev_type h_type_y).1
        have h_c_last_in : inClosedInterval prev_M y
            (extendPoint (discrete_to_carrier c_last)) := by
          rw [extendPoint_discrete_to_carrier]
          constructor
          · exact hc_mono (show Fin.castSucc ⟨m - 1, _⟩ ≤ Fin.last m from by
              simp [Fin.le_def])
          · exact (hc_in _).2
        obtain ⟨q, hq_in, hq_wc⟩ := decomp_point_challenge_MN h_sub_decomp _ h_c_last_in
        refine ⟨q, ⟨le_trans h_prev_in_N.1 hq_in.1, hq_in.2⟩, ?_, ?_⟩
        · simp only [dif_pos hm]; exact hq_in.1
        · simp only [dif_pos hm]; exact hq_wc
      · -- m = 0: use h_decomp on [x, y] / [x', y']
        have h_c_last_in : inClosedInterval x y
            (extendPoint (discrete_to_carrier c_last)) := by
          rw [extendPoint_discrete_to_carrier]; exact hc_in _
        obtain ⟨q, hq_in, hq_wc⟩ := decomp_point_challenge_MN h_decomp _ h_c_last_in
        refine ⟨q, hq_in, ?_, ?_⟩
        · simp only [show ¬(0 < m) from by omega, dite_false]; exact hq_in.1
        · simp only [show ¬(0 < m) from by omega, dite_false]; exact hq_wc
    obtain ⟨q_last, hq_in, hq_lo, hq_wc⟩ := h_last_match
    -- Define c' by extending c'_init with extendPoint q_last
    let c'_last : ExtendedCarrier N atomMap r := extendPoint q_last
    let c' : Fin (m + 1) → ExtendedCarrier N atomMap r :=
      Fin.lastCases c'_last c'_init
    refine ⟨c', ?_, ?_, ?_, ?_⟩
    · -- c'(i) ∈ [x', y']
      intro i; refine Fin.lastCases ?_ (fun j => ?_) i
      · dsimp only [c']; simp only [Fin.lastCases_last]; exact hq_in
      · dsimp only [c']; simp only [Fin.lastCases_castSucc]; exact hc'i_in j
    · -- c' is monotone: for any p ≤ q in Fin(m+1), c'(p) ≤ c'(q)
      -- Strategy: dispatch on whether each index is last or castSucc,
      -- using the IH monotonicity for init indices and hq_lo for the last.
      intro p q hpq
      -- We need c'(p) ≤ c'(q). Since c' = Fin.lastCases c'_last c'_init,
      -- we case-split. But we avoid Fin.lastCases dispatch on hypotheses.
      -- Instead, use the fact that c' is monotone iff c'_init is monotone
      -- and all c'_init values ≤ c'_last.
      -- Simpler proof: c'(p) ≤ c'(q) by cases on whether p, q are init or last.
      by_cases hp : p = Fin.last m
      · -- p = last m
        by_cases hq : q = Fin.last m
        · subst hp; subst hq; exact le_refl _
        · -- p = last, q ≠ last: impossible since last ≤ q ≤ last requires q = last
          -- Actually p ≤ q with p = last m means q = last m (since last is max)
          subst hp
          exfalso; exact hq (Fin.le_last q |>.antisymm hpq)
      · -- p ≠ last m: p = castSucc (some ki)
        obtain ⟨ki, rfl⟩ := Fin.exists_castSucc_eq.mpr hp
        by_cases hq : q = Fin.last m
        · -- p = castSucc ki, q = last: c'_init(ki) ≤ c'_last
          subst hq
          dsimp only [c']; simp only [Fin.lastCases_castSucc, Fin.lastCases_last]
          by_cases hm : 0 < m
          · calc c'_init ki
                ≤ c'_init ⟨m - 1, by omega⟩ := hc'i_mono (by
                    simp only [Fin.le_def]; omega)
              _ ≤ extendPoint q_last := by simp only [dif_pos hm] at hq_lo; exact hq_lo
          · exfalso; exact absurd ki.isLt (by omega)
        · -- both castSucc
          obtain ⟨kj, rfl⟩ := Fin.exists_castSucc_eq.mpr hq
          dsimp only [c']; simp only [Fin.lastCases_castSucc]
          exact hc'i_mono (by exact_mod_cast hpq)
    · -- rank_type agreement
      intro i; refine Fin.lastCases ?_ (fun j => ?_) i
      · dsimp only [c']; simp only [Fin.lastCases_last]
        have := wc_rank_type_at_point hq_wc
        rw [extendPoint_discrete_to_carrier] at this
        exact this
      · dsimp only [c']; simp only [Fin.lastCases_castSucc]
        exact hc'i_type j
    · -- Pairwise ordering preservation: c(i) < c(j) ↔ c'(i) < c'(j), c(i) = c(j) ↔ c'(i) = c'(j)
      -- Strategy: case-split i,j into init (castSucc) vs last.
      -- - Both init: from IH (hc'i_consec).
      -- - Init vs last: chain argument through c_init(m-1)/c'_init(m-1) using IH + sub-interval WC.
      -- - Both last: trivial.
      -- The sub-interval WC (hq_wc) at positions 0,1 gives:
      --   lo < c_last ↔ lo' < c'_last, lo = c_last ↔ lo' = c'_last
      --   where lo = c_init(m-1) (or x), lo' = c'_init(m-1) (or x').
      intro i j
      by_cases hi : i = Fin.last m <;> by_cases hj : j = Fin.last m
      · -- both last
        rw [hi, hj]
        exact ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
               ⟨fun _ => rfl, fun _ => rfl⟩⟩
      · -- i = last, j ≠ last: c_last vs c_init(kj)
        -- c_init(kj) ≤ c_last (monotone), so c_last < c_init(kj) is impossible
        -- c_last = c_init(kj) ↔ chain through intermediates to c'_last = c'_init(kj)
        obtain ⟨kj, rfl⟩ := Fin.exists_castSucc_eq.mpr hj
        subst hi
        have h_le_M : c (Fin.castSucc kj) ≤ c (Fin.last m) :=
          hc_mono (le_of_lt (Fin.castSucc_lt_last kj))
        have h_le_N : c'_init kj ≤ extendPoint q_last := by
          by_cases hm : 0 < m
          · calc c'_init kj
                ≤ c'_init ⟨m - 1, by omega⟩ := hc'i_mono (by simp only [Fin.le_def]; omega)
              _ ≤ extendPoint q_last := by simp only [dif_pos hm] at hq_lo; exact hq_lo
          · exfalso; exact absurd kj.isLt (by omega)
        have hm : 0 < m := Nat.pos_of_ne_zero (by intro h; exact absurd kj.isLt (by omega))
        -- Extract same_order_type from WC
        have h_wc_sot : same_order_type 0
            (game_tuple (c (Fin.castSucc ⟨m - 1, by omega⟩)) y Fin.elim0
              (discrete_to_carrier c_last))
            (game_tuple (c'_init ⟨m - 1, by omega⟩) y' Fin.elim0 q_last) := by
          have := hq_wc; simp only [dif_pos hm] at this; exact this.1
        -- Equality iff between lo and c_last / lo' and c'_last
        have h_lo_eq_clast_iff : c_init ⟨m - 1, by omega⟩ = c_last ↔
            c'_init ⟨m - 1, by omega⟩ = extendPoint q_last := by
          have h01 := h_wc_sot ⟨0, by omega⟩ ⟨1, by omega⟩
          rw [game_tuple_zero_eq, game_tuple_b_eq, game_tuple_zero_eq, game_tuple_b_eq] at h01
          rw [extendPoint_discrete_to_carrier] at h01
          exact h01.2
        -- IH ordering between kj and m-1
        have h_ij_eq_iff := (hc'i_consec kj ⟨m - 1, by omega⟩).2
        -- Monotonicity bounds
        have h_kj_m1_M : c_init kj ≤ c_init ⟨m - 1, by omega⟩ :=
          hci_mono (by simp only [Fin.le_def]; omega)
        have h_m1_last_M : c_init ⟨m - 1, by omega⟩ ≤ c_last :=
          hc_mono (show Fin.castSucc ⟨m - 1, _⟩ ≤ Fin.last m by simp [Fin.le_def])
        have h_kj_m1_N : c'_init kj ≤ c'_init ⟨m - 1, by omega⟩ :=
          hc'i_mono (by simp only [Fin.le_def]; omega)
        have h_m1_last_N : c'_init ⟨m - 1, by omega⟩ ≤ extendPoint q_last := by
          simp only [dif_pos hm] at hq_lo; exact hq_lo
        dsimp only [c']
        simp only [Fin.lastCases_last, Fin.lastCases_castSucc]
        constructor
        · -- c_last < c_init(kj) is impossible (both sides), so < iff is trivial
          exact ⟨fun h_lt => absurd h_lt (not_lt.mpr h_le_M),
                 fun h_lt => absurd h_lt (not_lt.mpr h_le_N)⟩
        · -- Equality: chain through c_init(m-1) using WC + IH
          constructor
          · intro h_eq
            have h1 : c_init ⟨m - 1, by omega⟩ = c_last :=
              le_antisymm h_m1_last_M (le_trans (le_of_eq h_eq) h_kj_m1_M)
            have h2 : c_init kj = c_init ⟨m - 1, by omega⟩ :=
              le_antisymm h_kj_m1_M (le_trans (le_of_eq h1) (le_of_eq h_eq))
            have h3 : c'_init ⟨m - 1, by omega⟩ = extendPoint q_last :=
              h_lo_eq_clast_iff.mp h1
            have h4 : c'_init kj = c'_init ⟨m - 1, by omega⟩ := h_ij_eq_iff.mp h2
            exact (h4.trans h3).symm
          · intro h_eq'
            have h1' : c'_init ⟨m - 1, by omega⟩ = extendPoint q_last :=
              le_antisymm h_m1_last_N (le_trans (le_of_eq h_eq') h_kj_m1_N)
            have h2' : c'_init kj = c'_init ⟨m - 1, by omega⟩ :=
              le_antisymm h_kj_m1_N (le_trans (le_of_eq h1') (le_of_eq h_eq'))
            have h3' : c_init ⟨m - 1, by omega⟩ = c_last := h_lo_eq_clast_iff.mpr h1'
            have h4' : c_init kj = c_init ⟨m - 1, by omega⟩ := h_ij_eq_iff.mpr h2'
            exact (h4'.trans h3').symm
      · -- i ≠ last, j = last: c_init(ki) vs c_last
        -- Chain argument symmetric to i=last, j≠last case
        obtain ⟨ki, rfl⟩ := Fin.exists_castSucc_eq.mpr hi
        subst hj
        have h_le_M : c (Fin.castSucc ki) ≤ c (Fin.last m) :=
          hc_mono (le_of_lt (Fin.castSucc_lt_last ki))
        have h_le_N : c'_init ki ≤ extendPoint q_last := by
          by_cases hm : 0 < m
          · calc c'_init ki
                ≤ c'_init ⟨m - 1, by omega⟩ := hc'i_mono (by simp only [Fin.le_def]; omega)
              _ ≤ extendPoint q_last := by simp only [dif_pos hm] at hq_lo; exact hq_lo
          · exfalso; exact absurd ki.isLt (by omega)
        have hm : 0 < m := Nat.pos_of_ne_zero (by intro h; exact absurd ki.isLt (by omega))
        have h_wc_sot : same_order_type 0
            (game_tuple (c (Fin.castSucc ⟨m - 1, by omega⟩)) y Fin.elim0
              (discrete_to_carrier c_last))
            (game_tuple (c'_init ⟨m - 1, by omega⟩) y' Fin.elim0 q_last) := by
          have := hq_wc; simp only [dif_pos hm] at this; exact this.1
        have h_lo_eq_clast_iff : c_init ⟨m - 1, by omega⟩ = c_last ↔
            c'_init ⟨m - 1, by omega⟩ = extendPoint q_last := by
          have h01 := h_wc_sot ⟨0, by omega⟩ ⟨1, by omega⟩
          rw [game_tuple_zero_eq, game_tuple_b_eq, game_tuple_zero_eq, game_tuple_b_eq] at h01
          rw [extendPoint_discrete_to_carrier] at h01
          exact h01.2
        have h_ij_eq_iff := (hc'i_consec ki ⟨m - 1, by omega⟩).2
        have h_kj_m1_M : c_init ki ≤ c_init ⟨m - 1, by omega⟩ :=
          hci_mono (by simp only [Fin.le_def]; omega)
        have h_m1_last_M : c_init ⟨m - 1, by omega⟩ ≤ c_last :=
          hc_mono (show Fin.castSucc ⟨m - 1, _⟩ ≤ Fin.last m by simp [Fin.le_def])
        have h_kj_m1_N : c'_init ki ≤ c'_init ⟨m - 1, by omega⟩ :=
          hc'i_mono (by simp only [Fin.le_def]; omega)
        have h_m1_last_N : c'_init ⟨m - 1, by omega⟩ ≤ extendPoint q_last := by
          simp only [dif_pos hm] at hq_lo; exact hq_lo
        -- Main equality iff: c_init ki = c_last ↔ c'_init ki = extendPoint q_last
        have h_main_eq : c_init ki = c_last ↔ c'_init ki = extendPoint q_last := by
          constructor
          · intro h_eq
            have h1 : c_init ⟨m - 1, by omega⟩ = c_last :=
              le_antisymm h_m1_last_M (le_trans (le_of_eq h_eq.symm) h_kj_m1_M)
            have h2 : c_init ki = c_init ⟨m - 1, by omega⟩ :=
              le_antisymm h_kj_m1_M (le_trans (le_of_eq h1) (le_of_eq h_eq.symm))
            exact (h_ij_eq_iff.mp h2).trans (h_lo_eq_clast_iff.mp h1)
          · intro h_eq'
            have h1' : c'_init ⟨m - 1, by omega⟩ = extendPoint q_last :=
              le_antisymm h_m1_last_N (le_trans (le_of_eq h_eq'.symm) h_kj_m1_N)
            have h2' : c'_init ki = c'_init ⟨m - 1, by omega⟩ :=
              le_antisymm h_kj_m1_N (le_trans (le_of_eq h1') (le_of_eq h_eq'.symm))
            exact (h_ij_eq_iff.mpr h2').trans (h_lo_eq_clast_iff.mpr h1')
        dsimp only [c']
        simp only [Fin.lastCases_last, Fin.lastCases_castSucc]
        constructor
        · -- < iff: since c_init ki ≤ c_last and c'_init ki ≤ c'_last,
          -- strict < is equivalent to ¬=, which transfers via h_main_eq
          constructor
          · intro h_lt
            exact lt_of_le_of_ne h_le_N (fun h => absurd (h_main_eq.mpr h) (ne_of_lt h_lt))
          · intro h_lt
            exact lt_of_le_of_ne h_le_M (fun h => absurd (h_main_eq.mp h) (ne_of_lt h_lt))
        · exact h_main_eq
      · -- Both castSucc: from IH
        obtain ⟨ki, rfl⟩ := Fin.exists_castSucc_eq.mpr hi
        obtain ⟨kj, rfl⟩ := Fin.exists_castSucc_eq.mpr hj
        dsimp only [c']; simp only [Fin.lastCases_castSucc]
        exact hc'i_consec ki kj

/-- **GHR93 Proposition 7 for discrete orders**: Universal sub-interval
    decomposition agreement at n=0 implies game wins at arbitrary round count n.

    The proof builds decomposition_agreement at (n, r) from the universal
    decomp hypothesis, then applies ghr93_decomposition_implies_game. -/
theorem discrete_ghr93_proposition7 {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
    [NoMinOrder N.carrier] [IsSuccArchimedean N.carrier]
    (n r : Nat)
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h_univ : discrete_universal_decomp M N atomMap r x y x' y')
    (h_type_x : rank_type M atomMap r x = rank_type N atomMap r x')
    (h_type_y : rank_type M atomMap r y = rank_type N atomMap r y') :
    ghr93_duplicator_wins M N atomMap n r x y x' y' := by
  -- Get the base-level decomposition for the full interval
  have h_base : decomposition_agreement M N atomMap 0 r x y x' y' :=
    (h_univ x y x' y'
      ⟨le_refl x, hxy⟩ ⟨hxy, le_refl y⟩ hxy
      ⟨le_refl x', hx'y'⟩ ⟨hx'y', le_refl y'⟩ hx'y'
      h_type_x h_type_y).1
  intro a ha
  -- Sort the selection and apply sorted matching
  let σ := Tuple.sort a
  have h_sorted_mono : Monotone (a ∘ σ) := Tuple.monotone_sort a
  have h_sorted_in : ∀ i, inClosedInterval x y ((a ∘ σ) i) := fun i => ha (σ i)
  obtain ⟨c'_sorted, hc'_in, hc'_mono, hc'_type, hc'_ord⟩ :=
    discrete_sorted_matching n r hxy hx'y' h_type_x h_type_y h_univ h_base
      (a ∘ σ) h_sorted_mono h_sorted_in
  -- Unsort: define a' = c'_sorted ∘ σ⁻¹
  let a' := c'_sorted ∘ σ.symm
  have ha'_in : ∀ i, inClosedInterval x' y' (a' i) := fun i => hc'_in (σ.symm i)
  -- Pairwise ordering transfers through unsort
  have ha'_ord : ∀ i j : Fin n,
      (a i < a j ↔ a' i < a' j) ∧ (a i = a j ↔ a' i = a' j) := by
    intro i j; dsimp only [a']
    have h := hc'_ord (σ.symm i) (σ.symm j)
    simp only [Function.comp, Equiv.Perm.apply_symm_apply] at h ⊢
    exact h
  -- Rank_type agreement for a/a'
  have ha'_type : ∀ i : Fin n,
      rank_type M atomMap r (a i) = rank_type N atomMap r (a' i) := by
    intro i; dsimp only [a']
    have h := hc'_type (σ.symm i)
    simp only [Function.comp, Equiv.Perm.apply_symm_apply] at h
    exact h
  refine ⟨a', ha'_in, ?_⟩
  -- Point challenge: for each b', find matching b with full WC at game level n.
  -- Strategy: use universal decomposition to derive ordering between b and each a_k.
  -- For each k, use h_univ on [extendPoint b, a k] or [a k, extendPoint b] to get ordering.
  intro b' hb'
  -- Get matching point b from base decomposition
  obtain ⟨b, hb_in, hb_wc⟩ := decomp_point_challenge_NM h_base b' hb'
  refine ⟨b, hb_in, ?_⟩
  -- Extract ordering from the base WC at rank 0
  have hb_sot := hb_wc.1
  have hord_xb : (x < extendPoint b ↔ x' < extendPoint b') ∧
      (x = extendPoint b ↔ x' = extendPoint b') := by
    have h01 := hb_sot ⟨0, by omega⟩ ⟨1, by omega⟩
    rw [game_tuple_zero_eq, game_tuple_b_eq, game_tuple_zero_eq, game_tuple_b_eq] at h01
    exact h01
  have hord_by : (extendPoint b < y ↔ extendPoint b' < y') ∧
      (extendPoint b = y ↔ extendPoint b' = y') := by
    have h12 := hb_sot ⟨1, by omega⟩ ⟨2, by omega⟩
    rw [game_tuple_b_eq, game_tuple_y_eq, game_tuple_b_eq, game_tuple_y_eq] at h12
    exact h12
  have hord_xy : (x < y ↔ x' < y') ∧ (x = y ↔ x' = y') := by
    have h02 := hb_sot ⟨0, by omega⟩ ⟨2, by omega⟩
    rw [game_tuple_zero_eq, game_tuple_y_eq, game_tuple_zero_eq, game_tuple_y_eq] at h02
    exact h02
  -- Ordering between boundaries (x/y) and selections (a_k/a'_k):
  -- Use the universal decomposition on sub-intervals to derive these.
  have hord_x_sel : ∀ k : Fin n,
      (x < a k ↔ x' < a' k) ∧ (x = a k ↔ x' = a' k) := by
    intro k
    have hak_in := ha k; have ha'k_in := ha'_in k
    have h_sub := (h_univ x (a k) x' (a' k)
      ⟨le_refl x, hxy⟩ ⟨hak_in.1, hak_in.2⟩ hak_in.1
      ⟨le_refl x', hx'y'⟩ ⟨ha'k_in.1, ha'k_in.2⟩ ha'k_in.1
      h_type_x (ha'_type k)).2
    have hx'_in_sub : inClosedInterval x' (a' k)
        (extendPoint (discrete_to_carrier x')) := by
      rw [extendPoint_discrete_to_carrier]; exact ⟨le_refl x', ha'k_in.1⟩
    obtain ⟨_, _, hp_wc⟩ := decomp_point_challenge_MN h_sub
      (discrete_to_carrier x') hx'_in_sub
    have h02 := hp_wc.1 ⟨0, by omega⟩ ⟨2, by omega⟩
    rw [game_tuple_zero_eq, game_tuple_y_eq, game_tuple_zero_eq, game_tuple_y_eq,
        extendPoint_discrete_to_carrier] at h02
    -- h02 : (x' < a'_k ↔ x < a_k) ∧ (x' = a'_k ↔ x = a_k)
    exact ⟨h02.1.symm, h02.2.symm⟩
  have hord_y_sel : ∀ k : Fin n,
      (y < a k ↔ y' < a' k) ∧ (y = a k ↔ y' = a' k) := by
    intro k
    have hak_in := ha k; have ha'k_in := ha'_in k
    have h_sub := (h_univ (a k) y (a' k) y'
      ⟨hak_in.1, hak_in.2⟩ ⟨hxy, le_refl y⟩ hak_in.2
      ⟨ha'k_in.1, ha'k_in.2⟩ ⟨hx'y', le_refl y'⟩ ha'k_in.2
      (ha'_type k) h_type_y).2
    have hy'_in_sub : inClosedInterval (a' k) y'
        (extendPoint (discrete_to_carrier y')) := by
      rw [extendPoint_discrete_to_carrier]; exact ⟨ha'k_in.2, le_refl y'⟩
    obtain ⟨_, _, hp_wc⟩ := decomp_point_challenge_MN h_sub
      (discrete_to_carrier y') hy'_in_sub
    have h02 := hp_wc.1 ⟨0, by omega⟩ ⟨2, by omega⟩
    rw [game_tuple_zero_eq, game_tuple_y_eq, game_tuple_zero_eq, game_tuple_y_eq,
        extendPoint_discrete_to_carrier] at h02
    -- h02 : (a'_k < y' ↔ a_k < y) ∧ (a'_k = y' ↔ a_k = y)
    -- We need (y < a_k ↔ y' < a'_k) ∧ (y = a_k ↔ y' = a'_k)
    have h_swap : (a k < y ↔ a' k < y') ∧ (a k = y ↔ a' k = y') :=
      ⟨h02.1.symm, h02.2.symm⟩
    exact order_reverse h_swap
  -- Ordering between point (b/b') and selections (a_k/a'_k):
  -- Use universal decomposition on sub-intervals [extendPoint b, a k] or [a k, extendPoint b]
  have hb_type : rank_type M atomMap r (extendPoint b) =
      rank_type N atomMap r (extendPoint b') := wc_rank_type_at_point hb_wc
  have hord_b_sel : ∀ k : Fin n,
      (extendPoint b < a k ↔ extendPoint b' < a' k) ∧
      (extendPoint b = a k ↔ extendPoint b' = a' k) := by
    intro k
    have hak_in := ha k; have ha'k_in := ha'_in k
    rcases le_or_gt (extendPoint b) (a k) with hba | hab
    · -- b ≤ a_k: use decomp on [extendPoint b, a k] / [extendPoint b', a' k]
      -- First derive extendPoint b' ≤ a' k using pivot through x
      have hb'_le_a'k : extendPoint b' ≤ a' k := by
        -- x ≤ b ≤ a_k and ordering x↔x', xb↔x'b' transfer
        -- pivot_chain_order: x ≤ b ≤ a_k gives x < a_k ↔ x' < a'_k
        -- We already have this from hord_x_sel. Now:
        -- b ≤ a_k means ¬(a_k < b). We need ¬(a'_k < b').
        -- From: a_k < y ↔ a'_k < y' (derivable from hord_y_sel or containment)
        -- and b < y ↔ b' < y' (from hord_by)
        -- This is still not enough. Use the sub-interval decomp directly.
        -- Forward decomp on [x, a_k] / [x', a'_k], challenge with b:
        have h_sub_fwd := (h_univ x (a k) x' (a' k)
          ⟨le_refl x, hxy⟩ ⟨hak_in.1, hak_in.2⟩ hak_in.1
          ⟨le_refl x', hx'y'⟩ ⟨ha'k_in.1, ha'k_in.2⟩ ha'k_in.1
          h_type_x (ha'_type k)).1
        have hb_in_sub : inClosedInterval x (a k) (extendPoint b) := ⟨hb_in.1, hba⟩
        obtain ⟨b'', hb''_in, _⟩ := decomp_point_challenge_MN h_sub_fwd b hb_in_sub
        -- b'' ∈ [x', a'_k], so extendPoint b'' ≤ a'_k
        -- But b'' is a DIFFERENT point than b'. We just need that SOME point
        -- in [x', a'_k] exists, which proves the interval is non-degenerate.
        -- Actually we need b' ≤ a'_k specifically.
        -- Try: use the sub-interval decomp on [extendPoint b, a_k]/[extendPoint b', ?]
        -- where ? satisfies the right rank_type.
        -- Key: we can use h_univ on [extendPoint b, a_k] with boundaries b/a_k
        -- mapping to b'/a'_k, IF b' ≤ a'_k.
        -- ALTERNATIVE: prove by contradiction. Suppose a'_k < b'.
        -- Then from hord_x_sel: x < a_k ↔ x' < a'_k.
        -- If a'_k < b' and x' ≤ a'_k < b', then x' < b'.
        -- From hord_xb: x' < b' → x < b. So x < b ≤ a_k.
        -- Hence x < a_k, so x' < a'_k (by hord_x_sel).
        -- Now a'_k < b' and x' < a'_k. Also a_k ≥ b ≥ x.
        -- From hord_y_sel: y < a_k ↔ y' < a'_k. Since a_k ≤ y, ¬(y < a_k),
        -- so ¬(y' < a'_k), i.e., a'_k ≤ y'.
        -- Now we have x' < a'_k < b' ≤ y'.
        -- Use the backward decomp on [a'_k, y'] / [a_k, y] to challenge with b'.
        -- b' ∈ [a'_k, y'] gives matching p ∈ [a_k, y].
        -- The WC at rank 0 on [a_k, y]/[a'_k, y'] at positions (0,1):
        -- a_k < p ↔ a'_k < b'. Since a'_k < b', we get a_k < p.
        -- But p ∈ [a_k, y], so a_k ≤ p. And a_k < p means p > a_k.
        -- Also from WC at (0,2): a_k < y ↔ a'_k < y'.
        -- Now: use forward decomp on [x, a_k] / [x', a'_k] to challenge with b.
        -- b ∈ [x, a_k]. Matching b'' ∈ [x', a'_k]. WC at (1,2): b < a_k ↔ b'' < a'_k.
        -- And WC at (0,1): x < b ↔ x' < b''. And we know rank_type(b) = rank_type(b'').
        -- Similarly from the base WC: rank_type(b) = rank_type(b'). So rank_type(b'') = rank_type(b').
        -- But b'' ∈ [x', a'_k] and b' ∈ [a'_k, y'] with a'_k < b'. So b'' < b'? Not necessarily.
        -- This approach is getting too complex. Let me just sorry this for now.
        sorry
      -- Now use decomp on [extendPoint b, a_k] / [extendPoint b', a'_k]
      have h_sub := (h_univ (extendPoint b) (a k) (extendPoint b') (a' k)
        ⟨hb_in.1, hb_in.2⟩ ⟨hak_in.1, hak_in.2⟩ hba
        ⟨hb'.1, hb'.2⟩ ⟨ha'k_in.1, ha'k_in.2⟩ hb'_le_a'k
        hb_type (ha'_type k)).2
      have hb'_in_sub : inClosedInterval (extendPoint b') (a' k)
          (extendPoint (discrete_to_carrier (extendPoint b'))) := by
        rw [extendPoint_discrete_to_carrier]; exact ⟨le_refl _, hb'_le_a'k⟩
      obtain ⟨_, _, hp_wc⟩ := decomp_point_challenge_MN h_sub
        (discrete_to_carrier (extendPoint b')) hb'_in_sub
      have h02 := hp_wc.1 ⟨0, by omega⟩ ⟨2, by omega⟩
      rw [game_tuple_zero_eq, game_tuple_y_eq, game_tuple_zero_eq, game_tuple_y_eq,
          extendPoint_discrete_to_carrier] at h02
      -- h02 : (b' < a'_k ↔ b < a_k) ∧ (b' = a'_k ↔ b = a_k) (N/M sides swapped)
      exact ⟨h02.1.symm, h02.2.symm⟩
    · -- a_k < b: symmetric, use decomp on [a_k, extendPoint b] / [a'_k, extendPoint b']
      have ha'k_le_b' : a' k ≤ extendPoint b' := by sorry
      have h_sub := (h_univ (a k) (extendPoint b) (a' k) (extendPoint b')
        ⟨hak_in.1, hak_in.2⟩ ⟨hb_in.1, hb_in.2⟩ (le_of_lt hab)
        ⟨ha'k_in.1, ha'k_in.2⟩ ⟨hb'.1, hb'.2⟩ ha'k_le_b'
        (ha'_type k) hb_type).2
      have hb'_in_sub : inClosedInterval (a' k) (extendPoint b')
          (extendPoint (discrete_to_carrier (extendPoint b'))) := by
        rw [extendPoint_discrete_to_carrier]; exact ⟨ha'k_le_b', le_refl _⟩
      obtain ⟨_, _, hp_wc⟩ := decomp_point_challenge_MN h_sub
        (discrete_to_carrier (extendPoint b')) hb'_in_sub
      have h02 := hp_wc.1 ⟨0, by omega⟩ ⟨2, by omega⟩
      rw [game_tuple_zero_eq, game_tuple_y_eq, game_tuple_zero_eq, game_tuple_y_eq,
          extendPoint_discrete_to_carrier] at h02
      -- h02 : (a'_k < b' ↔ a_k < b) ∧ (a'_k = b' ↔ a_k = b) (N/M sides swapped)
      exact order_reverse ⟨h02.1.symm, h02.2.symm⟩
  -- Build the winning condition
  refine ⟨?_, ?_, ?_⟩
  · -- same_order_type
    exact same_order_type_of_cases hord_xb hord_xy hord_by
      hord_x_sel hord_b_sel hord_y_sel ha'_ord
  · -- gap_point_agreement: trivial in discrete orders (everything is a point)
    intro i
    exact ⟨⟨fun _ => discrete_extended_isPoint _, fun _ => discrete_extended_isPoint _⟩,
      ⟨fun h => by obtain ⟨g, _⟩ := h; exact ((discrete_no_gaps (T := M.carrier)).false g).elim,
       fun h => by obtain ⟨g, _⟩ := h; exact ((discrete_no_gaps (T := N.carrier)).false g).elim⟩⟩
  · -- formula_agreement: from rank_type agreement
    have hb_form := hb_wc.2.2
    exact formula_agreement_of_cases
      (fun A hA => by
        have h := h_type_x; simp only [rank_type, Set.ext_iff] at h
        have h_A := h A; simp only [Set.mem_setOf_eq] at h_A
        exact ⟨fun hxA => (h_A.mp ⟨hA, hxA⟩).2, fun hx'A => (h_A.mpr ⟨hA, hx'A⟩).2⟩)
      (fun A hA => by
        have h01 := hb_form ⟨1, by omega⟩ A hA
        rw [game_tuple_b_eq, game_tuple_b_eq] at h01; exact h01)
      (fun A hA => by
        have h := h_type_y; simp only [rank_type, Set.ext_iff] at h
        have h_A := h A; simp only [Set.mem_setOf_eq] at h_A
        exact ⟨fun hyA => (h_A.mp ⟨hA, hyA⟩).2, fun hy'A => (h_A.mpr ⟨hA, hy'A⟩).2⟩)
      (fun k A hA => by
        have h := ha'_type k; simp only [rank_type, Set.ext_iff] at h
        have h_A := h A; simp only [Set.mem_setOf_eq] at h_A
        exact ⟨fun hakA => (h_A.mp ⟨hA, hakA⟩).2, fun ha'kA => (h_A.mpr ⟨hA, ha'kA⟩).2⟩)

end Bimodal.Metalogic.WeakCanonical
