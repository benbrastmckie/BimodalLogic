---
name: research
agent: orchestrator
description: "Add research reports for TODO task number and sync artifacts"
---

You are conducting research for an existing TODO task by number.

**Task number + optional prompt:** $ARGUMENTS

**Context Loaded:**
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@.opencode/context/common/system/state-schema.md
@.opencode/context/common/system/artifact-management.md
@.opencode/context/common/standards/tasks.md
@.opencode/context/common/standards/patterns.md
@.opencode/context/common/workflows/task-breakdown.md

**Task:**

Execute the research workflow:

1. **Resolve task number**
   - Parse the task number and optional prompt.
   - Look up the task in `.opencode/specs/TODO.md`; fail clearly if not found.

2. **Lazy project directory creation**
   - Derive slug from TODO title (snake_case).
   - Create `.opencode/specs/NNN_slug/` **only when writing the first research artifact**; create `reports/` at that moment. Do **not** pre-create `plans/` or `summaries/`, and do not write `state.json` until an artifact is produced.

3. **Generate research artifact(s)**
   - Route to @subagents/researcher (and specialists as needed) with task context and optional prompt.
   - Write research report(s) to `reports/research-XXX.md` (start at 001, increment if files exist) following `artifact-management.md`.

4. **Update TODO.md**
   - Add a link to the new research artifact under the task entry and include a brief summary (1-2 sentences) of findings.
   - Preserve existing task metadata and numbering per `tasks.md`; keep status markers and metadata status aligned (e.g., `[IN PROGRESS]` ↔ `in-progress`).

5. **Update project state**
   - Append report paths to the project `reports` array, keep `status`/`phase` current, and update timestamps per `state-schema.md`.

6. **Return summary**
   - Provide paths to research artifacts and the TODO link/summary updates.

**Usage Examples:**

```bash
/research 105 "Survey FastAPI auth best practices"
/research 105
```

**Expected Output:**

- Research report path(s) (reports/research-XXX.md)
- TODO.md updated with link + brief summary
- Project state.json updated for research activity

Execute the research now.
