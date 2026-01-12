# Implementation Plan: Task #410

**Task**: Remove eager context loading from skill frontmatter
**Version**: 001
**Created**: 2026-01-12
**Language**: meta

## Overview

Remove `context:` arrays from skill frontmatter files that still have them (skill-orchestrator, skill-status-sync, skill-git-workflow). Document the lazy loading pattern using @-references in skill bodies. Update CLAUDE.md to reflect the lazy loading approach.

## Current State Analysis

### Skills with `context:` arrays (need removal):
1. **skill-orchestrator** - Has `context:` array with routing.md, delegation.md
2. **skill-status-sync** - Has `context:` array with state-management.md, state-lookup.md
3. **skill-git-workflow** - Has `context:` array with git-safety.md

### Skills already using `context: fork` (no changes needed):
- skill-lean-research (uses `context: fork`)
- skill-researcher (uses `context: fork`)
- skill-planner (uses `context: fork`)
- skill-implementer (uses `context: fork`)
- skill-lean-implementation (uses `context: fork`)
- skill-latex-implementation (uses `context: fork`)

## Phases

### Phase 1: Update skill-orchestrator

**Status**: [NOT STARTED]

**Objectives**:
1. Remove `context:` array from frontmatter
2. Add @-reference for on-demand context loading in skill body

**Files to modify**:
- `.claude/skills/skill-orchestrator/SKILL.md` - Remove context array, add lazy loading reference

**Steps**:
1. Remove lines 5-7 (context: array with routing.md, delegation.md)
2. Add comment in frontmatter noting lazy loading approach
3. Add "Context Loading" section in skill body referencing:
   - `@.claude/context/core/orchestration/routing.md` (when routing needed)
   - `@.claude/context/core/orchestration/delegation.md` (when delegation needed)

**Verification**:
- Skill frontmatter has no `context:` array
- Skill body documents on-demand loading pattern

---

### Phase 2: Update skill-status-sync

**Status**: [NOT STARTED]

**Objectives**:
1. Remove `context:` array from frontmatter
2. Add @-reference for on-demand context loading in skill body

**Files to modify**:
- `.claude/skills/skill-status-sync/SKILL.md` - Remove context array, add lazy loading reference

**Steps**:
1. Remove lines 5-7 (context: array with state-management.md, state-lookup.md)
2. Add comment in frontmatter noting lazy loading approach
3. Add "Context Loading" section in skill body referencing:
   - `@.claude/context/core/orchestration/state-management.md` (when needed)
   - `@.claude/context/core/orchestration/state-lookup.md` (when needed)

**Verification**:
- Skill frontmatter has no `context:` array
- Skill body documents on-demand loading pattern

---

### Phase 3: Update skill-git-workflow

**Status**: [NOT STARTED]

**Objectives**:
1. Remove `context:` array from frontmatter
2. Add @-reference for on-demand context loading in skill body

**Files to modify**:
- `.claude/skills/skill-git-workflow/SKILL.md` - Remove context array, add lazy loading reference

**Steps**:
1. Remove lines 5-6 (context: array with git-safety.md)
2. Add comment in frontmatter noting lazy loading approach
3. Add "Context Loading" section in skill body referencing:
   - `@.claude/context/core/standards/git-safety.md` (when git operations performed)

**Verification**:
- Skill frontmatter has no `context:` array
- Skill body documents on-demand loading pattern

---

### Phase 4: Update CLAUDE.md documentation

**Status**: [NOT STARTED]

**Objectives**:
1. Document the lazy loading pattern in the Skill Architecture section
2. Clarify that all skills now use lazy loading (no eager context)
3. Reference context/index.md for on-demand lookup

**Files to modify**:
- `.claude/CLAUDE.md` - Update Skill Architecture section

**Steps**:
1. Update "Skill Architecture" section to note lazy loading pattern
2. Add note about `context: fork` vs removed `context:` arrays
3. Reference `@.claude/context/index.md` for context discovery
4. Remove or update any references to eager context loading

**Verification**:
- CLAUDE.md documents lazy loading pattern
- No references to `context:` arrays as a loading mechanism

---

### Phase 5: Verify and validate

**Status**: [NOT STARTED]

**Objectives**:
1. Verify no skills have `context:` arrays in frontmatter
2. Confirm all skills reference context/index.md pattern

**Files to check**:
- All `.claude/skills/*/SKILL.md` files

**Steps**:
1. Run grep to verify no remaining `context:` arrays (except `context: fork`)
2. Verify each skill documents on-demand context loading
3. Review context/index.md is up-to-date with skill context needs

**Verification**:
- `grep -r "^context:" .claude/skills/` shows only `context: fork` entries
- All skills have documented lazy loading approach

---

## Dependencies

- Task 409 (Convert workflow skills to forked subagent pattern) - COMPLETED

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Context not loaded when needed | Medium | Low | Document @-references clearly in skill bodies |
| Inconsistent pattern between skills | Low | Low | Use same "Context Loading" section format |

## Success Criteria

- [ ] No skills have `context:` arrays in frontmatter (except `context: fork`)
- [ ] All affected skills document on-demand context loading via @-references
- [ ] CLAUDE.md updated to reflect lazy loading pattern
- [ ] context/index.md remains the reference for context discovery

## Rollback Plan

Restore original `context:` arrays from git history if lazy loading causes issues.
