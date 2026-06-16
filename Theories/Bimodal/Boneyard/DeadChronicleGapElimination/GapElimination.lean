-- Archived from Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean
-- Task 301: Dead code archival. These declarations are NOT on any live call path
-- to completeness_discrete. The sorry chain chronicle_gap_contradiction -> succ_cofinal
-- -> limitDomSubtype_isSuccArchimedean is dead because completeness_discrete uses
-- the Reynolds pipeline (countermodel_discrete_reynolds_v2) instead.
--
-- This file does NOT compile standalone — it requires imports and context from
-- the original ChronicleToCountermodel.lean. Preserved for historical reference only.

-- Original imports were:
-- import Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodelBasic
-- import Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery

/-! ## Gap Elimination and IsSuccArchimedean — DEAD CODE (task 301)

The following declarations are dead code. They are NOT on any live call path to
`completeness_discrete` (which uses the Reynolds pipeline via
`countermodel_discrete_reynolds_v2`). They remain in this file because
`succ_embed_surjective` is still called internally by `cantor_bfmcs_discrete_restricted_tc/fuc`,
which are used by `countermodel_discrete_enriched` in Completeness.lean and Transfer.lean.

Dead declarations (sorry-laden):
- `succ_reaches_dom_N` — dead BX pipeline stage induction
- `chronicle_gap_contradiction` — dead gap elimination (sorry)
- `succ_cofinal` — dead cofinality from gap elimination
- `limitDomSubtype_isSuccArchimedean` — dead IsSuccArchimedean from cofinality

The sorry chain: `chronicle_gap_contradiction` → `succ_cofinal` →
`limitDomSubtype_isSuccArchimedean` → `succ_embed_surjective` →
`cantor_bfmcs_discrete_restricted_tc/fuc`. This chain is dead because
`completeness_discrete` no longer uses `cantor_bfmcs_discrete` — it uses
the Reynolds pipeline instead.

`mcs_mixed_case_absurd` and `dd_countermodel_chronicle_mixed_sorry` moved to
MCSMixedCase.lean (task 301 phase 1).
-/

/--
Stage induction: for any N and any a, b in dom(N) with a ≤ b, there exists k
such that `succ^[k](a) = b` in the full limit_dom ordering.
-/
private theorem succ_reaches_dom_N (fc : FrameClass) (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ limit_dom fc A h_mcs, next_top ∈ limit_f fc A h_mcs x)
    (N : ℕ) (a b : LimitDomSubtype fc A h_mcs)
    (ha : a.val ∈ (omega_chain_val fc A h_mcs N).dom)
    (hb : b.val ∈ (omega_chain_val fc A h_mcs N).dom)
    (hab : a ≤ b) :
    ∃ k, (limitDomSubtype_succ fc A h_mcs h_discrete)^[k] a = b := by
  induction N generalizing a b with
  | zero =>
    -- dom(0) = {0}, so a.val = 0 and b.val = 0, hence a = b
    simp only [omega_chain_val, omega_chain, singleton_chronicle, singleton_dom,
      Finset.mem_singleton] at ha hb
    have : a = b := Subtype.ext (by rw [ha, hb])
    exact ⟨0, this⟩
  | succ N ih =>
    -- Case split: are a, b in dom(N) or is one the new point?
    by_cases ha_old : a.val ∈ (omega_chain_val fc A h_mcs N).dom
    · by_cases hb_old : b.val ∈ (omega_chain_val fc A h_mcs N).dom
      · -- Case 1: both in dom(N). Apply IH.
        exact ih a b ha_old hb_old hab
      · -- Case 3: a ∈ dom(N), b = new point at stage N+1.
        -- b is between dom(N) points w ≤ w_next, or beyond max/below min.
        -- Since a ≤ b and a ∈ dom(N), we need b ≥ a.
        -- b ∉ dom(N), but b ∈ dom(N+1). b is the unique new point.
        -- Find the adjacent dom(N) pair (w, w_next) that brackets b.
        -- If b > max(dom(N)): IH gives succ^[k](a) = max(dom(N)).
        --   Then we need succ reaches from max to b. This is the hard boundary case.
        -- If b < min(dom(N)): impossible since a ∈ dom(N) and a ≤ b.
        -- If b is between w and w_next (adjacent in dom(N)):
        --   IH gives succ^[k](a) = w_next. Since a ≤ b < w_next,
        --   orbit convexity gives j with succ^[j](a) = b.
        -- Use omega_chain_dom_mono to get a in dom(N+1)
        have ha_new : a.val ∈ (omega_chain_val fc A h_mcs (N + 1)).dom :=
          omega_chain_dom_mono fc A h_mcs N ha_old
        -- We know b ∈ dom(N+1) \ dom(N). Check if b is between two dom(N) points.
        have h_dom_ne : (omega_chain_val fc A h_mcs N).dom.Nonempty :=
          ⟨a.val, ha_old⟩
        -- b.val is in dom(N+1) but not in dom(N).
        -- Check: is b.val > max(dom(N))?
        set max_N := (omega_chain_val fc A h_mcs N).dom.max' h_dom_ne with max_N_def
        by_cases hb_above_max : max_N < b.val
        · -- Boundary case: b above max(dom(N)).
          -- IH gives succ^[k](a) = ⟨max_N, ...⟩.
          have h_max_mem : max_N ∈ (omega_chain_val fc A h_mcs N).dom :=
            Finset.max'_mem _ h_dom_ne
          have h_max_limit : max_N ∈ limit_dom fc A h_mcs := ⟨N, h_max_mem⟩
          have h_a_le_max : a ≤ ⟨max_N, h_max_limit⟩ := by
            show a.val ≤ max_N
            exact Finset.le_max' _ a.val ha_old
          obtain ⟨k₁, hk₁⟩ := ih a ⟨max_N, h_max_limit⟩ ha_old h_max_mem h_a_le_max
          -- Now need: ∃ k₂, succ^[k₂](⟨max_N,...⟩) = b.
          -- succ(⟨max_N,...⟩) is the next limit_dom point after max_N.
          -- By succ_le_iff, since max_N < b.val, succ(max_N_sub) ≤ b.
          -- If succ(max_N_sub) = b: done with k₁ + 1.
          -- If succ(max_N_sub) < b: succ(max_N_sub) is a limit_dom point
          --   in (max_N, b.val). It's in dom(M) for some M.
          --   It's NOT in dom(N) (since max_N is the maximum).
          --   By dom_new_unique, it must be b (since b is the unique new
          --   dom(N+1)\dom(N) point, and succ(max_N_sub) ∈ limit_dom means
          --   it's in some dom(M)... but we can't assume it's in dom(N+1)).
          -- Actually, we know succ(max_N_sub) ≤ b. And a ≤ b with a ≤ max_N_sub.
          -- We have succ^[k₁](a) = max_N_sub. Need succ^[k₁ + k₂](a) = b for some k₂.
          -- It suffices to show b ≤ succ^[k₂](max_N_sub) for some k₂, then use orbit convexity.
          -- Actually, let's use succ_orbit_convex directly:
          -- We need ∃ m, b ≤ succ^[m](a). Then orbit convexity gives j with succ^[j](a) = b.
          -- succ^[k₁](a) = max_N_sub. succ^[k₁+1](a) = succ(max_N_sub).
          -- succ(max_N_sub) ≤ b ↔ max_N_sub < b ↔ max_N < b.val. ✓
          -- Need: is b ≤ succ(max_N_sub)?
          -- succ(max_N_sub) is some limit_dom point > max_N.
          -- b is also > max_N and b ∈ limit_dom.
          -- Is succ(max_N_sub) ≤ b or > b?
          -- succ(max_N_sub) ≤ b OR b < succ(max_N_sub).
          -- If b < succ(max_N_sub): b is a limit_dom point between max_N and succ(max_N_sub).
          --   But limit_dom_has_succ says no limit_dom between max_N and succ(max_N).
          --   So b can't be between them. Contradiction.
          -- Therefore succ(max_N_sub) ≤ b. But also succ(max_N_sub) ≥ b (by... not necessarily).
          -- Actually: succ(max_N_sub) > max_N. And b > max_N. No limit_dom between max_N
          --   and succ(max_N_sub). b ∈ limit_dom with b > max_N. So b ≥ succ(max_N_sub).
          -- And succ(max_N_sub) ≤ b (from succ_le_iff: max_N < b means succ ≤ b).
          -- These give succ(max_N_sub) ≤ b and b ≥ succ(max_N_sub). Both say the same thing!
          -- But we also need b ≤ succ(max_N_sub) to use orbit convexity.
          -- Hmm, we only know succ(max_N_sub) ≤ b. To get b ≤ succ(max_N_sub) (equality):
          -- succ(max_N_sub) is the nearest limit_dom > max_N. b is limit_dom > max_N.
          -- So succ(max_N_sub) ≤ b. If succ(max_N_sub) < b: then succ(max_N_sub) is between
          --   max_N and b. succ(max_N_sub) ∈ limit_dom, succ(max_N_sub) ∉ dom(N) (since > max_N).
          --   succ(max_N_sub) ∈ dom(M) for some M. If M ≤ N+1: succ(max_N_sub) ∈ dom(N+1).
          --   Since succ(max_N_sub) ∉ dom(N) and b ∉ dom(N), and both ∈ dom(N+1)\dom(N):
          --   omega_chain_dom_new_unique gives succ(max_N_sub) = b. Contradicts < b.
          --   If M > N+1: succ(max_N_sub) ∉ dom(N+1). But we don't know this.
          -- We need a different argument. Let's try: b is in dom(N+1), and succ(max_N_sub)
          --   is the nearest limit_dom point after max_N. If b ∈ dom(N+1) with b > max_N,
          --   and max_N ∈ dom(N+1), then succ(max_N_sub) ≤ b (by succ_le_iff). And if
          --   succ(max_N_sub) = b: done. If succ(max_N_sub) < b: then between max_N and b
          --   in limit_dom there is succ(max_N_sub). No limit_dom between max_N and
          --   succ(max_N_sub). But succ(max_N_sub) < b ∈ limit_dom. So limit_dom has a point
          --   succ(max_N_sub) ∈ (max_N, b). This point is > max_N so ∉ dom(N).
          --   It's in limit_dom, so ∈ dom(M) for some M.
          --   We can't directly conclude succ(max_N_sub) ∈ dom(N+1).
          -- Let me try orbit convexity differently.
          -- succ^[k₁+1](a) = succ(max_N_sub) ≤ b.
          -- If succ(max_N_sub) = b: ⟨k₁+1, rfl⟩ works.
          -- If succ(max_N_sub) < b: apply orbit convexity is wrong direction.
          -- We need succ^[m](a) ≥ b for orbit convexity.
          -- This approach doesn't directly give us b ≤ succ^[m](a).
          -- Let me use the direct argument with limit_dom_has_succ.
          -- succ(max_N_sub) is the next limit_dom after max_N. No limit_dom between.
          -- b > max_N and b ∈ limit_dom. So b ≥ succ(max_N_sub).
          -- But succ(max_N_sub) ≤ b. If strict: contradiction with "no limit_dom between
          --   max_N and succ(max_N_sub)"? No, b is not between max_N and succ(max_N_sub)
          --   if b ≥ succ(max_N_sub).
          -- Hmm. We just know succ(max_N_sub) ≤ b. We need ≥ too.
          -- Let's try: no limit_dom between max_N and succ(max_N_sub).
          --   b > max_N, b ∈ limit_dom. So b ≥ succ(max_N_sub).
          -- succ(max_N_sub) ≤ b from succ_le_iff.
          -- So b ≥ succ(max_N_sub) and succ(max_N_sub) ≤ b. Both say b ≥ succ(max_N_sub).
          -- We need b = succ(max_N_sub) or to continue iterating.
          -- Actually, succ(max_N_sub) ≤ b gives us b ≤ succ^[k₁+1](a) → b via:
          -- Wait, succ^[k₁+1](a) = succ(max_N_sub). And succ(max_N_sub) ≤ b.
          -- We need b ≤ succ^[m](a) for SOME m, not succ^[k₁+1](a) ≤ b.
          -- The issue is: succ keeps going past b potentially. If succ(max_N_sub) ≤ b,
          --   that means max_N_sub < b (which we know). It doesn't help.
          -- I think for this boundary case we need a separate argument.
          -- Key: b > max_N. b ∈ limit_dom. No limit_dom in (max_N, succ(max_N_sub)).
          -- b ∈ limit_dom ∩ (max_N, ∞). So b ≥ succ(max_N_sub).
          -- succ^[k₁+1](a) = succ(max_N_sub) ≤ b.
          -- If succ(max_N_sub) = b: k = k₁ + 1 works.
          -- If succ(max_N_sub) < b: continue iterating. But this is the original problem!
          -- Unless we can show succ(max_N_sub) = b using dom_new_unique.
          -- succ(max_N_sub) is limit_dom point > max_N. It's ∉ dom(N) (since > max_N).
          -- b ∉ dom(N). Both in limit_dom. If BOTH in dom(N+1):
          --   omega_chain_dom_new_unique gives succ(max_N_sub).val = b.val. Done!
          -- Is succ(max_N_sub) in dom(N+1)?
          -- Not necessarily! succ(max_N_sub) might enter at a later stage.
          -- So this approach has a gap for the boundary case.
          -- Let me just use sorry for now and handle this case separately.
          -- DEAD APPROACH: convergence/stage-induction method for succ_reaches_dom_N.
          -- Resolution: task 129 (Henkin model) or Reynolds pipeline (tasks 154-155).
          -- See Boneyard/StageInductionGapAnalysis/ for related archived analysis.
          sorry
        · -- b.val ≤ max_N. So b is at or below max(dom(N)).
          -- Since b ∉ dom(N), b ∈ dom(N+1) \ dom(N).
          -- b.val ≤ max_N. There exists some dom(N) point ≥ b.val (namely max_N).
          -- Also, a ∈ dom(N) and a ≤ b.
          -- b is between some adjacent dom(N) pair or below min(dom(N)).
          -- Check: is b.val < min(dom(N))? Impossible since a ≤ b and a ∈ dom(N).
          set min_N := (omega_chain_val fc A h_mcs N).dom.min' h_dom_ne with min_N_def
          have h_a_ge_min : min_N ≤ a.val := Finset.min'_le _ a.val ha_old
          have h_b_ge_min : min_N ≤ b.val := le_trans h_a_ge_min hab
          -- b.val ∈ [min_N, max_N] and b.val ∉ dom(N).
          -- Find adjacent pair (w, w_next) in dom(N) with w < b.val < w_next.
          -- Since b.val ≤ max_N and b.val ≥ min_N and b.val ∉ dom(N):
          -- First find some dom(N) point ≤ b.val:
          push_neg at hb_above_max  -- hb_above_max : b.val ≤ max_N
          -- We have min_N ≤ b.val ≤ max_N and b.val ∉ dom(N)
          -- Find w = max of {d ∈ dom(N) | d ≤ b.val}
          haveI : DecidablePred (fun d => d ≤ b.val) := fun d => inferInstance
          set L_set := (omega_chain_val fc A h_mcs N).dom.filter (· ≤ b.val) with L_set_def
          have hL_ne : L_set.Nonempty := by
            refine ⟨a.val, Finset.mem_filter.mpr ⟨ha_old, hab⟩⟩
          set R_set := (omega_chain_val fc A h_mcs N).dom.filter (b.val < ·) with R_set_def
          -- max_N ≥ b.val. If max_N = b.val: b.val ∈ dom(N), contradiction.
          -- So max_N > b.val (since b ∉ dom(N) and max_N ≥ b.val).
          have h_max_gt_b : max_N > b.val := by
            rcases lt_or_eq_of_le hb_above_max with h | h
            · exact h
            · exact absurd (h ▸ Finset.max'_mem _ h_dom_ne) hb_old
          have hR_ne : R_set.Nonempty := by
            refine ⟨max_N, Finset.mem_filter.mpr ⟨Finset.max'_mem _ h_dom_ne, h_max_gt_b⟩⟩
          set w := L_set.max' hL_ne with w_def
          set w_next := R_set.min' hR_ne with w_next_def
          have hw_mem : w ∈ (omega_chain_val fc A h_mcs N).dom :=
            (Finset.mem_filter.mp (Finset.max'_mem L_set hL_ne)).1
          have hw_le_b : w ≤ b.val :=
            (Finset.mem_filter.mp (Finset.max'_mem L_set hL_ne)).2
          have hwn_mem : w_next ∈ (omega_chain_val fc A h_mcs N).dom :=
            (Finset.mem_filter.mp (Finset.min'_mem R_set hR_ne)).1
          have hb_lt_wn : b.val < w_next :=
            (Finset.mem_filter.mp (Finset.min'_mem R_set hR_ne)).2
          have hw_lt_b : w < b.val := by
            rcases lt_or_eq_of_le hw_le_b with h | h
            · exact h
            · exact absurd (h ▸ hw_mem) hb_old
          have hw_lt_wn : w < w_next := lt_trans hw_lt_b hb_lt_wn
          -- w and w_next are in limit_dom
          have hw_limit : w ∈ limit_dom fc A h_mcs := ⟨N, hw_mem⟩
          have hwn_limit : w_next ∈ limit_dom fc A h_mcs := ⟨N, hwn_mem⟩
          -- IH: succ^[k](a_sub) = w_next_sub
          have h_a_le_wn : a ≤ (⟨w_next, hwn_limit⟩ : LimitDomSubtype fc A h_mcs) :=
            show a.val ≤ w_next from le_of_lt (lt_of_le_of_lt hab hb_lt_wn)
          obtain ⟨k₁, hk₁⟩ := ih a ⟨w_next, hwn_limit⟩ ha_old hwn_mem h_a_le_wn
          -- Now: succ^[k₁](a) = ⟨w_next, hwn_limit⟩
          -- We have a ≤ b < w_next and succ^[k₁](a) = w_next_sub ≥ b.
          -- By orbit convexity: ∃ j ≤ k₁, succ^[j](a) = b.
          have hb_le_iter : b ≤ (limitDomSubtype_succ fc A h_mcs h_discrete)^[k₁] a := by
            rw [hk₁]; exact le_of_lt hb_lt_wn
          exact (succ_orbit_convex fc A h_mcs h_discrete a b k₁ hab hb_le_iter).imp
            fun j ⟨_, hj⟩ => hj
    · by_cases hb_old : b.val ∈ (omega_chain_val fc A h_mcs N).dom
      · -- Case 2: a = new point at stage N+1, b ∈ dom(N).
        -- a ∉ dom(N), a ∈ dom(N+1). b ∈ dom(N).
        -- a is between dom(N) points or at boundary.
        -- Since a ≤ b and b ∈ dom(N):
        --   If a < min(dom(N)): a is below all dom(N) points. Need succ^[k](a) = b.
        --     This is the hard boundary case (below-min).
        --   If a is between w and w_next (adjacent in dom(N)):
        --     IH gives succ^[m](w_next_sub) = b_sub.
        --     Need succ^[j](a_sub) = w_next_sub. Then chain.
        --     By orbit convexity on the IH path from w to w_next:
        --     succ^[m'](w_sub) = w_next_sub. a between w and w_next.
        --     But a = new point, and we need succ from a to w_next.
        --     Key: succ(a) is next limit_dom after a. No limit_dom between a and succ(a).
        --     w_next > a (since a < w_next). w_next ∈ limit_dom. So succ(a) ≤ w_next.
        --     If succ(a) < w_next: succ(a) ∈ limit_dom ∩ (a, w_next). succ(a) ∉ dom(N)
        --       (between w and w_next, adjacent in dom(N)). So succ(a) is a later-stage point.
        --     Actually: between a and succ(a), no limit_dom. w_next > a, w_next ∈ limit_dom.
        --     So w_next ≥ succ(a). I.e., succ(a) ≤ w_next.
        --     Similarly, between w and a: w < a. w ∈ limit_dom. succ(w) ≤ a (since w < a
        --       and succ_le_iff). Also succ(w) is limit_dom, succ(w) > w.
        --     If succ(w) = a: then iterate: succ(a) is next. succ(a) ≤ w_next.
        --       succ^[2](w) = succ(a) ≤ w_next. IH gives succ^[m](w) = w_next.
        --       Orbit convexity: a between w and w_next, so a = succ^[j](w) for some j.
        --       Then succ^[m-j](a) = w_next. Then IH from w_next to b.
        --     But this uses IH with w ∈ dom(N), which is fine!
        -- For now, let me handle the "between" case and sorry the boundary.
        have h_dom_ne : (omega_chain_val fc A h_mcs N).dom.Nonempty := ⟨b.val, hb_old⟩
        set min_N := (omega_chain_val fc A h_mcs N).dom.min' h_dom_ne
        set max_N := (omega_chain_val fc A h_mcs N).dom.max' h_dom_ne
        -- a.val < min_N or a.val is between two dom(N) points
        -- Since a ≤ b and b ∈ dom(N), a.val ≤ b.val ≤ max_N.
        have h_a_le_max : a.val ≤ max_N :=
          le_trans hab (Finset.le_max' _ b.val hb_old)
        by_cases h_a_ge_min : min_N ≤ a.val
        · -- a.val ≥ min_N. So a.val ∈ [min_N, max_N] and a.val ∉ dom(N).
          -- Find adjacent pair bracketing a.
          haveI : DecidablePred (fun d => d ≤ a.val) := fun d => inferInstance
          set L_set := (omega_chain_val fc A h_mcs N).dom.filter (· ≤ a.val)
          set R_set := (omega_chain_val fc A h_mcs N).dom.filter (a.val < ·)
          have hL_ne : L_set.Nonempty := by
            refine ⟨min_N, Finset.mem_filter.mpr ⟨Finset.min'_mem _ h_dom_ne, h_a_ge_min⟩⟩
          -- Need a dom(N) point > a.val. Since a ≤ b and b ∈ dom(N):
          -- If a.val = b.val: a = b (same subtype element), and a ∈ dom(N) since b ∈ dom(N).
          -- But a ∉ dom(N). So a.val ≠ b.val. So a.val < b.val.
          have h_a_lt_b : a.val < b.val := by
            rcases lt_or_eq_of_le (hab : a.val ≤ b.val) with h | h
            · exact h
            · exact absurd (show a.val ∈ _ from h ▸ hb_old) ha_old
          have hR_ne : R_set.Nonempty :=
            ⟨b.val, Finset.mem_filter.mpr ⟨hb_old, h_a_lt_b⟩⟩
          set w := L_set.max' hL_ne
          set w_next := R_set.min' hR_ne
          have hw_mem : w ∈ (omega_chain_val fc A h_mcs N).dom :=
            (Finset.mem_filter.mp (Finset.max'_mem L_set hL_ne)).1
          have hw_le_a : w ≤ a.val :=
            (Finset.mem_filter.mp (Finset.max'_mem L_set hL_ne)).2
          have hwn_mem : w_next ∈ (omega_chain_val fc A h_mcs N).dom :=
            (Finset.mem_filter.mp (Finset.min'_mem R_set hR_ne)).1
          have ha_lt_wn : a.val < w_next :=
            (Finset.mem_filter.mp (Finset.min'_mem R_set hR_ne)).2
          have hw_lt_a : w < a.val := by
            rcases lt_or_eq_of_le hw_le_a with h | h
            · exact h
            · exact absurd (h ▸ hw_mem) ha_old
          -- w, w_next, b ∈ dom(N). w < a < w_next ≤ b.
          have hw_limit : w ∈ limit_dom fc A h_mcs := ⟨N, hw_mem⟩
          have hwn_limit : w_next ∈ limit_dom fc A h_mcs := ⟨N, hwn_mem⟩
          -- IH: succ^[m](w_sub) = b_sub (both in dom(N), w ≤ b since w < a ≤ b)
          have hw_le_b : (⟨w, hw_limit⟩ : LimitDomSubtype fc A h_mcs) ≤ b := by
            show w ≤ b.val; exact le_trans (le_of_lt hw_lt_a) hab
          obtain ⟨m, hm⟩ := ih ⟨w, hw_limit⟩ b hw_mem hb_old hw_le_b
          -- succ^[m](w_sub) = b. Since w < a ≤ b = succ^[m](w_sub):
          --   a is between w_sub and succ^[m](w_sub).
          --   By orbit convexity: ∃ j ≤ m, succ^[j](w_sub) = a.
          have ha_in_range : a ≤ (limitDomSubtype_succ fc A h_mcs h_discrete)^[m] ⟨w, hw_limit⟩ := by
            rw [hm]; exact hab
          have hw_le_a' : (⟨w, hw_limit⟩ : LimitDomSubtype fc A h_mcs) ≤ a := by
            show w ≤ a.val; exact le_of_lt hw_lt_a
          obtain ⟨j, hj_le, hj_eq⟩ := succ_orbit_convex fc A h_mcs h_discrete
            ⟨w, hw_limit⟩ a m hw_le_a' ha_in_range
          -- succ^[j](w_sub) = a. So succ^[m-j](a) = succ^[m](w_sub) = b.
          -- Actually, succ^[m](w_sub) = b and succ^[j](w_sub) = a.
          -- succ^[m-j](succ^[j](w_sub)) = succ^[m](w_sub) = b.
          -- So succ^[m-j](a) = b.
          refine ⟨m - j, ?_⟩
          have : (limitDomSubtype_succ fc A h_mcs h_discrete)^[m - j]
              ((limitDomSubtype_succ fc A h_mcs h_discrete)^[j] ⟨w, hw_limit⟩) =
              (limitDomSubtype_succ fc A h_mcs h_discrete)^[m] ⟨w, hw_limit⟩ := by
            rw [← Function.iterate_add_apply]
            congr 1; omega
          rw [hj_eq] at this; rw [this, hm]
        · -- a.val < min_N. Boundary case: a below min(dom(N)).
          -- This is the hard boundary case (below-min).
          -- DEAD APPROACH: convergence/stage-induction method for succ_reaches_dom_N.
          -- Resolution: task 129 (Henkin model) or Reynolds pipeline (tasks 154-155).
          -- See Boneyard/StageInductionGapAnalysis/ for related archived analysis.
          sorry
      · -- Case 4: both new at stage N+1.
        -- omega_chain_dom_new_unique gives a.val = b.val, hence a = b.
        have ha_new : a.val ∈ (omega_chain_val fc A h_mcs (N + 1)).dom := ha
        have hb_new : b.val ∈ (omega_chain_val fc A h_mcs (N + 1)).dom := hb
        have := omega_chain_dom_new_unique fc A h_mcs N a.val b.val ha_new ha_old hb_new hb_old
        exact ⟨0, Subtype.ext this⟩

-- ARCHIVED: limit_dom_points_are_succ_iterates moved to
-- Boneyard/DeadConvergenceProof/limit_dom_succ_iterates.lean
-- This helper was only used by the dead convergence proof inside succ_cofinal.
-- It is not needed by the plan v9 approach (derive succ_cofinal from one_class).

/-! ## Z1 Derivation and Gap Elimination Helpers

The Z1 schema `G(Gφ→φ) → (FGφ→Gφ)` is derivable from Prior-UZ + BX axioms.
Once derived, `theorem_in_mcs` places Z1 in every MCS, enabling the Doets
maximum principle argument for gap elimination in `succ_cofinal`.
-/

/-- Z1 formula: `G(Gφ→φ) → (FGφ→Gφ)`.
The syntactic correspondent of the IsSuccArchimedean frame condition. -/
private def z1_formula (φ : Formula) : Formula :=
  (φ.all_future.imp φ).all_future.imp (φ.all_future.some_future.imp φ.all_future)

/-- Z1 derivation: `⊢[fc] G(Gφ→φ) → (FGφ→Gφ)`.
Requires `FrameClass.Discrete <= fc` since z1 has minFrameClass = .Discrete. -/
private def z1_derivation (fc : FrameClass) (h_fc : FrameClass.Discrete <= fc) (φ : Formula) :
    DerivationTree fc [] (z1_formula φ) :=
  DerivationTree.axiom [] _ (Axiom.z1 φ) h_fc

/-- Z1 is in every MCS: if S is maximal consistent (for fc >= Discrete), then `z1_formula φ ∈ S`. -/
private theorem z1_in_mcs (fc : FrameClass) (h_fc : FrameClass.Discrete <= fc) (φ : Formula) {S : Set Formula}
    (h_mcs : SetMaximalConsistent (fc := fc) S) :
    z1_formula φ ∈ S :=
  theorem_in_mcs h_mcs (z1_derivation fc h_fc φ)

/-! ## Chronicle Gap Elimination via Model Surgery

Reynolds' Theorem 14 adapted to the chronicle level using sorry-free model
surgery from `GoodStructuresModelSurgery.lean`.

The proof uses `gap_contradicts_prior` / `gap_contradicts_prior_below` together
with `no_boundary_at_successor` from GoodStructures.lean to derive a contradiction
from the existence of a bounded successor orbit.

## Strategy

Given `a < b` with `∀ n, succ^[n](a) < b`:

1. Build an `OrderedMonadicStructure` on `LimitDomSubtype` with `interp p x :=
   (atomMap_rev p) ∈ limit_f(x.val)`, where the signature is a singleton
   `{ψ}` for a formula ψ distinguishing `limit_f(a.val)` from `limit_f(b.val)`.

2. Prove `semantic_prior_UZ/SZ` for this structure using the MCS-level Prior-UZ/SZ
   (from `h_fc : Discrete ≤ fc`) together with C4/C5 coherence.

3. By `no_boundary_at_successor`: the contemp_equiv class of `a` is succ-closed.

4. Since `a` and `b` are NOT contemp_equiv (ψ distinguishes them), `b` bounds the
   class of `a` above. By `gap_contradicts_prior`: False.

## Constant-MCS Case

When `limit_f(a.val) = limit_f(b.val)`, no formula distinguishes a and b, so
contemp_equiv holds for all sig/k. The Z+Z counterexample shows this case
cannot be resolved by abstract model surgery alone. A chronicle-specific argument
(showing constant MCS implies the succ-orbit covers the entire domain) is needed.
This case has a sorry pending resolution.
-/

/--
Helper: if `ψ ∈ limit_f(y)` and `x < y`, then `F(ψ) ∈ limit_f(x)`.
More precisely, `some_future ψ ∈ limit_f(x)`.

Proof by contradiction using C4. If `F(ψ) ∉ limit_f(x)`, then `¬F(ψ) = (U(ψ, ⊤)).neg
∈ limit_f(x)`. By C4 with event `ψ` at `y` and guard `⊤`, we get `z` with
`x < z < y` and `⊤.neg ∈ limit_f(z)`, i.e., `⊥ ∈ limit_f(z)`. But `⊥` is never in
an MCS. Contradiction.
-/
private theorem limit_f_some_future_of_lt (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (x y : Rat) (hx : x ∈ limit_dom fc A h_mcs) (hy : y ∈ limit_dom fc A h_mcs)
    (hxy : x < y) (ψ : Formula) (hψ : ψ ∈ limit_f fc A h_mcs y) :
    Formula.some_future ψ ∈ limit_f fc A h_mcs x := by
  by_contra h_neg
  have h_mcs_x := limit_c0 fc A h_mcs x hx
  have h_neg_F : (Formula.some_future ψ).neg ∈ limit_f fc A h_mcs x :=
    (SetMaximalConsistent.negation_complete h_mcs_x _).resolve_left h_neg
  -- some_future ψ = U(ψ, ⊤). So (some_future ψ).neg = (U(ψ, ⊤)).neg
  -- C4 with η = ψ, ξ = ⊤: ¬U(ψ,⊤) ∈ f(x) and ψ ∈ f(y) gives z with ⊤.neg ∈ f(z)
  -- Use change to make the types match exactly
  set top := Formula.bot.imp Formula.bot with htop_def
  have h_neg_until : (Formula.untl ψ top).neg ∈ limit_f fc A h_mcs x := h_neg_F
  obtain ⟨z, hz, _, _, h_top_neg⟩ :=
    limit_satisfies_c4 fc A h_mcs x y hx hy hxy top ψ h_neg_until hψ
  -- ⊤.neg = (⊥ → ⊥).neg ∈ f(z). But ⊤ = ⊥ → ⊥ is in every MCS.
  have h_mcs_z := limit_c0 fc A h_mcs z hz
  have h_top_in : top ∈ limit_f fc A h_mcs z :=
    theorem_in_mcs h_mcs_z (identity Formula.bot)
  exact set_consistent_not_both h_mcs_z.1 top h_top_in h_top_neg

/--
Helper: if `ψ ∈ limit_f(y)` and `x < y`, then `G(ψ.neg) ∉ limit_f(x)`.
Contrapositive of `limit_forward_G`: if `G(ψ.neg) ∈ limit_f(x)` and `x < y`,
then `ψ.neg ∈ limit_f(y)`, contradicting `ψ ∈ limit_f(y)`.
-/
private theorem limit_f_not_G_neg_of_mem (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (x y : Rat) (hx : x ∈ limit_dom fc A h_mcs) (hy : y ∈ limit_dom fc A h_mcs)
    (hxy : x < y) (ψ : Formula) (hψ : ψ ∈ limit_f fc A h_mcs y) :
    Formula.all_future ψ.neg ∉ limit_f fc A h_mcs x := by
  intro h_G_neg
  have h_neg_y := limit_forward_G fc A h_mcs x y hx hy hxy ψ.neg h_G_neg
  exact SetMaximalConsistent.neg_excludes (limit_c0 fc A h_mcs y hy) ψ h_neg_y hψ

/--
**Core gap elimination**: If the chronicle domain has a bounded successor orbit,
derive a contradiction.

**Status (task 273)**: SORRY. Extensive analysis (6 approaches tried) shows this is
a genuinely difficult theorem requiring a novel proof technique. See plan file
`specs/273_chronicle_gap_contradiction_proof/plans/01_gap-contradiction-plan.md`
for detailed blocker analysis.

**Approaches investigated and their failure modes**:
1. Model surgery via contemp_equiv: Trivially true for bounded intervals at any
   EF-game depth k (confirmed by research).
2. Stage induction via succ_reaches_dom_N: Boundary cases irresolvable (limit-level
   successor may not appear until arbitrarily later stage).
3. Z1 direct instantiation: Orbit membership is second-order, not expressible as
   a temporal formula. G(Gψ→ψ) unverifiable for distinguishing formulas at gap
   boundary points.
4. Pred/succ cancellation descent: Circular (requires IsPredArchimedean = IsSuccArchimedean).
5. Dom(N) stage counting: Gives succ^K(a) ≤ b but not ≥ b (orbit may advance slower
   than dom(N) spacing due to intermediate insertions).
6. Boneyard expressive completeness approach: Requires semantic Prior-UZ/SZ for
   orbit-membership structure, which is the gap this theorem is trying to fill.

**Helper lemmas added**: `limit_f_some_future_of_lt` and `limit_f_not_G_neg_of_mem`
(both sorry-free) provide F(ψ) ∈ limit_f(x) from ψ ∈ limit_f(y) when x < y, and
the contrapositive of limit_forward_G.

**What is needed**: A proof technique that either (a) expresses orbit membership
in the temporal language (possibly using Reynolds expressive completeness with a
different structure), (b) uses the chronicle construction's enumeration directly
to show the orbit reaches b, or (c) bypasses chronicle_gap_contradiction entirely
via Strategy B (completing ReynoldsBridge.lean:489).
-/
private theorem chronicle_gap_contradiction (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_fc : FrameClass.Discrete ≤ fc)
    (h_discrete : ∀ x ∈ limit_dom fc A h_mcs, next_top ∈ limit_f fc A h_mcs x)
    (a b : LimitDomSubtype fc A h_mcs) (hab : a < b)
    (h_orbit_bounded : ∀ n : ℕ,
      (limitDomSubtype_succ fc A h_mcs h_discrete)^[n] a < b) :
    False := by
  sorry

/-  OLD PROOF (blocked by import cycle, replaced above):
  letI : SuccOrder (LimitDomSubtype fc A h_mcs) :=
    limitDomSubtype_succOrder fc A h_mcs h_discrete
  letI : PredOrder (LimitDomSubtype fc A h_mcs) :=
    limitDomSubtype_predOrder fc A h_mcs h_discrete
  -- Case split on whether limit_f distinguishes a and b
  by_cases h_mcs_eq : limit_f fc A h_mcs a.val = limit_f fc A h_mcs b.val
  · -- Case B: constant MCS at a and b. Chronicle-specific argument needed.
    -- The Z+Z counterexample shows this cannot be resolved by abstract
    -- model surgery. A proof that constant MCS + chronicle structure implies
    -- the succ-orbit covers the domain (making this case vacuously false)
    -- requires induction on the omega-chain construction.
    sorry
  · -- Case A: limit_f differs at a and b. Pick a distinguishing formula.
    -- There exists ψ in the symmetric difference of limit_f(a.val) and limit_f(b.val).
    -- h_mcs_eq : ¬(limit_f ... a.val = limit_f ... b.val), i.e., the sets differ
    have h_ne : ∃ ψ, ψ ∈ limit_f fc A h_mcs a.val ∧ ψ ∉ limit_f fc A h_mcs b.val ∨
        ψ ∈ limit_f fc A h_mcs b.val ∧ ψ ∉ limit_f fc A h_mcs a.val := by
      by_contra h_all
      push_neg at h_all
      exact h_mcs_eq (Set.eq_of_subset_of_subset
        (fun x hx => by_contra h; exact (h_all x).1 hx h)
        (fun x hx => by_contra h; exact (h_all x).2 hx h))
    -- Build a single-predicate OrderedMonadicStructure on LimitDomSubtype.
    -- sig has one predicate; interp maps that predicate to ψ-membership.
    -- The signature: a single predicate p₀
    let sig : Bimodal.Metalogic.WeakCanonical.MonadicSignature := {
      preds := Unit
      fintypePreds := inferInstance
      decEqPreds := inferInstance
    }
    -- Choose a ψ that distinguishes a and b, preferring ψ ∈ limit_f(a.val) \ limit_f(b.val)
    -- to ensure the class of a (where ψ holds) is bounded above by b (where ψ doesn't hold).
    obtain ⟨ψ, hψ⟩ := h_ne
    rcases hψ with ⟨hψ_in, hψ_not⟩ | ⟨hψ_in, hψ_not⟩
    · -- ψ ∈ limit_f(a.val) but ψ ∉ limit_f(b.val)
      -- Build the OrderedMonadicStructure
      let M : Bimodal.Metalogic.WeakCanonical.OrderedMonadicStructure sig := {
        carrier := LimitDomSubtype fc A h_mcs
        interp := fun () x => ψ ∈ limit_f fc A h_mcs x.val
        carrier_order := inferInstance
      }
      -- atomMap: maps all formulas to the single predicate
      let atomMap : Formula → sig.preds := fun _ => ()
      -- h_surj: trivially true for a single-predicate signature
      have h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p := by
        intro (); exact ⟨⟨0⟩, rfl⟩
      -- Prove semantic_prior_UZ for this structure.
      -- For any ψ' and t: if ∃ s > t, temporal_truth s ψ', then ∃ first such s.
      -- temporal_truth depends on ψ' recursively. For atoms, it's ψ-membership.
      -- The proof adapts chronicle_semantic_prior_UZ from Transfer.lean.
      -- Key: effectiveFormula maps any formula ψ' to a formula whose MCS membership
      -- equals temporal_truth M atomMap t ψ'. We define it inline.
      -- effectiveFormula for a single-pred sig: atom a ↦ ψ, bot ↦ bot, etc.
      -- The effective formula is: replace all atoms and boxes in ψ' with ψ.
      let eff : Formula → Formula := fun f => match f with
        | .atom _ => ψ | .bot => .bot
        | .imp f₁ f₂ => .imp (eff f₁) (eff f₂)
        | .box _ => ψ  -- box maps to the single predicate too
        | .untl f₁ f₂ => .untl (eff f₁) (eff f₂)
        | .snce f₁ f₂ => .snce (eff f₁) (eff f₂)
      -- We need: temporal_truth M atomMap t f ↔ eff(f) ∈ limit_f(t.val)
      -- This requires a nontrivial proof by induction on f, using C4/C5.
      -- For the MCS bridge: eff(f) ∈ limit_f(t.val) is governed by the MCS properties.
      -- The proof of semantic_prior_UZ then follows the Transfer.lean pattern:
      --   temporal_truth t ψ' → eff(ψ') ∈ fmcs(t) → F(eff(ψ')) ∈ fmcs(t)
      --   → U(eff(ψ'), eff(ψ').neg) ∈ fmcs(t) [by Prior-UZ axiom]
      --   → C5 gives first witness → convert back to temporal_truth
      --
      -- This is a substantial inline proof. For now, we use the direct approach:
      -- since limit_f(a.val) ≠ limit_f(b.val) and ψ distinguishes them,
      -- we know a and b are NOT contemp_equiv at k=0 (0-equiv checks only
      -- predicate agreement, not quantifier depth). Then no_gaps_discrete_model_surgery
      -- gives ∃ boundary at successor, contradicting no_boundary_at_successor.
      --
      -- Actually, we can bypass semantic_prior_UZ entirely: we only need
      -- no_boundary_at_successor (which doesn't require prior_UZ/SZ) to get succ-closure,
      -- then gap_contradicts_prior (which does require prior_UZ/SZ).
      -- So we DO need semantic_prior_UZ/SZ. Let's prove it.
      --
      -- The proof follows the chronicle_semantic_prior_UZ pattern but operates on
      -- the raw limit_f/limit_c0/limit_satisfies_c5_strong/limit_satisfies_c4 directly.
      have h_temporal_truth_eff : ∀ (t : LimitDomSubtype fc A h_mcs) (f : Formula),
          Bimodal.Metalogic.WeakCanonical.temporal_truth M atomMap t f ↔
          eff f ∈ limit_f fc A h_mcs t.val := by
        intro t f
        induction f generalizing t with
        | atom _ => show (ψ ∈ limit_f fc A h_mcs t.val) ↔ (ψ ∈ limit_f fc A h_mcs t.val); exact Iff.rfl
        | bot =>
          constructor
          · exact False.elim
          · intro h; exact absurd h (bot_not_in_mcs (limit_c0 fc A h_mcs t.val t.property))
        | imp f₁ f₂ ih₁ ih₂ =>
          simp only [Bimodal.Metalogic.WeakCanonical.temporal_truth, eff]
          rw [ih₁ t, ih₂ t]
          exact (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (limit_c0 fc A h_mcs t.val t.property) _ _).symm
        | box _ => show (ψ ∈ limit_f fc A h_mcs t.val) ↔ (ψ ∈ limit_f fc A h_mcs t.val); exact Iff.rfl
        | untl f₁ f₂ ih₁ ih₂ =>
          simp only [Bimodal.Metalogic.WeakCanonical.temporal_truth, eff]
          constructor
          · -- Forward: temporal Until → MCS Until
            intro ⟨s, hts, hf₁s, h_guard⟩
            have h₁ : eff f₁ ∈ limit_f fc A h_mcs s.val := (ih₁ s).mp hf₁s
            have h₂ : ∀ r : LimitDomSubtype fc A h_mcs, t < r → r < s →
                eff f₂ ∈ limit_f fc A h_mcs r.val :=
              fun r htr hrs => (ih₂ r).mp (h_guard r htr hrs)
            by_contra h_neg
            have h_neg_until : (Formula.untl (eff f₁) (eff f₂)).neg ∈
                limit_f fc A h_mcs t.val :=
              (SetMaximalConsistent.negation_complete
                (limit_c0 fc A h_mcs t.val t.property) _).resolve_left h_neg
            obtain ⟨z, hz, htz, hzs, h_neg_guard⟩ :=
              limit_satisfies_c4 fc A h_mcs t.val s.val t.property s.property hts
                (eff f₂) (eff f₁) h_neg_until h₁
            exact absurd (h₂ ⟨z, hz⟩ htz hzs)
              (SetMaximalConsistent.neg_excludes (limit_c0 fc A h_mcs z hz) _ h_neg_guard)
          · -- Backward: MCS Until → temporal Until
            intro h_until
            obtain ⟨y, hy, hty, hf₁y, h_guard⟩ :=
              limit_satisfies_c5_strong fc A h_mcs t.val t.property (eff f₂) (eff f₁) h_until
            exact ⟨⟨y, hy⟩, hty, (ih₁ ⟨y, hy⟩).mpr hf₁y,
              fun r htr hrs => (ih₂ r).mpr (h_guard r.val r.property htr hrs)⟩
        | snce f₁ f₂ ih₁ ih₂ =>
          simp only [Bimodal.Metalogic.WeakCanonical.temporal_truth, eff]
          constructor
          · -- Forward: temporal Since → MCS Since
            intro ⟨s, hst, hf₁s, h_guard⟩
            have h₁ : eff f₁ ∈ limit_f fc A h_mcs s.val := (ih₁ s).mp hf₁s
            have h₂ : ∀ r : LimitDomSubtype fc A h_mcs, s < r → r < t →
                eff f₂ ∈ limit_f fc A h_mcs r.val :=
              fun r hsr hrt => (ih₂ r).mp (h_guard r hsr hrt)
            by_contra h_neg
            have h_neg_since : (Formula.snce (eff f₁) (eff f₂)).neg ∈
                limit_f fc A h_mcs t.val :=
              (SetMaximalConsistent.negation_complete
                (limit_c0 fc A h_mcs t.val t.property) _).resolve_left h_neg
            obtain ⟨z, hz, hsz, hzt, h_neg_guard⟩ :=
              limit_satisfies_c4' fc A h_mcs t.val s.val t.property s.property hst
                (eff f₂) (eff f₁) h_neg_since h₁
            exact absurd (h₂ ⟨z, hz⟩ hsz hzt)
              (SetMaximalConsistent.neg_excludes (limit_c0 fc A h_mcs z hz) _ h_neg_guard)
          · -- Backward: MCS Since → temporal Since
            intro h_since
            obtain ⟨y, hy, hyt, hf₁y, h_guard⟩ :=
              limit_satisfies_c5'_strong fc A h_mcs t.val t.property (eff f₂) (eff f₁) h_since
            exact ⟨⟨y, hy⟩, hyt, (ih₁ ⟨y, hy⟩).mpr hf₁y,
              fun r hsr hrt => (ih₂ r).mpr (h_guard r.val r.property hsr hrt)⟩
      -- Now prove semantic_prior_UZ
      have h_prior_UZ : Bimodal.Metalogic.WeakCanonical.semantic_prior_UZ M atomMap := by
        intro t ψ' ⟨s, hts, h_ψ_s⟩
        let eff_ψ := eff ψ'
        have h_eff_s : eff_ψ ∈ limit_f fc A h_mcs s.val :=
          (h_temporal_truth_eff s ψ').mp h_ψ_s
        -- F(eff_ψ) ∈ fmcs(t)
        have h_F_eff : Formula.some_future eff_ψ ∈ limit_f fc A h_mcs t.val := by
          by_contra h_neg
          have h_neg_F : (Formula.some_future eff_ψ).neg ∈ limit_f fc A h_mcs t.val :=
            (SetMaximalConsistent.negation_complete (limit_c0 fc A h_mcs t.val t.property) _).resolve_left h_neg
          simp only [Formula.some_future] at h_neg_F
          obtain ⟨z, hz, htz, hzs, h_neg_top⟩ :=
            limit_satisfies_c4 fc A h_mcs t.val s.val t.property s.property hts _ _ h_neg_F h_eff_s
          have h_top : Formula.imp Formula.bot Formula.bot ∈ limit_f fc A h_mcs z :=
            (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (limit_c0 fc A h_mcs z hz) _ _).mpr (fun h => h)
          have h_bot : Formula.bot ∈ limit_f fc A h_mcs z :=
            (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (limit_c0 fc A h_mcs z hz) _ _).mp h_neg_top h_top
          exact absurd h_bot (bot_not_in_mcs (limit_c0 fc A h_mcs z hz))
        -- Prior-UZ axiom: F(eff_ψ) → U(eff_ψ, ¬eff_ψ) in every MCS
        have h_prior := theorem_in_mcs (limit_c0 fc A h_mcs t.val t.property)
          (DerivationTree.axiom [] _ (Axiom.prior_UZ eff_ψ) h_fc)
        have h_until : Formula.untl eff_ψ eff_ψ.neg ∈ limit_f fc A h_mcs t.val :=
          (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (limit_c0 fc A h_mcs t.val t.property) _ _).mp h_prior h_F_eff
        -- C5 forward
        obtain ⟨s', hs', hts', h_eff_s', h_guard⟩ :=
          limit_satisfies_c5_strong fc A h_mcs t.val t.property eff_ψ.neg eff_ψ h_until
        refine ⟨⟨s', hs'⟩, hts', ?_, ?_⟩
        · exact (h_temporal_truth_eff ⟨s', hs'⟩ ψ').mpr h_eff_s'
        · intro r htr hrs
          simp only [Formula.neg, Bimodal.Metalogic.WeakCanonical.temporal_truth]
          intro h_ψ_r
          have h_eff_r : eff_ψ ∈ limit_f fc A h_mcs r.val :=
            (h_temporal_truth_eff r ψ').mp h_ψ_r
          exact absurd h_eff_r
            (SetMaximalConsistent.neg_excludes (limit_c0 fc A h_mcs r.val r.property) _ (h_guard r.val r.property htr hrs))
      -- Prove semantic_prior_SZ (symmetric)
      have h_prior_SZ : Bimodal.Metalogic.WeakCanonical.semantic_prior_SZ M atomMap := by
        intro t ψ' ⟨s, hst, h_ψ_s⟩
        let eff_ψ := eff ψ'
        have h_eff_s : eff_ψ ∈ limit_f fc A h_mcs s.val :=
          (h_temporal_truth_eff s ψ').mp h_ψ_s
        have h_P_eff : Formula.some_past eff_ψ ∈ limit_f fc A h_mcs t.val := by
          by_contra h_neg
          have h_neg_P : (Formula.some_past eff_ψ).neg ∈ limit_f fc A h_mcs t.val :=
            (SetMaximalConsistent.negation_complete (limit_c0 fc A h_mcs t.val t.property) _).resolve_left h_neg
          simp only [Formula.some_past] at h_neg_P
          obtain ⟨z, hz, hsz, hzt, h_neg_top⟩ :=
            limit_satisfies_c4' fc A h_mcs t.val s.val t.property s.property hst _ _ h_neg_P h_eff_s
          have h_top : Formula.imp Formula.bot Formula.bot ∈ limit_f fc A h_mcs z :=
            (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (limit_c0 fc A h_mcs z hz) _ _).mpr (fun h => h)
          have h_bot : Formula.bot ∈ limit_f fc A h_mcs z :=
            (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (limit_c0 fc A h_mcs z hz) _ _).mp h_neg_top h_top
          exact absurd h_bot (bot_not_in_mcs (limit_c0 fc A h_mcs z hz))
        have h_prior := theorem_in_mcs (limit_c0 fc A h_mcs t.val t.property)
          (DerivationTree.axiom [] _ (Axiom.prior_SZ eff_ψ) h_fc)
        have h_since : Formula.snce eff_ψ eff_ψ.neg ∈ limit_f fc A h_mcs t.val :=
          (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (limit_c0 fc A h_mcs t.val t.property) _ _).mp h_prior h_P_eff
        obtain ⟨s', hs', hst', h_eff_s', h_guard⟩ :=
          limit_satisfies_c5'_strong fc A h_mcs t.val t.property eff_ψ.neg eff_ψ h_since
        refine ⟨⟨s', hs'⟩, hst', ?_, ?_⟩
        · exact (h_temporal_truth_eff ⟨s', hs'⟩ ψ').mpr h_eff_s'
        · intro r hsr hrt
          simp only [Formula.neg, Bimodal.Metalogic.WeakCanonical.temporal_truth]
          intro h_ψ_r
          have h_eff_r : eff_ψ ∈ limit_f fc A h_mcs r.val :=
            (h_temporal_truth_eff r ψ').mp h_ψ_r
          exact absurd h_eff_r
            (SetMaximalConsistent.neg_excludes (limit_c0 fc A h_mcs r.val r.property) _ (h_guard r.val r.property hsr hrt))
      -- Succ-closure: class of a is succ-closed by no_boundary_at_successor + transitivity
      have h_succ_closed : ∀ c, Bimodal.Metalogic.WeakCanonical.contemp_equiv sig 0 M a c →
          Bimodal.Metalogic.WeakCanonical.contemp_equiv sig 0 M a (Order.succ c) :=
        fun c hac => (Bimodal.Metalogic.WeakCanonical.contemp_equiv_is_equiv sig 0 M).trans hac
          (Bimodal.Metalogic.WeakCanonical.no_boundary_at_successor sig 0 M c)
      -- Bounded above: b is NOT in a's class (ψ distinguishes them at k=0)
      have h_not_equiv_ab : ¬ Bimodal.Metalogic.WeakCanonical.contemp_equiv sig 0 M a b := by
        intro h_equiv
        -- contemp_equiv at k=0 means all subintervals have the same 0-type.
        -- In particular, the structure at a and b must agree on all predicates.
        -- Since sig has one predicate (ψ membership), a and b must both have ψ
        -- or both lack ψ. But ψ ∈ limit_f(a.val) and ψ ∉ limit_f(b.val).
        -- The 0-equivalence implies identical predicate assignments.
        simp only [Bimodal.Metalogic.WeakCanonical.contemp_equiv] at h_equiv
        -- The subinterval [min(a,b), max(a,b)] = [a, b] has good(0) for M.
        -- Good at depth 0 means all pairs of elements in [a,b] have the same
        -- predicate values. Since a, b ∈ [a, b], interp () a = interp () b.
        -- But interp () a = (ψ ∈ limit_f(a.val)) = True and
        --     interp () b = (ψ ∈ limit_f(b.val)) = False.
        have hab_le := le_of_lt hab
        rw [min_eq_left hab_le, max_eq_right hab_le] at h_equiv
        have h_good := h_equiv a b ⟨le_refl a, hab_le⟩
        -- h_good : good sig 0 (M.subinterval sig a b)
        -- At depth 0, good means for any two elements c, d of the subinterval,
        -- M.subinterval.interp p c = M.subinterval.interp p d.
        -- The subinterval has carrier = {x | a ≤ x ∧ x ≤ b}.
        -- We need elements: ⟨a, ⟨le_refl, hab_le⟩⟩ and ⟨b, ⟨hab_le, le_refl⟩⟩.
        -- Then M.subinterval.interp () ⟨a,...⟩ = ψ ∈ limit_f(a.val) = True
        --  and M.subinterval.interp () ⟨b,...⟩ = ψ ∈ limit_f(b.val) = False.
        -- good at 0 should give these are equal, contradiction.
        -- Actually, good(0) only says k_equiv depth 0, which requires
        -- evaluating all sentences of quantifier depth 0. A sentence of depth 0
        -- is a Boolean combination of atoms. The atoms are the predicates applied
        -- to the (0 free) variables -- but there are no free variables in a sentence!
        -- So depth 0 is about closed formulas, which don't reference specific elements.
        -- This means good(0) is trivially true. We need k ≥ 1!
        -- Let me use k = 1 instead.
        sorry
      -- Apply gap_contradicts_prior
      exact Bimodal.Metalogic.WeakCanonical.gap_contradicts_prior sig 0 M atomMap h_surj
        h_prior_UZ h_prior_SZ a h_succ_closed ⟨b, hab, h_not_equiv_ab⟩
    · -- ψ ∈ limit_f(b.val) but ψ ∉ limit_f(a.val)
      -- Symmetric case: b has ψ, a doesn't.
      -- The class of a (where ψ is absent) is bounded above by some point where ψ appears.
      -- Use gap_contradicts_prior_below or rearrange the argument.
      -- Actually, we can use the same argument: a's class contains points where ψ ∉ limit_f.
      -- b is NOT in a's class. Since b > a, a's class is bounded above.
      let M : Bimodal.Metalogic.WeakCanonical.OrderedMonadicStructure sig := {
        carrier := LimitDomSubtype fc A h_mcs
        interp := fun () x => ψ ∈ limit_f fc A h_mcs x.val
        carrier_order := inferInstance
      }
      let atomMap : Formula → sig.preds := fun _ => ()
      have h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p := by
        intro (); exact ⟨⟨0⟩, rfl⟩
      -- Same semantic_prior_UZ/SZ proofs apply (they don't depend on the direction)
      -- For brevity, we sorry the symmetric case and note it follows by the same pattern
      sorry
-/

/--
Succ-iterates are cofinal: for any `a < b` in `LimitDomSubtype`, there exists `n`
such that `succ^[n](a) ≥ b`. Combined with `succ_orbit_convex`, this gives
`IsSuccArchimedean`.

Proof: by contradiction using `chronicle_gap_contradiction`. If succ^[n](a) < b
for all n, then the successor orbit is bounded, creating a Dedekind cut that
contradicts Prior-SZ at the chronicle level (Reynolds Theorem 14 at chronicle level).
-/
private theorem succ_cofinal (fc : FrameClass) (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_fc : FrameClass.Discrete ≤ fc)
    (h_discrete : ∀ x ∈ limit_dom fc A h_mcs, next_top ∈ limit_f fc A h_mcs x)
    (a b : LimitDomSubtype fc A h_mcs) (hab : a < b) :
    ∃ n, b ≤ (limitDomSubtype_succ fc A h_mcs h_discrete)^[n] a := by
  by_contra h_not_cofinal
  push_neg at h_not_cofinal
  exact chronicle_gap_contradiction fc A h_mcs h_fc h_discrete a b hab h_not_cofinal
/--
**SUPERSEDED by `limitDomSubtype_isSuccArchimedean_axiom`** (task 155).

`IsSuccArchimedean` instance for `LimitDomSubtype` in the discrete case.
Uses `succ_cofinal` which has a sorry via `chronicle_gap_contradiction`.
Retained for compilation of the general `completeness` theorem only.
`succ_embed_surjective` now uses the axiom instead of this definition.
-/
noncomputable def limitDomSubtype_isSuccArchimedean (fc : FrameClass)
    (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_fc : FrameClass.Discrete ≤ fc)
    (h_discrete : ∀ x ∈ limit_dom fc A h_mcs, next_top ∈ limit_f fc A h_mcs x) :
    @IsSuccArchimedean (LimitDomSubtype fc A h_mcs)
      inferInstance
      (limitDomSubtype_succOrder fc A h_mcs h_discrete) :=
  @IsSuccArchimedean.mk _ _ (limitDomSubtype_succOrder fc A h_mcs h_discrete) <| by
    intro a b hab
    change ∃ n, (limitDomSubtype_succ fc A h_mcs h_discrete)^[n] a = b
    set s := limitDomSubtype_succ fc A h_mcs h_discrete
    rcases eq_or_lt_of_le hab with rfl | hab_lt
    · exact ⟨0, rfl⟩
    · -- a < b. By succ_cofinal: ∃ n, b ≤ s^[n](a).
      obtain ⟨n, hn⟩ := succ_cofinal fc A h_mcs h_fc h_discrete a b hab_lt
      -- By succ_orbit_convex: ∃ j ≤ n, s^[j](a) = b.
      exact (succ_orbit_convex fc A h_mcs h_discrete a b n (le_of_lt hab_lt) hn).imp
        fun j ⟨_, hj⟩ => hj

/-! ## Collapse-Based Discrete Pipeline

When U(T,bot) is present in all domain MCS's, the limit domain has an immediate
successor for each point. `IsSuccArchimedean` (via the axiom
`limitDomSubtype_isSuccArchimedean_axiom`, task 155) asserts that finitely many
succ steps reach any larger element. `succ_embed_surjective` follows from
`IsSuccArchimedean` via `succ_orbit_convex`.

The collapse equivalence below (succ-reachability) is used in auxiliary proofs.
`succ_embed_surjective` now uses the axiom directly; no `sorryAx` in this chain.
-/

-- ARCHIVED from ChronicleToCountermodel.lean lines 390-412 (task 302)
-- Reason: z1 helpers — private, unused after gap elimination moved to model surgery

/-! ## Z1 Derivation and Gap Elimination Helpers

The Z1 schema `G(Gφ→φ) → (FGφ→Gφ)` is derivable from Prior-UZ + BX axioms.
Once derived, `theorem_in_mcs` places Z1 in every MCS, enabling the Doets
maximum principle argument for gap elimination in `succ_cofinal`.
-/

/-- Z1 formula: `G(Gφ→φ) → (FGφ→Gφ)`.
The syntactic correspondent of the IsSuccArchimedean frame condition. -/
private def z1_formula (φ : Formula) : Formula :=
  (φ.all_future.imp φ).all_future.imp (φ.all_future.some_future.imp φ.all_future)

/-- Z1 derivation: `⊢[fc] G(Gφ→φ) → (FGφ→Gφ)`.
Requires `FrameClass.Discrete <= fc` since z1 has minFrameClass = .Discrete. -/
private def z1_derivation (fc : FrameClass) (h_fc : FrameClass.Discrete <= fc) (φ : Formula) :
    DerivationTree fc [] (z1_formula φ) :=
  DerivationTree.axiom [] _ (Axiom.z1 φ) h_fc

/-- Z1 is in every MCS: if S is maximal consistent (for fc >= Discrete), then `z1_formula φ ∈ S`. -/
private theorem z1_in_mcs (fc : FrameClass) (h_fc : FrameClass.Discrete <= fc) (φ : Formula) {S : Set Formula}
    (h_mcs : SetMaximalConsistent (fc := fc) S) :
    z1_formula φ ∈ S :=
  theorem_in_mcs h_mcs (z1_derivation fc h_fc φ)
