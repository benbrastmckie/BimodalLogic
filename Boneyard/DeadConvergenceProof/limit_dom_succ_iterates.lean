/-!
# ARCHIVED: limit_dom_points_are_succ_iterates

This file contains the dead helper theorem that was previously inlined in
ChronicleToCountermodel.lean (lines ~1458-1508).

The theorem attempted to prove that every limit_dom point in [a, z] is a
succ-iterate of a when all succ-iterates of a are <= z. The proof used an
infinite-descent argument but was ultimately stuck on the same convergence
gap as succ_cofinal.

This helper was only used by the dead convergence proof inside succ_cofinal.
It is not needed by the plan v9 approach (derive succ_cofinal from one_class).

**Archived**: 2026-05-29 (task 202, Phase 0)
-/

/--
Every limit_dom point in `[a.val, L)` for a limit_dom point `a` is a succ-iterate
of `a`, where `L` is any upper bound such that all succ-iterates are below `L`.

Key step: if `z ∈ limit_dom` with `a.val ≤ z.val` and `z.val < succ^[n](a).val` for
no `n`, then `z.val ≥ succ^[n](a).val` for all `n`, contradicting `z.val < L`.
If `succ^[n₀](a) > z` for some `n₀`: take minimum; then `z` is between consecutive
succ-iterates, contradicting the immediate-successor property.
-/
private theorem limit_dom_points_are_succ_iterates (fc : FrameClass)
    (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ limit_dom fc A h_mcs, next_top ∈ limit_f fc A h_mcs x)
    (a z : LimitDomSubtype fc A h_mcs) (h_az : a ≤ z)
    (h_all_below : ∀ n, (limitDomSubtype_succ fc A h_mcs h_discrete)^[n] a ≤ z) :
    ∃ m, (limitDomSubtype_succ fc A h_mcs h_discrete)^[m] a = z := by
  set s := limitDomSubtype_succ fc A h_mcs h_discrete
  -- For each n, either s^[n](a) = z, or s^[n](a) < z or s^[n](a) > z.
  -- But h_all_below says s^[n](a) ≤ z. So s^[n](a) ≤ z.
  -- If s^[n](a) = z for some n: done.
  by_contra h_never
  push_neg at h_never
  -- h_never : ∀ m, s^[m] a ≠ z
  -- Combined with h_all_below: s^[m](a) < z for all m.
  have h_strict : ∀ m, s^[m] a < z := by
    intro m; exact lt_of_le_of_ne (h_all_below m) (h_never m)
  -- Since s^[m](a) < z for all m: s^[m](a) ≤ pred(z) for all m.
  have h_le_pred : ∀ m, s^[m] a ≤ limitDomSubtype_pred fc A h_mcs h_discrete z :=
    fun m => (limitDomSubtype_le_pred_iff fc A h_mcs h_discrete _ z).mpr (h_strict m)
  -- Now: s^[m](a) ≤ pred(z). And pred(z) < z.
  -- s^[m](a) ≠ pred(z) for all m (otherwise s^[m+1](a) = succ(pred(z)) = z by succ_pred).
  have h_ne_pred : ∀ m, s^[m] a ≠ limitDomSubtype_pred fc A h_mcs h_discrete z := by
    intro m h_eq
    have : s^[m + 1] a = z := by
      rw [Function.iterate_succ', Function.comp_apply, h_eq]
      exact limitDomSubtype_succ_pred fc A h_mcs h_discrete z
    exact h_never (m + 1) this
  -- So s^[m](a) < pred(z) for all m.
  have h_strict_pred : ∀ m, s^[m] a < limitDomSubtype_pred fc A h_mcs h_discrete z :=
    fun m => lt_of_le_of_ne (h_le_pred m) (h_ne_pred m)
  -- But now: s^[m](a) < pred(z) for all m. pred(z) < z. So all succ iterates are ≤ pred(z).
  -- Apply the same argument to pred(z): s^[m](a) ≤ pred(pred(z)) for all m, etc.
  -- This gives an infinite descent on z, pred(z), pred^2(z), ...
  -- But we also know s(a) > a (succ is strictly increasing). So s^[m](a) is strictly increasing.
  -- And s^[m](a) < pred(z) for all m. The sequence s^[m](a).val is strictly increasing
  -- in ℚ, bounded by pred(z).val.
  -- Casting to ℝ and using convergence, the limit is L ≤ pred(z).val < z.val.
  -- The first limit_dom point ≥ L (in ℝ) has a predecessor which is a succ-iterate.
  -- This gives a succ-iterate equal to a value ≥ L, contradicting all being < pred(z).
  -- For now we defer to succ_reaches_dom_N for this step.
  -- Actually, let's derive the contradiction directly:
  -- pred(z) is limit_dom. All succ iterates of a are strictly below pred(z).
  -- Apply THIS LEMMA recursively to (a, pred(z)): all succ iterates ≤ pred(z),
  -- and all are ≠ pred(z), so all < pred(z), so all ≤ pred(pred(z)), etc.
  -- This is infinite descent on z → pred(z) → pred^2(z) → ...
  -- But z can decrease indefinitely (NoMinOrder), so we need another argument.
  -- Use the real analysis approach instead.
  -- DEAD APPROACH: convergence/stage-induction for limit_dom_points_are_succ_iterates.
  -- Resolution: task 129 (Henkin model) or Reynolds pipeline (tasks 154-155).
  -- See Boneyard/StageInductionGapAnalysis/ for related archived analysis.
  sorry

-- END ARCHIVED CODE
