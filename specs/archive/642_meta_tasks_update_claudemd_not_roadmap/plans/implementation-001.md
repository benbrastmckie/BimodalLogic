# Implementation Plan: Task #642

- **Task**: 642 - meta_tasks_update_claudemd_not_roadmap
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Priority**: Medium
- **Dependencies**: Task 641 (completed)
- **Research Inputs**: specs/642_meta_tasks_update_claudemd_not_roadmap/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This plan implements language-based filtering in the /todo command so that meta tasks (language: "meta") update CLAUDE.md instead of ROAD_MAP.md. The implementation adds a "Recent System Changes" rolling log section to CLAUDE.md, introduces the `claudemd_items` field in state.json for explicit matching, and modifies the /todo command to filter tasks by language and handle meta tasks separately.

### Research Integration

Key findings from research-001.md:
- /todo command Step 3.5 and Step 5.5 handle ROAD_MAP.md updates without language filtering
- No existing language-based filtering for post-completion handling
- CLAUDE.md needs a "Recent System Changes" section with rolling log (max 10 entries)
- The `claudemd_items` field should parallel `roadmap_items` for consistency

## Goals & Non-Goals

**Goals**:
- Exclude meta tasks from ROAD_MAP.md updates in /todo
- Add CLAUDE.md update handling for meta tasks
- Implement rolling log with automatic pruning (max 10 entries)
- Support explicit `claudemd_items` matching
- Document the new field in state-management.md

**Non-Goals**:
- Refactoring the entire /todo command
- Adding CLAUDE.md matching to /implement (deferred)
- Complex section-based matching in CLAUDE.md (simple rolling log only)
- Retroactive updates for already-completed meta tasks

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| CLAUDE.md bloat | Medium | Low | Rolling log limited to 10 entries, automatic pruning |
| Missing meta tasks | Low | Low | Explicit language check in Step 3.5 ensures filtering |
| Backward compatibility | Low | Low | New fields are optional; existing tasks unaffected |
| Section parsing errors | Medium | Low | Use clear markers for Recent System Changes section |

## Implementation Phases

### Phase 1: Schema Documentation [NOT STARTED]

**Goal**: Document the `claudemd_items` field in state-management.md

**Tasks**:
- [ ] Add `claudemd_items` to Completion Fields Schema table
- [ ] Add usage notes explaining meta task handling
- [ ] Update state.json example to show the field

**Timing**: 15 minutes

**Files to modify**:
- `.claude/rules/state-management.md` - Add claudemd_items field documentation

**Verification**:
- Schema table includes claudemd_items with correct type (array of strings)
- Usage notes explain relationship to meta tasks

---

### Phase 2: Add CLAUDE.md Section [NOT STARTED]

**Goal**: Add "Recent System Changes" section to CLAUDE.md

**Tasks**:
- [ ] Add new section before "Important Notes"
- [ ] Use format: `- [YYYY-MM-DD] Task #N: {summary}`
- [ ] Add initial entry for Task 641 as example

**Timing**: 15 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - Add "Recent System Changes" section

**Verification**:
- New section visible in CLAUDE.md
- Format matches specification
- Section is before "Important Notes"

---

### Phase 3: Language Filtering in /todo Step 3.5 [NOT STARTED]

**Goal**: Filter meta tasks out of ROAD_MAP.md scanning

**Tasks**:
- [ ] Add language check in Step 3.5 task loop
- [ ] Create separate array for meta tasks
- [ ] Skip meta tasks in roadmap matching logic
- [ ] Add comments explaining the filtering

**Timing**: 30 minutes

**Files to modify**:
- `.claude/commands/todo.md` - Modify Step 3.5

**Verification**:
- Meta tasks are not matched against ROAD_MAP.md
- Non-meta tasks continue to work as before
- Dry-run output separates meta tasks

---

### Phase 4: CLAUDE.md Scanning (New Step 3.6) [NOT STARTED]

**Goal**: Scan meta tasks for CLAUDE.md updates

**Tasks**:
- [ ] Add new Step 3.6 after Step 3.5
- [ ] Extract meta tasks collected in Phase 3
- [ ] Check for `claudemd_items` field in each
- [ ] Build list of CLAUDE.md updates

**Timing**: 30 minutes

**Files to modify**:
- `.claude/commands/todo.md` - Add Step 3.6

**Verification**:
- Meta tasks with claudemd_items are tracked
- Meta tasks without claudemd_items still get logged (using completion_summary)
- Scanning logic mirrors roadmap scanning structure

---

### Phase 5: CLAUDE.md Update Logic (New Step 5.6) [NOT STARTED]

**Goal**: Update CLAUDE.md "Recent System Changes" section

**Tasks**:
- [ ] Add new Step 5.6 after Step 5.5
- [ ] Read current CLAUDE.md content
- [ ] Find "Recent System Changes" section
- [ ] Insert new entries at top of section
- [ ] Prune old entries (keep max 10)
- [ ] Write updated CLAUDE.md
- [ ] Add dry-run support

**Timing**: 45 minutes

**Files to modify**:
- `.claude/commands/todo.md` - Add Step 5.6

**Verification**:
- New entries added at top of section
- Old entries pruned when exceeding 10
- Dry-run shows what would be added
- Format is `- [YYYY-MM-DD] Task #N: {summary}`

---

### Phase 6: Documentation Updates [NOT STARTED]

**Goal**: Update CLAUDE.md workflow documentation to reflect meta task handling

**Tasks**:
- [ ] Update "Completion Summary Workflow" section in CLAUDE.md
- [ ] Add note about meta tasks updating CLAUDE.md instead of ROAD_MAP.md
- [ ] Update /todo command description to mention meta task handling

**Timing**: 15 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - Update Completion Summary Workflow section

**Verification**:
- Documentation clearly explains meta task flow
- Workflow section mentions CLAUDE.md updates for meta tasks

## Testing & Validation

- [ ] Dry-run /todo with no meta tasks - behaves as before
- [ ] Dry-run /todo with meta task - shows CLAUDE.md update, not ROAD_MAP.md
- [ ] Execute /todo with meta task - CLAUDE.md updated correctly
- [ ] Verify rolling log pruning with >10 entries simulation
- [ ] Verify non-meta tasks still update ROAD_MAP.md correctly
- [ ] State schema documentation is accurate

## Artifacts & Outputs

- `.claude/commands/todo.md` - Modified with language filtering and CLAUDE.md handling
- `.claude/CLAUDE.md` - New "Recent System Changes" section
- `.claude/rules/state-management.md` - Updated with claudemd_items field
- `specs/642_meta_tasks_update_claudemd_not_roadmap/summaries/implementation-summary-YYYYMMDD.md` - Upon completion

## Rollback/Contingency

If implementation causes issues:
1. Revert /todo command changes (Step 3.5, 3.6, 5.6 modifications)
2. Remove "Recent System Changes" section from CLAUDE.md
3. Remove claudemd_items from state-management.md

Git history preserves pre-implementation state for easy rollback.
