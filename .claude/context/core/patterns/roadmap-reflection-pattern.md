# ROAD_MAP.md Reflection Pattern

## Purpose

Prevent research agents from recommending approaches that have been documented as dead ends in the project's ROAD_MAP.md file. This pattern ensures that domain-specific research agents learn from prior failures and align recommendations with active project strategies.

## When to Apply

- During research phase (Stage 2.5), before executing primary searches
- When evaluating multiple implementation paths
- When a task description matches keywords from documented Dead Ends
- When recommending proof strategies or implementation approaches

## Applicable Agents

This pattern applies to domain-specific research agents:

| Agent | Integration Location |
|-------|---------------------|
| lean-research-agent | Stage 2.5 in lean-research-flow.md |
| logic-research-agent | Stage 2.5 in agent file (after Stage 2) |
| math-research-agent | Stage 2.5 in agent file (after Stage 2) |

**Not applicable to**: general-research-agent (no domain-specific pitfalls tracked in ROAD_MAP.md)

## Pattern Steps

### Step 1: Load ROAD_MAP.md Sections

Load the relevant sections from `specs/ROAD_MAP.md`:
- **Strategies** (lines 23-147): Active and concluded strategic approaches
- **Dead Ends** (lines 293-520): Documented failed approaches with lessons

```markdown
**Load**: `@specs/ROAD_MAP.md` (Strategies and Dead Ends sections only)
```

### Step 2: Extract Task Keywords

From the task description, extract domain-relevant keywords:
- Modal logic: "single-family", "modal_backward", "MCS-membership", "constant witness"
- Temporal logic: "single-history", "FDSM", "cross-origin", "CanonicalReachable"
- General: "decidability", "tableau", "IndexedMCSFamily"

### Step 3: Scan Dead Ends

Search Dead Ends section for approaches matching task keywords:

1. For each dead end entry, check:
   - Does the entry's description match task keywords?
   - Is the entry status BLOCKED or ABANDONED (not SUPERSEDED)?
   - Is there a "Superseded By" alternative documented?

2. If a match is found, extract:
   - **Lesson**: The actionable takeaway
   - **Why It Failed**: Root cause understanding
   - **Superseded By**: Alternative approach (if any)

### Step 4: Scan Strategies

Check Strategies section for relevant active/concluded approaches:

1. For each strategy entry, check:
   - Does the strategy apply to the task domain?
   - What is the status (ACTIVE, CONCLUDED, PAUSED)?
   - Are there relevant outcomes or references?

2. Extract applicable strategic context for recommendations.

### Step 5: Apply Pitfall Filter

Before recommending an approach:

**If approach matches a Dead End**:
- Note the documented failure reason
- Check "Superseded By" for documented alternative
- Flag in research report Risks section
- Recommend the superseding approach instead

**If approach aligns with an active Strategy**:
- Reference the strategy in recommendations
- Include relevant outcomes/references from strategy

## Example Check

```
Task: "Prove modal completeness using single MCS family"

Dead End Scan:
  Match Found: "Single-Family BFMCS modal_backward" (BLOCKED)
  Status: BLOCKED - requires T-axiom converse not generally available
  Lesson: "Multi-family bundles are essential for modal completeness without T-axiom"
  Superseded By: "Multi-family BFMCS with modal saturation"

Action:
  - DO NOT recommend single-family approach
  - Recommend multi-family approach from "Superseded By"
  - Include lesson in report Risks section
```

## Report Section Template

Add this section to research reports when reflection identifies relevant pitfalls:

```markdown
## ROAD_MAP.md Reflection

### Pitfalls Checked
| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| {dead_end_name} | Low/Medium/High | {how it affects recommended approach} |
| ... | ... | ... |

### Strategy Alignment
| Strategy | Status | Relevance |
|----------|--------|-----------|
| {strategy_name} | ACTIVE/CONCLUDED/PAUSED | {how research aligns with strategy} |
| ... | ... | ... |
```

## Integration Checklist

When adding Stage 2.5 to a research agent:

1. [ ] Insert Stage 2.5 section between Stage 2 (Analyze Task) and Stage 3 (Execute Searches)
2. [ ] Add ROAD_MAP.md loading instruction referencing Strategies and Dead Ends sections
3. [ ] Add keyword extraction step based on task description
4. [ ] Add Dead Ends scanning procedure with lesson extraction
5. [ ] Add Strategies scanning procedure for active approaches
6. [ ] Add pitfall filter logic before recommendations
7. [ ] Update report template to include ROAD_MAP.md Reflection section
8. [ ] Add "Check ROAD_MAP.md pitfalls" to agent MUST DO requirements
9. [ ] Reference this pattern file in agent Context References

## Maintenance

When documenting new dead ends or strategies in ROAD_MAP.md:

1. Use the established schema (see ROAD_MAP.md Strategies and Dead Ends section headers)
2. Include explicit "Superseded By" when an alternative approach exists
3. Include clear "Lesson" for dead ends to guide future research
4. Update keyword lists in this pattern if new domain concepts are added
