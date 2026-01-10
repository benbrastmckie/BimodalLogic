# Implementation Plan: Task #351

**Task**: Review and fix skill context loading
**Version**: 001
**Created**: 2026-01-10
**Language**: meta

## Overview

Replace `context: fork` in all 9 skill SKILL.md files with targeted context file arrays. Each skill will load only the 1-3 context files relevant to its domain and purpose, following the three-tier loading strategy. This improves efficiency by loading focused domain knowledge instead of forking the entire conversation context.

## Phases

### Phase 1: Lean Skills Context Update

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Update skill-lean-implementation with Lean-specific context
2. Update skill-lean-research with search tool context

**Files to modify**:
- `.claude/skills/skill-lean-implementation/SKILL.md` - Replace `context: fork` with Lean implementation context
- `.claude/skills/skill-lean-research/SKILL.md` - Replace `context: fork` with Lean research context

**Steps**:
1. Edit skill-lean-implementation/SKILL.md:
   - Change `context: fork` to:
     ```yaml
     context:
       - .claude/context/project/lean4/tools/mcp-tools-guide.md
       - .claude/context/project/lean4/patterns/tactic-patterns.md
       - .claude/context/project/lean4/standards/lean4-style-guide.md
     ```
2. Edit skill-lean-research/SKILL.md:
   - Change `context: fork` to:
     ```yaml
     context:
       - .claude/context/project/lean4/tools/mcp-tools-guide.md
       - .claude/context/project/lean4/tools/leansearch-api.md
       - .claude/context/project/lean4/tools/loogle-api.md
     ```

**Verification**:
- Both files have valid YAML frontmatter
- Context paths reference existing files
- No syntax errors in frontmatter

---

### Phase 2: General Workflow Skills Context Update

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Update skill-implementer with summary format context
2. Update skill-researcher with report format context
3. Update skill-planner with plan format context
4. Update skill-latex-implementation with minimal context

**Files to modify**:
- `.claude/skills/skill-implementer/SKILL.md` - Add summary and code pattern context
- `.claude/skills/skill-researcher/SKILL.md` - Add report format context
- `.claude/skills/skill-planner/SKILL.md` - Add plan format and task breakdown context
- `.claude/skills/skill-latex-implementation/SKILL.md` - Add minimal summary format context

**Steps**:
1. Edit skill-implementer/SKILL.md:
   - Change `context: fork` to:
     ```yaml
     context:
       - .claude/context/core/formats/summary-format.md
       - .claude/context/core/standards/code-patterns.md
     ```
2. Edit skill-researcher/SKILL.md:
   - Change `context: fork` to:
     ```yaml
     context:
       - .claude/context/core/formats/report-format.md
     ```
3. Edit skill-planner/SKILL.md:
   - Change `context: fork` to:
     ```yaml
     context:
       - .claude/context/core/formats/plan-format.md
       - .claude/context/core/workflows/task-breakdown.md
     ```
4. Edit skill-latex-implementation/SKILL.md:
   - Change `context: fork` to:
     ```yaml
     context:
       - .claude/context/core/formats/summary-format.md
     ```

**Verification**:
- All 4 files have valid YAML frontmatter
- Context paths reference existing files
- No syntax errors in frontmatter

---

### Phase 3: Infrastructure Skills Context Update

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Update skill-status-sync with state management context
2. Update skill-git-workflow with git safety context
3. Update skill-orchestrator with routing/delegation context

**Files to modify**:
- `.claude/skills/skill-status-sync/SKILL.md` - Add state management context
- `.claude/skills/skill-git-workflow/SKILL.md` - Add git safety context
- `.claude/skills/skill-orchestrator/SKILL.md` - Add routing and delegation context

**Steps**:
1. Edit skill-status-sync/SKILL.md:
   - Change `context: fork` to:
     ```yaml
     context:
       - .claude/context/core/orchestration/state-management.md
       - .claude/context/core/orchestration/state-lookup.md
     ```
2. Edit skill-git-workflow/SKILL.md:
   - Change `context: fork` to:
     ```yaml
     context:
       - .claude/context/core/standards/git-safety.md
     ```
3. Edit skill-orchestrator/SKILL.md:
   - Change `context: fork` to:
     ```yaml
     context:
       - .claude/context/core/orchestration/routing.md
       - .claude/context/core/orchestration/delegation.md
     ```

**Verification**:
- All 3 files have valid YAML frontmatter
- Context paths reference existing files
- No syntax errors in frontmatter

---

### Phase 4: Verification and Documentation

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Verify all context file paths are valid
2. Check YAML frontmatter syntax
3. Document the context loading pattern

**Files to modify**:
- None (verification phase)

**Steps**:
1. Verify all referenced context files exist:
   ```bash
   # Check each context file path
   ls -la .claude/context/project/lean4/tools/mcp-tools-guide.md
   ls -la .claude/context/project/lean4/patterns/tactic-patterns.md
   # ... etc for all paths
   ```
2. Validate YAML frontmatter in each skill file
3. Add a comment in each skill file explaining context rationale (optional)

**Verification**:
- All context file paths exist
- All skill files have valid YAML frontmatter
- No broken references

---

## Dependencies

- None - all context files already exist

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Context file path incorrect | Medium | Low | Verify paths exist before committing |
| YAML syntax error in frontmatter | High | Low | Validate YAML after each edit |
| Skill system doesn't parse array format | High | Low | Test with one skill first |
| Context files too large | Medium | Low | Selected files are small (< 10KB each) |

## Success Criteria

- [ ] All 9 skills updated with targeted context arrays
- [ ] No `context: fork` remains in any skill file
- [ ] All context file paths are valid
- [ ] YAML frontmatter parses correctly in all files
- [ ] Each skill loads 1-3 domain-relevant context files

## Rollback Plan

If implementation fails:
1. Revert all skill files to use `context: fork`
2. Investigate context array parsing issues
3. Create issue for skill system updates if needed
