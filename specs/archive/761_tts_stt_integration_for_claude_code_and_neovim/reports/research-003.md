# Research Report: Task #761 - STT Plugin Keybindings Not Visible

**Task**: 761 - TTS/STT Integration for Claude Code and Neovim
**Date**: 2026-01-29
**Focus**: Neovim STT keybindings not visible in which-key

## Summary

The STT plugin was created at `~/.config/nvim/lua/stt/init.lua` with proper implementation, but it is **not being loaded** by Neovim because it sits outside the plugin loading system. The plugin defines keybindings inside its `setup()` function, but `setup()` is never called since the module is not loaded anywhere.

## Findings

### 1. STT Plugin Implementation Status

**Location**: `~/.config/nvim/lua/stt/init.lua`
**Status**: File exists with complete implementation

The plugin is well-implemented with:
- `M.start_recording()` - Start audio recording via parecord
- `M.stop_recording()` - Stop recording gracefully
- `M.toggle_recording()` - Toggle recording state
- `M.transcribe_and_insert()` - Transcribe via Vosk and insert at cursor
- `M.health()` - Dependency health check
- `M.setup()` - Keybinding setup function

**Keybindings defined in setup()**:
- `<leader>vr` - Start recording
- `<leader>vs` - Stop recording
- `<leader>vt` - Toggle recording
- `<leader>vh` - Health check

### 2. Why the Plugin is Not Loaded

**Root Cause**: The `stt` module is in `~/.config/nvim/lua/stt/` which is on the Lua path, but nothing requires or loads it.

The user's Neovim configuration uses **lazy.nvim** for plugin management. Plugins are loaded via:

1. **Category imports** in `bootstrap.lua`:
   ```lua
   { import = "neotex.plugins.lsp" }
   { import = "neotex.plugins.editor" }
   { import = "neotex.plugins.text" }
   { import = "neotex.plugins.ui" }
   ```

2. **Explicit loading** for `tools` and `ai` plugins:
   ```lua
   local tools_ok, tools_plugins = pcall(require, "neotex.plugins.tools")
   local ai_ok, ai_plugins = pcall(require, "neotex.plugins.ai")
   ```

The `stt` plugin was placed **outside the neotex.plugins hierarchy** and is not registered with lazy.nvim.

### 3. User's Plugin Loading Patterns

**Pattern A: Standalone plugins** (like himalaya-plugin.lua)
- Created as lazy.nvim spec with `dir`, `name`, `event`, `config`, and `dependencies`
- Registered in category init.lua (e.g., `neotex.plugins.tools.init`)
- Lazy-loaded on events

**Pattern B: Direct category loading**
- Plugins placed in category directories (editor, ui, text)
- Auto-discovered via `{ import = "neotex.plugins.<category>" }`

### 4. Which-Key Configuration

**Location**: `~/.config/nvim/lua/neotex/plugins/editor/which-key.lua`

The which-key configuration does **not** define any `<leader>v` group. Current groups are:
- `<leader>a` - AI
- `<leader>f` - Find
- `<leader>g` - Git
- `<leader>h` - Help
- `<leader>i` - LSP
- `<leader>j` - Jupyter
- `<leader>l` - LaTeX
- `<leader>m` - Mail
- `<leader>n` - NixOS
- `<leader>p` - Pandoc
- `<leader>r` - Run
- `<leader>s` - Surround
- `<leader>S` - Sessions
- `<leader>t` - Todo
- `<leader>T` - Templates
- `<leader>x` - Text
- `<leader>y` - Yank

**The `<leader>v` group for Voice/STT needs to be added to which-key.**

### 5. Supporting Infrastructure Status

| Component | Status | Path |
|-----------|--------|------|
| STT plugin code | Present | `~/.config/nvim/lua/stt/init.lua` |
| Vosk transcribe script | Present | `~/.local/bin/vosk-transcribe.py` |
| Vosk model | **MISSING** | `~/.local/share/vosk/vosk-model-small-en-us` |
| parecord | Needs verification | System binary |

## Recommendations

### Option A: Integrate into existing plugin system (Recommended)

1. **Move plugin to neotex structure**:
   ```
   ~/.config/nvim/lua/neotex/plugins/tools/stt.lua  # lazy.nvim spec
   ~/.config/nvim/lua/neotex/plugins/tools/stt/init.lua  # implementation
   ```

2. **Create lazy.nvim spec** (stt.lua):
   ```lua
   return {
     dir = vim.fn.stdpath('config') .. '/lua/neotex/plugins/tools/stt',
     name = 'stt',
     event = { 'VeryLazy' },
     config = function(_, opts)
       local stt = require('neotex.plugins.tools.stt')
       stt.setup(opts)
     end,
   }
   ```

3. **Register in tools/init.lua**:
   ```lua
   local stt_module = safe_require("neotex.plugins.tools.stt")
   add_if_valid(stt_module)
   ```

4. **Add which-key group** in `which-key.lua`:
   ```lua
   wk.add({
     { "<leader>v", group = "voice", icon = "?" },
     { "<leader>vr", function() require('neotex.plugins.tools.stt').start_recording() end, desc = "start recording", icon = "?" },
     { "<leader>vs", function() require('neotex.plugins.tools.stt').stop_recording() end, desc = "stop recording", icon = "?" },
     { "<leader>vt", function() require('neotex.plugins.tools.stt').toggle_recording() end, desc = "toggle recording", icon = "?" },
     { "<leader>vh", function() require('neotex.plugins.tools.stt').health() end, desc = "health check", icon = "?" },
   })
   ```

### Option B: Simple require in init.lua

Add to `~/.config/nvim/init.lua` after config setup:
```lua
-- Load STT plugin
local stt_ok, stt = pcall(require, "stt")
if stt_ok then
  stt.setup()
end
```

This is simpler but doesn't follow the project's plugin organization.

### Additional Required Steps

1. **Download Vosk model**:
   ```bash
   mkdir -p ~/.local/share/vosk
   cd ~/.local/share/vosk
   wget https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip
   unzip vosk-model-small-en-us-0.15.zip
   mv vosk-model-small-en-us-0.15 vosk-model-small-en-us
   ```

2. **Verify dependencies**:
   ```bash
   which parecord  # Should exist
   python3 -c "import vosk"  # Should not error
   ```

## Files to Create/Modify

| File | Action | Purpose |
|------|--------|---------|
| `~/.config/nvim/lua/neotex/plugins/tools/stt.lua` | Create | Lazy.nvim plugin spec |
| `~/.config/nvim/lua/neotex/plugins/tools/stt/init.lua` | Move from `lua/stt/init.lua` | Plugin implementation |
| `~/.config/nvim/lua/neotex/plugins/tools/init.lua` | Modify | Register STT plugin |
| `~/.config/nvim/lua/neotex/plugins/editor/which-key.lua` | Modify | Add `<leader>v` group |
| `~/.config/nvim/lua/stt/init.lua` | Delete | Remove orphaned location |

## Next Steps

1. Move STT plugin into neotex structure
2. Create lazy.nvim plugin spec
3. Register plugin in tools/init.lua
4. Add which-key mappings for `<leader>v`
5. Download Vosk model
6. Test full flow: record -> stop -> transcribe -> insert
