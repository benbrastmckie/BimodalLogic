# Research Summary: /task Command Context Window Protection

## Key Findings

1. **Current implementation has critical context window protection gaps**: task-executor and batch-task-orchestrator return verbose results (100+ lines per task) instead of artifact references + brief summaries, causing context bloat in the primary agent.

2. **Simple vs complex task paths not differentiated**: All tasks follow the same workflow (research → plan → execute) regardless of complexity, when simple tasks should use direct execution with single commits and complex tasks should use multi-phase plans with phase-based commits.

3. **Industry best practices recommend orchestrator-workers pattern**: Workers create artifacts, return only references + 3-5 sentence summaries, with progressive summarization at each hierarchy level and strict response size limits (500 tokens max).

4. **Objective complexity metrics enable intelligent routing**: Use 7 indicators (effort, files, LOC, dependencies, research, unknowns, risk) to score tasks 0-14 and route to simple (direct) or complex (plan-based) execution paths.

5. **Summary artifacts not consistently created**: When subagents create detailed artifacts (plans, reports), they don't always create corresponding summaries in summaries/ directory, violating artifact-management.md standards.

## Most Relevant Resources

- **Current Implementation Files**:
  - .opencode/command/task.md (lines 54-88: workflow, 96-102: artifact management)
  - .opencode/agent/subagents/task-executor.md (lines 559-706: verbose return format)
  - .opencode/agent/subagents/batch-task-orchestrator.md (lines 344-398: batch results aggregation)

- **Standards and Best Practices**:
  - .opencode/context/core/system/artifact-management.md (context protection principles)
  - .opencode/context/core/system/git-commits.md (targeted commit patterns)
  - Anthropic's "Building Effective Agents" (orchestrator-workers pattern)

## Recommendations

**Priority 1**: Update task-executor return format to enforce artifact-first returns (reduce from 100+ lines to ~15 lines with artifacts + brief summary + key metrics only).

**Priority 2**: Enforce summary artifact creation in summaries/ when detailed artifacts are produced (research-summary.md, plan-summary.md, implementation-summary-YYYYMMDD.md).

**Priority 3**: Implement complexity router in /task command to differentiate simple (direct execution, single commit) vs complex (multi-phase plan, commit per phase) paths using objective 7-indicator scoring.

**Priority 4**: Update batch-task-orchestrator to use progressive summarization (return brief summaries per task instead of full results, reducing batch returns from 1000+ lines to ~50 lines).

**Priority 5**: Differentiate git commit patterns: simple tasks commit once at completion, complex tasks commit after each phase with phase numbers in commit messages.

**Priority 6**: Add return validation to enforce max 500 token responses from subagents with required fields (task_number, status, artifacts, summary, key_metrics) and forbidden fields (full_content, detailed_results).

## Full Report

See: .opencode/specs/169_task_command_improvements/reports/research-001.md
