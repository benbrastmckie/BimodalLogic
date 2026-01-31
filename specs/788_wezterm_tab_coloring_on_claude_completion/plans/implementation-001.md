# Implementation Plan: Task #788

- **Task**: 788 - Improve WezTerm tab coloring for Claude Code completion
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: specs/788_wezterm_tab_coloring_on_claude_completion/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Implement automatic clearing of the CLAUDE_STATUS user variable when tabs are switched, using the `update-status` event with tab tracking in `wezterm.GLOBAL`. This approach works automatically with any tab switching method (keyboard, mouse) and keeps all logic in wezterm.lua without external dependencies.

### Research Integration

The research identified that:
1. User variables can only be cleared via OSC escape sequences (no `pane:set_user_var()` exists)
2. `pane:inject_output()` can send escape sequences but requires actual pane objects (not available in `format-tab-title`)
3. The `update-status` event provides access to pane objects and can detect tab switches via `wezterm.GLOBAL` tracking
4. Recommended approach: Option C from research - use `update-status` with tab tracking

## Goals & Non-Goals

**Goals**:
- Tab notification color only appears when tab is not active
- Color resets automatically when user switches to the notified tab
- Works with all tab switching methods (keyboard shortcuts, mouse clicks)
- No manual intervention required from user

**Non-Goals**:
- Changing the notification color scheme
- Adding audio notifications
- Supporting multiplexer panes (documented limitation of inject_output)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `inject_output` interferes with TUI | Low | Low | OSC sequences don't move cursor; test with neovim running |
| update-status timing delay | Low | Medium | Set `status_update_interval` to 500ms for responsive clearing |
| Race between set and clear | Low | Low | Clearing always wins (most recent); user variable operations are atomic |
| NixOS home-manager rebuild required | Low | High | Expected workflow; test changes before committing |

## Implementation Phases

### Phase 1: Add update-status Event Handler [COMPLETED]

**Goal**: Implement tab tracking and automatic CLAUDE_STATUS clearing when tabs are switched

**Tasks**:
- [ ] Add `status_update_interval = 500` config option for responsive updates
- [ ] Implement `update-status` event handler that tracks active tab per window
- [ ] Use `wezterm.GLOBAL.tab_tracking` to store last known active tab per window
- [ ] When tab changes, check all panes in new tab for CLAUDE_STATUS='needs_input'
- [ ] Clear user variable via `pane:inject_output('\027]1337;SetUserVar=CLAUDE_STATUS=\007')`

**Timing**: 1 hour

**Files to modify**:
- `/home/benjamin/.dotfiles/config/wezterm.lua` - Add update-status event handler and config option

**Implementation Details**:

Insert after line 241 (after the format-tab-title event handler):

```lua
-- Clear Claude notification when tab becomes active
-- Uses update-status event to track tab switches and clear CLAUDE_STATUS user variable
config.status_update_interval = 500  -- 500ms for responsive clearing

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
      local user_vars = tab_pane:get_user_vars()
      if user_vars.CLAUDE_STATUS == 'needs_input' then
        -- Clear the user variable via OSC escape sequence
        tab_pane:inject_output('\027]1337;SetUserVar=CLAUDE_STATUS=\007')
      end
    end
    -- Update tracking
    tracking[window_id] = tab_id
    wezterm.GLOBAL.tab_tracking = tracking
  end
end)
```

**Verification**:
- WezTerm reloads config without errors (check with `wezterm cli list-clients`)
- Tab tracking logic is correct (inspect via debug logging if needed)

---

### Phase 2: Test and Verify Behavior [COMPLETED]

**Goal**: Verify the implementation works correctly in realistic scenarios

**Tasks**:
- [ ] Rebuild NixOS config with home-manager to apply changes
- [ ] Test scenario 1: Claude completes on inactive tab - verify amber coloring appears
- [ ] Test scenario 2: Switch to notified tab - verify color resets to normal
- [ ] Test scenario 3: Switch away and back - verify no amber (variable was cleared)
- [ ] Test scenario 4: Run with neovim active - verify no TUI interference

**Timing**: 0.5 hours

**Files to modify**:
- None (testing only)

**Verification**:
- All test scenarios pass
- No visual glitches or cursor position issues in neovim
- Notification timing feels responsive (within 500ms)

---

### Phase 3: Documentation and Cleanup [COMPLETED]

**Goal**: Document the implementation and ensure code clarity

**Tasks**:
- [ ] Add comments explaining the tab tracking mechanism
- [ ] Verify existing comments in format-tab-title are still accurate
- [ ] Test one final end-to-end scenario

**Timing**: 0.5 hours

**Files to modify**:
- `/home/benjamin/.dotfiles/config/wezterm.lua` - Ensure comments are clear and complete

**Verification**:
- Code is self-documenting
- Comments explain the "why" not just the "what"
- Implementation matches research recommendations

---

## Testing & Validation

- [ ] WezTerm loads config without errors after changes
- [ ] Tab coloring appears when Claude completes on inactive tab
- [ ] Tab coloring disappears when switching to the notified tab
- [ ] No color reappears when switching away and back
- [ ] Works with keyboard tab switching (Ctrl+Space n/p)
- [ ] Works with mouse tab clicking
- [ ] No interference with neovim or other TUI programs

## Artifacts & Outputs

- Modified `/home/benjamin/.dotfiles/config/wezterm.lua` with update-status handler
- Implementation summary documenting the changes

## Rollback/Contingency

If the implementation causes issues:
1. Comment out the new `update-status` event handler
2. Comment out the `status_update_interval` config line
3. Reload WezTerm config (Ctrl+Shift+R or restart)
4. The existing notification behavior will continue (color appears but doesn't auto-clear)
