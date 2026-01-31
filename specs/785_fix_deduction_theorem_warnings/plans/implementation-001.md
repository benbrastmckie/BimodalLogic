# Implementation Plan: Task #785

- **Task**: 785 - Fix DeductionTheorem.lean build warnings
- **Status**: [COMPLETED]
- **Effort**: 0.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/785_fix_deduction_theorem_warnings/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Fix 8 build warnings in DeductionTheorem.lean by removing unused simp arguments and ineffective tactics. The research report identified two categories: 6 `simp [List.filter]` calls where the argument is redundant (simp already knows `List.mem_filter`), and 2 `simp_wf` tactics in `decreasing_by` blocks that do nothing because goals are already simplified.

### Research Integration

- Research report: specs/785_fix_deduction_theorem_warnings/reports/research-001.md
- Key findings: `simp` already has access to `List.mem_filter` lemma, making `[List.filter]` argument unnecessary. The `simp_wf` tactics are ineffective because well-foundedness goals are already in final form.

## Goals & Non-Goals

**Goals**:
- Remove all 8 build warnings from DeductionTheorem.lean
- Maintain proof correctness (no semantic changes)
- Clean, warning-free build

**Non-Goals**:
- Optimizing proof performance
- Refactoring proof structure
- Adding new functionality

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| simp behavior change | Medium | Low | Verify each edit compiles before proceeding |
| Line number drift | Low | Low | Use semantic markers (function names) to locate edits |
| Proof breakage | High | Very Low | Build after each phase to catch issues early |

## Implementation Phases

### Phase 1: Remove unused simp [List.filter] arguments [NOT STARTED]

**Goal**: Fix 6 warnings about unused `simp [List.filter]` arguments

**Tasks**:
- [ ] Edit line 101: Change `simp [List.filter] at hx` to `simp at hx` in `removeAll_subset`
- [ ] Edit line 129: Change `simp [List.filter] at h_in` to `simp at h_in` in `cons_removeAll_perm` (forward)
- [ ] Edit line 138: Change `simp [List.filter]` to `simp` in `cons_removeAll_perm` (backward)
- [ ] Edit line 225: Change `simp [List.filter]` to `simp` in `deduction_with_mem` (assumption case)
- [ ] Edit line 268: Change `simp [List.filter] at hx` to `simp at hx` in `deduction_with_mem` (weakening A in Gamma'')
- [ ] Edit line 275: Change `simp [List.filter]` to `simp` in `deduction_with_mem` (weakening A not in Gamma'')
- [ ] Build module to verify no errors

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/DeductionTheorem.lean` - Remove `[List.filter]` from 6 simp calls

**Verification**:
- `lake build Bimodal.Metalogic.DeductionTheorem` compiles without errors
- 6 fewer warnings in output

---

### Phase 2: Remove ineffective simp_wf tactics [NOT STARTED]

**Goal**: Fix 2 warnings about ineffective `simp_wf` tactics

**Tasks**:
- [ ] Edit line 297: Remove `simp_wf` line from `deduction_with_mem` decreasing_by block
- [ ] Edit line 439: Remove `simp_wf` line from `deduction_theorem` decreasing_by block
- [ ] Build module to verify no errors

**Timing**: 10 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/DeductionTheorem.lean` - Remove 2 `simp_wf` lines

**Verification**:
- `lake build Bimodal.Metalogic.DeductionTheorem` compiles without errors
- All 8 warnings eliminated

---

### Phase 3: Final verification [NOT STARTED]

**Goal**: Confirm all warnings are resolved and build is clean

**Tasks**:
- [ ] Run full module build and capture output
- [ ] Verify zero warnings related to simp or simp_wf
- [ ] Create implementation summary

**Timing**: 5 minutes

**Verification**:
- Clean build with no warnings for the edited file
- All proofs still compile successfully

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.DeductionTheorem` compiles successfully
- [ ] No new errors or warnings introduced
- [ ] All 8 original warnings eliminated

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (after completion)

## Rollback/Contingency

If any edit breaks a proof:
1. Revert the specific edit using git
2. Investigate why simp behavior changed
3. Try alternative simplification (e.g., `simp only [List.mem_filter]` if needed)

All changes are local to one file and can be reverted with `git checkout Theories/Bimodal/Metalogic/DeductionTheorem.lean`.
