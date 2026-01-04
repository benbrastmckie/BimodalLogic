---
last_updated: 2026-01-04T04:45:44Z
next_project_number: 280
repository_health:
  overall_score: 92
  production_readiness: excellent
  last_assessed: 2025-12-29T00:05:34Z
task_counts:
  active: 4
  completed: 50
  blocked: 2
  in_progress: 2
  not_started: 23
  total: 81
priority_distribution:
  high: 15
  medium: 12
  low: 11
technical_debt:
  sorry_count: 6
  axiom_count: 11
  build_errors: 11
  status: well-documented
---

# TODO

## High Priority

### 280. Fix orchestrator Stage 4 validation to enforce subagent return format and prevent phantom research
- **Effort**: 6-8 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None

**Description**:
When running `/research 279`, the researcher agent returned plain text instead of the required JSON format (per subagent-return-format.md), and the orchestrator's Stage 4 (ValidateReturn) did not catch this violation. This resulted in "phantom research" - the orchestrator claimed research was completed successfully, but no artifacts were created, no status was updated, and no directory was created. This is a critical validation failure affecting ALL workflow commands (/research, /plan, /implement, /revise).

**Current Behavior**:
```bash
/research 279
# Output: "Task 279 research has been completed successfully by the researcher agent"
# Reality: No artifacts created, status still [NOT STARTED], no directory created
# Problem: Orchestrator accepted plain text return instead of required JSON format
```

**Expected Behavior**:
```bash
/research 279
# Orchestrator Stage 4 validation should:
# 1. Validate return is valid JSON (not plain text)
# 2. Validate required fields present (status, summary, artifacts, metadata)
# 3. Validate artifacts array non-empty if status=completed
# 4. Validate all artifact files exist on disk
# 5. Validate all artifact files are non-empty (size > 0 bytes)
# 6. REJECT return and report validation failure if any check fails
```

**Root Cause**:
Orchestrator Stage 4 (ValidateReturn) references validation-rules.md but does NOT actually implement the validation logic. The validation is documented but not enforced.

**Impact**:
- Phantom research: Status updated but no artifacts created
- Phantom planning: Status updated but no plan created
- Phantom implementation: Status updated but no code written
- User confusion: Commands claim success but produce no output
- Data corruption: state.json and TODO.md out of sync with reality

**Fix Strategy**:
1. Implement validation logic in orchestrator Stage 4 (ValidateReturn)
2. Add validation for all subagent returns (researcher, planner, implementer, lean-research-agent, lean-implementation-agent, lean-planner)
3. Test validation with intentionally malformed returns
4. Update validation-rules.md with implementation details
5. Add error handling for validation failures

**Acceptance Criteria**:
- [ ] Orchestrator Stage 4 validates JSON structure
- [ ] Orchestrator Stage 4 validates required fields
- [ ] Orchestrator Stage 4 validates status enum
- [ ] Orchestrator Stage 4 validates session_id match
- [ ] Orchestrator Stage 4 validates artifacts exist if status=completed
- [ ] Orchestrator Stage 4 validates artifacts are non-empty
- [ ] Validation failures return clear error messages to user
- [ ] All workflow commands tested with validation enabled
- [ ] No phantom research/planning/implementation possible

---

### 278. Investigate and fix /implement command argument parsing failure
- **Effort**: 5 hours
- **Status**: [PLANNED]
- **Priority**: High
- **Language**: general
- **Blocking**: None
- **Dependencies**: None
- **Analysis**: [Analysis Report](278_investigate_fix_implement_argument_parsing/reports/analysis-001.md)
- **Plan**: [Implementation Plan](278_investigate_fix_implement_argument_parsing/plans/implementation-001.md)

**Description**:
When running `/implement 271`, the orchestrator returns an error message saying "However, I need you to provide the task number you want to implement" despite 271 being provided as an argument. This suggests the orchestrator is not properly parsing the `$ARGUMENTS` variable or the argument is not being passed correctly from the user invocation to the orchestrator.

**Current Behavior**:
```bash
/implement 271
# Returns: "However, I need you to provide the task number you want to implement.
#          Usage: /implement TASK_NUMBER [PROMPT]
#          Examples:
#          - /implement 196 - Implement task 196
#          - /implement 196 "Focus on error handling" - Implement with custom focus
#          - /implement 105-107 - Batch implement tasks 105-107"
```

**Expected Behavior**:
```bash
/implement 271
# Should parse 271 from $ARGUMENTS
# Should format as "Task: 271"
# Should delegate to implementer subagent with prompt="Task: 271"
```

**Root Cause Investigation Needed**:
1. Is `$ARGUMENTS` being populated correctly by OpenCode?
2. Is the orchestrator's Stage 1 (PreflightValidation) parsing logic working?
3. Is there a mismatch between how arguments are passed and how they're expected?
4. Are there similar issues with other commands (/research, /plan, /revise)?

**Files to Investigate**:
- `.opencode/agent/orchestrator.md` - Stage 1 argument parsing logic
- `.opencode/command/implement.md` - Command frontmatter and argument handling
- `.opencode/context/core/standards/command-argument-handling.md` - Argument handling standard
- `.opencode/context/core/system/routing-logic.md` - Routing and delegation logic

**Acceptance Criteria**:
- [ ] `/implement 271` successfully parses 271 as task number
- [ ] Orchestrator Stage 1 correctly extracts task number from $ARGUMENTS
- [ ] Orchestrator Stage 3 correctly formats prompt as "Task: 271"
- [ ] Similar commands (/research, /plan, /revise) tested and working
- [ ] Root cause documented and fixed
- [ ] No regression in other command argument handling

**Impact**: Critical bug preventing all task-based workflow commands from functioning. Blocks implementation of tasks 271, 275, 276, and all other planned work.

---

### 277. Improve OpenCode header display for task commands
- **Effort**: 3.5 hours
- **Status**: [PLANNED]
- **Priority**: High
- **Language**: general
- **Started**: 2026-01-03
- **Research**: [Research Report](277_improve_opencode_header_and_summary_display_for_task_commands/reports/research-001.md)
- **Plan**: [Implementation Plan v2](277_improve_opencode_header_and_summary_display_for_task_commands/plans/implementation-002.md)
- **Blocking**: None
- **Dependencies**: None

**Description**:
Improve the OpenCode system to always display the task number in the header when running task-based commands (`/task`, `/research`, `/plan`, `/revise`, `/implement`) and display the command name when running direct commands (`/todo`, `/errors`, `/review`, `/meta`). Ensure all summaries returned to the user are brief.

**Current Behavior**:
- Headers may not consistently show task numbers for task-based commands
- Command names may not be displayed for direct commands
- Summaries may be verbose

**Expected Behavior**:
- Task-based commands (`/task`, `/research`, `/plan`, `/revise`, `/implement`): Header displays "Task: {number}"
- Direct commands (`/todo`, `/errors`, `/review`, `/meta`): Header displays "Command: /{command}"
- All summaries are brief and concise

**Files to Modify**:
- `.opencode/agent/orchestrator.md` - Add header display logic in Stage 5
- `.opencode/context/core/standards/command-output.md` (create) - Document header standards

**Acceptance Criteria**:
- [ ] Task-based commands display "Task: {number}" in header
- [ ] Direct commands display "Command: /{command}" in header
- [ ] All summaries are brief (target: <100 tokens)
- [ ] Header standards documented in command-output.md
- [ ] All commands tested and verified

**Impact**: Improves user experience by providing clear context about which task or command is running, and makes summaries more concise.

---

### 275. Fix workflow commands to update status at beginning and end in both TODO.md and state.json
- **Effort**: 8 hours
- **Status**: [PLANNED]
- **Priority**: High
- **Language**: markdown
- **Started**: 2026-01-03
- **Research**: [Research Report](275_fix_workflow_status_updates/reports/research-001.md)
- **Plan**: [Implementation Plan](275_fix_workflow_status_updates/plans/implementation-001.md)
- **Blocking**: None
- **Dependencies**: None

**Description**:
The `/implement` command correctly updates task status to `[COMPLETED]` at the end, but does NOT update status to `[IMPLEMENTING]` at the beginning. This inconsistency should be fixed across all workflow commands (`/research`, `/plan`, `/revise`, `/implement`) to ensure status is updated at both the beginning and end of command execution in both TODO.md and state.json files.

**Current Behavior**:
```bash
/implement 274
# Beginning: Status remains [NOT STARTED] or [PLANNED]
# End: Status updated to [COMPLETED]
# Problem: No status update at beginning
```

**Expected Behavior**:
```bash
/implement 274
# Beginning: Status updated to [IMPLEMENTING]
# End: Status updated to [COMPLETED]

/research 275
# Beginning: Status updated to [RESEARCHING]
# End: Status updated to [RESEARCHED]

/plan 275
# Beginning: Status updated to [PLANNING]
# End: Status updated to [PLANNED]

/revise 275
# Beginning: Status updated to [REVISING]
# End: Status updated to [REVISED]
```

**Status Transitions** (per state-management.md):
- `/research`: `[NOT STARTED]` → `[RESEARCHING]` → `[RESEARCHED]`
- `/plan`: `[RESEARCHED]` → `[PLANNING]` → `[PLANNED]`
- `/revise`: `[PLANNED]` → `[REVISING]` → `[REVISED]`
- `/implement`: `[PLANNED]` → `[IMPLEMENTING]` → `[COMPLETED]`

**Root Cause**:
Commands and subagents update status only at the end via status-sync-manager, not at the beginning. The beginning status update is missing from the workflow.

**Solution**:
1. Update each command to invoke status-sync-manager at the beginning:
   - `/research` → Update to `[RESEARCHING]` before delegating to researcher
   - `/plan` → Update to `[PLANNING]` before delegating to planner
   - `/revise` → Update to `[REVISING]` before delegating to reviser
   - `/implement` → Update to `[IMPLEMENTING]` before delegating to implementer
2. Update each subagent to invoke status-sync-manager at the end:
   - researcher → Update to `[RESEARCHED]` after creating research artifacts
   - planner → Update to `[PLANNED]` after creating plan artifacts
   - reviser → Update to `[REVISED]` after revising plan artifacts
   - implementer → Update to `[COMPLETED]` after implementation (already working)
3. Update context files to document the two-phase status update pattern:
   - `.opencode/context/core/workflows/command-lifecycle.md` - Document beginning and end status updates
   - `.opencode/context/core/system/state-management.md` - Update status transition documentation

**Files to Modify**:
- `.opencode/command/research.md` - Add beginning status update to `[RESEARCHING]`
- `.opencode/command/plan.md` - Add beginning status update to `[PLANNING]`
- `.opencode/command/revise.md` - Add beginning status update to `[REVISING]`
- `.opencode/command/implement.md` - Add beginning status update to `[IMPLEMENTING]`
- `.opencode/agent/subagents/researcher.md` - Ensure end status update to `[RESEARCHED]`
- `.opencode/agent/subagents/planner.md` - Ensure end status update to `[PLANNED]`
- `.opencode/agent/subagents/reviser.md` - Ensure end status update to `[REVISED]`
- `.opencode/agent/subagents/implementer.md` - Verify end status update to `[COMPLETED]` (already working)
- `.opencode/context/core/workflows/command-lifecycle.md` - Document two-phase status updates
- `.opencode/context/core/system/state-management.md` - Update status transition documentation

**Acceptance Criteria**:
- [ ] `/research` updates status to `[RESEARCHING]` at beginning, `[RESEARCHED]` at end
- [ ] `/plan` updates status to `[PLANNING]` at beginning, `[PLANNED]` at end
- [ ] `/revise` updates status to `[REVISING]` at beginning, `[REVISED]` at end
- [ ] `/implement` updates status to `[IMPLEMENTING]` at beginning, `[COMPLETED]` at end
- [ ] All status updates occur in both TODO.md and state.json via status-sync-manager
- [ ] Status transitions follow state-management.md standard
- [ ] Context files document two-phase status update pattern
- [ ] All workflow commands tested and verified

**Impact**: Ensures consistent status tracking across all workflow commands, providing accurate visibility into task progress at both the beginning and end of command execution.

---

### 274. Remove status metadata from research reports (belongs in TODO.md and state.json only)
- **Effort**: 2-3 hours
- **Status**: [COMPLETED]
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Completed**: 2026-01-03
- **Artifacts**: .opencode/specs/274_remove_status_metadata_from_research_reports/summaries/implementation-summary-20260103.md

**Description**:
Research reports created by `/research` command incorrectly include status metadata (e.g., `**Status**: [RESEARCHING]`) in the report file itself. Status should only be tracked in TODO.md and state.json, not in artifact files. This creates redundancy and potential inconsistency.

**Current Behavior**:
```bash
/research 271
# Creates: .opencode/specs/271_*/reports/research-001.md
# Report contains: **Status**: [RESEARCHING]
# Problem: Status metadata duplicated in artifact file
```

**Expected Behavior**:
```bash
/research 271
# Creates: .opencode/specs/271_*/reports/research-001.md
# Report contains: NO status metadata
# Status tracked in: TODO.md and state.json only
```

**Example Issue**:
File: `.opencode/specs/271_revise_meta_command_task_creation/reports/research-001.md`
Contains: `**Status**: [RESEARCHING]`
Should contain: Research findings only, no status metadata

**Root Cause**:
- Researcher subagent includes status in research report template
- Research report template should not include status metadata
- Status belongs in TODO.md and state.json, not in artifact files

**Solution**:
1. Update researcher subagent to remove status from research report template
2. Update research report standard/template to exclude status metadata
3. Research reports should contain:
   - Research findings
   - Analysis and recommendations
   - References and citations
   - NO status metadata (tracked separately in TODO.md/state.json)

**Files to Modify**:
- `.opencode/agent/subagents/researcher.md` - Remove status from report template
- `.opencode/context/core/standards/report.md` (if exists) - Update research report standard

**Acceptance Criteria**:
- [ ] Research reports do NOT include status metadata
- [ ] Status tracked only in TODO.md and state.json
- [ ] Researcher subagent updated to exclude status from reports
- [ ] Research report standard/template updated (if exists)
- [ ] No redundant metadata in artifact files

**Impact**: Eliminates redundant status metadata in research reports, ensuring single source of truth in TODO.md and state.json.

---

### 273. Fix /research command to link research artifacts in TODO.md task entries
- **Effort**: 4-6 hours
- **Status**: [COMPLETED]
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None

**Description**:
The `/research` command creates research reports but does not update TODO.md task entries to link to those reports. This violates the artifact linking standard and makes it difficult for users to find research artifacts. The fix should be minimal, avoiding needless complexity or context bloat.

**Current Behavior**:
```bash
/research 271
# Creates: .opencode/specs/271_*/reports/research-001.md
# Updates: Task 271 status to [RESEARCHED]
# Missing: Link to research report in TODO.md task entry
```

**Expected Behavior**:
```bash
/research 271
# Creates: .opencode/specs/271_*/reports/research-001.md
# Updates: Task 271 status to [RESEARCHED]
# Adds: Research link in TODO.md task entry
```

**Standard Format** (to be specified in context file):
```markdown
### 271. Task title
- **Effort**: 8-12 hours
- **Status**: [RESEARCHED]
- **Priority**: High
- **Language**: markdown
- **Research**: [Research Report](271_task_name/reports/research-001.md)
- **Blocking**: None
- **Dependencies**: None
```

**Root Cause**:
- `/research` command delegates to researcher subagent
- Researcher updates status via status-sync-manager
- Status-sync-manager updates status field but does NOT add artifact links
- No context file specifies the standard format for artifact links in TODO.md

**Solution** (minimal, avoiding complexity):
1. Create/update context file specifying TODO.md artifact link format:
   - Location: `.opencode/context/core/standards/todo-format.md` (or similar)
   - Content: Standard format for Research, Plan, Implementation links
   - Keep it simple: just the link format, no complex logic

2. Update researcher subagent to add research link when updating status:
   - After creating research report
   - Before delegating to status-sync-manager
   - Add `- **Research**: [Research Report](path/to/report.md)` line

3. Update status-sync-manager to preserve artifact links:
   - When updating TODO.md task entry
   - Preserve existing Research/Plan/Implementation links
   - Only update Status, Completed, and other metadata fields

**Files to Modify**:
- `.opencode/context/core/standards/todo-format.md` (create) - Specify artifact link format
- `.opencode/agent/subagents/researcher.md` - Add research link when updating TODO.md
- `.opencode/agent/subagents/status-sync-manager.md` - Preserve artifact links during updates

**Acceptance Criteria**:
- [ ] Context file specifies standard TODO.md artifact link format
- [ ] `/research NNN` adds Research link to TODO.md task entry
- [ ] Research link format: `- **Research**: [Research Report](path/to/report.md)`
- [ ] status-sync-manager preserves existing artifact links
- [ ] Solution is minimal and avoids needless complexity
- [ ] No context bloat - single focused context file for format

**Impact**: Makes research artifacts discoverable in TODO.md, following artifact linking standards without adding complexity.

---

### 276. ✓ Investigate and remove redundant project-level state.json files in favor of centralized specs/state.json
- **Effort**: 8 hours
- **Status**: [COMPLETED]
- **Started**: 2026-01-03
- **Completed**: 2026-01-03
- **Research**: [Research Report](276_investigate_remove_redundant_project_level_state_json/reports/research-001.md)
- **Plan**: [Implementation Plan](276_investigate_remove_redundant_project_level_state_json/plans/implementation-001.md)
- **Implementation**: [Implementation Summary](276_investigate_remove_redundant_project_level_state_json/summaries/implementation-summary-20260103.md)
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None

**Description**:
When `/research`, `/plan`, `/revise`, and `/implement` commands run on a task number, they lazily create a project directory (e.g., `.opencode/specs/258_resolve_truth_lean_sorries/`) and create a project-level `state.json` file within that directory. This project-level state.json appears to duplicate information already tracked in the centralized `.opencode/specs/state.json` file's `active_projects` array. This task investigates whether the project-level state.json files serve a unique purpose or can be removed to simplify the system and improve performance.

**Current Behavior**:
- Central state file: `.opencode/specs/state.json` contains `active_projects` array with metadata for all projects
- Project-level state files: `.opencode/specs/{number}_{slug}/state.json` created lazily for each project
- Both files contain similar metadata: project_number, project_name, type, phase, status, artifacts, timestamps
- status-sync-manager writes to both files atomically
- No evidence found of project-level state.json being read by any command or agent

**Investigation Goals**:
1. Determine if project-level state.json is ever read (not just written) by any command or agent
2. Identify any unique information in project-level state.json not available in specs/state.json
3. Assess performance impact of maintaining duplicate state files
4. Evaluate simplification benefits of using only specs/state.json

**Potential Outcomes**:
- **If redundant**: Remove project-level state.json creation from status-sync-manager, update all agents to use only specs/state.json, document migration path
- **If necessary**: Document the specific purpose and usage patterns, clarify when each state file should be used

**Success Criteria**:
- [ ] Comprehensive search for all reads of project-level state.json files
- [ ] Analysis of metadata differences between project-level and central state.json
- [ ] Performance comparison (file I/O, atomic writes, lookup speed)
- [ ] Decision documented with clear rationale
- [ ] If removing: migration plan created with backward compatibility strategy
- [ ] If keeping: usage patterns documented in architecture guide

**Impact**: Simplifies state management by eliminating redundant project-level state.json files if they serve no unique purpose, reducing file I/O overhead and improving system performance. If project-level state.json is necessary, clarifies its purpose and usage patterns.

---

### 272. ✓ Add standardized YAML header to TODO.md with state.json metadata
- **Effort**: 14 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: markdown
- **Started**: 2026-01-03
- **Completed**: 2026-01-04
- **Research**: [Research Report](272_add_yaml_header_to_todo_md/reports/research-001.md)
- **Plan**: [Implementation Plan](272_add_yaml_header_to_todo_md/plans/implementation-001.md)
- **Implementation**: [Implementation Summary](272_add_yaml_header_to_todo_md/summaries/implementation-summary-20260104.md)
- **Blocking**: None
- **Dependencies**: None

**Description**:
Add a standardized YAML header to `.opencode/specs/TODO.md` that makes relevant information from `specs/state.json` accessible to users in a readable format. All commands that update TODO.md and state.json should keep this metadata synchronized by modifying the appropriate subagents to perform this work systematically. Context files should be revised to specify the required TODO.md format.

**Current State**:
- TODO.md has a simple text header with "Last Updated" timestamp
- state.json contains rich metadata (next_project_number, repository_health, active_projects, etc.)
- No standardized way to surface state.json metadata in TODO.md
- Commands update TODO.md and state.json independently without header synchronization

**Proposed YAML Header** (example):
```yaml
---
last_updated: 2026-01-03T19:50:47Z
next_project_number: 272
repository_health:
  overall_score: 92
  production_readiness: excellent
  active_tasks: 4
  completed_tasks: 50
  high_priority_tasks: 15
  medium_priority_tasks: 12
  low_priority_tasks: 11
technical_debt:
  sorry_count: 6
  axiom_count: 11
  build_errors: 11
  status: well-documented
---
```

**Tasks**:
1. Design YAML header schema for TODO.md based on state.json metadata
2. Identify which state.json fields should be surfaced in TODO.md header
3. Update TODO.md to include YAML header with current state.json metadata
4. Modify subagents to update TODO.md YAML header when updating state.json:
   - status-sync-manager.md (atomic TODO.md + state.json updates)
   - researcher.md (updates state.json on research completion)
   - planner.md (updates state.json on plan creation)
   - implementer.md (updates state.json on implementation)
   - task-executor.md (updates state.json during multi-phase execution)
5. Update context files to specify TODO.md YAML header format:
   - .opencode/context/core/standards/tasks.md (task format standard)
   - .opencode/context/core/system/state-management.md (state synchronization)
   - .opencode/context/core/system/artifact-management.md (TODO.md structure)
6. Update /todo command to regenerate YAML header from state.json
7. Test header synchronization across all workflow commands

**Files to Modify**:
- .opencode/specs/TODO.md (add YAML header)
- .opencode/agent/subagents/status-sync-manager.md (header sync logic)
- .opencode/agent/subagents/researcher.md (update header on research)
- .opencode/agent/subagents/planner.md (update header on planning)
- .opencode/agent/subagents/implementer.md (update header on implementation)
- .opencode/agent/subagents/task-executor.md (update header during execution)
- .opencode/command/todo.md (header regeneration logic)
- .opencode/context/core/standards/tasks.md (document header format)
- .opencode/context/core/system/state-management.md (document sync requirements)
- .opencode/context/core/system/artifact-management.md (document TODO.md structure)

**Acceptance Criteria**:
- [ ] YAML header schema designed and documented
- [ ] TODO.md includes YAML header with state.json metadata
- [ ] All subagents update TODO.md header when updating state.json
- [ ] Context files specify TODO.md YAML header format
- [ ] /todo command regenerates header from state.json
- [ ] Header synchronization tested across all workflow commands
- [ ] No duplicate metadata between header and state.json
- [ ] Header remains human-readable and accessible

**Impact**: Makes state.json metadata accessible to users directly in TODO.md, improving visibility into project health, task counts, and technical debt without requiring manual state.json inspection. Ensures metadata consistency across TODO.md and state.json through systematic synchronization.

---

### 271. Revise /meta command to create tasks with linked artifacts instead of implementing directly
- **Effort**: 10 hours
- **Status**: [PLANNED]
- **Completed**: 2026-01-03
- **Priority**: High
- **Language**: markdown
- **Research**: [Research Report](271_revise_meta_command_task_creation/reports/research-001.md)
- **Plan**: [Implementation Plan v2](271_revise_meta_command_task_creation/plans/implementation-002.md)
- **Blocking**: None
- **Dependencies**: None

**Description**:
The `/meta` command currently implements work directly after the interview. Instead, it should conclude by creating an appropriate number of tasks in `.opencode/specs/TODO.md` following task standards, with each task linking to a detailed plan artifact (plan only - no research or summary artifacts). Additionally, this task migrates the system from 'Language' field to 'Type' field and updates /implement routing to handle meta tasks properly.

**Current Behavior**:
- `/meta` conducts interview (Stages 0-6)
- Stage 7 (GenerateSystem): Delegates to meta subagents to create agents, commands, context files
- Stage 8 (DeliverSystem): Presents completed system, creates git commit

**Expected Behavior**:
- `/meta` conducts interview (Stages 0-6)
- Stage 7 (CreateTasksWithArtifacts): 
  - Use `next_project_number` from state.json for task numbering
  - Create project directories in `.opencode/specs/NNN_*/` for each task
  - Generate ONLY plan artifacts for each task (self-documenting)
  - Create task entries in TODO.md linking to plan artifacts
  - Set Type field to 'meta' for meta-related tasks
  - Increment `next_project_number` for each task created
- Stage 8 (DeliverTaskSummary): Present task list with artifact links, instruct user to review and run `/implement NNN` for each task

**Tasks to Create** (examples based on interview):
1. Planning task: Design agent architecture and workflow patterns
2. Implementation tasks (one per agent/command/context group):
   - Create domain-specific agents
   - Create custom commands
   - Create context files

**Artifact Structure** (per task):
```
.opencode/specs/NNN_task_name/
└── plans/
    └── implementation-001.md    # Detailed implementation plan (self-documenting)
```

**Files to Modify**:
- `.opencode/agent/subagents/meta.md` - Revise Stage 7 and Stage 8
- `.opencode/command/meta.md` - Update workflow description
- `.opencode/command/implement.md` - Add meta task routing
- `.opencode/context/core/standards/tasks.md` - Language → Type migration
- `.opencode/context/core/standards/plan.md` - Language → Type migration
- `.opencode/context/core/standards/report.md` - Language → Type migration
- `.opencode/context/core/system/state-management.md` - Language → Type migration

**Acceptance Criteria**:
- [ ] `/meta` creates tasks in TODO.md using next_project_number from state.json
- [ ] Each task has a project directory in `.opencode/specs/NNN_*/`
- [ ] Each task links to plan artifact ONLY (no research or summary artifacts)
- [ ] Plan artifacts follow plan.md standard with phases and estimates
- [ ] Task entries use 'Type' field instead of 'Language' field
- [ ] Meta tasks set Type to 'meta'
- [ ] Task breakdown follows task-breakdown.md workflow
- [ ] state.json next_project_number incremented for each task
- [ ] Language→Type migration completed across all system files
- [ ] /implement command routes meta tasks to meta subagents
- [ ] NO implementation performed - only tasks and plan artifacts created
- [ ] User can review plan artifacts and run `/implement NNN` for each task

**Impact**: Enables user review of /meta output before implementation, simplifies artifact generation (plan only), and improves semantic clarity with Type field migration.

---

### 269. Fix /meta command to accept user prompts directly instead of forcing interactive interview
- **Effort**: 2-3 hours
- **Status**: [RESEARCHING]
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None

**Description**:
The `/meta` command currently ignores user-provided prompts and always starts an interactive interview. This differs from the OpenAgents implementation where `/meta` accepts `$ARGUMENTS` directly via `<target_domain> $ARGUMENTS </target_domain>` pattern, allowing users to provide requirements upfront.

**Current Behavior**:
```bash
/meta "I want to revise my opencode system..."
# Ignores the prompt, shows generic interview message
```

**Expected Behavior** (from OpenAgents):
```bash
/meta "I want to revise my opencode system..."
# Uses the prompt as target_domain, proceeds with requirements
```

**Root Cause**:
- ProofChecker `/meta` command (`.opencode/command/meta.md`) does NOT pass `$ARGUMENTS` to the meta agent
- OpenAgents `/meta` command passes `$ARGUMENTS` via `<target_domain> $ARGUMENTS </target_domain>` in the agent file
- ProofChecker meta agent (`.opencode/agent/subagents/meta.md`) expects interactive interview, not prompt-based input

**Solution**:
1. Update `.opencode/command/meta.md` to pass `$ARGUMENTS` to meta agent (similar to OpenAgents pattern)
2. Update `.opencode/agent/subagents/meta.md` to:
   - Check if `$ARGUMENTS` is provided (non-empty)
   - If provided: Use as target_domain, skip Stage 1 (InitiateInterview), proceed directly to Stage 2 with domain context
   - If empty: Fall back to current interactive interview workflow
3. Add `<target_domain>` XML tag to meta agent to receive `$ARGUMENTS`
4. Update Stage 1 logic to be conditional based on `$ARGUMENTS` presence

**Files to Modify**:
- `.opencode/command/meta.md` - Add `$ARGUMENTS` passing
- `.opencode/agent/subagents/meta.md` - Add conditional workflow based on `$ARGUMENTS`

**Acceptance Criteria**:
- [ ] `/meta "prompt text"` uses the prompt directly without interactive interview
- [ ] `/meta` (no arguments) falls back to interactive interview
- [ ] Both modes create appropriate tasks in TODO.md with linked artifacts
- [ ] Both modes follow task-breakdown.md and artifact-management.md standards
- [ ] Both modes use next_project_number from state.json for task numbering
- [ ] Both modes create project directories in `.opencode/specs/NNN_*/`

**Impact**: Enables faster /meta usage for users who know their requirements, while preserving interactive mode for exploratory use.

---


### 267. Integrate context/meta/ into context/core/ with proper subdirectory organization
- **Effort**: 4-6 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-01-03
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None

**Description**:
Integrate `.opencode/context/meta/` into `.opencode/context/core/` by distributing the 4 meta context files to appropriate subdirectories in `core/` to maintain organization. Update all references throughout the `.opencode/` system to prevent feature regressions.

**Current State**:
- `.opencode/context/meta/` contains 4 files:
  - `interview-patterns.md` (5171 bytes)
  - `architecture-principles.md` (6641 bytes)
  - `domain-patterns.md` (5781 bytes)
  - `agent-templates.md` (7254 bytes)

**Target Organization**:
All context files should belong to either:
- `context/core/` - General context files applicable across projects
- `context/project/` - Repository-specific context files

**Tasks**:
1. Analyze each meta context file to determine appropriate core/ subdirectory:
   - `interview-patterns.md` → likely `core/processes/` or `core/workflows/`
   - `architecture-principles.md` → likely `core/standards/` or `core/patterns/`
   - `domain-patterns.md` → likely `core/patterns/` or `core/templates/`
   - `agent-templates.md` → likely `core/templates/` or `core/standards/`
2. Move files to appropriate core/ subdirectories
3. Update all references in:
   - `.opencode/command/meta.md` (frontmatter context_loading)
   - `.opencode/agent/subagents/meta/*.md` (5 agents)
   - `.opencode/context/index.md` (meta/ section)
   - `.opencode/README.md` (Meta Command Guide)
   - Any other files referencing context/meta/
4. Remove empty `.opencode/context/meta/` directory
5. Validate no broken references (grep validation)
6. Test /meta command still works correctly

**Acceptance Criteria**:
- [x] All 4 meta context files moved to appropriate core/ subdirectories
- [x] No `.opencode/context/meta/` directory exists
- [x] All references updated (command files, agent files, context index, README)
- [x] No broken references (validated with grep)
- [x] /meta command still functions correctly
- [x] Context organization follows core/ vs project/ convention

**Implementation Summary**:
- Moved `interview-patterns.md` → `core/workflows/interview-patterns.md`
- Moved `architecture-principles.md` → `core/standards/architecture-principles.md`
- Moved `domain-patterns.md` → `core/standards/domain-patterns.md`
- Moved `agent-templates.md` → `core/templates/agent-templates.md`
- Updated references in: `.opencode/command/meta.md`, `.opencode/agent/subagents/meta.md`, `.opencode/context/index.md`, `.opencode/README.md`
- Updated cross-references in all 4 moved files
- Removed empty `.opencode/context/meta/` directory
- Git commit: 33d4d45

---



### 257. Completeness Proofs
- **Effort**: 70-90 hours
- **Status**: [RESEARCHED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: Decidability
- **Dependencies**: Soundness (Complete), Deduction Theorem (Complete)

**Description**: Implement the completeness proof for TM logic using the canonical model method. The infrastructure (types and axiom statements) is present in `Logos/Core/Metalogic/Completeness.lean`.

**Action Items**:
1. Implement `lindenbaum` lemma (extend consistent sets to maximal consistent sets using Zorn's lemma).
2. Prove properties of maximal consistent sets (deductive closure, negation completeness).
3. Construct `canonical_frame` and prove frame properties (nullity, compositionality).
4. Prove `truth_lemma` (correspondence between membership and truth).
5. Prove `weak_completeness` and `strong_completeness`.

**Files**:
- `Logos/Core/Metalogic/Completeness.lean`

**Acceptance Criteria**:
- [ ] Lindenbaum lemma implemented
- [ ] Maximal consistent set properties proven
- [ ] Canonical frame constructed with frame properties
- [ ] Truth lemma proven
- [ ] Weak and strong completeness proven

**Impact**: Completes the metalogic foundation for TM logic by proving completeness, enabling derivability from validity.

---

### 258. Resolve Truth.lean Sorries
- **Effort**: 10-20 hours
- **Status**: [RESEARCHED]
- **Started**: 2026-01-03
- **Completed**: 2026-01-03
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None
- **Research Artifacts**:
  - Main Report: .opencode/specs/258_resolve_truth_lean_sorries/reports/research-001.md
  - Summary: .opencode/specs/258_resolve_truth_lean_sorries/summaries/research-summary.md

**Description**: Resolve the 3 remaining `sorry` placeholders in `Logos/Core/Semantics/Truth.lean` related to temporal swap validity. These require handling domain extension for history quantification.

**Research Findings**: The 3 sorries mentioned in the task description (lines 697, 776, 798) were already resolved in Task 213 (commit 1cf688b, 2025-12-28). Current Truth.lean has 580 lines with zero sorries. The unprovable `is_valid_swap_involution` theorem and `truth_swap_of_valid_at_triple` function were removed after semantic analysis proved them false. Task 258 is ALREADY RESOLVED.

**Action Items**:
1. ~~Resolve `truth_swap_of_valid_at_triple` (implication case)~~ - Already resolved in Task 213
2. ~~Resolve `truth_swap_of_valid_at_triple` (past case - domain extension)~~ - Already resolved in Task 213
3. ~~Resolve `truth_swap_of_valid_at_triple` (future case - domain extension)~~ - Already resolved in Task 213

**Files**:
- `Logos/Core/Semantics/Truth.lean` (current: 580 lines, 0 sorries)

**Acceptance Criteria**:
- [x] Implication case resolved (removed in Task 213)
- [x] Past case with domain extension resolved (removed in Task 213)
- [x] Future case with domain extension resolved (removed in Task 213)
- [x] All tests pass (Truth.lean builds successfully)
- [x] SORRY_REGISTRY.md updated (shows 0 sorries in Truth.lean)

**Impact**: Task objectives already achieved through Task 213. Truth.lean is clean, well-documented, and builds successfully.

**Recommendation**: Mark task as ALREADY RESOLVED or OBSOLETE. See Task 213 for resolution details.

---

### 259. Automation Tactics
- **Effort**: 40-60 hours
- **Status**: [RESEARCHED]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None

**Description**: Implement the remaining planned tactics for TM logic to support easier proof construction. Currently 4/12 tactics are implemented.

**Action Items**:
1. Implement `modal_k_tactic`, `temporal_k_tactic`.
2. Implement `modal_4_tactic`, `modal_b_tactic`.
3. Implement `temp_4_tactic`, `temp_a_tactic`.
4. Implement `modal_search`, `temporal_search`.
5. Fix Aesop integration (blocked by Batteries dependency).

**Files**:
- `Logos/Core/Automation/Tactics.lean`

**Acceptance Criteria**:
- [ ] All 8 remaining tactics implemented
- [ ] Aesop integration fixed
- [ ] Tests added for new tactics
- [ ] TACTIC_REGISTRY.md updated
- [ ] Documentation updated

**Impact**: Significantly improves proof automation capabilities for TM logic, making proof construction easier and more efficient.

---

### 260. Proof Search
- **Effort**: 40-60 hours
- **Status**: [RESEARCHED]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None

**Description**: Implement automated proof search for TM logic.

**Action Items**:
1. Implement breadth-first proof search.
2. Implement heuristic-guided search.

**Files**:
- `Logos/Core/Automation/ProofSearch.lean`

**Acceptance Criteria**:
- [ ] Breadth-first proof search implemented
- [ ] Heuristic-guided search implemented
- [ ] Tests added for proof search
- [ ] Performance benchmarks created
- [ ] Documentation updated

**Impact**: Enables automated proof discovery for TM logic, reducing manual proof construction effort.

---

### 261. Decidability
- **Effort**: 40-60 hours
- **Status**: [RESEARCHED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None

**Description**: Implement decision procedures for TM logic.

**Action Items**:
1. Implement tableau method.
2. Implement satisfiability decision procedure.

**Files**:
- `Logos/Core/Metalogic/Decidability.lean` (to be created)

**Acceptance Criteria**:
- [ ] Tableau method implemented
- [ ] Satisfiability decision procedure implemented
- [ ] Tests added for decision procedures
- [ ] Documentation updated

**Impact**: Provides algorithmic decision procedures for TM logic validity and satisfiability.

---

### 262. ModalS5 Limitation
- **Effort**: 2 hours
- **Status**: [RESEARCHED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None

**Description**: The theorem `diamond_mono_imp` in `ModalS5.lean` is marked with `sorry` because it is not valid as an object-level implication. This is a documented limitation.

**Action Items**:
1. Maintain documentation or find alternative formulation if possible.

**Files**:
- `Logos/Core/Theorems/ModalS5.lean`

**Acceptance Criteria**:
- [ ] Documentation maintained or alternative formulation found
- [ ] SORRY_REGISTRY.md updated with justification

**Impact**: Resolves documented limitation in ModalS5 theorems.

---

### 270. Fix /research command to conduct research instead of implementing tasks
- **Effort**: 6-8 hours
- **Status**: [COMPLETED]
- **Started**: 2026-01-03
- **Completed**: 2026-01-03
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None

**Description**:
The `/research` command is incorrectly executing full task implementation instead of conducting research and creating research artifacts. When `/research 267` was run, it violated the status transition rules defined in `.opencode/context/core/system/state-management.md` by changing the task status to [COMPLETED] instead of [RESEARCHED], and implemented the task directly instead of creating research artifacts.

**Expected Behavior** (per state-management.md):
1. Status transition: `[NOT STARTED]` → `[RESEARCHING]` → `[RESEARCHED]`
2. Create research artifacts in `.opencode/specs/267_*/reports/research-001.md`
3. Link research artifacts in TODO.md and state.json using status-sync-manager
4. Follow artifact-management.md standards (lazy directory creation)
5. Create git commit for research artifacts only

**Actual Behavior** (INCORRECT):
1. Status transition: `[NOT STARTED]` → `[COMPLETED]` (invalid transition)
2. Implemented task directly (moved files, updated references)
3. No research artifacts created
4. Violated command-specific status marker rules

**Root Cause**:
The researcher subagent (`.opencode/agent/subagents/researcher.md`) is executing implementation workflows instead of research-only workflows. It needs to be constrained to:
- Research execution only (web search, documentation review, analysis)
- Research report creation (NOT implementation)
- Status updates via status-sync-manager: `[RESEARCHING]` → `[RESEARCHED]`
- Artifact validation per artifact-management.md

**Action Items**:
1. Audit researcher.md workflow to identify implementation logic
2. Remove implementation execution from researcher.md
3. Ensure researcher.md creates research artifacts only
4. Validate status transitions follow state-management.md:
   - Valid transition: `[NOT STARTED]` → `[RESEARCHING]` → `[RESEARCHED]`
   - Invalid transition: `[NOT STARTED]` → `[COMPLETED]` (skip research phase)
5. Validate artifact creation follows artifact-management.md:
   - Lazy directory creation (`.opencode/specs/{number}_{slug}/`)
   - Research report in `reports/research-001.md`
   - Artifact links in TODO.md and state.json via status-sync-manager
6. Test /research command with markdown task (like 267)
7. Test /research command with lean task (language-based routing)
8. Verify no implementation occurs during research
9. Update documentation if needed

**Acceptance Criteria**:
- [ ] /research command creates research artifacts only (no implementation)
- [ ] Research artifacts follow artifact-management.md standards
- [ ] Status transitions follow state-management.md: `[NOT STARTED]` → `[RESEARCHING]` → `[RESEARCHED]`
- [ ] Artifact links added to TODO.md and state.json via status-sync-manager
- [ ] No implementation occurs during /research
- [ ] Language-based routing works correctly (lean vs general)
- [ ] Lazy directory creation followed
- [ ] Git commits created for research artifacts only
- [ ] Atomic status updates via status-sync-manager (two-phase commit)

**Files Affected**:
- `.opencode/agent/subagents/researcher.md` (remove implementation logic)
- `.opencode/command/research.md` (validate workflow documentation)
- `.opencode/context/core/system/state-management.md` (reference standard)

**Impact**: Fixes critical workflow bug where /research implements tasks instead of researching them, preventing proper research/plan/implement workflow separation and violating status transition rules.

**References**:
- State Management Standard: `.opencode/context/core/system/state-management.md`
- Artifact Management: `.opencode/context/core/system/artifact-management.md`
- Status Sync Manager: `.opencode/agent/subagents/status-sync-manager.md`

---

### 263. Refactor Context.lean
- **Effort**: 2-4 hours
- **Status**: [RESEARCHING]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: Task 264
- **Dependencies**: None

**Description**: Refactor the `Context.lean` file to improve clarity, performance, and alignment with the LEAN 4 style guide. This involves reviewing the existing implementation of proof contexts and applying best practices for data structures and function definitions in LEAN 4.

**Files Affected**:
- `Logos/Core/Syntax/Context.lean`
- `LogosTest/Core/Syntax/ContextTest.lean`

**Acceptance Criteria**:
- [ ] The `Context.lean` file is refactored for clarity and performance.
- [ ] All related tests in `ContextTest.lean` are updated and pass.
- [ ] The refactoring adheres to the LEAN 4 style guide.
- [ ] The public API of the `Context` module remains backward-compatible or changes are documented.

**Impact**: Improves the maintainability and readability of a core component of the syntax package.

---

### 264. Update Context References
- **Effort**: 1-2 hours
- **Status**: [RESEARCHING]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: Task 263

**Files Affected**:
- `Logos/Core/ProofSystem/Derivation.lean`
- `Logos/Core/Metalogic/DeductionTheorem.lean`
- Other files that import `Logos.Core.Syntax.Context`

**Description**: After refactoring `Context.lean`, update all references to the `Context` module throughout the codebase to ensure they are compatible with any changes made to the API. This task involves searching for all usages of `Context` and updating them as necessary.

**Acceptance Criteria**:
- [ ] All references to the `Context` module are updated.
- [ ] The project builds successfully after the updates.
- [ ] All tests pass after the updates.

**Impact**: Ensures that the entire codebase is compatible with the refactored `Context` module.

---

## High Priority




### 132. Prove Lindenbaum maximal consistency lemma in Completeness.lean
- **Effort**: 3 hours
- **Status**: [RESEARCHED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - Logos/Core/Metalogic/Completeness.lean
- **Description**: Formalize and prove the Lindenbaum maximal consistency lemma to eliminate the first axiom placeholder.
- **Acceptance Criteria**:
  - [ ] Lindenbaum lemma proven and axiom removed
  - [ ] Proof integrates with existing canonical model scaffolding
  - [ ] Related tests added or updated
- **Impact**: Unlocks subsequent completeness proofs by establishing maximal consistency.

---

### 133. Build canonical model constructors in Completeness.lean
- **Effort**: 3 hours
- **Status**: [RESEARCHED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 132
- **Files Affected**:
  - Logos/Core/Metalogic/Completeness.lean
- **Description**: Implement canonical model construction helpers and remove associated axiom stubs.
- **Acceptance Criteria**:
  - [ ] Canonical model constructors implemented
  - [ ] Corresponding axiom placeholders removed
  - [ ] Construction type-checks with existing definitions
- **Impact**: Provides the core model for subsequent truth lemma proofs.

---

### 134. Prove truth lemma structure in Completeness.lean
- **Effort**: 3 hours
- **Status**: [RESEARCHED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 133
- **Files Affected**:
  - Logos/Core/Metalogic/Completeness.lean
- **Description**: Prove the truth lemma for the canonical model, removing the corresponding axiom placeholder.
- **Acceptance Criteria**:
  - [ ] Truth lemma proven and axiom removed
  - [ ] Proof integrates with canonical model components
  - [ ] Tests (or placeholders) updated to exercise lemma
- **Impact**: Establishes the key bridge between syntax and semantics for completeness.

---

### 135. Remove provable_iff_valid sorry in Completeness.lean
- **Effort**: 2 hours
- **Status**: [RESEARCHED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 132, 133, 134
- **Files Affected**:
  - Logos/Core/Metalogic/Completeness.lean
- **Description**: Complete the `provable_iff_valid` theorem using the proven canonical model and truth lemma to eliminate the remaining sorry.
- **Acceptance Criteria**:
  - [ ] `provable_iff_valid` fully proven
  - [ ] No remaining axiom or sorry placeholders in Completeness.lean
  - [ ] Completeness tests added or updated
- **Impact**: Delivers full completeness, enabling derivability from validity.

### Decidability


---

### 136. Design Decidability.lean architecture and signatures
- **Effort**: 2 hours
- **Status**: [RESEARCHED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - Logos/Core/Metalogic/Decidability.lean
- **Description**: Define the module structure, main theorems, and function signatures for decidability (tableau and satisfiability checks).
- **Acceptance Criteria**:
  - [ ] Module skeleton with signatures for tableau and decision procedures
  - [ ] Documentation comments outline intended algorithms
  - [ ] No build warnings from new declarations
- **Impact**: Establishes a foundation for future decidability proofs and implementations.

---

### 137. Implement tableau core rules in Decidability.lean
- **Effort**: 3 hours
- **Status**: [RESEARCHED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 136
- **Files Affected**:
  - Logos/Core/Metalogic/Decidability.lean
- **Description**: Implement the core tableau expansion rules and supporting helpers for validity checking.
- **Acceptance Criteria**:
  - [ ] Tableau expansion rules implemented and type-checking
  - [ ] Basic examples compile demonstrating rule application
  - [ ] No placeholder axioms for these rules remain
- **Impact**: Provides executable building blocks for the decision procedure.

---

### 138. Implement satisfiability and validity decision procedure tests
- **Effort**: 3 hours
- **Status**: [RESEARCHED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 136, 137
- **Files Affected**:
  - Logos/Core/Metalogic/Decidability.lean
  - LogosTest/Metalogic/DecidabilityTest.lean (new or updated)
- **Description**: Wire the tableau components into a decision procedure and add tests covering satisfiable and unsatisfiable cases.
- **Acceptance Criteria**:
  - [ ] Decision procedure implemented and compiles
  - [ ] Tests cover satisfiable and unsatisfiable scenarios
  - [ ] No remaining placeholder axioms in the decision procedure path
- **Impact**: Delivers an initial, test-backed decision procedure for TM logic.

### Layer Extensions (Future Planning)


---

### 139. Draft Layer 1 counterfactual operator plan
- **Effort**: 2 hours
- **Status**: [RESEARCHED]
- **Priority**: Low
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - Documentation/UserGuide/ARCHITECTURE.md
  - Documentation/UserGuide/METHODOLOGY.md
- **Description**: Draft a plan for Layer 1 counterfactual operators, defining `box_c` and `diamond_m` semantics and integration points.
- **Acceptance Criteria**:
  - [ ] Draft plan describing operators, semantics, and required modules
  - [ ] Architecture updated with Layer 1 scope and assumptions
  - [ ] Clear follow-on tasks identified
- **Impact**: Provides roadmap for counterfactual extensions post Layer 0.

---

### 140. Draft Layer 2 epistemic operator plan
- **Effort**: 2 hours
- **Status**: [RESEARCHED]
- **Priority**: Low
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - Documentation/UserGuide/ARCHITECTURE.md
  - Documentation/UserGuide/METHODOLOGY.md
- **Description**: Draft a plan for Layer 2 epistemic operators (`K`, `B`) including semantics and proof obligations.
- **Acceptance Criteria**:
  - [ ] Draft plan outlines semantics, target theorems, and module impacts
  - [ ] Architecture updated with Layer 2 scope and assumptions
  - [ ] Follow-on tasks identified
- **Impact**: Establishes roadmap for epistemic extensions.

---

### 141. Draft Layer 3 normative operator plan
- **Effort**: 2 hours
- **Status**: [RESEARCHED]
- **Priority**: Low
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - Documentation/UserGuide/ARCHITECTURE.md
  - Documentation/UserGuide/METHODOLOGY.md
- **Description**: Draft a plan for Layer 3 normative operators (`O`, `P`) including semantics and proof obligations.
- **Acceptance Criteria**:
  - [ ] Draft plan outlines semantics, target theorems, and module impacts
  - [ ] Architecture updated with Layer 3 scope and assumptions
  - [ ] Follow-on tasks identified
- **Impact**: Provides a roadmap for normative logic extensions.

---

### 175. Establish CI/CD pipeline with automated testing and linting
- **Effort**: 13 hours
- **Status**: [RESEARCHED]
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - .github/workflows/ci.yml (new)
  - .github/workflows/lint.yml (new)
  - .github/workflows/coverage.yml (new)
  - Documentation/Development/CI_CD_PROCESS.md (new)
- **Description**: Create GitHub Actions workflows for continuous integration and deployment. Currently all tests run manually. CI/CD pipeline should run tests, linting, style checks, coverage reporting, and documentation build checks automatically on every pull request and commit.
- **Acceptance Criteria**:
  - [ ] GitHub Actions workflow for tests created and passing
  - [ ] Linting and style checks integrated into CI
  - [ ] Coverage reporting integrated into CI
  - [ ] Documentation build checks integrated into CI
  - [ ] CI runs on all pull requests and commits to main
  - [ ] CI failure blocks merge
  - [ ] CI/CD process documented in CI_CD_PROCESS.md
- **Impact**: Ensures code quality automatically, prevents regressions, and enables confident merging of pull requests. Essential for maintaining production-ready code.

---

### 176. Enhance proof search with domain-specific heuristics and caching
- **Effort**: 18 hours
- **Status**: [RESEARCHED]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - Logos/Core/Automation/ProofSearch.lean
  - Logos/Core/Automation/ProofSearchHeuristics.lean (new)
  - Logos/Core/Automation/ProofCache.lean (new)
  - LogosTest/Core/Automation/ProofSearchHeuristicsTest.lean (new)
- **Description**: Enhance ProofSearch.lean with modal-specific and temporal-specific heuristics, proof caching with hash-consing, and success pattern learning. Current heuristics are basic (Task 127 complete). Domain-specific optimizations will significantly improve proof search effectiveness.
- **Acceptance Criteria**:
  - [ ] Modal-specific heuristics implemented (prefer S5 axioms for modal goals)
  - [ ] Temporal-specific heuristics implemented (prefer temporal axioms for temporal goals)
  - [ ] Proof caching with hash-consing implemented
  - [ ] Success pattern learning implemented
  - [ ] Heuristics tested and benchmarked
  - [ ] Documentation for heuristic tuning added
- **Impact**: Improves automation effectiveness by tailoring proof search to the structure of modal and temporal problems, reducing search time and increasing success rate.

---

### 178. Complete advanced tutorial sections with hands-on exercises
- **Effort**: 13 hours
- **Status**: [RESEARCHED]
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: 172
- **Files Affected**:
  - Documentation/UserGuide/TUTORIAL.md
  - Documentation/UserGuide/TUTORIAL_EXERCISES.md (new)
  - Documentation/UserGuide/TROUBLESHOOTING.md (new)
- **Description**: Enhance TUTORIAL.md with advanced sections on proof search automation, custom tactic development, and metalogic. Add hands-on exercises with solutions and a troubleshooting guide. Current tutorial is basic and lacks advanced topics.
- **Acceptance Criteria**:
  - [ ] Advanced tutorial section on proof search and automation added
  - [ ] Advanced tutorial section on custom tactic development added
  - [ ] Advanced tutorial section on metalogic and soundness added
  - [ ] Hands-on exercises with solutions added
  - [ ] Troubleshooting guide created
  - [ ] Tutorial tested with new users for clarity
- **Impact**: Improves onboarding by providing comprehensive learning path from basics to advanced topics with practical exercises.

---

### 179. Implement performance benchmarks for proof search and derivation
- **Effort**: 13 hours
- **Status**: [RESEARCHED]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - LogosBench/ (new directory)
  - LogosBench/ProofSearchBench.lean (new)
  - LogosBench/DerivationBench.lean (new)
  - LogosBench/SemanticEvaluationBench.lean (new)
  - Documentation/Development/PERFORMANCE_TARGETS.md (new)
- **Description**: Create performance benchmark suite for proof search, derivation, and semantic evaluation. Add performance regression testing to CI. Currently no benchmarks exist and performance could regress unnoticed. Document performance targets.
- **Acceptance Criteria**:
  - [ ] Benchmark suite for proof search created
  - [ ] Benchmark suite for derivation created
  - [ ] Benchmark suite for semantic evaluation created
  - [ ] Performance regression testing added to CI
  - [ ] Performance targets documented
  - [ ] Baseline performance measurements recorded
- **Impact**: Ensures performance doesn't regress and provides data for optimization efforts. Critical for maintaining usable proof search times.

---

### 180. Add test coverage metrics and reporting
- **Effort**: 9 hours
- **Status**: [RESEARCHED]
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: 175
- **Files Affected**:
  - .github/workflows/coverage.yml
  - scripts/GenerateCoverage.lean (new)
  - Documentation/Development/TEST_COVERAGE.md (new)
- **Description**: Integrate test coverage measurement tool, generate coverage reports, add coverage reporting to CI, and create coverage improvement plan. TESTING_STANDARDS.md defines target of at least 85 percent but no measurement exists.
- **Acceptance Criteria**:
  - [ ] Coverage measurement tool integrated
  - [ ] Coverage reports generated automatically
  - [ ] Coverage reporting integrated into CI
  - [ ] Coverage improvement plan created
  - [ ] Coverage measurement process documented
  - [ ] Current coverage baseline established
- **Impact**: Enables data-driven test improvement by identifying untested code paths and tracking coverage over time.

---

### 189. Add --divide flag to /research command for topic subdivision
- **Effort**: 3 hours
- **Status**: [IN PROGRESS]
- **Started**: 2025-12-26
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Research Artifacts**:
  - Main Report: [.opencode/specs/189_research_divide_flag/reports/research-001.md]
  - Summary: [.opencode/specs/189_research_divide_flag/summaries/research-summary.md]
- **Files Affected**:
  - .opencode/command/research.md
  - .opencode/agent/subagents/researcher.md
  - .opencode/agent/subagents/specialists/web-research-specialist.md
- **Description**: Add a --divide flag to the /research command that changes its behavior. Without --divide, /research should create individual research reports only (no research summary). With --divide, /research should invoke a subagent to divide the research topic into natural subtopics, pass each subtopic to further research subagents to research and create individual reports, then compile the references and brief summaries into a research summary report. The research summary should contain only references to the individual reports and their brief summaries, not duplicate the full content.
- **Acceptance Criteria**:
  - [ ] --divide flag added to /research command documentation and input parsing
  - [ ] Without --divide: /research creates only individual research reports (reports/research-NNN.md), no summary
  - [ ] With --divide: /research divides topic into subtopics using a subagent
  - [ ] With --divide: Each subtopic is researched by a separate subagent, creating individual reports
  - [ ] With --divide: Research summary report (summaries/research-summary.md) is created compiling references and brief summaries
  - [ ] Research summary contains only references and brief summaries, not full content
  - [ ] All behavior follows lazy directory creation (create summaries/ only when writing summary)
  - [ ] Status markers and state sync work correctly for both modes
  - [ ] Documentation updated to explain --divide flag behavior
- **Impact**: Provides more flexible research workflow - simple research creates focused reports without overhead of summary compilation, while complex research can be divided into manageable subtopics with a summary overview.

---

### 203. Add --complex flag to /research for subtopic subdivision with summary
- **Effort**: TBD
- **Status**: [RESEARCHED]
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - .opencode/command/research.md
  - .opencode/agent/subagents/researcher.md
  - .opencode/agent/subagents/lean-research-agent.md
- **Description**: Enhance the /research command to support a --complex flag that changes its behavior for handling complex research topics. Without --complex flag: /research creates a single research report (reports/research-001.md) with no summary - this is the current default behavior. With --complex flag: /research should (1) Divide the topic into 1-5 appropriate subtopics using intelligent analysis, (2) Spawn research subagents to complete each subtopic in parallel, creating individual research reports (reports/research-001.md, reports/research-002.md, etc.), (3) Each subagent returns only its report path and brief summary (not full content) to the primary agent, (4) Primary agent compiles all report paths and brief summaries into a research summary report (summaries/research-summary.md), (5) Update TODO.md and state.json with all report references and mark task as [RESEARCHED]. The --complex flag enables comprehensive research on large topics while protecting context windows through summarization.
- **Acceptance Criteria**:
  - [ ] --complex flag added to /research command argument parsing
  - [ ] Without --complex: /research creates single report, no summary (current behavior preserved)
  - [ ] With --complex: Topic intelligently divided into 1-5 subtopics
  - [ ] With --complex: Separate research subagents spawned for each subtopic
  - [ ] With --complex: Each subtopic generates individual report (reports/research-NNN.md)
  - [ ] With --complex: Subagents return only report path + brief summary (not full content)
  - [ ] With --complex: Primary agent creates research summary (summaries/research-summary.md) compiling all references
  - [ ] Research summary contains only paths and brief summaries, not duplicated full content
  - [ ] Lazy directory creation followed (summaries/ created only when writing summary)
  - [ ] TODO.md updated with all report references and [RESEARCHED] status for both modes
  - [ ] state.json updated correctly for both modes
  - [ ] Documentation explains --complex flag behavior and use cases
- **Impact**: Enables comprehensive research on complex topics by dividing them into manageable subtopics while protecting the primary agent's context window through summarization. Provides flexibility - simple topics get focused single reports, complex topics get thorough multi-report coverage with summary overview.

---

### 205. Implement Lean tool usage verification and monitoring system
- **Effort**: 6-8 hours
- **Status**: [RESEARCHED]
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - .opencode/command/research.md
  - .opencode/command/implement.md
  - .opencode/agent/subagents/lean-research-agent.md
  - .opencode/agent/subagents/lean-implementation-agent.md
  - .opencode/context/core/standards/lean-tool-verification.md (new)
  - .opencode/specs/monitoring/ (new directory structure)
- **Description**: Design and implement a comprehensive monitoring and verification system to detect and validate that Lean-specific tools (lean-lsp-mcp, Loogle, LeanExplore, LeanSearch) are being correctly used by the appropriate commands and agents when processing Lean tasks. The system should provide visibility into tool usage patterns, detect routing errors, track tool availability issues, and identify opportunities for improvement. This includes creating verification methods, logging standards, monitoring dashboards, and automated health checks to ensure the system is working optimally.
- **Acceptance Criteria**:
  - [ ] Verification method identified for detecting lean-lsp-mcp usage in /implement command for Lean tasks
  - [ ] Verification method identified for detecting Loogle usage in /research command for Lean tasks
  - [ ] Automated tool availability checks implemented (binary existence, process health, API connectivity)
  - [ ] Tool usage logging standardized in lean-research-agent and lean-implementation-agent return formats
  - [ ] Monitoring dashboard or report created showing tool usage metrics per command execution
  - [ ] Health check command or script created to verify routing is working correctly
  - [ ] Documentation created explaining verification methods and monitoring approach
  - [ ] Error detection implemented for cases where tools should be used but aren't (routing failures)
  - [ ] Recommendations provided for system improvements based on monitoring data
  - [ ] All verification methods tested with real command executions on Lean tasks
- **Impact**: Provides visibility and confidence that the Lean tool integration is working correctly, enables early detection of routing or configuration issues, and identifies opportunities to improve the system's effectiveness with Lean-specific research and implementation workflows.

---

### 218. Fix lean-lsp-mcp integration and opencode module import errors
**Effort**: 0.75 hours
**Status**: [PLANNED]
**Started**: 2025-12-28
**Researched**: 2025-12-28
**Priority**: High
**Blocking**: None
**Dependencies**: 212 (completed)
**Language**: python
**Research Artifacts**:
  - Main Report: [.opencode/specs/218_fix_lean_lsp_mcp_integration/reports/research-002.md]
**Research Findings** (2025-12-28): CRITICAL DISCOVERY: OpenCode has native MCP support via opencode.json configuration, NOT .mcp.json. Task 212's custom Python MCP client approach is architecturally incompatible - OpenCode agents use natural language tool instructions, not Python imports. The ModuleNotFoundError is a symptom of wrong architectural approach, not missing __init__.py files. Solution requires complete pivot from Python-based integration to configuration-based integration: (1) Create opencode.json with lean-lsp-mcp server configuration, (2) Update lean-implementation-agent.md to use natural language MCP tool instructions instead of Python imports, (3) Remove custom MCP client from task 212 (architecturally incompatible). Proper approach enables 15+ lean-lsp-mcp tools (compile, check-proof, search, etc.) via native OpenCode MCP bridge. Previous plan obsolete - new configuration-based approach estimated 1-2 hours.

**Files Affected**:
- opencode.json (new, MCP server configuration)
- .opencode/agent/subagents/lean-implementation-agent.md (update to use MCP tool instructions)
- .opencode/agent/subagents/lean-research-agent.md (update to use MCP tool instructions)
- Documentation/UserGuide/MCP_INTEGRATION.md (new, user guide)
- .opencode/tool/mcp/client.py (mark deprecated, incompatible with OpenCode architecture)

**Description**:
Research revealed that OpenCode has native MCP (Model Context Protocol) support that makes task 212's custom Python MCP client unnecessary and architecturally incompatible. OpenCode agents interact with MCP servers through natural language tool instructions, not Python imports. The proper integration approach uses opencode.json configuration to register MCP servers, making their tools automatically available to agents. This enables lean-implementation-agent to use lean-lsp-mcp's 15+ tools for real-time compilation checking, proof state inspection, and theorem search during Lean proof implementation.

**Acceptance Criteria**:
- [ ] opencode.json created with lean-lsp-mcp server configuration
- [ ] lean-implementation-agent.md updated with MCP tool usage instructions
- [ ] lean-research-agent.md updated with MCP tool usage instructions  
- [ ] MCP integration guide created in user documentation
- [ ] Test Lean task implementation successfully uses lean-lsp-mcp tools
- [ ] No Python import errors (using configuration-based approach)
- [ ] Selective tool enablement reduces context window usage

**Impact**:
CRITICAL ARCHITECTURAL CORRECTION: Pivots from incompatible custom Python client to proper OpenCode-native MCP integration. Enables lean-lsp-mcp tools for real-time Lean compilation checking, proof verification, and theorem search. Reduces context window usage by 2000-5000 tokens through selective per-agent tool enablement. Establishes foundation for additional MCP servers (Context7, Grep) to enhance Lean development workflow.

---


### 279. Systematically fix metadata lookup to use state.json instead of TODO.md
- **Effort**: 12-16 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None

**Description**:
When running `/implement 276`, the command output showed "Extract task 276 details from TODO.md" which indicates that commands and subagents are extracting metadata from TODO.md instead of from the authoritative source (specs/state.json). TODO.md should be kept in sync as a user-facing version of state.json, but all metadata lookups should reference state.json as the single source of truth.

**Current Behavior**:
```bash
/implement 276
# Output shows: "Extract task 276 details from TODO.md"
# Problem: Using TODO.md for metadata lookup instead of state.json
```

**Expected Behavior**:
```bash
/implement 276
# Should: Extract task 276 metadata from state.json
# Should: Use state.json as single source of truth
# Should: Update TODO.md to reflect state.json changes (sync direction: state.json → TODO.md)
```

**Root Cause Analysis**:

Comprehensive codebase search reveals widespread use of TODO.md for metadata extraction:

1. **Orchestrator** (`.opencode/agent/orchestrator.md`):
   - Stage 2 (DetermineRouting): "Extract language from state.json or TODO.md"
   - Should be: Extract language from state.json ONLY

2. **Workflow Commands** (4 files):
   - `/research` - "Extract language from task entry (state.json or TODO.md)"
   - `/plan` - "Extract language from task entry (state.json or TODO.md)"
   - `/implement` - "Extract language from task entry (state.json or TODO.md)"
   - `/revise` - "Extract language from task entry (state.json or TODO.md)"
   - Should be: Extract from state.json ONLY

3. **Subagents** (7 files):
   - `researcher.md` - "Extract language from state.json (fallback to TODO.md)"
   - `planner.md` - "Read task from .opencode/specs/TODO.md"
   - `implementer.md` - "grep -A 50 "^### ${task_number}\." .opencode/specs/TODO.md"
   - `lean-research-agent.md` - "Extract language from state.json (fallback to TODO.md)"
   - `lean-implementation-agent.md` - "Read task from .opencode/specs/TODO.md"
   - `lean-planner.md` - "Read task from .opencode/specs/TODO.md"
   - `status-sync-manager.md` - "Extract current status from .opencode/specs/TODO.md"
   - Should be: Extract from state.json ONLY

4. **Context Files** (6 files):
   - `routing-guide.md` - "Extract language from task entry in TODO.md"
   - `routing-logic.md` - "task_entry=$(grep -A 20 "^### ${task_number}\." .opencode/specs/TODO.md)"
   - `research-workflow.md` - "Read task from TODO.md using grep"
   - `planning-workflow.md` - "Read task from TODO.md using grep"
   - `implementation-workflow.md` - "Read task from TODO.md using grep"
   - `subagent-structure.md` - "Read task from TODO.md"
   - Should be: Document state.json as source of truth

**Metadata Fields Affected**:

The following metadata fields are currently extracted from TODO.md but should come from state.json:

1. **Language** - Used for routing to Lean-specific agents
2. **Priority** - Used for task prioritization
3. **Status** - Used for workflow state tracking
4. **Effort** - Used for estimation
5. **Dependencies** - Used for task ordering
6. **Blocking** - Used for identifying blockers
7. **Description** - Used for task context
8. **Artifacts** - Used for linking research/plans/implementations

**Correct Architecture**:

```
state.json (authoritative source)
    ↓
    | (read metadata)
    ↓
Commands/Subagents
    ↓
    | (update metadata)
    ↓
status-sync-manager
    ↓
    | (atomic two-phase commit)
    ↓
state.json + TODO.md (synchronized)
```

**Sync Direction**: state.json → TODO.md (NOT bidirectional)

**Files to Modify** (25 files total):

**Orchestrator** (1 file):
- `.opencode/agent/orchestrator.md` - Update Stage 2 to extract language from state.json only

**Commands** (4 files):
- `.opencode/command/research.md` - Update Stage 1 to read from state.json
- `.opencode/command/plan.md` - Update Stage 1 to read from state.json
- `.opencode/command/implement.md` - Update Stage 1 to read from state.json
- `.opencode/command/revise.md` - Update Stage 1 to read from state.json

**Subagents** (7 files):
- `.opencode/agent/subagents/researcher.md` - Remove TODO.md fallback, use state.json only
- `.opencode/agent/subagents/planner.md` - Replace grep TODO.md with jq state.json
- `.opencode/agent/subagents/implementer.md` - Replace grep TODO.md with jq state.json
- `.opencode/agent/subagents/lean-research-agent.md` - Remove TODO.md fallback, use state.json only
- `.opencode/agent/subagents/lean-implementation-agent.md` - Replace grep TODO.md with jq state.json
- `.opencode/agent/subagents/lean-planner.md` - Replace grep TODO.md with jq state.json
- `.opencode/agent/subagents/status-sync-manager.md` - Extract status from state.json, not TODO.md

**Context Files** (6 files):
- `.opencode/context/core/system/routing-guide.md` - Document state.json as source
- `.opencode/context/core/system/routing-logic.md` - Update examples to use state.json
- `.opencode/context/project/processes/research-workflow.md` - Update to use state.json
- `.opencode/context/project/processes/planning-workflow.md` - Update to use state.json
- `.opencode/context/project/processes/implementation-workflow.md` - Update to use state.json
- `.opencode/context/core/standards/subagent-structure.md` - Document state.json pattern

**Standards** (2 files):
- `.opencode/context/core/system/state-management.md` - Clarify state.json as authoritative source
- `.opencode/context/core/system/artifact-management.md` - Document metadata lookup pattern

**Templates** (1 file):
- `.opencode/context/core/templates/command-template.md` - Update template to use state.json

**Documentation** (4 files):
- `.opencode/docs/guides/creating-commands.md` - Update examples to use state.json
- `.opencode/ARCHITECTURE.md` - Document state.json as source of truth
- `.opencode/REFACTOR.md` - Update refactoring notes
- `.opencode/REBUILD_SUMMARY.md` - Update rebuild notes

**Implementation Strategy**:

**Phase 1: Update Metadata Extraction Pattern** (4 hours)
1. Create helper function for state.json metadata extraction:
   ```bash
   # Extract task metadata from state.json
   task_metadata=$(jq -r --arg task_num "$task_number" \
     '.active_projects[] | select(.project_number == ($task_num | tonumber))' \
     .opencode/specs/state.json)
   
   # Extract specific fields
   language=$(echo "$task_metadata" | jq -r '.language // "general"')
   priority=$(echo "$task_metadata" | jq -r '.priority // "medium"')
   status=$(echo "$task_metadata" | jq -r '.status // "not_started"')
   ```

2. Document pattern in state-management.md
3. Create examples in routing-guide.md

**Phase 2: Update Orchestrator and Commands** (3 hours)
1. Update orchestrator.md Stage 2 (DetermineRouting)
2. Update research.md Stage 1 (PreflightValidation)
3. Update plan.md Stage 1 (PreflightValidation)
4. Update implement.md Stage 1 (PreflightValidation)
5. Update revise.md Stage 1 (PreflightValidation)

**Phase 3: Update Subagents** (4 hours)
1. Update researcher.md - Remove TODO.md fallback
2. Update planner.md - Replace grep with jq
3. Update implementer.md - Replace grep with jq
4. Update lean-research-agent.md - Remove TODO.md fallback
5. Update lean-implementation-agent.md - Replace grep with jq
6. Update lean-planner.md - Replace grep with jq
7. Update status-sync-manager.md - Extract status from state.json

**Phase 4: Update Context and Documentation** (3 hours)
1. Update 6 context files (routing, workflows, standards)
2. Update 2 standards files (state-management, artifact-management)
3. Update 1 template file (command-template)
4. Update 4 documentation files (guides, architecture, notes)

**Phase 5: Testing and Validation** (2 hours)
1. Test /research command with Lean task (language routing)
2. Test /plan command with markdown task
3. Test /implement command with general task
4. Test /revise command
5. Verify metadata extracted from state.json, not TODO.md
6. Verify TODO.md still synchronized correctly
7. Verify no grep TODO.md commands in output

**Acceptance Criteria**:
- [ ] All metadata extraction uses state.json as source of truth
- [ ] No commands or subagents extract metadata from TODO.md
- [ ] TODO.md remains synchronized via status-sync-manager (state.json → TODO.md)
- [ ] Language-based routing works correctly (Lean tasks → lean-research-agent)
- [ ] All workflow commands tested and verified
- [ ] Context files document state.json as authoritative source
- [ ] No "Extract task NNN details from TODO.md" messages in command output
- [ ] grep TODO.md only used for validation/testing, not metadata extraction

**Impact**: 
Establishes state.json as the single source of truth for task metadata, eliminating confusion about which file is authoritative. Ensures TODO.md is kept in sync as a user-facing view of state.json, but all programmatic access uses state.json. Fixes the issue observed in /implement 276 where TODO.md was being used for metadata lookup.

**Related Tasks**:
- Task 276: Investigate redundant project-level state.json files (related to state management)
- Task 272: Add YAML header to TODO.md (sync state.json → TODO.md)
- Task 275: Fix workflow status updates (uses status-sync-manager)

