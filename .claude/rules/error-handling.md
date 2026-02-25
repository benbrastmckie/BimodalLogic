---
paths: .claude/**/*
---

# Error Handling Rules

## Error Categories

| Category | Examples |
|----------|----------|
| Operational | `delegation_hang`, `timeout`, `validation_failed` |
| State | `status_sync_failure`, `file_not_found`, `parse_error` |
| External | `git_commit_failure`, `build_error`, `tool_unavailable`, `mcp_abort_error` |
| Team Mode | `team_creation_failed`, `teammate_timeout`, `synthesis_failed` |

## Error Response Pattern

1. **Log**: Record in errors.json with session_id and context
2. **Preserve**: Keep completed work, mark phases [PARTIAL] not failed
3. **Enable Resume**: Store resume point, next invocation continues
4. **Report**: Return structured error with recovery suggestion

## Severity Levels

| Severity | Response |
|----------|----------|
| critical | Stop, alert, require manual fix |
| high | Log, attempt recovery |
| medium | Log, continue with workaround |
| low | Log, ignore |

## Quick Recovery Reference

| Error | Recovery |
|-------|----------|
| Timeout | Save progress, mark [PARTIAL], commit, resume next /implement |
| State sync | Read both files, git blame for latest, sync |
| jq parse | Use `select(.type == "X" | not)` pattern |
| MCP abort | Retry once, try alternative tool, continue with partial |
| Team creation failed | Fall back to single agent |
| Context exhaustion | Write handoff, spawn successor teammate |

## Non-Blocking Errors

Log and continue: Git commit failures, metric collection, non-critical logging, team mode degradation.

Full procedures: @.claude/context/core/reference/error-recovery-procedures.md
