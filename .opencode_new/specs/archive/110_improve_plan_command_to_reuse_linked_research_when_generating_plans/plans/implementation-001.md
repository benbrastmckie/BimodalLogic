# Implementation Plan: Improve /plan command to reuse linked research when generating plans

**Project**: #110  
**Version**: 001  
**Date**: 2025-12-22  
**Complexity**: medium

## Task Description

Update the `/plan` command so that when invoked with a task number it resolves any research links already listed on that TODO entry, pulls those artifacts into the plan generation flow, and cites them in a dedicated "Research Inputs" section. Handle missing or dangling research links gracefully and keep lazy artifact creation intact (no project directories until writing artifacts).

## Research Inputs

- None linked on the TODO entry (Task 110). The plan must still support linked research when present and degrade gracefully when absent.

## Complexity Assessment

- **Level**: medium
- **Estimated Effort**: 2–4 hours
- **Required Knowledge**: command spec authoring, research artifact discovery, lazy directory creation guardrails, TODO/state synchronization, status markers
- **Potential Challenges**: robust link discovery from TODO entries, dangling/missing research references, maintaining lazy creation while still emitting plan artifacts, keeping TODO/state metadata aligned

## Technology Stack

- **Languages**: Markdown for command spec/doc updates
- **Tools/Standards**: `.opencode/command/plan.md`, `.opencode/context/common/system/artifact-management.md`, `.opencode/specs/TODO.md`, `.opencode/specs/state.json`, `status-markers.md`, `tasks.md`

## Implementation Steps

### Step 1: Gather context and define research-link resolution rules
**Action**: Document how `/plan {task_number}` discovers research links on the TODO entry (Markdown links in task body, Research: lines, summaries). Define graceful handling for no links and for missing/dangling files.  
**Files**: `.opencode/command/plan.md`, `.opencode/context/common/system/artifact-management.md`  
**Verification**: Rules cover normal, empty, and dangling-link cases and align with acceptance criteria.

### Step 2: Update /plan command contract for research reuse and lazy creation
**Action**: Expand the command spec to (a) load linked research paths from TODO, (b) pass resolved research references into the planner subagent, (c) emit a "Research Inputs" section in the generated plan with citations, and (d) preserve lazy directory creation (create project root + `plans/` only when writing).  
**Files**: `.opencode/command/plan.md`  
**Verification**: Spec explicitly lists research resolution, citation requirements, and lazy creation guardrails; examples reflect the new behavior.

### Step 3: Update artifact-management guidance for /plan + research inputs
**Action**: Add guidance on reusing research for plans, citation expectations, and lazy creation boundaries for project roots/subdirs.  
**Files**: `.opencode/context/common/system/artifact-management.md`  
**Verification**: Guidance references research-input reuse, citation placement, and lazy directory creation for `/plan` specifically.

### Step 4: Sync TODO/state metadata
**Action**: Add the new plan link and brief summary to the Task 110 TODO entry; update task status markers and timestamps. Create project state.json and update `.opencode/specs/state.json` (project registration, next_project_number increment, pending_tasks status).  
**Files**: `.opencode/specs/TODO.md`, `.opencode/specs/state.json`, `.opencode/specs/110_improve_plan_command_to_reuse_linked_research_when_generating_plans/state.json`  
**Verification**: TODO/state are consistent; status markers and lowercase state values match standards; plan path recorded; no extra directories created.

### Step 5: Validation pass
**Action**: Check JSON validity, link correctness, and conformity with status-markers/tasks standards; ensure no `.gitkeep` or empty subdirectories were introduced.  
**Files**: updated files above  
**Verification**: All acceptance criteria satisfied; links resolve; directory creation limited to project root and `plans/`.

## File Structure

```
.opencode/specs/110_improve_plan_command_to_reuse_linked_research_when_generating_plans/
  plans/
    implementation-001.md
  state.json
```

## Testing Strategy

- **Validation**: Verify plan contains "Research Inputs" with citations (or explicit "None linked" note) and acceptance criteria coverage.
- **Integrity**: Confirm TODO link points to the plan; state.json entries updated and valid JSON.
- **Guardrails**: Ensure no extra directories (`reports/`, `summaries/`) are created until needed.

## Verification Checkpoints

- [ ] Research resolution and graceful handling rules documented
- [ ] /plan contract updated with research input flow + citations
- [ ] Artifact-management updated for research reuse + lazy creation
- [ ] TODO/state synchronized with plan link and statuses
- [ ] No premature directory creation beyond project root + `plans/`

## Related Tasks

- Task 108 (/todo and /review lifecycle) — ensures cleanup/gap-analysis does not conflict with /plan numbering.
- Task 109 (lazy directory creation enforcement) — complementary guardrails for artifact-producing commands.
