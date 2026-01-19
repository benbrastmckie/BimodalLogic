# Implementation Plan: Task #614

- **Task**: 614 - refactor_cleanup_to_refresh_command
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/614_refactor_cleanup_to_refresh_command/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Refactor the /cleanup command to /refresh with a simplified two-mode interface. The current four-mode interface (--status, --dry-run, default, --force) will be consolidated into two modes: default mode shows status and prompts via AskUserQuestion, and --force mode immediately terminates orphaned processes. This also fixes a critical script bug where `set -euo pipefail` causes early exit due to bash arithmetic operators returning non-zero when incrementing from 0.

### Research Integration

Key findings from research-001.md:
- 5 files require renaming (command, skill directory, script, systemd files)
- 10 files contain references to "cleanup" that need updating
- Root cause of script bug: `((terminated++))` returns exit code 1 when terminated=0 due to bash arithmetic context
- AskUserQuestion tool available for interactive confirmation (pattern from meta-builder-agent)
- Shell aliases should be reduced from 4 to 2

## Goals & Non-Goals

**Goals**:
- Rename /cleanup command to /refresh across all files
- Simplify interface from 4 modes to 2 modes
- Fix bash arithmetic bug in shell script
- Update skill to use AskUserQuestion for interactive confirmation
- Update all documentation references
- Update shell aliases (4 to 2)
- Update systemd service and timer files

**Non-Goals**:
- Changing the underlying process detection/termination logic
- Adding new functionality beyond the interface simplification
- Modifying the systemd timer schedule
- Backward compatibility aliases for old command names

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Existing shell aliases break | Low | Medium | Document migration in CLAUDE.md |
| Systemd timer fails after rename | Low | Low | Test timer after rename |
| AskUserQuestion behavior differs from expectation | Medium | Low | Follow meta-builder-agent pattern exactly |
| Missing references after rename | Low | Medium | Use grep to find all occurrences before/after |
| Script bug fix introduces regression | Medium | Low | Test with multiple process counts (0, 1, many) |

## Implementation Phases

### Phase 1: Fix Script Bug [COMPLETED]

**Goal**: Fix the arithmetic operator bug that causes early exit when incrementing from 0

**Tasks**:
- [ ] Edit `.claude/scripts/claude-cleanup.sh` to replace `((terminated++))` with `terminated=$((terminated + 1))`
- [ ] Edit `.claude/scripts/claude-cleanup.sh` to replace `((failed++))` with `failed=$((failed + 1))`
- [ ] Apply same fix to any other arithmetic operators in the script

**Timing**: 15 minutes

**Files to modify**:
- `.claude/scripts/claude-cleanup.sh` - Replace arithmetic expansion operators

**Verification**:
- Script runs without early exit when terminating multiple processes
- Counter variables correctly track terminations and failures

---

### Phase 2: Rename Files [COMPLETED]

**Goal**: Rename all cleanup-related files to refresh

**Tasks**:
- [ ] Rename `.claude/commands/cleanup.md` to `.claude/commands/refresh.md`
- [ ] Rename `.claude/skills/skill-cleanup/` directory to `.claude/skills/skill-refresh/`
- [ ] Rename `.claude/scripts/claude-cleanup.sh` to `.claude/scripts/claude-refresh.sh`
- [ ] Rename `.claude/systemd/claude-cleanup.service` to `.claude/systemd/claude-refresh.service`
- [ ] Rename `.claude/systemd/claude-cleanup.timer` to `.claude/systemd/claude-refresh.timer`

**Timing**: 20 minutes

**Files to modify**:
- `.claude/commands/cleanup.md` -> `.claude/commands/refresh.md`
- `.claude/skills/skill-cleanup/SKILL.md` -> `.claude/skills/skill-refresh/SKILL.md`
- `.claude/scripts/claude-cleanup.sh` -> `.claude/scripts/claude-refresh.sh`
- `.claude/systemd/claude-cleanup.service` -> `.claude/systemd/claude-refresh.service`
- `.claude/systemd/claude-cleanup.timer` -> `.claude/systemd/claude-refresh.timer`

**Verification**:
- All files renamed successfully
- No orphaned cleanup-named files remain
- Git tracks file renames properly

---

### Phase 3: Update File Contents [COMPLETED]

**Goal**: Update internal references within renamed files

**Tasks**:
- [ ] Update `.claude/commands/refresh.md`: Change command name, description, remove --status and --dry-run flags
- [ ] Update `.claude/skills/skill-refresh/SKILL.md`: Change skill name, add AskUserQuestion to allowed-tools, implement two-mode logic
- [ ] Update `.claude/scripts/claude-refresh.sh`: Remove --status and --dry-run flags, default mode outputs status (skill handles confirmation)
- [ ] Update `.claude/systemd/claude-refresh.service`: Update Description, ExecStart path, SyslogIdentifier
- [ ] Update `.claude/systemd/claude-refresh.timer`: Update Description

**Timing**: 45 minutes

**Files to modify**:
- `.claude/commands/refresh.md` - Simplify to two modes
- `.claude/skills/skill-refresh/SKILL.md` - Add AskUserQuestion, implement confirmation logic
- `.claude/scripts/claude-refresh.sh` - Remove obsolete flags, keep --force
- `.claude/systemd/claude-refresh.service` - Update paths and identifiers
- `.claude/systemd/claude-refresh.timer` - Update description

**Verification**:
- Command recognizes /refresh and /refresh --force
- Skill uses AskUserQuestion for default mode
- Script outputs status in default mode, terminates with --force
- Systemd files reference correct paths

---

### Phase 4: Update Documentation References [COMPLETED]

**Goal**: Update all documentation files that reference cleanup

**Tasks**:
- [ ] Update `.claude/CLAUDE.md`: Change command references, skill name, alias examples
- [ ] Update `.claude/scripts/install-aliases.sh`: Reduce to 2 aliases (claude-refresh, claude-refresh-force)
- [ ] Update `.claude/scripts/install-systemd-timer.sh`: Update service/timer names and paths
- [ ] Update `.claude/docs/memory-leak-fix-plan.md`: Update script references
- [ ] Search for and update any other files referencing cleanup

**Timing**: 30 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - Update Session Maintenance section
- `.claude/scripts/install-aliases.sh` - Simplify aliases
- `.claude/scripts/install-systemd-timer.sh` - Update references
- `.claude/docs/memory-leak-fix-plan.md` - Update if exists
- Any other files found via grep

**Verification**:
- grep for "cleanup" returns no matches in .claude/ (except archive/history)
- All documentation references use "refresh" terminology
- Shell aliases install script works correctly

---

### Phase 5: Verification and Testing [IN PROGRESS]

**Goal**: Verify the refactored command works correctly in all modes

**Tasks**:
- [ ] Test `/refresh` - Should show status and prompt via AskUserQuestion
- [ ] Test `/refresh --force` - Should terminate orphaned processes immediately
- [ ] Test shell alias installation
- [ ] Verify systemd timer configuration is valid
- [ ] Run grep to confirm no stray cleanup references

**Timing**: 30 minutes

**Files to modify**:
- None (testing only)

**Verification**:
- Both command modes work as expected
- AskUserQuestion prompts correctly
- Shell aliases function properly
- `grep -r "cleanup" .claude/ --include="*.md" --include="*.sh"` returns no unexpected matches

---

## Testing & Validation

- [ ] `/refresh` displays status and prompts for confirmation
- [ ] `/refresh --force` terminates processes without prompting
- [ ] Script handles 0, 1, and multiple orphaned processes without early exit
- [ ] Shell aliases install and work correctly
- [ ] Systemd files have valid syntax (`systemd-analyze verify`)
- [ ] No cleanup references remain in documentation

## Artifacts & Outputs

- `.claude/commands/refresh.md` - Refactored command file
- `.claude/skills/skill-refresh/SKILL.md` - Updated skill with AskUserQuestion
- `.claude/scripts/claude-refresh.sh` - Fixed and simplified script
- `.claude/systemd/claude-refresh.service` - Renamed service file
- `.claude/systemd/claude-refresh.timer` - Renamed timer file
- `.claude/CLAUDE.md` - Updated documentation
- `.claude/scripts/install-aliases.sh` - Simplified aliases
- `.claude/scripts/install-systemd-timer.sh` - Updated paths

## Rollback/Contingency

If implementation fails or introduces critical bugs:
1. Use `git checkout` to restore original cleanup files
2. Re-run `/cleanup --status` to verify functionality
3. Investigate specific failure before re-attempting

Files can be recovered via git history since all originals are committed.
