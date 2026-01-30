# Research Report: Task #761

**Task**: Integrate TTS and STT for Claude Code and Neovim
**Date**: 2026-01-29
**Focus**: TTS/STT best practices for NixOS with Claude Code and Neovim integration

## Summary

This research investigates TTS (text-to-speech) and STT (speech-to-text) solutions that are NixOS-installable, free, fast, and have a small footprint (no local LLM requirement). For TTS, **Piper** is the recommended solution due to its natural-sounding neural TTS with fast inference and small model sizes. For STT, **Vosk** is recommended for its 50MB lightweight models and offline capability, though **faster-whisper with tiny model** (~40MB) is a viable alternative with higher accuracy.

## Findings

### TTS Solutions

#### 1. Piper TTS (Recommended)

**Availability**: Available in nixpkgs as `piper-tts`

**Characteristics**:
- Fast neural TTS that runs on CPU with minimal overhead
- Models range from 15-75MB depending on quality (medium quality ~45MB)
- Produces natural "Google TTS quality" speech
- CLI invocable: `echo "text" | piper --model model.onnx --output_file out.wav`
- Depends on espeak-ng for phonemization (also in nixpkgs)

**NixOS Installation**:
```nix
environment.systemPackages = [ pkgs.piper-tts ];
```

**Pros**: Natural sounding, fast, small models, actively maintained
**Cons**: Requires downloading voice models separately

**Sources**:
- [Piper TTS](https://domdelorenzo.com/posts/linux-tts/)
- [piper-tts on PyPI](https://pypi.org/project/piper-tts/)
- [piper on MyNixOS](https://mynixos.com/nixpkgs/package/piper-tts)

#### 2. espeak-ng (Fallback)

**Availability**: Available in nixpkgs as `espeak-ng`

**Characteristics**:
- Extremely lightweight (~2MB total with data)
- Supports 100+ languages
- Fast but robotic-sounding
- CLI invocable: `espeak-ng "text"`

**NixOS Installation**:
```nix
environment.systemPackages = [ pkgs.espeak-ng ];
```

**Pros**: Tiny footprint, fast, no model download needed
**Cons**: Robotic voice quality from 1990s-era synthesis

**Sources**:
- [espeak-ng GitHub](https://github.com/espeak-ng/espeak-ng)
- [espeak-ng on MyNixOS](https://mynixos.com/nixpkgs/package/espeak)

### STT Solutions

#### 1. Vosk (Recommended for Offline)

**Availability**: Not in nixpkgs directly, requires Python pip installation or custom derivation

**Characteristics**:
- Lightweight models: ~50MB per language
- Supports 20+ languages including English
- Zero-latency streaming API
- Works offline on Raspberry Pi and similar constrained devices
- Python bindings: `pip install vosk`

**Installation Approach**:
```nix
# Using Python environment with pip
python3.withPackages (ps: [ ps.vosk ])
# Or via pip in a virtualenv
```

**Note**: Vosk is not packaged in nixpkgs directly. Users have attempted custom derivations using `buildPythonPackage` with wheel format.

**Pros**: Very small models (50MB), fast, offline, streaming
**Cons**: Not in nixpkgs (requires custom packaging), accuracy lower than Whisper

**Sources**:
- [Vosk Official](https://alphacephei.com/vosk/)
- [Vosk GitHub](https://github.com/alphacep/vosk-api)
- [NixOS Discourse - Vosk packaging](https://discourse.nixos.org/t/vosk-a-python-package-not-in-nixpkgs/71858)

#### 2. faster-whisper with tiny model (Alternative)

**Availability**: Available in nixpkgs as `python3Packages.faster-whisper`

**Characteristics**:
- Whisper tiny model: ~40MB (encoder 36MB + decoder ~4MB quantized)
- 4x faster than OpenAI Whisper implementation
- 8-bit quantization reduces memory usage
- Higher accuracy than Vosk

**NixOS Installation**:
```nix
python3.withPackages (ps: [ ps.faster-whisper ])
# Or use Wyoming service integration
services.wyoming.faster-whisper.servers."default" = {
  model = "tiny";
};
```

**Pros**: High accuracy, in nixpkgs, well-maintained
**Cons**: Larger than Vosk models, slower on CPU-only

**Sources**:
- [faster-whisper GitHub](https://github.com/SYSTRAN/faster-whisper)
- [faster-whisper on MyNixOS](https://mynixos.com/nixpkgs/package/python311Packages.faster-whisper)
- [NixOS faster-whisper options](https://search.nixos.org/options?query=faster-whisper)

### Claude Code Integration

#### Stop Hook for Completion Notifications

Claude Code provides a `Stop` hook that fires when the agent finishes responding. This is the integration point for TTS notifications.

**Hook Configuration** (from official docs):
```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/tts-notification.sh"
          }
        ]
      }
    ]
  }
}
```

**Hook Input** (JSON via stdin):
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/path/to/project",
  "hook_event_name": "Stop",
  "stop_hook_active": false
}
```

**Key Considerations**:
1. The hook runs when Claude finishes responding (not on user interrupt)
2. `stop_hook_active` indicates if the hook is already in a continuation loop
3. The `transcript_path` provides access to the full conversation for summary generation
4. Hook timeout default is 60 seconds

**Sources**:
- [Claude Code Hooks Reference](https://code.claude.com/docs/en/hooks)
- [Claude Code Notifications That Don't Suck](https://www.d12frosted.io/posts/2026-01-05-claude-code-notifications)
- [Get Notified When Claude Code Finishes](https://alexop.dev/posts/claude-code-notification-hooks/)

#### Existing Project Hook Pattern

This project already has a Stop hook in `.claude/settings.json`:
```json
"Stop": [
  {
    "matcher": "*",
    "hooks": [
      {
        "type": "command",
        "command": "bash .claude/hooks/post-command.sh 2>/dev/null || echo '{}'"
      }
    ]
  }
]
```

The TTS notification can be integrated into this existing hook or added as an additional hook.

### WezTerm Integration

#### Getting Tab Information

**Environment Variable**: `WEZTERM_PANE` contains the pane ID of the current pane.

**CLI Commands**:
```bash
# Get tab index for current pane
wezterm cli list --format=json | jq '.[] | select(.is_active) | .tab_id'

# Get all tab information
wezterm cli list --format=json
```

**From Within a Script**:
```bash
# WEZTERM_PANE is set in the environment
TAB_INFO=$(wezterm cli list --format=json | jq ".[] | select(.pane_id == $WEZTERM_PANE)")
TAB_INDEX=$(echo "$TAB_INFO" | jq '.tab_id')
```

**Sources**:
- [WezTerm PaneInformation docs](https://wezterm.org/config/lua/PaneInformation.html)
- [WezTerm Discussion - Get active pane ID](https://github.com/wezterm/wezterm/discussions/5010)
- [WezTerm Discussion - Tab count](https://github.com/wezterm/wezterm/discussions/3181)

### Neovim STT Integration

#### Existing Plugins

1. **gp.nvim** - Full AI plugin with STT support (uses cloud APIs)
2. **speech-to-text.nvim** - Uses Python speech_recognition library
3. **nvim-speech** - Uses Vernacular ASR (Indian language focus)
4. **whisper.nvim** - Whisper-based, records ~10 seconds, inserts at cursor

**Sources**:
- [gp.nvim](https://neovimcraft.com/plugin/Robitx/gp.nvim/)
- [speech-to-text.nvim](https://github.com/eyalk11/speech-to-text.nvim)
- [nvim-speech](https://github.com/vipul-sharma20/nvim-speech)

#### Custom Implementation Pattern

For a custom Vosk-based integration:

**1. Audio Recording** (using PulseAudio):
```bash
# Record from default microphone
parecord --channels=1 --rate=16000 --file-format=wav /tmp/recording.wav
# Or with timeout
timeout 10s parecord --channels=1 --rate=16000 --file-format=wav /tmp/recording.wav
```

**2. Neovim Lua Async Job**:
```lua
local function record_and_transcribe()
  -- Start recording
  local job_id = vim.fn.jobstart({
    'parecord', '--channels=1', '--rate=16000',
    '--file-format=wav', '/tmp/nvim-stt.wav'
  }, {
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        transcribe_and_insert()
      end
    end
  })

  -- Stop after keypress or timeout
  vim.keymap.set('n', '<Esc>', function()
    vim.fn.jobstop(job_id)
  end, { buffer = true })
end

local function transcribe_and_insert()
  vim.fn.jobstart({
    'python3', '-c', [[
import vosk
import json
import wave
model = vosk.Model("/path/to/vosk-model")
wf = wave.open("/tmp/nvim-stt.wav", "rb")
rec = vosk.KaldiRecognizer(model, wf.getframerate())
rec.AcceptWaveform(wf.readframes(wf.getnframes()))
print(json.loads(rec.Result())["text"])
]]
  }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      local text = table.concat(data, " ")
      vim.api.nvim_put({text}, 'c', true, true)
    end
  })
end
```

**Sources**:
- [Neovim Lua Guide](https://neovim.io/doc/user/lua-guide.html)
- [Async make in Neovim with Lua](https://phelipetls.github.io/posts/async-make-in-nvim-with-lua/)
- [plenary.nvim Job module](https://neovimcraft.com/plugin/nvim-lua/plenary.nvim/)

## Recommendations

### 1. TTS for Claude Code Notifications

**Recommended**: Piper TTS with a medium-quality English voice

**Implementation**:
1. Install `piper-tts` via NixOS
2. Download a voice model (e.g., `en_US-lessac-medium.onnx`, ~45MB)
3. Create a Stop hook script that:
   - Checks if 60 seconds have elapsed since last notification
   - Gets WezTerm tab number via `wezterm cli list`
   - Extracts brief summary from transcript (last assistant message)
   - Calls piper to speak: "Tab {N}: {summary}"

**Sample Hook Script**:
```bash
#!/bin/bash
# .claude/hooks/tts-notify.sh

LAST_NOTIFY_FILE="/tmp/claude-tts-last-notify"
COOLDOWN_SECONDS=60

# Check cooldown
if [[ -f "$LAST_NOTIFY_FILE" ]]; then
  LAST_TIME=$(cat "$LAST_NOTIFY_FILE")
  NOW=$(date +%s)
  if (( NOW - LAST_TIME < COOLDOWN_SECONDS )); then
    echo '{}'
    exit 0
  fi
fi

# Get tab number
TAB_NUM=$(wezterm cli list --format=json | jq ".[] | select(.pane_id == $WEZTERM_PANE) | .tab_id" 2>/dev/null || echo "unknown")

# Generate brief message
MESSAGE="Tab $TAB_NUM: Claude has finished"

# Speak using piper
echo "$MESSAGE" | piper --model ~/.local/share/piper/en_US-lessac-medium.onnx --output_file - | aplay -q

# Update cooldown
date +%s > "$LAST_NOTIFY_FILE"

echo '{}'
exit 0
```

### 2. STT for Neovim

**Recommended**: Vosk with small English model (50MB)

**Rationale**: Meets all constraints - free, fast, small (50MB), offline, no local LLM

**Alternative**: faster-whisper with tiny model if higher accuracy needed (~40MB model, but slower)

**Implementation**:
1. Install Vosk via pip (custom nix derivation or shell.nix)
2. Download vosk-model-small-en-us (50MB)
3. Create Lua plugin with:
   - Keymap to start recording (uses parecord)
   - Keymap to stop recording
   - Async transcription via Vosk Python
   - Insert result at cursor

### 3. NixOS Packaging Strategy

**For Piper**:
```nix
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    piper-tts
    espeak-ng  # dependency
  ];
}
```

**For Vosk** (using Python environment):
```nix
{ pkgs, ... }:
let
  pythonEnv = pkgs.python3.withPackages (ps: with ps; [
    vosk
  ]);
in
{
  environment.systemPackages = [ pythonEnv ];
}
```

**Note**: Vosk may need to be packaged manually. A working derivation template:
```nix
{ lib, python3Packages, fetchPypi }:
python3Packages.buildPythonPackage rec {
  pname = "vosk";
  version = "0.3.45";
  format = "wheel";
  src = fetchPypi {
    inherit pname version format;
    sha256 = "...";
    python = "py3";
    platform = "manylinux1_x86_64";
  };
  # ...
}
```

## Decisions

1. **TTS Engine**: Piper TTS over espeak-ng (quality) and Festival (size/speed)
2. **STT Engine**: Vosk over Whisper variants (model size constraint, offline requirement)
3. **Audio Recording**: PulseAudio `parecord` (widely available, simple CLI)
4. **Hook Integration**: Extend existing Stop hook in `.claude/settings.json`
5. **Neovim Pattern**: Custom Lua plugin using vim.fn.jobstart for async

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Vosk not in nixpkgs | Use pip in shell.nix or create custom derivation |
| Piper voice model download | Include model path in nix configuration, document manual download |
| Audio device permissions | Ensure user is in `audio` group on NixOS |
| Hook timeout (60s default) | Keep TTS short, use async playback |
| Recording in terminal | Use parecord with PulseAudio (works in terminal) |
| STT accuracy for technical terms | Consider vocabulary customization in Vosk |

## References

- [Claude Code Hooks Reference](https://code.claude.com/docs/en/hooks)
- [Piper TTS on Linux](https://domdelorenzo.com/posts/linux-tts/)
- [Vosk Official Documentation](https://alphacephei.com/vosk/)
- [faster-whisper GitHub](https://github.com/SYSTRAN/faster-whisper)
- [WezTerm CLI Documentation](https://wezterm.org/cli/cli/activate-tab.html)
- [Neovim Lua Guide](https://neovim.io/doc/user/lua-guide.html)
- [MyNixOS - piper-tts](https://mynixos.com/nixpkgs/package/piper-tts)
- [MyNixOS - espeak-ng](https://mynixos.com/nixpkgs/package/espeak)
- [NixOS Discourse - Vosk packaging](https://discourse.nixos.org/t/vosk-a-python-package-not-in-nixpkgs/71858)

## Next Steps

1. Create implementation plan with:
   - Phase 1: NixOS packaging for piper-tts, vosk, and audio tools
   - Phase 2: TTS notification hook for Claude Code
   - Phase 3: Neovim STT plugin
   - Phase 4: Integration testing and refinement
