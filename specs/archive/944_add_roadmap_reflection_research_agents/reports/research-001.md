# Research Report: Task #944

**Task**: 944 - add_roadmap_reflection_research_agents
**Started**: 2026-02-26T12:00:00Z
**Completed**: 2026-02-26T12:30:00Z
**Effort**: Medium (agent modifications + documentation)
**Dependencies**: None
**Sources/Inputs**: - lean-research-agent.md, logic-research-agent.md, math-research-agent.md, ROAD_MAP.md, lean-research-flow.md
**Artifacts**: - specs/944_add_roadmap_reflection_research_agents/reports/research-001.md
**Standards**: report-format.md, return-metadata-file.md

## Executive Summary

- Three research agents (lean, logic, math) share similar stage structures: Stage 0 (init), Stage 1-2 (parse/analyze), Stage 3-4 (search/synthesize), Stage 5-7 (report/return)
- ROAD_MAP.md has well-structured "Strategies" and "Dead Ends" sections with 5 strategies and 8 dead ends documenting failed approaches and lessons learned
- Stage 2.5 should be inserted in the flow file (lean-research-flow.md) and directly in logic/math agent files (which embed their full execution flow)
- The reflection pattern can be documented in a new context file for future agent onboarding

## Context & Scope

The task is to add ROAD_MAP.md reflection to lean-research-agent, logic-research-agent, and math-research-agent. This involves loading Dead Ends and Strategies sections during research to check for relevant pitfalls before recommending approaches.

## Findings

### Existing Agent Structure

All three research agents follow a consistent stage structure:

| Agent | Stage Embedding | Execution Flow |
|-------|-----------------|----------------|
| lean-research-agent | Minimal in agent file, delegates to lean-research-flow.md | Stages 1-7 in separate flow file |
| logic-research-agent | Full stages embedded in agent file (234-526) | Self-contained |
| math-research-agent | Full stages embedded in agent file (239-516) | Self-contained |

**Key Stage Locations:**

1. **lean-research-agent.md**: Stage 0 at lines 157-186, then `@.claude/context/project/lean4/agents/lean-research-flow.md` for Stages 1-7
2. **logic-research-agent.md**: Stage 0 at lines 204-232, Stage 1-2 at 234-268, Stage 3 at 269-295
3. **math-research-agent.md**: Stage 0 at lines 209-237, Stage 1-2 at 239-274, Stage 3 at 275-301

### ROAD_MAP.md Structure Analysis

The ROAD_MAP.md file contains three strategic sections:

#### Strategies Section (lines 23-147)
- Schema comment defines the entry format
- 5 documented strategies:
  1. **Representation-First Architecture** (CONCLUDED) - canonical model construction foundation
  2. **Indexed MCS Family Approach** (ACTIVE) - family of MCS indexed by time
  3. **CoherentConstruction Two-Chain Design** (SUPERSEDED) - simplified coherence proofs
  4. **Algebraic Verification Path** (PAUSED) - Stone duality alternative

#### Dead Ends Section (lines 293-520)
- Schema comment at lines 295-318 defines entry format
- 8 documented dead ends with explicit lessons:
  1. **Boneyard Decidability Infrastructure** - tableau approach superseded by FMP
  2. **Single-History FDSM Construction** - modal trivialization issue
  3. **Cross-Origin Coherence Proofs** - not on critical path
  4. **Original IndexedMCSFamily.construct_indexed_family** - proof complexity
  5. **CanonicalReachable/CanonicalQuotient Stack** - backward_P witnesses issue
  6. **MCS-Membership Semantics for Box** - soundness/completeness gap
  7. **Constant Witness Family Approach** - temporal saturation failure
  8. **Single-Family BFMCS modal_backward** - requires T-axiom converse

Each dead end includes:
- Status (ABANDONED/SUPERSEDED/BLOCKED)
- Related tasks
- What was tried
- Why it failed
- Evidence (file paths)
- Lesson (actionable takeaway)
- Superseded by (if applicable)

### Existing Context Loading Patterns

Research agents use lazy context loading with @-references:

```markdown
## Context References

**Always Load**:
- `@.claude/context/project/lean4/tools/mcp-tools-guide.md`
- `@.claude/context/core/formats/return-metadata-file.md`

**Load After Stage 0**:
- `@.claude/context/project/lean4/agents/lean-research-flow.md`
```

This pattern allows conditional loading based on execution stage.

### Related Patterns in Codebase

1. **Zero-Debt Policy Compliance** (lean-research-agent.md lines 130-156):
   - Already has a "Research Constraints" section that FORBIDS recommending sorry-based approaches
   - Pattern: Check constraints BEFORE making recommendations
   - This is the closest analog to the roadmap reflection pattern

2. **Implementation agents use `approaches_tried`** (general-implementation-agent.md):
   - Track failed approaches to prevent retries
   - Similar concept: learn from prior failures

3. **roadmap_items in completion_data** (general-implementation-agent.md lines 277-280):
   - Optionally generates items that map to ROAD_MAP.md
   - Shows ROAD_MAP.md is already integrated in other workflows

## Recommendations

### Implementation Approach

**Stage 2.5 Location and Content:**

1. For **lean-research-agent.md**: Add Stage 2.5 to lean-research-flow.md (between Stage 2 and Stage 3)
2. For **logic-research-agent.md**: Add Stage 2.5 directly in the agent file (after Stage 2, before Stage 3)
3. For **math-research-agent.md**: Add Stage 2.5 directly in the agent file (after Stage 2, before Stage 3)

**Stage 2.5 Content Template:**

```markdown
## Stage 2.5: ROAD_MAP.md Reflection

Before executing searches, consult ROAD_MAP.md for relevant strategic context:

1. **Load** `@specs/ROAD_MAP.md` (Strategies and Dead Ends sections only)

2. **Scan Dead Ends** for approaches matching the task:
   - Search for keywords from task description
   - Identify any previously tried approaches
   - Note lessons learned and "Superseded By" alternatives

3. **Scan Strategies** for relevant active/concluded approaches:
   - Check which strategies apply to the domain
   - Note any ongoing experiments (ACTIVE status)
   - Apply lessons from concluded strategies

4. **Apply Pitfall Filter**:
   - If task recommends an approach documented in Dead Ends:
     - Note the failure reason
     - Check "Superseded By" for alternative
     - Flag in research report Risks section
   - If task aligns with an active strategy:
     - Reference the strategy in recommendations
     - Check for relevant outcomes/references

**Example Check:**
```
Task: "Prove modal completeness using single MCS family"
Dead End Match: "Single-Family BFMCS modal_backward" (BLOCKED)
Lesson: "Multi-family bundles are essential for modal completeness without T-axiom"
Superseded By: "Multi-family BFMCS with modal saturation"
Action: Recommend multi-family approach, NOT single-family
```
```

### Report Section Addition

Add to research report template:

```markdown
## ROAD_MAP.md Reflection

### Pitfalls Checked
| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| {name} | Low/Medium/High | {how it affects approach} |

### Strategy Alignment
| Strategy | Status | Relevance |
|----------|--------|-----------|
| {name} | ACTIVE/CONCLUDED | {how research aligns} |
```

### Documentation File

Create `@.claude/context/core/patterns/roadmap-reflection-pattern.md`:

```markdown
# ROAD_MAP.md Reflection Pattern

## Purpose
Prevent research agents from recommending approaches that have been documented as dead ends.

## When to Apply
- During research phase, before making approach recommendations
- When evaluating multiple implementation paths
- When a task description matches keywords from Dead Ends

## Pattern
1. Load ROAD_MAP.md Strategies and Dead Ends sections
2. Extract keywords from task description
3. Search for matching dead ends
4. Check lessons and "Superseded By" alternatives
5. Flag in research report if relevant
6. Recommend alternative approaches from "Superseded By"

## Integration
- lean-research-agent: Stage 2.5 in lean-research-flow.md
- logic-research-agent: Stage 2.5 in agent file
- math-research-agent: Stage 2.5 in agent file
- general-research-agent: Not required (no domain-specific pitfalls)
```

## Decisions

1. **Stage 2.5 naming**: Use "2.5" rather than renumbering all stages - minimizes changes to existing documentation
2. **Location**: Embed in flow file for lean (existing pattern), embed in agent files for logic/math (their existing pattern)
3. **Selective loading**: Only load Strategies and Dead Ends sections, not entire ROAD_MAP.md (efficiency)
4. **Report section**: Add ROAD_MAP.md Reflection section to research reports (visibility)

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| ROAD_MAP.md becomes large | Increased context usage | Only load relevant sections (lines 23-520) |
| False positive matches | Over-cautious recommendations | Use keyword matching, not exact match; allow override in report |
| Agent ignores reflection | Repeated dead-end recommendations | Add to MUST DO critical requirements |
| Future agents don't adopt | Pattern not propagated | Document in core patterns; add to agent onboarding |

## Appendix

### Files Analyzed
- `/home/benjamin/Projects/ProofChecker/.claude/agents/lean-research-agent.md` (259 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/agents/logic-research-agent.md` (660 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/agents/math-research-agent.md` (664 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/context/project/lean4/agents/lean-research-flow.md` (332 lines)
- `/home/benjamin/Projects/ProofChecker/specs/ROAD_MAP.md` (~700 lines, Strategies 23-147, Dead Ends 293-520)

### ROAD_MAP.md Section Line Ranges
- Strategies: Lines 23-147 (125 lines)
- Ambitions: Lines 149-291 (143 lines)
- Dead Ends: Lines 293-520 (228 lines)

### Keywords to Match Against Dead Ends
From task descriptions, extract domain keywords:
- Modal logic: "single-family", "modal_backward", "MCS-membership", "constant witness"
- Temporal logic: "single-history", "FDSM", "cross-origin", "CanonicalReachable"
- General: "decidability", "tableau", "IndexedMCSFamily"
