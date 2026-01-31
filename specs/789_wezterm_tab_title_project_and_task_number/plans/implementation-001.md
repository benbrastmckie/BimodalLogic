# Implementation Plan: Configure WezTerm Tab Titles

- **Task**: 789 - Configure WezTerm tab title to show project directory and task number
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: specs/789_wezterm_tab_title_project_and_task_number/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

This plan modifies WezTerm configuration and Claude Code hooks to display project names in tab titles and append task numbers during Claude commands. The existing `format-tab-title` handler will be updated to extract project names from the current working directory and read task numbers from user variables. A new hook script will parse Claude commands for task numbers.

### Research Integration

Integrated findings from research-001.md:
- WezTerm's `current_working_dir` returns a Url object with `file_path` attribute for cwd extraction
- User variables via OSC 1337 can pass task numbers between shell and WezTerm Lua config
- Existing `update-status` handler already clears notification status on tab activation
- Pattern for parsing Claude commands: `/(?:research|plan|implement|revise)\s+\d+`

## Goals & Non-Goals

**Goals**:
- Display tab titles as `{tab_number} {project_name}` (e.g., `2 ProofChecker`)
- Append task numbers when running `/research N`, `/plan N`, `/implement N` commands
- Clear stale task numbers when running commands without task numbers
- Maintain existing notification color behavior (amber for inactive tabs needing input)

**Non-Goals**:
- Modifying the color scheme or styling beyond existing patterns
- Adding new notification states beyond current CLAUDE_STATUS
- Supporting task number extraction from arbitrary shell commands (only Claude commands)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `current_working_dir` returns nil | Title shows pane title fallback | Low | Add graceful fallback to existing pane title |
| WEZTERM_PANE not set in hook context | Task number not passed | Low | Check variable existence before proceeding |
| Regex pattern misses edge cases | Some task numbers not captured | Low | Test with various command formats |

## Implementation Phases

### Phase 1: Update format-tab-title Handler [COMPLETED]

**Goal**: Modify WezTerm's `format-tab-title` to display project name from cwd and task number from user variables.

**Tasks**:
- [ ] Read current wezterm.lua configuration
- [ ] Modify `format-tab-title` handler (lines 203-241) to:
  - Extract project name from `tab.active_pane.current_working_dir.file_path`
  - Fall back to pane title if cwd unavailable
  - Read `TASK_NUMBER` from user variables
  - Format title as `{tab_num} {project}` or `{tab_num} {project} #{task}`
- [ ] Verify existing notification coloring logic remains intact
- [ ] Test manually in WezTerm

**Timing**: 45 minutes

**Files to modify**:
- `/home/benjamin/.dotfiles/config/wezterm.lua` - Update format-tab-title handler

**Verification**:
- Tab shows project directory name instead of `nvim ~`
- Existing amber notification color still works on inactive tabs

---

### Phase 2: Create Task Number Hook Script [COMPLETED]

**Goal**: Create Claude Code hook to parse task numbers from prompts and set WezTerm user variable.

**Tasks**:
- [ ] Create `.claude/hooks/wezterm-task-number.sh`
- [ ] Parse `/research N`, `/plan N`, `/implement N`, `/revise N` patterns from prompt
- [ ] Set `TASK_NUMBER` user variable via OSC 1337 when task found
- [ ] Clear `TASK_NUMBER` when command has no task number
- [ ] Make script executable
- [ ] Test script standalone with echo input

**Timing**: 30 minutes

**Files to modify**:
- `.claude/hooks/wezterm-task-number.sh` - New hook script

**Verification**:
- Script outputs `{}` on all code paths
- Script correctly parses task numbers from test input

---

### Phase 3: Register Hook in Settings [COMPLETED]

**Goal**: Add the new hook to Claude Code's UserPromptSubmit hook chain.

**Tasks**:
- [ ] Read current `.claude/settings.json` hook configuration
- [ ] Add `wezterm-task-number.sh` to UserPromptSubmit hooks
- [ ] Position before `wezterm-clear-status.sh` in hook order
- [ ] Verify JSON syntax is valid

**Timing**: 15 minutes

**Files to modify**:
- `.claude/settings.json` - Add hook to UserPromptSubmit

**Verification**:
- settings.json parses as valid JSON
- Hook order is correct (task-number before clear-status)

---

### Phase 4: Integration Testing [COMPLETED]

**Goal**: Verify complete integration works end-to-end.

**Tasks**:
- [ ] Start fresh Claude Code session in WezTerm
- [ ] Verify tab shows project name without task number initially
- [ ] Run `/research 789` style command
- [ ] Verify tab shows `{N} ProofChecker #789`
- [ ] Run `/todo` (no task number)
- [ ] Verify task number is cleared from tab
- [ ] Verify notification color behavior unchanged
- [ ] Switch tabs to verify color clears on active tab

**Timing**: 30 minutes

**Files to modify**:
- None (testing only)

**Verification**:
- All test scenarios pass
- No regressions in existing behavior

## Testing & Validation

- [ ] Tab displays project name from cwd
- [ ] Tab displays task number when running task-specific commands
- [ ] Tab clears task number when running non-task commands
- [ ] Amber notification color appears on inactive tabs needing input
- [ ] Notification color clears when tab becomes active
- [ ] Fallback to pane title works when cwd unavailable

## Artifacts & Outputs

- `/home/benjamin/.dotfiles/config/wezterm.lua` - Updated tab title handler
- `.claude/hooks/wezterm-task-number.sh` - New hook script
- `.claude/settings.json` - Updated hook registration
- `specs/789_wezterm_tab_title_project_and_task_number/summaries/implementation-summary-20260131.md` - Completion summary

## Rollback/Contingency

To revert changes:
1. Restore wezterm.lua from git: `git checkout ~/.dotfiles/config/wezterm.lua`
2. Remove hook script: `rm .claude/hooks/wezterm-task-number.sh`
3. Remove hook from settings.json UserPromptSubmit array
4. Reload WezTerm configuration: `wezterm cli reload-configuration`
