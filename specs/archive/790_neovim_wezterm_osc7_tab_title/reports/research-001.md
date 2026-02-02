# Research Report: Task #790

**Task**: 790 - neovim_wezterm_osc7_tab_title
**Started**: 2026-02-01T12:00:00Z
**Completed**: 2026-02-01T12:15:00Z
**Effort**: Small (1-2 hours implementation)
**Dependencies**: None
**Sources/Inputs**: Codebase exploration, WezTerm documentation, Neovim documentation, blog posts
**Artifacts**: specs/790_neovim_wezterm_osc7_tab_title/reports/research-001.md
**Standards**: report-format.md

## Executive Summary

- WezTerm already shows project directory in tab titles via OSC 7 from fish shell
- The issue: Neovim doesn't emit OSC 7 when it changes working directory via :cd/:lcd/:tcd
- Solution: Add DirChanged autocmd in `~/.config/nvim/lua/neotex/config/autocmds.lua` to emit OSC 7
- Additional consideration: Handle session restore and neo-tree directory changes

## Context & Scope

**Problem**: WezTerm tabs show the shell's working directory (e.g., "benjamin" when shell is in ~). When Neovim opens a project and changes to its root directory, the tab title doesn't update because Neovim doesn't emit OSC 7 escape sequences.

**Goal**: When Neovim changes working directory (via :cd, :lcd, :tcd, autochdir, session restore, or neo-tree), update the WezTerm tab title to reflect the new directory.

**Constraints**:
- Must work within existing neovim config structure (`~/.config/nvim/lua/neotex/config/autocmds.lua`)
- Should not interfere with terminal buffers that emit their own OSC 7
- Must handle all directory change sources (manual, session, plugins)

## Findings

### Existing Infrastructure

#### WezTerm Configuration (`~/.config/wezterm/wezterm.lua`)

The WezTerm config already handles OSC 7 via `format-tab-title`:
```lua
-- Extract project name from current working directory
local active_pane = tab.active_pane
if active_pane then
  local cwd_url = active_pane.current_working_dir
  if cwd_url then
    local cwd_path = cwd_url.file_path
    if cwd_path then
      project_name = cwd_path:match("([^/]+)/?$")
    end
  end
end
```

This reads `current_working_dir` from the pane, which is populated by OSC 7 sequences.

#### Fish Shell Configuration (`~/.config/fish/config.fish`)

Fish already emits OSC 7 when PWD changes:
```fish
if set -q WEZTERM_PANE
    function __wezterm_osc7 --on-variable PWD
        printf "\033]7;file://%s%s\033\\" (hostname) (pwd)
    end
    __wezterm_osc7
end
```

#### Neovim Autocmds (`~/.config/nvim/lua/neotex/config/autocmds.lua`)

Current autocmds handle:
- FileType settings
- TermOpen handling
- Markdown keymaps
- FileChangedShell handling
- FocusGained/BufEnter for autoread

**No existing DirChanged handling** - this is the gap to fill.

### Neovim DirChanged Event

The `DirChanged` autocmd event fires after the current directory changes:

| Pattern | Trigger |
|---------|---------|
| `window` | `:lcd` (window-local) |
| `tabpage` | `:tcd` (tabpage-local) |
| `global` | `:cd` (global) |
| `auto` | `'autochdir'` option |

**v:event** provides:
- `cwd` - current working directory
- `scope` - "global", "tabpage", or "window"
- `changed_window` - true if fired during window/tab switch

### OSC 7 Protocol

OSC 7 format: `ESC ] 7 ; file://hostname/path ESC \`

In Lua:
```lua
local function emit_osc7()
  local cwd = vim.fn.getcwd()
  local hostname = vim.fn.hostname()
  io.write(string.format("\027]7;file://%s%s\027\\", hostname, cwd))
  io.flush()
end
```

**Technical notes**:
- Use `\027` (decimal) instead of `\x1b` (hex) for Lua 5.1 compatibility
- `io.write` sends to stdout which reaches the terminal
- `io.flush()` ensures immediate delivery

### Session Manager Interaction

The session manager (`neovim-session-manager`) restores sessions including working directory. When a session loads:
1. Session file is read
2. Neovim `:cd` is executed to restore working directory
3. DirChanged event fires
4. Our autocmd will emit OSC 7

**No special handling needed** - DirChanged will fire naturally.

### Neo-tree Interaction

Neo-tree follows `follow_current_file` but does NOT change Neovim's working directory when navigating. The tree shows files relative to its root, but `:pwd` remains unchanged.

However, Neo-tree's "navigate_up" mapping (-) does NOT change cwd either.

**The only way neo-tree affects cwd** is if user explicitly runs `:cd` to a directory shown in neo-tree.

### Terminal Buffer Consideration

Terminal buffers (toggleterm, etc.) run their own shell which emits OSC 7. We should:
1. Emit OSC 7 on DirChanged for non-terminal buffers
2. Terminal buffers will emit their own OSC 7 via fish shell

**Potential issue**: When switching from terminal to normal buffer, the cwd might differ. Consider emitting OSC 7 on BufEnter for non-terminal buffers to keep tab title accurate.

## Recommendations

### Primary Implementation

Add to `~/.config/nvim/lua/neotex/config/autocmds.lua`:

```lua
-- Emit OSC 7 to update WezTerm tab title when directory changes
-- Only in WezTerm (WEZTERM_PANE is set)
if vim.env.WEZTERM_PANE then
  local function emit_osc7()
    local cwd = vim.fn.getcwd()
    local hostname = vim.fn.hostname()
    -- OSC 7 format: ESC ] 7 ; file://hostname/path ESC \
    -- Use \027 (decimal) for Lua 5.1 compatibility instead of \x1b
    io.write(string.format("\027]7;file://%s%s\027\\", hostname, cwd))
    io.flush()
  end

  -- Emit on directory change (covers :cd, :lcd, :tcd, autochdir)
  api.nvim_create_autocmd("DirChanged", {
    pattern = "*",
    callback = emit_osc7,
    desc = "Update WezTerm tab title via OSC 7",
  })

  -- Emit on VimEnter to set initial cwd
  api.nvim_create_autocmd("VimEnter", {
    callback = emit_osc7,
    desc = "Set initial WezTerm tab title via OSC 7",
  })

  -- Emit when switching to non-terminal buffer to restore cwd display
  -- (terminal buffers emit their own OSC 7 via shell)
  api.nvim_create_autocmd("BufEnter", {
    callback = function()
      if vim.bo.buftype ~= "terminal" then
        emit_osc7()
      end
    end,
    desc = "Refresh WezTerm tab title on buffer switch",
  })
end
```

### Location

File: `~/.config/nvim/lua/neotex/config/autocmds.lua`

Add within the `M.setup()` function, after existing autocmds.

### Testing Plan

1. **Manual :cd test**: Run `:cd /tmp`, verify tab shows "tmp"
2. **Session restore test**: Open session in project root, verify tab shows project name
3. **Terminal switch test**: Open toggleterm, cd somewhere, close terminal, verify tab shows Neovim's cwd
4. **VimEnter test**: Start nvim in project root, verify tab shows project name immediately

### Alternative Approaches Considered

1. **Shell-only approach**: Modify fish to detect when running inside Neovim and use Neovim's cwd. Rejected: more complex, requires detecting Neovim reliably.

2. **OSC title (OSC 2) approach**: Set window title directly instead of cwd. Rejected: WezTerm already extracts project name from cwd, this would duplicate logic.

3. **User variable approach (like TASK_NUMBER)**: Set a user variable with project name. Rejected: More complex, cwd-based approach already works.

## Decisions

1. **Use OSC 7** (current working directory) rather than OSC 1/2 (window title) because WezTerm already extracts project name from cwd in format-tab-title
2. **Guard with WEZTERM_PANE** to avoid sending escape sequences in non-WezTerm terminals
3. **Include VimEnter** to handle initial directory on startup
4. **Include BufEnter** to restore correct cwd display after leaving terminal buffers
5. **Use pattern "*"** for DirChanged to catch all directory change types (global, window, tabpage, auto)

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| OSC 7 not reaching terminal | Low | Tab title not updated | Guard with WEZTERM_PANE check |
| BufEnter causes flicker | Low | Visual distraction | OSC 7 is fast, no visible flicker expected |
| Conflicts with terminal buffer OSC 7 | Low | Tab title jumps | Only emit for non-terminal buffers |
| Breaks other terminals | Low | Escape codes visible | WEZTERM_PANE guard prevents this |

## Appendix

### Search Queries Used

1. "neovim OSC 7 DirChanged autocmd wezterm working directory tab title"
2. "neovim emit OSC 7 escape sequence send terminal current working directory lua"

### References

- [OSC7 in Neovim: third time's a charm](https://lacamb.re/blog/osc7_in_neovim_third_time.html) - Handling OSC 7 from terminal processes
- [Neovim Autocmd Documentation](https://neovim.io/doc/user/autocmd.html) - DirChanged event details
- [WezTerm Discussion #4515](https://github.com/wezterm/wezterm/discussions/4515) - Tab title updates from Neovim
- [Neovim Terminal Documentation](https://neovim.io/doc/user/terminal.html) - Terminal buffer behavior

### Files Examined

- `~/.config/nvim/init.lua` - Entry point
- `~/.config/nvim/lua/neotex/config/init.lua` - Config loader
- `~/.config/nvim/lua/neotex/config/autocmds.lua` - Autocmd definitions (target file)
- `~/.config/nvim/lua/neotex/plugins/ui/sessions.lua` - Session manager config
- `~/.config/nvim/lua/neotex/plugins/ui/neo-tree.lua` - File tree config
- `~/.config/wezterm/wezterm.lua` - WezTerm configuration
- `~/.config/fish/config.fish` - Fish shell configuration
