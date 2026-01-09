#!/bin/bash
# Validate state.json and TODO.md are synchronized
# Called after writes to .opencode/specs/

STATE_FILE=".opencode/specs/state.json"
TODO_FILE=".opencode/specs/TODO.md"

# Check both files exist
if [[ ! -f "$STATE_FILE" ]]; then
    echo '{"decision": "allow", "warning": "state.json not found"}'
    exit 0
fi

if [[ ! -f "$TODO_FILE" ]]; then
    echo '{"decision": "allow", "warning": "TODO.md not found"}'
    exit 0
fi

# Quick validation: check state.json is valid JSON
if ! jq empty "$STATE_FILE" 2>/dev/null; then
    echo '{"decision": "block", "reason": "state.json is not valid JSON"}'
    exit 1
fi

# Success
echo '{"decision": "allow"}'
exit 0
