# Implementation Plan: Task #621

- **Task**: 621 - Analyze Plan Errors and Improve Agent Execution
- **Status**: [IMPLEMENTING]
- **Effort**: 3 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/621_analyze_plan_errors_improve_agent_execution/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This plan addresses the gap between documented jq escaping workarounds and their actual use in skill implementations. Research identified that skill-planner and skill-status-sync use vulnerable jq patterns that trigger Claude Code Issue #1132, causing postflight failures. The fix requires updating 8 skill files to reference the workaround documentation, replacing problematic jq patterns with the two-step approach, and adding error logging for jq failures.

### Research Integration

Key findings from research-001.md:
- jq escaping bug (Issue #1132) is well-documented but skills don't consistently use workarounds
- skill-planner Stage 8 uses the exact broken pattern: `select(.type != "plan")` in a single jq call
- skill-status-sync artifact linking operations use the same vulnerable pattern
- The system recovered via file-based jq approach after 3 failed attempts, wasting tokens
- Error logging to errors.json did not capture the jq failures

## Goals & Non-Goals

**Goals**:
- Eliminate jq parse failures in postflight operations across all skills
- Ensure all skills using jq reference the workaround documentation
- Add error logging for jq failures to enable pattern tracking
- Create reusable postflight shell scripts to encapsulate correct patterns

**Non-Goals**:
- Replacing jq with Python (considered long-term, out of scope)
- Adding pre-commit hooks for skill validation
- Modifying the jq-escaping-workarounds.md document itself

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Two-step pattern introduces race conditions | Medium | Low | Use atomic file operations (write to temp, then mv) |
| Shell scripts introduce new bugs | Medium | Low | Test scripts with sample data before deployment |
| Missing skills during audit | High | Medium | Use grep to systematically find all jq usage |
| Edit breaks skill formatting | Medium | Low | Carefully preserve YAML frontmatter and markdown structure |

## Implementation Phases

### Phase 1: Update skill-planner with two-step jq pattern [COMPLETED]

**Goal**: Fix the primary source of observed errors by updating skill-planner Stage 8 to use the documented two-step jq pattern.

**Tasks**:
- [ ] Add context reference to jq-escaping-workarounds.md in skill-planner SKILL.md
- [ ] Replace Stage 8 artifact linking with two-step pattern from workaround doc
- [ ] Add explicit note: "Use two-step jq pattern - see jq-escaping-workarounds.md"
- [ ] Verify Stage 7 status update already uses safe pattern (no artifact manipulation)

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-planner/SKILL.md` - Replace Stage 8 jq pattern, add context reference

**Verification**:
- [ ] Run `/plan` on a test task and verify no jq parse errors in output
- [ ] Confirm state.json artifacts array is correctly updated
- [ ] Confirm no INVALID_CHARACTER errors in execution log

---

### Phase 2: Update skill-status-sync with two-step jq pattern [COMPLETED]

**Goal**: Fix the canonical status update skill which is used for manual corrections and recovery operations.

**Tasks**:
- [ ] Add context reference to jq-escaping-workarounds.md in skill-status-sync SKILL.md
- [ ] Update postflight_update operation artifact handling to use two-step pattern
- [ ] Update artifact_link operation to use two-step pattern
- [ ] Add note referencing workaround document in each operation section

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-status-sync/SKILL.md` - Update jq patterns in postflight_update and artifact_link operations

**Verification**:
- [ ] Manually invoke skill-status-sync with artifact_link operation
- [ ] Verify no jq parse errors
- [ ] Confirm artifact is correctly added to state.json

---

### Phase 3: Audit and update remaining skills using jq [IN PROGRESS]

**Goal**: Ensure all skills using jq follow the workaround patterns.

**Tasks**:
- [ ] Audit skill-researcher for jq usage patterns
- [ ] Audit skill-lean-research for jq usage patterns
- [ ] Audit skill-implementer for jq usage patterns
- [ ] Audit skill-lean-implementation for jq usage patterns
- [ ] Audit skill-latex-implementation for jq usage patterns
- [ ] Audit skill-meta for jq usage patterns
- [ ] For each skill with vulnerable patterns: add context reference and fix patterns
- [ ] Create checklist of skills reviewed with status

**Timing**: 45 minutes

**Files to modify**:
- `.claude/skills/skill-researcher/SKILL.md` - If jq patterns found, update
- `.claude/skills/skill-lean-research/SKILL.md` - If jq patterns found, update
- `.claude/skills/skill-implementer/SKILL.md` - If jq patterns found, update
- `.claude/skills/skill-lean-implementation/SKILL.md` - If jq patterns found, update
- `.claude/skills/skill-latex-implementation/SKILL.md` - If jq patterns found, update
- `.claude/skills/skill-meta/SKILL.md` - If jq patterns found, update

**Verification**:
- [ ] Grep for `select(.type !=` pattern returns no matches in skill files
- [ ] All skills with jq usage reference jq-escaping-workarounds.md
- [ ] Document audit results in implementation summary

---

### Phase 4: Create reusable postflight shell scripts [NOT STARTED]

**Goal**: Encapsulate correct jq patterns in reusable scripts to prevent copy/paste errors.

**Tasks**:
- [ ] Create `.claude/scripts/postflight-research.sh` with two-step pattern
- [ ] Create `.claude/scripts/postflight-plan.sh` with two-step pattern
- [ ] Create `.claude/scripts/postflight-implement.sh` with two-step pattern
- [ ] Add usage documentation to each script header
- [ ] Update skills to reference scripts as alternative to inline patterns

**Timing**: 30 minutes

**Files to create**:
- `.claude/scripts/postflight-research.sh` - Research postflight with correct jq pattern
- `.claude/scripts/postflight-plan.sh` - Plan postflight with correct jq pattern
- `.claude/scripts/postflight-implement.sh` - Implementation postflight with correct jq pattern

**Verification**:
- [ ] Each script runs successfully with test data
- [ ] Scripts accept task_number and artifact_path as arguments
- [ ] Scripts handle missing artifact gracefully

---

### Phase 5: Add jq error logging to errors.json [NOT STARTED]

**Goal**: Enable tracking of jq failures for future pattern analysis.

**Tasks**:
- [ ] Define new error type `jq_parse_failure` in errors.json schema
- [ ] Add error logging pattern to skill-planner for jq failures
- [ ] Add error logging pattern to skill-status-sync for jq failures
- [ ] Document error logging approach in error-handling.md

**Timing**: 30 minutes

**Files to modify**:
- `specs/errors.json` - Add jq_parse_failure to schema comment
- `.claude/skills/skill-planner/SKILL.md` - Add error logging for jq failures
- `.claude/skills/skill-status-sync/SKILL.md` - Add error logging for jq failures
- `.claude/rules/error-handling.md` - Document jq_parse_failure error type

**Verification**:
- [ ] If a jq command fails, error is logged to errors.json
- [ ] Error includes session_id, original command, and error message
- [ ] Recovery action is logged if retry succeeds

---

### Phase 6: Verification and Documentation [NOT STARTED]

**Goal**: Verify all changes work together and document the improvements.

**Tasks**:
- [ ] Run end-to-end test: /plan on a fresh task
- [ ] Verify no jq errors in execution
- [ ] Verify artifacts correctly linked in state.json
- [ ] Verify TODO.md status correctly updated
- [ ] Create implementation summary documenting all changes
- [ ] Update jq-escaping-workarounds.md with reference to postflight scripts

**Timing**: 15 minutes

**Files to modify**:
- `.claude/context/core/patterns/jq-escaping-workarounds.md` - Add reference to postflight scripts

**Artifacts to create**:
- `specs/621_analyze_plan_errors_improve_agent_execution/summaries/implementation-summary-YYYYMMDD.md`

**Verification**:
- [ ] End-to-end /plan command completes without jq errors
- [ ] Implementation summary documents all files changed
- [ ] All success criteria met

## Testing & Validation

- [ ] /plan command executes without jq parse errors
- [ ] Artifacts correctly linked in state.json after postflight
- [ ] TODO.md status markers correctly updated
- [ ] Error logging captures any jq failures with session correlation
- [ ] Postflight scripts execute correctly with test data
- [ ] Grep for vulnerable patterns returns no matches in skill files

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (upon completion)
- `.claude/scripts/postflight-research.sh` (new)
- `.claude/scripts/postflight-plan.sh` (new)
- `.claude/scripts/postflight-implement.sh` (new)

## Rollback/Contingency

If changes cause unexpected failures:
1. Revert skill SKILL.md files to previous versions via git
2. Delete new postflight scripts
3. Keep jq-escaping-workarounds.md unchanged (reference only)
4. Investigate failure cause before retrying

The changes are isolated to skill instruction files and new scripts, making rollback straightforward via git revert.
