# Implementation Plan: Port Lean Version Management Command

- **Task**: 940 - port_lean_version_management_command
- **Status**: [NOT STARTED]
- **Effort**: 4.5 hours
- **Dependencies**: /lake command (existing)
- **Research Inputs**: specs/940_port_lean_version_management_command/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Port the /lean command for Lean toolchain and Mathlib version management to the ProofChecker project's agent system. The command provides four modes: check (status display), upgrade (interactive with AskUserQuestion), rollback (revert to backup), and dry-run (preview changes). This complements the existing /lake command (build management) with version management capabilities.

### Research Integration

Integrated findings from research-001.md:
- Elan manages toolchain via `lean-toolchain` file; Mathlib pinned in `lakefile.lean`
- Standard update procedure: `lake update` + `lake exe cache get`
- AskUserQuestion pattern from `/refresh` skill for interactive upgrade confirmation
- Git-based backup with `.lean-version-backup/` safety net
- Direct execution skill pattern (no subagent needed)

## Goals & Non-Goals

**Goals**:
- Provide unified command for Lean toolchain and Mathlib version management
- Enable interactive upgrades with user confirmation
- Support rollback to previous versions
- Integrate Mathlib cache management post-upgrade
- Preview changes before applying via dry-run mode

**Non-Goals**:
- Custom toolchain compilation (rely on elan's prebuilt toolchains)
- Management of multiple simultaneous Lean projects
- Automatic version selection without user confirmation

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Network failure during upgrade | Medium | Medium | Backup exists before upgrade; retry or rollback available |
| Incompatible Mathlib version | High | Low | Dry-run mode shows changes; version compatibility check |
| Build fails after upgrade | Medium | Medium | Clear rollback path; build verification step |
| Cache corruption | Medium | Low | `lake exe cache get!` force overwrite command |
| Concurrent lake operations | Low | Low | Warn if `.lake` lock exists |

## Implementation Phases

### Phase 1: Core Infrastructure [NOT STARTED]

- **Dependencies:** None
- **Goal:** Create command file and skill skeleton with argument parsing

**Tasks:**
- [ ] Create `.claude/commands/lean.md` with command documentation and syntax
- [ ] Create `.claude/skills/skill-lean-version/SKILL.md` skeleton
- [ ] Implement argument parsing for modes (check, upgrade, rollback, dry-run)
- [ ] Add flag parsing (--dry-run, --version)

**Timing:** 45 minutes

**Files to create/modify:**
- `.claude/commands/lean.md` - Command entry point
- `.claude/skills/skill-lean-version/SKILL.md` - Direct execution skill

**Verification:**
- Command file follows lake.md pattern
- Skill file follows skill-lake-repair pattern
- Arguments and flags documented

---

### Phase 2: Check Mode [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Implement status display showing current versions and available updates

**Tasks:**
- [ ] Read current toolchain from `lean-toolchain` file
- [ ] Read Mathlib version from `lakefile.lean`
- [ ] Run `elan show` to list installed toolchains
- [ ] Query latest Mathlib release (optional, network-dependent)
- [ ] Format and display status report

**Timing:** 45 minutes

**Files to modify:**
- `.claude/skills/skill-lean-version/SKILL.md` - Add check mode implementation

**Verification:**
- `/lean` or `/lean check` displays current versions
- Lists installed toolchains
- Shows comparison with latest if network available

---

### Phase 3: Upgrade Mode with AskUserQuestion [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Implement interactive upgrade with user confirmation and backup

**Tasks:**
- [ ] Implement backup creation to `.lean-version-backup/` with timestamps
- [ ] Implement AskUserQuestion prompt for upgrade confirmation
- [ ] Update `lean-toolchain` file with new version
- [ ] Update `lakefile.lean` Mathlib pin
- [ ] Run `lake update` after version changes
- [ ] Run `lake exe cache get` to download prebuilt oleans
- [ ] Implement backup cleanup (keep last 3)
- [ ] Report success/failure with next steps

**Timing:** 1.5 hours

**Files to modify:**
- `.claude/skills/skill-lean-version/SKILL.md` - Add upgrade mode implementation

**Verification:**
- `/lean upgrade` prompts user for confirmation
- Backup created before modifications
- Files updated correctly
- Cache download triggered
- Success message with next steps

---

### Phase 4: Rollback Mode [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Implement version rollback from backup

**Tasks:**
- [ ] List available backups in `.lean-version-backup/`
- [ ] Implement AskUserQuestion for backup selection
- [ ] Restore selected backup files (`lean-toolchain`, `lakefile.lean`, `lake-manifest.json`)
- [ ] Run `lake update` after restore
- [ ] Run `lake exe cache get` to sync cache
- [ ] Report rollback completion

**Timing:** 45 minutes

**Files to modify:**
- `.claude/skills/skill-lean-version/SKILL.md` - Add rollback mode implementation

**Verification:**
- `/lean rollback` lists available backups
- User can select which backup to restore
- Files restored correctly
- Cache sync triggered

---

### Phase 5: Dry-Run Mode [NOT STARTED]

- **Dependencies:** Phase 2, Phase 3
- **Goal:** Implement preview of upgrade changes without applying

**Tasks:**
- [ ] Detect --dry-run flag in upgrade mode
- [ ] Show current vs. target version comparison
- [ ] List files that would be modified
- [ ] Show commands that would be executed
- [ ] Display "No changes made" confirmation

**Timing:** 30 minutes

**Files to modify:**
- `.claude/skills/skill-lean-version/SKILL.md` - Add dry-run support to upgrade mode

**Verification:**
- `/lean --dry-run upgrade` shows preview
- No files modified
- Clear indication of dry-run mode

---

### Phase 6: Testing and Documentation [NOT STARTED]

- **Dependencies:** Phase 4, Phase 5
- **Goal:** Verify all modes work correctly and document usage

**Tasks:**
- [ ] Test check mode on current project
- [ ] Test dry-run upgrade mode
- [ ] Test upgrade on expendable branch
- [ ] Test rollback from backup
- [ ] Verify command documentation is complete
- [ ] Update CLAUDE.md if needed to reference /lean command

**Timing:** 30 minutes

**Files to modify:**
- `.claude/CLAUDE.md` - Add /lean to command list if not auto-discovered

**Verification:**
- All modes execute without errors
- Help text is clear and accurate
- Error messages are informative
- Edge cases handled gracefully

## Testing & Validation

- [ ] `/lean` displays current version status
- [ ] `/lean check` shows installed toolchains
- [ ] `/lean --dry-run upgrade` previews changes without applying
- [ ] `/lean upgrade` prompts for confirmation before modifying files
- [ ] Backup files created in `.lean-version-backup/` before upgrade
- [ ] `/lean rollback` restores previous version
- [ ] `lake exe cache get` runs after upgrade/rollback
- [ ] Error handling for network failures and missing files

## Artifacts & Outputs

- `.claude/commands/lean.md` - Command entry point with syntax and examples
- `.claude/skills/skill-lean-version/SKILL.md` - Direct execution skill with all modes
- plans/implementation-001.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (upon completion)

## Rollback/Contingency

If implementation fails or introduces regressions:
1. Delete `.claude/commands/lean.md` and `.claude/skills/skill-lean-version/` directory
2. Existing `/lake` command remains unaffected
3. Manual toolchain management still available via `elan` CLI
4. Git provides full undo capability for all changes
