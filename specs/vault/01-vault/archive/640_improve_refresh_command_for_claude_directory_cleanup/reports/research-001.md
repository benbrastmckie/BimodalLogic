# Research Report: Task #640

**Task**: 640 - improve_refresh_command_for_claude_directory_cleanup
**Started**: 2026-01-20T09:33:00Z
**Completed**: 2026-01-20T09:45:00Z
**Effort**: Medium
**Priority**: High
**Dependencies**: None
**Sources/Inputs**:
- Codebase exploration (existing /refresh skill and scripts)
- Web search for Claude Code cleanup best practices
- Analysis of ~/.claude/ directory structure
**Artifacts**:
- specs/640_improve_refresh_command_for_claude_directory_cleanup/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The ~/.claude/ directory on this system is 7.3GB, with projects/ consuming 7.1GB (97%)
- Current /refresh --projects only cleans the current project's directory; does NOT clean other directories (debug, file-history, todos, session-env, plugins)
- Web research confirms community demand for comprehensive cleanup tools (multiple third-party tools exist: CC-Cleaner, claude-cleaner, claude-config-editor)
- Recommended approach: Add `--global` mode to clean directories across entire ~/.claude/, with tiered age thresholds (8h/2d/everything) as specified

## Context & Scope

### Problem Statement
The ~/.claude/ directory grows without bound, causing:
1. Long startup times when Claude scans the directory
2. Significant disk space consumption (7GB+ in this case)
3. Accumulation of orphaned files from old sessions

### Current /refresh Capabilities
- **Process cleanup**: Identifies and terminates orphaned Claude Code processes
- **Project cleanup** (`--projects`): Cleans session files in `~/.claude/projects/{current-project}/` only

### Limitations of Current Implementation
1. Only cleans the current project directory - does not handle other projects or global directories
2. Uses modification time (mtime) which gets reset when Claude scans files
3. Does not clean: debug/, file-history/, session-env/, todos/, plugins/cache/
4. Default 7-day threshold is too conservative for aggressive cleanup

## Findings

### 1. Directory Structure Analysis

| Directory | Size | Files | Description | Safe to Clean? |
|-----------|------|-------|-------------|----------------|
| projects/ | 7.1GB | 1088 | Session .jsonl files + subdirs | Yes, by age |
| debug/ | 151MB | 691 | Debug output files | Yes, safe to delete |
| file-history/ | 56MB | 3358 | File version snapshots | Yes, orphaned safe |
| todos/ | 3.4MB | 817 | Todo list backups | Yes, by age |
| session-env/ | 1.5MB | 0 | Environment snapshots | Yes, orphaned safe |
| plugins/ | 2.4MB | - | Plugin cache | Yes, old versions |
| telemetry/ | 1.5MB | - | Usage telemetry | Yes, safe to delete |
| shell-snapshots/ | 968KB | - | Shell state | Yes, safe to delete |
| history.jsonl | 578KB | 1 | Command history | Caution - user history |
| cache/ | 76KB | - | General cache | Yes, safe to delete |

### 2. Key Files to Preserve

**NEVER DELETE**:
- `sessions-index.json` - Critical system file in each project directory
- `settings.json` - User settings
- `.credentials.json` - Authentication credentials
- Files modified within the last hour (safety margin)

### 3. Web Research Findings

#### Community Cleanup Tools
1. **CC-Cleaner** ([GitHub](https://github.com/tk-425/CC-Cleaner)): Web GUI for managing Claude Code projects
   - Handles orphaned file-history, session-env, debug, todos
   - Identifies files not linked to active sessions

2. **claude-config-editor** ([GitHub](https://github.com/gagarinyury/claude-config-editor)): Web tool for config cleanup
   - Reports users reducing 17MB to 732KB via chat history cleanup

3. **@tylerbu/claude-cleaner**: JSR package for cleanup

#### Known Issues (GitHub)
- **#16453**: Plugin cache grows indefinitely - no automatic cleanup
- **#11963**: Request for `claude cleanup` command - still open
- **#15621**: Plugin cache keeps old versions

#### Best Practices from Community
- "Aggressively clear context between subtasks" - applies to file cleanup too
- Use `/compact` command to trim context data
- Regular cleanup can resolve performance degradation

### 4. Startup Time Analysis

Current Claude startup time: ~1.1 seconds
This is reasonable, but will degrade as directory grows larger.

### 5. Age-Based Cleanup Thresholds

The user requested three tiers:
1. **Everything** (clean slate, most aggressive)
2. **Everything before 8 hours** (default)
3. **Everything before 2 days**

These map to cleanup ages of:
- `--age 0` or `--all`: Everything (preserve only last-hour safety margin)
- `--age 0.33` (8 hours): Default aggressive cleanup
- `--age 2`: Conservative cleanup

## Recommendations

### 1. Add Global Cleanup Mode

Add `--global` flag to clean entire ~/.claude/ directory, not just current project:

```bash
/refresh --global [--age HOURS] [--dry-run] [--force]
```

### 2. Extend Cleanup Scope

The new global mode should clean:
- All project directories in ~/.claude/projects/
- ~/.claude/debug/ (all files)
- ~/.claude/file-history/ (orphaned sessions or by age)
- ~/.claude/todos/ (by age)
- ~/.claude/session-env/ (orphaned directories)
- ~/.claude/plugins/cache/ (old versions)
- ~/.claude/telemetry/ (all files)
- ~/.claude/shell-snapshots/ (by age)

### 3. Implement Tiered Age Options

Change `--age` to accept hours instead of days for finer control:

| Option | Hours | Description |
|--------|-------|-------------|
| `--all` | 0 | Clean everything (except safety margin) |
| `--age 8` | 8 | Default - aggressive cleanup |
| `--age 48` | 48 | Conservative - 2 days |
| `--age 168` | 168 | Current behavior - 7 days |

### 4. Add Preset Shortcuts

For convenience:
- `/refresh --global` - Default 8-hour cleanup
- `/refresh --global --aggressive` - Clean everything
- `/refresh --global --conservative` - 2-day cleanup

### 5. Update Safety Measures

1. Preserve files modified within last hour (existing)
2. Never delete sessions-index.json (existing)
3. Never delete settings.json, .credentials.json (new)
4. Show summary of what will be cleaned before confirmation
5. Backup sessions-index.json before any operation (new)

### 6. Documentation Updates

Update these files:
- `.claude/commands/refresh.md` - Add new options
- `.claude/skills/skill-refresh/SKILL.md` - Update skill instructions
- `CLAUDE.md` - Update Session Maintenance section

## Implementation Approach

### Phase 1: New Cleanup Script
Create `.claude/scripts/claude-global-cleanup.sh`:
- Accepts `--age HOURS`, `--dry-run`, `--force`, `--all`, `--aggressive`, `--conservative`
- Iterates through all cleanable directories
- Reports sizes before/after
- Respects safety measures

### Phase 2: Update Skill
Modify `skill-refresh/SKILL.md`:
- Add `--global` mode detection
- Route to new cleanup script
- Update return format for global cleanup results

### Phase 3: Update Command
Modify `.claude/commands/refresh.md`:
- Document new `--global` mode
- Document age presets
- Update examples

### Phase 4: Optional Enhancements
- Add systemd timer option for global cleanup
- Add shell alias `claude-cleanup` for `claude-refresh --global`

## Decisions

1. **Age unit**: Use hours (not days) for `--age` in global mode for finer control
2. **Default behavior**: Keep current `/refresh` behavior unchanged; new features require `--global` flag
3. **Presets**: Provide `--aggressive` and `--conservative` shortcuts for common use cases
4. **Safety**: Always preserve last-hour files and critical system files

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Accidental deletion of needed sessions | Medium | High | Dry-run default, confirmation prompt, backup sessions-index.json |
| Breaking Claude Code functionality | Low | High | Never delete system files, test thoroughly |
| Inconsistent state after partial cleanup | Low | Medium | Atomic operations, clear error reporting |
| User confusion with new options | Medium | Low | Clear documentation, sensible defaults |

## Appendix

### Search Queries Used
1. "claude code ~/.claude directory cleanup garbage collection best practices 2026"
2. "claude code slow startup scanning projects directory fix"
3. "claude code history.jsonl cleanup OR delete OR manage size"
4. "claude code debug OR file-history OR session-env directory cleanup"

### References
- [CC-Cleaner](https://github.com/tk-425/CC-Cleaner) - Web GUI cleanup tool
- [claude-config-editor](https://github.com/gagarinyury/claude-config-editor) - Config optimization tool
- [GitHub Issue #11963](https://github.com/anthropics/claude-code/issues/11963) - Auto-cleanup feature request
- [GitHub Issue #16453](https://github.com/anthropics/claude-code/issues/16453) - Plugin cache growth issue
- [Simon Willison on Claude Code logs](https://simonwillison.net/2025/Oct/22/claude-code-logs/) - Log preservation guidance

### Current Directory State

```
~/.claude/ (7.3GB total)
├── projects/        7.1GB  (97% of total)
├── debug/           151MB
├── file-history/    56MB
├── todos/           3.4MB
├── plugins/         2.4MB
├── telemetry/       1.5MB
├── session-env/     1.5MB
├── shell-snapshots/ 968KB
├── history.jsonl    578KB
├── cache/           76KB
└── (other files)    ~1MB
```
