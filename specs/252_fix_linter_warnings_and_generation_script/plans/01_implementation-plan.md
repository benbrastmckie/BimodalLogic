# Implementation Plan: Fix Linter Warnings and Improve Generation Scripts

- **Task**: 252 - Fix linter warnings across codebase and improve dataset generation scripts
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: specs/252_fix_linter_warnings_and_generation_script/reports/01_linter-warning-research.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Fix 36 linter warnings across 7 Lean files and improve the dataset generation shell script for robustness. All Lean changes are mechanical: renaming unused binders to `_`, removing unused simp arguments, removing no-op tactics, and prefixing unused variables with `_`. The shell script improvements add signal trapping, prerequisite checking, and post-run validation. All changes are low-risk and verifiable via `lake build`.

### Research Integration

The research report identified 6 warning categories across 7 files:
1. Unused variables `h_sc`/`h_mem` in definition binders (22 warnings across 3 files)
2. Unused simp arguments in TemporalFormulas.lean (6 warnings)
3. Unused `all_goals simp_wf` in ProofSearch/Core.lean (2 warnings)
4. Unused variable `fc` in CountermodelExtraction.lean (1 warning)
5. Unused variables in ProofSearch/Strategies.lean (4 warnings)
6. Generation script robustness gaps (no signal trapping, no prereq check, no post-run validation)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap items directly addressed. This is a code-quality improvement task.

## Goals & Non-Goals

**Goals**:
- Eliminate all 36 identified linter warnings across 7 Lean files
- Improve generation script with signal trapping, prerequisite checking, and post-run validation
- Verify zero regressions via `lake build`

**Non-Goals**:
- Fix the broader 638 actionable warnings beyond the task-scoped files
- Add progress reporting to the generation script (separate task 253)
- Suppress warnings rather than fix root causes
- Refactor any proof logic or change semantics

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Anonymous binder breaks downstream proof | M | L | The research confirms these binder names are never referenced in definition bodies or downstream proofs; `lake build` verifies |
| Removing simp arg changes proof behavior | M | L | The linter confirms the args have no effect; proofs close without them |
| Removing `simp_wf` breaks termination proof | M | L | `omega` alone suffices for all goals; the research confirms `simp_wf` is no-op |
| Shell script changes break existing workflow | L | L | Changes are additive (trap, checks); existing behavior preserved |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- |
| 2 | 4 | 1, 2, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Fix Lean Warnings in Semantics and FrameConditions [COMPLETED]

**Goal**: Eliminate 22 unused-variable warnings for `h_sc`/`h_mem` binders across 3 files.

**Tasks**:
- [x] In `Theories/Bimodal/Semantics/Validity.lean`: Replace `(h_sc : ShiftClosed Omega)` with `(_ : ShiftClosed Omega)` and `(h_mem : tau in Omega)` with `(_ : tau in Omega)` in all 5 definitions (`valid`, `semantic_consequence`, `valid_dense`, `valid_discrete`, `unsatisfiable_implies_all_fixed`)
- [x] In `Theories/Bimodal/FrameConditions/Validity.lean`: Apply the same anonymous binder pattern to the definition at lines 56-57
- [x] In `Theories/Bimodal/FrameConditions/Soundness.lean`: Apply the same anonymous binder pattern across all 5 affected locations
- [x] Run `lake build` on the affected files to verify no regressions

**Timing**: 45 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Semantics/Validity.lean` - Replace 10 named binders with `_` (5 definitions x 2 binders)
- `Theories/Bimodal/FrameConditions/Validity.lean` - Replace 2 named binders with `_` (1 definition)
- `Theories/Bimodal/FrameConditions/Soundness.lean` - Replace 10 named binders with `_` (5 locations x 2 binders)

**Verification**:
- `lake build` passes with no errors
- Warning count for these files drops to zero

---

### Phase 2: Fix Lean Warnings in Syntax and Automation [NOT STARTED]

**Goal**: Eliminate 12 warnings for unused simp arguments and no-op tactics across 2 files.

**Tasks**:
- [ ] In `Theories/Bimodal/Syntax/SubformulaClosure/TemporalFormulas.lean`:
  - Line 565: Remove `f_nesting_depth` from `simp only [G_neg_neg_bot, Formula.all_future, f_nesting_depth]`
  - Line 566: Remove `f_nesting_depth` from `simp only [H_neg_neg_bot, Formula.all_past, f_nesting_depth]`
  - Line 647: Remove `p_nesting_depth` from `simp only [G_neg_neg_bot, Formula.all_future, p_nesting_depth]`
  - Line 650: Remove `p_nesting_depth` from `simp only [H_neg_neg_bot, Formula.all_past, p_nesting_depth]`
  - Line 803: Remove `Formula.and` from the `simp only` argument list
  - Line 895: Remove `Formula.and` from the `simp only` argument list
- [ ] In `Theories/Bimodal/Automation/ProofSearch/Core.lean`:
  - Line 1016: Remove the `all_goals simp_wf` line from the `decreasing_by` block
  - Line 1141: Remove the `all_goals simp_wf` line from the `decreasing_by` block
- [ ] Run `lake build` on the affected files to verify no regressions

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Syntax/SubformulaClosure/TemporalFormulas.lean` - Remove 6 unused simp arguments
- `Theories/Bimodal/Automation/ProofSearch/Core.lean` - Remove 2 `all_goals simp_wf` lines

**Verification**:
- `lake build` passes with no errors
- Warning count for these files drops to zero

---

### Phase 3: Fix Remaining Lean Warnings and Improve Generation Script [NOT STARTED]

**Goal**: Eliminate 5 remaining Lean warnings and add robustness improvements to the generation script.

**Tasks**:
- [ ] In `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean`:
  - Line 128: Rename parameter `fc` to `_fc` (intentionally unused scaffolding for future frame-class-aware extraction)
- [ ] In `Theories/Bimodal/Automation/ProofSearch/Strategies.lean`:
  - Lines 365, 371, 376: Replace `(proof : ...)` with `(_ : ...)` in existential binders
  - Line 375: Replace `(h : [p.box] |- p)` with `(_ : [p.box] |- p)`
- [ ] In `scripts/run_dataset_generation.sh`:
  - Add a `cleanup()` function that handles partial output files
  - Add `trap cleanup EXIT INT TERM` for signal handling
  - Add a `check_prereqs()` function that verifies `lake exe dataset_generator` binary exists before running
  - Add basic post-run validation: check that output files are valid JSON lines (non-empty, parseable first/last line)
  - Add a `--dry-run` option that prints commands without executing
- [ ] Run `lake build` on the affected Lean files

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` - Rename `fc` to `_fc`
- `Theories/Bimodal/Automation/ProofSearch/Strategies.lean` - Replace 4 named binders with `_`
- `scripts/run_dataset_generation.sh` - Add signal trapping, prereq checking, post-run validation, dry-run option

**Verification**:
- `lake build` passes with no errors
- `bash -n scripts/run_dataset_generation.sh` passes (syntax check)
- `scripts/run_dataset_generation.sh --dry-run` executes without error

---

### Phase 4: Full Build Verification [NOT STARTED]

**Goal**: Confirm all changes integrate correctly and warning count has decreased.

**Tasks**:
- [ ] Run full `lake build` and capture warning output
- [ ] Compare warning count against the pre-fix baseline (799 total, 638 actionable)
- [ ] Verify no new warnings were introduced
- [ ] Verify no `sorry` was introduced (grep for new sorry occurrences in modified files)
- [ ] Run `scripts/run_dataset_generation.sh --dry-run` to verify script improvements work

**Timing**: 1 hour (dominated by full build time)

**Depends on**: 1, 2, 3

**Files to modify**:
- None (verification only)

**Verification**:
- Full `lake build` passes with zero errors
- Warning count reduced by at least 36 (from 799 to 763 or fewer)
- No new `sorry` in any modified file
- Generation script dry-run succeeds

## Testing & Validation

- [ ] `lake build` passes with zero errors after all changes
- [ ] Warning count decreased by at least 36
- [ ] No new warnings introduced in modified files
- [ ] No `sorry` introduced in any modified file
- [ ] `bash -n scripts/run_dataset_generation.sh` passes
- [ ] `scripts/run_dataset_generation.sh --dry-run` executes cleanly
- [ ] All existing proofs still close (verified by successful `lake build`)

## Artifacts & Outputs

- `specs/252_fix_linter_warnings_and_generation_script/plans/01_implementation-plan.md` (this file)
- `specs/252_fix_linter_warnings_and_generation_script/summaries/01_implementation-summary.md` (created after implementation)

## Rollback/Contingency

All changes are to individual lines within existing files. If any change causes a regression:
1. `git diff` to identify the specific change
2. `git checkout -- <file>` to revert the problematic file
3. Investigate the regression before re-applying the fix

The generation script changes are purely additive (new functions, trap handler) and do not modify existing execution paths. Reverting is straightforward via `git checkout`.
