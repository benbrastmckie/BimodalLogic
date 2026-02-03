# Research Report: Task #834

**Task**: 834 - Enhance /todo Command with Changelog Updates and Task Suggestions
**Started**: 2026-02-03T10:30:00Z
**Completed**: 2026-02-03T10:50:00Z
**Effort**: 3-4 hours (estimated for implementation)
**Dependencies**: Task 833 (Enhance ROADMAP.md Structure with Changelog, Strategies, and Ambitions)
**Sources/Inputs**:
- Current `/todo` command: `.claude/commands/todo.md` (~1188 lines)
- Task 833 research: `specs/833_enhance_roadmap_structure_changelog_strategies_ambitions/reports/research-001.md`
- `/learn` command output pattern: `.claude/skills/skill-learn/SKILL.md`, `.claude/docs/examples/learn-flow-example.md`
- State management rules: `.claude/rules/state-management.md`
- Current ROADMAP: `specs/ROAD_MAP.md`
- skill-status-sync: `.claude/skills/skill-status-sync/SKILL.md`
**Artifacts**: This report
**Standards**: report-format.md

## Executive Summary

- The `/todo` command is a comprehensive 1188-line command that handles task archival, roadmap updates, CLAUDE.md suggestions, orphan/misplaced directories, and repository metrics
- Task 833 defines the Changelog schema: `### YYYY-MM-DD` date headers with `- **Task {N}**: {summary}` entries
- Task suggestion generation should follow the `/learn` output pattern: analyze sources, propose 3-5 tasks with clear structure
- Implementation requires two additions to the `/todo` command: (1) Changelog update step (Step 5.8), (2) Task suggestion generation (Step 7.5)
- skill-status-sync does NOT need updates; `/todo` already handles its own status updates inline

## Context & Scope

### Task 834 Requirements

From the task description:
1. **Update ROADMAP.md Changelog section** when archiving completed tasks
2. **Add task suggestion generation** at end of /todo execution
3. **Update skill-status-sync or create new skill** if delegation is needed

### Dependency: Task 833 Schemas

Task 833 (status: researched) defines the Changelog section schema that this task will consume:

**Changelog Schema**:
```markdown
## Changelog

### YYYY-MM-DD

- **Task {N}**: {completion_summary} [(details)](path/to/summary)
- **Task {N}**: {completion_summary}

### YYYY-MM-DD

- **Task {N}**: {completion_summary}
```

**Parsing Patterns** (from Task 833):
```
Date header: ^### (\d{4}-\d{2}-\d{2})$
Entry: ^- \*\*Task (\d+)\*\*: (.+?)(?:\s*\[.*?\]\(.*?\))?$
```

**Update Rules** (from Task 833):
1. Group archived tasks by completion date
2. If date header exists, append entries
3. If date header doesn't exist, create it (reverse chronological order)
4. Include optional `[(details)](path)` link if summary artifact exists

## Findings

### Current /todo Command Structure (Analysis)

The `/todo` command has 7 main sections:

| Step | Name | Lines | Purpose |
|------|------|-------|---------|
| 1 | Parse Arguments | 18-22 | Handle `--dry-run` flag |
| 2-2.6 | Scan Operations | 26-124 | Find archivable, orphaned, misplaced tasks |
| 3-3.6 | Prepare Archive List | 126-330 | Roadmap matching, CLAUDE.md suggestions extraction |
| 4-4.6 | Dry Run / User Prompts | 332-488 | Show preview, handle orphan/misplaced decisions |
| 5-5.7 | Archive Tasks | 490-912 | Move files, update states, roadmap, CLAUDE.md, metrics |
| 6 | Git Commit | 914-944 | Commit all changes |
| 7 | Output | 946-1013 | Display summary |

**Key insertion points identified**:
- **Changelog update**: Add Step 5.8 after Step 5.7 (Sync Repository Metrics) and before Step 6 (Git Commit)
- **Task suggestions**: Add Step 7.5 after Step 7 (Output) as a final display section

### Changelog Integration Design

**Step 5.8: Update Changelog Section**

This step updates the ROADMAP.md Changelog section with completed task entries.

**Prerequisites**:
- Task 833 must be implemented first (Changelog section must exist in ROADMAP.md)
- Only completed tasks (not abandoned) are added to Changelog

**Algorithm**:

1. **Filter completed tasks** (exclude abandoned):
   ```bash
   # From archivable tasks, extract only completed ones
   completed_tasks=()
   for task in "${archivable_tasks[@]}"; do
     status=$(echo "$task" | jq -r '.status')
     if [ "$status" = "completed" ]; then
       completed_tasks+=("$task")
     fi
   done
   ```

2. **Group by completion date**:
   ```bash
   # Build date -> tasks map
   declare -A tasks_by_date
   for task in "${completed_tasks[@]}"; do
     # Extract date from task completion timestamp (ISO8601 -> YYYY-MM-DD)
     completed_ts=$(echo "$task" | jq -r '.last_updated // .completed // .archived')
     date=$(echo "$completed_ts" | cut -c1-10)  # YYYY-MM-DD
     project_num=$(echo "$task" | jq -r '.project_number')
     summary=$(echo "$task" | jq -r '.completion_summary // "Completed"')

     # Store entry
     entry="- **Task ${project_num}**: ${summary}"
     tasks_by_date[$date]+="${entry}\n"
   done
   ```

3. **For each date, update ROADMAP.md**:
   ```bash
   for date in "${!tasks_by_date[@]}"; do
     date_header="### ${date}"
     entries="${tasks_by_date[$date]}"

     # Check if date header exists in Changelog section
     if grep -q "^${date_header}$" specs/ROAD_MAP.md; then
       # Append after existing date header
       # Use Edit tool: old_string = "### {date}\n\n", new_string = "### {date}\n\n{entries}\n"
     else
       # Insert new date header after "## Changelog" in reverse chronological position
       # Find insertion point: after ## Changelog, before any date that comes after this one
     fi
   done
   ```

4. **Track changes for output**:
   ```bash
   changelog_entries_added=0
   changelog_dates_created=0
   ```

**Edit Pattern for Appending to Existing Date**:
```
old_string: "### YYYY-MM-DD\n\n"
new_string: "### YYYY-MM-DD\n\n- **Task {N}**: {summary}\n"
```

**Edit Pattern for Creating New Date Header**:
```
old_string: "## Changelog\n\n"
new_string: "## Changelog\n\n### YYYY-MM-DD\n\n- **Task {N}**: {summary}\n\n"
```

**Reverse Chronological Ordering**:
When inserting a new date, find the correct position:
1. Scan for all existing date headers: `grep -n "^### [0-9]" specs/ROAD_MAP.md`
2. Find first date that is older than new date
3. Insert before that date

### Task Suggestion Generation Design

**Step 7.5: Generate Task Suggestions**

This step analyzes sources and proposes 3-5 next tasks, displayed at the end of `/todo` output.

**Sources to Analyze** (in priority order):

1. **Active tasks from state.json** - Identify blocked or stale tasks
2. **ROADMAP.md Ambitions** - Extract unchecked success criteria
3. **ROADMAP.md Strategies** - Check ACTIVE strategies for next steps
4. **Recent completions** - Identify follow-up work patterns

**Suggestion Categories**:

| Category | Source | Example Suggestion |
|----------|--------|-------------------|
| **Unblocked** | Active tasks with cleared dependencies | "Task 835 is now unblocked - ready for /research" |
| **Stale** | Tasks not_started for >7 days | "Task 750 has been waiting 14 days - consider prioritizing" |
| **Ambition Progress** | Unchecked criteria in Ambitions | "Ambition 'Proof Quality': 2/5 criteria remaining" |
| **Strategy Next Steps** | ACTIVE strategies with next_steps | "Strategy 'Representation-First': Next step - prove compositionality" |
| **Follow-up** | Patterns from completed tasks | "Consider /learn to find new FIX:/TODO: tags" |
| **New Task** | Gaps identified in analysis | "Create task: Port soundness from Boneyard" |

**Algorithm**:

1. **Scan active tasks**:
   ```bash
   # Get all active tasks
   active_tasks=$(jq '.active_projects[]' specs/state.json)

   # Find tasks that are unblocked (no dependencies or all deps completed)
   # Find stale tasks (not_started and created > 7 days ago)
   ```

2. **Parse ROADMAP.md sections** (requires Task 833 implementation):
   ```bash
   # Extract Ambitions section
   ambitions=$(sed -n '/^## Ambitions/,/^## /p' specs/ROAD_MAP.md)
   # Count unchecked criteria: grep -c "^- \[ \]"

   # Extract Strategies section
   strategies=$(sed -n '/^## Strategies/,/^## /p' specs/ROAD_MAP.md)
   # Find ACTIVE strategies with Next Steps
   ```

3. **Analyze recent completions** (from just-archived tasks):
   ```bash
   # Check for patterns:
   # - Multiple related tasks completed -> suggest consolidation review
   # - All tasks in a phase completed -> suggest next phase
   # - Implementation completed -> suggest /learn for cleanup
   ```

4. **Generate suggestions** (limit to 5):
   ```bash
   suggestions=()
   # Priority: unblocked > stale > ambition > strategy > follow-up > new
   ```

**Output Format** (following /learn pattern):

```
## Task Suggestions

Based on analysis of active tasks, ROADMAP, and recent completions:

### Recommended Next Steps

1. **Ready to start**: Task 835 (/review command integration) is now unblocked
   - Run `/research 835` to begin

2. **Stale task**: Task 750 (Hybrid ultrafilter approach) has been pending 14 days
   - Consider prioritizing or abandoning with `/task --abandon 750`

3. **Ambition progress**: "Proof Quality and Organization" - 3 unchecked criteria
   - "Audit proof dependencies" still open
   - "Create domain-specific tactics" still open
   - "Add helpful simp lemmas" still open

4. **Strategy next step**: "Representation-First Architecture" (ACTIVE)
   - Next step: "Measure proof economy improvement"

5. **Maintenance**: Consider running `/learn` to scan for new FIX:/TODO: tags

---

Active tasks: {N} | Completed today: {M} | ROADMAP ambitions: {K} unchecked criteria
```

### Skill Update Assessment

**Question**: Does skill-status-sync need updates?

**Answer**: NO. The `/todo` command already handles all status updates inline via direct jq/Edit operations. It does not delegate to skill-status-sync.

Evidence from `/todo` command:
- Step 5B: "Update state.json" - uses jq directly
- Step 5C: "Update TODO.md" - uses Edit tool directly
- Step 5.5: "Update Roadmap" - uses Edit tool directly
- Step 5.7: "Sync Repository Metrics" - uses jq and Edit directly

The skill-status-sync is for **standalone use** only (per its SKILL.md):
> "IMPORTANT: This skill is for STANDALONE USE ONLY. Workflow skills now handle their own preflight/postflight status updates inline."

### Implementation Complexity Analysis

| Change | Complexity | Notes |
|--------|------------|-------|
| Step 5.8: Changelog update | Medium | Requires date parsing, Edit operations, reverse chronological ordering |
| Step 7.5: Task suggestions | Medium-High | Multiple source analysis, output formatting, follows /learn pattern |
| Dry-run updates | Low | Add changelog preview and suggestions preview to dry-run output |
| Git commit message | Low | Add changelog count to commit message |
| Output section | Low | Add changelog summary and suggestions to output |

**Total estimated effort**: 3-4 hours

## Recommendations

### Implementation Phases

**Phase 1: Changelog Integration (2 hours)**

1. Add Step 5.8 after Step 5.7 in `/todo` command
2. Implement date grouping and Edit patterns
3. Handle reverse chronological ordering for new dates
4. Update dry-run output to show changelog preview
5. Update git commit message to include changelog count
6. Update final output to show changelog summary

**Phase 2: Task Suggestions (1.5 hours)**

1. Add Step 7.5 after Step 7 in `/todo` command
2. Implement active task analysis (unblocked, stale)
3. Implement ROADMAP parsing for Ambitions/Strategies
4. Implement suggestion formatting following /learn pattern
5. Add suggestions to final output

**Phase 3: Edge Cases (0.5 hours)**

1. Handle case where Changelog section doesn't exist (require Task 833 first)
2. Handle case where no suggestions are available
3. Test with zero completed tasks (changelog step no-op)

### Insertion Points in /todo Command

**Step 5.8 Location** (after line ~912, before Step 6):

```markdown
### 5.8. Update Changelog Section

**Condition**: At least one completed task is being archived AND Changelog section exists in ROAD_MAP.md

**Step 5.8.1: Group completed tasks by date**:
...

**Step 5.8.2: Update ROAD_MAP.md Changelog**:
...

**Step 5.8.3: Track changes**:
...
```

**Step 7.5 Location** (after line ~1013, before Notes section):

```markdown
### 7.5. Generate Task Suggestions

**Condition**: Always execute at end of /todo

**Step 7.5.1: Analyze active tasks**:
...

**Step 7.5.2: Parse ROADMAP sections**:
...

**Step 7.5.3: Generate suggestions**:
...

**Step 7.5.4: Display suggestions**:
...
```

### Dry-Run Output Updates

Add to Step 4 (Dry Run Output):

```
Changelog updates:

Entries to add:
- 2026-02-03: Task #829, Task #830 (2 entries, new date header)
- 2026-02-02: Task #825 (1 entry, existing date header)

Total: 3 entries across 2 dates

---

Task suggestions will be shown after archival completes.
```

### Git Commit Message Update

Update Step 6 commit message patterns:

```bash
# Current pattern:
git commit -m "todo: archive {N} tasks, update {R} roadmap items, ..."

# New pattern with changelog:
git commit -m "todo: archive {N} tasks, update {R} roadmap items, add {C} changelog entries, ..."
```

### Final Output Updates

Add to Step 7:

```
Changelog updated: {N} entries
- 2026-02-03: 2 entries (new date header)
- 2026-02-02: 1 entry (appended)

---

## Task Suggestions
{suggestions content}
```

## Decisions

1. **Changelog only for completed tasks**: Abandoned tasks are NOT added to Changelog (they're tracked in state.json with abandoned_reason but not celebrated in Changelog)

2. **Date format**: Use ISO 8601 (YYYY-MM-DD) matching Task 833 schema

3. **Summary source**: Use `completion_summary` field from state.json; fall back to "Completed" if missing

4. **Link format**: Include `[(details)](path)` only if summary artifact exists

5. **Suggestion limit**: Maximum 5 suggestions to keep output manageable

6. **Suggestion priority**: unblocked > stale > ambition > strategy > follow-up > new

7. **Requires Task 833**: Changelog update step checks for section existence; errors gracefully if missing

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Task 833 not complete | High | Check for Changelog section existence; skip Step 5.8 with warning if missing |
| Edit pattern failures | Medium | Use unique strings for Edit operations; test with multiple scenarios |
| Large Changelog section | Low | Date headers provide natural partitioning; no performance issue expected |
| Suggestion analysis slow | Low | Simple jq and grep operations; cache parsed ROADMAP content |
| No suggestions available | Low | Display "No suggestions - all tasks look good!" message |

## Appendix

### Files to Modify

1. `.claude/commands/todo.md` - Add Steps 5.8 and 7.5
2. `specs/ROAD_MAP.md` - Will be modified by Step 5.8 (requires Task 833 first)

### Related Documentation

- Task 833 research: `specs/833_enhance_roadmap_structure_changelog_strategies_ambitions/reports/research-001.md`
- /learn output pattern: `.claude/docs/examples/learn-flow-example.md`
- State management: `.claude/rules/state-management.md`

### Test Scenarios

1. **Normal case**: 2 completed tasks, 1 abandoned task -> Changelog gets 2 entries
2. **New date header**: First task completed on a new day -> Creates date header
3. **Existing date header**: Task completed same day as previous -> Appends to existing
4. **No completed tasks**: Only abandoned tasks archived -> Changelog step skipped
5. **Missing Changelog section**: Task 833 not complete -> Skip with warning
6. **Suggestions with all sources**: Active tasks, Ambitions, Strategies all present -> Full suggestions
7. **No suggestions needed**: All tasks completed, no unchecked criteria -> "All looks good" message

## Next Steps

1. Run `/plan 834` to create implementation plan
2. Ensure Task 833 is implemented first (creates Changelog section structure)
3. Implementation should update `/todo` command with Steps 5.8 and 7.5
4. Test with dry-run before live archival
5. After 834 completes, proceed with Task 835 (/review command integration)
