import Bimodal.Metalogic.WeakCanonical.Expressiveness.Claim1

/-!
# D-Consistency and Game Rank Downward Transport

D-consistency and game rank downward transport.
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-! ## GHR93 Claim 1: D-Consistency of Strategy Responses

GHR93 Chapter 9, Section 8, Claim 1 (p.28): if Duplicator has a winning strategy
for G_{m;r'}(M, xy; N, x'y') with r' ≥ r, and c is a split point in [x,y] with
formula-agreement partner d in [x',y'], then any winning response at the boundary
position (where c is placed) must equal d.

The proof in GHR93 uses the infimum construction: d is the infimum of S_C.
In our simplified setting where d = a_bwd(n) (Spoiler's last backward pick),
we use the formula agreement and order transfer to show the response must match d.

### Key Argument (GHR93 Claim 1, simplified)

Given: A winning strategy for G_{n+1;r}(M,xy;N,x'y'). Spoiler places c at the
boundary. The response d' := a'_full(boundary) satisfies:
1. d' ∈ [x',y'] (from inClosedInterval)
2. formula_agreement(c, d') (from winning condition)
3. same gap/point status as c (from winning condition)
4. same ordering relative to x',y' as c has to x,y (from same_order_type)

Since c has the same formula_agreement with d (by hcd_form), and the same
gap/point status (by hcd_gp), d' must have the same rank_type as d.
By same_order_type, d' must occupy the same position relative to x',y' as d.

The full uniqueness requires showing that no two distinct elements of [x',y']
can have the same rank_type AND the same ordering relative to endpoints, which
follows from the infimum properties of d (GHR93 Claim 1 proof, p.28-29).
-/

/-- D-consistency (left boundary, existential form): for any Spoiler
    selection ending with c at position n, there exists a Duplicator response
    satisfying bounds, winning condition, AND having d at position n.

    This existential form is weaker than the universal form (which would
    require ALL winning responses to have d at position n). The existential
    suffices for `ghr93_strategy_restrict_left` which only needs ONE response
    with the d-consistency property.

    The proof applies the forward strategy h_fwd to obtain a candidate response,
    then verifies a'_full(n) = d using boundary correspondence from
    same_order_type. Boundary cases (x'=d, d=y') are fully proved.
    Interior case uses the forward strategy's response directly (sorry-free
    for boundary cases; interior case sorry'd pending Claim 1). -/
theorem d_consistency_left {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {n r : Nat}
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r}
    {d : ExtendedCarrier N atomMap r}
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (hc_interval : inClosedInterval x y c)
    (hd_interval : inClosedInterval x' y' d)
    (hcd_form : ∀ (A : StaviFormula), stavi_depth A ≤ r →
      (stavi_temporal_truth_mu M atomMap r c A ↔
       stavi_temporal_truth_mu N atomMap r d A))
    (hcd_gp : (IsPoint c ↔ IsPoint d) ∧ (IsGap c ↔ IsGap d))
    (hcd_boundary : (x = c ↔ x' = d) ∧ (c = y ↔ d = y'))
    (h_fwd : ghr93_duplicator_wins M N atomMap (n + 1) r x y x' y')
    (h_fwd_r1 : ghr93_duplicator_wins M N atomMap (n + 1) (r + 2)
      (rank_embed (by omega : r ≤ r + 2) x) (rank_embed (by omega : r ≤ r + 2) y)
      (rank_embed (by omega : r ≤ r + 2) x') (rank_embed (by omega : r ≤ r + 2) y'))
    (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p))
    -- GHR93 Claim 1 (interior case): when d is strictly interior to [x',y'],
    -- the rank-r forward game response at position n equals d.
    -- This replaces the false universal h_d_unique with a direct d-consistency
    -- guarantee constructed via rank_down(h_fwd_r1) + K⁻(¬D) at the call site.
    (h_interior_d : x' ≠ d → d ≠ y' →
      ∀ (a_pad : Fin (n + 1) → ExtendedCarrier M atomMap r),
        (∀ i, inClosedInterval x y (a_pad i)) →
        a_pad ⟨n, by omega⟩ = c →
        ∃ (a'_full : Fin (n + 1) → ExtendedCarrier N atomMap r),
          (∀ i, inClosedInterval x' y' (a'_full i)) ∧
          (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
            ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
              ghr93_winning_condition (n + 1)
                (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) ∧
          a'_full ⟨n, by omega⟩ = d) :
    ∀ (a_pad : Fin (n + 1) → ExtendedCarrier M atomMap r),
      (∀ i, inClosedInterval x y (a_pad i)) →
      a_pad ⟨n, by omega⟩ = c →
      ∃ (a'_full : Fin (n + 1) → ExtendedCarrier N atomMap r),
        (∀ i, inClosedInterval x' y' (a'_full i)) ∧
        (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
          ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
            ghr93_winning_condition (n + 1)
              (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) ∧
        a'_full ⟨n, by omega⟩ = d := by
  intro a_pad ha_pad hc_last
  -- Boundary case 1: x' = d
  by_cases hx'd : x' = d
  · -- Apply the forward strategy for the boundary case
    obtain ⟨a'_full, ha'_full, hwin_full⟩ := h_fwd a_pad ha_pad
    set t := a'_full ⟨n, by omega⟩ with ht_def
    obtain ⟨p₀, hp₀⟩ := h_pt
    obtain ⟨b₀, hb₀, hcond₀⟩ := hwin_full p₀ hp₀
    obtain ⟨hord₀, _, _⟩ := hcond₀
    have heq_0_n1 := (hord₀ ⟨0, by omega⟩ ⟨n + 1, by omega⟩).2
    simp only [game_tuple, show (0 : Nat) = 0 from rfl, dite_true,
               show (n + 1 : Nat) ≠ 0 from by omega,
               show (n + 1 : Nat) ≠ (n + 1) + 1 from by omega,
               show (n + 1 : Nat) ≠ (n + 1) + 2 from by omega, dite_false,
               show n + 1 - 1 = n from by omega] at heq_0_n1
    rw [hc_last] at heq_0_n1
    have hxc : x = c := hcd_boundary.1.mpr hx'd
    have hx't : x' = t := heq_0_n1.mp hxc
    have ht_eq_d : t = d := hx't.symm.trans hx'd
    exact ⟨a'_full, ha'_full, hwin_full, ht_def ▸ ht_eq_d⟩
  · by_cases hdy' : d = y'
    · -- Apply the forward strategy for the boundary case
      obtain ⟨a'_full, ha'_full, hwin_full⟩ := h_fwd a_pad ha_pad
      set t := a'_full ⟨n, by omega⟩ with ht_def
      obtain ⟨p₀, hp₀⟩ := h_pt
      obtain ⟨b₀, hb₀, hcond₀⟩ := hwin_full p₀ hp₀
      obtain ⟨hord₀, _, _⟩ := hcond₀
      have heq_n1_n3 := (hord₀ ⟨n + 1, by omega⟩ ⟨(n + 1) + 2, by omega⟩).2
      simp only [game_tuple, show (n + 1 : Nat) ≠ 0 from by omega,
                 show (n + 1 : Nat) ≠ (n + 1) + 1 from by omega,
                 show (n + 1 : Nat) ≠ (n + 1) + 2 from by omega, dite_false,
                 show n + 1 - 1 = n from by omega,
                 show ((n + 1) + 2 : Nat) ≠ 0 from by omega,
                 show ¬((n + 1 + 2 : Nat) = (n + 1) + 1) from by omega,
                 show (n + 1 + 2 : Nat) = (n + 1) + 2 from by omega, dite_true] at heq_n1_n3
      rw [hc_last] at heq_n1_n3
      have hcy : c = y := hcd_boundary.2.mpr hdy'
      have hty' : t = y' := heq_n1_n3.mp hcy
      have ht_eq_d : t = d := hty'.trans hdy'.symm
      exact ⟨a'_full, ha'_full, hwin_full, ht_def ▸ ht_eq_d⟩
    · -- Interior case: x' < d < y'. Delegate to h_interior_d.
      exact h_interior_d hx'd hdy' a_pad ha_pad hc_last

/-- D-consistency (right boundary, existential form): dual of
    d_consistency_left for the right sub-interval, where c is placed at
    position 0. For any Spoiler selection starting with c, there exists a
    response satisfying bounds, winning condition, AND having d at position 0.

    Boundary cases proved; interior case sorry'd (same blocker as left). -/
theorem d_consistency_right {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {n r : Nat}
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r}
    {d : ExtendedCarrier N atomMap r}
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (hc_interval : inClosedInterval x y c)
    (hd_interval : inClosedInterval x' y' d)
    (hcd_form : ∀ (A : StaviFormula), stavi_depth A ≤ r →
      (stavi_temporal_truth_mu M atomMap r c A ↔
       stavi_temporal_truth_mu N atomMap r d A))
    (hcd_gp : (IsPoint c ↔ IsPoint d) ∧ (IsGap c ↔ IsGap d))
    (hcd_boundary : (x = c ↔ x' = d) ∧ (c = y ↔ d = y'))
    (h_fwd : ghr93_duplicator_wins M N atomMap (n + 1) r x y x' y')
    (h_fwd_r1 : ghr93_duplicator_wins M N atomMap (n + 1) (r + 2)
      (rank_embed (by omega : r ≤ r + 2) x) (rank_embed (by omega : r ≤ r + 2) y)
      (rank_embed (by omega : r ≤ r + 2) x') (rank_embed (by omega : r ≤ r + 2) y'))
    (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p))
    -- GHR93 Claim 1 (interior case, right boundary): when d is strictly
    -- interior to [x',y'], the rank-r forward game response at position 0
    -- equals d. Constructed via rank_down(h_fwd_r1) + K⁻(¬D) at the call site.
    (h_interior_d : x' ≠ d → d ≠ y' →
      ∀ (a_pad : Fin (n + 1) → ExtendedCarrier M atomMap r),
        (∀ i, inClosedInterval x y (a_pad i)) →
        a_pad ⟨0, by omega⟩ = c →
        ∃ (a'_full : Fin (n + 1) → ExtendedCarrier N atomMap r),
          (∀ i, inClosedInterval x' y' (a'_full i)) ∧
          (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
            ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
              ghr93_winning_condition (n + 1)
                (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) ∧
          a'_full ⟨0, by omega⟩ = d) :
    ∀ (a_pad : Fin (n + 1) → ExtendedCarrier M atomMap r),
      (∀ i, inClosedInterval x y (a_pad i)) →
      a_pad ⟨0, by omega⟩ = c →
      ∃ (a'_full : Fin (n + 1) → ExtendedCarrier N atomMap r),
        (∀ i, inClosedInterval x' y' (a'_full i)) ∧
        (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
          ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
            ghr93_winning_condition (n + 1)
              (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) ∧
        a'_full ⟨0, by omega⟩ = d := by
  intro a_pad ha_pad hc_first
  -- Boundary case 1: x' = d
  by_cases hx'd : x' = d
  · obtain ⟨a'_full, ha'_full, hwin_full⟩ := h_fwd a_pad ha_pad
    set t := a'_full ⟨0, by omega⟩ with ht_def
    obtain ⟨p₀, hp₀⟩ := h_pt
    obtain ⟨b₀, hb₀, hcond₀⟩ := hwin_full p₀ hp₀
    obtain ⟨hord₀, _, _⟩ := hcond₀
    have heq_0_1 := (hord₀ ⟨0, by omega⟩ ⟨1, by omega⟩).2
    simp only [game_tuple, show (0 : Nat) = 0 from rfl, dite_true,
               show (1 : Nat) ≠ 0 from by omega,
               show (1 : Nat) ≠ (n + 1) + 1 from by omega,
               show (1 : Nat) ≠ (n + 1) + 2 from by omega, dite_false,
               show 1 - 1 = 0 from by omega] at heq_0_1
    rw [hc_first] at heq_0_1
    have hxc : x = c := hcd_boundary.1.mpr hx'd
    have hx't : x' = t := heq_0_1.mp hxc
    have ht_eq_d : t = d := hx't.symm.trans hx'd
    exact ⟨a'_full, ha'_full, hwin_full, ht_def ▸ ht_eq_d⟩
  · by_cases hdy' : d = y'
    · obtain ⟨a'_full, ha'_full, hwin_full⟩ := h_fwd a_pad ha_pad
      set t := a'_full ⟨0, by omega⟩ with ht_def
      obtain ⟨p₀, hp₀⟩ := h_pt
      obtain ⟨b₀, hb₀, hcond₀⟩ := hwin_full p₀ hp₀
      obtain ⟨hord₀, _, _⟩ := hcond₀
      have heq_1_n3 : c = y ↔ t = y' := by
        have h := (hord₀ ⟨1, by omega⟩ ⟨(n + 1) + 2, by omega⟩).2
        simp only [game_tuple, show (1 : Nat) ≠ 0 from by omega,
                   show (1 : Nat) ≠ (n + 1) + 1 from by omega,
                   show (1 : Nat) ≠ (n + 1) + 2 from by omega, dite_false,
                   show 1 - 1 = 0 from by omega,
                   show ((n + 1) + 2 : Nat) ≠ 0 from by omega,
                   show ¬((n + 1 + 2 : Nat) = (n + 1) + 1) from by omega,
                   show (n + 1 + 2 : Nat) = (n + 1) + 2 from by omega, dite_true] at h
        rwa [show a_pad ⟨1 - 1, by omega⟩ = c from hc_first] at h
      have hcy : c = y := hcd_boundary.2.mpr hdy'
      have hty' : t = y' := heq_1_n3.mp hcy
      have ht_eq_d : t = d := hty'.trans hdy'.symm
      exact ⟨a'_full, ha'_full, hwin_full, ht_def ▸ ht_eq_d⟩
    · -- Interior case: x' < d < y'. Delegate to h_interior_d.
      exact h_interior_d hx'd hdy' a_pad ha_pad hc_first


/-! ## Game Rank Downward Transport (GHR93 Lemma 10, rank part)

If Duplicator wins the game at rank r' with rank-embedded positions from
rank r, she also wins at rank r. This is the rank-monotonicity part of
GHR93 Lemma 10: the rank-r' game with rank-embedded endpoints involves
more carrier elements (more gaps) but also a stronger winning condition
(formula agreement at depth ≤ r' ≥ r). Crucially, Duplicator's responses
can always be chosen from rank r, because formula agreement forces gap
responses to be r-definable (via the K⁺/K⁻ characterization of gaps). -/

/-- **GHR93 Lemma 10** (Game rank downward transport):
    If Duplicator wins G_{m;r'}(M, xy; N, x'y') with rank-embedded positions
    (r + 2 ≤ r'), then she wins G_{m;r}(M, xy; N, x'y').

    The proof uses GHR93's K⁺/K⁻ gap characterization formula D' of depth
    ≤ r+2 ≤ r' to transfer gap definability from Spoiler's picks to
    Duplicator's responses. Gap responses at rank r' are shown r-definable
    by formula agreement, then projected to rank r.

    Hypothesis r + 2 ≤ r' is needed because gap_char_formula D has
    stavi_depth = stavi_depth(D) + 2, and formula agreement covers depth ≤ r'. -/
theorem ghr93_duplicator_wins_rank_down {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {m r r' : Nat} (hle : r ≤ r') (h2 : r + 2 ≤ r')
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h : ghr93_duplicator_wins M N atomMap m r'
           (rank_embed hle x) (rank_embed hle y)
           (rank_embed hle x') (rank_embed hle y')) :
    ghr93_duplicator_wins M N atomMap m r x y x' y' := by
  -- Spoiler picks m elements from [x,y] at rank r.
  intro a ha
  -- Embed Spoiler's picks to rank r'.
  have ha' : ∀ i, inClosedInterval (rank_embed hle x) (rank_embed hle y)
      (rank_embed hle (a i)) := by
    intro i; exact (rank_embed_inClosedInterval hle x y (a i)).mpr (ha i)
  -- Apply the rank-r' strategy.
  obtain ⟨a'_r', ha'_r'_in, hwin_r'⟩ := h (fun i => rank_embed hle (a i)) ha'
  -- Case split: does [x', y'] contain a carrier point?
  by_cases h_pt : ∃ (p₀ : N.carrier), inClosedInterval x' y' (extendPoint p₀)
  · -- Case 1: carrier point p₀ ∈ [x', y']. Use it to extract winning conditions.
    obtain ⟨p₀, hp₀⟩ := h_pt
    -- Embed p₀ to rank r'
    have hp₀' : inClosedInterval (rank_embed hle x') (rank_embed hle y')
        (extendPoint p₀) := by
      rw [← rank_embed_point hle p₀]
      exact (rank_embed_inClosedInterval hle x' y' (extendPoint p₀)).mpr hp₀
    -- Extract winning condition using p₀
    obtain ⟨b₀, hb₀, hcond₀⟩ := hwin_r' p₀ hp₀'
    obtain ⟨hord₀, hgp₀, hform₀⟩ := hcond₀
    -- Extract formula agreement at selection positions from the winning condition.
    -- Position i+1 in game tuple: M-side = rank_embed(a(i)), N-side = a'_r'(i)
    have hform_sel : ∀ (i : Fin m) (A : StaviFormula), stavi_depth A ≤ r' →
        (stavi_temporal_truth_mu M atomMap r' (rank_embed hle (a i)) A ↔
         stavi_temporal_truth_mu N atomMap r' (a'_r' i) A) := by
      intro i A hA
      have h := hform₀ ⟨1 + i.val, by omega⟩ A hA
      simp only [game_tuple] at h
      simp only [show (1 + i.val : Nat) ≠ 0 from by omega,
                 show ¬((1 + i.val : Nat) = m + 1) from by { have := i.isLt; omega },
                 show ¬((1 + i.val : Nat) = m + 2) from by { have := i.isLt; omega },
                 dite_false, show 1 + i.val - 1 = i.val from by omega] at h
      exact h
    -- Extract gap/point agreement at selection positions
    have hgp_sel : ∀ (i : Fin m),
        (IsPoint (rank_embed hle (a i)) ↔ IsPoint (a'_r' i)) ∧
        (IsGap (rank_embed hle (a i)) ↔ IsGap (a'_r' i)) := by
      intro i
      have h := hgp₀ ⟨1 + i.val, by omega⟩
      simp only [game_tuple] at h
      simp only [show (1 + i.val : Nat) ≠ 0 from by omega,
                 show ¬((1 + i.val : Nat) = m + 1) from by { have := i.isLt; omega },
                 show ¬((1 + i.val : Nat) = m + 2) from by { have := i.isLt; omega },
                 dite_false, show 1 + i.val - 1 = i.val from by omega] at h
      exact h
    -- For each gap response, show it is r-definable via gap_char_formula transfer.
    -- If a(i) is a gap at rank r defined by D (depth ≤ r), then gap_char_formula(D)
    -- has depth r + 2 ≤ r'. It holds at rank_embed(a(i)) and transfers to a'_r'(i).
    have h_gap_r_def : ∀ (i : Fin m) (g : RDefinableGap N atomMap r'),
        a'_r' i = Sum.inr g → r_definable_gap N atomMap g.val r := by
      intro i g hg
      -- a'_r'(i) is a gap. By gap/point agreement, rank_embed(a(i)) is a gap.
      have h_gp := (hgp_sel i).2.mpr ⟨g, hg⟩
      -- Case split on a(i) to determine if it's a point or gap.
      cases ha_i : a i with
      | inl q =>
        -- a(i) is a carrier point. rank_embed(a(i)) = extendPoint q at rank r'.
        -- gap/point says IsGap(extendPoint q at r') iff IsGap(a'_r'(i)).
        -- a'_r'(i) is a gap. So IsGap(extendPoint q) must hold.
        -- But extendPoint q = Sum.inl q, which is NOT a gap. Contradiction.
        exfalso
        have : IsPoint (rank_embed hle (a i)) := by
          rw [ha_i]; simp [rank_embed, Sum.map, IsPoint, extendPoint]
        have : ¬IsGap (rank_embed hle (a i)) := by
          intro ⟨g', hg'⟩; rw [ha_i] at hg'; simp [rank_embed, Sum.map, extendPoint] at hg'
        exact this h_gp
      | inr g_r =>
        -- a(i) = Sum.inr g_r, an r-definable gap at rank r.
        -- g_r : RDefinableGap M atomMap r. g_r.prop : r_definable_gap M atomMap g_r.val r.
        obtain ⟨D, hD_depth, hD_def⟩ := g_r.prop
        -- gap_char_formula(D) holds at g_r at rank r
        have h_char_M : stavi_temporal_truth_mu M atomMap r (Sum.inr g_r)
            (gap_char_formula D) :=
          gap_char_formula_holds g_r D hD_depth hD_def
        -- By rank_embed_stavi_truth_mu, it holds at rank_embed(a(i)) at rank r'
        have h_char_M' : stavi_temporal_truth_mu M atomMap r'
            (rank_embed hle (a i)) (gap_char_formula D) := by
          rw [ha_i, rank_embed_gap_eq]
          exact (rank_embed_stavi_truth_mu hle (Sum.inr g_r) (gap_char_formula D)).mpr h_char_M
        -- Transfer via formula agreement: depth(gap_char_formula D) ≤ r + 2 ≤ r'
        have h_depth_ok : stavi_depth (gap_char_formula D) ≤ r' :=
          le_trans (stavi_depth_gap_char_formula_le hD_depth) h2
        have h_char_N : stavi_temporal_truth_mu N atomMap r' (a'_r' i)
            (gap_char_formula D) :=
          (hform_sel i (gap_char_formula D) h_depth_ok).mp h_char_M'
        -- gap_char_formula_implies_definable: g is definable by D
        have h_char_g : stavi_temporal_truth_mu N atomMap r' (Sum.inr g)
            (gap_char_formula D) := hg ▸ h_char_N
        have h_def := gap_char_formula_implies_definable g D h_char_g
        -- D has depth ≤ r, so g is r-definable
        exact ⟨D, hD_depth, h_def⟩
    -- Define projection: rank r' elements → rank r elements
    -- Points project to the same carrier point. Gaps project using r-definability.
    let proj : (i : Fin m) → ExtendedCarrier N atomMap r := fun i =>
      match h_eq : a'_r' i with
      | .inl q => extendPoint q
      | .inr g => Sum.inr ⟨g.val, h_gap_r_def i g h_eq⟩
    -- proj(i) ∈ [x', y'] at rank r
    have hproj_in : ∀ i, inClosedInterval x' y' (proj i) := by
      intro i
      have h_in := ha'_r'_in i
      -- h_in : inClosedInterval (rank_embed hle x') (rank_embed hle y') (a'_r' i)
      simp only [proj]
      split
      · case h_1 q h_eq =>
        -- a'_r'(i) = Sum.inl q at rank r'. proj(i) = extendPoint q at rank r.
        -- Sum.inl q = extendPoint q = rank_embed(extendPoint q at rank r)
        rw [h_eq] at h_in
        -- h_in : inClosedInterval (rank_embed hle x') (rank_embed hle y') (Sum.inl q)
        -- Sum.inl q at rank r' = rank_embed(Sum.inl q at rank r) by rank_embed_point
        have h_re : (Sum.inl q : ExtendedCarrier N atomMap r') =
            rank_embed hle (extendPoint q : ExtendedCarrier N atomMap r) := by
          simp [rank_embed, Sum.map, extendPoint]
        rw [h_re] at h_in
        exact (rank_embed_inClosedInterval hle x' y' (extendPoint q)).mp h_in
      · case h_2 g h_eq =>
        -- a'_r'(i) = Sum.inr g at rank r'. proj(i) = Sum.inr ⟨g.val, _⟩ at rank r.
        -- Since rank_embed(proj(i)) = a'_r'(i) (shown in hN_eq below), we have
        -- rank_embed(x') ≤ a'_r'(i) ≤ rank_embed(y') at rank r'.
        -- Since rank_embed(proj(i)) = a'_r'(i), and rank_embed preserves ≤:
        -- x' ≤ proj(i) ≤ y' at rank r.
        rw [h_eq] at h_in
        -- rank_embed(Sum.inr ⟨g.val, _⟩) = Sum.inr g (same underlying gap)
        have h_re : rank_embed hle (Sum.inr ⟨g.val, h_gap_r_def i g h_eq⟩ :
            ExtendedCarrier N atomMap r) = (Sum.inr g : ExtendedCarrier N atomMap r') := by
          simp [rank_embed, Sum.map, rank_embed_gap, Subtype.ext_iff]
        have h_in' : inClosedInterval (rank_embed hle x') (rank_embed hle y')
            (rank_embed hle (Sum.inr ⟨g.val, h_gap_r_def i g h_eq⟩ :
              ExtendedCarrier N atomMap r)) := h_re ▸ h_in
        exact (rank_embed_inClosedInterval hle x' y' _).mp h_in'
    -- Provide the projected responses and prove the winning condition.
    refine ⟨proj, hproj_in, ?_⟩
    intro b' hb'
    -- Embed b' to rank r'
    have hb'' : inClosedInterval (rank_embed hle x') (rank_embed hle y')
        (extendPoint b') := by
      rw [← rank_embed_point hle b']
      exact (rank_embed_inClosedInterval hle x' y' (extendPoint b')).mpr hb'
    obtain ⟨b, hb, hcond⟩ := hwin_r' b' hb''
    -- b is in [rank_embed(x), rank_embed(y)] at rank r', so b ∈ [x, y] at rank r
    have hb_r : inClosedInterval x y (extendPoint b) := by
      rw [← rank_embed_point hle b] at hb
      exact (rank_embed_inClosedInterval hle x y (extendPoint b)).mp hb
    refine ⟨b, hb_r, ?_⟩
    obtain ⟨hord, hgp, hform⟩ := hcond
    -- Key helper: M-side game tuple at rank r' = rank_embed of M-side at rank r.
    have hM_eq : ∀ (k : Fin (m + 3)),
        game_tuple (rank_embed hle x) (rank_embed hle y)
          (fun i => rank_embed hle (a i)) b k =
        rank_embed hle (game_tuple x y a b k) := by
      intro k
      simp only [game_tuple]
      split_ifs with h0 hn1 hn2
      · -- k = 0: rank_embed(x) = rank_embed(x) ✓
        rfl
      · -- k = m+1: extendPoint b at rank r' = rank_embed(extendPoint b at rank r)
        exact (rank_embed_point hle b).symm
      · -- k = m+2: rank_embed(y) = rank_embed(y) ✓
        rfl
      · -- 1 ≤ k ≤ m: rank_embed(a(k-1)) = rank_embed(a(k-1)) ✓
        rfl
    -- Key helper: N-side game tuple at rank r' = rank_embed of N-side at rank r.
    -- For each position k: game_tuple_N_r'(k) = rank_embed(game_tuple_N_r(k)).
    have hN_eq : ∀ (k : Fin (m + 3)),
        game_tuple (rank_embed hle x') (rank_embed hle y') a'_r' b' k =
        rank_embed hle (game_tuple x' y' proj b' k) := by
      intro k
      simp only [game_tuple]
      split_ifs with h0 hn1 hn2
      · rfl  -- k=0: rank_embed(x') = rank_embed(x')
      · exact (rank_embed_point hle b').symm  -- k=m+1: extendPoint b'
      · rfl  -- k=m+2: rank_embed(y') = rank_embed(y')
      · -- Selection: a'_r'(k-1) = rank_embed(proj(k-1))
        have hk : k.val - 1 < m := by omega
        simp only [proj]
        split
        · case h_1 q h_eq =>
          rw [show Fin.mk (k.val - 1) (by omega) = ⟨k.val - 1, hk⟩ from rfl] at h_eq
          rw [h_eq]; exact (rank_embed_point hle q).symm
        · case h_2 g h_eq =>
          -- h_eq : a'_r' ⟨k.val - 1, _⟩ = Sum.inr g
          -- Goal: a'_r' ⟨k.val - 1, _⟩ = rank_embed hle (Sum.inr ⟨g.val, _⟩)
          -- Both Fin indices have the same val; use proof irrelevance via trans
          have h1 : a'_r' ⟨k.val - 1, by omega⟩ = Sum.inr g := h_eq
          have h2 : (Sum.inr g : ExtendedCarrier N atomMap r') =
              rank_embed hle (Sum.inr ⟨g.val, h_gap_r_def ⟨k.val - 1, by omega⟩ g h_eq⟩ :
                ExtendedCarrier N atomMap r) := by
            simp [rank_embed, Sum.map, rank_embed_gap, Subtype.ext_iff]
          exact h1.trans h2
    -- Now prove the three winning condition components using hM_eq and hN_eq.
    -- Both sides of the game tuple are rank_embed of their rank-r counterparts,
    -- so rank_embed preserves <, =, IsPoint, IsGap, and formula truth.
    refine ⟨?_, ?_, ?_⟩
    · -- same_order_type at rank r
      intro i j
      have h_ij := hord i j
      rw [hM_eq i, hM_eq j] at h_ij
      rw [hN_eq i, hN_eq j] at h_ij
      exact ⟨(rank_embed_lt hle _ _).symm.trans (h_ij.1.trans (rank_embed_lt hle _ _)),
             ⟨fun h => rank_embed_injective hle _ _ (h_ij.2.mp (congrArg _ h)),
              fun h => rank_embed_injective hle _ _ (h_ij.2.mpr (congrArg _ h))⟩⟩
    · -- gap_point_agreement at rank r
      intro k
      have h_gp_k := hgp k
      rw [hM_eq k, hN_eq k] at h_gp_k
      -- IsPoint transfer: rank_embed_isPoint gives the bridge
      have h_pt : IsPoint (game_tuple x y a b k) ↔ IsPoint (game_tuple x' y' proj b' k) :=
        (rank_embed_isPoint hle _).symm.trans (h_gp_k.1.trans (rank_embed_isPoint hle _))
      -- IsGap: derive from IsPoint using the fact that elements are either points or gaps
      have h_gap : IsGap (game_tuple x y a b k) ↔ IsGap (game_tuple x' y' proj b' k) := by
        constructor
        · intro ⟨g, hg⟩
          -- M-side is a gap, so NOT a point
          have h_not_pt_M : ¬IsPoint (game_tuple x y a b k) := by
            intro ⟨q, hq⟩; rw [hg] at hq; cases hq
          -- N-side is also NOT a point (by h_pt)
          have h_not_pt_N : ¬IsPoint (game_tuple x' y' proj b' k) :=
            fun hp => h_not_pt_M (h_pt.mpr hp)
          -- N-side must be a gap
          rcases isPoint_or_isGap (game_tuple x' y' proj b' k) with hp | hg'
          · exact absurd hp h_not_pt_N
          · exact hg'
        · intro ⟨g, hg⟩
          have h_not_pt_N : ¬IsPoint (game_tuple x' y' proj b' k) := by
            intro ⟨q, hq⟩; rw [hg] at hq; cases hq
          have h_not_pt_M : ¬IsPoint (game_tuple x y a b k) :=
            fun hp => h_not_pt_N (h_pt.mp hp)
          rcases isPoint_or_isGap (game_tuple x y a b k) with hp | hg'
          · exact absurd hp h_not_pt_M
          · exact hg'
      exact ⟨h_pt, h_gap⟩
    · -- formula_agreement at rank r (depth ≤ r)
      intro k A hA
      have hA' : stavi_depth A ≤ r' := le_trans hA hle
      have h_form_k := hform k A hA'
      rw [hM_eq k, hN_eq k] at h_form_k
      exact (rank_embed_stavi_truth_mu hle _ A).symm.trans
        (h_form_k.trans (rank_embed_stavi_truth_mu hle _ A))
  · -- Case 2: no carrier point in [x', y']. The winning condition is vacuously true.
    push_neg at h_pt
    refine ⟨fun _ => x', fun _ => ⟨le_refl _, hx'y'⟩, ?_⟩
    intro b' hb'; exact absurd hb' (h_pt b')

/-- Position-tracking variant of rank_down. Given a rank-r' response a'_r' obtained
    from applying the rank-r' game to rank_embed(a), if ∃ carrier point in [x',y'],
    we can project a'_r' to rank r with position tracking: whenever a'_r'(j) = rank_embed(e)
    and e ∈ [x',y'], the projection at j equals e. -/
theorem ghr93_rank_down_proj {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {m r r' : Nat} (hle : r ≤ r') (h2 : r + 2 ≤ r')
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (a : Fin m → ExtendedCarrier M atomMap r)
    (ha : ∀ i, inClosedInterval x y (a i))
    (a'_r' : Fin m → ExtendedCarrier N atomMap r')
    (ha'_r'_in : ∀ i, inClosedInterval (rank_embed hle x') (rank_embed hle y') (a'_r' i))
    (hwin_r' : ∀ (b' : N.carrier),
      inClosedInterval (rank_embed hle x') (rank_embed hle y') (extendPoint b') →
        ∃ (b : M.carrier),
          inClosedInterval (rank_embed hle x) (rank_embed hle y) (extendPoint b) ∧
            ghr93_winning_condition m
              (game_tuple (rank_embed hle x) (rank_embed hle y) (fun i => rank_embed hle (a i)) b)
              (game_tuple (rank_embed hle x') (rank_embed hle y') a'_r' b'))
    (h_pt : ∃ (p₀ : N.carrier), inClosedInterval x' y' (extendPoint p₀)) :
    ∃ (proj : Fin m → ExtendedCarrier N atomMap r),
      (∀ i, inClosedInterval x' y' (proj i)) ∧
      (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
        ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
          ghr93_winning_condition m (game_tuple x y a b) (game_tuple x' y' proj b')) ∧
      (∀ (j : Fin m) (e : ExtendedCarrier N atomMap r),
        a'_r' j = rank_embed hle e → inClosedInterval x' y' e → proj j = e) := by
  -- Use the carrier point to extract winning conditions and prove gap r-definability.
  obtain ⟨p₀, hp₀⟩ := h_pt
  have hp₀' : inClosedInterval (rank_embed hle x') (rank_embed hle y')
      (extendPoint p₀) := by
    rw [← rank_embed_point hle p₀]
    exact (rank_embed_inClosedInterval hle x' y' (extendPoint p₀)).mpr hp₀
  obtain ⟨b₀, hb₀, hcond₀⟩ := hwin_r' p₀ hp₀'
  obtain ⟨hord₀, hgp₀, hform₀⟩ := hcond₀
  -- Formula agreement at selection positions
  have hform_sel : ∀ (i : Fin m) (A : StaviFormula), stavi_depth A ≤ r' →
      (stavi_temporal_truth_mu M atomMap r' (rank_embed hle (a i)) A ↔
       stavi_temporal_truth_mu N atomMap r' (a'_r' i) A) := by
    intro i A hA
    have h := hform₀ ⟨1 + i.val, by omega⟩ A hA
    simp only [game_tuple] at h
    simp only [show (1 + i.val : Nat) ≠ 0 from by omega,
               show ¬((1 + i.val : Nat) = m + 1) from by { have := i.isLt; omega },
               show ¬((1 + i.val : Nat) = m + 2) from by { have := i.isLt; omega },
               dite_false, show 1 + i.val - 1 = i.val from by omega] at h
    exact h
  -- Gap/point agreement at selection positions
  have hgp_sel : ∀ (i : Fin m),
      (IsPoint (rank_embed hle (a i)) ↔ IsPoint (a'_r' i)) ∧
      (IsGap (rank_embed hle (a i)) ↔ IsGap (a'_r' i)) := by
    intro i
    have h := hgp₀ ⟨1 + i.val, by omega⟩
    simp only [game_tuple] at h
    simp only [show (1 + i.val : Nat) ≠ 0 from by omega,
               show ¬((1 + i.val : Nat) = m + 1) from by { have := i.isLt; omega },
               show ¬((1 + i.val : Nat) = m + 2) from by { have := i.isLt; omega },
               dite_false, show 1 + i.val - 1 = i.val from by omega] at h
    exact h
  -- Gap responses are r-definable
  have h_gap_r_def : ∀ (i : Fin m) (g : RDefinableGap N atomMap r'),
      a'_r' i = Sum.inr g → r_definable_gap N atomMap g.val r := by
    intro i g hg
    have h_gp := (hgp_sel i).2.mpr ⟨g, hg⟩
    cases ha_i : a i with
    | inl q =>
      exfalso
      have : IsPoint (rank_embed hle (a i)) := by
        rw [ha_i]; simp [rank_embed, Sum.map, IsPoint, extendPoint]
      have : ¬IsGap (rank_embed hle (a i)) := by
        intro ⟨g', hg'⟩; rw [ha_i] at hg'; simp [rank_embed, Sum.map, extendPoint] at hg'
      exact this h_gp
    | inr g_r =>
      obtain ⟨D, hD_depth, hD_def⟩ := g_r.prop
      have h_char_M : stavi_temporal_truth_mu M atomMap r (Sum.inr g_r)
          (gap_char_formula D) :=
        gap_char_formula_holds g_r D hD_depth hD_def
      have h_char_M' : stavi_temporal_truth_mu M atomMap r'
          (rank_embed hle (a i)) (gap_char_formula D) := by
        rw [ha_i, rank_embed_gap_eq]
        exact (rank_embed_stavi_truth_mu hle (Sum.inr g_r) (gap_char_formula D)).mpr h_char_M
      have h_depth_ok : stavi_depth (gap_char_formula D) ≤ r' :=
        le_trans (stavi_depth_gap_char_formula_le hD_depth) h2
      have h_char_N : stavi_temporal_truth_mu N atomMap r' (a'_r' i)
          (gap_char_formula D) :=
        (hform_sel i (gap_char_formula D) h_depth_ok).mp h_char_M'
      have h_char_g : stavi_temporal_truth_mu N atomMap r' (Sum.inr g)
          (gap_char_formula D) := hg ▸ h_char_N
      exact ⟨D, hD_depth, gap_char_formula_implies_definable g D h_char_g⟩
  -- Define projection
  let proj : Fin m → ExtendedCarrier N atomMap r := fun i =>
    match h_eq : a'_r' i with
    | .inl q => extendPoint q
    | .inr g => Sum.inr ⟨g.val, h_gap_r_def i g h_eq⟩
  -- proj(i) ∈ [x', y']
  have hproj_in : ∀ i, inClosedInterval x' y' (proj i) := by
    intro i
    have h_in := ha'_r'_in i
    simp only [proj]
    split
    · case h_1 q h_eq =>
      rw [h_eq] at h_in
      have h_re : (Sum.inl q : ExtendedCarrier N atomMap r') =
          rank_embed hle (extendPoint q : ExtendedCarrier N atomMap r) := by
        simp [rank_embed, Sum.map, extendPoint]
      rw [h_re] at h_in
      exact (rank_embed_inClosedInterval hle x' y' (extendPoint q)).mp h_in
    · case h_2 g h_eq =>
      rw [h_eq] at h_in
      have h_re : rank_embed hle (Sum.inr ⟨g.val, h_gap_r_def i g h_eq⟩ :
          ExtendedCarrier N atomMap r) = (Sum.inr g : ExtendedCarrier N atomMap r') := by
        simp [rank_embed, Sum.map, rank_embed_gap, Subtype.ext_iff]
      have h_in' : inClosedInterval (rank_embed hle x') (rank_embed hle y')
          (rank_embed hle (Sum.inr ⟨g.val, h_gap_r_def i g h_eq⟩ :
            ExtendedCarrier N atomMap r)) := h_re ▸ h_in
      exact (rank_embed_inClosedInterval hle x' y' _).mp h_in'
  -- Key: N-side game tuple at rank r' = rank_embed of N-side at rank r
  have hN_eq : ∀ (b' : N.carrier) (k : Fin (m + 3)),
      game_tuple (rank_embed hle x') (rank_embed hle y') a'_r' b' k =
      rank_embed hle (game_tuple x' y' proj b' k) := by
    intro b' k
    simp only [game_tuple]
    split_ifs with h0 hn1 hn2
    · rfl
    · exact (rank_embed_point hle b').symm
    · rfl
    · have hk : k.val - 1 < m := by omega
      simp only [proj]
      split
      · case h_1 q h_eq =>
        rw [show Fin.mk (k.val - 1) (by omega) = ⟨k.val - 1, hk⟩ from rfl] at h_eq
        rw [h_eq]; exact (rank_embed_point hle q).symm
      · case h_2 g h_eq =>
        have h1 : a'_r' ⟨k.val - 1, by omega⟩ = Sum.inr g := h_eq
        have h2 : (Sum.inr g : ExtendedCarrier N atomMap r') =
            rank_embed hle (Sum.inr ⟨g.val, h_gap_r_def ⟨k.val - 1, by omega⟩ g h_eq⟩ :
              ExtendedCarrier N atomMap r) := by
          simp [rank_embed, Sum.map, rank_embed_gap, Subtype.ext_iff]
        exact h1.trans h2
  -- M-side game tuple at rank r' = rank_embed of M-side at rank r
  have hM_eq : ∀ (b : M.carrier) (k : Fin (m + 3)),
      game_tuple (rank_embed hle x) (rank_embed hle y)
        (fun i => rank_embed hle (a i)) b k =
      rank_embed hle (game_tuple x y a b k) := by
    intro b k
    simp only [game_tuple]
    split_ifs with h0 hn1 hn2
    · rfl
    · exact (rank_embed_point hle b).symm
    · rfl
    · rfl
  -- Winning condition
  have hwin : ∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
      ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
        ghr93_winning_condition m (game_tuple x y a b) (game_tuple x' y' proj b') := by
    intro b' hb'
    have hb'' : inClosedInterval (rank_embed hle x') (rank_embed hle y')
        (extendPoint b') := by
      rw [← rank_embed_point hle b']
      exact (rank_embed_inClosedInterval hle x' y' (extendPoint b')).mpr hb'
    obtain ⟨b, hb, hcond⟩ := hwin_r' b' hb''
    have hb_r : inClosedInterval x y (extendPoint b) := by
      rw [← rank_embed_point hle b] at hb
      exact (rank_embed_inClosedInterval hle x y (extendPoint b)).mp hb
    refine ⟨b, hb_r, ?_⟩
    obtain ⟨hord, hgp, hform⟩ := hcond
    refine ⟨?_, ?_, ?_⟩
    · -- same_order_type
      intro i j
      have h_ij := hord i j
      rw [hM_eq b i, hM_eq b j] at h_ij
      rw [hN_eq b' i, hN_eq b' j] at h_ij
      exact ⟨(rank_embed_lt hle _ _).symm.trans (h_ij.1.trans (rank_embed_lt hle _ _)),
             ⟨fun h => rank_embed_injective hle _ _ (h_ij.2.mp (congrArg _ h)),
              fun h => rank_embed_injective hle _ _ (h_ij.2.mpr (congrArg _ h))⟩⟩
    · -- gap_point_agreement
      intro k
      have h_gp_k := hgp k
      rw [hM_eq b k, hN_eq b' k] at h_gp_k
      have h_pt_k : IsPoint (game_tuple x y a b k) ↔ IsPoint (game_tuple x' y' proj b' k) :=
        (rank_embed_isPoint hle _).symm.trans (h_gp_k.1.trans (rank_embed_isPoint hle _))
      have h_gap_k : IsGap (game_tuple x y a b k) ↔ IsGap (game_tuple x' y' proj b' k) := by
        constructor
        · intro ⟨g, hg⟩
          have h_not_pt_M : ¬IsPoint (game_tuple x y a b k) := by
            intro ⟨q, hq⟩; rw [hg] at hq; cases hq
          have h_not_pt_N : ¬IsPoint (game_tuple x' y' proj b' k) :=
            fun hp => h_not_pt_M (h_pt_k.mpr hp)
          rcases isPoint_or_isGap (game_tuple x' y' proj b' k) with hp | hg'
          · exact absurd hp h_not_pt_N
          · exact hg'
        · intro ⟨g, hg⟩
          have h_not_pt_N : ¬IsPoint (game_tuple x' y' proj b' k) := by
            intro ⟨q, hq⟩; rw [hg] at hq; cases hq
          have h_not_pt_M : ¬IsPoint (game_tuple x y a b k) :=
            fun hp => h_not_pt_N (h_pt_k.mp hp)
          rcases isPoint_or_isGap (game_tuple x y a b k) with hp | hg'
          · exact absurd hp h_not_pt_M
          · exact hg'
      exact ⟨h_pt_k, h_gap_k⟩
    · -- formula_agreement
      intro k A hA
      have hA' : stavi_depth A ≤ r' := le_trans hA hle
      have h_form_k := hform k A hA'
      rw [hM_eq b k, hN_eq b' k] at h_form_k
      exact (rank_embed_stavi_truth_mu hle _ A).symm.trans
        (h_form_k.trans (rank_embed_stavi_truth_mu hle _ A))
  -- Position tracking: if a'_r'(j) = rank_embed(e), then proj(j) = e
  -- Key insight: hN_eq at selection positions gives a'_r'(j) = rank_embed(proj(j)).
  -- Combined with h_eq : a'_r'(j) = rank_embed(e), injectivity of rank_embed gives proj(j) = e.
  have hpos : ∀ (j : Fin m) (e : ExtendedCarrier N atomMap r),
      a'_r' j = rank_embed hle e → inClosedInterval x' y' e → proj j = e := by
    intro j e h_eq _h_in
    -- From hN_eq applied to the selection position of j:
    -- game_tuple ... a'_r' b' ⟨1+j, ...⟩ = rank_embed(game_tuple ... proj b' ⟨1+j, ...⟩)
    -- At index 1+j (selection slot): LHS = a'_r'(j), RHS = rank_embed(proj(j))
    have h_sel : a'_r' j = rank_embed hle (proj j) := by
      have h := hN_eq p₀ ⟨1 + j.val, by omega⟩
      simp only [game_tuple, show (1 + j.val : Nat) ≠ 0 from by omega,
                 show ¬((1 + j.val : Nat) = m + 1) from by { have := j.isLt; omega },
                 show ¬((1 + j.val : Nat) = m + 2) from by { have := j.isLt; omega },
                 dite_false, show 1 + j.val - 1 = j.val from by omega] at h
      exact h
    -- Now: rank_embed(proj(j)) = a'_r'(j) = rank_embed(e)
    have h_re_eq : rank_embed hle (proj j) = rank_embed hle e := h_sel.symm.trans h_eq
    exact rank_embed_injective hle _ _ h_re_eq
  exact ⟨proj, hproj_in, hwin, hpos⟩


end Bimodal.Metalogic.WeakCanonical
