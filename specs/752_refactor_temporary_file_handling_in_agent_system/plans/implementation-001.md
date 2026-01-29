# Implementation Plan: Task #752

- **Task**: 752 - refactor_temporary_file_handling_in_agent_system
- **Status**: [IMPLEMENTING]
- **Effort**: 5 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/752_refactor_temporary_file_handling_in_agent_system/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Refactor global coordination files (`specs/.postflight-pending`, `specs/.postflight-loop-guard`) to task-scoped locations (`specs/{N}_{SLUG}/.postflight-pending`) to enable safe concurrent agent execution. The research report identified that the current design assumes single-agent operation, creating race conditions when multiple agents work on different tasks simultaneously.

### Research Integration

The research report (research-001.md) found:
- Global coordination files in `specs/` create **HIGH** concurrency risk when multiple agents run simultaneously
- Task-scoped metadata files (`specs/{N}_{SLUG}/.return-meta.json`) are already correctly designed and safe
- Moving coordination files to task directories enables concurrent work on different tasks while maintaining single-agent-per-task guarantees

## Goals & Non-Goals

**Goals**:
- Move postflight marker files to task-scoped directories
- Update hook script to detect task-scoped markers
- Update all skills to write markers to task directories
- Update documentation to reflect new patterns
- Enable concurrent agent execution on different tasks

**Non-Goals**:
- Changing `/tmp/` usage patterns (already process-safe)
- Modifying `.return-meta.json` handling (already task-scoped)
- Implementing multi-agent-per-task support (out of scope)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Hook fails to find task-scoped marker | Premature termination, lost postflight | Medium | Use robust `find` with error handling |
| Multiple markers found | Ambiguous which task is active | Low | Process first found, log warning |
| Task directory doesn't exist when marker created | Marker creation fails | Low | Use `mkdir -p` before writing marker |
| Migration breaks in-flight operations | Lost postflight on upgrade | Medium | Clean all old markers before deployment |

## Implementation Phases

### Phase 1: Update Hook Script [COMPLETED]

**Goal**: Modify `subagent-postflight.sh` to detect task-scoped markers using find

**Tasks**:
- [ ] Read current hook implementation
- [ ] Replace hardcoded `MARKER_FILE="specs/.postflight-pending"` with `find` command
- [ ] Extract task directory from found marker path for loop guard
- [ ] Update loop guard path to be task-scoped
- [ ] Add fallback to global marker for backward compatibility during migration
- [ ] Test hook with simulated task-scoped marker

**Timing**: 1 hour

**Files to modify**:
- `.claude/hooks/subagent-postflight.sh` - Replace global paths with task-scoped detection

**Implementation Details**:

Replace the hardcoded paths:
```bash
# Before
MARKER_FILE="specs/.postflight-pending"
LOOP_GUARD_FILE="specs/.postflight-loop-guard"

# After
# Find task-scoped marker (or fallback to global for backward compatibility)
MARKER_FILE=$(find specs -maxdepth 3 -name ".postflight-pending" -type f 2>/dev/null | head -1)
if [ -z "$MARKER_FILE" ]; then
    # Fallback to global (backward compatibility during migration)
    if [ -f "specs/.postflight-pending" ]; then
        MARKER_FILE="specs/.postflight-pending"
    fi
fi
# Derive loop guard from marker location
if [ -n "$MARKER_FILE" ]; then
    TASK_DIR=$(dirname "$MARKER_FILE")
    LOOP_GUARD_FILE="$TASK_DIR/.postflight-loop-guard"
fi
```

**Verification**:
- Create test marker at `specs/999_test/.postflight-pending`
- Verify hook finds and processes it correctly
- Verify loop guard is created in task directory
- Remove test files

---

### Phase 2: Update All Skills [NOT STARTED]

**Goal**: Modify all 7 skill files to write markers to task-scoped directories

**Tasks**:
- [ ] Update skill-researcher/SKILL.md - Stage 3 marker creation and Stage 10 cleanup
- [ ] Update skill-lean-research/SKILL.md - Same pattern
- [ ] Update skill-implementer/SKILL.md - Same pattern
- [ ] Update skill-lean-implementation/SKILL.md - Same pattern
- [ ] Update skill-planner/SKILL.md - Same pattern
- [ ] Update skill-latex-implementation/SKILL.md - Same pattern
- [ ] Update skill-typst-implementation/SKILL.md - Same pattern

**Timing**: 2 hours

**Files to modify**:
- `.claude/skills/skill-researcher/SKILL.md`
- `.claude/skills/skill-lean-research/SKILL.md`
- `.claude/skills/skill-implementer/SKILL.md`
- `.claude/skills/skill-lean-implementation/SKILL.md`
- `.claude/skills/skill-planner/SKILL.md`
- `.claude/skills/skill-latex-implementation/SKILL.md`
- `.claude/skills/skill-typst-implementation/SKILL.md`

**Implementation Details**:

For each skill, update two sections:

**Stage 3: Create Postflight Marker** (before):
```bash
cat > specs/.postflight-pending << EOF
```

**Stage 3: Create Postflight Marker** (after):
```bash
# Ensure task directory exists
mkdir -p "specs/${task_number}_${project_name}"

cat > "specs/${task_number}_${project_name}/.postflight-pending" << EOF
```

**Stage 10: Cleanup** (before):
```bash
rm -f specs/.postflight-pending
rm -f specs/.postflight-loop-guard
```

**Stage 10: Cleanup** (after):
```bash
rm -f "specs/${task_number}_${project_name}/.postflight-pending"
rm -f "specs/${task_number}_${project_name}/.postflight-loop-guard"
```

**Verification**:
- Run `/research` on test task and verify marker created in task directory
- Verify postflight cleanup removes task-scoped markers
- Verify no global markers remain after operation

---

### Phase 3: Update Documentation [NOT STARTED]

**Goal**: Update documentation files to reflect new task-scoped patterns

**Tasks**:
- [ ] Update postflight-control.md - Change location section and all examples
- [ ] Update file-metadata-exchange.md - Update any marker file references
- [ ] Update workflow-interruptions.md - Update recovery commands
- [ ] Optionally document concurrency guarantees in CLAUDE.md

**Timing**: 1 hour

**Files to modify**:
- `.claude/context/core/patterns/postflight-control.md` - Primary documentation update
- `.claude/context/core/patterns/file-metadata-exchange.md` - Update if marker paths referenced
- `.claude/context/core/troubleshooting/workflow-interruptions.md` - Update recovery commands

**Implementation Details**:

**postflight-control.md** - Key changes:

1. Update Location section:
```markdown
### Location

```
specs/{N}_{SLUG}/.postflight-pending
```

Where `{N}` is the task number and `{SLUG}` is the project name.
```

2. Update all code examples to use task-scoped paths

3. Update Emergency Cleanup section:
```bash
# Manual Cleanup (Emergency) - for specific task
rm -f "specs/${task_number}_${project_name}/.postflight-pending"
rm -f "specs/${task_number}_${project_name}/.postflight-loop-guard"

# Clean all orphaned markers
find specs -maxdepth 3 -name ".postflight-pending" -delete
find specs -maxdepth 3 -name ".postflight-loop-guard" -delete
```

**workflow-interruptions.md** - Update recovery commands to use `find`:
```bash
# Find and remove orphaned postflight markers
find specs -maxdepth 3 -name ".postflight-pending" -mmin +60 -delete
find specs -maxdepth 3 -name ".postflight-loop-guard" -mmin +60 -delete
```

**Verification**:
- Review updated documentation for consistency
- Verify all examples use task-scoped paths
- Verify emergency cleanup commands work correctly

---

### Phase 4: Enhance Cleanup Tools [NOT STARTED]

**Goal**: Update `/refresh` command to clean task-scoped markers

**Tasks**:
- [ ] Read current skill-refresh/SKILL.md implementation
- [ ] Add cleanup for orphaned task-scoped postflight markers
- [ ] Use age-based cleanup (markers older than 1 hour)

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-refresh/SKILL.md` - Add marker cleanup section

**Implementation Details**:

Add new cleanup step to skill-refresh:
```bash
# Clean orphaned postflight markers (older than 1 hour)
echo "Cleaning orphaned postflight markers..."
find specs -maxdepth 3 -name ".postflight-pending" -mmin +60 -delete 2>/dev/null
find specs -maxdepth 3 -name ".postflight-loop-guard" -mmin +60 -delete 2>/dev/null

# Also clean global markers if they exist (legacy)
rm -f specs/.postflight-pending 2>/dev/null
rm -f specs/.postflight-loop-guard 2>/dev/null
```

**Verification**:
- Run `/refresh --dry-run` to see what would be cleaned
- Verify orphaned markers are identified

---

### Phase 5: Integration Testing [NOT STARTED]

**Goal**: Verify complete workflow functions with task-scoped markers

**Tasks**:
- [ ] Clean any existing global markers
- [ ] Run `/research` on a test task
- [ ] Verify marker created in task directory during execution
- [ ] Verify marker cleaned up after completion
- [ ] Verify no global markers created
- [ ] Run `/plan` on the same task
- [ ] Verify marker isolation between different tasks

**Timing**: 30 minutes

**Files to modify**:
- None (testing only)

**Test Plan**:

1. **Pre-test cleanup**:
   ```bash
   rm -f specs/.postflight-pending
   rm -f specs/.postflight-loop-guard
   find specs -maxdepth 3 -name ".postflight-pending" -delete
   ```

2. **Single task test**:
   - Create test task 999
   - Run `/research 999`
   - During execution, verify marker at `specs/999_test/.postflight-pending`
   - After completion, verify marker removed

3. **No global marker test**:
   - Run any skill command
   - Verify `specs/.postflight-pending` is NOT created

**Verification**:
- All tests pass
- No regressions in single-agent workflow

## Testing & Validation

- [ ] Hook script finds task-scoped markers
- [ ] All 7 skills create markers in task directories
- [ ] Cleanup removes task-scoped markers
- [ ] No global markers created
- [ ] `/refresh` cleans orphaned markers
- [ ] Documentation accurately reflects new pattern
- [ ] Single-agent workflows continue to function

## Artifacts & Outputs

- Updated `.claude/hooks/subagent-postflight.sh`
- Updated 7 skill SKILL.md files
- Updated 3 context/documentation files
- Updated skill-refresh/SKILL.md
- Implementation summary at `specs/752_refactor_temporary_file_handling_in_agent_system/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If implementation causes issues:

1. **Immediate rollback**: Revert to global marker paths in hook and skills
2. **Clean state**:
   ```bash
   # Remove all task-scoped markers
   find specs -maxdepth 3 -name ".postflight-pending" -delete
   find specs -maxdepth 3 -name ".postflight-loop-guard" -delete
   ```
3. **Git revert**: `git revert HEAD~N` where N is number of phase commits

The hook's fallback to global markers during Phase 1 provides backward compatibility during migration, reducing rollback risk.
