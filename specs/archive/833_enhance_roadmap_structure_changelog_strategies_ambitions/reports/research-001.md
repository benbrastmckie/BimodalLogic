# Research Report: Task #833

**Task**: 833 - Enhance ROADMAP.md Structure with Changelog, Strategies, and Ambitions
**Started**: 2026-02-03T12:00:00Z
**Completed**: 2026-02-03T12:45:00Z
**Effort**: 2-3 hours (estimated for implementation)
**Dependencies**: None (blocking tasks 834, 835)
**Sources/Inputs**:
- Current ROADMAP files: `specs/ROAD_MAP.md`, `Theories/Logos/docs/project-info/ROADMAP.md`
- Existing patterns: `.claude/context/core/formats/roadmap-format.md`, `.claude/context/core/patterns/roadmap-update.md`
- `/todo` command: `.claude/commands/todo.md`
- Web research: Keep A Changelog specification, project roadmap best practices
**Artifacts**: This report
**Standards**: report-format.md

## Executive Summary

- Current ROAD_MAP.md (~940 lines) contains detailed phase-based development plans but lacks changelog tracking, strategy experiments, and long-term ambitions
- Recommend adding three new sections with machine-parseable schemas: **Changelog** (dated entries), **Strategies** (active experiments), **Ambitions** (big picture goals)
- Schemas designed for atomic updates by `/todo` (changelog entries) and `/review` (strategy status updates, ambition identification)

## Context & Scope

### Current ROADMAP Structure Analysis

The project has two ROADMAP files:

1. **`specs/ROAD_MAP.md`** (940 lines) - Primary development roadmap for ProofChecker
   - Current sections: Overview, Current State, Phases 0-6, Recommended Execution Order, Success Metrics, Open Questions, Active Tasks, Conclusion
   - Uses markdown tables for status tracking
   - Checkbox items with `- [ ]` / `- [x]` patterns
   - References task numbers with `(Task {N})` notation
   - Already integrated with `/todo` command for completion annotations

2. **`Theories/Logos/docs/project-info/ROADMAP.md`** (194 lines) - Logos-specific roadmap
   - Focused on Logos extension development phases
   - Simpler structure with Vision, Development Phases, Priority Order, Milestones

The task focuses on `specs/ROAD_MAP.md` which is the primary roadmap processed by commands.

### What's Missing

1. **Changelog**: No historical record of completed work. Task completions are annotated on existing items but there's no consolidated log of accomplishments over time.

2. **Strategies**: Active experiments and approaches are embedded in prose. No explicit tracking of:
   - Strategy name and hypothesis
   - Current status (active/paused/concluded)
   - Outcomes and learnings

3. **Ambitions**: Long-term vision is scattered. The "Current State" section describes accomplishments but not aspirations. Phase descriptions mix near-term tasks with long-term goals.

## Findings

### Industry Best Practices

#### Changelog Format (Keep A Changelog)

Based on the [Keep A Changelog](https://keepachangelog.com/en/1.1.0/) specification:

- **Structure**: Unreleased section at top, then versioned entries with dates
- **Date format**: ISO 8601 (YYYY-MM-DD)
- **Change categories**: Added, Changed, Deprecated, Removed, Fixed, Security
- **Guiding principles**: For humans not machines, linkable versions, latest first

**Adaptation for task-based workflow**: Replace version numbers with date ranges, link changes to task numbers.

#### Roadmap Strategies

From [Atlassian Project Roadmap Guide](https://www.atlassian.com/agile/project-management/project-roadmap) and [Aha! Roadmap Best Practices](https://www.aha.io/roadmapping/guide/roadmap/best-practices):

- Connect strategy (why) to actions (what) to timeline (when)
- Regular reviews and updates to reflect current state
- Clear ownership and status tracking
- Transparency with progress updates

#### Vision/Ambitions Documentation

From [Vision and Scope Documents](https://orangesoft.co/blog/how-to-write-a-vision-and-scope-document) and [Scrum Product Vision](https://resources.scrumalliance.org/Article/write-product-vision-statement):

- Concise, aspirational descriptions of long-term goals
- 3-5 key objectives representing strategic direction
- Success criteria for each ambition
- Timeframe (even if rough)

### Existing Integration Points

The `/todo` command (`.claude/commands/todo.md`) already:
- Scans `specs/ROAD_MAP.md` for task references
- Annotates checkboxes with `*(Completed: Task {N}, {DATE})*`
- Uses structured matching via `roadmap_items` field in `state.json`

The `/review` command currently:
- Generates review reports with roadmap progress sections
- Does NOT update ROAD_MAP.md directly

### Schema Design Requirements

1. **Machine-parseable**: Regular expressions can extract structured data
2. **Human-readable**: Markdown formatting for documentation
3. **Atomic updates**: Single Edit operations can modify entries
4. **Non-destructive**: New sections don't break existing functionality

## Recommendations

### Proposed Section Structure

Insert three new sections after "Last Updated" metadata and before "Overview":

```markdown
# ProofChecker Development Roadmap

**Last Updated**: YYYY-MM-DD
**Status**: {current status description}

---

## Changelog

{Dated entries of completed work}

---

## Strategies

{Active experiments with status}

---

## Ambitions

{Big picture goals}

---

## Overview
{existing content}
```

### Schema 1: Changelog Section

**Purpose**: Record completed work from task completions, updated by `/todo` command.

**Format**:
```markdown
## Changelog

### YYYY-MM-DD

- **Task {N}**: {completion_summary} [(details)](specs/{N}_{SLUG}/summaries/...)
- **Task {N}**: {completion_summary}

### YYYY-MM-DD

- **Task {N}**: {completion_summary}
```

**Schema Definition**:

| Element | Pattern | Example |
|---------|---------|---------|
| Date header | `### YYYY-MM-DD` | `### 2026-02-03` |
| Entry | `- **Task {N}**: {summary} [(details)](path)` | `- **Task 829**: Removed backwards-compatible aliases [(details)](specs/829_.../summaries/...)` |

**Parsing Regex**:
```
Date: ^### (\d{4}-\d{2}-\d{2})$
Entry: ^- \*\*Task (\d+)\*\*: (.+?)(?:\s*\[.*?\]\(.*?\))?$
```

**Update Rules for `/todo`**:
1. Group archived tasks by completion date
2. If date header exists, append entries
3. If date header doesn't exist, create it (keep dates in reverse chronological order)
4. Include optional `[(details)](path)` link if summary artifact exists

### Schema 2: Strategies Section

**Purpose**: Track active experiments and approaches, updated by `/review` command.

**Format**:
```markdown
## Strategies

### Strategy: {Name}

**Status**: {ACTIVE|PAUSED|CONCLUDED|ABANDONED}
**Started**: YYYY-MM-DD
**Hypothesis**: {What we're trying to achieve/test}

**Approach**:
{Description of the approach}

**Outcomes**:
- {Outcome 1}
- {Outcome 2}

**Next Steps**:
- {Next step if ACTIVE/PAUSED}

---
```

**Schema Definition**:

| Element | Pattern | Required |
|---------|---------|----------|
| Strategy header | `### Strategy: {Name}` | Yes |
| Status | `**Status**: {ACTIVE\|PAUSED\|CONCLUDED\|ABANDONED}` | Yes |
| Started | `**Started**: YYYY-MM-DD` | Yes |
| Hypothesis | `**Hypothesis**: {text}` | Yes |
| Approach | `**Approach**:\n{text}` | Optional |
| Outcomes | `**Outcomes**:\n- {items}` | Optional |
| Next Steps | `**Next Steps**:\n- {items}` | Optional (required if ACTIVE/PAUSED) |
| Separator | `---` | Yes (between strategies) |

**Parsing Regex**:
```
Header: ^### Strategy: (.+)$
Status: ^\*\*Status\*\*: (ACTIVE|PAUSED|CONCLUDED|ABANDONED)$
Started: ^\*\*Started\*\*: (\d{4}-\d{2}-\d{2})$
```

**Update Rules for `/review`**:
1. Scan codebase for evidence of strategy progress
2. Update status based on findings
3. Add new outcomes as bullet points
4. Update next steps or archive if concluded

### Schema 3: Ambitions Section

**Purpose**: Document big picture goals, informed by `/review` analysis.

**Format**:
```markdown
## Ambitions

### Ambition: {Name}

**Priority**: {HIGH|MEDIUM|LOW}
**Timeframe**: {SHORT-TERM|MEDIUM-TERM|LONG-TERM|ONGOING}
**Success Criteria**:
- [ ] {Criterion 1}
- [ ] {Criterion 2}
- [x] {Criterion 3 - achieved}

**Description**:
{What we aspire to achieve and why it matters}

**Related Phases**: Phase {N}, Phase {M}

---
```

**Schema Definition**:

| Element | Pattern | Required |
|---------|---------|----------|
| Ambition header | `### Ambition: {Name}` | Yes |
| Priority | `**Priority**: {HIGH\|MEDIUM\|LOW}` | Yes |
| Timeframe | `**Timeframe**: {SHORT-TERM\|MEDIUM-TERM\|LONG-TERM\|ONGOING}` | Yes |
| Success Criteria | `**Success Criteria**:\n- [ ] {items}` | Yes (at least one) |
| Description | `**Description**:\n{text}` | Yes |
| Related Phases | `**Related Phases**: Phase {N}, ...` | Optional |
| Separator | `---` | Yes (between ambitions) |

**Parsing Regex**:
```
Header: ^### Ambition: (.+)$
Priority: ^\*\*Priority\*\*: (HIGH|MEDIUM|LOW)$
Timeframe: ^\*\*Timeframe\*\*: (SHORT-TERM|MEDIUM-TERM|LONG-TERM|ONGOING)$
Criteria: ^- \[([ x])\] (.+)$
```

**Update Rules for `/review`**:
1. Analyze codebase state against success criteria
2. Mark criteria checkboxes when achieved
3. Propose new ambitions based on findings
4. Adjust priority based on current focus

### Migration Plan

**Content to Migrate**:

1. **To Changelog**: No existing content to migrate (will be populated by future `/todo` runs)

2. **To Strategies**: Extract from existing prose:
   - "Representation-First Architecture" approach (lines 62-126)
   - "Indexed MCS Family Approach" (lines 66-77)
   - "CoherentConstruction Approach" (lines 154-172)
   - "Algebraic Approach" (lines 174-188)

3. **To Ambitions**: Extract from existing content:
   - "Proof Quality and Organization" (Phase 1)
   - "Generalization" (Phase 2)
   - "Extension" (Phase 3)
   - "Publication-Ready Package" (Phase 6)
   - The "Key Insight" about representation theorem as core

**Migration Strategy**:
- Extract and restructure content into new sections
- Keep original phase content for detailed task tracking
- Add cross-references between Ambitions and Phases

### Integration with Commands

#### `/todo` Command Updates (Task 834)

Add to Step 5.5 (after roadmap annotation):

```
Step 5.8: Update Changelog Section

For each archived task with status "completed":
1. Extract completion_summary from state.json
2. Group by completion date
3. Find or create date header in Changelog section
4. Append entry: `- **Task {N}**: {summary}`
5. If summary artifact exists, add link
```

**Edit Pattern**:
```bash
# Find existing date header or insert new one
date_header="### ${completion_date}"
if grep -q "^${date_header}$" specs/ROAD_MAP.md; then
  # Append after date header
  old_string="${date_header}\n"
  new_string="${date_header}\n\n- **Task ${N}**: ${summary}\n"
else
  # Insert new date header after "## Changelog"
  old_string="## Changelog\n"
  new_string="## Changelog\n\n${date_header}\n\n- **Task ${N}**: ${summary}\n"
fi
```

#### `/review` Command Updates (Task 835)

Add at start (before codebase analysis):

```
Step 1.5: Load ROADMAP Context

1. Read Strategies section to understand active experiments
2. Read Ambitions section to inform review focus
3. Prioritize analysis areas based on active strategies
```

Add at end (after generating review report):

```
Step N: Update ROADMAP Based on Findings

1. Update strategy statuses based on codebase evidence
2. Add new outcomes to active strategies
3. Mark achieved ambition criteria
4. Propose new ambitions if gaps identified
5. Generate task suggestions based on roadmap analysis
```

## Decisions

1. **Section placement**: New sections go BEFORE "Overview" to establish context before diving into details
2. **Date format**: Use ISO 8601 (YYYY-MM-DD) consistently
3. **Separator**: Use `---` between entries for clear visual separation
4. **Status values**: ACTIVE/PAUSED/CONCLUDED/ABANDONED for strategies; HIGH/MEDIUM/LOW for priority
5. **Timeframe values**: SHORT-TERM/MEDIUM-TERM/LONG-TERM/ONGOING to match existing language
6. **Checkbox criteria**: Use `- [ ]` / `- [x]` for success criteria to enable progress tracking

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking existing `/todo` roadmap parsing | High | New sections have distinct headers, existing patterns unchanged |
| Large ROAD_MAP.md file (~1000+ lines) | Medium | Changelog entries are brief (1 line each), can archive old entries periodically |
| Schema evolution needs | Medium | Document schema version, design for backward compatibility |
| Ambiguous strategy/ambition distinction | Low | Clear definitions: strategy = how (experiment), ambition = what (goal) |

## Appendix

### Search Queries Used
- "Keep A Changelog format specification 2026"
- "project roadmap strategies section documentation best practices"
- "software project long-term vision goals ambitions documentation format"
- "software experimentation strategy tracking active experiments status documentation"

### References
- [Keep A Changelog](https://keepachangelog.com/en/1.1.0/) - Changelog format specification
- [Atlassian Project Roadmap Guide](https://www.atlassian.com/agile/project-management/project-roadmap) - Roadmap best practices
- [Aha! Roadmap Best Practices](https://www.aha.io/roadmapping/guide/roadmap/best-practices) - Roadmap structure guidelines
- [Vision and Scope Documents](https://orangesoft.co/blog/how-to-write-a-vision-and-scope-document) - Vision documentation patterns
- [Scrum Product Vision](https://resources.scrumalliance.org/Article/write-product-vision-statement) - Product vision statement guidelines

## Next Steps

1. Run `/plan 833` to create implementation plan for restructuring ROAD_MAP.md
2. Implementation should:
   - Add three new sections with initial content
   - Migrate existing content to Strategies section
   - Create initial Ambitions from existing phase goals
   - Leave Changelog empty (to be populated by future `/todo` runs)
3. After 833 completes, proceed with dependent tasks 834 and 835
