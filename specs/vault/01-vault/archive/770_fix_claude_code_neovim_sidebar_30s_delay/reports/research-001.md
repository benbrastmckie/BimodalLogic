# Research Report: Task #770

**Task**: 770 - Fix Claude Code Neovim sidebar 30-second delay
**Started**: 2026-01-30T12:00:00Z
**Completed**: 2026-01-30T12:30:00Z
**Effort**: small
**Priority**: high
**Dependencies**: None
**Sources/Inputs**: Codebase analysis, Claude Code hooks documentation, Neovim autocommand documentation
**Artifacts**: specs/770_fix_claude_code_neovim_sidebar_30s_delay/reports/research-001.md
**Standards**: report-format.md

## Executive Summary

- Two bugs found in `claude-ready-signal.sh`: wrong Lua module path and incorrect `luaeval()` syntax
- TextChanged fallback in `terminal-state.lua` uses wrong event for terminal buffers (needs `TextChangedT`)
- The 30-second delay is caused by commands expiring in the queue (stale command timeout)

## Context & Scope

Investigated the signal path between Claude Code's SessionStart hook and Neovim's terminal-state.lua module to understand why the sidebar has a 30-second blank delay when opened from Neovim but works immediately when opened directly in terminal.

### Signal Path Architecture

```
Claude Code starts
    |
    v
SessionStart hook fires
    |
    v
.claude/settings.json calls:
  bash ~/.config/nvim/scripts/claude-ready-signal.sh
    |
    v
claude-ready-signal.sh checks $NVIM
    |
    v
nvim --server "$NVIM" --remote-expr <lua call>
    |
    v
terminal-state.lua:on_claude_ready()
    |
    v
Queued commands are flushed
```

## Findings

### Issue 1: Wrong Lua Module Path in claude-ready-signal.sh

**Location**: `~/.config/nvim/scripts/claude-ready-signal.sh` line 8

**Current (WRONG)**:
```bash
nvim --server "$NVIM" --remote-expr \
  'luaeval("require(\"neotex.plugins.ai.claude.utils.terminal-state\").on_claude_ready()")'
```

**Actual module path**: `neotex.plugins.ai.claude.claude-session.terminal-state`

**Error message** (when tested manually):
```
Error executing lua: Vim:E5108: Error executing lua [string "luaeval()"]:1:
attempt to index global 'neotex' (a nil value)
```

### Issue 2: Wrong Lua Eval Syntax for Remote Expr

**Problem**: The `luaeval()` function doesn't work correctly with `require()` from `--remote-expr`

**Testing results**:
```bash
# FAILS - luaeval with require
nvim --server "$NVIM" --remote-expr \
  'luaeval("require(\"...\").on_claude_ready()")'
# Error: attempt to index global 'neotex' (a nil value)

# WORKS - v:lua.require syntax
nvim --server "$NVIM" --remote-expr \
  'v:lua.require("neotex.plugins.ai.claude.claude-session.terminal-state").on_claude_ready()'
# Returns: vim.NIL (success)
```

### Issue 3: TextChanged vs TextChangedT for Terminal Buffers

**Location**: `terminal-state.lua` line 352

**Current (WRONG)**:
```lua
vim.api.nvim_create_autocmd("TextChanged", {
  group = ready_check_group,
  buffer = args.buf,
  -- ...
})
```

**Problem**: Neovim has a separate event `TextChangedT` specifically for terminal-mode text changes. The standard `TextChanged` event may not fire reliably in terminal buffers.

**Documentation**: From [Neovim autocmd docs](https://neovim.io/doc/user/autocmd.html):
> `TextChangedT` - After a change was made to the text in the current buffer in Terminal-mode. Otherwise the same as TextChanged.

### Issue 4: The 30-Second Timeout is a Stale Command Expiry

**Location**: `terminal-state.lua` lines 193-217

The 30-second delay isn't a hardcoded timeout - it's the staleness check for queued commands:

```lua
-- Check if command is still fresh (< 30 seconds old)
if os.time() - cmd.timestamp < 30 then
  -- send command
else
  vim.notify("Dropped stale command (>30s old)", ...)
end
```

**What happens**:
1. User opens Claude from Neovim
2. Command gets queued with timestamp
3. SessionStart hook fails silently (wrong module path/syntax)
4. TextChanged fallback doesn't fire (wrong event type for terminal)
5. 30 seconds pass, command expires
6. Eventually pattern detection succeeds via some other code path

### Verification: SessionStart Hook IS Firing

Confirmed by checking `.claude/logs/sessions.log`:
```
[2026-01-30T00:03:16+00:00] Session started
```

The `log-session.sh` hook runs successfully. The `claude-ready-signal.sh` hook runs but fails silently due to `>/dev/null 2>&1` error suppression.

### Environment Variables: $NVIM is Available

Confirmed `$NVIM` environment variable is present in hook context:
```
NVIM=/run/user/1000/nvim.1427667.0
```

## Recommendations

### Fix 1: Correct claude-ready-signal.sh (Required)

```bash
#!/usr/bin/env bash
# Claude Code SessionStart hook - signals Neovim when ready

if [ -n "$NVIM" ]; then
  # Use v:lua.require syntax (works with --remote-expr)
  # Module path: neotex.plugins.ai.claude.claude-session.terminal-state
  nvim --server "$NVIM" --remote-expr \
    'v:lua.require("neotex.plugins.ai.claude.claude-session.terminal-state").on_claude_ready()' \
    >/dev/null 2>&1
fi
```

### Fix 2: Add Debug Logging to Hook (Recommended)

```bash
#!/usr/bin/env bash
# Claude Code SessionStart hook - signals Neovim when ready

LOG_FILE="/tmp/claude-ready-signal.log"

if [ -n "$NVIM" ]; then
  echo "[$(date -Iseconds)] Attempting signal to $NVIM" >> "$LOG_FILE"

  result=$(nvim --server "$NVIM" --remote-expr \
    'v:lua.require("neotex.plugins.ai.claude.claude-session.terminal-state").on_claude_ready()' 2>&1)
  exit_code=$?

  echo "[$(date -Iseconds)] Result: $result (exit: $exit_code)" >> "$LOG_FILE"
fi
```

### Fix 3: Use TextChangedT in terminal-state.lua (Recommended)

```lua
-- Change line 352 from:
vim.api.nvim_create_autocmd("TextChanged", {

-- To (cover both modes):
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedT" }, {
```

### Fix 4: Add TermEnter as Additional Fallback (Optional)

```lua
-- Add after the TextChanged autocmd:
vim.api.nvim_create_autocmd("TermEnter", {
  group = ready_check_group,
  buffer = args.buf,
  callback = function()
    if M.is_terminal_ready(args.buf) then
      state = M.State.READY
      M.flush_queue(args.buf)
      vim.api.nvim_del_augroup_by_id(ready_check_group)
    end
  end
})
```

## Decisions

1. **Primary fix**: Correct the hook script's module path and Lua syntax
2. **Secondary fix**: Add `TextChangedT` to the fallback autocommand
3. **Debug aid**: Add temporary logging to trace signal path

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Hook script changes don't take effect immediately | Claude Code caches hooks at startup; restart required |
| Multiple Neovim instances could have stale $NVIM | Signal goes to whatever socket $NVIM points to |
| v:lua.require syntax may differ across nvim versions | Test on nvim 0.11.5 (current version) confirmed working |

## Appendix

### Files Examined
- `/home/benjamin/Projects/ProofChecker/.claude/settings.json` - Hook configuration
- `~/.config/nvim/scripts/claude-ready-signal.sh` - Signal hook script
- `~/.config/nvim/lua/neotex/plugins/ai/claude/claude-session/terminal-state.lua` - Neovim state module
- `/home/benjamin/Projects/ProofChecker/.claude/logs/sessions.log` - Hook execution log

### Manual Test Commands

```bash
# Test current (broken) syntax:
nvim --server "$NVIM" --remote-expr \
  'luaeval("require(\"neotex.plugins.ai.claude.utils.terminal-state\").on_claude_ready()")'
# Exit code: 2 (error)

# Test fixed syntax:
nvim --server "$NVIM" --remote-expr \
  'v:lua.require("neotex.plugins.ai.claude.claude-session.terminal-state").on_claude_ready()'
# Returns: vim.NIL (success)
```

### References
- [Claude Code Hooks Reference](https://code.claude.com/docs/en/hooks)
- [Neovim Autocommand Documentation](https://neovim.io/doc/user/autocmd.html)
- [GitHub Issue: Hooks not loading](https://github.com/anthropics/claude-code/issues/11544)
