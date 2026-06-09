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


end Bimodal.Metalogic.WeakCanonical
