---
name: errors
agent: orchestrator
description: "Analyze errors.json, create fix plans, track fix effectiveness"
context_level: 2
language: markdown
routing:
  language_based: false
  target_agent: error-diagnostics-agent
timeout: 1800
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/orchestration/delegation.md"
    - "core/orchestration/state-management.md"
    - "core/orchestration/routing.md"
  data_files:
    - ".opencode/specs/errors.json"
    - ".opencode/specs/TODO.md"
    - ".opencode/specs/state.json"
  max_context_size: 50000
---

**Usage:** `/errors [--all] [--type TYPE]`

## Description

Analyzes errors.json, groups errors by type and root cause, checks for recurring errors, creates fix plans, and tracks fix effectiveness.

## Workflow Setup

**Orchestrator handles:**
- Parse flags from arguments (--all, --type)
- Load and filter errors.json
- Group errors by type and root cause
- Check for recurring errors
- Delegate to error-diagnostics-agent
- Validate return format
- Relay result to user

**Error-diagnostics-agent handles:**
- Root cause analysis for error groups
- Fix recommendations
- Fix plan creation
- TODO task creation for fixes
- errors.json updates with fix references
- Git commits

## Arguments

- `--all` (optional): Analyze all errors (default: only not_addressed)
- `--type TYPE` (optional): Filter to specific error type

## Examples

```bash
/errors                                  # Analyze unaddressed errors
/errors --all                            # Analyze all errors
/errors --type delegation_hang           # Analyze specific type
```

## Error Types

- `delegation_hang` - Delegation timeouts or hangs
- `tool_failure` - Tool invocation failures
- `status_sync_failure` - Status synchronization failures
- `build_error` - Build/compilation errors
- `git_commit_failure` - Git commit failures

## Delegation

**Target Agent:** `error-diagnostics-agent` (`.opencode/agent/subagents/error-diagnostics-agent.md`)  
**Timeout:** 1800s (30 minutes)  
**Language-Based Routing:** No (always routes to error-diagnostics-agent)

**Error-Diagnostics-Agent Responsibilities:**
- Analyze error groups and identify root causes
- Generate fix recommendations
- Create fix plan in specs/NNN_error_fix/plans/
- Create TODO task linking fix plan
- Update errors.json with fix references
- Create git commit

## Quality Standards

**Error Grouping:**
- Group errors intelligently by type and root cause
- Identify patterns and recurring issues
- Track fix effectiveness by checking recurrence

**Atomic Updates:**
- Use atomic write for errors.json updates
- Backup errors.json before writing
- Rollback on write failure

**Fix Plan Structure:**
- Overview: Error summary and impact
- Error Groups: Grouped by type and root cause
- Fix Recommendations: From error-diagnostics
- Phases: Fix implementation phases
- Success Criteria: Error resolution verification

## Error Handling

**No Errors Found:**
```
No errors found matching filter
Suggestion: Use --all flag to see all errors
```

**Timeout:**
```
Error: Error analysis timed out after 1800s
Status: Partial analysis may exist
Recommendation: Retry with /errors
```

**Validation Failure:**
```
Error: Return validation failed
Details: {validation_error}
Recommendation: Fix error-diagnostics-agent subagent
```

**Plan Creation Failure:**
```
Error: Fix plan creation failed
Details: {error_message}
Recommendation: Check error-diagnostics-agent logs
```

**Errors.json Update Failure:**
```
Error: errors.json update failed
Rollback: Restored from backup
Recommendation: Retry with /errors
```

## Notes

- **Recurrence Tracking**: Checks if errors recurred after fix_attempted
- **Fix Effectiveness**: Marks fixes as successful or failed based on recurrence
- **Atomic Updates**: errors.json updates are atomic with backup/rollback
- **Git Workflow**: Delegated to git-workflow-manager for standardized commits
- **Priority Assignment**: Critical errors → Priority: Critical, High severity → Priority: High

For detailed workflow documentation, see:
- `.opencode/agent/subagents/error-diagnostics-agent.md`
