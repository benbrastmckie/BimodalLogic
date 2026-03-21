# Implementation Plan: Task #833

- **Task**: 833 - Enhance ROADMAP.md Structure with Changelog, Strategies, and Ambitions
- **Status**: [NOT STARTED]
- **Effort**: 3.5 hours
- **Dependencies**: None (blocks tasks 834, 835)
- **Research Inputs**:
  - reports/research-001.md (schemas for new sections, command integration)
  - reports/research-002.md (content exclusions, Dead Ends section, boundaries)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Restructure specs/ROAD_MAP.md to add four new sections (Changelog, Strategies, Ambitions, Dead Ends) while removing clutter content that belongs elsewhere. The goal is to transform the roadmap from a detailed task tracker into a strategic document with machine-parseable schemas enabling programmatic updates by `/todo` and `/review` commands.

### Research Integration

- **research-001.md**: Provides schemas for Changelog, Strategies, and Ambitions sections with regex patterns for parsing, field requirements, and command integration patterns
- **research-002.md**: Identifies ~270 lines of clutter to remove/relocate, defines content boundaries (roadmap=strategic, TODO=operational, specs=tactical), and specifies Dead Ends section design using ADR patterns

## Goals & Non-Goals

**Goals**:
- Add Changelog section with dated entries schema for `/todo` integration
- Add Strategies section with status-tracked experiments schema
- Add Ambitions section with prioritized goals and success criteria
- Add Dead Ends section to prevent circular decision-making
- Remove "Active Metalogic Tasks" section (duplicates TODO.md)
- Condense Boneyard tables to summary with archive reference
- Migrate existing content (approaches, insights) to appropriate new sections
- Define clear parsing patterns for programmatic updates

**Non-Goals**:
- Implementing `/todo` command updates (task 834)
- Implementing `/review` command updates (task 835)
- Creating the archive file (specs/ROAD_MAP_ARCHIVE.md) - future work
- Removing phase detail content (keep for reference)
- Changing existing phase structure or task checkbox patterns

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Data loss during restructuring | High | Low | Work incrementally, commit after each section; keep original content in archive reference |
| Breaking existing `/todo` roadmap parsing | High | Low | New sections have distinct headers; existing `(Task {N})` patterns unchanged |
| Inconsistent migration of content | Medium | Medium | Document migration mapping before implementing; verify each moved item |
| File becomes too long with new sections | Medium | Low | Changelog entries are brief; establish archival guidelines |
| Ambiguous strategy/ambition categorization | Low | Medium | Clear definitions: strategy=how (experiment), ambition=what (goal) |

## Implementation Phases

### Phase 1: Add Section Scaffolding [NOT STARTED]

**Goal**: Insert empty section structure with schemas documented in comments

**Tasks**:
- [ ] Read current ROAD_MAP.md to identify exact insertion point (after "Status" line, before "Overview")
- [ ] Insert `## Changelog` section with schema comment and initial empty state
- [ ] Insert `## Strategies` section with schema comment
- [ ] Insert `## Ambitions` section with schema comment
- [ ] Insert `## Dead Ends` section with schema comment
- [ ] Add horizontal rule separators between new sections

**Timing**: 30 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - Insert 4 new sections

**Verification**:
- All 4 sections exist with proper headers
- Sections appear in correct order (Changelog, Strategies, Ambitions, Dead Ends)
- Sections are between header and Overview
- File still parses as valid markdown

---

### Phase 2: Migrate Existing Content to Strategies [NOT STARTED]

**Goal**: Extract and restructure approach descriptions into Strategies format

**Tasks**:
- [ ] Extract "Indexed MCS Family Approach" description from lines 69-77 into Strategy entry
- [ ] Extract "CoherentConstruction Approach" from lines 154-172 into Strategy entry
- [ ] Extract "Algebraic Approach" from lines 174-188 into Strategy entry
- [ ] Extract "Representation-First Architecture" concept into Strategy entry
- [ ] Mark each with appropriate status (ACTIVE/CONCLUDED based on current state)
- [ ] Add Started dates where known from task history
- [ ] Keep original detailed content in place (new section provides strategic summary)

**Timing**: 45 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - Populate Strategies section

**Verification**:
- 4 strategies documented with all required fields
- Status values match current codebase state
- Original detailed content remains for reference

---

### Phase 3: Create Initial Ambitions [NOT STARTED]

**Goal**: Extract long-term goals from existing content into Ambitions format

**Tasks**:
- [ ] Create "Publication-Ready Metalogic" ambition from Phase 6 goals
- [ ] Create "Full LTL Extension" ambition from Phase 3.3.A Until/Since section
- [ ] Create "Modular Frame Classes" ambition from Phase 2.3 description
- [ ] Create "Algebraic Verification Path" ambition from Algebraic Approach goals
- [ ] Create "Proof Economy" ambition from Phase 1 goals
- [ ] Assign priorities (HIGH/MEDIUM/LOW) based on Phase priority indicators
- [ ] Add success criteria as checkboxes from existing task lists
- [ ] Cross-reference related phases

**Timing**: 45 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - Populate Ambitions section

**Verification**:
- 5 ambitions documented with all required fields
- Success criteria include checkboxes
- Related Phases field links to existing phase numbers

---

### Phase 4: Document Dead Ends [NOT STARTED]

**Goal**: Create Dead Ends entries for failed/superseded approaches

**Tasks**:
- [ ] Document "Boneyard Decidability Infrastructure" as SUPERSEDED
- [ ] Document "Single-History FDSM Construction" as ABANDONED (modal trivialization)
- [ ] Document "Cross-Origin Coherence Proofs" as BLOCKED (not on critical path)
- [ ] Document "Original IndexedMCSFamily.construct_indexed_family" as SUPERSEDED by CoherentConstruction
- [ ] Include evidence links to relevant code/commits where available
- [ ] Add concise lessons learned for each

**Timing**: 30 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - Populate Dead Ends section

**Verification**:
- 4 dead ends documented with required fields
- Each has clear "Why It Failed" explanation
- Lessons are actionable 1-sentence takeaways

---

### Phase 5: Remove Clutter Content [NOT STARTED]

**Goal**: Remove or condense content that belongs elsewhere

**Tasks**:
- [ ] Remove "Active Metalogic Tasks" section (lines 903-918) - duplicates TODO.md
- [ ] Condense Boneyard status tables (lines 26-60) to single summary paragraph
- [ ] Add note: "Full Boneyard documentation available in Boneyard/README.md"
- [ ] Review code examples (if any verbose ones remain) and add references to docs/ instead
- [ ] Update "Last Updated" date in header

**Timing**: 30 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - Remove/condense clutter

**Verification**:
- "Active Metalogic Tasks" section removed
- Boneyard tables condensed to summary
- File reduced by ~50-100 lines
- No broken internal references

---

### Phase 6: Add Content Boundary Documentation [NOT STARTED]

**Goal**: Add clear guidance on what belongs in ROADMAP vs TODO vs task specs

**Tasks**:
- [ ] Add brief "Content Boundaries" note after header metadata
- [ ] Define: ROADMAP = strategic (months-years), TODO = operational (days-weeks), specs = tactical (hours-days)
- [ ] Reference quarterly archival practice (to be implemented later)

**Timing**: 15 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - Add content boundaries note

**Verification**:
- Content boundary definitions present
- Guidance is concise (5-10 lines)

---

### Phase 7: Verify and Validate [NOT STARTED]

**Goal**: Ensure restructured document is correct and consistent

**Tasks**:
- [ ] Verify all new section schemas match research-001.md specifications
- [ ] Check all regex patterns from research would correctly parse new content
- [ ] Verify no content was accidentally deleted (compare with original)
- [ ] Check internal cross-references still work
- [ ] Verify markdown formatting renders correctly
- [ ] Count final line reduction from original

**Timing**: 15 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- All 4 new sections follow specified schemas
- Original critical content preserved
- Net line reduction of 50-150 lines

## Testing & Validation

- [ ] Changelog section: Schema header present, empty entries area ready for `/todo` updates
- [ ] Strategies section: 4 strategies with all required fields (Status, Started, Hypothesis)
- [ ] Ambitions section: 5 ambitions with checkboxes for success criteria
- [ ] Dead Ends section: 4 entries with Why It Failed and Lesson fields
- [ ] Active Metalogic Tasks section: Removed
- [ ] Boneyard tables: Condensed to summary
- [ ] Internal links: All phase references work
- [ ] Markdown: Renders correctly (no broken syntax)

## Artifacts & Outputs

- `specs/ROAD_MAP.md` - Restructured roadmap with 4 new sections
- `specs/833_enhance_roadmap_structure_changelog_strategies_ambitions/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If restructuring causes issues:
1. Git revert to pre-implementation commit
2. Original ROAD_MAP.md is recoverable from git history
3. No external dependencies affected (tasks 834, 835 not yet implemented)

**Incremental commits** after each phase enable partial rollback if specific phase causes problems.
