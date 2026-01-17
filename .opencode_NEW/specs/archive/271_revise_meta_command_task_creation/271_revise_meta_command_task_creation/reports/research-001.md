# Research Report: Revise /meta Command to Create Tasks with Linked Artifacts

**Task**: 271 - Revise /meta command to create tasks with linked artifacts instead of implementing directly
**Status**: [RESEARCHING]
**Started**: 2026-01-03
**Language**: markdown
**Priority**: High

## Executive Summary

This research analyzes the current `/meta` command implementation and proposes a comprehensive revision to align it with the research → plan → implement workflow used by other ProofChecker commands. The key change is to have `/meta` create tasks with linked artifacts (research reports and implementation plans) instead of directly implementing the generated system.

## Current Implementation Analysis

### Current Workflow (8 Stages)

The `/meta` command currently implements a complete system generation workflow:

**Stages 0-6: Interview and Design**
- Stage 0: DetectExistingProject - Scan for .opencode directory, offer merge strategies
- Stage 1: InitiateInterview - Explain process, set expectations
- Stage 2: GatherDomainInformation - Collect domain, purpose, target users
- Stage 3: IdentifyUseCases - Explore 3-5 use cases, assess complexity
- Stage 4: AssessComplexity - Determine agent count, hierarchy, knowledge requirements
- Stage 5: IdentifyIntegrations - Discover external tools, file operations, custom commands
- Stage 6: ReviewAndConfirm - Present architecture summary, get user confirmation

**Stage 7: GenerateSystem (IMPLEMENTATION)**
- Delegates to 5 meta subagents to create files:
  - domain-analyzer: Domain analysis report, recommended structure
  - workflow-designer: Workflow definitions with stages and dependencies
  - agent-generator: Agent files (.opencode/agent/subagents/{domain}/*.md)
  - command-creator: Command files (.opencode/command/*.md)
  - context-organizer: Context files (.opencode/context/{domain}/*.md)
- Validates all artifacts (existence, non-empty, valid YAML frontmatter, size limits)

**Stage 8: DeliverSystem**
- Generates README.md in .opencode/agent/subagents/{domain}/
- Updates TODO.md with task entries (marked as completed)
- Creates git commit via git-workflow-manager
- Presents completed system to user

### Problems with Current Approach

1. **No User Review Before Implementation**: System is generated and committed without user review of the design
2. **Violates Research → Plan → Implement Workflow**: Other commands (research, plan, implement) follow a staged workflow with user checkpoints
3. **No Artifact Links**: Generated files are not linked to research artifacts or implementation plans
4. **Immediate Implementation**: No opportunity to review, revise, or approve the design before files are created
5. **Monolithic Execution**: All work happens in one command execution with no intermediate checkpoints
6. **No Task Breakdown**: Complex system generation is not broken into reviewable, implementable tasks

## Proposed Revision

### New Workflow (8 Stages)

**Stages 0-6: Interview and Design (UNCHANGED)**
- Keep existing interview stages exactly as-is
- These stages gather requirements and design the architecture
- User confirms the architecture design in Stage 6

**Stage 7: CreateTasksWithArtifacts (REVISED)**

Instead of generating the system, create tasks with linked artifacts:

1. **Determine Task Breakdown**:
   - Analyze interview results to determine appropriate task count
   - Typical breakdown:
     - 1 research task: Analyze domain requirements and identify core concepts
     - 1 planning task: Design agent architecture and workflow patterns
     - N implementation tasks (one per agent/command/context group):
       - Create domain-specific agents
       - Create custom commands
       - Create context files
   - Use task-breakdown.md workflow for complex systems

2. **Retrieve next_project_number from state.json**:
   - Read specs/state.json
   - Extract next_project_number field
   - Use for first task number
   - Increment for each subsequent task

3. **For Each Task**:
   a. Create project directory: `specs/NNN_task_name/`
   b. Generate research artifact: `reports/research-001.md`
      - Domain analysis for research task
      - Component requirements for implementation tasks
      - Follow report.md standard
   c. Generate plan artifact: `plans/implementation-001.md`
      - Detailed implementation plan with phases
      - Follow plan.md standard with status markers
      - Include effort estimates, dependencies, acceptance criteria
   d. Generate summary artifacts: `summaries/`
      - research-summary.md (<100 tokens)
      - plan-summary.md (<100 tokens)
      - Follow summary.md standard
   e. Create task entry in TODO.md:
      - Follow tasks.md standard
      - Include all required fields (Language, Effort, Priority, Status)
      - Link to research and plan artifacts
      - Status: [NOT STARTED]
   f. Update state.json:
      - Add task to active_projects array
      - Increment next_project_number
      - Include artifact paths

4. **Lazy Directory Creation**:
   - Create project root only when writing first artifact
   - Create subdirectories (reports/, plans/, summaries/) only when writing to them
   - Follow artifact-management.md standards

5. **Validation**:
   - Verify all artifacts created successfully
   - Verify artifacts are non-empty
   - Verify summary artifacts within token limit (<100 tokens)
   - Verify task entries follow tasks.md standard

**Stage 8: DeliverTaskSummary (REVISED)**

Instead of delivering a completed system, deliver a task list:

1. **Present Task List**:
   - List all created tasks with numbers and titles
   - Show artifact links for each task
   - Explain the workflow: review → implement

2. **Provide Instructions**:
   - "Review the research and plan artifacts for each task"
   - "Run `/implement NNN` for each task when ready"
   - "Tasks can be implemented in order or in parallel (if no dependencies)"

3. **Create Git Commit**:
   - Commit message: "meta: create tasks for {domain} system ({N} tasks)"
   - Include: TODO.md, state.json, all task directories with artifacts
   - Use git-workflow-manager for standardized commit

4. **Return Standardized Format**:
   - Follow subagent-return-format.md
   - Include task numbers, artifact paths, brief summaries
   - Protect context window (no full artifact content)

## Task Breakdown Strategy

### Simple System (1-2 agents, 3-4 use cases)
- Task 1: Research domain requirements and core concepts
- Task 2: Design agent architecture and workflows
- Task 3: Implement agents and commands
- Task 4: Create context files and documentation

**Total**: 4 tasks

### Moderate System (3-5 agents, 4-6 use cases)
- Task 1: Research domain requirements and core concepts
- Task 2: Design agent architecture and workflows
- Task 3: Implement orchestrator agent
- Task 4: Implement subagent group 1 (e.g., research agents)
- Task 5: Implement subagent group 2 (e.g., implementation agents)
- Task 6: Create custom commands
- Task 7: Create context files and documentation

**Total**: 7 tasks

### Complex System (6-8 agents, 7+ use cases)
- Task 1: Research domain requirements and core concepts
- Task 2: Design agent architecture and workflows
- Task 3: Implement orchestrator agent
- Task 4-N: Implement individual subagents (one task per agent)
- Task N+1: Create custom commands (group by workflow)
- Task N+2: Create context files (group by domain area)
- Task N+3: Create documentation and integration guides

**Total**: 10-15 tasks

## Artifact Structure Per Task

Following artifact-management.md standards:

```
specs/NNN_task_name/
├── reports/
│   └── research-001.md          # Domain analysis, requirements, component specs
├── plans/
│   └── implementation-001.md    # Detailed implementation plan with phases
└── summaries/
    ├── research-summary.md      # Brief research summary (<100 tokens)
    └── plan-summary.md          # Brief plan summary (<100 tokens)
```

### Research Artifact Content

For research task:
- Domain analysis
- Core concepts identification
- Use case analysis
- Complexity assessment
- Integration requirements
- Recommended architecture

For implementation tasks:
- Component requirements (agent/command/context)
- Interface specifications
- Workflow definitions
- Integration points
- Dependencies

### Plan Artifact Content

Following plan.md standard:
- Metadata block (Task, Status, Effort, Priority, Dependencies, Research Inputs, Artifacts, Standards, Language, Lean Intent)
- Overview (2-4 sentences)
- Goals & Non-Goals
- Risks & Mitigations
- Implementation Phases (with status markers)
- Testing & Validation
- Artifacts & Outputs
- Rollback/Contingency

### Summary Artifact Content

Following summary.md standard:
- research-summary.md: 3-5 sentences, <100 tokens, key findings
- plan-summary.md: 3-5 sentences, <100 tokens, phase overview

## Files to Modify

### 1. .opencode/agent/subagents/meta.md

**Changes to Stage 7 (GenerateSystem → CreateTasksWithArtifacts)**:

```xml
<stage id="7" name="CreateTasksWithArtifacts">
  <action>Create tasks in TODO.md with linked research and plan artifacts</action>
  <process>
    1. Determine task breakdown based on interview results:
       - Simple system (1-2 agents): 4 tasks
       - Moderate system (3-5 agents): 7 tasks
       - Complex system (6-8 agents): 10-15 tasks
    
    2. Read next_project_number from specs/state.json
    
    3. For each task in breakdown:
       a. Generate task slug from task name
       b. Create project directory: specs/{number}_{slug}/
       c. Generate research artifact:
          - Path: reports/research-001.md
          - Content: Domain analysis, requirements, component specs
          - Follow report.md standard
       d. Generate plan artifact:
          - Path: plans/implementation-001.md
          - Content: Detailed implementation plan with phases
          - Follow plan.md standard with status markers
       e. Generate summary artifacts:
          - Path: summaries/research-summary.md (<100 tokens)
          - Path: summaries/plan-summary.md (<100 tokens)
          - Follow summary.md standard
       f. Create task entry in TODO.md:
          - Follow tasks.md standard
          - Include: Language, Effort, Priority, Status, Dependencies
          - Link to research and plan artifacts
          - Status: [NOT STARTED]
       g. Update state.json:
          - Add to active_projects array
          - Increment next_project_number
          - Include artifact paths
    
    4. Validate all artifacts:
       - Verify existence and non-empty
       - Verify summary artifacts within token limit
       - Verify task entries follow standards
    
    5. If validation fails:
       - Log errors
       - Return status "failed" with error details
    
    6. If validation passes:
       - Collect all task numbers and artifact paths
       - Proceed to Stage 8
  </process>
  <validation>
    - All tasks must have project directories
    - All artifacts must exist and be non-empty
    - Summary artifacts must be within token limit (<100 tokens)
    - Task entries must follow tasks.md standard
    - state.json must be updated correctly
  </validation>
  <checkpoint>Tasks created with linked artifacts</checkpoint>
</stage>
```

**Changes to Stage 8 (DeliverSystem → DeliverTaskSummary)**:

```xml
<stage id="8" name="DeliverTaskSummary">
  <action>Present task list with artifact links and usage instructions</action>
  <process>
    1. Present task list to user:
       "I've created {N} tasks for your {domain} system:
       
       TASKS CREATED:
       {for each task:}
       - Task {number}: {title}
         - Research: {research_artifact_path}
         - Plan: {plan_artifact_path}
         - Status: [NOT STARTED]
       
       NEXT STEPS:
       1. Review the research and plan artifacts for each task
       2. Run `/implement {task_number}` for each task when ready
       3. Tasks can be implemented in order or in parallel (if no dependencies)
       
       To get started, review Task {first_task_number} artifacts:
       - {first_research_path}
       - {first_plan_path}
       
       Then run: `/implement {first_task_number}`"
    
    2. Create git commit:
       - Delegate to git-workflow-manager
       - Message: "meta: create tasks for {domain} system ({N} tasks)"
       - Include: TODO.md, state.json, all task directories
    
    3. Return standardized format:
       {
         "status": "completed",
         "summary": "Created {N} tasks for {domain} system with research and plan artifacts",
         "artifacts": [
           {for each task:}
           {
             "type": "task",
             "task_number": {number},
             "title": "{title}",
             "research_path": "{path}",
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
         "next_steps": "Review artifacts and run /implement for each task"
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

### 2. .opencode/command/meta.md

**Changes to Workflow Section**:

Update Stage 7 and Stage 8 descriptions to match new behavior:

```markdown
### Stage 7: Create Tasks with Artifacts
- Determines appropriate task breakdown based on system complexity
- Uses next_project_number from state.json for task numbering
- Creates project directories in specs/NNN_*/
- Generates research artifacts analyzing requirements
- Generates detailed plan artifacts for each task
- Creates task entries in TODO.md linking to artifacts
- Increments next_project_number for each task created

### Stage 8: Deliver Task Summary
- Presents task list with artifact links
- Provides usage instructions (review → implement workflow)
- Creates git commit for tasks and artifacts
- Returns standardized format with task numbers and paths
```

**Changes to Artifacts Section**:

Update to reflect new artifact structure:

```markdown
## Artifacts

This command creates the following artifacts:

- **Task Entries**: `specs/TODO.md`
  - One entry per task with status [NOT STARTED]
  - Links to research and plan artifacts
  - Follows tasks.md standard

- **Research Artifacts**: `specs/NNN_task_name/reports/research-001.md`
  - Domain analysis for research tasks
  - Component requirements for implementation tasks
  - Follows report.md standard

- **Plan Artifacts**: `specs/NNN_task_name/plans/implementation-001.md`
  - Detailed implementation plan with phases
  - Follows plan.md standard with status markers
  - Includes effort estimates, dependencies, acceptance criteria

- **Summary Artifacts**: `specs/NNN_task_name/summaries/`
  - research-summary.md (<100 tokens)
  - plan-summary.md (<100 tokens)
  - Follows summary.md standard

- **State Tracking**: Updates to state.json
  - Adds tasks to active_projects array
  - Increments next_project_number
  - Includes artifact paths
```

## Integration with Existing Standards

### Compliance with artifact-management.md

- Lazy directory creation: Create project root only when writing first artifact
- Create subdirectories (reports/, plans/, summaries/) only when writing to them
- No placeholder files or pre-created empty directories
- Follow naming conventions: NNN_project_name format

### Compliance with tasks.md

- Use next_project_number from state.json for task IDs
- Include all required fields: Language, Effort, Priority, Status, Dependencies
- Follow metadata format: `- **Field**:` pattern
- Link to research and plan artifacts
- Status: [NOT STARTED] for all created tasks

### Compliance with plan.md

- Include metadata block with all required fields
- Use status markers from status-markers.md
- Include implementation phases with status markers
- Follow structure: Overview, Goals & Non-Goals, Risks & Mitigations, Phases, Testing, Artifacts, Rollback

### Compliance with summary.md

- Keep summaries brief: 3-5 sentences
- Token limit: <100 tokens (~400 characters)
- Focus on key findings and recommendations
- Avoid verbose content duplication

### Compliance with subagent-return-format.md

- Return standardized format with status, summary, artifacts, metadata
- Include brief summary in return object (<100 tokens)
- List artifact paths, not full content
- Protect orchestrator context window

## Acceptance Criteria Validation

Based on task 271 acceptance criteria:

- [x] `/meta` creates tasks in TODO.md using next_project_number from state.json
  - Implementation: Read state.json, use next_project_number, increment for each task

- [x] Each task has a project directory in `specs/NNN_*/`
  - Implementation: Create directory with lazy creation when writing first artifact

- [x] Each task links to research artifact and plan artifact
  - Implementation: Task entry includes links to reports/research-001.md and plans/implementation-001.md

- [x] Research artifacts analyze domain requirements per research standards
  - Implementation: Generate research-001.md following report.md standard

- [x] Plan artifacts follow plan.md standard with phases and estimates
  - Implementation: Generate implementation-001.md following plan.md standard

- [x] Summary artifacts follow summary.md standard (<100 tokens)
  - Implementation: Generate research-summary.md and plan-summary.md with token limit

- [x] Task entries follow tasks.md standard (Language, Effort, Priority, Status fields)
  - Implementation: Include all required fields in task entry

- [x] Task breakdown follows task-breakdown.md workflow
  - Implementation: Use task breakdown strategy based on system complexity

- [x] state.json next_project_number incremented for each task
  - Implementation: Increment next_project_number after each task creation

- [x] NO implementation performed - only tasks and artifacts created
  - Implementation: Stage 7 creates tasks/artifacts, does NOT delegate to meta subagents for file generation

- [x] User can review artifacts and run `/implement NNN` for each task
  - Implementation: Stage 8 provides instructions to review and implement

## Implementation Effort Estimate

### Stage 7 Revision (CreateTasksWithArtifacts)
- Task breakdown logic: 1 hour
- next_project_number handling: 0.5 hours
- Research artifact generation: 1.5 hours
- Plan artifact generation: 1.5 hours
- Summary artifact generation: 1 hour
- Task entry creation: 1 hour
- state.json updates: 0.5 hours
- Validation logic: 1 hour
**Subtotal**: 8 hours

### Stage 8 Revision (DeliverTaskSummary)
- Task list presentation: 0.5 hours
- Usage instructions: 0.5 hours
- Git commit integration: 0.5 hours
- Return format standardization: 0.5 hours
**Subtotal**: 2 hours

### Command Documentation Updates
- meta.md workflow section: 0.5 hours
- meta.md artifacts section: 0.5 hours
**Subtotal**: 1 hour

### Testing and Validation
- Test simple system (4 tasks): 0.5 hours
- Test moderate system (7 tasks): 0.5 hours
- Test complex system (10+ tasks): 0.5 hours
- Validate artifact standards compliance: 0.5 hours
**Subtotal**: 2 hours

**Total Effort**: 13 hours

This aligns with the task estimate of 8-12 hours (slightly over due to comprehensive artifact generation).

## Risks and Mitigations

### Risk 1: Task Breakdown Complexity
**Risk**: Determining optimal task breakdown for different system sizes may be complex
**Mitigation**: Use clear heuristics based on agent count and use case count; follow task-breakdown.md workflow

### Risk 2: Artifact Generation Quality
**Risk**: Generated research and plan artifacts may not meet quality standards
**Mitigation**: Use templates from report.md and plan.md standards; validate against standards before returning

### Risk 3: Context Window Bloat
**Risk**: Generating multiple artifacts may bloat context window
**Mitigation**: Use summary artifacts (<100 tokens); return artifact paths, not content; follow subagent-return-format.md

### Risk 4: User Confusion
**Risk**: Users may be confused by task-based workflow instead of immediate implementation
**Mitigation**: Provide clear instructions in Stage 8; explain review → implement workflow; show example commands

### Risk 5: State.json Synchronization
**Risk**: Multiple task creations may cause state.json conflicts
**Mitigation**: Update state.json atomically for each task; validate next_project_number before each increment

## Recommendations

1. **Implement in Phases**:
   - Phase 1: Revise Stage 7 to create tasks with artifacts (8 hours)
   - Phase 2: Revise Stage 8 to deliver task summary (2 hours)
   - Phase 3: Update command documentation (1 hour)
   - Phase 4: Testing and validation (2 hours)

2. **Use Existing Meta Subagents for Artifact Content**:
   - Leverage domain-analyzer for research artifact content
   - Leverage workflow-designer for plan artifact content
   - Adapt their outputs to artifact format instead of direct file creation

3. **Provide Task Templates**:
   - Create templates for research artifacts (domain analysis, component requirements)
   - Create templates for plan artifacts (agent implementation, command creation, context organization)
   - Ensure templates follow report.md and plan.md standards

4. **Add Validation Layer**:
   - Validate all artifacts before creating task entries
   - Validate task entries before updating state.json
   - Validate state.json updates before git commit
   - Fail fast with clear error messages

5. **Document Workflow Change**:
   - Update meta.md command documentation
   - Add examples showing review → implement workflow
   - Explain benefits of task-based approach (user review, incremental implementation)

## Related Tasks

This revision relates to:
- Task 269: Fix /meta command to accept user prompts directly (can be implemented independently)
- Task 256: Add /meta command from OpenAgents (this revision aligns with OpenAgents patterns)
- Task 240: OpenAgents migration (this revision follows frontmatter delegation pattern)

## Conclusion

Revising the `/meta` command to create tasks with linked artifacts instead of implementing directly aligns it with the research → plan → implement workflow used by other ProofChecker commands. This change:

1. Enables user review of generated system design before implementation
2. Provides clear artifact links for traceability
3. Follows ProofChecker standards (artifact-management.md, tasks.md, plan.md, summary.md)
4. Protects context window through summary artifacts
5. Allows incremental implementation with user control

The implementation effort is estimated at 13 hours (slightly over the 8-12 hour estimate due to comprehensive artifact generation). The revision can be implemented in 4 phases with clear validation at each step.

## Sources

1. `.opencode/command/meta.md` - Current meta command documentation
2. `.opencode/agent/subagents/meta.md` - Current meta agent implementation
3. `.opencode/context/core/system/artifact-management.md` - Artifact management standards
4. `.opencode/context/core/standards/tasks.md` - Task standards
5. `.opencode/context/core/standards/plan.md` - Plan artifact standard
6. `.opencode/context/core/standards/summary.md` - Summary artifact standard
7. `.opencode/context/core/standards/subagent-return-format.md` - Return format standard
8. `.opencode/context/core/workflows/task-breakdown.md` - Task breakdown workflow
9. `specs/TODO.md` - Task 271 description
10. `specs/state.json` - State management schema
