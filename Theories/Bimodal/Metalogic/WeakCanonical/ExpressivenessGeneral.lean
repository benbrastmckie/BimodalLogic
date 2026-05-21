import Bimodal.Metalogic.WeakCanonical.EFGames
import Mathlib.Data.Finset.Sort

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

/-! ## Symmetry of the Winning Condition -/

/-- The winning condition is symmetric: swapping the tuples (and structures)
    preserves it. -/
theorem ghr93_winning_condition_symm {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    {n : Nat}
    {tM : Fin (n + 3) → ExtendedCarrier M atomMap r}
    {tN : Fin (n + 3) → ExtendedCarrier N atomMap r}
    (h : ghr93_winning_condition n tM tN) :
    ghr93_winning_condition n tN tM := by
  obtain ⟨hord, hgp, hform⟩ := h
  refine ⟨?_, ?_, ?_⟩
  · intro i j; exact ⟨(hord i j).1.symm, (hord i j).2.symm⟩
  · intro i; exact ⟨(hgp i).1.symm, (hgp i).2.symm⟩
  · intro i A hA; exact (hform i A hA).symm

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
  /-- The split point d is at or below a_n -/
  hd_le_an : d ≤ a_bwd ⟨n, by omega⟩
  /-- x ≤ c (for sub-interval well-formedness) -/
  hxc : x ≤ c
  /-- c ≤ y (for sub-interval well-formedness) -/
  hcy : c ≤ y
  /-- x' ≤ d (for sub-interval well-formedness) -/
  hx'd : x' ≤ d
  /-- d ≤ y' (for sub-interval well-formedness) -/
  hdy' : d ≤ y'
  /-- Backward strategy σ on the left sub-interval:
      Duplicator wins G_{n;r}(N, x'd; M, xc) -/
  sigma : ghr93_duplicator_wins N M atomMap n r x' d x c
  /-- Backward strategy τ on the right sub-interval:
      Duplicator wins G_{n;r}(N, dy'; M, cy) -/
  tau : ghr93_duplicator_wins N M atomMap n r d y' c y

/-- Obtain the split point properties. This is the core setup lemma for
    the inductive step, combining strategy restriction and IH application.

    **Approach** (simplified from GHR93, avoids infimum infrastructure):

    1. Set d = a_bwd(n) — Spoiler's last backward pick. Then hd_le_an is le_refl.
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
    (ih : ∀ {x₀ y₀ : ExtendedCarrier M atomMap r}
            {x₀' y₀' : ExtendedCarrier N atomMap r},
          x₀ ≤ y₀ → x₀' ≤ y₀' →
          (∃ p, inClosedInterval x₀' y₀' (extendPoint p)) →
          ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x₀ y₀ x₀' y₀' →
          ghr93_duplicator_wins N M atomMap n r x₀' y₀' x₀ y₀)
    (h_fwd : ghr93_duplicator_wins M N atomMap (4 + 3 * n) r x y x' y')
    (a_bwd : Fin (n + 1) → ExtendedCarrier N atomMap r)
    (ha_bwd : ∀ i, inClosedInterval x' y' (a_bwd i)) :
    ∃ (c : ExtendedCarrier M atomMap r) (d : ExtendedCarrier N atomMap r),
      SplitPointProps n x y x' y' c d a_bwd := by
  -- Step 1: Set d = a_bwd(n) (Spoiler's last backward pick)
  let d := a_bwd ⟨n, by omega⟩
  have hd_interval : inClosedInterval x' y' d := ha_bwd ⟨n, by omega⟩
  have hd_le_an : d ≤ a_bwd ⟨n, by omega⟩ := le_refl d
  -- Step 2: Obtain c from the forward strategy.
  -- Use the (4+3n)-round strategy with 1 selection: play it with an arbitrary
  -- element from [x,y]. By round_mono, the (4+3n)-round strategy implies a
  -- 1-round strategy. Play the 1-round strategy to find a point c that matches d.
  --
  -- First, get a 1-round strategy on [x,y] vs [x',y']:
  have h1 : ghr93_duplicator_wins M N atomMap 1 r x y x' y' :=
    ghr93_duplicator_wins_round_mono (by omega : 1 ≤ 4 + 3 * n) hxy hx'y' h_fwd
  -- Play the 1-round strategy: Spoiler picks 1 element from [x,y].
  -- We need to pick something from [x,y] to find c. Use an arbitrary point
  -- (e.g., x itself, or any element that will give us a meaningful c).
  -- The winning condition will give us a response that matches the selection.
  -- We choose x as the selection (simplest choice that's in [x,y]).
  obtain ⟨a'1, ha'1, _hwin1⟩ := h1 (fun _ : Fin 1 => x) (fun _ => ⟨le_refl x, hxy⟩)
  -- a'1 ⟨0, ...⟩ is the response to x. It's in [x',y'].
  -- But we need c to match d. The above play doesn't directly give us c matching d.
  --
  -- Better approach: use the full (4+3n)-round strategy to derive c.
  -- Play with d as one of the N-side elements by using the backward structure.
  -- Since d is in N and the forward game goes M→N, we can't directly use d as input.
  --
  -- Key realization: c doesn't need to come from a specific play of the game.
  -- We need c such that:
  --   (a) c ∈ [x,y]
  --   (b) rank_type(c) = rank_type(d) (or formula agreement)
  --   (c) IsPoint c ↔ IsPoint d
  --
  -- Then strategy restriction gives forward strategies on sub-intervals, and
  -- the IH converts them to backward strategies.
  --
  -- For now, we use sorry to construct c with the needed properties.
  -- The full construction would use the forward strategy's Round 2 mechanism
  -- to extract a compatible element from M.
  --
  -- When d is a point (∃ p', d = extendPoint p'), we can play the forward
  -- game's Round 2 with p' to get a matching point b in [x,y] ∩ M.
  -- When d is a gap, the argument uses gap detection formulas (Lemma 9).
  --
  -- Step 3-5: Construct c, sigma, tau
  -- These depend on strategy restriction (ghr93_strategy_restrict_left/right)
  -- which has sorry's in EFGames.lean. We propagate the sorry here but
  -- provide the correct structural decomposition.
  suffices h_exists : ∃ c : ExtendedCarrier M atomMap r,
      inClosedInterval x y c ∧
      (∀ (A : StaviFormula), stavi_depth A ≤ r →
        (stavi_temporal_truth_mu M atomMap r c A ↔
         stavi_temporal_truth_mu N atomMap r d A)) ∧
      ((IsPoint c ↔ IsPoint d) ∧ (IsGap c ↔ IsGap d)) by
    obtain ⟨c, hc_interval, hcd_form, hcd_gp⟩ := h_exists
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
    -- The d-consistency hypothesis requires that d equals the strategy's response
    -- to c for every padded selection. This is the key structural condition that
    -- in GHR93 follows from defining d as an infimum.
    -- For the left restriction: d = response at position n (last position)
    -- For the right restriction: d = response at position 0 (first position)
    -- These are sorry'd pending the infimum/consistency infrastructure.
    have h_d_consistent_left : ∀ (a_pad : Fin (1 + 3 * n + 1) → ExtendedCarrier M atomMap r),
        (∀ i, inClosedInterval x y (a_pad i)) →
        a_pad ⟨1 + 3 * n, by omega⟩ = c →
        ∀ (a'_full : Fin (1 + 3 * n + 1) → ExtendedCarrier N atomMap r),
          (∀ i, inClosedInterval x' y' (a'_full i)) →
          (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
            ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
              ghr93_winning_condition (1 + 3 * n + 1)
                (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) →
          a'_full ⟨1 + 3 * n, by omega⟩ = d := by sorry
    have h_d_consistent_right : ∀ (a_pad : Fin (1 + 3 * n + 1) → ExtendedCarrier M atomMap r),
        (∀ i, inClosedInterval x y (a_pad i)) →
        a_pad ⟨0, by omega⟩ = c →
        ∀ (a'_full : Fin (1 + 3 * n + 1) → ExtendedCarrier N atomMap r),
          (∀ i, inClosedInterval x' y' (a'_full i)) →
          (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
            ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
              ghr93_winning_condition (1 + 3 * n + 1)
                (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) →
          a'_full ⟨0, by omega⟩ = d := by sorry
    have h_restrict_left : ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x c x' d :=
      ghr93_strategy_restrict_left h_mono_left
        hc_interval.1 hc_interval.2 hd_interval.1 hd_interval.2
        hcd_form hcd_gp h_d_consistent_left
    have h_restrict_right : ghr93_duplicator_wins M N atomMap (1 + 3 * n) r c y d y' :=
      ghr93_strategy_restrict_right h_mono_left
        hc_interval.1 hc_interval.2 hd_interval.1 hd_interval.2
        hcd_form hcd_gp h_d_consistent_right
    -- Apply IH to get backward strategies
    -- sigma: backward n-round on [x',d] vs [x,c]
    -- Need: h_pt for [x',d] (∃ point in [x',d])
    -- tau: backward n-round on [d,y'] vs [c,y]
    -- Need: h_pt for [d,y'] (∃ point in [d,y'])
    --
    -- These sub-interval point witnesses are sorry'd. In full generality,
    -- they follow from the density of actual points in the extended carrier
    -- (every non-degenerate interval in M_r contains a point from M).
    -- For degenerate intervals (c=x or d=x'), the game is vacuous.
    have h_pt_left : ∃ p, inClosedInterval x' d (extendPoint p) := by sorry
    have h_pt_right : ∃ p, inClosedInterval d y' (extendPoint p) := by sorry
    exact {
      hc_interval := hc_interval
      hd_interval := hd_interval
      hd_le_an := hd_le_an
      hxc := hc_interval.1
      hcy := hc_interval.2
      hx'd := hd_interval.1
      hdy' := hd_interval.2
      sigma := ih hc_interval.1 hd_interval.1 h_pt_left h_restrict_left
      tau := ih hc_interval.2 hd_interval.2 h_pt_right h_restrict_right
    }
  -- Prove the existence of c with the needed properties.
  -- Case split on whether d is a point or a gap.
  rcases isPoint_or_isGap d with ⟨p', hp'⟩ | ⟨g', hg'⟩
  · -- Case: d is a point (d = extendPoint p' for some p' : N.carrier)
    -- Use the forward game's Round 2 mechanism: play with p' as Spoiler's
    -- Round 2 challenge to find a matching point b in [x,y] ∩ M.
    --
    -- We need a play of the forward game first (Round 1).
    -- Use round_mono to get a 1-round strategy, play with any element.
    obtain ⟨a'_play, _ha'_play, hwin_play⟩ :=
      h1 (fun _ : Fin 1 => x) (fun _ => ⟨le_refl x, hxy⟩)
    -- Now play Round 2 with p'. Since d = extendPoint p' ∈ [x',y'],
    -- p' is in [x',y'] ∩ N.
    have hp'_in : inClosedInterval x' y' (extendPoint p') := by
      have : extendPoint p' = d := by rw [hp']; rfl
      rw [this]; exact hd_interval
    obtain ⟨b, hb_in, hcond⟩ := hwin_play p' hp'_in
    -- b is in [x,y] ∩ M. Set c = extendPoint b.
    refine ⟨extendPoint b, hb_in, ?_, ?_⟩
    · -- Formula agreement: stavi_temporal_truth_mu M atomMap r (extendPoint b) A ↔
      --                    stavi_temporal_truth_mu N atomMap r d A
      -- From the winning condition, formula_agreement at the b/p' positions gives:
      --   stavi_temporal_truth_mu M atomMap r (game_tuple x y _ b i) A ↔
      --   stavi_temporal_truth_mu N atomMap r (game_tuple x' y' _ p' i) A
      -- At the index corresponding to b (index n+1 = 2 for 1-round game):
      --   game_tuple x y _ b ⟨2, ...⟩ = extendPoint b
      --   game_tuple x' y' _ p' ⟨2, ...⟩ = extendPoint p'
      -- And d = extendPoint p', so this is exactly what we need.
      obtain ⟨_, _, hform⟩ := hcond
      intro A hA
      -- In the 1-round game (n=1 in game_tuple), the b position is at index 2:
      -- game_tuple x y (fun _ => x) b : Fin 4
      --   index 0 → x, index 2 (= 1+1) → extendPoint b, index 3 (= 1+2) → y,
      --   index 1 → a(0) = x
      -- game_tuple x' y' a'_play p' : Fin 4
      --   index 0 → x', index 2 → extendPoint p', index 3 → y',
      --   index 1 → a'_play(0)
      have hform_b := hform ⟨2, by omega⟩ A hA
      -- Simplify game_tuple at index 2:
      -- game_tuple x y (fun _ => x) b ⟨2, _⟩ = extendPoint b
      -- game_tuple x' y' a'_play p' ⟨2, _⟩ = extendPoint p'
      simp only [game_tuple, show (2 : Nat) ≠ 0 from by omega, dite_false,
                 show (2 : Nat) = 1 + 1 from by omega, dite_true] at hform_b
      -- hform_b now has: extendPoint b ↔ extendPoint p'
      -- Goal needs: extendPoint b ↔ Sum.inl p' (= extendPoint p')
      rw [hp']; exact hform_b
    · -- Gap/point agreement
      constructor
      · -- IsPoint (extendPoint b) ↔ IsPoint d
        rw [hp']
        exact ⟨fun _ => ⟨p', rfl⟩, fun _ => ⟨b, rfl⟩⟩
      · -- IsGap (extendPoint b) ↔ IsGap d
        rw [hp']
        simp only [IsGap, extendPoint]
        constructor
        · intro ⟨g, hg⟩; exact absurd hg.symm Sum.inr_ne_inl
        · intro ⟨g, hg⟩; exact absurd hg.symm Sum.inr_ne_inl
  · -- Case: d is a gap (d = Sum.inr g' for some gap g')
    -- This case is more complex: need to find c that is also a gap in M
    -- with the same rank_type. The construction uses gap detection formulas
    -- (left_formula / right_formula from GHR93 Lemma 9) to locate a compatible
    -- gap in M. This requires the gap detection correctness lemma
    -- (left_formula_gap_detection / right_formula_gap_detection), which are
    -- sorry'd in EFGames.lean.
    --
    -- The argument:
    -- 1. g' is an r-definable gap in N, defined by some formula D of depth ≤ r
    -- 2. For each formula A with stavi_depth A ≤ r, compute left(A, D) or right(A, D)
    -- 3. These formulas are evaluable at actual points in M
    -- 4. By the forward strategy's winning condition (formula agreement at the
    --    boundary elements x/x' and y/y'), the gap detection formulas agree
    --    between M and N
    -- 5. This gives a compatible gap in M
    --
    -- For now, this is sorry'd. The full proof requires Lemma 9 to be
    -- fully proved (~400-500 lines) plus ~100 lines of case analysis here.
    sorry

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
  -- but hd_le_an says d ≤ a_bwd ⟨0,_⟩. Contradiction.
  -- ---------------------------------------------------------------
  obtain ⟨i_split, hi_split⟩ := h_split
  by_cases hn : n = 0
  · subst hn
    have : i_split = ⟨0, by omega⟩ := by ext; omega
    rw [this] at hi_split
    exact absurd (le_trans props.hd_le_an (le_refl _)) (not_le.mpr hi_split)
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
  refine ⟨a'_resp, ha'_resp_in, ?_⟩
  intro b_sp hb_sp
  by_cases hbc : extendPoint b_sp ≤ c
  · -- b_sp in [x, c]: delegate to σ's Round 2
    obtain ⟨b_resp_L, hb_resp_L_in, hcond_L⟩ :=
      hwin_L b_sp ⟨hb_sp.1, hbc⟩
    refine ⟨b_resp_L, ⟨hb_resp_L_in.1, le_trans hb_resp_L_in.2 props.hdy'⟩, ?_⟩
    -- ---------------------------------------------------------------
    -- Step 7: Transfer winning condition (b_sp ≤ c case)
    -- Have: hcond_L : ghr93_winning_condition L.card
    --         (game_tuple x' d a_sigma b_resp_L)
    --         (game_tuple x c resp_L b_sp)
    -- Need: ghr93_winning_condition (n+1)
    --         (game_tuple x' y' a_bwd b_resp_L)
    --         (game_tuple x y a'_resp b_sp)
    -- ---------------------------------------------------------------
    -- ---------------------------------------------------------------
    -- Winning condition transfer (left case)
    -- ---------------------------------------------------------------
    -- The winning condition for the full (n+1)-round game requires
    -- combining sigma's and tau's winning conditions. The same_order_type
    -- and gap/point/formula agreement at L-indices comes from sigma
    -- (hcond_L), at R-indices from tau, and cross-partition from interval
    -- containment. Accessing tau's winning condition at R-selection indices
    -- requires playing tau's Round 2, which needs a point in [c,y] ∩ M.
    -- This is sorry'd: the winning condition transfer requires ~200 lines
    -- of game_tuple index case analysis plus the tau Round 2 point issue.
    sorry
  · -- b_sp in (c, y]: delegate to τ's Round 2
    push_neg at hbc
    obtain ⟨b_resp_R, hb_resp_R_in, hcond_R⟩ :=
      hwin_R b_sp ⟨le_of_lt hbc, hb_sp.2⟩
    refine ⟨b_resp_R, ⟨le_trans props.hx'd hb_resp_R_in.1, hb_resp_R_in.2⟩, ?_⟩
    -- ---------------------------------------------------------------
    -- Winning condition transfer (right case): symmetric, sorry'd
    -- ---------------------------------------------------------------
    sorry

/-! ### Cases II-IV: Tail Cases

When ALL of Spoiler's backward selections a_0,...,a_n lie in (d,y'),
the proof depends on the nature of a_n (the last selection):

- **Case II** (a_n is a point): Use standard Until U(B, A) where
  B = X_{a_n} is the type at a_n. Duplicator finds a matching point
  in M via the Until witness.

- **Case III** (a_n is a left-defined gap): Use Stavi Until U'(B, A)
  via the gap detection formula left(B, D). Duplicator finds a matching
  gap in M via Lemma 9.

- **Case IV** (a_n is a gap not left-defined): Use right(B, D) gap
  detection. Duplicator finds a matching gap in M defined on the right.

These cases are sorry'd for Phase 4C.4-4C.6. -/

/-- **Cases II-IV helper**: When all selections lie in (d,y'), construct
    Duplicator's response based on the nature of a_n.

    Sorry'd for Phase 4C.4-4C.6. -/
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
  -- Case II:  IsPoint (a_bwd ⟨n, by omega⟩) → use Until U(B, A)
  -- Case III: IsGap (a_bwd ⟨n, by omega⟩) ∧ (left-defined) → use left(B, D)
  -- Case IV:  IsGap (a_bwd ⟨n, by omega⟩) ∧ (not left-defined) → use right(B, D)
  sorry

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
    (ih : ∀ {x₀ y₀ : ExtendedCarrier M atomMap r}
            {x₀' y₀' : ExtendedCarrier N atomMap r},
          x₀ ≤ y₀ → x₀' ≤ y₀' →
          (∃ p, inClosedInterval x₀' y₀' (extendPoint p)) →
          ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x₀ y₀ x₀' y₀' →
          ghr93_duplicator_wins N M atomMap n r x₀' y₀' x₀ y₀)
    (h_fwd : ghr93_duplicator_wins M N atomMap (4 + 3 * n) r x y x' y') :
    ghr93_duplicator_wins N M atomMap (n + 1) r x' y' x y := by
  -- Unfold the backward game
  unfold ghr93_duplicator_wins
  intro a_bwd ha_bwd
  -- Obtain split points c, d and their properties
  obtain ⟨c, d, props⟩ :=
    obtain_split_point_props hxy hx'y' h_pt ih h_fwd a_bwd ha_bwd
  -- Case split: does any selection fall strictly below d?
  by_cases h_split : ∃ i : Fin (n + 1), a_bwd i < d
  · -- Case I: at least one selection below d (the "split" case)
    exact ghr93_case_I props ha_bwd h_split
  · -- Cases II-IV: all selections are at or above d
    push_neg at h_split
    exact ghr93_cases_II_III_IV props ha_bwd h_split

/-! ## GHR93 Theorem 6: Forward-to-Backward Transfer -/

/-- **GHR93 Theorem 6** (Forward-to-backward transfer, uniform rank version):
    (*)_n: If Duplicator wins G_{1+3n; r}(M, xy; N, x'y'),
    then she wins G_{n; r}(N, x'y'; M, xy).

    The hypothesis `h_pt` requires that [x',y'] contains an actual point
    from N. This is needed for the base case to trigger Round 2 of the
    forward game and extract a matching point.

    The proof is by induction on n. The base case (n=0) uses the 1-round
    forward strategy with the Spoiler's point as the selection, extracts
    a matching point via gap_point_agreement, and transfers the winning
    condition via the base_case embedding. The inductive step delegates to
    `ghr93_inductive_step`, which establishes split points c (in M_r) and
    d (in N_r), obtains sub-interval backward strategies σ and τ via the
    IH, and splits into four cases:
      Case I:   ∃ i, a_i < d (split case — sorry'd, Phase 4C.3)
      Case II:  all a_i ≥ d, a_n is a point (sorry'd, Phase 4C.4)
      Case III: all a_i ≥ d, a_n is a left-defined gap (sorry'd, Phase 4C.5)
      Case IV:  all a_i ≥ d, a_n is a gap not left-defined (sorry'd, Phase 4C.6) -/
theorem ghr93_forward_to_backward {sig : MonadicSignature}
    (atomMap : Formula → sig.preds) (n r : Nat)
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p))
    (h : ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x y x' y') :
    ghr93_duplicator_wins N M atomMap n r x' y' x y := by
  -- Revert endpoints before induction so the IH is universally quantified
  -- over all sub-intervals, not bound to the specific x, y, x', y'.
  revert x y x' y' hxy hx'y' h_pt h
  induction n with
  | zero =>
    intro x y x' y' hxy hx'y' h_pt h
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
    -- Use game_tuple_zero_eq to normalize the a_bwd function
    rw [show a_bwd = Fin.elim0 from funext (fun i => Fin.elim0 i)]
    -- The backward 0-game winning condition at (N, M) follows from
    -- the forward 1-game winning condition at (M, N) restricted to
    -- the embedded indices, with Iff direction swapped (symmetry).
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
    intro x y x' y' hxy hx'y' h_pt h
    -- Inductive step: (*)_n → (*)_{n+1}
    -- ih_gen is now universally quantified over all endpoints:
    --   ih_gen : ∀ {x y x' y'}, x ≤ y → x' ≤ y' → (∃ p, ...) →
    --            ghr93_duplicator_wins M N (1+3*n) r x y x' y' →
    --            ghr93_duplicator_wins N M n r x' y' x y
    --
    -- Note: 1 + 3 * (n + 1) = 4 + 3 * n
    have h_rounds : 1 + 3 * (n + 1) = 4 + 3 * n := by omega
    rw [h_rounds] at h
    -- Apply the inductive step helper with the generalized IH
    exact ghr93_inductive_step atomMap n r hxy hx'y' h_pt
      (fun {x₀ y₀ x₀' y₀'} hle hle' hpt' hfwd =>
        ih_gen hle hle' hpt' hfwd)
      h

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
  -- Use the uniform-rank version at rank r+4n, then transport back to rank r.
  -- Step 1: Apply the uniform-rank Theorem 6 at rank r+4n.
  -- Step 2: The result gives a backward strategy at rank r+4n.
  -- Step 3: Transport the backward strategy back to rank r using rank_embed properties.
  -- For now, this is sorry'd pending the full inductive step proof.
  sorry

end Bimodal.Metalogic.WeakCanonical
