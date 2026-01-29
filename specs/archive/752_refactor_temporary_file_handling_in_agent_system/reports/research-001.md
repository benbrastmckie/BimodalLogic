# Research Report: Task #752

**Task**: 752 - refactor_temporary_file_handling_in_agent_system
**Started**: 2026-01-29T12:00:00Z
**Completed**: 2026-01-29T12:30:00Z
**Effort**: 2-4 hours
**Priority**: high
**Dependencies**: None
**Sources/Inputs**: Codebase audit of `.claude/` directory, skills, agents, and context files
**Artifacts**: specs/752_refactor_temporary_file_handling_in_agent_system/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The agent system uses two types of temporary files: **global coordination files** in `specs/` (`.postflight-pending`, `.postflight-loop-guard`) and **task-scoped metadata files** in `specs/{N}_{SLUG}/` (`.return-meta.json`)
- Global coordination files (`specs/.postflight-pending`) create **concurrency risks** when multiple agents run simultaneously on different tasks
- The current design assumes single-agent operation; moving coordination files to task-scoped directories would enable safe concurrent agent execution
- A secondary pattern uses `/tmp/` for jq intermediate files, which is process-safe but leaves orphan files on error

## Context & Scope

This research audited all temporary file usage, metadata exchange patterns, and file-based coordination mechanisms in the agent orchestration system to identify concurrency risks and propose improvements.

### Files Audited

- `.claude/hooks/subagent-postflight.sh` - SubagentStop hook
- `.claude/skills/skill-*/SKILL.md` - All skill definitions (7 skills)
- `.claude/context/core/patterns/postflight-control.md` - Marker file protocol
- `.claude/context/core/patterns/file-metadata-exchange.md` - Metadata exchange patterns
- `.claude/context/core/formats/return-metadata-file.md` - Metadata schema
- `.claude/context/core/troubleshooting/workflow-interruptions.md` - Recovery patterns
- `.claude/context/core/orchestration/sessions.md` - Session management

## Findings

### 1. Global Coordination Files (High Risk)

**Location**: `specs/`

| File | Purpose | Concurrency Risk |
|------|---------|------------------|
| `.postflight-pending` | Marker file to block premature termination | **HIGH** - Single file shared by all skills |
| `.postflight-loop-guard` | Counter to prevent infinite loops | **HIGH** - Single file, incremented by hook |

**Current Usage Pattern** (from `subagent-postflight.sh`):
```bash
MARKER_FILE="specs/.postflight-pending"
LOOP_GUARD_FILE="specs/.postflight-loop-guard"
```

**Problem**: If Agent A is processing task 100 and Agent B starts task 200 simultaneously:
1. Agent B creates `specs/.postflight-pending` with task_number=200
2. Agent A's postflight reads the marker and sees task_number=200 (wrong task)
3. Agent A's cleanup removes Agent B's marker
4. Agent B's subagent terminates prematurely without postflight

**Evidence of Single-Agent Assumption**:
- All skills write to the same `specs/.postflight-pending` path
- The hook script (`subagent-postflight.sh`) reads a single marker file
- The loop guard counter is global, not task-scoped

### 2. Task-Scoped Metadata Files (Safe Design)

**Location**: `specs/{N}_{SLUG}/.return-meta.json`

This pattern is already task-scoped and safe for concurrency:
- Each agent writes to its own task directory
- No cross-task interference possible
- Cleanup is targeted: `rm -f "specs/${task_number}_${project_name}/.return-meta.json"`

**Example from skill-implementer/SKILL.md**:
```bash
metadata_file="specs/${task_number}_${project_name}/.return-meta.json"
```

### 3. System `/tmp/` Usage (Process-Safe, Cleanup Risk)

**Location**: `/tmp/state.json`, `/tmp/errors.json`, etc.

All skills use `/tmp/` for jq intermediate files:
```bash
jq '...' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

**Analysis**:
- **Process-safe**: File names are not task-specific, but atomic mv operation prevents conflicts
- **Cleanup risk**: On error, orphan `/tmp/state.json` files may persist
- **Not recommended to change**: System `/tmp/` is cleaned by OS, and PID-namespacing would add complexity

**Enhancement**: Some patterns use `$$` (PID) for uniqueness (e.g., `/tmp/todo_nonmeta_$$.jq`), which is already safe.

### 4. Session Directory Pattern (Deprecated but Instructive)

**Location**: `.tmp/sessions/{session-id}/`

The deprecated session management shows the correct pattern for concurrent safety:
- Each session has a unique ID
- Files are isolated in session directories
- No file conflicts between sessions

This pattern should be applied to coordination files.

### 5. Current Marker File Contents

**Observed in `specs/.postflight-pending`**:
```json
{
  "session_id": "sess_1769699615_c00b7d",
  "skill": "skill-researcher",
  "task_number": 752,
  "operation": "research",
  "reason": "Postflight pending: status update, artifact linking, git commit",
  "created": "2026-01-29T15:00:00Z",
  "stop_hook_active": false
}
```

The file already contains `task_number`, suggesting the marker was designed with task awareness but implemented in a global location.

## Recommendations

### Recommendation 1: Move Coordination Files to Task Directories

**Before**:
```
specs/.postflight-pending
specs/.postflight-loop-guard
```

**After**:
```
specs/{N}_{SLUG}/.postflight-pending
specs/{N}_{SLUG}/.postflight-loop-guard
```

**Implementation Changes Required**:

1. **SubagentStop Hook** (`subagent-postflight.sh`):
   - Accept task directory as parameter or scan for any `.postflight-pending` files
   - Pattern: `find specs -maxdepth 2 -name ".postflight-pending" -type f 2>/dev/null | head -1`

2. **All Skills** (7 files):
   - Update marker creation: `cat > "specs/${task_number}_${project_name}/.postflight-pending" << EOF`
   - Update cleanup: `rm -f "specs/${task_number}_${project_name}/.postflight-pending"`
   - Update loop guard: `rm -f "specs/${task_number}_${project_name}/.postflight-loop-guard"`

3. **Postflight Control Pattern** (context/core/patterns/postflight-control.md):
   - Update documentation to reflect task-scoped paths

4. **Workflow Interruptions** (context/core/troubleshooting/workflow-interruptions.md):
   - Update recovery commands to use task-scoped paths
   - Update emergency cleanup: `find specs -name ".postflight-pending" -delete`

### Recommendation 2: Hook Detection Strategy

The hook must detect which task is pending. Two options:

**Option A: Scan for markers** (recommended)
```bash
# Find any pending marker
MARKER_FILE=$(find specs -maxdepth 2 -name ".postflight-pending" -type f 2>/dev/null | head -1)
if [ -n "$MARKER_FILE" ]; then
    # Extract task directory for loop guard
    TASK_DIR=$(dirname "$MARKER_FILE")
    LOOP_GUARD_FILE="$TASK_DIR/.postflight-loop-guard"
    ...
fi
```

**Option B: Store current task in session state**
```bash
# Skills write to session-scoped location
SESSION_MARKER=".claude/sessions/${session_id}/.postflight-pending"
```

Option A is simpler and maintains the existing pattern.

### Recommendation 3: Enhanced Cleanup Commands

Update `/refresh` command to clean task-scoped markers:
```bash
# Clean orphaned postflight markers older than 1 hour
find specs -maxdepth 2 -name ".postflight-pending" -mmin +60 -delete
find specs -maxdepth 2 -name ".postflight-loop-guard" -mmin +60 -delete
```

### Recommendation 4: Document Concurrency Guarantees

Add to CLAUDE.md or a context file:
- At most one agent works on a task at a time (enforced by status markers)
- Coordination files are task-scoped to enable concurrent work on different tasks
- Global resources (state.json, TODO.md) use atomic operations

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Hook fails to find marker | Premature termination, lost postflight | Use robust find with error handling |
| Multiple markers found | Ambiguous which task is active | Take first found, log warning |
| Task directory doesn't exist yet | Marker creation fails | mkdir -p before writing marker |
| Migration breaks in-flight operations | Lost postflight on upgrade | Clean all markers before deploying |

## Files Requiring Modification

### High Priority (Functional)

1. `.claude/hooks/subagent-postflight.sh` - Hook script
2. `.claude/skills/skill-lean-research/SKILL.md`
3. `.claude/skills/skill-lean-implementation/SKILL.md`
4. `.claude/skills/skill-researcher/SKILL.md`
5. `.claude/skills/skill-implementer/SKILL.md`
6. `.claude/skills/skill-planner/SKILL.md`
7. `.claude/skills/skill-latex-implementation/SKILL.md`
8. `.claude/skills/skill-typst-implementation/SKILL.md`

### Medium Priority (Documentation)

9. `.claude/context/core/patterns/postflight-control.md`
10. `.claude/context/core/patterns/file-metadata-exchange.md`
11. `.claude/context/core/troubleshooting/workflow-interruptions.md`
12. `.claude/CLAUDE.md` (optional concurrency documentation)

### Low Priority (Enhancement)

13. `.claude/skills/skill-refresh/SKILL.md` - Add marker cleanup

## Implementation Estimate

| Phase | Effort | Description |
|-------|--------|-------------|
| Phase 1: Hook Update | 1 hour | Modify subagent-postflight.sh for task-scoped markers |
| Phase 2: Skill Updates | 2 hours | Update all 7 skill files with new paths |
| Phase 3: Documentation | 1 hour | Update context files and troubleshooting guide |
| Phase 4: Testing | 1 hour | Verify single-agent still works, test recovery |

**Total**: 5 hours

## Success Criteria

- [ ] All coordination files written to task-scoped directories
- [ ] SubagentStop hook detects markers in task directories
- [ ] Single-agent workflows continue to function
- [ ] Emergency recovery commands updated
- [ ] No orphan global markers remain after operations

## Appendix

### Search Queries Used

1. `specs/\.\w+` - Find hidden files in specs directory
2. `/tmp/|temp.*=|\.tmp` - Find /tmp usage patterns
3. `.postflight-pending|.return-meta.json|temp.*file` - Find temp file patterns
4. `specs/\.` - Find hidden files with specs/ prefix

### Current Temporary File Inventory

| File | Location | Scope | Concurrency Safe |
|------|----------|-------|-----------------|
| `.postflight-pending` | `specs/` | Global | No |
| `.postflight-loop-guard` | `specs/` | Global | No |
| `.return-meta.json` | `specs/{N}_{SLUG}/` | Task | Yes |
| `/tmp/state.json` | System | Process | Yes (atomic mv) |
| `/tmp/meta_*.json` | System | Process | Yes |

### References

- `.claude/context/core/patterns/postflight-control.md` - Current marker protocol
- `.claude/context/core/patterns/file-metadata-exchange.md` - Metadata exchange patterns
- `.claude/context/core/troubleshooting/workflow-interruptions.md` - Recovery procedures
- `.claude/hooks/subagent-postflight.sh` - Hook implementation
