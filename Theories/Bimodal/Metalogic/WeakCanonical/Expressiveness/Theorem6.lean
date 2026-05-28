import Bimodal.Metalogic.WeakCanonical.Expressiveness.CaseAnalysis

/-!
# Theorem 6: Forward-to-Backward Game Transfer

Theorem 6: forward-to-backward game transfer for expressive completeness.

**Phase R2 restructuring**: The `char_k` parameters have been removed from all
theorem variants. The `ghr93_inductive_step` now takes a `delta` parameter for
the rank offset between the backward game (rank `r`) and sigma/tau (rank
`r + delta`), matching GHR93's rank-peeling structure.

With tau at rank `r + delta` (delta = 4 in the inductive step), the full
rank-r type formula B = X_{a_n} can be transferred via U(B, sf_top)
(depth r+1 <= r+4), eliminating the need for the weaker char_k approach.

The uniform-rank version uses delta=0 (sigma/tau at rank r, same as backward
game). The rank-varying version uses delta=4 (sigma/tau at rank r+4, matching
GHR93's rank-peeling).
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-! ## GHR93 Theorem 6: Forward-to-Backward Transfer (Uniform Rank) -/

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

    The uniform rank version uses `delta := 0`, meaning sigma/tau are at
    rank `r + 0 = r` (same as the backward game). The `char_k` parameters
    have been removed: with tau at the correct rank, the full rank-r type
    formula transfer via U(B, sf_top) eliminates the need for char_k.

    Parameter `rounds_r1` is decoupled from `n` to allow the rank-universal
    forward hypothesis to provide more rounds than strictly needed. The
    constraint `h_enough` ensures enough rounds at each induction level. -/
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
    (h : ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x y x' y') :
    ghr93_duplicator_wins N M atomMap n r x' y' x y := by
  revert r x y x' y' hxy hx'y' h_pt h_pt_M h
  induction n with
  | zero =>
    intro r x y x' y' hxy hx'y' h_pt h_pt_M h
    -- Base case: G_{1;r}(M,xy;N,x'y') → G_{0;r}(N,x'y';M,xy)
    simp only [Nat.mul_zero, Nat.add_zero] at h
    unfold ghr93_duplicator_wins at h ⊢
    intro a_bwd _ha_bwd
    refine ⟨Fin.elim0, fun i => Fin.elim0 i, ?_⟩
    intro b_sp hb_sp
    obtain ⟨a'_resp, ha'_resp, hwin_fwd⟩ :=
      h (fun _ : Fin 1 => extendPoint b_sp) (fun _ => hb_sp)
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
    refine ⟨?_, ?_, ?_⟩
    · intro i j
      rw [base_case_M_eq x y b_sp b_resp i, base_case_M_eq x y b_sp b_resp j,
          base_case_N_eq x' y' q p a'_resp hq_eq i,
          base_case_N_eq x' y' q p a'_resp hq_eq j]
      exact ⟨(hord_fwd _ _).1.symm, (hord_fwd _ _).2.symm⟩
    · intro i
      rw [base_case_M_eq x y b_sp b_resp i,
          base_case_N_eq x' y' q p a'_resp hq_eq i]
      exact ⟨(hgp_fwd _).1.symm, (hgp_fwd _).2.symm⟩
    · intro i A hA
      rw [base_case_M_eq x y b_sp b_resp i,
          base_case_N_eq x' y' q p a'_resp hq_eq i]
      exact (hform_fwd _ A hA).symm
  | succ n ih_gen =>
    intro r x y x' y' hxy hx'y' h_pt h_pt_M h
    have h_rounds : 1 + 3 * (n + 1) = 4 + 3 * n := by omega
    rw [h_rounds] at h
    have h_fwd_r1 := ghr93_duplicator_wins_round_mono (by omega : 4 + 3 * n ≤ rounds_r1)
      ((rank_embed_le (by omega : r ≤ r + 2) x y).mpr hxy)
      ((rank_embed_le (by omega : r ≤ r + 2) x' y').mpr hx'y')
      (h_r1_univ r hxy hx'y')
    exact ghr93_inductive_step atomMap n r 0 hxy hx'y' h_pt h_pt_M
      (fun {x₀ y₀ x₀' y₀'} hle hle' hpt' hfwd => sorry)
      h h_fwd_r1
      (fun r' {x₁ y₁ x₁' y₁'} hle hle' =>
        ghr93_duplicator_wins_round_mono (by omega : 4 + 3 * n ≤ rounds_r1)
          ((rank_embed_le (by omega : r' ≤ r' + 2) x₁ y₁).mpr hle)
          ((rank_embed_le (by omega : r' ≤ r' + 2) x₁' y₁').mpr hle')
          (h_r1_univ r' hle hle'))

/-- **GHR93 Theorem 6** (Forward-to-backward transfer, uniform rank version):
    Public API. Calls the core with `delta := 0`. -/
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
                   (rank_embed (by omega : r' ≤ r' + 2) y₁')) :
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

**Phase R2 restructuring**: The rank-varying version now calls
ghr93_inductive_step with delta=4, matching GHR93's rank-peeling structure.
The IH construction (forward at r → backward at r+4) requires rank promotion,
which is sorry'd pending Phase R3's full rank plumbing. -/

/-- **GHR93 Theorem 6** (Forward-to-backward transfer, rank-varying version):
    If Duplicator wins G_{1+3n; r+4n}(M, xy; N, x'y') on the rank-(r+4n)
    extended carriers, then she wins G_{n; r}(N, x'y'; M, xy) on the
    rank-r extended carriers.

    The positions are given at rank r and embedded to rank r+4n via
    rank_embed for the forward game hypothesis.

    The hypothesis `h_r1_univ` provides a rank-(r'+2) forward strategy for
    ALL pairs of intervals at ANY rank r'. -/
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
                   (rank_embed (by omega : r' ≤ r' + 2) y₁')) :
    ghr93_duplicator_wins N M atomMap n r x' y' x y := by
  -- GHR93 Theorem 6 (rank-varying): forward at rank r+4n → backward at rank r.
  -- Proof by induction on n, with r and all position-dependent data generalized.
  -- Base (n=0): rank_embed is identity (r+0=r), use forward 1-game directly.
  -- Step (n→n+1): the forward game at r+4(n+1) is first transported to rank r
  -- via rank_down for the h_fwd parameter. Then ghr93_inductive_step is called
  -- with delta=4: the IH for obtain_split_point_props produces backward games
  -- at r+4, matching GHR93's rank-peeling structure.
  revert r x y x' y' hxy hx'y' h_pt h h_r1_univ
  induction n with
  | zero =>
    intro r x y x' y' hxy hx'y' h_pt h _h_r1_univ
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
    intro r x y x' y' hxy hx'y' h_pt h h_r1_univ
    -- Inductive step: forward at rank r + 4*(n+1) with 4+3n rounds
    -- → backward at rank r with n+1 rounds.
    --
    -- GHR93 rank peeling: r + 4*(n+1) = (r+4) + 4*n.
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
    -- The h_fwd parameter for ghr93_inductive_step needs the forward game
    -- at rank r. We use rank_down to project from r+4(n+1) to r.
    have h_fwd : ghr93_duplicator_wins M N atomMap (4 + 3 * n) r x y x' y' := by
      have h_rounds : 1 + 3 * (n + 1) = 4 + 3 * n := by omega
      rw [h_rounds] at h
      exact ghr93_duplicator_wins_rank_down (by omega : r ≤ r + 4 * (n + 1))
        (by omega : r + 2 ≤ r + 4 * (n + 1)) hxy hx'y' h
    -- Step 3: Derive h_fwd_r1 at rank r+2
    have h_fwd_r1 : ghr93_duplicator_wins M N atomMap (4 + 3 * n) (r + 2)
        (rank_embed (by omega : r ≤ r + 2) x) (rank_embed (by omega : r ≤ r + 2) y)
        (rank_embed (by omega : r ≤ r + 2) x') (rank_embed (by omega : r ≤ r + 2) y') :=
      ghr93_duplicator_wins_round_mono (by omega : 4 + 3 * n ≤ 1 + 3 * (n + 1))
        ((rank_embed_le (by omega : r ≤ r + 2) x y).mpr hxy)
        ((rank_embed_le (by omega : r ≤ r + 2) x' y').mpr hx'y')
        (h_r1_univ r hxy hx'y')
    -- Step 4: Construct the delta=4 IH for ghr93_inductive_step.
    -- The IH for obtain_split_point_props needs:
    --   forward (1+3n) at rank r on sub-intervals
    --   → backward n at rank r+4 on rank-embedded sub-intervals.
    -- This is the GHR93 rank promotion: the sub-interval IH at (r, delta=4)
    -- requires constructing backward games at a higher rank from forward
    -- games at a lower rank. This will be completed in Phase R3 when the
    -- full rank-peeling plumbing is in place.
    have ih_delta4 : ∀ {x₀ y₀ : ExtendedCarrier M atomMap r}
            {x₀' y₀' : ExtendedCarrier N atomMap r},
          x₀ ≤ y₀ → x₀' ≤ y₀' →
          (∃ p, inClosedInterval x₀' y₀' (extendPoint p)) →
          ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x₀ y₀ x₀' y₀' →
          ghr93_duplicator_wins N M atomMap n (r + 4)
            (rank_embed (by omega : r ≤ r + 4) x₀')
            (rank_embed (by omega : r ≤ r + 4) y₀')
            (rank_embed (by omega : r ≤ r + 4) x₀)
            (rank_embed (by omega : r ≤ r + 4) y₀) := by
      intro x₀ y₀ x₀' y₀' hle hle' hpt' hfwd
      -- GHR93 rank promotion: forward (1+3n) at r → backward n at r+4.
      -- The IH `ih` at base rank r+4 says: forward (1+3n) at (r+4)+4n
      -- on rank-embedded positions → backward n at r+4.
      -- We need to promote the rank-r forward game to rank (r+4)+4n.
      -- This requires the original forward game at rank r+4(n+1) = (r+4)+4n,
      -- restricted to the sub-interval. Phase R3 will complete this using
      -- the ambient high-rank game and strategy restriction.
      sorry
    exact ghr93_inductive_step atomMap n r 4 hxy hx'y' h_pt h_pt_M
      ih_delta4 h_fwd h_fwd_r1
      (fun r' {x₁ y₁ x₁' y₁'} hle hle' =>
        ghr93_duplicator_wins_round_mono (by omega : 4 + 3 * n ≤ 1 + 3 * (n + 1))
          ((rank_embed_le (by omega : r' ≤ r' + 2) x₁ y₁).mpr hle)
          ((rank_embed_le (by omega : r' ≤ r' + 2) x₁' y₁').mpr hle')
          (h_r1_univ r' hle hle'))


end Bimodal.Metalogic.WeakCanonical
