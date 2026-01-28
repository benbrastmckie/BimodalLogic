# Implementation Plan: Task #723

- **Task**: 723 - update_claude_documentation
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/723_update_claude_documentation/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Restructure CLAUDE.md to be the primary user-facing reference with a clear "Getting Started" section and categorized command documentation. Remove redundant content that duplicates ARCHITECTURE.md, and ensure all references are accurate. The goal is to make the documentation concise, complete, and easy to navigate.

### Research Integration

Key findings from research-001.md:
- CLAUDE.md is ~500 lines, ARCHITECTURE.md is ~975 lines with significant overlap
- 13 commands need clear categorization (Primary Workflow vs Maintenance vs Utility)
- Missing quick-start section showing complete task lifecycle
- Some outdated references need fixing (e.g., `.claude/agent/orchestrator.md`, project structure)

## Goals & Non-Goals

**Goals**:
- Add a "Getting Started" section to CLAUDE.md showing complete task lifecycle
- Reorganize command documentation by category with consistent examples
- Remove redundant content from CLAUDE.md that belongs in ARCHITECTURE.md
- Fix outdated references and path errors
- Ensure CLAUDE.md is under 400 lines (concise but complete)

**Non-Goals**:
- Complete rewrite of ARCHITECTURE.md (minimal changes only)
- Changes to individual command files (.claude/commands/)
- Changes to context files or agents
- Documentation of internal implementation details

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking existing Claude behavior by changing CLAUDE.md | High | Low | Preserve all critical configuration, test after changes |
| Information loss during consolidation | Medium | Medium | Move content to ARCHITECTURE.md before removing from CLAUDE.md |
| Users confused by reorganization | Low | Low | Keep structure logical, add clear section headers |

## Implementation Phases

### Phase 1: Add Getting Started Section [NOT STARTED]

**Goal**: Create a clear "Getting Started" section at the top of CLAUDE.md that shows users how to use the task management system with a concrete example.

**Tasks**:
- [ ] Read current CLAUDE.md structure completely
- [ ] Draft "Getting Started" section with complete task lifecycle example
- [ ] Include example showing: `/task` -> `/research` -> `/plan` -> `/implement` -> `/todo`
- [ ] Add expected output examples for each step
- [ ] Insert section after "Quick Reference" and before "System Overview"

**Timing**: 45 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - Add Getting Started section (~50 lines)

**Verification**:
- Getting Started section clearly shows workflow from task creation to completion
- Includes concrete commands user can run
- Under 60 lines total

---

### Phase 2: Reorganize Command Documentation [NOT STARTED]

**Goal**: Restructure the "Command Workflows" section to group commands by category with consistent formatting.

**Tasks**:
- [ ] Define three categories: Primary Workflow, Maintenance, Utility
- [ ] Reorganize existing command documentation into categories
- [ ] Add brief example for each command showing typical usage
- [ ] Remove detailed checkpoint descriptions (move to ARCHITECTURE.md if not already there)
- [ ] Update command reference table with categories

**Timing**: 45 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - Restructure Command Workflows section

**Command Categories**:
| Category | Commands |
|----------|----------|
| Primary Workflow | `/task`, `/research`, `/plan`, `/implement` |
| Maintenance | `/todo`, `/errors`, `/review`, `/refresh`, `/lake` |
| Utility | `/revise`, `/meta`, `/learn`, `/convert` |

**Verification**:
- Each command has 3-5 lines of documentation with example
- Categories are clearly labeled
- Total command section under 150 lines

---

### Phase 3: Remove Redundant Content [NOT STARTED]

**Goal**: Remove content from CLAUDE.md that duplicates ARCHITECTURE.md, keeping CLAUDE.md as the concise user reference.

**Tasks**:
- [ ] Identify redundant sections (Skill Architecture details, Forked Subagent pattern details)
- [ ] Verify content exists in ARCHITECTURE.md before removing
- [ ] Replace verbose explanations with references to ARCHITECTURE.md
- [ ] Keep only essential skill information (the mapping table)
- [ ] Consolidate "Thin Wrapper Skill Pattern" section to 10 lines max

**Timing**: 30 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - Remove redundant sections, add cross-references

**Sections to Consolidate**:
- Skill Architecture (keep mapping table, remove execution details)
- Thin Wrapper Skill Pattern (keep summary, remove pattern details)
- Custom Agent Registration (reduce to 3 lines with reference)
- Related Documentation (consolidate to 5 lines)

**Verification**:
- No essential information lost (available in ARCHITECTURE.md)
- CLAUDE.md has clear "See ARCHITECTURE.md for details" references
- Total file under 400 lines

---

### Phase 4: Fix Outdated References [NOT STARTED]

**Goal**: Update all incorrect file paths and outdated references throughout CLAUDE.md.

**Tasks**:
- [ ] Fix project structure section (add `Theories/` alongside `Logos/`)
- [ ] Update or remove references to `.claude/agent/orchestrator.md`
- [ ] Verify all file path references exist
- [ ] Update any deprecated pattern mentions
- [ ] Ensure version dates are current

**Timing**: 30 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - Fix references
- `.claude/ARCHITECTURE.md` - Fix references (minimal)

**Known Issues to Fix**:
1. Line 159 of ARCHITECTURE.md references `.claude/agent/orchestrator.md` - doesn't exist
2. Project structure shows only `Logos/` but `Theories/` also exists
3. Any references to deprecated files from Task 246 consolidation

**Verification**:
- All referenced files exist
- Project structure matches actual directory layout
- No broken internal links

---

### Phase 5: Final Review and Validation [NOT STARTED]

**Goal**: Verify the restructured documentation is accurate, complete, and concise.

**Tasks**:
- [ ] Read through complete CLAUDE.md for flow and clarity
- [ ] Verify line count is under 400 lines
- [ ] Check that all commands are documented
- [ ] Verify cross-references to ARCHITECTURE.md are accurate
- [ ] Run sample commands to verify documentation matches behavior

**Timing**: 30 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - Final polish and fixes

**Verification Checklist**:
- [ ] Getting Started section is clear and actionable
- [ ] Command categories are logical and complete
- [ ] No essential information missing
- [ ] All file paths are valid
- [ ] Total lines under 400
- [ ] Cross-references work

## Testing & Validation

- [ ] Read restructured CLAUDE.md top to bottom for coherence
- [ ] Verify each command in Quick Reference exists with documentation
- [ ] Check all internal links resolve to existing files
- [ ] Confirm line count target met (<400 lines)
- [ ] Test one command from each category works as documented

## Artifacts & Outputs

- `plans/implementation-001.md` - This plan file
- `.claude/CLAUDE.md` - Updated documentation (primary deliverable)
- `.claude/ARCHITECTURE.md` - Minor fixes to outdated references
- `summaries/implementation-summary-20260128.md` - Completion summary

## Rollback/Contingency

If changes cause issues:
1. Git revert the CLAUDE.md changes
2. Original content preserved in git history
3. Can incrementally re-apply changes one phase at a time
