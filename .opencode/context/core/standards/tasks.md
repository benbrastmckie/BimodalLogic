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
- **Type**: markdown (override if task involves code or meta work)
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

Override Type when:
- Task involves Lean code → lean
- Task involves meta work (agents, commands, context) → meta
- Task involves specific language → specify language (python, shell, etc.)

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
- `/review`, `/todo`, and `/implement` must capture/populate the `Type` metadata for every task they create or modify; backfill missing Type when encountered.
- `/implement` uses the TODO task `Type` field as the authoritative routing signal. Plan metadata is secondary. If `Type` is missing, warn and default to general unless the user explicitly supplies `--type {type}` (explicit flag wins over metadata when they disagree).
- Commands mirror status markers (`[NOT STARTED]`, `[IN PROGRESS]`, `[BLOCKED]`, `[ABANDONED]`, `[COMPLETED]`) and timestamps between plan files and TODO/state, without altering numbering rules.
- **Lean routing and MCP validation**:
  - Lean research requests **must** use the Lean research subagent; Lean implementation requests **must** use the Lean implementation subagent, selected from the TODO `Type` field (or explicit flag override) rather than heuristics.
  - Validate Lean MCP server availability against `.mcp.json` before dispatch; fail with a clear error if required servers are missing/unreachable or if the command is absent/returns non-zero during a health ping.
  - Default required Lean server: `lean-lsp` (stdio via `uvx lean-lsp-mcp`); planned servers (`lean-explore`, `loogle`, `lean-search`) should raise a "planned/not configured" warning instead of proceeding silently.
  - When validation fails, surface remediation steps (install command, set env like `LEAN_PROJECT_PATH`, supply API keys) and do **not** create project directories or artifacts.

## Quality Checklist

-   [ ] Task ID is unique and retrieved from `state.json`.
-   [ ] Title is clear and descriptive.
-   [ ] Metadata (Effort, Status, Priority, **Type**) is complete.
-   [ ] Type field reflects the primary type for the work (e.g., `lean`, `markdown`, `python`, `shell`, `json`, `meta`).
-   [ ] Dependencies are correctly listed.
-   [ ] Acceptance criteria are testable.
-   [ ] No emojis are present.
-   [ ] Metadata format uses `- **Field**:` pattern (not `*Field**:` or other variants).
-   [ ] All required fields present (Type, Effort, Priority, Status).

## Troubleshooting

### Missing Type Field

**Problem**: Task is missing the Type field.

**Impact**: 
- Prevents proper routing to specialized agents (lean-research-agent, lean-implementation-agent, meta subagents)
- Breaks automation workflows that depend on Type field
- Violates task standards (Type is MANDATORY per line 110 quality checklist)

**Solution**:
1. Identify the primary type for the task:
   - Lean code tasks → `- **Type**: lean`
   - Documentation tasks → `- **Type**: markdown`
   - General tasks → `- **Type**: general`
   - Python tasks → `- **Type**: python`
   - Shell scripts → `- **Type**: shell`
   - Meta work (agents, commands, context) → `- **Type**: meta`
2. Add Type field to task metadata in TODO.md
3. Ensure Type field is on its own line with correct formatting

**Prevention**:
- Use /task command to create tasks (enforces Type field)
- Avoid manual editing of TODO.md
- If manual editing required, follow task standards exactly

### Incorrect Metadata Format

**Problem**: Task uses `*Field**:` instead of `- **Field**:` format.

**Impact**:
- Breaks parsing by automation tools
- Violates task standards
- Makes tasks harder to read and maintain

**Solution**:
1. Find all metadata fields using incorrect format (e.g., `*Effort**:`, `*Status**:`)
2. Replace with correct format: `- **Effort**:`, `- **Status**:`
3. Ensure each field is on its own line
4. Verify formatting matches task standards

**Example Fix**:
```markdown
BEFORE (incorrect):
*Effort**: 2 hours
*Status**: [NOT STARTED]
*Language**: lean

AFTER (correct):
- **Effort**: 2 hours
- **Status**: [NOT STARTED]
- **Language**: lean
```

**Prevention**:
- Use /task command to create tasks (enforces correct format)
- Use /review command to create tasks (validates format)
- Avoid manual editing of TODO.md

### Validation Errors from /task Command

**Problem**: /task command rejects task creation with validation error.

**Common Errors**:

1. "Type field is required but could not be detected"
   - Solution: Add `--type lean` (or markdown/general/meta) flag to /task command
   - Example: `/task "Fix bug in Foo.lean" --type lean`

2. "Metadata format must use `- **Field**:` pattern"
   - Solution: This error should not occur with /task command (internal validation)
   - If it occurs: Report as bug in /task command implementation

3. "Required field missing: {field_name}"
   - Solution: This error should not occur with /task command (auto-populates defaults)
   - If it occurs: Report as bug in /task command implementation

**Prevention**:
- Always use /task command for task creation
- Provide --type flag if type detection might fail
- Review task standards before creating tasks

### Validation Errors from /review Command

**Problem**: /review command reports non-compliant tasks after creation.

**Common Violations**:

1. "Task {number} missing required Type field"
   - Solution: Manually add Type field to task in TODO.md
   - Follow format: `- **Type**: {lean|markdown|general|meta}`

2. "Task {number} has incorrect metadata format"
   - Solution: Fix metadata format to use `- **Field**:` pattern
   - Replace `*Field**:` with `- **Field**:`

3. "Task {number} missing required field: {field_name}"
   - Solution: Add missing field to task in TODO.md
   - Follow task standards for field format

**Prevention**:
- Ensure /task command validation is working correctly
- Report validation failures to system maintainers
- Manually verify created tasks comply with standards

## Maintenance

### Archival
-   Completed tasks should be archived when the project is finished.
-   Update `state.json` to move project from `active_projects` to `completed_projects` (and eventually `archive/state.json`).
