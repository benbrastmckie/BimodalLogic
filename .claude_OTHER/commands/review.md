---
description: Review code and create analysis reports
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), TaskCreate, TaskUpdate, AskUserQuestion
argument-hint: [SCOPE] [--create-tasks]
model: opus
---

# /review Command

Analyze codebase, identify issues, and optionally create tasks for fixes.

## Arguments

- `$1` - Optional scope: file path, directory, or "all"
- `--create-tasks` - Create tasks for identified issues

## Execution

### 1. Parse Arguments

```
scope = $1 or "all"
create_tasks = "--create-tasks" in $ARGUMENTS
```

Determine review scope:
- If file path: Review that file
- If directory: Review all files in directory
- If "all": Review entire codebase

### 1.5. Load Review State

Read existing state file or initialize if missing:

```bash
# Read or create specs/reviews/state.json
if [ -f specs/reviews/state.json ]; then
  review_state=$(cat specs/reviews/state.json)
else
  # Initialize with empty state
  mkdir -p specs/reviews
  echo '{"_schema_version":"1.0.0","_comment":"Review state tracking","_last_updated":"","reviews":[],"statistics":{"total_reviews":0,"last_review":"","total_issues_found":0,"total_tasks_created":0}}' > specs/reviews/state.json
fi
```

### 2. Gather Context

**For Lua files (.lua):**
- Run project-specific lint/check commands to verify correctness
- Check for TODO/FIXME comments
- Identify incomplete configurations
- Check module organization

**For general code:**
- Check for TODO/FIXME comments
- Identify code smells
- Check for security issues
- Review error handling

**For documentation:**
- Check for outdated information
- Identify missing documentation
- Verify links work

### 2.5. Roadmap Integration

**Context**: Load @.claude/context/formats/roadmap-format.md for parsing patterns.

**Ensure specs/ROADMAP.md exists** before parsing. If the file does not exist, create it with the default template:
```markdown
# Project Roadmap

## Phase 1: Current Priorities (High Priority)

- [ ] (No items yet -- add roadmap items here)

## Success Metrics

- (Define success metrics here)
```

Parse `specs/ROADMAP.md` to extract:
1. **Phase headers**: `## Phase {N}: {Title} ({Priority})`
2. **Checkboxes**: `- [ ]` (incomplete) and `- [x]` (complete)
3. **Status tables**: Pipe-delimited rows with Component/Status/Location
4. **Priority markers**: `(High Priority)`, `(Medium Priority)`, `(Low Priority)`

Build `roadmap_state` structure:
```json
{
  "phases": [
    {
      "number": 1,
      "title": "Proof Quality and Organization",
      "priority": "High",
      "checkboxes": {
        "total": 15,
        "completed": 3,
        "items": [
          {"text": "Audit proof dependencies", "completed": false},
          {"text": "Create proof architecture guide", "completed": true}
        ]
      }
    }
  ],
  "status_tables": [
    {
      "component": "Soundness",
      "status": "PROVEN",
      "location": "src/plugins/lsp.lua"
    }
  ]
}
```

**Error handling**: If ROADMAP.md doesn't exist or fails to parse, log warning and continue review without roadmap integration.

### 2.5.2. Cross-Reference Roadmap with Project State

**Context**: Load @.claude/context/patterns/roadmap-update.md for matching strategy.

Cross-reference roadmap items with project state to identify completed work:

**1. Query TODO.md for completed tasks:**
```bash
# Find completed task titles
grep -E '^\#\#\#.*\[COMPLETED\]' specs/TODO.md
```

**2. Query state.json for completion data:**
```bash
# Get completed tasks with dates
jq '.active_projects[] | select(.status == "completed")' specs/state.json
```

**3. Check file existence for mentioned paths:**
```bash
# For each path in roadmap items, check if exists
# E.g., docs/architecture/proof-structure.md
```

**4. Count TODOs in Lua files:**
```bash
# Current TODO count for metrics
grep -r "TODO" . --include="*.lua" --include="*.py" --include="*.js" --include="*.ts" --include="*.tex" | wc -l
```

**Match roadmap items to completed work:**

| Match Type | Confidence | Action |
|------------|------------|--------|
| Item contains `(Task {N})` | High | Auto-annotate |
| Item text matches task title | Medium | Suggest annotation |
| Item's file path exists | Medium | Suggest annotation |
| Partial keyword match | Low | Report only |

Build `roadmap_matches` list:
```json
[
  {
    "roadmap_item": "Create proof architecture guide",
    "phase": 1,
    "match_type": "title_match",
    "confidence": "medium",
    "matched_task": 628,
    "completion_date": "2026-01-15"
  }
]
```

### 2.5.3. Annotate Completed Roadmap Items

For high-confidence matches, update ROADMAP.md to mark items as complete.

**Annotation format** (per roadmap-format.md):
```markdown
- [x] {item text} *(Completed: Task {N}, {DATE})*
```

**Edit process for checkboxes:**

1. For each high-confidence match:
   ```
   old_string: "- [ ] Create proof architecture guide"
   new_string: "- [x] Create proof architecture guide *(Completed: Task 628, 2026-01-15)*"
   ```

2. Use Edit tool with exact string matching

**Edit process for status tables:**

1. For components verified as complete:
   ```
   old_string: "| **Soundness** | PARTIAL |"
   new_string: "| **Soundness** | PROVEN |"
   ```

**Safety rules:**
- Skip items already annotated (contain `*(Completed:`)
- Preserve existing formatting and indentation
- One edit per item (no batch edits)
- Log skipped items for report

**Track changes:**
```json
{
  "annotations_made": 3,
  "items_skipped": 2,
  "skipped_reasons": ["already_annotated", "low_confidence"]
}
```

### 2.6. Parse Task Order

**Context**: Load @.claude/context/formats/task-order-format.md for parsing patterns.

Read `specs/TODO.md` and extract the Task Order section if present.

**1. Extract Task Order lines:**
```bash
# Find lines between "## Task Order" and "## Tasks"
task_order_start=$(grep -n "^## Task Order$" specs/TODO.md | head -1 | cut -d: -f1)
task_order_end=$(grep -n "^## Tasks$" specs/TODO.md | head -1 | cut -d: -f1)

if [ -z "$task_order_start" ]; then
  # No Task Order section -- set exists=false and skip
  task_order_state='{"exists": false}'
else
  # Extract lines between headers (exclusive of both)
  task_order_lines=$(sed -n "$((task_order_start+1)),$((task_order_end-1))p" specs/TODO.md)
fi
```

**2. Parse metadata (wave+tree format):**

Extract timestamp and goal from the Task Order lines:

| Element | Regex | Capture Groups |
|---------|-------|----------------|
| Timestamp | `^\*Updated (\d{4}-\d{2}-\d{2})\. (.+)\*$` | (1) date, (2) changelog |
| Goal | `^\*\*Goal\*\*: (.+)$` | (1) goal text |

**3. Parse wave table:**

Find lines in the wave summary table (between `| Wave |` header and blank line after table):
- Table header regex: `^\| Wave \| Tasks \| Blocked by \|$`
- Table row regex: `^\| (\d+) \| ([\d, ]+) \| ([\d, ]*|-{1,2}) \|$`
  - Capture (1) wave number, (2) comma-separated task numbers, (3) blocking wave numbers or `--`

Build wave list:
```json
[
  {"wave": 1, "tasks": [101, 102], "blocked_by": []},
  {"wave": 2, "tasks": [103], "blocked_by": [1]}
]
```

**4. Parse dependency tree entries:**

After the wave table, find lines matching the tree format:
- Root task (no indent): `^(\d+)\s+\[([A-Z ]+)\]\s+(.+)$`
  - Capture (1) task number, (2) status, (3) title/description
- Child task (indented with `├──` or `└──`): `^[│\s]*[├└]──\s+(\d+)\s+\[([A-Z ]+)\]\s+(.+)$`
  - Capture (1) task number, (2) status, (3) title/description
  - Parent is the nearest ancestor at a lower indentation level

Build tree entries:
```json
[
  {"task_number": 101, "status": "COMPLETED", "description": "Define schema", "depth": 0, "parent": null},
  {"task_number": 102, "status": "NOT STARTED", "description": "Add parsing", "depth": 1, "parent": 101},
  {"task_number": 87, "status": "RESEARCHED", "description": "Investigate wezterm", "depth": 0, "parent": null}
]
```

**5. Build `task_order_state` structure:**

```json
{
  "exists": true,
  "timestamp": "2026-03-24",
  "changelog": "Archived 3 tasks. Regenerated Task Order.",
  "goal": "Complete modal logic completeness proof.",
  "waves": [
    {"wave": 1, "tasks": [101, 87], "blocked_by": []},
    {"wave": 2, "tasks": [102], "blocked_by": [1]}
  ],
  "tree_entries": [
    {"task_number": 101, "status": "COMPLETED", "description": "Define schema", "depth": 0, "parent": null},
    {"task_number": 102, "status": "NOT STARTED", "description": "Add parsing", "depth": 1, "parent": 101},
    {"task_number": 87, "status": "RESEARCHED", "description": "Investigate wezterm", "depth": 0, "parent": null}
  ],
  "all_task_numbers": [101, 102, 87]
}
```

**Error handling**: If `## Task Order` does not exist in TODO.md, set `task_order_state.exists = false` and continue review without Task Order operations. Downstream sections (pruning, interactive management) check `task_order_state.exists` before operating.

### 3. Analyze Findings

Categorize issues:
- **Critical**: Broken functionality, security vulnerabilities
- **High**: Missing features, significant bugs
- **Medium**: Code quality issues, incomplete implementations
- **Low**: Style issues, minor improvements

### 4. Create Review Report

Write to `specs/reviews/review-{DATE}.md`:

```markdown
# Code Review Report

**Date**: {ISO_DATE}
**Scope**: {scope}
**Reviewed by**: Claude

## Summary

- Total files reviewed: {N}
- Critical issues: {N}
- High priority issues: {N}
- Medium priority issues: {N}
- Low priority issues: {N}

## Critical Issues

### {Issue Title}
**File**: `path/to/file:line`
**Description**: {what's wrong}
**Impact**: {why it matters}
**Recommended fix**: {how to fix}

## High Priority Issues

{Same format}

## Medium Priority Issues

{Same format}

## Low Priority Issues

{Same format}

## Code Quality Metrics

| Metric | Value | Status |
|--------|-------|--------|
| TODO count | {N} | {Info} |
| FIXME count | {N} | {OK/Warning} |
| Build status | {Pass/Fail} | {Status} |

## Roadmap Progress

### Completed Since Last Review
- [x] {item} *(Completed: Task {N}, {DATE})*
- [x] {item} *(Completed: Task {N}, {DATE})*

### Current Focus
| Phase | Priority | Current Goal | Progress |
|-------|----------|--------------|----------|
| Phase 1 | High | Audit proof dependencies | 3/15 items |
| Phase 2 | Medium | Define SetDerivable | 0/8 items |

### Recommended Next Tasks
1. {Task recommendation} (Phase {N}, {Priority})
2. {Task recommendation} (Phase {N}, {Priority})

## Recommendations

1. {Priority recommendation}
2. {Secondary recommendation}
```

### 4.5. Update Review State

After creating the review report, update `specs/reviews/state.json`:

1. **Generate review entry:**
```json
{
  "review_id": "review-{DATE}",
  "date": "{ISO_DATE}",
  "scope": "{scope}",
  "report_path": "specs/reviews/review-{DATE}.md",
  "summary": {
    "files_reviewed": {N},
    "critical_issues": {N},
    "high_issues": {N},
    "medium_issues": {N},
    "low_issues": {N}
  },
  "tasks_created": [],
  "registries_updated": []
}
```

2. **Add entry to reviews array**
3. **Update statistics:**
   - Increment `total_reviews`
   - Update `last_review` date
   - Add issue counts to `total_issues_found`
4. **Update `_last_updated` timestamp**

### 5. Task Proposal Mode

The review command always presents task proposals after analysis. The `--create-tasks` flag controls the interaction mode:

**Default (no flag)**: Proceed to Section 5.5 for interactive group selection via AskUserQuestion.

**With `--create-tasks` flag**: Auto-create tasks for all Critical/High severity issues without prompting:

```
For each Critical/High issue:
  /task "Fix: {issue title}" --task-type={inferred_task_type} --priority={severity}
```

Link tasks to review report.

**Update state:** Add created task numbers to the `tasks_created` array in the review entry:
```json
"tasks_created": [601, 602, 603]
```

Also increment `statistics.total_tasks_created` by the count of new tasks.

**Note**: When `--create-tasks` is used, skip Section 5.5 interactive selection.

### 5.5. Issue Grouping and Task Recommendations

Group review issues and roadmap items into coherent task proposals, then present for interactive selection.

#### 5.5.1. Collect All Issues

Combine issues from review findings and incomplete roadmap items:

**From Review Findings** (Section 3-4):
```json
{
  "source": "review",
  "file_path": "src/plugins/lsp.lua",
  "line": 42,
  "severity": "high",
  "description": "Missing case in pattern match",
  "impact": "May cause incomplete evaluation",
  "recommended_fix": "Add wildcard case handler"
}
```

**From Roadmap Items** (Section 2.5):
```json
{
  "source": "roadmap",
  "file_path": null,
  "phase": 1,
  "priority": "high",
  "description": "Audit proof dependencies",
  "item_text": "Audit proof dependencies for Soundness.lean"
}
```

#### 5.5.2. Extract Grouping Indicators

For each issue, extract grouping indicators:

| Indicator | Extraction Rule |
|-----------|-----------------|
| `file_section` | Path prefix up to first-level directory (e.g., `src/plugins/` from `src/plugins/lsp.lua:42`) |
| `issue_type` | Map severity: Critical/High -> "fix", Medium -> "quality", Low -> "improvement". For roadmap: "roadmap" |
| `priority` | Direct from severity (Critical=4, High=3, Medium=2, Low=1) or phase priority |
| `key_terms` | Extract significant words (>4 chars, not stopwords) from description |

**Example extracted indicators:**
```json
{
  "file_section": "src/plugins/",
  "issue_type": "fix",
  "priority": 3,
  "key_terms": ["pattern", "match", "evaluation", "incomplete"]
}
```

#### 5.5.3. Clustering Algorithm

Group issues using file_section + issue_type as primary criteria:

```
groups = []

for each issue in all_issues:
  matched = false

  # Primary match: same file_section AND same issue_type
  for each group in groups:
    if issue.file_section == group.file_section AND issue.issue_type == group.issue_type:
      add issue to group.items
      matched = true
      break

  # Secondary match: 2+ shared key_terms AND same priority
  if not matched:
    for each group in groups:
      shared_terms = intersection(issue.key_terms, group.key_terms)
      if len(shared_terms) >= 2 AND issue.priority == group.priority:
        add issue to group.items
        update group.key_terms with union
        matched = true
        break

  # No match: create new group
  if not matched:
    new_group = {
      "file_section": issue.file_section,
      "issue_type": issue.issue_type,
      "priority": issue.priority,
      "key_terms": issue.key_terms,
      "items": [issue]
    }
    append new_group to groups
```

#### 5.5.4. Group Post-Processing

Apply size limits and generate labels:

**1. Combine small groups:**
Groups with <2 items are merged into nearest match or "Other" group.

**2. Cap total groups:**
Maximum 10 groups. If exceeded, merge lowest-priority groups.

**3. Generate group labels:**

| Condition | Label Format |
|-----------|--------------|
| Has file_section | "{directory} {issue_type}s" (e.g., "Bimodal fixes") |
| Same priority, no section | "{key_term} issues" (e.g., "Proof quality issues") |
| Roadmap items | "Roadmap: {phase_name}" |
| Mixed/Other | "Other {issue_type}s" |

**4. Calculate group metadata:**
```json
{
  "label": "Bimodal fixes",
  "item_count": 3,
  "severity_breakdown": {"critical": 1, "high": 2},
  "file_list": ["Soundness.lean", "Correctness.lean"],
  "max_priority": 3,
  "total_score": 11
}
```

#### 5.5.5. Score Groups for Ordering

Sort groups by combined score:

| Factor | Score |
|--------|-------|
| Contains critical issue | +10 |
| Contains high issue | +5 |
| Group max priority: Critical | +8 |
| Group max priority: High | +6 |
| Group max priority: Medium | +4 |
| Group max priority: Low | +2 |
| Number of items (capped at 5) | +N |
| Roadmap "Near Term" items | +3 |

Sort groups by descending score.

#### 5.5.6. Interactive Group Selection (Tier 1)

Present grouped task proposals via AskUserQuestion with multiSelect:

```json
{
  "question": "Which task groups should be created?",
  "header": "Review Task Proposals",
  "multiSelect": true,
  "options": [
    {
      "label": "[Group] {group_label} ({item_count} issues)",
      "description": "{severity_breakdown} | Files: {file_list}"
    }
  ]
}
```

**Option generation:**

For each group (sorted by score):
```json
{
  "label": "[Group] Bimodal fixes (3 issues)",
  "description": "Critical: 1, High: 2 | Files: Soundness.lean, Correctness.lean"
}
```

For ungrouped individual issues (if <2 items couldn't form groups):
```json
{
  "label": "[Individual] {issue_title, truncated to 50 chars}",
  "description": "{severity} | {file}:{line}"
}
```

**Selection handling:**
- Empty selection: No tasks created, proceed to Section 6
- Any selection: Proceed to Tier 2 granularity selection

#### 5.5.7. Granularity Selection (Tier 2)

For selected groups, ask how tasks should be created:

```json
{
  "question": "How should selected groups be created as tasks?",
  "header": "Task Granularity",
  "multiSelect": false,
  "options": [
    {
      "label": "Keep as grouped tasks",
      "description": "Creates {N} tasks (one per selected group)"
    },
    {
      "label": "Expand into individual tasks",
      "description": "Creates {M} tasks (one per issue in selected groups)"
    },
    {
      "label": "Show issues and select manually",
      "description": "See all issues in selected groups for manual selection"
    }
  ]
}
```

**Option handling:**

**"Keep as grouped tasks"**: Proceed to Section 5.6 with grouped task creation.

**"Expand into individual tasks"**: Proceed to Section 5.6 with individual task creation for all issues in selected groups.

**"Show issues and select manually"**: Present Tier 3 manual selection:

```json
{
  "question": "Select individual issues to create as tasks:",
  "header": "Issue Selection",
  "multiSelect": true,
  "options": [
    {
      "label": "{issue_description, truncated to 60 chars}",
      "description": "{severity} | {file}:{line} | From: {group_label}"
    }
  ]
}
```

After manual selection, proceed to Section 5.6 with individual task creation for selected issues.

### 5.6. Task Creation from Selection

Create tasks based on selection and granularity choices from Sections 5.5.6 and 5.5.7.

#### 5.6.1. Grouped Task Creation

When "Keep as grouped tasks" is selected, create one task per group:

**Task fields:**
```json
{
  "title": "{group_label}: {item_count} issues",
  "description": "{combined issue descriptions with file:line references}",
  "task_type": "{majority_task_type}",
  "priority": "{max_priority_in_group}"
}
```

**Task type inference by majority file type in group:**
| File pattern | Task Type |
|--------------|-----------|
| `*.lua` | general |
| `*.md`, `*.json`, `.claude/**` | meta |
| `*.tex` | latex |
| `*.typ` | typst |
| Other | general |

**Description format:**
```markdown
Review issues from {scope} review on {DATE}:

1. [{severity}] {file}:{line} - {description}
   Impact: {impact}
   Fix: {recommended_fix}

2. [{severity}] {file}:{line} - {description}
   ...

Related files: {file_list}
```

#### 5.6.2. Individual Task Creation

When "Expand into individual tasks" or manual selection is chosen:

**Task fields:**
```json
{
  "title": "{issue_description, truncated to 60 chars}",
  "description": "{full issue details}",
  "task_type": "{task_type_from_file}",
  "priority": "{priority_from_severity}"
}
```

**Priority mapping:**
| Severity | Priority |
|----------|----------|
| Critical | critical |
| High | high |
| Medium | medium |
| Low | low |

**Description format:**
```markdown
Review issue from {scope} review on {DATE}:

**File**: `{file}:{line}`
**Severity**: {severity}
**Description**: {description}
**Impact**: {impact}
**Recommended Fix**: {recommended_fix}
```

#### 5.6.3. State Updates

**1. Read current state:**
```bash
next_num=$(jq -r '.next_project_number' specs/state.json)
```

**2. Create slug from title:**
```bash
# Lowercase, replace spaces/special chars with underscore, truncate to 40 chars
slug=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g' | cut -c1-40)
```

**3. Infer topic from file path and description:**

Use the file-path heuristic to assign topic before writing state.json:
- Issues from `.claude/` or `specs/` files → `"agent-system"`
- Issues from `Theories/Bimodal/Metalogic/` files → run keyword heuristic on issue title
- Issues from `.lean` files → run keyword heuristic against issue title and description

Keyword heuristic order (bilateral > agent-system > algebraic-representation > decidability > formula-refactor > frame-extensions > completeness).

**4. Add task to state.json:**
```bash
jq --arg num "$next_num" --arg slug "$slug" --arg title "$title" \
   --arg desc "$description" --arg tt "$task_type" --arg prio "$priority" \
   --arg topic "$inferred_topic" \
   '.active_projects += [{
     "project_number": ($num | tonumber),
     "project_name": $slug,
     "status": "not_started",
     "task_type": $tt,
     "topic": (if $topic != "" then $topic else null end),
     "priority": $prio,
     "description": $title,
     "created": (now | strftime("%Y-%m-%dT%H:%M:%SZ"))
   } | if .topic == null then del(.topic) else . end] |
   .next_project_number = (($num | tonumber) + 1)' \
   specs/state.json > specs/state.json.tmp && mv specs/state.json.tmp specs/state.json
```

**4. Update TODO.md:**
Add task entry following existing format in TODO.md frontmatter section.

**5. Track in review state:**
```bash
# Add task numbers to review entry
jq --argjson tasks "[${task_nums}]" \
   '.reviews[-1].tasks_created = $tasks' \
   specs/reviews/state.json > specs/reviews/state.json.tmp && \
   mv specs/reviews/state.json.tmp specs/reviews/state.json

# Update statistics
jq --argjson count "${task_count}" \
   '.statistics.total_tasks_created += $count' \
   specs/reviews/state.json > specs/reviews/state.json.tmp && \
   mv specs/reviews/state.json.tmp specs/reviews/state.json
```

#### 5.6.4. Duplicate Prevention

Before creating each task, check for existing similar tasks:

```bash
# Check state.json for tasks with similar names or file paths
existing=$(jq -r '.active_projects[] | select(.project_name | contains("'"$slug"'"))' specs/state.json)
if [ -n "$existing" ]; then
  # Skip creation, log as duplicate
  echo "Skipping duplicate: $title (similar to existing task)"
fi
```

### 6. Update Registries (if applicable)

If reviewing specific domains, update relevant registries:
- `.claude/docs/registries/lean-files.md`
- `.claude/docs/registries/documentation.md`

### 6.5. Regenerate Task Order

Regenerate the Task Order section in TODO.md using `generate-task-order.sh`. This replaces all manual pruning, insertion, and dependency chain management with a single script call.

**Skip condition**: If `task_order_state.exists == false` AND no tasks were created in Section 5.6, skip this section entirely.

**Run `generate-task-order.sh --update-todo`:**
```bash
# Regenerate Task Order from state.json (non-fatal)
if [ -f ".claude/scripts/generate-task-order.sh" ]; then
  bash ".claude/scripts/generate-task-order.sh" --update-todo specs/TODO.md specs/state.json \
    || { echo "Warning: Task Order regeneration failed (non-fatal)" >&2; }
else
  echo "Note: generate-task-order.sh not found -- skipping Task Order regeneration" >&2
fi
```

**What the script does**:
- Reads current task statuses from `specs/state.json`
- Builds wave assignment (topological sort by dependency level)
- Builds dependency tree entries with indentation
- Writes the complete `## Task Order` section in wave+tree format
- Preserves the goal statement if one exists in the current Task Order

**Track result**:
- `task_order_regenerated`: true if script ran successfully, false if skipped or failed

**Non-fatal**: If the script fails, log the warning and continue to Section 6.7. Task Order regeneration failure does not block the review workflow.

### 6.6. (Removed)

Task insertion into the Task Order is now handled automatically by Section 6.5 (`generate-task-order.sh --update-todo`). The script reads `specs/state.json` directly, so any tasks created in Section 5.6 are already included in the regenerated Task Order. No separate insertion step is needed.

### 6.7. Interactive Task Order Management

After Task Order regeneration (Section 6.5), optionally allow the user to update the goal statement.

#### 6.7.1. Skip Conditions

Skip this section entirely if ALL of the following are true:
- `task_order_state.exists == false` AND no tasks were created in Section 5.6
- `task_order_regenerated == false` (regeneration was skipped or failed)

```
if not task_order_state.exists and not task_order_regenerated:
  skip to Section 7
```

#### 6.7.2. Present Task Order Summary

Display a brief summary of Task Order changes made by Section 6.5:

```
Task Order: regenerated from state.json
- Tasks in order: {task_order_state.all_task_numbers.length}
- Waves: {task_order_state.waves.length}
- New tasks included: {tasks_created.length}
```

This gives the user context before the goal statement prompt.

#### 6.7.3. Goal Statement Update

**Condition**: Only present if Task Order regeneration ran (`task_order_regenerated == true`).

```json
{
  "question": "Update the Task Order goal statement?",
  "header": "Task Order Goal",
  "multiSelect": false,
  "options": [
    {
      "label": "Keep current",
      "description": "Goal: {task_order_state.goal}"
    },
    {
      "label": "Update goal",
      "description": "Enter a new goal statement for the Task Order"
    }
  ]
}
```

**Selection handling:**

**"Keep current"**: No changes to goal statement.

**"Update goal"**: Generate 3-4 suggested goal statements based on current task titles and review findings:

```json
{
  "question": "Select a new goal statement:",
  "header": "New Goal",
  "multiSelect": false,
  "options": [
    {
      "label": "{auto_generated_goal_1}",
      "description": "Based on highest-wave tasks"
    },
    {
      "label": "{auto_generated_goal_2}",
      "description": "Based on overall task distribution"
    },
    {
      "label": "{auto_generated_goal_3}",
      "description": "Based on recent review findings"
    },
    {
      "label": "Keep current",
      "description": "Goal: {task_order_state.goal}"
    }
  ]
}
```

Apply selected goal:
```
# Use Edit tool to replace goal line in TODO.md
old_string = "**Goal**: {old_goal}"
new_string = "**Goal**: {selected_goal}"
```

### 7. Git Commit

Commit review report, state files, task state, and any roadmap changes:

```bash
# Add review artifacts
git add specs/reviews/review-{DATE}.md specs/reviews/state.json

# Add roadmap if modified
if git diff --name-only | grep -q "specs/ROADMAP.md"; then
  git add specs/ROADMAP.md
fi

# Add task state if tasks were created
if git diff --name-only | grep -q "specs/state.json"; then
  git add specs/state.json specs/TODO.md
fi

# Add TODO.md if Task Order was pruned (even if no tasks were created)
if git diff --name-only | grep -q "specs/TODO.md"; then
  git add specs/TODO.md
fi

git commit -m "$(cat <<'EOF'
review: {scope} code review

Roadmap: {annotations_made} items annotated
Tasks: {tasks_created} created ({grouped_count} grouped, {individual_count} individual)
Task Order: {regenerated_or_skipped} (regenerated from state.json / skipped)

Session: {session_id}

EOF
)"
```

This ensures review report, state tracking, task state, and roadmap updates are committed together.

## Standards Reference

This command implements the multi-task creation pattern. See `.claude/docs/reference/standards/multi-task-creation-standard.md` for the complete standard.

**Compliance Level**: Partial (required components, limited optional)

| Component | Status | Notes |
|-----------|--------|-------|
| Discovery | Yes | Code analysis + roadmap items |
| Selection | Yes | Tier-1 group selection, Tier-2 granularity |
| Grouping | Yes | file_section + issue_type clustering |
| Dependencies | Partial | Declared in state.json; Task Order generated by script |
| Ordering | No | Sequential creation |
| Visualization | No | Not implemented |
| Confirmation | Yes | Implicit via selection |
| State Updates | Yes | Atomic updates (Section 5.6.3) |

**Note**: Task Order management uses `generate-task-order.sh --update-todo` (Section 6.5) for regeneration. Dependencies are derived from `state.json` and rendered automatically in the wave+tree format. Goal statement override is available via Section 6.7.3.

### 8. Output

Use condensed format with issue counts and task summaries:

```
Review complete for: {scope}

Report: specs/reviews/review-{DATE}.md

Issues found: {total}
- Critical: {N}, High: {N}, Medium: {N}, Low: {N}

{If tasks created:}
Tasks created: {N}
- Task #{N1}: {title} ({count} issues)
- Task #{N2}: {title}

{If no tasks created:}
No tasks created.

Next Steps:
1. Review report for details
2. Run /implement {N} to address issues
```

**Section Inclusion Rules:**

| Section | Show When |
|---------|-----------|
| Issues found | Always |
| Tasks created | tasks_created > 0 |
| No tasks created | tasks_created == 0 |
| Next Steps | Always |
