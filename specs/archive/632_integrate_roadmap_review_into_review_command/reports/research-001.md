# Research Report: Task #632

- **Task**: 632 - Integrate roadmap review into /review command
- **Started**: 2026-01-20T02:06:30Z
- **Completed**: 2026-01-20T02:45:00Z
- **Effort**: 4-6 hours (implementation estimate)
- **Priority**: Medium
- **Dependencies**: None
- **Sources/Inputs**:
  - `.claude/commands/review.md` - Current /review command implementation
  - `.claude/context/core/workflows/review-process.md` - Review workflow documentation
  - `specs/ROAD_MAP.md` - Roadmap structure to parse
  - `specs/TODO.md` - Task list for cross-reference
  - `specs/state.json` - Machine state for cross-reference
  - `specs/reviews/review-2026-01-19.md` - Example review report format
  - `.claude/agents/meta-builder-agent.md` - AskUserQuestion patterns
- **Artifacts**: This report
- **Standards**: report-format.md, subagent-return.md, return-metadata-file.md

## Executive Summary

- The current `/review` command focuses on codebase analysis (sorry counts, code quality, issues) but does not integrate with ROAD_MAP.md
- ROAD_MAP.md has a well-structured format with phases, checkboxes, status tables, and success metrics that can be parsed programmatically
- Cross-referencing can use: TODO.md completed tasks, state.json status data, file existence checks, and sorry count verification
- The AskUserQuestion tool can present recommended tasks for user selection (pattern established in meta-builder-agent.md)
- Implementation requires adding a new step between "Analyze Findings" and "Create Review Report" in the current workflow

## Context & Scope

Task 632 requires modifying the `/review` command to:

1. **Parse** ROAD_MAP.md structure (phases, checkboxes, status tables)
2. **Cross-reference** with TODO.md/state.json and codebase state
3. **Edit** ROAD_MAP.md to annotate completed items
4. **Identify** current goals and path forward
5. **Present** recommended tasks for user selection

This is a "meta" task (modifying the .claude/ system itself), requiring changes to:
- `.claude/commands/review.md` - Add roadmap integration steps

## Findings

### 1. Current /review Command Structure

**Location**: `.claude/commands/review.md`

**Current 8-step flow**:
1. Parse Arguments (scope, --create-tasks flag)
2. Load Review State (`specs/reviews/state.json`)
3. Gather Context (Lean diagnostics, code smells, docs)
4. Analyze Findings (categorize by severity)
5. Create Review Report (`specs/reviews/review-{DATE}.md`)
6. Update Review State (`specs/reviews/state.json`)
7. Create Tasks (if --create-tasks)
8. Git Commit + Output

**Integration point**: Roadmap review should be added as Step 2.5 (after Load Review State, before Gather Context) or as part of Step 4 (Analyze Findings).

### 2. ROAD_MAP.md Structure Analysis

**Format components**:

| Component | Pattern | Example |
|-----------|---------|---------|
| Phase headers | `## Phase {N}: {Title}` | `## Phase 1: Proof Quality and Organization` |
| Task checkboxes | `- [ ] {task}` or `- [x] {task}` | `- [ ] Audit proof dependencies` |
| Status tables | `\| Component \| Status \| Location \|` | Tables with checkmarks or "PROVEN" |
| Priority markers | `(High Priority)`, `(Medium Priority)` | In section headers |
| Subsection numbering | `### {N}.{M} {Title}` | `### 1.1 Proof Economy Improvements` |
| Success metrics | `### Success Metrics` with bullet lists | `- **Lines of proof code**: Target 20% reduction` |

**Key sections**:
- "Current State: What's Been Accomplished" - Already completed work
- "Phase 1-6" - Future work with checkboxes
- "Recommended Execution Order" - Near/Medium/Long term
- "Success Metrics" - Quantifiable targets
- "Open Questions" - Unresolved items

### 3. Cross-Reference Requirements

**Data sources and verification methods**:

| Data Source | Verification Method | What to Check |
|-------------|-------------------|---------------|
| TODO.md | Parse `[COMPLETED]` status | Completed tasks matching roadmap items |
| state.json | Query `status: completed` | Machine-readable task completion |
| Lean files | File existence via Glob | Whether mentioned files exist |
| Sorry counts | `grep -r "sorry" Theories/` | Compare to roadmap assertions |
| Build status | `lake build` (optional) | Build succeeds without errors |
| Theorem existence | MCP lean_local_search | Whether claimed theorems exist |

**Current sorry count**: 4 files with sorries in Metalogic_v2 (found via codebase search)

### 4. Markdown Editing Patterns

**For annotating completed items**:

```markdown
# Before
- [ ] Audit proof dependencies

# After (completed)
- [x] Audit proof dependencies *(Completed: Task 620, 2026-01-20)*

# Or using inline notes
- [x] Audit proof dependencies
  - Note: Completed via task 620 - proof dependency analysis
```

**For updating status tables**:

```markdown
# Before
| **Strong Completeness** | PROVEN | Completeness/StrongCompleteness.lean |

# After (with verification note)
| **Strong Completeness** | PROVEN (verified 2026-01-20) | Completeness/StrongCompleteness.lean |
```

### 5. AskUserQuestion Pattern for Task Recommendation

**From meta-builder-agent.md**:

```json
{
  "question": "Which tasks would you like to create?",
  "header": "Recommended Tasks from Roadmap",
  "options": [
    "Task 1: {title} (High priority, 4 hours)",
    "Task 2: {title} (Medium priority, 2 hours)",
    "All recommended tasks",
    "None - skip task creation"
  ],
  "allow_multiple": true
}
```

**Selection handling**:
- User can select one, multiple, or none
- Each selection triggers `/task "Description"` call
- Created task numbers tracked in review output

### 6. Proposed Workflow Integration

**New Step 2.5: Roadmap Analysis**

```
2.5. Roadmap Integration
  2.5.1 Parse ROAD_MAP.md structure
    - Extract phase headers, checkboxes, status tables
    - Build roadmap_state object with current state

  2.5.2 Cross-reference with project state
    - Query TODO.md for completed tasks
    - Query state.json for status data
    - Check file existence for mentioned paths
    - Verify sorry counts against claims

  2.5.3 Annotate ROAD_MAP.md
    - Mark completed items with [x] and notes
    - Update status tables with verification dates
    - Add completion notes where appropriate

  2.5.4 Identify current goals
    - Find first incomplete items in each phase
    - Match to "Recommended Execution Order" section
    - Prioritize by phase priority markers

  2.5.5 Generate task recommendations
    - Create task descriptions from incomplete items
    - Estimate effort from roadmap hints or default
    - Assign language based on file paths mentioned
```

**Modified Step 5: Create Review Report**

Add "Roadmap Progress" section:

```markdown
## Roadmap Progress

### Completed Since Last Review
- [x] Phase 1.1: Proof Economy Improvements (Task 620)

### Current Focus
- Phase 4: Architecture Optimization - In Progress
- Next milestone: Refactor to make representation_theorem primary export

### Recommended Tasks
(See user selection prompt)
```

**New Step 5.5: User Task Selection**

```
5.5. Present Recommended Tasks
  5.5.1 Display recommendations with AskUserQuestion
  5.5.2 Await user selection
  5.5.3 Create selected tasks via /task command
  5.5.4 Record created task numbers in review report
```

### 7. Implementation Considerations

**Parsing complexity**:
- Markdown parsing requires regex patterns for structure detection
- Status tables have varying column formats
- Checkboxes can be nested under subsections

**Cross-reference challenges**:
- Task titles in TODO.md may not exactly match roadmap items
- Need fuzzy matching or manual mapping
- Some roadmap items span multiple tasks

**Edit safety**:
- Must preserve existing ROAD_MAP.md content
- Use Edit tool with precise old_string/new_string
- Verify edits don't corrupt markdown structure

## Decisions

1. **Integration point**: Add roadmap processing as Step 2.5, before gathering other context
2. **Annotation style**: Use `[x] {item} *(Completed: Task {N}, {DATE})*` format
3. **User interaction**: Use AskUserQuestion with multi-select for task creation
4. **No flag required**: Roadmap review happens on every /review invocation (per task description)
5. **Non-blocking**: Roadmap parsing failures should warn but not halt review

## Recommendations

### Phase 1: Core Integration (4 hours)
1. **Add Step 2.5** to `.claude/commands/review.md` with roadmap parsing
2. **Implement parsing functions** for:
   - Phase headers extraction
   - Checkbox state detection
   - Status table parsing
3. **Add cross-reference logic** for TODO.md and state.json matching

### Phase 2: Annotation and Editing (2 hours)
4. **Implement roadmap editing** to mark completed items
5. **Add completion notes** with task numbers and dates
6. **Verify edit safety** with backup/rollback capability

### Phase 3: Task Recommendation (2 hours)
7. **Generate recommendations** from first incomplete items per phase
8. **Add AskUserQuestion prompt** for user selection
9. **Create tasks** for selected items via `/task` command

### Phase 4: Report Integration (1 hour)
10. **Add "Roadmap Progress" section** to review report format
11. **Include created task numbers** in report
12. **Update review state** with roadmap findings

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Roadmap format changes | Parsing fails silently | Add format validation warnings |
| Fuzzy matching errors | Wrong items marked complete | Require explicit task number references |
| Edit corruption | ROAD_MAP.md damaged | Use precise Edit tool patterns, no regex |
| Long execution time | Review takes >10 minutes | Parallelize cross-reference checks |
| User overwhelmed by recommendations | Too many tasks suggested | Limit to 5-7 highest priority items |

## Appendix

### A. ROAD_MAP.md Structure Reference

```
ROAD_MAP.md
├── # ProofChecker Development Roadmap (header)
├── **Last Updated**: {DATE}
├── **Status**: {summary}
├── ## Overview (purpose)
├── ## Current State: What's Been Accomplished
│   ├── ### Metalogic_v2: Representation-First Architecture
│   │   └── Status tables with | Component | Status | Location |
│   └── ### Syntax and Semantics (etc.)
├── ## Phase 1: {Title} ({Priority})
│   ├── ### 1.1 {Subtopic}
│   │   ├── **Tasks**:
│   │   │   ├── - [ ] {uncompleted item}
│   │   │   └── - [x] {completed item}
│   │   └── **Expected Impact**: ...
│   └── ### 1.2 {Subtopic} ...
├── ## Phase 2-6: ... (similar structure)
├── ## Recommended Execution Order
│   ├── ### Near Term (Next 2-4 weeks)
│   ├── ### Medium Term (1-3 months)
│   └── ### Long Term (3-6 months)
├── ## Success Metrics
└── ## Open Questions
```

### B. Regex Patterns for Parsing

```regex
# Phase header
/^## Phase (\d+): (.+?)(?:\s*\((.+)\))?$/

# Checkbox (incomplete)
/^(\s*)- \[ \] (.+)$/

# Checkbox (completed)
/^(\s*)- \[x\] (.+)$/

# Status table row
/^\| (.+?) \| (.+?) \| (.+?) \|$/

# Subsection
/^### (\d+\.\d+) (.+)$/
```

### C. Example AskUserQuestion Payload

```json
{
  "question": "The roadmap analysis identified these potential tasks. Which would you like to create?",
  "header": "Roadmap Task Recommendations",
  "options": [
    "1. Audit proof dependencies (Phase 1.1, ~4 hours, lean)",
    "2. Create domain-specific tactics (Phase 1.1, ~3 hours, lean)",
    "3. Visualize import graph (Phase 1.2, ~2 hours, general)",
    "All recommended tasks",
    "Skip task creation"
  ],
  "allow_multiple": true
}
```

### D. Cross-Reference Data Structures

```typescript
interface RoadmapState {
  phases: Phase[];
  currentStatus: string;
  lastUpdated: string;
}

interface Phase {
  number: number;
  title: string;
  priority: "High" | "Medium" | "Low";
  sections: Section[];
}

interface Section {
  number: string;  // "1.1", "1.2", etc.
  title: string;
  checkboxes: Checkbox[];
  statusTables: StatusTable[];
}

interface Checkbox {
  text: string;
  completed: boolean;
  indent: number;
  completionNote?: string;
}

interface CrossReferenceResult {
  matchedTasks: Array<{
    roadmapItem: Checkbox;
    todoTask: TaskEntry;
    confidence: "exact" | "fuzzy" | "suggested";
  }>;
  unmatchedRoadmapItems: Checkbox[];
  codebaseVerifications: Array<{
    claim: string;
    verified: boolean;
    evidence: string;
  }>;
}
```
