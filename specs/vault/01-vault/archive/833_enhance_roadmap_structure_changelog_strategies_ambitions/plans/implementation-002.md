# Implementation Plan: Task #833 (v002)

- **Task**: 833 - Enhance ROADMAP.md Structure with Changelog, Strategies, and Ambitions
- **Status**: [COMPLETED]
- **Effort**: 4 hours (revised from 3.5)
- **Dependencies**: None (blocks tasks 834, 835)
- **Research Inputs**:
  - reports/research-001.md (schemas for new sections, command integration)
  - reports/research-002.md (content exclusions, Dead Ends section, boundaries)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Revision Notes

**v002 changes from v001**:
- Added **Rationale** field to all section schemas (Changelog, Strategies, Ambitions, Dead Ends)
- Added **References** field for artifact citations
- Updated migration phases to capture why each item was pursued and key reference documents
- Slightly increased effort estimate to account for citation work

**Revision reason**: User requested "brief reasons and citations for the elements included in each section to keep track of why things were/are pursued, and what key references to use to learn more."

## Overview

Restructure specs/ROAD_MAP.md to add four new sections (Changelog, Strategies, Ambitions, Dead Ends) while removing clutter content. Each section entry will include:
- **Rationale**: Brief explanation of WHY this item exists/was pursued
- **References**: Links to relevant task artifacts, research reports, or external sources

This prevents circular decision-making by documenting not just WHAT was done, but WHY and WHERE to learn more.

### Research Integration

- **research-001.md**: Base schemas for sections with regex patterns and command integration
- **research-002.md**: Dead Ends section design, clutter analysis, content boundaries

## Goals & Non-Goals

**Goals**:
- Add Changelog section with dated entries including completion rationale
- Add Strategies section with hypothesis rationale and reference links
- Add Ambitions section with motivation and related artifacts
- Add Dead Ends section with failure reasons and evidence links
- Remove "Active Metalogic Tasks" section (duplicates TODO.md)
- Condense Boneyard tables to summary with archive reference
- Ensure every entry explains WHY and cites relevant artifacts

**Non-Goals**:
- Implementing `/todo` command updates (task 834)
- Implementing `/review` command updates (task 835)
- Creating specs/ROAD_MAP_ARCHIVE.md (future work)
- Changing existing phase structure

## Revised Schemas

### Schema 1: Changelog (with Rationale)

```markdown
## Changelog

### YYYY-MM-DD

- **Task {N}**: {summary}
  - *Rationale*: {Why this work was needed/pursued}
  - *References*: [summary](path/to/summary.md), [plan](path/to/plan.md)
```

**Required Fields**:
| Field | Format | Purpose |
|-------|--------|---------|
| Date header | `### YYYY-MM-DD` | Group by completion date |
| Task entry | `**Task {N}**: {summary}` | What was done |
| Rationale | `*Rationale*: {text}` | Why it was done |
| References | `*References*: [label](path)` | Where to learn more |

### Schema 2: Strategies (with Rationale)

```markdown
## Strategies

### Strategy: {Name}

**Status**: {ACTIVE|PAUSED|CONCLUDED|ABANDONED}
**Started**: YYYY-MM-DD
**Hypothesis**: {What we're testing}

*Rationale*: {Why we chose this approach over alternatives}

**Approach**:
{Description}

**Outcomes**:
- {Outcome}

**References**:
- [Research Report](path/to/research.md) - {what it covers}
- [Task 753](specs/753_.../plans/...) - Initial implementation
- [External](https://example.com) - {title/description}

---
```

**Required Fields** (additions in bold):
| Field | Purpose |
|-------|---------|
| Rationale | Why this strategy was chosen |
| References | Links to supporting artifacts |

### Schema 3: Ambitions (with Rationale)

```markdown
## Ambitions

### Ambition: {Name}

**Priority**: {HIGH|MEDIUM|LOW}
**Timeframe**: {SHORT-TERM|MEDIUM-TERM|LONG-TERM|ONGOING}

*Rationale*: {Why this goal matters to the project}

**Success Criteria**:
- [ ] {Criterion}

**Description**:
{What we aspire to achieve}

**Related Phases**: Phase {N}
**References**:
- [Phase {N} description](ROAD_MAP.md#phase-n) - Context
- [Task {M} research](path) - Supporting analysis

---
```

### Schema 4: Dead Ends (with Evidence References)

```markdown
## Dead Ends

### Dead End: {Name}

**Status**: ABANDONED | SUPERSEDED | BLOCKED
**Tried**: YYYY-MM-DD to YYYY-MM-DD
**Related Tasks**: Task {N}, Task {M}

*Rationale*: {Why we originally tried this approach}

**What We Tried**:
{Description}

**Why It Failed**:
{Specific reasons}

**Evidence**:
- [Boneyard/File.lean](path) - Archived implementation
- [Task {N} summary](path) - Post-mortem analysis
- [Commit abc123](link) - Where attempt was abandoned

**Lesson**:
{1-sentence actionable takeaway}

**Superseded By**: {Alternative approach if applicable}

---
```

## Implementation Phases

### Phase 1: Add Section Scaffolding with Schema Comments [COMPLETED]

**Goal**: Insert empty section structure with enhanced schemas documented

**Tasks**:
- [ ] Read current ROAD_MAP.md to identify insertion point
- [ ] Insert `## Changelog` with schema comment including Rationale/References fields
- [ ] Insert `## Strategies` with schema comment including Rationale/References fields
- [ ] Insert `## Ambitions` with schema comment including Rationale/References fields
- [ ] Insert `## Dead Ends` with schema comment including Evidence/References fields
- [ ] Add horizontal rule separators

**Timing**: 30 minutes

**Files to modify**:
- `specs/ROAD_MAP.md`

**Verification**:
- All 4 sections have schema comments documenting Rationale and References fields

---

### Phase 2: Migrate Existing Content to Strategies with Rationale [COMPLETED]

**Goal**: Extract approach descriptions into Strategies format with reasons and citations

**Tasks**:
- [ ] **Indexed MCS Family Approach**
  - Extract from lines 69-77
  - Rationale: "Enables representation theorem via modal saturation properties"
  - References: Task 753 research, IndexedMCSFamily.lean
- [ ] **CoherentConstruction Approach**
  - Extract from lines 154-172
  - Rationale: "Two-chain design (left/right) simplifies coherence proofs"
  - References: Task 814 research, CoherentConstruction.lean
- [ ] **Algebraic Approach**
  - Extract from lines 174-188
  - Rationale: "Provides alternative verification path via Boolean algebra"
  - References: Phase 5 description, Algebraic/ module
- [ ] **Representation-First Architecture**
  - Extract from lines 62-126
  - Rationale: "Core completeness depends on representation theorem as foundation"
  - References: Phase 4 overview, Bundle/Representation.lean
- [ ] Mark each with appropriate status
- [ ] Add Started dates from task history

**Timing**: 60 minutes (increased for citation work)

**Files to modify**:
- `specs/ROAD_MAP.md` - Populate Strategies section

**Verification**:
- 4 strategies documented with Rationale and References fields
- All References link to valid paths

---

### Phase 3: Create Initial Ambitions with Motivation [COMPLETED]

**Goal**: Extract long-term goals with rationale explaining importance

**Tasks**:
- [ ] **Publication-Ready Metalogic**
  - Rationale: "Core use case for the codebase - verified modal logic proofs"
  - References: Phase 6 description, README.md vision statement
- [ ] **Full LTL Extension**
  - Rationale: "Until/Since operators complete the temporal expressiveness"
  - References: Phase 3.3.A description, LTL.lean
- [ ] **Modular Frame Classes**
  - Rationale: "Enables theory reuse across different modal systems"
  - References: Phase 2.3 description, FrameClasses.lean
- [ ] **Algebraic Verification Path**
  - Rationale: "Alternative proof method that may simplify some arguments"
  - References: Algebraic/ module README, Phase 5 description
- [ ] **Proof Economy**
  - Rationale: "Reduce sorry count to achieve production-quality proofs"
  - References: sorry-debt-policy.md, Phase 1 goals
- [ ] Assign priorities and add success criteria

**Timing**: 60 minutes (increased for citation work)

**Files to modify**:
- `specs/ROAD_MAP.md` - Populate Ambitions section

**Verification**:
- 5 ambitions with Rationale and References fields
- References link to valid paths

---

### Phase 4: Document Dead Ends with Evidence [COMPLETED]

**Goal**: Create Dead Ends entries with failure reasons and evidence links

**Tasks**:
- [ ] **Boneyard Decidability Infrastructure**
  - Rationale: "Attempted decidability via explicit frame enumeration"
  - Why Failed: Parametric FMP approach is cleaner
  - Evidence: Boneyard/Decidability/ folder, Task 812 summary
  - Superseded by: semantic_weak_completeness
- [ ] **Single-History FDSM Construction**
  - Rationale: "Attempted simpler single-history model construction"
  - Why Failed: Modal trivialization (Box psi = psi)
  - Evidence: Task 825 research-002.md, archived fdsm_from_closure_mcs
  - Lesson: Multi-history saturation required for non-trivial modalities
- [ ] **Cross-Origin Coherence Proofs**
  - Rationale: "Attempted to prove coherence across different MCS origins"
  - Why Failed: Not on critical path
  - Evidence: coherence_sorries in Construction.lean
  - Lesson: Focus effort on what's actually blocking main results
- [ ] **Original IndexedMCSFamily.construct_indexed_family**
  - Rationale: "Initial attempt at indexed family construction"
  - Why Failed: CoherentConstruction provides cleaner two-chain design
  - Evidence: Git history, Task 814 research
  - Superseded by: CoherentConstruction module

**Timing**: 45 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - Populate Dead Ends section

**Verification**:
- 4 dead ends with Evidence links and Lesson fields
- All Evidence links are valid

---

### Phase 5: Remove Clutter Content [COMPLETED]

**Goal**: Remove or condense content that belongs elsewhere

**Tasks**:
- [ ] Remove "Active Metalogic Tasks" section (lines 903-918)
- [ ] Condense Boneyard status tables to summary paragraph
- [ ] Add note: "Full Boneyard documentation in Boneyard/README.md"
- [ ] Update "Last Updated" date

**Timing**: 30 minutes

**Files to modify**:
- `specs/ROAD_MAP.md`

**Verification**:
- "Active Metalogic Tasks" removed
- Boneyard condensed
- ~50-100 lines reduced

---

### Phase 6: Add Content Boundary Documentation [COMPLETED]

**Goal**: Add guidance on what belongs where

**Tasks**:
- [ ] Add "Content Boundaries" note after header
- [ ] Define: ROADMAP = strategic (months-years), TODO = operational (days-weeks), specs = tactical (hours-days)
- [ ] Note: "Each entry should include Rationale (why) and References (learn more)"

**Timing**: 15 minutes

**Files to modify**:
- `specs/ROAD_MAP.md`

**Verification**:
- Content boundary definitions present
- Rationale/References guidance included

---

### Phase 7: Verify and Validate [COMPLETED]

**Goal**: Ensure all entries have proper rationale and working links

**Tasks**:
- [ ] Verify all Strategies have Rationale and References fields
- [ ] Verify all Ambitions have Rationale and References fields
- [ ] Verify all Dead Ends have Evidence links
- [ ] Check all artifact paths are valid
- [ ] Verify markdown renders correctly
- [ ] Count final line changes

**Timing**: 20 minutes

**Verification**:
- All entries follow enhanced schemas
- All references link to valid paths
- No broken links

## Testing & Validation

- [ ] Changelog: Schema includes Rationale and References fields in comments
- [ ] Strategies: 4 entries with Rationale and References populated
- [ ] Ambitions: 5 entries with Rationale and References populated
- [ ] Dead Ends: 4 entries with Evidence links and Lessons
- [ ] All artifact paths resolve to existing files
- [ ] Active Metalogic Tasks section removed
- [ ] Markdown renders without errors

## Artifacts & Outputs

- `specs/ROAD_MAP.md` - Restructured with enhanced schemas
- `specs/833_enhance_roadmap_structure_changelog_strategies_ambitions/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

Git revert available for any phase. Incremental commits after each phase.
