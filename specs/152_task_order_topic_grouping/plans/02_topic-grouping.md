# Implementation Plan: Task #152

- **Task**: 152 - task_order_topic_grouping
- **Status**: [NOT STARTED]
- **Effort**: 5.5 hours
- **Dependencies**: Tasks 149 and 150 (both completed)
- **Research Inputs**: specs/152_task_order_topic_grouping/reports/01_topic-grouping-research.md, specs/152_task_order_topic_grouping/reports/02_topic-field-population.md
- **Artifacts**: plans/02_topic-grouping.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This plan transforms the Task Order section in TODO.md from a monolithic dependency tree into semantically grouped, scannable sections organized by topic. The implementation spans both the output side (how topics are rendered in the Task Order) and the input side (how topics are assigned when tasks are created). It adds an `active_topics` top-level array and per-task `topic` field to state.json, backfills all 26 active tasks using a seven-topic taxonomy, implements Union-Find connected component detection and topic-grouped tree rendering in generate-task-order.sh, enhances the wave table with a Topics column, wires topic assignment into all four task-creation paths (`/task`, `meta-builder-agent`, `skill-fix-it`, `/review`), adds `--sync` backfill for missing topics, and updates format and schema documentation.

### Research Integration

**Report 01** (topic-grouping-research.md) provides the output-side design:
- Connected component analysis showing only 2 multi-task components and 20 isolated nodes, confirming topic grouping as the primary UX improvement.
- Seven-topic taxonomy: `completeness`, `decidability`, `formula-refactor`, `frame-extensions`, `algebraic-representation`, `bilateral`, `agent-system`.
- Complete Union-Find bash implementation with path compression (~25 lines).
- Output format design with `### TopicName` headings, single fenced code block per topic, cross-topic dep annotations `(topic-name: desc)`, and `Uncategorized` fallback.
- Compatibility confirmation: `update-task-status.sh` Mode A and `replace_section()` boundary detection are unaffected.
- Keyword heuristic function `assign_topic_heuristic()` for automated backfill.

**Report 02** (topic-field-population.md) provides the input-side design:
- Identification of all four task-creation paths: `/task`, `meta-builder-agent`, `skill-fix-it`, `/review`.
- Exact insertion points in each command/agent file for the `topic` field.
- `active_topics` top-level array schema for state.json as a single source of truth for topic names.
- Topic assignment UX: auto-infer via keyword heuristic + AskUserQuestion picker for `/task`; auto-assign without extra prompts for batch creators (`meta-builder-agent`, `skill-fix-it`, `/review`).
- `/task --sync` backfill mechanism for tasks missing topics.
- Inheritance rules: `--recover` preserves topic from archived entry; `--expand` and `--review` inherit from parent task.

### Prior Plan Reference

Plan v1 (01_topic-grouping.md) covered 4 phases totaling 3.5 hours: (1) state.json backfill, (2) script rendering enhancement, (3) format spec update, (4) live regeneration. It explicitly deferred task-creation wiring as a Non-Goal. The effort estimates for the core phases proved well-calibrated. This revised plan retains the core phase structure while expanding Phase 1 to include the `active_topics` schema and adding two new phases for task-creation wiring and schema documentation. The dependency wave structure is adjusted from 3 waves to 4 waves to accommodate the new phases.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Add `active_topics` top-level string array to state.json listing the canonical seven-topic taxonomy
- Add optional `topic` string field to state.json task entries with graceful degradation when absent
- Backfill topic field for all active tasks using keyword heuristics with manual verification
- Implement Union-Find connected component detection in generate-task-order.sh
- Replace monolithic dependency tree with per-topic grouped sections using `### TopicName` headings and fenced code blocks
- Add Topics column to wave table for quick wave-topic index
- Wire topic assignment into `/task` creation flow (AskUserQuestion picker with auto-suggest)
- Wire topic auto-assignment into `meta-builder-agent`, `skill-fix-it`, and `/review` task creation
- Add `--sync` backfill pass for tasks missing topic field
- Add topic inheritance for `--expand` and `--review` (derived task) submodes
- Update task-order-format.md to document new format elements
- Update state-management-schema.md to document `active_topics` and `topic` field
- Regenerate live TODO.md Task Order section with new grouped format

**Non-Goals**:
- Adding topic validation or enforcement (topics are advisory, not enforced)
- Auto-pruning unused topics from `active_topics` (future `/todo` enhancement)
- Modifying `update-task-status.sh` (already compatible per research)
- Changing connected component detection to affect rendering (topics are primary grouping, components are implicit)
- Per-topic color coding or UI enhancements beyond headings

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Wave table Topics column too wide for GitHub rendering | M | M | Truncate to 3 topics + "..." per wave row; test with current data |
| Cross-topic dependency annotations confuse readers | L | L | Use consistent `(topic-name: desc) (see above)` format documented in spec |
| Keyword heuristic misclassifies a task | L | L | Manual review after backfill; topic field is easily correctable via `--sync` |
| Bash Union-Find path compression mutation side effects | M | L | Path compression via associative array assignment is safe in bash; test with known graph |
| AskUserQuestion for topic in `/task` adds friction to task creation | M | M | Auto-suggest makes it usually one click; "Skip" option keeps friction low |
| `active_topics` array grows stale with unused topics | L | L | Topics are cheap to maintain; prune only via explicit future command |
| Script regression breaks existing Task Order consumers | H | L | Test Mode A compatibility with spot-check after regeneration |
| Many files modified increases merge conflict risk | M | L | Phases are independent per-file; commit after each phase |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4 | 1 |
| 3 | 5 | 2, 3, 4 |
| 4 | 6 | 2, 5 |

Phases within the same wave can execute in parallel.

### Phase 1: Schema changes and state.json backfill [NOT STARTED]

**Goal**: Add `active_topics` top-level array and `topic` field to all active task entries in state.json using the seven-topic taxonomy from research.

**Tasks**:
- [ ] Add `active_topics` top-level array to state.json containing the seven canonical topic values: `["completeness", "decidability", "formula-refactor", "frame-extensions", "algebraic-representation", "bilateral", "agent-system"]`
- [ ] Write jq command to add `topic` field to each active task entry based on the taxonomy mapping from research report 01 Appendix A (26 tasks)
- [ ] Apply the jq transformation to specs/state.json
- [ ] Verify all 26 active tasks have correct topic assignments by reading the result
- [ ] Spot-check edge cases: task 949 (agent-system vs completeness), task 125 (algebraic-representation with cross-topic deps), task 998 (frame-extensions)
- [ ] Verify `active_topics` array is present at top level alongside `next_project_number`

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `specs/state.json` -- Add `"active_topics": [...]` at top level; add `"topic": "{value}"` to each active task entry

**Verification**:
- Run `jq '.active_topics' specs/state.json` and confirm the seven-topic array
- Run `jq '.active_projects[] | "\(.project_number) \(.topic // "MISSING")"' specs/state.json` and confirm all tasks have correct topic assignments
- No task shows "MISSING"

---

### Phase 2: Implement topic-grouped rendering in generate-task-order.sh [NOT STARTED]

**Goal**: Add `load_topics()`, `compute_connected_components()`, and `generate_grouped_section()` functions to the script, replacing the monolithic dependency tree with per-topic grouped output.

**Tasks**:
- [ ] Add `declare -A task_topic` and `load_topics()` function after `build_graph()` section (~15 lines); reads `topic` field from state.json via jq into associative array
- [ ] Add Union-Find functions: `cc_find()` (with path compression), `cc_union()`, `compute_connected_components()` after `compute_waves()` section (~30 lines)
- [ ] Add `generate_grouped_section()` function that collects canonical topic order from `active_topics`, iterates topics, filters tasks per topic, and runs DFS within each topic block (~60 lines)
- [ ] Add cross-topic dependency annotation logic: when a dep belongs to a different topic, annotate with `(topic-name: desc) (see above)` (~15 lines)
- [ ] Add `Uncategorized` fallback section for tasks without a topic field
- [ ] Update `generate_wave_table()` to add a Topics column: collect distinct topics per wave, format as comma-separated list truncated to 3 entries (~20 lines)
- [ ] Update `generate_section()` to call `load_topics()`, `compute_connected_components()`, and use `generate_grouped_section()` instead of `generate_dependency_tree()`
- [ ] Preserve the existing `generate_dependency_tree()` function (do not delete, useful for debugging)

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `.claude/scripts/generate-task-order.sh` -- Add ~140 lines of new functions, modify ~20 lines in existing functions

**Verification**:
- Run `bash .claude/scripts/generate-task-order.sh --print` and confirm output has `### TopicName` headings, per-topic code blocks, and Topics column in wave table
- Verify all 26 active tasks appear exactly once across all topic sections
- Verify cross-topic deps for task 125 show `(formula-refactor: ...)` and `(frame-extensions: ...)` annotations

---

### Phase 3: Wire topic assignment into task-creation commands [NOT STARTED]

**Goal**: Add topic field population to all four task-creation paths so new tasks receive a topic at creation time, and add `--sync` backfill for tasks missing topics.

**Tasks**:
- [ ] **`/task` (create mode)**: Add Step 4.5 to `.claude/commands/task.md` -- run keyword heuristic against description, present AskUserQuestion picker with auto-suggest + all `active_topics` + "New topic..." + "Skip (no topic)"; if "New topic..." selected, append to `active_topics` in state.json
- [ ] **`/task` (create mode)**: Add `"topic": $topic` to the Step 6 jq block that writes the task entry to state.json; omit field if topic is null/skipped
- [ ] **`/task --expand`**: Add topic inheritance -- read parent task's `topic` from state.json, pass to each subtask jq entry
- [ ] **`/task --review`**: Add topic inheritance from parent task to follow-up task jq entries
- [ ] **`/task --sync`**: Add batch backfill pass after existing sync step 5 -- detect tasks with missing `topic`, run keyword heuristic, present batch AskUserQuestion multiSelect with options "Accept all auto-inferred", "Accept selected", "Skip backfill"
- [ ] **`meta-builder-agent`**: Add auto-inferred `topic` column to Stage 5 ReviewAndConfirm confirmation table; include `"topic": $topic` in Stage 6 jq block that writes each task to state.json
- [ ] **`skill-fix-it`**: Add `"topic": $topic` to Step 9.1 jq block; auto-infer topic using file-path heuristic (`.claude/` files -> `agent-system`, `.lean` files -> keyword match); add Topic column to Step 10 summary table
- [ ] **`/review`**: Add `"topic": $topic` to Section 5.6.3 jq block; auto-infer topic from file-path heuristic

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `.claude/commands/task.md` -- Add Step 4.5 (topic detection + AskUserQuestion), modify Step 6 jq, add `--sync` backfill, add `--expand` and `--review` inheritance (~60 lines added)
- `.claude/agents/meta-builder-agent.md` -- Add topic column to Stage 5 table, add `"topic"` to Stage 6 jq (~20 lines added)
- `.claude/skills/skill-fix-it/SKILL.md` -- Add `"topic"` to Step 9.1 jq, add Topic column to Step 10 summary (~15 lines added)
- `.claude/commands/review.md` -- Add `"topic"` to Section 5.6.3 jq (~10 lines added)

**Verification**:
- Read each modified file and confirm the `topic` field appears in the relevant jq blocks
- Confirm `/task` has the AskUserQuestion picker with auto-suggest, existing topics, "New topic...", and "Skip"
- Confirm `--sync` has batch backfill logic with multiSelect confirmation
- Confirm `--expand` and `--review` inherit topic from parent task
- Confirm `meta-builder-agent` Stage 5 table includes Topic column
- Confirm `skill-fix-it` Step 10 summary includes Topic column

---

### Phase 4: Update format and schema documentation [NOT STARTED]

**Goal**: Document all new format elements in task-order-format.md and schema changes in state-management-schema.md and state-management.md.

**Tasks**:
- [ ] **task-order-format.md**: Add "Topic Headings" subsection to Structure Elements section documenting `### TopicName` format, regex `^### (.+)$` within `## Task Order`, and canonical topic list
- [ ] **task-order-format.md**: Add "Topics Column" description to Dependency Waves Section documenting the new 4-column wave table (Wave, Tasks, Blocked by, Topics)
- [ ] **task-order-format.md**: Add "Cross-Topic Dependency Annotation" subsection documenting `(topic-name: desc)` syntax
- [ ] **task-order-format.md**: Add "Topic Taxonomy" subsection listing the 7 canonical topic values with descriptions
- [ ] **task-order-format.md**: Update Complete Example with a topic-grouped version showing 2-3 topic sections
- [ ] **task-order-format.md**: Update Parsing Patterns Summary table with new patterns: topic heading, topics column
- [ ] **task-order-format.md**: Update Generation Algorithm section to include topic loading and grouped rendering steps
- [ ] **state-management-schema.md**: Add `active_topics` to the "state.json Full Structure" section and "Field Reference" table; document it as a top-level `string[]` array
- [ ] **state-management-schema.md**: Add `topic` to the project entry field reference table as an optional string field
- [ ] **state-management.md**: Add brief mention of `active_topics` in the "Canonical Sources" section under state.json

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `.claude/context/formats/task-order-format.md` -- Add ~80 lines of new documentation, update existing sections
- `.claude/context/reference/state-management-schema.md` -- Add `active_topics` and `topic` field documentation (~20 lines added)
- `.claude/rules/state-management.md` -- Add brief mention of `active_topics` (~5 lines added)

**Verification**:
- Read the updated task-order-format.md and confirm all new elements are documented
- Verify regex patterns match the actual output from Phase 2
- Read state-management-schema.md and confirm `active_topics` and `topic` are documented
- Read state-management.md and confirm `active_topics` is mentioned

---

### Phase 5: Keyword heuristic helper function [NOT STARTED]

**Goal**: Extract the keyword heuristic into a reusable shell function available to both generate-task-order.sh and task-creation commands, avoiding duplication across files.

**Tasks**:
- [ ] Create a shared helper function `assign_topic_heuristic()` in generate-task-order.sh (or a shared include file if one exists) that takes `name` and `description` arguments and echoes the matched topic (empty string for uncategorized)
- [ ] Verify the function implements the keyword matching order from research report 01 Appendix B: bilateral > agent-system > algebraic-representation > decidability > formula-refactor > frame-extensions > completeness
- [ ] Document the function in the task-order-format.md Topic Taxonomy subsection (reference to the function location)
- [ ] Add the keyword heuristic reference to the `/task` Step 4.5 instructions so agents know to use the same pattern matching

**Timing**: 30 minutes

**Depends on**: 2, 3, 4

**Files to modify**:
- `.claude/scripts/generate-task-order.sh` -- Add `assign_topic_heuristic()` function (~20 lines)
- `.claude/context/formats/task-order-format.md` -- Add reference to heuristic function location

**Verification**:
- Run the heuristic function against known task names and confirm correct topic assignment
- Confirm the function is referenced in both the script and the documentation

---

### Phase 6: Live regeneration and verification [NOT STARTED]

**Goal**: Regenerate the live TODO.md Task Order section and verify full backward compatibility across all changes.

**Tasks**:
- [ ] Run `bash .claude/scripts/generate-task-order.sh --update-todo specs/TODO.md specs/state.json` to produce the new grouped output
- [ ] Verify the Task Order section in TODO.md has topic headings and grouped code blocks
- [ ] Spot-check Mode A compatibility: verify that `grep -n -E "^\s*(└─ )?142 \[" specs/TODO.md` still matches the task 142 entry in the tree
- [ ] Verify section boundary detection: confirm `## Tasks` heading is preserved and not consumed by the new format
- [ ] Verify all 26 active tasks appear in the Task Order (count lines matching task number pattern)
- [ ] Review wave table for correct 4-column format with Topics column content
- [ ] Verify `### TopicName` headings appear for each active topic (up to 7)
- [ ] Verify cross-topic dependency annotations for task 125
- [ ] Verify `Uncategorized` section does NOT appear (all tasks should have topics after Phase 1)
- [ ] Validate state.json is well-formed JSON: `jq . specs/state.json > /dev/null`

**Timing**: 30 minutes

**Depends on**: 2, 5

**Files to modify**:
- `specs/TODO.md` -- Task Order section replaced by regeneration script

**Verification**:
- `grep -c "^### " specs/TODO.md` returns the number of topic headings (should be 7 or fewer, matching active topics)
- `grep -c "^\*\*Dependency Waves\*\*:" specs/TODO.md` returns 1
- No error output from the regeneration script
- `update-task-status.sh` Mode A pattern still matches at least one tree entry
- `jq '.active_projects | length' specs/state.json` returns 26
- `jq '.active_topics | length' specs/state.json` returns 7

## Testing & Validation

- [ ] `jq '.active_topics' specs/state.json` returns the seven-topic array
- [ ] `jq '.active_projects[] | select(.topic == null or .topic == "")' specs/state.json` returns empty (all tasks have topics)
- [ ] `bash .claude/scripts/generate-task-order.sh --print` produces valid output with topic headings
- [ ] All 26 active tasks appear exactly once in the grouped output
- [ ] Cross-topic dependencies for task 125 show topic annotations
- [ ] Wave table has 4 columns (Wave, Tasks, Blocked by, Topics)
- [ ] `grep -n -E "^\s*(└─ )?18 \[" specs/TODO.md` matches task 18 in the tree (Mode A check)
- [ ] `## Task Order` and `## Tasks` section boundaries are preserved
- [ ] Tasks without deps appear as roots in their topic section
- [ ] Uncategorized section appears only if a task lacks a topic field (should not appear after backfill)
- [ ] `/task` Step 4.5 AskUserQuestion picker is documented with auto-suggest + full topic list
- [ ] `meta-builder-agent` Stage 5 confirmation table includes Topic column
- [ ] `skill-fix-it` Step 10 summary includes Topic column
- [ ] `/review` Section 5.6.3 jq includes `"topic"` field
- [ ] `--sync` backfill logic is documented with batch AskUserQuestion multiSelect
- [ ] `state-management-schema.md` documents `active_topics` and `topic` fields
- [ ] `task-order-format.md` documents topic headings, topics column, cross-topic annotations, and taxonomy

## Artifacts & Outputs

- `specs/152_task_order_topic_grouping/plans/02_topic-grouping.md` (this plan)
- `specs/state.json` -- Updated with `active_topics` array and `topic` field on all active tasks
- `.claude/scripts/generate-task-order.sh` -- Enhanced with topic-grouped rendering, Union-Find, and keyword heuristic
- `.claude/context/formats/task-order-format.md` -- Updated specification with topic format elements
- `.claude/context/reference/state-management-schema.md` -- Updated with `active_topics` and `topic` field documentation
- `.claude/rules/state-management.md` -- Updated with `active_topics` mention
- `.claude/commands/task.md` -- Updated with topic assignment (Step 4.5), `--sync` backfill, inheritance for `--expand`/`--review`
- `.claude/agents/meta-builder-agent.md` -- Updated with topic column and jq field
- `.claude/skills/skill-fix-it/SKILL.md` -- Updated with topic auto-assignment and summary column
- `.claude/commands/review.md` -- Updated with topic field in jq block
- `specs/TODO.md` -- Regenerated Task Order section with topic-grouped format

## Rollback/Contingency

All changes are to text files tracked by git. If the implementation fails:
1. `git checkout -- specs/state.json` to remove topic backfill and `active_topics`
2. `git checkout -- .claude/scripts/generate-task-order.sh` to restore original script
3. `git checkout -- .claude/context/formats/task-order-format.md` to restore original spec
4. `git checkout -- .claude/context/reference/state-management-schema.md` to restore original schema doc
5. `git checkout -- .claude/rules/state-management.md` to restore original rules
6. `git checkout -- .claude/commands/task.md .claude/agents/meta-builder-agent.md .claude/skills/skill-fix-it/SKILL.md .claude/commands/review.md` to restore original command/agent files
7. `git checkout -- specs/TODO.md` to restore original Task Order
8. Re-run `bash .claude/scripts/generate-task-order.sh --update-todo specs/TODO.md specs/state.json` to regenerate clean Task Order from reverted state
