# Implementation Plan: Fix Claude Code Neovim Sidebar 30-Second Delay

- **Task**: 770 - Fix Claude Code Neovim sidebar 30-second delay
- **Status**: [COMPLETED]
- **Effort**: 1 hour
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/770_fix_claude_code_neovim_sidebar_30s_delay/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Fix three bugs causing the 30-second blank delay when opening Claude Code sidebar from Neovim. The root cause is that the SessionStart hook in `claude-ready-signal.sh` fails silently due to a wrong Lua module path and incorrect `luaeval()` syntax. Additionally, the fallback detection in `terminal-state.lua` uses the wrong autocommand event for terminal buffers.

### Research Integration

Research report (research-001.md) identified:
1. Wrong module path: `neotex.plugins.ai.claude.utils.terminal-state` should be `neotex.plugins.ai.claude.claude-session.terminal-state`
2. Wrong Lua eval syntax: `luaeval("require(...)")` should be `v:lua.require(...)`
3. Missing TextChangedT event for terminal-mode fallback detection

## Goals & Non-Goals

**Goals**:
- Eliminate 30-second delay when opening Claude Code sidebar from Neovim
- Fix the signal hook to correctly notify terminal-state.lua
- Add debug logging to verify signal path works

**Non-Goals**:
- Restructuring terminal-state.lua architecture
- Supporting multiple simultaneous Claude Code sessions
- Adding new features beyond fixing the delay

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Hook changes not taking effect | Low | Medium | Restart Claude Code after changes |
| Neovim version incompatibility with v:lua syntax | Low | Low | Tested on nvim 0.11.5 in research |
| Debug logging introduces overhead | Low | Low | Log to /tmp, minimal I/O |

## Implementation Phases

### Phase 1: Fix claude-ready-signal.sh [COMPLETED]

**Goal**: Correct the module path and Lua eval syntax in the signal hook script

**Tasks**:
- [ ] Open `~/.config/nvim/scripts/claude-ready-signal.sh`
- [ ] Change module path from `neotex.plugins.ai.claude.utils.terminal-state` to `neotex.plugins.ai.claude.claude-session.terminal-state`
- [ ] Change from `luaeval("require(...)")` syntax to `v:lua.require(...)` syntax
- [ ] Add debug logging to `/tmp/claude-ready-signal.log`

**Timing**: 15 minutes

**Files to modify**:
- `~/.config/nvim/scripts/claude-ready-signal.sh` - Fix module path, syntax, add logging

**Verification**:
- Manual review of script syntax
- Test signal path by running script with $NVIM set

---

### Phase 2: Fix terminal-state.lua TextChanged Event [COMPLETED]

**Goal**: Add TextChangedT to the autocommand events for terminal buffer detection

**Tasks**:
- [ ] Open `~/.config/nvim/lua/neotex/plugins/ai/claude/claude-session/terminal-state.lua`
- [ ] Find the TextChanged autocommand (around line 352)
- [ ] Change `"TextChanged"` to `{ "TextChanged", "TextChangedT" }` to cover both modes

**Timing**: 10 minutes

**Files to modify**:
- `~/.config/nvim/lua/neotex/plugins/ai/claude/claude-session/terminal-state.lua` - Add TextChangedT event

**Verification**:
- Syntax check (open file in Neovim, no Lua errors)

---

### Phase 3: Verification and Testing [COMPLETED]

**Goal**: Verify the fix works end-to-end

**Tasks**:
- [ ] Close any running Claude Code sessions
- [ ] Clear old debug log: `rm -f /tmp/claude-ready-signal.log`
- [ ] Open Neovim and launch Claude Code (`:Claude`)
- [ ] Verify sidebar becomes responsive immediately (not 30 seconds)
- [ ] Check `/tmp/claude-ready-signal.log` for successful signal
- [ ] Verify no errors in `:messages`

**Timing**: 10 minutes

**Verification**:
- Sidebar responds within 2 seconds (previously 30 seconds)
- Debug log shows `Result: vim.NIL (exit: 0)` indicating success

## Testing & Validation

- [ ] Sidebar opens immediately when Claude Code launched from Neovim
- [ ] Debug log at `/tmp/claude-ready-signal.log` shows successful signal
- [ ] No Lua errors in Neovim `:messages`
- [ ] Commands queued before Claude ready are executed promptly

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-20260130.md (after completion)
- Debug log at /tmp/claude-ready-signal.log (temporary, for verification)

## Rollback/Contingency

If changes cause issues:
1. Revert `claude-ready-signal.sh` to use original (broken) syntax - sidebar will still work after 30-second timeout
2. Revert `terminal-state.lua` TextChanged change - fallback detection returns to previous behavior
3. Both files are version-controlled in neotex config repo; `git checkout` can restore

The 30-second delay is merely inconvenient, not functionality-breaking, so rollback impact is minimal.
