# Research Report: Task #795

**Task**: 795 - Fix wezterm tab project number persistence for workflow commands
**Started**: 2026-02-01T12:00:00Z
**Completed**: 2026-02-01T12:45:00Z
**Effort**: S (simple fix, isolated to one file)
**Dependencies**: Tasks 788-791 completed (WezTerm integration established)
**Sources/Inputs**:
- Codebase: `.claude/hooks/wezterm-task-number.sh`, `~/.config/nvim/lua/neotex/config/autocmds.lua`
- Documentation: `.claude/context/project/hooks/wezterm-integration.md`
**Artifacts**: specs/795_wezterm_tab_project_number_persistence/reports/research-001.md
**Standards**: report-format.md

## Executive Summary

- The current shell hook (`wezterm-task-number.sh`) **only sets** TASK_NUMBER when a pattern matches - it does NOT clear for non-matching prompts (intentional design, see lines 52-56)
- The Neovim monitor (`autocmds.lua`) **does clear** TASK_NUMBER when no pattern matches (line 201) and when terminal closes (line 276)
- **The bug is in the Neovim monitor**: it clears on ANY non-matching prompt, rather than distinguishing between project-bound commands (which should update/replace) vs non-project commands (which should clear)
- **Simple fix**: Modify the Neovim monitor to only clear for explicitly non-project commands like `/todo`, `/review`, `/meta`

## Context & Scope

### Problem Statement

When a user runs `/plan N` or `/implement N` from within Neovim's Claude Code terminal, the tab title correctly shows `#N`. However, the current Neovim monitor clears the task number on ANY command that doesn't match the pattern, including workflow commands that should preserve/update the number.

**Expected behavior**:
- `/research 795` -> Set `#795`
- `/plan 795` -> Set `#795` (replace previous)
- `/implement 795` -> Set `#795` (replace previous)
- `/revise 795` -> Set `#795` (replace previous)
- Other commands -> Persist previous task number

**Current behavior**:
- `/research 795` -> Set `#795`
- (any other prompt) -> Clear task number

### Two Integration Mechanisms

The WezTerm TASK_NUMBER integration has two parallel mechanisms:

| Component | Context | Behavior |
|-----------|---------|----------|
| `wezterm-task-number.sh` | Shell hook (standalone Claude Code) | Sets on match, does NOT clear on non-match |
| `autocmds.lua` | Neovim monitor (embedded Claude Code) | Sets on match, CLEARS on non-match |

The discrepancy is intentional per comment in the shell hook (lines 52-56):
```bash
# Note: We don't clear TASK_NUMBER when pattern doesn't match to allow
# persistence during Claude Code sessions. The Neovim integration (task 791)
# handles clearing on terminal close.
```

However, the Neovim implementation went further and clears on every non-matching line, which is overly aggressive.

## Findings

### 1. Shell Hook Behavior (Correct Pattern)

**File**: `.claude/hooks/wezterm-task-number.sh`

The shell hook:
1. Extracts task number from `/research N`, `/plan N`, `/implement N`, `/revise N` patterns
2. Sets TASK_NUMBER if pattern matches
3. Does NOT clear if pattern doesn't match (persistence during session)
4. Only fires on `UserPromptSubmit` hook event

```bash
# Lines 52-56: Intentional persistence
# Note: We don't clear TASK_NUMBER when pattern doesn't match to allow
# persistence during Claude Code sessions. The Neovim integration (task 791)
# handles clearing on terminal close. This prevents conflicts between the
# shell hook and Neovim's task number monitoring.
```

### 2. Neovim Monitor Behavior (Bug Location)

**File**: `~/.config/nvim/lua/neotex/config/autocmds.lua`

The Neovim monitor:
1. Monitors terminal buffer content via `nvim_buf_attach`
2. Parses lines for `/research N`, `/plan N`, `/implement N`, `/revise N` patterns
3. Sets TASK_NUMBER if pattern matches
4. **Clears TASK_NUMBER if pattern doesn't match** (line 201) - THIS IS THE BUG
5. Clears TASK_NUMBER when terminal closes (line 276) - this is correct

```lua
-- Lines 196-205: Current behavior
if state.last_task_number ~= task_number then
  if task_number then
    wezterm.set_task_number(task_number)
  else
    wezterm.clear_task_number()  -- <-- BUG: clears on ALL non-matching lines
  end
  state.last_task_number = task_number
end
```

### 3. Pattern Matching Details

The patterns matched are identical in both mechanisms:
- `/research N` or `research N` (with optional leading `/`)
- `/plan N` or `plan N`
- `/implement N` or `implement N`
- `/revise N` or `revise N`

Case-insensitive in Neovim (via Lua patterns like `[rR][eE][sS]...`).

### 4. Commands That Should Clear Task Number

Based on the task description, these non-project commands should clear:
- `/todo` - No associated project
- `/review` - No associated project
- `/meta` - No associated project (creates new tasks)
- `/learn` - No associated project
- `/lake` - No associated project
- `/refresh` - No associated project
- `/errors` - No associated project

### 5. Commands That Should Preserve/Update Task Number

Project-bound commands (already handled by setting):
- `/research N`
- `/plan N`
- `/implement N`
- `/revise N`

Other commands that should PRESERVE existing task number:
- General conversation/prompts
- Tool usage confirmations
- Any text that doesn't match a known command

## Recommendations

### Primary Recommendation: Modify Clearing Logic

Change the Neovim monitor to only clear TASK_NUMBER when an explicit non-project command is detected, rather than on every non-matching prompt.

**Implementation approach**:

```lua
-- Add pattern for non-project commands
local function is_clear_command(line)
  -- Match /todo, /review, /meta, /learn, /lake, /refresh, /errors
  return line:match('/?%s*[tT][oO][dD][oO]%s*$')
      or line:match('/?%s*[rR][eE][vV][iI][eE][wW]%s*$')
      or line:match('/?%s*[mM][eE][tT][aA]%s*$')
      or line:match('/?%s*[lL][eE][aA][rR][nN]')
      or line:match('/?%s*[lL][aA][kK][eE]')
      or line:match('/?%s*[rR][eE][fF][rR][eE][sS][hH]')
      or line:match('/?%s*[eE][rR][rR][oO][rR][sS]%s*$')
end

-- Modified update logic
local task_num = parse_task_number(line)
if task_num then
  update_task_number(bufnr, task_num)
elseif is_clear_command(line) then
  update_task_number(bufnr, nil)  -- Clear only for explicit commands
end
-- Otherwise: do nothing (preserve existing)
```

### Alternative: Shell Hook Approach

Could also add clearing logic to `wezterm-task-number.sh`, but:
- Would need to handle both mechanisms consistently
- Neovim monitor already handles terminal close cleanup
- Keeping clearing logic in one place (Neovim) is cleaner

## Decisions

1. **Fix in Neovim monitor only** - Shell hook behavior is correct (no-op on non-match)
2. **Explicit clear command list** - Only clear for known non-project commands
3. **Preserve on unknown input** - Any other text preserves current task number
4. **Keep terminal close clearing** - Still clear when Claude terminal buffer closes

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| New commands not in clear list | Medium | Low | Easy to add new patterns |
| Pattern matching false positives | Low | Low | Patterns are specific enough |
| Stale task number after project switch | Low | Low | User can `/todo` to clear |

## Files to Modify

1. `~/.config/nvim/lua/neotex/config/autocmds.lua` - Add `is_clear_command` function, modify update logic

## Appendix

### Files Examined

- `/home/benjamin/Projects/ProofChecker/.claude/hooks/wezterm-task-number.sh` - Shell hook (no changes needed)
- `/home/benjamin/Projects/ProofChecker/.claude/settings.json` - Hook registration
- `/home/benjamin/.config/nvim/lua/neotex/config/autocmds.lua` - Neovim monitor (needs modification)
- `/home/benjamin/.config/nvim/lua/neotex/lib/wezterm.lua` - OSC emission utilities
- `/home/benjamin/.dotfiles/config/wezterm.lua` - Tab title handler (no changes needed)
- `/home/benjamin/Projects/ProofChecker/.claude/context/project/hooks/wezterm-integration.md` - Documentation

### Related Tasks

- Task 788: WezTerm tab coloring on Claude completion (CLAUDE_STATUS)
- Task 789: WezTerm tab title project and task number (TASK_NUMBER hook)
- Task 790: Neovim WezTerm OSC 7 tab title (OSC 7 emission)
- Task 791: Neovim task number monitoring (original implementation)
- Task 792: Documentation of WezTerm integration

### Test Plan

1. Open Neovim in WezTerm
2. Launch Claude Code via `:ClaudeCode`
3. Enter `/research 795` - verify tab shows `#795`
4. Enter `/plan 795` - verify tab shows `#795` (replace)
5. Enter general text prompt - verify tab still shows `#795` (persist)
6. Enter `/todo` - verify tab number clears
7. Enter `/research 796` - verify tab shows `#796`
8. Close Claude terminal - verify tab number clears
