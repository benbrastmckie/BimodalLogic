# Implementation Plan: Task #761 (Revision 002)

- **Task**: 761 - TTS/STT Integration for Claude Code and Neovim
- **Status**: [COMPLETED]
- **Effort**: 1.5 hours
- **Priority**: Medium
- **Dependencies**: None (TTS hook already working, Vosk already installed)
- **Research Inputs**:
  - research-001.md (initial research)
  - research-002.md (supplementary research)
  - research-003.md (diagnostic findings - KEY)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

This is a **revision plan** to fix STT plugin integration issues identified in the initial implementation. The TTS notification hook is **working correctly** and requires no changes. This plan focuses exclusively on fixing the STT plugin by integrating it into the user's neotex plugin structure, registering it with lazy.nvim, and adding which-key keybindings.

### Research Integration

- **Initial Research**: research-001.md identified Piper TTS and Vosk STT as suitable tools
- **Supplementary Research**: research-002.md explored Neovim STT plugin patterns
- **Diagnostic Research**: research-003.md (2026-01-29) identified root causes:
  1. STT plugin created at `~/.config/nvim/lua/stt/init.lua` but **not loaded** by lazy.nvim
  2. Plugin sits outside neotex.plugins hierarchy, so not auto-discovered
  3. No which-key `<leader>v` group definition
  4. Vosk model not downloaded

**Key Finding**: The STT implementation is technically correct, but architecturally misplaced. It needs to be moved into the neotex.plugins.tools structure and registered with the plugin manager.

## Goals & Non-Goals

**Goals**:
- Move STT plugin into neotex.plugins.tools structure
- Create lazy.nvim plugin specification
- Register plugin in tools/init.lua
- Add which-key `<leader>v` (voice) group and keybindings
- Download Vosk model (~50MB)
- Verify full STT flow works end-to-end

**Non-Goals**:
- Modifying TTS hook (already working)
- Changing STT plugin logic (implementation is correct)
- Adding new features beyond original spec

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Neotex structure changes break existing plugins | H | L | Follow established patterns from himalaya-plugin.lua |
| Lazy.nvim doesn't load plugin after restructure | M | M | Test with `:Lazy` and verify plugin appears |
| Which-key group conflicts with existing mappings | L | L | `<leader>v` confirmed unused in current config |
| Vosk model download fails | M | L | Document manual download as fallback |

## Implementation Phases

### Phase 1: Restructure STT Plugin Files [COMPLETED]

**Goal**: Move STT plugin from orphaned location into neotex.plugins.tools hierarchy.

**Tasks**:
- [ ] Create directory structure: `~/.config/nvim/lua/neotex/plugins/tools/stt/`
- [ ] Move `~/.config/nvim/lua/stt/init.lua` to `~/.config/nvim/lua/neotex/plugins/tools/stt/init.lua`
- [ ] Create lazy.nvim spec at `~/.config/nvim/lua/neotex/plugins/tools/stt.lua`
- [ ] Update module path in plugin spec to `neotex.plugins.tools.stt`
- [ ] Delete old orphaned directory `~/.config/nvim/lua/stt/`

**Timing**: 20 minutes

**Files to create/modify**:
- `~/.config/nvim/lua/neotex/plugins/tools/stt/` - Create directory
- `~/.config/nvim/lua/neotex/plugins/tools/stt/init.lua` - Move existing implementation
- `~/.config/nvim/lua/neotex/plugins/tools/stt.lua` - Create lazy.nvim spec
- `~/.config/nvim/lua/stt/` - Delete orphaned directory

**Lazy.nvim Spec Pattern** (based on himalaya-plugin.lua):
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

**Verification**:
- Files moved to correct locations
- Old orphaned directory removed
- Plugin spec syntactically valid Lua

---

### Phase 2: Register Plugin and Add Which-Key Mappings [COMPLETED]

**Goal**: Register STT plugin with lazy.nvim and add `<leader>v` group to which-key.

**Tasks**:
- [ ] Read `~/.config/nvim/lua/neotex/plugins/tools/init.lua` to understand pattern
- [ ] Add STT plugin registration using safe_require pattern
- [ ] Read `~/.config/nvim/lua/neotex/plugins/editor/which-key.lua` to understand structure
- [ ] Add `<leader>v` group definition in which-key config
- [ ] Add four keybindings: `vr` (start), `vs` (stop), `vt` (toggle), `vh` (health)
- [ ] Verify keybindings call functions from `neotex.plugins.tools.stt` module

**Timing**: 30 minutes

**Files to modify**:
- `~/.config/nvim/lua/neotex/plugins/tools/init.lua` - Add STT plugin registration
- `~/.config/nvim/lua/neotex/plugins/editor/which-key.lua` - Add `<leader>v` group

**Plugin Registration Pattern** (from tools/init.lua):
```lua
local stt_module = safe_require("neotex.plugins.tools.stt")
add_if_valid(stt_module)
```

**Which-Key Pattern** (from which-key.lua):
```lua
wk.add({
  { "<leader>v", group = "voice", icon = "?" },
  { "<leader>vr", function() require('neotex.plugins.tools.stt').start_recording() end, desc = "start recording", icon = "?" },
  { "<leader>vs", function() require('neotex.plugins.tools.stt').stop_recording() end, desc = "stop recording", icon = "?" },
  { "<leader>vt", function() require('neotex.plugins.tools.stt').toggle_recording() end, desc = "toggle recording", icon = "?" },
  { "<leader>vh", function() require('neotex.plugins.tools.stt').health() end, desc = "health check", icon = "?" },
})
```

**Verification**:
- `:Lazy` shows STT plugin loaded
- `:WhichKey <leader>v` shows voice group with four mappings
- No Lua errors on Neovim startup

---

### Phase 3: Vosk Model Download and End-to-End Testing [COMPLETED]

**Goal**: Download Vosk model and verify complete STT workflow.

**Tasks**:
- [ ] Download vosk-model-small-en-us-0.15.zip (~50MB)
- [ ] Extract to `~/.local/share/vosk/vosk-model-small-en-us`
- [ ] Verify model directory structure (contains `am/`, `graph/`, `conf/`)
- [ ] Test STT health check: `<leader>vh` should report all dependencies available
- [ ] Test recording flow: `<leader>vr` -> speak -> `<leader>vs` -> verify text inserted
- [ ] Verify parecord is available (from pulseaudio package)
- [ ] Verify vosk-transcribe.py works standalone
- [ ] Update docs/tts-stt-integration.md with corrected plugin paths

**Timing**: 40 minutes

**Files to verify**:
- `~/.local/share/vosk/vosk-model-small-en-us/` - Model directory
- `~/.local/bin/vosk-transcribe.py` - Transcription script (already created)

**Files to modify**:
- `docs/tts-stt-integration.md` - Update plugin paths and setup instructions

**Model Download Commands**:
```bash
mkdir -p ~/.local/share/vosk
cd ~/.local/share/vosk
wget https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip
unzip vosk-model-small-en-us-0.15.zip
mv vosk-model-small-en-us-0.15 vosk-model-small-en-us
rm vosk-model-small-en-us-0.15.zip
```

**Verification**:
- Model directory exists and contains required files
- `<leader>vh` reports "All dependencies available"
- Full recording flow inserts transcribed text at cursor
- Documentation reflects correct plugin paths

---

## Testing & Validation

- [ ] TTS hook continues to work (no regression)
- [ ] `:Lazy` shows STT plugin in loaded plugins list
- [ ] `:WhichKey <leader>v` displays voice group with all four mappings
- [ ] `<leader>vh` health check passes
- [ ] Full STT flow: record -> speak -> stop -> text appears at cursor
- [ ] No Lua errors in `:messages` after loading
- [ ] Plugin survives Neovim restart

## Artifacts & Outputs

- `~/.config/nvim/lua/neotex/plugins/tools/stt/init.lua` - STT plugin implementation (moved)
- `~/.config/nvim/lua/neotex/plugins/tools/stt.lua` - Lazy.nvim plugin spec (new)
- `~/.config/nvim/lua/neotex/plugins/tools/init.lua` - Updated with STT registration
- `~/.config/nvim/lua/neotex/plugins/editor/which-key.lua` - Updated with `<leader>v` group
- `~/.local/share/vosk/vosk-model-small-en-us/` - Vosk model directory
- `docs/tts-stt-integration.md` - Updated documentation with correct paths
- `specs/761_tts_stt_integration_for_claude_code_and_neovim/summaries/implementation-summary-YYYYMMDD.md` - Revision summary

## Rollback/Contingency

**If lazy.nvim integration fails**:
- Revert changes to tools/init.lua and which-key.lua
- Restore STT plugin to orphaned location `~/.config/nvim/lua/stt/`
- Add manual `require('stt').setup()` to init.lua as temporary workaround
- Original TTS functionality unaffected

**If Vosk model download fails**:
- STT plugin will gracefully report missing model in health check
- User can manually download from alternative mirrors
- TTS notifications continue to work independently

**Partial Rollback**:
- All changes are in Neovim config - no system-level changes
- Git revert of modified files restores previous state
- TTS hook is completely independent and unaffected
