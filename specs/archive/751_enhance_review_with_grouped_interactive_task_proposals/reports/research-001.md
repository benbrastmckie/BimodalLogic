# Research Report: Task #751

**Task**: 751 - enhance_review_with_grouped_interactive_task_proposals
**Started**: 2026-01-29T12:00:00Z
**Completed**: 2026-01-29T12:15:00Z
**Effort**: 1-2 hours (research phase)
**Priority**: Medium
**Dependencies**: None
**Sources/Inputs**: Codebase analysis, .claude/commands/review.md, .claude/commands/learn.md, .claude/commands/todo.md, .claude/skills/skill-learn/SKILL.md
**Artifacts**: This report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Current /review Section 5.5 uses a flat numbered list for task recommendations and only creates tasks when `--create-tasks` flag is present
- The `/learn` command already has comprehensive interactive task grouping via AskUserQuestion with multiSelect support
- Implementation requires: (1) adapting /learn's topic grouping algorithm, (2) modifying Section 5.5 to always display interactive selection, (3) removing `--create-tasks` flag requirement for task proposals
- Key grouping criteria identified: file/component area, issue type (fix vs feature vs documentation), and priority level

## Context & Scope

### What Was Researched

This research analyzed the current `/review` command implementation to understand:
1. How task proposals are currently structured and presented
2. The `--create-tasks` flag behavior and its role
3. Existing interactive selection patterns in the codebase
4. Grouping/clustering algorithms already implemented

### Constraints

- Must integrate with existing AskUserQuestion tool patterns
- Must maintain consistency with /learn command's interactive paradigm
- Should reuse existing grouping logic where applicable

## Findings

### 1. Current /review Implementation Structure

**File**: `.claude/commands/review.md` (449 lines)

**Relevant Sections**:
- **Section 5 (lines 308-323)**: "Create Tasks (if --create-tasks)" - Only triggers when flag is present
- **Section 5.5 (lines 325-384)**: "Roadmap Task Recommendations" - Generates task recommendations from incomplete roadmap items

**Current Task Proposal Flow** (Section 5.5):
1. Identifies incomplete roadmap items by finding first `- [ ]` checkbox per phase
2. Scores items by priority factors:
   - Phase priority (High=+6, Medium=+4, Low=+2)
   - First incomplete in phase (+2)
   - Listed in "Near Term" section (+3)
   - Contains actionable file path (+1)
3. Selects top 5-7 recommendations
4. Infers language from content patterns
5. Presents flat numbered list (lines 355-373):
```
Based on roadmap analysis, I recommend these tasks:

1. [ ] Audit proof dependencies (Phase 1, High Priority, Score: 11)
   Language: lean

2. [ ] Visualize import graph (Phase 1, High Priority, Score: 9)
   Language: general
...

Which tasks should I create? Enter numbers (e.g., "1,3,5") or "all" or "none":
```

**Current Problems**:
- Only shows recommendations when `--create-tasks` flag is used
- No grouping by file/component, type, or priority
- Manual text parsing for user selection ("1,3,5")
- Does not use AskUserQuestion tool

### 2. Existing Interactive Selection Patterns

**Best Example**: `/learn` command (`.claude/commands/learn.md` and `.claude/skills/skill-learn/SKILL.md`)

The /learn command has a sophisticated 3-tier interactive selection:

**Tier 1: Task Type Selection** (lines 146-169 of SKILL.md)
```json
{
  "question": "Which task types should be created?",
  "header": "Task Types",
  "multiSelect": true,
  "options": [
    {"label": "fix-it task", "description": "Combine {N} FIX:/NOTE: tags into single task"},
    {"label": "learn-it task", "description": "Update context from {N} NOTE: tags"},
    {"label": "TODO tasks", "description": "Create tasks for {N} TODO: items"}
  ]
}
```

**Tier 2: Individual Item Selection** (lines 186-226 of SKILL.md)
```json
{
  "question": "Select TODO items to create as tasks:",
  "header": "TODO Selection",
  "multiSelect": true,
  "options": [
    {"label": "{content truncated to 50 chars}", "description": "{file}:{line}"},
    ...
  ]
}
```

**Tier 3: Topic Grouping** (lines 325-345 of SKILL.md)
```json
{
  "question": "How should TODO items be grouped into tasks?",
  "header": "TODO Topic Grouping",
  "multiSelect": false,
  "options": [
    {"label": "Accept suggested topic groups", "description": "Creates {N} grouped tasks: {group_summaries}"},
    {"label": "Keep as separate tasks", "description": "Creates {M} individual tasks"},
    {"label": "Create single combined task", "description": "Creates 1 task containing all items"}
  ]
}
```

**Other AskUserQuestion Examples**:
- `/todo` command (lines 425-462): Orphan directory handling with single-select
- `/lake` command (lines 243-262): Confirmation for task creation
- `/refresh` command: Age threshold selection

### 3. Grouping Algorithm from /learn

**Location**: `.claude/skills/skill-learn/SKILL.md`, Step 7.5 (lines 228-352)

**Topic Detection Uses** (per documentation):
1. **Shared key terms**: 2+ significant terms in common
2. **File section proximity**: Same directory path prefix
3. **Action type similarity**: implement, fix, document, test, refactor

**Clustering Algorithm** (lines 267-288):
```
1. Start with first item as initial group
2. For each remaining item:
   - If shares 2+ key terms with existing group -> add to group
   - If shares file_section AND action_type with existing group -> add to group
   - Otherwise -> start new group
3. Generate topic label from most common shared terms in group
```

**Example Clustering Output**:
```
Group 1: "S5 Theorems" (shared: S5, theorem, Logos/Layer1/, implementation)
  - Add completeness theorem for S5
  - Add soundness theorem for S5

Group 2: "Utility Optimization" (shared: Logos/Shared/, improvement)
  - Optimize helper function
```

### 4. Task Creation Flow

**Current Task Creation** (from `/task` command, `task.md` lines 44-107):
1. Read `next_project_number` from `specs/state.json`
2. Create slug from description
3. Update `state.json` via jq
4. Update `TODO.md` frontmatter and add entry
5. Git commit

**Linking Pattern** (from `/learn` dependency handling, lines 356-411):
- `dependencies` array field in state.json entry
- `**Dependencies**: {task_num}` line in TODO.md entry

### 5. Data Structures for Review Issues

Current /review categorizes issues by severity (lines 200-246):
- **Critical**: Broken functionality, security vulnerabilities
- **High**: Missing features, significant bugs
- **Medium**: Code quality issues, incomplete implementations
- **Low**: Style issues, minor improvements

Each issue contains (lines 227-234):
- File path with line number
- Description
- Impact
- Recommended fix

**Note**: These map naturally to grouping criteria:
- **By file/component**: Group by file path prefix (e.g., `Theories/Bimodal/`, `docs/`)
- **By fix type**: Critical/High = "fix tasks", Medium = "quality tasks", Low = "improvement tasks"
- **By priority**: Already categorized

## Recommendations

### Implementation Approach

**Phase 1: Task Grouping Logic**

Adapt `/learn`'s clustering algorithm for review issues:

1. **Extract grouping indicators for each issue**:
   - `file_section`: Path prefix up to first-level directory (e.g., `Theories/Bimodal/`)
   - `issue_type`: Map severity to type - Critical/High -> "fix", Medium -> "quality", Low -> "improvement"
   - `priority`: Direct from severity
   - `key_terms`: Extract significant words from description

2. **Implement clustering**:
```
for each issue:
  - Check existing groups for match:
    a) Same file_section AND same issue_type -> add to group
    b) 2+ shared key_terms AND same priority -> add to group
  - If no match -> create new group
```

3. **Generate group labels**:
   - Format: "{file_section} {issue_type}" or "{key_terms} issues"
   - Examples: "Bimodal fixes", "Documentation improvements", "Proof quality issues"

**Phase 2: Interactive Selection Interface**

Modify Section 5.5 to always display grouped task proposals:

1. **Remove `--create-tasks` conditional** - Always show proposals after review
2. **Add group-level checkboxes** using AskUserQuestion:
```json
{
  "question": "Which task groups should be created?",
  "header": "Review Task Proposals",
  "multiSelect": true,
  "options": [
    {
      "label": "[Group] Bimodal/Metalogic fixes (3 issues)",
      "description": "Critical: 1, High: 2 | Files: Correctness.lean, Soundness.lean"
    },
    {
      "label": "[Group] Documentation improvements (2 issues)",
      "description": "Low: 2 | Files: README.md, guide.tex"
    },
    {
      "label": "[Individual] Fix Kripke frame validation",
      "description": "High | Theories/Bimodal/Kripke.lean:45"
    }
  ]
}
```

3. **Add expansion option** for groups:
```json
{
  "question": "Expand selected groups into individual issues?",
  "header": "Task Granularity",
  "multiSelect": false,
  "options": [
    {"label": "Keep as grouped tasks", "description": "Creates {N} tasks (one per group)"},
    {"label": "Expand into individual tasks", "description": "Creates {M} tasks (one per issue)"},
    {"label": "Show issues and select manually", "description": "See all issues in selected groups"}
  ]
}
```

**Phase 3: Task Creation Integration**

Wire selected tasks to actual creation:

1. **For grouped tasks**:
   - Title: "{group_label}: {issue_count} issues"
   - Description: List all issues with file:line references
   - Language: Detect from majority file type in group
   - Priority: Highest priority in group

2. **For individual tasks**:
   - Title: "{issue description, truncated to 60 chars}"
   - Description: Full issue details with file:line
   - Language: From file extension
   - Priority: From severity

3. **Add dependency linking** for related groups:
   - Critical/High fix tasks should depend on completed research
   - Quality tasks can reference related fix tasks

### Sections to Modify

| File | Section | Change |
|------|---------|--------|
| `review.md` | Section 5 (lines 308-323) | Remove `--create-tasks` conditional, always proceed to 5.5 |
| `review.md` | Section 5.5 (lines 325-384) | Complete rewrite with grouping + AskUserQuestion |
| `review.md` | After Section 5.5 | Add new Section 5.6 for task creation from selection |
| `review.md` | Section 6 | Update to include task creation tracking |
| `review.md` | Frontmatter | Add AskUserQuestion to allowed-tools |

### Estimated Line Changes

- **Removal**: ~20 lines (old flat list logic)
- **Addition**: ~150 lines (grouping algorithm, AskUserQuestion prompts, task creation)
- **Modification**: ~30 lines (flag handling, output formatting)
- **Total**: Net +160 lines

## Decisions

1. **Reuse /learn's clustering algorithm** rather than creating new one - proven pattern
2. **Use AskUserQuestion with multiSelect** for group selection (consistent with other commands)
3. **Offer three granularity options**: grouped, expanded, manual - matches /learn's pattern
4. **Group by file_section + issue_type as primary criteria** - most intuitive for code review context
5. **Keep priority scoring from current implementation** - useful for sorting groups

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Complex grouping may confuse users | Provide clear group labels and descriptions |
| Too many groups defeats purpose | Limit to 7-10 groups max, combine small groups |
| Dependency linking complexity | Start simple (no cross-group dependencies), add later |
| AskUserQuestion limitation on options | Use pagination or "Show more" pattern if >15 groups |

## Appendix

### Search Queries Used

1. `AskUserQuestion` - Found 12 files with patterns
2. `--create-tasks` - Found usage in review.md and user-guide.md
3. `group|cluster|categorize` - Found /learn grouping implementation
4. `checkbox|interactive|selection` - Found comprehensive patterns

### Key File References

- `.claude/commands/review.md` - Primary target for modification
- `.claude/skills/skill-learn/SKILL.md` - Reference implementation for grouping
- `.claude/commands/todo.md` - Example of AskUserQuestion with multiSelect
- `.claude/commands/task.md` - Task creation jq patterns

### AskUserQuestion Tool Signature

```json
{
  "question": "string - The question to display",
  "header": "string - Section header",
  "multiSelect": "boolean - Allow multiple selections",
  "options": [
    {
      "label": "string - Option label (displayed)",
      "description": "string - Additional context"
    }
  ]
}
```
