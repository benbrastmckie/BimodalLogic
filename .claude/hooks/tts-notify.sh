#!/bin/bash
# TTS notification hook for Claude Code completion
# Announces WezTerm tab number and completion message via Piper TTS
#
# Integration: Called from Stop hook in .claude/settings.json
# Requirements: piper-tts, aplay (alsa-utils), jq, wezterm
#
# Configuration:
#   PIPER_MODEL - Path to piper voice model (default: ~/.local/share/piper/en_US-lessac-medium.onnx)
#   TTS_COOLDOWN - Seconds between notifications (default: 60)
#   TTS_ENABLED - Set to "0" to disable (default: 1)

set -euo pipefail

# Configuration with defaults
PIPER_MODEL="${PIPER_MODEL:-$HOME/.local/share/piper/en_US-lessac-medium.onnx}"
TTS_COOLDOWN="${TTS_COOLDOWN:-60}"
TTS_ENABLED="${TTS_ENABLED:-1}"

# State files
LAST_NOTIFY_FILE="/tmp/claude-tts-last-notify"
LOG_FILE="/tmp/claude-tts-notify.log"

# Helper: log message
log() {
    echo "[$(date -Iseconds)] $1" >> "$LOG_FILE"
}

# Helper: return success JSON for Stop hook
exit_success() {
    echo '{}'
    exit 0
}

# Check if TTS is disabled
if [[ "$TTS_ENABLED" != "1" ]]; then
    exit_success
fi

# Check if piper is available
if ! command -v piper &>/dev/null; then
    log "piper command not found - skipping TTS notification"
    exit_success
fi

# Check if model exists
if [[ ! -f "$PIPER_MODEL" ]]; then
    log "Piper model not found at $PIPER_MODEL - skipping TTS notification"
    exit_success
fi

# Check cooldown
if [[ -f "$LAST_NOTIFY_FILE" ]]; then
    LAST_TIME=$(cat "$LAST_NOTIFY_FILE" 2>/dev/null || echo "0")
    NOW=$(date +%s)
    ELAPSED=$((NOW - LAST_TIME))
    if (( ELAPSED < TTS_COOLDOWN )); then
        log "Cooldown active: ${ELAPSED}s < ${TTS_COOLDOWN}s - skipping notification"
        exit_success
    fi
fi

# Get WezTerm tab info
TAB_LABEL=""
if [[ -n "${WEZTERM_PANE:-}" ]] && command -v wezterm &>/dev/null; then
    # Get tab_id for current pane
    # Note: tab_id is 0-indexed internal ID, tab_title may be more useful
    TAB_INFO=$(wezterm cli list --format=json 2>/dev/null | jq -r ".[] | select(.pane_id == $WEZTERM_PANE)" 2>/dev/null || echo "")
    if [[ -n "$TAB_INFO" ]]; then
        # Extract tab index (1-based for human readability)
        TAB_ID=$(echo "$TAB_INFO" | jq -r '.tab_id' 2>/dev/null || echo "")
        if [[ -n "$TAB_ID" && "$TAB_ID" != "null" ]]; then
            # Add 1 to convert from 0-indexed to 1-indexed for humans
            TAB_NUM=$((TAB_ID + 1))
            TAB_LABEL="Tab $TAB_NUM: "
        fi
    fi
fi

# Generate message
MESSAGE="${TAB_LABEL}Claude has finished"

# Speak using piper with aplay
# Use a subshell with timeout to prevent hanging
if command -v aplay &>/dev/null; then
    # aplay available (ALSA)
    (timeout 10s bash -c "echo '$MESSAGE' | piper --model '$PIPER_MODEL' --output_file - 2>/dev/null | aplay -q 2>/dev/null" &)
elif command -v paplay &>/dev/null; then
    # paplay available (PulseAudio) - need to write to temp file first
    TEMP_WAV="/tmp/claude-tts-$$.wav"
    (timeout 10s bash -c "echo '$MESSAGE' | piper --model '$PIPER_MODEL' --output_file '$TEMP_WAV' 2>/dev/null && paplay '$TEMP_WAV' 2>/dev/null; rm -f '$TEMP_WAV'" &)
else
    log "No audio player found (aplay or paplay) - skipping TTS notification"
    exit_success
fi

# Update cooldown timestamp
date +%s > "$LAST_NOTIFY_FILE"

log "Notification sent: $MESSAGE"

exit_success
