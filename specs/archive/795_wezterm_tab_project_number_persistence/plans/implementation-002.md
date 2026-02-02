# Implementation Plan: Task #795 (Revised)

- **Task**: 795 - Fix wezterm tab project number persistence for workflow commands
- **Version**: 002 (Revised)
- **Status**: [NOT STARTED]
- **Effort**: 0.5 hours
- **Dependencies**: Tasks 788-791 completed (WezTerm integration established)
- **Research Inputs**: specs/795_wezterm_tab_project_number_persistence/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Revision Rationale

The original plan (v001) required maintaining a list of "clear commands" (`/todo`, `/review`, `/meta`, etc.) in the Neovim configuration. This creates a maintenance burden since the agent system's command set may evolve, requiring synchronous updates to the Neovim config.

**New approach**: Remove all clearing logic from the Neovim monitor except for terminal close. The task number will:
1. **Set/update** when a project-bound command (`/research N`, `/plan N`, `/implement N`, `/revise N`) is detected
2. **Persist** for all other input (no clearing)
3. **Clear** only when the Claude terminal closes

This design:
- Eliminates the need to maintain command lists in Neovim
- Is forward-compatible with any future agent commands
- Still provides the primary value (showing which task is being worked on)
- Uses terminal close as the natural "session end" clear trigger

## Goals & Non-Goals

**Goals**:
- Preserve task number across all prompts within a Claude session
- Update task number when running project-bound commands (`/research N`, `/plan N`, `/implement N`, `/revise N`)
- Clear task number only on terminal close (natural session boundary)
- Zero maintenance burden for Neovim config when agent commands change

**Non-Goals**:
- Providing explicit per-command clearing (user can close/reopen Claude terminal)
- Modifying the shell hook (its behavior is already correct)
- Adding command awareness to Neovim beyond the 4 project-bound patterns

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Task number persists longer than expected | Low | Medium | Terminal close clears; user can restart Claude session |
| User switches projects without closing terminal | Low | Medium | Project-bound commands update the number; worst case shows old number |
| New project-bound commands not detected | Low | Low | Only 4 patterns needed; these are stable (research/plan/implement/revise cycle) |

## Implementation Phases

### Phase 1: Remove Clearing Logic [NOT STARTED]

**Goal**: Modify the Neovim monitor to remove the "clear on non-match" behavior, keeping only "set on match".

**Tasks**:
- [ ] Read current `autocmds.lua` to locate the clearing logic (around line 201)
- [ ] Remove the `else` branch that calls `wezterm.clear_task_number()`
- [ ] Keep the `if task_number then set` branch unchanged
- [ ] Keep the terminal close clearing (line 276) unchanged

**Timing**: 0.15 hours

**Files to modify**:
- `~/.config/nvim/lua/neotex/config/autocmds.lua` - Remove else branch in task number update

**Current code** (to be modified):
```lua
if state.last_task_number ~= task_number then
  if task_number then
    wezterm.set_task_number(task_number)
  else
    wezterm.clear_task_number()  -- REMOVE THIS BRANCH
  end
  state.last_task_number = task_number
end
```

**New code**:
```lua
if task_number and state.last_task_number ~= task_number then
  wezterm.set_task_number(task_number)
  state.last_task_number = task_number
end
```

**Verification**:
- Lua syntax is correct
- Only the clearing branch is removed
- Terminal close clearing is preserved

---

### Phase 2: Manual Testing [NOT STARTED]

**Goal**: Verify the fix works correctly across all command scenarios.

**Tasks**:
- [ ] Open Neovim in WezTerm
- [ ] Launch Claude Code via `:ClaudeCode`
- [ ] Test: `/research 795` sets `#795`
- [ ] Test: `/plan 795` replaces with `#795`
- [ ] Test: General text prompt preserves `#795`
- [ ] Test: `/todo` preserves `#795` (changed from v001: was "clears")
- [ ] Test: `/review` preserves `#795`
- [ ] Test: `/research 796` sets `#796`
- [ ] Test: Close Claude terminal clears task number

**Timing**: 0.15 hours

**Files to modify**:
- None (testing only)

**Verification**:
- All test scenarios pass
- Task number persists until terminal close or project command updates it

---

### Phase 3: Update Documentation [NOT STARTED]

**Goal**: Update the WezTerm integration documentation to reflect the simplified behavior.

**Tasks**:
- [ ] Update `.claude/context/project/hooks/wezterm-integration.md`
- [ ] Document: "Task number persists for session, only clears on terminal close"
- [ ] Remove any references to per-command clearing behavior

**Timing**: 0.2 hours

**Files to modify**:
- `.claude/context/project/hooks/wezterm-integration.md` - Update behavior description

**Verification**:
- Documentation accurately describes current behavior
- No mention of command-specific clearing

## Testing & Validation

- [ ] `/research N` sets task number to N
- [ ] `/plan N` sets/replaces task number to N
- [ ] `/implement N` sets/replaces task number to N
- [ ] `/revise N` sets/replaces task number to N
- [ ] General prompts preserve existing task number
- [ ] `/todo` preserves task number (session persistence)
- [ ] `/review` preserves task number (session persistence)
- [ ] `/meta` preserves task number (session persistence)
- [ ] Terminal close clears task number

## Artifacts & Outputs

- Modified `~/.config/nvim/lua/neotex/config/autocmds.lua` (simplified, ~5 lines changed)
- Updated `.claude/context/project/hooks/wezterm-integration.md`

## Comparison with v001

| Aspect | v001 | v002 (this plan) |
|--------|------|------------------|
| Commands to maintain in Neovim | 7+ clear commands | 4 set commands (stable) |
| Maintenance burden | High (add new commands) | None (set commands are fixed) |
| Clear behavior | Per-command | Terminal close only |
| User control | Explicit `/todo` clears | Close terminal to clear |
| Complexity | Medium (pattern matching for clears) | Low (remove code) |

## Rollback/Contingency

If users strongly prefer explicit clearing via commands:
1. v001 approach can be revisited
2. Could add a dedicated `/clear-task` command instead of using `/todo`
3. Current v002 is strictly simpler and can be enhanced if needed
