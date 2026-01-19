# Research Report: Task #585

**Task**: 585 - Add session cleanup to agents
**Date**: 2026-01-19
**Focus**: Claude Code memory management, session cleanup, and monitoring for improved responsiveness

## Executive Summary

- **Critical Finding**: Your system has **25 orphaned Claude processes** consuming **~10.7 GB of memory**, with the `~/.claude/` directory at **7.3 GB**
- Claude Code provides built-in cleanup mechanisms via `cleanupPeriodDays` setting, `/compact`, and `/clear` commands
- Orphaned processes (detached from TTY) are a known issue requiring manual or automated cleanup scripts
- The original task proposal (adding "Stage 8: Session Cleanup" to agents) is **not applicable** - agents cannot manage their own process lifecycle since they run inside Claude's runtime
- **Recommended approach**: Configure Claude Code settings + add system-level cleanup automation

## Context & Scope

This research addresses responsiveness issues when using Claude Code with the agent architecture. The investigation covers:

1. How Claude Code manages sessions and memory internally
2. Mechanisms for cleaning up stale sessions and processes
3. Memory monitoring approaches
4. Simple additions to existing architecture

**Constraints**: Focus on solutions that integrate with current architecture without major rewrites.

## Findings

### 1. Current System State Analysis

**Your System Snapshot** (2026-01-19):

| Metric | Value | Status |
|--------|-------|--------|
| Total Claude processes | 40 | High |
| Orphaned processes (no TTY) | 25 | **Critical** |
| Active processes (with TTY) | 15 | Normal |
| Total process memory | 10.7 GB | **Very High** |
| ~/.claude/ directory size | 7.3 GB | High |
| Project session directories | 327 (for ProofChecker) | High |

**Memory breakdown by process type**:
- Largest processes: 686 MB, 588 MB, 489 MB (likely running complex agents)
- Average per process: ~270 MB
- Orphaned processes contribute ~6.5 GB of the total

### 2. Claude Code Memory Architecture

**Context Window** (per official docs):
- Fixed 200,000 token limit per session
- Shared between conversation history, file contents, command outputs, tool results
- Auto-compacts at 95% capacity by default

**Session Storage**:
- SQLite database + JSONL transcript files in `~/.claude/projects/`
- Organized by project hash (encoded working directory path)
- Each session gets unique UUID

**Memory Files** (loaded on every session):
| Location | Scope | Purpose |
|----------|-------|---------|
| `~/.claude/CLAUDE.md` | User global | Personal preferences |
| `./CLAUDE.md` | Project | Team/project instructions |
| `./.claude/rules/*.md` | Project | Modular rules |
| `./CLAUDE.local.md` | User/project | Personal project prefs |

### 3. Built-in Cleanup Mechanisms

**Session Cleanup Setting** (`cleanupPeriodDays`):
```json
// ~/.claude/settings.json
{
  "cleanupPeriodDays": 30  // Default: 30 days
}
```

Your current `~/.claude/settings.json` only has model setting - **missing cleanup configuration**.

**Recommended settings.json update**:
```json
{
  "model": "sonnet",
  "cleanupPeriodDays": 7
}
```

Setting to 7 days (vs default 30) will reduce stored session data significantly.

**Context Management Commands**:
| Command | Function | When to Use |
|---------|----------|-------------|
| `/clear` | Completely reset context | Between unrelated tasks |
| `/compact` | Summarize conversation | When context > 70% full |
| `/cost` | Show token usage stats | Monitor session health |
| `/context` | Show context breakdown | Debug bloated context |

### 4. Orphaned Process Problem

**How orphaned processes form**:
- Claude Code spawns subprocesses for various operations
- When sessions disconnect improperly, child processes lose their parent
- These processes show `??` in TTY column (not attached to terminal)
- They persist until manually killed or system restart

**Identification** (Linux):
```bash
# Count orphaned Claude processes
ps aux | grep '\[c\]laude' | awk '$7 == "??" {print $2}' | wc -l

# List with memory usage
ps aux | grep '\[c\]laude' | awk '$7 == "??" {print $2, $6/1024 "MB"}'
```

**Manual cleanup** (Linux):
```bash
# Kill all orphaned Claude processes
ps aux | grep '\[c\]laude' | awk '$7 == "??" {print $2}' | xargs kill -9 2>/dev/null
```

### 5. Automated Cleanup Approaches

**Option A: Shell Alias** (manual trigger)
```bash
# Add to ~/.bashrc or ~/.zshrc
alias claude-cleanup='ps aux | grep "\[c\]laude" | awk "\$7 == \"??\" {print \$2}" | xargs kill -9 2>/dev/null'
```

**Option B: systemd Timer** (Linux automated - recommended)
```ini
# ~/.config/systemd/user/claude-cleanup.service
[Unit]
Description=Cleanup orphaned Claude Code processes

[Service]
Type=oneshot
ExecStart=/bin/bash -c "ps aux | grep '[c]laude' | awk '$7 == \"??\" {print $2}' | xargs kill -9 2>/dev/null || true"
```

```ini
# ~/.config/systemd/user/claude-cleanup.timer
[Unit]
Description=Run Claude cleanup hourly

[Timer]
OnCalendar=hourly
Persistent=true

[Install]
WantedBy=timers.target
```

Enable with:
```bash
systemctl --user daemon-reload
systemctl --user enable --now claude-cleanup.timer
```

### 6. Memory Monitoring Approaches

**Command-line monitoring**:
```bash
# Total Claude memory usage
ps aux | grep '\[c\]laude' | awk '{sum += $6} END {print sum/1024/1024 " GB"}'

# Per-session monitoring
watch -n 5 'ps aux | grep claude | grep -v grep | awk "{print \$2, \$6/1024\"MB\", \$11}" | head -20'
```

**In-session monitoring**:
| Command | Shows |
|---------|-------|
| `/cost` | Token usage, API duration, cost |
| `/context` | Context window usage breakdown |
| `claude doctor` | System health, version info |

**Disk monitoring**:
```bash
# Session storage size
du -sh ~/.claude/projects/

# Per-project breakdown
du -sh ~/.claude/projects/*
```

### 7. Task 585 Original Proposal Analysis

The original task proposed adding "Stage 8: Session Cleanup" to agents. This approach is **not feasible** because:

1. **Agents run inside Claude's runtime** - they cannot control their own process lifecycle
2. **No API for memory release** - Claude's architecture doesn't expose memory management
3. **Context is immutable** - context can only be summarized or cleared, not selectively pruned

**What agents CAN do** (current patterns already handle this):
- Return minimal metadata (current pattern uses metadata files)
- Avoid loading unnecessary context (lazy loading pattern)
- Clean up temporary files (already in error handling)

### 8. Alternative Improvements for Architecture

**Improvement 1: Add cleanup reminder to skill postflight**

Skills could log context usage after agent returns:
```
# In skill postflight
- Log session token count for monitoring
- Suggest /compact if > 150k tokens used
```

**Improvement 2: Session-aware agent instructions**

Add to agent documentation:
```markdown
## Session Hygiene
- Use `/cost` before starting complex operations
- Use `/compact` if resuming long-running task
- Prefer metadata files over large JSON returns
```

**Improvement 3: Monitoring hook in CLAUDE.md**

Add to project CLAUDE.md:
```markdown
## Session Maintenance
- After 45 minutes of work: check `/cost`
- If > 100k tokens: run `/compact`
- Between tasks: use `/clear`
```

## Decisions

1. **Do NOT modify agent files** to add cleanup stages - it's not technically possible
2. **DO add system-level cleanup** via settings.json and systemd timer
3. **DO add monitoring guidance** to project documentation
4. **DO recommend immediate cleanup** of current orphaned processes

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Killing active processes | High | Only kill processes with `??` TTY |
| Lost session history | Medium | Set cleanupPeriodDays to 7 (not 1) |
| Cleanup script errors | Low | Use `|| true` to prevent failures |

## Immediate Actions Required

**Step 1: Kill orphaned processes NOW**
```bash
ps aux | grep '\[c\]laude' | awk '$7 == "??" {print $2}' | xargs kill -9 2>/dev/null
```
This will free ~6.5 GB of memory.

**Step 2: Update settings.json**
```bash
echo '{"model": "sonnet", "cleanupPeriodDays": 7}' > ~/.claude/settings.json
```

**Step 3: Set up automated cleanup**
Create systemd user timer (see Section 5, Option B).

**Step 4: Clean old session data**
```bash
# Remove session data older than 7 days (preview first)
find ~/.claude/projects -type f -mtime +7 -name "*.jsonl" | head -20
# Then delete
find ~/.claude/projects -type f -mtime +7 -name "*.jsonl" -delete
```

## Implementation Recommendations

Instead of modifying agents, create these artifacts:

### Artifact 1: `~/.claude/settings.json` (update)
```json
{
  "model": "sonnet",
  "cleanupPeriodDays": 7
}
```

### Artifact 2: `~/.config/systemd/user/claude-cleanup.service`
```ini
[Unit]
Description=Cleanup orphaned Claude Code processes

[Service]
Type=oneshot
ExecStart=/bin/bash -c "ps aux | grep '[c]laude' | awk '$7 == \"??\" {print $2}' | xargs kill -9 2>/dev/null || true"
```

### Artifact 3: `~/.config/systemd/user/claude-cleanup.timer`
```ini
[Unit]
Description=Run Claude cleanup hourly

[Timer]
OnCalendar=hourly
Persistent=true

[Install]
WantedBy=timers.target
```

### Artifact 4: Shell alias in `~/.bashrc`
```bash
alias claude-cleanup='ps aux | grep "\[c\]laude" | awk "\$7 == \"??\" {print \$2}" | xargs kill -9 2>/dev/null'
alias claude-memory='ps aux | grep "\[c\]laude" | awk "{sum += \$6} END {print sum/1024/1024 \" GB\"}"'
```

### Artifact 5: Documentation addition to `.claude/CLAUDE.md`
```markdown
## Session Maintenance

Monitor and maintain Claude Code sessions to prevent memory bloat:

### Regular Checks
- Check memory: `claude-memory` alias
- Check context: `/cost` command in session
- Check disk: `du -sh ~/.claude/projects/`

### Cleanup
- Manual: `claude-cleanup` alias
- Automatic: systemd timer runs hourly
- In-session: `/clear` between tasks, `/compact` for long sessions

### Settings
- `~/.claude/settings.json`: cleanupPeriodDays = 7
- Sessions older than 7 days auto-delete
```

## References

- [Claude Code Memory Management](https://code.claude.com/docs/en/memory) - Official docs
- [Claude Code Cost Management](https://code.claude.com/docs/en/costs) - Token tracking
- [Orphaned Process Cleanup Gist](https://gist.github.com/yowmamasita/f3458e89367a82fbdee4366f456ed576) - Community solution
- [Session Management DeepWiki](https://deepwiki.com/zebbern/claude-code-guide/9.1-session-management) - Technical details
- [Claude Code Settings Guide](https://code.claude.com/docs/en/settings) - Configuration reference
- [Disable Auto-Delete Guide](https://aiengineerguide.com/blog/disable-auto-delete-chat-history-in-claude-code/) - cleanupPeriodDays details

## Next Steps

1. Run `/plan 585` to create implementation plan for cleanup automation
2. Implementation should focus on system-level changes (settings, systemd timer, aliases)
3. **DO NOT** modify agent files for session cleanup - not technically feasible
4. Consider revising task description to reflect actual solution scope
