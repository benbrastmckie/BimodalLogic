import Bimodal.Metalogic.WeakCanonical.Expressiveness.SplitPoint
import Bimodal.Metalogic.WeakCanonical.EFGames.Composition
import Mathlib.Data.Fin.Tuple.Sort

/-!
# Case Analysis: Cases I, II, III-IV for the Inductive Step

Case analysis: Cases I, II, III-IV for the inductive step of Theorem 6.
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-- In a gap's cut, every element has a strictly larger element in the cut.
    Follows from `Gap.no_sup`: if all elements were ≤ a, then a would be a LUB in the cut. -/
private theorem gap_cut_exists_gt {T : Type} [LinearOrder T] (γ : Gap T) (a : T) (ha : a ∈ γ.cut) :
    ∃ b, b ∈ γ.cut ∧ a < b := by
  by_contra h
  push_neg at h
  apply γ.no_sup
  refine ⟨a, ?_, ha⟩
  constructor
  · intro b hb; exact h b hb
  · intro c hc; exact hc ha

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

set_option maxHeartbeats 800000

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
    {atomMap : Formula → sig.preds} {n r delta : Nat}
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r}
    {d : ExtendedCarrier N atomMap r}
    {a_bwd : Fin (n + 1) → ExtendedCarrier N atomMap r}
    (props : SplitPointProps n delta x y x' y' c d a_bwd)
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
  -- Phase R2: sigma/tau are now at rank r+delta on rank-embedded positions.
  -- Phase R3 will add rank projection (rank_down for delta>0, or cast for delta=0).
  have sigma_reduced : ghr93_duplicator_wins N M atomMap L.card r x' d x c := by
    sorry
  have tau_reduced : ghr93_duplicator_wins N M atomMap R.card r d y' c y := by
    sorry
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
          show (R.card + 2 : Nat) = R.card + 2 from rfl, dite_true, dite_false] at this
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
          show (R.card + 2 : Nat) = R.card + 2 from rfl, dite_true, dite_false] at this
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
        show (L.card + 1 : Nat) = L.card + 1 from rfl, dite_true] at this
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
        hi0 hj0 _ _ _ hjb _ hjy _ hjd _ _ hib hj0 _ _ _ hjb _ hjy _ hjd _ _
        hiy hj0 _ _ _ hjb _ hjy _ hjd _ _ _ hid hj0 _ _ _ hjb _ hjy _ hjd _ _
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
            simp only [a'_resp, hjd', dite_true]
            set kj := isoL.symm ⟨j', hj_mem⟩
            have hj_eq : a_bwd j' = a_sigma kj := by
              simp only [a_sigma]; congr 1; exact (heL_inv j' hj_mem).symm
            rw [hj_eq]; exact sig_sel_sel ki kj
          · have hj_mem : j' ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd'⟩
            simp only [a'_resp, hjd', dite_false]
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
            simp only [a'_resp, hjd', dite_true]
            set kj := isoL.symm ⟨j', hj_mem⟩
            have hj_eq : a_bwd j' = a_sigma kj := by
              simp only [a_sigma]; congr 1; exact (heL_inv j' hj_mem).symm
            rw [hj_eq]
            exact pivot_chain_order_rev' (hd_le_a_tau ki) (ha_sig_le_d kj)
              (hc_le_rR ki) (hresp_L_le_c kj) (tau_d_sel ki) (sig_sel_d kj)
          · have hj_mem : j' ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd'⟩
            simp only [a'_resp, hjd', dite_false]
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
        show (R.card + 2 : Nat) = R.card + 2 from rfl, dite_true, dite_false] at this
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
        show (R.card + 2 : Nat) = R.card + 2 from rfl, dite_true, dite_false] at this
      exact this
    have hform_b_R : ∀ A, stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r (extendPoint b_resp_R) A ↔
         stavi_temporal_truth_mu M atomMap r (extendPoint b_sp) A) := by
      intro A hA
      have := hform_R ⟨R.card + 1, by omega⟩ A hA
      simp only [game_tuple, show (R.card + 1 : Nat) ≠ 0 from by omega,
        show (R.card + 1 : Nat) = R.card + 1 from rfl, dite_true] at this
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
        hi0 hj0 _ _ _ hjb _ hjy _ hjd _ _ hib hj0 _ _ _ hjb _ hjy _ hjd _ _
        hiy hj0 _ _ _ hjb _ hjy _ hjd _ _ _ hid hj0 _ _ _ hjb _ hjy _ hjd _ _
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
            simp only [a'_resp, hjd', dite_true]
            set kj := isoL.symm ⟨j', hj_mem⟩
            have hj_eq : a_bwd j' = a_sigma kj := by
              simp only [a_sigma]; congr 1; exact (heL_inv j' hj_mem).symm
            rw [hj_eq]; exact sig_sel_sel ki kj
          · have hj_mem : j' ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd'⟩
            simp only [a'_resp, hjd', dite_false]
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
            simp only [a'_resp, hjd', dite_true]
            set kj := isoL.symm ⟨j', hj_mem⟩
            have hj_eq : a_bwd j' = a_sigma kj := by
              simp only [a_sigma]; congr 1; exact (heL_inv j' hj_mem).symm
            rw [hj_eq]
            exact pivot_chain_order_rev (hd_le_a_tau ki) (ha_sig_le_d kj)
              (hc_le_rR ki) (hresp_L_le_c' kj)
              (tau_d_sel ki).1 (tau_d_sel ki).2
              (sig_sel_d kj).1 (sig_sel_d kj).2
          · have hj_mem : j' ∈ R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, hjd'⟩
            simp only [a'_resp, hjd', dite_false]
            set kj := isoR.symm ⟨j', hj_mem⟩
            have hj_eq : a_bwd j' = a_tau kj := by
              simp only [a_tau]; congr 1; exact (heR_inv j' hj_mem).symm
            rw [hj_eq]; exact tau_sel_sel ki kj
    · -- gap_point_agreement (n+1)
      exact gap_point_agreement_of_cases hgp_x_R hgp_b_R hgp_y_R hgp_sel_R
    · -- formula_agreement (n+1)
      exact formula_agreement_of_cases hform_x_R hform_b_R hform_y_R hform_sel_R

/-! ### Case II: a_n is a Point

When ALL of Spoiler's backward selections a_0,...,a_n lie in [d,y']
and a_n (= d) is an actual point, Duplicator applies τ to the init
sub-sequence a_0,...,a_{n-1} (n elements, fitting τ's n-round game
on [d,y']/[c,y]).  For the last selection a_n = d, Duplicator responds
with c (the corresponding split point in M).

Since d = a_bwd(n) from obtain_split_point_props, and d is a point,
the gap/point and formula agreement at the n-th position follow from
the properties established during the split point construction.

Round 2 is delegated to τ when b_sp ∈ [c,y], and to σ when b_sp ∈ [x,c).
The winning condition is assembled from τ's winning condition at the
init indices plus the (c,d) correspondence at the n-th index. -/

set_option maxHeartbeats 1600000

/-- **Case II helper**: When all selections lie in [d,y'] and a_n is a
    point, construct Duplicator's response using τ on the init sub-sequence
    and c as the response for a_n = d.

    The proof applies τ to a_0,...,a_{n-1}, sets a'_resp(n) = c,
    and transfers the winning condition from τ's n-round game to the
    full (n+1)-round game by injecting the (c,d) boundary pair. -/
private theorem ghr93_case_II {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {n r delta : Nat}
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r}
    {d : ExtendedCarrier N atomMap r}
    {a_bwd : Fin (n + 1) → ExtendedCarrier N atomMap r}
    (props : SplitPointProps n delta x y x' y' c d a_bwd)
    (ha_bwd : ∀ i, inClosedInterval x' y' (a_bwd i))
    (h_no_split : ∀ i : Fin (n + 1), d ≤ a_bwd i)
    (h_point : IsPoint (a_bwd ⟨n, by omega⟩))
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
  -- GHR93 Case II: Phase R2 temporarily sorry'd.
  -- Phase R3 will rewrite this using tau at rank r+delta for full rank-r
  -- type formula transfer via U(B, sf_top).
  -- The old proof used char_k (insufficient depth) and h_ih_r2 (unnecessary
  -- with delta-aware IH). These parameters have been removed from the
  -- signature. The rewrite will use props.tau at rank r+delta directly.
  sorry
/- OLD CASE II PROOF (removed in Phase R2, to be rewritten in Phase R3):
  let a_init : Fin n → ExtendedCarrier N atomMap r :=
    fun k => a_bwd ⟨k.val, by omega⟩
  have ha_init : ∀ k, inClosedInterval d y' (a_init k) := by
    intro k
    exact ⟨h_no_split ⟨k.val, by omega⟩, (ha_bwd ⟨k.val, by omega⟩).2⟩
  obtain ⟨resp_tau, hresp_tau_in, hwin_tau⟩ := props.tau a_init ha_init
  -- resp_tau : Fin n → ExtendedCarrier M atomMap r, all in [c, y]
  -- Step 3: Construct e_n using the (n+1)-round forward game.
  -- a_bwd(n) is a carrier point p_n in [d, y'] ⊆ [x', y'].
  obtain ⟨p_n, hp_n⟩ := h_point
  have hp_n_in : inClosedInterval x' y' (extendPoint p_n) := by
    have := ha_bwd ⟨n, by omega⟩; rw [hp_n] at this; exact this
  -- Build M-side selections: resp_tau(i) for i < n, then c at position n.
  -- This allows the forward game to produce N-side responses that correspond
  -- to the tau sub-game, then we use round 2 with p_n for the e_n match.
  let a_M : Fin (n + 1) → ExtendedCarrier M atomMap r := fun i =>
    if h : i.val < n then resp_tau ⟨i.val, h⟩ else c
  have ha_M : ∀ i, inClosedInterval x y (a_M i) := by
    intro i; simp only [a_M]
    split
    case isTrue h =>
      have := hresp_tau_in ⟨i.val, h⟩
      exact ⟨le_trans props.hxc this.1, this.2⟩
    case isFalse _ => exact props.hc_interval
  -- Play the d-compatible (1+3n+1)-round forward game to get e_n AND
  -- the cross-boundary ordering (d < p_n ↔ c < e_n).
  -- Step 3a: Pad a_M to (1+3n+1) elements with c at position 1+3n.
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
  -- Step 3b: Apply d-compatible strategy.
  obtain ⟨a'_big, ha'_big, hwin_big, hd_eq_big⟩ :=
    props.h_d_compat_left a_pad_big ha_pad_big hpad_last
  -- Step 3c: Challenge with p_n to get e_n_pt.
  obtain ⟨e_n_pt, he_n_pt_in, hcond_big⟩ := hwin_big p_n hp_n_in
  let e_n : ExtendedCarrier M atomMap r := extendPoint e_n_pt
  have he_n_in : inClosedInterval x y e_n := he_n_pt_in
  -- Step 3d: Extract ordering and formula agreement from the big game.
  obtain ⟨hord_big, hgp_big, hform_big⟩ := hcond_big
  -- Position indices for the big game (a_pad_big : Fin (1+3*n+1)):
  -- b-position = (1+3*n+1)+1, y-position = (1+3*n+1)+2,
  -- last selection position in game_tuple = 1+(1+3*n) = 2+3*n.
  -- Formula agreement at b-position: e_n vs p_n.
  have hform_en_an : ∀ (A : StaviFormula), stavi_depth A ≤ r →
      (stavi_temporal_truth_mu M atomMap r e_n A ↔
       stavi_temporal_truth_mu N atomMap r (a_bwd ⟨n, by omega⟩) A) := by
    intro A hA
    have h := hform_big ⟨(1 + 3 * n + 1) + 1, by omega⟩ A hA
    simp only [game_tuple_b_eq] at h
    rw [hp_n]; exact h
  -- Cross-boundary ordering: (c < e_n ↔ d < p_n).
  -- Selection c at game_tuple position 1+(1+3*n) = 2+3*n.
  -- b-position at (1+3*n+1)+1.
  have hord_cd_en_pn : (c < e_n ↔ d < extendPoint p_n) ∧
      (c = e_n ↔ d = extendPoint p_n) := by
    have hord := hord_big ⟨1 + (1 + 3 * n), by omega⟩ ⟨(1 + 3 * n + 1) + 1, by omega⟩
    -- M-side at selection position: a_pad_big(1+3*n) = c
    -- M-side at selection position: unfold game_tuple, show a_pad_big(1+3*n) = c
    have hM_sel : game_tuple x y a_pad_big e_n_pt ⟨1 + (1 + 3 * n), by omega⟩ = c := by
      simp only [game_tuple, show 1 + (1 + 3 * n) ≠ 0 from by omega,
        show ¬(1 + (1 + 3 * n) = 1 + 3 * n + 1 + 1) from by omega,
        show ¬(1 + (1 + 3 * n) = 1 + 3 * n + 1 + 2) from by omega, dite_false]
      show a_pad_big ⟨1 + (1 + 3 * n) - 1, _⟩ = c
      simp only [a_pad_big, show ¬(1 + (1 + 3 * n) - 1 < n) from by omega,
        show ¬(1 + 3 * n < n) from by omega,
        show 1 + (1 + 3 * n) - 1 = 1 + 3 * n from by omega, dite_false, ite_true]
    have hM_b : game_tuple x y a_pad_big e_n_pt ⟨(1 + 3 * n + 1) + 1, by omega⟩ = e_n :=
      game_tuple_b_eq x y a_pad_big e_n_pt
    -- N-side at selection position: a'_big(1+3*n) = d
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
  -- Forward game orderings from the big game.
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
  -- Gap/point and formula agreement from big game for x/x' and y/y' positions.
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
  -- Step 3e: Extract big-game ordering between resp_tau(k) / a'_big(k) and e_n / p_n.
  -- For k < n, position (1+k) in the big game has a_pad_big(k) = resp_tau(k) on M-side
  -- and a'_big(k) on N-side. The b-position has e_n on M-side and p_n on N-side.
  -- This gives: resp_tau(k) < e_n ↔ a'_big(k) < p_n (and = variant).
  have hord_big_sel_en : ∀ (k : Fin n),
      (resp_tau k < e_n ↔ a'_big ⟨k.val, by omega⟩ < extendPoint p_n) ∧
      (resp_tau k = e_n ↔ a'_big ⟨k.val, by omega⟩ = extendPoint p_n) := by
    intro k
    have hord := hord_big ⟨1 + k.val, by omega⟩ ⟨(1 + 3 * n + 1) + 1, by omega⟩
    -- M-side at position (1+k): game_tuple x y a_pad_big e_n_pt ⟨1+k.val, _⟩
    --   = a_pad_big ⟨k.val, _⟩ = resp_tau ⟨k.val, _⟩ (since k.val < n)
    have hM_sel : game_tuple x y a_pad_big e_n_pt ⟨1 + k.val, by omega⟩ =
        resp_tau k := by
      simp only [game_tuple, show (1 + k.val : Nat) ≠ 0 from by omega,
        show ¬((1 + k.val : Nat) = 1 + 3 * n + 1 + 1) from by { have := k.isLt; omega },
        show ¬((1 + k.val : Nat) = 1 + 3 * n + 1 + 2) from by { have := k.isLt; omega },
        dite_false]
      show a_pad_big ⟨1 + k.val - 1, _⟩ = resp_tau k
      simp only [a_pad_big, show 1 + k.val - 1 = k.val from by omega,
        show k.val < n from k.isLt, dite_true]
    -- N-side at position (1+k): a'_big ⟨k.val, _⟩
    have hN_sel : game_tuple x' y' a'_big p_n ⟨1 + k.val, by omega⟩ =
        a'_big ⟨k.val, by omega⟩ := by
      simp only [game_tuple, show (1 + k.val : Nat) ≠ 0 from by omega,
        show ¬((1 + k.val : Nat) = 1 + 3 * n + 1 + 1) from by { have := k.isLt; omega },
        show ¬((1 + k.val : Nat) = 1 + 3 * n + 1 + 2) from by { have := k.isLt; omega },
        dite_false, show 1 + k.val - 1 = k.val from by omega]
    rw [hM_sel, game_tuple_b_eq, hN_sel, game_tuple_b_eq] at hord
    exact hord
  -- Step 3f: Hoist p_cy existence (needed for tau formula agreement, independent of b_sp).
  have ⟨p_cy_pre, hp_cy_pre⟩ : ∃ (p : M.carrier), inClosedInterval c y (extendPoint p) := by
    rcases props.h_pt_cy with ⟨p_cy, hp_cy⟩ | ⟨_, hdy'_eq, _, hgap_d⟩
    · exact ⟨p_cy, hp_cy⟩
    · -- d = y', d is gap, but a_bwd(n) ∈ [d, y'] = [d, d] is a point — contradiction
      obtain ⟨g_d, hg_d⟩ := hgap_d
      have ha_eq : a_bwd ⟨n, by omega⟩ = d :=
        le_antisymm (hdy'_eq ▸ (ha_bwd ⟨n, by omega⟩).2) (h_no_split ⟨n, by omega⟩)
      have : d = extendPoint p_n := ha_eq ▸ hp_n
      exact absurd (this.symm ▸ hg_d : extendPoint p_n = Sum.inr g_d) (by simp [extendPoint])
  -- Instantiate hwin_tau with p_cy_pre to get formula agreement at inner positions.
  obtain ⟨_b_tau_pre, _hb_tau_pre_in, hcond_tau_pre⟩ := hwin_tau p_cy_pre hp_cy_pre
  obtain ⟨_hord_tau_pre, _hgp_tau_pre, hform_tau_pre⟩ := hcond_tau_pre
  -- Formula agreement between a'_big(k) and a_init(k) at rank r.
  -- Both agree with resp_tau(k) at rank r (from big game and tau respectively),
  -- so they agree with each other.
  have hform_abig_ainit : ∀ (k : Fin n) (A : StaviFormula), stavi_depth A ≤ r →
      (stavi_temporal_truth_mu N atomMap r (a'_big ⟨k.val, by omega⟩) A ↔
       stavi_temporal_truth_mu N atomMap r (a_init k) A) := by
    intro k A hA
    -- From big game formula agreement at position (1+k):
    -- M resp_tau(k) ↔ N a'_big(k)
    have h_big : stavi_temporal_truth_mu M atomMap r (resp_tau k) A ↔
        stavi_temporal_truth_mu N atomMap r (a'_big ⟨k.val, by omega⟩) A := by
      have h := hform_big ⟨1 + k.val, by omega⟩ A hA
      -- M-side: game_tuple at (1+k) = a_pad_big(k) = resp_tau(k) for k < n
      have hM : game_tuple x y a_pad_big e_n_pt ⟨1 + k.val, by omega⟩ = resp_tau k := by
        simp only [game_tuple, show (1 + k.val : Nat) ≠ 0 from by omega,
          show ¬((1 + k.val : Nat) = 1 + 3 * n + 1 + 1) from by { have := k.isLt; omega },
          show ¬((1 + k.val : Nat) = 1 + 3 * n + 1 + 2) from by { have := k.isLt; omega },
          dite_false]
        show a_pad_big ⟨1 + k.val - 1, _⟩ = resp_tau k
        simp only [a_pad_big, show 1 + k.val - 1 = k.val from by omega,
          show k.val < n from k.isLt, dite_true]
      -- N-side: game_tuple at (1+k) = a'_big(k)
      have hN : game_tuple x' y' a'_big p_n ⟨1 + k.val, by omega⟩ =
          a'_big ⟨k.val, by omega⟩ := by
        simp only [game_tuple, show (1 + k.val : Nat) ≠ 0 from by omega,
          show ¬((1 + k.val : Nat) = 1 + 3 * n + 1 + 1) from by { have := k.isLt; omega },
          show ¬((1 + k.val : Nat) = 1 + 3 * n + 1 + 2) from by { have := k.isLt; omega },
          dite_false, show 1 + k.val - 1 = k.val from by omega]
      rw [hM, hN] at h; exact h
    -- From tau formula agreement at position (1+k):
    -- N a_init(k) ↔ M resp_tau(k)
    have h_tau : stavi_temporal_truth_mu N atomMap r (a_init k) A ↔
        stavi_temporal_truth_mu M atomMap r (resp_tau k) A := by
      have h := hform_tau_pre ⟨1 + k.val, by omega⟩ A hA
      simp_game_tuple at h; exact h
    -- Combine: a'_big(k) ↔ resp_tau(k) (from h_big.symm) ↔ a_init(k) (from h_tau.symm)
    exact h_big.symm.trans h_tau.symm
  -- Step 3g: Construct rank-(r+2) backward game tau_r2 on [d,y']/[c,y].
  -- GHR93 Case II requires a backward game at rank r+2 to transfer formulas
  -- of depth r+2 (specifically U(B, sf_top) where B has depth r).
  -- Construction: h_r1_univ gives (4+3n)-round forward at rank r+2,
  -- round_mono reduces to (1+3n) rounds, h_ih_r2 converts to n-round backward.
  have h_fwd_r2 : ghr93_duplicator_wins M N atomMap (4 + 3 * n) (r + 2)
      (rank_embed (by omega : r ≤ r + 2) c) (rank_embed (by omega : r ≤ r + 2) y)
      (rank_embed (by omega : r ≤ r + 2) d) (rank_embed (by omega : r ≤ r + 2) y') :=
    h_r1_univ r props.hcy props.hdy'
  have h_fwd_r2_mono : ghr93_duplicator_wins M N atomMap (1 + 3 * n) (r + 2)
      (rank_embed (by omega : r ≤ r + 2) c) (rank_embed (by omega : r ≤ r + 2) y)
      (rank_embed (by omega : r ≤ r + 2) d) (rank_embed (by omega : r ≤ r + 2) y') :=
    ghr93_duplicator_wins_round_mono (by omega : 1 + 3 * n ≤ 4 + 3 * n)
      ((rank_embed_le (by omega : r ≤ r + 2) c y).mpr props.hcy)
      ((rank_embed_le (by omega : r ≤ r + 2) d y').mpr props.hdy')
      h_fwd_r2
  -- Point witness in [rank_embed d, rank_embed y'] for h_ih_r2
  have h_pt_r2 : ∃ p, inClosedInterval (rank_embed (by omega : r ≤ r + 2) d)
      (rank_embed (by omega : r ≤ r + 2) y')
      (extendPoint (sig := sig) (atomMap := atomMap) (r := r + 2) p) := by
    refine ⟨p_n, ?_⟩
    have hpn_in_dy' : inClosedInterval d y' (extendPoint p_n) :=
      ⟨le_trans (h_no_split ⟨n, by omega⟩) (le_of_eq hp_n),
       le_trans (le_of_eq hp_n.symm) (ha_bwd ⟨n, by omega⟩).2⟩
    rw [show (extendPoint (r := r + 2) p_n : ExtendedCarrier N atomMap (r + 2)) =
            rank_embed (by omega : r ≤ r + 2) (extendPoint (r := r) p_n) from
          (rank_embed_point (by omega : r ≤ r + 2) p_n).symm]
    exact (rank_embed_inClosedInterval (by omega : r ≤ r + 2) d y' (extendPoint p_n)).mpr
      hpn_in_dy'
  -- tau_r2: n-round backward game at rank r+2 on [d,y']/[c,y] (rank-embedded)
  have tau_r2 : ghr93_duplicator_wins N M atomMap n (r + 2)
      (rank_embed (by omega : r ≤ r + 2) d) (rank_embed (by omega : r ≤ r + 2) y')
      (rank_embed (by omega : r ≤ r + 2) c) (rank_embed (by omega : r ≤ r + 2) y) :=
    h_ih_r2
      ((rank_embed_le (by omega : r ≤ r + 2) c y).mpr props.hcy)
      ((rank_embed_le (by omega : r ≤ r + 2) d y').mpr props.hdy')
      h_pt_r2 h_fwd_r2_mono
  -- tau_r2 is now available for same_side proofs via formula transfer at rank r+2.
  -- Phase 3C-EQ: Hoist c ≤ e_n and d ≤ p_n before resp_mod definition.
  have hd_le_pn : d ≤ extendPoint p_n := by
    have h := h_no_split ⟨n, by omega⟩; rw [hp_n] at h; exact h
  have hc_le_en : c ≤ e_n := by
    rcases lt_or_eq_of_le hd_le_pn with hlt | heq
    · exact le_of_lt (hord_cd_en_pn.1.mpr hlt)
    · exact le_of_eq (hord_cd_en_pn.2.mpr heq)
  -- Phase 3C-STRICT: Construct composed backward game on [d,y']/[c,y]
  -- with pivot p_n/e_n. GHR93 Prop 12.8.18 approach: sub-interval backward
  -- games composed at e_n/p_n. Resolves the depth-agreement gap.
  have h_en_le_y : e_n ≤ y := he_n_in.2
  have h_pn_le_y' : extendPoint p_n ≤ y' := hp_n_in.2
  -- Step S1: Left sub-interval backward game on [d, p_n]/[c, e_n]
  have tau_left : ghr93_duplicator_wins N M atomMap n r d (extendPoint p_n) c e_n :=
    ih hc_le_en hd_le_pn ⟨p_n, hd_le_pn, le_refl _⟩
      (ghr93_duplicator_wins_round_mono (by omega : 1 + 3 * n ≤ 4 + 3 * n) hc_le_en hd_le_pn
        (ghr93_duplicator_wins_rank_down (by omega : r ≤ r + 2) (by omega : r + 2 ≤ r + 2)
          hc_le_en hd_le_pn (h_r1_univ r hc_le_en hd_le_pn)))
  -- Step S2: Right sub-interval backward game on [p_n, y']/[e_n, y]
  have tau_right : ghr93_duplicator_wins N M atomMap n r (extendPoint p_n) y' e_n y :=
    ih h_en_le_y h_pn_le_y' ⟨p_n, le_refl _, h_pn_le_y'⟩
      (ghr93_duplicator_wins_round_mono (by omega : 1 + 3 * n ≤ 4 + 3 * n) h_en_le_y h_pn_le_y'
        (ghr93_duplicator_wins_rank_down (by omega : r ≤ r + 2) (by omega : r + 2 ≤ r + 2)
          h_en_le_y h_pn_le_y' (h_r1_univ r h_en_le_y h_pn_le_y')))
  -- Step S3: Formula and gap/point agreement at pivot e_n/p_n
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
  -- Step S4: Compose into full backward game on [d, y']/[c, y]
  have tau_composed : ghr93_duplicator_wins N M atomMap n r d y' c y :=
    ghr93_strategy_compose hd_le_pn h_pn_le_y' hc_le_en h_en_le_y
      hpivot_form hpivot_gp
      (fun h => absurd (show ∃ p : M.carrier, inClosedInterval e_n y
          (extendPoint (sig := sig) (atomMap := atomMap) (r := r) p) from
          ⟨e_n_pt, le_refl _, h_en_le_y⟩) h)
      (fun h => absurd (show ∃ p : M.carrier, inClosedInterval c e_n
          (extendPoint (sig := sig) (atomMap := atomMap) (r := r) p) from
          ⟨e_n_pt, hc_le_en, le_refl _⟩) h)
      tau_left tau_right
  -- Step S5: Play composed game with a_init to get resp_comp
  obtain ⟨resp_comp, hresp_comp_in, hwin_comp⟩ := tau_composed a_init ha_init
  -- Step S6: Play tau_left directly with a_init to get sub-interval ordering.
  -- a_init selections are in [d, p_n] (from sorting + h_ainit_le_pn below).
  have h_ainit_le_pn : ∀ (k : Fin n), a_init k ≤ extendPoint p_n := by
    intro k
    have hk_le : (⟨k.val, by omega⟩ : Fin (n + 1)) ≤ ⟨n, by omega⟩ :=
      Fin.mk_le_mk.mpr (by omega)
    have := h_mono hk_le
    rw [hp_n] at this; exact this
  have ha_init_sub : ∀ k, inClosedInterval d (extendPoint p_n) (a_init k) :=
    fun k => ⟨(ha_init k).1, h_ainit_le_pn k⟩
  obtain ⟨resp_left, hresp_left_in, hwin_left⟩ := tau_left a_init ha_init_sub
  -- resp_left(k) ∈ [c, e_n] — automatic from left sub-game!
  -- Extract sub-interval ordering from tau_left via an arbitrary point in [c, e_n].
  have ⟨p_ce, hp_ce⟩ : ∃ (p : M.carrier), inClosedInterval c e_n (extendPoint p) :=
    ⟨e_n_pt, hc_le_en, le_refl _⟩
  obtain ⟨_b_left, _hb_left_in, hcond_left⟩ := hwin_left p_ce hp_ce
  obtain ⟨hord_left, _hgp_left, hform_left⟩ := hcond_left
  -- Key ordering from tau_left: sel_pn_ord for the sub-interval.
  -- position 1+k vs y-position (n+2): a_init(k) vs p_n ↔ resp_left(k) vs e_n
  have hord_left_sel_pn : ∀ (k : Fin n),
      (a_init k < extendPoint p_n ↔ resp_left k < e_n) ∧
      (a_init k = extendPoint p_n ↔ resp_left k = e_n) := by
    intro k
    have h := hord_left ⟨1 + k.val, by omega⟩ ⟨n + 2, by omega⟩
    simp_game_tuple at h; exact h
  -- Phase 3C-EQ + 3C-STRICT: Modified response function.
  -- When a_init(k) = p_n: respond with e_n (equality case).
  -- When a_init(k) < p_n (strict): use resp_left(k) from the left sub-game.
  -- sel_pn_ord follows directly from hord_left_sel_pn.
  let resp_mod : Fin n → ExtendedCarrier M atomMap r := fun k =>
    if a_init k = extendPoint p_n then e_n else resp_left k
  have hresp_mod_eq : ∀ (k : Fin n), a_init k = extendPoint p_n → resp_mod k = e_n :=
    fun k heq => by simp [resp_mod, heq]
  have hresp_mod_ne : ∀ (k : Fin n), a_init k ≠ extendPoint p_n → resp_mod k = resp_left k :=
    fun k hne => by simp [resp_mod, hne]
  have hresp_mod_in : ∀ (k : Fin n), inClosedInterval c y (resp_mod k) := by
    intro k; simp only [resp_mod]
    split
    · exact ⟨hc_le_en, he_n_in.2⟩
    · exact ⟨(hresp_left_in k).1, le_trans (hresp_left_in k).2 h_en_le_y⟩
  -- The full winning condition assembly:
  -- The key gap: a_N ≠ a_bwd in general, so the forward winning condition
  -- doesn't directly give us the backward winning condition.
  -- The assembly requires combining tau's ordering with the e_n ordering.
  obtain ⟨e_n, he_n_in, he_n_props⟩ :
      ∃ e_n : ExtendedCarrier M atomMap r,
        inClosedInterval x y e_n ∧
        (∀ (b_sp : M.carrier), inClosedInterval x y (extendPoint b_sp) →
          ∃ (b_resp : N.carrier), inClosedInterval x' y' (extendPoint b_resp) ∧
            ghr93_winning_condition (n + 1)
              (game_tuple x' y' a_bwd b_resp)
              (game_tuple x y (fun i => if h : i.val < n then resp_mod ⟨i.val, h⟩ else e_n) b_sp)) := by
    refine ⟨e_n, he_n_in, ?_⟩
    intro b_sp hb_sp
    -- (hd_le_pn and hc_le_en hoisted before resp_mod definition)
    -- Case split on b_sp vs c for round-2 delegation
    by_cases hbc : extendPoint (sig := sig) (atomMap := atomMap) (r := r) b_sp ≤ c
    · -- Case A: b_sp ∈ [x, c]. Use sigma for round 2.
      have hd_in_x'd : inClosedInterval x' d d := ⟨props.hx'd, le_refl d⟩
      obtain ⟨_resp_sig, _, hwin_sig⟩ :=
        props.sigma (fun _ : Fin n => d) (fun _ => hd_in_x'd)
      obtain ⟨b_resp, hb_resp_in, hcond_sig⟩ :=
        hwin_sig b_sp ⟨hb_sp.1, hbc⟩
      -- b_resp ∈ [x', d] ⊆ [x', y']
      refine ⟨b_resp, ⟨hb_resp_in.1, le_trans hb_resp_in.2 props.hdy'⟩, ?_⟩
      -- Assemble winning condition from tau + sigma + e_n data.
      -- b_resp comes from sigma (in [x',d]), tau provides positions 1..n.
      -- For tau ordering at positions 1..n, use an arbitrary point in [c,y]
      -- to instantiate hwin_tau and extract ordering/formula data.
      obtain ⟨hord_sig, hgp_sig, hform_sig⟩ := hcond_sig
      -- Extract tau winning condition at inner positions by instantiating
      -- hwin_tau with an arbitrary carrier point in [c, y].
      -- In Case II, the degenerate case (c = y gap) is impossible because
      -- d = y' and a_bwd(n) is a point, but d would be a gap — contradiction.
      have ⟨p_cy, hp_cy⟩ : ∃ (p : M.carrier), inClosedInterval c y (extendPoint p) := by
        rcases props.h_pt_cy with ⟨p_cy, hp_cy⟩ | ⟨_, hdy'_eq, _, hgap_d⟩
        · exact ⟨p_cy, hp_cy⟩
        · -- d = y', d is gap, but a_bwd(n) ∈ [d, y'] = [d, d] is a point — contradiction
          obtain ⟨g_d, hg_d⟩ := hgap_d
          have ha_eq : a_bwd ⟨n, by omega⟩ = d :=
            le_antisymm (hdy'_eq ▸ (ha_bwd ⟨n, by omega⟩).2) (h_no_split ⟨n, by omega⟩)
          -- a_bwd(n) = extendPoint p_n, so d = extendPoint p_n, but d = Sum.inr g_d
          have : d = extendPoint p_n := ha_eq ▸ hp_n
          exact absurd (this.symm ▸ hg_d : extendPoint p_n = Sum.inr g_d) (by simp [extendPoint])
      obtain ⟨_b_tau, _hb_tau_in, hcond_tau_aux⟩ := hwin_tau p_cy hp_cy
      obtain ⟨hord_tau_aux, hgp_tau_aux, hform_tau_aux⟩ := hcond_tau_aux
      -- hgp_tau_aux/hform_tau_aux at positions 1..n give a_init(k)/resp_tau(k)
      -- agreement, independent of the Round 2 point p_cy.
      refine ⟨?_, ?_, ?_⟩
      · -- same_order_type (n+1): sigma sub-case
        -- Uses task 195 tactics: same_order_type_grid, order_refl,
        -- simp_game_tuple, pivot_chain_order'
        have hab_n : a_bwd ⟨n, by omega⟩ = extendPoint p_n := hp_n
        have hab_eq : ∀ (k : Nat) (hk : k < n + 1), ¬(k < n) →
            a_bwd ⟨k, hk⟩ = extendPoint p_n := by
          intro k hk hkn
          have : k = n := Nat.eq_of_lt_succ_of_not_lt hk hkn
          subst this; exact hp_n
        -- Forward game orderings (from d-compatible big game)
        have fwd_x_b := hord_fwd_x_en
        have fwd_x_y := hord_fwd_x_y
        have fwd_b_y := hord_fwd_en_y
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
        -- Raw ordering facts from tau_left (in terms of resp_left)
        have tau_d_sel_raw : ∀ (k : Fin n),
            (d < a_init k ↔ c < resp_left k) ∧
            (d = a_init k ↔ c = resp_left k) := by
          intro k; have h := hord_left ⟨0, by omega⟩ ⟨1 + k.val, by omega⟩
          simp_game_tuple at h; exact h
        have tau_sel_sel_raw : ∀ (k k' : Fin n),
            (a_init k < a_init k' ↔ resp_left k < resp_left k') ∧
            (a_init k = a_init k' ↔ resp_left k = resp_left k') := by
          intro k k'
          have h := hord_left ⟨1 + k.val, by omega⟩ ⟨1 + k'.val, by omega⟩
          simp_game_tuple at h; exact h
        have hd_le_sel : ∀ (k : Fin n), d ≤ a_init k :=
          fun k => (ha_init k).1
        -- Phase 3C-STRICT: Lift tau_left ordering to resp_mod.
        -- When a_init(k) = p_n, resp_mod(k) = e_n; use forward game orderings.
        -- When a_init(k) ≠ p_n, resp_mod(k) = resp_left(k); use tau_left orderings.
        have hc_le_rtau : ∀ (k : Fin n), c ≤ resp_mod k := by
          intro k; exact (hresp_mod_in k).1
        have tau_d_sel : ∀ (k : Fin n),
            (d < a_init k ↔ c < resp_mod k) ∧
            (d = a_init k ↔ c = resp_mod k) := by
          intro k
          rcases Decidable.em (a_init k = extendPoint p_n) with heq | hne
          · rw [hresp_mod_eq k heq, heq]
            exact ⟨hord_cd_en_pn.1.symm, hord_cd_en_pn.2.symm⟩
          · rw [hresp_mod_ne k hne]; exact tau_d_sel_raw k
        have tau_sel_y : ∀ (k : Fin n),
            (a_init k < y' ↔ resp_mod k < y) ∧
            (a_init k = y' ↔ resp_mod k = y) := by
          intro k
          rcases Decidable.em (a_init k = extendPoint p_n) with heq | hne
          · rw [hresp_mod_eq k heq, heq]
            exact ⟨hord_fwd_en_y.1.symm, hord_fwd_en_y.2.symm⟩
          · -- Strict case: a_init(k) < p_n ≤ y' and resp_left(k) < e_n ≤ y
            rw [hresp_mod_ne k hne]
            have hlt_pn : a_init k < extendPoint p_n := lt_of_le_of_ne (h_ainit_le_pn k) hne
            have hlt_en : resp_left k < e_n := (hord_left_sel_pn k).1.mp hlt_pn
            have hlt_y' : a_init k < y' := lt_of_lt_of_le hlt_pn h_pn_le_y'
            have hlt_y : resp_left k < y := lt_of_lt_of_le hlt_en h_en_le_y
            exact ⟨⟨fun _ => hlt_y, fun _ => hlt_y'⟩,
                   ⟨fun h => absurd hlt_y' (by rw [h]; exact lt_irrefl _),
                    fun h => absurd hlt_y (by rw [h]; exact lt_irrefl _)⟩⟩
        have tau_sel_sel : ∀ (k k' : Fin n),
            (a_init k < a_init k' ↔ resp_mod k < resp_mod k') ∧
            (a_init k = a_init k' ↔ resp_mod k = resp_mod k') := by
          intro k k'
          rcases Decidable.em (a_init k = extendPoint p_n) with heq_k | hne_k
          · rcases Decidable.em (a_init k' = extendPoint p_n) with heq_k' | hne_k'
            · -- Both = p_n: both responses e_n
              rw [hresp_mod_eq k heq_k, hresp_mod_eq k' heq_k', heq_k, heq_k']
              exact ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
                     ⟨fun _ => rfl, fun _ => rfl⟩⟩
            · -- k = p_n, k' ≠ p_n: a_init(k') < p_n (strict).
              -- resp_mod(k) = e_n, resp_mod(k') = resp_left(k')
              -- From hord_left_sel_pn: resp_left(k') < e_n ↔ a_init(k') < p_n
              rw [hresp_mod_eq k heq_k, hresp_mod_ne k' hne_k', heq_k]
              have hlt_k' : a_init k' < extendPoint p_n :=
                lt_of_le_of_ne (h_ainit_le_pn k') hne_k'
              have hlt_resp_k' : resp_left k' < e_n := (hord_left_sel_pn k').1.mp hlt_k'
              -- p_n < a_init(k') is False; e_n < resp_left(k') is False
              exact ⟨⟨fun h => absurd h (not_lt_of_gt hlt_k'),
                      fun h => absurd h (not_lt_of_gt hlt_resp_k')⟩,
                     ⟨fun h => absurd hlt_k' (h ▸ lt_irrefl _),
                      fun h => absurd hlt_resp_k' (h ▸ lt_irrefl _)⟩⟩
          · rcases Decidable.em (a_init k' = extendPoint p_n) with heq_k' | hne_k'
            · -- k ≠ p_n, k' = p_n: symmetric
              rw [hresp_mod_ne k hne_k, hresp_mod_eq k' heq_k', heq_k']
              have hlt_k : a_init k < extendPoint p_n :=
                lt_of_le_of_ne (h_ainit_le_pn k) hne_k
              have hlt_resp_k : resp_left k < e_n := (hord_left_sel_pn k).1.mp hlt_k
              -- a_init(k) < p_n; resp_left(k) < e_n
              exact ⟨⟨fun _ => hlt_resp_k, fun _ => hlt_k⟩,
                     ⟨fun h => absurd hlt_k (h ▸ lt_irrefl _),
                      fun h => absurd hlt_resp_k (h ▸ lt_irrefl _)⟩⟩
            · -- Neither = p_n: use raw tau_left orderings
              rw [hresp_mod_ne k hne_k, hresp_mod_ne k' hne_k']
              exact tau_sel_sel_raw k k'
        -- sel_pn_ord: direct from hord_left_sel_pn (Phase 3C-STRICT resolved!)
        have sel_pn_ord : ∀ (k : Fin n),
            (a_init k < extendPoint p_n ↔ resp_mod k < e_n) ∧
            (a_init k = extendPoint p_n ↔ resp_mod k = e_n) := by
          intro k
          rcases Decidable.em (a_init k = extendPoint p_n) with heq | hne
          · -- Equality case (Phase 3C-EQ): a_init(k) = p_n, response is e_n
            rw [hresp_mod_eq k heq, heq]
            exact ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
                   ⟨fun _ => rfl, fun _ => rfl⟩⟩
          · -- Strict case (Phase 3C-STRICT): a_init(k) ≠ p_n, response is resp_left(k)
            rw [hresp_mod_ne k hne]
            exact hord_left_sel_pn k
        -- pn_sel_ord: reverse direction (p_n vs sel), derived from sel_pn_ord
        -- via linear order trichotomy. Uses resp_mod for Phase 3C-EQ.
        have pn_sel_ord : ∀ (k : Fin n),
            (extendPoint p_n < a_init k ↔ e_n < resp_mod k) ∧
            (extendPoint p_n = a_init k ↔ e_n = resp_mod k) := by
          intro k; have h := sel_pn_ord k
          exact ⟨⟨fun hba => by
            rcases lt_trichotomy (resp_mod k) e_n with hcd | hcd | hcd
            · exact absurd (h.1.mpr hcd) (not_lt.mpr (le_of_lt hba))
            · exact absurd (h.2.mpr hcd) (ne_of_gt hba)
            · exact hcd,
            fun hdc => by
            rcases lt_trichotomy (a_init k) (extendPoint p_n) with hab | hab | hab
            · exact absurd (h.1.mp hab) (not_lt.mpr (le_of_lt hdc))
            · exact absurd (h.2.mp hab) (ne_of_gt hdc)
            · exact hab⟩,
            ⟨fun h2 => (h.2.mp h2.symm).symm, fun h2 => (h.2.mpr h2.symm).symm⟩⟩
        -- Dispatch all N×N grid cases
        same_order_type_grid <;>
          -- Rewrite a_bwd(k) to extendPoint p_n when k = n
          (try rw [hab_eq _ _ (by assumption)]) <;>
          (try rw [hab_eq _ _ (by assumption)]) <;>
          first
          | order_refl
          | exact sig_x_b | exact ⟨sig_x_b.1.symm, sig_x_b.2.symm⟩
          | exact fwd_x_y | exact ⟨fwd_x_y.1.symm, fwd_x_y.2.symm⟩
          | exact fwd_b_y | exact ⟨fwd_b_y.1.symm, fwd_b_y.2.symm⟩
          | exact ⟨fwd_x_b.1.symm, fwd_x_b.2.symm⟩ | exact fwd_x_b
          -- b vs y pivot through d/c
          | exact pivot_chain_order' hb_resp_in.2 props.hdy' hbc props.hcy
              sig_b_d tau_d_y'
          | exact pivot_chain_order_rev' props.hdy' hb_resp_in.2 props.hcy hbc
              tau_d_y' sig_b_d
          -- x vs b pivot through x'/x
          | exact pivot_chain_order' props.hx'd hb_resp_in.1 props.hxc hb_sp.1
              sig_x_d sig_x_b
          | exact pivot_chain_order_rev' hb_resp_in.1 props.hx'd hb_sp.1 props.hxc
              sig_x_b sig_x_d
          -- x vs y pivot through d/c
          | exact pivot_chain_order_rev' props.hdy' props.hx'd props.hcy props.hxc
              tau_d_y' sig_x_d
          | exact pivot_chain_order' props.hx'd props.hdy' props.hxc props.hcy
              sig_x_d tau_d_y'
          -- tau selection vs y
          | exact tau_sel_y ⟨_, ‹_›⟩
          | exact ⟨(tau_sel_y ⟨_, ‹_›⟩).1.symm, (tau_sel_y ⟨_, ‹_›⟩).2.symm⟩
          -- tau selection vs selection
          | exact tau_sel_sel ⟨_, ‹_›⟩ ⟨_, ‹_›⟩
          -- x vs selection pivot through d/c
          | exact pivot_chain_order' props.hx'd (hd_le_sel ⟨_, ‹_›⟩) props.hxc
              (hc_le_rtau ⟨_, ‹_›⟩) sig_x_d (tau_d_sel ⟨_, ‹_›⟩)
          | exact pivot_chain_order_rev' (hd_le_sel ⟨_, ‹_›⟩) props.hx'd
              (hc_le_rtau ⟨_, ‹_›⟩) props.hxc (tau_d_sel ⟨_, ‹_›⟩) sig_x_d
          -- b vs selection pivot through d/c
          | exact pivot_chain_order' hb_resp_in.2 (hd_le_sel ⟨_, ‹_›⟩) hbc
              (hc_le_rtau ⟨_, ‹_›⟩) sig_b_d (tau_d_sel ⟨_, ‹_›⟩)
          | exact pivot_chain_order_rev' (hd_le_sel ⟨_, ‹_›⟩) hb_resp_in.2
              (hc_le_rtau ⟨_, ‹_›⟩) hbc (tau_d_sel ⟨_, ‹_›⟩) sig_b_d
          -- selection vs y pivot through d/c
          | exact pivot_chain_order_rev' props.hdy' (hd_le_sel ⟨_, ‹_›⟩)
              props.hcy (hc_le_rtau ⟨_, ‹_›⟩) tau_d_y' (tau_d_sel ⟨_, ‹_›⟩)
          | exact pivot_chain_order' (hd_le_sel ⟨_, ‹_›⟩) props.hdy'
              (hc_le_rtau ⟨_, ‹_›⟩) props.hcy (tau_d_sel ⟨_, ‹_›⟩) tau_d_y'
          -- selection vs p_n/e_n pivot through d/c then d/c→p_n/e_n via fwd_x_b
          | (exact pivot_chain_order' (hd_le_sel ⟨_, ‹_›⟩)
              (le_trans (h_no_split ⟨_, by omega⟩)
                (by rw [← hab_n]; exact le_refl _))
              (hc_le_rtau ⟨_, ‹_›⟩) he_n_in.1
              (tau_d_sel ⟨_, ‹_›⟩) fwd_x_b)
          | (exact pivot_chain_order_rev'
              (le_trans (h_no_split ⟨_, by omega⟩)
                (by rw [← hab_n]; exact le_refl _))
              (hd_le_sel ⟨_, ‹_›⟩) he_n_in.1 (hc_le_rtau ⟨_, ‹_›⟩)
              fwd_x_b (tau_d_sel ⟨_, ‹_›⟩))
          -- Remaining impossible-direction goals (both sides False for <)
          -- b_resp vs x (b_resp ≥ x', b_sp ≥ x)
          | (exact ⟨⟨fun h => absurd (lt_of_lt_of_le h hb_resp_in.1) (lt_irrefl _),
                     fun h => absurd (lt_of_lt_of_le h hb_sp.1) (lt_irrefl _)⟩,
                    ⟨fun h => by rw [h] at hb_resp_in; exact absurd
                       (lt_of_lt_of_le (sig_x_b.1.mpr (lt_of_le_of_eq hb_sp.1
                         (sig_x_b.2.mp hb_resp_in.1.symm).symm)) hb_resp_in.1)
                       (lt_irrefl _),
                     fun h => by rw [h] at hb_sp; exact absurd
                       (lt_of_lt_of_le (sig_x_b.1.mp (lt_of_le_of_eq hb_resp_in.1
                         (sig_x_b.2.mpr hb_sp.1.symm).symm)) hb_sp.1)
                       (lt_irrefl _)⟩⟩)
          -- y' vs a_init(k) (a_init(k) ≤ y', resp_mod(k) ≤ y; both < False)
          | (exact ⟨⟨fun h => absurd (lt_of_lt_of_le h (ha_bwd ⟨_, by omega⟩).2)
                       (lt_irrefl _),
                     fun h => absurd (lt_of_lt_of_le h (hresp_mod_in ⟨_, ‹_›⟩).2)
                       (lt_irrefl _)⟩,
                    ⟨fun h => ((tau_sel_y ⟨_, ‹_›⟩).2.mp (by
                       convert h.symm using 2; congr 1; exact Fin.ext (by omega))).symm,
                     fun h => by
                       have := (tau_sel_y ⟨_, ‹_›⟩).2.mpr h.symm
                       convert this.symm using 2; congr 1; exact Fin.ext (by omega)⟩⟩)
          -- y' vs p_n (p_n ≤ y', e_n ≤ y; both < False)
          | (exact ⟨⟨fun h => absurd (lt_of_lt_of_le h hp_n_in.2) (lt_irrefl _),
                     fun h => absurd (lt_of_lt_of_le h he_n_in.2) (lt_irrefl _)⟩,
                    ⟨fun h => (fwd_b_y.2.mpr h.symm).symm,
                     fun h => (fwd_b_y.2.mp h.symm).symm⟩⟩)
          -- p_n vs x' (p_n ≥ x', e_n ≥ x; both < False)
          | (exact ⟨⟨fun h => absurd (lt_of_lt_of_le h hp_n_in.1) (lt_irrefl _),
                     fun h => absurd (lt_of_lt_of_le h he_n_in.1) (lt_irrefl _)⟩,
                    ⟨fun h => (fwd_x_b.2.mpr h.symm).symm,
                     fun h => (fwd_x_b.2.mp h.symm).symm⟩⟩)
          -- Cross-boundary orderings: pivot through d/c using hord_cd_en_pn.
          -- b_resp vs p_n / p_n vs b_resp
          | (exact pivot_chain_order' hb_resp_in.2 hd_le_pn hbc hc_le_en
              sig_b_d hord_cd_en_pn)
          | (exact pivot_chain_order_rev' hd_le_pn hb_resp_in.2 hc_le_en hbc
              hord_cd_en_pn sig_b_d)
          -- a_init(k) vs p_n / p_n vs a_init(k)
          | (exact pivot_chain_order_rev' hd_le_pn (hd_le_sel ⟨_, ‹_›⟩)
              hc_le_en (hc_le_rtau ⟨_, ‹_›⟩) hord_cd_en_pn (tau_d_sel ⟨_, ‹_›⟩))
          | (exact pivot_chain_order' (hd_le_sel ⟨_, ‹_›⟩) hd_le_pn
              (hc_le_rtau ⟨_, ‹_›⟩) hc_le_en (tau_d_sel ⟨_, ‹_›⟩) hord_cd_en_pn)
          -- b_resp vs x' (reverse impossible: b_resp ≥ x', b_sp ≥ x)
          | (exact ⟨⟨fun h => absurd (lt_of_lt_of_le h hb_resp_in.1) (lt_irrefl _),
                     fun h => absurd (lt_of_lt_of_le h hb_sp.1) (lt_irrefl _)⟩,
                    ⟨fun h => (sig_x_b.2.mp h.symm).symm,
                     fun h => (sig_x_b.2.mpr h.symm).symm⟩⟩)
          -- b_resp vs p_n: pivot through d/c (hord_cd_en_pn orientation corrected)
          | (exact pivot_chain_order' hb_resp_in.2 hd_le_pn hbc hc_le_en
              sig_b_d ⟨hord_cd_en_pn.1.symm, hord_cd_en_pn.2.symm⟩)
          -- y' vs a_bwd(j-1) reverse (impossible: a_bwd ≤ y', resp_mod ≤ y)
          | (refine ⟨⟨fun h => absurd (lt_of_lt_of_le h ?_) (lt_irrefl _),
                     fun h => absurd (lt_of_lt_of_le h (hresp_mod_in ⟨_, ‹_›⟩).2)
                       (lt_irrefl _)⟩,
                    ⟨fun h => ((tau_sel_y ⟨_, ‹_›⟩).2.mp (by
                       convert h.symm using 2; congr 1; exact Fin.ext (by omega))).symm,
                     fun h => by
                       have := (tau_sel_y ⟨_, ‹_›⟩).2.mpr h.symm
                       convert this.symm using 2; congr 1; exact Fin.ext (by omega)⟩⟩
             convert (ha_bwd ⟨_, by omega⟩).2 using 2; congr 1; exact Fin.ext (by omega))
          -- p_n vs b_resp: reverse of b_resp vs p_n
          | (exact pivot_chain_order_rev' hd_le_pn hb_resp_in.2 hc_le_en hbc
              ⟨hord_cd_en_pn.1.symm, hord_cd_en_pn.2.symm⟩ sig_b_d)
          -- y' vs sel(j-1) reverse: impossible < + tau_sel_y = (Fin index mismatch)
          | (refine ⟨⟨fun h => absurd (lt_of_lt_of_le h ?_) (lt_irrefl _),
                     fun h => absurd (lt_of_lt_of_le h ?_) (lt_irrefl _)⟩,
                    ⟨fun h => ?_, fun h => ?_⟩⟩
             · convert (ha_bwd ⟨_, by omega⟩).2 using 2; congr 1; exact Fin.ext rfl
             · convert (hresp_mod_in ⟨_, ‹_›⟩).2 using 2; congr 1; exact Fin.ext rfl
             · exact ((tau_sel_y ⟨_, ‹_›⟩).2.mp (by
                 convert h.symm using 2; congr 1; exact Fin.ext (by omega))).symm
             · have := (tau_sel_y ⟨_, ‹_›⟩).2.mpr h.symm
               convert this.symm using 2; congr 1; exact Fin.ext (by omega))
          -- sel(i) vs p_n / p_n vs sel(j): remaining cross-boundary grid cases.
          -- These involve a_bwd with ¬(k-1<n), so k-1=n.
          -- Rewrite using hab_eq then dispatch with pivot_chain_order'.
          | (try rw [hab_eq _ (by omega) (by omega)]
             first
             | exact pivot_chain_order_rev' hd_le_pn (hd_le_sel ⟨_, ‹_›⟩)
                    hc_le_en (hc_le_rtau ⟨_, ‹_›⟩)
                    ⟨hord_cd_en_pn.1.symm, hord_cd_en_pn.2.symm⟩
                    (tau_d_sel ⟨_, ‹_›⟩)
             | exact pivot_chain_order' (hd_le_sel ⟨_, ‹_›⟩) hd_le_pn
                    (hc_le_rtau ⟨_, ‹_›⟩) hc_le_en (tau_d_sel ⟨_, ‹_›⟩)
                    ⟨hord_cd_en_pn.1.symm, hord_cd_en_pn.2.symm⟩
             | exact ⟨⟨fun h => absurd (lt_of_lt_of_le h (ha_bwd ⟨_, by omega⟩).2)
                         (lt_irrefl _),
                       fun h => absurd (lt_of_lt_of_le h (hresp_mod_in ⟨_, ‹_›⟩).2)
                         (lt_irrefl _)⟩,
                      ⟨fun h => ((tau_sel_y ⟨_, ‹_›⟩).2.mp (by
                         convert h.symm using 2; congr 1; exact Fin.ext (by omega))).symm,
                       fun h => by
                         have := (tau_sel_y ⟨_, ‹_›⟩).2.mpr h.symm
                         convert this.symm using 2; congr 1; exact Fin.ext (by omega)⟩⟩
             | (have key := (tau_sel_y ⟨_, ‹_›⟩)
                convert ⟨key.1.symm, key.2.symm⟩ using 3 <;> (congr 1; exact Fin.ext (by omega)))
             | (have key := pivot_chain_order' (hd_le_sel ⟨_, ‹_›⟩) hd_le_pn
                    (hc_le_rtau ⟨_, ‹_›⟩) hc_le_en (tau_d_sel ⟨_, ‹_›⟩) hord_cd_en_pn
                convert key using 3 <;> (congr 1; exact Fin.ext (by omega)))
             | (exact pivot_chain_order_rev' hd_le_pn (hd_le_sel ⟨_, ‹_›⟩)
                    hc_le_en (hc_le_rtau ⟨_, ‹_›⟩)
                    ⟨hord_cd_en_pn.1.symm, hord_cd_en_pn.2.symm⟩
                    (tau_d_sel ⟨_, ‹_›⟩))
             | (exact pivot_chain_order' (hd_le_sel ⟨_, ‹_›⟩) hd_le_pn
                    (hc_le_rtau ⟨_, ‹_›⟩) hc_le_en (tau_d_sel ⟨_, ‹_›⟩) hord_cd_en_pn)
             -- y' vs sel(j-1) (Fin mismatch: a_bwd vs a_init)
             | (convert ⟨(tau_sel_y ⟨_, ‹_›⟩).1.symm, (tau_sel_y ⟨_, ‹_›⟩).2.symm⟩ using 3
                <;> (congr 1; exact Fin.ext (by omega)))
             -- sel(i-1) vs p_n (rewrite a_bwd to p_n, then pivot with Fin convert)
             | (rw [hab_eq _ _ (by assumption)]
                convert pivot_chain_order' (hd_le_sel ⟨_, ‹_›⟩) hd_le_pn
                    (hc_le_rtau ⟨_, ‹_›⟩) hc_le_en (tau_d_sel ⟨_, ‹_›⟩) hord_cd_en_pn
                    using 3 <;> (congr 1; exact Fin.ext (by omega)))
             -- p_n vs sel(j-1) (Fin mismatch: pivot_chain_order_rev' with convert)
             | (convert pivot_chain_order_rev' hd_le_pn (hd_le_sel ⟨_, ‹_›⟩)
                    hc_le_en (hc_le_rtau ⟨_, ‹_›⟩)
                    ⟨hord_cd_en_pn.1.symm, hord_cd_en_pn.2.symm⟩
                    (tau_d_sel ⟨_, ‹_›⟩) using 3
                <;> (congr 1; exact Fin.ext (by omega)))
             -- sel(i) vs p_n: rw j-side a_bwd to p_n (hab_eq on ¬j-1<n),
             -- then the i-side a_bwd is a_init by rfl, close with sel_pn_ord
             | (rw [show (a_bwd ⟨_, _⟩ : ExtendedCarrier N atomMap r) = extendPoint p_n
                    from hab_eq _ _ ‹_›]
                exact sel_pn_ord ⟨_, ‹_›⟩)
             -- p_n vs sel(j), sel(i) vs p_n, y' vs sel(j-1): Fin bridging
             | (first
               | (convert pn_sel_ord ⟨_, ‹_›⟩ using 3 <;> (congr 1; exact Fin.ext (by omega)))
               | (rw [show (a_bwd ⟨_, _⟩ : ExtendedCarrier N atomMap r) = extendPoint p_n
                      from hab_eq _ _ (by assumption)]
                  exact sel_pn_ord ⟨_, ‹_›⟩)
               | (have key := (tau_sel_y ⟨_, ‹_›⟩)
                  exact ⟨key.1.symm, key.2.symm⟩)
               -- y' vs sel(j-1) reverse: impossible < (sel ≤ y', resp_mod ≤ y), = from tau_sel_y
               | (exact ⟨⟨fun h => absurd (lt_of_lt_of_le h (ha_bwd ⟨_, by omega⟩).2)
                             (lt_irrefl _),
                         fun h => absurd (lt_of_lt_of_le h (hresp_mod_in ⟨_, ‹_›⟩).2)
                             (lt_irrefl _)⟩,
                        ⟨fun h => ((tau_sel_y ⟨_, ‹_›⟩).2.mp h.symm).symm,
                         fun h => ((tau_sel_y ⟨_, ‹_›⟩).2.mpr h.symm).symm⟩⟩)
               -- sel(i) vs p_n: rewrite j-side a_bwd to p_n via hab_eq, then sel_pn_ord
               | (rw [hab_eq _ (by omega) (by assumption)]
                  exact sel_pn_ord ⟨_, ‹_›⟩)
               | (simp only [hab_eq _ _ ‹¬_ < n›]; exact sel_pn_ord ⟨_, ‹_›⟩)))
      · -- gap_point_agreement (n+1)
        intro i
        simp only [game_tuple]
        split_ifs with h0 hn1 hn2 h0' hlt
        · -- i=0: x'/x — from d-compatible big game at position 0
          exact ⟨hgp_fwd_x.1.symm, hgp_fwd_x.2.symm⟩
        · -- i=n+2: extendPoint b_resp / extendPoint b_sp (both are Sum.inl)
          constructor
          · exact ⟨fun _ => ⟨b_sp, rfl⟩, fun _ => ⟨b_resp, rfl⟩⟩
          · constructor <;> intro ⟨g, hg⟩ <;> cases hg
        · -- i=n+3: y'/y — from d-compatible big game
          exact ⟨hgp_fwd_y.1.symm, hgp_fwd_y.2.symm⟩
        · -- i inner, i-1 < n: a_bwd(i-1)/resp_mod(i-1)
          -- Case split on whether a_init(i-1) = p_n
          let k : Fin n := ⟨i.val - 1, by omega⟩
          rcases Decidable.em (a_init k = extendPoint p_n) with heq_k | hne_k
          · -- a_init(k) = p_n: resp_mod(k) = e_n
            have hmod_eq : resp_mod k = e_n := hresp_mod_eq k heq_k
            show (IsPoint (a_bwd ⟨i.val - 1, _⟩) ↔ IsPoint (resp_mod ⟨i.val - 1, _⟩)) ∧
                 (IsGap (a_bwd ⟨i.val - 1, _⟩) ↔ IsGap (resp_mod ⟨i.val - 1, _⟩))
            rw [show (⟨i.val - 1, by omega⟩ : Fin n) = k from Fin.ext rfl, hmod_eq]
            have : a_bwd ⟨i.val - 1, by omega⟩ = extendPoint p_n := by
              show a_init k = extendPoint p_n; exact heq_k
            rw [this]
            constructor
            · exact ⟨fun _ => ⟨e_n_pt, rfl⟩, fun _ => ⟨p_n, rfl⟩⟩
            · constructor <;> intro ⟨g, hg⟩ <;> exact (Sum.inl_ne_inr hg).elim
          · -- a_init(k) ≠ p_n: resp_mod(k) = resp_left(k), use tau_left
            have hmod_ne : resp_mod k = resp_left k := hresp_mod_ne k hne_k
            have hleft_i := _hgp_left ⟨1 + (i.val - 1), by omega⟩
            simp only [game_tuple, show 1 + (i.val - 1) ≠ 0 from by omega,
                       show ¬(1 + (i.val - 1) = n + 1) from by omega,
                       show ¬(1 + (i.val - 1) = n + 2) from by omega,
                       dite_false, show 1 + (i.val - 1) - 1 = i.val - 1 from by omega] at hleft_i
            show (IsPoint (a_bwd ⟨i.val - 1, _⟩) ↔ IsPoint (resp_mod ⟨i.val - 1, _⟩)) ∧
                 (IsGap (a_bwd ⟨i.val - 1, _⟩) ↔ IsGap (resp_mod ⟨i.val - 1, _⟩))
            rw [show (⟨i.val - 1, by omega⟩ : Fin n) = k from Fin.ext rfl, hmod_ne]
            exact hleft_i
        · -- i inner, i-1=n: a_bwd(n)/e_n — both are Sum.inl (point)
          have hi_eq : i.val - 1 = n := by omega
          have hab : (a_bwd ⟨i.val - 1, by omega⟩ : ExtendedCarrier N atomMap r) =
                     a_bwd ⟨n, by omega⟩ := by congr 1; exact Fin.ext hi_eq
          rw [hab, hp_n]
          constructor
          · exact ⟨fun _ => ⟨e_n_pt, rfl⟩, fun _ => ⟨p_n, rfl⟩⟩
          · constructor <;> intro ⟨g, hg⟩ <;> exact (Sum.inl_ne_inr hg).elim
      · -- formula_agreement (n+1)
        intro i A hA
        simp only [game_tuple]
        split_ifs with h0 hn1 hn2 h0' hlt
        · -- i=0: x'/x — from d-compatible big game
          exact (hform_fwd_x A hA).symm
        · -- i=n+2: extendPoint b_resp / extendPoint b_sp — from sigma at position n+1
          have hsig_n1 := hform_sig ⟨n + 1, by omega⟩ A hA
          simp only [game_tuple, show (n + 1 : Nat) ≠ 0 from by omega,
                     show (n + 1 : Nat) = n + 1 from rfl,
                     dite_false, dite_true] at hsig_n1
          exact hsig_n1
        · -- i=n+3: y'/y — from d-compatible big game
          exact (hform_fwd_y A hA).symm
        · -- i inner, i-1 < n: a_bwd(i-1)/resp_mod(i-1)
          let k : Fin n := ⟨i.val - 1, by omega⟩
          rcases Decidable.em (a_init k = extendPoint p_n) with heq_k | hne_k
          · -- a_init(k) = p_n: resp_mod(k) = e_n, use hform_en_an
            have hmod_eq : resp_mod k = e_n := hresp_mod_eq k heq_k
            -- Goal: N(a_bwd(i-1)) ↔ M(resp_mod(i-1)). Rewrite both to known terms.
            have hab_pn : (a_bwd ⟨i.val - 1, by omega⟩ : ExtendedCarrier N atomMap r) =
                a_bwd ⟨n, by omega⟩ := by
              have : a_bwd ⟨i.val - 1, by omega⟩ = extendPoint p_n := by
                have : a_bwd ⟨i.val - 1, by omega⟩ = a_init k := by
                  simp only [a_init]; congr 1
                rw [this]; exact heq_k
              rw [this]; simp only [hp_n, extendPoint]
            have hrw : (resp_mod ⟨i.val - 1, h0'⟩ : ExtendedCarrier M atomMap r) = e_n := by
              rw [show (⟨i.val - 1, h0'⟩ : Fin n) = k from Fin.ext rfl, hmod_eq]
            rw [hab_pn, hrw]
            exact (hform_en_an A hA).symm
          · -- a_init(k) ≠ p_n: resp_mod(k) = resp_left(k), use tau_left
            have hmod_ne : resp_mod k = resp_left k := hresp_mod_ne k hne_k
            have hleft_i := hform_left ⟨1 + (i.val - 1), by omega⟩ A hA
            simp only [game_tuple, show 1 + (i.val - 1) ≠ 0 from by omega,
                       show ¬(1 + (i.val - 1) = n + 1) from by omega,
                       show ¬(1 + (i.val - 1) = n + 2) from by omega,
                       dite_false, show 1 + (i.val - 1) - 1 = i.val - 1 from by omega] at hleft_i
            show stavi_temporal_truth_mu N atomMap r (a_bwd ⟨i.val - 1, _⟩) A ↔
                 stavi_temporal_truth_mu M atomMap r (resp_mod ⟨i.val - 1, _⟩) A
            rw [show (⟨i.val - 1, by omega⟩ : Fin n) = k from Fin.ext rfl, hmod_ne]
            exact hleft_i
        · -- i inner, i-1=n: a_bwd(n)/e_n — from hform_en_an
          have hi_eq : i.val - 1 = n := by omega
          have hab : (a_bwd ⟨i.val - 1, by omega⟩ : ExtendedCarrier N atomMap r) =
                     a_bwd ⟨n, by omega⟩ := by congr 1; exact Fin.ext hi_eq
          rw [hab]
          exact (hform_en_an A hA).symm
    · -- Case B: b_sp > c, i.e., b_sp ∈ (c, y]. Use tau for round 2.
      push_neg at hbc
      have hc_lt_bsp : c < extendPoint (sig := sig) (atomMap := atomMap) (r := r) b_sp := hbc
      have hb_sp_cy : inClosedInterval c y (extendPoint b_sp) :=
        ⟨le_of_lt hc_lt_bsp, hb_sp.2⟩
      obtain ⟨b_resp, hb_resp_in, hcond_tau⟩ := hwin_tau b_sp hb_sp_cy
      -- b_resp ∈ [d, y'] ⊆ [x', y']
      refine ⟨b_resp, ⟨le_trans props.hx'd hb_resp_in.1, hb_resp_in.2⟩, ?_⟩
      -- Assemble winning condition from tau + e_n data.
      -- The target: ghr93_winning_condition (n+1)
      --   (game_tuple x' y' a_bwd b_resp)
      --   (game_tuple x y merged_resp b_sp)
      -- where merged_resp(i) = resp_tau(i) for i < n, merged_resp(n) = e_n.
      --
      -- We have hcond_tau: winning condition on (n)-round game
      --   (game_tuple d y' a_init b_resp) vs (game_tuple c y resp_tau b_sp)
      -- and hform_en_an: e_n and a_bwd(n) agree on rank-r formulas.
      --
      -- The (n+1)-round game tuple extends the tau game with:
      --   position 0: x'/x (instead of d/c)
      --   position n+1: a_bwd(n)/e_n (new position)
      --
      -- The ordering, gp, and formula properties at the tau-covered positions
      -- follow from hcond_tau (shifted). At position n+1 they follow from
      -- the forward game properties.
      obtain ⟨hord_tau, hgp_tau, hform_tau⟩ := hcond_tau
      refine ⟨?_, ?_, ?_⟩
      · -- same_order_type (n+1): tau sub-case (Case B)
        -- Derive (x' < d ↔ x < c) either from sigma or from degenerate case.
        have sig_x_d : (x' < d ↔ x < c) ∧ (x' = d ↔ x = c) := by
          rcases props.h_pt_xc with ⟨p_xc, hp_xc⟩ | ⟨hxc_eq, hx'd_eq, _, _⟩
          · -- Non-degenerate: instantiate sigma to extract ordering
            have hd_in_x'd : inClosedInterval x' d d := ⟨props.hx'd, le_refl d⟩
            obtain ⟨_resp_sig, _, hwin_sig_b⟩ :=
              props.sigma (fun _ : Fin n => d) (fun _ => hd_in_x'd)
            obtain ⟨_b_sig, _, hcond_sig_b⟩ := hwin_sig_b p_xc hp_xc
            obtain ⟨hord_sig_b, _, _⟩ := hcond_sig_b
            have h := hord_sig_b ⟨0, by omega⟩ ⟨n + 2, by omega⟩
            simp_game_tuple at h; exact h
          · -- Degenerate: x = c and x' = d, so both sides trivial
            subst hxc_eq; subst hx'd_eq
            exact ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
                   ⟨fun _ => rfl, fun _ => rfl⟩⟩
        -- Now extract tau orderings from hord_tau.
        have hab_n : a_bwd ⟨n, by omega⟩ = extendPoint p_n := hp_n
        have hab_eq : ∀ (k : Nat) (hk : k < n + 1), ¬(k < n) →
            a_bwd ⟨k, hk⟩ = extendPoint p_n := by
          intro k hk hkn
          have : k = n := Nat.eq_of_lt_succ_of_not_lt hk hkn
          subst this; exact hp_n
        have fwd_x_b := hord_fwd_x_en
        have fwd_x_y := hord_fwd_x_y
        have fwd_b_y := hord_fwd_en_y
        have tau_d_b : (d < extendPoint b_resp ↔ c < extendPoint b_sp) ∧
            (d = extendPoint b_resp ↔ c = extendPoint b_sp) := by
          have h := hord_tau ⟨0, by omega⟩ ⟨n + 1, by omega⟩
          simp_game_tuple at h; exact h
        have tau_d_y' : (d < y' ↔ c < y) ∧ (d = y' ↔ c = y) := by
          have h := hord_tau ⟨0, by omega⟩ ⟨n + 2, by omega⟩
          simp_game_tuple at h; exact h
        have tau_b_y' : (extendPoint b_resp < y' ↔ extendPoint b_sp < y) ∧
            (extendPoint b_resp = y' ↔ extendPoint b_sp = y) := by
          have h := hord_tau ⟨n + 1, by omega⟩ ⟨n + 2, by omega⟩
          simp_game_tuple at h; exact h
        -- Raw ordering facts from tau_left (in terms of resp_left) for Case B
        have tau_d_sel_raw : ∀ (k : Fin n),
            (d < a_init k ↔ c < resp_left k) ∧ (d = a_init k ↔ c = resp_left k) := by
          intro k; have h := hord_left ⟨0, by omega⟩ ⟨1 + k.val, by omega⟩
          simp_game_tuple at h; exact h
        have tau_sel_sel_raw : ∀ (k k' : Fin n),
            (a_init k < a_init k' ↔ resp_left k < resp_left k') ∧
            (a_init k = a_init k' ↔ resp_left k = resp_left k') := by
          intro k k'; have h := hord_left ⟨1 + k.val, by omega⟩ ⟨1 + k'.val, by omega⟩
          simp_game_tuple at h; exact h
        -- Ordering facts between resp_tau and b_sp (from original tau, used for b-position)
        have tau_sel_b_raw : ∀ (k : Fin n),
            (a_init k < extendPoint b_resp ↔ resp_tau k < extendPoint b_sp) ∧
            (a_init k = extendPoint b_resp ↔ resp_tau k = extendPoint b_sp) := by
          intro k; have h := hord_tau ⟨1 + k.val, by omega⟩ ⟨n + 1, by omega⟩
          simp_game_tuple at h; exact h
        have tau_b_sel_raw : ∀ (k : Fin n),
            (extendPoint b_resp < a_init k ↔ extendPoint b_sp < resp_tau k) ∧
            (extendPoint b_resp = a_init k ↔ extendPoint b_sp = resp_tau k) := by
          intro k; have h := hord_tau ⟨n + 1, by omega⟩ ⟨1 + k.val, by omega⟩
          simp_game_tuple at h; exact h
        have hd_le_sel : ∀ (k : Fin n), d ≤ a_init k :=
          fun k => (ha_init k).1
        -- Phase 3C-STRICT: Lift tau_left ordering to resp_mod (Case B)
        have hc_le_rtau : ∀ (k : Fin n), c ≤ resp_mod k :=
          fun k => (hresp_mod_in k).1
        have tau_d_sel : ∀ (k : Fin n),
            (d < a_init k ↔ c < resp_mod k) ∧ (d = a_init k ↔ c = resp_mod k) := by
          intro k
          rcases Decidable.em (a_init k = extendPoint p_n) with heq | hne
          · rw [hresp_mod_eq k heq, heq]
            exact ⟨hord_cd_en_pn.1.symm, hord_cd_en_pn.2.symm⟩
          · rw [hresp_mod_ne k hne]; exact tau_d_sel_raw k
        have tau_sel_b : ∀ (k : Fin n),
            (a_init k < extendPoint b_resp ↔ resp_mod k < extendPoint b_sp) ∧
            (a_init k = extendPoint b_resp ↔ resp_mod k = extendPoint b_sp) := by
          intro k
          rcases Decidable.em (a_init k = extendPoint p_n) with heq | hne
          · sorry -- Phase 3C-STRICT: equality case sel vs b_resp (needs composed game)
          · -- Strict case: resp_mod(k) = resp_left(k), need resp_left vs b_sp ordering
            sorry -- Phase 3C-STRICT: strict case sel vs b_resp (needs composed game for b_sp ordering)
        have tau_sel_y : ∀ (k : Fin n),
            (a_init k < y' ↔ resp_mod k < y) ∧
            (a_init k = y' ↔ resp_mod k = y) := by
          intro k
          rcases Decidable.em (a_init k = extendPoint p_n) with heq | hne
          · rw [hresp_mod_eq k heq, heq]
            exact ⟨hord_fwd_en_y.1.symm, hord_fwd_en_y.2.symm⟩
          · -- Strict case: use transitivity through e_n
            rw [hresp_mod_ne k hne]
            have hlt_pn : a_init k < extendPoint p_n := lt_of_le_of_ne (h_ainit_le_pn k) hne
            have hlt_en : resp_left k < e_n := (hord_left_sel_pn k).1.mp hlt_pn
            have hlt_y' : a_init k < y' := lt_of_lt_of_le hlt_pn h_pn_le_y'
            have hlt_y : resp_left k < y := lt_of_lt_of_le hlt_en h_en_le_y
            exact ⟨⟨fun _ => hlt_y, fun _ => hlt_y'⟩,
                   ⟨fun h => absurd hlt_y' (by rw [h]; exact lt_irrefl _),
                    fun h => absurd hlt_y (by rw [h]; exact lt_irrefl _)⟩⟩
        have tau_sel_sel : ∀ (k k' : Fin n),
            (a_init k < a_init k' ↔ resp_mod k < resp_mod k') ∧
            (a_init k = a_init k' ↔ resp_mod k = resp_mod k') := by
          intro k k'
          rcases Decidable.em (a_init k = extendPoint p_n) with heq_k | hne_k
          · rcases Decidable.em (a_init k' = extendPoint p_n) with heq_k' | hne_k'
            · rw [hresp_mod_eq k heq_k, hresp_mod_eq k' heq_k', heq_k, heq_k']
              exact ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
                     ⟨fun _ => rfl, fun _ => rfl⟩⟩
            · -- k = p_n, k' ≠ p_n
              rw [hresp_mod_eq k heq_k, hresp_mod_ne k' hne_k', heq_k]
              have hlt_k' : a_init k' < extendPoint p_n :=
                lt_of_le_of_ne (h_ainit_le_pn k') hne_k'
              have hlt_resp_k' : resp_left k' < e_n := (hord_left_sel_pn k').1.mp hlt_k'
              exact ⟨⟨fun h => absurd h (not_lt_of_gt hlt_k'),
                      fun h => absurd h (not_lt_of_gt hlt_resp_k')⟩,
                     ⟨fun h => absurd hlt_k' (h ▸ lt_irrefl _),
                      fun h => absurd hlt_resp_k' (h ▸ lt_irrefl _)⟩⟩
          · rcases Decidable.em (a_init k' = extendPoint p_n) with heq_k' | hne_k'
            · -- k ≠ p_n, k' = p_n
              rw [hresp_mod_ne k hne_k, hresp_mod_eq k' heq_k', heq_k']
              have hlt_k : a_init k < extendPoint p_n :=
                lt_of_le_of_ne (h_ainit_le_pn k) hne_k
              have hlt_resp_k : resp_left k < e_n := (hord_left_sel_pn k).1.mp hlt_k
              exact ⟨⟨fun _ => hlt_resp_k, fun _ => hlt_k⟩,
                     ⟨fun h => absurd hlt_k (h ▸ lt_irrefl _),
                      fun h => absurd hlt_resp_k (h ▸ lt_irrefl _)⟩⟩
            · -- Neither = p_n
              rw [hresp_mod_ne k hne_k, hresp_mod_ne k' hne_k']
              exact tau_sel_sel_raw k k'
        have tau_b_sel : ∀ (k : Fin n),
            (extendPoint b_resp < a_init k ↔ extendPoint b_sp < resp_mod k) ∧
            (extendPoint b_resp = a_init k ↔ extendPoint b_sp = resp_mod k) := by
          intro k
          rcases Decidable.em (a_init k = extendPoint p_n) with heq | hne
          · sorry -- Phase 3C-STRICT: equality case b_resp vs sel (needs composed game)
          · sorry -- Phase 3C-STRICT: strict case b_resp vs sel (needs composed game for b_sp ordering)
        -- sel_pn_ord: direct from hord_left_sel_pn (Case B, Phase 3C-STRICT resolved!)
        have sel_pn_ord : ∀ (k : Fin n),
            (a_init k < extendPoint p_n ↔ resp_mod k < e_n) ∧
            (a_init k = extendPoint p_n ↔ resp_mod k = e_n) := by
          intro k
          rcases Decidable.em (a_init k = extendPoint p_n) with heq | hne
          · rw [hresp_mod_eq k heq, heq]
            exact ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
                   ⟨fun _ => rfl, fun _ => rfl⟩⟩
          · rw [hresp_mod_ne k hne]
            exact hord_left_sel_pn k
        have pn_sel_ord : ∀ (k : Fin n),
            (extendPoint p_n < a_init k ↔ e_n < resp_mod k) ∧
            (extendPoint p_n = a_init k ↔ e_n = resp_mod k) := by
          intro k; have h := sel_pn_ord k
          exact ⟨⟨fun hba => by
            rcases lt_trichotomy (resp_mod k) e_n with hcd | hcd | hcd
            · exact absurd (h.1.mpr hcd) (not_lt.mpr (le_of_lt hba))
            · exact absurd (h.2.mpr hcd) (ne_of_gt hba)
            · exact hcd,
            fun hdc => by
            rcases lt_trichotomy (a_init k) (extendPoint p_n) with hab | hab | hab
            · exact absurd (h.1.mp hab) (not_lt.mpr (le_of_lt hdc))
            · exact absurd (h.2.mp hab) (ne_of_gt hdc)
            · exact hab⟩,
            ⟨fun h2 => (h.2.mp h2.symm).symm, fun h2 => (h.2.mpr h2.symm).symm⟩⟩
        -- Dispatch all N×N grid cases (same pattern as Case A)
        same_order_type_grid <;>
          (try rw [hab_eq _ _ (by assumption)]) <;>
          (try rw [hab_eq _ _ (by assumption)]) <;>
          first
          | order_refl
          -- b_resp vs b_sp (tau)
          | exact tau_d_b | exact ⟨tau_d_b.1.symm, tau_d_b.2.symm⟩
          -- b_resp vs y (tau)
          | exact tau_b_y' | exact ⟨tau_b_y'.1.symm, tau_b_y'.2.symm⟩
          -- d vs y (tau)
          | exact tau_d_y' | exact ⟨tau_d_y'.1.symm, tau_d_y'.2.symm⟩
          -- x vs y (forward)
          | exact fwd_x_y | exact ⟨fwd_x_y.1.symm, fwd_x_y.2.symm⟩
          -- x vs e_n/p_n (forward)
          | exact fwd_x_b | exact ⟨fwd_x_b.1.symm, fwd_x_b.2.symm⟩
          -- e_n/p_n vs y (forward)
          | exact fwd_b_y | exact ⟨fwd_b_y.1.symm, fwd_b_y.2.symm⟩
          -- sel vs sel (tau)
          | exact tau_sel_sel ⟨_, ‹_›⟩ ⟨_, ‹_›⟩
          -- sel vs b (tau)
          | exact tau_sel_b ⟨_, ‹_›⟩ | exact ⟨(tau_sel_b ⟨_, ‹_›⟩).1.symm, (tau_sel_b ⟨_, ‹_›⟩).2.symm⟩
          | exact tau_b_sel ⟨_, ‹_›⟩ | exact ⟨(tau_b_sel ⟨_, ‹_›⟩).1.symm, (tau_b_sel ⟨_, ‹_›⟩).2.symm⟩
          -- sel vs y (tau)
          | exact tau_sel_y ⟨_, ‹_›⟩ | exact ⟨(tau_sel_y ⟨_, ‹_›⟩).1.symm, (tau_sel_y ⟨_, ‹_›⟩).2.symm⟩
          -- x vs b pivot through d/c
          | exact pivot_chain_order' props.hx'd hb_resp_in.1 props.hxc
              (le_of_lt hc_lt_bsp) sig_x_d tau_d_b
          | exact pivot_chain_order_rev' hb_resp_in.1 props.hx'd
              (le_of_lt hc_lt_bsp) props.hxc tau_d_b sig_x_d
          -- x vs sel pivot through d/c
          | exact pivot_chain_order' props.hx'd (hd_le_sel ⟨_, ‹_›⟩) props.hxc
              (hc_le_rtau ⟨_, ‹_›⟩) sig_x_d (tau_d_sel ⟨_, ‹_›⟩)
          | exact pivot_chain_order_rev' (hd_le_sel ⟨_, ‹_›⟩) props.hx'd
              (hc_le_rtau ⟨_, ‹_›⟩) props.hxc (tau_d_sel ⟨_, ‹_›⟩) sig_x_d
          -- x vs y pivot through d/c
          | exact pivot_chain_order' props.hx'd props.hdy' props.hxc props.hcy
              sig_x_d tau_d_y'
          | exact pivot_chain_order_rev' props.hdy' props.hx'd props.hcy props.hxc
              tau_d_y' sig_x_d
          -- b vs sel pivot through d/c
          | exact pivot_chain_order' hb_resp_in.1 (hd_le_sel ⟨_, ‹_›⟩) (le_of_lt hc_lt_bsp)
              (hc_le_rtau ⟨_, ‹_›⟩) tau_d_b (tau_d_sel ⟨_, ‹_›⟩)
          | exact pivot_chain_order_rev' (hd_le_sel ⟨_, ‹_›⟩) hb_resp_in.1
              (hc_le_rtau ⟨_, ‹_›⟩) (le_of_lt hc_lt_bsp) (tau_d_sel ⟨_, ‹_›⟩) tau_d_b
          -- b vs y pivot through d/c
          | exact pivot_chain_order' hb_resp_in.1 props.hdy' (le_of_lt hc_lt_bsp) props.hcy
              tau_d_b tau_d_y'
          | exact pivot_chain_order_rev' props.hdy' hb_resp_in.1 props.hcy (le_of_lt hc_lt_bsp)
              tau_d_y' tau_d_b
          -- sel vs y pivot through d/c
          | exact pivot_chain_order' (hd_le_sel ⟨_, ‹_›⟩) props.hdy'
              (hc_le_rtau ⟨_, ‹_›⟩) props.hcy (tau_d_sel ⟨_, ‹_›⟩) tau_d_y'
          | exact pivot_chain_order_rev' props.hdy' (hd_le_sel ⟨_, ‹_›⟩)
              props.hcy (hc_le_rtau ⟨_, ‹_›⟩) tau_d_y' (tau_d_sel ⟨_, ‹_›⟩)
          -- sel vs p_n/e_n pivot through d/c (same as Case A)
          | (exact pivot_chain_order_rev' hd_le_pn (hd_le_sel ⟨_, ‹_›⟩)
              hc_le_en (hc_le_rtau ⟨_, ‹_›⟩) hord_cd_en_pn (tau_d_sel ⟨_, ‹_›⟩))
          | (exact pivot_chain_order' (hd_le_sel ⟨_, ‹_›⟩) hd_le_pn
              (hc_le_rtau ⟨_, ‹_›⟩) hc_le_en (tau_d_sel ⟨_, ‹_›⟩) hord_cd_en_pn)
          -- x vs p_n/e_n pivot via sig_x_d + hord_cd_en_pn
          | (exact pivot_chain_order' props.hx'd hd_le_pn props.hxc hc_le_en
              sig_x_d hord_cd_en_pn)
          | (exact pivot_chain_order_rev' hd_le_pn props.hx'd hc_le_en props.hxc
              hord_cd_en_pn sig_x_d)
          -- b vs p_n/e_n pivot through d/c
          | (exact pivot_chain_order' hb_resp_in.1 hd_le_pn (le_of_lt hc_lt_bsp) hc_le_en
              tau_d_b hord_cd_en_pn)
          | (exact pivot_chain_order_rev' hd_le_pn hb_resp_in.1 hc_le_en (le_of_lt hc_lt_bsp)
              hord_cd_en_pn tau_d_b)
          -- p_n/e_n vs y
          | (exact pivot_chain_order' hd_le_pn props.hdy' hc_le_en props.hcy
              hord_cd_en_pn tau_d_y')
          | (exact pivot_chain_order_rev' props.hdy' hd_le_pn props.hcy hc_le_en
              tau_d_y' hord_cd_en_pn)
          -- b_resp vs p_n (pivot through d/c + hord_cd_en_pn)
          | (exact pivot_chain_order' hb_resp_in.1 hd_le_pn (le_of_lt hc_lt_bsp)
              hc_le_en tau_d_b hord_cd_en_pn)
          -- y' vs b_resp (reverse of tau_b_y')
          | (exact ⟨tau_b_y'.1.symm, tau_b_y'.2.symm⟩)
          -- y' vs sel (Fin mismatch, convert tau_sel_y)
          | (have key := (tau_sel_y ⟨_, ‹_›⟩)
             convert ⟨key.1.symm, key.2.symm⟩ using 3 <;> (congr 1; exact Fin.ext (by omega)))
          -- y' vs p_n (reverse of fwd_b_y)
          | (exact ⟨fwd_b_y.1.symm, fwd_b_y.2.symm⟩)
          -- p_n vs x' (reverse of fwd_x_b)
          | (exact ⟨fwd_x_b.1.symm, fwd_x_b.2.symm⟩)
          -- p_n vs b_resp (pivot_chain_order_rev')
          | (exact pivot_chain_order_rev' hd_le_pn hb_resp_in.1 hc_le_en
              (le_of_lt hc_lt_bsp) hord_cd_en_pn tau_d_b)
          -- sel(i) vs p_n (Fin mismatch, convert pivot_chain_order')
          | (have key := pivot_chain_order' (hd_le_sel ⟨_, ‹_›⟩) hd_le_pn
                  (hc_le_rtau ⟨_, ‹_›⟩) hc_le_en (tau_d_sel ⟨_, ‹_›⟩) hord_cd_en_pn
             convert key using 3 <;> (congr 1; exact Fin.ext (by omega)))
          -- p_n vs sel(j)
          | (convert pivot_chain_order_rev' hd_le_pn (hd_le_sel ⟨_, ‹_›⟩)
                  hc_le_en (hc_le_rtau ⟨_, ‹_›⟩)
                  ⟨hord_cd_en_pn.1.symm, hord_cd_en_pn.2.symm⟩
                  (tau_d_sel ⟨_, ‹_›⟩) using 3 <;> (congr 1; exact Fin.ext (by omega)))
          -- b_resp vs p_n (pivot through d/c + hord_cd_en_pn)
          | (exact pivot_chain_order' hb_resp_in.1 hd_le_pn
              (le_of_lt hc_lt_bsp) hc_le_en tau_d_b hord_cd_en_pn)
          -- p_n vs b_resp (reverse)
          | (exact pivot_chain_order_rev' hd_le_pn hb_resp_in.1
              hc_le_en (le_of_lt hc_lt_bsp) hord_cd_en_pn tau_d_b)
          -- y' vs b_resp (reverse of tau_b_y')
          | (exact ⟨tau_b_y'.1.symm, tau_b_y'.2.symm⟩)
          -- y' vs p_n (reverse of fwd_b_y)
          | (exact ⟨fwd_b_y.1.symm, fwd_b_y.2.symm⟩)
          -- p_n vs x' (reverse of fwd_x_b)
          | (exact ⟨fwd_x_b.1.symm, fwd_x_b.2.symm⟩)
          -- y' vs sel(j-1) (Fin mismatch)
          | (convert ⟨(tau_sel_y ⟨_, ‹_›⟩).1.symm, (tau_sel_y ⟨_, ‹_›⟩).2.symm⟩ using 3
             <;> (congr 1; exact Fin.ext (by omega)))
          -- sel(i-1) vs p_n (rewrite + pivot with Fin convert)
          | (rw [hab_eq _ _ (by assumption)]
             convert pivot_chain_order' (hd_le_sel ⟨_, ‹_›⟩) hd_le_pn
                 (hc_le_rtau ⟨_, ‹_›⟩) hc_le_en (tau_d_sel ⟨_, ‹_›⟩) hord_cd_en_pn
                 using 3 <;> (congr 1; exact Fin.ext (by omega)))
          -- p_n vs sel(j-1) (Fin mismatch: pivot_chain_order_rev' with convert)
          | (convert pivot_chain_order_rev' hd_le_pn (hd_le_sel ⟨_, ‹_›⟩)
                 hc_le_en (hc_le_rtau ⟨_, ‹_›⟩)
                 ⟨hord_cd_en_pn.1.symm, hord_cd_en_pn.2.symm⟩
                 (tau_d_sel ⟨_, ‹_›⟩) using 3
             <;> (congr 1; exact Fin.ext (by omega)))
          -- Remaining grid goals: b_resp/p_n, y'/b_resp, y'/sel, y'/p_n, p_n/x, p_n/b_resp, sel/p_n, p_n/sel
          | (first
            | (convert pn_sel_ord ⟨_, ‹_›⟩ using 3 <;> (congr 1; exact Fin.ext (by omega)))
            | (rw [show (a_bwd ⟨_, _⟩ : ExtendedCarrier N atomMap r) = extendPoint p_n
                   from hab_eq _ _ (by assumption)]
               exact sel_pn_ord ⟨_, ‹_›⟩)
            | (have key := (tau_sel_y ⟨_, ‹_›⟩)
               exact ⟨key.1.symm, key.2.symm⟩)
            | exact ⟨fwd_b_y.1.symm, fwd_b_y.2.symm⟩
            | exact ⟨fwd_x_b.1.symm, fwd_x_b.2.symm⟩
            | exact ⟨tau_b_y'.1.symm, tau_b_y'.2.symm⟩
            | (exact pivot_chain_order' hb_resp_in.1 hd_le_pn
                  (le_of_lt hc_lt_bsp) hc_le_en tau_d_b
                  ⟨hord_cd_en_pn.1.symm, hord_cd_en_pn.2.symm⟩)
            | (exact pivot_chain_order_rev' hd_le_pn hb_resp_in.1
                  hc_le_en (le_of_lt hc_lt_bsp)
                  ⟨hord_cd_en_pn.1.symm, hord_cd_en_pn.2.symm⟩ tau_d_b)
            -- y' vs sel(j-1) reverse: impossible < (sel ≤ y', resp_tau ≤ y), = from tau_sel_y
            | (exact ⟨⟨fun h => absurd (lt_of_lt_of_le h (ha_bwd ⟨_, by omega⟩).2)
                           (lt_irrefl _),
                       fun h => absurd (lt_of_lt_of_le h (hresp_mod_in ⟨_, ‹_›⟩).2)
                           (lt_irrefl _)⟩,
                      ⟨fun h => ((tau_sel_y ⟨_, ‹_›⟩).2.mp h.symm).symm,
                       fun h => ((tau_sel_y ⟨_, ‹_›⟩).2.mpr h.symm).symm⟩⟩)
            -- sel(i) vs p_n: rewrite j-side a_bwd to p_n via hab_eq, then sel_pn_ord
            | (rw [hab_eq _ (by omega) (by assumption)]
               exact sel_pn_ord ⟨_, ‹_›⟩)
            -- y' vs b_resp: impossible < (b_resp ≤ y', b_sp ≤ y), = from tau_b_y'
            | (exact ⟨⟨fun h => absurd h (not_lt.mpr hb_resp_in.2),
                       fun h => absurd h (not_lt.mpr hb_sp_cy.2)⟩,
                      ⟨fun h => (tau_b_y'.2.mp h.symm).symm,
                       fun h => (tau_b_y'.2.mpr h.symm).symm⟩⟩)
            -- y' vs p_n: impossible < (p_n ≤ y', e_n ≤ y), = from fwd_b_y
            | (exact ⟨⟨fun h => absurd h (not_lt.mpr hp_n_in.2),
                       fun h => absurd h (not_lt.mpr he_n_in.2)⟩,
                      ⟨fun h => (fwd_b_y.2.mpr h.symm).symm,
                       fun h => (fwd_b_y.2.mp h.symm).symm⟩⟩)
            -- p_n vs x': impossible < (x' ≤ p_n, x ≤ e_n), = from fwd_x_b
            | (exact ⟨⟨fun h => absurd h (not_lt.mpr hp_n_in.1),
                       fun h => absurd h (not_lt.mpr he_n_in.1)⟩,
                      ⟨fun h => (fwd_x_b.2.mpr h.symm).symm,
                       fun h => (fwd_x_b.2.mp h.symm).symm⟩⟩)
            -- sel(i) vs p_n: rw j-side a_bwd to p_n via hab_eq, then sel_pn_ord
            | (rw [show (a_bwd ⟨_, _⟩ : ExtendedCarrier N atomMap r) = extendPoint p_n
                   from hab_eq _ _ (by assumption)]
               exact sel_pn_ord ⟨_, ‹_›⟩)
            -- sel(i) vs p_n: Fin convert variant
            | (rw [show (a_bwd ⟨_, _⟩ : ExtendedCarrier N atomMap r) = extendPoint p_n
                   from hab_eq _ _ (by assumption)]
               convert sel_pn_ord ⟨_, ‹_›⟩ using 3
               <;> (congr 1; exact Fin.ext (by omega)))
            -- sel(i) vs p_n: rename indices, rewrite j-side a_bwd via hab_eq, then sel_pn_ord with Fin bridge
            | (rename_i i j _ _ _ _ _ hj_not_lt
               have hj_rw : a_bwd ⟨↑j - 1, by omega⟩ = extendPoint p_n :=
                 hab_eq _ (by omega) hj_not_lt
               rw [hj_rw]
               convert sel_pn_ord ⟨_, ‹_›⟩ using 3
               <;> (congr 1; exact Fin.ext (by omega)))
            -- sel(i) vs p_n: 8-hypothesis variant (rename_i with 6 underscores)
            | (rename_i i j _ _ _ _ _ _ hi_lt hj_not_lt
               have hj_rw : a_bwd ⟨↑j - 1, by omega⟩ = extendPoint p_n :=
                 hab_eq _ (by omega) hj_not_lt
               rw [hj_rw]
               convert sel_pn_ord ⟨_, hi_lt⟩ using 3
               <;> (congr 1; exact Fin.ext (by omega)))
            -- b_resp vs p_n / p_n vs b_resp: sorry'd pending Phase 3C.
            -- In Case B, b_resp ∈ [d, y'] creates a fan (d ≤ b_resp AND d ≤ p_n)
            -- rather than a chain, so pivot_chain_order' cannot derive this.
            -- The property IS mathematically true once d is redefined as the minimum
            -- of all selections (GHR93). See: specs/199_grid_order_tactic/reports/02_blocker-analysis.md
            | sorry)
        /- Dead code preserved for reference (tau ordering extractions):
        have hd_le_an := props.hd_le_an
        -- Forward game orderings
        have fwd_x_b : (x < e_n ↔ x' < extendPoint p_n) ∧
            (x = e_n ↔ x' = extendPoint p_n) := by
          have h := hord_fwd ⟨0, by omega⟩ ⟨n + 1 + 1, by omega⟩
          simp only [game_tuple_zero_eq, game_tuple_b_eq] at h; exact h
        have fwd_x_y : (x < y ↔ x' < y') ∧ (x = y ↔ x' = y') := by
          have h := hord_fwd ⟨0, by omega⟩ ⟨n + 1 + 2, by omega⟩
          simp only [game_tuple_zero_eq, game_tuple_y_eq] at h; exact h
        have fwd_b_y : (e_n < y ↔ extendPoint p_n < y') ∧
            (e_n = y ↔ extendPoint p_n = y') := by
          have h := hord_fwd ⟨n + 1 + 1, by omega⟩ ⟨n + 1 + 2, by omega⟩
          simp only [game_tuple_b_eq, game_tuple_y_eq] at h; exact h
        -- Tau game orderings
        have tau_d_b : (d < extendPoint b_resp ↔ c < extendPoint b_sp) ∧
            (d = extendPoint b_resp ↔ c = extendPoint b_sp) := by
          have h := hord_tau ⟨0, by omega⟩ ⟨n + 1, by omega⟩
          simp only [game_tuple_zero_eq, game_tuple_b_eq] at h; exact h
        have tau_d_y' : (d < y' ↔ c < y) ∧ (d = y' ↔ c = y) := by
          have h := hord_tau ⟨0, by omega⟩ ⟨n + 2, by omega⟩
          simp only [game_tuple_zero_eq, game_tuple_y_eq] at h; exact h
        have tau_b_y' : (extendPoint b_resp < y' ↔ extendPoint b_sp < y) ∧
            (extendPoint b_resp = y' ↔ extendPoint b_sp = y) := by
          have h := hord_tau ⟨n + 1, by omega⟩ ⟨n + 2, by omega⟩
          simp only [game_tuple_b_eq, game_tuple_y_eq] at h; exact h
        have tau_d_sel : ∀ (k : Fin n),
            (d < a_init k ↔ c < resp_tau k) ∧ (d = a_init k ↔ c = resp_tau k) := by
          intro k; have h := hord_tau ⟨0, by omega⟩ ⟨1 + k.val, by omega⟩
          simp only [game_tuple_zero_eq, game_tuple_sel_eq] at h; exact h
        have tau_sel_b : ∀ (k : Fin n),
            (a_init k < extendPoint b_resp ↔ resp_tau k < extendPoint b_sp) ∧
            (a_init k = extendPoint b_resp ↔ resp_tau k = extendPoint b_sp) := by
          intro k; have h := hord_tau ⟨1 + k.val, by omega⟩ ⟨n + 1, by omega⟩
          simp only [game_tuple_sel_eq, game_tuple_b_eq] at h; exact h
        have tau_sel_y : ∀ (k : Fin n),
            (a_init k < y' ↔ resp_tau k < y) ∧
            (a_init k = y' ↔ resp_tau k = y) := by
          intro k; have h := hord_tau ⟨1 + k.val, by omega⟩ ⟨n + 2, by omega⟩
          simp only [game_tuple_sel_eq, game_tuple_y_eq] at h; exact h
        have tau_sel_sel : ∀ (k k' : Fin n),
            (a_init k < a_init k' ↔ resp_tau k < resp_tau k') ∧
            (a_init k = a_init k' ↔ resp_tau k = resp_tau k') := by
          intro k k'; have h := hord_tau ⟨1 + k.val, by omega⟩ ⟨1 + k'.val, by omega⟩
          simp only [game_tuple_sel_eq] at h; exact h
        have tau_b_sel : ∀ (k : Fin n),
            (extendPoint b_resp < a_init k ↔ extendPoint b_sp < resp_tau k) ∧
            (extendPoint b_resp = a_init k ↔ extendPoint b_sp = resp_tau k) := by
          intro k; have h := hord_tau ⟨n + 1, by omega⟩ ⟨1 + k.val, by omega⟩
          simp only [game_tuple_b_eq, game_tuple_sel_eq] at h; exact h
        -- Main split: delta + split_ifs + simp_all, then close remaining goals.
        -- NOTE: hab_n is NOT in context yet — simp_all cannot rewrite it.
        sorry
        -- NOTE: Round 9 analysis found the block-commented proof had a sorry
        -- fallback. The proof needs (x' < d ↔ x < c) for pivot_chain_order
        -- but this is not directly available from forward or tau games.
        -- A sigma-game instantiation or alternative approach is needed.
        -- G0: x' vs b_resp — pivot through d/c
        · exact pivot_chain_order props.hx'd hb_resp_in.1
            props.hxc (le_of_lt hc_lt_bsp) tau_d_b.1 tau_d_b.2
            (by rw [hab_n]; exact fwd_x_b.1) (by rw [hab_n]; exact fwd_x_b.2)
        -- G1: x' vs y' — from forward game
        · exact fwd_x_y
        -- G2: x' vs sel(j) — split on j-1<n
        · split_ifs with hjn
          · exact pivot_chain_order props.hx'd (h_no_split ⟨_, by omega⟩)
              props.hxc (hresp_tau_in ⟨_, hjn⟩).1
              (by rw [hab_n]; exact fwd_x_b.1) (by rw [hab_n]; exact fwd_x_b.2)
              (tau_d_sel ⟨_, hjn⟩).1 (tau_d_sel ⟨_, hjn⟩).2
          · rw [show a_bwd ⟨j.val - 1, _⟩ = a_bwd ⟨n, by omega⟩ from
              by congr 1; exact Fin.ext (by omega), hab_n]
            exact ⟨fwd_x_b.1.symm, fwd_x_b.2.symm⟩
        -- G3: b_resp vs x' — reverse of G0
        · exact pivot_chain_order_rev hb_resp_in.1 props.hx'd
            (le_of_lt hc_lt_bsp) props.hxc
            tau_d_b.1 tau_d_b.2
            (by rw [hab_n]; exact fwd_x_b.1) (by rw [hab_n]; exact fwd_x_b.2)
        -- G4: b_resp vs y' — from tau
        · exact tau_b_y'
        -- G5: b_resp vs sel(j)
        · split_ifs with hjn
          · exact tau_b_sel ⟨_, hjn⟩
          · rw [show a_bwd ⟨j.val - 1, _⟩ = a_bwd ⟨n, by omega⟩ from
              by congr 1; exact Fin.ext (by omega), hab_n]
            exact pivot_chain_order_rev hb_resp_in.1
              (by rw [hab_n] at hd_le_an ⊢; exact hd_le_an)
              (le_of_lt hc_lt_bsp) he_n_in.1
              tau_d_b.1 tau_d_b.2
              (by rw [hab_n]; exact fwd_x_b.1) (by rw [hab_n]; exact fwd_x_b.2)
        -- G6: y' vs x' — reverse of G1
        · exact ⟨fwd_x_y.1.symm, fwd_x_y.2.symm⟩
        -- G7: y' vs b_resp — reverse of G4
        · exact ⟨tau_b_y'.1.symm, tau_b_y'.2.symm⟩
        -- G8: y' vs sel(j)
        · split_ifs with hjn
          · exact pivot_chain_order_rev props.hdy' (h_no_split ⟨_, by omega⟩)
              props.hcy (hresp_tau_in ⟨_, hjn⟩).1
              tau_d_y'.1 tau_d_y'.2
              (tau_d_sel ⟨_, hjn⟩).1 (tau_d_sel ⟨_, hjn⟩).2
          · rw [show a_bwd ⟨j.val - 1, _⟩ = a_bwd ⟨n, by omega⟩ from
              by congr 1; exact Fin.ext (by omega), hab_n]
            exact ⟨fwd_b_y.1.symm, fwd_b_y.2.symm⟩
        -- G9: sel(i) vs x'
        · split_ifs with hin
          · exact pivot_chain_order_rev (h_no_split ⟨_, by omega⟩) props.hx'd
              (hresp_tau_in ⟨_, hin⟩).1 props.hxc
              (tau_d_sel ⟨_, hin⟩).1 (tau_d_sel ⟨_, hin⟩).2
              (by rw [hab_n]; exact fwd_x_b.1) (by rw [hab_n]; exact fwd_x_b.2)
          · rw [show a_bwd ⟨i.val - 1, _⟩ = a_bwd ⟨n, by omega⟩ from
              by congr 1; exact Fin.ext (by omega), hab_n]
            exact ⟨fwd_x_b.1, fwd_x_b.2⟩
        -- G10: sel(i) vs b_resp
        · split_ifs with hin
          · exact tau_sel_b ⟨_, hin⟩
          · rw [show a_bwd ⟨i.val - 1, _⟩ = a_bwd ⟨n, by omega⟩ from
              by congr 1; exact Fin.ext (by omega), hab_n]
            exact pivot_chain_order
              (by rw [hab_n] at hd_le_an ⊢; exact hd_le_an) hb_resp_in.1
              he_n_in.1 (le_of_lt hc_lt_bsp)
              (by rw [hab_n]; exact ⟨fun h => fwd_x_b.1.mp (lt_of_le_of_lt props.hx'd h),
                fun h => fwd_x_b.1.mpr (lt_of_le_of_lt props.hxc h)⟩)
              (by rw [hab_n]; exact ⟨fun h => (fwd_x_b.2.mp (le_antisymm props.hx'd
                (h ▸ hd_le_an))).trans h,
                fun h => (fwd_x_b.2.mpr (le_antisymm props.hxc (h ▸ he_n_in.1))).trans h⟩)
              tau_d_b.1 tau_d_b.2
        -- G11: sel(i) vs y'
        · split_ifs with hin
          · exact tau_sel_y ⟨_, hin⟩
          · rw [show a_bwd ⟨i.val - 1, _⟩ = a_bwd ⟨n, by omega⟩ from
              by congr 1; exact Fin.ext (by omega), hab_n]
            exact fwd_b_y
        -- G12: sel(i) vs sel(j)
        · split_ifs with hin hjn
          · exact tau_sel_sel ⟨_, hin⟩ ⟨_, hjn⟩
          · rw [show a_bwd ⟨j.val - 1, _⟩ = a_bwd ⟨n, by omega⟩ from
              by congr 1; exact Fin.ext (by omega), hab_n]
            exact pivot_chain_order ((ha_init ⟨_, hin⟩).1)
              (by rw [hab_n] at hd_le_an ⊢; exact hd_le_an)
              (hresp_tau_in ⟨_, hin⟩).1 he_n_in.1
              (tau_d_sel ⟨_, hin⟩).1 (tau_d_sel ⟨_, hin⟩).2
              (by rw [hab_n]; exact fwd_x_b.1) (by rw [hab_n]; exact fwd_x_b.2)
          · rw [show a_bwd ⟨i.val - 1, _⟩ = a_bwd ⟨n, by omega⟩ from
              by congr 1; exact Fin.ext (by omega), hab_n]
            exact pivot_chain_order_rev
              (by rw [hab_n] at hd_le_an ⊢; exact hd_le_an)
              ((ha_init ⟨_, hjn⟩).1)
              he_n_in.1 (hresp_tau_in ⟨_, hjn⟩).1
              (by rw [hab_n]; exact fwd_x_b.1) (by rw [hab_n]; exact fwd_x_b.2)
              (tau_d_sel ⟨_, hjn⟩).1 (tau_d_sel ⟨_, hjn⟩).2
          · rw [show a_bwd ⟨i.val - 1, _⟩ = a_bwd ⟨n, by omega⟩ from
              by congr 1; exact Fin.ext (by omega),
              show a_bwd ⟨j.val - 1, _⟩ = a_bwd ⟨n, by omega⟩ from
              by congr 1; exact Fin.ext (by omega)]
            exact ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
                   ⟨fun _ => rfl, fun _ => rfl⟩⟩
        -/
      · -- gap_point_agreement (n+1): for all positions
        intro i
        simp only [game_tuple]
        split_ifs with h0 hn1 hn2 h0' hlt
        · -- i=0: x'/x — from d-compatible big game
          exact ⟨hgp_fwd_x.1.symm, hgp_fwd_x.2.symm⟩
        · -- i=n+2: extendPoint b_resp / extendPoint b_sp
          -- Both are Sum.inl, hence both are points and neither is a gap
          constructor
          · exact ⟨fun _ => ⟨b_sp, rfl⟩, fun _ => ⟨b_resp, rfl⟩⟩
          · constructor <;> intro ⟨g, hg⟩ <;> cases hg
        · -- i=n+3: y'/y — from d-compatible big game
          exact ⟨hgp_fwd_y.1.symm, hgp_fwd_y.2.symm⟩
        · -- i inner, i-1 < n: a_bwd(i-1) / resp_mod(i-1) — Phase 3C-EQ case split
          let k : Fin n := ⟨i.val - 1, by omega⟩
          rcases Decidable.em (a_init k = extendPoint p_n) with heq_k | hne_k
          · have hmod_eq : resp_mod k = e_n := hresp_mod_eq k heq_k
            show (IsPoint (a_bwd ⟨i.val - 1, _⟩) ↔ IsPoint (resp_mod ⟨i.val - 1, _⟩)) ∧
                 (IsGap (a_bwd ⟨i.val - 1, _⟩) ↔ IsGap (resp_mod ⟨i.val - 1, _⟩))
            rw [show (⟨i.val - 1, by omega⟩ : Fin n) = k from Fin.ext rfl, hmod_eq]
            have : a_bwd ⟨i.val - 1, by omega⟩ = extendPoint p_n := by
              show a_init k = extendPoint p_n; exact heq_k
            rw [this]
            constructor
            · exact ⟨fun _ => ⟨e_n_pt, rfl⟩, fun _ => ⟨p_n, rfl⟩⟩
            · constructor <;> intro ⟨g, hg⟩ <;> exact (Sum.inl_ne_inr hg).elim
          · -- a_init(k) ≠ p_n: resp_mod(k) = resp_left(k), use tau_left
            have hmod_ne : resp_mod k = resp_left k := hresp_mod_ne k hne_k
            have hleft_i := _hgp_left ⟨1 + (i.val - 1), by omega⟩
            simp only [game_tuple, show 1 + (i.val - 1) ≠ 0 from by omega,
                       show ¬(1 + (i.val - 1) = n + 1) from by omega,
                       show ¬(1 + (i.val - 1) = n + 2) from by omega,
                       dite_false, show 1 + (i.val - 1) - 1 = i.val - 1 from by omega] at hleft_i
            show (IsPoint (a_bwd ⟨i.val - 1, _⟩) ↔ IsPoint (resp_mod ⟨i.val - 1, _⟩)) ∧
                 (IsGap (a_bwd ⟨i.val - 1, _⟩) ↔ IsGap (resp_mod ⟨i.val - 1, _⟩))
            rw [show (⟨i.val - 1, by omega⟩ : Fin n) = k from Fin.ext rfl, hmod_ne]
            exact hleft_i
        · -- i inner, i-1=n: a_bwd(n)/e_n — both are Sum.inl (point)
          have hi_eq : i.val - 1 = n := by omega
          have hab : (a_bwd ⟨i.val - 1, by omega⟩ : ExtendedCarrier N atomMap r) =
                     a_bwd ⟨n, by omega⟩ := by congr 1; exact Fin.ext hi_eq
          rw [hab, hp_n]
          constructor
          · exact ⟨fun _ => ⟨e_n_pt, rfl⟩, fun _ => ⟨p_n, rfl⟩⟩
          · constructor <;> intro ⟨g, hg⟩ <;> exact (Sum.inl_ne_inr hg).elim
      · -- formula_agreement (n+1): for all positions and formulas
        intro i A hA
        simp only [game_tuple]
        split_ifs with h0 hn1 hn2 h0' hlt
        · -- i=0: x'/x — from d-compatible big game
          exact (hform_fwd_x A hA).symm
        · -- i=n+2: extendPoint b_resp / extendPoint b_sp — from tau at position n+1
          have htau_n1 := hform_tau ⟨n + 1, by omega⟩ A hA
          simp only [game_tuple, show (n + 1 : Nat) ≠ 0 from by omega,
                     show (n + 1 : Nat) = n + 1 from rfl,
                     dite_false, dite_true] at htau_n1
          exact htau_n1
        · -- i=n+3: y'/y — from d-compatible big game
          exact (hform_fwd_y A hA).symm
        · -- i inner, i-1 < n: a_bwd(i-1) / resp_mod(i-1) — Phase 3C-EQ case split
          let k : Fin n := ⟨i.val - 1, by omega⟩
          rcases Decidable.em (a_init k = extendPoint p_n) with heq_k | hne_k
          · have hmod_eq : resp_mod k = e_n := hresp_mod_eq k heq_k
            have hab_pn : (a_bwd ⟨i.val - 1, by omega⟩ : ExtendedCarrier N atomMap r) =
                a_bwd ⟨n, by omega⟩ := by
              have : a_bwd ⟨i.val - 1, by omega⟩ = extendPoint p_n := by
                have : a_bwd ⟨i.val - 1, by omega⟩ = a_init k := by
                  simp only [a_init]; congr 1
                rw [this]; exact heq_k
              rw [this]; simp only [hp_n, extendPoint]
            have hrw : (resp_mod ⟨i.val - 1, h0'⟩ : ExtendedCarrier M atomMap r) = e_n := by
              rw [show (⟨i.val - 1, h0'⟩ : Fin n) = k from Fin.ext rfl, hmod_eq]
            rw [hab_pn, hrw]
            exact (hform_en_an A hA).symm
          · -- a_init(k) ≠ p_n: resp_mod(k) = resp_left(k), use tau_left
            have hmod_ne : resp_mod k = resp_left k := hresp_mod_ne k hne_k
            have hleft_i := hform_left ⟨1 + (i.val - 1), by omega⟩ A hA
            simp only [game_tuple, show 1 + (i.val - 1) ≠ 0 from by omega,
                       show ¬(1 + (i.val - 1) = n + 1) from by omega,
                       show ¬(1 + (i.val - 1) = n + 2) from by omega,
                       dite_false, show 1 + (i.val - 1) - 1 = i.val - 1 from by omega] at hleft_i
            show stavi_temporal_truth_mu N atomMap r (a_bwd ⟨i.val - 1, _⟩) A ↔
                 stavi_temporal_truth_mu M atomMap r (resp_mod ⟨i.val - 1, _⟩) A
            rw [show (⟨i.val - 1, by omega⟩ : Fin n) = k from Fin.ext rfl, hmod_ne]
            exact hleft_i
        · -- i inner, i-1=n: a_bwd(n)/e_n — from hform_en_an
          have hi_eq : i.val - 1 = n := by omega
          have hab : (a_bwd ⟨i.val - 1, by omega⟩ : ExtendedCarrier N atomMap r) =
                     a_bwd ⟨n, by omega⟩ := by congr 1; exact Fin.ext hi_eq
          rw [hab]
          exact (hform_en_an A hA).symm
  -- Step 4: Build merged response (uses resp_mod for Phase 3C-EQ)
  let a'_resp : Fin (n + 1) → ExtendedCarrier M atomMap r := fun i =>
    if h : i.val < n then resp_mod ⟨i.val, h⟩
    else e_n
  have ha'_resp_in : ∀ i, inClosedInterval x y (a'_resp i) := by
    intro i; simp only [a'_resp]
    split
    case isTrue h =>
      have := hresp_mod_in ⟨i.val, h⟩
      exact ⟨le_trans props.hxc this.1, this.2⟩
    case isFalse _ => exact he_n_in
  -- Step 5: Provide response with winning condition
  exact ⟨a'_resp, ha'_resp_in, fun b_sp hb_sp => he_n_props b_sp hb_sp⟩
  /-  OLD CASE II PROOF (used hd_eq_an, incompatible with d = infimum)
  have hd_eq_an : d = a_bwd ⟨n, by omega⟩ := props.hd_eq_an
  -- d is a point
  obtain ⟨p_d, hp_d⟩ := h_point
  -- So d = extendPoint p_d
  have hd_pt : d = extendPoint p_d := hd_eq_an ▸ hp_d
  -- ---------------------------------------------------------------
  -- Step 1: Build the init sub-sequence a_init : Fin n → ExtendedCarrier N
  -- ---------------------------------------------------------------
  let a_init : Fin n → ExtendedCarrier N atomMap r :=
    fun k => a_bwd ⟨k.val, by omega⟩
  have ha_init : ∀ k, inClosedInterval d y' (a_init k) := by
    intro k
    exact ⟨h_no_split ⟨k.val, by omega⟩, (ha_bwd ⟨k.val, by omega⟩).2⟩
  -- ---------------------------------------------------------------
  -- Step 2: Play τ with the init sub-sequence
  -- ---------------------------------------------------------------
  obtain ⟨resp_tau, hresp_tau_in, hwin_tau⟩ := props.tau a_init ha_init
  -- resp_tau : Fin n → ExtendedCarrier M atomMap r, all in [c, y]
  -- ---------------------------------------------------------------
  -- Step 3: Build the merged response a'_resp
  -- ---------------------------------------------------------------
  -- a'_resp(i) = resp_tau(i) for i < n
  -- a'_resp(n) = c
  let a'_resp : Fin (n + 1) → ExtendedCarrier M atomMap r := fun i =>
    if h : i.val < n then resp_tau ⟨i.val, h⟩
    else c
  have ha'_resp_in : ∀ i, inClosedInterval x y (a'_resp i) := by
    intro i; simp only [a'_resp]
    split
    case isTrue h =>
      have := hresp_tau_in ⟨i.val, h⟩
      exact ⟨le_trans props.hxc this.1, this.2⟩
    case isFalse _ =>
      exact props.hc_interval
  -- ---------------------------------------------------------------
  -- Step 4: Provide a'_resp and handle Round 2
  -- ---------------------------------------------------------------
  -- ---------------------------------------------------------------
  -- Pre-extract tau and sigma boundary data (needed for gap_point at j=n)
  -- ---------------------------------------------------------------
  obtain ⟨p_cy, hp_cy⟩ := props.h_pt_cy
  obtain ⟨b_resp_tau_aux, _, hcond_tau_aux⟩ := hwin_tau p_cy hp_cy
  obtain ⟨_, hgp_tau_aux, _⟩ := hcond_tau_aux
  -- Extract gap/point agreement at tau boundary (index 0 = d/c)
  have hgp_dc : (IsPoint d ↔ IsPoint c) ∧ (IsGap d ↔ IsGap c) := by
    have := hgp_tau_aux ⟨0, by omega⟩
    simp only [game_tuple, dite_true] at this; exact this
  -- Since d = extendPoint p_d, d is a point, so c is a point too
  have hc_point : IsPoint c := hgp_dc.1.mp ⟨p_d, hd_pt⟩
  have hc_not_gap : ¬IsGap c := by
    intro hgap_c
    have hgap_d : IsGap d := hgp_dc.2.mpr hgap_c
    obtain ⟨g', hg'⟩ := hgap_d
    -- d = Sum.inr g', but d = extendPoint p_d = Sum.inl p_d
    simp [hd_pt, extendPoint] at hg'
  -- Also pre-extract sigma data for x'/x boundary
  have hd_in_x'd : inClosedInterval x' d d := ⟨props.hx'd, le_refl d⟩
  obtain ⟨resp_sig_aux, _, hwin_sig_aux⟩ :=
    props.sigma (fun _ : Fin n => d) (fun _ => hd_in_x'd)
  obtain ⟨p_xc, hp_xc⟩ := props.h_pt_xc
  obtain ⟨_, _, hcond_sig_aux⟩ := hwin_sig_aux p_xc hp_xc
  obtain ⟨_, hgp_sig_aux, _⟩ := hcond_sig_aux
  refine ⟨a'_resp, ha'_resp_in, ?_⟩
  intro b_sp hb_sp
  by_cases hbc : extendPoint b_sp ≤ c
  · -- b_sp in [x, c]: delegate to σ's Round 2
    obtain ⟨resp_sig, _, hwin_sig⟩ :=
      props.sigma (fun _ : Fin n => d) (fun _ => hd_in_x'd)
    obtain ⟨b_resp_sig, hb_resp_sig_in, hcond_sig⟩ :=
      hwin_sig b_sp ⟨hb_sp.1, hbc⟩
    -- b_resp_sig is in [x',d] ⊂ [x',y']
    refine ⟨b_resp_sig, ⟨hb_resp_sig_in.1, le_trans hb_resp_sig_in.2 props.hdy'⟩, ?_⟩
    -- ---------------------------------------------------------------
    -- Winning condition transfer (b_sp ≤ c case)
    -- ---------------------------------------------------------------
    -- Re-extract tau's winning condition (with p_cy as Round 2 point)
    obtain ⟨_, _, hcond_tau⟩ := hwin_tau p_cy hp_cy
    obtain ⟨hord_tau, hgp_tau, hform_tau⟩ := hcond_tau
    obtain ⟨hord_sig, hgp_sig, hform_sig⟩ := hcond_sig
    -- Helper: tau maps index 0→d/c, 1+k→a_init(k)/resp_tau(k),
    --         n+1→p_cy/b_tau_resp(?), n+2→y'/y
    -- sigma maps index 0→x'/x, 1+k→d/resp_sig(k),
    --         n+1→b_sp/b_resp_sig, n+2→d/c
    -- Extract boundary orderings from tau
    have tau_d_y : (d < y' ↔ c < y) ∧ (d = y' ↔ c = y) := by
      have h := hord_tau ⟨0, by omega⟩ ⟨n + 2, by omega⟩
      simp only [game_tuple_zero_eq, game_tuple_y_eq] at h; exact h
    have tau_d_sel : ∀ (k : Fin n),
        (d < a_init k ↔ c < resp_tau k) ∧ (d = a_init k ↔ c = resp_tau k) := by
      intro k; have h := hord_tau ⟨0, by omega⟩ ⟨1 + k.val, by omega⟩
      simp only [game_tuple_zero_eq, game_tuple_sel_eq] at h; exact h
    have tau_sel_y : ∀ (k : Fin n),
        (a_init k < y' ↔ resp_tau k < y) ∧ (a_init k = y' ↔ resp_tau k = y) := by
      intro k; have h := hord_tau ⟨1 + k.val, by omega⟩ ⟨n + 2, by omega⟩
      simp only [game_tuple_sel_eq, game_tuple_y_eq] at h; exact h
    have tau_sel_sel : ∀ (k k' : Fin n),
        (a_init k < a_init k' ↔ resp_tau k < resp_tau k') ∧
        (a_init k = a_init k' ↔ resp_tau k = resp_tau k') := by
      intro k k'; have h := hord_tau ⟨1 + k.val, by omega⟩ ⟨1 + k'.val, by omega⟩
      simp only [game_tuple_sel_eq] at h; exact h
    -- Extract boundary orderings from sigma
    have sig_x_d : (x' < d ↔ x < c) ∧ (x' = d ↔ x = c) := by
      have h := hord_sig ⟨0, by omega⟩ ⟨n + 2, by omega⟩
      simp only [game_tuple_zero_eq, game_tuple_y_eq] at h; exact h
    have sig_x_b : (x' < extendPoint b_resp_sig ↔ x < extendPoint b_sp) ∧
                   (x' = extendPoint b_resp_sig ↔ x = extendPoint b_sp) := by
      have h := hord_sig ⟨0, by omega⟩ ⟨n + 1, by omega⟩
      simp only [game_tuple_zero_eq, game_tuple_b_eq] at h; exact h
    have sig_b_d : (extendPoint b_resp_sig < d ↔ extendPoint b_sp < c) ∧
                   (extendPoint b_resp_sig = d ↔ extendPoint b_sp = c) := by
      have h := hord_sig ⟨n + 1, by omega⟩ ⟨n + 2, by omega⟩
      simp only [game_tuple_b_eq, game_tuple_y_eq] at h; exact h
    -- Interval bounds
    have hd_le_init : ∀ (k : Fin n), d ≤ a_init k := fun k => (ha_init k).1
    have hc_le_tau : ∀ (k : Fin n), c ≤ resp_tau k := fun k => (hresp_tau_in k).1
    have hresp_tau_le_y : ∀ (k : Fin n), resp_tau k ≤ y := fun k => (hresp_tau_in k).2
    -- gap_point at selections
    have hgp_sel : ∀ (j : Fin (n + 1)),
        (IsPoint (a_bwd j) ↔ IsPoint (a'_resp j)) ∧
        (IsGap (a_bwd j) ↔ IsGap (a'_resp j)) := by
      intro j
      by_cases hjn : j.val < n
      · -- j < n: from tau at selection index 1 + j.val
        simp only [a'_resp, hjn, dite_true]
        have htau_gp := hgp_tau ⟨1 + j.val, by omega⟩
        simp only [game_tuple,
          show (1 + j.val : Nat) ≠ 0 from by omega,
          show ¬((1 + j.val : Nat) = n + 1) from by omega,
          show ¬((1 + j.val : Nat) = n + 2) from by omega,
          dite_false, show 1 + j.val - 1 = j.val from by omega] at htau_gp
        -- N-side: a_init ⟨j.val, hjn⟩ = a_bwd j
        have hN_eq : a_init ⟨j.val, hjn⟩ = a_bwd j := by
          simp [a_init]
        rw [hN_eq] at htau_gp; exact htau_gp
      · -- j = n: d/c, gap/point from tau boundary
        simp only [a'_resp, show ¬(j.val < n) from hjn, dite_false]
        rw [show a_bwd j = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
        rw [← hd_eq_an, hd_pt]
        constructor
        · exact ⟨fun _ => hc_point, fun _ => ⟨p_d, rfl⟩⟩
        · exact ⟨fun ⟨g, hg⟩ => absurd hg.symm Sum.inr_ne_inl,
                 fun h => absurd h hc_not_gap⟩
    -- formula at selections
    have hform_sel : ∀ (j : Fin (n + 1)) (A : StaviFormula), stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r (a_bwd j) A ↔
         stavi_temporal_truth_mu M atomMap r (a'_resp j) A) := by
      intro j A hA
      by_cases hjn : j.val < n
      · simp only [a'_resp, hjn, dite_true]
        have htau_form := hform_tau ⟨1 + j.val, by omega⟩ A hA
        simp only [game_tuple,
          show (1 + j.val : Nat) ≠ 0 from by omega,
          show ¬((1 + j.val : Nat) = n + 1) from by omega,
          show ¬((1 + j.val : Nat) = n + 2) from by omega,
          dite_false, show 1 + j.val - 1 = j.val from by omega] at htau_form
        have hN_eq : a_init ⟨j.val, hjn⟩ = a_bwd j := by
          simp [a_init]
        rw [hN_eq] at htau_form; exact htau_form
      · -- j = n: formula agreement between d and c from tau boundary
        simp only [a'_resp, show ¬(j.val < n) from hjn, dite_false]
        rw [show a_bwd j = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
        rw [← hd_eq_an]
        -- From tau: index 0 maps d/c
        have htau_form_d := hform_tau ⟨0, by omega⟩ A hA
        simp only [game_tuple, dite_true] at htau_form_d
        exact htau_form_d
    -- Boundary gap/point and formula
    have hgp_x : (IsPoint x' ↔ IsPoint x) ∧ (IsGap x' ↔ IsGap x) := by
      -- From sigma at index 0
      have := hgp_sig ⟨0, by omega⟩
      simp only [game_tuple, show (0 : Nat) ≠ n + 1 from by omega,
        show (0 : Nat) ≠ n + 2 from by omega, dite_true] at this
      exact this
    have hgp_y : (IsPoint y' ↔ IsPoint y) ∧ (IsGap y' ↔ IsGap y) := by
      have := hgp_tau ⟨n + 2, by omega⟩
      simp only [game_tuple, show (n + 2 : Nat) ≠ 0 from by omega,
        show ¬((n + 2 : Nat) = n + 1) from by omega,
        show (n + 2 : Nat) = n + 2 from rfl, dite_true, dite_false] at this
      exact this
    have hgp_b : (@IsPoint sig N atomMap r (extendPoint b_resp_sig) ↔
                  @IsPoint sig M atomMap r (extendPoint b_sp)) ∧
                 (@IsGap sig N atomMap r (extendPoint b_resp_sig) ↔
                  @IsGap sig M atomMap r (extendPoint b_sp)) := by
      constructor
      · exact ⟨fun _ => ⟨b_sp, rfl⟩, fun _ => ⟨b_resp_sig, rfl⟩⟩
      · exact ⟨fun ⟨g, hg⟩ => absurd hg.symm Sum.inr_ne_inl,
               fun ⟨g, hg⟩ => absurd hg.symm Sum.inr_ne_inl⟩
    have hform_x : ∀ A, stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r x' A ↔ stavi_temporal_truth_mu M atomMap r x A) := by
      intro A hA
      have := hform_sig ⟨0, by omega⟩ A hA
      simp only [game_tuple, show (0 : Nat) ≠ n + 1 from by omega,
        show (0 : Nat) ≠ n + 2 from by omega, dite_true] at this
      exact this
    have hform_y : ∀ A, stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r y' A ↔ stavi_temporal_truth_mu M atomMap r y A) := by
      intro A hA
      have := hform_tau ⟨n + 2, by omega⟩ A hA
      simp only [game_tuple, show (n + 2 : Nat) ≠ 0 from by omega,
        show ¬((n + 2 : Nat) = n + 1) from by omega,
        show (n + 2 : Nat) = n + 2 from rfl, dite_true, dite_false] at this
      exact this
    have hform_b : ∀ A, stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r (extendPoint b_resp_sig) A ↔
         stavi_temporal_truth_mu M atomMap r (extendPoint b_sp) A) := by
      intro A hA
      have := hform_sig ⟨n + 1, by omega⟩ A hA
      simp only [game_tuple, show (n + 1 : Nat) ≠ 0 from by omega,
        show (n + 1 : Nat) = n + 1 from rfl, dite_true] at this
      exact this
    -- ----- Assemble the winning condition -----
    refine ⟨?_, ?_, ?_⟩
    · -- same_order_type (n+1)
      -- Full game has n+4 indices: 0→x'/x, 1..n→a_bwd(0..n-1)/a'_resp(0..n-1),
      --   n+1→a_bwd(n)/a'_resp(n)=d/c, n+2→b_resp_sig/b_sp, n+3→y'/y
      -- tau maps: 0→d/c, 1+k→a_init(k)/resp_tau(k), n+1→p_cy/?, n+2→y'/y
      -- sigma maps: 0→x'/x, 1+k→d/resp_sig(k), n+1→b_sp/b_resp_sig, n+2→d/c
      -- For cross-boundary ordering, use pivot through d/c
      intro i j; simp only [game_tuple]; split_ifs with
        hi0 hj0 _ _ _ hjb _ hjy _ hjd _ _ hib hj0 _ _ _ hjb _ hjy _ hjd _ _
        hiy hj0 _ _ _ hjb _ hjy _ hjd _ _ _ hid hj0 _ _ _ hjb _ hjy _ hjd _ _
      -- Goal 1: x vs x
      · exact ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
               ⟨fun _ => rfl, fun _ => rfl⟩⟩
      -- Goal 2: x vs b
      · exact sig_x_b
      -- Goal 3: x vs y
      · exact pivot_chain_order props.hx'd props.hdy' props.hxc props.hcy
          sig_x_d.1 sig_x_d.2 tau_d_y.1 tau_d_y.2
      -- Goal 4: x vs sel(j)
      · set j' : Fin (n + 1) := ⟨j.val - 1, by omega⟩
        by_cases hjn : j'.val < n
        · -- j' < n: tau selection
          simp only [a'_resp, hjn, dite_true]
          have : a_bwd j' = a_init ⟨j'.val, hjn⟩ := by
            simp [a_init]
          rw [this]
          exact pivot_chain_order props.hx'd (hd_le_init ⟨j'.val, hjn⟩)
            props.hxc (hc_le_tau ⟨j'.val, hjn⟩) sig_x_d.1 sig_x_d.2
            (tau_d_sel ⟨j'.val, hjn⟩).1 (tau_d_sel ⟨j'.val, hjn⟩).2
        · -- j' = n: a_bwd(n) = d, a'_resp(n) = c
          simp only [a'_resp, show ¬(j'.val < n) from hjn, dite_false]
          rw [show a_bwd j' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
          rw [← hd_eq_an]
          exact sig_x_d
      -- Goal 5: b vs x
      · have h := hord_sig ⟨n + 1, by omega⟩ ⟨0, by omega⟩
        simp only [game_tuple_b_eq, game_tuple_zero_eq] at h; exact h
      -- Goal 6: b vs b
      · exact ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
               ⟨fun _ => rfl, fun _ => rfl⟩⟩
      -- Goal 7: b vs y
      · exact pivot_chain_order hb_resp_sig_in.2 props.hdy' hbc props.hcy
          sig_b_d.1 sig_b_d.2 tau_d_y.1 tau_d_y.2
      -- Goal 8: b vs sel(j)
      · set j' : Fin (n + 1) := ⟨j.val - 1, by omega⟩
        by_cases hjn : j'.val < n
        · simp only [a'_resp, hjn, dite_true]
          have : a_bwd j' = a_init ⟨j'.val, hjn⟩ := by
            simp [a_init]
          rw [this]
          exact pivot_chain_order hb_resp_sig_in.2 (hd_le_init ⟨j'.val, hjn⟩)
            hbc (hc_le_tau ⟨j'.val, hjn⟩)
            sig_b_d.1 sig_b_d.2 (tau_d_sel ⟨j'.val, hjn⟩).1 (tau_d_sel ⟨j'.val, hjn⟩).2
        · simp only [a'_resp, show ¬(j'.val < n) from hjn, dite_false]
          rw [show a_bwd j' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
          rw [← hd_eq_an]
          exact sig_b_d
      -- Goal 9: y vs x
      · exact pivot_chain_order_rev props.hdy' props.hx'd props.hcy props.hxc
          tau_d_y.1 tau_d_y.2 sig_x_d.1 sig_x_d.2
      -- Goal 10: y vs b
      · exact pivot_chain_order_rev props.hdy' hb_resp_sig_in.2 props.hcy hbc
          tau_d_y.1 tau_d_y.2 sig_b_d.1 sig_b_d.2
      -- Goal 11: y vs y
      · exact ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
               ⟨fun _ => rfl, fun _ => rfl⟩⟩
      -- Goal 12: y vs sel(j) — y' ≥ sel ≥ d and y ≥ resp ≥ c
      · set j' : Fin (n + 1) := ⟨j.val - 1, by omega⟩
        by_cases hjn : j'.val < n
        · simp only [a'_resp, hjn, dite_true]
          have : a_bwd j' = a_init ⟨j'.val, hjn⟩ := by
            simp [a_init]
          rw [this]
          have htsy := tau_sel_y ⟨j'.val, hjn⟩
          exact ⟨⟨fun h => absurd h (not_lt.mpr (ha_init ⟨j'.val, hjn⟩).2),
                  fun h => absurd h (not_lt.mpr (hresp_tau_in ⟨j'.val, hjn⟩).2)⟩,
                 ⟨fun h => (htsy.2.mp h.symm).symm,
                  fun h => (htsy.2.mpr h.symm).symm⟩⟩
        · -- j' = n: y' vs d / y vs c
          simp only [a'_resp, show ¬(j'.val < n) from hjn, dite_false]
          rw [show a_bwd j' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
          rw [← hd_eq_an]
          exact ⟨⟨fun h => absurd h (not_lt.mpr props.hdy'),
                  fun h => absurd h (not_lt.mpr props.hcy)⟩,
                 ⟨fun h => (tau_d_y.2.mp h.symm).symm,
                  fun h => (tau_d_y.2.mpr h.symm).symm⟩⟩
      -- Goal 13: sel(i) vs x
      · set i' : Fin (n + 1) := ⟨i.val - 1, by omega⟩
        by_cases hin : i'.val < n
        · simp only [a'_resp, hin, dite_true]
          have : a_bwd i' = a_init ⟨i'.val, hin⟩ := by
            simp [a_init]
          rw [this]
          exact pivot_chain_order_rev (hd_le_init ⟨i'.val, hin⟩) props.hx'd
            (hc_le_tau ⟨i'.val, hin⟩) props.hxc
            (tau_d_sel ⟨i'.val, hin⟩).1 (tau_d_sel ⟨i'.val, hin⟩).2
            sig_x_d.1 sig_x_d.2
        · simp only [a'_resp, show ¬(i'.val < n) from hin, dite_false]
          rw [show a_bwd i' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
          rw [← hd_eq_an]
          have h := hord_sig ⟨n + 2, by omega⟩ ⟨0, by omega⟩
          simp only [game_tuple_y_eq, game_tuple_zero_eq] at h; exact h
      -- Goal 14: sel(i) vs b
      · set i' : Fin (n + 1) := ⟨i.val - 1, by omega⟩
        by_cases hin : i'.val < n
        · simp only [a'_resp, hin, dite_true]
          have : a_bwd i' = a_init ⟨i'.val, hin⟩ := by
            simp [a_init]
          rw [this]
          exact pivot_chain_order_rev (hd_le_init ⟨i'.val, hin⟩) hb_resp_sig_in.2
            (hc_le_tau ⟨i'.val, hin⟩) hbc
            (tau_d_sel ⟨i'.val, hin⟩).1 (tau_d_sel ⟨i'.val, hin⟩).2
            sig_b_d.1 sig_b_d.2
        · simp only [a'_resp, show ¬(i'.val < n) from hin, dite_false]
          rw [show a_bwd i' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
          rw [← hd_eq_an]
          have h := hord_sig ⟨n + 2, by omega⟩ ⟨n + 1, by omega⟩
          simp only [game_tuple_y_eq, game_tuple_b_eq] at h; exact h
      -- Goal 15: sel(i) vs y
      · set i' : Fin (n + 1) := ⟨i.val - 1, by omega⟩
        by_cases hin : i'.val < n
        · simp only [a'_resp, hin, dite_true]
          have : a_bwd i' = a_init ⟨i'.val, hin⟩ := by
            simp [a_init]
          rw [this]; exact tau_sel_y ⟨i'.val, hin⟩
        · simp only [a'_resp, show ¬(i'.val < n) from hin, dite_false]
          rw [show a_bwd i' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
          rw [← hd_eq_an]; exact tau_d_y
      -- Goal 16: sel(i) vs sel(j)
      · set i' : Fin (n + 1) := ⟨i.val - 1, by omega⟩
        set j' : Fin (n + 1) := ⟨j.val - 1, by omega⟩
        by_cases hin : i'.val < n
        · simp only [a'_resp, hin, dite_true]
          have hi_eq : a_bwd i' = a_init ⟨i'.val, hin⟩ := by
            simp [a_init]
          rw [hi_eq]
          by_cases hjn : j'.val < n
          · simp only [a'_resp, hjn, dite_true]
            have hj_eq : a_bwd j' = a_init ⟨j'.val, hjn⟩ := by
              simp [a_init]
            rw [hj_eq]; exact tau_sel_sel ⟨i'.val, hin⟩ ⟨j'.val, hjn⟩
          · -- j' = n: sel(i') vs d / resp_tau(i') vs c
            simp only [a'_resp, show ¬(j'.val < n) from hjn, dite_false]
            rw [show a_bwd j' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
            rw [← hd_eq_an]
            -- a_init(i') ≥ d and resp_tau(i') ≥ c, so < is impossible
            -- = follows from tau_d_sel reversed
            have hds := tau_d_sel ⟨i'.val, hin⟩
            exact ⟨⟨fun h => absurd h (not_lt.mpr (hd_le_init ⟨i'.val, hin⟩)),
                    fun h => absurd h (not_lt.mpr (hc_le_tau ⟨i'.val, hin⟩))⟩,
                   ⟨fun h => (hds.2.mp h.symm).symm,
                    fun h => (hds.2.mpr h.symm).symm⟩⟩
        · -- i' = n: d vs ... / c vs ...
          simp only [a'_resp, show ¬(i'.val < n) from hin, dite_false]
          rw [show a_bwd i' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
          rw [← hd_eq_an]
          by_cases hjn : j'.val < n
          · simp only [a'_resp, hjn, dite_true]
            have hj_eq : a_bwd j' = a_init ⟨j'.val, hjn⟩ := by
              simp [a_init]
            rw [hj_eq]; exact tau_d_sel ⟨j'.val, hjn⟩
          · -- i' = n, j' = n: d vs d / c vs c
            simp only [a'_resp, show ¬(j'.val < n) from hjn, dite_false]
            rw [show a_bwd j' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
            rw [← hd_eq_an]
            simp
    · -- gap_point_agreement (n+1)
      exact gap_point_agreement_of_cases hgp_x hgp_b hgp_y hgp_sel
    · -- formula_agreement (n+1)
      exact formula_agreement_of_cases hform_x hform_b hform_y hform_sel
  · -- b_sp in (c, y]: delegate to τ's Round 2
    push_neg at hbc
    obtain ⟨b_resp_tau, hb_resp_tau_in, hcond_tau⟩ := hwin_tau b_sp ⟨le_of_lt hbc, hb_sp.2⟩
    refine ⟨b_resp_tau, ⟨le_trans props.hx'd hb_resp_tau_in.1, hb_resp_tau_in.2⟩, ?_⟩
    -- ---------------------------------------------------------------
    -- Winning condition transfer (b_sp > c case)
    -- ---------------------------------------------------------------
    obtain ⟨hord_tau, hgp_tau, hform_tau⟩ := hcond_tau
    -- Also get sigma's data for x'/x boundary
    have hd_in_x'd : inClosedInterval x' d d := ⟨props.hx'd, le_refl d⟩
    obtain ⟨resp_sig, _, hwin_sig⟩ :=
      props.sigma (fun _ : Fin n => d) (fun _ => hd_in_x'd)
    obtain ⟨p_xc, hp_xc⟩ := props.h_pt_xc
    obtain ⟨_, _, hcond_sig⟩ := hwin_sig p_xc hp_xc
    obtain ⟨hord_sig, hgp_sig, hform_sig⟩ := hcond_sig
    -- Extract orderings from tau
    have tau_d_y : (d < y' ↔ c < y) ∧ (d = y' ↔ c = y) := by
      have h := hord_tau ⟨0, by omega⟩ ⟨n + 2, by omega⟩
      simp only [game_tuple_zero_eq, game_tuple_y_eq] at h; exact h
    have tau_d_sel : ∀ (k : Fin n),
        (d < a_init k ↔ c < resp_tau k) ∧ (d = a_init k ↔ c = resp_tau k) := by
      intro k; have h := hord_tau ⟨0, by omega⟩ ⟨1 + k.val, by omega⟩
      simp only [game_tuple_zero_eq, game_tuple_sel_eq] at h; exact h
    have tau_sel_y : ∀ (k : Fin n),
        (a_init k < y' ↔ resp_tau k < y) ∧ (a_init k = y' ↔ resp_tau k = y) := by
      intro k; have h := hord_tau ⟨1 + k.val, by omega⟩ ⟨n + 2, by omega⟩
      simp only [game_tuple_sel_eq, game_tuple_y_eq] at h; exact h
    have tau_sel_sel : ∀ (k k' : Fin n),
        (a_init k < a_init k' ↔ resp_tau k < resp_tau k') ∧
        (a_init k = a_init k' ↔ resp_tau k = resp_tau k') := by
      intro k k'; have h := hord_tau ⟨1 + k.val, by omega⟩ ⟨1 + k'.val, by omega⟩
      simp only [game_tuple_sel_eq] at h; exact h
    have tau_d_b : (d < extendPoint b_resp_tau ↔ c < extendPoint b_sp) ∧
                   (d = extendPoint b_resp_tau ↔ c = extendPoint b_sp) := by
      have h := hord_tau ⟨0, by omega⟩ ⟨n + 1, by omega⟩
      simp only [game_tuple_zero_eq, game_tuple_b_eq] at h; exact h
    have tau_b_y : (extendPoint b_resp_tau < y' ↔ extendPoint b_sp < y) ∧
                   (extendPoint b_resp_tau = y' ↔ extendPoint b_sp = y) := by
      have h := hord_tau ⟨n + 1, by omega⟩ ⟨n + 2, by omega⟩
      simp only [game_tuple_b_eq, game_tuple_y_eq] at h; exact h
    have tau_b_sel : ∀ (k : Fin n),
        (extendPoint b_resp_tau < a_init k ↔ extendPoint b_sp < resp_tau k) ∧
        (extendPoint b_resp_tau = a_init k ↔ extendPoint b_sp = resp_tau k) := by
      intro k; have h := hord_tau ⟨n + 1, by omega⟩ ⟨1 + k.val, by omega⟩
      simp only [game_tuple_b_eq, game_tuple_sel_eq] at h; exact h
    have tau_sel_b : ∀ (k : Fin n),
        (a_init k < extendPoint b_resp_tau ↔ resp_tau k < extendPoint b_sp) ∧
        (a_init k = extendPoint b_resp_tau ↔ resp_tau k = extendPoint b_sp) := by
      intro k; have h := hord_tau ⟨1 + k.val, by omega⟩ ⟨n + 1, by omega⟩
      simp only [game_tuple_sel_eq, game_tuple_b_eq] at h; exact h
    -- Extract sigma orderings for x boundary
    have sig_x_d : (x' < d ↔ x < c) ∧ (x' = d ↔ x = c) := by
      have h := hord_sig ⟨0, by omega⟩ ⟨n + 2, by omega⟩
      simp only [game_tuple_zero_eq, game_tuple_y_eq] at h; exact h
    -- Interval bounds
    have hd_le_init : ∀ (k : Fin n), d ≤ a_init k := fun k => (ha_init k).1
    have hc_le_tau : ∀ (k : Fin n), c ≤ resp_tau k := fun k => (hresp_tau_in k).1
    -- gap_point at selections
    have hgp_sel : ∀ (j : Fin (n + 1)),
        (IsPoint (a_bwd j) ↔ IsPoint (a'_resp j)) ∧
        (IsGap (a_bwd j) ↔ IsGap (a'_resp j)) := by
      intro j
      by_cases hjn : j.val < n
      · simp only [a'_resp, hjn, dite_true]
        have htau_gp := hgp_tau ⟨1 + j.val, by omega⟩
        simp only [game_tuple,
          show (1 + j.val : Nat) ≠ 0 from by omega,
          show ¬((1 + j.val : Nat) = n + 1) from by omega,
          show ¬((1 + j.val : Nat) = n + 2) from by omega,
          dite_false, show 1 + j.val - 1 = j.val from by omega] at htau_gp
        have hN_eq : a_init ⟨j.val, hjn⟩ = a_bwd j := by
          simp [a_init]
        rw [hN_eq] at htau_gp; exact htau_gp
      · simp only [a'_resp, show ¬(j.val < n) from hjn, dite_false]
        rw [show a_bwd j = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
        rw [← hd_eq_an, hd_pt]
        constructor
        · exact ⟨fun _ => hc_point, fun _ => ⟨p_d, rfl⟩⟩
        · exact ⟨fun ⟨g, hg⟩ => absurd hg.symm Sum.inr_ne_inl,
                 fun h => absurd h hc_not_gap⟩
    have hform_sel : ∀ (j : Fin (n + 1)) (A : StaviFormula), stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r (a_bwd j) A ↔
         stavi_temporal_truth_mu M atomMap r (a'_resp j) A) := by
      intro j A hA
      by_cases hjn : j.val < n
      · simp only [a'_resp, hjn, dite_true]
        have htau_form := hform_tau ⟨1 + j.val, by omega⟩ A hA
        simp only [game_tuple,
          show (1 + j.val : Nat) ≠ 0 from by omega,
          show ¬((1 + j.val : Nat) = n + 1) from by omega,
          show ¬((1 + j.val : Nat) = n + 2) from by omega,
          dite_false, show 1 + j.val - 1 = j.val from by omega] at htau_form
        have hN_eq : a_init ⟨j.val, hjn⟩ = a_bwd j := by
          simp [a_init]
        rw [hN_eq] at htau_form; exact htau_form
      · simp only [a'_resp, show ¬(j.val < n) from hjn, dite_false]
        rw [show a_bwd j = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
        rw [← hd_eq_an]
        have htau_form_d := hform_tau ⟨0, by omega⟩ A hA
        simp only [game_tuple, dite_true] at htau_form_d
        exact htau_form_d
    -- Boundary data
    have hgp_x : (IsPoint x' ↔ IsPoint x) ∧ (IsGap x' ↔ IsGap x) := by
      have := hgp_sig ⟨0, by omega⟩
      simp only [game_tuple, show (0 : Nat) ≠ n + 1 from by omega,
        show (0 : Nat) ≠ n + 2 from by omega, dite_true] at this
      exact this
    have hgp_y : (IsPoint y' ↔ IsPoint y) ∧ (IsGap y' ↔ IsGap y) := by
      have := hgp_tau ⟨n + 2, by omega⟩
      simp only [game_tuple, show (n + 2 : Nat) ≠ 0 from by omega,
        show ¬((n + 2 : Nat) = n + 1) from by omega,
        show (n + 2 : Nat) = n + 2 from rfl, dite_true, dite_false] at this
      exact this
    have hgp_b : (@IsPoint sig N atomMap r (extendPoint b_resp_tau) ↔
                  @IsPoint sig M atomMap r (extendPoint b_sp)) ∧
                 (@IsGap sig N atomMap r (extendPoint b_resp_tau) ↔
                  @IsGap sig M atomMap r (extendPoint b_sp)) := by
      constructor
      · exact ⟨fun _ => ⟨b_sp, rfl⟩, fun _ => ⟨b_resp_tau, rfl⟩⟩
      · exact ⟨fun ⟨g, hg⟩ => absurd hg.symm Sum.inr_ne_inl,
               fun ⟨g, hg⟩ => absurd hg.symm Sum.inr_ne_inl⟩
    have hform_x : ∀ A, stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r x' A ↔ stavi_temporal_truth_mu M atomMap r x A) := by
      intro A hA
      have := hform_sig ⟨0, by omega⟩ A hA
      simp only [game_tuple, show (0 : Nat) ≠ n + 1 from by omega,
        show (0 : Nat) ≠ n + 2 from by omega, dite_true] at this
      exact this
    have hform_y : ∀ A, stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r y' A ↔ stavi_temporal_truth_mu M atomMap r y A) := by
      intro A hA
      have := hform_tau ⟨n + 2, by omega⟩ A hA
      simp only [game_tuple, show (n + 2 : Nat) ≠ 0 from by omega,
        show ¬((n + 2 : Nat) = n + 1) from by omega,
        show (n + 2 : Nat) = n + 2 from rfl, dite_true, dite_false] at this
      exact this
    have hform_b : ∀ A, stavi_depth A ≤ r →
        (stavi_temporal_truth_mu N atomMap r (extendPoint b_resp_tau) A ↔
         stavi_temporal_truth_mu M atomMap r (extendPoint b_sp) A) := by
      intro A hA
      have := hform_tau ⟨n + 1, by omega⟩ A hA
      simp only [game_tuple, show (n + 1 : Nat) ≠ 0 from by omega,
        show (n + 1 : Nat) = n + 1 from rfl, dite_true] at this
      exact this
    -- ----- Assemble the winning condition (right case) -----
    refine ⟨?_, ?_, ?_⟩
    · -- same_order_type (n+1)
      intro i j; simp only [game_tuple]; split_ifs with
        hi0 hj0 _ _ _ hjb _ hjy _ hjd _ _ hib hj0 _ _ _ hjb _ hjy _ hjd _ _
        hiy hj0 _ _ _ hjb _ hjy _ hjd _ _ _ hid hj0 _ _ _ hjb _ hjy _ hjd _ _
      -- Goal 1: x vs x
      · exact ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
               ⟨fun _ => rfl, fun _ => rfl⟩⟩
      -- Goal 2: x vs b
      · exact pivot_chain_order props.hx'd hb_resp_tau_in.1 props.hxc (le_of_lt hbc)
          sig_x_d.1 sig_x_d.2 tau_d_b.1 tau_d_b.2
      -- Goal 3: x vs y
      · exact pivot_chain_order props.hx'd props.hdy' props.hxc props.hcy
          sig_x_d.1 sig_x_d.2 tau_d_y.1 tau_d_y.2
      -- Goal 4: x vs sel(j)
      · set j' : Fin (n + 1) := ⟨j.val - 1, by omega⟩
        by_cases hjn : j'.val < n
        · simp only [a'_resp, hjn, dite_true]
          have : a_bwd j' = a_init ⟨j'.val, hjn⟩ := by
            simp [a_init]
          rw [this]
          exact pivot_chain_order props.hx'd (hd_le_init ⟨j'.val, hjn⟩)
            props.hxc (hc_le_tau ⟨j'.val, hjn⟩) sig_x_d.1 sig_x_d.2
            (tau_d_sel ⟨j'.val, hjn⟩).1 (tau_d_sel ⟨j'.val, hjn⟩).2
        · simp only [a'_resp, show ¬(j'.val < n) from hjn, dite_false]
          rw [show a_bwd j' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
          rw [← hd_eq_an]
          exact sig_x_d
      -- Goal 5: b vs x
      · exact pivot_chain_order_rev hb_resp_tau_in.1 props.hx'd (le_of_lt hbc) props.hxc
          tau_d_b.1 tau_d_b.2 sig_x_d.1 sig_x_d.2
      -- Goal 6: b vs b
      · exact ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
               ⟨fun _ => rfl, fun _ => rfl⟩⟩
      -- Goal 7: b vs y
      · exact tau_b_y
      -- Goal 8: b vs sel(j)
      · set j' : Fin (n + 1) := ⟨j.val - 1, by omega⟩
        by_cases hjn : j'.val < n
        · simp only [a'_resp, hjn, dite_true]
          have : a_bwd j' = a_init ⟨j'.val, hjn⟩ := by
            simp [a_init]
          rw [this]; exact tau_b_sel ⟨j'.val, hjn⟩
        · -- j' = n: b vs d / b_sp vs c — b ≥ d and b_sp > c
          simp only [a'_resp, show ¬(j'.val < n) from hjn, dite_false]
          rw [show a_bwd j' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
          rw [← hd_eq_an]
          exact ⟨⟨fun h => absurd h (not_lt.mpr hb_resp_tau_in.1),
                  fun h => absurd h (not_lt.mpr (le_of_lt hbc))⟩,
                 ⟨fun h => (tau_d_b.2.mp h.symm).symm,
                  fun h => (tau_d_b.2.mpr h.symm).symm⟩⟩
      -- Goal 9: y vs x
      · exact pivot_chain_order_rev props.hdy' props.hx'd props.hcy props.hxc
          tau_d_y.1 tau_d_y.2 sig_x_d.1 sig_x_d.2
      -- Goal 10: y vs b
      · have h := hord_tau ⟨n + 2, by omega⟩ ⟨n + 1, by omega⟩
        simp only [game_tuple_y_eq, game_tuple_b_eq] at h; exact h
      -- Goal 11: y vs y
      · exact ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
               ⟨fun _ => rfl, fun _ => rfl⟩⟩
      -- Goal 12: y vs sel(j)
      · set j' : Fin (n + 1) := ⟨j.val - 1, by omega⟩
        by_cases hjn : j'.val < n
        · simp only [a'_resp, hjn, dite_true]
          have : a_bwd j' = a_init ⟨j'.val, hjn⟩ := by
            simp [a_init]
          rw [this]
          have := tau_sel_y ⟨j'.val, hjn⟩
          exact ⟨⟨fun h => absurd h (not_lt.mpr (ha_init ⟨j'.val, hjn⟩).2),
                  fun h => absurd h (not_lt.mpr (hresp_tau_in ⟨j'.val, hjn⟩).2)⟩,
                 ⟨fun h => (this.2.mp h.symm).symm,
                  fun h => (this.2.mpr h.symm).symm⟩⟩
        · simp only [a'_resp, show ¬(j'.val < n) from hjn, dite_false]
          rw [show a_bwd j' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
          rw [← hd_eq_an]
          exact ⟨⟨fun h => absurd h (not_lt.mpr props.hdy'),
                  fun h => absurd h (not_lt.mpr props.hcy)⟩,
                 ⟨fun h => (tau_d_y.2.mp h.symm).symm,
                  fun h => (tau_d_y.2.mpr h.symm).symm⟩⟩
      -- Goal 13: sel(i) vs x
      · set i' : Fin (n + 1) := ⟨i.val - 1, by omega⟩
        by_cases hin : i'.val < n
        · simp only [a'_resp, hin, dite_true]
          have : a_bwd i' = a_init ⟨i'.val, hin⟩ := by
            simp [a_init]
          rw [this]
          exact pivot_chain_order_rev (hd_le_init ⟨i'.val, hin⟩) props.hx'd
            (hc_le_tau ⟨i'.val, hin⟩) props.hxc
            (tau_d_sel ⟨i'.val, hin⟩).1 (tau_d_sel ⟨i'.val, hin⟩).2
            sig_x_d.1 sig_x_d.2
        · simp only [a'_resp, show ¬(i'.val < n) from hin, dite_false]
          rw [show a_bwd i' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
          rw [← hd_eq_an]
          have h := hord_sig ⟨n + 2, by omega⟩ ⟨0, by omega⟩
          simp only [game_tuple_y_eq, game_tuple_zero_eq] at h; exact h
      -- Goal 14: sel(i) vs b
      · set i' : Fin (n + 1) := ⟨i.val - 1, by omega⟩
        by_cases hin : i'.val < n
        · simp only [a'_resp, hin, dite_true]
          have : a_bwd i' = a_init ⟨i'.val, hin⟩ := by
            simp [a_init]
          rw [this]; exact tau_sel_b ⟨i'.val, hin⟩
        · simp only [a'_resp, show ¬(i'.val < n) from hin, dite_false]
          rw [show a_bwd i' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
          rw [← hd_eq_an]
          have h := hord_tau ⟨0, by omega⟩ ⟨n + 1, by omega⟩
          simp only [game_tuple_zero_eq, game_tuple_b_eq] at h; exact h
      -- Goal 15: sel(i) vs y
      · set i' : Fin (n + 1) := ⟨i.val - 1, by omega⟩
        by_cases hin : i'.val < n
        · simp only [a'_resp, hin, dite_true]
          have : a_bwd i' = a_init ⟨i'.val, hin⟩ := by
            simp [a_init]
          rw [this]; exact tau_sel_y ⟨i'.val, hin⟩
        · simp only [a'_resp, show ¬(i'.val < n) from hin, dite_false]
          rw [show a_bwd i' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
          rw [← hd_eq_an]; exact tau_d_y
      -- Goal 16: sel(i) vs sel(j)
      · set i' : Fin (n + 1) := ⟨i.val - 1, by omega⟩
        set j' : Fin (n + 1) := ⟨j.val - 1, by omega⟩
        by_cases hin : i'.val < n
        · simp only [a'_resp, hin, dite_true]
          have hi_eq : a_bwd i' = a_init ⟨i'.val, hin⟩ := by
            simp [a_init]
          rw [hi_eq]
          by_cases hjn : j'.val < n
          · simp only [a'_resp, hjn, dite_true]
            have hj_eq : a_bwd j' = a_init ⟨j'.val, hjn⟩ := by
              simp [a_init]
            rw [hj_eq]; exact tau_sel_sel ⟨i'.val, hin⟩ ⟨j'.val, hjn⟩
          · -- j' = n: sel(i') vs d / resp_tau(i') vs c
            simp only [a'_resp, show ¬(j'.val < n) from hjn, dite_false]
            rw [show a_bwd j' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
            rw [← hd_eq_an]
            have hds := tau_d_sel ⟨i'.val, hin⟩
            exact ⟨⟨fun h => absurd h (not_lt.mpr (hd_le_init ⟨i'.val, hin⟩)),
                    fun h => absurd h (not_lt.mpr (hc_le_tau ⟨i'.val, hin⟩))⟩,
                   ⟨fun h => (hds.2.mp h.symm).symm,
                    fun h => (hds.2.mpr h.symm).symm⟩⟩
        · -- i' = n: d vs ... / c vs ...
          simp only [a'_resp, show ¬(i'.val < n) from hin, dite_false]
          rw [show a_bwd i' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
          rw [← hd_eq_an]
          by_cases hjn : j'.val < n
          · simp only [a'_resp, hjn, dite_true]
            have hj_eq : a_bwd j' = a_init ⟨j'.val, hjn⟩ := by
              simp [a_init]
            rw [hj_eq]; exact tau_d_sel ⟨j'.val, hjn⟩
          · -- i' = n, j' = n: d vs d / c vs c
            simp only [a'_resp, show ¬(j'.val < n) from hjn, dite_false]
            rw [show a_bwd j' = a_bwd ⟨n, by omega⟩ from by congr 1; simp [Fin.ext_iff]; omega]
            rw [← hd_eq_an]
            simp
    · -- gap_point_agreement (n+1)
      intro i
      simp only [game_tuple]
      by_cases hi0 : i.val = 0
      · simp [hi0]; exact hgp_x
      · by_cases hi_b : i.val = n + 1 + 1
        · simp [hi0, hi_b]; exact hgp_b
        · by_cases hi_y : i.val = (n + 1) + 2
          · simp [hi0, hi_b, hi_y]; exact hgp_y
          · simp [hi0, hi_b, hi_y]
            exact hgp_sel ⟨i.val - 1, by omega⟩
    · -- formula_agreement (n+1)
      intro i A hA
      simp only [game_tuple]
      by_cases hi0 : i.val = 0
      · simp [hi0]; exact hform_x A hA
      · by_cases hi_b : i.val = n + 1 + 1
        · simp [hi0, hi_b]; exact hform_b A hA
        · by_cases hi_y : i.val = (n + 1) + 2
          · simp [hi0, hi_b, hi_y]; exact hform_y A hA
          · simp [hi0, hi_b, hi_y]
            exact hform_sel ⟨i.val - 1, by omega⟩ A hA
  END OLD CASE II PROOF -/
  END Phase R2 COMMENT -/

/-! ### Cases III-IV: Gap Cases

When ALL of Spoiler's backward selections a_0,...,a_n lie in [d,y']
and a_n is a GAP (not a point), the proof uses gap detection formulas:

- **Case III** (a_n is a left-defined gap): Use Stavi Until U'(B, A)
  via the gap detection formula left(B, D). Duplicator finds a matching
  gap in M via Lemma 9.

- **Case IV** (a_n is a gap not left-defined): Use right(B, D) gap
  detection. Duplicator finds a matching gap in M defined on the right.

These cases require Lemma 9 (gap detection correctness) which is sorry'd
in EFGames.lean. -/

/-- **Cases III-IV helper**: When all selections lie in [d,y'] and a_n is
    a gap, construct Duplicator's response.

    The `h_r1_univ` parameter provides forward games at ANY rank r'+2,
    which is essential for gap detection transfer: gap existence needs
    rank r+2 (via gap_char_formula), while formula agreement at gaps
    needs rank r+4 (via left/right_formula_gap_detection). The rank-(r+4)
    game is obtained by instantiating h_r1_univ at r' = r+2. -/
private theorem ghr93_cases_III_IV {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {n r delta : Nat}
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r}
    {d : ExtendedCarrier N atomMap r}
    {a_bwd : Fin (n + 1) → ExtendedCarrier N atomMap r}
    (props : SplitPointProps n delta x y x' y' c d a_bwd)
    (ha_bwd : ∀ i, inClosedInterval x' y' (a_bwd i))
    (h_no_split : ∀ i : Fin (n + 1), d ≤ a_bwd i)
    (h_gap : IsGap (a_bwd ⟨n, by omega⟩))
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h_fwd_r1 : ghr93_duplicator_wins M N atomMap (4 + 3 * n) (r + 2)
      (rank_embed (by omega : r ≤ r + 2) x) (rank_embed (by omega : r ≤ r + 2) y)
      (rank_embed (by omega : r ≤ r + 2) x') (rank_embed (by omega : r ≤ r + 2) y'))
    (h_r1_univ : ∀ (r' : Nat) {x₁ y₁ : ExtendedCarrier M atomMap r'}
                   {x₁' y₁' : ExtendedCarrier N atomMap r'},
                 x₁ ≤ y₁ → x₁' ≤ y₁' →
                 ghr93_duplicator_wins M N atomMap (4 + 3 * n) (r' + 2)
                   (rank_embed (by omega : r' ≤ r' + 2) x₁)
                   (rank_embed (by omega : r' ≤ r' + 2) y₁)
                   (rank_embed (by omega : r' ≤ r' + 2) x₁')
                   (rank_embed (by omega : r' ≤ r' + 2) y₁')) :
    ∃ (a'_resp : Fin (n + 1) → ExtendedCarrier M atomMap r),
      (∀ i, inClosedInterval x y (a'_resp i)) ∧
      ∀ (b_sp : M.carrier),
        inClosedInterval x y (extendPoint b_sp) →
        ∃ (b_resp : N.carrier),
          inClosedInterval x' y' (extendPoint b_resp) ∧
          ghr93_winning_condition (n + 1)
            (game_tuple x' y' a_bwd b_resp)
            (game_tuple x y a'_resp b_sp) := by
  -- GHR93 Cases III/IV: all a_bwd(i) ≥ d, a_bwd(n) is a gap γ_N.
  -- Strategy: use τ for positions 0..n-1, then find a matching gap in M
  -- for position n via gap detection transfer.
  --
  -- Step 1: Build init sub-sequence (first n elements, all in [d, y'])
  let a_init : Fin n → ExtendedCarrier N atomMap r :=
    fun k => a_bwd ⟨k.val, by omega⟩
  have ha_init : ∀ k, inClosedInterval d y' (a_init k) := by
    intro k
    exact ⟨h_no_split ⟨k.val, by omega⟩, (ha_bwd ⟨k.val, by omega⟩).2⟩
  -- Step 2: Apply τ to the init sub-sequence to get M-side responses.
  -- Phase R2: tau is at rank r+delta on rank-embedded positions.
  -- Phase R3 will rank-embed a_init and project resp_tau back to rank r.
  have h_tau_app : ∃ (resp_tau : Fin n → ExtendedCarrier M atomMap r),
      (∀ k, inClosedInterval c y (resp_tau k)) ∧
      ∀ (b_sp : M.carrier), inClosedInterval c y (extendPoint b_sp) →
        ∃ (b_resp : N.carrier), inClosedInterval d y' (extendPoint b_resp) ∧
          ghr93_winning_condition n
            (game_tuple d y' a_init b_resp)
            (game_tuple c y resp_tau b_sp) := by sorry
  obtain ⟨resp_tau, hresp_tau_in, hwin_tau⟩ := h_tau_app
  -- Step 3: Extract the gap γ_N from h_gap
  obtain ⟨γ_N, hγ_N_eq⟩ := h_gap
  -- Step 4: Derive rank-(r+4) forward game from h_r1_univ at r' = r+2.
  -- This resolves the rank mismatch: gap detection formulas (left_formula,
  -- right_formula) have depth up to r+4, and h_fwd_r3 has rank r+4 = (r+2)+2.
  -- rank_embed transitivity: rank_embed (r+2 ≤ r+4) ∘ rank_embed (r ≤ r+2) = rank_embed (r ≤ r+4)
  have rank_embed_comp : ∀ (e : ExtendedCarrier M atomMap r),
      rank_embed (show r + 2 ≤ r + 2 + 2 by omega) (rank_embed (by omega : r ≤ r + 2) e) =
      rank_embed (show r ≤ r + 4 by omega) e := by
    intro e; cases e with
    | inl p => simp [rank_embed, Sum.map]
    | inr g => simp [rank_embed, Sum.map, rank_embed_gap]
  have rank_embed_comp_N : ∀ (e : ExtendedCarrier N atomMap r),
      rank_embed (show r + 2 ≤ r + 2 + 2 by omega) (rank_embed (by omega : r ≤ r + 2) e) =
      rank_embed (show r ≤ r + 4 by omega) e := by
    intro e; cases e with
    | inl p => simp [rank_embed, Sum.map]
    | inr g => simp [rank_embed, Sum.map, rank_embed_gap]
  have h_fwd_r3 : ghr93_duplicator_wins M N atomMap (4 + 3 * n) (r + 4)
      (rank_embed (by omega : r ≤ r + 4) x) (rank_embed (by omega : r ≤ r + 4) y)
      (rank_embed (by omega : r ≤ r + 4) x') (rank_embed (by omega : r ≤ r + 4) y') := by
    -- h_r1_univ at r' = r+2 gives game at rank (r+2)+2 = r+4.
    -- The endpoints match via rank_embed_comp (transitivity of rank_embed).
    have h_at_r2 := h_r1_univ (r + 2)
      ((rank_embed_le (by omega : r ≤ r + 2) x y).mpr hxy)
      ((rank_embed_le (by omega : r ≤ r + 2) x' y').mpr hx'y')
    -- h_at_r2 : game at rank (r+2)+2 with rank_embed-composed endpoints.
    -- Rewrite rank_embed compositions to direct rank_embeds.
    simp only [rank_embed_comp, rank_embed_comp_N] at h_at_r2
    exact h_at_r2
  -- Step 5: Gap detection assembly.
  -- Extract the defining formula D and its depth bound from γ_N's r-definability.
  obtain ⟨D, hD_depth, hD_def⟩ := γ_N.prop
  -- Sub-goal S11.1: Existence of a matching gap in M with formula agreement.
  -- GHR93 Cases III/IV core: gap detection transfer via left/right_formula.
  -- (a) Get reference point m_N in N near the gap, with D-between condition
  -- (b) Use left/right_formula_gap_detection backward to encode gap truth
  -- (c) Transfer via h_fwd_r3 (rank r+4) to reference point m_M in M
  -- (d) Use left/right_formula_gap_detection forward to extract matching gap
  -- (e) Apply gap_detection_unique to show the gap is independent of A
  have h_gap_match : ∃ (γ_M : RDefinableGap M atomMap r),
      inClosedInterval x y (Sum.inr γ_M) ∧
      (∀ (A : StaviFormula), stavi_depth A ≤ r →
        (stavi_temporal_truth_mu M atomMap r (Sum.inr γ_M) A ↔
         stavi_temporal_truth_mu N atomMap r (Sum.inr γ_N) A)) := by
    -- GHR93 Cases III/IV gap detection transfer.
    -- S11.1a: Reference point m_N ∈ γ_N.val.cut ∩ [x', y'] with D-between.
    -- S11.1b: Forward game → m_M with formula agreement at depth ≤ r+4.
    -- S11.1c: left/right_formula transfer via gap detection lemmas.
    -- S11.1d: gap_detection_unique → γ_M independent of A.
    -- S11.1e: Interval from forward game bounds.
    --
    -- Case split on left vs right definability. Both cases are symmetric;
    -- the left case uses left_formula, the right uses right_formula.
    rcases hD_def with h_left | h_right
    · -- LEFT CASE: γ_N is D-definable on the left.
      -- S11.1a: Get reference point m_N.
      -- From gap_definable_on_left: ∃ t ∈ cut, D holds at all u ≥ t in cut.
      -- Keep h_left for later use in gap detection transfer.
      have h_left_orig := h_left
      obtain ⟨⟨t_N, ht_N_cut, hD_above_t⟩, _h_no_init⟩ := h_left
      -- Find m_N ∈ γ_N.val.cut ∩ [x', y'] with D-between condition.
      -- Strategy: case split on d (point vs gap), find a cut element above x'.
      -- Then take max of that element and t_N for the D-between condition.
      have hγ_N_in : inClosedInterval x' y' (Sum.inr γ_N) := by
        rw [← hγ_N_eq]; exact ha_bwd ⟨n, by omega⟩
      -- Any t ∈ γ_N.val.cut has extendPoint t < Sum.inr γ_N ≤ y'.
      have ht_N_lt_γ : (extendPoint t_N : ExtendedCarrier N atomMap r) <
          Sum.inr γ_N :=
        lt_of_le_of_ne ((extendPoint_le_gap_iff t_N γ_N).mpr ht_N_cut)
          (fun h => by cases h)
      -- Find m_N: a cut element above x' with D-between condition.
      have hd_le_γ : d ≤ Sum.inr γ_N := hγ_N_eq ▸ h_no_split ⟨n, by omega⟩
      -- Helper: any cut element ≥ t_N satisfies the D-between condition.
      have hD_between_any : ∀ (m : N.carrier), t_N ≤ m → m ∈ γ_N.val.cut →
          (∀ u : N.carrier, m < u → u ∈ γ_N.val.cut →
            stavi_temporal_truth_mu N atomMap r (extendPoint u) D) := by
        intro m htm hm_cut u hmu hu_cut
        exact (stavi_truth_mu_at_point u D).mpr
          (hD_above_t u (le_of_lt (lt_of_le_of_lt htm hmu)) hu_cut)
      -- Degenerate boundary check: if x' = Sum.inr γ_N, the reference-point approach
      -- cannot find m_N ∈ cut above x' (all cut elements are strictly below the gap).
      -- In this case, d = x' = Sum.inr γ_N, so c corresponds via hcd_form directly.
      if hx'_eq_γ : x' = (Sum.inr γ_N : ExtendedCarrier N atomMap r) then
        -- DEGENERATE LEFT BOUNDARY: x' = Sum.inr γ_N.
        -- Then d = Sum.inr γ_N (since x' ≤ d ≤ Sum.inr γ_N = x').
        have hd_eq_γN : d = Sum.inr γ_N :=
          le_antisymm hd_le_γ (hx'_eq_γ ▸ props.hx'd)
        -- c is a gap (since d is a gap by hcd_gp).
        have hd_gap : IsGap d := ⟨γ_N, hd_eq_γN⟩
        obtain ⟨g_c, hc_eq⟩ := props.hcd_gp.2.mpr hd_gap
        -- g_c serves as γ_M with formula agreement from hcd_form.
        exact ⟨g_c, ⟨hc_eq ▸ props.hxc, hc_eq ▸ props.hcy⟩,
          fun A hA => by
            have h := props.hcd_form A hA
            rw [hc_eq] at h; rw [hd_eq_γN] at h; exact h⟩
      else
      -- NON-DEGENERATE: x' ≠ Sum.inr γ_N, hence x' < Sum.inr γ_N.
      have hx'_lt_γ : x' < (Sum.inr γ_N : ExtendedCarrier N atomMap r) :=
        lt_of_le_of_ne (le_trans props.hx'd hd_le_γ) hx'_eq_γ
      -- Case split: either t_N is already above x', or we need a higher cut element.
      have ⟨m_N, hm_N_cut, hm_N_above_x', hm_N_D_between⟩ :
          ∃ (m_N : N.carrier), m_N ∈ γ_N.val.cut ∧
            x' ≤ (extendPoint m_N : ExtendedCarrier N atomMap r) ∧
            (∀ u : N.carrier, m_N < u → u ∈ γ_N.val.cut →
              stavi_temporal_truth_mu N atomMap r (extendPoint u) D) := by
        rcases le_or_gt x' (extendPoint t_N) with hx'_le | hx'_gt
        · -- t_N works directly
          exact ⟨t_N, ht_N_cut, hx'_le, hD_between_any t_N le_rfl ht_N_cut⟩
        · -- x' > extendPoint t_N. Since x' ≤ d ≤ Sum.inr γ_N,
          -- case-split on whether d is a point or a gap.
          rcases isPoint_or_isGap d with ⟨d_pt, hd_eq⟩ | ⟨g_d, hd_eq⟩
          · -- d is a point d_pt. Then d_pt ∈ γ_N.val.cut and x' ≤ d = extendPoint d_pt.
            have hd_pt_cut : d_pt ∈ γ_N.val.cut := by
              have h1 : (extendPoint d_pt : ExtendedCarrier N atomMap r) = d := hd_eq.symm
              have h2 : d ≤ (Sum.inr γ_N : ExtendedCarrier N atomMap r) := hd_le_γ
              exact (extendPoint_le_gap_iff d_pt γ_N).mp (h1 ▸ h2)
            have hx'_le_d_pt : x' ≤ (extendPoint d_pt : ExtendedCarrier N atomMap r) := by
              have : (extendPoint d_pt : ExtendedCarrier N atomMap r) = d := hd_eq.symm
              rw [this]; exact props.hx'd
            -- d_pt ≥ t_N (since extendPoint d_pt ≥ x' > extendPoint t_N)
            have ht_le_d : t_N ≤ d_pt :=
              le_of_lt ((extendPoint_lt_iff t_N d_pt).mp
                (lt_of_lt_of_le hx'_gt hx'_le_d_pt))
            exact ⟨d_pt, hd_pt_cut, hx'_le_d_pt, hD_between_any d_pt ht_le_d hd_pt_cut⟩
          · -- d is a gap g_d. Since d ≤ Sum.inr γ_N and d ≠ Sum.inr γ_N
            -- (d is below a_bwd(n) = Sum.inr γ_N and there's a point a_bwd(0)
            -- between d and y'), γ_N.val.cut is NOT a subset of g_d.val.cut.
            -- So there exists m ∈ γ_N.val.cut \ g_d.val.cut, giving Sum.inr g_d < extendPoint m.
            -- Strategy: γ_N.val.cut has no supremum, so we can find elements
            -- arbitrarily high. We need one above g_d and t_N.
            -- From d ≤ Sum.inr γ_N, g_d.val.cut ⊆ γ_N.val.cut.
            have hg_d_sub : g_d.val.cut ⊆ γ_N.val.cut := by
              rw [hd_eq] at hd_le_γ; exact hd_le_γ
            -- γ_N.val.cut \ g_d.val.cut is nonempty (otherwise g_d = γ_N,
            -- but d < Sum.inr γ_N since d ≤ a_bwd(n) = Sum.inr γ_N
            -- and we've established ht_N_lt_γ so γ_N is a proper gap above d).
            -- Find m0 ∈ γ_N.cut with x' ≤ extendPoint m0.
            -- Strategy: case split on x' being a point or gap.
            -- When x' is a point p in the cut, gap_cut_exists_gt gives m0 > p.
            -- When x' is a gap g_x ⊊ γ_N, the strict difference γ_N.cut \ g_x.cut
            -- gives m0 with extendPoint m0 > Sum.inr g_x = x'.
            -- Edge case: x' = Sum.inr γ_N (= d when g_d = γ_N). This means the
            -- interval [x', d] is degenerate. Handled separately.
            have hx'_lt_γ : x' < (Sum.inr γ_N : ExtendedCarrier N atomMap r) := by
              rcases eq_or_lt_of_le (show x' ≤ Sum.inr γ_N from
                  le_trans props.hx'd hd_le_γ) with heq | hlt
              · -- x' = Sum.inr γ_N contradicts hx'_lt_γ from outer case split.
                exact absurd heq (ne_of_lt hx'_lt_γ)
              · exact hlt
            -- Now x' < Sum.inr γ_N strictly.
            -- Find m0 ∈ γ_N.cut with x' ≤ extendPoint m0.
            rcases isPoint_or_isGap x' with ⟨p_x, hpx_eq⟩ | ⟨g_x, hgx_eq⟩
            · -- x' is a point p_x. Since x' ≤ Sum.inr γ_N, p_x ∈ γ_N.cut.
              have hp_cut : p_x ∈ γ_N.val.cut := by
                rw [hpx_eq] at hx'_lt_γ
                exact (extendPoint_le_gap_iff p_x γ_N).mp (le_of_lt hx'_lt_γ)
              -- gap_cut_exists_gt: ∃ m0 > p_x in the cut.
              obtain ⟨m0, hm0_cut, hp_lt_m0⟩ := gap_cut_exists_gt γ_N.val p_x hp_cut
              have hx'_le_m0 : x' ≤ (extendPoint m0 : ExtendedCarrier N atomMap r) := by
                rw [hpx_eq]; exact le_of_lt ((extendPoint_lt_iff p_x m0).mpr hp_lt_m0)
              -- t_N ≤ m0? If not, t_N > m0, so extendPoint t_N > extendPoint m0 ≥ x'.
              -- But hx'_gt says extendPoint t_N < x'. Contradiction.
              -- So t_N < m0 or t_N ≤ m0.
              have htm : t_N ≤ m0 := by
                by_contra h_not; push_neg at h_not
                -- m0 < t_N, so extendPoint m0 < extendPoint t_N
                have : (extendPoint m0 : ExtendedCarrier N atomMap r) ≤ extendPoint t_N :=
                  (extendPoint_le_iff m0 t_N).mpr (le_of_lt h_not)
                exact not_lt.mpr (le_trans hx'_le_m0 this) hx'_gt
              exact ⟨m0, hm0_cut, hx'_le_m0, hD_between_any m0 htm hm0_cut⟩
            · -- x' is a gap g_x. Since x' < Sum.inr γ_N, g_x.cut ⊊ γ_N.cut.
              have hg_sub : g_x.val.cut ⊆ γ_N.val.cut := by
                rw [hgx_eq] at hx'_lt_γ; exact le_of_lt hx'_lt_γ
              have hg_ne : g_x.val.cut ≠ γ_N.val.cut := by
                intro heq
                have := gap_ext g_x.val γ_N.val heq
                have : x' = (Sum.inr γ_N : ExtendedCarrier N atomMap r) := by
                  rw [hgx_eq]; congr 1; exact Subtype.ext this
                exact absurd this (ne_of_lt hx'_lt_γ)
              -- Strict difference is nonempty.
              have h_diff : ∃ m0, m0 ∈ γ_N.val.cut ∧ m0 ∉ g_x.val.cut := by
                by_contra h_all; push_neg at h_all
                exact hg_ne (Set.Subset.antisymm hg_sub (fun x hx => h_all x hx))
              obtain ⟨m0, hm0_cut, hm0_not_gx⟩ := h_diff
              -- m0 ∉ g_x.cut means extendPoint m0 > Sum.inr g_x = x'
              have hx'_le_m0 : x' ≤ (extendPoint m0 : ExtendedCarrier N atomMap r) := by
                rw [hgx_eq]
                exact le_of_lt (@lt_of_not_le (ExtendedCarrier N atomMap r) _ _ _
                  (fun h => hm0_not_gx ((extendPoint_le_gap_iff m0 g_x).mp h)))
              have htm : t_N ≤ m0 := by
                by_contra h_not; push_neg at h_not
                have : (extendPoint m0 : ExtendedCarrier N atomMap r) ≤ extendPoint t_N :=
                  (extendPoint_le_iff m0 t_N).mpr (le_of_lt h_not)
                exact not_lt.mpr (le_trans hx'_le_m0 this) hx'_gt
              exact ⟨m0, hm0_cut, hx'_le_m0, hD_between_any m0 htm hm0_cut⟩
      -- m_N is in [x', y']: x' ≤ extendPoint m_N and extendPoint m_N < Sum.inr γ_N ≤ y'.
      have hm_N_lt_γ : (extendPoint m_N : ExtendedCarrier N atomMap r) < Sum.inr γ_N :=
        lt_of_le_of_ne ((extendPoint_le_gap_iff m_N γ_N).mpr hm_N_cut)
          (fun h => by cases h)
      have hm_N_in : inClosedInterval x' y' (extendPoint m_N) :=
        ⟨hm_N_above_x', le_of_lt (lt_of_lt_of_le hm_N_lt_γ hγ_N_in.2)⟩
      -- S11.1b: Forward game at rank r+4 — challenge with m_N to get m_M.
      -- Reduce h_fwd_r3 to a 1-round game, then challenge with m_N.
      have h_fwd_1 : ghr93_duplicator_wins M N atomMap 1 (r + 4)
          (rank_embed (by omega : r ≤ r + 4) x)
          (rank_embed (by omega : r ≤ r + 4) y)
          (rank_embed (by omega : r ≤ r + 4) x')
          (rank_embed (by omega : r ≤ r + 4) y') := by
        exact ghr93_duplicator_wins_round_mono (by omega : 1 ≤ 4 + 3 * n)
          ((rank_embed_le _ x y).mpr hxy) ((rank_embed_le _ x' y').mpr hx'y') h_fwd_r3
      -- Play the 1-round game: pick c (rank-embedded) from M.
      have hc_in_re : inClosedInterval (rank_embed (by omega : r ≤ r + 4) x)
          (rank_embed (by omega : r ≤ r + 4) y)
          (rank_embed (by omega : r ≤ r + 4) c) := by
        exact ⟨(rank_embed_le _ x c).mpr props.hxc, (rank_embed_le _ c y).mpr props.hcy⟩
      obtain ⟨a'_1, ha'_1_in, hwin_1⟩ := h_fwd_1
        (fun _ : Fin 1 => rank_embed (by omega : r ≤ r + 4) c)
        (fun _ => hc_in_re)
      -- Challenge Round 2 with m_N.
      have hm_N_in_re : inClosedInterval
          (rank_embed (by omega : r ≤ r + 4) x')
          (rank_embed (by omega : r ≤ r + 4) y')
          (extendPoint m_N) := by
        rw [show (extendPoint m_N : ExtendedCarrier N atomMap (r + 4)) =
            rank_embed (by omega : r ≤ r + 4) (extendPoint m_N) from
            (rank_embed_point (by omega : r ≤ r + 4) m_N).symm]
        exact ⟨(rank_embed_le _ x' (extendPoint m_N)).mpr hm_N_in.1,
               (rank_embed_le _ (extendPoint m_N) y').mpr hm_N_in.2⟩
      obtain ⟨m_M, hm_M_in_re, hcond_1⟩ := hwin_1 m_N hm_N_in_re
      obtain ⟨_hord_1, _hgp_1, hform_1⟩ := hcond_1
      -- hform_1 gives formula agreement at game_tuple positions.
      -- At the b-position: m_M vs m_N.
      have hform_mM_mN : ∀ (A : StaviFormula), stavi_depth A ≤ r + 4 →
          (stavi_temporal_truth_mu M atomMap (r + 4) (extendPoint m_M) A ↔
           stavi_temporal_truth_mu N atomMap (r + 4) (extendPoint m_N) A) := by
        intro A hA
        have h := hform_1 ⟨1 + 1, by omega⟩ A hA
        simp only [game_tuple_b_eq] at h; exact h
      -- Simplify via stavi_truth_mu_at_point: truth at carrier points is rank-independent.
      -- rank r ↔ standard ↔ rank (r+4), so rank-r agreement follows from rank-(r+4) agreement.
      have hform_pts : ∀ (A : StaviFormula), stavi_depth A ≤ r + 4 →
          (stavi_temporal_truth_mu M atomMap r (extendPoint m_M) A ↔
           stavi_temporal_truth_mu N atomMap r (extendPoint m_N) A) := by
        intro A hA
        constructor
        · intro h
          exact (stavi_truth_mu_at_point (r := r) m_N A).mpr
            ((stavi_truth_mu_at_point (r := r + 4) m_N A).mp
              ((hform_mM_mN A hA).mp
                ((stavi_truth_mu_at_point (r := r + 4) m_M A).mpr
                  ((stavi_truth_mu_at_point (r := r) m_M A).mp h))))
        · intro h
          exact (stavi_truth_mu_at_point (r := r) m_M A).mpr
            ((stavi_truth_mu_at_point (r := r + 4) m_M A).mp
              ((hform_mM_mN A hA).mpr
                ((stavi_truth_mu_at_point (r := r + 4) m_N A).mpr
                  ((stavi_truth_mu_at_point (r := r) m_N A).mp h))))
      -- m_M is in [x, y] (from rank-embedded bounds).
      have hm_M_in : inClosedInterval x y (extendPoint m_M) := by
        have h_lo := hm_M_in_re.1
        have h_hi := hm_M_in_re.2
        -- h_lo : rank_embed x ≤ extendPoint m_M (at rank r+4)
        -- rank_embed_point: rank_embed (extendPoint m_M) = extendPoint m_M
        -- So h_lo : rank_embed x ≤ rank_embed (extendPoint m_M) by substitution
        rw [← rank_embed_point (by omega : r ≤ r + 4) m_M] at h_lo h_hi
        exact ⟨(rank_embed_le _ x (extendPoint m_M)).mp h_lo,
               (rank_embed_le _ (extendPoint m_M) y).mp h_hi⟩
      -- Degenerate y' check: if y' = Sum.inr γ_N, the sub-interval game approach
      -- cannot find complement elements in [m_N, y']. Handle via tau endpoint agreement.
      if hy'_eq_γ : y' = (Sum.inr γ_N : ExtendedCarrier N atomMap r) then
        -- y' = Sum.inr γ_N. Use tau 0-round game for endpoint agreement.
        rcases props.h_pt_cy with ⟨p_cy, hp_cy⟩ | ⟨hcy_eq, hdy'_eq, hgap_c, _hgap_d⟩
        · -- Carrier point p_cy ∈ [c, y]. Use tau endpoint agreement.
          -- Phase R2: tau at r+delta. Phase R3 will project to rank r.
          have h_tau_0 : ghr93_duplicator_wins N M atomMap 0 r d y' c y := by sorry
          obtain ⟨_a'_tau0, _ha'_tau0_in, hwin_tau0⟩ := h_tau_0
            (fun i => Fin.elim0 i) (fun i => Fin.elim0 i)
          obtain ⟨b_tau0, _hb_tau0_in, hcond_tau0⟩ := hwin_tau0 p_cy hp_cy
          obtain ⟨_hord_tau0, hgp_tau0, hform_tau0⟩ := hcond_tau0
          have hgp_y : (IsPoint y ↔ IsPoint y') ∧ (IsGap y ↔ IsGap y') := by
            have h := hgp_tau0 ⟨0 + 2, by omega⟩
            simp only [game_tuple_y_eq] at h; exact ⟨h.1.symm, h.2.symm⟩
          obtain ⟨g_y_M, hy_eq⟩ := hgp_y.2.mpr ⟨γ_N, hy'_eq_γ⟩
          exact ⟨g_y_M, ⟨hy_eq ▸ hxy, hy_eq ▸ le_refl y⟩,
            fun A hA => by
              have h := hform_tau0 ⟨0 + 2, by omega⟩ A hA
              simp only [game_tuple_y_eq] at h
              rw [hy_eq] at h; rw [hy'_eq_γ] at h; exact h.symm⟩
        · -- c = y, d = y', both gaps. Use hcd_form directly.
          have hd_eq_γN : d = Sum.inr γ_N := by rw [hdy'_eq, hy'_eq_γ]
          obtain ⟨g_c, hc_eq⟩ := hgap_c
          exact ⟨g_c, ⟨hc_eq ▸ hcy_eq ▸ hxy, hc_eq ▸ hcy_eq ▸ le_refl y⟩,
            fun A hA => by
              have h := props.hcd_form A hA
              rw [hc_eq] at h; rw [hd_eq_γN] at h; exact h⟩
      else
      -- NON-DEGENERATE y': Sum.inr γ_N < y'.
      have hγ_ne_y' : (Sum.inr γ_N : ExtendedCarrier N atomMap r) ≠ y' :=
        fun h => hy'_eq_γ h.symm
      have hy'_gt_γ : y' > (Sum.inr γ_N : ExtendedCarrier N atomMap r) :=
        lt_of_le_of_ne hγ_N_in.2 hγ_ne_y'
      -- S11.1c: Gap detection transfer.
      -- For each A with stavi_depth A ≤ r, transfer A-truth at γ_N to existence of
      -- a matching gap γ_A_M in M via left_formula_gap_detection.
      -- left_formula(A, D) has depth ≤ max(depth A, depth D) + 4 ≤ r + 4.
      have hform_transfer : ∀ (A : StaviFormula), stavi_depth A ≤ r →
          stavi_temporal_truth_mu N atomMap r (Sum.inr γ_N) A →
          ∃ (γ_A : RDefinableGap M atomMap r),
            (extendPoint m_M : ExtendedCarrier M atomMap r) < Sum.inr γ_A ∧
            gap_definable_on_left M atomMap γ_A.val D ∧
            (∀ u : M.carrier, m_M < u → u ∈ γ_A.val.cut →
              stavi_temporal_truth_mu M atomMap r (extendPoint u) D) ∧
            stavi_temporal_truth_mu M atomMap r (Sum.inr γ_A) A := by
        intro A hA hA_γN
        -- Backward: A^mu(γ_N) → left_formula(A,D)(m_N) via left_formula_gap_detection at N
        have h_left_N : stavi_temporal_truth_mu N atomMap r (extendPoint m_N)
            (left_formula A D) := by
          rw [left_formula_gap_detection A D hD_depth m_N]
          exact ⟨γ_N, hm_N_lt_γ, h_left_orig, hm_N_D_between, hA_γN⟩
        -- Transfer: left_formula truth from m_N to m_M.
        have h_left_depth : stavi_depth (left_formula A D) ≤ r + 4 := by
          calc stavi_depth (left_formula A D) ≤ max (stavi_depth A) (stavi_depth D) + 4 :=
            stavi_depth_left_formula A D
          _ ≤ max r r + 4 := by omega
          _ = r + 4 := by omega
        have h_left_M : stavi_temporal_truth_mu M atomMap r (extendPoint m_M)
            (left_formula A D) := (hform_pts (left_formula A D) h_left_depth).mpr h_left_N
        -- Forward: left_formula(A,D)(m_M) → ∃ γ_A in M with A^mu(γ_A)
        rw [left_formula_gap_detection A D hD_depth m_M] at h_left_M
        obtain ⟨γ_A, hm_lt_γA, h_def_A, h_D_bet_A, hA_γA⟩ := h_left_M
        exact ⟨γ_A, hm_lt_γA, h_def_A, h_D_bet_A, hA_γA⟩
      -- Step 1: Instantiate hform_transfer with sf_verum to get γ_M existence.
      -- sf_verum has depth 0 ≤ r and is trivially true at all positions.
      have h_verum_γN : stavi_temporal_truth_mu N atomMap r (Sum.inr γ_N) sf_verum := by
        simp [sf_verum, stavi_temporal_truth_mu, temporal_truth_mu]
      obtain ⟨γ_M, hm_lt_γM, h_def_γM_left, h_D_bet_γM, _⟩ :=
        hform_transfer sf_verum (by rw [stavi_depth_sf_verum]; omega) h_verum_γN
      -- Step 2: γ_M ∈ [x, y].
      -- Lower bound: x ≤ m_M < γ_M (trivial from hm_M_in.1 and hm_lt_γM).
      -- Upper bound Sum.inr γ_M ≤ y: by contradiction using sub-interval game.
      -- Since y' > Sum.inr γ_N (non-degenerate), find p_N ∉ γ_N.cut with ¬D(p_N)
      -- in [m_N, y'] via _h_no_init. Play sub-interval forward game on [m_M, y] vs
      -- [m_N, y'] via h_r1_univ to get p_M with m_M < p_M (order agreement).
      -- Then h_D_bet_γM gives D(p_M), but formula agreement gives ¬D(p_M). ⊥
      have hγ_M_in : inClosedInterval x y (Sum.inr γ_M) :=
        ⟨le_of_lt (lt_of_le_of_lt hm_M_in.1 hm_lt_γM), by
          by_contra h_not_le; push_neg at h_not_le
          -- h_not_le : y < Sum.inr γ_M
          -- Step 2a: Find complement element t₀ of γ_N with extendPoint t₀ ≤ y'.
          have ⟨t₀, ht₀_not_cut, ht₀_le_y'⟩ : ∃ t₀ : N.carrier, t₀ ∉ γ_N.val.cut ∧
              (extendPoint t₀ : ExtendedCarrier N atomMap r) ≤ y' := by
            rcases isPoint_or_isGap y' with ⟨p_y', hp_eq⟩ | ⟨g_y', hg_eq⟩
            · -- y' is a point p_y' above γ_N.
              refine ⟨p_y', ?_, le_of_eq hp_eq.symm⟩
              intro h_in
              have : (extendPoint p_y' : ExtendedCarrier N atomMap r) ≤ Sum.inr γ_N :=
                (extendPoint_le_gap_iff p_y' γ_N).mpr h_in
              have : y' ≤ (Sum.inr γ_N : ExtendedCarrier N atomMap r) := hp_eq ▸ this
              exact absurd this (not_le.mpr hy'_gt_γ)
            · -- y' is a gap g_y' with γ_N.cut ⊊ g_y'.cut.
              -- Sum.inr γ_N ≤ y' = Sum.inr g_y' implies γ_N.cut ⊆ g_y'.cut.
              have hg_sub : γ_N.val.cut ⊆ g_y'.val.cut := by
                -- hγ_N_in.2 : Sum.inr γ_N ≤ y' and hg_eq : y' = Sum.inr g_y'
                -- On ExtendedCarrier, Sum.inr γ ≤ Sum.inr g ↔ γ.cut ⊆ g.cut.
                -- Use the ordering directly.
                show extendedLE (Sum.inr γ_N) (Sum.inr g_y')
                have h1 : extendedLE (Sum.inr γ_N) y' := le_of_lt hy'_gt_γ
                rwa [hg_eq] at h1
              -- The subset is proper (since the gaps are different).
              have hg_ne : ¬g_y'.val.cut ⊆ γ_N.val.cut := by
                intro h_sub
                have h_eq := gap_ext γ_N.val g_y'.val
                  (Set.Subset.antisymm hg_sub h_sub)
                have : y' = (Sum.inr γ_N : ExtendedCarrier N atomMap r) := by
                  rw [hg_eq]; exact congr_arg Sum.inr (Subtype.ext h_eq.symm)
                exact hy'_eq_γ this
              obtain ⟨m₀, hm₀_in, hm₀_not⟩ := Set.not_subset.mp hg_ne
              exact ⟨m₀, hm₀_not, le_trans ((extendPoint_le_gap_iff m₀ g_y').mpr hm₀_in)
                (le_of_eq hg_eq.symm)⟩
          -- Step 2b: Apply _h_no_init to get p_N with ¬D(p_N).
          push_neg at _h_no_init
          obtain ⟨p_N, hp_N_not_cut, hp_N_le, hpN_not_D⟩ := _h_no_init t₀ ht₀_not_cut
          -- Step 2c: Show m_N < p_N (cut membership vs complement).
          have hm_N_lt_p_N : m_N < p_N := by
            by_contra h_not_lt; push_neg at h_not_lt
            exact hp_N_not_cut (γ_N.val.downward_closed m_N p_N hm_N_cut h_not_lt)
          -- Step 2d: p_N ∈ [m_N, y'] at rank r.
          have hp_N_in : extendPoint p_N ≤ y' :=
            le_trans ((extendPoint_le_iff p_N t₀).mpr hp_N_le) ht₀_le_y'
          -- Step 2e: Sub-interval forward game on [m_M, y] vs [m_N, y'] via h_r1_univ.
          -- Instantiate at r' = r to get game at rank r+2 (simpler than r+4).
          have h_sub_raw := h_r1_univ r
            (show (extendPoint m_M : ExtendedCarrier M atomMap r) ≤ y from hm_M_in.2)
            (show (extendPoint m_N : ExtendedCarrier N atomMap r) ≤ y' from hm_N_in.2)
          -- h_sub_raw : game at rank r+2 on [rank_embed m_M, rank_embed y] vs
          --   [rank_embed m_N, rank_embed y'].
          -- rank_embed_point simplifies: rank_embed(extendPoint m) = extendPoint m.
          -- Reduce to 1-round game.
          have h_sub_1 : ghr93_duplicator_wins M N atomMap 1 (r + 2)
              (rank_embed (show r ≤ r + 2 by omega) (extendPoint m_M : ExtendedCarrier M atomMap r))
              (rank_embed (show r ≤ r + 2 by omega) y)
              (rank_embed (show r ≤ r + 2 by omega) (extendPoint m_N : ExtendedCarrier N atomMap r))
              (rank_embed (show r ≤ r + 2 by omega) y') :=
            ghr93_duplicator_wins_round_mono (show 1 ≤ 4 + 3 * n by omega)
              ((rank_embed_le _ (extendPoint m_M) y).mpr hm_M_in.2)
              ((rank_embed_le _ (extendPoint m_N) y').mpr hm_N_in.2)
              h_sub_raw
          -- M selects rank_embed(extendPoint m_M) as its single selection.
          have hm_M_in_sub : inClosedInterval
              (rank_embed (show r ≤ r + 2 by omega) (extendPoint m_M : ExtendedCarrier M atomMap r))
              (rank_embed (show r ≤ r + 2 by omega) y)
              (rank_embed (show r ≤ r + 2 by omega) (extendPoint m_M : ExtendedCarrier M atomMap r)) :=
            ⟨le_refl _, (rank_embed_le _ (extendPoint m_M) y).mpr hm_M_in.2⟩
          obtain ⟨a'_sub, _ha'_sub_in, hwin_sub⟩ := h_sub_1
            (fun _ : Fin 1 => rank_embed (show r ≤ r + 2 by omega)
              (extendPoint m_M : ExtendedCarrier M atomMap r))
            (fun _ => hm_M_in_sub)
          -- Challenge with p_N.
          have hp_N_in_sub : inClosedInterval
              (rank_embed (show r ≤ r + 2 by omega) (extendPoint m_N : ExtendedCarrier N atomMap r))
              (rank_embed (show r ≤ r + 2 by omega) y')
              (extendPoint p_N : ExtendedCarrier N atomMap (r + 2)) := by
            rw [← rank_embed_point (show r ≤ r + 2 by omega) p_N]
            exact ⟨(rank_embed_le _ (extendPoint m_N) (extendPoint p_N)).mpr
                    ((extendPoint_le_iff m_N p_N).mpr (le_of_lt hm_N_lt_p_N)),
                   (rank_embed_le _ (extendPoint p_N) y').mpr hp_N_in⟩
          obtain ⟨p_M, hp_M_in_sub, hcond_sub⟩ := hwin_sub p_N hp_N_in_sub
          obtain ⟨hord_sub, _hgp_sub, hform_sub⟩ := hcond_sub
          -- Step 2f: Order agreement at positions (0, 2) gives m_M < p_M.
          -- game_tuple for n=1: pos 0 = rank_embed(m_M), pos 1 = rank_embed(m_M),
          --   pos 2 = extendPoint p_M, pos 3 = rank_embed(y).
          -- N-side: pos 0 = rank_embed(m_N), pos 1 = a'_sub(0),
          --   pos 2 = extendPoint p_N, pos 3 = rank_embed(y').
          have hord_0_2 := hord_sub ⟨0, by omega⟩ ⟨1 + 1, by omega⟩
          simp only [game_tuple_zero_eq, game_tuple_b_eq] at hord_0_2
          -- N-side: rank_embed(m_N) < extendPoint p_N at rank r+2.
          have hm_N_lt_p_N_r2 :
              rank_embed (show r ≤ r + 2 by omega) (extendPoint m_N : ExtendedCarrier N atomMap r) <
              (extendPoint p_N : ExtendedCarrier N atomMap (r + 2)) := by
            rw [rank_embed_point (show r ≤ r + 2 by omega) m_N]
            rw [show (extendPoint p_N : ExtendedCarrier N atomMap (r + 2)) =
                rank_embed (show r ≤ r + 2 by omega) (extendPoint p_N : ExtendedCarrier N atomMap r)
                from (rank_embed_point (show r ≤ r + 2 by omega) p_N).symm]
            rw [rank_embed_point (show r ≤ r + 2 by omega) p_N]
            exact (extendPoint_lt_iff m_N p_N).mpr hm_N_lt_p_N
          -- Transfer: rank_embed(m_M) < extendPoint p_M at rank r+2.
          have hm_M_lt_p_M_r2 :
              rank_embed (show r ≤ r + 2 by omega) (extendPoint m_M : ExtendedCarrier M atomMap r) <
              (extendPoint p_M : ExtendedCarrier M atomMap (r + 2)) :=
            hord_0_2.1.mpr hm_N_lt_p_N_r2
          -- Step 2g: m_M < p_M at rank r.
          have hm_M_lt_p_M_r : m_M < p_M := by
            rw [rank_embed_point (show r ≤ r + 2 by omega) m_M,
                show (extendPoint p_M : ExtendedCarrier M atomMap (r + 2)) =
                  rank_embed (show r ≤ r + 2 by omega) (extendPoint p_M : ExtendedCarrier M atomMap r)
                  from (rank_embed_point (show r ≤ r + 2 by omega) p_M).symm,
                rank_embed_point (show r ≤ r + 2 by omega) p_M] at hm_M_lt_p_M_r2
            exact (extendPoint_lt_iff m_M p_M).mp hm_M_lt_p_M_r2
          -- Step 2h: p_M ≤ y (from game bounds) → p_M ∈ γ_M.cut.
          have hp_M_le_y : (extendPoint p_M : ExtendedCarrier M atomMap r) ≤ y := by
            have h_bound := hp_M_in_sub.2
            rw [show (extendPoint p_M : ExtendedCarrier M atomMap (r + 2)) =
                  rank_embed (show r ≤ r + 2 by omega) (extendPoint p_M : ExtendedCarrier M atomMap r)
                  from (rank_embed_point (show r ≤ r + 2 by omega) p_M).symm] at h_bound
            exact (rank_embed_le _ (extendPoint p_M) y).mp h_bound
          have hp_M_in_cut : p_M ∈ γ_M.val.cut :=
            (extendPoint_le_gap_iff p_M γ_M).mp (le_of_lt (lt_of_le_of_lt hp_M_le_y h_not_le))
          -- Step 2i: D(p_M) from h_D_bet_γM.
          have hD_p_M : stavi_temporal_truth_mu M atomMap r (extendPoint p_M) D :=
            h_D_bet_γM p_M hm_M_lt_p_M_r hp_M_in_cut
          -- Step 2j: Formula agreement at position 2 gives ¬D(p_M).
          -- hform_sub at position 2 (b-position): D at p_M ↔ D at p_N at rank r+2.
          have hform_D := hform_sub ⟨1 + 1, by omega⟩ D (by omega : stavi_depth D ≤ r + 2)
          simp only [game_tuple_b_eq] at hform_D
          -- Transfer between rank r and rank r+2 via stavi_truth_mu_at_point.
          have hD_p_M_r2 : stavi_temporal_truth_mu M atomMap (r + 2) (extendPoint p_M) D :=
            (stavi_truth_mu_at_point (r := r + 2) p_M D).mpr
              ((stavi_truth_mu_at_point (r := r) p_M D).mp hD_p_M)
          have hD_p_N_r2 : stavi_temporal_truth_mu N atomMap (r + 2) (extendPoint p_N) D :=
            hform_D.mp hD_p_M_r2
          have hD_p_N : stavi_temporal_truth N atomMap p_N D :=
            (stavi_truth_mu_at_point (r := r + 2) p_N D).mp hD_p_N_r2
          -- But ¬D(p_N) from _h_no_init.
          exact hpN_not_D hD_p_N⟩
      -- Step 3: Formula agreement ∀ A, depth A ≤ r → (A(γ_M) ↔ A(γ_N)).
      -- The chain: A(γ) ↔ left_formula(A,D)(m) (at the correct reference point)
      -- via left_formula_gap_detection, and left_formula truth transfers via hform_pts.
      -- By gap_detection_unique, γ_M is the UNIQUE D-left-definable gap above m_M,
      -- and γ_N is the unique one above m_N.
      -- Full proof requires careful handling of gap_detection_unique + D-between
      -- conditions on both sides. Deferred to dedicated sub-lemma.
      refine ⟨γ_M, hγ_M_in, ?_⟩
      intro A hA
      constructor
      · -- A(γ_M) → A(γ_N): left_formula backward at m_M, transfer, forward at m_N.
        intro hA_γM
        -- left_formula(A,D) at m_M, using γ_M as witness.
        have h_left_mM : stavi_temporal_truth_mu M atomMap r (extendPoint m_M)
            (left_formula A D) := by
          rw [left_formula_gap_detection A D hD_depth m_M]
          exact ⟨γ_M, hm_lt_γM, h_def_γM_left, h_D_bet_γM, hA_γM⟩
        -- Transfer to m_N via hform_pts
        have h_left_depth : stavi_depth (left_formula A D) ≤ r + 4 := by
          calc stavi_depth (left_formula A D) ≤ max (stavi_depth A) (stavi_depth D) + 4 :=
            stavi_depth_left_formula A D
          _ ≤ max r r + 4 := by omega
          _ = r + 4 := by omega
        have h_left_mN : stavi_temporal_truth_mu N atomMap r (extendPoint m_N)
            (left_formula A D) := (hform_pts (left_formula A D) h_left_depth).mp h_left_mM
        -- Extract γ from left_formula at m_N — must be γ_N by gap_detection_unique.
        rw [left_formula_gap_detection A D hD_depth m_N] at h_left_mN
        obtain ⟨γ_N', hm_lt_γN', h_def_γN', h_D_bet_γN', hA_γN'⟩ := h_left_mN
        -- γ_N' = γ_N by gap_detection_unique
        have hm_N_in_γN : m_N ∈ γ_N.val.cut := hm_N_cut
        have hm_N_in_γN' : m_N ∈ γ_N'.val.cut :=
          (extendPoint_le_gap_iff m_N γ_N').mp (le_of_lt hm_lt_γN')
        have h_D_bet_γN_std : ∀ u : N.carrier, m_N < u → u ∈ γ_N.val.cut →
            stavi_temporal_truth N atomMap u D := by
          intro u hmu hu_cut
          exact (stavi_truth_mu_at_point u D).mp (hm_N_D_between u hmu hu_cut)
        have h_D_bet_γN'_std : ∀ u : N.carrier, m_N < u → u ∈ γ_N'.val.cut →
            stavi_temporal_truth N atomMap u D := by
          intro u hmu hu_cut
          exact (stavi_truth_mu_at_point u D).mp (h_D_bet_γN' u hmu hu_cut)
        have h_gap_eq : γ_N.val = γ_N'.val :=
          gap_detection_unique h_left_orig h_def_γN'
            h_D_bet_γN_std h_D_bet_γN'_std hm_N_in_γN hm_N_in_γN'
        have h_eq : γ_N = γ_N' := Subtype.ext h_gap_eq
        rw [h_eq]; exact hA_γN'
      · -- A(γ_N) → A(γ_M): use hform_transfer to get γ_A, then γ_A = γ_M by uniqueness
        intro hA_γN
        obtain ⟨γ_A, hm_lt_γA, h_def_γA, h_D_bet_γA, hA_γA⟩ := hform_transfer A hA hA_γN
        -- γ_A = γ_M by gap_detection_unique: both D-left-definable above m_M.
        -- m_M ∈ γ_M.cut (from hm_lt_γM) and m_M ∈ γ_A.cut (from hm_lt_γA).
        have hm_M_in_γM : m_M ∈ γ_M.val.cut :=
          (extendPoint_le_gap_iff m_M γ_M).mp (le_of_lt hm_lt_γM)
        have hm_M_in_γA : m_M ∈ γ_A.val.cut :=
          (extendPoint_le_gap_iff m_M γ_A).mp (le_of_lt hm_lt_γA)
        -- D-between at m_M for γ_M: h_D_bet_γM, converted to stavi_temporal_truth
        have h_D_bet_γM' : ∀ u : M.carrier, m_M < u → u ∈ γ_M.val.cut →
            stavi_temporal_truth M atomMap u D := by
          intro u hmu hu_cut
          exact (stavi_truth_mu_at_point u D).mp (h_D_bet_γM u hmu hu_cut)
        have h_D_bet_γA' : ∀ u : M.carrier, m_M < u → u ∈ γ_A.val.cut →
            stavi_temporal_truth M atomMap u D := by
          intro u hmu hu_cut
          exact (stavi_truth_mu_at_point u D).mp (h_D_bet_γA u hmu hu_cut)
        have h_gap_eq : γ_M.val = γ_A.val :=
          gap_detection_unique h_def_γM_left h_def_γA h_D_bet_γM' h_D_bet_γA'
            hm_M_in_γM hm_M_in_γA
        -- γ_M = γ_A as subtypes
        have h_eq : γ_M = γ_A := Subtype.ext h_gap_eq
        rw [h_eq]; exact hA_γA
    · -- RIGHT CASE: γ_N is D-definable on the right.
      -- Symmetric to the left case, using right_formula_gap_detection.
      -- S11.1a: Get reference point m_N (above γ_N, in complement).
      have h_right_orig := h_right
      obtain ⟨⟨t_N, ht_N_not_cut, hD_below_t⟩, _h_no_final⟩ := h_right
      have hγ_N_in : inClosedInterval x' y' (Sum.inr γ_N) := by
        rw [← hγ_N_eq]; exact ha_bwd ⟨n, by omega⟩
      -- t_N ∉ γ_N.cut means extendPoint t_N > Sum.inr γ_N.
      have ht_N_gt_γ : (extendPoint t_N : ExtendedCarrier N atomMap r) >
          Sum.inr γ_N :=
        lt_of_not_le (fun h => ht_N_not_cut ((extendPoint_le_gap_iff t_N γ_N).mp h))
      -- D-between for right case: D at complement elements below m_N.
      have hD_between_any : ∀ (m : N.carrier), m ≤ t_N → m ∉ γ_N.val.cut →
          (∀ u : N.carrier, u < m → u ∉ γ_N.val.cut →
            stavi_temporal_truth_mu N atomMap r (extendPoint u) D) := by
        intro m htm hm_not_cut u hum hu_not_cut
        exact (stavi_truth_mu_at_point u D).mpr
          (hD_below_t u hu_not_cut (le_trans (le_of_lt hum) htm))
      -- Degenerate boundary check: if y' = Sum.inr γ_N, all complement elements
      -- are above γ_N and hence above y', so no reference point m_N exists.
      -- Handle via forward game endpoint agreement or hcd_form.
      if hy'_eq_γ : y' = (Sum.inr γ_N : ExtendedCarrier N atomMap r) then
        -- DEGENERATE RIGHT BOUNDARY: y' = Sum.inr γ_N.
        -- Sub-case on h_pt_cy to determine the approach.
        rcases props.h_pt_cy with ⟨p_cy, hp_cy⟩ | ⟨hcy_eq, hdy'_eq, hgap_c, _hgap_d⟩
        · -- Carrier point p_cy ∈ [c, y]. Use tau sub-game endpoint agreement.
          -- The tau sub-game G_{n;r+delta}(N, d y'; M, c y) on rank-embedded
          -- positions. Phase R3 will project to rank r.
          -- Phase R2: tau at r+delta. Phase R3 will project to rank r.
          have h_tau_0 : ghr93_duplicator_wins N M atomMap 0 r d y' c y := by sorry
          obtain ⟨_a'_tau0, _ha'_tau0_in, hwin_tau0⟩ := h_tau_0
            (fun i => Fin.elim0 i) (fun i => Fin.elim0 i)
          obtain ⟨b_tau0, _hb_tau0_in, hcond_tau0⟩ := hwin_tau0 p_cy hp_cy
          obtain ⟨_hord_tau0, hgp_tau0, hform_tau0⟩ := hcond_tau0
          -- Extract gap/point + formula agreement at y ↔ y' (endpoint positions).
          -- game_tuple has 0+3 = 3 positions: pos 0 = d/c, pos 1 = b/b', pos 2 = y'/y.
          have hgp_y : (IsPoint y ↔ IsPoint y') ∧ (IsGap y ↔ IsGap y') := by
            have h := hgp_tau0 ⟨0 + 2, by omega⟩
            simp only [game_tuple_y_eq] at h; exact ⟨h.1.symm, h.2.symm⟩
          obtain ⟨g_y_M, hy_eq⟩ := hgp_y.2.mpr ⟨γ_N, hy'_eq_γ⟩
          exact ⟨g_y_M, ⟨hy_eq ▸ hxy, hy_eq ▸ le_refl y⟩,
            fun A hA => by
              have h := hform_tau0 ⟨0 + 2, by omega⟩ A hA
              simp only [game_tuple_y_eq] at h
              rw [hy_eq] at h; rw [hy'_eq_γ] at h; exact h.symm⟩
        · -- c = y, d = y', both gaps. Use hcd_form directly.
          have hd_eq_γN : d = Sum.inr γ_N := by rw [hdy'_eq, hy'_eq_γ]
          obtain ⟨g_c, hc_eq⟩ := hgap_c
          exact ⟨g_c, ⟨hc_eq ▸ hcy_eq ▸ hxy, hc_eq ▸ hcy_eq ▸ le_refl y⟩,
            fun A hA => by
              have h := props.hcd_form A hA
              rw [hc_eq] at h; rw [hd_eq_γN] at h; exact h⟩
      else
      -- NON-DEGENERATE: y' ≠ Sum.inr γ_N, hence Sum.inr γ_N < y'.
      have hγ_ne_y' : (Sum.inr γ_N : ExtendedCarrier N atomMap r) ≠ y' :=
        fun h => hy'_eq_γ h.symm
      -- Find m_N: a complement element below y' with D-between condition.
      -- Case split: either t_N is already below y', or we need a lower element.
      have ⟨m_N, hm_N_not_cut, hm_N_below_y', hm_N_D_between⟩ :
          ∃ (m_N : N.carrier), m_N ∉ γ_N.val.cut ∧
            (extendPoint m_N : ExtendedCarrier N atomMap r) ≤ y' ∧
            (∀ u : N.carrier, u < m_N → u ∉ γ_N.val.cut →
              stavi_temporal_truth_mu N atomMap r (extendPoint u) D) := by
        rcases le_or_gt (extendPoint t_N : ExtendedCarrier N atomMap r) y' with ht_le | ht_gt
        · exact ⟨t_N, ht_N_not_cut, ht_le, hD_between_any t_N le_rfl ht_N_not_cut⟩
        · -- extendPoint t_N > y'. Need a complement element below y'.
          -- Since Sum.inr γ_N ≤ y' < extendPoint t_N, and the complement
          -- has no minimum (complement_no_min), we can find one.
          -- Strategy: case split on y' being a point or gap.
          rcases isPoint_or_isGap y' with ⟨p_y, hpy_eq⟩ | ⟨g_y, hgy_eq⟩
          · -- y' is a point p_y. Since Sum.inr γ_N ≤ y' = extendPoint p_y,
            -- p_y ∈ γ_N.cut OR p_y ∉ γ_N.cut.
            -- If p_y ∉ γ_N.cut, use p_y directly.
            -- If p_y ∈ γ_N.cut, then extendPoint p_y ≤ Sum.inr γ_N.
            -- But Sum.inr γ_N ≤ y' = extendPoint p_y, so extendPoint p_y = Sum.inr γ_N.
            -- That's impossible (Sum.inl p_y ≠ Sum.inr γ_N by Sum disjointness).
            have hp_not_cut : p_y ∉ γ_N.val.cut := by
              intro h_in
              -- p_y ∈ cut means extendPoint p_y ≤ Sum.inr γ_N.
              -- But Sum.inr γ_N ≤ y' = extendPoint p_y (= Sum.inl p_y).
              -- Sum.inl p_y ≤ Sum.inr γ_N and Sum.inr γ_N ≤ Sum.inl p_y
              -- gives Sum.inl = Sum.inr, impossible.
              have h1 := (extendPoint_le_gap_iff p_y γ_N).mpr h_in
              -- h1 : extendPoint p_y ≤ Sum.inr γ_N (in ExtendedCarrier)
              have h2 := hγ_N_in.2
              -- h2 : Sum.inr γ_N ≤ y'
              rw [hpy_eq] at h2
              -- h2 : Sum.inr γ_N ≤ extendPoint p_y (= Sum.inl p_y)
              exact absurd (le_antisymm h1 h2) (fun h => by cases h)
            have hpy_le : (extendPoint p_y : ExtendedCarrier N atomMap r) ≤ y' := by
              rw [hpy_eq]; exact le_refl _
            -- p_y ≤ t_N (since extendPoint p_y = y' < extendPoint t_N)
            have ht_ge_p : p_y ≤ t_N :=
              le_of_lt ((extendPoint_lt_iff p_y t_N).mp (hpy_eq ▸ ht_gt))
            exact ⟨p_y, hp_not_cut, hpy_le,
              hD_between_any p_y ht_ge_p hp_not_cut⟩
          · -- y' is a gap g_y. Since Sum.inr γ_N ≤ y' = Sum.inr g_y,
            -- γ_N.cut ⊆ g_y.cut. Since t_N ∉ γ_N.cut and extendPoint t_N > y',
            -- t_N is above both gaps.
            -- The complement of γ_N has no minimum (complement_no_min).
            -- But we need a complement element below y' = Sum.inr g_y.
            -- Since Sum.inr γ_N ≤ Sum.inr g_y, γ_N.cut ⊆ g_y.cut.
            -- If γ_N.cut = g_y.cut, then γ_N = g_y (gaps with same cut).
            -- Then y' = Sum.inr γ_N, and Sum.inr γ_N < extendPoint t_N.
            -- Elements NOT in γ_N.cut with extendPoint ≤ y' = Sum.inr γ_N would
            -- require extendPoint m ≤ Sum.inr γ_N and m ∉ cut. But m ∉ cut means
            -- extendPoint m > Sum.inr γ_N. Contradiction.
            -- If γ_N.cut ⊊ g_y.cut, there's m ∈ g_y.cut \ γ_N.cut.
            -- Then m ∉ γ_N.cut and extendPoint m ≤ Sum.inr g_y = y'.
            -- m ≤ t_N follows from m ∉ γ_N.cut and D-below argument.
            have hg_y_sub : γ_N.val.cut ⊆ g_y.val.cut := by
              rw [hgy_eq] at hγ_N_in; exact hγ_N_in.2
            rcases eq_or_ne γ_N.val.cut g_y.val.cut with h_eq_cut | h_ne_cut
            · -- γ_N.cut = g_y.cut, so γ_N = g_y. Then y' = Sum.inr γ_N.
              -- This contradicts hy'_eq_γ from the outer non-degenerate case split.
              exfalso
              have h_gap_eq := gap_ext γ_N.val g_y.val h_eq_cut
              have hy'_eq : y' = (Sum.inr γ_N : ExtendedCarrier N atomMap r) := by
                rw [hgy_eq]; congr 1; exact Subtype.ext h_gap_eq.symm
              exact absurd hy'_eq hy'_eq_γ
            · -- γ_N.cut ⊊ g_y.cut. Find m ∈ g_y.cut \ γ_N.cut.
              have h_diff : ∃ m0, m0 ∈ g_y.val.cut ∧ m0 ∉ γ_N.val.cut := by
                by_contra h_all; push_neg at h_all
                exact h_ne_cut (Set.Subset.antisymm hg_y_sub (fun x hx => h_all x hx))
              obtain ⟨m0, hm0_gy, hm0_not_γ⟩ := h_diff
              -- m0 ∈ g_y.cut means extendPoint m0 ≤ Sum.inr g_y = y'.
              have hm0_le_y' : (extendPoint m0 : ExtendedCarrier N atomMap r) ≤ y' := by
                rw [hgy_eq]; exact (extendPoint_le_gap_iff m0 g_y).mpr hm0_gy
              -- m0 ≤ t_N (since both are ∉ γ_N.cut, and D holds at complement
              -- elements ≤ t_N). Actually we need m0 ≤ t_N for D-between.
              -- m0 ∉ γ_N.cut and t_N ∉ γ_N.cut. Both are complement elements.
              -- We need m0 ≤ t_N. Since extendPoint m0 ≤ y' < extendPoint t_N,
              -- m0 < t_N (for carrier points, extendPoint preserves order).
              have htm : m0 ≤ t_N := by
                rcases le_or_gt m0 t_N with h | h
                · exact h
                · -- m0 > t_N, so extendPoint m0 > extendPoint t_N > y'. Contradiction.
                  exfalso
                  have : (extendPoint t_N : ExtendedCarrier N atomMap r) <
                      extendPoint m0 :=
                    (extendPoint_lt_iff t_N m0).mpr h
                  exact not_le.mpr (lt_trans ht_gt this) hm0_le_y'
              exact ⟨m0, hm0_not_γ, hm0_le_y',
                hD_between_any m0 htm hm0_not_γ⟩
      -- m_N is in [x', y']: Sum.inr γ_N < extendPoint m_N and extendPoint m_N ≤ y'.
      have hm_N_gt_γ : (extendPoint m_N : ExtendedCarrier N atomMap r) > Sum.inr γ_N :=
        lt_of_not_le (fun h => hm_N_not_cut ((extendPoint_le_gap_iff m_N γ_N).mp h))
      have hm_N_in : inClosedInterval x' y' (extendPoint m_N) :=
        ⟨le_of_lt (lt_of_le_of_lt hγ_N_in.1 hm_N_gt_γ), hm_N_below_y'⟩
      -- S11.1b: Forward game at rank r+4 — challenge with m_N to get m_M.
      have h_fwd_1 : ghr93_duplicator_wins M N atomMap 1 (r + 4)
          (rank_embed (by omega : r ≤ r + 4) x)
          (rank_embed (by omega : r ≤ r + 4) y)
          (rank_embed (by omega : r ≤ r + 4) x')
          (rank_embed (by omega : r ≤ r + 4) y') := by
        exact ghr93_duplicator_wins_round_mono (by omega : 1 ≤ 4 + 3 * n)
          ((rank_embed_le _ x y).mpr hxy) ((rank_embed_le _ x' y').mpr hx'y') h_fwd_r3
      have hc_in_re : inClosedInterval (rank_embed (by omega : r ≤ r + 4) x)
          (rank_embed (by omega : r ≤ r + 4) y)
          (rank_embed (by omega : r ≤ r + 4) c) := by
        exact ⟨(rank_embed_le _ x c).mpr props.hxc, (rank_embed_le _ c y).mpr props.hcy⟩
      obtain ⟨a'_1, ha'_1_in, hwin_1⟩ := h_fwd_1
        (fun _ : Fin 1 => rank_embed (by omega : r ≤ r + 4) c)
        (fun _ => hc_in_re)
      have hm_N_in_re : inClosedInterval
          (rank_embed (by omega : r ≤ r + 4) x')
          (rank_embed (by omega : r ≤ r + 4) y')
          (extendPoint m_N) := by
        rw [show (extendPoint m_N : ExtendedCarrier N atomMap (r + 4)) =
            rank_embed (by omega : r ≤ r + 4) (extendPoint m_N) from
            (rank_embed_point (by omega : r ≤ r + 4) m_N).symm]
        exact ⟨(rank_embed_le _ x' (extendPoint m_N)).mpr hm_N_in.1,
               (rank_embed_le _ (extendPoint m_N) y').mpr hm_N_in.2⟩
      obtain ⟨m_M, hm_M_in_re, hcond_1⟩ := hwin_1 m_N hm_N_in_re
      obtain ⟨_hord_1, _hgp_1, hform_1⟩ := hcond_1
      -- Formula agreement at carrier points m_M vs m_N.
      have hform_mM_mN : ∀ (A : StaviFormula), stavi_depth A ≤ r + 4 →
          (stavi_temporal_truth_mu M atomMap (r + 4) (extendPoint m_M) A ↔
           stavi_temporal_truth_mu N atomMap (r + 4) (extendPoint m_N) A) := by
        intro A hA
        have h := hform_1 ⟨1 + 1, by omega⟩ A hA
        simp only [game_tuple_b_eq] at h; exact h
      have hform_pts : ∀ (A : StaviFormula), stavi_depth A ≤ r + 4 →
          (stavi_temporal_truth_mu M atomMap r (extendPoint m_M) A ↔
           stavi_temporal_truth_mu N atomMap r (extendPoint m_N) A) := by
        intro A hA
        constructor
        · intro h
          exact (stavi_truth_mu_at_point (r := r) m_N A).mpr
            ((stavi_truth_mu_at_point (r := r + 4) m_N A).mp
              ((hform_mM_mN A hA).mp
                ((stavi_truth_mu_at_point (r := r + 4) m_M A).mpr
                  ((stavi_truth_mu_at_point (r := r) m_M A).mp h))))
        · intro h
          exact (stavi_truth_mu_at_point (r := r) m_M A).mpr
            ((stavi_truth_mu_at_point (r := r + 4) m_M A).mp
              ((hform_mM_mN A hA).mpr
                ((stavi_truth_mu_at_point (r := r + 4) m_N A).mpr
                  ((stavi_truth_mu_at_point (r := r) m_N A).mp h))))
      have hm_M_in : inClosedInterval x y (extendPoint m_M) := by
        have h_lo := hm_M_in_re.1
        have h_hi := hm_M_in_re.2
        rw [← rank_embed_point (by omega : r ≤ r + 4) m_M] at h_lo h_hi
        exact ⟨(rank_embed_le _ x (extendPoint m_M)).mp h_lo,
               (rank_embed_le _ (extendPoint m_M) y).mp h_hi⟩
      -- Degenerate x' check: if x' = Sum.inr γ_N, the sub-interval game approach
      -- cannot find cut elements in [x', m_N] (all cut elements are below γ_N = x').
      -- Handle via sigma endpoint agreement or hcd_form.
      if hx'_eq_γ2 : x' = (Sum.inr γ_N : ExtendedCarrier N atomMap r) then
        -- x' = Sum.inr γ_N. Then d = Sum.inr γ_N = x'.
        have hd_le_γN : d ≤ (Sum.inr γ_N : ExtendedCarrier N atomMap r) :=
          hγ_N_eq ▸ h_no_split ⟨n, by omega⟩
        have hd_eq_γN : d = Sum.inr γ_N :=
          le_antisymm hd_le_γN (hx'_eq_γ2 ▸ props.hx'd)
        -- Use sigma 0-round game or hcd_form for x/x' endpoint agreement.
        rcases props.h_pt_xc with ⟨p_xc, hp_xc⟩ | ⟨hxc_eq, hx'd_eq, hgap_c, _hgap_d⟩
        · -- Carrier point p_xc ∈ [x, c]. Use sigma endpoint agreement.
          -- Phase R2: sigma at r+delta. Phase R3 will project to rank r.
          have h_sigma_0 : ghr93_duplicator_wins N M atomMap 0 r x' d x c := by sorry
          obtain ⟨_a'_sig0, _ha'_sig0_in, hwin_sig0⟩ := h_sigma_0
            (fun i => Fin.elim0 i) (fun i => Fin.elim0 i)
          obtain ⟨b_sig0, _hb_sig0_in, hcond_sig0⟩ := hwin_sig0 p_xc hp_xc
          obtain ⟨_hord_sig0, hgp_sig0, hform_sig0⟩ := hcond_sig0
          -- game_tuple for n=0 has 3 positions: pos 0 = x'/x, pos 1 = b/b', pos 2 = d/c.
          -- Extract gap/point + formula agreement at x ↔ x' (position 0).
          have hgp_x : (IsPoint x ↔ IsPoint x') ∧ (IsGap x ↔ IsGap x') := by
            have h := hgp_sig0 ⟨0, by omega⟩
            simp only [game_tuple_zero_eq] at h; exact ⟨h.1.symm, h.2.symm⟩
          obtain ⟨g_x_M, hx_eq⟩ := hgp_x.2.mpr ⟨γ_N, hx'_eq_γ2⟩
          exact ⟨g_x_M, ⟨hx_eq ▸ le_refl x, hx_eq ▸ hxy⟩,
            fun A hA => by
              have h := hform_sig0 ⟨0, by omega⟩ A hA
              simp only [game_tuple_zero_eq] at h
              rw [hx_eq] at h; rw [hx'_eq_γ2] at h; exact h.symm⟩
        · -- x = c, x' = d, both gaps. Use hcd_form directly.
          have hd_eq : d = x' := hx'd_eq.symm
          obtain ⟨g_c, hc_eq⟩ := hgap_c
          exact ⟨g_c, ⟨hc_eq ▸ hxc_eq ▸ le_refl x, hc_eq ▸ hxc_eq ▸ hxy⟩,
            fun A hA => by
              have h := props.hcd_form A hA
              rw [hc_eq] at h; rw [hd_eq_γN] at h; exact h⟩
      else
      -- NON-DEGENERATE x': x' < Sum.inr γ_N.
      have hx'_lt_γ2 : x' < (Sum.inr γ_N : ExtendedCarrier N atomMap r) :=
        lt_of_le_of_ne hγ_N_in.1 hx'_eq_γ2
      -- S11.1c: Gap detection transfer (right case).
      -- For each A with depth ≤ r, transfer A-truth at γ_N to matching gap in M.
      have hform_transfer : ∀ (A : StaviFormula), stavi_depth A ≤ r →
          stavi_temporal_truth_mu N atomMap r (Sum.inr γ_N) A →
          ∃ (γ_A : RDefinableGap M atomMap r),
            (extendPoint m_M : ExtendedCarrier M atomMap r) > Sum.inr γ_A ∧
            gap_definable_on_right M atomMap γ_A.val D ∧
            (∀ u : M.carrier, u < m_M → u ∉ γ_A.val.cut →
              stavi_temporal_truth_mu M atomMap r (extendPoint u) D) ∧
            stavi_temporal_truth_mu M atomMap r (Sum.inr γ_A) A := by
        intro A hA hA_γN
        have h_right_N : stavi_temporal_truth_mu N atomMap r (extendPoint m_N)
            (right_formula A D) := by
          rw [right_formula_gap_detection A D hD_depth m_N]
          exact ⟨γ_N, hm_N_gt_γ, h_right_orig, hm_N_D_between, hA_γN⟩
        have h_right_depth : stavi_depth (right_formula A D) ≤ r + 4 := by
          calc stavi_depth (right_formula A D) ≤ max (stavi_depth A) (stavi_depth D) + 4 :=
            stavi_depth_right_formula A D
          _ ≤ max r r + 4 := by omega
          _ = r + 4 := by omega
        have h_right_M : stavi_temporal_truth_mu M atomMap r (extendPoint m_M)
            (right_formula A D) := (hform_pts (right_formula A D) h_right_depth).mpr h_right_N
        rw [right_formula_gap_detection A D hD_depth m_M] at h_right_M
        obtain ⟨γ_A, hm_gt_γA, h_def_A, h_D_bet_A, hA_γA⟩ := h_right_M
        exact ⟨γ_A, hm_gt_γA, h_def_A, h_D_bet_A, hA_γA⟩
      -- Instantiate with sf_verum to get γ_M.
      have h_verum_γN : stavi_temporal_truth_mu N atomMap r (Sum.inr γ_N) sf_verum := by
        simp [sf_verum, stavi_temporal_truth_mu, temporal_truth_mu]
      obtain ⟨γ_M, hm_gt_γM, h_def_γM_right, h_D_bet_γM, _⟩ :=
        hform_transfer sf_verum (by rw [stavi_depth_sf_verum]; omega) h_verum_γN
      -- γ_M ∈ [x, y].
      -- Upper bound: extendPoint m_M > Sum.inr γ_M, trivial.
      -- Lower bound: x ≤ Sum.inr γ_M by contradiction using sub-interval game.
      -- Since x' < Sum.inr γ_N (non-degenerate), find p_N ∈ γ_N.cut with ¬D(p_N)
      -- in [x', m_N] via _h_no_final. Play sub-interval forward game on [x, m_M] vs
      -- [x', m_N] to get p_M with p_M < m_M (order agreement).
      -- Then h_D_bet_γM gives D(p_M), but formula agreement gives ¬D(p_M). ⊥
      have hγ_M_in : inClosedInterval x y (Sum.inr γ_M) :=
        ⟨by
          by_contra h_not_le; push_neg at h_not_le
          -- h_not_le : Sum.inr γ_M < x
          -- Step 2a: Find cut element t₀ of γ_N with x' ≤ extendPoint t₀.
          have ⟨t₀, ht₀_in_cut, ht₀_ge_x'⟩ : ∃ t₀ : N.carrier, t₀ ∈ γ_N.val.cut ∧
              x' ≤ (extendPoint t₀ : ExtendedCarrier N atomMap r) := by
            rcases isPoint_or_isGap x' with ⟨p_x', hp_eq⟩ | ⟨g_x', hg_eq⟩
            · -- x' is a point p_x' below γ_N.
              have hp_cut : p_x' ∈ γ_N.val.cut := by
                rw [hp_eq] at hx'_lt_γ2
                exact (extendPoint_le_gap_iff p_x' γ_N).mp (le_of_lt hx'_lt_γ2)
              obtain ⟨m₀, hm₀_cut, hp_lt_m₀⟩ := gap_cut_exists_gt γ_N.val p_x' hp_cut
              exact ⟨m₀, hm₀_cut, le_of_lt (hp_eq ▸ (extendPoint_lt_iff p_x' m₀).mpr hp_lt_m₀)⟩
            · -- x' is a gap g_x' with g_x'.cut ⊂ γ_N.cut.
              have hg_sub : g_x'.val.cut ⊆ γ_N.val.cut := by
                show extendedLE (Sum.inr g_x') (Sum.inr γ_N)
                have : extendedLE x' (Sum.inr γ_N) := le_of_lt hx'_lt_γ2
                rwa [hg_eq] at this
              have hg_ne : g_x'.val.cut ≠ γ_N.val.cut := by
                intro heq
                have : x' = (Sum.inr γ_N : ExtendedCarrier N atomMap r) := by
                  rw [hg_eq]; exact congr_arg Sum.inr (Subtype.ext (gap_ext g_x'.val γ_N.val heq))
                exact hx'_eq_γ2 this
              obtain ⟨m₀, hm₀_cut, hm₀_not_gx⟩ := by
                have : ¬γ_N.val.cut ⊆ g_x'.val.cut := by
                  intro h_sub; exact hg_ne (Set.Subset.antisymm hg_sub h_sub)
                exact Set.not_subset.mp this
              have hx'_le_m₀ : x' ≤ (extendPoint m₀ : ExtendedCarrier N atomMap r) := by
                rw [hg_eq]
                exact le_of_lt (@lt_of_not_le (ExtendedCarrier N atomMap r) _ _ _
                  (fun h => hm₀_not_gx ((extendPoint_le_gap_iff m₀ g_x').mp h)))
              exact ⟨m₀, hm₀_cut, hx'_le_m₀⟩
          -- Step 2b: Apply _h_no_final to get p_N ∈ γ_N.cut with ¬D(p_N).
          push_neg at _h_no_final
          obtain ⟨p_N, hp_N_ge, hp_N_in_cut, hpN_not_D⟩ := _h_no_final t₀ ht₀_in_cut
          -- Step 2c: Show p_N < m_N (cut membership vs complement).
          -- p_N ∈ γ_N.cut, m_N ∉ γ_N.cut. If p_N ≥ m_N, then m_N ≤ p_N ∈ cut,
          -- by downward closure m_N ∈ cut. Contradiction.
          have hp_N_lt_m_N : p_N < m_N := by
            by_contra h_not_lt; push_neg at h_not_lt
            exact hm_N_not_cut (γ_N.val.downward_closed p_N m_N hp_N_in_cut h_not_lt)
          -- Step 2d: p_N ∈ [x', m_N] at rank r.
          have hp_N_ge_x' : x' ≤ (extendPoint p_N : ExtendedCarrier N atomMap r) :=
            le_trans ht₀_ge_x' ((extendPoint_le_iff t₀ p_N).mpr hp_N_ge)
          -- Step 2e: Sub-interval forward game on [x, m_M] vs [x', m_N] via h_r1_univ.
          -- Instantiate at r' = r to get game at rank r+2.
          have h_sub_raw := h_r1_univ r
            (show x ≤ (extendPoint m_M : ExtendedCarrier M atomMap r) from hm_M_in.1)
            (show x' ≤ (extendPoint m_N : ExtendedCarrier N atomMap r) from hm_N_in.1)
          have h_sub_1 : ghr93_duplicator_wins M N atomMap 1 (r + 2)
              (rank_embed (show r ≤ r + 2 by omega) x)
              (rank_embed (show r ≤ r + 2 by omega) (extendPoint m_M : ExtendedCarrier M atomMap r))
              (rank_embed (show r ≤ r + 2 by omega) x')
              (rank_embed (show r ≤ r + 2 by omega) (extendPoint m_N : ExtendedCarrier N atomMap r)) :=
            ghr93_duplicator_wins_round_mono (show 1 ≤ 4 + 3 * n by omega)
              ((rank_embed_le _ x (extendPoint m_M)).mpr hm_M_in.1)
              ((rank_embed_le _ x' (extendPoint m_N)).mpr hm_N_in.1)
              h_sub_raw
          -- M selects rank_embed(extendPoint m_M) as its single selection.
          have hm_M_in_sub : inClosedInterval
              (rank_embed (show r ≤ r + 2 by omega) x)
              (rank_embed (show r ≤ r + 2 by omega) (extendPoint m_M : ExtendedCarrier M atomMap r))
              (rank_embed (show r ≤ r + 2 by omega) (extendPoint m_M : ExtendedCarrier M atomMap r)) :=
            ⟨(rank_embed_le _ x (extendPoint m_M)).mpr hm_M_in.1, le_refl _⟩
          obtain ⟨a'_sub, _ha'_sub_in, hwin_sub⟩ := h_sub_1
            (fun _ : Fin 1 => rank_embed (show r ≤ r + 2 by omega)
              (extendPoint m_M : ExtendedCarrier M atomMap r))
            (fun _ => hm_M_in_sub)
          -- Challenge with p_N.
          have hp_N_in_sub : inClosedInterval
              (rank_embed (show r ≤ r + 2 by omega) x')
              (rank_embed (show r ≤ r + 2 by omega) (extendPoint m_N : ExtendedCarrier N atomMap r))
              (extendPoint p_N : ExtendedCarrier N atomMap (r + 2)) := by
            rw [← rank_embed_point (show r ≤ r + 2 by omega) p_N]
            exact ⟨(rank_embed_le _ x' (extendPoint p_N)).mpr hp_N_ge_x',
                   (rank_embed_le _ (extendPoint p_N) (extendPoint m_N)).mpr
                    ((extendPoint_le_iff p_N m_N).mpr (le_of_lt hp_N_lt_m_N))⟩
          obtain ⟨p_M, hp_M_in_sub, hcond_sub⟩ := hwin_sub p_N hp_N_in_sub
          obtain ⟨hord_sub, _hgp_sub, hform_sub⟩ := hcond_sub
          -- Step 2f: Order agreement at positions (0, 2) gives p_M < m_M.
          -- game_tuple: pos 0 = x/x', pos 1 = m_M/a'_sub(0), pos 2 = p_M/p_N, pos 3 = m_M/m_N.
          -- Use positions (2, 3): p_M < m_M ↔ p_N < m_N.
          have hord_2_3 := hord_sub ⟨1 + 1, by omega⟩ ⟨1 + 2, by omega⟩
          simp only [game_tuple_b_eq, game_tuple_y_eq] at hord_2_3
          -- N-side: extendPoint p_N < rank_embed(extendPoint m_N) at rank r+2.
          have hp_N_lt_m_N_r2 :
              (extendPoint p_N : ExtendedCarrier N atomMap (r + 2)) <
              rank_embed (show r ≤ r + 2 by omega) (extendPoint m_N : ExtendedCarrier N atomMap r) := by
            rw [show (extendPoint p_N : ExtendedCarrier N atomMap (r + 2)) =
                rank_embed (show r ≤ r + 2 by omega) (extendPoint p_N : ExtendedCarrier N atomMap r)
                from (rank_embed_point (show r ≤ r + 2 by omega) p_N).symm]
            rw [rank_embed_point (show r ≤ r + 2 by omega) p_N,
                rank_embed_point (show r ≤ r + 2 by omega) m_N]
            exact (extendPoint_lt_iff p_N m_N).mpr hp_N_lt_m_N
          -- Transfer: extendPoint p_M < rank_embed(extendPoint m_M) at rank r+2.
          have hp_M_lt_m_M_r2 :
              (extendPoint p_M : ExtendedCarrier M atomMap (r + 2)) <
              rank_embed (show r ≤ r + 2 by omega) (extendPoint m_M : ExtendedCarrier M atomMap r) :=
            hord_2_3.1.mpr hp_N_lt_m_N_r2
          -- Step 2g: p_M < m_M at rank r.
          have hp_M_lt_m_M_r : p_M < m_M := by
            rw [show (extendPoint p_M : ExtendedCarrier M atomMap (r + 2)) =
                  rank_embed (show r ≤ r + 2 by omega) (extendPoint p_M : ExtendedCarrier M atomMap r)
                  from (rank_embed_point (show r ≤ r + 2 by omega) p_M).symm,
                rank_embed_point (show r ≤ r + 2 by omega) p_M,
                rank_embed_point (show r ≤ r + 2 by omega) m_M] at hp_M_lt_m_M_r2
            exact (extendPoint_lt_iff p_M m_M).mp hp_M_lt_m_M_r2
          -- Step 2h: p_M ∉ γ_M.cut (since x ≤ extendPoint p_M and x > Sum.inr γ_M).
          -- Actually: extendPoint p_M ≥ x > Sum.inr γ_M, so p_M ∉ γ_M.cut.
          have hp_M_ge_x : x ≤ (extendPoint p_M : ExtendedCarrier M atomMap r) := by
            have h_bound := hp_M_in_sub.1
            rw [show (extendPoint p_M : ExtendedCarrier M atomMap (r + 2)) =
                  rank_embed (show r ≤ r + 2 by omega) (extendPoint p_M : ExtendedCarrier M atomMap r)
                  from (rank_embed_point (show r ≤ r + 2 by omega) p_M).symm] at h_bound
            exact (rank_embed_le _ x (extendPoint p_M)).mp h_bound
          have hp_M_not_cut : p_M ∉ γ_M.val.cut := by
            intro h_in
            have : (extendPoint p_M : ExtendedCarrier M atomMap r) ≤ Sum.inr γ_M :=
              (extendPoint_le_gap_iff p_M γ_M).mpr h_in
            exact not_le.mpr h_not_le (le_trans hp_M_ge_x this)
          -- Step 2i: D(p_M) from h_D_bet_γM.
          have hD_p_M : stavi_temporal_truth_mu M atomMap r (extendPoint p_M) D :=
            h_D_bet_γM p_M hp_M_lt_m_M_r hp_M_not_cut
          -- Step 2j: Formula agreement at position 2 gives ¬D(p_M).
          have hform_D := hform_sub ⟨1 + 1, by omega⟩ D (by omega : stavi_depth D ≤ r + 2)
          simp only [game_tuple_b_eq] at hform_D
          have hD_p_M_r2 : stavi_temporal_truth_mu M atomMap (r + 2) (extendPoint p_M) D :=
            (stavi_truth_mu_at_point (r := r + 2) p_M D).mpr
              ((stavi_truth_mu_at_point (r := r) p_M D).mp hD_p_M)
          have hD_p_N_r2 : stavi_temporal_truth_mu N atomMap (r + 2) (extendPoint p_N) D :=
            hform_D.mp hD_p_M_r2
          have hD_p_N : stavi_temporal_truth N atomMap p_N D :=
            (stavi_truth_mu_at_point (r := r + 2) p_N D).mp hD_p_N_r2
          exact hpN_not_D hD_p_N,
         le_of_lt (lt_of_lt_of_le hm_gt_γM hm_M_in.2)⟩
      -- Formula agreement.
      refine ⟨γ_M, hγ_M_in, ?_⟩
      intro A hA
      constructor
      · -- A(γ_M) → A(γ_N): right_formula backward at m_M, transfer, forward at m_N.
        intro hA_γM
        have h_right_mM : stavi_temporal_truth_mu M atomMap r (extendPoint m_M)
            (right_formula A D) := by
          rw [right_formula_gap_detection A D hD_depth m_M]
          exact ⟨γ_M, hm_gt_γM, h_def_γM_right, h_D_bet_γM, hA_γM⟩
        have h_right_depth : stavi_depth (right_formula A D) ≤ r + 4 := by
          calc stavi_depth (right_formula A D) ≤ max (stavi_depth A) (stavi_depth D) + 4 :=
            stavi_depth_right_formula A D
          _ ≤ max r r + 4 := by omega
          _ = r + 4 := by omega
        have h_right_mN : stavi_temporal_truth_mu N atomMap r (extendPoint m_N)
            (right_formula A D) := (hform_pts (right_formula A D) h_right_depth).mp h_right_mM
        rw [right_formula_gap_detection A D hD_depth m_N] at h_right_mN
        obtain ⟨γ_N', hm_gt_γN', h_def_γN', h_D_bet_γN', hA_γN'⟩ := h_right_mN
        -- γ_N' = γ_N by gap_detection_unique_right.
        have hm_N_not_γN : m_N ∉ γ_N.val.cut := hm_N_not_cut
        have hm_N_not_γN' : m_N ∉ γ_N'.val.cut := by
          intro h_in
          exact absurd ((extendPoint_le_gap_iff m_N γ_N').mpr h_in) (not_le.mpr hm_gt_γN')
        have h_D_bet_γN_std : ∀ u : N.carrier, u < m_N → u ∉ γ_N.val.cut →
            stavi_temporal_truth N atomMap u D := by
          intro u hmu hu_not
          exact (stavi_truth_mu_at_point u D).mp (hm_N_D_between u hmu hu_not)
        have h_D_bet_γN'_std : ∀ u : N.carrier, u < m_N → u ∉ γ_N'.val.cut →
            stavi_temporal_truth N atomMap u D := by
          intro u hmu hu_not
          exact (stavi_truth_mu_at_point u D).mp (h_D_bet_γN' u hmu hu_not)
        have h_gap_eq : γ_N.val = γ_N'.val :=
          gap_detection_unique_right h_right_orig h_def_γN'
            h_D_bet_γN_std h_D_bet_γN'_std hm_N_not_γN hm_N_not_γN'
        have h_eq : γ_N = γ_N' := Subtype.ext h_gap_eq
        rw [h_eq]; exact hA_γN'
      · -- A(γ_N) → A(γ_M): use hform_transfer, then uniqueness.
        intro hA_γN
        obtain ⟨γ_A, hm_gt_γA, h_def_γA, h_D_bet_γA, hA_γA⟩ := hform_transfer A hA hA_γN
        have hm_M_not_γM : m_M ∉ γ_M.val.cut := by
          intro h_in
          exact absurd ((extendPoint_le_gap_iff m_M γ_M).mpr h_in) (not_le.mpr hm_gt_γM)
        have hm_M_not_γA : m_M ∉ γ_A.val.cut := by
          intro h_in
          exact absurd ((extendPoint_le_gap_iff m_M γ_A).mpr h_in) (not_le.mpr hm_gt_γA)
        have h_D_bet_γM' : ∀ u : M.carrier, u < m_M → u ∉ γ_M.val.cut →
            stavi_temporal_truth M atomMap u D := by
          intro u hmu hu_not
          exact (stavi_truth_mu_at_point u D).mp (h_D_bet_γM u hmu hu_not)
        have h_D_bet_γA' : ∀ u : M.carrier, u < m_M → u ∉ γ_A.val.cut →
            stavi_temporal_truth M atomMap u D := by
          intro u hmu hu_not
          exact (stavi_truth_mu_at_point u D).mp (h_D_bet_γA u hmu hu_not)
        have h_gap_eq : γ_M.val = γ_A.val :=
          gap_detection_unique_right h_def_γM_right h_def_γA h_D_bet_γM' h_D_bet_γA'
            hm_M_not_γM hm_M_not_γA
        have h_eq : γ_M = γ_A := Subtype.ext h_gap_eq
        rw [h_eq]; exact hA_γA
  obtain ⟨γ_M, hγ_M_in, hγ_M_form⟩ := h_gap_match
  -- Sub-goal S11.2: gap/point agreement (both are gaps, so trivial).
  have hγ_gp : (IsPoint (Sum.inr γ_M : ExtendedCarrier M atomMap r) ↔
                 IsPoint (Sum.inr γ_N : ExtendedCarrier N atomMap r)) ∧
                (IsGap (Sum.inr γ_M : ExtendedCarrier M atomMap r) ↔
                 IsGap (Sum.inr γ_N : ExtendedCarrier N atomMap r)) := by
    exact ⟨⟨fun ⟨_, hp⟩ => absurd hp (by simp),
            fun ⟨_, hp⟩ => absurd hp (by simp)⟩,
           ⟨fun _ => ⟨γ_N, rfl⟩, fun _ => ⟨γ_M, rfl⟩⟩⟩
  -- Step 5b: Construct the response function a'_resp.
  -- Positions 0..n-1: use resp_tau. Position n: use Sum.inr γ_M.
  let a'_resp : Fin (n + 1) → ExtendedCarrier M atomMap r := fun i =>
    if h : i.val < n then resp_tau ⟨i.val, h⟩
    else Sum.inr γ_M
  -- Step 5c: All responses are in [x, y].
  have ha'_resp_in : ∀ i, inClosedInterval x y (a'_resp i) := by
    intro i; simp only [a'_resp]
    split
    case isTrue h =>
      have := hresp_tau_in ⟨i.val, h⟩
      exact ⟨le_trans props.hxc this.1, this.2⟩
    case isFalse _ => exact hγ_M_in
  -- Step 5d: Handle the point challenge and winning condition.
  refine ⟨a'_resp, ha'_resp_in, ?_⟩
  intro b_sp hb_sp_in
  -- Sub-goal S11.3: Point challenge + winning condition assembly.
  -- Strategy: Use the d-compatible forward game (h_d_compat_left) to
  -- get b_resp with cross-boundary orderings, then assemble the winning
  -- condition from tau sub-game + gap properties + forward game.
  --
  -- Key position mapping for game_tuple (n+1):
  --   game_tuple x' y' a_bwd b_resp has n+1+3 = n+4 positions:
  --     pos 0 = x', pos 1..n+1 = a_bwd(0..n), pos n+2 = b_resp, pos n+3 = y'
  --   game_tuple x y a'_resp b_sp has n+4 positions:
  --     pos 0 = x, pos 1..n = resp_tau(0..n-1), pos n+1 = γ_M,
  --     pos n+2 = b_sp, pos n+3 = y
  --
  -- Step S11.3a: Play d-compatible strategy to get b_resp and orderings.
  -- Pad the M-selections to 1+3*n+1 elements (resp_tau padded with c),
  -- apply h_d_compat_left, challenge with an N-point from [x', y'].
  -- This gives formula agreement + orderings between c/d and b_sp/b_resp.
  --
  -- Step S11.3b: Combine to get the full winning condition.
  -- For each pair (i,j) of positions 0..n+3:
  --   order:  from tau sub-game (for tau positions) + d-compat (for cross-boundary)
  --           + gap interval membership (for gap position)
  --   gp:     from tau sub-game (for tau positions) + S11.2 (for gap position)
  --           + point status (for b_sp/b_resp)
  --   form:   from tau sub-game (for tau positions) + S11.1 (for gap position)
  --           + d-compat forward game (for b_sp/b_resp and endpoints)
  --
  -- This mirrors the Case II assembly pattern (~200 lines) with the gap at
  -- position n+1 replacing the point e_n from Case II.
  sorry

/-- **Cases II-IV dispatcher**: When all selections lie in [d,y'],
    split on whether a_n is a point (Case II) or gap (Cases III-IV). -/
private theorem ghr93_cases_II_III_IV {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {n r delta : Nat}
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r}
    {d : ExtendedCarrier N atomMap r}
    {a_bwd : Fin (n + 1) → ExtendedCarrier N atomMap r}
    (props : SplitPointProps n delta x y x' y' c d a_bwd)
    (ha_bwd : ∀ i, inClosedInterval x' y' (a_bwd i))
    (h_no_split : ∀ i : Fin (n + 1), d ≤ a_bwd i)
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h_fwd_r1 : ghr93_duplicator_wins M N atomMap (4 + 3 * n) (r + 2)
      (rank_embed (by omega : r ≤ r + 2) x) (rank_embed (by omega : r ≤ r + 2) y)
      (rank_embed (by omega : r ≤ r + 2) x') (rank_embed (by omega : r ≤ r + 2) y'))
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
  rcases isPoint_or_isGap (a_bwd ⟨n, by omega⟩) with h_pt | h_gap
  · -- Case II: a_n is a point. With tau at r+delta, the full rank-r type
    -- formula transfer becomes available. Phase R3 will rewrite this.
    sorry
  · exact ghr93_cases_III_IV props ha_bwd h_no_split h_gap hxy hx'y' h_fwd_r1 h_r1_univ

/-! ### Assembly: The Inductive Step -/

/-- **GHR93 Theorem 6, inductive step**: combines the setup (split points
    c, d and sub-interval strategies σ, τ) with the 4-case analysis.

    This theorem is factored out of `ghr93_forward_to_backward` to keep
    the main proof clean and allow each case to be addressed independently.

    The `h_r1_univ` parameter provides rank-universal forward games (at any
    rank r'+2) needed by Cases III/IV for gap detection transfer at rank r+4. -/
theorem ghr93_inductive_step {sig : MonadicSignature}
    (atomMap : Formula → sig.preds) (n r delta : Nat)
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p))
    (h_pt_M : ∃ (p : M.carrier), inClosedInterval x y (extendPoint p))
    (ih : ∀ {x₀ y₀ : ExtendedCarrier M atomMap r}
            {x₀' y₀' : ExtendedCarrier N atomMap r},
          x₀ ≤ y₀ → x₀' ≤ y₀' →
          (∃ p, inClosedInterval x₀' y₀' (extendPoint p)) →
          ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x₀ y₀ x₀' y₀' →
          ghr93_duplicator_wins N M atomMap n (r + delta)
            (rank_embed (by omega : r ≤ r + delta) x₀')
            (rank_embed (by omega : r ≤ r + delta) y₀')
            (rank_embed (by omega : r ≤ r + delta) x₀)
            (rank_embed (by omega : r ≤ r + delta) y₀))
    (h_fwd : ghr93_duplicator_wins M N atomMap (4 + 3 * n) r x y x' y')
    (h_fwd_r1 : ghr93_duplicator_wins M N atomMap (4 + 3 * n) (r + 2)
      (rank_embed (by omega : r ≤ r + 2) x) (rank_embed (by omega : r ≤ r + 2) y)
      (rank_embed (by omega : r ≤ r + 2) x') (rank_embed (by omega : r ≤ r + 2) y'))
    (h_r1_univ : ∀ (r' : Nat) {x₁ y₁ : ExtendedCarrier M atomMap r'}
                   {x₁' y₁' : ExtendedCarrier N atomMap r'},
                 x₁ ≤ y₁ → x₁' ≤ y₁' →
                 ghr93_duplicator_wins M N atomMap (4 + 3 * n) (r' + 2)
                   (rank_embed (by omega : r' ≤ r' + 2) x₁)
                   (rank_embed (by omega : r' ≤ r' + 2) y₁)
                   (rank_embed (by omega : r' ≤ r' + 2) x₁')
                   (rank_embed (by omega : r' ≤ r' + 2) y₁')) :
    ghr93_duplicator_wins N M atomMap (n + 1) r x' y' x y := by
  -- Unfold the backward game
  unfold ghr93_duplicator_wins
  intro a_bwd ha_bwd
  -- GHR93 WLOG: sort Spoiler's selections so a_sorted is monotone.
  -- GHR93 p. 115 assumes sorted selections; the winning condition is
  -- permutation-invariant (ghr93_winning_condition_perm), so this is sound.
  let σ := Tuple.sort a_bwd
  let a_sorted : Fin (n + 1) → ExtendedCarrier N atomMap r := a_bwd ∘ σ
  have ha_sorted : ∀ i, inClosedInterval x' y' (a_sorted i) :=
    fun i => ha_bwd (σ i)
  have h_mono : Monotone a_sorted := Tuple.monotone_sort a_bwd
  -- Reduce to the sorted case: prove for a_sorted, transfer back to a_bwd.
  suffices h_sorted : ∃ (a'_resp : Fin (n + 1) → ExtendedCarrier M atomMap r),
      (∀ i, inClosedInterval x y (a'_resp i)) ∧
      ∀ (b_sp : M.carrier), inClosedInterval x y (extendPoint b_sp) →
        ∃ (b_resp : N.carrier), inClosedInterval x' y' (extendPoint b_resp) ∧
          ghr93_winning_condition (n + 1)
            (game_tuple x' y' a_sorted b_resp)
            (game_tuple x y a'_resp b_sp) by
    -- Transfer from sorted back to original via σ⁻¹
    obtain ⟨a'_resp_s, ha'_in_s, hwin_s⟩ := h_sorted
    refine ⟨a'_resp_s ∘ σ.symm, fun i => ha'_in_s (σ.symm i), ?_⟩
    intro b_sp hb_sp
    obtain ⟨b_resp, hb_resp_in, hcond_s⟩ := hwin_s b_sp hb_sp
    refine ⟨b_resp, hb_resp_in, ?_⟩
    -- a_sorted ∘ σ⁻¹ = a_bwd ∘ σ ∘ σ⁻¹ = a_bwd
    have h_unsort_N : a_sorted ∘ σ.symm = a_bwd := by
      ext i; simp [a_sorted, Function.comp]
    -- Apply ghr93_winning_condition_perm with σ⁻¹
    have h_perm := ghr93_winning_condition_perm a_sorted a'_resp_s b_resp b_sp
      σ.symm hcond_s
    rwa [h_unsort_N] at h_perm
  -- Now prove the theorem for sorted selections a_sorted.
  -- Obtain split points c, d and their properties (with delta for sigma/tau rank)
  obtain ⟨c, d, props⟩ :=
    obtain_split_point_props delta hxy hx'y' h_pt h_pt_M ih h_fwd h_fwd_r1 a_sorted ha_sorted
  -- Case split: does any selection fall strictly below d?
  by_cases h_split : ∃ i : Fin (n + 1), a_sorted i < d
  · -- Case I: at least one selection below d (the "split" case)
    exact ghr93_case_I props ha_sorted h_split
  · -- Cases II-IV: all selections are at or above d
    push_neg at h_split
    exact ghr93_cases_II_III_IV props ha_sorted h_split hxy hx'y' h_fwd_r1 h_r1_univ
      h_mono


end Bimodal.Metalogic.WeakCanonical
