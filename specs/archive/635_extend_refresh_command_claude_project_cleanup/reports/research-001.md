# Research Report: Task #635

**Task**: 635 - extend_refresh_command_claude_project_cleanup
**Started**: 2026-01-19T22:38:00Z
**Completed**: 2026-01-19T22:50:00Z
**Effort**: Medium
**Priority**: Medium
**Dependencies**: None
**Sources/Inputs**: Codebase exploration, WebSearch, Claude Code project directory analysis
**Artifacts**: This report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The `/refresh` command currently handles only orphaned process cleanup via `skill-refresh` (direct execution skill)
- Claude Code project files accumulate in `~/.claude/projects/{encoded-path}/` with 9.7GB currently for ProofChecker alone
- Primary cleanup candidates: JSONL session logs (largest files up to 750MB each), session directories, and file-history
- Existing multi-mode patterns in `/task` and `/meta` commands provide clear integration approach
- Recommended: Add `--projects` flag to `/refresh` with survey and confirmation-based cleanup

## Context & Scope

### Research Questions

1. What is the current `/refresh` command implementation architecture?
2. What files accumulate in Claude Code project directories?
3. Which files are safe to clean up?
4. How should new modes integrate with existing skills?

### Constraints

- Must preserve active session data
- Must require explicit user confirmation before deletion
- Should integrate cleanly with existing skill-refresh architecture
- Should follow established multi-mode patterns from /task command

## Findings

### 1. Current /refresh Implementation

**Location**: `.claude/skills/skill-refresh/SKILL.md`

**Architecture**:
- Direct execution skill (not a thin wrapper - executes inline without subagent)
- Delegates to bash script: `.claude/scripts/claude-refresh.sh`
- Uses `AskUserQuestion` for confirmation in default mode
- Supports `--force` flag for immediate execution

**Command Pattern**:
```
/refresh [--force]
```

**Current Capabilities**:
- Detects Claude Code processes by pattern matching (`[c]laude`, `[n]ode.*claude`, `[a]nthropic`)
- Identifies orphaned processes (TTY == "?" and not in current process tree)
- Reports memory usage and process age
- Terminates with SIGTERM then SIGKILL if needed

### 2. Claude Code Project Directory Structure

**Location**: `~/.claude/projects/{encoded-path}/`

**Path Encoding**: Project path with `/` replaced by `-`, e.g.:
- `/home/benjamin/Projects/ProofChecker` → `-home-benjamin-Projects-ProofChecker`

**Directory Contents**:

| File Type | Description | Example | Cleanup Safe? |
|-----------|-------------|---------|---------------|
| `{uuid}.jsonl` | Session conversation logs | `bc3ebe50-7be2-4219-94eb-9eb746e05b79.jsonl` | Yes (for old sessions) |
| `{uuid}/` | Session data directory | Contains subagents/, tool-results/ | Yes (for old sessions) |
| `sessions-index.json` | Session index with metadata | Maps session IDs to files | NO - system file |

**Current ProofChecker Statistics**:
- Total size: 9.7 GB
- Total sessions: 365 directories, 1437 JSONL files
- Largest single file: 753 MB (session bc3ebe50)
- Files older than 7 days: 916 (152 MB)
- Files older than 14 days: 3 (240 KB)

### 3. Related Claude Directories

| Directory | Size | Purpose | Cleanup Safe? |
|-----------|------|---------|---------------|
| `~/.claude/projects/` | 11 GB (total) | All project session data | Selective |
| `~/.claude/file-history/` | 56 MB | File version snapshots | Yes (orphaned) |
| `~/.claude/debug/` | 149 MB | Debug logs | Yes |
| `~/.claude/session-env/` | 1.5 MB | Shell environment data | Yes (orphaned) |
| `~/.claude/shell-snapshots/` | 940 KB | Shell state snapshots | Yes |
| `~/.claude/todos/` | 3.3 MB | Todo list state | Caution |

### 4. Session Index Structure

The `sessions-index.json` file tracks session metadata:

```json
{
  "version": 1,
  "entries": [
    {
      "sessionId": "uuid",
      "fullPath": "/home/.../{uuid}.jsonl",
      "fileMtime": 1768094429516,
      "firstPrompt": "command text...",
      "messageCount": 48,
      "created": "2026-01-11T00:48:11.614Z",
      "modified": "2026-01-11T01:20:29.484Z",
      "gitBranch": "main",
      "projectPath": "/home/benjamin/Projects/ProofChecker",
      "isSidechain": false
    }
  ]
}
```

### 5. File Accumulation Patterns

**Large Files** (by size, top 10):
| Size | Session | Date |
|------|---------|------|
| 753 MB | bc3ebe50-7be2-4219-94eb-9eb746e05b79 | Jan 17 |
| 687 MB | 96bc9d3c-a8c6-49bb-a2ca-54b4305b523e | Jan 18 |
| 590 MB | 7a38e926-1187-4458-9c2e-7d0ed2ce0ce4 | Jan 19 |
| 511 MB | 3276839c-c5a0-439b-ae44-899275d48cf6 | Jan 19 |
| 502 MB | 56acddf7-85fd-4800-aa39-11f6ed4423fa | Jan 19 |

**Observation**: Large sessions accumulate quickly. A single long session can generate 500+ MB.

### 6. External Cleanup Tools

**CC-Cleaner** (https://github.com/tk-425/CC-Cleaner):
- Web-based GUI for Claude Code cleanup
- Features: orphan detection, bulk deletion, trash-based recovery
- Identifies files not tracked in .claude.json as orphans

**claude-cleaner** (CLI):
- Options: `--files-only`, `--commits-only`, `--execute`
- Dry-run by default

### 7. Multi-Mode Skill Patterns

**Pattern from /task command**:
```markdown
## Mode Detection

Check $ARGUMENTS for flags:
- `--recover RANGES` → Recover mode
- `--expand N` → Expand mode
- `--sync` → Sync mode
- `--abandon RANGES` → Abandon mode
- No flag → Default mode (create)
```

**Pattern from /meta command**:
```markdown
### 1. Mode Detection

if $ARGUMENTS is empty:
    mode = "interactive"
elif $ARGUMENTS == "--analyze":
    mode = "analyze"
else:
    mode = "prompt"
```

## Recommendations

### 1. Command Interface Design

Extend `/refresh` with new `--projects` flag:

```
/refresh [--force]           # Current: process cleanup
/refresh --projects [opts]   # New: project file cleanup
```

**Project cleanup options**:
- `--projects` - Survey project directory and prompt for cleanup
- `--projects --force` - Skip confirmation and clean immediately
- `--projects --age DAYS` - Only target sessions older than DAYS (default: 7)
- `--projects --dry-run` - Show what would be cleaned without changes
- `--projects --all` - Clean all Claude projects, not just current

### 2. Cleanup Strategy

**Safe to Clean**:
1. Session JSONL files older than threshold (default 7 days)
2. Corresponding session directories
3. Orphaned file-history entries (no matching session)
4. Debug logs older than threshold
5. Orphaned session-env directories

**Never Clean**:
1. `sessions-index.json` - System file
2. Active sessions (less than threshold age)
3. Currently running session

### 3. Implementation Architecture

**Option A: Extend Skill with Bash Script** (Recommended)

Create new script: `.claude/scripts/claude-project-cleanup.sh`
- Survey function: count files, calculate sizes, identify cleanup candidates
- Cleanup function: remove files, update sessions-index.json (if needed)
- Similar structure to existing `claude-refresh.sh`

Extend skill-refresh SKILL.md:
- Add mode detection for `--projects`
- Route to appropriate script
- Use AskUserQuestion for confirmation

**Option B: Create Separate Skill**

Create `skill-project-cleanup`:
- Dedicated skill for project file management
- More isolated but less discoverable

### 4. Survey Output Format

```
Claude Code Project Cleanup
===========================

Project: /home/benjamin/Projects/ProofChecker
Directory: ~/.claude/projects/-home-benjamin-Projects-ProofChecker/

Current Usage:
  Total size:        9.7 GB
  Session count:     365
  JSONL log count:   1437

Cleanup Candidates (sessions older than 7 days):
  Sessions:          152
  Total size:        3.2 GB
  Largest:           bc3ebe50... (753 MB, 12 days old)

Would you like to clean up these old sessions?
```

### 5. Safety Measures

1. **Age threshold**: Default 7 days, configurable
2. **Dry run first**: Show what will be deleted before acting
3. **Confirmation required**: Use AskUserQuestion unless --force
4. **Preserve recent**: Never delete sessions from current day
5. **Backup option**: Consider moving to trash instead of permanent delete
6. **Index update**: After cleanup, prune orphaned entries from sessions-index.json

### 6. Files to Create/Modify

| File | Action | Purpose |
|------|--------|---------|
| `.claude/scripts/claude-project-cleanup.sh` | Create | Survey and cleanup logic |
| `.claude/skills/skill-refresh/SKILL.md` | Modify | Add --projects mode |
| `.claude/commands/refresh.md` | Modify | Document new mode |

## Decisions

1. **Extend existing skill** rather than create new skill - follows DRY principle and keeps refresh functionality consolidated
2. **Use bash script** for cleanup logic - consistent with existing claude-refresh.sh pattern
3. **Age-based cleanup** - safest approach, preserves recent work
4. **Confirmation by default** - consistent with existing /refresh behavior

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Accidental deletion of needed session | High | Age threshold, confirmation prompt, dry-run option |
| sessions-index.json corruption | Medium | Never modify directly; let Claude Code manage |
| Slow startup not actually caused by files | Low | Verify improvement after cleanup |
| Cross-project cleanup | Medium | Default to current project only; --all requires explicit flag |

## Appendix

### Search Queries Used

- "Claude Code CLI project directory cleanup ~/.claude/projects sessions 2026"
- CC-Cleaner GitHub repository
- claude-cleaner JSR package

### File Statistics Collection Commands

```bash
# Total size
du -sh ~/.claude/projects/-home-benjamin-Projects-ProofChecker

# Session count
find . -maxdepth 1 -type d | tail -n +2 | wc -l

# JSONL count
find . -name '*.jsonl' -type f | wc -l

# Age distribution
find . -type f -mtime +7 | wc -l
find . -type f -mtime +14 | wc -l

# Largest files
ls -laS *.jsonl | head -20
```

### References

- [CC-Cleaner GitHub](https://github.com/tk-425/CC-Cleaner) - Web GUI for Claude Code cleanup
- [Claude Code Issue #17792](https://github.com/anthropics/claude-code/issues/17792) - Temp file cleanup discussion
- [Claude Code Issue #17996](https://github.com/anthropics/claude-code/issues/17996) - Temp file directory configuration
- [Claude Code CLI Reference](https://code.claude.com/docs/en/cli-reference) - Official documentation
