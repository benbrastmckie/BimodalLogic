# Research Report: Task #431

**Task**: WezTerm tab color notification for Claude Code input needed
**Date**: 2026-01-30
**Focus**: TTS hook compatibility, WezTerm user variables from Stop hooks, preventing conflicts between TTS and tab notifications

## Summary

This research extends the prior findings (research-001.md) by analyzing the existing TTS notification system and determining how to implement WezTerm tab color notifications that coexist without conflict. The key insight is that both notifications should be triggered from the same Stop hook event but operate independently - TTS provides audible notification while tab coloring provides visual indication. The implementation should follow the same pattern as tts-notify.sh: checking for WezTerm context, using cooldown logic, and returning empty JSON on success.

## Findings

### 1. Existing TTS Hook Architecture

The TTS notification hook at `.claude/hooks/tts-notify.sh` provides a well-tested pattern:

**Key Design Elements**:
- Registered in `.claude/settings.json` under `Stop` hooks with matcher `*`
- Uses environment variables for configuration (`TTS_ENABLED`, `TTS_COOLDOWN`)
- Checks for `$WEZTERM_PANE` environment variable to detect WezTerm context
- Uses `wezterm cli list --format=json` to get tab information
- Has cooldown logic via timestamp file at `/tmp/claude-tts-last-notify`
- Returns `{}` (empty JSON) for success, matching Claude Code hook expectations
- Runs in background with timeout to prevent blocking

**Integration Pattern**:
```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/post-command.sh 2>/dev/null || echo '{}'"
          },
          {
            "type": "command",
            "command": "bash .claude/hooks/tts-notify.sh 2>/dev/null || echo '{}'"
          }
        ]
      }
    ]
  }
}
```

### 2. Why Stop Hook (Not Notification Hook)

The prior research suggested using `Notification` hooks with `permission_prompt` and `idle_prompt` matchers. However, after reviewing the current TTS implementation:

**Stop Hook Advantages**:
- Already tested and working for TTS in the current setup
- Fires for all completion events, not just specific notification types
- Simpler - one hook covers all "needs attention" scenarios
- Consistent with existing codebase patterns

**Notification Hook Considerations**:
- More granular (can distinguish permission_prompt vs idle_prompt)
- Known latency issues reported in 2026 (seconds of delay)
- Not currently used in this project's hooks configuration

**Recommendation**: Use Stop hook for tab coloring, same as TTS, for consistency and proven reliability.

### 3. WezTerm User Variable Implementation

The WezTerm tab color notification can be implemented using OSC 1337 SetUserVar escape sequences. Based on the WezTerm documentation:

**Setting User Variables**:
```bash
# Set a user variable (value must be base64 encoded)
printf "\033]1337;SetUserVar=%s=%s\007" "CLAUDE_STATUS" "$(echo -n 'needs_input' | base64)"

# Clear the user variable
printf "\033]1337;SetUserVar=%s=%s\007" "CLAUDE_STATUS" "$(echo -n '' | base64)"
```

**Shell Helper Function**:
```bash
__wezterm_set_user_var() {
  if hash base64 2>/dev/null; then
    if [[ -z "${TMUX}" ]]; then
      printf "\033]1337;SetUserVar=%s=%s\007" "$1" "$(echo -n "$2" | base64)"
    else
      # tmux passthrough
      printf "\033Ptmux;\033\033]1337;SetUserVar=%s=%s\007\033\\" "$1" "$(echo -n "$2" | base64)"
    fi
  fi
}
```

**Accessing in WezTerm Lua**:
```lua
-- In format-tab-title handler
local claude_status = tab.active_pane.user_vars.CLAUDE_STATUS
```

### 4. WezTerm format-tab-title Modification

The existing `format-tab-title` handler in `~/.dotfiles/config/wezterm.lua` (lines 202-220) needs extension:

**Current Implementation**:
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

**Proposed Extension**:
```lua
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local edge_background = '#1a1a1a'
  local background = tab.is_active and '#3a3a3a' or '#202020'
  local foreground = tab.is_active and '#d0d0d0' or '#808080'

  -- Check for Claude Code notification status
  local claude_status = tab.active_pane.user_vars.CLAUDE_STATUS
  if claude_status == 'needs_input' then
    -- Amber/yellow for inactive tab needing attention
    if not tab.is_active then
      background = '#e5b566'  -- Amber from user's color scheme
      foreground = '#151515'  -- Dark text for contrast
    else
      -- Active tab still shows notification with subtle indicator
      background = '#6c5333'  -- Darker amber for active tab
      foreground = '#e5b566'  -- Amber text
    end
  end

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

### 5. Non-Conflict Strategy

The TTS and WezTerm tab notifications operate on completely different channels:

| Aspect | TTS Notification | Tab Color Notification |
|--------|------------------|------------------------|
| Output | Audio (speakers) | Visual (terminal UI) |
| Mechanism | piper TTS -> aplay | OSC escape sequence |
| State Persistence | None (one-shot) | User variable persists until cleared |
| Cooldown | 60 seconds default | Should use separate cooldown |
| Dependencies | piper-tts, aplay | base64 (standard) |

**No Conflict Expected Because**:
1. TTS writes to audio device, tab color writes escape sequence to terminal
2. Both run in parallel (Claude Code hook parallelization)
3. Neither depends on the other's output
4. Can share cooldown file or use separate files

### 6. Clearing Tab Notification

The tab color persists until the user variable is cleared. Options for clearing:

**Option A: SessionStart Hook** (Recommended)
When Claude resumes interaction, clear the status:
```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/wezterm-clear-status.sh 2>/dev/null || echo '{}'"
          }
        ]
      }
    ]
  }
}
```

**Option B: UserPromptSubmit Hook**
Clear when user submits a new prompt:
```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/wezterm-clear-status.sh 2>/dev/null || echo '{}'"
          }
        ]
      }
    ]
  }
}
```

**Option C: Fish Shell Prompt Integration**
Add to fish prompt to clear on each prompt display (most aggressive).

**Recommendation**: Use both SessionStart (for session resume) and UserPromptSubmit (for new prompts) to ensure the status is cleared when user interacts.

### 7. Implementation Files Summary

**New Files**:
1. `.claude/hooks/wezterm-notify.sh` - Sets CLAUDE_STATUS user variable on Stop
2. `.claude/hooks/wezterm-clear-status.sh` - Clears CLAUDE_STATUS user variable

**Modified Files**:
1. `.claude/settings.json` - Add new hooks to Stop, SessionStart, and UserPromptSubmit
2. `~/.dotfiles/config/wezterm.lua` - Extend format-tab-title handler

**Optional New File**:
3. `~/.dotfiles/config/config.fish` - Add `__wezterm_set_user_var` function (for potential other uses)

## Recommendations

### Primary Approach

1. **Create wezterm-notify.sh** following the tts-notify.sh pattern:
   - Check `WEZTERM_PANE` environment variable
   - Use independent cooldown file (`/tmp/claude-wezterm-last-notify`)
   - Set `CLAUDE_STATUS=needs_input` via OSC 1337 escape sequence
   - Return `{}` on success

2. **Create wezterm-clear-status.sh**:
   - Check `WEZTERM_PANE` environment variable
   - Clear `CLAUDE_STATUS` via OSC 1337 escape sequence
   - Return `{}` on success

3. **Update .claude/settings.json**:
   - Add wezterm-notify.sh to Stop hooks (alongside tts-notify.sh)
   - Add wezterm-clear-status.sh to SessionStart hooks
   - Add wezterm-clear-status.sh to UserPromptSubmit hooks

4. **Update wezterm.lua**:
   - Add CLAUDE_STATUS check to format-tab-title handler
   - Use amber/yellow colors from existing color scheme for "needs input" state

### Color Scheme (From User's Palette)

Based on the existing wezterm.lua colors:
- **Needs Input (Inactive Tab)**: Background `#e5b566` (yellow), Foreground `#151515` (black)
- **Needs Input (Active Tab)**: Background `#6c5333` (dark amber), Foreground `#e5b566` (yellow)
- **Normal Inactive**: Background `#202020`, Foreground `#808080` (unchanged)
- **Normal Active**: Background `#3a3a3a`, Foreground `#d0d0d0` (unchanged)

### Configuration Variables

For consistency with TTS, support environment variables:
- `WEZTERM_NOTIFY_ENABLED` - Set to "0" to disable (default: "1")
- `WEZTERM_NOTIFY_COOLDOWN` - Seconds between notifications (default: 0, no cooldown for visual)

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Tab color persists after user responds | Clear on SessionStart and UserPromptSubmit hooks |
| WezTerm not available | Check `$WEZTERM_PANE` before sending escape sequences |
| Escape sequence causes issues in other terminals | Guard with `$WEZTERM_PANE` check |
| Concurrent writes from TTS and tab hooks | No issue - different output channels |
| User variable not visible in format-tab-title | Documented WezTerm behavior, should work with Lua access pattern |

## References

### WezTerm Documentation
- [format-tab-title Event](https://wezterm.org/config/lua/window-events/format-tab-title.html)
- [user-var-changed Event](https://wezterm.org/config/lua/window-events/user-var-changed.html)
- [Passing Data from Pane to Lua](https://wezterm.org/recipes/passing-data.html)
- [pane:get_user_vars()](https://wezterm.org/config/lua/pane/get_user_vars.html)
- [Escape Sequences](https://wezterm.org/escape-sequences.html)

### Claude Code Documentation
- [Hooks Reference](https://code.claude.com/docs/en/hooks)
- [Get Notified When Claude Code Finishes](https://alexop.dev/posts/claude-code-notification-hooks/)

### Existing Implementation
- `.claude/hooks/tts-notify.sh` - Pattern for Stop hook implementation
- `~/.dotfiles/config/wezterm.lua` - Current WezTerm configuration

## Next Steps

1. Create `/plan 431` to define implementation phases based on this research
2. Phase 1: Create wezterm-notify.sh and wezterm-clear-status.sh scripts
3. Phase 2: Update .claude/settings.json with new hook registrations
4. Phase 3: Update wezterm.lua format-tab-title handler
5. Phase 4: Test in WezTerm with Claude Code neovim plugin
