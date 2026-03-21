# Implementation Plan: Task #795 (Revised v003)

- **Task**: 795 - Fix wezterm tab project number persistence for workflow commands
- **Version**: 003 (Revised)
- **Status**: [NOT STARTED]
- **Effort**: 0.5 hours
- **Dependencies**: Tasks 788-791 completed (WezTerm integration established)
- **Research Inputs**: specs/795_wezterm_tab_project_number_persistence/reports/research-001.md
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Revision Rationale

- **v001**: Maintained a list of "clear commands" - high maintenance burden
- **v002**: Removed all clearing, persisted task number until terminal close - too persistent
- **v003** (this): Clear by default, only show task number when workflow command is running

**Correct behavior**:
- Task number should display ONLY when a workflow command (`/research N`, `/plan N`, `/implement N`, `/revise N`) is actively being processed
- All other prompts, commands, or interactions should clear the task number
- The task number indicates "currently working on task N" not "recently worked on task N"

## Goals & Non-Goals

**Goals**:
- Show task number ONLY during workflow command execution
- Clear task number for all other input (commands, prompts, tool confirmations)
- Zero maintenance burden - only 4 workflow patterns to track (stable set)
- Provide clear visual indication of which task is currently being worked on

**Non-Goals**:
- Persisting task number across multiple prompts
- Tracking non-workflow commands
- Showing task number during general conversation

## Design

**Logic**:
```
on_prompt_submit(line):
  task_number = parse_workflow_command(line)  # returns N or nil
  if task_number:
    set_task_number(task_number)
  else:
    clear_task_number()
```

**Workflow patterns** (stable, unlikely to change):
- `/research N` or `research N`
- `/plan N` or `plan N`
- `/implement N` or `implement N`
- `/revise N` or `revise N`

This is exactly 4 patterns representing the research → plan → implement → revise lifecycle. These are fundamental and won't change with agent system updates.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Task number flickers (set then clear) | Low | Low | Execution is typically long enough to see the number |
| New workflow commands added | Low | Very Low | Core 4 commands are stable lifecycle stages |
| Pattern false negatives | Medium | Low | Patterns are tested and case-insensitive |

## Implementation Phases

### Phase 1: Implement Clear-by-Default Logic [NOT STARTED]

**Goal**: Modify the Neovim monitor to clear task number by default, only setting when a workflow command is detected.

**Tasks**:
- [ ] Read current `autocmds.lua` to understand the task number update logic
- [ ] Modify to: if workflow pattern matches → set; else → clear
- [ ] Keep terminal close clearing as additional cleanup

**Timing**: 0.2 hours

**Files to modify**:
- `~/.config/nvim/lua/neotex/config/autocmds.lua` - Modify task number update logic

**Current logic** (from research):
```lua
-- Sets on match, clears on non-match (but incorrectly clears on ALL non-matches)
if task_number then
  wezterm.set_task_number(task_number)
else
  wezterm.clear_task_number()
end
```

**New logic** (correct behavior - same structure, just ensuring it's applied correctly):
```lua
local task_number = parse_task_number(line)
if task_number then
  wezterm.set_task_number(task_number)
else
  wezterm.clear_task_number()
end
```

The key insight: the current code structure is actually correct! The bug is likely in HOW/WHEN the monitoring fires, not the logic itself. Need to verify the monitor is attached to the right events and parsing the right content.

**Verification**:
- Monitor parses user input lines (not Claude output)
- Set fires on `/research N`, `/plan N`, `/implement N`, `/revise N`
- Clear fires on everything else

---

### Phase 2: Manual Testing [NOT STARTED]

**Goal**: Verify the fix works correctly across all scenarios.

**Test cases**:
- [ ] `/research 795` → shows `#795`
- [ ] `/plan 795` → shows `#795`
- [ ] `/implement 795` → shows `#795`
- [ ] `/revise 795` → shows `#795`
- [ ] `/todo` → clears (no number shown)
- [ ] `/review` → clears
- [ ] `/meta` → clears
- [ ] "Hello, can you help me?" → clears
- [ ] Tool confirmation (y/n) → clears
- [ ] Terminal close → clears

**Timing**: 0.15 hours

**Files to modify**:
- None (testing only)

**Verification**:
- Task number only visible during workflow command execution
- All other input clears the task number

---

### Phase 3: Update Documentation [NOT STARTED]

**Goal**: Update documentation to reflect the clear-by-default behavior.

**Tasks**:
- [ ] Update `.claude/context/project/hooks/wezterm-integration.md`
- [ ] Document: "Task number displays only during workflow command execution"
- [ ] List the 4 workflow commands that show task numbers

**Timing**: 0.15 hours

**Files to modify**:
- `.claude/context/project/hooks/wezterm-integration.md` - Update behavior description

**Verification**:
- Documentation accurately describes clear-by-default behavior
- Workflow commands are listed

## Testing & Validation

| Input | Expected Result |
|-------|-----------------|
| `/research 795` | Tab shows `#795` |
| `/plan 795` | Tab shows `#795` |
| `/implement 795` | Tab shows `#795` |
| `/revise 795` | Tab shows `#795` |
| `/todo` | Tab clears number |
| `/review` | Tab clears number |
| `/meta` | Tab clears number |
| `/lake` | Tab clears number |
| General prompt | Tab clears number |
| Tool confirmation | Tab clears number |
| Terminal close | Tab clears number |

## Artifacts & Outputs

- Modified `~/.config/nvim/lua/neotex/config/autocmds.lua`
- Updated `.claude/context/project/hooks/wezterm-integration.md`

## Version History

| Version | Approach | Issue |
|---------|----------|-------|
| v001 | Maintain list of clear commands | High maintenance burden |
| v002 | Never clear except terminal close | Too persistent |
| v003 | Clear by default, set only for workflow | Correct behavior |

## Rollback/Contingency

The current behavior already clears on non-match, so this may require minimal changes. If issues arise:
1. Revert `autocmds.lua` changes via git
2. Shell hook continues to work independently
3. Terminal close still clears as safety net
