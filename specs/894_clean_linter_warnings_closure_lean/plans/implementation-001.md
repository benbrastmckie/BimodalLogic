# Implementation Plan: Task #894

- **Task**: 894 - clean_linter_warnings_closure_lean
- **Status**: [COMPLETED]
- **Effort**: 0.25 hours
- **Dependencies**: None
- **Research Inputs**: specs/894_clean_linter_warnings_closure_lean/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Remove unused simp arguments and an unused variable binding in `Closure.lean` to eliminate linter warnings. The research report confirmed all warnings are about provably redundant arguments that can be safely removed without affecting proof correctness.

### Research Integration

- Line 99: Unused variable `h` in decidable if-then-else pattern
- Line 304: Unused simp argument `hbot'` (goal already contains `none <|> ...`)
- Line 316: Unused simp arguments `hbot'` and `hcontra'` (goal already contains `none <|> none <|> ...`)

## Goals & Non-Goals

**Goals**:
- Remove all 4 linter warnings from `Closure.lean`
- Verify the build succeeds with no warnings for this file

**Non-Goals**:
- Changing proof logic or semantics
- Addressing warnings in other files

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Simp fails without removed args | L | Very Low | Research confirmed goal states don't require these args |

## Implementation Phases

### Phase 1: Remove Unused Arguments [COMPLETED]

- **Dependencies**: None
- **Goal**: Eliminate all 4 linter warnings by removing unused simp arguments and variable bindings

**Tasks**:
- [x] Line 99: Change `if h : sf.formula = φ then` to `if sf.formula = φ then`
- [x] Line 304: Change `simp [hbot', hr'']` to `simp [hr'']`
- [x] Line 316: Change `simp [hbot', hcontra', hr'']` to `simp [hr'']`
- [x] Run `lake build` and verify no warnings for `Closure.lean`

**Timing**: 10-15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Closure.lean` - Remove unused arguments at lines 99, 304, 316

**Verification**:
- `lake build` completes successfully
- No warnings appear for `Closure.lean` in build output

**Progress:**

**Session: 2026-02-18, sess_1771381924_d1724f**
- Removed: unused variable `h` at line 99 (decidable if-then-else)
- Removed: unused simp argument `hbot'` at line 304
- Removed: unused simp arguments `hbot', hcontra'` at line 316
- Verified: `lake build` shows no warnings for `Decidability/Closure.lean`

---

## Testing & Validation

- [ ] Build succeeds with `lake build`
- [ ] No linter warnings for `Closure.lean`
- [ ] All existing functionality preserved (proofs still compile)

## Artifacts & Outputs

- Modified `Closure.lean` with 3 edits removing unused arguments
- Implementation summary documenting the changes

## Rollback/Contingency

If any edit causes proof failure (highly unlikely per research analysis), revert individual edits and investigate which simp arguments are actually needed. The research confirmed goal state analysis shows all removed arguments are provably redundant.
