# Implementation Plan: Task #414

- **Task**: 414 - Create planner-agent subagent with lazy context
- **Status**: [NOT STARTED]
- **Effort**: 2-3 hours
- **Priority**: Low
- **Dependencies**: 410
- **Research Inputs**: [research-001.md](../reports/research-001.md)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Create the `planner-agent.md` subagent file that integrates with the existing `skill-planner`. The agent will load plan-format.md and task-breakdown.md on-demand, analyze task requirements and research, decompose work into phases, and return structured JSON matching subagent-return.md schema.

### Research Integration

- research-001.md: Agent structure pattern, context files to load, return format requirements

## Goals & Non-Goals

**Goals**:
- Create planner-agent.md following established agent patterns
- Implement lazy context loading for plan-format.md and task-breakdown.md
- Return valid JSON matching subagent-return.md schema
- Support integration with existing skill-planner

**Non-Goals**:
- Modifying skill-planner (already complete)
- Adding new planning features beyond basic phase decomposition
- Supporting Lean-specific planning (general planner only)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Agent doesn't match return schema | High | Low | Use explicit return format examples from research |
| Missing context loading instructions | Medium | Low | Follow general-research-agent pattern |
| Phase granularity too coarse/fine | Medium | Medium | Apply task-breakdown.md guidelines explicitly |

## Implementation Phases

### Phase 1: Create Agent File Structure [COMPLETED]

**Goal**: Create planner-agent.md with metadata, overview, and allowed tools sections

**Tasks**:
- [ ] Create `.claude/agents/planner-agent.md` file
- [ ] Add Overview section describing planning purpose
- [ ] Add Agent Metadata section (name, purpose, invoked by, return format)
- [ ] Add Allowed Tools section (Read, Write, Edit, Glob, Grep)
- [ ] Add Context References section with @-references

**Timing**: 30 minutes

**Files to modify**:
- `.claude/agents/planner-agent.md` - Create new file

**Verification**:
- File exists with correct structure
- Metadata matches skill-planner expectations

---

### Phase 2: Implement Execution Flow [COMPLETED]

**Goal**: Define the 6-stage execution flow for plan creation

**Tasks**:
- [ ] Stage 1: Parse delegation context (extract task_context, metadata, research_path)
- [ ] Stage 2: Load research report (if exists, read and analyze findings)
- [ ] Stage 3: Analyze task scope and complexity (simple/medium/complex)
- [ ] Stage 4: Decompose into phases using task-breakdown guidelines
- [ ] Stage 5: Create plan file following plan-format.md structure
- [ ] Stage 6: Return structured JSON

**Timing**: 45 minutes

**Dependencies**: Phase 1 complete

**Verification**:
- All 6 stages documented with clear inputs/outputs
- Phase decomposition logic follows task-breakdown.md

---

### Phase 3: Add Error Handling [COMPLETED]

**Goal**: Document error scenarios and recovery strategies

**Tasks**:
- [ ] Handle invalid task (not found, wrong status)
- [ ] Handle missing research (proceed with task description only)
- [ ] Handle timeout/interruption (save partial progress)
- [ ] Handle file operation failures

**Timing**: 20 minutes

**Dependencies**: Phase 2 complete

**Verification**:
- All error scenarios covered
- Recovery strategies documented

---

### Phase 4: Add Return Format Examples [COMPLETED]

**Goal**: Provide concrete JSON examples for completed/partial/failed returns

**Tasks**:
- [ ] Add completed example with plan artifact and metadata
- [ ] Add partial example (timeout during plan creation)
- [ ] Add failed example (invalid task or status)
- [ ] Add Critical Requirements section (MUST DO / MUST NOT)

**Timing**: 30 minutes

**Dependencies**: Phase 3 complete

**Verification**:
- All examples are valid JSON
- Examples match subagent-return.md schema
- Metadata includes phase_count and estimated_hours

---

### Phase 5: Verification and Testing [COMPLETED]

**Goal**: Verify agent integrates correctly with skill-planner

**Tasks**:
- [ ] Verify file structure matches other agents
- [ ] Check all @-references are valid paths
- [ ] Verify return format matches skill-planner expectations
- [ ] Run syntax check (markdown linting if available)

**Timing**: 15 minutes

**Dependencies**: Phase 4 complete

**Verification**:
- Agent file passes structure review
- No broken references
- Ready for integration testing

## Testing & Validation

- [ ] File exists at `.claude/agents/planner-agent.md`
- [ ] Structure matches existing agent patterns (general-research-agent.md)
- [ ] All @-references point to existing context files
- [ ] Return format examples are valid JSON
- [ ] Metadata fields match skill-planner expectations

## Artifacts & Outputs

- `.claude/agents/planner-agent.md` - Main deliverable
- `specs/414_create_planner_agent_subagent/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If implementation fails:
1. Delete `.claude/agents/planner-agent.md` if partially created
2. skill-planner continues to reference non-existent agent (fails gracefully)
3. Can retry implementation from any phase
