# Research Report: Task #768

**Task**: 768 - neovim_ctrl_backslash_stt_toggle_claude_code
**Date**: 2026-01-29
**Focus**: Research claude-code.nvim plugin for neovim keybinding solutions, specifically for terminal mode keybindings in Claude Code sidebar, GitHub issues, and STT toggle implementation patterns

## Summary

The `<C-\>` mapping for STT toggle in Claude Code terminal buffers has already been implemented. The implementation correctly addresses Neovim's special handling of `<C-\>` in terminal mode by using a buffer-local terminal mode mapping set via an autocmd that fires when Claude Code terminal buffers are created.

## Findings

### 1. Current Implementation Status

**Location**: `/home/benjamin/.config/nvim/lua/neotex/plugins/ai/claudecode.lua`

The `<C-\>` mapping is already implemented at lines 92-97:

```lua
-- Buffer-local terminal mode keybinding for STT toggle
vim.keymap.set('t', '<C-\\>', '<Cmd>STTToggle<CR>', {
  buffer = 0,
  silent = true,
  desc = 'STT: Toggle recording (terminal mode)'
})
```

This mapping is set inside a `TermOpen` autocmd with pattern `*claude*`, ensuring it only applies to Claude Code terminal buffers.

### 2. Neovim Terminal Mode `<C-\>` Behavior

Per the [Neovim terminal documentation](https://neovim.io/doc/user/terminal.html), `<C-\>` has special handling in terminal mode:

> "In this mode all keys except `<C-\>` are sent to the underlying program. If `<C-\>` is pressed, the next key is sent unless it is `<C-N>` or `<C-O>`."

Key sequences:
- `<C-\><C-N>` - Returns to normal mode from terminal mode
- `<C-\><C-O>` - Executes a single normal mode command, then returns to terminal mode

**Important**: When mapping `<C-\>` alone (without a following key), Neovim intercepts it before passing to the terminal program. This allows the current implementation to work correctly.

### 3. STT Plugin Status

**Location**: `/home/benjamin/.config/nvim/lua/neotex/plugins/tools/stt/init.lua`

The STT plugin is fully implemented with:
- `M.start_recording()` - Start audio recording via parecord
- `M.stop_recording()` - Stop recording gracefully
- `M.transcribe_and_insert()` - Transcribe via Vosk and insert at cursor
- `M.toggle_recording()` - Toggle recording state
- `M.health()` - Dependency health check

User commands are registered:
- `:STTStart` - Start recording
- `:STTStop` - Stop recording
- `:STTToggle` - Toggle recording (used by `<C-\>` mapping)
- `:STTHealth` - Check dependencies

### 4. Which-Key Integration

**Location**: `/home/benjamin/.config/nvim/lua/neotex/plugins/editor/which-key.lua`

The `<leader>v` voice group is configured (lines 699-703):

```lua
{ "<leader>v", group = "voice", icon = "?" },
{ "<leader>vh", function() require('neotex.plugins.tools.stt').health() end, desc = "health check", icon = "?" },
{ "<leader>vr", function() require('neotex.plugins.tools.stt').start_recording() end, desc = "start recording", icon = "?" },
{ "<leader>vs", function() require('neotex.plugins.tools.stt').stop_recording() end, desc = "stop recording", icon = "?" },
{ "<leader>vv", function() require('neotex.plugins.tools.stt').toggle_recording() end, desc = "toggle recording", icon = "?" },
```

### 5. Documentation Status

**Location**: `/home/benjamin/.config/nvim/docs/MAPPINGS.md`

The `<C-\>` mapping is documented in the VOICE section (line 392):

```markdown
| `<C-\>` | Toggle recording | Alternative toggle (works in Claude Code) |
```

### 6. greggh/claude-code.nvim Plugin Research

Based on web research of the [greggh/claude-code.nvim GitHub repository](https://github.com/greggh/claude-code.nvim):

**Default Terminal Keybindings**:
- `<C-h/j/k/l>` - Navigate between windows
- `<C-f/b>` - Scroll full-page down/up
- `<C-,>` - Toggle Claude Code terminal (default)

**Voice/STT Integration**: No speech-to-text or voice input features are mentioned in the plugin documentation. The STT integration is a custom addition to the user's neovim configuration.

**Custom Keybindings**: The plugin allows disabling default keymaps by setting them to `false`, which is done in the current configuration at lines 47-59.

### 7. Normal Mode Mapping

**Location**: `/home/benjamin/.config/nvim/lua/neotex/plugins/tools/stt/init.lua` (lines 310-314)

There's also a normal mode `<C-\>` mapping in the STT plugin setup:

```lua
vim.keymap.set('n', '<C-\\>', M.toggle_recording, {
  noremap = true,
  silent = true,
  desc = 'STT: Toggle recording (Ctrl-\\)'
})
```

This allows STT toggle from normal mode in any buffer.

## Architecture Summary

| Context | Mapping | Source | Function |
|---------|---------|--------|----------|
| Normal mode (global) | `<C-\>` | stt/init.lua | STT toggle |
| Terminal mode (Claude buffers) | `<C-\>` | claudecode.lua TermOpen autocmd | STT toggle via :STTToggle |
| Normal mode | `<leader>vv` | which-key.lua | STT toggle |
| Normal mode | `<leader>vr` | which-key.lua | Start recording |
| Normal mode | `<leader>vs` | which-key.lua | Stop recording |

## Recommendations

### Task Appears Complete

The requested `<C-\>` mapping for STT toggle in Claude Code sidebar is **already implemented**. The implementation:

1. Uses buffer-local terminal mode mapping (`buffer = 0`)
2. Fires only for Claude Code terminal buffers (`*claude*` pattern)
3. Calls `:STTToggle` user command
4. Is documented in MAPPINGS.md

### Potential Enhancements (Optional)

If the task was created because the mapping isn't working, consider:

1. **Verify STT plugin loads**: Check that the `neotex.plugins.tools.stt` module is properly registered in `tools/init.lua`

2. **Verify dependencies**: Run `:STTHealth` to check for missing dependencies (parecord, python3, Vosk model)

3. **Verify autocmd fires**: Run `:autocmd TermOpen *claude*` to confirm the autocmd is registered

4. **Check for conflicts**: Some terminal emulators (like tmux) may intercept `<C-\>` before it reaches Neovim

### Alternative Approach (If Current Fails)

If the `<C-\>` mapping has issues due to terminal emulator conflicts, consider using an alternative key:

```lua
-- Alternative: Use <C-.> instead of <C-\>
vim.keymap.set('t', '<C-.>', '<Cmd>STTToggle<CR>', {
  buffer = 0,
  silent = true,
  desc = 'STT: Toggle recording (terminal mode)'
})
```

## References

- [greggh/claude-code.nvim](https://github.com/greggh/claude-code.nvim) - Plugin repository
- [Neovim Terminal Documentation](https://neovim.io/doc/user/terminal.html) - Terminal mode key handling
- [Creating mappings for :terminal](http://vimcasts.org/episodes/neovim-terminal-mappings/) - Vimcasts tutorial
- [Neovim Lua Guide - Keymaps](https://neovim.io/doc/user/lua-guide.html) - vim.keymap.set documentation

## Files Referenced

| File | Purpose |
|------|---------|
| `~/.config/nvim/lua/neotex/plugins/ai/claudecode.lua` | Claude Code plugin config with `<C-\>` terminal mapping |
| `~/.config/nvim/lua/neotex/plugins/tools/stt/init.lua` | STT plugin implementation |
| `~/.config/nvim/lua/neotex/plugins/editor/which-key.lua` | `<leader>v` voice group mappings |
| `~/.config/nvim/lua/neotex/config/keymaps.lua` | Central keymaps (no STT changes needed) |
| `~/.config/nvim/docs/MAPPINGS.md` | User-facing keybinding documentation |

## Next Steps

1. **Verify the existing implementation works** - Test `<C-\>` in Claude Code terminal
2. **If not working**: Debug with `:verbose map <C-\>` in terminal mode
3. **If task was created in error**: Mark task as complete with note that feature already exists
