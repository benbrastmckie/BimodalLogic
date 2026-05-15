# Research Report: Task #152 (Round 2)

**Task**: 152 - Task Order Topic Grouping — Topic Field Population
**Started**: 2026-05-15T21:00:00Z
**Completed**: 2026-05-15T21:30:00Z
**Effort**: 1-2 hours (focused investigation)
**Dependencies**: Report 01 (topic-grouping-research.md) completed
**Sources/Inputs**:
- `.claude/commands/task.md` — full read (642 lines)
- `.claude/agents/meta-builder-agent.md` — full read (1409 lines)
- `.claude/skills/skill-fix-it/SKILL.md` — full read (547 lines)
- `.claude/commands/review.md` — full read (1004 lines)
- `.claude/skills/skill-meta/SKILL.md` — full read (238 lines)
- `specs/state.json` — current schema examined
- `.claude/context/reference/state-management-schema.md` — schema reference read
- `.claude/rules/state-management.md` — state rules read
**Artifacts**:
- `specs/152_task_order_topic_grouping/reports/02_topic-field-population.md` (this file)
**Standards**: report-format.md, state-management-schema.md

---

## Executive Summary

- **Four task-creation paths** exist in the system: `/task` (primary), `meta-builder-agent` (batch via `/meta`), `skill-fix-it` (tag-based), and `/review` (issue-based). Each writes to `state.json` and `TODO.md` with slightly different jq patterns, and each needs topic assignment added.
- **`/task` is the highest-leverage change**: it handles the single-task creation case and serves as the model the others follow. The topic field should be added to step 6 of the Create Task flow (the jq update that writes state.json).
- **`active_topics` in state.json** should be a top-level `string[]` array listing the canonical topic taxonomy. This allows all commands to read and display available topics without hardcoding them in multiple places.
- **Topic assignment UX**: the recommended flow is (1) auto-infer topic by keyword matching the description against known topics, (2) present an `AskUserQuestion` picker showing the auto-inferred suggestion plus all existing topics plus "New topic…", (3) user confirms or overrides. Single-topic prompt is lightweight for the common case.
- **`/task --sync`** should backfill missing topics for existing tasks — the same keyword heuristic used at creation time, presented as a batch confirmation rather than task-by-task.
- **`meta-builder-agent`** and **`skill-fix-it`** already have structured task objects in memory before writing state.json; topic assignment can be added to the batch-creation loop without requiring extra user prompts (use auto-inference with optional override at the confirmation stage).

---

## Context & Scope

### Research Question

Report 01 established the output format (topic-grouped Task Order) and defined a seven-topic taxonomy. This round investigates the **input side**: how does the `topic` field get written into `state.json` in the first place? Specifically:
1. Which commands/agents create task entries?
2. What is the exact insertion point for `topic` in each?
3. What schema change is needed in `state.json` (active_topics array)?
4. What UX should govern topic selection?
5. Should `--sync` backfill missing topics?

### Scope Constraint

This is a research-only report. Implementation is covered by the existing Phase 1 plan in `specs/152_task_order_topic_grouping/plans/01_topic-grouping.md`.

---

## Findings

### 1. All Commands That Create Task Entries

#### 1.1 `/task` — Primary Single-Task Creator

**File**: `.claude/commands/task.md`

**Creation path**: Create Task Mode (Default, no flag).

**Exact insertion point**: Step 6 — "Update state.json (via jq)":
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '.next_project_number = {NEW_NUMBER} |
   .active_projects = [{
     "project_number": {N},
     "project_name": "slug",
     "status": "not_started",
     "task_type": "detected",
     "created": $ts,
     "last_updated": $ts
   }] + .active_projects' \
  specs/state.json > specs/tmp/state.json && \
  mv specs/tmp/state.json specs/state.json
```

**Topic should be added here** as a `"topic": $topic` field in the object literal.

**Step 4** already auto-detects `task_type` from keyword matching. Topic assignment follows the same pattern but runs as step 4.5 (after task_type detection, before slug generation).

**Current flow (steps 1-9)**:
1. Read next_project_number
2. Parse description
3. Improve description (slug expansion, verb inference, normalization)
4. Detect task_type from keywords
5. Create slug
6. Update state.json ← **add `topic` here**
7. Update TODO.md (Part A: frontmatter, Part B: task entry, Part C: Task Order regeneration)
8. Git commit
9. Output

**Submode note**: `--recover` restores from archive but retains original fields including any existing `topic`. `--review` creates follow-up tasks using the same jq pattern as Create Task — topic should be inherited from the parent task. `--expand` creates subtasks — topic should inherit from the parent. `--sync` would need a backfill pass (see §1.5).

#### 1.2 `meta-builder-agent` — Batch Task Creator for `/meta`

**File**: `.claude/agents/meta-builder-agent.md`

**Creation path**: Stage 6 CreateTasks (both Interactive and Prompt modes).

**Exact insertion point**: The jq block that creates each task object in `active_projects`. The agent builds a `task_list[]` in memory before writing. Task objects are written in topological order.

**Current state.json Entry** (from Stage 6):
```json
{
  "project_number": 36,
  "project_name": "task_slug",
  "status": "not_started",
  "task_type": "meta",
  "dependencies": [35, 34],
  "artifacts": []
}
```

**Topic should be added here** as `"topic": "agent-system"` (or the appropriate value).

**Best insertion point for topic assignment in `/meta`**: Stage 3.5 (AnalyzeTopics / Topic Clustering) already infers grouping labels from task content. The agent can derive `topic` values from the same keyword-matching heuristic used for `/task`. Topic assignment should happen during Stage 5 (ReviewAndConfirm) summary — the table shown to the user can include a Topic column, allowing the user to confirm or override. This avoids an extra round of prompts while still providing visibility.

**Key difference from `/task`**: The meta-builder-agent already does topic analysis at Stage 3.5 for consolidation purposes. The same infrastructure can derive `topic` values at that stage.

#### 1.3 `skill-fix-it` — Tag-Based Multi-Task Creator

**File**: `.claude/skills/skill-fix-it/SKILL.md`

**Creation path**: Step 8 (Create Selected Tasks), sub-steps 8.2–8.5.

**Exact insertion point**: Step 9.1 (Update state.json). The skill writes individual task objects using jq:
```bash
jq --arg ts ... \
  '.active_projects += [{
    "project_number": ($num | tonumber),
    "project_name": $slug,
    "status": "not_started",
    "task_type": $task_type,
    "dependencies": [learn_it_task_num]
  }]' ...
```

**Topic should be added here** as a `"topic": $topic` parameter.

**Auto-inference for fix-it tasks**: The skill already does language detection by file path (`.lean` → lean, `.md`/`.claude/*` → meta). Topic can be inferred from the same file-path heuristic:
- Tags from `.claude/` files → `"agent-system"`
- Tags from `.lean` files → inferred by content keywords against the taxonomy
- Tags from `.tex` files → `"documentation"` or appropriate project topic

This is a good candidate for **auto-assign without extra prompt** since fix-it tasks are already batched and the user is going through multiple selection steps. Topic can appear in the Step 10 summary table as confirmation.

#### 1.4 `/review` — Issue-Based Task Creator

**File**: `.claude/commands/review.md`

**Creation path**: Section 5.6.3 (State Updates). Uses jq with `.active_projects += [...]` pattern:
```bash
jq --arg num "$next_num" --arg slug "$slug" --arg title "$title" \
   --arg desc "$description" --arg tt "$task_type" --arg prio "$priority" \
   '.active_projects += [{
     "project_number": ($num | tonumber),
     "project_name": $slug,
     "status": "not_started",
     "task_type": $tt,
     "priority": $prio,
     "description": $title,
     ...
   }]'
```

**Topic should be added here** as a `"topic": $topic` parameter.

**Auto-inference for /review tasks**: Review tasks are inferred from code analysis. Topic can be derived from the file path of the issue:
- Issues in `.claude/` or `specs/` → `"agent-system"`
- Issues in `Theories/Bimodal/Metalogic/` → `"completeness"` or appropriate lean topic
- Issues in `.lean` files → use keyword heuristic on issue description

Since `/review` task creation already has a two-tier selection UX (group selection → granularity), topic assignment can be shown in the Tier 1 group label (e.g., "Bimodal fixes [completeness]") without adding another prompt step.

#### 1.5 `/task --sync` — Potential Backfill Path

**File**: `.claude/commands/task.md`, Sync Mode section.

**Current behavior**: Compares state.json and TODO.md entries for numerical consistency, then reconciles discrepancies. Does NOT currently touch the `topic` field.

**Proposed backfill behavior**: During `--sync`, detect active tasks that have `"topic": null` or no `topic` field. For each such task, run the keyword-matching heuristic against `project_name` and `description`. Present findings as a batch `AskUserQuestion` with multiSelect:

```
Found 18 tasks without topic assignment:
  - #8 genuine_truth_at_completeness → auto-inferred: completeness
  - #18 dense_representation_theorem → auto-inferred: completeness
  ...
```

Options: "Accept all auto-inferred", "Accept selected" (multiSelect), "Skip backfill".

This makes `--sync` the canonical backfill mechanism rather than requiring a separate one-time script.

---

### 2. Proposed `active_topics` Schema in state.json

#### 2.1 Why a Top-Level Array?

Multiple commands need to:
- Display the list of existing topics when prompting the user
- Validate that a user-entered topic value matches a known topic
- Ensure consistent spelling across task entries

Without a central registry, each command would need to hardcode the topic list or derive it dynamically from all task entries (expensive with 26+ tasks). A top-level `active_topics` array provides a single source of truth.

#### 2.2 Proposed Schema

Add to the top level of `state.json`:

```json
{
  "active_topics": [
    "completeness",
    "decidability",
    "formula-refactor",
    "frame-extensions",
    "algebraic-representation",
    "bilateral",
    "agent-system"
  ]
}
```

**Format**: Array of kebab-case strings. Ordered by rough priority (most active/important first is useful for UX).

**Lifecycle**:
- **Read** by all task-creation commands when presenting the topic picker
- **Written** when a user selects "New topic…" during task creation — the new value is appended to the array
- **Never auto-pruned** — topics remain in the list even if no tasks use them (historical accuracy; pruning can be a future `/todo` enhancement)

**Rationale for strings over objects**: The taxonomy is simple at this stage. If metadata per topic (description, color, owner) is needed later, the schema can evolve from `string[]` to `{name: string, description?: string}[]` without breaking existing string readers.

#### 2.3 Where the Schema Should Be Documented

Add `active_topics` to:
- `.claude/context/reference/state-management-schema.md` → "state.json Full Structure" section and "Field Reference" table
- `.claude/rules/state-management.md` → brief mention in "Canonical Sources" section under state.json

---

### 3. Topic Assignment UX Flow

#### 3.1 For `/task` (Single-Task Creation)

Insert as Step 4.5 (after task_type detection):

```
4.5 Detect topic from keywords:
    1. Run keyword heuristic (from report 01, Appendix B) against combined
       project_name + description text
    2. If a confident match is found, set auto_topic = "matched-topic"
    3. Read active_topics from state.json

    AskUserQuestion:
    {
      "question": "Assign a topic to this task?",
      "header": "Topic",
      "multiSelect": false,
      "options": [
        { "label": "{auto_topic} (suggested)", "description": "Auto-inferred from description" },
        ... (one option per active_topic not equal to auto_topic) ...
        { "label": "New topic…", "description": "Enter a custom topic name" },
        { "label": "Skip (no topic)", "description": "Task will appear under Uncategorized" }
      ]
    }

    If "New topic…" selected:
      Prompt for topic name (free-text via AskUserQuestion)
      Append new topic to state.json active_topics array
    
    If "Skip (no topic)":
      topic = null (field omitted from state.json entry)
```

**Effort for user**: One extra selection after the task description is entered. The auto-suggest means the common case is a single click to confirm.

#### 3.2 For `meta-builder-agent` (Batch via `/meta`)

Add topic column to Stage 5 ReviewAndConfirm table:

| # | Title | Task Type | Topic | Effort | Dependencies |
|---|-------|-----------|-------|--------|--------------|
| 1 | Update task.md | meta | agent-system | 1h | None |
| 2 | Backfill topics | meta | agent-system | 30m | Task 1 |

Include a note: "Topics auto-inferred — change during task description if needed."

If the user selects "Revise" at Stage 5, they can revisit topic assignments. Otherwise, auto-inferred topics are accepted.

This avoids per-task topic prompts in the already-lengthy interview flow.

#### 3.3 For `skill-fix-it` (Tag-Based Tasks)

Auto-assign topic using the file-path and content heuristic. Show in Step 10 summary:

```
## Tasks Created from Tags

| # | Type | Title | Task Type | Topic |
|---|------|-------|-----------|-------|
| 153 | fix-it | Fix issues from FIX: tags | lean4 | completeness |
| 154 | learn-it | Update context files | meta | agent-system |
```

No extra prompt — the user has already gone through 3-4 selection steps. Auto-assignment is appropriate here.

#### 3.4 For `/review` (Issue-Based Tasks)

Auto-assign topic in Section 5.6.3 using file-path heuristic. Display in Section 5.6 task creation output. Same rationale as fix-it — user has already completed multi-step selection.

#### 3.5 For `--sync` (Backfill)

Present as batch confirmation (see §1.5). The multiSelect picker allows users to selectively override auto-inferences without confirming each task individually.

---

### 4. Commands That Do NOT Create Tasks

For completeness, these commands were verified to NOT create task entries:

- `/research N` — updates task status to `researching`/`researched`, no new tasks
- `/plan N` — updates status to `planning`/`planned`, no new tasks
- `/implement N` — updates status to `implementing`/`completed`, no new tasks
- `/revise N` — updates plan artifacts, no new tasks
- `/todo` — archives tasks (moves to archive/state.json), no new tasks
- `/refresh` — cleans processes/files, no tasks
- `/lean`, `/lake` — Lean-specific, no task state changes

---

### 5. What Changes Are Needed Per Command

| Command/Agent | File | Insertion Point | Change Type |
|---------------|------|-----------------|-------------|
| `/task` (create) | `.claude/commands/task.md` | Step 4.5 + Step 6 jq | Add AskUserQuestion + `"topic"` field |
| `/task --sync` | `.claude/commands/task.md` | Sync Mode step 3 | Add batch backfill pass |
| `/task --recover` | `.claude/commands/task.md` | Recover Mode step 2 | Inherit `topic` from archived entry (no change if field is preserved) |
| `/task --review` | `.claude/commands/task.md` | Step 8 (CreateTasks) | Inherit `topic` from parent task |
| `/task --expand` | `.claude/commands/task.md` | Expand Mode step 3 | Inherit `topic` from parent task |
| `meta-builder-agent` | `.claude/agents/meta-builder-agent.md` | Stage 5 table + Stage 6 jq | Add topic column to confirm table + `"topic"` field in jq |
| `skill-fix-it` | `.claude/skills/skill-fix-it/SKILL.md` | Step 9.1 jq + Step 10 summary | Add `"topic"` field + show in summary table |
| `/review` | `.claude/commands/review.md` | Section 5.6.3 jq | Add `"topic"` field |

---

### 6. state.json Schema Summary

Current active task entry (simplified):
```json
{
  "project_number": 152,
  "project_name": "task_order_topic_grouping",
  "status": "researching",
  "task_type": "meta",
  "dependencies": [149, 150],
  "created": "...",
  "last_updated": "..."
}
```

Proposed addition (new field per task):
```json
{
  "project_number": 152,
  "project_name": "task_order_topic_grouping",
  "status": "researching",
  "task_type": "meta",
  "topic": "agent-system",
  "dependencies": [149, 150],
  "created": "...",
  "last_updated": "..."
}
```

Proposed top-level addition:
```json
{
  "next_project_number": 153,
  "active_topics": [
    "completeness",
    "decidability",
    "formula-refactor",
    "frame-extensions",
    "algebraic-representation",
    "bilateral",
    "agent-system"
  ],
  "active_projects": [ ... ]
}
```

---

## Decisions

1. **`active_topics` lives at the top level of `state.json`** (not inside a metadata object or separate file). This follows the existing convention where `next_project_number`, `task_counts`, and `repository_health` all live at the top level.

2. **`topic` is an optional string field on task entries** — absent means "uncategorized". This matches how `priority` and `effort` are handled (optional, absent = unset).

3. **`/task` gets a UX prompt (AskUserQuestion)** because it's the primary creation path and the user is already providing description interactively. The auto-suggest makes the prompt lightweight.

4. **`meta-builder-agent`, `skill-fix-it`, and `/review` use auto-inference** without extra prompts, since these commands already have multi-step user interaction and adding per-task topic prompts would degrade UX.

5. **`--sync` handles backfill** as a batch confirmation — this is more ergonomic than a separate script and keeps backfill logic inside the established sync workflow.

6. **`--recover` and `--expand` inherit topic from the parent/archived entry** — no change needed to the current recover flow since the jq operation copies the entire task object; topic is automatically preserved if it was set in the archived entry. For `--expand`, the parent's topic is passed to all subtasks.

---

## Recommendations

### Priority 1: Schema Changes (Prerequisite for Everything)

1. **Add `active_topics` to state.json** (top-level array) during Phase 1 (state.json backfill) of the existing implementation plan. This should precede any command changes since the commands read from it.

2. **Document `active_topics` in state-management-schema.md** and `state-management.md`. Add the `topic` field to the project entry field reference table.

### Priority 2: `/task` Command Enhancement (Highest UX Impact)

3. **Add Step 4.5** to the Create Task flow in `.claude/commands/task.md`:
   - Run keyword heuristic
   - Present AskUserQuestion picker with auto-suggest + existing topics + "New topic…" + "Skip"
   - If "New topic…": append to `active_topics` in state.json before writing task entry

4. **Add `"topic": $topic` to the Step 6 jq block**. If topic is null/skipped, omit the field entirely (use `if $topic != null then {"topic": $topic} else {} end`).

5. **Add `--sync` backfill logic** in Sync Mode after step 5: scan for tasks missing `topic`, run keyword heuristic, batch-confirm with AskUserQuestion multiSelect.

### Priority 3: Batch Creator Enhancements

6. **`meta-builder-agent`**: Add `topic` column to Stage 5 confirmation table. Auto-infer using keyword heuristic in Stage 3.5 (AnalyzeTopics). Include `"topic": $topic` in Stage 6 jq.

7. **`skill-fix-it`**: Auto-infer topic in Step 9.1. Add Topic column to Step 10 summary. Include `"topic": $topic` in the jq writes.

8. **`/review`**: Auto-infer topic from file-path heuristic in Section 5.6.3. Add to jq block.

### Priority 4: Inheritance for Derived Tasks

9. **`/task --recover`**: The current flow copies the archived task object verbatim — `topic` is automatically preserved. No code change needed.

10. **`/task --expand`**: Add `"topic": parent_topic` to each subtask jq entry, where `parent_topic` is read from the parent's state.json entry.

11. **`/task --review`**: Add `"topic": parent_topic` to follow-up task jq entries.

---

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| AskUserQuestion for topic in `/task` adds friction that slows down task creation | Medium | Auto-suggest makes it usually one click; "Skip" option keeps friction low |
| `active_topics` array grows stale with unused topics | Low | Topics are cheap to maintain; prune only via explicit `/todo`-style command in a future task |
| Keyword heuristic assigns wrong topic to ambiguous tasks (e.g., task 949) | Medium | User can override at creation time; `--sync` allows batch correction |
| `--expand` and `--review` inheritance is wrong if parent has outdated topic | Low | User can always run `--sync` to re-evaluate |
| `active_topics` not in CLAUDE.md system description causes future agents to miss it | Medium | Document in state-management-schema.md; the schema reference is consistently loaded by command instructions |

---

## Appendix

### A. Keyword Heuristic for Topic Auto-Inference

(Same as Appendix B in report 01, reproduced for reference):

```bash
assign_topic_heuristic() {
  local name="$1" desc="$2"
  local combined="${name} ${desc}"
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
  elif echo "$combined" | grep -qiE "frame_hier|discrete.*frame|dense.*frame|integer.*frame|open_set|time_add|tense.*s5|temporal.*operator"; then
    echo "frame-extensions"
  elif echo "$combined" | grep -qiE "completeness|sorry|represent|bfmcs|countermodel|canonical|parametric|chain|saturation"; then
    echo "completeness"
  else
    echo ""  # empty = uncategorized / prompt user
  fi
}
```

### B. AskUserQuestion Picker Example for `/task`

```json
{
  "question": "Assign a topic to this task?",
  "header": "Topic Assignment",
  "multiSelect": false,
  "options": [
    {
      "label": "completeness (suggested)",
      "description": "Auto-inferred from description keywords"
    },
    {
      "label": "decidability",
      "description": "KType, Doets, FMP, decidability"
    },
    {
      "label": "formula-refactor",
      "description": "G/H/F/P abbreviations, module reorganization"
    },
    {
      "label": "frame-extensions",
      "description": "Dense/discrete/integer frames, temporal operators"
    },
    {
      "label": "algebraic-representation",
      "description": "Jonsson-Tarski, STSA, Boolean algebras"
    },
    {
      "label": "bilateral",
      "description": "Bilateral proof system"
    },
    {
      "label": "agent-system",
      "description": "Agent architecture, meta tasks, demo updates"
    },
    {
      "label": "New topic…",
      "description": "Enter a custom topic name (will be added to active_topics)"
    },
    {
      "label": "Skip (no topic)",
      "description": "Task will appear under Uncategorized in Task Order"
    }
  ]
}
```

### C. Implementation Impact on Existing Plan (Plan 01)

The existing plan in `specs/152_task_order_topic_grouping/plans/01_topic-grouping.md` has 4 phases:
- Phase 1: State.json backfill (already covers adding `topic` to existing tasks)
- Phase 2: generate-task-order.sh enhancement
- Phase 3: task-order-format.md update
- Phase 4: Live regeneration

The findings from this report suggest expanding **Phase 1** to also:
1. Add `active_topics` top-level array to state.json
2. Document schema changes in state-management-schema.md

And adding a **Phase 5** (or appending to Phase 3):
1. Update `/task` command (Step 4.5 + Step 6)
2. Update `meta-builder-agent` (Stage 5 table + Stage 6 jq)
3. Update `skill-fix-it` (Step 9.1 + Step 10 summary)
4. Update `/review` (Section 5.6.3 jq)
5. Add `--sync` backfill logic

This additional phase is **low-risk** since each change is localized to its respective file and the schema change is additive (backward-compatible: tasks without `topic` render as "Uncategorized").
