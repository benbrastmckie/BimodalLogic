# Task Standards

## Purpose

Standards for creating, formatting, and managing tasks within the .opencode system. These standards ensure consistency across .opencode/specs/TODO.md, IMPLEMENTATION_STATUS.md, and state tracking.

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
-   Guess the next number by reading `.opencode/specs/TODO.md`.
-   Reuse IDs from archived or deleted tasks.

### Formatting Standards

#### Header
-   Format: `### {Task ID}. {Task Title}`
-   Example: `### 90. Implement User Login`

#### Metadata

**Required Fields**:
- **Description**: Clear description of the task (user must provide)

**Auto-Populated Fields (Defaults Used if Not Provided)**:
- **Priority**: Medium (override if task is urgent or low priority)
- **Language**: markdown (override if task involves code)
- **Effort**: 2 hours (override if you have better estimate)
- **Files Affected**: TBD (override if you know which files)
- **Dependencies**: None (override if task depends on others)
- **Blocking**: None (override if task blocks others)
- **Acceptance Criteria**: Generic checklist (override for specific criteria)
- **Impact**: Generic statement (override for specific impact)
- **Status**: `pending`, `in-progress`, `blocked`, `completed` (displayed in .opencode/specs/TODO.md using status markers per status-markers.md)

**When to Override Defaults**:

Override Priority when:
- Task is urgent or blocking critical work → High
- Task is nice-to-have or low impact → Low

Override Language when:
- Task involves Lean code → lean
- Task involves specific language → specify language

Override Effort when:
- You have a better estimate based on task complexity
- Task is known to be quick (<1 hour) or long (>4 hours)

Override Files Affected when:
- You know which files will be modified
- Task is file-specific (e.g., "Fix bug in Foo.lean")

Override Acceptance Criteria when:
- Task has specific, measurable success criteria
- Generic checklist is not sufficient

Override Impact when:
- Task has significant impact on project
- Generic statement doesn't capture importance

#### Content
-   **Files Affected**: List of file paths.
-   **Description**: Clear description of the task.
-   **Acceptance Criteria**: Checkbox list of requirements.
-   **Impact**: Statement of impact.

### Placement

#### .opencode/specs/TODO.md
-   Insert under the appropriate Priority section (High, Medium, Low).
-   Reorganization: /todo may regroup pending tasks by kind (feature, documentation, maintenance, research) while preserving numbering and metadata. Completed tasks move to the "Completed" section. Reorganization must not create or modify project directories or artifacts.
-   Maintain lazy directory creation: no directories are created during TODO reordering.

#### IMPLEMENTATION_STATUS.md
-   Add reference: `**Planned Work**: Task {Task ID}: {Task Title}`

## Command Integration

- `/implement` **must** reuse the plan link attached in .opencode/specs/TODO.md when present and update that plan in place with status markers. When no plan is linked, `/implement` executes directly (no failure) while preserving lazy directory creation (no project roots/subdirs unless an artifact is written) and numbering/state sync; guidance to use `/plan {task}` remains recommended for complex work.
- `/implement`, `/review`, and `/todo` **must** keep IMPLEMENTATION_STATUS.md, SORRY_REGISTRY.md, and TACTIC_REGISTRY.md in sync when they change task/plan/implementation status or sorry/tactic counts.
- `/implement` must emit an implementation summary artifact (standard naming) whenever task execution writes implementation artifacts; status-only paths do not emit summaries. Maintain lazy directory creation.
- `/review`, `/todo`, and `/implement` must capture/populate the `Language` metadata for every task they create or modify; backfill missing Language when encountered.
- `/implement` uses the TODO task `Language` field as the authoritative Lean intent signal. Plan `lean:` metadata is secondary. If `Language` is missing, warn and default to non-Lean unless the user explicitly supplies `--lang lean` (explicit flag wins over metadata when they disagree).
- Commands mirror status markers (`[NOT STARTED]`, `[IN PROGRESS]`, `[BLOCKED]`, `[ABANDONED]`, `[COMPLETED]`) and timestamps between plan files and TODO/state, without altering numbering rules.
- **Lean routing and MCP validation**:
  - Lean research requests **must** use the Lean research subagent; Lean implementation requests **must** use the Lean implementation subagent, selected from the TODO `Language` field (or explicit flag override) rather than heuristics.
  - Validate Lean MCP server availability against `.mcp.json` before dispatch; fail with a clear error if required servers are missing/unreachable or if the command is absent/returns non-zero during a health ping.
  - Default required Lean server: `lean-lsp` (stdio via `uvx lean-lsp-mcp`); planned servers (`lean-explore`, `loogle`, `lean-search`) should raise a "planned/not configured" warning instead of proceeding silently.
  - When validation fails, surface remediation steps (install command, set env like `LEAN_PROJECT_PATH`, supply API keys) and do **not** create project directories or artifacts.

## Quality Checklist

-   [ ] Task ID is unique and retrieved from `state.json`.
-   [ ] Title is clear and descriptive.
-   [ ] Metadata (Effort, Status, Priority, **Language**) is complete.
-   [ ] Language field reflects the primary language for the work (e.g., `lean`, `markdown`, `python`, `shell`, `json`).
-   [ ] Dependencies are correctly listed.
-   [ ] Acceptance criteria are testable.
-   [ ] No emojis are present.

## Maintenance

### Archival
-   Completed tasks should be archived when the project is finished.
-   Update `state.json` to move project from `active_projects` to `completed_projects` (and eventually `archive/state.json`).
