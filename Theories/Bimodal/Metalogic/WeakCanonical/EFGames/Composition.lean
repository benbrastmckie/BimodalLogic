import Bimodal.Metalogic.WeakCanonical.EFGames.CustomGame

/-!
# GHR93 Proposition 7: Strategy Composition for EF Games

## References
- GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9, Proposition 7
- Task 155 plan: Phase 6A
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-! ## Pivot Transfer -/

/-- From (e < c ↔ e' < d) and (e = c ↔ e' = d), derive c < e ↔ d < e'. -/
private theorem pivot_flip {α β : Type*} [LinearOrder α] [LinearOrder β]
    {e : α} {e' : β} {c : α} {d : β}
    (hlt : e < c ↔ e' < d) (heq : e = c ↔ e' = d) :
    (c < e ↔ d < e') ∧ (c = e ↔ d = e') := by
  have aux1 : c < e → d < e' := by
    intro h
    rcases lt_trichotomy e' d with h' | h' | h'
    · exact absurd (hlt.mpr h') (not_lt.mpr (le_of_lt h))
    · exact absurd h (not_lt.mpr (le_of_eq (heq.mpr h')))
    · exact h'
  have aux2 : d < e' → c < e := by
    intro h
    rcases lt_trichotomy e c with h' | h' | h'
    · exact absurd (hlt.mp h') (not_lt.mpr (le_of_lt h))
    · exact absurd h (not_lt.mpr (le_of_eq (heq.mp h')))
    · exact h'
  exact ⟨⟨aux1, aux2⟩,
    ⟨fun h => (heq.mp h.symm).symm, fun h => (heq.mpr h.symm).symm⟩⟩

/-! ## Main Theorem -/

/-- **GHR93 Proposition 7**: Strategy composition for EF games. -/
theorem ghr93_strategy_compose {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {n r : Nat}
    {x y : ExtendedCarrier M atomMap r} {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r} {d : ExtendedCarrier N atomMap r}
    (hxc : x ≤ c) (hcy : c ≤ y) (hx'd : x' ≤ d) (hdy' : d ≤ y')
    (hcd_type : ∀ (A : StaviFormula), stavi_depth A ≤ r →
      (stavi_temporal_truth_mu M atomMap r c A ↔
       stavi_temporal_truth_mu N atomMap r d A))
    (hcd_gp : (IsPoint c ↔ IsPoint d) ∧ (IsGap c ↔ IsGap d))
    (h_compat_R : (¬∃ p : N.carrier, inClosedInterval d y'
        (extendPoint (sig := sig) (atomMap := atomMap) (r := r) p)) → c = y)
    (h_compat_L : (¬∃ p : N.carrier, inClosedInterval x' d
        (extendPoint (sig := sig) (atomMap := atomMap) (r := r) p)) → x = c)
    (h_left : ghr93_duplicator_wins M N atomMap n r x c x' d)
    (h_right : ghr93_duplicator_wins M N atomMap n r c y d y') :
    ghr93_duplicator_wins M N atomMap n r x y x' y' := by
  intro a ha
  -- Pad selections
  let a_L := fun i => if a i ≤ c then a i else c
  let a_R := fun i => if a i ≤ c then c else a i
  have ha_L : ∀ i, inClosedInterval x c (a_L i) := by
    intro i; simp only [a_L]; split <;> [exact ⟨(ha i).1, ‹_›⟩; exact ⟨hxc, le_refl c⟩]
  have ha_R : ∀ i, inClosedInterval c y (a_R i) := by
    intro i; simp only [a_R]; split
    · exact ⟨le_refl c, hcy⟩
    · exact ⟨le_of_lt (lt_of_not_ge ‹_›), (ha i).2⟩
  -- Apply sub-strategies
  obtain ⟨a'_L, ha'_L, hwin_L⟩ := h_left a_L ha_L
  obtain ⟨a'_R, ha'_R, hwin_R⟩ := h_right a_R ha_R
  -- Merge
  let a' := fun i => if a i ≤ c then a'_L i else a'_R i
  have ha' : ∀ i, inClosedInterval x' y' (a' i) := by
    intro i; simp only [a']; split
    · exact ⟨(ha'_L i).1, le_trans (ha'_L i).2 hdy'⟩
    · exact ⟨le_trans hx'd (ha'_R i).1, (ha'_R i).2⟩
  refine ⟨a', ha', ?_⟩
  -- Round 2
  intro b' hb'
  -- Get BOTH sub-strategies' winning conditions
  rcases le_or_gt (extendPoint (sig := sig) (atomMap := atomMap) (r := r) b') d with hb'd | hdb'
  · -- b' ≤ d: left side
    obtain ⟨b, hb_L, hcond_L⟩ := hwin_L b' ⟨hb'.1, hb'd⟩
    -- Need right side winning condition. Find point in [d, y'].
    rcases Classical.em (∃ p : N.carrier,
        inClosedInterval d y' (extendPoint (sig := sig) (atomMap := atomMap) (r := r) p))
      with ⟨p_R, hp_R⟩ | h_no_pt_R
    · obtain ⟨b_R, hb_R, hcond_R⟩ := hwin_R p_R hp_R
      have hL_eq : ∀ i, a i ≤ c → a_L i = a i := fun i h => by simp [a_L, h]
      have hR_eq : ∀ i, ¬(a i ≤ c) → a_R i = a i := fun i h => by simp [a_R, h]
      refine ⟨b, ⟨hb_L.1, le_trans hb_L.2 hcy⟩, ?_⟩
      show ghr93_winning_condition n (game_tuple x y a b)
        (game_tuple x' y' a' b')
      exact compose_wc hb_L.2 hxc hcy hx'd hdy' hcd_type hcd_gp
        a a_L a_R a'_L a'_R ha_L ha_R ha'_L ha'_R hL_eq hR_eq hcond_L hcond_R
    · -- Degenerate case: no point in [d, y'].
      -- Derive c = y from h_compat_R and d = y' from gap structure.
      -- Then all selections satisfy a i ≤ c, and the game tuples coincide
      -- with the left sub-game tuples, so hcond_L applies directly.
      have hcy_eq : c = y := h_compat_R h_no_pt_R
      have hdy_eq : d = y' := by
        by_contra hne
        have hlt : d < y' := lt_of_le_of_ne hdy' hne
        have hd_gap : IsGap d := by
          rcases isPoint_or_isGap d with ⟨p, hp⟩ | hg
          · have : extendPoint (sig := sig) (atomMap := atomMap) (r := r) p = d :=
              by rw [extendPoint]; exact hp.symm
            exact absurd ⟨p, this ▸ le_refl _, this ▸ hdy'⟩ h_no_pt_R
          · exact hg
        have hy'_gap : IsGap y' := by
          rcases isPoint_or_isGap y' with ⟨p, hp⟩ | hg
          · have : extendPoint (sig := sig) (atomMap := atomMap) (r := r) p = y' :=
              by rw [extendPoint]; exact hp.symm
            exact absurd ⟨p, this ▸ hdy', this ▸ le_refl _⟩ h_no_pt_R
          · exact hg
        obtain ⟨gd, hgd⟩ := hd_gap
        obtain ⟨gy', hgy'⟩ := hy'_gap
        exact h_no_pt_R (point_between_strict_gaps hgd hgy' hlt)
      -- All selections are LEFT (a i ≤ c since c = y)
      have ha_le_c : ∀ i, a i ≤ c := fun i => hcy_eq ▸ (ha i).2
      have haL_eq : ∀ i, a_L i = a i := fun i => by simp [a_L, ha_le_c i]
      have ha'_eq : ∀ i, a' i = a'_L i := fun i => by simp [a', ha_le_c i]
      -- The game tuples coincide with left sub-game tuples
      have hM_eq : game_tuple x y a b = game_tuple x c a_L b := by
        funext ⟨i, hi⟩; simp only [game_tuple]
        split
        · rfl
        case isFalse h0 =>
          split
          · rfl
          case isFalse hn1 =>
            split
            · exact hcy_eq.symm
            case isFalse hn2 => exact (haL_eq ⟨i - 1, by omega⟩).symm
      have hN_eq : game_tuple x' y' a' b' = game_tuple x' d a'_L b' := by
        funext ⟨i, hi⟩; simp only [game_tuple]
        split
        · rfl
        case isFalse h0 =>
          split
          · rfl
          case isFalse hn1 =>
            split
            · exact hdy_eq.symm
            case isFalse hn2 => exact ha'_eq ⟨i - 1, by omega⟩
      exact ⟨b, ⟨hb_L.1, hcy_eq ▸ hb_L.2⟩, hM_eq ▸ hN_eq ▸ hcond_L⟩
  · -- d < b': right side
    obtain ⟨b, hb_R, hcond_R⟩ := hwin_R b' ⟨le_of_lt hdb', hb'.2⟩
    rcases Classical.em (∃ p : N.carrier,
        inClosedInterval x' d (extendPoint (sig := sig) (atomMap := atomMap) (r := r) p))
      with ⟨p_L, hp_L⟩ | h_no_pt_L
    · obtain ⟨b_L, hb_L, hcond_L⟩ := hwin_L p_L hp_L
      have hL_eq : ∀ i, a i ≤ c → a_L i = a i := fun i h => by simp [a_L, h]
      have hR_eq : ∀ i, ¬(a i ≤ c) → a_R i = a i := fun i h => by simp [a_R, h]
      refine ⟨b, ⟨le_trans hxc hb_R.1, hb_R.2⟩, ?_⟩
      show ghr93_winning_condition n (game_tuple x y a b)
        (game_tuple x' y' a' b')
      exact compose_wc_right hb_R.1 hxc hcy hx'd hdy' hcd_type hcd_gp
        a a_L a_R a'_L a'_R ha_L ha_R ha'_L ha'_R hL_eq hR_eq hcond_L hcond_R
    · -- Degenerate case: no point in [x', d].
      -- Derive x = c from h_compat_L and x' = d from gap structure.
      -- Then a_R = a and a' = a'_R, so the game tuples coincide
      -- with the right sub-game tuples, and hcond_R applies directly.
      have hxc_eq : x = c := h_compat_L h_no_pt_L
      have hx'd_eq : x' = d := by
        by_contra hne
        have hlt : x' < d := lt_of_le_of_ne hx'd hne
        have hx'_gap : IsGap x' := by
          rcases isPoint_or_isGap x' with ⟨p, hp⟩ | hg
          · have : extendPoint (sig := sig) (atomMap := atomMap) (r := r) p = x' :=
              by rw [extendPoint]; exact hp.symm
            exact absurd ⟨p, this ▸ le_refl _, this ▸ hx'd⟩ h_no_pt_L
          · exact hg
        have hd_gap : IsGap d := by
          rcases isPoint_or_isGap d with ⟨p, hp⟩ | hg
          · have : extendPoint (sig := sig) (atomMap := atomMap) (r := r) p = d :=
              by rw [extendPoint]; exact hp.symm
            exact absurd ⟨p, this ▸ hx'd, this ▸ le_refl _⟩ h_no_pt_L
          · exact hg
        obtain ⟨gx', hgx'⟩ := hx'_gap
        obtain ⟨gd, hgd⟩ := hd_gap
        exact h_no_pt_L (point_between_strict_gaps hgx' hgd hlt)
      -- All selections satisfy c ≤ a i (since x = c)
      have ha_ge_c : ∀ i, c ≤ a i := fun i => hxc_eq ▸ (ha i).1
      have haR_eq : ∀ i, a_R i = a i := by
        intro i; simp only [a_R]; split
        · next h => exact le_antisymm (ha_ge_c i) h
        · rfl
      -- For LEFT selections (a i = c): a'_L i = d = a'_R i, so a' i = a'_R i
      have ha'_eq_R : ∀ i, a' i = a'_R i := by
        intro i; simp only [a']; split
        · next h =>
          have hac : a i = c := le_antisymm h (ha_ge_c i)
          -- a'_L i ∈ [x', d] = [d, d], so a'_L i = d
          have haLi_d : a'_L i = d :=
            le_antisymm (ha'_L i).2 (hx'd_eq ▸ (ha'_L i).1)
          -- a'_R i = d: from hcond_R same_order_type at (0, 1+i)
          have haRi_d : a'_R i = d := by
            apply le_antisymm _ (ha'_R i).1
            by_contra hgt; push_neg at hgt
            have h_sel_eq : a_R i = c := by rw [haR_eq i, hac]
            have hord := hcond_R.1 ⟨0, by omega⟩ ⟨1 + i.val, by omega⟩
            rw [game_tuple_zero_eq, game_tuple_sel_eq,
                game_tuple_zero_eq, game_tuple_sel_eq] at hord
            exact lt_irrefl c (h_sel_eq ▸ hord.1.mpr hgt)
          rw [haLi_d, haRi_d]
        · rfl
      -- Game tuples coincide with right sub-game tuples
      have hM_eq : game_tuple x y a b = game_tuple c y a_R b := by
        funext ⟨i, hi⟩; simp only [game_tuple]
        by_cases h0 : i = 0
        · simp [h0, hxc_eq]
        · by_cases hn1 : i = n + 1
          · simp [hn1]
          · by_cases hn2 : i = n + 2
            · simp [hn2]
            · simp [h0, hn1, hn2]; exact (haR_eq ⟨i - 1, by omega⟩).symm
      have hN_eq : game_tuple x' y' a' b' = game_tuple d y' a'_R b' := by
        funext ⟨i, hi⟩; simp only [game_tuple]
        by_cases h0 : i = 0
        · simp [h0, hx'd_eq]
        · by_cases hn1 : i = n + 1
          · simp [hn1]
          · by_cases hn2 : i = n + 2
            · simp [hn2]
            · simp [h0, hn1, hn2]; exact ha'_eq_R ⟨i - 1, by omega⟩
      refine ⟨b, ⟨hxc_eq ▸ hb_R.1, hb_R.2⟩, ?_⟩
      rw [hM_eq, hN_eq]
      exact hcond_R
where
  /-- Winning condition when b comes from left strategy (b ≤ c). -/
  compose_wc
      {sig : MonadicSignature}
      {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
      {n r : Nat}
      {x y : ExtendedCarrier M atomMap r} {x' y' : ExtendedCarrier N atomMap r}
      {c : ExtendedCarrier M atomMap r} {d : ExtendedCarrier N atomMap r}
      {b b_R : M.carrier} {b' b'_R : N.carrier}
      (hb_le_c : extendPoint (sig := sig) (atomMap := atomMap) (r := r) b ≤ c)
      (hxc : x ≤ c) (hcy : c ≤ y) (hx'd : x' ≤ d) (hdy' : d ≤ y')
      (hcd_type : ∀ (A : StaviFormula), stavi_depth A ≤ r →
        (stavi_temporal_truth_mu M atomMap r c A ↔
         stavi_temporal_truth_mu N atomMap r d A))
      (hcd_gp : (IsPoint c ↔ IsPoint d) ∧ (IsGap c ↔ IsGap d))
      (a a_L a_R : Fin n → ExtendedCarrier M atomMap r)
      (a'_L a'_R : Fin n → ExtendedCarrier N atomMap r)
      (ha_L : ∀ i, inClosedInterval x c (a_L i))
      (ha_R : ∀ i, inClosedInterval c y (a_R i))
      (ha'_L : ∀ i, inClosedInterval x' d (a'_L i))
      (ha'_R : ∀ i, inClosedInterval d y' (a'_R i))
      (hL_eq : ∀ i, a i ≤ c → a_L i = a i)
      (hR_eq : ∀ i, ¬(a i ≤ c) → a_R i = a i)
      (hcond_L : ghr93_winning_condition n
        (game_tuple x c a_L b) (game_tuple x' d a'_L b'))
      (hcond_R : ghr93_winning_condition n
        (game_tuple c y a_R b_R) (game_tuple d y' a'_R b'_R)) :
      ghr93_winning_condition n
        (game_tuple x y a b)
        (game_tuple x' y' (fun i => if a i ≤ c then a'_L i else a'_R i) b') := by
    obtain ⟨hord_L, hgp_L, hform_L⟩ := hcond_L
    obtain ⟨hord_R, hgp_R, hform_R⟩ := hcond_R
    refine ⟨?_, ?_, ?_⟩
    · -- same_order_type
      -- Per-index value matching between merged and sub-game tuples
      -- LEFT i (tM i ≤ c): merged values = left sub-game values
      -- RIGHT i (c < tM i): merged values = right sub-game values
      -- For each index, classify it and relate merged values to sub-game values.
      -- We define per-index data: either LEFT (with M/N equalities to left sub-game)
      -- or RIGHT (with M/N equalities to right sub-game), plus pivot iff data.
      have idx_data : ∀ i : Fin (n + 3),
          (game_tuple x y a b i ≤ c ∧
           game_tuple x y a b i = game_tuple x c a_L b i ∧
           game_tuple x' y' (fun i => if a i ≤ c then a'_L i else a'_R i) b' i =
             game_tuple x' d a'_L b' i) ∨
          (c < game_tuple x y a b i ∧
           game_tuple x y a b i = game_tuple c y a_R b_R i ∧
           game_tuple x' y' (fun i => if a i ≤ c then a'_L i else a'_R i) b' i =
             game_tuple d y' a'_R b'_R i) := by
        intro i
        simp only [game_tuple]
        split
        case isTrue h0 =>
          -- i = 0: x ≤ c, LEFT
          left; exact ⟨hxc, rfl, rfl⟩
        case isFalse h0 =>
          split
          case isTrue hn1 =>
            -- i = n+1: extendPoint b ≤ c, LEFT
            left; exact ⟨hb_le_c, rfl, rfl⟩
          case isFalse hn1 =>
            split
            case isTrue hn2 =>
              -- i = n+2: y ≥ c. RIGHT if c < y, LEFT if c = y.
              rcases lt_or_eq_of_le hcy with hlt | heq
              · right; refine ⟨hlt, rfl, rfl⟩
              · left
                refine ⟨le_of_eq heq.symm, heq.symm, ?_⟩
                have h := hord_R ⟨0, by omega⟩ ⟨n + 2, by omega⟩
                simp only [game_tuple, dite_true, show (n + 2 : Nat) ≠ 0 from by omega,
                  show ¬((n + 2 : Nat) = n + 1) from by omega, dite_false] at h
                exact (h.2.mp heq).symm
            case isFalse hn2 =>
              -- Selection index k = i.val - 1
              have hk : i.val - 1 < n := by omega
              rcases le_or_lt (a ⟨i.val - 1, hk⟩) c with h_le | h_gt
              · left; exact ⟨h_le, (hL_eq ⟨i.val - 1, hk⟩ h_le).symm, by simp [h_le]⟩
              · right; exact ⟨h_gt, (hR_eq ⟨i.val - 1, hk⟩ (not_le.mpr h_gt)).symm,
                  by simp [not_le.mpr h_gt]⟩
      -- Main proof: for each pair, dispatch using idx_data
      intro i j
      rcases idx_data i with ⟨hi_le, heqMi, heqNi⟩ | ⟨hi_gt, heqMi, heqNi⟩
      · -- i is LEFT
        rcases idx_data j with ⟨hj_le, heqMj, heqNj⟩ | ⟨hj_gt, heqMj, heqNj⟩
        · -- Both LEFT: rewrite to left sub-game, use hord_L
          rw [heqMi, heqNi, heqMj, heqNj]; exact hord_L i j
        · -- LEFT i, RIGHT j: use pivot_chain_order
          -- Rewrite goal to use sub-game values
          rw [heqMi, heqMj, heqNi, heqNj]
          -- Get pivot iffs from sub-strategies
          have hpiv_i := hord_L i ⟨n + 2, by omega⟩
          simp only [game_tuple_y_eq] at hpiv_i
          have hpiv_j := hord_R ⟨0, by omega⟩ j
          simp only [game_tuple_zero_eq] at hpiv_j
          -- N-side bounds
          have hi_N_le : game_tuple x' d a'_L b' i ≤ d := by
            rcases lt_or_eq_of_le (heqMi ▸ hi_le) with hlt | heq
            · exact le_of_lt (hpiv_i.1.mp hlt)
            · exact le_of_eq (hpiv_i.2.mp heq)
          have hd_le_j : d ≤ game_tuple d y' a'_R b'_R j := by
            exact le_of_lt (hpiv_j.1.mp (heqMj ▸ hj_gt))
          exact pivot_chain_order (heqMi ▸ hi_le) (le_of_lt (heqMj ▸ hj_gt))
            hi_N_le hd_le_j hpiv_i.1 hpiv_i.2 hpiv_j.1 hpiv_j.2
      · -- i is RIGHT
        rcases idx_data j with ⟨hj_le, heqMj, heqNj⟩ | ⟨hj_gt, heqMj, heqNj⟩
        · -- RIGHT i, LEFT j: reverse pivot
          rw [heqMi, heqMj, heqNi, heqNj]
          have hpiv_j := hord_L j ⟨n + 2, by omega⟩
          simp only [game_tuple_y_eq] at hpiv_j
          have hpiv_i := hord_R ⟨0, by omega⟩ i
          simp only [game_tuple_zero_eq] at hpiv_i
          have hj_N_le : game_tuple x' d a'_L b' j ≤ d := by
            rcases lt_or_eq_of_le (heqMj ▸ hj_le) with hlt | heq
            · exact le_of_lt (hpiv_j.1.mp hlt)
            · exact le_of_eq (hpiv_j.2.mp heq)
          have hd_le_i : d ≤ game_tuple d y' a'_R b'_R i := by
            exact le_of_lt (hpiv_i.1.mp (heqMi ▸ hi_gt))
          -- hpair gives (left_j < right_i ↔ left_N_j < right_N_i), but we need the reverse
          have hpair := pivot_chain_order (heqMj ▸ hj_le) (le_of_lt (heqMi ▸ hi_gt))
            hj_N_le hd_le_i hpiv_j.1 hpiv_j.2 hpiv_i.1 hpiv_i.2
          -- Derive reversed order iff from hpair: b < a ↔ b' < a' from (a < b ↔ a' < b') ∧ (a = b ↔ a' = b')
          constructor
          · constructor
            · intro h
              rcases lt_trichotomy (game_tuple x' d a'_L b' j) (game_tuple d y' a'_R b'_R i) with h' | h' | h'
              · exact absurd h (not_lt.mpr (le_of_lt (hpair.1.mpr h')))
              · exact absurd h (not_lt.mpr (le_of_eq (hpair.2.mpr h')))
              · exact h'
            · intro h
              rcases lt_trichotomy (game_tuple x c a_L b j) (game_tuple c y a_R b_R i) with h' | h' | h'
              · exact absurd h (not_lt.mpr (le_of_lt (hpair.1.mp h')))
              · exact absurd h (not_lt.mpr (le_of_eq (hpair.2.mp h')))
              · exact h'
          · exact ⟨fun h => (hpair.2.mp h.symm).symm, fun h => (hpair.2.mpr h.symm).symm⟩
        · -- Both RIGHT: rewrite to right sub-game, use hord_R
          rw [heqMi, heqNi, heqMj, heqNj]; exact hord_R i j
    · -- gap_point_agreement: dispatch per-index to left or right sub-strategy
      intro i
      simp only [game_tuple]
      split
      case isTrue h0 =>
        -- i = 0: M-value = x, N-value = x'. Left game at 0.
        have := hgp_L ⟨0, by omega⟩
        simp only [game_tuple, dite_true] at this
        exact this
      case isFalse h0 =>
        split
        case isTrue hn1 =>
          -- i = n+1: extendPoint b, extendPoint b'. Left game at n+1.
          have := hgp_L ⟨n + 1, by omega⟩
          simp only [game_tuple, show (n + 1 : Nat) ≠ 0 from by omega, dite_false, dite_true] at this
          exact this
        case isFalse hn1 =>
          split
          case isTrue hn2 =>
            -- i = n+2: y, y'. Right game at n+2.
            have := hgp_R ⟨n + 2, by omega⟩
            simp only [game_tuple, show (n + 2 : Nat) ≠ 0 from by omega,
              show ¬((n + 2 : Nat) = n + 1) from by omega, dite_false, dite_true] at this
            exact this
          case isFalse hn2 =>
            -- Selection index k = i.val - 1
            have hi_sel : i.val - 1 < n := by omega
            let k : Fin n := ⟨i.val - 1, hi_sel⟩
            show (IsPoint (a k) ↔ IsPoint (if a k ≤ c then a'_L k else a'_R k)) ∧
                 (IsGap (a k) ↔ IsGap (if a k ≤ c then a'_L k else a'_R k))
            split
            case isTrue h_le =>
              have hgp_Lk := hgp_L ⟨1 + k.val, by omega⟩
              rw [game_tuple_sel_eq, game_tuple_sel_eq] at hgp_Lk
              rwa [hL_eq k h_le] at hgp_Lk
            case isFalse h_gt =>
              have hgp_Rk := hgp_R ⟨1 + k.val, by omega⟩
              rw [game_tuple_sel_eq, game_tuple_sel_eq] at hgp_Rk
              rwa [hR_eq k h_gt] at hgp_Rk
    · -- formula_agreement: dispatch per-index to left or right sub-strategy
      intro i A hA
      simp only [game_tuple]
      split
      case isTrue h0 =>
        have := hform_L ⟨0, by omega⟩ A hA
        simp only [game_tuple, dite_true] at this
        exact this
      case isFalse h0 =>
        split
        case isTrue hn1 =>
          have := hform_L ⟨n + 1, by omega⟩ A hA
          simp only [game_tuple, show (n + 1 : Nat) ≠ 0 from by omega, dite_false, dite_true] at this
          exact this
        case isFalse hn1 =>
          split
          case isTrue hn2 =>
            have := hform_R ⟨n + 2, by omega⟩ A hA
            simp only [game_tuple, show (n + 2 : Nat) ≠ 0 from by omega,
              show ¬((n + 2 : Nat) = n + 1) from by omega, dite_false, dite_true] at this
            exact this
          case isFalse hn2 =>
            have hi_sel : i.val - 1 < n := by omega
            let k : Fin n := ⟨i.val - 1, hi_sel⟩
            show stavi_temporal_truth_mu M atomMap r (a k) A ↔
                 stavi_temporal_truth_mu N atomMap r (if a k ≤ c then a'_L k else a'_R k) A
            split
            case isTrue h_le =>
              have := hform_L ⟨1 + k.val, by omega⟩ A hA
              rw [game_tuple_sel_eq, game_tuple_sel_eq] at this
              rwa [hL_eq k h_le] at this
            case isFalse h_gt =>
              have := hform_R ⟨1 + k.val, by omega⟩ A hA
              rw [game_tuple_sel_eq, game_tuple_sel_eq] at this
              rwa [hR_eq k h_gt] at this
  /-- Winning condition when b comes from right strategy (c ≤ b). -/
  compose_wc_right
      {sig : MonadicSignature}
      {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
      {n r : Nat}
      {x y : ExtendedCarrier M atomMap r} {x' y' : ExtendedCarrier N atomMap r}
      {c : ExtendedCarrier M atomMap r} {d : ExtendedCarrier N atomMap r}
      {b b_L : M.carrier} {b' b'_L : N.carrier}
      (hbR_ge_c : c ≤ extendPoint (sig := sig) (atomMap := atomMap) (r := r) b)
      (hxc : x ≤ c) (hcy : c ≤ y) (hx'd : x' ≤ d) (hdy' : d ≤ y')
      (hcd_type : ∀ (A : StaviFormula), stavi_depth A ≤ r →
        (stavi_temporal_truth_mu M atomMap r c A ↔
         stavi_temporal_truth_mu N atomMap r d A))
      (hcd_gp : (IsPoint c ↔ IsPoint d) ∧ (IsGap c ↔ IsGap d))
      (a a_L a_R : Fin n → ExtendedCarrier M atomMap r)
      (a'_L a'_R : Fin n → ExtendedCarrier N atomMap r)
      (ha_L : ∀ i, inClosedInterval x c (a_L i))
      (ha_R : ∀ i, inClosedInterval c y (a_R i))
      (ha'_L : ∀ i, inClosedInterval x' d (a'_L i))
      (ha'_R : ∀ i, inClosedInterval d y' (a'_R i))
      (hL_eq : ∀ i, a i ≤ c → a_L i = a i)
      (hR_eq : ∀ i, ¬(a i ≤ c) → a_R i = a i)
      (hcond_L : ghr93_winning_condition n
        (game_tuple x c a_L b_L) (game_tuple x' d a'_L b'_L))
      (hcond_R : ghr93_winning_condition n
        (game_tuple c y a_R b) (game_tuple d y' a'_R b')) :
      ghr93_winning_condition n
        (game_tuple x y a b)
        (game_tuple x' y' (fun i => if a i ≤ c then a'_L i else a'_R i) b') := by
    obtain ⟨hord_L, hgp_L, hform_L⟩ := hcond_L
    obtain ⟨hord_R, hgp_R, hform_R⟩ := hcond_R
    refine ⟨?_, ?_, ?_⟩
    · -- same_order_type (symmetric to compose_wc but n+1 is RIGHT-owned)
      -- idx_data: LEFT uses ≤ c, RIGHT uses c ≤ (may overlap at boundary)
      have idx_data : ∀ i : Fin (n + 3),
          (game_tuple x y a b i ≤ c ∧
           game_tuple x y a b i = game_tuple x c a_L b_L i ∧
           game_tuple x' y' (fun i => if a i ≤ c then a'_L i else a'_R i) b' i =
             game_tuple x' d a'_L b'_L i) ∨
          (c ≤ game_tuple x y a b i ∧
           game_tuple x y a b i = game_tuple c y a_R b i ∧
           game_tuple x' y' (fun i => if a i ≤ c then a'_L i else a'_R i) b' i =
             game_tuple d y' a'_R b' i) := by
        intro i
        simp only [game_tuple]
        split
        case isTrue h0 => left; exact ⟨hxc, rfl, rfl⟩
        case isFalse h0 =>
          split
          case isTrue hn1 =>
            -- i = n+1: c ≤ extendPoint b, RIGHT-owned
            right; exact ⟨hbR_ge_c, rfl, rfl⟩
          case isFalse hn1 =>
            split
            case isTrue hn2 =>
              -- i = n+2: c ≤ y, RIGHT-owned
              right; exact ⟨hcy, rfl, rfl⟩
            case isFalse hn2 =>
              have hk : i.val - 1 < n := by omega
              rcases le_or_lt (a ⟨i.val - 1, hk⟩) c with h_le | h_gt
              · left; exact ⟨h_le, (hL_eq ⟨i.val - 1, hk⟩ h_le).symm, by simp [h_le]⟩
              · right; exact ⟨le_of_lt h_gt, (hR_eq ⟨i.val - 1, hk⟩ (not_le.mpr h_gt)).symm,
                  by simp [not_le.mpr h_gt]⟩
      -- Main same_order_type proof
      intro i j
      rcases idx_data i with ⟨hi_le, heqMi, heqNi⟩ | ⟨hc_le_i, heqMi, heqNi⟩
      · rcases idx_data j with ⟨hj_le, heqMj, heqNj⟩ | ⟨hc_le_j, heqMj, heqNj⟩
        · -- Both LEFT
          rw [heqMi, heqNi, heqMj, heqNj]; exact hord_L i j
        · -- LEFT i, RIGHT j
          rw [heqMi, heqMj, heqNi, heqNj]
          have hpiv_i := hord_L i ⟨n + 2, by omega⟩
          simp only [game_tuple_y_eq] at hpiv_i
          have hpiv_j := hord_R ⟨0, by omega⟩ j
          simp only [game_tuple_zero_eq] at hpiv_j
          have hi_N_le : game_tuple x' d a'_L b'_L i ≤ d := by
            rcases lt_or_eq_of_le (heqMi ▸ hi_le) with hlt | heq
            · exact le_of_lt (hpiv_i.1.mp hlt)
            · exact le_of_eq (hpiv_i.2.mp heq)
          have hd_le_j : d ≤ game_tuple d y' a'_R b' j := by
            rcases lt_or_eq_of_le (heqMj ▸ hc_le_j) with hlt | heq
            · exact le_of_lt (hpiv_j.1.mp hlt)
            · exact le_of_eq (hpiv_j.2.mp heq)
          exact pivot_chain_order (heqMi ▸ hi_le) (heqMj ▸ hc_le_j)
            hi_N_le hd_le_j hpiv_i.1 hpiv_i.2 hpiv_j.1 hpiv_j.2
      · rcases idx_data j with ⟨hj_le, heqMj, heqNj⟩ | ⟨hc_le_j, heqMj, heqNj⟩
        · -- RIGHT i, LEFT j
          rw [heqMi, heqMj, heqNi, heqNj]
          have hpiv_j := hord_L j ⟨n + 2, by omega⟩
          simp only [game_tuple_y_eq] at hpiv_j
          have hpiv_i := hord_R ⟨0, by omega⟩ i
          simp only [game_tuple_zero_eq] at hpiv_i
          have hj_N_le : game_tuple x' d a'_L b'_L j ≤ d := by
            rcases lt_or_eq_of_le (heqMj ▸ hj_le) with hlt | heq
            · exact le_of_lt (hpiv_j.1.mp hlt)
            · exact le_of_eq (hpiv_j.2.mp heq)
          have hd_le_i : d ≤ game_tuple d y' a'_R b' i := by
            rcases lt_or_eq_of_le (heqMi ▸ hc_le_i) with hlt | heq
            · exact le_of_lt (hpiv_i.1.mp hlt)
            · exact le_of_eq (hpiv_i.2.mp heq)
          have hpair := pivot_chain_order (heqMj ▸ hj_le) (heqMi ▸ hc_le_i)
            hj_N_le hd_le_i hpiv_j.1 hpiv_j.2 hpiv_i.1 hpiv_i.2
          constructor
          · constructor
            · intro h
              rcases lt_trichotomy (game_tuple x' d a'_L b'_L j) (game_tuple d y' a'_R b' i) with h' | h' | h'
              · exact absurd h (not_lt.mpr (le_of_lt (hpair.1.mpr h')))
              · exact absurd h (not_lt.mpr (le_of_eq (hpair.2.mpr h')))
              · exact h'
            · intro h
              rcases lt_trichotomy (game_tuple x c a_L b_L j) (game_tuple c y a_R b i) with h' | h' | h'
              · exact absurd h (not_lt.mpr (le_of_lt (hpair.1.mp h')))
              · exact absurd h (not_lt.mpr (le_of_eq (hpair.2.mp h')))
              · exact h'
          · exact ⟨fun h => (hpair.2.mp h.symm).symm, fun h => (hpair.2.mpr h.symm).symm⟩
        · -- Both RIGHT
          rw [heqMi, heqNi, heqMj, heqNj]; exact hord_R i j
    · -- gap_point_agreement
      intro i
      simp only [game_tuple]
      split
      case isTrue h0 =>
        have := hgp_L ⟨0, by omega⟩
        simp only [game_tuple, dite_true] at this; exact this
      case isFalse h0 =>
        split
        case isTrue hn1 =>
          -- n+1: extendPoint b, b' -- from RIGHT strategy
          have := hgp_R ⟨n + 1, by omega⟩
          simp only [game_tuple, show (n + 1 : Nat) ≠ 0 from by omega, dite_false, dite_true] at this
          exact this
        case isFalse hn1 =>
          split
          case isTrue hn2 =>
            have := hgp_R ⟨n + 2, by omega⟩
            simp only [game_tuple, show (n + 2 : Nat) ≠ 0 from by omega,
              show ¬((n + 2 : Nat) = n + 1) from by omega, dite_false, dite_true] at this
            exact this
          case isFalse hn2 =>
            have hi_sel : i.val - 1 < n := by omega
            let k : Fin n := ⟨i.val - 1, hi_sel⟩
            show (IsPoint (a k) ↔ IsPoint (if a k ≤ c then a'_L k else a'_R k)) ∧
                 (IsGap (a k) ↔ IsGap (if a k ≤ c then a'_L k else a'_R k))
            split
            case isTrue h_le =>
              have hgp_Lk := hgp_L ⟨1 + k.val, by omega⟩
              rw [game_tuple_sel_eq, game_tuple_sel_eq] at hgp_Lk
              rwa [hL_eq k h_le] at hgp_Lk
            case isFalse h_gt =>
              have hgp_Rk := hgp_R ⟨1 + k.val, by omega⟩
              rw [game_tuple_sel_eq, game_tuple_sel_eq] at hgp_Rk
              rwa [hR_eq k h_gt] at hgp_Rk
    · -- formula_agreement
      intro i A hA
      simp only [game_tuple]
      split
      case isTrue h0 =>
        have := hform_L ⟨0, by omega⟩ A hA
        simp only [game_tuple, dite_true] at this; exact this
      case isFalse h0 =>
        split
        case isTrue hn1 =>
          have := hform_R ⟨n + 1, by omega⟩ A hA
          simp only [game_tuple, show (n + 1 : Nat) ≠ 0 from by omega, dite_false, dite_true] at this
          exact this
        case isFalse hn1 =>
          split
          case isTrue hn2 =>
            have := hform_R ⟨n + 2, by omega⟩ A hA
            simp only [game_tuple, show (n + 2 : Nat) ≠ 0 from by omega,
              show ¬((n + 2 : Nat) = n + 1) from by omega, dite_false, dite_true] at this
            exact this
          case isFalse hn2 =>
            have hi_sel : i.val - 1 < n := by omega
            let k : Fin n := ⟨i.val - 1, hi_sel⟩
            show stavi_temporal_truth_mu M atomMap r (a k) A ↔
                 stavi_temporal_truth_mu N atomMap r (if a k ≤ c then a'_L k else a'_R k) A
            split
            case isTrue h_le =>
              have := hform_L ⟨1 + k.val, by omega⟩ A hA
              rw [game_tuple_sel_eq, game_tuple_sel_eq] at this
              rwa [hL_eq k h_le] at this
            case isFalse h_gt =>
              have := hform_R ⟨1 + k.val, by omega⟩ A hA
              rw [game_tuple_sel_eq, game_tuple_sel_eq] at this
              rwa [hR_eq k h_gt] at this

end Bimodal.Metalogic.WeakCanonical
