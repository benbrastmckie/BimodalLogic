# Research Report: Task #793

**Task**: 793 - fix_claude_code_neovim_sidebar_black_screen
**Started**: 2026-02-01T12:00:00Z
**Completed**: 2026-02-01T12:45:00Z
**Effort**: Medium
**Dependencies**: None
**Sources/Inputs**: Web search, Claude Code GitHub issues, codebase review, official documentation
**Artifacts**: This report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The black screen issue is likely caused by Claude Code's terminal rendering system, not the hook system
- Recent Claude Code versions (2.1.27+) have known rendering/CPU issues that may contribute
- The WezTerm hooks (tasks 788-791) are fast and unlikely to cause 30-second delays
- Multiple potential causes identified with corresponding fix recommendations
- Recommended approach: Enable async hooks, use synchronized output terminal, and consider Claude Code version testing

## Context & Scope

### Problem Description
Running a command in Claude Code sidebar in Neovim causes an initial black screen (all text disappears) for approximately 30 seconds before showing activity. The functionality works correctly otherwise. The issue started recently and is inconsistent.

### Environment
- **Claude Code Version**: 2.1.29
- **Neovim Version**: 0.11.5
- **Terminal**: WezTerm (implied by hook configuration)
- **Platform**: Linux (NixOS based on environment)

## Findings

### 1. Claude Code Known Rendering Issues

#### a. Differential Renderer Limitations
Anthropic rewrote Claude Code's rendering system to reduce flickering by ~85%, but issues persist:
- The system uses scrollback buffer (not alternate screen buffer)
- This requires clearing and redrawing everything on changes
- Can cause visible tearing, especially in constrained environments like sidebar panes

**Source**: [Claude Chill Hacker News Discussion](https://news.ycombinator.com/item?id=46699072)

#### b. Blank Screen During Long Operations (Bug #12996)
Known bug where UI goes completely blank with zero progress indication during extended operations:
- Affects Windows primarily but also reported on macOS and WSL
- Screen appears "dead" with no spinner, dots, or status text
- Cannot determine if operation is proceeding or crashed

**Source**: [GitHub Issue #12996](https://github.com/anthropics/claude-code/issues/12996)

#### c. v2.1.27+ CPU Hang Issue
Critical bug in v2.1.27 where CLI hangs at 100% CPU after first response:
- **Working versions**: 2.1.22, 2.1.23, 2.1.25
- **Broken versions**: 2.1.27+
- Issue NOT related to hooks - confirmed by disabling all hooks
- May contribute to rendering delays/black screen

**Source**: [GitHub Issue #22158](https://github.com/anthropics/claude-code/issues/22158)

### 2. Hook System Analysis

#### a. Current Hook Configuration
The project has these hooks configured in `.claude/settings.json`:

| Event | Hooks | Potential Impact |
|-------|-------|------------------|
| SessionStart | log-session.sh, claude-ready-signal.sh | **Medium** - Runs on startup |
| UserPromptSubmit | wezterm-task-number.sh, wezterm-clear-status.sh | **Low** - Fast execution |
| Stop | post-command.sh, tts-notify.sh, wezterm-notify.sh | **Low** - Runs after response |
| SubagentStop | subagent-postflight.sh | **Medium** - Can block stop |
| PreToolUse/PostToolUse | Various matchers | **Low** - Targeted execution |

#### b. Hook Execution Timing Evidence
From `/tmp/claude-ready-signal.log`:
```
[2026-02-01 22:21:18] Hook triggered, NVIM=/run/user/1000/nvim.2034916.0
[2026-02-01 22:21:19] Result: vim.NIL (exit: 0)
```
The hook executes in approximately 1 second - not a 30-second delay source.

#### c. WezTerm Hook Performance
Tested `wezterm cli list --format=json | jq`:
- **Execution time**: 9ms
- **Status**: Fast, not a delay source

#### d. Known Hook Issues

1. **Blocking Behavior** (Bug #4809): PostToolUse hooks with exit code 1 can block Claude's execution despite documentation saying they're non-blocking

2. **Async Hook Solution**: Claude Code 2.1.0+ supports `async: true` for non-blocking background execution

3. **UserPromptSubmit/SessionStart Context Injection**: These hooks add stdout as context Claude can see, which could cause processing delays with large outputs

**Source**: [Claude Code Hooks Reference](https://code.claude.com/docs/en/hooks)

### 3. Neovim Integration Analysis

#### a. SessionStart Hook (claude-ready-signal.sh)
```bash
nvim --server "$NVIM" --remote-expr \
  'v:lua.require("neotex.plugins.ai.claude.claude-session.terminal-state").on_claude_ready()'
```

**Findings**:
- Uses `nvim --remote-expr` which has known issues in Neovim 0.9.0+ (GitHub #22970)
- The hook logs show instant execution (not the delay source)
- The `v:lua.require()` call triggers Lua module loading

#### b. Terminal State Module
The `terminal-state.lua` module:
- Uses event-driven autocommands (not timer-based polling)
- Has fallback detection via TextChanged autocommand
- 100ms delay in `on_claude_ready()` for initialization

### 4. Terminal Rendering Factors

#### a. Synchronized Output (DEC Mode 2026)
Anthropic recommends terminals with DEC mode 2026 support:
- **Ghostty**: Zero flicker, full 2026 support
- **tmux**: Has patches for synchronized output
- **WezTerm**: May need configuration for optimal performance

#### b. Sidebar Pane Constraints
Claude Code rendering is more prone to issues in constrained environments:
- Narrow window widths can cause display corruption
- Sidebar panes have limited viewport
- Layout calculations become more complex

### 5. Potential Root Causes

Based on research, the most likely causes in priority order:

| Priority | Cause | Evidence | Likelihood |
|----------|-------|----------|------------|
| 1 | Claude Code v2.1.29 rendering bug | Known issues in 2.1.27+ | High |
| 2 | Synchronous hook blocking | Multiple hooks on UserPromptSubmit | Medium |
| 3 | Terminal synchronized output missing | WezTerm config not verified | Medium |
| 4 | Narrow sidebar viewport | Reported for narrow windows | Medium |
| 5 | Neovim remote-expr delay | Would show in logs | Low |

## Recommendations

### Immediate Fixes (Try First)

1. **Test Claude Code 2.1.25**
   ```bash
   # Use known working version
   ~/.local/share/claude/versions/2.1.25
   ```
   This bypasses the v2.1.27+ rendering/CPU issues.

2. **Enable Async Hooks for WezTerm Integration**
   Update `.claude/settings.json` to use async hooks:
   ```json
   {
     "hooks": {
       "UserPromptSubmit": [
         {
           "matcher": "*",
           "hooks": [
             {
               "type": "command",
               "command": "bash .claude/hooks/wezterm-task-number.sh 2>/dev/null || echo '{}'",
               "async": true
             },
             {
               "type": "command",
               "command": "bash .claude/hooks/wezterm-clear-status.sh 2>/dev/null || echo '{}'",
               "async": true
             }
           ]
         }
       ]
     }
   }
   ```

3. **Disable SessionStart Neovim Hook Temporarily**
   Comment out the claude-ready-signal.sh hook to test if it's contributing:
   ```json
   "SessionStart": [
     {
       "matcher": "startup",
       "hooks": [
         {
           "type": "command",
           "command": "bash .claude/hooks/log-session.sh 2>/dev/null || echo '{}'"
         }
         // Temporarily disabled:
         // {
         //   "type": "command",
         //   "command": "bash ~/.config/nvim/scripts/claude-ready-signal.sh 2>/dev/null || echo '{}'"
         // }
       ]
     }
   ]
   ```

### Configuration Fixes

4. **Configure WezTerm for Synchronized Output**
   Add to `wezterm.lua`:
   ```lua
   config.enable_kitty_keyboard = true
   config.enable_csi_u_key_encoding = true
   ```

5. **Increase Sidebar Width**
   If using a narrow sidebar, try increasing width to reduce rendering complexity.

### Investigation Fixes

6. **Enable Hook Debug Mode**
   ```bash
   claude --debug
   ```
   Then check verbose output (Ctrl+O) during the black screen period.

7. **Add Timing to Hooks**
   Modify each hook to log start/end times:
   ```bash
   echo "[$(date -Iseconds)] START: hook-name" >> /tmp/claude-hooks.log
   # ... existing hook code ...
   echo "[$(date -Iseconds)] END: hook-name" >> /tmp/claude-hooks.log
   ```

### Long-term Fixes

8. **Consider Ghostty Terminal**
   Ghostty has DEC mode 2026 support and zero flicker - recommended by Anthropic.

9. **Report Issue to Anthropic**
   If issue persists after testing, file a bug report with:
   - Claude Code version
   - Terminal and version
   - Hook configuration
   - Debug output during black screen

## Decisions

1. **Hook system is NOT the primary cause** - Execution logs show fast completion
2. **Claude Code version is likely a major factor** - v2.1.27+ has known rendering issues
3. **Multiple hooks on UserPromptSubmit should use async** - Reduces startup blocking
4. **SessionStart neovim hook is safe** - Logs show instant execution

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Downgrading Claude Code loses features | Medium | Test specific version first, report bug upstream |
| Async hooks may miss events | Low | Claude Code handles async hook completion gracefully |
| Disabling neovim hook breaks integration | Medium | Test in isolation, use TextChanged fallback |

## Appendix

### Search Queries Used
1. "Claude Code neovim sidebar black screen delay rendering issue 2026"
2. "Claude Code CLI terminal black screen 30 seconds delay"
3. "Claude Code hooks PreToolUse PostToolUse slow delay blocking"
4. "Claude Code hooks async blocking SessionStart UserPromptSubmit slow startup"
5. "nvim --remote-expr slow delay blocking neovim"
6. "Claude Code UserPromptSubmit hook slow rendering delay black screen"
7. "Claude Code 2.1.29 black screen rendering delay neovim terminal"

### Key References
- [Claude Code Hooks Reference](https://code.claude.com/docs/en/hooks)
- [Blank Screen Bug #12996](https://github.com/anthropics/claude-code/issues/12996)
- [v2.1.27 CPU Hang #22158](https://github.com/anthropics/claude-code/issues/22158)
- [CLI Black Output #14769](https://github.com/anthropics/claude-code/issues/14769)
- [SessionStart Hook Issues #10373](https://github.com/anthropics/claude-code/issues/10373)
- [Claude Chill Discussion](https://news.ycombinator.com/item?id=46699072)
- [Neovim remote-expr Issues #22970](https://github.com/neovim/neovim/issues/22970)

### Files Reviewed
- `.claude/settings.json` - Hook configuration
- `.claude/hooks/wezterm-notify.sh` - WezTerm stop notification
- `.claude/hooks/wezterm-task-number.sh` - Task number extraction
- `.claude/hooks/wezterm-clear-status.sh` - Status clearing
- `.claude/hooks/log-session.sh` - Session logging
- `.claude/hooks/tts-notify.sh` - TTS notification
- `.claude/hooks/post-command.sh` - Post-command logging
- `.claude/hooks/subagent-postflight.sh` - Subagent postflight handler
- `~/.config/nvim/scripts/claude-ready-signal.sh` - Neovim integration hook
- `~/.config/nvim/lua/neotex/plugins/ai/claude/claude-session/terminal-state.lua` - Terminal state module

### Hook Execution Log Sample
```
[2026-02-01 22:21:18] Hook triggered, NVIM=/run/user/1000/nvim.2034916.0
[2026-02-01 22:21:19] Result: vim.NIL (exit: 0)
```
