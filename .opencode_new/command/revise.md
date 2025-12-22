---
name: revise
agent: orchestrator
description: "Create revised implementation plan with incremented version number"
---

You are revising an implementation plan for a software development project.

**Task Number + Prompt:** $ARGUMENTS

**Context Loaded:**
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@context/common/standards/tasks.md
@context/common/system/artifact-management.md
@context/common/system/state-schema.md
@context/common/system/status-markers.md
@context/project/repo/project-overview.md

**Task:**

Execute the task-linked plan revision workflow (task number + prompt) in compliance with tasks, artifact-management, state-schema, and status-marker standards:

1. **Parse & validate arguments**
   - Require `task_number` + revision prompt; reject if missing.
   - Enforce task-number formatting and status markers per `tasks.md` / `status-markers.md`.

2. **Resolve task & plan (no new directories)**
   - Look up the task in `.opencode/specs/TODO.md`; fail gracefully if unknown.
   - Extract the plan link (or project link) from the TODO entry. If absent, stop with a clear message directing the user to run `/plan` first. Do **not** create project directories.
   - Validate the referenced plan file exists on disk; if missing, fail gracefully.

3. **Version and create revised plan**
   - Locate the project’s `plans/` folder and highest `implementation-NNN.md`.
   - Create `implementation-{N+1}.md` in the same folder with `[NOT STARTED]` status markers, the revision prompt, and a brief delta header.
   - Preserve project numbering; do **not** touch `next_project_number` or `active_projects`.

4. **Sync TODO and state (no renumbering)**
   - Update the TODO task to point to the new plan version; keep task numbering and status markers intact.
   - Refresh the project `state.json` (append plan path, phase `planning`, status `active`, timestamps per `state-schema.md`), only if the project state file exists.
   - Update `.opencode/specs/state.json` pending task entry for the task (e.g., `status: in_progress/completed` as appropriate) and `_last_updated`, without creating new project entries or directories.

5. **Update documentation**
   - Add/refresh usage notes in `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md` and `Documentation/ProjectInfo/FEATURE_REGISTRY.md` to reflect the harmonized `/revise` contract with `/add` and `/plan`.

6. **Return results**
   - Provide the new plan reference, delta summary, TODO/state/doc updates applied, and any guardrail messages triggered.

**Expected Output:**

- Revised plan reference (`plans/implementation-{N+1}.md`) in the same project directory
- TODO.md updated to the new plan link with unchanged task numbering/status markers
- Project state updated (if present) with appended plan and refreshed timestamps; global state pending task updated without new projects
- Documentation updated to reflect the `/revise` contract and guardrails
- Clear error messaging when task or plan links are missing (no directories created)

Execute the revision now.
