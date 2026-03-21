# Research Report: Task #401

**Task**: Add [EXPANDED] status for parent tasks
**Date**: 2026-01-11
**Focus**: Find all context files and documentation that needs to be updated to include the [EXPANDED] status marker

## Summary

The `[EXPANDED]` status is a new terminal-like status for parent tasks that have been divided/expanded into subtasks. This status indicates the parent task is complete from a workflow perspective - its work is now represented by its subtasks. Six key files define status markers and need updating, plus the task.md Divide Mode needs to set this status automatically.

## Findings

### Finding 1: Primary Status Definition Files

These files define the authoritative status markers and MUST be updated:

**1. `.claude/context/core/standards/status-markers.md`** (PRIMARY AUTHORITY)
- Lines 22-189: Defines all status markers with formats, meanings, and transitions
- Needs: New `[EXPANDED]` section with definition, transitions, timestamps
- Table at lines 173-188 needs `[EXPANDED] | expanded | Task expanded into subtasks` row

**2. `.claude/rules/state-management.md`**
- Lines 24-33: Valid Transitions section
- Lines 92-105: Status Values Mapping table
- Needs: Add `[EXPANDED]` to transitions, add `| [EXPANDED] | expanded |` to mapping table

**3. `.claude/context/core/workflows/status-transitions.md`**
- Lines 7-20: Status Markers quick reference table
- Lines 22-36: Valid Transitions diagram
- Needs: Add `| Expanded | [EXPANDED] | Task expanded into subtasks |` row

### Finding 2: Secondary Reference Files

**4. `.claude/CLAUDE.md`**
- Lines 32-38: Status Markers quick reference list
- Needs: Add `[EXPANDED]` to the terminal/exception states line

**5. `.claude/skills/skill-status-sync/SKILL.md`**
- Lines 437-448: Status Mapping table
- Needs: Add `| Expand task | any (with subtasks) | expanded | status, subtasks |` row

### Finding 3: Command File Updates

**6. `.claude/commands/task.md`**
- Lines 166-198: Divide Mode section
- Currently only updates `subtasks` array in step 4
- Needs: Also set `status: "expanded"` in the jq command at step 4

### Finding 4: Status Semantics for [EXPANDED]

Based on analysis of existing patterns:

**TODO.md Format**: `- **Status**: [EXPANDED]`
**state.json Value**: `"status": "expanded"`
**Meaning**: Parent task has been expanded into subtasks; work continues in subtasks.

**Valid Transitions**:
- `[NOT STARTED]` -> `[EXPANDED]` (when /task --divide creates subtasks)
- `[RESEARCHED]` -> `[EXPANDED]` (when /task --divide creates subtasks after research)
- Any pre-completion status -> `[EXPANDED]` (when divided into subtasks)

**Note**: `[EXPANDED]` is a terminal-like state - the parent task delegates to subtasks. It differs from `[COMPLETED]` because the parent's work is delegated, not finished.

### Finding 5: Files NOT Requiring Changes

These files use status markers but don't define them (no changes needed):
- `.claude/commands/research.md` - uses status, doesn't define
- `.claude/commands/plan.md` - uses status, doesn't define
- `.claude/commands/implement.md` - uses status, doesn't define
- `specs/TODO.md` - consumes status markers
- Archive files - historical, no updates needed

### Finding 6: Task 394 Update Required

Task 394 currently has:
- Status: `[RESEARCHED]` in TODO.md
- Status: `"researched"` in state.json
- Subtasks: `[398, 399]`

After implementing [EXPANDED] status, task 394 should be updated to:
- Status: `[EXPANDED]` in TODO.md
- Status: `"expanded"` in state.json

## Recommendations

1. **Update status-markers.md first** - This is the primary authority; other files reference it

2. **Define [EXPANDED] semantics clearly**:
   - Parent task status when subtasks are created
   - Terminal-like but different from COMPLETED
   - Indicates work delegated to subtasks

3. **Modify task.md Divide Mode** to set status atomically when creating subtasks

4. **Update task 394** as the first application of the new status

5. **Consider transition validation** - Should expanding be allowed from any pre-completion status?

## Files to Modify (in order)

| File | Section | Change |
|------|---------|--------|
| `.claude/context/core/standards/status-markers.md` | Status Marker Definitions | Add [EXPANDED] definition |
| `.claude/context/core/standards/status-markers.md` | TODO.md vs state.json Mapping | Add row |
| `.claude/context/core/standards/status-markers.md` | Valid Transition Diagram | Add [EXPANDED] node |
| `.claude/rules/state-management.md` | Valid Transitions | Add [EXPANDED] |
| `.claude/rules/state-management.md` | Status Values Mapping | Add row |
| `.claude/context/core/workflows/status-transitions.md` | Status Markers table | Add row |
| `.claude/CLAUDE.md` | Status Markers | Add to terminal states |
| `.claude/skills/skill-status-sync/SKILL.md` | Status Mapping | Add expand operation |
| `.claude/commands/task.md` | Divide Mode | Set status to expanded |
| `specs/state.json` | Task 394 | Update status to expanded |
| `specs/TODO.md` | Task 394 | Update status to [EXPANDED] |

## References

- `.claude/context/core/standards/status-markers.md` - Primary status documentation
- `.claude/rules/state-management.md` - State management rules
- `.claude/context/core/workflows/status-transitions.md` - Transition workflows
- `.claude/commands/task.md` - Task command with Divide Mode
- `.claude/skills/skill-status-sync/SKILL.md` - Status sync patterns

## Next Steps

1. Create implementation plan with phased approach
2. Update status definition files first
3. Update task.md Divide Mode
4. Update task 394 as validation
5. Test with `/task --divide` (soon to be `--expand`) on another task
