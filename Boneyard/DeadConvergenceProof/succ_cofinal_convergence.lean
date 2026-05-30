/-!
# ARCHIVED: Dead Convergence Proof for succ_cofinal

This file contains the dead convergence proof attempt that was previously inlined
in the `succ_cofinal` theorem body in ChronicleToCountermodel.lean (lines 1557-1885).

The approach attempted to prove `succ_cofinal` by showing that the successor orbit
{s^[n](a)} converges to a limit L in ℝ, then deriving a contradiction using temporal
logic axioms (Z1, Prior-UZ, c5_strong). However, in the "constant MCS" case (all
limit_dom points have identical MCS labels), no discriminating formula exists, and
the temporal logic axioms are trivially satisfied.

Three gap elimination approaches were evaluated:
(a) Prior-SZ maximum principle with a discriminating formula
(b) Syntactic Z1 derivation tree from Prior-UZ
(c) Stage-induction on the omega-chain construction

All three face the same fundamental difficulty in the constant-MCS case.

**Resolution**: Plan v9 (task 202) takes the hybrid approach:
  no_gaps_discrete (Reynolds Theorem 14, Lemmas 6-13) -> one_class -> succ_cofinal
This closes Path A (the parametric canonical model) without needing the convergence
argument.

**Archived**: 2026-05-29 (task 202, Phase 0)
-/

-- Original theorem signature (for reference):
-- private theorem succ_cofinal (fc : FrameClass) (A : Set Formula)
--     (h_mcs : SetMaximalConsistent (fc := fc) A)
--     (h_discrete : ∀ x ∈ limit_dom fc A h_mcs, next_top ∈ limit_f fc A h_mcs x)
--     (a b : LimitDomSubtype fc A h_mcs) (hab : a < b) :
--     ∃ n, b ≤ (limitDomSubtype_succ fc A h_mcs h_discrete)^[n] a := by

-- BEGIN ARCHIVED PROOF BODY (329 lines)
  set s := limitDomSubtype_succ fc A h_mcs h_discrete
  by_contra h_not_cofinal
  push_neg at h_not_cofinal
  -- h_not_cofinal: ∀ n, s^[n](a) < b
  -- Step 1: s^[n](a) ≤ pred(b) for all n
  set pb := limitDomSubtype_pred fc A h_mcs h_discrete b
  have h_le_pb : ∀ n, s^[n] a ≤ pb :=
    fun n => (limitDomSubtype_le_pred_iff fc A h_mcs h_discrete _ b).mpr (h_not_cofinal n)
  -- Step 2: Define the real-valued sequence and show it converges
  set f : ℕ → ℝ := fun n => (s^[n] a).val
  have s_lt : ∀ x : LimitDomSubtype fc A h_mcs, x < s x :=
    fun x => (limitDomSubtype_succ_le_iff fc A h_mcs h_discrete x (s x)).mp le_rfl
  have f_mono : Monotone f := by
    intro m n hmn
    simp only [f]
    apply Rat.cast_le.mpr
    obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hmn
    clear hmn; induction k with
    | zero => simp
    | succ k ih =>
      have h_step : (s^[m + k] a).val < (s (s^[m + k] a)).val := s_lt _
      have h_eq : (s (s^[m + k] a)).val = (s^[m + (k + 1)] a).val := by
        congr 1; rw [show m + (k + 1) = (m + k) + 1 from by omega,
          Function.iterate_succ', Function.comp_apply]
      exact le_of_lt (lt_of_le_of_lt ih (h_eq ▸ h_step))
  have f_bdd : BddAbove (Set.range f) := by
    refine ⟨(b.val : ℝ), ?_⟩
    rintro _ ⟨n, rfl⟩
    exact Rat.cast_le.mpr (le_of_lt (h_not_cofinal n))
  -- The sequence converges to some limit
  obtain ⟨L, hL_tendsto⟩ := Real.tendsto_of_bddAbove_monotone f_bdd f_mono
  -- L is an upper bound for all f(n)
  have hL_ub : ∀ n, f n ≤ L := by
    intro n
    exact le_of_tendsto_of_tendsto tendsto_const_nhds hL_tendsto
      (Filter.eventually_atTop.mpr ⟨n, fun m hm => f_mono hm⟩)
  -- L ≤ b.val (since all f(n) < b.val and L is the limit)
  have hL_le_b : L ≤ (b.val : ℝ) := by
    exact le_of_tendsto_of_tendsto hL_tendsto tendsto_const_nhds
      (Filter.Eventually.of_forall fun n => Rat.cast_le.mpr (le_of_lt (h_not_cofinal n)))
  -- Step 3: L > pred(b).val (the key step)
  -- We prove this by showing the first limit_dom point ≥ L has its predecessor
  -- as a succ-iterate, forcing L to be in limit_dom.
  -- First, show that pred(b).val < b.val in ℝ
  have h_pb_lt_b : (pb.val : ℝ) < (b.val : ℝ) := by
    exact Rat.cast_lt.mpr (limitDomSubtype_pred_lt fc A h_mcs h_discrete b)
  -- Now: if L > pred(b).val, get contradiction directly
  -- if L ≤ pred(b).val, get contradiction via the "first limit_dom ≥ L" argument
  -- For the full formal proof, we combine both into one argument.
  -- The "first limit_dom point ≥ L" is b (since L ≤ b.val).
  -- pred(b) < b. pred(b).val < b.val ≤ L? Or pred(b).val ≥ L?
  -- Case split:
  by_cases h_case : L > (pb.val : ℝ)
  · -- L > pred(b).val. Since f(n) → L and pred(b).val < L:
    -- eventually f(n) > pred(b).val.
    have := Filter.Tendsto.eventually_const_lt h_case hL_tendsto
    rw [Filter.eventually_atTop] at this
    obtain ⟨n₀, hn₀⟩ := this
    specialize hn₀ n₀ le_rfl
    -- f(n₀) > pred(b).val, i.e., s^[n₀](a).val > pred(b).val
    have h_gt_pb : pb < s^[n₀] a := by
      show pb.val < (s^[n₀] a).val
      exact Rat.cast_lt.mp hn₀
    -- But s^[n₀](a) ≤ pb from h_le_pb. Contradiction!
    exact absurd (h_le_pb n₀) (not_le.mpr h_gt_pb)
  · -- L ≤ pred(b).val. The sequence is bounded by pred(b).val.
    push_neg at h_case
    -- h_case: L ≤ pred(b).val
    -- All f(n) ≤ L ≤ pred(b).val < b.val. s^[n](a) ≤ pred(b).
    -- s^[n](a) ≠ pred(b) (otherwise s^[n+1](a) = succ(pred(b)) = b).
    have h_ne_pb : ∀ n, s^[n] a ≠ pb := by
      intro n h_eq
      have : s^[n + 1] a = b := by
        rw [Function.iterate_succ', Function.comp_apply, h_eq]
        exact limitDomSubtype_succ_pred fc A h_mcs h_discrete b
      exact absurd this (ne_of_lt (h_not_cofinal (n + 1)))
    -- Step 4: All orbit points are strictly below pb.
    have h_lt_pb : ∀ n, s^[n] a < pb :=
      fun n => lt_of_le_of_ne (h_le_pb n) (h_ne_pb n)
    -- Step 5: Any limit_dom point c with a ≤ c and c.val < L is an orbit point.
    -- Proof: f(n) → L, so eventually f(n) > c.val, giving c < s^[n](a).
    -- By orbit convexity, c = s^[k](a).
    have orbit_below_L : ∀ c : LimitDomSubtype fc A h_mcs,
        a ≤ c → (c.val : ℝ) < L →
        ∃ m, s^[m] a = c := by
      intro c hac hcL
      have : ∃ n₀, (c.val : ℝ) < f n₀ := by
        by_contra h_all
        push_neg at h_all
        -- f n ≤ c.val for all n, but f → L and L > c.val. Contradiction.
        have : L ≤ (c.val : ℝ) :=
          le_of_tendsto_of_tendsto hL_tendsto tendsto_const_nhds
            (Filter.Eventually.of_forall fun n => h_all n)
        linarith
      obtain ⟨n₀, hn₀⟩ := this
      have hc_le : c ≤ s^[n₀] a := by
        show c.val ≤ (s^[n₀] a).val
        exact_mod_cast le_of_lt (Rat.cast_lt.mp hn₀)
      exact (succ_orbit_convex fc A h_mcs h_discrete a c n₀ hac hc_le).imp
        fun k ⟨_, hk⟩ => hk
    -- Step 6: Define pred-chain g(k) = pred^[k](pb). Show all orbit points < g(k).
    set p := limitDomSubtype_pred fc A h_mcs h_discrete with p_def
    -- g(k) = p^[k](pb) is the k-th predecessor starting from pb
    -- Key: ∀ k n, s^[n] a < p^[k] pb
    -- Proved by induction on k:
    --   Base: h_lt_pb says s^[n] a < pb = p^[0] pb. ✓
    --   Step: if ∀ n, s^[n] a < p^[k] pb, then:
    --     s^[n] a ≤ p(p^[k] pb) (by le_pred_iff)
    --     s^[n] a ≠ p(p^[k] pb) (otherwise s^[n+1] a = succ(pred(...)) = p^[k] pb,
    --       contradicting s^[n+1] a < p^[k] pb)
    --     So s^[n] a < p^[k+1] pb. ✓
    have h_lt_pred_chain : ∀ k n, s^[n] a < p^[k] pb := by
      intro k
      induction k with
      | zero => simp only [Function.iterate_zero, id_eq]; exact h_lt_pb
      | succ k ih =>
        intro n
        have h_le : s^[n] a ≤ p^[k + 1] pb := by
          rw [Function.iterate_succ', Function.comp_apply]
          exact (limitDomSubtype_le_pred_iff fc A h_mcs h_discrete _ _).mpr (ih n)
        have h_ne : s^[n] a ≠ p^[k + 1] pb := by
          intro h_eq
          rw [Function.iterate_succ', Function.comp_apply] at h_eq
          have h_succ_eq : s^[n + 1] a = p^[k] pb := by
            rw [Function.iterate_succ', Function.comp_apply, h_eq]
            exact limitDomSubtype_succ_pred fc A h_mcs h_discrete (p^[k] pb)
          exact absurd h_succ_eq (ne_of_lt (ih (n + 1)))
        exact lt_of_le_of_ne h_le h_ne
    -- Step 7: pred-chain values are strictly decreasing
    have h_pred_chain_strict : ∀ k, (p^[k + 1] pb).val < (p^[k] pb).val := by
      intro k
      rw [Function.iterate_succ', Function.comp_apply]
      exact limitDomSubtype_pred_lt fc A h_mcs h_discrete (p^[k] pb)
    -- Step 8: All pred-chain values ≥ L (since orbit values → L and orbit < pred-chain)
    have h_pred_chain_ge_L : ∀ k, L ≤ ((p^[k] pb).val : ℝ) := by
      intro k
      exact le_of_tendsto_of_tendsto hL_tendsto tendsto_const_nhds
        (Filter.Eventually.of_forall fun n =>
          Rat.cast_le.mpr (le_of_lt (h_lt_pred_chain k n)))
    -- Step 9: Gap elimination via backward G truth lemma.
    -- Key insight: the backward G truth lemma (if ψ ∈ limit_f(y) for ALL
    -- y > x, then G(ψ) ∈ limit_f(x)) can be proved using limit_F_resolution
    -- alone (no IsSuccArchimedean needed), breaking the circularity.
    --
    -- Backward G truth lemma:
    -- If ψ ∈ limit_f(y) for all y > x in limit_dom, then G(ψ) ∈ limit_f(x).
    have backward_G : ∀ (ψ : Formula) (x : LimitDomSubtype fc A h_mcs),
        (∀ y : LimitDomSubtype fc A h_mcs, x < y → ψ ∈ limit_f fc A h_mcs y.val) →
        ψ.all_future ∈ limit_f fc A h_mcs x.val := by
      intro ψ x h_all
      by_contra h_not
      have h_mcs_x := limit_c0 fc A h_mcs x.val x.property
      -- ¬G(ψ) ∈ limit_f(x) by negation completeness
      have h_neg : (ψ.all_future).neg ∈ limit_f fc A h_mcs x.val :=
        (SetMaximalConsistent.negation_complete h_mcs_x ψ.all_future).resolve_left h_not
      -- Build derivation: ⊢ ψ.neg.neg → ψ (double negation elimination)
      have h_dne : DerivationTree fc [] (ψ.neg.neg.imp ψ) :=
        Bimodal.Theorems.Propositional.double_negation ψ
      -- Temporal necessitation: ⊢ G(ψ.neg.neg → ψ)
      have h_G_dne : DerivationTree fc [] (Formula.all_future (ψ.neg.neg.imp ψ)) :=
        DerivationTree.temporal_necessitation _ h_dne
      -- K-distribution: ⊢ G(ψ.neg.neg → ψ) → (G(ψ.neg.neg) → G(ψ))
      have h_dist : DerivationTree fc [] ((ψ.neg.neg.imp ψ).all_future.imp
          (ψ.neg.neg.all_future.imp ψ.all_future)) :=
        liftBase fc (Bimodal.Theorems.TemporalDerived.temp_k_dist_derived ψ.neg.neg ψ)
      -- Modus ponens: ⊢ G(ψ.neg.neg) → G(ψ)
      have h_G_impl : DerivationTree fc [] (ψ.neg.neg.all_future.imp ψ.all_future) :=
        DerivationTree.modus_ponens [] _ _ h_dist h_G_dne
      -- Contrapositive: ⊢ ¬G(ψ) → ¬G(ψ.neg.neg)
      -- Note: ¬G(ψ.neg.neg) = (ψ.neg.neg.all_future).neg = F(ψ.neg)  (definitionally)
      have h_contra : DerivationTree fc [] (ψ.all_future.neg.imp ψ.neg.neg.all_future.neg) := by
        have h_cp := liftBase fc (Bimodal.Theorems.TemporalDerived.contrapositive
          ψ.neg.neg.all_future ψ.all_future)
        exact DerivationTree.modus_ponens [] _ _ h_cp h_G_impl
      -- Apply in MCS: F(ψ.neg) ∈ limit_f(x)
      -- F(ψ.neg) = ψ.neg.some_future = ψ.neg.neg.all_future.neg  (by definition)
      -- ¬G(¬¬ψ) = neg(all_future ψ.neg.neg) ∈ limit_f(x) from h_contra and h_neg
      have h_neg_G : (Formula.all_future ψ.neg.neg).neg ∈ limit_f fc A h_mcs x.val :=
        SetMaximalConsistent.implication_property h_mcs_x
          (theorem_in_mcs h_mcs_x h_contra) h_neg
      -- Derive F(¬ψ) from ¬G(¬¬ψ) via duality
      -- ¬G(¬¬ψ) means G(¬¬ψ) ∉ x, then by negation completeness + bridge, F(¬ψ) ∈ x
      have h_G_nn_not : Formula.all_future ψ.neg.neg ∉ limit_f fc A h_mcs x.val :=
        SetMaximalConsistent.neg_excludes h_mcs_x _ h_neg_G
      have h_F_neg : Formula.some_future ψ.neg ∈ limit_f fc A h_mcs x.val := by
        rcases SetMaximalConsistent.negation_complete h_mcs_x (Formula.some_future ψ.neg) with h | h
        · exact h
        · have h_G := Bundle.neg_some_future_to_all_future_neg h_mcs_x ψ.neg h
          exact absurd h_G h_G_nn_not
      -- By limit_F_resolution: ∃ y > x with ψ.neg ∈ limit_f(y)
      obtain ⟨y, hy_dom, hxy, h_neg_y⟩ :=
        limit_F_resolution fc A h_mcs x.val x.property ψ.neg h_F_neg
      -- But ψ ∈ limit_f(y) by hypothesis (y > x in limit_dom)
      have h_psi_y : ψ ∈ limit_f fc A h_mcs y :=
        h_all ⟨y, hy_dom⟩ hxy
      -- Contradiction: ψ and ψ.neg both in limit_f(y)
      exact set_consistent_not_both (limit_c0 fc A h_mcs y hy_dom).1 ψ h_psi_y h_neg_y
    -- Backward F: if φ ∈ limit_f(y) for some y > x, then F(φ) ∈ limit_f(x).
    -- Proof: if G(¬φ) ∈ limit_f(x), forward_G gives ¬φ ∈ limit_f(y), contradicting φ.
    -- So G(¬φ) ∉ limit_f(x), hence ¬G(¬φ) = F(φ) ∈ limit_f(x).
    have backward_F : ∀ (φ : Formula) (x : LimitDomSubtype fc A h_mcs)
        (y : LimitDomSubtype fc A h_mcs) (_ : x < y)
        (_ : φ ∈ limit_f fc A h_mcs y.val),
        Formula.some_future φ ∈ limit_f fc A h_mcs x.val := by
      intro φ x y hxy hφy
      have h_mcs_x := limit_c0 fc A h_mcs x.val x.property
      -- F(φ) = φ.neg.all_future.neg (definitionally)
      -- ¬G(¬φ) = (φ.neg.all_future).neg = φ.neg.all_future.neg = F(φ)
      -- So it suffices to show G(φ.neg) ∉ limit_f(x)
      by_contra h_not_F
      -- ¬F(φ) ∈ limit_f(x), meaning G(φ.neg) ∈ limit_f(x)
      -- show: G(φ.neg) = φ.neg.all_future ∈ limit_f(x)
      have h_G_neg : φ.neg.all_future ∈ limit_f fc A h_mcs x.val := by
        -- ¬F(φ) ∈ limit_f(x), derive G(¬φ) via duality bridge
        have h_neg_F : (Formula.some_future φ).neg ∈ limit_f fc A h_mcs x.val :=
          (SetMaximalConsistent.negation_complete h_mcs_x _).resolve_left h_not_F
        exact Bundle.neg_some_future_to_all_future_neg h_mcs_x φ h_neg_F
      -- By forward_G: φ.neg ∈ limit_f(y)
      have h_neg_y := limit_forward_G fc A h_mcs x.val y.val x.property y.property hxy
        φ.neg h_G_neg
      -- Contradiction: φ and φ.neg both in limit_f(y)
      exact set_consistent_not_both (limit_c0 fc A h_mcs y.val y.property).1 φ hφy h_neg_y
    -- Step 9: Gap elimination (L ≤ pred(b).val).
    --
    -- The orbit {s^[n](a)} converges to L from below, the pred-chain
    -- {pred^[k](pb)} forms a strictly decreasing sequence with values ≥ L.
    -- All orbit points < all pred-chain points. The orbit and pred-chain
    -- are succ/pred-closed respectively, forming disconnected components.
    --
    -- Available infrastructure for the gap elimination:
    -- • backward_G: ψ at all y > x ⟹ G(ψ) ∈ limit_f(x)
    -- • backward_F: φ at y > x ⟹ F(φ) ∈ limit_f(x)
    -- • backward_P (proved below): φ at y < x ⟹ P(φ) ∈ limit_f(x)
    -- • limit_F_resolution, limit_P_resolution: resolve F/P to witnesses
    -- • limit_satisfies_c5_strong, c5'_strong: resolve U/S with guards
    -- • Axiom.prior_UZ/SZ: F(φ) → U(φ,¬φ), P(φ) → S(φ,¬φ)
    -- • theorem_in_mcs: derivable formulas are in every MCS
    -- • orbit_below_L: limit_dom points with a ≤ c and c.val < L are orbit
    -- • h_lt_pred_chain: all orbit < all pred-chain
    -- • h_pred_chain_ge_L: pred-chain ℝ-values ≥ L
    --
    -- The gap elimination requires showing that the disconnected orbit +
    -- pred-chain structure contradicts the temporal logic axioms. The core
    -- difficulty is finding a discriminating formula (one that holds at all
    -- orbit points but fails at some non-orbit point, or vice versa).
    --
    -- Three approaches were evaluated:
    -- (a) Prior-SZ maximum principle with a discriminating formula
    -- (b) Syntactic Z1 derivation tree from Prior-UZ (~100 lines, no
    --     published derivation exists)
    -- (c) Stage-induction on the omega-chain construction
    --
    -- All three approaches face the same fundamental difficulty: in the
    -- "constant MCS" case (all limit_dom points have identical MCS labels),
    -- no discriminating formula exists, and the temporal logic axioms are
    -- trivially satisfied. The contradiction in this case must come from
    -- properties of the omega-chain construction itself (each new point
    -- resolves a specific counterexample with a specific MCS, and constant
    -- MCS everywhere conflicts with the counterexample resolution process).
    -- Formalizing this requires deep interaction with the construction
    -- internals (omega_chain_elim_result, BurgessR3Maximal, etc.).
    --
    -- Status: This sorry represents a genuine mathematical gap in the
    -- formalization. The theorem is mathematically true (IsSuccArchimedean
    -- holds for the limit domain in the discrete case), but the formal
    -- proof requires either a Z1 derivation tree, a deep construction
    -- argument, or adding Z1 as an axiom with a soundness proof.
    --
    -- Backward P (dual of backward_F): proved and available for future use.
    -- If φ ∈ limit_f(y) for y < x, then P(φ) ∈ limit_f(x).
    have _backward_P : ∀ (φ : Formula) (x y : LimitDomSubtype fc A h_mcs),
        y < x → φ ∈ limit_f fc A h_mcs y.val →
        Formula.some_past φ ∈ limit_f fc A h_mcs x.val := by
      intro φ x y hyx hφy
      have h_mcs_x := limit_c0 fc A h_mcs x.val x.property
      by_contra h_not_P
      have h_H_neg : φ.neg.all_past ∈ limit_f fc A h_mcs x.val := by
        have h_neg_P : (Formula.some_past φ).neg ∈ limit_f fc A h_mcs x.val :=
          (SetMaximalConsistent.negation_complete h_mcs_x _).resolve_left h_not_P
        exact Bundle.neg_some_past_to_all_past_neg h_mcs_x φ h_neg_P
      have h_neg_y := limit_backward_H fc A h_mcs x.val y.val x.property y.property hyx
        φ.neg h_H_neg
      exact set_consistent_not_both (limit_c0 fc A h_mcs y.val y.property).1 φ hφy h_neg_y
    -- Step 9: Gap elimination.
    --
    -- The orbit {s^[n](a)} converges to L from below, the pred-chain
    -- {p^[k](pb)} has values ≥ L (strictly decreasing). All orbit < all
    -- pred-chain. The gap creates a ℤ+ℤ-like structure.
    --
    -- Available tools: backward_G, backward_F, _backward_P, z1_in_mcs,
    -- orbit_below_L, h_lt_pred_chain, limit_F_resolution, limit_forward_G.
    --
    -- Approaches investigated (task 153):
    --
    -- (1) Prior-UZ + c5_strong ("constant-MCS exclusion"):
    --     F(φ) at orbit point → U(φ, ¬φ) at orbit point (Prior-UZ).
    --     c5_strong gives witness y with φ at y and ¬φ at intermediates.
    --     FAILS: in the discrete case, y = succ(x) with no intermediates,
    --     so the guard ¬φ is vacuously satisfied. No contradiction.
    --
    -- (2) Z1 (Doets maximum principle):
    --     Z1 = G(Gφ→φ) → (FGφ → Gφ). In strict (irreflexive) semantics,
    --     G(Gφ→φ) at orbit point x requires Gφ→φ at all strictly future
    --     points. In the constant-MCS case, this is trivially satisfied
    --     (both Gφ and φ in every MCS), so Z1 gives no information.
    --     In the non-constant case, controlling φ truth at ALL future
    --     points (not just orbit/pred-chain) is the unsolved difficulty.
    --
    -- (3) Gap point analysis: if a limit_dom point c exists with value
    --     ≥ L and below all pred-chain points, then pred(c) is either
    --     an orbit point (giving c = succ(orbit) = next orbit, but
    --     orbit values < L ≤ c.val, contradiction) or another gap point
    --     (infinite descent). The descent produces a strictly decreasing
    --     sequence of gap rationals bounded below by L, which converges
    --     but does not yield a contradiction with current tools.
    --
    -- Conclusion: the gap scenario is consistent with all temporal axioms
    -- (Z1, Prior-UZ, c5) under strict semantics in the constant-MCS case.
    -- Resolution requires either:
    -- (a) A construction-level argument showing the omega-chain cannot
    --     produce a gap (deep interaction with omega_chain_elim_result),
    -- (b) The task 129 approach: weak/reflexive completeness + conservative
    --     extension, which provides IsSuccArchimedean via a Henkin model
    --     that avoids the gap entirely, OR
    -- (c) The Reynolds pipeline (tasks 154-155) which bypasses this sorry.
    -- DEAD APPROACH: convergence/stage-induction gap analysis for succ_cofinal.
    -- Resolution: task 129 (Henkin model) or Reynolds pipeline (tasks 154-155).
    -- See Boneyard/StageInductionGapAnalysis/ for related archived analysis.
    sorry

-- END ARCHIVED PROOF BODY
-- (End of succ_cofinal proof — resolution: task 129 or Reynolds pipeline.)
