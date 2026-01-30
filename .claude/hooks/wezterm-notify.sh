#!/bin/bash
# WezTerm tab notification hook for Claude Code completion
# Sets CLAUDE_STATUS user variable via OSC 1337 when Claude stops
#
# Integration: Called from Stop hook in .claude/settings.json
# Requirements: wezterm with user variable support
#
# Configuration:
#   WEZTERM_NOTIFY_ENABLED - Set to "0" to disable (default: 1)
#
# The CLAUDE_STATUS variable is read by wezterm.lua format-tab-title handler
# to show amber background on inactive tabs that need attention.

set -euo pipefail

# Configuration with defaults
WEZTERM_NOTIFY_ENABLED="${WEZTERM_NOTIFY_ENABLED:-1}"

# Helper: return success JSON for Stop hook
exit_success() {
    echo '{}'
    exit 0
}

# Check if notification is disabled
if [[ "$WEZTERM_NOTIFY_ENABLED" != "1" ]]; then
    exit_success
fi

# Only run in WezTerm
if [[ -z "${WEZTERM_PANE:-}" ]]; then
    exit_success
fi

# Set CLAUDE_STATUS user variable via OSC 1337
# Format: OSC 1337 ; SetUserVar=name=base64_value ST
# base64 encode the value "needs_input"
STATUS_VALUE=$(echo -n "needs_input" | base64 | tr -d '\n')

# Print OSC 1337 escape sequence
# \033] = OSC
# \007 = ST (string terminator)
printf '\033]1337;SetUserVar=CLAUDE_STATUS=%s\007' "$STATUS_VALUE"

exit_success
