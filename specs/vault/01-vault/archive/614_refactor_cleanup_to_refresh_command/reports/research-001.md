# Research Report: Refactor /cleanup to /refresh

- **Task**: 614 - refactor_cleanup_to_refresh_command
- **Started**: 2026-01-19T10:00:00Z
- **Completed**: 2026-01-19T10:45:00Z
- **Effort**: 45 minutes
- **Priority**: Medium
- **Dependencies**: None
- **Sources/Inputs**:
  - Codebase exploration (Glob, Grep, Read)
  - .claude/commands/cleanup.md
  - .claude/skills/skill-cleanup/SKILL.md
  - .claude/scripts/claude-cleanup.sh
  - .claude/output/cleanup.md (bug evidence)
- **Artifacts**:
  - specs/614_refactor_cleanup_to_refresh_command/reports/research-001.md
- **Standards**: report-format.md, artifact-formats.md

## Executive Summary

- The /cleanup command needs to be renamed to /refresh with a simplified two-mode interface
- 10 files require modification, 5 files require renaming
- Critical script bug: `set -euo pipefail` causes early exit due to arithmetic operator behavior with value 0
- AskUserQuestion tool available for interactive confirmation (see meta-builder-agent pattern)
- Documentation references in CLAUDE.md and other files need updating

## Context & Scope

This research examines the current /cleanup implementation to understand:
1. All files requiring rename/update
2. The script bug causing early exit after each kill
3. How to use AskUserQuestion for interactive confirmation
4. Documentation updates needed

The goal is to transform the command from a four-mode interface (--status, --dry-run, default, --force) to a two-mode interface (default with AskUserQuestion prompt, --force for immediate execution).

## Findings

### 1. Complete File Inventory

#### Files to Rename (5 files)

| Current Path | New Path |
|--------------|----------|
| `.claude/commands/cleanup.md` | `.claude/commands/refresh.md` |
| `.claude/skills/skill-cleanup/SKILL.md` | `.claude/skills/skill-refresh/SKILL.md` |
| `.claude/scripts/claude-cleanup.sh` | `.claude/scripts/claude-refresh.sh` |
| `.claude/systemd/claude-cleanup.service` | `.claude/systemd/claude-refresh.service` |
| `.claude/systemd/claude-cleanup.timer` | `.claude/systemd/claude-refresh.timer` |

#### Files to Update (References) (10 files)

| File | Changes Needed |
|------|----------------|
| `.claude/CLAUDE.md` | Update command references (lines 311, 343-352), skill name, command examples |
| `.claude/scripts/install-aliases.sh` | Update alias names and script references |
| `.claude/scripts/install-systemd-timer.sh` | Update service/timer names and paths |
| `.claude/context/core/orchestration/sessions.md` | May reference cleanup |
| `.claude/context/core/orchestration/orchestrator.md` | May reference cleanup |
| `.claude/docs/memory-leak-fix-plan.md` | References cleanup script |
| `.claude/docs/templates/command-template.md` | May reference cleanup as example |
| `.claude/docs/templates/agent-template.md` | May reference cleanup |
| `.claude/docs/guides/permission-configuration.md` | May reference cleanup |
| `.claude/docs/troubleshooting/status-conflicts.md` | May reference cleanup |

### 2. Script Bug Analysis

**Location**: `.claude/scripts/claude-cleanup.sh`, lines 305-316

**Root Cause**: The combination of `set -euo pipefail` (line 18) and bash arithmetic operators.

**Problem Code**:
```bash
((terminated++))
((failed++))
```

**Why It Fails**:
- When `terminated=0`, the expression `((terminated++))` evaluates the pre-increment value (0)
- In bash arithmetic context, 0 is falsy, so `(( ... ))` returns exit code 1
- With `set -e` enabled, any command returning non-zero exit code terminates the script
- Result: Script exits after the first successful termination

**Evidence** (from .claude/output/cleanup.md):
```
PID 4046: terminated (forced)
[Script exits with code 1]
```

**Fix Options**:

Option A - Disable exit-on-error for arithmetic:
```bash
((terminated++)) || true
((failed++)) || true
```

Option B - Use assignment instead of arithmetic expansion:
```bash
terminated=$((terminated + 1))
failed=$((failed + 1))
```

Option C - Initialize to non-zero value:
```bash
terminated=1  # Pre-initialize
# After loop, subtract 1 from count
```

**Recommended Fix**: Option B (clearest, most portable)

### 3. AskUserQuestion Pattern

**Reference Implementation**: `.claude/agents/meta-builder-agent.md` (lines 197-313)

**Pattern for Interactive Confirmation**:

```json
{
  "question": "Found N orphaned processes using X MB. Terminate these processes?",
  "header": "Confirm Cleanup",
  "options": [
    {"label": "Yes, terminate", "description": "Kill N orphaned processes and reclaim X MB"},
    {"label": "Cancel", "description": "Exit without changes"}
  ]
}
```

**Key Points**:
- AskUserQuestion is an allowed tool for direct execution skills
- Return structured response based on user selection
- No need for shell-level `read -p` which fails in Claude Code environment

### 4. New Interface Design

**Current Interface (4 modes)**:
```
/cleanup              # Interactive (shell prompt - broken in Claude)
/cleanup --status     # Status only
/cleanup --dry-run    # Preview only
/cleanup --force      # Immediate execution
```

**New Interface (2 modes)**:
```
/refresh              # Show status + AskUserQuestion prompt
/refresh --force      # Immediate execution
```

**Behavior Change**:
- Default mode (`/refresh`):
  1. Run status/detection
  2. Display orphaned process list with memory usage
  3. Use AskUserQuestion for confirmation
  4. If confirmed, terminate processes
  5. Display results

- Force mode (`/refresh --force`):
  1. Run detection
  2. Terminate immediately
  3. Display results

### 5. Shell Alias Updates

**Current Aliases** (install-aliases.sh):
```bash
alias claude-memory='$CLEANUP_SCRIPT --status'
alias claude-cleanup='$CLEANUP_SCRIPT'
alias claude-orphans='$CLEANUP_SCRIPT --dry-run'
alias claude-cleanup-force='$CLEANUP_SCRIPT --force'
```

**New Aliases**:
```bash
alias claude-refresh='$REFRESH_SCRIPT'
alias claude-refresh-force='$REFRESH_SCRIPT --force'
```

Note: `--status` and `--dry-run` functionality merged into default mode.

### 6. Systemd Service Updates

Files need updating:
- `claude-cleanup.service` -> `claude-refresh.service`
- `claude-cleanup.timer` -> `claude-refresh.timer`

Content changes:
- Update Description fields
- Update ExecStart paths
- Update SyslogIdentifier

## Decisions

1. **Fix Method**: Use Option B (assignment instead of arithmetic expansion) for the script bug fix
2. **Alias Strategy**: Reduce from 4 to 2 aliases (claude-refresh, claude-refresh-force)
3. **Skill Type**: Keep as direct execution skill (not thin wrapper) since no subagent needed
4. **AskUserQuestion**: Use in skill for interactive confirmation instead of shell read

## Recommendations

### Implementation Order

**Phase 1: Script Bug Fix**
1. Fix arithmetic operators in claude-cleanup.sh
2. Test that full cleanup loop completes

**Phase 2: Rename Files**
1. Rename command file
2. Rename and relocate skill directory
3. Rename script file
4. Rename systemd files

**Phase 3: Update Interfaces**
1. Simplify command syntax (remove --status, --dry-run)
2. Update skill to use AskUserQuestion
3. Update script to remove obsolete flags

**Phase 4: Update References**
1. Update CLAUDE.md documentation
2. Update install-aliases.sh
3. Update install-systemd-timer.sh
4. Update any other reference files

**Phase 5: Verification**
1. Test /refresh (interactive mode)
2. Test /refresh --force
3. Test shell aliases
4. Test systemd timer

### Code Changes Summary

**claude-refresh.sh (new script)**:
- Remove --status flag handling
- Remove --dry-run flag handling
- Keep --force flag
- Fix arithmetic operators
- Default mode: output status and process list, exit 0 (skill handles confirmation)

**skill-refresh/SKILL.md**:
- Add AskUserQuestion to allowed-tools
- Default mode: Run script for status, use AskUserQuestion, run script with --force if confirmed
- Force mode: Run script with --force directly

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Breaking existing aliases | Medium | Low | Document migration path, keep old aliases temporarily |
| Systemd timer stops working | Low | Low | Test timer after rename |
| AskUserQuestion doesn't work as expected | Low | Medium | Test interactive mode thoroughly |
| Documentation inconsistency | Medium | Low | Search-and-replace cleanup references |

## Appendix

### Search Queries Used

```bash
# Find all files referencing cleanup
grep -r "cleanup" .claude/ --include="*.md" --include="*.sh"

# Find all cleanup-named files
find .claude -name "*cleanup*"

# Count references
grep -c "cleanup" .claude/CLAUDE.md
```

### Reference Files

- Command template: `.claude/docs/templates/command-template.md`
- Skill pattern: `.claude/context/core/patterns/thin-wrapper-skill.md`
- AskUserQuestion example: `.claude/agents/meta-builder-agent.md`
- Bash arithmetic: https://www.gnu.org/software/bash/manual/html_node/Shell-Arithmetic.html
