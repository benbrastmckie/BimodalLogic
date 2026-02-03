# Implementation Plan: Task #839

- **Task**: 839 - Clean linter warnings in Metalogic files
- **Status**: [COMPLETED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/839_clean_linter_warnings/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: lean
- **Lean Intent**: false

## Overview

Apply mechanical linter fixes across three Metalogic files: TaskFrame.lean (1 warning), WorldHistory.lean (2 warnings), and SoundnessLemmas.lean (16 warnings). All fixes are syntax-only refactorings that do not change proof semantics. The implementation is ordered from simplest to most numerous to enable early verification.

### Research Integration

Research identified 19 total warnings:
- 6 "Try this" suggestions for combining `intro` tactics
- 10 unused `simp` arguments (primarily `truth_at`)
- 1 duplicate namespace prefix
- 2 unused section variable instances

## Goals & Non-Goals

**Goals**:
- Eliminate all 19 linter warnings in the three target files
- Maintain proof correctness (no semantic changes)
- Improve code quality through cleaner syntax

**Non-Goals**:
- Refactoring proof strategies
- Performance optimization
- Addressing linter warnings in other files

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Combined intros break proofs | M | L | Test each change with `lean_goal` before moving on |
| Removing simp args causes proof failure | M | L | Verify proof still compiles after each removal |
| `omit` syntax incorrect | L | L | Use exact syntax from Lean 4 documentation |

## Implementation Phases

### Phase 1: Fix TaskFrame.lean [COMPLETED]

**Goal**: Remove duplicate namespace prefix (1 warning)

**Tasks**:
- [ ] Remove redundant `FiniteTaskFrame.` prefix from definition at line 193

**Timing**: 10 minutes

**Files to modify**:
- `Theories/Bimodal/Semantics/TaskFrame.lean` - Line 193: change `def FiniteTaskFrame.toTaskFrame` to `def toTaskFrame`

**Steps**:
1. Read TaskFrame.lean around line 193
2. Change `def FiniteTaskFrame.toTaskFrame` to `def toTaskFrame` (remove redundant namespace prefix since already inside `namespace FiniteTaskFrame`)
3. Verify with `lean_goal` that file compiles without errors

**Verification**:
- File compiles without errors
- Warning at line 193 is resolved

---

### Phase 2: Fix WorldHistory.lean [COMPLETED]

**Goal**: Add `omit` clauses for unused section variables (2 warnings)

**Tasks**:
- [ ] Add `omit` clause before `neg_neg_eq` theorem at line 397
- [ ] Add `omit` clause before `neg_injective` theorem at line 403

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Semantics/WorldHistory.lean` - Lines 397, 403: add `omit [LinearOrder D] [IsOrderedAddMonoid D] in` before each theorem

**Steps**:
1. Read WorldHistory.lean around lines 395-410
2. Add `omit [LinearOrder D] [IsOrderedAddMonoid D] in` before line 397 (`neg_neg_eq`)
3. Add `omit [LinearOrder D] [IsOrderedAddMonoid D] in` before line 403 (`neg_injective`)
4. Verify file compiles without errors

**Verification**:
- File compiles without errors
- Warnings at lines 397 and 403 are resolved

---

### Phase 3: Fix SoundnessLemmas.lean - Intro Patterns [COMPLETED]

**Goal**: Combine consecutive `intro` tactics (6 warnings)

**Tasks**:
- [ ] Fix intro at line 221: combine to `intro h_box_swap_φ σ ρ`
- [ ] Fix intro at line 239: combine to `intro h_swap_φ σ h_all_not`
- [ ] Fix intro at line 287: combine to `intro h_swap_φ s h_s_le_t h_all_not_future`
- [ ] Fix intro at line 336 (first): combine to `intro h_fut_all h_conj`
- [ ] Fix intro at line 336 (second): combine to `intro h_now h_past`
- [ ] Fix intro at line 350: combine to `intro h_fut_all h_conj`

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Lines 221, 239, 287, 336, 350: replace separate intros with combined intro patterns

**Steps**:
1. Read SoundnessLemmas.lean around each warning location
2. For each location, replace the sequence of separate `intro` tactics with the linter's suggested combined form
3. After each change, verify the proof still compiles with `lean_goal`

**Verification**:
- All 6 intro-related warnings are resolved
- All proofs still compile

---

### Phase 4: Fix SoundnessLemmas.lean - Unused Simp Args [COMPLETED]

**Goal**: Remove unused `simp` arguments (10 warnings)

**Tasks**:
- [ ] Line 238: Remove `truth_at` from simp
- [ ] Line 286: Remove `Formula.sometime_future` and `truth_at` from simp
- [ ] Line 432: Remove `truth_at` from simp
- [ ] Line 522: Remove `truth_at` from simp
- [ ] Line 647: Remove `truth_at` from simp (or entire simp if only arg)
- [ ] Line 694: Remove `truth_at` from simp (or entire simp if only arg)
- [ ] Line 705: Remove `truth_at` from simp (or entire simp if only arg)
- [ ] Line 726: Remove `truth_at` from simp (or entire simp if only arg)

**Timing**: 35 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Multiple lines: remove unused arguments from `simp only [...]` calls

**Steps**:
1. For each line listed, read the current simp call
2. Remove the unused argument(s)
3. If `truth_at` is the only argument, replace `simp only [truth_at]` with `simp` or remove entirely if the simp does nothing
4. Verify each proof still compiles after modification

**Verification**:
- All 10 unused simp argument warnings are resolved
- All proofs still compile

---

## Testing & Validation

- [ ] `lake build` completes without errors
- [ ] Linter warnings in TaskFrame.lean reduced by 1
- [ ] Linter warnings in WorldHistory.lean reduced by 2
- [ ] Linter warnings in SoundnessLemmas.lean reduced by 16
- [ ] All existing tests pass

## Artifacts & Outputs

- Modified `Theories/Bimodal/Semantics/TaskFrame.lean`
- Modified `Theories/Bimodal/Semantics/WorldHistory.lean`
- Modified `Theories/Bimodal/Metalogic/SoundnessLemmas.lean`
- Implementation summary at `specs/839_clean_linter_warnings/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If any fix causes unexpected compilation failures:
1. Revert the specific change using `git checkout -- <file>`
2. Investigate the failure before re-attempting
3. If a fix cannot be applied cleanly, skip it and document in summary
