# Command Lifecycle Pattern

**Version**: 1.0  
**Created**: 2025-12-28  
**Purpose**: Standardized pre-flight and post-flight procedures for workflow commands  
**Scope**: /research, /plan, /revise, /implement commands

---

## Overview

This document defines the standardized 8-stage lifecycle pattern followed by all workflow commands (/research, /plan, /revise, /implement). The pattern ensures consistent behavior across commands while allowing for legitimate command-specific variations.

### Purpose

- Establish single source of truth for command lifecycle procedures
- Reduce procedural duplication across command files (39% reduction: 1,961 → 1,200 lines)
- Document legitimate command-specific variations with justifications
- Ensure consistent status transitions, artifact management, and git commits
- Provide clear integration points with existing standards

### Benefits

- **Consistency**: All commands follow same structural pattern
- **Maintainability**: Changes to common procedures update once, apply everywhere
- **Clarity**: Command files document only variations, not entire lifecycle
- **Compliance**: Enforces adherence to status-markers.md, subagent-return-format.md, artifact-management.md, git-commits.md
- **Extensibility**: New commands can adopt pattern easily

### Scope

This lifecycle pattern applies to:
- Workflow commands that delegate to subagents
- Commands that create artifacts and update task status
- Commands that require pre-flight validation and post-flight cleanup
- Commands that create git commits for artifact tracking

---

## 8-Stage Lifecycle Pattern

All workflow commands follow this 8-stage pattern:

### Stage 1: Preflight

**Purpose**: Parse arguments, validate task, update status to in-progress

**Common Steps**:
1. Parse task number from $ARGUMENTS (first argument)
2. Validate task number is integer
3. If task number missing or invalid, return error with usage message
4. Extract optional prompt from $ARGUMENTS (remaining text after task number)
5. Load task from TODO.md
6. Validate task exists and is not [COMPLETED] or [ABANDONED]
7. Extract task description and language field
8. Mark task with in-progress status marker (command-specific)
9. Update state.json: status = "{in_progress_state}", started = "{YYYY-MM-DD}"
10. Generate session_id for tracking: sess_{timestamp}_{random_6char}

**Status Update Mechanism**:
- Atomic update via status-sync-manager
- TODO.md: Update status marker, add/preserve **Started**: {date}
- state.json: Update status field, add/update started timestamp

**Validation Requirements**:
- Task number must exist in TODO.md
- Task must not be [COMPLETED] or [ABANDONED]
- Language field must be present (default to "general" if missing)
- Command-specific validations (see Variations Table)

**Error Handling**:
- Missing task number: "Error: Task number required. Usage: /{command} TASK_NUMBER [PROMPT]"
- Invalid task number: "Error: Task number must be an integer. Got: {input}"
- Task not found: "Error: Task {task_number} not found in TODO.md"
- Task completed: "Error: Task {task_number} already [COMPLETED]"

### Stage 2: CheckLanguage / DetermineRouting

**Purpose**: Extract language field and determine target agent for delegation

**Common Steps**:
1. Extract Language field from TODO.md task entry
2. Validate extraction succeeded (non-empty result)
3. If extraction fails: default to "general" and log warning
4. Log extracted language: "Task {task_number} language: {language}"
5. Determine target agent based on language and command (see Routing Table)
6. Log routing decision: "Routing /{command} (task {task_number}, Language: {language}) to {agent}"
7. Prepare agent-specific context parameters

**Language Extraction**:
```bash
grep -A 20 "^### ${task_number}\." TODO.md | grep "Language" | sed 's/\*\*Language\*\*: //'
```

**Critical Importance**:
- MUST extract Language field explicitly
- DO NOT skip this stage
- DO NOT assume language without extraction
- Incorrect routing bypasses language-specific tooling (lean-lsp-mcp, Loogle for Lean)

**Routing Logic**: See Command-Specific Variations Table

### Stage 3: PrepareDelegation

**Purpose**: Prepare delegation context for subagent invocation

**Common Steps**:
1. Generate session_id: sess_{timestamp}_{random_6char} (if not already generated in Stage 1)
2. Set delegation_depth = 1 (orchestrator → command → agent)
3. Set delegation_path = ["orchestrator", "{command}", "{agent}"]
4. Set timeout (command-specific, see Variations Table)
5. Store session_id for validation
6. Prepare delegation context object with all required parameters
7. Validate delegation depth < 3 (safety check)

**Delegation Context Structure**:
```json
{
  "session_id": "sess_{timestamp}_{random}",
  "delegation_depth": 1,
  "delegation_path": ["orchestrator", "{command}", "{agent}"],
  "timeout": {command_specific_timeout},
  "task_number": {number},
  "task_description": "{description}",
  "language": "{language}",
  "{command_specific_params}": {...}
}
```

**Timeout Values**: See Command-Specific Variations Table

**Special Context Parameters**: See Command-Specific Variations Table

### Stage 4: InvokeAgent

**Purpose**: Delegate to appropriate subagent and wait for return

**Common Steps**:
1. Invoke target agent with delegation context
2. Pass all required parameters (session_id, task_number, language, etc.)
3. Set timeout from Stage 3
4. Wait for agent return
5. Capture return object

**Invocation Pattern**:
- Use subagent delegation mechanism per subagent-delegation-guide.md
- Ensure all required parameters passed
- Respect timeout limits
- Handle timeout gracefully (return partial status)

**Timeout Handling**:
- If timeout occurs: Proceed to Stage 6 with partial status
- Log timeout event
- Preserve partial artifacts if any
- Allow resume if applicable

### Stage 5: ReceiveResults

**Purpose**: Validate agent return against subagent-return-format.md

**Common Steps**:
1. Receive return object from agent
2. Validate return format matches subagent-return-format.md
3. Check required fields present: status, summary, artifacts, metadata
4. Validate session_id matches expected value
5. Validate status is one of: completed, partial, failed, blocked
6. Validate artifacts array structure
7. Validate metadata includes session_id, duration, agent_type
8. Log validation results

**Validation Checks**:
- [ ] Return object is valid JSON/structured format
- [ ] status field present and valid value
- [ ] summary field present and within token limit (<100 tokens)
- [ ] artifacts array present (may be empty)
- [ ] metadata object present with required fields
- [ ] session_id matches expected value
- [ ] errors array present (may be empty)

**Validation Failure Handling**:
- Log validation error with details
- Treat as failed status
- Include validation error in return to user
- Do not proceed to artifact processing

### Stage 6: ProcessResults

**Purpose**: Extract artifacts, summary, and errors from agent return

**Common Steps**:
1. Extract status from return object
2. Extract summary from return object
3. Extract artifacts array from return object
4. Extract errors array from return object
5. Validate artifact paths exist on disk
6. Validate summary artifact exists (if required)
7. Prepare artifact links for TODO.md
8. Prepare status update based on return status

**Artifact Processing**:
- For each artifact in artifacts array:
  - Verify path exists on disk
  - Verify file is not empty
  - Extract artifact type and summary
  - Prepare link format for TODO.md

**Status Determination**:
- If status == "completed": Proceed to completion post-flight
- If status == "partial": Proceed to partial post-flight
- If status == "failed": Proceed to failure post-flight
- If status == "blocked": Proceed to blocked post-flight

### Stage 7: Postflight

**Purpose**: Update status, link artifacts, create git commit

**Common Steps**:
1. Update TODO.md with completion status marker (command-specific)
2. Add/update **Completed** timestamp (if completed)
3. Update state.json with completion status and timestamp
4. Link artifacts in TODO.md (command-specific format)
5. Validate all artifact links are correct
6. Create git commit with scoped changes
7. Validate git commit succeeded

**Status Update Patterns**: See Command-Specific Variations Table

**Artifact Linking Patterns**: See Command-Specific Variations Table

**Git Commit Pattern**:
- Scope: Artifacts + TODO.md + state.json + (command-specific files)
- Message: "task {number}: {action}" (command-specific action)
- Delegate to git-workflow-manager
- If git commit fails: Log error but continue (non-critical)

**Git Commit Failure Handling**:
- Log error to errors.json
- Include error in return to user
- Do not fail the command (git failure is non-critical)
- User can manually commit if needed

**Update Procedures**:

All status and artifact updates in Stage 7 MUST be delegated to status-sync-manager to ensure atomicity across all tracking files.

**Validation Protocol**:
1. Verify subagent returned validation success:
   - Check subagent return metadata for validation_result
   - Verify all artifacts validated (exist, non-empty, token limit)
   - Extract metadata if applicable (plan_metadata, phase_statuses)
   - If validation failed: Abort update, return error to user

2. Delegate to status-sync-manager:
   - task_number: {number}
   - new_status: {status from subagent return}
   - timestamp: {ISO8601 date}
   - session_id: {session_id}
   - validated_artifacts: {artifacts from subagent return}
   - plan_metadata: {metadata from planner if applicable}
   - plan_version: {version from revise if applicable}
   - phase_statuses: {statuses from implement if applicable}

3. status-sync-manager performs two-phase commit:
   - Phase 1: Prepare, validate artifacts, backup
   - Phase 2: Write all files or rollback all

**Atomicity Guarantees**:

status-sync-manager ensures atomic updates across:
- TODO.md (status markers, timestamps, artifact links)
- state.json (status, timestamps, artifacts array, plan_metadata, plan_versions)
- project state.json (lazy created on first artifact write)
- plan file (phase statuses if applicable)

Either all files update successfully or all are rolled back to original state.

**Artifact Validation**:

Subagents validate artifacts before returning:
- Verify artifact files exist on disk
- Verify artifact files are non-empty (size > 0)
- Verify summary artifacts within token limit (<100 tokens, ~400 chars)
- Return validated_artifacts in return object

status-sync-manager validates artifacts before commit:
- Re-verify artifact files exist
- Re-verify artifact files are non-empty
- If validation fails: Abort update, rollback, return error

**Plan Metadata Tracking**:

Planner extracts metadata from plan file:
- phase_count: Count ### Phase headings
- estimated_hours: Extract from metadata section
- complexity: Extract from metadata section

status-sync-manager stores metadata in state.json:
```json
{
  "plan_metadata": {
    "phase_count": 4,
    "estimated_hours": 12,
    "complexity": "medium"
  }
}
```

**Plan Version History**:

/revise command tracks plan versions:
- Append to plan_versions array in state.json
- Preserve all previous versions
- Update plan_path to latest version

```json
{
  "plan_versions": [
    {
      "version": 1,
      "path": "plans/implementation-001.md",
      "created": "2025-12-28T10:00:00Z",
      "reason": "Initial implementation plan"
    },
    {
      "version": 2,
      "path": "plans/implementation-002.md",
      "created": "2025-12-28T14:00:00Z",
      "reason": "Revised to reduce complexity"
    }
  ]
}
```

**Project State Creation**:

status-sync-manager creates project state.json lazily:
- Created on first artifact write
- Uses state-schema.md template
- Populates with project metadata
- Adds to two-phase commit transaction

### Stage 8: ReturnSuccess

**Purpose**: Return brief summary to user

**Common Steps**:
1. Format return message with brief summary
2. Include artifact paths (command-specific)
3. Include next steps or recommendations
4. Ensure return is within token limit (<100 tokens)
5. Return to user

**Return Format**:
```
{Command} completed for task {number}.

{Brief summary from agent (3-5 sentences)}

Artifacts:
- {Artifact type}: {path}
- {Artifact type}: {path}

Next steps: {recommendations}
```

**Token Limit**: <100 tokens (~400 characters)

**Return Content**: See Command-Specific Variations Table

---

## Pre-flight Checklist

Use this checklist before invoking subagent (after Stage 3):

- [ ] Task number parsed and validated
- [ ] Task exists in TODO.md
- [ ] Task not [COMPLETED] or [ABANDONED]
- [ ] Language field extracted
- [ ] Status updated to in-progress marker
- [ ] state.json updated with status and started timestamp
- [ ] session_id generated
- [ ] Delegation context prepared
- [ ] Timeout set appropriately
- [ ] Command-specific validations passed

---

## Post-flight Checklist

Use this checklist after receiving agent return (after Stage 6):

- [ ] Return format validated against subagent-return-format.md
- [ ] session_id matches expected value
- [ ] Artifacts extracted and validated
- [ ] Artifact paths exist on disk
- [ ] Summary artifact exists (if required)
- [ ] Status updated to completion marker
- [ ] state.json updated with completion status and timestamp
- [ ] Artifacts linked in TODO.md
- [ ] Git commit created with correct scope
- [ ] Git commit succeeded (or error logged)
- [ ] Return message formatted correctly
- [ ] Return within token limit (<100 tokens)

---

## Command-Specific Variations

### Variation Table 1: Status Markers

| Command | Initial States | In-Progress Marker | Completion Marker | Partial Marker | Failed Marker |
|---------|---------------|-------------------|-------------------|----------------|---------------|
| /research | [NOT STARTED] | [RESEARCHING] | [RESEARCHED] | [RESEARCHING] | [RESEARCHING] |
| /plan | [NOT STARTED], [RESEARCHED] | [PLANNING] | [PLANNED] | [PLANNING] | [PLANNING] |
| /revise | [PLANNED], [REVISED] | [REVISING] | [REVISED] | [REVISING] | [REVISING] |
| /implement | [NOT STARTED], [PLANNED], [REVISED] | [IMPLEMENTING] | [COMPLETED] | [PARTIAL] | [IMPLEMENTING] |

**Justification**: Each command has different workflow position and semantics

**Integration**: All markers defined in status-markers.md

### Variation Table 2: Routing Logic

| Command | Language | Has Plan | Target Agent | Justification |
|---------|----------|----------|--------------|---------------|
| /research | lean | N/A | lean-research-agent | Lean-specific tooling (lean-lsp-mcp, Loogle) |
| /research | * | N/A | researcher | General research |
| /plan | * | N/A | planner | No language-specific planning |
| /revise | * | N/A | planner | No language-specific planning |
| /implement | lean | yes | lean-implementation-agent | Lean-specific implementation with phases |
| /implement | lean | no | lean-implementation-agent | Lean-specific implementation without phases |
| /implement | * | yes | task-executor | General phased implementation |
| /implement | * | no | implementer | General direct implementation |

**Justification**: Different agents for different languages and execution modes

**Critical**: Language extraction MUST occur in Stage 2 for correct routing

### Variation Table 3: Timeouts

| Command | Timeout | Justification |
|---------|---------|---------------|
| /research | 3600s (1 hour) | Research can be extensive, requires time for analysis |
| /plan | 1800s (30 min) | Planning is structured, less time-intensive |
| /revise | 1800s (30 min) | Revision builds on existing plan, similar to planning |
| /implement | 7200s (2 hours) | Implementation is most complex, may involve multiple phases |

**Justification**: Different complexity and time requirements per workflow

**Note**: Timeouts are per-command invocation, not per-phase (phases have separate timeouts)

### Variation Table 4: Special Delegation Context

| Command | Special Parameters | Purpose |
|---------|-------------------|---------|
| /research | divide_topics: boolean | Enable topic subdivision via --divide flag |
| /plan | research_inputs: array | Paths to research artifacts from TODO.md |
| /revise | existing_plan_path: string, new_version: integer | Current plan and next version number |
| /implement | plan_path: string, resume_from_phase: integer | Plan file and resume phase (if partial) |

**Justification**: Command-specific workflow requirements

**Note**: All commands include standard parameters (session_id, task_number, language, etc.)

### Variation Table 5: Artifact Types and Linking

| Command | Artifact Types | Link Format in TODO.md | Justification |
|---------|---------------|----------------------|---------------|
| /research | reports/research-001.md, summaries/research-summary.md | - Main Report: [path]<br>- Summary: [path] | Research produces report + summary |
| /plan | plans/implementation-001.md | - Plan: [path]<br>- Plan Summary: {summary} | Planning produces single plan file |
| /revise | plans/implementation-{version}.md | - Plan: [new_path] (updates existing) | Revision creates new version, updates link |
| /implement | Implementation files, summaries/implementation-summary-{date}.md | - Implementation: [paths]<br>- Summary: [path] | Implementation produces code + summary |

**Justification**: Different artifact types per workflow

**Integration**: All follow artifact-management.md lazy directory creation and summary requirements

### Variation Table 6: Git Commit Scope and Messages

| Command | Commit Scope | Message Format | Justification |
|---------|-------------|----------------|---------------|
| /research | Research artifacts + TODO.md + state.json | "task {number}: research completed" | Research artifacts are self-contained |
| /plan | Plan file + TODO.md + state.json | "task {number}: plan created" | Plan file is self-contained |
| /revise | New plan file + TODO.md + state.json | "task {number}: plan revised to v{version}" | New plan version is self-contained |
| /implement | Implementation files + TODO.md + state.json + plan (if exists) | "task {number}: implementation completed" | Implementation may update plan status |

**Justification**: Different artifact scopes per workflow

**Integration**: All follow git-commits.md targeted commit pattern

### Variation Table 7: Validation Checks

| Command | Unique Validation | Justification |
|---------|------------------|---------------|
| /research | Check for --divide flag | Optional topic subdivision feature |
| /plan | Warn if plan already exists | Prevent accidental plan overwrite (suggest /revise) |
| /revise | Require existing plan (fail if missing) | Revision requires existing plan to revise |
| /implement | Check for plan existence, determine resume phase | Resume support for interrupted work |

**Justification**: Command-specific requirements and features

**Note**: All commands perform common validations (task exists, not completed, etc.)

### Variation Table 8: Return Content

| Command | Return Content | Token Limit | Justification |
|---------|---------------|-------------|---------------|
| /research | Brief summary + research artifact paths | <100 tokens | Research summary in artifact, not return |
| /plan | Brief summary + plan path + phase count + effort | <100 tokens | Plan details in artifact, return includes metadata |
| /revise | Brief summary + new plan path + version | <100 tokens | Revision details in artifact, return includes version |
| /implement | Brief summary + implementation summary path | <100 tokens | Implementation details in summary artifact |

**Justification**: Different information needs per workflow

**Integration**: All follow subagent-return-format.md token limits

---

## Error Handling Patterns

### Pattern 1: Timeout Handling

**Scenario**: Agent execution exceeds timeout

**Handling**:
1. Capture timeout event
2. Check for partial artifacts
3. If partial artifacts exist:
   - Save partial artifacts
   - Update status to partial marker (if applicable)
   - Provide resume instructions
4. If no partial artifacts:
   - Keep in-progress status marker
   - Log timeout error
   - Recommend retry
5. Return to user with timeout error and recommendations

**Example**:
```
Error: Agent execution timed out after {timeout}s

Partial artifacts saved:
- {artifact_path}

Status: [PARTIAL] (for /implement) or [IN_PROGRESS] (for others)

Recommendation: Resume with /{command} {task_number} to continue
```

### Pattern 2: Validation Failure Handling

**Scenario**: Pre-flight or post-flight validation fails

**Handling**:
1. Identify validation failure point
2. Log validation error with details
3. Do not proceed to next stage
4. Revert status update if already applied
5. Return error to user with clear message
6. Provide corrective action recommendation

**Example**:
```
Error: Validation failed at {stage}

Details: {validation_error}

Status: Reverted to {previous_status}

Recommendation: {corrective_action}
```

### Pattern 3: Git Commit Failure Handling

**Scenario**: Git commit creation fails

**Handling**:
1. Log git error to errors.json
2. Continue with command execution (git failure is non-critical)
3. Include git error in return to user
4. Provide manual commit instructions
5. Do not fail the command

**Example**:
```
Warning: Git commit failed

Error: {git_error}

Artifacts created successfully:
- {artifact_paths}

Status: [COMPLETED] (or appropriate completion marker)

Recommendation: Manually commit changes with:
  git add {files}
  git commit -m "task {number}: {action}"
```

### Pattern 4: Agent Return Validation Failure

**Scenario**: Agent return does not match subagent-return-format.md

**Handling**:
1. Log validation error with details
2. Treat as failed status
3. Check for partial artifacts on disk
4. If artifacts exist: Save and link them
5. Return validation error to user
6. Recommend agent fix or manual completion

**Example**:
```
Error: Agent return validation failed

Details: {validation_error}

Partial artifacts found:
- {artifact_paths}

Status: [FAILED] or [IN_PROGRESS]

Recommendation: Check agent implementation or complete manually
```

---

## Validation Framework

### Return Validation (Stage 5)

Validate agent return against subagent-return-format.md:

**Required Fields**:
- status: string (completed|partial|failed|blocked)
- summary: string (<100 tokens)
- artifacts: array of objects
- metadata: object with session_id, duration, agent_type
- errors: array (may be empty)
- next_steps: string

**Artifact Object Structure**:
```json
{
  "type": "string",
  "path": "string",
  "summary": "string"
}
```

**Metadata Object Structure**:
```json
{
  "session_id": "string",
  "duration_seconds": number,
  "agent_type": "string",
  "delegation_depth": number,
  "delegation_path": array
}
```

**Validation Logic**:
```
1. Check all required fields present
2. Validate status is valid value
3. Validate summary within token limit
4. Validate artifacts array structure
5. Validate each artifact has type, path, summary
6. Validate metadata has all required fields
7. Validate session_id matches expected value
8. Validate errors array structure
```

### Artifact Validation (Stage 6)

Validate artifacts exist and are well-formed:

**Validation Checks**:
- [ ] Artifact path exists on disk
- [ ] Artifact file is not empty
- [ ] Artifact file is readable
- [ ] Summary artifact exists (if required)
- [ ] Summary within token limit (<100 tokens, ~400 chars)
- [ ] Artifact type is valid
- [ ] Artifact path follows naming convention

**Summary Artifact Requirements** (per artifact-management.md):
- Must exist in summaries/ subdirectory
- Must be named {type}-summary.md or {type}-summary-{date}.md
- Must contain brief summary (<100 tokens)
- Must be included in artifacts array

---

## Integration with Existing Standards

### status-markers.md Integration

**Purpose**: Defines all status markers and transition rules

**Integration Points**:
- Stage 1 (Preflight): Use status markers for in-progress transitions
- Stage 7 (Postflight): Use status markers for completion transitions
- Variation Table 1: All status markers defined in status-markers.md

**Compliance**:
- All commands use markers from status-markers.md
- All transitions follow rules in status-markers.md
- Atomic updates via status-sync-manager

### subagent-return-format.md Integration

**Purpose**: Defines standardized return format for all agents

**Integration Points**:
- Stage 5 (ReceiveResults): Validate return against subagent-return-format.md
- Stage 8 (ReturnSuccess): Format return per subagent-return-format.md
- Validation Framework: Use subagent-return-format.md validation rules

**Compliance**:
- All agents return format per subagent-return-format.md
- All commands validate returns per subagent-return-format.md
- Summary artifacts required per subagent-return-format.md

### artifact-management.md Integration

**Purpose**: Defines lazy directory creation and artifact requirements

**Integration Points**:
- Stage 6 (ProcessResults): Validate artifacts per artifact-management.md
- Stage 7 (Postflight): Link artifacts per artifact-management.md
- Variation Table 5: Artifact types follow artifact-management.md

**Compliance**:
- All commands use lazy directory creation
- All commands create summary artifacts
- All commands follow naming conventions

### git-commits.md Integration

**Purpose**: Defines targeted git commit patterns

**Integration Points**:
- Stage 7 (Postflight): Create git commits per git-commits.md
- Variation Table 6: Commit scopes follow git-commits.md
- Error Pattern 3: Git failure handling per git-commits.md

**Compliance**:
- All commands create targeted commits
- All commands use git-workflow-manager
- All commands handle git failures gracefully

---

## Usage in Commands

### Referencing the Lifecycle

Commands should reference this file in their context loading:

```
Context Loaded:
@.opencode/context/common/workflows/command-lifecycle.md
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@.opencode/context/common/system/status-markers.md
@.opencode/context/common/standards/subagent-return-format.md
@.opencode/context/common/system/git-commits.md
```

### Documenting Variations

Commands should document only their variations from the common pattern:

```xml
<workflow_execution>
  Follow command-lifecycle.md 8-stage pattern with these variations:
  
  <stage id="1" name="Preflight">
    <status_transition>
      Initial: [NOT STARTED]
      In-Progress: [RESEARCHING]
    </status_transition>
    <validation>
      Check for --divide flag (topic subdivision)
    </validation>
  </stage>
  
  <stage id="2" name="CheckLanguage">
    <routing>
      Language: lean → lean-research-agent
      Language: * → researcher
    </routing>
  </stage>
  
  <stage id="3" name="PrepareDelegation">
    <timeout>3600s (1 hour)</timeout>
    <special_context>
      divide_topics: boolean (from --divide flag)
    </special_context>
  </stage>
  
  <!-- Stages 4-6: Follow command-lifecycle.md (no variations) -->
  
  <stage id="7" name="Postflight">
    <status_transition>
      Completion: [RESEARCHED]
      Partial: [RESEARCHING]
    </status_transition>
    <artifact_linking>
      - Main Report: [path]
      - Summary: [path]
    </artifact_linking>
    <git_commit>
      Scope: Research artifacts + TODO.md + state.json
      Message: "task {number}: research completed"
    </git_commit>
  </stage>
  
  <stage id="8" name="ReturnSuccess">
    <return_format>
      Brief summary + research artifact paths
    </return_format>
  </stage>
</workflow_execution>
```

### Example: Minimal Command File

With lifecycle reference, command files can be much shorter:

```markdown
---
name: research
agent: orchestrator
description: "Conduct research and create reports with [RESEARCHED] status"
---

Context Loaded:
@.opencode/context/common/workflows/command-lifecycle.md
@.opencode/specs/TODO.md
@.opencode/specs/state.json

<workflow_execution>
  Follow command-lifecycle.md 8-stage pattern.
  
  Variations:
  - Status: [NOT STARTED] → [RESEARCHING] → [RESEARCHED]
  - Routing: lean → lean-research-agent, * → researcher
  - Timeout: 3600s
  - Artifacts: reports/research-001.md, summaries/research-summary.md
  - Git: "task {number}: research completed"
</workflow_execution>
```

---

## References

### Analyzed Files

**Commands**:
- .opencode/command/research.md (466 lines → ~300 lines with lifecycle)
- .opencode/command/plan.md (450 lines → ~290 lines with lifecycle)
- .opencode/command/revise.md (422 lines → ~280 lines with lifecycle)
- .opencode/command/implement.md (623 lines → ~330 lines with lifecycle)

**Total Reduction**: 1,961 lines → 1,200 lines (39% reduction)

**Agents**:
- .opencode/agent/subagents/researcher.md
- .opencode/agent/subagents/planner.md
- .opencode/agent/subagents/lean-research-agent.md
- .opencode/agent/subagents/lean-implementation-agent.md
- .opencode/agent/subagents/task-executor.md
- .opencode/agent/subagents/implementer.md

**Standards**:
- .opencode/context/common/system/status-markers.md
- .opencode/context/common/standards/subagent-return-format.md
- .opencode/context/common/system/artifact-management.md
- .opencode/context/common/system/git-commits.md

### Related Tasks

- Task 191: Fix subagent delegation hang (created subagent-return-format.md)
- Task 169: Context window protection (created summary requirements)
- Task 156: Targeted git commits (created git-commits.md)
- Task 208: Fix Lean routing (enhanced routing validation)
- Task 207: Reduce implement output verbosity (summary artifacts)

### Research Artifacts

- Main Report: .opencode/specs/211_standardize_command_lifecycle_procedures/reports/research-001.md
- Summary: .opencode/specs/211_standardize_command_lifecycle_procedures/summaries/research-summary.md

---

## Version History

**Version 1.0** (2025-12-28):
- Initial creation
- Extracted 8-stage pattern from 4 commands
- Documented 8 variation categories
- Created 4 error handling patterns
- Integrated with 4 existing standards
- Achieved 39% duplication reduction target
