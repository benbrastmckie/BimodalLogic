# Research Report: Task #151

**Task**: 151 - Task Order Command Integration
**Started**: 2026-05-15T19:15:00Z
**Completed**: 2026-05-15T19:55:00Z
**Effort**: 45 minutes
**Dependencies**: Task #149 (completed)
**Sources/Inputs**:
- `.claude/commands/todo.md` — full /todo command specification (1014 lines)
- `.claude/commands/review.md` — full /review command specification (1570 lines)
- `.claude/scripts/generate-task-order.sh` — auto-generation script created by Task 149 (~540 lines)
- `.claude/context/formats/task-order-format.md` — new wave+tree format spec (300 lines)
- `.claude/rules/state-management.md` — current sync rules
- `specs/149_redesign_task_order_format/reports/01_format-redesign-research.md` — Task 149 research
- `specs/149_redesign_task_order_format/plans/01_task-order-redesign.md` — Task 149 plan (completed)
- `specs/149_redesign_task_order_format/summaries/01_task-order-redesign-summary.md` — Task 149 completion
- `specs/TODO.md` lines 28–82 — live Task Order section (current wave+tree format)
**Artifacts**: `specs/151_task_order_command_integration/reports/01_command-integration.md`
**Standards**: report-format.md, subagent-return.md

---

## Executive Summary

- Task 149 has been completed: `generate-task-order.sh` exists and is functional, producing wave tables and dependency trees from state.json; the new wave+tree format is live in TODO.md.
- The `/todo` command currently has **no call** to `generate-task-order.sh`; Task Order regeneration must be added at Step 5 (after archiving tasks and moving directories), before the git commit in Step 6.
- The `/review` command's Section 2.6 parses Task Order using the old flat-category format (ordered/unordered task entry regexes, code block arrow chains). The parsing logic must be replaced to consume the new wave+tree format.
- The `/review` command's Sections 6.5 (Prune Task Order) must be replaced with a `generate-task-order.sh --update-todo` call; the complex manual pruning code is no longer needed.
- `state-management.md` currently has no Task Order sync rules; two rules should be added: (1) Task Order regeneration triggers, and (2) who is responsible for Task Order updates vs. state.json/TODO.md sync.
- The implementations are straightforward insertions/replacements — no architectural changes are required.

---

## Context & Scope

### What was researched

1. The `/todo` command archive flow in `commands/todo.md` — all 1014 lines — to identify the exact insertion point for Task Order regeneration.
2. The `/review` command in `commands/review.md` — all 1570 lines — to identify the Task Order parsing (Section 2.6) and pruning (Section 6.5) sections that use the old format.
3. The `generate-task-order.sh` script to understand its interface (`--print`, `--update-todo FILE STATE`, `--goal TEXT`).
4. The `task-order-format.md` spec to understand the new wave+tree parsing patterns.
5. The `state-management.md` rules file to understand existing sync rules and identify gaps.
6. Task 149 artifacts to confirm what was built and what was explicitly deferred.

### Key constraint from Task 149

Task 149's "Non-Goals" explicitly stated that wiring `generate-task-order.sh` into `/todo` and `/review` was task 151 scope. The summary confirms this: the script is complete and tested; no integration was done yet.

---

## Findings

### Finding 1: /todo has no Task Order regeneration

The `/todo` command flow:
1. Parse arguments
2. Scan for archivable tasks
3. Prepare archive list
4. Scan roadmap
5. Archive tasks (Steps 5A–5F: update archive/state.json, update state.json, update TODO.md, move directories, handle orphans, handle misplaced)
5.5. Update Roadmap
5.6. Sync repository metrics
5.7. Vault operation (if needed)
6. Git commit
7. Output

There is no reference to `generate-task-order.sh` or Task Order anywhere in `commands/todo.md`. The correct insertion point is a new **Step 5.8** (after 5.6, before 5.7/vault):

```
5.8. Regenerate Task Order
```

This step should call `generate-task-order.sh --update-todo` after archiving is complete (state.json is updated, completed tasks are removed from active_projects), so the regenerated wave table and tree correctly omit the archived tasks.

**Why after step 5.6**: At step 5.5, state.json already has the archived tasks removed (Step 5B). The `generate-task-order.sh` script reads state.json directly, so it will naturally omit archived tasks. Placing regeneration after 5.6 (metrics sync) keeps it logically grouped with TODO.md side-effects.

**Why before 5.7 (vault)**: The vault operation renumbers tasks, which would invalidate a Task Order generated before renumbering. If vault is triggered, Task Order should be regenerated again after renumbering — but vault is rare. A pragmatic approach: regenerate once after 5.6, then again after 5.7 if vault occurred.

### Finding 2: /review's Section 2.6 uses old flat-category format

Section 2.6 of `review.md` ("Parse Task Order") uses parsing patterns designed for the pre-task-149 format. Specifically, it parses:
- `### {N}. {category_name}` — category subsection headers (flat-category format)
- `` ``` `` fenced blocks for arrow chains like `63 → 58 → 59 → 60`
- Ordered entries: `^\d+\.\s+\*\*(\d+)\*\*\s+\[([A-Z ]+)\]\s+--\s+(.+)$`
- Unordered entries: `^-\s+\*\*(\d+)\*\*\s+\[([A-Z ]+)\]\s+--\s+(.+)$`
- Inline dependency notes: `\(depends on ([\d,\s]+)\)`

None of these patterns match the current wave+tree format. The `task_order_state` JSON structure it builds (with `categories`, `dependency_chain`, etc.) reflects the old format's categorical groupings.

The new parsing patterns from `task-order-format.md` are:
- Timestamp: `^\*Updated (\d{4}-\d{2}-\d{2})\. (.+)\*$`
- Goal: `^\*\*Goal\*\*: (.+)$`
- Wave table header: `^\*\*Dependency Waves\*\*:$`
- Wave table row: `^\| (\d+) \| ([\d, ]+) \| ([\d, --]+) \|$`
- Tree header: `^\*\*Dependency Tree\*\* \(indented = must complete first\):$`
- Fenced block: `` ^\`\`\` ``
- Tree entry (inside fenced block): `^(\s*)(└─ )?(\d+) \[([A-Z ]+)\] — (.+)$`

The `task_order_state` structure needs to be updated to reflect what the new format provides:

```json
{
  "exists": true,
  "timestamp": "2026-05-15",
  "goal": "Sorry-free bx_completeness → ...",
  "waves": [
    {"wave": 1, "tasks": [8, 18, 60, 142, 147], "blocked_by": []},
    {"wave": 2, "tasks": [148, 145, 128], "blocked_by": [147, 143, 122]},
    {"wave": 3, "tasks": [146], "blocked_by": [145]}
  ],
  "tree_entries": [
    {"task_number": 148, "status": "RESEARCHED", "description": "...", "depth": 0},
    {"task_number": 147, "status": "COMPLETED", "description": "...", "depth": 1}
  ],
  "all_task_numbers": [148, 147, 146, 145, 143, 128, 122, 142]
}
```

### Finding 3: /review's Section 6.5 must be replaced with a script call

Section 6.5 ("Prune Task Order") contains 6 sub-sections of complex manual logic:
- 6.5.1: Cross-reference task numbers against state.json to find tasks to prune
- 6.5.2: Remove pruned task entries line by line from categories
- 6.5.3: Update dependency chain code blocks (arrow chains)
- 6.5.4: Update inline dependency references
- 6.5.5: Update timestamp with pruning note
- 6.5.6: Write updated Task Order

All of this logic is now superseded by a single `generate-task-order.sh --update-todo specs/TODO.md specs/state.json` call, which:
- Reads only non-terminal tasks from state.json (completed/abandoned automatically excluded)
- Recomputes waves and tree from scratch
- Replaces the entire section

The new Section 6.5 should be simplified to:

```markdown
### 6.5. Regenerate Task Order

Replace the Task Order section with a fresh generation from state.json:

```bash
.claude/scripts/generate-task-order.sh --update-todo specs/TODO.md specs/state.json
```

This regeneration auto-prunes completed/abandoned tasks and recomputes wave assignments.
```

Sections 6.6 ("Insert New Tasks into Task Order") and 6.7 ("Interactive Task Order Management") reference the `task_order_state` structure. If the structure is updated to match the new format, Section 6.6 needs adjustment since the new format has no "categories" for placement. However, a simpler approach: after inserting new tasks into state.json in Section 5.6, call `generate-task-order.sh --update-todo` in Section 6.5 to regenerate from the updated state. This removes the need for Sections 6.6's category placement logic.

**Recommendation**: Replace Section 6.5 + 6.6 with a single regeneration call, and simplify Section 6.7 to only offer Goal statement update (the category/dependency interactive management is no longer needed since the script handles all of that).

### Finding 4: state-management.md lacks Task Order sync rules

The current `state-management.md` (80 lines) covers:
- File synchronization (state.json vs TODO.md)
- Status transitions (permissive model)
- Two-phase update pattern
- Error handling

There is no mention of Task Order. Two rules should be added:

**Rule 1: Task Order Regeneration Triggers**

Task Order must be regenerated after any of these events:
- `/todo` archive run (any tasks archived)
- `/review` when new tasks are created (via 6.5 simplification)
- Manual request via `generate-task-order.sh --print` or `--update-todo`

Task Order should NOT be regenerated on:
- Individual non-terminal status changes (in-place sed in update-task-status.sh handles those)
- Read-only operations (/research, /plan)

**Rule 2: Task Order is Derived from state.json**

Task Order is not a canonical source; it is derived from state.json. Divergence between Task Order and state.json is expected between regeneration points and must be tolerated. The `generate-task-order.sh` script is the single source of truth for regeneration.

**Rule 3: Who is responsible**

- `update-task-status.sh` Phase 3: handles in-place non-terminal status updates
- `generate-task-order.sh --update-todo`: handles full regeneration (terminal transitions, /todo, /review)
- Neither `/research` nor `/plan` postflight triggers Task Order regeneration

### Finding 5: generate-task-order.sh interface (confirmed ready)

The script was verified to exist at `.claude/scripts/generate-task-order.sh`. Its interface:
- `--print`: Print generated Task Order section to stdout
- `--update-todo TODO_FILE STATE_FILE [--goal "text"]`: Replace `## Task Order` section in TODO_FILE using STATE_FILE
- Returns 0 on success, 1 on error (state.json not found, TODO.md not found)
- Exits with `INFO: No active non-terminal tasks found` and exit 0 if no tasks

The script is self-contained and does not depend on any other scripts.

---

## Decisions

1. **Insertion point for /todo**: New Step 5.8 after Step 5.6 (metrics sync), before Step 5.7 (vault). This ensures state.json is up to date before regeneration.
2. **Replace not extend for /review Section 6.5**: The old pruning logic (6 sub-sections) should be entirely replaced by a single script call. This is the correct simplification since the new format is generated, not manually maintained.
3. **Sections 6.6 and 6.7 scope reduction**: Since the new format is auto-generated, the complex category-placement and interactive dependency management in 6.6/6.7 can be simplified. The remaining useful part of 6.7 is the goal statement update prompt.
4. **state-management.md additions**: Add a new section "Task Order Sync" documenting regeneration triggers, derivation relationship, and responsible scripts. This is separate from the state.json/TODO.md synchronization rules (which cover canonical sources).
5. **No changes to /review Section 6.6.7 "Generate New Task Order"**: If no Task Order section exists and tasks were created, the review command should call `generate-task-order.sh --update-todo` directly rather than constructing a manual section. This aligns with the auto-generation approach.

---

## Recommendations

### Priority 1: Add Task Order regeneration to /todo (Step 5.8)

Insert after Step 5.6, before Step 5.7:

```markdown
### 5.8. Regenerate Task Order

After archiving tasks and syncing metrics, regenerate the Task Order section to reflect the updated state:

```bash
.claude/scripts/generate-task-order.sh --update-todo specs/TODO.md specs/state.json || {
  echo "Warning: Task Order regeneration failed (non-fatal)" >&2
}
```

This call is non-fatal: if the script fails (e.g., no active tasks), log a warning and continue.

If a vault operation was performed in Step 5.7 (task renumbering), regenerate Task Order again after the renumbering is complete.
```

Also update the git commit message in Step 6 to include `Task Order regenerated` when Step 5.8 ran.

### Priority 2: Update /review Section 2.6 to use new wave+tree parsing

Replace the category-based `task_order_state` parsing logic with wave+tree parsing:

- Remove all references to `categories`, `dependency_chain`, arrow chain extraction, ordered/unordered task entry patterns
- Add wave table parsing: extract `waves[]` array with `wave`, `tasks[]`, `blocked_by[]` fields
- Add tree entry parsing: extract `tree_entries[]` array with `task_number`, `status`, `description`, `depth` fields
- Update `task_order_state` JSON structure in the spec to reflect new format
- Keep all references to `task_order_state.exists` and `task_order_state.all_task_numbers` (same semantics)

### Priority 3: Replace /review Sections 6.5 and 6.6 with a single regeneration call

Replace Sections 6.5 (Prune Task Order, ~120 lines) and 6.6 (Insert New Tasks, ~200 lines) with:

```markdown
### 6.5. Regenerate Task Order

Call `generate-task-order.sh --update-todo` to rebuild the Task Order section. This auto-prunes completed/abandoned tasks and incorporates any new tasks created in Section 5.6 (which were added to state.json before this call).

**Skip condition**: If `task_order_state.exists == false` AND no tasks were created in Section 5.6, skip this section (no Task Order to update and nothing to add).

```bash
.claude/scripts/generate-task-order.sh --update-todo specs/TODO.md specs/state.json || {
  echo "Warning: Task Order regeneration failed (non-fatal)" >&2
}
```
```

Keep Section 6.7 ("Interactive Task Order Management") but simplify it:
- Remove the Category Placement Override (6.7.3) — no longer needed
- Remove the Dependency Updates (6.7.4) — now handled by state.json `dependencies` field
- Keep Goal Statement Update (6.7.6) — still valid
- Simplify 6.7.1 skip conditions accordingly

### Priority 4: Add Task Order sync rules to state-management.md

Add a new section after "Two-Phase Update Pattern":

```markdown
## Task Order Synchronization

### Derivation Relationship

The `## Task Order` section in TODO.md is **derived** from state.json, not a canonical source. 
Divergence between Task Order and state.json is expected between regeneration events.

### Regeneration Triggers

| Event | Regeneration Call |
|-------|-----------------|
| `/todo` archive run (any tasks archived) | After Step 5.6: `generate-task-order.sh --update-todo` |
| `/review` run (tasks created or existing Task Order found) | After Section 5.6: `generate-task-order.sh --update-todo` |
| Terminal status transition (COMPLETED/ABANDONED) | `update-task-status.sh` Phase 3 Mode B |
| `/task` creation (Task 150 scope) | `generate-task-order.sh --update-todo` |

### Responsible Scripts

- **In-place non-terminal updates**: `update-task-status.sh` Phase 3 Mode A
- **Full regeneration**: `generate-task-order.sh --update-todo specs/TODO.md specs/state.json`

### Non-Regeneration Events

Task Order is NOT regenerated during:
- `/research` or `/plan` runs (status changes only)
- Read-only operations
- Failed operations (non-fatal Task Order failures should not block archiving)
```

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| /todo fails if generate-task-order.sh is absent | Make the call non-fatal with `|| { echo "Warning..." }` |
| /review's Section 6.6 logic depended on `task_order_state.categories` | Remove Sections 6.6 entirely; replace with regeneration |
| Vault operation renumbers tasks between regenerations | Add a second `generate-task-order.sh` call after vault renumbering completes |
| /review's 6.7 interactive management references old category structure | Simplify 6.7 to only Goal Statement Update |
| state.json is updated mid-/review before Task Order regeneration | By design: Section 5.6 updates state.json, Section 6.5 regenerates from it |

---

## Context Extension Recommendations

- **Topic**: Task Order regeneration integration pattern
- **Gap**: No documented pattern explaining where and how `generate-task-order.sh` hooks into command flows
- **Recommendation**: Add `.claude/context/patterns/task-order-integration.md` documenting the regeneration hook points, non-fatal invocation pattern, and the relationship between `update-task-status.sh` Phase 3 and `generate-task-order.sh`

---

## Appendix

### Files examined (line counts)

- `.claude/commands/todo.md` — 1014 lines
- `.claude/commands/review.md` — 1570 lines
- `.claude/scripts/generate-task-order.sh` — 548 lines
- `.claude/context/formats/task-order-format.md` — 300 lines
- `.claude/rules/state-management.md` — 80 lines
- `specs/149_redesign_task_order_format/reports/01_format-redesign-research.md` — 515 lines
- `specs/149_redesign_task_order_format/summaries/01_task-order-redesign-summary.md` — 45 lines
- `specs/TODO.md` lines 28–82 (Task Order section)

### /todo command flow summary (relevant steps)

| Step | Description | Task Order impact |
|------|-------------|------------------|
| 2 | Scan archivable tasks | None |
| 5A-5F | Archive tasks, update files | state.json updated; Task Order now stale |
| 5.5 | Update ROADMAP.md | None |
| 5.6 | Sync repository metrics | None |
| **5.8 (new)** | **Regenerate Task Order** | **Calls generate-task-order.sh** |
| 5.7 | Vault operation (rare) | May renumber tasks |
| 6 | Git commit | Commits TODO.md with new Task Order |

### /review command sections relevant to Task Order

| Section | Description | Action |
|---------|-------------|--------|
| 2.6 | Parse Task Order | Rewrite parsing for wave+tree format |
| 6.5 | Prune Task Order | Replace with `generate-task-order.sh` call |
| 6.6 | Insert new tasks into Task Order | Remove (covered by regeneration) |
| 6.7 | Interactive Task Order Management | Simplify: keep Goal Update only |
| 6.7.6 | Goal Statement Update | Keep unchanged |
