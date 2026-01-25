---
description: Review code and create analysis reports
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), TodoWrite, mcp__lean-lsp__*
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

### 2. Gather Context

**For Lean files (.lean):**
- Run `lean_diagnostic_messages` for each file
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

Cross-reference roadmap items with project state to identify completed work.

**Data Queries:**

**1. Query state.json for completed tasks with roadmap_items:**
```bash
# Get completed tasks with their completion data
jq '.active_projects[] | select(.status == "completed") | {
  project_number,
  project_name,
  roadmap_items: (.roadmap_items // []),
  completion_summary: (.completion_summary // "")
}' specs/state.json
```

**2. Query TODO.md for completed task references:**
```bash
# Find completed task numbers for cross-reference
grep -E '^\#\#\#.*\[COMPLETED\]' specs/TODO.md | grep -oE '^### [0-9]+'
```

**3. Count sorries in Lean files (for metrics):**
```bash
# Current sorry count for roadmap progress tracking
grep -r "sorry" Logos/ --include="*.lean" | wc -l
```

**Matching Strategy (Two-Tier Only):**

| Priority | Match Type | Confidence | Action |
|----------|------------|------------|--------|
| 1 | Explicit `roadmap_items` array match | High | Auto-annotate |
| 2 | Item contains `(Task {N})` reference | High | Auto-annotate |

**IMPORTANT**: No fuzzy title matching. Tasks without explicit `roadmap_items` OR existing `(Task N)`
references in ROAD_MAP.md will NOT be matched. This is intentional - agents must populate
`roadmap_items` during implementation.

**Matching Process:**

For each completed task in state.json:

1. **Check explicit roadmap_items** (Priority 1):
   - If task has `roadmap_items` array, look for exact text match in ROAD_MAP.md checkboxes
   - Example: `roadmap_items: ["Prove soundness for K modal logic"]` matches `- [ ] Prove soundness for K modal logic`

2. **Check exact task references** (Priority 2):
   - Scan ROAD_MAP.md for `(Task N)` where N is the task number
   - Example: `- [ ] Create proof guide (Task 628)` matches task 628

Build `roadmap_matches` list:
```json
[
  {
    "roadmap_item": "Prove soundness for K modal logic",
    "phase": 2,
    "match_type": "explicit_roadmap_items",
    "confidence": "high",
    "matched_task": 628,
    "completion_date": "2026-01-15"
  }
]
```

**Unmatched Tasks Warning:**

Track tasks that could not be matched to any roadmap item:
```json
{
  "unmatched_tasks": [
    {
      "task_number": 630,
      "task_name": "refactor_kripke_frames",
      "reason": "No roadmap_items specified, no (Task 630) reference in ROAD_MAP.md"
    }
  ],
  "warning": "3 completed tasks have no roadmap item match. Consider adding roadmap_items during implementation."
}
```

Include unmatched tasks in the review report under a dedicated warning section.

### 2.5.3. Annotate Completed Roadmap Items

For matched items (from Priority 1 or Priority 2 matching), update ROAD_MAP.md to mark items as complete.

**Annotation format** (per roadmap-format.md):
```markdown
- [x] {item text} *(Completed: Task {N}, {DATE})*
```

**Edit process for checkboxes:**

1. For each matched item:
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
  "skipped_reasons": ["already_annotated"],
  "match_types": {
    "explicit_roadmap_items": 2,
    "exact_task_ref": 1
  }
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

## Roadmap Progress

### Completed Since Last Review

*Matched via explicit roadmap_items:*
- [x] {item} *(Completed: Task {N}, {DATE})*

*Matched via (Task N) reference:*
- [x] {item} *(Completed: Task {N}, {DATE})*

### Unmatched Completed Tasks

> **Warning**: The following completed tasks have no roadmap item match.
> Consider adding `roadmap_items` during implementation for future tasks.

| Task | Name | Reason |
|------|------|--------|
| {N} | {task_name} | No roadmap_items, no (Task N) ref |

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

### 5. Create Tasks (if --create-tasks)

For each High/Critical issue, create a task:

```
/task "Fix: {issue title}"
```

Link tasks to review report.

**Update state:** Add created task numbers to the `tasks_created` array in the review entry:
```json
"tasks_created": [601, 602, 603]
```

Also increment `statistics.total_tasks_created` by the count of new tasks.

### 5.5. Roadmap Task Recommendations

Generate task recommendations from incomplete roadmap items.

**1. Identify current goals:**
For each phase, find first incomplete checkbox (`- [ ]`).

**2. Score items by priority:**

| Factor | Score |
|--------|-------|
| Phase priority: High | +6 |
| Phase priority: Medium | +4 |
| Phase priority: Low | +2 |
| First incomplete in phase | +2 |
| Listed in "Near Term" section | +3 |
| Contains actionable file path | +1 |

**3. Select top 5-7 recommendations:**
Sort by score, take top items.

**4. Infer language from content:**
- Contains `.lean` path: `lean`
- Contains `.md` path: `meta`
- Contains `.tex` path: `latex`
- Otherwise: `general`

**5. Present to user via prompt:**

```
Based on roadmap analysis, I recommend these tasks:

1. [ ] Audit proof dependencies (Phase 1, High Priority, Score: 11)
   Language: lean

2. [ ] Visualize import graph (Phase 1, High Priority, Score: 9)
   Language: general

3. [ ] Create proof architecture guide (Phase 1, High Priority, Score: 8)
   Language: meta

4. [ ] Define SetDerivable (Phase 2, Medium Priority, Score: 6)
   Language: lean

5. [ ] Analyze FMP bound complexity (Phase 3, Medium Priority, Score: 5)
   Language: lean

Which tasks should I create? Enter numbers (e.g., "1,3,5") or "all" or "none":
```

**6. Create selected tasks:**
For each selected item, invoke:
```
/task "{item text}" --language={inferred_language} --priority={phase_priority}
```

**7. Track created tasks:**
Add task numbers to `roadmap_tasks_created` in review state.

### 6. Update Registries (if applicable)

If reviewing specific domains, update relevant registries:
- `.claude/docs/registries/lean-files.md`
- `.claude/docs/registries/documentation.md`

### 7. Git Commit

Commit review report, state file, and any roadmap changes:

```bash
# Add review artifacts
git add specs/reviews/review-{DATE}.md specs/reviews/state.json

# Add roadmap if modified
if git diff --name-only | grep -q "specs/ROAD_MAP.md"; then
  git add specs/ROAD_MAP.md
fi

git commit -m "$(cat <<'EOF'
review: {scope} code review

Roadmap: {annotations_made} items annotated, {tasks_created} tasks created

Session: {session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

This ensures review report, state tracking, and roadmap updates are committed together.

### 8. Output

```
Review complete for: {scope}

Report: specs/reviews/review-{DATE}.md

Summary:
- Critical: {N} issues
- High: {N} issues
- Medium: {N} issues
- Low: {N} issues

Roadmap Progress:
- Annotations made: {N} items marked complete
  - Via explicit roadmap_items: {N}
  - Via (Task N) references: {N}
- Unmatched completed tasks: {N} (see report for details)
- Current focus: {phase_name} ({priority})
- Recommended tasks: {N}

{If unmatched tasks > 0}
**Warning**: {N} completed tasks could not be matched to roadmap items.
Agents should populate `roadmap_items` during implementation.

{If tasks created from issues}
Created {N} tasks for critical/high issues:
- Task #{N1}: {title}
- Task #{N2}: {title}

{If tasks created from roadmap}
Created {N} tasks from roadmap recommendations:
- Task #{N1}: {title}
- Task #{N2}: {title}

Top recommendations:
1. {recommendation}
2. {recommendation}
```
