# Research Report: Task #761 (Supplementary)

**Task**: Integrate TTS and STT for Claude Code and Neovim
**Date**: 2026-01-29
**Focus**: Existing Neovim STT plugins evaluation - build vs buy analysis

## Summary

This supplementary research investigates existing Neovim speech-to-text plugins to determine whether a custom solution is necessary. After comprehensive web research, **three viable plugins exist that meet most requirements**, with **whisper.nvim** being the recommended choice for offline Neovim STT integration. However, each has trade-offs. The recommendation is to **use whisper.nvim as the base** rather than building from scratch, with minor customizations if needed.

## Evaluation Criteria

The user requirements are:
1. Works with offline STT engines (Vosk, Whisper, faster-whisper)
2. Actively maintained in 2025-2026
3. NixOS compatible
4. Free and open source
5. Small footprint (no local LLM requirement)
6. Basic functionality: record, transcribe, insert at cursor

## Plugins Evaluated

### 1. whisper.nvim (Avi-D-coder) - RECOMMENDED

**Repository**: [github.com/Avi-D-coder/whisper.nvim](https://github.com/Avi-D-coder/whisper.nvim)

| Criterion | Status | Notes |
|-----------|--------|-------|
| Offline operation | YES | Uses whisper.cpp locally |
| Actively maintained | PARTIAL | Limited commits, but functional |
| NixOS compatible | YES | whisper.cpp in nixpkgs |
| Free/open source | YES | MIT license |
| Small footprint | YES | Base model ~148MB, tiny ~77MB |
| Basic functionality | YES | Record + transcribe + insert at cursor |

**How it works**:
- Press `<C-g>` to toggle recording
- Press `<Space>` to process and insert transcription at cursor
- Auto-inserts every 20 seconds if not manually triggered
- On first use, downloads whisper base.en model (~148MB)

**Requirements**:
- Neovim >= 0.8.0
- whisper-cpp binary (specifically `whisper-stream`)
- Working microphone

**Configuration**:
```lua
{
  model = "tiny.en",  -- Options: tiny.en (77MB), base.en (148MB), small.en (488MB)
  step_ms = 20000,    -- Auto-process interval
  vad_thold = 0.60,   -- Voice activity detection threshold
}
```

**NixOS Installation**:
```nix
environment.systemPackages = [ pkgs.whisper-cpp ];
```

**Verdict**: This is the simplest, most focused option. Meets all core requirements.

---

### 2. murmur.nvim (mecattaf) - ARCHIVED

**Repository**: [github.com/mecattaf/murmur.nvim](https://github.com/mecattaf/murmur.nvim)

| Criterion | Status | Notes |
|-----------|--------|-------|
| Offline operation | YES | Uses whisper.cpp server |
| Actively maintained | NO | **Archived May 7, 2025** |
| NixOS compatible | PARTIAL | Requires running whisper.cpp server |
| Free/open source | YES | Fork of gp.nvim |
| Small footprint | YES | Uses whisper-small by default |
| Basic functionality | YES | Record + transcribe + insert |

**How it works**:
- Requires whisper.cpp server running locally (separate process)
- Invoke `:Murmur` command to record audio
- Audio sent to local server for transcription
- Results inserted at cursor

**Requirements**:
- Neovim >= 0.9.0
- whisper.cpp server running (host:127.0.0.1, port:8009)
- SoX, arecord, or ffmpeg for recording

**Verdict**: More complex setup (server requirement), and project is archived. Not recommended despite good feature set.

---

### 3. vocal.nvim (kyza0d) - VIABLE ALTERNATIVE

**Repository**: [github.com/kyza0d/vocal.nvim](https://github.com/kyza0d/vocal.nvim)

| Criterion | Status | Notes |
|-----------|--------|-------|
| Offline operation | YES | Supports local whisper models |
| Actively maintained | PARTIAL | 15 commits, created April 2025 |
| NixOS compatible | PARTIAL | Requires python-openai-whisper |
| Free/open source | YES | MIT license |
| Small footprint | YES | Configurable model sizes |
| Basic functionality | YES | Record + transcribe + insert |

**How it works**:
- Trigger with `<leader>v` (configurable)
- Records audio using SoX
- Transcribes with local Whisper model or OpenAI API
- Inserts at cursor

**Requirements**:
- Neovim >= 0.11.0 (newer requirement!)
- SoX for audio recording
- Python with openai-whisper package
- plenary.nvim dependency

**Caveats**:
- README notes "API transcription has issues"
- Windows support not working
- Requires newer Neovim version

**Verdict**: Viable but less mature than whisper.nvim, higher Neovim version requirement.

---

### 4. speech-to-text.nvim (eyalk11) - NOT RECOMMENDED

**Repository**: [github.com/eyalk11/speech-to-text.nvim](https://github.com/eyalk11/speech-to-text.nvim)

| Criterion | Status | Notes |
|-----------|--------|-------|
| Offline operation | PARTIAL | Whisper engine works offline, others don't |
| Actively maintained | NO | Last commit April 2023 |
| NixOS compatible | POOR | Keyboard package requires admin on Linux |
| Free/open source | YES | MIT license |
| Small footprint | YES | Depends on engine choice |
| Basic functionality | YES | Via `:Voice` command |

**Issues**:
- Tested only on Windows
- Requires `keyboard` Python package (needs root on Linux)
- 3+ years since last update

**Verdict**: Unmaintained, Linux compatibility issues. Not recommended.

---

### 5. gp.nvim (Robitx) - NOT SUITABLE FOR OFFLINE

**Repository**: [github.com/Robitx/gp.nvim](https://github.com/Robitx/gp.nvim)

| Criterion | Status | Notes |
|-----------|--------|-------|
| Offline operation | NO | Requires OpenAI API for whisper |
| Actively maintained | YES | Very active development |
| NixOS compatible | YES | Standard Lua plugin |
| Free/open source | YES | MIT license |
| Small footprint | NO | Full AI plugin, many features |
| Basic functionality | YES | GpWhisper* commands |

**Verdict**: Cloud-dependent for STT. Does not meet offline requirement.

---

### 6. nvim-speech (vipul-sharma20) - NOT SUITABLE

**Repository**: [github.com/vipul-sharma20/nvim-speech](https://github.com/vipul-sharma20/nvim-speech)

| Criterion | Status | Notes |
|-----------|--------|-------|
| Offline operation | NO | Requires Vernacular ASR API |
| Actively maintained | NO | Last commit November 2020 |
| NixOS compatible | N/A | API-dependent |
| Free/open source | YES | Apache 2.0 |
| Small footprint | N/A | API-dependent |
| Basic functionality | PARTIAL | Indian languages focus |

**Verdict**: Cloud-dependent, unmaintained, niche language focus. Not suitable.

---

### Alternative: nerd-dictation (External Tool)

**Repository**: [github.com/ideasman42/nerd-dictation](https://github.com/ideasman42/nerd-dictation)

This is not a Neovim plugin but a system-wide dictation tool using Vosk.

| Criterion | Status | Notes |
|-----------|--------|-------|
| Offline operation | YES | Uses Vosk locally |
| Actively maintained | YES | 161 commits, ongoing development |
| NixOS compatible | LIKELY | Pure Python with Vosk |
| Free/open source | YES | GPL-3.0 |
| Small footprint | YES | Vosk models ~50MB |
| Basic functionality | YES | Via keystroke simulation |

**How it works**:
- Run `nerd-dictation begin` to start recording
- Run `nerd-dictation end` to stop and type results
- Simulates keystrokes into any application (including Neovim)
- Configuration via Python script at `~/.config/nerd-dictation/nerd-dictation.py`

**Pros**:
- Works with ANY application, not just Neovim
- Very small models (Vosk ~50MB vs Whisper ~77-148MB)
- Highly customizable text transformations
- Actively maintained

**Cons**:
- Not integrated into Neovim (external tool)
- Requires separate keyboard shortcut management
- Less seamless than native plugin

**Verdict**: Excellent fallback if Neovim-specific integration is not required. Could use Vosk instead of Whisper for smaller footprint.

---

## Comparison Matrix

| Plugin | Offline | Maintained | NixOS | Footprint | Functionality | Recommended |
|--------|---------|------------|-------|-----------|---------------|-------------|
| whisper.nvim | YES | Partial | YES | 77-148MB | Full | YES |
| murmur.nvim | YES | Archived | Partial | ~100MB | Full | NO |
| vocal.nvim | YES | Partial | Partial | Variable | Full | MAYBE |
| speech-to-text.nvim | Partial | NO | Poor | Variable | Full | NO |
| gp.nvim | NO | YES | YES | Large | Full | NO |
| nvim-speech | NO | NO | N/A | N/A | Partial | NO |
| nerd-dictation | YES | YES | Likely | 50MB | External | ALTERNATIVE |

## Recommendation

**Primary**: Use **whisper.nvim** by Avi-D-coder

Rationale:
1. Meets all core requirements (offline, free, NixOS-compatible)
2. Simplest architecture (no server, just whisper-cpp binary)
3. Focused functionality (just STT, no AI bloat)
4. Works with tiny model for ~77MB footprint
5. Active community despite limited official updates

**Setup for NixOS**:
```nix
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    whisper-cpp  # Provides whisper-stream binary
  ];
}
```

**Neovim config (lazy.nvim)**:
```lua
{
  "Avi-D-coder/whisper.nvim",
  config = function()
    require("whisper").setup({
      model = "tiny.en",  -- Smallest model for speed
    })
  end,
  keys = {
    { "<C-g>", desc = "Toggle whisper recording" },
    { "<Space>", desc = "Process and insert transcription" },
  },
}
```

**Secondary Alternative**: Use **nerd-dictation** as external tool

If Vosk's smaller model size (50MB) is preferred over Whisper (77MB minimum), or if system-wide dictation is desired:

```nix
{ pkgs, ... }:
let
  nerd-dictation = pkgs.python3Packages.buildPythonApplication {
    # Custom derivation or use existing if available
  };
in
{
  environment.systemPackages = [
    nerd-dictation
    pkgs.vosk-models  # If available, or download separately
    pkgs.xdotool      # For keystroke simulation on X11
  ];
}
```

Then bind keyboard shortcuts via window manager to:
- `nerd-dictation begin` - Start recording
- `nerd-dictation end` - Stop and type

## Do NOT Build Custom Plugin

The research shows that **whisper.nvim already provides the exact functionality needed**:
- Record audio
- Transcribe with local whisper.cpp
- Insert at cursor

Building a custom plugin would reinvent the wheel. The only reasons to build custom would be:
1. Need Vosk instead of Whisper (use nerd-dictation instead)
2. Need faster-whisper (not worth the integration complexity)
3. Need specialized text transformations (can add post-processing to whisper.nvim)

## References

- [whisper.nvim (Avi-D-coder)](https://github.com/Avi-D-coder/whisper.nvim)
- [murmur.nvim](https://github.com/mecattaf/murmur.nvim)
- [vocal.nvim](https://github.com/kyza0d/vocal.nvim)
- [speech-to-text.nvim](https://github.com/eyalk11/speech-to-text.nvim)
- [gp.nvim](https://github.com/Robitx/gp.nvim)
- [nvim-speech](https://github.com/vipul-sharma20/nvim-speech)
- [nerd-dictation](https://github.com/ideasman42/nerd-dictation)
- [whisper.cpp](https://github.com/ggml-org/whisper.cpp)
- [Vosk API](https://alphacephei.com/vosk/)
- [whisper.vim discussion](https://github.com/ggml-org/whisper.cpp/discussions/108)

## Next Steps

1. Update implementation plan to use whisper.nvim instead of custom plugin
2. Add nerd-dictation as fallback/alternative in plan
3. Test whisper.nvim with whisper.cpp from nixpkgs
4. Verify tiny.en model meets accuracy requirements
