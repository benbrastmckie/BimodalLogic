# Implementation Plan: Align /revise command with /add and /plan for task-linked plan revisions

**Task**: #107  
**Complexity**: Moderate  
**Estimated Effort**: 3 hours  
**Priority**: High

## Task Description
Ensure `/revise {task_number} "{prompt}"` resolves the task’s plan reference from TODO.md, writes an incremented plan version in the same project directory, and updates TODO/state/doc references consistently with `/add` and `/plan`, without creating new project directories.

## Objectives
- Normalize `/revise` contract with `/add` and `/plan` (task-number + prompt, no premature directory creation).
- Ensure plan lookup, versioning, and linkage back to TODO/state/docs are consistent and reliable.
- Gracefully handle missing tasks or missing plan references.

## Current Gaps to Address
1) `/revise` spec lacks explicit plan-resolution logic and guardrails (task/plan lookup, errors).  
2) Plan versioning and TODO/state/doc updates not aligned with `/add` and `/plan` flows.  
3) State/doc sync rules need to be clarified (pending_tasks, project state, IMPLEMENTATION_STATUS, FEATURE_REGISTRY).  
4) No explicit user-facing usage update for the harmonized contract.

## Plan
1) **Analyze current command specs & standards**  
   - Review `.opencode/command/revise.md`, `.opencode/command/plan.md`, `.opencode/command/add.md`, `context/common/system/artifact-management.md`, `context/common/system/state-schema.md`, and `context/common/standards/tasks.md` for expected behaviors and status markers.

2) **Define task & plan resolution rules**  
   - Resolve TODO entry by task number; if missing, fail with clear message.  
   - Extract existing plan link from TODO (or project link), ensuring no project directories are created if missing; instruct user to run `/plan` first when absent.  
   - Validate plan path exists on disk; if not, report gracefully.

3) **Versioning & artifact creation**  
   - Locate highest `implementation-XXX.md` in the project’s `plans/`.  
   - Create `implementation-{next}.md` with revision header, status markers, and prompt/delta notes.  
   - Preserve project directory and numbering; do not touch `next_project_number`.

4) **Sync TODO and state**  
   - Update TODO task metadata to reference the new plan version (status remains aligned with task markers).  
   - Update project `state.json` (plans array append, phase/status refresh).  
   - Update `.opencode/specs/state.json` pending task entry (status and timestamps as needed) without creating new projects.  
   - Keep archive untouched.

5) **Update documentation**  
   - Add usage example and contract notes to `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md` and `Documentation/ProjectInfo/FEATURE_REGISTRY.md` to reflect the harmonized `/revise` behavior.  
   - Ensure messaging aligns with `/add` + `/plan`.

6) **Validation & safeguards**  
   - Add guardrails and error messages for: missing task ID, missing plan link, missing plan file.  
   - Smoke-test on sample tasks (with/without plan links).  
   - Verify JSON and Markdown integrity after updates.

## Files to Modify
- `.opencode/command/revise.md`
- `.opencode/command/plan.md` (cross-references/contract alignment)
- `.opencode/command/add.md` (contract notes, if needed)
- `.opencode/context/common/system/artifact-management.md` (plan versioning notes, if needed)
- `.opencode/specs/TODO.md` (plan reference updates)
- `.opencode/specs/state.json` (pending task status, references)
- `.opencode/specs/107_align_revise_command_with_add_and_plan_for_task_linked_plan_revisions/state.json` (project state)
- `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`
- `Documentation/ProjectInfo/FEATURE_REGISTRY.md`

## Verification
- `/revise 107 "test"` resolves task 107, finds existing plan reference, and creates `implementation-00{N+1}.md` in the same project folder.  
- TODO entry shows the new plan link with unchanged task numbering/status markers.  
- `state.json` and project `state.json` updated without altering `next_project_number` or creating new projects.  
- Usage docs reflect the task-number + prompt contract and the no-new-directory rule.  
- File format validations pass (JSON lint, Markdown sanity) and no unintended edits to other tasks or state entries.
