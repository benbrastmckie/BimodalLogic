---
name: implement
agent: orchestrator
description: "Execute implementation with resume support and [COMPLETED] status"
context_level: 2
language: varies
routing:
  lean: lean-implementation-agent
  default: implementer
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/standards/subagent-return-format.md"
    - "core/system/status-markers.md"
    - "system/routing-guide.md"
  optional:
    - "project/processes/implementation-workflow.md"
  max_context_size: 50000
---

**Task Input (required):** $ARGUMENTS (task number or range; e.g., `/implement 197`, `/implement 105-107`)

<context>
  <system_context>
    Implementation command that executes task implementations with plan-based or direct execution,
    language-based routing, and resume support for long-running operations.
  </system_context>
  <domain_context>
    ProofChecker task implementation with support for Lean 4, markdown, and general languages.
    Integrates with plan-based phased execution and direct single-pass implementation.
  </domain_context>
  <task_context>
    Parse task number/range, validate tasks exist, extract language for routing, delegate to
    appropriate implementer agent, validate return, and update status to [COMPLETED].
  </task_context>
  <execution_context>
    Routing layer only. Delegates to implementer subagent for actual execution.
    Supports batch implementation for task ranges.
  </execution_context>
</context>

<role>Implementation command - Route tasks to implementer with language-based agent selection</role>

<task>
  Parse task number or range, validate tasks exist, extract language from task entry,
  route to appropriate implementer agent (lean-implementation-agent for Lean, implementer for others),
  validate implementation artifacts, and relay results to user.
</task>

<workflow_execution>
  <stage id="1" name="Preflight">
    <action>Parse arguments and validate tasks</action>
    <process>
      1. Parse task number or range from $ARGUMENTS
      2. If range (contains hyphen):
         - Split on hyphen to get start and end
         - Validate both are integers
         - Validate start &lt; end
         - Generate task list: [start, start+1, ..., end]
      3. If single task:
         - Validate is integer
         - Create single-item task list
      4. For each task in list:
         - Validate task exists in TODO.md
         - Validate task is not [COMPLETED]
         - Update status to [IMPLEMENTING]
    </process>
    <validation>
      - Task number must be integer or range (N-M)
      - All tasks must exist in TODO.md
      - No tasks can be [COMPLETED]
      - Range start must be less than end
    </validation>
    <checkpoint>Tasks validated and status updated to [IMPLEMENTING]</checkpoint>
  </stage>

  <stage id="2" name="CheckLanguage">
    <action>Extract language for routing</action>
    <process>
      1. For each task, extract language from task entry:
         ```bash
         grep -A 20 "^### ${task_number}\." TODO.md | grep "Language" | sed 's/\*\*Language\*\*: //'
         ```
      2. Determine target agent based on language:
         - lean → lean-implementation-agent
         - markdown → implementer
         - python → implementer
         - general → implementer
      3. If extraction fails:
         - Default to "general" with warning
         - Log warning to errors.json
    </process>
    <routing_rules>
      | Language | Agent | Tools |
      |----------|-------|-------|
      | lean | lean-implementation-agent | lean-lsp-mcp, lake build |
      | markdown | implementer | File operations, git |
      | python | implementer | File operations, git, python |
      | general | implementer | File operations, git |
    </routing_rules>
    <checkpoint>Language extracted and routing target determined</checkpoint>
  </stage>

  <stage id="3" name="PrepareDelegation">
    <action>Prepare delegation context</action>
    <process>
      1. Generate session_id: sess_{timestamp}_{random_6char}
      2. Set delegation_depth = 1
      3. Set delegation_path = ["orchestrator", "implement", "{agent}"]
      4. Set timeout:
         - With plan: 7200s (2 hours)
         - Without plan: 3600s (1 hour)
      5. Prepare task context:
         - task_number
         - language
         - custom_prompt (if provided)
         - plan_path (if exists)
    </process>
    <checkpoint>Delegation context prepared</checkpoint>
  </stage>

  <stage id="4" name="Delegate">
    <action>Delegate to implementer subagent</action>
    <process>
      1. For each task in task list:
         - Invoke target agent (from CheckLanguage stage)
         - Pass delegation context
         - Pass task context
         - Wait for return
      2. If batch (multiple tasks):
         - Execute sequentially
         - Collect results
         - Continue on individual task failure
    </process>
    <checkpoint>Subagent(s) invoked</checkpoint>
  </stage>

  <stage id="5" name="ValidateReturn">
    <action>Validate subagent return</action>
    <process>
      1. Validate against subagent-return-format.md
      2. Check required fields present:
         - status (completed|partial|failed|blocked)
         - summary (&lt;100 tokens)
         - artifacts (array)
         - metadata (object)
         - session_id (matches expected)
      3. Verify artifacts exist on disk (if status = completed)
      4. Check token limits (summary &lt;100 tokens)
    </process>
    <checkpoint>Return validated</checkpoint>
  </stage>

  <stage id="6" name="ReturnSuccess">
    <action>Return result to user</action>
    <return_format>
      <single_task>
        Implementation completed for task {number}.
        {brief_summary}
        Files: {file_count} modified/created.
        {if summary_artifact:}
        Summary: {summary_path}
      </single_task>
      
      <batch_tasks>
        Batch implementation completed for tasks {start}-{end}.
        {N} tasks completed successfully.
        {M} tasks failed.
        See individual task summaries for details.
      </batch_tasks>
      
      <partial>
        Implementation partially completed for task {number}.
        {brief_reason}
        Phase {N} in progress.
        Resume with: /implement {number}
      </partial>
    </return_format>
    <checkpoint>Result returned to user</checkpoint>
  </stage>
</workflow_execution>

<routing_intelligence>
  <language_routing>
    Language-based routing ensures correct tooling:
    - Lean tasks → lean-implementation-agent (with lean-lsp-mcp, lake build)
    - Other tasks → implementer (with general file operations)
    
    See `.opencode/context/project/processes/implementation-workflow.md` for:
    - Language extraction logic
    - Routing rules
    - Agent capabilities
  </language_routing>
  
  <context_allocation>
    Level 2 (Filtered):
    - Load command frontmatter
    - Load required context (return format, status markers, routing guide)
    - Load optional context (implementation workflow) if needed
    - Subagent loads additional context per its context_loading frontmatter
  </context_allocation>
</routing_intelligence>

<delegation>
  Detailed implementation workflow in `.opencode/agent/subagents/implementer.md`
  
  Implementer handles:
  - Plan-based vs direct implementation
  - Resume support (automatic detection of incomplete phases)
  - Artifact creation (implementation files + summary)
  - Status updates (via status-sync-manager)
  - Git commits (via git-workflow-manager)
  
  See also: `.opencode/context/project/processes/implementation-workflow.md`
</delegation>

<quality_standards>
  <atomic_updates>
    Status updates delegated to status-sync-manager for atomic synchronization:
    - TODO.md (status, timestamps, artifact links)
    - state.json (status, timestamps, artifact_paths)
    - Plan file (phase status markers if plan exists)
  </atomic_updates>
  
  <lazy_directory_creation>
    Directories created only when writing artifacts:
    - .opencode/specs/{number}_{slug}/ created when writing first artifact
    - summaries/ subdirectory created when writing summary
  </lazy_directory_creation>
  
  <git_workflow>
    Git commits delegated to git-workflow-manager:
    - Per-phase commits if plan exists
    - Single commit if no plan
    - Message format: "task {number}: {description}"
  </git_workflow>
  
  <token_limits>
    Summary artifacts: &lt;100 tokens (~400 characters)
    Protects orchestrator context window from bloat
  </token_limits>
</quality_standards>

<usage_examples>
  - `/implement 196` - Implement task 196 using plan if available
  - `/implement 196 "Focus on error handling"` - Implement with custom focus
  - `/implement 105-107` - Batch implement tasks 105-107
  - `/implement 105-107 "Batch implementation"` - Batch with custom context
</usage_examples>

<validation>
  <pre_flight>
    - Task number is valid integer or range
    - All tasks exist in TODO.md
    - No tasks are [COMPLETED]
    - Range is valid (start &lt; end)
  </pre_flight>
  <mid_flight>
    - Language extracted successfully (or defaulted)
    - Routing target determined
    - Delegation context prepared
    - Return validated against schema
  </mid_flight>
  <post_flight>
    - Implementation artifacts created
    - Status updated to [COMPLETED]
    - Git commit created
    - Return relayed to user
  </post_flight>
</validation>

<error_handling>
  <task_not_found>
    Error: Task {task_number} not found in .opencode/specs/TODO.md
    
    Recommendation: Verify task number exists in TODO.md
  </task_not_found>
  
  <invalid_task_number>
    Error: Task must be integer or range (N-M). Got: {input}
    
    Usage: /implement TASK_NUMBER [PROMPT]
  </invalid_task_number>
  
  <invalid_range>
    Error: Invalid range {start}-{end}. Start must be less than end.
    
    Usage: /implement START-END [PROMPT]
  </invalid_range>
  
  <task_already_completed>
    Error: Task {task_number} is already [COMPLETED]
    
    Recommendation: Cannot re-implement completed tasks
  </task_already_completed>
  
  <implementation_timeout>
    Error: Implementation timed out
    
    Status: Partial implementation may exist
    Task status: [IMPLEMENTING]
    Phase status: [IN PROGRESS] (if plan exists)
    
    Recommendation: Resume with /implement {task_number}
  </implementation_timeout>
  
  <language_extraction_failure>
    Warning: Could not extract language from task entry
    
    Defaulting to: general
    Agent: implementer
    
    Recommendation: Add **Language**: {language} to task entry in TODO.md
  </language_extraction_failure>
  
  <validation_failure>
    Error: Implementation validation failed
    
    Details: {validation_error}
    
    Recommendation: Fix implementer subagent implementation
  </validation_failure>
  
  <git_commit_failure>
    Warning: Git commit failed
    
    Implementation completed successfully
    Task status updated to [COMPLETED]
    
    Manual commit required:
      git add {files}
      git commit -m "task {number}: {description}"
    
    Error: {git_error}
  </git_commit_failure>
</error_handling>

<notes>
  - **Resume Support**: Automatic resume from incomplete phases if plan exists
  - **Language Routing**: Lean tasks route to lean-implementation-agent with specialized tools
  - **Phase Tracking**: Plan-based tasks track phase status and support resume
  - **Git Workflow**: Per-phase commits for plan-based, single commit for direct
  - **Context Window Protection**: Summary artifact for multi-file outputs
  - **Atomic Updates**: status-sync-manager ensures consistency across files
  - **Lazy Creation**: Directories created only when writing artifacts
  
  For detailed workflow documentation, see:
  - `.opencode/context/project/processes/implementation-workflow.md`
  - `.opencode/agent/subagents/implementer.md`
</notes>
