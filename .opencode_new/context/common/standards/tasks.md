# Task Standards

## Purpose

Standards for creating, formatting, and managing tasks within the .opencode system. These standards ensure consistency across TODO.md, IMPLEMENTATION_STATUS.md, and state tracking.

## Core Principles

1.  **Unique IDs**: Every task MUST have a unique ID derived from `state.json`.
2.  **Atomic**: Tasks should be actionable units of work.
3.  **Tracked**: Status and priority must be explicitly tracked using the standard markers.
4.  **Linked**: Tasks must link to relevant artifacts (reports, plans, summaries).
5.  **No emojis**: Task titles, descriptions, and artifacts must not include emojis.

## General Standards

### ID Generation

**Do**:
-   Retrieve Task IDs from `.opencode/specs/state.json`.
-   Use the `next_project_number` field.
-   Increment `next_project_number` in `state.json` immediately after use.

**Don't**:
-   Guess the next number by reading `TODO.md`.
-   Reuse IDs from archived or deleted tasks.

### Formatting Standards

#### Header
-   Format: `### {Task ID}. {Task Title}`
-   Example: `### 90. Implement User Login`

#### Metadata
-   **Effort**: Estimated time (e.g., "2 hours")
-   **Status**: `pending`, `in-progress`, `blocked`, `completed` (displayed in TODO.md using status markers per status-markers.md)
-   **Priority**: `High`, `Medium`, `Low`
-   **Blocking**: List of Task IDs blocked by this task, or `None`
-   **Dependencies**: List of Task IDs this task depends on, or `None`

#### Content
-   **Files Affected**: List of file paths.
-   **Description**: Clear description of the task.
-   **Acceptance Criteria**: Checkbox list of requirements.
-   **Impact**: Statement of impact.

### Placement

#### TODO.md
-   Insert under the appropriate Priority section (High, Medium, Low).
-   Reorganization: /todo may regroup pending tasks by kind (feature, documentation, maintenance, research) while preserving numbering and metadata. Completed tasks move to the "Completed" section. Reorganization must not create or modify project directories or artifacts.
-   Maintain lazy directory creation: no directories are created during TODO reordering.

#### IMPLEMENTATION_STATUS.md
-   Add reference: `**Planned Work**: Task {Task ID}: {Task Title}`

## Command Integration

- `/task` **must** reuse the plan link attached in TODO.md when present and update that plan in place with status markers. When no plan is linked, `/task` executes directly (no failure) while preserving lazy directory creation (no project roots/subdirs unless an artifact is written) and numbering/state sync; guidance to use `/plan {task}` remains recommended for complex work.
- `/implement` **requires** a plan path argument, updates the referenced plan phases with status markers (and timestamps), syncs status to TODO/state for referenced tasks, and respects lazy directory creation (no project roots/subdirs unless writing artifacts).
- Both commands mirror status markers (`[NOT STARTED]`, `[IN PROGRESS]`, `[BLOCKED]`, `[ABANDONED]`, `[COMPLETED]`) and timestamps between plan files and TODO/state, without altering numbering rules.

## Quality Checklist

-   [ ] Task ID is unique and retrieved from `state.json`.
-   [ ] Title is clear and descriptive.
-   [ ] Metadata (Effort, Status, Priority) is complete.
-   [ ] Dependencies are correctly listed.
-   [ ] Acceptance criteria are testable.
-   [ ] No emojis are present.

## Maintenance

### Archival
-   Completed tasks should be archived when the project is finished.
-   Update `state.json` to move project from `active_projects` to `completed_projects` (and eventually `archive/state.json`).
