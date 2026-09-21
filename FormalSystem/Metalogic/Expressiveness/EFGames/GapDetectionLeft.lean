/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Expressiveness.EFGames.GapDetection
import FormalSystem.Metalogic.Expressiveness.EFGames.MuRelativizedTruth

/-!
# Gap Detection Correctness: Left Direction

GHR93 Lemma 9 for `leftFormula`: gap uniqueness (`gap_detection_unique`), the core
`U'(X, D)` helper (`stavi_untl_gap_detection`), and the correctness theorem
`left_formula_gap_detection`. The formulas themselves are defined in
`EFGames/GapDetection.lean`; the right direction is `EFGames/GapDetectionRight.lean`.
-/

set_option linter.style.longFile 2300

namespace FormalSystem.Metalogic.Expressiveness

open FormalSystem.Syntax

/-! ### Gap Uniqueness for Lemma 9

Infrastructure for the gap detection correctness theorem. The key fact:
given D, m, there is at most one gap γ > m with GapDefinableOnLeft D
and D holding at all actual points between m and γ. This uses the
D-between condition to rule out multiple gaps.
-/

/-- Two gaps satisfying the Lemma 9 conditions for the same D and m must be equal.
    The key property: D holds at all actual points u with m < u and u ∈ γ.cut.
    If γ₁.cut ⊊ γ₂.cut, elements of γ₂.cut \ γ₁.cut are in γ₁.complement with D
    holding (by γ₂'s D-between condition), giving an initial segment of γ₁.complement
    where D holds, contradicting γ₁ being D-definable on the left. -/
theorem gap_detection_unique {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {γ₁ γ₂ : Gap M.carrier} {D : StaviFormula} {m : M.carrier}
    (h₁_def : GapDefinableOnLeft M atomMap γ₁ D)
    (h₂_def : GapDefinableOnLeft M atomMap γ₂ D)
    (h₁_bet : ∀ u : M.carrier, m < u → u ∈ γ₁.cut →
      StaviTemporalTruth M atomMap u D)
    (h₂_bet : ∀ u : M.carrier, m < u → u ∈ γ₂.cut →
      StaviTemporalTruth M atomMap u D)
    (hm₁ : m ∈ γ₁.cut)
    (hm₂ : m ∈ γ₂.cut) :
    γ₁ = γ₂ := by
  apply gap_ext
  by_contra hne
  -- WLOG γ₁.cut ⊊ γ₂.cut
  wlog h : ¬(γ₂.cut ⊆ γ₁.cut) with H
  · push Not at hne
    rcases gap_cuts_total γ₁ γ₂ with hsub | hsub
    · exact h fun h' => hne (Set.Subset.antisymm hsub h')
    · exact H h₂_def h₁_def h₂_bet h₁_bet hm₂ hm₁ (Ne.symm hne)
        (fun h' => hne (Set.Subset.antisymm hsub h').symm)
  -- ∃ x ∈ γ₂.cut \ γ₁.cut
  obtain ⟨x, hx₂, hx₁⟩ := Set.not_subset.mp h
  -- γ₁ D-def-left: no initial segment of γ₁.complement has D
  obtain ⟨_, h_no_init⟩ := h₁_def
  -- Derive contradiction: D holds at an initial segment of γ₁.complement
  apply h_no_init
  -- Witness: x ∉ γ₁.cut, and D at all u ∉ γ₁.cut with u ≤ x
  refine ⟨x, hx₁, fun u hu_not_in hu_le => ?_⟩
  -- u ∉ γ₁.cut, so u > m (since m ∈ γ₁.cut and complement elements are above cut)
  have hmu : m < u := by
    by_contra h_not
    push Not at h_not
    exact hu_not_in (γ₁.downward_closed m u hm₁ h_not)
  -- u ≤ x ∈ γ₂.cut, so u ∈ γ₂.cut by downward-closure
  have hu_in_2 : u ∈ γ₂.cut := γ₂.downward_closed x u hx₂ hu_le
  -- D(u) by the D-between condition for γ₂
  exact h₂_bet u hmu hu_in_2

/-! ### Core Gap Detection Helper: U'(X, D) at actual points

The fundamental connection between U'(X, D) evaluated at an actual point m
and the existence of a D-defined gap. This is the linchpin of Lemma 9:
all temporal cases of leftFormula reduce to applications of this lemma.

**Forward direction** (U' → gap exists):
From U'(X, D)(m) with FO-table witness s, the gap γ is defined as the
boundary where D transitions from holding to failing in (m, s).
Gap cut = {x | ∀ u, m < u → u ≤ x → D(u)}.

**Backward direction** (gap → U'):
Given γ with gap conditions, choose s = some point in complement above γ
where ¬D holds. The FO table conditions follow from the gap axioms.
-/

/-- Core helper: U'(X, D) at an actual point m in M_r detects a D-defined
    gap γ > m where X holds at all complement points of γ below some bound,
    with D holding on all actual points between m and γ.
    This is the "engine" behind all temporal cases of Lemma 9.

    Note: The conclusion provides X at complement points (actual points above γ)
    rather than X^mu(γ), because atoms evaluate to False at gaps. Callers that
    need X^mu(γ) for temporal X can derive it from complement-point truth via
    the structure of temporal evaluation at gaps. -/
theorem stavi_untl_gap_detection {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (X D : StaviFormula) (hD : staviDepth D ≤ r) (m : M.carrier) :
    StaviTemporalTruthMu M atomMap r (extendPoint m) (.stavi_untl X D) ↔
    (∃ (γ : RDefinableGap M atomMap r) (s_bound : M.carrier),
      extendPoint (sig := sig) (atomMap := atomMap) (r := r) m < Sum.inr γ ∧
      s_bound ∉ γ.val.cut ∧
      GapDefinableOnLeft M atomMap γ.val D ∧
      (∀ u : M.carrier, m < u → u ∈ γ.val.cut →
        StaviTemporalTruthMu M atomMap r
          (extendPoint (sig := sig) (atomMap := atomMap) (r := r) u) D) ∧
      (∀ u : M.carrier, u ∉ γ.val.cut → u < s_bound →
        StaviTemporalTruth M atomMap u X)) := by
  -- Convert LHS from mu-relativized at actual point to standard evaluation
  rw [stavi_truth_mu_at_point m (.stavi_untl X D)]
  simp only [StaviTemporalTruth]
  -- Now LHS is the FO table: ∃ s > m, conditions (1)(2)(3)
  -- RHS is: ∃ γ, m < γ ∧ GapDefinableOnLeft γ D ∧ D-between(m,γ) ∧ X^mu(γ)
  constructor
  · -- **Forward direction** (FO table → gap):
    intro ⟨s, hms, h_body, ⟨u_fail, hmu_fail, hus_fail, hD_fail⟩,
           ⟨u_init, hmu_init, hus_init, hD_init⟩⟩
    -- Define gap cut via D-cofinality: x ∈ cut iff at every u ∈ (m, x],
    -- ∃ v > u with D on all of (m, v). Ensures cut has no sup in itself.
    let cut : Set M.carrier :=
      {x | ∀ u, m < u → u ≤ x →
        ∃ v, u < v ∧ ∀ w, m < w → w < v → StaviTemporalTruth M atomMap w D}
    have hm_in_cut : m ∈ cut :=
      fun u hmu hum => absurd (lt_of_lt_of_le hmu hum) (lt_irrefl m)
    have hu_fail_not_cut : u_fail ∉ cut := by
      intro h; obtain ⟨v, hfv, hDv⟩ := h u_fail hmu_fail le_rfl
      exact hD_fail (hDv u_fail hmu_fail hfv)
    have h_cut_lt_uf : ∀ x ∈ cut, x < u_fail := by
      intro x hx; by_contra h; push Not at h
      exact hu_fail_not_cut (fun u hmu huf => hx u hmu (le_trans huf h))
    have h_cut_lt_s : ∀ x ∈ cut, x < s :=
      fun x hx => lt_trans (h_cut_lt_uf x hx) hus_fail
    have h_dc : ∀ x y, x ∈ cut → y ≤ x → y ∈ cut :=
      fun x y hx hyx u hmu huy => hx u hmu (le_trans huy hyx)
    have h_proper : cut ≠ Set.univ := by
      intro h; exact hu_fail_not_cut (h ▸ Set.mem_univ u_fail)
    -- Key: condition (1) right disjunct fails when all points below u are cofinal
    have h_cofinal_propagate :
        ∀ u, m < u → u < s →
        (∀ w, m < w → w < u →
          ∃ v, w < v ∧ ∀ z, m < z → z < v → StaviTemporalTruth M atomMap z D) →
        ∃ v, u < v ∧ ∀ z, m < z → z < v → StaviTemporalTruth M atomMap z D := by
      intro u hmu hus h_below
      cases h_body u hmu hus with
      | inl h => exact h
      | inr h =>
        obtain ⟨_, v', hmv', hv'u, hDv'⟩ := h
        obtain ⟨v₂, hv'v₂, hDv₂⟩ := h_below v' hmv' hv'u
        exact absurd (hDv₂ v' hmv' hv'v₂) hDv'
    have hu_init_cut : u_init ∈ cut := by
      intro u hmu huu_init
      exact h_cofinal_propagate u hmu (lt_of_le_of_lt huu_init hus_init)
        (fun w hmw hwu => ⟨u_init, lt_of_lt_of_le hwu huu_init,
          fun z hmz hz_init => hD_init z hmz hz_init⟩)
    have h_D_at_cut : ∀ u, m < u → u ∈ cut → StaviTemporalTruth M atomMap u D := by
      intro u hmu hu_cut
      obtain ⟨v, huv, hDv⟩ := hu_cut u hmu le_rfl
      exact hDv u hmu huv
    -- Cut has no supremum in cut
    have h_no_sup : ¬∃ p, IsLUB cut p ∧ p ∈ cut := by
      intro ⟨p, ⟨h_ub, _⟩, hp_cut⟩
      have hmp : m < p := lt_of_lt_of_le hmu_init (h_ub hu_init_cut)
      obtain ⟨v, hpv, hDv⟩ := hp_cut p hmp le_rfl
      have hvs : v < s := by
        by_contra h; push Not at h
        exact hD_fail (hDv u_fail hmu_fail (lt_of_lt_of_le hus_fail h))
      have hv_cut : v ∈ cut := by
        intro u hmu huv
        rcases eq_or_lt_of_le huv with rfl | huv'
        · -- u = v (renamed), need cofinal at u
          exact h_cofinal_propagate u (lt_trans hmp hpv) hvs
            (fun w hmw hwu => ⟨u, hwu, hDv⟩)
        · exact ⟨v, huv', hDv⟩
      exact not_le.mpr hpv (h_ub hv_cut)
    -- Complement has no minimum
    have h_comp_no_min : ¬∃ b, b ∉ cut ∧ ∀ y, y ∉ cut → b ≤ y := by
      intro ⟨b, hb_not, hb_min⟩
      have hmb : m < b := by
        by_contra h; push Not at h; exact hb_not (h_dc m b hm_in_cut h)
      have hbs : b < s := lt_of_le_of_lt (hb_min u_fail hu_fail_not_cut) hus_fail
      have h_below_b : ∀ y, y < b → y ∈ cut := by
        intro y hyb; by_contra hy_not; exact not_lt.mpr (hb_min y hy_not) hyb
      cases h_body b hmb hbs with
      | inl h_cof =>
        exact hb_not (fun u hmu hub => by
          rcases eq_or_lt_of_le hub with rfl | hub'
          · exact h_cof
          · exact (h_below_b u hub') u hmu le_rfl)
      | inr h =>
        obtain ⟨_, v', hmv', hv'b, hDv'⟩ := h
        obtain ⟨v₂, hv'v₂, hDv₂⟩ := (h_below_b v' hv'b) v' hmv' le_rfl
        exact hDv' (hDv₂ v' hmv' hv'v₂)
    -- Construct the Gap
    let γ_gap : Gap M.carrier :=
      ⟨cut, ⟨m, hm_in_cut⟩, h_proper, h_dc, h_no_sup, h_comp_no_min⟩
    -- GapDefinableOnLeft: D holds on final segment of cut (witness: m),
    -- and D does NOT hold on any initial segment of complement.
    have h_no_init_compl : ¬∃ t, t ∉ cut ∧
        ∀ u, u ∉ cut → u ≤ t → StaviTemporalTruth M atomMap u D := by
      intro ⟨t, ht_not, hDt⟩
      have hmt : m < t := by
        by_contra h; push Not at h; exact ht_not (h_dc m t hm_in_cut h)
      have hts : t < s := by
        by_contra h; push Not at h
        exact hD_fail (hDt u_fail hu_fail_not_cut (le_trans (le_of_lt hus_fail) h))
      -- Show t ∈ cut by showing cofinal at every u ∈ (m, t].
      -- For any u ∈ (m, t] with u < s, condition (1) right disjunct fails:
      -- any ¬D witness v' ∈ (m, u) has D(v') (from h_D_at_cut or hDt). So left holds.
      suffices t ∈ cut from ht_not this
      intro u hmu hut
      have hus : u < s := lt_of_le_of_lt hut hts
      exact h_cofinal_propagate u hmu hus (fun w hmw hwu => by
        have hws : w < s := lt_trans hwu hus
        exact h_cofinal_propagate w hmw hws (fun z hmz hzw => by
          have hzs : z < s := lt_trans hzw hws
          -- z ∈ (m, s). Right disjunct requires ¬D at v' ∈ (m, z).
          -- But v' < z < w < u ≤ t, so D(v') from cut or complement.
          cases h_body z hmz hzs with
          | inl h => exact h
          | inr h =>
            obtain ⟨_, v', hmv', hv'z, hDv'⟩ := h
            have : StaviTemporalTruth M atomMap v' D := by
              by_cases hv'_cut : v' ∈ cut
              · exact h_D_at_cut v' hmv' hv'_cut
              · exact hDt v' hv'_cut (le_trans (le_of_lt hv'z)
                  (le_trans (le_of_lt hzw) (le_trans (le_of_lt hwu) hut)))
            exact absurd this hDv'))
    have h_def_left : GapDefinableOnLeft M atomMap γ_gap D :=
      ⟨⟨u_init, hu_init_cut, fun u hmu hu_cut =>
        h_D_at_cut u (lt_of_lt_of_le hmu_init hmu) hu_cut⟩, h_no_init_compl⟩
    -- r-definability: D has depth ≤ r and defines the gap on the left
    have h_r_def : IsRDefinableGap M atomMap γ_gap r :=
      ⟨D, hD, Or.inl h_def_left⟩
    -- Package as RDefinableGap
    let γ_rdef : RDefinableGap M atomMap r := ⟨γ_gap, h_r_def⟩
    refine ⟨γ_rdef, s, ?_, ?_, ?_, ?_, ?_⟩
    · -- extendPoint m < Sum.inr γ_rdef ↔ m ∈ cut (for point vs gap, < ↔ ∈ cut)
      constructor
      · exact hm_in_cut
      · intro h; exact h hm_in_cut
    · -- s ∉ cut: s is a complement point (cut points are all < s)
      intro hs_cut; exact not_lt.mpr le_rfl (h_cut_lt_s s hs_cut)
    · -- GapDefinableOnLeft M atomMap γ_rdef.val D
      exact h_def_left
    · -- D-between: ∀ u, m < u → u ∈ cut → D^mu(u)
      intro u hmu hu_cut
      exact (stavi_truth_mu_at_point u D).mpr
        (h_D_at_cut u hmu hu_cut)
    · -- X at complement points below s:
      -- For any complement point u < s, the right disjunct of condition (1)
      -- at a smaller complement point u₀ < u gives X at (u₀, s) ⊇ {u}.
      intro u hu_not_cut hus
      -- u ∉ cut, so m < u (complement points are above cut points, m ∈ cut)
      have hmu : m < u := by
        by_contra h; push Not at h; exact hu_not_cut (h_dc m u hm_in_cut h)
      -- Since complement has no minimum, ∃ u₀ < u with u₀ ∉ cut
      have ⟨u₀, hu₀_not, hu₀u⟩ : ∃ u₀, u₀ ∉ cut ∧ u₀ < u := by
        by_contra h_all; push Not at h_all
        exact h_comp_no_min ⟨u, hu_not_cut, fun y hy => h_all y hy⟩
      have hmu₀ : m < u₀ := by
        by_contra h; push Not at h; exact hu₀_not (h_dc m u₀ hm_in_cut h)
      have hu₀s : u₀ < s := lt_trans hu₀u hus
      -- At complement point u₀: left disjunct would imply u₀ ∈ cut, so right holds
      have h_right_u₀ :
          (∀ v, u₀ < v → v < s → StaviTemporalTruth M atomMap v X) ∧
          ∃ v', m < v' ∧ v' < u₀ ∧ ¬StaviTemporalTruth M atomMap v' D := by
        cases h_body u₀ hmu₀ hu₀s with
        | inl h_left =>
          -- Left disjunct: ∃ v > u₀, D on (m, v). This implies u₀ ∈ cut.
          exfalso; apply hu₀_not
          obtain ⟨v, hu₀v, hDv⟩ := h_left
          intro u' hmu' hu'u₀
          exact ⟨v, lt_of_le_of_lt hu'u₀ hu₀v, hDv⟩
        | inr h_right => exact h_right
      -- From right disjunct at u₀: X at all points in (u₀, s), including u
      exact h_right_u₀.1 u hu₀u hus
  · -- **Backward direction** (gap → FO table):
    intro ⟨γ, s_bound, hm_lt_γ, hs_bound_not, h_def_left, h_D_bet, hX_compl⟩
    have hm_in_cut : m ∈ γ.val.cut :=
      (extendPoint_le_gap_iff m γ).mp (le_of_lt hm_lt_γ)
    obtain ⟨⟨t_cut, ht_in, ht_D_final⟩, h_no_init_seg⟩ := h_def_left
    -- Helper: from negation of initial segment condition, get ¬D witnesses
    have h_neg_init : ∀ t, t ∉ γ.val.cut →
        ∃ w, w ∉ γ.val.cut ∧ w ≤ t ∧ ¬StaviTemporalTruth M atomMap w D := by
      intro t ht; by_contra h_all; push Not at h_all
      exact h_no_init_seg ⟨t, ht, fun w hw hwt => h_all w hw hwt⟩
    -- Helper: complement points are above all cut points (including m)
    have h_compl_gt_m : ∀ x, x ∉ γ.val.cut → m < x := by
      intro x hx; by_contra h; push Not at h
      exact hx (γ.val.downward_closed m x hm_in_cut h)
    -- Complement is non-empty (cut is proper)
    have h_compl_ne : ∃ x, x ∉ γ.val.cut := by
      by_contra h_all; push Not at h_all
      exact γ.val.proper (Set.eq_univ_iff_forall.mpr h_all)
    -- Use s_bound as s₀ (a complement point)
    refine ⟨s_bound, h_compl_gt_m s_bound hs_bound_not, ?_, ?_, ?_⟩
    · -- Condition (1): ∀ u ∈ (m, s_bound), disjunction
      intro u hmu hus
      by_cases hu_cut : u ∈ γ.val.cut
      · -- u ∈ cut: first disjunct — D cofinal above u
        left
        -- Since u ∈ cut and cut has no sup, ∃ y ∈ cut with y > u
        have ⟨y, hy_in, huy⟩ : ∃ y ∈ γ.val.cut, u < y := by
          by_contra h_all; push Not at h_all
          exact γ.val.no_sup ⟨u, ⟨fun x hx => h_all x hx, fun b hb => hb hu_cut⟩, hu_cut⟩
        exact ⟨y, huy, fun w hmw hwy =>
          (stavi_truth_mu_at_point w D).mp
            (h_D_bet w hmw (γ.val.downward_closed y w hy_in (le_of_lt hwy)))⟩
      · -- u ∉ cut: second disjunct — X on (u, s_bound) and ¬D witness below u
        right
        refine ⟨?_, ?_⟩
        · -- ∀ v, u < v → v < s_bound → X(v)
          -- All points between two complement points are complement (upward-closed).
          -- hX_compl gives X at complement points below s_bound.
          intro v huv hvs
          -- v is between u (complement) and s_bound (complement), so v ∉ cut
          have hv_not : v ∉ γ.val.cut := by
            intro hv_in
            exact hu_cut (γ.val.downward_closed v u hv_in (le_of_lt huv))
          exact hX_compl v hv_not hvs
        · -- ∃ v', m < v' ∧ v' < u ∧ ¬D(v')
          -- complement_no_min gives y < u with y ∉ cut, then h_neg_init gives ¬D witness
          have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
            by_contra h_all; push Not at h_all
            exact γ.val.complement_no_min ⟨u, hu_cut, fun z hz => h_all z hz⟩
          obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
          exact ⟨w, h_compl_gt_m w hw_not, lt_of_le_of_lt hwy hyu, hDw⟩
    · -- Condition (2): ∃ u ∈ (m, s_bound), ¬D(u)
      -- complement_no_min: s_bound is not the minimum, so ∃ y < s_bound in complement
      have ⟨y, hy_not, hys⟩ : ∃ y, y ∉ γ.val.cut ∧ y < s_bound := by
        by_contra h_all; push Not at h_all
        exact γ.val.complement_no_min ⟨s_bound, hs_bound_not, fun z hz => h_all z hz⟩
      -- h_neg_init gives ¬D witness at or below y
      obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
      exact ⟨w, h_compl_gt_m w hw_not, lt_of_le_of_lt hwy hys, hDw⟩
    · -- Condition (3): ∃ u ∈ (m, s_bound), D on (m, u)
      -- From no_sup: ∃ y ∈ cut with y > m
      have ⟨y, hy_in, hmy⟩ : ∃ y ∈ γ.val.cut, m < y := by
        by_contra h_all; push Not at h_all
        exact γ.val.no_sup ⟨m, ⟨fun x hx => h_all x hx, fun b hb => hb hm_in_cut⟩, hm_in_cut⟩
      -- y < s_bound since y ∈ cut, s_bound ∉ cut, and cut is downward-closed
      have hys : y < s_bound := by
        by_contra h; push Not at h
        exact hs_bound_not (γ.val.downward_closed y s_bound hy_in h)
      exact ⟨y, hmy, hys, fun v hmv hvy =>
        (stavi_truth_mu_at_point v D).mp
          (h_D_bet v hmv (γ.val.downward_closed y v hy_in (le_of_lt hvy)))⟩

-- std_untl_gap_detection: DELETED (provably false).
-- U(X,D) has no D-failure condition, so GapDefinableOnLeft fails for D = top.
-- Backward direction also fails: complement points have X but D fails near gap.
-- Affected cases in left/right_formula_gap_detection proved directly instead.

/-! ### Lemma 9: Gap Detection Correctness (GHR93)

The crucial bridge: `leftFormula(A,D)` evaluated at an actual point m
detects whether there is a D-defined gap gamma > m where A^mu holds at gamma.

Precisely: for an actual point m in M, and a gap gamma in M_r:

  StaviTemporalTruthMu M atomMap r (extendPoint m) (leftFormula A D) ↔
    ∃ (γ : RDefinableGap M atomMap r),
      extendPoint m < Sum.inr γ ∧
      GapDefinableOnLeft M atomMap γ.val D ∧
      (∀ u : M.carrier, m < u → u ∈ γ.val.cut →
        StaviTemporalTruthMu M atomMap r (extendPoint u) D) ∧
      StaviTemporalTruthMu M atomMap r (Sum.inr γ) A
-/

/--
**GHR93 Lemma 9** (Gap detection correctness, left direction):
leftFormula(A, D) evaluated at an actual point m in M_r detects
whether A^mu holds at a gap gamma that is D-defined on the left,
with gamma > m and D holding at all actual points between m and gamma.

This is the core of the gap detection machinery: it converts a property
of a gap (A^mu holds there, gap is D-defined) into a temporal formula
evaluable at actual points.

NOTE: The proof is by case analysis on the structure of A, connecting the
syntactic leftFormula definition with the semantic gap properties. The S/S'
cases use `std_untl`/`std_snce` constructors to correctly represent standard
Until/Since of Stavi-enriched subformulas. Every case is proved here; the
theorem is an unconditional equivalence.
-/
theorem left_formula_gap_detection {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (A D : StaviFormula) (hD : staviDepth D ≤ r) (m : M.carrier) :
    StaviTemporalTruthMu M atomMap r (extendPoint m) (leftFormula A D) ↔
    (∃ (γ : RDefinableGap M atomMap r),
      extendPoint (sig := sig) (atomMap := atomMap) (r := r) m < Sum.inr γ ∧
      GapDefinableOnLeft M atomMap γ.val D ∧
      (∀ u : M.carrier, m < u → u ∈ γ.val.cut →
        StaviTemporalTruthMu M atomMap r
          (extendPoint (sig := sig) (atomMap := atomMap) (r := r) u) D) ∧
      StaviTemporalTruthMu M atomMap r (Sum.inr γ) A) := by
  induction A generalizing m with
  | base φ =>
    -- leftFormula (.base φ) D = leftFormulaBase D φ
    -- This case requires sub-induction on the Formula φ.
    -- All sub-cases reduce to the same pattern as the outer StaviFormula cases
    -- because leftFormulaBase maps atom/bot/box to .base .bot (both sides False)
    -- and imp/untl/snce to formulas that mirror the neg/conj/stavi_untl patterns.
    -- For now we handle this via a sub-induction on φ.
    simp only [leftFormula]
    induction φ with
    | atom a =>
      -- leftFormulaBase D (atom a) = .base .bot
      simp only [leftFormulaBase, StaviTemporalTruthMu, TemporalTruthMu]
      constructor
      · exact False.elim
      · intro ⟨γ, _, _, _, hA⟩; exact hA
    | bot =>
      -- leftFormulaBase D bot = .base .bot
      simp only [leftFormulaBase, StaviTemporalTruthMu, TemporalTruthMu]
      constructor
      · exact False.elim
      · intro ⟨γ, _, _, _, hA⟩; exact hA
    | box f =>
      -- leftFormulaBase D (box f) = .base .bot
      simp only [leftFormulaBase, StaviTemporalTruthMu, TemporalTruthMu]
      constructor
      · exact False.elim
      · intro ⟨γ, _, _, _, hA⟩; exact hA
    | imp f g ih_f ih_g =>
      -- leftFormulaBase D (f.imp g) = U'(⊤,D) ∧ ¬(left_base(f) ∧ (U'(⊤,D) ∧ ¬left_base(g)))
      -- The neg/conj outer cases handle this pattern using gap_detection_unique.
      -- imp = ¬(f ∧ ¬g), so (.base (f.imp g))^mu at γ = (f^mu → g^mu) at γ.
      -- Strategy: use the proved neg and conj outer-case patterns with gap uniqueness.
      constructor
      · -- Forward direction
        intro hLHS
        -- Unfold leftFormulaBase
        simp only [leftFormulaBase] at hLHS
        -- hLHS : StaviTemporalTruthMu ... (.conj (.stavi_untl (.base top) D) (.neg (.conj
        -- (leftFormulaBase D f) (.conj (.stavi_untl (.base top) D) (.neg (leftFormulaBase D
        -- g))))))
        simp only [StaviTemporalTruthMu] at hLHS
        obtain ⟨hU, hNeg⟩ := hLHS
        -- Extract gap from U'(⊤,D)(m)
        have hU' : StaviTemporalTruthMu M atomMap r (extendPoint m)
            (.stavi_untl (.base Formula.top) D) := by
          simp only [StaviTemporalTruthMu]; exact hU
        obtain ⟨γ, _s_bound, hγ_lt, _hs_not, hγ_def, hγ_bet, _⟩ :=
          (stavi_untl_gap_detection (.base Formula.top) D hD m).mp hU'
        refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
        -- Need: (.base (f.imp g))^mu(γ) = TemporalTruthMu M atomMap r (Sum.inr γ) (f.imp g)
        simp only [StaviTemporalTruthMu, TemporalTruthMu]
        intro hf_at_γ
        -- From f^mu(γ), by IH backward: leftFormulaBase D f at m
        have hLeft_f : StaviTemporalTruthMu M atomMap r (extendPoint m)
            (leftFormulaBase D f) :=
          ih_f.mpr ⟨γ, hγ_lt, hγ_def, hγ_bet, hf_at_γ⟩
        -- From ¬(left_base(f) ∧ U'(⊤,D) ∧ ¬left_base(g)) and left_base(f) and U'(⊤,D): left_base(g)
        have hLeft_g : StaviTemporalTruthMu M atomMap r (extendPoint m)
            (leftFormulaBase D g) := by
          by_contra h
          exact hNeg ⟨hLeft_f, hU, h⟩
        -- From left_base(g), by IH forward: ∃ γ', ... ∧ g^mu(γ')
        obtain ⟨γ', hγ'_lt, hγ'_def, hγ'_bet, hg_at_γ'⟩ := ih_g.mp hLeft_g
        -- γ = γ' by gap_detection_unique
        have hm_in : m ∈ γ.val.cut :=
          (extendPoint_le_gap_iff m γ).mp (le_of_lt hγ_lt)
        have hm_in' : m ∈ γ'.val.cut :=
          (extendPoint_le_gap_iff m γ').mp (le_of_lt hγ'_lt)
        have hγ_bet_std : ∀ u, m < u → u ∈ γ.val.cut →
            StaviTemporalTruth M atomMap u D :=
          fun u hmu hu_in => (stavi_truth_mu_at_point u D).mp (hγ_bet u hmu hu_in)
        have hγ'_bet_std : ∀ u, m < u → u ∈ γ'.val.cut →
            StaviTemporalTruth M atomMap u D :=
          fun u hmu hu_in => (stavi_truth_mu_at_point u D).mp (hγ'_bet u hmu hu_in)
        have heq : γ.val = γ'.val :=
          gap_detection_unique hγ_def hγ'_def hγ_bet_std hγ'_bet_std hm_in hm_in'
        rw [Subtype.ext heq]
        exact hg_at_γ'
      · -- Backward direction
        intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hfg_at_γ⟩
        simp only [leftFormulaBase, StaviTemporalTruthMu]
        constructor
        · -- U'(⊤,D)(m): from γ, construct stavi_untl_gap_detection
          have h_compl : ∃ x, x ∉ γ.val.cut := by
            by_contra h; push Not at h; exact γ.val.proper (Set.eq_univ_iff_forall.mpr h)
          obtain ⟨s_b, hs_b⟩ := h_compl
          have hTop_compl : ∀ u : M.carrier, u ∉ γ.val.cut → u < s_b →
              StaviTemporalTruth M atomMap u (.base Formula.top) := by
            intro u _ _
            simp only [StaviTemporalTruth, TemporalTruth, Formula.top]; exact id
          have := (stavi_untl_gap_detection (.base Formula.top) D hD m).mpr
            ⟨γ, s_b, hγ_lt, hs_b, hγ_def, hγ_bet, hTop_compl⟩
          simp only [StaviTemporalTruthMu] at this
          exact this
        · -- ¬(left_base(f) ∧ U'(⊤,D)(m) ∧ ¬left_base(g))
          intro ⟨hLf, _, hNLg⟩
          obtain ⟨γ₁, hγ₁_lt, hγ₁_def, hγ₁_bet, hf_at_γ₁⟩ := ih_f.mp hLf
          have hm_in : m ∈ γ.val.cut :=
            (extendPoint_le_gap_iff m γ).mp (le_of_lt hγ_lt)
          have hm_in₁ : m ∈ γ₁.val.cut :=
            (extendPoint_le_gap_iff m γ₁).mp (le_of_lt hγ₁_lt)
          have hγ_bet_std : ∀ u, m < u → u ∈ γ.val.cut →
              StaviTemporalTruth M atomMap u D :=
            fun u hmu hu_in => (stavi_truth_mu_at_point u D).mp (hγ_bet u hmu hu_in)
          have hγ₁_bet_std : ∀ u, m < u → u ∈ γ₁.val.cut →
              StaviTemporalTruth M atomMap u D :=
            fun u hmu hu_in => (stavi_truth_mu_at_point u D).mp (hγ₁_bet u hmu hu_in)
          have heq : γ₁.val = γ.val :=
            gap_detection_unique hγ₁_def hγ_def hγ₁_bet_std hγ_bet_std hm_in₁ hm_in
          -- f → g at γ, so g^mu(γ)
          simp only [StaviTemporalTruthMu, TemporalTruthMu] at hfg_at_γ
          have hg_at_γ := hfg_at_γ ((Subtype.ext heq) ▸ hf_at_γ₁)
          exact hNLg (ih_g.mpr ⟨γ, hγ_lt, hγ_def, hγ_bet, hg_at_γ⟩)
    | untl g f _ _ =>
      -- leftFormulaBase D (untl g f) = .stavi_untl (.conj (.base g) (.base (untl g f))) D
      -- This mirrors the stavi_untl outer case
      simp only [leftFormulaBase]
      rw [stavi_untl_gap_detection (.conj (.base g) (.base (.untl g f))) D hD m]
      constructor
      · -- Forward: complement-point truth of g ∧ U(f,g) → U(f,g)^mu at γ
        intro ⟨γ, s_bound, hγ_lt, hs_not, hγ_def, hγ_bet, hX_compl⟩
        refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
        -- hX_compl: ∀ u ∉ γ.cut, u < s_bound → g(u) ∧ U(f,g)(u)
        -- Need: U(f,g)^mu at Sum.inr γ
        simp only [StaviTemporalTruthMu, TemporalTruthMu]
        -- U(f,g)^mu at γ: ∃ s > γ, MuHolds s ∧ f^mu(s) ∧ ∀ v ∈ (γ,s), MuHolds v → g^mu(v)
        -- Pick a complement point u₀ above γ where U(f,g) holds
        have ⟨u₀, hu₀_not, hu₀s⟩ : ∃ u₀, u₀ ∉ γ.val.cut ∧ u₀ < s_bound := by
          by_contra h_all; push Not at h_all
          exact γ.val.complement_no_min ⟨s_bound, hs_not, fun z hz => h_all z hz⟩
        have hX_u₀ := hX_compl u₀ hu₀_not hu₀s
        simp only [StaviTemporalTruth, TemporalTruth] at hX_u₀
        obtain ⟨hg_u₀, s₁, hu₀s₁, hf_s₁, hg_between⟩ := hX_u₀
        -- s₁ ∉ γ.cut (since u₀ ∉ γ.cut and u₀ < s₁, and cut is downward closed)
        have hs₁_not : s₁ ∉ γ.val.cut := by
          intro h; exact hu₀_not (γ.val.downward_closed s₁ u₀ h (le_of_lt hu₀s₁))
        refine ⟨extendPoint s₁, ⟨hs₁_not, hs₁_not⟩, ⟨s₁, rfl⟩,
          (temporal_truth_mu_at_point s₁ f).mpr hf_s₁, fun v hγv hvs hmu => ?_⟩
        obtain ⟨v₀, rfl⟩ := hmu
        have hv₀_not : v₀ ∉ γ.val.cut := by
          intro h; exact not_lt.mpr (show extendPoint v₀ ≤ Sum.inr γ from h) hγv
        have hv₀_s₁ : v₀ < s₁ := (extendPoint_lt_iff v₀ s₁).mp hvs
        apply (temporal_truth_mu_at_point v₀ g).mpr
        by_cases hv_u₀ : u₀ < v₀
        · exact hg_between v₀ hv_u₀ hv₀_s₁
        · push Not at hv_u₀
          have hv₀_sb : v₀ < s_bound := lt_of_le_of_lt hv_u₀ hu₀s
          exact (hX_compl v₀ hv₀_not hv₀_sb).1
      · -- Backward: U(f,g)^mu at γ → complement-point truth of g ∧ U(f,g)
        intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hUA⟩
        simp only [StaviTemporalTruthMu, TemporalTruthMu] at hUA
        obtain ⟨s, hγs, hmu_s, hf_s, hg_mu⟩ := hUA
        obtain ⟨s₁, rfl⟩ := hmu_s
        have hs₁_not : s₁ ∉ γ.val.cut := by
          intro h; exact not_lt.mpr (show extendPoint s₁ ≤ Sum.inr γ from h) hγs
        refine ⟨γ, s₁, hγ_lt, hs₁_not, hγ_def, hγ_bet, fun u hu_not hu_s₁ => ?_⟩
        simp only [StaviTemporalTruth, TemporalTruth]
        constructor
        · -- g(u): u is a complement point between γ and s₁
          have hγu : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT (Sum.inr γ)
              (extendPoint u) := by
            change u ∉ γ.val.cut ∧ ¬(u ∈ γ.val.cut); exact ⟨hu_not, hu_not⟩
          exact (temporal_truth_mu_at_point u g).mp
            (hg_mu (extendPoint u) hγu ((extendPoint_lt_iff u s₁).mpr hu_s₁) ⟨u, rfl⟩)
        · -- U(f,g)(u): use s₁ as witness
          refine ⟨s₁, hu_s₁, (temporal_truth_mu_at_point s₁ f).mp hf_s, fun v huv hvs₁ => ?_⟩
          have hv_not : v ∉ γ.val.cut := by
            intro h; exact hu_not (γ.val.downward_closed v u h (le_of_lt huv))
          have hγv : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT (Sum.inr γ)
              (extendPoint v) := by
            change v ∉ γ.val.cut ∧ ¬(v ∈ γ.val.cut); exact ⟨hv_not, hv_not⟩
          exact (temporal_truth_mu_at_point v g).mp
            (hg_mu (extendPoint v) hγv ((extendPoint_lt_iff v s₁).mpr hvs₁) ⟨v, rfl⟩)
    | snce g f _ _ =>
      -- leftFormulaBase D (.snce f g) = .std_untl compound D where
      -- compound = D ∧ g ∧ S(f,g) ∧ U'(⊤, g∧D) ∧ ¬U'(D, g∧D)
      simp only [leftFormulaBase]
      rw [stavi_truth_mu_at_point m (.std_untl _ D)]
      simp only [StaviTemporalTruth]
      constructor
      · -- Forward: std_untl(compound, D)^mu(m) → gap conditions
        intro ⟨s, hms, hcompound_s, hD_bet⟩
        obtain ⟨hDs, hgs, hSnce_s, hU'_gD_s, hNotU'D_gD_s⟩ := hcompound_s
        obtain ⟨s₁, hss₁, h_body, h_fail, h_init⟩ := hU'_gD_s
        obtain ⟨u_fail, hsu_fail, hu_fail_s₁, hgD_fail⟩ := h_fail
        obtain ⟨u_init, hsu_init, hu_init_s₁, hgD_init⟩ := h_init
        -- Build B∧D-cofinal cut (mirrors stavi_untl_gap_detection)
        let gD : M.carrier → Prop := fun u =>
          TemporalTruth M atomMap u g ∧ StaviTemporalTruth M atomMap u D
        let cut : Set M.carrier :=
          {x | ∀ u, s < u → u ≤ x → ∃ v, u < v ∧ ∀ w, s < w → w < v → gD w}
        have hs_in_cut : s ∈ cut :=
          fun u hsu hus => absurd (lt_of_lt_of_le hsu hus) (lt_irrefl s)
        have hu_fail_not_cut : u_fail ∉ cut := by
          intro h; obtain ⟨v, hfv, hgDv⟩ := h u_fail hsu_fail le_rfl
          exact hgD_fail (hgDv u_fail hsu_fail hfv)
        have h_cut_lt_uf : ∀ x ∈ cut, x < u_fail := by
          intro x hx; by_contra h; push Not at h
          exact hu_fail_not_cut (fun u hsu huf => hx u hsu (le_trans huf h))
        have h_cut_lt_s₁ : ∀ x ∈ cut, x < s₁ :=
          fun x hx => lt_trans (h_cut_lt_uf x hx) hu_fail_s₁
        have h_dc : ∀ x y, x ∈ cut → y ≤ x → y ∈ cut :=
          fun x y hx hyx u hsu huy => hx u hsu (le_trans huy hyx)
        have h_proper : cut ≠ Set.univ := by
          intro h; exact hu_fail_not_cut (h ▸ Set.mem_univ u_fail)
        have h_cofinal_propagate :
            ∀ u, s < u → u < s₁ →
            (∀ w, s < w → w < u →
              ∃ v, w < v ∧ ∀ z, s < z → z < v → gD z) →
            ∃ v, u < v ∧ ∀ z, s < z → z < v → gD z := by
          intro u hsu hus₁ h_below
          cases h_body u hsu hus₁ with
          | inl h => exact h
          | inr h =>
            obtain ⟨_, v', hsv', hv'u, hgDv'⟩ := h
            obtain ⟨v₂, hv'v₂, hgDv₂⟩ := h_below v' hsv' hv'u
            exact absurd (hgDv₂ v' hsv' hv'v₂) hgDv'
        have hu_init_cut : u_init ∈ cut := by
          intro u hsu huu_init
          exact h_cofinal_propagate u hsu (lt_of_le_of_lt huu_init hu_init_s₁)
            (fun w hsw hwu => ⟨u_init, lt_of_lt_of_le hwu huu_init,
              fun z hsz hz_init => hgD_init z hsz hz_init⟩)
        have h_gD_at_cut : ∀ u, s < u → u ∈ cut → gD u := by
          intro u hsu hu_cut
          obtain ⟨v, huv, hgDv⟩ := hu_cut u hsu le_rfl
          exact hgDv u hsu huv
        have h_no_sup : ¬∃ p, IsLUB cut p ∧ p ∈ cut := by
          intro ⟨p, ⟨h_ub, _⟩, hp_cut⟩
          have hsp : s < p := lt_of_lt_of_le hsu_init (h_ub hu_init_cut)
          obtain ⟨v, hpv, hgDv⟩ := hp_cut p hsp le_rfl
          have hvs₁ : v < s₁ := by
            by_contra h; push Not at h
            exact hgD_fail (hgDv u_fail hsu_fail (lt_of_lt_of_le hu_fail_s₁ h))
          have hv_cut : v ∈ cut := by
            intro u hsu huv
            rcases eq_or_lt_of_le huv with rfl | huv'
            · exact h_cofinal_propagate u (lt_trans hsp hpv) hvs₁
                (fun w hsw hwu => ⟨u, hwu, hgDv⟩)
            · exact ⟨v, huv', hgDv⟩
          exact not_le.mpr hpv (h_ub hv_cut)
        have h_comp_no_min : ¬∃ b, b ∉ cut ∧ ∀ y, y ∉ cut → b ≤ y := by
          intro ⟨b, hb_not, hb_min⟩
          have hsb : s < b := by
            by_contra h; push Not at h; exact hb_not (h_dc s b hs_in_cut h)
          have hbs₁ : b < s₁ := lt_of_le_of_lt (hb_min u_fail hu_fail_not_cut) hu_fail_s₁
          have h_below_b : ∀ y, y < b → y ∈ cut := by
            intro y hyb; by_contra hy_not; exact not_lt.mpr (hb_min y hy_not) hyb
          cases h_body b hsb hbs₁ with
          | inl h_cof =>
            exact hb_not (fun u hsu hub => by
              rcases eq_or_lt_of_le hub with rfl | hub'
              · exact h_cof
              · exact (h_below_b u hub') u hsu le_rfl)
          | inr h =>
            obtain ⟨_, v', hsv', hv'b, hgDv'⟩ := h
            obtain ⟨v₂, hv'v₂, hgDv₂⟩ := (h_below_b v' hv'b) v' hsv' le_rfl
            exact hgDv' (hgDv₂ v' hsv' hv'v₂)
        -- Construct the Gap
        let γ_gap : Gap M.carrier :=
          ⟨cut, ⟨s, hs_in_cut⟩, h_proper, h_dc, h_no_sup, h_comp_no_min⟩
        -- Show D-definable-on-left
        -- Part 1: D cofinal in cut (from gD cofinal → D cofinal)
        have h_D_cofinal_cut : ∃ t, t ∈ γ_gap.cut ∧
            ∀ u, t ≤ u → u ∈ γ_gap.cut → StaviTemporalTruth M atomMap u D :=
          ⟨u_init, hu_init_cut, fun u hu_le hu_cut =>
            (h_gD_at_cut u (lt_of_lt_of_le hsu_init hu_le) hu_cut).2⟩
        -- Part 2a: No initial complement segment with gD
        have h_no_init_compl_gD : ¬∃ t, t ∉ γ_gap.cut ∧
            ∀ u, u ∉ γ_gap.cut → u ≤ t → gD u := by
          intro ⟨t, ht_not, hgDt⟩
          have hst : s < t := by
            by_contra h; push Not at h; exact ht_not (h_dc s t hs_in_cut h)
          have hts₁ : t < s₁ := by
            by_contra h; push Not at h
            exact hgD_fail (hgDt u_fail hu_fail_not_cut (le_trans (le_of_lt hu_fail_s₁) h))
          suffices t ∈ cut from ht_not this
          intro u hsu hut
          exact h_cofinal_propagate u hsu (lt_of_le_of_lt hut hts₁)
            (fun w hsw hwu =>
              h_cofinal_propagate w hsw (lt_trans hwu (lt_of_le_of_lt hut hts₁))
                (fun z hsz hzw => by
                  cases h_body z hsz (lt_trans hzw (lt_trans hwu
                      (lt_of_le_of_lt hut hts₁))) with
                  | inl h => exact h
                  | inr h =>
                    obtain ⟨_, v', hsv', hv'z, hgDv'⟩ := h
                    have : gD v' := by
                      by_cases hv'_cut : v' ∈ cut
                      · exact h_gD_at_cut v' hsv' hv'_cut
                      · exact hgDt v' hv'_cut (le_trans (le_of_lt hv'z)
                          (le_trans (le_of_lt hzw) (le_trans (le_of_lt hwu) hut)))
                    exact absurd this hgDv'))
        -- D-failure: D fails somewhere in (s, s₁)
        have hD_fails : ∃ u_D, s < u_D ∧ u_D < s₁ ∧
            ¬StaviTemporalTruth M atomMap u_D D := by
          by_contra h_all_D; push Not at h_all_D
          apply hNotU'D_gD_s
          exact ⟨s₁, hss₁,
            fun u hsu hus₁ => by
              cases h_body u hsu hus₁ with
              | inl h => left; exact h
              | inr h =>
                right
                exact ⟨fun v huv hvs₁ => h_all_D v (lt_trans hsu huv) hvs₁,
                       h.2⟩,
            ⟨u_fail, hsu_fail, hu_fail_s₁, hgD_fail⟩,
            ⟨u_init, hsu_init, hu_init_s₁, hgD_init⟩⟩
        obtain ⟨u_D, hsu_D, hu_D_s₁, hD_fail_D⟩ := hD_fails
        have hu_D_not_cut : u_D ∉ cut := by
          intro h; exact hD_fail_D (h_gD_at_cut u_D hsu_D h).2
        -- Complement points are > all cut points
        have h_compl_gt_cut : ∀ x, x ∉ cut → ∀ y, y ∈ cut → y < x := by
          intro x hx y hy; by_contra h; push Not at h
          exact hx (h_dc y x hy h)
        -- Part 2b: No initial complement segment with D
        have h_no_init_compl_D : ¬∃ t, t ∉ γ_gap.cut ∧
            ∀ u, u ∉ γ_gap.cut → u ≤ t →
              StaviTemporalTruth M atomMap u D := by
          intro ⟨t, ht_not, hDt⟩
          have hst : s < t := h_compl_gt_cut t ht_not s hs_in_cut
          -- t < u_D (otherwise D(u_D) from hDt)
          have ht_uD : t < u_D := by
            by_contra h; push Not at h
            exact hD_fail_D (hDt u_D hu_D_not_cut h)
          have hts₁ : t < s₁ := lt_trans ht_uD hu_D_s₁
          -- Construct U'(D, gD)(s) with bound t, contradicting hNotU'D_gD_s
          apply hNotU'D_gD_s
          refine ⟨t, hst, ?_, ?_, ?_⟩
          · -- Condition 1
            intro u hsu hut
            cases h_body u hsu (lt_trans hut hts₁) with
            | inl h => left; exact h
            | inr h =>
              right
              exact ⟨fun v huv hvt => by
                by_cases hv_cut : v ∈ cut
                · exact (h_gD_at_cut v (lt_trans hsu huv) hv_cut).2
                · exact hDt v hv_cut (le_of_lt hvt),
                h.2⟩
          · -- Condition 2: gD fails in (s, t)
            by_contra h_no_fail; push Not at h_no_fail
            apply h_no_init_compl_gD
            -- All complement points ≤ t have gD? We need a complement point with ¬gD
            -- complement_no_min gives ∃ c < t with c ∉ cut
            obtain ⟨c, hc_not, hct⟩ : ∃ c, c ∉ cut ∧ c < t := by
              by_contra h; push Not at h
              exact h_comp_no_min ⟨t, ht_not, fun y hy => h y hy⟩
            -- h_no_fail says: ∀ u, s < u → u < t → gD u (no gD failure in (s,t))
            -- c is complement, s < c < t, so gD(c) from h_no_fail
            have hsc : s < c := h_compl_gt_cut c hc_not s hs_in_cut
            have hgDc := h_no_fail c hsc hct
            -- But then c is complement with gD: initial complement has gD
            exact ⟨c, hc_not, fun u hu huc => by
              have hsu' : s < u := h_compl_gt_cut u hu s hs_in_cut
              have hut' : u < t := lt_of_le_of_lt huc hct
              exact h_no_fail u hsu' hut'⟩
          · -- Condition 3: gD initial in (s, t)
            have : u_init < t := h_compl_gt_cut t ht_not u_init hu_init_cut
            exact ⟨u_init, hsu_init, this, hgD_init⟩
        have h_def_left_D : GapDefinableOnLeft M atomMap γ_gap D :=
          ⟨h_D_cofinal_cut, h_no_init_compl_D⟩
        have h_r_def : IsRDefinableGap M atomMap γ_gap r :=
          ⟨D, hD, Or.inl h_def_left_D⟩
        let γ : RDefinableGap M atomMap r := ⟨γ_gap, h_r_def⟩
        refine ⟨γ, ?_, ?_, ?_, ?_⟩
        · -- extendPoint m < Sum.inr γ: m ∈ cut
          have hm_in : m ∈ cut := h_dc s m hs_in_cut (le_of_lt hms)
          constructor
          · exact hm_in
          · intro h; exact h hm_in
        · exact h_def_left_D
        · -- D^mu at cut points above m
          intro u hmu hu_cut
          by_cases hsu : s < u
          · exact (stavi_truth_mu_at_point u D).mpr (h_gD_at_cut u hsu hu_cut).2
          · push Not at hsu
            rcases eq_or_lt_of_le hsu with rfl | hus
            · exact (stavi_truth_mu_at_point u D).mpr hDs
            · exact (stavi_truth_mu_at_point u D).mpr (hD_bet u hmu hus)
        · -- S(f,g)^mu at γ: use witness from S(f,g)(s)
          simp only [TemporalTruth] at hSnce_s
          obtain ⟨q, hqs, hf_q, hg_qs⟩ := hSnce_s
          have hq_cut : q ∈ cut := h_dc s q hs_in_cut (le_of_lt hqs)
          change TemporalTruthMu M atomMap r (Sum.inr γ) (g.snce f)
          exact ⟨extendPoint q, ⟨hq_cut, fun h => h hq_cut⟩, ⟨q, rfl⟩,
            (temporal_truth_mu_at_point q f).mpr hf_q,
            fun u hqu huγ hmu => by
              obtain ⟨p, rfl⟩ := hmu
              apply (temporal_truth_mu_at_point p g).mpr
              have hp_cut : p ∈ cut := huγ.1
              have hqp : q < p := (extendPoint_lt_iff q p).mp hqu
              by_cases hps : p ≤ s
              · rcases eq_or_lt_of_le hps with rfl | hps'
                · exact hgs
                · exact hg_qs p hqp hps'
              · push Not at hps
                exact (h_gD_at_cut p hps hp_cut).1⟩
      · -- Backward: gap conditions → std_untl(compound, D)^mu(m)
        -- Given D-gap γ with S(f,g)^mu(γ), construct std_untl(compound, D)(m)
        -- where compound = D ∧ g ∧ S(f,g) ∧ U'(⊤, g∧D) ∧ ¬U'(D, g∧D)
        intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hSnce_mu⟩
        -- S(f,g)^mu(γ): ∃ t < γ (mu-point), f^mu(t) ∧ g^mu on (t, γ)
        simp only [StaviTemporalTruthMu, TemporalTruthMu] at hSnce_mu
        obtain ⟨t_ext, ht_γ, ⟨t_pt, rfl⟩, hf_t, hg_mu⟩ := hSnce_mu
        -- t_pt is in the cut
        have ht_cut : t_pt ∈ γ.val.cut :=
          (extendPoint_le_gap_iff t_pt γ).mp (le_of_lt ht_γ)
        -- m is in the cut
        have hm_cut : m ∈ γ.val.cut :=
          (extendPoint_le_gap_iff m γ).mp (le_of_lt hγ_lt)
        -- Find a cut point s above both m and t_pt (cut has no sup)
        have ⟨s, hs_cut, hms, hts⟩ : ∃ s, s ∈ γ.val.cut ∧ m < s ∧ t_pt < s := by
          -- Cut has no sup, so there exist cut points above any cut member.
          -- We need one above both m and t_pt.
          -- First get one above m:
          have ⟨s₁, hs₁, hms₁⟩ : ∃ s₁ ∈ γ.val.cut, m < s₁ := by
            by_contra h; push Not at h
            exact γ.val.no_sup ⟨m, ⟨h, fun _ hb => hb hm_cut⟩, hm_cut⟩
          -- Then get one above max(s₁, t_pt):
          have hmax_cut : max s₁ t_pt ∈ γ.val.cut := by
            rcases le_or_gt s₁ t_pt with h | h
            · simp only [max_eq_right h]; exact ht_cut
            · simp only [max_eq_left (le_of_lt h)]; exact hs₁
          have ⟨s₂, hs₂, hmax_s₂⟩ : ∃ s₂ ∈ γ.val.cut, max s₁ t_pt < s₂ := by
            by_contra h; push Not at h
            exact γ.val.no_sup ⟨max s₁ t_pt, ⟨h, fun _ hb => hb hmax_cut⟩, hmax_cut⟩
          exact ⟨s₂, hs₂,
            lt_trans hms₁ (lt_of_le_of_lt (le_max_left s₁ t_pt) hmax_s₂),
            lt_of_le_of_lt (le_max_right s₁ t_pt) hmax_s₂⟩
        -- Properties at s (cut point above m and t_pt):
        -- D(s) from D-between
        have hDs : StaviTemporalTruth M atomMap s D :=
          (stavi_truth_mu_at_point s D).mp (hγ_bet s hms hs_cut)
        -- g(s) from S(f,g)^mu(γ): s is a cut point above t_pt
        have hγs : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint t_pt) (extendPoint s) :=
          (extendPoint_lt_iff t_pt s).mpr hts
        have hγs' : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint s) (Sum.inr γ) := by
          exact ⟨hs_cut, fun h => h hs_cut⟩
        have hgs : TemporalTruth M atomMap s g :=
          (temporal_truth_mu_at_point s g).mp
            (hg_mu (extendPoint s) hγs hγs' ⟨s, rfl⟩)
        -- S(f,g)(s): witness t_pt with f(t_pt) and g on (t_pt, s)
        have hSnce_s : TemporalTruth M atomMap s (g.snce f) := by
          simp only [TemporalTruth]
          refine ⟨t_pt, hts, (temporal_truth_mu_at_point t_pt f).mp hf_t, fun u htu hus => ?_⟩
          have hu_cut : u ∈ γ.val.cut := γ.val.downward_closed s u hs_cut (le_of_lt hus)
          have hγu : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (extendPoint t_pt) (extendPoint u) :=
            (extendPoint_lt_iff t_pt u).mpr htu
          have huγ : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (extendPoint u) (Sum.inr γ) := ⟨hu_cut, fun h => h hu_cut⟩
          exact (temporal_truth_mu_at_point u g).mp
            (hg_mu (extendPoint u) hγu huγ ⟨u, rfl⟩)
        -- D on (m, s): all points between m and s are cut points and have D
        have hD_bet_ms : ∀ u, m < u → u < s → StaviTemporalTruth M atomMap u D := by
          intro u hmu hus
          have hu_cut : u ∈ γ.val.cut := γ.val.downward_closed s u hs_cut (le_of_lt hus)
          exact (stavi_truth_mu_at_point u D).mp (hγ_bet u hmu hu_cut)
        -- Extract gap definability conditions
        obtain ⟨⟨t_D, ht_D_cut, hD_final⟩, h_no_init_D⟩ := hγ_def
        -- Helper: complement points > cut points
        have h_compl_gt : ∀ x, x ∉ γ.val.cut → ∀ y, y ∈ γ.val.cut → y < x := by
          intro x hx y hy; by_contra h; push Not at h
          exact hx (γ.val.downward_closed y x hy h)
        -- Helper: ¬D witnesses at complement points
        have h_neg_init : ∀ t, t ∉ γ.val.cut →
            ∃ w, w ∉ γ.val.cut ∧ w ≤ t ∧ ¬StaviTemporalTruth M atomMap w D := by
          intro t ht; by_contra h_all; push Not at h_all
          exact h_no_init_D ⟨t, ht, fun w hw hwt => h_all w hw hwt⟩
        -- Get a complement point for U'(⊤, g∧D) bound
        have ⟨c₀, hc₀_not⟩ : ∃ c₀, c₀ ∉ γ.val.cut := by
          by_contra h; push Not at h
          exact γ.val.proper (Set.eq_univ_iff_forall.mpr h)
        have hsc₀ : s < c₀ := h_compl_gt c₀ hc₀_not s hs_cut
        -- g∧D at cut points above s
        have h_gD_cut : ∀ u, s < u → u ∈ γ.val.cut →
            TemporalTruth M atomMap u g ∧ StaviTemporalTruth M atomMap u D := by
          intro u hsu hu_cut
          exact ⟨(temporal_truth_mu_at_point u g).mp
            (hg_mu (extendPoint u)
              ((extendPoint_lt_iff t_pt u).mpr (lt_trans hts hsu))
              ⟨hu_cut, fun h => h hu_cut⟩ ⟨u, rfl⟩),
            (stavi_truth_mu_at_point u D).mp (hγ_bet u (lt_trans hms hsu) hu_cut)⟩
        refine ⟨s, hms, ⟨hDs, hgs, hSnce_s, ?_, ?_⟩, hD_bet_ms⟩
        · -- U'(⊤, g∧D)(s): bound c₀
          refine ⟨c₀, hsc₀, ?_, ?_, ?_⟩
          · -- Condition (1): body
            intro u hsu huc₀
            by_cases hu_cut : u ∈ γ.val.cut
            · -- u ∈ cut: left disjunct (gD cofinal)
              left
              have ⟨y, hy_in, huy⟩ : ∃ y ∈ γ.val.cut, u < y := by
                by_contra h_all; push Not at h_all
                exact γ.val.no_sup ⟨u, ⟨fun x hx => h_all x hx, fun b hb => hb hu_cut⟩, hu_cut⟩
              exact ⟨y, huy, fun w hsw hwy =>
                h_gD_cut w hsw (γ.val.downward_closed y w hy_in (le_of_lt hwy))⟩
            · -- u ∉ cut: right disjunct (⊤ trivial + ¬gD witness)
              right
              refine ⟨fun v _ _ => by simp [TemporalTruth, Formula.top], ?_⟩
              have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
                by_contra h_all; push Not at h_all
                exact γ.val.complement_no_min ⟨u, hu_cut, fun z hz => h_all z hz⟩
              obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
              exact ⟨w, h_compl_gt w hw_not s hs_cut, lt_of_le_of_lt hwy hyu,
                fun ⟨_, hD'⟩ => hDw hD'⟩
          · -- Condition (2): ¬gD failure in (s, c₀)
            have ⟨y, hy_not, hyc₀⟩ : ∃ y, y ∉ γ.val.cut ∧ y < c₀ := by
              by_contra h_all; push Not at h_all
              exact γ.val.complement_no_min ⟨c₀, hc₀_not, fun z hz => h_all z hz⟩
            obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
            exact ⟨w, h_compl_gt w hw_not s hs_cut, lt_of_le_of_lt hwy hyc₀,
              fun ⟨_, hD'⟩ => hDw hD'⟩
          · -- Condition (3): gD initial in (s, c₀)
            have ⟨y, hy_in, hsy⟩ : ∃ y ∈ γ.val.cut, s < y := by
              by_contra h_all; push Not at h_all
              exact γ.val.no_sup ⟨s, ⟨fun x hx => h_all x hx, fun b hb => hb hs_cut⟩, hs_cut⟩
            exact ⟨y, hsy, h_compl_gt c₀ hc₀_not y hy_in, fun v hsv hvy =>
              h_gD_cut v hsv (γ.val.downward_closed y v hy_in (le_of_lt hvy))⟩
        · -- ¬U'(D, g∧D)(s): by contradiction using two-step D-transfer argument
          intro ⟨s₁, hss₁, h_body, h_fail, h_init⟩
          obtain ⟨u_fail, hsu_fail, huf_s₁, hgD_fail⟩ := h_fail
          have huf_not_cut : u_fail ∉ γ.val.cut := by
            intro h; exact hgD_fail (h_gD_cut u_fail hsu_fail h)
          -- Left disjunct fails at any complement point: ¬D below blocks gD on (s,v)
          have h_left_fails : ∀ u, s < u → u < s₁ → u ∉ γ.val.cut →
              ¬(∃ v, u < v ∧ ∀ w, s < w → w < v →
                TemporalTruth M atomMap w g ∧ StaviTemporalTruth M atomMap w D) := by
            intro u hsu _ hu_not ⟨v, huv, hgDv⟩
            have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
              by_contra h_all; push Not at h_all
              exact γ.val.complement_no_min ⟨u, hu_not, fun z hz => h_all z hz⟩
            obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
            exact hDw (hgDv w (h_compl_gt w hw_not s hs_cut)
              (lt_trans (lt_of_le_of_lt hwy hyu) huv)).2
          -- Two-step argument: D holds at ALL complement points in (s, s₁)
          have hD_all_compl : ∀ u, s < u → u < s₁ → u ∉ γ.val.cut →
              StaviTemporalTruth M atomMap u D := by
            intro u hsu hus₁ hu_not
            -- Step 1: right branch at u gives v' ∈ (s, u) complement
            have h_right_u := (h_body u hsu hus₁).resolve_left
              (h_left_fails u hsu hus₁ hu_not)
            obtain ⟨_, v', hsv', hv'u, hgD_v'⟩ := h_right_u
            have hv'_not : v' ∉ γ.val.cut := by
              intro h; exact hgD_v' (h_gD_cut v' hsv' h)
            -- Step 2: right branch at v' gives D on (v', s₁)
            have hv'_s₁ : v' < s₁ := lt_trans hv'u hus₁
            have h_right_v' := (h_body v' hsv' hv'_s₁).resolve_left
              (h_left_fails v' hsv' hv'_s₁ hv'_not)
            -- D(u) from D on (v', s₁) since v' < u < s₁
            exact h_right_v'.1 u hv'u hus₁
          -- Contradiction: initial D-segment in complement violates gap condition (2)
          have ⟨t, ht_not, ht_uf⟩ : ∃ t, t ∉ γ.val.cut ∧ t < u_fail := by
            by_contra h_all; push Not at h_all
            exact γ.val.complement_no_min ⟨u_fail, huf_not_cut, fun z hz => h_all z hz⟩
          apply h_no_init_D
          exact ⟨t, ht_not, fun u hu_not hut =>
            hD_all_compl u (h_compl_gt u hu_not s hs_cut)
              (lt_of_le_of_lt hut (lt_trans ht_uf huf_s₁)) hu_not⟩
  | neg A ih =>
    -- leftFormula (.neg A) D = .conj (.stavi_untl (.base top) D) (.neg (leftFormula A D))
    simp only [leftFormula, StaviTemporalTruthMu]
    constructor
    · -- Forward: U'(top, D)(m) ∧ ¬left(A,D)(m) → ∃ γ with ¬A^mu(γ)
      intro ⟨hU, hNot⟩
      -- Use stavi_untl_gap_detection to extract gap from U'(top, D)(m)
      -- First reconstruct the stavi_untl term from the expanded goal
      have hU' : StaviTemporalTruthMu M atomMap r (extendPoint m)
          (.stavi_untl (.base Formula.top) D) := by
        simp only [StaviTemporalTruthMu]; exact hU
      obtain ⟨γ, _s_bound, hγ_lt, _hs_not, hγ_def, hγ_bet, _⟩ :=
        (stavi_untl_gap_detection (.base Formula.top) D hD m).mp hU'
      -- From ¬left(A,D)(m), by IH we get ¬(∃ γ with A^mu(γ))
      -- But actually we get: ¬ leftFormula(A,D)(m), so by IH: not (∃ γ, ... ∧ A^mu(γ))
      have hNot' : ¬(∃ (γ' : RDefinableGap M atomMap r),
          extendPoint m < Sum.inr γ' ∧
          GapDefinableOnLeft M atomMap γ'.val D ∧
          (∀ u, m < u → u ∈ γ'.val.cut → StaviTemporalTruthMu M atomMap r (extendPoint u) D) ∧
          StaviTemporalTruthMu M atomMap r (Sum.inr γ') A) := by
        rwa [← ih m]
      -- Therefore γ has ¬A^mu(γ)
      refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
      intro hA_at_γ
      exact hNot' ⟨γ, hγ_lt, hγ_def, hγ_bet, hA_at_γ⟩
    · -- Backward: ∃ γ with ¬A^mu(γ) → U'(top, D)(m) ∧ ¬left(A,D)(m)
      intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hNot_A⟩
      constructor
      · -- U'(top, D)(m)
        -- Need s_bound ∉ cut. Get one from complement_no_min or properness.
        have h_compl : ∃ x, x ∉ γ.val.cut := by
          by_contra h; push Not at h; exact γ.val.proper (Set.eq_univ_iff_forall.mpr h)
        obtain ⟨s_b, hs_b⟩ := h_compl
        -- top holds at all complement points (trivially)
        have hTop_compl : ∀ u : M.carrier, u ∉ γ.val.cut → u < s_b →
            StaviTemporalTruth M atomMap u (.base Formula.top) := by
          intro u _ _
          simp only [StaviTemporalTruth, TemporalTruth, Formula.top]; exact id
        have := (stavi_untl_gap_detection (.base Formula.top) D hD m).mpr
          ⟨γ, s_b, hγ_lt, hs_b, hγ_def, hγ_bet, hTop_compl⟩
        simp only [StaviTemporalTruthMu] at this
        exact this
      · -- ¬left(A,D)(m)
        rw [ih m]
        intro ⟨γ', hγ'_lt, hγ'_def, hγ'_bet, hA_at_γ'⟩
        -- γ and γ' must be equal by gap_detection_unique
        have hm_in : m ∈ γ.val.cut :=
          (extendPoint_le_gap_iff m γ).mp (le_of_lt hγ_lt)
        have hm_in' : m ∈ γ'.val.cut :=
          (extendPoint_le_gap_iff m γ').mp (le_of_lt hγ'_lt)
        have hγ_bet_std : ∀ u, m < u → u ∈ γ.val.cut →
            StaviTemporalTruth M atomMap u D := by
          intro u hmu hu_in
          exact (stavi_truth_mu_at_point u D).mp (hγ_bet u hmu hu_in)
        have hγ'_bet_std : ∀ u, m < u → u ∈ γ'.val.cut →
            StaviTemporalTruth M atomMap u D := by
          intro u hmu hu_in
          exact (stavi_truth_mu_at_point u D).mp (hγ'_bet u hmu hu_in)
        have heq : γ.val = γ'.val :=
          gap_detection_unique hγ_def hγ'_def hγ_bet_std hγ'_bet_std hm_in hm_in'
        have : γ = γ' := Subtype.ext heq
        rw [this] at hNot_A
        exact hNot_A hA_at_γ'
  | conj A B ihA ihB =>
    -- leftFormula (.conj A B) D = .conj (leftFormula A D) (leftFormula B D)
    simp only [leftFormula, StaviTemporalTruthMu]
    constructor
    · -- Forward: left(A,D)(m) ∧ left(B,D)(m) → ∃ γ with (A ∧ B)^mu(γ)
      intro ⟨hA, hB⟩
      obtain ⟨γA, hγA_lt, hγA_def, hγA_bet, hγA_val⟩ := (ihA m).mp hA
      obtain ⟨γB, hγB_lt, hγB_def, hγB_bet, hγB_val⟩ := (ihB m).mp hB
      -- γA and γB must be equal by gap_detection_unique
      have hm_in_A : m ∈ γA.val.cut :=
        (extendPoint_le_gap_iff m γA).mp (le_of_lt hγA_lt)
      have hm_in_B : m ∈ γB.val.cut :=
        (extendPoint_le_gap_iff m γB).mp (le_of_lt hγB_lt)
      -- Convert D-between conditions to use StaviTemporalTruth
      have hγA_bet' : ∀ u, m < u → u ∈ γA.val.cut →
          StaviTemporalTruth M atomMap u D := by
        intro u hmu hu_in
        exact (stavi_truth_mu_at_point u D).mp (hγA_bet u hmu hu_in)
      have hγB_bet' : ∀ u, m < u → u ∈ γB.val.cut →
          StaviTemporalTruth M atomMap u D := by
        intro u hmu hu_in
        exact (stavi_truth_mu_at_point u D).mp (hγB_bet u hmu hu_in)
      have heq : γA.val = γB.val :=
        gap_detection_unique hγA_def hγB_def hγA_bet' hγB_bet' hm_in_A hm_in_B
      refine ⟨γA, hγA_lt, hγA_def, hγA_bet, ?_, ?_⟩
      · exact hγA_val
      · have : γA = γB := Subtype.ext heq
        rw [this]
        exact hγB_val
    · -- Backward: ∃ γ with (A ∧ B)^mu(γ) → left(A,D)(m) ∧ left(B,D)(m)
      intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hA_val, hB_val⟩
      exact ⟨(ihA m).mpr ⟨γ, hγ_lt, hγ_def, hγ_bet, hA_val⟩,
             (ihB m).mpr ⟨γ, hγ_lt, hγ_def, hγ_bet, hB_val⟩⟩
  | stavi_untl A B _ _ =>
    -- leftFormula (.stavi_untl A B) D = .stavi_untl (.conj B (.stavi_untl A B)) D
    -- Need: U'(B ∧ U'(A,B), D)(m) ↔ ∃ γ, ... ∧ U'(A,B)^mu(γ)
    simp only [leftFormula]
    constructor
    · -- Forward: from U'(B ∧ U'(A,B), D)(m), get gap with (B ∧ U'(A,B)) at complement points
      -- Extract U'(A,B) at complement points, then construct U'(A,B)^mu(γ)
      intro h
      obtain ⟨γ, s_bound, hγ_lt, hs_not, hγ_def, hγ_bet, hX_compl⟩ :=
        (stavi_untl_gap_detection (.conj B (.stavi_untl A B)) D hD m).mp h
      -- Extract stavi_untl(A,B) and B at complement points below s_bound
      have hUA_compl : ∀ u : M.carrier, u ∉ γ.val.cut → u < s_bound →
          StaviTemporalTruth M atomMap u (.stavi_untl A B) :=
        fun u hu hus => (hX_compl u hu hus).2
      have hB_compl : ∀ u : M.carrier, u ∉ γ.val.cut → u < s_bound →
          StaviTemporalTruth M atomMap u B :=
        fun u hu hus => (hX_compl u hu hus).1
      -- Pick complement point u₁ < s_bound
      have ⟨u₁, hu₁_not, hu₁s⟩ : ∃ u₁, u₁ ∉ γ.val.cut ∧ u₁ < s_bound := by
        by_contra h_all; push Not at h_all
        exact γ.val.complement_no_min ⟨s_bound, hs_not, fun z hz => h_all z hz⟩
      -- FO table of stavi_untl(A,B) at u₁
      have hUA_u₁ := hUA_compl u₁ hu₁_not hu₁s
      simp only [StaviTemporalTruth] at hUA_u₁
      obtain ⟨s₁, hu₁s₁, h_body₁, ⟨wf, hwf_u₁, hwf_s₁, hBwf⟩,
              ⟨wi, hwi_u₁, hwi_s₁, hBwi⟩⟩ := hUA_u₁
      -- s₁ ∉ cut (upward-closed complement: s₁ > u₁ ∉ cut)
      have hs₁_not : s₁ ∉ γ.val.cut := by
        intro h; exact hu₁_not (γ.val.downward_closed s₁ u₁ h (le_of_lt hu₁s₁))
      -- wf ∉ cut (wf > u₁)
      have hwf_not : wf ∉ γ.val.cut := by
        intro h; exact hu₁_not (γ.val.downward_closed wf u₁ h (le_of_lt hwf_u₁))
      -- wi ∉ cut (wi > u₁)
      have hwi_not : wi ∉ γ.val.cut := by
        intro h; exact hu₁_not (γ.val.downward_closed wi u₁ h (le_of_lt hwi_u₁))
      -- Construct stavi_untl(A,B)^mu(Sum.inr γ):
      refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
      -- Need: StaviTemporalTruthMu M atomMap r (Sum.inr γ) (.stavi_untl A B)
      -- Use (stavi_truth_mu_at_point u₁ (.stavi_untl A B)).mpr to convert back
      -- Actually, construct directly in the mu-relativized form
      simp only [StaviTemporalTruthMu]
      refine ⟨extendPoint s₁, ?_, ?_, ?_, ?_⟩
      · -- Sum.inr γ < extendPoint s₁: s₁ ∉ cut
        exact ⟨hs₁_not, hs₁_not⟩
      · -- Condition (1): ∀ mu-point u ∈ (γ, extendPoint s₁), FO body
        intro u hγu hus₁ hmu
        obtain ⟨u_pt, rfl⟩ := hmu
        -- u_pt ∉ cut (Sum.inr γ < extendPoint u_pt means u_pt ∉ cut)
        have hu_pt_not : u_pt ∉ γ.val.cut := by
          intro h; exact not_lt.mpr (show extendPoint u_pt ≤ Sum.inr γ from h) hγu
        -- u_pt < s₁ (extendPoint u_pt < extendPoint s₁)
        have hu_pt_s₁ : u_pt < s₁ := (extendPoint_lt_iff u_pt s₁).mp hus₁
        -- Case split: u_pt > u₁ (use inner FO table) or u_pt ≤ u₁ (B-cofinal)
        by_cases hu_pt_u₁ : u₁ < u_pt
        · -- u_pt > u₁: use h_body₁ at u_pt
          cases h_body₁ u_pt hu_pt_u₁ hu_pt_s₁ with
          | inl h_cof =>
            -- LEFT: ∃ v > u_pt, B on (u₁, v). Extend to B on (γ, v) using hB_compl.
            left
            obtain ⟨v, hu_pt_v, hBv⟩ := h_cof
            refine ⟨extendPoint v, (extendPoint_lt_iff u_pt v).mpr hu_pt_v, ⟨v, rfl⟩,
              fun w hγw hwv hmu_w => ?_⟩
            obtain ⟨w_pt, rfl⟩ := hmu_w
            have hw_pt_v : w_pt < v := (extendPoint_lt_iff w_pt v).mp hwv
            have hw_pt_not : w_pt ∉ γ.val.cut := by
              intro h; exact not_lt.mpr (show extendPoint w_pt ≤ Sum.inr γ from h) hγw
            -- w_pt is a complement point. If w_pt > u₁, use hBv. If w_pt ≤ u₁, use hB_compl.
            by_cases hwu₁ : u₁ < w_pt
            · exact (stavi_truth_mu_at_point w_pt B).mpr (hBv w_pt hwu₁ hw_pt_v)
            · push Not at hwu₁
              -- w_pt ≤ u₁. w_pt ∉ cut and w_pt < s_bound (w_pt < v < s₁, s₁ > u₁, u₁ < s_bound)
              -- Need w_pt < s_bound. w_pt ≤ u₁ < s_bound.
              have hw_sb : w_pt < s_bound := lt_of_le_of_lt hwu₁ hu₁s
              exact (stavi_truth_mu_at_point w_pt B).mpr (hB_compl w_pt hw_pt_not hw_sb)
          | inr h_right =>
            -- RIGHT: A on (u_pt, s₁) and ¬B witness v' ∈ (u₁, u_pt)
            right
            obtain ⟨hA_above, v', hmv', hv'u, hBv'⟩ := h_right
            refine ⟨fun v hv hvs hmu_v => ?_, ?_⟩
            · -- A^mu(v) for v mu-point in (u_pt, s₁)
              obtain ⟨v_pt, rfl⟩ := hmu_v
              exact (stavi_truth_mu_at_point v_pt A).mpr
                (hA_above v_pt ((extendPoint_lt_iff u_pt v_pt).mp hv)
                  ((extendPoint_lt_iff v_pt s₁).mp hvs))
            · -- ∃ v' mu-point ∈ (γ, u_pt) with ¬B^mu(v')
              refine ⟨extendPoint v', ?_, (extendPoint_lt_iff v' u_pt).mpr hv'u,
                ⟨v', rfl⟩, ?_⟩
              · -- Sum.inr γ < extendPoint v': v' > u₁ > γ (v' ∈ (u₁, u_pt))
                change v' ∉ γ.val.cut ∧ ¬(v' ∈ γ.val.cut)
                have hv'_not : v' ∉ γ.val.cut := by
                  intro h; exact hu₁_not (γ.val.downward_closed v' u₁ h (le_of_lt hmv'))
                exact ⟨hv'_not, hv'_not⟩
              · exact mt (stavi_truth_mu_at_point v' B).mp hBv'
        · -- u_pt ≤ u₁: B holds at u_pt (from hB_compl) and at all complement points below wi
          -- Use LEFT disjunct: B cofinal
          push Not at hu_pt_u₁
          left
          -- Need ∃ v_mu > u_pt with B^mu on (γ, v_mu)
          -- Use v_mu = extendPoint wi (wi from inner FO table: B on (u₁, wi))
          refine ⟨extendPoint wi, (extendPoint_lt_iff u_pt wi).mpr (lt_of_le_of_lt hu_pt_u₁ hwi_u₁),
            ⟨wi, rfl⟩, fun w hγw hwwi hmu_w => ?_⟩
          obtain ⟨w_pt, rfl⟩ := hmu_w
          have hw_pt_not : w_pt ∉ γ.val.cut := by
            intro h; exact not_lt.mpr (show extendPoint w_pt ≤ Sum.inr γ from h) hγw
          have hw_pt_wi : w_pt < wi := (extendPoint_lt_iff w_pt wi).mp hwwi
          by_cases hwu₁ : u₁ < w_pt
          · -- w_pt > u₁: B at w_pt from hBwi (B on (u₁, wi))
            exact (stavi_truth_mu_at_point w_pt B).mpr (hBwi w_pt hwu₁ hw_pt_wi)
          · -- w_pt ≤ u₁: B at w_pt from hB_compl
            push Not at hwu₁
            exact (stavi_truth_mu_at_point w_pt B).mpr
              (hB_compl w_pt hw_pt_not (lt_of_le_of_lt hwu₁ hu₁s))
      · -- Condition (2): ∃ mu-point in (γ, s') with ¬B^mu
        refine ⟨extendPoint wf, ?_, (extendPoint_lt_iff wf s₁).mpr hwf_s₁,
          ⟨wf, rfl⟩, mt (stavi_truth_mu_at_point wf B).mp hBwf⟩
        change wf ∉ γ.val.cut ∧ ¬(wf ∈ γ.val.cut)
        exact ⟨hwf_not, hwf_not⟩
      · -- Condition (3): ∃ mu-point in (γ, s') with B^mu initial
        -- Use u₁ as the initial segment witness: B holds at all complement points in (γ, u₁)
        -- because complement points below u₁ are below s_bound, so hB_compl applies.
        -- But we need the initial mu-point between γ and s₁ where B holds from γ to that point.
        -- Wait: we need ∃ u_init ∈ (γ, s'), B^mu on (γ, u_init). The interval (γ, u_init)
        -- should contain only complement points where B holds.
        -- Pick u₁ itself if B at all complement points below u₁.
        -- Actually, from hBwi: B on (u₁, wi). Combined with hB_compl for complement points
        -- below u₁, we can use wi as the initial segment bound: B on complement points in (γ, wi).
        -- But we need u_init to satisfy: u_init ∈ (γ, s') and B^mu on (γ, u_init).
        -- complement_no_min gives us complement points below u₁ where B holds.
        -- Use wi as u_init: B holds on all complement points in (γ, wi).
        refine ⟨extendPoint wi, ?_, (extendPoint_lt_iff wi s₁).mpr hwi_s₁,
          ⟨wi, rfl⟩, fun v hγv hvwi hmu_v => ?_⟩
        · change wi ∉ γ.val.cut ∧ ¬(wi ∈ γ.val.cut)
          exact ⟨hwi_not, hwi_not⟩
        · obtain ⟨v_pt, rfl⟩ := hmu_v
          have hv_pt_not : v_pt ∉ γ.val.cut := by
            intro h; exact not_lt.mpr (show extendPoint v_pt ≤ Sum.inr γ from h) hγv
          have hv_pt_wi : v_pt < wi := (extendPoint_lt_iff v_pt wi).mp hvwi
          by_cases hvu₁ : u₁ < v_pt
          · exact (stavi_truth_mu_at_point v_pt B).mpr (hBwi v_pt hvu₁ hv_pt_wi)
          · push Not at hvu₁
            exact (stavi_truth_mu_at_point v_pt B).mpr
              (hB_compl v_pt hv_pt_not (lt_of_le_of_lt hvu₁ hu₁s))
    · -- Backward: from gap with U'(A,B)^mu(γ), construct U'(B ∧ U'(A,B), D)(m)
      intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hUA⟩
      -- From U'(A,B)^mu(γ), extract complement-point truth of B ∧ U'(A,B)
      -- U'(A,B)^mu(γ) gives FO table at the gap with witnesses among complement points
      simp only [StaviTemporalTruthMu] at hUA
      obtain ⟨s_ua, hγ_s_ua, h_body_ua, ⟨wf_ua, hγ_wf, hwf_s, hmu_wf, hBwf_ua⟩,
              ⟨wi_ua, hγ_wi, hwi_s, hmu_wi, hBwi_ua⟩⟩ := hUA
      -- Extract s_ua bound. All mu-points above γ are complement points.
      -- From the FO table, B and stavi_untl(A,B) hold at specific complement points.
      -- We need to provide (conj B (stavi_untl A B)) at complement points for .mpr
      -- Get a complement point as s_bound for .mpr
      obtain ⟨wf_pt, rfl⟩ := hmu_wf
      obtain ⟨wi_pt, rfl⟩ := hmu_wi
      have hwf_not : wf_pt ∉ γ.val.cut := by
        intro h; exact not_lt.mpr (show extendPoint wf_pt ≤ Sum.inr γ from h) hγ_wf
      have hwi_not : wi_pt ∉ γ.val.cut := by
        intro h; exact not_lt.mpr (show extendPoint wi_pt ≤ Sum.inr γ from h) hγ_wi
      -- Strategy: use stavi_untl_gap_detection.mpr.
      -- Pick s_bound as a complement point below BOTH wf_pt and wi_pt.
      -- This ensures:
      --   (a) B holds at complement points u < s_bound (from hBwi_ua, since u < wi_pt)
      --   (b) U'(A,B)(u) can be constructed with wf_pt as ¬B witness and wi_pt as B-initial,
      --       both in the interval (u, s_pt) where s_pt is a carrier bound above wf_pt and wi_pt.
      -- First, get a carrier bound s_pt from s_ua above both witnesses.
      have ⟨s_pt, hs_pt_wf, hs_pt_wi, hs_pt_s_ua⟩ :
          ∃ s_pt : M.carrier, wf_pt < s_pt ∧ wi_pt < s_pt ∧ extendPoint s_pt ≤ s_ua := by
        rcases s_ua with s₁ | g_ua
        · refine ⟨s₁, (extendPoint_lt_iff wf_pt s₁).mp hwf_s,
            (extendPoint_lt_iff wi_pt s₁).mp hwi_s, le_rfl⟩
        · have hwf_cut : wf_pt ∈ g_ua.val.cut :=
            (extendPoint_le_gap_iff wf_pt g_ua).mp (le_of_lt hwf_s)
          have hwi_cut : wi_pt ∈ g_ua.val.cut :=
            (extendPoint_le_gap_iff wi_pt g_ua).mp (le_of_lt hwi_s)
          have hmax_cut : max wf_pt wi_pt ∈ g_ua.val.cut := by
            rcases le_or_gt wf_pt wi_pt with h | h
            · simp only [max_eq_right h]; exact hwi_cut
            · simp only [max_eq_left (le_of_lt h)]; exact hwf_cut
          have ⟨y, hy_cut, hmax_y⟩ : ∃ y, y ∈ g_ua.val.cut ∧ max wf_pt wi_pt < y := by
            by_contra h_all; push Not at h_all
            exact g_ua.val.no_sup ⟨max wf_pt wi_pt,
              ⟨h_all, fun b hb => hb hmax_cut⟩, hmax_cut⟩
          exact ⟨y, lt_of_le_of_lt (le_max_left _ _) hmax_y,
            lt_of_le_of_lt (le_max_right _ _) hmax_y,
            le_of_lt (lt_of_le_of_ne
              ((extendPoint_le_gap_iff y g_ua).mpr hy_cut) (fun h => by cases h))⟩
      -- Pick s_bound = min(wf_pt, wi_pt). Both ∉ γ.cut.
      let s_bound := min wf_pt wi_pt
      have hs_bound_not : s_bound ∉ γ.val.cut := by
        simp only [s_bound, min_def]; split
        · exact hwf_not
        · exact hwi_not
      -- Apply stavi_untl_gap_detection.mpr
      apply (stavi_untl_gap_detection (.conj B (.stavi_untl A B)) D hD m).mpr
      refine ⟨γ, s_bound, hγ_lt, hs_bound_not, hγ_def, hγ_bet, fun u hu_not hu_sb => ?_⟩
      -- u is a complement point with u < s_bound = min(wf_pt, wi_pt)
      -- So u < wf_pt AND u < wi_pt
      have hu_wf : u < wf_pt := lt_of_lt_of_le hu_sb (min_le_left wf_pt wi_pt)
      have hu_wi : u < wi_pt := lt_of_lt_of_le hu_sb (min_le_right wf_pt wi_pt)
      have hγu : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
          (Sum.inr γ) (extendPoint u) := by
        change u ∉ γ.val.cut ∧ ¬(u ∈ γ.val.cut); exact ⟨hu_not, hu_not⟩
      simp only [StaviTemporalTruth]
      constructor
      · -- B(u): from hBwi_ua, u is between γ and wi_pt
        exact (stavi_truth_mu_at_point u B).mp
          (hBwi_ua (extendPoint u) hγu ((extendPoint_lt_iff u wi_pt).mpr hu_wi) ⟨u, rfl⟩)
      · -- U'(A,B)(u): FO table at u with bound s_pt
        refine ⟨s_pt, lt_trans hu_wf hs_pt_wf, ?_, ?_, ?_⟩
        · -- Body: ∀ w ∈ (u, s_pt), disjunction
          intro w huw hws
          have hw_not : w ∉ γ.val.cut := by
            intro h; exact hu_not (γ.val.downward_closed w u h (le_of_lt huw))
          have hγw : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (Sum.inr γ) (extendPoint w) := by
            change w ∉ γ.val.cut ∧ ¬(w ∈ γ.val.cut); exact ⟨hw_not, hw_not⟩
          have hw_s_ua : extendPoint w < s_ua :=
            lt_of_lt_of_le ((extendPoint_lt_iff w s_pt).mpr hws) hs_pt_s_ua
          -- Apply mu-body at w
          have h_disj := h_body_ua (extendPoint w) hγw hw_s_ua ⟨w, rfl⟩
          cases h_disj with
          | inl h_cof =>
            -- Left: ∃ v mu-point > w, B^mu on (γ, v). Restrict to (u, v).
            left
            obtain ⟨v, hwv, hmu_v, hBv⟩ := h_cof
            obtain ⟨v_pt, rfl⟩ := hmu_v
            refine ⟨v_pt, (extendPoint_lt_iff w v_pt).mp hwv, fun z huz hzv => ?_⟩
            have hz_not : z ∉ γ.val.cut := by
              intro h; exact hu_not (γ.val.downward_closed z u h (le_of_lt huz))
            have hγz : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
                (Sum.inr γ) (extendPoint z) := by
              change z ∉ γ.val.cut ∧ ¬(z ∈ γ.val.cut); exact ⟨hz_not, hz_not⟩
            exact (stavi_truth_mu_at_point z B).mp
              (hBv (extendPoint z) hγz ((extendPoint_lt_iff z v_pt).mpr hzv) ⟨z, rfl⟩)
          | inr h_take =>
            -- Right: A^mu on (w, s_ua), ¬B^mu at v' ∈ (γ, w)
            obtain ⟨hA_above, v', hγv', hv'w, hmu_v', hBv'_neg⟩ := h_take
            obtain ⟨v'_pt, rfl⟩ := hmu_v'
            -- v'_pt is in (γ, w). Since u < wf_pt ≤ min(wf_pt, wi_pt) and u < wi_pt,
            -- if v'_pt ≤ u then v'_pt < wi_pt, so B(v'_pt) from hBwi_ua.
            -- But ¬B(v'_pt) contradicts. So v'_pt > u.
            have hv'u : u < v'_pt := by
              by_contra h_neg; push Not at h_neg
              have hv'_wi : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
                  (extendPoint v'_pt) (extendPoint wi_pt) :=
                (extendPoint_lt_iff v'_pt wi_pt).mpr (lt_of_le_of_lt h_neg hu_wi)
              exact hBv'_neg ((stavi_truth_mu_at_point v'_pt B).mpr
                ((stavi_truth_mu_at_point v'_pt B).mp
                  (hBwi_ua (extendPoint v'_pt) hγv' hv'_wi ⟨v'_pt, rfl⟩)))
            right
            refine ⟨fun v hwv hvs => ?_,
              v'_pt, hv'u, (extendPoint_lt_iff v'_pt w).mp hv'w,
              fun h => hBv'_neg ((stavi_truth_mu_at_point v'_pt B).mpr h)⟩
            have hv_not : v ∉ γ.val.cut := by
              intro h; exact hw_not (γ.val.downward_closed v w h (le_of_lt hwv))
            exact (stavi_truth_mu_at_point v A).mp
              (hA_above (extendPoint v) ((extendPoint_lt_iff w v).mpr hwv)
                (lt_of_lt_of_le ((extendPoint_lt_iff v s_pt).mpr hvs) hs_pt_s_ua)
                ⟨v, rfl⟩)
        · -- ¬B witness: wf_pt is in (u, s_pt) and ¬B(wf_pt)
          exact ⟨wf_pt, hu_wf, hs_pt_wf,
            fun h => hBwf_ua ((stavi_truth_mu_at_point wf_pt B).mpr h)⟩
        · -- B initial: wi_pt is in (u, s_pt) and B on (u, wi_pt)
          refine ⟨wi_pt, hu_wi, hs_pt_wi, fun v huv hvwi => ?_⟩
          have hv_not : v ∉ γ.val.cut := by
            intro h; exact hu_not (γ.val.downward_closed v u h (le_of_lt huv))
          have hγv : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (Sum.inr γ) (extendPoint v) := by
            change v ∉ γ.val.cut ∧ ¬(v ∈ γ.val.cut); exact ⟨hv_not, hv_not⟩
          exact (stavi_truth_mu_at_point v B).mp
            (hBwi_ua (extendPoint v) hγv ((extendPoint_lt_iff v wi_pt).mpr hvwi) ⟨v, rfl⟩)
  | stavi_snce A B _ _ =>
    -- leftFormula (.stavi_snce A B) D = .std_untl compound D
    -- compound = D ∧ B ∧ S'(A,B) ∧ U'(⊤, B∧D) ∧ ¬U'(D, B∧D)
    -- Same compound decomposition as std_snce; S'(A,B) FO table differs from S(A,B)
    simp only [leftFormula]
    rw [stavi_truth_mu_at_point m (.std_untl _ D)]
    simp only [StaviTemporalTruth]
    constructor
    · -- Forward: compound at s → gap with S'(A,B)^mu(γ)
      intro ⟨s, hms, ⟨hDs, hBs, hSnce_s, hU'_BD_s, hNotU'D_BD_s⟩, hD_bet⟩
      obtain ⟨s₁, hss₁, h_body, h_fail, h_init⟩ := hU'_BD_s
      obtain ⟨u_fail, hsu_fail, hu_fail_s₁, hBD_fail⟩ := h_fail
      obtain ⟨u_init, hsu_init, hu_init_s₁, hBD_init⟩ := h_init
      -- Gap construction (identical to std_snce: uses U'(⊤,B∧D) + ¬U'(D,B∧D))
      let bD : M.carrier → Prop := fun u =>
        StaviTemporalTruth M atomMap u B ∧ StaviTemporalTruth M atomMap u D
      let cut : Set M.carrier :=
        {x | ∀ u, s < u → u ≤ x → ∃ v, u < v ∧ ∀ w, s < w → w < v → bD w}
      have hs_in_cut : s ∈ cut :=
        fun u hsu hus => absurd (lt_of_lt_of_le hsu hus) (lt_irrefl s)
      have hu_fail_not_cut : u_fail ∉ cut := by
        intro h; obtain ⟨v, hfv, hBDv⟩ := h u_fail hsu_fail le_rfl
        exact hBD_fail (hBDv u_fail hsu_fail hfv)
      have h_cut_lt_uf : ∀ x ∈ cut, x < u_fail := by
        intro x hx; by_contra h; push Not at h
        exact hu_fail_not_cut (fun u hsu huf => hx u hsu (le_trans huf h))
      have h_dc : ∀ x y, x ∈ cut → y ≤ x → y ∈ cut :=
        fun x y hx hyx u hsu huy => hx u hsu (le_trans huy hyx)
      have h_proper : cut ≠ Set.univ := by
        intro h; exact hu_fail_not_cut (h ▸ Set.mem_univ u_fail)
      have h_cofinal_propagate :
          ∀ u, s < u → u < s₁ →
          (∀ w, s < w → w < u → ∃ v, w < v ∧ ∀ z, s < z → z < v → bD z) →
          ∃ v, u < v ∧ ∀ z, s < z → z < v → bD z := by
        intro u hsu hus₁ h_below
        cases h_body u hsu hus₁ with
        | inl h => exact h
        | inr h =>
          obtain ⟨_, v', hsv', hv'u, hBDv'⟩ := h
          obtain ⟨v₂, hv'v₂, hBDv₂⟩ := h_below v' hsv' hv'u
          exact absurd (hBDv₂ v' hsv' hv'v₂) hBDv'
      have hu_init_cut : u_init ∈ cut := by
        intro u hsu huu_init
        exact h_cofinal_propagate u hsu (lt_of_le_of_lt huu_init hu_init_s₁)
          (fun w hsw hwu => ⟨u_init, lt_of_lt_of_le hwu huu_init,
            fun z hsz hz_init => hBD_init z hsz hz_init⟩)
      have h_bD_at_cut : ∀ u, s < u → u ∈ cut → bD u := by
        intro u hsu hu_cut
        obtain ⟨v, huv, hBDv⟩ := hu_cut u hsu le_rfl
        exact hBDv u hsu huv
      have h_no_sup : ¬∃ p, IsLUB cut p ∧ p ∈ cut := by
        intro ⟨p, ⟨h_ub, _⟩, hp_cut⟩
        have hsp : s < p := lt_of_lt_of_le hsu_init (h_ub hu_init_cut)
        obtain ⟨v, hpv, hBDv⟩ := hp_cut p hsp le_rfl
        have hvs₁ : v < s₁ := by
          by_contra h; push Not at h
          exact hBD_fail (hBDv u_fail hsu_fail (lt_of_lt_of_le hu_fail_s₁ h))
        exact not_le.mpr hpv (h_ub (show v ∈ cut from fun u hsu huv => by
          rcases eq_or_lt_of_le huv with rfl | huv'
          · exact h_cofinal_propagate u (lt_trans hsp hpv) hvs₁
              (fun w hsw hwu => ⟨u, hwu, hBDv⟩)
          · exact ⟨v, huv', hBDv⟩))
      have h_comp_no_min : ¬∃ b, b ∉ cut ∧ ∀ y, y ∉ cut → b ≤ y := by
        intro ⟨b, hb_not, hb_min⟩
        have hsb : s < b := by
          by_contra h; push Not at h; exact hb_not (h_dc s b hs_in_cut h)
        have hbs₁ : b < s₁ := lt_of_le_of_lt (hb_min u_fail hu_fail_not_cut) hu_fail_s₁
        have h_below_b : ∀ y, y < b → y ∈ cut := by
          intro y hyb; by_contra hy_not; exact not_lt.mpr (hb_min y hy_not) hyb
        cases h_body b hsb hbs₁ with
        | inl h_cof =>
          exact hb_not (fun u hsu hub => by
            rcases eq_or_lt_of_le hub with rfl | hub'
            · exact h_cof
            · exact (h_below_b u hub') u hsu le_rfl)
        | inr h =>
          obtain ⟨_, v', hsv', hv'b, hBDv'⟩ := h
          obtain ⟨v₂, hv'v₂, hBDv₂⟩ := (h_below_b v' hv'b) v' hsv' le_rfl
          exact hBDv' (hBDv₂ v' hsv' hv'v₂)
      let γ_gap : Gap M.carrier :=
        ⟨cut, ⟨s, hs_in_cut⟩, h_proper, h_dc, h_no_sup, h_comp_no_min⟩
      have h_D_cofinal_cut : ∃ t, t ∈ γ_gap.cut ∧
          ∀ u, t ≤ u → u ∈ γ_gap.cut → StaviTemporalTruth M atomMap u D :=
        ⟨u_init, hu_init_cut, fun u hu_le hu_cut =>
          (h_bD_at_cut u (lt_of_lt_of_le hsu_init hu_le) hu_cut).2⟩
      have h_no_init_compl_bD : ¬∃ t, t ∉ γ_gap.cut ∧
          ∀ u, u ∉ γ_gap.cut → u ≤ t → bD u := by
        intro ⟨t, ht_not, hBDt⟩
        have hst : s < t := by
          by_contra h; push Not at h; exact ht_not (h_dc s t hs_in_cut h)
        have hts₁ : t < s₁ := by
          by_contra h; push Not at h
          exact hBD_fail (hBDt u_fail hu_fail_not_cut (le_trans (le_of_lt hu_fail_s₁) h))
        suffices t ∈ cut from ht_not this
        intro u hsu hut
        exact h_cofinal_propagate u hsu (lt_of_le_of_lt hut hts₁)
          (fun w hsw hwu =>
            h_cofinal_propagate w hsw (lt_trans hwu (lt_of_le_of_lt hut hts₁))
              (fun z hsz hzw => by
                cases h_body z hsz (lt_trans hzw (lt_trans hwu
                    (lt_of_le_of_lt hut hts₁))) with
                | inl h => exact h
                | inr h =>
                  obtain ⟨_, v', hsv', hv'z, hBDv'⟩ := h
                  have : bD v' := by
                    by_cases hv'_cut : v' ∈ cut
                    · exact h_bD_at_cut v' hsv' hv'_cut
                    · exact hBDt v' hv'_cut (le_trans (le_of_lt hv'z)
                        (le_trans (le_of_lt hzw) (le_trans (le_of_lt hwu) hut)))
                  exact absurd this hBDv'))
      have hD_fails : ∃ u_D, s < u_D ∧ u_D < s₁ ∧
          ¬StaviTemporalTruth M atomMap u_D D := by
        by_contra h_all_D; push Not at h_all_D
        apply hNotU'D_BD_s
        exact ⟨s₁, hss₁,
          fun u hsu hus₁ => by
            cases h_body u hsu hus₁ with
            | inl h => left; exact h
            | inr h => right; exact ⟨fun v huv hvs₁ => h_all_D v (lt_trans hsu huv) hvs₁, h.2⟩,
          ⟨u_fail, hsu_fail, hu_fail_s₁, hBD_fail⟩,
          ⟨u_init, hsu_init, hu_init_s₁, hBD_init⟩⟩
      obtain ⟨u_D, hsu_D, hu_D_s₁, hD_fail_D⟩ := hD_fails
      have hu_D_not_cut : u_D ∉ cut := by
        intro h; exact hD_fail_D (h_bD_at_cut u_D hsu_D h).2
      have h_compl_gt_cut : ∀ x, x ∉ cut → ∀ y, y ∈ cut → y < x := by
        intro x hx y hy; by_contra h; push Not at h; exact hx (h_dc y x hy h)
      have h_no_init_compl_D : ¬∃ t, t ∉ γ_gap.cut ∧
          ∀ u, u ∉ γ_gap.cut → u ≤ t → StaviTemporalTruth M atomMap u D := by
        intro ⟨t, ht_not, hDt⟩
        have hst : s < t := h_compl_gt_cut t ht_not s hs_in_cut
        have ht_uD : t < u_D := by
          by_contra h; push Not at h; exact hD_fail_D (hDt u_D hu_D_not_cut h)
        have hts₁ : t < s₁ := lt_trans ht_uD hu_D_s₁
        apply hNotU'D_BD_s
        refine ⟨t, hst, ?_, ?_, ?_⟩
        · intro u hsu hut
          cases h_body u hsu (lt_trans hut hts₁) with
          | inl h => left; exact h
          | inr h => right
                     exact ⟨fun v huv hvt => by
                       by_cases hv_cut : v ∈ cut
                       · exact (h_bD_at_cut v (lt_trans hsu huv) hv_cut).2
                       · exact hDt v hv_cut (le_of_lt hvt), h.2⟩
        · by_contra h_no_fail; push Not at h_no_fail
          apply h_no_init_compl_bD
          obtain ⟨c, hc_not, hct⟩ : ∃ c, c ∉ cut ∧ c < t := by
            by_contra h; push Not at h
            exact h_comp_no_min ⟨t, ht_not, fun y hy => h y hy⟩
          exact ⟨c, hc_not, fun u hu huc =>
            h_no_fail u (h_compl_gt_cut u hu s hs_in_cut) (lt_of_le_of_lt huc hct)⟩
        · exact ⟨u_init, hsu_init, h_compl_gt_cut t ht_not u_init hu_init_cut, hBD_init⟩
      have h_def_left_D : GapDefinableOnLeft M atomMap γ_gap D :=
        ⟨h_D_cofinal_cut, h_no_init_compl_D⟩
      let γ : RDefinableGap M atomMap r := ⟨γ_gap, ⟨D, hD, Or.inl h_def_left_D⟩⟩
      refine ⟨γ, ?_, ?_, ?_, ?_⟩
      · have hm_in : m ∈ cut := h_dc s m hs_in_cut (le_of_lt hms)
        exact ⟨hm_in, fun h => h hm_in⟩
      · exact h_def_left_D
      · intro u hmu hu_cut
        by_cases hsu : s < u
        · exact (stavi_truth_mu_at_point u D).mpr (h_bD_at_cut u hsu hu_cut).2
        · push Not at hsu
          rcases eq_or_lt_of_le hsu with rfl | hus
          · exact (stavi_truth_mu_at_point u D).mpr hDs
          · exact (stavi_truth_mu_at_point u D).mpr (hD_bet u hmu hus)
      · -- S'(A,B)^mu(γ): from S'(A,B)(s) with B∧D at cut points above s
        obtain ⟨s₂, hs₂s, h_body_snce, ⟨uf_snce, hs₂_uf, huf_s, hBuf⟩,
                ⟨ui_snce, hs₂_ui, hui_s, hBui⟩⟩ := hSnce_s
        have hs₂_cut : s₂ ∈ cut := h_dc s s₂ hs_in_cut (le_of_lt hs₂s)
        have huf_cut : uf_snce ∈ cut := h_dc s uf_snce hs_in_cut (le_of_lt huf_s)
        have hui_cut : ui_snce ∈ cut := h_dc s ui_snce hs_in_cut (le_of_lt hui_s)
        simp only [StaviTemporalTruthMu]
        refine ⟨extendPoint s₂, ⟨hs₂_cut, fun h => h hs₂_cut⟩, ?_, ?_, ?_⟩
        · -- Body: ∀ mu-point u ∈ (s₂, γ), body^mu(u)
          intro u hs₂u huγ hmu
          obtain ⟨u_pt, rfl⟩ := hmu
          have hu_cut : u_pt ∈ γ.val.cut :=
            (extendPoint_le_gap_iff u_pt γ).mp (le_of_lt huγ)
          have hs₂_upt : s₂ < u_pt := (extendPoint_lt_iff s₂ u_pt).mp hs₂u
          by_cases hups : u_pt < s
          · -- u_pt < s: use original body from S'(A,B)(s)
            cases h_body_snce u_pt hs₂_upt hups with
            | inl h_cof =>
              left
              obtain ⟨v, hvu, hBv⟩ := h_cof
              have hv_cut : v ∈ cut := h_dc s v hs_in_cut (le_of_lt (lt_trans hvu hups))
              refine ⟨extendPoint v, (extendPoint_lt_iff v u_pt).mpr hvu,
                ⟨v, rfl⟩, fun w hvw hwγ hmu_w => ?_⟩
              obtain ⟨w_pt, rfl⟩ := hmu_w
              have hw_cut : w_pt ∈ γ.val.cut :=
                (extendPoint_le_gap_iff w_pt γ).mp (le_of_lt hwγ)
              have hvw_pt : v < w_pt := (extendPoint_lt_iff v w_pt).mp hvw
              by_cases hwps : w_pt < s
              · exact (stavi_truth_mu_at_point w_pt B).mpr (hBv w_pt hvw_pt hwps)
              · push Not at hwps
                rcases eq_or_lt_of_le hwps with rfl | hwps'
                · exact (stavi_truth_mu_at_point s B).mpr hBs
                · exact (stavi_truth_mu_at_point _ B).mpr (h_bD_at_cut _ hwps' hw_cut).1
            | inr h_right =>
              right
              obtain ⟨hA_above, v', hu_v', hv'_s, hBv'⟩ := h_right
              have hv'_cut : v' ∈ cut := h_dc s v' hs_in_cut (le_of_lt hv'_s)
              refine ⟨fun v hs₂v hvu hmu_v => ?_, ?_⟩
              · obtain ⟨v_pt, rfl⟩ := hmu_v
                exact (stavi_truth_mu_at_point v_pt A).mpr
                  (hA_above v_pt ((extendPoint_lt_iff s₂ v_pt).mp hs₂v)
                    ((extendPoint_lt_iff v_pt u_pt).mp hvu))
              · exact ⟨extendPoint v', (extendPoint_lt_iff u_pt v').mpr hu_v',
                  ⟨hv'_cut, fun h => h hv'_cut⟩, ⟨v', rfl⟩,
                  mt (stavi_truth_mu_at_point v' B).mp hBv'⟩
          · -- u_pt ≥ s: cut point above s, B cofinal from B∧D
            push Not at hups
            left
            -- Use ui_snce (B-init witness) extended: B at all cut points above ui_snce
            -- since B on (ui_snce, s) from hBui + B at cut above s from h_bD_at_cut
            refine ⟨extendPoint ui_snce, (extendPoint_lt_iff ui_snce u_pt).mpr
              (lt_of_lt_of_le hui_s hups),
              ⟨ui_snce, rfl⟩, fun w huiw hwγ hmu_w => ?_⟩
            obtain ⟨w_pt, rfl⟩ := hmu_w
            have hw_cut : w_pt ∈ γ.val.cut :=
              (extendPoint_le_gap_iff w_pt γ).mp (le_of_lt hwγ)
            have hui_wpt : ui_snce < w_pt := (extendPoint_lt_iff ui_snce w_pt).mp huiw
            by_cases hwps : w_pt < s
            · exact (stavi_truth_mu_at_point w_pt B).mpr (hBui w_pt hui_wpt hwps)
            · push Not at hwps
              rcases eq_or_lt_of_le hwps with rfl | hsw'
              · exact (stavi_truth_mu_at_point s B).mpr hBs
              · exact (stavi_truth_mu_at_point w_pt B).mpr (h_bD_at_cut w_pt hsw' hw_cut).1
        · -- Fail: ∃ mu-point in (s₂, γ) with ¬B^mu
          exact ⟨extendPoint uf_snce, (extendPoint_lt_iff s₂ uf_snce).mpr hs₂_uf,
            ⟨huf_cut, fun h => h huf_cut⟩, ⟨uf_snce, rfl⟩,
            mt (stavi_truth_mu_at_point uf_snce B).mp hBuf⟩
        · -- Init: ∃ mu-point in (s₂, γ) with B^mu on (init, γ)
          refine ⟨extendPoint ui_snce, (extendPoint_lt_iff s₂ ui_snce).mpr hs₂_ui,
            ⟨hui_cut, fun h => h hui_cut⟩, ⟨ui_snce, rfl⟩,
            fun v huiv hvγ hmu_v => ?_⟩
          obtain ⟨v_pt, rfl⟩ := hmu_v
          have hv_cut : v_pt ∈ γ.val.cut :=
            (extendPoint_le_gap_iff v_pt γ).mp (le_of_lt hvγ)
          have hui_vpt : ui_snce < v_pt := (extendPoint_lt_iff ui_snce v_pt).mp huiv
          by_cases hvps : v_pt < s
          · exact (stavi_truth_mu_at_point v_pt B).mpr (hBui v_pt hui_vpt hvps)
          · push Not at hvps
            rcases eq_or_lt_of_le hvps with rfl | hvs
            · exact (stavi_truth_mu_at_point s B).mpr hBs
            · exact (stavi_truth_mu_at_point _ B).mpr (h_bD_at_cut _ hvs hv_cut).1
    · -- Backward: gap with S'(A,B)^mu(γ) → compound at m
      -- Same compound structure as std_snce backward but S'(A,B) FO table
      intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hSnce_mu⟩
      -- Expand S'(A,B)^mu(γ): FO table with bound, body, fail, init for B
      simp only [StaviTemporalTruthMu] at hSnce_mu
      obtain ⟨s_bound_ext, hs_bound_γ, h_body_AB, ⟨uf_ext, hs_uf, huf_γ, hmu_uf, hBuf⟩,
              ⟨ui_ext, hs_ui, hui_γ, hmu_ui, hBui⟩⟩ := hSnce_mu
      obtain ⟨uf_pt, rfl⟩ := hmu_uf
      obtain ⟨ui_pt, rfl⟩ := hmu_ui
      have huf_cut : uf_pt ∈ γ.val.cut :=
        (extendPoint_le_gap_iff uf_pt γ).mp (le_of_lt huf_γ)
      have hui_cut : ui_pt ∈ γ.val.cut :=
        (extendPoint_le_gap_iff ui_pt γ).mp (le_of_lt hui_γ)
      have hm_cut : m ∈ γ.val.cut :=
        (extendPoint_le_gap_iff m γ).mp (le_of_lt hγ_lt)
      -- Find cut point s above m, uf_pt, ui_pt
      have ⟨s, hs_cut, hms, hufs, huis⟩ :
          ∃ s, s ∈ γ.val.cut ∧ m < s ∧ uf_pt < s ∧ ui_pt < s := by
        have hmax3_cut : max m (max uf_pt ui_pt) ∈ γ.val.cut := by
          rcases le_or_gt m (max uf_pt ui_pt) with h | h
          · simp only [max_eq_right h]
            rcases le_or_gt uf_pt ui_pt with h' | h'
            · simp only [max_eq_right h']; exact hui_cut
            · simp only [max_eq_left (le_of_lt h')]; exact huf_cut
          · simp only [max_eq_left (le_of_lt h)]; exact hm_cut
        have ⟨s₂, hs₂, hmax_s₂⟩ : ∃ s₂ ∈ γ.val.cut, max m (max uf_pt ui_pt) < s₂ := by
          by_contra h; push Not at h
          exact γ.val.no_sup ⟨_, ⟨h, fun _ hb => hb hmax3_cut⟩, hmax3_cut⟩
        exact ⟨s₂, hs₂,
          lt_of_le_of_lt (le_max_left _ _) hmax_s₂,
          lt_of_le_of_lt (le_trans (le_max_left _ _) (le_max_right _ _)) hmax_s₂,
          lt_of_le_of_lt (le_trans (le_max_right _ _) (le_max_right _ _)) hmax_s₂⟩
      have hDs : StaviTemporalTruth M atomMap s D :=
        (stavi_truth_mu_at_point s D).mp (hγ_bet s hms hs_cut)
      have hγs' : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
          (extendPoint s) (Sum.inr γ) := ⟨hs_cut, fun h => h hs_cut⟩
      have hBs : StaviTemporalTruth M atomMap s B :=
        (stavi_truth_mu_at_point s B).mp
          (hBui (extendPoint s) ((extendPoint_lt_iff ui_pt s).mpr huis) hγs' ⟨s, rfl⟩)
      have hD_bet_ms : ∀ u, m < u → u < s → StaviTemporalTruth M atomMap u D := by
        intro u hmu hus
        exact (stavi_truth_mu_at_point u D).mp
          (hγ_bet u hmu (γ.val.downward_closed s u hs_cut (le_of_lt hus)))
      -- S'(A,B)(s): construct via mu-form restriction from (s_bound, γ) to (s_bound, s)
      have hSnce_s : StaviTemporalTruth M atomMap s (.stavi_snce A B) := by
        -- `r` is implicit and undetermined by the RHS, so leaving it to unification made
        -- the rewrite emit a second, never-operated-on `?r : Nat` goal.
        rw [← stavi_truth_mu_at_point (r := r) s (.stavi_snce A B)]
        simp only [StaviTemporalTruthMu]
        refine ⟨s_bound_ext, lt_trans hs_uf ((extendPoint_lt_iff uf_pt s).mpr hufs), ?_, ?_, ?_⟩
        · -- body: restrict from (s_bound, γ) to (s_bound, extendPoint s)
          intro u hsu hus hmu
          cases h_body_AB u hsu (lt_trans hus hγs') hmu with
          | inl h_left =>
            left; obtain ⟨v, hvu, hmu_v, hBv⟩ := h_left
            exact ⟨v, hvu, hmu_v, fun w hvw hws hmu_w =>
              hBv w hvw (lt_trans hws hγs') hmu_w⟩
          | inr h_right =>
            right; obtain ⟨hA, v', huv', hv'γ, hmu_v', hBv'⟩ := h_right
            have hv'_s : v' < extendPoint s := by
              by_contra h; push Not at h
              exact hBv' (hBui v'
                (lt_of_lt_of_le ((extendPoint_lt_iff ui_pt s).mpr huis) h)
                hv'γ hmu_v')
            exact ⟨hA, v', huv', hv'_s, hmu_v', hBv'⟩
        · -- fail: uf_pt with ¬B
          exact ⟨extendPoint uf_pt, hs_uf,
            (extendPoint_lt_iff uf_pt s).mpr hufs, ⟨uf_pt, rfl⟩, hBuf⟩
        · -- init: ui_pt with B on (ui_pt, s), restricted from (ui_pt, γ)
          exact ⟨extendPoint ui_pt, hs_ui,
            (extendPoint_lt_iff ui_pt s).mpr huis, ⟨ui_pt, rfl⟩,
            fun v huiv hvs hmu_v =>
              hBui v huiv (lt_trans hvs hγs') hmu_v⟩
      -- Extract gap definability conditions (same as std_snce backward)
      obtain ⟨⟨t_D, ht_D_cut, hD_final⟩, h_no_init_D⟩ := hγ_def
      have h_compl_gt : ∀ x, x ∉ γ.val.cut → ∀ y, y ∈ γ.val.cut → y < x := by
        intro x hx y hy; by_contra h; push Not at h
        exact hx (γ.val.downward_closed y x hy h)
      have h_neg_init : ∀ t, t ∉ γ.val.cut →
          ∃ w, w ∉ γ.val.cut ∧ w ≤ t ∧ ¬StaviTemporalTruth M atomMap w D := by
        intro t ht; by_contra h_all; push Not at h_all
        exact h_no_init_D ⟨t, ht, fun w hw hwt => h_all w hw hwt⟩
      have ⟨c₀, hc₀_not⟩ : ∃ c₀, c₀ ∉ γ.val.cut := by
        by_contra h; push Not at h
        exact γ.val.proper (Set.eq_univ_iff_forall.mpr h)
      have hsc₀ : s < c₀ := h_compl_gt c₀ hc₀_not s hs_cut
      have h_bD_cut : ∀ u, s < u → u ∈ γ.val.cut →
          StaviTemporalTruth M atomMap u B ∧ StaviTemporalTruth M atomMap u D := by
        intro u hsu hu_cut
        exact ⟨(stavi_truth_mu_at_point u B).mp
          (hBui (extendPoint u)
            ((extendPoint_lt_iff ui_pt u).mpr (lt_trans huis hsu))
            ⟨hu_cut, fun h => h hu_cut⟩ ⟨u, rfl⟩),
          (stavi_truth_mu_at_point u D).mp (hγ_bet u (lt_trans hms hsu) hu_cut)⟩
      -- Provide the S'(A,B)(s) part of the goal
      have hSnce_s_expanded : ∃ s_1 < s,
          (∀ u, s_1 < u → u < s →
            (∃ v < u, ∀ w, v < w → w < s → StaviTemporalTruth M atomMap w B) ∨
            (∀ v, s_1 < v → v < u → StaviTemporalTruth M atomMap v A) ∧
              ∃ v', u < v' ∧ v' < s ∧ ¬StaviTemporalTruth M atomMap v' B) ∧
          (∃ u, s_1 < u ∧ u < s ∧ ¬StaviTemporalTruth M atomMap u B) ∧
          ∃ u, s_1 < u ∧ u < s ∧
            ∀ v, u < v → v < s → StaviTemporalTruth M atomMap v B := by
        simp only [StaviTemporalTruth] at hSnce_s
        exact hSnce_s
      refine ⟨s, hms, ⟨hDs, hBs, hSnce_s_expanded, ?_, ?_⟩, hD_bet_ms⟩
      · -- U'(⊤, B∧D)(s): same as std_snce backward
        refine ⟨c₀, hsc₀, ?_, ?_, ?_⟩
        · intro u hsu huc₀
          by_cases hu_cut : u ∈ γ.val.cut
          · left
            have ⟨y, hy_in, huy⟩ : ∃ y ∈ γ.val.cut, u < y := by
              by_contra h_all; push Not at h_all
              exact γ.val.no_sup ⟨u, ⟨fun x hx => h_all x hx, fun b hb => hb hu_cut⟩, hu_cut⟩
            exact ⟨y, huy, fun w hsw hwy =>
              h_bD_cut w hsw (γ.val.downward_closed y w hy_in (le_of_lt hwy))⟩
          · right
            refine ⟨fun v _ _ => by simp [TemporalTruth, Formula.top], ?_⟩
            have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
              by_contra h_all; push Not at h_all
              exact γ.val.complement_no_min ⟨u, hu_cut, fun z hz => h_all z hz⟩
            obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
            exact ⟨w, h_compl_gt w hw_not s hs_cut, lt_of_le_of_lt hwy hyu,
              fun ⟨_, hD'⟩ => hDw hD'⟩
        · have ⟨y, hy_not, hyc₀⟩ : ∃ y, y ∉ γ.val.cut ∧ y < c₀ := by
            by_contra h_all; push Not at h_all
            exact γ.val.complement_no_min ⟨c₀, hc₀_not, fun z hz => h_all z hz⟩
          obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
          exact ⟨w, h_compl_gt w hw_not s hs_cut, lt_of_le_of_lt hwy hyc₀,
            fun ⟨_, hD'⟩ => hDw hD'⟩
        · have ⟨y, hy_in, hsy⟩ : ∃ y ∈ γ.val.cut, s < y := by
            by_contra h_all; push Not at h_all
            exact γ.val.no_sup ⟨s, ⟨fun x hx => h_all x hx, fun b hb => hb hs_cut⟩, hs_cut⟩
          exact ⟨y, hsy, h_compl_gt c₀ hc₀_not y hy_in, fun v hsv hvy =>
            h_bD_cut v hsv (γ.val.downward_closed y v hy_in (le_of_lt hvy))⟩
      · -- ¬U'(D, B∧D)(s): same two-step D-transfer as std_snce backward
        intro ⟨s₁, hss₁, h_body, h_fail, h_init⟩
        obtain ⟨u_fail, hsu_fail, huf_s₁, hBD_fail⟩ := h_fail
        have huf_not_cut : u_fail ∉ γ.val.cut := by
          intro h; exact hBD_fail (h_bD_cut u_fail hsu_fail h)
        have h_left_fails : ∀ u, s < u → u < s₁ → u ∉ γ.val.cut →
            ¬(∃ v, u < v ∧ ∀ w, s < w → w < v →
              StaviTemporalTruth M atomMap w B ∧ StaviTemporalTruth M atomMap w D) := by
          intro u hsu _ hu_not ⟨v, huv, hBDv⟩
          have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
            by_contra h_all; push Not at h_all
            exact γ.val.complement_no_min ⟨u, hu_not, fun z hz => h_all z hz⟩
          obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
          exact hDw (hBDv w (h_compl_gt w hw_not s hs_cut)
            (lt_trans (lt_of_le_of_lt hwy hyu) huv)).2
        have hD_all_compl : ∀ u, s < u → u < s₁ → u ∉ γ.val.cut →
            StaviTemporalTruth M atomMap u D := by
          intro u hsu hus₁ hu_not
          have h_right_u := (h_body u hsu hus₁).resolve_left
            (h_left_fails u hsu hus₁ hu_not)
          obtain ⟨_, v', hsv', hv'u, hBD_v'⟩ := h_right_u
          have hv'_not : v' ∉ γ.val.cut := by
            intro h; exact hBD_v' (h_bD_cut v' hsv' h)
          have h_right_v' := (h_body v' hsv' (lt_trans hv'u hus₁)).resolve_left
            (h_left_fails v' hsv' (lt_trans hv'u hus₁) hv'_not)
          exact h_right_v'.1 u hv'u hus₁
        have ⟨t, ht_not, ht_uf⟩ : ∃ t, t ∉ γ.val.cut ∧ t < u_fail := by
          by_contra h_all; push Not at h_all
          exact γ.val.complement_no_min ⟨u_fail, huf_not_cut, fun z hz => h_all z hz⟩
        exact h_no_init_D
          ⟨t, ht_not, fun u hu_not hut =>
            hD_all_compl u (h_compl_gt u hu_not s hs_cut)
              (lt_of_le_of_lt hut (lt_trans ht_uf huf_s₁)) hu_not⟩
  | std_untl A B _ _ =>
    -- leftFormula (.std_untl A B) D = .stavi_untl (.conj B (.std_untl A B)) D
    -- Same pattern as stavi_untl: U'(B ∧ U(A,B), D)(m) ↔ ∃ γ, ... ∧ U(A,B)^mu(γ)
    simp only [leftFormula]
    constructor
    · -- Forward: from U'(B ∧ U(A,B), D)(m), get complement point truth, derive U(A,B)^mu(γ)
      intro h
      obtain ⟨γ, s_bound, hγ_lt, hs_not, hγ_def, hγ_bet, hX_compl⟩ :=
        (stavi_untl_gap_detection (.conj B (.std_untl A B)) D hD m).mp h
      -- hX_compl gives conj B (std_untl A B) at complement points
      -- Extract std_untl(A,B) at complement points and construct std_untl(A,B)^mu(γ)
      have hUA_compl : ∀ u : M.carrier, u ∉ γ.val.cut → u < s_bound →
          StaviTemporalTruth M atomMap u (.std_untl A B) :=
        fun u hu hus => (hX_compl u hu hus).2
      -- std_untl(A,B)^mu(γ): ∃ mu-point s > γ, A^mu(s) ∧ ∀ mu-point u ∈ (γ,s), B^mu(u)
      -- Pick complement point u₁ < s_bound. std_untl(A,B)(u₁) gives ∃ s > u₁, A(s) ∧ B on (u₁, s).
      -- B at complement points below u₁ from hX_compl.
      have ⟨u₁, hu₁_not, hu₁s⟩ : ∃ u₁, u₁ ∉ γ.val.cut ∧ u₁ < s_bound := by
        by_contra h_all; push Not at h_all
        exact γ.val.complement_no_min ⟨s_bound, hs_not, fun z hz => h_all z hz⟩
      have hB_compl : ∀ u : M.carrier, u ∉ γ.val.cut → u < s_bound →
          StaviTemporalTruth M atomMap u B :=
        fun u hu hus => (hX_compl u hu hus).1
      have hUA_u₁ := hUA_compl u₁ hu₁_not hu₁s
      -- std_untl(A,B)(u₁): ∃ s₁ > u₁, A(s₁) ∧ B on (u₁, s₁)
      simp only [StaviTemporalTruth] at hUA_u₁
      obtain ⟨s₁, hu₁s₁, hAs₁, hB_between⟩ := hUA_u₁
      -- Construct std_untl(A,B)^mu(γ)
      refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
      simp only [StaviTemporalTruthMu]
      -- Need: ∃ s > γ, MuHolds s ∧ A^mu(s) ∧ ∀ mu-pt u ∈ (γ,s), B^mu(u)
      have hs₁_not : s₁ ∉ γ.val.cut := by
        intro h; exact hu₁_not (γ.val.downward_closed s₁ u₁ h (le_of_lt hu₁s₁))
      refine ⟨extendPoint s₁, ⟨hs₁_not, hs₁_not⟩, ⟨s₁, rfl⟩,
        (stavi_truth_mu_at_point s₁ A).mpr hAs₁, fun u hγu hus hmu => ?_⟩
      obtain ⟨u_pt, rfl⟩ := hmu
      have hu_pt_not : u_pt ∉ γ.val.cut := by
        intro h; exact not_lt.mpr (show extendPoint u_pt ≤ Sum.inr γ from h) hγu
      have hu_pt_s₁ : u_pt < s₁ := (extendPoint_lt_iff u_pt s₁).mp hus
      by_cases hu_u₁ : u₁ < u_pt
      · exact (stavi_truth_mu_at_point u_pt B).mpr (hB_between u_pt hu_u₁ hu_pt_s₁)
      · push Not at hu_u₁
        exact (stavi_truth_mu_at_point u_pt B).mpr
          (hB_compl u_pt hu_pt_not (lt_of_le_of_lt hu_u₁ hu₁s))
    · -- Backward: from gap with U(A,B)^mu(γ), construct U'(B ∧ U(A,B), D)(m)
      intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hUA⟩
      -- U(A,B)^mu(γ) = ∃ s > γ, MuHolds s ∧ A^mu(s) ∧ ∀ mu-pt u ∈ (γ,s), B^mu(u)
      simp only [StaviTemporalTruthMu] at hUA
      obtain ⟨s_ua, hγ_s_ua, hmu_s, hA_s, hB_mu⟩ := hUA
      obtain ⟨s₁, rfl⟩ := hmu_s
      have hs₁_not : s₁ ∉ γ.val.cut := by
        intro h; exact not_lt.mpr (show extendPoint s₁ ≤ Sum.inr γ from h) hγ_s_ua
      -- Apply stavi_untl_gap_detection.mpr with s_bound = s₁
      -- Need: (B ∧ U(A,B)) at complement points u with u ∉ γ.cut and u < s₁
      apply (stavi_untl_gap_detection (.conj B (.std_untl A B)) D hD m).mpr
      refine ⟨γ, s₁, hγ_lt, hs₁_not, hγ_def, hγ_bet, fun u hu_not hu_s₁ => ?_⟩
      -- u is a complement point above γ with u < s₁
      -- Show B(u) ∧ U(A,B)(u)
      have hγu : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
          (Sum.inr γ) (extendPoint u) := by
        change u ∉ γ.val.cut ∧ ¬(u ∈ γ.val.cut); exact ⟨hu_not, hu_not⟩
      simp only [StaviTemporalTruth]
      constructor
      · -- B(u): from hB_mu, since γ < extendPoint u < extendPoint s₁
        exact (stavi_truth_mu_at_point u B).mp
          (hB_mu (extendPoint u) hγu ((extendPoint_lt_iff u s₁).mpr hu_s₁) ⟨u, rfl⟩)
      · -- U(A,B)(u): ∃ s' > u, A(s') ∧ B on (u, s'). Pick s' = s₁.
        refine ⟨s₁, hu_s₁, (stavi_truth_mu_at_point s₁ A).mp hA_s, fun v huv hvs₁ => ?_⟩
        -- v is between u and s₁, both complement points, so v ∉ γ.cut
        have hv_not : v ∉ γ.val.cut := by
          intro h; exact hu_not (γ.val.downward_closed v u h (le_of_lt huv))
        have hγv : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (Sum.inr γ) (extendPoint v) := by
          change v ∉ γ.val.cut ∧ ¬(v ∈ γ.val.cut); exact ⟨hv_not, hv_not⟩
        exact (stavi_truth_mu_at_point v B).mp
          (hB_mu (extendPoint v) hγv ((extendPoint_lt_iff v s₁).mpr hvs₁) ⟨v, rfl⟩)
  | std_snce A B _ _ =>
    -- leftFormula (.std_snce A B) D = .std_untl compound D
    -- compound = D ∧ B ∧ S(A,B) ∧ U'(⊤, B∧D) ∧ ¬U'(D, B∧D)
    -- Same compound decomposition as base.snce; S(A,B)^mu has simple structure
    simp only [leftFormula]
    rw [stavi_truth_mu_at_point m (.std_untl _ D)]
    simp only [StaviTemporalTruth]
    constructor
    · -- Forward: compound at s → gap with S(A,B)^mu(γ)
      -- Identical compound decomposition as base.snce, only temporal part differs
      intro ⟨s, hms, ⟨hDs, hBs, ⟨q, hqs, hAq, hBqs⟩, hU'_BD_s, hNotU'D_BD_s⟩, hD_bet⟩
      obtain ⟨s₁, hss₁, h_body, h_fail, h_init⟩ := hU'_BD_s
      obtain ⟨u_fail, hsu_fail, hu_fail_s₁, hBD_fail⟩ := h_fail
      obtain ⟨u_init, hsu_init, hu_init_s₁, hBD_init⟩ := h_init
      let bD : M.carrier → Prop := fun u =>
        StaviTemporalTruth M atomMap u B ∧ StaviTemporalTruth M atomMap u D
      let cut : Set M.carrier :=
        {x | ∀ u, s < u → u ≤ x → ∃ v, u < v ∧ ∀ w, s < w → w < v → bD w}
      have hs_in_cut : s ∈ cut :=
        fun u hsu hus => absurd (lt_of_lt_of_le hsu hus) (lt_irrefl s)
      have hu_fail_not_cut : u_fail ∉ cut := by
        intro h; obtain ⟨v, hfv, hBDv⟩ := h u_fail hsu_fail le_rfl
        exact hBD_fail (hBDv u_fail hsu_fail hfv)
      have h_cut_lt_uf : ∀ x ∈ cut, x < u_fail := by
        intro x hx; by_contra h; push Not at h
        exact hu_fail_not_cut (fun u hsu huf => hx u hsu (le_trans huf h))
      have h_dc : ∀ x y, x ∈ cut → y ≤ x → y ∈ cut :=
        fun x y hx hyx u hsu huy => hx u hsu (le_trans huy hyx)
      have h_proper : cut ≠ Set.univ := by
        intro h; exact hu_fail_not_cut (h ▸ Set.mem_univ u_fail)
      have h_cofinal_propagate :
          ∀ u, s < u → u < s₁ →
          (∀ w, s < w → w < u → ∃ v, w < v ∧ ∀ z, s < z → z < v → bD z) →
          ∃ v, u < v ∧ ∀ z, s < z → z < v → bD z := by
        intro u hsu hus₁ h_below
        cases h_body u hsu hus₁ with
        | inl h => exact h
        | inr h =>
          obtain ⟨_, v', hsv', hv'u, hBDv'⟩ := h
          obtain ⟨v₂, hv'v₂, hBDv₂⟩ := h_below v' hsv' hv'u
          exact absurd (hBDv₂ v' hsv' hv'v₂) hBDv'
      have hu_init_cut : u_init ∈ cut := by
        intro u hsu huu_init
        exact h_cofinal_propagate u hsu (lt_of_le_of_lt huu_init hu_init_s₁)
          (fun w hsw hwu => ⟨u_init, lt_of_lt_of_le hwu huu_init,
            fun z hsz hz_init => hBD_init z hsz hz_init⟩)
      have h_bD_at_cut : ∀ u, s < u → u ∈ cut → bD u := by
        intro u hsu hu_cut
        obtain ⟨v, huv, hBDv⟩ := hu_cut u hsu le_rfl
        exact hBDv u hsu huv
      have h_no_sup : ¬∃ p, IsLUB cut p ∧ p ∈ cut := by
        intro ⟨p, ⟨h_ub, _⟩, hp_cut⟩
        have hsp : s < p := lt_of_lt_of_le hsu_init (h_ub hu_init_cut)
        obtain ⟨v, hpv, hBDv⟩ := hp_cut p hsp le_rfl
        have hvs₁ : v < s₁ := by
          by_contra h; push Not at h
          exact hBD_fail (hBDv u_fail hsu_fail (lt_of_lt_of_le hu_fail_s₁ h))
        exact not_le.mpr hpv (h_ub (show v ∈ cut from fun u hsu huv => by
          rcases eq_or_lt_of_le huv with rfl | huv'
          · exact h_cofinal_propagate u (lt_trans hsp hpv) hvs₁
              (fun w hsw hwu => ⟨u, hwu, hBDv⟩)
          · exact ⟨v, huv', hBDv⟩))
      have h_comp_no_min : ¬∃ b, b ∉ cut ∧ ∀ y, y ∉ cut → b ≤ y := by
        intro ⟨b, hb_not, hb_min⟩
        have hsb : s < b := by
          by_contra h; push Not at h; exact hb_not (h_dc s b hs_in_cut h)
        have hbs₁ : b < s₁ := lt_of_le_of_lt (hb_min u_fail hu_fail_not_cut) hu_fail_s₁
        have h_below_b : ∀ y, y < b → y ∈ cut := by
          intro y hyb; by_contra hy_not; exact not_lt.mpr (hb_min y hy_not) hyb
        cases h_body b hsb hbs₁ with
        | inl h_cof =>
          exact hb_not (fun u hsu hub => by
            rcases eq_or_lt_of_le hub with rfl | hub'
            · exact h_cof
            · exact (h_below_b u hub') u hsu le_rfl)
        | inr h =>
          obtain ⟨_, v', hsv', hv'b, hBDv'⟩ := h
          obtain ⟨v₂, hv'v₂, hBDv₂⟩ := (h_below_b v' hv'b) v' hsv' le_rfl
          exact hBDv' (hBDv₂ v' hsv' hv'v₂)
      let γ_gap : Gap M.carrier :=
        ⟨cut, ⟨s, hs_in_cut⟩, h_proper, h_dc, h_no_sup, h_comp_no_min⟩
      have h_D_cofinal_cut : ∃ t, t ∈ γ_gap.cut ∧
          ∀ u, t ≤ u → u ∈ γ_gap.cut → StaviTemporalTruth M atomMap u D :=
        ⟨u_init, hu_init_cut, fun u hu_le hu_cut =>
          (h_bD_at_cut u (lt_of_lt_of_le hsu_init hu_le) hu_cut).2⟩
      have h_no_init_compl_bD : ¬∃ t, t ∉ γ_gap.cut ∧
          ∀ u, u ∉ γ_gap.cut → u ≤ t → bD u := by
        intro ⟨t, ht_not, hBDt⟩
        have hst : s < t := by
          by_contra h; push Not at h; exact ht_not (h_dc s t hs_in_cut h)
        have hts₁ : t < s₁ := by
          by_contra h; push Not at h
          exact hBD_fail (hBDt u_fail hu_fail_not_cut (le_trans (le_of_lt hu_fail_s₁) h))
        suffices t ∈ cut from ht_not this
        intro u hsu hut
        exact h_cofinal_propagate u hsu (lt_of_le_of_lt hut hts₁)
          (fun w hsw hwu =>
            h_cofinal_propagate w hsw (lt_trans hwu (lt_of_le_of_lt hut hts₁))
              (fun z hsz hzw => by
                cases h_body z hsz (lt_trans hzw (lt_trans hwu
                    (lt_of_le_of_lt hut hts₁))) with
                | inl h => exact h
                | inr h =>
                  obtain ⟨_, v', hsv', hv'z, hBDv'⟩ := h
                  have : bD v' := by
                    by_cases hv'_cut : v' ∈ cut
                    · exact h_bD_at_cut v' hsv' hv'_cut
                    · exact hBDt v' hv'_cut (le_trans (le_of_lt hv'z)
                        (le_trans (le_of_lt hzw) (le_trans (le_of_lt hwu) hut)))
                  exact absurd this hBDv'))
      have hD_fails : ∃ u_D, s < u_D ∧ u_D < s₁ ∧
          ¬StaviTemporalTruth M atomMap u_D D := by
        by_contra h_all_D; push Not at h_all_D
        apply hNotU'D_BD_s
        exact ⟨s₁, hss₁,
          fun u hsu hus₁ => by
            cases h_body u hsu hus₁ with
            | inl h => left; exact h
            | inr h => right; exact ⟨fun v huv hvs₁ => h_all_D v (lt_trans hsu huv) hvs₁, h.2⟩,
          ⟨u_fail, hsu_fail, hu_fail_s₁, hBD_fail⟩,
          ⟨u_init, hsu_init, hu_init_s₁, hBD_init⟩⟩
      obtain ⟨u_D, hsu_D, hu_D_s₁, hD_fail_D⟩ := hD_fails
      have hu_D_not_cut : u_D ∉ cut := by
        intro h; exact hD_fail_D (h_bD_at_cut u_D hsu_D h).2
      have h_compl_gt_cut : ∀ x, x ∉ cut → ∀ y, y ∈ cut → y < x := by
        intro x hx y hy; by_contra h; push Not at h; exact hx (h_dc y x hy h)
      have h_no_init_compl_D : ¬∃ t, t ∉ γ_gap.cut ∧
          ∀ u, u ∉ γ_gap.cut → u ≤ t → StaviTemporalTruth M atomMap u D := by
        intro ⟨t, ht_not, hDt⟩
        have hst : s < t := h_compl_gt_cut t ht_not s hs_in_cut
        have ht_uD : t < u_D := by
          by_contra h; push Not at h; exact hD_fail_D (hDt u_D hu_D_not_cut h)
        have hts₁ : t < s₁ := lt_trans ht_uD hu_D_s₁
        apply hNotU'D_BD_s
        refine ⟨t, hst, ?_, ?_, ?_⟩
        · intro u hsu hut
          cases h_body u hsu (lt_trans hut hts₁) with
          | inl h => left; exact h
          | inr h => right
                     exact ⟨fun v huv hvt => by
                       by_cases hv_cut : v ∈ cut
                       · exact (h_bD_at_cut v (lt_trans hsu huv) hv_cut).2
                       · exact hDt v hv_cut (le_of_lt hvt), h.2⟩
        · by_contra h_no_fail; push Not at h_no_fail
          apply h_no_init_compl_bD
          obtain ⟨c, hc_not, hct⟩ : ∃ c, c ∉ cut ∧ c < t := by
            by_contra h; push Not at h
            exact h_comp_no_min ⟨t, ht_not, fun y hy => h y hy⟩
          exact ⟨c, hc_not, fun u hu huc =>
            h_no_fail u (h_compl_gt_cut u hu s hs_in_cut) (lt_of_le_of_lt huc hct)⟩
        · exact ⟨u_init, hsu_init, h_compl_gt_cut t ht_not u_init hu_init_cut, hBD_init⟩
      have h_def_left_D : GapDefinableOnLeft M atomMap γ_gap D :=
        ⟨h_D_cofinal_cut, h_no_init_compl_D⟩
      let γ : RDefinableGap M atomMap r := ⟨γ_gap, ⟨D, hD, Or.inl h_def_left_D⟩⟩
      refine ⟨γ, ?_, ?_, ?_, ?_⟩
      · have hm_in : m ∈ cut := h_dc s m hs_in_cut (le_of_lt hms)
        exact ⟨hm_in, fun h => h hm_in⟩
      · exact h_def_left_D
      · intro u hmu hu_cut
        by_cases hsu : s < u
        · exact (stavi_truth_mu_at_point u D).mpr (h_bD_at_cut u hsu hu_cut).2
        · push Not at hsu
          rcases eq_or_lt_of_le hsu with rfl | hus
          · exact (stavi_truth_mu_at_point u D).mpr hDs
          · exact (stavi_truth_mu_at_point u D).mpr (hD_bet u hmu hus)
      · -- S(A,B)^mu(γ): from S(A,B)(s), same construction as base.snce
        have hq_cut : q ∈ cut := h_dc s q hs_in_cut (le_of_lt hqs)
        exact ⟨extendPoint q, ⟨hq_cut, fun h => h hq_cut⟩, ⟨q, rfl⟩,
          (stavi_truth_mu_at_point q A).mpr hAq,
          fun u hqu huγ hmu => by
            obtain ⟨p, rfl⟩ := hmu
            have hp_cut : p ∈ cut := huγ.1
            have hqp : q < p := (extendPoint_lt_iff q p).mp hqu
            by_cases hps : p ≤ s
            · rcases eq_or_lt_of_le hps with rfl | hps'
              · exact (stavi_truth_mu_at_point p B).mpr hBs
              · exact (stavi_truth_mu_at_point p B).mpr (hBqs p hqp hps')
            · push Not at hps
              exact (stavi_truth_mu_at_point p B).mpr (h_bD_at_cut p hps hp_cut).1⟩
    · -- Backward: gap with S(A,B)^mu(γ) → compound at m
      intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hSnce_mu⟩
      obtain ⟨t_ext, ht_γ, ⟨t_pt, rfl⟩, hA_t, hB_mu⟩ := hSnce_mu
      have ht_cut : t_pt ∈ γ.val.cut :=
        (extendPoint_le_gap_iff t_pt γ).mp (le_of_lt ht_γ)
      have hm_cut : m ∈ γ.val.cut :=
        (extendPoint_le_gap_iff m γ).mp (le_of_lt hγ_lt)
      have ⟨s, hs_cut, hms, hts⟩ : ∃ s, s ∈ γ.val.cut ∧ m < s ∧ t_pt < s := by
        have ⟨s₁, hs₁, hms₁⟩ : ∃ s₁ ∈ γ.val.cut, m < s₁ := by
          by_contra h; push Not at h
          exact γ.val.no_sup ⟨m, ⟨h, fun _ hb => hb hm_cut⟩, hm_cut⟩
        have hmax_cut : max s₁ t_pt ∈ γ.val.cut := by
          rcases le_or_gt s₁ t_pt with h | h
          · simp only [max_eq_right h]; exact ht_cut
          · simp only [max_eq_left (le_of_lt h)]; exact hs₁
        have ⟨s₂, hs₂, hmax_s₂⟩ : ∃ s₂ ∈ γ.val.cut, max s₁ t_pt < s₂ := by
          by_contra h; push Not at h
          exact γ.val.no_sup ⟨max s₁ t_pt, ⟨h, fun _ hb => hb hmax_cut⟩, hmax_cut⟩
        exact ⟨s₂, hs₂,
          lt_trans hms₁ (lt_of_le_of_lt (le_max_left s₁ t_pt) hmax_s₂),
          lt_of_le_of_lt (le_max_right s₁ t_pt) hmax_s₂⟩
      have hDs : StaviTemporalTruth M atomMap s D :=
        (stavi_truth_mu_at_point s D).mp (hγ_bet s hms hs_cut)
      have hγs : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
          (extendPoint t_pt) (extendPoint s) :=
        (extendPoint_lt_iff t_pt s).mpr hts
      have hγs' : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
          (extendPoint s) (Sum.inr γ) := ⟨hs_cut, fun h => h hs_cut⟩
      have hBs : StaviTemporalTruth M atomMap s B :=
        (stavi_truth_mu_at_point s B).mp
          (hB_mu (extendPoint s) hγs hγs' ⟨s, rfl⟩)
      have hSnce_s : ∃ s_1 < s, StaviTemporalTruth M atomMap s_1 A ∧
          ∀ u, s_1 < u → u < s → StaviTemporalTruth M atomMap u B := by
        refine ⟨t_pt, hts, (stavi_truth_mu_at_point t_pt A).mp hA_t, fun u htu hus => ?_⟩
        have hu_cut : u ∈ γ.val.cut := γ.val.downward_closed s u hs_cut (le_of_lt hus)
        have hγu : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint t_pt) (extendPoint u) :=
          (extendPoint_lt_iff t_pt u).mpr htu
        have huγ : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint u) (Sum.inr γ) := ⟨hu_cut, fun h => h hu_cut⟩
        exact (stavi_truth_mu_at_point u B).mp
          (hB_mu (extendPoint u) hγu huγ ⟨u, rfl⟩)
      have hD_bet_ms : ∀ u, m < u → u < s → StaviTemporalTruth M atomMap u D := by
        intro u hmu hus
        exact (stavi_truth_mu_at_point u D).mp
          (hγ_bet u hmu (γ.val.downward_closed s u hs_cut (le_of_lt hus)))
      obtain ⟨⟨t_D, ht_D_cut, hD_final⟩, h_no_init_D⟩ := hγ_def
      have h_compl_gt : ∀ x, x ∉ γ.val.cut → ∀ y, y ∈ γ.val.cut → y < x := by
        intro x hx y hy; by_contra h; push Not at h
        exact hx (γ.val.downward_closed y x hy h)
      have h_neg_init : ∀ t, t ∉ γ.val.cut →
          ∃ w, w ∉ γ.val.cut ∧ w ≤ t ∧ ¬StaviTemporalTruth M atomMap w D := by
        intro t ht; by_contra h_all; push Not at h_all
        exact h_no_init_D ⟨t, ht, fun w hw hwt => h_all w hw hwt⟩
      have ⟨c₀, hc₀_not⟩ : ∃ c₀, c₀ ∉ γ.val.cut := by
        by_contra h; push Not at h
        exact γ.val.proper (Set.eq_univ_iff_forall.mpr h)
      have hsc₀ : s < c₀ := h_compl_gt c₀ hc₀_not s hs_cut
      have h_bD_cut : ∀ u, s < u → u ∈ γ.val.cut →
          StaviTemporalTruth M atomMap u B ∧ StaviTemporalTruth M atomMap u D := by
        intro u hsu hu_cut
        exact ⟨(stavi_truth_mu_at_point u B).mp
          (hB_mu (extendPoint u)
            ((extendPoint_lt_iff t_pt u).mpr (lt_trans hts hsu))
            ⟨hu_cut, fun h => h hu_cut⟩ ⟨u, rfl⟩),
          (stavi_truth_mu_at_point u D).mp (hγ_bet u (lt_trans hms hsu) hu_cut)⟩
      refine ⟨s, hms, ⟨hDs, hBs, hSnce_s, ?_, ?_⟩, hD_bet_ms⟩
      · -- U'(⊤, B∧D)(s): same as base.snce backward
        refine ⟨c₀, hsc₀, ?_, ?_, ?_⟩
        · intro u hsu huc₀
          by_cases hu_cut : u ∈ γ.val.cut
          · left
            have ⟨y, hy_in, huy⟩ : ∃ y ∈ γ.val.cut, u < y := by
              by_contra h_all; push Not at h_all
              exact γ.val.no_sup ⟨u, ⟨fun x hx => h_all x hx, fun b hb => hb hu_cut⟩, hu_cut⟩
            exact ⟨y, huy, fun w hsw hwy =>
              h_bD_cut w hsw (γ.val.downward_closed y w hy_in (le_of_lt hwy))⟩
          · right
            refine ⟨fun v _ _ => by simp [TemporalTruth, Formula.top], ?_⟩
            have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
              by_contra h_all; push Not at h_all
              exact γ.val.complement_no_min ⟨u, hu_cut, fun z hz => h_all z hz⟩
            obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
            exact ⟨w, h_compl_gt w hw_not s hs_cut, lt_of_le_of_lt hwy hyu,
              fun ⟨_, hD'⟩ => hDw hD'⟩
        · have ⟨y, hy_not, hyc₀⟩ : ∃ y, y ∉ γ.val.cut ∧ y < c₀ := by
            by_contra h_all; push Not at h_all
            exact γ.val.complement_no_min ⟨c₀, hc₀_not, fun z hz => h_all z hz⟩
          obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
          exact ⟨w, h_compl_gt w hw_not s hs_cut, lt_of_le_of_lt hwy hyc₀,
            fun ⟨_, hD'⟩ => hDw hD'⟩
        · have ⟨y, hy_in, hsy⟩ : ∃ y ∈ γ.val.cut, s < y := by
            by_contra h_all; push Not at h_all
            exact γ.val.no_sup ⟨s, ⟨fun x hx => h_all x hx, fun b hb => hb hs_cut⟩, hs_cut⟩
          exact ⟨y, hsy, h_compl_gt c₀ hc₀_not y hy_in, fun v hsv hvy =>
            h_bD_cut v hsv (γ.val.downward_closed y v hy_in (le_of_lt hvy))⟩
      · -- ¬U'(D, B∧D)(s): same two-step D-transfer as base.snce
        intro ⟨s₁, hss₁, h_body, h_fail, h_init⟩
        obtain ⟨u_fail, hsu_fail, huf_s₁, hBD_fail⟩ := h_fail
        have huf_not_cut : u_fail ∉ γ.val.cut := by
          intro h; exact hBD_fail (h_bD_cut u_fail hsu_fail h)
        have h_left_fails : ∀ u, s < u → u < s₁ → u ∉ γ.val.cut →
            ¬(∃ v, u < v ∧ ∀ w, s < w → w < v →
              StaviTemporalTruth M atomMap w B ∧ StaviTemporalTruth M atomMap w D) := by
          intro u hsu _ hu_not ⟨v, huv, hBDv⟩
          have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
            by_contra h_all; push Not at h_all
            exact γ.val.complement_no_min ⟨u, hu_not, fun z hz => h_all z hz⟩
          obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
          exact hDw (hBDv w (h_compl_gt w hw_not s hs_cut)
            (lt_trans (lt_of_le_of_lt hwy hyu) huv)).2
        have hD_all_compl : ∀ u, s < u → u < s₁ → u ∉ γ.val.cut →
            StaviTemporalTruth M atomMap u D := by
          intro u hsu hus₁ hu_not
          have h_right_u := (h_body u hsu hus₁).resolve_left
            (h_left_fails u hsu hus₁ hu_not)
          obtain ⟨_, v', hsv', hv'u, hBD_v'⟩ := h_right_u
          have hv'_not : v' ∉ γ.val.cut := by
            intro h; exact hBD_v' (h_bD_cut v' hsv' h)
          have h_right_v' := (h_body v' hsv' (lt_trans hv'u hus₁)).resolve_left
            (h_left_fails v' hsv' (lt_trans hv'u hus₁) hv'_not)
          exact h_right_v'.1 u hv'u hus₁
        have ⟨t, ht_not, ht_uf⟩ : ∃ t, t ∉ γ.val.cut ∧ t < u_fail := by
          by_contra h_all; push Not at h_all
          exact γ.val.complement_no_min ⟨u_fail, huf_not_cut, fun z hz => h_all z hz⟩
        exact h_no_init_D ⟨t, ht_not, fun u hu_not hut =>
          hD_all_compl u (h_compl_gt u hu_not s hs_cut)
            (lt_of_le_of_lt hut (lt_trans ht_uf huf_s₁)) hu_not⟩

end FormalSystem.Metalogic.Expressiveness
