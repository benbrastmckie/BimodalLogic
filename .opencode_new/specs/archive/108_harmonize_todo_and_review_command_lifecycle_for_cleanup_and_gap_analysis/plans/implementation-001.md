# Implementation Plan: Harmonize /todo and /review command lifecycle for cleanup and gap analysis

**Project**: #108  
**Version**: 001  
**Date**: 2025-12-22  
**Complexity**: complex

## Task Description

Align /todo to own cleanup/archival (remove completed tasks from TODO, migrate state entries to archive/state.json, clear orphaned specs directories and stale state entries, synchronize Feature Registry and Implementation Status) and /review to own ambition/gap analysis that generates tasks via /add without changing numbering. Ensure TODO/state/archive/Feature Registry/Implementation Status stay in sync, comply with state-schema.md, tasks.md, and status-markers.md, enforce lazy directory creation and numbering protection.

## Complexity Assessment

- **Level**: complex
- **Estimated Effort**: 3–6 hours
- **Required Knowledge**: command lifecycle design, JSON state/archival schemas, Markdown task formatting, filesystem-safe moves, numbering/lazy-creation guardrails, documentation sync
- **Potential Challenges**: safe migration of completed_projects into archive/state.json, orphan/stale detection without data loss, preventing numbering or premature dir creation, extending /review for gap analysis + /add task generation, keeping Feature Registry and Implementation Status consistent

## Technology Stack

- **Languages**: Python (state manipulation utilities), Bash (orchestration wrappers), Markdown
- **Frameworks/Libraries**: json, pathlib/shutil (safe moves), datetime/ISO-8601 helpers
- **Tools**: validation against state-schema.md, tasks/status markers normalization utilities
- **Dependencies**: .opencode/context/common/system/{state-schema.md,status-markers.md,artifact-management.md}, .opencode/context/common/standards/tasks.md; command specs for /todo and /review

## Dependencies

### Required Modules/Packages

- JSON load/validate/write utilities for `.opencode/specs/state.json` and `.opencode/specs/archive/state.json`
- Markdown section update helpers for `.opencode/specs/TODO.md`, `Documentation/ProjectInfo/FEATURE_REGISTRY.md`, `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`
- Filesystem mover for `.opencode/specs/NNN_*` → `.opencode/specs/archive/NNN_*` (existing dirs only)

### Prerequisites

- Load standards: `state-schema.md`, `tasks.md`, `status-markers.md`, `artifact-management.md`
- Load current state snapshots: TODO, state.json, archive/state.json, specs directory listing, status docs
- Confirm no modification to `next_project_number` and no new project dirs unless archiving existing ones

### External Libraries

- Standard library (json, pathlib, shutil, datetime) only; no new external deps expected

## Implementation Steps

### Step 1: Establish lifecycle rules and data contracts
**Action**: Consolidate acceptance criteria into concrete rules for cleanup vs gap analysis; define archival record shape (timeline, artifacts.base_path, summary) per state-schema.md; codify numbering/lazy-creation guardrails.  
**File**: `.opencode/command/todo.md`, `.opencode/command/review.md`, `.opencode/context/common/system/state-schema.md`, `.opencode/context/common/standards/tasks.md`  
**Approach**: Document rule set and validation expectations; ensure /todo only cleans/archives and /review only generates tasks via /add; note confirmation gate for >5 removals.  
**Verification**: Rules trace back to task acceptance criteria; numbering/lazy-creation constraints explicitly documented.

### Step 2: Implement shared lifecycle helpers (detection + normalization)
**Action**: Create utilities to load/normalize TODO/state/archive; detect completed tasks, orphan specs dirs, stale state entries; normalize statuses per status-markers.md; compute migrations without executing writes.  
**File**: `.opencode/commands/todo` (shared helper module), `.opencode/commands/review` (read-only usage)  
**Approach**: Pure functions returning planned operations (remove-from-TODO, move-to-archive, warnings); no filesystem mutations yet; ensure idempotency and dry-run capability.  
**Verification**: Unit-level checks on sample fixtures; dry-run output matches expected operations for known fixtures (completed tasks present, archive empty, orphan dir present, stale state entry present).

### Step 3: Extend /todo cleanup/archival flow
**Action**: Wire helpers into /todo to perform cleanup and archival updates: remove completed tasks from TODO, migrate matching state entries to archive/state.json, move existing project dirs to archive/, clear orphan/stale entries, refresh `_last_updated`, and sync status docs.  
**File**: `.opencode/commands/todo`, `.opencode/specs/TODO.md`, `.opencode/specs/state.json`, `.opencode/specs/archive/state.json`, `Documentation/ProjectInfo/FEATURE_REGISTRY.md`, `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`  
**Approach**: Sequence: confirm (>5 removal guard) → apply TODO removals → state migration (active/pending → completed → archive entries with timeline/artifacts base_path) → directory moves (only if exists) → prune stale state/orphans → update status docs with maintenance summary; enforce no `next_project_number` change; no new dirs except archive moves.  
**Verification**: JSON validates against schema; archive/state.json populated for migrated entries; TODO/state/archive/status docs consistent in counts and IDs; no new project directories created.

### Step 4: Extend /review ambition/gap-analysis flow
**Action**: Add structured gap-analysis checklist and task generation path via /add or todo-manager; ensure /review does not perform cleanup or change numbering.  
**File**: `.opencode/commands/review`, `.opencode/specs/TODO.md`, `.opencode/specs/state.json`, `Documentation/ProjectInfo/FEATURE_REGISTRY.md`, `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`  
**Approach**: Implement analysis rubric (architecture coverage, docs gaps, command coverage) → produce task proposals → invoke /add (or equivalent) to register tasks so numbering stays centralized; update TODO/state pending_tasks and status docs accordingly; ensure no archive/state mutations or directory creation unless /add triggers artifact creation elsewhere.  
**Verification**: New tasks appear with proper IDs/status markers; `next_project_number` unchanged; archive untouched; status docs reflect new ambitions.

### Step 5: Add validation, safety, and reporting layers
**Action**: Add dry-run mode, confirmation prompts, and schema/status validations to both commands; include warning/error aggregation.  
**File**: `.opencode/commands/todo`, `.opencode/commands/review`  
**Approach**: Validate JSON after writes; enforce status markers; gate destructive operations (>5 removals) with confirmation; surface orphan/stale/dir-move warnings; ensure lazy directory creation by guarding mkdir calls (only on archive move).  
**Verification**: Dry-run outputs planned operations; live run passes validations; no unexpected directory creation; numbering remains unchanged.

### Step 6: Update documentation and examples
**Action**: Update Feature Registry and Implementation Status entries to reflect lifecycle split, archival responsibilities, gap-analysis outputs, and lazy creation guarantees; add examples of /todo cleanup and /review gap-analysis runs.  
**File**: `Documentation/ProjectInfo/FEATURE_REGISTRY.md`, `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`, `.opencode/command/{todo,review}.md`  
**Approach**: Add concise entries describing behaviors, safety gates, and numbering rules; include sample invocation + expected outputs; align terminology with tasks.md/status-markers.md.  
**Verification**: Docs cite updated behavior; acceptance criteria reflected; no conflicting statements about numbering or directory creation.

### Step 7: Testing and validation pass
**Action**: Execute scenario tests for cleanup and review flows; verify cross-file consistency and numbering protection.  
**File**: Test harness/fixtures (existing or new), state/TODO/archive/status docs  
**Approach**: Scenarios: (a) completed tasks with dirs; (b) completed tasks without dirs; (c) orphan dirs; (d) stale state entries; (e) /review generating tasks via /add; (f) >5 removals confirmation. Validate JSON and markers after each.  
**Verification**: All scenarios pass; no `next_project_number` changes; archive/state populated as expected; TODO/state/status docs synchronized; no empty dirs created.

## File Structure

```
.opencode/specs/108_harmonize_todo_and_review_command_lifecycle_for_cleanup_and_gap_analysis/
  plans/
    implementation-001.md
  reports/
    research-001.md
  summaries/
    plan-summary.md (new)
  state.json
```

## Testing Strategy

- **Unit Tests**: For detection/normalization helpers (completed/orphan/stale detection), status normalization, and archival record generation.
- **Integration Tests**: End-to-end /todo cleanup run over fixture datasets; /review gap-analysis run producing tasks via /add without touching archive.
- **Test Coverage**: Cover edge cases listed; ensure no `next_project_number` mutations and no unexpected directory creation.

## Verification Checkpoints

- [ ] Acceptance criteria mapped to ruleset and command specs
- [ ] Archive/state.json populated from completed_projects with valid schema
- [ ] TODO/state/archive/status docs consistent after /todo run
- [ ] /review produces tasks via /add with numbering unchanged
- [ ] Lazy directory creation enforced (only move existing dirs)

## Documentation Requirements

- Update command specs (/todo, /review) with lifecycle split, numbering guardrails, confirmation gates, and lazy-creation policy.
- Update Feature Registry and Implementation Status to reflect cleanup vs gap-analysis responsibilities and recent maintenance/review outcomes.

## Success Criteria

- /todo reliably cleans and archives without creating new project directories or altering numbering; TODO/state/archive/status docs match.
- /review delivers gap-analysis tasks via /add with numbering intact and no cleanup side effects.
- Archive/state.json populated and consistent with completed projects; orphan/stale issues resolved or warned.
- Lazy directory creation enforced across both commands.

## Related Research

- [Project #108 Research](../reports/research-001.md)

## Notes

- Ensure confirmation gate for bulk removals (>5 completed tasks) remains in /todo flow.
- Preserve `pending_tasks` status values; do not mutate `next_project_number` in either command.
