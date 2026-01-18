# Implementation Plan: Task #591

- **Task**: 591 - Find and Fix Double Forking in Skill-Agent Delegation
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/591_find_fix_double_forking/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This task removes redundant `context: fork` and `agent:` fields from 8 thin wrapper skills that already use the Task tool for delegation. Research confirmed there is no harmful double forking, but the current configuration creates unnecessary context overhead (~100 tokens per invocation). The fix follows Option A from research: remove `context: fork` while keeping explicit Task tool delegation.

### Research Integration

Key findings from research-001.md:
- `context: fork` creates an isolated conversation context, NOT a subprocess
- When combined with Task tool invocation, this creates redundant context layers
- All 8 forked skills (skill-researcher, skill-lean-research, skill-planner, skill-implementer, skill-lean-implementation, skill-latex-implementation, skill-meta, skill-document-converter) are redundant
- Removing `context: fork` eliminates ~100 token overhead per skill invocation
- Bug #17283 (context: fork not working) is now fixed, but Option A remains preferred for explicit delegation

## Goals & Non-Goals

**Goals**:
- Remove `context: fork` and `agent:` fields from all 8 redundant thin wrapper skills
- Update CLAUDE.md documentation to reflect the change
- Verify no regression in skill behavior after changes

**Non-Goals**:
- Modifying agent files (agents remain unchanged)
- Changing the Task tool invocation pattern in skill instructions
- Implementing Option B (keep context: fork, remove Task tool)
- Modifying skills without context: fork (skill-status-sync, skill-orchestrator, skill-git-workflow)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Skill behavior change after removing context: fork | Medium | Low | Test each skill after modification |
| Skill instructions execute in main context instead of isolated | Low | Medium | Skill instructions are minimal (~100 tokens), acceptable overhead |
| Future Claude Code updates change context: fork behavior | Low | Low | Document decision and rationale for future reference |
| Incomplete testing misses regression | Medium | Low | Test all 8 skills with actual task operations |

## Implementation Phases

### Phase 1: Update Research and Implementation Skills [NOT STARTED]

**Goal**: Remove redundant frontmatter from research and implementation delegation skills

**Tasks**:
- [ ] Update skill-researcher/SKILL.md - remove `context: fork` and `agent:` lines
- [ ] Update skill-lean-research/SKILL.md - remove `context: fork` and `agent:` lines
- [ ] Update skill-implementer/SKILL.md - remove `context: fork` and `agent:` lines
- [ ] Update skill-lean-implementation/SKILL.md - remove `context: fork` and `agent:` lines
- [ ] Update skill-latex-implementation/SKILL.md - remove `context: fork` and `agent:` lines

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-researcher/SKILL.md` - remove 2 frontmatter fields
- `.claude/skills/skill-lean-research/SKILL.md` - remove 2 frontmatter fields
- `.claude/skills/skill-implementer/SKILL.md` - remove 2 frontmatter fields
- `.claude/skills/skill-lean-implementation/SKILL.md` - remove 2 frontmatter fields
- `.claude/skills/skill-latex-implementation/SKILL.md` - remove 2 frontmatter fields

**Verification**:
- Each skill file has valid YAML frontmatter (no syntax errors)
- Each skill file retains `allowed-tools: Task`
- No `context: fork` or `agent:` fields remain in modified files

---

### Phase 2: Update Planner and Meta Skills [NOT STARTED]

**Goal**: Remove redundant frontmatter from planning and system building skills

**Tasks**:
- [ ] Update skill-planner/SKILL.md - remove `context: fork` and `agent:` lines
- [ ] Update skill-meta/SKILL.md - remove `context: fork` and `agent:` lines
- [ ] Update skill-document-converter/SKILL.md - remove `context: fork` and `agent:` lines

**Timing**: 20 minutes

**Files to modify**:
- `.claude/skills/skill-planner/SKILL.md` - remove 2 frontmatter fields
- `.claude/skills/skill-meta/SKILL.md` - remove 2 frontmatter fields
- `.claude/skills/skill-document-converter/SKILL.md` - remove 2 frontmatter fields

**Verification**:
- Each skill file has valid YAML frontmatter
- Each skill file retains `allowed-tools: Task`
- No `context: fork` or `agent:` fields remain in modified files

---

### Phase 3: Update Documentation [NOT STARTED]

**Goal**: Update CLAUDE.md to reflect the architectural change

**Tasks**:
- [ ] Update "Forked Subagent Pattern" section in CLAUDE.md
- [ ] Remove references to `context: fork` for thin wrapper skills
- [ ] Clarify that thin wrappers use Task tool directly without context: fork
- [ ] Document when `context: fork` IS appropriate (skills that do work directly, not delegate)

**Timing**: 30 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - update Skill Architecture section

**Verification**:
- Documentation accurately describes current architecture
- No stale references to `context: fork` for thin wrapper skills
- Clear guidance on when to use vs. not use context: fork

---

### Phase 4: Verification Testing [NOT STARTED]

**Goal**: Verify all modified skills still function correctly

**Tasks**:
- [ ] Test skill-planner by examining skill file loads without error
- [ ] Test skill-researcher by verifying frontmatter is valid
- [ ] Test skill-lean-research by verifying frontmatter is valid
- [ ] Test skill-implementer by verifying frontmatter is valid
- [ ] Test skill-lean-implementation by verifying frontmatter is valid
- [ ] Test skill-latex-implementation by verifying frontmatter is valid
- [ ] Test skill-meta by verifying frontmatter is valid
- [ ] Test skill-document-converter by verifying frontmatter is valid
- [ ] Grep all skill files to confirm no `context: fork` remains in modified files

**Timing**: 30 minutes

**Verification**:
- All 8 skill files have valid YAML frontmatter (parseable)
- Grep confirms no `context: fork` in the 8 modified skill files
- Grep confirms `allowed-tools: Task` present in all 8 files

---

## Testing & Validation

- [ ] YAML frontmatter parses without errors in all 8 modified skill files
- [ ] No `context: fork` appears in any of the 8 modified skill files
- [ ] All 8 modified skills retain `allowed-tools: Task`
- [ ] CLAUDE.md Skill Architecture section accurately reflects changes
- [ ] Git diff shows only frontmatter field removals, no instruction changes

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (created on completion)
- Modified files:
  - `.claude/skills/skill-researcher/SKILL.md`
  - `.claude/skills/skill-lean-research/SKILL.md`
  - `.claude/skills/skill-planner/SKILL.md`
  - `.claude/skills/skill-implementer/SKILL.md`
  - `.claude/skills/skill-lean-implementation/SKILL.md`
  - `.claude/skills/skill-latex-implementation/SKILL.md`
  - `.claude/skills/skill-meta/SKILL.md`
  - `.claude/skills/skill-document-converter/SKILL.md`
  - `.claude/CLAUDE.md`

## Rollback/Contingency

If skills malfunction after changes:
1. Restore `context: fork` and `agent:` fields to affected skill files
2. Git revert the commit if needed: `git revert HEAD`
3. Log issue in errors.json for investigation
4. Consider Option B (keep context: fork, remove Task tool) as alternative approach

The changes are isolated to frontmatter fields and can be easily reverted by re-adding the two removed lines to each skill file.
