# Implementation Plan: Task #611

- **Task**: 611 - context_optimization_and_loading_patterns
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Priority**: Medium
- **Dependencies**: Task 609 (Document command-skill-agent architecture)
- **Research Inputs**: specs/611_context_optimization_and_loading_patterns/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This plan optimizes context files created in task 609 and those pre-existing in the orchestration directory. The research identified 5,250 lines across 10 orchestration files with significant redundancy, duplicate references in index.md, and multiple files documenting the same patterns. The optimization follows a consolidate-then-verify approach: first fix low-effort issues, then consolidate high-impact orchestration files, and finally verify no broken references remain.

### Research Integration

Key findings from research-001.md:
- Context loading architecture is correctly structured (commands: 0, skills: 0-2 refs, agents: 2-8 loaded)
- Orchestration files have 75% potential reduction (5,250 -> ~1,300 lines)
- Index.md has duplicate state-management.md references
- Status-related files have overlapping content

## Goals & Non-Goals

**Goals**:
- Consolidate orchestration files from 10 to 3-4 focused files
- Remove duplicate references from index.md
- Merge overlapping status-related documentation
- Verify all @-references remain valid after consolidation
- Maintain or improve context quality and clarity

**Non-Goals**:
- Changing the lazy loading architecture (it's already correct)
- Modifying agent or skill files (only context files)
- Removing intentional duplication (template consistency is acceptable)
- Consolidating project-specific context (lean4/, logic/ directories)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Consolidation breaks @-references | High | Medium | Grep all references before removal, create redirect comments |
| Over-consolidation loses clarity | Medium | Low | Keep distinct sections with clear headers, preserve quick-reference sections |
| Information loss during merge | Medium | Low | Audit content before merge, preserve all unique information |
| Index.md cleanup breaks examples | Low | Low | Test examples after cleanup, verify loading patterns |

## Implementation Phases

### Phase 1: Fix Index.md Duplicates [NOT STARTED]

**Goal**: Remove duplicate references and fix minor issues in index.md

**Tasks**:
- [ ] Read index.md and identify all duplicate references
- [ ] Remove duplicate state-management.md references (lines ~429, 444, 455)
- [ ] Verify deprecated file references have valid deprecation dates
- [ ] Update any stale version numbers or dates

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/index.md` - Remove duplicate references

**Verification**:
- Grep index.md for duplicate @-references
- Each file referenced exactly once in loading examples

---

### Phase 2: Audit Orchestration Redundancy [NOT STARTED]

**Goal**: Document exact overlap between orchestration files before consolidation

**Tasks**:
- [ ] Read all 10 orchestration files and catalog content
- [ ] Create overlap matrix showing which concepts appear in which files
- [ ] Identify canonical source for each concept (session tracking, delegation depth, timeouts, etc.)
- [ ] Draft consolidation mapping: which file content merges where

**Timing**: 45 minutes

**Files to review**:
- `.claude/context/core/orchestration/orchestrator.md` (870 lines)
- `.claude/context/core/orchestration/delegation.md` (851 lines)
- `.claude/context/core/orchestration/routing.md` (769 lines)
- `.claude/context/core/orchestration/architecture.md` (758 lines)
- `.claude/context/core/orchestration/validation.md` (690 lines)
- `.claude/context/core/orchestration/state-management.md` (535 lines)
- `.claude/context/core/orchestration/sessions.md`
- `.claude/context/core/orchestration/preflight-pattern.md`
- `.claude/context/core/orchestration/postflight-pattern.md`
- `.claude/context/core/orchestration/subagent-validation.md`

**Verification**:
- Overlap matrix document created
- Clear consolidation plan with no information loss

---

### Phase 3: Consolidate Orchestration Files [NOT STARTED]

**Goal**: Reduce orchestration files from 10 to 3-4 focused files

**Tasks**:
- [ ] Create `orchestration-core.md` (~600 lines) - Essential patterns: delegation, session tracking, routing
- [ ] Create `orchestration-validation.md` (~400 lines) - Return validation, artifact validation, preflight/postflight
- [ ] Create `orchestration-reference.md` (~300 lines) - Troubleshooting, examples, quick reference
- [ ] Add deprecation notices to original files pointing to new locations
- [ ] Update index.md to reference new consolidated files

**Timing**: 90 minutes

**Files to create**:
- `.claude/context/core/orchestration/orchestration-core.md` - Primary orchestration patterns
- `.claude/context/core/orchestration/orchestration-validation.md` - Validation patterns
- `.claude/context/core/orchestration/orchestration-reference.md` - Examples and troubleshooting

**Files to modify**:
- Original orchestration files - Add deprecation notices
- `.claude/context/index.md` - Update to reference new files

**Verification**:
- New files cover all unique content from originals
- Index.md updated with new references
- Deprecation notices include migration paths

---

### Phase 4: Merge Status-Related Files [NOT STARTED]

**Goal**: Consolidate overlapping status documentation

**Tasks**:
- [ ] Audit status-markers.md, status-transitions.md, state-management.md for overlap
- [ ] Identify which content is unique vs duplicated
- [ ] Either merge into single file OR keep separate with clear boundaries
- [ ] Update cross-references between files

**Timing**: 45 minutes

**Files to review/modify**:
- `.claude/context/core/standards/status-markers.md` (350 lines)
- `.claude/context/core/orchestration/state-management.md` (535 lines)
- Any status-transitions.md if it exists

**Verification**:
- No contradictory information between status files
- Clear boundaries between what each file covers
- All cross-references valid

---

### Phase 5: Verification and Cleanup [NOT STARTED]

**Goal**: Ensure all changes maintain system integrity

**Tasks**:
- [ ] Grep all .claude/ files for @-references to removed/changed files
- [ ] Verify all references in CLAUDE.md still resolve
- [ ] Verify all references in agent files still resolve
- [ ] Remove deprecated files that have passed their deprecation period (if any)
- [ ] Run test command flows if possible (research, plan, implement)
- [ ] Document final line count reduction achieved

**Timing**: 30 minutes

**Files to verify**:
- `.claude/CLAUDE.md` - Project configuration
- `.claude/agents/*.md` - All agent files
- `.claude/skills/*/SKILL.md` - All skill files
- `.claude/commands/*.md` - All command files
- `.claude/context/index.md` - Master index

**Verification**:
- Zero broken @-references
- All deprecated files have migration paths documented
- Final line count documented (target: 75% reduction in orchestration/)

## Testing & Validation

- [ ] Grep for duplicate @-references in index.md (should be zero)
- [ ] Grep for broken references to removed files (should be zero)
- [ ] Verify consolidated files have clear section headers
- [ ] Verify orchestration/ directory has expected file count (3-4 new + deprecated originals)
- [ ] Verify total line count reduction meets target (~75%)

## Artifacts & Outputs

- `specs/611_context_optimization_and_loading_patterns/plans/implementation-001.md` (this file)
- `.claude/context/core/orchestration/orchestration-core.md` (new consolidated file)
- `.claude/context/core/orchestration/orchestration-validation.md` (new consolidated file)
- `.claude/context/core/orchestration/orchestration-reference.md` (new consolidated file)
- Updated `.claude/context/index.md`
- `specs/611_context_optimization_and_loading_patterns/summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If consolidation breaks system:
1. Keep deprecated original files functional (don't delete during implementation)
2. Revert index.md changes to reference original files
3. Remove new consolidated files
4. Git revert if necessary

All original files are preserved with deprecation notices until verified working, enabling quick rollback by removing deprecation notices and reverting index.md changes.
