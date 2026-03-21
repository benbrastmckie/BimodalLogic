# Research Report: Task #788

**Task**: 788 - Improve WezTerm tab coloring for Claude Code completion
**Started**: 2026-01-31T00:00:00Z
**Completed**: 2026-01-31T00:00:00Z
**Effort**: Low (2-3 hours implementation)
**Dependencies**: None
**Sources/Inputs**:
- Codebase: `/home/benjamin/.dotfiles/config/wezterm.lua`, `.claude/hooks/wezterm-notify.sh`
- Web: WezTerm official documentation (wezterm.org)
**Artifacts**:
- `specs/788_wezterm_tab_coloring_on_claude_completion/reports/research-001.md`
**Standards**: report-format.md

## Executive Summary

- The current implementation already handles conditional coloring for inactive tabs only
- The issue is that the `CLAUDE_STATUS` user variable persists after tab activation, causing the color to reappear if the tab loses focus again
- **Solution**: Use `pane:inject_output` in the `format-tab-title` event to clear the user variable via OSC 1337 when the tab becomes active
- Alternative approach: Track active tab state in `wezterm.GLOBAL` and clear user var on tab switch

## Context and Scope

### Current Implementation Analysis

**wezterm.lua** (lines 203-241):
- Uses `format-tab-title` event handler to customize tab appearance
- Checks `tab.is_active` to apply different styles for active vs inactive tabs
- Checks `active_pane.user_vars.CLAUDE_STATUS == 'needs_input'` for notification coloring
- Applies amber background (`#e5b566`) with black foreground (`#151515`) for notifications

**wezterm-notify.sh**:
- Sets `CLAUDE_STATUS=needs_input` via OSC 1337 escape sequence when Claude Code stops
- Correctly uses base64 encoding for the value
- Writes to the pane's TTY directly (not stdout) since hooks have redirected stdio

### Problem Statement

1. The tab colors correctly when Claude completes (only on inactive tabs)
2. However, when the user switches to that tab, the `CLAUDE_STATUS` user variable is NOT cleared
3. If the user then switches away and back, the amber color reappears (because `CLAUDE_STATUS` still equals 'needs_input')
4. The color should reset to normal once the user acknowledges by viewing the tab

## Findings

### WezTerm API Capabilities

#### User Variables (OSC 1337)

User variables are set via OSC 1337 escape sequences from the terminal:
```bash
printf '\033]1337;SetUserVar=%s=%s\007' "name" "$(echo -n 'value' | base64)"
```

To **clear** a user variable, set it to an empty string:
```bash
printf '\033]1337;SetUserVar=%s=%s\007' "CLAUDE_STATUS" ""
```

Note: Empty string base64-encodes to empty string, so no encoding needed for clearing.

**Important Limitation**: User variables can only be **set** via OSC escape sequences from the terminal. There is no `pane:set_user_var()` method in the Lua API (this is a feature request in [GitHub Issue #7307](https://github.com/wezterm/wezterm/issues/7307)).

#### pane:inject_output

The [`pane:inject_output(text)`](https://wezterm.org/config/lua/pane/inject_output.html) method can send escape sequences to a pane's output:

```lua
pane:inject_output('\033]1337;SetUserVar=CLAUDE_STATUS=\007')
```

**Limitations**:
- Only works for local panes, not multiplexer panes
- Can confuse TUI programs if cursor position changes (not an issue for OSC sequences)
- Requires access to the actual `pane` object, not just `PaneInformation`

#### PaneInformation vs Pane Objects

In `format-tab-title`, we receive `PaneInformation` structs (read-only snapshots), NOT actual `pane` objects. This means we cannot call `pane:inject_output()` directly from `format-tab-title`.

**Solution**: Use the `user-var-changed` event which receives actual `pane` objects.

#### Available Events

| Event | Receives | Use Case |
|-------|----------|----------|
| `format-tab-title` | PaneInformation (read-only) | Styling tabs |
| `user-var-changed` | window, pane, name, value | React to variable changes |
| `update-status` | window, pane | Periodic status updates |
| `window-focus-changed` | window, pane | Window focus changes |

Note: There is **no dedicated tab-focus-changed event**.

#### wezterm.GLOBAL

[`wezterm.GLOBAL`](https://wezterm.org/config/lua/wezterm/GLOBAL.html) allows sharing state across Lua contexts:
- Persists across config reloads
- Thread-safe (but no synchronization primitives)
- Can store strings, numbers, tables, booleans

### Alternative: has_unseen_output

WezTerm has a built-in [`has_unseen_output`](https://wezterm.org/config/lua/PaneInformation.html) field on PaneInformation (since version 20220319):
- Returns `true` if output occurred since the pane last lost focus
- Automatically resets when the pane gains focus

**However**, this is different from our use case because:
1. We want to track a specific event (Claude completion), not any output
2. Claude may output additional text after completion, causing false positives
3. Our user variable approach provides more precise control

## Recommended Approach

### Option A: Track Active State in GLOBAL + Clear via inject_output (Recommended)

This approach uses `wezterm.GLOBAL` to track which tabs have been "seen" since they were notified, and clears the user variable when the tab becomes active.

**Implementation**:

1. In `format-tab-title`, when `tab.is_active` and `CLAUDE_STATUS == 'needs_input'`:
   - Record that this tab needs clearing in `wezterm.GLOBAL`

2. In `user-var-changed` event (already fires when CLAUDE_STATUS is set):
   - No changes needed

3. Add a new `update-status` event handler:
   - Check if any tabs marked for clearing in `wezterm.GLOBAL`
   - Use `pane:inject_output` to clear the user variable
   - Remove the tab from the clearing set

**Pros**:
- Cleanly separates tab coloring logic from clearing logic
- Works with the existing flow
- Uses proper pane objects for inject_output

**Cons**:
- Relies on periodic `update-status` event (configurable via `status_update_interval`)
- Slightly more complex

### Option B: Clear via Shell Hook (Simpler)

Create a complementary "clear" script that the user runs or is triggered automatically.

**Implementation**:

1. Create `.claude/hooks/wezterm-clear.sh` that clears CLAUDE_STATUS
2. Modify shell integration (fish/bash) to detect focus and run clear script

**Pros**:
- Simple
- No Lua complexity

**Cons**:
- Requires shell-level integration
- May not work in all scenarios (e.g., mouse tab clicks)

### Option C: Use update-status with Tab Tracking (Most Reliable)

Track the active tab in `wezterm.GLOBAL` via `update-status` event. When the active tab changes, clear the user variable.

**Implementation**:

```lua
-- Track last known active tab per window
wezterm.on('update-status', function(window, pane)
  local window_id = window:window_id()
  local active_tab = window:active_tab()
  local tab_id = active_tab:tab_id()

  -- Get or initialize tracking table
  local tracking = wezterm.GLOBAL.tab_tracking or {}
  local last_active = tracking[window_id]

  if last_active ~= tab_id then
    -- Tab changed! Check if new tab has CLAUDE_STATUS
    for _, tab_pane in ipairs(active_tab:panes()) do
      if tab_pane:get_user_vars().CLAUDE_STATUS == 'needs_input' then
        -- Clear the user variable
        tab_pane:inject_output('\027]1337;SetUserVar=CLAUDE_STATUS=\007')
      end
    end
    -- Update tracking
    tracking[window_id] = tab_id
    wezterm.GLOBAL.tab_tracking = tracking
  end
end)
```

**Pros**:
- Completely automatic
- Works with any tab switching method (keyboard, mouse)
- No shell integration needed

**Cons**:
- Depends on `status_update_interval` timing (default 1 second)
- Adds processing overhead to update-status (minimal)

## Implementation Recommendation

**Recommended: Option C** - Use `update-status` event with tab tracking in `wezterm.GLOBAL`.

This approach:
1. Works automatically when tabs are switched
2. Handles all switching methods (keyboard shortcuts, mouse clicks)
3. Keeps all logic in wezterm.lua
4. Has no external dependencies

**Key Implementation Details**:

1. **Escape sequence format**: Use `\027]1337;SetUserVar=CLAUDE_STATUS=\007` (octal escape `\027` = ESC)

2. **Timing**: May have up to `status_update_interval` delay (default 1000ms). Consider setting to 500ms for more responsive clearing:
   ```lua
   config.status_update_interval = 500
   ```

3. **Tab ID tracking**: Use `tab:tab_id()` for stable identification across config reloads

4. **Multiple panes**: Check all panes in the active tab, not just the active pane (though Claude typically runs in a single pane)

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| `inject_output` interferes with TUI | Low - OSC doesn't move cursor | Test with neovim actively running |
| Multiplexer panes unsupported | Low - typically local usage | Document limitation |
| update-status timing delay | Low - 500ms-1000ms delay acceptable | Set lower `status_update_interval` |
| Race between set and clear | Low - user variable operations are atomic | Clearing always wins (most recent) |

## Appendix

### Web Search Queries Used

1. "WezTerm user_vars clear reset tab activation event Lua API"
2. "WezTerm pane:set_user_var clear user variable from Lua config"
3. "WezTerm wezterm cli send-text OSC escape sequence user variable"
4. "WezTerm tab-focus-changed tab-activated event window-focus-changed Lua API"
5. "WezTerm update-status event tab switch detect active tab change"
6. "WezTerm pane:inject_output OSC escape sequence user variable clear"

### Documentation References

- [pane:get_user_vars()](https://wezterm.org/config/lua/pane/get_user_vars.html)
- [user-var-changed event](https://wezterm.org/config/lua/window-events/user-var-changed.html)
- [PaneInformation object](https://wezterm.org/config/lua/PaneInformation.html) - includes `has_unseen_output`
- [pane:inject_output](https://wezterm.org/config/lua/pane/inject_output.html)
- [wezterm.GLOBAL](https://wezterm.org/config/lua/wezterm/GLOBAL.html)
- [update-status event](https://wezterm.org/config/lua/window-events/update-status.html)
- [window-events index](https://wezterm.org/config/lua/window-events/index.html)
- [Tab activity indicator discussion](https://github.com/wezterm/wezterm/discussions/796)
- [Passing data from pane to Lua](https://wezterm.org/recipes/passing-data.html)
- [GitHub Issue #7307 - pane:set_user_var request](https://github.com/wezterm/wezterm/issues/7307)
