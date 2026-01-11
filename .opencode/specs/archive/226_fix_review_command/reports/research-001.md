# Research Report: Fix /review Command Issues

**Task**: 226
**Created**: 2025-12-29
**Status**: Research Complete
**Priority**: High
**Language**: markdown

## Executive Summary

This research analyzes 5 critical issues with the /review command implementation and proposes architectural solutions following existing system patterns. Root cause analysis reveals that all issues stem from incomplete integration with the command-lifecycle.md pattern and status-sync-manager delegation. The /review command was created before these standards were established, resulting in gaps in project numbering, task creation, summary formatting, verbosity control, and context file organization.

**Key Findings**:
1. **Project numbering bug**: /review Stage 1 reads next_project_number but doesn't use it (hardcoded "codebase_review")
2. **Missing task creation**: /review creates review project but no matching TODO.md task entry
3. **Summary lacks actionable follow-ups**: Follow-up tasks listed as prose, not formatted for /task invocation
4. **Excessive verbosity**: Reviewer returns verbose metrics and findings to orchestrator (bloats context)
5. **Context file redundancy**: review.md duplicates content from command-lifecycle.md and status-markers.md

**Estimated Effort**: 6-8 hours total (2h per issue 1-2, 1h per issue 3-5)

## Issue 1: Project Numbering Bug

### Root Cause Analysis

**Evidence from review.md Stage 1 (lines 60-69)**:
```markdown
4. Read next_project_number from state.json
5. Generate project path: .opencode/specs/{number}_codebase_review
```

**Evidence from actual execution (task 225)**:
- state.json shows next_project_number: 227 (before review)
- Review created directory: 225_codebase_review
- Task 225 already exists in TODO.md (different task)
- Result: Directory number collision

**Root Cause**: /review Stage 1 reads next_project_number from state.json (line 60) but the reviewer subagent receives hardcoded project_path ".opencode/specs/{number}_codebase_review" where {number} is NOT replaced with actual next_project_number. The reviewer creates the directory with whatever number is in the path string.

**Evidence from reviewer.md (lines 36-38)**:
```markdown
<parameter name="project_path" type="string">
  Project directory path for artifact creation (e.g., .opencode/specs/207_codebase_review)
</parameter>
```

The project_path is passed as a string but /review Stage 1 doesn't actually substitute next_project_number into the path before passing to reviewer.

### Proposed Solution

**Fix Location**: `.opencode/command/review.md` Stage 1 (lines 60-69)

**Current Code** (conceptual):
```
4. Read next_project_number from state.json
5. Generate project path: .opencode/specs/{number}_codebase_review
```

**Fixed Code**:
```
4. Read next_project_number from state.json
5. Validate next_project_number is valid integer
6. Generate project path: .opencode/specs/{next_project_number}_codebase_review
   Example: If next_project_number = 227, path = .opencode/specs/227_codebase_review
7. Pass actual project_path to reviewer (not template string)
```

**Integration Points**:
- Follows command-lifecycle.md Stage 1 (Preflight) pattern for reading state.json
- Aligns with artifact-management.md project numbering rules (lines 40-46)
- Ensures reviewer receives actual path, not template

**Validation**:
- Verify next_project_number is positive integer
- Verify generated path doesn't already exist (collision detection)
- If collision: Increment next_project_number and retry (or fail with clear error)

**Estimated Effort**: 2 hours
- 1h: Update review.md Stage 1 with proper path generation
- 0.5h: Add validation and collision detection
- 0.5h: Test with actual /review execution

## Issue 2: Missing Task Creation

### Root Cause Analysis

**Evidence from TODO.md**:
- Task 225 exists: "Fix systematic status-sync-manager TODO.md update failures"
- No task entry for review project 225_codebase_review
- Review summary exists at .opencode/specs/225_codebase_review/summaries/review-summary.md
- state.json shows project 225 in completed_projects (lines 180-185)

**Root Cause**: /review command creates review project directory and summary artifact but does NOT create a corresponding task entry in TODO.md. The review project exists in state.json completed_projects but has no TODO.md representation.

**Expected Behavior** (from command-lifecycle.md):
- All projects should have corresponding TODO.md task entries
- Task status should match project status (e.g., [COMPLETED] for completed review)
- Task should link to review summary artifact

**Evidence from review.md Stage 7 (Postflight)**:
- Lines 309-360: Delegates to status-sync-manager for state updates
- Updates TODO.md with created tasks (from identified_tasks)
- Does NOT create task for review project itself
- Only creates tasks for follow-up work identified during review

### Proposed Solution

**Fix Location**: `.opencode/command/review.md` Stage 7 (Postflight)

**Current Behavior**:
```
1. If status == "completed":
   a. Prepare state update payload for status-sync-manager:
      - validated_artifacts: All artifacts from reviewer return
      - review_metrics: Metrics from reviewer return
      - created_tasks: Task numbers from Stage 6 CreateTasks
      - project_path: Review project directory path
      - review_scope: Scope from input
   b. Delegate to status-sync-manager for atomic update:
      - Update TODO.md with created tasks (follow-up tasks only)
      - Update state.json (increment next_project_number, add task entries)
      - Create project state.json
```

**Fixed Behavior**:
```
1. If status == "completed":
   a. Create TODO.md task entry for review project:
      - Task number: Same as project number (e.g., 225)
      - Status: [COMPLETED]
      - Title: "Codebase Review - {scope}"
      - Completed timestamp: Review completion timestamp
      - Link to review summary artifact
      - Priority: High (reviews are high-priority maintenance)
      - Language: markdown
   b. Prepare state update payload for status-sync-manager:
      - validated_artifacts: All artifacts from reviewer return
      - review_metrics: Metrics from reviewer return
      - created_tasks: Task numbers from Stage 6 + review task number
      - project_path: Review project directory path
      - review_scope: Scope from input
      - review_task_number: Project number (for TODO.md entry)
   c. Delegate to status-sync-manager for atomic update:
      - Update TODO.md with review task entry (status: completed)
      - Update TODO.md with created follow-up tasks
      - Update state.json (increment next_project_number, add all task entries)
      - Create project state.json
```

**Task Entry Format**:
```markdown
### 225. Codebase Review - Full
- **Effort**: N/A (review operation)
- **Status**: [COMPLETED]
- **Started**: 2025-12-29
- **Completed**: 2025-12-29
- **Priority**: High
- **Language**: markdown
- **Review Summary**: [Review Summary](.opencode/specs/225_codebase_review/summaries/review-summary.md)
- **Scope**: Full codebase (Lean code, documentation, tests)
- **Findings**: 6 sorry, 11 axioms, 11 build errors, 87.5% test coverage
- **Registries Updated**: IMPLEMENTATION_STATUS, SORRY_REGISTRY, TACTIC_REGISTRY, FEATURE_REGISTRY
- **Description**: Comprehensive codebase review completed. Updated all 4 registries with accurate counts. Identified 5 follow-up tasks for build errors and documentation.
```

**Integration Points**:
- Follows status-markers.md format for completed tasks
- Aligns with artifact-management.md TODO.md format (lines 116-139)
- Uses status-sync-manager for atomic TODO.md + state.json updates
- Review task number matches project number (consistency)

**Validation**:
- Verify review task number doesn't already exist in TODO.md
- If collision: Use next available task number (increment)
- Verify review summary artifact exists before linking

**Estimated Effort**: 2 hours
- 1h: Update review.md Stage 7 to create review task entry
- 0.5h: Update status-sync-manager delegation payload
- 0.5h: Test with actual /review execution

## Issue 3: Summary Lacks Actionable Follow-ups

### Root Cause Analysis

**Evidence from review-summary.md (lines 49-53)**:
```markdown
## Follow-ups

- **Task 225-1**: Fix 6 noncomputable errors in Perpetuity/Principles.lean and AesopRules.lean (Priority: High, Estimated: 1 hour)
- **Task 225-2**: Fix 5 build errors in ProofSearch.lean (dependent elimination, List.qsort, termination_by) (Priority: High, Estimated: 4 hours)
- **Task 225-3**: Complete SoundnessLemmas.lean temporal_duality case after soundness theorem (Priority: Medium, Estimated: 2-3 hours)
```

**Problem**: Follow-up tasks are listed as prose with task numbers like "225-1", "225-2" which don't exist in TODO.md. User cannot invoke `/task 225-1` because these are not real task numbers.

**Root Cause**: Reviewer creates follow-up task descriptions but doesn't format them for easy /task invocation. The identified_tasks array (returned to /review command) contains proper task descriptions, but the review summary artifact formats them as prose with fake task numbers.

**Evidence from reviewer.md (lines 215-221)**:
```markdown
"identified_tasks": [
  {
    "description": "Fix {N} sorry statements in {file}",
    "priority": "high",
    "language": "lean"
  }
]
```

The identified_tasks array has proper format for /task creation, but review summary doesn't reference actual task numbers created by /review Stage 6.

### Proposed Solution

**Fix Location**: `.opencode/agent/subagents/reviewer.md` Step 4 (lines 123-157)

**Current Behavior**:
```markdown
- Follow-ups: Bullet list of created tasks with priorities
```

Review summary lists tasks with fake numbers (225-1, 225-2) that don't exist.

**Fixed Behavior**:
```markdown
- Follow-ups: Bullet list of created tasks with ACTUAL task numbers
```

**Implementation Approach**:

**Option A: Two-Pass Approach** (Recommended)
1. Reviewer returns identified_tasks array to /review command
2. /review Stage 6 creates tasks and collects actual task numbers
3. /review passes created_task_numbers back to reviewer (or updates summary directly)
4. Review summary references actual task numbers

**Option B: Placeholder Approach**
1. Reviewer creates summary with placeholders: "Task {TBD-1}", "Task {TBD-2}"
2. /review Stage 6 creates tasks and gets actual numbers
3. /review Stage 7 updates review summary to replace placeholders with actual numbers
4. Example: "Task {TBD-1}" → "Task 227"

**Recommended: Option B (Simpler)**

**Updated Review Summary Format**:
```markdown
## Follow-ups

Created 5 follow-up tasks to address findings:

- **Task 227**: Fix 6 noncomputable errors in Perpetuity/Principles.lean and AesopRules.lean (Priority: High, Estimated: 1 hour)
  - Invoke: `/task 227` to view details or `/implement 227` to execute
  
- **Task 228**: Fix 5 build errors in ProofSearch.lean (Priority: High, Estimated: 4 hours)
  - Invoke: `/task 228` to view details or `/implement 228` to execute
  
- **Task 229**: Complete SoundnessLemmas.lean temporal_duality case (Priority: Medium, Estimated: 2-3 hours)
  - Invoke: `/task 229` to view details or `/implement 229` to execute

All tasks created in TODO.md and ready for execution.
```

**Integration Points**:
- /review Stage 6 creates tasks and collects task numbers
- /review Stage 7 updates review summary with actual task numbers
- Follows artifact-management.md summary standards (lines 84-107)
- Provides clear invocation instructions for users

**Validation**:
- Verify all task numbers in summary exist in TODO.md
- Verify task numbers are sequential
- Verify summary updated before git commit

**Estimated Effort**: 1 hour
- 0.5h: Update review.md Stage 7 to update summary with task numbers
- 0.5h: Test with actual /review execution

## Issue 4: Excessive Verbosity

### Root Cause Analysis

**Evidence from reviewer.md return format (lines 176-230)**:
```json
{
  "status": "completed",
  "summary": "Codebase review completed. Found {sorry_count} sorry statements, {axiom_count} axioms, {build_error_count} build errors. Identified {undocumented_tactic_count} undocumented tactics and {missing_feature_count} missing features. Created {task_count} tasks.",
  "artifacts": [...],
  "metadata": {...},
  "errors": [],
  "next_steps": "Review findings and address high-priority tasks",
  "identified_tasks": [...],
  "metrics": {
    "sorry_count": 10,
    "axiom_count": 11,
    "build_errors": 3,
    "undocumented_tactics": 8,
    "missing_features": 3,
    "tasks_created": 5
  }
}
```

**Problem**: Reviewer returns verbose metrics object (6 fields) and identified_tasks array (potentially 10+ tasks with full descriptions) to orchestrator. This bloats orchestrator context window.

**Root Cause**: Reviewer follows old return format pattern (pre-metadata-passing standards). The metrics and identified_tasks should be in artifacts (review summary file), not in return object.

**Evidence from artifact-management.md (lines 166-180)**:
```markdown
### Core Pattern

Subagents return artifact links + brief summaries (metadata) to calling agents, NOT full artifact content.

1. Subagent creates artifact (research report, implementation plan, code files, etc.)
2. Subagent validates artifact (exists, non-empty, within token limits)
3. Subagent returns to caller:
   - artifacts array: List of artifact objects with type, path, summary fields
   - summary field: Brief metadata summary (<100 tokens, ~400 characters)
   - Full artifact content stays in files, NOT in return object
```

**Current Verbosity**:
- summary field: ~50 tokens (acceptable)
- metrics object: ~30 tokens (should be in artifact)
- identified_tasks array: ~200-500 tokens (should be in artifact)
- Total: ~280-580 tokens (excessive)

**Target Verbosity**:
- summary field: ~50 tokens (brief findings)
- artifacts array: 5 artifact objects (~50 tokens)
- Total: ~100 tokens (95% reduction)

### Proposed Solution

**Fix Location**: `.opencode/agent/subagents/reviewer.md` Step 5 (lines 160-240)

**Current Return Format**:
```json
{
  "summary": "Codebase review completed. Found 10 sorry, 11 axioms, 3 build errors. Identified 8 undocumented tactics and 3 missing features. Created 5 tasks.",
  "metrics": {
    "sorry_count": 10,
    "axiom_count": 11,
    "build_errors": 3,
    "undocumented_tactics": 8,
    "missing_features": 3,
    "tasks_created": 5
  },
  "identified_tasks": [
    {
      "description": "Fix 10 sorry statements in Logos/Core/Theorems/",
      "priority": "high",
      "language": "lean",
      "estimated_hours": 5
    },
    ...
  ]
}
```

**Fixed Return Format** (Metadata Passing):
```json
{
  "summary": "Review completed. Updated 4 registries. Found 6 sorry, 11 axioms, 11 build errors. Created 5 follow-up tasks.",
  "artifacts": [
    {
      "type": "summary",
      "path": ".opencode/specs/227_codebase_review/summaries/review-summary.md",
      "summary": "Review findings and 5 follow-up tasks"
    },
    {
      "type": "documentation",
      "path": "docs/ProjectInfo/IMPLEMENTATION_STATUS.md",
      "summary": "Updated implementation status"
    },
    {
      "type": "documentation",
      "path": "docs/ProjectInfo/SORRY_REGISTRY.md",
      "summary": "Updated sorry registry"
    },
    {
      "type": "documentation",
      "path": "docs/ProjectInfo/TACTIC_REGISTRY.md",
      "summary": "Updated tactic registry"
    },
    {
      "type": "documentation",
      "path": "docs/ProjectInfo/FEATURE_REGISTRY.md",
      "summary": "Updated feature registry"
    }
  ],
  "metadata": {
    "session_id": "sess_1703606400_a1b2c3",
    "duration_seconds": 1800,
    "agent_type": "reviewer",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "review", "reviewer"],
    "metrics_summary": "6 sorry, 11 axioms, 11 build errors, 5 tasks created"
  }
}
```

**Key Changes**:
1. Remove verbose metrics object from return (move to review summary artifact)
2. Remove verbose identified_tasks array from return (move to review summary artifact)
3. Add brief metrics_summary to metadata field (<20 tokens)
4. /review command reads identified_tasks from review summary artifact (not return object)

**Integration Points**:
- Follows artifact-management.md metadata passing pattern (lines 166-180)
- Aligns with subagent-return-format.md standards
- Reduces orchestrator context window bloat by 95%
- Metrics and tasks available in review summary artifact for /review to read

**Implementation Approach**:
1. Reviewer writes metrics and identified_tasks to review summary artifact
2. Reviewer returns brief summary + artifact links (no verbose data)
3. /review Stage 6 reads review summary artifact to extract identified_tasks
4. /review Stage 6 creates tasks from identified_tasks (read from artifact)
5. /review Stage 7 delegates to status-sync-manager with task numbers

**Validation**:
- Verify metrics in review summary artifact
- Verify identified_tasks in review summary artifact
- Verify return object <100 tokens
- Verify /review can read identified_tasks from artifact

**Estimated Effort**: 1 hour
- 0.5h: Update reviewer.md to remove verbose return fields
- 0.5h: Update review.md Stage 6 to read identified_tasks from artifact

## Issue 5: Context File Organization

### Root Cause Analysis

**Evidence from review.md (287 lines)**:
- Lines 1-15: Metadata and context loading
- Lines 17-40: Context descriptions (duplicates command-lifecycle.md)
- Lines 42-505: Workflow stages (duplicates command-lifecycle.md 8-stage pattern)
- Lines 507-653: Artifact management, quality standards, validation (duplicates artifact-management.md, status-markers.md)

**Duplication Analysis**:

**1. Workflow Stages (lines 50-505)**:
- Duplicates command-lifecycle.md 8-stage pattern
- /review has same stages as /research, /plan, /implement
- Only difference: Stage 3 invokes reviewer instead of researcher/planner/implementer
- Estimated duplication: 60% (270 lines)

**2. Artifact Management (lines 519-584)**:
- Duplicates artifact-management.md lazy creation rules
- Duplicates artifact-management.md summary standards
- Duplicates artifact-management.md project numbering
- Estimated duplication: 80% (52 lines)

**3. Quality Standards (lines 586-600)**:
- Duplicates status-markers.md no-emojis standard
- Duplicates artifact-management.md registry accuracy
- Estimated duplication: 70% (10 lines)

**4. Validation (lines 608-625)**:
- Duplicates command-lifecycle.md validation stages
- Duplicates subagent-return-format.md validation
- Estimated duplication: 60% (11 lines)

**Total Duplication**: ~343 lines (60% of file)

**Root Cause**: review.md was created before command-lifecycle.md standardization (task 211). It contains inline workflow documentation instead of referencing shared standards.

### Proposed Solution

**Fix Location**: `.opencode/context/core/workflows/review.md`

**Refactoring Approach**: Extract to References Pattern

**Current Structure** (287 lines):
```markdown
# Repository Review Workflow

## Quick Reference
[15 lines]

## Workflow Overview
[5 lines]

## Workflow Stages
[455 lines - DUPLICATES command-lifecycle.md]

## Principles
[14 lines]

## Review Checklist
[40 lines - UNIQUE CONTENT]

## Review Report Format
[38 lines - UNIQUE CONTENT]

## Common Issues
[20 lines - UNIQUE CONTENT]

## Best Practices
[15 lines - UNIQUE CONTENT]
```

**Refactored Structure** (~150 lines, 47% reduction):
```markdown
# Repository Review Workflow

## Quick Reference
[15 lines - KEEP]

## Workflow Overview
[5 lines - KEEP]

## Workflow Stages

**Standard Lifecycle**: /review follows the 8-stage command lifecycle pattern defined in command-lifecycle.md with reviewer-specific adaptations.

**Reference**: See `.opencode/context/core/workflows/command-lifecycle.md` for detailed stage descriptions.

**Reviewer-Specific Adaptations**:

### Stage 1: Preflight
- Read next_project_number from state.json
- Generate project path: .opencode/specs/{next_project_number}_codebase_review
- Load current registries (IMPLEMENTATION_STATUS, SORRY_REGISTRY, TACTIC_REGISTRY, FEATURE_REGISTRY)

### Stage 2: PrepareDelegation
- Route to reviewer subagent
- Pass review scope (full|lean|docs)
- Pass current registry contents

### Stage 3: InvokeSubagent
- Invoke reviewer with delegation context
- Timeout: 3600s (1 hour for comprehensive review)

### Stage 4: ReceiveResults
- Validate reviewer return against subagent-return-format.md
- Extract review summary artifact path
- Extract updated registry paths

### Stage 5: ProcessResults
- Extract identified_tasks from review summary artifact
- Extract metrics from review summary artifact
- Determine next action based on status

### Stage 6: CreateTasks
- Create TODO.md task for review project (status: completed)
- Create TODO.md tasks for identified follow-up work
- Use /task command for each identified task

### Stage 7: Postflight
- Delegate to status-sync-manager for atomic state updates
- Git commit all changes (registries + TODO.md + state.json)

### Stage 8: ReturnSuccess
- Return brief summary + artifact path to user
- Context window protection: <100 tokens

[~80 lines - REDUCED from 455 lines]

## Artifact Management

**Reference**: See `.opencode/context/core/system/artifact-management.md` for detailed artifact standards.

**Review-Specific Artifacts**:
- Project directory: {next_project_number}_codebase_review
- Review summary: summaries/review-summary.md
- Registry updates: IMPLEMENTATION_STATUS.md, SORRY_REGISTRY.md, TACTIC_REGISTRY.md, FEATURE_REGISTRY.md

[~15 lines - REDUCED from 65 lines]

## Principles
[14 lines - KEEP]

## Review Checklist
[40 lines - KEEP, UNIQUE CONTENT]

## Review Report Format
[38 lines - KEEP, UNIQUE CONTENT]

## Common Issues
[20 lines - KEEP, UNIQUE CONTENT]

## Best Practices
[15 lines - KEEP, UNIQUE CONTENT]
```

**Duplication Reduction**:
- Before: 287 lines (343 lines duplicated)
- After: ~150 lines (50 lines duplicated)
- Reduction: 47% overall, 85% duplication reduction

**Integration Points**:
- References command-lifecycle.md for 8-stage pattern
- References artifact-management.md for artifact standards
- References status-markers.md for status format
- References subagent-return-format.md for validation
- Preserves unique review-specific content (checklist, report format, common issues)

**Validation**:
- Verify all references resolve to existing files
- Verify unique content preserved
- Verify no functionality lost
- Verify /review command still works

**Estimated Effort**: 1 hour
- 0.5h: Refactor review.md to reference pattern
- 0.5h: Validate references and test /review execution

## Cross-Cutting Concerns

### Integration with status-sync-manager

All 5 issues require updates to status-sync-manager delegation:

**Issue 1 (Project Numbering)**:
- status-sync-manager receives correct project_path from /review
- Validates project_path format
- Creates project state.json with correct project_number

**Issue 2 (Task Creation)**:
- status-sync-manager receives review task entry
- Creates TODO.md entry for review project (status: completed)
- Creates TODO.md entries for follow-up tasks
- Updates state.json with all task entries

**Issue 3 (Actionable Follow-ups)**:
- /review reads identified_tasks from review summary artifact
- /review creates tasks and collects task numbers
- /review updates review summary with actual task numbers
- status-sync-manager validates all task numbers exist

**Issue 4 (Verbosity)**:
- Reviewer returns brief summary + artifact links
- /review reads identified_tasks from review summary artifact
- status-sync-manager receives task numbers (not full task descriptions)

**Issue 5 (Context File Organization)**:
- review.md references command-lifecycle.md for workflow stages
- status-sync-manager delegation follows standard pattern
- No changes needed to status-sync-manager itself

### Backward Compatibility

**Breaking Changes**: None

All fixes are internal to /review command and reviewer subagent. No changes to:
- User-facing /review command syntax
- Review summary artifact format (only follow-up section changes)
- Registry update behavior
- Git commit behavior

**Migration Path**: None needed (no breaking changes)

### Testing Strategy

**Unit Tests** (per issue):
1. **Project Numbering**: Verify /review uses next_project_number from state.json
2. **Task Creation**: Verify /review creates TODO.md task for review project
3. **Actionable Follow-ups**: Verify review summary contains actual task numbers
4. **Verbosity**: Verify reviewer return <100 tokens
5. **Context File Organization**: Verify review.md references resolve correctly

**Integration Tests**:
1. Run /review on test repository
2. Verify project directory created with correct number
3. Verify TODO.md contains review task + follow-up tasks
4. Verify review summary contains actual task numbers
5. Verify orchestrator context window <100 tokens
6. Verify all registries updated
7. Verify git commit created

**Regression Tests**:
1. Verify existing review projects still accessible
2. Verify review summary format backward compatible
3. Verify registry update behavior unchanged

## Implementation Roadmap

### Phase 1: Project Numbering and Task Creation (4 hours)

**Tasks**:
1. Fix review.md Stage 1 to use next_project_number (Issue 1)
2. Fix review.md Stage 7 to create review task entry (Issue 2)
3. Update status-sync-manager delegation payload
4. Test with actual /review execution

**Deliverables**:
- Updated review.md (Stage 1, Stage 7)
- Test results showing correct project numbering
- Test results showing review task in TODO.md

**Validation**:
- /review creates directory with next_project_number
- TODO.md contains review task entry (status: completed)
- state.json incremented next_project_number
- No directory number collisions

### Phase 2: Summary and Verbosity (2 hours)

**Tasks**:
1. Fix review summary to include actual task numbers (Issue 3)
2. Fix reviewer return format to reduce verbosity (Issue 4)
3. Update /review Stage 6 to read identified_tasks from artifact
4. Test with actual /review execution

**Deliverables**:
- Updated reviewer.md (Step 4, Step 5)
- Updated review.md (Stage 6)
- Test results showing actionable follow-ups
- Test results showing <100 token return

**Validation**:
- Review summary contains actual task numbers (e.g., "Task 227")
- Review summary includes invocation instructions
- Reviewer return <100 tokens
- /review can read identified_tasks from artifact

### Phase 3: Context File Organization (2 hours)

**Tasks**:
1. Refactor review.md to reference pattern (Issue 5)
2. Validate all references resolve
3. Test /review execution with refactored file
4. Update documentation

**Deliverables**:
- Refactored review.md (47% size reduction)
- Test results showing /review still works
- Documentation updates

**Validation**:
- review.md references resolve to existing files
- Unique content preserved (checklist, report format)
- /review command functionality unchanged
- 85% duplication reduction achieved

## Recommendations

### Immediate Actions (High Priority)

1. **Fix Project Numbering** (Issue 1): Critical bug causing directory collisions
2. **Fix Task Creation** (Issue 2): Critical gap in task tracking
3. **Fix Verbosity** (Issue 4): High impact on orchestrator context window

### Short-Term Actions (Medium Priority)

4. **Fix Actionable Follow-ups** (Issue 3): Improves user experience
5. **Fix Context File Organization** (Issue 5): Reduces maintenance burden

### Long-Term Actions (Low Priority)

6. **Add Collision Detection**: Prevent directory number collisions
7. **Add Review Metrics Dashboard**: Visualize review trends over time
8. **Add Review Scheduling**: Automate periodic reviews

## References

### System Architecture
- `.opencode/context/core/workflows/command-lifecycle.md` - 8-stage command pattern
- `.opencode/context/core/system/artifact-management.md` - Artifact standards
- `.opencode/context/core/standards/status-markers.md` - Status format
- `.opencode/context/core/standards/subagent-return-format.md` - Return format

### Review Command
- `.opencode/command/review.md` - Review command specification
- `.opencode/agent/subagents/reviewer.md` - Reviewer subagent specification
- `.opencode/context/core/workflows/review.md` - Review workflow context

### State Management
- `.opencode/agent/subagents/status-sync-manager.md` - Atomic state updates
- `.opencode/specs/state.json` - Global state tracking
- `.opencode/specs/TODO.md` - Task tracking

### Evidence
- `.opencode/specs/225_codebase_review/summaries/review-summary.md` - Example review with issues
- `.opencode/specs/state.json` (lines 5, 180-185) - Project numbering evidence
- `TODO.md` (line 225) - Task collision evidence

## Conclusion

All 5 issues with /review command stem from incomplete integration with command-lifecycle.md and status-sync-manager patterns. The fixes are straightforward and follow existing architectural patterns. Total estimated effort is 6-8 hours with no breaking changes. Implementation should proceed in 3 phases: (1) Project numbering and task creation (critical), (2) Summary and verbosity (high impact), (3) Context file organization (maintenance).

**Success Criteria**:
- /review uses next_project_number from state.json (no collisions)
- /review creates TODO.md task for review project (status: completed)
- Review summary contains actual task numbers with invocation instructions
- Reviewer return <100 tokens (95% verbosity reduction)
- review.md references command-lifecycle.md (47% size reduction, 85% duplication reduction)
