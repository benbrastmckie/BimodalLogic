---
name: plan
agent: orchestrator
description: "Create implementation plan for TODO task number and sync artifacts"
---

You are creating an implementation plan for an existing TODO task by number.

**Task from TODO (number + optional prompt):** $ARGUMENTS

**Context Loaded:**
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@.opencode/context/common/system/state-schema.md
@.opencode/context/common/system/artifact-management.md
@.opencode/context/common/standards/tasks.md
@.opencode/context/common/standards/patterns.md
@.opencode/context/common/workflows/task-breakdown.md

**Task:**

Execute the planning workflow:

1. **Resolve task number**
   - Parse the task number and optional prompt.
   - Look up the task in `.opencode/specs/TODO.md`; fail clearly if not found.

2. **Ensure project directory exists (lazy creation)**
   - Derive slug from TODO title (snake_case).
   - Create `.opencode/specs/NNN_slug/` immediately before writing the first plan artifact; write `state.json` alongside the artifact per `state-schema.md`.
   - Lazily create subdirectories only when writing artifacts: for the plan step, create `plans/` as needed; do **not** pre-create `reports/` or `summaries/` or add placeholder files.
   - **Contract boundary:** `/plan` is responsible for creating the project directory when absent. `/revise` will **not** create directories and requires an existing plan link in TODO.md; if none exists, instruct the user to run `/plan` first.

3. **Resolve research links (if any)**
   - From the TODO entry, collect any research links (Markdown links in the task body and explicit `Research:` lines).
   - Validate linked files exist; if any are missing, report dangling references but proceed.
   - Pass resolved research references to the planner; if none are linked, note this and continue without creating extra directories.

4. **Generate plan artifact (with research inputs)**
   - Route to @subagents/planner with the task context, resolved research references, and optional prompt.
   - Write plan to `plans/implementation-XXX.md` (start at 001, increment if files exist) following `artifact-management.md`.
   - Plan must include a clearly labeled "Research Inputs" section citing each linked research artifact (or explicitly stating none linked).

5. **Update TODO.md**
   - Add a link to the new plan under the task entry and include a brief summary (1-2 sentences) of the plan.
   - Preserve existing task metadata and numbering per `tasks.md`; keep status markers and metadata status in sync (e.g., `[IN PROGRESS]` ↔ `in-progress`).

6. **Update project state**
   - Append the plan path to the project `plans` array, set/refresh `phase` to `planning`, and update timestamps per `state-schema.md`.

7. **Return summary**
   - Provide the plan path, TODO link added, and any next steps.

**Usage Examples:**

```bash
/plan 105 "Focus on auth flows and RBAC"
/plan 105
```

**Expected Output:**

- Plan reference path (plans/implementation-XXX.md)
- Research inputs captured in the plan (linked citations or explicit "none linked")
- TODO.md updated with link + brief summary
- Project state.json updated for planning phase

Execute the planning now.
