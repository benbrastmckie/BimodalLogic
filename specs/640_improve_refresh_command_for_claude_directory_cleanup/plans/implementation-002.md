# Implementation Plan: Improve /refresh Command for ~/.claude/ Directory Cleanup

- **Task**: 640 - improve_refresh_command_for_claude_directory_cleanup
- **Version**: 002 (revised from 001)
- **Status**: [IMPLEMENTING]
- **Effort**: 3.5 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/640_improve_refresh_command_for_claude_directory_cleanup/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Revision Notes

**Changes from v001**:
1. **No --global flag**: /refresh now does comprehensive cleanup by default (no special flag needed)
2. **No --aggressive/--conservative presets**: Removed these named presets
3. **Interactive age selection**: When run without --force, present user with three choices:
   - 8 hours (default)
   - 2 days
   - Clean slate (everything except safety margin)
4. **Simplified UX**: Single command `/refresh` handles both process cleanup AND directory cleanup

## Overview

The ~/.claude/ directory has grown to 7.3GB (97% in projects/), causing slow startup times. This plan modifies /refresh to perform comprehensive cleanup of the entire ~/.claude/ directory by default. When run interactively, it presents the user with age threshold options: 8 hours (default), 2 days, or clean slate.

### Research Integration

- Integrated findings from research-001.md identifying directory sizes, safety constraints, and community best practices
- Key insight: projects/ is 97% of usage; other directories add 200MB+ combined
- Safety requirements: preserve sessions-index.json, settings.json, .credentials.json, files modified within 1 hour

## Goals & Non-Goals

**Goals**:
- Make /refresh clean the entire ~/.claude/ directory by default
- Present interactive age selection: 8 hours (default), 2 days, or clean slate
- Clean all cleanable directories: projects/, debug/, file-history/, todos/, session-env/, telemetry/, shell-snapshots/, plugins/cache/
- Preserve existing process cleanup functionality (runs first)
- Support --force and --dry-run flags for automation
- Update all related documentation

**Non-Goals**:
- Multiple named presets (--aggressive, --conservative, etc.)
- Separate --global flag
- Cleaning history.jsonl (user command history - preserve)
- GUI or complex interactive selection
- Automatic scheduled cleanup changes

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Accidental deletion of active sessions | High | Medium | Preserve files modified within 1 hour; dry-run preview |
| Breaking Claude Code functionality | High | Low | Never delete system files (sessions-index.json, settings.json, .credentials.json) |
| Inconsistent state after partial cleanup | Medium | Low | Process directories atomically; clear error reporting |
| User confusion with changed behavior | Medium | Medium | Clear documentation; interactive prompts explain options |

## Implementation Phases

### Phase 1: Create Comprehensive Cleanup Script [IN PROGRESS]

**Goal**: Create a new script `claude-cleanup.sh` that handles comprehensive ~/.claude/ cleanup with age threshold parameter

**Tasks**:
- [ ] Create `.claude/scripts/claude-cleanup.sh` with argument parsing
- [ ] Accept `--age HOURS` parameter (default 8, or 0 for clean slate with safety margin)
- [ ] Implement directory scanning for all cleanable directories:
  - `~/.claude/projects/` - all project session files
  - `~/.claude/debug/` - debug output files
  - `~/.claude/file-history/` - file version snapshots
  - `~/.claude/todos/` - todo backups
  - `~/.claude/session-env/` - environment snapshots
  - `~/.claude/telemetry/` - telemetry data
  - `~/.claude/shell-snapshots/` - shell state
  - `~/.claude/plugins/cache/` - old plugin versions
  - `~/.claude/cache/` - general cache
- [ ] Implement safety measures:
  - Never delete: sessions-index.json, settings.json, .credentials.json
  - Never delete files modified within last hour (safety margin)
- [ ] Add `--dry-run` mode showing what would be deleted
- [ ] Add verbose output with before/after sizes per directory
- [ ] Return structured output: files_deleted, bytes_freed, directories_cleaned

**Timing**: 1.5 hours

**Files to create**:
- `.claude/scripts/claude-cleanup.sh` - Main comprehensive cleanup script

**Verification**:
- Script runs without errors in `--dry-run` mode
- Script correctly identifies cleanable files across all target directories
- Safety files are never included in cleanup candidates
- Recent files (<1 hour) are excluded
- Age threshold works correctly for all three values (8, 48, 0)

---

### Phase 2: Update Skill for Unified Cleanup [NOT STARTED]

**Goal**: Modify skill-refresh to integrate directory cleanup with process cleanup and present interactive age selection

**Tasks**:
- [ ] Update SKILL.md execution flow:
  1. First, run existing process cleanup (orphaned Claude processes)
  2. Then, run directory cleanup via new script
- [ ] Add interactive age selection when not using --force:
  ```
  Select cleanup age threshold:
  1. 8 hours (default) - Remove files older than 8 hours
  2. 2 days - Remove files older than 2 days
  3. Clean slate - Remove everything (except safety margin)
  ```
- [ ] Map selection to --age parameter: 8, 48, or 0
- [ ] Preserve --dry-run flag (shows preview for both process and directory cleanup)
- [ ] Preserve --force flag (skips confirmation, uses 8-hour default)
- [ ] Update output format to show both process and directory cleanup results

**Timing**: 1 hour

**Files to modify**:
- `.claude/skills/skill-refresh/SKILL.md` - Unified cleanup flow

**Verification**:
- `/refresh` shows process cleanup + prompts for age selection
- `/refresh --dry-run` previews both cleanup types without changes
- `/refresh --force` runs process cleanup + 8-hour directory cleanup immediately
- All three age options work correctly when selected

---

### Phase 3: Update Command Documentation [NOT STARTED]

**Goal**: Update the /refresh command documentation with new unified cleanup behavior

**Tasks**:
- [ ] Rewrite `.claude/commands/refresh.md` for new behavior:
  - Default behavior: process cleanup + interactive directory cleanup
  - --dry-run: preview mode
  - --force: immediate execution with 8-hour default
- [ ] Document the three age options clearly
- [ ] Add examples for common use cases
- [ ] Update safety documentation
- [ ] Remove references to --projects flag (now default behavior)

**Timing**: 0.5 hours

**Files to modify**:
- `.claude/commands/refresh.md` - Rewrite for unified cleanup

**Verification**:
- Documentation accurately reflects new behavior
- Examples are clear and practical
- Safety information is prominent

---

### Phase 4: Update CLAUDE.md and Related Documentation [NOT STARTED]

**Goal**: Update project-level documentation to reflect new /refresh behavior

**Tasks**:
- [ ] Update Session Maintenance section in CLAUDE.md:
  - Remove --projects flag references
  - Document new interactive age selection
  - Update quick commands table
- [ ] Update shell aliases if needed
- [ ] Review and update any other files referencing old /refresh behavior

**Timing**: 0.5 hours

**Files to modify**:
- `.claude/CLAUDE.md` - Update Session Maintenance section
- `.claude/scripts/install-aliases.sh` - Update if needed

**Verification**:
- CLAUDE.md accurately describes new /refresh behavior
- Quick commands table reflects simplified options
- No stale references to --projects or --global

---

### Phase 5: Testing and Verification [NOT STARTED]

**Goal**: Comprehensive testing of all new functionality

**Tasks**:
- [ ] Test full cleanup flow with each age option (8h, 48h, clean slate)
- [ ] Test --dry-run mode shows accurate preview
- [ ] Test --force mode uses 8-hour default
- [ ] Verify safety files are never touched
- [ ] Verify files <1 hour old are preserved
- [ ] Test error handling for missing directories
- [ ] Document actual space savings achieved
- [ ] Verify process cleanup still works correctly

**Timing**: 0.5 hours

**Verification**:
- All three age options produce expected results
- Safety measures work correctly
- No regressions in process cleanup
- Output is clear and informative

## Testing & Validation

- [ ] `/refresh` runs process cleanup, then prompts for age selection
- [ ] `/refresh --dry-run` previews without making changes
- [ ] `/refresh --force` runs immediately with 8-hour default
- [ ] Age option "8 hours" cleans files older than 8 hours
- [ ] Age option "2 days" cleans files older than 48 hours
- [ ] Age option "Clean slate" cleans everything (except safety margin)
- [ ] System files (sessions-index.json, settings.json, .credentials.json) are never deleted
- [ ] Files modified within last hour are never deleted
- [ ] Output shows before/after sizes and space reclaimed
- [ ] All target directories are cleaned: projects/, debug/, file-history/, todos/, session-env/, telemetry/, shell-snapshots/, plugins/cache/, cache/

## Artifacts & Outputs

- `.claude/scripts/claude-cleanup.sh` - New comprehensive cleanup script
- `.claude/skills/skill-refresh/SKILL.md` - Updated skill with unified cleanup
- `.claude/commands/refresh.md` - Updated command documentation
- `.claude/CLAUDE.md` - Updated project documentation
- `specs/640_improve_refresh_command_for_claude_directory_cleanup/summaries/implementation-summary-YYYYMMDD.md` - Final summary

## Rollback/Contingency

If implementation causes issues:
1. The cleanup script is a new file - simply remove it
2. Revert SKILL.md changes to restore original behavior
3. Documentation changes are non-breaking

If accidental data loss occurs:
1. Claude Code sessions can be regenerated (though conversation history is lost)
2. Settings and credentials in ~/.claude/ root are never touched
3. Consider adding backup functionality in future iteration
