# Implementation Plan: Task #728

- **Task**: 728 - create_user_guide_command_workflows
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Priority**: medium
- **Dependencies**: None
- **Research Inputs**: specs/728_create_user_guide_command_workflows/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Create a comprehensive user guide documenting all command workflows for the ProofChecker `.claude/` task management system. The guide will cover the complete task lifecycle (task -> research -> plan -> implement), maintenance commands, and utility commands. Research identified 13 commands organized into core workflow, maintenance, and utility categories. The guide will be placed in `.claude/docs/guides/user-guide.md` and linked from `.claude/docs/README.md`.

### Research Integration

- Identified 13 commands across 3 categories: core workflow (5), maintenance (5), utility (3)
- Core workflow follows: `/task` -> `/research` -> `/plan` -> `/implement` with `/revise` for refinement
- All commands use checkpoint-based execution: GATE IN -> DELEGATE -> GATE OUT -> COMMIT
- Existing docs lack user-facing command workflow documentation (gap identified)

## Goals & Non-Goals

**Goals**:
- Create user-facing documentation explaining all command workflows
- Document the complete task lifecycle with status transitions
- Cover all command flags and options with clear examples
- Provide quick reference tables for common operations
- Link appropriately to existing architecture documentation

**Non-Goals**:
- Duplicating internal implementation details covered in architecture docs
- Documenting agent/skill internals (focus on user perspective)
- Creating separate pages for each command (single comprehensive guide)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Documentation becomes stale | M | M | Include version date in header; link to command files for authoritative details |
| Too much detail overwhelms users | M | L | Focus on common use cases; use tables for quick reference |
| Missing edge cases | L | M | Include troubleshooting section for common issues |

## Implementation Phases

### Phase 1: Create User Guide Structure [COMPLETED]

**Goal**: Create the main user guide document with proper structure and introductory content

**Tasks**:
- [ ] Create `.claude/docs/guides/user-guide.md` with metadata header
- [ ] Write Quick Start section with first workflow example
- [ ] Create document outline with all section headers
- [ ] Add navigation links to related documentation

**Timing**: 30 minutes

**Files to modify**:
- `.claude/docs/guides/user-guide.md` - Create new file with structure and intro

**Verification**:
- File exists with proper markdown structure
- Quick Start section provides working example

---

### Phase 2: Document Core Workflow Commands [COMPLETED]

**Goal**: Document the primary task lifecycle commands with all flags and examples

**Tasks**:
- [ ] Document `/task` command with all flags (create, --recover, --expand, --sync, --abandon, --review)
- [ ] Document `/research` command (repeatable, language routing, focus parameter)
- [ ] Document `/plan` command (prerequisites, output structure)
- [ ] Document `/revise` command (plan revision vs description update)
- [ ] Document `/implement` command (resume support, phase tracking)
- [ ] Add status transition table and workflow diagram

**Timing**: 45 minutes

**Files to modify**:
- `.claude/docs/guides/user-guide.md` - Add Core Workflow Commands section

**Verification**:
- All 5 core commands documented with syntax and examples
- Status transitions clearly explained
- Workflow progression diagram included

---

### Phase 3: Document Maintenance and Utility Commands [COMPLETED]

**Goal**: Document maintenance commands and utility commands

**Tasks**:
- [ ] Document `/todo` command (archival, dry-run, roadmap integration)
- [ ] Document `/review` command (scope, --create-tasks flag)
- [ ] Document `/refresh` command (cleanup, age thresholds)
- [ ] Document `/lake` command (Lean build, auto-repair, --clean, --max-retries)
- [ ] Document `/errors` command (analysis, --fix flag)
- [ ] Document `/meta` command (system builder, modes)
- [ ] Document `/learn` command (tag extraction, task creation)
- [ ] Document `/convert` command (format conversion, supported types)

**Timing**: 30 minutes

**Files to modify**:
- `.claude/docs/guides/user-guide.md` - Add Maintenance and Utility sections

**Verification**:
- All 8 commands documented with syntax and examples
- Common use cases covered for each command

---

### Phase 4: Add Reference Tables and Update README [COMPLETED]

**Goal**: Add quick reference material and link guide from docs README

**Tasks**:
- [ ] Create command quick reference table (command, syntax, description)
- [ ] Add troubleshooting section with common issues and solutions
- [ ] Update `.claude/docs/README.md` to include User Guide in navigation
- [ ] Add User Guide entry to Guides section with description
- [ ] Verify all internal links work correctly

**Timing**: 15 minutes

**Files to modify**:
- `.claude/docs/guides/user-guide.md` - Add reference tables and troubleshooting
- `.claude/docs/README.md` - Add link to user guide

**Verification**:
- Quick reference table covers all 13 commands
- README.md links to new guide with description
- All documentation links functional

---

## Testing & Validation

- [ ] All 13 commands documented with syntax examples
- [ ] Status transition table accurate per state-management.md
- [ ] Workflow diagrams match actual command flow
- [ ] README.md properly links to new user guide
- [ ] No broken internal links in new documentation
- [ ] Documentation follows existing style conventions

## Artifacts & Outputs

- `.claude/docs/guides/user-guide.md` - New comprehensive user guide
- `.claude/docs/README.md` - Updated with link to user guide
- `specs/728_create_user_guide_command_workflows/summaries/implementation-summary-YYYYMMDD.md` - Implementation summary

## Rollback/Contingency

If the user guide proves problematic:
1. The new file can be removed without affecting existing docs
2. README.md changes can be reverted to previous state
3. No existing documentation is modified in place (additive changes only)
