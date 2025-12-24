# Research Summary: Status Synchronization Audit

## Key Findings

1. **No Multi-File Atomic Update Mechanism**: Commands specify atomic updates across TODO.md, state.json, and plan files, but batch-status-manager only handles TODO.md. No implementation exists for multi-file atomicity, creating risk of file divergence.

2. **/revise Command Missing Postflight Status Updates**: The /revise command does not specify TODO.md or state.json status updates after creating a new plan version, leaving status markers potentially stale or incorrect.

3. **Plan File Status Updates Inconsistent**: Only /task explicitly updates plan headers and phases. /plan and /revise do not specify plan file status updates, creating synchronization gaps.

4. **state.json Field Naming Inconsistency**: state-schema.md uses `started`/`completed` but task.md line 67 uses `started_at`/`completed_at`, creating implementation ambiguity.

5. **Lazy Directory Creation Fully Compliant**: All four commands correctly defer directory creation until artifact write time, maintaining lazy creation guardrails.

## Most Relevant Resources

- `.opencode/context/common/system/status-markers.md`: Defines status marker standards and timestamp formats
- `.opencode/context/common/system/state-schema.md`: Defines state.json schema and field naming
- `.opencode/agent/subagents/specialists/batch-status-manager.md`: Current TODO.md-only atomic update specialist
- `.opencode/command/task.md`: Most complete specification for atomic TODO/plan/state updates

## Recommendations

1. **Create status-sync-manager Specialist**: New specialist for atomic multi-file updates across TODO.md, state.json, and plan files with transaction semantics and rollback capability.

2. **Fix /revise Command**: Add explicit postflight status update specification for TODO.md and state.json, clarify whether status should change or remain [PLANNED].

3. **Standardize Plan File Updates**: Ensure /plan and /revise update plan file status markers consistently with /task behavior.

4. **Fix Field Naming**: Standardize on `started`/`completed` per state-schema.md and update all command specifications.

## Full Report

See: `.opencode/specs/168_ensure_plan_research_revise_and_task_update_todo_md_and_state_json_status_correctly/reports/research-001.md`
