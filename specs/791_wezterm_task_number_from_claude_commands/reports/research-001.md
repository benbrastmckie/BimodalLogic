# Research Report: Task #791

**Task**: 791 - Extend WezTerm task number integration for Claude Code commands
**Started**: 2026-02-01T12:00:00Z
**Completed**: 2026-02-01T12:30:00Z
**Effort**: M (moderate complexity, multiple integration points)
**Dependencies**: Tasks 788-790 completed, greggh/claude-code.nvim plugin
**Sources/Inputs**:
- Codebase: `.claude/hooks/wezterm-task-number.sh`, `~/.dotfiles/config/wezterm.lua`, `~/.config/nvim/lua/neotex/`
- Web: WezTerm documentation (wezterm.org), Neovim documentation (neovim.io), greggh/claude-code.nvim
**Artifacts**: specs/791_wezterm_task_number_from_claude_commands/reports/research-001.md
**Standards**: report-format.md

## Executive Summary

- The current `wezterm-task-number.sh` hook parses prompts at shell level via `CLAUDE_USER_PROMPT` environment variable
- When Claude Code runs inside Neovim (via greggh/claude-code.nvim), user input goes directly to the embedded terminal buffer, bypassing shell-level hooks
- **Three implementation approaches identified**: (A) Neovim terminal input interception, (B) Extension of existing wezterm-task-number.sh hook with SubagentStop/Stop events, (C) coder/claudecode.nvim migration with WebSocket integration
- **Recommended approach**: Option B - leverage existing hooks infrastructure with UserPromptSubmit event and terminal text monitoring

## Context & Scope

### Problem Statement

The current implementation (task 789) successfully displays task numbers in WezTerm tab titles when Claude Code commands are executed from the shell prompt. The `wezterm-task-number.sh` hook parses the `CLAUDE_USER_PROMPT` environment variable on `UserPromptSubmit` events.

However, when running Claude Code from within Neovim (using the greggh/claude-code.nvim plugin), user prompts are sent directly to the embedded terminal buffer. The shell-level hooks still fire, but the environment variable contains the prompt text as typed in the Neovim terminal, which does work for direct slash commands but may have different behavior.

**Key Question**: Do the existing hooks already work for Neovim-embedded Claude Code?

### Current Implementation Analysis

#### wezterm-task-number.sh (Current Hook)

```bash
# Extract from .claude/hooks/wezterm-task-number.sh
PROMPT="${CLAUDE_USER_PROMPT:-}"

# Matches: /research N, /plan N, /implement N, /revise N
if [[ "$PROMPT" =~ ^[[:space:]]*/?(research|plan|implement|revise)[[:space:]]+([0-9]+) ]]; then
    TASK_NUMBER="${BASH_REMATCH[2]}"
fi
```

The hook:
1. Reads `CLAUDE_USER_PROMPT` environment variable (set by Claude Code on UserPromptSubmit)
2. Parses for `/research N`, `/plan N`, `/implement N`, `/revise N` patterns
3. Sets `TASK_NUMBER` user variable via OSC 1337 to the pane's TTY

#### WezTerm Configuration

```lua
-- From ~/.dotfiles/config/wezterm.lua lines 246-253
-- Append task number if set via TASK_NUMBER user variable
if active_pane and active_pane.user_vars and active_pane.user_vars.TASK_NUMBER then
  local task_num = active_pane.user_vars.TASK_NUMBER
  if task_num and task_num ~= '' then
    title = title .. ' #' .. task_num
  end
end
```

#### Neovim OSC 7 Integration (Task 790)

Task 790 established the pattern for emitting escape sequences from Neovim:

```lua
-- From ~/.config/nvim/lua/neotex/config/autocmds.lua
if vim.env.WEZTERM_PANE then
  local function emit_osc7()
    local cwd = vim.fn.getcwd()
    local hostname = vim.fn.hostname()
    local osc7 = string.format("\027]7;file://%s%s\007", hostname, cwd)
    io.write(osc7)
    io.flush()
  end
end
```

This demonstrates that Neovim CAN emit OSC escape sequences that WezTerm processes.

## Findings

### 1. Claude Code Hooks Environment Variables

When Claude Code fires hooks (UserPromptSubmit, Stop, etc.), it sets environment variables including:
- `CLAUDE_USER_PROMPT` - The user's prompt text
- `WEZTERM_PANE` - The WezTerm pane ID (inherited from shell)

**Key Finding**: The `CLAUDE_USER_PROMPT` variable is set regardless of whether Claude Code runs in a standalone terminal or embedded in Neovim. The hook script should work in both contexts.

### 2. Neovim Claude Code Integration (greggh/claude-code.nvim)

The greggh/claude-code.nvim plugin:
- Creates a terminal buffer within Neovim
- Runs Claude Code CLI as a terminal job
- Provides commands like `:ClaudeCode`, `:ClaudeCodeContinue`
- Does NOT intercept or modify user input before sending to terminal

The terminal buffer inherits the `WEZTERM_PANE` environment variable from the parent Neovim process. When Claude Code fires hooks, they execute in the same environment.

### 3. Testing the Current Implementation

**Hypothesis**: The current wezterm-task-number.sh hook should already work for Neovim-embedded Claude Code.

**Rationale**:
1. Claude Code hooks fire regardless of how Claude Code was launched
2. `CLAUDE_USER_PROMPT` is set by Claude Code itself, not the shell
3. `WEZTERM_PANE` is inherited from the parent environment

**Verification Needed**: Test running `/research 791` from within Neovim's Claude Code terminal to see if the task number appears in the tab title.

### 4. Potential Issues

#### Issue A: TTY Path Resolution

The current hook uses:
```bash
PANE_TTY=$(wezterm cli list --format=json 2>/dev/null | \
    jq -r ".[] | select(.pane_id == $WEZTERM_PANE) | .tty_name" 2>/dev/null || echo "")
```

When Claude Code runs inside Neovim, the `WEZTERM_PANE` points to the parent WezTerm pane (the one running Neovim), not a sub-pane. This should still work correctly because:
- The Neovim terminal buffer shares the same PTY as its host pane
- The OSC escape sequence written to that TTY will be processed by WezTerm

#### Issue B: Escape Sequence Routing

OSC 1337 sequences written to a PTY are processed by the terminal emulator (WezTerm). When Neovim runs in WezTerm:
- Neovim creates a pseudo-terminal (PTY) for its embedded terminal buffers
- The inner PTY output goes to Neovim's stdout, which goes to WezTerm's PTY
- OSC sequences should pass through correctly

**Potential Problem**: If Neovim's terminal emulation strips or modifies OSC sequences, they may not reach WezTerm.

### 5. Alternative Approach: Neovim-Side OSC 1337 Emission

If the hook-based approach doesn't work from within Neovim, we could add Neovim autocmds to emit OSC 1337 directly, similar to the OSC 7 implementation from task 790.

**Concept**:
```lua
-- Hypothetical Neovim autocmd for task number
if vim.env.WEZTERM_PANE then
  local function emit_task_number(task_num)
    local encoded = vim.fn.system("echo -n '" .. task_num .. "' | base64 | tr -d '\\n'")
    local osc = string.format("\027]1337;SetUserVar=TASK_NUMBER=%s\007", encoded)
    io.write(osc)
    io.flush()
  end

  -- Monitor terminal input for /research N, /plan N patterns
  -- Problem: No direct hook for terminal input before it's sent
end
```

**Challenge**: Neovim doesn't provide a direct autocmd for intercepting terminal input before it's sent. Available events:
- `TermEnter` / `TermLeave` - Terminal mode changes
- `TextChangedT` - After text changes in terminal mode (too late)
- `TermRequest` - For OSC/DCS sequences FROM the terminal process

### 6. coder/claudecode.nvim Alternative

The coder/claudecode.nvim plugin uses a WebSocket-based MCP protocol that could potentially provide hooks for user input. However:
- Requires migration from greggh/claude-code.nvim
- More complex integration
- Not needed if existing hooks work

## Recommendations

### Primary Recommendation: Test Existing Implementation

Before implementing any changes, verify whether the current hook already works:

1. Open Neovim in WezTerm
2. Launch Claude Code via `:ClaudeCode`
3. Enter `/research 791`
4. Check if tab title updates to include `#791`

If this works, no implementation is needed.

### If Current Implementation Fails: Option B - Enhanced Hook

If the current implementation doesn't work due to TTY routing issues, the solution is to emit OSC 1337 from within Neovim after detecting Claude Code startup.

**Implementation Plan**:

1. **Add Neovim autocmd for Claude Code terminal buffers**:
   - Listen for `TermOpen` events matching Claude Code pattern
   - Monitor terminal output for prompt patterns (using `TermRequest` or output callbacks)

2. **Parse user input from Neovim side**:
   - Use `nvim_buf_attach` on the Claude Code terminal buffer
   - Capture lines as they're added (user input echoes back)
   - Parse for `/research N`, `/plan N`, `/implement N` patterns

3. **Emit OSC 1337 from Neovim**:
   - When task number detected, emit OSC 1337 via `io.write()`
   - This goes directly to WezTerm (bypassing inner PTY issues)

### If Direct Terminal Input Needed: Option C - Terminal Keymap Hook

If we need to intercept input BEFORE it's sent to the terminal:

```lua
-- Create a wrapper for terminal input
vim.keymap.set('t', '<CR>', function()
  -- Get current line content (user's input)
  local line = vim.api.nvim_get_current_line()

  -- Check for task number patterns
  local task_num = line:match('^/?%s*(research|plan|implement|revise)%s+(%d+)')
  if task_num then
    emit_task_number(task_num)
  end

  -- Send the actual Enter key
  return '<CR>'
end, { expr = true, buffer = claude_bufnr })
```

**Limitation**: This intercepts Enter key presses, which may interfere with normal terminal operation.

## Decisions

1. **First: Verify current implementation works** - Test before implementing
2. **If needed: Use Neovim-side OSC emission** - More reliable than depending on hook TTY routing
3. **Avoid terminal keymap hooks** - Too invasive, may break terminal interaction
4. **Keep hook as fallback** - The shell-level hook should work for standalone Claude Code

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Current implementation already works | Medium | Low (positive outcome) | Test first before implementing |
| Inner PTY strips OSC sequences | Low | High | Emit from Neovim side instead |
| Neovim terminal buffer monitoring too slow | Low | Medium | Use efficient autocmds |
| Terminal keymap hooks break Claude interaction | Medium | High | Avoid keymap approach |
| Multiple Claude instances cause conflicts | Low | Low | Use pane-specific tracking |

## Appendix

### Search Queries Used

1. "greggh/claude-code.nvim callbacks hooks terminal prompt events 2026"
2. "WezTerm OSC 1337 SetUserVar neovim emit escape sequence terminal 2026"
3. "neovim terminal detect user input autocmd terminal input callback 2026"
4. "coder/claudecode.nvim hooks callbacks prompt events integration 2026"

### Documentation References

- [WezTerm Escape Sequences](https://wezterm.org/escape-sequences.html) - OSC 1337 SetUserVar documentation
- [WezTerm Shell Integration](https://wezterm.org/shell-integration.html) - User variables setup
- [WezTerm Passing Data to Lua](https://wezterm.org/recipes/passing-data.html) - User variable patterns
- [Neovim Terminal Documentation](https://neovim.io/doc/user/terminal.html) - Terminal mode events
- [Neovim Autocmd Documentation](https://neovim.io/doc/user/autocmd.html) - TermRequest, TextChangedT events
- [greggh/claude-code.nvim](https://github.com/greggh/claude-code.nvim) - Current Neovim integration

### Files Examined

- `/home/benjamin/Projects/ProofChecker/.claude/hooks/wezterm-task-number.sh` - Current task number hook
- `/home/benjamin/Projects/ProofChecker/.claude/settings.json` - Hook configuration
- `/home/benjamin/.dotfiles/config/wezterm.lua` - WezTerm tab title configuration
- `/home/benjamin/.config/nvim/lua/neotex/config/autocmds.lua` - OSC 7 implementation reference
- `/home/benjamin/.config/nvim/lua/neotex/plugins/ai/claudecode.lua` - Claude Code plugin config
- `/home/benjamin/.local/share/nvim/lazy/claude-code.nvim/lua/claude-code/terminal.lua` - Plugin terminal handling

### Related Tasks

- Task 788: WezTerm tab coloring on Claude completion (CLAUDE_STATUS user variable)
- Task 789: WezTerm tab title project and task number (TASK_NUMBER user variable)
- Task 790: Neovim WezTerm OSC 7 tab title (OSC 7 emission from Neovim)

### Test Plan (For Implementation Phase)

1. **Test current implementation**:
   ```bash
   # In WezTerm, open Neovim
   nvim
   # Launch Claude Code
   :ClaudeCode
   # Enter command
   /research 791
   # Check tab title for #791
   ```

2. **If fails, implement Neovim-side emission**:
   - Add autocmd to `~/.config/nvim/lua/neotex/config/autocmds.lua`
   - Monitor Claude Code terminal buffer
   - Emit OSC 1337 when task commands detected
