# Implementation Plan: Task #619

- **Task**: 619 - agent_system_architecture_upgrade
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/619_agent_system_architecture_upgrade/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Incremental upgrade to the ProofChecker agent system architecture focusing on progressive disclosure, enhanced metadata passing, and reduced context window pollution. The current system works well; this plan preserves working patterns while adopting improvements from 2026 Claude Code best practices.

### Research Integration

Key findings from research-001.md integrated into this plan:
- CLAUDE.md reduction from 385 to ~100 lines (Priority 1)
- state.json schema enhancement for delegation context (Priority 2)
- Skill description improvements for better trigger matching (Priority 4)
- Documentation cleanup removing invalid "context: fork" references (Priority 5)
- Native subagent adoption deferred (Priority 3) as optional future enhancement

## Goals & Non-Goals

**Goals**:
- Reduce CLAUDE.md from 385 lines to ~100 lines
- Enhance state.json with delegation context for recovery
- Improve skill descriptions for better trigger matching
- Remove references to non-existent "context: fork" feature
- Create quick-reference.md for detailed command information

**Non-Goals**:
- Full migration to native Claude Code subagent patterns (future work)
- Restructuring the three-layer architecture (working well)
- Changes to Lean 4 or core project files

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| CLAUDE.md too minimal loses context | Medium | Medium | Test with common workflows before committing |
| state.json schema breaks existing tools | High | Low | Additive changes only, no field removals |
| Skill description changes cause routing issues | Medium | Low | Test each skill individually after changes |
| Documentation inconsistencies after cleanup | Low | Medium | Grep for all context:fork references |

## Implementation Phases

### Phase 1: CLAUDE.md Minimization [NOT STARTED]

**Goal**: Reduce CLAUDE.md from 385 lines to ~100 lines by extracting detailed content to reference files.

**Tasks**:
- [ ] Create `.claude/context/core/quick-reference.md` with detailed command info
- [ ] Extract skill-to-agent mapping table to system-overview.md (already has partial)
- [ ] Extract session maintenance section to quick-reference.md
- [ ] Extract git commit conventions to quick-reference.md (keep reference in CLAUDE.md)
- [ ] Rewrite CLAUDE.md with minimal essential content (~50-100 lines)
- [ ] Verify all extracted content is accessible via @-references

**Timing**: 1.5 hours

**Files to modify**:
- `.claude/CLAUDE.md` - Reduce to minimal version
- `.claude/context/core/quick-reference.md` - Create with extracted content
- `.claude/context/core/architecture/system-overview.md` - Add any missing tables

**Verification**:
- CLAUDE.md is under 100 lines
- All commands documented in quick-reference.md
- Agent can find detailed info via @-references

---

### Phase 2: state.json Schema Enhancement [NOT STARTED]

**Goal**: Add delegation context fields to state.json for improved recovery and debugging.

**Tasks**:
- [ ] Design enhanced task entry schema with delegation_context and execution_trace
- [ ] Update `.claude/rules/state-management.md` with new schema documentation
- [ ] Add session field to track active operation checkpoint
- [ ] Add recovery field for resume point information
- [ ] Update skill-status-sync to write new fields during operations
- [ ] Test recovery by interrupting an operation and resuming

**Timing**: 1.5 hours

**Files to modify**:
- `.claude/rules/state-management.md` - Document new schema fields
- `.claude/skills/skill-status-sync/SKILL.md` - Update to write new fields
- `specs/state.json` - Will receive new fields during operations (no manual edit)

**Verification**:
- state.json entries include delegation_context when operations are in progress
- Interrupted operations can be resumed using recovery information
- Schema documentation matches actual behavior

---

### Phase 3: Skill Description Improvements [NOT STARTED]

**Goal**: Update skill descriptions to be more specific for better trigger matching.

**Tasks**:
- [ ] Audit all 12 skill descriptions for specificity
- [ ] Update skill-researcher description with language triggers
- [ ] Update skill-lean-research description with Lean-specific triggers
- [ ] Update skill-planner description with planning triggers
- [ ] Update skill-implementer description with implementation triggers
- [ ] Update remaining skill descriptions following third-person pattern
- [ ] Verify descriptions are under 100 words each

**Timing**: 1 hour

**Files to modify**:
- `.claude/skills/skill-researcher/SKILL.md` - Update description
- `.claude/skills/skill-lean-research/SKILL.md` - Update description
- `.claude/skills/skill-planner/SKILL.md` - Update description
- `.claude/skills/skill-implementer/SKILL.md` - Update description
- `.claude/skills/skill-lean-implementation/SKILL.md` - Update description
- `.claude/skills/skill-latex-implementation/SKILL.md` - Update description
- `.claude/skills/skill-meta/SKILL.md` - Update description
- `.claude/skills/skill-document-converter/SKILL.md` - Update description

**Verification**:
- All descriptions follow third-person pattern
- Descriptions include specific trigger conditions
- Each description under 100 words

---

### Phase 4: Documentation Cleanup [NOT STARTED]

**Goal**: Remove invalid "context: fork" references and clarify subagent delegation pattern.

**Tasks**:
- [ ] Search for all "context: fork" and "context:fork" references in .claude/
- [ ] Update thin-wrapper-skill.md to remove context:fork mentions
- [ ] Update system-overview.md if it mentions context forking
- [ ] Add clarification that subagent context isolation comes from Task tool delegation
- [ ] Verify no documentation references non-existent frontmatter fields

**Timing**: 0.5 hours

**Files to modify**:
- `.claude/context/core/patterns/thin-wrapper-skill.md` - Remove context:fork
- `.claude/context/core/architecture/system-overview.md` - Clarify delegation
- Any other files found by grep search

**Verification**:
- `grep -r "context.*fork" .claude/` returns no results
- Documentation accurately describes Task tool delegation

---

### Phase 5: Verification and Testing [NOT STARTED]

**Goal**: Validate all changes work together and the system functions correctly.

**Tasks**:
- [ ] Test /research command with lean and general tasks
- [ ] Test /plan command creates valid plans
- [ ] Test /implement command resumes correctly
- [ ] Verify agent can find context via @-references
- [ ] Check CLAUDE.md provides sufficient context for common operations
- [ ] Document any adjustments needed based on testing

**Timing**: 0.5 hours

**Files to modify**:
- Any files needing adjustments based on testing

**Verification**:
- All workflow commands execute successfully
- No missing context errors during operations
- Recovery from interruption works with new state.json fields

---

## Testing & Validation

- [ ] CLAUDE.md under 100 lines and provides essential context
- [ ] Quick-reference.md accessible and contains detailed command info
- [ ] state.json accepts new delegation_context fields
- [ ] All skill descriptions follow third-person pattern
- [ ] No "context: fork" references remain in documentation
- [ ] /research, /plan, /implement commands work correctly
- [ ] Interrupted operations can resume using recovery info

## Artifacts & Outputs

- `.claude/CLAUDE.md` - Minimized version (~100 lines)
- `.claude/context/core/quick-reference.md` - New detailed reference file
- `.claude/rules/state-management.md` - Updated schema documentation
- `.claude/skills/*/SKILL.md` - Updated descriptions (8 files)
- `.claude/context/core/patterns/thin-wrapper-skill.md` - Cleaned up
- `.claude/context/core/architecture/system-overview.md` - Clarifications added

## Rollback/Contingency

All changes are incremental and can be reverted individually:
- CLAUDE.md changes: git revert the specific commit
- state.json schema: additive only, no breaking changes
- Skill descriptions: can be reverted per-file
- Documentation: can be reverted per-file

If the minimized CLAUDE.md proves insufficient, content can be restored from quick-reference.md by adding @-references back to CLAUDE.md.
