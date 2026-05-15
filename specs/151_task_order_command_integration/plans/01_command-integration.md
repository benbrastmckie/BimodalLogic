# Implementation Plan: Task Order Command Integration

- **Task**: 151 - Task Order Command Integration
- **Status**: [IMPLEMENTING]
- **Effort**: 2.5 hours
- **Dependencies**: Task 149 (completed)
- **Research Inputs**: specs/151_task_order_command_integration/reports/01_command-integration.md
- **Artifacts**: plans/01_command-integration.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/context/formats/plan-format.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Task 149 created `generate-task-order.sh` and the wave+tree format specification, but deferred wiring the script into `/todo` and `/review` commands. This plan integrates the Task Order auto-generation into both command flows and documents the synchronization rules. The three integration points are: (1) add Task Order regeneration as a new step in `/todo` archive flow, (2) rewrite `/review` Section 2.6 parsing and Sections 6.5-6.6 for the new wave+tree format, (3) add Task Order sync rules to `state-management.md`. Definition of done: both commands call `generate-task-order.sh` at the correct points, `/review` parses the new format, and state-management.md documents regeneration triggers.

### Research Integration

Research report `01_command-integration.md` identified exact insertion points:
- `/todo`: New Step 5.8 after Step 5.6 (metrics sync), before Step 5.7 (vault)
- `/review`: Section 2.6 needs full rewrite for wave+tree parsing; Sections 6.5+6.6 replaced by single `generate-task-order.sh --update-todo` call; Section 6.7 simplified to keep only Goal Statement Update
- `state-management.md`: No existing Task Order rules; three rules needed (regeneration triggers, derivation relationship, responsible scripts)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items directly reference this meta-system task. This is internal infrastructure work supporting the task management system.

## Goals & Non-Goals

**Goals**:
- Wire `generate-task-order.sh --update-todo` into `/todo` archive flow (Step 5.8)
- Rewrite `/review` Section 2.6 to parse wave+tree format instead of flat-category format
- Replace `/review` Sections 6.5 (Prune Task Order) and 6.6 (Insert New Tasks) with a single `generate-task-order.sh` call
- Simplify `/review` Section 6.7 to remove category/dependency interactive management (keep Goal Statement Update only)
- Add Task Order Synchronization section to `state-management.md`
- Update `/todo` SKILL.md to include the regeneration stage

**Non-Goals**:
- Modifying `generate-task-order.sh` itself (already complete from Task 149)
- Wiring into `/task` creation flow (separate scope, noted in research as potential Task 150 work)
- Creating a context pattern document for integration hooks (suggested by research but not required for this task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `/todo` fails if generate-task-order.sh is absent | M | L | Make the call non-fatal with `\|\| { echo "Warning..." }` |
| `/review` Section 6.6 logic depended on `task_order_state.categories` | H | H | Remove Section 6.6 entirely; replace with regeneration call |
| Vault operation renumbers tasks after Task Order regeneration | M | L | Add second regeneration call after vault renumbering in Step 5.7 |
| `/review` Section 6.7 references old category structure | M | H | Simplify 6.7: remove 6.7.3 (Category Placement Override) and 6.7.4 (Dependency Updates) |
| SKILL.md and commands/todo.md get out of sync | M | M | Update both files in Phase 1 together |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 3 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Add Task Order Regeneration to /todo [COMPLETED]

**Goal**: Wire `generate-task-order.sh --update-todo` into the /todo archive flow at the correct insertion point.

**Tasks**:
- [ ] Add new Step 5.8 "Regenerate Task Order" in `.claude/commands/todo.md` between Step 5.6 (Sync Repository Metrics) and Step 5.7 (Vault Operation)
- [ ] Add non-fatal invocation: `generate-task-order.sh --update-todo specs/TODO.md specs/state.json || { echo "Warning: Task Order regeneration failed (non-fatal)" >&2; }`
- [ ] Add note in Step 5.7 (Vault Operation) to regenerate Task Order again after renumbering completes (after Step 5.8.8/Reset state)
- [ ] Add new Stage (between current Stage 10 and Stage 11) in `.claude/skills/skill-todo/SKILL.md` for Task Order regeneration
- [ ] Update git commit message template in Step 6 / Stage 15 to include "Task Order regenerated" when regeneration ran

**Timing**: 45 minutes

**Depends on**: none

**Files to modify**:
- `.claude/commands/todo.md` - Add Step 5.8 between Steps 5.6 and 5.7; update Step 5.7 vault section; update Step 6 commit message
- `.claude/skills/skill-todo/SKILL.md` - Add regeneration stage between ArchiveTasks (Stage 10) and UpdateRoadmap (Stage 11)

**Verification**:
- Step 5.8 exists in commands/todo.md with the correct script invocation
- SKILL.md has a new stage for Task Order regeneration
- Vault operation section references re-running regeneration after renumbering

---

### Phase 2: Rewrite /review Task Order Sections [COMPLETED]

**Goal**: Update `/review` command to parse the new wave+tree format and use `generate-task-order.sh` for regeneration instead of manual pruning/insertion logic.

**Tasks**:
- [ ] Rewrite Section 2.6 "Parse Task Order" in `.claude/commands/review.md`:
  - Remove old parsing patterns (category headers, arrow chains, ordered/unordered entries, inline dependency notes)
  - Add new parsing patterns from task-order-format.md (timestamp, goal, wave table, tree entries)
  - Replace `task_order_state` JSON structure with new format (waves[], tree_entries[], all_task_numbers)
- [ ] Replace Section 6.5 "Prune Task Order" (~120 lines of manual pruning logic across 6 sub-sections) with a single `generate-task-order.sh --update-todo` call
- [ ] Remove Section 6.6 "Insert New Tasks into Task Order" entirely (covered by regeneration from state.json after Section 5.6 adds new tasks)
- [ ] Simplify Section 6.7 "Interactive Task Order Management":
  - Remove Section 6.7.3 (Category Placement Override) -- no categories in new format
  - Remove Section 6.7.4 (Dependency Updates) -- handled by state.json dependencies field
  - Remove Section 6.7.5 (Apply Interactive Changes) -- no longer needed
  - Keep Section 6.7.1 (Skip Conditions) with updated logic
  - Keep Section 6.7.2 (Present Task Order Summary) with updated field names
  - Keep Section 6.7.6 (Goal Statement Update) unchanged
- [ ] Update Section 6.6.7 "Generate New Task Order" to use `generate-task-order.sh --update-todo` instead of manual section construction
- [ ] Update Section 7 git commit message template to reflect simplified Task Order operations

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `.claude/commands/review.md` - Rewrite Section 2.6, replace Sections 6.5-6.6, simplify Section 6.7, update Section 7

**Verification**:
- Section 2.6 parses wave table and dependency tree entries (not categories or arrow chains)
- `task_order_state` structure matches the new format (waves, tree_entries, no categories)
- Section 6.5 is a single script call, not 6 sub-sections
- Section 6.6 is removed or merged into 6.5
- Section 6.7 retains only Goal Statement Update (6.7.6) and summary display (6.7.2)
- No references to `categories`, `dependency_chain`, or arrow chain patterns remain

---

### Phase 3: Add Task Order Sync Rules to state-management.md [COMPLETED]

**Goal**: Document the Task Order synchronization model in state-management.md so all agents know when and how Task Order is updated.

**Tasks**:
- [ ] Add new "## Task Order Synchronization" section after "Two-Phase Update Pattern" in `.claude/rules/state-management.md`
- [ ] Document "Derivation Relationship" subsection: Task Order is derived from state.json, not canonical; divergence between regenerations is tolerated
- [ ] Document "Regeneration Triggers" subsection with table of events and their regeneration calls
- [ ] Document "Responsible Scripts" subsection identifying `update-task-status.sh` Phase 3 (in-place updates) vs `generate-task-order.sh` (full regeneration)
- [ ] Document "Non-Regeneration Events" subsection listing events that do NOT trigger regeneration

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `.claude/rules/state-management.md` - Add Task Order Synchronization section after Two-Phase Update Pattern

**Verification**:
- state-management.md contains a "Task Order Synchronization" section
- Section includes derivation relationship, regeneration triggers table, responsible scripts, and non-regeneration events
- Regeneration triggers table lists /todo, /review, terminal status transitions, and /task creation

---

## Testing & Validation

- [ ] Verify `commands/todo.md` has Step 5.8 between Steps 5.6 and 5.7
- [ ] Verify `commands/todo.md` Step 5.7 (vault) includes post-renumbering regeneration note
- [ ] Verify `skills/skill-todo/SKILL.md` has Task Order regeneration stage
- [ ] Verify `commands/review.md` Section 2.6 uses wave+tree parsing patterns
- [ ] Verify `commands/review.md` has no remaining references to `categories`, `dependency_chain`, or arrow chain patterns in Sections 2.6 and 6.5-6.7
- [ ] Verify `commands/review.md` Section 6.5 is a single script call
- [ ] Verify `rules/state-management.md` has Task Order Synchronization section with all four subsections
- [ ] Verify `generate-task-order.sh` is not modified (should remain unchanged from Task 149)

## Artifacts & Outputs

- `specs/151_task_order_command_integration/plans/01_command-integration.md` (this plan)
- Modified: `.claude/commands/todo.md`
- Modified: `.claude/skills/skill-todo/SKILL.md`
- Modified: `.claude/commands/review.md`
- Modified: `.claude/rules/state-management.md`

## Rollback/Contingency

All changes are to command specification files (`.claude/commands/*.md`, `.claude/skills/*/SKILL.md`, `.claude/rules/*.md`). Rollback via `git checkout` on any individual file. No runtime code or build artifacts are affected. The `generate-task-order.sh` script is not modified by this task, so the generation capability remains intact regardless of whether integration changes are reverted.
