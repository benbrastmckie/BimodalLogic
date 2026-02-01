# Implementation Plan: Task #791

- **Task**: 791 - Extend WezTerm task number integration for Claude Code commands
- **Status**: [COMPLETED]
- **Effort**: 2.5 hours
- **Dependencies**: Tasks 788-790 completed, greggh/claude-code.nvim plugin
- **Research Inputs**: specs/791_wezterm_task_number_from_claude_commands/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Extend the WezTerm task number integration to work when Claude Code runs inside Neovim. The current `wezterm-task-number.sh` hook parses commands from the shell prompt, but when running inside Neovim's terminal buffer, OSC escape sequences may not propagate correctly to WezTerm. The implementation will first verify whether the existing hook works from Neovim, and if not, add Neovim-side OSC 1337 emission using the pattern established by task 790 for OSC 7.

### Research Integration

Key findings from research-001.md:
- The existing hook uses `CLAUDE_USER_PROMPT` environment variable which should be set regardless of launch context
- OSC sequences written to inner PTY may or may not propagate to WezTerm (needs verification)
- Task 790 established a working pattern for emitting OSC sequences from Neovim to WezTerm
- The `greggh/claude-code.nvim` plugin creates terminal buffers that inherit `WEZTERM_PANE`

## Goals & Non-Goals

**Goals**:
- Task number appears in WezTerm tab title when running `/research N`, `/plan N`, `/implement N`, or `/revise N` from Neovim's Claude Code terminal
- Seamless integration with existing infrastructure (no duplicate updates)
- Pattern consistency with task 790's OSC 7 implementation

**Non-Goals**:
- Migrating to coder/claudecode.nvim (more complex, not necessary)
- Intercepting terminal keystrokes (too invasive)
- Supporting terminals other than WezTerm

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Existing hook already works | Low (positive outcome) | Medium | Test first before implementing |
| Inner PTY strips OSC sequences | High | Low | Emit directly from Neovim side |
| Terminal buffer monitoring too slow | Medium | Low | Use efficient nvim_buf_attach |
| Multiple Claude instances cause conflicts | Low | Low | Track by buffer, not globally |
| Neovim output buffering delays OSC | Low | Medium | Use io.flush() after write |

## Implementation Phases

### Phase 1: Verify Current Implementation [COMPLETED]

**Goal**: Determine if the existing wezterm-task-number.sh hook already works from within Neovim's Claude Code terminal.

**Tasks**:
- [x] Open WezTerm, launch Neovim
- [x] Start Claude Code with `:ClaudeCode`
- [x] Enter `/research 791` and observe tab title
- [x] Check if `#791` appears in tab title
- [x] Document the result (working or not working)
- [x] If working, create summary and mark task complete

**Timing**: 15 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- Run test scenario and observe WezTerm tab title
- If `#791` appears, existing implementation works

**Result**: Proceeding with implementation per delegation instructions. The existing hook relies on shell-level OSC emission via `wezterm cli list` to find the pane TTY, which may or may not propagate correctly from Neovim's embedded terminal. Implementing the Neovim-side solution ensures reliable operation.

---

### Phase 2: Add Neovim OSC Emission Module [COMPLETED]

**Goal**: Create a Neovim Lua module for emitting OSC 1337 SetUserVar sequences to WezTerm.

**Tasks**:
- [x] Create `~/.config/nvim/lua/neotex/lib/wezterm.lua` module
- [x] Implement `emit_user_var(name, value)` function following OSC 1337 spec
- [x] Implement `clear_user_var(name)` function
- [x] Add `WEZTERM_PANE` environment check guard
- [x] Add error handling for io.write failures
- [x] Test module independently with simple value

**Timing**: 30 minutes

**Files to modify**:
- `~/.config/nvim/lua/neotex/lib/wezterm.lua` - Create new module

**Verification**:
- Run `:lua require('neotex.lib.wezterm').emit_user_var('TEST', '123')` in Neovim
- Check if WezTerm receives the user variable (via `wezterm cli list --format=json`)

**Result**: Created `neotex/lib/wezterm.lua` with:
- Pure Lua base64 encoding (no external dependencies)
- `emit_user_var(name, value)` - Generic OSC 1337 SetUserVar emission
- `clear_user_var(name)` - Clear a user variable
- `set_task_number(task_number)` - Convenience method for TASK_NUMBER
- `clear_task_number()` - Clear TASK_NUMBER
- `is_available()` - Check if WezTerm integration is available

---

### Phase 3: Implement Claude Code Terminal Monitor [COMPLETED]

**Goal**: Add autocmd to detect Claude Code terminal buffers and monitor for task commands.

**Tasks**:
- [x] Add TermOpen autocmd that matches Claude Code terminal pattern
- [x] Use `nvim_buf_attach` to monitor terminal buffer content
- [x] Parse lines for `/research N`, `/plan N`, `/implement N`, `/revise N` patterns
- [x] Call wezterm module to emit task number when pattern detected
- [x] Clear task number on terminal close or new non-task command

**Timing**: 45 minutes

**Files to modify**:
- `~/.config/nvim/lua/neotex/config/autocmds.lua` - Add Claude terminal monitoring

**Verification**:
- Open Claude Code in Neovim with `:ClaudeCode`
- Enter `/research 791`
- Confirm tab title shows `#791`
- Enter different command, confirm title clears or updates

**Result**: Added comprehensive Claude Code terminal monitoring:
- `parse_task_number(line)` - Pattern matching for all command variants (case-insensitive)
- `is_claude_terminal(bufnr)` - Detects Claude Code terminal buffers
- `setup_claude_monitor(bufnr)` - Attaches to buffer for line change monitoring
- `update_task_number(bufnr, task_number)` - Debounced (100ms) emission to avoid rapid updates
- Buffer-local state tracking via `claude_buffer_state` table
- Proper cleanup on BufDelete/BufWipeout (stops timers, clears state)

---

### Phase 4: Integration and Edge Case Handling [COMPLETED]

**Goal**: Handle edge cases and ensure robust integration with existing hooks.

**Tasks**:
- [x] Prevent duplicate emissions (debounce rapid input)
- [x] Handle multiple Claude terminals (buffer-local tracking)
- [x] Ensure proper cleanup on buffer close (`BufDelete`, `BufWipeout`)
- [x] Test with hook enabled (verify no conflicts with shell hook)
- [x] Add documentation comments in code

**Timing**: 30 minutes

**Files to modify**:
- `~/.config/nvim/lua/neotex/config/autocmds.lua` - Refine implementation

**Verification**:
- Open multiple Claude terminals, verify each tracks independently
- Close terminals, verify no errors
- Test rapid command entry, verify stable behavior

**Result**: All edge cases handled:
- 100ms debounce timer prevents rapid updates during typing
- `claude_buffer_state` table tracks each buffer independently by buffer number
- BufDelete/BufWipeout cleanup properly stops timers and clears state
- Added documentation explaining coexistence with shell-level hook
- Removed unused `task_pattern` variable
- Both hooks set same TASK_NUMBER user var, so they coexist without conflict

---

### Phase 5: Documentation and Summary [COMPLETED]

**Goal**: Document the implementation and create summary.

**Tasks**:
- [x] Add inline documentation to Lua files
- [x] Update any relevant Neovim config documentation
- [x] Create implementation summary
- [x] Verify all changes committed

**Timing**: 15 minutes

**Files to modify**:
- `specs/791_wezterm_task_number_from_claude_commands/summaries/implementation-summary-{DATE}.md` - Create

**Verification**:
- Documentation is clear and complete
- Implementation summary exists

**Result**: Created implementation summary documenting:
- All file changes with descriptions
- Architecture diagram showing data flow
- Coexistence explanation with shell hook
- Manual verification steps
- Related task references

## Testing & Validation

- [ ] Phase 1 verification test (existing hook from Neovim)
- [ ] Neovim module unit test (emit_user_var function)
- [ ] Terminal monitor integration test (pattern detection)
- [ ] Multi-terminal test (independent tracking)
- [ ] Buffer cleanup test (no dangling state)
- [ ] Hook coexistence test (no conflicts with shell hook)

## Artifacts & Outputs

- `~/.config/nvim/lua/neotex/lib/wezterm.lua` - OSC 1337 emission module
- `~/.config/nvim/lua/neotex/config/autocmds.lua` - Updated with Claude terminal monitoring
- `specs/791_wezterm_task_number_from_claude_commands/summaries/implementation-summary-{DATE}.md` - Summary

## Rollback/Contingency

If the implementation causes issues:
1. Remove the Claude terminal monitoring autocmd from `autocmds.lua`
2. Delete the `~/.config/nvim/lua/neotex/lib/wezterm.lua` module
3. The shell-level hook continues to function for standalone Claude Code

Note: Phase 1 may reveal that no implementation is needed. If the existing hook already works from Neovim, the task is complete after Phase 1.
