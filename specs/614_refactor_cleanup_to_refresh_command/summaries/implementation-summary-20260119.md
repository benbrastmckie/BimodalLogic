# Implementation Summary: Task #614

**Task**: Refactor /cleanup to /refresh Command
**Status**: Finished
**Date**: 2026-01-19
**Duration**: ~1.5 hours

## Changes Made

Refactored the /cleanup command to /refresh with a simplified two-mode interface. The original four-mode interface (--status, --dry-run, default, --force) was consolidated into two modes: default mode shows status and prompts via AskUserQuestion, and --force mode immediately terminates orphaned processes.

### Key Changes

1. **Fixed script bug**: Replaced `((var++))` with `var=$((var + 1))` to prevent early exit when `set -euo pipefail` is enabled
2. **Renamed all files**: cleanup.md -> refresh.md, skill-cleanup -> skill-refresh, etc.
3. **Simplified interface**: Removed --status and --dry-run flags
4. **Added AskUserQuestion integration**: Skill now uses Claude's AskUserQuestion tool for interactive confirmation
5. **Updated documentation**: CLAUDE.md, install scripts, systemd files, and templates

## Files Modified

### Renamed Files
- `.claude/commands/cleanup.md` -> `.claude/commands/refresh.md`
- `.claude/skills/skill-cleanup/SKILL.md` -> `.claude/skills/skill-refresh/SKILL.md`
- `.claude/scripts/claude-cleanup.sh` -> `.claude/scripts/claude-refresh.sh`
- `.claude/systemd/claude-cleanup.service` -> `.claude/systemd/claude-refresh.service`
- `.claude/systemd/claude-cleanup.timer` -> `.claude/systemd/claude-refresh.timer`

### Updated Files
- `.claude/CLAUDE.md` - Session Maintenance section, skill-to-agent mapping
- `.claude/scripts/install-aliases.sh` - Reduced from 4 to 2 aliases, handles migration
- `.claude/scripts/install-systemd-timer.sh` - Updated paths, handles old file cleanup
- `.claude/templates/settings.json` - Updated command reference

## New Interface

| Command | Description |
|---------|-------------|
| `/refresh` | Show status and prompt for confirmation |
| `/refresh --force` | Terminate orphaned processes immediately |

### Shell Aliases (after reinstall)
- `claude-refresh` - Show status and prompt
- `claude-refresh-force` - Terminate immediately

## Technical Details

### Bug Fix
The original script used `((terminated++))` which returns exit code 1 when incrementing from 0 in bash arithmetic context. Combined with `set -e`, this caused the script to exit after the first successful termination. Fixed by using `terminated=$((terminated + 1))` instead.

### AskUserQuestion Integration
The skill now uses AskUserQuestion for interactive confirmation instead of shell's `read -p` which doesn't work in Claude Code's environment:
```json
{
  "question": "Terminate these orphaned processes?",
  "header": "Confirm Cleanup",
  "options": [
    {"label": "Yes, terminate", "description": "Kill orphaned processes and reclaim memory"},
    {"label": "Cancel", "description": "Exit without changes"}
  ]
}
```

## Verification

- Script help output works correctly
- Script default mode displays process list
- Systemd files pass syntax verification
- No unexpected cleanup references remain in source files
- All renamed files exist in correct locations

## Migration Notes

For users with existing aliases or systemd timers:
1. Run `install-aliases.sh --uninstall` then `install-aliases.sh` to update aliases
2. Run `install-systemd-timer.sh --uninstall` then `install-systemd-timer.sh` to update timer
3. The uninstall scripts automatically handle both old (cleanup) and new (refresh) naming
