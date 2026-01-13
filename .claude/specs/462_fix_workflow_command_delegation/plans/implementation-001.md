# Implementation Plan: Task #462

- **Task**: 462 - Fix workflow command delegation
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: .claude/specs/462_fix_workflow_command_delegation/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

The /research and /implement commands complete CHECKPOINT 1 (GATE IN) via skill-status-sync but fail to proceed to STAGE 2 delegation. Root cause: command files use descriptive language ("Invoke skill with:") instead of imperative instructions that trigger action. The working /meta command demonstrates the correct pattern by using "Invoke skill-meta via Skill tool with:" immediately without a separate preflight checkpoint.

### Research Integration

Research report (research-001.md) identified:
- Command files document workflow as description rather than executable instructions
- After preflight completes, Claude interprets descriptive STAGE 2 as documentation
- The /meta command works because it immediately delegates without ambiguous phrasing
- Recommendation: Option A (minimal change) - add explicit "Execute Now: Use the Skill tool" directives

## Goals & Non-Goals

**Goals**:
- Fix /research command to delegate to skill-researcher/skill-lean-research after preflight
- Fix /implement command to delegate to skill-implementer/skill-lean-implementation after preflight
- Maintain checkpoint-based execution model structure
- Preserve session ID tracking through delegation

**Non-Goals**:
- Restructure commands into single-skill orchestrators (Option B - future work)
- Change the preflight/postflight checkpoint model
- Modify skill or agent files (issue is in command files)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Fix is still ambiguous | Commands still stop | Medium | Use explicit "EXECUTE NOW" with code-like Skill invocation |
| Break existing behavior | Regression in working paths | Low | Test /meta still works after changes |
| Session ID not passed correctly | Lost traceability | Low | Include session_id explicitly in Skill args |
| Skill routing logic unclear | Wrong skill invoked | Low | Use clear routing table with exact skill names |

## Implementation Phases

### Phase 1: Fix /research Command [NOT STARTED]

**Goal**: Make /research command proceed from GATE IN to STAGE 2 delegation

**Tasks**:
- [ ] Add explicit continuation directive after GATE IN
- [ ] Change STAGE 2 from descriptive to imperative format
- [ ] Add "EXECUTE NOW" prefix with Skill tool invocation syntax
- [ ] Include explicit language-based routing with skill names
- [ ] Ensure session_id is passed in Skill args

**Files to modify**:
- `.claude/commands/research.md` - Rewrite STAGE 2 section with imperative instructions

**Timing**: 45 minutes

**Verification**:
- Review updated research.md has imperative "Execute Now" directive
- Confirm Skill tool invocation syntax is explicit
- Confirm routing table lists exact skill names (skill-lean-research, skill-researcher)

---

### Phase 2: Fix /implement Command [NOT STARTED]

**Goal**: Make /implement command proceed from GATE IN to STAGE 2 delegation

**Tasks**:
- [ ] Add explicit continuation directive after GATE IN (step 7)
- [ ] Change STAGE 2 from descriptive to imperative format
- [ ] Add "EXECUTE NOW" prefix with Skill tool invocation syntax
- [ ] Include explicit language-based routing with skill names
- [ ] Ensure all required args (plan_path, resume_phase, session_id) are in Skill args

**Files to modify**:
- `.claude/commands/implement.md` - Rewrite STAGE 2 section with imperative instructions

**Timing**: 45 minutes

**Verification**:
- Review updated implement.md has imperative "Execute Now" directive
- Confirm Skill tool invocation syntax is explicit
- Confirm routing table lists exact skill names (skill-lean-implementation, skill-latex-implementation, skill-implementer)

---

### Phase 3: Verify /plan Command [NOT STARTED]

**Goal**: Ensure /plan command follows the same pattern and doesn't have the same issue

**Tasks**:
- [ ] Read .claude/commands/plan.md
- [ ] Check if STAGE 2 uses imperative or descriptive language
- [ ] If descriptive, apply same fix pattern as research/implement
- [ ] If imperative, confirm it matches the fixed pattern

**Files to modify**:
- `.claude/commands/plan.md` - Only if fix needed

**Timing**: 30 minutes

**Verification**:
- /plan command has consistent imperative delegation pattern
- If no fix needed, document why it works

---

### Phase 4: Test End-to-End Execution [NOT STARTED]

**Goal**: Verify all fixed commands delegate correctly

**Tasks**:
- [ ] Test /research on a test task proceeds past preflight
- [ ] Test /implement on a planned task proceeds past preflight
- [ ] Test /plan (if modified) proceeds correctly
- [ ] Verify /meta still works (regression check)
- [ ] Document any issues found

**Timing**: 30 minutes

**Verification**:
- Commands proceed to STAGE 2 and invoke skills
- Session IDs are passed through delegation
- No regression in /meta command

## Testing & Validation

- [ ] /research {N} proceeds from [RESEARCHING] to skill invocation
- [ ] /implement {N} proceeds from [IMPLEMENTING] to skill invocation
- [ ] /plan {N} proceeds correctly (if modified)
- [ ] /meta still works as expected
- [ ] Session ID appears in skill delegation context
- [ ] Language routing selects correct skill

## Artifacts & Outputs

- `.claude/commands/research.md` - Fixed with imperative STAGE 2
- `.claude/commands/implement.md` - Fixed with imperative STAGE 2
- `.claude/commands/plan.md` - Fixed if needed
- `.claude/specs/462_fix_workflow_command_delegation/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If changes break command execution:
1. Revert to pre-change versions using git: `git checkout HEAD~1 -- .claude/commands/{research,implement,plan}.md`
2. Re-analyze failure mode
3. Consider Option B (single orchestrating skill) if Option A proves insufficient
