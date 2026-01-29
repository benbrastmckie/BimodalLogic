# Implementation Plan: Task #762

- **Task**: 762 - fix_planner_agent_enforce_status_field
- **Status**: [IMPLEMENTING]
- **Effort**: 1 hour
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/762_fix_planner_agent_enforce_status_field/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This task fixes a gap in the planner-agent that allows plans to be created without required metadata fields. Task 750's v005 plan was missing the Status field despite the template in Stage 5 including it. The fix moves plan-format.md to the "Always Load" section and adds an explicit verification step in Stage 6 to ensure all required fields (especially Status) exist before writing success metadata.

### Research Integration

Research findings confirmed:
1. Task 750 v005 plan is missing `- **Status**: [NOT STARTED]` while tasks 758, 759, 741 all have it
2. plan-format.md explicitly lists Status as a required field (line 8)
3. The planner-agent template includes Status, but no verification enforces its presence
4. Moving plan-format.md to "Always Load" ensures agents always have the format specification
5. Adding verification in Stage 6 provides a safety net before declaring success

## Goals & Non-Goals

**Goals**:
- Ensure plan-format.md is always loaded by planner-agent (not optional)
- Add explicit verification step to check required fields before success metadata
- Prevent future plans from missing the Status field
- Keep changes minimal and focused

**Non-Goals**:
- Fixing the existing Task 750 v005 plan (separate manual fix)
- Adding validation for all 10 required fields (focus on Status as the critical one)
- Restructuring the agent's execution flow

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Agents may still skip "Always Load" context | Medium | Low | Verification step catches this |
| Verification adds complexity | Low | Medium | Keep verification simple (grep for field) |
| Edit/re-verify loop could fail | Low | Low | Clear instructions for re-reading plan-format.md |

## Implementation Phases

### Phase 1: Update Context References Section [COMPLETED]

**Goal**: Move plan-format.md from "Load When Creating Plan" to "Always Load" section

**Tasks**:
- [ ] Edit lines 39-44 in `.claude/agents/planner-agent.md`
- [ ] Move plan-format.md to Always Load section
- [ ] Update description to emphasize REQUIRED fields

**Timing**: 10 minutes

**Files to modify**:
- `.claude/agents/planner-agent.md` - Lines 39-44 (Context References section)

**Verification**:
- plan-format.md appears under "Always Load" section
- task-breakdown.md remains under "Load When Creating Plan" section

---

### Phase 2: Add Verification Step in Stage 6 [COMPLETED]

**Goal**: Insert verification step at the beginning of Stage 6 to check required fields exist

**Tasks**:
- [ ] Rename Stage 6 to "Verify Plan and Write Metadata File"
- [ ] Add pre-check section with required field verification
- [ ] Include instructions for fixing missing fields before proceeding

**Timing**: 20 minutes

**Files to modify**:
- `.claude/agents/planner-agent.md` - Stage 6 section (around line 250)

**Verification**:
- Stage 6 heading includes "Verify Plan"
- Pre-check section lists required metadata fields
- Instructions for fixing missing fields are present

---

### Phase 3: Update Critical Requirements Section [COMPLETED]

**Goal**: Add explicit requirement to verify Status field before success metadata

**Tasks**:
- [ ] Add item 10 to "MUST DO" list requiring Status field verification
- [ ] Ensure numbering is correct after addition

**Timing**: 5 minutes

**Files to modify**:
- `.claude/agents/planner-agent.md` - Critical Requirements section (around line 377)

**Verification**:
- MUST DO list includes Status field verification requirement
- Item numbering is sequential and correct

---

### Phase 4: Verify All Changes [IN PROGRESS]

**Goal**: Confirm all edits are consistent and complete

**Tasks**:
- [ ] Re-read the modified planner-agent.md file
- [ ] Verify no broken markdown structure
- [ ] Verify stage numbering is still correct
- [ ] Confirm changes match research recommendations

**Timing**: 10 minutes

**Files to modify**:
- None (read-only verification)

**Verification**:
- File parses as valid markdown
- All stage numbers sequential
- All list numbers sequential
- Changes align with research-001.md recommendations

## Testing & Validation

- [ ] Confirm plan-format.md is in "Always Load" section
- [ ] Confirm Stage 6 includes verification step
- [ ] Confirm MUST DO list includes Status verification
- [ ] Confirm no markdown syntax errors introduced

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (after implementation)
- Modified: `.claude/agents/planner-agent.md`

## Rollback/Contingency

If changes cause issues:
1. Revert `.claude/agents/planner-agent.md` via git checkout
2. The original file is preserved in git history
3. No other files are modified, so rollback is straightforward
