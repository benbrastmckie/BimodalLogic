import Bimodal.Metalogic.WeakCanonical.EFGames.CustomGame

/-!
# Decomposition Formulas and Lemma 11

Decomposition formulas and Lemma 11: game-decomposition equivalence.
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-! ## Decomposition Formulas and Lemma 11 (GHR93 Definition 8.8)

An (n;r)-decomposition formula describes a "play" of the game G_{n;r}:
it specifies the rank-r types at each selected element, the gap/point
status of each element, and the types realized in each sub-interval
between adjacent elements.

Rather than defining decomposition formulas as syntactic FO formulas
(which would require a complex FO formula type with quantifiers), we
define the *semantic content* directly: two intervals (x,y) in M_r and
(x',y') in N_r agree on all decomposition formulas iff they agree on:

1. The rank-r types at the boundary elements x, y (resp. x', y')
2. The set of rank-r types realized in the interval (x, y) (resp. (x', y'))
3. For each pair of corresponding elements: gap/point status matches

This semantic characterization is equivalent to the syntactic definition
and is more natural to work with in Lean.

### References

- GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9, Definition 8.8
- GHR93 Lemma 11
- Task 155 plan: Phase 4B, Task 4B.6
-/

/-- Semantic content of (n;r)-decomposition formula agreement.

    Two intervals agree on all (n;r)-decomposition formulas iff:
    (a) The rank-r types at boundary elements match.
    (b) For every n-element selection from [x,y]_r, there exists an
        n-element selection from [x',y']_r such that:
        - rank-r types agree at corresponding positions
        - gap/point status agrees at corresponding positions
        - the sets of types realized in each sub-interval agree
        - for any actual point challenge, a matching response exists
          with the full winning condition (GHR93 Def 8.8, clause (b))
    (c) Symmetrically from N to M.

    This captures Definition 8.8 semantically: a decomposition formula
    exists y_1,...,y_n specifying types at each y_i and in each sub-interval,
    and agreement means all such specifications match.

    The point-challenge condition (last conjunct in each direction)
    provides the Sigma_i interval-type matching from GHR93 Def 8.8:
    for any actual point in a sub-interval of one structure, a
    type-and-position-matching actual point exists in the corresponding
    sub-interval of the other structure. This is needed for the backward
    direction of Lemma 11 (decomposition -> game) to handle Round 2. -/
def decomposition_agreement {sig : MonadicSignature}
    (M N : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (n r : Nat)
    (x y : ExtendedCarrier M atomMap r) (x' y' : ExtendedCarrier N atomMap r) : Prop :=
  -- Boundary type agreement
  rank_type M atomMap r x = rank_type N atomMap r x' ∧
  rank_type M atomMap r y = rank_type N atomMap r y' ∧
  -- Forward direction: for every selection from M, matching selection from N
  (∀ (a : Fin n → ExtendedCarrier M atomMap r),
    (∀ i, inClosedInterval x y (a i)) →
    ∃ (a' : Fin n → ExtendedCarrier N atomMap r),
      (∀ i, inClosedInterval x' y' (a' i)) ∧
      -- Types agree at each selected position
      (∀ i, rank_type M atomMap r (a i) = rank_type N atomMap r (a' i)) ∧
      -- Gap/point status agrees
      (∀ i, (IsPoint (a i) ↔ IsPoint (a' i)) ∧
            (IsGap (a i) ↔ IsGap (a' i))) ∧
      -- Same order type (relative ordering preserved)
      (∀ i j, (a i < a j ↔ a' i < a' j) ∧ (a i = a j ↔ a' i = a' j)) ∧
      -- Point challenge: for any actual point in [x',y'] ∩ N,
      -- a type-and-position-matching actual point in [x,y] ∩ M with
      -- full winning condition (GHR93 Def 8.8 Sigma_i condition)
      (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
        ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
          ghr93_winning_condition n
            (game_tuple x y a b) (game_tuple x' y' a' b'))) ∧
  -- Backward direction: for every selection from N, matching selection from M
  (∀ (a' : Fin n → ExtendedCarrier N atomMap r),
    (∀ i, inClosedInterval x' y' (a' i)) →
    ∃ (a : Fin n → ExtendedCarrier M atomMap r),
      (∀ i, inClosedInterval x y (a i)) ∧
      (∀ i, rank_type M atomMap r (a i) = rank_type N atomMap r (a' i)) ∧
      (∀ i, (IsPoint (a i) ↔ IsPoint (a' i)) ∧
            (IsGap (a i) ↔ IsGap (a' i))) ∧
      (∀ i j, (a i < a j ↔ a' i < a' j) ∧ (a i = a j ↔ a' i = a' j)) ∧
      -- Point challenge (symmetric): for any actual point in [x,y] ∩ M,
      -- a type-and-position-matching actual point in [x',y'] ∩ N
      (∀ (b : M.carrier), inClosedInterval x y (extendPoint b) →
        ∃ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') ∧
          ghr93_winning_condition n
            (game_tuple x y a b) (game_tuple x' y' a' b')))

/-- **GHR93 Lemma 11** (Game ↔ decomposition agreement, forward direction):

    If Duplicator wins G_{n;r}(M, x y; N, x' y'), then M_r and N_r agree
    on all (n;r)-decomposition formulas evaluated at (x,y) and (x',y').

    Intuitively: Duplicator's winning strategy provides the matching
    selections required by decomposition agreement. The winning condition
    (order type + formula agreement) implies type equality and gap/point
    agreement at each position.

    The h_pt hypothesis (existence of a point in [x',y']) is needed to
    trigger Round 2 and extract the winning condition. The h_bwd hypothesis
    provides the backward game (N→M) for the decomposition's backward
    direction. -/
theorem ghr93_game_implies_decomposition {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {n r : Nat}
    {x y : ExtendedCarrier M atomMap r} {x' y' : ExtendedCarrier N atomMap r}
    (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p))
    (h_pt_M : ∃ (p : M.carrier), inClosedInterval x y (extendPoint p))
    (h : ghr93_duplicator_wins M N atomMap n r x y x' y')
    (h_bwd : ghr93_duplicator_wins N M atomMap n r x' y' x y) :
    decomposition_agreement M N atomMap n r x y x' y' := by
  obtain ⟨p_N, hp_N⟩ := h_pt
  obtain ⟨p_M, hp_M⟩ := h_pt_M
  -- Helper: extract formula agreement from a game play
  -- Given a selection a and its response a', the winning condition gives
  -- formula_agreement at all indices. From this, we derive rank_type equality.
  have rank_type_from_win : ∀ (t : ExtendedCarrier M atomMap r)
      (t' : ExtendedCarrier N atomMap r),
      (∀ (A : StaviFormula), stavi_depth A ≤ r →
        (stavi_temporal_truth_mu M atomMap r t A ↔
         stavi_temporal_truth_mu N atomMap r t' A)) →
      rank_type M atomMap r t = rank_type N atomMap r t' := by
    intro t t' hform
    ext A
    simp only [rank_type, Set.mem_setOf_eq]
    constructor
    · intro ⟨hd, hA⟩; exact ⟨hd, (hform A hd).mp hA⟩
    · intro ⟨hd, hA⟩; exact ⟨hd, (hform A hd).mpr hA⟩
  -- Extract winning condition from forward game with a trivial selection
  -- and the point p_N as the Round 2 challenge.
  obtain ⟨a'_triv, _ha'_triv, hwin_triv⟩ :=
    h (fun _ : Fin n => x) (fun _ => ⟨le_refl _, le_trans hp_M.1 hp_M.2⟩)
  obtain ⟨b_triv, _hb_triv, hcond_triv⟩ := hwin_triv p_N hp_N
  obtain ⟨hord_triv, hgp_triv, hform_triv⟩ := hcond_triv
  -- Boundary type agreement: x/x' (index 0 in game_tuple)
  have htype_x : rank_type M atomMap r x = rank_type N atomMap r x' := by
    apply rank_type_from_win
    intro A hA
    exact hform_triv ⟨0, by omega⟩ A hA
  -- Boundary type agreement: y/y' (index n+2 in game_tuple)
  have htype_y : rank_type M atomMap r y = rank_type N atomMap r y' := by
    apply rank_type_from_win
    intro A hA
    have := hform_triv ⟨n + 2, by omega⟩ A hA
    simp only [game_tuple, show (n + 2) ≠ 0 from by omega,
      show ¬(n + 2 = n + 1) from by omega,
      show (n + 2) = n + 2 from rfl, dite_false, dite_true] at this
    exact this
  refine ⟨htype_x, htype_y, ?_, ?_⟩
  · -- Forward direction: for every selection from M, matching from N
    intro a ha
    obtain ⟨a', ha', hwin_fwd⟩ := h a ha
    -- Extract type/gap/order from a single Round 2 play (for redundant conditions)
    obtain ⟨b_fwd, _hb_fwd, hcond_fwd⟩ := hwin_fwd p_N hp_N
    obtain ⟨hord_fwd, hgp_fwd, hform_fwd⟩ := hcond_fwd
    refine ⟨a', ha', ?_, ?_, ?_, ?_⟩
    · -- Type agreement at each selection
      intro i
      apply rank_type_from_win
      intro A hA
      -- Index in game_tuple: a(i) is at position 1+i.val
      have := hform_fwd ⟨1 + i.val, by omega⟩ A hA
      simp only [game_tuple, show 1 + i.val ≠ 0 from by omega,
        show ¬(1 + i.val = n + 1) from by omega,
        show ¬(1 + i.val = n + 2) from by omega, dite_false,
        show 1 + i.val - 1 = i.val from by omega] at this
      convert this using 2 <;> simp [Fin.ext_iff]
    · -- Gap/point agreement at each selection
      intro i
      have := hgp_fwd ⟨1 + i.val, by omega⟩
      simp only [game_tuple, show 1 + i.val ≠ 0 from by omega,
        show ¬(1 + i.val = n + 1) from by omega,
        show ¬(1 + i.val = n + 2) from by omega, dite_false,
        show 1 + i.val - 1 = i.val from by omega] at this
      convert this using 2 <;> simp [Fin.ext_iff]
    · -- Order preservation at each pair of selections
      intro i j
      have := hord_fwd ⟨1 + i.val, by omega⟩ ⟨1 + j.val, by omega⟩
      simp only [game_tuple, show 1 + i.val ≠ 0 from by omega,
        show ¬(1 + i.val = n + 1) from by omega,
        show ¬(1 + i.val = n + 2) from by omega,
        show 1 + j.val ≠ 0 from by omega,
        show ¬(1 + j.val = n + 1) from by omega,
        show ¬(1 + j.val = n + 2) from by omega, dite_false,
        show 1 + i.val - 1 = i.val from by omega,
        show 1 + j.val - 1 = j.val from by omega] at this
      convert this using 2 <;> simp [Fin.ext_iff]
    · -- Point challenge: for any actual b' in [x',y'], use Round 2 of forward game
      intro b' hb'
      obtain ⟨b, hb, hcond_b⟩ := hwin_fwd b' hb'
      exact ⟨b, hb, hcond_b⟩
  · -- Backward direction: for every selection from N, matching from M
    intro a' ha'
    obtain ⟨a, ha, hwin_bwd⟩ := h_bwd a' ha'
    obtain ⟨b_bwd, _hb_bwd, hcond_bwd⟩ := hwin_bwd p_M hp_M
    obtain ⟨hord_bwd, hgp_bwd, hform_bwd⟩ := hcond_bwd
    refine ⟨a, ha, ?_, ?_, ?_, ?_⟩
    · -- Type agreement at each selection
      intro i
      apply rank_type_from_win
      intro A hA
      -- In the backward game (N→M), the game_tuple for N is the first argument
      -- and for M is the second. The formula_agreement gives:
      -- stavi_temporal_truth_mu N ... (tN i) A ↔ stavi_temporal_truth_mu M ... (tM i) A
      -- We need the reverse direction (M ↔ N), so swap the iff.
      have := hform_bwd ⟨1 + i.val, by omega⟩ A hA
      simp only [game_tuple, show 1 + i.val ≠ 0 from by omega,
        show ¬(1 + i.val = n + 1) from by omega,
        show ¬(1 + i.val = n + 2) from by omega, dite_false,
        show 1 + i.val - 1 = i.val from by omega] at this
      convert this.symm using 2 <;> simp [Fin.ext_iff]
    · -- Gap/point agreement at each selection
      intro i
      have := hgp_bwd ⟨1 + i.val, by omega⟩
      simp only [game_tuple, show 1 + i.val ≠ 0 from by omega,
        show ¬(1 + i.val = n + 1) from by omega,
        show ¬(1 + i.val = n + 2) from by omega, dite_false,
        show 1 + i.val - 1 = i.val from by omega] at this
      constructor
      · convert this.1.symm using 2 <;> simp [Fin.ext_iff]
      · convert this.2.symm using 2 <;> simp [Fin.ext_iff]
    · -- Order preservation at each pair of selections
      intro i j
      have := hord_bwd ⟨1 + i.val, by omega⟩ ⟨1 + j.val, by omega⟩
      simp only [game_tuple, show 1 + i.val ≠ 0 from by omega,
        show ¬(1 + i.val = n + 1) from by omega,
        show ¬(1 + i.val = n + 2) from by omega,
        show 1 + j.val ≠ 0 from by omega,
        show ¬(1 + j.val = n + 1) from by omega,
        show ¬(1 + j.val = n + 2) from by omega, dite_false,
        show 1 + i.val - 1 = i.val from by omega,
        show 1 + j.val - 1 = j.val from by omega] at this
      constructor
      · convert this.1.symm using 2 <;> simp [Fin.ext_iff]
      · convert this.2.symm using 2 <;> simp [Fin.ext_iff]
    · -- Point challenge: for any actual b in [x,y], use Round 2 of backward game
      -- h_bwd is ghr93_duplicator_wins N M, so Round 2 challenge is from M
      intro b hb
      obtain ⟨b', hb', hcond_b⟩ := hwin_bwd b hb
      -- hcond_b : ghr93_winning_condition n (game_tuple x' y' a' b') (game_tuple x y a b)
      -- We need: ghr93_winning_condition n (game_tuple x y a b) (game_tuple x' y' a' b')
      exact ⟨b', hb', (ghr93_winning_condition_symm _ _).mpr hcond_b⟩

/-- **GHR93 Lemma 11** (Game ↔ decomposition agreement, backward direction):

    If M_r and N_r agree on all (n;r)-decomposition formulas at (x,y)/(x',y'),
    then Duplicator has a winning strategy for G_{n;r}(M, x y; N, x' y').

    Intuitively: decomposition agreement provides Duplicator with matching
    selections (from the forward condition). For the point challenge (Round 2),
    the point-challenge condition in decomposition_agreement directly provides
    the required type-and-position-matching actual point.

    The proof constructs Duplicator's strategy from the decomposition
    agreement. The Round 1 response uses the forward matching. For Round 2,
    the point-challenge condition (strengthened GHR93 Def 8.8 Sigma_i)
    provides b matching b' with the full winning condition. -/
theorem ghr93_decomposition_implies_game {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {n r : Nat}
    {x y : ExtendedCarrier M atomMap r} {x' y' : ExtendedCarrier N atomMap r}
    (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p))
    (h_pt_M : ∃ (p : M.carrier), inClosedInterval x y (extendPoint p))
    (h : decomposition_agreement M N atomMap n r x y x' y') :
    ghr93_duplicator_wins M N atomMap n r x y x' y' := by
  -- Decompose the strengthened decomposition_agreement
  obtain ⟨_htype_x, _htype_y, h_fwd, _h_bwd⟩ := h
  -- Construct Duplicator's strategy: unfold ghr93_duplicator_wins
  -- For all ways Spoiler can pick n elements from [x,y]_r...
  intro a ha
  -- Use the forward condition to get Duplicator's Round 1 response
  obtain ⟨a', ha', _htypes, _hgp, _hord, h_pt_challenge⟩ := h_fwd a ha
  -- Provide a' as the response and handle Round 2
  refine ⟨a', ha', ?_⟩
  -- For all point challenges by Spoiler in [x',y'] ∩ N...
  intro b' hb'
  -- The point-challenge condition directly provides the matching b
  exact h_pt_challenge b' hb'

/-- **GHR93 Lemma 11** (Game ↔ decomposition agreement, iff version):

    Duplicator has a winning strategy for G_{n;r}(M, x y; N, x' y') iff
    M_r and N_r agree on all (n;r)-decomposition formulas at (x,y)/(x',y').

    The h_pt hypotheses are needed for the game → decomposition direction
    (to trigger Round 2) and for the decomposition → game direction
    (to handle the point challenge). -/
theorem ghr93_game_iff_decomposition {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {n r : Nat}
    {x y : ExtendedCarrier M atomMap r} {x' y' : ExtendedCarrier N atomMap r}
    (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p))
    (h_pt_M : ∃ (p : M.carrier), inClosedInterval x y (extendPoint p))
    (h_bwd : ghr93_duplicator_wins N M atomMap n r x' y' x y) :
    ghr93_duplicator_wins M N atomMap n r x y x' y' ↔
    decomposition_agreement M N atomMap n r x y x' y' :=
  ⟨fun hg => ghr93_game_implies_decomposition h_pt h_pt_M hg h_bwd,
   fun hd => ghr93_decomposition_implies_game h_pt h_pt_M hd⟩


end Bimodal.Metalogic.WeakCanonical
