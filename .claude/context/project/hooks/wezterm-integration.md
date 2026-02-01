# WezTerm Tab Integration

This document describes the WezTerm terminal integration for Claude Code, providing tab title updates and visual notifications.

## Overview

The integration enables:
- Task number display in WezTerm tab titles (e.g., `ProofChecker #792`)
- Amber highlighting for tabs awaiting Claude Code input
- Automatic notification clearing when the user views or responds

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│ WezTerm Tab Title                                               │
│ "1 ProofChecker #792"                                           │
└─────────────────────────────────────────────────────────────────┘
                    ▲                           ▲
                    │                           │
         ┌─────────┴─────────┐       ┌─────────┴─────────┐
         │ OSC 7             │       │ OSC 1337          │
         │ file://host/path  │       │ SetUserVar=...    │
         └─────────┬─────────┘       └─────────┬─────────┘
                   │                           │
    ┌──────────────┴──────────┐    ┌──────────┴──────────────┐
    │ Shell / Neovim          │    │ Claude Code Hooks        │
    │                         │    │                          │
    │ Directory updates from  │    │ wezterm-task-number.sh   │
    │ shells and Neovim       │    │ wezterm-notify.sh        │
    │ autocmds                │    │ wezterm-clear-status.sh  │
    └─────────────────────────┘    └──────────────────────────┘
```

## Hook Files

### wezterm-notify.sh

**Path**: `.claude/hooks/wezterm-notify.sh`
**Hook Event**: `Stop`
**Purpose**: Set amber tab notification when Claude awaits input

Sets `CLAUDE_STATUS=needs_input` via OSC 1337 to the pane TTY. The WezTerm `format-tab-title` handler reads this variable and applies amber background (#e5b566) to inactive tabs.

### wezterm-clear-status.sh

**Path**: `.claude/hooks/wezterm-clear-status.sh`
**Hook Event**: `UserPromptSubmit`
**Purpose**: Clear notification when user submits a prompt

Clears `CLAUDE_STATUS` by setting it to an empty value, restoring normal tab appearance.

### wezterm-task-number.sh

**Path**: `.claude/hooks/wezterm-task-number.sh`
**Hook Event**: `UserPromptSubmit`
**Purpose**: Extract and display task number in tab title

Parses `CLAUDE_USER_PROMPT` environment variable for patterns:
- `/research N`
- `/plan N`
- `/implement N`
- `/revise N`

Sets `TASK_NUMBER` user variable with the extracted number.

## User Variables

| Variable | Purpose | Values |
|----------|---------|--------|
| `TASK_NUMBER` | Task number for tab title | Numeric string (e.g., "792") |
| `CLAUDE_STATUS` | Notification state | "needs_input" or empty |

## Configuration

### Disabling Notifications

Set environment variable before starting Claude Code:

```bash
export WEZTERM_NOTIFY_ENABLED=0
```

### Hook Registration

Hooks are registered in `.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "bash .claude/hooks/wezterm-notify.sh 2>/dev/null || echo '{}'"
      }]
    }],
    "UserPromptSubmit": [{
      "matcher": "*",
      "hooks": [
        {
          "type": "command",
          "command": "bash .claude/hooks/wezterm-task-number.sh 2>/dev/null || echo '{}'"
        },
        {
          "type": "command",
          "command": "bash .claude/hooks/wezterm-clear-status.sh 2>/dev/null || echo '{}'"
        }
      ]
    }]
  }
}
```

## Technical Details

### TTY Access Pattern

Claude Code hooks run with redirected stdio (stdout is a socket to Claude). To emit OSC sequences visible to WezTerm, hooks must write directly to the pane's TTY:

```bash
# Get TTY path via WezTerm CLI
PANE_TTY=$(wezterm cli list --format=json | \
  jq -r ".[] | select(.pane_id == $WEZTERM_PANE) | .tty_name")

# Write escape sequence to TTY
printf '\033]1337;SetUserVar=NAME=base64value\007' > "$PANE_TTY"
```

### OSC Escape Sequence Format

| Sequence | Format | Purpose |
|----------|--------|---------|
| OSC 7 | `ESC ] 7 ; file://hostname/path BEL` | Directory update |
| OSC 1337 | `ESC ] 1337 ; SetUserVar=name=base64value BEL` | User variable |

Values are base64-encoded in OSC 1337 to handle special characters safely.

### WezTerm Handler Location

The `format-tab-title` and `update-status` handlers that consume these variables are in `~/.dotfiles/config/wezterm.lua`.

## Integration with Neovim

When Claude Code runs inside Neovim (via claude-code.nvim), the Neovim autocmds in `~/.config/nvim/lua/neotex/config/autocmds.lua` provide parallel integration:

- **OSC 7**: Neovim emits directory updates on DirChanged, VimEnter, BufEnter
- **Task Number**: Neovim monitors Claude terminal buffers and sets TASK_NUMBER via `neotex.lib.wezterm`

Both mechanisms can run simultaneously without conflict since they set the same user variables.

## Related Documentation

- **WezTerm configuration**: `~/.dotfiles/docs/terminal.md`
- **Neovim integration**: `~/.config/nvim/lua/neotex/config/README.md`
- **Hook source files**: `.claude/hooks/wezterm-*.sh`
