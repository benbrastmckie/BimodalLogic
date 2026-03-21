# Research Report: Task #775

**Task**: Fix WezTerm tab coloring with Claude Code hooks
**Date**: 2026-01-30
**Focus**: Diagnose and fix WezTerm tab coloring mechanism

## Summary

The WezTerm tab coloring feature is not working because the Claude Code hooks write the OSC 1337 escape sequence to captured stdout (a socket) instead of the actual terminal TTY. The escape sequences are being captured by Claude Code as part of the hook's JSON output, not sent to WezTerm. The fix requires writing the escape sequence directly to the pane's TTY device file (e.g., `/dev/pts/2`) rather than using printf to stdout.

## Findings

### 1. Root Cause Identified

**The Problem**: Claude Code hooks run with redirected stdio:
- `stdin`: Connected to a socket (receives input from Claude Code)
- `stdout`: Connected to a socket (sends JSON response back to Claude Code)
- `stderr`: Connected to `/dev/null`

When `wezterm-notify.sh` executes `printf '\033]1337;SetUserVar=CLAUDE_STATUS=%s\007'`, the escape sequence is captured by Claude Code, not sent to WezTerm.

**Evidence**:
```bash
# Inside a Claude Code hook, file descriptors show:
$ ls -la /proc/self/fd/
0 -> socket:[6085104]  # stdin is a socket
1 -> socket:[6085106]  # stdout is a socket (escape sequence goes here!)
2 -> /dev/null         # stderr discarded
```

### 2. Current Implementation Analysis

**wezterm-notify.sh** (current, broken):
```bash
printf '\033]1337;SetUserVar=CLAUDE_STATUS=%s\007' "$STATUS_VALUE"
```
This writes to stdout, which Claude Code captures.

**wezterm-clear-status.sh** (current, broken):
```bash
printf '\033]1337;SetUserVar=CLAUDE_STATUS=\007'
```
Same issue - writes to captured stdout.

### 3. Solution: Write to Pane TTY

The escape sequence must be written directly to the terminal's TTY device file. WezTerm provides this information via `wezterm cli list --format=json` which includes the `tty_name` field.

**Fixed approach**:
```bash
# Get the TTY for the current pane
PANE_TTY=$(wezterm cli list --format=json 2>/dev/null | \
    jq -r ".[] | select(.pane_id == $WEZTERM_PANE) | .tty_name")

# Write escape sequence to the TTY, not stdout
printf '\033]1337;SetUserVar=CLAUDE_STATUS=%s\007' "$STATUS_VALUE" > "$PANE_TTY"
```

**Verified working**: Testing confirmed that writing to the pane's TTY (`/dev/pts/2` in test) successfully sets the user variable and triggers the tab color change.

### 4. Why `/dev/tty` Doesn't Work

In a detached subprocess like a Claude Code hook, there is no controlling terminal, so `/dev/tty` is not available. The hook process is spawned without a terminal association. We must use the explicit TTY path from WezTerm CLI.

### 5. WezTerm User Variables Architecture

**Setting Variables**: OSC 1337 escape sequences with base64-encoded values:
```
\033]1337;SetUserVar=NAME=BASE64_VALUE\007
```

**Reading Variables in Lua**: Available via `tab.active_pane.user_vars.NAME` in event handlers like `format-tab-title`.

**Triggered Events**:
- `user-var-changed` - Fires when variable changes
- Tab bar automatically refreshes, triggering `format-tab-title`

**Note**: User variables are NOT exposed in `wezterm cli list` JSON output (GitHub issue #3675), only in Lua context.

### 6. WezTerm Configuration Analysis

The current `~/.dotfiles/config/wezterm.lua` already has the correct Lua code:

```lua
if not tab.is_active then
    local active_pane = tab.active_pane
    if active_pane and active_pane.user_vars and active_pane.user_vars.CLAUDE_STATUS == 'needs_input' then
        background = '#e5b566'  -- amber
        foreground = '#151515'  -- black
    end
end
```

This configuration is correct and does not need changes. The issue is solely in the shell scripts.

### 7. Hook Registration Analysis

The `.claude/settings.json` hook registrations are correct:
- `wezterm-notify.sh` is registered in `Stop` hooks
- `wezterm-clear-status.sh` is registered in `UserPromptSubmit` hooks

No changes needed to settings.json.

## Recommendations

### Fix 1: Update wezterm-notify.sh

Replace the printf statement with TTY-targeted output:

```bash
#!/bin/bash
# WezTerm tab notification hook for Claude Code completion
set -euo pipefail

WEZTERM_NOTIFY_ENABLED="${WEZTERM_NOTIFY_ENABLED:-1}"

exit_success() {
    echo '{}'
    exit 0
}

if [[ "$WEZTERM_NOTIFY_ENABLED" != "1" ]]; then
    exit_success
fi

if [[ -z "${WEZTERM_PANE:-}" ]]; then
    exit_success
fi

# Get the TTY for the current pane
PANE_TTY=$(wezterm cli list --format=json 2>/dev/null | \
    jq -r ".[] | select(.pane_id == $WEZTERM_PANE) | .tty_name" 2>/dev/null || echo "")

if [[ -z "$PANE_TTY" ]] || [[ ! -w "$PANE_TTY" ]]; then
    exit_success
fi

# Set CLAUDE_STATUS user variable via OSC 1337 - write to TTY, not stdout
STATUS_VALUE=$(echo -n "needs_input" | base64 | tr -d '\n')
printf '\033]1337;SetUserVar=CLAUDE_STATUS=%s\007' "$STATUS_VALUE" > "$PANE_TTY"

exit_success
```

### Fix 2: Update wezterm-clear-status.sh

Apply the same TTY-targeting fix:

```bash
#!/bin/bash
# WezTerm tab notification clear hook
set -euo pipefail

exit_success() {
    echo '{}'
    exit 0
}

if [[ -z "${WEZTERM_PANE:-}" ]]; then
    exit_success
fi

# Get the TTY for the current pane
PANE_TTY=$(wezterm cli list --format=json 2>/dev/null | \
    jq -r ".[] | select(.pane_id == $WEZTERM_PANE) | .tty_name" 2>/dev/null || echo "")

if [[ -z "$PANE_TTY" ]] || [[ ! -w "$PANE_TTY" ]]; then
    exit_success
fi

# Clear CLAUDE_STATUS user variable - write to TTY, not stdout
printf '\033]1337;SetUserVar=CLAUDE_STATUS=\007' > "$PANE_TTY"

exit_success
```

### Implementation Checklist

1. [ ] Update `.claude/hooks/wezterm-notify.sh` to write to pane TTY
2. [ ] Update `.claude/hooks/wezterm-clear-status.sh` to write to pane TTY
3. [ ] Test by running a Claude Code command and switching tabs
4. [ ] Verify tab shows amber color on inactive tabs when Claude stops
5. [ ] Verify tab color clears when submitting a new prompt

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| TTY not writable | Hook fails silently | Check `-w "$PANE_TTY"` before writing |
| jq not available | Cannot find TTY | Already handled by `2>/dev/null \|\| echo ""` |
| Race condition with TTY | Escape sequence lost | Unlikely with synchronous write |
| Multiple panes per tab | Wrong pane targeted | `$WEZTERM_PANE` is specific to the Claude pane |

## References

### WezTerm Documentation
- [Passing Data from Pane to Lua](https://wezterm.org/recipes/passing-data.html)
- [Escape Sequences](https://wezterm.org/escape-sequences.html)
- [format-tab-title Event](https://wezterm.org/config/lua/window-events/format-tab-title.html)
- [PaneInformation Object](https://wezterm.org/config/lua/PaneInformation.html)

### GitHub Issues
- [wezterm cli list | add user variables (#3675)](https://github.com/wezterm/wezterm/issues/3675) - Feature request explaining why user_vars not in CLI
- [Unable to Set User Var When Connected to Unix Domain (#1528)](https://github.com/wez/wezterm/issues/1528) - Related user variable issues

### Existing Implementation
- `.claude/hooks/wezterm-notify.sh` - Current broken implementation
- `.claude/hooks/wezterm-clear-status.sh` - Current broken implementation
- `~/.dotfiles/config/wezterm.lua` - Correct Lua handler (no changes needed)
- `specs/archive/431_wezterm_tab_color_notification/` - Original implementation task

## Next Steps

1. Run `/plan 775` to create implementation plan
2. Implement fixes to both shell scripts
3. Test in WezTerm with Claude Code
