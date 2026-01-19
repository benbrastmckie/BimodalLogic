# Implementation Plan: Task #585

- **Task**: 585 - Add session cleanup to agents
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/585_add_session_cleanup_to_agents/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .claude/context/core/formats/plan-format.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Implement a `/cleanup` command and supporting infrastructure to identify and safely terminate orphaned Claude Code processes, reducing memory footprint. Research revealed that the original task description (agent-level cleanup stages) is not feasible since agents cannot manage their own process lifecycle. Instead, this plan implements system-level cleanup via a skill/command that interfaces with OS process management.

### Research Integration

Key findings from research-001.md:
- 25 orphaned Claude processes consuming ~10.7 GB memory identified
- Agent-level cleanup NOT possible (agents run inside Claude's runtime)
- Recommended approach: System-level cleanup via settings.json, shell aliases, and systemd timer
- Process identification: `ps aux | grep '[c]laude' | awk '$7 == "??"'` detects orphaned processes

## Goals & Non-Goals

**Goals**:
- Create `/cleanup` command to identify and terminate orphaned Claude processes
- Add shell aliases for quick memory monitoring (`claude-memory`, `claude-cleanup`)
- Configure Claude Code settings for automatic session cleanup
- Document cleanup procedures in project CLAUDE.md

**Non-Goals**:
- Modifying agent files to add cleanup stages (research proved this infeasible)
- Creating cross-platform cleanup (focus on Linux/systemd)
- Implementing real-time memory monitoring daemon
- Automatic process cleanup without user confirmation

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Kill active Claude processes by mistake | High | Low | Only target processes with `??` TTY (no terminal) |
| User runs cleanup during active session | Medium | Medium | Add confirmation prompt and exclude current PID |
| systemd timer permissions | Low | Low | Use user-level systemd (no root needed) |
| settings.json overwrites user config | Medium | Medium | Merge with existing settings, not overwrite |

## Implementation Phases

### Phase 1: Create cleanup skill infrastructure [NOT STARTED]

**Goal**: Create the skill file and basic structure for `/cleanup` command

**Tasks**:
- [ ] Create `.claude/skills/skill-cleanup.md` with command definition
- [ ] Define command syntax: `/cleanup [--dry-run] [--force] [--status]`
- [ ] Add skill to CLAUDE.md skill registry

**Timing**: 45 minutes

**Files to modify**:
- `.claude/skills/skill-cleanup.md` - Create new skill file
- `.claude/CLAUDE.md` - Add skill reference

**Verification**:
- Skill file exists and follows skill format
- `/cleanup` command recognized by Claude Code

---

### Phase 2: Implement process detection and cleanup logic [NOT STARTED]

**Goal**: Implement the core cleanup functionality that identifies and terminates orphaned processes

**Tasks**:
- [ ] Create cleanup script at `.claude/scripts/claude-cleanup.sh`
- [ ] Implement orphaned process detection (TTY == "??")
- [ ] Add dry-run mode to preview without killing
- [ ] Add force mode to skip confirmation
- [ ] Add status mode to show current memory usage
- [ ] Exclude current process and its parent from cleanup targets

**Timing**: 1 hour

**Files to modify**:
- `.claude/scripts/claude-cleanup.sh` - Create cleanup script

**Verification**:
- `./claude-cleanup.sh --status` shows memory usage
- `./claude-cleanup.sh --dry-run` lists orphaned processes without killing
- `./claude-cleanup.sh` prompts for confirmation before cleanup

---

### Phase 3: Add shell aliases and settings configuration [NOT STARTED]

**Goal**: Create convenience aliases and update Claude Code settings

**Tasks**:
- [ ] Create alias installation script at `.claude/scripts/install-aliases.sh`
- [ ] Define aliases: `claude-memory`, `claude-cleanup`, `claude-orphans`
- [ ] Create settings.json template with recommended cleanupPeriodDays
- [ ] Add installation instructions to skill documentation

**Timing**: 30 minutes

**Files to modify**:
- `.claude/scripts/install-aliases.sh` - Create alias installer
- `.claude/templates/settings.json` - Create settings template

**Verification**:
- Running install script adds aliases to shell config
- Settings template includes cleanupPeriodDays = 7

---

### Phase 4: Create systemd timer for automated cleanup [NOT STARTED]

**Goal**: Set up optional automated cleanup via systemd user timer

**Tasks**:
- [ ] Create service file at `.claude/systemd/claude-cleanup.service`
- [ ] Create timer file at `.claude/systemd/claude-cleanup.timer`
- [ ] Create installation script for systemd setup
- [ ] Document enable/disable procedure

**Timing**: 30 minutes

**Files to modify**:
- `.claude/systemd/claude-cleanup.service` - Create systemd service
- `.claude/systemd/claude-cleanup.timer` - Create systemd timer
- `.claude/scripts/install-systemd-timer.sh` - Create timer installer

**Verification**:
- `systemctl --user list-timers` shows claude-cleanup.timer after install
- Timer triggers cleanup hourly when enabled

---

### Phase 5: Documentation and integration [NOT STARTED]

**Goal**: Document the cleanup system and integrate with project workflows

**Tasks**:
- [ ] Add "Session Maintenance" section to project CLAUDE.md
- [ ] Document `/cleanup` command in skill file
- [ ] Create troubleshooting guide for memory issues
- [ ] Add cleanup recommendations to agent documentation

**Timing**: 15 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - Add Session Maintenance section
- `.claude/skills/skill-cleanup.md` - Complete documentation

**Verification**:
- CLAUDE.md contains Session Maintenance section
- Skill file has complete usage documentation

## Testing & Validation

- [ ] `/cleanup --status` correctly reports memory usage
- [ ] `/cleanup --dry-run` identifies orphaned processes without killing
- [ ] `/cleanup` with active processes excludes current session
- [ ] Shell aliases work after installation
- [ ] systemd timer activates on schedule
- [ ] settings.json merge preserves existing user settings

## Artifacts & Outputs

- `.claude/skills/skill-cleanup.md` - Cleanup command skill
- `.claude/scripts/claude-cleanup.sh` - Core cleanup script
- `.claude/scripts/install-aliases.sh` - Alias installer
- `.claude/scripts/install-systemd-timer.sh` - Timer installer
- `.claude/systemd/claude-cleanup.service` - systemd service
- `.claude/systemd/claude-cleanup.timer` - systemd timer
- `.claude/templates/settings.json` - Settings template
- Updated `.claude/CLAUDE.md` - Session Maintenance documentation

## Rollback/Contingency

If cleanup causes issues:
1. Disable systemd timer: `systemctl --user disable claude-cleanup.timer`
2. Remove aliases from shell config
3. Revert settings.json to previous state
4. The cleanup script only affects orphaned processes; active sessions remain unaffected

All changes are additive and do not modify core system behavior. Removal is straightforward by deleting created files.
