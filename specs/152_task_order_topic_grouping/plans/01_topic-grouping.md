# Implementation Plan: Task #152

- **Task**: 152 - task_order_topic_grouping
- **Status**: [NOT STARTED]
- **Effort**: 3.5 hours
- **Dependencies**: Tasks 149 and 150 (both completed)
- **Research Inputs**: specs/152_task_order_topic_grouping/reports/01_topic-grouping-research.md
- **Artifacts**: plans/01_topic-grouping.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This plan adds topic-based grouping to the Task Order section in TODO.md, transforming the monolithic wave table and dependency tree into semantically organized sections. The implementation adds a `topic` field to state.json entries, implements Union-Find connected component detection in generate-task-order.sh, replaces the flat dependency tree with per-topic `### TopicName` headings and fenced code blocks, enhances the wave table with a Topics column, and backfills the topic field for all active tasks using heuristic keyword matching. The result is a scannable Task Order where related tasks (e.g., all completeness work, all frame extension work) appear together.

### Research Integration

The research report (01_topic-grouping-research.md) provides:
- **Connected component analysis**: Only 2 multi-task components (3-4 tasks each) and 20 isolated nodes, confirming topic grouping as the primary UX improvement over component splitting alone.
- **Seven-topic taxonomy**: `completeness`, `decidability`, `formula-refactor`, `frame-extensions`, `algebraic-representation`, `bilateral`, `agent-system` -- covering all 26 active tasks with no outliers.
- **Union-Find implementation**: Complete 25-line bash implementation with path compression for O(N alpha(N)) component detection.
- **Output format design**: `### TopicName` headings with single fenced code block per topic, cross-topic dep annotations `(topic-name: desc)`, and `Uncategorized` fallback.
- **Compatibility assessment**: `update-task-status.sh` Mode A grep pattern is already compatible; `replace_section()` boundary detection is unaffected by level-3 headings.
- **Keyword heuristic mapping**: Complete bash function `assign_topic_heuristic()` for automated backfill.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Add optional `topic` string field to state.json task entries with graceful degradation when absent
- Implement Union-Find connected component detection in generate-task-order.sh
- Replace monolithic dependency tree with per-topic grouped sections using `### TopicName` headings
- Add Topics column to wave table for quick wave-topic index
- Backfill topic field for all active tasks using keyword heuristics
- Update task-order-format.md to document new format elements
- Regenerate live TODO.md Task Order section with new grouped format

**Non-Goals**:
- Updating `/task` creation flow to prompt for topic at task creation time (future enhancement)
- Adding topic validation or enforcement (topics are advisory, not enforced)
- Modifying update-task-status.sh (already compatible per research)
- Changing connected component detection to affect rendering (topics are primary grouping, components are implicit)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Wave table Topics column too wide for GitHub rendering | M | M | Truncate to 3 topics + "..." per wave row; test with current data |
| Cross-topic dependency annotations confuse readers | L | L | Use consistent `(topic-name: desc) (see above)` format documented in spec |
| Keyword heuristic misclassifies a task | L | L | Manual review after backfill; topic field is easily correctable |
| Bash Union-Find path compression mutation side effects | M | L | Path compression via associative array assignment is safe in bash; test with known graph |
| Script regression breaks existing Task Order consumers | H | L | Test Mode A compatibility with spot-check after regeneration |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Backfill topic field in state.json [NOT STARTED]

**Goal**: Add `topic` field to all active task entries in state.json using the seven-topic taxonomy from research.

**Tasks**:
- [ ] Write jq command to add `topic` field to each active task entry based on the taxonomy mapping from research Appendix A
- [ ] Apply the jq transformation to specs/state.json
- [ ] Verify all 26 active tasks have correct topic assignments by reading the result
- [ ] Spot-check edge cases: task 949 (agent-system vs completeness), task 125 (algebraic-representation with cross-topic deps), task 998 (frame-extensions)

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `specs/state.json` -- Add `"topic": "{value}"` to each active task entry

**Verification**:
- Run `jq '.active_projects[] | "\(.project_number) \(.topic // "MISSING")"' specs/state.json` and confirm all tasks have correct topic assignments
- No task shows "MISSING"

---

### Phase 2: Implement topic-grouped rendering in generate-task-order.sh [NOT STARTED]

**Goal**: Add `load_topics()`, `compute_connected_components()`, and `generate_grouped_section()` functions to the script, replacing the monolithic dependency tree with per-topic grouped output.

**Tasks**:
- [ ] Add `declare -A task_topic` and `load_topics()` function after `build_graph()` section (~15 lines)
- [ ] Add Union-Find functions: `cc_find()`, `cc_union()`, `compute_connected_components()` after `compute_waves()` section (~30 lines)
- [ ] Add `generate_grouped_section()` function that collects canonical topic order, iterates topics, filters tasks per topic, and runs DFS within each topic block (~60 lines)
- [ ] Add cross-topic dependency annotation logic: when a dep belongs to a different topic, annotate with `(topic-name: desc) (see above)` (~15 lines)
- [ ] Add `Uncategorized` fallback section for tasks without a topic field
- [ ] Update `generate_wave_table()` to add a Topics column: collect distinct topics per wave, format as comma-separated list truncated to 3 entries (~20 lines)
- [ ] Update `generate_section()` to call `load_topics()`, `compute_connected_components()`, and use `generate_grouped_section()` instead of `generate_dependency_tree()`
- [ ] Preserve the existing `generate_dependency_tree()` function (do not delete, as it may be useful for debugging)

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `.claude/scripts/generate-task-order.sh` -- Add ~140 lines of new functions, modify ~20 lines in existing functions

**Verification**:
- Run `bash .claude/scripts/generate-task-order.sh --print` and confirm output has `### TopicName` headings, per-topic code blocks, and Topics column in wave table
- Verify all 26 active tasks appear exactly once across all topic sections
- Verify cross-topic deps for task 125 show `(formula-refactor: ...)` and `(frame-extensions: ...)` annotations

---

### Phase 3: Update task-order-format.md specification [NOT STARTED]

**Goal**: Document the new topic-grouped format elements in the format specification.

**Tasks**:
- [ ] Add "Topic Headings" subsection to Structure Elements section documenting `### TopicName` format, regex `^### (.+)$` within `## Task Order`, and canonical topic list
- [ ] Add "Topics Column" description to Dependency Waves Section documenting the new column
- [ ] Update Wave Table format to show 4 columns: Wave, Tasks, Blocked by, Topics
- [ ] Add "Cross-Topic Dependency Annotation" subsection to Dependency Tree Section documenting `(topic-name: desc)` syntax
- [ ] Add "Topic Taxonomy" subsection listing the 7 canonical topic values with descriptions
- [ ] Update Complete Example with a topic-grouped version showing 2-3 topic sections
- [ ] Update Parsing Patterns Summary table with new patterns: topic heading, topics column
- [ ] Update Generation Algorithm section to include topic loading and grouped rendering steps

**Timing**: 45 minutes

**Depends on**: 1

**Files to modify**:
- `.claude/context/formats/task-order-format.md` -- Add ~80 lines of new documentation, update existing sections

**Verification**:
- Read the updated format spec and confirm all new elements are documented
- Verify regex patterns match the actual output from Phase 2

---

### Phase 4: Live regeneration and verification [NOT STARTED]

**Goal**: Regenerate the live TODO.md Task Order section and verify backward compatibility.

**Tasks**:
- [ ] Run `bash .claude/scripts/generate-task-order.sh --update-todo specs/TODO.md specs/state.json` to produce the new grouped output
- [ ] Verify the Task Order section in TODO.md has topic headings and grouped code blocks
- [ ] Spot-check Mode A compatibility: verify that `grep -n -E "^\s*(└─ )?142 \[" specs/TODO.md` still matches the task 142 entry in the tree
- [ ] Verify section boundary detection: confirm `## Tasks` heading is preserved and not consumed by the new format
- [ ] Verify all 26 active tasks appear in the Task Order (count lines matching task number pattern)
- [ ] Review wave table for correct Topics column content

**Timing**: 30 minutes

**Depends on**: 2, 3

**Files to modify**:
- `specs/TODO.md` -- Task Order section replaced by regeneration script

**Verification**:
- `grep -c "^### " specs/TODO.md` returns the number of topic headings (should be 7 or fewer, matching active topics)
- `grep -c "^\*\*Dependency Waves\*\*:" specs/TODO.md` returns 1
- No error output from the regeneration script
- `update-task-status.sh` Mode A pattern still matches at least one tree entry

## Testing & Validation

- [ ] `bash .claude/scripts/generate-task-order.sh --print` produces valid output with topic headings
- [ ] All 26 active tasks appear exactly once in the grouped output
- [ ] Cross-topic dependencies for task 125 show topic annotations
- [ ] Wave table has 4 columns (Wave, Tasks, Blocked by, Topics)
- [ ] `grep -n -E "^\s*(└─ )?18 \[" specs/TODO.md` matches task 18 in the tree (Mode A check)
- [ ] `## Task Order` and `## Tasks` section boundaries are preserved
- [ ] Tasks without deps appear as roots in their topic section
- [ ] Uncategorized section appears only if a task lacks a topic field
- [ ] `jq '.active_projects[] | select(.topic == null or .topic == "")' specs/state.json` returns empty (all tasks have topics)

## Artifacts & Outputs

- `specs/152_task_order_topic_grouping/plans/01_topic-grouping.md` (this plan)
- `specs/state.json` -- Updated with `topic` field on all active tasks
- `.claude/scripts/generate-task-order.sh` -- Enhanced with topic-grouped rendering
- `.claude/context/formats/task-order-format.md` -- Updated specification
- `specs/TODO.md` -- Regenerated Task Order section

## Rollback/Contingency

All changes are to text files tracked by git. If the implementation fails:
1. `git checkout -- specs/state.json` to remove topic backfill
2. `git checkout -- .claude/scripts/generate-task-order.sh` to restore original script
3. `git checkout -- .claude/context/formats/task-order-format.md` to restore original spec
4. `git checkout -- specs/TODO.md` to restore original Task Order
5. Re-run `bash .claude/scripts/generate-task-order.sh --update-todo specs/TODO.md specs/state.json` to regenerate clean Task Order from reverted state
