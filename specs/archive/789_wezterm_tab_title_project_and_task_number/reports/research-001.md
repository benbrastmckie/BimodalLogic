# Research Report: Task #789

**Task**: 789 - Configure WezTerm tab title to show project directory and task number
**Started**: 2026-01-31T12:00:00Z
**Completed**: 2026-01-31T12:15:00Z
**Effort**: S (configuration changes to existing system)
**Dependencies**: None
**Sources/Inputs**: WezTerm documentation, codebase exploration, Claude Code hooks documentation
**Artifacts**: specs/789_wezterm_tab_title_project_and_task_number/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- WezTerm's `format-tab-title` event provides access to `current_working_dir` via the Url object's `file_path` attribute
- User variables (set via OSC 1337) can pass task numbers from Claude Code hooks to WezTerm
- Tab activation detection requires tracking with `wezterm.GLOBAL` since there's no dedicated "on-tab-activated" event
- Existing notification system already uses user variables (CLAUDE_STATUS) with similar patterns

## Context & Scope

The task requires modifying WezTerm configuration at `/home/benjamin/.dotfiles/config/wezterm.lua` and potentially Claude Code hooks to:

1. Display project directory name in tab titles (e.g., `2 ProofChecker`)
2. Append task numbers when running Claude commands (e.g., `2 ProofChecker #788`)
3. Clear notification color when tab becomes active

## Findings

### 1. Current WezTerm Configuration

The existing config at `/home/benjamin/.dotfiles/config/wezterm.lua` already has:

**format-tab-title handler** (lines 203-241):
- Uses `tab.tab_index + 1` for tab number
- Reads `tab.active_pane.title` for title content
- Checks `tab.active_pane.user_vars.CLAUDE_STATUS` for notification coloring
- Returns styled FormatItem array for amber background on inactive tabs needing input

**update-status handler** (lines 248-272):
- Tracks tab changes using `wezterm.GLOBAL.tab_tracking`
- Clears `CLAUDE_STATUS` user variable when tab becomes active
- Uses `tab_pane:inject_output()` to send OSC escape sequence

### 2. Getting Current Working Directory

The `pane.current_working_dir` returns a Url object (since WezTerm 20240127-113634-bbcac864):

```lua
local cwd = tab.active_pane.current_working_dir
if cwd then
  local path = cwd.file_path  -- e.g., "/home/benjamin/Projects/ProofChecker"
  local project_name = path:match("([^/]+)$")  -- e.g., "ProofChecker"
end
```

**Important**: The Url object has these fields:
- `scheme` - URL protocol (e.g., "file")
- `file_path` - Decoded path as filesystem location
- `host` - Hostname
- `path` - Raw path with percent-encoding

**OSC 7 Integration**: For reliable cwd detection, shell integration should emit OSC 7. Fish shell handles this automatically via `fish_title` function.

### 3. User Variables for Task Numbers

WezTerm supports passing data from shell to Lua config via OSC 1337:

**Setting a user variable** (from shell/script):
```bash
printf '\033]1337;SetUserVar=%s=%s\007' TASK_NUMBER $(echo -n "788" | base64)
```

**Reading in Lua**:
```lua
local task_num = tab.active_pane.user_vars.TASK_NUMBER
```

**Existing Pattern**: The project already uses this for `CLAUDE_STATUS`:
- `wezterm-notify.sh` sets `CLAUDE_STATUS=needs_input` on Stop hook
- `wezterm-clear-status.sh` clears it on UserPromptSubmit hook

### 4. Claude Code Hook Integration

From the hooks reference, Claude Code provides:

**UserPromptSubmit hook**: Receives `prompt` field with the user's input. This is where we can parse `/research 788` style commands to extract task numbers.

```json
{
  "hook_event_name": "UserPromptSubmit",
  "prompt": "/research 788"
}
```

**Hook script approach**:
```bash
#!/bin/bash
# Parse task number from prompt
PROMPT=$(cat | jq -r '.prompt')
TASK_NUM=$(echo "$PROMPT" | grep -oP '/(?:research|plan|implement)\s+\K\d+' | head -1)

if [[ -n "$TASK_NUM" ]]; then
  STATUS_VALUE=$(echo -n "$TASK_NUM" | base64)
  printf '\033]1337;SetUserVar=TASK_NUMBER=%s\007' "$STATUS_VALUE" > "$PANE_TTY"
fi
echo '{}'
```

**Stop hook**: Clear the task number when Claude finishes (or keep it for visibility).

### 5. Tab Activation Detection

WezTerm does NOT have a dedicated "on-tab-activated" event. The current implementation uses a workaround:

**Pattern** (already implemented in wezterm.lua lines 248-272):
1. Set `config.status_update_interval = 500` for frequent `update-status` calls
2. Track last active tab per window in `wezterm.GLOBAL.tab_tracking`
3. Detect tab change by comparing current `tab_id` to last tracked
4. On change, clear user variables via `inject_output()`

This approach works but has a 500ms polling delay.

### 6. Alternative Approach: fish_title Function

Fish shell's `fish_title` function sets the terminal title directly:

```fish
function fish_title
    set -l wd (basename (prompt_pwd))
    set -l task ""

    # Check for task number in environment or recent command
    if set -q CLAUDE_TASK_NUMBER
        set task " #$CLAUDE_TASK_NUMBER"
    end

    echo "$wd$task"
end
```

This bypasses WezTerm's format-tab-title entirely by setting the pane title that WezTerm reads.

## Recommendations

### Implementation Approach

**Option A: WezTerm-only (Recommended)**

Modify `format-tab-title` to:
1. Extract project name from `cwd.file_path` using Lua string match
2. Check `user_vars.TASK_NUMBER` for task number suffix
3. Format as `{tab_number} {project_name}` or `{tab_number} {project_name} #{task}`

Add Claude Code hooks to:
1. UserPromptSubmit: Parse command, extract task number, set user variable
2. Stop: Optionally clear task number (or keep for visibility)

Use existing `update-status` handler for color clearing (already works).

**Option B: Fish + WezTerm Hybrid**

Use `fish_title` for basic `{project_name}` display, and user variables for task number overlay. More complex but potentially more responsive.

### Proposed format-tab-title Changes

```lua
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local edge_background = '#1a1a1a'
  local background = tab.is_active and '#3a3a3a' or '#202020'
  local foreground = tab.is_active and '#d0d0d0' or '#808080'

  -- Check for Claude Code notification status on inactive tabs
  if not tab.is_active then
    local active_pane = tab.active_pane
    if active_pane and active_pane.user_vars and active_pane.user_vars.CLAUDE_STATUS == 'needs_input' then
      background = '#e5b566'
      foreground = '#151515'
    end
  end

  -- Build tab title: tab_index + project_name [+ task_number]
  local tab_num = tostring(tab.tab_index + 1)
  local title = tab_num .. ' '

  -- Get project name from cwd
  local cwd = tab.active_pane and tab.active_pane.current_working_dir
  if cwd and cwd.file_path then
    local project_name = cwd.file_path:match("([^/]+)$") or cwd.file_path
    title = title .. project_name
  else
    -- Fallback to pane title
    title = title .. (tab.active_pane and tab.active_pane.title or '')
  end

  -- Add task number if present
  local task_num = tab.active_pane and tab.active_pane.user_vars and tab.active_pane.user_vars.TASK_NUMBER
  if task_num and task_num ~= '' then
    title = title .. ' #' .. task_num
  end

  -- Truncate if too long
  if #title > max_width - 2 then
    title = wezterm.truncate_right(title, max_width - 2)
  end

  local separator = tab.tab_index < #tabs - 1 and '|' or ''

  return {
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = ' ' .. title .. ' ' },
    { Background = { Color = edge_background } },
    { Foreground = { Color = '#404040' } },
    { Text = separator },
  }
end)
```

### Proposed Hook Script

Create `.claude/hooks/wezterm-task-number.sh`:

```bash
#!/bin/bash
# Set TASK_NUMBER user variable for WezTerm tab title
# Called from UserPromptSubmit hook

set -euo pipefail

# Helper: return success JSON
exit_success() {
    echo '{}'
    exit 0
}

# Only run in WezTerm
if [[ -z "${WEZTERM_PANE:-}" ]]; then
    exit_success
fi

# Read prompt from stdin
INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')

# Parse task number from /research N, /plan N, /implement N patterns
TASK_NUM=$(echo "$PROMPT" | grep -oP '^/(?:research|plan|implement|revise)\s+\K\d+' || echo "")

# Get the TTY for the current pane
PANE_TTY=$(wezterm cli list --format=json 2>/dev/null | \
    jq -r ".[] | select(.pane_id == $WEZTERM_PANE) | .tty_name" 2>/dev/null || echo "")

if [[ -z "$PANE_TTY" ]] || [[ ! -w "$PANE_TTY" ]]; then
    exit_success
fi

if [[ -n "$TASK_NUM" ]]; then
    # Set TASK_NUMBER user variable
    STATUS_VALUE=$(echo -n "$TASK_NUM" | base64 | tr -d '\n')
    printf '\033]1337;SetUserVar=TASK_NUMBER=%s\007' "$STATUS_VALUE" > "$PANE_TTY"
else
    # Clear TASK_NUMBER for commands without task numbers
    printf '\033]1337;SetUserVar=TASK_NUMBER=\007' > "$PANE_TTY"
fi

exit_success
```

### Settings.json Addition

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/wezterm-task-number.sh 2>/dev/null || echo '{}'"
          },
          {
            "type": "command",
            "command": "bash .claude/hooks/wezterm-clear-status.sh 2>/dev/null || echo '{}'"
          }
        ]
      }
    ]
  }
}
```

### Color Clearing on Tab Activation

The existing implementation in wezterm.lua (lines 248-272) already handles this:
- `update-status` fires every 500ms
- Tracks tab changes via `wezterm.GLOBAL.tab_tracking`
- Clears `CLAUDE_STATUS` via `inject_output()` when tab becomes active

This should be extended to also clear `TASK_NUMBER` color effects (if any) or simply the `CLAUDE_STATUS` clearing is sufficient since task number doesn't affect color.

The color IS cleared when tab becomes active - the amber background is only applied when `not tab.is_active` AND `CLAUDE_STATUS == 'needs_input'`. The existing implementation works correctly.

## Decisions

1. **Use Option A (WezTerm-only)**: Simpler, leverages existing patterns
2. **Parse task from prompt**: Use grep pattern for `/research|plan|implement N`
3. **Keep task number visible**: Don't clear on Stop, only on new command without task
4. **Color clearing works**: Existing implementation is correct

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| `current_working_dir` returns nil | Fallback to pane title |
| User variable not set on first run | Initialize to empty, handle gracefully |
| 500ms polling delay for color clear | Acceptable UX trade-off |
| Commands without task numbers show stale task | Clear on UserPromptSubmit when no task parsed |

## Appendix

### Search Queries Used
- "WezTerm format-tab-title lua cwd current working directory 2026"
- "WezTerm user variables OSC 1337 SetUserVar custom data terminal"
- "WezTerm Url object file_path extract path from get_current_working_dir lua"
- "WezTerm tab activation event callback lua on active tab changed"
- "Claude Code CLI hooks environment variables CLAUDE_TOOL_INPUT passing data to hooks 2026"

### Documentation References
- [WezTerm format-tab-title](https://wezterm.org/config/lua/window-events/format-tab-title.html)
- [WezTerm get_current_working_dir](https://wezterm.org/config/lua/pane/get_current_working_dir.html)
- [WezTerm Url object](https://wezterm.org/config/lua/wezterm.url/Url.html)
- [WezTerm user-var-changed](https://wezterm.org/config/lua/window-events/user-var-changed.html)
- [WezTerm TabInformation](https://wezterm.org/config/lua/TabInformation.html)
- [WezTerm Passing Data from Pane to Lua](https://wezterm.org/recipes/passing-data.html)
- [WezTerm Shell Integration](https://wezterm.org/shell-integration.html)
- [Claude Code Hooks Reference](https://code.claude.com/docs/en/hooks)
- [GitHub Discussion: Place current_working_dir in Tab title](https://github.com/wezterm/wezterm/discussions/5890)

### Existing Files Reviewed
- `/home/benjamin/.dotfiles/config/wezterm.lua` - Current WezTerm config
- `/home/benjamin/Projects/ProofChecker/.claude/hooks/wezterm-notify.sh` - Stop hook notification
- `/home/benjamin/Projects/ProofChecker/.claude/hooks/wezterm-clear-status.sh` - UserPromptSubmit clear hook
- `/home/benjamin/Projects/ProofChecker/.claude/settings.json` - Hook configuration
