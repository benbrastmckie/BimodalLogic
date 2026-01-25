# Archive Directory

This directory contains files that were previously part of the `.claude/` system but have been superseded by architectural changes.

## hooks/ - Archived 2026-01-25

### subagent-postflight.sh

**Reason for archival**: Checkpoints migrated from skills to commands (Task #676).

**Background**: This hook was created as a workaround for GitHub Issue #17351, where skill postflight code was not executing after subagents returned. The hook used marker files (`specs/.postflight-pending`) to detect when postflight operations were pending and block premature session termination.

**Replaced by**: Commands now handle all checkpoint operations (preflight, postflight, git commit) directly, eliminating the need for hooks to force skill continuation. The thin wrapper skill pattern means skills only validate inputs and invoke subagents.

## patterns/ - Archived 2026-01-25

### postflight-control.md

**Reason for archival**: Pattern no longer applicable after checkpoint migration.

**Background**: Documented the marker file protocol for coordinating postflight execution between skills and the SubagentStop hook.

**Replaced by**: Commands handle checkpoints via:
1. CHECKPOINT 1 (GATE IN): Preflight status updates
2. STAGE 2 (DELEGATE): Invoke thin wrapper skill
3. CHECKPOINT 2 (GATE OUT): Read metadata, update status, link artifacts
4. CHECKPOINT 3 (COMMIT): Git commit with session ID

## Restoration

If you need to restore these files (e.g., for debugging or rollback):

```bash
# Restore SubagentStop hook
cp .claude/archive/hooks/subagent-postflight.sh .claude/hooks/
# Re-add to settings.json "hooks" section:
# "SubagentStop": [{"matcher": "*", "hooks": [{"type": "command", "command": "bash .claude/hooks/subagent-postflight.sh 2>/dev/null || echo '{}'", "timeout": 30000}]}]

# Restore pattern
cp .claude/archive/patterns/postflight-control.md .claude/context/core/patterns/
```

## Related Documentation

- Task #676: Investigate skill registration and migrate checkpoints to commands
- Research Report: `specs/676_investigate_skill_registration_integrate_task_command/reports/research-004.md`
- `.claude/CLAUDE.md`: Updated Checkpoint-Based Execution Model section
