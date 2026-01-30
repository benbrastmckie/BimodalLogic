# Implementation Plan: Task #761

- **Task**: 761 - TTS/STT Integration for Claude Code and Neovim
- **Status**: [IMPLEMENTING]
- **Effort**: 4.5 hours
- **Priority**: Medium
- **Dependencies**: piper-tts and vosk (already installed by user)
- **Research Inputs**: specs/761_tts_stt_integration_for_claude_code_and_neovim/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

This plan implements TTS notifications for Claude Code completions and STT input for Neovim. The TTS hook integrates with Claude Code's existing Stop hook mechanism, using Piper TTS to announce the WezTerm tab number and a brief completion summary after a 60-second cooldown. The STT plugin provides a Lua-based Neovim integration using Vosk for offline speech recognition, with keymappings to record, transcribe, and insert text at cursor.

### Research Integration

- **Research Report**: research-001.md (2026-01-29)
- **Key Findings Integrated**:
  - Piper TTS CLI invocation pattern: `echo "text" | piper --model model.onnx --output_file -`
  - WezTerm tab detection via `WEZTERM_PANE` environment variable and `wezterm cli list --format=json`
  - Existing Stop hook in `.claude/settings.json` provides integration point
  - Vosk Python API for offline transcription with ~50MB model
  - Neovim async job pattern using `vim.fn.jobstart`

## Goals & Non-Goals

**Goals**:
- TTS notification when Claude Code finishes (with 60-second cooldown to avoid spam)
- Announce WezTerm tab number for multi-tab workflows
- Neovim keymapping to trigger voice recording and insert transcribed text
- All components work offline with no cloud APIs
- Small footprint (no local LLM, use existing piper-tts and vosk)

**Non-Goals**:
- Continuous STT (dictation mode) - only triggered recording
- Voice commands for Neovim (only text insertion)
- Transcript summarization (use simple "Claude has finished" message initially)
- Cross-platform support (NixOS only)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Piper voice model not downloaded | H | M | Document model download step, verify in phase 1 |
| Audio permissions issues | M | L | Ensure user in `audio` group, test early |
| Stop hook timeout (60s default) | M | L | Keep TTS short, use async audio playback |
| WezTerm not running | L | L | Graceful fallback when WEZTERM_PANE unset |
| Vosk model path incorrect | M | M | Use XDG_DATA_HOME standard path |
| Recording doesn't stop cleanly | M | M | Implement timeout and explicit stop keybind |

## Implementation Phases

### Phase 1: Claude Code TTS Notification Hook [COMPLETED]

**Goal**: Create a Stop hook script that uses Piper TTS to announce Claude Code completion with WezTerm tab number.

**Tasks**:
- [ ] Create `.claude/hooks/tts-notify.sh` script
- [ ] Implement 60-second cooldown using `/tmp/claude-tts-last-notify` timestamp file
- [ ] Extract WezTerm tab number via `wezterm cli list --format=json` and `WEZTERM_PANE`
- [ ] Integrate Piper TTS invocation with appropriate voice model path
- [ ] Configure audio output (pipe to `aplay` or `paplay`)
- [ ] Update `.claude/settings.json` to add TTS hook to existing Stop hook chain
- [ ] Handle edge cases: WezTerm not running, audio device unavailable
- [ ] Test notification flow with manual hook trigger

**Timing**: 1.5 hours

**Files to create/modify**:
- `.claude/hooks/tts-notify.sh` - Create TTS notification script
- `.claude/settings.json` - Add TTS hook to Stop hooks array

**Verification**:
- Manual test: Run `echo '{}' | .claude/hooks/tts-notify.sh` - should hear TTS
- Cooldown test: Run twice within 60s - second should be silent
- Integration test: Have Claude complete a response and verify notification

---

### Phase 2: Neovim STT Plugin [COMPLETED]

**Goal**: Create a Neovim Lua plugin that records audio, transcribes via Vosk, and inserts text at cursor.

**Tasks**:
- [ ] Create plugin structure at `~/.config/nvim/lua/stt/init.lua`
- [ ] Implement `start_recording()` function using `parecord` with proper audio settings
- [ ] Implement `stop_recording()` function to terminate recording job
- [ ] Create Python transcription script `~/.local/bin/vosk-transcribe.py`
- [ ] Implement `transcribe_and_insert()` function with async job
- [ ] Configure Vosk model path (default: `~/.local/share/vosk/vosk-model-small-en-us`)
- [ ] Add visual feedback during recording (echo message or statusline)
- [ ] Create keymappings: `<leader>vr` to start, `<leader>vs` to stop
- [ ] Handle errors: no microphone, Vosk model missing, transcription failure
- [ ] Document plugin setup in plugin file comments

**Timing**: 2 hours

**Files to create**:
- `~/.config/nvim/lua/stt/init.lua` - Neovim STT plugin
- `~/.local/bin/vosk-transcribe.py` - Vosk transcription script

**Verification**:
- Unit test: `parecord` captures audio to WAV file
- Unit test: `vosk-transcribe.py` correctly transcribes test WAV
- Integration test: Full flow in Neovim - record, stop, text appears at cursor

---

### Phase 3: Integration Testing and Documentation [COMPLETED]

**Goal**: Verify end-to-end functionality and document setup/usage.

**Tasks**:
- [ ] End-to-end test: Claude Code TTS notification in real workflow
- [ ] End-to-end test: Neovim STT in real editing session
- [ ] Verify cooldown behavior over extended session
- [ ] Test edge cases: no audio device, missing models, permissions
- [ ] Create setup documentation with prerequisites
- [ ] Document keybindings and configuration options
- [ ] Create troubleshooting section for common issues
- [ ] Add configuration examples for custom voice models

**Timing**: 1 hour

**Files to create**:
- `docs/tts-stt-integration.md` - Setup and usage documentation

**Verification**:
- Documentation accurately reflects implementation
- All documented features work as described
- Troubleshooting steps resolve common issues

---

## Testing & Validation

- [ ] TTS hook produces audible notification on Claude completion
- [ ] TTS cooldown prevents notification spam (60-second minimum)
- [ ] WezTerm tab number correctly detected and announced
- [ ] Neovim recording starts and stops cleanly
- [ ] Transcribed text inserts at cursor position
- [ ] All components work offline (no network required)
- [ ] Error messages helpful when dependencies missing

## Artifacts & Outputs

- `.claude/hooks/tts-notify.sh` - Claude Code TTS notification hook
- `~/.config/nvim/lua/stt/init.lua` - Neovim STT plugin
- `~/.local/bin/vosk-transcribe.py` - Vosk transcription helper script
- `docs/tts-stt-integration.md` - Setup and usage documentation
- `specs/761_tts_stt_integration_for_claude_code_and_neovim/summaries/implementation-summary-YYYYMMDD.md` - Implementation summary

## Rollback/Contingency

**TTS Hook Rollback**:
- Remove TTS hook entry from `.claude/settings.json`
- Delete `.claude/hooks/tts-notify.sh`
- Original Stop hook behavior unchanged

**STT Plugin Rollback**:
- Remove `require('stt')` from Neovim config
- Delete `~/.config/nvim/lua/stt/` directory
- Delete `~/.local/bin/vosk-transcribe.py`

**Partial Rollback**:
- TTS and STT are independent - either can be removed without affecting the other
