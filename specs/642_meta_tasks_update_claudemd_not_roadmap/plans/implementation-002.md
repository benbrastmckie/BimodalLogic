# Implementation Plan: Task #642

- **Task**: 642 - meta_tasks_update_claudemd_not_roadmap
- **Status**: [NOT STARTED]
- **Version**: 002 (revised)
- **Effort**: 2 hours
- **Priority**: Medium
- **Dependencies**: Task 641 (completed)
- **Research Inputs**: specs/642_meta_tasks_update_claudemd_not_roadmap/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false
- **Revision Reason**: Replace rolling log approach with intelligent CLAUDE.md content updates

## Overview

This revised plan implements language-based filtering in the /todo command so that meta tasks (language: "meta") suggest appropriate CLAUDE.md updates instead of ROAD_MAP.md. The key change from v001 is replacing the "rolling log" approach with **intelligent content suggestions** - the system should:

1. Only suggest changes when they are actually needed
2. Avoid bloating CLAUDE.md with unnecessary content
3. Remove outdated content when appropriate
4. Never remove critical content that would degrade system performance

The approach uses a `claudemd_suggestions` field (replacing `claudemd_items`) that contains structured suggestions for CLAUDE.md modifications, which are reviewed by the user during /todo execution.

### Design Philosophy

Meta tasks improve the development system itself. When such a task completes:
- **Add content**: Only if it introduces new behavior/workflow/pattern that users need to know
- **Update content**: If existing documentation is now incorrect or incomplete
- **Remove content**: If the task deprecates or replaces existing functionality
- **No change**: If the task is purely internal with no user-visible impact

### Research Integration (Preserved from v001)

Key findings from research-001.md:
- /todo command Step 3.5 and Step 5.5 handle ROAD_MAP.md updates without language filtering
- No existing language-based filtering for post-completion handling
- The `claudemd_suggestions` field should parallel `roadmap_items` structure

## Goals & Non-Goals

**Goals**:
- Exclude meta tasks from ROAD_MAP.md updates in /todo
- Add CLAUDE.md suggestion handling for meta tasks
- Implement structured suggestion format (add/update/remove/none)
- Support user review before applying changes
- Document the new field in state-management.md

**Non-Goals**:
- Automatic CLAUDE.md modifications without user review
- Rolling log or changelog section (explicitly rejected)
- Retroactive updates for already-completed meta tasks
- Complex semantic analysis of what to update

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| CLAUDE.md bloat from excessive additions | High | Medium | Require explicit suggestion; dry-run shows preview |
| Critical content removed | High | Low | User must approve all removals; suggestions are advisory |
| Missing needed updates | Medium | Medium | Implementation agent prompted to assess CLAUDE.md impact |
| Suggestion format confusion | Low | Low | Clear schema documentation and examples |

## Claudemd_suggestions Schema

Each completed meta task may include a `claudemd_suggestions` field:

```json
{
  "claudemd_suggestions": {
    "action": "add|update|remove|none",
    "section": "Section Name (e.g., 'Command Workflows', 'Skill Architecture')",
    "rationale": "Why this change is needed (or why no change is needed)",
    "content": "The text to add or the updated text (null for remove/none)",
    "removes": "Text pattern being removed/replaced (null for add/none)"
  }
}
```

**Action types**:
- `add`: New content needed (new command, new pattern, new feature)
- `update`: Existing content needs modification (changed behavior, clarification)
- `remove`: Content is now obsolete (deprecated feature, replaced workflow)
- `none`: No CLAUDE.md changes needed (internal refactor, bug fix, invisible change)

## Implementation Phases

### Phase 1: Schema Documentation [NOT STARTED]

**Goal**: Document the `claudemd_suggestions` field in state-management.md

**Tasks**:
- [ ] Add `claudemd_suggestions` to Completion Fields Schema table
- [ ] Document the action types and their meanings
- [ ] Add examples for each action type
- [ ] Explain when to use `none` action

**Timing**: 20 minutes

**Files to modify**:
- `.claude/rules/state-management.md` - Add claudemd_suggestions field documentation

**Verification**:
- Schema includes claudemd_suggestions object with all fields
- Examples cover add/update/remove/none cases

---

### Phase 2: Language Filtering in /todo Step 3.5 [NOT STARTED]

**Goal**: Filter meta tasks out of ROAD_MAP.md scanning

**Tasks**:
- [ ] Add language check in Step 3.5 task loop
- [ ] Create separate array for meta tasks
- [ ] Skip meta tasks in roadmap matching logic
- [ ] Add comments explaining the filtering

**Timing**: 25 minutes

**Files to modify**:
- `.claude/commands/todo.md` - Modify Step 3.5

**Verification**:
- Meta tasks are not matched against ROAD_MAP.md
- Non-meta tasks continue to work as before
- Dry-run output separates meta tasks

---

### Phase 3: CLAUDE.md Suggestion Scanning (New Step 3.6) [NOT STARTED]

**Goal**: Scan meta tasks for CLAUDE.md update suggestions

**Tasks**:
- [ ] Add new Step 3.6 after Step 3.5
- [ ] Extract meta tasks collected in Phase 2
- [ ] Check for `claudemd_suggestions` field in each
- [ ] Build list of suggested CLAUDE.md modifications
- [ ] Skip tasks with action: "none"

**Timing**: 25 minutes

**Files to modify**:
- `.claude/commands/todo.md` - Add Step 3.6

**Verification**:
- Meta tasks with claudemd_suggestions are tracked
- Tasks with action: "none" are acknowledged but not queued for changes
- Suggestion list includes action, section, and rationale

---

### Phase 4: CLAUDE.md Suggestion Preview (New Step 5.6) [NOT STARTED]

**Goal**: Display CLAUDE.md modification suggestions for user review

**Tasks**:
- [ ] Add new Step 5.6 after Step 5.5
- [ ] For each suggestion, display:
  - Task number and name
  - Action type (add/update/remove)
  - Target section
  - Rationale
  - Proposed content (for add/update)
  - Content to remove (for update/remove)
- [ ] Format as actionable suggestions, not automatic changes
- [ ] Add dry-run support

**Timing**: 30 minutes

**Files to modify**:
- `.claude/commands/todo.md` - Add Step 5.6

**Verification**:
- Suggestions displayed clearly with context
- User understands what would change and why
- Dry-run shows suggestions without any state changes

---

### Phase 5: Documentation Updates [NOT STARTED]

**Goal**: Update CLAUDE.md workflow documentation to reflect meta task handling

**Tasks**:
- [ ] Update "Completion Summary Workflow" section in CLAUDE.md
- [ ] Add note about meta tasks updating CLAUDE.md instead of ROAD_MAP.md
- [ ] Document that suggestions require user review
- [ ] Update /todo command description to mention meta task handling

**Timing**: 20 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - Update Completion Summary Workflow section

**Verification**:
- Documentation clearly explains meta task flow
- Workflow section mentions CLAUDE.md suggestions for meta tasks
- Clear that changes are suggested, not automatic

## Testing & Validation

- [ ] Dry-run /todo with no meta tasks - behaves as before
- [ ] Dry-run /todo with meta task (action: none) - shows acknowledgment, no suggestions
- [ ] Dry-run /todo with meta task (action: add) - shows add suggestion with content
- [ ] Dry-run /todo with meta task (action: update) - shows before/after
- [ ] Dry-run /todo with meta task (action: remove) - shows what would be removed
- [ ] Verify non-meta tasks still update ROAD_MAP.md correctly
- [ ] State schema documentation is accurate

## Artifacts & Outputs

- `.claude/commands/todo.md` - Modified with language filtering and CLAUDE.md suggestion handling
- `.claude/CLAUDE.md` - Updated Completion Summary Workflow section
- `.claude/rules/state-management.md` - Updated with claudemd_suggestions field
- `specs/642_meta_tasks_update_claudemd_not_roadmap/summaries/implementation-summary-YYYYMMDD.md` - Upon completion

## Example Suggestions

### Example 1: Add (New Command)
```
Task #645: Add /debug command for MCP troubleshooting

Suggested CLAUDE.md change:
  Action: ADD
  Section: Command Workflows
  Rationale: New user-facing command that needs documentation
  Content:
    ### /debug - MCP troubleshooting
    Diagnoses MCP server connectivity and tool availability.
```

### Example 2: Update (Changed Behavior)
```
Task #648: Change /refresh default threshold to 24 hours

Suggested CLAUDE.md change:
  Action: UPDATE
  Section: Session Maintenance > Quick Commands
  Rationale: Default behavior changed
  Removes: "Execute both cleanups immediately (8-hour default)"
  Content: "Execute both cleanups immediately (24-hour default)"
```

### Example 3: Remove (Deprecated Feature)
```
Task #650: Remove legacy /sync command

Suggested CLAUDE.md change:
  Action: REMOVE
  Section: Command Workflows
  Rationale: Command removed, documentation is now misleading
  Removes: "### /sync - Legacy state synchronization..."
```

### Example 4: None (Internal Change)
```
Task #642: Meta tasks should suggest CLAUDE.md updates

Suggested CLAUDE.md change:
  Action: NONE
  Rationale: Internal /todo behavior change; user workflow unchanged
```

## Rollback/Contingency

If implementation causes issues:
1. Revert /todo command changes (Step 3.5, 3.6, 5.6 modifications)
2. Revert state-management.md schema additions
3. Revert CLAUDE.md workflow documentation updates

Git history preserves pre-implementation state for easy rollback.

## Changes from v001

| Aspect | v001 (Rolling Log) | v002 (Intelligent Suggestions) |
|--------|-------------------|-------------------------------|
| Storage | Rolling log section in CLAUDE.md | claudemd_suggestions field in state.json |
| Automation | Auto-append with pruning | Suggestions require user review |
| Bloat control | Max 10 entries, FIFO | Explicit action types, "none" option |
| Content quality | Appends regardless of value | Only suggests when needed |
| Removal support | No | Yes (action: remove) |
| Update support | No | Yes (action: update) |
