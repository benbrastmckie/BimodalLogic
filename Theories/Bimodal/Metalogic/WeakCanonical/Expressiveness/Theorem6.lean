import Bimodal.Metalogic.WeakCanonical.Expressiveness.CaseAnalysis

/-!
# Theorem 6: Forward-to-Backward Game Transfer

Theorem 6: forward-to-backward game transfer for expressive completeness.
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-! ## GHR93 Theorem 6: Forward-to-Backward Transfer -/

/-- **GHR93 Theorem 6, core** (Forward-to-backward transfer with decoupled r+1 round count):
    The key insight is that the rank-universal forward hypothesis `h_r1_univ` is
    quantified over ALL ranks `r'` and all endpoints, so it does NOT depend on the
    induction variable `n` or the specific endpoints `x, y, x', y'`. This allows it
    to stay out of the IH, breaking the recursive tower where each induction level
    needs rank r'+2 on sub-intervals.

    The rank-universal quantification (over `r'`) is essential for Cases III/IV
    (gap detection), where gap detection formulas have depth up to r+4, requiring
    a forward game at rank r+4 = (r+2)+2. By instantiating `h_r1_univ` at `r' = r+2`,
    we obtain the needed rank-(r+4) game.

    Parameter `rounds_r1` is the round count for the forward games, decoupled from `n`.
    The constraint `h_enough : 1 + 3 * n ≤ rounds_r1` ensures enough rounds at each level.
    (In the succ case, 1+3(n+1) = 4+3n ≤ rounds_r1 gives the 4+3n rounds needed
    by ghr93_inductive_step for h_fwd_r1, and 1+3n ≤ rounds_r1 for the IH.) -/
private theorem ghr93_forward_to_backward_core {sig : MonadicSignature}
    (atomMap : Formula → sig.preds) (n : Nat) (rounds_r1 r : Nat)
    {M N : OrderedMonadicStructure sig}
    (h_r1_univ : ∀ (r' : Nat) {x₁ y₁ : ExtendedCarrier M atomMap r'}
                   {x₁' y₁' : ExtendedCarrier N atomMap r'},
                 x₁ ≤ y₁ → x₁' ≤ y₁' →
                 ghr93_duplicator_wins M N atomMap rounds_r1 (r' + 2)
                   (rank_embed (by omega : r' ≤ r' + 2) x₁)
                   (rank_embed (by omega : r' ≤ r' + 2) y₁)
                   (rank_embed (by omega : r' ≤ r' + 2) x₁')
                   (rank_embed (by omega : r' ≤ r' + 2) y₁'))
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (h_enough : 1 + 3 * n ≤ rounds_r1)
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p))
    (h_pt_M : ∃ (p : M.carrier), inClosedInterval x y (extendPoint p))
    (h : ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x y x' y')
    (k_nf : Nat)
    (char_k : NormalForm sig k_nf 1 → StaviFormula)
    (char_k_correct : ∀ (nf_k : NormalForm sig k_nf 1)
        (M' : OrderedMonadicStructure sig) (t : M'.carrier),
        stavi_temporal_truth M' atomMap t (char_k nf_k) ↔
        nf_eval_nf M' k_nf 1 (fun _ => t) nf_k)
    (char_k_depth : ∀ (nf_k : NormalForm sig k_nf 1),
        stavi_depth (char_k nf_k) + 2 ≤ r) :
    ghr93_duplicator_wins N M atomMap n r x' y' x y := by
  -- h_r1_univ, k_nf, char_k, char_k_correct do NOT depend on n, r, or
  -- specific endpoints, so they stay in scope after reverting. char_k_depth
  -- depends on r and is reverted. Revert r so that ih_gen is rank-polymorphic
  -- — this allows constructing a rank-(r+2) backward game for Case II's
  -- U(B,A) transfer.
  revert r h_enough x y x' y' hxy hx'y' h_pt h_pt_M h char_k_depth
  induction n with
  | zero =>
    intro r x y x' y' _ hxy hx'y' h_pt _h_pt_M h _char_k_depth
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
    -- Goal: ∀ (r : Nat) {x y x' y'}, ... → backward (n+1) r
    -- ih_gen is now rank-polymorphic (r was reverted before induction):
    -- ih_gen : ∀ (r₀ : Nat), 1+3*n ≤ rounds_r1 → ∀ {x₀ y₀ x₀' y₀'}, ... →
    --          forward (1+3n) r₀ → char_k_depth at r₀ → backward n r₀
    intro r x y x' y' h_enough hxy hx'y' h_pt h_pt_M h char_k_depth
    -- Inductive step: (*)_n → (*)_{n+1}
    -- Note: 1 + 3 * (n + 1) = 4 + 3 * n
    have h_rounds : 1 + 3 * (n + 1) = 4 + 3 * n := by omega
    rw [h_rounds] at h
    -- Derive h_fwd_r1 for the specific endpoints from h_r1_univ at r' = r + round_mono
    -- h_r1_univ r gives rounds_r1 rounds at rank r+2; we need 4+3n rounds
    -- h_enough : 1+3(n+1) = 4+3n ≤ rounds_r1, so round_mono applies directly
    have h_fwd_r1 : ghr93_duplicator_wins M N atomMap (4 + 3 * n) (r + 2)
        (rank_embed (by omega : r ≤ r + 2) x) (rank_embed (by omega : r ≤ r + 2) y)
        (rank_embed (by omega : r ≤ r + 2) x') (rank_embed (by omega : r ≤ r + 2) y') :=
      ghr93_duplicator_wins_round_mono (by omega : 4 + 3 * n ≤ rounds_r1)
        ((rank_embed_le (by omega : r ≤ r + 2) x y).mpr hxy)
        ((rank_embed_le (by omega : r ≤ r + 2) x' y').mpr hx'y')
        (h_r1_univ r hxy hx'y')
    -- Construct the rank-(r+2) IH for Case II's U(B,A) transfer.
    -- ih_gen at r+2 gives: forward (1+3n) (r+2) → backward n (r+2).
    -- This is passed to ghr93_inductive_step so Case II can build a rank-(r+2)
    -- tau on sub-intervals [d,y']/[c,y], preserving formulas at rank r+2.
    -- char_k_depth at rank r+2: stavi_depth (char_k nf) + 2 ≤ r + 2
    -- follows from char_k_depth at rank r by omega.
    have char_k_depth_r2 : ∀ (nf_k : NormalForm sig k_nf 1),
        stavi_depth (char_k nf_k) + 2 ≤ r + 2 :=
      fun nf_k => by have := char_k_depth nf_k; omega
    have h_ih_r2 : ∀ {x₀ y₀ : ExtendedCarrier M atomMap (r + 2)}
            {x₀' y₀' : ExtendedCarrier N atomMap (r + 2)},
          x₀ ≤ y₀ → x₀' ≤ y₀' →
          (∃ p, inClosedInterval x₀' y₀' (extendPoint p)) →
          ghr93_duplicator_wins M N atomMap (1 + 3 * n) (r + 2) x₀ y₀ x₀' y₀' →
          ghr93_duplicator_wins N M atomMap n (r + 2) x₀' y₀' x₀ y₀ :=
      fun {x₀ y₀ x₀' y₀'} hle hle' hpt' hfwd =>
        ih_gen (r + 2) (by omega : 1 + 3 * n ≤ rounds_r1) hle hle' hpt' (by
          obtain ⟨p_N, hp_N⟩ := hpt'
          obtain ⟨a'_play, _, hwin_play⟩ := hfwd (fun _ : Fin (1 + 3 * n) => x₀)
            (fun _ => ⟨le_refl x₀, hle⟩)
          obtain ⟨b_M, hb_M_in, _⟩ := hwin_play p_N hp_N
          exact ⟨b_M, hb_M_in⟩) hfwd char_k_depth_r2
    exact ghr93_inductive_step atomMap n r hxy hx'y' h_pt h_pt_M
      (fun {x₀ y₀ x₀' y₀'} hle hle' hpt' hfwd =>
        ih_gen r (by omega : 1 + 3 * n ≤ rounds_r1) hle hle' hpt' (by
          obtain ⟨p_N, hp_N⟩ := hpt'
          obtain ⟨a'_play, _, hwin_play⟩ := hfwd (fun _ : Fin (1 + 3 * n) => x₀)
            (fun _ => ⟨le_refl x₀, hle⟩)
          obtain ⟨b_M, hb_M_in, _⟩ := hwin_play p_N hp_N
          exact ⟨b_M, hb_M_in⟩) hfwd char_k_depth)
      h h_fwd_r1
      (fun r' {x₁ y₁ x₁' y₁'} hle hle' =>
        ghr93_duplicator_wins_round_mono (by omega : 4 + 3 * n ≤ rounds_r1)
          ((rank_embed_le (by omega : r' ≤ r' + 2) x₁ y₁).mpr hle)
          ((rank_embed_le (by omega : r' ≤ r' + 2) x₁' y₁').mpr hle')
          (h_r1_univ r' hle hle'))
      h_ih_r2 k_nf char_k char_k_correct char_k_depth

/-- **GHR93 Theorem 6** (Forward-to-backward transfer, uniform rank version):
    (*)_n: If Duplicator wins G_{1+3n; r}(M, xy; N, x'y'),
    then she wins G_{n; r}(N, x'y'; M, xy).

    The hypothesis `h_pt` requires that [x',y'] contains an actual point
    from N. This is needed for the base case to trigger Round 2 of the
    forward game and extract a matching point.

    The hypothesis `h_r1_univ` provides a rank (r'+2) forward strategy for
    ALL pairs of intervals at ANY rank r', not just the specific [x,y] and
    [x',y'] at rank r. This is needed because:
    (1) The induction reduces to sub-intervals, and each level needs a
        rank (r+2) strategy on its specific sub-interval.
    (2) Cases III/IV (gap detection) need rank (r+4) = (r+2)+2 games, which
        are obtained by instantiating h_r1_univ at r' = r+2.
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
    (h_r1_univ : ∀ (r' : Nat) {x₁ y₁ : ExtendedCarrier M atomMap r'}
                   {x₁' y₁' : ExtendedCarrier N atomMap r'},
                 x₁ ≤ y₁ → x₁' ≤ y₁' →
                 ghr93_duplicator_wins M N atomMap (1 + 3 * n) (r' + 2)
                   (rank_embed (by omega : r' ≤ r' + 2) x₁)
                   (rank_embed (by omega : r' ≤ r' + 2) y₁)
                   (rank_embed (by omega : r' ≤ r' + 2) x₁')
                   (rank_embed (by omega : r' ≤ r' + 2) y₁'))
    (k_nf : Nat)
    (char_k : NormalForm sig k_nf 1 → StaviFormula)
    (char_k_correct : ∀ (nf_k : NormalForm sig k_nf 1)
        (M' : OrderedMonadicStructure sig) (t : M'.carrier),
        stavi_temporal_truth M' atomMap t (char_k nf_k) ↔
        nf_eval_nf M' k_nf 1 (fun _ => t) nf_k)
    (char_k_depth : ∀ (nf_k : NormalForm sig k_nf 1),
        stavi_depth (char_k nf_k) + 2 ≤ r) :
    ghr93_duplicator_wins N M atomMap n r x' y' x y :=
  ghr93_forward_to_backward_core atomMap n (1 + 3 * n) r
    h_r1_univ (by omega) hxy hx'y' h_pt h_pt_M h k_nf char_k char_k_correct char_k_depth


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
    rank_embed for the forward game hypothesis.

    The hypothesis `h_r1_univ` provides a rank-(r'+2) forward strategy for
    ALL pairs of intervals at ANY rank r'. This universal hypothesis is
    needed by `ghr93_forward_to_backward` in the inductive step to play
    sub-interval games at rank r+2. It is passed as a parameter rather
    than derived internally, since deriving sub-interval strategies from
    a single-interval game requires Lemma 10 (strategy restriction).
    In the completeness proof context, this comes from the decomposition
    formula which gives agreement at all positions. -/
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
           (rank_embed (by omega : r ≤ r + 4 * n) y'))
    (h_r1_univ : ∀ (r' : Nat) {x₁ y₁ : ExtendedCarrier M atomMap r'}
                   {x₁' y₁' : ExtendedCarrier N atomMap r'},
                 x₁ ≤ y₁ → x₁' ≤ y₁' →
                 ghr93_duplicator_wins M N atomMap (1 + 3 * n) (r' + 2)
                   (rank_embed (by omega : r' ≤ r' + 2) x₁)
                   (rank_embed (by omega : r' ≤ r' + 2) y₁)
                   (rank_embed (by omega : r' ≤ r' + 2) x₁')
                   (rank_embed (by omega : r' ≤ r' + 2) y₁'))
    (k_nf : Nat)
    (char_k : NormalForm sig k_nf 1 → StaviFormula)
    (char_k_correct : ∀ (nf_k : NormalForm sig k_nf 1)
        (M' : OrderedMonadicStructure sig) (t : M'.carrier),
        stavi_temporal_truth M' atomMap t (char_k nf_k) ↔
        nf_eval_nf M' k_nf 1 (fun _ => t) nf_k)
    (char_k_depth : ∀ (nf_k : NormalForm sig k_nf 1),
        stavi_depth (char_k nf_k) + 2 ≤ r) :
    ghr93_duplicator_wins N M atomMap n r x' y' x y := by
  -- GHR93 Theorem 6 (rank-varying): forward at rank r+4n → backward at rank r.
  -- Proof by induction on n, with r and all position-dependent data generalized.
  -- Base (n=0): rank_embed is identity (r+0=r), use forward 1-game directly.
  -- Step (n→n+1): use ghr93_forward_to_backward at rank r, deriving its
  -- hypotheses from h via round monotonicity and the IH at rank r+4.
  -- k_nf, char_k, char_k_correct are rank-independent. char_k_depth depends
  -- on r and is reverted.
  revert r x y x' y' hxy hx'y' h_pt h h_r1_univ char_k_depth
  induction n with
  | zero =>
    intro r x y x' y' hxy hx'y' h_pt h _h_r1_univ _char_k_depth
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
    intro r x y x' y' hxy hx'y' h_pt h h_r1_univ char_k_depth
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
    -- Step 3: Use h_r1_univ parameter for ghr93_forward_to_backward.
    -- h_r1_univ gives games on all sub-intervals at rank r'+2 for any r'.
    -- Pass it through directly (ghr93_forward_to_backward now takes rank-universal h_r1_univ).
    exact ghr93_forward_to_backward atomMap (n + 1) r hxy hx'y' h_pt h_pt_M h_fwd
      h_r1_univ k_nf char_k char_k_correct char_k_depth


end Bimodal.Metalogic.WeakCanonical
