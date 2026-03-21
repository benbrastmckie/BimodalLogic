# Implementation Plan: Task #884

- **Task**: 884 - Incremental Summary Updates Per Phase
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Version**: 001
- **Created**: 2026-02-16
- **Language**: meta
- **Dependencies**: None
- **Research Inputs**: specs/884_incremental_summary_updates_per_phase/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, summary-format.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Transform implementation summaries from single-completion artifacts to running logs with per-phase entries. This enables visibility into partial progress and maintains an audit trail of changes across sessions. The implementation modifies summary-format.md to define the new incremental format, updates both implementation agents to create/update summaries after each phase, and updates skill postflight to link summaries for partial completions.

### Research Integration

Research identified that:
1. Both agents currently create summaries only at Stage 6 (full completion)
2. Skill postflight links summaries only for `implemented` status, not `partial`
3. Task 881's summary already demonstrates multi-session tracking, proving the pattern is viable
4. Progress Subsection format (task 883) provides a model for session-entry structure

## Goals & Non-Goals

**Goals**:
- Summaries become running logs updated after each phase completion
- Partial completions have summary artifacts linked in state.json
- Clear phase-by-phase documentation of changes made
- Cumulative statistics section for overall progress visibility

**Non-Goals**:
- Changing the Progress Subsection format in plan files (task 883)
- Modifying research or plan summary formats
- Real-time summary updates during phase execution (only after completion)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Summary file conflicts when resuming | Medium | Low | Append-only pattern with phase headers as anchors |
| Backward incompatibility with existing summaries | Low | Low | New format is additive; existing summaries remain valid |
| Summary update failure mid-implementation | Medium | Low | Treat as non-blocking; log warning and continue |

## Implementation Phases

### Phase 1: Update Summary Format Standard [NOT STARTED]

- **Dependencies**: None
- **Goal**: Define the incremental summary format with Phase Log structure

**Objectives**:
1. Add "Incremental Summary Format" section to summary-format.md
2. Define Phase Entry schema with required fields
3. Add Cumulative Statistics section format
4. Update status marker guidance for IN PROGRESS summaries

**Files to modify**:
- `.claude/context/core/formats/summary-format.md` - Add incremental format section (~40-50 lines)

**Steps**:
1. Read current summary-format.md to understand existing structure
2. Add new section "## Incremental Summary Format" after existing skeleton
3. Define Phase Entry schema:
   - Phase header: `### Phase N: {name} [{STATUS}]`
   - Session info: date, session_id, duration
   - Changes Made: bullet list
   - Files Modified: paths with descriptions
   - Verification: build/test results
4. Add Cumulative Statistics section:
   - Phases: N/M completed
   - Outcome delta (sorries, axioms for Lean; tests for general)
   - Overall build status
5. Update metadata to support `[IN PROGRESS]` status

**Verification**:
- summary-format.md has new Incremental Summary Format section
- Phase Entry schema is clearly documented
- Example skeleton shows running log structure

**Estimated effort**: 1 hour

---

### Phase 2: Update Lean Implementation Flow [NOT STARTED]

- **Dependencies**: Phase 1
- **Goal**: Add per-phase summary creation/update logic to lean-implementation-flow.md

**Objectives**:
1. Add Stage 4F for summary update after each phase
2. Define create-or-append logic for summary file
3. Update Stage 6 to finalize rather than create summary
4. Update completion_data to include summary artifact for partial status

**Files to modify**:
- `.claude/context/project/lean4/agents/lean-implementation-flow.md` - Add Stage 4F, modify Stage 6

**Steps**:
1. Read current lean-implementation-flow.md
2. Insert new Stage 4F after Stage 4E (Progress Subsection update):
   ```markdown
   ### 4F. Update Summary File

   After updating Progress subsection, create or update the implementation summary:

   1. Check if summary file exists at `specs/{N}_{SLUG}/summaries/implementation-summary-{DATE}.md`
   2. If exists: Append new Phase Entry to Phase Log section
   3. If not exists: Create new summary with initial Phase Entry
   4. Update Cumulative Statistics section with current totals
   5. Update metadata Status to `[IN PROGRESS]` (or `[COMPLETED]` if final phase)
   ```
3. Modify Stage 6 to finalize summary rather than create from scratch:
   - Change from "Create Implementation Summary" to "Finalize Implementation Summary"
   - Update summary metadata Status to `[COMPLETED]`
   - Ensure all Phase Entries are present
4. Update Stage 7 metadata to include summary artifact even for partial status

**Verification**:
- Stage 4F is documented with clear create-or-append logic
- Stage 6 is updated for finalization
- Stage 7 shows summary artifact in partial status example

**Estimated effort**: 45 minutes

---

### Phase 3: Update Lean Implementation Agent [NOT STARTED]

- **Dependencies**: Phase 2
- **Goal**: Reference summary update in agent's Critical Requirements

**Objectives**:
1. Add reference to Stage 4F in execution flow
2. Update Critical Requirements to include per-phase summary update
3. Ensure summary artifact is included in metadata for partial status

**Files to modify**:
- `.claude/agents/lean-implementation-agent.md` - Update Critical Requirements section

**Steps**:
1. Read current lean-implementation-agent.md
2. Add to MUST DO section:
   - "Write Phase Entry to summary file after each phase completion (Stage 4F)"
   - "Include summary artifact in metadata for both implemented and partial status"
3. Update Context References to include summary-format.md:
   ```markdown
   **Load When Creating Summary**:
   - `@.claude/context/core/formats/summary-format.md` - Incremental summary format
   ```
4. Verify existing point #9 covers summary creation, update wording if needed

**Verification**:
- MUST DO includes per-phase summary update requirement
- Context References includes summary-format.md
- Agent instructions are consistent with lean-implementation-flow.md

**Estimated effort**: 15 minutes

---

### Phase 4: Update General Implementation Agent [NOT STARTED]

- **Dependencies**: Phase 1
- **Goal**: Add per-phase summary update to Phase Checkpoint Protocol

**Objectives**:
1. Add summary update step to Phase Checkpoint Protocol
2. Define create-or-append logic inline (no external flow file)
3. Update Stage 6 to finalize rather than create
4. Update Critical Requirements

**Files to modify**:
- `.claude/agents/general-implementation-agent.md` - Add summary update to protocol, update Stage 6

**Steps**:
1. Read current general-implementation-agent.md
2. Update Phase Checkpoint Protocol (after step 5, Write Progress subsection):
   ```markdown
   6. **Update summary file** with Phase Entry:
      - If first phase: Create summary at `specs/{N}_{SLUG}/summaries/implementation-summary-{DATE}.md`
      - If subsequent: Append Phase Entry to existing summary
      - Update Cumulative Statistics section
   7. **Git commit** with message... (renumber remaining steps)
   ```
3. Update Stage 6 from "Create Implementation Summary" to "Finalize Implementation Summary":
   - Summary already exists with Phase Entries
   - Update metadata Status to `[COMPLETED]`
   - Verify all phases have entries
4. Add to Critical Requirements MUST DO:
   - "Update summary file with Phase Entry after each phase completion"
   - "Include summary artifact in metadata for both implemented and partial status"
5. Add to Context References:
   ```markdown
   **Load When Creating Summary**:
   - `@.claude/context/core/formats/summary-format.md` - Incremental summary format
   ```

**Verification**:
- Phase Checkpoint Protocol includes summary update step
- Stage 6 is updated for finalization
- Critical Requirements include per-phase summary update

**Estimated effort**: 30 minutes

---

### Phase 5: Update Skill Postflight (Both Skills) [NOT STARTED]

- **Dependencies**: Phases 2, 3, 4
- **Goal**: Link summary artifacts for partial status in both skill postflight sections

**Objectives**:
1. Update skill-implementer Stage 8 to link summary for partial status
2. Update skill-lean-implementation Stage 8 to link summary for partial status
3. Ensure artifact linking logic handles both implemented and partial

**Files to modify**:
- `.claude/skills/skill-implementer/SKILL.md` - Update Stage 8 artifact linking
- `.claude/skills/skill-lean-implementation/SKILL.md` - Update Stage 8 artifact linking

**Steps**:
1. Read current skill-implementer/SKILL.md
2. Update Stage 8 to handle summary artifact for partial status:
   - Add logic to find summary artifact in metadata (regardless of status)
   - Link summary artifact to state.json for both `implemented` and `partial` status
   - Update TODO.md with Summary link for partial status
3. Read current skill-lean-implementation/SKILL.md
4. Apply same updates to Stage 8

**Verification**:
- Both skills link summary artifacts for `partial` status
- Artifact linking code handles missing summary gracefully
- TODO.md Summary link added for partial completions

**Estimated effort**: 30 minutes

---

## Testing & Validation

- [ ] summary-format.md has complete Incremental Summary Format section
- [ ] lean-implementation-flow.md has Stage 4F with clear logic
- [ ] lean-implementation-agent.md references Stage 4F in Critical Requirements
- [ ] general-implementation-agent.md has summary update in Phase Checkpoint Protocol
- [ ] Both skill SKILL.md files link summary for partial status
- [ ] All files pass lint/formatting checks (if applicable)
- [ ] Documentation is internally consistent across all modified files

## Artifacts & Outputs

- `summary-format.md` - Updated with Incremental Summary Format section
- `lean-implementation-flow.md` - Updated with Stage 4F
- `lean-implementation-agent.md` - Updated Critical Requirements
- `general-implementation-agent.md` - Updated Phase Checkpoint Protocol
- `skill-implementer/SKILL.md` - Updated artifact linking
- `skill-lean-implementation/SKILL.md` - Updated artifact linking

## Rollback/Contingency

If issues arise:
1. Revert to previous versions via git history
2. Existing single-completion summaries remain compatible
3. Skill postflight changes are additive (won't break existing flows)

The changes are backward compatible - agents can still create summaries at completion if the incremental approach fails.
