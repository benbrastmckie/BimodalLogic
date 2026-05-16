# Task Order Format Standard

**Purpose**: Define the Task Order section format for TODO.md, providing structured task prioritization, dependency visualization, and auto-generation from the state.json dependency graph.

---

## Placement

The `## Task Order` section is placed between the `# TODO` header (and optional YAML frontmatter) and the `## Tasks` section:

```markdown
---
next_project_number: 277
---

# TODO

## Task Order
{task order content}

## Tasks
{individual task entries}
```

---

## Structure Elements

### Section Header

Format: `## Task Order`
Regex: `^## Task Order$`

### Update Timestamp

Format: `*Updated YYYY-MM-DD. Generated from state.json dependency graph.*`
Regex: `^\*Updated (\d{4}-\d{2}-\d{2})\. (.+)\*$`

The changelog summary briefly describes the generation source and any notable context.

Examples:
```markdown
*Updated 2026-05-15. Generated from state.json dependency graph.*
*Updated 2026-05-15. Generated from state.json. Tasks 139-141 archived.*
```

### Goal Statement

Format: `**Goal**: {one-line project goal}`
Regex: `^\*\*Goal\*\*: (.+)$`

The goal is a single-line summary of the current project focus. This line is **preserved across regenerations** — the generation script reads the existing Goal line from TODO.md and retains it unless `--goal` is passed explicitly.

Example:
```markdown
**Goal**: Zero sorries on bx_completeness critical path → module reorganization → extensions.
```

### Optional Status Summary

An optional `**Status**:` line may follow the Goal, providing a prose summary of current progress. This line is also preserved across regenerations.

Format: `**Status**: {prose summary}`

### Topic Headings

When tasks have `topic` fields in state.json, the dependency tree is replaced by topic-grouped sections. Each topic uses a level-3 heading inside `## Task Order`:

Format: `### {Topic Name}` (e.g., `### Completeness`, `### Agent System`)
Regex: `^### (.+)$` (within `## Task Order` boundaries)

Topic headings do NOT trigger the section-end boundary detector (which only matches `^## `), so they are safely contained within the Task Order section.

### Topics Column

The wave table includes a 4th column for topic breakdown per wave:

```markdown
| Wave | Tasks | Blocked by | Topics |
|------|-------|------------|--------|
| 1 | 8,18,60 | -- | completeness, formula-refactor, frame-extensions, ... |
| 2 | 20,21,125 | 18,116,122 | completeness, frame-extensions, algebraic-representation |
```

Topics are listed in canonical order from `active_topics` in state.json. When more than 3 topics appear in a wave, the display is truncated to `first, second, third, ...`.

### Cross-Topic Dependency Annotation

When a task's dependency belongs to a different topic section, the dependency entry shows the source topic inline:

```
### Algebraic Representation
```
125 [NOT STARTED] — Jonsson-Tarski representation...
  └─ 116 [PLANNED] — (formula-refactor: Remove all_future via Until/Since) (see above)
  └─ 122 [RESEARCHED] — (frame-extensions: Build discrete BFMCS on Z) (see above)
```
```

Format: `(topic-name: short description) (see above)` — indicates the task lives in a different topic section and was already rendered there.

Regex: `^(\s*)(└─ )?(\d+) \[([A-Z ]+)\] — \(([a-z-]+): (.+)\) \(see above\)$`

### Topic Taxonomy

The seven canonical topic values for this project:

| Topic | Canonical Value | Description |
|-------|----------------|-------------|
| Completeness | `completeness` | bx_completeness critical path, dense/discrete rep theorems, audits |
| Decidability | `decidability` | Doets normal forms, KType finiteness, FMP |
| Formula Refactor | `formula-refactor` | G/H/F/P as abbreviations, module reorg, dead-code cleanup |
| Frame Extensions | `frame-extensions` | Discrete/dense/integer frame hierarchy, temporal operators, topology |
| Algebraic Representation | `algebraic-representation` | Jonsson-Tarski, STSA, literature survey |
| Bilateral Logic | `bilateral` | Bilateral proof system (acceptance/rejection judgments) |
| Agent System | `agent-system` | Meta tasks, agent architecture, demo updates |

Topics are stored in `state.json` at two levels:
- **Top-level array**: `active_topics: ["completeness", "decidability", ...]` — canonical order for rendering
- **Per-task field**: `"topic": "completeness"` — optional string on each task entry

The keyword heuristic function `assign_topic_heuristic()` in `.claude/scripts/generate-task-order.sh` (lines ~208-235) auto-infers topics from task names and descriptions using the priority order: bilateral > agent-system > algebraic-representation > decidability > formula-refactor > frame-extensions > completeness.

This function is the canonical heuristic for all task-creation commands. When implementing topic assignment in `/task` Step 4.5, `meta-builder-agent` Stage 3.5, `skill-fix-it` Step 9.1, and `/review` Section 5.6.3, apply the same keyword matching pattern rather than duplicating it.

---

## Dependency Waves Section

### Wave Table Header

Format: `**Dependency Waves**:`
Regex: `^\*\*Dependency Waves\*\*:$`

### Wave Table

Immediately follows the header. The wave table has four columns:

```markdown
| Wave | Tasks | Blocked by | Topics |
|------|-------|------------|--------|
| 1 | {task_id_list} | -- | {topic_list} |
| 2 | {task_id_list} | {blocking_ids} | {topic_list} |
```

- **Wave**: Wave number (1 = no active dependencies, 2 = depends only on wave 1, etc.)
- **Tasks**: Comma-separated task IDs in this wave
- **Blocked by**: Task IDs that must complete before this wave can start; `--` if none
- **Topics**: Comma-separated topic names in this wave (from `task_topic` map); `--` if no topics assigned; truncated to first 3 + `...` if more than 3

Wave table row regex (4-column): `^\| (\d+) \| ([\d,]+) \| ([\d,\-]+) \| (.+) \|$`

**Note**: The wave table serves as a quick index. The full task-to-topic mapping is in the grouped sections below.

---

## Grouped Topic Sections

When tasks have `topic` fields in state.json, the dependency tree is replaced by per-topic sections. Each section has a `### TopicName` heading and a single fenced code block:

### Grouped Section Header

Format: `**Grouped by Topic** (indented = must complete first):`
Regex: `^\*\*Grouped by Topic\*\* \(indented = must complete first\):$`

### Topic Section Structure

````markdown
### Completeness
```
8 [RESEARCHED] — genuine_truth_at_completeness
18 [BLOCKED] — Wire the TimelineQuot BFMCS and DenseTask-based TaskFrame ℚ
20 [NOT STARTED] — Review ParametricCanonical.lean, ParametricTruthLemma.lean
  └─ 18 [BLOCKED] — Wire the TimelineQuot BFMCS and DenseTask-based TaskFrame ℚ (see above)
```

### Algebraic Representation
```
112 [RESEARCHED] — literature_study_representation_theorem
125 [NOT STARTED] — Jonsson-Tarski representation bimodal SUS
  └─ 116 [PLANNED] — (formula-refactor: Remove all_future (G) and all_past (H)) (see above)
  └─ 122 [RESEARCHED] — (frame-extensions: Build discrete BFMCS on Z) (see above)
992 [RESEARCHED] — shift_closed_tense_s5_algebra
```
````

### Tree Entries

Each entry shows a task ID, status marker, and short description. Tasks appear in DFS order within their topic block:

**Entry format**: `{indent}{task_id} [{STATUS}] — {short description}`

- Root entries (no active deps): no indent
- Level 1 dependencies: `  └─ ` (2 spaces + `└─ `)
- Level 2 dependencies: `    └─ ` (4 spaces + `└─ `)
- Each additional level: +2 spaces

**Tree entry regex**: `^(\s*)(└─ )?(\d+) \[([A-Z ]+)\] — (.+)$`

**Diamond dependencies**: When a task appears as a dependency of multiple parents within the same topic, it uses `(see above)` on subsequent occurrences.

**Cross-topic dependencies**: When a dependency belongs to a different topic section, it shows the source topic inline:
```
  └─ 116 [PLANNED] — (formula-refactor: Remove all_future via Until/Since) (see above)
```

**Uncategorized fallback**: Tasks without a `topic` field appear in an `### Uncategorized` section at the end (should not appear after backfill).

### Backward Compatibility (Dependency Tree)

The old `**Dependency Tree** (indented = must complete first):` format (pre-2026-05-15) is no longer generated by the script, but remains parseable by `update-task-status.sh` Mode A since tree entry format is unchanged. The `generate_dependency_tree()` function is preserved in the script for debugging purposes.

---

## Status Markers

Task Order entries use the same status markers as TODO.md task entries:

| Marker | Meaning |
|--------|---------|
| `[NOT STARTED]` | Task not yet begun |
| `[RESEARCHING]` | Research in progress |
| `[RESEARCHED]` | Research completed |
| `[PLANNING]` | Plan creation in progress |
| `[PLANNED]` | Plan created, ready for implementation |
| `[IMPLEMENTING]` | Implementation in progress |
| `[COMPLETED]` | Task finished |
| `[BLOCKED]` | Cannot proceed (with reason) |
| `[ABANDONED]` | Task dropped |
| `[PARTIAL]` | Partially complete |
| `[EXPANDED]` | Divided into subtasks |

Status marker regex: `\[([A-Z ]+)\]`

---

## Complete Example

````markdown
## Task Order

*Updated 2026-05-15. Generated from state.json dependency graph.*

**Goal**: Zero sorries on bx_completeness critical path → module reorganization → extensions.

**Dependency Waves**:
| Wave | Tasks | Blocked by | Topics |
|------|-------|------------|--------|
| 1 | 8,18,60,64,142,619,953 | -- | completeness, formula-refactor, bilateral, agent-system |
| 2 | 20,21,125,128 | 18,116,122 | completeness, frame-extensions, algebraic-representation |

**Grouped by Topic** (indented = must complete first):

### Completeness
```
8 [RESEARCHED] — genuine_truth_at_completeness
18 [BLOCKED] — Wire the TimelineQuot BFMCS and DenseTask-based TaskFrame ℚ
20 [NOT STARTED] — Review ParametricCanonical.lean, ParametricTruthLemma.lean
  └─ 18 [BLOCKED] — Wire the TimelineQuot BFMCS and DenseTask-based TaskFrame ℚ (see above)
64 [RESEARCHED] — critical_path_review
142 [RESEARCHED] — mixed_case_countermodel
```

### Algebraic Representation
```
112 [RESEARCHED] — literature_study_representation_theorem
125 [NOT STARTED] — Jonsson-Tarski representation bimodal SUS
  └─ 116 [PLANNED] — (formula-refactor: redefine_ghfp_via_until_since) (see above)
  └─ 122 [RESEARCHED] — (frame-extensions: discrete_bfmcs_countermodel) (see above)
```

### Agent System
```
619 [RESEARCHED] — agent_system_architecture_upgrade
152 [IMPLEMENTING] — task_order_topic_grouping
```

## Tasks
````

---

## Parsing Patterns Summary

| Element | Pattern |
|---------|---------|
| Section header | `^## Task Order$` |
| Timestamp | `^\*Updated (\d{4}-\d{2}-\d{2})\. (.+)\*$` |
| Goal | `^\*\*Goal\*\*: (.+)$` |
| Wave table header | `^\*\*Dependency Waves\*\*:$` |
| Wave table row (4-col) | `^\| (\d+) \| ([\d,]+) \| ([\d,\-]+) \| (.+) \|$` |
| Grouped section header | `^\*\*Grouped by Topic\*\* \(indented = must complete first\):$` |
| Topic heading | `^### (.+)$` (within `## Task Order`) |
| Tree fenced block start | `^\`\`\`` |
| Tree entry | `^(\s*)(└─ )?(\d+) \[([A-Z ]+)\] — (.+)$` |
| Cross-topic dep entry | `^(\s*)(└─ )?(\d+) \[([A-Z ]+)\] — \(([a-z-]+): (.+)\) \(see above\)$` |
| Tree indent level | Count of 2-space units before `└─` or task ID |
| Status marker | `\[([A-Z ]+)\]` |

---

## Generation

The `## Task Order` section is auto-generated by `.claude/scripts/generate-task-order.sh`.

### Script Usage

```bash
# Print to stdout (inspection)
.claude/scripts/generate-task-order.sh --print

# Replace Task Order section in TODO.md
.claude/scripts/generate-task-order.sh --update-todo specs/TODO.md specs/state.json

# Replace section with custom goal line
.claude/scripts/generate-task-order.sh --update-todo specs/TODO.md specs/state.json --goal "Custom goal text"
```

### Generation Algorithm

1. **Filter**: Extract non-terminal tasks from state.json (exclude `completed`, `abandoned`, `expanded`)
2. **Clean dependencies**: Remove dependencies that point to terminal tasks (treat as satisfied)
3. **Load topics**: Read `task_topic[task_num]` from state.json `topic` field; read `active_topics_order[]` from top-level `active_topics` array
4. **Kahn's algorithm**: Compute wave assignments by iteratively removing zero-in-degree nodes
5. **Union-Find**: Compute connected components for implicit subtree grouping
6. **Build wave table**: Group tasks by wave; `Blocked by` = union of active deps; `Topics` = distinct topic names in wave (canonical order, truncated to 3 + `...`)
7. **Build grouped sections**: For each topic in `active_topics_order`, filter tasks, render DFS tree with cross-topic dep annotations; `Uncategorized` fallback for tasks without topic
8. **Replace section**: Replace content between `## Task Order` and next `## ` heading in TODO.md

### Wave Computation

```
in_degree[task] = count of task's active dependencies
wave = 1
queue = tasks where in_degree == 0

while queue not empty:
  assign all queue tasks to current wave
  for each task in queue:
    for each successor (task that depends on current):
      in_degree[successor] -= 1
      if in_degree[successor] == 0: add to next queue
  wave += 1
```

---

## update-task-status.sh Integration

Phase 3 of `update-task-status.sh` updates task status markers in the Task Order tree. It uses a two-mode strategy:

### Mode A: In-Place Status Update (non-terminal transitions)

For status transitions to `RESEARCHING`, `RESEARCHED`, `PLANNING`, `PLANNED`, `IMPLEMENTING`:
- Pattern: `^\s*(└─ )?{task_number} \[` matches tree lines at any indent level
- Action: Replace `[OLD_STATUS]` with `[NEW_STATUS]` on the matched line

### Mode B: Full Regeneration (terminal transitions)

For transitions to `COMPLETED`, `ABANDONED`, `EXPANDED`:
- Call `generate-task-order.sh --update-todo` to rebuild the entire section
- This auto-prunes the completed task from both wave table and tree
- Also fires when `--clean` flag is passed to `update-task-status.sh`

---

## Related

- @.claude/scripts/generate-task-order.sh — Auto-generation script
- @.claude/scripts/update-task-status.sh — Phase 3 status update (uses patterns above)
- @.claude/context/formats/roadmap-format.md — ROADMAP.md structure
- @.claude/rules/state-management.md — Task status management
- @.claude/rules/artifact-formats.md — Status marker definitions

---

## Appendix: Previous Format (Historical Reference)

The previous format (before 2026-05-15) used flat category subsections with arrow-chain dependency notation:

```markdown
### 1. Critical Path -- Sorry-Free Completeness

```
63 → 58 → 59 → 60
```

1. **63** [RESEARCHED] -- Prove Box backward via BFMCS modal saturation
2. **58** [NOT STARTED] -- Wire completeness to FrameConditions

### 2. Code Cleanup (parallel to critical path)
...
```

This format required manual curation of categories and dependency chains, and did not auto-prune completed tasks. It was replaced by the wave+tree format for automated generation from state.json.
