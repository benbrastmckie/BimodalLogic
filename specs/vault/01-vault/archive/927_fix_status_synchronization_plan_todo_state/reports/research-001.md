# Research Report: Task #927

**Task**: 927 - Fix status synchronization to ensure plan file status, TODO.md status, and state.json status all update together
**Started**: 2026-02-25T12:00:00Z
**Completed**: 2026-02-25T12:45:00Z
**Effort**: 2 hours
**Dependencies**: None
**Sources/Inputs**:
- Codebase analysis of .claude/skills/, .claude/scripts/, .claude/rules/, .claude/commands/
- specs/state.json and specs/TODO.md examination
- Plan file analysis (specs/926_*/plans/)
**Artifacts**:
- specs/927_fix_status_synchronization_plan_todo_state/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Plan file status on line 4 (metadata block) is NOT consistently updated when task status changes
- The issue is in implementation skills (`skill-implementer`, `skill-lean-implementation`, etc.) which have the code but it is not always executed
- Postflight scripts (`postflight-implement.sh`, `postflight-plan.sh`) only update state.json, NOT plan files
- `skill-status-sync` only mentions two-file synchronization (TODO.md + state.json), not three-file
- Recommended solution: Create centralized `update_plan_file_status` function and ensure all postflight paths call it

## Context & Scope

### Problem Statement

The system tracks task status in three locations:
1. **state.json**: Machine-readable status (e.g., `"status": "completed"`)
2. **TODO.md**: User-facing status marker (e.g., `[COMPLETED]`)
3. **Plan file** (line 4): Artifact status (e.g., `- **Status**: [COMPLETED]`)

Currently, state.json and TODO.md are reliably synchronized, but the plan file status often remains stale (e.g., showing `[NOT STARTED]` when the task is actually `[COMPLETED]`).

### Evidence

**Task 926** demonstrates the issue:
- state.json: `"status": "completed"`, `"completed": "2026-02-25T21:37:29Z"`
- TODO.md: `- **Status**: [COMPLETED]`
- Plan file (implementation-001.md, line 4): `- **Status**: [NOT STARTED]`

## Findings

### 1. Where Status Updates ARE Documented

**Skill Files with Plan File Update Code:**

The following implementation skills contain `sed` commands to update plan file status:
- `skill-implementer/SKILL.md` (lines 91-98, 389-395, 411-417)
- `skill-lean-implementation/SKILL.md` (lines 96-103, 448-454, 461-467)
- `skill-typst-implementation/SKILL.md` (lines 70-77, 281-288, 303-310)
- `skill-latex-implementation/SKILL.md` (lines 70-77, 282-288, 304-310)

**Code Pattern (from skill-implementer):**
```bash
# Find latest plan file
plan_file=$(ls -1 "specs/${task_number}_${project_name}/plans/implementation-"*.md 2>/dev/null | sort -V | tail -1)
if [ -n "$plan_file" ] && [ -f "$plan_file" ]; then
    sed -i "s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [IMPLEMENTING]/" "$plan_file"
fi
```

### 2. Where Status Updates Are MISSING

**`skill-status-sync/SKILL.md`:**
- Documents only two files: TODO.md and state.json
- No mention of plan file status synchronization
- Line 81-84: "Atomic Synchronization" lists only 4 targets, but #4 "Plan file (phase status markers)" refers to PHASE markers, not the plan's overall Status field

**`inline-status-update.md`:**
- Only provides patterns for TODO.md and state.json
- No plan file patterns documented

**Postflight Scripts:**
- `postflight-implement.sh`: Only updates state.json
- `postflight-plan.sh`: Only updates state.json
- `postflight-research.sh`: Only updates state.json (research has no plan)

**`state-management.md`:**
- Documents "Multi-File Synchronization" for TODO.md, state.json, and "Plan files (phase markers)"
- But "phase markers" refers to `### Phase N: Name [STATUS]` headings, NOT the metadata `- **Status**: [...]` field

### 3. Root Cause Analysis

The plan file status update code EXISTS in skill files but appears to not always execute. Possible reasons:

**A. Path Construction Issues:**
The pattern `ls -1 "specs/${task_number}_${project_name}/plans/implementation-"*.md` requires both `task_number` and `project_name` variables to be correctly set. If `project_name` is empty or incorrect, the path won't match.

**B. Bash Not Being Used:**
Skills are markdown instruction files, not actual shell scripts. The code is meant to be EXECUTED by Claude, not run automatically. If Claude skips the "Update plan file" step, it won't happen.

**C. Missing from Postflight Flow:**
When skills delegate to agents and handle postflight internally, the plan file update step may be buried in a long skill document and overlooked.

**D. Inconsistent Agent Implementation:**
The implementation agents (`general-implementation-agent.md`) update PHASE status markers but may not update the plan's overall Status field.

### 4. Design Intent vs. Reality

**Intent (from skill-implementer):**

Stage 2 (Preflight): Updates plan file to `[IMPLEMENTING]`
Stage 7 (Postflight): Updates plan file to `[COMPLETED]` or `[PARTIAL]`

**Reality:**
- The instructions are present but may not be consistently followed
- No centralized function exists to guarantee the update
- No validation step checks that plan file status matches task status

### 5. Synchronization Architecture

**Current Architecture:**
```
Command (/implement)
    |
    v
Skill (skill-implementer)
    |
    +-- Stage 2: Preflight
    |       +-- Update state.json (jq)
    |       +-- Update TODO.md (Edit)
    |       +-- [OPTIONAL] Update plan file (sed)  <-- MAY BE SKIPPED
    |
    +-- Stage 5: Invoke Subagent
    |       +-- Agent works...
    |
    +-- Stage 7: Postflight
    |       +-- Update state.json (jq)
    |       +-- Update TODO.md (Edit)
    |       +-- [OPTIONAL] Update plan file (sed)  <-- MAY BE SKIPPED
    |
    +-- Stage 9: Git Commit
```

**Issue:** Plan file updates are "optional" instructions embedded in markdown, not enforced by any mechanism.

## Recommendations

### Solution 1: Centralize Plan File Updates (RECOMMENDED)

Create a reusable helper function and ensure all postflight paths call it:

**A. Create Helper Script:**
```bash
# .claude/scripts/update-plan-status.sh
# Usage: update-plan-status.sh TASK_NUMBER PROJECT_NAME NEW_STATUS
plan_file=$(ls -1 "specs/${1}_${2}/plans/implementation-"*.md 2>/dev/null | sort -V | tail -1)
if [ -n "$plan_file" ] && [ -f "$plan_file" ]; then
    sed -i "s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [${3}]/" "$plan_file"
    echo "$plan_file"
else
    echo ""
fi
```

**B. Update Postflight Scripts:**
Add plan file update to `postflight-implement.sh`:
```bash
# After updating state.json, update plan file
project_name=$(jq -r --argjson num "$task_number" \
  '.active_projects[] | select(.project_number == $num) | .project_name' \
  "$state_file")
updated_plan=$(.claude/scripts/update-plan-status.sh "$task_number" "$project_name" "COMPLETED")
if [ -n "$updated_plan" ]; then
    echo "  Plan status updated: $updated_plan"
fi
```

### Solution 2: Add Validation Gate

Add a validation step that fails if plan file status doesn't match state.json:

```bash
# In postflight validation
state_status=$(jq -r '.active_projects[] | select(.project_number == '$task_number') | .status' specs/state.json)
plan_status=$(grep -oP '^\- \*\*Status\*\*: \[\K[^\]]+' "$plan_file" || echo "NOT_FOUND")
if [ "$plan_status" != "COMPLETED" ] && [ "$state_status" == "completed" ]; then
    echo "WARNING: Plan file status mismatch"
    # Auto-fix
fi
```

### Solution 3: Update skill-status-sync

Modify `skill-status-sync/SKILL.md` to include plan file as a third synchronization target:

Add new section:
```markdown
4. **Update plan file status** (if plan exists):
   - Find plan: `ls -1 "specs/${task_number}_${project_name}/plans/implementation-"*.md`
   - Update Status field: `sed -i "s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [$status]/"`
```

### Solution 4: Add Pre-Commit Validation Hook

Create a git hook that validates three-way synchronization before allowing commits:

```bash
# .claude/hooks/validate-status-sync.sh (extend existing)
# Check plan file status matches state.json for modified tasks
```

## Decisions

- **Primary Fix**: Implement Solution 1 (centralized helper) + Solution 2 (validation)
- **Secondary Fix**: Update skill-status-sync documentation
- **Avoid**: Adding complex pre-commit hooks (may slow development)

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking existing workflow | High | Test each skill type after changes |
| sed pattern mismatch | Medium | Use exact pattern from plan-format.md |
| Path construction fails | Medium | Add fallback with glob if project_name unavailable |
| Concurrent updates race | Low | Plan file is human-readable, conflicts are resolvable |

## Appendix

### Files Examined

1. `.claude/skills/skill-status-sync/SKILL.md` - Two-file sync only
2. `.claude/skills/skill-implementer/SKILL.md` - Has plan update code (lines 91-98, 389-395)
3. `.claude/skills/skill-lean-implementation/SKILL.md` - Has plan update code
4. `.claude/scripts/postflight-implement.sh` - state.json only
5. `.claude/context/core/patterns/inline-status-update.md` - Two-file patterns only
6. `.claude/context/core/orchestration/state-management.md` - Documents three-file but ambiguous
7. `.claude/rules/state-management.md` - Two-file focus
8. `.claude/context/core/formats/plan-format.md` - Defines Status field on line 4

### Verified Issue Instance

Task 926 plan file status mismatch:
```
$ head -5 specs/926_audit_agent_system_context_efficiency/plans/implementation-001.md
# Implementation Plan: Task #926

- **Task**: 926 - Audit Agent System Context Efficiency
- **Status**: [NOT STARTED]    <-- SHOULD BE [COMPLETED]
- **Effort**: 4 hours
```

### Pattern for Plan File Status Update

```bash
# Regex pattern that matches the Status line in plan metadata
# - **Status**: [ANY_STATUS]
sed -i "s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [NEW_STATUS]/" "$plan_file"
```
