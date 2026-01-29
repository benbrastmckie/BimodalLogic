# Implementation Plan: Task #751

- **Task**: 751 - enhance_review_with_grouped_interactive_task_proposals
- **Status**: [COMPLETED]
- **Effort**: 3-4 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/751_enhance_review_with_grouped_interactive_task_proposals/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Modify the /review command to always conclude with an interactive task proposal experience featuring intelligent task grouping. The current implementation uses a flat numbered list that only appears when `--create-tasks` is specified. This plan implements a 3-phase approach: (1) adapt the clustering algorithm from /learn to group review issues by file/component and issue type, (2) integrate AskUserQuestion for interactive group selection with multiSelect support, and (3) wire selected tasks to the task creation system with proper state management.

### Research Integration

The research report identified:
- Current Section 5.5 (lines 325-384) generates flat task recommendations from roadmap items
- The /learn skill has a proven topic grouping algorithm in SKILL.md (lines 228-352)
- AskUserQuestion supports multiSelect for checkbox-style selection
- Grouping criteria: file_section + issue_type (primary), key_terms + priority (secondary)
- Estimated net +160 lines of code changes

## Goals & Non-Goals

**Goals**:
- Always display task proposals after review (remove `--create-tasks` requirement)
- Group related issues by file/component area and issue type
- Provide interactive selection via AskUserQuestion with multiSelect
- Support three granularity options: grouped, expanded, manual
- Create tasks with proper dependency linking and state management

**Non-Goals**:
- Cross-group dependency inference (defer to future task)
- Custom grouping criteria configuration
- Persisting grouping preferences between reviews
- AI-powered semantic grouping (use deterministic algorithm only)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Too many groups defeats grouping purpose | Medium | Medium | Cap at 7-10 groups, combine small groups (<2 items) |
| AskUserQuestion option limit | Low | Low | Use pagination or "Show more" pattern if >15 groups |
| Grouping algorithm too simple | Medium | Low | Start simple, iterate based on user feedback |
| Breaking existing --create-tasks flag users | Medium | Low | Keep flag functional (creates all high/critical without prompt) |

## Implementation Phases

### Phase 1: Task Grouping Logic [COMPLETED]

**Goal**: Implement clustering algorithm adapted from /learn to group review issues by file/component and issue type.

**Tasks**:
- [ ] Define grouping data structure in Section 5.5
  - `file_section`: Path prefix up to first-level directory (e.g., `Theories/Bimodal/`)
  - `issue_type`: Map severity to type - Critical/High -> "fix", Medium -> "quality", Low -> "improvement"
  - `priority`: Direct from severity
  - `key_terms`: Extract significant words from description
- [ ] Implement clustering algorithm
  - Check existing groups for match: same file_section AND same issue_type -> add to group
  - Secondary match: 2+ shared key_terms AND same priority -> add to group
  - Otherwise: create new group
- [ ] Generate group labels
  - Format: "{file_section} {issue_type}" or "{key_terms} issues"
  - Examples: "Bimodal fixes", "Documentation improvements", "Proof quality issues"
- [ ] Add group size limits (combine groups with <2 items, cap at 10 groups)

**Timing**: 1-1.5 hours

**Files to modify**:
- `.claude/commands/review.md` - Add grouping algorithm to Section 5.5 (lines 325-384)

**Verification**:
- Grouping algorithm produces reasonable groups for sample review data
- Group labels are descriptive and concise
- Small groups are properly combined

---

### Phase 2: Interactive Selection Interface [COMPLETED]

**Goal**: Modify Section 5.5 to always display grouped task proposals with AskUserQuestion multiSelect support.

**Tasks**:
- [ ] Add AskUserQuestion to allowed-tools in frontmatter (line 3)
- [ ] Remove `--create-tasks` conditional from Section 5 (lines 308-323)
  - Keep flag functional but change behavior: if present, auto-create high/critical without prompt
- [ ] Rewrite Section 5.5 to always show grouped proposals
- [ ] Implement Tier 1: Group selection via AskUserQuestion
  ```json
  {
    "question": "Which task groups should be created?",
    "header": "Review Task Proposals",
    "multiSelect": true,
    "options": [
      {"label": "[Group] {group_label} ({count} issues)", "description": "{severity_breakdown} | Files: {file_list}"},
      {"label": "[Individual] {issue_title}", "description": "{severity} | {file}:{line}"}
    ]
  }
  ```
- [ ] Implement Tier 2: Granularity selection
  ```json
  {
    "question": "How should selected groups be created as tasks?",
    "header": "Task Granularity",
    "multiSelect": false,
    "options": [
      {"label": "Keep as grouped tasks", "description": "Creates {N} tasks (one per group)"},
      {"label": "Expand into individual tasks", "description": "Creates {M} tasks (one per issue)"},
      {"label": "Show issues and select manually", "description": "See all issues in selected groups"}
    ]
  }
  ```
- [ ] Handle "Show issues and select manually" with nested AskUserQuestion

**Timing**: 1-1.5 hours

**Files to modify**:
- `.claude/commands/review.md` - Lines 1-6 (frontmatter), 308-384 (Sections 5 and 5.5)

**Verification**:
- AskUserQuestion prompts display correctly with group descriptions
- MultiSelect allows choosing multiple groups
- Granularity options work for all three choices
- Manual selection shows individual issues from selected groups

---

### Phase 3: Task Creation Integration [COMPLETED]

**Goal**: Wire selected tasks to actual creation with proper state.json/TODO.md updates and dependency linking.

**Tasks**:
- [ ] Add new Section 5.6: Task Creation from Selection
- [ ] Implement grouped task creation
  - Title: "{group_label}: {issue_count} issues"
  - Description: List all issues with file:line references
  - Language: Detect from majority file type in group
  - Priority: Highest priority in group
- [ ] Implement individual task creation
  - Title: "{issue description, truncated to 60 chars}"
  - Description: Full issue details with file:line
  - Language: From file extension (.lean -> lean, .md -> meta, etc.)
  - Priority: From severity mapping
- [ ] Update state.json and TODO.md via standard task creation pattern
  - Read next_project_number
  - Create slug from title
  - Add to active_projects array
  - Update TODO.md frontmatter
- [ ] Track created tasks in review state
  - Add to `tasks_created` array in review entry
  - Increment `statistics.total_tasks_created`
- [ ] Update Section 6 to include task creation tracking in registries

**Timing**: 1 hour

**Files to modify**:
- `.claude/commands/review.md` - Add Section 5.6 after current Section 5.5, update Section 6

**Verification**:
- Tasks created correctly in state.json and TODO.md
- Language inference works for all file types
- Priority mapping is correct
- Review state tracks created tasks
- No duplicate tasks created on re-review

---

## Testing & Validation

- [ ] Run /review on a scope with mixed issue types and verify grouping
- [ ] Verify AskUserQuestion prompts display group descriptions correctly
- [ ] Test "Keep as grouped tasks" creates single task per group
- [ ] Test "Expand into individual tasks" creates one task per issue
- [ ] Test "Show issues and select manually" allows individual selection
- [ ] Verify --create-tasks flag still works (auto-creates high/critical)
- [ ] Verify state.json and TODO.md stay synchronized
- [ ] Verify review state tracks created tasks

## Artifacts & Outputs

- `.claude/commands/review.md` - Updated command file (~160 net lines added)
- `specs/751_enhance_review_with_grouped_interactive_task_proposals/plans/implementation-001.md` - This plan
- `specs/751_enhance_review_with_grouped_interactive_task_proposals/summaries/implementation-summary-YYYYMMDD.md` - Post-implementation summary

## Rollback/Contingency

If implementation causes issues:
1. Revert review.md to previous version via git checkout
2. The changes are isolated to a single command file
3. No schema changes to state.json or TODO.md formats
4. Flag behavior preserved as fallback for existing workflows
