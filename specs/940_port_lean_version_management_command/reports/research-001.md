# Research Report: Port Lean Version Management Command

- **Task**: 940 - Port Lean Version Management Command
- **Started**: 2026-02-26T12:00:00Z
- **Completed**: 2026-02-26T12:30:00Z
- **Effort**: 30 minutes
- **Dependencies**: /lake command (existing)
- **Sources/Inputs**:
  - Codebase: `.claude/commands/lake.md`, `.claude/skills/skill-lake-repair/SKILL.md`
  - Codebase: `.claude/skills/skill-meta/SKILL.md`, `.claude/commands/meta.md`
  - Codebase: `.claude/skills/skill-refresh/SKILL.md`
  - Codebase: `lean-toolchain`, `lakefile.lean`, `lake-manifest.json`
  - External: [elan GitHub README](https://github.com/leanprover/elan)
  - External: [Lean documentation - Managing Toolchains with Elan](https://lean-lang.org/doc/reference/latest/Build-Tools-and-Distribution/Managing-Toolchains-with-Elan/)
  - External: [Mathlib4 wiki - Using as dependency](https://github.com/leanprover-community/mathlib4/wiki/Using-mathlib4-as-a-dependency)
- **Artifacts**: This report
- **Standards**: report-format.md

## Executive Summary

- The /lean command should provide 4 modes: `check` (status), `upgrade` (interactive), `rollback` (revert), and `dry-run` (preview)
- Elan manages toolchain versions via `lean-toolchain` file; Mathlib version is pinned in `lakefile.lean`
- Backup strategy: git-based (existing files are versioned); create `.lean-version-backup/` for emergency recovery
- AskUserQuestion pattern from `/refresh` skill provides interactive upgrade confirmation model
- Direct skill execution (no subagent) is appropriate given straightforward workflow
- Mathlib cache management (`lake exe cache get`) must be integrated post-upgrade

## Context & Scope

This research supports porting a Lean version management command to the ProofChecker project's agent system. The command will complement the existing `/lake` command (build management) with version and toolchain management capabilities.

**Current Project State**:
- Lean toolchain: `leanprover/lean4:v4.27.0-rc1` (from `lean-toolchain`)
- Mathlib version: `v4.27.0-rc1` (from `lakefile.lean`)
- Installed elan version: 4.1.2
- Three toolchains installed: v4.14.0, v4.22.0, v4.27.0-rc1

## Findings

### 1. Toolchain Management (Elan)

**Key Files**:
- `lean-toolchain`: Single-line file specifying active toolchain (e.g., `leanprover/lean4:v4.27.0-rc1`)
- Toolchain format: `[origin:]channel[-date]` where channel can be `stable`, `beta`, `nightly`, or version number

**Elan Commands Relevant to /lean**:
| Command | Purpose |
|---------|---------|
| `elan show` | Display active toolchain and list all installed |
| `elan toolchain list` | List installed toolchains |
| `elan toolchain install <version>` | Install specific toolchain |
| `elan toolchain uninstall <version>` | Remove toolchain |
| `elan toolchain gc --delete` | Garbage collect unused toolchains |
| `elan default <version>` | Set default toolchain |

**Automatic Version Selection**: Elan reads `lean-toolchain` file and automatically downloads/uses the specified version. No manual installation typically needed for project work.

### 2. Mathlib Version Management (Lake)

**Key Files**:
- `lakefile.lean`: Contains Mathlib dependency with version pin
  ```lean
  require mathlib from git
    "https://github.com/leanprover-community/mathlib4.git" @ "v4.27.0-rc1"
  ```
- `lake-manifest.json`: Lock file with resolved dependency hashes

**Update Procedure** (from Mathlib wiki):
1. Update toolchain: `curl https://raw.githubusercontent.com/leanprover-community/mathlib4/master/lean-toolchain -o lean-toolchain`
2. Update lakefile mathlib pin (if desired)
3. Run `lake update` - triggers hook that executes `lake exe cache get`
4. Verify with `lake build`

**Cache Commands**:
| Command | Purpose |
|---------|---------|
| `lake exe cache get` | Download prebuilt oleans |
| `lake exe cache get!` | Force overwrite corrupted cache |
| `lake clean` | Clear local build artifacts |

### 3. Existing Skill Patterns

**AskUserQuestion Usage** (from `/refresh`):
```json
{
  "question": "Select cleanup age threshold:",
  "header": "Age Threshold",
  "multiSelect": false,
  "options": [
    {"label": "8 hours (default)", "description": "..."},
    {"label": "2 days", "description": "..."},
    {"label": "Clean slate", "description": "..."}
  ]
}
```

This pattern is ideal for interactive upgrade confirmation:
- Present current vs. available versions
- Let user select upgrade path (latest stable, specific version, skip)
- Confirm before modifying files

**Multi-Mode Pattern** (from `/meta`, `/lake`):
- Mode detection via argument parsing
- `--dry-run` flag for preview without changes
- Clear mode routing in execution steps

**Direct Execution vs. Subagent**:
- `/lake` uses direct execution (no subagent) for build operations
- `/refresh` uses direct execution with AskUserQuestion
- /lean should follow same pattern - operations are straightforward enough not to require subagent delegation

### 4. Backup and Recovery Patterns

**Git-Based Backup** (preferred):
- `lean-toolchain` and `lakefile.lean` are already tracked in git
- Rollback via `git checkout` is natural
- No separate backup directory needed for normal operations

**Emergency Backup** (for safety):
- Create `.lean-version-backup/` with timestamped copies before upgrade
- Contents: `lean-toolchain.{timestamp}`, `lakefile.lean.{timestamp}`, `lake-manifest.json.{timestamp}`
- Auto-cleanup after successful upgrade (keep last 3)

**Rollback Strategy**:
1. First try: `git checkout lean-toolchain lakefile.lean` (if uncommitted)
2. Second try: Restore from `.lean-version-backup/`
3. Third try: Manual version pin in files + `lake update`

### 5. Recommended Architecture

**Command**: `/lean`

**Modes**:
| Mode | Invocation | Purpose |
|------|------------|---------|
| Check | `/lean` or `/lean check` | Show current versions, installed toolchains, available updates |
| Upgrade | `/lean upgrade [VERSION]` | Interactive upgrade with confirmation |
| Rollback | `/lean rollback` | Revert to previous version from backup |
| Dry-run | `/lean --dry-run upgrade` | Preview upgrade without changes |

**Skill**: `skill-lean-version`

**Allowed Tools**: `Bash`, `Read`, `Write`, `Edit`, `AskUserQuestion`

**Not Needed**: `Task` tool (no subagent delegation)

### 6. Execution Flow (Upgrade Mode)

1. **Check current state**:
   - Read `lean-toolchain` for current version
   - Read `lakefile.lean` for Mathlib pin
   - Run `elan show` for installed toolchains

2. **Fetch available versions**:
   - Query latest Mathlib release tag
   - Query latest Lean stable release
   - Compare with current

3. **Present options via AskUserQuestion**:
   - "Stay on current version"
   - "Upgrade to latest stable ({version})"
   - "Upgrade to specific version..."

4. **Create backup**:
   - Copy current files to `.lean-version-backup/`

5. **Apply upgrade**:
   - Update `lean-toolchain` with new version
   - Update `lakefile.lean` mathlib pin
   - Run `lake update`
   - Run `lake exe cache get`

6. **Verify**:
   - Run `lake build` (or defer to user)
   - Report success/failure

7. **Cleanup on success**:
   - Prune old backups (keep 3 most recent)

## Decisions

1. **Direct execution skill** - No subagent needed; workflow is linear and straightforward
2. **Git-first backup** - Rely on git for primary backup, use `.lean-version-backup/` as safety net
3. **AskUserQuestion for confirmation** - Match `/refresh` pattern for interactive upgrades
4. **Combine toolchain + Mathlib** - Single command manages both (they typically move together)
5. **Cache integration mandatory** - Always run `lake exe cache get` after upgrade to avoid long rebuilds

## Recommendations

### Implementation Priority

1. **Phase 1**: Core check/status mode
   - Show current toolchain, Mathlib version
   - List installed toolchains
   - Basic version comparison

2. **Phase 2**: Upgrade mode
   - Interactive upgrade with AskUserQuestion
   - Backup creation
   - File updates + lake update + cache get

3. **Phase 3**: Rollback mode
   - Restore from backup
   - Validate restored state

4. **Phase 4**: Dry-run mode
   - Preview all changes without applying

### File Structure

```
.claude/
  commands/
    lean.md              # Command entry point
  skills/
    skill-lean-version/
      SKILL.md           # Direct execution skill
```

### Testing Strategy

1. Test check mode on current project state
2. Test dry-run upgrade to verify change detection
3. Test actual upgrade on branch (expendable)
4. Test rollback from backup

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Network failure during upgrade | Medium | Medium | Backup exists; user can retry |
| Incompatible Mathlib version | Low | High | Dry-run mode; version compatibility check |
| Build fails after upgrade | Medium | Medium | Clear rollback path; build verification step |
| Cache corruption | Low | Medium | `lake exe cache get!` force overwrite |
| Concurrent lake operations | Low | Low | Warn if .lake lock exists |

## Appendix

### Search Queries Used

1. "elan Lean toolchain management commands 2026"
2. "Mathlib4 cache lake exe cache get update 2025 2026"

### Key Documentation URLs

- [Elan README](https://github.com/leanprover/elan/blob/master/README.md)
- [Managing Toolchains with Elan](https://lean-lang.org/doc/reference/latest/Build-Tools-and-Distribution/Managing-Toolchains-with-Elan/)
- [Using Mathlib4 as a dependency](https://github.com/leanprover-community/mathlib4/wiki/Using-mathlib4-as-a-dependency)

### Current Project Versions (as of research)

```
lean-toolchain: leanprover/lean4:v4.27.0-rc1
lakefile.lean mathlib: v4.27.0-rc1
Installed toolchains: v4.14.0, v4.22.0, v4.27.0-rc1
```
