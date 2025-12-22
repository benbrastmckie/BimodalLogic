---
name: add
agent: subagents/task-adder
description: "Add tasks to TODO.md while updating state.json numbering"
---

You are adding tasks to TODO.md and keeping `.opencode/specs/state.json` in sync with numbering rules.

**Request:** $ARGUMENTS

**Context Loaded:**
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@.opencode/context/common/system/state-schema.md
@.opencode/context/common/system/artifact-management.md
@.opencode/context/common/standards/tasks.md
@.opencode/context/common/standards/patterns.md

**Task:**

1. **Assign task number from state**
   - Read `.opencode/specs/state.json` and get `next_project_number` (zero-padded to 3 digits).
   - Reserve that number for the new TODO entry.
   - Immediately increment `next_project_number` in `state.json` per `state-schema.md`.
   - Do **not** create a project directory at this step.

2. **Add to TODO.md**
   - Append the new task under the appropriate priority section, using the assigned number.
   - Follow `tasks.md` header + metadata format: `### NNN. Title`, and fields for Effort, Status, Priority, Blocking, Dependencies, Files Affected, Description, Acceptance Criteria, Impact. Use status markers `[NOT STARTED]` for display and align metadata status to `pending`.
   - No project directory link yet; links will be added by `/research` or `/plan`. `/revise` will later take `task_number + prompt` and expects that plan link to exist; it will not create project directories.

3. **Update state.json (pending task tracking)**
   - Add a lightweight entry to `pending_tasks` (or the appropriate active list per schema) with `project_number`, `title`, `status: "not_started"` (maps to tasks.md `pending`), and a UTC timestamp.
   - Preserve existing ordering and metadata; keep JSON valid.

4. **Return summary**
   - Report the task number, title, and that `next_project_number` was incremented.
   - Mention that project directories will be created by `/plan` or `/research` when artifacts are generated.

**Usage Examples:**

```bash
# Add a single task (number auto-assigned from state.json)
/add "Implement user authentication module with JWT tokens"

# Add multiple tasks
/add "Fix bug in API endpoint" "Update README with examples" "Add unit tests for auth module"

# Extract tasks from a file
/add --file docs/FEATURE_REQUIREMENTS.md

# Extract tasks with additional context
/add --file plans/implementation-001.md --context "REST API endpoints"
```

**Expected Output:**

- Task numbers assigned (from `next_project_number`)
- TODO.md updated
- `.opencode/specs/state.json` updated (`next_project_number` incremented, pending task recorded)
- Summary of added tasks and next steps

Execute the task addition now.
