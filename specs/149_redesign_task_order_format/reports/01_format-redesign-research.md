# Research Report: Task #149

**Task**: 149 - Redesign Task Order Format and Generation Script
**Started**: 2026-05-15T18:35:00Z
**Completed**: 2026-05-15T19:10:00Z
**Effort**: 1.5 hours
**Dependencies**: None
**Sources/Inputs**:
- `.claude/context/formats/task-order-format.md` — current format spec
- `specs/TODO.md` lines 28–91 — current Task Order content
- `.claude/scripts/update-task-status.sh` — Phase 3 status update logic
- `specs/state.json` — full dependency graph
- `.claude/context/formats/plan-format.md` — Dependency Analysis wave table pattern
- `.claude/scripts/update-recommended-order.sh` — existing topological sort infrastructure
**Artifacts**: `specs/149_redesign_task_order_format/reports/01_format-redesign-research.md`
**Standards**: report-format.md, subagent-return.md

---

## Executive Summary

- The current Task Order uses flat category sections with inline arrow chains; it conveys no wave-level parallelism and status markers drift from state.json between commands.
- The replacement design uses two complementary views: a **wave table** (quick parallel-execution overview) and an **indented dependency tree** (per-task relationship display), both auto-generated from state.json.
- An existing `update-recommended-order.sh` script already contains all three algorithmic components needed (topological sort, dependency traversal, section replacement) and should be adapted rather than replaced.
- Phase 3 of `update-task-status.sh` currently targets only `- **{N}** [STATUS]` bullet patterns; the new format requires different patterns and a regeneration strategy for completed-task pruning.
- The new format removes the manual category-maintenance burden: the script derives execution waves from the dependency DAG automatically, and completed tasks are pruned on every regeneration.
- Interaction with `/todo`, `/review`, `/task`: all three commands need minor changes (hooks into `generate-task-order.sh`) but none require deep surgery.

---

## Context & Scope

### What was researched

1. The current `task-order-format.md` spec (296 lines): flat categories, arrow chains, ordered/unordered task entries, inline dependency notes.
2. The live Task Order in `specs/TODO.md` (lines 28–91): 6 Phase categories with numbered task entries, a Status/Goal/Goal description header block.
3. `update-task-status.sh` Phase 3 (`update_todo_task_order`): grepping for `- **{N}** [STATUS]` bullet form; the current TODO.md Task Order does NOT use this exact pattern (it uses `{N}. **{task_number}** [STATUS]` numbered list entries), indicating Phase 3 is a no-op on the live file.
4. `update-recommended-order.sh` (709 lines): full Kahn's-algorithm topological sort, `get_dependents`, section replacement machinery — all reusable.
5. `state.json`: 31 active projects; dependency arrays are well-populated. Terminal statuses to filter: `completed`, `abandoned`, `expanded`.

### Key constraints

- Must be generatable from state.json alone (no manual curation after initial setup).
- Auto-pruning completed tasks on every regeneration (no stale entries).
- update-task-status.sh Phase 3 must remain fast (no full regeneration on every status change — only on `completed` postflight).
- Must be backward-compatible with the existing `## Task Order` header sentinel for parsing.

---

## Findings

### Codebase Patterns

**Phase 3 of update-task-status.sh is effectively broken for the current format**

The grep pattern is:
```bash
order_line=$(grep -n -E "^- \*\*${task_number}\*\* \[" "$TODO_FILE" | head -1 | cut -d: -f1)
```

This targets `- **N** [STATUS]` (unordered bullet). The live Task Order uses:
```
1. **142** [RESEARCHED] — Mixed-case countermodel...
```
which is a numbered list entry. The grep finds no match, so Phase 3 silently no-ops on every status change. This means the Task Order is already drifting from state.json.

**update-recommended-order.sh already implements the hard parts**

The `topological_sort()` function in that script implements Kahn's algorithm correctly, including:
- Filtering terminal tasks (`completed`, `abandoned`, `expanded`)
- Counting in-degree only from active (non-terminal) dependencies
- Handling cycles with a warning
- Outputting tasks in dependency-first order

The `get_dependents()` function gets reverse edges (what a task unblocks). Both are directly reusable.

**state.json dependency arrays are well-populated**

Key dependency chains extracted:
- `148` depends on `[147]`
- `147` depends on `[]` (independent)
- `146` depends on `[145]`
- `145` depends on `[143]`
- `143` depends on `[139]` (139 is completed/archived, so 143 is effectively a root)
- `128` depends on `[122]`
- `122` depends on `[123]` (123 completed, so 122 is a root)
- `125` depends on `[123, 124, 122, 116, 115]`
- `142` depends on `[]` (independent)
- `150, 151` both depend on `[149]`

**Existing "Recommended Order" section is unused**

`specs/TODO.md` lines 522–527 show two duplicate `## Recommended Order` headers with empty content, suggesting the `update-recommended-order.sh` script was never wired up. The new design replaces this with the enhanced `## Task Order` section.

### Wave Computation from Active Tasks

Applying Kahn's algorithm to the non-terminal tasks from state.json, the waves are:

| Wave | Tasks | Reason |
|------|-------|--------|
| 1 | 142, 147, 60, 8, 112, 64, 68, 992, 953, 949, 619, 998, 143, 122 | No active dependencies |
| 2 | 148, 145, 128 | Depend only on wave-1 tasks |
| 3 | 146 | Depends on 145 (wave 2) |
| 4 | 125 | Depends on 122 (wave 1) + 116 (wave ?) |

Note: tasks 116, 21, 131, 131, 150, 151, 149 etc. also appear. The tree should only show a **focus subset** — non-backlog active tasks on the critical path. The script should have a configurable threshold or show all non-terminal tasks.

### Format Design

#### A. Wave Table

```markdown
**Dependency Waves**:
| Wave | Tasks | Blocked by |
|------|-------|------------|
| 1 | 142, 147 | -- |
| 2 | 148 | 147 |
| 3 | 145 | 143 |
| 4 | 146 | 145 |
```

Matches the plan-format.md Dependency Analysis table pattern exactly — same column names, same `--` for no blockers.

#### B. Indented Dependency Tree

Trees are built by DFS from roots (tasks with no active dependencies). Leaves (dependencies) are indented further — meaning a child is something that must be done first (a blocker/prerequisite), not something triggered after.

Convention (matching user-specified direction): deeper indentation = must-complete-first.

```
148 [RESEARCHED] — Complete table_correctness temporal cases
  └─ 147 [RESEARCHED] — Prove lift_eval and insertEnv lemmas
146 [RESEARCHED] — NormalForm cleanup
  └─ 145 [RESEARCHED] — Split NEquivalence, redesign KType
    └─ 143 [PARTIAL] — Doets Lemma 1.1
142 [RESEARCHING] — Mixed-case countermodel (independent)
```

Each root task (no active dependencies, or all dependencies completed) is at the leftmost level. Its active dependencies are indented one level beneath it with `  └─`. Multi-parent tasks (diamond dependencies) appear under each parent but should include a note.

#### C. Section Header Block

```markdown
## Task Order

*Updated 2026-05-15. Generated from state.json dependency graph.*

**Goal**: Zero sorries on bx_completeness critical path → module reorganization → extensions.

**Dependency Waves**:
| Wave | Tasks | Blocked by |
|------|-------|------------|
| 1 | 142, 147 | -- |
| 2 | 148 | 147 |
...

**Dependency Tree** (indented = must complete first):
148 [RESEARCHED] — Complete table_correctness temporal cases
  └─ 147 [RESEARCHED] — Prove lift_eval and insertEnv lemmas
...
```

### Generation Algorithm

```
generate-task-order.sh algorithm:

INPUT: specs/state.json

1. FILTER: Extract non-terminal projects
   statuses: not (completed | abandoned | expanded)
   → active_tasks = list of {id, status, dependencies, description}

2. CLEAN DEPENDENCIES: For each task, remove deps that are terminal
   (dep not in active_tasks → ignore it)
   → clean_deps[task] = list of dep_ids still in active_tasks

3. KAHN'S ALGORITHM (compute waves):
   in_degree[task] = len(clean_deps[task])
   wave = 1
   wave_assignments = {}
   queue = tasks where in_degree == 0
   while queue not empty:
     for task in queue:
       wave_assignments[task] = wave
     next_queue = []
     for task in queue:
       for successor in tasks where task in clean_deps[successor]:
         in_degree[successor] -= 1
         if in_degree[successor] == 0:
           next_queue.append(successor)
     queue = next_queue
     wave += 1

4. BUILD WAVE TABLE:
   group tasks by wave number
   for each wave (sorted):
     blocked_by = union of clean_deps of tasks in this wave
     emit: | wave | task_ids | blocked_by_ids or -- |

5. BUILD DEPENDENCY TREE:
   roots = tasks where clean_deps[task] == []
   For each root (sorted by task id):
     print_tree(root, indent=0)
   
   print_tree(task, indent):
     status = active_tasks[task].status → format as [STATUS]
     description = first 60 chars of description
     emit: {indent_prefix}task_id [STATUS] — description
     for dep in clean_deps[task] (sorted):
       emit: {indent_prefix + "  "}└─ (recurse into dep)
   
   Note: dep under task = "dep must complete first"
   (This is REVERSE of typical tree notation — child is blocker)

6. GENERATE MARKDOWN:
   emit ## Task Order header
   emit timestamp line
   emit Goal line (read from existing Task Order or use default)
   emit blank line
   emit Dependency Waves table
   emit blank line  
   emit Dependency Tree section
   emit blank line

7. REPLACE section in TODO.md between ## Task Order and next ## heading
```

### update-task-status.sh Phase 3 Changes

**Current behavior**: grep for `- **{N}** [` pattern → update status in place.

**Problem 1**: The pattern doesn't match the current numbered-list entries.
**Problem 2**: The new wave+tree format has task IDs inline in pipe-delimited table cells and indented tree lines — neither is easily in-place patchable by sed.

**Recommended approach**: Two-mode operation

```
Mode A: In-place status update (non-terminal transitions)
  - Keep for speed; update the pattern to match tree format
  - New tree pattern: `^(\s*(?:└─ )?){task_number} \[`
  - Replace [OLD_STATUS] with [NEW_STATUS] on that line

Mode B: Full regeneration (completed/abandoned/expanded transitions)
  - On postflight:implement (status → completed), call generate-task-order.sh
  - This auto-prunes the completed task from tree and waves
  - Slower but correct; only called once per task completion
```

**Specific changes to update-task-status.sh Phase 3**:

```bash
update_todo_task_order() {
  # ...
  
  # Try in-place update for non-terminal statuses
  if [[ "$TODO_STATUS" != "COMPLETED" && "$TODO_STATUS" != "ABANDONED" ]]; then
    # New pattern: matches tree lines like "148 [RESEARCHED]" or "  └─ 147 [RESEARCHED]"
    local order_line
    order_line=$(grep -n -E "^\s*(└─ )?${task_number} \[" "$TODO_FILE" | head -1 | cut -d: -f1)
    
    # Also match wave table cells: | 1 | 142, 147 | -- | (harder, skip for now)
    # Status is only shown in tree lines, not wave table, so this is sufficient
    
    if [[ -z "$order_line" ]]; then
      echo "Warning: task $task_number not found in Task Order tree" >&2
      return 0
    fi
    
    local current_order_status
    current_order_status=$(sed -n "${order_line}p" "$TODO_FILE" | grep -oE '\[([A-Z ]+)\]' | head -1 | tr -d '[]')
    
    sed -i "${order_line}s/\[${current_order_status}\]/[${TODO_STATUS}]/" "$TODO_FILE"
    
  else
    # Terminal status: regenerate entire Task Order section
    local gen_script="$SCRIPT_DIR/generate-task-order.sh"
    if [[ -x "$gen_script" ]]; then
      "$gen_script" --update-todo "$TODO_FILE" "$STATE_FILE" || {
        echo "Warning: generate-task-order.sh failed (non-fatal)" >&2
      }
    fi
  fi
}
```

### Interaction with Other Commands

**`/todo` command**:
- Currently calls `update-recommended-order.sh refresh` via postflight
- After task 151, should call `generate-task-order.sh --update-todo` instead
- The `/todo` archive flow removes completed tasks from state.json → regeneration auto-prunes them
- For task 149: add `generate-task-order.sh` call to postflight-research.sh or directly in todo.md

**`/review` command**:
- Currently reads Task Order for context (Section 6.5 per task 151)
- No changes needed for task 149 — the new format is more parseable, not less
- Task 151 will update /review to use the new format

**`/task` command**:
- Currently does not auto-insert into Task Order (task 150 handles this)
- For task 149: the script should be callable standalone; /task auto-insert is out of scope

**`/implement` postflight**:
- `postflight-implement.sh` calls `update-task-status.sh postflight ... implement ...`
- This triggers Phase 3 Mode B (regeneration) when status → completed
- No separate hook needed

---

## Proposed New Format Spec (complete)

### Section Structure

```markdown
## Task Order

*Updated {YYYY-MM-DD}. Generated from state.json dependency graph.*

**Goal**: {one-line project goal}

**Dependency Waves**:
| Wave | Tasks | Blocked by |
|------|-------|------------|
| 1 | {task_id_list} | -- |
| 2 | {task_id_list} | {blocking_ids} |
...

**Dependency Tree** (indented = must complete first):
```
{task_id} [{STATUS}] — {short description}
  └─ {dep_id} [{STATUS}] — {short description}
    └─ {dep_dep_id} [{STATUS}] — {short description}
{independent_task_id} [{STATUS}] — {short description}
```
```

### Parsing Patterns (new spec)

| Element | Pattern |
|---------|---------|
| Section header | `^## Task Order$` |
| Timestamp | `^\*Updated (\d{4}-\d{2}-\d{2})\. (.+)\*$` |
| Goal | `^\*\*Goal\*\*: (.+)$` |
| Wave table header | `^\*\*Dependency Waves\*\*:$` |
| Wave table row | `^\| (\d+) \| ([\d, ]+) \| ([\d, --]+) \|$` |
| Tree header | `^\*\*Dependency Tree\*\*` |
| Tree entry | `^(\s*)(└─ )?(\d+) \[([A-Z ]+)\] — (.+)$` |
| Tree indent level | count of 2-space units before `└─` or task id |

### Status Markers

Same as before: `[NOT STARTED]`, `[RESEARCHING]`, `[RESEARCHED]`, `[PLANNING]`, `[PLANNED]`, `[IMPLEMENTING]`, `[COMPLETED]`, `[BLOCKED]`, `[PARTIAL]`, `[EXPANDED]`, `[ABANDONED]`.

---

## Concrete Example: Current → New

### Current Task Order (from TODO.md lines 29–91)

```
### Phase 1: Sorry-Free `bx_completeness`
**Mixed-case countermodel** (1 sorry):
1. **142** [RESEARCHED] — Mixed-case countermodel...
**Table correctness completion** (2 sorries):
2. **147** [RESEARCHED] — Prove lift_eval...
3. **148** [RESEARCHED] — Complete table_correctness...
...

### Phase 6: Publication Quality
- **95** [NOT STARTED] — Verification audit...
```

### New Task Order (generated from state.json)

```markdown
## Task Order

*Updated 2026-05-15. Generated from state.json dependency graph.*

**Goal**: Zero sorries on bx_completeness critical path → module reorganization → extensions.

**Dependency Waves**:
| Wave | Tasks | Blocked by |
|------|-------|------------|
| 1 | 142, 147, 143, 122, 60, 112, 64, 68, 8, 953, 949, 992, 619, 998, 114 | -- |
| 2 | 148, 145, 128 | 147, 143, 122 |
| 3 | 146 | 145 |
| 4 | 125 | 116, 122 |

**Dependency Tree** (indented = must complete first):
```
148 [RESEARCHED] — Complete table_correctness temporal cases
  └─ 147 [RESEARCHED] — Prove lift_eval and insertEnv lemmas
146 [RESEARCHED] — NormalForm cleanup and cardinality
  └─ 145 [RESEARCHED] — Split NEquivalence, redesign KType
    └─ 143 [PARTIAL] — Doets Lemma 1.1: normal form KType
128 [NOT STARTED] — Open set operator for dense/continuous frames
  └─ 122 [RESEARCHED] — Build discrete BFMCS on Z
142 [RESEARCHED] — Mixed-case countermodel (independent)
60 [NOT STARTED] — Clean up stale axiom references (independent)
114 [NOT STARTED] — Plan-compliance rule for agents (independent)
```
```

Note: backlog tasks (953, 949, 8, 68, etc.) can be placed in a separate collapsed section or omitted from the tree with a footnote count.

---

## Decisions

1. **Tree child = blocker** (not triggered-by): the user specified "leaves are blockers, must complete before parent." In the output, a task's deps appear BELOW it with indentation, meaning "to do 148 you first need 147." This is reverse of typical org-chart trees but matches the stated requirement.

2. **Wave table uses task IDs only** (no status): status is shown in the tree, not repeated in the table. Keeps the table compact.

3. **In-place update for non-terminal, full regeneration for terminal**: balances speed (most updates are non-terminal) with correctness (pruning requires regeneration).

4. **Goal line is preserved from existing content** on refresh: the script reads the current Goal line from TODO.md; if absent, uses a default. This prevents overwriting user-customized goals on every regeneration.

5. **`generate-task-order.sh` is a new script** (not a modification of `update-recommended-order.sh`): the `Recommended Order` section has a different purpose (simple numbered action list). The new script outputs the `Task Order` section with two sub-formats.

6. **Backlog separation**: tasks with no dependency relationships AND status `researched`/`planned` from low-priority domains (953, 949, 992, etc.) can be collapsed into a "Backlog" count line: `(+8 backlog tasks not shown)`. This keeps the tree focused on actionable work.

---

## Recommendations

### Priority 1: New spec file

Replace `.claude/context/formats/task-order-format.md` with the new wave+tree spec. The old category format can be preserved as historical context in an Appendix section.

### Priority 2: generate-task-order.sh

Create `.claude/scripts/generate-task-order.sh` with:
- `--print`: output to stdout (for inspection)
- `--update-todo FILE STATE`: replace `## Task Order` section in FILE using STATE
- `--goal "text"`: override the Goal line

Reuse `topological_sort()` logic from `update-recommended-order.sh` (copy or source it). The script is ~200 lines of bash.

### Priority 3: update-task-status.sh Phase 3

Modify `update_todo_task_order()`:
- Change grep pattern to match tree format: `^\s*(└─ )?{task_number} \[`
- For `COMPLETED`/`ABANDONED` transitions: call `generate-task-order.sh --update-todo` instead of in-place sed

### Priority 4: Wire into /todo postflight

Add `generate-task-order.sh --update-todo` call to `postflight-research.sh` or the `/todo` command's archive phase. This ensures the Task Order is refreshed after every archive run.

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Tree with 30+ tasks is too long to be useful | Add backlog threshold: only show tasks with priority or recent activity; rest shown as count |
| Diamond dependencies (multi-parent) appear under each parent, confusing the tree | Add `(also needed by N)` annotation or deduplicate with a note |
| Goal line gets overwritten on regeneration | Script reads and preserves existing Goal line; only overwrites if `--goal` flag passed |
| Circular dependencies cause infinite DFS | Detect cycles before tree generation; emit warning and skip cycle members |
| Script is slow for large state.json | jq extraction is O(n); Kahn's is O(V+E); for <100 tasks this is <1 second |
| Phase 3 regex mismatch on indented lines (spaces + └─) | Use `grep -E` with `^\s*(└─ )?{N} \[` pattern; test with dry-run |

---

## Context Extension Recommendations

- **Topic**: Task Order auto-generation pattern
- **Gap**: There is no documented pattern for auto-generating TODO.md sections from state.json dependency data
- **Recommendation**: Add a new context file `.claude/context/patterns/task-order-generation.md` documenting the wave computation and tree traversal patterns, to help future implementers understand the design intent

---

## Appendix

### Files read
- `/home/benjamin/Projects/ProofChecker/.claude/context/formats/task-order-format.md` (296 lines)
- `/home/benjamin/Projects/ProofChecker/specs/TODO.md` (full, 527 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/scripts/update-task-status.sh` (336 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/scripts/update-recommended-order.sh` (709 lines)
- `/home/benjamin/Projects/ProofChecker/specs/state.json` (810 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/context/formats/plan-format.md` (148 lines)

### Active task dependency graph summary (from state.json)

```
142  → (none)
147  → (none)
148  → [147]
143  → [139*completed*]   # effectively a root
145  → [143]
146  → [145]
122  → [123*completed*]   # effectively a root
128  → [122]
125  → [123*, 124*, 122, 116, 115*]
116  → [107*]             # effectively a root
126  → [123*, 129*]       # effectively a root
130  → [129*]             # effectively a root
131  → (none)
150  → [149]
151  → [149]
```

(* = completed/absent from active_projects, treated as satisfied)

### Wave table (derived)

| Wave | Tasks | Blocked by |
|------|-------|------------|
| 1 | 142, 147, 143, 122, 116, 126, 130, 131, 60, 8, 112, 64, 68, 992, 953, 949, 619, 998, 114, 149, 95, 20, 21, 18 | -- |
| 2 | 148, 145, 128, 125, 150, 151 | 147, 143, 122, 116, 149 |
| 3 | 146 | 145 |

Note: many "wave 1" tasks are backlog/deferred; the script should distinguish active-focus tasks from backlog using priority fields or a configurable filter.
