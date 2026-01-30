# Implementation Plan: Task #775

- **Task**: 775 - Fix WezTerm tab coloring with Claude Code hooks
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/775_fix_wezterm_tab_coloring_with_claude_code_hooks/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

The WezTerm tab coloring feature is not working because the Claude Code hooks write OSC 1337 escape sequences to captured stdout (a socket) instead of the actual terminal TTY. The escape sequences are captured by Claude Code as part of the hook's JSON output rather than being sent to WezTerm. The fix requires writing escape sequences directly to the pane's TTY device file (obtained via `wezterm cli list --format=json`) instead of using printf to stdout.

### Research Integration

Key findings from research-001.md:
- Root cause identified: Claude Code hooks have redirected stdio (stdin/stdout are sockets, stderr is /dev/null)
- Solution verified: Writing to the pane's TTY (e.g., `/dev/pts/2`) successfully sets user variables
- WezTerm Lua configuration is correct and does not need changes
- Hook registrations in settings.json are correct

## Goals & Non-Goals

**Goals**:
- Fix wezterm-notify.sh to write escape sequences to the pane's TTY
- Fix wezterm-clear-status.sh to write escape sequences to the pane's TTY
- Maintain graceful failure when TTY is unavailable
- Preserve existing hook output (JSON) for Claude Code

**Non-Goals**:
- Modifying WezTerm Lua configuration (already correct)
- Changing hook registrations in settings.json
- Adding new features beyond fixing the tab coloring

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| TTY not writable | Hook fails silently | Low | Check `-w "$PANE_TTY"` before writing |
| jq not available | Cannot find TTY | Low | Handled by `2>/dev/null \|\| echo ""` fallback |
| WEZTERM_PANE not set | Cannot find correct pane | Low | Early exit with success (preserves hook behavior) |
| wezterm CLI unavailable | Cannot query pane info | Low | Early exit with success |

## Implementation Phases

### Phase 1: Update wezterm-notify.sh [NOT STARTED]

**Goal**: Modify the notification hook to write escape sequences to the pane's TTY instead of stdout

**Tasks**:
- [ ] Read current `.claude/hooks/wezterm-notify.sh` implementation
- [ ] Add TTY lookup using `wezterm cli list --format=json`
- [ ] Add TTY writability check
- [ ] Redirect escape sequence output to TTY
- [ ] Verify JSON output still goes to stdout

**Timing**: 30 minutes

**Files to modify**:
- `.claude/hooks/wezterm-notify.sh` - Replace printf to stdout with printf to TTY

**Verification**:
- Hook returns valid JSON `{}` on stdout
- Escape sequence is written to the pane's TTY device

---

### Phase 2: Update wezterm-clear-status.sh [NOT STARTED]

**Goal**: Modify the clear hook to write escape sequences to the pane's TTY instead of stdout

**Tasks**:
- [ ] Read current `.claude/hooks/wezterm-clear-status.sh` implementation
- [ ] Add TTY lookup using `wezterm cli list --format=json`
- [ ] Add TTY writability check
- [ ] Redirect escape sequence output to TTY
- [ ] Verify JSON output still goes to stdout

**Timing**: 30 minutes

**Files to modify**:
- `.claude/hooks/wezterm-clear-status.sh` - Replace printf to stdout with printf to TTY

**Verification**:
- Hook returns valid JSON `{}` on stdout
- Escape sequence is written to the pane's TTY device

---

### Phase 3: Integration Testing [NOT STARTED]

**Goal**: Verify the complete tab coloring workflow functions correctly

**Tasks**:
- [ ] Start a Claude Code session in WezTerm
- [ ] Execute a command that triggers the Stop hook
- [ ] Switch to a different tab
- [ ] Verify the Claude tab shows amber color
- [ ] Switch back to the Claude tab and submit a new prompt
- [ ] Verify the tab color clears

**Timing**: 30 minutes

**Files to modify**:
- None (testing only)

**Verification**:
- Inactive tabs with pending Claude input show amber background (#e5b566)
- Submitting a prompt clears the amber background
- No errors appear in Claude Code output

## Testing & Validation

- [ ] Hook returns valid JSON `{}` when WEZTERM_PANE is not set
- [ ] Hook returns valid JSON `{}` when TTY is not writable
- [ ] Escape sequence reaches WezTerm (tab color changes)
- [ ] Tab color clears on UserPromptSubmit
- [ ] No regression in hook timing or Claude Code behavior

## Artifacts & Outputs

- `.claude/hooks/wezterm-notify.sh` (modified)
- `.claude/hooks/wezterm-clear-status.sh` (modified)
- `specs/775_fix_wezterm_tab_coloring_with_claude_code_hooks/summaries/implementation-summary-20260130.md`

## Rollback/Contingency

If the fix causes issues:
1. Revert both hook scripts to previous versions using git
2. The hooks will return to their previous (non-functional but harmless) state
3. Tab coloring will simply not work, which is the current behavior

Git command to rollback:
```bash
git checkout HEAD^ -- .claude/hooks/wezterm-notify.sh .claude/hooks/wezterm-clear-status.sh
```
