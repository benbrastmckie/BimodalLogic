# Research Report: Task #877

**Task**: 877 - Update planner-agent to generate phase dependencies
**Date**: 2026-02-11
**Focus**: Update planner-agent.md Stage 5 plan template to include Dependencies field for each phase

## Summary

The planner-agent.md needs updates to generate the new `Dependencies` field added in task 876. Two primary changes are needed: (1) add dependency analysis to Stage 4 during task decomposition, and (2) update the Stage 5 plan template to include the `Dependencies` field in phase format.

## Findings

### Current State Analysis

#### planner-agent.md Stage 4 (Task Decomposition)

Located at lines 136-163, Stage 4 currently covers:
1. Understand the Full Scope
2. Identify Major Phases
3. Break Into Small Tasks
4. Define Dependencies
5. Estimate Effort

**Key observation**: Step 4 "Define Dependencies" already exists conceptually but is task-level, not phase-level. The content mentions:
- "What must be done first?"
- "What blocks what?"
- "What's the critical path?"

However, this guidance is not translated into the plan template output. The dependency analysis happens mentally but isn't captured in the artifact.

#### planner-agent.md Stage 5 (Plan Template)

Located at lines 165-247, the phase template currently shows:
```markdown
### Phase 1: {Name} [NOT STARTED]

**Goal**: {What this phase accomplishes}

**Tasks**:
- [ ] {Task 1}
- [ ] {Task 2}

**Timing**: {X hours}

**Files to modify**:
- `path/to/file` - {what changes}

**Verification**:
- {How to verify phase is complete}
```

**Missing**: The `Dependencies` field is not present in this template.

### plan-format.md Phase Dependencies Standard (Task 876)

Task 876 added the Dependencies field to plan-format.md (lines 76-116):

```markdown
### Phase Dependencies Notation

The `Dependencies` field declares which phases must complete before this phase can start.

**Syntax**:
- `None` - Phase can start immediately (no blockers)
- `Phase 1` - Phase blocked until Phase 1 completes
- `Phase 1, Phase 3` - Phase blocked until both Phase 1 and Phase 3 complete

### Phase 1: Setup [NOT STARTED]
- **Dependencies:** None
- **Goal:** Initialize project structure
```

**Field placement**: After phase heading, before `Goal` field.

### task-breakdown.md Dependency Patterns

The task-breakdown.md document (lines 48-58, 75-95) establishes dependency patterns:

**Process Section** (lines 48-58):
```
### 4. Define Dependencies
- What must be done first?
- What can be done in parallel?
- What blocks what?
- What's the critical path?
```

**Template Section** (lines 75-95) shows task-level dependencies:
```markdown
- [ ] **Task 1.1:** {Description}
  - **Dependencies:** {none / task X}

- [ ] **Task 1.2:** {Description}
  - **Dependencies:** {task 1.1}
```

**Phase-level dependency example** (line 95):
```markdown
- [ ] **Task 2.1:** {Description}
  - **Dependencies:** {phase 1 complete}
```

### Task 876 Implementation Plan (Reference)

The task 876 plan demonstrates the format in practice:
```markdown
### Phase 1: Update plan-format.md [IN PROGRESS]

- **Dependencies**: None
- **Goal**: Add Dependencies field...

### Phase 2: Update artifact-formats.md [NOT STARTED]

- **Dependencies**: Phase 1
- **Goal**: Add Dependencies field...

### Phase 3: Verify Consistency and Document [NOT STARTED]

- **Dependencies**: Phase 1, Phase 2
- **Goal**: Verify both files are consistent...
```

### Dependency Analysis Patterns to Implement

Based on task-breakdown.md and plan-format.md, the planner agent should analyze:

1. **Sequential dependencies**: Phase N outputs become Phase N+1 inputs
   - Example: "Create schema" before "Build models" before "Add API endpoints"

2. **Parallel opportunities**: Independent phases that can run concurrently
   - Example: "Documentation" and "Core Implementation" can run after "Setup"

3. **Convergence points**: Phases that require multiple predecessors
   - Example: "Integration Testing" depends on both "Frontend" and "Backend"

4. **Input/Output mapping**: Identify file/artifact flow between phases
   - Phase 1 creates file X -> Phase 2 modifies file X -> Dependencies: Phase 1

## Recommendations

### 1. Update Stage 4: Add Explicit Dependency Analysis

Insert after step 4 "Define Dependencies" a specific sub-step for generating the `Dependencies` field:

```markdown
4. **Define Dependencies**
   - What must be done first?
   - What blocks what?
   - What's the critical path?
   - **Generate Dependencies field**: For each phase, determine:
     - `None` if phase has no blockers (typically Phase 1)
     - `Phase {N}` if blocked by a single prior phase
     - `Phase {N}, Phase {M}` if blocked by multiple prior phases
   - **Identify parallel opportunities**: Phases with same predecessor can potentially run in parallel
```

### 2. Update Stage 5: Add Dependencies Field to Plan Template

Update the phase template (around line 214) to include Dependencies:

```markdown
### Phase 1: {Name} [NOT STARTED]

- **Dependencies**: None
- **Goal**: {What this phase accomplishes}

**Tasks**:
- [ ] {Task 1}
- [ ] {Task 2}

**Timing**: {X hours}

**Files to modify**:
- `path/to/file` - {what changes}

**Verification**:
- {How to verify phase is complete}
```

### 3. Add Dependency Generation Guidance

Add a new subsection in Stage 4 or as a note in Stage 5:

```markdown
#### Phase Dependency Generation

Analyze phase inputs/outputs to generate Dependencies:

| If Phase... | Then Dependencies = |
|-------------|---------------------|
| Has no prerequisites | `None` |
| Uses output from Phase N | `Phase N` |
| Uses outputs from Phases N and M | `Phase N, Phase M` |
| First phase in plan | Always `None` |

**Input/Output mapping heuristic**:
- If Phase B modifies files created by Phase A -> B depends on A
- If Phase B requires artifacts from Phase A -> B depends on A
- If Phase B tests functionality from Phase A -> B depends on A
```

### 4. Update Verification in Stage 6

Add verification that Dependencies field exists in generated plans:

```markdown
#### 6a. Verify Required Metadata Fields

Re-read the plan file and verify these fields exist (per plan-format.md):
- `- **Status**: [NOT STARTED]` - **REQUIRED**
- `- **Dependencies**: ...` - **REQUIRED** for each phase (None, Phase N, or Phase N, Phase M)
- `- **Task**: {N} - {title}` - Task identifier
...
```

## Implementation Scope

### Files to Modify

1. **`.claude/agents/planner-agent.md`**
   - Stage 4 (lines 136-163): Add explicit dependency analysis guidance
   - Stage 5 (lines 165-247): Update phase template to include Dependencies field
   - Stage 6 (lines 249-301): Add Dependencies field to verification checklist

### Estimated Changes

- Stage 4: ~10-15 lines of new guidance
- Stage 5: ~2 lines per phase template (add Dependencies field)
- Stage 6: ~3 lines for verification update

## References

- `.claude/agents/planner-agent.md` - Target file for updates
- `.claude/context/core/workflows/task-breakdown.md` - Dependency patterns (lines 48-58, 75-95)
- `.claude/context/core/formats/plan-format.md` - Dependencies field standard (lines 76-116)
- `.claude/rules/artifact-formats.md` - Artifact template reference
- `specs/876_add_phase_dependency_field_plan_format_standards/plans/implementation-001.md` - Live example of format

## Next Steps

1. Run `/plan 877` to create implementation plan based on these findings
2. Plan should include 2-3 phases:
   - Phase 1: Update Stage 4 with dependency analysis guidance
   - Phase 2: Update Stage 5 plan template with Dependencies field
   - Phase 3: Update Stage 6 verification checklist
