# Implementation Plan: Task #635

- **Task**: 635 - extend_refresh_command_claude_project_cleanup
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/635_extend_refresh_command_claude_project_cleanup/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Extend the `/refresh` command with a `--projects` mode for surveying and cleaning up accumulated Claude Code project files in `~/.claude/projects/`. The implementation adds a new bash script `claude-project-cleanup.sh` following the existing `claude-refresh.sh` pattern, extends `skill-refresh/SKILL.md` with mode detection, and updates the command documentation. This enables users to reclaim disk space from old session files that cause slow startup.

### Research Integration

Key findings from research-001.md:
- ProofChecker project directory: 9.7 GB across 365 sessions
- Primary cleanup targets: JSONL session logs (up to 753 MB each) and session directories
- Must preserve `sessions-index.json` (system file) and recent sessions
- Multi-mode skill pattern from `/task` command provides integration template
- Age-based cleanup (default 7 days) is safest approach

## Goals & Non-Goals

**Goals**:
- Add `--projects` flag to `/refresh` for project file cleanup
- Survey project directories showing size, session count, and cleanup candidates
- Require explicit user confirmation before deletion (unless `--force`)
- Support configurable age threshold via `--age DAYS` option
- Support `--dry-run` mode to preview cleanup without changes
- Integrate seamlessly with existing process cleanup functionality

**Non-Goals**:
- Modifying `sessions-index.json` directly (let Claude Code manage it)
- Cross-project cleanup (`--all` flag deferred to future enhancement)
- Trash-based recovery (immediate deletion is simpler)
- GUI or interactive file selection

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Accidental deletion of needed session | High | Age threshold (7 days default), confirmation prompt, dry-run option |
| sessions-index.json corruption | High | Never modify; only delete files, let Claude Code handle index |
| Slow cleanup on large directories | Medium | Stream output during cleanup, show progress |
| Current session deletion | High | Never delete files modified within last hour |

## Implementation Phases

### Phase 1: Create Project Cleanup Script [NOT STARTED]

**Goal**: Implement the core bash script for surveying and cleaning project files

**Tasks**:
- [ ] Create `.claude/scripts/claude-project-cleanup.sh`
- [ ] Implement `get_project_dir()` function to resolve current project path to encoded directory
- [ ] Implement `survey_project()` function to count sessions, calculate sizes, identify cleanup candidates by age
- [ ] Implement `cleanup_sessions()` function to delete old JSONL files and session directories
- [ ] Add `--age DAYS`, `--dry-run`, and `--force` flag parsing
- [ ] Format output similar to `claude-refresh.sh` (colors, tables, summaries)
- [ ] Add safety checks: exclude files modified in last hour, never touch sessions-index.json
- [ ] Make script executable

**Timing**: 1.5 hours

**Files to modify**:
- `.claude/scripts/claude-project-cleanup.sh` - Create new (main cleanup script)

**Verification**:
- Script runs standalone with `./claude-project-cleanup.sh`
- Survey output shows correct statistics (cross-check with `du` and `find` commands)
- Dry-run mode shows candidates without deleting
- Force mode deletes old sessions correctly
- Current session never targeted

---

### Phase 2: Extend Skill with Mode Detection [NOT STARTED]

**Goal**: Add `--projects` mode to skill-refresh SKILL.md with routing logic

**Tasks**:
- [ ] Update SKILL.md frontmatter description to include project cleanup
- [ ] Add mode detection section to parse `--projects` flag and sub-options
- [ ] Add execution path for projects mode that calls `claude-project-cleanup.sh`
- [ ] Integrate with AskUserQuestion for confirmation (reuse existing pattern)
- [ ] Add return format documentation for projects mode output
- [ ] Add error handling for missing project directory

**Timing**: 45 minutes

**Files to modify**:
- `.claude/skills/skill-refresh/SKILL.md` - Extend with projects mode

**Verification**:
- `/refresh --projects` triggers project cleanup mode
- `/refresh` (no flags) continues to work for process cleanup
- Confirmation prompt appears in default mode
- `--force` bypasses confirmation

---

### Phase 3: Update Command Documentation [NOT STARTED]

**Goal**: Document new `--projects` mode in command file

**Tasks**:
- [ ] Update `.claude/commands/refresh.md` with `--projects` syntax
- [ ] Add options table for `--projects` sub-options (`--age`, `--dry-run`)
- [ ] Add examples for common usage patterns
- [ ] Update execution section to describe mode routing
- [ ] Add safety notes specific to project cleanup

**Timing**: 30 minutes

**Files to modify**:
- `.claude/commands/refresh.md` - Add projects mode documentation

**Verification**:
- Documentation matches implemented behavior
- Examples are accurate and runnable
- Safety notes clearly explain what will/won't be deleted

---

### Phase 4: Integration Testing and Verification [NOT STARTED]

**Goal**: Verify end-to-end functionality and safety measures

**Tasks**:
- [ ] Test `/refresh --projects` survey output on actual project directory
- [ ] Test `/refresh --projects --dry-run` shows candidates without deleting
- [ ] Test `/refresh --projects --age 1` with short age threshold
- [ ] Test `/refresh --projects --force` performs cleanup
- [ ] Verify original `/refresh` process cleanup still works
- [ ] Verify sessions-index.json is never modified
- [ ] Verify current session files are protected
- [ ] Update CLAUDE.md Session Maintenance section with new command

**Timing**: 15 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - Update Session Maintenance quick commands table

**Verification**:
- All test cases pass
- No regressions in existing functionality
- CLAUDE.md reflects new capabilities

## Testing & Validation

- [ ] Survey output correctly identifies cleanup candidates by age
- [ ] Dry-run mode reports but does not delete
- [ ] Force mode deletes files and reports results
- [ ] sessions-index.json is never touched
- [ ] Files modified within last hour are never deleted
- [ ] Original process cleanup (`/refresh`) still functions
- [ ] Confirmation prompt appears in default mode
- [ ] Memory usage statistics are accurate

## Artifacts & Outputs

- `.claude/scripts/claude-project-cleanup.sh` - New cleanup script
- `.claude/skills/skill-refresh/SKILL.md` - Extended with projects mode
- `.claude/commands/refresh.md` - Updated documentation
- `.claude/CLAUDE.md` - Updated quick commands table
- `specs/635_extend_refresh_command_claude_project_cleanup/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If implementation causes issues:
1. Revert the three modified/created files via git
2. Project cleanup functionality is additive - removing it does not affect existing process cleanup
3. If data loss occurs, sessions can be retrieved from backups (if available) or will regenerate on next Claude Code session

No database migrations or state changes are involved, so rollback is clean and immediate.
