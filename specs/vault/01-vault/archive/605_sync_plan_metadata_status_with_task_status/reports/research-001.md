# Research Report: Task #605

**Task**: 605 - Sync Plan Metadata Status with Task Status
**Date**: 2026-01-19
**Focus**: Analyzing current status update patterns and identifying insertion points for plan metadata sync

## Summary

The implementation plan files have a `**Status**:` field in their metadata header (e.g., `**Status**: [NOT STARTED]`) that is NOT being updated when tasks progress through research/plan/implement cycles. Analysis of completed tasks (604, 568, 601) confirms their plan files still show `[NOT STARTED]` despite being `[COMPLETED]` in TODO.md and state.json. This creates an inconsistency between the three status sources.

## Findings

### 1. Plan File Metadata Format

Plan files use a YAML-like markdown metadata block at the top:

```markdown
# Implementation Plan: Task #{N}

- **Task**: {N} - {title}
- **Status**: [NOT STARTED]        <-- This field is not being updated
- **Effort**: 3 hours
- **Priority**: High
- **Dependencies**: ...
```

The `**Status**:` field follows the same status markers as TODO.md: `[NOT STARTED]`, `[RESEARCHING]`, `[PLANNED]`, `[IMPLEMENTING]`, `[COMPLETED]`, etc.

**Evidence**: Tasks 604 and 568 are both `[COMPLETED]` in state.json/TODO.md but their plan files show `[NOT STARTED]`:
- `specs/604_migrate_fmp_to_semanticcanonicalmodel_v2/plans/implementation-001.md` line 4: `**Status**: [NOT STARTED]`
- `specs/568_create_metalogic_v2_test_suite/plans/implementation-001.md` line 4: `**Status**: [NOT STARTED]`

### 2. Current Status Update Locations

Status updates occur in the skill postflight stages (Stage 7 in most skills):

| Skill | Files Updated | Plan Status Updated? |
|-------|---------------|---------------------|
| skill-planner | state.json, TODO.md | No (creates plan with `[NOT STARTED]`) |
| skill-implementer | state.json, TODO.md | No |
| skill-lean-implementation | state.json, TODO.md | No |
| skill-latex-implementation | state.json, TODO.md | No |
| skill-researcher | state.json, TODO.md | N/A (no plan yet) |

### 3. Status Transition Points That Need Plan Updates

Based on workflow analysis, the plan file Status should be updated at these transitions:

| Transition | Trigger | Plan Status Should Change To |
|------------|---------|------------------------------|
| PLANNED -> IMPLEMENTING | /implement preflight | [IMPLEMENTING] |
| IMPLEMENTING -> COMPLETED | /implement postflight | [COMPLETED] |
| IMPLEMENTING -> PARTIAL | /implement postflight (timeout) | [PARTIAL] |
| PLANNED -> REVISING | /revise preflight | [REVISING] |
| REVISING -> REVISED | /revise postflight | New plan created with [NOT STARTED] |

**Note**: When a task is `[PLANNED]`, the plan file exists with `[NOT STARTED]`. The plan status should transition independently from the task status.

### 4. Current Skill Architecture

Implementation skills follow this pattern (from `skill-implementer/SKILL.md`):

```
Stage 1: Input Validation
Stage 2: Preflight Status Update      <-- Updates state.json, TODO.md
Stage 3: Create Postflight Marker
Stage 4: Prepare Delegation Context
Stage 5: Invoke Subagent
Stage 6: Parse Subagent Return
Stage 7: Update Task Status           <-- Updates state.json, TODO.md
Stage 8: Link Artifacts
Stage 9: Git Commit
Stage 10: Cleanup
Stage 11: Return Brief Summary
```

The plan file update should be added to Stage 2 (preflight) and Stage 7 (postflight).

### 5. Plan File Location Pattern

Plan files are located at:
```
specs/{N}_{SLUG}/plans/implementation-{NNN}.md
```

The `{NNN}` version number (001, 002, etc.) means there may be multiple plan versions. The skill should update the **latest** plan file (highest version number).

### 6. Existing Documentation Intent

The `status-markers.md` standard (line 316-317) already mentions that status-sync-manager should update plan files:

> **Atomic Synchronization**
> status-sync-manager updates atomically:
> 1. TODO.md (status marker, timestamps, artifact links)
> 2. state.json (status field, timestamps, artifact_paths)
> 3. Plan file (phase status markers, if plan exists)

However, this refers to **phase status markers** (e.g., `### Phase 1: Name [COMPLETED]`), not the **top-level plan metadata Status field**. The top-level field is a separate concern.

### 7. Implementation Agents Already Update Phase Status

The `general-implementation-agent.md` (Stage 4) shows phase status updates:

```markdown
**A. Mark Phase In Progress**
Edit plan file: Change phase status to `[IN PROGRESS]`

...

**D. Mark Phase Complete**
Edit plan file: Change phase status to `[COMPLETED]`
```

This means agents already edit plan files. Adding top-level Status updates follows the same pattern.

## Recommendations

### Recommendation 1: Add Plan Status Update to Skill Postflight

Add a new sub-stage in Stage 7 (Update Task Status) of implementation skills:

```bash
# After updating state.json and TODO.md, update plan file
plan_file=$(ls -1 "specs/${task_number}_${project_name}/plans/implementation-"*.md 2>/dev/null | sort -V | tail -1)
if [ -n "$plan_file" ]; then
    # Update plan metadata Status field
    sed -i "s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [${new_status_uppercase}]/" "$plan_file"
fi
```

### Recommendation 2: Add Plan Status Update to Skill Preflight

Update Stage 2 (Preflight Status Update) similarly:

```bash
# After updating state.json and TODO.md to IMPLEMENTING
plan_file=$(ls -1 "specs/${task_number}_${project_name}/plans/implementation-"*.md 2>/dev/null | sort -V | tail -1)
if [ -n "$plan_file" ]; then
    sed -i "s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [IMPLEMENTING]/" "$plan_file"
fi
```

### Recommendation 3: Update These Skills

1. `.claude/skills/skill-implementer/SKILL.md` - General implementation
2. `.claude/skills/skill-lean-implementation/SKILL.md` - Lean implementation
3. `.claude/skills/skill-latex-implementation/SKILL.md` - LaTeX implementation
4. `.claude/skills/skill-planner/SKILL.md` - Should create plan with `[NOT STARTED]` (already does)

### Recommendation 4: Consider skill-status-sync Integration

For standalone status corrections, `skill-status-sync` could also be enhanced to optionally update plan files. However, since workflow skills now handle their own status updates inline, this is lower priority.

### Recommendation 5: Status Mapping

| state.json status | TODO.md marker | Plan Status |
|-------------------|----------------|-------------|
| implementing | [IMPLEMENTING] | [IMPLEMENTING] |
| completed | [COMPLETED] | [COMPLETED] |
| partial | [PARTIAL] | [PARTIAL] |
| blocked | [BLOCKED] | [BLOCKED] |

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Plan file doesn't exist (task not yet planned) | Check file exists before sed; skip gracefully |
| Multiple plan versions | Use `sort -V | tail -1` to get latest |
| Regex doesn't match (malformed header) | Use robust pattern that handles variations |
| Edit fails silently | Verify edit applied with grep after sed |

## References

- `.claude/skills/skill-implementer/SKILL.md` - Current implementation skill pattern
- `.claude/skills/skill-lean-implementation/SKILL.md` - Lean implementation skill
- `.claude/context/core/formats/plan-format.md` - Plan metadata specification
- `.claude/context/core/standards/status-markers.md` - Status marker definitions
- `.claude/rules/state-management.md` - State synchronization rules

## Next Steps

1. Run `/plan 605` to create an implementation plan
2. The plan should include:
   - Phase 1: Add plan status update to skill-implementer (preflight + postflight)
   - Phase 2: Add plan status update to skill-lean-implementation
   - Phase 3: Add plan status update to skill-latex-implementation
   - Phase 4: Test with a sample task through full cycle
3. Verification: After implementation, check that completed tasks have synchronized Status fields across all three files (state.json, TODO.md, plan file)
