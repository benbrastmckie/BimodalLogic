# Research Report: Task #916

**Task**: Implement F/P Witness Obligation Tracking
**Date**: 2026-02-23
**Focus**: Progress review after context exhaustion during Phase 3 implementation

## Summary

The last implementation agent made substantial progress on Phase 3 (Witness Graph Properties) but ran out of context mid-edit, leaving WitnessGraph.lean with **48 build errors** and **no sorries** syntactically -- because the agent replaced the sorries with attempted proofs that do not compile. The file is NOT imported by any other module, so the full project `lake build` succeeds (1001 jobs), masking these errors. The committed version (9d95c405) has 5 sorries and builds cleanly; the uncommitted working copy has 911 new lines of partially-correct proof code.

## Findings

### 1. Build Status

- **Full project build**: Succeeds (1001 jobs) -- WitnessGraph.lean is not imported by any other file
- **WitnessGraph.lean build**: **FAILS with 48 errors** (`lake build Bimodal.Metalogic.Bundle.WitnessGraph`)
- **Root cause**: The file is an orphan module -- no `import Bimodal.Metalogic.Bundle.WitnessGraph` exists anywhere in the codebase. This means build errors in this file are invisible to `lake build`.

### 2. File State Comparison

| Metric | Committed (9d95c405) | Working Copy |
|--------|---------------------|--------------|
| Lines | 1,578 | 2,489 |
| Sorries | 5 | 0 (syntactically) |
| Build errors | 0 | 48 |
| Builds cleanly? | Yes | **No** |
| Has `end` namespace? | Yes | **No** (missing) |

### 3. What the Last Agent Changed (Uncommitted)

The agent made the following categories of changes:

**a) processStep modification** (correct design change):
- Modified `processStep` to handle the case where F(psi) is already witnessed by falling through to check P(psi). Previously, when `isWitnessed i (.future psi) = true`, the function returned `g` unchanged. Now it checks P(psi) in the same step.
- This correctly addresses the "F-blocks-P" issue identified in plan v007.

**b) Updated all split-proof lemmas** (mostly correct):
- `processStep_nodes_length_ge`, `processStep_node_preserved`, `processStep_edge_preserved` -- all updated to handle the new F-witnessed-then-P branch. These changes appear structurally sound based on reading.

**c) New theorem: `processStep_creates_past_witness_F_witnessed`** (correct):
- Handles the new code path where F is witnessed but P is not.

**d) New helper lemmas** (correct approach, errors in execution):
- `addFutureWitness_new_obl_matches` and `addPastWitness_new_obl_matches` -- extract information when `isWitnessed` transitions from false to true
- `processStep_isWitnessed_monotone` -- monotonicity of isWitnessed
- `forward_witness_of_isWitnessed` and `backward_witness_of_isWitnessed` -- the critical helpers that close the "isWitnessed = true" sorry cases

**e) Completed Phase 3 main theorems** (partially broken):
- `witnessGraph_forward_F_local` -- appears mostly correct but depends on broken helpers
- `witnessGraph_backward_P_local` -- complex three-way case split for F-blocks-P, has errors
- `witnessGraph_GContent_propagates` and `witnessGraph_HContent_propagates` -- substantial proofs attempted, errors in the "new edge" cases
- `processStep_edgesValid` and `buildWitnessGraph_edgesValid` -- new lemmas, have errors

### 4. Error Classification (48 Errors)

The 48 errors fall into these categories:

| Category | Count | Lines | Description |
|----------|-------|-------|-------------|
| Dependent elimination failure | 4 | 1427, 1459, 2366, 2417 | `cases` tactic on `List.mem_append` -- Lean can't solve dependent equation |
| `cases h :=` syntax error | 6 | 1615, 1768, 1977 | Invalid pattern `cases h :=` used instead of `cases h` or `match` |
| Unknown identifier | 5 | 1467, 2317-2318, 2452-2453 | References to `processStep_edges_subset_or_new` before definition; `src` out of scope |
| Unsolved goals | 8 | 1464, 1606, 1612, 1760, 1766, 1954, 1974 | Proof steps incomplete or wrong |
| simp/omega failures | ~12 | 2192-2238 | `processStep_edgesValid` proof has wrong `simp` and `omega` applications |
| Invalid projection | 2 | 2314, 2450 | `h_new.2.2` on a type without fields (Prop equality, not a structure) |
| Type mismatch | 5 | 2192-2238 | Edge validity proofs have type errors |
| Unknown tactic | 1 | 1523 | Attempted `rfl.symm` as a tactic |
| Cascading errors | ~5 | Various | Parse errors from earlier failures |

### 5. Committed Version Sorry Analysis

The 5 sorries in the committed version (lines 1373, 1427, 1437, 1467, 1479) fall into these categories:

| Sorry | Theorem | Category | Agent's Approach (Working Copy) |
|-------|---------|----------|---------------------------------|
| Line 1373 | `witnessGraph_forward_F_local` (isWitnessed=true case) | Development placeholder | Resolved via `forward_witness_of_isWitnessed` induction helper (correct approach, has errors) |
| Line 1427 | `witnessGraph_backward_P_local` (isWitnessed=true case) | Development placeholder | Resolved via `backward_witness_of_isWitnessed` (same approach, has errors) |
| Line 1437 | `witnessGraph_backward_P_local` (F-blocks-P) | Development placeholder | Resolved via processStep modification + coverage re-invocation (correct approach, has errors) |
| Line 1467 | `witnessGraph_GContent_propagates` | Development placeholder | Full induction proof attempted (correct approach, errors in new-edge case) |
| Line 1479 | `witnessGraph_HContent_propagates` | Development placeholder | Full induction proof attempted (correct approach, errors in new-edge case) |

All 5 sorries represent development placeholders with clear remediation paths (proof completion). They block transitive sorry-freedom for the eventual completeness theorem chain.

### 6. processStep_edges_subset_or_new Order Issue

A critical structural issue: in the committed version, `processStep_edges_subset_or_new` is defined at line 1515 (after the acyclicity section). But in the working copy, the agent uses it at line 1467 inside `processStep_isWitnessed_monotone` -- which is defined BEFORE it. The committed version's `processStep_edges_subset_or_new` also does NOT handle the new F-witnessed-then-P branch, while the working copy's version at line 2070 DOES handle it correctly.

This means the working copy has the correct version of `processStep_edges_subset_or_new` but placed it too late -- it needs to be moved before its first use.

## Recommendations

### Option A: Fix the Working Copy (Recommended)

The agent's approach is mathematically correct. The 48 errors are fixable without changing strategy. Recommended steps:

1. **Move `processStep_edges_subset_or_new`** before `processStep_isWitnessed_monotone` (line ~1462)
2. **Fix `cases` syntax** -- replace `cases h :=` pattern with proper `cases`/`by_cases`/`match`
3. **Fix dependent elimination** -- use `rcases`/`obtain` instead of `cases` on `List.mem_append`
4. **Fix projection errors** -- `h_new` for the new backward edge case destructures as `(h1, h2)` not `h_new.2.2`
5. **Fix `processStep_edgesValid`** -- the simp/omega failures need correct unfolding of addFutureWitness/addPastWitness
6. **Restore `end Bimodal.Metalogic.Bundle`** at end of file

Estimated effort: 4-6 hours (fix errors, verify build).

### Option B: Revert to Committed, Incremental Approach

If fixing the working copy proves too complex (too many interrelated errors):

1. Revert WitnessGraph.lean to committed version: `git checkout HEAD -- Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean`
2. Apply changes incrementally, building after each logical unit
3. Follow plan v007 sub-phases (3A, 3B, 3C, 3D) in order

Estimated effort: 8-12 hours (redo from committed state).

### Option C: Hybrid Approach

1. Start from the committed version
2. Cherry-pick the correct processStep modification and lemma updates from the working copy
3. Build incrementally, copying proven helpers as needed

Estimated effort: 6-8 hours.

### Recommendation

**Option A** is preferred because the working copy's mathematical approach is sound and the errors are mechanical (syntax, ordering, projection). The key insight -- using induction on build steps with `forward_witness_of_isWitnessed`/`backward_witness_of_isWitnessed` to handle the isWitnessed=true cases -- is correct and already mostly coded.

### Plan Update Needed

The implementation plan (v007) should be updated to reflect:
- Phase 3 sub-phases 3A and 3B are largely addressed in the working copy (once errors are fixed)
- The processStep modification (from sub-phase 3D) was correctly done as part of 3C/3D work
- The agent did not follow the sub-phase order (3A -> 3B -> 3C -> 3D) but instead tackled all five sorries simultaneously

## Next Steps

1. Fix the 48 build errors in WitnessGraph.lean (Option A)
2. Verify `lake build Bimodal.Metalogic.Bundle.WitnessGraph` succeeds with 0 errors and 0 sorries
3. Add `end Bimodal.Metalogic.Bundle` to close the namespace
4. Commit the Phase 3 completion
5. Proceed to Phase 4 (Int Embedding)

## References

- Last commit: 9d95c405 (task 916 phase 3: fix build errors iteration 1)
- Implementation plan: specs/916_implement_fp_witness_obligation_tracking/plans/implementation-007.md
- Previous research: specs/916_implement_fp_witness_obligation_tracking/reports/research-011.md
