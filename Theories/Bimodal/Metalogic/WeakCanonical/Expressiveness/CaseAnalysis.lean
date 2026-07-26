/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Bimodal.Metalogic.WeakCanonical.Expressiveness.SplitPoint
import Bimodal.Metalogic.WeakCanonical.EFGames.Composition
import Bimodal.Metalogic.WeakCanonical.EFGames.CharacteristicFormula
import Mathlib.Data.Fin.Tuple.Sort

/-!
# Case Analysis: Cases I and II for the Inductive Step

Case analysis: Cases I and II for the inductive step of Theorem 6.

The gap cases (III-IV), the `ghr93_cases_II_III_IV` dispatcher, and the
`ghr93_inductive_step` assembly were archived to
`Boneyard/SorriedDeclExcisions/Ghr93ForwardToBackwardChain.lean` (dead closure
resting on sorried gap-detection lemmas; zero external call sites). The live
`ghr93_inductive_step_discrete` in `Transfer.lean` is a distinct declaration
and does not depend on the archived chain.
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

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


set_option maxHeartbeats 800000 in
-- `ghr93_case_I` discharges the whole 4x4 index grid of the Case I splitting argument in a
-- single `split_ifs`, so it does not elaborate within the default 200000-heartbeat budget.
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
theorem ghr93_case_I {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {n r delta : Nat}
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r}
    {d : ExtendedCarrier N atomMap r}
    {a_bwd : Fin (n + 1) → ExtendedCarrier N atomMap r}
    (props : SplitPointProps n delta x y x' y' c d a_bwd)
    (hd : 2 ≤ delta)
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
  -- Phase R3: Project sigma/tau from rank r+delta to rank r via rank_down,
  -- then reduce rounds via round_mono.
  have sigma_reduced : ghr93_duplicator_wins N M atomMap L.card r x' d x c :=
    ghr93_duplicator_wins_round_mono hL_le props.hx'd props.hxc
      (ghr93_duplicator_wins_rank_down (by omega : r ≤ r + delta)
        (by omega : r + 2 ≤ r + delta) props.hx'd props.hxc props.sigma)
  have tau_reduced : ghr93_duplicator_wins N M atomMap R.card r d y' c y :=
    ghr93_duplicator_wins_round_mono hR_le props.hdy' props.hcy
      (ghr93_duplicator_wins_rank_down (by omega : r ≤ r + delta)
        (by omega : r + 2 ≤ r + delta) props.hdy' props.hcy props.tau)
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
          dite_true, dite_false] at this
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
          dite_true, dite_false] at this
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
        dite_true] at this
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
        hi0 hj0 _ _ _ hjb _ hjy _ hjd _ _ hib hj0
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
            simp only [hjd', dite_true]
            set kj := isoL.symm ⟨j', hj_mem⟩
            have hj_eq : a_bwd j' = a_sigma kj := by
              simp only [a_sigma]; congr 1; exact (heL_inv j' hj_mem).symm
            rw [hj_eq]; exact sig_sel_sel ki kj
          · have hj_mem : j' ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd'⟩
            simp only [hjd', dite_false]
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
            simp only [hjd', dite_true]
            set kj := isoL.symm ⟨j', hj_mem⟩
            have hj_eq : a_bwd j' = a_sigma kj := by
              simp only [a_sigma]; congr 1; exact (heL_inv j' hj_mem).symm
            rw [hj_eq]
            exact pivot_chain_order_rev' (hd_le_a_tau ki) (ha_sig_le_d kj)
              (hc_le_rR ki) (hresp_L_le_c kj) (tau_d_sel ki) (sig_sel_d kj)
          · have hj_mem : j' ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd'⟩
            simp only [hjd', dite_false]
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
        dite_true, dite_false] at this
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
        dite_true, dite_false] at this
      exact this
    have hform_b_R : ∀ A, stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r (extendPoint b_resp_R) A ↔
         stavi_temporal_truth_mu M atomMap r (extendPoint b_sp) A) := by
      intro A hA
      have := hform_R ⟨R.card + 1, by omega⟩ A hA
      simp only [game_tuple, show (R.card + 1 : Nat) ≠ 0 from by omega,
        dite_true] at this
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
        hi0 hj0 _ _ _ hjb _ hjy _ hjd _ _ hib hj0
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
            simp only [hjd', dite_true]
            set kj := isoL.symm ⟨j', hj_mem⟩
            have hj_eq : a_bwd j' = a_sigma kj := by
              simp only [a_sigma]; congr 1; exact (heL_inv j' hj_mem).symm
            rw [hj_eq]; exact sig_sel_sel ki kj
          · have hj_mem : j' ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd'⟩
            simp only [hjd', dite_false]
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
            simp only [hjd', dite_true]
            set kj := isoL.symm ⟨j', hj_mem⟩
            have hj_eq : a_bwd j' = a_sigma kj := by
              simp only [a_sigma]; congr 1; exact (heL_inv j' hj_mem).symm
            rw [hj_eq]
            exact pivot_chain_order_rev (hd_le_a_tau ki) (ha_sig_le_d kj)
              (hc_le_rR ki) (hresp_L_le_c' kj)
              (tau_d_sel ki).1 (tau_d_sel ki).2
              (sig_sel_d kj).1 (sig_sel_d kj).2
          · have hj_mem : j' ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd'⟩
            simp only [hjd', dite_false]
            set kj := isoR.symm ⟨j', hj_mem⟩
            have hj_eq : a_bwd j' = a_tau kj := by
              simp only [a_tau]; congr 1; exact (heR_inv j' hj_mem).symm
            rw [hj_eq]; exact tau_sel_sel ki kj
    · -- gap_point_agreement (n+1)
      exact gap_point_agreement_of_cases hgp_x_R hgp_b_R hgp_y_R hgp_sel_R
    · -- formula_agreement (n+1)
      exact formula_agreement_of_cases hform_x_R hform_b_R hform_y_R hform_sel_R

/-! ### GHR93 U(B,A) Transfer: Formula Agreement via Characteristic Formulas

Helper for Case II: establish U(B,A) truth transfer through tau at rank r+delta.
This implements the GHR93 mechanism for deriving formula agreement between
e_n (in M) and a_n (in N) using x_t_formula, independently of the forward game.

The d-compatible forward game (h_d_compat_left) is still used for e_n construction
and ordering data. The U(B,A) transfer establishes the FORMULA AGREEMENT
independently, proving the GHR93 approach works and providing infrastructure
for the full supremum rewrite in a future phase. -/

set_option maxHeartbeats 800000 in
-- `ghr93_untl_transfer` transfers an `U(B,A)` obligation across the rank-`r+delta` embedding
-- with the interval formula fully unfolded; the default 200000-heartbeat budget is not enough.
/-- **GHR93 U(B,A) truth transfer**: Given d < a_n = p_n (non-degenerate Case II),
    transfer U(B,A) from d in N to c in M through tau at rank r+delta.

    B = x_t_formula(a_n): characteristic formula for a_n's rank-r type.
    A = x_interval_formula(d, a_n): interval type formula.
    U(B,A)(d) holds in N by untl_type_holds_at_witness.
    props.tau at rank r+delta gives formula agreement at depth ≥ r+2 ≥ depth(U(B,A)).
    Therefore U(B,A)(c) holds in M. -/
private theorem ghr93_untl_transfer {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {n r delta : Nat}
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r}
    {d : ExtendedCarrier N atomMap r}
    {a_bwd : Fin (n + 1) → ExtendedCarrier N atomMap r}
    (props : SplitPointProps n delta x y x' y' c d a_bwd)
    (hd : 2 ≤ delta)
    (ha_bwd : ∀ i, inClosedInterval x' y' (a_bwd i))
    (h_no_split : ∀ i : Fin (n + 1), d ≤ a_bwd i)
    (p_n : N.carrier)
    (hp_n : a_bwd ⟨n, by omega⟩ = extendPoint p_n)
    (hd_lt_pn : d < extendPoint p_n) :
    stavi_temporal_truth_mu M atomMap r c
      (sf_untl (x_t_formula N atomMap r (a_bwd ⟨n, by omega⟩))
               (x_interval_formula N atomMap r d (a_bwd ⟨n, by omega⟩))) := by
  -- Step 1: U(B, A)(d) holds in N.
  have hmu_an : mu_holds (a_bwd ⟨n, by omega⟩) := ⟨p_n, hp_n⟩
  have h_untl_N : stavi_temporal_truth_mu N atomMap r d
      (sf_untl (x_t_formula N atomMap r (a_bwd ⟨n, by omega⟩))
               (x_interval_formula N atomMap r d (a_bwd ⟨n, by omega⟩))) :=
    untl_type_holds_at_witness hmu_an (hp_n ▸ hd_lt_pn)
  -- Step 2: Play props.tau at rank r+delta with rank-embedded a_init.
  let a_init_re : Fin n → ExtendedCarrier N atomMap (r + delta) :=
    fun k => rank_embed (by omega : r ≤ r + delta) (a_bwd ⟨k.val, by omega⟩)
  have ha_init_re : ∀ k, inClosedInterval
      (rank_embed (by omega : r ≤ r + delta) d)
      (rank_embed (by omega : r ≤ r + delta) y')
      (a_init_re k) := by
    intro k
    exact ⟨(rank_embed_le _ d _).mpr (h_no_split ⟨k.val, by omega⟩),
           (rank_embed_le _ _ y').mpr (ha_bwd ⟨k.val, by omega⟩).2⟩
  obtain ⟨resp_tau_re, _, hwin_tau_re⟩ := props.tau a_init_re ha_init_re
  -- Step 3: Get formula agreement at the d/c position (position 0 in game_tuple).
  -- Need a carrier point in [c, y] for Round 2.
  have ⟨p_cy, hp_cy⟩ : ∃ (p : M.carrier), inClosedInterval c y (extendPoint p) := by
    rcases props.h_pt_cy with ⟨p_cy, hp_cy⟩ | ⟨_, hdy'_eq, _, hgap_d⟩
    · exact ⟨p_cy, hp_cy⟩
    · obtain ⟨g_d, hg_d⟩ := hgap_d
      have ha_eq : a_bwd ⟨n, by omega⟩ = d :=
        le_antisymm (hdy'_eq ▸ (ha_bwd ⟨n, by omega⟩).2) (h_no_split ⟨n, by omega⟩)
      exact absurd ((ha_eq ▸ hp_n).symm ▸ hg_d : extendPoint p_n = Sum.inr g_d)
        (by simp [extendPoint])
  obtain ⟨_, _, hcond_tau_re⟩ := hwin_tau_re p_cy
    ⟨(rank_embed_le _ c _).mpr hp_cy.1, (rank_embed_le _ _ y).mpr hp_cy.2⟩
  obtain ⟨_, _, hform_tau_re⟩ := hcond_tau_re
  -- Position 0 in game_tuple is the left endpoint (d / c).
  have hform_dc : ∀ (F : StaviFormula), stavi_depth F ≤ r + delta →
      (stavi_temporal_truth_mu N atomMap r d F ↔
       stavi_temporal_truth_mu M atomMap r c F) := by
    intro F hF
    rw [← formula_transfer_rank_embed (by omega : r ≤ r + delta) d F,
        ← formula_transfer_rank_embed (by omega : r ≤ r + delta) c F]
    have h := hform_tau_re ⟨0, by omega⟩ F hF
    simp only [game_tuple_zero_eq] at h; exact h
  -- Step 4: Transfer U(B,A): depth ≤ r+2 ≤ r+delta.
  exact (hform_dc _ (by calc stavi_depth _ ≤ r + 2 := untl_type_depth
                          _ ≤ r + delta := by omega)).mp h_untl_N

set_option maxHeartbeats 800000 in
-- `ghr93_construct_en` builds the witness `e_n` together with its rank-`r` type and depth-`r`
-- formula agreement in one term; the default 200000-heartbeat budget is not enough.
/-- **GHR93 Case II e_n construction via U(B,A)**: Construct e_n as a bounded
    Until witness in (c, y], with full formula agreement at depth r between
    e_n and a_n. Also provides the A condition on (c, e_n) for Round 2.

    This combines three mechanisms:
    1. `ghr93_untl_transfer`: U(B,A)(c) in M from U(B,A)(d) in N
    2. `h_d_compat_left`: B-point existence in (c, y] via forward game
    3. `untl_witness_bounded`: bounded witness z ≤ y with A on (c, z)

    The result e_n has:
    - `mu_holds e_n` (carrier point)
    - `c < e_n` and `e_n ≤ y`
    - B(e_n): same rank-r type as a_n
    - A on (c, e_n): all mu-points between c and e_n have rank-r type
      matching some mu-point in (d, a_n) in N
    - Formula agreement with a_n at depth r (from x_t_correct via B) -/
private theorem ghr93_construct_en {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {n r delta : Nat}
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r}
    {d : ExtendedCarrier N atomMap r}
    {a_bwd : Fin (n + 1) → ExtendedCarrier N atomMap r}
    (props : SplitPointProps n delta x y x' y' c d a_bwd)
    (hd : 2 ≤ delta)
    (ha_bwd : ∀ i, inClosedInterval x' y' (a_bwd i))
    (h_no_split : ∀ i : Fin (n + 1), d ≤ a_bwd i)
    (p_n : N.carrier)
    (hp_n : a_bwd ⟨n, by omega⟩ = extendPoint p_n)
    (hp_n_in : inClosedInterval x' y' (extendPoint p_n))
    (hd_lt_pn : d < extendPoint p_n)
    (_h_mono : Monotone a_bwd)
    (resp_tau : Fin n → ExtendedCarrier M atomMap r)
    (hresp_tau_in : ∀ i, inClosedInterval c y (resp_tau i)) :
    ∃ (e_n : ExtendedCarrier M atomMap r),
      c < e_n ∧ e_n ≤ y ∧ mu_holds e_n ∧
      stavi_temporal_truth_mu M atomMap r e_n
        (x_t_formula N atomMap r (a_bwd ⟨n, by omega⟩)) ∧
      (∀ w : ExtendedCarrier M atomMap r, c < w → w < e_n → mu_holds w →
        stavi_temporal_truth_mu M atomMap r w
          (x_interval_formula N atomMap r d (a_bwd ⟨n, by omega⟩))) := by
  -- Step 1: Get U(B,A)(c) in M via ghr93_untl_transfer.
  have h_untl_M := ghr93_untl_transfer props hd ha_bwd h_no_split p_n hp_n hd_lt_pn
  -- Step 2: Get a B-satisfying carrier point in (c, y] using d-compatible forward game.
  -- The d-compatible game constrains position n to map to d, ensuring c < b_pt
  -- via the ordering d < p_n.
  let a_pad_big : Fin (1 + 3 * n + 1) → ExtendedCarrier M atomMap r := fun i =>
    if h : i.val < n then resp_tau ⟨i.val, h⟩
    else if i.val = 1 + 3 * n then c
    else c  -- fill remaining positions with c
  have ha_pad_big : ∀ i, inClosedInterval x y (a_pad_big i) := by
    intro i; simp only [a_pad_big]
    split
    · exact ⟨le_trans props.hxc (hresp_tau_in ⟨_, ‹_›⟩).1, (hresp_tau_in ⟨_, ‹_›⟩).2⟩
    · split <;> exact props.hc_interval
  have hpad_last : a_pad_big ⟨1 + 3 * n, by omega⟩ = c := by
    simp [a_pad_big, show ¬(1 + 3 * n < n) from by omega]
  obtain ⟨a'_big, _, hwin_big, hd_eq_big⟩ :=
    props.h_d_compat_left a_pad_big ha_pad_big hpad_last
  obtain ⟨b_pt, hb_pt_in, hcond_big⟩ := hwin_big p_n hp_n_in
  obtain ⟨hord_big, _, hform_big⟩ := hcond_big
  -- B(b_pt) from forward game formula agreement + x_t_self.
  have hform_bpt : ∀ (F : StaviFormula), stavi_depth F ≤ r →
      (stavi_temporal_truth_mu M atomMap r (extendPoint b_pt) F ↔
       stavi_temporal_truth_mu N atomMap r (extendPoint p_n) F) := by
    intro F hF
    have h := hform_big ⟨(1 + 3 * n + 1) + 1, by omega⟩ F hF
    simp only [game_tuple_b_eq] at h; exact h
  have hB_bpt : stavi_temporal_truth_mu M atomMap r (extendPoint b_pt)
      (x_t_formula N atomMap r (a_bwd ⟨n, by omega⟩)) := by
    have hpn_is_an : extendPoint p_n = a_bwd ⟨n, by omega⟩ := hp_n.symm
    exact (hform_bpt _ x_t_depth).mpr (hpn_is_an ▸ x_t_self)
  -- c < b_pt from d-compat game ordering: d < p_n transfers to c < b_pt.
  have hc_lt_bpt : c < extendPoint b_pt := by
    have hord_cd := hord_big ⟨1 + (1 + 3 * n), by omega⟩ ⟨(1 + 3 * n + 1) + 1, by omega⟩
    have hM_sel : game_tuple x y a_pad_big b_pt ⟨1 + (1 + 3 * n), by omega⟩ = c := by
      simp only [game_tuple, show 1 + (1 + 3 * n) ≠ 0 from by omega,
        show ¬(1 + (1 + 3 * n) = 1 + 3 * n + 1 + 1) from by omega,
        show ¬(1 + (1 + 3 * n) = 1 + 3 * n + 1 + 2) from by omega, dite_false]
      show a_pad_big ⟨1 + (1 + 3 * n) - 1, _⟩ = c
      have h_idx : (⟨1 + (1 + 3 * n) - 1, by omega⟩ : Fin (1 + 3 * n + 1)) =
          ⟨1 + 3 * n, by omega⟩ := Fin.ext (by simp)
      rw [h_idx]; exact hpad_last
    have hN_sel : game_tuple x' y' a'_big p_n ⟨1 + (1 + 3 * n), by omega⟩ = d := by
      simp only [game_tuple, show 1 + (1 + 3 * n) ≠ 0 from by omega,
        show ¬(1 + (1 + 3 * n) = 1 + 3 * n + 1 + 1) from by omega,
        show ¬(1 + (1 + 3 * n) = 1 + 3 * n + 1 + 2) from by omega, dite_false]
      show a'_big ⟨1 + (1 + 3 * n) - 1, _⟩ = d
      have h1 : 1 + (1 + 3 * n) - 1 = 1 + 3 * n := by omega
      have : a'_big ⟨1 + (1 + 3 * n) - 1, by omega⟩ = a'_big ⟨1 + 3 * n, by omega⟩ := by
        congr 1; exact Fin.ext h1
      rw [this]; exact hd_eq_big
    rw [hM_sel, game_tuple_b_eq] at hord_cd
    rw [hN_sel, game_tuple_b_eq] at hord_cd
    exact hord_cd.1.mpr hd_lt_pn
  -- b_pt is a B-satisfying mu-point in (c, y].
  -- Step 3: Apply untl_witness_bounded to get e_n in (c, y].
  have h_b_bound : ∃ z_b : ExtendedCarrier M atomMap r,
      c < z_b ∧ z_b ≤ y ∧ mu_holds z_b ∧
      stavi_temporal_truth_mu M atomMap r z_b
        (x_t_formula N atomMap r (a_bwd ⟨n, by omega⟩)) :=
    ⟨extendPoint b_pt, hc_lt_bpt, hb_pt_in.2, ⟨b_pt, rfl⟩, hB_bpt⟩
  obtain ⟨e_n, hc_lt_en, he_n_le_y, hmu_en, hB_en, hA_on⟩ :=
    untl_witness_bounded h_untl_M h_b_bound
  exact ⟨e_n, hc_lt_en, he_n_le_y, hmu_en, hB_en, hA_on⟩


set_option maxHeartbeats 1600000 in
-- `ghr93_case_II` injects the `(c,d)` boundary pair into the full `(n+1)`-round game while
-- replaying tau's whole n-round winning condition; the default 200000-heartbeat budget is not
-- enough.
/-- **Case II helper**: When all selections lie in [d,y'] and a_n is a
    point, construct Duplicator's response using τ on the init sub-sequence
    and c as the response for a_n = d.

    The proof applies τ to a_0,...,a_{n-1}, sets a'_resp(n) = c,
    and transfers the winning condition from τ's n-round game to the
    full (n+1)-round game by injecting the (c,d) boundary pair. -/
theorem ghr93_case_II {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {n r delta : Nat}
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r}
    {d : ExtendedCarrier N atomMap r}
    {a_bwd : Fin (n + 1) → ExtendedCarrier N atomMap r}
    (props : SplitPointProps n delta x y x' y' c d a_bwd)
    (hd : 2 ≤ delta)
    (ha_bwd : ∀ i, inClosedInterval x' y' (a_bwd i))
    (h_no_split : ∀ i : Fin (n + 1), d ≤ a_bwd i)
    (h_point : IsPoint (a_bwd ⟨n, by omega⟩))
    (ih : ∀ {x₀ y₀ : ExtendedCarrier M atomMap r}
            {x₀' y₀' : ExtendedCarrier N atomMap r},
          x₀ ≤ y₀ → x₀' ≤ y₀' →
          (∃ p, inClosedInterval x₀' y₀' (extendPoint p)) →
          ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x₀ y₀ x₀' y₀' →
          ghr93_duplicator_wins N M atomMap n r x₀' y₀' x₀ y₀)
    (h_r1_univ : ∀ (r' : Nat) {x₁ y₁ : ExtendedCarrier M atomMap r'}
                   {x₁' y₁' : ExtendedCarrier N atomMap r'},
                 x₁ ≤ y₁ → x₁' ≤ y₁' →
                 ghr93_duplicator_wins M N atomMap (4 + 3 * n) (r' + 2)
                   (rank_embed (by omega : r' ≤ r' + 2) x₁)
                   (rank_embed (by omega : r' ≤ r' + 2) y₁)
                   (rank_embed (by omega : r' ≤ r' + 2) x₁')
                   (rank_embed (by omega : r' ≤ r' + 2) y₁'))
    (h_mono : Monotone a_bwd) :
    ∃ (a'_resp : Fin (n + 1) → ExtendedCarrier M atomMap r),
      (∀ i, inClosedInterval x y (a'_resp i)) ∧
      ∀ (b_sp : M.carrier),
        inClosedInterval x y (extendPoint b_sp) →
        ∃ (b_resp : N.carrier),
          inClosedInterval x' y' (extendPoint b_resp) ∧
          ghr93_winning_condition (n + 1)
            (game_tuple x' y' a_bwd b_resp)
            (game_tuple x y a'_resp b_sp) := by
  -- ===================================================================
  -- GHR93 Case II: all selections in [d, y'], a_n is a point p_n.
  -- Strategy: play tau on init sub-sequence, use forward game for e_n,
  -- build composed backward game tau_left/tau_right with pivot at p_n/e_n.
  -- Round 2 dispatches through composed game sub-components.
  -- ===================================================================
  -- Step 1: Extract p_n and define a_init (first n of n+1 sorted selections).
  obtain ⟨p_n, hp_n⟩ := h_point
  have hp_n_in : inClosedInterval x' y' (extendPoint p_n) := by
    have := ha_bwd ⟨n, by omega⟩; rw [hp_n] at this; exact this
  let a_init : Fin n → ExtendedCarrier N atomMap r :=
    fun k => a_bwd ⟨k.val, by omega⟩
  have ha_init : ∀ k, inClosedInterval d y' (a_init k) := by
    intro k
    exact ⟨h_no_split ⟨k.val, by omega⟩, (ha_bwd ⟨k.val, by omega⟩).2⟩
  -- Step 2: Project sigma/tau from rank r+delta to rank r.
  have sigma_r : ghr93_duplicator_wins N M atomMap n r x' d x c :=
    ghr93_duplicator_wins_rank_down (by omega : r ≤ r + delta)
      (by omega : r + 2 ≤ r + delta) props.hx'd props.hxc props.sigma
  have tau_r : ghr93_duplicator_wins N M atomMap n r d y' c y :=
    ghr93_duplicator_wins_rank_down (by omega : r ≤ r + delta)
      (by omega : r + 2 ≤ r + delta) props.hdy' props.hcy props.tau
  obtain ⟨resp_tau, hresp_tau_in, hwin_tau⟩ := tau_r a_init ha_init
  -- resp_tau : Fin n → ExtendedCarrier M atomMap r, all in [c, y]
  -- Step 3: Construct e_n using the (n+1)-round forward game.
  -- Build M-side selections: resp_tau(i) for i < n, then c at position n.
  let a_M : Fin (n + 1) → ExtendedCarrier M atomMap r := fun i =>
    if h : i.val < n then resp_tau ⟨i.val, h⟩ else c
  have ha_M : ∀ i, inClosedInterval x y (a_M i) := by
    intro i; simp only [a_M]
    split
    case isTrue h =>
      have := hresp_tau_in ⟨i.val, h⟩
      exact ⟨le_trans props.hxc this.1, this.2⟩
    case isFalse _ => exact props.hc_interval
  -- Play the d-compatible (1+3n+1)-round forward game.
  let a_pad_big : Fin (1 + 3 * n + 1) → ExtendedCarrier M atomMap r := fun i =>
    if h : i.val < n then resp_tau ⟨i.val, h⟩
    else if i.val = 1 + 3 * n then c
    else a_M ⟨min i.val n, by omega⟩
  have ha_pad_big : ∀ i, inClosedInterval x y (a_pad_big i) := by
    intro i; simp only [a_pad_big]
    split
    · exact ⟨le_trans props.hxc (hresp_tau_in ⟨_, ‹_›⟩).1, (hresp_tau_in ⟨_, ‹_›⟩).2⟩
    · split
      · exact props.hc_interval
      · exact ha_M ⟨min i.val n, by omega⟩
  have hpad_last : a_pad_big ⟨1 + 3 * n, by omega⟩ = c := by
    simp [a_pad_big, show ¬(1 + 3 * n < n) from by omega]
  obtain ⟨a'_big, ha'_big, hwin_big, hd_eq_big⟩ :=
    props.h_d_compat_left a_pad_big ha_pad_big hpad_last
  -- Challenge with p_n to get e_n_pt.
  obtain ⟨e_n_pt, he_n_pt_in, hcond_big⟩ := hwin_big p_n hp_n_in
  let e_n : ExtendedCarrier M atomMap r := extendPoint e_n_pt
  have he_n_in : inClosedInterval x y e_n := he_n_pt_in
  obtain ⟨hord_big, hgp_big, hform_big⟩ := hcond_big
  -- Step 4: Extract formula agreement, ordering, and gap/point from big game.
  have hform_en_an : ∀ (A : StaviFormula), stavi_depth A ≤ r →
      (stavi_temporal_truth_mu M atomMap r e_n A ↔
       stavi_temporal_truth_mu N atomMap r (a_bwd ⟨n, by omega⟩) A) := by
    intro A hA
    have h := hform_big ⟨(1 + 3 * n + 1) + 1, by omega⟩ A hA
    simp only [game_tuple_b_eq] at h
    rw [hp_n]; exact h
  have hord_cd_en_pn : (c < e_n ↔ d < extendPoint p_n) ∧
      (c = e_n ↔ d = extendPoint p_n) := by
    have hord := hord_big ⟨1 + (1 + 3 * n), by omega⟩ ⟨(1 + 3 * n + 1) + 1, by omega⟩
    have hM_sel : game_tuple x y a_pad_big e_n_pt ⟨1 + (1 + 3 * n), by omega⟩ = c := by
      simp only [game_tuple, show 1 + (1 + 3 * n) ≠ 0 from by omega,
        show ¬(1 + (1 + 3 * n) = 1 + 3 * n + 1 + 1) from by omega,
        show ¬(1 + (1 + 3 * n) = 1 + 3 * n + 1 + 2) from by omega, dite_false]
      show a_pad_big ⟨1 + (1 + 3 * n) - 1, _⟩ = c
      simp only [a_pad_big, 
        show ¬(1 + 3 * n < n) from by omega,
        show 1 + (1 + 3 * n) - 1 = 1 + 3 * n from by omega, dite_false, ite_true]
    have hM_b : game_tuple x y a_pad_big e_n_pt ⟨(1 + 3 * n + 1) + 1, by omega⟩ = e_n :=
      game_tuple_b_eq x y a_pad_big e_n_pt
    have hN_sel : game_tuple x' y' a'_big p_n ⟨1 + (1 + 3 * n), by omega⟩ = d := by
      simp only [game_tuple, show 1 + (1 + 3 * n) ≠ 0 from by omega,
        show ¬(1 + (1 + 3 * n) = 1 + 3 * n + 1 + 1) from by omega,
        show ¬(1 + (1 + 3 * n) = 1 + 3 * n + 1 + 2) from by omega, dite_false]
      show a'_big ⟨1 + (1 + 3 * n) - 1, _⟩ = d
      have h1 : 1 + (1 + 3 * n) - 1 = 1 + 3 * n := by omega
      have : a'_big ⟨1 + (1 + 3 * n) - 1, by omega⟩ = a'_big ⟨1 + 3 * n, by omega⟩ := by
        congr 1; exact Fin.ext h1
      rw [this]; exact hd_eq_big
    have hN_b : game_tuple x' y' a'_big p_n ⟨(1 + 3 * n + 1) + 1, by omega⟩ = extendPoint p_n :=
      game_tuple_b_eq x' y' a'_big p_n
    rw [hM_sel, hM_b, hN_sel, hN_b] at hord; exact hord
  -- Forward game orderings.
  have hord_fwd_x_en : (x < e_n ↔ x' < extendPoint p_n) ∧
      (x = e_n ↔ x' = extendPoint p_n) := by
    have hord := hord_big ⟨0, by omega⟩ ⟨(1 + 3 * n + 1) + 1, by omega⟩
    simp only [game_tuple_zero_eq, game_tuple_b_eq] at hord; exact hord
  have hord_fwd_x_y : (x < y ↔ x' < y') ∧ (x = y ↔ x' = y') := by
    have hord := hord_big ⟨0, by omega⟩ ⟨(1 + 3 * n + 1) + 2, by omega⟩
    simp only [game_tuple_zero_eq, game_tuple_y_eq] at hord; exact hord
  have hord_fwd_en_y : (e_n < y ↔ extendPoint p_n < y') ∧
      (e_n = y ↔ extendPoint p_n = y') := by
    have hord := hord_big ⟨(1 + 3 * n + 1) + 1, by omega⟩ ⟨(1 + 3 * n + 1) + 2, by omega⟩
    simp only [game_tuple_b_eq, game_tuple_y_eq] at hord; exact hord
  have hgp_fwd_x : (IsPoint x ↔ IsPoint x') ∧ (IsGap x ↔ IsGap x') := by
    have h := hgp_big ⟨0, by omega⟩; simp only [game_tuple_zero_eq] at h; exact h
  have hgp_fwd_y : (IsPoint y ↔ IsPoint y') ∧ (IsGap y ↔ IsGap y') := by
    have h := hgp_big ⟨(1 + 3 * n + 1) + 2, by omega⟩; simp only [game_tuple_y_eq] at h; exact h
  have hform_fwd_x : ∀ (A : StaviFormula), stavi_depth A ≤ r →
      (stavi_temporal_truth_mu M atomMap r x A ↔ stavi_temporal_truth_mu N atomMap r x' A) := by
    intro A hA; have h := hform_big ⟨0, by omega⟩ A hA
    simp only [game_tuple_zero_eq] at h; exact h
  have hform_fwd_y : ∀ (A : StaviFormula), stavi_depth A ≤ r →
      (stavi_temporal_truth_mu M atomMap r y A ↔ stavi_temporal_truth_mu N atomMap r y' A) := by
    intro A hA; have h := hform_big ⟨(1 + 3 * n + 1) + 2, by omega⟩ A hA
    simp only [game_tuple_y_eq] at h; exact h
  -- Hoist p_cy existence (needed for tau formula agreement).
  have ⟨p_cy_pre, hp_cy_pre⟩ : ∃ (p : M.carrier), inClosedInterval c y (extendPoint p) := by
    rcases props.h_pt_cy with ⟨p_cy, hp_cy⟩ | ⟨_, hdy'_eq, _, hgap_d⟩
    · exact ⟨p_cy, hp_cy⟩
    · obtain ⟨g_d, hg_d⟩ := hgap_d
      have ha_eq : a_bwd ⟨n, by omega⟩ = d :=
        le_antisymm (hdy'_eq ▸ (ha_bwd ⟨n, by omega⟩).2) (h_no_split ⟨n, by omega⟩)
      have : d = extendPoint p_n := ha_eq ▸ hp_n
      exact absurd (this.symm ▸ hg_d : extendPoint p_n = Sum.inr g_d) (by simp [extendPoint])
  -- Formula agreement between a'_big(k) and a_init(k) at rank r (via big game + tau).
  obtain ⟨_b_tau_pre, _hb_tau_pre_in, hcond_tau_pre⟩ := hwin_tau p_cy_pre hp_cy_pre
  obtain ⟨_hord_tau_pre, _hgp_tau_pre, hform_tau_pre⟩ := hcond_tau_pre
  -- Step 5: Build sub-interval backward games via IH.
  have hd_le_pn : d ≤ extendPoint p_n := by
    have h := h_no_split ⟨n, by omega⟩; rw [hp_n] at h; exact h
  have hc_le_en : c ≤ e_n := by
    rcases lt_or_eq_of_le hd_le_pn with hlt | heq
    · exact le_of_lt (hord_cd_en_pn.1.mpr hlt)
    · exact le_of_eq (hord_cd_en_pn.2.mpr heq)
  have h_en_le_y : e_n ≤ y := he_n_in.2
  have h_pn_le_y' : extendPoint p_n ≤ y' := hp_n_in.2
  -- tau_left: backward game on [d, p_n]/[c, e_n]
  have tau_left : ghr93_duplicator_wins N M atomMap n r d (extendPoint p_n) c e_n :=
    ih hc_le_en hd_le_pn ⟨p_n, hd_le_pn, le_refl _⟩
      (ghr93_duplicator_wins_round_mono (by omega : 1 + 3 * n ≤ 4 + 3 * n) hc_le_en hd_le_pn
        (ghr93_duplicator_wins_rank_down (by omega : r ≤ r + 2) (by omega : r + 2 ≤ r + 2)
          hc_le_en hd_le_pn (h_r1_univ r hc_le_en hd_le_pn)))
  -- tau_right: backward game on [p_n, y']/[e_n, y]
  have tau_right : ghr93_duplicator_wins N M atomMap n r (extendPoint p_n) y' e_n y :=
    ih h_en_le_y h_pn_le_y' ⟨p_n, le_refl _, h_pn_le_y'⟩
      (ghr93_duplicator_wins_round_mono (by omega : 1 + 3 * n ≤ 4 + 3 * n) h_en_le_y h_pn_le_y'
        (ghr93_duplicator_wins_rank_down (by omega : r ≤ r + 2) (by omega : r + 2 ≤ r + 2)
          h_en_le_y h_pn_le_y' (h_r1_univ r h_en_le_y h_pn_le_y')))
  -- Pivot agreement for composition.
  have hpivot_form : ∀ (A : StaviFormula), stavi_depth A ≤ r →
      (stavi_temporal_truth_mu N atomMap r (extendPoint p_n) A ↔
       stavi_temporal_truth_mu M atomMap r e_n A) := by
    intro A hA; rw [show (extendPoint p_n : ExtendedCarrier N atomMap r) =
        a_bwd ⟨n, by omega⟩ from hp_n.symm]; exact (hform_en_an A hA).symm
  have hpivot_gp : (IsPoint (extendPoint (sig := sig) (atomMap := atomMap) (r := r) p_n) ↔
      IsPoint e_n) ∧ (IsGap (extendPoint (sig := sig) (atomMap := atomMap) (r := r) p_n) ↔
      IsGap e_n) := by
    refine ⟨⟨fun _ => ⟨e_n_pt, rfl⟩, fun _ => ⟨p_n, rfl⟩⟩,
           ⟨fun ⟨g, h⟩ => ?_, fun ⟨g, h⟩ => ?_⟩⟩
    · exact absurd h (Sum.inl_ne_inr)
    · exact absurd h (Sum.inl_ne_inr)
  -- Step 6: Play tau_left with a_init to get resp_left.
  have h_ainit_le_pn : ∀ (k : Fin n), a_init k ≤ extendPoint p_n := by
    intro k
    have hk_le : (⟨k.val, by omega⟩ : Fin (n + 1)) ≤ ⟨n, by omega⟩ :=
      Fin.mk_le_mk.mpr (by omega)
    have := h_mono hk_le
    rw [hp_n] at this; exact this
  have ha_init_sub : ∀ k, inClosedInterval d (extendPoint p_n) (a_init k) :=
    fun k => ⟨(ha_init k).1, h_ainit_le_pn k⟩
  obtain ⟨resp_left, hresp_left_in, hwin_left⟩ := tau_left a_init ha_init_sub
  -- resp_left(k) ∈ [c, e_n]
  -- Extract ordering from tau_left via an arbitrary point.
  have ⟨p_ce, hp_ce⟩ : ∃ (p : M.carrier), inClosedInterval c e_n (extendPoint p) :=
    ⟨e_n_pt, hc_le_en, le_refl _⟩
  obtain ⟨_b_left, _hb_left_in, hcond_left⟩ := hwin_left p_ce hp_ce
  obtain ⟨hord_left, _hgp_left, hform_left⟩ := hcond_left
  -- Key ordering from tau_left: sel vs p_n / e_n.
  have hord_left_sel_pn : ∀ (k : Fin n),
      (a_init k < extendPoint p_n ↔ resp_left k < e_n) ∧
      (a_init k = extendPoint p_n ↔ resp_left k = e_n) := by
    intro k
    have h := hord_left ⟨1 + k.val, by omega⟩ ⟨n + 2, by omega⟩
    simp_game_tuple at h; exact h
  -- Step 7: resp_left IS the response function — no resp_mod indirection needed.
  -- Key: hord_left_sel_pn shows (a_init k = p_n ↔ resp_left k = e_n),
  -- so when a_init(k) = p_n, resp_left(k) = e_n automatically.
  -- sel_pn_ord is just hord_left_sel_pn.
  have hresp_left_in_cy : ∀ (k : Fin n), inClosedInterval c y (resp_left k) :=
    fun k => ⟨(hresp_left_in k).1, le_trans (hresp_left_in k).2 h_en_le_y⟩
  -- Step 8: Build the final (n+1)-element response and dispatch round 2.
  -- Response: resp_left(0..n-1), e_n at position n.
  let a'_resp : Fin (n + 1) → ExtendedCarrier M atomMap r := fun i =>
    if h : i.val < n then resp_left ⟨i.val, h⟩ else e_n
  have ha'_resp_in : ∀ i, inClosedInterval x y (a'_resp i) := by
    intro i; simp only [a'_resp]
    split
    case isTrue h => exact ⟨le_trans props.hxc (hresp_left_in_cy ⟨i.val, h⟩).1,
                           (hresp_left_in_cy ⟨i.val, h⟩).2⟩
    case isFalse _ => exact he_n_in
  refine ⟨a'_resp, ha'_resp_in, ?_⟩
  intro b_sp hb_sp
  -- Round 2 case split: b_sp vs c.
  by_cases hbc : extendPoint (sig := sig) (atomMap := atomMap) (r := r) b_sp ≤ c
  · -- ================================================================
    -- Case A: b_sp ∈ [x, c]. Use sigma for round 2.
    -- ================================================================
    have hd_in_x'd : inClosedInterval x' d d := ⟨props.hx'd, le_refl d⟩
    obtain ⟨_resp_sig, _, hwin_sig⟩ :=
      sigma_r (fun _ : Fin n => d) (fun _ => hd_in_x'd)
    obtain ⟨b_resp, hb_resp_in, hcond_sig⟩ :=
      hwin_sig b_sp ⟨hb_sp.1, hbc⟩
    refine ⟨b_resp, ⟨hb_resp_in.1, le_trans hb_resp_in.2 props.hdy'⟩, ?_⟩
    obtain ⟨hord_sig, hgp_sig, hform_sig⟩ := hcond_sig
    -- Extract tau winning condition at inner positions.
    have ⟨p_cy, hp_cy⟩ : ∃ (p : M.carrier), inClosedInterval c y (extendPoint p) := by
      rcases props.h_pt_cy with ⟨p_cy, hp_cy⟩ | ⟨_, hdy'_eq, _, hgap_d⟩
      · exact ⟨p_cy, hp_cy⟩
      · obtain ⟨g_d, hg_d⟩ := hgap_d
        have ha_eq : a_bwd ⟨n, by omega⟩ = d :=
          le_antisymm (hdy'_eq ▸ (ha_bwd ⟨n, by omega⟩).2) (h_no_split ⟨n, by omega⟩)
        have : d = extendPoint p_n := ha_eq ▸ hp_n
        exact absurd (this.symm ▸ hg_d : extendPoint p_n = Sum.inr g_d) (by simp [extendPoint])
    obtain ⟨_b_tau, _hb_tau_in, hcond_tau_aux⟩ := hwin_tau p_cy hp_cy
    obtain ⟨hord_tau_aux, hgp_tau_aux, hform_tau_aux⟩ := hcond_tau_aux
    refine ⟨?_, ?_, ?_⟩
    · -- same_order_type (n+1): Case A — using same_order_type_of_cases helper
      -- Extract fixed-index orderings from sub-game data.
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
      -- tau_left orderings — used uniformly (no resp_mod case splits).
      have hd_le_sel : ∀ (k : Fin n), d ≤ a_init k :=
        fun k => (ha_init k).1
      have hc_le_rl : ∀ (k : Fin n), c ≤ resp_left k :=
        fun k => (hresp_left_in k).1
      have tau_d_sel : ∀ (k : Fin n),
          (d < a_init k ↔ c < resp_left k) ∧
          (d = a_init k ↔ c = resp_left k) := by
        intro k
        have h := hord_left ⟨0, by omega⟩ ⟨1 + k.val, by omega⟩
        simp_game_tuple at h; exact h
      have tau_sel_sel : ∀ (j j' : Fin n),
          (a_init j < a_init j' ↔ resp_left j < resp_left j') ∧
          (a_init j = a_init j' ↔ resp_left j = resp_left j') := by
        intro j j'
        have h := hord_left ⟨1 + j.val, by omega⟩ ⟨1 + j'.val, by omega⟩
        simp_game_tuple at h; exact h
      -- Full sel-vs-sel ordering covering Fin (n+1) × Fin (n+1).
      have full_sel_sel : ∀ (k k' : Fin (n + 1)),
          (a_bwd k < a_bwd k' ↔ a'_resp k < a'_resp k') ∧
          (a_bwd k = a_bwd k' ↔ a'_resp k = a'_resp k') := by
        intro k k'
        by_cases hk : k.val < n <;> by_cases hk' : k'.val < n
        · -- Both < n: use tau_left sel-vs-sel directly
          rw [show a'_resp k = resp_left ⟨k.val, hk⟩ from by simp [a'_resp, hk],
              show a'_resp k' = resp_left ⟨k'.val, hk'⟩ from by simp [a'_resp, hk']]
          exact tau_sel_sel ⟨k.val, hk⟩ ⟨k'.val, hk'⟩
        · -- k < n, k' = n: sel vs p_n/e_n
          have : k' = ⟨n, by omega⟩ := Fin.ext (Nat.eq_of_lt_succ_of_not_lt k'.isLt hk')
          rw [show a'_resp k = resp_left ⟨k.val, hk⟩ from by simp [a'_resp, hk],
              show a'_resp k' = e_n from by simp [a'_resp, hk'], this, hp_n]
          exact hord_left_sel_pn ⟨k.val, hk⟩
        · -- k = n, k' < n: reverse of sel vs p_n/e_n
          have : k = ⟨n, by omega⟩ := Fin.ext (Nat.eq_of_lt_succ_of_not_lt k.isLt hk)
          rw [show a'_resp k = e_n from by simp [a'_resp, hk],
              show a'_resp k' = resp_left ⟨k'.val, hk'⟩ from by simp [a'_resp, hk'], this, hp_n]
          exact order_reverse (hord_left_sel_pn ⟨k'.val, hk'⟩)
        · -- Both = n
          rw [show a'_resp k = e_n from by simp [a'_resp, hk],
              show a'_resp k' = e_n from by simp [a'_resp, hk']]
          have hkeq : k = ⟨n, by omega⟩ := Fin.ext (Nat.eq_of_lt_succ_of_not_lt k.isLt hk)
          have hk'eq : k' = ⟨n, by omega⟩ := Fin.ext (Nat.eq_of_lt_succ_of_not_lt k'.isLt hk')
          rw [hkeq, hk'eq]; exact order_refl_pair _ _
      -- x vs sel ordering for Fin (n+1).
      have full_x_sel : ∀ (k : Fin (n + 1)),
          (x' < a_bwd k ↔ x < a'_resp k) ∧
          (x' = a_bwd k ↔ x = a'_resp k) := by
        intro k
        by_cases hk : k.val < n
        · rw [show a'_resp k = resp_left ⟨k.val, hk⟩ from by simp [a'_resp, hk]]
          exact pivot_chain_order' props.hx'd (hd_le_sel ⟨k.val, hk⟩) props.hxc
            (hc_le_rl ⟨k.val, hk⟩) sig_x_d (tau_d_sel ⟨k.val, hk⟩)
        · rw [show a'_resp k = e_n from by simp [a'_resp, hk],
              show k = ⟨n, by omega⟩ from Fin.ext (Nat.eq_of_lt_succ_of_not_lt k.isLt hk), hp_n]
          exact ⟨hord_fwd_x_en.1.symm, hord_fwd_x_en.2.symm⟩
      -- b_resp vs sel ordering for Fin (n+1).
      have full_b_sel : ∀ (k : Fin (n + 1)),
          (extendPoint b_resp < a_bwd k ↔ extendPoint b_sp < a'_resp k) ∧
          (extendPoint b_resp = a_bwd k ↔ extendPoint b_sp = a'_resp k) := by
        intro k
        by_cases hk : k.val < n
        · rw [show a'_resp k = resp_left ⟨k.val, hk⟩ from by simp [a'_resp, hk]]
          exact pivot_chain_order' hb_resp_in.2 (hd_le_sel ⟨k.val, hk⟩) hbc
            (hc_le_rl ⟨k.val, hk⟩) sig_b_d (tau_d_sel ⟨k.val, hk⟩)
        · rw [show a'_resp k = e_n from by simp [a'_resp, hk],
              show k = ⟨n, by omega⟩ from Fin.ext (Nat.eq_of_lt_succ_of_not_lt k.isLt hk), hp_n]
          exact pivot_chain_order' hb_resp_in.2 hd_le_pn hbc hc_le_en
            sig_b_d ⟨hord_cd_en_pn.1.symm, hord_cd_en_pn.2.symm⟩
      -- y vs sel ordering for Fin (n+1).
      have sel_y_ord : ∀ (k : Fin n),
          (a_init k < y' ↔ resp_left k < y) ∧
          (a_init k = y' ↔ resp_left k = y) := by
        intro k
        exact pivot_chain_order' (h_ainit_le_pn k) h_pn_le_y'
          ((hresp_left_in k).2) h_en_le_y
          (hord_left_sel_pn k) ⟨hord_fwd_en_y.1.symm, hord_fwd_en_y.2.symm⟩
      have full_y_sel : ∀ (k : Fin (n + 1)),
          (y' < a_bwd k ↔ y < a'_resp k) ∧
          (y' = a_bwd k ↔ y = a'_resp k) := by
        intro k
        by_cases hk : k.val < n
        · rw [show a'_resp k = resp_left ⟨k.val, hk⟩ from by simp [a'_resp, hk]]
          exact order_reverse (sel_y_ord ⟨k.val, hk⟩)
        · rw [show a'_resp k = e_n from by simp [a'_resp, hk],
              show k = ⟨n, by omega⟩ from Fin.ext (Nat.eq_of_lt_succ_of_not_lt k.isLt hk), hp_n]
          exact order_reverse ⟨hord_fwd_en_y.1.symm, hord_fwd_en_y.2.symm⟩
      -- Apply the same_order_type_of_cases helper.
      exact same_order_type_of_cases sig_x_b
        ⟨hord_fwd_x_y.1.symm, hord_fwd_x_y.2.symm⟩
        (pivot_chain_order' hb_resp_in.2 props.hdy' hbc props.hcy sig_b_d tau_d_y')
        full_x_sel full_b_sel full_y_sel full_sel_sel
    · -- gap_point_agreement (n+1): Case A
      intro i
      simp only [game_tuple]
      split_ifs with h0 hn1 hn2
      · exact ⟨hgp_fwd_x.1.symm, hgp_fwd_x.2.symm⟩
      · constructor
        · exact ⟨fun _ => ⟨b_sp, rfl⟩, fun _ => ⟨b_resp, rfl⟩⟩
        · constructor <;> intro ⟨g, hg⟩ <;> cases hg
      · exact ⟨hgp_fwd_y.1.symm, hgp_fwd_y.2.symm⟩
      · -- Inner position: use tau_left's gap/point data uniformly.
        by_cases hlt : i.val - 1 < n
        · simp only [a'_resp, show (i.val - 1 : Nat) < n from hlt, dite_true]
          have hleft_gp := _hgp_left ⟨1 + (i.val - 1), by omega⟩
          simp only [game_tuple, show 1 + (i.val - 1) ≠ 0 from by omega,
                     show ¬(1 + (i.val - 1) = n + 1) from by omega,
                     show ¬(1 + (i.val - 1) = n + 2) from by omega,
                     dite_false, show 1 + (i.val - 1) - 1 = i.val - 1 from by omega] at hleft_gp
          exact hleft_gp
        · -- i-1 = n: a_bwd(n)/e_n — both points
          have hi_eq : i.val - 1 = n := by omega
          have hab : (a_bwd ⟨i.val - 1, by omega⟩ : ExtendedCarrier N atomMap r) =
                     a_bwd ⟨n, by omega⟩ := by congr 1; exact Fin.ext hi_eq
          rw [hab, hp_n]
          simp only [a'_resp, show ¬(i.val - 1 < n) from hlt, dite_false]
          exact ⟨⟨fun _ => ⟨e_n_pt, rfl⟩, fun _ => ⟨p_n, rfl⟩⟩,
                 ⟨fun ⟨g, hg⟩ => absurd hg Sum.inl_ne_inr, fun ⟨g, hg⟩ => absurd hg Sum.inl_ne_inr⟩⟩
    · -- formula_agreement (n+1): Case A
      intro i A hA
      simp only [game_tuple]
      split_ifs with h0 hn1 hn2
      · exact (hform_fwd_x A hA).symm
      · -- b_resp/b_sp from sigma
        have hsig_b := hform_sig ⟨n + 1, by omega⟩ A hA
        simp_game_tuple at hsig_b; exact hsig_b
      · exact (hform_fwd_y A hA).symm
      · -- Inner position: use tau_left's formula data uniformly.
        by_cases hlt : i.val - 1 < n
        · simp only [a'_resp, show (i.val - 1 : Nat) < n from hlt, dite_true]
          have hleft_form := hform_left ⟨1 + (i.val - 1), by omega⟩ A hA
          simp only [game_tuple, show 1 + (i.val - 1) ≠ 0 from by omega,
                     show ¬(1 + (i.val - 1) = n + 1) from by omega,
                     show ¬(1 + (i.val - 1) = n + 2) from by omega,
                     dite_false, show 1 + (i.val - 1) - 1 = i.val - 1 from by omega] at hleft_form
          exact hleft_form
        · have hi_eq : i.val - 1 = n := by omega
          have hab : (a_bwd ⟨i.val - 1, by omega⟩ : ExtendedCarrier N atomMap r) =
                     a_bwd ⟨n, by omega⟩ := by congr 1; exact Fin.ext hi_eq
          rw [hab]
          simp only [a'_resp, show ¬(i.val - 1 < n) from hlt, dite_false]
          exact (hform_en_an A hA).symm
  · -- ================================================================
    -- Case B: b_sp > c. Use tau_left or tau_right for round 2.
    -- resp_left used directly (no resp_mod indirection).
    -- ================================================================
    push_neg at hbc
    have hc_lt_bsp : c < extendPoint (sig := sig) (atomMap := atomMap) (r := r) b_sp := hbc
    -- Sub-split on b_sp vs e_n for round 2 dispatch.
    rcases le_or_gt (extendPoint (sig := sig) (atomMap := atomMap) (r := r) b_sp) e_n with hbe | heb
    · -- Sub-case B1: b_sp ≤ e_n. Use tau_left for Round 2.
      have hb_sp_ce : inClosedInterval c e_n (extendPoint b_sp) :=
        ⟨le_of_lt hc_lt_bsp, hbe⟩
      obtain ⟨b_resp, hb_resp_in, hcond_left_b⟩ := hwin_left b_sp hb_sp_ce
      refine ⟨b_resp, ⟨le_trans props.hx'd hb_resp_in.1, le_trans hb_resp_in.2 h_pn_le_y'⟩, ?_⟩
      obtain ⟨hord_left_b, hgp_left_b, hform_left_b⟩ := hcond_left_b
      -- All orderings from tau_left (b-challenge variant).
      have tau_d_b : (d < extendPoint b_resp ↔ c < extendPoint b_sp) ∧
          (d = extendPoint b_resp ↔ c = extendPoint b_sp) := by
        have h := hord_left_b ⟨0, by omega⟩ ⟨n + 1, by omega⟩
        simp_game_tuple at h; exact h
      have tau_b_pn :
          ((extendPoint (sig := sig) (atomMap := atomMap) (r := r) b_resp : ExtendedCarrier N
              atomMap r) <
           extendPoint p_n ↔
           (extendPoint (sig := sig) (atomMap := atomMap) (r := r) b_sp : ExtendedCarrier M atomMap
               r) <
           e_n) ∧
          ((extendPoint (sig := sig) (atomMap := atomMap) (r := r) b_resp : ExtendedCarrier N
              atomMap r) =
           extendPoint p_n ↔
           (extendPoint (sig := sig) (atomMap := atomMap) (r := r) b_sp : ExtendedCarrier M atomMap
               r) =
           e_n) := by
        have h := hord_left_b ⟨n + 1, by omega⟩ ⟨n + 2, by omega⟩
        simp_game_tuple at h; exact h
      have tau_sel_b : ∀ (k : Fin n),
          (a_init k < (extendPoint (sig := sig) (atomMap := atomMap) (r := r) b_resp :
            ExtendedCarrier N atomMap r) ↔
           resp_left k < (extendPoint (sig := sig) (atomMap := atomMap) (r := r) b_sp :
            ExtendedCarrier M atomMap r)) ∧
          (a_init k = (extendPoint (sig := sig) (atomMap := atomMap) (r := r) b_resp :
            ExtendedCarrier N atomMap r) ↔
           resp_left k = (extendPoint (sig := sig) (atomMap := atomMap) (r := r) b_sp :
            ExtendedCarrier M atomMap r)) := by
        intro k; have h := hord_left_b ⟨1 + k.val, by omega⟩ ⟨n + 1, by omega⟩
        simp_game_tuple at h; exact h
      -- sigma_x_d for Case B1
      have sig_x_d : (x' < d ↔ x < c) ∧ (x' = d ↔ x = c) := by
        rcases props.h_pt_xc with ⟨p_xc, hp_xc⟩ | ⟨hxc_eq, hx'd_eq, _, _⟩
        · obtain ⟨_resp_sig_b1, _, hwin_sig_b1⟩ :=
            sigma_r (fun _ : Fin n => d) (fun _ => ⟨props.hx'd, le_refl d⟩)
          obtain ⟨_b_sig_b1, _, hcond_sig_b1⟩ := hwin_sig_b1 p_xc hp_xc
          obtain ⟨hord_sig_b1, _, _⟩ := hcond_sig_b1
          have h := hord_sig_b1 ⟨0, by omega⟩ ⟨n + 2, by omega⟩
          simp_game_tuple at h; exact h
        · subst hxc_eq; subst hx'd_eq
          exact ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
                 ⟨fun _ => rfl, fun _ => rfl⟩⟩
      -- tau_left orderings — used uniformly.
      have hd_le_sel : ∀ (k : Fin n), d ≤ a_init k := fun k => (ha_init k).1
      have hc_le_rl : ∀ (k : Fin n), c ≤ resp_left k := fun k => (hresp_left_in k).1
      have tau_d_sel : ∀ (k : Fin n),
          (d < a_init k ↔ c < resp_left k) ∧ (d = a_init k ↔ c = resp_left k) := by
        intro k; have h := hord_left ⟨0, by omega⟩ ⟨1 + k.val, by omega⟩
        simp_game_tuple at h; exact h
      have tau_sel_sel : ∀ (j j' : Fin n),
          (a_init j < a_init j' ↔ resp_left j < resp_left j') ∧
          (a_init j = a_init j' ↔ resp_left j = resp_left j') := by
        intro j j'
        have h := hord_left ⟨1 + j.val, by omega⟩ ⟨1 + j'.val, by omega⟩
        simp_game_tuple at h; exact h
      have sel_y_ord : ∀ (k : Fin n),
          (a_init k < y' ↔ resp_left k < y) ∧
          (a_init k = y' ↔ resp_left k = y) := by
        intro k
        exact pivot_chain_order' (h_ainit_le_pn k) h_pn_le_y'
          ((hresp_left_in k).2) h_en_le_y
          (hord_left_sel_pn k) ⟨hord_fwd_en_y.1.symm, hord_fwd_en_y.2.symm⟩
      refine ⟨?_, ?_, ?_⟩
      · -- same_order_type (n+1): Case B1
        have full_sel_sel : ∀ (k k' : Fin (n + 1)),
            (a_bwd k < a_bwd k' ↔ a'_resp k < a'_resp k') ∧
            (a_bwd k = a_bwd k' ↔ a'_resp k = a'_resp k') := by
          intro k k'
          by_cases hk : k.val < n <;> by_cases hk' : k'.val < n
          · rw [show a'_resp k = resp_left ⟨k.val, hk⟩ from by simp [a'_resp, hk],
                show a'_resp k' = resp_left ⟨k'.val, hk'⟩ from by simp [a'_resp, hk']]
            exact tau_sel_sel ⟨k.val, hk⟩ ⟨k'.val, hk'⟩
          · have : k' = ⟨n, by omega⟩ := Fin.ext (Nat.eq_of_lt_succ_of_not_lt k'.isLt hk')
            rw [show a'_resp k = resp_left ⟨k.val, hk⟩ from by simp [a'_resp, hk],
                show a'_resp k' = e_n from by simp [a'_resp, hk'], this, hp_n]
            exact hord_left_sel_pn ⟨k.val, hk⟩
          · have : k = ⟨n, by omega⟩ := Fin.ext (Nat.eq_of_lt_succ_of_not_lt k.isLt hk)
            rw [show a'_resp k = e_n from by simp [a'_resp, hk],
                show a'_resp k' = resp_left ⟨k'.val, hk'⟩ from by simp [a'_resp, hk'], this, hp_n]
            exact order_reverse (hord_left_sel_pn ⟨k'.val, hk'⟩)
          · rw [show a'_resp k = e_n from by simp [a'_resp, hk],
                show a'_resp k' = e_n from by simp [a'_resp, hk']]
            have hkeq : k = ⟨n, by omega⟩ := Fin.ext (Nat.eq_of_lt_succ_of_not_lt k.isLt hk)
            have hk'eq : k' = ⟨n, by omega⟩ := Fin.ext (Nat.eq_of_lt_succ_of_not_lt k'.isLt hk')
            rw [hkeq, hk'eq]; exact order_refl_pair _ _
        have full_x_sel : ∀ (k : Fin (n + 1)),
            (x' < a_bwd k ↔ x < a'_resp k) ∧ (x' = a_bwd k ↔ x = a'_resp k) := by
          intro k; by_cases hk : k.val < n
          · rw [show a'_resp k = resp_left ⟨k.val, hk⟩ from by simp [a'_resp, hk]]
            exact pivot_chain_order' props.hx'd (hd_le_sel ⟨k.val, hk⟩) props.hxc
              (hc_le_rl ⟨k.val, hk⟩) sig_x_d (tau_d_sel ⟨k.val, hk⟩)
          · rw [show a'_resp k = e_n from by simp [a'_resp, hk],
                show k = ⟨n, by omega⟩ from Fin.ext (Nat.eq_of_lt_succ_of_not_lt k.isLt hk), hp_n]
            exact ⟨hord_fwd_x_en.1.symm, hord_fwd_x_en.2.symm⟩
        have full_b_sel : ∀ (k : Fin (n + 1)),
            (extendPoint b_resp < a_bwd k ↔ extendPoint b_sp < a'_resp k) ∧
            (extendPoint b_resp = a_bwd k ↔ extendPoint b_sp = a'_resp k) := by
          intro k; by_cases hk : k.val < n
          · -- b_resp vs a_init(k) / b_sp vs resp_left(k): reverse of sel_b
            rw [show a'_resp k = resp_left ⟨k.val, hk⟩ from by simp [a'_resp, hk]]
            exact order_reverse (tau_sel_b ⟨k.val, hk⟩)
          · rw [show a'_resp k = e_n from by simp [a'_resp, hk],
                show k = ⟨n, by omega⟩ from Fin.ext (Nat.eq_of_lt_succ_of_not_lt k.isLt hk), hp_n]
            exact tau_b_pn
        have full_y_sel : ∀ (k : Fin (n + 1)),
            (y' < a_bwd k ↔ y < a'_resp k) ∧ (y' = a_bwd k ↔ y = a'_resp k) := by
          intro k; by_cases hk : k.val < n
          · rw [show a'_resp k = resp_left ⟨k.val, hk⟩ from by simp [a'_resp, hk]]
            exact order_reverse (sel_y_ord ⟨k.val, hk⟩)
          · rw [show a'_resp k = e_n from by simp [a'_resp, hk],
                show k = ⟨n, by omega⟩ from Fin.ext (Nat.eq_of_lt_succ_of_not_lt k.isLt hk), hp_n]
            exact order_reverse ⟨hord_fwd_en_y.1.symm, hord_fwd_en_y.2.symm⟩
        have hord_by : (extendPoint b_resp < y' ↔ extendPoint b_sp < y) ∧
            (extendPoint b_resp = y' ↔ extendPoint b_sp = y) :=
          pivot_chain_order' hb_resp_in.2 h_pn_le_y' hbe h_en_le_y
            tau_b_pn ⟨hord_fwd_en_y.1.symm, hord_fwd_en_y.2.symm⟩
        have hord_xb : (x' < extendPoint b_resp ↔ x < extendPoint b_sp) ∧
            (x' = extendPoint b_resp ↔ x = extendPoint b_sp) :=
          pivot_chain_order' props.hx'd hb_resp_in.1 props.hxc (le_of_lt hc_lt_bsp)
            sig_x_d tau_d_b
        exact same_order_type_of_cases hord_xb
          ⟨hord_fwd_x_y.1.symm, hord_fwd_x_y.2.symm⟩ hord_by
          full_x_sel full_b_sel full_y_sel full_sel_sel
      · -- gap_point_agreement (n+1): Case B1
        intro i
        simp only [game_tuple]
        split_ifs with h0 hn1 hn2
        · exact ⟨hgp_fwd_x.1.symm, hgp_fwd_x.2.symm⟩
        · constructor
          · exact ⟨fun _ => ⟨b_sp, rfl⟩, fun _ => ⟨b_resp, rfl⟩⟩
          · constructor <;> intro ⟨g, hg⟩ <;> cases hg
        · exact ⟨hgp_fwd_y.1.symm, hgp_fwd_y.2.symm⟩
        · by_cases hlt : i.val - 1 < n
          · simp only [a'_resp, show (i.val - 1 : Nat) < n from hlt, dite_true]
            have hleft_gp := _hgp_left ⟨1 + (i.val - 1), by omega⟩
            simp only [game_tuple, show 1 + (i.val - 1) ≠ 0 from by omega,
                       show ¬(1 + (i.val - 1) = n + 1) from by omega,
                       show ¬(1 + (i.val - 1) = n + 2) from by omega,
                       dite_false, show 1 + (i.val - 1) - 1 = i.val - 1 from by omega] at hleft_gp
            exact hleft_gp
          · have hi_eq : i.val - 1 = n := by omega
            have hab : (a_bwd ⟨i.val - 1, by omega⟩ : ExtendedCarrier N atomMap r) =
                       a_bwd ⟨n, by omega⟩ := by congr 1; exact Fin.ext hi_eq
            rw [hab, hp_n]
            simp only [a'_resp, show ¬(i.val - 1 < n) from hlt, dite_false]
            exact ⟨⟨fun _ => ⟨e_n_pt, rfl⟩, fun _ => ⟨p_n, rfl⟩⟩,
                   ⟨fun ⟨g, hg⟩ => absurd hg Sum.inl_ne_inr, fun ⟨g, hg⟩ => absurd hg
                       Sum.inl_ne_inr⟩⟩
      · -- formula_agreement (n+1): Case B1
        intro i A hA
        simp only [game_tuple]
        split_ifs with h0 hn1 hn2
        · exact (hform_fwd_x A hA).symm
        · have htau_b := hform_left_b ⟨n + 1, by omega⟩ A hA
          simp_game_tuple at htau_b; exact htau_b
        · exact (hform_fwd_y A hA).symm
        · by_cases hlt : i.val - 1 < n
          · simp only [a'_resp, show (i.val - 1 : Nat) < n from hlt, dite_true]
            have hleft_form := hform_left_b ⟨1 + (i.val - 1), by omega⟩ A hA
            simp only [game_tuple, show 1 + (i.val - 1) ≠ 0 from by omega,
                       show ¬(1 + (i.val - 1) = n + 1) from by omega,
                       show ¬(1 + (i.val - 1) = n + 2) from by omega,
                       dite_false, show 1 + (i.val - 1) - 1 = i.val - 1 from by omega] at hleft_form
            exact hleft_form
          · have hi_eq : i.val - 1 = n := by omega
            have hab : (a_bwd ⟨i.val - 1, by omega⟩ : ExtendedCarrier N atomMap r) =
                       a_bwd ⟨n, by omega⟩ := by congr 1; exact Fin.ext hi_eq
            rw [hab]
            simp only [a'_resp, show ¬(i.val - 1 < n) from hlt, dite_false]
            exact (hform_en_an A hA).symm
    · -- Sub-case B2: b_sp > e_n. Use tau_right for Round 2.
      -- Orderings: resp_left(k) ≤ e_n < b_sp, so b_sp > all resp_left values.
      have hb_sp_ey : inClosedInterval e_n y (extendPoint b_sp) :=
        ⟨le_of_lt heb, hb_sp.2⟩
      obtain ⟨_resp_right_dummy, _, hwin_right⟩ := tau_right
        (fun _ : Fin n => extendPoint p_n) (fun _ => ⟨le_refl _, h_pn_le_y'⟩)
      obtain ⟨b_resp, hb_resp_in_R, hcond_right_b⟩ := hwin_right b_sp hb_sp_ey
      refine ⟨b_resp, ⟨le_trans props.hx'd (le_trans hd_le_pn hb_resp_in_R.1),
                        hb_resp_in_R.2⟩, ?_⟩
      obtain ⟨hord_right_b, hgp_right_b, hform_right_b⟩ := hcond_right_b
      refine ⟨?_, ?_, ?_⟩
      · -- same_order_type (n+1): Case B2
        have tau_pn_b :
            ((extendPoint (sig := sig) (atomMap := atomMap) (r := r) p_n : ExtendedCarrier N
                atomMap r) <
             extendPoint b_resp ↔ e_n < extendPoint b_sp) ∧
            ((extendPoint (sig := sig) (atomMap := atomMap) (r := r) p_n : ExtendedCarrier N
                atomMap r) =
             extendPoint b_resp ↔ e_n = extendPoint b_sp) := by
          have h := hord_right_b ⟨0, by omega⟩ ⟨n + 1, by omega⟩
          simp_game_tuple at h; exact h
        have tau_b_y' :
            ((extendPoint (sig := sig) (atomMap := atomMap) (r := r) b_resp : ExtendedCarrier N
                atomMap r) < y' ↔
             (extendPoint (sig := sig) (atomMap := atomMap) (r := r) b_sp : ExtendedCarrier M
                 atomMap r) < y) ∧
            ((extendPoint (sig := sig) (atomMap := atomMap) (r := r) b_resp : ExtendedCarrier N
                atomMap r) = y' ↔
             (extendPoint (sig := sig) (atomMap := atomMap) (r := r) b_sp : ExtendedCarrier M
                 atomMap r) = y) := by
          have h := hord_right_b ⟨n + 1, by omega⟩ ⟨n + 2, by omega⟩
          simp_game_tuple at h; exact h
        have sig_x_d : (x' < d ↔ x < c) ∧ (x' = d ↔ x = c) := by
          rcases props.h_pt_xc with ⟨p_xc, hp_xc⟩ | ⟨hxc_eq, hx'd_eq, _, _⟩
          · obtain ⟨_resp_sig_b2, _, hwin_sig_b2⟩ :=
              sigma_r (fun _ : Fin n => d) (fun _ => ⟨props.hx'd, le_refl d⟩)
            obtain ⟨_b_sig_b2, _, hcond_sig_b2⟩ := hwin_sig_b2 p_xc hp_xc
            obtain ⟨hord_sig_b2, _, _⟩ := hcond_sig_b2
            have h := hord_sig_b2 ⟨0, by omega⟩ ⟨n + 2, by omega⟩
            simp_game_tuple at h; exact h
          · subst hxc_eq; subst hx'd_eq
            exact ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
                   ⟨fun _ => rfl, fun _ => rfl⟩⟩
        have hord_xb : (x' < extendPoint b_resp ↔ x < extendPoint b_sp) ∧
            (x' = extendPoint b_resp ↔ x = extendPoint b_sp) :=
          pivot_chain_order' (le_trans props.hx'd hd_le_pn) hb_resp_in_R.1
            (le_trans props.hxc hc_le_en) (le_of_lt heb)
            (pivot_chain_order' props.hx'd hd_le_pn props.hxc hc_le_en
              sig_x_d ⟨hord_cd_en_pn.1.symm, hord_cd_en_pn.2.symm⟩)
            tau_pn_b
        -- tau_left orderings — used uniformly.
        have hd_le_sel : ∀ (k : Fin n), d ≤ a_init k := fun k => (ha_init k).1
        have hc_le_rl : ∀ (k : Fin n), c ≤ resp_left k := fun k => (hresp_left_in k).1
        have tau_d_sel : ∀ (k : Fin n),
            (d < a_init k ↔ c < resp_left k) ∧ (d = a_init k ↔ c = resp_left k) := by
          intro k; have h := hord_left ⟨0, by omega⟩ ⟨1 + k.val, by omega⟩
          simp_game_tuple at h; exact h
        have tau_sel_sel : ∀ (j j' : Fin n),
            (a_init j < a_init j' ↔ resp_left j < resp_left j') ∧
            (a_init j = a_init j' ↔ resp_left j = resp_left j') := by
          intro j j'
          have h := hord_left ⟨1 + j.val, by omega⟩ ⟨1 + j'.val, by omega⟩
          simp_game_tuple at h; exact h
        have sel_y_ord : ∀ (k : Fin n),
            (a_init k < y' ↔ resp_left k < y) ∧ (a_init k = y' ↔ resp_left k = y) := by
          intro k
          exact pivot_chain_order' (h_ainit_le_pn k) h_pn_le_y'
            ((hresp_left_in k).2) h_en_le_y
            (hord_left_sel_pn k) ⟨hord_fwd_en_y.1.symm, hord_fwd_en_y.2.symm⟩
        have hb_resp_gt_pn :
            (extendPoint (sig := sig) (atomMap := atomMap) (r := r) p_n : ExtendedCarrier N atomMap
                r) <
            extendPoint b_resp := tau_pn_b.1.mpr heb
        have full_sel_sel : ∀ (k k' : Fin (n + 1)),
            (a_bwd k < a_bwd k' ↔ a'_resp k < a'_resp k') ∧
            (a_bwd k = a_bwd k' ↔ a'_resp k = a'_resp k') := by
          intro k k'
          by_cases hk : k.val < n <;> by_cases hk' : k'.val < n
          · rw [show a'_resp k = resp_left ⟨k.val, hk⟩ from by simp [a'_resp, hk],
                show a'_resp k' = resp_left ⟨k'.val, hk'⟩ from by simp [a'_resp, hk']]
            exact tau_sel_sel ⟨k.val, hk⟩ ⟨k'.val, hk'⟩
          · have : k' = ⟨n, by omega⟩ := Fin.ext (Nat.eq_of_lt_succ_of_not_lt k'.isLt hk')
            rw [show a'_resp k = resp_left ⟨k.val, hk⟩ from by simp [a'_resp, hk],
                show a'_resp k' = e_n from by simp [a'_resp, hk'], this, hp_n]
            exact hord_left_sel_pn ⟨k.val, hk⟩
          · have : k = ⟨n, by omega⟩ := Fin.ext (Nat.eq_of_lt_succ_of_not_lt k.isLt hk)
            rw [show a'_resp k = e_n from by simp [a'_resp, hk],
                show a'_resp k' = resp_left ⟨k'.val, hk'⟩ from by simp [a'_resp, hk'], this, hp_n]
            exact order_reverse (hord_left_sel_pn ⟨k'.val, hk'⟩)
          · rw [show a'_resp k = e_n from by simp [a'_resp, hk],
                show a'_resp k' = e_n from by simp [a'_resp, hk']]
            have hkeq : k = ⟨n, by omega⟩ := Fin.ext (Nat.eq_of_lt_succ_of_not_lt k.isLt hk)
            have hk'eq : k' = ⟨n, by omega⟩ := Fin.ext (Nat.eq_of_lt_succ_of_not_lt k'.isLt hk')
            rw [hkeq, hk'eq]; exact order_refl_pair _ _
        have full_x_sel : ∀ (k : Fin (n + 1)),
            (x' < a_bwd k ↔ x < a'_resp k) ∧ (x' = a_bwd k ↔ x = a'_resp k) := by
          intro k; by_cases hk : k.val < n
          · rw [show a'_resp k = resp_left ⟨k.val, hk⟩ from by simp [a'_resp, hk]]
            exact pivot_chain_order' props.hx'd (hd_le_sel ⟨k.val, hk⟩) props.hxc
              (hc_le_rl ⟨k.val, hk⟩) sig_x_d (tau_d_sel ⟨k.val, hk⟩)
          · rw [show a'_resp k = e_n from by simp [a'_resp, hk],
                show k = ⟨n, by omega⟩ from Fin.ext (Nat.eq_of_lt_succ_of_not_lt k.isLt hk), hp_n]
            exact ⟨hord_fwd_x_en.1.symm, hord_fwd_x_en.2.symm⟩
        have full_b_sel : ∀ (k : Fin (n + 1)),
            (extendPoint b_resp < a_bwd k ↔ extendPoint b_sp < a'_resp k) ∧
            (extendPoint b_resp = a_bwd k ↔ extendPoint b_sp = a'_resp k) := by
          intro k; by_cases hk : k.val < n
          · -- b_resp > p_n ≥ a_init(k), b_sp > e_n ≥ resp_left(k). Both sides false.
            rw [show a'_resp k = resp_left ⟨k.val, hk⟩ from by simp [a'_resp, hk]]
            have h_bwd_lt : a_bwd k < extendPoint b_resp :=
              lt_of_le_of_lt (h_ainit_le_pn ⟨k.val, hk⟩) hb_resp_gt_pn
            have h_resp_lt : resp_left ⟨k.val, hk⟩ <
                (extendPoint (sig := sig) (atomMap := atomMap) (r := r) b_sp : ExtendedCarrier M
                    atomMap r) :=
              lt_of_le_of_lt (hresp_left_in ⟨k.val, hk⟩).2 heb
            exact ⟨⟨fun h => absurd h (not_lt.mpr (le_of_lt h_bwd_lt)),
                    fun h => absurd h (not_lt.mpr (le_of_lt h_resp_lt))⟩,
                   ⟨fun h => absurd h_bwd_lt (h ▸ lt_irrefl _),
                    fun h => absurd h_resp_lt (h ▸ lt_irrefl _)⟩⟩
          · rw [show a'_resp k = e_n from by simp [a'_resp, hk],
                show k = ⟨n, by omega⟩ from Fin.ext (Nat.eq_of_lt_succ_of_not_lt k.isLt hk), hp_n]
            exact order_reverse tau_pn_b
        have full_y_sel : ∀ (k : Fin (n + 1)),
            (y' < a_bwd k ↔ y < a'_resp k) ∧ (y' = a_bwd k ↔ y = a'_resp k) := by
          intro k; by_cases hk : k.val < n
          · rw [show a'_resp k = resp_left ⟨k.val, hk⟩ from by simp [a'_resp, hk]]
            exact order_reverse (sel_y_ord ⟨k.val, hk⟩)
          · rw [show a'_resp k = e_n from by simp [a'_resp, hk],
                show k = ⟨n, by omega⟩ from Fin.ext (Nat.eq_of_lt_succ_of_not_lt k.isLt hk), hp_n]
            exact order_reverse ⟨hord_fwd_en_y.1.symm, hord_fwd_en_y.2.symm⟩
        exact same_order_type_of_cases hord_xb
          ⟨hord_fwd_x_y.1.symm, hord_fwd_x_y.2.symm⟩ tau_b_y'
          full_x_sel full_b_sel full_y_sel full_sel_sel
      · -- gap_point_agreement (n+1): Case B2
        intro i
        simp only [game_tuple]
        split_ifs with h0 hn1 hn2
        · exact ⟨hgp_fwd_x.1.symm, hgp_fwd_x.2.symm⟩
        · constructor
          · exact ⟨fun _ => ⟨b_sp, rfl⟩, fun _ => ⟨b_resp, rfl⟩⟩
          · constructor <;> intro ⟨g, hg⟩ <;> cases hg
        · exact ⟨hgp_fwd_y.1.symm, hgp_fwd_y.2.symm⟩
        · by_cases hlt : i.val - 1 < n
          · simp only [a'_resp, show (i.val - 1 : Nat) < n from hlt, dite_true]
            have hleft_gp := _hgp_left ⟨1 + (i.val - 1), by omega⟩
            simp only [game_tuple, show 1 + (i.val - 1) ≠ 0 from by omega,
                       show ¬(1 + (i.val - 1) = n + 1) from by omega,
                       show ¬(1 + (i.val - 1) = n + 2) from by omega,
                       dite_false, show 1 + (i.val - 1) - 1 = i.val - 1 from by omega] at hleft_gp
            exact hleft_gp
          · have hi_eq : i.val - 1 = n := by omega
            have hab : (a_bwd ⟨i.val - 1, by omega⟩ : ExtendedCarrier N atomMap r) =
                       a_bwd ⟨n, by omega⟩ := by congr 1; exact Fin.ext hi_eq
            rw [hab, hp_n]
            simp only [a'_resp, show ¬(i.val - 1 < n) from hlt, dite_false]
            exact ⟨⟨fun _ => ⟨e_n_pt, rfl⟩, fun _ => ⟨p_n, rfl⟩⟩,
                   ⟨fun ⟨g, hg⟩ => absurd hg Sum.inl_ne_inr, fun ⟨g, hg⟩ => absurd hg
                       Sum.inl_ne_inr⟩⟩
      · -- formula_agreement (n+1): Case B2
        intro i A hA
        simp only [game_tuple]
        split_ifs with h0 hn1 hn2
        · exact (hform_fwd_x A hA).symm
        · have hform_b := hform_right_b ⟨n + 1, by omega⟩ A hA
          simp_game_tuple at hform_b; exact hform_b
        · exact (hform_fwd_y A hA).symm
        · by_cases hlt : i.val - 1 < n
          · simp only [a'_resp, show (i.val - 1 : Nat) < n from hlt, dite_true]
            have hleft_form := hform_left ⟨1 + (i.val - 1), by omega⟩ A hA
            simp only [game_tuple, show 1 + (i.val - 1) ≠ 0 from by omega,
                       show ¬(1 + (i.val - 1) = n + 1) from by omega,
                       show ¬(1 + (i.val - 1) = n + 2) from by omega,
                       dite_false, show 1 + (i.val - 1) - 1 = i.val - 1 from by omega] at hleft_form
            exact hleft_form
          · have hi_eq : i.val - 1 = n := by omega
            have hab : (a_bwd ⟨i.val - 1, by omega⟩ : ExtendedCarrier N atomMap r) =
                       a_bwd ⟨n, by omega⟩ := by congr 1; exact Fin.ext hi_eq
            rw [hab]
            simp only [a'_resp, show ¬(i.val - 1 < n) from hlt, dite_false]
            exact (hform_en_an A hA).symm
/- OLD CASE II PROOF DELETED. See git history for reference. -/

end Bimodal.Metalogic.WeakCanonical
