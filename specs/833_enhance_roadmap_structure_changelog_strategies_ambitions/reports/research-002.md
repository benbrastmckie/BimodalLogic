# Research Report: Task #833 (Part 2)

**Task**: 833 - Enhance ROADMAP.md Structure with Changelog, Strategies, and Ambitions
**Started**: 2026-02-03T14:00:00Z
**Completed**: 2026-02-03T14:45:00Z
**Focus**: What to EXCLUDE from ROADMAP.md, preventing circular attempts, lessons learned tracking
**Effort**: 30 minutes research + implementation time
**Dependencies**: None
**Sources/Inputs**:
- Current specs/ROAD_MAP.md (939 lines)
- Theories/Logos/docs/project-info/ROADMAP.md (194 lines)
- research-001.md (covers what to ADD)
- Web research: roadmap anti-patterns, lessons learned formats, ADRs, content archiving
**Artifacts**: This report
**Standards**: report-format.md

## Executive Summary

- Current ROAD_MAP.md contains significant clutter: task-level status tables, outdated Boneyard references, verbose code examples, and duplicate information that belongs in TODO.md or task artifacts
- Recommend adding a **Dead Ends** section to track failed approaches and prevent circular decision-making, using Architecture Decision Record (ADR) patterns
- Define clear content boundaries: ROADMAP = strategic vision (months-years), TODO = task queue (days-weeks), task artifacts = execution details (hours-days)
- Establish quarterly archival cycle to move completed phases and obsolete content to a separate archive document

## Context & Scope

### Research Questions

1. What content types clutter roadmaps and should be excluded?
2. What anti-patterns in project documentation lead to circular decision-making?
3. How to structure a "Lessons Learned" or "Failed Experiments" section?
4. What granularity of detail belongs in ROADMAP vs TODO vs task artifacts?

### Relationship to research-001.md

research-001.md focused on what to ADD (Changelog, Strategies, Ambitions sections with schemas). This report focuses on:
- What to REMOVE or RELOCATE from current content
- How to prevent repeating failed approaches
- Content boundary definitions

## Findings

### 1. Clutter Analysis of Current ROAD_MAP.md

#### Content That Should Be Removed or Relocated

| Lines | Content Type | Issue | Recommendation |
|-------|--------------|-------|----------------|
| 17-60 | Boneyard status tables | Deprecated content given prominent placement | Move to appendix or separate archive file |
| 78-98 | Detailed sorry/gap tracking | Task-level detail, belongs in task artifacts | Move to Metalogic README or task specs |
| 101-126 | Technical implementation details | Too granular for roadmap | Reference task specs instead |
| 154-172 | CoherentConstruction details | Implementation-level, changes frequently | Keep high-level summary only |
| 199-210 | Decidability tables | Boneyard infrastructure, deprecated | Archive or remove |
| 281-301 | Code examples | Verbose, rarely updated | Move to docs/tutorials or remove |
| 903-918 | Active Tasks section | Duplicates TODO.md, stale within days | Remove entirely (use TODO.md) |

#### Estimated Line Reduction

| Category | Current Lines | After Cleanup | Reduction |
|----------|---------------|---------------|-----------|
| Boneyard/deprecated | ~120 | 20 (summary) | 100 lines |
| Code examples | ~60 | 0 | 60 lines |
| Task-level details | ~80 | 20 (references) | 60 lines |
| Duplicate content | ~50 | 0 | 50 lines |
| **Total** | ~310 | ~40 | **~270 lines** |

This would reduce ROAD_MAP.md from ~939 lines to ~669 lines (28% reduction) while improving clarity.

### 2. Anti-Patterns Leading to Circular Decision-Making

Based on web research and codebase analysis, these anti-patterns cause teams to revisit the same failed approaches:

#### A. Undocumented Dead Ends

**Pattern**: Approach is tried, fails, gets abandoned without recording why it failed. Months later, same approach is tried again.

**Examples in current codebase**:
- The Boneyard contains deprecated approaches but lacks explanation of WHY they were deprecated
- CoherentConstruction vs IndexedMCSFamily approaches are both documented without clear narrative of which superseded which
- Task 753, 755, 750 represent different completeness strategies without cross-references

**Solution**: Add explicit "Dead Ends" section documenting failed approaches with reasons.

#### B. Missing Decision Context

**Pattern**: Current approach is documented, but alternatives considered and rejected are not. New contributors (or future-you) don't know why alternatives were rejected.

**Architecture Decision Records (ADRs)** solve this by capturing:
- Context (what prompted the decision)
- Decision (what was chosen)
- Consequences (what resulted)
- Alternatives considered (what was rejected and why)

**Solution**: Integrate ADR-style content into Strategies section with explicit "Rejected Alternatives" subsections.

#### C. Stale Status Information

**Pattern**: Status tables get outdated, creating confusion about current state. People make decisions based on stale information.

**Current issue**: Lines 903-918 "Active Metalogic Tasks" section shows tasks from 2026-01-29 that may be completed or abandoned by now.

**Solution**: Remove task-level tracking from roadmap entirely. TODO.md is the authoritative source for task status.

#### D. Implicit vs Explicit Knowledge

**Pattern**: Lessons are learned but not written down. Knowledge exists only in individual memory or scattered commit messages.

**Solution**: Formalize lessons in structured format that's searchable and browsable.

### 3. Dead Ends / Lessons Learned Section Design

Based on [Architecture Decision Records](https://adr.github.io/), [retrospective best practices](https://www.parabol.co/resources/project-retrospectives/), and [lessons learned documentation](https://lean6sigmahub.com/lessons-learned-documentation-capturing-knowledge-for-future-projects/):

#### Proposed Schema: Dead Ends Section

```markdown
## Dead Ends

This section documents approaches that were tried and abandoned, to prevent circular decision-making.

### Dead End: {Name}

**Status**: ABANDONED | SUPERSEDED | BLOCKED
**Tried**: YYYY-MM-DD to YYYY-MM-DD
**Related Tasks**: Task {N}, Task {M}

**What We Tried**:
{1-2 paragraph description of the approach}

**Why It Failed**:
{Specific reasons: technical limitation, complexity, wrong abstraction, etc.}

**Evidence**:
- {Link to failed attempt, error message, or blocking issue}
- {Commit or branch where attempt lives}

**Lesson**:
{1 sentence takeaway that can inform future decisions}

**Superseded By**: {Alternative approach if applicable}

---
```

#### Key Fields Explained

| Field | Purpose | Prevents |
|-------|---------|----------|
| Status | Clear lifecycle state | Confusion about whether approach is viable |
| Tried dates | When effort was invested | Re-attempting at same tech maturity level |
| Related Tasks | Cross-reference to detailed work | Duplicating research effort |
| Why It Failed | Root cause analysis | Same mistake under different guise |
| Evidence | Concrete proof | "Maybe we just did it wrong" revisiting |
| Lesson | Distilled insight | Long document re-reading |
| Superseded By | Forward reference | Orphaned dead ends |

#### Initial Dead Ends to Document

Based on current codebase analysis:

1. **Boneyard Decidability Infrastructure**
   - Status: SUPERSEDED
   - Why: Parametric FMP approach is cleaner
   - Superseded by: semantic_weak_completeness

2. **Single-History FDSM Construction**
   - Status: ABANDONED
   - Why: Modal trivialization (Box psi = psi)
   - Lesson: Multi-history saturation required for non-trivial modalities

3. **Cross-Origin Coherence Proofs**
   - Status: BLOCKED
   - Why: Not on critical path, representation theorem doesn't require them
   - Lesson: Focus effort on what's actually blocking main results

4. **Original IndexedMCSFamily.construct_indexed_family**
   - Status: SUPERSEDED
   - Why: CoherentConstruction provides cleaner two-chain design
   - Superseded by: CoherentConstruction module

### 4. Content Boundary Definitions

Based on [roadmap best practices](https://www.productplan.com/glossary/project-roadmap/) and [project documentation guidelines](https://www.atlassian.com/agile/project-management/project-roadmap):

#### Roadmap (ROAD_MAP.md) - Strategic Level

**Timeframe**: Months to years
**Audience**: Project maintainers, contributors, stakeholders
**Granularity**: Phases, milestones, strategic goals

**INCLUDE**:
- Vision and long-term goals
- Major phases with high-level status
- Strategic decisions and their rationale
- Cross-cutting architectural concerns
- Success metrics and quality gates
- Dead ends and lessons learned

**EXCLUDE**:
- Individual task status (use TODO.md)
- Code examples (use docs/)
- Detailed sorry counts (use task artifacts)
- Active task lists (stale within days)
- Implementation-level details (use task specs)

#### TODO (TODO.md) - Operational Level

**Timeframe**: Days to weeks
**Audience**: Active developers, task assignment
**Granularity**: Individual tasks with status

**INCLUDE**:
- Task queue with priorities
- Blocking/blocked-by relationships
- Effort estimates
- Links to research/plan artifacts

**EXCLUDE**:
- Strategic rationale (use ROAD_MAP.md)
- Historical completed tasks (archive)
- Alternative approaches considered (use roadmap Strategies)

#### Task Artifacts (specs/{N}_{SLUG}/) - Execution Level

**Timeframe**: Hours to days
**Audience**: Developer working on specific task
**Granularity**: Step-by-step instructions, code changes

**INCLUDE**:
- Research findings with sources
- Implementation plans with phases
- Sorry inventories and categorization
- Technical details and code snippets
- Completion summaries

**EXCLUDE**:
- Strategic context (reference ROAD_MAP.md)
- Unrelated task information
- Project-wide status

### 5. Archival Guidelines

Based on [content archiving best practices](https://contentstrategyinc.com/best-practices-for-archiving-and-deleting-content/):

#### Quarterly Archival Cycle

Every 3 months, review and archive:
1. Completed phases (move details to archive, keep 1-line summary)
2. Superseded approaches (move to Dead Ends if not already)
3. Deprecated infrastructure (Boneyard references)
4. Stale task references (remove, TODO.md is source of truth)

#### Archive Location

Create `specs/ROAD_MAP_ARCHIVE.md` for:
- Full text of completed phases
- Detailed Boneyard documentation
- Historical decision context
- Old success metrics

#### Keep in Main Roadmap

- 1-line phase completion summaries with dates
- References to archive for details
- Active and future phases
- Current strategies and dead ends

## Decisions

1. **Remove "Active Metalogic Tasks" section** - TODO.md is authoritative, roadmap copy is always stale
2. **Relocate Boneyard details** - Keep 1-paragraph summary in roadmap, full tables in archive
3. **Add Dead Ends section** - Use ADR-inspired schema to prevent circular attempts
4. **Remove code examples** - Roadmap should reference tutorials, not contain code
5. **Define content boundaries** - Roadmap = strategic (months), TODO = operational (days), specs = tactical (hours)
6. **Establish quarterly review** - Archive completed phases, update dead ends, verify currency

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Over-aggressive pruning loses valuable context | High | Archive don't delete; keep references to archive |
| Dead Ends section becomes stale | Medium | Include in quarterly review cycle |
| Content boundary violations creep back | Medium | Document clear examples in each category |
| Archive becomes dumping ground | Low | Require structured format in archive too |

## Recommendations

### Immediate Actions (Task 833 Implementation)

1. Add Dead Ends section with initial 4 documented dead ends
2. Remove "Active Metalogic Tasks" section (lines 903-918)
3. Condense Boneyard tables to single summary paragraph with archive reference
4. Add content boundary definitions to roadmap header or separate guide

### Future Actions

1. Create specs/ROAD_MAP_ARCHIVE.md during implementation
2. Document quarterly archival process in .claude/commands/todo.md
3. Consider /roadmap command for roadmap-specific maintenance

## Appendix

### Search Queries Used

- "roadmap document anti-patterns clutter what to exclude software project documentation 2026"
- "lessons learned documentation format prevent circular decision making failed experiments tracking"
- "project roadmap vs todo list what level of detail belongs where granularity"
- "dead ends what we tried project documentation retrospective failed approaches architecture decision records"
- "roadmap maintenance archiving old content when to remove items from roadmap document hygiene"

### References

- [Architecture Decision Records](https://adr.github.io/) - ADR format and methodology
- [GitHub Well-Architected Anti-patterns](https://wellarchitected.github.com/library/scenarios/anti-patterns/) - Documentation anti-patterns
- [Project Retrospectives Guide](https://www.parabol.co/resources/project-retrospectives/) - Retrospective best practices
- [Lessons Learned Documentation](https://lean6sigmahub.com/lessons-learned-documentation-capturing-knowledge-for-future-projects/) - Capturing project insights
- [ProductPlan Project Roadmap](https://www.productplan.com/glossary/project-roadmap/) - Roadmap vs project plan granularity
- [Content Archiving Best Practices](https://contentstrategyinc.com/best-practices-for-archiving-and-deleting-content/) - When and how to archive

## Next Steps

1. Integrate findings from research-002.md (exclusions) with research-001.md (additions) in implementation plan
2. Run `/plan 833` to create comprehensive implementation plan
3. Implementation should address both ADDING new sections AND REMOVING/ARCHIVING clutter
4. Establish Dead Ends section with initial documented approaches from codebase
