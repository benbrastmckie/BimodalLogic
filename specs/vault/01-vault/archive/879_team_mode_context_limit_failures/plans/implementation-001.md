# Implementation Plan: Task #879

- **Task**: 879 - Investigate and fix team mode context limit failures
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: specs/879_team_mode_context_limit_failures/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This plan addresses context limit failures in team mode by implementing four mitigations identified in research: (1) updating the planner agent to split phases exceeding 60 minutes, (2) adding context-efficiency guidance to lean-implementation-agent, (3) documenting context limits as a known failure mode in error-handling.md, and (4) implementing single-agent fallback for complex phases in skill-team-implement.

### Research Integration

Key findings from research-001.md integrated into this plan:
- Root cause: Lean implementation consumes ~150k+ tokens for multi-hour phases
- lean_goal calls after every tactic is primary context consumer
- Teammates cannot use /compact during execution
- Phase chunking (30-60 min sub-phases) is the recommended primary mitigation

## Goals & Non-Goals

**Goals**:
- Enable successful team mode execution for complex Lean tasks
- Reduce context exhaustion risk through phase chunking guidelines
- Add agent-level context efficiency guidance
- Document context limits as known failure mode with recovery patterns
- Implement fallback logic for phases that exceed safe context budgets

**Non-Goals**:
- Modifying Claude Code's context management internals
- Implementing automatic /compact for teammates (not possible)
- Guaranteeing zero context exhaustion (fundamental constraint)
- Changing the Lean proof workflow (e.g., reducing lean_goal calls)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase chunking increases planning complexity | Medium | Medium | Add clear guidelines with examples |
| Context efficiency guidance reduces proof quality | Medium | Low | Make guidance advisory, not mandatory |
| Fallback logic adds team mode complexity | Low | Medium | Keep logic simple and well-documented |
| Changes break existing workflows | Medium | Low | Test with actual task before deployment |

## Implementation Phases

### Phase 1: Update Planner Agent for Phase Chunking [NOT STARTED]

- **Dependencies**: None
- **Goal**: Ensure the planner agent splits phases that would exceed context budgets

**Tasks**:
- [ ] Update planner-agent.md to include phase chunking guidance
- [ ] Add context consumption estimation heuristics
- [ ] Define 60-minute threshold rule for phase splitting
- [ ] Add examples of multi-hour phase decomposition

**Timing**: 1 hour

**Files to modify**:
- `.claude/agents/planner-agent.md` - Add phase chunking section with guidelines

**Verification**:
- Planner agent documentation includes explicit 60-minute phase threshold
- Examples demonstrate splitting multi-hour work into sub-phases
- Guidelines reference context budget considerations

---

### Phase 2: Add Context Efficiency Guidance to Lean Implementation Agent [NOT STARTED]

- **Dependencies**: None
- **Goal**: Help Lean implementation agents operate within context budgets

**Tasks**:
- [ ] Add "Context Management" section to lean-implementation-agent.md
- [ ] Include guidelines for minimizing lean_goal calls (batch per tactic block)
- [ ] Add guidance on lean_multi_attempt for batched exploration
- [ ] Add guidance on targeted file reads (line ranges instead of full files)
- [ ] Include instruction to save progress frequently and return partial when approaching limit

**Timing**: 1 hour

**Files to modify**:
- `.claude/agents/lean-implementation-agent.md` - Add context management section

**Verification**:
- Lean implementation agent has explicit context efficiency guidelines
- Guidelines are advisory (recommendations, not hard requirements)
- Partial progress and return patterns are documented

---

### Phase 3: Document Context Limits in Error Handling [NOT STARTED]

- **Dependencies**: None
- **Goal**: Document context exhaustion as a known teammate failure mode with recovery patterns

**Tasks**:
- [ ] Add "Context Limit Failures" section to error-handling.md
- [ ] Document that teammates cannot use /compact during execution
- [ ] Describe the [PARTIAL] status recovery pattern
- [ ] Add guidance for lead agent to resume from partial progress
- [ ] Include link to research findings for deeper understanding

**Timing**: 45 minutes

**Files to modify**:
- `.claude/rules/error-handling.md` - Add context limit failure section

**Verification**:
- Error handling documentation covers context limits as known failure mode
- Recovery pattern (mark partial, resume single-agent) is clearly documented
- Guidance distinguishes between agent bugs and fundamental constraints

---

### Phase 4: Implement Single-Agent Fallback for Complex Phases [NOT STARTED]

- **Dependencies**: Phase 1, Phase 2
- **Goal**: Update skill-team-implement to route complex phases to single agent

**Tasks**:
- [ ] Review current skill-team-implement wave generation logic
- [ ] Add effort-based routing check (phases > 4 hours get special handling)
- [ ] Implement documentation for when single-agent is preferred
- [ ] Update team-wave-helpers.md with fallback patterns
- [ ] Add advisory prompt text for team leads about complex phases

**Timing**: 1.25 hours

**Files to modify**:
- `.claude/skills/skill-team-implement/SKILL.md` - Add complex phase handling guidance
- `.claude/utils/team-wave-helpers.md` - Add fallback patterns section

**Verification**:
- Skill documentation includes guidance for complex phase handling
- Team leads know when to consider single-agent fallback
- Patterns documented for recoverable team mode failures

---

## Testing & Validation

- [ ] Read updated planner-agent.md and verify phase chunking guidelines are clear
- [ ] Read updated lean-implementation-agent.md and verify context efficiency guidance is present
- [ ] Read updated error-handling.md and verify context limit documentation is complete
- [ ] Read updated skill-team-implement and team-wave-helpers for fallback patterns
- [ ] Dry-run: Manually verify that `/plan` with multi-hour phases would be split per new guidelines

## Artifacts & Outputs

- Updated `.claude/agents/planner-agent.md` with phase chunking guidance
- Updated `.claude/agents/lean-implementation-agent.md` with context management section
- Updated `.claude/rules/error-handling.md` with context limit failure documentation
- Updated `.claude/skills/skill-team-implement/SKILL.md` with complex phase handling
- Updated `.claude/utils/team-wave-helpers.md` with fallback patterns

## Rollback/Contingency

All changes are documentation-only additions to existing files. If issues arise:
1. Revert specific commits via `git revert`
2. No functional code changes mean no runtime breakage risk
3. Previous behavior remains valid; new guidance is additive

## Success Criteria

- [ ] Planner agent guidelines prevent creation of phases > 60 minutes for Lean work
- [ ] Lean implementation agents have actionable context efficiency guidance
- [ ] Error handling documentation covers teammate context exhaustion
- [ ] Team mode skill includes guidance for complex phase fallback
- [ ] All changes are pure documentation updates (no code changes)
