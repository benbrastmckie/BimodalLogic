# Implementation Plan: Task #639 (v2)

- **Task**: 639 - improve_review_roadmap_matching
- **Version**: 2 (revised)
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Priority**: Medium
- **Dependencies**: None (task 641 already implemented structured matching in /todo)
- **Research Inputs**: specs/639_improve_review_roadmap_matching/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This task improves ROAD_MAP.md checkbox matching reliability in the /review command by adopting the structured matching approach already implemented in /todo (task 641). The plan takes a **clean break approach** - removing unreliable fuzzy title matching entirely in favor of explicit two-tier matching (explicit roadmap_items, exact task references). This simplifies the codebase and forces deliberate roadmap item specification.

### Revision Notes (v2)

Changed from v1:
- **Removed**: Fuzzy title matching as fallback (was Priority 3)
- **Removed**: Backwards compatibility considerations
- **Simplified**: Two-tier matching only (explicit items + exact refs)
- **Added**: Unmatched task warning for items lacking roadmap_items

### Research Integration

Research report (research-001.md) identified:
- /todo already has reliable structured matching (roadmap_items + exact refs)
- /review lacks roadmap_items extraction (main gap)
- Agents rarely populate roadmap_items due to unclear guidance
- Documentation in roadmap-update.md is outdated

## Goals & Non-Goals

**Goals**:
- Add roadmap_items field extraction to /review Step 2.5.2
- Implement two-tier matching (explicit items > exact refs)
- Remove fuzzy title matching entirely (clean break)
- Update agent guidance for populating roadmap_items during implementation
- Update roadmap-update.md to document explicit-only approach
- Warn when completed tasks have no roadmap items matched

**Non-Goals**:
- Maintaining fuzzy matching for backwards compatibility
- Creating a separate roadmap-matching utility skill
- Modifying /todo command (already working)
- Adding automated roadmap item discovery

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Old completed tasks won't match roadmap | Low | High | Report as "unmatched" with suggestion to add roadmap_items manually |
| Agents forget to populate roadmap_items | Medium | Medium | Clear guidance with examples; warning for unmatched tasks |
| Documentation drift between commands | Low | Low | Update roadmap-update.md as single source of truth |

## Implementation Phases

### Phase 1: Update /review Command Matching Logic [COMPLETED]

**Goal**: Add roadmap_items field extraction and two-tier matching to /review Step 2.5.2, removing fuzzy matching

**Tasks**:
- [ ] Read current /review command implementation (lines 105-156)
- [ ] Add jq query to extract roadmap_items from state.json for completed tasks
- [ ] Implement Priority 1 matching: explicit roadmap_items text matching
- [ ] Keep Priority 2 matching: exact (Task N) reference matching (already exists)
- [ ] Remove fuzzy title matching entirely
- [ ] Add "unmatched tasks" warning section for tasks without roadmap matches
- [ ] Update output format to show match type (explicit/exact-ref/none)

**Timing**: 1.5 hours

**Files to modify**:
- `.claude/commands/review.md` - Add roadmap_items extraction, remove fuzzy matching

**Verification**:
- [ ] /review extracts roadmap_items from state.json
- [ ] Explicit roadmap_items matched correctly
- [ ] Exact (Task N) refs matched correctly
- [ ] No fuzzy matching occurs
- [ ] Unmatched tasks reported with warning

---

### Phase 2: Update Agent Guidance for roadmap_items [NOT STARTED]

**Goal**: Add clear instructions for agents to populate roadmap_items during implementation

**Tasks**:
- [ ] Add "Populating roadmap_items" section to general-implementation-agent.md
- [ ] Add same section to lean-implementation-agent.md
- [ ] Add same section to latex-implementation-agent.md
- [ ] Include guidance on reading ROAD_MAP.md and matching items
- [ ] Add examples showing correct roadmap_items format
- [ ] Emphasize this is **required** for roadmap tracking (not optional)

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
- [ ] Guidance emphasizes requirement (not optional)

---

### Phase 3: Update Documentation [NOT STARTED]

**Goal**: Synchronize roadmap-update.md with actual implementation

**Tasks**:
- [ ] Read current roadmap-update.md documentation
- [ ] Add "Explicit roadmap_items" as Priority 1 matching strategy
- [ ] Update Priority 2 description for exact (Task N) matching
- [ ] Remove any references to fuzzy title matching
- [ ] Document "unmatched tasks" warning behavior
- [ ] Add examples for each matching type
- [ ] Cross-reference /todo and /review command sections

**Timing**: 0.5 hours

**Files to modify**:
- `.claude/context/core/patterns/roadmap-update.md` - Update matching strategy documentation

**Verification**:
- [ ] Documentation matches /review implementation (no fuzzy)
- [ ] Documentation matches /todo implementation
- [ ] Priority order clearly documented
- [ ] Examples provided for explicit and exact-ref matching

---

### Phase 4: Testing and Validation [NOT STARTED]

**Goal**: Verify implementation works correctly with representative test scenarios

**Tasks**:
- [ ] Test Scenario 1: Task with explicit roadmap_items (should match)
- [ ] Test Scenario 2: Task with (Task N) reference in roadmap (should match)
- [ ] Test Scenario 3: Task without explicit items or refs (should report as unmatched)
- [ ] Verify /review output correctly shows match types
- [ ] Verify unmatched tasks warning appears
- [ ] Verify no fuzzy matching attempts

**Timing**: 0.5 hours

**Files to modify**: None (testing only)

**Verification**:
- [ ] All three scenarios produce expected results
- [ ] Match types correctly reflected in output
- [ ] Unmatched tasks properly warned
- [ ] No errors or unexpected behavior

## Testing & Validation

- [ ] /review command extracts roadmap_items for completed tasks
- [ ] Priority 1 (explicit items) matches correctly
- [ ] Priority 2 (exact refs) matches correctly
- [ ] No fuzzy matching occurs
- [ ] Unmatched tasks warned appropriately
- [ ] Agent guidance is clear and complete
- [ ] Documentation reflects implementation

## Artifacts & Outputs

- `.claude/commands/review.md` - Updated with explicit-only matching
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
4. If explicit-only proves too restrictive, can add fuzzy back later as opt-in
