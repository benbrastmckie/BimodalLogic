# Implementation Plan: Task #829

- **Task**: 829 - Remove Metalogic Backwards-Compatible Aliases
- **Status**: [COMPLETED]
- **Effort**: 0.5 hours
- **Dependencies**: None (standalone cleanup)
- **Research Inputs**: specs/829_remove_metalogic_backwards_compatible_aliases/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Remove all backwards-compatible aliases added during task 818 refactoring. The research confirmed two aliases to remove: `semantic_weak_completeness` (primary) and `double_negation_elim` (secondary). Neither has any active code dependencies. This is a clean-break approach to improve codebase clarity and consistency, following the "clean-break" approach requested in the task description.

### Research Integration

From research-001.md:
- `semantic_weak_completeness` at FMP/SemanticCanonicalModel.lean:448 has ZERO active code dependencies
- `double_negation_elim` at Bundle/Completeness.lean:194 is defined but never used anywhere in codebase
- Type abbreviations (BoundedTime, HistoryTimePair, Branch, AlgWorld) are NOT aliases and must be preserved

## Goals & Non-Goals

**Goals**:
- Remove `semantic_weak_completeness` alias from FMP/SemanticCanonicalModel.lean
- Remove `double_negation_elim` alias from Bundle/Completeness.lean
- Update documentation to remove backwards compatibility mentions
- Verify build integrity after all changes

**Non-Goals**:
- Remove legitimate type abbreviations (BoundedTime, HistoryTimePair, Branch, AlgWorld)
- Modify any theorem implementations
- Rename the canonical theorems themselves

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Undiscovered usage of aliases | Medium | Very Low | Research confirmed zero active usages; lake build will catch any |
| Build regression | Low | Very Low | Run lake build after each change |
| Documentation drift | Low | Low | Update all documentation in single phase |

## Implementation Phases

### Phase 1: Remove Aliases [COMPLETED]

**Goal**: Remove both backwards-compatible alias definitions from Lean source files

**Tasks**:
- [x] Remove `semantic_weak_completeness` alias from SemanticCanonicalModel.lean (lines 443-448)
- [x] Remove `double_negation_elim` alias from Bundle/Completeness.lean (lines 186-195)
- [x] Run `lake build` to verify no breakage

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Remove alias definition (lines 443-448)
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - Remove alias definition (lines 186-195)

**Verification**:
- `lake build` completes successfully with no new errors
- `grep -r "semantic_weak_completeness" Theories/` shows no alias definition
- `grep -r "double_negation_elim" Theories/` returns no results

---

### Phase 2: Update Documentation [COMPLETED]

**Goal**: Remove all mentions of backwards compatibility and the removed aliases from documentation

**Tasks**:
- [x] Update FMP/README.md - Remove "also available as..." note (line 33)
- [x] Update Metalogic/Metalogic.lean - Remove alias mention from import comment (line 114)
- [x] Update FMP/SemanticCanonicalModel.lean - Update file header docstring if it references the alias

**Timing**: 10 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/README.md` - Remove backwards compatibility note
- `Theories/Bimodal/Metalogic/Metalogic.lean` - Remove "(alias: semantic_weak_completeness)" from comment

**Verification**:
- `grep -r "backwards compat" Theories/Bimodal/Metalogic/` returns no results
- `grep -r "alias.*semantic_weak_completeness" Theories/` returns no results

---

### Phase 3: Final Verification [COMPLETED]

**Goal**: Confirm clean build and document completion

**Tasks**:
- [x] Run full `lake build` to verify all changes integrate correctly
- [x] Verify no new warnings or errors introduced
- [x] Create implementation summary

**Timing**: 5 minutes

**Verification**:
- Clean `lake build` with no new errors or warnings
- All modified files compile correctly

## Testing & Validation

- [ ] `lake build` succeeds after Phase 1 (aliases removed)
- [ ] `lake build` succeeds after Phase 2 (documentation updated)
- [ ] Final `lake build` confirms no regression
- [ ] Grep searches confirm aliases are fully removed

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If any phase introduces build errors:
1. Revert the specific file change using `git checkout -- <file>`
2. Investigate whether an undiscovered dependency exists
3. If real dependency found, update plan to address it before proceeding

Since research confirmed zero dependencies, rollback is extremely unlikely to be needed.
