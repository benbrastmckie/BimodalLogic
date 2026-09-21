/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Expressiveness.EFGames.TypeFormulas

/-!
# Mu-Relativized Truth at Actual Points

At an actual point `extendPoint m` of the extended structure, mu-relativized truth agrees with
ordinary truth in the base structure: `extendPoint_lt_iff`, `temporal_truth_mu_at_point` and
`stavi_truth_mu_at_point`. These lemmas depend only on `EFGames/TypeFormulas.lean`, not on the gap
detection formulas, and are what the game-transfer development uses from this family.
-/

namespace FormalSystem.Metalogic.Expressiveness

open FormalSystem.Syntax

/-! ### Mu-Relativized Truth at Actual Points

Key infrastructure lemma: at an actual point (extendPoint m), the mu-relativized
temporal truth agrees with standard temporal truth. This is because mu-points in
M_r are exactly the actual points from M, and the ordering among actual points in
M_r is the same as in M. -/

/-- extendPoint preserves strict order. -/
theorem extendPoint_lt_iff {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat} (x y : M.carrier) :
    extendPoint (sig := sig) (atomMap := atomMap) (r := r) x <
    extendPoint (sig := sig) (atomMap := atomMap) (r := r) y ↔ x < y := by
  simp only [extendPoint]
  constructor
  · intro ⟨hle, hne⟩; exact lt_of_le_of_ne (show x ≤ y from hle) (fun h => hne (h ▸ le_refl y))
  · intro h; exact ⟨le_of_lt h, fun hyx => not_lt.mpr (show y ≤ x from hyx) h⟩

/-- For standard temporal formulas, mu-relativized truth at an actual point equals
    standard temporal truth. -/
theorem temporal_truth_mu_at_point {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (m : M.carrier) (φ : Formula) :
    TemporalTruthMu M atomMap r (extendPoint m) φ ↔
    TemporalTruth M atomMap m φ := by
  induction φ generalizing m with
  | atom a =>
    simp only [TemporalTruthMu, TemporalTruth, extendPoint]
  | bot =>
    simp only [TemporalTruthMu, TemporalTruth]
  | imp φ ψ ihφ ihψ =>
    simp only [TemporalTruthMu, TemporalTruth]
    exact Iff.imp (ihφ m) (ihψ m)
  | box φ =>
    simp only [TemporalTruthMu, TemporalTruth, extendPoint]
  | untl ψ φ ihψ ihφ =>
    constructor
    · intro ⟨s, hms, hmu, hphi, hpsi⟩
      obtain ⟨s', rfl⟩ := hmu
      have hms' : m < s' := (extendPoint_lt_iff m s').mp hms
      exact ⟨s', hms', (ihφ s').mp hphi, fun u hmu' hus =>
        (ihψ u).mp (hpsi (extendPoint u) ((extendPoint_lt_iff m u).mpr hmu')
          ((extendPoint_lt_iff u s').mpr hus) ⟨u, rfl⟩)⟩
    · intro ⟨s, hms, hphi, hpsi⟩
      refine ⟨extendPoint s, (extendPoint_lt_iff m s).mpr hms, ⟨s, rfl⟩,
        (ihφ s).mpr hphi, fun u hmu hus hmu_holds => ?_⟩
      obtain ⟨u', rfl⟩ := hmu_holds
      exact (ihψ u').mpr (hpsi u' ((extendPoint_lt_iff m u').mp hmu)
        ((extendPoint_lt_iff u' s).mp hus))
  | snce ψ φ ihψ ihφ =>
    constructor
    · intro ⟨s, hsm, hmu, hphi, hpsi⟩
      obtain ⟨s', rfl⟩ := hmu
      have hsm' : s' < m := (extendPoint_lt_iff s' m).mp hsm
      exact ⟨s', hsm', (ihφ s').mp hphi, fun u hsu hum =>
        (ihψ u).mp (hpsi (extendPoint u) ((extendPoint_lt_iff s' u).mpr hsu)
          ((extendPoint_lt_iff u m).mpr hum) ⟨u, rfl⟩)⟩
    · intro ⟨s, hsm, hphi, hpsi⟩
      refine ⟨extendPoint s, (extendPoint_lt_iff s m).mpr hsm, ⟨s, rfl⟩,
        (ihφ s).mpr hphi, fun u hsu hum hmu_holds => ?_⟩
      obtain ⟨u', rfl⟩ := hmu_holds
      exact (ihψ u').mpr (hpsi u' ((extendPoint_lt_iff s u').mp hsu)
        ((extendPoint_lt_iff u' m).mp hum))

/-- For Stavi formulas, mu-relativized truth at an actual point equals
    standard temporal truth. -/
theorem stavi_truth_mu_at_point {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (m : M.carrier) (A : StaviFormula) :
    StaviTemporalTruthMu M atomMap r (extendPoint m) A ↔
    StaviTemporalTruth M atomMap m A := by
  induction A generalizing m with
  | base φ =>
    simp only [StaviTemporalTruthMu, StaviTemporalTruth]
    exact temporal_truth_mu_at_point m φ
  | neg A ih =>
    simp only [StaviTemporalTruthMu, StaviTemporalTruth]
    exact Iff.not (ih m)
  | conj A B ihA ihB =>
    simp only [StaviTemporalTruthMu, StaviTemporalTruth]
    exact Iff.and (ihA m) (ihB m)
  | stavi_untl A B ihA ihB =>
    simp only [StaviTemporalTruthMu, StaviTemporalTruth]
    constructor
    · -- mp: mu-relativized → standard
      intro ⟨s, hms, h_body, ⟨u_fail, hmu_fail, hus_fail, hmu_fail_mu, hB_fail⟩,
             ⟨u_init, hmu_init, hus_init, hmu_init_mu, hB_init⟩⟩
      -- Get M.carrier representatives
      obtain ⟨uf, rfl⟩ := hmu_fail_mu
      obtain ⟨ui, rfl⟩ := hmu_init_mu
      -- We need s' : M.carrier with s' > m. The witness s might be a gap.
      -- Use a point in the complement of s's gap (if s is a gap), or s itself.
      -- For the bound, we need s' such that uf < s' and ui < s'.
      -- Key: s > extendPoint uf and s > extendPoint ui.
      -- Take s' : find a point in M.carrier above both uf and ui.
      -- Option: use s if it's a point, otherwise use complement element.
      -- Actually we can just pick a point above both witnesses.
      -- Since the body only needs to hold on (m, s'), we can pick s' > uf, ui.
      -- But we need s' > uf AND s' > ui. Without NoMaxOrder, just take max(uf, ui) + 1?
      -- Actually, we have s > extendPoint uf in ExtendedCarrier. If s is a gap g,
      -- then uf ∈ g.val.cut. Since g.val.cut ≠ univ (proper), ∃ s' ∉ g.val.cut.
      -- Such s' satisfies extendPoint s' > Sum.inr g > extendPoint uf, so s' > uf.
      -- Similarly s' > ui.
      -- If s is a point extendPoint s', then s' > uf and s' > ui directly.
      -- In either case, we get s' > max(uf, ui) > m.
      -- Let's handle both cases of s:
      rcases s with s' | g
      · -- s = extendPoint s'
        have hms' : m < s' := (extendPoint_lt_iff m s').mp hms
        refine ⟨s', hms', ?_, ?_, ?_⟩
        · -- Body: ∀ u ∈ (m, s'), disjunction
          intro u hmu hus'
          have h_disj := h_body (extendPoint u) ((extendPoint_lt_iff m u).mpr hmu)
            ((extendPoint_lt_iff u s').mpr hus') ⟨u, rfl⟩
          cases h_disj with
          | inl h =>
            left
            obtain ⟨v, huv, hv_mu, hBv⟩ := h
            obtain ⟨v', rfl⟩ := hv_mu
            exact ⟨v', (extendPoint_lt_iff u v').mp huv,
              fun w hmw hwv' => (ihB w).mp (hBv (extendPoint w)
                ((extendPoint_lt_iff m w).mpr hmw) ((extendPoint_lt_iff w v').mpr hwv') ⟨w, rfl⟩)⟩
          | inr h =>
            right
            obtain ⟨hA, v', hmv', hv'u, hv'_mu, hBv'⟩ := h
            obtain ⟨v'', rfl⟩ := hv'_mu
            exact ⟨fun v huv hvs' => (ihA v).mp (hA (extendPoint v)
                ((extendPoint_lt_iff u v).mpr huv) ((extendPoint_lt_iff v s').mpr hvs') ⟨v, rfl⟩),
              v'', (extendPoint_lt_iff m v'').mp hmv', (extendPoint_lt_iff v'' u).mp hv'u,
              fun h => hBv' ((ihB v'').mpr h)⟩
        · -- Fail: ∃ u ∈ (m, s'), ¬B(u)
          exact ⟨uf, (extendPoint_lt_iff m uf).mp hmu_fail,
            (extendPoint_lt_iff uf s').mp hus_fail,
            fun h => hB_fail ((ihB uf).mpr h)⟩
        · -- Init: ∃ u ∈ (m, s'), B on (m, u)
          exact ⟨ui, (extendPoint_lt_iff m ui).mp hmu_init,
            (extendPoint_lt_iff ui s').mp hus_init,
            fun v hmv hvu => (ihB v).mp (hB_init (extendPoint v)
              ((extendPoint_lt_iff m v).mpr hmv) ((extendPoint_lt_iff v ui).mpr hvu) ⟨v, rfl⟩)⟩
      · -- s = Sum.inr g (a gap)
        -- uf, ui ∈ g.val.cut since extendPoint uf/ui < Sum.inr g
        have huf_cut : uf ∈ g.val.cut := (extendPoint_le_gap_iff uf g).mp (le_of_lt hus_fail)
        have hui_cut : ui ∈ g.val.cut := (extendPoint_le_gap_iff ui g).mp (le_of_lt hus_init)
        -- gap cut cofinal: every element has a larger one in the cut
        have gap_cut_cofinal : ∀ (x : M.carrier), x ∈ g.val.cut → ∃ y, y ∈ g.val.cut ∧ x < y := by
          intro x hx; by_contra h_all; push Not at h_all
          exact g.val.no_sup ⟨x, ⟨h_all, fun b hb => hb hx⟩, hx⟩
        -- max(uf, ui) ∈ cut
        have hmax_cut : max uf ui ∈ g.val.cut := by
          rcases le_or_gt uf ui with h | h
          · simp only [max_eq_right h]; exact hui_cut
          · simp only [max_eq_left (le_of_lt h)]; exact huf_cut
        obtain ⟨y, hy_cut, hmax_y⟩ := gap_cut_cofinal (max uf ui) hmax_cut
        have huf_y : uf < y := lt_of_le_of_lt (le_max_left uf ui) hmax_y
        have hui_y : ui < y := lt_of_le_of_lt (le_max_right uf ui) hmax_y
        -- Use y as the bound in M.carrier
        have hm_y : m < y := lt_trans ((extendPoint_lt_iff m uf).mp hmu_fail) huf_y
        refine ⟨y, hm_y, ?_, ?_, ?_⟩
        · -- Body: ∀ u ∈ (m, y), disjunction
          intro u hmu huy
          -- u < y and y ∈ cut → u ∈ cut (downward_closed)
          have hu_cut : u ∈ g.val.cut := g.val.downward_closed y u hy_cut (le_of_lt huy)
          have hu_s : (extendPoint (sig := sig) (atomMap := atomMap) (r := r) u) < Sum.inr g :=
            lt_of_le_of_ne ((extendPoint_le_gap_iff u g).mpr hu_cut) (fun h => by cases h)
          have h_disj := h_body (extendPoint u)
            ((extendPoint_lt_iff m u).mpr hmu) hu_s (mu_holds_point u)
          cases h_disj with
          | inl h_cof =>
            left
            obtain ⟨v, huv, hmu_v, hBv⟩ := h_cof
            obtain ⟨xv, rfl⟩ := hmu_v
            exact ⟨xv, (extendPoint_lt_iff u xv).mp huv,
              fun w hmw hwv => (ihB w).mp (hBv (extendPoint w)
                ((extendPoint_lt_iff m w).mpr hmw) ((extendPoint_lt_iff w xv).mpr hwv) ⟨w, rfl⟩)⟩
          | inr h_take =>
            right
            obtain ⟨hA, v', hmv', hv'u, hmu_v', hBv'⟩ := h_take
            obtain ⟨xv', rfl⟩ := hmu_v'
            -- xv' < y because xv' < u < y... actually v' < u < s=gap.
            -- For A quantifier: ∀ v ∈ (u, s=gap) with mu → A. At M.carrier: ∀ v ∈ (u, y).
            -- v ∈ (u, y) → v ∈ cut → extendPoint v < Sum.inr g, so within (u, s).
            exact ⟨fun v huv hvy => by
                have hv_cut : v ∈ g.val.cut := g.val.downward_closed y v hy_cut (le_of_lt hvy)
                have hv_s : (extendPoint (sig := sig) (atomMap := atomMap) (r := r) v) < Sum.inr
                    g :=
                  lt_of_le_of_ne ((extendPoint_le_gap_iff v g).mpr hv_cut) (fun h => by cases h)
                exact (ihA v).mp (hA (extendPoint v)
                  ((extendPoint_lt_iff u v).mpr huv) hv_s ⟨v, rfl⟩),
              xv', (extendPoint_lt_iff m xv').mp hmv',
                (extendPoint_lt_iff xv' u).mp hv'u,
                fun h => hBv' ((ihB xv').mpr h)⟩
        · -- Fail
          exact ⟨uf, (extendPoint_lt_iff m uf).mp hmu_fail, huf_y,
            fun h => hB_fail ((ihB uf).mpr h)⟩
        · -- Init
          exact ⟨ui, (extendPoint_lt_iff m ui).mp hmu_init, hui_y,
            fun v hmv hvu => (ihB v).mp (hB_init (extendPoint v)
              ((extendPoint_lt_iff m v).mpr hmv) ((extendPoint_lt_iff v ui).mpr hvu) ⟨v, rfl⟩)⟩
    · -- mpr: standard → mu-relativized
      intro ⟨s, hms, h_body, ⟨uf, hmuf, hufs, hBuf⟩, ⟨ui, hmui, huis, hBui⟩⟩
      -- Use extendPoint s as the witness (s is an actual point, NOT mu-restricted)
      refine ⟨extendPoint s, (extendPoint_lt_iff m s).mpr hms, ?_, ?_, ?_⟩
      · -- Body
        intro u hmu hus hmu_holds
        obtain ⟨u', rfl⟩ := hmu_holds
        have hmu' : m < u' := (extendPoint_lt_iff m u').mp hmu
        have hus' : u' < s := (extendPoint_lt_iff u' s).mp hus
        have h_disj := h_body u' hmu' hus'
        cases h_disj with
        | inl h =>
          left
          obtain ⟨v, huv, hBv⟩ := h
          exact ⟨extendPoint v, (extendPoint_lt_iff u' v).mpr huv, ⟨v, rfl⟩,
            fun w hmw hwv hw_mu => by
              obtain ⟨w', rfl⟩ := hw_mu
              exact (ihB w').mpr (hBv w' ((extendPoint_lt_iff m w').mp hmw)
                ((extendPoint_lt_iff w' v).mp hwv))⟩
        | inr h =>
          right
          obtain ⟨hA, v', hmv', hv'u, hBv'⟩ := h
          exact ⟨fun v huv hvs hv_mu => by
              obtain ⟨v', rfl⟩ := hv_mu
              exact (ihA v').mpr (hA v' ((extendPoint_lt_iff u' v').mp huv)
                ((extendPoint_lt_iff v' s).mp hvs)),
            extendPoint v', (extendPoint_lt_iff m v').mpr hmv',
              (extendPoint_lt_iff v' u').mpr hv'u, ⟨v', rfl⟩,
              fun h => hBv' ((ihB v').mp h)⟩
      · -- Fail
        exact ⟨extendPoint uf, (extendPoint_lt_iff m uf).mpr hmuf,
          (extendPoint_lt_iff uf s).mpr hufs, ⟨uf, rfl⟩,
          fun h => hBuf ((ihB uf).mp h)⟩
      · -- Init
        exact ⟨extendPoint ui, (extendPoint_lt_iff m ui).mpr hmui,
          (extendPoint_lt_iff ui s).mpr huis, ⟨ui, rfl⟩,
          fun v hmv hvu hv_mu => by
            obtain ⟨v', rfl⟩ := hv_mu
            exact (ihB v').mpr (hBui v' ((extendPoint_lt_iff m v').mp hmv)
              ((extendPoint_lt_iff v' ui).mp hvu))⟩
  | stavi_snce A B ihA ihB =>
    simp only [StaviTemporalTruthMu, StaviTemporalTruth]
    constructor
    · -- mp: mu-relativized → standard (past dual)
      intro ⟨s, hsm, h_body, ⟨u_fail, hsu_fail, hum_fail, hmu_fail_mu, hB_fail⟩,
             ⟨u_init, hsu_init, hum_init, hmu_init_mu, hB_init⟩⟩
      obtain ⟨uf, rfl⟩ := hmu_fail_mu
      obtain ⟨ui, rfl⟩ := hmu_init_mu
      rcases s with s' | g
      · -- s = extendPoint s'
        have hs'm : s' < m := (extendPoint_lt_iff s' m).mp hsm
        refine ⟨s', hs'm, ?_, ?_, ?_⟩
        · intro u hsu hum
          have h_disj := h_body (extendPoint u) ((extendPoint_lt_iff s' u).mpr hsu)
            ((extendPoint_lt_iff u m).mpr hum) ⟨u, rfl⟩
          cases h_disj with
          | inl h =>
            left
            obtain ⟨v, hvu, hv_mu, hBv⟩ := h
            obtain ⟨v', rfl⟩ := hv_mu
            exact ⟨v', (extendPoint_lt_iff v' u).mp hvu,
              fun w hvw hwm => (ihB w).mp (hBv (extendPoint w)
                ((extendPoint_lt_iff v' w).mpr hvw) ((extendPoint_lt_iff w m).mpr hwm) ⟨w, rfl⟩)⟩
          | inr h =>
            right
            obtain ⟨hA, v', huv', hv'm, hv'_mu, hBv'⟩ := h
            obtain ⟨v'', rfl⟩ := hv'_mu
            exact ⟨fun v hsv hvu => (ihA v).mp (hA (extendPoint v)
                ((extendPoint_lt_iff s' v).mpr hsv) ((extendPoint_lt_iff v u).mpr hvu) ⟨v, rfl⟩),
              v'', (extendPoint_lt_iff u v'').mp huv', (extendPoint_lt_iff v'' m).mp hv'm,
              fun h => hBv' ((ihB v'').mpr h)⟩
        · exact ⟨uf, (extendPoint_lt_iff s' uf).mp hsu_fail,
            (extendPoint_lt_iff uf m).mp hum_fail,
            fun h => hB_fail ((ihB uf).mpr h)⟩
        · exact ⟨ui, (extendPoint_lt_iff s' ui).mp hsu_init,
            (extendPoint_lt_iff ui m).mp hum_init,
            fun v huv hvm => (ihB v).mp (hB_init (extendPoint v)
              ((extendPoint_lt_iff ui v).mpr huv) ((extendPoint_lt_iff v m).mpr hvm) ⟨v, rfl⟩)⟩
      · -- s = Sum.inr g (gap) — find s' in complement below m
        -- uf, ui ∉ g.val.cut since Sum.inr g < extendPoint uf/ui
        have huf_not_cut : uf ∉ g.val.cut := by
          intro h; exact not_lt.mpr ((extendPoint_le_gap_iff uf g).mpr h) hsu_fail
        have hui_not_cut : ui ∉ g.val.cut := by
          intro h; exact not_lt.mpr ((extendPoint_le_gap_iff ui g).mpr h) hsu_init
        -- complement_no_min → ∃ z < uf/ui ∉ cut
        have compl_no_min := g.val.complement_no_min
        have ⟨z₁, hz₁_not_cut, hz₁_uf⟩ : ∃ z, z ∉ g.val.cut ∧ z < uf := by
          by_contra h_all; push Not at h_all
          exact compl_no_min ⟨uf, huf_not_cut, fun y hy => h_all y hy⟩
        have ⟨z₂, hz₂_not_cut, hz₂_ui⟩ : ∃ z, z ∉ g.val.cut ∧ z < ui := by
          by_contra h_all; push Not at h_all
          exact compl_no_min ⟨ui, hui_not_cut, fun y hy => h_all y hy⟩
        have hmin_not_cut : min z₁ z₂ ∉ g.val.cut := by
          rcases le_or_gt z₁ z₂ with h | h
          · simp only [min_eq_left h]; exact hz₁_not_cut
          · simp only [min_eq_right (le_of_lt h)]; exact hz₂_not_cut
        -- Use s' = min z₁ z₂
        have hs'm : min z₁ z₂ < m := by
          calc min z₁ z₂ ≤ z₁ := min_le_left z₁ z₂
            _ < uf := hz₁_uf
            _ < m := (extendPoint_lt_iff uf m).mp hum_fail
        refine ⟨min z₁ z₂, hs'm, ?_, ?_, ?_⟩
        · -- Body: ∀ u ∈ (min z₁ z₂, m), disjunction
          intro u hsu hum
          -- u > min z₁ z₂, min ∉ cut → u ∉ cut → Sum.inr g < extendPoint u
          have hu_not_cut : u ∉ g.val.cut := by
            intro hu_in
            exact hmin_not_cut (g.val.downward_closed u (min z₁ z₂) hu_in (le_of_lt hsu))
          have hu_above_g : @LT.lt (ExtendedCarrier M atomMap r)
              extendedLinearOrder.toLT (Sum.inr g) (Sum.inl u) :=
            ⟨hu_not_cut, fun h => hu_not_cut h⟩
          have h_disj := h_body (extendPoint u) hu_above_g
            ((extendPoint_lt_iff u m).mpr hum) (mu_holds_point u)
          cases h_disj with
          | inl h_cof =>
            left
            obtain ⟨v, hvu, hmu_v, hBv⟩ := h_cof
            obtain ⟨xv, rfl⟩ := hmu_v
            exact ⟨xv, (extendPoint_lt_iff xv u).mp hvu,
              fun w hvw hwm => (ihB w).mp (hBv (extendPoint w)
                ((extendPoint_lt_iff xv w).mpr hvw) ((extendPoint_lt_iff w m).mpr hwm) ⟨w, rfl⟩)⟩
          | inr h_take =>
            right
            obtain ⟨hA, v', huv', hv'm, hmu_v', hBv'⟩ := h_take
            obtain ⟨xv', rfl⟩ := hmu_v'
            exact ⟨fun v hsv hvu => by
                have hv_not_cut : v ∉ g.val.cut := by
                  intro hv_in
                  exact hmin_not_cut (g.val.downward_closed v (min z₁ z₂) hv_in (le_of_lt hsv))
                have hv_above_g : @LT.lt (ExtendedCarrier M atomMap r)
                    extendedLinearOrder.toLT (Sum.inr g) (Sum.inl v) :=
                  ⟨hv_not_cut, fun h => hv_not_cut h⟩
                exact (ihA v).mp (hA (extendPoint v) hv_above_g
                  ((extendPoint_lt_iff v u).mpr hvu) ⟨v, rfl⟩),
              xv', (extendPoint_lt_iff u xv').mp huv',
                (extendPoint_lt_iff xv' m).mp hv'm,
                fun h => hBv' ((ihB xv').mpr h)⟩
        · -- Fail
          exact ⟨uf, lt_of_le_of_lt (min_le_left z₁ z₂) hz₁_uf,
            (extendPoint_lt_iff uf m).mp hum_fail,
            fun h => hB_fail ((ihB uf).mpr h)⟩
        · -- Init
          exact ⟨ui, lt_of_le_of_lt (min_le_right z₁ z₂) hz₂_ui,
            (extendPoint_lt_iff ui m).mp hum_init,
            fun v hvu hvm => (ihB v).mp (hB_init (extendPoint v)
              ((extendPoint_lt_iff ui v).mpr hvu) ((extendPoint_lt_iff v m).mpr hvm) ⟨v, rfl⟩)⟩
    · -- mpr: standard → mu-relativized
      intro ⟨s, hsm, h_body, ⟨uf, hsuf, hufm, hBuf⟩, ⟨ui, hsui, huim, hBui⟩⟩
      refine ⟨extendPoint s, (extendPoint_lt_iff s m).mpr hsm, ?_, ?_, ?_⟩
      · intro u hsu hum hmu_holds
        obtain ⟨u', rfl⟩ := hmu_holds
        have hsu' : s < u' := (extendPoint_lt_iff s u').mp hsu
        have hu'm : u' < m := (extendPoint_lt_iff u' m).mp hum
        have h_disj := h_body u' hsu' hu'm
        cases h_disj with
        | inl h =>
          left
          obtain ⟨v, hvu, hBv⟩ := h
          exact ⟨extendPoint v, (extendPoint_lt_iff v u').mpr hvu, ⟨v, rfl⟩,
            fun w hvw hwm hw_mu => by
              obtain ⟨w', rfl⟩ := hw_mu
              exact (ihB w').mpr (hBv w' ((extendPoint_lt_iff v w').mp hvw)
                ((extendPoint_lt_iff w' m).mp hwm))⟩
        | inr h =>
          right
          obtain ⟨hA, v', hu'v', hv'm, hBv'⟩ := h
          exact ⟨fun v hsv hvu hv_mu => by
              obtain ⟨v', rfl⟩ := hv_mu
              exact (ihA v').mpr (hA v' ((extendPoint_lt_iff s v').mp hsv)
                ((extendPoint_lt_iff v' u').mp hvu)),
            extendPoint v', (extendPoint_lt_iff u' v').mpr hu'v',
              (extendPoint_lt_iff v' m).mpr hv'm, ⟨v', rfl⟩,
              fun h => hBv' ((ihB v').mp h)⟩
      · exact ⟨extendPoint uf, (extendPoint_lt_iff s uf).mpr hsuf,
          (extendPoint_lt_iff uf m).mpr hufm, ⟨uf, rfl⟩,
          fun h => hBuf ((ihB uf).mp h)⟩
      · exact ⟨extendPoint ui, (extendPoint_lt_iff s ui).mpr hsui,
          (extendPoint_lt_iff ui m).mpr huim, ⟨ui, rfl⟩,
          fun v huv hvm hv_mu => by
            obtain ⟨v', rfl⟩ := hv_mu
            exact (ihB v').mpr (hBui v' ((extendPoint_lt_iff ui v').mp huv)
              ((extendPoint_lt_iff v' m).mp hvm))⟩
  | std_untl A B ihA ihB =>
    -- Standard Until at an actual point: same structure as temporal_truth_mu_at_point untl case
    simp only [StaviTemporalTruthMu, StaviTemporalTruth]
    constructor
    · intro ⟨s, hms, hmu, hAs, hBu⟩
      obtain ⟨s', rfl⟩ := hmu
      have hms' : m < s' := (extendPoint_lt_iff m s').mp hms
      exact ⟨s', hms', (ihA s').mp hAs, fun u hmu' hus =>
        (ihB u).mp (hBu (extendPoint u) ((extendPoint_lt_iff m u).mpr hmu')
          ((extendPoint_lt_iff u s').mpr hus) ⟨u, rfl⟩)⟩
    · intro ⟨s, hms, hAs, hBu⟩
      refine ⟨extendPoint s, (extendPoint_lt_iff m s).mpr hms, ⟨s, rfl⟩,
        (ihA s).mpr hAs, fun u hmu hus hmu_holds => ?_⟩
      obtain ⟨u', rfl⟩ := hmu_holds
      exact (ihB u').mpr (hBu u' ((extendPoint_lt_iff m u').mp hmu)
        ((extendPoint_lt_iff u' s).mp hus))
  | std_snce A B ihA ihB =>
    -- Standard Since at an actual point: same structure as temporal_truth_mu_at_point snce case
    simp only [StaviTemporalTruthMu, StaviTemporalTruth]
    constructor
    · intro ⟨s, hsm, hmu, hAs, hBu⟩
      obtain ⟨s', rfl⟩ := hmu
      have hsm' : s' < m := (extendPoint_lt_iff s' m).mp hsm
      exact ⟨s', hsm', (ihA s').mp hAs, fun u hsu hum =>
        (ihB u).mp (hBu (extendPoint u) ((extendPoint_lt_iff s' u).mpr hsu)
          ((extendPoint_lt_iff u m).mpr hum) ⟨u, rfl⟩)⟩
    · intro ⟨s, hsm, hAs, hBu⟩
      refine ⟨extendPoint s, (extendPoint_lt_iff s m).mpr hsm, ⟨s, rfl⟩,
        (ihA s).mpr hAs, fun u hsu hum hmu_holds => ?_⟩
      obtain ⟨u', rfl⟩ := hmu_holds
      exact (ihB u').mpr (hBu u' ((extendPoint_lt_iff s u').mp hsu)
        ((extendPoint_lt_iff u' m).mp hum))

end FormalSystem.Metalogic.Expressiveness
