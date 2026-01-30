#!/bin/bash
# WezTerm tab notification clear hook for Claude Code
# Clears CLAUDE_STATUS user variable via OSC 1337 when user submits prompt
#
# Integration: Called from UserPromptSubmit hook in .claude/settings.json
# Requirements: wezterm with user variable support
#
# Clearing the variable ensures the tab color returns to normal after
# the user responds to Claude's input request.

set -euo pipefail

# Helper: return success JSON for hook
exit_success() {
    echo '{}'
    exit 0
}

# Only run in WezTerm
if [[ -z "${WEZTERM_PANE:-}" ]]; then
    exit_success
fi

# Clear CLAUDE_STATUS user variable via OSC 1337
# Set to empty string (empty base64 value)
printf '\033]1337;SetUserVar=CLAUDE_STATUS=\007'

exit_success
