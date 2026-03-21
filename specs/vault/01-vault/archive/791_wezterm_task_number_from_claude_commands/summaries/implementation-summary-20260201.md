# Implementation Summary: Task #791

**Completed**: 2026-02-01
**Duration**: ~45 minutes

## Overview

Extended WezTerm task number integration to work when Claude Code runs inside Neovim. The implementation adds Neovim-side OSC 1337 emission that monitors Claude Code terminal buffers and updates the WezTerm tab title with the task number when `/research N`, `/plan N`, `/implement N`, or `/revise N` commands are detected.

## Changes Made

### 1. Created WezTerm OSC Module (`neotex/lib/wezterm.lua`)

A new Lua module providing OSC 1337 SetUserVar emission functions:

- `emit_user_var(name, value)` - Generic OSC 1337 SetUserVar emission with base64 encoding
- `clear_user_var(name)` - Clear a user variable
- `set_task_number(task_number)` - Convenience method for TASK_NUMBER
- `clear_task_number()` - Clear TASK_NUMBER
- `is_available()` - Check if WezTerm integration is available

The module includes a pure Lua base64 encoder (no external dependencies) and properly guards against non-WezTerm environments.

### 2. Added Claude Code Terminal Monitor (`neotex/config/autocmds.lua`)

Extended the existing autocmds configuration with:

- **TermOpen autocmd**: Detects Claude Code terminal buffers by name pattern
- **Buffer attachment**: Uses `nvim_buf_attach` to monitor terminal content changes
- **Pattern parsing**: Case-insensitive matching for `/research N`, `/plan N`, `/implement N`, `/revise N`
- **Debouncing**: 100ms timer to prevent rapid emissions during typing
- **Buffer-local tracking**: Independent state for each Claude Code terminal
- **Cleanup**: Proper timer cancellation and state cleanup on buffer close

## Files Modified

| File | Change |
|------|--------|
| `~/.config/nvim/lua/neotex/lib/wezterm.lua` | Created new OSC 1337 emission module |
| `~/.config/nvim/lua/neotex/config/autocmds.lua` | Added Claude Code terminal monitoring |

## Architecture

```
WezTerm Tab Title Update Flow (from Neovim)
-------------------------------------------

User types /research 791 in Claude Code terminal
    |
    v
TermOpen autocmd detects Claude Code buffer
    |
    v
nvim_buf_attach monitors buffer changes
    |
    v
on_lines callback parses changed lines
    |
    v
parse_task_number() extracts task number
    |
    v
update_task_number() with 100ms debounce
    |
    v
wezterm.set_task_number() emits OSC 1337
    |
    v
WezTerm receives SetUserVar=TASK_NUMBER
    |
    v
format-tab-title handler appends #791 to title
```

## Coexistence with Shell Hook

This implementation works alongside the existing `wezterm-task-number.sh` shell hook:

| Context | Mechanism |
|---------|-----------|
| Standalone Claude Code | Shell hook via `CLAUDE_USER_PROMPT` env var |
| Claude Code in Neovim | Neovim monitor via `nvim_buf_attach` |

Both mechanisms set the same `TASK_NUMBER` user variable, so they coexist without conflict. The Neovim monitor ensures reliable operation when the shell hook's TTY routing may not work correctly for embedded terminals.

## Verification Notes

Manual verification required:
1. Open WezTerm, launch Neovim
2. Start Claude Code with `:ClaudeCode`
3. Enter `/research 791`
4. Check tab title shows `#791`
5. Enter different command, observe title updates/clears
6. Close terminal, verify clean state

## Related Tasks

- Task 788: WezTerm tab coloring on Claude completion (CLAUDE_STATUS)
- Task 789: WezTerm tab title project and task number (TASK_NUMBER hook)
- Task 790: Neovim WezTerm OSC 7 tab title (established OSC emission pattern)
