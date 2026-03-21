# Implementation Plan: Task #535

**Task**: Refactor Heavy-Lifting Agents to Use Sonnet
**Version**: 001
**Created**: 2026-01-17
**Language**: meta
**Session ID**: sess_1768660008_6b7162

## Overview

Add explicit `model: sonnet` field to all 7 heavy-lifting agent YAML frontmatter files based on Task 534 research findings. This makes model selection explicit and ensures consistent behavior.

## Research Basis

From Task 534 (research-001.md):
- Agent YAML frontmatter supports `model` field with values: sonnet, opus, haiku, inherit
- Default is sonnet when omitted (making this change explicit but not behavioral)
- Known bug: Task tool's `model` parameter may be ignored, so frontmatter is the reliable method

## Phases

### Phase 1: Add Model Field to All Agents

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Add `model: sonnet` to all 7 agent frontmatter files

**Files to modify**:
- `.claude/agents/meta-builder-agent.md` - Add model: sonnet
- `.claude/agents/planner-agent.md` - Add model: sonnet
- `.claude/agents/general-research-agent.md` - Add model: sonnet
- `.claude/agents/lean-research-agent.md` - Add model: sonnet
- `.claude/agents/lean-implementation-agent.md` - Add model: sonnet
- `.claude/agents/latex-implementation-agent.md` - Add model: sonnet
- `.claude/agents/general-implementation-agent.md` - Add model: sonnet

**Steps**:
1. Edit each agent file to add `model: sonnet` after the `description` field in YAML frontmatter

**Verification**:
- Each file has valid YAML frontmatter with model field
- No syntax errors in frontmatter

---

## Dependencies

- Task 534 (completed) - Research findings on model selection

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| YAML syntax error | Agent not recognized | Verify frontmatter syntax after each edit |
| Behavioral change | Low | Sonnet is already default, making explicit |

## Success Criteria

- [ ] All 7 agents have explicit `model: sonnet` in frontmatter
- [ ] YAML syntax is valid in all files
- [ ] No errors when listing agents
