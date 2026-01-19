# Research Report: Task #601

**Task**: 601 - Design Task Review Logic and Validation Rules
**Date**: 2026-01-18
**Focus**: Design validation rules for state.json/TODO.md consistency, artifact links, completion verification, follow-up task workflow

## Summary

This research defines comprehensive validation rules for a `/task --review` command that will detect and optionally correct inconsistencies between state.json and TODO.md, validate artifact links, verify task completion, and facilitate follow-up task creation. The design leverages existing patterns from skill-status-sync, validation.md, and state-management.md while introducing new validation categories specific to task review workflows.

## Findings

### 1. Existing Validation Infrastructure

The codebase already has robust validation patterns that the review system should leverage:

**From `.claude/context/core/orchestration/validation.md`**:
- High-value checks: task existence, status transitions, delegation safety, argument validation, return format validation
- Artifact existence validation (for completed status only)
- Artifact non-empty validation (prevents phantom research)
- Session ID matching validation
- Git blame timestamp conflict resolution pattern

**From `.claude/rules/state-management.md`**:
- Two-phase update pattern (read both files, prepare in memory, write state.json first, then TODO.md)
- Status value mappings between TODO.md and state.json
- Artifact object schema with required fields: type, path, summary
- Lazy directory creation rule

**From `.claude/hooks/validate-state-sync.sh`**:
- Basic validation hook exists but only checks JSON validity
- No cross-file consistency checking currently implemented

### 2. State Consistency Validation Design

#### 2.1 Field Synchronization Rules

| Field | state.json | TODO.md | Sync Rule |
|-------|------------|---------|-----------|
| project_number | `project_number` | `### {N}.` heading | Must match exactly |
| status | `status` (snake_case) | `[STATUS]` (UPPER) | Must map correctly per status-management.md |
| priority | `priority` | `**Priority**:` | Must match exactly |
| language | `language` | `**Language**:` | Must match exactly |
| description | `description` | `**Description**:` | Optional sync (state.json may not have) |
| artifacts.path | `artifacts[].path` | Markdown links | All state.json paths must appear in TODO.md |
| created | `created` | `**Created**:` | Optional sync |
| completed | `completed` | `**Completed**:` | Required for COMPLETED tasks |

#### 2.2 Status Mapping Validation

```
Status Mapping Table:
not_started ↔ [NOT STARTED]
researching ↔ [RESEARCHING]
researched ↔ [RESEARCHED]
planning ↔ [PLANNING]
planned ↔ [PLANNED]
implementing ↔ [IMPLEMENTING]
completed ↔ [COMPLETED]
blocked ↔ [BLOCKED]
abandoned ↔ [ABANDONED]
partial ↔ [PARTIAL]
expanded ↔ [EXPANDED]
```

#### 2.3 Existence Checks

| Check | Description | Severity |
|-------|-------------|----------|
| Task in state.json but not TODO.md | "Orphan machine state" | ERROR |
| Task in TODO.md but not state.json | "Orphan human entry" | ERROR |
| Task number gap | Numbers between last and next missing | WARNING |
| Duplicate task number | Same number appears twice | ERROR |

### 3. Artifact Link Validation Design

#### 3.1 Path Format Validation

Artifacts must follow the naming convention from artifact-formats.md:

```
specs/{N}_{SLUG}/reports/research-{NNN}.md
specs/{N}_{SLUG}/plans/implementation-{NNN}.md
specs/{N}_{SLUG}/summaries/implementation-summary-{DATE}.md
```

Validation regex patterns:
- Research: `^specs/\d+_[a-z0-9_]+/reports/research-\d{3}\.md$`
- Plan: `^specs/\d+_[a-z0-9_]+/plans/implementation-\d{3}\.md$`
- Summary: `^specs/\d+_[a-z0-9_]+/summaries/implementation-summary-\d{8}\.md$`

#### 3.2 Artifact Existence Validation

| Check | Description | When Applied |
|-------|-------------|--------------|
| File exists | Artifact path points to existing file | Always |
| File non-empty | Artifact file has content (size > 0) | Always |
| Directory exists | Task directory exists | If any artifacts listed |
| Task number matches | Path contains correct task number | Always |

#### 3.3 Artifact Completeness by Status

| Status | Required Artifacts | Optional Artifacts |
|--------|-------------------|-------------------|
| researched | 1+ research report | - |
| planned | 1+ research report, 1 plan | - |
| completed | 1+ research, 1 plan, 1 summary | additional research/plans |
| partial | 1+ research, 1 plan | summary |
| blocked | 0-1+ research, 0-1 plan | - |

#### 3.4 Cross-Reference Validation

- Every artifact in state.json `artifacts[]` must have a corresponding link in TODO.md
- Every artifact link in TODO.md should be in state.json (warning if not)
- Artifact `summary` field should be non-empty in state.json

### 4. Completion Verification Design

#### 4.1 Plan Phase Completion Checks

For tasks with status `completed`, verify plan file shows all phases complete:

```markdown
# Detection Pattern
grep -E "^\*\*Status\*\*: \[(NOT STARTED|IN PROGRESS|PARTIAL|BLOCKED)\]" plan.md
```

If any phases are not `[COMPLETED]`, the task has incomplete work.

#### 4.2 Summary Content Verification

For completed tasks, verify summary contains:
- `**Completed**:` date field
- `## Changes Made` section
- `## Files Modified` section
- `## Verification` section

#### 4.3 Completion Verification Matrix

| Criterion | Check Method | Action on Failure |
|-----------|--------------|-------------------|
| All plan phases [COMPLETED] | Grep plan file | Flag as incomplete |
| Summary exists | File existence | Flag as missing summary |
| Summary has required sections | Grep summary file | Warning |
| Completed date in TODO.md | Parse TODO.md | Auto-fix or warn |
| Completed timestamp in state.json | Parse state.json | Auto-fix or warn |

### 5. Follow-up Task Workflow Design

#### 5.1 Incomplete Work Detection

When a "completed" task has incomplete work, generate a follow-up report:

```markdown
## Incomplete Work Report: Task #{N}

**Original Task**: {title}
**Incomplete Phases**: Phase 2, Phase 4
**Remaining Work**:
- Phase 2: [IN PROGRESS] - Modal soundness lemmas
- Phase 4: [NOT STARTED] - Test suite expansion

**Recommended Follow-up Tasks**:
1. "Complete phase 2 of task {N}: Modal soundness lemmas"
2. "Complete phase 4 of task {N}: Test suite expansion"
```

#### 5.2 Follow-up Task Creation

Follow-up tasks should:
- Reference parent task in description: "Continuation of Task #{N}"
- Inherit language from parent task
- Inherit priority from parent task
- Link to parent's research and plan artifacts
- Not duplicate completed phases

#### 5.3 Interactive vs Automatic Mode

| Mode | Behavior | Use Case |
|------|----------|----------|
| `--review` | Report issues, prompt for each fix | Normal review |
| `--review --fix` | Auto-fix obvious issues, prompt for ambiguous | Quick cleanup |
| `--review --dry-run` | Report issues only, no changes | Audit |

### 6. Validation Rule Categories

#### 6.1 Critical (ERROR) - Block completion

These issues must be fixed before a task can be considered complete:

1. **STATUS_MISMATCH**: state.json status doesn't map to TODO.md status
2. **MISSING_IN_STATE**: Task exists in TODO.md but not state.json
3. **MISSING_IN_TODO**: Task exists in state.json but not TODO.md
4. **ARTIFACT_NOT_FOUND**: Artifact path in state.json points to non-existent file
5. **EMPTY_ARTIFACT**: Artifact file exists but is empty (0 bytes)
6. **COMPLETED_NO_SUMMARY**: Task marked completed but no summary artifact
7. **PHANTOM_COMPLETION**: Task marked completed but plan phases incomplete

#### 6.2 Warning (WARN) - Should fix

These issues indicate problems but don't block workflow:

1. **PRIORITY_MISMATCH**: Priority differs between files
2. **LANGUAGE_MISMATCH**: Language differs between files
3. **MISSING_ARTIFACT_LINK**: state.json has artifact not linked in TODO.md
4. **ORPHAN_ARTIFACT_LINK**: TODO.md has link not in state.json artifacts
5. **MISSING_ARTIFACT_SUMMARY**: Artifact in state.json lacks summary field
6. **DESCRIPTION_MISMATCH**: Descriptions differ significantly
7. **TIMESTAMP_MISSING**: Expected timestamp fields missing

#### 6.3 Info (INFO) - Awareness only

1. **TASK_NUMBER_GAP**: Gap in task number sequence
2. **STALE_IN_PROGRESS**: Task marked in-progress for >24 hours
3. **ORPHAN_DIRECTORY**: specs/{N}_* directory exists but task not in state.json

### 7. Implementation Recommendations

#### 7.1 Validation Execution Order

1. **Parse phase**: Load both files into memory
2. **Cross-reference phase**: Build task maps, detect existence mismatches
3. **Field validation phase**: For each task, validate field consistency
4. **Artifact validation phase**: Check file existence and completeness
5. **Completion verification phase**: For completed tasks, verify work is done
6. **Report generation phase**: Compile issues by severity
7. **Fix phase** (optional): Apply corrections with user confirmation

#### 7.2 Correction Priority

When auto-fixing, apply corrections in order:
1. Existence fixes (add missing entries)
2. Status fixes (sync to most recent change)
3. Field fixes (priority, language, timestamps)
4. Artifact link fixes (add missing links)

#### 7.3 Git Blame for Conflict Resolution

When state.json and TODO.md disagree, use git blame to determine which was updated more recently:

```bash
# Get timestamp of last change to task in state.json
git log -1 --format=%ct -S "\"project_number\": $task_number" -- specs/state.json

# Get timestamp of last change to task in TODO.md
git blame -L "$start_line,$end_line" specs/TODO.md | head -1 | awk '{print $1}' | xargs git show -s --format=%ct
```

The more recent change wins, with state.json as tie-breaker (machine state is canonical).

### 8. User Confirmation Patterns

#### 8.1 Issue Presentation Format

```
[ERROR] STATUS_MISMATCH: Task 597
  state.json: blocked
  TODO.md: [IMPLEMENTING]
  Git blame: state.json updated 2026-01-19T06:37:54Z
  Recommended: Update TODO.md to [BLOCKED]

  (f)ix / (s)kip / (a)bort?
```

#### 8.2 Batch Operations

For tasks with multiple issues:
```
Task 597 has 3 issues:
  [ERROR] STATUS_MISMATCH - state.json: blocked, TODO.md: [IMPLEMENTING]
  [WARN] MISSING_ARTIFACT_LINK - research-003.md not in TODO.md
  [WARN] TIMESTAMP_MISSING - completed timestamp missing

  (f)ix all / (i)nteractive / (s)kip task / (a)bort?
```

## Recommendations

1. **Create validation rule engine**: Build a modular validation system that can run individual checks and aggregate results

2. **Implement two-pass approach**: First pass detects all issues, second pass applies fixes (allows user to review all issues before any changes)

3. **Leverage existing patterns**: Use git blame conflict resolution from validation.md, two-phase update from state-management.md

4. **Create follow-up task template**: Standardize how follow-up tasks reference their parent and inherit metadata

5. **Add dry-run mode**: Essential for safe review without accidental changes

6. **Consider hook integration**: Could add post-commit hook to run basic validation automatically

7. **Support task ranges**: Allow `--review 595-600` for batch review of specific tasks

## References

### Codebase References
- `.claude/context/core/orchestration/validation.md` - Existing validation patterns
- `.claude/rules/state-management.md` - State synchronization rules
- `.claude/rules/artifact-formats.md` - Artifact naming conventions
- `.claude/skills/skill-status-sync/SKILL.md` - Status update patterns
- `.claude/hooks/validate-state-sync.sh` - Existing validation hook

### External References
- [Workflow Engine vs State Machine](https://workflowengine.io/blog/workflow-engine-vs-state-machine/) - State machine validation concepts
- [Symfony Workflows and State Machines](https://symfony.com/doc/current/workflow/workflow-and-state-machine.html) - State transition validation patterns
- [Single Source of Truth (SSOT)](https://airbyte.com/data-engineering-resources/single-point-of-truth) - Data consistency patterns
- [Data Consistency Best Practices](https://www.decube.io/post/what-is-data-consistency-definition-examples-and-best-practice) - Cross-validation approaches
- [Real-Time Data Synchronization](https://www.serverion.com/uncategorized/top-7-practices-for-real-time-data-synchronization/) - Synchronization patterns
- [YAML Best Practices](https://spacelift.io/blog/yaml) - Validation and safe parsing

## Next Steps

1. Run `/plan 601` to create implementation plan based on these validation rules
2. Implement validation engine with modular rule system
3. Create CLI interface with interactive correction workflow
4. Add dry-run and batch operation support
5. Integrate with `/task` command as `--review` flag
