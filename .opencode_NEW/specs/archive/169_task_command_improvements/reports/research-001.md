# Research Report: /task Command Context Window Protection Improvements

- **Task**: 169 - Improve /task command to protect primary agent context window
- **Status**: [IN PROGRESS]
- **Started**: 2025-12-24
- **Effort**: 4 hours
- **Priority**: High
- **Sources/Inputs**:
  - .opencode/command/task.md
  - .opencode/agent/subagents/task-executor.md
  - .opencode/agent/subagents/batch-task-orchestrator.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/report.md
  - Web research on context window protection patterns
  - Anthropic's "Building Effective Agents" (Dec 2024)
- **Artifacts**: This report
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

## Executive Summary

- Current /task command implementation has significant gaps in context window protection, particularly when subagents return full execution details instead of artifact references and summaries
- Simple tasks (no plans) and complex tasks (multi-phase plans) follow different execution paths but lack clear differentiation in artifact management and git commit patterns
- Batch execution via batch-task-orchestrator properly delegates but individual task-executor returns verbose results that bloat primary agent context
- Web research reveals industry best practices: orchestrator-workers pattern with Create-Reference-Summarize workflow, progressive summarization at each hierarchy level, and objective complexity metrics for routing decisions
- Recommendations include implementing two-tier routing, standardizing summary formats, enforcing artifact-first returns, and differentiating git commit patterns for simple vs complex workflows

## Context & Scope

This research analyzes the current /task command implementation to identify gaps in context window protection when executing single tasks or task ranges. The command must handle both simple tasks (no plans, direct TODO.md updates with git commits) and complex tasks (multi-phase plans with phased execution, plan updates, and commits per phase).

**Scope Constraints**:
- Focus on /task command and its subagents (task-executor, batch-task-orchestrator)
- Analyze single task execution and batch/range execution paths
- Evaluate artifact management patterns per artifact-management.md standards
- Review git commit patterns per git-commits.md standards
- Identify gaps in context window protection mechanisms

## Findings

### 1. Current Implementation Analysis

#### /task Command Workflow

**Strengths**:
- Supports single tasks, comma-separated lists, and ranges (e.g., /task 105, /task 105,106, /task 105-107)
- Routes to batch-task-orchestrator for multi-task inputs
- Uses status-sync-manager for atomic TODO/plan/state updates
- Enforces lazy directory creation (project roots/subdirs only when writing artifacts)
- Respects Language metadata for Lean routing

**Gaps**:
- No explicit complexity assessment before routing to task-executor
- Lacks clear differentiation between simple (no plan) and complex (multi-phase plan) execution paths
- Does not enforce artifact-first returns from subagents
- Missing standardized summary format requirements for subagent responses
- Git commit patterns not differentiated by task complexity

**Current Flow**:
```
/task {number(s)}
  ├─ ParseInput: validate, normalize ranges/lists
  ├─ ResolveTasks: load TODO, detect Lean, preflight status update
  ├─ Execute:
  │   ├─ Single task → task-executor (Level 2)
  │   └─ Multiple tasks → batch-task-orchestrator (Level 2)
  └─ Postflight: sync plan/status, update state, return summary
```

#### task-executor Agent

**Strengths**:
- Intelligent task type detection (implementation, documentation, refactoring, research, batch)
- Multi-factor scoring for task classification
- Automatic TODO.md status tracking ([NOT STARTED] → [IN PROGRESS] → [COMPLETED])
- Routes to appropriate coordinators (implementer, documenter, refactorer, researcher)
- Atomic status updates with timestamps

**Gaps**:
- **CRITICAL**: Returns verbose coordinator results to orchestrator instead of artifact references + brief summaries
- Creates project directories (stage 4) but doesn't enforce artifact-first creation
- Research phase (stage 5) and planning phase (stage 6) create artifacts but return full details
- Return format (stage 10) includes full coordinator results, workflow details, and verbose output
- No standardized summary length limits (can return 50+ lines of detail)

**Current Return Format** (lines 559-706):
```json
{
  "task_number": NNN,
  "task_title": "{title}",
  "task_type": "implementation|documentation|refactoring|research|batch_tasks",
  "complexity": "simple|moderate|complex",
  "coordinator_used": "@subagents/{coordinator_name}",
  "todo_status_tracking": {...},  // Full tracking details
  "workflow_executed": {...},     // Full workflow details
  "coordinator_results": {...},   // Full coordinator output
  "artifacts": [...],             // Artifact paths (good)
  "status": "completed|in_progress|failed",
  "next_steps": "..."             // Verbose recommendations
}
```

**Problem**: This format returns 100+ lines of detail to the primary agent, causing context bloat.

#### batch-task-orchestrator Agent

**Strengths**:
- Dependency analysis via task-dependency-analyzer
- Wave-based parallel execution (up to 5 concurrent tasks)
- Atomic status updates via batch-status-manager
- Comprehensive error handling (failed, blocked, skipped tasks)
- Graceful degradation on failures

**Gaps**:
- Routes to task-executor for each task, which returns verbose results
- Aggregates all task-executor results into batch summary (context multiplication)
- Return format (lines 344-398) includes full task results for every task in batch
- No progressive summarization (each task's full details included)

**Current Return Format**:
```json
{
  "batch_execution": {...},
  "dependency_analysis": {...},
  "wave_results": [...],
  "task_results": {              // PROBLEM: Full results for every task
    "63": {
      "status": "completed",
      "artifacts": [...],
      "plan_summary": {...},     // Full plan details
      "recommendation": "..."    // Full recommendations
    },
    // ... repeated for every task
  },
  "failed_tasks": {...},
  "blocked_tasks": {...},
  "execution_time": {...},
  "todo_status": {...},
  "recommendations": [...]
}
```

**Problem**: For a batch of 10 tasks, this returns 1000+ lines of detail to the primary agent.

### 2. Artifact Management Gaps

#### Current Patterns

**What Works**:
- Lazy directory creation enforced (specs/NNN_slug/ created only when writing first artifact)
- Subdirectories (reports/, plans/, summaries/) created only when writing into them
- Project state.json created alongside first artifact
- Artifact paths returned in responses

**What's Missing**:
- **No enforcement of summary artifact creation**: Subagents create detailed artifacts (plans, reports) but don't always create corresponding summaries
- **No standardized summary format**: When summaries are created, format varies by agent
- **No artifact-first return protocol**: Subagents can return full content instead of references
- **Missing implementation summaries**: When /task executes with artifacts, should create summaries/implementation-summary-YYYYMMDD.md but this is not consistently enforced

#### Artifact Management Standards (from artifact-management.md)

**Key Requirements**:
1. Lazy creation: project root + subdirs only when writing artifacts
2. Summaries under summaries/ for quick reference
3. Context protection: agents return only file paths + brief summaries (3-5 sentences)
4. State sync: update project state alongside artifact writes

**Gap Analysis**:
- [PASS] Lazy creation enforced
- [PASS] State sync implemented
- [WARN] Summary creation inconsistent
- [FAIL] Context protection not enforced (agents return full details)

### 3. Simple vs Complex Task Handling

#### Current Approach

The task-executor has complexity assessment (lines 709-747) but doesn't use it to differentiate execution paths:

**Complexity Indicators**:
- Simple: ≤30 min, 1-2 files, clear requirements, no dependencies
- Moderate: 30 min - 2 hours, 2-3 files, minor unknowns, some dependencies
- Complex: >2 hours, 4+ files, unclear requirements, complex dependencies, research needed

**Current Execution**:
- All tasks go through same workflow (research → planning → execution)
- Simple tasks skip research (stage 5) but still create plans (stage 6)
- No differentiation in git commit patterns
- No differentiation in summary requirements

#### Recommended Approach (from web research)

**Simple Tasks** (direct execution path):
1. Mark [IN PROGRESS]
2. Execute directly (no research, no plan)
3. Update TODO.md with completion
4. Single git commit with all changes
5. Return brief summary (3-5 sentences)

**Complex Tasks** (plan-based execution path):
1. Mark [IN PROGRESS]
2. Research phase (if needed) → create reports/research-NNN.md
3. Planning phase → create plans/implementation-NNN.md
4. Execution phase → implement with phase tracking
5. Git commit per phase
6. Create summaries/implementation-summary-YYYYMMDD.md
7. Return artifact references + structured summary

**Gap**: Current implementation doesn't differentiate these paths clearly.

### 4. Git Commit Patterns

#### Current Standards (from git-commits.md)

**Requirements**:
- Targeted commits: stage only task-relevant files
- No `git add -A` or blanket commits
- Commit after artifacts + status updates + validation
- Format: `<area>: <summary> (task NNN)`

**Gaps in /task Implementation**:
- No explicit git commit guidance in task.md (line 101 mentions git-commits.md but doesn't specify when/how)
- task-executor doesn't handle git commits (delegates to coordinators)
- batch-task-orchestrator doesn't coordinate git commits across tasks
- No differentiation between simple (single commit) and complex (commit per phase) patterns

**Recommended Patterns**:

**Simple Tasks**:
```bash
# After direct execution completes
git add file1.md file2.md
git commit -m "docs: add missing READMEs (task 169)"
```

**Complex Tasks**:
```bash
# After research phase
git add specs/169_*/reports/research-001.md
git commit -m "research: context window protection patterns (task 169, phase 1)"

# After planning phase
git add specs/169_*/plans/implementation-001.md
git commit -m "plan: /task command improvements (task 169, phase 2)"

# After implementation phase
git add .opencode/command/task.md .opencode/agent/subagents/task-executor.md
git commit -m "implement: enforce artifact-first returns (task 169, phase 3)"
```

### 5. Context Window Protection Best Practices (Web Research)

#### Orchestrator-Workers Pattern

**Key Principles**:
1. **Workers create artifacts**: All detailed work products written to files
2. **Workers return references**: Only file paths + metadata returned to orchestrator
3. **Progressive summarization**: Each level summarizes for the level above
4. **Bounded responses**: Strict limits on response size (e.g., 500 tokens max)

**Implementation**:
```
Primary Agent (Orchestrator)
  ├─ Delegates to Worker 1
  │   ├─ Creates artifact: specs/169_*/reports/research-001.md
  │   └─ Returns: {path, summary: "3-5 sentences", key_findings: [3 bullets]}
  ├─ Delegates to Worker 2
  │   ├─ Creates artifact: specs/169_*/plans/implementation-001.md
  │   └─ Returns: {path, summary: "3-5 sentences", phases: [phase names]}
  └─ Aggregates references (not content)
```

**Anti-Pattern** (current implementation):
```
Primary Agent
  ├─ Delegates to Worker
  │   ├─ Creates artifact
  │   └─ Returns: {artifact_path, FULL_CONTENT, FULL_DETAILS, FULL_RECOMMENDATIONS}
  └─ Context bloated with full content
```

#### Create-Reference-Summarize Workflow

**Standard Pattern**:
1. **Create**: Worker creates detailed artifact (report, plan, implementation)
2. **Reference**: Worker records artifact path
3. **Summarize**: Worker creates brief summary (3-5 sentences)
4. **Return**: Worker returns {path, summary, status, key_metrics} only

**Summary Structure**:
```markdown
# Brief Summary (3-5 sentences)
- What was done
- Key outcomes
- Status/completion
- Next steps (if applicable)

# Key Metrics (3-5 bullets)
- Files modified: 3
- Lines changed: +150/-20
- Tests added: 5
- Phases completed: 2/3
```

**Full Details**: Remain in artifact, never returned to orchestrator

#### Objective Complexity Metrics

**7 Indicators for Routing**:
1. **Effort estimate**: <30 min = simple, 30min-2hr = moderate, >2hr = complex
2. **File count**: 1-2 = simple, 2-3 = moderate, 4+ = complex
3. **Lines of code**: <100 = simple, 100-500 = moderate, >500 = complex
4. **Dependencies**: none = simple, some = moderate, many = complex
5. **Research needed**: no = simple, minor = moderate, yes = complex
6. **Unknowns**: clear = simple, minor = moderate, unclear = complex
7. **Risk level**: low = simple, medium = moderate, high = complex

**Scoring**:
- Simple: 0-2 complex indicators
- Moderate: 3-4 complex indicators
- Complex: 5+ complex indicators

**Routing Decision**:
- Simple → Direct execution path (no plan)
- Moderate → Lightweight plan path (single-phase plan)
- Complex → Full plan path (multi-phase plan with research)

## Decisions

### 1. Enforce Artifact-First Returns

**Decision**: All subagents (task-executor, batch-task-orchestrator, coordinators) MUST create artifacts for detailed work and return only references + brief summaries to the primary agent.

**Rationale**: Prevents context window bloat, aligns with industry best practices, enables scalable hierarchical agent systems.

**Implementation**: Update return formats to enforce maximum response size and require summary artifacts.

### 2. Differentiate Simple vs Complex Execution Paths

**Decision**: Implement two-tier routing based on objective complexity metrics:
- Simple tasks: direct execution, no plan, single commit, brief summary
- Complex tasks: multi-phase execution, plan-based, commit per phase, structured summary with artifact references

**Rationale**: Simple tasks don't need the overhead of research/planning phases; complex tasks benefit from structured approach.

**Implementation**: Add complexity router in /task command before delegating to task-executor.

### 3. Standardize Summary Formats

**Decision**: Define strict summary formats for simple and complex task returns:
- Simple: 3-5 sentences + file list
- Complex: Structured summary with artifact references, phase summaries, key metrics

**Rationale**: Consistent summaries enable predictable context usage and easier aggregation in batch execution.

**Implementation**: Create summary templates and enforce in subagent return validation.

### 4. Implement Phase-Based Git Commits for Complex Tasks

**Decision**: Complex tasks with multi-phase plans commit after each phase; simple tasks commit once at completion.

**Rationale**: Phase-based commits provide better granularity and rollback points for complex work; single commits are sufficient for simple changes.

**Implementation**: Update implementation-orchestrator to commit after each phase; update task-executor to commit once for simple tasks.

## Recommendations

### Priority 1: Update task-executor Return Format

**Current** (lines 559-706):
```json
{
  "task_number": NNN,
  "coordinator_results": {...},  // Full details
  "workflow_executed": {...},    // Full details
  // ... 100+ lines
}
```

**Recommended**:
```json
{
  "task_number": NNN,
  "task_title": "{title}",
  "status": "completed|in_progress|failed",
  "artifacts": [
    {
      "type": "plan|report|implementation",
      "path": "specs/NNN_*/plans/implementation-001.md"
    }
  ],
  "summary": "Brief 3-5 sentence summary of what was done and outcome",
  "key_metrics": {
    "files_modified": 3,
    "complexity": "simple|moderate|complex",
    "execution_time": "15m"
  },
  "next_step": "Brief one-line recommendation"
}
```

**Impact**: Reduces return size from 100+ lines to ~15 lines, protecting primary agent context.

### Priority 2: Enforce Summary Artifact Creation

**Requirement**: When task-executor or coordinators create detailed artifacts (plans, reports, implementations), they MUST also create a corresponding summary artifact in summaries/.

**Summary Naming**:
- Research: summaries/research-summary.md
- Planning: summaries/plan-summary.md
- Implementation: summaries/implementation-summary-YYYYMMDD.md

**Summary Format** (from artifact-management.md):
```markdown
# {Type} Summary: {task_title}

## Key Outcomes
1. {outcome_1}
2. {outcome_2}
3. {outcome_3}

## Artifacts Created
- {artifact_1_path}
- {artifact_2_path}

## Status
{brief_status_statement}

## Full Details
See: {full_artifact_path}
```

**Implementation**: Add summary creation step to task-executor stages 5, 6, 8.

### Priority 3: Implement Complexity Router in /task Command

**New Stage** (insert before stage 3 "Execute"):

```markdown
<stage id="2.5" name="AssessComplexity">
  <action>Assess task complexity and determine execution path</action>
  <process>
    1. Extract complexity indicators from task:
       - Effort estimate (from TODO.md)
       - File count (from Files Affected)
       - Dependencies (from TODO.md)
       - Keywords (research, implement, create, update, fix)
    2. Score complexity (0-7 scale)
    3. Determine execution path:
       - Score 0-2: Simple (direct execution)
       - Score 3-4: Moderate (lightweight plan)
       - Score 5-7: Complex (full plan with research)
    4. Set routing flags for stage 3
  </process>
  <checkpoint>Complexity assessed, execution path determined</checkpoint>
</stage>
```

**Routing Logic**:
```
Simple Path:
  /task → task-executor → direct execution → single commit → brief summary

Complex Path:
  /task → task-executor → research → plan → implement → commit per phase → structured summary
```

### Priority 4: Update batch-task-orchestrator Return Format

**Current** (lines 344-398):
```json
{
  "task_results": {
    "63": {full_details},
    "64": {full_details},
    // ... full details for every task
  }
}
```

**Recommended**:
```json
{
  "batch_execution": {
    "total_tasks": 6,
    "completed": 5,
    "failed": 1,
    "execution_time": "25m"
  },
  "task_summaries": [
    {
      "task_number": 63,
      "status": "completed",
      "summary": "Brief one-line summary",
      "artifacts": ["specs/063_*/"]
    },
    // ... brief summaries only
  ],
  "failed_tasks": [
    {
      "task_number": 64,
      "error": "Brief error message",
      "recommendation": "Brief fix suggestion"
    }
  ],
  "next_steps": "Brief recommendations"
}
```

**Impact**: Reduces batch return from 1000+ lines to ~50 lines for 10 tasks.

### Priority 5: Differentiate Git Commit Patterns

**Update task.md** (line 101):

```markdown
<git_commits>
  Simple tasks (no plan):
    - Single commit after completion
    - Stage only task-relevant files
    - Format: "<area>: <summary> (task NNN)"
    - Example: "docs: add missing READMEs (task 169)"
  
  Complex tasks (multi-phase plan):
    - Commit after each phase completion
    - Stage only phase-relevant files
    - Format: "<area>: <summary> (task NNN, phase N)"
    - Examples:
      - "research: context window protection (task 169, phase 1)"
      - "plan: /task improvements (task 169, phase 2)"
      - "implement: artifact-first returns (task 169, phase 3)"
</git_commits>
```

**Update implementation-orchestrator**:
- Add git commit step after each phase completion
- Use git-workflow-manager for scoped commits
- Include phase number in commit message

### Priority 6: Add Validation for Artifact-First Returns

**New Validation Rule** (add to task-executor and batch-task-orchestrator):

```markdown
<return_validation>
  <max_response_size>500 tokens</max_response_size>
  <required_fields>
    - task_number
    - status
    - artifacts (array of paths)
    - summary (3-5 sentences max)
    - key_metrics (object)
  </required_fields>
  <forbidden_fields>
    - full_content
    - detailed_results
    - verbose_output
  </forbidden_fields>
  <enforcement>
    If response exceeds max_response_size:
      1. Log warning
      2. Truncate to summary + artifacts only
      3. Recommend creating summary artifact
  </enforcement>
</return_validation>
```

## Risks & Mitigations

### Risk 1: Breaking Changes to Existing Workflows

**Risk**: Changing return formats may break existing command integrations.

**Mitigation**:
- Implement changes incrementally
- Add backward compatibility layer for transition period
- Update all commands that consume task-executor/batch-task-orchestrator responses
- Test thoroughly before deployment

### Risk 2: Summary Quality Variance

**Risk**: Automated summaries may miss important details or be too generic.

**Mitigation**:
- Provide clear summary templates
- Include examples of good vs bad summaries
- Implement summary quality checks (length, structure, content)
- Allow manual summary refinement when needed

### Risk 3: Complexity Assessment Accuracy

**Risk**: Objective complexity metrics may misclassify tasks.

**Mitigation**:
- Use multiple indicators (7 total) for robust classification
- Allow manual override with --simple or --complex flags
- Log complexity scores for review and tuning
- Iterate on scoring thresholds based on real usage

### Risk 4: Git Commit Overhead for Complex Tasks

**Risk**: Committing after each phase may create too many small commits.

**Mitigation**:
- Only commit when phase produces artifacts (not for status-only updates)
- Allow commit squashing in final review
- Document rationale for phase-based commits (rollback points, granularity)
- Consider batching related phases if appropriate

## Appendix

### A. Current File Structure

```
.opencode/
├── command/
│   └── task.md                          # /task command definition
├── agent/
│   └── subagents/
│       ├── task-executor.md             # Single task execution
│       ├── batch-task-orchestrator.md   # Batch task execution
│       └── specialists/
│           ├── batch-status-manager.md  # TODO.md batch updates
│           └── status-sync-manager.md   # Multi-file status sync
└── context/
    └── common/
        ├── system/
        │   ├── artifact-management.md   # Artifact standards
        │   ├── status-markers.md        # Status marker spec
        │   └── git-commits.md           # Git commit standards
        └── standards/
            ├── report.md                # Report format standard
            └── plan.md                  # Plan format standard
```

### B. Complexity Scoring Matrix

| Indicator | Simple (0) | Moderate (1) | Complex (2) |
|-----------|------------|--------------|-------------|
| Effort | <30 min | 30min-2hr | >2hr |
| Files | 1-2 | 2-3 | 4+ |
| LOC | <100 | 100-500 | >500 |
| Dependencies | None | Some | Many |
| Research | No | Minor | Yes |
| Unknowns | Clear | Minor | Unclear |
| Risk | Low | Medium | High |

**Total Score**: 0-14 (sum of all indicators)
- 0-4: Simple → Direct execution path
- 5-9: Moderate → Lightweight plan path
- 10-14: Complex → Full plan path with research

### C. Summary Templates

#### Simple Task Summary Template

```markdown
# Task {number}: {title}

Completed {task_type} task affecting {file_count} files. {Brief description of changes}. Status: {status}. {Next step if applicable}.

**Files Modified**: {file_list}
**Execution Time**: {time}
```

#### Complex Task Summary Template

```markdown
# Task {number}: {title}

## Overview
{2-3 sentence overview of task and approach}

## Artifacts Created
- Research: {path or "N/A"}
- Plan: {path}
- Implementation: {path or "In Progress"}
- Summary: {path}

## Key Outcomes
- {outcome_1}
- {outcome_2}
- {outcome_3}

## Status
{Current status and completion percentage}

## Next Steps
{Brief next steps or "Task complete"}

**Full Details**: See artifacts above
```

### D. Implementation Checklist

**Phase 1: Update Return Formats**
- [ ] Update task-executor return format (lines 559-706)
- [ ] Update batch-task-orchestrator return format (lines 344-398)
- [ ] Add return validation rules
- [ ] Test with sample tasks

**Phase 2: Enforce Summary Artifacts**
- [ ] Add summary creation to task-executor stages 5, 6, 8
- [ ] Create summary templates
- [ ] Update artifact-management.md with summary requirements
- [ ] Test summary generation

**Phase 3: Implement Complexity Router**
- [ ] Add complexity assessment stage to /task command
- [ ] Implement scoring algorithm
- [ ] Add routing logic for simple/complex paths
- [ ] Test with various task types

**Phase 4: Differentiate Git Commits**
- [ ] Update task.md with git commit patterns
- [ ] Update implementation-orchestrator for phase-based commits
- [ ] Update task-executor for single commits
- [ ] Test commit patterns

**Phase 5: Integration Testing**
- [ ] Test single simple task execution
- [ ] Test single complex task execution
- [ ] Test batch execution with mixed complexity
- [ ] Test error scenarios
- [ ] Validate context window usage

**Phase 6: Documentation**
- [ ] Update command documentation
- [ ] Update agent documentation
- [ ] Add examples to standards
- [ ] Create migration guide

### E. References

**Internal Documentation**:
- .opencode/command/task.md - /task command specification
- .opencode/agent/subagents/task-executor.md - Task executor agent
- .opencode/agent/subagents/batch-task-orchestrator.md - Batch orchestrator
- .opencode/context/core/system/artifact-management.md - Artifact standards
- .opencode/context/core/standards/status-markers.md - Status markers
- .opencode/context/core/system/git-commits.md - Git commit standards

**External Research**:
- Anthropic's "Building Effective Agents" (Dec 2024)
- Prompt Engineering Guide: Orchestrator-Workers Pattern
- Academic research on LLM agent architectures
- Industry best practices for distributed agent systems

### F. Anti-Patterns to Avoid

**Anti-Pattern 1: Full Content Returns**
```json
// BAD
{
  "artifacts": ["path/to/plan.md"],
  "plan_content": "... 500 lines of plan content ...",
  "full_details": "... 200 lines of details ..."
}

// GOOD
{
  "artifacts": ["path/to/plan.md"],
  "summary": "Created 3-phase implementation plan for task 169. Phases: research, implement, test. Estimated 4 hours total."
}
```

**Anti-Pattern 2: Nested Full Results**
```json
// BAD
{
  "task_results": {
    "63": {
      "coordinator_results": {
        "full_output": "...",
        "detailed_logs": "..."
      }
    }
  }
}

// GOOD
{
  "task_summaries": [
    {
      "task_number": 63,
      "status": "completed",
      "summary": "Brief summary",
      "artifacts": ["path"]
    }
  ]
}
```

**Anti-Pattern 3: No Complexity Differentiation**
```
// BAD: All tasks follow same path
Task 1 (simple) → research → plan → implement
Task 2 (complex) → research → plan → implement

// GOOD: Differentiated paths
Task 1 (simple) → direct implement
Task 2 (complex) → research → plan → implement
```

**Anti-Pattern 4: Blanket Git Commits**
```bash
# BAD
git add -A
git commit -m "Updated files"

# GOOD
git add .opencode/command/task.md .opencode/agent/subagents/task-executor.md
git commit -m "implement: enforce artifact-first returns (task 169, phase 3)"
```

---

**Report Status**: [IN PROGRESS]
**Next Steps**: Create implementation plan based on these recommendations
