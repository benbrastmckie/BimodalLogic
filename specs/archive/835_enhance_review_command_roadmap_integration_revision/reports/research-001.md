# Research Report: Task #835

**Task**: enhance_review_command_roadmap_integration_revision
**Date**: 2026-02-03
**Focus**: review command integration with roadmap

## Summary

The current /review command has substantial ROADMAP.md integration for **reading** roadmap state (Section 2.5) and **annotating** completed items (Section 2.5.2-2.5.3), but lacks the ability to **revise** the roadmap based on review findings. Additionally, the task description calls for "Strategies and Ambitions sections" which do not currently exist in `specs/ROAD_MAP.md`. The /todo command already has task suggestion infrastructure (Section 7.5) that can be adapted for /review.

## Findings

### 1. Current /review Command Structure

**Location**: `.claude/commands/review.md` (777 lines)

**Current ROADMAP Integration (Section 2.5)**:
- Loads `@.claude/context/core/formats/roadmap-format.md` for parsing patterns
- Parses `specs/ROAD_MAP.md` to extract:
  - Phase headers: `## Phase {N}: {Title} ({Priority})`
  - Checkboxes: `- [ ]` (incomplete) and `- [x]` (complete)
  - Status tables: Pipe-delimited rows with Component/Status/Location
  - Priority markers: `(High Priority)`, `(Medium Priority)`, `(Low Priority)`
- Cross-references roadmap items with project state (TODO.md, state.json)
- Annotates completed roadmap items with task completion dates

**Current Output** (Section 4, Review Report):
- Includes "Roadmap Progress" section showing:
  - Completed Since Last Review
  - Current Focus (phase, priority, progress)
  - Recommended Next Tasks

**Gap**: No **writing back** to ROADMAP.md with new findings, status updates, or proposed ambitions.

### 2. ROADMAP.md Structure Analysis

**File**: `specs/ROAD_MAP.md` (939 lines)

**Current Sections**:
```
## Overview
## Current State: What's Been Accomplished
  ### Metalogic_v2: Representation-First Architecture (Boneyard)
  ### Bimodal/Metalogic: Universal Parametric Representation Theorem
## Phase 0: Complete Core Proofs (High Priority)
## Phase 1: Proof Quality and Organization (High Priority)
## Phase 2: Generalization (Medium Priority)
## Phase 3: Extensions (Medium Priority)
## Phase 4: Architecture Optimization (High Priority)
## Phase 5: Managing Remaining Sorries (Low Priority)
## Phase 6: Polish and Publication (Low Priority Now, High Later)
## Recommended Execution Order
## Success Metrics
## Open Questions
## Active Metalogic Tasks
## Conclusion
```

**Missing Sections** (per task description):
- `## Strategies` - Does not exist
- `## Ambitions` - Does not exist
- `## Changelog` - Does not exist (mentioned as needing Task 833)

**Note**: The /todo command (Section 7.5.2) already checks for these sections:
```bash
if grep -q "^## Ambitions" specs/ROAD_MAP.md; then ...
if grep -q "^## Strategies" specs/ROAD_MAP.md; then ...
```

### 3. /learn Command Task Suggestion Pattern

**Location**: `.claude/commands/learn.md`

**Pattern**: After scanning tags and creating tasks, outputs a "Next Steps" section:
```
**Next Steps**:
1. Review tasks in TODO.md
2. Run `/research 650` to begin
3. Progress through /research -> /plan -> /implement cycle
```

**Relevance**: The task description asks for "task suggestions based on findings (like /learn)". This pattern provides a model for the output format.

### 4. /todo Command Task Suggestion Pattern (More Comprehensive)

**Location**: `.claude/commands/todo.md` (Section 7.5)

**Pattern**: Generates 3-5 prioritized task suggestions based on:
1. Unblocked tasks (ready to start)
2. Stale tasks (not_started for >7 days)
3. Ambition progress (if section exists)
4. Active strategies (if section exists)
5. Follow-up suggestions from completed tasks

**Output Format**:
```
## Task Suggestions

Based on analysis of active tasks, ROADMAP, and recent completions:

### Recommended Next Steps

1. **Ready to start**: Task {N} ({name}) - Run `/research {N}` to begin
2. **Ready to plan**: Task {N} ({name}) - Run `/plan {N}` to create plan
3. **Stale task**: Task {N} ({name}) has been pending {N} days
...

Active tasks: {N} | Completed today: {M} | Repository health: {status}
```

### 5. Checkpoint-Based Execution Pattern

**Location**: `.claude/context/core/workflows/command-lifecycle.md`

**Standard Pattern**:
- Stage 1-5, 8: Orchestrator stages
- Stage 6-7: Subagent stages

**Current /review uses**:
- Section 1-4: Analysis and report generation
- Section 5: Task creation (interactive or auto)
- Section 6: Registry updates
- Section 7: Git commit
- Section 8: Output

**Note**: The /review command does NOT currently delegate to a subagent. All execution is inline in the command file. The context file `review-process.md` mentions a "reviewer subagent" but this is not implemented in the actual command.

### 6. Roadmap Format Standards

**Location**: `.claude/context/core/formats/roadmap-format.md`

**Key Parsing Patterns**:
- Phase headers: `^## Phase (\d+): (.+?) \((\w+) Priority\)`
- Checkboxes: `- \[ \]` and `- \[x\]`
- Completion annotation: `- [x] {item} *(Completed: Task {N}, {DATE})*`

**Location**: `.claude/context/core/patterns/roadmap-update.md`

**Key Update Patterns**:
- Confidence levels: High (auto-annotate), Medium (suggest), Low (report only)
- Safety rules: Never remove content, skip already-annotated items
- Scoring factors for recommendations

### 7. Proposed Strategies and Ambitions Sections

Since these sections don't exist, we need to define their structure. Based on the existing ROADMAP format patterns:

**Proposed Strategies Section**:
```markdown
## Strategies

### {Strategy Name}
**Status**: ACTIVE | PAUSED | COMPLETED
**Started**: {DATE}
**Priority**: High | Medium | Low
**Next Steps**:
- [ ] {next step 1}
- [ ] {next step 2}

**Description**: {strategy description}

**Progress**:
- [x] {completed milestone}
- [ ] {pending milestone}
```

**Proposed Ambitions Section**:
```markdown
## Ambitions

Long-term goals and quality targets for the project.

### {Ambition Name}
**Target**: {specific measurable target}
**Deadline**: {optional deadline}
**Criteria**:
- [ ] {success criterion 1}
- [ ] {success criterion 2}

**Rationale**: {why this matters}
```

### 8. Skill vs Inline Execution Decision

**Current State**: /review command executes entirely inline (no skill delegation)

**Options**:
1. **Keep inline, extend existing logic**: Simpler, maintains consistency with current pattern
2. **Create skill-reviewer**: Would follow agent pattern but adds complexity

**Recommendation**: Keep inline execution, extend existing logic. Rationale:
- /review doesn't require specialized tools beyond what's already allowed
- No long-running operations that benefit from background execution
- Pattern consistency with current implementation
- Skill creation adds overhead without clear benefit

### 9. Integration Points for Roadmap Revision

**Current Step 2.5**: Loads roadmap, extracts state, cross-references with project state
**Current Step 2.5.3**: Annotates completed items in roadmap

**Proposed New Steps**:

1. **Step 1.5 (New)**: Load and analyze ROADMAP.md context
   - Read Strategies section (if exists), extract ACTIVE strategies
   - Read Ambitions section (if exists), extract unchecked criteria
   - Use this context to inform the review focus

2. **Step 6.5 (New)**: Revise ROADMAP.md based on review findings
   - Update strategy statuses based on review findings
   - Propose new ambitions based on discovered gaps
   - Add notes about new gaps identified
   - Update "Active Metalogic Tasks" section with newly created tasks

3. **Step 8.5 (New)**: Output task suggestions
   - Similar to /todo Section 7.5
   - Based on review findings, not just existing state

## Recommendations

### 1. Add Roadmap Loading at Start (Step 1.5)

Insert new section after Step 1 (Parse Arguments):

```markdown
### 1.5. Load ROADMAP Context

**Purpose**: Load ROADMAP.md context (Strategies and Ambitions) to inform review focus.

**Context**: Load @.claude/context/core/formats/roadmap-format.md for section patterns.

1. Check for Strategies section existence
2. If exists, extract ACTIVE strategies with their next steps
3. Check for Ambitions section existence
4. If exists, extract unchecked criteria
5. Store in review_context for use in analysis

Build `roadmap_context` structure:
```json
{
  "strategies": [{
    "name": "Strategy Name",
    "status": "ACTIVE",
    "next_steps": ["step 1", "step 2"]
  }],
  "ambitions": [{
    "name": "Ambition Name",
    "unchecked_criteria": ["criterion 1"]
  }]
}
```

**Fallback**: If sections don't exist, log info message and continue without roadmap context.
```

### 2. Add Roadmap Revision Step (Step 6.5)

Insert new section after Step 6 (Update Registries):

```markdown
### 6.5. Revise ROADMAP.md Based on Findings

**Condition**: Review findings suggest roadmap updates needed

**6.5.1. Strategy Status Updates**

For each ACTIVE strategy in roadmap_context:
- Check if review findings relate to this strategy
- If strategy goals are met by current codebase state, propose status change to COMPLETED
- If strategy is blocked, propose status change to PAUSED

**6.5.2. Propose New Ambitions**

If review identified significant gaps not covered by existing ambitions:
- Formulate ambition proposal with criteria
- Present to user via AskUserQuestion for approval
- If approved, add to Ambitions section

**6.5.3. Update Active Tasks Section**

If "Active Metalogic Tasks" section exists:
- Remove completed tasks
- Add newly created tasks from Section 5
- Update task statuses

**6.5.4. Add Gap Notes (Optional)**

If review identified documentation gaps or architectural concerns:
- Add to "Open Questions" section or create "Review Notes" subsection
```

### 3. Add Task Suggestions Output (Step 8.5)

Insert new section at end of Step 8 (Output):

```markdown
### 8.5. Task Suggestions

Based on review findings, generate task suggestions following /todo pattern:

**Sources**:
1. Issues identified in review (not converted to tasks)
2. Incomplete roadmap items from Strategies/Ambitions
3. Stale tasks in TODO.md
4. Follow-up opportunities from completed phases

**Output Format**:
```
## Task Suggestions

Based on review findings:

### Recommended Next Steps

1. {suggestion with rationale}
2. {suggestion with rationale}
3. {suggestion with rationale}

---

Review summary: {critical}/{high}/{medium}/{low} issues | Tasks created: {N}
```
```

### 4. Define Strategies and Ambitions Format (Prerequisite)

This task requires the Strategies and Ambitions sections to exist. Options:

**Option A**: Create sections as part of this task
**Option B**: Create a prerequisite task (or note dependency on existing task)

**Recommendation**: Check if Task 833 addresses this. The /todo command references "requires Task 833" for Changelog section. A similar prerequisite task may be needed for Strategies/Ambitions.

### 5. Update Review Report Format (Step 4)

Extend the review report template to include:

```markdown
## Roadmap Context

### Active Strategies
{List ACTIVE strategies that informed this review}

### Ambition Progress
{Progress on ambition criteria}

## Roadmap Revisions

### Strategy Updates
- {Strategy}: {OLD_STATUS} -> {NEW_STATUS} (reason)

### Proposed Ambitions
- {New ambition if gaps identified}

### Task Suggestions

1. {suggestion}
2. {suggestion}
```

## Dependencies

1. **Task 833** (or similar): May need to implement Strategies/Ambitions/Changelog sections in ROADMAP.md first
2. **roadmap-format.md**: Should be extended to document Strategies/Ambitions section format

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Strategies/Ambitions sections don't exist | Feature partially unusable | Graceful fallback with info message; document section creation |
| Review becomes too long with all additions | User experience degraded | Make roadmap revision opt-in via flag (--update-roadmap) |
| Circular dependency with roadmap updates | Potential for inconsistent state | Clear separation of read phase vs write phase |
| Task suggestions overlap with /todo | User confusion | Differentiate: /review = findings-based, /todo = state-based |

## Implementation Approach

**Recommended Strategy**: Incremental extension of existing /review command

1. **Phase 1**: Add Step 1.5 (Load ROADMAP context) - read-only, low risk
2. **Phase 2**: Add Step 8.5 (Task suggestions output) - output-only, low risk
3. **Phase 3**: Add Step 6.5 (Revise ROADMAP) - write operations, higher complexity

**Estimated Effort**: 4-6 hours across phases

## References

- `.claude/commands/review.md` - Current review command implementation
- `.claude/commands/todo.md` - Task suggestion pattern (Section 7.5)
- `.claude/commands/learn.md` - Next Steps output pattern
- `.claude/context/core/workflows/command-lifecycle.md` - Checkpoint-based execution pattern
- `.claude/context/core/formats/roadmap-format.md` - ROADMAP parsing patterns
- `.claude/context/core/patterns/roadmap-update.md` - ROADMAP update patterns
- `specs/ROAD_MAP.md` - Current roadmap structure

## Next Steps

1. Run `/plan 835` to create implementation plan with detailed phases
2. Consider creating prerequisite task for Strategies/Ambitions section structure if not covered by Task 833
3. Review Task 833 status to understand Changelog section implementation
