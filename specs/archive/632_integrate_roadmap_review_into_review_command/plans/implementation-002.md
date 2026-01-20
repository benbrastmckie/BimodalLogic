# Implementation Plan: Task #632

- **Task**: 632 - Integrate roadmap review into /review command
- **Status**: [COMPLETED]
- **Effort**: 6 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/632_integrate_roadmap_review_into_review_command/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false
- **Revision**: v2 - Added Phase 0 for context file creation

## Overview

Modify the `/review` command to integrate roadmap analysis as a core operation. The implementation:
1. Creates minimal context files documenting ROAD_MAP.md format and update process
2. Adds Step 2.5 (Roadmap Integration) that parses ROAD_MAP.md structure
3. Cross-references completed work with TODO.md/state.json and codebase state
4. Annotates completed items and identifies current goals
5. Presents recommended tasks for user selection via AskUserQuestion

### Research Integration

Key findings from research-001.md:
- Current /review has 8 steps; roadmap integration fits at Step 2.5
- ROAD_MAP.md uses parseable patterns: phase headers, checkboxes, status tables, priority markers
- AskUserQuestion pattern from meta-builder-agent enables user task selection
- Annotation format: `[x] {item} *(Completed: Task {N}, {DATE})*`
- Cross-reference uses TODO.md status, state.json, file existence, and sorry counts

## Goals & Non-Goals

**Goals**:
- Create minimal context files for ROAD_MAP.md format and update process
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
| Roadmap format changes break parsing | H | L | Document format in context file, add validation warnings |
| Edit corruption of ROAD_MAP.md | H | L | Use precise Edit tool patterns with exact string matching |
| Too many recommendations overwhelm user | M | M | Limit to 5-7 highest priority items |
| Cross-reference mismatches | M | M | Require explicit task number references, allow manual override |
| Context files bloat conversation | M | L | Keep files minimal, use @-references only where needed |

## Implementation Phases

### Phase 0: Context File Creation [COMPLETED]

**Goal**: Create minimal context files documenting ROAD_MAP.md format and update process

**Tasks**:
- [ ] Create `.claude/context/core/formats/roadmap-format.md` - Document standard ROAD_MAP.md structure
- [ ] Create `.claude/context/core/patterns/roadmap-update.md` - Document roadmap update process
- [ ] Keep files minimal (<100 lines each) for lazy loading efficiency
- [ ] Add @-references in review.md to load context only when needed

**Timing**: 0.5 hours

**Files to create**:
- `.claude/context/core/formats/roadmap-format.md`
- `.claude/context/core/patterns/roadmap-update.md`

**Context file content guidelines**:

**roadmap-format.md** should document:
- Phase header format (`## Phase {N}: {Title} (Priority)`)
- Checkbox format (`- [ ]` incomplete, `- [x]` complete)
- Status table format (`| Component | Status | Location |`)
- Annotation format for completion (`*(Completed: Task {N}, {DATE})*`)
- Success metrics section format

**roadmap-update.md** should document:
- When roadmap updates happen (during /review)
- How completion is detected (cross-reference with TODO.md/state.json)
- How items are annotated (checkbox conversion, annotation suffix)
- How goals are identified (first incomplete items per phase)
- How tasks are recommended (priority scoring, user selection)

**Verification**:
- Context files exist and are <100 lines each
- Files follow existing .claude/context/ format conventions

---

### Phase 1: Core Roadmap Parsing [COMPLETED]

**Goal**: Implement parsing functions to extract structure from ROAD_MAP.md

**Tasks**:
- [ ] Add Step 2.5 section header to `.claude/commands/review.md` after Step 1.5
- [ ] Add @-reference to load `roadmap-format.md` context at Step 2.5
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
- Context file @-reference is present

---

### Phase 2: Cross-Reference Logic [COMPLETED]

**Goal**: Implement cross-referencing between roadmap items and project state

**Tasks**:
- [ ] Add @-reference to load `roadmap-update.md` context for cross-reference patterns
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

### Phase 3: Roadmap Annotation [COMPLETED]

**Goal**: Implement roadmap editing to mark completed items

**Tasks**:
- [ ] Document annotation format (per roadmap-format.md context)
- [ ] Add instructions for updating status tables with verification dates
- [ ] Define Edit tool usage patterns (precise old_string/new_string)
- [ ] Add safety checks to preserve existing content
- [ ] Document handling of already-annotated items (skip re-annotation)

**Timing**: 1 hour

**Files to modify**:
- `.claude/commands/review.md` - Add Step 2.5.3 annotation section

**Verification**:
- Annotation format matches context file specification
- Edit patterns are safe and reversible

---

### Phase 4: Task Recommendation Engine [COMPLETED]

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

### Phase 5: Report Integration and Testing [COMPLETED]

**Goal**: Add roadmap progress section to review report and verify end-to-end flow

**Tasks**:
- [ ] Add "Roadmap Progress" section template to report format
- [ ] Include sections: Completed Since Last Review, Current Focus, Recommended Tasks
- [ ] Track created task numbers in review report
- [ ] Update review state with roadmap findings (optional extension)
- [ ] Add git commit to include ROAD_MAP.md changes
- [ ] Document error handling for parsing failures (warn but continue)

**Timing**: 0.5 hours

**Files to modify**:
- `.claude/commands/review.md` - Update Step 4 report format, Step 7 git commit

**Verification**:
- Review report template includes roadmap section
- Git commit includes ROAD_MAP.md if modified
- Parsing failures produce warnings, not fatal errors

---

## Testing & Validation

- [ ] Context files exist at specified paths and are <100 lines
- [ ] Manual run of `/review` command produces roadmap progress section
- [ ] ROAD_MAP.md checkboxes correctly annotated with task numbers
- [ ] Status tables updated with verification dates where applicable
- [ ] AskUserQuestion prompt displays with 5-7 recommendations
- [ ] User task selection creates tasks via `/task` command
- [ ] Review report includes "Roadmap Progress" section
- [ ] Git commit includes both review report and ROAD_MAP.md changes

## Artifacts & Outputs

- `.claude/context/core/formats/roadmap-format.md` - ROAD_MAP.md format specification
- `.claude/context/core/patterns/roadmap-update.md` - Roadmap update process documentation
- `.claude/commands/review.md` - Modified with roadmap integration
- `specs/reviews/review-{DATE}.md` - Future reviews include roadmap section
- `specs/ROAD_MAP.md` - Annotated with completion status (during review runs)

## Context Loading Strategy

The context files are loaded lazily via @-references:
- `roadmap-format.md` - Referenced at Step 2.5 (parsing)
- `roadmap-update.md` - Referenced at Step 2.5.2 (cross-reference)

This ensures minimal context loading overhead while providing standardized documentation.

## Rollback/Contingency

If implementation causes issues:
1. Revert `.claude/commands/review.md` to previous version via git
2. Context files are additive and can remain in place
3. ROAD_MAP.md annotations are additive and can be manually removed
4. Review state and reports are independent files, unaffected by rollback
