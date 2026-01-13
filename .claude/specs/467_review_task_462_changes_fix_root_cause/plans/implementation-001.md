# Implementation Plan: Task #467

- **Task**: 467 - Review task 462 changes and fix root cause of workflow delegation errors
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: .claude/specs/467_review_task_462_changes_fix_root_cause/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This plan addresses workflow delegation errors where Claude stops after skill invocations return instead of continuing through the checkpoint-based execution model. The research identified that task 462's changes (adding "EXECUTE NOW" language) are correct but incomplete. The root cause is that command files lack explicit continuation markers between checkpoints. This plan adds "IMMEDIATELY CONTINUE" markers to create unambiguous control flow, keeping changes minimal and elegant.

### Research Integration

Key findings from research-001.md:
- Two failure points identified: after preflight skill-status-sync returns, and after delegation skill returns
- Task 462's "EXECUTE NOW" phrasing addresses the right problem but is insufficient
- The fundamental issue is Claude interpreting skill JSON returns as transaction boundaries
- /meta command works because it has no preflight checkpoint (no intermediate returns)

## Goals & Non-Goals

**Goals**:
- Fix workflow delegation errors with minimal, targeted changes
- Add explicit continuation markers between checkpoints
- Keep task 462's improvements ("EXECUTE NOW", routing tables)
- Update command-lifecycle.md to document the pattern

**Non-Goals**:
- Refactoring commands into orchestrator skills (too invasive)
- Restructuring the checkpoint-based architecture
- Changing /meta command (already working)
- Adding continuation markers where not needed

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Continuation markers still ambiguous | Commands still stop mid-flow | Use specific, unambiguous language: "IMMEDIATELY CONTINUE to {section} below" |
| Changes break working commands | Regression | Test /meta still works after changes |
| Over-engineering the solution | Unnecessary complexity | Apply minimal changes, one consistent pattern |
| Documentation becomes inconsistent | Confusion | Update all three affected commands together |

## Implementation Phases

### Phase 1: Update research.md [NOT STARTED]

**Goal**: Add explicit continuation markers to /research command file

**Tasks**:
- [ ] Replace "PROCEED if all pass" after GATE IN with "On GATE IN success: Status is [RESEARCHING]. IMMEDIATELY CONTINUE to STAGE 2 below."
- [ ] Add continuation marker after STAGE 2 DELEGATE: "On DELEGATE success: Research complete. IMMEDIATELY CONTINUE to CHECKPOINT 2 below."
- [ ] Add continuation marker after CHECKPOINT 2 GATE OUT: "On GATE OUT success: IMMEDIATELY CONTINUE to CHECKPOINT 3 below."
- [ ] Verify command structure is coherent

**Timing**: 20 minutes

**Files to modify**:
- `.claude/commands/research.md` - Add 3 continuation markers

**Verification**:
- File contains "IMMEDIATELY CONTINUE" markers after each checkpoint
- "EXECUTE NOW" language preserved from task 462
- Routing table preserved

---

### Phase 2: Update plan.md and implement.md [NOT STARTED]

**Goal**: Apply same continuation marker pattern to remaining affected commands

**Tasks**:
- [ ] Update plan.md: Add "IMMEDIATELY CONTINUE" markers after GATE IN, DELEGATE, and GATE OUT
- [ ] Update implement.md: Add "IMMEDIATELY CONTINUE" markers after GATE IN, DELEGATE, and GATE OUT
- [ ] Ensure consistent language across all three commands

**Timing**: 30 minutes

**Files to modify**:
- `.claude/commands/plan.md` - Add 3 continuation markers
- `.claude/commands/implement.md` - Add 3 continuation markers

**Verification**:
- Both files contain matching continuation marker pattern
- "EXECUTE NOW" language preserved
- Routing tables preserved

---

### Phase 3: Update command-lifecycle.md documentation [NOT STARTED]

**Goal**: Document the continuation marker pattern for future reference

**Tasks**:
- [ ] Add "Control Flow in Commands" section documenting the pattern
- [ ] Include the standard template: "On {checkpoint} success: IMMEDIATELY CONTINUE to {next_section} below."
- [ ] Explain why this pattern prevents Claude from treating skill returns as stopping points

**Timing**: 20 minutes

**Files to modify**:
- `.claude/context/core/workflows/command-lifecycle.md` - Add documentation section

**Verification**:
- Documentation explains the pattern clearly
- Provides template for future commands
- References the root cause issue

---

### Phase 4: Verification and cleanup [NOT STARTED]

**Goal**: Verify all changes work correctly and remove any cruft

**Tasks**:
- [ ] Verify /meta command still works (regression check)
- [ ] Review all three updated command files for consistency
- [ ] Check for any cruft from task 462 that should be removed
- [ ] Ensure documentation is accurate and complete

**Timing**: 20 minutes

**Files to review**:
- `.claude/commands/research.md`
- `.claude/commands/plan.md`
- `.claude/commands/implement.md`
- `.claude/commands/meta.md` (verify unchanged and working)
- `.claude/context/core/workflows/command-lifecycle.md`

**Verification**:
- All continuation markers use consistent language
- No redundant or conflicting instructions
- /meta command unchanged
- Documentation accurate

## Testing & Validation

- [ ] Run /research on a test task and verify continuous execution through all checkpoints
- [ ] Run /plan on a test task and verify continuous execution
- [ ] Run /implement on a test task and verify continuous execution
- [ ] Verify /meta still works without modification

## Artifacts & Outputs

- `.claude/specs/467_review_task_462_changes_fix_root_cause/plans/implementation-001.md` (this file)
- `.claude/specs/467_review_task_462_changes_fix_root_cause/summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If the continuation markers prove insufficient:
1. Revert command file changes using git
2. Consider alternative approach: consolidate into orchestrator skills (more invasive but eliminates multiple-return-point problem)
3. Document failure mode for future iteration
