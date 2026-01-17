# Implementation Plan: Task #549 - Intelligent Model Routing Architecture

- **Task**: 549 - research_intelligent_model_routing_architecture
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Priority**: High
- **Dependencies**: Task 548 (skill-to-agent delegation pattern) - COMPLETED
- **Research Inputs**: specs/549_research_intelligent_model_routing_architecture/reports/research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Implement fixed model assignments for all 7 agents in `.claude/agents/` by adding the `model:` field to their YAML frontmatter. Based on research findings, Lean agents (lean-implementation-agent, lean-research-agent) will use Opus for complex theorem proving, while all other agents will remain on Sonnet. Haiku is explicitly avoided due to the tool_reference bug (GitHub #14863) affecting agents with many tools.

### Research Integration

Key findings from research-002.md integrated into this plan:
- Agent YAML frontmatter `model:` field is officially supported with values: opus, sonnet, haiku, inherit
- Task tool model parameter has a bug (GitHub #11682) causing 404 errors - use frontmatter instead
- Haiku fails with "tool_reference blocks not supported" when agents use many tools (GitHub #14863)
- Lean agents need maximum reasoning capability for theorem proving

## Goals & Non-Goals

**Goals**:
- Add explicit `model:` field to all 7 agent frontmatter files
- Assign Opus to lean-implementation-agent and lean-research-agent
- Assign Sonnet (explicitly) to remaining 5 agents for clarity
- Verify agents are recognized after modification

**Non-Goals**:
- Dynamic model selection based on task complexity (future task 551)
- Creating model-specific agent variants (deferred per research recommendation)
- Implementing Haiku for any agent (tool_reference bug makes it unsafe)
- Modifying skills (model selection is at agent layer)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Agent not discovered after adding model field | High | Low | Restart session after modifications; verify frontmatter YAML syntax |
| Opus costs significantly higher for Lean work | Medium | High | Monitor usage; can downgrade to Sonnet if quality sufficient |
| Frontmatter model field behavior changes in Claude Code updates | High | Low | Pin to specific model versions if needed; test after updates |
| YAML syntax errors in frontmatter | Medium | Low | Validate YAML syntax before saving; test agent invocation |

## Implementation Phases

### Phase 1: Add Model Field to Lean Agents [COMPLETED]

**Goal**: Configure Lean agents (implementation and research) to use Opus for maximum reasoning capability.

**Tasks**:
- [x] Read current lean-implementation-agent.md frontmatter
- [x] Add `model: opus` to lean-implementation-agent.md frontmatter
- [x] Read current lean-research-agent.md frontmatter
- [x] Add `model: opus` to lean-research-agent.md frontmatter

**Timing**: 30 minutes

**Files to modify**:
- `.claude/agents/lean-implementation-agent.md` - Add `model: opus` to frontmatter
- `.claude/agents/lean-research-agent.md` - Add `model: opus` to frontmatter

**Verification**:
- Frontmatter YAML syntax is valid
- Model field appears in frontmatter block between --- markers

---

### Phase 2: Add Model Field to Planning and Research Agents [COMPLETED]

**Goal**: Explicitly set Sonnet for planner and general research agents.

**Tasks**:
- [x] Read current planner-agent.md frontmatter
- [x] Add `model: sonnet` to planner-agent.md frontmatter
- [x] Read current general-research-agent.md frontmatter
- [x] Add `model: sonnet` to general-research-agent.md frontmatter

**Timing**: 30 minutes

**Files to modify**:
- `.claude/agents/planner-agent.md` - Add `model: sonnet` to frontmatter
- `.claude/agents/general-research-agent.md` - Add `model: sonnet` to frontmatter

**Verification**:
- Frontmatter YAML syntax is valid
- Model field appears in frontmatter block between --- markers

---

### Phase 3: Add Model Field to Implementation Agents [IN PROGRESS]

**Goal**: Explicitly set Sonnet for general, LaTeX, and meta-builder implementation agents.

**Tasks**:
- [ ] Read current general-implementation-agent.md frontmatter
- [ ] Add `model: sonnet` to general-implementation-agent.md frontmatter
- [ ] Read current latex-implementation-agent.md frontmatter
- [ ] Add `model: sonnet` to latex-implementation-agent.md frontmatter
- [ ] Read current meta-builder-agent.md frontmatter
- [ ] Add `model: sonnet` to meta-builder-agent.md frontmatter

**Timing**: 45 minutes

**Files to modify**:
- `.claude/agents/general-implementation-agent.md` - Add `model: sonnet` to frontmatter
- `.claude/agents/latex-implementation-agent.md` - Add `model: sonnet` to frontmatter
- `.claude/agents/meta-builder-agent.md` - Add `model: sonnet` to frontmatter

**Verification**:
- Frontmatter YAML syntax is valid
- Model field appears in frontmatter block between --- markers

---

### Phase 4: Verification and Documentation [NOT STARTED]

**Goal**: Verify all agents are properly configured and document the model tier assignments.

**Tasks**:
- [ ] List all agent files and verify model fields are present
- [ ] Create verification checklist showing all 7 agents with their model assignments
- [ ] Verify YAML frontmatter syntax is valid for all agents
- [ ] Update implementation summary with cost impact analysis from research

**Timing**: 45 minutes

**Files to verify**:
- `.claude/agents/lean-implementation-agent.md` - model: opus
- `.claude/agents/lean-research-agent.md` - model: opus
- `.claude/agents/planner-agent.md` - model: sonnet
- `.claude/agents/general-research-agent.md` - model: sonnet
- `.claude/agents/general-implementation-agent.md` - model: sonnet
- `.claude/agents/latex-implementation-agent.md` - model: sonnet
- `.claude/agents/meta-builder-agent.md` - model: sonnet

**Verification**:
- All 7 agents have explicit model field
- Lean agents use opus, others use sonnet
- No YAML syntax errors

## Testing & Validation

- [ ] Verify all 7 agent files contain valid YAML frontmatter with model field
- [ ] Check that model values are one of: opus, sonnet (no haiku per research)
- [ ] Session restart may be required for agent registration to take effect
- [ ] Run a simple /plan command to verify planner-agent works with explicit model
- [ ] Document any behavioral differences observed

## Artifacts & Outputs

- Modified agent files (7 files in `.claude/agents/`)
- Implementation summary: `specs/549_research_intelligent_model_routing_architecture/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If model field causes issues:
1. Remove the `model:` line from affected agent frontmatter
2. Agents will revert to default Sonnet behavior
3. Git revert the changes if widespread issues occur:
   ```
   git revert HEAD~N  # where N is the number of commits to revert
   ```
4. Re-evaluate research findings and GitHub issues for updates
