# Implementation Plan: Improve /refresh Command for ~/.claude/ Directory Cleanup

- **Task**: 640 - improve_refresh_command_for_claude_directory_cleanup
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/640_improve_refresh_command_for_claude_directory_cleanup/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

The ~/.claude/ directory has grown to 7.3GB (97% in projects/), causing slow startup times. The current /refresh command only cleans the current project directory and misses other cleanable directories (debug/, file-history/, todos/, session-env/, telemetry/, shell-snapshots/, plugins/cache/). This plan adds a `--global` mode to clean the entire ~/.claude/ directory with tiered age options: aggressive (8 hours), conservative (2 days), and clean slate (everything except safety margin).

### Research Integration

- Integrated findings from research-001.md identifying directory sizes, safety constraints, and community best practices
- Key insight: projects/ is 97% of usage; other directories add 200MB+ combined
- Safety requirements: preserve sessions-index.json, settings.json, .credentials.json, files modified within 1 hour

## Goals & Non-Goals

**Goals**:
- Add `--global` mode to clean entire ~/.claude/ directory
- Implement tiered age presets: `--aggressive` (8h), `--conservative` (2d), default (8h)
- Clean additional directories: debug/, file-history/, todos/, session-env/, telemetry/, shell-snapshots/, plugins/cache/
- Maintain backward compatibility with existing /refresh behavior
- Update all related documentation

**Non-Goals**:
- Cleaning history.jsonl (user command history - preserve)
- Modifying the process cleanup functionality
- Adding a GUI or interactive selection mode
- Automatic scheduled global cleanup (systemd timer remains project-scoped)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Accidental deletion of active sessions | High | Medium | Preserve files modified within 1 hour; dry-run default behavior |
| Breaking Claude Code functionality | High | Low | Never delete system files (sessions-index.json, settings.json, .credentials.json) |
| Inconsistent state after partial cleanup | Medium | Low | Process directories atomically; clear error reporting |
| User confusion with new options | Low | Medium | Clear documentation; sensible defaults; verbose output |
| Deleting data user wants to keep | Medium | Medium | Require --force for destructive operations; confirmation prompts |

## Implementation Phases

### Phase 1: Create Global Cleanup Script [NOT STARTED]

**Goal**: Create a new script `claude-global-cleanup.sh` that handles comprehensive ~/.claude/ cleanup

**Tasks**:
- [ ] Create `.claude/scripts/claude-global-cleanup.sh` with argument parsing
- [ ] Implement directory scanning for all cleanable directories
- [ ] Add age threshold logic with hours (not days) for finer control
- [ ] Add preset shortcuts: `--aggressive` (8h), `--conservative` (48h), `--all` (0h with 1h safety)
- [ ] Implement safety measures: never delete system files, preserve files <1 hour old
- [ ] Add `--dry-run` mode showing what would be deleted
- [ ] Add verbose output with before/after sizes
- [ ] Test script directly from command line

**Timing**: 1.5 hours

**Files to create**:
- `.claude/scripts/claude-global-cleanup.sh` - Main global cleanup script

**Verification**:
- Script runs without errors in `--dry-run` mode
- Script correctly identifies cleanable files across all target directories
- Safety files are never included in cleanup candidates
- Recent files (<1 hour) are excluded

---

### Phase 2: Update Skill for Global Mode [NOT STARTED]

**Goal**: Extend skill-refresh to handle the new `--global` mode and route to the global cleanup script

**Tasks**:
- [ ] Add `--global` mode detection in SKILL.md
- [ ] Add preset detection: `--aggressive`, `--conservative`, `--all`
- [ ] Route `--global` to new global cleanup script
- [ ] Preserve existing project cleanup behavior without `--global`
- [ ] Update return format documentation for global cleanup results
- [ ] Add confirmation flow via AskUserQuestion for non-force mode

**Timing**: 0.75 hours

**Files to modify**:
- `.claude/skills/skill-refresh/SKILL.md` - Add global mode handling

**Verification**:
- `/refresh` (no flags) still works for process cleanup
- `/refresh --projects` still works for current project cleanup
- `/refresh --global` triggers global cleanup mode
- `/refresh --global --dry-run` shows preview without changes
- `/refresh --global --force` executes immediately

---

### Phase 3: Update Command Documentation [NOT STARTED]

**Goal**: Update the /refresh command documentation with new global mode options

**Tasks**:
- [ ] Add `--global` mode section to `.claude/commands/refresh.md`
- [ ] Document preset options (--aggressive, --conservative, --all)
- [ ] Add examples for common use cases
- [ ] Update safety documentation

**Timing**: 0.5 hours

**Files to modify**:
- `.claude/commands/refresh.md` - Add global mode documentation

**Verification**:
- Documentation is clear and complete
- Examples cover all common use cases
- Safety information is prominent

---

### Phase 4: Update CLAUDE.md and Related Documentation [NOT STARTED]

**Goal**: Update project-level documentation to reflect new /refresh capabilities

**Tasks**:
- [ ] Update Session Maintenance section in CLAUDE.md
- [ ] Update quick commands table with global cleanup options
- [ ] Update shell aliases installation script with global cleanup alias
- [ ] Review and update any other files referencing /refresh

**Timing**: 0.5 hours

**Files to modify**:
- `.claude/CLAUDE.md` - Update Session Maintenance section
- `.claude/scripts/install-aliases.sh` - Add `claude-cleanup` alias (if exists)

**Verification**:
- CLAUDE.md accurately describes all /refresh capabilities
- Quick commands table is comprehensive
- Shell aliases include global cleanup option

---

### Phase 5: Testing and Verification [NOT STARTED]

**Goal**: Comprehensive testing of all new functionality

**Tasks**:
- [ ] Test global cleanup dry-run on actual ~/.claude/ directory
- [ ] Verify no system files are touched
- [ ] Verify age thresholds work correctly for all presets
- [ ] Test force mode with small age threshold
- [ ] Verify backward compatibility: existing /refresh commands unchanged
- [ ] Test error handling for missing directories
- [ ] Document actual space savings achieved

**Timing**: 0.75 hours

**Verification**:
- All test cases pass
- No regressions in existing functionality
- Actual cleanup achieves expected space savings
- Error handling works as expected

## Testing & Validation

- [ ] `/refresh` (process cleanup) works unchanged
- [ ] `/refresh --force` (process cleanup) works unchanged
- [ ] `/refresh --projects` (project cleanup) works unchanged
- [ ] `/refresh --global` shows survey and prompts for confirmation
- [ ] `/refresh --global --dry-run` previews cleanup without changes
- [ ] `/refresh --global --force` executes cleanup immediately
- [ ] `/refresh --global --aggressive` uses 8-hour threshold
- [ ] `/refresh --global --conservative` uses 48-hour threshold
- [ ] `/refresh --global --all` cleans everything except safety margin
- [ ] `/refresh --global --age 24` uses custom 24-hour threshold
- [ ] System files (sessions-index.json, settings.json, .credentials.json) are never deleted
- [ ] Files modified within last hour are never deleted
- [ ] Output shows before/after sizes and space reclaimed

## Artifacts & Outputs

- `.claude/scripts/claude-global-cleanup.sh` - New global cleanup script
- `.claude/skills/skill-refresh/SKILL.md` - Updated skill with global mode
- `.claude/commands/refresh.md` - Updated command documentation
- `.claude/CLAUDE.md` - Updated project documentation
- `specs/640_improve_refresh_command_for_claude_directory_cleanup/summaries/implementation-summary-YYYYMMDD.md` - Final summary

## Rollback/Contingency

If implementation causes issues:
1. The new `--global` mode is additive; existing functionality remains unchanged
2. Remove `claude-global-cleanup.sh` to disable global cleanup
3. Revert SKILL.md changes to restore original routing
4. Command documentation changes are non-breaking

If accidental data loss occurs:
1. Claude Code sessions can be regenerated (though history is lost)
2. Settings and credentials in ~/.claude/ root are never touched
3. Consider adding backup functionality in future iteration
