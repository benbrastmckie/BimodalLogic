# Implementation Plan: Task #632

- **Task**: 632 - Integrate roadmap review into /review command
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/632_integrate_roadmap_review_into_review_command/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Modify the `/review` command to integrate roadmap analysis as a core operation. The implementation adds a Step 2.5 (Roadmap Integration) that parses ROAD_MAP.md structure, cross-references completed work with TODO.md/state.json and codebase state, annotates completed items, identifies current goals, and presents recommended tasks for user selection via AskUserQuestion. The research report provides detailed patterns for parsing, cross-referencing, and editing.

### Research Integration

Key findings from research-001.md:
- Current /review has 8 steps; roadmap integration fits at Step 2.5
- ROAD_MAP.md uses parseable patterns: phase headers, checkboxes, status tables, priority markers
- AskUserQuestion pattern from meta-builder-agent enables user task selection
- Annotation format: `[x] {item} *(Completed: Task {N}, {DATE})*`
- Cross-reference uses TODO.md status, state.json, file existence, and sorry counts

## Goals & Non-Goals

**Goals**:
- Parse ROAD_MAP.md phases, checkboxes, and status tables
- Cross-reference roadmap items with completed tasks and codebase state
- Annotate completed roadmap items with task numbers and dates
- Identify current goals and next actionable items
- Present 5-7 recommended tasks via AskUserQuestion
- Create tasks for user-selected items
- Add "Roadmap Progress" section to review report

**Non-Goals**:
- Restructuring ROAD_MAP.md format
- Automated task creation without user selection
- Complex fuzzy matching between task titles and roadmap items
- Build verification (optional, may skip for performance)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Roadmap format changes break parsing | H | L | Add format validation warnings, fail gracefully |
| Edit corruption of ROAD_MAP.md | H | L | Use precise Edit tool patterns with exact string matching |
| Too many recommendations overwhelm user | M | M | Limit to 5-7 highest priority items |
| Cross-reference mismatches | M | M | Require explicit task number references, allow manual override |
| Long execution time | M | L | Parallelize independent operations where possible |

## Implementation Phases

### Phase 1: Core Roadmap Parsing [NOT STARTED]

**Goal**: Implement parsing functions to extract structure from ROAD_MAP.md

**Tasks**:
- [ ] Add Step 2.5 section header to `.claude/commands/review.md` after Step 1.5
- [ ] Document roadmap parsing approach with regex patterns
- [ ] Implement phase header extraction (`## Phase {N}: {Title}`)
- [ ] Implement checkbox state detection (incomplete `- [ ]` vs completed `- [x]`)
- [ ] Implement status table parsing (`| Component | Status | Location |`)
- [ ] Implement priority marker extraction (`(High Priority)`, etc.)
- [ ] Build structured `roadmap_state` data from parsed content

**Timing**: 1.5 hours

**Files to modify**:
- `.claude/commands/review.md` - Add Step 2.5 roadmap parsing section

**Verification**:
- Review command describes parsing approach for all roadmap components
- Regex patterns match actual ROAD_MAP.md content

---

### Phase 2: Cross-Reference Logic [NOT STARTED]

**Goal**: Implement cross-referencing between roadmap items and project state

**Tasks**:
- [ ] Add TODO.md query instructions (find completed tasks matching roadmap items)
- [ ] Add state.json query instructions (status: completed filter)
- [ ] Add file existence check instructions (Glob for mentioned paths)
- [ ] Add sorry count verification instructions (Grep for sorry in Theories/)
- [ ] Document matching strategy for roadmap items to tasks
- [ ] Define confidence levels: exact match, fuzzy match, suggested

**Timing**: 1 hour

**Files to modify**:
- `.claude/commands/review.md` - Add Step 2.5.2 cross-reference section

**Verification**:
- Cross-reference instructions cover all data sources
- Matching strategy handles ambiguous cases

---

### Phase 3: Roadmap Annotation [NOT STARTED]

**Goal**: Implement roadmap editing to mark completed items

**Tasks**:
- [ ] Document annotation format for completed checkboxes
- [ ] Add instructions for updating status tables with verification dates
- [ ] Define Edit tool usage patterns (precise old_string/new_string)
- [ ] Add safety checks to preserve existing content
- [ ] Document handling of already-annotated items (skip re-annotation)

**Timing**: 1 hour

**Files to modify**:
- `.claude/commands/review.md` - Add Step 2.5.3 annotation section

**Verification**:
- Annotation format matches research recommendation
- Edit patterns are safe and reversible

---

### Phase 4: Task Recommendation Engine [NOT STARTED]

**Goal**: Generate and present task recommendations from incomplete roadmap items

**Tasks**:
- [ ] Add logic to identify first incomplete items per phase
- [ ] Add priority scoring based on phase priority markers and execution order
- [ ] Add task description generation from roadmap item text
- [ ] Add language inference from file paths mentioned in items
- [ ] Implement AskUserQuestion prompt with multi-select
- [ ] Add task creation via `/task` for selected items
- [ ] Limit recommendations to 5-7 items maximum

**Timing**: 1.5 hours

**Files to modify**:
- `.claude/commands/review.md` - Add Step 5.5 task recommendation section

**Verification**:
- AskUserQuestion format matches meta-builder-agent pattern
- Task creation properly invokes /task command

---

### Phase 5: Report Integration and Testing [NOT STARTED]

**Goal**: Add roadmap progress section to review report and verify end-to-end flow

**Tasks**:
- [ ] Add "Roadmap Progress" section template to report format
- [ ] Include sections: Completed Since Last Review, Current Focus, Recommended Tasks
- [ ] Track created task numbers in review report
- [ ] Update review state with roadmap findings (optional extension)
- [ ] Add git commit to include ROAD_MAP.md changes
- [ ] Document error handling for parsing failures (warn but continue)

**Timing**: 1 hour

**Files to modify**:
- `.claude/commands/review.md` - Update Step 4 report format, Step 7 git commit

**Verification**:
- Review report template includes roadmap section
- Git commit includes ROAD_MAP.md if modified
- Parsing failures produce warnings, not fatal errors

---

## Testing & Validation

- [ ] Manual run of `/review` command produces roadmap progress section
- [ ] ROAD_MAP.md checkboxes correctly annotated with task numbers
- [ ] Status tables updated with verification dates where applicable
- [ ] AskUserQuestion prompt displays with 5-7 recommendations
- [ ] User task selection creates tasks via `/task` command
- [ ] Review report includes "Roadmap Progress" section
- [ ] Git commit includes both review report and ROAD_MAP.md changes

## Artifacts & Outputs

- `.claude/commands/review.md` - Modified with roadmap integration
- `specs/reviews/review-{DATE}.md` - Future reviews include roadmap section
- `specs/ROAD_MAP.md` - Annotated with completion status (during review runs)

## Rollback/Contingency

If implementation causes issues:
1. Revert `.claude/commands/review.md` to previous version via git
2. ROAD_MAP.md annotations are additive and can be manually removed
3. Review state and reports are independent files, unaffected by rollback
