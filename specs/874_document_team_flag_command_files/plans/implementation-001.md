# Implementation Plan: Document --team flag in command files

- **Task**: 874 - document_team_flag_command_files
- **Status**: [NOT STARTED]
- **Effort**: 1 hour
- **Dependencies**: None
- **Research Inputs**: specs/874_document_team_flag_command_files/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Add documentation for `--team` and `--team-size N` flags to the `/research`, `/plan`, and `/implement` command files. These flags are already implemented in the orchestrator but undocumented in the command files, making the feature undiscoverable to users.

### Research Integration

Research report identified:
- Three command files need updates: research.md, plan.md, implement.md
- Established Options table pattern from lake.md should be followed
- argument-hint in YAML frontmatter needs updating
- Team mode routes to skill-team-{research|plan|implement} when --team flag is present
- team_size is clamped to 2-4 with default of 2

## Goals & Non-Goals

**Goals**:
- Document --team and --team-size flags in all three command files
- Follow established Options table pattern from lake.md
- Update argument-hint in YAML frontmatter for each command
- Maintain consistency across all three commands

**Non-Goals**:
- Modifying the team mode implementation
- Updating skill-orchestrator or team skill files
- Adding new functionality

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Inconsistent documentation style | Low | Low | Use lake.md as reference template |
| Missing details about team behavior | Low | Low | Reference research report for accurate details |

## Implementation Phases

### Phase 1: Update research.md [NOT STARTED]

**Goal**: Add --team and --team-size documentation to the /research command file

**Tasks**:
- [ ] Update argument-hint to `TASK_NUMBER [FOCUS] [--team [--team-size N]]`
- [ ] Add Options table after Arguments section with --team and --team-size flags
- [ ] Add brief explanation of team mode behavior

**Timing**: 15 minutes

**Files to modify**:
- `.claude/commands/research.md` - Add Options section after line 15

**Verification**:
- Options table follows lake.md format
- argument-hint matches CLAUDE.md Command Reference table

---

### Phase 2: Update plan.md [NOT STARTED]

**Goal**: Add --team and --team-size documentation to the /plan command file

**Tasks**:
- [ ] Update argument-hint to `TASK_NUMBER [--team [--team-size N]]`
- [ ] Add Options table after Arguments section with --team and --team-size flags
- [ ] Add brief explanation of team mode behavior

**Timing**: 15 minutes

**Files to modify**:
- `.claude/commands/plan.md` - Add Options section after line 14

**Verification**:
- Options table follows lake.md format
- argument-hint matches CLAUDE.md Command Reference table

---

### Phase 3: Update implement.md [NOT STARTED]

**Goal**: Add --team and --team-size documentation to the /implement command file

**Tasks**:
- [ ] Update argument-hint to `TASK_NUMBER [--team [--team-size N]] [--force]`
- [ ] Restructure Arguments section to separate positional args from flags
- [ ] Add Options table with --team, --team-size, and --force flags
- [ ] Add brief explanation of team mode behavior

**Timing**: 20 minutes

**Files to modify**:
- `.claude/commands/implement.md` - Update Arguments section and add Options section

**Verification**:
- Options table follows lake.md format
- --force flag preserved in new Options table
- argument-hint matches CLAUDE.md Command Reference table

---

### Phase 4: Verification [NOT STARTED]

**Goal**: Verify all changes are consistent and complete

**Tasks**:
- [ ] Verify all three command files have consistent Options table format
- [ ] Verify argument-hint values match CLAUDE.md Command Reference
- [ ] Verify team mode explanation is consistent across files

**Timing**: 10 minutes

**Verification**:
- All three files have identical Options table structure
- argument-hint values are accurate
- No broken formatting

## Testing & Validation

- [ ] Each command file has proper Options table after Arguments section
- [ ] argument-hint matches CLAUDE.md Command Reference table for each command
- [ ] Team mode explanation is present in each file
- [ ] --force flag in implement.md is properly documented in new Options table

## Artifacts & Outputs

- `.claude/commands/research.md` - Updated with --team documentation
- `.claude/commands/plan.md` - Updated with --team documentation
- `.claude/commands/implement.md` - Updated with --team and --force documentation
- `specs/874_document_team_flag_command_files/plans/implementation-001.md` - This plan
- `specs/874_document_team_flag_command_files/summaries/implementation-summary-{DATE}.md` - Summary on completion

## Rollback/Contingency

Revert changes via git:
```bash
git checkout -- .claude/commands/research.md .claude/commands/plan.md .claude/commands/implement.md
```
