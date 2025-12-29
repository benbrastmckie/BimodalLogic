---
name: research
agent: orchestrator
description: "Conduct research and create reports with [RESEARCHED] status"
context_level: 2
language: markdown
routing:
  lean: lean-research-agent
  default: researcher
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/standards/subagent-return-format.md"
    - "core/workflows/status-transitions.md"
    - "core/system/routing-guide.md"
  optional:
    - "project/lean4/tools/leansearch-api.md"
    - "project/lean4/tools/loogle-api.md"
  max_context_size: 50000
---

**Task Input (required):** $ARGUMENTS (task number; e.g., `/research 197`, `/research 172`)

<context>
  <system_context>
    Research command that conducts research for tasks, creates research reports, and updates
    task status to [RESEARCHED]. Supports language-based routing for Lean-specific research tools.
  </system_context>
  <domain_context>
    ProofChecker research with support for general research (web search, documentation) and
    Lean-specific research (LeanExplore, Loogle, LeanSearch, lean-lsp-mcp).
  </domain_context>
  <task_context>
    Parse task number, validate task exists, extract language for routing, delegate to
    appropriate researcher agent, validate research report, and update status to [RESEARCHED].
  </task_context>
  <execution_context>
    Routing layer only. Delegates to researcher subagent for actual research execution.
    Supports topic subdivision via --divide flag.
  </execution_context>
</context>

<role>Research command - Route tasks to researcher with language-based agent selection</role>

<task>
  Parse task number, validate task exists and is not completed, extract language from task entry,
  route to appropriate researcher agent (lean-research-agent for Lean, researcher for others),
  validate research report, and relay results to user.
</task>

<workflow_execution>
  <stage id="1" name="Preflight">
    <action>Parse arguments and validate task</action>
    <process>
      1. Parse task number from $ARGUMENTS
      2. Parse flags (--divide for topic subdivision)
      3. Validate task number is integer
      4. Validate task exists in TODO.md
      5. Validate task is not [COMPLETED]
      6. Update status to [RESEARCHING]
    </process>
    <validation>
      - Task number must be integer
      - Task must exist in TODO.md
      - Task cannot be [COMPLETED]
    </validation>
    <checkpoint>Task validated and status updated to [RESEARCHING]</checkpoint>
  </stage>

  <stage id="2" name="CheckLanguage">
    <action>Extract language for routing</action>
    <process>
      1. Extract language from task entry:
         ```bash
         grep -A 20 "^### ${task_number}\." TODO.md | grep "Language" | sed 's/\*\*Language\*\*: //'
         ```
      2. Determine target agent based on language:
         - lean → lean-research-agent
         - markdown → researcher
         - python → researcher
         - general → researcher
      3. If extraction fails:
         - Default to "general" with warning
         - Log warning to errors.json
    </process>
    <routing_rules>
      | Language | Agent | Tools |
      |----------|-------|-------|
      | lean | lean-research-agent | LeanExplore, Loogle, LeanSearch, lean-lsp-mcp |
      | markdown | researcher | Web search, documentation review |
      | python | researcher | Web search, documentation review |
      | general | researcher | Web search, documentation review |
    </routing_rules>
    <checkpoint>Language extracted and routing target determined</checkpoint>
  </stage>

  <stage id="3" name="PrepareDelegation">
    <action>Prepare delegation context</action>
    <process>
      1. Generate session_id: sess_{timestamp}_{random_6char}
      2. Set delegation_depth = 1
      3. Set delegation_path = ["orchestrator", "research", "{agent}"]
      4. Set timeout = 3600s (1 hour)
      5. Prepare task context:
         - task_number
         - language
         - custom_prompt (if provided)
         - divide_flag (if --divide specified)
    </process>
    <checkpoint>Delegation context prepared</checkpoint>
  </stage>

  <stage id="4" name="Delegate">
    <action>Delegate to researcher subagent</action>
    <process>
      1. Invoke target agent (from CheckLanguage stage)
      2. Pass delegation context
      3. Pass task context
      4. Wait for return
    </process>
    <checkpoint>Researcher invoked</checkpoint>
  </stage>

  <stage id="5" name="ValidateReturn">
    <action>Validate researcher return</action>
    <process>
      1. Validate against subagent-return-format.md
      2. Check required fields present:
         - status (completed|partial|failed|blocked)
         - summary (&lt;100 tokens)
         - artifacts (array with research report)
         - metadata (object with findings_count)
         - session_id (matches expected)
      3. Verify research report exists on disk
      4. Check token limits (summary &lt;100 tokens)
    </process>
    <checkpoint>Return validated</checkpoint>
  </stage>

  <stage id="6" name="ReturnSuccess">
    <action>Return result to user</action>
    <return_format>
      <completed>
        Research completed for task {number}.
        {brief_summary}
        Report: {report_path}
      </completed>
      
      <partial>
        Research partially completed for task {number}.
        {brief_reason}
        Resume with: /research {number}
        Report: {report_path}
      </partial>
    </return_format>
    <checkpoint>Result returned to user</checkpoint>
  </stage>
</workflow_execution>

<routing_intelligence>
  <language_routing>
    Language-based routing ensures correct research tools:
    - Lean tasks → lean-research-agent (with LeanExplore, Loogle, LeanSearch, lean-lsp-mcp)
    - Other tasks → researcher (with web search, documentation review)
    
    See `.opencode/context/project/processes/research-workflow.md` for:
    - Language extraction logic
    - Routing rules
    - Tool descriptions
  </language_routing>
  
  <context_allocation>
    Level 2 (Filtered):
    - Load command frontmatter
    - Load required context (return format, status markers, routing guide)
    - Load optional context (research workflow) if needed
    - Researcher loads additional context per its context_loading frontmatter
  </context_allocation>
</routing_intelligence>

<delegation>
  Detailed research workflow in `.opencode/agent/subagents/researcher.md`
  
  Researcher handles:
  - General research (web search, documentation review)
  - Lean research (LeanExplore, Loogle, LeanSearch, lean-lsp-mcp)
  - Topic subdivision (--divide flag)
  - Research report creation
  - Status updates (via status-sync-manager)
  - Git commits (via git-workflow-manager)
  
  See also: `.opencode/context/project/processes/research-workflow.md`
</delegation>

<quality_standards>
  <research_report_quality>
    - Comprehensive coverage of topic
    - Relevant documentation and references cited
    - Clear recommendations for implementation
    - Technical details and considerations documented
    - NO EMOJI (per documentation.md standards)
  </research_report_quality>
  
  <atomic_updates>
    Status updates delegated to status-sync-manager for atomic synchronization:
    - TODO.md (status, timestamps, research link)
    - state.json (status, timestamps, research_path, research_metadata)
  </atomic_updates>
  
  <lazy_directory_creation>
    Directories created only when writing artifacts:
    - .opencode/specs/{number}_{slug}/ created when writing first artifact
    - reports/ subdirectory created when writing research-001.md
    - summaries/ NOT created (summary is metadata, not artifact)
  </lazy_directory_creation>
</quality_standards>

<usage_examples>
  - `/research 197` - Research task 197 using task description
  - `/research 197 "Focus on CLI integration"` - Research with custom focus
  - `/research 197 --divide` - Subdivide research into multiple topics
</usage_examples>

<validation>
  <pre_flight>
    - Task number is valid integer
    - Task exists in TODO.md
    - Task is not [COMPLETED]
  </pre_flight>
  <mid_flight>
    - Language extracted (or defaulted)
    - Routing target determined
    - Delegation context prepared
    - Return validated against schema
  </mid_flight>
  <post_flight>
    - Research report created
    - Status updated to [RESEARCHED]
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
    Error: Task number must be an integer. Got: {input}
    
    Usage: /research TASK_NUMBER [PROMPT]
  </invalid_task_number>
  
  <language_extraction_failed>
    Warning: Language not found for task {task_number}, defaulting to 'general'
    
    Proceeding with researcher agent (web search, documentation)
  </language_extraction_failed>
  
  <routing_validation_failed>
    Error: Routing validation failed: language={language}, agent={agent}
    
    Expected: language=lean → agent=lean-research-agent
    Got: language=lean → agent=researcher
    
    Recommendation: Fix language extraction or routing logic
  </routing_validation_failed>
  
  <research_timeout>
    Warning: Research timed out after 3600s
    
    Partial artifacts created: {list}
    
    Resume with: /research {task_number}
  </research_timeout>
  
  <status_update_failed>
    Error: Failed to update task status
    
    Details: {error_message}
    
    Artifacts created:
    - Research Report: {report_path}
    
    Manual recovery steps:
    1. Verify research artifact exists: {report_path}
    2. Manually update TODO.md status to [RESEARCHED]
    3. Manually update state.json status to "researched"
    
    Or retry: /research {task_number}
  </status_update_failed>
  
  <git_commit_failure>
    Warning: Git commit failed
    
    Research completed successfully: {report_path}
    Task status updated to [RESEARCHED]
    
    Manual commit required:
      git add {files}
      git commit -m "task {number}: research completed"
    
    Error: {git_error}
  </git_commit_failure>
</error_handling>

<notes>
  - **Language Routing**: Lean tasks route to lean-research-agent with specialized tools
  - **Topic Subdivision**: Use --divide flag to break research into sub-topics
  - **Research Tools**: 
    - Lean: LeanExplore, Loogle, LeanSearch, lean-lsp-mcp
    - General: Web search, documentation review
  - **Context Window Protection**: Summary in return metadata, not separate artifact
  - **Atomic Updates**: status-sync-manager ensures consistency across files
  - **Git Workflow**: Delegated to git-workflow-manager for standardized commits
  
  For detailed workflow documentation, see:
  - `.opencode/context/project/processes/research-workflow.md`
  - `.opencode/agent/subagents/researcher.md`
  - `.opencode/agent/subagents/lean-research-agent.md`
</notes>
