import FormalSystem.Metalogic.WeakCanonical.NEquivalence
import FormalSystem.Metalogic.Core.MaximalConsistent
import FormalSystem.Metalogic.Core.MCSProperties
import FormalSystem.Metalogic.Bundle.TemporalContent
import FormalSystem.Metalogic.Bundle.WitnessSeed
import FormalSystem.Metalogic.Bundle.CanonicalFrame
import FormalSystem.Syntax.Formula
import FormalSystem.Theorems.GeneralizedNecessitation
import FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodelBasic
import FormalSystem.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery

/-!
# ARCHIVED (Boneyard) — never compiled.

Singleton dead sorried declarations: 3 independent declarations from 3 different
files, carrying 4 statement-position sorries total, each with zero code consumers
(verified by fresh word-boundary grep at excision time).

From `Metalogic/WeakCanonical/OrderedSum.lean`:
- `doets_lemma_1_5` (1 sorry) — type-matching ordered-sum k-equivalence
  (Doets 1989 Lemma 1.5). Not on the discrete completeness critical path;
  bypassed in the discrete case by the one_class argument. Required only for
  the dense case (future work). The live `doets_lemma_1_4` is NOT part of this
  excision and remains in live code.

From `Metalogic/BXCanonical/Frame.lean`:
- `bx_le_refl` (1 sorry) — reflexivity of the canonical temporal ordering.
  Under irreflexive semantics `bx_le` is NOT reflexive (G(φ) → φ is no longer
  valid), so the statement is unprovable as stated.

From `Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`:
- `succ_reaches_dom_N` (2 sorries) — dead BX pipeline stage induction. The
  boundary cases (new point above max(dom(N)) or below min(dom(N))) are
  irresolvable because the limit-level successor may not appear until an
  arbitrarily later stage. Superseded by the Reynolds pipeline; it was the
  first declaration in its file and orphans nothing.

Do not import from live code.
-/

#exit

/- ======================================================================
   Source: Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean
   Original context: `namespace Bimodal.Metalogic.WeakCanonical`.
   ====================================================================== -/

/-! ## Doets Lemma 1.5 (Type-Matching Variant) -/

/--
Doets Lemma 1.5: If two ordered sums have matching k-type distributions,
they are k-equivalent.

**Status**: Sorried. Not on discrete completeness critical path.
Required only for dense case (future work). Bypassed in the discrete case
by the one_class argument.
-/
theorem doets_lemma_1_5 (sig : MonadicSignature) (k : Nat) (I J : Type)
    [LinearOrder I] [LinearOrder J]
    (m : I → OrderedMonadicStructure sig) (m' : J → OrderedMonadicStructure sig)
    (_h_matching : ∀ (τ : KType sig k),
      (∃ i, k_type_of sig k (m i) = τ) ↔ (∃ j, k_type_of sig k (m' j) = τ)) :
    k_equiv sig k (orderedSum sig I m) (orderedSum sig J m') := by
  sorry

/- ======================================================================
   Source: Theories/Bimodal/Metalogic/BXCanonical/Frame.lean
   Original context: `namespace Bimodal.Metalogic.BXCanonical`,
   `open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Metalogic.Core
   Bimodal.Metalogic.Bundle Bimodal.Theorems`.
   ====================================================================== -/

/-! ## Reflexivity (from BX1: G(φ) → φ) -/

/--
The canonical ordering is reflexive: w ≤ w for all BXPoints.
-/
theorem bx_le_refl (w : BXPoint) : bx_le w w := by
  -- Under irreflexive semantics, bx_le is NOT reflexive.
  -- G(φ) → φ is no longer valid.
  sorry

/- ======================================================================
   Source: Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean
   Original context: `namespace Bimodal.Metalogic.BXCanonical.Chronicle`,
   `open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Metalogic.Core
   Bimodal.Metalogic.Bundle Bimodal.Metalogic.Algebraic.ParametricCanonical
   Bimodal.Metalogic.Algebraic.ParametricHistory
   Bimodal.Metalogic.Algebraic.ParametricTruthLemma
   Bimodal.Metalogic.Algebraic.ParametricCompleteness
   Bimodal.Metalogic.Algebraic.RestrictedParametricTruthLemma
   Bimodal.Semantics Bimodal.Theorems.Propositional
   Bimodal.Theorems.Combinators Bimodal.Theorems.Perpetuity
   Bimodal.Metalogic.BXCanonical Classical`.
   ====================================================================== -/

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
          -- Resolution: the Henkin-model route or the Reynolds pipeline.
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
          -- Resolution: the Henkin-model route or the Reynolds pipeline.
          -- See Boneyard/StageInductionGapAnalysis/ for related archived analysis.
          sorry
      · -- Case 4: both new at stage N+1.
        -- omega_chain_dom_new_unique gives a.val = b.val, hence a = b.
        have ha_new : a.val ∈ (omega_chain_val fc A h_mcs (N + 1)).dom := ha
        have hb_new : b.val ∈ (omega_chain_val fc A h_mcs (N + 1)).dom := hb
        have := omega_chain_dom_new_unique fc A h_mcs N a.val b.val ha_new ha_old hb_new hb_old
        exact ⟨0, Subtype.ext this⟩
