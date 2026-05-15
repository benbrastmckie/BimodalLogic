# Research Report: Task #152

**Task**: 152 - Task Order Topic Grouping and Wave Separation
**Started**: 2026-05-15T20:00:00Z
**Completed**: 2026-05-15T20:45:00Z
**Effort**: 3-5 hours (implementation estimate)
**Dependencies**: Tasks 149 and 150 (both completed)
**Sources/Inputs**:
- `.claude/scripts/generate-task-order.sh` — full script read
- `.claude/context/formats/task-order-format.md` — format spec read
- `specs/state.json` — all active task entries analyzed
- `specs/TODO.md` — current Task Order section examined
- `.claude/scripts/update-task-status.sh` — Phase 3 compatibility assessed
**Artifacts**:
- `specs/152_task_order_topic_grouping/reports/01_topic-grouping-research.md` (this file)
**Standards**: report-format.md, task-order-format.md, state-management.md

---

## Executive Summary

- The current Task Order section is a single monolithic wave table and dependency tree spanning all 26 active tasks, making it hard to scan because tasks from completely unrelated domains (Lean proofs, agent system meta) appear interleaved.
- The dependency graph has only **2 true multi-task connected components** (3 tasks each) and 20 isolated nodes — so connected-component splitting alone provides limited separation; **topic-based grouping is the primary improvement**.
- Seven topic categories cover all active tasks: `completeness`, `decidability`, `formula-refactor`, `frame-extensions`, `algebraic-representation`, `bilateral`, and `agent-system`.
- The `topic` field should be added as an **optional string** to `state.json` task entries; when absent the task is assigned to a fallback `"uncategorized"` group.
- Implementation requires changes to `generate-task-order.sh` (add Union-Find component detection and topic-grouped tree rendering), `task-order-format.md` (document new format elements), and a one-time `state.json` backfill of the `topic` field for existing tasks.
- `update-task-status.sh` Mode A (in-place status update) uses a file-wide grep pattern that is **already compatible** with the new format — no changes needed there.

---

## Context & Scope

### What Was Researched

Task 152 asks for five improvements to the Task Order section in `TODO.md`:
1. Detect independent subgraphs (connected components) and render each as its own block.
2. Add optional `topic` field to `state.json` task entries.
3. Update `generate-task-order.sh` to group tasks by topic with per-group markdown headings and code blocks.
4. Enhance wave table to show topic breakdown per wave.
5. Backfill `topic` field for existing active tasks using heuristic keyword matching.

### Constraints

- Must not break `update-task-status.sh` Mode A (in-place grep-based status update).
- Section boundaries (`## Task Order` / `## Tasks`) must remain stable for `replace_section()` parsing.
- The `topic` field must be optional so old tasks without it degrade gracefully.
- No external dependencies — implementation stays in bash + jq.

---

## Findings

### 1. Current generate-task-order.sh Architecture

The script is 548 lines organized in well-separated sections:

| Section | Lines | Purpose |
|---------|-------|---------|
| Argument parsing | 30-69 | `--print` / `--update-todo` mode selection |
| Data extraction | 86-104 | `get_active_tasks()` calls `jq` on state.json |
| Graph building | 116-171 | Populates `task_status`, `task_deps`, `task_desc`, `all_task_nums` |
| Kahn's algorithm | 179-239 | Computes `wave_assignment[task_num]` |
| Wave table | 245-293 | `generate_wave_table()` emits markdown table |
| Dependency tree | 299-404 | `generate_dependency_tree()` + `print_tree_node()` DFS |
| Goal reading | 410-433 | Reads existing Goal line from TODO.md |
| Section assembly | 439-458 | `generate_section()` calls table + tree |
| Section replacement | 464-513 | `replace_section()` writes to TODO.md |

**Key insertion points for topic grouping**:
- **After `build_graph()`**: call `load_topics()` to read `topic` field from state.json into `task_topic[task_num]`.
- **After `compute_waves()`**: call `compute_connected_components()` to build `component_id[task_num]` via Union-Find.
- **In `generate_section()`**: replace `generate_dependency_tree()` with `generate_grouped_section()`.
- **In `generate_wave_table()`**: optionally add a Topics column.

No changes are needed to `build_graph()`, `compute_waves()`, `replace_section()`, or `read_existing_goal()`.

### 2. Current Task Order Output (live as of 2026-05-15)

```
**Dependency Waves**:
| Wave | Tasks | Blocked by |
|------|-------|------------|
| 1 | 8,18,60,64,68,95,112,114,116,122,126,127,130,131,142,143,152,619,949,953,992,998 | -- |
| 2 | 20,21,125,128 | 18,116,122 |

**Dependency Tree** (indented = must complete first):
```
8 [RESEARCHED] — genuine_truth_at_completeness
18 [BLOCKED] — Wire the TimelineQuot BFMCS and DenseTask-based TaskFrame ℚ
...
20 [NOT STARTED] — Review ParametricCanonical.lean...
  └─ 18 [BLOCKED] — ... (see above)
21 [PLANNED] — Clean up technical debt...
  └─ 18 [BLOCKED] — ... (see above)
125 [NOT STARTED] — Research algebraic methods...
  └─ 116 [PLANNED] — ... (see above)
  └─ 122 [RESEARCHED] — ... (see above)
128 [NOT STARTED] — Add topological open set...
  └─ 122 [RESEARCHED] — ... (see above)
```
```

Wave 1 contains 22 tasks — far too many to scan. The tasks span Lean proof work, meta/agent system, and bilateral logic with no visual grouping.

### 3. State.json Schema Analysis

Current active task entries contain these fields (relevant to this task):
- `project_number` (int, required)
- `project_name` (string, required)
- `status` (string, required)
- `task_type` (string, optional: `lean4`, `meta`, `formal`)
- `description` (string, optional)
- `dependencies` (array of ints, optional)

**Proposed addition**: `"topic": "completeness"` — an optional string using a canonical kebab-case taxonomy.

The `topic` field intentionally differs from `task_type`:
- `task_type` = implementation technology (lean4, meta, formal)
- `topic` = semantic domain (what the task is *about*)

### 4. Active Task Graph: Connected Components

After cleaning dependencies (removing references to completed/archived tasks), the active edges are:

```
18 -> {20, 21}      (dense rep theorem blocks audit + cleanup)
116 -> {125}        (GHFP refactor blocks Jonsson-Tarski rep)
122 -> {125, 128}   (discrete BFMCS blocks Jonsson-Tarski + open set)
```

**Connected components** (undirected reachability):
- **Component A**: `{18, 20, 21}` — Dense representation + parametric audit + tech debt cleanup
- **Component B**: `{116, 122, 125, 128}` — GHFP refactor + discrete BFMCS + Jonsson-Tarski + open set operator
- **20 isolated nodes**: `8, 60, 64, 68, 95, 112, 114, 126, 127, 130, 131, 142, 143, 152, 619, 949, 953, 992, 998`

With only 2 multi-task components, connected-component splitting alone does not dramatically improve readability. The improvement comes from **topic grouping** which clusters the 20 isolated nodes semantically.

### 5. Connected Component Detection in Bash

**Recommended approach: Union-Find (disjoint sets)**

This is the cleanest approach for bash since it only requires forward-traversal of dependencies (no backward edges needed):

```bash
declare -A cc_parent  # task_num -> root representative

# Initialize: each task is its own component
for tn in "${all_task_nums[@]}"; do
  cc_parent["$tn"]="$tn"
done

# Find with path compression
cc_find() {
  local x="$1"
  while [[ "${cc_parent[$x]}" != "$x" ]]; do
    cc_parent["$x"]="${cc_parent[${cc_parent[$x]}]}"  # path compression
    x="${cc_parent[$x]}"
  done
  echo "$x"
}

# Union: merge components of two tasks
cc_union() {
  local rx ry
  rx=$(cc_find "$1")
  ry=$(cc_find "$2")
  [[ "$rx" != "$ry" ]] && cc_parent["$rx"]="$ry"
}

# Build components from active deps
for tn in "${all_task_nums[@]}"; do
  local deps="${task_deps[$tn]:-}"
  for dep in $deps; do
    cc_union "$tn" "$dep"
  done
done

# Result: cc_find(task_num) returns component root
```

This is ~25 lines, handles path compression, and runs in O(N α(N)) which is effectively linear for N=26.

### 6. Topic Taxonomy for This Project

Based on analysis of all 26 active task names and descriptions:

| Topic | Canonical Value | Tasks | Description |
|-------|----------------|-------|-------------|
| Completeness | `completeness` | 8, 18, 20, 21, 64, 68, 95, 142 | bx_completeness critical path, dense/discrete rep theorems, audits |
| Decidability | `decidability` | 143 | Doets normal forms, KType finiteness, FMP |
| Formula Refactor | `formula-refactor` | 60, 116, 130, 131 | G/H/F/P as abbreviations, module reorg, dead-code cleanup |
| Frame Extensions | `frame-extensions` | 122, 126, 127, 128, 998 | Discrete/dense/integer frame hierarchy, temporal operators, topology |
| Algebraic Representation | `algebraic-representation` | 112, 125, 992 | Jonsson-Tarski, STSA, literature survey |
| Bilateral Logic | `bilateral` | 953 | Bilateral proof system (acceptance/rejection judgments) |
| Agent System | `agent-system` | 114, 152, 619, 949 | Meta tasks, agent architecture, demo updates |

**Note on task 949** (`update_demo_lean_bimodal_logic`): Could fit `completeness` (showcases completeness results) or `agent-system` (meta/documentation). Assigned to `agent-system` since it is a documentation/demo task rather than a proof task.

**Note on task 125** (`jonsson_tarski_representation`): Has cross-topic dependencies on 116 (`formula-refactor`) and 122 (`frame-extensions`). Assigned to `algebraic-representation` as its primary domain. Cross-topic deps shown with inline annotations.

**Heuristic keyword mapping for backfill**:

| Keyword pattern | Assigned topic |
|----------------|---------------|
| `completeness`, `sorry`, `representation_theorem`, `bfmcs`, `countermodel`, `canonical` | `completeness` |
| `ktype`, `normal_form`, `decidability`, `fmp`, `filtration` | `decidability` |
| `ghfp`, `formula`, `module_organization`, `boneyard`, `cleanup`, `refactor`, `icc_finite` | `formula-refactor` |
| `frame_hierarchy`, `discrete`, `dense`, `integer`, `open_set`, `time_addition`, `tense` | `frame-extensions` |
| `algebraic`, `jonsson`, `tarski`, `representation`, `stsa`, `boolean_algebra` | `algebraic-representation` |
| `bilateral`, `proof_system`, `acceptance`, `rejection` | `bilateral` |
| `agent`, `architecture`, `demo`, `task_order`, `rules`, `compliance`, `meta` | `agent-system` |

### 7. Proposed Output Format Design

The new Task Order section uses `### TopicName` headings inside `## Task Order`. Within each topic section, connected components with internal edges are shown as named subtrees; isolated tasks are grouped in a flat "standalone tasks" block.

```markdown
## Task Order

*Updated 2026-05-15. Generated from state.json dependency graph.*

**Goal**: Sorry-free `bx_completeness` → module reorganization → ...

**Dependency Waves**:
| Wave | Tasks | Blocked by | Topics |
|------|-------|------------|--------|
| 1 | 8,18,60,64,68,95,112,114,116,122,126,... | -- | completeness, formula-refactor, frame-extensions, algebraic-representation, bilateral, agent-system |
| 2 | 20,21,125,128 | 18,116,122 | completeness, frame-extensions, algebraic-representation |

### Completeness
```
18 [BLOCKED] — Wire the TimelineQuot BFMCS and DenseTask-based TaskFrame ℚ
  └─ 20 [NOT STARTED] — Review ParametricCanonical.lean, ParametricTruthLemma.lean
  └─ 21 [PLANNED] — Clean up technical debt accumulated across tasks 9-20
8 [RESEARCHED] — genuine_truth_at_completeness
64 [RESEARCHED] — critical_path_review
68 [RESEARCHED] — prove_dense_completeness_fc_via_rat
95 [NOT STARTED] — completeness_verification_audit
142 [RESEARCHED] — mixed_case_countermodel
```

### Decidability
```
143 [PARTIAL] — doets_lemma_1_1_normal_form_ktype
```

### Formula Refactor
```
116 [PLANNED] — redefine_ghfp_via_until_since
60 [NOT STARTED] — remove_discrete_icc_finite_axiom
130 [NOT STARTED] — archive_dead_sorries_to_boneyard
131 [NOT STARTED] — refactor_module_organization
```

### Frame Extensions
```
122 [RESEARCHED] — discrete_bfmcs_countermodel
  └─ 128 [NOT STARTED] — open_set_operator_dense_continuous
126 [RESEARCHED] — frame_hierarchy_dense_discrete_integer_extensions
127 [NOT STARTED] — time_addition_operator
998 [RESEARCHING] — fmp_redesign_strict_temporal
```

### Algebraic Representation
```
125 [NOT STARTED] — jonsson_tarski_representation_bimodal_sus
  └─ 116 [PLANNED] — (formula-refactor: redefine_ghfp_via_until_since) (see above)
  └─ 122 [RESEARCHED] — (frame-extensions: discrete_bfmcs_countermodel) (see above)
112 [RESEARCHED] — literature_study_representation_theorem
992 [RESEARCHED] — shift_closed_tense_s5_algebra
```

### Bilateral
```
953 [RESEARCHED] — refactor_proof_system_to_bilateral
```

### Agent System
```
619 [RESEARCHED] — agent_system_architecture_upgrade
114 [NOT STARTED] — plan_compliance_rule_for_implementation_agents
152 [RESEARCHING] — task_order_topic_grouping
949 [RESEARCHED] — update_demo_lean_bimodal_logic
```

## Tasks
```

**Design decisions in this format**:

1. **Wave table**: Add a `Topics` column listing which topic categories appear in each wave. Since wave 1 is crowded, this gives a quick index. The Topics value can be a comma-separated list of topic names (truncated to first 3 if more than 3 topics).

2. **Topic headings**: `### TopicName` (level 3 heading) fits naturally inside `## Task Order` (level 2). Does not conflict with `## Tasks` (level 2) section boundary detection.

3. **Within a topic**: All tasks — whether in a connected component or isolated — appear in a single code block. Tasks with active dependencies show them indented below (same DFS convention as current format). Component boundaries are implicit in the tree structure.

4. **Cross-topic deps**: When task 125 depends on 116 (a different topic), those dep entries appear indented under 125 with a `(topic-name: desc)` annotation. The `(see above)` convention is extended with the topic name for clarity.

5. **Task ordering within topic block**: Roots first (sorted numerically), then tasks with deps follow in DFS order. This preserves the current "deps appear below their dependents" convention.

6. **Uncategorized fallback**: If a task has no `topic` field (or an unknown value), it appears in an `### Uncategorized` section at the end.

7. **Topics column in wave table**: Optional enhancement. Can be omitted in v1 if it makes the table too wide. The core improvement is the topic-grouped tree.

### 8. update-task-status.sh Compatibility

**Mode A** (in-place status update for non-terminal transitions) uses:
```bash
order_line=$(grep -n -E "^\s*(└─ )?${task_number} \[" "$TODO_FILE" | head -1 | cut -d: -f1)
```

This searches the entire file for lines matching the task number pattern. Since code block entries still use the same `{task_num} [{STATUS}] — {desc}` format (just under different headings), Mode A requires **no changes**.

**Mode B** (full regeneration for terminal transitions) calls `generate-task-order.sh --update-todo`, which will automatically use the new grouped format. **No changes needed**.

**Conclusion**: `update-task-status.sh` is fully backward-compatible with the proposed format.

### 9. Section Parsing Compatibility

`replace_section()` in `generate-task-order.sh` finds boundaries by:
- Start: `^## Task Order$`
- End: next line matching `^## ` (but not `### `)

Since `### TopicName` headings are level-3 (start with `### ` not `## `), they do not match the end-of-section boundary. The replacement logic works unchanged.

`read_existing_goal()` reads the Goal line with `^\*\*Goal\*\*: (.+)$` — unchanged.

---

## Decisions

1. **Topics over components as primary grouping**: With only 2 non-trivial connected components and 20 isolated nodes, topic-based grouping provides dramatically more useful clustering. Connected components are rendered implicitly through the tree indentation within each topic block.

2. **`topic` field as optional string**: Using a string (not an enum) keeps the schema flexible for future topic categories. The script degrades gracefully when the field is absent.

3. **Seven canonical topics**: `completeness`, `decidability`, `formula-refactor`, `frame-extensions`, `algebraic-representation`, `bilateral`, `agent-system`. These cover all 26 active tasks with no outliers.

4. **Cross-topic deps annotated inline**: When a dep belongs to a different topic, the annotation `(topic-name: desc)` is added to make the cross-cutting relationship explicit without duplicating the full subtree.

5. **Single code block per topic**: One ```...``` block per topic section (containing all tasks for that topic, with DFS tree rendering). This is simpler than one block per connected component and keeps related isolated tasks together.

6. **Topics column in wave table**: Recommended for v1 since it adds the most value (quick index of what's happening in each wave). Can be a comma-separated, truncated list.

7. **Backfill via jq**: One-shot `jq` command to add `topic` field to all existing active tasks using the keyword-matching heuristics. Run once during implementation; future tasks set `topic` at creation time via `/task` command prompt.

---

## Recommendations

### Priority 1: Core Implementation

1. **Add `load_topics()` to generate-task-order.sh** (after `build_graph()`):
   ```bash
   declare -A task_topic  # task_num -> topic string
   load_topics() {
     local topics_data
     topics_data=$(jq -r '.active_projects[] | ... | "\(.project_number)|\(.topic // "uncategorized")"' "$STATE_FILE")
     while IFS='|' read -r tn topic; do
       [[ -n "$tn" ]] && task_topic["$tn"]="$topic"
     done <<< "$topics_data"
   }
   ```

2. **Add `compute_connected_components()` using Union-Find** (after `compute_waves()`). Returns `cc_root[task_num]` — the canonical representative for each component. See Section 5 above for the complete 25-line implementation.

3. **Replace `generate_dependency_tree()` with `generate_grouped_section()`**:
   - Collect the canonical topic order (ordered list of distinct topics actually present).
   - For each topic, filter tasks by topic, then run DFS only over those tasks.
   - Emit `### TopicName` heading + single fenced code block.
   - Cross-topic deps get `(topic-name: desc)` annotation.

4. **Update `generate_wave_table()`** to add a `Topics` column showing which topics appear in each wave.

5. **Update `generate_section()`** to call new functions in place of old ones.

### Priority 2: Schema and Documentation

6. **Add `topic` field to `task-order-format.md`**: Document the new format elements (topic headings, component notation, cross-topic dep annotation syntax, topic taxonomy table).

7. **Backfill `state.json`**: Write a targeted `jq` one-liner or short script to add `topic` field to all 26 active tasks based on the taxonomy in Section 6. This is idempotent (can safely re-run if fields change).

### Priority 3: Integration

8. **Update `/task` creation flow** to prompt for or infer `topic` when creating new tasks. At minimum, add `topic` to the jq update that writes the new task entry.

9. **Update `task-order-format.md`**'s `Parsing Patterns Summary` table with the new `### TopicName` heading pattern.

---

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Wave table `Topics` column too wide for GitHub rendering | Medium | Truncate to first 3 topics + "..." or omit Topics column from table entirely; keep grouping in tree only |
| Cross-topic deps confuse readers who look for a task in the "wrong" topic section | Low | Consistent `(topic: desc)` annotation makes origin clear; full regen always shows task once per topic |
| `topic` values drift from taxonomy (typos, variations) | Low | Document canonical values in `task-order-format.md`; script prints warning for unknown topic values |
| Bash Union-Find with path compression: parent array mutation during `cc_find` side-effects | Low | Path compression via `cc_parent["$x"]="${cc_parent[...]}"` is safe in bash; test with known graph |
| update-task-status.sh Mode A: task found in multiple code blocks (if format changes) | Very Low | grep returns first match (`head -1`); with one appearance per task this is fine |
| All tasks in one topic creates a still-monolithic block | Low | With 7 topics and max 9 tasks per topic, even the largest topic block is manageable |

---

## Context Extension Recommendations

- **Topic**: Task Order format changes and topic taxonomy
- **Gap**: The current `task-order-format.md` documents the wave+tree format but has no topic grouping section. After this task is implemented, the format spec should be updated to document `### TopicName` headings, the `topic` field schema, and the canonical taxonomy.
- **Recommendation**: Update `.claude/context/formats/task-order-format.md` as part of implementation Phase 3 (format spec update).

---

## Appendix

### A. Active Task List with Proposed Topics

| Task | Status | Topic | Deps (active only) |
|------|--------|-------|-------------------|
| 8 | researched | completeness | — |
| 18 | blocked | completeness | — |
| 20 | not_started | completeness | 18 |
| 21 | planned | completeness | 18 |
| 60 | not_started | formula-refactor | — |
| 64 | researched | completeness | — |
| 68 | researched | completeness | — |
| 95 | not_started | completeness | — |
| 112 | researched | algebraic-representation | — |
| 114 | not_started | agent-system | — |
| 116 | planned | formula-refactor | — |
| 122 | researched | frame-extensions | — |
| 125 | not_started | algebraic-representation | 116, 122 |
| 126 | researched | frame-extensions | — |
| 127 | not_started | frame-extensions | — |
| 128 | not_started | frame-extensions | 122 |
| 130 | not_started | formula-refactor | — |
| 131 | not_started | formula-refactor | — |
| 142 | researched | completeness | — |
| 143 | partial | decidability | — |
| 152 | researching | agent-system | — |
| 619 | researched | agent-system | — |
| 949 | researched | agent-system | — |
| 953 | researched | bilateral | — |
| 992 | researched | algebraic-representation | — |
| 998 | researching | frame-extensions | — |

### B. Keyword Heuristics for Topic Backfill

```bash
assign_topic_heuristic() {
  local name="$1" desc="$2"
  local combined="${name} ${desc}"
  # Order matters: more specific patterns first
  if echo "$combined" | grep -qiE "bilateral|acceptance|rejection"; then
    echo "bilateral"
  elif echo "$combined" | grep -qiE "agent|architecture|demo|task_order|compliance|meta|rules"; then
    echo "agent-system"
  elif echo "$combined" | grep -qiE "jonsson|tarski|stsa|lindenbaum|algebraic|boolean_algebra"; then
    echo "algebraic-representation"
  elif echo "$combined" | grep -qiE "ktype|normal_form|decidab|fmp|filtrat|doets|nequiv"; then
    echo "decidability"
  elif echo "$combined" | grep -qiE "ghfp|formula|module_org|boneyard|icc_finite|refactor|cleanup|reorgani"; then
    echo "formula-refactor"
  elif echo "$combined" | grep -qiE "frame_hier|discrete.*frame|dense.*frame|integer.*frame|open_set|time_add|tense.*s5|fmp|temporal.*operator"; then
    echo "frame-extensions"
  elif echo "$combined" | grep -qiE "completeness|sorry|represent|bfmcs|countermodel|canonical|parametric|chain|saturation"; then
    echo "completeness"
  else
    echo "uncategorized"
  fi
}
```

### C. Implementation Phase Outline

**Phase 1** (~1 hour): Core bash additions to `generate-task-order.sh`
- `load_topics()` function
- `compute_connected_components()` Union-Find
- `generate_grouped_section()` replacing `generate_dependency_tree()`
- Update `generate_wave_table()` with Topics column
- Update `generate_section()` orchestrator

**Phase 2** (~30 min): State.json backfill
- Write jq command to add `topic` field for all 26 active tasks
- Apply and verify output matches taxonomy table

**Phase 3** (~30 min): Format spec update
- Update `task-order-format.md` with new format elements
- Add Topic Taxonomy section
- Update Complete Example
- Update Generation Algorithm description

**Phase 4** (~30 min): Live regeneration and verification
- Run `generate-task-order.sh --update-todo` to produce new grouped output
- Verify Mode A compatibility with spot-check on `update-task-status.sh`
- Verify section boundary detection still works

### D. References

- `.claude/scripts/generate-task-order.sh` — Current implementation (548 lines)
- `.claude/context/formats/task-order-format.md` — Format specification (300 lines)
- `.claude/scripts/update-task-status.sh` — Phase 3 task order update (lines 230-300)
- `specs/state.json` — 26 active tasks analyzed
- `specs/TODO.md` lines 28-74 — Current Task Order section
