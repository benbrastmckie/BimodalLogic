# Research Report: Task #431

**Task**: WezTerm tab color notification for Claude Code input needed
**Date**: 2026-01-12
**Focus**: WezTerm tab color notifications, terminal escape sequences for tab styling, Claude Code hooks system for detecting input-needed state, NixOS dotfiles configuration for WezTerm

## Summary

This research identifies a complete solution for WezTerm tab color notifications when Claude Code needs user input. The approach combines Claude Code's Notification hooks system with WezTerm's user variable escape sequences (OSC 1337) and the `format-tab-title` Lua event handler. The user's existing NixOS dotfiles at `~/.dotfiles/config/wezterm.lua` already have a working `format-tab-title` handler that can be extended to support this feature.

## Findings

### 1. Claude Code Hooks System

Claude Code provides a hooks system that executes shell commands at specific lifecycle points. The relevant hooks for detecting "input needed" state are:

**Notification Hook Types**:
- `permission_prompt` - Triggered when Claude needs permission to use a tool
- `idle_prompt` - Triggered when Claude awaits user input (after 60+ seconds idle)

**Stop Hook**:
- Fires when Claude finishes responding or pauses between operations
- Useful for general "task complete" notifications

**Configuration Location**: `~/.claude/settings.json` (user-level, applies to all projects)

**Configuration Format**:
```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "permission_prompt|idle_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/notification-script.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/completion-script.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

**Key Details**:
- `$CLAUDE_PROJECT_DIR` environment variable available in hooks
- Hooks receive JSON via stdin with session information
- Default timeout is 60 seconds, configurable per command
- Multiple hooks run in parallel

**References**:
- [Claude Code Hooks Documentation](https://code.claude.com/docs/en/hooks)
- [alexop.dev Notification Hooks Guide](https://alexop.dev/posts/claude-code-notification-hooks/)
- [Desktop Notifications Guide](https://kane.mx/posts/2025/claude-code-notification-hooks/)

### 2. WezTerm User Variables and Escape Sequences

WezTerm supports OSC 1337 escape sequences for setting user variables associated with terminal panes. These variables can be read by Lua event handlers to customize tab appearance.

**Setting User Variables from Shell**:
```bash
# Basic format (value must be base64 encoded)
printf "\033]1337;SetUserVar=%s=%s\007" "VAR_NAME" "$(echo -n 'value' | base64)"

# Helper function from WezTerm shell integration
__wezterm_set_user_var() {
  if hash base64 2>/dev/null ; then
    if [[ -z "${TMUX}" ]] ; then
      printf "\033]1337;SetUserVar=%s=%s\007" "$1" "$(echo -n "$2" | base64)"
    else
      # tmux passthrough
      printf "\033Ptmux;\033\033]1337;SetUserVar=%s=%s\007\033\\" "$1" "$(echo -n "$2" | base64)"
    fi
  fi
}
```

**Events Triggered When User Var Changes**:
- `user-var-changed` - Fires immediately when variable is set/changed
- `update-status` - Allows status bar updates
- Tab bar automatically updates, triggering `format-tab-title`

**Accessing User Variables in Lua**:
```lua
-- In format-tab-title handler
local claude_status = tab.active_pane.user_vars.CLAUDE_STATUS

-- In user-var-changed handler
wezterm.on('user-var-changed', function(window, pane, name, value)
  if name == "CLAUDE_STATUS" then
    -- React to status change
  end
end)
```

**References**:
- [WezTerm user-var-changed Event](https://wezterm.org/config/lua/window-events/user-var-changed.html)
- [WezTerm Passing Data Recipe](https://wezterm.org/recipes/passing-data.html)
- [WezTerm Shell Integration](https://wezterm.org/shell-integration.html)
- [WezTerm get_user_vars](https://wezterm.org/config/lua/pane/get_user_vars.html)

### 3. WezTerm format-tab-title Event

The `format-tab-title` event allows customizing tab appearance based on pane state. The user's existing configuration already uses this event.

**Current Implementation** (`~/.dotfiles/config/wezterm.lua`, lines 202-220):
```lua
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local edge_background = '#1a1a1a'
  local background = tab.is_active and '#3a3a3a' or '#202020'
  local foreground = tab.is_active and '#d0d0d0' or '#808080'

  local title = tostring(tab.tab_index + 1)

  local separator = tab.tab_index < #tabs - 1 and '|' or ''

  return {
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = ' ' .. title .. ' ' },
    { Background = { Color = edge_background } },
    { Foreground = { Color = '#404040' } },
    { Text = separator },
  }
end)
```

**Built-in Activity Detection**:
WezTerm provides `has_unseen_output` property on panes:
```lua
for _, pane in ipairs(tab.panes) do
  if pane.has_unseen_output then
    -- Tab has new output since losing focus
  end
end
```

**References**:
- [WezTerm format-tab-title](https://wezterm.org/config/lua/window-events/format-tab-title.html)
- [GitHub Discussion: Tab Activity Indicator](https://github.com/wezterm/wezterm/discussions/796)

### 4. Fish Shell Integration

The user's fish config at `~/.dotfiles/config/config.fish` is minimal. WezTerm's official shell integration does not include fish shell support, so a custom function will need to be created.

**Fish Function for Setting WezTerm User Variables**:
```fish
function __wezterm_set_user_var
  if command -q base64
    printf "\033]1337;SetUserVar=%s=%s\007" $argv[1] (echo -n $argv[2] | base64)
  end
end
```

### 5. NixOS Dotfiles Configuration

**Relevant Files**:
- WezTerm config: `~/.dotfiles/config/wezterm.lua` (symlinked to `~/.config/wezterm/wezterm.lua`)
- Fish config: `~/.dotfiles/config/config.fish` (symlinked to `~/.config/fish/config.fish`)
- Home Manager: `~/.dotfiles/home.nix` (manages symlinks via `home.file`)

**WezTerm Installation**: Installed via home.nix packages (line 155: `wezterm`)

**Configuration Symlink** (home.nix line 628):
```nix
".config/wezterm/wezterm.lua".source = ./config/wezterm.lua;
```

### 6. Alternative Approaches Considered

**Bell Event**: WezTerm's bell event can supplement notifications but doesn't alter default bell handling. Less suitable than user variables for persistent state.

**has_unseen_output**: Built-in property for detecting output in background tabs. Good for general activity but cannot distinguish Claude Code specifically.

**OSC 9/777 Notifications**: System toast notifications. Works but requires additional extension for VSCode Terminal Notification. Better suited for desktop alerts than tab colors.

## Recommendations

### Primary Approach: User Variables + format-tab-title

1. **Create notification hook script** that sets a WezTerm user variable when Claude needs input
2. **Extend format-tab-title** in wezterm.lua to check for the user variable and apply distinctive tab coloring
3. **Create cleanup mechanism** to clear the variable when user provides input (using fish prompt integration or session management)

### Recommended Color Scheme

Based on user's existing color scheme in wezterm.lua:
- Normal inactive tab: `#202020` (current)
- Normal active tab: `#3a3a3a` (current)
- Claude needs input (inactive): `#e5b566` (amber/yellow from user's palette)
- Claude needs input (active): `#ac4142` (red from user's palette)

### Implementation Architecture

```
Claude Code Notification Hook
         |
         v
~/.claude/hooks/wezterm-notify.sh
         |
         | printf "\033]1337;SetUserVar=CLAUDE_STATUS=%s\007" "needs_input"
         v
WezTerm user-var-changed event (triggers tab bar update)
         |
         v
format-tab-title event handler
         |
         | Check tab.active_pane.user_vars.CLAUDE_STATUS
         v
Tab styled with amber/red background if CLAUDE_STATUS == "needs_input"
```

## Next Steps

1. Create `~/.claude/settings.json` with Notification hooks configuration
2. Create notification script at `~/.claude/hooks/wezterm-notify.sh`
3. Add fish function `__wezterm_set_user_var` to config.fish
4. Extend wezterm.lua `format-tab-title` handler to check CLAUDE_STATUS user variable
5. Add cleanup mechanism (optional fish prompt hook or manual /clear command)
6. Test with Claude Code in neovim terminal

## References

### WezTerm Documentation
- [format-tab-title Event](https://wezterm.org/config/lua/window-events/format-tab-title.html)
- [user-var-changed Event](https://wezterm.org/config/lua/window-events/user-var-changed.html)
- [Passing Data from Pane to Lua](https://wezterm.org/recipes/passing-data.html)
- [Shell Integration](https://wezterm.org/shell-integration.html)
- [pane:get_user_vars()](https://wezterm.org/config/lua/pane/get_user_vars.html)
- [Bell Event](https://wezterm.org/config/lua/window-events/bell.html)
- [Escape Sequences](https://wezterm.org/escape-sequences.html)
- [GitHub Discussion: Tab Activity Indicator](https://github.com/wezterm/wezterm/discussions/796)

### Claude Code Documentation
- [Hooks Reference](https://code.claude.com/docs/en/hooks)
- [alexop.dev: Claude Code Notification Hooks](https://alexop.dev/posts/claude-code-notification-hooks/)
- [Desktop Notifications for Claude Code](https://kane.mx/posts/2025/claude-code-notification-hooks/)
- [Martin Hjartmyr: Terminal Notifications](https://martin.hjartmyr.se/articles/claude-code-terminal-notifications/)

### Shell Integration
- [WezTerm Shell Integration Script (GitHub)](https://github.com/wezterm/wezterm/blob/main/assets/shell-integration/wezterm.sh)
