# Implementation Plan: Task #944

- **Task**: 944 - add_roadmap_reflection_research_agents
- **Status**: [IMPLEMENTING]
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/944_add_roadmap_reflection_research_agents/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This task adds ROAD_MAP.md reflection to three research agents (lean, logic, math) to prevent recommending approaches documented as dead ends. The implementation inserts Stage 2.5 into the agent execution flows, adds pitfall checking logic, and creates a reusable pattern document for future agents. Research report at specs/944_add_roadmap_reflection_research_agents/reports/research-001.md provides Stage 2.5 content templates and detailed file locations.

### Research Integration

Key findings integrated from research-001.md:
- Three agents share similar stage structure but differ in flow embedding (lean delegates to flow file; logic/math embed full flow)
- ROAD_MAP.md has well-structured Strategies (lines 23-147) and Dead Ends (lines 293-520) sections with 5 strategies and 8 dead ends
- Stage 2.5 should be inserted between Stage 2 (Analyze Task) and Stage 3 (Execute Searches)
- Report template should include "ROAD_MAP.md Reflection" section for pitfall tracking

## Goals & Non-Goals

**Goals**:
- Add Stage 2.5 to lean-research-flow.md, logic-research-agent.md, and math-research-agent.md
- Enable agents to check ROAD_MAP.md Dead Ends before recommending approaches
- Add report section for documenting pitfall matches and strategy alignment
- Create reusable documentation pattern at `.claude/context/core/patterns/roadmap-reflection-pattern.md`

**Non-Goals**:
- Adding reflection to general-research-agent (no domain-specific pitfalls)
- Creating automated pitfall matching (manual keyword search is sufficient)
- Modifying ROAD_MAP.md structure itself

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| ROAD_MAP.md becomes large, increasing context usage | Medium | Medium | Only load Strategies and Dead Ends sections (lines 23-520) |
| False positive keyword matches | Low | Medium | Use keyword matching with context; allow override in report |
| Agent ignores reflection step | Medium | Low | Add to MUST DO critical requirements; verify in report template |
| Stage numbering confusion | Low | Low | Use 2.5 naming to avoid renumbering existing stages |

## Implementation Phases

### Phase 1: Create Documentation Pattern [COMPLETED]

- **Dependencies:** None
- **Goal:** Create reusable roadmap reflection pattern document for agent onboarding

**Tasks**:
- [ ] Create `.claude/context/core/patterns/roadmap-reflection-pattern.md`
- [ ] Document pattern purpose, when to apply, and integration points
- [ ] Include example keyword matching for Dead Ends
- [ ] Reference Stage 2.5 locations in each agent type

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/core/patterns/roadmap-reflection-pattern.md` - NEW FILE

**Verification**:
- File exists and contains purpose, pattern steps, and integration points
- Pattern is self-contained and understandable without other context

---

### Phase 2: Add Stage 2.5 to lean-research-flow.md [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Insert roadmap reflection stage into lean research execution flow

**Tasks**:
- [ ] Read lean-research-flow.md to find exact insertion point (after Stage 2, before Stage 3)
- [ ] Insert Stage 2.5: ROAD_MAP.md Reflection section with:
  - Load instruction for specs/ROAD_MAP.md (Strategies and Dead Ends sections)
  - Dead Ends keyword scanning procedure
  - Strategies relevance check procedure
  - Pitfall filter application logic
  - Example check showing dead end match
- [ ] Update Stage 3 header comment if needed to reference Stage 2.5

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/project/lean4/agents/lean-research-flow.md` - Insert Stage 2.5 after Stage 2

**Verification**:
- Stage 2.5 exists between Stage 2 and Stage 3
- Content matches template from research report
- File has valid markdown structure

---

### Phase 3: Add Stage 2.5 to logic-research-agent.md [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Insert roadmap reflection stage into logic research agent

**Tasks**:
- [ ] Read logic-research-agent.md to find Stage 2/Stage 3 boundary (around line 268)
- [ ] Insert Stage 2.5: ROAD_MAP.md Reflection section
- [ ] Add reference to roadmap-reflection-pattern.md in Context References section
- [ ] Add "Check ROAD_MAP.md pitfalls" to MUST DO requirements

**Timing**: 30 minutes

**Files to modify**:
- `.claude/agents/logic-research-agent.md` - Insert Stage 2.5, update Context References, update requirements

**Verification**:
- Stage 2.5 exists between Stage 2 and Stage 3
- Context References includes pattern file
- MUST DO includes roadmap check

---

### Phase 4: Add Stage 2.5 to math-research-agent.md [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Insert roadmap reflection stage into math research agent

**Tasks**:
- [ ] Read math-research-agent.md to find Stage 2/Stage 3 boundary (around line 274)
- [ ] Insert Stage 2.5: ROAD_MAP.md Reflection section
- [ ] Add reference to roadmap-reflection-pattern.md in Context References section
- [ ] Add "Check ROAD_MAP.md pitfalls" to MUST DO requirements

**Timing**: 30 minutes

**Files to modify**:
- `.claude/agents/math-research-agent.md` - Insert Stage 2.5, update Context References, update requirements

**Verification**:
- Stage 2.5 exists between Stage 2 and Stage 3
- Context References includes pattern file
- MUST DO includes roadmap check

---

### Phase 5: Update Report Templates and Verification [NOT STARTED]

- **Dependencies:** Phase 2, Phase 3, Phase 4
- **Goal:** Add ROAD_MAP.md Reflection section to research report structure and verify all changes

**Tasks**:
- [ ] Update lean-research-flow.md Stage 5 report structure to include ROAD_MAP.md Reflection section
- [ ] Update logic-research-agent.md Stage 5 report structure to include ROAD_MAP.md Reflection section
- [ ] Update math-research-agent.md Stage 5 report structure to include ROAD_MAP.md Reflection section
- [ ] Add roadmap-reflection-pattern.md to context index.json with appropriate metadata
- [ ] Verify all modified files have valid markdown structure

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/project/lean4/agents/lean-research-flow.md` - Update report template in Stage 5
- `.claude/agents/logic-research-agent.md` - Update report template in Stage 5
- `.claude/agents/math-research-agent.md` - Update report template in Stage 5
- `.claude/context/index.json` - Add entry for roadmap-reflection-pattern.md

**Verification**:
- All three report templates include ROAD_MAP.md Reflection section with Pitfalls Checked and Strategy Alignment tables
- Pattern file is indexed and discoverable via jq queries
- All modified files pass markdown linting (valid structure)

## Testing & Validation

- [ ] Verify all four new/modified agent files have valid markdown structure
- [ ] Confirm Stage 2.5 appears in correct location (after Stage 2, before Stage 3) in all three agents
- [ ] Verify roadmap-reflection-pattern.md is indexed in context/index.json
- [ ] Verify report templates include ROAD_MAP.md Reflection section
- [ ] Test jq query discovers the pattern file: `jq -r '.entries[] | select(.path | contains("roadmap-reflection")) | .path' .claude/context/index.json`

## Artifacts & Outputs

- `.claude/context/core/patterns/roadmap-reflection-pattern.md` - NEW: Reusable pattern documentation
- `.claude/context/project/lean4/agents/lean-research-flow.md` - MODIFIED: Stage 2.5 + report template
- `.claude/agents/logic-research-agent.md` - MODIFIED: Stage 2.5 + Context References + MUST DO + report template
- `.claude/agents/math-research-agent.md` - MODIFIED: Stage 2.5 + Context References + MUST DO + report template
- `.claude/context/index.json` - MODIFIED: New entry for pattern file

## Rollback/Contingency

If implementation causes issues:
1. All changes are to documentation files - no code impact
2. Revert Stage 2.5 insertions via git: `git checkout HEAD~1 -- <file>`
3. Pattern file can be deleted without affecting existing agents
4. Index.json entry can be removed without breaking queries

Primary risk is context size increase from loading ROAD_MAP.md sections. If this becomes problematic, modify Stage 2.5 to load only Dead Ends section (most actionable) rather than both Strategies and Dead Ends.
