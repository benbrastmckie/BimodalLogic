# Implementation Summary: Task 270

**Task**: Fix /research command to conduct research instead of implementing tasks  
**Date**: 2026-01-03  
**Status**: COMPLETED

## Problem

The `/research` command was incorrectly executing full task implementation instead of conducting research. When `/research 267` was run, it:
- Changed status to [COMPLETED] instead of [RESEARCHED] (invalid transition per state-management.md)
- Implemented the task directly (moved files, updated references)
- Did NOT create research artifacts

## Root Cause

The researcher subagent (`.opencode/agent/subagents/researcher.md`) lacked explicit constraints preventing implementation. When given a task description like "Integrate X into Y", it interpreted this as an implementation request and executed it, rather than researching HOW to implement it.

## Changes Made

### 1. Added Critical Constraints Section

Added `<critical_constraints>` section to researcher.md with:
- Explicit FORBIDDEN activities (implementing tasks, modifying project files, using [COMPLETED] status)
- Explicit ALLOWED activities (research only, creating reports, using [RESEARCHED] status)
- Clear guidance: "If task requests implementation, research HOW to implement, do NOT implement"

### 2. Restricted Permissions

Updated permissions in researcher.md frontmatter:
- **Write permissions**: Restricted to `.opencode/specs/*/reports/**/*` and state files only
- **Denied bash commands**: Added `mv` and `cp` to prevent file operations
- **Denied write paths**: Added `.opencode/command/**/*`, `.opencode/agent/**/*`, `.opencode/context/**/*`, `docs/**/*`, `Logos/**/*`, `LogosTest/**/*`

### 3. Enhanced Constraints Section

Added explicit `<must_not>` constraints:
- `<must_not>Implement tasks (research HOW to implement, do NOT implement)</must_not>`
- `<must_not>Modify project files outside .opencode/specs/{task_number}_*/</must_not>`
- `<must_not>Change status to [COMPLETED] (only [RESEARCHED] allowed)</must_not>`
- `<must_not>Move files, update code, or make implementation changes</must_not>`

### 4. Reinforced Status Transitions

Added explicit constraint:
- `<must>Use status transition: [NOT STARTED] → [RESEARCHING] → [RESEARCHED]</must>`

## Files Modified

- `.opencode/agent/subagents/researcher.md` (added constraints, restricted permissions)
- `.opencode/specs/TODO.md` (marked task 270 as COMPLETED)
- `.opencode/specs/state.json` (added completion activity)

## Impact

The researcher agent is now explicitly constrained to:
1. Conduct research ONLY (no implementation)
2. Create research artifacts in `.opencode/specs/{task_number}_*/reports/` only
3. Use correct status transitions: [NOT STARTED] → [RESEARCHING] → [RESEARCHED]
4. Never modify project files outside the specs directory

This fixes the critical workflow bug where `/research` was implementing tasks instead of researching them, ensuring proper separation between research, planning, and implementation phases.

## Validation

The fix ensures:
- ✅ Research artifacts follow artifact-management.md standards
- ✅ Status transitions follow state-management.md rules
- ✅ No implementation occurs during /research
- ✅ Permissions prevent file operations outside research scope
- ✅ Explicit constraints guide agent behavior

## Next Steps

Future `/research` invocations will:
1. Read task description
2. Research HOW to accomplish the task (not implement it)
3. Create research report with findings and recommendations
4. Update status to [RESEARCHED] (not [COMPLETED])
5. Return research artifact for user review
