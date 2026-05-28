import Bimodal.Metalogic.WeakCanonical.Expressiveness.DConsistencyTransport

/-!
# Split-Point Infrastructure

Split-point infrastructure: SplitPointProps and the main obtain_split_point_props theorem.
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-! ## GHR93 Theorem 6: Inductive Step Infrastructure

The inductive step of Theorem 6 converts a forward (4+3n)-round strategy
into a backward (n+1)-round strategy. The proof introduces key quantities
from the GHR93 argument:

- **d**: A "split point" in N_r that separates the interval [x',y'] based on
  where the forward strategy's type pattern changes. Formally, d is defined
  using the interval type A = X_{(a_{n-1}, a_n)} and a continuation formula C.

- **c**: The corresponding split point in M_r, obtained by applying the
  forward strategy to d.

- **σ, τ**: Backward strategies on sub-intervals [x',d]/[x,c] and
  [d,y']/[c,y], obtained by restricting the master forward strategy and
  applying the inductive hypothesis (*)_n.

The proof then splits into four cases based on the nature of a_n (Spoiler's
last selection in the backward game). -/

/-- Properties of the split points c, d that are needed for the case analysis.

    **GHR93 rank structure**: The `delta` parameter captures the rank offset
    between the backward game's rank `r` and the rank at which sigma/tau play.
    In GHR93, the induction peels off 4 from the rank at each step, so sigma/tau
    end up at rank `r + delta` (with delta = 4 in the inductive step). Positions
    c, d, x, y, x', y' live at rank `r`, and sigma/tau play on rank-embedded
    positions via `rank_embed (by omega : r ≤ r + delta)`.

    When `delta = 0`, this reduces to the original structure (sigma/tau at rank r). -/
structure SplitPointProps {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (n : Nat) (delta : Nat)
    (x y : ExtendedCarrier M atomMap r)
    (x' y' : ExtendedCarrier N atomMap r)
    (c : ExtendedCarrier M atomMap r)
    (d : ExtendedCarrier N atomMap r)
    (a_bwd : Fin (n + 1) → ExtendedCarrier N atomMap r) where
  /-- c is in [x, y] -/
  hc_interval : inClosedInterval x y c
  /-- d is in [x', y'] -/
  hd_interval : inClosedInterval x' y' d
  /-- The split point d is ≤ a_n (Spoiler's last backward pick).
      When d = infimum of continuation_set (GHR93 d̄), this holds because
      a_bwd(n) ∈ continuation_set and the infimum ≤ every member.
      Case I uses ≤ only. Case II is restructured to work without =. -/
  hd_le_an : d ≤ a_bwd ⟨n, by omega⟩
  /-- x ≤ c (for sub-interval well-formedness) -/
  hxc : x ≤ c
  /-- c ≤ y (for sub-interval well-formedness) -/
  hcy : c ≤ y
  /-- x' ≤ d (for sub-interval well-formedness) -/
  hx'd : x' ≤ d
  /-- d ≤ y' (for sub-interval well-formedness) -/
  hdy' : d ≤ y'
  /-- There exists an actual M-point in [x, c], or x = c (and x' = d) with c a gap.
      Degenerate case: GHR93 allows the sub-interval to be a single gap point.
      The x' = d condition ensures the N-side sub-interval is also degenerate. -/
  h_pt_xc : (∃ (p : M.carrier), inClosedInterval x c (extendPoint p)) ∨
             (x = c ∧ x' = d ∧ IsGap c ∧ IsGap d)
  /-- There exists an actual M-point in [c, y], or c = y (and d = y') with c a gap.
      Degenerate case: GHR93 allows the sub-interval to be a single gap point.
      The d = y' condition ensures the N-side sub-interval is also degenerate. -/
  h_pt_cy : (∃ (p : M.carrier), inClosedInterval c y (extendPoint p)) ∨
             (c = y ∧ d = y' ∧ IsGap c ∧ IsGap d)
  /-- Formula agreement between c and d at rank r.
      Used in degenerate gap cases (GHR93 implicit: game on [d,d] vs [c,c]). -/
  hcd_form : ∀ (A : StaviFormula), stavi_depth A ≤ r →
      (stavi_temporal_truth_mu M atomMap r c A ↔
       stavi_temporal_truth_mu N atomMap r d A)
  /-- Gap/point correspondence between c and d.
      Used in degenerate gap cases and Case II point derivation. -/
  hcd_gp : (IsPoint c ↔ IsPoint d) ∧ (IsGap c ↔ IsGap d)
  /-- Backward strategy σ on the left sub-interval at rank r + delta:
      Duplicator wins G_{n; r+delta}(N, x'd; M, xc) on rank-embedded positions.
      GHR93: sigma lives at rank r+4 (delta=4) from the IH applied at base rank r+4. -/
  sigma : ghr93_duplicator_wins N M atomMap n (r + delta)
    (rank_embed (by omega : r ≤ r + delta) x')
    (rank_embed (by omega : r ≤ r + delta) d)
    (rank_embed (by omega : r ≤ r + delta) x)
    (rank_embed (by omega : r ≤ r + delta) c)
  /-- Backward strategy τ on the right sub-interval at rank r + delta:
      Duplicator wins G_{n; r+delta}(N, dy'; M, cy) on rank-embedded positions.
      GHR93: tau lives at rank r+4 (delta=4) from the IH applied at base rank r+4. -/
  tau : ghr93_duplicator_wins N M atomMap n (r + delta)
    (rank_embed (by omega : r ≤ r + delta) d)
    (rank_embed (by omega : r ≤ r + delta) y')
    (rank_embed (by omega : r ≤ r + delta) c)
    (rank_embed (by omega : r ≤ r + delta) y)
  /-- (n+1)-round forward strategy on the full interval.
      Derived from the (4+3n)-round forward strategy via round_mono.
      Used in Case II to construct e_n and establish ordering compatibility. -/
  h_fwd_n1 : ghr93_duplicator_wins M N atomMap (n + 1) r x y x' y'
  /-- D-compatible (1+3n+1)-round forward strategy: for any selection ending
      with c, there exists a response ending with d and satisfying the winning
      condition. Used in Case II to derive cross-boundary orderings between
      d/c and p_n/e_n. -/
  h_d_compat_left :
    ∀ (a_pad : Fin (1 + 3 * n + 1) → ExtendedCarrier M atomMap r),
      (∀ i, inClosedInterval x y (a_pad i)) →
      a_pad ⟨1 + 3 * n, by omega⟩ = c →
      ∃ (a'_full : Fin (1 + 3 * n + 1) → ExtendedCarrier N atomMap r),
        (∀ i, inClosedInterval x' y' (a'_full i)) ∧
        (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
          ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
            ghr93_winning_condition (1 + 3 * n + 1)
              (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) ∧
        a'_full ⟨1 + 3 * n, by omega⟩ = d

set_option maxHeartbeats 800000 in
/-- Obtain the split point properties. This is the core setup lemma for
    the inductive step, combining strategy restriction and IH application.

    **Approach** (simplified from GHR93, avoids infimum infrastructure):

    1. Set d = a_bwd(n) — Spoiler's last backward pick. Then hd_eq_an is rfl.
    2. Play the forward (4+3n)-round strategy with 1 element from [x,y] to find a
       compatible point c. Specifically, use round_mono to get a 1-round strategy,
       then play it to find c such that c and d have the same rank_type and
       gap/point status.
    3. Apply strategy_restrict_left/right with c,d to restrict the forward strategy
       from [x,y] to [x,c] and [c,y] (consuming one round each).
    4. Apply round_mono to reduce rounds to 1+3n.
    5. Apply the generalized IH on the sub-intervals to get sigma and tau.

    The generalized IH is universally quantified over endpoints, so it can be
    applied to sub-intervals [x,c]/[x',d] and [c,y]/[d,y'].

    Key insight: We do NOT need to compute an infimum. Setting d = a_bwd(n)
    and obtaining c from the forward strategy is sufficient. The winning
    condition of the forward game guarantees that c and d are compatible
    (same rank_type, same gap/point status).

    NOTE: Steps 2-5 are sorry'd pending full proofs of strategy_restrict_left/right
    and the sub-interval h_pt witness (existence of an actual point in each
    sub-interval). The construction is structurally correct — the sorry's are
    in the strategy restriction lemma and the sub-interval point existence.  -/
theorem obtain_split_point_props {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {n r : Nat}
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (delta : Nat)
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
    (a_bwd : Fin (n + 1) → ExtendedCarrier N atomMap r)
    (ha_bwd : ∀ i, inClosedInterval x' y' (a_bwd i)) :
    ∃ (c : ExtendedCarrier M atomMap r) (d : ExtendedCarrier N atomMap r),
      SplitPointProps n delta x y x' y' c d a_bwd := by
  -- Step 1: Set d = inf(continuation_set) — the GHR93 d̄.
  -- S_C = {t ∈ [x',y'] : cont_holds at all mu-points in (t, y')}
  -- a_bwd(n) ∈ S_C. d = inf(S_C) ≤ a_bwd(n).
  -- The infimum is either a carrier point (if S_C has a point minimum)
  -- or a gap (constructed via infimum_gap).
  -- For this refactoring, we sorry-construct the infimum with its key properties.
  -- The infrastructure for the full construction exists (infimum_gap,
  -- infimum_gap_r_definable, inf_carrier_cut, etc.) and is sorry-free.
  -- Construct d as the infimum of S_C within [x', y'].
  -- Case split: either a_bwd(n) is the minimum of S_C, or S_C has elements
  -- strictly below a_bwd(n) (requiring gap/point infimum construction).
  set S_C := continuation_set x' y' (a_bwd ⟨n, by omega⟩) with S_C_def
  have h_an_in_SC : a_bwd ⟨n, by omega⟩ ∈ S_C :=
    a_n_in_continuation_set (ha_bwd ⟨n, by omega⟩)
  obtain ⟨d, hd_interval, hd_glb, hd_le_an_proof, hd_is_inf⟩ :
      ∃ d : ExtendedCarrier N atomMap r,
        inClosedInterval x' y' d ∧
        (∀ s ∈ S_C, d ≤ s) ∧
        d ≤ a_bwd ⟨n, by omega⟩ ∧
        -- d is the greatest lower bound (infimum) of S_C:
        (∀ e : ExtendedCarrier N atomMap r, (∀ s ∈ S_C, e ≤ s) → e ≤ d) := by
    -- Construct d as the infimum of S_C (GHR93 d̄).
    -- Case split: does S_C have a carrier-point minimum?
    -- A carrier-point minimum p has extendPoint p ∈ S_C and extendPoint p ≤ all s ∈ S_C.
    by_cases h_has_pt_min : ∃ (p : N.carrier),
        (extendPoint p : ExtendedCarrier N atomMap r) ∈ S_C ∧
        ∀ s ∈ S_C, (extendPoint p : ExtendedCarrier N atomMap r) ≤ s
    · -- Point minimum case: d = extendPoint p
      obtain ⟨p, hp_in_SC, hp_lb⟩ := h_has_pt_min
      refine ⟨extendPoint p, ?_, hp_lb, hp_lb _ h_an_in_SC, ?_⟩
      · -- inClosedInterval x' y' (extendPoint p): follows from p ∈ S_C ⊆ [x',y']
        exact hp_in_SC.1
      · -- GLB: if e ≤ all s ∈ S_C, then e ≤ extendPoint p (since extendPoint p ∈ S_C)
        intro e he; exact he _ hp_in_SC
    · -- No carrier-point minimum. Sub-split on carrier-point GLB existence.
      push_neg at h_has_pt_min
      -- h_has_pt_min : ∀ p, extendPoint p ∈ S_C → ∃ s ∈ S_C, s < extendPoint p
      -- (i.e., no carrier point that's both IN S_C and ≤ all of S_C)
      have h_ne : S_C.Nonempty := continuation_set_nonempty hx'y'
      -- h_pt_below: ∃ carrier-point lower bound of S_C.
      have h_pt_below : ∃ p : N.carrier, ∀ s ∈ S_C,
          (extendPoint p : ExtendedCarrier N atomMap r) ≤ s := by
        rcases isPoint_or_isGap x' with ⟨px, hpx⟩ | ⟨gx, hgx⟩
        · refine ⟨px, fun s hs => ?_⟩; rw [show (extendPoint px : ExtendedCarrier N atomMap r) = x' from hpx.symm]; exact hs.1.1
        · obtain ⟨q, hq⟩ := gx.val.nonempty
          refine ⟨q, fun s hs => ?_⟩
          have hq_le_x' : (extendPoint q : ExtendedCarrier N atomMap r) ≤ x' := by
            rw [hgx]; exact (hq : q ∈ gx.val.cut)
          exact le_trans hq_le_x' hs.1.1
      -- 3-way case split: Case 2 (carrier-point GLB exists) vs Case 3 (no GLB).
      by_cases h_has_glb : ∃ (p : N.carrier),
          (∀ s ∈ S_C, (extendPoint p : ExtendedCarrier N atomMap r) ≤ s) ∧
          (∀ q : N.carrier, (∀ s ∈ S_C,
            (extendPoint q : ExtendedCarrier N atomMap r) ≤ s) →
            (extendPoint q : ExtendedCarrier N atomMap r) ≤ extendPoint p)
      · -- Case 2: Carrier-point GLB p exists but p ∉ S_C.
        -- d = extendPoint p is the infimum of S_C in the full extended order.
        obtain ⟨p, hp_lb, hp_greatest⟩ := h_has_glb
        -- p ∉ S_C: if extendPoint p ∈ S_C, h_has_pt_min gives ∃ s < extendPoint p,
        -- contradicting hp_lb.
        have hp_not_in : (extendPoint p : ExtendedCarrier N atomMap r) ∉ S_C := by
          intro hp_in
          obtain ⟨s, hs_in, hs_lt⟩ := h_has_pt_min p hp_in
          exact absurd (hp_lb s hs_in) (not_le.mpr hs_lt)
        refine ⟨extendPoint p, ?_, hp_lb, hp_lb _ h_an_in_SC, ?_⟩
        · -- inClosedInterval x' y' (extendPoint p):
          -- x' ≤ extendPoint p: In a linear order, either x' ≤ extendPoint p or
          -- extendPoint p < x'. If extendPoint p < x', then since x' ≤ s for all
          -- s ∈ S_C (from S_C ⊆ [x',y']), we have extendPoint p < x' ≤ s for all s.
          -- But x' itself is a lb of S_C. If x' is a point x' = extendPoint px,
          -- then px is a carrier-point lb with extendPoint p < extendPoint px,
          -- contradicting hp_greatest (since px would give extendPoint px ≤ extendPoint p).
          -- If x' is a gap, any q in x'.cut has extendPoint q ≤ x' ≤ s, so q is a
          -- carrier-point lb, hence extendPoint q ≤ extendPoint p. In particular
          -- x' has all its cut members ≤ p. But x' > extendPoint p means p is in x'.cut
          -- (since extendPoint p ≤ x' = gap means p ∈ cut). And the complement of
          -- x'.cut has no minimum, so there exist points above p still in the cut... wait.
          -- Actually: extendPoint p < x' means extendPoint p ≤ x'. If x' = Sum.inr gx,
          -- then extendPoint p ≤ Sum.inr gx means p ∈ gx.cut. So p is in the cut.
          -- p is the greatest carrier-point lb. All carrier-point lbs q have q ≤ p.
          -- gx.cut is downward-closed and contains p. Now: does gx.cut contain all
          -- q ≤ p? Yes (downward-closed). Does it contain anything above p? If not,
          -- then p is a maximum of gx.cut, but it's also in the cut, so it would be
          -- the LUB of gx.cut and in the cut — violating the gap no_sup axiom.
          -- So gx.cut must contain some q > p. But then extendPoint q ≤ Sum.inr gx ≤ s
          -- for all s ∈ S_C, making q a carrier-point lb with q > p, contradicting
          -- hp_greatest. Contradiction! So extendPoint p ≥ x'.
          constructor
          · by_contra h_lt
            push_neg at h_lt
            -- extendPoint p < x'
            rcases isPoint_or_isGap x' with ⟨px, hpx⟩ | ⟨gx, hgx⟩
            · -- x' is a point: px is a carrier-point lb above p
              have : (extendPoint px : ExtendedCarrier N atomMap r) ≤ extendPoint p := by
                apply hp_greatest
                intro s hs
                have : x' ≤ s := hs.1.1
                rw [hpx] at this; exact this
              rw [hpx] at h_lt
              exact absurd this (not_le.mpr h_lt)
            · -- x' is a gap gx. extendPoint p < x' means p ∈ gx.cut.
              rw [hgx] at h_lt
              have hp_in_cut : p ∈ gx.val.cut :=
                le_of_lt h_lt
              -- All carrier-point lbs q have extendPoint q ≤ extendPoint p, so q ≤ p.
              -- gx.cut is downward-closed and contains p. So gx.cut ⊇ {q : q ≤ p}.
              -- We show gx.cut ⊆ {q : q ≤ p}: if q ∈ gx.cut, then extendPoint q ≤ x',
              -- and x' ≤ s for all s ∈ S_C, so q is a carrier-point lb, hence q ≤ p.
              have h_cut_sub : ∀ q : N.carrier, q ∈ gx.val.cut → q ≤ p := by
                intro q hq_cut
                have hq_lb : ∀ s ∈ S_C, (extendPoint q : ExtendedCarrier N atomMap r) ≤ s := by
                  intro s hs
                  have : (extendPoint q : ExtendedCarrier N atomMap r) ≤ x' := by
                    rw [hgx]; exact hq_cut
                  exact le_trans this hs.1.1
                exact (extendPoint_le_iff q p).mp (hp_greatest q hq_lb)
              -- So p is a maximum of gx.cut: p ∈ gx.cut and ∀ q ∈ gx.cut, q ≤ p.
              -- This makes p an upper bound of gx.cut that's IN the cut,
              -- violating the gap's no_sup axiom.
              have h_p_lub : IsLUB gx.val.cut p ∧ p ∈ gx.val.cut :=
                ⟨⟨fun q hq => h_cut_sub q hq, fun _ hb => hb hp_in_cut⟩, hp_in_cut⟩
              exact absurd ⟨p, h_p_lub⟩ gx.val.no_sup
          · exact le_trans (hp_lb _ h_an_in_SC) (ha_bwd ⟨n, by omega⟩).2
        · -- GLB in full extended order: if e ≤ all s ∈ S_C, then e ≤ extendPoint p.
          -- For carrier-point e = extendPoint q: q is a carrier-point lb, so q ≤ p
          -- by hp_greatest, so e ≤ extendPoint p.
          -- For gap e = Sum.inr g: g's cut ⊆ {q : q is carrier-point lb of S_C} ⊆ {q : q ≤ p}.
          -- If p were in g.cut, then p is a maximum of g.cut (since g.cut ⊆ {q : q ≤ p}
          -- and p ∈ g.cut), violating g's no_sup axiom. So p ∉ g.cut, meaning
          -- Sum.inr g ≤ extendPoint p.
          intro e he
          rcases isPoint_or_isGap e with ⟨q, hq⟩ | ⟨g, hg⟩
          · -- e is a carrier point
            rw [hq]; exact hp_greatest q (fun s hs => by rw [show (extendPoint q : ExtendedCarrier N atomMap r) = e from hq.symm]; exact he s hs)
          · -- e is a gap g. Show Sum.inr g ≤ extendPoint p.
            rw [hg]
            -- g.cut ⊆ {q : q ≤ p}: if q ∈ g.cut, then extendPoint q ≤ Sum.inr g ≤ s
            -- for all s ∈ S_C, so q is a carrier-point lb, hence q ≤ p.
            have h_g_cut_sub : ∀ q : N.carrier, q ∈ g.val.cut → q ≤ p := by
              intro q hq_cut
              have hq_lb : ∀ s ∈ S_C, (extendPoint q : ExtendedCarrier N atomMap r) ≤ s := by
                intro s hs
                exact le_trans (show (extendPoint q : ExtendedCarrier N atomMap r) ≤ Sum.inr g from hq_cut)
                  (hg ▸ he s hs)
              exact (extendPoint_le_iff q p).mp (hp_greatest q hq_lb)
            -- Show p ∉ g.cut (otherwise p is max of g.cut, violating no_sup)
            by_contra h_not_le
            push_neg at h_not_le
            -- ¬(Sum.inr g ≤ extendPoint p) means extendPoint p < Sum.inr g,
            -- i.e., extendPoint p ≤ Sum.inr g, i.e., p ∈ g.cut
            have hp_in_g : p ∈ g.val.cut := le_of_lt h_not_le
            have h_p_lub : IsLUB g.val.cut p ∧ p ∈ g.val.cut :=
              ⟨⟨fun q hq => h_g_cut_sub q hq, fun _ hb => hb hp_in_g⟩, hp_in_g⟩
            exact absurd ⟨p, h_p_lub⟩ g.val.no_sup
      · -- Case 3: No carrier-point GLB. Construct d as a gap via infimum_gap.
        -- Step 3.1: Derive h_above (needed for inf_carrier_cut_proper).
        have h_above : ∃ (q : N.carrier) (s : ↥S_C),
            (extendPoint q : ExtendedCarrier N atomMap r) > s.val := by
          obtain ⟨s₀, hs₀⟩ := h_ne
          rcases isPoint_or_isGap s₀ with ⟨p₀, hp₀⟩ | ⟨g₀, hg₀⟩
          · -- s₀ is carrier point: h_has_pt_min gives t ∈ S_C with t < s₀
            have hs₀' : (extendPoint p₀ : ExtendedCarrier N atomMap r) ∈ S_C := by
              rw [show (extendPoint p₀ : ExtendedCarrier N atomMap r) = s₀ from hp₀.symm]; exact hs₀
            obtain ⟨t, ht_in, ht_lt⟩ := h_has_pt_min p₀ hs₀'
            exact ⟨p₀, ⟨t, ht_in⟩, ht_lt⟩
          · -- s₀ is a gap: use g₀.proper to find q ∉ g₀.cut
            have h_proper := g₀.val.proper
            rw [Set.ne_univ_iff_exists_not_mem] at h_proper
            obtain ⟨q, hq_not_in⟩ := h_proper
            have hq_ge : (extendPoint q : ExtendedCarrier N atomMap r) ≥ s₀ := hg₀ ▸ hq_not_in
            have hq_ne : (extendPoint q : ExtendedCarrier N atomMap r) ≠ s₀ := by
              rw [hg₀]; exact fun h => absurd h (by simp [extendPoint])
            exact ⟨q, ⟨s₀, hs₀⟩, lt_of_le_of_ne hq_ge (Ne.symm hq_ne)⟩
        -- Step 3.2: Construct the gap and package as RDefinableGap.
        set gamma := infimum_gap h_ne h_pt_below h_above h_has_glb with gamma_def
        -- Step 3.3: Three-way case split on boundary structure (GHR93 p.116).
        -- Key: does ∃ p₀ in the cut with x' ≤ extendPoint p₀?
        by_cases hx'_bound : ∃ p₀ : N.carrier,
            p₀ ∈ inf_carrier_cut S_C ∧
            x' ≤ (extendPoint p₀ : ExtendedCarrier N atomMap r)
        · -- hx'_bound: gamma strictly above x'. Second split on h_abv.
          by_cases h_abv : ∃ q₀ : N.carrier,
              q₀ ∉ inf_carrier_cut S_C ∧
              (extendPoint q₀ : ExtendedCarrier N atomMap r) < y' ∧
              x' ≤ (extendPoint q₀ : ExtendedCarrier N atomMap r)
          · -- Sub-case (b): r-definable gap. Apply infimum_gap_r_definable.
            have h_rdef := infimum_gap_r_definable hx'y'
              (ha_bwd ⟨n, by omega⟩) h_ne h_pt_below h_above h_has_glb
              hx'_bound h_abv
            have h_gamma_lb_pt : ∀ (ps : N.carrier),
                (extendPoint ps : ExtendedCarrier N atomMap r) ∈ S_C →
                ps ∉ gamma.cut := by
              intro ps hps h_in
              obtain ⟨s, hs_in, hs_lt⟩ := h_has_pt_min ps hps
              exact absurd ((h_in : ps ∈ inf_carrier_cut S_C) s hs_in) (not_le.mpr hs_lt)
            have h_gamma_lb_gap : ∀ (gs : RDefinableGap N atomMap r),
                (Sum.inr gs : ExtendedCarrier N atomMap r) ∈ S_C →
                gamma.cut ⊆ gs.val.cut := by
              intro gs hgs q hq; exact (hq : q ∈ inf_carrier_cut S_C) _ hgs
            refine ⟨Sum.inr ⟨gamma, h_rdef⟩, ⟨?_, ?_⟩, ?_, ?_, ?_⟩
            · -- x' ≤ d
              obtain ⟨p₀, hp₀_cut, hx'_le⟩ := hx'_bound
              exact le_trans hx'_le (hp₀_cut : p₀ ∈ inf_carrier_cut S_C)
            · -- d ≤ y': via d ≤ a_bwd(n) ≤ y'
              apply le_trans _ (ha_bwd ⟨n, by omega⟩).2
              match h_eq : a_bwd ⟨n, by omega⟩, h_an_in_SC with
              | Sum.inl pa, hs => exact h_gamma_lb_pt pa hs
              | Sum.inr ga, hs => exact h_gamma_lb_gap ga hs
            · -- ∀ s ∈ S_C, d ≤ s
              intro s hs; match s, hs with
              | Sum.inl ps, hs => exact h_gamma_lb_pt ps hs
              | Sum.inr gs, hs => exact h_gamma_lb_gap gs hs
            · -- d ≤ a_bwd(n)
              match h_eq : a_bwd ⟨n, by omega⟩, h_an_in_SC with
              | Sum.inl pa, hs => exact h_gamma_lb_pt pa hs
              | Sum.inr ga, hs => exact h_gamma_lb_gap ga hs
            · -- GLB: ∀ e, (∀ s ∈ S_C, e ≤ s) → e ≤ d
              intro e he; match e, he with
              | Sum.inl pe, he => exact he
              | Sum.inr ge, he =>
                intro q hq s hs
                exact le_trans (hq : (extendPoint q : ExtendedCarrier N atomMap r) ≤ Sum.inr ge) (he s hs)
          · -- Sub-case (c): gamma = y' (as gaps), d = y'.
            push_neg at h_abv
            have h_y'_gap : IsGap y' := by
              rcases isPoint_or_isGap y' with ⟨py', hpy'⟩ | hg
              · exfalso
                have hpy'_not_cut : py' ∉ gamma.cut := by
                  intro h_in
                  have h_y'_in_SC : (extendPoint py' : ExtendedCarrier N atomMap r) ∈ S_C := by
                    rw [show (extendPoint py' : ExtendedCarrier N atomMap r) = y' from hpy'.symm]
                    exact ⟨⟨hx'y', le_refl y'⟩, fun u hyu huy' _ => absurd (lt_trans hyu huy') (lt_irrefl _)⟩
                  obtain ⟨s, hs_in, hs_lt⟩ := h_has_pt_min py' h_y'_in_SC
                  exact absurd ((h_in : py' ∈ inf_carrier_cut S_C) s hs_in) (not_le.mpr hs_lt)
                have : ¬ (∀ q, q ∉ gamma.cut → py' ≤ q) :=
                  fun h => gamma.complement_no_min ⟨py', hpy'_not_cut, h⟩
                push_neg at this
                obtain ⟨q', hq'_not_cut, hq'_lt⟩ := this
                obtain ⟨p₀, hp₀_cut, hx'_le_p₀⟩ := hx'_bound
                have hq'_lt_y' : (extendPoint q' : ExtendedCarrier N atomMap r) < y' := by
                  rw [hpy']; exact (extendPoint_lt_iff q' py').mpr hq'_lt
                have hq'_lt_x' := h_abv q' (hq'_not_cut : q' ∉ inf_carrier_cut S_C) hq'_lt_y'
                have : ¬ (q' ≤ p₀) := fun h => hq'_not_cut (gamma.downward_closed p₀ q' hp₀_cut h)
                have hx'_le_q' := le_trans hx'_le_p₀
                  ((extendPoint_le_iff p₀ q').mpr (le_of_lt (not_le.mp this)))
                exact absurd hx'_le_q' (not_le.mpr hq'_lt_x')
              · exact hg
            obtain ⟨gy', hgy'⟩ := h_y'_gap
            have h_cut_eq : gamma.cut = gy'.val.cut := by
              ext q; constructor
              · intro hq
                have h1 := (hq : q ∈ inf_carrier_cut S_C) _ h_an_in_SC
                have h2 := (ha_bwd ⟨n, by omega⟩).2
                rw [hgy'] at h2; exact le_trans h1 h2
              · intro hq; by_contra hq_not
                obtain ⟨p₀, hp₀_cut, hx'_le_p₀⟩ := hx'_bound
                have hq_lt_y' : (extendPoint q : ExtendedCarrier N atomMap r) < y' := by
                  rw [hgy']; exact ⟨hq, fun h => absurd hq h⟩
                have hq_lt_x' := h_abv q (hq_not : q ∉ inf_carrier_cut S_C) hq_lt_y'
                have : ¬ (q ≤ p₀) := fun h => hq_not (gamma.downward_closed p₀ q hp₀_cut h)
                have hx'_le_q := le_trans hx'_le_p₀
                  ((extendPoint_le_iff p₀ q).mpr (le_of_lt (not_le.mp this)))
                exact absurd hx'_le_q (not_le.mpr hq_lt_x')
            refine ⟨y', ⟨hx'y', le_refl y'⟩, ?_, ?_, ?_⟩
            · -- ∀ s ∈ S_C, y' ≤ s
              intro s hs; match s, hs with
              | Sum.inl ps, hs =>
                rw [hgy']
                have : ps ∉ gamma.cut := by
                  intro h_in; obtain ⟨t, ht_in, ht_lt⟩ := h_has_pt_min ps hs
                  exact absurd ((h_in : ps ∈ inf_carrier_cut S_C) t ht_in) (not_le.mpr ht_lt)
                rwa [h_cut_eq] at this
              | Sum.inr gs, hs =>
                rw [hgy']; intro q hq; rw [← h_cut_eq] at hq
                exact (hq : q ∈ inf_carrier_cut S_C) _ hs
            · -- y' ≤ a_bwd(n)
              match h_eq : a_bwd ⟨n, by omega⟩, h_an_in_SC with
              | Sum.inl pa, hs =>
                rw [hgy']
                have : pa ∉ gamma.cut := by
                  intro h_in; obtain ⟨t, ht_in, ht_lt⟩ := h_has_pt_min pa hs
                  exact absurd ((h_in : pa ∈ inf_carrier_cut S_C) t ht_in) (not_le.mpr ht_lt)
                rwa [h_cut_eq] at this
              | Sum.inr ga, hs =>
                rw [hgy']; intro q hq; rw [← h_cut_eq] at hq
                exact (hq : q ∈ inf_carrier_cut S_C) _ hs
            · -- GLB
              intro e he; exact le_trans (he _ h_an_in_SC) (ha_bwd ⟨n, by omega⟩).2
        · -- ¬hx'_bound: gamma = x' (as gaps), d = x'.
          push_neg at hx'_bound
          have hx'_gap : IsGap x' := by
            rcases isPoint_or_isGap x' with ⟨px', hpx'⟩ | hg
            · exfalso
              have h_px'_cut : px' ∈ inf_carrier_cut S_C := by
                intro s hs
                rw [show (extendPoint px' : ExtendedCarrier N atomMap r) = x' from hpx'.symm]
                exact hs.1.1
              exact absurd (hx'_bound px' h_px'_cut) (not_lt.mpr (hpx' ▸ le_refl _))
            · exact hg
          obtain ⟨gx', hgx'⟩ := hx'_gap
          have h_cut_eq : gamma.cut = gx'.val.cut := by
            ext q; constructor
            · intro hq; by_contra h_not_in
              exact absurd (hx'_bound q hq) (not_lt.mpr
                (show x' ≤ (extendPoint q : ExtendedCarrier N atomMap r) by rw [hgx']; exact h_not_in))
            · intro hq s hs
              exact le_trans
                (show (extendPoint q : ExtendedCarrier N atomMap r) ≤ x' by rw [hgx']; exact hq) hs.1.1
          refine ⟨x', ⟨le_refl _, hx'y'⟩, ?_, (ha_bwd ⟨n, by omega⟩).1, ?_⟩
          · intro s hs; exact hs.1.1
          · intro e he
            rcases isPoint_or_isGap e with ⟨pe, hpe⟩ | ⟨ge, hge⟩
            · rw [hpe, hgx']
              have hmem : pe ∈ gamma.cut := by rw [hpe] at he; exact he
              rw [h_cut_eq] at hmem; exact hmem
            · rw [hge, hgx']
              have hmem : ge.val.cut ⊆ gamma.cut := by
                intro q hq; rw [hge] at he
                intro s hs
                exact le_trans
                  (hq : (extendPoint q : ExtendedCarrier N atomMap r) ≤ Sum.inr ge) (he s hs)
              intro q hq; exact (h_cut_eq ▸ hmem hq : q ∈ gx'.val.cut)
  -- Step 2: Construct c = inf(S_C^M) — the M-side infimum (GHR93 p.115-116).
  -- S_C^M = { t ∈ [x,y] : cont_holds_cross at all mu-points in (t, y) in M }.
  -- The continuation predicate uses N-side interval type (a_bwd(n), y') but
  -- evaluates truth in M. This mirrors d = inf(S_C^N) exactly.
  set S_C_M := continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y' with S_C_M_def
  have h_y_in_SC_M : y ∈ S_C_M := by
    refine ⟨⟨hxy, le_refl y⟩, ?_⟩
    intro u hyu huy _
    exact absurd (lt_trans hyu huy) (lt_irrefl y)
  obtain ⟨c_inf, hc_inf_interval, hc_inf_glb, hc_inf_is_inf⟩ :
      ∃ c_inf : ExtendedCarrier M atomMap r,
        inClosedInterval x y c_inf ∧
        (∀ s ∈ S_C_M, c_inf ≤ s) ∧
        (∀ e : ExtendedCarrier M atomMap r, (∀ s ∈ S_C_M, e ≤ s) → e ≤ c_inf) := by
    -- Mirror the d = inf(S_C^N) construction (3-way case split).
    by_cases h_has_pt_min_M : ∃ (p : M.carrier),
        (extendPoint p : ExtendedCarrier M atomMap r) ∈ S_C_M ∧
        ∀ s ∈ S_C_M, (extendPoint p : ExtendedCarrier M atomMap r) ≤ s
    · -- Case 1: Carrier-point minimum exists.
      obtain ⟨p, hp_in, hp_lb⟩ := h_has_pt_min_M
      exact ⟨extendPoint p, hp_in.1, hp_lb, fun e he => he _ hp_in⟩
    · push_neg at h_has_pt_min_M
      -- h_has_pt_min_M : ∀ p, extendPoint p ∈ S_C_M → ∃ s ∈ S_C_M, s < extendPoint p
      have h_ne_M : S_C_M.Nonempty := ⟨y, h_y_in_SC_M⟩
      have h_pt_below_M : ∃ p : M.carrier, ∀ s ∈ S_C_M,
          (extendPoint p : ExtendedCarrier M atomMap r) ≤ s := by
        rcases isPoint_or_isGap x with ⟨px, hpx⟩ | ⟨gx, hgx⟩
        · refine ⟨px, fun s hs => ?_⟩
          rw [show (extendPoint px : ExtendedCarrier M atomMap r) = x from hpx.symm]
          exact hs.1.1
        · obtain ⟨q, hq⟩ := gx.val.nonempty
          refine ⟨q, fun s hs => ?_⟩
          have hq_le_x : (extendPoint q : ExtendedCarrier M atomMap r) ≤ x := by
            rw [hgx]; exact (hq : q ∈ gx.val.cut)
          exact le_trans hq_le_x hs.1.1
      by_cases h_has_glb_M : ∃ (p : M.carrier),
          (∀ s ∈ S_C_M, (extendPoint p : ExtendedCarrier M atomMap r) ≤ s) ∧
          (∀ q : M.carrier, (∀ s ∈ S_C_M,
            (extendPoint q : ExtendedCarrier M atomMap r) ≤ s) →
            (extendPoint q : ExtendedCarrier M atomMap r) ≤ extendPoint p)
      · -- Case 2: Carrier-point GLB p exists but p ∉ S_C_M.
        obtain ⟨p, hp_lb, hp_greatest⟩ := h_has_glb_M
        have hp_not_in : (extendPoint p : ExtendedCarrier M atomMap r) ∉ S_C_M := by
          intro hp_in
          obtain ⟨s, hs_in, hs_lt⟩ := h_has_pt_min_M p hp_in
          exact absurd (hp_lb s hs_in) (not_le.mpr hs_lt)
        refine ⟨extendPoint p, ?_, hp_lb, ?_⟩
        · constructor
          · by_contra h_lt
            push_neg at h_lt
            rcases isPoint_or_isGap x with ⟨px, hpx⟩ | ⟨gx, hgx⟩
            · have : (extendPoint px : ExtendedCarrier M atomMap r) ≤ extendPoint p := by
                apply hp_greatest
                intro s hs
                have : x ≤ s := hs.1.1
                rw [hpx] at this; exact this
              rw [hpx] at h_lt
              exact absurd this (not_le.mpr h_lt)
            · rw [hgx] at h_lt
              have hp_in_cut : p ∈ gx.val.cut := le_of_lt h_lt
              have h_cut_sub : ∀ q : M.carrier, q ∈ gx.val.cut → q ≤ p := by
                intro q hq_cut
                have hq_lb : ∀ s ∈ S_C_M, (extendPoint q : ExtendedCarrier M atomMap r) ≤ s := by
                  intro s hs
                  have : (extendPoint q : ExtendedCarrier M atomMap r) ≤ x := by
                    rw [hgx]; exact hq_cut
                  exact le_trans this hs.1.1
                exact (extendPoint_le_iff q p).mp (hp_greatest q hq_lb)
              have h_p_lub : IsLUB gx.val.cut p ∧ p ∈ gx.val.cut :=
                ⟨⟨fun q hq => h_cut_sub q hq, fun _ hb => hb hp_in_cut⟩, hp_in_cut⟩
              exact absurd ⟨p, h_p_lub⟩ gx.val.no_sup
          · exact le_trans (hp_lb _ h_y_in_SC_M) h_y_in_SC_M.1.2
        · intro e he
          rcases isPoint_or_isGap e with ⟨q, hq⟩ | ⟨g, hg⟩
          · rw [hq]; exact hp_greatest q (fun s hs => by rw [show (extendPoint q : ExtendedCarrier M atomMap r) = e from hq.symm]; exact he s hs)
          · rw [hg]
            have h_g_cut_sub : ∀ q : M.carrier, q ∈ g.val.cut → q ≤ p := by
              intro q hq_cut
              have hq_lb : ∀ s ∈ S_C_M, (extendPoint q : ExtendedCarrier M atomMap r) ≤ s := by
                intro s hs
                exact le_trans (show (extendPoint q : ExtendedCarrier M atomMap r) ≤ Sum.inr g from hq_cut)
                  (hg ▸ he s hs)
              exact (extendPoint_le_iff q p).mp (hp_greatest q hq_lb)
            by_contra h_not_le
            push_neg at h_not_le
            have hp_in_g : p ∈ g.val.cut := le_of_lt h_not_le
            have h_p_lub : IsLUB g.val.cut p ∧ p ∈ g.val.cut :=
              ⟨⟨fun q hq => h_g_cut_sub q hq, fun _ hb => hb hp_in_g⟩, hp_in_g⟩
            exact absurd ⟨p, h_p_lub⟩ g.val.no_sup
      · -- Case 3: No carrier-point GLB. Construct c_inf as a gap (mirrors N-side Case 3).
        -- Step 3.1: Derive h_above_M.
        have h_above_M : ∃ (q : M.carrier) (s : ↥S_C_M),
            (extendPoint q : ExtendedCarrier M atomMap r) > s.val := by
          obtain ⟨s₀, hs₀⟩ := h_ne_M
          rcases isPoint_or_isGap s₀ with ⟨p₀, hp₀⟩ | ⟨g₀, hg₀⟩
          · have hs₀' : (extendPoint p₀ : ExtendedCarrier M atomMap r) ∈ S_C_M := by
              rw [show (extendPoint p₀ : ExtendedCarrier M atomMap r) = s₀ from hp₀.symm]; exact hs₀
            obtain ⟨t, ht_in, ht_lt⟩ := h_has_pt_min_M p₀ hs₀'
            exact ⟨p₀, ⟨t, ht_in⟩, ht_lt⟩
          · have h_proper := g₀.val.proper
            rw [Set.ne_univ_iff_exists_not_mem] at h_proper
            obtain ⟨q, hq_not_in⟩ := h_proper
            have hq_ge : (extendPoint q : ExtendedCarrier M atomMap r) ≥ s₀ := hg₀ ▸ hq_not_in
            have hq_ne : (extendPoint q : ExtendedCarrier M atomMap r) ≠ s₀ := by
              rw [hg₀]; exact fun h => absurd h (by simp [extendPoint])
            exact ⟨q, ⟨s₀, hs₀⟩, lt_of_le_of_ne hq_ge (Ne.symm hq_ne)⟩
        -- Step 3.2: Construct the gap.
        set gamma_M := infimum_gap h_ne_M h_pt_below_M h_above_M h_has_glb_M with gamma_M_def
        -- Step 3.3: Three-way case split (mirror of N-side).
        by_cases hx_bound : ∃ p₀ : M.carrier,
            p₀ ∈ inf_carrier_cut S_C_M ∧
            x ≤ (extendPoint p₀ : ExtendedCarrier M atomMap r)
        · -- hx_bound: gamma_M strictly above x.
          -- Further split: is there a carrier point above the gap and strictly below y?
          by_cases h_abv_M : ∃ q₀ : M.carrier,
              q₀ ∉ inf_carrier_cut S_C_M ∧
              (extendPoint q₀ : ExtendedCarrier M atomMap r) < y ∧
              x ≤ (extendPoint q₀ : ExtendedCarrier M atomMap r)
          · -- Sub-case (b): r-definable gap. Apply infimum_gap_r_definable_cross.
            have h_rdef := infimum_gap_r_definable_cross hxy
              h_ne_M h_pt_below_M h_above_M h_has_glb_M
              hx_bound h_abv_M
            have h_gamma_lb_pt : ∀ (ps : M.carrier),
                (extendPoint ps : ExtendedCarrier M atomMap r) ∈ S_C_M →
                ps ∉ gamma_M.cut := by
              intro ps hps h_in
              obtain ⟨s, hs_in, hs_lt⟩ := h_has_pt_min_M ps hps
              exact absurd ((h_in : ps ∈ inf_carrier_cut S_C_M) s hs_in) (not_le.mpr hs_lt)
            have h_gamma_lb_gap : ∀ (gs : RDefinableGap M atomMap r),
                (Sum.inr gs : ExtendedCarrier M atomMap r) ∈ S_C_M →
                gamma_M.cut ⊆ gs.val.cut := by
              intro gs hgs q hq; exact (hq : q ∈ inf_carrier_cut S_C_M) _ hgs
            refine ⟨Sum.inr ⟨gamma_M, h_rdef⟩, ⟨?_, ?_⟩, ?_, ?_⟩
            · -- x ≤ c_inf
              obtain ⟨p₀, hp₀_cut, hx_le⟩ := hx_bound
              exact le_trans hx_le (hp₀_cut : p₀ ∈ inf_carrier_cut S_C_M)
            · -- c_inf ≤ y: via c_inf ≤ y (y ∈ S_C_M)
              match h_eq : y, h_y_in_SC_M with
              | Sum.inl py, hy => exact h_gamma_lb_pt py hy
              | Sum.inr gy, hy => exact h_gamma_lb_gap gy hy
            · -- ∀ s ∈ S_C_M, c_inf ≤ s
              intro s hs; match s, hs with
              | Sum.inl ps, hs => exact h_gamma_lb_pt ps hs
              | Sum.inr gs, hs => exact h_gamma_lb_gap gs hs
            · -- GLB: ∀ e, (∀ s ∈ S_C_M, e ≤ s) → e ≤ c_inf
              intro e he; match e, he with
              | Sum.inl pe, he => exact he
              | Sum.inr ge, he =>
                intro q hq s hs
                exact le_trans (hq : (extendPoint q : ExtendedCarrier M atomMap r) ≤ Sum.inr ge) (he s hs)
          · -- Sub-case (c): gamma_M = y (as gaps), c_inf = y.
            push_neg at h_abv_M
            have h_y_gap : IsGap y := by
              rcases isPoint_or_isGap y with ⟨py, hpy⟩ | hg
              · exfalso
                have hpy_not_cut : py ∉ gamma_M.cut := by
                  intro h_in
                  have h_y_in_SC' : (extendPoint py : ExtendedCarrier M atomMap r) ∈ S_C_M := by
                    rw [show (extendPoint py : ExtendedCarrier M atomMap r) = y from hpy.symm]
                    exact h_y_in_SC_M
                  obtain ⟨s, hs_in, hs_lt⟩ := h_has_pt_min_M py h_y_in_SC'
                  exact absurd ((h_in : py ∈ inf_carrier_cut S_C_M) s hs_in) (not_le.mpr hs_lt)
                have : ¬ (∀ q, q ∉ gamma_M.cut → py ≤ q) :=
                  fun h => gamma_M.complement_no_min ⟨py, hpy_not_cut, h⟩
                push_neg at this
                obtain ⟨q', hq'_not_cut, hq'_lt⟩ := this
                obtain ⟨p₀, hp₀_cut, hx_le_p₀⟩ := hx_bound
                have hq'_lt_y : (extendPoint q' : ExtendedCarrier M atomMap r) < y := by
                  rw [hpy]; exact (extendPoint_lt_iff q' py).mpr hq'_lt
                have hq'_lt_x := h_abv_M q' (hq'_not_cut : q' ∉ inf_carrier_cut S_C_M) hq'_lt_y
                have : ¬ (q' ≤ p₀) := fun h => hq'_not_cut (gamma_M.downward_closed p₀ q' hp₀_cut h)
                have hx_le_q' := le_trans hx_le_p₀
                  ((extendPoint_le_iff p₀ q').mpr (le_of_lt (not_le.mp this)))
                exact absurd hx_le_q' (not_le.mpr hq'_lt_x)
              · exact hg
            obtain ⟨gy, hgy⟩ := h_y_gap
            have h_cut_eq_M' : gamma_M.cut = gy.val.cut := by
              ext q; constructor
              · intro hq
                have h1 := (hq : q ∈ inf_carrier_cut S_C_M) _ h_y_in_SC_M
                rw [hgy] at h1; exact h1
              · intro hq; by_contra hq_not
                obtain ⟨p₀, hp₀_cut, hx_le_p₀⟩ := hx_bound
                have hq_lt_y : (extendPoint q : ExtendedCarrier M atomMap r) < y := by
                  rw [hgy]; exact ⟨hq, fun h => absurd hq h⟩
                have hq_lt_x := h_abv_M q (hq_not : q ∉ inf_carrier_cut S_C_M) hq_lt_y
                have : ¬ (q ≤ p₀) := fun h => hq_not (gamma_M.downward_closed p₀ q hp₀_cut h)
                have hx_le_q := le_trans hx_le_p₀
                  ((extendPoint_le_iff p₀ q).mpr (le_of_lt (not_le.mp this)))
                exact absurd hx_le_q (not_le.mpr hq_lt_x)
            refine ⟨y, ⟨hxy, le_refl y⟩, ?_, ?_⟩
            · -- ∀ s ∈ S_C_M, y ≤ s
              intro s hs; match s, hs with
              | Sum.inl ps, hs =>
                rw [hgy]
                have : ps ∉ gamma_M.cut := by
                  intro h_in; obtain ⟨t, ht_in, ht_lt⟩ := h_has_pt_min_M ps hs
                  exact absurd ((h_in : ps ∈ inf_carrier_cut S_C_M) t ht_in) (not_le.mpr ht_lt)
                rwa [h_cut_eq_M'] at this
              | Sum.inr gs, hs =>
                rw [hgy]; intro q hq; rw [← h_cut_eq_M'] at hq
                exact (hq : q ∈ inf_carrier_cut S_C_M) _ hs
            · -- GLB
              intro e he; exact he _ h_y_in_SC_M
        · -- ¬hx_bound: gamma_M = x (as gaps), c_inf = x.
          push_neg at hx_bound
          have hx_gap : IsGap x := by
            rcases isPoint_or_isGap x with ⟨px, hpx⟩ | hg
            · exfalso
              have h_px_cut : px ∈ inf_carrier_cut S_C_M := by
                intro s hs
                rw [show (extendPoint px : ExtendedCarrier M atomMap r) = x from hpx.symm]
                exact hs.1.1
              exact absurd (hx_bound px h_px_cut) (not_lt.mpr (hpx ▸ le_refl _))
            · exact hg
          obtain ⟨gx, hgx⟩ := hx_gap
          have h_cut_eq_M : gamma_M.cut = gx.val.cut := by
            ext q; constructor
            · intro hq; by_contra h_not_in
              exact absurd (hx_bound q hq) (not_lt.mpr
                (show x ≤ (extendPoint q : ExtendedCarrier M atomMap r) by rw [hgx]; exact h_not_in))
            · intro hq s hs
              exact le_trans
                (show (extendPoint q : ExtendedCarrier M atomMap r) ≤ x by rw [hgx]; exact hq) hs.1.1
          refine ⟨x, ⟨le_refl _, hxy⟩, ?_, ?_⟩
          · intro s hs; exact hs.1.1
          · intro e he
            rcases isPoint_or_isGap e with ⟨pe, hpe⟩ | ⟨ge, hge⟩
            · rw [hpe, hgx]
              have hmem : pe ∈ gamma_M.cut := by rw [hpe] at he; exact he
              rw [h_cut_eq_M] at hmem; exact hmem
            · rw [hge, hgx]
              have hmem : ge.val.cut ⊆ gamma_M.cut := by
                intro q hq; rw [hge] at he
                intro s hs
                exact le_trans
                  (hq : (extendPoint q : ExtendedCarrier M atomMap r) ≤ Sum.inr ge) (he s hs)
              intro q hq; exact (h_cut_eq_M ▸ hmem hq : q ∈ gx.val.cut)
  -- c_inf ∈ S_C^M: for any mu u > c_inf in M, u is not a lower bound of S_C^M,
  -- so ∃ s ∈ S_C^M with s < u, giving cont_holds_cross at u from s's tail.
  have hc_inf_in_SC_M : c_inf ∈ S_C_M := by
    refine ⟨hc_inf_interval, ?_⟩
    intro u hcu huy hmu
    have : ¬ (∀ s ∈ S_C_M, u ≤ s) := by
      intro h_lb
      exact absurd (hc_inf_is_inf u h_lb) (not_le.mpr hcu)
    push_neg at this
    obtain ⟨s₀, hs₀_in, hs₀_lt⟩ := this
    exact hs₀_in.2 u hs₀_lt huy hmu
  -- Cofinal cont_holds_cross failure below c_inf: for any s ∈ [x, y] with s < c_inf,
  -- ∃ mu-point u in M with s < u ≤ c_inf, u < y, and ¬cont_holds_cross at u.
  have h_cofinal_failure_below_c_inf :
      ∀ (s : ExtendedCarrier M atomMap r),
        inClosedInterval x y s → s < c_inf →
        ∃ (u : ExtendedCarrier M atomMap r),
          s < u ∧ u ≤ c_inf ∧ u < y ∧
          mu_holds u ∧ ¬ cont_holds_cross (a_bwd ⟨n, by omega⟩) y' u := by
    intro s hs_interval hs_lt_c
    have hs_not_SC_M : s ∉ S_C_M := by
      intro hs_in; exact absurd (hc_inf_glb s hs_in) (not_le.mpr hs_lt_c)
    have : ¬ (∀ u : ExtendedCarrier M atomMap r,
        s < u → u < y → mu_holds u →
        cont_holds_cross (a_bwd ⟨n, by omega⟩) y' u) := by
      intro h_all; exact hs_not_SC_M ⟨hs_interval, h_all⟩
    push_neg at this
    obtain ⟨v, hsv, hvy, hmu_v, h_not_cont_v⟩ := this
    rcases le_or_gt v c_inf with hv_le_c | hv_gt_c
    · exact ⟨v, hsv, hv_le_c, hvy, hmu_v, h_not_cont_v⟩
    · exact absurd (hc_inf_in_SC_M.2 v hv_gt_c hvy hmu_v) h_not_cont_v
  -- Step 3: Get a 1-round forward strategy for game-based properties.
  have h1 : ghr93_duplicator_wins M N atomMap 1 r x y x' y' :=
    ghr93_duplicator_wins_round_mono (by omega : 1 ≤ 4 + 3 * n) hxy hx'y' h_fwd
  -- Step 4-5: Prove c satisfies the suffices requirements.
  -- c = inf(S_C^M) has interval and infimum properties.
  -- Formula agreement, gap/point, and boundary correspondence require
  -- the game to connect c (M-side infimum) with d (N-side infimum).
  suffices h_exists : ∃ c : ExtendedCarrier M atomMap r,
      inClosedInterval x y c ∧
      (∀ (A : StaviFormula), stavi_depth A ≤ r →
        (stavi_temporal_truth_mu M atomMap r c A ↔
         stavi_temporal_truth_mu N atomMap r d A)) ∧
      ((IsPoint c ↔ IsPoint d) ∧ (IsGap c ↔ IsGap d)) ∧
      -- Boundary order correspondence: c's position relative to x,y
      -- mirrors d's position relative to x',y'. This is essential for
      -- the degenerate interval cases (x'=d or d=y') where we need to
      -- derive x=c or c=y to apply ghr93_duplicator_wins_degenerate_gap.
      ((x = c ↔ x' = d) ∧ (c = y ↔ d = y')) ∧
      -- GHR93 Claim 1 interior: for the left boundary (a_pad ends with c),
      -- a response exists with d at position 1+3n. Proved inside suffices
      -- where c = c_inf gives access to the K⁻(¬D) argument at rank r+2.
      (x' ≠ d → d ≠ y' →
        ∀ (a_pad : Fin (1 + 3 * n + 1) → ExtendedCarrier M atomMap r),
          (∀ i, inClosedInterval x y (a_pad i)) →
          a_pad ⟨1 + 3 * n, by omega⟩ = c →
          ∃ (a'_full : Fin (1 + 3 * n + 1) → ExtendedCarrier N atomMap r),
            (∀ i, inClosedInterval x' y' (a'_full i)) ∧
            (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
              ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
                ghr93_winning_condition (1 + 3 * n + 1)
                  (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) ∧
            a'_full ⟨1 + 3 * n, by omega⟩ = d) ∧
      -- GHR93 Claim 1 interior: for the right boundary (a_pad starts with c),
      -- a response exists with d at position 0.
      (x' ≠ d → d ≠ y' →
        ∀ (a_pad : Fin (1 + 3 * n + 1) → ExtendedCarrier M atomMap r),
          (∀ i, inClosedInterval x y (a_pad i)) →
          a_pad ⟨0, by omega⟩ = c →
          ∃ (a'_full : Fin (1 + 3 * n + 1) → ExtendedCarrier N atomMap r),
            (∀ i, inClosedInterval x' y' (a'_full i)) ∧
            (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
              ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
                ghr93_winning_condition (1 + 3 * n + 1)
                  (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) ∧
            a'_full ⟨0, by omega⟩ = d) by
    obtain ⟨c, hc_interval, hcd_form, hcd_gp, hcd_boundary,
            h_interior_d_left_from_suffices, h_interior_d_right_from_suffices⟩ := h_exists
    refine ⟨c, d, ?_⟩
    -- Step 4-5: Apply strategy restriction + IH to get sigma and tau
    -- Forward strategy: (4+3n) rounds on [x,y] vs [x',y']
    -- By round_mono: (n+2) rounds on [x,y] (since n+2 ≤ 4+3n for n ≥ 0)
    -- By strategy_restrict_left: (n+1) rounds on [x,c] vs [x',d]
    -- By round_mono: (1+3n) rounds on [x,c] vs [x',d] (since 1+3n ≤ n+1+... wait)
    --
    -- Actually: we need (1+3n) rounds on the sub-interval for the IH.
    -- strategy_restrict consumes 1 round: (k+1) → k on sub-interval.
    -- So we need at least (2+3n) rounds on the full interval.
    -- We have (4+3n) rounds. By round_mono: (2+3n) rounds.
    -- By strategy_restrict: (1+3n) rounds on sub-interval. OK.
    have h_mono_left : ghr93_duplicator_wins M N atomMap (1 + 3 * n + 1) r x y x' y' :=
      ghr93_duplicator_wins_round_mono (by omega : 1 + 3 * n + 1 ≤ 4 + 3 * n) hxy hx'y' h_fwd
    have h_mono_left_r1 : ghr93_duplicator_wins M N atomMap (1 + 3 * n + 1) (r + 2)
        (rank_embed (by omega : r ≤ r + 2) x) (rank_embed (by omega : r ≤ r + 2) y)
        (rank_embed (by omega : r ≤ r + 2) x') (rank_embed (by omega : r ≤ r + 2) y') :=
      ghr93_duplicator_wins_round_mono (by omega : 1 + 3 * n + 1 ≤ 4 + 3 * n)
        ((rank_embed_le (by omega : r ≤ r + 2) x y).mpr hxy)
        ((rank_embed_le (by omega : r ≤ r + 2) x' y').mpr hx'y') h_fwd_r1
    -- D-consistency (existential form) and strategy restriction.
    -- d_consistency_left/right provide: for any padded selection ending/starting
    -- with c, there EXISTS a response with bounds + winning + d at boundary.
    -- ghr93_strategy_restrict_left/right consume this directly.
    -- GHR93 Claim 1: d is uniquely determined among elements with the same
    -- rank-r type, gap/point status, and boundary position.
    -- This follows from the infimum construction of d and the rank-(r+2)
    -- forward strategy (h_fwd_r1). The proof requires constructing the
    -- rank-(r+2) formula K⁻(¬D) = neg(std_snce(neg(base .bot), D)) where
    -- D is the pigeonhole formula with stavi_depth D ≤ r. The formula
    -- K⁻(¬D) has depth r+2 (within the rank budget after the r+1→r+2 bump).
    -- Key fact: d ∈ S_C (tail condition from GLB property).
    have hd_in_SC : d ∈ S_C := by
      refine ⟨hd_interval, ?_⟩
      intro u hdu huy' hmu
      have : ¬ (∀ s ∈ S_C, u ≤ s) := by
        intro h_lb
        exact absurd (hd_is_inf u h_lb) (not_le.mpr hdu)
      push_neg at this
      obtain ⟨s₀, hs₀_in, hs₀_lt⟩ := this
      exact hs₀_in.2 u hs₀_lt huy' hmu
    -- Cofinal failure below d: for any element s ∈ [x', y'] with s < d,
    -- there exists a mu-point u with s < u ≤ d, u < y', where
    -- cont_holds fails. This follows from s ∉ S_C (since d = inf(S_C))
    -- and d ∈ S_C (which rules out failures above d).
    have h_cofinal_failure_below_d :
        ∀ (s : ExtendedCarrier N atomMap r),
          inClosedInterval x' y' s → s < d →
          ∃ (u : ExtendedCarrier N atomMap r),
            s < u ∧ u ≤ d ∧ u < y' ∧
            mu_holds u ∧ ¬ cont_holds (a_bwd ⟨n, by omega⟩) y' u := by
      intro s hs_interval hs_lt_d
      -- s < d = inf(S_C), so s ∉ S_C
      have hs_not_SC : s ∉ S_C := by
        intro hs_in; exact absurd (hd_glb s hs_in) (not_le.mpr hs_lt_d)
      -- s ∈ [x', y'] and s ∉ S_C: tail condition fails
      have : ¬ (∀ u : ExtendedCarrier N atomMap r,
          s < u → u < y' → mu_holds u →
          cont_holds (a_bwd ⟨n, by omega⟩) y' u) := by
        intro h_all; exact hs_not_SC ⟨hs_interval, h_all⟩
      push_neg at this
      obtain ⟨v, hsv, hvy', hmu_v, h_not_cont_v⟩ := this
      -- v is a mu-point with s < v < y' and ¬cont_holds at v.
      -- Show v ≤ d: if v > d, then v ∈ (d, y') and d ∈ S_C gives
      -- cont_holds at v, contradicting h_not_cont_v.
      rcases le_or_gt v d with hv_le_d | hv_gt_d
      · exact ⟨v, hsv, hv_le_d, hvy', hmu_v, h_not_cont_v⟩
      · -- v > d: contradiction from d ∈ S_C
        exact absurd (hd_in_SC.2 v hv_gt_d hvy' hmu_v) h_not_cont_v
    -- GHR93 Claim 1 interior case: use rank_down(h_mono_left_r1) to construct
    -- responses where the boundary position equals d. This replaces the
    -- mathematically false h_d_unique universal claim.
    -- The proof uses ghr93_duplicator_wins_rank_down which projects rank r+2
    -- responses to rank r. The key property is that all projected responses
    -- come from the rank r+2 game, so the position corresponding to c
    -- (mapped to rank_embed(c) at rank r+2) gets a response that projects to d.
    -- GHR93 Claim 1 interior case (left/right):
    -- Construct response with position n = d (left) or position 0 = d (right).
    -- The proof inlines ghr93_duplicator_wins_rank_down's construction:
    -- embed Spoiler's selection to rank r+2, play through h_mono_left_r1,
    -- project responses back. The K⁻(¬D) argument (already proved in the
    -- Claim 1 block below) shows the rank r+2 response at the boundary
    -- position equals rank_embed(d), so the projection gives d.
    -- GHR93 Claim 1 interior case: proved in the suffices block where c = c_inf
    -- gives access to the full K⁻(¬D) argument at rank r+2.
    have h_interior_d_left := h_interior_d_left_from_suffices
    have h_interior_d_right := h_interior_d_right_from_suffices
    have h_d_consistent_left :=
      d_consistency_left hxy hx'y' hc_interval hd_interval
        hcd_form hcd_gp hcd_boundary h_mono_left h_mono_left_r1 h_pt h_interior_d_left
    have h_d_consistent_right :=
      d_consistency_right hxy hx'y' hc_interval hd_interval
        hcd_form hcd_gp hcd_boundary h_mono_left h_mono_left_r1 h_pt h_interior_d_right
    have h_restrict_left : ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x c x' d :=
      ghr93_strategy_restrict_left
        hc_interval.1 hc_interval.2 hd_interval.1 hd_interval.2
        hcd_form hcd_gp h_d_consistent_left h_pt
    have h_restrict_right : ghr93_duplicator_wins M N atomMap (1 + 3 * n) r c y d y' :=
      ghr93_strategy_restrict_right
        hc_interval.1 hc_interval.2 hd_interval.1 hd_interval.2
        hcd_form hcd_gp h_d_consistent_right h_pt
    -- Construct sigma: backward n-round on [x',d] vs [x,c] at rank r+delta
    -- GHR93: sigma lives at rank r+delta on rank-embedded positions
    -- Two cases: degenerate (x' = d, both gaps) or non-degenerate (∃ point in [x',d])
    have sigma : ghr93_duplicator_wins N M atomMap n (r + delta)
        (rank_embed (by omega : r ≤ r + delta) x')
        (rank_embed (by omega : r ≤ r + delta) d)
        (rank_embed (by omega : r ≤ r + delta) x)
        (rank_embed (by omega : r ≤ r + delta) c) := by
      by_cases hx'd_eq : x' = d
      · -- Degenerate: x' = d. By boundary correspondence, x = c.
        have hxc_eq : x = c := hcd_boundary.1.mpr hx'd_eq
        rcases isPoint_or_isGap d with ⟨p_d, hp_d⟩ | ⟨g_d, hg_d⟩
        · -- d is a point: [x',d] = [d,d] with d a point, so d witnesses itself
          have h_pt_sub : ∃ p, inClosedInterval x' d (extendPoint p) := by
            rw [hx'd_eq, hp_d]; exact ⟨p_d, le_refl _, le_refl _⟩
          exact ih hc_interval.1 hd_interval.1 h_pt_sub h_restrict_left
        · -- d is a gap, x' = d: fully degenerate. By gap agreement, c is a gap.
          have hc_gap : IsGap c := hcd_gp.2.mpr ⟨g_d, hg_d⟩
          obtain ⟨g_c, hg_c⟩ := hc_gap
          -- Directly construct degenerate gap game at rank r+delta.
          -- Both rank_embed d and rank_embed c are gaps, so Round 2 is vacuous
          -- (no carrier point in a gap interval).
          rw [hx'd_eq, hxc_eq]
          intro a ha
          have ha_eq : ∀ i, a i = rank_embed (by omega : r ≤ r + delta) d :=
            fun i => le_antisymm (ha i).2 (ha i).1
          refine ⟨fun _ => rank_embed (by omega : r ≤ r + delta) c,
                  fun _ => ⟨le_refl _, le_refl _⟩, ?_⟩
          intro b' hb'
          -- rank_embed c is a gap: extendPoint b' = rank_embed c is impossible
          have hg_c_embed : rank_embed (by omega : r ≤ r + delta) c =
              Sum.inr (rank_embed_gap (by omega : r ≤ r + delta) g_c) := by
            rw [hg_c]; rfl
          have h_eq : extendPoint b' = rank_embed (by omega : r ≤ r + delta) c :=
            le_antisymm hb'.2 hb'.1
          exact absurd (h_eq.symm ▸ hg_c_embed : extendPoint b' =
            Sum.inr (rank_embed_gap (by omega : r ≤ r + delta) g_c))
            (by simp [extendPoint])
      · -- Non-degenerate: x' ≠ d, so x' < d (strict).
        have hx'd_lt : x' < d := lt_of_le_of_ne hd_interval.1 hx'd_eq
        -- Find a point witness in [x', d]
        have h_pt_sub : ∃ p, inClosedInterval x' d (extendPoint p) := by
          rcases isPoint_or_isGap d with ⟨p_d, hp_d⟩ | ⟨g_d, hg_d⟩
          · rw [hp_d] at hd_interval ⊢
            exact ⟨p_d, hd_interval.1, le_refl _⟩
          · rcases isPoint_or_isGap x' with ⟨x_pt, hx_pt⟩ | ⟨g_x, hg_x⟩
            · rw [hx_pt] at hd_interval ⊢
              exact ⟨x_pt, le_refl _, hd_interval.1⟩
            · rw [hg_x] at hx'd_lt ⊢; rw [hg_d] at hx'd_lt ⊢
              exact point_between_strict_gaps rfl rfl hx'd_lt
        exact ih hc_interval.1 hd_interval.1 h_pt_sub h_restrict_left
    -- Construct tau: backward n-round on [d,y'] vs [c,y] at rank r+delta
    -- GHR93: tau lives at rank r+delta on rank-embedded positions
    have tau : ghr93_duplicator_wins N M atomMap n (r + delta)
        (rank_embed (by omega : r ≤ r + delta) d)
        (rank_embed (by omega : r ≤ r + delta) y')
        (rank_embed (by omega : r ≤ r + delta) c)
        (rank_embed (by omega : r ≤ r + delta) y) := by
      by_cases hdy'_eq : d = y'
      · -- Degenerate: d = y'. By boundary correspondence, c = y.
        have hcy_eq : c = y := hcd_boundary.2.mpr hdy'_eq
        rcases isPoint_or_isGap d with ⟨p_d, hp_d⟩ | ⟨g_d, hg_d⟩
        · have h_pt_sub : ∃ p, inClosedInterval d y' (extendPoint p) :=
            ⟨p_d, le_of_eq hp_d, le_of_eq (show extendPoint p_d = y' from hp_d.symm.trans hdy'_eq)⟩
          exact ih hc_interval.2 hd_interval.2 h_pt_sub h_restrict_right
        · have hc_gap : IsGap c := hcd_gp.2.mpr ⟨g_d, hg_d⟩
          obtain ⟨g_c, hg_c⟩ := hc_gap
          -- Directly construct degenerate gap game at rank r+delta.
          -- Both rank_embed d and rank_embed c are gaps, so Round 2 is vacuous.
          rw [show y' = d from hdy'_eq.symm, show y = c from hcy_eq.symm]
          intro a ha
          have ha_eq : ∀ i, a i = rank_embed (by omega : r ≤ r + delta) d :=
            fun i => le_antisymm (ha i).2 (ha i).1
          refine ⟨fun _ => rank_embed (by omega : r ≤ r + delta) c,
                  fun _ => ⟨le_refl _, le_refl _⟩, ?_⟩
          intro b' hb'
          -- rank_embed c is a gap: extendPoint b' = rank_embed c is impossible
          have hg_c_embed : rank_embed (by omega : r ≤ r + delta) c =
              Sum.inr (rank_embed_gap (by omega : r ≤ r + delta) g_c) := by
            rw [hg_c]; rfl
          have h_eq : extendPoint b' = rank_embed (by omega : r ≤ r + delta) c :=
            le_antisymm hb'.2 hb'.1
          exact absurd (h_eq.symm ▸ hg_c_embed : extendPoint b' =
            Sum.inr (rank_embed_gap (by omega : r ≤ r + delta) g_c))
            (by simp [extendPoint])
      · have hdy'_lt : d < y' := lt_of_le_of_ne hd_interval.2 hdy'_eq
        have h_pt_sub : ∃ p, inClosedInterval d y' (extendPoint p) := by
          rcases isPoint_or_isGap d with ⟨p_d, hp_d⟩ | ⟨g_d, hg_d⟩
          · exact ⟨p_d, le_of_eq hp_d,
              le_of_lt (show extendPoint p_d < y' by rw [show extendPoint p_d = d from hp_d.symm]; exact hdy'_lt)⟩
          · rcases isPoint_or_isGap y' with ⟨y_pt, hy_pt⟩ | ⟨g_y, hg_y⟩
            · exact ⟨y_pt,
                le_of_lt (show d < extendPoint y_pt by rw [show extendPoint y_pt = y' from hy_pt.symm]; exact hdy'_lt),
                le_of_eq (show extendPoint y_pt = y' from hy_pt.symm)⟩
            · rw [hg_d] at hdy'_lt ⊢; rw [hg_y] at hdy'_lt ⊢
              exact point_between_strict_gaps rfl rfl hdy'_lt
        exact ih hc_interval.2 hd_interval.2 h_pt_sub h_restrict_right
    -- M-side sub-interval point witnesses (for SplitPointProps)
    -- Disjunctive form: either a carrier point exists in the sub-interval,
    -- or the sub-interval is degenerate (x = c or c = y) with c a gap.
    have h_pt_xc_w : (∃ p, inClosedInterval x c (extendPoint p)) ∨
        (x = c ∧ x' = d ∧ IsGap c ∧ IsGap d) := by
      by_cases hxc_eq : x = c
      · rcases isPoint_or_isGap c with ⟨p_c, hp_c⟩ | ⟨g_c, hg_c⟩
        · left; rw [hxc_eq, hp_c]; exact ⟨p_c, le_refl _, le_refl _⟩
        · right
          have hx'd_eq : x' = d := hcd_boundary.1.mp hxc_eq
          have hd_gap : IsGap d := hcd_gp.2.mp ⟨g_c, hg_c⟩
          exact ⟨hxc_eq, hx'd_eq, ⟨g_c, hg_c⟩, hd_gap⟩
      · left
        rcases isPoint_or_isGap c with ⟨p_c, hp_c⟩ | ⟨g_c, hg_c⟩
        · rw [hp_c] at hc_interval ⊢
          exact ⟨p_c, hc_interval.1, le_refl _⟩
        · obtain ⟨p_M, hp_M⟩ := h_pt_M
          rcases le_or_lt (extendPoint p_M) c with h | h
          · exact ⟨p_M, hp_M.1, h⟩
          · rcases isPoint_or_isGap x with ⟨x_pt, hx_pt⟩ | ⟨g_x, hgx⟩
            · rw [hx_pt] at hc_interval ⊢
              exact ⟨x_pt, le_refl _, hc_interval.1⟩
            · have hxc_lt : x < c := lt_of_le_of_ne hc_interval.1 hxc_eq
              rw [hgx] at hxc_lt ⊢; rw [hg_c] at hxc_lt ⊢
              exact point_between_strict_gaps rfl rfl hxc_lt
    have h_pt_cy_w : (∃ p, inClosedInterval c y (extendPoint p)) ∨
        (c = y ∧ d = y' ∧ IsGap c ∧ IsGap d) := by
      by_cases hcy_eq : c = y
      · rcases isPoint_or_isGap c with ⟨p_c, hp_c⟩ | ⟨g_c, hg_c⟩
        · left; rw [← hcy_eq, hp_c]; exact ⟨p_c, le_refl _, le_refl _⟩
        · right
          have hdy'_eq : d = y' := hcd_boundary.2.mp hcy_eq
          have hd_gap : IsGap d := hcd_gp.2.mp ⟨g_c, hg_c⟩
          exact ⟨hcy_eq, hdy'_eq, ⟨g_c, hg_c⟩, hd_gap⟩
      · left
        rcases isPoint_or_isGap c with ⟨p_c, hp_c⟩ | ⟨g_c, hg_c⟩
        · rw [hp_c] at hc_interval ⊢
          exact ⟨p_c, le_refl _, hc_interval.2⟩
        · obtain ⟨p_M, hp_M⟩ := h_pt_M
          rcases le_or_lt c (extendPoint p_M) with h | h
          · exact ⟨p_M, h, hp_M.2⟩
          · rcases isPoint_or_isGap y with ⟨y_pt, hy_pt⟩ | ⟨g_y, hgy⟩
            · rw [hy_pt] at hc_interval ⊢
              exact ⟨y_pt, hc_interval.2, le_refl _⟩
            · have hcy_lt : c < y := lt_of_le_of_ne hc_interval.2 hcy_eq
              rw [hg_c] at hcy_lt ⊢; rw [hgy] at hcy_lt ⊢
              exact point_between_strict_gaps rfl rfl hcy_lt
    exact {
      hc_interval := hc_interval
      hd_interval := hd_interval
      hd_le_an := hd_le_an_proof
      hxc := hc_interval.1
      hcy := hc_interval.2
      hx'd := hd_interval.1
      hdy' := hd_interval.2
      h_pt_xc := h_pt_xc_w
      h_pt_cy := h_pt_cy_w
      hcd_form := hcd_form
      hcd_gp := hcd_gp
      sigma := sigma
      tau := tau
      h_fwd_n1 := ghr93_duplicator_wins_round_mono (by omega : n + 1 ≤ 4 + 3 * n) hxy hx'y' h_fwd
      h_d_compat_left := h_d_consistent_left
    }
  -- Prove the existence of c with the needed properties using c_inf = inf(S_C^M).
  -- GHR93 Claim 1: Use the rank-(r+2) game h_fwd_r1 to show that the game
  -- response to rank_embed(c_inf) equals rank_embed(d). This gives formula
  -- agreement at depth r+2 between rank_embed(c_inf) and rank_embed(d), which
  -- projects to depth-r agreement between c_inf and d via rank_embed_stavi_truth_mu.
  -- Gap/point and boundary are derived from the rank-(r+2) game's winning condition.
  -- This completely bypasses the rank-r game and t_game, avoiding the depth
  -- mismatch that makes t_game = d unprovable via hform_1 (depth r only).
  --
  -- Step 1: Reduce h_fwd_r1 to 1 round at rank r+2
  have h1_r2 : ghr93_duplicator_wins M N atomMap 1 (r + 2)
      (rank_embed (by omega : r ≤ r + 2) x)
      (rank_embed (by omega : r ≤ r + 2) y)
      (rank_embed (by omega : r ≤ r + 2) x')
      (rank_embed (by omega : r ≤ r + 2) y') :=
    ghr93_duplicator_wins_round_mono (by omega : 1 ≤ 4 + 3 * n)
      ((rank_embed_le (by omega : r ≤ r + 2) x y).mpr hxy)
      ((rank_embed_le (by omega : r ≤ r + 2) x' y').mpr hx'y') h_fwd_r1
  -- Step 2: Play with rank_embed(c_inf)
  have hc_inf_r2 : inClosedInterval
      (rank_embed (by omega : r ≤ r + 2) x)
      (rank_embed (by omega : r ≤ r + 2) y)
      (rank_embed (by omega : r ≤ r + 2) c_inf) :=
    (rank_embed_inClosedInterval (by omega : r ≤ r + 2) x y c_inf).mpr hc_inf_interval
  obtain ⟨a'_r2, ha'_r2, hwin_r2⟩ := h1_r2
    (fun _ => rank_embed (by omega : r ≤ r + 2) c_inf) (fun _ => hc_inf_r2)
  set r2_resp := a'_r2 ⟨0, by omega⟩ with r2_resp_def
  -- Step 3: Direction 2 at rank r+2 (r2_resp ≥ rank_embed(d))
  -- r2_resp ∈ S_C at rank r+2, hence rank_embed(d) ≤ r2_resp.
  -- Proof mirrors h_t_game_in_SC: for mu u > r2_resp in N at rank r+2,
  -- play Round 2 to get M-side point above rank_embed(c_inf),
  -- then use c_inf ∈ S_C_M and formula transfer.
  -- Re-derive d ∈ S_C and cofinal failure below d (these were proved in the
  -- suffices branch but are not in scope here).
  have hd_in_SC : d ∈ S_C := by
    refine ⟨hd_interval, ?_⟩
    intro u hdu huy' hmu
    have : ¬ (∀ s ∈ S_C, u ≤ s) := by
      intro h_lb
      exact absurd (hd_is_inf u h_lb) (not_le.mpr hdu)
    push_neg at this
    obtain ⟨s₀, hs₀_in, hs₀_lt⟩ := this
    exact hs₀_in.2 u hs₀_lt huy' hmu
  have h_cofinal_failure_below_d :
      ∀ (s : ExtendedCarrier N atomMap r),
        inClosedInterval x' y' s → s < d →
        ∃ (u : ExtendedCarrier N atomMap r),
          s < u ∧ u ≤ d ∧ u < y' ∧
          mu_holds u ∧ ¬ cont_holds (a_bwd ⟨n, by omega⟩) y' u := by
    intro s hs_interval hs_lt_d
    have hs_not_SC : s ∉ S_C := by
      intro hs_in; exact absurd (hd_glb s hs_in) (not_le.mpr hs_lt_d)
    have : ¬ (∀ u : ExtendedCarrier N atomMap r,
        s < u → u < y' → mu_holds u →
        cont_holds (a_bwd ⟨n, by omega⟩) y' u) := by
      intro h_all; exact hs_not_SC ⟨hs_interval, h_all⟩
    push_neg at this
    obtain ⟨v, hsv, hvy', hmu_v, h_not_cont_v⟩ := this
    rcases le_or_gt v d with hv_le_d | hv_gt_d
    · exact ⟨v, hsv, hv_le_d, hvy', hmu_v, h_not_cont_v⟩
    · exact absurd (hd_in_SC.2 v hv_gt_d hvy' hmu_v) h_not_cont_v
  -- Steps 3-5 combined: r2_resp = rank_embed(d)
  -- GHR93 Claim 1: the game response must equal rank_embed of the infimum.
  --
  -- Direction 1 (r2_resp ≤ rank_embed(d)): K⁻(¬D_M) argument.
  --   Apply pigeonhole_definable_formula_cross to S_C_M to get D_M of depth ≤ r
  --   that holds on (a_bwd(n), y') in N but fails cofinally below c_inf in M.
  --   Construct K⁻(¬D_M) = neg(std_snce(base(⊤), D_M)) of depth ≤ r + 2.
  --   K⁻(¬D_M)(c_inf) = TRUE (¬D_M cofinal below c_inf in M).
  --   Transfer via hform_r2_1 at depth r+2: K⁻(¬D_M)(r2_resp) = TRUE.
  --   If r2_resp > rank_embed(d): D_M holds on (d, y') (from d ∈ S_C),
  --   so Since(⊤, D_M)(r2_resp) = TRUE, contradicting K⁻(¬D_M)(r2_resp).
  --
  -- Direction 2 (rank_embed(d) ≤ r2_resp): game Round 2 argument.
  --   For any mu p with r2_resp < extendPoint p < y' (at rank r+2):
  --   play p in Round 2, get M-side b with c_inf < b < y, cont_holds_cross at b,
  --   formula transfer gives cont_holds at p. So cont_holds above r2_resp.
  --   By contradiction: if r2_resp < rank_embed(d), find failure between
  --   r2_resp and d (from cofinal failure), contradicting cont_holds above r2_resp.
  --   The carrier-point case gives contradiction directly; the gap case
  --   follows from Direction 1 giving r2_resp ≤ rank_embed(d).
  --
  -- We prove both directions and combine.
  -- Direction 2 helper: cont_holds transfer via game Round 2.
  -- For any carrier point p of N with r2_resp < extendPoint p (at rank r+2)
  -- and extendPoint p < y' (at rank r), cont_holds holds at extendPoint p.
  have h_cont_transfer : ∀ (p : N.carrier),
      r2_resp < (extendPoint p : ExtendedCarrier N atomMap (r + 2)) →
      (extendPoint p : ExtendedCarrier N atomMap r) < y' →
      cont_holds (a_bwd ⟨n, by omega⟩) y' (extendPoint p) := by
    intro p hr2_lt_p hp_lt_y'
    -- Play p in Round 2 of the rank-(r+2) game
    have hp_in_r2 : inClosedInterval
        (rank_embed (by omega : r ≤ r + 2) x')
        (rank_embed (by omega : r ≤ r + 2) y')
        (extendPoint p : ExtendedCarrier N atomMap (r + 2)) := by
      constructor
      · -- rank_embed(x') ≤ extendPoint(p) at rank r+2
        -- From ha'_r2: rank_embed(x') ≤ r2_resp, and r2_resp < extendPoint(p)
        exact le_trans (ha'_r2 ⟨0, by omega⟩).1 (le_of_lt hr2_lt_p)
      · -- extendPoint(p) ≤ rank_embed(y') at rank r+2
        -- hp_lt_y' : extendPoint(p) < y' at rank r
        -- rank_embed preserves: rank_embed(extendPoint(p)) < rank_embed(y')
        rw [← rank_embed_point (by omega : r ≤ r + 2) p]
        exact le_of_lt ((rank_embed_lt (by omega : r ≤ r + 2)
          (extendPoint p) y').mpr hp_lt_y')
    obtain ⟨b_u, hb_u_in, hcond_u⟩ := hwin_r2 p hp_in_r2
    obtain ⟨hord_u, _hgp_u, hform_u⟩ := hcond_u
    -- Extract order at index (1,2): rank_embed(c_inf) vs extendPoint(b_u)
    have hord_12 := hord_u ⟨1, by omega⟩ ⟨2, by omega⟩
    simp only [game_tuple, show (1 : Nat) ≠ 0 from by omega,
               show (1 : Nat) ≠ 1 + 1 from by omega,
               show (1 : Nat) ≠ 1 + 2 from by omega, dite_false,
               show 1 - 1 = 0 from by omega,
               show (2 : Nat) ≠ 0 from by omega,
               show (2 : Nat) = 1 + 1 from by omega, dite_true] at hord_12
    -- c_inf < extendPoint b_u at rank r (from order type)
    have hc_lt_bu_r : c_inf < (extendPoint b_u : ExtendedCarrier M atomMap r) := by
      have : rank_embed (by omega : r ≤ r + 2) c_inf <
          (extendPoint b_u : ExtendedCarrier M atomMap (r + 2)) := by
        rw [← rank_embed_point (by omega : r ≤ r + 2) p] at hr2_lt_p
        exact hord_12.1.mpr hr2_lt_p
      rw [← rank_embed_point (by omega : r ≤ r + 2) b_u] at this
      exact (rank_embed_lt (by omega : r ≤ r + 2) c_inf (extendPoint b_u)).mp this
    -- Extract order at index (2,3): extendPoint(b_u) vs rank_embed(y)
    have hord_23 := hord_u ⟨2, by omega⟩ ⟨3, by omega⟩
    simp only [game_tuple, show (2 : Nat) ≠ 0 from by omega,
               show (2 : Nat) = 1 + 1 from by omega, dite_true,
               show (3 : Nat) ≠ 0 from by omega,
               show ¬((3 : Nat) = 1 + 1) from by omega,
               show (3 : Nat) = 1 + 2 from by omega, dite_true] at hord_23
    -- extendPoint(b_u) < y at rank r
    have hbu_lt_y : (extendPoint b_u : ExtendedCarrier M atomMap r) < y := by
      have hp_lt_y'_r2 : (extendPoint p : ExtendedCarrier N atomMap (r + 2)) <
          rank_embed (by omega : r ≤ r + 2) y' := by
        rw [← rank_embed_point (by omega : r ≤ r + 2) p]
        exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint p) y').mpr hp_lt_y'
      have : (extendPoint b_u : ExtendedCarrier M atomMap (r + 2)) <
          rank_embed (by omega : r ≤ r + 2) y := hord_23.1.mpr hp_lt_y'_r2
      rw [← rank_embed_point (by omega : r ≤ r + 2) b_u] at this
      exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint b_u) y).mp this
    -- c_inf ∈ S_C_M: cont_holds_cross at extendPoint b_u
    have hmu_bu : mu_holds (extendPoint (sig := sig) (atomMap := atomMap) (r := r) b_u) :=
      ⟨b_u, rfl⟩
    have h_cont_cross_bu : cont_holds_cross (a_bwd ⟨n, by omega⟩) y' (extendPoint b_u) :=
      hc_inf_in_SC_M.2 (extendPoint b_u) hc_lt_bu_r hbu_lt_y hmu_bu
    -- Transfer: for any A with depth ≤ r, if A holds at all mu in (a_bwd(n), y'),
    -- then A holds at extendPoint(b_u) in M (from cont_holds_cross),
    -- then A holds at extendPoint(p) in N (from formula agreement).
    intro A hA h_all_mu
    have hA_bu : stavi_temporal_truth_mu M atomMap r (extendPoint b_u) A :=
      h_cont_cross_bu A hA h_all_mu
    -- Formula agreement at index 2, depth ≤ r+2
    have hform_2 := hform_u ⟨2, by omega⟩ A (le_trans hA (by omega : r ≤ r + 2))
    simp only [game_tuple, show (2 : Nat) ≠ 0 from by omega, dite_false,
               show (2 : Nat) = 1 + 1 from by omega, dite_true] at hform_2
    -- Bridge from rank r to rank r+2 via rank_embed_stavi_truth_mu.
    -- hform_2 : truth M (r+2) (extendPoint b_u) A ↔ truth N (r+2) (extendPoint p) A
    -- We need: truth N r (extendPoint p) A
    -- extendPoint b_u at rank r+2 = rank_embed(extendPoint b_u at rank r) by rank_embed_point.
    -- So truth M (r+2) (extendPoint b_u) A ↔ truth M r (extendPoint b_u) A.
    -- Similarly for p on the N side.
    have hM_bridge : stavi_temporal_truth_mu M atomMap (r + 2)
        (extendPoint b_u : ExtendedCarrier M atomMap (r + 2)) A ↔
        stavi_temporal_truth_mu M atomMap r (extendPoint b_u : ExtendedCarrier M atomMap r) A := by
      conv_lhs => rw [show (extendPoint b_u : ExtendedCarrier M atomMap (r + 2)) =
        rank_embed (by omega : r ≤ r + 2) (extendPoint b_u : ExtendedCarrier M atomMap r) from
        (rank_embed_point (by omega : r ≤ r + 2) b_u).symm]
      exact rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) (extendPoint b_u) A
    have hN_bridge : stavi_temporal_truth_mu N atomMap (r + 2)
        (extendPoint p : ExtendedCarrier N atomMap (r + 2)) A ↔
        stavi_temporal_truth_mu N atomMap r (extendPoint p : ExtendedCarrier N atomMap r) A := by
      conv_lhs => rw [show (extendPoint p : ExtendedCarrier N atomMap (r + 2)) =
        rank_embed (by omega : r ≤ r + 2) (extendPoint p : ExtendedCarrier N atomMap r) from
        (rank_embed_point (by omega : r ≤ r + 2) p).symm]
      exact rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) (extendPoint p) A
    exact hN_bridge.mp (hform_2.mp (hM_bridge.mpr hA_bu))
  -- Direction 1: r2_resp ≤ rank_embed(d)
  -- GHR93 Claim 1 Step 2.2: K⁻(¬D_M) argument.
  -- Apply pigeonhole_definable_formula_cross to get D_M, construct K⁻(¬D_M),
  -- transfer via game, derive bound.
  have h_r2_resp_le_d : r2_resp ≤ rank_embed (by omega : r ≤ r + 2) d := by
    -- By contradiction: assume rank_embed(d) < r2_resp.
    by_contra h_not_le
    push_neg at h_not_le
    -- h_not_le : rank_embed d < r2_resp
    -- GHR93 Claim 1, Direction 1: K⁻(¬D) argument.
    -- Extract order agreement at indices (0,1) from the game.
    -- Instantiate hwin_r2 with any carrier point from h_pt to get winning condition.
    obtain ⟨p_N, hp_N⟩ := h_pt
    have hp_N_r2 : inClosedInterval
        (rank_embed (by omega : r ≤ r + 2) x')
        (rank_embed (by omega : r ≤ r + 2) y')
        (extendPoint p_N : ExtendedCarrier N atomMap (r + 2)) := by
      rw [← rank_embed_point (by omega : r ≤ r + 2) p_N]
      exact (rank_embed_inClosedInterval (by omega : r ≤ r + 2) x' y'
        (extendPoint p_N)).mpr hp_N
    obtain ⟨b_w, hb_w_in, hcond_w⟩ := hwin_r2 p_N hp_N_r2
    obtain ⟨hord_w, hgp_w, hform_w⟩ := hcond_w
    -- Order agreement at index (0,1): rank_embed(x) < rank_embed(c_inf) ↔ rank_embed(x') < r2_resp
    have hord_01 := hord_w ⟨0, by omega⟩ ⟨1, by omega⟩
    simp only [game_tuple, show (0 : Nat) = 0 from rfl, dite_true,
               show (1 : Nat) ≠ 0 from by omega,
               show (1 : Nat) ≠ 1 + 1 from by omega,
               show (1 : Nat) ≠ 1 + 2 from by omega, dite_false,
               show 1 - 1 = 0 from by omega] at hord_01
    -- hord_01 : rank_embed x < rank_embed c_inf ↔ rank_embed x' < r2_resp
    -- Also extract (1,3): rank_embed(c_inf) < rank_embed(y) ↔ r2_resp < rank_embed(y')
    have hord_13 := hord_w ⟨1, by omega⟩ ⟨3, by omega⟩
    simp only [game_tuple, show (1 : Nat) ≠ 0 from by omega,
               show (1 : Nat) ≠ 1 + 1 from by omega,
               show (1 : Nat) ≠ 1 + 2 from by omega, dite_false,
               show 1 - 1 = 0 from by omega,
               show (3 : Nat) ≠ 0 from by omega,
               show ¬((3 : Nat) = 1 + 1) from by omega,
               show (3 : Nat) = 1 + 2 from by omega, dite_true] at hord_13
    -- Use the game Round 2 response to derive contradiction via cont_holds transfer.
    -- For any carrier point q in N with r2_resp < extendPoint(q) at rank r+2 and
    -- extendPoint(q) < y' at rank r, h_cont_transfer gives cont_holds at q.
    -- From d ∈ S_C: cont_holds at all mu above d and below y'.
    -- Key: play Round 2 with a carrier point p' above d.
    -- The game response b gives formula agreement between b (M) and p' (N).
    -- If b ≤ c_inf: cont_holds_cross at b (from formula agreement with p' where
    -- cont_holds holds), then the infimum property gives contradiction with failures
    -- below c_inf.
    --
    -- Step 1: Find a carrier point p' with d < extendPoint(p') < y' in N.
    -- From hd_in_SC and d being the infimum: d ≤ a_bwd(n) and a_bwd(n) ∈ S_C.
    -- If d < a_bwd(n): then between d and a_bwd(n) there might be carrier points.
    -- Actually use h_pt: there exists p in [x', y'].
    -- If extendPoint(p_N) > d: take p' = p_N.
    -- If extendPoint(p_N) ≤ d: need another carrier point above d.
    -- From h_an_in_SC: a_bwd(n) ∈ S_C means a_bwd(n) ∈ [x', y'].
    -- a_bwd(n) might or might not be a carrier point.
    -- Use a separate argument: Since(⊤, D) semantics.
    --
    -- Actually, the simplest contradiction comes from the order agreement itself.
    -- If c_inf = x: order (0,1) gives rank_embed(x) = rank_embed(c_inf), so
    -- ¬(rank_embed(x) < rank_embed(c_inf)). By iff: ¬(rank_embed(x') < r2_resp).
    -- So r2_resp ≤ rank_embed(x') ≤ rank_embed(d). Contradicts h_not_le.
    -- If c_inf > x: we need the K⁻(¬D) argument.
    rcases eq_or_lt_of_le hc_inf_interval.1 with hx_eq_c | hx_lt_c
    · -- Case: x = c_inf
      -- Order (0,1) equality iff: x = c_inf → x' = r2_resp
      have h_x_eq : rank_embed (by omega : r ≤ r + 2) x =
          rank_embed (by omega : r ≤ r + 2) c_inf := by rw [hx_eq_c]
      have h_x'_eq : rank_embed (by omega : r ≤ r + 2) x' = a'_r2 ⟨0, by omega⟩ :=
        hord_01.2.mp h_x_eq
      -- So r2_resp = rank_embed(x')
      have h_r2_eq_x' : r2_resp = rank_embed (by omega : r ≤ r + 2) x' :=
        h_x'_eq.symm
      -- rank_embed(x') ≤ rank_embed(d) (since x' ≤ d from hd_interval)
      have hx'_le_d : rank_embed (by omega : r ≤ r + 2) x' ≤
          rank_embed (by omega : r ≤ r + 2) d :=
        (rank_embed_le (by omega : r ≤ r + 2) x' d).mpr hd_interval.1
      -- r2_resp = rank_embed(x') ≤ rank_embed(d), contradicting h_not_le
      exact absurd (h_r2_eq_x' ▸ hx'_le_d) (not_le.mpr h_not_le)
    · -- Case: x < c_inf. GHR93 Claim 1 K⁻(¬D_M) argument.
      -- Case split: does cont_holds_cross hold at c_inf itself?
      -- (A) If yes: strict failures exist below c_inf → K⁻ pigeonhole argument.
      -- (B) If no: use the failing formula A directly (depth ≤ r).
      by_cases h_cont_c : cont_holds_cross (a_bwd ⟨n, by omega⟩) y' c_inf
      · -- (A) cont_holds_cross holds at c_inf. K⁻ argument via strict pigeonhole.
        have h_strict_failure :
            ∀ (s : ExtendedCarrier M atomMap r),
              inClosedInterval x y s → s < c_inf →
              ∃ (u : ExtendedCarrier M atomMap r),
                s < u ∧ u < c_inf ∧ u < y ∧
                mu_holds u ∧ ¬ cont_holds_cross (a_bwd ⟨n, by omega⟩) y' u := by
          intro s hs hs_lt_c
          obtain ⟨v, hsv, hv_le_c, hvy, hmu_v, h_not_cont_v⟩ :=
            h_cofinal_failure_below_c_inf s hs hs_lt_c
          rcases lt_or_eq_of_le hv_le_c with hv_lt | hv_eq
          · exact ⟨v, hsv, hv_lt, hvy, hmu_v, h_not_cont_v⟩
          · exact absurd h_cont_c (hv_eq ▸ h_not_cont_v)
        -- Bridge to strict pigeonhole precondition:
        have h_strict_bridge :
            ∀ p : M.carrier, p ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') →
              x ≤ (extendPoint p : ExtendedCarrier M atomMap r) →
              (extendPoint p : ExtendedCarrier M atomMap r) < c_inf →
              ∃ (u : M.carrier),
                p ≤ u ∧
                u ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') ∧
                (extendPoint u : ExtendedCarrier M atomMap r) < c_inf ∧
                ∃ (A : StaviFormula),
                  stavi_depth A ≤ r ∧
                  (∀ v : ExtendedCarrier N atomMap r,
                    a_bwd ⟨n, by omega⟩ < v → v < y' → mu_holds v →
                    stavi_temporal_truth_mu N atomMap r v A) ∧
                  ¬ stavi_temporal_truth M atomMap u A := by
          intro p hp_cut hxp hp_lt_c
          have hp_interval : inClosedInterval x y (extendPoint p : ExtendedCarrier M atomMap r) :=
            ⟨hxp, le_trans (le_of_lt hp_lt_c) hc_inf_interval.2⟩
          obtain ⟨v, hpv, hv_lt_c, _, hmu_v, h_not_cont_v⟩ :=
            h_strict_failure (extendPoint p) hp_interval hp_lt_c
          obtain ⟨q, hq_eq⟩ := hmu_v
          rw [hq_eq] at hpv hv_lt_c h_not_cont_v
          have hq_cut : q ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
            intro s hs; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb s hs)
          have hp_le_q : p ≤ q := (extendPoint_le_iff p q).mp (le_of_lt hpv)
          simp only [cont_holds_cross] at h_not_cont_v
          push_neg at h_not_cont_v
          obtain ⟨B, hB_depth, hB_interval, hB_fail⟩ := h_not_cont_v
          have hB_fail_carrier : ¬ stavi_temporal_truth M atomMap q B :=
            fun h => hB_fail ((stavi_truth_mu_at_point q B).mpr h)
          exact ⟨q, hp_le_q, hq_cut, hv_lt_c, B, hB_depth, hB_interval, hB_fail_carrier⟩
        -- Get starting point for strict pigeonhole.
        obtain ⟨u₀, hx_lt_u₀, hu₀_lt_c, _, hmu_u₀, _⟩ :=
          h_strict_failure x ⟨le_refl x, hxy⟩ hx_lt_c
        obtain ⟨q₀, hq₀⟩ := hmu_u₀
        rw [hq₀] at hx_lt_u₀ hu₀_lt_c
        have hq₀_cut : q₀ ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
          intro s hs; exact le_trans (le_of_lt hu₀_lt_c) (hc_inf_glb s hs)
        -- Starting point is strictly below c_inf: apply strict pigeonhole.
        obtain ⟨D_M, hD_depth, hD_interval, hD_cofinal⟩ :=
          pigeonhole_definable_formula_cross_strict hxy
            ⟨q₀, hq₀_cut, le_of_lt hx_lt_u₀, hu₀_lt_c⟩ h_strict_bridge
        -- D_M: depth ≤ r, holds at all mu in (a_n, y') in N,
        -- fails cofinally below c_inf with ep_u < c_inf strictly.
        --
        -- K⁻(¬D_M) argument:
        -- (1) Since(⊤, D_M) FALSE at c_inf (D_M fails in every open (s, c_inf)).
        -- (2) Transfer neg(Since(⊤, D_M)) via rank_embed + formula_agreement.
        -- (3) Since(⊤, D_M) TRUE at r2_resp (D_M holds on (a_bwd(n), y') in N).
        -- (4) Contradiction.
        --
        -- Define K⁻(¬D_M) = neg(std_snce(neg(base .bot), D_M))
        -- neg(base .bot) is always true (= ⊤), depth 0.
        -- std_snce has depth max(0, depth D_M) + 2 = r + 2 (since D_M depth ≤ r).
        -- neg preserves depth. So K⁻(¬D_M) has depth r + 2.
        let K_minus := StaviFormula.neg (StaviFormula.std_snce (StaviFormula.neg (.base .bot)) D_M)
        have hK_depth : stavi_depth K_minus ≤ r + 2 := by
          simp only [K_minus, stavi_depth, operator_depth]
          omega
        -- (1) Since(⊤, D_M) FALSE at c_inf in M at rank r.
        -- For any mu-point s < c_inf, hD_cofinal gives a failure of D_M in (s, c_inf).
        -- First we need a starting cut point. We have q₀ with ep < c_inf.
        -- Actually, hD_cofinal gives: for any cut point t with x ≤ ep(t) < c_inf,
        -- ∃ u ≥ t in cut with ep(u) < c_inf and ¬D_M(u).
        -- We need: ¬ std_snce(neg .bot, D_M)(c_inf) in M at rank r.
        -- I.e., ¬ (∃ mu s < c_inf, neg(.bot)(s) ∧ ∀ mu u ∈ (s, c_inf), D_M(u)).
        -- Equivalently: ∀ mu s < c_inf, ∃ mu u ∈ (s, c_inf), ¬D_M(u).
        have h_since_false_c : ¬ stavi_temporal_truth_mu M atomMap r c_inf
            (StaviFormula.std_snce (StaviFormula.neg (.base .bot)) D_M) := by
          simp only [stavi_temporal_truth_mu]
          push_neg
          intro s hs_lt_c _hmu_s _h_neg_bot
          -- Need: ∃ mu u ∈ (s, c_inf), ¬D_M(u).
          -- From h_strict_failure at s (if s ∈ [x, y]):
          -- Use hD_cofinal to get a cut point where D_M fails.
          -- But hD_cofinal takes a cut point, not an arbitrary mu-point.
          -- We need to connect s to a cut point below it.
          -- Actually, we use h_strict_failure to get a mu-point above s
          -- where cont_holds_cross fails, then the pigeonhole formula D_M
          -- also fails at some point above s.
          --
          -- Alternative: from hD_cofinal, get a chain of D_M failures.
          -- hD_cofinal says: for any cut point t with x ≤ ep(t) < c_inf,
          -- ∃ u ≥ t with ep(u) < c_inf and ¬D_M(u).
          -- We need to find u with s < ep(u) < c_inf and ¬D_M(u).
          --
          -- From q₀ (our starting cut point with ep(q₀) < c_inf):
          -- If s < ep(q₀): use hD_cofinal at q₀ to get u ≥ q₀ with
          --   ep(u) < c_inf and ¬D_M(u). Then s < ep(q₀) ≤ ep(u) < c_inf.
          -- If ep(q₀) ≤ s: need a cut point above s.
          --   From h_strict_failure at s (with s ∈ [x,y], s < c_inf):
          --   get v with s < v < c_inf and mu_holds v and ¬cont_holds_cross v.
          --   Then v = ep(q') for some q'. q' is in cut, ep(q') < c_inf.
          --   Apply hD_cofinal at q' to get u ≥ q' with ¬D_M(u).
          --   s < ep(q') ≤ ep(u) < c_inf. Done.
          --
          -- First, establish s ∈ [x, y]:
          -- s < c_inf ≤ y, so s < y.
          -- We need x ≤ s. s is a mu-point in M. We need it in [x, y].
          -- Actually s could be anywhere < c_inf. But we can handle s < x too:
          -- if s < x < c_inf, use h_strict_failure at x.
          rcases le_or_lt x s with hxs | hsx
          · -- x ≤ s < c_inf
            have hs_interval : inClosedInterval x y s :=
              ⟨hxs, le_trans (le_of_lt hs_lt_c) hc_inf_interval.2⟩
            obtain ⟨v, hsv, hv_lt_c, _, hmu_v, _⟩ :=
              h_strict_failure s hs_interval hs_lt_c
            obtain ⟨q', hq'_eq⟩ := hmu_v
            rw [hq'_eq] at hsv hv_lt_c
            have hq'_cut : q' ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
              intro t ht; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb t ht)
            obtain ⟨u, hq'_le_u, _, hu_lt_c, hD_fail⟩ :=
              hD_cofinal q' hq'_cut (le_trans hxs (le_of_lt hsv)) hv_lt_c
            refine ⟨extendPoint u, hsv.trans_le ((extendPoint_le_iff q' u).mpr hq'_le_u),
                    hu_lt_c, ⟨u, rfl⟩, ?_⟩
            exact fun h => hD_fail ((stavi_truth_mu_at_point u D_M).mp h)
          · -- s < x < c_inf: use x as stepping stone
            obtain ⟨v, hxv, hv_lt_c, _, hmu_v, _⟩ :=
              h_strict_failure x ⟨le_refl x, hxy⟩ hx_lt_c
            obtain ⟨q', hq'_eq⟩ := hmu_v
            rw [hq'_eq] at hxv hv_lt_c
            have hq'_cut : q' ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
              intro t ht; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb t ht)
            obtain ⟨u, hq'_le_u, _, hu_lt_c, hD_fail⟩ :=
              hD_cofinal q' hq'_cut (le_of_lt hxv) hv_lt_c
            refine ⟨extendPoint u, lt_trans hsx (hxv.trans_le ((extendPoint_le_iff q' u).mpr hq'_le_u)),
                    hu_lt_c, ⟨u, rfl⟩, ?_⟩
            exact fun h => hD_fail ((stavi_truth_mu_at_point u D_M).mp h)
        -- K⁻(¬D_M) TRUE at c_inf in M at rank r:
        have hK_true_c : stavi_temporal_truth_mu M atomMap r c_inf K_minus :=
          h_since_false_c
        -- (2) Transfer K⁻(¬D_M) from c_inf (M) to r2_resp (N) via rank_embed
        -- and formula_agreement at rank r+2.
        -- formula_agreement at index 1 gives:
        --   truth M (r+2) (rank_embed c_inf) A ↔ truth N (r+2) r2_resp A
        -- for all A with depth ≤ r+2.
        -- rank_embed_stavi_truth_mu gives:
        --   truth M (r+2) (rank_embed c_inf) A ↔ truth M r c_inf A
        -- Combining: truth M r c_inf K_minus → truth N (r+2) r2_resp K_minus
        have hform_1 := hform_w ⟨1, by omega⟩ K_minus (by exact hK_depth)
        simp only [game_tuple, show (1 : Nat) ≠ 0 from by omega,
                   show (1 : Nat) ≠ 1 + 1 from by omega,
                   show (1 : Nat) ≠ 1 + 2 from by omega, dite_false,
                   show 1 - 1 = 0 from by omega] at hform_1
        have hM_bridge_K : stavi_temporal_truth_mu M atomMap (r + 2)
            (rank_embed (by omega : r ≤ r + 2) c_inf) K_minus ↔
            stavi_temporal_truth_mu M atomMap r c_inf K_minus :=
          rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) c_inf K_minus
        have hK_true_r2 : stavi_temporal_truth_mu N atomMap (r + 2) r2_resp K_minus :=
          hform_1.mp (hM_bridge_K.mpr hK_true_c)
        -- (3) Since(⊤, D_M) TRUE at r2_resp in N at rank r+2 (for contradiction).
        -- hK_true_r2 gives K_minus = neg(Since(⊤, D_M)), so Since FALSE at r2_resp.
        -- We show Since TRUE at r2_resp: witness s = rank_embed(d) when d is a point.
        -- Unfold K_minus to get ¬∃ form.
        simp only [K_minus, stavi_temporal_truth_mu] at hK_true_r2
        -- hK_true_r2 : ¬∃ s < r2_resp, mu_holds s ∧ ¬(.bot)(s) ∧ ∀ mu u ∈ (s,r2_resp), D_M(u)
        -- Case-split: is d a carrier point or a gap?
        rcases isPoint_or_isGap d with ⟨p_d, hp_d⟩ | ⟨g_d, hg_d⟩
        · -- d = extendPoint p_d: rank_embed d = extendPoint p_d at rank r+2
          apply hK_true_r2
          refine ⟨rank_embed (by omega : r ≤ r + 2) d, h_not_le, ?_, ?_, ?_⟩
          · -- mu_holds (rank_embed d): d is a carrier point, so rank_embed d is too
            exact (rank_embed_mu_holds (by omega : r ≤ r + 2) d).mpr ⟨p_d, hp_d⟩
          · -- ¬ temporal_truth_mu N atomMap (r+2) (rank_embed d) .bot = ¬ False
            simp [temporal_truth_mu]
          · -- ∀ mu u ∈ (rank_embed d, r2_resp), D_M(u) at rank r+2
            intro u hu_gt hu_lt hmu_u
            -- u is a mu-point in (rank_embed d, r2_resp) at rank r+2.
            -- mu_holds u means u = extendPoint q for some q : N.carrier.
            obtain ⟨q, hq⟩ := hmu_u
            rw [hq] at hu_gt hu_lt ⊢
            -- extendPoint q at rank r+2 is Sum.inl q. We need D_M at q.
            -- Use rank_embed_stavi_truth_mu: truth at rank r+2 ↔ truth at rank r.
            -- Sum.inl q = extendPoint q = rank_embed (extendPoint q).
            have hq_eq : (Sum.inl q : ExtendedCarrier N atomMap (r + 2)) =
                rank_embed (by omega : r ≤ r + 2)
                  (extendPoint q : ExtendedCarrier N atomMap r) :=
              (rank_embed_point (by omega : r ≤ r + 2) q).symm
            rw [hq_eq, rank_embed_stavi_truth_mu]
            -- Goal: stavi_temporal_truth_mu N atomMap r (extendPoint q) D_M
            -- rank_embed d < rank_embed (extendPoint q), so d < extendPoint q.
            have hd_lt_q : d < (extendPoint q : ExtendedCarrier N atomMap r) := by
              rw [hq_eq] at hu_gt
              exact (rank_embed_lt (by omega : r ≤ r + 2) d (extendPoint q)).mp hu_gt
            -- extendPoint q < r2_resp ≤ rank_embed y', so extendPoint q < y' at rank r.
            have hr2_le_y' : r2_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
              (ha'_r2 ⟨0, by omega⟩).2
            have hq_lt_y' : (extendPoint q : ExtendedCarrier N atomMap r) < y' := by
              have h1 : rank_embed (by omega : r ≤ r + 2) (extendPoint q : ExtendedCarrier N atomMap r) <
                  rank_embed (by omega : r ≤ r + 2) y' := by
                rw [rank_embed_point]; exact lt_of_lt_of_le hu_lt hr2_le_y'
              exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q) y').mp h1
            -- d ∈ S_C: cont_holds at all mu in (d, y'). Apply to extendPoint q.
            exact hd_in_SC.2 (extendPoint q) hd_lt_q hq_lt_y' (mu_holds_point q) D_M hD_depth hD_interval
        · -- d is a gap: find a carrier point strictly above d and below r2_resp
          -- at rank r+2, then use it as the Since witness.
          -- Since rank_embed d < r2_resp, and rank_embed d is a gap at rank r+2,
          -- there exists a carrier point between them.
          -- Case split on r2_resp: carrier point vs gap at rank r+2.
          rcases isPoint_or_isGap r2_resp with ⟨q_r2, hq_r2⟩ | ⟨g_r2, hg_r2⟩
          · -- r2_resp = extendPoint q_r2 at rank r+2.
            -- q_r2 ∉ (rank_embed_gap g_d).cut (since r2_resp > rank_embed d).
            -- By complement_no_min on rank_embed_gap g_d at rank r+2:
            -- ∃ q' ∉ (rank_embed_gap g_d).cut with q' < q_r2.
            -- Then extendPoint q' at rank r+2 is between rank_embed d and r2_resp.
            have hq_r2_not_cut : q_r2 ∉ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut := by
              rw [rank_embed_gap_cut]
              intro h_in
              have : (extendPoint q_r2 : ExtendedCarrier N atomMap (r + 2)) ≤
                  rank_embed (by omega : r ≤ r + 2) d := by
                rw [hg_d]; exact h_in
              rw [hq_r2] at h_not_le
              exact absurd this (not_le.mpr h_not_le)
            have : ¬ (∀ q, q ∉ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut → q_r2 ≤ q) :=
              fun h => (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.complement_no_min
                ⟨q_r2, hq_r2_not_cut, h⟩
            push_neg at this
            obtain ⟨q', hq'_not_cut, hq'_lt⟩ := this
            have hq'_not_cut_r : q' ∉ g_d.val.cut := by
              rwa [rank_embed_gap_cut] at hq'_not_cut
            -- extendPoint q' > rank_embed d and < r2_resp at rank r+2
            have hq'_gt_d : rank_embed (by omega : r ≤ r + 2) d <
                (extendPoint q' : ExtendedCarrier N atomMap (r + 2)) := by
              rw [show rank_embed (by omega : r ≤ r + 2) d =
                (Sum.inr (rank_embed_gap (by omega : r ≤ r + 2) g_d) :
                  ExtendedCarrier N atomMap (r + 2)) from by rw [hg_d]; rfl]
              constructor
              · exact (show q' ∉ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut from hq'_not_cut)
              · exact (show ¬(q' ∈ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut) from
                  fun h => absurd h (by rwa [rank_embed_gap_cut]))
            have hq'_lt_r2 : (extendPoint q' : ExtendedCarrier N atomMap (r + 2)) < r2_resp := by
              rw [show r2_resp = (Sum.inl q_r2 : ExtendedCarrier N atomMap (r + 2)) from hq_r2]
              exact (extendPoint_lt_iff q' q_r2).mpr hq'_lt
            -- Project to rank r: d < extendPoint q' < y'
            have hd_lt_q'_r : d < (extendPoint q' : ExtendedCarrier N atomMap r) := by
              exact (rank_embed_lt (by omega : r ≤ r + 2) d (extendPoint q')).mp
                (by rw [rank_embed_point]; exact hq'_gt_d)
            have hq'_lt_y'_r : (extendPoint q' : ExtendedCarrier N atomMap r) < y' := by
              have hr2_le_y' : r2_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
                (ha'_r2 ⟨0, by omega⟩).2
              have : (extendPoint q' : ExtendedCarrier N atomMap (r + 2)) <
                  rank_embed (by omega : r ≤ r + 2) y' :=
                lt_of_lt_of_le hq'_lt_r2 hr2_le_y'
              rw [← rank_embed_point (by omega : r ≤ r + 2) q'] at this
              exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q') y').mp this
            -- Use extendPoint q' at rank r+2 as Since witness
            apply hK_true_r2
            refine ⟨extendPoint q', hq'_lt_r2, ⟨q', rfl⟩, ?_, ?_⟩
            · simp [temporal_truth_mu]
            · -- ∀ mu u ∈ (extendPoint q', r2_resp), D_M(u) at rank r+2
              intro u hu_gt hu_lt hmu_u
              obtain ⟨q_u, hq_u⟩ := hmu_u
              rw [hq_u] at hu_gt hu_lt ⊢
              have hq_eq : (Sum.inl q_u : ExtendedCarrier N atomMap (r + 2)) =
                  rank_embed (by omega : r ≤ r + 2)
                    (extendPoint q_u : ExtendedCarrier N atomMap r) :=
                (rank_embed_point (by omega : r ≤ r + 2) q_u).symm
              rw [hq_eq, rank_embed_stavi_truth_mu]
              -- d < extendPoint q' < extendPoint q_u at rank r
              have hd_lt_qu : d < (extendPoint q_u : ExtendedCarrier N atomMap r) := by
                have : (extendPoint q' : ExtendedCarrier N atomMap (r + 2)) <
                    (extendPoint q_u : ExtendedCarrier N atomMap (r + 2)) := hu_gt
                rw [← rank_embed_point (by omega : r ≤ r + 2) q',
                    ← rank_embed_point (by omega : r ≤ r + 2) q_u] at this
                exact lt_trans hd_lt_q'_r
                  ((rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q') (extendPoint q_u)).mp this)
              have hqu_lt_y' : (extendPoint q_u : ExtendedCarrier N atomMap r) < y' := by
                have hr2_le_y' : r2_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
                  (ha'_r2 ⟨0, by omega⟩).2
                have : rank_embed (by omega : r ≤ r + 2) (extendPoint q_u : ExtendedCarrier N atomMap r) <
                    rank_embed (by omega : r ≤ r + 2) y' := by
                  rw [rank_embed_point]; exact lt_of_lt_of_le hu_lt hr2_le_y'
                exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_u) y').mp this
              exact hd_in_SC.2 (extendPoint q_u) hd_lt_qu hqu_lt_y' (mu_holds_point q_u) D_M hD_depth hD_interval
          · -- r2_resp is a gap g_r2 at rank r+2.
            -- g_d.cut ⊂ g_r2.cut (since rank_embed d < r2_resp means the gap is strictly smaller).
            -- Find q ∈ g_r2.cut \ g_d.cut (equivalently, q ∈ g_r2.cut and q ∉ g_d.cut).
            -- Then extendPoint q < r2_resp and extendPoint q > rank_embed d at rank r+2.
            -- First: rank_embed d < Sum.inr g_r2 means (rank_embed_gap g_d).cut ⊆ g_r2.cut
            -- strictly. We need a concrete witness.
            -- g_r2.cut has no supremum in cut (no_sup). g_d.cut ⊂ g_r2.cut.
            -- complement_no_min on rank_embed_gap g_d at rank r+2 says no minimum of
            -- complement. But g_r2.cut \ g_d.cut elements are in the complement of g_d
            -- intersected with g_r2.cut.
            -- Alternative approach: g_r2.cut is proper (≠ univ). g_d.cut ⊂ g_r2.cut.
            -- So ∃ q ∈ g_r2.cut \ g_d.cut. But how to prove this?
            -- Since rank_embed d = Sum.inr (rank_embed_gap g_d) < Sum.inr g_r2 = r2_resp,
            -- we have: (rank_embed_gap g_d).cut ⊂ g_r2.cut.
            -- Specifically, since rank_embed d < r2_resp, there exists q such that
            -- q ∈ g_r2.cut but q ∉ (rank_embed_gap g_d).cut.
            -- The gap ordering Sum.inr g1 < Sum.inr g2 means g1.cut ⊂ g2.cut strictly.
            rw [hg_d] at h_not_le
            -- h_not_le : Sum.inr (rank_embed_gap ... g_d) < Sum.inr g_r2
            -- By gap ordering, (rank_embed_gap g_d).cut ⊊ g_r2.cut
            rw [hg_r2] at h_not_le
            -- Get a carrier point in g_r2.cut \ (rank_embed_gap g_d).cut
            have h_strict_sub : ∃ q, q ∈ g_r2.val.cut ∧ q ∉ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut := by
              by_contra h_eq
              push_neg at h_eq
              -- h_eq : ∀ q, q ∈ g_r2.cut → q ∈ (rank_embed_gap g_d).cut
              -- So g_r2.cut ⊆ (rank_embed_gap g_d).cut
              -- Combined with the ordering, this contradicts strict inclusion.
              -- From h_not_le: Sum.inr (rank_embed_gap g_d) < Sum.inr g_r2
              -- This means (rank_embed_gap g_d).cut ⊂ g_r2.cut or there's a gap ordering.
              -- Actually, the extended ordering for gaps: Sum.inr g1 < Sum.inr g2 iff
              -- g1.cut ⊂ g2.cut (strict). If h_eq gives g_r2.cut ⊆ (rank_embed_gap g_d).cut,
              -- and the ordering gives (rank_embed_gap g_d).cut ⊆ g_r2.cut (from ≤),
              -- then g_r2.cut = (rank_embed_gap g_d).cut. But strict < means ≠.
              -- Actually, let's look at the gap ordering more carefully.
              -- Sum.inr g1 ≤ Sum.inr g2 iff g1.cut ⊆ g2.cut.
              -- So h_not_le says ¬ (Sum.inr g_r2 ≤ Sum.inr (rank_embed_gap g_d)).
              -- Wait, h_not_le says Sum.inr (rank_embed_gap g_d) < Sum.inr g_r2.
              -- The actual definition: Sum.inr g1 ≤ Sum.inr g2 iff g1.cut ⊆ g2.cut.
              -- From h_not_le (< version): (rank_embed_gap g_d).cut ⊆ g_r2.cut and
              --   ¬(g_r2.cut ⊆ (rank_embed_gap g_d).cut).
              -- But h_eq says g_r2.cut ⊆ (rank_embed_gap g_d).cut. Contradiction.
              -- h_not_le : rank_embed d < Sum.inr g_r2
              -- h_eq : g_r2.cut ⊆ (rank_embed_gap g_d).cut
              -- le_of_lt h_not_le: rank_embed d ≤ Sum.inr g_r2
              -- These combine to show rank_embed d = Sum.inr g_r2, contradicting strict <.
              exact absurd (le_antisymm (le_of_lt h_not_le) h_eq) (ne_of_lt h_not_le)
            obtain ⟨q_w, hq_w_in, hq_w_not⟩ := h_strict_sub
            have hq_w_not_gd : q_w ∉ g_d.val.cut := by
              rwa [rank_embed_gap_cut] at hq_w_not
            -- extendPoint q_w at rank r+2 satisfies:
            -- extendPoint q_w < r2_resp (since q_w ∈ g_r2.cut and r2_resp = Sum.inr g_r2)
            -- extendPoint q_w > rank_embed d (since q_w ∉ (rank_embed_gap g_d).cut)
            have hq_w_lt_r2 : (extendPoint q_w : ExtendedCarrier N atomMap (r + 2)) < r2_resp := by
              rw [show r2_resp = (Sum.inr g_r2 : ExtendedCarrier N atomMap (r + 2)) from hg_r2]
              constructor
              · exact (show q_w ∈ g_r2.val.cut from hq_w_in)
              · exact (show ¬(q_w ∉ g_r2.val.cut) from not_not.mpr hq_w_in)
            have hq_w_gt_d_r2 : rank_embed (by omega : r ≤ r + 2) d <
                (extendPoint q_w : ExtendedCarrier N atomMap (r + 2)) := by
              rw [show rank_embed (by omega : r ≤ r + 2) d =
                (Sum.inr (rank_embed_gap (by omega : r ≤ r + 2) g_d) :
                  ExtendedCarrier N atomMap (r + 2)) from by rw [hg_d]; rfl]
              constructor
              · exact (show q_w ∉ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut from hq_w_not)
              · exact (show ¬(q_w ∈ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut) from
                  fun h => absurd h (by rwa [rank_embed_gap_cut]))
            -- Project to rank r
            have hd_lt_qw : d < (extendPoint q_w : ExtendedCarrier N atomMap r) := by
              exact (rank_embed_lt (by omega : r ≤ r + 2) d (extendPoint q_w)).mp
                (by rw [rank_embed_point]; exact hq_w_gt_d_r2)
            have hqw_lt_y' : (extendPoint q_w : ExtendedCarrier N atomMap r) < y' := by
              have hr2_le_y' : r2_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
                (ha'_r2 ⟨0, by omega⟩).2
              have : (extendPoint q_w : ExtendedCarrier N atomMap (r + 2)) <
                  rank_embed (by omega : r ≤ r + 2) y' :=
                lt_of_lt_of_le hq_w_lt_r2 hr2_le_y'
              rw [← rank_embed_point (by omega : r ≤ r + 2) q_w] at this
              exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_w) y').mp this
            -- Use extendPoint q_w as Since witness
            apply hK_true_r2
            refine ⟨extendPoint q_w, hq_w_lt_r2, ⟨q_w, rfl⟩, ?_, ?_⟩
            · simp [temporal_truth_mu]
            · intro u hu_gt hu_lt hmu_u
              obtain ⟨q_u, hq_u⟩ := hmu_u
              rw [hq_u] at hu_gt hu_lt ⊢
              have hq_eq : (Sum.inl q_u : ExtendedCarrier N atomMap (r + 2)) =
                  rank_embed (by omega : r ≤ r + 2)
                    (extendPoint q_u : ExtendedCarrier N atomMap r) :=
                (rank_embed_point (by omega : r ≤ r + 2) q_u).symm
              rw [hq_eq, rank_embed_stavi_truth_mu]
              have hd_lt_qu : d < (extendPoint q_u : ExtendedCarrier N atomMap r) := by
                have : (extendPoint q_w : ExtendedCarrier N atomMap (r + 2)) <
                    (extendPoint q_u : ExtendedCarrier N atomMap (r + 2)) := hu_gt
                rw [← rank_embed_point (by omega : r ≤ r + 2) q_w,
                    ← rank_embed_point (by omega : r ≤ r + 2) q_u] at this
                exact lt_trans hd_lt_qw
                  ((rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_w) (extendPoint q_u)).mp this)
              have hqu_lt_y' : (extendPoint q_u : ExtendedCarrier N atomMap r) < y' := by
                have hr2_le_y' : r2_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
                  (ha'_r2 ⟨0, by omega⟩).2
                have : rank_embed (by omega : r ≤ r + 2) (extendPoint q_u : ExtendedCarrier N atomMap r) <
                    rank_embed (by omega : r ≤ r + 2) y' := by
                  rw [rank_embed_point]; exact lt_of_lt_of_le hu_lt hr2_le_y'
                exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_u) y').mp this
              exact hd_in_SC.2 (extendPoint q_u) hd_lt_qu hqu_lt_y' (mu_holds_point q_u) D_M hD_depth hD_interval
      · -- (B) cont_holds_cross FAILS at c_inf. Direct formula argument.
        -- ¬cont_holds_cross gives A of depth ≤ r with A at all mu in (a_n, y')
        -- but ¬A at c_inf. Formula agreement forces A to fail at r2_resp.
        -- For carrier-point r2_resp above d: A holds (from hd_in_SC.2), contradiction.
        -- For gap r2_resp: requires formula materialization (GHR93 uses C as a
        -- formula, but the Lean code uses a universally-quantified predicate).
        -- This edge case (¬cont_holds_cross at c_inf AND gap r2_resp) requires
        -- materializing the continuation predicate as a single StaviFormula,
        -- which is a blocked dependency (report 39: circularity at this proof stage).
        simp only [cont_holds_cross] at h_cont_c
        push_neg at h_cont_c
        obtain ⟨A_fail, hA_depth, hA_interval, hA_fail_c⟩ := h_cont_c
        -- Formula agreement at index 1: A_fail at rank_embed(c_inf) ↔ A_fail at r2_resp
        have hform_1_A := hform_w ⟨1, by omega⟩ A_fail (le_trans hA_depth (by omega : r ≤ r + 2))
        simp only [game_tuple, show (1 : Nat) ≠ 0 from by omega,
                   show (1 : Nat) ≠ 1 + 1 from by omega,
                   show (1 : Nat) ≠ 1 + 2 from by omega, dite_false,
                   show 1 - 1 = 0 from by omega] at hform_1_A
        -- rank_embed bridge: A_fail at c_inf (rank r) ↔ A_fail at rank_embed(c_inf) (rank r+2)
        have hM_bridge_A : stavi_temporal_truth_mu M atomMap (r + 2)
            (rank_embed (by omega : r ≤ r + 2) c_inf) A_fail ↔
            stavi_temporal_truth_mu M atomMap r c_inf A_fail :=
          rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) c_inf A_fail
        -- A_fail fails at c_inf → fails at rank_embed(c_inf) → fails at r2_resp
        have hA_fail_r2 : ¬ stavi_temporal_truth_mu N atomMap (r + 2) r2_resp A_fail :=
          fun h => hA_fail_c (hM_bridge_A.mp (hform_1_A.mpr h))
        -- Show A_fail holds at r2_resp: case split on carrier point vs gap.
        rcases isPoint_or_isGap r2_resp with ⟨q_r2, hq_r2⟩ | ⟨g_r2, _hg_r2⟩
        · -- r2_resp = extendPoint q_r2 (carrier point). Project to rank r.
          have hd_lt_q : d < (extendPoint q_r2 : ExtendedCarrier N atomMap r) := by
            have : rank_embed (by omega : r ≤ r + 2) d < r2_resp := h_not_le
            rw [hq_r2] at this
            exact (rank_embed_lt (by omega : r ≤ r + 2) d (extendPoint q_r2)).mp
              (by rw [rank_embed_point]; exact this)
          have hq_lt_y' : (extendPoint q_r2 : ExtendedCarrier N atomMap r) < y' := by
            have hr2_le_y' : r2_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
              (ha'_r2 ⟨0, by omega⟩).2
            -- If r2_resp = rank_embed y', then extendPoint q_r2 = y' at rank r.
            -- But then d < y' and a_bwd n < y'. We need STRICT inequality.
            -- From the game: r2_resp is in the closed interval, but we need to
            -- handle the boundary. If extendPoint q_r2 = y', use hd_in_SC differently.
            -- Actually, rank_embed(y') = y' at rank r+2 for carrier/gap points.
            -- If r2_resp < rank_embed(y'): project and we're done.
            -- If r2_resp = rank_embed(y'): need separate argument.
            rcases eq_or_lt_of_le hr2_le_y' with h_eq | h_lt
            · -- r2_resp = rank_embed y'. Show contradiction via order agreement.
              -- rank_embed(c_inf) < r2_resp = rank_embed(y'), so c_inf < y.
              -- order (1,3): rank_embed(c_inf) < rank_embed(y) ↔ r2_resp < rank_embed(y').
              -- r2_resp = rank_embed(y'), so r2_resp < rank_embed(y') is FALSE.
              -- So rank_embed(c_inf) < rank_embed(y) is FALSE, i.e., y ≤ c_inf.
              -- But c_inf ≤ y (from hc_inf_interval.2). So c_inf = y.
              -- hx_lt_c : x < c_inf = y. So x < y and c_inf = y.
              -- c_inf = y means S_C_M's infimum is y. Since y ∈ S_C_M, every
              -- element ≤ y is a lower bound. So c_inf = y only if S_C_M = {y}.
              -- This means cont_holds_cross fails at ALL mu in (x, y).
              -- But h_cofinal_failure_below_c_inf with s = x gives v with x < v ≤ c_inf = y.
              -- If c_inf = y: v ≤ y, so v ∈ [x, y]. ¬cont_holds_cross at v.
              -- This is consistent. But we're trying to show r2_resp ≤ rank_embed(d)
              -- and h_not_le says rank_embed(d) < r2_resp = rank_embed(y').
              -- So d < y'. And d ∈ S_C: cont_holds at all mu in (d, y') in N.
              -- The formula agreement at (0,1) gives:
              --   rank_embed(x) < rank_embed(c_inf) ↔ rank_embed(x') < r2_resp.
              -- Since x < c_inf: rank_embed(x) < rank_embed(c_inf). So rank_embed(x') < r2_resp.
              -- r2_resp = rank_embed(y'). So x' < y'.
              -- At position 1: order (1,3): rank_embed(c_inf) vs rank_embed(y).
              exfalso
              have h_c_eq_y : c_inf = y := by
                apply le_antisymm hc_inf_interval.2
                by_contra h_lt_y
                push_neg at h_lt_y
                have : rank_embed (by omega : r ≤ r + 2) c_inf <
                    rank_embed (by omega : r ≤ r + 2) y :=
                  (rank_embed_lt (by omega : r ≤ r + 2) c_inf y).mpr h_lt_y
                have h13 := (hord_13.1.mp this)
                exact absurd (h_eq ▸ h13) (lt_irrefl _)
              rw [h_c_eq_y] at hx_lt_c
              -- x < y = c_inf. hx_eq_c case was already handled, so this is the
              -- strict case. We need to derive contradiction.
              -- c_inf = y: order (0,1) gives x < y ↔ x' < r2_resp.
              -- We have x < y. So x' < r2_resp = rank_embed(y').
              -- i.e., x' < y'. Also, rank_embed(d) < r2_resp = rank_embed(y'), so d < y'.
              -- Use hA_fail_r2: A_fail fails at r2_resp = rank_embed(y').
              -- But A_fail holds at all mu in (a_bwd n, y') in N (from hA_interval).
              -- If y' is a carrier point at rank r: rank_embed(y') = extendPoint(q_r2)
              -- at rank r+2. Projecting: extendPoint(q_r2) = y' at rank r.
              -- But we need A_fail to hold at y', which requires y' to be in
              -- (a_bwd n, y'), which is vacuous (y' is not < y').
              -- c_inf = y gives STRICT failures below c_inf (since u < y = c_inf).
              -- Apply the same K⁻(¬D_M) pigeonhole argument as Case A.
              have h_strict_failure_s1 :
                  ∀ (s : ExtendedCarrier M atomMap r),
                    inClosedInterval x y s → s < c_inf →
                    ∃ (u : ExtendedCarrier M atomMap r),
                      s < u ∧ u < c_inf ∧ u < y ∧
                      mu_holds u ∧ ¬ cont_holds_cross (a_bwd ⟨n, by omega⟩) y' u := by
                intro s hs hs_lt_c
                obtain ⟨v, hsv, hv_le_c, hvy, hmu_v, h_not_cont_v⟩ :=
                  h_cofinal_failure_below_c_inf s hs hs_lt_c
                -- v < y and c_inf = y, so v < c_inf (strict!)
                exact ⟨v, hsv, h_c_eq_y ▸ hvy, hvy, hmu_v, h_not_cont_v⟩
              -- Build strict bridge for pigeonhole (same as Case A pattern)
              have h_strict_bridge_s1 :
                  ∀ p : M.carrier, p ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') →
                    x ≤ (extendPoint p : ExtendedCarrier M atomMap r) →
                    (extendPoint p : ExtendedCarrier M atomMap r) < c_inf →
                    ∃ (u : M.carrier),
                      p ≤ u ∧
                      u ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') ∧
                      (extendPoint u : ExtendedCarrier M atomMap r) < c_inf ∧
                      ∃ (A : StaviFormula),
                        stavi_depth A ≤ r ∧
                        (∀ v : ExtendedCarrier N atomMap r,
                          a_bwd ⟨n, by omega⟩ < v → v < y' → mu_holds v →
                          stavi_temporal_truth_mu N atomMap r v A) ∧
                        ¬ stavi_temporal_truth M atomMap u A := by
                intro p hp_cut hxp hp_lt_c
                have hp_interval : inClosedInterval x y (extendPoint p : ExtendedCarrier M atomMap r) :=
                  ⟨hxp, le_trans (le_of_lt hp_lt_c) hc_inf_interval.2⟩
                obtain ⟨v, hpv, hv_lt_c, _, hmu_v, h_not_cont_v⟩ :=
                  h_strict_failure_s1 (extendPoint p) hp_interval hp_lt_c
                obtain ⟨q, hq_eq⟩ := hmu_v
                rw [hq_eq] at hpv hv_lt_c h_not_cont_v
                have hq_cut : q ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
                  intro s hs; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb s hs)
                have hp_le_q : p ≤ q := (extendPoint_le_iff p q).mp (le_of_lt hpv)
                simp only [cont_holds_cross] at h_not_cont_v
                push_neg at h_not_cont_v
                obtain ⟨B, hB_depth, hB_interval, hB_fail⟩ := h_not_cont_v
                have hB_fail_carrier : ¬ stavi_temporal_truth M atomMap q B :=
                  fun h => hB_fail ((stavi_truth_mu_at_point q B).mpr h)
                exact ⟨q, hp_le_q, hq_cut, hv_lt_c, B, hB_depth, hB_interval, hB_fail_carrier⟩
              -- Get starting point for strict pigeonhole
              obtain ⟨u₀, hx_lt_u₀, hu₀_lt_c, _, hmu_u₀, _⟩ :=
                h_strict_failure_s1 x ⟨le_refl x, hxy⟩ (h_c_eq_y.symm ▸ hx_lt_c)
              obtain ⟨q₀, hq₀⟩ := hmu_u₀
              rw [hq₀] at hx_lt_u₀ hu₀_lt_c
              have hq₀_cut : q₀ ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
                intro s hs; exact le_trans (le_of_lt hu₀_lt_c) (hc_inf_glb s hs)
              -- Apply strict pigeonhole to get D_M with cofinal failures
              obtain ⟨D_M, hD_depth, hD_interval, hD_cofinal⟩ :=
                pigeonhole_definable_formula_cross_strict hxy
                  ⟨q₀, hq₀_cut, le_of_lt hx_lt_u₀, hu₀_lt_c⟩ h_strict_bridge_s1
              -- K⁻(¬D_M) argument: construct K_minus, show Since false at c_inf
              let K_minus := StaviFormula.neg (StaviFormula.std_snce (StaviFormula.neg (.base .bot)) D_M)
              have hK_depth : stavi_depth K_minus ≤ r + 2 := by
                simp only [K_minus, stavi_depth, operator_depth]; omega
              -- Since(⊤, D_M) FALSE at c_inf: D_M fails in every interval (s, c_inf)
              have h_since_false_c : ¬ stavi_temporal_truth_mu M atomMap r c_inf
                  (StaviFormula.std_snce (StaviFormula.neg (.base .bot)) D_M) := by
                simp only [stavi_temporal_truth_mu]
                push_neg
                intro s hs_lt_c _hmu_s _h_neg_bot
                rcases le_or_lt x s with hxs | hsx
                · have hs_interval : inClosedInterval x y s :=
                    ⟨hxs, le_trans (le_of_lt hs_lt_c) hc_inf_interval.2⟩
                  obtain ⟨v, hsv, hv_lt_c, _, hmu_v, _⟩ :=
                    h_strict_failure_s1 s hs_interval hs_lt_c
                  obtain ⟨q', hq'_eq⟩ := hmu_v
                  rw [hq'_eq] at hsv hv_lt_c
                  have hq'_cut : q' ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
                    intro t ht; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb t ht)
                  obtain ⟨u, hq'_le_u, _, hu_lt_c, hD_fail⟩ :=
                    hD_cofinal q' hq'_cut (le_trans hxs (le_of_lt hsv)) hv_lt_c
                  refine ⟨extendPoint u, hsv.trans_le ((extendPoint_le_iff q' u).mpr hq'_le_u),
                          hu_lt_c, ⟨u, rfl⟩, ?_⟩
                  exact fun h => hD_fail ((stavi_truth_mu_at_point u D_M).mp h)
                · obtain ⟨v, hxv, hv_lt_c, _, hmu_v, _⟩ :=
                    h_strict_failure_s1 x ⟨le_refl x, hxy⟩ (h_c_eq_y.symm ▸ hx_lt_c)
                  obtain ⟨q', hq'_eq⟩ := hmu_v
                  rw [hq'_eq] at hxv hv_lt_c
                  have hq'_cut : q' ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
                    intro t ht; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb t ht)
                  obtain ⟨u, hq'_le_u, _, hu_lt_c, hD_fail⟩ :=
                    hD_cofinal q' hq'_cut (le_of_lt hxv) hv_lt_c
                  refine ⟨extendPoint u, lt_trans hsx (hxv.trans_le ((extendPoint_le_iff q' u).mpr hq'_le_u)),
                          hu_lt_c, ⟨u, rfl⟩, ?_⟩
                  exact fun h => hD_fail ((stavi_truth_mu_at_point u D_M).mp h)
              -- K_minus TRUE at c_inf in M
              have hK_true_c : stavi_temporal_truth_mu M atomMap r c_inf K_minus :=
                h_since_false_c
              -- Transfer K_minus via formula agreement to r2_resp
              have hform_1_K := hform_w ⟨1, by omega⟩ K_minus (by exact hK_depth)
              simp only [game_tuple, show (1 : Nat) ≠ 0 from by omega,
                         show (1 : Nat) ≠ 1 + 1 from by omega,
                         show (1 : Nat) ≠ 1 + 2 from by omega, dite_false,
                         show 1 - 1 = 0 from by omega] at hform_1_K
              have hM_bridge_K : stavi_temporal_truth_mu M atomMap (r + 2)
                  (rank_embed (by omega : r ≤ r + 2) c_inf) K_minus ↔
                  stavi_temporal_truth_mu M atomMap r c_inf K_minus :=
                rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) c_inf K_minus
              have hK_true_r2 : stavi_temporal_truth_mu N atomMap (r + 2) r2_resp K_minus :=
                hform_1_K.mp (hM_bridge_K.mpr hK_true_c)
              -- Since(⊤, D_M) TRUE at r2_resp: find Since witness between d and r2_resp
              simp only [K_minus, stavi_temporal_truth_mu] at hK_true_r2
              apply hK_true_r2
              -- Case split: if d is a point, use rank_embed(d). If gap, use complement_no_min.
              rcases isPoint_or_isGap d with ⟨p_d, hp_d⟩ | ⟨g_d, hg_d⟩
              · -- d is a carrier point: use rank_embed(d) directly
                refine ⟨rank_embed (by omega : r ≤ r + 2) d, h_not_le, ?_, ?_, ?_⟩
                · exact (rank_embed_mu_holds (by omega : r ≤ r + 2) d).mpr ⟨p_d, hp_d⟩
                · simp [temporal_truth_mu]
                · intro u hu_gt hu_lt hmu_u
                  obtain ⟨q, hq⟩ := hmu_u
                  rw [hq] at hu_gt hu_lt ⊢
                  have hq_eq : (Sum.inl q : ExtendedCarrier N atomMap (r + 2)) =
                      rank_embed (by omega : r ≤ r + 2)
                        (extendPoint q : ExtendedCarrier N atomMap r) :=
                    (rank_embed_point (by omega : r ≤ r + 2) q).symm
                  rw [hq_eq, rank_embed_stavi_truth_mu]
                  have hd_lt_q : d < (extendPoint q : ExtendedCarrier N atomMap r) := by
                    rw [hq_eq] at hu_gt
                    exact (rank_embed_lt (by omega : r ≤ r + 2) d (extendPoint q)).mp hu_gt
                  have hq_lt_y' : (extendPoint q : ExtendedCarrier N atomMap r) < y' := by
                    have : rank_embed (by omega : r ≤ r + 2) (extendPoint q : ExtendedCarrier N atomMap r) <
                        rank_embed (by omega : r ≤ r + 2) y' := by
                      rw [rank_embed_point]; exact lt_of_lt_of_le hu_lt (h_eq ▸ le_refl _)
                    exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q) y').mp this
                  exact hd_in_SC.2 (extendPoint q) hd_lt_q hq_lt_y' (mu_holds_point q) D_M hD_depth hD_interval
              · -- d is a gap: use complement_no_min to find carrier point above d
                -- q_r2 ∉ (rank_embed_gap g_d).cut since rank_embed d < r2_resp = extendPoint q_r2
                have hq_r2_not_cut : q_r2 ∉ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut := by
                  rw [rank_embed_gap_cut]
                  intro h_in
                  have : (extendPoint q_r2 : ExtendedCarrier N atomMap (r + 2)) ≤
                      rank_embed (by omega : r ≤ r + 2) d := by
                    rw [hg_d]; exact h_in
                  rw [hq_r2] at h_not_le
                  exact absurd this (not_le.mpr h_not_le)
                have : ¬(∀ q, q ∉ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut → q_r2 ≤ q) :=
                  fun h => (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.complement_no_min
                    ⟨q_r2, hq_r2_not_cut, h⟩
                push_neg at this
                obtain ⟨q', hq'_not_cut, hq'_lt⟩ := this
                have hq'_gt_d : rank_embed (by omega : r ≤ r + 2) d <
                    (extendPoint q' : ExtendedCarrier N atomMap (r + 2)) := by
                  rw [show rank_embed (by omega : r ≤ r + 2) d =
                    (Sum.inr (rank_embed_gap (by omega : r ≤ r + 2) g_d) :
                      ExtendedCarrier N atomMap (r + 2)) from by rw [hg_d]; rfl]
                  constructor
                  · exact (show q' ∉ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut from hq'_not_cut)
                  · exact (show ¬(q' ∈ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut) from
                      fun h => absurd h (by rwa [rank_embed_gap_cut]))
                have hq'_lt_r2 : (extendPoint q' : ExtendedCarrier N atomMap (r + 2)) < r2_resp := by
                  rw [show r2_resp = (Sum.inl q_r2 : ExtendedCarrier N atomMap (r + 2)) from hq_r2]
                  exact (extendPoint_lt_iff q' q_r2).mpr hq'_lt
                refine ⟨extendPoint q', hq'_lt_r2, ⟨q', rfl⟩, ?_, ?_⟩
                · simp [temporal_truth_mu]
                · intro u hu_gt hu_lt hmu_u
                  obtain ⟨q_u, hq_u⟩ := hmu_u
                  rw [hq_u] at hu_gt hu_lt ⊢
                  have hq_eq : (Sum.inl q_u : ExtendedCarrier N atomMap (r + 2)) =
                      rank_embed (by omega : r ≤ r + 2)
                        (extendPoint q_u : ExtendedCarrier N atomMap r) :=
                    (rank_embed_point (by omega : r ≤ r + 2) q_u).symm
                  rw [hq_eq, rank_embed_stavi_truth_mu]
                  have hd_lt_qu : d < (extendPoint q_u : ExtendedCarrier N atomMap r) := by
                    have : (extendPoint q' : ExtendedCarrier N atomMap (r + 2)) <
                        (extendPoint q_u : ExtendedCarrier N atomMap (r + 2)) := hu_gt
                    have hd_lt_q'_r : d < (extendPoint q' : ExtendedCarrier N atomMap r) :=
                      (rank_embed_lt (by omega : r ≤ r + 2) d (extendPoint q')).mp
                        (by rw [rank_embed_point]; exact hq'_gt_d)
                    rw [← rank_embed_point (by omega : r ≤ r + 2) q',
                        ← rank_embed_point (by omega : r ≤ r + 2) q_u] at this
                    exact lt_trans hd_lt_q'_r
                      ((rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q') (extendPoint q_u)).mp this)
                  have hqu_lt_y' : (extendPoint q_u : ExtendedCarrier N atomMap r) < y' := by
                    have : rank_embed (by omega : r ≤ r + 2) (extendPoint q_u : ExtendedCarrier N atomMap r) <
                        rank_embed (by omega : r ≤ r + 2) y' := by
                      rw [rank_embed_point]; exact lt_of_lt_of_le hu_lt (h_eq ▸ le_refl _)
                    exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_u) y').mp this
                  exact hd_in_SC.2 (extendPoint q_u) hd_lt_qu hqu_lt_y' (mu_holds_point q_u) D_M hD_depth hD_interval
            · -- r2_resp < rank_embed y'. Project to rank r.
              have hr2_lt : r2_resp < rank_embed (by omega : r ≤ r + 2) y' := h_lt
              have : rank_embed (by omega : r ≤ r + 2)
                  (extendPoint q_r2 : ExtendedCarrier N atomMap r) <
                  rank_embed (by omega : r ≤ r + 2) y' := by
                rw [rank_embed_point]
                rw [show r2_resp = (extendPoint q_r2 : ExtendedCarrier N atomMap (r + 2)) from hq_r2] at hr2_lt
                exact hr2_lt
              exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_r2) y').mp this
          -- A_fail holds at extendPoint q_r2 at rank r (from hd_in_SC.2)
          have hA_holds_q : stavi_temporal_truth_mu N atomMap r
              (extendPoint q_r2 : ExtendedCarrier N atomMap r) A_fail :=
            hd_in_SC.2 (extendPoint q_r2) hd_lt_q hq_lt_y' (mu_holds_point q_r2)
              A_fail hA_depth hA_interval
          -- Bridge to rank r+2
          have hN_bridge : stavi_temporal_truth_mu N atomMap (r + 2)
              (extendPoint q_r2 : ExtendedCarrier N atomMap (r + 2)) A_fail ↔
              stavi_temporal_truth_mu N atomMap r
                (extendPoint q_r2 : ExtendedCarrier N atomMap r) A_fail := by
            conv_lhs => rw [show (extendPoint q_r2 : ExtendedCarrier N atomMap (r + 2)) =
              rank_embed (by omega : r ≤ r + 2)
                (extendPoint q_r2 : ExtendedCarrier N atomMap r) from
              (rank_embed_point (by omega : r ≤ r + 2) q_r2).symm]
            exact rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) (extendPoint q_r2) A_fail
          -- A_fail holds at r2_resp at rank r+2
          have hA_holds_r2 : stavi_temporal_truth_mu N atomMap (r + 2) r2_resp A_fail := by
            rw [hq_r2]; exact hN_bridge.mpr hA_holds_q
          exact hA_fail_r2 hA_holds_r2
        · -- r2_resp is a gap at rank r+2.
          -- gap_point_agreement forces c_inf to also be a gap. Then strict
          -- failures below c_inf follow (mu_holds v → v ≠ gap c_inf → v < c_inf).
          -- The K⁻(¬D_M) argument from Case A then applies identically.
          have h_gp_1 := hgp_w ⟨1, by omega⟩
          simp only [game_tuple, show (1 : Nat) ≠ 0 from by omega,
                     show (1 : Nat) ≠ 1 + 1 from by omega,
                     show (1 : Nat) ≠ 1 + 2 from by omega, dite_false,
                     show 1 - 1 = 0 from by omega] at h_gp_1
          have h_not_pt_r2 : ¬IsPoint r2_resp := by
            intro ⟨q, hq⟩; simp [_hg_r2] at hq
          have h_not_pt_rc : ¬IsPoint (rank_embed (by omega : r ≤ r + 2) c_inf) :=
            fun h => h_not_pt_r2 (h_gp_1.1.mp h)
          have h_not_pt_c : ¬IsPoint c_inf := by
            rwa [← rank_embed_isPoint (by omega : r ≤ r + 2) c_inf]
          have h_gap_c : IsGap c_inf := (isPoint_or_isGap c_inf).resolve_left h_not_pt_c
          -- Strict cofinal failures below c_inf (c_inf is gap → mu v < c_inf)
          have h_strict_failure_s2 :
              ∀ (s : ExtendedCarrier M atomMap r),
                inClosedInterval x y s → s < c_inf →
                ∃ (u : ExtendedCarrier M atomMap r),
                  s < u ∧ u < c_inf ∧ u < y ∧
                  mu_holds u ∧ ¬ cont_holds_cross (a_bwd ⟨n, by omega⟩) y' u := by
            intro s hs hs_lt_c
            obtain ⟨v, hsv, hv_le_c, hvy, hmu_v, h_not_cont_v⟩ :=
              h_cofinal_failure_below_c_inf s hs hs_lt_c
            have hv_ne_c : v ≠ c_inf := by
              obtain ⟨g_c, hg_c⟩ := h_gap_c
              intro heq
              obtain ⟨p_v, hp_v⟩ := hmu_v
              simp [heq, hg_c] at hp_v
            exact ⟨v, hsv, lt_of_le_of_ne hv_le_c hv_ne_c, hvy, hmu_v, h_not_cont_v⟩
          -- K⁻(¬D_M) argument (same structure as S1/Case A)
          -- Build strict bridge for pigeonhole
          have h_strict_bridge_s2 :
              ∀ p : M.carrier, p ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') →
                x ≤ (extendPoint p : ExtendedCarrier M atomMap r) →
                (extendPoint p : ExtendedCarrier M atomMap r) < c_inf →
                ∃ (u : M.carrier),
                  p ≤ u ∧
                  u ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') ∧
                  (extendPoint u : ExtendedCarrier M atomMap r) < c_inf ∧
                  ∃ (A : StaviFormula),
                    stavi_depth A ≤ r ∧
                    (∀ v : ExtendedCarrier N atomMap r,
                      a_bwd ⟨n, by omega⟩ < v → v < y' → mu_holds v →
                      stavi_temporal_truth_mu N atomMap r v A) ∧
                    ¬ stavi_temporal_truth M atomMap u A := by
            intro p hp_cut hxp hp_lt_c
            have hp_interval : inClosedInterval x y (extendPoint p : ExtendedCarrier M atomMap r) :=
              ⟨hxp, le_trans (le_of_lt hp_lt_c) hc_inf_interval.2⟩
            obtain ⟨v, hpv, hv_lt_c, _, hmu_v, h_not_cont_v⟩ :=
              h_strict_failure_s2 (extendPoint p) hp_interval hp_lt_c
            obtain ⟨q, hq_eq⟩ := hmu_v
            rw [hq_eq] at hpv hv_lt_c h_not_cont_v
            have hq_cut : q ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
              intro s hs; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb s hs)
            have hp_le_q : p ≤ q := (extendPoint_le_iff p q).mp (le_of_lt hpv)
            simp only [cont_holds_cross] at h_not_cont_v
            push_neg at h_not_cont_v
            obtain ⟨B, hB_depth, hB_interval, hB_fail⟩ := h_not_cont_v
            have hB_fail_carrier : ¬ stavi_temporal_truth M atomMap q B :=
              fun h => hB_fail ((stavi_truth_mu_at_point q B).mpr h)
            exact ⟨q, hp_le_q, hq_cut, hv_lt_c, B, hB_depth, hB_interval, hB_fail_carrier⟩
          -- Get starting point for strict pigeonhole
          obtain ⟨u₀, hx_lt_u₀, hu₀_lt_c, _, hmu_u₀, _⟩ :=
            h_strict_failure_s2 x ⟨le_refl x, hxy⟩ hx_lt_c
          obtain ⟨q₀, hq₀⟩ := hmu_u₀
          rw [hq₀] at hx_lt_u₀ hu₀_lt_c
          have hq₀_cut : q₀ ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
            intro s hs; exact le_trans (le_of_lt hu₀_lt_c) (hc_inf_glb s hs)
          -- Apply strict pigeonhole to get D_M with cofinal failures
          obtain ⟨D_M, hD_depth, hD_interval, hD_cofinal⟩ :=
            pigeonhole_definable_formula_cross_strict hxy
              ⟨q₀, hq₀_cut, le_of_lt hx_lt_u₀, hu₀_lt_c⟩ h_strict_bridge_s2
          -- K⁻(¬D_M) argument: construct K_minus, show Since false at c_inf
          let K_minus := StaviFormula.neg (StaviFormula.std_snce (StaviFormula.neg (.base .bot)) D_M)
          have hK_depth : stavi_depth K_minus ≤ r + 2 := by
            simp only [K_minus, stavi_depth, operator_depth]; omega
          -- Since(⊤, D_M) FALSE at c_inf: D_M fails in every interval (s, c_inf)
          have h_since_false_c : ¬ stavi_temporal_truth_mu M atomMap r c_inf
              (StaviFormula.std_snce (StaviFormula.neg (.base .bot)) D_M) := by
            simp only [stavi_temporal_truth_mu]
            push_neg
            intro s hs_lt_c _hmu_s _h_neg_bot
            rcases le_or_lt x s with hxs | hsx
            · have hs_interval : inClosedInterval x y s :=
                ⟨hxs, le_trans (le_of_lt hs_lt_c) hc_inf_interval.2⟩
              obtain ⟨v, hsv, hv_lt_c, _, hmu_v, _⟩ :=
                h_strict_failure_s2 s hs_interval hs_lt_c
              obtain ⟨q', hq'_eq⟩ := hmu_v
              rw [hq'_eq] at hsv hv_lt_c
              have hq'_cut : q' ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
                intro t ht; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb t ht)
              obtain ⟨u, hq'_le_u, _, hu_lt_c, hD_fail⟩ :=
                hD_cofinal q' hq'_cut (le_trans hxs (le_of_lt hsv)) hv_lt_c
              refine ⟨extendPoint u, hsv.trans_le ((extendPoint_le_iff q' u).mpr hq'_le_u),
                      hu_lt_c, ⟨u, rfl⟩, ?_⟩
              exact fun h => hD_fail ((stavi_truth_mu_at_point u D_M).mp h)
            · obtain ⟨v, hxv, hv_lt_c, _, hmu_v, _⟩ :=
                h_strict_failure_s2 x ⟨le_refl x, hxy⟩ hx_lt_c
              obtain ⟨q', hq'_eq⟩ := hmu_v
              rw [hq'_eq] at hxv hv_lt_c
              have hq'_cut : q' ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
                intro t ht; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb t ht)
              obtain ⟨u, hq'_le_u, _, hu_lt_c, hD_fail⟩ :=
                hD_cofinal q' hq'_cut (le_of_lt hxv) hv_lt_c
              refine ⟨extendPoint u, lt_trans hsx (hxv.trans_le ((extendPoint_le_iff q' u).mpr hq'_le_u)),
                      hu_lt_c, ⟨u, rfl⟩, ?_⟩
              exact fun h => hD_fail ((stavi_truth_mu_at_point u D_M).mp h)
          -- K_minus TRUE at c_inf in M
          have hK_true_c : stavi_temporal_truth_mu M atomMap r c_inf K_minus :=
            h_since_false_c
          -- Transfer K_minus via formula agreement to r2_resp
          have hform_1_K := hform_w ⟨1, by omega⟩ K_minus (by exact hK_depth)
          simp only [game_tuple, show (1 : Nat) ≠ 0 from by omega,
                     show (1 : Nat) ≠ 1 + 1 from by omega,
                     show (1 : Nat) ≠ 1 + 2 from by omega, dite_false,
                     show 1 - 1 = 0 from by omega] at hform_1_K
          have hM_bridge_K : stavi_temporal_truth_mu M atomMap (r + 2)
              (rank_embed (by omega : r ≤ r + 2) c_inf) K_minus ↔
              stavi_temporal_truth_mu M atomMap r c_inf K_minus :=
            rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) c_inf K_minus
          have hK_true_r2 : stavi_temporal_truth_mu N atomMap (r + 2) r2_resp K_minus :=
            hform_1_K.mp (hM_bridge_K.mpr hK_true_c)
          -- Since(⊤, D_M) TRUE at r2_resp: witness = rank_embed(d)
          simp only [K_minus, stavi_temporal_truth_mu] at hK_true_r2
          apply hK_true_r2
          -- Use complement_no_min pattern: find carrier point between d and r2_resp
          have hd_lt_r2 := h_not_le
          obtain ⟨g_c_inf, hg_c_inf⟩ := h_gap_c
          -- r2_resp = Sum.inr g_r2 (a gap). Find carrier point between rank_embed(d) and r2_resp.
          rcases isPoint_or_isGap d with ⟨p_d, hp_d⟩ | ⟨g_d, hg_d⟩
          · -- d is a carrier point: rank_embed(d) is a carrier point at rank r+2
            -- rank_embed(d) < r2_resp, so use rank_embed(d) as the Since witness
            refine ⟨rank_embed (by omega : r ≤ r + 2) d, hd_lt_r2, ?_, ?_, ?_⟩
            · exact (rank_embed_mu_holds (by omega : r ≤ r + 2) d).mpr ⟨p_d, hp_d⟩
            · simp [temporal_truth_mu]
            · intro u hu_gt hu_lt hmu_u
              obtain ⟨q_u, hq_u⟩ := hmu_u
              rw [hq_u] at hu_gt hu_lt ⊢
              have hq_eq : (Sum.inl q_u : ExtendedCarrier N atomMap (r + 2)) =
                  rank_embed (by omega : r ≤ r + 2)
                    (extendPoint q_u : ExtendedCarrier N atomMap r) :=
                (rank_embed_point (by omega : r ≤ r + 2) q_u).symm
              rw [hq_eq, rank_embed_stavi_truth_mu]
              have hd_lt_qu : d < (extendPoint q_u : ExtendedCarrier N atomMap r) := by
                rw [hq_eq] at hu_gt
                exact (rank_embed_lt (by omega : r ≤ r + 2) d (extendPoint q_u)).mp hu_gt
              have hqu_lt_y' : (extendPoint q_u : ExtendedCarrier N atomMap r) < y' := by
                have hr2_le_y' : r2_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
                  (ha'_r2 ⟨0, by omega⟩).2
                have : rank_embed (by omega : r ≤ r + 2) (extendPoint q_u : ExtendedCarrier N atomMap r) <
                    rank_embed (by omega : r ≤ r + 2) y' := by
                  rw [rank_embed_point]; exact lt_of_lt_of_le hu_lt hr2_le_y'
                exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_u) y').mp this
              exact hd_in_SC.2 (extendPoint q_u) hd_lt_qu hqu_lt_y' (mu_holds_point q_u) D_M hD_depth hD_interval
          · -- d is a gap: use complement_no_min to find carrier point between gaps
            rw [_hg_r2] at hd_lt_r2
            rw [hg_d] at hd_lt_r2
            have h_strict_sub : ∃ q, q ∈ g_r2.val.cut ∧ q ∉ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut := by
              by_contra h_eq
              push_neg at h_eq
              exact absurd (le_antisymm (le_of_lt hd_lt_r2) h_eq) (ne_of_lt hd_lt_r2)
            obtain ⟨q_w, hq_w_in, hq_w_not⟩ := h_strict_sub
            have hq_w_not_gd : q_w ∉ g_d.val.cut := by
              rwa [rank_embed_gap_cut] at hq_w_not
            have hq_w_lt_r2 : (extendPoint q_w : ExtendedCarrier N atomMap (r + 2)) < r2_resp := by
              rw [show r2_resp = (Sum.inr g_r2 : ExtendedCarrier N atomMap (r + 2)) from _hg_r2]
              constructor
              · exact hq_w_in
              · exact not_not.mpr hq_w_in
            have hq_w_gt_d : rank_embed (by omega : r ≤ r + 2) d <
                (extendPoint q_w : ExtendedCarrier N atomMap (r + 2)) := by
              rw [show rank_embed (by omega : r ≤ r + 2) d =
                (Sum.inr (rank_embed_gap (by omega : r ≤ r + 2) g_d) :
                  ExtendedCarrier N atomMap (r + 2)) from by rw [hg_d]; rfl]
              constructor
              · exact hq_w_not
              · exact hq_w_not
            refine ⟨extendPoint q_w, hq_w_lt_r2, ⟨q_w, rfl⟩, ?_, ?_⟩
            · simp [temporal_truth_mu]
            · intro u hu_gt hu_lt hmu_u
              obtain ⟨q_u, hq_u⟩ := hmu_u
              rw [hq_u] at hu_gt hu_lt ⊢
              have hq_eq : (Sum.inl q_u : ExtendedCarrier N atomMap (r + 2)) =
                  rank_embed (by omega : r ≤ r + 2)
                    (extendPoint q_u : ExtendedCarrier N atomMap r) :=
                (rank_embed_point (by omega : r ≤ r + 2) q_u).symm
              rw [hq_eq, rank_embed_stavi_truth_mu]
              have hd_lt_qu : d < (extendPoint q_u : ExtendedCarrier N atomMap r) := by
                have : (extendPoint q_w : ExtendedCarrier N atomMap (r + 2)) <
                    (extendPoint q_u : ExtendedCarrier N atomMap (r + 2)) := hu_gt
                have hd_lt_qw_r : d < (extendPoint q_w : ExtendedCarrier N atomMap r) :=
                  (rank_embed_lt (by omega : r ≤ r + 2) d (extendPoint q_w)).mp
                    (by rw [rank_embed_point]; exact hq_w_gt_d)
                rw [← rank_embed_point (by omega : r ≤ r + 2) q_w,
                    ← rank_embed_point (by omega : r ≤ r + 2) q_u] at this
                exact lt_trans hd_lt_qw_r
                  ((rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_w) (extendPoint q_u)).mp this)
              have hqu_lt_y' : (extendPoint q_u : ExtendedCarrier N atomMap r) < y' := by
                have hr2_le_y' : r2_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
                  (ha'_r2 ⟨0, by omega⟩).2
                have : rank_embed (by omega : r ≤ r + 2) (extendPoint q_u : ExtendedCarrier N atomMap r) <
                    rank_embed (by omega : r ≤ r + 2) y' := by
                  rw [rank_embed_point]; exact lt_of_lt_of_le hu_lt hr2_le_y'
                exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_u) y').mp this
              exact hd_in_SC.2 (extendPoint q_u) hd_lt_qu hqu_lt_y' (mu_holds_point q_u) D_M hD_depth hD_interval
  -- Direction 2: rank_embed(d) ≤ r2_resp
  -- GHR93 Claim 1 Step 2.3: game Round 2 argument.
  have h_r2_resp_ge_d : rank_embed (by omega : r ≤ r + 2) d ≤ r2_resp := by
    -- By contradiction: assume r2_resp < rank_embed(d).
    by_contra h_not_le
    push_neg at h_not_le
    -- h_not_le : r2_resp < rank_embed d
    -- From h_cont_transfer: any mu p with r2_resp < extendPoint(p) and p < y'
    -- satisfies cont_holds at p.
    -- From h_cofinal_failure_below_d: for any s < d, ∃ mu v with s < v ≤ d,
    -- v < y', ¬cont_holds v.
    -- Case split on whether r2_resp is a carrier point or gap.
    rcases isPoint_or_isGap r2_resp with ⟨p_resp, hp_resp⟩ | ⟨g_resp, hg_resp⟩
    · -- r2_resp = extendPoint(p_resp): carrier point case.
      -- extendPoint(p_resp) < rank_embed(d) at rank r+2.
      -- Project to rank r: extendPoint(p_resp) < d.
      have hp_lt_d : (extendPoint p_resp : ExtendedCarrier N atomMap r) < d := by
        -- r2_resp < rank_embed(d) at rank r+2, and r2_resp = extendPoint(p_resp) at rank r+2
        -- extendPoint(p_resp) at rank r+2 = rank_embed(extendPoint(p_resp) at rank r)
        -- So rank_embed(extendPoint(p_resp)) < rank_embed(d), hence extendPoint(p_resp) < d
        have : r2_resp < rank_embed (by omega : r ≤ r + 2) d := h_not_le
        rw [hp_resp] at this
        -- this : Sum.inl p_resp < rank_embed d, where Sum.inl p_resp = extendPoint p_resp at rank r+2
        -- = rank_embed (extendPoint p_resp at rank r) by rank_embed_point
        exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint p_resp) d).mp
          (show rank_embed (by omega : r ≤ r + 2) (extendPoint p_resp : ExtendedCarrier N atomMap r)
            < rank_embed (by omega : r ≤ r + 2) d from by
              simp only [rank_embed_point]; exact this)
      -- extendPoint(p_resp) ∈ [x', y']
      have hp_in : inClosedInterval x' y' (extendPoint p_resp : ExtendedCarrier N atomMap r) := by
        have h_r2 := ha'_r2 ⟨0, by omega⟩
        rw [show a'_r2 ⟨0, by omega⟩ = r2_resp from r2_resp_def.symm, hp_resp] at h_r2
        constructor
        · exact (rank_embed_le (by omega : r ≤ r + 2) x' (extendPoint p_resp)).mp
            (show rank_embed (by omega : r ≤ r + 2) x' ≤
              rank_embed (by omega : r ≤ r + 2) (extendPoint p_resp : ExtendedCarrier N atomMap r) from by
              simp only [rank_embed_point]; exact h_r2.1)
        · exact (rank_embed_le (by omega : r ≤ r + 2) (extendPoint p_resp) y').mp
            (show rank_embed (by omega : r ≤ r + 2) (extendPoint p_resp : ExtendedCarrier N atomMap r) ≤
              rank_embed (by omega : r ≤ r + 2) y' from by
              simp only [rank_embed_point]; exact h_r2.2)
      -- Cofinal failure: ∃ mu v with extendPoint(p_resp) < v ≤ d, ¬cont_holds v
      obtain ⟨v, hpv, hv_le_d, hvy', hmu_v, h_not_cont_v⟩ :=
        h_cofinal_failure_below_d (extendPoint p_resp) hp_in hp_lt_d
      obtain ⟨q, hq⟩ := hmu_v
      rw [hq] at hpv hv_le_d hvy' h_not_cont_v
      -- rank_embed(extendPoint(q)) > r2_resp at rank r+2
      have hr2_lt_q : r2_resp < (extendPoint q : ExtendedCarrier N atomMap (r + 2)) := by
        rw [hp_resp]
        show (extendPoint p_resp : ExtendedCarrier N atomMap (r + 2)) <
          (extendPoint q : ExtendedCarrier N atomMap (r + 2))
        have h := (rank_embed_lt (by omega : r ≤ r + 2)
          (extendPoint p_resp : ExtendedCarrier N atomMap r)
          (extendPoint q : ExtendedCarrier N atomMap r)).mpr hpv
        simp only [rank_embed_point] at h
        exact h
      -- h_cont_transfer gives cont_holds at q, contradicting ¬cont_holds
      exact h_not_cont_v (h_cont_transfer q hr2_lt_q hvy')
    · -- r2_resp is a gap, r2_resp < rank_embed(d). Use order agreement.
      -- Extract order agreement for boundary analysis.
      obtain ⟨p_N₂, hp_N₂⟩ := h_pt
      have hp_N₂_r2 : inClosedInterval
          (rank_embed (by omega : r ≤ r + 2) x')
          (rank_embed (by omega : r ≤ r + 2) y')
          (extendPoint p_N₂ : ExtendedCarrier N atomMap (r + 2)) := by
        rw [← rank_embed_point (by omega : r ≤ r + 2) p_N₂]
        exact (rank_embed_inClosedInterval (by omega : r ≤ r + 2) x' y'
          (extendPoint p_N₂)).mpr hp_N₂
      obtain ⟨b_w₂, _, hcond_w₂⟩ := hwin_r2 p_N₂ hp_N₂_r2
      obtain ⟨hord_w₂, _, _⟩ := hcond_w₂
      -- Order (1,3): rank_embed(c_inf) < rank_embed(y) ↔ r2_resp < rank_embed(y')
      have hord_13₂ := hord_w₂ ⟨1, by omega⟩ ⟨3, by omega⟩
      simp only [game_tuple, show (1 : Nat) ≠ 0 from by omega,
                 show (1 : Nat) ≠ 1 + 1 from by omega,
                 show (1 : Nat) ≠ 1 + 2 from by omega, dite_false,
                 show 1 - 1 = 0 from by omega,
                 show (3 : Nat) ≠ 0 from by omega,
                 show ¬((3 : Nat) = 1 + 1) from by omega,
                 show (3 : Nat) = 1 + 2 from by omega, dite_true] at hord_13₂
      -- Also extract (0,1)
      have hord_01₂ := hord_w₂ ⟨0, by omega⟩ ⟨1, by omega⟩
      simp only [game_tuple, show (0 : Nat) = 0 from rfl, dite_true,
                 show (1 : Nat) ≠ 0 from by omega,
                 show (1 : Nat) ≠ 1 + 1 from by omega,
                 show (1 : Nat) ≠ 1 + 2 from by omega, dite_false,
                 show 1 - 1 = 0 from by omega] at hord_01₂
      -- Case split: c_inf = y (right boundary) or c_inf < y
      rcases eq_or_lt_of_le hc_inf_interval.2 with hc_eq_y | hc_lt_y
      · -- c_inf = y: order (1,3) equality gives r2_resp = rank_embed(y')
        have h_eq : rank_embed (by omega : r ≤ r + 2) c_inf =
            rank_embed (by omega : r ≤ r + 2) y := by rw [hc_eq_y]
        have h_r2_eq_y' : a'_r2 ⟨0, by omega⟩ = rank_embed (by omega : r ≤ r + 2) y' :=
          hord_13₂.2.mp h_eq
        -- r2_resp = rank_embed(y') ≥ rank_embed(d)
        have : r2_resp = rank_embed (by omega : r ≤ r + 2) y' := h_r2_eq_y'
        have hd_le_y' : rank_embed (by omega : r ≤ r + 2) d ≤
            rank_embed (by omega : r ≤ r + 2) y' :=
          (rank_embed_le (by omega : r ≤ r + 2) d y').mpr hd_interval.2
        exact absurd (this ▸ hd_le_y') (not_le.mpr h_not_le)
      · -- c_inf < y and c_inf > x (interior case)
        -- c_inf = x boundary case
        rcases eq_or_lt_of_le hc_inf_interval.1 with hx_eq_c | hx_lt_c
        · -- x = c_inf: order (0,1) equality gives r2_resp = rank_embed(x')
          have h_eq : rank_embed (by omega : r ≤ r + 2) x =
              rank_embed (by omega : r ≤ r + 2) c_inf := by rw [hx_eq_c]
          have h_r2_eq_x' : rank_embed (by omega : r ≤ r + 2) x' = a'_r2 ⟨0, by omega⟩ :=
            hord_01₂.2.mp h_eq
          -- r2_resp = rank_embed(x') ≤ rank_embed(d)
          have hx'_le_d : rank_embed (by omega : r ≤ r + 2) x' ≤
              rank_embed (by omega : r ≤ r + 2) d :=
            (rank_embed_le (by omega : r ≤ r + 2) x' d).mpr hd_interval.1
          -- h_not_le : r2_resp < rank_embed(d)
          -- This is consistent with r2_resp ≤ rank_embed(d). No contradiction here.
          -- But: r2_resp is a gap (Sum.inr g_resp).
          -- rank_embed(x') might equal rank_embed(d) or be strictly less.
          -- If r2_resp = rank_embed(x') and x' = d: r2_resp = rank_embed(d).
          -- Contradicts h_not_le: r2_resp < rank_embed(d).
          -- If x' < d: r2_resp = rank_embed(x') < rank_embed(d). Consistent.
          -- r2_resp = rank_embed(x') (from h_r2_eq_x') and r2_resp < rank_embed(d),
          -- so rank_embed(x') < rank_embed(d) hence x' < d.
          -- Use h_cofinal_failure_below_d to get a mu-point u with x' < u < y' and ¬cont_holds.
          -- Since r2_resp = rank_embed(x') < rank_embed(u) (carrier point above x'),
          -- h_cont_transfer gives cont_holds at u. Contradiction.
          have hx'_lt_d : x' < d := by
            have : rank_embed (by omega : r ≤ r + 2) x' < rank_embed (by omega : r ≤ r + 2) d := by
              calc rank_embed (by omega : r ≤ r + 2) x' = a'_r2 ⟨0, by omega⟩ := h_r2_eq_x'
                _ = r2_resp := r2_resp_def.symm
                _ < rank_embed (by omega : r ≤ r + 2) d := h_not_le
            exact (rank_embed_lt (by omega : r ≤ r + 2) x' d).mp this
          obtain ⟨u, hx'u, hud, huy', hmu_u, h_not_cont_u⟩ :=
            h_cofinal_failure_below_d x' ⟨le_refl x', hx'y'⟩ hx'_lt_d
          obtain ⟨q_u, hq_u⟩ := hmu_u
          rw [hq_u] at hx'u huy' h_not_cont_u
          -- r2_resp = rank_embed(x') < extendPoint(q_u) at rank r+2
          have hr2_lt_qu : r2_resp <
              (extendPoint q_u : ExtendedCarrier N atomMap (r + 2)) := by
            calc r2_resp = a'_r2 ⟨0, by omega⟩ := r2_resp_def.symm
              _ = rank_embed (by omega : r ≤ r + 2) x' := h_r2_eq_x'.symm
              _ < rank_embed (by omega : r ≤ r + 2) (extendPoint q_u) := by
                  exact (rank_embed_lt (by omega : r ≤ r + 2) x' (extendPoint q_u)).mpr hx'u
              _ = extendPoint q_u := rank_embed_point (by omega : r ≤ r + 2) q_u
          exact h_not_cont_u (h_cont_transfer q_u hr2_lt_qu huy')
        · -- Interior case: x < c_inf < y, gap, r2_resp < rank_embed(d).
          -- Strategy: find carrier point q ∉ g_resp.val.cut with extendPoint q < d,
          -- then h_cofinal_failure_below_d gives failure u above q. By downward-closure
          -- of the gap's cut, u's carrier point is also ∉ cut, so r2_resp < u at rank r+2.
          -- h_cont_transfer gives cont_holds at u, contradicting the failure.
          --
          -- Step 1: x' < d from order agreement
          have hx'_lt_d : x' < d := by
            have hx_lt_c_r2 : rank_embed (by omega : r ≤ r + 2) x <
                rank_embed (by omega : r ≤ r + 2) c_inf :=
              (rank_embed_lt (by omega : r ≤ r + 2) x c_inf).mpr hx_lt_c
            have hx'_lt_r2 : rank_embed (by omega : r ≤ r + 2) x' < r2_resp := by
              rw [show r2_resp = a'_r2 ⟨0, by omega⟩ from r2_resp_def.symm]
              exact hord_01₂.1.mp hx_lt_c_r2
            exact (rank_embed_lt (by omega : r ≤ r + 2) x' d).mp
              (lt_trans hx'_lt_r2 h_not_le)
          -- Step 2: Find a carrier point q ∉ g_resp.val.cut with extendPoint q < d.
          -- Case split on d being a point or gap.
          rcases isPoint_or_isGap d with ⟨p_d, hp_d⟩ | ⟨g_d, hg_d⟩
          · -- d = extendPoint p_d (carrier point)
            -- p_d ∉ g_resp.val.cut (since r2_resp < rank_embed(d) = extendPoint p_d)
            have hp_d_not_cut : p_d ∉ g_resp.val.cut := by
              intro hp_d_in
              -- extendPoint p_d ≤ Sum.inr g_resp = r2_resp
              have h_le : (extendPoint p_d : ExtendedCarrier N atomMap (r + 2)) ≤ r2_resp := by
                rw [hg_resp]; exact hp_d_in
              -- r2_resp < rank_embed(d) = extendPoint p_d
              have h_eq : rank_embed (by omega : r ≤ r + 2) d =
                  (extendPoint p_d : ExtendedCarrier N atomMap (r + 2)) := by
                rw [hp_d]; exact rank_embed_point (by omega : r ≤ r + 2) p_d
              exact absurd (h_eq ▸ h_not_le) (not_lt.mpr h_le)
            -- complement_no_min: ∃ q < p_d with q ∉ cut
            have h_comp_no_min := g_resp.val.complement_no_min
            push_neg at h_comp_no_min
            -- h_comp_no_min says: no minimum in complement.
            -- Since p_d ∉ cut: ∃ q ∉ cut, q < p_d.
            -- Actually complement_no_min = ¬∃ m, m ∉ cut ∧ ∀ y, y ∉ cut → m ≤ y
            -- We need to extract: ∃ q ∉ cut, q < p_d.
            -- From complement_no_min applied to p_d:
            obtain ⟨q, hq_not_cut, hq_lt_pd⟩ :
                ∃ q : N.carrier, q ∉ g_resp.val.cut ∧ q < p_d := by
              by_contra h_all
              push_neg at h_all
              -- h_all : ∀ q, q ∉ g_resp.val.cut → p_d ≤ q
              -- So p_d is a minimum of the complement
              exact g_resp.val.complement_no_min ⟨p_d, hp_d_not_cut, h_all⟩
            -- extendPoint q < d at rank r
            have hq_lt_d : (extendPoint q : ExtendedCarrier N atomMap r) < d := by
              rw [hp_d]
              exact (extendPoint_lt_iff q p_d).mpr hq_lt_pd
            -- r2_resp < extendPoint q at rank r+2
            have hr2_lt_q : r2_resp <
                (extendPoint q : ExtendedCarrier N atomMap (r + 2)) := by
              rw [hg_resp]; exact lt_of_not_ge (fun h => hq_not_cut h)
            -- x' < extendPoint q
            have hx'_lt_q : x' < (extendPoint q : ExtendedCarrier N atomMap r) := by
              have : rank_embed (by omega : r ≤ r + 2) x' <
                  (extendPoint q : ExtendedCarrier N atomMap (r + 2)) := by
                exact lt_trans (by
                  rw [show r2_resp = a'_r2 ⟨0, by omega⟩ from r2_resp_def.symm]
                  exact hord_01₂.1.mp
                    ((rank_embed_lt (by omega : r ≤ r + 2) x c_inf).mpr hx_lt_c))
                  hr2_lt_q
              rw [← rank_embed_point (by omega : r ≤ r + 2) q] at this
              exact (rank_embed_lt (by omega : r ≤ r + 2) x' (extendPoint q)).mp this
            -- extendPoint q ∈ [x', y']
            have hq_interval : inClosedInterval x' y'
                (extendPoint q : ExtendedCarrier N atomMap r) :=
              ⟨le_of_lt hx'_lt_q, le_trans (le_of_lt hq_lt_d) hd_interval.2⟩
            -- Apply h_cofinal_failure_below_d at extendPoint q
            obtain ⟨u, hqu, hud, huy', hmu_u, h_not_cont_u⟩ :=
              h_cofinal_failure_below_d (extendPoint q) hq_interval hq_lt_d
            obtain ⟨q_u, hq_u⟩ := hmu_u
            rw [hq_u] at hqu hud huy' h_not_cont_u
            -- q < q_u (from extendPoint q < extendPoint q_u)
            have hq_lt_qu : q < q_u := (extendPoint_lt_iff q q_u).mp hqu
            -- q_u ∉ g_resp.val.cut (downward-closure contrapositive)
            have hqu_not_cut : q_u ∉ g_resp.val.cut := by
              intro hqu_in
              exact hq_not_cut (g_resp.val.downward_closed q_u q hqu_in (le_of_lt hq_lt_qu))
            -- r2_resp < extendPoint q_u at rank r+2
            have hr2_lt_qu : r2_resp <
                (extendPoint q_u : ExtendedCarrier N atomMap (r + 2)) := by
              rw [hg_resp]; exact lt_of_not_ge (fun h => hqu_not_cut h)
            -- h_cont_transfer gives cont_holds at q_u
            exact h_not_cont_u (h_cont_transfer q_u hr2_lt_qu huy')
          · -- d = Sum.inr g_d (gap case)
            -- r2_resp < rank_embed(d) where both are gaps.
            -- rank_embed(d) = Sum.inr (rank_embed_gap g_d) with same cut as g_d.
            -- g_resp.val.cut ⊊ g_d.val.cut (from r2_resp < rank_embed(d)).
            -- Extract q ∈ g_d.val.cut \ g_resp.val.cut.
            -- Extract q ∈ g_d.val.cut \ g_resp.val.cut from strict gap ordering.
            -- r2_resp < rank_embed(d) at rank r+2, with both being gaps.
            -- This means g_resp.val.cut ⊂ g_d.val.cut (via rank_embed_gap_cut).
            obtain ⟨q, hq_in_gd, hq_not_gr⟩ : ∃ q, q ∈ g_d.val.cut ∧ q ∉ g_resp.val.cut := by
              -- r2_resp ≤ rank_embed(d) gives g_resp.val.cut ⊆ g_d.val.cut (via rank_embed_gap_cut)
              -- r2_resp < rank_embed(d) gives ¬(g_d.val.cut ⊆ g_resp.val.cut) (strict)
              -- So ∃ q ∈ g_d.val.cut \ g_resp.val.cut
              by_contra h_all
              push_neg at h_all
              -- h_all : ∀ q ∈ g_d.val.cut, q ∈ g_resp.val.cut, i.e., g_d.val.cut ⊆ g_resp.val.cut
              -- Combined with g_resp.val.cut ⊆ g_d.val.cut (from ≤): cuts are equal
              -- Equal cuts at rank r+2 means equal gaps, so r2_resp = rank_embed(d), contradicting <
              have h_cut_eq : g_resp.val.cut = g_d.val.cut := by
                apply Set.Subset.antisymm
                · -- g_resp ⊆ g_d: from r2_resp ≤ rank_embed(d), le part
                  intro p hp
                  -- hp : p ∈ g_resp.val.cut, meaning extendPoint p ≤ r2_resp
                  -- From r2_resp ≤ rank_embed(d) and transitivity:
                  -- extendPoint p ≤ rank_embed(d) = Sum.inr (rank_embed_gap g_d)
                  -- So p ∈ (rank_embed_gap g_d).val.cut = g_d.val.cut
                  have h1 : (extendPoint p : ExtendedCarrier N atomMap (r + 2)) ≤ r2_resp := by
                    rw [hg_resp]; exact hp
                  have h2 : (extendPoint p : ExtendedCarrier N atomMap (r + 2)) ≤
                      rank_embed (by omega : r ≤ r + 2) d := le_trans h1 (le_of_lt h_not_le)
                  rw [hg_d, rank_embed_gap_eq] at h2
                  rwa [show (extendPoint p : ExtendedCarrier N atomMap (r + 2)) ≤
                      (Sum.inr (rank_embed_gap (by omega : r ≤ r + 2) g_d) :
                      ExtendedCarrier N atomMap (r + 2)) ↔
                      p ∈ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut from Iff.rfl,
                    rank_embed_gap_cut] at h2
                · exact h_all
              -- Equal cuts means equal gaps (gap_ext), so r2_resp = rank_embed(d)
              have h_gap_eq : g_resp = rank_embed_gap (by omega : r ≤ r + 2) g_d := by
                exact Subtype.ext (gap_ext g_resp.val (rank_embed_gap (by omega : r ≤ r + 2) g_d).val
                  (by rw [rank_embed_gap_cut]; exact h_cut_eq))
              have h_eq : r2_resp = rank_embed (by omega : r ≤ r + 2) d := by
                rw [hg_resp, hg_d, rank_embed_gap_eq]
                exact congrArg Sum.inr h_gap_eq
              exact absurd h_eq (ne_of_lt h_not_le)
            -- extendPoint q < d at rank r (since q ∈ g_d.val.cut)
            have hq_lt_d : (extendPoint q : ExtendedCarrier N atomMap r) < d := by
              rw [hg_d]
              -- q ∈ g_d.val.cut means extendPoint q ≤ Sum.inr g_d
              -- strict because Sum.inl ≠ Sum.inr
              have h_le : (extendPoint q : ExtendedCarrier N atomMap r) ≤ Sum.inr g_d := hq_in_gd
              have h_ne : (extendPoint q : ExtendedCarrier N atomMap r) ≠ Sum.inr g_d := by
                simp [extendPoint]
              exact lt_of_le_of_ne h_le h_ne
            -- r2_resp < extendPoint q at rank r+2
            have hr2_lt_q : r2_resp <
                (extendPoint q : ExtendedCarrier N atomMap (r + 2)) := by
              rw [hg_resp]; exact lt_of_not_ge (fun h => hq_not_gr h)
            -- x' < extendPoint q
            have hx'_lt_q : x' < (extendPoint q : ExtendedCarrier N atomMap r) := by
              have : rank_embed (by omega : r ≤ r + 2) x' <
                  (extendPoint q : ExtendedCarrier N atomMap (r + 2)) := by
                exact lt_trans (by
                  rw [show r2_resp = a'_r2 ⟨0, by omega⟩ from r2_resp_def.symm]
                  exact hord_01₂.1.mp
                    ((rank_embed_lt (by omega : r ≤ r + 2) x c_inf).mpr hx_lt_c))
                  hr2_lt_q
              rw [← rank_embed_point (by omega : r ≤ r + 2) q] at this
              exact (rank_embed_lt (by omega : r ≤ r + 2) x' (extendPoint q)).mp this
            -- extendPoint q ∈ [x', y']
            have hq_interval : inClosedInterval x' y'
                (extendPoint q : ExtendedCarrier N atomMap r) :=
              ⟨le_of_lt hx'_lt_q, le_trans (le_of_lt hq_lt_d) hd_interval.2⟩
            -- Apply h_cofinal_failure_below_d
            obtain ⟨u, hqu, hud, huy', hmu_u, h_not_cont_u⟩ :=
              h_cofinal_failure_below_d (extendPoint q) hq_interval hq_lt_d
            obtain ⟨q_u, hq_u⟩ := hmu_u
            rw [hq_u] at hqu hud huy' h_not_cont_u
            have hq_lt_qu : q < q_u := (extendPoint_lt_iff q q_u).mp hqu
            have hqu_not_cut : q_u ∉ g_resp.val.cut := by
              intro hqu_in
              exact hq_not_gr (g_resp.val.downward_closed q_u q hqu_in (le_of_lt hq_lt_qu))
            have hr2_lt_qu : r2_resp <
                (extendPoint q_u : ExtendedCarrier N atomMap (r + 2)) := by
              rw [hg_resp]; exact lt_of_not_ge (fun h => hqu_not_cut h)
            exact h_not_cont_u (h_cont_transfer q_u hr2_lt_qu huy')
  have h_r2_eq : r2_resp = rank_embed (by omega : r ≤ r + 2) d :=
    le_antisymm h_r2_resp_le_d h_r2_resp_ge_d
  -- Step 6: Get winning condition from rank-(r+2) game for extraction.
  obtain ⟨p_N, hp_N⟩ := h_pt
  have hp_N_r2 : inClosedInterval
      (rank_embed (by omega : r ≤ r + 2) x')
      (rank_embed (by omega : r ≤ r + 2) y')
      (extendPoint p_N) := by
    rw [← rank_embed_point (by omega : r ≤ r + 2) p_N]
    exact (rank_embed_inClosedInterval (by omega : r ≤ r + 2) x' y'
      (extendPoint p_N)).mpr hp_N
  obtain ⟨b_play, hb_play, hcond_play⟩ := hwin_r2 p_N hp_N_r2
  obtain ⟨hord_play, hgp_play, hform_play⟩ := hcond_play
  -- game_tuple indices for k=1 at rank r+2:
  -- 0 = rank_embed(x) / rank_embed(x')
  -- 1 = rank_embed(c_inf) / r2_resp
  -- 2 = extendPoint(b_play) / extendPoint(p_N)
  -- 3 = rank_embed(y) / rank_embed(y')
  -- Extract formula agreement at index 1 at depth r+2:
  have hform_r2_1 : ∀ A : StaviFormula, stavi_depth A ≤ r + 2 →
      (stavi_temporal_truth_mu M atomMap (r + 2)
        (rank_embed (by omega : r ≤ r + 2) c_inf) A ↔
       stavi_temporal_truth_mu N atomMap (r + 2) r2_resp A) := by
    intro A hA
    have h := hform_play ⟨1, by omega⟩ A hA
    simp only [game_tuple, show (1 : Nat) ≠ 0 from by omega,
               show (1 : Nat) ≠ 1 + 1 from by omega,
               show (1 : Nat) ≠ 1 + 2 from by omega, dite_false,
               show 1 - 1 = 0 from by omega] at h
    exact h
  -- Rewrite using h_r2_eq: r2_resp = rank_embed(d)
  rw [h_r2_eq] at hform_r2_1
  -- Step 8: Project formula agreement from rank r+2 to rank r via rank_embed_stavi_truth_mu.
  have hform_cd : ∀ A : StaviFormula, stavi_depth A ≤ r →
      (stavi_temporal_truth_mu M atomMap r c_inf A ↔
       stavi_temporal_truth_mu N atomMap r d A) := by
    intro A hA
    have h_depth_r2 : stavi_depth A ≤ r + 2 := le_trans hA (by omega)
    calc stavi_temporal_truth_mu M atomMap r c_inf A
        ↔ stavi_temporal_truth_mu M atomMap (r + 2)
            (rank_embed (by omega : r ≤ r + 2) c_inf) A :=
          (rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) c_inf A).symm
      _ ↔ stavi_temporal_truth_mu N atomMap (r + 2)
            (rank_embed (by omega : r ≤ r + 2) d) A :=
          hform_r2_1 A h_depth_r2
      _ ↔ stavi_temporal_truth_mu N atomMap r d A :=
          rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) d A
  -- Step 9: Gap/point agreement from rank-(r+2) game, projected to rank r.
  -- rank_embed preserves IsPoint: IsPoint(rank_embed e) ↔ IsPoint e
  -- IsGap = ¬IsPoint (from isPoint_or_isGap), so IsGap also preserved.
  have hgp_r2_1 := hgp_play ⟨1, by omega⟩
  simp only [game_tuple, show (1 : Nat) ≠ 0 from by omega,
             show (1 : Nat) ≠ 1 + 1 from by omega,
             show (1 : Nat) ≠ 1 + 2 from by omega, dite_false,
             show 1 - 1 = 0 from by omega] at hgp_r2_1
  have h_a'_r2_eq_d : a'_r2 ⟨0, by omega⟩ = rank_embed (by omega : r ≤ r + 2) d :=
    r2_resp_def ▸ h_r2_eq
  rw [h_a'_r2_eq_d] at hgp_r2_1
  have hgp_cd : (IsPoint c_inf ↔ IsPoint d) ∧ (IsGap c_inf ↔ IsGap d) := by
    refine ⟨(rank_embed_isPoint _ c_inf).symm.trans
      (hgp_r2_1.1.trans (rank_embed_isPoint _ d)), ?_⟩
    cases c_inf with
    | inl x =>
      cases d with
      | inl y => simp [IsGap]
      | inr g =>
        exfalso
        have := hgp_r2_1.1.mp ⟨x, rfl⟩
        exact (by simp [rank_embed, IsPoint] at this : False)
    | inr g =>
      cases d with
      | inl y =>
        exfalso
        have := hgp_r2_1.1.mpr ⟨y, rfl⟩
        exact (by simp [rank_embed, IsPoint] at this : False)
      | inr g' => simp [IsGap]
  -- Step 10: Boundary correspondence from rank-(r+2) game, projected to rank r.
  have hord_r2_01 := hord_play ⟨0, by omega⟩ ⟨1, by omega⟩
  simp only [game_tuple, show (0 : Nat) = 0 from rfl, dite_true,
             show (1 : Nat) ≠ 0 from by omega,
             show (1 : Nat) ≠ 1 + 1 from by omega,
             show (1 : Nat) ≠ 1 + 2 from by omega, dite_false,
             show 1 - 1 = 0 from by omega] at hord_r2_01
  have hord_r2_13 := hord_play ⟨1, by omega⟩ ⟨3, by omega⟩
  simp only [game_tuple, show (1 : Nat) ≠ 0 from by omega,
             show (1 : Nat) ≠ 1 + 1 from by omega,
             show (1 : Nat) ≠ 1 + 2 from by omega, dite_false,
             show 1 - 1 = 0 from by omega,
             show (3 : Nat) ≠ 0 from by omega,
             show ¬((3 : Nat) = 1 + 1) from by omega,
             show (3 : Nat) = 1 + 2 from by omega, dite_true] at hord_r2_13
  rw [h_a'_r2_eq_d] at hord_r2_01 hord_r2_13
  -- Project boundary from rank r+2 to rank r using rank_embed injectivity.
  have hbdy_cd : (x = c_inf ↔ x' = d) ∧ (c_inf = y ↔ d = y') := by
    have re_eq : ∀ (S : OrderedMonadicStructure sig) (aM : Formula → sig.preds)
        (a b : ExtendedCarrier S aM r),
        rank_embed (by omega : r ≤ r + 2) a = rank_embed (by omega : r ≤ r + 2) b ↔ a = b := by
      intro S aM a b
      constructor
      · intro h
        exact le_antisymm ((rank_embed_le _ a b).mp (le_of_eq h))
          ((rank_embed_le _ b a).mp (le_of_eq h.symm))
      · intro h; rw [h]
    constructor
    · rw [← re_eq M atomMap x c_inf, ← re_eq N atomMap x' d]
      exact hord_r2_01.2
    · rw [← re_eq M atomMap c_inf y, ← re_eq N atomMap d y']
      exact hord_r2_13.2
  -- Step 11: GHR93 Claim 1 interior case (left).
  -- For any Spoiler selection a_pad ending with c_inf, construct Duplicator's
  -- response with d at position 1+3n using rank_down + K⁻(¬D) position tracking.
  have h_interior_left : x' ≠ d → d ≠ y' →
      ∀ (a_pad : Fin (1 + 3 * n + 1) → ExtendedCarrier M atomMap r),
        (∀ i, inClosedInterval x y (a_pad i)) →
        a_pad ⟨1 + 3 * n, by omega⟩ = c_inf →
        ∃ (a'_full : Fin (1 + 3 * n + 1) → ExtendedCarrier N atomMap r),
          (∀ i, inClosedInterval x' y' (a'_full i)) ∧
          (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
            ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
              ghr93_winning_condition (1 + 3 * n + 1)
                (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) ∧
          a'_full ⟨1 + 3 * n, by omega⟩ = d := by
    intro _hx'd _hdy' a_pad ha_pad hc_last
    -- Step 1: Play the multi-round rank r+2 game with rank_embed(a_pad).
    have h_mr1 : ghr93_duplicator_wins M N atomMap (1 + 3 * n + 1) (r + 2)
        (rank_embed (by omega : r ≤ r + 2) x) (rank_embed (by omega : r ≤ r + 2) y)
        (rank_embed (by omega : r ≤ r + 2) x') (rank_embed (by omega : r ≤ r + 2) y') :=
      ghr93_duplicator_wins_round_mono (by omega : 1 + 3 * n + 1 ≤ 4 + 3 * n)
        ((rank_embed_le (by omega : r ≤ r + 2) x y).mpr hxy)
        ((rank_embed_le (by omega : r ≤ r + 2) x' y').mpr hx'y') h_fwd_r1
    -- Embed a_pad to rank r+2
    have ha_pad_r2 : ∀ i, inClosedInterval
        (rank_embed (by omega : r ≤ r + 2) x) (rank_embed (by omega : r ≤ r + 2) y)
        (rank_embed (by omega : r ≤ r + 2) (a_pad i)) :=
      fun i => (rank_embed_inClosedInterval (by omega : r ≤ r + 2) x y (a_pad i)).mpr (ha_pad i)
    obtain ⟨a'_mr, ha'_mr_in, hwin_mr⟩ := h_mr1
      (fun i => rank_embed (by omega : r ≤ r + 2) (a_pad i)) ha_pad_r2
    -- Step 2: Define mr_resp = a'_mr at position 1+3n.
    let mr_resp : ExtendedCarrier N atomMap (r + 2) := a'_mr ⟨1 + 3 * n, by omega⟩
    -- Step 3: Prove cont_transfer for mr_resp (analogous to h_cont_transfer).
    -- For any carrier point p with mr_resp < extendPoint p < y', cont_holds holds.
    -- Uses hwin_mr at game_tuple positions (2+3n, 3+3n) for (c_inf, b).
    have h_cont_transfer_mr : ∀ (p : N.carrier),
        mr_resp < (extendPoint p : ExtendedCarrier N atomMap (r + 2)) →
        (extendPoint p : ExtendedCarrier N atomMap r) < y' →
        cont_holds (a_bwd ⟨n, by omega⟩) y' (extendPoint p) := by
      intro p hmr_lt_p hp_lt_y'
      have hp_in_r2 : inClosedInterval
          (rank_embed (by omega : r ≤ r + 2) x')
          (rank_embed (by omega : r ≤ r + 2) y')
          (extendPoint p : ExtendedCarrier N atomMap (r + 2)) := by
        constructor
        · exact le_trans (ha'_mr_in ⟨1 + 3 * n, by omega⟩).1 (le_of_lt hmr_lt_p)
        · rw [← rank_embed_point (by omega : r ≤ r + 2) p]
          exact le_of_lt ((rank_embed_lt (by omega : r ≤ r + 2)
            (extendPoint p) y').mpr hp_lt_y')
      obtain ⟨b_u, hb_u_in, hcond_u⟩ := hwin_mr p hp_in_r2
      obtain ⟨hord_u, _hgp_u, hform_u⟩ := hcond_u
      -- Extract order at index (2+3n, 3+3n): rank_embed(c_inf) vs extendPoint(b_u)
      -- Multi-round adaptation of h_cont_transfer (lines 3240-3330).
      -- game_tuple indices for n_sel = 1+3*n+1 selections:
      --   a_pad[1+3*n] = c_inf at game index 1+(1+3*n) = 2+3*n
      --   b_u at game index n_sel+1 = (1+3*n+1)+1 = 3+3*n
      --   y at game index n_sel+2 = (1+3*n+1)+2 = 4+3*n
      -- Helpers to convert game_tuple at indices 2+3n, 3+3n, 4+3n.
      -- For n_sel=1+3*n+1: x at 0, selections at 1..(n_sel), b at n_sel+1=3+3*n, y at n_sel+2=4+3*n
      -- Pattern: simp only [game_tuple, show (k : Nat) = n_sel + j from by omega, ...]
      have ha_pad_c : game_tuple (rank_embed (by omega : r ≤ r + 2) x)
            (rank_embed (by omega : r ≤ r + 2) y)
            (fun i => rank_embed (by omega : r ≤ r + 2) (a_pad i)) b_u
            ⟨2 + 3 * n, by omega⟩ = rank_embed (by omega : r ≤ r + 2) c_inf := by
        simp only [game_tuple,
          show (2 + 3 * n : Nat) ≠ 0 from by omega,
          show ¬((2 + 3 * n : Nat) = (1 + 3 * n + 1) + 1) from by omega,
          show ¬((2 + 3 * n : Nat) = (1 + 3 * n + 1) + 2) from by omega,
          dite_false,
          show 2 + 3 * n - 1 = 1 + 3 * n from by omega,
          hc_last]
      -- Index 3+3n = n_sel+1: b slot → extendPoint b_u
      have hgt_M_b : game_tuple (rank_embed (by omega : r ≤ r + 2) x)
            (rank_embed (by omega : r ≤ r + 2) y)
            (fun i => rank_embed (by omega : r ≤ r + 2) (a_pad i)) b_u
            ⟨3 + 3 * n, by omega⟩ = extendPoint b_u := by
        simp only [game_tuple,
          show (3 + 3 * n : Nat) = (1 + 3 * n + 1) + 1 from by omega,
          show (1 + 3 * n + 1 + 1 : Nat) ≠ 0 from by omega,
          dite_true, dite_false]
      -- Index 3+3n = n_sel+1 on N side: b slot → extendPoint p
      have hgt_N_b : game_tuple (rank_embed (by omega : r ≤ r + 2) x')
            (rank_embed (by omega : r ≤ r + 2) y') a'_mr p
            ⟨3 + 3 * n, by omega⟩ = extendPoint p := by
        simp only [game_tuple,
          show (3 + 3 * n : Nat) = (1 + 3 * n + 1) + 1 from by omega,
          show (1 + 3 * n + 1 + 1 : Nat) ≠ 0 from by omega,
          dite_true, dite_false]
      -- Index 4+3n = n_sel+2: y slot → rank_embed(y)
      have hgt_M_y : game_tuple (rank_embed (by omega : r ≤ r + 2) x)
            (rank_embed (by omega : r ≤ r + 2) y)
            (fun i => rank_embed (by omega : r ≤ r + 2) (a_pad i)) b_u
            ⟨4 + 3 * n, by omega⟩ = rank_embed (by omega : r ≤ r + 2) y := by
        simp only [game_tuple,
          show (4 + 3 * n : Nat) = (1 + 3 * n + 1) + 2 from by omega,
          show ¬((1 + 3 * n + 1 + 2 : Nat) = (1 + 3 * n + 1) + 1) from by omega,
          show (1 + 3 * n + 1 + 2 : Nat) ≠ 0 from by omega,
          dite_true, dite_false]
      -- Index 4+3n = n_sel+2 on N side: y slot → rank_embed(y')
      have hgt_N_y : game_tuple (rank_embed (by omega : r ≤ r + 2) x')
            (rank_embed (by omega : r ≤ r + 2) y') a'_mr p
            ⟨4 + 3 * n, by omega⟩ = rank_embed (by omega : r ≤ r + 2) y' := by
        simp only [game_tuple,
          show (4 + 3 * n : Nat) = (1 + 3 * n + 1) + 2 from by omega,
          show ¬((1 + 3 * n + 1 + 2 : Nat) = (1 + 3 * n + 1) + 1) from by omega,
          show (1 + 3 * n + 1 + 2 : Nat) ≠ 0 from by omega,
          dite_true, dite_false]
      -- Index 2+3n on N side: selection slot → a'_mr[1+3*n] = mr_resp
      have hgt_N_c : game_tuple (rank_embed (by omega : r ≤ r + 2) x')
            (rank_embed (by omega : r ≤ r + 2) y') a'_mr p
            ⟨2 + 3 * n, by omega⟩ = a'_mr ⟨1 + 3 * n, by omega⟩ := by
        simp only [game_tuple,
          show (2 + 3 * n : Nat) ≠ 0 from by omega,
          show ¬((2 + 3 * n : Nat) = (1 + 3 * n + 1) + 1) from by omega,
          show ¬((2 + 3 * n : Nat) = (1 + 3 * n + 1) + 2) from by omega,
          dite_false,
          show 2 + 3 * n - 1 = 1 + 3 * n from by omega]
      -- Extract order at index (2+3n, 3+3n): c_inf vs b_u
      have hord_c_b := hord_u ⟨2 + 3 * n, by omega⟩ ⟨3 + 3 * n, by omega⟩
      rw [ha_pad_c, hgt_M_b, hgt_N_c, hgt_N_b] at hord_c_b
      -- hord_c_b : (rank_embed c_inf < extendPoint b_u ↔ mr_resp < extendPoint p) ∧ ...
      -- c_inf < extendPoint b_u at rank r (from order type)
      have hc_lt_bu_r : c_inf < (extendPoint b_u : ExtendedCarrier M atomMap r) := by
        have : rank_embed (by omega : r ≤ r + 2) c_inf <
            (extendPoint b_u : ExtendedCarrier M atomMap (r + 2)) := by
          rw [← rank_embed_point (by omega : r ≤ r + 2) p] at hmr_lt_p
          exact hord_c_b.1.mpr hmr_lt_p
        rw [← rank_embed_point (by omega : r ≤ r + 2) b_u] at this
        exact (rank_embed_lt (by omega : r ≤ r + 2) c_inf (extendPoint b_u)).mp this
      -- Extract order at index (3+3n, 4+3n): extendPoint(b_u) vs rank_embed(y)
      have hord_b_y := hord_u ⟨3 + 3 * n, by omega⟩ ⟨4 + 3 * n, by omega⟩
      rw [hgt_M_b, hgt_M_y, hgt_N_b, hgt_N_y] at hord_b_y
      -- extendPoint(b_u) < y at rank r
      have hbu_lt_y : (extendPoint b_u : ExtendedCarrier M atomMap r) < y := by
        have hp_lt_y'_r2 : (extendPoint p : ExtendedCarrier N atomMap (r + 2)) <
            rank_embed (by omega : r ≤ r + 2) y' := by
          rw [← rank_embed_point (by omega : r ≤ r + 2) p]
          exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint p) y').mpr hp_lt_y'
        have : (extendPoint b_u : ExtendedCarrier M atomMap (r + 2)) <
            rank_embed (by omega : r ≤ r + 2) y := hord_b_y.1.mpr hp_lt_y'_r2
        rw [← rank_embed_point (by omega : r ≤ r + 2) b_u] at this
        exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint b_u) y).mp this
      -- c_inf ∈ S_C_M: cont_holds_cross at extendPoint b_u
      have hmu_bu : mu_holds (extendPoint (sig := sig) (atomMap := atomMap) (r := r) b_u) :=
        ⟨b_u, rfl⟩
      have h_cont_cross_bu : cont_holds_cross (a_bwd ⟨n, by omega⟩) y' (extendPoint b_u) :=
        hc_inf_in_SC_M.2 (extendPoint b_u) hc_lt_bu_r hbu_lt_y hmu_bu
      -- Transfer: A holds at b_u in M → A holds at p in N (via formula agreement)
      intro A hA h_all_mu
      have hA_bu : stavi_temporal_truth_mu M atomMap r (extendPoint b_u) A :=
        h_cont_cross_bu A hA h_all_mu
      -- Formula agreement at index 3+3n (b_u/p slot), depth ≤ r+2
      have hform_3n := hform_u ⟨3 + 3 * n, by omega⟩ A (le_trans hA (by omega : r ≤ r + 2))
      rw [hgt_M_b, hgt_N_b] at hform_3n
      -- Bridge from rank r to rank r+2 via rank_embed_stavi_truth_mu.
      have hM_bridge : stavi_temporal_truth_mu M atomMap (r + 2)
          (extendPoint b_u : ExtendedCarrier M atomMap (r + 2)) A ↔
          stavi_temporal_truth_mu M atomMap r (extendPoint b_u : ExtendedCarrier M atomMap r) A := by
        conv_lhs => rw [show (extendPoint b_u : ExtendedCarrier M atomMap (r + 2)) =
          rank_embed (by omega : r ≤ r + 2) (extendPoint b_u : ExtendedCarrier M atomMap r) from
          (rank_embed_point (by omega : r ≤ r + 2) b_u).symm]
        exact rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) (extendPoint b_u) A
      have hN_bridge : stavi_temporal_truth_mu N atomMap (r + 2)
          (extendPoint p : ExtendedCarrier N atomMap (r + 2)) A ↔
          stavi_temporal_truth_mu N atomMap r (extendPoint p : ExtendedCarrier N atomMap r) A := by
        conv_lhs => rw [show (extendPoint p : ExtendedCarrier N atomMap (r + 2)) =
          rank_embed (by omega : r ≤ r + 2) (extendPoint p : ExtendedCarrier N atomMap r) from
          (rank_embed_point (by omega : r ≤ r + 2) p).symm]
        exact rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) (extendPoint p) A
      exact hN_bridge.mp (hform_3n.mp (hM_bridge.mpr hA_bu))
    -- Step 4: Prove mr_resp ≤ rank_embed(d) (Direction 1: K⁻(¬D_M) argument).
    -- This mirrors the proof of h_r2_resp_le_d but for the multi-round game.
    -- The argument uses h_cont_transfer_mr, cofinal failures, and pigeonhole,
    -- with game indices adapted for the (1+3n+1)-round game.
    have h_mr_resp_le_d : mr_resp ≤ rank_embed (by omega : r ≤ r + 2) d := by
      -- K⁻(¬D_M) argument for the multi-round game. Uses the formula agreement
      -- between rank_embed(c_inf) and rank_embed(d) (from hform_r2_1, already
      -- derived from the 1-round game) combined with multi-round game formula
      -- agreement at position 2+3n to transfer the K⁻ formula.
      --
      -- Step 1: Extract formula agreement at c_inf index from multi-round game.
      -- Play with carrier point p_N (already obtained from h_pt).
      obtain ⟨b_mr_w, _hb_mr_w, hcond_mr_w⟩ := hwin_mr p_N hp_N_r2
      obtain ⟨_hord_mr_w, _hgp_mr_w, hform_mr_w⟩ := hcond_mr_w
      -- Formula agreement at index 2+3n: rank_embed(c_inf) ↔ mr_resp at rank r+2.
      -- game_tuple M-side at 2+3n = rank_embed(a_pad(1+3n)) = rank_embed(c_inf)
      -- game_tuple N-side at 2+3n = a'_mr(1+3n) = mr_resp
      have hform_mr_cinf : ∀ A : StaviFormula, stavi_depth A ≤ r + 2 →
          (stavi_temporal_truth_mu M atomMap (r + 2) (rank_embed (by omega : r ≤ r + 2) c_inf) A ↔
           stavi_temporal_truth_mu N atomMap (r + 2) mr_resp A) := by
        intro A hA
        have h := hform_mr_w ⟨2 + 3 * n, by omega⟩ A hA
        simp only [game_tuple,
          show (2 + 3 * n : Nat) ≠ 0 from by omega,
          show ¬((2 + 3 * n : Nat) = (1 + 3 * n + 1) + 1) from by omega,
          show ¬((2 + 3 * n : Nat) = (1 + 3 * n + 1) + 2) from by omega,
          dite_false,
          show 2 + 3 * n - 1 = 1 + 3 * n from by omega,
          hc_last] at h
        exact h
      -- Step 2: Compose formula agreements to get mr_resp ↔ rank_embed(d) at rank r+2.
      have hform_mr_d : ∀ A : StaviFormula, stavi_depth A ≤ r + 2 →
          (stavi_temporal_truth_mu N atomMap (r + 2) mr_resp A ↔
           stavi_temporal_truth_mu N atomMap (r + 2) (rank_embed (by omega : r ≤ r + 2) d) A) := by
        intro A hA
        exact (hform_mr_cinf A hA).symm.trans (hform_r2_1 A hA)
      -- Step 3: By contradiction.
      by_contra h_not_le
      push_neg at h_not_le
      -- h_not_le : rank_embed d < mr_resp
      -- Step 4: Case split on x = c_inf vs x < c_inf.
      rcases eq_or_lt_of_le hc_inf_interval.1 with hx_eq_c | hx_lt_c
      · -- Case: x = c_inf. Order agreement from multi-round game gives contradiction.
        -- Extract order at (0, 2+3n) from multi-round game:
        -- x < rank_embed(c_inf) ↔ x' < mr_resp
        have hord_0_c := _hord_mr_w ⟨0, by omega⟩ ⟨2 + 3 * n, by omega⟩
        simp only [game_tuple,
          show (0 : Nat) = 0 from rfl, dite_true,
          show (2 + 3 * n : Nat) ≠ 0 from by omega,
          show ¬((2 + 3 * n : Nat) = (1 + 3 * n + 1) + 1) from by omega,
          show ¬((2 + 3 * n : Nat) = (1 + 3 * n + 1) + 2) from by omega,
          dite_false,
          show 2 + 3 * n - 1 = 1 + 3 * n from by omega,
          hc_last] at hord_0_c
        -- x = c_inf: rank_embed(x) = rank_embed(c_inf), so equality branch.
        have h_x_eq : rank_embed (by omega : r ≤ r + 2) x =
            rank_embed (by omega : r ≤ r + 2) c_inf := by rw [hx_eq_c]
        have h_x'_eq : rank_embed (by omega : r ≤ r + 2) x' = mr_resp :=
          hord_0_c.2.mp h_x_eq
        -- mr_resp = rank_embed(x') ≤ rank_embed(d)
        have hx'_le_d : rank_embed (by omega : r ≤ r + 2) x' ≤
            rank_embed (by omega : r ≤ r + 2) d :=
          (rank_embed_le (by omega : r ≤ r + 2) x' d).mpr hd_interval.1
        exact absurd (h_x'_eq.symm ▸ hx'_le_d) (not_le.mpr h_not_le)
      · -- Case: x < c_inf. K⁻(¬D_M) argument.
        -- Case split: does cont_holds_cross hold at c_inf?
        by_cases h_cont_c : cont_holds_cross (a_bwd ⟨n, by omega⟩) y' c_inf
        · -- (A) cont_holds_cross holds at c_inf. K⁻ argument via strict pigeonhole.
          have h_strict_failure :
              ∀ (s : ExtendedCarrier M atomMap r),
                inClosedInterval x y s → s < c_inf →
                ∃ (u : ExtendedCarrier M atomMap r),
                  s < u ∧ u < c_inf ∧ u < y ∧
                  mu_holds u ∧ ¬ cont_holds_cross (a_bwd ⟨n, by omega⟩) y' u := by
            intro s hs hs_lt_c
            obtain ⟨v, hsv, hv_le_c, hvy, hmu_v, h_not_cont_v⟩ :=
              h_cofinal_failure_below_c_inf s hs hs_lt_c
            rcases lt_or_eq_of_le hv_le_c with hv_lt | hv_eq
            · exact ⟨v, hsv, hv_lt, hvy, hmu_v, h_not_cont_v⟩
            · exact absurd h_cont_c (hv_eq ▸ h_not_cont_v)
          -- Bridge to strict pigeonhole precondition:
          have h_strict_bridge :
              ∀ p : M.carrier, p ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') →
                x ≤ (extendPoint p : ExtendedCarrier M atomMap r) →
                (extendPoint p : ExtendedCarrier M atomMap r) < c_inf →
                ∃ (u : M.carrier),
                  p ≤ u ∧
                  u ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') ∧
                  (extendPoint u : ExtendedCarrier M atomMap r) < c_inf ∧
                  ∃ (A : StaviFormula),
                    stavi_depth A ≤ r ∧
                    (∀ v : ExtendedCarrier N atomMap r,
                      a_bwd ⟨n, by omega⟩ < v → v < y' → mu_holds v →
                      stavi_temporal_truth_mu N atomMap r v A) ∧
                    ¬ stavi_temporal_truth M atomMap u A := by
            intro p hp_cut hxp hp_lt_c
            have hp_interval : inClosedInterval x y (extendPoint p : ExtendedCarrier M atomMap r) :=
              ⟨hxp, le_trans (le_of_lt hp_lt_c) hc_inf_interval.2⟩
            obtain ⟨v, hpv, hv_lt_c, _, hmu_v, h_not_cont_v⟩ :=
              h_strict_failure (extendPoint p) hp_interval hp_lt_c
            obtain ⟨q, hq_eq⟩ := hmu_v
            rw [hq_eq] at hpv hv_lt_c h_not_cont_v
            have hq_cut : q ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
              intro s hs; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb s hs)
            have hp_le_q : p ≤ q := (extendPoint_le_iff p q).mp (le_of_lt hpv)
            simp only [cont_holds_cross] at h_not_cont_v
            push_neg at h_not_cont_v
            obtain ⟨B, hB_depth, hB_interval, hB_fail⟩ := h_not_cont_v
            have hB_fail_carrier : ¬ stavi_temporal_truth M atomMap q B :=
              fun h => hB_fail ((stavi_truth_mu_at_point q B).mpr h)
            exact ⟨q, hp_le_q, hq_cut, hv_lt_c, B, hB_depth, hB_interval, hB_fail_carrier⟩
          -- Get starting point for strict pigeonhole.
          obtain ⟨u₀, hx_lt_u₀, hu₀_lt_c, _, hmu_u₀, _⟩ :=
            h_strict_failure x ⟨le_refl x, hxy⟩ hx_lt_c
          obtain ⟨q₀, hq₀⟩ := hmu_u₀
          rw [hq₀] at hx_lt_u₀ hu₀_lt_c
          have hq₀_cut : q₀ ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
            intro s hs; exact le_trans (le_of_lt hu₀_lt_c) (hc_inf_glb s hs)
          -- Apply pigeonhole to get D_M.
          obtain ⟨D_M, hD_depth, hD_interval, hD_cofinal⟩ :=
            pigeonhole_definable_formula_cross_strict hxy
              ⟨q₀, hq₀_cut, le_of_lt hx_lt_u₀, hu₀_lt_c⟩ h_strict_bridge
          -- K⁻(¬D_M) = neg(Since(⊤, D_M)).
          let K_minus := StaviFormula.neg (StaviFormula.std_snce (StaviFormula.neg (.base .bot)) D_M)
          have hK_depth : stavi_depth K_minus ≤ r + 2 := by
            simp only [K_minus, stavi_depth, operator_depth]; omega
          -- Since(⊤, D_M) FALSE at c_inf in M at rank r:
          have h_since_false_c : ¬ stavi_temporal_truth_mu M atomMap r c_inf
              (StaviFormula.std_snce (StaviFormula.neg (.base .bot)) D_M) := by
            simp only [stavi_temporal_truth_mu]
            push_neg
            intro s hs_lt_c _hmu_s _h_neg_bot
            rcases le_or_lt x s with hxs | hsx
            · have hs_interval : inClosedInterval x y s :=
                ⟨hxs, le_trans (le_of_lt hs_lt_c) hc_inf_interval.2⟩
              obtain ⟨v, hsv, hv_lt_c, _, hmu_v, _⟩ :=
                h_strict_failure s hs_interval hs_lt_c
              obtain ⟨q', hq'_eq⟩ := hmu_v
              rw [hq'_eq] at hsv hv_lt_c
              have hq'_cut : q' ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
                intro t ht; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb t ht)
              obtain ⟨u, hq'_le_u, _, hu_lt_c, hD_fail⟩ :=
                hD_cofinal q' hq'_cut (le_trans hxs (le_of_lt hsv)) hv_lt_c
              refine ⟨extendPoint u, hsv.trans_le ((extendPoint_le_iff q' u).mpr hq'_le_u),
                      hu_lt_c, ⟨u, rfl⟩, ?_⟩
              exact fun h => hD_fail ((stavi_truth_mu_at_point u D_M).mp h)
            · obtain ⟨v, hxv, hv_lt_c, _, hmu_v, _⟩ :=
                h_strict_failure x ⟨le_refl x, hxy⟩ hx_lt_c
              obtain ⟨q', hq'_eq⟩ := hmu_v
              rw [hq'_eq] at hxv hv_lt_c
              have hq'_cut : q' ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
                intro t ht; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb t ht)
              obtain ⟨u, hq'_le_u, _, hu_lt_c, hD_fail⟩ :=
                hD_cofinal q' hq'_cut (le_of_lt hxv) hv_lt_c
              refine ⟨extendPoint u, lt_trans hsx (hxv.trans_le ((extendPoint_le_iff q' u).mpr hq'_le_u)),
                      hu_lt_c, ⟨u, rfl⟩, ?_⟩
              exact fun h => hD_fail ((stavi_truth_mu_at_point u D_M).mp h)
          -- K⁻(¬D_M) TRUE at c_inf (M, r):
          have hK_true_c : stavi_temporal_truth_mu M atomMap r c_inf K_minus := h_since_false_c
          -- Transfer K⁻ to mr_resp via composed formula agreement:
          -- c_inf (M,r) → rank_embed(c_inf) (M,r+2) → mr_resp (N,r+2)
          have hK_true_mr : stavi_temporal_truth_mu N atomMap (r + 2) mr_resp K_minus :=
            (hform_mr_cinf K_minus hK_depth).mp
              ((rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) c_inf K_minus).mpr hK_true_c)
          -- Since(⊤, D_M) FALSE at mr_resp:
          simp only [K_minus, stavi_temporal_truth_mu] at hK_true_mr
          -- Show Since(⊤, D_M) TRUE at mr_resp (contradiction).
          -- Witness: rank_embed(d) is below mr_resp, and D_M holds at all mu between them.
          apply hK_true_mr
          rcases isPoint_or_isGap d with ⟨p_d, hp_d⟩ | ⟨g_d, hg_d⟩
          · -- d is a carrier point: use rank_embed(d) as Since witness.
            refine ⟨rank_embed (by omega : r ≤ r + 2) d, h_not_le, ?_, ?_, ?_⟩
            · exact (rank_embed_mu_holds (by omega : r ≤ r + 2) d).mpr ⟨p_d, hp_d⟩
            · simp [temporal_truth_mu]
            · -- D_M holds at all mu between rank_embed(d) and mr_resp.
              intro u hu_gt hu_lt hmu_u
              obtain ⟨q, hq⟩ := hmu_u
              rw [hq] at hu_gt hu_lt ⊢
              have hq_eq : (Sum.inl q : ExtendedCarrier N atomMap (r + 2)) =
                  rank_embed (by omega : r ≤ r + 2)
                    (extendPoint q : ExtendedCarrier N atomMap r) :=
                (rank_embed_point (by omega : r ≤ r + 2) q).symm
              rw [hq_eq, rank_embed_stavi_truth_mu]
              have hd_lt_q : d < (extendPoint q : ExtendedCarrier N atomMap r) := by
                rw [hq_eq] at hu_gt
                exact (rank_embed_lt (by omega : r ≤ r + 2) d (extendPoint q)).mp hu_gt
              have hq_lt_y' : (extendPoint q : ExtendedCarrier N atomMap r) < y' := by
                have hmr_le_y' : mr_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
                  (ha'_mr_in ⟨1 + 3 * n, by omega⟩).2
                have : rank_embed (by omega : r ≤ r + 2) (extendPoint q : ExtendedCarrier N atomMap r) <
                    rank_embed (by omega : r ≤ r + 2) y' := by
                  rw [rank_embed_point]; exact lt_of_lt_of_le hu_lt hmr_le_y'
                exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q) y').mp this
              exact hd_in_SC.2 (extendPoint q) hd_lt_q hq_lt_y' (mu_holds_point q) D_M hD_depth hD_interval
          · -- d is a gap: find carrier point between rank_embed(d) and mr_resp.
            rcases isPoint_or_isGap mr_resp with ⟨q_mr, hq_mr⟩ | ⟨g_mr, hg_mr⟩
            · -- mr_resp is a carrier point: use complement_no_min.
              have hq_mr_not_cut : q_mr ∉ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut := by
                rw [rank_embed_gap_cut]
                intro h_in
                have : (extendPoint q_mr : ExtendedCarrier N atomMap (r + 2)) ≤
                    rank_embed (by omega : r ≤ r + 2) d := by
                  rw [hg_d]; exact h_in
                rw [hq_mr] at h_not_le
                exact absurd this (not_le.mpr h_not_le)
              have : ¬ (∀ q, q ∉ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut → q_mr ≤ q) :=
                fun h => (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.complement_no_min
                  ⟨q_mr, hq_mr_not_cut, h⟩
              push_neg at this
              obtain ⟨q', hq'_not_cut, hq'_lt⟩ := this
              have hq'_gt_d : rank_embed (by omega : r ≤ r + 2) d <
                  (extendPoint q' : ExtendedCarrier N atomMap (r + 2)) := by
                rw [show rank_embed (by omega : r ≤ r + 2) d =
                  (Sum.inr (rank_embed_gap (by omega : r ≤ r + 2) g_d) :
                    ExtendedCarrier N atomMap (r + 2)) from by rw [hg_d]; rfl]
                exact ⟨hq'_not_cut, fun h => absurd h hq'_not_cut⟩
              have hq'_lt_mr : (extendPoint q' : ExtendedCarrier N atomMap (r + 2)) < mr_resp := by
                rw [show mr_resp = (Sum.inl q_mr : ExtendedCarrier N atomMap (r + 2)) from hq_mr]
                exact (extendPoint_lt_iff q' q_mr).mpr hq'_lt
              -- Project to rank r: d < extendPoint q' < y'
              have hd_lt_q'_r : d < (extendPoint q' : ExtendedCarrier N atomMap r) :=
                (rank_embed_lt (by omega : r ≤ r + 2) d (extendPoint q')).mp
                  (by rw [rank_embed_point]; exact hq'_gt_d)
              have hq'_lt_y'_r : (extendPoint q' : ExtendedCarrier N atomMap r) < y' := by
                have hmr_le_y' : mr_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
                  (ha'_mr_in ⟨1 + 3 * n, by omega⟩).2
                have : (extendPoint q' : ExtendedCarrier N atomMap (r + 2)) <
                    rank_embed (by omega : r ≤ r + 2) y' :=
                  lt_of_lt_of_le hq'_lt_mr hmr_le_y'
                rw [← rank_embed_point (by omega : r ≤ r + 2) q'] at this
                exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q') y').mp this
              -- Use extendPoint q' as Since witness.
              refine ⟨extendPoint q', hq'_lt_mr, ⟨q', rfl⟩, ?_, ?_⟩
              · simp [temporal_truth_mu]
              · intro u hu_gt hu_lt hmu_u
                obtain ⟨q_u, hq_u⟩ := hmu_u
                rw [hq_u] at hu_gt hu_lt ⊢
                have hq_eq : (Sum.inl q_u : ExtendedCarrier N atomMap (r + 2)) =
                    rank_embed (by omega : r ≤ r + 2)
                      (extendPoint q_u : ExtendedCarrier N atomMap r) :=
                  (rank_embed_point (by omega : r ≤ r + 2) q_u).symm
                rw [hq_eq, rank_embed_stavi_truth_mu]
                have hd_lt_qu : d < (extendPoint q_u : ExtendedCarrier N atomMap r) := by
                  have : (extendPoint q' : ExtendedCarrier N atomMap (r + 2)) <
                      (extendPoint q_u : ExtendedCarrier N atomMap (r + 2)) := hu_gt
                  rw [← rank_embed_point (by omega : r ≤ r + 2) q',
                      ← rank_embed_point (by omega : r ≤ r + 2) q_u] at this
                  exact lt_trans hd_lt_q'_r
                    ((rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q') (extendPoint q_u)).mp this)
                have hqu_lt_y' : (extendPoint q_u : ExtendedCarrier N atomMap r) < y' := by
                  have hmr_le_y' : mr_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
                    (ha'_mr_in ⟨1 + 3 * n, by omega⟩).2
                  have : rank_embed (by omega : r ≤ r + 2) (extendPoint q_u : ExtendedCarrier N atomMap r) <
                      rank_embed (by omega : r ≤ r + 2) y' := by
                    rw [rank_embed_point]; exact lt_of_lt_of_le hu_lt hmr_le_y'
                  exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_u) y').mp this
                exact hd_in_SC.2 (extendPoint q_u) hd_lt_qu hqu_lt_y' (mu_holds_point q_u) D_M hD_depth hD_interval
            · -- mr_resp is a gap: find carrier point between two gaps.
              rw [hg_d] at h_not_le
              rw [hg_mr] at h_not_le
              have h_strict_sub : ∃ q, q ∈ g_mr.val.cut ∧ q ∉ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut := by
                by_contra h_eq
                push_neg at h_eq
                exact absurd (le_antisymm (le_of_lt h_not_le) h_eq) (ne_of_lt h_not_le)
              obtain ⟨q_w, hq_w_in, hq_w_not⟩ := h_strict_sub
              have hq_w_not_gd : q_w ∉ g_d.val.cut := by
                rwa [rank_embed_gap_cut] at hq_w_not
              have hq_w_lt_mr : (extendPoint q_w : ExtendedCarrier N atomMap (r + 2)) < mr_resp := by
                rw [show mr_resp = (Sum.inr g_mr : ExtendedCarrier N atomMap (r + 2)) from hg_mr]
                constructor
                · exact hq_w_in
                · exact not_not.mpr hq_w_in
              have hq_w_gt_d : rank_embed (by omega : r ≤ r + 2) d <
                  (extendPoint q_w : ExtendedCarrier N atomMap (r + 2)) := by
                rw [show rank_embed (by omega : r ≤ r + 2) d =
                  (Sum.inr (rank_embed_gap (by omega : r ≤ r + 2) g_d) :
                    ExtendedCarrier N atomMap (r + 2)) from by rw [hg_d]; rfl]
                constructor
                · exact hq_w_not
                · exact hq_w_not
              have hd_lt_qw : d < (extendPoint q_w : ExtendedCarrier N atomMap r) :=
                (rank_embed_lt (by omega : r ≤ r + 2) d (extendPoint q_w)).mp
                  (by rw [rank_embed_point]; exact hq_w_gt_d)
              have hqw_lt_y' : (extendPoint q_w : ExtendedCarrier N atomMap r) < y' := by
                have hmr_le_y' : mr_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
                  (ha'_mr_in ⟨1 + 3 * n, by omega⟩).2
                have : (extendPoint q_w : ExtendedCarrier N atomMap (r + 2)) <
                    rank_embed (by omega : r ≤ r + 2) y' :=
                  lt_of_lt_of_le hq_w_lt_mr hmr_le_y'
                rw [← rank_embed_point (by omega : r ≤ r + 2) q_w] at this
                exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_w) y').mp this
              refine ⟨extendPoint q_w, hq_w_lt_mr, ⟨q_w, rfl⟩, ?_, ?_⟩
              · simp [temporal_truth_mu]
              · intro u hu_gt hu_lt hmu_u
                obtain ⟨q_u, hq_u⟩ := hmu_u
                rw [hq_u] at hu_gt hu_lt ⊢
                have hq_eq : (Sum.inl q_u : ExtendedCarrier N atomMap (r + 2)) =
                    rank_embed (by omega : r ≤ r + 2)
                      (extendPoint q_u : ExtendedCarrier N atomMap r) :=
                  (rank_embed_point (by omega : r ≤ r + 2) q_u).symm
                rw [hq_eq, rank_embed_stavi_truth_mu]
                have hd_lt_qu : d < (extendPoint q_u : ExtendedCarrier N atomMap r) := by
                  have : (extendPoint q_w : ExtendedCarrier N atomMap (r + 2)) <
                      (extendPoint q_u : ExtendedCarrier N atomMap (r + 2)) := hu_gt
                  rw [← rank_embed_point (by omega : r ≤ r + 2) q_w,
                      ← rank_embed_point (by omega : r ≤ r + 2) q_u] at this
                  exact lt_trans hd_lt_qw
                    ((rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_w) (extendPoint q_u)).mp this)
                have hqu_lt_y' : (extendPoint q_u : ExtendedCarrier N atomMap r) < y' := by
                  have hmr_le_y' : mr_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
                    (ha'_mr_in ⟨1 + 3 * n, by omega⟩).2
                  have : rank_embed (by omega : r ≤ r + 2) (extendPoint q_u : ExtendedCarrier N atomMap r) <
                      rank_embed (by omega : r ≤ r + 2) y' := by
                    rw [rank_embed_point]; exact lt_of_lt_of_le hu_lt hmr_le_y'
                  exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_u) y').mp this
                exact hd_in_SC.2 (extendPoint q_u) hd_lt_qu hqu_lt_y' (mu_holds_point q_u) D_M hD_depth hD_interval
        · -- (B) cont_holds_cross FAILS at c_inf. Direct formula argument.
          -- Restructured proof: rcases eq_or_lt_of_le kept properly scoped.
          simp only [cont_holds_cross] at h_cont_c
          push_neg at h_cont_c
          obtain ⟨A_fail, hA_depth, hA_interval, hA_fail_c⟩ := h_cont_c
          have hA_fail_mr : ¬ stavi_temporal_truth_mu N atomMap (r + 2) mr_resp A_fail := by
            intro h
            exact hA_fail_c
              ((rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) c_inf A_fail).mp
                ((hform_mr_cinf A_fail (le_trans hA_depth (by omega : r ≤ r + 2))).mpr h))
          -- Show A_fail holds at mr_resp via carrier point above d.
          rcases isPoint_or_isGap mr_resp with ⟨q_mr, hq_mr⟩ | ⟨g_mr, _hg_mr⟩
          · -- mr_resp = extendPoint q_mr (carrier point). Project to rank r.
            have hd_lt_q : d < (extendPoint q_mr : ExtendedCarrier N atomMap r) := by
              have : rank_embed (by omega : r ≤ r + 2) d < mr_resp := h_not_le
              rw [hq_mr] at this
              exact (rank_embed_lt (by omega : r ≤ r + 2) d (extendPoint q_mr)).mp
                (by rw [rank_embed_point]; exact this)
            have hmr_le_y' : mr_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
              (ha'_mr_in ⟨1 + 3 * n, by omega⟩).2
            rcases eq_or_lt_of_le hmr_le_y' with h_eq | h_lt
            · -- mr_resp = rank_embed y': show c_inf = y then K⁻ pigeonhole
              exfalso
              have hord_c_y := _hord_mr_w ⟨2 + 3 * n, by omega⟩ ⟨4 + 3 * n, by omega⟩
              simp only [game_tuple,
                show (2 + 3 * n : Nat) ≠ 0 from by omega,
                show ¬((2 + 3 * n : Nat) = (1 + 3 * n + 1) + 1) from by omega,
                show ¬((2 + 3 * n : Nat) = (1 + 3 * n + 1) + 2) from by omega,
                dite_false,
                show 2 + 3 * n - 1 = 1 + 3 * n from by omega,
                hc_last,
                show (4 + 3 * n : Nat) = (1 + 3 * n + 1) + 2 from by omega,
                show ¬((1 + 3 * n + 1 + 2 : Nat) = (1 + 3 * n + 1) + 1) from by omega,
                show (1 + 3 * n + 1 + 2 : Nat) ≠ 0 from by omega,
                dite_true] at hord_c_y
              have h_c_eq_y : c_inf = y := by
                apply le_antisymm hc_inf_interval.2
                by_contra h_lt_y
                push_neg at h_lt_y
                have : rank_embed (by omega : r ≤ r + 2) c_inf <
                    rank_embed (by omega : r ≤ r + 2) y :=
                  (rank_embed_lt (by omega : r ≤ r + 2) c_inf y).mpr h_lt_y
                have := hord_c_y.1.mp this
                exact absurd (h_eq ▸ this) (lt_irrefl _)
              -- c_inf = y. Same K⁻ pigeonhole argument as Case A.
              have h_strict_failure_s1 :
                  ∀ (s : ExtendedCarrier M atomMap r),
                    inClosedInterval x y s → s < c_inf →
                    ∃ (u : ExtendedCarrier M atomMap r),
                      s < u ∧ u < c_inf ∧ u < y ∧
                      mu_holds u ∧ ¬ cont_holds_cross (a_bwd ⟨n, by omega⟩) y' u := by
                intro s hs hs_lt_c
                obtain ⟨v, hsv, hv_le_c, hvy, hmu_v, h_not_cont_v⟩ :=
                  h_cofinal_failure_below_c_inf s hs hs_lt_c
                exact ⟨v, hsv, h_c_eq_y ▸ hvy, hvy, hmu_v, h_not_cont_v⟩
              have h_strict_bridge_s1 :
                  ∀ p : M.carrier, p ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') →
                    x ≤ (extendPoint p : ExtendedCarrier M atomMap r) →
                    (extendPoint p : ExtendedCarrier M atomMap r) < c_inf →
                    ∃ (u : M.carrier),
                      p ≤ u ∧
                      u ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') ∧
                      (extendPoint u : ExtendedCarrier M atomMap r) < c_inf ∧
                      ∃ (A : StaviFormula),
                        stavi_depth A ≤ r ∧
                        (∀ v : ExtendedCarrier N atomMap r,
                          a_bwd ⟨n, by omega⟩ < v → v < y' → mu_holds v →
                          stavi_temporal_truth_mu N atomMap r v A) ∧
                        ¬ stavi_temporal_truth M atomMap u A := by
                intro p hp_cut hxp hp_lt_c
                have hp_interval : inClosedInterval x y (extendPoint p : ExtendedCarrier M atomMap r) :=
                  ⟨hxp, le_trans (le_of_lt hp_lt_c) hc_inf_interval.2⟩
                obtain ⟨v, hpv, hv_lt_c, _, hmu_v, h_not_cont_v⟩ :=
                  h_strict_failure_s1 (extendPoint p) hp_interval hp_lt_c
                obtain ⟨q, hq_eq⟩ := hmu_v
                rw [hq_eq] at hpv hv_lt_c h_not_cont_v
                have hq_cut : q ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
                  intro s hs; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb s hs)
                have hp_le_q : p ≤ q := (extendPoint_le_iff p q).mp (le_of_lt hpv)
                simp only [cont_holds_cross] at h_not_cont_v
                push_neg at h_not_cont_v
                obtain ⟨B, hB_depth, hB_interval, hB_fail⟩ := h_not_cont_v
                have hB_fail_carrier : ¬ stavi_temporal_truth M atomMap q B :=
                  fun h => hB_fail ((stavi_truth_mu_at_point q B).mpr h)
                exact ⟨q, hp_le_q, hq_cut, hv_lt_c, B, hB_depth, hB_interval, hB_fail_carrier⟩
              obtain ⟨u₀, hx_lt_u₀, hu₀_lt_c, _, hmu_u₀, _⟩ :=
                h_strict_failure_s1 x ⟨le_refl x, hxy⟩ (h_c_eq_y.symm ▸ hx_lt_c)
              obtain ⟨q₀, hq₀⟩ := hmu_u₀
              rw [hq₀] at hx_lt_u₀ hu₀_lt_c
              have hq₀_cut : q₀ ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
                intro s hs; exact le_trans (le_of_lt hu₀_lt_c) (hc_inf_glb s hs)
              obtain ⟨D_M', hD_depth', hD_interval', hD_cofinal'⟩ :=
                pigeonhole_definable_formula_cross_strict hxy
                  ⟨q₀, hq₀_cut, le_of_lt hx_lt_u₀, hu₀_lt_c⟩ h_strict_bridge_s1
              let K_minus' := StaviFormula.neg (StaviFormula.std_snce (StaviFormula.neg (.base .bot)) D_M')
              have hK_depth' : stavi_depth K_minus' ≤ r + 2 := by
                simp only [K_minus', stavi_depth, operator_depth]; omega
              have h_since_false_c' : ¬ stavi_temporal_truth_mu M atomMap r c_inf
                  (StaviFormula.std_snce (StaviFormula.neg (.base .bot)) D_M') := by
                simp only [stavi_temporal_truth_mu]; push_neg
                intro s hs_lt_c _hmu_s _h_neg_bot
                rcases le_or_lt x s with hxs | hsx
                · have hs_interval : inClosedInterval x y s :=
                    ⟨hxs, le_trans (le_of_lt hs_lt_c) hc_inf_interval.2⟩
                  obtain ⟨v, hsv, hv_lt_c, _, hmu_v, _⟩ :=
                    h_strict_failure_s1 s hs_interval hs_lt_c
                  obtain ⟨q', hq'_eq⟩ := hmu_v
                  rw [hq'_eq] at hsv hv_lt_c
                  have hq'_cut : q' ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
                    intro t ht; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb t ht)
                  obtain ⟨u, hq'_le_u, _, hu_lt_c, hD_fail⟩ :=
                    hD_cofinal' q' hq'_cut (le_trans hxs (le_of_lt hsv)) hv_lt_c
                  refine ⟨extendPoint u, hsv.trans_le ((extendPoint_le_iff q' u).mpr hq'_le_u),
                          hu_lt_c, ⟨u, rfl⟩, ?_⟩
                  exact fun h => hD_fail ((stavi_truth_mu_at_point u D_M').mp h)
                · obtain ⟨v, hxv, hv_lt_c, _, hmu_v, _⟩ :=
                    h_strict_failure_s1 x ⟨le_refl x, hxy⟩ (h_c_eq_y.symm ▸ hx_lt_c)
                  obtain ⟨q', hq'_eq⟩ := hmu_v
                  rw [hq'_eq] at hxv hv_lt_c
                  have hq'_cut : q' ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
                    intro t ht; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb t ht)
                  obtain ⟨u, hq'_le_u, _, hu_lt_c, hD_fail⟩ :=
                    hD_cofinal' q' hq'_cut (le_of_lt hxv) hv_lt_c
                  refine ⟨extendPoint u, lt_trans hsx (hxv.trans_le ((extendPoint_le_iff q' u).mpr hq'_le_u)),
                          hu_lt_c, ⟨u, rfl⟩, ?_⟩
                  exact fun h => hD_fail ((stavi_truth_mu_at_point u D_M').mp h)
              have hK_true_mr' : stavi_temporal_truth_mu N atomMap (r + 2) mr_resp K_minus' :=
                (hform_mr_cinf K_minus' hK_depth').mp
                  ((rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) c_inf K_minus').mpr h_since_false_c')
              simp only [K_minus', stavi_temporal_truth_mu] at hK_true_mr'
              apply hK_true_mr'
              have hd_lt_y' : d < y' :=
                (rank_embed_lt (by omega : r ≤ r + 2) d y').mp (h_eq ▸ h_not_le)
              rcases isPoint_or_isGap d with ⟨p_d, hp_d⟩ | ⟨g_d_pt, hg_d_pt⟩
              · refine ⟨rank_embed (by omega : r ≤ r + 2) d, h_not_le, ?_, ?_, ?_⟩
                · exact (rank_embed_mu_holds (by omega : r ≤ r + 2) d).mpr ⟨p_d, hp_d⟩
                · simp [temporal_truth_mu]
                · intro u hu_gt hu_lt hmu_u
                  obtain ⟨q_u, hq_u⟩ := hmu_u
                  rw [hq_u] at hu_gt hu_lt ⊢
                  have hq_eq : (Sum.inl q_u : ExtendedCarrier N atomMap (r + 2)) =
                      rank_embed (by omega : r ≤ r + 2) (extendPoint q_u : ExtendedCarrier N atomMap r) :=
                    (rank_embed_point (by omega : r ≤ r + 2) q_u).symm
                  rw [hq_eq, rank_embed_stavi_truth_mu]
                  have hd_lt_qu : d < (extendPoint q_u : ExtendedCarrier N atomMap r) := by
                    rw [hq_eq] at hu_gt
                    exact (rank_embed_lt (by omega : r ≤ r + 2) d (extendPoint q_u)).mp hu_gt
                  have hqu_lt_y' : (extendPoint q_u : ExtendedCarrier N atomMap r) < y' := by
                    have : rank_embed (by omega : r ≤ r + 2) (extendPoint q_u : ExtendedCarrier N atomMap r) <
                        rank_embed (by omega : r ≤ r + 2) y' := by
                      rw [rank_embed_point]; exact lt_of_lt_of_le hu_lt (h_eq ▸ le_refl _)
                    exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_u) y').mp this
                  exact hd_in_SC.2 (extendPoint q_u) hd_lt_qu hqu_lt_y' (mu_holds_point q_u) D_M' hD_depth' hD_interval'
              · -- d is a gap. Use complement_no_min.
                have hq_mr_not_gd : q_mr ∉ (rank_embed_gap (by omega : r ≤ r + 2) g_d_pt).val.cut := by
                  rw [rank_embed_gap_cut]; intro h_in
                  have : (extendPoint q_mr : ExtendedCarrier N atomMap (r + 2)) ≤
                      rank_embed (by omega : r ≤ r + 2) d := by rw [hg_d_pt]; exact h_in
                  rw [hq_mr] at h_not_le; exact absurd this (not_le.mpr h_not_le)
                have : ¬(∀ q, q ∉ (rank_embed_gap (by omega : r ≤ r + 2) g_d_pt).val.cut → q_mr ≤ q) :=
                  fun h => (rank_embed_gap (by omega : r ≤ r + 2) g_d_pt).val.complement_no_min
                    ⟨q_mr, hq_mr_not_gd, h⟩
                push_neg at this
                obtain ⟨q', hq'_not, hq'_lt⟩ := this
                have hq'_gt_d : rank_embed (by omega : r ≤ r + 2) d <
                    (extendPoint q' : ExtendedCarrier N atomMap (r + 2)) := by
                  rw [show rank_embed (by omega : r ≤ r + 2) d =
                    (Sum.inr (rank_embed_gap (by omega : r ≤ r + 2) g_d_pt) :
                      ExtendedCarrier N atomMap (r + 2)) from by rw [hg_d_pt]; rfl]
                  constructor
                  · exact (show q' ∉ (rank_embed_gap (by omega : r ≤ r + 2) g_d_pt).val.cut from hq'_not)
                  · exact (show ¬(q' ∈ (rank_embed_gap (by omega : r ≤ r + 2) g_d_pt).val.cut) from
                      fun h => absurd h hq'_not)
                have hd_lt_q' : d < (extendPoint q' : ExtendedCarrier N atomMap r) :=
                  (rank_embed_lt (by omega : r ≤ r + 2) d (extendPoint q')).mp
                    (by rw [rank_embed_point]; exact hq'_gt_d)
                have hq'_lt_mr : (extendPoint q' : ExtendedCarrier N atomMap (r + 2)) < mr_resp := by
                  rw [hq_mr]; exact (extendPoint_lt_iff q' q_mr).mpr hq'_lt
                refine ⟨extendPoint q', hq'_lt_mr, ⟨q', rfl⟩, ?_, ?_⟩
                · simp [temporal_truth_mu]
                · intro u hu_gt hu_lt hmu_u
                  obtain ⟨q_u, hq_u⟩ := hmu_u
                  rw [hq_u] at hu_gt hu_lt ⊢
                  have hq_eq : (Sum.inl q_u : ExtendedCarrier N atomMap (r + 2)) =
                      rank_embed (by omega : r ≤ r + 2) (extendPoint q_u : ExtendedCarrier N atomMap r) :=
                    (rank_embed_point (by omega : r ≤ r + 2) q_u).symm
                  rw [hq_eq, rank_embed_stavi_truth_mu]
                  have hd_lt_qu : d < (extendPoint q_u : ExtendedCarrier N atomMap r) := by
                    have : (extendPoint q' : ExtendedCarrier N atomMap (r + 2)) <
                        (extendPoint q_u : ExtendedCarrier N atomMap (r + 2)) := hu_gt
                    rw [← rank_embed_point (by omega : r ≤ r + 2) q',
                        ← rank_embed_point (by omega : r ≤ r + 2) q_u] at this
                    exact lt_trans hd_lt_q'
                      ((rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q') (extendPoint q_u)).mp this)
                  have hqu_lt_y' : (extendPoint q_u : ExtendedCarrier N atomMap r) < y' := by
                    have hmr_le_y'2 : mr_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
                      (ha'_mr_in ⟨1 + 3 * n, by omega⟩).2
                    have : rank_embed (by omega : r ≤ r + 2) (extendPoint q_u : ExtendedCarrier N atomMap r) <
                        rank_embed (by omega : r ≤ r + 2) y' := by
                      rw [rank_embed_point]; exact lt_of_lt_of_le hu_lt hmr_le_y'2
                    exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_u) y').mp this
                  exact hd_in_SC.2 (extendPoint q_u) hd_lt_qu hqu_lt_y' (mu_holds_point q_u) D_M' hD_depth' hD_interval'
            · -- h_lt: mr_resp < rank_embed y'. Direct contradiction via A_fail.
              have hq_lt_y' : (extendPoint q_mr : ExtendedCarrier N atomMap r) < y' := by
                have : rank_embed (by omega : r ≤ r + 2)
                    (extendPoint q_mr : ExtendedCarrier N atomMap r) <
                    rank_embed (by omega : r ≤ r + 2) y' := by
                  rw [rank_embed_point]
                  rw [show mr_resp = (extendPoint q_mr : ExtendedCarrier N atomMap (r + 2)) from hq_mr] at h_lt
                  exact h_lt
                exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_mr) y').mp this
              have hA_holds_q : stavi_temporal_truth_mu N atomMap r
                  (extendPoint q_mr : ExtendedCarrier N atomMap r) A_fail :=
                hd_in_SC.2 (extendPoint q_mr) hd_lt_q hq_lt_y' (mu_holds_point q_mr)
                  A_fail hA_depth hA_interval
              have hN_bridge : stavi_temporal_truth_mu N atomMap (r + 2)
                  (extendPoint q_mr : ExtendedCarrier N atomMap (r + 2)) A_fail ↔
                  stavi_temporal_truth_mu N atomMap r
                    (extendPoint q_mr : ExtendedCarrier N atomMap r) A_fail := by
                conv_lhs => rw [show (extendPoint q_mr : ExtendedCarrier N atomMap (r + 2)) =
                  rank_embed (by omega : r ≤ r + 2)
                    (extendPoint q_mr : ExtendedCarrier N atomMap r) from
                  (rank_embed_point (by omega : r ≤ r + 2) q_mr).symm]
                exact rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) (extendPoint q_mr) A_fail
              have hA_holds_mr : stavi_temporal_truth_mu N atomMap (r + 2) mr_resp A_fail := by
                rw [hq_mr]; exact hN_bridge.mpr hA_holds_q
              exact hA_fail_mr hA_holds_mr
          · -- mr_resp is a gap at rank r+2.
            have h_gp_c := _hgp_mr_w ⟨2 + 3 * n, by omega⟩
            simp only [game_tuple,
              show (2 + 3 * n : Nat) ≠ 0 from by omega,
              show ¬((2 + 3 * n : Nat) = (1 + 3 * n + 1) + 1) from by omega,
              show ¬((2 + 3 * n : Nat) = (1 + 3 * n + 1) + 2) from by omega,
              dite_false,
              show 2 + 3 * n - 1 = 1 + 3 * n from by omega,
              hc_last] at h_gp_c
            have h_not_pt_mr : ¬IsPoint mr_resp := by
              intro ⟨q, hq⟩; simp [_hg_mr] at hq
            have h_not_pt_rc : ¬IsPoint (rank_embed (by omega : r ≤ r + 2) c_inf) :=
              fun h => h_not_pt_mr (h_gp_c.1.mp h)
            have h_not_pt_c : ¬IsPoint c_inf := by
              rwa [← rank_embed_isPoint (by omega : r ≤ r + 2) c_inf]
            have h_gap_c : IsGap c_inf := (isPoint_or_isGap c_inf).resolve_left h_not_pt_c
            have h_strict_failure_s2 :
                ∀ (s : ExtendedCarrier M atomMap r),
                  inClosedInterval x y s → s < c_inf →
                  ∃ (u : ExtendedCarrier M atomMap r),
                    s < u ∧ u < c_inf ∧ u < y ∧
                    mu_holds u ∧ ¬ cont_holds_cross (a_bwd ⟨n, by omega⟩) y' u := by
              intro s hs hs_lt_c
              obtain ⟨v, hsv, hv_le_c, hvy, hmu_v, h_not_cont_v⟩ :=
                h_cofinal_failure_below_c_inf s hs hs_lt_c
              have hv_ne_c : v ≠ c_inf := by
                obtain ⟨g_c, hg_c⟩ := h_gap_c
                intro heq
                obtain ⟨p_v, hp_v⟩ := hmu_v
                simp [heq, hg_c] at hp_v
              exact ⟨v, hsv, lt_of_le_of_ne hv_le_c hv_ne_c, hvy, hmu_v, h_not_cont_v⟩
            have h_strict_bridge_s2 :
                ∀ p : M.carrier, p ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') →
                  x ≤ (extendPoint p : ExtendedCarrier M atomMap r) →
                  (extendPoint p : ExtendedCarrier M atomMap r) < c_inf →
                  ∃ (u : M.carrier),
                    p ≤ u ∧
                    u ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') ∧
                    (extendPoint u : ExtendedCarrier M atomMap r) < c_inf ∧
                    ∃ (A : StaviFormula),
                      stavi_depth A ≤ r ∧
                      (∀ v : ExtendedCarrier N atomMap r,
                        a_bwd ⟨n, by omega⟩ < v → v < y' → mu_holds v →
                        stavi_temporal_truth_mu N atomMap r v A) ∧
                      ¬ stavi_temporal_truth M atomMap u A := by
              intro p hp_cut hxp hp_lt_c
              have hp_interval : inClosedInterval x y (extendPoint p : ExtendedCarrier M atomMap r) :=
                ⟨hxp, le_trans (le_of_lt hp_lt_c) hc_inf_interval.2⟩
              obtain ⟨v, hpv, hv_lt_c, _, hmu_v, h_not_cont_v⟩ :=
                h_strict_failure_s2 (extendPoint p) hp_interval hp_lt_c
              obtain ⟨q, hq_eq⟩ := hmu_v
              rw [hq_eq] at hpv hv_lt_c h_not_cont_v
              have hq_cut : q ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
                intro s hs; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb s hs)
              have hp_le_q : p ≤ q := (extendPoint_le_iff p q).mp (le_of_lt hpv)
              simp only [cont_holds_cross] at h_not_cont_v
              push_neg at h_not_cont_v
              obtain ⟨B, hB_depth, hB_interval, hB_fail⟩ := h_not_cont_v
              have hB_fail_carrier : ¬ stavi_temporal_truth M atomMap q B :=
                fun h => hB_fail ((stavi_truth_mu_at_point q B).mpr h)
              exact ⟨q, hp_le_q, hq_cut, hv_lt_c, B, hB_depth, hB_interval, hB_fail_carrier⟩
            obtain ⟨u₀, hx_lt_u₀, hu₀_lt_c, _, hmu_u₀, _⟩ :=
              h_strict_failure_s2 x ⟨le_refl x, hxy⟩ hx_lt_c
            obtain ⟨q₀, hq₀⟩ := hmu_u₀
            rw [hq₀] at hx_lt_u₀ hu₀_lt_c
            have hq₀_cut : q₀ ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
              intro s hs; exact le_trans (le_of_lt hu₀_lt_c) (hc_inf_glb s hs)
            obtain ⟨D_M, hD_depth, hD_interval, hD_cofinal⟩ :=
              pigeonhole_definable_formula_cross_strict hxy
                ⟨q₀, hq₀_cut, le_of_lt hx_lt_u₀, hu₀_lt_c⟩ h_strict_bridge_s2
            let K_minus := StaviFormula.neg (StaviFormula.std_snce (StaviFormula.neg (.base .bot)) D_M)
            have hK_depth : stavi_depth K_minus ≤ r + 2 := by
              simp only [K_minus, stavi_depth, operator_depth]; omega
            have h_since_false_c : ¬ stavi_temporal_truth_mu M atomMap r c_inf
                (StaviFormula.std_snce (StaviFormula.neg (.base .bot)) D_M) := by
              simp only [stavi_temporal_truth_mu]; push_neg
              intro s hs_lt_c _hmu_s _h_neg_bot
              rcases le_or_lt x s with hxs | hsx
              · have hs_interval : inClosedInterval x y s :=
                  ⟨hxs, le_trans (le_of_lt hs_lt_c) hc_inf_interval.2⟩
                obtain ⟨v, hsv, hv_lt_c, _, hmu_v, _⟩ :=
                  h_strict_failure_s2 s hs_interval hs_lt_c
                obtain ⟨q', hq'_eq⟩ := hmu_v
                rw [hq'_eq] at hsv hv_lt_c
                have hq'_cut : q' ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
                  intro t ht; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb t ht)
                obtain ⟨u, hq'_le_u, _, hu_lt_c, hD_fail⟩ :=
                  hD_cofinal q' hq'_cut (le_trans hxs (le_of_lt hsv)) hv_lt_c
                refine ⟨extendPoint u, hsv.trans_le ((extendPoint_le_iff q' u).mpr hq'_le_u),
                        hu_lt_c, ⟨u, rfl⟩, ?_⟩
                exact fun h => hD_fail ((stavi_truth_mu_at_point u D_M).mp h)
              · obtain ⟨v, hxv, hv_lt_c, _, hmu_v, _⟩ :=
                  h_strict_failure_s2 x ⟨le_refl x, hxy⟩ hx_lt_c
                obtain ⟨q', hq'_eq⟩ := hmu_v
                rw [hq'_eq] at hxv hv_lt_c
                have hq'_cut : q' ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
                  intro t ht; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb t ht)
                obtain ⟨u, hq'_le_u, _, hu_lt_c, hD_fail⟩ :=
                  hD_cofinal q' hq'_cut (le_of_lt hxv) hv_lt_c
                refine ⟨extendPoint u, lt_trans hsx (hxv.trans_le ((extendPoint_le_iff q' u).mpr hq'_le_u)),
                        hu_lt_c, ⟨u, rfl⟩, ?_⟩
                exact fun h => hD_fail ((stavi_truth_mu_at_point u D_M).mp h)
            have hK_true_mr : stavi_temporal_truth_mu N atomMap (r + 2) mr_resp K_minus :=
              (hform_mr_cinf K_minus hK_depth).mp
                ((rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) c_inf K_minus).mpr h_since_false_c)
            simp only [K_minus, stavi_temporal_truth_mu] at hK_true_mr
            apply hK_true_mr
            rcases isPoint_or_isGap d with ⟨p_d, hp_d⟩ | ⟨g_d, hg_d⟩
            · refine ⟨rank_embed (by omega : r ≤ r + 2) d, h_not_le, ?_, ?_, ?_⟩
              · exact (rank_embed_mu_holds (by omega : r ≤ r + 2) d).mpr ⟨p_d, hp_d⟩
              · simp [temporal_truth_mu]
              · intro u hu_gt hu_lt hmu_u
                obtain ⟨q, hq⟩ := hmu_u
                rw [hq] at hu_gt hu_lt ⊢
                have hq_eq : (Sum.inl q : ExtendedCarrier N atomMap (r + 2)) =
                    rank_embed (by omega : r ≤ r + 2) (extendPoint q : ExtendedCarrier N atomMap r) :=
                  (rank_embed_point (by omega : r ≤ r + 2) q).symm
                rw [hq_eq, rank_embed_stavi_truth_mu]
                have hd_lt_q : d < (extendPoint q : ExtendedCarrier N atomMap r) := by
                  rw [hq_eq] at hu_gt
                  exact (rank_embed_lt (by omega : r ≤ r + 2) d (extendPoint q)).mp hu_gt
                have hq_lt_y' : (extendPoint q : ExtendedCarrier N atomMap r) < y' := by
                  have hmr_le_y' : mr_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
                    (ha'_mr_in ⟨1 + 3 * n, by omega⟩).2
                  have : rank_embed (by omega : r ≤ r + 2) (extendPoint q : ExtendedCarrier N atomMap r) <
                      rank_embed (by omega : r ≤ r + 2) y' := by
                    rw [rank_embed_point]; exact lt_of_lt_of_le hu_lt hmr_le_y'
                  exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q) y').mp this
                exact hd_in_SC.2 (extendPoint q) hd_lt_q hq_lt_y' (mu_holds_point q) D_M hD_depth hD_interval
            · -- Both d and mr_resp are gaps. Find carrier point between them.
              rw [hg_d] at h_not_le; rw [_hg_mr] at h_not_le
              have h_strict_sub' : ∃ q, q ∈ g_mr.val.cut ∧ q ∉ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut := by
                by_contra h_eq; push_neg at h_eq
                exact absurd (le_antisymm (le_of_lt h_not_le) h_eq) (ne_of_lt h_not_le)
              obtain ⟨q_w, hq_w_in, hq_w_not⟩ := h_strict_sub'
              have hq_w_lt_mr : (extendPoint q_w : ExtendedCarrier N atomMap (r + 2)) < mr_resp := by
                rw [show mr_resp = (Sum.inr g_mr : ExtendedCarrier N atomMap (r + 2)) from _hg_mr]
                exact ⟨hq_w_in, not_not.mpr hq_w_in⟩
              have hq_w_gt_d : rank_embed (by omega : r ≤ r + 2) d <
                  (extendPoint q_w : ExtendedCarrier N atomMap (r + 2)) := by
                rw [show rank_embed (by omega : r ≤ r + 2) d =
                  (Sum.inr (rank_embed_gap (by omega : r ≤ r + 2) g_d) :
                    ExtendedCarrier N atomMap (r + 2)) from by rw [hg_d]; rfl]
                exact ⟨hq_w_not, hq_w_not⟩
              have hd_lt_qw : d < (extendPoint q_w : ExtendedCarrier N atomMap r) :=
                (rank_embed_lt (by omega : r ≤ r + 2) d (extendPoint q_w)).mp
                  (by rw [rank_embed_point]; exact hq_w_gt_d)
              have hqw_lt_y' : (extendPoint q_w : ExtendedCarrier N atomMap r) < y' := by
                have hmr_le_y' : mr_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
                  (ha'_mr_in ⟨1 + 3 * n, by omega⟩).2
                have : (extendPoint q_w : ExtendedCarrier N atomMap (r + 2)) <
                    rank_embed (by omega : r ≤ r + 2) y' :=
                  lt_of_lt_of_le hq_w_lt_mr hmr_le_y'
                rw [← rank_embed_point (by omega : r ≤ r + 2) q_w] at this
                exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_w) y').mp this
              refine ⟨extendPoint q_w, hq_w_lt_mr, ⟨q_w, rfl⟩, ?_, ?_⟩
              · simp [temporal_truth_mu]
              · intro u hu_gt hu_lt hmu_u
                obtain ⟨q_u, hq_u⟩ := hmu_u
                rw [hq_u] at hu_gt hu_lt ⊢
                have hq_eq : (Sum.inl q_u : ExtendedCarrier N atomMap (r + 2)) =
                    rank_embed (by omega : r ≤ r + 2) (extendPoint q_u : ExtendedCarrier N atomMap r) :=
                  (rank_embed_point (by omega : r ≤ r + 2) q_u).symm
                rw [hq_eq, rank_embed_stavi_truth_mu]
                have hd_lt_qu : d < (extendPoint q_u : ExtendedCarrier N atomMap r) := by
                  have : (extendPoint q_w : ExtendedCarrier N atomMap (r + 2)) <
                      (extendPoint q_u : ExtendedCarrier N atomMap (r + 2)) := hu_gt
                  rw [← rank_embed_point (by omega : r ≤ r + 2) q_w,
                      ← rank_embed_point (by omega : r ≤ r + 2) q_u] at this
                  exact lt_trans hd_lt_qw
                    ((rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_w) (extendPoint q_u)).mp this)
                have hqu_lt_y' : (extendPoint q_u : ExtendedCarrier N atomMap r) < y' := by
                  have hmr_le_y' : mr_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
                    (ha'_mr_in ⟨1 + 3 * n, by omega⟩).2
                  have : rank_embed (by omega : r ≤ r + 2) (extendPoint q_u : ExtendedCarrier N atomMap r) <
                      rank_embed (by omega : r ≤ r + 2) y' := by
                    rw [rank_embed_point]; exact lt_of_lt_of_le hu_lt hmr_le_y'
                  exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_u) y').mp this
                exact hd_in_SC.2 (extendPoint q_u) hd_lt_qu hqu_lt_y' (mu_holds_point q_u) D_M hD_depth hD_interval
    -- Step 5: Prove rank_embed(d) ≤ mr_resp (Direction 2: game Round 2 argument).
    have h_mr_resp_ge_d : rank_embed (by omega : r ≤ r + 2) d ≤ mr_resp := by
      by_contra h_not_le
      push_neg at h_not_le
      -- h_not_le : mr_resp < rank_embed d
      rcases isPoint_or_isGap mr_resp with ⟨p_resp, hp_resp⟩ | ⟨g_resp, hg_resp⟩
      · -- mr_resp = extendPoint(p_resp): carrier point case.
        have hp_lt_d : (extendPoint p_resp : ExtendedCarrier N atomMap r) < d := by
          have : mr_resp < rank_embed (by omega : r ≤ r + 2) d := h_not_le
          rw [hp_resp] at this
          exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint p_resp) d).mp
            (show rank_embed (by omega : r ≤ r + 2) (extendPoint p_resp : ExtendedCarrier N atomMap r)
              < rank_embed (by omega : r ≤ r + 2) d from by
                simp only [rank_embed_point]; exact this)
        have hp_in : inClosedInterval x' y' (extendPoint p_resp : ExtendedCarrier N atomMap r) := by
          have h_r2 := ha'_mr_in ⟨1 + 3 * n, by omega⟩
          rw [show a'_mr ⟨1 + 3 * n, by omega⟩ = mr_resp from rfl, hp_resp] at h_r2
          constructor
          · exact (rank_embed_le (by omega : r ≤ r + 2) x' (extendPoint p_resp)).mp
              (show rank_embed (by omega : r ≤ r + 2) x' ≤
                rank_embed (by omega : r ≤ r + 2) (extendPoint p_resp : ExtendedCarrier N atomMap r) from by
                simp only [rank_embed_point]; exact h_r2.1)
          · exact (rank_embed_le (by omega : r ≤ r + 2) (extendPoint p_resp) y').mp
              (show rank_embed (by omega : r ≤ r + 2) (extendPoint p_resp : ExtendedCarrier N atomMap r) ≤
                rank_embed (by omega : r ≤ r + 2) y' from by
                simp only [rank_embed_point]; exact h_r2.2)
        obtain ⟨v, hpv, hv_le_d, hvy', hmu_v, h_not_cont_v⟩ :=
          h_cofinal_failure_below_d (extendPoint p_resp) hp_in hp_lt_d
        obtain ⟨q, hq⟩ := hmu_v
        rw [hq] at hpv hv_le_d hvy' h_not_cont_v
        have hmr_lt_q : mr_resp < (extendPoint q : ExtendedCarrier N atomMap (r + 2)) := by
          rw [hp_resp]
          show (extendPoint p_resp : ExtendedCarrier N atomMap (r + 2)) <
            (extendPoint q : ExtendedCarrier N atomMap (r + 2))
          have h := (rank_embed_lt (by omega : r ≤ r + 2)
            (extendPoint p_resp : ExtendedCarrier N atomMap r)
            (extendPoint q : ExtendedCarrier N atomMap r)).mpr hpv
          simp only [rank_embed_point] at h
          exact h
        exact h_not_cont_v (h_cont_transfer_mr q hmr_lt_q hvy')
      · -- mr_resp is a gap. Mirror of h_r2_resp_ge_d gap case (lines 3994-4250).
        -- Strategy: derive x' < d, find q with mr_resp < extendPoint q < d at rank r+2,
        -- use h_cofinal_failure_below_d + h_cont_transfer_mr for contradiction.
        -- Step 1: x' < d from rank_embed x' ≤ mr_resp < rank_embed d.
        have hx'_lt_d : x' < d := by
          have h1 : rank_embed (by omega : r ≤ r + 2) x' ≤ mr_resp :=
            (ha'_mr_in ⟨1 + 3 * n, by omega⟩).1
          exact (rank_embed_lt (by omega : r ≤ r + 2) x' d).mp (lt_of_le_of_lt h1 h_not_le)
        -- Step 2: Case split on d being a point or gap.
        rcases isPoint_or_isGap d with ⟨p_d, hp_d⟩ | ⟨g_d, hg_d⟩
        · -- d = extendPoint p_d (carrier point)
          -- p_d ∉ g_resp.val.cut since mr_resp < rank_embed(d) = extendPoint p_d.
          have hp_d_not_cut : p_d ∉ g_resp.val.cut := by
            intro hp_d_in
            have h_le : (extendPoint p_d : ExtendedCarrier N atomMap (r + 2)) ≤ mr_resp := by
              rw [hg_resp]; exact hp_d_in
            have h_eq : rank_embed (by omega : r ≤ r + 2) d =
                (extendPoint p_d : ExtendedCarrier N atomMap (r + 2)) := by
              rw [hp_d]; exact rank_embed_point (by omega : r ≤ r + 2) p_d
            exact absurd (h_eq ▸ h_not_le) (not_lt.mpr h_le)
          -- complement_no_min: ∃ q ∉ cut, q < p_d.
          obtain ⟨q, hq_not_cut, hq_lt_pd⟩ :
              ∃ q : N.carrier, q ∉ g_resp.val.cut ∧ q < p_d := by
            by_contra h_all
            push_neg at h_all
            exact g_resp.val.complement_no_min ⟨p_d, hp_d_not_cut, h_all⟩
          -- extendPoint q < d at rank r.
          have hq_lt_d : (extendPoint q : ExtendedCarrier N atomMap r) < d := by
            rw [hp_d]; exact (extendPoint_lt_iff q p_d).mpr hq_lt_pd
          -- mr_resp < extendPoint q at rank r+2.
          have hmr_lt_q : mr_resp < (extendPoint q : ExtendedCarrier N atomMap (r + 2)) := by
            rw [hg_resp]; exact lt_of_not_ge (fun h => hq_not_cut h)
          -- x' < extendPoint q at rank r.
          have hx'_lt_q : x' < (extendPoint q : ExtendedCarrier N atomMap r) := by
            have h1 : rank_embed (by omega : r ≤ r + 2) x' ≤ mr_resp :=
              (ha'_mr_in ⟨1 + 3 * n, by omega⟩).1
            have h2 : rank_embed (by omega : r ≤ r + 2) x' <
                (extendPoint q : ExtendedCarrier N atomMap (r + 2)) :=
              lt_of_le_of_lt h1 hmr_lt_q
            rw [← rank_embed_point (by omega : r ≤ r + 2) q] at h2
            exact (rank_embed_lt (by omega : r ≤ r + 2) x' (extendPoint q)).mp h2
          -- extendPoint q ∈ [x', y'].
          have hq_interval : inClosedInterval x' y'
              (extendPoint q : ExtendedCarrier N atomMap r) :=
            ⟨le_of_lt hx'_lt_q, le_trans (le_of_lt hq_lt_d) hd_interval.2⟩
          -- Apply h_cofinal_failure_below_d at extendPoint q.
          obtain ⟨u, hqu, _hud, huy', hmu_u, h_not_cont_u⟩ :=
            h_cofinal_failure_below_d (extendPoint q) hq_interval hq_lt_d
          obtain ⟨q_u, hq_u⟩ := hmu_u
          rw [hq_u] at hqu huy' h_not_cont_u
          -- q < q_u from extendPoint q < extendPoint q_u.
          have hq_lt_qu : q < q_u := (extendPoint_lt_iff q q_u).mp hqu
          -- q_u ∉ g_resp.val.cut (downward-closure).
          have hqu_not_cut : q_u ∉ g_resp.val.cut := by
            intro hqu_in
            exact hq_not_cut (g_resp.val.downward_closed q_u q hqu_in (le_of_lt hq_lt_qu))
          -- mr_resp < extendPoint q_u at rank r+2.
          have hmr_lt_qu : mr_resp <
              (extendPoint q_u : ExtendedCarrier N atomMap (r + 2)) := by
            rw [hg_resp]; exact lt_of_not_ge (fun h => hqu_not_cut h)
          exact h_not_cont_u (h_cont_transfer_mr q_u hmr_lt_qu huy')
        · -- d = Sum.inr g_d (gap). Both mr_resp and d are gaps with g_resp.cut ⊊ g_d.cut.
          obtain ⟨q, hq_in_gd, hq_not_gr⟩ : ∃ q, q ∈ g_d.val.cut ∧ q ∉ g_resp.val.cut := by
            by_contra h_all
            push_neg at h_all
            have h_cut_eq : g_resp.val.cut = g_d.val.cut := by
              apply Set.Subset.antisymm
              · intro p hp
                have h1 : (extendPoint p : ExtendedCarrier N atomMap (r + 2)) ≤ mr_resp := by
                  rw [hg_resp]; exact hp
                have h2 : (extendPoint p : ExtendedCarrier N atomMap (r + 2)) ≤
                    rank_embed (by omega : r ≤ r + 2) d := le_trans h1 (le_of_lt h_not_le)
                rw [hg_d, rank_embed_gap_eq] at h2
                rwa [show (extendPoint p : ExtendedCarrier N atomMap (r + 2)) ≤
                    (Sum.inr (rank_embed_gap (by omega : r ≤ r + 2) g_d) :
                    ExtendedCarrier N atomMap (r + 2)) ↔
                    p ∈ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut from Iff.rfl,
                  rank_embed_gap_cut] at h2
              · exact h_all
            have h_gap_eq : g_resp = rank_embed_gap (by omega : r ≤ r + 2) g_d :=
              Subtype.ext (gap_ext g_resp.val (rank_embed_gap (by omega : r ≤ r + 2) g_d).val
                (by rw [rank_embed_gap_cut]; exact h_cut_eq))
            have h_eq : mr_resp = rank_embed (by omega : r ≤ r + 2) d := by
              rw [hg_resp, hg_d, rank_embed_gap_eq]
              exact congrArg Sum.inr h_gap_eq
            exact absurd h_eq (ne_of_lt h_not_le)
          -- extendPoint q < d at rank r (since q ∈ g_d.val.cut).
          have hq_lt_d : (extendPoint q : ExtendedCarrier N atomMap r) < d := by
            rw [hg_d]
            have h_le : (extendPoint q : ExtendedCarrier N atomMap r) ≤ Sum.inr g_d := hq_in_gd
            have h_ne : (extendPoint q : ExtendedCarrier N atomMap r) ≠ Sum.inr g_d := by
              simp [extendPoint]
            exact lt_of_le_of_ne h_le h_ne
          -- mr_resp < extendPoint q at rank r+2.
          have hmr_lt_q : mr_resp <
              (extendPoint q : ExtendedCarrier N atomMap (r + 2)) := by
            rw [hg_resp]; exact lt_of_not_ge (fun h => hq_not_gr h)
          -- x' < extendPoint q at rank r.
          have hx'_lt_q : x' < (extendPoint q : ExtendedCarrier N atomMap r) := by
            have h1 : rank_embed (by omega : r ≤ r + 2) x' ≤ mr_resp :=
              (ha'_mr_in ⟨1 + 3 * n, by omega⟩).1
            have h2 : rank_embed (by omega : r ≤ r + 2) x' <
                (extendPoint q : ExtendedCarrier N atomMap (r + 2)) :=
              lt_of_le_of_lt h1 hmr_lt_q
            rw [← rank_embed_point (by omega : r ≤ r + 2) q] at h2
            exact (rank_embed_lt (by omega : r ≤ r + 2) x' (extendPoint q)).mp h2
          -- extendPoint q ∈ [x', y'].
          have hq_interval : inClosedInterval x' y'
              (extendPoint q : ExtendedCarrier N atomMap r) :=
            ⟨le_of_lt hx'_lt_q, le_trans (le_of_lt hq_lt_d) hd_interval.2⟩
          -- Apply h_cofinal_failure_below_d.
          obtain ⟨u, hqu, _hud, huy', hmu_u, h_not_cont_u⟩ :=
            h_cofinal_failure_below_d (extendPoint q) hq_interval hq_lt_d
          obtain ⟨q_u, hq_u⟩ := hmu_u
          rw [hq_u] at hqu huy' h_not_cont_u
          have hq_lt_qu : q < q_u := (extendPoint_lt_iff q q_u).mp hqu
          have hqu_not_cut : q_u ∉ g_resp.val.cut := by
            intro hqu_in
            exact hq_not_gr (g_resp.val.downward_closed q_u q hqu_in (le_of_lt hq_lt_qu))
          have hmr_lt_qu : mr_resp <
              (extendPoint q_u : ExtendedCarrier N atomMap (r + 2)) := by
            rw [hg_resp]; exact lt_of_not_ge (fun h => hqu_not_cut h)
          exact h_not_cont_u (h_cont_transfer_mr q_u hmr_lt_qu huy')
    -- Step 6: Derive equality.
    have h_mr_eq : mr_resp = rank_embed (by omega : r ≤ r + 2) d :=
      le_antisymm h_mr_resp_le_d h_mr_resp_ge_d
    -- Step 7: Use rank_down with position tracking (ghr93_rank_down_proj).
    -- Since a'_mr(1+3n) = rank_embed(d) (from h_mr_eq), the projected response at
    -- position 1+3n equals d.
    obtain ⟨a'_rd, ha'_rd, hwin_rd, hpos_rd⟩ := ghr93_rank_down_proj
      (by omega : r ≤ r + 2) (by omega : r + 2 ≤ r + 2) hxy hx'y'
      a_pad ha_pad a'_mr ha'_mr_in hwin_mr ⟨p_N, hp_N⟩
    exact ⟨a'_rd, ha'_rd, hwin_rd,
      hpos_rd ⟨1 + 3 * n, by omega⟩ d h_mr_eq hd_interval⟩
  -- Step 12: GHR93 Claim 1 interior case (right). Mirror of left.
  have h_interior_right : x' ≠ d → d ≠ y' →
      ∀ (a_pad : Fin (1 + 3 * n + 1) → ExtendedCarrier M atomMap r),
        (∀ i, inClosedInterval x y (a_pad i)) →
        a_pad ⟨0, by omega⟩ = c_inf →
        ∃ (a'_full : Fin (1 + 3 * n + 1) → ExtendedCarrier N atomMap r),
          (∀ i, inClosedInterval x' y' (a'_full i)) ∧
          (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
            ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
              ghr93_winning_condition (1 + 3 * n + 1)
                (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) ∧
          a'_full ⟨0, by omega⟩ = d := by
    intro _hx'd _hdy' a_pad ha_pad hc_first
    -- Mirror of h_interior_left with position 0 instead of 1+3n.
    -- Step 1: Play the multi-round rank r+2 game with rank_embed(a_pad).
    have h_mr1 : ghr93_duplicator_wins M N atomMap (1 + 3 * n + 1) (r + 2)
        (rank_embed (by omega : r ≤ r + 2) x) (rank_embed (by omega : r ≤ r + 2) y)
        (rank_embed (by omega : r ≤ r + 2) x') (rank_embed (by omega : r ≤ r + 2) y') :=
      ghr93_duplicator_wins_round_mono (by omega : 1 + 3 * n + 1 ≤ 4 + 3 * n)
        ((rank_embed_le (by omega : r ≤ r + 2) x y).mpr hxy)
        ((rank_embed_le (by omega : r ≤ r + 2) x' y').mpr hx'y') h_fwd_r1
    -- Embed a_pad to rank r+2
    have ha_pad_r2 : ∀ i, inClosedInterval
        (rank_embed (by omega : r ≤ r + 2) x) (rank_embed (by omega : r ≤ r + 2) y)
        (rank_embed (by omega : r ≤ r + 2) (a_pad i)) :=
      fun i => (rank_embed_inClosedInterval (by omega : r ≤ r + 2) x y (a_pad i)).mpr (ha_pad i)
    obtain ⟨a'_mr, ha'_mr_in, hwin_mr⟩ := h_mr1
      (fun i => rank_embed (by omega : r ≤ r + 2) (a_pad i)) ha_pad_r2
    -- Step 2: Define mr_resp = a'_mr at position 0.
    let mr_resp : ExtendedCarrier N atomMap (r + 2) := a'_mr ⟨0, by omega⟩
    -- Step 3: Prove cont_transfer for mr_resp (position 0 version).
    -- For any carrier point p with mr_resp < extendPoint p < y', cont_holds holds.
    -- Uses hwin_mr at game_tuple positions (1, 3+3n, 4+3n) for (c_inf, b, y).
    have h_cont_transfer_mr : ∀ (p : N.carrier),
        mr_resp < (extendPoint p : ExtendedCarrier N atomMap (r + 2)) →
        (extendPoint p : ExtendedCarrier N atomMap r) < y' →
        cont_holds (a_bwd ⟨n, by omega⟩) y' (extendPoint p) := by
      intro p hmr_lt_p hp_lt_y'
      have hp_in_r2 : inClosedInterval
          (rank_embed (by omega : r ≤ r + 2) x')
          (rank_embed (by omega : r ≤ r + 2) y')
          (extendPoint p : ExtendedCarrier N atomMap (r + 2)) := by
        constructor
        · exact le_trans (ha'_mr_in ⟨0, by omega⟩).1 (le_of_lt hmr_lt_p)
        · rw [← rank_embed_point (by omega : r ≤ r + 2) p]
          exact le_of_lt ((rank_embed_lt (by omega : r ≤ r + 2)
            (extendPoint p) y').mpr hp_lt_y')
      obtain ⟨b_u, hb_u_in, hcond_u⟩ := hwin_mr p hp_in_r2
      obtain ⟨hord_u, _hgp_u, hform_u⟩ := hcond_u
      -- Game tuple helpers for position 0 (game index 1).
      -- Index 1: M-side = rank_embed(a_pad(0)) = rank_embed(c_inf)
      have ha_pad_c : game_tuple (rank_embed (by omega : r ≤ r + 2) x)
            (rank_embed (by omega : r ≤ r + 2) y)
            (fun i => rank_embed (by omega : r ≤ r + 2) (a_pad i)) b_u
            ⟨1, by omega⟩ = rank_embed (by omega : r ≤ r + 2) c_inf := by
        simp only [game_tuple,
          show (1 : Nat) ≠ 0 from by omega,
          show ¬((1 : Nat) = (1 + 3 * n + 1) + 1) from by omega,
          show ¬((1 : Nat) = (1 + 3 * n + 1) + 2) from by omega,
          dite_false,
          show 1 - 1 = 0 from by omega,
          hc_first]
      -- Index 1: N-side = a'_mr(0) = mr_resp
      have hgt_N_c : game_tuple (rank_embed (by omega : r ≤ r + 2) x')
            (rank_embed (by omega : r ≤ r + 2) y') a'_mr p
            ⟨1, by omega⟩ = a'_mr ⟨0, by omega⟩ := by
        simp only [game_tuple,
          show (1 : Nat) ≠ 0 from by omega,
          show ¬((1 : Nat) = (1 + 3 * n + 1) + 1) from by omega,
          show ¬((1 : Nat) = (1 + 3 * n + 1) + 2) from by omega,
          dite_false,
          show 1 - 1 = 0 from by omega]
      -- Index 3+3n = n_sel+1: b slot → extendPoint b_u
      have hgt_M_b : game_tuple (rank_embed (by omega : r ≤ r + 2) x)
            (rank_embed (by omega : r ≤ r + 2) y)
            (fun i => rank_embed (by omega : r ≤ r + 2) (a_pad i)) b_u
            ⟨3 + 3 * n, by omega⟩ = extendPoint b_u := by
        simp only [game_tuple,
          show (3 + 3 * n : Nat) = (1 + 3 * n + 1) + 1 from by omega,
          show (1 + 3 * n + 1 + 1 : Nat) ≠ 0 from by omega,
          dite_true, dite_false]
      -- Index 3+3n = n_sel+1 on N side: b slot → extendPoint p
      have hgt_N_b : game_tuple (rank_embed (by omega : r ≤ r + 2) x')
            (rank_embed (by omega : r ≤ r + 2) y') a'_mr p
            ⟨3 + 3 * n, by omega⟩ = extendPoint p := by
        simp only [game_tuple,
          show (3 + 3 * n : Nat) = (1 + 3 * n + 1) + 1 from by omega,
          show (1 + 3 * n + 1 + 1 : Nat) ≠ 0 from by omega,
          dite_true, dite_false]
      -- Index 4+3n = n_sel+2: y slot → rank_embed(y)
      have hgt_M_y : game_tuple (rank_embed (by omega : r ≤ r + 2) x)
            (rank_embed (by omega : r ≤ r + 2) y)
            (fun i => rank_embed (by omega : r ≤ r + 2) (a_pad i)) b_u
            ⟨4 + 3 * n, by omega⟩ = rank_embed (by omega : r ≤ r + 2) y := by
        simp only [game_tuple,
          show (4 + 3 * n : Nat) = (1 + 3 * n + 1) + 2 from by omega,
          show ¬((1 + 3 * n + 1 + 2 : Nat) = (1 + 3 * n + 1) + 1) from by omega,
          show (1 + 3 * n + 1 + 2 : Nat) ≠ 0 from by omega,
          dite_true, dite_false]
      -- Index 4+3n = n_sel+2 on N side: y slot → rank_embed(y')
      have hgt_N_y : game_tuple (rank_embed (by omega : r ≤ r + 2) x')
            (rank_embed (by omega : r ≤ r + 2) y') a'_mr p
            ⟨4 + 3 * n, by omega⟩ = rank_embed (by omega : r ≤ r + 2) y' := by
        simp only [game_tuple,
          show (4 + 3 * n : Nat) = (1 + 3 * n + 1) + 2 from by omega,
          show ¬((1 + 3 * n + 1 + 2 : Nat) = (1 + 3 * n + 1) + 1) from by omega,
          show (1 + 3 * n + 1 + 2 : Nat) ≠ 0 from by omega,
          dite_true, dite_false]
      -- Extract order at index (1, 3+3n): c_inf vs b_u
      have hord_c_b := hord_u ⟨1, by omega⟩ ⟨3 + 3 * n, by omega⟩
      rw [ha_pad_c, hgt_M_b, hgt_N_c, hgt_N_b] at hord_c_b
      -- c_inf < extendPoint b_u at rank r
      have hc_lt_bu_r : c_inf < (extendPoint b_u : ExtendedCarrier M atomMap r) := by
        have : rank_embed (by omega : r ≤ r + 2) c_inf <
            (extendPoint b_u : ExtendedCarrier M atomMap (r + 2)) := by
          rw [← rank_embed_point (by omega : r ≤ r + 2) p] at hmr_lt_p
          exact hord_c_b.1.mpr hmr_lt_p
        rw [← rank_embed_point (by omega : r ≤ r + 2) b_u] at this
        exact (rank_embed_lt (by omega : r ≤ r + 2) c_inf (extendPoint b_u)).mp this
      -- Extract order at index (3+3n, 4+3n): extendPoint(b_u) vs rank_embed(y)
      have hord_b_y := hord_u ⟨3 + 3 * n, by omega⟩ ⟨4 + 3 * n, by omega⟩
      rw [hgt_M_b, hgt_M_y, hgt_N_b, hgt_N_y] at hord_b_y
      -- extendPoint(b_u) < y at rank r
      have hbu_lt_y : (extendPoint b_u : ExtendedCarrier M atomMap r) < y := by
        have hp_lt_y'_r2 : (extendPoint p : ExtendedCarrier N atomMap (r + 2)) <
            rank_embed (by omega : r ≤ r + 2) y' := by
          rw [← rank_embed_point (by omega : r ≤ r + 2) p]
          exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint p) y').mpr hp_lt_y'
        have : (extendPoint b_u : ExtendedCarrier M atomMap (r + 2)) <
            rank_embed (by omega : r ≤ r + 2) y := hord_b_y.1.mpr hp_lt_y'_r2
        rw [← rank_embed_point (by omega : r ≤ r + 2) b_u] at this
        exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint b_u) y).mp this
      -- c_inf ∈ S_C_M: cont_holds_cross at extendPoint b_u
      have hmu_bu : mu_holds (extendPoint (sig := sig) (atomMap := atomMap) (r := r) b_u) :=
        ⟨b_u, rfl⟩
      have h_cont_cross_bu : cont_holds_cross (a_bwd ⟨n, by omega⟩) y' (extendPoint b_u) :=
        hc_inf_in_SC_M.2 (extendPoint b_u) hc_lt_bu_r hbu_lt_y hmu_bu
      -- Transfer: A holds at b_u in M → A holds at p in N (via formula agreement)
      intro A hA h_all_mu
      have hA_bu : stavi_temporal_truth_mu M atomMap r (extendPoint b_u) A :=
        h_cont_cross_bu A hA h_all_mu
      -- Formula agreement at index 3+3n (b_u/p slot), depth ≤ r+2
      have hform_3n := hform_u ⟨3 + 3 * n, by omega⟩ A (le_trans hA (by omega : r ≤ r + 2))
      rw [hgt_M_b, hgt_N_b] at hform_3n
      -- Bridge from rank r to rank r+2 via rank_embed_stavi_truth_mu.
      have hM_bridge : stavi_temporal_truth_mu M atomMap (r + 2)
          (extendPoint b_u : ExtendedCarrier M atomMap (r + 2)) A ↔
          stavi_temporal_truth_mu M atomMap r (extendPoint b_u : ExtendedCarrier M atomMap r) A := by
        conv_lhs => rw [show (extendPoint b_u : ExtendedCarrier M atomMap (r + 2)) =
          rank_embed (by omega : r ≤ r + 2) (extendPoint b_u : ExtendedCarrier M atomMap r) from
          (rank_embed_point (by omega : r ≤ r + 2) b_u).symm]
        exact rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) (extendPoint b_u) A
      have hN_bridge : stavi_temporal_truth_mu N atomMap (r + 2)
          (extendPoint p : ExtendedCarrier N atomMap (r + 2)) A ↔
          stavi_temporal_truth_mu N atomMap r (extendPoint p : ExtendedCarrier N atomMap r) A := by
        conv_lhs => rw [show (extendPoint p : ExtendedCarrier N atomMap (r + 2)) =
          rank_embed (by omega : r ≤ r + 2) (extendPoint p : ExtendedCarrier N atomMap r) from
          (rank_embed_point (by omega : r ≤ r + 2) p).symm]
        exact rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) (extendPoint p) A
      exact hN_bridge.mp (hform_3n.mp (hM_bridge.mpr hA_bu))
    -- Step 4: Prove mr_resp ≤ rank_embed(d) (Direction 1: K⁻(¬D_M) argument).
    -- Same blocker as h_interior_left Step 4 — requires pigeonhole argument.
    have h_mr_resp_le_d : mr_resp ≤ rank_embed (by omega : r ≤ r + 2) d := by
      -- K⁻(¬D_M) argument for the multi-round game (right interior).
      -- Same proof structure as h_interior_left Step 4.
      -- Game index: c_inf at position 1 (since a_pad(0) = c_inf).
      obtain ⟨b_mr_w, _hb_mr_w, hcond_mr_w⟩ := hwin_mr p_N hp_N_r2
      obtain ⟨_hord_mr_w, _hgp_mr_w, hform_mr_w⟩ := hcond_mr_w
      -- Formula agreement at index 1: rank_embed(c_inf) ↔ mr_resp at rank r+2.
      have hform_mr_cinf : ∀ A : StaviFormula, stavi_depth A ≤ r + 2 →
          (stavi_temporal_truth_mu M atomMap (r + 2) (rank_embed (by omega : r ≤ r + 2) c_inf) A ↔
           stavi_temporal_truth_mu N atomMap (r + 2) mr_resp A) := by
        intro A hA
        have h := hform_mr_w ⟨1, by omega⟩ A hA
        simp only [game_tuple,
          show (1 : Nat) ≠ 0 from by omega,
          show ¬((1 : Nat) = (1 + 3 * n + 1) + 1) from by omega,
          show ¬((1 : Nat) = (1 + 3 * n + 1) + 2) from by omega,
          dite_false,
          show 1 - 1 = 0 from by omega,
          hc_first] at h
        exact h
      -- Step 2: Compose formula agreements to get mr_resp ↔ rank_embed(d) at rank r+2.
      have hform_mr_d : ∀ A : StaviFormula, stavi_depth A ≤ r + 2 →
          (stavi_temporal_truth_mu N atomMap (r + 2) mr_resp A ↔
           stavi_temporal_truth_mu N atomMap (r + 2) (rank_embed (by omega : r ≤ r + 2) d) A) := by
        intro A hA
        exact (hform_mr_cinf A hA).symm.trans (hform_r2_1 A hA)
      -- Step 3: By contradiction.
      by_contra h_not_le
      push_neg at h_not_le
      -- h_not_le : rank_embed d < mr_resp
      -- Step 4: Case split on x = c_inf vs x < c_inf.
      rcases eq_or_lt_of_le hc_inf_interval.1 with hx_eq_c | hx_lt_c
      · -- Case: x = c_inf. Order agreement from multi-round game gives contradiction.
        have hord_0_c := _hord_mr_w ⟨0, by omega⟩ ⟨1, by omega⟩
        simp only [game_tuple,
          show (0 : Nat) = 0 from rfl, dite_true,
          show (1 : Nat) ≠ 0 from by omega,
          show ¬((1 : Nat) = (1 + 3 * n + 1) + 1) from by omega,
          show ¬((1 : Nat) = (1 + 3 * n + 1) + 2) from by omega,
          dite_false,
          show 1 - 1 = 0 from by omega,
          hc_first] at hord_0_c
        have h_x_eq : rank_embed (by omega : r ≤ r + 2) x =
            rank_embed (by omega : r ≤ r + 2) c_inf := by rw [hx_eq_c]
        have h_x'_eq : rank_embed (by omega : r ≤ r + 2) x' = mr_resp :=
          hord_0_c.2.mp h_x_eq
        have hx'_le_d : rank_embed (by omega : r ≤ r + 2) x' ≤
            rank_embed (by omega : r ≤ r + 2) d :=
          (rank_embed_le (by omega : r ≤ r + 2) x' d).mpr hd_interval.1
        exact absurd (h_x'_eq.symm ▸ hx'_le_d) (not_le.mpr h_not_le)
      · -- Case: x < c_inf. K⁻(¬D_M) argument.
        by_cases h_cont_c : cont_holds_cross (a_bwd ⟨n, by omega⟩) y' c_inf
        · -- (A) cont_holds_cross holds at c_inf. K⁻ argument via strict pigeonhole.
          have h_strict_failure :
              ∀ (s : ExtendedCarrier M atomMap r),
                inClosedInterval x y s → s < c_inf →
                ∃ (u : ExtendedCarrier M atomMap r),
                  s < u ∧ u < c_inf ∧ u < y ∧
                  mu_holds u ∧ ¬ cont_holds_cross (a_bwd ⟨n, by omega⟩) y' u := by
            intro s hs hs_lt_c
            obtain ⟨v, hsv, hv_le_c, hvy, hmu_v, h_not_cont_v⟩ :=
              h_cofinal_failure_below_c_inf s hs hs_lt_c
            rcases lt_or_eq_of_le hv_le_c with hv_lt | hv_eq
            · exact ⟨v, hsv, hv_lt, hvy, hmu_v, h_not_cont_v⟩
            · exact absurd h_cont_c (hv_eq ▸ h_not_cont_v)
          have h_strict_bridge :
              ∀ p : M.carrier, p ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') →
                x ≤ (extendPoint p : ExtendedCarrier M atomMap r) →
                (extendPoint p : ExtendedCarrier M atomMap r) < c_inf →
                ∃ (u : M.carrier),
                  p ≤ u ∧
                  u ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') ∧
                  (extendPoint u : ExtendedCarrier M atomMap r) < c_inf ∧
                  ∃ (A : StaviFormula),
                    stavi_depth A ≤ r ∧
                    (∀ v : ExtendedCarrier N atomMap r,
                      a_bwd ⟨n, by omega⟩ < v → v < y' → mu_holds v →
                      stavi_temporal_truth_mu N atomMap r v A) ∧
                    ¬ stavi_temporal_truth M atomMap u A := by
            intro p hp_cut hxp hp_lt_c
            have hp_interval : inClosedInterval x y (extendPoint p : ExtendedCarrier M atomMap r) :=
              ⟨hxp, le_trans (le_of_lt hp_lt_c) hc_inf_interval.2⟩
            obtain ⟨v, hpv, hv_lt_c, _, hmu_v, h_not_cont_v⟩ :=
              h_strict_failure (extendPoint p) hp_interval hp_lt_c
            obtain ⟨q, hq_eq⟩ := hmu_v
            rw [hq_eq] at hpv hv_lt_c h_not_cont_v
            have hq_cut : q ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
              intro s hs; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb s hs)
            have hp_le_q : p ≤ q := (extendPoint_le_iff p q).mp (le_of_lt hpv)
            simp only [cont_holds_cross] at h_not_cont_v
            push_neg at h_not_cont_v
            obtain ⟨B, hB_depth, hB_interval, hB_fail⟩ := h_not_cont_v
            have hB_fail_carrier : ¬ stavi_temporal_truth M atomMap q B :=
              fun h => hB_fail ((stavi_truth_mu_at_point q B).mpr h)
            exact ⟨q, hp_le_q, hq_cut, hv_lt_c, B, hB_depth, hB_interval, hB_fail_carrier⟩
          obtain ⟨u₀, hx_lt_u₀, hu₀_lt_c, _, hmu_u₀, _⟩ :=
            h_strict_failure x ⟨le_refl x, hxy⟩ hx_lt_c
          obtain ⟨q₀, hq₀⟩ := hmu_u₀
          rw [hq₀] at hx_lt_u₀ hu₀_lt_c
          have hq₀_cut : q₀ ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
            intro s hs; exact le_trans (le_of_lt hu₀_lt_c) (hc_inf_glb s hs)
          obtain ⟨D_M, hD_depth, hD_interval, hD_cofinal⟩ :=
            pigeonhole_definable_formula_cross_strict hxy
              ⟨q₀, hq₀_cut, le_of_lt hx_lt_u₀, hu₀_lt_c⟩ h_strict_bridge
          let K_minus := StaviFormula.neg (StaviFormula.std_snce (StaviFormula.neg (.base .bot)) D_M)
          have hK_depth : stavi_depth K_minus ≤ r + 2 := by
            simp only [K_minus, stavi_depth, operator_depth]; omega
          have h_since_false_c : ¬ stavi_temporal_truth_mu M atomMap r c_inf
              (StaviFormula.std_snce (StaviFormula.neg (.base .bot)) D_M) := by
            simp only [stavi_temporal_truth_mu]
            push_neg
            intro s hs_lt_c _hmu_s _h_neg_bot
            rcases le_or_lt x s with hxs | hsx
            · have hs_interval : inClosedInterval x y s :=
                ⟨hxs, le_trans (le_of_lt hs_lt_c) hc_inf_interval.2⟩
              obtain ⟨v, hsv, hv_lt_c, _, hmu_v, _⟩ :=
                h_strict_failure s hs_interval hs_lt_c
              obtain ⟨q', hq'_eq⟩ := hmu_v
              rw [hq'_eq] at hsv hv_lt_c
              have hq'_cut : q' ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
                intro t ht; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb t ht)
              obtain ⟨u, hq'_le_u, _, hu_lt_c, hD_fail⟩ :=
                hD_cofinal q' hq'_cut (le_trans hxs (le_of_lt hsv)) hv_lt_c
              refine ⟨extendPoint u, hsv.trans_le ((extendPoint_le_iff q' u).mpr hq'_le_u),
                      hu_lt_c, ⟨u, rfl⟩, ?_⟩
              exact fun h => hD_fail ((stavi_truth_mu_at_point u D_M).mp h)
            · obtain ⟨v, hxv, hv_lt_c, _, hmu_v, _⟩ :=
                h_strict_failure x ⟨le_refl x, hxy⟩ hx_lt_c
              obtain ⟨q', hq'_eq⟩ := hmu_v
              rw [hq'_eq] at hxv hv_lt_c
              have hq'_cut : q' ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
                intro t ht; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb t ht)
              obtain ⟨u, hq'_le_u, _, hu_lt_c, hD_fail⟩ :=
                hD_cofinal q' hq'_cut (le_of_lt hxv) hv_lt_c
              refine ⟨extendPoint u, lt_trans hsx (hxv.trans_le ((extendPoint_le_iff q' u).mpr hq'_le_u)),
                      hu_lt_c, ⟨u, rfl⟩, ?_⟩
              exact fun h => hD_fail ((stavi_truth_mu_at_point u D_M).mp h)
          have hK_true_mr : stavi_temporal_truth_mu N atomMap (r + 2) mr_resp K_minus :=
            (hform_mr_cinf K_minus hK_depth).mp
              ((rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) c_inf K_minus).mpr h_since_false_c)
          simp only [K_minus, stavi_temporal_truth_mu] at hK_true_mr
          apply hK_true_mr
          rcases isPoint_or_isGap d with ⟨p_d, hp_d⟩ | ⟨g_d, hg_d⟩
          · refine ⟨rank_embed (by omega : r ≤ r + 2) d, h_not_le, ?_, ?_, ?_⟩
            · exact (rank_embed_mu_holds (by omega : r ≤ r + 2) d).mpr ⟨p_d, hp_d⟩
            · simp [temporal_truth_mu]
            · intro u hu_gt hu_lt hmu_u
              obtain ⟨q, hq⟩ := hmu_u
              rw [hq] at hu_gt hu_lt ⊢
              have hq_eq : (Sum.inl q : ExtendedCarrier N atomMap (r + 2)) =
                  rank_embed (by omega : r ≤ r + 2)
                    (extendPoint q : ExtendedCarrier N atomMap r) :=
                (rank_embed_point (by omega : r ≤ r + 2) q).symm
              rw [hq_eq, rank_embed_stavi_truth_mu]
              have hd_lt_q : d < (extendPoint q : ExtendedCarrier N atomMap r) := by
                rw [hq_eq] at hu_gt
                exact (rank_embed_lt (by omega : r ≤ r + 2) d (extendPoint q)).mp hu_gt
              have hq_lt_y' : (extendPoint q : ExtendedCarrier N atomMap r) < y' := by
                have hmr_le_y' : mr_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
                  (ha'_mr_in ⟨0, by omega⟩).2
                have : rank_embed (by omega : r ≤ r + 2) (extendPoint q : ExtendedCarrier N atomMap r) <
                    rank_embed (by omega : r ≤ r + 2) y' := by
                  rw [rank_embed_point]; exact lt_of_lt_of_le hu_lt hmr_le_y'
                exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q) y').mp this
              exact hd_in_SC.2 (extendPoint q) hd_lt_q hq_lt_y' (mu_holds_point q) D_M hD_depth hD_interval
          · rcases isPoint_or_isGap mr_resp with ⟨q_mr, hq_mr⟩ | ⟨g_mr, hg_mr⟩
            · have hq_mr_not_cut : q_mr ∉ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut := by
                rw [rank_embed_gap_cut]
                intro h_in
                have : (extendPoint q_mr : ExtendedCarrier N atomMap (r + 2)) ≤
                    rank_embed (by omega : r ≤ r + 2) d := by
                  rw [hg_d]; exact h_in
                rw [hq_mr] at h_not_le
                exact absurd this (not_le.mpr h_not_le)
              have : ¬ (∀ q, q ∉ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut → q_mr ≤ q) :=
                fun h => (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.complement_no_min
                  ⟨q_mr, hq_mr_not_cut, h⟩
              push_neg at this
              obtain ⟨q', hq'_not_cut, hq'_lt⟩ := this
              have hq'_gt_d : rank_embed (by omega : r ≤ r + 2) d <
                  (extendPoint q' : ExtendedCarrier N atomMap (r + 2)) := by
                rw [show rank_embed (by omega : r ≤ r + 2) d =
                  (Sum.inr (rank_embed_gap (by omega : r ≤ r + 2) g_d) :
                    ExtendedCarrier N atomMap (r + 2)) from by rw [hg_d]; rfl]
                exact ⟨hq'_not_cut, fun h => absurd h hq'_not_cut⟩
              have hq'_lt_mr : (extendPoint q' : ExtendedCarrier N atomMap (r + 2)) < mr_resp := by
                rw [show mr_resp = (Sum.inl q_mr : ExtendedCarrier N atomMap (r + 2)) from hq_mr]
                exact (extendPoint_lt_iff q' q_mr).mpr hq'_lt
              have hd_lt_q'_r : d < (extendPoint q' : ExtendedCarrier N atomMap r) :=
                (rank_embed_lt (by omega : r ≤ r + 2) d (extendPoint q')).mp
                  (by rw [rank_embed_point]; exact hq'_gt_d)
              have hq'_lt_y'_r : (extendPoint q' : ExtendedCarrier N atomMap r) < y' := by
                have hmr_le_y' : mr_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
                  (ha'_mr_in ⟨0, by omega⟩).2
                have : (extendPoint q' : ExtendedCarrier N atomMap (r + 2)) <
                    rank_embed (by omega : r ≤ r + 2) y' :=
                  lt_of_lt_of_le hq'_lt_mr hmr_le_y'
                rw [← rank_embed_point (by omega : r ≤ r + 2) q'] at this
                exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q') y').mp this
              refine ⟨extendPoint q', hq'_lt_mr, ⟨q', rfl⟩, ?_, ?_⟩
              · simp [temporal_truth_mu]
              · intro u hu_gt hu_lt hmu_u
                obtain ⟨q_u, hq_u⟩ := hmu_u
                rw [hq_u] at hu_gt hu_lt ⊢
                have hq_eq : (Sum.inl q_u : ExtendedCarrier N atomMap (r + 2)) =
                    rank_embed (by omega : r ≤ r + 2)
                      (extendPoint q_u : ExtendedCarrier N atomMap r) :=
                  (rank_embed_point (by omega : r ≤ r + 2) q_u).symm
                rw [hq_eq, rank_embed_stavi_truth_mu]
                have hd_lt_qu : d < (extendPoint q_u : ExtendedCarrier N atomMap r) := by
                  have : (extendPoint q' : ExtendedCarrier N atomMap (r + 2)) <
                      (extendPoint q_u : ExtendedCarrier N atomMap (r + 2)) := hu_gt
                  rw [← rank_embed_point (by omega : r ≤ r + 2) q',
                      ← rank_embed_point (by omega : r ≤ r + 2) q_u] at this
                  exact lt_trans hd_lt_q'_r
                    ((rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q') (extendPoint q_u)).mp this)
                have hqu_lt_y' : (extendPoint q_u : ExtendedCarrier N atomMap r) < y' := by
                  have hmr_le_y' : mr_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
                    (ha'_mr_in ⟨0, by omega⟩).2
                  have : rank_embed (by omega : r ≤ r + 2) (extendPoint q_u : ExtendedCarrier N atomMap r) <
                      rank_embed (by omega : r ≤ r + 2) y' := by
                    rw [rank_embed_point]; exact lt_of_lt_of_le hu_lt hmr_le_y'
                  exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_u) y').mp this
                exact hd_in_SC.2 (extendPoint q_u) hd_lt_qu hqu_lt_y' (mu_holds_point q_u) D_M hD_depth hD_interval
            · rw [hg_d] at h_not_le; rw [hg_mr] at h_not_le
              have h_strict_sub : ∃ q, q ∈ g_mr.val.cut ∧ q ∉ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut := by
                by_contra h_eq; push_neg at h_eq
                exact absurd (le_antisymm (le_of_lt h_not_le) h_eq) (ne_of_lt h_not_le)
              obtain ⟨q_w, hq_w_in, hq_w_not⟩ := h_strict_sub
              have hq_w_lt_mr : (extendPoint q_w : ExtendedCarrier N atomMap (r + 2)) < mr_resp := by
                rw [show mr_resp = (Sum.inr g_mr : ExtendedCarrier N atomMap (r + 2)) from hg_mr]
                exact ⟨hq_w_in, not_not.mpr hq_w_in⟩
              have hq_w_gt_d : rank_embed (by omega : r ≤ r + 2) d <
                  (extendPoint q_w : ExtendedCarrier N atomMap (r + 2)) := by
                rw [show rank_embed (by omega : r ≤ r + 2) d =
                  (Sum.inr (rank_embed_gap (by omega : r ≤ r + 2) g_d) :
                    ExtendedCarrier N atomMap (r + 2)) from by rw [hg_d]; rfl]
                exact ⟨hq_w_not, hq_w_not⟩
              have hd_lt_qw : d < (extendPoint q_w : ExtendedCarrier N atomMap r) :=
                (rank_embed_lt (by omega : r ≤ r + 2) d (extendPoint q_w)).mp
                  (by rw [rank_embed_point]; exact hq_w_gt_d)
              have hqw_lt_y' : (extendPoint q_w : ExtendedCarrier N atomMap r) < y' := by
                have hmr_le_y' : mr_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
                  (ha'_mr_in ⟨0, by omega⟩).2
                have : (extendPoint q_w : ExtendedCarrier N atomMap (r + 2)) <
                    rank_embed (by omega : r ≤ r + 2) y' :=
                  lt_of_lt_of_le hq_w_lt_mr hmr_le_y'
                rw [← rank_embed_point (by omega : r ≤ r + 2) q_w] at this
                exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_w) y').mp this
              refine ⟨extendPoint q_w, hq_w_lt_mr, ⟨q_w, rfl⟩, ?_, ?_⟩
              · simp [temporal_truth_mu]
              · intro u hu_gt hu_lt hmu_u
                obtain ⟨q_u, hq_u⟩ := hmu_u
                rw [hq_u] at hu_gt hu_lt ⊢
                have hq_eq : (Sum.inl q_u : ExtendedCarrier N atomMap (r + 2)) =
                    rank_embed (by omega : r ≤ r + 2)
                      (extendPoint q_u : ExtendedCarrier N atomMap r) :=
                  (rank_embed_point (by omega : r ≤ r + 2) q_u).symm
                rw [hq_eq, rank_embed_stavi_truth_mu]
                have hd_lt_qu : d < (extendPoint q_u : ExtendedCarrier N atomMap r) := by
                  have : (extendPoint q_w : ExtendedCarrier N atomMap (r + 2)) <
                      (extendPoint q_u : ExtendedCarrier N atomMap (r + 2)) := hu_gt
                  rw [← rank_embed_point (by omega : r ≤ r + 2) q_w,
                      ← rank_embed_point (by omega : r ≤ r + 2) q_u] at this
                  exact lt_trans hd_lt_qw
                    ((rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_w) (extendPoint q_u)).mp this)
                have hqu_lt_y' : (extendPoint q_u : ExtendedCarrier N atomMap r) < y' := by
                  have hmr_le_y' : mr_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
                    (ha'_mr_in ⟨0, by omega⟩).2
                  have : rank_embed (by omega : r ≤ r + 2) (extendPoint q_u : ExtendedCarrier N atomMap r) <
                      rank_embed (by omega : r ≤ r + 2) y' := by
                    rw [rank_embed_point]; exact lt_of_lt_of_le hu_lt hmr_le_y'
                  exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_u) y').mp this
                exact hd_in_SC.2 (extendPoint q_u) hd_lt_qu hqu_lt_y' (mu_holds_point q_u) D_M hD_depth hD_interval
        · -- (B) cont_holds_cross FAILS at c_inf. Direct formula argument.
          simp only [cont_holds_cross] at h_cont_c
          push_neg at h_cont_c
          obtain ⟨A_fail, hA_depth, hA_interval, hA_fail_c⟩ := h_cont_c
          have hA_fail_mr : ¬ stavi_temporal_truth_mu N atomMap (r + 2) mr_resp A_fail := by
            intro h
            exact hA_fail_c
              ((rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) c_inf A_fail).mp
                ((hform_mr_cinf A_fail (le_trans hA_depth (by omega : r ≤ r + 2))).mpr h))
          rcases isPoint_or_isGap mr_resp with ⟨q_mr, hq_mr⟩ | ⟨g_mr, _hg_mr⟩
          · -- mr_resp = extendPoint q_mr (carrier point). Restructured with proper scoping.
            have hd_lt_q : d < (extendPoint q_mr : ExtendedCarrier N atomMap r) := by
              have : rank_embed (by omega : r ≤ r + 2) d < mr_resp := h_not_le
              rw [hq_mr] at this
              exact (rank_embed_lt (by omega : r ≤ r + 2) d (extendPoint q_mr)).mp
                (by rw [rank_embed_point]; exact this)
            have hmr_le_y' : mr_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
              (ha'_mr_in ⟨0, by omega⟩).2
            rcases eq_or_lt_of_le hmr_le_y' with h_eq | h_lt
            · -- h_eq: mr_resp = rank_embed y'. K⁻ pigeonhole via c_inf = y.
              exfalso
              have hord_c_y := _hord_mr_w ⟨1, by omega⟩ ⟨4 + 3 * n, by omega⟩
              simp only [game_tuple,
                show (1 : Nat) ≠ 0 from by omega,
                show ¬((1 : Nat) = (1 + 3 * n + 1) + 1) from by omega,
                show ¬((1 : Nat) = (1 + 3 * n + 1) + 2) from by omega,
                dite_false,
                show 1 - 1 = 0 from by omega,
                hc_first,
                show (4 + 3 * n : Nat) = (1 + 3 * n + 1) + 2 from by omega,
                show ¬((1 + 3 * n + 1 + 2 : Nat) = (1 + 3 * n + 1) + 1) from by omega,
                show (1 + 3 * n + 1 + 2 : Nat) ≠ 0 from by omega,
                dite_true] at hord_c_y
              have h_c_eq_y : c_inf = y := by
                apply le_antisymm hc_inf_interval.2
                by_contra h_lt_y; push_neg at h_lt_y
                have : rank_embed (by omega : r ≤ r + 2) c_inf < rank_embed (by omega : r ≤ r + 2) y :=
                  (rank_embed_lt (by omega : r ≤ r + 2) c_inf y).mpr h_lt_y
                exact absurd (h_eq ▸ hord_c_y.1.mp this) (lt_irrefl _)
              have h_strict_failure_s1 :
                  ∀ (s : ExtendedCarrier M atomMap r),
                    inClosedInterval x y s → s < c_inf →
                    ∃ (u : ExtendedCarrier M atomMap r),
                      s < u ∧ u < c_inf ∧ u < y ∧
                      mu_holds u ∧ ¬ cont_holds_cross (a_bwd ⟨n, by omega⟩) y' u := by
                intro s hs hs_lt_c
                obtain ⟨v, hsv, hv_le_c, hvy, hmu_v, h_not_cont_v⟩ :=
                  h_cofinal_failure_below_c_inf s hs hs_lt_c
                exact ⟨v, hsv, h_c_eq_y ▸ hvy, hvy, hmu_v, h_not_cont_v⟩
              have h_strict_bridge_s1 :
                  ∀ p : M.carrier, p ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') →
                    x ≤ (extendPoint p : ExtendedCarrier M atomMap r) →
                    (extendPoint p : ExtendedCarrier M atomMap r) < c_inf →
                    ∃ (u : M.carrier),
                      p ≤ u ∧ u ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') ∧
                      (extendPoint u : ExtendedCarrier M atomMap r) < c_inf ∧
                      ∃ (A : StaviFormula), stavi_depth A ≤ r ∧
                        (∀ v : ExtendedCarrier N atomMap r,
                          a_bwd ⟨n, by omega⟩ < v → v < y' → mu_holds v →
                          stavi_temporal_truth_mu N atomMap r v A) ∧
                        ¬ stavi_temporal_truth M atomMap u A := by
                intro p hp_cut hxp hp_lt_c
                have hp_interval : inClosedInterval x y (extendPoint p : ExtendedCarrier M atomMap r) :=
                  ⟨hxp, le_trans (le_of_lt hp_lt_c) hc_inf_interval.2⟩
                obtain ⟨v, hpv, hv_lt_c, _, hmu_v, h_not_cont_v⟩ :=
                  h_strict_failure_s1 (extendPoint p) hp_interval hp_lt_c
                obtain ⟨q, hq_eq⟩ := hmu_v
                rw [hq_eq] at hpv hv_lt_c h_not_cont_v
                have hq_cut : q ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
                  intro s hs; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb s hs)
                have hp_le_q : p ≤ q := (extendPoint_le_iff p q).mp (le_of_lt hpv)
                simp only [cont_holds_cross] at h_not_cont_v; push_neg at h_not_cont_v
                obtain ⟨B, hB_depth, hB_interval, hB_fail⟩ := h_not_cont_v
                exact ⟨q, hp_le_q, hq_cut, hv_lt_c, B, hB_depth, hB_interval,
                  fun h => hB_fail ((stavi_truth_mu_at_point q B).mpr h)⟩
              obtain ⟨u₀, hx_lt_u₀, hu₀_lt_c, _, hmu_u₀, _⟩ :=
                h_strict_failure_s1 x ⟨le_refl x, hxy⟩ (h_c_eq_y.symm ▸ hx_lt_c)
              obtain ⟨q₀, hq₀⟩ := hmu_u₀
              rw [hq₀] at hx_lt_u₀ hu₀_lt_c
              have hq₀_cut : q₀ ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
                intro s hs; exact le_trans (le_of_lt hu₀_lt_c) (hc_inf_glb s hs)
              obtain ⟨D_M', hD_depth', hD_interval', hD_cofinal'⟩ :=
                pigeonhole_definable_formula_cross_strict hxy
                  ⟨q₀, hq₀_cut, le_of_lt hx_lt_u₀, hu₀_lt_c⟩ h_strict_bridge_s1
              let K_minus' := StaviFormula.neg (StaviFormula.std_snce (StaviFormula.neg (.base .bot)) D_M')
              have hK_depth' : stavi_depth K_minus' ≤ r + 2 := by
                simp only [K_minus', stavi_depth, operator_depth]; omega
              have h_since_false_c' : ¬ stavi_temporal_truth_mu M atomMap r c_inf
                  (StaviFormula.std_snce (StaviFormula.neg (.base .bot)) D_M') := by
                simp only [stavi_temporal_truth_mu]; push_neg
                intro s hs_lt_c _hmu_s _h_neg_bot
                rcases le_or_lt x s with hxs | hsx
                · have hs_interval : inClosedInterval x y s :=
                    ⟨hxs, le_trans (le_of_lt hs_lt_c) hc_inf_interval.2⟩
                  obtain ⟨v, hsv, hv_lt_c, _, hmu_v, _⟩ :=
                    h_strict_failure_s1 s hs_interval hs_lt_c
                  obtain ⟨q', hq'_eq⟩ := hmu_v
                  rw [hq'_eq] at hsv hv_lt_c
                  have hq'_cut : q' ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
                    intro t ht; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb t ht)
                  obtain ⟨u, hq'_le_u, _, hu_lt_c, hD_fail⟩ :=
                    hD_cofinal' q' hq'_cut (le_trans hxs (le_of_lt hsv)) hv_lt_c
                  refine ⟨extendPoint u, hsv.trans_le ((extendPoint_le_iff q' u).mpr hq'_le_u),
                          hu_lt_c, ⟨u, rfl⟩, fun h => hD_fail ((stavi_truth_mu_at_point u D_M').mp h)⟩
                · obtain ⟨v, hxv, hv_lt_c, _, hmu_v, _⟩ :=
                    h_strict_failure_s1 x ⟨le_refl x, hxy⟩ (h_c_eq_y.symm ▸ hx_lt_c)
                  obtain ⟨q', hq'_eq⟩ := hmu_v
                  rw [hq'_eq] at hxv hv_lt_c
                  have hq'_cut : q' ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
                    intro t ht; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb t ht)
                  obtain ⟨u, hq'_le_u, _, hu_lt_c, hD_fail⟩ :=
                    hD_cofinal' q' hq'_cut (le_of_lt hxv) hv_lt_c
                  refine ⟨extendPoint u, lt_trans hsx (hxv.trans_le ((extendPoint_le_iff q' u).mpr hq'_le_u)),
                          hu_lt_c, ⟨u, rfl⟩, fun h => hD_fail ((stavi_truth_mu_at_point u D_M').mp h)⟩
              have hK_true_mr' : stavi_temporal_truth_mu N atomMap (r + 2) mr_resp K_minus' :=
                (hform_mr_cinf K_minus' hK_depth').mp
                  ((rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) c_inf K_minus').mpr h_since_false_c')
              simp only [K_minus', stavi_temporal_truth_mu] at hK_true_mr'
              apply hK_true_mr'
              have hd_lt_y' : d < y' :=
                (rank_embed_lt (by omega : r ≤ r + 2) d y').mp (h_eq ▸ h_not_le)
              rcases isPoint_or_isGap d with ⟨p_d, hp_d⟩ | ⟨g_d_pt, hg_d_pt⟩
              · refine ⟨rank_embed (by omega : r ≤ r + 2) d, h_not_le, ?_, ?_, ?_⟩
                · exact (rank_embed_mu_holds (by omega : r ≤ r + 2) d).mpr ⟨p_d, hp_d⟩
                · simp [temporal_truth_mu]
                · intro u hu_gt hu_lt hmu_u
                  obtain ⟨q_u, hq_u⟩ := hmu_u
                  rw [hq_u] at hu_gt hu_lt ⊢
                  have hq_eq : (Sum.inl q_u : ExtendedCarrier N atomMap (r + 2)) =
                      rank_embed (by omega : r ≤ r + 2) (extendPoint q_u : ExtendedCarrier N atomMap r) :=
                    (rank_embed_point (by omega : r ≤ r + 2) q_u).symm
                  rw [hq_eq, rank_embed_stavi_truth_mu]
                  have hd_lt_qu : d < (extendPoint q_u : ExtendedCarrier N atomMap r) := by
                    rw [hq_eq] at hu_gt
                    exact (rank_embed_lt (by omega : r ≤ r + 2) d (extendPoint q_u)).mp hu_gt
                  have hqu_lt_y' : (extendPoint q_u : ExtendedCarrier N atomMap r) < y' := by
                    have : rank_embed (by omega : r ≤ r + 2) (extendPoint q_u : ExtendedCarrier N atomMap r) <
                        rank_embed (by omega : r ≤ r + 2) y' := by
                      rw [rank_embed_point]; exact lt_of_lt_of_le hu_lt (h_eq ▸ le_refl _)
                    exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_u) y').mp this
                  exact hd_in_SC.2 (extendPoint q_u) hd_lt_qu hqu_lt_y' (mu_holds_point q_u) D_M' hD_depth' hD_interval'
              · -- d is a gap. complement_no_min argument.
                have hq_mr_not_gd : q_mr ∉ (rank_embed_gap (by omega : r ≤ r + 2) g_d_pt).val.cut := by
                  rw [rank_embed_gap_cut]; intro h_in
                  have : (extendPoint q_mr : ExtendedCarrier N atomMap (r + 2)) ≤
                      rank_embed (by omega : r ≤ r + 2) d := by rw [hg_d_pt]; exact h_in
                  rw [hq_mr] at h_not_le; exact absurd this (not_le.mpr h_not_le)
                have : ¬(∀ q, q ∉ (rank_embed_gap (by omega : r ≤ r + 2) g_d_pt).val.cut → q_mr ≤ q) :=
                  fun h => (rank_embed_gap (by omega : r ≤ r + 2) g_d_pt).val.complement_no_min
                    ⟨q_mr, hq_mr_not_gd, h⟩
                push_neg at this
                obtain ⟨q', hq'_not, hq'_lt⟩ := this
                have hq'_gt_d : rank_embed (by omega : r ≤ r + 2) d <
                    (extendPoint q' : ExtendedCarrier N atomMap (r + 2)) := by
                  rw [show rank_embed (by omega : r ≤ r + 2) d =
                    (Sum.inr (rank_embed_gap (by omega : r ≤ r + 2) g_d_pt) :
                      ExtendedCarrier N atomMap (r + 2)) from by rw [hg_d_pt]; rfl]
                  exact ⟨hq'_not, fun h => absurd h hq'_not⟩
                have hd_lt_q' : d < (extendPoint q' : ExtendedCarrier N atomMap r) :=
                  (rank_embed_lt (by omega : r ≤ r + 2) d (extendPoint q')).mp
                    (by rw [rank_embed_point]; exact hq'_gt_d)
                have hq'_lt_mr : (extendPoint q' : ExtendedCarrier N atomMap (r + 2)) < mr_resp := by
                  rw [hq_mr]; exact (extendPoint_lt_iff q' q_mr).mpr hq'_lt
                refine ⟨extendPoint q', hq'_lt_mr, ⟨q', rfl⟩, ?_, ?_⟩
                · simp [temporal_truth_mu]
                · intro u hu_gt hu_lt hmu_u
                  obtain ⟨q_u, hq_u⟩ := hmu_u
                  rw [hq_u] at hu_gt hu_lt ⊢
                  have hq_eq : (Sum.inl q_u : ExtendedCarrier N atomMap (r + 2)) =
                      rank_embed (by omega : r ≤ r + 2) (extendPoint q_u : ExtendedCarrier N atomMap r) :=
                    (rank_embed_point (by omega : r ≤ r + 2) q_u).symm
                  rw [hq_eq, rank_embed_stavi_truth_mu]
                  have hd_lt_qu : d < (extendPoint q_u : ExtendedCarrier N atomMap r) := by
                    have : (extendPoint q' : ExtendedCarrier N atomMap (r + 2)) <
                        (extendPoint q_u : ExtendedCarrier N atomMap (r + 2)) := hu_gt
                    rw [← rank_embed_point (by omega : r ≤ r + 2) q',
                        ← rank_embed_point (by omega : r ≤ r + 2) q_u] at this
                    exact lt_trans hd_lt_q'
                      ((rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q') (extendPoint q_u)).mp this)
                  have hqu_lt_y' : (extendPoint q_u : ExtendedCarrier N atomMap r) < y' := by
                    have hmr_le_y'2 : mr_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
                      (ha'_mr_in ⟨0, by omega⟩).2
                    have : rank_embed (by omega : r ≤ r + 2) (extendPoint q_u : ExtendedCarrier N atomMap r) <
                        rank_embed (by omega : r ≤ r + 2) y' := by
                      rw [rank_embed_point]; exact lt_of_lt_of_le hu_lt hmr_le_y'2
                    exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_u) y').mp this
                  exact hd_in_SC.2 (extendPoint q_u) hd_lt_qu hqu_lt_y' (mu_holds_point q_u) D_M' hD_depth' hD_interval'
            · -- h_lt: mr_resp < rank_embed y'. Direct contradiction via A_fail.
              have hq_lt_y' : (extendPoint q_mr : ExtendedCarrier N atomMap r) < y' := by
                have : rank_embed (by omega : r ≤ r + 2)
                    (extendPoint q_mr : ExtendedCarrier N atomMap r) <
                    rank_embed (by omega : r ≤ r + 2) y' := by
                  rw [rank_embed_point]
                  rw [show mr_resp = (extendPoint q_mr : ExtendedCarrier N atomMap (r + 2)) from hq_mr] at h_lt
                  exact h_lt
                exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_mr) y').mp this
              have hA_holds_q : stavi_temporal_truth_mu N atomMap r
                  (extendPoint q_mr : ExtendedCarrier N atomMap r) A_fail :=
                hd_in_SC.2 (extendPoint q_mr) hd_lt_q hq_lt_y' (mu_holds_point q_mr)
                  A_fail hA_depth hA_interval
              have hN_bridge : stavi_temporal_truth_mu N atomMap (r + 2)
                  (extendPoint q_mr : ExtendedCarrier N atomMap (r + 2)) A_fail ↔
                  stavi_temporal_truth_mu N atomMap r
                    (extendPoint q_mr : ExtendedCarrier N atomMap r) A_fail := by
                conv_lhs => rw [show (extendPoint q_mr : ExtendedCarrier N atomMap (r + 2)) =
                  rank_embed (by omega : r ≤ r + 2)
                    (extendPoint q_mr : ExtendedCarrier N atomMap r) from
                  (rank_embed_point (by omega : r ≤ r + 2) q_mr).symm]
                exact rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) (extendPoint q_mr) A_fail
              exact hA_fail_mr (by rw [hq_mr]; exact hN_bridge.mpr hA_holds_q)
          · -- mr_resp is a gap. gap_point_agreement forces c_inf to be a gap.
            have h_gp_c := _hgp_mr_w ⟨1, by omega⟩
            simp only [game_tuple,
              show (1 : Nat) ≠ 0 from by omega,
              show ¬((1 : Nat) = (1 + 3 * n + 1) + 1) from by omega,
              show ¬((1 : Nat) = (1 + 3 * n + 1) + 2) from by omega,
              dite_false,
              show 1 - 1 = 0 from by omega,
              hc_first] at h_gp_c
            have h_not_pt_mr : ¬IsPoint mr_resp := by
              intro ⟨q, hq⟩; simp [_hg_mr] at hq
            have h_not_pt_rc : ¬IsPoint (rank_embed (by omega : r ≤ r + 2) c_inf) :=
              fun h => h_not_pt_mr (h_gp_c.1.mp h)
            have h_not_pt_c : ¬IsPoint c_inf := by
              rwa [← rank_embed_isPoint (by omega : r ≤ r + 2) c_inf]
            have h_gap_c : IsGap c_inf := (isPoint_or_isGap c_inf).resolve_left h_not_pt_c
            have h_strict_failure_s2 :
                ∀ (s : ExtendedCarrier M atomMap r),
                  inClosedInterval x y s → s < c_inf →
                  ∃ (u : ExtendedCarrier M atomMap r),
                    s < u ∧ u < c_inf ∧ u < y ∧
                    mu_holds u ∧ ¬ cont_holds_cross (a_bwd ⟨n, by omega⟩) y' u := by
              intro s hs hs_lt_c
              obtain ⟨v, hsv, hv_le_c, hvy, hmu_v, h_not_cont_v⟩ :=
                h_cofinal_failure_below_c_inf s hs hs_lt_c
              have hv_ne_c : v ≠ c_inf := by
                obtain ⟨g_c, hg_c⟩ := h_gap_c
                intro heq; obtain ⟨p_v, hp_v⟩ := hmu_v; simp [heq, hg_c] at hp_v
              exact ⟨v, hsv, lt_of_le_of_ne hv_le_c hv_ne_c, hvy, hmu_v, h_not_cont_v⟩
            have h_strict_bridge_s2 :
                ∀ p : M.carrier, p ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') →
                  x ≤ (extendPoint p : ExtendedCarrier M atomMap r) →
                  (extendPoint p : ExtendedCarrier M atomMap r) < c_inf →
                  ∃ (u : M.carrier),
                    p ≤ u ∧ u ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') ∧
                    (extendPoint u : ExtendedCarrier M atomMap r) < c_inf ∧
                    ∃ (A : StaviFormula), stavi_depth A ≤ r ∧
                      (∀ v : ExtendedCarrier N atomMap r,
                        a_bwd ⟨n, by omega⟩ < v → v < y' → mu_holds v →
                        stavi_temporal_truth_mu N atomMap r v A) ∧
                      ¬ stavi_temporal_truth M atomMap u A := by
              intro p hp_cut hxp hp_lt_c
              have hp_interval : inClosedInterval x y (extendPoint p : ExtendedCarrier M atomMap r) :=
                ⟨hxp, le_trans (le_of_lt hp_lt_c) hc_inf_interval.2⟩
              obtain ⟨v, hpv, hv_lt_c, _, hmu_v, h_not_cont_v⟩ :=
                h_strict_failure_s2 (extendPoint p) hp_interval hp_lt_c
              obtain ⟨q, hq_eq⟩ := hmu_v
              rw [hq_eq] at hpv hv_lt_c h_not_cont_v
              have hq_cut : q ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
                intro s hs; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb s hs)
              have hp_le_q : p ≤ q := (extendPoint_le_iff p q).mp (le_of_lt hpv)
              simp only [cont_holds_cross] at h_not_cont_v; push_neg at h_not_cont_v
              obtain ⟨B, hB_depth, hB_interval, hB_fail⟩ := h_not_cont_v
              exact ⟨q, hp_le_q, hq_cut, hv_lt_c, B, hB_depth, hB_interval,
                fun h => hB_fail ((stavi_truth_mu_at_point q B).mpr h)⟩
            obtain ⟨u₀, hx_lt_u₀, hu₀_lt_c, _, hmu_u₀, _⟩ :=
              h_strict_failure_s2 x ⟨le_refl x, hxy⟩ hx_lt_c
            obtain ⟨q₀, hq₀⟩ := hmu_u₀
            rw [hq₀] at hx_lt_u₀ hu₀_lt_c
            have hq₀_cut : q₀ ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
              intro s hs; exact le_trans (le_of_lt hu₀_lt_c) (hc_inf_glb s hs)
            obtain ⟨D_M, hD_depth, hD_interval, hD_cofinal⟩ :=
              pigeonhole_definable_formula_cross_strict hxy
                ⟨q₀, hq₀_cut, le_of_lt hx_lt_u₀, hu₀_lt_c⟩ h_strict_bridge_s2
            let K_minus := StaviFormula.neg (StaviFormula.std_snce (StaviFormula.neg (.base .bot)) D_M)
            have hK_depth : stavi_depth K_minus ≤ r + 2 := by
              simp only [K_minus, stavi_depth, operator_depth]; omega
            have h_since_false_c : ¬ stavi_temporal_truth_mu M atomMap r c_inf
                (StaviFormula.std_snce (StaviFormula.neg (.base .bot)) D_M) := by
              simp only [stavi_temporal_truth_mu]; push_neg
              intro s hs_lt_c _hmu_s _h_neg_bot
              rcases le_or_lt x s with hxs | hsx
              · have hs_interval : inClosedInterval x y s :=
                  ⟨hxs, le_trans (le_of_lt hs_lt_c) hc_inf_interval.2⟩
                obtain ⟨v, hsv, hv_lt_c, _, hmu_v, _⟩ :=
                  h_strict_failure_s2 s hs_interval hs_lt_c
                obtain ⟨q', hq'_eq⟩ := hmu_v
                rw [hq'_eq] at hsv hv_lt_c
                have hq'_cut : q' ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
                  intro t ht; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb t ht)
                obtain ⟨u, hq'_le_u, _, hu_lt_c, hD_fail⟩ :=
                  hD_cofinal q' hq'_cut (le_trans hxs (le_of_lt hsv)) hv_lt_c
                refine ⟨extendPoint u, hsv.trans_le ((extendPoint_le_iff q' u).mpr hq'_le_u),
                        hu_lt_c, ⟨u, rfl⟩, fun h => hD_fail ((stavi_truth_mu_at_point u D_M).mp h)⟩
              · obtain ⟨v, hxv, hv_lt_c, _, hmu_v, _⟩ :=
                  h_strict_failure_s2 x ⟨le_refl x, hxy⟩ hx_lt_c
                obtain ⟨q', hq'_eq⟩ := hmu_v
                rw [hq'_eq] at hxv hv_lt_c
                have hq'_cut : q' ∈ inf_carrier_cut (continuation_set_cross x y (a_bwd ⟨n, by omega⟩) y') := by
                  intro t ht; exact le_trans (le_of_lt hv_lt_c) (hc_inf_glb t ht)
                obtain ⟨u, hq'_le_u, _, hu_lt_c, hD_fail⟩ :=
                  hD_cofinal q' hq'_cut (le_of_lt hxv) hv_lt_c
                refine ⟨extendPoint u, lt_trans hsx (hxv.trans_le ((extendPoint_le_iff q' u).mpr hq'_le_u)),
                        hu_lt_c, ⟨u, rfl⟩, fun h => hD_fail ((stavi_truth_mu_at_point u D_M).mp h)⟩
            have hK_true_mr : stavi_temporal_truth_mu N atomMap (r + 2) mr_resp K_minus :=
              (hform_mr_cinf K_minus hK_depth).mp
                ((rank_embed_stavi_truth_mu (by omega : r ≤ r + 2) c_inf K_minus).mpr h_since_false_c)
            simp only [K_minus, stavi_temporal_truth_mu] at hK_true_mr
            apply hK_true_mr
            rcases isPoint_or_isGap d with ⟨p_d, hp_d⟩ | ⟨g_d, hg_d⟩
            · refine ⟨rank_embed (by omega : r ≤ r + 2) d, h_not_le, ?_, ?_, ?_⟩
              · exact (rank_embed_mu_holds (by omega : r ≤ r + 2) d).mpr ⟨p_d, hp_d⟩
              · simp [temporal_truth_mu]
              · intro u hu_gt hu_lt hmu_u
                obtain ⟨q, hq⟩ := hmu_u; rw [hq] at hu_gt hu_lt ⊢
                have hq_eq : (Sum.inl q : ExtendedCarrier N atomMap (r + 2)) =
                    rank_embed (by omega : r ≤ r + 2) (extendPoint q : ExtendedCarrier N atomMap r) :=
                  (rank_embed_point (by omega : r ≤ r + 2) q).symm
                rw [hq_eq, rank_embed_stavi_truth_mu]
                have hd_lt_q : d < (extendPoint q : ExtendedCarrier N atomMap r) := by
                  rw [hq_eq] at hu_gt
                  exact (rank_embed_lt (by omega : r ≤ r + 2) d (extendPoint q)).mp hu_gt
                have hq_lt_y' : (extendPoint q : ExtendedCarrier N atomMap r) < y' := by
                  have hmr_le_y' : mr_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
                    (ha'_mr_in ⟨0, by omega⟩).2
                  exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q) y').mp
                    (by rw [rank_embed_point]; exact lt_of_lt_of_le hu_lt hmr_le_y')
                exact hd_in_SC.2 (extendPoint q) hd_lt_q hq_lt_y' (mu_holds_point q) D_M hD_depth hD_interval
            · rw [hg_d] at h_not_le; rw [_hg_mr] at h_not_le
              have h_strict_sub' : ∃ q, q ∈ g_mr.val.cut ∧ q ∉ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut := by
                by_contra h_eq; push_neg at h_eq
                exact absurd (le_antisymm (le_of_lt h_not_le) h_eq) (ne_of_lt h_not_le)
              obtain ⟨q_w, hq_w_in, hq_w_not⟩ := h_strict_sub'
              have hq_w_lt_mr : (extendPoint q_w : ExtendedCarrier N atomMap (r + 2)) < mr_resp := by
                rw [show mr_resp = (Sum.inr g_mr : ExtendedCarrier N atomMap (r + 2)) from _hg_mr]
                exact ⟨hq_w_in, not_not.mpr hq_w_in⟩
              have hq_w_gt_d : rank_embed (by omega : r ≤ r + 2) d <
                  (extendPoint q_w : ExtendedCarrier N atomMap (r + 2)) := by
                rw [show rank_embed (by omega : r ≤ r + 2) d =
                  (Sum.inr (rank_embed_gap (by omega : r ≤ r + 2) g_d) :
                    ExtendedCarrier N atomMap (r + 2)) from by rw [hg_d]; rfl]
                exact ⟨hq_w_not, hq_w_not⟩
              have hd_lt_qw : d < (extendPoint q_w : ExtendedCarrier N atomMap r) :=
                (rank_embed_lt (by omega : r ≤ r + 2) d (extendPoint q_w)).mp
                  (by rw [rank_embed_point]; exact hq_w_gt_d)
              have hqw_lt_y' : (extendPoint q_w : ExtendedCarrier N atomMap r) < y' := by
                have hmr_le_y' : mr_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
                  (ha'_mr_in ⟨0, by omega⟩).2
                have : (extendPoint q_w : ExtendedCarrier N atomMap (r + 2)) <
                    rank_embed (by omega : r ≤ r + 2) y' :=
                  lt_of_lt_of_le hq_w_lt_mr hmr_le_y'
                rw [← rank_embed_point (by omega : r ≤ r + 2) q_w] at this
                exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_w) y').mp this
              refine ⟨extendPoint q_w, hq_w_lt_mr, ⟨q_w, rfl⟩, ?_, ?_⟩
              · simp [temporal_truth_mu]
              · intro u hu_gt hu_lt hmu_u
                obtain ⟨q_u, hq_u⟩ := hmu_u; rw [hq_u] at hu_gt hu_lt ⊢
                have hq_eq : (Sum.inl q_u : ExtendedCarrier N atomMap (r + 2)) =
                    rank_embed (by omega : r ≤ r + 2) (extendPoint q_u : ExtendedCarrier N atomMap r) :=
                  (rank_embed_point (by omega : r ≤ r + 2) q_u).symm
                rw [hq_eq, rank_embed_stavi_truth_mu]
                have hd_lt_qu : d < (extendPoint q_u : ExtendedCarrier N atomMap r) := by
                  have : (extendPoint q_w : ExtendedCarrier N atomMap (r + 2)) <
                      (extendPoint q_u : ExtendedCarrier N atomMap (r + 2)) := hu_gt
                  rw [← rank_embed_point (by omega : r ≤ r + 2) q_w,
                      ← rank_embed_point (by omega : r ≤ r + 2) q_u] at this
                  exact lt_trans hd_lt_qw
                    ((rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_w) (extendPoint q_u)).mp this)
                have hqu_lt_y' : (extendPoint q_u : ExtendedCarrier N atomMap r) < y' := by
                  have hmr_le_y' : mr_resp ≤ rank_embed (by omega : r ≤ r + 2) y' :=
                    (ha'_mr_in ⟨0, by omega⟩).2
                  exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint q_u) y').mp
                    (by rw [rank_embed_point]; exact lt_of_lt_of_le hu_lt hmr_le_y')
                exact hd_in_SC.2 (extendPoint q_u) hd_lt_qu hqu_lt_y' (mu_holds_point q_u) D_M hD_depth hD_interval
    -- Step 5: Prove rank_embed(d) ≤ mr_resp (Direction 2: game Round 2 argument).
    have h_mr_resp_ge_d : rank_embed (by omega : r ≤ r + 2) d ≤ mr_resp := by
      by_contra h_not_le
      push_neg at h_not_le
      -- h_not_le : mr_resp < rank_embed d
      rcases isPoint_or_isGap mr_resp with ⟨p_resp, hp_resp⟩ | ⟨g_resp, hg_resp⟩
      · -- mr_resp = extendPoint(p_resp): carrier point case.
        have hp_lt_d : (extendPoint p_resp : ExtendedCarrier N atomMap r) < d := by
          have : mr_resp < rank_embed (by omega : r ≤ r + 2) d := h_not_le
          rw [hp_resp] at this
          exact (rank_embed_lt (by omega : r ≤ r + 2) (extendPoint p_resp) d).mp
            (show rank_embed (by omega : r ≤ r + 2) (extendPoint p_resp : ExtendedCarrier N atomMap r)
              < rank_embed (by omega : r ≤ r + 2) d from by
                simp only [rank_embed_point]; exact this)
        have hp_in : inClosedInterval x' y' (extendPoint p_resp : ExtendedCarrier N atomMap r) := by
          have h_r2 := ha'_mr_in ⟨0, by omega⟩
          rw [show a'_mr ⟨0, by omega⟩ = mr_resp from rfl, hp_resp] at h_r2
          constructor
          · exact (rank_embed_le (by omega : r ≤ r + 2) x' (extendPoint p_resp)).mp
              (show rank_embed (by omega : r ≤ r + 2) x' ≤
                rank_embed (by omega : r ≤ r + 2) (extendPoint p_resp : ExtendedCarrier N atomMap r) from by
                simp only [rank_embed_point]; exact h_r2.1)
          · exact (rank_embed_le (by omega : r ≤ r + 2) (extendPoint p_resp) y').mp
              (show rank_embed (by omega : r ≤ r + 2) (extendPoint p_resp : ExtendedCarrier N atomMap r) ≤
                rank_embed (by omega : r ≤ r + 2) y' from by
                simp only [rank_embed_point]; exact h_r2.2)
        obtain ⟨v, hpv, hv_le_d, hvy', hmu_v, h_not_cont_v⟩ :=
          h_cofinal_failure_below_d (extendPoint p_resp) hp_in hp_lt_d
        obtain ⟨q, hq⟩ := hmu_v
        rw [hq] at hpv hv_le_d hvy' h_not_cont_v
        have hmr_lt_q : mr_resp < (extendPoint q : ExtendedCarrier N atomMap (r + 2)) := by
          rw [hp_resp]
          show (extendPoint p_resp : ExtendedCarrier N atomMap (r + 2)) <
            (extendPoint q : ExtendedCarrier N atomMap (r + 2))
          have h := (rank_embed_lt (by omega : r ≤ r + 2)
            (extendPoint p_resp : ExtendedCarrier N atomMap r)
            (extendPoint q : ExtendedCarrier N atomMap r)).mpr hpv
          simp only [rank_embed_point] at h
          exact h
        exact h_not_cont_v (h_cont_transfer_mr q hmr_lt_q hvy')
      · -- mr_resp is a gap. Mirror of h_r2_resp_ge_d gap case.
        have hx'_lt_d : x' < d := by
          have h1 : rank_embed (by omega : r ≤ r + 2) x' ≤ mr_resp :=
            (ha'_mr_in ⟨0, by omega⟩).1
          exact (rank_embed_lt (by omega : r ≤ r + 2) x' d).mp (lt_of_le_of_lt h1 h_not_le)
        rcases isPoint_or_isGap d with ⟨p_d, hp_d⟩ | ⟨g_d, hg_d⟩
        · -- d = extendPoint p_d (carrier point)
          have hp_d_not_cut : p_d ∉ g_resp.val.cut := by
            intro hp_d_in
            have h_le : (extendPoint p_d : ExtendedCarrier N atomMap (r + 2)) ≤ mr_resp := by
              rw [hg_resp]; exact hp_d_in
            have h_eq : rank_embed (by omega : r ≤ r + 2) d =
                (extendPoint p_d : ExtendedCarrier N atomMap (r + 2)) := by
              rw [hp_d]; exact rank_embed_point (by omega : r ≤ r + 2) p_d
            exact absurd (h_eq ▸ h_not_le) (not_lt.mpr h_le)
          obtain ⟨q, hq_not_cut, hq_lt_pd⟩ :
              ∃ q : N.carrier, q ∉ g_resp.val.cut ∧ q < p_d := by
            by_contra h_all
            push_neg at h_all
            exact g_resp.val.complement_no_min ⟨p_d, hp_d_not_cut, h_all⟩
          have hq_lt_d : (extendPoint q : ExtendedCarrier N atomMap r) < d := by
            rw [hp_d]; exact (extendPoint_lt_iff q p_d).mpr hq_lt_pd
          have hmr_lt_q : mr_resp < (extendPoint q : ExtendedCarrier N atomMap (r + 2)) := by
            rw [hg_resp]; exact lt_of_not_ge (fun h => hq_not_cut h)
          have hx'_lt_q : x' < (extendPoint q : ExtendedCarrier N atomMap r) := by
            have h1 : rank_embed (by omega : r ≤ r + 2) x' ≤ mr_resp :=
              (ha'_mr_in ⟨0, by omega⟩).1
            have h2 : rank_embed (by omega : r ≤ r + 2) x' <
                (extendPoint q : ExtendedCarrier N atomMap (r + 2)) :=
              lt_of_le_of_lt h1 hmr_lt_q
            rw [← rank_embed_point (by omega : r ≤ r + 2) q] at h2
            exact (rank_embed_lt (by omega : r ≤ r + 2) x' (extendPoint q)).mp h2
          have hq_interval : inClosedInterval x' y'
              (extendPoint q : ExtendedCarrier N atomMap r) :=
            ⟨le_of_lt hx'_lt_q, le_trans (le_of_lt hq_lt_d) hd_interval.2⟩
          obtain ⟨u, hqu, _hud, huy', hmu_u, h_not_cont_u⟩ :=
            h_cofinal_failure_below_d (extendPoint q) hq_interval hq_lt_d
          obtain ⟨q_u, hq_u⟩ := hmu_u
          rw [hq_u] at hqu huy' h_not_cont_u
          have hq_lt_qu : q < q_u := (extendPoint_lt_iff q q_u).mp hqu
          have hqu_not_cut : q_u ∉ g_resp.val.cut := by
            intro hqu_in
            exact hq_not_cut (g_resp.val.downward_closed q_u q hqu_in (le_of_lt hq_lt_qu))
          have hmr_lt_qu : mr_resp <
              (extendPoint q_u : ExtendedCarrier N atomMap (r + 2)) := by
            rw [hg_resp]; exact lt_of_not_ge (fun h => hqu_not_cut h)
          exact h_not_cont_u (h_cont_transfer_mr q_u hmr_lt_qu huy')
        · -- d = Sum.inr g_d (gap). Both mr_resp and d are gaps with g_resp.cut ⊊ g_d.cut.
          obtain ⟨q, hq_in_gd, hq_not_gr⟩ : ∃ q, q ∈ g_d.val.cut ∧ q ∉ g_resp.val.cut := by
            by_contra h_all
            push_neg at h_all
            have h_cut_eq : g_resp.val.cut = g_d.val.cut := by
              apply Set.Subset.antisymm
              · intro p hp
                have h1 : (extendPoint p : ExtendedCarrier N atomMap (r + 2)) ≤ mr_resp := by
                  rw [hg_resp]; exact hp
                have h2 : (extendPoint p : ExtendedCarrier N atomMap (r + 2)) ≤
                    rank_embed (by omega : r ≤ r + 2) d := le_trans h1 (le_of_lt h_not_le)
                rw [hg_d, rank_embed_gap_eq] at h2
                rwa [show (extendPoint p : ExtendedCarrier N atomMap (r + 2)) ≤
                    (Sum.inr (rank_embed_gap (by omega : r ≤ r + 2) g_d) :
                    ExtendedCarrier N atomMap (r + 2)) ↔
                    p ∈ (rank_embed_gap (by omega : r ≤ r + 2) g_d).val.cut from Iff.rfl,
                  rank_embed_gap_cut] at h2
              · exact h_all
            have h_gap_eq : g_resp = rank_embed_gap (by omega : r ≤ r + 2) g_d :=
              Subtype.ext (gap_ext g_resp.val (rank_embed_gap (by omega : r ≤ r + 2) g_d).val
                (by rw [rank_embed_gap_cut]; exact h_cut_eq))
            have h_eq : mr_resp = rank_embed (by omega : r ≤ r + 2) d := by
              rw [hg_resp, hg_d, rank_embed_gap_eq]
              exact congrArg Sum.inr h_gap_eq
            exact absurd h_eq (ne_of_lt h_not_le)
          have hq_lt_d : (extendPoint q : ExtendedCarrier N atomMap r) < d := by
            rw [hg_d]
            have h_le : (extendPoint q : ExtendedCarrier N atomMap r) ≤ Sum.inr g_d := hq_in_gd
            have h_ne : (extendPoint q : ExtendedCarrier N atomMap r) ≠ Sum.inr g_d := by
              simp [extendPoint]
            exact lt_of_le_of_ne h_le h_ne
          have hmr_lt_q : mr_resp <
              (extendPoint q : ExtendedCarrier N atomMap (r + 2)) := by
            rw [hg_resp]; exact lt_of_not_ge (fun h => hq_not_gr h)
          have hx'_lt_q : x' < (extendPoint q : ExtendedCarrier N atomMap r) := by
            have h1 : rank_embed (by omega : r ≤ r + 2) x' ≤ mr_resp :=
              (ha'_mr_in ⟨0, by omega⟩).1
            have h2 : rank_embed (by omega : r ≤ r + 2) x' <
                (extendPoint q : ExtendedCarrier N atomMap (r + 2)) :=
              lt_of_le_of_lt h1 hmr_lt_q
            rw [← rank_embed_point (by omega : r ≤ r + 2) q] at h2
            exact (rank_embed_lt (by omega : r ≤ r + 2) x' (extendPoint q)).mp h2
          have hq_interval : inClosedInterval x' y'
              (extendPoint q : ExtendedCarrier N atomMap r) :=
            ⟨le_of_lt hx'_lt_q, le_trans (le_of_lt hq_lt_d) hd_interval.2⟩
          obtain ⟨u, hqu, _hud, huy', hmu_u, h_not_cont_u⟩ :=
            h_cofinal_failure_below_d (extendPoint q) hq_interval hq_lt_d
          obtain ⟨q_u, hq_u⟩ := hmu_u
          rw [hq_u] at hqu huy' h_not_cont_u
          have hq_lt_qu : q < q_u := (extendPoint_lt_iff q q_u).mp hqu
          have hqu_not_cut : q_u ∉ g_resp.val.cut := by
            intro hqu_in
            exact hq_not_gr (g_resp.val.downward_closed q_u q hqu_in (le_of_lt hq_lt_qu))
          have hmr_lt_qu : mr_resp <
              (extendPoint q_u : ExtendedCarrier N atomMap (r + 2)) := by
            rw [hg_resp]; exact lt_of_not_ge (fun h => hqu_not_cut h)
          exact h_not_cont_u (h_cont_transfer_mr q_u hmr_lt_qu huy')
    -- Step 6: Derive equality.
    have h_mr_eq : mr_resp = rank_embed (by omega : r ≤ r + 2) d :=
      le_antisymm h_mr_resp_le_d h_mr_resp_ge_d
    -- Step 7: Use rank_down with position tracking.
    obtain ⟨a'_rd, ha'_rd, hwin_rd, hpos_rd⟩ := ghr93_rank_down_proj
      (by omega : r ≤ r + 2) (by omega : r + 2 ≤ r + 2) hxy hx'y'
      a_pad ha_pad a'_mr ha'_mr_in hwin_mr ⟨p_N, hp_N⟩
    exact ⟨a'_rd, ha'_rd, hwin_rd,
      hpos_rd ⟨0, by omega⟩ d h_mr_eq hd_interval⟩
  -- Step 13: Provide the suffices witness directly from the rank-(r+2) game.
  -- This bypasses t_game entirely — no rank mismatch.
  refine ⟨c_inf, hc_inf_interval, hform_cd, hgp_cd, hbdy_cd, h_interior_left, h_interior_right⟩


end Bimodal.Metalogic.WeakCanonical
