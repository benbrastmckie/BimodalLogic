# Implementation Plan: Task #884

- **Task**: 884 - Incremental Summary Updates Per Phase
- **Status**: [IMPLEMENTING]
- **Effort**: 3.5 hours
- **Version**: 002
- **Created**: 2026-02-16
- **Revised**: 2026-02-17
- **Language**: meta
- **Dependencies**: None
- **Research Inputs**:
  - specs/884_incremental_summary_updates_per_phase/reports/research-001.md (summary patterns)
  - specs/884_incremental_summary_updates_per_phase/reports/research-002.md (context file analysis)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, artifact-formats.md, summary-format.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Transform implementation summaries from single-completion artifacts to running logs with per-phase entries. This enables visibility into partial progress and maintains an audit trail of changes across sessions.

### Changes from v001

**Incorporated from research-002.md**:
1. **Phase 0 added**: Remove deprecated orchestration files (quick cleanup, 15min)
2. **Explicit context loading references**: Each phase now specifies exactly which context files to load
3. **Phase 6 added**: Create metadata-quick-ref.md (context efficiency improvement)
4. **Clarified Progress vs Summary distinction**: Progress subsection in plan files vs implementation summary files

**Structure changes**:
- 6 phases (was 5) + Phase 0 prep
- Added "Context to Load" section to each phase
- Added "Context Efficiency Notes" section

### Research Integration

Research-001.md identified:
1. Both agents currently create summaries only at Stage 6 (full completion)
2. Skill postflight links summaries only for `implemented` status, not `partial`
3. Task 881's summary already demonstrates multi-session tracking
4. Progress Subsection format (task 883) provides a model for session-entry structure

Research-002.md identified:
1. 6 deprecated orchestration files should be removed
2. return-metadata-file.md (545 lines) is too heavy for routine loading
3. Implementation agents load ~1,000-1,700 lines before task-specific files
4. A focused metadata-quick-ref.md (~50 lines) would reduce overhead

## Goals & Non-Goals

**Goals**:
- Summaries become running logs updated after each phase completion
- Partial completions have summary artifacts linked in state.json
- Clear phase-by-phase documentation of changes made
- Cumulative statistics section for overall progress visibility
- Cleaner context loading (remove deprecated files, add quick reference)

**Non-Goals**:
- Changing the Progress Subsection format in plan files (task 883)
- Modifying research or plan summary formats
- Real-time summary updates during phase execution (only after completion)
- Full context file reorganization (out of scope - separate task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Summary file conflicts when resuming | Medium | Low | Append-only pattern with phase headers as anchors |
| Backward incompatibility with existing summaries | Low | Low | New format is additive; existing summaries remain valid |
| Summary update failure mid-implementation | Medium | Low | Treat as non-blocking; log warning and continue |
| Deprecated file references in other files | Low | Medium | Grep for references before deletion |

## Implementation Phases

### Phase 0: Cleanup Deprecated Files [COMPLETED]

- **Dependencies**: None
- **Goal**: Remove deprecated orchestration files to prevent accidental loading

**Objectives**:
1. Delete 6 deprecated files from core/orchestration/
2. Verify no active files reference them

**Context to Load**:
- `.claude/context/index.md` (line ~200-220, deprecation list)

**Files to delete**:
- `.claude/context/core/orchestration/orchestrator.md`
- `.claude/context/core/orchestration/delegation.md`
- `.claude/context/core/orchestration/routing.md`
- `.claude/context/core/orchestration/validation.md`
- `.claude/context/core/orchestration/subagent-validation.md`
- `.claude/context/core/orchestration/sessions.md`

**Steps**:
1. Grep codebase for references to each deprecated file
2. If references exist: update them to point to consolidated files
3. Delete the 6 deprecated files
4. Update index.md to remove "Deprecated" section (files no longer exist)

**Verification**:
- Deprecated files no longer exist on disk
- No broken references in remaining files
- index.md updated

**Estimated effort**: 15 minutes

**Progress:**

**Session: 2026-02-16, sess_1771307296_4d328c**
- Removed: 6 deprecated orchestration files (orchestrator.md, delegation.md, routing.md, validation.md, subagent-validation.md, sessions.md)
- Fixed: 6 files with broken references updated to point to consolidated files
- Updated: index.md, architecture.md, command-structure.md, context-loading-best-practices.md, context-revision-guide.md, README.md

---

### Phase 1: Update Summary Format Standard [COMPLETED]

- **Dependencies**: Phase 0
- **Goal**: Define the incremental summary format with Phase Log structure

**Objectives**:
1. Add "Incremental Summary Format" section to summary-format.md
2. Define Phase Entry schema with required fields
3. Add Cumulative Statistics section format
4. Update status marker guidance for IN PROGRESS summaries
5. Clarify relationship to Progress Subsection (different purposes)

**Context to Load**:
- `.claude/context/core/formats/summary-format.md` (current format)
- `.claude/rules/artifact-formats.md` (Progress Subsection for reference, do NOT modify)

**Files to modify**:
- `.claude/context/core/formats/summary-format.md` - Add incremental format section (~50-60 lines)

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
5. Add "Progress vs Summary" clarification note:
   - Progress Subsection: In plan file, tracks attempts during implementation
   - Summary Phase Entry: In summary file, documents outcomes after each phase
6. Update metadata to support `[IN PROGRESS]` status

**Verification**:
- summary-format.md has new Incremental Summary Format section
- Phase Entry schema is clearly documented
- Example skeleton shows running log structure
- Distinction from Progress Subsection is clear

**Estimated effort**: 45 minutes

**Progress:**

**Session: 2026-02-16, sess_1771307296_4d328c**
- Added: Incremental Summary Format section (~130 lines) to summary-format.md
- Added: Phase Entry schema with required/optional fields table
- Added: Cumulative Statistics section format with metrics table
- Added: Progress vs Summary distinction section
- Added: Create-or-append logic for summary updates
- Added: Complete incremental summary skeleton

---

### Phase 2: Update Lean Implementation Flow [COMPLETED]

- **Dependencies**: Phase 1
- **Goal**: Add per-phase summary creation/update logic to lean-implementation-flow.md

**Objectives**:
1. Add Stage 4F for summary update after each phase
2. Define create-or-append logic for summary file
3. Update Stage 6 to finalize rather than create summary
4. Update completion_data to include summary artifact for partial status

**Context to Load**:
- `.claude/context/project/lean4/agents/lean-implementation-flow.md` (current flow)
- `.claude/context/core/formats/summary-format.md` (Phase Entry format from Phase 1)

**Files to modify**:
- `.claude/context/project/lean4/agents/lean-implementation-flow.md` - Add Stage 4F, modify Stage 6

**Steps**:
1. Read current lean-implementation-flow.md
2. Insert new Stage 4F after Stage 4E (Progress Subsection update):
   ```markdown
   ### 4F. Update Implementation Summary

   After updating Progress subsection, create or update the implementation summary:

   **Load**: @.claude/context/core/formats/summary-format.md (Incremental format section)

   1. Check if summary file exists at `specs/{N}_{SLUG}/summaries/implementation-summary-{DATE}.md`
   2. If exists: Append new Phase Entry to Phase Log section
   3. If not exists: Create new summary with initial Phase Entry
   4. Update Cumulative Statistics section with current totals
   5. Set header Status to `[IN PROGRESS]` (or `[COMPLETED]` if final phase)
   ```
3. Modify Stage 6 to finalize summary rather than create from scratch:
   - Change from "Create Implementation Summary" to "Finalize Implementation Summary"
   - Update summary header Status to `[COMPLETED]`
   - Ensure all Phase Entries are present
4. Update Stage 7 metadata to include summary artifact even for partial status

**Verification**:
- Stage 4F is documented with clear create-or-append logic
- Stage 6 is updated for finalization
- Stage 7 shows summary artifact in partial status example

**Estimated effort**: 45 minutes

**Progress:**

**Session: 2026-02-16, sess_1771307296_4d328c**
- Added: Stage 4F (Update Implementation Summary) with create-or-append logic
- Fixed: Stage 6 changed from "Create" to "Finalize" with update steps
- Fixed: Stage 7 metadata to include summary artifact for both implemented and partial status
- Updated: Phase Checkpoint Protocol step 6 to include summary update, step 7 for git staging
- Updated: git staging to include summaries/ directory

---

### Phase 3: Update Lean Implementation Agent [NOT STARTED]

- **Dependencies**: Phase 2
- **Goal**: Reference summary update in agent's Critical Requirements

**Objectives**:
1. Add reference to Stage 4F in execution flow
2. Update Critical Requirements to include per-phase summary update
3. Ensure summary artifact is included in metadata for partial status
4. Add summary-format.md to Context References

**Context to Load**:
- `.claude/agents/lean-implementation-agent.md` (current agent)

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
4. Verify existing summary creation guidance is consistent with new approach

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
5. Add summary-format.md to Context References

**Context to Load**:
- `.claude/agents/general-implementation-agent.md` (current agent)
- `.claude/context/core/formats/summary-format.md` (Phase Entry format from Phase 1)

**Files to modify**:
- `.claude/agents/general-implementation-agent.md` - Add summary update to protocol, update Stage 6

**Steps**:
1. Read current general-implementation-agent.md
2. Update Phase Checkpoint Protocol (after step 5, Write Progress subsection):
   ```markdown
   6. **Update summary file** with Phase Entry:
      **Load**: @.claude/context/core/formats/summary-format.md
      - If first phase: Create summary at `specs/{N}_{SLUG}/summaries/implementation-summary-{DATE}.md`
      - If subsequent: Append Phase Entry to existing summary's Phase Log
      - Update Cumulative Statistics section
   7. **Git commit** with message... (renumber remaining steps)
   ```
3. Update Stage 6 from "Create Implementation Summary" to "Finalize Implementation Summary":
   - Summary already exists with Phase Entries
   - Update header Status to `[COMPLETED]`
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
- Context References includes summary-format.md

**Estimated effort**: 30 minutes

---

### Phase 5: Update Skill Postflight (Both Skills) [NOT STARTED]

- **Dependencies**: Phases 2, 3, 4
- **Goal**: Link summary artifacts for partial status in both skill postflight sections

**Objectives**:
1. Update skill-implementer Stage 8 to link summary for partial status
2. Update skill-lean-implementation Stage 8 to link summary for partial status
3. Ensure artifact linking logic handles both implemented and partial

**Context to Load**:
- `.claude/skills/skill-implementer/SKILL.md` (current skill)
- `.claude/skills/skill-lean-implementation/SKILL.md` (current skill)

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

### Phase 6: Create Metadata Quick Reference [NOT STARTED]

- **Dependencies**: None (parallel with Phases 1-5)
- **Goal**: Create focused metadata schema reference to reduce context loading overhead

**Objectives**:
1. Create metadata-quick-ref.md (~50 lines)
2. Extract essential fields from return-metadata-file.md
3. Update agent references to prefer quick reference for routine cases

**Context to Load**:
- `.claude/context/core/formats/return-metadata-file.md` (source of fields)

**Files to create**:
- `.claude/context/core/formats/metadata-quick-ref.md` - New quick reference

**Steps**:
1. Read return-metadata-file.md to identify essential fields
2. Create metadata-quick-ref.md with:
   - Essential status values: implemented, partial, blocked, failed
   - Core artifact fields: path, type, summary
   - Common metadata: session_id, phase_count
   - Link to full schema for edge cases
3. Add note to return-metadata-file.md header:
   ```markdown
   **Quick Reference**: For common cases, use @.claude/context/core/formats/metadata-quick-ref.md
   ```

**Verification**:
- metadata-quick-ref.md exists and is ~50 lines
- Contains essential fields with clear examples
- Links to full schema for complex cases

**Estimated effort**: 20 minutes

---

## Context Efficiency Notes

From research-002.md, these context loading improvements should be applied:

| When | Load This | Not This |
|------|-----------|----------|
| Writing metadata | metadata-quick-ref.md (~50 lines) | return-metadata-file.md (545 lines) |
| Writing summary | summary-format.md (~60 lines) | Full summary-format.md + artifact-formats.md |
| Writing progress | artifact-formats.md Progress section only | Full artifact-formats.md (350 lines) |

**Lazy Loading Pattern**: All context references use `@` prefix for lazy loading. Only load when entering the relevant stage.

## Testing & Validation

- [ ] Phase 0: Deprecated orchestration files removed
- [ ] Phase 1: summary-format.md has complete Incremental Summary Format section
- [ ] Phase 2: lean-implementation-flow.md has Stage 4F with clear logic
- [ ] Phase 3: lean-implementation-agent.md references Stage 4F in Critical Requirements
- [ ] Phase 4: general-implementation-agent.md has summary update in Phase Checkpoint Protocol
- [ ] Phase 5: Both skill SKILL.md files link summary for partial status
- [ ] Phase 6: metadata-quick-ref.md exists and is referenced
- [ ] All files pass lint/formatting checks (if applicable)
- [ ] Documentation is internally consistent across all modified files

## Artifacts & Outputs

**Files to delete** (Phase 0):
- 6 deprecated orchestration files

**Files to modify**:
- `summary-format.md` - Updated with Incremental Summary Format section
- `lean-implementation-flow.md` - Updated with Stage 4F
- `lean-implementation-agent.md` - Updated Critical Requirements
- `general-implementation-agent.md` - Updated Phase Checkpoint Protocol
- `skill-implementer/SKILL.md` - Updated artifact linking
- `skill-lean-implementation/SKILL.md` - Updated artifact linking
- `index.md` - Remove deprecated files list

**Files to create**:
- `metadata-quick-ref.md` - New quick reference

## Follow-On Work (Out of Scope)

From research-002.md, these improvements are recommended but not included in this plan:

1. **Create implementation-essentials.md** (~100 lines) - Condensed phase checkpoint protocol
2. **Consolidate progress tracking docs** - Clarify progress-file.md vs artifact-formats.md Progress
3. **Verify git-staging-scope.md** - Create if missing

These should be tracked as separate tasks.

## Rollback/Contingency

If issues arise:
1. Revert to previous versions via git history
2. Existing single-completion summaries remain compatible
3. Skill postflight changes are additive (won't break existing flows)
4. Phase 0 deletions can be restored from git

The changes are backward compatible - agents can still create summaries at completion if the incremental approach fails.
