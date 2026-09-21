/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Expressiveness.EFGames.GapDetection
import FormalSystem.Metalogic.Expressiveness.EFGames.MuRelativizedTruth

/-!
# Gap Detection Correctness: Right Direction

GHR93 Lemma 9 for `rightFormula`: the core `S'(X, D)` helper (`stavi_snce_gap_detection`), gap
uniqueness on the right (`gap_detection_unique_right`), and the correctness theorem
`right_formula_gap_detection`. The formulas themselves are defined in
`EFGames/GapDetection.lean`; the left direction is `EFGames/GapDetectionLeft.lean`.
-/

set_option linter.style.longFile 2400

namespace FormalSystem.Metalogic.Expressiveness

open FormalSystem.Syntax

/-! ### GHR93 Lemma 9 (Gap detection correctness, right direction)

rightFormula(A, D) evaluated at an actual point m in M_r detects
whether A^mu holds at a gap gamma that is D-defined on the right,
with gamma < m and D holding at all actual points between gamma and m.
-/

/-- Core helper for right: S'(X, D) at an actual point m detects a D-defined
    gap γ < m where X holds at cut points above some bound, with D holding at
    complement points between γ and m. Dual of stavi_untl_gap_detection.

    RHS uses "X at cut points above s_bound" rather than X^mu at the gap,
    matching the stavi_untl_gap_detection pattern. -/
theorem stavi_snce_gap_detection {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (X D : StaviFormula) (hD : staviDepth D ≤ r) (m : M.carrier) :
    StaviTemporalTruthMu M atomMap r (extendPoint m) (.stavi_snce X D) ↔
    (∃ (γ : RDefinableGap M atomMap r) (s_bound : M.carrier),
      extendPoint (sig := sig) (atomMap := atomMap) (r := r) m > Sum.inr γ ∧
      s_bound ∈ γ.val.cut ∧
      GapDefinableOnRight M atomMap γ.val D ∧
      (∀ u : M.carrier, u < m → u ∉ γ.val.cut →
        StaviTemporalTruthMu M atomMap r
          (extendPoint (sig := sig) (atomMap := atomMap) (r := r) u) D) ∧
      (∀ u : M.carrier, u ∈ γ.val.cut → s_bound < u →
        StaviTemporalTruth M atomMap u X)) := by
  -- Dual of stavi_untl_gap_detection: reverse direction, complement ↔ cut roles swapped
  rw [stavi_truth_mu_at_point m (.stavi_snce X D)]
  simp only [StaviTemporalTruth]
  -- LHS: ∃ s < m, body(1) ∧ (2) D fails somewhere ∧ (3) D holds on final segment
  constructor
  · -- **Forward direction** (FO table → gap):
    intro ⟨s, hsm, h_body, ⟨u_fail, hsu_fail, hum_fail, hD_fail⟩,
           ⟨u_init, hsu_init, hum_init, hD_init⟩⟩
    -- Dual cut: complement (= points where D is cofinal toward m from below)
    let compl : Set M.carrier :=
      {x | ∀ u, x ≤ u → u < m →
        ∃ v, v < u ∧ ∀ w, v < w → w < m → StaviTemporalTruth M atomMap w D}
    have hm_in_compl : m ∈ compl :=
      fun u hmu hum => absurd (lt_of_lt_of_le hum hmu) (lt_irrefl u)
    have hu_fail_not_compl : u_fail ∉ compl := by
      intro h; obtain ⟨v, hvu, hDv⟩ := h u_fail le_rfl hum_fail
      exact hD_fail (hDv u_fail hvu hum_fail)
    let cut : Set M.carrier := {x | x ∉ compl}
    -- Classical conversion: x ∉ cut ↔ x ∈ compl
    have h_not_cut_compl : ∀ x, x ∉ cut → x ∈ compl := fun x h => by
      by_contra hx; exact h hx
    have h_compl_not_cut : ∀ x, x ∈ compl → x ∉ cut := fun x hx h => h hx
    have huf_in_cut : u_fail ∈ cut := hu_fail_not_compl
    have hm_not_cut : m ∉ cut := h_compl_not_cut m hm_in_compl
    -- compl is upward-closed; cut is downward-closed
    have h_compl_up : ∀ x y, x ∈ compl → x ≤ y → y ∈ compl :=
      fun x y hx hxy u hyu hum => hx u (le_trans hxy hyu) hum
    have h_cut_dc : ∀ x y, x ∈ cut → y ≤ x → y ∈ cut :=
      fun x y hx hyx hy => hx (h_compl_up y x hy hyx)
    -- All cut points < all compl points
    have h_cut_lt_compl : ∀ x ∈ cut, ∀ y ∈ compl, x < y := by
      intro x hx y hy; by_contra h; push Not at h
      exact hx (h_compl_up y x hy h)
    have h_proper : cut ≠ Set.univ := by
      intro h; exact hm_not_cut (h ▸ Set.mem_univ m)
    -- Cofinal propagation (dual): body condition left ⟹ compl membership
    have h_cofinal_propagate :
        ∀ u, s < u → u < m →
        (∀ w, u < w → w < m →
          ∃ v, v < w ∧ ∀ z, v < z → z < m → StaviTemporalTruth M atomMap z D) →
        ∃ v, v < u ∧ ∀ z, v < z → z < m → StaviTemporalTruth M atomMap z D := by
      intro u hsu hum h_above
      cases h_body u hsu hum with
      | inl h => exact h
      | inr h =>
        obtain ⟨_, v', huv', hv'm, hDv'⟩ := h
        obtain ⟨v₂, hv₂v', hDv₂⟩ := h_above v' huv' hv'm
        exact absurd (hDv₂ v' hv₂v' hv'm) hDv'
    -- u_init ∈ compl: D on (u_init, m) and body LEFT at u_init
    have h_cofinal_u_init :
        ∃ v, v < u_init ∧ ∀ w, v < w → w < m → StaviTemporalTruth M atomMap w D := by
      cases h_body u_init hsu_init hum_init with
      | inl h => exact h
      | inr h =>
        obtain ⟨_, v', huv', hv'm, hDv'⟩ := h
        exact absurd (hD_init v' huv' hv'm) hDv'
    have hu_init_compl : u_init ∈ compl := by
      intro u huu_init hum
      rcases eq_or_lt_of_le huu_init with rfl | hlt
      · exact h_cofinal_u_init
      · exact ⟨u_init, hlt, fun w hw hwm => hD_init w hw hwm⟩
    -- D at compl points
    have h_D_at_compl : ∀ u, u ∈ compl → u < m →
        StaviTemporalTruth M atomMap u D := by
      intro u hu hum; obtain ⟨v, hvu, hDv⟩ := hu u le_rfl hum
      exact hDv u hvu hum
    -- No sup in cut
    have h_no_sup : ¬∃ p, IsLUB cut p ∧ p ∈ cut := by
      intro ⟨p, ⟨h_ub, _⟩, hp_cut⟩
      have hpm : p < m := h_cut_lt_compl p hp_cut m hm_in_compl
      have hps : s < p := by
        by_contra h; push Not at h
        exact not_le.mpr (lt_of_le_of_lt h hsu_fail) (h_ub huf_in_cut)
      apply hp_cut
      intro u hpu hum
      rcases eq_or_lt_of_le hpu with rfl | hpu'
      · exact h_cofinal_propagate p hps hum (fun w hpw hwm => by
          have : w ∈ compl := by by_contra hw; exact not_le.mpr hpw (h_ub hw)
          exact this w le_rfl hwm)
      · have : u ∈ compl := by by_contra hu_cut; exact not_le.mpr hpu' (h_ub hu_cut)
        exact this u le_rfl hum
    -- Complement has no minimum
    have h_comp_no_min : ¬∃ b, b ∉ cut ∧ ∀ y, y ∉ cut → b ≤ y := by
      intro ⟨b, hb_compl, hb_min⟩
      have hbm : b < m := by
        rcases eq_or_lt_of_le (hb_min m (fun h => h hm_in_compl)) with rfl | h
        · exact absurd (hb_min u_init (fun h => h hu_init_compl)) (not_le.mpr hum_init)
        · exact h
      have hb_in_compl : b ∈ compl := h_not_cut_compl b hb_compl
      have hsb : s < b := by
        by_contra h; push Not at h
        have hs_compl := h_compl_up b s hb_in_compl h
        obtain ⟨v, hvu, hDv⟩ := hs_compl u_fail (le_of_lt hsu_fail) hum_fail
        exact hD_fail (hDv u_fail hvu hum_fail)
      cases h_body b hsb hbm with
      | inl h_cof =>
        obtain ⟨v, hvb, hDv⟩ := h_cof
        by_cases hvs : s < v
        · have hvm : v < m := lt_trans hvb hbm
          cases h_body v hvs hvm with
          | inl h2 =>
            obtain ⟨v₂, hv₂v, hDv₂⟩ := h2
            have hv_compl : v ∈ compl := by
              intro u hvu hum
              rcases eq_or_lt_of_le hvu with rfl | hvu'
              · exact ⟨v₂, hv₂v, hDv₂⟩
              · exact ⟨v, hvu', hDv⟩
            exact absurd (hb_min v (h_compl_not_cut v hv_compl)) (not_le.mpr hvb)
          | inr h2 =>
            obtain ⟨_, v', hvv', hv'm, hDv'⟩ := h2
            exact absurd (hDv v' hvv' hv'm) hDv'
        · push Not at hvs
          exact absurd (hDv u_fail (lt_of_le_of_lt hvs hsu_fail) hum_fail) hD_fail
      | inr h_right =>
        obtain ⟨_, v', hbv', hv'm, hDv'⟩ := h_right
        have hv'_not_compl : v' ∉ compl := by
          intro hv'; exact hDv' (h_D_at_compl v' hv' hv'm)
        exact not_lt.mpr (le_of_lt hbv') (h_cut_lt_compl v' hv'_not_compl b hb_in_compl)
    -- No final-cut segment with D
    have h_no_final_cut : ¬∃ t, t ∈ cut ∧ ∀ u, t ≤ u → u ∈ cut →
        StaviTemporalTruth M atomMap u D := by
      intro ⟨t, ht_cut, hDt⟩
      have htm : t < m := h_cut_lt_compl t ht_cut m hm_in_compl
      have hst : s < t := by
        by_contra h; push Not at h
        exact hD_fail (hDt u_fail (le_trans h (le_of_lt hsu_fail)) huf_in_cut)
      apply ht_cut
      cases h_body t hst htm with
      | inl h =>
        intro u htu hum
        rcases eq_or_lt_of_le htu with rfl | htu'
        · exact h
        · obtain ⟨v, hvt, hDv⟩ := h
          exact ⟨t, htu', fun w htw hwm => by
            by_cases hw_cut : w ∈ cut
            · exact hDt w (le_of_lt htw) hw_cut
            · exact h_D_at_compl w (h_not_cut_compl w hw_cut) hwm⟩
      | inr h =>
        obtain ⟨_, v', htv', hv'm, hDv'⟩ := h
        by_cases hv'_cut : v' ∈ cut
        · exact absurd (hDt v' (le_of_lt htv') hv'_cut) hDv'
        · exact absurd (h_D_at_compl v' (h_not_cut_compl v' hv'_cut) hv'm) hDv'
    -- Initial complement segment has D
    have h_init_compl : ∃ t, t ∉ cut ∧ ∀ u, u ∉ cut → u ≤ t →
        StaviTemporalTruth M atomMap u D :=
      ⟨u_init, h_compl_not_cut u_init hu_init_compl,
        fun u hu huu => h_D_at_compl u (h_not_cut_compl u hu) (lt_of_le_of_lt huu hum_init)⟩
    -- Build Gap
    let γ_gap : Gap M.carrier :=
      ⟨cut, ⟨u_fail, huf_in_cut⟩, h_proper, h_cut_dc, h_no_sup, h_comp_no_min⟩
    have h_def_right : GapDefinableOnRight M atomMap γ_gap D :=
      ⟨h_init_compl, h_no_final_cut⟩
    have h_r_def : IsRDefinableGap M atomMap γ_gap r :=
      ⟨D, hD, Or.inr h_def_right⟩
    let γ_rdef : RDefinableGap M atomMap r := ⟨γ_gap, h_r_def⟩
    -- X at cut points: from body right disjunct
    have h_X_at_cut : ∀ u : M.carrier, u ∈ cut → u_fail < u →
        StaviTemporalTruth M atomMap u X := by
      intro u hu_cut huf_u
      have hum : u < m := h_cut_lt_compl u hu_cut m hm_in_compl
      have hsu : s < u := lt_trans hsu_fail huf_u
      have ⟨z, hz_cut, huz⟩ : ∃ z ∈ cut, u < z := by
        by_contra h_all; push Not at h_all
        exact h_no_sup ⟨u, ⟨fun x hx => h_all x hx, fun b hb => hb hu_cut⟩, hu_cut⟩
      have hzm : z < m := h_cut_lt_compl z hz_cut m hm_in_compl
      have hsz : s < z := lt_trans hsu huz
      have h_right_z : (∀ v, s < v → v < z → StaviTemporalTruth M atomMap v X) ∧
          ∃ v', z < v' ∧ v' < m ∧ ¬StaviTemporalTruth M atomMap v' D := by
        cases h_body z hsz hzm with
        | inl h_left =>
          exfalso; apply hz_cut
          obtain ⟨v, hvz, hDv⟩ := h_left
          intro w hzw hwm; exact ⟨v, lt_of_lt_of_le hvz hzw, hDv⟩
        | inr h_right => exact h_right
      exact h_right_z.1 u hsu huz
    refine ⟨γ_rdef, u_fail, ?_, huf_in_cut, h_def_right, ?_, ?_⟩
    · -- m > γ
      change m ∉ cut ∧ ¬(m ∈ cut); exact ⟨hm_not_cut, hm_not_cut⟩
    · -- D at complement points < m
      intro u hum hu_not
      exact (stavi_truth_mu_at_point u D).mpr (h_D_at_compl u (h_not_cut_compl u hu_not) hum)
    · -- X at cut points above u_fail
      exact fun u hu_cut huf_u => h_X_at_cut u hu_cut huf_u
  · -- **Backward direction** (gap → FO table):
    intro ⟨γ, s_bound, hm_gt_γ, hs_bound_in, h_def_right, h_D_bet, hX_cut⟩
    have hm_not_cut : m ∉ γ.val.cut := by
      intro h; exact not_lt.mpr (show extendPoint m ≤ Sum.inr γ from h) hm_gt_γ
    obtain ⟨⟨t_compl, ht_not_cut, ht_D_init⟩, h_no_final_cut⟩ := h_def_right
    have h_neg_final : ∀ t, t ∈ γ.val.cut →
        ∃ w, w ∈ γ.val.cut ∧ t ≤ w ∧ ¬StaviTemporalTruth M atomMap w D := by
      intro t ht; by_contra h_all; push Not at h_all
      exact h_no_final_cut ⟨t, ht, fun w hwt hw_cut => h_all w hw_cut hwt⟩
    have h_cut_lt_m : ∀ x, x ∈ γ.val.cut → x < m := by
      intro x hx; by_contra h; push Not at h
      exact hm_not_cut (γ.val.downward_closed x m hx h)
    -- Complement points above cut: for v ∉ cut, all cut < v
    have h_compl_gt_cut : ∀ v, v ∉ γ.val.cut → ∀ x, x ∈ γ.val.cut → x < v := by
      intro v hv x hx; by_contra h; push Not at h
      exact hv (γ.val.downward_closed x v hx h)
    -- Use s_bound as s (s_bound ∈ cut, so s_bound < m)
    refine ⟨s_bound, h_cut_lt_m s_bound hs_bound_in, ?_, ?_, ?_⟩
    · -- Condition (1): ∀ u ∈ (s_bound, m), disjunction
      intro u hsu hum
      by_cases hu_cut : u ∈ γ.val.cut
      · -- u ∈ cut: RIGHT disjunct — X on (s_bound, u) and ¬D witness above u
        right
        refine ⟨fun v hsv hvu => ?_, ?_⟩
        · have hv_cut : v ∈ γ.val.cut := γ.val.downward_closed u v hu_cut (le_of_lt hvu)
          exact hX_cut v hv_cut hsv
        · have ⟨z, hz_cut, huz_strict⟩ : ∃ z ∈ γ.val.cut, u < z := by
            by_contra h_all; push Not at h_all
            exact γ.val.no_sup ⟨u, ⟨fun x hx => h_all x hx, fun b hb => hb hu_cut⟩, hu_cut⟩
          obtain ⟨w₂, hw₂_cut, hz_w₂, hDw₂⟩ := h_neg_final z hz_cut
          exact ⟨w₂, lt_of_lt_of_le huz_strict hz_w₂, h_cut_lt_m w₂ hw₂_cut, hDw₂⟩
      · -- u ∉ cut: LEFT disjunct — D cofinal below u
        left
        have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
          by_contra h_all; push Not at h_all
          exact γ.val.complement_no_min ⟨u, hu_cut, fun z hz => h_all z hz⟩
        exact ⟨y, hyu, fun w hyw hwm => by
          have hw_not : w ∉ γ.val.cut := by
            intro h; exact hy_not (γ.val.downward_closed w y h (le_of_lt hyw))
          exact (stavi_truth_mu_at_point w D).mp (h_D_bet w hwm hw_not)⟩
    · -- Condition (2): ∃ u ∈ (s_bound, m), ¬D(u)
      have ⟨z, hz_cut, hsz⟩ : ∃ z ∈ γ.val.cut, s_bound < z := by
        by_contra h_all; push Not at h_all
        exact γ.val.no_sup ⟨s_bound,
          ⟨h_all, fun b hb => hb hs_bound_in⟩, hs_bound_in⟩
      obtain ⟨w, hw_cut, hzw, hDw⟩ := h_neg_final z hz_cut
      exact ⟨w, lt_of_lt_of_le hsz hzw, h_cut_lt_m w hw_cut, hDw⟩
    · -- Condition (3): ∃ u ∈ (s_bound, m), D on (u, m)
      have ⟨y, hy_not, hym⟩ : ∃ y, y ∉ γ.val.cut ∧ y < m := by
        by_contra h_all; push Not at h_all
        exact γ.val.complement_no_min ⟨m, hm_not_cut, fun z hz => h_all z hz⟩
      have hsy : s_bound < y := h_compl_gt_cut y hy_not s_bound hs_bound_in
      refine ⟨y, hsy, hym, fun v hyv hvm => by
        have hv_not : v ∉ γ.val.cut := by
          intro h; exact hy_not (γ.val.downward_closed v y h (le_of_lt hyv))
        exact (stavi_truth_mu_at_point v D).mp (h_D_bet v hvm hv_not)⟩

-- std_snce_gap_detection: DELETED (provably false, past dual of std_untl_gap_detection).
-- Same issue: S(X,D) has no D-failure condition. See std_untl_gap_detection comment above.

theorem gap_detection_unique_right {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {γ₁ γ₂ : Gap M.carrier} {D : StaviFormula} {m : M.carrier}
    (h₁_def : GapDefinableOnRight M atomMap γ₁ D)
    (h₂_def : GapDefinableOnRight M atomMap γ₂ D)
    (h₁_bet : ∀ u : M.carrier, u < m → u ∉ γ₁.cut →
      StaviTemporalTruth M atomMap u D)
    (h₂_bet : ∀ u : M.carrier, u < m → u ∉ γ₂.cut →
      StaviTemporalTruth M atomMap u D)
    (hm₁ : m ∉ γ₁.cut)
    (hm₂ : m ∉ γ₂.cut) :
    γ₁ = γ₂ := by
  apply gap_ext
  by_contra hne
  wlog h : ¬(γ₁.cut ⊆ γ₂.cut) with H
  · push Not at hne
    rcases gap_cuts_total γ₁ γ₂ with hsub | hsub
    · exact H h₂_def h₁_def h₂_bet h₁_bet hm₂ hm₁ (Ne.symm hne)
        (fun h' => hne (Set.Subset.antisymm hsub h'))
    · exact h (fun h' => hne (Set.Subset.antisymm h' hsub))
  obtain ⟨x, hx₁, hx₂⟩ := Set.not_subset.mp h
  obtain ⟨_, h_no_init⟩ := h₁_def
  apply h_no_init
  refine ⟨x, hx₁, fun u hxu hu_in₁ => ?_⟩
  have hu_not₂ : u ∉ γ₂.cut := by
    intro h'; exact hx₂ (γ₂.downward_closed u x h' hxu)
  have hum : u < m := by
    by_contra h_not; push Not at h_not
    exact hm₁ (γ₁.downward_closed u m hu_in₁ h_not)
  exact h₂_bet u hum hu_not₂

theorem right_formula_gap_detection {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (A D : StaviFormula) (hD : staviDepth D ≤ r) (m : M.carrier) :
    StaviTemporalTruthMu M atomMap r (extendPoint m) (rightFormula A D) ↔
    (∃ (γ : RDefinableGap M atomMap r),
      extendPoint (sig := sig) (atomMap := atomMap) (r := r) m > Sum.inr γ ∧
      GapDefinableOnRight M atomMap γ.val D ∧
      (∀ u : M.carrier, u < m → u ∉ γ.val.cut →
        StaviTemporalTruthMu M atomMap r
          (extendPoint (sig := sig) (atomMap := atomMap) (r := r) u) D) ∧
      StaviTemporalTruthMu M atomMap r (Sum.inr γ) A) := by
  induction A generalizing m with
  | base φ =>
    simp only [rightFormula]
    induction φ with
    | atom a =>
      simp only [rightFormulaBase, StaviTemporalTruthMu, TemporalTruthMu]
      constructor
      · exact False.elim
      · intro ⟨γ, _, _, _, hA⟩; exact hA
    | bot =>
      simp only [rightFormulaBase, StaviTemporalTruthMu, TemporalTruthMu]
      constructor
      · exact False.elim
      · intro ⟨γ, _, _, _, hA⟩; exact hA
    | box a =>
      simp only [rightFormulaBase, StaviTemporalTruthMu, TemporalTruthMu]
      constructor
      · exact False.elim
      · intro ⟨γ, _, _, _, hA⟩; exact hA
    | imp f g ih_f ih_g =>
      -- rightFormulaBase D (.imp f g) = S'(⊤,D) ∧ ¬(right_base(f) ∧ S'(⊤,D) ∧ ¬right_base(g))
      -- Mirrors left base.imp with stavi_snce_gap_detection
      constructor
      · -- Forward direction
        intro hLHS
        simp only [rightFormulaBase] at hLHS
        simp only [StaviTemporalTruthMu] at hLHS
        obtain ⟨hS, hNeg⟩ := hLHS
        have hS' : StaviTemporalTruthMu M atomMap r (extendPoint m)
            (.stavi_snce (.base Formula.top) D) := by
          simp only [StaviTemporalTruthMu]; exact hS
        obtain ⟨γ, _s_bound, hγ_lt, _hs_in, hγ_def, hγ_bet, _⟩ :=
          (stavi_snce_gap_detection (.base Formula.top) D hD m).mp hS'
        refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
        simp only [StaviTemporalTruthMu, TemporalTruthMu]
        intro hf_at_γ
        have hRight_f : StaviTemporalTruthMu M atomMap r (extendPoint m)
            (rightFormulaBase D f) :=
          ih_f.mpr ⟨γ, hγ_lt, hγ_def, hγ_bet, hf_at_γ⟩
        have hRight_g : StaviTemporalTruthMu M atomMap r (extendPoint m)
            (rightFormulaBase D g) := by
          by_contra h
          exact hNeg ⟨hRight_f, hS, h⟩
        obtain ⟨γ', hγ'_lt, hγ'_def, hγ'_bet, hg_at_γ'⟩ := ih_g.mp hRight_g
        have hm_not : m ∉ γ.val.cut := by
          intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γ).mpr h) hγ_lt
        have hm_not' : m ∉ γ'.val.cut := by
          intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γ').mpr h) hγ'_lt
        have hγ_bet_std : ∀ u, u < m → u ∉ γ.val.cut →
            StaviTemporalTruth M atomMap u D :=
          fun u hum hu_not => (stavi_truth_mu_at_point u D).mp (hγ_bet u hum hu_not)
        have hγ'_bet_std : ∀ u, u < m → u ∉ γ'.val.cut →
            StaviTemporalTruth M atomMap u D :=
          fun u hum hu_not => (stavi_truth_mu_at_point u D).mp (hγ'_bet u hum hu_not)
        have heq : γ.val = γ'.val :=
          gap_detection_unique_right hγ_def hγ'_def hγ_bet_std hγ'_bet_std hm_not hm_not'
        rw [Subtype.ext heq]
        exact hg_at_γ'
      · -- Backward direction
        intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hfg_at_γ⟩
        simp only [rightFormulaBase, StaviTemporalTruthMu]
        constructor
        · -- S'(⊤,D)(m): from γ, construct stavi_snce_gap_detection
          have h_compl : ∃ x, x ∈ γ.val.cut := by
            obtain ⟨x, hx⟩ := γ.val.nonempty
            exact ⟨x, hx⟩
          obtain ⟨s_b, hs_b⟩ := h_compl
          have hTop_cut : ∀ u : M.carrier, u ∈ γ.val.cut → s_b < u →
              StaviTemporalTruth M atomMap u (.base Formula.top) := by
            intro u _ _
            simp only [StaviTemporalTruth, TemporalTruth, Formula.top]; exact id
          have := (stavi_snce_gap_detection (.base Formula.top) D hD m).mpr
            ⟨γ, s_b, hγ_lt, hs_b, hγ_def, hγ_bet, hTop_cut⟩
          simp only [StaviTemporalTruthMu] at this
          exact this
        · -- ¬(right_base(f) ∧ S'(⊤,D)(m) ∧ ¬right_base(g))
          intro ⟨hRf, _, hNRg⟩
          obtain ⟨γ₁, hγ₁_lt, hγ₁_def, hγ₁_bet, hf_at_γ₁⟩ := ih_f.mp hRf
          have hm_not : m ∉ γ.val.cut := by
            intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γ).mpr h) hγ_lt
          have hm_not₁ : m ∉ γ₁.val.cut := by
            intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γ₁).mpr h) hγ₁_lt
          have hγ_bet_std : ∀ u, u < m → u ∉ γ.val.cut →
              StaviTemporalTruth M atomMap u D :=
            fun u hum hu_not => (stavi_truth_mu_at_point u D).mp (hγ_bet u hum hu_not)
          have hγ₁_bet_std : ∀ u, u < m → u ∉ γ₁.val.cut →
              StaviTemporalTruth M atomMap u D :=
            fun u hum hu_not => (stavi_truth_mu_at_point u D).mp (hγ₁_bet u hum hu_not)
          have heq : γ₁.val = γ.val :=
            gap_detection_unique_right hγ₁_def hγ_def hγ₁_bet_std hγ_bet_std hm_not₁ hm_not
          simp only [StaviTemporalTruthMu, TemporalTruthMu] at hfg_at_γ
          have hg_at_γ := hfg_at_γ ((Subtype.ext heq) ▸ hf_at_γ₁)
          exact hNRg (ih_g.mpr ⟨γ, hγ_lt, hγ_def, hγ_bet, hg_at_γ⟩)
    | untl g f _ _ =>
      -- rightFormulaBase D (.untl f g) = .std_snce compound D where
      -- compound = D ∧ g ∧ U(f,g) ∧ S'(⊤, g∧D) ∧ ¬S'(D, g∧D)
      -- Mirrors left base.snce with direction reversed
      simp only [rightFormulaBase]
      rw [stavi_truth_mu_at_point m (.std_snce _ D)]
      simp only [StaviTemporalTruth]
      constructor
      · -- Forward: std_snce(compound, D)(m) → gap conditions
        intro ⟨s, hsm, hcompound_s, hD_bet⟩
        obtain ⟨hDs, hgs, hUntl_s, hS'_gD_s, hNotS'D_gD_s⟩ := hcompound_s
        obtain ⟨s₁, hs₁s, h_body, h_fail, h_init⟩ := hS'_gD_s
        obtain ⟨u_fail, hs₁_uf, huf_s, hgD_fail⟩ := h_fail
        obtain ⟨u_init, hs₁_ui, hui_s, hgD_init⟩ := h_init
        -- Build g∧D-cofinal complement (past direction, mirrors left's cut)
        let gD : M.carrier → Prop := fun u =>
          TemporalTruth M atomMap u g ∧ StaviTemporalTruth M atomMap u D
        let compl : Set M.carrier :=
          {x | ∀ u, u < s → x ≤ u → ∃ v, v < u ∧ ∀ w, v < w → w < s → gD w}
        have hs_in_compl : s ∈ compl :=
          fun u hus hsu => absurd (lt_of_le_of_lt hsu hus) (lt_irrefl s)
        have hu_fail_not_compl : u_fail ∉ compl := by
          intro h; obtain ⟨v, hvuf, hgDv⟩ := h u_fail huf_s le_rfl
          exact hgD_fail (hgDv u_fail hvuf huf_s)
        have h_compl_gt_uf : ∀ x ∈ compl, u_fail < x := by
          intro x hx; by_contra h; push Not at h
          exact hu_fail_not_compl (fun u hus huf => hx u hus (le_trans h huf))
        have h_compl_gt_s₁ : ∀ x ∈ compl, s₁ < x :=
          fun x hx => lt_trans hs₁_uf (h_compl_gt_uf x hx)
        have h_compl_uc : ∀ x y, x ∈ compl → x ≤ y → y ∈ compl :=
          fun x y hx hxy u hus hyu => hx u hus (le_trans (le_trans hxy hyu) le_rfl)
        -- cut = complement of compl (reversed from left's cut)
        let cut : Set M.carrier := {x | x ∉ compl}
        have h_cut_dc : ∀ x y, x ∈ cut → y ≤ x → y ∈ cut := by
          intro x y hx hyx hy; exact hx (h_compl_uc y x hy hyx)
        have h_proper : cut ≠ Set.univ := by
          intro h; have := h ▸ Set.mem_univ s; exact this hs_in_compl
        have h_cofinal_propagate :
            ∀ u, s₁ < u → u < s →
            (∀ w, u < w → w < s →
              ∃ v, v < w ∧ ∀ z, v < z → z < s → gD z) →
            ∃ v, v < u ∧ ∀ z, v < z → z < s → gD z := by
          intro u hs₁u hus h_above
          cases h_body u hs₁u hus with
          | inl h => exact h
          | inr h =>
            obtain ⟨_, v', huv', hv's, hgDv'⟩ := h
            obtain ⟨v₂, hv₂v', hgDv₂⟩ := h_above v' huv' hv's
            exact absurd (hgDv₂ v' hv₂v' hv's) hgDv'
        have h_cofinal_u_init :
            ∃ v, v < u_init ∧ ∀ w, v < w → w < s → gD w := by
          cases h_body u_init hs₁_ui hui_s with
          | inl h => exact h
          | inr h =>
            obtain ⟨_, v', hv'ui, hv's, hgDv'⟩ := h
            exact absurd (hgD_init v' hv'ui hv's) hgDv'
        have hu_init_compl : u_init ∈ compl := by
          intro u hus huu_init
          rcases eq_or_lt_of_le huu_init with rfl | hlt
          · exact h_cofinal_u_init
          · exact ⟨u_init, hlt, fun z huz hzs => hgD_init z huz hzs⟩
        have h_gD_at_compl : ∀ u, u ∈ compl → u < s → gD u := by
          intro u hu hus; obtain ⟨v, hvu, hgDv⟩ := hu u hus le_rfl
          exact hgDv u hvu hus
        have h_cut_lt_compl : ∀ x ∈ cut, ∀ y ∈ compl, x < y := by
          intro x hx y hy; by_contra h; push Not at h
          exact hx (h_compl_uc y x hy h)
        -- No sup in cut (mirrors stavi_snce_gap_detection)
        have h_no_sup : ¬∃ p, IsLUB cut p ∧ p ∈ cut := by
          intro ⟨p, ⟨h_ub, _⟩, hp_cut⟩
          have hps : p < s := h_cut_lt_compl p hp_cut s hs_in_compl
          have hs₁p : s₁ < p := by
            by_contra h; push Not at h
            exact not_le.mpr (lt_of_le_of_lt h hs₁_uf) (h_ub hu_fail_not_compl)
          apply hp_cut
          intro u hus hpu
          rcases eq_or_lt_of_le hpu with rfl | hpu'
          · exact h_cofinal_propagate p hs₁p hus (fun w hpw hws => by
              have : w ∈ compl := by by_contra hw; exact not_le.mpr hpw (h_ub hw)
              exact this w hws le_rfl)
          · have : u ∈ compl := by by_contra hu_cut; exact not_le.mpr hpu' (h_ub hu_cut)
            exact this u hus le_rfl
        have h_not_cut_of_compl : ∀ x, x ∈ compl → x ∉ cut :=
          fun x hx hx_cut => hx_cut hx
        -- No min in complement (mirrors stavi_snce_gap_detection)
        have h_comp_no_min : ¬∃ b, b ∉ cut ∧ ∀ y, y ∉ cut → b ≤ y := by
          intro ⟨b, hb_not_cut, hb_min⟩
          have hb_compl : b ∈ compl := by by_contra h; exact hb_not_cut (show b ∈ cut from h)
          have hbs : b < s := lt_of_le_of_lt (hb_min u_init (h_not_cut_of_compl _ hu_init_compl))
              hui_s
          have hs₁b : s₁ < b := h_compl_gt_s₁ b hb_compl
          have h_below_b : ∀ y, y < b → y ∈ cut := by
            intro y hyb; by_contra hy_not; exact not_lt.mpr (hb_min y hy_not) hyb
          cases h_body b hs₁b hbs with
          | inl h_cof =>
            obtain ⟨v, hvb, hgDv⟩ := h_cof
            by_cases hvs₁ : v ≤ s₁
            · exact hgD_fail (hgDv u_fail (lt_of_le_of_lt hvs₁ hs₁_uf) huf_s)
            · push Not at hvs₁
              have hv_compl : v ∈ compl := by
                intro u hus hvu
                rcases eq_or_lt_of_le hvu with rfl | hvu'
                · exact h_cofinal_propagate v hvs₁ (lt_trans hvb hbs)
                    (fun w hvw hws => ⟨v, hvw, hgDv⟩)
                · exact ⟨v, hvu', hgDv⟩
              exact absurd hvb (not_lt.mpr (hb_min v
                  (show v ∉ cut from fun hv_cut => hv_cut hv_compl)))
          | inr h =>
            obtain ⟨_, v', hbv', hv's, hgDv'⟩ := h
            exact hgDv' (h_gD_at_compl v' (h_compl_uc b v' hb_compl (le_of_lt hbv')) hv's)
        -- Construct Gap
        let γ_gap : Gap M.carrier :=
          ⟨cut, ⟨u_fail, show u_fail ∈ cut from hu_fail_not_compl⟩, h_proper, h_cut_dc, h_no_sup,
              h_comp_no_min⟩
        -- D-definable-on-right: D cofinal in complement, no initial D in cut
        -- Part 1: D cofinal in complement (from gD cofinal → D cofinal)
        have h_D_compl_cofinal : ∃ t, t ∉ γ_gap.cut ∧ ∀ u, u ∉ γ_gap.cut → u ≤ t →
            StaviTemporalTruth M atomMap u D :=
          ⟨u_init, fun h => h hu_init_compl, fun u hu hut =>
            (h_gD_at_compl u (by by_contra h'; exact hu h') (lt_of_le_of_lt hut hui_s)).2⟩
        -- D fails somewhere in (s₁, s): from ¬S'(D, gD)(s)
        have hD_fails : ∃ u_D, s₁ < u_D ∧ u_D < s ∧
            ¬StaviTemporalTruth M atomMap u_D D := by
          by_contra h_all_D; push Not at h_all_D
          apply hNotS'D_gD_s
          exact ⟨s₁, hs₁s,
            fun u hs₁u hus => by
              cases h_body u hs₁u hus with
              | inl h => left; exact h
              | inr h => right; exact ⟨fun v hsv hvu => h_all_D v hsv (lt_trans hvu hus), h.2⟩,
            ⟨u_fail, hs₁_uf, huf_s, hgD_fail⟩,
            ⟨u_init, hs₁_ui, hui_s, hgD_init⟩⟩
        obtain ⟨u_D, hs₁_uD, huD_s, hD_fail_D⟩ := hD_fails
        -- Part 2: No initial D in cut
        -- Mirrors left's h_no_init_compl_D. Strategy: assume ∃ t ∈ cut with D at
        -- all cut points ≥ t. Construct S'(D, gD)(s) with bound t contradicting
        -- hNotS'D_gD_s. Body: u ∈ cut uses right disjunct (D from hDt), u ∈ compl
        -- uses left disjunct (from compl defn). Fail: u_fail ∈ cut with ¬gD.
        -- Init: u_init ∈ compl with gD on (u_init, s).
        have h_no_init_cut_D : ¬∃ t, t ∈ γ_gap.cut ∧ ∀ u, t ≤ u → u ∈ γ_gap.cut →
            StaviTemporalTruth M atomMap u D := by
          intro ⟨t, ht_cut, hDt⟩
          by_cases htu : t ≤ u_D
          · exact hD_fail_D (hDt u_D htu (show u_D ∉ compl from fun h => hD_fail_D
              (h_gD_at_compl u_D h huD_s).2))
          · push Not at htu
            -- u_D < t. Construct S'(D, gD)(s) with bound t, contradicting hNotS'D_gD_s.
            -- All points in (t, s) have D: cut points ≥ t get D from hDt,
            -- compl points get gD → D from h_gD_at_compl.
            apply hNotS'D_gD_s
            have hts : t < s := h_cut_lt_compl t ht_cut s hs_in_compl
            refine ⟨t, hts, ?_, ?_, ?_⟩
            · -- Body: ∀ u ∈ (t, s), left or right disjunct
              intro u htu' hus
              have hs₁u : s₁ < u := lt_trans (lt_trans hs₁_uD htu) htu'
              cases h_body u hs₁u hus with
              | inl h => left; exact h
              | inr h =>
                right
                exact ⟨fun v htv hvu => by
                  by_cases hv_compl : v ∈ compl
                  · exact (h_gD_at_compl v hv_compl (lt_trans hvu hus)).2
                  · exact hDt v (le_of_lt htv) (show v ∈ γ_gap.cut from hv_compl), h.2⟩
            · -- Fail: ∃ u ∈ (t, s) with ¬gD(u)
              -- cut has no sup → ∃ u₂ ∈ cut with u₂ > t
              have ⟨u₂, hu₂_cut, htu₂⟩ : ∃ u₂, u₂ ∈ cut ∧ t < u₂ := by
                by_contra h; push Not at h
                exact h_no_sup ⟨t, ⟨fun x hx => h x hx,
                  fun ub hub => hub ht_cut⟩, ht_cut⟩
              have hu₂s : u₂ < s := h_cut_lt_compl u₂ hu₂_cut s hs_in_compl
              have hs₁u₂ : s₁ < u₂ := lt_trans (lt_trans hs₁_uD htu) htu₂
              -- h_body at u₂: left → u₂ ∈ compl contradiction, so right
              rcases h_body u₂ hs₁u₂ hu₂s with ⟨v, hvu₂, hgDv⟩ | ⟨_, v', hv'u₂, hv's, hngD⟩
              · exfalso
                exact hu₂_cut (show u₂ ∈ compl from
                  fun u' hu's hu₂u' => ⟨v, lt_of_lt_of_le hvu₂ hu₂u', hgDv⟩)
              · exact ⟨v', lt_trans htu₂ hv'u₂, hv's, hngD⟩
            · -- Init: ∃ u ∈ (t, s) with gD on (u, s)
              have ht_ui : t < u_init :=
                h_cut_lt_compl t ht_cut u_init hu_init_compl
              exact ⟨u_init, ht_ui, hui_s, hgD_init⟩
        have h_def_right : GapDefinableOnRight M atomMap γ_gap D :=
          ⟨h_D_compl_cofinal, h_no_init_cut_D⟩
        have h_r_def : IsRDefinableGap M atomMap γ_gap r :=
          ⟨D, hD, Or.inr h_def_right⟩
        let γ : RDefinableGap M atomMap r := ⟨γ_gap, h_r_def⟩
        refine ⟨γ, ?_, h_def_right, ?_, ?_⟩
        · -- extendPoint m > Sum.inr γ: m ∉ cut (m is above all cut points)
          have hm_compl : m ∈ compl := h_compl_uc s m hs_in_compl (le_of_lt hsm)
          change @GT.gt (ExtendedCarrier M atomMap r) _ (extendPoint m) (Sum.inr γ)
          exact ⟨fun h => h hm_compl, fun h => h hm_compl⟩
        · -- D at complement points below m
          intro u hum hu_not_cut
          have hu_compl : u ∈ compl := by by_contra h'; exact hu_not_cut h'
          by_cases hus : u < s
          · exact (stavi_truth_mu_at_point u D).mpr (h_gD_at_compl u hu_compl hus).2
          · push Not at hus
            rcases eq_or_lt_of_le hus with rfl | hsu
            · exact (stavi_truth_mu_at_point s D).mpr hDs
            · exact (stavi_truth_mu_at_point u D).mpr (hD_bet u hsu hum)
        · -- U(f,g)^mu at γ
          simp only [TemporalTruth] at hUntl_s
          obtain ⟨s₂, hss₂, hf_s₂, hg_bet⟩ := hUntl_s
          change TemporalTruthMu M atomMap r (Sum.inr γ) (g.untl f)
          have hs_compl : s ∈ compl := hs_in_compl
          refine ⟨extendPoint s₂, ?_, ⟨s₂, rfl⟩,
            (temporal_truth_mu_at_point s₂ f).mpr hf_s₂, ?_⟩
          · -- Sum.inr γ < extendPoint s₂
            show @LT.lt (ExtendedCarrier M atomMap r) _ (Sum.inr γ) (extendPoint s₂)
            have : @LT.lt (ExtendedCarrier M atomMap r) _ (Sum.inr γ) (extendPoint s) :=
              ⟨fun h => h hs_compl, fun h => h hs_compl⟩
            exact lt_trans this ((extendPoint_lt_iff s s₂).mpr hss₂)
          · -- g^mu at mu-points between γ and s₂
            intro u hγu hus₂ hmu
            obtain ⟨p, rfl⟩ := hmu
            apply (temporal_truth_mu_at_point p g).mpr
            have hps₂ : p < s₂ := (extendPoint_lt_iff p s₂).mp hus₂
            by_cases hps : s ≤ p
            · rcases eq_or_lt_of_le hps with rfl | hsp
              · exact hgs
              · exact hg_bet p hsp hps₂
            · push Not at hps
              have hp_compl : p ∈ compl := by
                by_contra hp_cut
                exact not_le.mpr hγu ((extendPoint_le_gap_iff p γ).mpr hp_cut)
              exact (h_gD_at_compl p hp_compl hps).1
      · -- Backward: gap conditions → std_snce(compound, D)(m)
        -- Mirrors left base.snce backward with direction reversed
        -- Left backward: gap above m, s = cut point above m+t_pt, S(f,g)^mu → compound above m
        -- Right backward: gap below m, s = compl point below m where compound holds
        intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hUntl_mu⟩
        -- U(f,g)^mu(γ): ∃ t > γ (mu-point), f^mu(t) ∧ g^mu on (γ, t)
        simp only [StaviTemporalTruthMu, TemporalTruthMu] at hUntl_mu
        obtain ⟨t_ext, hγ_t, ⟨t_pt, rfl⟩, hf_t, hg_mu⟩ := hUntl_mu
        -- t_pt is a complement point (above gap)
        have ht_not_cut : t_pt ∉ γ.val.cut := by
          intro h; exact not_lt.mpr ((extendPoint_le_gap_iff t_pt γ).mpr h) hγ_t
        -- m is a complement point (above gap)
        have hm_not_cut : m ∉ γ.val.cut := by
          intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γ).mpr h) hγ_lt
        -- Find complement point s: below m, below t_pt (for g from g^mu on (γ, t_pt))
        have ⟨s, hs_not_cut, hsm, hst⟩ :
            ∃ s, s ∉ γ.val.cut ∧ s < m ∧ s < t_pt := by
          -- complement has no min, so we can find complement points below any complement point.
          -- We need s < m, s > t_pt, s ∉ cut.
          -- Since t_pt ∉ cut and m ∉ cut and cut is downward closed:
          -- any point between t_pt and m that's ∉ cut works, or if t_pt < m, m is one.
          -- But we need s STRICTLY < m.
          -- All complement points > t_pt that are < m work (there are infinitely many since
          -- between any two complement points there's another complement point).
          -- Actually, complement may not be dense. But cut has no sup so cut points go
          -- arbitrarily high. Between cut points and complement points there may be structure.
          -- Simplest: if t_pt < m, find any point between them that's not in cut.
          -- All points above cut are not in cut (cut is downward closed).
          -- But cut could extend above t_pt... no, t_pt ∉ cut and cut is downward closed,
          -- so ALL points ≥ t_pt are ∉ cut? NO! Cut is downward closed means:
          -- x ∈ cut ∧ y ≤ x → y ∈ cut. So if t_pt ∉ cut, then no point ≥ t_pt is in cut?
          -- NO: cut is downward closed, so if x ∈ cut, any y ≤ x is in cut.
          -- But there CAN be cut points above t_pt if t_pt is not in cut.
          -- Example: cut = (-∞, 0) ∪ {1}, then 0.5 ∉ cut but 1 ∈ cut. But this contradicts
          -- downward closure: 0.5 ≤ 1 would require 0.5 ∈ cut.
          -- So actually, if t_pt ∉ cut and cut is downward closed, then ∀ u ≥ t_pt, u ∉ cut.
          -- Great! So any point ≥ t_pt is ∉ cut.
          -- We need s with t_pt < s < m. By linear order density? Not necessarily dense.
          -- But m and t_pt are carrier points. There might not be a carrier point between them.
          -- We need to handle the case t_pt < m vs t_pt ≥ m separately.
          by_cases htm : t_pt < m
          · -- Need s with t_pt < s < m, s ∉ cut
            -- Since complement has no minimum (relative to points above gap), and m
            -- is in complement,
            -- there exists a complement point below m that is above γ.
            -- All points above t_pt are complement (since cut is downward closed and t_pt ∉ cut).
            -- So any carrier point between t_pt and m works.
            -- But are there carrier points between t_pt and m?
            -- Not necessarily in a discrete order! t_pt could be pred(m).
            -- In that case, use t_pt itself as the witness (need t_pt < m, which holds).
            -- Wait, we need s ∉ cut. And t_pt ∉ cut. So s = t_pt works if t_pt < m!
            -- But the problem says s < m AND t_pt < s. We need s STRICTLY above t_pt.
            -- Hmm, do we really need s above t_pt? Let me re-read the left proof.
            -- In left: s was a cut point above BOTH m and t_pt. It needed t_pt < s for g(s).
            -- In right: we need s between γ and m. For g(s), we need t_pt < s so g(s) comes from
            -- g^mu on (γ, t_pt). Wait, actually g^mu on (γ, t_pt) gives g at mu-points between
            -- γ and t_pt. If s > t_pt, then s is NOT between γ and t_pt, so we can't get g(s).
            -- Unless t_pt was the UPPER bound and g^mu goes from γ to t_pt.
            -- U(f,g)^mu(γ) = ∃ t > γ, f(t) ∧ g on (γ, t). So g holds between γ and t_pt.
            -- We need s between γ and t_pt for g(s)! Not above t_pt.
            -- So s should satisfy: γ < s < t_pt (to get g(s)) AND s < m.
            -- If t_pt < m, then γ < s < t_pt < m gives both s < m and s in range for g.
            -- But we need s ∉ cut. Since γ < s: s could be in cut or not.
            -- Actually, cut goes up to γ (cut = below gap), and s > γ so s ∉ cut.
            -- Wait, but cut is downward closed and has no sup. So cut could extend beyond γ.
            -- NO: γ represents a gap between cut and complement. Cut is EXACTLY the set below γ.
            -- And complement = above γ. So for any s with extendPoint s > Sum.inr γ, s ∉ cut.
            -- And for any s with extendPoint s ≤ Sum.inr γ (i.e., s ∈ cut), s IS in cut.
            -- So: s ∈ cut ↔ extendPoint s ≤ Sum.inr γ ↔ s ∈ γ.val.cut (by definition).
            --
            -- So for s > γ (i.e., s ∉ cut), we need γ < s < t_pt (for g) and s < m.
            -- Such s exists because: between γ and t_pt there must be complement points
            -- (complement has no minimum, and t_pt is in complement).
            -- Actually, t_pt ∉ cut, so all we know is extendPoint t_pt > Sum.inr γ.
            -- We need s ∉ cut with s < t_pt.
            -- Since complement has no minimum, there's a complement point below t_pt.
            -- That complement point is also > γ (since all complement points are above the gap).
            -- So ∃ s, s ∉ cut ∧ s < t_pt.
            have ⟨s, hs_not, hs_t⟩ : ∃ s, s ∉ γ.val.cut ∧ s < t_pt := by
              by_contra h_all; push Not at h_all
              exact γ.val.complement_no_min ⟨t_pt, ht_not_cut,
                fun z hz => h_all z hz⟩
            exact ⟨s, hs_not, lt_trans hs_t htm, hs_t⟩
          · -- t_pt ≥ m: need s < m ≤ t_pt, s ∉ cut
            push Not at htm
            have ⟨s, hs_not, hs_m⟩ : ∃ s, s ∉ γ.val.cut ∧ s < m := by
              by_contra h_all; push Not at h_all
              exact γ.val.complement_no_min ⟨m, hm_not_cut,
                fun z hz => h_all z hz⟩
            exact ⟨s, hs_not, hs_m, lt_of_lt_of_le hs_m htm⟩
        -- Properties at s (complement point below m):
        -- D(s) from D-between
        have hDs : StaviTemporalTruth M atomMap s D :=
          (stavi_truth_mu_at_point s D).mp (hγ_bet s hsm hs_not_cut)
        -- g(s) from U(f,g)^mu(γ): s is a complement point below t_pt
        have hγs : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (Sum.inr γ) (extendPoint s) := ⟨fun h => hs_not_cut h, fun h => hs_not_cut h⟩
        have hst' : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint s) (extendPoint t_pt) := (extendPoint_lt_iff s t_pt).mpr hst
        have hgs : TemporalTruth M atomMap s g :=
          (temporal_truth_mu_at_point s g).mp
            (hg_mu (extendPoint s) hγs hst' ⟨s, rfl⟩)
        -- U(f,g)(s): witness t_pt with f(t_pt) and g on (s, t_pt)
        have hUntl_s : TemporalTruth M atomMap s (g.untl f) := by
          simp only [TemporalTruth]
          refine ⟨t_pt, hst, (temporal_truth_mu_at_point t_pt f).mp hf_t, fun u hsu hut => ?_⟩
          have hu_not_cut : u ∉ γ.val.cut := by
            intro h
            have : @LE.le (ExtendedCarrier M atomMap r) _ (extendPoint u) (Sum.inr γ) :=
              (extendPoint_le_gap_iff u γ).mpr h
            exact not_le.mpr (lt_trans hγs ((extendPoint_lt_iff s u).mpr hsu)) this
          have hγu : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (Sum.inr γ) (extendPoint u) :=
            ⟨fun h => hu_not_cut h, fun h => hu_not_cut h⟩
          have hut' : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (extendPoint u) (extendPoint t_pt) := (extendPoint_lt_iff u t_pt).mpr hut
          exact (temporal_truth_mu_at_point u g).mp
            (hg_mu (extendPoint u) hγu hut' ⟨u, rfl⟩)
        -- D on (s, m): complement points between s and m have D
        have hD_bet_sm : ∀ u, s < u → u < m → StaviTemporalTruth M atomMap u D := by
          intro u hsu hum
          have hu_not_cut : u ∉ γ.val.cut := by
            intro h
            have : @LE.le (ExtendedCarrier M atomMap r) _ (extendPoint u) (Sum.inr γ) :=
              (extendPoint_le_gap_iff u γ).mpr h
            exact not_le.mpr (lt_trans hγs ((extendPoint_lt_iff s u).mpr hsu)) this
          exact (stavi_truth_mu_at_point u D).mp (hγ_bet u hum hu_not_cut)
        -- Extract gap definability conditions
        obtain ⟨⟨t_D, ht_D_not, hD_init⟩, h_no_final_D⟩ := hγ_def
        -- Helper: cut points < complement points
        have h_cut_lt : ∀ x, x ∈ γ.val.cut → ∀ y, y ∉ γ.val.cut → x < y := by
          intro x hx y hy; by_contra h; push Not at h
          exact hy (γ.val.downward_closed x y hx h)
        -- Helper: ¬D witnesses at cut points
        have h_neg_final : ∀ t, t ∈ γ.val.cut →
            ∃ w, w ∈ γ.val.cut ∧ t ≤ w ∧ ¬StaviTemporalTruth M atomMap w D := by
          intro t ht; by_contra h_all; push Not at h_all
          exact h_no_final_D ⟨t, ht, fun w htw hw_cut => h_all w hw_cut htw⟩
        -- Get a cut point for S'(⊤, g∧D) bound
        have ⟨c₀, hc₀_cut⟩ : ∃ c₀, c₀ ∈ γ.val.cut := by
          obtain ⟨z, hz⟩ := γ.val.nonempty
          exact ⟨z, hz⟩
        have hc₀s : c₀ < s := h_cut_lt c₀ hc₀_cut s hs_not_cut
        -- g∧D at complement points below s
        have h_gD_compl : ∀ u, u < s → u ∉ γ.val.cut →
            TemporalTruth M atomMap u g ∧ StaviTemporalTruth M atomMap u D := by
          intro u hus hu_not_cut
          constructor
          · -- g from g^mu on (γ, t_pt): u is between γ and s < t_pt
            have hγu : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
                (Sum.inr γ) (extendPoint u) :=
              ⟨fun h => hu_not_cut h, fun h => hu_not_cut h⟩
            have hut' : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
                (extendPoint u) (extendPoint t_pt) :=
              lt_trans ((extendPoint_lt_iff u s).mpr hus) hst'
            exact (temporal_truth_mu_at_point u g).mp
              (hg_mu (extendPoint u) hγu hut' ⟨u, rfl⟩)
          · -- D from hγ_bet: u < m and u ∉ cut
            exact (stavi_truth_mu_at_point u D).mp
              (hγ_bet u (lt_trans hus hsm) hu_not_cut)
        refine ⟨s, hsm, ⟨hDs, hgs, hUntl_s, ?_, ?_⟩, hD_bet_sm⟩
        · -- S'(⊤, g∧D)(s): bound c₀ (a cut point below s)
          refine ⟨c₀, hc₀s, ?_, ?_, ?_⟩
          · -- Condition (1): body
            intro u hc₀u hus
            by_cases hu_not_cut : u ∉ γ.val.cut
            · -- u ∉ cut (complement): left disjunct (gD cofinal below u)
              left
              have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
                by_contra h_all; push Not at h_all
                exact γ.val.complement_no_min ⟨u, hu_not_cut, fun z hz => h_all z hz⟩
              exact ⟨y, hyu, fun w hyw hws =>
                h_gD_compl w hws (fun h_cut =>
                  hy_not (γ.val.downward_closed w y h_cut (le_of_lt hyw)))⟩
            · -- u ∈ cut: right disjunct (⊤ trivial + ¬gD witness)
              push Not at hu_not_cut
              right
              refine ⟨fun v _ _ => by simp [TemporalTruth, Formula.top], ?_⟩
              have ⟨y, hy_cut, huy⟩ : ∃ y, y ∈ γ.val.cut ∧ u < y := by
                by_contra h_all; push Not at h_all
                exact γ.val.no_sup ⟨u, ⟨fun x hx => h_all x hx, fun _ hb => hb hu_not_cut⟩,
                  hu_not_cut⟩
              obtain ⟨w, hw_cut, hyw, hDw⟩ := h_neg_final y hy_cut
              exact ⟨w, lt_of_lt_of_le huy hyw, h_cut_lt w hw_cut s hs_not_cut,
                fun ⟨_, hD'⟩ => hDw hD'⟩
          · -- Condition (2): ¬gD failure in (c₀, s)
            have ⟨y, hy_cut, hc₀y⟩ : ∃ y, y ∈ γ.val.cut ∧ c₀ < y := by
              by_contra h_all; push Not at h_all
              exact γ.val.no_sup ⟨c₀, ⟨fun x hx => h_all x hx, fun _ hb => hb hc₀_cut⟩,
                hc₀_cut⟩
            obtain ⟨w, hw_cut, hyw, hDw⟩ := h_neg_final y hy_cut
            exact ⟨w, lt_of_lt_of_le hc₀y hyw, h_cut_lt w hw_cut s hs_not_cut,
              fun ⟨_, hD'⟩ => hDw hD'⟩
          · -- Condition (3): gD initial in (c₀, s)
            have ⟨y, hy_not, hys⟩ : ∃ y, y ∉ γ.val.cut ∧ y < s := by
              by_contra h_all; push Not at h_all
              exact γ.val.complement_no_min ⟨s, hs_not_cut, fun z hz => h_all z hz⟩
            exact ⟨y, h_cut_lt c₀ hc₀_cut y hy_not, hys, fun v hyv hvs =>
              h_gD_compl v hvs (fun hv_cut =>
                hy_not (γ.val.downward_closed v y hv_cut (le_of_lt hyv)))⟩
        · -- ¬S'(D, g∧D)(s): by contradiction using two-step D-transfer argument
          intro ⟨s₁, hs₁s, h_body, h_fail, h_init⟩
          obtain ⟨u_fail, hs₁_uf, huf_s, hgD_fail⟩ := h_fail
          -- u_fail ∈ cut (complement points have gD from h_gD_compl)
          have huf_cut : u_fail ∈ γ.val.cut := by
            by_contra huf_not
            exact hgD_fail (h_gD_compl u_fail huf_s huf_not)
          -- Left disjunct fails at cut points
          have h_left_fails : ∀ u, s₁ < u → u < s → u ∈ γ.val.cut →
              ¬(∃ v, v < u ∧ ∀ w, v < w → w < s →
                TemporalTruth M atomMap w g ∧ StaviTemporalTruth M atomMap w D) := by
            intro u _ _ hu_cut ⟨v, hvu, hgDv⟩
            have hv_cut : v ∈ γ.val.cut := γ.val.downward_closed u v hu_cut (le_of_lt hvu)
            have ⟨y, hy_cut, hvy⟩ : ∃ y, y ∈ γ.val.cut ∧ v < y := by
              by_contra h; push Not at h
              exact γ.val.no_sup ⟨v, ⟨h, fun _ hb => hb hv_cut⟩, hv_cut⟩
            obtain ⟨w', hw'_cut, hyw', hDw'⟩ := h_neg_final y hy_cut
            exact hDw' (hgDv w' (lt_of_lt_of_le hvy hyw')
              (h_cut_lt w' hw'_cut s hs_not_cut)).2
          -- Two-step: D at ALL cut points in (s₁, s)
          have hD_all_cut : ∀ u, s₁ < u → u < s → u ∈ γ.val.cut →
              StaviTemporalTruth M atomMap u D := by
            intro u hs₁u hus hu_cut
            have h_right_u := (h_body u hs₁u hus).resolve_left
              (h_left_fails u hs₁u hus hu_cut)
            obtain ⟨_, v', hv'u, hv's, hgD_v'⟩ := h_right_u
            have hv'_cut : v' ∈ γ.val.cut := by
              by_contra hv'_not; exact hgD_v' (h_gD_compl v' hv's hv'_not)
            have ⟨u', hu'_cut, huu'⟩ : ∃ u', u' ∈ γ.val.cut ∧ u < u' := by
              by_contra h; push Not at h
              exact γ.val.no_sup ⟨u, ⟨h, fun _ hb => hb hu_cut⟩, hu_cut⟩
            have hu's : u' < s := h_cut_lt u' hu'_cut s hs_not_cut
            have h_right_u' := (h_body u' (lt_trans hs₁u huu') hu's).resolve_left
              (h_left_fails u' (lt_trans hs₁u huu') hu's hu'_cut)
            exact h_right_u'.1 u hs₁u huu'
          -- s₁ ∈ cut (if ∉ cut, u_fail also ∉ cut — contradiction)
          have hs₁_cut : s₁ ∈ γ.val.cut := by
            by_contra hs₁_not
            exact not_le.mpr (h_cut_lt u_fail huf_cut s₁ hs₁_not) (le_of_lt hs₁_uf)
          have ⟨t₀, ht₀_cut, hs₁t₀⟩ : ∃ t₀, t₀ ∈ γ.val.cut ∧ s₁ < t₀ := by
            by_contra h; push Not at h
            exact γ.val.no_sup ⟨s₁, ⟨h, fun _ hb => hb hs₁_cut⟩, hs₁_cut⟩
          exact h_no_final_D ⟨t₀, ht₀_cut, fun u ht₀u hu_cut =>
            hD_all_cut u (lt_of_lt_of_le hs₁t₀ ht₀u)
              (h_cut_lt u hu_cut s hs_not_cut) hu_cut⟩
    | snce g f _ _ =>
      -- rightFormulaBase D (.snce f g) = S'(g ∧ S(f,g), D)
      -- Mirrors left base.untl with stavi_snce_gap_detection
      simp only [rightFormulaBase]
      rw [stavi_snce_gap_detection (.conj (.base g) (.base (.snce g f))) D hD m]
      constructor
      · -- Forward: cut-point truth of g ∧ S(f,g) → S(f,g)^mu at γ
        intro ⟨γ, s_bound, hγ_lt, hs_in, hγ_def, hγ_bet, hX_cut⟩
        refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
        simp only [StaviTemporalTruthMu, TemporalTruthMu]
        -- Need S(f,g)^mu at γ: ∃ s < γ (mu), f^mu(s) ∧ g^mu on (s, γ)
        -- Pick a cut point u₀ above s_bound
        have ⟨u₀, hu₀_in, hu₀s⟩ : ∃ u₀, u₀ ∈ γ.val.cut ∧ s_bound < u₀ := by
          by_contra h_all; push Not at h_all
          exact γ.val.no_sup ⟨s_bound, ⟨fun z hz => h_all z hz, fun _ hb => hb hs_in⟩, hs_in⟩
        have hX_u₀ := hX_cut u₀ hu₀_in hu₀s
        simp only [StaviTemporalTruth, TemporalTruth] at hX_u₀
        obtain ⟨hg_u₀, t₁, ht₁u₀, hf_t₁, hg_between⟩ := hX_u₀
        -- t₁ ∈ cut (since t₁ < u₀ and u₀ ∈ cut, cut is downward closed)
        have ht₁_in : t₁ ∈ γ.val.cut :=
          γ.val.downward_closed u₀ t₁ hu₀_in (le_of_lt ht₁u₀)
        -- Witness: s = extendPoint t₁
        refine ⟨extendPoint t₁, ⟨ht₁_in, fun h => h ht₁_in⟩, ⟨t₁, rfl⟩,
          (temporal_truth_mu_at_point t₁ f).mpr hf_t₁, fun v hvt₁ hvγ hmu => ?_⟩
        obtain ⟨v₀, rfl⟩ := hmu
        have hv₀_in : v₀ ∈ γ.val.cut :=
          (extendPoint_le_gap_iff v₀ γ).mp (le_of_lt hvγ)
        have hv₀_t₁ : t₁ < v₀ := (extendPoint_lt_iff t₁ v₀).mp hvt₁
        apply (temporal_truth_mu_at_point v₀ g).mpr
        by_cases hv_u₀ : v₀ < u₀
        · exact hg_between v₀ hv₀_t₁ hv_u₀
        · push Not at hv_u₀
          have hv₀_sb : s_bound < v₀ := lt_of_lt_of_le hu₀s hv_u₀
          exact (hX_cut v₀ hv₀_in hv₀_sb).1
      · -- Backward: S(f,g)^mu at γ → cut-point truth of g ∧ S(f,g)
        intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hSA⟩
        simp only [StaviTemporalTruthMu, TemporalTruthMu] at hSA
        obtain ⟨s, hsγ, hmu_s, hf_s, hg_mu⟩ := hSA
        obtain ⟨t₁, rfl⟩ := hmu_s
        have ht₁_in : t₁ ∈ γ.val.cut :=
          (extendPoint_le_gap_iff t₁ γ).mp (le_of_lt hsγ)
        refine ⟨γ, t₁, hγ_lt, ht₁_in, hγ_def, hγ_bet, fun u hu_in hu_t₁ => ?_⟩
        simp only [StaviTemporalTruth, TemporalTruth]
        constructor
        · -- g(u): u is a cut point between t₁ and γ
          have hγu : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (extendPoint u) (Sum.inr γ) := by
            exact ⟨hu_in, fun h => h hu_in⟩
          have hut₁ : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (extendPoint t₁) (extendPoint u) :=
            (extendPoint_lt_iff t₁ u).mpr hu_t₁
          exact (temporal_truth_mu_at_point u g).mp
            (hg_mu (extendPoint u) hut₁ hγu ⟨u, rfl⟩)
        · -- S(f,g)(u): use t₁ as witness
          refine ⟨t₁, hu_t₁, (temporal_truth_mu_at_point t₁ f).mp hf_s, fun v htv hvu => ?_⟩
          have hv_in : v ∈ γ.val.cut := by
            exact γ.val.downward_closed u v hu_in (le_of_lt hvu)
          have hγv : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (extendPoint v) (Sum.inr γ) := ⟨hv_in, fun h => h hv_in⟩
          have hvt₁ : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (extendPoint t₁) (extendPoint v) :=
            (extendPoint_lt_iff t₁ v).mpr htv
          exact (temporal_truth_mu_at_point v g).mp
            (hg_mu (extendPoint v) hvt₁ hγv ⟨v, rfl⟩)
  | neg A ih =>
    simp only [rightFormula, StaviTemporalTruthMu]
    constructor
    · intro ⟨hS, hNot⟩
      have hS' : StaviTemporalTruthMu M atomMap r (extendPoint m)
          (.stavi_snce (.base Formula.top) D) := by
        simp only [StaviTemporalTruthMu]; exact hS
      obtain ⟨γ, _s_bound, hγ_lt, _hs_in, hγ_def, hγ_bet, _⟩ :=
        (stavi_snce_gap_detection (.base Formula.top) D hD m).mp hS'
      have hNot' : ¬(∃ (γ' : RDefinableGap M atomMap r),
          extendPoint m > Sum.inr γ' ∧
          GapDefinableOnRight M atomMap γ'.val D ∧
          (∀ u, u < m → u ∉ γ'.val.cut → StaviTemporalTruthMu M atomMap r (extendPoint u) D) ∧
          StaviTemporalTruthMu M atomMap r (Sum.inr γ') A) := by
        rwa [← ih m]
      refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
      intro hA_at_γ
      exact hNot' ⟨γ, hγ_lt, hγ_def, hγ_bet, hA_at_γ⟩
    · intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hNot_A⟩
      constructor
      · have h_compl : ∃ x, x ∈ γ.val.cut := by
          obtain ⟨x, hx⟩ := γ.val.nonempty
          exact ⟨x, hx⟩
        obtain ⟨s_b, hs_b⟩ := h_compl
        have hTop_cut : ∀ u : M.carrier, u ∈ γ.val.cut → s_b < u →
            StaviTemporalTruth M atomMap u (.base Formula.top) := by
          intro u _ _
          simp only [StaviTemporalTruth, TemporalTruth, Formula.top]; exact id
        have := (stavi_snce_gap_detection (.base Formula.top) D hD m).mpr
          ⟨γ, s_b, hγ_lt, hs_b, hγ_def, hγ_bet, hTop_cut⟩
        simp only [StaviTemporalTruthMu] at this
        exact this
      · rw [ih m]
        intro ⟨γ', hγ'_lt, hγ'_def, hγ'_bet, hA_at_γ'⟩
        have hm_not : m ∉ γ.val.cut := by
          intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γ).mpr h) hγ_lt
        have hm_not' : m ∉ γ'.val.cut := by
          intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γ').mpr h) hγ'_lt
        have hγ_bet_std : ∀ u, u < m → u ∉ γ.val.cut →
            StaviTemporalTruth M atomMap u D := by
          intro u hum hu_not
          exact (stavi_truth_mu_at_point u D).mp (hγ_bet u hum hu_not)
        have hγ'_bet_std : ∀ u, u < m → u ∉ γ'.val.cut →
            StaviTemporalTruth M atomMap u D := by
          intro u hum hu_not
          exact (stavi_truth_mu_at_point u D).mp (hγ'_bet u hum hu_not)
        have heq : γ.val = γ'.val :=
          gap_detection_unique_right hγ_def hγ'_def hγ_bet_std hγ'_bet_std hm_not hm_not'
        have : γ = γ' := Subtype.ext heq
        rw [this] at hNot_A
        exact hNot_A hA_at_γ'
  | conj A B ihA ihB =>
    simp only [rightFormula, StaviTemporalTruthMu]
    constructor
    · intro ⟨hA, hB⟩
      obtain ⟨γA, hγA_lt, hγA_def, hγA_bet, hγA_val⟩ := (ihA m).mp hA
      obtain ⟨γB, hγB_lt, hγB_def, hγB_bet, hγB_val⟩ := (ihB m).mp hB
      have hm_not_A : m ∉ γA.val.cut := by
        intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γA).mpr h) hγA_lt
      have hm_not_B : m ∉ γB.val.cut := by
        intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γB).mpr h) hγB_lt
      have hγA_bet' : ∀ u, u < m → u ∉ γA.val.cut →
          StaviTemporalTruth M atomMap u D := by
        intro u hum hu_not
        exact (stavi_truth_mu_at_point u D).mp (hγA_bet u hum hu_not)
      have hγB_bet' : ∀ u, u < m → u ∉ γB.val.cut →
          StaviTemporalTruth M atomMap u D := by
        intro u hum hu_not
        exact (stavi_truth_mu_at_point u D).mp (hγB_bet u hum hu_not)
      have heq : γA.val = γB.val :=
        gap_detection_unique_right hγA_def hγB_def hγA_bet' hγB_bet' hm_not_A hm_not_B
      refine ⟨γA, hγA_lt, hγA_def, hγA_bet, ?_, ?_⟩
      · exact hγA_val
      · have : γA = γB := Subtype.ext heq
        rw [this]
        exact hγB_val
    · intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hA_val, hB_val⟩
      exact ⟨(ihA m).mpr ⟨γ, hγ_lt, hγ_def, hγ_bet, hA_val⟩,
             (ihB m).mpr ⟨γ, hγ_lt, hγ_def, hγ_bet, hB_val⟩⟩
  | stavi_untl A B ihA ihB =>
    -- rightFormula (.stavi_untl A B) D = .std_snce compound D
    -- compound = D ∧ B ∧ U'(A,B) ∧ S'(⊤, B∧D) ∧ ¬S'(D, B∧D)
    -- Same compound decomposition as right base.untl with U'(A,B) instead of U(f,g)
    simp only [rightFormula]
    rw [stavi_truth_mu_at_point m (.std_snce _ D)]
    simp only [StaviTemporalTruth]
    constructor
    · -- Forward: std_snce(compound, D)(m) → gap conditions
      intro ⟨s, hsm, ⟨hDs, hBs, hUntl_s, hS'_BD_s, hNotS'D_BD_s⟩, hD_bet⟩
      obtain ⟨s₁, hs₁s, h_body, h_fail, h_init⟩ := hS'_BD_s
      obtain ⟨u_fail, hs₁_uf, huf_s, hBD_fail⟩ := h_fail
      obtain ⟨u_init, hs₁_ui, hui_s, hBD_init⟩ := h_init
      -- Gap construction (identical to base.untl)
      let bD : M.carrier → Prop := fun u =>
        StaviTemporalTruth M atomMap u B ∧ StaviTemporalTruth M atomMap u D
      let compl : Set M.carrier :=
        {x | ∀ u, u < s → x ≤ u → ∃ v, v < u ∧ ∀ w, v < w → w < s → bD w}
      have hs_in_compl : s ∈ compl :=
        fun u hus hsu => absurd (lt_of_le_of_lt hsu hus) (lt_irrefl s)
      have hu_fail_not_compl : u_fail ∉ compl := by
        intro h; obtain ⟨v, hvuf, hBDv⟩ := h u_fail huf_s le_rfl
        exact hBD_fail (hBDv u_fail hvuf huf_s)
      have h_compl_gt_uf : ∀ x ∈ compl, u_fail < x := by
        intro x hx; by_contra h; push Not at h
        exact hu_fail_not_compl (fun u hus huf => hx u hus (le_trans h huf))
      have h_compl_uc : ∀ x y, x ∈ compl → x ≤ y → y ∈ compl :=
        fun x y hx hxy u hus hyu => hx u hus (le_trans (le_trans hxy hyu) le_rfl)
      let cut : Set M.carrier := {x | x ∉ compl}
      have h_cut_dc : ∀ x y, x ∈ cut → y ≤ x → y ∈ cut := by
        intro x y hx hyx hy; exact hx (h_compl_uc y x hy hyx)
      have h_proper : cut ≠ Set.univ := by
        intro h; have := h ▸ Set.mem_univ s; exact this hs_in_compl
      have h_cofinal_propagate :
          ∀ u, s₁ < u → u < s →
          (∀ w, u < w → w < s → ∃ v, v < w ∧ ∀ z, v < z → z < s → bD z) →
          ∃ v, v < u ∧ ∀ z, v < z → z < s → bD z := by
        intro u hs₁u hus h_above
        cases h_body u hs₁u hus with
        | inl h => exact h
        | inr h =>
          obtain ⟨_, v', huv', hv's, hBDv'⟩ := h
          obtain ⟨v₂, hv₂v', hBDv₂⟩ := h_above v' huv' hv's
          exact absurd (hBDv₂ v' hv₂v' hv's) hBDv'
      have hu_init_compl : u_init ∈ compl := by
        intro u hus huu_init
        rcases eq_or_lt_of_le huu_init with rfl | hlt
        · cases h_body u_init hs₁_ui hui_s with
          | inl h => exact h
          | inr h =>
            obtain ⟨_, v', hv'ui, hv's, hBDv'⟩ := h
            exact absurd (hBD_init v' hv'ui hv's) hBDv'
        · exact ⟨u_init, hlt, fun z huz hzs => hBD_init z huz hzs⟩
      have h_bD_at_compl : ∀ u, u ∈ compl → u < s → bD u := by
        intro u hu hus; obtain ⟨v, hvu, hBDv⟩ := hu u hus le_rfl
        exact hBDv u hvu hus
      have h_cut_lt_compl : ∀ x ∈ cut, ∀ y ∈ compl, x < y := by
        intro x hx y hy; by_contra h; push Not at h
        exact hx (h_compl_uc y x hy h)
      have h_no_sup : ¬∃ p, IsLUB cut p ∧ p ∈ cut := by
        intro ⟨p, ⟨h_ub, _⟩, hp_cut⟩
        have hps : p < s := h_cut_lt_compl p hp_cut s hs_in_compl
        have hs₁p : s₁ < p := by
          by_contra h; push Not at h
          exact not_le.mpr (lt_of_le_of_lt h hs₁_uf) (h_ub hu_fail_not_compl)
        apply hp_cut
        intro u hus hpu
        rcases eq_or_lt_of_le hpu with rfl | hpu'
        · exact h_cofinal_propagate p hs₁p hus (fun w hpw hws => by
            have : w ∈ compl := by by_contra hw; exact not_le.mpr hpw (h_ub hw)
            exact this w hws le_rfl)
        · have : u ∈ compl := by by_contra hu_cut; exact not_le.mpr hpu' (h_ub hu_cut)
          exact this u hus le_rfl
      have h_not_cut_of_compl : ∀ x, x ∈ compl → x ∉ cut :=
        fun x hx hx_cut => hx_cut hx
      have h_comp_no_min : ¬∃ b, b ∉ cut ∧ ∀ y, y ∉ cut → b ≤ y := by
        intro ⟨b, hb_not_cut, hb_min⟩
        have hb_compl : b ∈ compl := by by_contra h; exact hb_not_cut (show b ∈ cut from h)
        have hbs : b < s := lt_of_le_of_lt (hb_min u_init (h_not_cut_of_compl _ hu_init_compl))
            hui_s
        have hs₁b : s₁ < b := lt_trans hs₁_uf (h_compl_gt_uf b hb_compl)
        have h_below_b : ∀ y, y < b → y ∈ cut := by
          intro y hyb; by_contra hy_not; exact not_lt.mpr (hb_min y hy_not) hyb
        cases h_body b hs₁b hbs with
        | inl h_cof =>
          obtain ⟨v, hvb, hBDv⟩ := h_cof
          by_cases hvs₁ : v ≤ s₁
          · exact hBD_fail (hBDv u_fail (lt_of_le_of_lt hvs₁ hs₁_uf) huf_s)
          · push Not at hvs₁
            have hv_compl : v ∈ compl := by
              intro u hus hvu
              rcases eq_or_lt_of_le hvu with rfl | hvu'
              · exact h_cofinal_propagate v hvs₁ (lt_trans hvb hbs)
                  (fun w hvw hws => ⟨v, hvw, hBDv⟩)
              · exact ⟨v, hvu', hBDv⟩
            exact absurd hvb (not_lt.mpr (hb_min v
                (show v ∉ cut from fun hv_cut => hv_cut hv_compl)))
        | inr h =>
          obtain ⟨_, v', hbv', hv's, hBDv'⟩ := h
          exact hBDv' (h_bD_at_compl v' (h_compl_uc b v' hb_compl (le_of_lt hbv')) hv's)
      let γ_gap : Gap M.carrier :=
        ⟨cut, ⟨u_fail, show u_fail ∈ cut from hu_fail_not_compl⟩, h_proper, h_cut_dc, h_no_sup,
            h_comp_no_min⟩
      have h_D_compl_cofinal : ∃ t, t ∉ γ_gap.cut ∧ ∀ u, u ∉ γ_gap.cut → u ≤ t →
          StaviTemporalTruth M atomMap u D :=
        ⟨u_init, fun h => h hu_init_compl, fun u hu hut =>
          (h_bD_at_compl u (by by_contra h'; exact hu h') (lt_of_le_of_lt hut hui_s)).2⟩
      have hD_fails : ∃ u_D, s₁ < u_D ∧ u_D < s ∧
          ¬StaviTemporalTruth M atomMap u_D D := by
        by_contra h_all_D; push Not at h_all_D
        apply hNotS'D_BD_s
        exact ⟨s₁, hs₁s,
          fun u hs₁u hus => by
            cases h_body u hs₁u hus with
            | inl h => left; exact h
            | inr h => right; exact ⟨fun v hsv hvu => h_all_D v hsv (lt_trans hvu hus), h.2⟩,
          ⟨u_fail, hs₁_uf, huf_s, hBD_fail⟩,
          ⟨u_init, hs₁_ui, hui_s, hBD_init⟩⟩
      obtain ⟨u_D, hs₁_uD, huD_s, hD_fail_D⟩ := hD_fails
      have hu_D_not_compl : u_D ∉ compl := by
        intro h; exact hD_fail_D (h_bD_at_compl u_D h huD_s).2
      have h_no_init_cut_D : ¬∃ t, t ∈ γ_gap.cut ∧ ∀ u, t ≤ u → u ∈ γ_gap.cut →
          StaviTemporalTruth M atomMap u D := by
        intro ⟨t, ht_cut, hDt⟩
        by_cases htu : t ≤ u_D
        · exact hD_fail_D (hDt u_D htu (show u_D ∉ compl from hu_D_not_compl))
        · push Not at htu
          apply hNotS'D_BD_s
          have hts : t < s := h_cut_lt_compl t ht_cut s hs_in_compl
          refine ⟨t, hts, ?_, ?_, ?_⟩
          · intro u htu' hus
            have hs₁u : s₁ < u := lt_trans (lt_trans hs₁_uD htu) htu'
            cases h_body u hs₁u hus with
            | inl h => left; exact h
            | inr h =>
              right
              exact ⟨fun v htv hvu => by
                by_cases hv_compl : v ∈ compl
                · exact (h_bD_at_compl v hv_compl (lt_trans hvu hus)).2
                · exact hDt v (le_of_lt htv) (show v ∈ γ_gap.cut from hv_compl), h.2⟩
          · have ⟨u₂, hu₂_cut, htu₂⟩ : ∃ u₂, u₂ ∈ cut ∧ t < u₂ := by
              by_contra h; push Not at h
              exact h_no_sup ⟨t, ⟨fun x hx => h x hx,
                fun ub hub => hub ht_cut⟩, ht_cut⟩
            have hu₂s : u₂ < s := h_cut_lt_compl u₂ hu₂_cut s hs_in_compl
            have hs₁u₂ : s₁ < u₂ := lt_trans (lt_trans hs₁_uD htu) htu₂
            rcases h_body u₂ hs₁u₂ hu₂s with ⟨v, hvu₂, hBDv⟩ | ⟨_, v', hv'u₂, hv's, hngD⟩
            · exfalso
              exact hu₂_cut (show u₂ ∈ compl from
                fun u' hu's hu₂u' => ⟨v, lt_of_lt_of_le hvu₂ hu₂u', hBDv⟩)
            · exact ⟨v', lt_trans htu₂ hv'u₂, hv's, hngD⟩
          · exact ⟨u_init, h_cut_lt_compl t ht_cut u_init hu_init_compl, hui_s, hBD_init⟩
      have h_def_right : GapDefinableOnRight M atomMap γ_gap D :=
        ⟨h_D_compl_cofinal, h_no_init_cut_D⟩
      have h_r_def : IsRDefinableGap M atomMap γ_gap r :=
        ⟨D, hD, Or.inr h_def_right⟩
      let γ : RDefinableGap M atomMap r := ⟨γ_gap, h_r_def⟩
      refine ⟨γ, ?_, h_def_right, ?_, ?_⟩
      · have hm_compl : m ∈ compl := h_compl_uc s m hs_in_compl (le_of_lt hsm)
        change @GT.gt (ExtendedCarrier M atomMap r) _ (extendPoint m) (Sum.inr γ)
        exact ⟨fun h => h hm_compl, fun h => h hm_compl⟩
      · intro u hum hu_not_cut
        have hu_compl : u ∈ compl := by by_contra h'; exact hu_not_cut h'
        by_cases hus : u < s
        · exact (stavi_truth_mu_at_point u D).mpr (h_bD_at_compl u hu_compl hus).2
        · push Not at hus
          rcases eq_or_lt_of_le hus with rfl | hsu
          · exact (stavi_truth_mu_at_point s D).mpr hDs
          · exact (stavi_truth_mu_at_point u D).mpr (hD_bet u hsu hum)
      · -- U'(A,B)^mu at γ: extend FO table of U'(A,B)(s) from (s, s₂) to (γ, s₂)
        obtain ⟨s₂, hss₂, h_body_AB, ⟨wf_AB, hswf, hwfs₂, hBwf_AB⟩,
                ⟨wi_AB, hswi, hwis₂, hBwi_AB⟩⟩ := hUntl_s
        simp only [StaviTemporalTruthMu]
        refine ⟨extendPoint s₂, ?_, ?_, ?_, ?_⟩
        · -- Sum.inr γ < extendPoint s₂: s₂ > s > γ (s₂ ∉ cut)
          have hs₂_compl : s₂ ∈ compl := h_compl_uc s s₂ hs_in_compl (le_of_lt hss₂)
          exact ⟨fun h => h hs₂_compl, fun h => h hs₂_compl⟩
        · -- Condition (1): ∀ mu-point u ∈ (γ, s₂), FO body
          intro u hγu hus₂ hmu
          obtain ⟨u_pt, rfl⟩ := hmu
          have hu_pt_not_cut : u_pt ∉ γ_gap.cut := by
            intro h; exact not_lt.mpr (show extendPoint u_pt ≤ Sum.inr γ from h) hγu
          have hu_pt_compl : u_pt ∈ compl := by by_contra h'; exact hu_pt_not_cut h'
          have hu_pt_s₂ : u_pt < s₂ := (extendPoint_lt_iff u_pt s₂).mp hus₂
          by_cases hus : u_pt < s
          · -- u_pt ∈ (γ, s): complement point below s. B holds from h_bD_at_compl.
            left
            refine ⟨extendPoint s, (extendPoint_lt_iff u_pt s).mpr hus, ⟨s, rfl⟩,
              fun w hγw hws hmu_w => ?_⟩
            obtain ⟨w_pt, rfl⟩ := hmu_w
            have hw_pt_s : w_pt < s := (extendPoint_lt_iff w_pt s).mp hws
            have hw_pt_not_cut : w_pt ∉ γ_gap.cut := by
              intro h; exact not_lt.mpr (show extendPoint w_pt ≤ Sum.inr γ from h) hγw
            have hw_pt_compl : w_pt ∈ compl := by by_contra h'; exact hw_pt_not_cut h'
            exact (stavi_truth_mu_at_point w_pt B).mpr (h_bD_at_compl w_pt hw_pt_compl hw_pt_s).1
          · -- u_pt ≥ s: use h_body_AB from U'(A,B)(s)
            push Not at hus
            rcases eq_or_lt_of_le hus with rfl | hsu
            · -- u_pt = s: B-cofinal using wi_AB
              left
              refine ⟨extendPoint wi_AB, (extendPoint_lt_iff s wi_AB).mpr hswi, ⟨wi_AB, rfl⟩,
                fun w hγw hwwi hmu_w => ?_⟩
              obtain ⟨w_pt, rfl⟩ := hmu_w
              have hw_pt_wi : w_pt < wi_AB := (extendPoint_lt_iff w_pt wi_AB).mp hwwi
              have hw_pt_not_cut : w_pt ∉ γ_gap.cut := by
                intro h; exact not_lt.mpr (show extendPoint w_pt ≤ Sum.inr γ from h) hγw
              have hw_pt_compl : w_pt ∈ compl := by by_contra h'; exact hw_pt_not_cut h'
              by_cases hws : w_pt < s
              · exact (stavi_truth_mu_at_point w_pt B).mpr (h_bD_at_compl w_pt hw_pt_compl hws).1
              · push Not at hws
                rcases eq_or_lt_of_le hws with rfl | hsw
                · exact (stavi_truth_mu_at_point s B).mpr hBs
                · exact (stavi_truth_mu_at_point w_pt B).mpr (hBwi_AB w_pt hsw hw_pt_wi)
            · -- u_pt > s: use h_body_AB
              cases h_body_AB u_pt hsu hu_pt_s₂ with
              | inl h_cof =>
                left
                obtain ⟨v, hu_v, hBv⟩ := h_cof
                refine ⟨extendPoint v, (extendPoint_lt_iff u_pt v).mpr hu_v, ⟨v, rfl⟩,
                  fun w hγw hwv hmu_w => ?_⟩
                obtain ⟨w_pt, rfl⟩ := hmu_w
                have hw_pt_v : w_pt < v := (extendPoint_lt_iff w_pt v).mp hwv
                have hw_pt_not_cut : w_pt ∉ γ_gap.cut := by
                  intro h; exact not_lt.mpr (show extendPoint w_pt ≤ Sum.inr γ from h) hγw
                have hw_pt_compl : w_pt ∈ compl := by by_contra h'; exact hw_pt_not_cut h'
                by_cases hws : w_pt < s
                · exact (stavi_truth_mu_at_point w_pt B).mpr (h_bD_at_compl w_pt hw_pt_compl hws).1
                · push Not at hws
                  rcases eq_or_lt_of_le hws with rfl | hsw
                  · exact (stavi_truth_mu_at_point s B).mpr hBs
                  · exact (stavi_truth_mu_at_point w_pt B).mpr (hBv w_pt hsw hw_pt_v)
              | inr h_right =>
                right
                obtain ⟨hA_above, v', hmv', hv'u, hBv'⟩ := h_right
                refine ⟨fun v hv hvs hmu_v => ?_, ?_⟩
                · obtain ⟨v_pt, rfl⟩ := hmu_v
                  exact (stavi_truth_mu_at_point v_pt A).mpr
                    (hA_above v_pt ((extendPoint_lt_iff u_pt v_pt).mp hv)
                      ((extendPoint_lt_iff v_pt s₂).mp hvs))
                · refine ⟨extendPoint v', ?_, (extendPoint_lt_iff v' u_pt).mpr hv'u,
                    ⟨v', rfl⟩, mt (stavi_truth_mu_at_point v' B).mp hBv'⟩
                  have hv'_compl : v' ∈ compl := h_compl_uc s v' hs_in_compl (le_of_lt hmv')
                  exact ⟨fun h => h hv'_compl, fun h => h hv'_compl⟩
        · -- Condition (2): ∃ mu-point ∈ (γ, s₂) with ¬B^mu
          have hwf_compl : wf_AB ∈ compl := h_compl_uc s wf_AB hs_in_compl (le_of_lt hswf)
          refine ⟨extendPoint wf_AB, ?_, (extendPoint_lt_iff wf_AB s₂).mpr hwfs₂,
            ⟨wf_AB, rfl⟩, mt (stavi_truth_mu_at_point wf_AB B).mp hBwf_AB⟩
          exact ⟨fun h => h hwf_compl, fun h => h hwf_compl⟩
        · -- Condition (3): ∃ mu-point ∈ (γ, s₂) with B^mu initial
          have hwi_compl : wi_AB ∈ compl := h_compl_uc s wi_AB hs_in_compl (le_of_lt hswi)
          refine ⟨extendPoint wi_AB, ?_, (extendPoint_lt_iff wi_AB s₂).mpr hwis₂,
            ⟨wi_AB, rfl⟩, fun v hγv hvwi hmu_v => ?_⟩
          · exact ⟨fun h => h hwi_compl, fun h => h hwi_compl⟩
          · obtain ⟨v_pt, rfl⟩ := hmu_v
            have hv_pt_wi : v_pt < wi_AB := (extendPoint_lt_iff v_pt wi_AB).mp hvwi
            have hv_pt_not_cut : v_pt ∉ γ_gap.cut := by
              intro h; exact not_lt.mpr (show extendPoint v_pt ≤ Sum.inr γ from h) hγv
            have hv_pt_compl : v_pt ∈ compl := by by_contra h'; exact hv_pt_not_cut h'
            by_cases hvs : v_pt < s
            · exact (stavi_truth_mu_at_point v_pt B).mpr (h_bD_at_compl v_pt hv_pt_compl hvs).1
            · push Not at hvs
              rcases eq_or_lt_of_le hvs with rfl | hsv
              · exact (stavi_truth_mu_at_point s B).mpr hBs
              · exact (stavi_truth_mu_at_point v_pt B).mpr (hBwi_AB v_pt hsv hv_pt_wi)
    · -- Backward: gap below m with U'(A,B)^mu → std_snce(compound, D)(m)
      -- Mirrors base.untl backward with U'(A,B) replacing U(f,g)
      intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hUA⟩
      simp only [StaviTemporalTruthMu] at hUA
      obtain ⟨s_sa, hs_sa_γ, h_body_sa, ⟨wf_sa, hs_wf, hwf_sa, ⟨wf_pt, rfl⟩, hBwf_sa⟩,
              ⟨wi_sa, hs_wi, hwi_sa, ⟨wi_pt, rfl⟩, hBwi_sa⟩⟩ := hUA
      -- wf_pt, wi_pt are complement points (above gap, between γ and s_sa)
      have hwf_not_cut : wf_pt ∉ γ.val.cut := by
        intro h; exact not_lt.mpr ((extendPoint_le_gap_iff wf_pt γ).mpr h) hs_wf
      have hwi_not_cut : wi_pt ∉ γ.val.cut := by
        intro h; exact not_lt.mpr ((extendPoint_le_gap_iff wi_pt γ).mpr h) hs_wi
      have hm_not_cut : m ∉ γ.val.cut := by
        intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γ).mpr h) hγ_lt
      -- Find complement point s below m, wf_pt, wi_pt
      have ⟨s, hs_not_cut, hsm, hswf, hswi⟩ :
          ∃ s, s ∉ γ.val.cut ∧ s < m ∧ s < wf_pt ∧ s < wi_pt := by
        -- Pick any complement point below all three
        have ⟨s₁, hs₁_not, hs₁_m⟩ : ∃ s₁, s₁ ∉ γ.val.cut ∧ s₁ < m := by
          by_contra h_all; push Not at h_all
          exact γ.val.complement_no_min ⟨m, hm_not_cut, fun z hz => h_all z hz⟩
        have ⟨s₂, hs₂_not, hs₂_wf⟩ : ∃ s₂, s₂ ∉ γ.val.cut ∧ s₂ < wf_pt := by
          by_contra h_all; push Not at h_all
          exact γ.val.complement_no_min ⟨wf_pt, hwf_not_cut, fun z hz => h_all z hz⟩
        have ⟨s₃, hs₃_not, hs₃_wi⟩ : ∃ s₃, s₃ ∉ γ.val.cut ∧ s₃ < wi_pt := by
          by_contra h_all; push Not at h_all
          exact γ.val.complement_no_min ⟨wi_pt, hwi_not_cut, fun z hz => h_all z hz⟩
        -- Take the minimum of s₁, s₂, s₃ — but simpler: find a complement point below all
        have ⟨s₀, hs₀_not, hs₀_min⟩ : ∃ s₀, s₀ ∉ γ.val.cut ∧
            s₀ < min s₁ (min s₂ s₃) := by
          have hmin_not : min s₁ (min s₂ s₃) ∉ γ.val.cut := by
            intro h_in
            rcases le_or_gt s₁ (min s₂ s₃) with h | h
            · simp only [min_eq_left h] at h_in; exact hs₁_not h_in
            · simp only [min_eq_right (le_of_lt h)] at h_in
              rcases le_or_gt s₂ s₃ with h' | h'
              · simp only [min_eq_left h'] at h_in; exact hs₂_not h_in
              · simp only [min_eq_right (le_of_lt h')] at h_in; exact hs₃_not h_in
          by_contra h_all; push Not at h_all
          exact γ.val.complement_no_min ⟨min s₁ (min s₂ s₃), hmin_not,
            fun z hz => h_all z hz⟩
        exact ⟨s₀, hs₀_not,
          lt_of_lt_of_le hs₀_min (le_trans (min_le_left _ _) (le_of_lt hs₁_m)),
          lt_of_lt_of_le hs₀_min (le_trans (min_le_right _ _)
              (le_trans (min_le_left _ _) (le_of_lt hs₂_wf))),
          lt_of_lt_of_le hs₀_min (le_trans (min_le_right _ _)
              (le_trans (min_le_right _ _) (le_of_lt hs₃_wi)))⟩
      have hγs : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
          (Sum.inr γ) (extendPoint s) := ⟨fun h => hs_not_cut h, fun h => hs_not_cut h⟩
      -- D(s) from D-between
      have hDs : StaviTemporalTruth M atomMap s D :=
        (stavi_truth_mu_at_point s D).mp (hγ_bet s hsm hs_not_cut)
      -- B(s) from U' init condition: s between γ and wi_pt
      have hBs : StaviTemporalTruth M atomMap s B :=
        (stavi_truth_mu_at_point s B).mp
          (hBwi_sa (extendPoint s) hγs
            ((extendPoint_lt_iff s wi_pt).mpr hswi) ⟨s, rfl⟩)
      -- U'(A,B)(s): restrict FO table from (γ, s_sa) to (s, s_sa)
      have hUA_s : StaviTemporalTruth M atomMap s (.stavi_untl A B) := by
        -- `(r := r)` pins the implicit rank that the old `show` line was there to fix,
        -- and removes the second `?r : Nat` goal the bare `apply` left behind.
        apply (stavi_truth_mu_at_point (r := r) s (.stavi_untl A B)).mp
        simp only [StaviTemporalTruthMu]
        refine ⟨s_sa, lt_trans ((extendPoint_lt_iff s wf_pt).mpr hswf) hwf_sa, ?_, ?_, ?_⟩
        · intro u hsu hus_sa hmu
          cases h_body_sa u (lt_trans hγs hsu) hus_sa hmu with
          | inl h_cof =>
            left
            obtain ⟨v, hvu, hmu_v, hBv⟩ := h_cof
            exact ⟨v, hvu, hmu_v, fun w hsw hwv hmu_w => hBv w (lt_trans hγs hsw) hwv hmu_w⟩
          | inr h_right =>
            right
            obtain ⟨hA_below, v', hv'γ, hv'u, hmu_v', hBv'⟩ := h_right
            have hv's : extendPoint s < v' := by
              by_contra h; push Not at h
              exact hBv' (hBwi_sa v' hv'γ
                (lt_of_le_of_lt h ((extendPoint_lt_iff s wi_pt).mpr hswi)) hmu_v')
            exact ⟨hA_below, v', hv's, hv'u, hmu_v', hBv'⟩
        · exact ⟨extendPoint wf_pt, (extendPoint_lt_iff s wf_pt).mpr hswf,
            hwf_sa, ⟨wf_pt, rfl⟩, hBwf_sa⟩
        · exact ⟨extendPoint wi_pt, (extendPoint_lt_iff s wi_pt).mpr hswi,
            hwi_sa, ⟨wi_pt, rfl⟩,
            fun v hsv hvwi hmu => hBwi_sa v (lt_trans hγs hsv) hvwi hmu⟩
      -- D on (s, m)
      have hD_bet_sm : ∀ u, s < u → u < m → StaviTemporalTruth M atomMap u D := by
        intro u hsu hum
        have hu_not_cut : u ∉ γ.val.cut := by
          intro h; exact not_le.mpr (lt_trans hγs ((extendPoint_lt_iff s u).mpr hsu))
            ((extendPoint_le_gap_iff u γ).mpr h)
        exact (stavi_truth_mu_at_point u D).mp (hγ_bet u hum hu_not_cut)
      -- Gap definability
      obtain ⟨⟨t_D, ht_D_not, hD_init⟩, h_no_final_D⟩ := hγ_def
      have h_cut_lt : ∀ x, x ∈ γ.val.cut → ∀ y, y ∉ γ.val.cut → x < y := by
        intro x hx y hy; by_contra h; push Not at h
        exact hy (γ.val.downward_closed x y hx h)
      have h_neg_final : ∀ t, t ∈ γ.val.cut →
          ∃ w, w ∈ γ.val.cut ∧ t ≤ w ∧ ¬StaviTemporalTruth M atomMap w D := by
        intro t ht; by_contra h_all; push Not at h_all
        exact h_no_final_D ⟨t, ht, fun w htw hw_cut => h_all w hw_cut htw⟩
      have ⟨c₀, hc₀_cut⟩ : ∃ c₀, c₀ ∈ γ.val.cut := γ.val.nonempty
      have hc₀s : c₀ < s := h_cut_lt c₀ hc₀_cut s hs_not_cut
      have h_bD_compl : ∀ u, u < s → u ∉ γ.val.cut →
          StaviTemporalTruth M atomMap u B ∧ StaviTemporalTruth M atomMap u D := by
        intro u hus hu_not_cut
        constructor
        · exact (stavi_truth_mu_at_point u B).mp
            (hBwi_sa (extendPoint u) ⟨fun h => hu_not_cut h, fun h => hu_not_cut h⟩
              (lt_trans ((extendPoint_lt_iff u s).mpr hus) ((extendPoint_lt_iff s wi_pt).mpr hswi))
              ⟨u, rfl⟩)
        · exact (stavi_truth_mu_at_point u D).mp (hγ_bet u (lt_trans hus hsm) hu_not_cut)
      refine ⟨s, hsm, ⟨hDs, hBs, hUA_s, ?_, ?_⟩, hD_bet_sm⟩
      · -- S'(⊤, B∧D)(s): bound c₀ (a cut point below s)
        refine ⟨c₀, hc₀s, ?_, ?_, ?_⟩
        · -- Condition (1): body
          intro u hc₀u hus
          by_cases hu_not_cut : u ∉ γ.val.cut
          · left
            have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
              by_contra h_all; push Not at h_all
              exact γ.val.complement_no_min ⟨u, hu_not_cut, fun z hz => h_all z hz⟩
            exact ⟨y, hyu, fun w hyw hws =>
              h_bD_compl w hws (fun h_cut =>
                hy_not (γ.val.downward_closed w y h_cut (le_of_lt hyw)))⟩
          · push Not at hu_not_cut
            right
            refine ⟨fun v _ _ => by simp [TemporalTruth, Formula.top], ?_⟩
            have ⟨y, hy_cut, huy⟩ : ∃ y, y ∈ γ.val.cut ∧ u < y := by
              by_contra h_all; push Not at h_all
              exact γ.val.no_sup ⟨u, ⟨h_all, fun _ hb => hb hu_not_cut⟩, hu_not_cut⟩
            obtain ⟨w, hw_cut, hyw, hDw⟩ := h_neg_final y hy_cut
            exact ⟨w, lt_of_lt_of_le huy hyw, h_cut_lt w hw_cut s hs_not_cut,
              fun ⟨_, hD'⟩ => hDw hD'⟩
        · -- Condition (2): ¬(B∧D) failure
          have ⟨y, hy_cut, hc₀y⟩ : ∃ y, y ∈ γ.val.cut ∧ c₀ < y := by
            by_contra h_all; push Not at h_all
            exact γ.val.no_sup ⟨c₀, ⟨h_all, fun _ hb => hb hc₀_cut⟩, hc₀_cut⟩
          obtain ⟨w, hw_cut, hyw, hDw⟩ := h_neg_final y hy_cut
          exact ⟨w, lt_of_lt_of_le hc₀y hyw, h_cut_lt w hw_cut s hs_not_cut,
            fun ⟨_, hD'⟩ => hDw hD'⟩
        · -- Condition (3): (B∧D) initial
          have ⟨y, hy_not, hys⟩ : ∃ y, y ∉ γ.val.cut ∧ y < s := by
            by_contra h_all; push Not at h_all
            exact γ.val.complement_no_min ⟨s, hs_not_cut, fun z hz => h_all z hz⟩
          exact ⟨y, h_cut_lt c₀ hc₀_cut y hy_not, hys, fun v hyv hvs =>
            h_bD_compl v hvs (fun hv_cut =>
              hy_not (γ.val.downward_closed v y hv_cut (le_of_lt hyv)))⟩
      · -- ¬S'(D, B∧D)(s): two-step D-transfer contradiction
        intro ⟨s₁, hs₁s, h_body, h_fail, h_init⟩
        obtain ⟨u_fail, hs₁_uf, huf_s, hbD_fail⟩ := h_fail
        have huf_cut : u_fail ∈ γ.val.cut := by
          by_contra huf_not
          exact hbD_fail (h_bD_compl u_fail huf_s huf_not)
        have h_left_fails : ∀ u, s₁ < u → u < s → u ∈ γ.val.cut →
            ¬(∃ v, v < u ∧ ∀ w, v < w → w < s →
              StaviTemporalTruth M atomMap w B ∧ StaviTemporalTruth M atomMap w D) := by
          intro u _ _ hu_cut ⟨v, hvu, hbDv⟩
          have hv_cut : v ∈ γ.val.cut := γ.val.downward_closed u v hu_cut (le_of_lt hvu)
          have ⟨y, hy_cut, hvy⟩ : ∃ y, y ∈ γ.val.cut ∧ v < y := by
            by_contra h; push Not at h
            exact γ.val.no_sup ⟨v, ⟨h, fun _ hb => hb hv_cut⟩, hv_cut⟩
          obtain ⟨w', hw'_cut, hyw', hDw'⟩ := h_neg_final y hy_cut
          exact hDw' (hbDv w' (lt_of_lt_of_le hvy hyw')
            (h_cut_lt w' hw'_cut s hs_not_cut)).2
        have hD_all_cut : ∀ u, s₁ < u → u < s → u ∈ γ.val.cut →
            StaviTemporalTruth M atomMap u D := by
          intro u hs₁u hus hu_cut
          have h_right_u := (h_body u hs₁u hus).resolve_left
            (h_left_fails u hs₁u hus hu_cut)
          obtain ⟨_, v', hv'u, hv's, hbD_v'⟩ := h_right_u
          have hv'_cut : v' ∈ γ.val.cut := by
            by_contra hv'_not; exact hbD_v' (h_bD_compl v' hv's hv'_not)
          have ⟨u', hu'_cut, huu'⟩ : ∃ u', u' ∈ γ.val.cut ∧ u < u' := by
            by_contra h; push Not at h
            exact γ.val.no_sup ⟨u, ⟨h, fun _ hb => hb hu_cut⟩, hu_cut⟩
          have hu's : u' < s := h_cut_lt u' hu'_cut s hs_not_cut
          have h_right_u' := (h_body u' (lt_trans hs₁u huu') hu's).resolve_left
            (h_left_fails u' (lt_trans hs₁u huu') hu's hu'_cut)
          exact h_right_u'.1 u hs₁u huu'
        have hs₁_cut : s₁ ∈ γ.val.cut := by
          by_contra hs₁_not
          exact not_le.mpr (h_cut_lt u_fail huf_cut s₁ hs₁_not) (le_of_lt hs₁_uf)
        have ⟨t₀, ht₀_cut, hs₁t₀⟩ : ∃ t₀, t₀ ∈ γ.val.cut ∧ s₁ < t₀ := by
          by_contra h; push Not at h
          exact γ.val.no_sup ⟨s₁, ⟨h, fun _ hb => hb hs₁_cut⟩, hs₁_cut⟩
        exact h_no_final_D ⟨t₀, ht₀_cut, fun u ht₀u hu_cut =>
          hD_all_cut u (lt_of_lt_of_le hs₁t₀ ht₀u)
            (h_cut_lt u hu_cut s hs_not_cut) hu_cut⟩
  /-  -- wf_pt and wi_pt are complement points (above gap)
      have hwf_not_cut : wf_pt ∉ γ.val.cut := by
        intro h; exact not_lt.mpr ((extendPoint_le_gap_iff wf_pt γ).mpr h) hwf_γ
      have hwi_not_cut : wi_pt ∉ γ.val.cut := by
        intro h; exact not_lt.mpr ((extendPoint_le_gap_iff wi_pt γ).mpr h) hwi_γ
      -- m is a complement point (above gap)
      have hm_not_cut : m ∉ γ.val.cut := by
        intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γ).mpr h) hγ_lt
      -- Find complement point s below m, below wf_pt and wi_pt
      have ⟨s, hs_not_cut, hsm, hswf, hswi⟩ :
          ∃ s, s ∉ γ.val.cut ∧ s < m ∧ s < wf_pt ∧ s < wi_pt := by
        -- complement has no min, so there are complement points below any complement point
        have ⟨s₁, hs₁_not, hs₁_min⟩ : ∃ s₁, s₁ ∉ γ.val.cut ∧
            s₁ < min (min wf_pt wi_pt) m := by
          have hmin_not : min (min wf_pt wi_pt) m ∉ γ.val.cut := by
            simp only [min_def]; split_ifs with h
            · simp only [min_def] at *; split_ifs with h' <;> assumption
            · exact hm_not_cut
          by_contra h_all; push_neg at h_all
          exact γ.val.complement_no_min ⟨min (min wf_pt wi_pt) m, hmin_not,
            fun z hz => h_all z hz⟩
        exact ⟨s₁, hs₁_not,
          lt_of_lt_of_le hs₁_min (min_le_right _ _),
          lt_of_lt_of_le hs₁_min (le_trans (min_le_left _ _) (min_le_left _ _)),
          lt_of_lt_of_le hs₁_min (le_trans (min_le_left _ _) (min_le_right _ _))⟩
      -- s_sa ≤ extendPoint s (s_sa is below or at s, since s ∉ cut means s > gap,
      -- and s_sa < gap = Sum.inr γ, so s_sa could be below or a gap itself)
      -- Actually, s_sa is below the gap (or at gap), and s is above the gap.
      -- So s_sa < Sum.inr γ ≤ extendPoint s? No: Sum.inr γ < extendPoint s
      -- because s ∉ cut. So s_sa < extendPoint s.
      have hs_sa_s : s_sa < extendPoint s := by
        calc s_sa < Sum.inr γ := hs_sa_γ
        _ < extendPoint s := ⟨fun h => hs_not_cut h, fun h => hs_not_cut h⟩
      -- D(s) from D-between (s < m and s ∉ cut)
      have hDs : StaviTemporalTruth M atomMap s D :=
        (stavi_truth_mu_at_point s D).mp (hγ_bet s hsm hs_not_cut)
      -- B(s) from hBwi_sa (s is between s_sa and wi_pt)
      -- Hmm, hBwi_sa is the B-init condition: B at all mu-points in (s_sa, wi_pt).
      -- But wait, s < wi_pt and s_sa < s, so extendPoint s is between s_sa and extendPoint wi_pt.
      -- Actually hBwi_sa says: ∀ v, s_sa < v → v < extendPoint wi_pt → mu(v) → B(v)
      -- Wait, let me re-check. The goal structure showed:
      -- wi: ∃ u, s_1 < u ∧ u < s_1 ∧ ∀ v, s < v → v < u → B(v)
      -- Actually the FO table for U'(A,B)(s) has condition (3): ∃ wi_pt ∈ (s_sa, s₁),
      -- B on (wi_pt, s₁). So hBwi_sa : ∀ v, wi_pt < v → v < ? → B(v).
      -- Hmm, I need to re-read what hBwi_sa actually is. From the obtain:
      -- ⟨wi_sa, hs_wi, hwi_γ, hmu_wi, hBwi_sa⟩ := hUA_mu
      -- This is from condition (3) of U'(A,B) FO table:
      -- ∃ wi, s_sa < wi ∧ wi < s₁ ∧ mu(wi) ∧ B on (s_sa, wi)
      -- Wait no, I need to look at the exact FO table structure. Let me check.
      -- Actually from the simp/obtain: the last condition gives
      -- ⟨wi_sa, hs_wi, hwi_γ, hmu_wi, hBwi_sa⟩
      -- hBwi_sa is probably: ∀ v, s_sa < v → v < extendPoint wi_pt → B^mu(v)
      -- Wait, the Stavi Until FO table condition (3) is: ∃ u_init, B on (s_sa, u_init).
      -- So hBwi_sa : ∀ v, s_sa < v → v < extendPoint wi_pt → B(v)... or similar.
      --
      -- Let me look at how the left proof handles this. In the left proof for stavi_snce backward
      -- (lines 5823-5929 which I just uncommented), the B condition is handled via hBwi_sa.
      --
      -- Actually, I need to re-check the exact structure. The obtain pattern was:
      -- ⟨wi_sa, hs_wi, hwi_γ, hmu_wi, hBwi_sa⟩
      -- In the U' FO table, condition (3) = ∃ u_init ∈ (s_sa, s₁), B-init.
      -- So wi_sa = u_init position, hs_wi = s_sa < wi_sa, hwi_γ = wi_sa < s₁ = Sum.inr γ,
      -- hmu_wi = ⟨wi_pt, rfl⟩ (it's a mu-point), hBwi_sa = B on final segment.
      -- Actually, the FO table condition (3) for U' says:
      -- ∃ u_init, s < u_init ∧ u_init < bound ∧ ∀ v, s < v → v < u_init → D'(v)
      -- Wait no, the condition (3) is B-init: B holds on (s, u_init).
      -- Actually hBwi_sa is: ∀ v, s_sa < v → v < extendPoint wi_pt → B(v)... wait,
      -- this doesn't look right for "B on init segment from s_sa to wi_pt".
      -- Let me check what the actual obtain pattern destructures.
      --
      -- The FO table for U'(A,B) at point s is:
      -- ∃ s₁ > s, body ∧ fail ∧ init
      -- where:
      -- body = ∀ u ∈ (s, s₁), (cofinal B) ∨ (A below ∧ ¬B witness)
      -- fail = ∃ u ∈ (s, s₁), ¬B(u)
      -- init = ∃ u ∈ (s, s₁), B on (s, u) [= ∀ v ∈ (s, u), B(v)]
      --
      -- At gap γ, this becomes U'(A,B)^mu(γ):
      -- ∃ s_sa > γ, body_mu ∧ fail_mu ∧ init_mu
      -- s_sa was obtained as the bound.
      -- init_mu: ∃ wi_sa ∈ (γ, s_sa), mu(wi_sa) ∧ ∀ v, γ < v → v < wi_sa → mu(v) → B^mu(v)
      -- Hmm, wait. Actually, B on initial segment means ∀ v ∈ (γ, wi_sa), B(v).
      -- In mu form at gap, this is:
      -- ∃ wi_sa, s_sa_lower < wi_sa ∧ wi_sa < s_sa_upper ∧ mu(wi_sa) ∧
      --   ∀ v, s_sa_lower < v → v < wi_sa → B^mu(v) [wait, or just B(v)?]
      --
      -- Actually, looking at the goal output more carefully:
      -- The obtain pattern for U'(A,B)^mu(γ) was:
      -- ⟨s_sa, hs_sa_γ, h_body_sa, ⟨wf_sa, hs_wf, hwf_γ, hmu_wf, hBwf_sa⟩,
      --         ⟨wi_sa, hs_wi, hwi_γ, hmu_wi, hBwi_sa⟩⟩
      --
      -- This destructures the expanded FO table. Based on the goal, condition (3) gives:
      -- ∃ u, s₁ < u ∧ u < s₁ ∧ ∀ v, s < v → v < u → B(v)
      -- In our case at gap: ∃ wi_sa > Sum.inr γ, wi_sa < s_sa, mu(wi_sa),
      --   ∀ v, Sum.inr γ < v → v < extendPoint wi_pt → B^mu(v)
      --
      -- Wait, I'm getting confused because this is in the wrong direction.
      -- Let me just check: hBwi_sa type.
      -- From the obtain: hBwi_sa is the last element after hmu_wi.
      -- The FO table init condition for U'(A,B) gives:
      -- ∃ u_init ∈ (s_sa, s₁), ∀ v ∈ (s_sa, u_init), B(v)
      -- At the gap level, s₁ = Sum.inr γ (the gap, which is the lower bound since U' goes upward).
      -- Wait, U'(A,B) at gap γ means the FO table is evaluated at Sum.inr γ.
      -- But Sum.inr γ < extendPoint m means the gap is BELOW m. U' looks to the FUTURE (above).
      -- So the FO table for U'(A,B) at gap γ looks ABOVE γ:
      -- ∃ s_sa > Sum.inr γ, body ∧ fail ∧ init
      -- where body, fail, init are about the interval (Sum.inr γ, s_sa).
      --
      -- So hBwi_sa should be:
      -- ∀ v, Sum.inr γ < v → v < extendPoint wi_pt → mu(v) → B^mu(v)
      -- Wait, no. The FO table init condition is:
      -- ∃ u_init ∈ (Sum.inr γ, s_sa), B on (Sum.inr γ, u_init)
      -- And "B on (Sum.inr γ, u_init)" means ∀ v, Sum.inr γ < v → v < u_init → B(v)
      -- In mu form: ∀ v, Sum.inr γ < v → v < extendPoint wi_pt → B^mu(v)... no.
      -- The FO table at a gap has mu-quantification. The init condition becomes:
      -- ∃ wi, Sum.inr γ < wi ∧ wi < s_sa ∧ mu(wi) ∧
      --   ∀ v, Sum.inr γ < v → v < wi ∧ mu(v) → B^mu(v)
      -- Hmm, actually I'm not sure about the exact mu-quantification pattern.
      --
      -- Actually, from the original obtain, the structure matches StaviTemporalTruth
      -- after simp. So hBwi_sa is probably just:
      -- ∀ v, Sum.inr γ < v → v < extendPoint wi_pt → StaviTemporalTruth M atomMap (carrier_of v)
      B
      -- But this doesn't have mu-quantification...
      --
      -- I think the actual type depends on how StaviTemporalTruth is defined for U'.
      -- Let me just use lean_hover_info to check.

      -- Actually, let me take a simpler approach. I know from the left proof template
      -- that B(s) can be obtained. In the left proof, hgs is proved using hg_mu
      -- (g on (γ, t_pt)) with s between γ and t_pt. For the right version, I need
      -- B(s) from the U'(A,B) FO table. Since s is between γ and wi_pt (in the complement),
      -- and hBwi_sa gives B on the initial segment, B(s) should follow.
      --
      -- Let me just write the proof and check with lean_goal.
      -/
  | stavi_snce A B _ _ =>
    -- rightFormula (.stavi_snce A B) D = S'(B ∧ S'(A,B), D)
    -- Mirrors left's stavi_untl case with stavi_snce_gap_detection
    simp only [rightFormula]
    constructor
    · intro h
      obtain ⟨γ, s_bound, hγ_lt, hs_in, hγ_def, hγ_bet, hX_cut⟩ :=
        (stavi_snce_gap_detection (.conj B (.stavi_snce A B)) D hD m).mp h
      have hSA_cut : ∀ u : M.carrier, u ∈ γ.val.cut → s_bound < u →
          StaviTemporalTruth M atomMap u (.stavi_snce A B) :=
        fun u hu hus => (hX_cut u hu hus).2
      have hB_cut : ∀ u : M.carrier, u ∈ γ.val.cut → s_bound < u →
          StaviTemporalTruth M atomMap u B :=
        fun u hu hus => (hX_cut u hu hus).1
      -- S'(A,B)^mu at γ from S'(A,B) at cut points: mirrors left stavi_untl forward
      -- Pick cut point u₁ above s_bound
      have ⟨u₁, hu₁_in, hu₁s⟩ : ∃ u₁, u₁ ∈ γ.val.cut ∧ s_bound < u₁ := by
        by_contra h_all; push Not at h_all
        exact γ.val.no_sup ⟨s_bound, ⟨fun z hz => h_all z hz, fun _ hb => hb hs_in⟩, hs_in⟩
      -- FO table of S'(A,B) at u₁
      have hSA_u₁ := hSA_cut u₁ hu₁_in hu₁s
      simp only [StaviTemporalTruth] at hSA_u₁
      obtain ⟨s₁, hs₁u₁, h_body₁, ⟨wf, hs₁wf, hwfu₁, hBwf⟩,
              ⟨wi, hs₁wi, hwiu₁, hBwi⟩⟩ := hSA_u₁
      -- s₁ ∈ cut (s₁ < u₁ ∈ cut, downward closure)
      have hs₁_in : s₁ ∈ γ.val.cut :=
        γ.val.downward_closed u₁ s₁ hu₁_in (le_of_lt hs₁u₁)
      -- wf ∈ cut (wf < u₁)
      have hwf_in : wf ∈ γ.val.cut :=
        γ.val.downward_closed u₁ wf hu₁_in (le_of_lt hwfu₁)
      -- wi ∈ cut (wi < u₁)
      have hwi_in : wi ∈ γ.val.cut :=
        γ.val.downward_closed u₁ wi hu₁_in (le_of_lt hwiu₁)
      -- Construct S'(A,B)^mu(Sum.inr γ)
      refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
      simp only [StaviTemporalTruthMu]
      refine ⟨extendPoint s₁, ?_, ?_, ?_, ?_⟩
      · -- extendPoint s₁ < Sum.inr γ: s₁ ∈ cut
        exact ⟨hs₁_in, fun h => h hs₁_in⟩
      · -- Condition (1): ∀ mu-point u ∈ (extendPoint s₁, Sum.inr γ), FO body
        intro u hs₁u huγ hmu
        obtain ⟨u_pt, rfl⟩ := hmu
        have hu_pt_in : u_pt ∈ γ.val.cut :=
          (extendPoint_le_gap_iff u_pt γ).mp (le_of_lt huγ)
        have hu_pt_s₁ : s₁ < u_pt := (extendPoint_lt_iff s₁ u_pt).mp hs₁u
        by_cases hu_pt_u₁ : u_pt < u₁
        · -- u_pt between s₁ and u₁: use h_body₁
          cases h_body₁ u_pt hu_pt_s₁ hu_pt_u₁ with
          | inl h_cof =>
            left
            obtain ⟨v, hvu_pt, hBv⟩ := h_cof
            refine ⟨extendPoint v, (extendPoint_lt_iff v u_pt).mpr hvu_pt, ⟨v, rfl⟩,
              fun w hvw hwγ hmu_w => ?_⟩
            obtain ⟨w_pt, rfl⟩ := hmu_w
            have hw_pt_in : w_pt ∈ γ.val.cut :=
              (extendPoint_le_gap_iff w_pt γ).mp (le_of_lt hwγ)
            have hw_pt_v : v < w_pt := (extendPoint_lt_iff v w_pt).mp hvw
            by_cases hwu₁ : w_pt < u₁
            · exact (stavi_truth_mu_at_point w_pt B).mpr (hBv w_pt hw_pt_v hwu₁)
            · push Not at hwu₁
              have hw_sb : s_bound < w_pt := lt_of_lt_of_le hu₁s hwu₁
              exact (stavi_truth_mu_at_point w_pt B).mpr (hB_cut w_pt hw_pt_in hw_sb)
          | inr h_right =>
            right
            obtain ⟨hA_below, v', hv'u_pt, hv'u₁, hBv'⟩ := h_right
            refine ⟨fun v hv hvs hmu_v => ?_, ?_⟩
            · obtain ⟨v_pt, rfl⟩ := hmu_v
              exact (stavi_truth_mu_at_point v_pt A).mpr
                (hA_below v_pt ((extendPoint_lt_iff s₁ v_pt).mp hv)
                  ((extendPoint_lt_iff v_pt u_pt).mp hvs))
            · refine ⟨extendPoint v', (extendPoint_lt_iff u_pt v').mpr hv'u_pt, ?_,
                ⟨v', rfl⟩, mt (stavi_truth_mu_at_point v' B).mp hBv'⟩
              have hv'_in : v' ∈ γ.val.cut :=
                γ.val.downward_closed u₁ v' hu₁_in (le_of_lt hv'u₁)
              exact ⟨hv'_in, fun h => h hv'_in⟩
        · -- u_pt ≥ u₁: B holds at u_pt from hB_cut. Use LEFT disjunct.
          push Not at hu_pt_u₁
          left
          refine ⟨extendPoint wi, (extendPoint_lt_iff wi u_pt).mpr (lt_of_lt_of_le hwiu₁ hu_pt_u₁),
            ⟨wi, rfl⟩, fun w hwwi hwγ hmu_w => ?_⟩
          obtain ⟨w_pt, rfl⟩ := hmu_w
          have hw_pt_in : w_pt ∈ γ.val.cut :=
            (extendPoint_le_gap_iff w_pt γ).mp (le_of_lt hwγ)
          have hw_pt_wi : wi < w_pt := (extendPoint_lt_iff wi w_pt).mp hwwi
          by_cases hwu₁ : w_pt < u₁
          · exact (stavi_truth_mu_at_point w_pt B).mpr (hBwi w_pt hw_pt_wi hwu₁)
          · push Not at hwu₁
            exact (stavi_truth_mu_at_point w_pt B).mpr
              (hB_cut w_pt hw_pt_in (lt_of_lt_of_le hu₁s hwu₁))
      · -- Condition (2): ∃ mu-point in (s₁, γ) with ¬B^mu
        have hwf_lt_γ : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint wf) (Sum.inr γ) := ⟨hwf_in, fun h => h hwf_in⟩
        refine ⟨extendPoint wf, (extendPoint_lt_iff s₁ wf).mpr hs₁wf,
          hwf_lt_γ,
          ⟨wf, rfl⟩, mt (stavi_truth_mu_at_point wf B).mp hBwf⟩
      · -- Condition (3): ∃ mu-point in (s₁, γ) with B^mu on final segment to γ
        have hwi_lt_γ : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint wi) (Sum.inr γ) := ⟨hwi_in, fun h => h hwi_in⟩
        refine ⟨extendPoint wi, (extendPoint_lt_iff s₁ wi).mpr hs₁wi,
          hwi_lt_γ,
          ⟨wi, rfl⟩, fun v hwiv hvγ hmu_v => ?_⟩
        · obtain ⟨v_pt, rfl⟩ := hmu_v
          have hv_pt_in : v_pt ∈ γ.val.cut :=
            (extendPoint_le_gap_iff v_pt γ).mp (le_of_lt hvγ)
          have hv_pt_wi : wi < v_pt := (extendPoint_lt_iff wi v_pt).mp hwiv
          by_cases hvu₁ : v_pt < u₁
          · exact (stavi_truth_mu_at_point v_pt B).mpr (hBwi v_pt hv_pt_wi hvu₁)
          · push Not at hvu₁
            exact (stavi_truth_mu_at_point v_pt B).mpr
              (hB_cut v_pt hv_pt_in (lt_of_lt_of_le hu₁s hvu₁))
    · -- Backward: stavi_snce backward direction (restored from comment)
      intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hSA⟩
      simp only [StaviTemporalTruthMu] at hSA
      obtain ⟨s_sa, hs_sa_γ, h_body_sa, ⟨wf_sa, hs_wf, hwf_γ, hmu_wf, hBwf_sa⟩,
              ⟨wi_sa, hs_wi, hwi_γ, hmu_wi, hBwi_sa⟩⟩ := hSA
      obtain ⟨wf_pt, rfl⟩ := hmu_wf
      obtain ⟨wi_pt, rfl⟩ := hmu_wi
      have hwf_in : wf_pt ∈ γ.val.cut :=
        (extendPoint_le_gap_iff wf_pt γ).mp (le_of_lt hwf_γ)
      have hwi_in : wi_pt ∈ γ.val.cut :=
        (extendPoint_le_gap_iff wi_pt γ).mp (le_of_lt hwi_γ)
      -- Get a carrier bound s_pt below s_sa (and below both wf_pt, wi_pt)
      have ⟨s_pt, hs_pt_wf, hs_pt_wi, hs_sa_s_pt⟩ :
          ∃ s_pt : M.carrier, s_pt < wf_pt ∧ s_pt < wi_pt ∧ s_sa ≤ extendPoint s_pt := by
        rcases s_sa with s₁ | g_sa
        · refine ⟨s₁, (extendPoint_lt_iff s₁ wf_pt).mp hs_wf,
            (extendPoint_lt_iff s₁ wi_pt).mp hs_wi, le_rfl⟩
        · have hwf_not : wf_pt ∉ g_sa.val.cut := by
            intro h; exact not_lt.mpr ((extendPoint_le_gap_iff wf_pt g_sa).mpr h) hs_wf
          have hwi_not : wi_pt ∉ g_sa.val.cut := by
            intro h; exact not_lt.mpr ((extendPoint_le_gap_iff wi_pt g_sa).mpr h) hs_wi
          have hmin_not : min wf_pt wi_pt ∉ g_sa.val.cut := by
            rcases le_or_gt wf_pt wi_pt with h | h
            · simp only [min_eq_left h]; exact hwf_not
            · simp only [min_eq_right (le_of_lt h)]; exact hwi_not
          have ⟨y, hy_not, hy_min⟩ : ∃ y, y ∉ g_sa.val.cut ∧ y < min wf_pt wi_pt := by
            by_contra h_all; push Not at h_all
            exact g_sa.val.complement_no_min ⟨min wf_pt wi_pt, hmin_not,
              fun z hz => h_all z hz⟩
          exact ⟨y, lt_of_lt_of_le hy_min (min_le_left _ _),
            lt_of_lt_of_le hy_min (min_le_right _ _),
            le_of_lt (show @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (Sum.inr g_sa) (extendPoint y) from ⟨hy_not, hy_not⟩)⟩
      -- Pick s_bound = max(wf_pt, wi_pt). Both ∈ γ.cut.
      let s_bound := max wf_pt wi_pt
      have hs_bound_in : s_bound ∈ γ.val.cut := by
        simp only [s_bound, max_def]; split
        · exact hwi_in
        · exact hwf_in
      -- Apply stavi_snce_gap_detection.mpr
      apply (stavi_snce_gap_detection (.conj B (.stavi_snce A B)) D hD m).mpr
      refine ⟨γ, s_bound, hγ_lt, hs_bound_in, hγ_def, hγ_bet, fun u hu_in hu_sb => ?_⟩
      -- u is a cut point with s_bound < u, so wf_pt < u AND wi_pt < u
      have hu_wf : wf_pt < u := lt_of_le_of_lt (le_max_left wf_pt wi_pt) hu_sb
      have hu_wi : wi_pt < u := lt_of_le_of_lt (le_max_right wf_pt wi_pt) hu_sb
      have huγ : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
          (extendPoint u) (Sum.inr γ) := ⟨hu_in, fun h => h hu_in⟩
      simp only [StaviTemporalTruth]
      constructor
      · -- B(u): from hBwi_sa, u is between wi_pt and γ
        exact (stavi_truth_mu_at_point u B).mp
          (hBwi_sa (extendPoint u) ((extendPoint_lt_iff wi_pt u).mpr hu_wi) huγ ⟨u, rfl⟩)
      · -- S'(A,B)(u): FO table at u with bound s_pt
        refine ⟨s_pt, lt_trans hs_pt_wf hu_wf, ?_, ?_, ?_⟩
        · -- Body: ∀ w ∈ (s_pt, u), disjunction
          intro w hsw hwu
          have hw_in : w ∈ γ.val.cut :=
            γ.val.downward_closed u w hu_in (le_of_lt hwu)
          have hwγ : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (extendPoint w) (Sum.inr γ) := ⟨hw_in, fun h => h hw_in⟩
          have hs_sa_w : s_sa < extendPoint w :=
            lt_of_le_of_lt hs_sa_s_pt ((extendPoint_lt_iff s_pt w).mpr hsw)
          have h_disj := h_body_sa (extendPoint w) hs_sa_w hwγ ⟨w, rfl⟩
          cases h_disj with
          | inl h_cof =>
            left
            obtain ⟨v, hvw, hmu_v, hBv⟩ := h_cof
            obtain ⟨v_pt, rfl⟩ := hmu_v
            refine ⟨v_pt, (extendPoint_lt_iff v_pt w).mp hvw, fun z hzv hzu => ?_⟩
            have hz_in : z ∈ γ.val.cut :=
              γ.val.downward_closed u z hu_in (le_of_lt hzu)
            have hzγ : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
                (extendPoint z) (Sum.inr γ) := ⟨hz_in, fun h => h hz_in⟩
            exact (stavi_truth_mu_at_point z B).mp
              (hBv (extendPoint z) ((extendPoint_lt_iff v_pt z).mpr hzv) hzγ ⟨z, rfl⟩)
          | inr h_take =>
            obtain ⟨hA_below, v', hv'_above_w, hv'_below_γ, hmu_v', hBv'_neg⟩ := h_take
            obtain ⟨v'_pt, rfl⟩ := hmu_v'
            have hv'_w : w < v'_pt := (extendPoint_lt_iff w v'_pt).mp hv'_above_w
            have hv'_in : v'_pt ∈ γ.val.cut :=
              (extendPoint_le_gap_iff v'_pt γ).mp (le_of_lt hv'_below_γ)
            by_cases hv'u : v'_pt < u
            · -- v'_pt between w and u: use RIGHT disjunct with v'_pt as ¬B witness
              right
              constructor
              · intro v hsv hvu
                exact (stavi_truth_mu_at_point v A).mp
                  (hA_below (extendPoint v) (lt_of_le_of_lt hs_sa_s_pt
                      ((extendPoint_lt_iff s_pt v).mpr hsv))
                    ((extendPoint_lt_iff v w).mpr hvu) ⟨v, rfl⟩)
              · exact ⟨v'_pt, hv'_w, hv'u,
                  mt (stavi_truth_mu_at_point v'_pt B).mpr hBv'_neg⟩
            · -- v'_pt ≥ u > wi_pt: B(v'_pt) from hBwi_sa contradicts ¬B(v'_pt)
              push Not at hv'u
              exfalso
              exact hBv'_neg
                (hBwi_sa (extendPoint v'_pt)
                  ((extendPoint_lt_iff wi_pt v'_pt).mpr (lt_of_lt_of_le hu_wi hv'u))
                  ⟨hv'_in, fun h => h hv'_in⟩ ⟨v'_pt, rfl⟩)
        · -- Condition (2): ¬B witness
          exact ⟨wf_pt, hs_pt_wf, hu_wf, mt (stavi_truth_mu_at_point wf_pt B).mpr hBwf_sa⟩
        · -- Condition (3): B on final segment
          exact ⟨wi_pt, hs_pt_wi, hu_wi, fun v hwiv hvu =>
            (stavi_truth_mu_at_point v B).mp
              (hBwi_sa (extendPoint v) ((extendPoint_lt_iff wi_pt v).mpr hwiv)
                (⟨γ.val.downward_closed u v hu_in (le_of_lt hvu),
                  fun h => h (γ.val.downward_closed u v hu_in (le_of_lt hvu))⟩)
                ⟨v, rfl⟩)⟩
  | std_untl A B _ _ =>
    -- rightFormula (.std_untl A B) D = .std_snce compound D
    -- compound = D ∧ B ∧ U(A,B) ∧ S'(⊤, B∧D) ∧ ¬S'(D, B∧D)
    -- Same compound decomposition as stavi_untl with U(A,B) instead of U'(A,B)
    simp only [rightFormula]
    rw [stavi_truth_mu_at_point m (.std_snce _ D)]
    simp only [StaviTemporalTruth]
    constructor
    · -- Forward: std_snce(compound, D)(m) → gap conditions
      intro ⟨s, hsm, ⟨hDs, hBs, hUntl_s, hS'_BD_s, hNotS'D_BD_s⟩, hD_bet⟩
      obtain ⟨s₁, hs₁s, h_body, h_fail, h_init⟩ := hS'_BD_s
      obtain ⟨u_fail, hs₁_uf, huf_s, hBD_fail⟩ := h_fail
      obtain ⟨u_init, hs₁_ui, hui_s, hBD_init⟩ := h_init
      -- Gap construction (identical to stavi_untl compound decomposition)
      let bD : M.carrier → Prop := fun u =>
        StaviTemporalTruth M atomMap u B ∧ StaviTemporalTruth M atomMap u D
      let compl : Set M.carrier :=
        {x | ∀ u, u < s → x ≤ u → ∃ v, v < u ∧ ∀ w, v < w → w < s → bD w}
      have hs_in_compl : s ∈ compl :=
        fun u hus hsu => absurd (lt_of_le_of_lt hsu hus) (lt_irrefl s)
      have hu_fail_not_compl : u_fail ∉ compl := by
        intro h; obtain ⟨v, hvuf, hBDv⟩ := h u_fail huf_s le_rfl
        exact hBD_fail (hBDv u_fail hvuf huf_s)
      have h_compl_gt_uf : ∀ x ∈ compl, u_fail < x := by
        intro x hx; by_contra h; push Not at h
        exact hu_fail_not_compl (fun u hus huf => hx u hus (le_trans h huf))
      have h_compl_uc : ∀ x y, x ∈ compl → x ≤ y → y ∈ compl :=
        fun x y hx hxy u hus hyu => hx u hus (le_trans (le_trans hxy hyu) le_rfl)
      let cut : Set M.carrier := {x | x ∉ compl}
      have h_cut_dc : ∀ x y, x ∈ cut → y ≤ x → y ∈ cut := by
        intro x y hx hyx hy; exact hx (h_compl_uc y x hy hyx)
      have h_proper : cut ≠ Set.univ := by
        intro h; have := h ▸ Set.mem_univ s; exact this hs_in_compl
      have h_cofinal_propagate :
          ∀ u, s₁ < u → u < s →
          (∀ w, u < w → w < s → ∃ v, v < w ∧ ∀ z, v < z → z < s → bD z) →
          ∃ v, v < u ∧ ∀ z, v < z → z < s → bD z := by
        intro u hs₁u hus h_above
        cases h_body u hs₁u hus with
        | inl h => exact h
        | inr h =>
          obtain ⟨_, v', huv', hv's, hBDv'⟩ := h
          obtain ⟨v₂, hv₂v', hBDv₂⟩ := h_above v' huv' hv's
          exact absurd (hBDv₂ v' hv₂v' hv's) hBDv'
      have hu_init_compl : u_init ∈ compl := by
        intro u hus huu_init
        rcases eq_or_lt_of_le huu_init with rfl | hlt
        · cases h_body u_init hs₁_ui hui_s with
          | inl h => exact h
          | inr h =>
            obtain ⟨_, v', hv'ui, hv's, hBDv'⟩ := h
            exact absurd (hBD_init v' hv'ui hv's) hBDv'
        · exact ⟨u_init, hlt, fun z huz hzs => hBD_init z huz hzs⟩
      have h_bD_at_compl : ∀ u, u ∈ compl → u < s → bD u := by
        intro u hu hus; obtain ⟨v, hvu, hBDv⟩ := hu u hus le_rfl
        exact hBDv u hvu hus
      have h_cut_lt_compl : ∀ x ∈ cut, ∀ y ∈ compl, x < y := by
        intro x hx y hy; by_contra h; push Not at h
        exact hx (h_compl_uc y x hy h)
      have h_no_sup : ¬∃ p, IsLUB cut p ∧ p ∈ cut := by
        intro ⟨p, ⟨h_ub, _⟩, hp_cut⟩
        have hps : p < s := h_cut_lt_compl p hp_cut s hs_in_compl
        have hs₁p : s₁ < p := by
          by_contra h; push Not at h
          exact not_le.mpr (lt_of_le_of_lt h hs₁_uf) (h_ub hu_fail_not_compl)
        apply hp_cut
        intro u hus hpu
        rcases eq_or_lt_of_le hpu with rfl | hpu'
        · exact h_cofinal_propagate p hs₁p hus (fun w hpw hws => by
            have : w ∈ compl := by by_contra hw; exact not_le.mpr hpw (h_ub hw)
            exact this w hws le_rfl)
        · have : u ∈ compl := by by_contra hu_cut; exact not_le.mpr hpu' (h_ub hu_cut)
          exact this u hus le_rfl
      have h_not_cut_of_compl : ∀ x, x ∈ compl → x ∉ cut :=
        fun x hx hx_cut => hx_cut hx
      have h_comp_no_min : ¬∃ b, b ∉ cut ∧ ∀ y, y ∉ cut → b ≤ y := by
        intro ⟨b, hb_not_cut, hb_min⟩
        have hb_compl : b ∈ compl := by by_contra h; exact hb_not_cut (show b ∈ cut from h)
        have hbs : b < s := lt_of_le_of_lt (hb_min u_init (h_not_cut_of_compl _ hu_init_compl))
            hui_s
        have hs₁b : s₁ < b := lt_trans hs₁_uf (h_compl_gt_uf b hb_compl)
        have h_below_b : ∀ y, y < b → y ∈ cut := by
          intro y hyb; by_contra hy_not; exact not_lt.mpr (hb_min y hy_not) hyb
        cases h_body b hs₁b hbs with
        | inl h_cof =>
          obtain ⟨v, hvb, hBDv⟩ := h_cof
          by_cases hvs₁ : v ≤ s₁
          · exact hBD_fail (hBDv u_fail (lt_of_le_of_lt hvs₁ hs₁_uf) huf_s)
          · push Not at hvs₁
            have hv_compl : v ∈ compl := by
              intro u hus hvu
              rcases eq_or_lt_of_le hvu with rfl | hvu'
              · exact h_cofinal_propagate v hvs₁ (lt_trans hvb hbs)
                  (fun w hvw hws => ⟨v, hvw, hBDv⟩)
              · exact ⟨v, hvu', hBDv⟩
            exact absurd hvb (not_lt.mpr (hb_min v
                (show v ∉ cut from fun hv_cut => hv_cut hv_compl)))
        | inr h =>
          obtain ⟨_, v', hbv', hv's, hBDv'⟩ := h
          exact hBDv' (h_bD_at_compl v' (h_compl_uc b v' hb_compl (le_of_lt hbv')) hv's)
      let γ_gap : Gap M.carrier :=
        ⟨cut, ⟨u_fail, show u_fail ∈ cut from hu_fail_not_compl⟩, h_proper, h_cut_dc, h_no_sup,
            h_comp_no_min⟩
      have h_D_compl_cofinal : ∃ t, t ∉ γ_gap.cut ∧ ∀ u, u ∉ γ_gap.cut → u ≤ t →
          StaviTemporalTruth M atomMap u D :=
        ⟨u_init, fun h => h hu_init_compl, fun u hu hut =>
          (h_bD_at_compl u (by by_contra h'; exact hu h') (lt_of_le_of_lt hut hui_s)).2⟩
      have hD_fails : ∃ u_D, s₁ < u_D ∧ u_D < s ∧
          ¬StaviTemporalTruth M atomMap u_D D := by
        by_contra h_all_D; push Not at h_all_D
        apply hNotS'D_BD_s
        exact ⟨s₁, hs₁s,
          fun u hs₁u hus => by
            cases h_body u hs₁u hus with
            | inl h => left; exact h
            | inr h => right; exact ⟨fun v hsv hvu => h_all_D v hsv (lt_trans hvu hus), h.2⟩,
          ⟨u_fail, hs₁_uf, huf_s, hBD_fail⟩,
          ⟨u_init, hs₁_ui, hui_s, hBD_init⟩⟩
      obtain ⟨u_D, hs₁_uD, huD_s, hD_fail_D⟩ := hD_fails
      have hu_D_not_compl : u_D ∉ compl := by
        intro h; exact hD_fail_D (h_bD_at_compl u_D h huD_s).2
      have h_no_init_cut_D : ¬∃ t, t ∈ γ_gap.cut ∧ ∀ u, t ≤ u → u ∈ γ_gap.cut →
          StaviTemporalTruth M atomMap u D := by
        intro ⟨t, ht_cut, hDt⟩
        by_cases htu : t ≤ u_D
        · exact hD_fail_D (hDt u_D htu (show u_D ∉ compl from hu_D_not_compl))
        · push Not at htu
          apply hNotS'D_BD_s
          have hts : t < s := h_cut_lt_compl t ht_cut s hs_in_compl
          refine ⟨t, hts, ?_, ?_, ?_⟩
          · intro u htu' hus
            have hs₁u : s₁ < u := lt_trans (lt_trans hs₁_uD htu) htu'
            cases h_body u hs₁u hus with
            | inl h => left; exact h
            | inr h =>
              right
              exact ⟨fun v htv hvu => by
                by_cases hv_compl : v ∈ compl
                · exact (h_bD_at_compl v hv_compl (lt_trans hvu hus)).2
                · exact hDt v (le_of_lt htv) (show v ∈ γ_gap.cut from hv_compl), h.2⟩
          · have ⟨u₂, hu₂_cut, htu₂⟩ : ∃ u₂, u₂ ∈ cut ∧ t < u₂ := by
              by_contra h; push Not at h
              exact h_no_sup ⟨t, ⟨h, fun ub hub => hub ht_cut⟩, ht_cut⟩
            have hu₂s : u₂ < s := h_cut_lt_compl u₂ hu₂_cut s hs_in_compl
            have hs₁u₂ : s₁ < u₂ := lt_trans (lt_trans hs₁_uD htu) htu₂
            rcases h_body u₂ hs₁u₂ hu₂s with ⟨v, hvu₂, hBDv⟩ | ⟨_, v', hv'u₂, hv's, hngD⟩
            · exfalso
              exact hu₂_cut (show u₂ ∈ compl from
                fun u' hu's hu₂u' => ⟨v, lt_of_lt_of_le hvu₂ hu₂u', hBDv⟩)
            · exact ⟨v', lt_trans htu₂ hv'u₂, hv's, hngD⟩
          · exact ⟨u_init, h_cut_lt_compl t ht_cut u_init hu_init_compl, hui_s, hBD_init⟩
      have h_def_right : GapDefinableOnRight M atomMap γ_gap D :=
        ⟨h_D_compl_cofinal, h_no_init_cut_D⟩
      have h_r_def : IsRDefinableGap M atomMap γ_gap r :=
        ⟨D, hD, Or.inr h_def_right⟩
      let γ : RDefinableGap M atomMap r := ⟨γ_gap, h_r_def⟩
      refine ⟨γ, ?_, h_def_right, ?_, ?_⟩
      · have hm_compl : m ∈ compl := h_compl_uc s m hs_in_compl (le_of_lt hsm)
        change @GT.gt (ExtendedCarrier M atomMap r) _ (extendPoint m) (Sum.inr γ)
        exact ⟨fun h => h hm_compl, fun h => h hm_compl⟩
      · intro u hum hu_not_cut
        have hu_compl : u ∈ compl := by by_contra h'; exact hu_not_cut h'
        by_cases hus : u < s
        · exact (stavi_truth_mu_at_point u D).mpr (h_bD_at_compl u hu_compl hus).2
        · push Not at hus
          rcases eq_or_lt_of_le hus with rfl | hsu
          · exact (stavi_truth_mu_at_point s D).mpr hDs
          · exact (stavi_truth_mu_at_point u D).mpr (hD_bet u hsu hum)
      · -- U(A,B)^mu at γ: simpler than U'(A,B) — just extend interval
        obtain ⟨s₂, hss₂, hA_s₂, hB_on⟩ := hUntl_s
        simp only [StaviTemporalTruthMu]
        have hs₂_compl : s₂ ∈ compl := h_compl_uc s s₂ hs_in_compl (le_of_lt hss₂)
        refine ⟨extendPoint s₂,
          (⟨fun h => h hs₂_compl, fun h => h hs₂_compl⟩ :
            @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT (Sum.inr γ)
                (extendPoint s₂)),
          ⟨s₂, rfl⟩, (stavi_truth_mu_at_point s₂ A).mpr hA_s₂,
          fun u hγu hus₂ hmu => ?_⟩
        obtain ⟨u_pt, rfl⟩ := hmu
        have hu_pt_not_cut : u_pt ∉ γ_gap.cut := by
          intro h; exact not_lt.mpr (show extendPoint u_pt ≤ Sum.inr γ from h) hγu
        have hu_pt_s₂ : u_pt < s₂ := (extendPoint_lt_iff u_pt s₂).mp hus₂
        by_cases hus : u_pt < s
        · have hu_compl : u_pt ∈ compl := by by_contra h'; exact hu_pt_not_cut h'
          exact (stavi_truth_mu_at_point u_pt B).mpr (h_bD_at_compl u_pt hu_compl hus).1
        · push Not at hus
          rcases eq_or_lt_of_le hus with rfl | hsu
          · exact (stavi_truth_mu_at_point s B).mpr hBs
          · exact (stavi_truth_mu_at_point u_pt B).mpr (hB_on u_pt hsu hu_pt_s₂)
    · -- Backward: gap below m with U(A,B)^mu → std_snce(compound, D)(m)
      intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hUA⟩
      simp only [StaviTemporalTruthMu] at hUA
      obtain ⟨s_sa, hs_sa_γ, ⟨t_pt, rfl⟩, hA_t, hB_mu⟩ := hUA
      -- t_pt is a complement point above gap with A(t_pt)
      have ht_not_cut : t_pt ∉ γ.val.cut := by
        intro h; exact not_lt.mpr ((extendPoint_le_gap_iff t_pt γ).mpr h) hs_sa_γ
      -- Find complement point s between γ and min(m, t_pt)
      have hm_not_cut : m ∉ γ.val.cut := by
        intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γ).mpr h) hγ_lt
      have ⟨s, hs_not_cut, hsm, hst⟩ :
          ∃ s, s ∉ γ.val.cut ∧ s < m ∧ s < t_pt := by
        have ⟨s₁, hs₁_not, hs₁_m⟩ : ∃ s₁, s₁ ∉ γ.val.cut ∧
            s₁ < min m t_pt := by
          have hmin_not : min m t_pt ∉ γ.val.cut := by
            simp only [min_def]; split_ifs with h
            · exact hm_not_cut
            · exact ht_not_cut
          by_contra h_all; push Not at h_all
          exact γ.val.complement_no_min ⟨min m t_pt, hmin_not, fun z hz => h_all z hz⟩
        exact ⟨s₁, hs₁_not,
          lt_of_lt_of_le hs₁_m (min_le_left _ _),
          lt_of_lt_of_le hs₁_m (min_le_right _ _)⟩
      have hγs : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
          (Sum.inr γ) (extendPoint s) := ⟨fun h => hs_not_cut h, fun h => hs_not_cut h⟩
      -- D(s) from D-between
      have hDs : StaviTemporalTruth M atomMap s D :=
        (stavi_truth_mu_at_point s D).mp (hγ_bet s hsm hs_not_cut)
      -- B(s) from B^mu on (γ, t_pt): s is between γ and t_pt
      have hBs : StaviTemporalTruth M atomMap s B :=
        (stavi_truth_mu_at_point s B).mp
          (hB_mu (extendPoint s) hγs ((extendPoint_lt_iff s t_pt).mpr hst) ⟨s, rfl⟩)
      -- U(A,B)(s): witness t_pt > s with A(t_pt) and B on (s, t_pt)
      have hUA_s : StaviTemporalTruth M atomMap s (.std_untl A B) := by
        simp only [StaviTemporalTruth]
        refine ⟨t_pt, hst, (stavi_truth_mu_at_point t_pt A).mp hA_t,
          fun u hsu hut => ?_⟩
        have hu_not_cut : u ∉ γ.val.cut := by
          intro h; exact not_le.mpr (lt_trans hγs ((extendPoint_lt_iff s u).mpr hsu))
            ((extendPoint_le_gap_iff u γ).mpr h)
        exact (stavi_truth_mu_at_point u B).mp
          (hB_mu (extendPoint u)
            ⟨fun h => hu_not_cut h, fun h => hu_not_cut h⟩
            ((extendPoint_lt_iff u t_pt).mpr hut) ⟨u, rfl⟩)
      -- D on (s, m)
      have hD_bet_sm : ∀ u, s < u → u < m → StaviTemporalTruth M atomMap u D := by
        intro u hsu hum
        have hu_not_cut : u ∉ γ.val.cut := by
          intro h; exact not_le.mpr (lt_trans hγs ((extendPoint_lt_iff s u).mpr hsu))
            ((extendPoint_le_gap_iff u γ).mpr h)
        exact (stavi_truth_mu_at_point u D).mp (hγ_bet u hum hu_not_cut)
      -- Gap definability
      obtain ⟨⟨t_D, ht_D_not, hD_init⟩, h_no_final_D⟩ := hγ_def
      have h_cut_lt : ∀ x, x ∈ γ.val.cut → ∀ y, y ∉ γ.val.cut → x < y := by
        intro x hx y hy; by_contra h; push Not at h
        exact hy (γ.val.downward_closed x y hx h)
      have h_neg_final : ∀ t, t ∈ γ.val.cut →
          ∃ w, w ∈ γ.val.cut ∧ t ≤ w ∧ ¬StaviTemporalTruth M atomMap w D := by
        intro t ht; by_contra h_all; push Not at h_all
        exact h_no_final_D ⟨t, ht, fun w htw hw_cut => h_all w hw_cut htw⟩
      have ⟨c₀, hc₀_cut⟩ : ∃ c₀, c₀ ∈ γ.val.cut := γ.val.nonempty
      have hc₀s : c₀ < s := h_cut_lt c₀ hc₀_cut s hs_not_cut
      have h_bD_compl : ∀ u, u < s → u ∉ γ.val.cut →
          StaviTemporalTruth M atomMap u B ∧ StaviTemporalTruth M atomMap u D := by
        intro u hus hu_not_cut
        constructor
        · exact (stavi_truth_mu_at_point u B).mp
            (hB_mu (extendPoint u) ⟨fun h => hu_not_cut h, fun h => hu_not_cut h⟩
              (lt_trans ((extendPoint_lt_iff u s).mpr hus) ((extendPoint_lt_iff s t_pt).mpr hst))
              ⟨u, rfl⟩)
        · exact (stavi_truth_mu_at_point u D).mp (hγ_bet u (lt_trans hus hsm) hu_not_cut)
      refine ⟨s, hsm, ⟨hDs, hBs, hUA_s, ?_, ?_⟩, hD_bet_sm⟩
      · -- S'(⊤, B∧D)(s): bound c₀ (a cut point below s)
        refine ⟨c₀, hc₀s, ?_, ?_, ?_⟩
        · intro u hc₀u hus
          by_cases hu_not_cut : u ∉ γ.val.cut
          · left
            have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
              by_contra h_all; push Not at h_all
              exact γ.val.complement_no_min ⟨u, hu_not_cut, fun z hz => h_all z hz⟩
            exact ⟨y, hyu, fun w hyw hws =>
              h_bD_compl w hws (fun h_cut =>
                hy_not (γ.val.downward_closed w y h_cut (le_of_lt hyw)))⟩
          · push Not at hu_not_cut
            right
            refine ⟨fun v _ _ => by simp [TemporalTruth, Formula.top], ?_⟩
            have ⟨y, hy_cut, huy⟩ : ∃ y, y ∈ γ.val.cut ∧ u < y := by
              by_contra h_all; push Not at h_all
              exact γ.val.no_sup ⟨u, ⟨h_all, fun _ hb => hb hu_not_cut⟩, hu_not_cut⟩
            obtain ⟨w, hw_cut, hyw, hDw⟩ := h_neg_final y hy_cut
            exact ⟨w, lt_of_lt_of_le huy hyw, h_cut_lt w hw_cut s hs_not_cut,
              fun ⟨_, hD'⟩ => hDw hD'⟩
        · have ⟨y, hy_cut, hc₀y⟩ : ∃ y, y ∈ γ.val.cut ∧ c₀ < y := by
            by_contra h_all; push Not at h_all
            exact γ.val.no_sup ⟨c₀, ⟨h_all, fun _ hb => hb hc₀_cut⟩, hc₀_cut⟩
          obtain ⟨w, hw_cut, hyw, hDw⟩ := h_neg_final y hy_cut
          exact ⟨w, lt_of_lt_of_le hc₀y hyw, h_cut_lt w hw_cut s hs_not_cut,
            fun ⟨_, hD'⟩ => hDw hD'⟩
        · have ⟨y, hy_not, hys⟩ : ∃ y, y ∉ γ.val.cut ∧ y < s := by
            by_contra h_all; push Not at h_all
            exact γ.val.complement_no_min ⟨s, hs_not_cut, fun z hz => h_all z hz⟩
          exact ⟨y, h_cut_lt c₀ hc₀_cut y hy_not, hys, fun v hyv hvs =>
            h_bD_compl v hvs (fun hv_cut =>
              hy_not (γ.val.downward_closed v y hv_cut (le_of_lt hyv)))⟩
      · -- ¬S'(D, B∧D)(s): two-step D-transfer contradiction
        intro ⟨s₁', hs₁s', h_body', h_fail', h_init'⟩
        obtain ⟨u_fail', hs₁_uf', huf_s', hbD_fail'⟩ := h_fail'
        have huf_cut : u_fail' ∈ γ.val.cut := by
          by_contra huf_not
          exact hbD_fail' (h_bD_compl u_fail' huf_s' huf_not)
        have h_left_fails : ∀ u, s₁' < u → u < s → u ∈ γ.val.cut →
            ¬(∃ v, v < u ∧ ∀ w, v < w → w < s →
              StaviTemporalTruth M atomMap w B ∧ StaviTemporalTruth M atomMap w D) := by
          intro u _ _ hu_cut ⟨v, hvu, hbDv⟩
          have hv_cut : v ∈ γ.val.cut := γ.val.downward_closed u v hu_cut (le_of_lt hvu)
          have ⟨y, hy_cut, hvy⟩ : ∃ y, y ∈ γ.val.cut ∧ v < y := by
            by_contra h; push Not at h
            exact γ.val.no_sup ⟨v, ⟨h, fun _ hb => hb hv_cut⟩, hv_cut⟩
          obtain ⟨w', hw'_cut, hyw', hDw'⟩ := h_neg_final y hy_cut
          exact hDw' (hbDv w' (lt_of_lt_of_le hvy hyw')
            (h_cut_lt w' hw'_cut s hs_not_cut)).2
        have hD_all_cut : ∀ u, s₁' < u → u < s → u ∈ γ.val.cut →
            StaviTemporalTruth M atomMap u D := by
          intro u hs₁u hus hu_cut
          have h_right_u := (h_body' u hs₁u hus).resolve_left
            (h_left_fails u hs₁u hus hu_cut)
          obtain ⟨_, v', hv'u, hv's, hbD_v'⟩ := h_right_u
          have hv'_cut : v' ∈ γ.val.cut := by
            by_contra hv'_not; exact hbD_v' (h_bD_compl v' hv's hv'_not)
          have ⟨u', hu'_cut, huu'⟩ : ∃ u', u' ∈ γ.val.cut ∧ u < u' := by
            by_contra h; push Not at h
            exact γ.val.no_sup ⟨u, ⟨h, fun _ hb => hb hu_cut⟩, hu_cut⟩
          have hu's : u' < s := h_cut_lt u' hu'_cut s hs_not_cut
          have h_right_u' := (h_body' u' (lt_trans hs₁u huu') hu's).resolve_left
            (h_left_fails u' (lt_trans hs₁u huu') hu's hu'_cut)
          exact h_right_u'.1 u hs₁u huu'
        have hs₁_cut : s₁' ∈ γ.val.cut := by
          by_contra hs₁_not
          exact not_le.mpr (h_cut_lt u_fail' huf_cut s₁' hs₁_not) (le_of_lt hs₁_uf')
        have ⟨t₀, ht₀_cut, hs₁t₀⟩ : ∃ t₀, t₀ ∈ γ.val.cut ∧ s₁' < t₀ := by
          by_contra h; push Not at h
          exact γ.val.no_sup ⟨s₁', ⟨h, fun _ hb => hb hs₁_cut⟩, hs₁_cut⟩
        exact h_no_final_D ⟨t₀, ht₀_cut, fun u ht₀u hu_cut =>
          hD_all_cut u (lt_of_lt_of_le hs₁t₀ ht₀u)
            (h_cut_lt u hu_cut s hs_not_cut) hu_cut⟩
  | std_snce A B _ _ =>
    -- rightFormula (.std_snce A B) D = S'(B ∧ S(A,B), D)
    -- Same pattern as base.snce with S(A,B) instead of S(f,g)
    simp only [rightFormula]
    rw [stavi_snce_gap_detection (.conj B (.std_snce A B)) D hD m]
    constructor
    · -- Forward: cut-point truth of B ∧ S(A,B) → S(A,B)^mu at γ
      intro ⟨γ, s_bound, hγ_lt, hs_in, hγ_def, hγ_bet, hX_cut⟩
      refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
      simp only [StaviTemporalTruthMu]
      have ⟨u₀, hu₀_in, hu₀s⟩ : ∃ u₀, u₀ ∈ γ.val.cut ∧ s_bound < u₀ := by
        by_contra h_all; push Not at h_all
        exact γ.val.no_sup ⟨s_bound, ⟨fun z hz => h_all z hz, fun _ hb => hb hs_in⟩, hs_in⟩
      have hX_u₀ := hX_cut u₀ hu₀_in hu₀s
      simp only [StaviTemporalTruth] at hX_u₀
      obtain ⟨hB_u₀, t₁, ht₁u₀, hA_t₁, hB_between⟩ := hX_u₀
      have ht₁_in : t₁ ∈ γ.val.cut :=
        γ.val.downward_closed u₀ t₁ hu₀_in (le_of_lt ht₁u₀)
      refine ⟨extendPoint t₁, ⟨ht₁_in, fun h => h ht₁_in⟩, ⟨t₁, rfl⟩,
        (stavi_truth_mu_at_point t₁ A).mpr hA_t₁, fun v hvt₁ hvγ hmu => ?_⟩
      obtain ⟨v₀, rfl⟩ := hmu
      have hv₀_in : v₀ ∈ γ.val.cut :=
        (extendPoint_le_gap_iff v₀ γ).mp (le_of_lt hvγ)
      have hv₀_t₁ : t₁ < v₀ := (extendPoint_lt_iff t₁ v₀).mp hvt₁
      apply (stavi_truth_mu_at_point v₀ B).mpr
      by_cases hv_u₀ : v₀ < u₀
      · exact hB_between v₀ hv₀_t₁ hv_u₀
      · push Not at hv_u₀
        have hv₀_sb : s_bound < v₀ := lt_of_lt_of_le hu₀s hv_u₀
        exact (hX_cut v₀ hv₀_in hv₀_sb).1
    · -- Backward: S(A,B)^mu at γ → cut-point truth of B ∧ S(A,B)
      intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hSA⟩
      simp only [StaviTemporalTruthMu] at hSA
      obtain ⟨s, hsγ, hmu_s, hA_s, hB_mu⟩ := hSA
      obtain ⟨t₁, rfl⟩ := hmu_s
      have ht₁_in : t₁ ∈ γ.val.cut :=
        (extendPoint_le_gap_iff t₁ γ).mp (le_of_lt hsγ)
      refine ⟨γ, t₁, hγ_lt, ht₁_in, hγ_def, hγ_bet, fun u hu_in hu_t₁ => ?_⟩
      simp only [StaviTemporalTruth]
      constructor
      · have hγu : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint u) (Sum.inr γ) := ⟨hu_in, fun h => h hu_in⟩
        have hut₁ : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint t₁) (extendPoint u) :=
          (extendPoint_lt_iff t₁ u).mpr hu_t₁
        exact (stavi_truth_mu_at_point u B).mp
          (hB_mu (extendPoint u) hut₁ hγu ⟨u, rfl⟩)
      · refine ⟨t₁, hu_t₁, (stavi_truth_mu_at_point t₁ A).mp hA_s, fun v htv hvu => ?_⟩
        have hv_in : v ∈ γ.val.cut :=
          γ.val.downward_closed u v hu_in (le_of_lt hvu)
        have hγv : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint v) (Sum.inr γ) := ⟨hv_in, fun h => h hv_in⟩
        have hvt₁ : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint t₁) (extendPoint v) :=
          (extendPoint_lt_iff t₁ v).mpr htv
        exact (stavi_truth_mu_at_point v B).mp
          (hB_mu (extendPoint v) hvt₁ hγv ⟨v, rfl⟩)

end FormalSystem.Metalogic.Expressiveness
