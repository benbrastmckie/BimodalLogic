---
description: Review code and create analysis reports
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), TodoWrite, AskUserQuestion, mcp__lean-lsp__*
argument-hint: [SCOPE] [--create-tasks]
model: claude-opus-4-5-20251101
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

### 1.6. Load ROADMAP Context (Strategies and Ambitions)

**Purpose**: Load Strategies and Ambitions sections from ROAD_MAP.md to inform review focus areas. These sections provide strategic context about active experiments, priorities, and aspirational goals.

**Context**: Load @.claude/context/core/formats/roadmap-format.md for section schemas.

Parse `specs/ROAD_MAP.md` to extract Strategies and Ambitions sections:

#### 1.6.1. Parse Strategies Section

Extract strategies with their status and metadata:
```
# Look for "## Strategies" section header
# Parse each "### Strategy: {Name}" subsection

For each strategy:
  name = text after "### Strategy: "
  status = value after "**Status**:" (ACTIVE|PAUSED|CONCLUDED|ABANDONED)
  hypothesis = text after "**Hypothesis**:"
  started = date after "**Started**:"
  outcomes = list items under "**Outcomes**:"
```

Build `strategies_context` structure:
```json
{
  "strategies": [
    {
      "name": "Modal Soundness via FMP",
      "status": "ACTIVE",
      "started": "2026-01-15",
      "hypothesis": "Using Finite Model Property simplifies soundness proofs",
      "outcomes": ["Partial implementation in Theories/Bimodal/"],
      "focus_areas": ["Bimodal soundness", "finite model construction"]
    }
  ],
  "active_count": 1,
  "paused_count": 0
}
```

**Focus area extraction**: Extract key terms from hypothesis and outcomes to guide review attention to relevant files/modules.

#### 1.6.2. Parse Ambitions Section

Extract ambitions with their priority and success criteria:
```
# Look for "## Ambitions" section header
# Parse each "### Ambition: {Name}" subsection

For each ambition:
  name = text after "### Ambition: "
  priority = value after "**Priority**:" (HIGH|MEDIUM|LOW)
  timeframe = value after "**Timeframe**:" (SHORT-TERM|MEDIUM-TERM|LONG-TERM|ONGOING)
  criteria = checkbox items under "**Success Criteria**:"
  related_phases = numbers in "**Related Phases**:"
```

Build `ambitions_context` structure:
```json
{
  "ambitions": [
    {
      "name": "Complete Modal Logic Foundation",
      "priority": "HIGH",
      "timeframe": "MEDIUM-TERM",
      "criteria": [
        {"text": "Soundness theorem proven", "completed": true},
        {"text": "Completeness theorem proven", "completed": false}
      ],
      "criteria_progress": "1/2 complete",
      "related_phases": [1, 2]
    }
  ],
  "high_priority_count": 1,
  "incomplete_criteria_count": 1
}
```

#### 1.6.3. Build Combined Roadmap Context

Combine strategies and ambitions into unified context:
```json
{
  "roadmap_context": {
    "strategies": {...},
    "ambitions": {...},
    "review_focus": {
      "active_strategy_areas": ["Bimodal soundness", "finite model construction"],
      "high_priority_ambition_criteria": ["Completeness theorem proven"],
      "suggested_review_paths": ["Theories/Bimodal/", "Theories/Completeness/"]
    },
    "loaded_successfully": true
  }
}
```

#### 1.6.4. Fallback Behavior

If Strategies or Ambitions sections don't exist or are empty placeholders:

```bash
# Check if sections exist and contain actual content (not placeholder text)
if sections_missing_or_placeholder; then
  echo "INFO: Strategies/Ambitions sections not yet populated in ROAD_MAP.md"
  echo "INFO: Review will proceed without strategic context"
  echo "INFO: Run /todo or manually populate sections after Task 833"

  roadmap_context = {
    "strategies": {"strategies": [], "active_count": 0, "paused_count": 0},
    "ambitions": {"ambitions": [], "high_priority_count": 0, "incomplete_criteria_count": 0},
    "review_focus": {
      "active_strategy_areas": [],
      "high_priority_ambition_criteria": [],
      "suggested_review_paths": []
    },
    "loaded_successfully": false,
    "fallback_reason": "sections_not_populated"
  }
fi
```

**Detection of placeholder sections**: Look for text like "populated in Phase" or "*No entries yet*" to identify unpopulated sections.

Variables set for later sections:
- `roadmap_context` - Full context object for use in Section 2 (focus review) and Section 4 (report)
- `review_focus_paths` - List of suggested file paths to prioritize in review
- `active_strategies` - List of ACTIVE strategy names for quick reference

### 2. Gather Context

**For Lean files (.lean):**
- Run `lake build` to check for errors
- Check for `sorry`, axioms, admitted proofs
- Identify incomplete theorems
- Check import organization

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

**Context**: Load @.claude/context/core/formats/roadmap-format.md for parsing patterns.

Parse `specs/ROAD_MAP.md` to extract:
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
      "location": "Soundness/Soundness.lean"
    }
  ]
}
```

**Error handling**: If ROAD_MAP.md doesn't exist or fails to parse, log warning and continue review without roadmap integration.

### 2.5.2. Cross-Reference Roadmap with Project State

**Context**: Load @.claude/context/core/patterns/roadmap-update.md for matching strategy.

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

**4. Count sorries in Lean files:**
```bash
# Current sorry count for metrics (exclude Boneyard/ and Examples/)
grep -r "sorry" Theories/ --include="*.lean" | grep -v "/Boneyard/" | grep -v "/Examples/" | wc -l
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

For high-confidence matches, update ROAD_MAP.md to mark items as complete.

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
| Sorry count | {N} | {OK/Warning/Critical} |
| Axiom count | {N} | {OK/Warning} |
| TODO count | {N} | {Info} |
| Build status | {Pass/Fail} | {Status} |

## Roadmap Context

{If roadmap_context.loaded_successfully is true, include these subsections:}

### Active Strategies

| Strategy | Status | Hypothesis | Focus Areas |
|----------|--------|------------|-------------|
| {strategy.name} | {strategy.status} | {strategy.hypothesis} | {strategy.focus_areas} |

{If no active strategies:}
*No active strategies defined in ROAD_MAP.md*

### Ambition Progress

| Ambition | Priority | Timeframe | Progress |
|----------|----------|-----------|----------|
| {ambition.name} | {ambition.priority} | {ambition.timeframe} | {ambition.criteria_progress} |

**Outstanding Criteria** (high-priority ambitions):
- [ ] {criterion.text} (from "{ambition.name}")

{If no ambitions:}
*No ambitions defined in ROAD_MAP.md*

{If roadmap_context.loaded_successfully is false:}
*Strategies and Ambitions sections not yet populated in ROAD_MAP.md. Run Task 833 or manually add content to enable strategic context.*

---

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

---

## Roadmap Revisions

{Document changes made to ROAD_MAP.md during this review}

### Strategy Updates

{If strategies_updated > 0:}
| Strategy | Previous Status | New Status | Reason |
|----------|-----------------|------------|--------|
| {strategy.name} | {old_status} | {new_status} | {reason_based_on_findings} |

{If no strategy updates:}
*No strategy status changes identified during this review.*

### Proposed Ambitions

{If ambitions_proposed > 0:}
The following ambitions are proposed based on review findings. User approval required before adding to ROAD_MAP.md.

| Proposed Ambition | Priority | Rationale |
|-------------------|----------|-----------|
| {ambition_name} | {priority} | {based_on_finding} |

{If no ambitions proposed:}
*No new ambitions proposed during this review.*

### Gap Notes

{If gaps identified in Open Questions or architectural concerns:}
The following concerns have been noted in the ROAD_MAP.md Open Questions section:
- {gap_description} (added to Open Questions)

{If no gaps:}
*No architectural gaps identified for Open Questions.*

---

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
  /task "Fix: {issue title}" --language={inferred_language} --priority={severity}
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
  "file_path": "Theories/Bimodal/Soundness.lean",
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
| `file_section` | Path prefix up to first-level directory (e.g., `Theories/Bimodal/` from `Theories/Bimodal/Soundness.lean:42`) |
| `issue_type` | Map severity: Critical/High -> "fix", Medium -> "quality", Low -> "improvement". For roadmap: "roadmap" |
| `priority` | Direct from severity (Critical=4, High=3, Medium=2, Low=1) or phase priority |
| `key_terms` | Extract significant words (>4 chars, not stopwords) from description |

**Example extracted indicators:**
```json
{
  "file_section": "Theories/Bimodal/",
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
  "language": "{majority_language}",
  "priority": "{max_priority_in_group}"
}
```

**Language inference by majority file type in group:**
| File pattern | Language |
|--------------|----------|
| `*.lean` | lean |
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
  "language": "{language_from_file}",
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

**3. Add task to state.json:**
```bash
jq --arg num "$next_num" --arg slug "$slug" --arg title "$title" \
   --arg desc "$description" --arg lang "$language" --arg prio "$priority" \
   '.active_projects += [{
     "project_number": ($num | tonumber),
     "project_name": $slug,
     "status": "not_started",
     "language": $lang,
     "priority": $prio,
     "description": $title,
     "created": (now | strftime("%Y-%m-%dT%H:%M:%SZ"))
   }] | .next_project_number = (($num | tonumber) + 1)' \
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

### 6.5. Revise ROADMAP.md Based on Findings

**Purpose**: Update ROAD_MAP.md to reflect review findings. This includes updating strategy statuses, proposing new ambitions, and noting architectural gaps.

**Precondition**: `roadmap_context` from Section 1.6 must exist. If `roadmap_context.loaded_successfully` is false, skip this section entirely.

#### 6.5.1. Strategy Status Updates

Analyze review findings against active strategies to determine if status changes are warranted:

**Status change criteria:**

| Current Status | Condition for Change | New Status |
|----------------|---------------------|------------|
| ACTIVE | All focus area files pass, no related issues found | CONCLUDED |
| ACTIVE | Major blockers identified in focus areas | PAUSED |
| PAUSED | Blocking issues resolved | ACTIVE |

**For each ACTIVE strategy:**
```
1. Check if review findings relate to strategy.focus_areas
2. Assess overall health of focus area files:
   - No critical/high issues → healthy
   - Has critical/high issues → blocked
3. If strategy objectives appear met (based on findings), propose CONCLUDED
4. If new blockers found, propose PAUSED

strategy_update = {
  "name": strategy.name,
  "current_status": "ACTIVE",
  "proposed_status": "PAUSED",
  "reason": "Critical issue found in {focus_area}: {issue_description}"
}
```

**Edit process for status changes:**

1. Use AskUserQuestion to confirm each status change:
   ```json
   {
     "question": "Update strategy '{name}' from {current} to {proposed}?",
     "header": "Strategy Status Update",
     "multiSelect": false,
     "options": [
       {"label": "Yes, update status", "description": "Reason: {reason}"},
       {"label": "No, keep current status", "description": "No change to ROAD_MAP.md"}
     ]
   }
   ```

2. If approved, use Edit tool:
   ```
   old_string: "**Status**: ACTIVE"
   new_string: "**Status**: PAUSED"
   ```

3. Add outcome entry under strategy:
   ```
   old_string: "**Outcomes**:\n- {existing_outcome}"
   new_string: "**Outcomes**:\n- {existing_outcome}\n- [{DATE}] Status changed to PAUSED: {reason}"
   ```

**Track changes:**
```json
{
  "strategies_updated": 1,
  "strategy_changes": [
    {"name": "Modal Soundness via FMP", "from": "ACTIVE", "to": "PAUSED", "reason": "..."}
  ]
}
```

#### 6.5.2. Propose New Ambitions

Identify gaps from review findings that warrant new ambitions:

**Gap identification criteria:**
- Pattern of issues across multiple files suggesting systemic problem
- Missing functionality referenced multiple times
- Quality debt (sorry count, axiom usage) above thresholds
- Incomplete areas not covered by existing ambitions

**For each significant gap:**
```
gap = {
  "description": "Improved test coverage for modal logic theorems",
  "evidence": ["5 untested theorems found in Bimodal/", "3 sorry placeholders"],
  "priority": "MEDIUM" (based on severity distribution),
  "timeframe": "SHORT-TERM" (based on effort estimate)
}
```

**Ambition proposal process:**

1. Formulate proposed ambition:
   ```markdown
   ### Ambition: {gap.description}
   **Priority**: {gap.priority}
   **Timeframe**: {gap.timeframe}

   *Rationale*: Identified during review on {DATE}. Evidence: {gap.evidence}

   **Success Criteria**:
   - [ ] {derived from gap findings}

   **Description**:
   {Detailed description based on gap analysis}

   **Related Phases**: {inferred from file locations}
   **References**:
   - [Review Report](specs/reviews/review-{DATE}.md) - Gap identification
   ```

2. Present via AskUserQuestion:
   ```json
   {
     "question": "Add new ambition to ROAD_MAP.md?",
     "header": "Proposed Ambition: {gap.description}",
     "multiSelect": false,
     "options": [
       {"label": "Yes, add ambition", "description": "Priority: {priority}, Timeframe: {timeframe}"},
       {"label": "No, skip this ambition", "description": "Will be noted in review report only"},
       {"label": "Defer to later", "description": "Will be marked as suggestion in review report"}
     ]
   }
   ```

3. If approved, use Edit tool to append to Ambitions section:
   ```
   old_string: "*Ambitions section populated in Phase 3.*"
   new_string: "### Ambition: {name}\n...\n\n---"
   ```
   OR if section has content:
   ```
   old_string: "---\n\n## Dead Ends"
   new_string: "---\n\n### Ambition: {name}\n...\n\n---\n\n## Dead Ends"
   ```

**Track changes:**
```json
{
  "ambitions_proposed": 2,
  "ambitions_approved": 1,
  "ambitions_deferred": 1,
  "proposed_ambitions": [
    {"name": "Improved test coverage", "status": "approved"},
    {"name": "Documentation refresh", "status": "deferred"}
  ]
}
```

#### 6.5.3. Update Active Tasks Section

If new tasks were created (from Section 5.6), sync them to any relevant roadmap sections:

**Link newly created tasks to roadmap items:**
```
For each created task:
  If task relates to a roadmap phase item:
    Update checkbox annotation: "- [ ] {item} (Task {N})"
```

**Update phase progress counts** if checkboxes were modified.

#### 6.5.4. Add Gap Notes to Open Questions

For gaps that don't warrant full ambitions but need tracking:

**Gap note criteria:**
- Architectural concerns requiring discussion
- Unclear requirements needing clarification
- Technical debt observations

**Edit process:**
1. Find "## Open Questions" section in ROAD_MAP.md
2. Append gap note:
   ```
   old_string: "## Open Questions\n\n{existing_content}"
   new_string: "## Open Questions\n\n- [{DATE}] {gap_description} (from review)\n{existing_content}"
   ```

**Track changes:**
```json
{
  "gap_notes_added": 1,
  "gap_notes": ["Unclear ownership of PropositionalLogic vs Bimodal boundary"]
}
```

#### 6.5.5. Summary Variables for Report

After all revision operations, build summary for Section 4 report:
```json
{
  "roadmap_revisions": {
    "strategies_updated": 1,
    "ambitions_proposed": 2,
    "ambitions_approved": 1,
    "gap_notes_added": 1,
    "roadmap_modified": true
  }
}
```

### 7. Git Commit

Commit review report, state files, task state, and any roadmap changes:

```bash
# Add review artifacts
git add specs/reviews/review-{DATE}.md specs/reviews/state.json

# Add roadmap if modified
if git diff --name-only | grep -q "specs/ROAD_MAP.md"; then
  git add specs/ROAD_MAP.md
fi

# Add task state if tasks were created
if git diff --name-only | grep -q "specs/state.json"; then
  git add specs/state.json specs/TODO.md
fi

git commit -m "$(cat <<'EOF'
review: {scope} code review

Roadmap: {annotations_made} items annotated
Strategies: {strategies_updated} updated
Ambitions: {ambitions_approved} added ({ambitions_proposed} proposed)
Tasks: {tasks_created} created ({grouped_count} grouped, {individual_count} individual)

Session: {session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

This ensures review report, state tracking, task state, roadmap updates, and strategy/ambition changes are committed together.

### 8. Output

```
Review complete for: {scope}

Report: specs/reviews/review-{DATE}.md

Summary:
- Critical: {N} issues
- High: {N} issues
- Medium: {N} issues
- Low: {N} issues

Issue Groups Identified:
- {N} groups formed from {M} total issues
- Groups: {group_labels}

Roadmap Progress:
- Annotations made: {N} items marked complete
- Current focus: {phase_name} ({priority})

{If roadmap_context.loaded_successfully:}
Roadmap Revisions:
- Strategies updated: {strategies_updated}
  {For each strategy change:}
  - {strategy.name}: {from} -> {to} ({reason})
- Ambitions: {ambitions_approved} added, {ambitions_proposed - ambitions_approved} deferred
  {For each approved ambition:}
  - Added: "{ambition.name}" ({priority})
- Gap notes: {gap_notes_added} added to Open Questions

{If not roadmap_context.loaded_successfully:}
Roadmap Context: Strategies/Ambitions sections not populated (see Task 833)

{If tasks created via interactive selection}
Tasks Created: {N} total
- Grouped tasks: {grouped_count}
  - Task #{N1}: {group_label} ({item_count} issues)
- Individual tasks: {individual_count}
  - Task #{N2}: {title}
  - Task #{N3}: {title}

{If tasks created via --create-tasks flag}
Auto-created {N} tasks for critical/high issues:
- Task #{N1}: {title}
- Task #{N2}: {title}

{If no tasks created}
No tasks created (user selected "none" or empty selection).

---

Task Suggestions: {task_suggestions.suggestions_shown} recommended next steps
- By source: {review_issue}x review issues, {roadmap_ambition}x ambition criteria, {stale_task}x stale tasks
{If roadmap_context.loaded_successfully and strategic_focus:}
- Strategic focus: {strategic_focus}

Top suggestions (see Section 8.5 output for full list):
1. [{priority}] {title} - `{suggested_command}`
2. [{priority}] {title} - `{suggested_command}`
3. [{priority}] {title} - `{suggested_command}`

---

Top recommendations for next review:
1. {recommendation}
2. {recommendation}
```

### 8.5. Task Suggestions

**Purpose**: Provide actionable task suggestions based on review findings, roadmap context, and task queue state. This follows the patterns established by /todo and /learn commands.

#### 8.5.1. Collect Suggestion Sources

Gather candidates from multiple sources:

**1. Unaddressed Review Issues (not converted to tasks):**
```json
{
  "source": "review_issue",
  "title": "{issue_description}",
  "priority": "{severity_to_priority}",
  "rationale": "Found during {scope} review: {impact}",
  "suggested_command": "/task \"{title}\" --language={lang}"
}
```

**2. Incomplete Roadmap Items from Strategies/Ambitions:**
```json
{
  "source": "roadmap_ambition",
  "title": "Complete: {criterion_text}",
  "priority": "{ambition.priority}",
  "rationale": "From ambition '{ambition.name}' - {criteria_progress}",
  "suggested_command": "/task \"Complete: {criterion}\" --language=lean"
}
```

```json
{
  "source": "roadmap_strategy",
  "title": "Advance: {strategy.name}",
  "priority": "high" (if ACTIVE),
  "rationale": "Active strategy with focus on {focus_areas}",
  "suggested_command": "/research {related_task} \"focus on {focus_area}\""
}
```

**3. Stale Tasks in TODO.md:**
```bash
# Find tasks in not_started status older than 7 days
jq '.active_projects[] | select(.status == "not_started") | select(.created < "{7_days_ago}")' specs/state.json
```

```json
{
  "source": "stale_task",
  "title": "Resume: Task #{N} - {title}",
  "priority": "medium",
  "rationale": "Not started for {days} days",
  "suggested_command": "/research {N}"
}
```

**4. Follow-up Opportunities from Completed Work:**
```json
{
  "source": "followup",
  "title": "{follow_up_description}",
  "priority": "low",
  "rationale": "Opportunity identified from completed task #{N}",
  "suggested_command": "/task \"{title}\""
}
```

#### 8.5.2. Prioritize Suggestions

Apply prioritization scoring:

| Factor | Score |
|--------|-------|
| Source is review_issue with Critical severity | +10 |
| Source is review_issue with High severity | +7 |
| Source is roadmap_ambition with HIGH priority | +6 |
| Source is roadmap_strategy (ACTIVE) | +5 |
| Source is stale_task (>14 days) | +4 |
| Source is stale_task (7-14 days) | +2 |
| Source is followup | +1 |
| Related to active strategy focus area | +3 |
| Addresses high-priority ambition criterion | +3 |

Sort suggestions by score descending.

#### 8.5.3. Limit and Format Output

**Limit to 3-5 suggestions** to keep output focused and actionable:
- If <5 high-priority items: Include all high-priority + top medium
- If >5 high-priority items: Include only top 5 by score

**Format pattern (following /todo):**
```
---

## Recommended Next Steps

Based on review findings and roadmap context, consider:

1. **[{priority}]** {title}
   - *Rationale*: {rationale}
   - *Command*: `{suggested_command}`

2. **[{priority}]** {title}
   - *Rationale*: {rationale}
   - *Command*: `{suggested_command}`

3. **[{priority}]** {title}
   - *Rationale*: {rationale}
   - *Command*: `{suggested_command}`

{If roadmap_context.loaded_successfully:}
**Strategic Focus**: Active strategies suggest prioritizing work in: {focus_areas}

{If stale tasks found:}
**Stale Tasks**: {N} tasks have been not_started for >7 days. Consider `/research` or `/abandon` for each.
```

#### 8.5.4. Variables for Final Output

Set variables for Section 8 output integration:
```json
{
  "task_suggestions": {
    "total_candidates": 12,
    "suggestions_shown": 5,
    "by_source": {
      "review_issue": 3,
      "roadmap_ambition": 1,
      "stale_task": 1
    },
    "strategic_focus": ["Bimodal soundness", "finite model construction"]
  }
}
```
