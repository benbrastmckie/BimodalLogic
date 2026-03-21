# Research Report: Missing Stage 7 (Postflight) Validation in Workflow Commands

## Executive Summary
Research into the `.opencode/command/*.md` files reveals that while core workflow commands (`research`, `plan`, `implement`, `revise`) have implemented a robust "Postflight" stage (Stage 3.5) for validation and git commits, several other commands (`task`, `review`, `todo`) lack this critical safety mechanism. Most notably, `review.md` modifies project state (creating tasks) without creating a git commit, leading to potential data loss or inconsistent state. `meta.md` does not follow the standard `<workflow_execution>` structure at all.

## Scope
- **Analyzed Directory**: `.opencode/command/`
- **Files Analyzed**: `task.md`, `research.md`, `plan.md`, `implement.md`, `review.md`, `revise.md`, `meta.md`, `todo.md`, `errors.md`
- **Focus**: Presence and completeness of "Stage 7" (Postflight) validation checkpoints.

## Findings

### 1. Compliant Commands
The following commands have a robust "Postflight" stage (numbered 3.5) that performs:
- Artifact validation (existence and non-empty check)
- Atomic status updates via `status-sync-manager`
- Verification of status updates in `state.json`
- Git commit creation via `git-workflow-manager`
- Validation of git commit success

**Commands:**
- `research.md`
- `plan.md`
- `implement.md`
- `revise.md`

### 2. Non-Compliant Commands

#### A. `review.md` (Critical)
- **Issue**: The command has a `CreateTasks` stage (Stage 3.5) that modifies `TODO.md` and `state.json` to add new tasks based on the review. However, it **lacks a subsequent Postflight stage** to create a git commit for these changes.
- **Risk**: New tasks are created but not committed. If the user runs another command or resets, these tasks could be lost or become "phantom" tasks (in `state.json` but not in git history).
- **Recommendation**: Add Stage 3.6 (Postflight) to validate the task creation and create a git commit.

#### B. `task.md` (High)
- **Issue**: Acts as a router for `task-creator`, `status-sync-manager`, etc. It validates the *return format* of the subagent but does not verify the *effect* (e.g., that `TODO.md` was actually updated).
- **Risk**: Silent failures where the subagent reports success but the file system is unchanged.
- **Recommendation**: Add Stage 3 (Postflight) before returning results to verify `TODO.md`/`state.json` updates and ensure a git commit was created (if the operation warrants it).

#### C. `todo.md` (Medium)
- **Issue**: Relies on `todo-manager` for archival. It displays git commit info if returned, but does not independently verify that the archival (moving files, updating `TODO.md`) actually occurred on disk.
- **Risk**: "Phantom" archival where the agent says it archived tasks but files remain in the active directory.
- **Recommendation**: Add Stage 3.5 (Postflight) to verify file moves and `TODO.md` updates.

#### D. `meta.md` (Structural)
- **Issue**: Does not follow the standard `<workflow_execution>` XML structure. It uses text-based descriptions and delegates entirely to the `meta` agent.
- **Risk**: Inconsistent behavior and lack of command-level validation.
- **Recommendation**: Refactor `meta.md` to use the standard `<workflow_execution>` structure with explicit stages, including Postflight validation.

#### E. `errors.md` (Compliant/N/A)
- **Status**: Read-only command. Explicitly states "No Preflight/Postflight needed".

## Implementation Plan

### Phase 1: Fix `review.md` (Critical)
1.  Add Stage 3.6 "Postflight" to `review.md`.
2.  Validate that `TODO.md` and `state.json` were updated.
3.  Invoke `git-workflow-manager` to commit the changes (message: "review: created N tasks").
4.  Validate git commit success.

### Phase 2: Fix `task.md`
1.  Insert Stage 3 "Postflight" (renaming current Stage 3 to 4).
2.  Verify `TODO.md` and `state.json` timestamps/content changed.
3.  Verify git commit hash in subagent return (if applicable).

### Phase 3: Fix `todo.md`
1.  Insert Stage 3.5 "Postflight".
2.  Verify project directories were moved to `archive/`.
3.  Verify tasks are marked `[ABANDONED]` or `[COMPLETED]` in `TODO.md`.

### Phase 4: Refactor `meta.md` (Future)
- Defer to a separate refactoring task as it requires rewriting the entire command file structure.

## Standardized Postflight Pattern
All fixed commands should implement this pattern:
```xml
<stage id="X" name="Postflight">
  <action>Verify effects and ensure git commit</action>
  <process>
    1. Verify file system changes (artifacts, status updates, moves).
    2. Verify state consistency (TODO.md vs state.json).
    3. Ensure git commit was created (check hash or invoke git-workflow-manager).
    4. Log success/failure.
  </process>
  <validation>
    - Changes verified on disk
    - Git commit verified
  </validation>
</stage>
```
