# Implementation Plan: Task #641

- **Task**: 641 - improve_todo_command_roadmap_update
- **Status**: [IMPLEMENTING]
- **Version**: 002
- **Effort**: 3 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**:
  - specs/641_improve_todo_command_roadmap_update/reports/research-001.md
  - specs/641_improve_todo_command_roadmap_update/reports/research-002.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This revised plan abandons the keyword/heuristic matching approach in favor of a **structured synchronization** between task completion data and ROAD_MAP.md updates. The core insight: require completed tasks to include a `completion_summary` field in state.json, which captures what was accomplished. The `/todo` command can then use `jq` to extract these targeted summaries and intelligently update ROAD_MAP.md.

### Revision Rationale

The original plan (v001) used keyword matching as a heuristic fallback for finding roadmap items. This approach:
- Relies on fuzzy text matching with arbitrary thresholds
- Requires maintaining a "common words exclusion list"
- Has inherent false positive/negative risks
- Lacks semantic understanding of what was actually completed

The new approach:
- **Requires** structured data at task completion time
- Uses deterministic `jq` queries instead of heuristic matching
- Enables semantic matching via the completion summary content
- Synchronizes the contract between `/implement` and `/todo`

### Research Integration

From research-001.md:
- Root cause: ROAD_MAP.md has 0 `(Task N)` references
- Current exact matching is correct but insufficient

From research-002.md:
- Opportunity to design a coherent data flow between commands
- `/implement` is the producer of completion context
- `/todo` is the consumer that needs to understand what changed

**New insight from user feedback**:
- Task state schema should constrain what fields completed tasks MUST have
- This enables reliable extraction via `jq` without heuristics

## Goals & Non-Goals

**Goals**:
1. Add `completion_summary` field to task schema in state.json (required for completed tasks)
2. Update `/implement` postflight to populate `completion_summary`
3. Add corresponding summary line in TODO.md entries (for user visibility)
4. Update `/todo` to extract completion summaries via `jq` and match to roadmap items
5. Update state-management.md to document the new schema constraint
6. Update documentation to reflect the synchronized workflow

**Non-Goals**:
- Keyword/fuzzy matching (explicitly rejected)
- Automatic categorization of completion summaries
- Retroactive population of summaries for existing completed tasks

## Schema Design

### New Task Field: `completion_summary`

Added to `state.json` task entries when status transitions to "completed":

```json
{
  "project_number": 641,
  "project_name": "improve_todo_command_roadmap_update",
  "status": "completed",
  "completion_summary": "Implemented structured synchronization between task completion data and roadmap updates. Added completion_summary field to task schema, updated /implement to populate it, and updated /todo to use jq extraction for targeted roadmap matching.",
  "roadmap_items": ["Improve /todo command roadmap update mechanism"]
}
```

**Field specifications**:
- `completion_summary` (string, required when status="completed"): 1-3 sentence description of what was accomplished
- `roadmap_items` (array of strings, optional): Explicit list of ROAD_MAP.md item texts this task addresses

### Corresponding TODO.md Entry

```markdown
### 641. Improve /todo Command Roadmap Update Mechanism
- **Status**: [COMPLETED]
- **Completed**: 2026-01-20
- **Summary**: Implemented structured synchronization between task completion data and roadmap updates.
```

## Implementation Phases

### Phase 1: Update State Schema Documentation [COMPLETED]

**Goal**: Document the new `completion_summary` field as a required constraint for completed tasks.

**Tasks**:
- [ ] Update `.claude/rules/state-management.md` to add `completion_summary` field to state.json entry schema
- [ ] Add validation note: "When status='completed', completion_summary is REQUIRED"
- [ ] Add `roadmap_items` optional field for explicit roadmap linkage
- [ ] Document that `/implement` is responsible for populating these fields

**Timing**: 20 minutes

**Files to modify**:
- `.claude/rules/state-management.md` - state.json Entry section

**Verification**:
- Schema documentation clearly shows new fields
- Required/optional status documented
- Producer (implement) responsibility documented

---

### Phase 2: Update /implement Postflight [IN PROGRESS]

**Goal**: Modify `/implement` command to populate `completion_summary` at task completion.

**Tasks**:
- [ ] Locate CHECKPOINT 2: GATE OUT section in `/implement`
- [ ] Add step to construct `completion_summary` from implementation summary artifact
- [ ] Add jq command to update state.json with completion_summary field
- [ ] Add Edit operation to add "Summary:" line to TODO.md entry
- [ ] Handle case where implementation was partial (don't add summary)

**Timing**: 45 minutes

**Files to modify**:
- `.claude/commands/implement.md` - CHECKPOINT 2: GATE OUT section

**Implementation detail**:
```bash
# After successful implementation, extract summary from result
completion_summary="$result_summary"  # From skill return

# Update state.json with completion_summary
jq --arg summary "$completion_summary" \
   '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
     completion_summary: $summary
   }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

**Verification**:
- state.json updated with completion_summary field
- TODO.md updated with Summary line
- Partial implementations don't get summary

---

### Phase 3: Update /todo Roadmap Scanning [NOT STARTED]

**Goal**: Replace heuristic matching with structured jq extraction and matching.

**Tasks**:
- [ ] Rewrite Step 3.5 to extract completion_summaries via jq
- [ ] Match based on explicit `roadmap_items` field if present
- [ ] Fall back to completion_summary text search against unchecked roadmap items
- [ ] Track matches with their source (explicit vs summary-derived)
- [ ] Remove all keyword matching code

**Timing**: 60 minutes

**Files to modify**:
- `.claude/commands/todo.md` - Step 3.5 section

**Implementation detail**:
```bash
# Extract completed tasks with summaries
completed_with_summaries=$(jq -r '
  .active_projects[] |
  select(.status == "completed") |
  select(.completion_summary != null) |
  {
    number: .project_number,
    name: .project_name,
    summary: .completion_summary,
    roadmap_items: (.roadmap_items // [])
  }
' specs/state.json)

# For each completed task:
# 1. If roadmap_items specified, use them directly
# 2. Otherwise, search ROAD_MAP.md for unchecked items containing key phrases from summary

roadmap_matches=()
for task_json in $(echo "$completed_with_summaries" | jq -c '.'); do
  project_num=$(echo "$task_json" | jq -r '.number')
  summary=$(echo "$task_json" | jq -r '.summary')
  explicit_items=$(echo "$task_json" | jq -r '.roadmap_items[]' 2>/dev/null)

  if [ -n "$explicit_items" ]; then
    # Explicit mapping - highest confidence
    for item_text in $explicit_items; do
      line_num=$(grep -n "^\s*- \[ \].*${item_text}" specs/ROAD_MAP.md | cut -d: -f1 | head -1)
      if [ -n "$line_num" ]; then
        roadmap_matches+=("${project_num}:completed:explicit:${line_num}:${item_text}")
      fi
    done
  else
    # Summary-based search - extract key noun phrases and search
    # (This is semantic, not keyword heuristic - uses the actual completion context)
    # Implementation will grep for unchecked items containing distinctive phrases from summary
  fi
done
```

**Verification**:
- jq extraction works correctly
- Explicit roadmap_items matched first
- Summary-based matching finds relevant items
- No keyword heuristics used

---

### Phase 4: Update /todo Roadmap Annotation [NOT STARTED]

**Goal**: Update annotation format to include completion summary reference.

**Tasks**:
- [ ] Modify Step 5.5 to include summary in annotation
- [ ] Distinguish explicit matches from summary-derived matches in annotation
- [ ] Add match source (explicit/summary) to tracking

**Timing**: 30 minutes

**Files to modify**:
- `.claude/commands/todo.md` - Step 5.5 section

**New annotation format**:
```markdown
# For explicit roadmap_items match:
- [x] {item text} *(Completed: Task {N}, {DATE})*

# For summary-derived match (if implemented):
- [x] {item text} *(Completed: Task {N}, {DATE} - "{truncated_summary}")*
```

**Verification**:
- Annotations include task number and date
- Summary truncation works correctly
- Match source visible in annotation

---

### Phase 5: Update Dry-Run Output [NOT STARTED]

**Goal**: Show structured match information in dry-run mode.

**Tasks**:
- [ ] Update Step 4 to show completion summaries being used
- [ ] Distinguish explicit vs summary-derived matches
- [ ] Show the completion_summary content for each matched task
- [ ] Remove keyword match display code

**Timing**: 25 minutes

**Files to modify**:
- `.claude/commands/todo.md` - Step 4 section

**New dry-run output format**:
```
Roadmap updates (from completion summaries):

Task #641 (improve_todo_command_roadmap_update):
  Summary: "Implemented structured synchronization..."
  Matches:
    - [ ] Improve /todo command roadmap update mechanism (line 42) [explicit]
    - [ ] Add completion tracking to task workflow (line 58) [summary-derived]

Task #638 (add_roadmap_tracking_to_todo):
  Summary: "Added initial roadmap scanning..."
  Matches:
    - [ ] Implement roadmap scanning in /todo (line 35) [explicit]

Total roadmap items to update: 3
- Explicit matches: 2
- Summary-derived: 1
```

**Verification**:
- Dry-run shows completion summaries
- Match types distinguished
- Clear, actionable output

---

### Phase 6: Update Documentation [NOT STARTED]

**Goal**: Document the synchronized workflow and schema constraints.

**Tasks**:
- [ ] Update CLAUDE.md to mention completion_summary field
- [ ] Update /todo Notes section with new matching strategy
- [ ] Remove references to keyword matching
- [ ] Document the producer/consumer relationship (/implement → /todo)
- [ ] Add examples of well-formed completion summaries

**Timing**: 30 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - state.json Structure section
- `.claude/commands/todo.md` - Notes/Roadmap Updates section

**Example documentation**:
```markdown
### Completion Summaries

When a task is completed via `/implement`, a `completion_summary` field is added:

```json
{
  "completion_summary": "1-3 sentences describing what was accomplished",
  "roadmap_items": ["Optional explicit roadmap item text to match"]
}
```

The `/todo` command uses these summaries to:
1. Match against ROAD_MAP.md items (explicit `roadmap_items` first, then summary search)
2. Annotate completed items with task reference and date
3. Provide traceability from roadmap to implementation
```

**Verification**:
- Documentation reflects new workflow
- Examples are clear and actionable
- No keyword matching references remain

---

### Phase 7: Verification and Testing [NOT STARTED]

**Goal**: Verify the implementation works end-to-end.

**Tasks**:
- [ ] Create a test task with completion_summary
- [ ] Manually add completion_summary to an existing completed task in state.json
- [ ] Run `/todo --dry-run` to verify extraction and matching
- [ ] Verify ROAD_MAP.md annotation format
- [ ] Confirm no regressions in existing archival behavior

**Timing**: 30 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- jq extraction produces correct output
- Matching works for explicit and summary-derived cases
- Annotations are correctly formatted
- Existing functionality preserved

## Testing & Validation

- [ ] New state schema documented in state-management.md
- [ ] `/implement` populates completion_summary on success
- [ ] TODO.md shows Summary line for completed tasks
- [ ] `/todo --dry-run` shows completion summary extraction
- [ ] Explicit roadmap_items matched with high confidence
- [ ] Summary-derived matches work when explicit items absent
- [ ] Annotations include task reference and date
- [ ] No keyword/heuristic matching code remains

## Artifacts & Outputs

- `.claude/rules/state-management.md` - Updated schema documentation
- `.claude/commands/implement.md` - Updated postflight with summary population
- `.claude/commands/todo.md` - Updated roadmap matching and annotation
- `.claude/CLAUDE.md` - Updated state.json documentation
- `specs/641_improve_todo_command_roadmap_update/summaries/implementation-summary-{DATE}.md` - Completion summary

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Completion summaries not consistently populated | High | Medium | Make field required for completed status, validate in /todo |
| Explicit roadmap_items rarely used | Low | High | Summary-derived matching as fallback, encourage explicit items in implementation workflow |
| Summary search produces false positives | Medium | Low | Only search unchecked items, require substantial phrase match |
| Migration for existing completed tasks | Low | N/A | Not in scope, only affects new completions |

## Rollback/Contingency

If structured matching proves insufficient:
1. The completion_summary field is still valuable for documentation
2. Can add heuristic matching as a tertiary fallback (not primary)
3. Schema changes are additive, no breaking changes to existing data

Changes are isolated to command definitions and documentation. Rollback is straightforward via git revert.

## Comparison to v001

| Aspect | v001 (Keyword Matching) | v002 (Structured Sync) |
|--------|-------------------------|------------------------|
| Data source | Task name tokenization | Explicit completion_summary |
| Matching strategy | Heuristic keyword overlap | jq extraction + text search |
| False positive risk | Medium (requires exclusion list) | Low (uses semantic content) |
| Maintenance burden | High (exclusion list updates) | Low (schema is stable) |
| Traceability | Limited | Full (summary documents intent) |
| Producer responsibility | None | /implement must populate summary |
| Consumer logic | Complex tokenization | Simple jq queries |
