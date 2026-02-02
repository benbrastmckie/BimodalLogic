# Research Report: Task #802

**Task**: Fix WezTerm tab task number clearing on Neovim exit and /clear command
**Date**: 2026-02-01
**Focus**: WezTerm task number clearing on Neovim exit and /clear command

## Summary

The task number persistence issue has two separate root causes:
1. **Neovim exit**: The `BufDelete`/`BufWipeout` autocmds in `autocmds.lua` only fire when the Claude terminal buffer is explicitly deleted, but when Neovim exits, `VimLeavePre` in toggleterm.lua force-deletes all terminal buffers without triggering the cleanup callback for Claude terminals.
2. **/clear command**: Claude Code's `/clear` command fires a `SessionStart` hook with `source: "clear"`, but the current implementation only has a `UserPromptSubmit` hook for the task number script, which does NOT fire on `/clear`.

## Findings

### Current Architecture

The task number system consists of three components:

1. **Shell hook** (`.claude/hooks/wezterm-task-number.sh`):
   - Triggered by `UserPromptSubmit` hook
   - Sets `TASK_NUMBER` for workflow commands (`/research N`, `/plan N`, `/implement N`, `/revise N`)
   - Clears `TASK_NUMBER` for non-workflow commands
   - Uses OSC 1337 escape sequence via pane TTY

2. **Neovim monitor** (`~/.config/nvim/lua/neotex/config/autocmds.lua`):
   - Tracks Claude terminal buffers via `TermOpen`
   - Clears `TASK_NUMBER` on `BufDelete`/`BufWipeout` via `wezterm.clear_task_number()`
   - Emits OSC 1337 via `io.write()` to stdout

3. **WezTerm config** (`~/.dotfiles/config/wezterm.lua`):
   - `format-tab-title` handler reads `TASK_NUMBER` user variable
   - Displays `#N` suffix in tab title when set

### Root Cause Analysis

#### Issue 1: Neovim Exit Does Not Clear TASK_NUMBER

**Problem flow**:
```
User closes Neovim (`:q`, `:qa`, or window close)
    |
    v
VimLeavePre fires (from toggleterm.lua)
    |
    v
Force-deletes all terminal buffers via nvim_buf_delete(bufnr, { force = true })
    |
    v
BufDelete autocmd in autocmds.lua fires... BUT
    |
    v
The callback checks claude_terminal_buffers[ev.buf], but the buffer may
already be invalid by the time the callback runs due to force deletion
```

**Root cause**: The `VimLeavePre` autocmd in toggleterm.lua (line 32-42) uses `pcall(vim.api.nvim_buf_delete, bufnr, { force = true })` which may not trigger the `BufDelete` autocmd properly, OR the Lua state is being cleaned up and the wezterm module cannot emit OSC sequences during exit.

**Evidence**: The `wezterm.clear_task_number()` function uses `io.write()` and `io.flush()`, but during Neovim exit, the stdio handles may already be closed or redirected.

#### Issue 2: /clear Command Does Not Clear TASK_NUMBER

**Problem**: According to Claude Code documentation ([Hooks reference](https://code.claude.com/docs/en/hooks)):

> The matcher value corresponds to how the session was initiated:
> | Matcher   | When it fires                          |
> | `clear`   | `/clear`                               |

The `/clear` command fires a `SessionStart` hook with `source: "clear"`, NOT a `UserPromptSubmit` hook.

**Current hook configuration** (`.claude/settings.json`):
```json
"UserPromptSubmit": [
  {
    "matcher": "*",
    "hooks": [
      { "type": "command", "command": "bash .claude/hooks/wezterm-task-number.sh" },
      { "type": "command", "command": "bash .claude/hooks/wezterm-clear-status.sh" }
    ]
  }
]
```

There is NO `SessionStart` hook configured to clear `TASK_NUMBER` when `/clear` is run.

### Evidence from Documentation

From the Claude Code hooks documentation:

1. **SessionStart source values**:
   - `startup` - New session
   - `resume` - `--resume`, `--continue`, or `/resume`
   - `clear` - `/clear`
   - `compact` - Auto or manual compaction

2. **SessionEnd reason values** (also relevant):
   - `clear` - Session cleared with `/clear` command
   - Other reasons like `logout`, `prompt_input_exit`, etc.

Both `SessionStart` (with source="clear") and `SessionEnd` (with reason="clear") fire when `/clear` is run, but neither currently has a hook to clear `TASK_NUMBER`.

### OSC 7 (Directory) Behavior

OSC 7 is independent of `TASK_NUMBER`. The tab title shows:
- `{tab_index} {directory_name} [#TASK_NUMBER]`

When `TASK_NUMBER` is cleared, the tab correctly shows just the directory. The OSC 7 sequence is emitted by:
1. Shell's precmd/preexec hooks
2. Neovim's `DirChanged`, `VimEnter`, and `BufEnter` autocmds

OSC 7 is working correctly. The issue is solely with `TASK_NUMBER` not being cleared.

## Recommendations

### Fix 1: Add SessionStart Hook for /clear

Add a `SessionStart` hook that clears `TASK_NUMBER` when `source: "clear"`:

```json
"SessionStart": [
  {
    "matcher": "clear",
    "hooks": [
      { "type": "command", "command": "bash .claude/hooks/wezterm-clear-task-number.sh" }
    ]
  }
]
```

Create a new script `.claude/hooks/wezterm-clear-task-number.sh` that unconditionally clears `TASK_NUMBER`.

### Fix 2: Add VimLeavePre Autocmd for TASK_NUMBER Clearing

Add a `VimLeavePre` autocmd in `autocmds.lua` that clears `TASK_NUMBER` when any Claude terminal buffer exists:

```lua
api.nvim_create_autocmd('VimLeavePre', {
  callback = function()
    for bufnr, _ in pairs(claude_terminal_buffers) do
      wezterm.clear_task_number()
      break  -- Only need to clear once
    end
  end,
  desc = 'WezTerm: Clear task number when Neovim exits',
})
```

This approach ensures the OSC sequence is emitted BEFORE terminal buffers are force-deleted.

### Fix 3 (Alternative): Use SessionEnd Hook

Alternatively, add a `SessionEnd` hook with `matcher: "clear"` to clear `TASK_NUMBER`:

```json
"SessionEnd": [
  {
    "matcher": "clear",
    "hooks": [
      { "type": "command", "command": "bash .claude/hooks/wezterm-clear-task-number.sh" }
    ]
  }
]
```

This would fire when the session ends due to `/clear`. However, `SessionStart` is more appropriate since the session is restarting, not ending.

## Dependencies

- Task 795: Established the current task number persistence architecture
- Neovim wezterm module: `~/.config/nvim/lua/neotex/lib/wezterm.lua`
- Shell hook: `.claude/hooks/wezterm-task-number.sh`

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| VimLeavePre timing issues | Medium | Use synchronous OSC write before buffer deletion |
| Hook execution order | Low | SessionStart hooks run early in session lifecycle |
| TTY access during exit | Medium | Test OSC emission in VimLeavePre context |

## Next Steps

1. Create `/plan 802` to implement both fixes
2. Create new script `.claude/hooks/wezterm-clear-task-number.sh`
3. Add `SessionStart` hook with `matcher: "clear"` to settings.json
4. Add `VimLeavePre` autocmd to autocmds.lua
5. Test all scenarios: Neovim exit, `/clear`, workflow commands, non-workflow commands

## References

- [Claude Code Hooks Reference](https://code.claude.com/docs/en/hooks) - Official documentation
- Task 795 implementation: `specs/795_wezterm_tab_project_number_persistence/`
- WezTerm OSC 1337: User variables documentation
