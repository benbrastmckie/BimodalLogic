# Implementation Plan: Task #891

- **Task**: 891 - Fix split-at tactic incompatibility in TemporalLindenbaum.lean
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: None (blocking task 888 Phase 3)
- **Research Inputs**: specs/891_fix_split_at_tactic_temporallindenbaum/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Fix 8 build errors in TemporalLindenbaum.lean caused by Lean 4.27.0-rc1 tactic incompatibilities. The errors fall into 4 categories: (A) `split` failing on `have`-wrapped match expressions from `temporalWitnessChain`, (B) `split at h ⊢` multi-target syntax not supported, (C) instance synthesis failure, and (D) type errors that are likely cascading failures. Each category will be addressed in sequence with build verification between phases.

### Research Integration

Research report (research-001.md) identified:
- Root cause: `temporalWitnessChain` unfolds with `have`-bindings that `split` cannot handle
- 3 locations with `have`-wrapped match (lines 214, 346, 373)
- 2 locations with multi-target `split at h ⊢` syntax (lines 223, 266)
- 1 instance synthesis failure (line 324)
- 2 type errors likely cascading from earlier failures (lines 394, 398)

## Goals & Non-Goals

**Goals**:
- Fix all 8 build errors in TemporalLindenbaum.lean
- Achieve clean build (0 errors, warnings for existing sorries acceptable)
- Unblock task 888 Phase 3

**Non-Goals**:
- Resolving the existing 3 sorries in maximal_tcs_is_mcs (separate mathematical issue for task 888)
- Optimizing proof structure beyond fixing the errors
- Refactoring unrelated code

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `cases` replacement changes proof state requiring additional tactics | Medium | Medium | Test each replacement individually before moving to next |
| Type errors are not just cascade effects | Medium | Low | If Phase 4 still has errors after Phase 1-3, investigate independently |
| Instance synthesis needs import changes | Low | Low | Check surrounding code context for similar patterns |

## Sorry Characterization

### Pre-existing Sorries
- 3 sorries in `maximal_tcs_is_mcs` at lines 603, 649, 656 (documented in task 888 as mathematical issues)

### Expected Resolution
- This task does NOT address the existing sorries
- Focus is purely on tactic/syntax errors blocking compilation

### New Sorries
- None expected. All fixes are tactic replacements, not proof gaps.

### Remaining Debt
After this implementation:
- Same 3 sorries remain (out of scope for this task)
- Build should complete successfully (sorries produce warnings, not errors)

## Implementation Phases

### Phase 1: Fix Category A - split fails on have-wrapped match [NOT STARTED]

- **Dependencies:** None
- **Goal:** Fix 3 locations where `split` cannot handle `have`-wrapped match expressions from `temporalWitnessChain` unfolding

**Tasks**:
- [ ] Fix line 214 in `temporalWitnessChain_head`: Replace `split <;> (try split) <;> simp` with explicit `cases` pattern on `extractForwardWitness` and `extractBackwardWitness`
- [ ] Fix line 346 in `henkinChain_mono`: Replace `split` after `simp only [henkinChain]` with explicit `cases` pattern
- [ ] Fix line 373 in `henkinStep_consistent`: Replace `split` after `simp only [henkinStep]` with explicit `cases` or `if_neg`/`if_pos` pattern
- [ ] Run `lake build` to verify Phase 1 errors resolved

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` - lines 214, 346, 373

**Verification**:
- Lines 214, 346, 373 no longer produce "Could not split" errors
- Build progresses further (may still have Phase 2-4 errors)

---

### Phase 2: Fix Category B - split at multi-target syntax [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Fix 2 locations where `split at h_mem ⊢` attempts to split both hypothesis and goal

**Tasks**:
- [ ] Fix line 223 in `forward_witness_in_chain`: Split the `split at h_mem ⊢` into separate operations - first `cases` for goal, then handle hypothesis with `simp` or `rcases`
- [ ] Fix line 266 in `backward_witness_in_chain`: Apply same pattern as line 223
- [ ] Run `lake build` to verify Phase 2 errors resolved

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` - lines 223, 266

**Verification**:
- Lines 223, 266 no longer produce "multiple targets not supported" errors
- Build progresses further

---

### Phase 3: Fix Category C - instance synthesis failure [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Resolve instance synthesis failure in `henkinStep` definition at line 324

**Tasks**:
- [ ] Read line 324 context to identify what instance is missing
- [ ] Check imports at top of file for missing typeclass requirements
- [ ] Look for similar patterns elsewhere in codebase that successfully synthesize the instance
- [ ] Add explicit instance or modify definition to help synthesis
- [ ] Run `lake build` to verify Phase 3 error resolved

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` - line 324 area

**Verification**:
- Line 324 no longer produces instance synthesis failure
- Build progresses to Phase 4 errors (if any remain)

---

### Phase 4: Fix Category D - type errors and verify build [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Fix remaining type errors at lines 394/398 and achieve clean build

**Tasks**:
- [ ] Check if lines 394/398 errors still exist after Phase 1-3 fixes
- [ ] If errors persist: Analyze type mismatch at line 394 in `finite_list_in_henkinChain`
- [ ] If errors persist: Analyze "function expected" error at line 398
- [ ] Fix any remaining issues
- [ ] Run `lake build` to verify full clean build (warnings for sorries acceptable)
- [ ] Verify the 3 existing sorries are still properly marked (no accidental removal)

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` - lines 394, 398 (if needed)

**Verification**:
- `lake build` completes with 0 errors
- Only warnings are for the 3 existing sorries in `maximal_tcs_is_mcs`
- Task 888 Phase 3 is unblocked

---

## Testing & Validation

- [ ] `lake build` completes with 0 errors
- [ ] TemporalLindenbaum.lean imports successfully
- [ ] No regression in dependent files
- [ ] Existing sorries remain unchanged (3 in maximal_tcs_is_mcs)

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- `summaries/implementation-summary-20260217.md` (on completion)
- Modified: `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean`

## Rollback/Contingency

If fixes introduce new problems:
1. `git checkout Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` to restore original
2. Re-run research with more detailed focus on specific failure point
3. Consider alternative approaches (e.g., `decide` tactic, manual case analysis)
