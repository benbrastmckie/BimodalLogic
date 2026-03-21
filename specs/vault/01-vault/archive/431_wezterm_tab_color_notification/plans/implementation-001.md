# Implementation Plan: Task #431

- **Task**: 431 - WezTerm tab color notification for Claude Code input
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/431_wezterm_tab_color_notification/reports/research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Implement WezTerm tab color notification when Claude Code needs input, using OSC 1337 SetUserVar escape sequences. The solution follows the existing TTS notification pattern (Stop hook) and uses a hybrid clearing approach: visual-only clearing when switching to the tab, plus state clearing via UserPromptSubmit hook when the user responds.

### Research Integration

Research report research-002.md identified:
- Use Stop hook (same as TTS) for setting notification status
- OSC 1337 SetUserVar for WezTerm user variables
- Hybrid clearing: format-tab-title only shows color on inactive tabs, UserPromptSubmit clears state
- Color scheme: amber (#e5b566) background with black (#151515) foreground for inactive tabs

## Goals & Non-Goals

**Goals**:
- Notify user visually when Claude Code completes or needs input
- Color only inactive tabs (instant visual clearing when switching to tab)
- Clear notification state when user responds
- Follow existing TTS hook pattern for consistency
- Support disable via environment variable

**Non-Goals**:
- Sound notifications (already handled by TTS hook)
- Notifications for active tabs (user is already looking at it)
- Cross-terminal support (WezTerm only)
- Custom color configuration (fixed amber scheme)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| OSC escape sequences cause issues in other terminals | Medium | Low | Guard with WEZTERM_PANE check |
| User variable not accessible in format-tab-title | High | Low | Tested pattern per WezTerm docs |
| Tab color persists after user responds | Medium | Medium | Hybrid clearing approach |
| Escape sequence timing conflicts with TTS | Low | Low | Independent output channels |

## Implementation Phases

### Phase 1: Create WezTerm Notification Script [COMPLETED]

**Goal**: Create the hook script that sets the CLAUDE_STATUS user variable on Stop events

**Tasks**:
- [ ] Create `.claude/hooks/wezterm-notify.sh` following tts-notify.sh pattern
- [ ] Implement WEZTERM_PANE environment check
- [ ] Implement OSC 1337 SetUserVar escape sequence to set CLAUDE_STATUS
- [ ] Add WEZTERM_NOTIFY_ENABLED environment variable support
- [ ] Make script executable

**Timing**: 30 minutes

**Files to modify**:
- `.claude/hooks/wezterm-notify.sh` - New file: notification script

**Verification**:
- Script exists and is executable
- Running script in WezTerm sets CLAUDE_STATUS user variable
- Running script outside WezTerm exits cleanly with '{}'

---

### Phase 2: Create Status Clear Script [COMPLETED]

**Goal**: Create the hook script that clears the CLAUDE_STATUS user variable

**Tasks**:
- [ ] Create `.claude/hooks/wezterm-clear-status.sh`
- [ ] Implement WEZTERM_PANE environment check
- [ ] Implement OSC 1337 SetUserVar escape sequence to clear CLAUDE_STATUS
- [ ] Make script executable

**Timing**: 15 minutes

**Files to modify**:
- `.claude/hooks/wezterm-clear-status.sh` - New file: clear status script

**Verification**:
- Script exists and is executable
- Running script clears CLAUDE_STATUS user variable
- Running script outside WezTerm exits cleanly with '{}'

---

### Phase 3: Register Hooks in Claude Code Settings [COMPLETED]

**Goal**: Add the new hooks to .claude/settings.json

**Tasks**:
- [ ] Add wezterm-notify.sh to Stop hooks (alongside existing tts-notify.sh)
- [ ] Add UserPromptSubmit hook section with wezterm-clear-status.sh

**Timing**: 15 minutes

**Files to modify**:
- `.claude/settings.json` - Add hook registrations

**Verification**:
- settings.json is valid JSON
- Stop hook array includes wezterm-notify.sh
- UserPromptSubmit hook section exists with wezterm-clear-status.sh

---

### Phase 4: Update WezTerm Configuration [COMPLETED]

**Goal**: Extend format-tab-title handler to show notification colors on inactive tabs

**Tasks**:
- [ ] Locate format-tab-title handler in ~/.dotfiles/config/wezterm.lua
- [ ] Add CLAUDE_STATUS user variable check
- [ ] Add condition for inactive tabs only (`and not tab.is_active`)
- [ ] Apply amber background (#e5b566) and black foreground (#151515) for notifying inactive tabs
- [ ] Test configuration reload

**Timing**: 30 minutes

**Files to modify**:
- `~/.dotfiles/config/wezterm.lua` - Extend format-tab-title handler

**Verification**:
- WezTerm config reloads without errors
- Inactive tab with CLAUDE_STATUS='needs_input' shows amber color
- Active tab shows normal colors regardless of CLAUDE_STATUS
- Switching to notifying tab instantly clears visual indicator

---

### Phase 5: Integration Testing [COMPLETED]

**Goal**: Verify end-to-end functionality in WezTerm with Claude Code

**Tasks**:
- [ ] Start Claude Code session in WezTerm
- [ ] Trigger Stop event (complete a command)
- [ ] Verify inactive tab shows amber color
- [ ] Switch to tab, verify color clears instantly
- [ ] Submit a prompt, verify CLAUDE_STATUS is cleared
- [ ] Test with WEZTERM_NOTIFY_ENABLED=0 (should not set status)

**Timing**: 30 minutes

**Files to modify**:
- None (testing only)

**Verification**:
- Full workflow functions as expected
- No errors in WezTerm debug output
- TTS and tab notifications work independently

---

## Testing & Validation

- [ ] wezterm-notify.sh sets user variable when WEZTERM_PANE is set
- [ ] wezterm-notify.sh outputs '{}' when WEZTERM_PANE is not set
- [ ] wezterm-clear-status.sh clears user variable
- [ ] settings.json passes JSON validation
- [ ] WezTerm config reloads without errors
- [ ] Inactive notifying tab shows amber background
- [ ] Active tab always shows normal colors
- [ ] Switching to notifying tab clears color instantly
- [ ] UserPromptSubmit clears CLAUDE_STATUS variable
- [ ] WEZTERM_NOTIFY_ENABLED=0 disables notification

## Artifacts & Outputs

- `.claude/hooks/wezterm-notify.sh` - Notification script
- `.claude/hooks/wezterm-clear-status.sh` - Status clear script
- `.claude/settings.json` - Updated with new hooks
- `~/.dotfiles/config/wezterm.lua` - Extended format-tab-title handler
- `specs/431_wezterm_tab_color_notification/summaries/implementation-summary-YYYYMMDD.md` - Implementation summary

## Rollback/Contingency

If the implementation causes issues:
1. Remove wezterm-notify.sh and wezterm-clear-status.sh from settings.json
2. Revert wezterm.lua changes (remove CLAUDE_STATUS check in format-tab-title)
3. Delete `.claude/hooks/wezterm-notify.sh` and `.claude/hooks/wezterm-clear-status.sh`

The TTS notification system remains unaffected as changes are additive and independent.
