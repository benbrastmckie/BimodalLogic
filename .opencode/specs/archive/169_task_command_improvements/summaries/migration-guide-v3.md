# Migration Guide: /implement Command Context Window Protection (v3)

**Date**: 2025-12-24
**Task**: 169 - Improve /implement command to protect primary agent context window
**Version**: 3 (Clean Break)
**Status**: COMPLETED

## Executive Summary

This migration guide documents the breaking changes implemented in Task 169 to protect the orchestrator's context window. The implementation uses a **clean-break approach** with no backward compatibility, requiring all consumers to update immediately. Key changes include artifact-first return formats, summary artifact enforcement, complexity-based routing, and differentiated git commit patterns.

**Impact**: All commands and agents that consume task-executor or batch-task-orchestrator outputs must update to handle new return formats. The /task → /implement rename affects all user-facing documentation and command invocations.

## Breaking Changes Summary

### 1. Return Format Changes

#### task-executor.md Return Format

**REMOVED FIELDS** (no longer present in return):
- `coordinator_results` - Full coordinator execution details
- `workflow_executed` - Detailed workflow stage information
- `todo_status_tracking` - Verbose TODO update details
- `plan_phases` - Full phase execution details
- `research_findings` - Full research report content
- `implementation_details` - Full implementation report content

**NEW FIELDS** (required in all returns):
- `summary` - Brief 3-5 sentence summary (<100 tokens)
- `artifacts` - Array of artifact references with type and path
- `key_metrics` - Complexity, effort, files modified, commits
- `session_id` - Unique session identifier for tracking

**OLD FORMAT** (100+ lines):
```json
{
  "task_number": 123,
  "status": "completed",
  "coordinator_results": {
    "workflow_executed": "research → plan → implement",
    "research_phase": {
      "findings": "... 500 lines of research content ...",
      "recommendations": "... 200 lines of recommendations ..."
    },
    "planning_phase": {
      "plan_content": "... 800 lines of plan content ...",
      "phases": [...]
    },
    "implementation_phase": {
      "changes": "... 1000 lines of implementation details ...",
      "files_modified": [...]
    }
  },
  "todo_status_tracking": {
    "before": "...",
    "after": "...",
    "changes_made": "..."
  }
}
```

**NEW FORMAT** (<500 tokens):
```json
{
  "task_number": 123,
  "status": "completed",
  "summary": "Implemented comprehensive validation system across task-executor and batch-task-orchestrator with token counting, field validation, and error handling. Created reusable validation utilities and comprehensive test coverage.",
  "artifacts": [
    {
      "type": "research_summary",
      "path": ".opencode/specs/123_validation_system/summaries/research-summary.md"
    },
    {
      "type": "plan_summary",
      "path": ".opencode/specs/123_validation_system/summaries/plan-summary.md"
    },
    {
      "type": "implementation_summary",
      "path": ".opencode/specs/123_validation_system/summaries/implementation-summary-20251224.md"
    }
  ],
  "key_metrics": {
    "complexity": "complex",
    "effort_hours": 6,
    "files_modified": 3,
    "commits": 5,
    "phases_completed": 5
  },
  "session_id": "20251224-123456-task-123"
}
```

**Token Reduction**: ~10,000 tokens → <500 tokens (95% reduction)

#### batch-task-orchestrator.md Return Format

**REMOVED FIELDS**:
- `dependency_analysis` - Full dependency graph details
- `wave_results` - Detailed wave execution logs
- `task_results` - Full task execution details for each task
- `coordination_details` - Verbose coordination information

**NEW FIELDS**:
- `batch_summary` - Brief 2-3 sentence batch summary (<75 tokens)
- `task_summaries` - One-line summaries per task (<150 chars each)
- `artifacts` - Batch summary artifact reference
- `key_metrics` - Aggregated metrics (total effort, files, commits, waves)

**OLD FORMAT** (1000+ lines for 10 tasks):
```json
{
  "total_tasks": 10,
  "completed": 10,
  "dependency_analysis": {
    "graph": "... 200 lines of dependency graph ...",
    "waves": [
      {
        "wave_number": 1,
        "tasks": [1, 2, 3],
        "execution_details": "... 300 lines per wave ..."
      }
    ]
  },
  "task_results": [
    {
      "task_number": 1,
      "full_coordinator_results": "... 100 lines per task ...",
      "workflow_executed": "...",
      "detailed_changes": "..."
    }
    // ... 9 more tasks with full details
  ]
}
```

**NEW FORMAT** (<50 lines for 10 tasks):
```json
{
  "total_tasks": 10,
  "completed": 10,
  "failed": 0,
  "blocked": 0,
  "batch_summary": "Successfully completed 10 tasks across 3 execution waves with mixed complexity. All simple tasks executed directly, moderate/complex tasks followed full workflow.",
  "task_summaries": [
    {
      "task_number": 1,
      "status": "completed",
      "summary": "Simple file modification completed",
      "artifacts": [".opencode/specs/001_*/summaries/implementation-summary-*.md"]
    },
    {
      "task_number": 2,
      "status": "completed",
      "summary": "Documentation update completed",
      "artifacts": [".opencode/specs/002_*/summaries/implementation-summary-*.md"]
    }
    // ... 8 more one-line summaries
  ],
  "artifacts": [
    {
      "type": "batch_summary",
      "path": ".opencode/specs/batch_001-010/summaries/batch-summary-20251224.md"
    }
  ],
  "key_metrics": {
    "total_effort_hours": 25,
    "total_files_modified": 18,
    "total_commits": 23,
    "execution_waves": 3,
    "simple_tasks": 5,
    "moderate_tasks": 3,
    "complex_tasks": 2
  }
}
```

**Line Reduction**: ~1000 lines → <50 lines (95% reduction)

### 2. Summary Artifact Requirements

**NEW REQUIREMENT**: All detailed artifacts MUST have corresponding summary artifacts.

| Detailed Artifact | Required Summary Artifact | Format |
|-------------------|---------------------------|--------|
| `reports/research-001.md` | `summaries/research-summary.md` | 3-5 sentences, <100 tokens |
| `plans/implementation-001.md` | `summaries/plan-summary.md` | 3-5 sentences, <100 tokens |
| Implementation results | `summaries/implementation-summary-YYYYMMDD.md` | 3-5 sentences, <100 tokens |
| Batch execution | `batch-{start}-{end}/summaries/batch-summary-YYYYMMDD.md` | 2-3 sentences, <75 tokens |

**Lazy Directory Creation**: The `summaries/` directory is created only when writing the first summary artifact (no empty directories or placeholder files).

**Validation**: task-executor and batch-task-orchestrator now validate that summary artifacts exist before returning. If missing, automatic correction is attempted.

### 3. Complexity-Based Routing

**NEW STAGE**: Stage 2.5 (AssessComplexity) added to /implement command.

**Complexity Scoring** (7 factors, 0-2 points each, 0-14 total):
1. **Effort estimate**: <2h=0, 2-4h=1, >4h=2
2. **Files affected**: 1=0, 2-3=1, >3=2
3. **Lines of code**: <100=0, 100-500=1, >500=2
4. **Dependencies**: 0=0, 1-2=1, >2=2
5. **Research needed**: No=0, Some=1, Extensive=2
6. **Unknowns**: Clear=0, Some=1, Many=2
7. **Risk level**: Low=0, Medium=1, High=2

**Complexity Thresholds**:
- **0-4 points**: SIMPLE - Direct execution, single commit, no research/plan
- **5-9 points**: MODERATE - Plan-based execution, phase commits
- **10-14 points**: COMPLEX - Full research → plan → implement workflow, commit per phase

**Manual Overrides**:
- `--simple` flag: Force simple execution path
- `--complex` flag: Force complex execution path

**Impact**: Task execution path now varies based on complexity assessment. Simple tasks bypass research/planning phases for faster execution.

### 4. Git Commit Pattern Differentiation

**NEW BEHAVIOR**: Commit patterns now differ based on task complexity.

#### Simple Tasks (0-4 complexity)
- **Commit Count**: 1 (single commit after all changes)
- **Commit Message**: `Implement task {number}: {title}`
- **Staging**: Only task-relevant files (no `git add -A`)

**Example**:
```bash
git add README.md
git commit -m "Implement task 999: Add comment to file"
```

#### Complex Tasks (10-14 complexity)
- **Commit Count**: N (one per phase that produces artifacts)
- **Commit Messages**: `Complete phase {N} of task {number}: {phase_name}`
- **Staging**: Only phase-relevant files
- **No Empty Commits**: Skip phases that don't produce artifacts

**Example**:
```bash
# Phase 1 - Research
git add .opencode/specs/998_*/reports/research-001.md .opencode/specs/998_*/summaries/research-summary.md
git commit -m "Complete research phase of task 998: Validation system design"

# Phase 2 - Planning
git add .opencode/specs/998_*/plans/implementation-001.md .opencode/specs/998_*/summaries/plan-summary.md
git commit -m "Complete planning phase of task 998: Validation implementation plan"

# Phase 3 - Implementation Phase 1
git add .opencode/agent/subagents/task-executor.md
git commit -m "Complete phase 1 of task 998: Task executor validation"

# ... additional phase commits
```

#### Batch Operations
- **Small Batches (<5 tasks)**: Single batch commit
- **Large Batches (>10 tasks)**: Wave-based commits (optional)
- **Commit Message**: `Complete batch {start}-{end}: {completed_count} tasks`

**Integration**: All git operations delegated to git-workflow-manager for consistency.

### 5. Validation Layer

**NEW VALIDATION**: Both task-executor and batch-task-orchestrator now validate returns before sending to orchestrator.

#### Task Executor Validation Rules
1. **Required Fields**: task_number, status, summary, artifacts, key_metrics
2. **Token Limit**: <500 tokens (estimated as chars ÷ 3)
3. **Summary Format**: 3-5 sentences, <100 tokens
4. **Artifact Paths**: All paths must exist and files must be present
5. **Summary Requirement**: If detailed artifact exists, summary must exist

**Validation Failure Handling**:
- Automatic correction attempted (condense summary, create missing artifacts)
- One retry after correction
- Detailed error message if still fails
- No return to orchestrator until validation passes

#### Batch Task Orchestrator Validation Rules
1. **Line Limit**: <50 lines per 10 tasks
2. **Task Accounting**: completed + failed + blocked + partial = total_tasks
3. **Batch Summary**: 2-3 sentences, <75 tokens
4. **Task Summaries**: Single sentence, <150 characters each
5. **Batch Artifact**: Batch summary artifact must exist

**Error Messages**: All validation errors include actionable recommendations and use /implement terminology.

## Clean-Break Approach Rationale

### Why Clean Break?

1. **Eliminates Technical Debt**: No backward compatibility code to maintain long-term
2. **Cleaner Architecture**: Single return format, no dual-format handling
3. **Simpler Codebase**: Fewer conditionals, clearer contracts
4. **Better Maintainability**: No legacy support burden, no deprecation cycles
5. **Immediate Benefits**: Full context window protection from day one

### Trade-offs Accepted

1. **Higher Upfront Risk**: All changes must be coordinated perfectly
2. **No Gradual Migration**: Cannot validate incrementally in production
3. **All-or-Nothing**: Single deployment, no partial rollout
4. **Breaking Changes**: All consumers must update immediately

### Success Criteria Met

- [PASS] Zero backward compatibility code in implementation
- [PASS] All consuming commands updated before breaking changes deployed
- [PASS] Comprehensive migration guide created (this document)
- [PASS] Context window targets achieved (<500 tokens per task, <50 lines per 10 tasks)
- [PASS] All /task references replaced with /implement
- [PASS] No broken links or command routing issues

## Migration Steps

### For Command Developers

If you have a command that consumes task-executor or batch-task-orchestrator outputs:

#### Step 1: Identify Consumption Points

Search your command file for references to removed fields:
```bash
grep -n "coordinator_results\|workflow_executed\|todo_status_tracking" .opencode/command/your-command.md
```

#### Step 2: Update to New Format

**OLD CODE** (consuming removed fields):
```markdown
<process>
  1. Execute task via task-executor
  2. Extract coordinator_results.research_phase.findings
  3. Display full research content to user
  4. Extract workflow_executed for logging
</process>
```

**NEW CODE** (consuming new format):
```markdown
<process>
  1. Execute task via task-executor
  2. Extract artifacts array and find research_summary artifact
  3. Read summary file from artifact path
  4. Display brief summary to user with artifact reference
  5. Extract key_metrics.complexity for logging
</process>
```

#### Step 3: Handle Artifacts

All detailed information is now in artifact files. Update your command to:
1. Extract artifact paths from `artifacts` array
2. Read artifact files when detailed information is needed
3. Display summaries from return format for quick reference
4. Provide artifact paths for users to access full details

**Example**:
```markdown
<artifact_handling>
  For each artifact in return.artifacts:
    - Display artifact.type and artifact.path
    - If user needs details, read file at artifact.path
    - Never display full artifact content inline
    - Always provide path reference for context window protection
</artifact_handling>
```

#### Step 4: Update Terminology

Replace all `/task` references with `/implement`:
```bash
# Find all /task references
grep -n "/task" .opencode/command/your-command.md

# Update to /implement
# Example: "/task 123" → "/implement 123"
```

#### Step 5: Test Integration

1. Execute your command with test scenario
2. Verify it handles new return format correctly
3. Verify no errors from missing removed fields
4. Verify artifact references work correctly
5. Verify all user-facing messages use /implement terminology

### For Agent Developers

If you have an agent that routes to task-executor or batch-task-orchestrator:

#### Step 1: Update Routing Logic

Ensure your agent routes to `/implement` command (not `/task`):

**OLD ROUTING**:
```markdown
<routing>
  If task execution needed:
    Route to /task command
</routing>
```

**NEW ROUTING**:
```markdown
<routing>
  If task execution needed:
    Route to /implement command
</routing>
```

#### Step 2: Handle Return Format

Update your agent to consume new return format:

**OLD CONSUMPTION**:
```markdown
<return_handling>
  Extract coordinator_results for detailed analysis
  Log workflow_executed for audit trail
  Display full implementation details to user
</return_handling>
```

**NEW CONSUMPTION**:
```markdown
<return_handling>
  Extract summary for quick overview
  Extract artifacts array for detailed information
  Display summary to user
  Provide artifact paths for full details
  Extract key_metrics for analysis
</return_handling>
```

#### Step 3: Update Documentation

Update your agent's documentation to reflect:
- New return format structure
- Artifact-first approach
- Summary requirements
- /implement terminology

### For Documentation Maintainers

#### Step 1: Update Command References

Replace all `/task {number}` with `/implement {number}`:
```bash
# Find all /task references in documentation
grep -rn "/task [0-9]" Documentation/

# Update each reference to /implement
```

#### Step 2: Update Examples

Update all examples showing task execution:

**OLD EXAMPLE**:
```markdown
To execute task 123:
```
/task 123
```
```

**NEW EXAMPLE**:
```markdown
To execute task 123:
```
/implement 123
```
```

#### Step 3: Update Workflow Descriptions

Update workflow descriptions to reflect new return formats:

**OLD DESCRIPTION**:
```markdown
The /task command returns full execution details including all research findings,
plan content, and implementation changes. Review the coordinator_results field
for complete information.
```

**NEW DESCRIPTION**:
```markdown
The /implement command returns a brief summary with artifact references. Review
the summary field for a quick overview, then access artifact files for detailed
information. This protects the orchestrator's context window from bloat.
```

## Before/After Examples

### Example 1: Simple Task Execution

#### Before (Old /task Command)

**Command**:
```
/task 999
```

**Return** (100+ lines):
```json
{
  "task_number": 999,
  "status": "completed",
  "coordinator_results": {
    "workflow_executed": "direct_implementation",
    "implementation_phase": {
      "files_modified": ["README.md"],
      "changes": [
        {
          "file": "README.md",
          "line": 1,
          "old": "# ProofChecker",
          "new": "# ProofChecker\n\n<!-- Project purpose: Formal verification of modal logic proofs -->"
        }
      ],
      "git_commits": [
        {
          "hash": "abc123",
          "message": "Add comment to README.md",
          "files": ["README.md"]
        }
      ]
    }
  },
  "todo_status_tracking": {
    "before": {
      "status": "[NOT STARTED]",
      "started": null,
      "completed": null
    },
    "after": {
      "status": "[COMPLETED]",
      "started": "2025-12-24",
      "completed": "2025-12-24"
    },
    "changes_made": [
      "Updated status from [NOT STARTED] to [IN PROGRESS]",
      "Set Started date to 2025-12-24",
      "Updated status from [IN PROGRESS] to [COMPLETED]",
      "Set Completed date to 2025-12-24"
    ]
  },
  "workflow_executed": {
    "stages": [
      "ParseInput",
      "ResolveTasks",
      "Execute",
      "Postflight"
    ],
    "duration_seconds": 15
  }
}
```

#### After (New /implement Command)

**Command**:
```
/implement 999
```

**Return** (<500 tokens):
```json
{
  "task_number": 999,
  "status": "completed",
  "summary": "Added explanatory comment to README.md describing project purpose. Simple modification with no dependencies or complexity.",
  "artifacts": [
    {
      "type": "implementation_summary",
      "path": ".opencode/specs/999_test_simple_task/summaries/implementation-summary-20251224.md"
    }
  ],
  "key_metrics": {
    "complexity": "simple",
    "effort_hours": 0.5,
    "files_modified": 1,
    "commits": 1
  },
  "session_id": "20251224-123456-task-999"
}
```

**Token Reduction**: ~2500 tokens → ~350 tokens (86% reduction)

### Example 2: Complex Task Execution

#### Before (Old /task Command)

**Command**:
```
/task 998
```

**Return** (500+ lines):
```json
{
  "task_number": 998,
  "status": "completed",
  "coordinator_results": {
    "workflow_executed": "research → plan → implement",
    "research_phase": {
      "findings": "... 500 lines of research findings ...",
      "recommendations": [
        "... 200 lines of recommendations ..."
      ],
      "artifacts_created": [
        ".opencode/specs/998_validation_system/reports/research-001.md"
      ]
    },
    "planning_phase": {
      "plan_content": "... 800 lines of plan content ...",
      "phases": [
        {
          "phase_number": 1,
          "name": "Task Executor Validation",
          "status": "[COMPLETED]",
          "tasks": ["... 50 lines of tasks ..."]
        },
        {
          "phase_number": 2,
          "name": "Batch Orchestrator Validation",
          "status": "[COMPLETED]",
          "tasks": ["... 50 lines of tasks ..."]
        },
        {
          "phase_number": 3,
          "name": "Validation Utilities",
          "status": "[COMPLETED]",
          "tasks": ["... 50 lines of tasks ..."]
        }
      ],
      "artifacts_created": [
        ".opencode/specs/998_validation_system/plans/implementation-001.md"
      ]
    },
    "implementation_phase": {
      "phase_1_results": {
        "files_modified": ["task-executor.md"],
        "changes": ["... 200 lines of changes ..."],
        "git_commit": "..."
      },
      "phase_2_results": {
        "files_modified": ["batch-task-orchestrator.md"],
        "changes": ["... 200 lines of changes ..."],
        "git_commit": "..."
      },
      "phase_3_results": {
        "files_modified": ["validation-utils.md"],
        "changes": ["... 200 lines of changes ..."],
        "git_commit": "..."
      }
    }
  },
  "todo_status_tracking": {
    "... 100 lines of status tracking ..."
  },
  "workflow_executed": {
    "... 50 lines of workflow details ..."
  }
}
```

#### After (New /implement Command)

**Command**:
```
/implement 998
```

**Return** (<500 tokens):
```json
{
  "task_number": 998,
  "status": "completed",
  "summary": "Implemented comprehensive validation system across task-executor and batch-task-orchestrator with token counting, field validation, and error handling. Created reusable validation utilities and comprehensive test coverage.",
  "artifacts": [
    {
      "type": "research_summary",
      "path": ".opencode/specs/998_validation_system/summaries/research-summary.md"
    },
    {
      "type": "plan_summary",
      "path": ".opencode/specs/998_validation_system/summaries/plan-summary.md"
    },
    {
      "type": "implementation_summary",
      "path": ".opencode/specs/998_validation_system/summaries/implementation-summary-20251224.md"
    }
  ],
  "key_metrics": {
    "complexity": "complex",
    "effort_hours": 6,
    "files_modified": 3,
    "commits": 5,
    "phases_completed": 5
  },
  "session_id": "20251224-123456-task-998"
}
```

**Token Reduction**: ~15,000 tokens → ~450 tokens (97% reduction)

### Example 3: Batch Execution

#### Before (Old /task Command)

**Command**:
```
/task 990-999
```

**Return** (1000+ lines):
```json
{
  "total_tasks": 10,
  "completed": 10,
  "failed": 0,
  "blocked": 0,
  "dependency_analysis": {
    "graph": {
      "nodes": ["... 100 lines of nodes ..."],
      "edges": ["... 50 lines of edges ..."]
    },
    "waves": [
      {
        "wave_number": 1,
        "tasks": [990, 991, 995],
        "execution_order": "parallel",
        "dependencies_satisfied": true
      },
      {
        "wave_number": 2,
        "tasks": [992, 996],
        "execution_order": "parallel",
        "dependencies_satisfied": true
      },
      {
        "wave_number": 3,
        "tasks": [993, 994, 997, 998, 999],
        "execution_order": "parallel",
        "dependencies_satisfied": true
      }
    ]
  },
  "task_results": [
    {
      "task_number": 990,
      "status": "completed",
      "coordinator_results": {
        "... 100 lines per task ..."
      },
      "todo_status_tracking": {
        "... 50 lines per task ..."
      }
    }
    // ... 9 more tasks with full details (900+ lines total)
  ],
  "coordination_details": {
    "... 100 lines of coordination details ..."
  }
}
```

#### After (New /implement Command)

**Command**:
```
/implement 990-999
```

**Return** (<50 lines):
```json
{
  "total_tasks": 10,
  "completed": 10,
  "failed": 0,
  "blocked": 0,
  "batch_summary": "Successfully completed 10 tasks across 3 execution waves with mixed complexity. All simple tasks executed directly, moderate/complex tasks followed full workflow.",
  "task_summaries": [
    {
      "task_number": 990,
      "status": "completed",
      "summary": "Simple file modification completed",
      "artifacts": [".opencode/specs/990_*/summaries/implementation-summary-*.md"]
    },
    {
      "task_number": 991,
      "status": "completed",
      "summary": "Documentation update completed",
      "artifacts": [".opencode/specs/991_*/summaries/implementation-summary-*.md"]
    },
    {
      "task_number": 992,
      "status": "completed",
      "summary": "Refactoring task completed",
      "artifacts": [".opencode/specs/992_*/summaries/implementation-summary-*.md"]
    },
    {
      "task_number": 993,
      "status": "completed",
      "summary": "Test coverage improvement completed",
      "artifacts": [".opencode/specs/993_*/summaries/implementation-summary-*.md"]
    },
    {
      "task_number": 994,
      "status": "completed",
      "summary": "Bug fix completed",
      "artifacts": [".opencode/specs/994_*/summaries/implementation-summary-*.md"]
    },
    {
      "task_number": 995,
      "status": "completed",
      "summary": "Feature enhancement completed",
      "artifacts": [".opencode/specs/995_*/summaries/implementation-summary-*.md"]
    },
    {
      "task_number": 996,
      "status": "completed",
      "summary": "Documentation update completed",
      "artifacts": [".opencode/specs/996_*/summaries/implementation-summary-*.md"]
    },
    {
      "task_number": 997,
      "status": "completed",
      "summary": "Validation extension completed",
      "artifacts": [".opencode/specs/997_*/summaries/implementation-summary-*.md"]
    },
    {
      "task_number": 998,
      "status": "completed",
      "summary": "Validation system implementation completed",
      "artifacts": [".opencode/specs/998_*/summaries/implementation-summary-*.md"]
    },
    {
      "task_number": 999,
      "status": "completed",
      "summary": "Comment addition completed",
      "artifacts": [".opencode/specs/999_*/summaries/implementation-summary-*.md"]
    }
  ],
  "artifacts": [
    {
      "type": "batch_summary",
      "path": ".opencode/specs/batch_990-999/summaries/batch-summary-20251224.md"
    }
  ],
  "key_metrics": {
    "total_effort_hours": 25,
    "total_files_modified": 18,
    "total_commits": 23,
    "execution_waves": 3,
    "simple_tasks": 5,
    "moderate_tasks": 3,
    "complex_tasks": 2
  }
}
```

**Line Reduction**: ~1200 lines → ~48 lines (96% reduction)

## Troubleshooting Common Issues

### Issue 1: "Field 'coordinator_results' not found"

**Symptom**: Command or agent fails with error about missing `coordinator_results` field.

**Cause**: Command/agent still consuming old return format.

**Solution**:
1. Update command/agent to consume new format
2. Replace `coordinator_results` access with `artifacts` array
3. Read artifact files for detailed information
4. Use `summary` field for quick overview

**Example Fix**:
```markdown
<!-- OLD -->
<process>
  Extract coordinator_results.research_phase.findings
</process>

<!-- NEW -->
<process>
  Extract artifacts array
  Find artifact with type="research_summary"
  Read summary file at artifact.path
</process>
```

### Issue 2: "Validation failed: Token count exceeds 500"

**Symptom**: task-executor returns validation error about token count.

**Cause**: Return format exceeds 500 token limit (usually due to verbose summary).

**Solution**:
1. Condense summary to 3-5 sentences
2. Move detailed information to artifact files
3. Ensure summary is <100 tokens
4. Retry validation

**Automatic Correction**: task-executor attempts automatic correction by condensing summary. If this fails, manual intervention required.

### Issue 3: "Missing summary artifact for detailed artifact"

**Symptom**: Validation error about missing summary artifact.

**Cause**: Detailed artifact (research/plan/implementation) created without corresponding summary.

**Solution**:
1. Create summary artifact at required path
2. Follow summary format (3-5 sentences, <100 tokens)
3. Ensure lazy directory creation (create summaries/ when writing first summary)
4. Retry validation

**Automatic Correction**: task-executor attempts to create summary from detailed artifact. If this fails, manual creation required.

### Issue 4: "/task command not found"

**Symptom**: User invokes `/task` and receives "command not found" error.

**Cause**: /task command renamed to /implement.

**Solution**:
1. Use `/implement` instead of `/task`
2. Update all scripts/documentation using `/task`
3. Inform users of rename

**Note**: The `/task` command for ADDING tasks to TODO.md still exists (task.md). Only task EXECUTION was renamed to /implement.

### Issue 5: "Batch return exceeds 50 lines per 10 tasks"

**Symptom**: batch-task-orchestrator returns validation error about line count.

**Cause**: Batch return format exceeds line limit (usually due to verbose task summaries).

**Solution**:
1. Condense task summaries to single sentence (<150 chars each)
2. Condense batch summary to 2-3 sentences (<75 tokens)
3. Move detailed information to batch summary artifact
4. Retry validation

**Automatic Correction**: batch-task-orchestrator attempts automatic correction by condensing summaries. If this fails, manual intervention required.

### Issue 6: "Task accounting mismatch"

**Symptom**: Validation error about task accounting (completed + failed + blocked ≠ total).

**Cause**: Some tasks not accounted for in batch return.

**Solution**:
1. Ensure all tasks are in one of: completed, failed, blocked, partial
2. Verify total_tasks matches actual task count
3. Check for tasks that were skipped or lost during execution
4. Retry validation

**Prevention**: batch-task-orchestrator tracks all tasks through execution and ensures accounting before return.

### Issue 7: "Complexity assessment incorrect"

**Symptom**: Task classified as simple when it should be complex (or vice versa).

**Cause**: Complexity scoring algorithm misclassified task.

**Solution**:
1. Use manual override flags: `--simple` or `--complex`
2. Review task metadata (effort, files, dependencies)
3. Update task metadata if incorrect
4. Re-run with override flag

**Example**:
```
/implement 998 --complex
```

**Tuning**: If misclassification is common, review complexity thresholds and adjust if needed.

## Custom Integration Migration

If you have custom integrations that consume task-executor or batch-task-orchestrator outputs:

### Step 1: Audit Integration Points

Identify all places where your integration:
1. Calls /task command (update to /implement)
2. Parses task-executor return format
3. Parses batch-task-orchestrator return format
4. Accesses removed fields (coordinator_results, workflow_executed, todo_status_tracking)

### Step 2: Update Return Format Parsing

Update your parsing logic to handle new format:

**OLD PARSING**:
```python
def parse_task_result(result):
    research = result['coordinator_results']['research_phase']['findings']
    plan = result['coordinator_results']['planning_phase']['plan_content']
    implementation = result['coordinator_results']['implementation_phase']['changes']
    return {
        'research': research,
        'plan': plan,
        'implementation': implementation
    }
```

**NEW PARSING**:
```python
def parse_task_result(result):
    summary = result['summary']
    artifacts = result['artifacts']
    
    # Read artifact files for detailed information
    research_summary = read_artifact(artifacts, 'research_summary')
    plan_summary = read_artifact(artifacts, 'plan_summary')
    implementation_summary = read_artifact(artifacts, 'implementation_summary')
    
    return {
        'summary': summary,
        'research_summary': research_summary,
        'plan_summary': plan_summary,
        'implementation_summary': implementation_summary,
        'artifacts': artifacts
    }

def read_artifact(artifacts, artifact_type):
    artifact = next((a for a in artifacts if a['type'] == artifact_type), None)
    if artifact:
        with open(artifact['path'], 'r') as f:
            return f.read()
    return None
```

### Step 3: Update Command Invocations

Replace all `/task` invocations with `/implement`:

**OLD**:
```python
result = invoke_command("/task 123")
```

**NEW**:
```python
result = invoke_command("/implement 123")
```

### Step 4: Handle Artifacts

Update your integration to:
1. Store artifact paths for reference
2. Read artifact files when detailed information needed
3. Display summaries for quick reference
4. Avoid storing full artifact content (context window protection)

### Step 5: Test Integration

1. Test with simple task execution
2. Test with complex task execution
3. Test with batch execution
4. Test error handling (failed, blocked, validation errors)
5. Verify no regressions in functionality

## Rollback Procedure

If critical issues arise and rollback is necessary:

### Step 1: Identify Rollback Trigger

Rollback is triggered if:
- Context window usage increases instead of decreases
- Validation failures exceed 10% of executions
- Critical commands break and cannot be quickly fixed
- Summary quality consistently poor (missing key information)
- Performance degradation >20% in task execution time
- Any consuming command fails at runtime
- Broken /implement command references or routing
- User confusion from incomplete /task → /implement rename

### Step 2: Execute Rollback

1. **Revert Git Commits**: Revert all commits from Task 169 in reverse order
   ```bash
   git log --grep="Task 169" --oneline
   git revert <commit-hash-phase-8>
   git revert <commit-hash-phase-7>
   # ... continue in reverse order
   ```

2. **Restore task.md**: Restore /task command file
   ```bash
   git checkout HEAD~N .opencode/command/task.md
   ```

3. **Update TODO.md**: Mark task 169 as [BLOCKED] with rollback reason
   ```markdown
   ### 169. Improve /implement command context window protection
   - **Status**: [BLOCKED]
   - **Blocked Reason**: Rollback due to {specific_issue}
   - **Rollback Date**: {date}
   ```

4. **Create Rollback Task**: Create new task for addressing rollback issues
   ```markdown
   ### {new_number}. Address Task 169 Rollback Issues
   - **Status**: [NOT STARTED]
   - **Priority**: High
   - **Description**: Investigate and fix issues that caused Task 169 rollback
   - **Blocking**: Task 169
   ```

5. **Notify Users**: Inform users of rollback and temporary use of /task command

### Step 3: Post-Rollback Analysis

1. Document rollback reason and issues encountered
2. Analyze root cause of issues
3. Create new implementation plan addressing issues
4. Consider phased approach with deprecation warnings instead of clean break
5. Re-plan implementation with lessons learned

## Migration Checklist

Use this checklist to ensure complete migration:

### Command Developers
- [ ] Identified all consumption points of task-executor/batch-task-orchestrator
- [ ] Updated to consume new return format (artifacts, summary, key_metrics)
- [ ] Removed all references to removed fields (coordinator_results, workflow_executed, todo_status_tracking)
- [ ] Updated all /task references to /implement
- [ ] Tested integration with new format
- [ ] Verified no errors from missing fields
- [ ] Verified artifact references work correctly
- [ ] Updated command documentation

### Agent Developers
- [ ] Updated routing to /implement command
- [ ] Updated return format consumption
- [ ] Updated agent documentation
- [ ] Tested agent with new format
- [ ] Verified no regressions

### Documentation Maintainers
- [ ] Updated all /task references to /implement
- [ ] Updated all examples with new command
- [ ] Updated workflow descriptions
- [ ] Updated troubleshooting guides
- [ ] Verified no broken links

### Integration Developers
- [ ] Audited all integration points
- [ ] Updated return format parsing
- [ ] Updated command invocations
- [ ] Implemented artifact handling
- [ ] Tested integration end-to-end
- [ ] Verified no regressions

### All Users
- [ ] Read migration guide
- [ ] Understand breaking changes
- [ ] Updated personal scripts/workflows
- [ ] Tested with new /implement command
- [ ] Reported any issues encountered

## Support and Resources

### Documentation
- **Implementation Plan**: `.opencode/specs/169_task_command_improvements/plans/implementation-003.md`
- **Research Report**: `.opencode/specs/169_task_command_improvements/reports/research-001.md`
- **Test Results**: `.opencode/specs/169_task_command_improvements/summaries/test-results-v3.md`
- **Artifact Management**: `.opencode/context/common/system/artifact-management.md`

### Schemas
- **Task Executor Return Schema**: `.opencode/specs/169_task_command_improvements/schemas/task-executor-return-schema.json`
- **Batch Return Schema**: `.opencode/specs/169_task_command_improvements/schemas/batch-return-schema.json`

### Examples
- See "Before/After Examples" section above
- See test scenarios in test-results-v3.md
- See artifact-management.md for summary examples

### Getting Help

If you encounter issues during migration:
1. Review troubleshooting section above
2. Check test-results-v3.md for similar scenarios
3. Review implementation-003.md for design rationale
4. Create new task for migration assistance if needed

## Conclusion

This migration represents a significant improvement in context window protection for the .opencode system. The clean-break approach eliminates technical debt and provides immediate benefits, but requires careful migration of all consuming commands and integrations.

**Key Takeaways**:
- **95%+ reduction** in return format size (tokens/lines)
- **Artifact-first approach** protects context window
- **Summary artifacts** provide quick reference without bloat
- **Complexity-based routing** optimizes execution paths
- **Differentiated git patterns** improve commit history
- **Validation layer** ensures format compliance

**Migration Timeline**:
- **Immediate**: All consuming commands must update
- **Day 1**: Test all integrations
- **Week 1**: Monitor for issues, address as needed
- **Month 1**: Review effectiveness, tune thresholds if needed

**Success Metrics**:
- Context window usage reduced by 95%+
- No validation failures in production
- All consuming commands working correctly
- User satisfaction with new /implement command
- No rollback required

Thank you for migrating to the new /implement command format. This change significantly improves the .opencode system's scalability and maintainability.
