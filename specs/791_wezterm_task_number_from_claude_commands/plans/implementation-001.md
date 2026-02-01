# Implementation Plan: Task #791

- **Task**: 791 - Extend WezTerm task number integration for Claude Code commands
- **Status**: [IMPLEMENTING]
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

### Phase 1: Verify Current Implementation [NOT STARTED]

**Goal**: Determine if the existing wezterm-task-number.sh hook already works from within Neovim's Claude Code terminal.

**Tasks**:
- [ ] Open WezTerm, launch Neovim
- [ ] Start Claude Code with `:ClaudeCode`
- [ ] Enter `/research 791` and observe tab title
- [ ] Check if `#791` appears in tab title
- [ ] Document the result (working or not working)
- [ ] If working, create summary and mark task complete

**Timing**: 15 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- Run test scenario and observe WezTerm tab title
- If `#791` appears, existing implementation works

---

### Phase 2: Add Neovim OSC Emission Module [NOT STARTED]

**Goal**: Create a Neovim Lua module for emitting OSC 1337 SetUserVar sequences to WezTerm.

**Tasks**:
- [ ] Create `~/.config/nvim/lua/neotex/lib/wezterm.lua` module
- [ ] Implement `emit_user_var(name, value)` function following OSC 1337 spec
- [ ] Implement `clear_user_var(name)` function
- [ ] Add `WEZTERM_PANE` environment check guard
- [ ] Add error handling for io.write failures
- [ ] Test module independently with simple value

**Timing**: 30 minutes

**Files to modify**:
- `~/.config/nvim/lua/neotex/lib/wezterm.lua` - Create new module

**Verification**:
- Run `:lua require('neotex.lib.wezterm').emit_user_var('TEST', '123')` in Neovim
- Check if WezTerm receives the user variable (via `wezterm cli list --format=json`)

---

### Phase 3: Implement Claude Code Terminal Monitor [NOT STARTED]

**Goal**: Add autocmd to detect Claude Code terminal buffers and monitor for task commands.

**Tasks**:
- [ ] Add TermOpen autocmd that matches Claude Code terminal pattern
- [ ] Use `nvim_buf_attach` to monitor terminal buffer content
- [ ] Parse lines for `/research N`, `/plan N`, `/implement N`, `/revise N` patterns
- [ ] Call wezterm module to emit task number when pattern detected
- [ ] Clear task number on terminal close or new non-task command

**Timing**: 45 minutes

**Files to modify**:
- `~/.config/nvim/lua/neotex/config/autocmds.lua` - Add Claude terminal monitoring

**Verification**:
- Open Claude Code in Neovim with `:ClaudeCode`
- Enter `/research 791`
- Confirm tab title shows `#791`
- Enter different command, confirm title clears or updates

---

### Phase 4: Integration and Edge Case Handling [NOT STARTED]

**Goal**: Handle edge cases and ensure robust integration with existing hooks.

**Tasks**:
- [ ] Prevent duplicate emissions (debounce rapid input)
- [ ] Handle multiple Claude terminals (buffer-local tracking)
- [ ] Ensure proper cleanup on buffer close (`BufDelete`, `BufWipeout`)
- [ ] Test with hook enabled (verify no conflicts with shell hook)
- [ ] Add documentation comments in code

**Timing**: 30 minutes

**Files to modify**:
- `~/.config/nvim/lua/neotex/config/autocmds.lua` - Refine implementation

**Verification**:
- Open multiple Claude terminals, verify each tracks independently
- Close terminals, verify no errors
- Test rapid command entry, verify stable behavior

---

### Phase 5: Documentation and Summary [NOT STARTED]

**Goal**: Document the implementation and create summary.

**Tasks**:
- [ ] Add inline documentation to Lua files
- [ ] Update any relevant Neovim config documentation
- [ ] Create implementation summary
- [ ] Verify all changes committed

**Timing**: 15 minutes

**Files to modify**:
- `specs/791_wezterm_task_number_from_claude_commands/summaries/implementation-summary-{DATE}.md` - Create

**Verification**:
- Documentation is clear and complete
- Implementation summary exists

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
