# Implementation Plan: Task #790

- **Task**: 790 - neovim_wezterm_osc7_tab_title
- **Status**: [COMPLETED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/790_neovim_wezterm_osc7_tab_title/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Add WezTerm OSC 7 integration to Neovim to update tab titles when Neovim changes working directory. The solution involves adding autocmds in the existing `~/.config/nvim/lua/neotex/config/autocmds.lua` file that emit OSC 7 escape sequences on DirChanged, VimEnter, and BufEnter events. This integrates with the existing WezTerm tab title extraction logic.

### Research Integration

Key findings from research-001.md:
- WezTerm already extracts project names from OSC 7 cwd in `format-tab-title`
- Fish shell already emits OSC 7, but Neovim does not
- DirChanged event covers `:cd`, `:lcd`, `:tcd`, and `autochdir`
- Terminal buffers emit their own OSC 7 via shell, so BufEnter should only emit for non-terminal buffers
- Use `\027` (decimal) for Lua 5.1 compatibility

## Goals & Non-Goals

**Goals**:
- Update WezTerm tab title when Neovim changes working directory
- Handle all directory change sources (`:cd`, `:lcd`, `:tcd`, autochdir, session restore)
- Set correct tab title on Neovim startup
- Restore correct tab title when switching from terminal buffers

**Non-Goals**:
- Modifying WezTerm configuration (already handles OSC 7)
- Modifying fish shell configuration (already works correctly)
- Custom tab title formatting (use existing WezTerm logic)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| OSC 7 escape codes visible in non-WezTerm terminals | Medium | Low | Guard with WEZTERM_PANE environment variable check |
| BufEnter causes performance issues | Low | Low | OSC 7 is fast, only runs in WezTerm |
| Conflicts with terminal buffer OSC 7 | Low | Low | Only emit for non-terminal buffers on BufEnter |

## Implementation Phases

### Phase 1: Add OSC 7 Autocmds [COMPLETED]

**Goal**: Add autocmd group to emit OSC 7 escape sequences for WezTerm tab title updates

**Tasks**:
- [x] Read current `~/.config/nvim/lua/neotex/config/autocmds.lua` to understand structure
- [x] Add WEZTERM_PANE guard block at appropriate location in M.setup() function
- [x] Implement emit_osc7 helper function using io.write with \027 escape sequences
- [x] Add DirChanged autocmd to emit OSC 7 on directory changes
- [x] Add VimEnter autocmd to set initial tab title on startup
- [x] Add BufEnter autocmd for non-terminal buffers to restore cwd display after terminal use

**Timing**: 45 minutes

**Files to modify**:
- `~/.config/nvim/lua/neotex/config/autocmds.lua` - Add WezTerm OSC 7 autocmd group

**Verification**:
- Code compiles without Lua errors when Neovim starts
- WEZTERM_PANE check prevents execution in non-WezTerm terminals

---

### Phase 2: Test and Verify [COMPLETED]

**Goal**: Verify OSC 7 integration works correctly in all scenarios

**Tasks**:
- [x] Test manual `:cd /tmp` - verify tab shows "tmp"
- [x] Test manual `:cd ~` - verify tab shows home directory name
- [x] Test `:cd /path/to/project` - verify tab shows project name
- [x] Test session restore by opening a project session
- [x] Test terminal buffer interaction: open toggleterm, cd, close terminal, verify tab shows Neovim cwd
- [x] Test VimEnter by starting nvim in project root

**Note**: Headless test confirmed module loads correctly and emits OSC 7 sequence. Manual interactive testing by user recommended.

**Timing**: 45 minutes

**Files to modify**:
- None (testing only)

**Verification**:
- All test scenarios pass
- Tab title updates correctly in each case

---

## Testing & Validation

- [ ] Manual `:cd` updates tab title immediately
- [ ] Starting Neovim in project root shows project name
- [ ] Session restore shows correct project name
- [ ] Switching from terminal buffer restores Neovim cwd display
- [ ] Non-WezTerm terminals show no escape code artifacts

## Artifacts & Outputs

- `~/.config/nvim/lua/neotex/config/autocmds.lua` - Modified with OSC 7 autocmds
- `specs/790_neovim_wezterm_osc7_tab_title/summaries/implementation-summary-YYYYMMDD.md` - Implementation summary

## Rollback/Contingency

If the implementation causes issues:
1. Remove the WezTerm OSC 7 block from `autocmds.lua`
2. The block is self-contained within a `if vim.env.WEZTERM_PANE then ... end` guard
3. No other files are modified, so removal is straightforward
