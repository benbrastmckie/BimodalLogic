# Error Recovery Procedures

Detailed recovery procedures for all error types. For quick reference, see error-handling.md.

## Timeout Recovery

```
1. Save partial progress to metadata file
2. Mark current phase [PARTIAL] in plan file
3. Git commit progress with session ID
4. Next /implement command resumes from failure point
```

**Metadata for timeout**:
```json
{
  "status": "partial",
  "partial_progress": {
    "stage": "timeout",
    "details": "Operation exceeded time limit",
    "phases_completed": 2,
    "phases_total": 4
  }
}
```

## State Sync Recovery

```
1. Read both TODO.md and state.json
2. Use git blame to determine latest modification
3. Sync to latest version
4. Log resolution in errors.json
```

**Detection**: `status_sync_failure` error when TODO.md and state.json disagree on task status.

**Auto-recovery**: `/task --sync` command performs reconciliation.

## Build Error Recovery

```
1. Capture full error output from lake build
2. Log to errors.json with file paths and line numbers
3. Keep source unchanged (no partial modifications)
4. Report error with context for manual fix
```

**For Lean tasks**: Use `/lake --max-retries N` for automatic repair attempts.

## jq Parse Failure Recovery

```
1. Capture jq error output (INVALID_CHARACTER, syntax error)
2. Log to errors.json with original command
3. Retry using "| not" pattern (see jq-escaping-workarounds.md)
4. If retry succeeds, log recovery
```

**Root cause**: Claude Code Issue #1132 escapes `!=` as `\!=`.

**Safe pattern**: Use `select(.type == "X" | not)` instead of `select(.type != "X")`

## MCP Abort Error Recovery

```
1. Log the error with tool name and context
2. Retry once after 5-second delay
3. Try alternative tool if available:
   - lean_diagnostic_messages -> lean_goal + lake build
   - lean_file_outline -> Read + lean_hover_info
4. Write partial status to metadata file
5. Continue with available information or return partial
```

**Error code**: `-32001` (MCP abort)

**Common cause**: Resource contention from multiple concurrent lean-lsp-mcp instances.

## Delegation Interrupted Recovery

```
1. Check metadata file for status="in_progress"
2. Extract partial_progress to determine resume point
3. Keep task status unchanged (still "researching" or "implementing")
4. Log error with partial_progress context
5. Display guidance: "Run command again to resume"
```

**Detection**: Metadata file exists with `status: "in_progress"` but agent terminated.

**Prevention**: Early metadata pattern ensures metadata exists for recovery.

## Team Mode Recovery

### Team Creation Failed

```
1. Log warning: "Team mode unavailable, falling back to single agent"
2. Invoke standard single-agent skill (skill-researcher, skill-planner, etc.)
3. Mark degraded_to_single: true in metadata
4. Continue with single-agent result
```

### Teammate Timeout

```
1. Continue with available teammate results
2. Note timeout in synthesis
3. Mark result as partial if critical teammate missing
4. Log which teammate timed out
```

### Synthesis Failed

```
1. Preserve raw teammate findings
2. Mark status as partial
3. Provide teammate result files to user
4. Log synthesis failure reason
```

### Debug Cycle Exhausted

```
1. Mark phase as [PARTIAL] in plan
2. Preserve all debug reports in specs/{N}_{SLUG}/debug/
3. Return partial with debug history
4. Suggest manual intervention
```

## Context Exhaustion Recovery

Context exhaustion is **expected** for complex phases, not an error.

### Handoff Pattern

```
1. Teammate detects approaching context limit (~80% usage)
2. Write handoff artifact:
   specs/{N}_{SLUG}/handoffs/phase-{P}-handoff-{TIMESTAMP}.md
3. Update progress file:
   specs/{N}_{SLUG}/progress/phase-{P}-progress.json
4. Return partial status with handoff_path in metadata
5. Lead spawns successor teammate (NOT single-agent fallback)
6. Successor reads minimal handoff context
7. Successor continues from handoff
```

### Metadata for Context Exhaustion

```json
{
  "status": "partial",
  "partial_progress": {
    "stage": "context_exhaustion_handoff",
    "details": "Approaching context limit. Handoff written with current state.",
    "handoff_path": "specs/{N}_{SLUG}/handoffs/phase-{P}-handoff-{TIMESTAMP}.md",
    "phases_completed": 2,
    "phases_total": 4
  }
}
```

### Successor Prompt

```
Quick Start (read ONLY this first):
- Immediate Next Action: {from handoff}
- Current State: {from handoff}

If stuck, read full handoff at: {handoff_path}
```

## Error Logging Format

All errors logged to errors.json:

```json
{
  "id": "err_{timestamp}",
  "timestamp": "ISO_DATE",
  "type": "error_type",
  "severity": "critical|high|medium|low",
  "message": "Error description",
  "context": {
    "session_id": "sess_1736700000_abc123",
    "command": "/implement",
    "task": 259,
    "phase": 2,
    "checkpoint": "GATE_OUT"
  },
  "trajectory": {
    "delegation_path": ["orchestrator", "implement", "skill-implementer", "agent"],
    "failed_at_depth": 3
  },
  "recovery": {
    "suggested_action": "Run /implement 259 to resume from phase 2",
    "auto_recoverable": true
  },
  "fix_status": "unfixed"
}
```

## Non-Blocking Errors

These should not stop execution - log and continue:
- Git commit failures
- Metric collection failures
- Non-critical logging failures
- Team mode degradation (falls back gracefully)

Report at end of operation.
