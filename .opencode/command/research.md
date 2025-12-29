---
name: research
agent: orchestrator
description: "Conduct research and create reports with [RESEARCHED] status"
context_level: 2
language: markdown
---

**Task Input (required):** $ARGUMENTS (task number; e.g., `/research 197`, `/research 172`)

Context Loaded:
@.opencode/context/common/workflows/command-lifecycle.md
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@.opencode/context/common/system/status-markers.md
@.opencode/context/common/standards/subagent-return-format.md
@.opencode/context/common/workflows/subagent-delegation-guide.md
@.opencode/context/common/system/git-commits.md

<context>
  <system_context>
    Research workflow with language-based routing, artifact creation, and [RESEARCHED]
    status marker. Supports topic subdivision via --divide flag.
  </system_context>
  <domain_context>
    Research for both Lean and general tasks. Lean tasks route to lean-research-agent,
    general tasks route to researcher subagent.
  </domain_context>
  <task_context>
    Conduct research for specified task, create research reports and summaries,
    update task status to [RESEARCHED], and commit artifacts.
  </task_context>
  <execution_context>
    Lazy directory creation (specs/NNN_*/reports/ only when writing). Atomic status
    synchronization via status-sync-manager. Git commit after completion.
  </execution_context>
</context>

<role>Research Command - Conduct research and create reports with status tracking</role>

<task>
  Conduct research for task, create artifacts in lazy-created directories, update
  status to [RESEARCHED] with timestamps, and commit changes.
</task>

<argument_parsing>
  <invocation_format>
    /research TASK_NUMBER [PROMPT]
    
    Examples:
    - /research 197
    - /research 197 "Focus on CLI integration"
  </invocation_format>
  
  <parameters>
    <task_number>
      <position>1</position>
      <type>integer</type>
      <required>true</required>
      <description>The task number from .opencode/specs/TODO.md to research</description>
      <extraction>Extract first argument after command name as task number</extraction>
      <validation>Must be a valid integer that exists in .opencode/specs/TODO.md</validation>
    </task_number>
    
    <prompt>
      <position>2</position>
      <type>string</type>
      <required>false</required>
      <description>Optional additional context or focus for research</description>
      <extraction>Extract remaining arguments after task number as prompt string</extraction>
      <default>Use task description from .opencode/specs/TODO.md</default>
    </prompt>
    
    <flags>
      <divide>
        <flag>--divide</flag>
        <type>boolean</type>
        <required>false</required>
        <description>Subdivide research into multiple topics</description>
        <default>false</default>
      </divide>
    </flags>
  </parameters>
  
  <parsing_logic>
    When user invokes "/research 197 'Focus on CLI'", parse as:
    1. Command: "research"
    2. Arguments: ["197", "Focus on CLI"]
    3. Extracted:
       - task_number = 197
       - prompt = "Focus on CLI"
       - flags = {}
  </parsing_logic>
  
  <error_handling>
    If task_number missing:
      Return: "Error: Task number required. Usage: /research TASK_NUMBER [PROMPT]"
    If task_number not integer:
      Return: "Error: Task number must be an integer. Got: {input}"
    If task not found in .opencode/specs/TODO.md:
      Return: "Error: Task {task_number} not found in .opencode/specs/TODO.md"
  </error_handling>
</argument_parsing>

<workflow_execution>
  Follow command-lifecycle.md 8-stage pattern with these variations:
  
  <stage id="1" name="Preflight">
    <status_transition>
      Initial: [NOT STARTED]
      In-Progress: [RESEARCHING]
    </status_transition>
    <validation>
      - Task number must exist in .opencode/specs/TODO.md
      - Task must not be [COMPLETED] or [ABANDONED]
      - Language field must be present (default to "general")
      - Check for --divide flag (topic subdivision)
    </validation>
    <status_update>
      Atomic update via status-sync-manager:
        - .opencode/specs/TODO.md: [RESEARCHING], **Started**: {date}
        - state.json: status = "researching", started = "{date}"
    </status_update>
  </stage>

  <stage id="2" name="CheckLanguage">
    <critical_importance>
      CRITICAL: This stage MUST extract the Language field and determine routing.
      DO NOT skip this stage. DO NOT assume language without extraction.
      Incorrect routing bypasses Lean-specific tooling (lean-lsp-mcp, Loogle).
    </critical_importance>
    <language_extraction>
      Extract Language field from .opencode/specs/TODO.md task using explicit bash command:
      ```bash
      grep -A 20 "^### ${task_number}\." .opencode/specs/TODO.md | grep "Language" | sed 's/\*\*Language\*\*: //'
      ```
      Validate extraction succeeded (non-empty result)
      If extraction fails: default to "general" and log warning
      Log extracted language: "Task ${task_number} language: ${language}"
    </language_extraction>
    <routing>
      Language: lean → lean-research-agent (LeanExplore, Loogle, LeanSearch)
      Language: * → researcher (web search, documentation)
    </routing>
    <validation>
      MUST complete before Stage 3:
      - Language field extracted and logged
      - Routing decision made and logged
      - Target agent determined (lean-research-agent or researcher)
      - Agent matches language (lean → lean-research-agent, else → researcher)
    </validation>
    <pre_invocation_check>
      Before invoking agent in Stage 4, verify:
      - Language was extracted in Stage 2
      - Routing decision was logged in Stage 2
      - Selected agent matches language:
        * If language == "lean" AND agent != "lean-research-agent" → ABORT with error
        * If language != "lean" AND agent == "lean-research-agent" → ABORT with error
      If validation fails: Return error "Routing validation failed: language=${language}, agent=${agent}"
    </pre_invocation_check>
  </stage>

  <stage id="3" name="PrepareDelegation">
    <timeout>3600s (1 hour)</timeout>
    <delegation_context>
      {
        "session_id": "sess_{timestamp}_{random}",
        "delegation_depth": 1,
        "delegation_path": ["orchestrator", "research", "{agent}"],
        "timeout": 3600,
        "task_context": {
          "task_number": {number},
          "description": "{description}",
          "language": "{language}",
          "divide": {true|false}
        }
      }
    </delegation_context>
    <special_context>
      divide_topics: boolean (from --divide flag)
    </special_context>
  </stage>

  <!-- Stages 4-6: Follow command-lifecycle.md (no variations) -->

  <stage id="7" name="Postflight">
    <status_transition>
      Completion: [RESEARCHED] + **Completed**: {date}
      Partial: Keep [RESEARCHING]
      Failed: Keep [RESEARCHING]
      Blocked: [BLOCKED]
    </status_transition>
    
    <validation_delegation>
      EXECUTE: Verify researcher returned validation success
      
      STEP 1: CHECK researcher return metadata
        - VERIFY return.status field exists and is valid
        - VERIFY return.metadata.validation_result exists
        - LOG: "Researcher validation: {validation_result}"
        - IF validation_result != "success": ABORT with error
      
      STEP 2: VERIFY research artifact validated
        - CHECK research artifact exists on disk
        - CHECK research artifact is non-empty (file size > 0)
        - VERIFY exactly 1 artifact: research report only (NO summary artifact)
        - LOG: "Research artifact validated: {report_path}"
        - IF artifact missing or empty: ABORT with error
        - IF summary artifact found: ABORT with error "Summary should be metadata, not artifact"
      
      STEP 3: VERIFY summary in metadata
        - VERIFY return.summary field exists
        - VERIFY summary is brief (<100 tokens)
        - LOG: "Research summary in metadata: {summary_length} tokens"
        - IF summary missing: ABORT with error
      
      CHECKPOINT: Validation completed
        - [ ] Researcher return validated
        - [ ] Research artifact exists on disk
        - [ ] Summary in metadata (not as artifact)
        - IF any checkpoint fails: ABORT Stage 7, return error to user
    </validation_delegation>
    
    <artifact_linking>
      Link 1 artifact in .opencode/specs/TODO.md:
        - Research Report: {report_path}
      
      NO summary artifact link (summary is metadata in return object)
      
      Reference: artifact-management.md "Context Window Protection via Metadata Passing"
    </artifact_linking>
    
    <git_commit>
      <conditional>
        IF status == "completed":
          PROCEED with git commit
        ELSE:
          SKIP git commit
          LOG: "Skipping git commit (status: {status})"
          PROCEED to atomic_update
      </conditional>
      
      <invocation>
        STEP 1: PREPARE git-workflow-manager delegation
          ```json
          {
            "scope_files": [
              "{report_path from researcher return}",
              ".opencode/specs/TODO.md",
              ".opencode/specs/state.json",
              ".opencode/specs/{task_number}_{slug}/state.json"
            ],
            "message_template": "task {number}: research completed",
            "task_context": {
              "task_number": "{number}",
              "description": "research completed"
            },
            "session_id": "{session_id}",
            "delegation_depth": 2,
            "delegation_path": ["orchestrator", "research", "git-workflow-manager"]
          }
          ```
        
        STEP 2: INVOKE git-workflow-manager
          - Subagent type: "git-workflow-manager"
          - Delegation context: {prepared context}
          - Timeout: 120s
          - LOG: "Invoking git-workflow-manager for task {number}"
        
        STEP 3: WAIT for git-workflow-manager return
          - Maximum wait: 120s
          - IF timeout: LOG error (non-critical), continue
        
        STEP 4: VALIDATE return
          - IF status == "completed":
            * EXTRACT commit_hash from commit_info
            * LOG: "Git commit created: {commit_hash}"
          
          - IF status == "failed":
            * LOG error to errors.json (non-critical)
            * INCLUDE warning in Stage 8 return
            * CONTINUE (git failure doesn't fail command)
      </invocation>
      
      CHECKPOINT: Git commit completed (if applicable)
        - [ ] Git commit attempted (if status == "completed")
        - [ ] Git commit succeeded OR failure logged (non-critical)
    </git_commit>
    
    <atomic_update>
      <action>INVOKE status-sync-manager subagent</action>
      
      <step_1_prepare_delegation>
        PREPARE delegation context:
        ```json
        {
          "task_number": "{number}",
          "new_status": "researched",
          "timestamp": "{ISO8601 date}",
          "session_id": "{session_id}",
          "validated_artifacts": "{artifacts from researcher return}",
          "delegation_depth": 2,
          "delegation_path": ["orchestrator", "research", "status-sync-manager"]
        }
        ```
        
        VALIDATE delegation context:
          - VERIFY all required fields present
          - VERIFY task_number is positive integer
          - VERIFY new_status is valid value ("researched")
          - VERIFY timestamp is ISO8601 format
          - IF validation fails: ABORT with error
      </step_1_prepare_delegation>
      
      <step_2_invoke>
        INVOKE status-sync-manager:
          - Subagent type: "status-sync-manager"
          - Delegation context: {prepared context}
          - Timeout: 60s
          - Delegation mechanism: Per subagent-delegation-guide.md
        
        LOG: "Invoking status-sync-manager for task {number}"
      </step_2_invoke>
      
      <step_3_wait>
        WAIT for status-sync-manager return:
          - Maximum wait: 60s
          - IF timeout: ABORT with error "status-sync-manager timeout after 60s"
      </step_3_wait>
      
      <step_4_validate_return>
        VALIDATE status-sync-manager return:
          - VERIFY return format matches subagent-return-format.md
          - VERIFY status field == "completed" (not "failed" or "partial")
          - VERIFY files_updated includes [".opencode/specs/TODO.md", "state.json"]
          - VERIFY rollback_performed == false
          - IF validation fails: ABORT with error details
        
        LOG: "status-sync-manager completed: {files_updated}"
      </step_4_validate_return>
      
      <step_5_verify_on_disk>
        VERIFY files updated on disk:
          - READ .opencode/specs/TODO.md and verify status marker changed to [RESEARCHED]
          - READ state.json and verify status field == "researched"
          - IF verification fails: ABORT with error
        
        CHECKPOINT: Atomic update completed successfully
          - [ ] status-sync-manager returned "completed"
          - [ ] .opencode/specs/TODO.md updated on disk
          - [ ] state.json updated on disk
          - [ ] No rollback performed
      </step_5_verify_on_disk>
      
      <status_sync_manager_protocol>
        status-sync-manager performs two-phase commit:
          - Phase 1: Prepare, validate artifacts, backup
          - Phase 2: Write all files or rollback all
        
        Atomicity guaranteed across:
          - .opencode/specs/TODO.md (status, timestamps, artifact links)
          - state.json (status, timestamps, artifacts array)
          - project state.json (lazy created if needed)
      </status_sync_manager_protocol>
    </atomic_update>
    
    <error_handling>
      <error_case name="validation_failed">
        IF validation fails before delegation:
          STEP 1: ABORT immediately
            - DO NOT invoke status-sync-manager
            - DO NOT invoke git-workflow-manager
          
          STEP 2: LOG error to errors.json
            ```json
            {
              "type": "validation_failed",
              "severity": "high",
              "context": {
                "command": "research",
                "task_number": "{number}",
                "session_id": "{session_id}",
                "stage": 7
              },
              "message": "Researcher return validation failed: {error}",
              "fix_status": "not_addressed"
            }
            ```
          
          STEP 3: RETURN validation error to user
            ```
            Error: Validation failed
            
            Details: {validation_error}
            
            Recommendation: Fix researcher subagent implementation
            ```
      </error_case>
      
      <error_case name="status_sync_manager_failed">
        IF status-sync-manager returns status == "failed":
          STEP 1: EXTRACT error details
            - error_type: {type from errors array}
            - error_message: {message from errors array}
            - rollback_performed: {boolean}
          
          STEP 2: LOG error to errors.json
            ```json
            {
              "type": "status_sync_failed",
              "severity": "high",
              "context": {
                "command": "research",
                "task_number": "{number}",
                "session_id": "{session_id}",
                "stage": 7
              },
              "message": "status-sync-manager failed: {error_message}",
              "fix_status": "not_addressed"
            }
            ```
          
          STEP 3: ABORT Stage 7
            - DO NOT proceed to git commit
            - DO NOT proceed to Stage 8
          
          STEP 4: RETURN error to user
            ```
            Error: Failed to update task status
            
            Details: {error_message}
            
            Artifacts created:
            - Research Report: {report_path}
            
            Manual recovery steps:
            1. Verify research artifact exists: {report_path}
            2. Manually update .opencode/specs/TODO.md status to [RESEARCHED]
            3. Manually update state.json status to "researched"
            4. Manually link research report in .opencode/specs/TODO.md
            
            Or retry: /research {task_number}
            ```
      </error_case>
      
      <error_case name="status_sync_manager_timeout">
        IF status-sync-manager times out after 60s:
          STEP 1: LOG timeout
          
          STEP 2: CHECK files on disk
            - IF .opencode/specs/TODO.md updated: Partial success
            - IF state.json updated: Partial success
            - IF neither updated: Complete failure
          
          STEP 3: RETURN appropriate error
            ```
            Error: Status update timed out
            
            Status: {partial or complete failure}
            
            Files updated:
            - .opencode/specs/TODO.md: {yes/no}
            - state.json: {yes/no}
            
            Recommendation: Check status-sync-manager implementation
            Retry: /research {task_number}
            ```
      </error_case>
      
      <error_case name="git_commit_failed">
        IF git-workflow-manager returns status == "failed":
          STEP 1: LOG error (non-critical)
            - Git failure does not fail the command
            - Artifacts and status updates still valid
          
          STEP 2: CONTINUE to Stage 8
            - Include git failure warning in return
          
          STEP 3: RETURN success with warning
            ```
            Warning: Git commit failed
            
            Research completed successfully: {report_path}
            Task status updated to [RESEARCHED]
            
            Manual commit required:
              git add {files}
              git commit -m "task {number}: research completed"
            
            Error: {git_error}
            ```
      </error_case>
    </error_handling>
    
    <stage_7_completion_checkpoint>
      VERIFY all Stage 7 steps completed:
        - [ ] Researcher return validated
        - [ ] Research artifact exists on disk
        - [ ] status-sync-manager invoked
        - [ ] status-sync-manager returned "completed"
        - [ ] .opencode/specs/TODO.md updated on disk (verified)
        - [ ] state.json updated on disk (verified)
        - [ ] git-workflow-manager invoked (if status == "completed")
      
      IF any checkpoint fails:
        - ABORT Stage 8
        - RETURN error to user with checkpoint failure details
        - Include manual recovery instructions
      
      IF all checkpoints pass:
        - LOG: "Stage 7 (Postflight) completed successfully"
        - PROCEED to Stage 8
    </stage_7_completion_checkpoint>
  </stage>

  <stage id="8" name="ReturnSuccess">
    <prerequisite>
      REQUIRE: Stage 7 completion checkpoint passed
      IF Stage 7 not completed: ABORT with error
    </prerequisite>
    
    <return_format>
      Research completed for task {number}
      
      {brief_summary from research agent (3-5 sentences, <100 tokens)}
      
      Artifact created:
      - Research Report: {report_path}
      
      Task marked [RESEARCHED].
      
      ---
      
      Or if partial:
      Research partially completed for task {number}
      
      {brief_summary from research agent}
      
      Partial artifacts: {list}
      
      Resume with: /research {number}
    </return_format>
    <context_window_protection>
      CRITICAL: Return only brief summary (3-5 sentences, <100 tokens) and artifact path.
      DO NOT include full research report content.
      Summary is metadata from return object, NOT a separate artifact file.
      Full research content is in report artifact for user to review separately.
      This protects orchestrator context window from bloat.
      
      Reference: artifact-management.md "Context Window Protection via Metadata Passing"
    </context_window_protection>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>
    Level 2 (Filtered) - Research requires project context based on language
  </context_allocation>
  <lean_routing>
    If Language: lean → lean-research-agent
    - Load .opencode/context/project/lean4/
    - Use LeanExplore, Loogle, LeanSearch (when available)
    - Fallback to web search if tools unavailable
  </lean_routing>
  <general_routing>
    If Language: * → researcher
    - Load .opencode/context/project/repo/
    - Use web search and documentation review
  </general_routing>
</routing_intelligence>

<artifact_management>
  <lazy_creation>
    Do not create specs/NNN_*/ until writing research artifacts
    Create only reports/ subdirectory when writing research-001.md
    Create summaries/ only if summary file needed
  </lazy_creation>
  <artifact_naming>
    Research reports: specs/NNN_{task_slug}/reports/research-001.md
    Research summaries: specs/NNN_{task_slug}/summaries/research-summary.md
  </artifact_naming>
  <state_sync>
    Update state.json with artifact paths when research completes
    Sync .opencode/specs/TODO.md with research report links
  </state_sync>
</artifact_management>

<quality_standards>
  <status_markers>
    Use [RESEARCHING] at start, [RESEARCHED] at completion per status-markers.md
    Include Started and Completed timestamps
  </status_markers>
  <language_routing>
    Route based on .opencode/specs/TODO.md Language field
    Validate lean-lsp-mcp availability for Lean tasks
  </language_routing>
  <no_emojis>
    No emojis in research reports, summaries, or status updates
  </no_emojis>
  <atomic_updates>
    Use status-sync-manager for atomic multi-file updates
  </atomic_updates>
</quality_standards>

<usage_examples>
  - `/research 195` (research task 195)
  - `/research 195 --divide` (subdivide research into topics)
</usage_examples>

<error_handling>
  Follow command-lifecycle.md error handling patterns:
  
  <timeout>
    If research times out after 3600s:
      - Check for partial artifacts
      - Return partial status
      - Keep task [RESEARCHING]
      - Provide resume instructions
  </timeout>
  <validation_failure>
    If return validation fails:
      - Log validation error with details
      - Return failed status
      - Keep task [RESEARCHING]
      - Recommend subagent fix
  </validation_failure>
  <tool_unavailable>
    If lean-lsp-mcp or Lean tools unavailable:
      - Log tool unavailability
      - Fallback to web search
      - Continue with degraded mode
      - Note tool unavailability in research report
  </tool_unavailable>
  <git_commit_failure>
    If git commit fails:
      - Log error to errors.json
      - Continue (commit failure non-critical)
      - Return success with warning
  </git_commit_failure>
</error_handling>
