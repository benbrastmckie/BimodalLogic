# Implementation Plan: Task #802

- **Task**: 802 - Fix WezTerm tab task number clearing on Neovim exit and /clear command
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/802_wezterm_task_number_clearing_neovim_exit/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Task numbers persist in WezTerm tabs after Neovim exits or /clear is run due to two separate root causes: (1) VimLeavePre does not trigger the existing BufDelete cleanup callback for Claude terminals, and (2) /clear fires SessionStart with source="clear" but no hook exists to clear TASK_NUMBER. This plan addresses both issues by adding a VimLeavePre autocmd in Neovim and a SessionStart hook in Claude Code settings.

### Research Integration

Research report research-001.md identified:
- VimLeavePre timing prevents BufDelete callback from executing properly during exit
- /clear fires SessionStart hook with source="clear", not UserPromptSubmit
- OSC 7 (directory) is working correctly; only TASK_NUMBER clearing is broken

## Goals & Non-Goals

**Goals**:
- Clear TASK_NUMBER when Neovim exits with an active Claude terminal
- Clear TASK_NUMBER when /clear command is run in Claude Code
- Maintain existing TASK_NUMBER behavior for workflow commands

**Non-Goals**:
- Modifying OSC 7 (directory) behavior (working correctly)
- Changing how TASK_NUMBER is set (only fixing clearing)
- Handling edge cases like multiple concurrent sessions

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| VimLeavePre callback timing | Medium | Low | Use synchronous io.write before terminal cleanup |
| TTY access during Neovim exit | Medium | Low | Test OSC emission works in VimLeavePre context |
| Hook execution order | Low | Low | SessionStart hooks run early in session lifecycle |

## Implementation Phases

### Phase 1: Add SessionStart Hook for /clear [NOT STARTED]

**Goal:** Clear TASK_NUMBER when /clear command is run in Claude Code

**Tasks:**
- [ ] Create new script `.claude/hooks/wezterm-clear-task-number.sh` that unconditionally clears TASK_NUMBER
- [ ] Add SessionStart hook in `.claude/settings.json` with matcher="clear"
- [ ] Test /clear command clears task number from tab

**Timing:** 30 minutes

**Files to modify:**
- `.claude/hooks/wezterm-clear-task-number.sh` - New file: script to clear TASK_NUMBER via OSC 1337
- `.claude/settings.json` - Add SessionStart hook configuration

**Verification:**
- Run /research N to set a task number
- Run /clear
- Tab title should show only directory, no #N suffix

---

### Phase 2: Add VimLeavePre Autocmd for Neovim Exit [NOT STARTED]

**Goal:** Clear TASK_NUMBER when Neovim exits with an active Claude terminal buffer

**Tasks:**
- [ ] Add VimLeavePre autocmd to `~/.config/nvim/lua/neotex/config/autocmds.lua`
- [ ] Ensure it checks for Claude terminal buffers before clearing
- [ ] Test Neovim exit clears task number from tab

**Timing:** 45 minutes

**Files to modify:**
- `~/.config/nvim/lua/neotex/config/autocmds.lua` - Add VimLeavePre autocmd

**Verification:**
- Open Neovim with toggleterm Claude terminal
- Run /research N to set a task number
- Exit Neovim (:qa or :q)
- Tab title should show only directory, no #N suffix

---

### Phase 3: Integration Testing [NOT STARTED]

**Goal:** Verify all scenarios work together without regressions

**Tasks:**
- [ ] Test workflow commands still set TASK_NUMBER correctly
- [ ] Test non-workflow commands still clear TASK_NUMBER
- [ ] Test /clear clears TASK_NUMBER
- [ ] Test Neovim exit clears TASK_NUMBER
- [ ] Test task number persists across prompts during workflow

**Timing:** 15 minutes

**Files to modify:**
- None (testing only)

**Verification:**
- Complete test matrix below
- All scenarios pass

## Testing & Validation

Test matrix:
- [ ] `/research N` sets task number in tab
- [ ] Follow-up prompts during workflow preserve task number
- [ ] Non-workflow command (e.g., "hello") clears task number
- [ ] `/clear` command clears task number
- [ ] Neovim exit (:qa) clears task number
- [ ] Neovim exit (window close) clears task number
- [ ] Tab shows correct directory after clearing

## Artifacts & Outputs

- `.claude/hooks/wezterm-clear-task-number.sh` - New hook script
- `~/.config/nvim/lua/neotex/config/autocmds.lua` - Modified with VimLeavePre autocmd
- `.claude/settings.json` - Modified with SessionStart hook
- `specs/802_wezterm_task_number_clearing_neovim_exit/summaries/implementation-summary-YYYYMMDD.md` - Summary on completion

## Rollback/Contingency

If issues arise:
1. Remove SessionStart hook from `.claude/settings.json`
2. Remove VimLeavePre autocmd from autocmds.lua
3. Delete `.claude/hooks/wezterm-clear-task-number.sh`
4. Task number behavior reverts to pre-fix state (persisting incorrectly)
