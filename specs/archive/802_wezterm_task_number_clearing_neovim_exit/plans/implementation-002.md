# Implementation Plan: Task #802 (v2)

- **Task**: 802 - Fix WezTerm tab task number clearing on Neovim exit and non-workflow commands
- **Status**: [COMPLETED]
- **Effort**: 1 hour
- **Dependencies**: None
- **Research Inputs**: specs/802_wezterm_task_number_clearing_neovim_exit/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false
- **Revision**: v2 - Expanded scope to clear task numbers for all non-workflow events

## Overview

Task numbers should clear when any non-workflow command or prompt is submitted, not just specific scenarios. The current `UserPromptSubmit` hook already handles non-workflow prompts correctly. This plan addresses the gaps where task numbers persist incorrectly:

1. **SessionStart events** - `/clear`, session resume, compaction, new startup
2. **Neovim exit** - When Neovim closes with active Claude terminal

The key insight: Use a **single unconditional SessionStart hook** that clears TASK_NUMBER for all session events. Since workflow commands send a `UserPromptSubmit` after `SessionStart`, the task number will be set again by the existing hook. Non-workflow prompts will clear via `UserPromptSubmit`, and session events without prompts will clear via `SessionStart`.

### Revision Rationale

The user clarified: "I want task numbers to clear if I run any other command in claude code (including /clear) or any other prompt that is not one of the workflow commands."

Original plan (v1) focused on:
- `/clear` command specifically (via SessionStart matcher="clear")
- Neovim exit (via VimLeavePre)

Revised plan (v2) expands scope:
- All SessionStart events (startup, resume, clear, compact) clear unconditionally
- Neovim exit clears unconditionally

This is simpler and more robust: "clear by default, set only for workflow commands."

## Goals & Non-Goals

**Goals**:
- Clear TASK_NUMBER for all SessionStart events (startup, resume, clear, compact)
- Clear TASK_NUMBER when Neovim exits with an active Claude terminal
- Maintain existing TASK_NUMBER behavior for workflow commands (set by UserPromptSubmit)

**Non-Goals**:
- Modifying OSC 7 (directory) behavior (working correctly)
- Changing how TASK_NUMBER is set (only expanding clearing scope)
- Modifying the existing UserPromptSubmit hook

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Race between SessionStart clear and UserPromptSubmit set | Medium | Low | UserPromptSubmit fires after SessionStart; workflow commands will re-set |
| VimLeavePre callback timing | Medium | Low | Use synchronous io.write before terminal cleanup |
| TTY access during Neovim exit | Medium | Low | Test OSC emission works in VimLeavePre context |

## Implementation Phases

### Phase 1: Add Universal SessionStart Hook [COMPLETED]

**Goal:** Clear TASK_NUMBER for all session start events (not just /clear)

**Tasks:**
- [ ] Create new script `.claude/hooks/wezterm-clear-task-number.sh` that unconditionally clears TASK_NUMBER
- [ ] Add SessionStart hook in `.claude/settings.json` with matcher="*" (all sources)
- [ ] Test that task numbers clear on session events

**Timing:** 20 minutes

**Files to modify:**
- `.claude/hooks/wezterm-clear-task-number.sh` - New file: script to clear TASK_NUMBER via OSC 1337
- `.claude/settings.json` - Add SessionStart hook configuration with matcher="*"

**Script content for wezterm-clear-task-number.sh:**
```bash
#!/bin/bash
# Clear TASK_NUMBER user variable for WezTerm tab title
# Called from SessionStart hook to reset task number on session events
set -euo pipefail

# Only run in WezTerm
if [[ -z "${WEZTERM_PANE:-}" ]]; then
    echo '{}'
    exit 0
fi

# Get the TTY for the current pane
PANE_TTY=$(wezterm cli list --format=json 2>/dev/null | \
    jq -r ".[] | select(.pane_id == $WEZTERM_PANE) | .tty_name" 2>/dev/null || echo "")

if [[ -n "$PANE_TTY" ]] && [[ -w "$PANE_TTY" ]]; then
    # Clear TASK_NUMBER via OSC 1337
    printf '\033]1337;SetUserVar=TASK_NUMBER=\007' > "$PANE_TTY"
fi

echo '{}'
exit 0
```

**Hook configuration:**
```json
"SessionStart": [
  {
    "matcher": "*",
    "hooks": [
      { "type": "command", "command": "bash .claude/hooks/wezterm-clear-task-number.sh" }
    ]
  }
]
```

**Verification:**
- Run /clear -> task number clears
- Start new session (exit and restart claude) -> no task number shown
- Run /research N -> task number sets (from UserPromptSubmit, overrides SessionStart clear)

---

### Phase 2: Add VimLeavePre Autocmd for Neovim Exit [COMPLETED]

**Goal:** Clear TASK_NUMBER when Neovim exits with an active Claude terminal buffer

**Tasks:**
- [ ] Add VimLeavePre autocmd to `~/.config/nvim/lua/neotex/config/autocmds.lua`
- [ ] Clear unconditionally if any Claude terminal buffer exists
- [ ] Test Neovim exit clears task number from tab

**Timing:** 25 minutes

**Files to modify:**
- `~/.config/nvim/lua/neotex/config/autocmds.lua` - Add VimLeavePre autocmd

**Autocmd content:**
```lua
api.nvim_create_autocmd('VimLeavePre', {
  callback = function()
    -- Clear task number if any Claude terminal was active
    for bufnr, _ in pairs(claude_terminal_buffers) do
      wezterm.clear_task_number()
      break  -- Only need to clear once
    end
  end,
  desc = 'WezTerm: Clear task number when Neovim exits with Claude terminal',
})
```

**Verification:**
- Open Neovim with toggleterm Claude terminal
- Run /research N to set a task number
- Exit Neovim (:qa or :q)
- Tab title should show only directory, no #N suffix

---

### Phase 3: Integration Testing [COMPLETED]

**Goal:** Verify all scenarios work together without regressions

**Tasks:**
- [ ] Test workflow commands set TASK_NUMBER correctly
- [ ] Test non-workflow prompts clear TASK_NUMBER
- [ ] Test /clear clears TASK_NUMBER
- [ ] Test new session startup clears TASK_NUMBER
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
- [ ] Follow-up prompts during workflow preserve task number (UserPromptSubmit with no match -> clears, then workflow continues...)
  - **Note**: This test needs clarification. The current hook clears on non-workflow prompts. If the user wants follow-up prompts to preserve, this would require additional logic.
- [ ] Non-workflow command (e.g., "hello") clears task number
- [ ] `/clear` command clears task number (via SessionStart)
- [ ] Session startup clears task number (via SessionStart)
- [ ] Neovim exit (:qa) clears task number (via VimLeavePre)
- [ ] Neovim exit (window close) clears task number
- [ ] Tab shows correct directory after clearing

## Artifacts & Outputs

- `.claude/hooks/wezterm-clear-task-number.sh` - New hook script
- `~/.config/nvim/lua/neotex/config/autocmds.lua` - Modified with VimLeavePre autocmd
- `.claude/settings.json` - Modified with SessionStart hook (matcher="*")
- `specs/802_wezterm_task_number_clearing_neovim_exit/summaries/implementation-summary-YYYYMMDD.md` - Summary on completion

## Rollback/Contingency

If issues arise:
1. Remove SessionStart hook from `.claude/settings.json`
2. Remove VimLeavePre autocmd from autocmds.lua
3. Delete `.claude/hooks/wezterm-clear-task-number.sh`
4. Task number behavior reverts to pre-fix state
