# Implementation Plan: Task #765

- **Task**: 765 - exclude_boneyard_examples_from_sorry_count
- **Status**: [IMPLEMENTING]
- **Effort**: 0.5 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/765_exclude_boneyard_examples_from_sorry_count/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This task updates the sorry count metrics to exclude Boneyard/ (deprecated/archived code) and Examples/ (pedagogical code) directories. The research report identified the exact file locations and commands to modify. The new sorry count will be 77 (down from 322), changing repository health status from "concerning" to "good".

### Research Integration

The research report (research-001.md) provided:
- Exact line numbers for all 5 files requiring modification
- Verified sorry counts: 242 in Boneyard/, 2 in Examples/, 77 in active codebase
- Recommended grep -v pattern for exclusions
- Identified outdated path reference (Logos/ instead of Theories/) in review.md

## Goals & Non-Goals

**Goals**:
- Exclude Boneyard/ and Examples/ from sorry count computations
- Update /todo and /review commands with exclusion filters
- Document the exclusion policy in state-management.md
- Update current metrics in state.json and TODO.md to reflect accurate count (77)

**Non-Goals**:
- Changing the actual sorry count in Lean source files
- Modifying status threshold logic (keep existing: <100="good", <300="manageable")
- Retroactively adjusting historical metrics

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Future directories may need exclusion | Low | Low | Document policy clearly for future reference |
| Exclusion patterns too broad | Low | Low | Use `/Boneyard/` not just `Boneyard` for directory specificity |
| Historical metrics incompatible | Medium | Low | This is a policy change, not a bug fix - document in commit |

## Implementation Phases

### Phase 1: Update Commands and Documentation [COMPLETED]

**Goal**: Modify the grep commands and documentation to implement exclusion policy

**Tasks**:
- [ ] Edit `.claude/commands/todo.md` line 850 - add `| grep -v "/Boneyard/" | grep -v "/Examples/"` to sorry_count command
- [ ] Edit `.claude/commands/review.md` line 132 - change `Logos/` to `Theories/` and add exclusion filters
- [ ] Edit `.claude/rules/state-management.md` line 121 - update sorry_count description to mention exclusions

**Timing**: 15 minutes

**Files to modify**:
- `.claude/commands/todo.md` - Update grep command at line 850
- `.claude/commands/review.md` - Fix path and add exclusions at line 132
- `.claude/rules/state-management.md` - Update documentation at line 121

**Verification**:
- Grep commands include `| grep -v "/Boneyard/" | grep -v "/Examples/"`
- review.md uses `Theories/` not `Logos/`
- Documentation mentions exclusion of Boneyard and Examples

---

### Phase 2: Update Current Metrics [IN PROGRESS]

**Goal**: Update state.json and TODO.md with accurate sorry count reflecting exclusions

**Tasks**:
- [ ] Edit `specs/state.json` - update repository_health.sorry_count to 77
- [ ] Edit `specs/state.json` - update repository_health.status to "good"
- [ ] Edit `specs/TODO.md` frontmatter - update technical_debt.sorry_count to 77
- [ ] Edit `specs/TODO.md` frontmatter - update technical_debt.status to "good"
- [ ] Verify new count by running updated grep command

**Timing**: 15 minutes

**Files to modify**:
- `specs/state.json` - Update sorry_count (314->77) and status ("concerning"->"good")
- `specs/TODO.md` - Update frontmatter technical_debt section to match

**Verification**:
- Run `grep -r "sorry" Theories/ --include="*.lean" | grep -v "/Boneyard/" | grep -v "/Examples/" | wc -l` returns ~77
- state.json and TODO.md show matching values
- repository_health.status is "good"

## Testing & Validation

- [ ] Run the updated grep command and verify count is approximately 77
- [ ] Check state.json sorry_count matches the grep output
- [ ] Check TODO.md technical_debt matches state.json
- [ ] Verify documentation in state-management.md mentions exclusions
- [ ] Verify /todo and /review commands have exclusion filters

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-20260129.md (upon completion)

## Rollback/Contingency

If implementation causes issues:
1. Revert grep command changes in todo.md and review.md to remove exclusion filters
2. Restore original metrics (sorry_count: 314, status: "concerning") in state.json and TODO.md
3. Revert documentation change in state-management.md

All changes are configuration/documentation only - no risk to Lean source code.
