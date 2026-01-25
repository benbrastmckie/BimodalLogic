# Implementation Plan: Task #639

- **Task**: 639 - improve_review_roadmap_matching
- **Status**: [NOT STARTED]
- **Effort**: 4.5 hours
- **Priority**: Medium
- **Dependencies**: None (task 641 already implemented structured matching in /todo)
- **Research Inputs**: specs/639_improve_review_roadmap_matching/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This task improves ROAD_MAP.md checkbox matching reliability in the /review command by adopting the structured matching approach already implemented in /todo (task 641). The primary change is adding roadmap_items field extraction to /review's Step 2.5.2, creating a unified three-tier matching strategy (explicit items, exact references, fuzzy fallback). Secondary changes include updating agent guidance for populating roadmap_items and synchronizing documentation.

### Research Integration

Research report (research-001.md) identified:
- /todo already has reliable structured matching (roadmap_items + exact refs)
- /review lacks roadmap_items extraction (main gap)
- Agents rarely populate roadmap_items due to unclear guidance
- Documentation in roadmap-update.md is outdated

## Goals & Non-Goals

**Goals**:
- Add roadmap_items field extraction to /review Step 2.5.2
- Implement three-tier matching priority (explicit items > exact refs > fuzzy fallback)
- Update agent guidance for populating roadmap_items during implementation
- Update roadmap-update.md to document explicit roadmap_items approach
- Maintain backward compatibility (fuzzy matching as low-confidence fallback)

**Non-Goals**:
- Deprecating fuzzy matching (evaluation for later)
- Creating a separate roadmap-matching utility skill
- Modifying /todo command (already working)
- Adding automated roadmap item discovery

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| /review changes break existing workflow | Low | Low | Adding priority 1 is additive; existing matching still works |
| Agents still don't populate roadmap_items | Medium | Medium | Clear guidance with examples; ROAD_MAP.md reading instructions |
| Documentation drift between commands | Low | Low | Update roadmap-update.md as single source of truth |
| Over-matching with fuzzy fallback | Medium | Medium | Mark fuzzy matches as "low confidence" report-only |

## Implementation Phases

### Phase 1: Update /review Command Matching Logic [NOT STARTED]

**Goal**: Add roadmap_items field extraction and three-tier matching to /review Step 2.5.2

**Tasks**:
- [ ] Read current /review command implementation (lines 105-156)
- [ ] Add jq query to extract roadmap_items from state.json for completed tasks
- [ ] Implement Priority 1 matching: explicit roadmap_items text matching
- [ ] Update Priority 2 matching: exact (Task N) reference matching (already exists)
- [ ] Demote fuzzy title matching to Priority 3 with low confidence marker
- [ ] Update confidence level descriptions in Step 2.5.2

**Timing**: 1.5 hours

**Files to modify**:
- `.claude/commands/review.md` - Add roadmap_items extraction and prioritized matching

**Verification**:
- [ ] /review extracts roadmap_items from state.json
- [ ] Explicit roadmap_items get highest confidence
- [ ] Exact (Task N) refs get high confidence
- [ ] Fuzzy title matches get low confidence (report only)

---

### Phase 2: Update Agent Guidance for roadmap_items [NOT STARTED]

**Goal**: Add clear instructions for agents to populate roadmap_items during implementation

**Tasks**:
- [ ] Add "Populating roadmap_items" section to general-implementation-agent.md
- [ ] Add same section to lean-implementation-agent.md
- [ ] Add same section to latex-implementation-agent.md
- [ ] Include guidance on reading ROAD_MAP.md and matching items
- [ ] Add examples showing correct roadmap_items format

**Timing**: 1.5 hours

**Files to modify**:
- `.claude/agents/general-implementation-agent.md` - Add roadmap_items guidance
- `.claude/agents/lean-implementation-agent.md` - Add roadmap_items guidance
- `.claude/agents/latex-implementation-agent.md` - Add roadmap_items guidance

**Verification**:
- [ ] Each agent has clear roadmap_items population guidance
- [ ] Guidance includes when to populate (non-meta tasks only)
- [ ] Guidance includes how to find relevant items
- [ ] Examples show correct format

---

### Phase 3: Update Documentation [NOT STARTED]

**Goal**: Synchronize roadmap-update.md with actual implementation

**Tasks**:
- [ ] Read current roadmap-update.md documentation
- [ ] Add "Explicit roadmap_items" as Priority 1 matching strategy
- [ ] Update Priority 2 description for exact (Task N) matching
- [ ] Mark fuzzy title matching as "low-confidence fallback"
- [ ] Add examples for each matching type
- [ ] Cross-reference /todo and /review command sections

**Timing**: 1 hour

**Files to modify**:
- `.claude/context/core/patterns/roadmap-update.md` - Update matching strategy documentation

**Verification**:
- [ ] Documentation matches /review implementation
- [ ] Documentation matches /todo implementation
- [ ] Priority order clearly documented
- [ ] Examples provided for each match type

---

### Phase 4: Testing and Validation [NOT STARTED]

**Goal**: Verify implementation works correctly with representative test scenarios

**Tasks**:
- [ ] Test Scenario 1: Task with explicit roadmap_items (should match with highest confidence)
- [ ] Test Scenario 2: Task with (Task N) reference in roadmap (should match with high confidence)
- [ ] Test Scenario 3: Task without explicit items or refs (should use fuzzy, low confidence)
- [ ] Verify /review output format correctly shows confidence levels
- [ ] Verify no regression in existing /review functionality

**Timing**: 0.5 hours

**Files to modify**: None (testing only)

**Verification**:
- [ ] All three scenarios produce expected results
- [ ] Confidence levels correctly reflected in output
- [ ] No errors or unexpected behavior

## Testing & Validation

- [ ] /review command extracts roadmap_items for completed tasks
- [ ] Priority 1 (explicit items) matches correctly
- [ ] Priority 2 (exact refs) matches correctly
- [ ] Priority 3 (fuzzy) marked as low confidence
- [ ] Agent guidance is clear and complete
- [ ] Documentation reflects implementation

## Artifacts & Outputs

- `.claude/commands/review.md` - Updated with roadmap_items matching
- `.claude/agents/general-implementation-agent.md` - Updated with roadmap_items guidance
- `.claude/agents/lean-implementation-agent.md` - Updated with roadmap_items guidance
- `.claude/agents/latex-implementation-agent.md` - Updated with roadmap_items guidance
- `.claude/context/core/patterns/roadmap-update.md` - Updated documentation
- `specs/639_improve_review_roadmap_matching/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If implementation causes issues:
1. Revert changes to review.md (git revert)
2. Agent guidance changes are additive and safe to keep
3. Documentation changes can be kept as they document intended behavior
4. Fuzzy matching preserved as fallback ensures existing functionality works
