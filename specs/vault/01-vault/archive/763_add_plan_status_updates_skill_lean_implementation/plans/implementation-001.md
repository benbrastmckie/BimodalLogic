# Implementation Plan: Task #763

- **Task**: 763 - add_plan_status_updates_skill_lean_implementation
- **Status**: [COMPLETED]
- **Effort**: 0.5 hours
- **Priority**: medium
- **Dependencies**: None
- **Research Inputs**: specs/763_add_plan_status_updates_skill_lean_implementation/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Add the plan status update pattern (sed commands to update `- **Status**: [...]` line) to skill-lean-implementation/SKILL.md at three specific locations: preflight ([IMPLEMENTING]), postflight success ([COMPLETED]), and postflight partial ([PARTIAL]). This pattern already exists in skill-implementer, skill-latex-implementation, and skill-typst-implementation, so the changes follow a well-established pattern.

### Research Integration

The research report identified exact insertion points:
- **Location 1**: After line 94 (Stage 2: Preflight Status Update), before the `---` divider
- **Location 2**: After line 240 (Stage 7: "If status is implemented"), before "If status is partial"
- **Location 3**: After line 245 (Stage 7: "If status is partial"), before the `---` divider

## Goals & Non-Goals

**Goals**:
- Add plan file status update to [IMPLEMENTING] in Stage 2 (preflight)
- Add plan file status update to [COMPLETED] in Stage 7 (postflight success)
- Add plan file status update to [PARTIAL] in Stage 7 (postflight partial)
- Maintain consistency with sister skills (skill-implementer, skill-latex-implementation, skill-typst-implementation)

**Non-Goals**:
- Phase-level status updates (responsibility of the agent, not the skill)
- Failed case handling (consistent with sister skills - plan stays [IMPLEMENTING] for retry)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Plan file doesn't exist | Low | Low | Guard clause `[ -n "$plan_file" ]` handles gracefully |
| sed pattern doesn't match | Low | Low | Regex is robust, matches any `[...]` content |
| Line numbers shifted since research | Medium | Low | Verify insertion points before editing |

## Implementation Phases

### Phase 1: Add Preflight Status Update [COMPLETED]

**Goal**: Add plan file status update to [IMPLEMENTING] in Stage 2, before the `---` divider after the TODO.md update.

**Tasks**:
- [ ] Verify current line 94-96 content matches expected pattern
- [ ] Insert plan file update block after TODO.md update instruction

**Timing**: 10 minutes

**Files to modify**:
- `.claude/skills/skill-lean-implementation/SKILL.md` - Insert preflight plan update after line 94

**Code to insert** (after "**Update TODO.md**: Use Edit tool to change status marker from `[PLANNED]` to `[IMPLEMENTING]`." and before `---`):

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

**Verification**:
- Stage 2 section contains both TODO.md and plan file update instructions
- Code block uses identical sed pattern as sister skills

---

### Phase 2: Add Postflight Completed Status Update [COMPLETED]

**Goal**: Add plan file status update to [COMPLETED] in Stage 7 postflight (implemented case), after the TODO.md update and before "If status is partial".

**Tasks**:
- [ ] Verify current line 240-242 content matches expected pattern
- [ ] Insert plan file update block after TODO.md update for completed case

**Timing**: 10 minutes

**Files to modify**:
- `.claude/skills/skill-lean-implementation/SKILL.md` - Insert completed plan update around line 240

**Code to insert** (after "Update TODO.md: Change status marker from `[IMPLEMENTING]` to `[COMPLETED]`." and before "**If status is \"partial\"**:"):

```markdown

**Update plan file** (if exists): Update the Status field to `[COMPLETED]`:
```bash
plan_file=$(ls -1 "specs/${task_number}_${project_name}/plans/implementation-"*.md 2>/dev/null | sort -V | tail -1)
if [ -n "$plan_file" ] && [ -f "$plan_file" ]; then
    sed -i "s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [COMPLETED]/" "$plan_file"
fi
```

```

**Verification**:
- Completed case in Stage 7 includes plan file update
- Pattern matches sister skills

---

### Phase 3: Add Postflight Partial Status Update [COMPLETED]

**Goal**: Add plan file status update to [PARTIAL] in Stage 7 postflight (partial case), after the TODO.md note and before the `---` divider.

**Tasks**:
- [ ] Verify current line 244-246 content matches expected pattern
- [ ] Insert plan file update block after TODO.md partial note

**Timing**: 10 minutes

**Files to modify**:
- `.claude/skills/skill-lean-implementation/SKILL.md` - Insert partial plan update around line 245

**Code to insert** (after "TODO.md stays as `[IMPLEMENTING]`." and before `---`):

```markdown

**Update plan file** (if exists): Update the Status field to `[PARTIAL]`:
```bash
plan_file=$(ls -1 "specs/${task_number}_${project_name}/plans/implementation-"*.md 2>/dev/null | sort -V | tail -1)
if [ -n "$plan_file" ] && [ -f "$plan_file" ]; then
    sed -i "s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [PARTIAL]/" "$plan_file"
fi
```

```

**Verification**:
- Partial case in Stage 7 includes plan file update
- Pattern matches sister skills

---

## Testing & Validation

- [ ] All three plan status update blocks are present in skill-lean-implementation/SKILL.md
- [ ] sed patterns are identical to those in sister skills
- [ ] Each code block is properly fenced with bash syntax highlighting
- [ ] Guard clauses check for file existence before sed
- [ ] No syntax errors in markdown (code blocks properly closed)

## Artifacts & Outputs

- Modified: `.claude/skills/skill-lean-implementation/SKILL.md` (3 insertions)

## Rollback/Contingency

If implementation causes issues:
1. Revert to previous version: `git checkout HEAD~1 -- .claude/skills/skill-lean-implementation/SKILL.md`
2. The changes are purely additive - removing the three blocks restores original behavior
