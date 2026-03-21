# Implementation Summary: Task #891

**Completed**: 2026-02-17
**Session**: sess_1771374336_9df87c

## Overview

Fixed 8 build errors in TemporalLindenbaum.lean caused by Lean 4.27.0-rc1 tactic incompatibilities. The file now builds successfully with 0 errors.

## Changes Made

### Phase 1: Fixed split on have-wrapped match (line 214)

- `temporalWitnessChain_head`: Changed `unfold temporalWitnessChain` to `rw [temporalWitnessChain]`
  - The `unfold` produced a `have φ := φ;` wrapper that the `split` tactic couldn't handle
  - Using `rw` avoids this wrapper

### Phase 2: Fixed split at multi-target syntax (lines 223, 266)

- `forward_witness_in_chain` and `backward_witness_in_chain`:
  - Changed from `unfold ... split at h_mem ⊢` to `rw ... split` + `conv at h_mem => rw [...]`
  - Lean 4.27 no longer supports `split at h ⊢` with multiple targets
  - Solution: Split goal first, then use `conv` to rewrite the match discriminant in the hypothesis

### Phase 3: Fixed instance synthesis failure (line 324)

- `henkinStep` definition:
  - Added `attribute [local instance] Classical.propDecidable in` before the definition
  - The `if SetConsistent (...)` required a `Decidable` instance which wasn't available
  - Using classical decidability as a local instance resolves this

### Phase 4: Fixed cascading type errors (lines 394-409, 448-491)

- `finite_list_in_henkinChain`:
  - Changed `absurd h (List.not_mem_nil _)` to `by simp`
  - Changed `List.mem_cons_of_mem` to `List.mem_cons.mpr (Or.inr h)`
  - Changed `List.mem_cons_self` to `List.mem_cons.mpr (Or.inl rfl)`
  - Lean 4.27 changed the List membership API

- `henkinLimit_forward_saturated` and `henkinLimit_backward_saturated`:
  - Simplified proof by using IH result directly with `exact ih h_old`
  - The IH now returns membership in `henkinLimit` directly, not in a specific chain level

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean`
  - Line 213-214: `temporalWitnessChain_head` proof
  - Line 217-256: `forward_witness_in_chain` proof (rewritten)
  - Line 258-296: `backward_witness_in_chain` proof (rewritten)
  - Line 322: Added `attribute [local instance] Classical.propDecidable in`
  - Line 393-409: `finite_list_in_henkinChain` proof
  - Line 448-452: `henkinLimit_forward_saturated` proof
  - Line 488-491: `henkinLimit_backward_saturated` proof

## Verification

- `lake build Bimodal.Metalogic.Bundle.TemporalLindenbaum` completes with 0 errors
- Only warnings are for 2 pre-existing sorries in `maximal_tcs_is_mcs` (documented in task 888 as a mathematical issue)
- Task 888 Phase 3 is now unblocked

## Technical Notes

The key insight for the multi-target split fix was:
1. Use `rw [temporalWitnessChain]` instead of `unfold` to avoid the `have φ := φ;` wrapper
2. Use `split` on the goal only
3. Use `conv at h_mem => rw [h_fwd]` (etc.) to propagate case information into the hypothesis
4. The `conv` approach is necessary because `simp only [h_fwd] at h_mem` doesn't propagate into dependent match discriminants
