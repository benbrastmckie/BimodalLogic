# Research Report: Task #763

**Task**: 763 - add_plan_status_updates_skill_lean_implementation
**Started**: 2026-01-29T12:00:00Z
**Completed**: 2026-01-29T12:15:00Z
**Effort**: 30 minutes
**Priority**: medium
**Dependencies**: None
**Sources/Inputs**: Codebase analysis of skill-implementer, skill-latex-implementation, skill-typst-implementation, skill-lean-implementation
**Artifacts**: This research report
**Standards**: report-format.md, return-metadata-file.md

## Executive Summary

- The plan status update pattern (sed commands to update `- **Status**: [...]` lines) is consistently implemented across skill-implementer, skill-latex-implementation, and skill-typst-implementation
- skill-lean-implementation is missing these updates entirely - it lacks plan file status updates in Stage 2 (preflight) and Stage 7 (postflight)
- The required changes are straightforward: add the same sed command pattern at three specific locations

## Context and Scope

The task is to ensure skill-lean-implementation updates the implementation plan's Status field alongside updates to TODO.md and state.json. This provides consistency across all implementer skills and ensures the plan artifact accurately reflects the current state of implementation.

## Findings

### Existing Pattern in Sister Skills

All three sister skills follow the identical pattern:

**Preflight (Stage 2 / Preflight Status Update)**:
```bash
# Find latest plan file
plan_file=$(ls -1 "specs/${task_number}_${project_name}/plans/implementation-"*.md 2>/dev/null | sort -V | tail -1)
if [ -n "$plan_file" ] && [ -f "$plan_file" ]; then
    sed -i "s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [IMPLEMENTING]/" "$plan_file"
fi
```

**Postflight (implemented/completed)**:
```bash
plan_file=$(ls -1 "specs/${task_number}_${project_name}/plans/implementation-"*.md 2>/dev/null | sort -V | tail -1)
if [ -n "$plan_file" ] && [ -f "$plan_file" ]; then
    sed -i "s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [COMPLETED]/" "$plan_file"
fi
```

**Postflight (partial)**:
```bash
plan_file=$(ls -1 "specs/${task_number}_${project_name}/plans/implementation-"*.md 2>/dev/null | sort -V | tail -1)
if [ -n "$plan_file" ] && [ -f "$plan_file" ]; then
    sed -i "s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [PARTIAL]/" "$plan_file"
fi
```

### Location Analysis in Sister Skills

| Skill | Preflight Lines | Completed Lines | Partial Lines |
|-------|-----------------|-----------------|---------------|
| skill-implementer | 91-98 | 265-271 | 287-293 |
| skill-latex-implementation | 70-76 | 282-288 | 304-310 |
| skill-typst-implementation | 70-76 | 282-288 | 304-310 |

### Current State of skill-lean-implementation

**Stage 2: Preflight Status Update** (Lines 77-96):
- Updates state.json with status "implementing"
- Updates TODO.md via Edit tool
- **MISSING**: Plan file status update

**Stage 7: Update Task Status (Postflight)** (Lines 210-246):
- Updates state.json to "completed" on success
- Updates TODO.md status marker
- **MISSING**: Plan file status update to [COMPLETED]
- Handles partial case (keeps status "implementing")
- **MISSING**: Plan file status update to [PARTIAL]

### Recommended Insertion Points

**Location 1: After Line 94** (Stage 2: Preflight Status Update)

Current text:
```markdown
**Update TODO.md**: Use Edit tool to change status marker from `[PLANNED]` to `[IMPLEMENTING]`.

---
```

Insert before the `---`:
```markdown
**Update plan file** (if exists): Update the Status field in plan metadata:
```bash
# Find latest plan file
plan_file=$(ls -1 "specs/${task_number}_${project_name}/plans/implementation-"*.md 2>/dev/null | sort -V | tail -1)
if [ -n "$plan_file" ] && [ -f "$plan_file" ]; then
    sed -i "s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [IMPLEMENTING]/" "$plan_file"
fi
```
```

**Location 2: After Line 240** (Stage 7: "If status is implemented")

Current text:
```markdown
Update TODO.md: Change status marker from `[IMPLEMENTING]` to `[COMPLETED]`.

**If status is "partial"**:
```

Insert before "If status is partial":
```markdown
**Update plan file** (if exists): Update the Status field to `[COMPLETED]`:
```bash
plan_file=$(ls -1 "specs/${task_number}_${project_name}/plans/implementation-"*.md 2>/dev/null | sort -V | tail -1)
if [ -n "$plan_file" ] && [ -f "$plan_file" ]; then
    sed -i "s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [COMPLETED]/" "$plan_file"
fi
```
```

**Location 3: After Line 245** (Stage 7: "If status is partial")

Current text:
```markdown
Keep status as "implementing" but update resume point.
TODO.md stays as `[IMPLEMENTING]`.

---
```

Insert before the `---`:
```markdown
**Update plan file** (if exists): Update the Status field to `[PARTIAL]`:
```bash
plan_file=$(ls -1 "specs/${task_number}_${project_name}/plans/implementation-"*.md 2>/dev/null | sort -V | tail -1)
if [ -n "$plan_file" ] && [ -f "$plan_file" ]; then
    sed -i "s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [PARTIAL]/" "$plan_file"
fi
```
```

### Phase Status Updates (Additional Consideration)

The focus prompt mentioned "update the phase status in the plan as progress is made." This is a separate concern from the overall plan Status field:

1. **Overall plan Status field**: Located in plan metadata header (e.g., `- **Status**: [IMPLEMENTING]`). This is what the sed pattern updates.

2. **Individual phase status**: Located within each phase section (e.g., `**Status**: [NOT STARTED]`). According to artifact-formats.md (lines 176-183), valid phase markers are:
   - `[NOT STARTED]` - Phase not begun
   - `[IN PROGRESS]` - Currently executing
   - `[COMPLETED]` - Phase finished
   - `[PARTIAL]` - Partially complete (interrupted)
   - `[BLOCKED]` - Cannot proceed

**Current situation**: Phase status updates are the responsibility of the lean-implementation-agent (subagent), not the skill wrapper. The subagent should update individual phase statuses as it progresses through the plan. This is a separate enhancement that would require changes to the agent definition, not the skill.

**Recommendation**: Keep this task focused on the overall plan Status field (what the task description specifies). Phase-level status updates should be tracked separately if needed.

## Decisions

1. **Use identical sed pattern**: The exact same sed command pattern from sister skills will be used for consistency
2. **Three insertion points**: Preflight, postflight-completed, postflight-partial
3. **No failed case update**: Consistent with sister skills - on failure, plan status stays as [IMPLEMENTING] for retry
4. **Phase status is out of scope**: This task addresses overall plan Status only, not individual phase markers

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Plan file doesn't exist | Low | Guard clause `[ -n "$plan_file" ]` handles missing file gracefully |
| sed pattern doesn't match | Low | The regex is robust and matches any `[...]` content in Status line |
| Inconsistency with agent updates | Medium | Ensure agent doesn't also try to update overall Status (currently it doesn't) |

## Appendix

### Files Examined
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-implementer/SKILL.md` (lines 85-110, 259-298)
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-latex-implementation/SKILL.md` (lines 64-88, 276-315)
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-typst-implementation/SKILL.md` (lines 64-88, 276-315)
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-lean-implementation/SKILL.md` (full file, 359 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/rules/state-management.md`
- `/home/benjamin/Projects/ProofChecker/.claude/rules/artifact-formats.md`

### Sed Pattern Explanation
```
s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [IMPLEMENTING]/
```
- `^` - Start of line
- `\- ` - Literal "- " (markdown list item)
- `\*\*Status\*\*` - Literal "**Status**" (bold markdown)
- `: ` - Literal ": "
- `\[.*\]` - Any content within brackets
- `$` - End of line
- Replacement preserves markdown formatting while changing the status value
