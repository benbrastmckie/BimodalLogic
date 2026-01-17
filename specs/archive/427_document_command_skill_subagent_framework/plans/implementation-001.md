# Implementation Plan: Task #427

**Task**: Document command, skill, and subagent framework
**Version**: 001
**Created**: 2026-01-12
**Language**: meta

## Overview

This plan addresses the documentation gaps identified in the research phase by creating new guides, updating existing documentation, and adding practical integration examples. The focus is on making the three-layer architecture (commands, skills, agents) accessible to both users and developers.

## Phases

### Phase 1: Create Component Selection Guide

**Estimated effort**: 45 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Help users decide when to create commands vs skills vs agents
2. Provide clear decision tree for capability development
3. Explain component responsibilities and relationships

**Files to create**:
- `.claude/docs/guides/component-selection.md`

**Steps**:
1. Create decision tree for component type selection
2. Document when each component type is appropriate
3. Explain the three-layer architecture with diagrams
4. Add examples showing component selection reasoning
5. Include anti-patterns and common mistakes

**Verification**:
- [ ] Decision tree is clear and actionable
- [ ] All three component types covered
- [ ] Includes practical examples
- [ ] Links to related documentation

---

### Phase 2: Create Skill Creation Guide

**Estimated effort**: 45 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Document the thin wrapper skill pattern
2. Explain context: fork for token efficiency
3. Provide step-by-step skill creation instructions

**Files to create**:
- `.claude/docs/guides/creating-skills.md`

**Steps**:
1. Explain thin wrapper pattern and its benefits
2. Document SKILL.md frontmatter format
3. Explain context: fork pattern for lazy loading
4. Document return validation requirements
5. Provide complete example based on existing skill
6. List common mistakes and how to avoid them

**Verification**:
- [ ] Thin wrapper pattern clearly explained
- [ ] Frontmatter specification complete
- [ ] Working example included
- [ ] Validation requirements documented

---

### Phase 3: Create Agent Creation Guide

**Estimated effort**: 45 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Expand on existing agent template with step-by-step guide
2. Document subagent return format requirements
3. Explain delegation depth and path

**Files to create**:
- `.claude/docs/guides/creating-agents.md`

**Steps**:
1. Document agent file structure and location
2. Explain 8-stage workflow (from template)
3. Detail subagent return format with examples
4. Document delegation context parameters
5. Explain relationship between skill and agent
6. Add testing and validation checklist

**Verification**:
- [ ] All 8 stages documented
- [ ] Return format specification complete
- [ ] Delegation patterns explained
- [ ] Testing guidance provided

---

### Phase 4: Create Integration Examples

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Show end-to-end flow through all three layers
2. Document language-based routing in practice
3. Demonstrate artifact creation and return flow

**Files to create**:
- `.claude/docs/examples/research-flow-example.md`

**Steps**:
1. Document /research 427 command flow end-to-end
2. Show orchestrator routing logic
3. Document skill delegation to agent
4. Show agent execution and artifact creation
5. Document return propagation back through layers

**Verification**:
- [ ] Complete flow documented
- [ ] All three layers shown
- [ ] Actual file paths referenced
- [ ] Routing decision points clear

---

### Phase 5: Update Existing Documentation

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Update README.md with current counts and links
2. Fix outdated path references
3. Add cross-references between documents

**Files to modify**:
- `.claude/docs/README.md` - Add skill/agent counts, link to new guides
- `.claude/docs/guides/creating-commands.md` - Fix path references, add skill delegation reference
- `.claude/docs/templates/README.md` - Add skill template reference

**Steps**:
1. Update README.md with current skill count (9) and agent count (6)
2. Fix path references from `.claude/agent/` to `.claude/agents/`
3. Fix path references from `.claude/command/` to `.claude/commands/`
4. Add links to new guides in documentation map
5. Update templates README to reference skill template
6. Add cross-references between related guides

**Verification**:
- [ ] All path references correct
- [ ] Current component counts accurate
- [ ] New guides linked in README
- [ ] Cross-references added

---

### Phase 6: Update Context Index

**Estimated effort**: 20 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Add documentation guides to context index
2. Improve discoverability of skill/agent documentation

**Files to modify**:
- `.claude/context/index.md` - Add documentation section

**Steps**:
1. Add new "Documentation Guides" section to context index
2. List new guides with descriptions
3. Cross-reference with core templates
4. Verify index organization

**Verification**:
- [ ] New guides listed in index
- [ ] Descriptions are helpful
- [ ] Related context cross-referenced

---

## Dependencies

- Research report (completed): `specs/427_document_command_skill_subagent_framework/reports/research-001.md`
- Existing documentation in `.claude/docs/`
- Existing templates in `.claude/docs/templates/`
- Existing context in `.claude/context/core/`

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Documentation drift from implementation | Medium | Use real file paths and task numbers in examples |
| Incomplete coverage of edge cases | Low | Focus on common patterns, reference advanced docs |
| Outdated examples over time | Medium | Use stable task numbers and patterns |
| Inconsistency with existing docs | Medium | Cross-reference existing documentation |

## Success Criteria

- [ ] Component selection guide provides clear decision tree
- [ ] Skill creation guide enables independent skill development
- [ ] Agent creation guide explains all workflow stages
- [ ] Integration example shows complete flow
- [ ] All existing documentation updated with correct paths
- [ ] Context index includes new documentation
- [ ] No broken cross-references

## Artifact Summary

**New Files**:
- `.claude/docs/guides/component-selection.md`
- `.claude/docs/guides/creating-skills.md`
- `.claude/docs/guides/creating-agents.md`
- `.claude/docs/examples/research-flow-example.md`

**Modified Files**:
- `.claude/docs/README.md`
- `.claude/docs/guides/creating-commands.md`
- `.claude/docs/templates/README.md`
- `.claude/context/index.md`

## Estimated Total Effort

3-4 hours (matches original task estimate)
