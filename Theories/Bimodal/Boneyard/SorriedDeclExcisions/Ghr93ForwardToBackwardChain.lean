import Bimodal.Metalogic.WeakCanonical.Expressiveness.SplitPoint
import Bimodal.Metalogic.WeakCanonical.EFGames.Composition
import Bimodal.Metalogic.WeakCanonical.EFGames.CharacteristicFormula
import Mathlib.Data.Fin.Tuple.Sort
import Bimodal.Metalogic.WeakCanonical.Expressiveness.CaseAnalysis

/-!
# ARCHIVED (Boneyard) — never compiled.

Dead ghr93 forward-to-backward closure: 7 declarations carrying 7
statement-position sorries, with zero external call sites (every consumer of
each declaration below is itself a member of this closure;
`ghr93_forward_to_backward_rank_varying` had no consumers at all).

From `Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`:
- `gap_cut_exists_gt`
- `ghr93_cases_III_IV` (contains all 7 sorries)
- `ghr93_cases_II_III_IV`
- `ghr93_inductive_step`

From `Metalogic/WeakCanonical/Expressiveness/Theorem6.lean`:
- `ghr93_forward_to_backward_core`
- `ghr93_forward_to_backward`
- `ghr93_forward_to_backward_rank_varying`

The live entry points `ghr93_case_I` / `ghr93_case_II` (CaseAnalysis.lean) and
the distinct, live `ghr93_inductive_step_discrete` (Transfer.lean) remain in
live code and are NOT part of this closure.

Do not import from live code.
-/

#exit

/- ======================================================================
   Source: Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean
   Original context: `namespace Bimodal.Metalogic.WeakCanonical`,
   `open Bimodal.Syntax`, `set_option maxHeartbeats 800000`.
   ====================================================================== -/

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
private theorem ghr93_cases_III_IV {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
                   (rank_embed (by omega : r' ≤ r' + 2) y₁'))
    (h_mono : Monotone a_bwd)
    (ih : ∀ {x₀ y₀ : ExtendedCarrier M atomMap r}
            {x₀' y₀' : ExtendedCarrier N atomMap r},
          x₀ ≤ y₀ → x₀' ≤ y₀' →
          (∃ p, inClosedInterval x₀' y₀' (extendPoint p)) →
          ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x₀ y₀ x₀' y₀' →
          ghr93_duplicator_wins N M atomMap n r x₀' y₀' x₀ y₀) :
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
  -- Phase R3: Project tau from rank r+delta to rank r via rank_down.
  have tau_r : ghr93_duplicator_wins N M atomMap n r d y' c y :=
    ghr93_duplicator_wins_rank_down (by omega : r ≤ r + delta)
      (by omega : r + 2 ≤ r + delta) props.hdy' props.hcy props.tau
  have h_tau_app : ∃ (resp_tau : Fin n → ExtendedCarrier M atomMap r),
      (∀ k, inClosedInterval c y (resp_tau k)) ∧
      ∀ (b_sp : M.carrier), inClosedInterval c y (extendPoint b_sp) →
        ∃ (b_resp : N.carrier), inClosedInterval d y' (extendPoint b_resp) ∧
          ghr93_winning_condition n
            (game_tuple d y' a_init b_resp)
            (game_tuple c y resp_tau b_sp) := tau_r a_init ha_init
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
          -- Phase R3: Project tau to 0-round rank-r game via round_mono.
          have h_tau_0 : ghr93_duplicator_wins N M atomMap 0 r d y' c y :=
            ghr93_duplicator_wins_round_mono (by omega : 0 ≤ n) props.hdy' props.hcy tau_r
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
          -- Phase R3: Project tau to 0-round rank-r game via round_mono.
          have h_tau_0 : ghr93_duplicator_wins N M atomMap 0 r d y' c y :=
            ghr93_duplicator_wins_round_mono (by omega : 0 ≤ n) props.hdy' props.hcy tau_r
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
          -- Phase R3: Project sigma to 0-round rank-r game via rank_down + round_mono.
          have sigma_r : ghr93_duplicator_wins N M atomMap n r x' d x c :=
            ghr93_duplicator_wins_rank_down (by omega : r ≤ r + delta)
              (by omega : r + 2 ≤ r + delta) props.hx'd props.hxc props.sigma
          have h_sigma_0 : ghr93_duplicator_wins N M atomMap 0 r x' d x c :=
            ghr93_duplicator_wins_round_mono (by omega : 0 ≤ n) props.hx'd props.hxc sigma_r
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
  -- Step 5b: Build IH-based sub-game on [x, y] × [x', y'] with n+1 rounds.
  -- Strategy: use the full-interval forward game + IH to get a backward game
  -- with n rounds. Then play it with a_init to get responses. The key insight
  -- is to use the IH on [x, y] × [x', y'] itself (not a sub-interval), which
  -- gives responses in [x, y] with all orderings relative to endpoints x,y.
  -- The gap position's orderings come from the fact that γ_M ∈ [x, y] and
  -- γ_N ∈ [x', y'] with the appropriate ordering correspondence.
  --
  -- Actually: the (1+3*n)-round forward game + IH gives an n-round backward game.
  -- But we need n+1 selections. We can use the n-round backward game for the
  -- first n selections and handle position n (the gap) separately.
  --
  -- Revised approach: Use the FULL interval forward game h_fwd_n1 (n+1 rounds)
  -- to get b_resp directly. Play h_fwd_n1 with a'_resp as M-selections,
  -- get N-responses, and then challenge with some N-carrier point to get
  -- the M-response b_sp_resp. But the game direction is wrong: h_fwd_n1 gives
  -- M-selections → N-responses → N-challenge → M-response.
  -- We need: N-selections (a_bwd) → M-responses (a'_resp) → M-challenge (b_sp) → N-response.
  -- This is the BACKWARD direction. The IH converts forward to backward.
  --
  -- Final approach: Apply IH to h_fwd_n1_ext (a (1+3*(n+1))-round forward game
  -- reduced to (1+3*(n+1)) rounds, then IH gives (n+1)-round backward game).
  -- But the IH parameter gives n rounds, not n+1!
  --
  -- The IH is for the PREVIOUS induction step: it converts (1+3*n)-round forward
  -- to n-round backward. We need (n+1)-round backward, which would need a
  -- (1+3*(n+1))-round forward game and an IH for n+1. We don't have that.
  --
  -- So we're stuck with n-round backward games. The proof MUST combine the
  -- n-round backward game (for positions 0..n-1) with separate handling for
  -- position n (the gap).
  --
  -- WORKING APPROACH: Use the IH-based sub-game on [x, γ_M] × [x', γ_N]
  -- for the first n positions, and handle position n and b_sp separately.
  -- For b_sp, case-split on b_sp ∈ γ_M.cut (below gap) vs b_sp ∉ γ_M.cut (above gap).
  -- For the γ vs y ordering, case-split on γ_N = y' vs γ_N < y'.
  --
  -- Ordering bounds.
  have hd_le_γN : d ≤ Sum.inr γ_N := hγ_N_eq ▸ h_no_split ⟨n, by omega⟩
  have hx'_le_γN : x' ≤ (Sum.inr γ_N : ExtendedCarrier N atomMap r) :=
    le_trans props.hx'd hd_le_γN
  have hγ_N_le_y' : @LE.le (ExtendedCarrier N atomMap r) _ (Sum.inr γ_N) y' := by
    have h := (ha_bwd ⟨n, by omega⟩).2
    rw [hγ_N_eq] at h; exact h
  -- a_init(k) ∈ [x', γ_N] for all k.
  have ha_init_sub : ∀ k, inClosedInterval x' (Sum.inr γ_N) (a_init k) := by
    intro k
    exact ⟨le_trans props.hx'd (h_no_split ⟨k.val, by omega⟩), by
      have : a_bwd ⟨k.val, by omega⟩ ≤ a_bwd ⟨n, by omega⟩ :=
        h_mono (Fin.mk_le_mk.mpr (by omega : k.val ≤ n))
      rw [hγ_N_eq] at this; exact this⟩
  -- Forward game at rank r on [x, γ_M] × [x', γ_N].
  have h_fwd_sub : ghr93_duplicator_wins M N atomMap (1 + 3 * n) r
      x (Sum.inr γ_M) x' (Sum.inr γ_N) :=
    ghr93_duplicator_wins_round_mono (by omega : 1 + 3 * n ≤ 4 + 3 * n)
      hγ_M_in.1 hx'_le_γN
      (ghr93_duplicator_wins_rank_down (by omega : r ≤ r + 2)
        (by omega : r + 2 ≤ r + 2) hγ_M_in.1 hx'_le_γN
        (h_r1_univ r hγ_M_in.1 hx'_le_γN))
  -- Case split on carrier point in [x', γ_N].
  by_cases h_pt_sub : ∃ (p : N.carrier), inClosedInterval x' (Sum.inr γ_N) (extendPoint p)
  case pos =>
    -- IH gives backward game on [x', γ_N] → [x, γ_M].
    have tau_sub : ghr93_duplicator_wins N M atomMap n r
        x' (Sum.inr γ_N) x (Sum.inr γ_M) :=
      ih hγ_M_in.1 hx'_le_γN h_pt_sub h_fwd_sub
    obtain ⟨resp_sub, hresp_sub_in, hwin_sub⟩ := tau_sub a_init ha_init_sub
    -- resp_sub(k) ∈ [x, γ_M].
    -- Define a'_resp using resp_sub.
    let a'_resp : Fin (n + 1) → ExtendedCarrier M atomMap r := fun i =>
      if h : i.val < n then resp_sub ⟨i.val, h⟩ else Sum.inr γ_M
    have ha'_resp_in : ∀ i, inClosedInterval x y (a'_resp i) := by
      intro i; simp only [a'_resp]; split
      case isTrue h =>
        exact ⟨(hresp_sub_in ⟨i.val, h⟩).1, le_trans (hresp_sub_in ⟨i.val, h⟩).2 hγ_M_in.2⟩
      case isFalse _ => exact hγ_M_in
    refine ⟨a'_resp, ha'_resp_in, ?_⟩
    intro b_sp hb_sp_in
    -- The winning condition proof for the (n+1)-game is assembled from:
    -- (A) Sub-game on [x', γ_N] × [x, γ_M] (for positions 0..n-1 and gap vs selections)
    -- (B) Gap detection (γ_M_form, γ_gp) (for formula/gp at gap position)
    -- (C) Interval containment (for y-endpoint orderings)
    -- (D) Forward game at y/y' (for formula/gp at y-endpoints)
    --
    -- The core difficulty (sel_gap_ord) is solved: resp_sub(k) ≤ γ_M from the sub-game.
    -- Infrastructure: full-interval forward game y/y' properties.
    have h_fwd_0 := ghr93_duplicator_wins_round_mono (by omega : 0 ≤ n + 1) hxy hx'y' props.h_fwd_n1
    obtain ⟨_, _, hwin_0⟩ := h_fwd_0 (fun i => Fin.elim0 i) (fun i => Fin.elim0 i)
    obtain ⟨p_0, hp_0⟩ := h_pt_sub
    obtain ⟨_, _, ⟨hord_0, hgp_0, hform_0⟩⟩ := hwin_0 p_0 ⟨hp_0.1, le_trans hp_0.2 hγ_N_le_y'⟩
    have hgp_yy' : (IsPoint y ↔ IsPoint y') ∧ (IsGap y ↔ IsGap y') := by
      have h := hgp_0 ⟨0 + 2, by omega⟩; simp only [game_tuple_y_eq] at h; exact h
    have hform_yy' : ∀ A, stavi_depth A ≤ r →
        (stavi_temporal_truth_mu M atomMap r y A ↔
         stavi_temporal_truth_mu N atomMap r y' A) := by
      intro A hA; have h := hform_0 ⟨0 + 2, by omega⟩ A hA
      simp only [game_tuple_y_eq] at h; exact h
    have hord_xy : (x < y ↔ x' < y') ∧ (x = y ↔ x' = y') := by
      have h := hord_0 ⟨0, by omega⟩ ⟨0 + 2, by omega⟩
      simp only [game_tuple_zero_eq, game_tuple_y_eq] at h; exact h
    -- Infrastructure: γ_N = y' → γ_M = y.
    have hγ_eq_endpoint : (Sum.inr γ_N : ExtendedCarrier N atomMap r) = y' →
        (Sum.inr γ_M : ExtendedCarrier M atomMap r) = y := by sorry
    -- Infrastructure: γ_N < y' → carrier point in [γ_N, y'].
    have h_pt_upper_of_lt : @LT.lt (ExtendedCarrier N atomMap r) _ (Sum.inr γ_N) y' →
        ∃ (p : N.carrier), inClosedInterval (Sum.inr γ_N) y' (extendPoint p) := by
      sorry -- Same argument as case neg branch (lines 3448-3460): isPoint_or_isGap y'
    -- Infrastructure: γ_N < y' → γ_M < y (from upper forward game).
    have hγ_lt_of_lt : @LT.lt (ExtendedCarrier N atomMap r) _ (Sum.inr γ_N) y' →
        @LT.lt (ExtendedCarrier M atomMap r) _ (Sum.inr γ_M) y := by sorry
    -- Case split on b_sp ≤ γ_M.
    by_cases hb_le_γM : extendPoint b_sp ≤ (Sum.inr γ_M : ExtendedCarrier M atomMap r)
    · -- Case A: b_sp ≤ γ_M. Use sub-game.
      have hb_sp_sub : inClosedInterval x (Sum.inr γ_M) (extendPoint b_sp) :=
        ⟨hb_sp_in.1, hb_le_γM⟩
      obtain ⟨b_resp, hb_resp_in, hcond_sub⟩ := hwin_sub b_sp hb_sp_sub
      obtain ⟨hord_sub, hgp_sub, hform_sub⟩ := hcond_sub
      have hb_resp_xy : inClosedInterval x' y' (extendPoint b_resp) :=
        ⟨hb_resp_in.1, le_trans hb_resp_in.2 hγ_N_le_y'⟩
      have hb_resp_lt_γN : @extendPoint sig N atomMap r b_resp < Sum.inr γ_N :=
        lt_of_le_of_ne hb_resp_in.2 (by simp [extendPoint])
      have hb_sp_lt_γM : @extendPoint sig M atomMap r b_sp < Sum.inr γ_M :=
        lt_of_le_of_ne hb_le_γM (by simp [extendPoint])
      have hb_resp_lt_y' : @extendPoint sig N atomMap r b_resp < y' :=
        lt_of_lt_of_le hb_resp_lt_γN hγ_N_le_y'
      have hb_sp_lt_y : @extendPoint sig M atomMap r b_sp < y :=
        lt_of_lt_of_le hb_sp_lt_γM hγ_M_in.2
      refine ⟨b_resp, hb_resp_xy, ?_, ?_, ?_⟩
      · -- same_order_type
        sorry
      · -- gap_point_agreement
        sorry
      · -- formula_agreement
        sorry
    · -- Case B: b_sp > γ_M. Use fresh upper sub-game.
      push_neg at hb_le_γM
      have hγ_M_lt_y : @LT.lt (ExtendedCarrier M atomMap r) _ (Sum.inr γ_M) y :=
        lt_of_lt_of_le hb_le_γM hb_sp_in.2
      have hγ_N_lt_y' : @LT.lt (ExtendedCarrier N atomMap r) _ (Sum.inr γ_N) y' := by
        rcases lt_or_eq_of_le hγ_N_le_y' with h_lt | h_eq
        · exact h_lt
        · exfalso; have h_eq_M := hγ_eq_endpoint h_eq; rw [h_eq_M] at hγ_M_lt_y
          exact lt_irrefl _ hγ_M_lt_y
      sorry
  case neg =>
    -- No carrier point in [x', γ_N]. Then x' = Sum.inr γ_N (degenerate).
    -- All a_bwd(k) = Sum.inr γ_N, d = Sum.inr γ_N, and c is a corresponding gap.
    push_neg at h_pt_sub
    -- x' = Sum.inr γ_N: any carrier point p with x' ≤ extendPoint p ≤ Sum.inr γ_N
    -- would satisfy h_pt_sub, contradiction. So no carrier point exists in this interval.
    -- Since d ≤ Sum.inr γ_N and x' ≤ d, all carrier points in γ_N.cut are below x'.
    -- This means x' is a gap ≥ Sum.inr γ_N. Combined with x' ≤ Sum.inr γ_N, x' = Sum.inr γ_N.
    have hx'_eq_γN : x' = (Sum.inr γ_N : ExtendedCarrier N atomMap r) := by
      by_contra h_ne
      have hx'_lt : x' < (Sum.inr γ_N : ExtendedCarrier N atomMap r) := lt_of_le_of_ne hx'_le_γN h_ne
      -- γ_N has a nonempty cut. Find a carrier point in [x', γ_N].
      rcases isPoint_or_isGap x' with ⟨p_x', hp_eq⟩ | ⟨g_x', hg_eq⟩
      · -- x' is a point. Then p_x' ∈ γ_N.cut (since x' < γ_N) and extendPoint p_x' = x' ≥ x'.
        have : inClosedInterval x' (Sum.inr γ_N) (extendPoint p_x') :=
          ⟨by rw [extendPoint, hp_eq], by rw [extendPoint]; exact le_of_lt (hp_eq ▸ hx'_lt)⟩
        exact h_pt_sub p_x' this
      · -- x' is a gap g_x'. Since x' < γ_N, g_x'.cut ⊊ γ_N.cut.
        have h_sub : g_x'.val.cut ⊆ γ_N.val.cut := by rw [hg_eq] at hx'_lt; exact le_of_lt hx'_lt
        have h_ne_cut : g_x'.val.cut ≠ γ_N.val.cut := by
          intro heq; have := gap_ext g_x'.val γ_N.val heq
          exact h_ne (by rw [hg_eq]; exact congr_arg Sum.inr (Subtype.ext this))
        obtain ⟨m₀, hm₀_in, hm₀_not⟩ := Set.not_subset.mp (fun h => h_ne_cut
          (Set.Subset.antisymm h_sub h))
        have hm₀_in_interval : inClosedInterval x' (Sum.inr γ_N) (extendPoint m₀) := by
          constructor
          · rw [hg_eq]
            exact le_of_lt (lt_of_not_ge (fun h => hm₀_not ((extendPoint_le_gap_iff m₀ g_x').mp h)))
          · exact (extendPoint_le_gap_iff m₀ γ_N).mpr hm₀_in
        exact h_pt_sub m₀ hm₀_in_interval
    -- Now x' = Sum.inr γ_N. So d = Sum.inr γ_N and all a_bwd(k) = Sum.inr γ_N.
    have hd_eq_γN : d = Sum.inr γ_N := le_antisymm hd_le_γN (hx'_eq_γN ▸ props.hx'd)
    have ha_bwd_all_γN : ∀ i, a_bwd i = Sum.inr γ_N := by
      intro i
      have h1 : d ≤ a_bwd i := h_no_split i
      have h2 : a_bwd i ≤ a_bwd ⟨n, by omega⟩ := h_mono (Fin.le_last i)
      rw [hγ_N_eq] at h2; rw [hd_eq_γN] at h1
      exact le_antisymm h2 h1
    -- c is a gap corresponding to d = γ_N.
    have hc_gap : IsGap c := props.hcd_gp.2.mpr ⟨γ_N, hd_eq_γN⟩
    obtain ⟨g_c, hc_eq⟩ := hc_gap
    -- g_c has the same formulas as γ_N (from hcd_form).
    have hgc_form : ∀ (A : StaviFormula), stavi_depth A ≤ r →
        (stavi_temporal_truth_mu M atomMap r (Sum.inr g_c) A ↔
         stavi_temporal_truth_mu N atomMap r (Sum.inr γ_N) A) := by
      intro A hA; rw [← hc_eq]; rw [← hd_eq_γN]; exact props.hcd_form A hA
    -- Use g_c as the M-gap (it has the same properties as γ_M but is at position c).
    -- All resp_tau are at c = Sum.inr g_c (since the tau game on [d, y'] = [γ_N, y'] → [c, y]
    -- with d = γ_N and all selections = γ_N gives all responses = c).
    -- The tau game with all-identical selections gives all-identical responses.
    have hresp_tau_all_c : ∀ k, resp_tau k = c := by
      intro k
      -- resp_tau(k) ∈ [c, y]. And from the tau ordering:
      -- resp_tau(k) < resp_tau(k') ↔ a_init(k) < a_init(k').
      -- Since all a_init(k) = Sum.inr γ_N (identical), the RHS is always false.
      -- So resp_tau(k) = resp_tau(k') for all k, k'. And resp_tau(k) ∈ [c, y].
      -- From the tau ordering at (1+k, 0): c < resp_tau(k) ↔ d < a_init(k).
      -- d = Sum.inr γ_N = a_init(k), so d < a_init(k) is false. So c < resp_tau(k) is false.
      -- So resp_tau(k) ≤ c. Combined with resp_tau(k) ≥ c (from [c, y]): resp_tau(k) = c.
      have h_lower := (hresp_tau_in k).1  -- c ≤ resp_tau(k)
      -- Need resp_tau(k) ≤ c. Use tau ordering.
      -- Get the tau winning condition by challenging with some carrier point.
      -- Since all a_init are identical (= Sum.inr γ_N), the tau game's orderings
      -- force all resp_tau to be identical. But we need a carrier point in [c, y] to challenge.
      rcases props.h_pt_cy with ⟨p_cy, hp_cy⟩ | ⟨hcy_eq, _, _, _⟩
      · obtain ⟨b_tau, _, hcond_tau⟩ := hwin_tau p_cy hp_cy
        obtain ⟨hord_tau, _, _⟩ := hcond_tau
        -- From tau ordering at (0, 1+k): d < a_init(k) ↔ c < resp_tau(k).
        have h := (hord_tau ⟨0, by omega⟩ ⟨1 + k.val, by omega⟩).1
        simp only [game_tuple_zero_eq, game_tuple_sel_eq] at h
        -- d < a_init(k) is d < Sum.inr γ_N = d, i.e., d < d. False.
        have h_ainit_eq : a_init k = Sum.inr γ_N := ha_bwd_all_γN ⟨k.val, by omega⟩
        have h_not_d : ¬(d < a_init k) := by rw [h_ainit_eq, hd_eq_γN]; exact lt_irrefl _
        have h_not_c : ¬(c < resp_tau k) := fun h_lt => h_not_d (h.mpr h_lt)
        exact le_antisymm (not_lt.mp h_not_c) h_lower
      · -- c = y. Since resp_tau(k) ∈ [c, y] = [y, y], resp_tau(k) = c.
        exact le_antisymm (hcy_eq ▸ (hresp_tau_in k).2) h_lower
    -- Now all resp_tau(k) = c = Sum.inr g_c.
    -- DEGENERATE KEY: x = c (sigma on {γ_N} × [x,c] has no carrier response).
    have hxc_eq : x = c := by
      rcases props.h_pt_xc with ⟨p_xc, hp_xc⟩ | ⟨hxc_eq, _, _, _⟩
      · have sigma_r := ghr93_duplicator_wins_rank_down (by omega : r ≤ r + delta)
            (by omega : r + 2 ≤ r + delta) props.hx'd props.hxc props.sigma
        have h_sig_0 := ghr93_duplicator_wins_round_mono (by omega : 0 ≤ n)
            props.hx'd props.hxc sigma_r
        obtain ⟨_, _, hwin_sig0⟩ := h_sig_0 (fun i => Fin.elim0 i) (fun i => Fin.elim0 i)
        obtain ⟨b_sig, hb_sig_in, _⟩ := hwin_sig0 p_xc hp_xc
        exact absurd (le_antisymm (hd_eq_γN ▸ hb_sig_in.2) (hx'_eq_γN ▸ hb_sig_in.1) :
          (extendPoint b_sig : ExtendedCarrier N atomMap r) = Sum.inr γ_N) (by simp [extendPoint])
      · exact hxc_eq
    -- All M-responses = c = x (constant). Matches N-side all = γ_N = x'.
    let a'_resp : Fin (n + 1) → ExtendedCarrier M atomMap r := fun _ => c
    have ha'_resp_in : ∀ i, inClosedInterval x y (a'_resp i) :=
      fun _ => ⟨le_of_eq hxc_eq, props.hcy⟩
    refine ⟨a'_resp, ha'_resp_in, ?_⟩
    intro b_sp hb_sp_in
    -- b_sp ∈ [x, y] = [c, y], so tau applies directly.
    have hb_sp_cy : inClosedInterval c y (extendPoint b_sp) := hxc_eq ▸ hb_sp_in
    obtain ⟨b_resp, hb_resp_in, hcond_tau⟩ := hwin_tau b_sp hb_sp_cy
    obtain ⟨hord_tau_d, hgp_tau_d, hform_tau_d⟩ := hcond_tau
    have hb_resp_xy : inClosedInterval x' y' (extendPoint b_resp) :=
      ⟨hx'_eq_γN ▸ (hd_eq_γN ▸ hb_resp_in.1), hb_resp_in.2⟩
    refine ⟨b_resp, hb_resp_xy, ?_, ?_, ?_⟩
    · -- same_order_type: All N-side selections = x' (= Sum.inr γ_N), all M-side = c (= x).
      -- Extract tau orderings between the 3 distinct values: d/c, b_resp/b_sp, y'/y.
      have h_tau_db : (d < extendPoint b_resp ↔ c < extendPoint b_sp) ∧
          (d = extendPoint b_resp ↔ c = extendPoint b_sp) := by
        have h := hord_tau_d ⟨0, by omega⟩ ⟨n + 1, by omega⟩
        simp only [game_tuple_zero_eq, game_tuple_b_eq] at h; exact h
      have h_tau_dy : (d < y' ↔ c < y) ∧ (d = y' ↔ c = y) := by
        have h := hord_tau_d ⟨0, by omega⟩ ⟨n + 2, by omega⟩
        simp only [game_tuple_zero_eq, game_tuple_y_eq] at h; exact h
      have h_tau_by : (extendPoint b_resp < y' ↔ extendPoint b_sp < y) ∧
          (extendPoint b_resp = y' ↔ extendPoint b_sp = y) := by
        have h := hord_tau_d ⟨n + 1, by omega⟩ ⟨n + 2, by omega⟩
        simp only [game_tuple_b_eq, game_tuple_y_eq] at h; exact h
      -- Rewrite x' = d and x = c to use tau orderings directly.
      -- For same_order_type_of_cases, we need 7 arguments with a = a'_resp (M), a' = a_bwd (N).
      -- The issue is that a'_resp(k) = c doesn't unfold, so we use `change`.
      -- Use same_order_type_of_cases. In the backward direction:
      -- M of same_order_type_of_cases = N (our x'/y'/a_bwd/b_resp),
      -- N of same_order_type_of_cases = M (our x/y/a'_resp/b_sp).
      -- Rewrite x' = d and x = c to use tau orderings directly.
      -- Use same_order_type_of_cases with explicit N/M swap for backward direction.
      -- All orderings derive from tau (d=x', c=x) + sel=d/c identity.
      have hxb : (x' < @extendPoint sig N atomMap r b_resp ↔ x < @extendPoint sig M atomMap r b_sp) ∧
          (x' = @extendPoint sig N atomMap r b_resp ↔ x = @extendPoint sig M atomMap r b_sp) :=
        hx'_eq_γN ▸ hxc_eq ▸ hd_eq_γN ▸ h_tau_db
      have hxy : (x' < y' ↔ x < y) ∧ (x' = y' ↔ x = y) :=
        hx'_eq_γN ▸ hxc_eq ▸ hd_eq_γN ▸ h_tau_dy
      have hsel_x : ∀ k : Fin (n + 1),
          (x' < a_bwd k ↔ x < a'_resp k) ∧ (x' = a_bwd k ↔ x = a'_resp k) := by
        intro k; rw [ha_bwd_all_γN k, hx'_eq_γN, hxc_eq]
        exact ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
               ⟨fun _ => rfl, fun _ => rfl⟩⟩
      have hsel_b : ∀ k : Fin (n + 1),
          (@extendPoint sig N atomMap r b_resp < a_bwd k ↔
           @extendPoint sig M atomMap r b_sp < a'_resp k) ∧
          (@extendPoint sig N atomMap r b_resp = a_bwd k ↔
           @extendPoint sig M atomMap r b_sp = a'_resp k) := by
        intro k; rw [ha_bwd_all_γN k]
        exact order_reverse (hd_eq_γN ▸ h_tau_db)
      have hsel_y : ∀ k : Fin (n + 1),
          (y' < a_bwd k ↔ y < a'_resp k) ∧ (y' = a_bwd k ↔ y = a'_resp k) := by
        intro k; rw [ha_bwd_all_γN k]
        exact order_reverse (hd_eq_γN ▸ h_tau_dy)
      have hsel_sel : ∀ k k' : Fin (n + 1),
          (a_bwd k < a_bwd k' ↔ a'_resp k < a'_resp k') ∧
          (a_bwd k = a_bwd k' ↔ a'_resp k = a'_resp k') := by
        intro k k'; rw [ha_bwd_all_γN k, ha_bwd_all_γN k']
        exact ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
               ⟨fun _ => rfl, fun _ => rfl⟩⟩
      exact @same_order_type_of_cases sig N M atomMap r (n + 1) x' y' a_bwd b_resp x y a'_resp b_sp
        hxb hxy h_tau_by hsel_x hsel_b hsel_y hsel_sel
    · -- gap_point_agreement (backward: N first, M second)
      exact gap_point_agreement_of_cases
        (by rw [hx'_eq_γN]
            show (IsPoint (Sum.inr γ_N) ↔ IsPoint x) ∧ (IsGap (Sum.inr γ_N) ↔ IsGap x)
            rw [hxc_eq, hc_eq]
            exact ⟨⟨fun ⟨_, hp⟩ => absurd hp (by simp), fun ⟨_, hp⟩ => absurd hp (by simp)⟩,
                   ⟨fun _ => ⟨g_c, rfl⟩, fun _ => ⟨γ_N, rfl⟩⟩⟩)
        ⟨⟨fun _ => ⟨b_sp, rfl⟩, fun _ => ⟨b_resp, rfl⟩⟩,
         ⟨fun ⟨g, hg⟩ => absurd hg (by simp [extendPoint]),
          fun ⟨g, hg⟩ => absurd hg (by simp [extendPoint])⟩⟩
        (by have h := hgp_tau_d ⟨n + 2, by omega⟩
            simp only [game_tuple_y_eq] at h; exact h)
        (fun k => by rw [ha_bwd_all_γN k]
                     show (IsPoint (Sum.inr γ_N) ↔ IsPoint c) ∧ (IsGap (Sum.inr γ_N) ↔ IsGap c)
                     rw [hc_eq]
                     exact ⟨⟨fun ⟨_, hp⟩ => absurd hp (by simp), fun ⟨_, hp⟩ => absurd hp (by simp)⟩,
                            ⟨fun _ => ⟨g_c, rfl⟩, fun _ => ⟨γ_N, rfl⟩⟩⟩)
    · -- formula_agreement
      -- formula_agreement for backward direction (N is first struct, M is second)
      -- hform_sel needs: N (a_bwd k) ↔ M (a'_resp k) = N γ_N ↔ M c
      -- hgc_form gives: M g_c ↔ N γ_N. So we need (hgc_form).symm for N γ_N ↔ M g_c.
      -- But a'_resp k = c, need to show/change to M c then rw hc_eq.
      exact formula_agreement_of_cases
        (fun A hA => by rw [hx'_eq_γN]; show stavi_temporal_truth_mu N atomMap r (Sum.inr γ_N) A ↔ stavi_temporal_truth_mu M atomMap r x A; rw [hxc_eq, hc_eq]; exact (hgc_form A hA).symm)
        (fun A hA => by have h := hform_tau_d ⟨n + 1, by omega⟩ A hA
                        simp only [game_tuple_b_eq] at h; exact h)
        (fun A hA => by have h := hform_tau_d ⟨n + 2, by omega⟩ A hA
                        simp only [game_tuple_y_eq] at h; exact h)
        (fun k A hA => by rw [ha_bwd_all_γN k]; show stavi_temporal_truth_mu N atomMap r (Sum.inr γ_N) A ↔ stavi_temporal_truth_mu M atomMap r c A; rw [hc_eq]; exact (hgc_form A hA).symm)

/-- **Cases II-IV dispatcher**: When all selections lie in [d,y'],
    split on whether a_n is a point (Case II) or gap (Cases III-IV). -/
private theorem ghr93_cases_II_III_IV {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (ih : ∀ {x₀ y₀ : ExtendedCarrier M atomMap r}
            {x₀' y₀' : ExtendedCarrier N atomMap r},
          x₀ ≤ y₀ → x₀' ≤ y₀' →
          (∃ p, inClosedInterval x₀' y₀' (extendPoint p)) →
          ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x₀ y₀ x₀' y₀' →
          ghr93_duplicator_wins N M atomMap n r x₀' y₀' x₀ y₀)
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
  · -- Case II: a_n is a point.
    exact ghr93_case_II props hd ha_bwd h_no_split h_pt ih h_r1_univ h_mono
  · exact ghr93_cases_III_IV props hd ha_bwd h_no_split h_gap hxy hx'y' h_fwd_r1 h_r1_univ
      h_mono ih

/-! ### Assembly: The Inductive Step -/

/-- **GHR93 Theorem 6, inductive step**: combines the setup (split points
    c, d and sub-interval strategies σ, τ) with the 4-case analysis.

    This theorem is factored out of `ghr93_forward_to_backward` to keep
    the main proof clean and allow each case to be addressed independently.

    The `h_r1_univ` parameter provides rank-universal forward games (at any
    rank r'+2) needed by Cases III/IV for gap detection transfer at rank r+4. -/
theorem ghr93_inductive_step {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds) (n r delta : Nat)
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (hd : 2 ≤ delta)
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
  -- Construct rank-r IH from the rank-(r+delta) IH via rank_down.
  -- This is needed by Cases II (for tau_left/tau_right) and Cases III/IV (for tau).
  have ih_r : ∀ {x₀ y₀ : ExtendedCarrier M atomMap r}
            {x₀' y₀' : ExtendedCarrier N atomMap r},
          x₀ ≤ y₀ → x₀' ≤ y₀' →
          (∃ p, inClosedInterval x₀' y₀' (extendPoint p)) →
          ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x₀ y₀ x₀' y₀' →
          ghr93_duplicator_wins N M atomMap n r x₀' y₀' x₀ y₀ := by
    intro x₀ y₀ x₀' y₀' hle hle' hpt' hfwd
    exact ghr93_duplicator_wins_rank_down (by omega : r ≤ r + delta)
      (by omega : r + 2 ≤ r + delta) hle' hle (ih hle hle' hpt' hfwd)
  -- Case split: does any selection fall strictly below d?
  by_cases h_split : ∃ i : Fin (n + 1), a_sorted i < d
  · -- Case I: at least one selection below d (the "split" case)
    exact ghr93_case_I props hd ha_sorted h_split
  · -- Cases II-IV: all selections are at or above d
    push_neg at h_split
    exact ghr93_cases_II_III_IV props hd ha_sorted h_split hxy hx'y' ih_r h_fwd_r1 h_r1_univ
      h_mono

/- ======================================================================
   Source: Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Theorem6.lean
   Original context: `namespace Bimodal.Metalogic.WeakCanonical`,
   `open Bimodal.Syntax`.
   ====================================================================== -/

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
private theorem ghr93_forward_to_backward_core {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
    -- Uniform-rank IH at delta=2: use ih_gen at rank r+2.
    -- ih_gen gives: forward (1+3n) at rank (r+2) → backward n at rank (r+2).
    -- h_r1_univ gives forward games at any rank r'+2, so we get the forward
    -- game at (r+2) with round_mono from rounds_r1 to 1+3*n.
    exact ghr93_inductive_step atomMap n r 2 (by omega) hxy hx'y' h_pt h_pt_M
      (fun {x₀ y₀ x₀' y₀'} hle hle' hpt' hfwd => by
        -- N-side point at rank r+2
        obtain ⟨p_N, hp_N⟩ := hpt'
        have hpt'_r2 : ∃ p, inClosedInterval (rank_embed (by omega : r ≤ r + 2) x₀')
            (rank_embed (by omega : r ≤ r + 2) y₀') (extendPoint p) :=
          ⟨p_N, (rank_embed_inClosedInterval (by omega : r ≤ r + 2) x₀' y₀'
            (extendPoint p_N)).mpr hp_N⟩
        -- M-side point: extract from forward game hfwd at rank r.
        -- hfwd is M vs N. Spoiler picks M-elements. Play with all at x₀.
        -- Then challenge with p_N to get M-side point b_M.
        obtain ⟨a'_dum, _, hwin_fwd⟩ :=
          hfwd (fun _ => x₀) (fun _ => ⟨le_refl _, hle⟩)
        obtain ⟨b_M, hb_M, _⟩ := hwin_fwd p_N hp_N
        have hpt_M_r2 : ∃ p, inClosedInterval (rank_embed (by omega : r ≤ r + 2) x₀)
            (rank_embed (by omega : r ≤ r + 2) y₀) (extendPoint p) :=
          ⟨b_M, (rank_embed_inClosedInterval (by omega : r ≤ r + 2) x₀ y₀
            (extendPoint b_M)).mpr hb_M⟩
        -- Forward game at rank r+2 from h_r1_univ + round_mono
        have h_fwd_r2 := ghr93_duplicator_wins_round_mono (by omega : 1 + 3 * n ≤ rounds_r1)
            ((rank_embed_le (by omega : r ≤ r + 2) x₀ y₀).mpr hle)
            ((rank_embed_le (by omega : r ≤ r + 2) x₀' y₀').mpr hle')
            (h_r1_univ r hle hle')
        exact ih_gen (by omega) (r + 2)
          ((rank_embed_le (by omega : r ≤ r + 2) x₀ y₀).mpr hle)
          ((rank_embed_le (by omega : r ≤ r + 2) x₀' y₀').mpr hle')
          hpt'_r2 hpt_M_r2 h_fwd_r2)
      h h_fwd_r1
      (fun r' {x₁ y₁ x₁' y₁'} hle hle' =>
        ghr93_duplicator_wins_round_mono (by omega : 4 + 3 * n ≤ rounds_r1)
          ((rank_embed_le (by omega : r' ≤ r' + 2) x₁ y₁).mpr hle)
          ((rank_embed_le (by omega : r' ≤ r' + 2) x₁' y₁').mpr hle')
          (h_r1_univ r' hle hle'))

/-- **GHR93 Theorem 6** (Forward-to-backward transfer, uniform rank version):
    Public API. Calls the core with `delta := 0`. -/
theorem ghr93_forward_to_backward {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
theorem ghr93_forward_to_backward_rank_varying {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
      -- Apply the IH `ih` at base rank r+4. The IH says:
      --   forward (1+3n) at (r+4)+4n → backward n at r+4.
      -- We obtain the forward game at (r+4)+4n = r+4(n+1) from h_r1_univ
      -- at r' = r+4n+2, giving (1+3(n+1)) rounds at (r+4n+2)+2 = r+4+4n.
      -- Then round_mono drops from (1+3(n+1)) to (1+3n) rounds.
      apply ih (r + 4)
        ((rank_embed_le (by omega : r ≤ r + 4) x₀ y₀).mpr hle)
        ((rank_embed_le (by omega : r ≤ r + 4) x₀' y₀').mpr hle')
      · -- Point existence: ∃ p, inClosedInterval (rank_embed x₀') (rank_embed y₀') (extendPoint p)
        obtain ⟨p, hp⟩ := hpt'
        refine ⟨p, ?_⟩
        rw [← rank_embed_point (by omega : r ≤ r + 4) p]
        exact (rank_embed_inClosedInterval (by omega : r ≤ r + 4) x₀' y₀'
            (extendPoint p)).mpr hp
      · -- Forward game: (1+3n) rounds at (r+4)+4n on rank-embedded positions.
        -- h_r1_univ at r'=r+4n+2 gives (1+3(n+1)) rounds at (r+4n+2)+2.
        -- The goal needs rank r+4+4n. (r+4n+2)+2 = r+4n+4 and r+4+4n = r+4+4n.
        -- These are propositionally but not definitionally equal. We use `simp [Nat.add_assoc, ...]`
        -- or `omega` on the rank.
        -- Since the positions live at the rank type, we must be careful.
        -- Strategy: Use h_r1_univ with r' such that r'+2 DEFINITIONALLY equals r+4+4*n.
        -- r + 4 + 4 * n is (r + 4) + (4 * n) definitionally.
        -- If we set r' = (r + 4) + (4 * n) - 2 = r + 2 + 4 * n,
        -- then r' + 2 = (r + 2 + 4 * n) + 2 = r + 2 + 4 * n + 2.
        -- Still not equal to (r + 4) + (4 * n) definitionally.
        -- The ONLY way to get definitional equality is to match the parenthesization.
        -- r + 4 + 4 * n is (r + 4) + (4 * n). We need r' + 2 = (r + 4) + (4 * n).
        -- So r' = (r + 4) + (4 * n) - 2. But Lean's Nat subtraction is messy.
        -- Alternative: Use `show` with `calc` or `conv` on the goal to normalize.
        -- Pragmatic: use `Eq.mpr` to transport the type.
        have h_re := h_r1_univ (r + 4 * n + 2)
          (x₁ := rank_embed (by omega : r ≤ r + 4 * n + 2) x₀)
          (y₁ := rank_embed (by omega : r ≤ r + 4 * n + 2) y₀)
          (x₁' := rank_embed (by omega : r ≤ r + 4 * n + 2) x₀')
          (y₁' := rank_embed (by omega : r ≤ r + 4 * n + 2) y₀')
          ((rank_embed_le (by omega : r ≤ r + 4 * n + 2) x₀ y₀).mpr hle)
          ((rank_embed_le (by omega : r ≤ r + 4 * n + 2) x₀' y₀').mpr hle')
        -- h_re: 1+3(n+1) rounds at rank (r+4*n+2)+2.
        -- Drop rounds via round_mono.
        have hle_M := (rank_embed_le (by omega : r + 4 * n + 2 ≤ r + 4 * n + 2 + 2)
            (rank_embed (by omega : r ≤ r + 4 * n + 2) x₀)
            (rank_embed (by omega : r ≤ r + 4 * n + 2) y₀)).mpr
            ((rank_embed_le (by omega : r ≤ r + 4 * n + 2) x₀ y₀).mpr hle)
        have hle_N := (rank_embed_le (by omega : r + 4 * n + 2 ≤ r + 4 * n + 2 + 2)
            (rank_embed (by omega : r ≤ r + 4 * n + 2) x₀')
            (rank_embed (by omega : r ≤ r + 4 * n + 2) y₀')).mpr
            ((rank_embed_le (by omega : r ≤ r + 4 * n + 2) x₀' y₀').mpr hle')
        have h_mono := ghr93_duplicator_wins_round_mono
          (by omega : 1 + 3 * n ≤ 1 + 3 * (n + 1)) hle_M hle_N h_re
        -- h_mono: 1+3n rounds at rank r+4*n+2+2. Goal: rank r+4+4*n.
        -- These ranks are propositionally equal. Use convert to bridge.
        -- convert using 1 resolves the rank (via omega) and leaves HEq goals
        -- for positions. Each position pair has the same underlying element
        -- (both are rank_embed compositions from r to the same target rank),
        -- differing only in proof arguments.
        convert h_mono using 1
        · omega
        -- Each remaining goal is HEq between rank_embed compositions at
        -- propositionally-equal ranks (r+4+4*n vs r+4*n+2+2).
        -- Use rank_embed_comp_heq which handles the dependent-type arithmetic.
        all_goals exact rank_embed_comp_heq _ _ _ _ (by omega) _
      · -- Sub-h_r1_univ: forward (1+3n) at r'+2 for any sub-interval.
        -- From outer h_r1_univ (at (1+3(n+1)) rounds), use round_mono.
        intro r' x₁ y₁ x₁' y₁' hle₁ hle₁'
        exact ghr93_duplicator_wins_round_mono (by omega : 1 + 3 * n ≤ 1 + 3 * (n + 1))
          ((rank_embed_le (by omega : r' ≤ r' + 2) x₁ y₁).mpr hle₁)
          ((rank_embed_le (by omega : r' ≤ r' + 2) x₁' y₁').mpr hle₁')
          (h_r1_univ r' hle₁ hle₁')
    exact ghr93_inductive_step atomMap n r 4 (by omega : 2 ≤ 4) hxy hx'y' h_pt h_pt_M
      ih_delta4 h_fwd h_fwd_r1
      (fun r' {x₁ y₁ x₁' y₁'} hle hle' =>
        ghr93_duplicator_wins_round_mono (by omega : 4 + 3 * n ≤ 1 + 3 * (n + 1))
          ((rank_embed_le (by omega : r' ≤ r' + 2) x₁ y₁).mpr hle)
          ((rank_embed_le (by omega : r' ≤ r' + 2) x₁' y₁').mpr hle')
          (h_r1_univ r' hle hle'))
