# Phase 7 Handoff: Build Fixes + Helper Lemmas Proved

**Date**: 2026-05-17T23:30Z
**Session**: sess_1779050716_7a0566
**Status**: PARTIAL - Build partially fixed, helper lemmas proved, atom_elim_correct remains

## Summary of Changes This Session

### Build Fixes (Pre-existing Issues from Previous Agent)

The HEAD commit (`8bb4e5ded`) does NOT build (20 errors). The previous agent committed broken code. This session fixed:

1. **`List.mem_cons_self` / `List.mem_cons_of_mem` API changes**: These lemmas no longer take explicit arguments in current Lean 4.27.0-rc1. Fixed by using `List.mem_cons.mpr (Or.inl rfl)` and `List.mem_cons.mpr (Or.inr hmem)` respectively.

2. **`List.mem_map_of_mem` API change**: Fixed by using `List.mem_map.mpr ⟨elem, proof, rfl⟩`.

3. **`String.get` deprecation**: The `s.get ⟨0, by omega⟩` API is deprecated. Fixed using `s.toList.head!` + `simp` + `decide`.

4. **`box` case in `int_truth_depends_on_atoms`**: `simp only [Separation.int_truth]` closes the goal directly (no `exact Iff.rfl` needed).

### Remaining Pre-existing Build Errors (~10 errors)

All in `expressiveness_inner` (the `.ex` and `.all` cases, lines 1017-1150):
- `String.append_left_cancel` is unknown (renamed/removed in current Lean)
- `tauto` tactic failures
- Type mismatches in the `hB_atoms` proof and `h_base_ne_rec` proof
- These errors existed in the commit from the previous agent and were NOT introduced by this session

### Mathematical Progress

1. **`int_truth_foldl_or` PROVED** (Task 7.4): The analog of `int_truth_foldl_and` for disjunction. Would work but is not exercised because the downstream code doesn't build.

2. **`guardFormula_unique` PROVED** (Task 7.5): Two assignments satisfying the guard must be equal. Proved via `funext` + showing `σ p = true ↔ τ p = true` + case analysis.

3. **`quantElimFormula_iff`**: Framework for reducing quantElimFormula semantics to branch existence. Not fully exercised due to downstream build issues.

## Blocking Issue: `atom_elim_correct` (Task 7.6-7.8)

The core challenge was thoroughly investigated this session. The key findings:

### Why `replaceAtoms` (uniform replacement) DOESN'T WORK

The initial approach tried to define a uniform atom replacement function and prove its correctness via `replaceAtoms_correct`. This fails because:

- `freshAM .lt_ref` represents `z < t` in the extended model
- At time `t` (present level): `lt_ref` is False (since `t < t` is false)
- At time `s < t` (past subformulas): `lt_ref` is True (since `s < t`)
- At time `s > t` (future subformulas): `lt_ref` is False

A SINGLE replacement formula cannot capture all three behaviors simultaneously. The same issue applies to `gt_ref`.

### Why `elimExtFromSep` + `applySubsts` is Hard to Prove

The original `elimExtFromSep` uses DIFFERENT substitution lists at different temporal levels (present, past, future). This is correct but proving it requires:

1. Reasoning about `applySubsts` on sequential substitution lists
2. Showing no double-substitution (via h_disj: atomMap and freshAM ranges are disjoint)
3. Handling the fact that `applySubsts_past_correct` and `applySubsts_future_correct` DON'T directly apply (the h_match condition fails for both M_ext and M_orig)

### Recommended Approach for Next Agent

The correct proof strategy for `atom_elim_correct` is:

1. **Structural induction on `B_sep`** (properly separated formula)
2. **Bot/Box/Imp cases**: Trivial (already shown to work in this session)
3. **Atom case**: Use `hB_atoms` to get `ep`, case-split on `ep`, show `applySubsts (.atom a) subs` finds the right target using `applySubsts_atom_hit`/`applySubsts_atom_miss` lemmas (added this session), and verify the replacement's truth matches `extIntStruct`
4. **Past temporal cases** (`all_past`, `snce`): Define a BRIDGE MODEL that makes `applySubsts_past_correct` applicable. Specifically, construct `M_bridge` where `M_bridge.val (freshAM ep)` is defined to match the past-level substitution semantics.
5. **Future temporal cases** (`all_future`, `untl`): Symmetric to past.

An alternative approach: prove `elimExtFromSep_correct` as a separate theorem using induction on formula structure WITH a parameterized substitution predicate that captures the level-dependent matching.

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` (build fixes + helper lemmas)

## Immediate Next Action

1. Fix the remaining ~10 build errors in `expressiveness_inner` (mostly `String.append_left_cancel` and type mismatches from Lean API changes)
2. Prove `atom_elim_correct` using structural induction with level-aware substitution correctness
3. Close the atom containment sorries (lines 1139, 1217)
