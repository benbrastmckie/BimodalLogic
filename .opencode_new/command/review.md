---
name: review
agent: orchestrator
description: "Ambition/gap-analysis workflow: analyze coverage, propose tasks via /add, keep numbering intact, and avoid cleanup/archival"
---

You are conducting an ambition/gap analysis review. Own **task discovery** only; do **not** perform cleanup/archival (owned by /todo) and do **not** mutate `next_project_number` beyond what /add performs.

**Request:** $ARGUMENTS

**Context Loaded:**
@context/common/standards/
@context/common/system/state-schema.md
@context/common/system/status-markers.md
@context/common/standards/tasks.md
@context/common/system/artifact-management.md
@context/project/
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@Documentation/ProjectInfo/FEATURE_REGISTRY.md
@Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md

**Task:**

Execute the ambition/gap-analysis workflow:

1) Route to @subagents/reviewer with **gap-analysis** scope.
2) Reviewer will:
   - Run structured coverage checks (architecture phases, docs, command coverage, testing readiness) and capture findings.
   - Propose new tasks via `/add` (or todo-manager) so numbering stays centralized in `.opencode/specs/state.json`; include rationale and impacted files. Do not change `next_project_number` manually.
   - Update TODO.md with new tasks (status `[NOT STARTED]`, full metadata) and append `pending_tasks` in state.json; do not touch `active_projects`/`completed_projects`/archive.
   - Keep archive untouched and avoid cleanup actions; no project directories created unless `/add` creates one while writing an artifact.
   - Optionally create review reports under an existing or newly created review project (if explicitly requested) while respecting lazy directory creation (only create dirs when writing artifacts).
   - Update `FEATURE_REGISTRY.md` and `IMPLEMENTATION_STATUS.md` to log new ambitions and gaps discovered.
3) Present results: findings summary, new task list with IDs, and artifact references (if reports created).

**Expected Output:**
- Gap-analysis findings and recommendations
- New tasks registered via /add with IDs and links in TODO.md/state.json
- No cleanup/archival performed; archive/state untouched
- Optional review report references; numbering unchanged except through /add
- Status doc updates reflecting new ambitions

**Safety and Validation:**
- Respect lazy directory creation and numbering guardrails; never pre-create project roots/subdirs without writing artifacts.
- Validate TODO formatting, status markers, and JSON syntax after updates.
- Fail gracefully if /add cannot be invoked or if task numbering conflicts are detected.

Execute the ambition/gap-analysis review now.
