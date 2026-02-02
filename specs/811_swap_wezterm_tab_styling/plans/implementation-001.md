# Implementation Plan: Task #811

- **Task**: 811 - swap_wezterm_tab_styling
- **Status**: [COMPLETED]
- **Effort**: 0.25 hours
- **Dependencies**: None
- **Research Inputs**: None
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Exchange the WezTerm tab styling between active tabs and Claude Code notification tabs. Currently, active tabs use a subtle gray theme while Claude Code notifications use an amber/black theme. After the swap, active tabs will be amber/black and Claude Code notifications will use gray.

## Goals & Non-Goals

**Goals**:
- Swap active tab colors with Claude Code notification tab colors
- Preserve all other tab bar functionality (formatting, notification clearing, etc.)

**Non-Goals**:
- Changing any other WezTerm configuration
- Modifying notification logic or behavior
- Changing inactive tab styling

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Config syntax error | M | L | Test by reloading WezTerm after change |
| Colors too similar to inactive | L | L | Visual inspection confirms distinct colors |

## Implementation Phases

### Phase 1: Swap Tab Styling Colors [COMPLETED]

**Goal**: Exchange the color values between active tab styling and Claude Code notification styling

**Tasks**:
- [ ] Update `config.colors.tab_bar.active_tab` to use amber background (#e5b566) and black foreground (#151515)
- [ ] Update the format-tab-title function's Claude notification branch to use gray background (#3a3a3a) and light foreground (#d0d0d0)
- [ ] Update the format-tab-title function's active tab branch to use the new amber colors

**Timing**: 0.25 hours

**Files to modify**:
- `/home/benjamin/.dotfiles/config/wezterm.lua` - Lines 169-176 (active_tab colors) and lines 206-217 (format-tab-title color logic)

**Specific Changes**:

1. Lines 169-176 - Change `active_tab` config:
   ```lua
   -- FROM:
   active_tab = {
     bg_color = "#3a3a3a",
     fg_color = "#d0d0d0",
     ...
   }
   -- TO:
   active_tab = {
     bg_color = "#e5b566",
     fg_color = "#151515",
     ...
   }
   ```

2. Lines 206-207 - Change format-tab-title active tab colors:
   ```lua
   -- FROM:
   local background = tab.is_active and "#3a3a3a" or "#202020"
   local foreground = tab.is_active and "#d0d0d0" or "#808080"
   -- TO:
   local background = tab.is_active and "#e5b566" or "#202020"
   local foreground = tab.is_active and "#151515" or "#808080"
   ```

3. Lines 214-217 - Change Claude notification colors:
   ```lua
   -- FROM:
   background = "#e5b566"
   foreground = "#151515"
   -- TO:
   background = "#3a3a3a"
   foreground = "#d0d0d0"
   ```

**Verification**:
- WezTerm reloads without errors
- Active tabs display with amber background and black text
- Claude Code notification tabs display with gray background and light text

---

## Testing & Validation

- [ ] WezTerm config reloads successfully (Ctrl+Shift+R or restart)
- [ ] Active tab shows amber (#e5b566) background with black (#151515) text
- [ ] Inactive tabs still show dark gray (#202020) background
- [ ] Claude Code notification triggers gray (#3a3a3a) background styling
- [ ] Tab text remains readable in all states

## Artifacts & Outputs

- Modified `/home/benjamin/.dotfiles/config/wezterm.lua`

## Rollback/Contingency

Restore original colors if the swap causes readability issues:
- active_tab: bg=#3a3a3a, fg=#d0d0d0
- notification: bg=#e5b566, fg=#151515
- format-tab-title active: bg=#3a3a3a, fg=#d0d0d0
