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
  induction n generalizing r x y x' y' with
  | zero =>
    -- n = 0: r + 4*0 = r, 1 + 3*0 = 1
    simp only [Nat.mul_zero, Nat.add_zero] at h ⊢
    -- discrete_rank_convert at same rank is identity
    have hx_eq : discrete_rank_convert (r' := r) x = x :=
      extendPoint_discrete_to_carrier x
    have hy_eq : discrete_rank_convert (r' := r) y = y :=
      extendPoint_discrete_to_carrier y
    have hx'_eq : discrete_rank_convert (r' := r) x' = x' :=
      extendPoint_discrete_to_carrier x'
    have hy'_eq : discrete_rank_convert (r' := r) y' = y' :=
      extendPoint_discrete_to_carrier y'
    rw [hx_eq, hy_eq, hx'_eq, hy'_eq]
    exact discrete_ghr93_theorem6_zero hx'y' hxy h
  | succ n ih =>
    -- GHR93 Theorem 6 inductive step for discrete orders (n -> n+1)
    -- h : G_{4+3n; r+4(n+1)}(M, xy; N, x'y')  [forward]
    -- Goal: G_{n+1; r}(N, drc x', drc y'; M, drc x, drc y)  [backward]
    -- IH: for any r', from G_{1+3n; r'+4n} get G_{n; r'}

    -- Get backward game at (n, r+4) via IH applied at r' = r+4
    -- Note: (r+4)+4*n = r+4*(n+1) definitionally
    have h_fwd_13n := ghr93_duplicator_wins_round_mono
      (show 1 + 3 * n ≤ 1 + 3 * (n + 1) from by omega) hxy hx'y' h
    -- IH expects rank (r+4)+4*n but we have r+4*(n+1). Cast using Nat.add_comm.
    -- Note: r + 4 * (n + 1) = r + (4 * n + 4) and (r + 4) + 4 * n = r + (4 + 4 * n)
    -- These are equal but not definitionally. We use show/calc to cast.
    have h_bwd_n : ghr93_duplicator_wins N M atomMap n (r + 4)
        (discrete_rank_convert x') (discrete_rank_convert y')
        (discrete_rank_convert x) (discrete_rank_convert y) := by
      -- Rewrite the goal to match IH's output type
      -- IH at r+4 gives: G_{n; r+4}(N, drc x'', drc y''; M, drc x'', drc y'')
      -- where x'' y'' are at rank (r+4)+4*n
      -- Our x y are at rank r+4*(n+1) = (r+4)+4*n (by omega)
      -- The drc output is extendPoint (discrete_to_carrier _), which only depends
      -- on the carrier point, so drc at rank R and drc at rank R' give the same
      -- element at the target rank. This is discrete_rank_convert's key property.
      -- Actually, the output of ih is parameterized by the INPUT endpoints' rank.
      -- ih (r+4) needs input at rank (r+4)+4*n = r+4+4*n.
      -- Our endpoints are at rank r+4*(n+1) = r+(4*n+4) = r+4*n+4.
      -- r+4+4*n vs r+4*n+4: these are equal (commutativity of addition).
      -- In Lean, Nat.add is right-assoc: (a + b) + c = a + (b + c) reducibly.
      -- But 4+4*n vs 4*n+4 needs add_comm. Not definitional!
      --
      -- Solution: cast the entire statement using omega.
      -- discrete_rank_convert output is independent of source rank
      -- So we can prove drc_{R->s} x = drc_{R'->s} (cast x) for any R, R'
      -- The approach: unfold drc to extendPoint (discrete_to_carrier x),
      -- show that the carrier point is the same regardless of source rank.
      -- Then the game statement follows.
      --
      -- Actually: ih (r+4) gives drc on inputs at rank (r+4)+4*n.
      -- Our drc x' is at rank r+4*(n+1). Since drc only extracts the
      -- carrier point and re-embeds, drc at rank R and drc at rank R'
      -- produce the SAME element at the target rank, for the SAME carrier input.
      -- But x' at rank R and x' at rank R' are DIFFERENT types!
      --
      -- The cleanest solution: use Nat.add_comm to cast the entire context.
      -- have hcast : r + 4 + 4 * n = r + 4 * (n + 1) := by omega
      -- But ▸ doesn't work well with dependent types.
      --
      -- Alternative: prove a version of the IH that works at our rank.
      -- We know r+4*(n+1) is the rank. We want (r+4)+4*n.
      -- In Lean4 Nat: 4*(n+1) = 4*n+4, and (r+4)+4*n = r+(4+4*n) = r+(4*n+4).
      -- Actually: let's check with omega if these are definitionally equal.
      -- They are NOT definitionally equal. Need explicit cast.
      --
      -- Use Eq.mp on the entire proposition.
      have hcast : r + 4 + 4 * n = r + 4 * (n + 1) := by omega
      have h_fwd_cast : ghr93_duplicator_wins M N atomMap (1 + 3 * n)
          (r + 4 + 4 * n) (hcast ▸ x) (hcast ▸ y) (hcast ▸ x') (hcast ▸ y') :=
        hcast ▸ h_fwd_13n
      have h_bwd_cast := ih (r + 4) (hcast ▸ hxy : (hcast ▸ x) ≤ (hcast ▸ y))
        (hcast ▸ hx'y' : (hcast ▸ x') ≤ (hcast ▸ y')) h_fwd_cast
      -- h_bwd_cast has drc applied to hcast ▸ x etc.
      -- Need to show drc (hcast ▸ x) = drc x at the target rank.
      -- In discrete orders, drc x = extendPoint (discrete_to_carrier x)
      -- and hcast ▸ x at rank R' has the same carrier point as x at rank R.
      -- So drc (hcast ▸ x) = drc x.
      convert h_bwd_cast using 2 <;>
        simp [discrete_rank_convert, discrete_to_carrier, extendPoint] <;>
        cases ‹_› with
        | inl p => simp [discrete_to_carrier, extendPoint]
        | inr g => exact absurd g.val (IsEmpty.false (discrete_no_gaps))

    -- Get 1-round forward game for point matching
    have h_fwd_1 := ghr93_duplicator_wins_round_mono
      (show 1 ≤ 1 + 3 * (n + 1) from by omega) hxy hx'y' h

    sorry


end Bimodal.Metalogic.WeakCanonical
