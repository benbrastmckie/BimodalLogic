# Implementation Plan: Task #768

- **Task**: 768 - neovim_ctrl_backslash_stt_toggle_claude_code
- **Status**: [NOT STARTED]
- **Effort**: 0.5 hours
- **Priority**: medium
- **Dependencies**: None
- **Research Inputs**: specs/768_neovim_ctrl_backslash_stt_toggle_claude_code/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Replace the non-functional `<C-\>` terminal mode mapping with `<C-'>` for STT toggle in Claude Code sidebar. Research confirmed `<C-\>` is reserved by Neovim in terminal mode and cannot be mapped. The fix requires updating two files: `claudecode.lua` (TermOpen autocmd) and `stt/init.lua` (global terminal mapping). Also fix the unreliable TermOpen pattern by using BufEnter with proper terminal detection.

### Research Integration

- `<C-\>` in terminal mode is reserved by Neovim for escape sequences - cannot be overridden
- TermOpen fires before buffer name is set, making `*claude*` pattern unreliable
- `<C-'>` is available and not reserved in terminal mode
- Normal mode `<C-\>` works fine and should be kept

## Goals & Non-Goals

**Goals**:
- Replace `<C-\>` with `<C-'>` for terminal mode STT toggle
- Remove redundant terminal mode mapping (consolidate to one location)
- Keep normal mode `<C-\>` mapping (it works)

**Non-Goals**:
- Changing the STT transcription logic
- Adding new features to STT plugin
- Fixing the TermOpen pattern issue (separate concern)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `<C-'>` conflicts with existing mapping | M | L | Check for conflicts before implementing |
| User muscle memory on `<C-\>` | L | M | Document the change in commit message |

## Implementation Phases

### Phase 1: Update stt/init.lua [NOT STARTED]

**Goal**: Replace global terminal mode `<C-\>` with `<C-'>`

**Tasks**:
- [ ] Replace `<C-\\>` with `<C-'>` in terminal mode mapping (lines 318-326)
- [ ] Update description text to reflect new key binding

**Timing**: 0.15 hours

**Files to modify**:
- `/home/benjamin/.config/nvim/lua/neotex/plugins/tools/stt/init.lua` - Replace terminal mode `<C-\>` mapping with `<C-'>`

**Verification**:
- Grep for `<C-\\>` should only find normal mode mapping
- Grep for `<C-'>` should find new terminal mode mapping

---

### Phase 2: Update claudecode.lua [NOT STARTED]

**Goal**: Remove redundant terminal mode mapping from TermOpen autocmd

**Tasks**:
- [ ] Remove the `<C-\>` keymap.set block from TermOpen callback (lines 92-97)
- [ ] Keep buffer settings (buflisted, buftype, bufhidden)

**Timing**: 0.15 hours

**Files to modify**:
- `/home/benjamin/.config/nvim/lua/neotex/plugins/ai/claudecode.lua` - Remove redundant terminal STT mapping

**Verification**:
- TermOpen callback should only set buffer options
- No `<C-\\>` mapping in claudecode.lua

---

### Phase 3: Verify and Document [NOT STARTED]

**Goal**: Ensure the changes work correctly

**Tasks**:
- [ ] Verify no terminal mode `<C-\>` mappings remain
- [ ] Confirm `<C-'>` terminal mapping exists in stt/init.lua
- [ ] Confirm normal mode `<C-\>` still exists in stt/init.lua

**Timing**: 0.2 hours

**Files to modify**:
- None (verification only)

**Verification**:
- Manual test: Open Claude Code sidebar, press `<C-'>` to toggle STT
- Verify normal mode `<C-\>` still works outside terminal

## Testing & Validation

- [ ] `<C-'>` toggles STT recording in Claude Code terminal sidebar
- [ ] `<C-\>` toggles STT recording in normal mode (outside terminal)
- [ ] No duplicate mappings or conflicts

## Artifacts & Outputs

- Modified: `/home/benjamin/.config/nvim/lua/neotex/plugins/tools/stt/init.lua`
- Modified: `/home/benjamin/.config/nvim/lua/neotex/plugins/ai/claudecode.lua`

## Rollback/Contingency

If the changes cause issues:
1. Revert to `<C-\>` in terminal mode (even though it doesn't work, it won't break anything)
2. Check for alternative key bindings if `<C-'>` has conflicts
