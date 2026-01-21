# Implementation Plan: Task #652

- **Task**: 652 - Improve /learn TODO grouping by topic
- **Status**: [IMPLEMENTING]
- **Effort**: 3 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/652_improve_learn_todo_grouping_by_topic/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This plan implements intelligent TODO grouping in the `/learn` command. Currently, TODO tasks are created one per selected item with no topic analysis. The improvement adds a topic grouping step between TODO selection and task creation, clustering TODOs by semantic topic to minimize task count while maintaining logical separation.

### Research Integration

Key findings from research-001.md:
- Current Step 8.4 creates one task per TODO item (lines 321-343 of SKILL.md)
- FIX:/NOTE: grouping pattern exists and can be adapted for TODO topic groups
- Recommended hybrid approach: auto-suggest topic groups + user confirmation
- Integration point: new Step 7.5 between TODO selection and task creation
- Content analysis heuristics: common terms, section proximity, action types

## Goals & Non-Goals

**Goals**:
- Inventory all TODO: tags found and present them to user
- Analyze selected TODOs for semantic topics/themes
- Present suggested topic groups for user confirmation
- Create grouped tasks that minimize task count while maintaining logical separation
- Preserve user control via confirmation/adjustment options
- Maintain existing FIX: and NOTE: tag handling (unchanged)

**Non-Goals**:
- Changing FIX: or NOTE: tag behavior (explicitly out of scope)
- Automatic grouping without user confirmation
- Complex NLP or ML-based clustering (use simple heuristics)
- Cross-file topic detection (group by file section/proximity as fallback)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Over-grouping unrelated TODOs | Medium | Medium | User confirmation step allows adjustment |
| Under-grouping related TODOs | Low | Medium | "Single combined task" option available |
| Adds interaction complexity | Medium | Low | Skip grouping for single TODO; clear UI |
| Topic detection accuracy | Medium | Medium | Present groups clearly so user can override |

## Implementation Phases

### Phase 1: Add Topic Analysis Infrastructure [COMPLETED]

**Goal**: Create the topic analysis logic that extracts terms and clusters TODOs

**Tasks**:
- [ ] Add Step 7.5 header and condition check after Step 7 in SKILL.md
- [ ] Implement Step 7.5.1: Extract topic indicators (key terms, file section, action type)
- [ ] Implement Step 7.5.2: Cluster TODOs by shared terms (2+ significant terms in common)
- [ ] Define topic label generation from most common shared terms

**Timing**: 1 hour

**Files to modify**:
- `.claude/skills/skill-learn/SKILL.md` - Add new Step 7.5 with subsections

**Verification**:
- Step 7.5 is defined with clear condition: "User selected TODO tasks AND selected more than 1 TODO item"
- Topic extraction and clustering logic is documented with examples

---

### Phase 2: Add User Confirmation UI for Topic Groups [COMPLETED]

**Goal**: Create the AskUserQuestion prompt for topic group confirmation

**Tasks**:
- [ ] Implement Step 7.5.3: Present topic groups via AskUserQuestion
- [ ] Define three grouping options: accept suggested groups, keep separate, single combined
- [ ] Add skip logic when only 1 TODO selected (no grouping benefit)
- [ ] Document the grouping options with clear descriptions

**Timing**: 45 minutes

**Files to modify**:
- `.claude/skills/skill-learn/SKILL.md` - Add Step 7.5.3 with AskUserQuestion JSON

**Verification**:
- AskUserQuestion prompt includes all three grouping options
- Option descriptions show group counts and topic summaries
- Skip logic documented for single-TODO case

---

### Phase 3: Modify Task Creation for Topic Groups [COMPLETED]

**Goal**: Update Step 8.4 to handle grouped vs individual TODO task creation

**Tasks**:
- [ ] Add conditional branching in Step 8.4: grouped vs individual mode
- [ ] Define grouped task template with topic summary title and item list
- [ ] Define effort scaling formula: 1h base + 30min per additional item
- [ ] Preserve existing individual task creation as fallback

**Timing**: 45 minutes

**Files to modify**:
- `.claude/skills/skill-learn/SKILL.md` - Update Step 8.4 with grouped task logic

**Verification**:
- Grouped task template includes topic summary title, item count, file:line references
- Effort scaling documented
- Individual task creation preserved for users who prefer separate tasks

---

### Phase 4: Update Documentation [COMPLETED]

**Goal**: Update command documentation and flow example to reflect new grouping feature

**Tasks**:
- [ ] Update `.claude/commands/learn.md` with TODO grouping section
- [ ] Update `.claude/docs/examples/learn-flow-example.md` with grouping scenario
- [ ] Add example topic groups (e.g., "Proof Scope: 2 items", "Documentation: 1 item")
- [ ] Document the three grouping options in user-facing documentation

**Timing**: 30 minutes

**Files to modify**:
- `.claude/commands/learn.md` - Add TODO grouping workflow section
- `.claude/docs/examples/learn-flow-example.md` - Add grouping example scenario

**Verification**:
- Command documentation explains TODO grouping feature
- Flow example shows complete grouping interaction
- Example output shows grouped task creation

---

## Testing & Validation

- [ ] Single TODO selected: grouping step is skipped
- [ ] Multiple TODOs selected: grouping options are presented
- [ ] "Accept suggested groups" creates grouped tasks with topic summary titles
- [ ] "Keep as separate tasks" preserves existing one-task-per-TODO behavior
- [ ] "Create single combined task" creates one task with all TODOs
- [ ] FIX: and NOTE: tag handling remains unchanged
- [ ] Effort scaling formula applied correctly to grouped tasks

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- Modified `.claude/skills/skill-learn/SKILL.md`
- Modified `.claude/commands/learn.md`
- Modified `.claude/docs/examples/learn-flow-example.md`
- `summaries/implementation-summary-YYYYMMDD.md` (upon completion)

## Rollback/Contingency

If topic grouping causes issues:
1. Remove Step 7.5 (topic grouping step) from SKILL.md
2. Revert Step 8.4 changes to original individual-task-only logic
3. Remove grouping documentation from commands/learn.md and flow example
4. Commit revert with message explaining rollback reason

The changes are additive and isolated to the TODO task creation path. FIX: and NOTE: handling is completely untouched.
