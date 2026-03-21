# Implementation Plan: Task #716

- **Task**: 716 - Fix SoundnessLemmas type mismatches
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/716_fix_soundnesslemmas_type_mismatches/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Fix type mismatches in `Theories/Bimodal/Boneyard/Metalogic/Soundness/SoundnessLemmas.lean` caused by task 658's semantic change from strict (`<`) to reflexive (`<=`) inequality in temporal operators. The fixes involve replacing transitivity lemmas (`lt_trans` -> `le_trans`), using reflexivity (`le_refl t`) for temporal T axioms, and adapting case analysis with `le_of_lt` conversions. Complete 4 sorry placeholders for `temp_t_future` and `temp_t_past` axioms that are now provable with reflexive semantics.

### Research Integration

Integrated findings from research-001.md:
- Root cause: Task 658 (commit a454f293) changed temporal semantics
- Key Mathlib lemmas: `le_trans`, `le_of_lt`, `le_refl`
- Theorem-by-theorem fix strategies provided

## Goals & Non-Goals

**Goals**:
- Fix 5 type mismatch errors at lines 263, 287, 288, 339, 363
- Complete 4 sorry placeholders at lines 590-591 and 791-792
- Ensure all proofs compile without errors
- Maintain logical correctness of proofs

**Non-Goals**:
- Refactor proof structure beyond minimum fixes
- Change semantics in Truth.lean
- Update proofs in other files

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Fix breaks downstream proofs | High | Low | Run `lake build` after each theorem fix |
| Incorrect lemma application | Medium | Low | Verify with `lean_goal` before committing |
| MCP tools timeout during verification | Medium | Medium | Use direct `lake build` for final verification |

## Implementation Phases

### Phase 1: Fix Transitivity Error (swap_axiom_t4_valid) [COMPLETED]

**Goal**: Fix line 263 by replacing `lt_trans` with `le_trans`

**Tasks**:
- [ ] Read current proof at lines 253-264
- [ ] Replace `lt_trans h_u_lt_r h_r_lt_t` with `le_trans h_u_le_r h_r_le_t`
- [ ] Update variable names in comments for clarity (`h_*_lt_*` -> `h_*_le_*`)
- [ ] Verify with `lean_diagnostic_messages`

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic/Soundness/SoundnessLemmas.lean` - lines 259-264

**Verification**:
- No diagnostic errors on the modified theorem
- `lean_goal` shows proof completes

---

### Phase 2: Fix Reflexivity Error (swap_axiom_ta_valid) [COMPLETED]

**Goal**: Fix lines 287-288 by using reflexivity instead of strict inequality

**Tasks**:
- [ ] Read current proof at lines 278-288
- [ ] Replace proof strategy: use `t` as witness with `le_refl t` instead of strict inequality
- [ ] Simplify proof to use reflexivity directly
- [ ] Verify with `lean_diagnostic_messages`

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic/Soundness/SoundnessLemmas.lean` - lines 282-288

**Verification**:
- No diagnostic errors on the modified theorem
- Proof logic matches research recommendation

---

### Phase 3: Fix Case Analysis (swap_axiom_tl_valid) [COMPLETED]

**Goal**: Fix lines 339 and 363 by adapting case analysis for reflexive inequalities

**Tasks**:
- [ ] Read current proof at lines 310-363
- [ ] Line 339 (past case): Change `h_ut` usage with `le_of_lt h_ut` conversion
- [ ] Line 363 (future case): Change `h_gt` usage with `le_of_lt h_gt` conversion
- [ ] Verify both case branches compile
- [ ] Verify with `lean_diagnostic_messages`

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic/Soundness/SoundnessLemmas.lean` - lines 339, 363

**Verification**:
- No diagnostic errors on swap_axiom_tl_valid
- All three cases (past, present, future) compile correctly

---

### Phase 4: Complete temp_t_future/temp_t_past in axiom_swap_valid [COMPLETED]

**Goal**: Replace sorry placeholders at lines 590-591 with complete proofs

**Tasks**:
- [ ] Read current axiom_swap_valid structure around lines 580-594
- [ ] Implement temp_t_future case using `le_refl t` for reflexivity
- [ ] Implement temp_t_past case using `le_refl t` for reflexivity
- [ ] Verify with `lean_diagnostic_messages`

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic/Soundness/SoundnessLemmas.lean` - lines 590-591

**Verification**:
- No sorry placeholders remain in axiom_swap_valid
- No diagnostic errors

---

### Phase 5: Complete temp_t_future/temp_t_past in axiom_locally_valid [COMPLETED]

**Goal**: Replace sorry placeholders at lines 791-792 with complete proofs

**Tasks**:
- [ ] Read current axiom_locally_valid structure around lines 780-795
- [ ] Implement temp_t_future case using same pattern as Phase 4
- [ ] Implement temp_t_past case using same pattern as Phase 4
- [ ] Verify with `lean_diagnostic_messages`

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic/Soundness/SoundnessLemmas.lean` - lines 791-792

**Verification**:
- No sorry placeholders remain in axiom_locally_valid
- No diagnostic errors

---

### Phase 6: Final Verification and Build [COMPLETED]

**Goal**: Ensure all fixes compile correctly with full build

**Tasks**:
- [ ] Run `lake build` on the entire project
- [ ] Verify no errors in SoundnessLemmas.lean
- [ ] Check for any downstream errors caused by changes
- [ ] Create implementation summary

**Timing**: 30 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build` completes without errors
- No sorry placeholders in modified file

## Testing & Validation

- [ ] All 5 type mismatch errors resolved (lines 263, 287, 288, 339, 363)
- [ ] All 4 sorry placeholders completed (lines 590-591, 791-792)
- [ ] `lean_diagnostic_messages` shows no errors for SoundnessLemmas.lean
- [ ] `lake build` succeeds without errors
- [ ] No new sorry placeholders introduced

## Artifacts & Outputs

- `specs/716_fix_soundnesslemmas_type_mismatches/plans/implementation-001.md` (this file)
- `specs/716_fix_soundnesslemmas_type_mismatches/summaries/implementation-summary-YYYYMMDD.md` (on completion)
- Modified: `Theories/Bimodal/Boneyard/Metalogic/Soundness/SoundnessLemmas.lean`

## Rollback/Contingency

If fixes cause unexpected downstream issues:
1. Revert changes with `git checkout -- Theories/Bimodal/Boneyard/Metalogic/Soundness/SoundnessLemmas.lean`
2. Re-examine semantics alignment between Truth.lean and SoundnessLemmas.lean
3. Consider whether additional files need coordinated updates
