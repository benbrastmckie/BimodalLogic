# Research Report: Neovim Ctrl-Backslash STT Toggle for Claude Code Sidebar

- **Task**: 768 - neovim_ctrl_backslash_stt_toggle_claude_code
- **Started**: 2026-01-29T12:00:00Z
- **Completed**: 2026-01-29T12:45:00Z
- **Effort**: 45 minutes
- **Priority**: Medium
- **Dependencies**: None
- **Sources/Inputs**:
  - Local config: `/home/benjamin/.config/nvim/lua/neotex/plugins/ai/claudecode.lua`
  - Local config: `/home/benjamin/.config/nvim/lua/neotex/plugins/tools/stt/init.lua`
  - Local config: `/home/benjamin/.config/nvim/lua/neotex/config/keymaps.lua`
  - Plugin source: `/home/benjamin/.local/share/nvim/lazy/claude-code.nvim/lua/claude-code/terminal.lua`
  - Plugin source: `/home/benjamin/.local/share/nvim/lazy/claude-code.nvim/lua/claude-code/keymaps.lua`
  - Neovim documentation: https://neovim.io/doc/user/terminal.html
  - GitHub issue: https://github.com/neovim/neovim/issues/7678
- **Artifacts**: specs/768_neovim_ctrl_backslash_stt_toggle_claude_code/reports/research-002.md
- **Standards**: report-format.md

## Executive Summary

- **ROOT CAUSE 1**: `<C-\>` is reserved in Neovim terminal mode and cannot be directly remapped - it serves as the escape sequence prefix for `<C-\><C-N>` (return to normal mode) and `<C-\><C-O>` (execute one normal command)
- **ROOT CAUSE 2**: The `TermOpen` autocmd with pattern `*claude*` does not match because buffer names are set AFTER `TermOpen` fires; the claude-code.nvim plugin names buffers `claude-code` or `claude-code-{instance}` only after terminal creation
- **ROOT CAUSE 3**: The autocmd pattern `*claude*` looks for "claude" in the buffer name at autocmd execution time, but `TermOpen` fires before `vim.cmd('file ' .. buffer_name)` renames the buffer
- The existing `<C-\>` mapping approach is fundamentally incompatible with terminal mode due to Neovim's reserved key handling
- Alternative key combinations (`<C-s>`, `<M-\>`, `<C-Space>`) or a two-key sequence (`<C-\><C-s>`) are the only viable solutions

## Context & Scope

The user created a `<C-\>` mapping in their neovim config to toggle STT (Speech-to-Text) recording, specifically for use within the Claude Code sidebar (the terminal window created by greggh/claude-code.nvim). The mapping works in normal mode but fails in terminal mode within the Claude Code sidebar.

### Existing Implementation

**Location**: `/home/benjamin/.config/nvim/lua/neotex/plugins/ai/claudecode.lua`

```lua
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*claude*",
  callback = function()
    vim.keymap.set('t', '<C-\\>', '<Cmd>STTToggle<CR>', {
      buffer = 0,
      silent = true,
      desc = 'STT: Toggle recording (terminal mode)'
    })
  end,
})
```

**Location**: `/home/benjamin/.config/nvim/lua/neotex/plugins/tools/stt/init.lua`

```lua
vim.keymap.set('n', '<C-\\>', M.toggle_recording, {
  noremap = true,
  silent = true,
  desc = 'STT: Toggle recording (Ctrl-\\)'
})
```

## Findings

### 1. Neovim Terminal Mode Reserved Keys

From the Neovim documentation:

> In terminal mode, all keys except `<C-\>` are sent to the underlying program. If `<C-\>` is pressed, the next key is sent unless it is `<C-N>` or `<C-O>`.

This means:
- `<C-\>` alone cannot be mapped in terminal mode
- `<C-\><C-N>` returns to normal mode (hardcoded behavior)
- `<C-\><C-O>` executes one normal mode command (hardcoded behavior)
- `<C-\>{any other key}` sends that key to the terminal program

**Impact**: The `vim.keymap.set('t', '<C-\\>', ...)` mapping will never trigger because Neovim intercepts `<C-\>` before any user mapping can process it.

### 2. TermOpen Autocmd Pattern Timing Issue

The `TermOpen` event fires **before** the buffer is renamed. The claude-code.nvim plugin follows this sequence:

**For split windows (terminal.lua lines 354-377)**:
```lua
vim.cmd(cmd)                    -- TermOpen fires HERE with term://{cwd}//{pid}:{cmd}
vim.cmd 'setlocal bufhidden=hide'
vim.cmd('file ' .. buffer_name)  -- Rename happens AFTER TermOpen
```

**For floating windows (terminal.lua lines 323-349)**:
```lua
vim.fn.termopen(cmd)            -- TermOpen fires HERE
vim.api.nvim_buf_set_name(new_bufnr, buffer_name)  -- Rename happens AFTER
```

The buffer name at `TermOpen` time is `term://{cwd}//{pid}:claude --dangerously-skip-permissions`, not `claude-code`. The pattern `*claude*` might match this because "claude" appears in the command, but the timing is unreliable.

### 3. Buffer Name Format

Claude-code.nvim uses these buffer names (terminal.lua lines 171-177):
```lua
local function generate_buffer_name(instance_id, config)
  if config.git.multi_instance then
    return 'claude-code-' .. instance_id:gsub('[^%w%-_]', '-')
  else
    return 'claude-code'
  end
end
```

The patterns that would reliably match:
- `*claude-code*` - matches the renamed buffer name
- `term://*claude*` - matches the term:// path containing the command
- `*` - matches everything (filter in callback)

### 4. Verification of Pattern Matching

The safest approach is to use pattern `*` and filter in the callback:

```lua
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    if bufname:match("claude") then
      -- Set buffer-local keymaps
    end
  end,
})
```

However, this still doesn't solve the `<C-\>` reservation issue.

### 5. How Plugin Keymaps Work

The claude-code.nvim plugin sets buffer-local keymaps via `setup_terminal_navigation()` in keymaps.lua, called AFTER the terminal is created:

```lua
vim.api.nvim_buf_set_keymap(buf, 't', '<C-h>', [[<C-\><C-n><C-w>h:lua ...]])
```

These keymaps use `<C-\><C-N>` to escape terminal mode first, then execute commands. This is the correct pattern for terminal mode keymaps.

## Decisions

- The `<C-\>` key cannot be used alone in terminal mode - this is a Neovim architectural constraint
- Alternative approaches must be used to achieve the desired functionality
- The TermOpen pattern should be fixed regardless to ensure the autocmd fires correctly

## Recommendations

### Solution 1: Use `<C-\><C-s>` Sequence (Recommended)

Map `<C-\><C-s>` which follows the terminal escape pattern:

```lua
-- In claudecode.lua TermOpen callback:
vim.keymap.set('t', '<C-\\><C-s>', '<Cmd>STTToggle<CR>', {
  buffer = 0,
  silent = true,
  desc = 'STT: Toggle recording (terminal mode)'
})
```

**Pros**: Consistent with Neovim terminal patterns, doesn't conflict with anything
**Cons**: Requires two keypresses instead of one

### Solution 2: Use Alt/Meta Key (`<M-\>` or `<M-s>`)

```lua
vim.keymap.set('t', '<M-\\>', '<Cmd>STTToggle<CR>', { buffer = 0, silent = true })
-- or
vim.keymap.set('t', '<M-s>', '<Cmd>STTToggle<CR>', { buffer = 0, silent = true })
```

**Pros**: Single keypress
**Cons**: May require terminal emulator configuration (iTerm2 needs "Option as +Esc")

### Solution 3: Use Different Control Key

```lua
vim.keymap.set('t', '<C-Space>', '<Cmd>STTToggle<CR>', { buffer = 0, silent = true })
-- or
vim.keymap.set('t', '<C-s>', '<Cmd>STTToggle<CR>', { buffer = 0, silent = true })
```

**Pros**: Single keypress, widely supported
**Cons**: May conflict with other mappings (`<C-s>` sometimes used for save)

### Solution 4: Fix TermOpen Pattern (Required for any solution)

Change the autocmd to reliably detect Claude Code terminals:

```lua
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",  -- Match all, filter in callback
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    -- Match either the initial term:// path or the renamed buffer
    if bufname:match("claude") or bufname:match("ClaudeCode") then
      -- Apply terminal-mode keymaps
      vim.keymap.set('t', '<C-\\><C-s>', '<Cmd>STTToggle<CR>', {
        buffer = 0,
        silent = true,
        desc = 'STT: Toggle recording (terminal mode)'
      })
    end
  end,
})
```

### Solution 5: Hook into Plugin's Keymap Setup

Instead of using TermOpen, hook into the claude-code.nvim plugin's keymap setup by calling after the plugin creates its terminal:

```lua
-- In claudecode.lua config function, after require("claude-code").setup(opts):
local original_toggle = require("claude-code").toggle
require("claude-code").toggle = function()
  original_toggle()
  -- Apply STT keymaps to the new buffer
  vim.defer_fn(function()
    local claude = require("claude-code")
    local current_instance = claude.claude_code.current_instance
    if current_instance and claude.claude_code.instances[current_instance] then
      local bufnr = claude.claude_code.instances[current_instance]
      if vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_set_keymap(bufnr, 't', '<C-\\><C-s>', '<Cmd>STTToggle<CR>', {
          noremap = true, silent = true
        })
      end
    end
  end, 50)
end
```

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| `<C-\><C-s>` may be awkward for frequent use | Users can choose `<M-s>` or `<C-Space>` based on preference |
| Alt key behavior varies by terminal | Document terminal emulator requirements (Kitty, iTerm2, Alacritty) |
| Future Neovim changes | Use standard patterns from terminal.txt documentation |
| Plugin updates may break hooks | Solution 4 (TermOpen pattern) is most maintainable |

## Appendix

### Search Queries Used
- "neovim terminal mode keybinding not working buffer-local autocmd TermOpen"
- "neovim Ctrl-backslash terminal mode special key C-\ reserved"
- "neovim terminal mode remap ctrl-backslash workaround tnoremap"

### References
- Neovim terminal documentation: https://neovim.io/doc/user/terminal.html
- TermOpen timing issue: https://github.com/neovim/neovim/issues/7678
- claude-code.nvim repository: https://github.com/greggh/claude-code.nvim
- VimCasts terminal mappings: https://www.jackfranklin.co.uk/blog/executing-tasks-in-neovim/
- toggleterm.nvim patterns: https://github.com/akinsho/toggleterm.nvim

### Key Code Locations
- `~/.config/nvim/lua/neotex/plugins/ai/claudecode.lua` - TermOpen autocmd (lines 82-101)
- `~/.config/nvim/lua/neotex/plugins/tools/stt/init.lua` - STT module (line 310)
- `~/.local/share/nvim/lazy/claude-code.nvim/lua/claude-code/terminal.lua` - Buffer creation (lines 354-377, 323-349)
- `~/.local/share/nvim/lazy/claude-code.nvim/lua/claude-code/keymaps.lua` - Plugin keymaps (lines 114-190)
