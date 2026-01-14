# Research Report: Refactor /meta Command to Create Tasks Instead of Direct Implementation

**Task**: 306 - Refactor /meta command to create tasks instead of direct implementation  
**Started**: 2026-01-05  
**Completed**: 2026-01-05  
**Effort**: 4 hours  
**Priority**: High  
**Dependencies**: None  
**Sources/Inputs**: 
- .opencode/command/meta.md (current command implementation)
- .opencode/agent/subagents/meta.md (current meta agent)
- .opencode/command/task.md (task creation reference)
- .opencode/agent/subagents/task-creator.md (deprecated, reference only)
- .opencode/specs/271_revise_meta_command_task_creation/reports/research-001.md (prior research)
- .opencode/specs/294_revise_meta_command_to_accept_optional_task_number/reports/research-001.md (related research)
- .opencode/agent/subagents/meta/ (5 meta subagents: domain-analyzer, workflow-designer, agent-generator, command-creator, context-organizer)

**Artifacts**: 
- .opencode/specs/306_refactor_meta_command_to_create_tasks_instead_of_direct_implementation/reports/research-001.md

**Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

---

## Executive Summary

This research analyzes the current /meta command implementation and proposes a comprehensive refactoring to align it with the task creation pattern used by /task command. The key change is to have /meta create tasks with plan artifacts instead of directly implementing the system generation work. This preserves the valuable interview functionality for requirements gathering while following the research → plan → implement workflow pattern.

**Key Findings**:
1. Current /meta command implements an 8-stage workflow that directly generates system files (agents, commands, context) via 5 meta subagents
2. Task 271 already researched this problem and proposed creating tasks with research + plan artifacts
3. /task command provides a proven pattern: create task entries atomically via status-sync-manager delegation
4. /meta should preserve interview functionality (Stages 0-6) but replace Stage 7 (GenerateSystem) with CreateTasksWithArtifacts
5. Interview results provide all context needed to generate plan artifacts without implementation
6. Backward compatibility can be maintained with existing prompt mode and interactive mode

**Recommendations**:
1. Keep /meta command Stages 0-6 unchanged (interview and requirements gathering)
2. Replace Stage 7 (GenerateSystem) with CreateTasksWithArtifacts following /task pattern
3. Create plan artifacts (plans/implementation-001.md) for each task, NOT research artifacts
4. Delegate to status-sync-manager for atomic task creation (same as /task command)
5. Update Stage 8 to deliver task summary instead of completed system
6. Preserve interview functionality - this is /meta's unique value proposition

---

## Context & Scope

### Research Objective

Analyze the current /meta command implementation and design a refactoring that:
1. Creates tasks with plan artifacts instead of directly implementing system generation
2. Preserves the interview functionality for requirements clarification
3. Follows the /task command pattern for atomic task creation
4. Maintains backward compatibility with prompt mode and interactive mode
5. Enables review and approval before implementation

### Current /meta Command Behavior

The /meta command currently supports two modes:

**1. Prompt Mode** (with $ARGUMENTS):
- User provides requirements: `/meta "I want to revise my opencode system..."`
- Skips Stage 1 (InitiateInterview)
- Parses target_domain from $ARGUMENTS
- Proceeds to Stage 2 with pre-populated context
- Executes Stages 2-8 to generate complete system

**2. Interactive Mode** (no $ARGUMENTS):
- User provides no arguments: `/meta`
- Executes full 8-stage interactive interview
- Gathers requirements through guided questions
- Generates complete system based on interview results

**Current 8-Stage Workflow**:
- Stage 0: DetectExistingProject - Scan for .opencode, offer merge strategies
- Stage 1: InitiateInterview - Explain process, set expectations (CONDITIONAL: skip if prompt mode)
- Stage 2: GatherDomainInformation - Collect domain, purpose, target users
- Stage 3: IdentifyUseCases - Explore 3-5 use cases, assess complexity
- Stage 4: AssessComplexity - Determine agent count, hierarchy, knowledge requirements
- Stage 5: IdentifyIntegrations - Discover external tools, file operations, custom commands
- Stage 6: ReviewAndConfirm - Present architecture summary, get user confirmation
- Stage 7: GenerateSystem - **DIRECTLY IMPLEMENTS** by delegating to 5 meta subagents
- Stage 8: DeliverSystem - Present completed system, create git commit

**Problem**: Stage 7 directly implements the system without creating reviewable tasks or plan artifacts.

---

## Key Findings

### Finding 1: Current Stage 7 Directly Implements System Generation

**Current Stage 7 (GenerateSystem)** delegates to 5 meta subagents to create files:

```xml
<stage id="7" name="GenerateSystem">
  <action>Delegate to meta subagents to create all system components</action>
  <process>
    1. Delegate to domain-analyzer:
       - Generate domain analysis report
       - Recommend structure based on domain type
    
    2. Delegate to workflow-designer:
       - Create workflow definitions
       - Define stages and dependencies
    
    3. Delegate to agent-generator:
       - Create agent files in .opencode/agent/subagents/{domain}/
       - Generate orchestrator if hierarchical
       - Generate specialized subagents
    
    4. Delegate to command-creator:
       - Create command files in .opencode/command/
       - Implement custom slash commands
    
    5. Delegate to context-organizer:
       - Create context files in .opencode/context/{domain}/
       - Organize knowledge areas
       - Create integration guides
    
    6. Validate all artifacts:
       - Verify existence and non-empty
       - Validate YAML frontmatter
       - Check size limits
  </process>
</stage>
```

**Problems**:
1. No user review before implementation - system is generated and committed immediately
2. Violates research → plan → implement workflow used by other commands
3. No artifact links - generated files are not linked to plan artifacts
4. Monolithic execution - all work happens in one command with no checkpoints
5. No task breakdown - complex system generation is not broken into reviewable tasks

### Finding 2: Task 271 Already Researched This Problem

Task 271 ("Revise /meta command to create tasks with linked artifacts") already conducted comprehensive research on this exact problem. Key insights from that research:

**Proposed Solution from Task 271**:
- Keep Stages 0-6 unchanged (interview and design)
- Replace Stage 7 with CreateTasksWithArtifacts
- Create tasks with research + plan artifacts
- Use task breakdown strategy based on complexity:
  - Simple system (1-2 agents): 4 tasks
  - Moderate system (3-5 agents): 7 tasks
  - Complex system (6-8 agents): 10-15 tasks

**Artifact Structure Proposed**:
```
.opencode/specs/NNN_task_name/
├── reports/
│   └── research-001.md          # Domain analysis, requirements
├── plans/
│   └── implementation-001.md    # Implementation plan with phases
└── summaries/
    ├── research-summary.md      # Brief summary (<100 tokens)
    └── plan-summary.md          # Brief summary (<100 tokens)
```

**CRITICAL INSIGHT**: Task 271 proposed creating BOTH research and plan artifacts. However, this is unnecessary complexity. The interview results (Stages 0-6) already provide all the research context. We only need to create PLAN artifacts.

### Finding 3: /task Command Provides Proven Pattern

The /task command (recently optimized in v5.0.0) provides a proven pattern for task creation:

**Key Pattern Elements**:
1. **Direct delegation to status-sync-manager** (no intermediate subagent)
2. **Atomic task creation** (both TODO.md and state.json or neither)
3. **Inline description reformulation** (simple transformations, no subagent)
4. **Language detection from keywords** (fast, accurate)
5. **Validation before delegation** (fail fast)

**Execution Flow**:
```
Stage 1: ParseInput
  - Extract description from $ARGUMENTS
  - Extract flags (--priority, --effort, --language, --divide)
  - Validate inputs

Stage 2: ReformulateDescription
  - Clean and normalize description
  - Generate title from description
  - Detect language if not provided

Stage 3: DivideIfRequested
  - If --divide flag: divide into 1-5 subtasks
  - Else: single task

Stage 4: CreateTasks
  - For each task: delegate to status-sync-manager
  - Collect task numbers
  - Handle errors with rollback

Stage 5: ReturnSuccess
  - Format success message
  - Return task numbers and next steps
```

**Performance**: 3-5s for single task, 9-12s for 5 tasks (40-50% improvement from v4.0.0)

**CRITICAL INSIGHT**: /meta should follow this pattern - delegate directly to status-sync-manager for task creation, not to an intermediate subagent.

### Finding 4: Interview Results Provide All Context for Plan Artifacts

The interview stages (0-6) gather comprehensive information that can be used to generate plan artifacts:

**Stage 0 (DetectExistingProject)**:
- integration_mode: "new" | "extend" | "separate" | "replace"

**Stage 2 (GatherDomainInformation)**:
- domain: String (e.g., "formal verification")
- purpose: String (e.g., "add proof verification capabilities")
- target_users: String (e.g., "researchers and theorem provers")
- domain_type: "formal_verification" | "development" | "business" | "hybrid" | "general"

**Stage 3 (IdentifyUseCases)**:
- use_cases: Array of {description, complexity, dependencies, priority}
- Example: [{description: "Research proof strategies", complexity: "moderate", dependencies: [], priority: "high"}]

**Stage 4 (AssessComplexity)**:
- agent_count: 1-8
- hierarchy: "flat" | "hierarchical"
- knowledge_areas: Array of strings (3-5 items)
- needs_state_management: boolean

**Stage 5 (IdentifyIntegrations)**:
- external_tools: Array of strings
- file_types: Array of strings
- custom_commands: Array of {name, description}

**Stage 6 (ReviewAndConfirm)**:
- User confirmation of architecture

**CRITICAL INSIGHT**: This information is sufficient to generate detailed plan artifacts for each task WITHOUT needing separate research artifacts. The interview results ARE the research.

### Finding 5: Plan Artifacts Should Follow plan.md Standard

Plan artifacts should follow the plan.md template standard:

**Required Sections**:
1. **Metadata Block**:
   - Task: {number} - {title}
   - Status: [NOT STARTED]
   - Effort: {estimate}
   - Priority: {High|Medium|Low}
   - Dependencies: {list or None}
   - Research Inputs: Interview results from /meta command
   - Artifacts: {list of artifacts to be created}
   - Standards: {list of standards to follow}
   - Language: {meta}

2. **Overview** (2-4 sentences)
3. **Goals & Non-Goals**
4. **Risks & Mitigations**
5. **Implementation Phases** (with status markers)
6. **Testing & Validation**
7. **Artifacts & Outputs**
8. **Rollback/Contingency**

**Example Plan Content for "Create Domain-Specific Agents" Task**:

```markdown
# Implementation Plan: Create Domain-Specific Agents

**Task**: 303 - Create domain-specific agents for formal verification system  
**Status**: [NOT STARTED]  
**Effort**: 6-8 hours  
**Priority**: High  
**Dependencies**: Task 302 (Design architecture and workflow patterns)  
**Research Inputs**: /meta interview results (domain: formal verification, agents: 3, hierarchy: hierarchical)  
**Artifacts**: 
- .opencode/agent/subagents/formal_verification/orchestrator.md
- .opencode/agent/subagents/formal_verification/proof-researcher.md
- .opencode/agent/subagents/formal_verification/proof-implementer.md

**Standards**: agent-workflow.md, subagent-structure.md, frontmatter-delegation.md  
**Language**: meta

---

## Overview

Create 3 specialized agents for formal verification system: orchestrator (coordinates workflows), proof-researcher (researches proof strategies), and proof-implementer (implements proofs in Lean 4). Agents follow hierarchical architecture with orchestrator delegating to specialized subagents.

## Goals & Non-Goals

**Goals**:
- Create orchestrator agent with 8-stage workflow
- Create proof-researcher agent with research capabilities
- Create proof-implementer agent with Lean 4 integration
- Follow frontmatter delegation pattern (<300 lines per file)
- Include proper YAML frontmatter with permissions

**Non-Goals**:
- Creating context files (separate task)
- Creating custom commands (separate task)
- Implementing proof verification logic (done by agents later)

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Agent files too large (>300 lines) | Use frontmatter delegation, move workflow to agent body |
| Missing permissions | Reference existing agents for permission patterns |
| Incorrect delegation paths | Validate can_delegate_to lists |

## Implementation Phases

### Phase 1: Create Orchestrator Agent [NOT STARTED]
- Create .opencode/agent/subagents/formal_verification/orchestrator.md
- Add YAML frontmatter with delegation config
- Implement 8-stage workflow
- Define delegation to proof-researcher and proof-implementer

### Phase 2: Create Proof-Researcher Agent [NOT STARTED]
- Create .opencode/agent/subagents/formal_verification/proof-researcher.md
- Add YAML frontmatter with research permissions
- Implement research workflow
- Add Loogle/LeanSearch integration

### Phase 3: Create Proof-Implementer Agent [NOT STARTED]
- Create .opencode/agent/subagents/formal_verification/proof-implementer.md
- Add YAML frontmatter with write permissions
- Implement implementation workflow
- Add lean-lsp-mcp integration

### Phase 4: Validation [NOT STARTED]
- Verify all agents have valid YAML frontmatter
- Verify delegation paths are correct
- Verify file sizes <300 lines
- Test agent invocation via task tool

## Testing & Validation

- [ ] All agent files created in correct directory
- [ ] YAML frontmatter valid (parse with yq)
- [ ] File sizes <300 lines
- [ ] Delegation paths correct
- [ ] Permissions appropriate for agent role
- [ ] Agents follow 8-stage workflow pattern

## Artifacts & Outputs

- orchestrator.md (250-300 lines)
- proof-researcher.md (200-250 lines)
- proof-implementer.md (200-250 lines)

## Rollback/Contingency

If agent creation fails:
- Remove created agent files
- Revert to previous state
- Review error logs
- Adjust plan and retry
```

**CRITICAL INSIGHT**: Plan artifacts can be generated from interview results without requiring separate research phase.

### Finding 6: Task Breakdown Strategy Based on Complexity

Based on interview results, determine appropriate task breakdown:

**Simple System** (1-2 agents, 3-4 use cases): **4 tasks**
- Task 1: Design architecture and workflow patterns (planning task)
- Task 2: Create agents
- Task 3: Create commands
- Task 4: Create context files and documentation

**Moderate System** (3-5 agents, 4-6 use cases): **7 tasks**
- Task 1: Design architecture and workflow patterns (planning task)
- Task 2: Create orchestrator agent
- Task 3: Create subagent group 1 (e.g., research agents)
- Task 4: Create subagent group 2 (e.g., implementation agents)
- Task 5: Create custom commands
- Task 6: Create context files
- Task 7: Create documentation and integration guides

**Complex System** (6-8 agents, 7+ use cases): **10-15 tasks**
- Task 1: Design architecture and workflow patterns (planning task)
- Task 2: Create orchestrator agent
- Tasks 3-N: Create individual subagents (one task per agent)
- Task N+1: Create custom commands (group by workflow)
- Task N+2: Create context files (group by domain area)
- Task N+3: Create documentation and integration guides

**CRITICAL INSIGHT**: First task is always a planning task that creates detailed architecture design. Subsequent tasks implement components based on that design.

### Finding 7: Backward Compatibility Can Be Maintained

The refactoring can maintain backward compatibility with existing usage patterns:

**Mode Detection**:
```bash
# Check if $ARGUMENTS is empty
if [ -z "$ARGUMENTS" ]; then
  mode="interactive"
  # Execute full 8-stage interview
else
  mode="prompt"
  target_domain="$ARGUMENTS"
  # Parse target_domain and proceed with adaptive interview
fi
```

**Both modes** will now create tasks instead of directly implementing:
- **Prompt Mode**: Parse requirements from prompt → Skip Stage 1 → Execute Stages 2-8 → Create tasks
- **Interactive Mode**: Execute full interview Stages 1-8 → Create tasks

**User Experience Change**:
- **Before**: `/meta "..."` → Complete system generated immediately
- **After**: `/meta "..."` → Tasks created with plan artifacts → User runs `/implement {number}` for each task

**CRITICAL INSIGHT**: This is a breaking change in behavior but maintains API compatibility. Users will need to adjust workflow to review plans and run /implement.

---

## Detailed Analysis

### Analysis 1: Comparison of Current vs. Proposed Stage 7

**Current Stage 7 (GenerateSystem)**:
```xml
<stage id="7" name="GenerateSystem">
  <action>Delegate to meta subagents to create all system components</action>
  <process>
    1. Delegate to domain-analyzer → Generate domain analysis report
    2. Delegate to workflow-designer → Create workflow definitions
    3. Delegate to agent-generator → Create agent files
    4. Delegate to command-creator → Create command files
    5. Delegate to context-organizer → Create context files
    6. Validate all artifacts
  </process>
  <validation>
    - All artifacts must exist and be non-empty
    - YAML frontmatter must be valid
    - File sizes must be within limits
  </validation>
  <checkpoint>System components generated and validated</checkpoint>
</stage>
```

**Proposed Stage 7 (CreateTasksWithArtifacts)**:
```xml
<stage id="7" name="CreateTasksWithArtifacts">
  <action>Create tasks with plan artifacts for each component</action>
  <process>
    1. Read next_project_number from .opencode/specs/state.json
    
    2. Determine task breakdown based on complexity:
       - Simple (1-2 agents): 4 tasks
       - Moderate (3-5 agents): 7 tasks
       - Complex (6-8 agents): 10-15 tasks
    
    3. For each task in breakdown:
       a. Generate task title and slug from interview results
       b. Assign task number: next_project_number + task_index
       c. Create project directory: .opencode/specs/{number}_{slug}/
       d. Generate plan artifact: plans/implementation-001.md
          - Use interview results as context
          - Follow plan.md template standard
          - Include phases, effort estimates, acceptance criteria
       e. Delegate to status-sync-manager for atomic task creation:
          - operation: "create_task"
          - task_number: {number}
          - title: {title}
          - description: {description}
          - priority: {priority}
          - effort: {effort}
          - language: "meta"
          - new_status: "not_started"
       f. Collect task_number from return
    
    4. Validate all tasks created:
       - Verify task_numbers are sequential
       - Verify plan artifacts exist and are non-empty
       - Verify TODO.md and state.json updated
    
    5. If validation fails:
       - Log errors
       - Return status "failed" with error details
    
    6. If validation passes:
       - Collect all task numbers and artifact paths
       - Proceed to Stage 8
  </process>
  <validation>
    - All tasks must have project directories
    - All plan artifacts must exist and be non-empty
    - Task entries must follow tasks.md standard
    - state.json must be updated correctly
  </validation>
  <checkpoint>Tasks created with plan artifacts</checkpoint>
</stage>
```

**Key Differences**:
1. **Artifacts**: Current creates agent/command/context files → Proposed creates plan artifacts only
2. **Delegation**: Current delegates to 5 meta subagents → Proposed delegates to status-sync-manager
3. **Atomicity**: Current has no rollback → Proposed uses status-sync-manager atomic updates
4. **Validation**: Current validates generated files → Proposed validates task creation
5. **Output**: Current delivers complete system → Proposed delivers task list

### Analysis 2: Plan Artifact Generation Strategy

**Plan Artifact Content Generation**:

For each task, generate plan artifact from interview results:

**Task 1 (Planning Task)**: "Design architecture and workflow patterns"
- **Overview**: Design detailed architecture for {domain} system based on interview results
- **Goals**: Create architecture document, workflow definitions, agent specifications
- **Phases**:
  1. Document domain requirements (from Stage 2)
  2. Design agent architecture (from Stage 4)
  3. Define workflows (from Stage 3 use cases)
  4. Specify integrations (from Stage 5)
  5. Create validation criteria
- **Artifacts**: architecture.md, workflows.md, agent-specs.md

**Task 2-N (Implementation Tasks)**: "Create {component}"
- **Overview**: Implement {component} based on architecture design from Task 1
- **Goals**: Create {specific files} following {standards}
- **Phases**:
  1. Review architecture design
  2. Create {component} files
  3. Validate {component} structure
  4. Test {component} functionality
- **Artifacts**: {list of files to create}

**Generation Process**:
```python
def generate_plan_artifact(task_info, interview_results):
    """Generate plan artifact from interview results"""
    
    # Extract relevant context
    domain = interview_results['domain']
    purpose = interview_results['purpose']
    use_cases = interview_results['use_cases']
    agent_count = interview_results['agent_count']
    hierarchy = interview_results['hierarchy']
    knowledge_areas = interview_results['knowledge_areas']
    external_tools = interview_results['external_tools']
    custom_commands = interview_results['custom_commands']
    
    # Generate plan content
    plan = f"""# Implementation Plan: {task_info['title']}

**Task**: {task_info['number']} - {task_info['title']}
**Status**: [NOT STARTED]
**Effort**: {task_info['effort']}
**Priority**: {task_info['priority']}
**Dependencies**: {task_info['dependencies']}
**Research Inputs**: /meta interview results (domain: {domain}, purpose: {purpose})
**Artifacts**: {task_info['artifacts']}
**Standards**: {task_info['standards']}
**Language**: meta

---

## Overview

{generate_overview(task_info, interview_results)}

## Goals & Non-Goals

**Goals**:
{generate_goals(task_info, interview_results)}

**Non-Goals**:
{generate_non_goals(task_info, interview_results)}

## Risks & Mitigations

{generate_risks(task_info, interview_results)}

## Implementation Phases

{generate_phases(task_info, interview_results)}

## Testing & Validation

{generate_validation_criteria(task_info, interview_results)}

## Artifacts & Outputs

{generate_artifact_list(task_info, interview_results)}

## Rollback/Contingency

{generate_rollback_plan(task_info, interview_results)}
"""
    
    return plan
```

**CRITICAL INSIGHT**: Plan generation can be fully automated from interview results without requiring LLM calls for each plan. Use template-based generation with interview data.

### Analysis 3: Status-Sync-Manager Delegation Pattern

**Delegation to status-sync-manager** (same pattern as /task command):

```bash
# For each task in task_list
for task in "${task_list[@]}"; do
  # Prepare task metadata
  task_number="${task[number]}"
  title="${task[title]}"
  description="${task[description]}"
  priority="${task[priority]}"
  effort="${task[effort]}"
  
  # Delegate to status-sync-manager
  result=$(task \
    subagent_type="status-sync-manager" \
    prompt="Create task with operation=create_task, task_number=${task_number}, title=${title}, description=${description}, priority=${priority}, effort=${effort}, language=meta, new_status=not_started" \
    description="Create task entry atomically")
  
  # Parse result
  status=$(echo "$result" | jq -r '.status')
  
  # Validate success
  if [ "$status" != "completed" ]; then
    echo "[ERROR] Failed to create task ${task_number}"
    return 1
  fi
  
  # Collect task number
  created_tasks+=("$task_number")
done
```

**Atomic Updates**:
- status-sync-manager updates both TODO.md and state.json atomically
- If either update fails, both are rolled back
- No partial state possible

**Error Handling**:
- If task creation fails, stop immediately
- Return error with details of which task failed
- List successfully created tasks (if any)
- status-sync-manager handles rollback automatically

**CRITICAL INSIGHT**: Use status-sync-manager for ALL task creation to ensure atomic updates and automatic rollback.

### Analysis 4: Stage 8 Transformation

**Current Stage 8 (DeliverSystem)**:
```xml
<stage id="8" name="DeliverSystem">
  <action>Present completed system and create git commit</action>
  <process>
    1. Generate README.md in .opencode/agent/subagents/{domain}/
    2. Update TODO.md with task entries (marked as completed)
    3. Create git commit via git-workflow-manager
    4. Present completed system to user
  </process>
</stage>
```

**Proposed Stage 8 (DeliverTaskSummary)**:
```xml
<stage id="8" name="DeliverTaskSummary">
  <action>Present task list with plan artifact links and usage instructions</action>
  <process>
    1. Present task list to user:
       "I've created {N} tasks for your {domain} system:
       
       TASKS CREATED:
       {for each task:}
       - Task {number}: {title}
         - Plan: {plan_artifact_path}
         - Status: [NOT STARTED]
       
       NEXT STEPS:
       1. Review the plan artifacts for each task
       2. Run `/implement {task_number}` for each task when ready
       3. Tasks can be implemented in order or in parallel (if no dependencies)
       
       To get started, review Task {first_task_number} plan:
       - {first_plan_path}
       
       Then run: `/implement {first_task_number}`"
    
    2. Create git commit:
       - Delegate to git-workflow-manager
       - Message: "meta: create tasks for {domain} system ({N} tasks)"
       - Include: TODO.md, state.json, all task directories with plans
    
    3. Return standardized format:
       {
         "status": "completed",
         "summary": "Created {N} tasks for {domain} system with plan artifacts",
         "artifacts": [
           {for each task:}
           {
             "type": "task",
             "task_number": {number},
             "title": "{title}",
             "plan_path": "{path}",
             "status": "[NOT STARTED]"
           }
         ],
         "metadata": {
           "domain": "{domain}",
           "task_count": {N},
           "first_task_number": {number},
           "last_task_number": {number},
           "integration_mode": "{integration_mode}",
           "timestamp": "{ISO8601}"
         },
         "session_id": "{session_id}",
         "next_steps": "Review plan artifacts and run /implement for each task"
       }
  </process>
  <validation>
    - Task list must be complete
    - Git commit must succeed
    - Return format must match subagent-return-format.md
  </validation>
  <checkpoint>Task summary delivered</checkpoint>
</stage>
```

**Key Changes**:
1. **Output**: Complete system → Task list with plan links
2. **Instructions**: System usage → Review plans and run /implement
3. **Git Commit**: System files → Task directories with plans
4. **Return Format**: System summary → Task metadata

---

## Decisions

### Decision 1: Create Plan Artifacts Only (Not Research Artifacts)

**Decision**: Create ONLY plan artifacts (plans/implementation-001.md), NOT research artifacts.

**Rationale**:
- Interview results (Stages 0-6) already provide all research context
- Creating separate research artifacts would duplicate interview information
- Plan artifacts can reference interview results as "Research Inputs"
- Simpler artifact structure reduces complexity
- Faster execution (no research artifact generation)

**Alternative Considered**: Create both research and plan artifacts (as proposed in Task 271)
**Rejected Because**: Unnecessary duplication, slower execution, more complex validation

### Decision 2: Delegate Directly to status-sync-manager (Not task-creator)

**Decision**: Delegate directly to status-sync-manager for task creation, following /task command pattern.

**Rationale**:
- /task command v5.0.0 eliminated task-creator layer for 40-50% performance improvement
- task-creator is now deprecated (marked in frontmatter)
- Direct delegation ensures atomic updates
- Simpler delegation chain reduces failure points
- Consistent with current best practices

**Alternative Considered**: Delegate to task-creator subagent
**Rejected Because**: task-creator is deprecated, adds unnecessary layer, slower performance

### Decision 3: Preserve Interview Functionality (Stages 0-6 Unchanged)

**Decision**: Keep interview stages (0-6) completely unchanged.

**Rationale**:
- Interview functionality is /meta's unique value proposition
- Provides structured requirements gathering
- Enables clarification and validation before task creation
- Supports both prompt mode and interactive mode
- No need to change what works well

**Alternative Considered**: Simplify interview to reduce stages
**Rejected Because**: Current interview provides valuable structure and validation

### Decision 4: Use Template-Based Plan Generation

**Decision**: Generate plan artifacts using templates populated with interview results, not LLM calls.

**Rationale**:
- Interview results provide all necessary context
- Template-based generation is deterministic and fast
- No additional LLM calls needed (reduces latency and cost)
- Easier to validate and test
- Consistent plan structure across all tasks

**Alternative Considered**: Use LLM to generate custom plans for each task
**Rejected Because**: Slower, non-deterministic, unnecessary complexity

### Decision 5: Maintain Backward Compatibility with Mode Detection

**Decision**: Maintain existing mode detection (prompt vs interactive) but change behavior to create tasks instead of implementing.

**Rationale**:
- Preserves existing API (command signature unchanged)
- Users can still use `/meta "..."` or `/meta` patterns
- Behavior change is intentional (create tasks vs implement)
- Clear migration path for users

**Alternative Considered**: Add new flag like `--create-tasks` to opt into new behavior
**Rejected Because**: Adds complexity, delays migration, creates two code paths to maintain

---

## Recommendations

### Recommendation 1: Refactor Stage 7 to CreateTasksWithArtifacts

**Action**: Replace Stage 7 (GenerateSystem) with CreateTasksWithArtifacts following /task command pattern.

**Implementation**:
1. Read next_project_number from state.json
2. Determine task breakdown based on complexity (4, 7, or 10-15 tasks)
3. For each task:
   - Generate title, slug, description from interview results
   - Create project directory: .opencode/specs/{number}_{slug}/
   - Generate plan artifact: plans/implementation-001.md (template-based)
   - Delegate to status-sync-manager for atomic task creation
   - Collect task_number from return
4. Validate all tasks created successfully
5. Proceed to Stage 8 with task list

**Effort**: 2-3 hours (modify meta.md Stage 7)

### Recommendation 2: Update Stage 8 to DeliverTaskSummary

**Action**: Replace Stage 8 (DeliverSystem) with DeliverTaskSummary.

**Implementation**:
1. Present task list with plan artifact links
2. Provide usage instructions (review plans → run /implement)
3. Create git commit via git-workflow-manager (TODO.md, state.json, task directories)
4. Return standardized format with task metadata

**Effort**: 1 hour (modify meta.md Stage 8)

### Recommendation 3: Update Command Documentation

**Action**: Update .opencode/command/meta.md to reflect new behavior.

**Implementation**:
1. Update Workflow section (Stages 7-8 descriptions)
2. Update Artifacts section (plan artifacts instead of system files)
3. Update Usage section (add /implement step)
4. Add migration guide for existing users

**Effort**: 30 minutes

### Recommendation 4: Create Plan Generation Templates

**Action**: Create templates for plan artifact generation.

**Implementation**:
1. Create template for planning task (Task 1)
2. Create template for agent implementation tasks
3. Create template for command implementation tasks
4. Create template for context implementation tasks
5. Add helper functions to populate templates with interview results

**Effort**: 2 hours

### Recommendation 5: Test with Simple, Moderate, and Complex Systems

**Action**: Test refactored /meta command with all three complexity levels.

**Implementation**:
1. Test simple system (1-2 agents): Verify 4 tasks created
2. Test moderate system (3-5 agents): Verify 7 tasks created
3. Test complex system (6-8 agents): Verify 10-15 tasks created
4. Verify plan artifacts generated correctly
5. Verify task creation atomic (TODO.md + state.json)
6. Verify git commit includes all artifacts

**Effort**: 2 hours

---

## Risks & Mitigations

### Risk 1: Breaking Change for Existing Users

**Risk**: Users expect `/meta` to generate complete system immediately.

**Likelihood**: High  
**Impact**: Medium

**Mitigation**:
1. Update documentation with clear migration guide
2. Add deprecation notice to old behavior
3. Provide examples of new workflow (review plans → /implement)
4. Consider adding warning message on first use

### Risk 2: Plan Generation Quality

**Risk**: Template-based plan generation may produce lower quality plans than LLM-generated plans.

**Likelihood**: Medium  
**Impact**: Low

**Mitigation**:
1. Design comprehensive templates with all necessary sections
2. Use interview results to populate specific details
3. Test plan quality with real examples
4. Allow users to revise plans with /revise command

### Risk 3: Task Breakdown Complexity

**Risk**: Determining optimal task breakdown for complex systems may be difficult.

**Likelihood**: Medium  
**Impact**: Medium

**Mitigation**:
1. Use clear heuristics based on agent count and use cases
2. Provide task breakdown preview in Stage 6 (ReviewAndConfirm)
3. Allow user to adjust task breakdown before creation
4. Document task breakdown strategy in command documentation

### Risk 4: Performance Regression

**Risk**: Creating multiple tasks with plan artifacts may be slower than direct implementation.

**Likelihood**: Low  
**Impact**: Low

**Mitigation**:
1. Use template-based plan generation (fast, no LLM calls)
2. Delegate directly to status-sync-manager (no intermediate layers)
3. Parallelize plan artifact creation if possible
4. Benchmark performance and optimize if needed

---

## Appendix: Task Breakdown Examples

### Example 1: Simple System (Formal Verification)

**Interview Results**:
- Domain: Formal verification
- Agents: 2 (proof-researcher, proof-implementer)
- Use Cases: 3 (research strategies, implement proofs, verify proofs)
- Hierarchy: Flat
- Commands: 2 (/verify, /prove)

**Task Breakdown** (4 tasks):
1. Task 301: Design architecture and workflow patterns for formal verification system
2. Task 302: Create proof-researcher and proof-implementer agents
3. Task 303: Create /verify and /prove commands
4. Task 304: Create context files and documentation

### Example 2: Moderate System (Customer Support)

**Interview Results**:
- Domain: Customer support
- Agents: 4 (orchestrator, ticket-analyzer, response-generator, escalation-handler)
- Use Cases: 5 (analyze tickets, generate responses, escalate issues, track status, report metrics)
- Hierarchy: Hierarchical
- Commands: 4 (/ticket, /respond, /escalate, /report)

**Task Breakdown** (7 tasks):
1. Task 305: Design architecture and workflow patterns for customer support system
2. Task 306: Create orchestrator agent
3. Task 307: Create ticket-analyzer and response-generator agents
4. Task 308: Create escalation-handler agent
5. Task 309: Create /ticket, /respond, /escalate, /report commands
6. Task 310: Create context files (ticket templates, response patterns)
7. Task 311: Create documentation and integration guides

### Example 3: Complex System (Data Engineering)

**Interview Results**:
- Domain: Data engineering
- Agents: 7 (orchestrator, pipeline-designer, data-validator, transformer, loader, monitor, reporter)
- Use Cases: 8 (design pipelines, validate data, transform data, load data, monitor runs, generate reports, handle errors, optimize performance)
- Hierarchy: Hierarchical
- Commands: 6 (/pipeline, /validate, /transform, /load, /monitor, /report)

**Task Breakdown** (13 tasks):
1. Task 312: Design architecture and workflow patterns for data engineering system
2. Task 313: Create orchestrator agent
3. Task 314: Create pipeline-designer agent
4. Task 315: Create data-validator agent
5. Task 316: Create transformer agent
6. Task 317: Create loader agent
7. Task 318: Create monitor agent
8. Task 319: Create reporter agent
9. Task 320: Create /pipeline and /validate commands
10. Task 321: Create /transform and /load commands
11. Task 322: Create /monitor and /report commands
12. Task 323: Create context files (schemas, transformations, validation rules)
13. Task 324: Create documentation and integration guides

---

## Conclusion

The /meta command refactoring aligns it with the task creation pattern used by /task command while preserving its valuable interview functionality. By creating tasks with plan artifacts instead of directly implementing system generation, users gain the ability to review and approve designs before implementation. This follows the research → plan → implement workflow pattern and enables better control over system generation.

**Key Takeaways**:
1. Keep interview stages (0-6) unchanged - this is /meta's unique value
2. Replace Stage 7 with task creation following /task pattern
3. Create plan artifacts only (interview results provide research context)
4. Delegate directly to status-sync-manager for atomic updates
5. Update Stage 8 to deliver task summary instead of completed system
6. Use template-based plan generation for speed and consistency

**Estimated Implementation Effort**: 6-8 hours
- Stage 7 refactoring: 2-3 hours
- Stage 8 refactoring: 1 hour
- Plan templates: 2 hours
- Documentation updates: 30 minutes
- Testing: 2 hours
- Buffer: 30 minutes

**Next Steps**:
1. Create implementation plan for this refactoring
2. Implement Stage 7 (CreateTasksWithArtifacts)
3. Implement Stage 8 (DeliverTaskSummary)
4. Create plan generation templates
5. Update command documentation
6. Test with all complexity levels
7. Create migration guide for users
