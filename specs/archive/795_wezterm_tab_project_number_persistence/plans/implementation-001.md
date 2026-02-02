# Implementation Plan: Task #795

- **Task**: 795 - Fix wezterm tab project number persistence for workflow commands
- **Status**: [NOT STARTED]
- **Effort**: 1 hour
- **Dependencies**: Tasks 788-791 completed (WezTerm integration established)
- **Research Inputs**: specs/795_wezterm_tab_project_number_persistence/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

The bug is in the Neovim monitor (`autocmds.lua`) which clears TASK_NUMBER on ANY non-matching prompt, rather than only clearing for explicit non-project commands. The fix adds an `is_clear_command()` function to distinguish between commands that should clear the task number (`/todo`, `/review`, `/meta`, etc.) versus general prompts that should preserve the existing task number.

### Research Integration

- Shell hook (`wezterm-task-number.sh`) behavior is correct - sets on match, does not clear on non-match
- Neovim monitor is overly aggressive - clears on every non-matching line
- Fix should only clear for explicit non-project commands: `/todo`, `/review`, `/meta`, `/learn`, `/lake`, `/refresh`, `/errors`

## Goals & Non-Goals

**Goals**:
- Preserve task number in tab title across general prompts and tool confirmations
- Update/replace task number when running project-bound commands (`/research N`, `/plan N`, `/implement N`, `/revise N`)
- Clear task number only for explicit non-project commands

**Non-Goals**:
- Modifying the shell hook (its behavior is already correct)
- Changing the terminal-close clearing behavior (correct as-is)
- Adding new commands to the project-bound pattern list

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| New commands not in clear list | Low | Medium | Easy to add new patterns; conservative approach preserves task number |
| Pattern matching false positives | Low | Low | Patterns are specific (case-insensitive, match command structure) |
| Stale task number after project switch | Low | Low | User can `/todo` to clear; project commands update correctly |

## Implementation Phases

### Phase 1: Add Clear Command Detection [NOT STARTED]

**Goal**: Add the `is_clear_command()` helper function to detect non-project commands that should clear the task number.

**Tasks**:
- [ ] Read current autocmds.lua to understand exact structure
- [ ] Add `is_clear_command()` local function near the existing task number parsing logic
- [ ] Function should match: `/todo`, `/review`, `/meta`, `/learn`, `/lake`, `/refresh`, `/errors`

**Timing**: 0.25 hours

**Files to modify**:
- `~/.config/nvim/lua/neotex/config/autocmds.lua` - Add helper function

**Verification**:
- Function exists and is syntactically correct
- Lua patterns correctly match test strings

---

### Phase 2: Modify Update Logic [NOT STARTED]

**Goal**: Change the task number update logic to only clear when an explicit non-project command is detected.

**Tasks**:
- [ ] Locate the current clearing logic (around line 201 per research)
- [ ] Change from "clear on non-match" to "clear only on is_clear_command match"
- [ ] Preserve the "set on project command match" behavior unchanged

**Timing**: 0.25 hours

**Files to modify**:
- `~/.config/nvim/lua/neotex/config/autocmds.lua` - Modify update_task_number call logic

**Verification**:
- Logic flow: project command -> set; clear command -> clear; other -> preserve
- No syntax errors in modified code

---

### Phase 3: Manual Testing [NOT STARTED]

**Goal**: Verify the fix works correctly across all command scenarios.

**Tasks**:
- [ ] Open Neovim in WezTerm
- [ ] Launch Claude Code via `:ClaudeCode`
- [ ] Test: `/research 795` sets `#795`
- [ ] Test: `/plan 795` replaces with `#795`
- [ ] Test: General text prompt preserves `#795`
- [ ] Test: `/todo` clears task number
- [ ] Test: `/research 796` sets `#796`
- [ ] Test: Close Claude terminal clears task number

**Timing**: 0.25 hours

**Files to modify**:
- None (testing only)

**Verification**:
- All test scenarios pass per test plan in research report

---

### Phase 4: Update Documentation [NOT STARTED]

**Goal**: Update the WezTerm integration documentation to reflect the new behavior.

**Tasks**:
- [ ] Update `.claude/context/project/hooks/wezterm-integration.md` if needed
- [ ] Document the clear command list and persistence behavior

**Timing**: 0.25 hours

**Files to modify**:
- `.claude/context/project/hooks/wezterm-integration.md` - Update behavior description

**Verification**:
- Documentation accurately describes current behavior
- Clear command list is documented

## Testing & Validation

- [ ] `/research N` sets task number to N
- [ ] `/plan N` sets/replaces task number to N
- [ ] `/implement N` sets/replaces task number to N
- [ ] `/revise N` sets/replaces task number to N
- [ ] General prompts preserve existing task number
- [ ] `/todo` clears task number
- [ ] `/review` clears task number
- [ ] `/meta` clears task number
- [ ] Terminal close clears task number

## Artifacts & Outputs

- Modified `~/.config/nvim/lua/neotex/config/autocmds.lua`
- Updated `/.claude/context/project/hooks/wezterm-integration.md` (if changes needed)

## Rollback/Contingency

If the fix causes issues:
1. Revert changes to `autocmds.lua` using git in the dotfiles repo
2. The shell hook provides standalone functionality outside Neovim
3. Terminal close behavior remains unchanged as safety net
