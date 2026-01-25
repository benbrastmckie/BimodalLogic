# Research Report: Revise /meta Command to Accept Optional Task Number

**Task**: 294 - Revise /meta command to accept optional task number  
**Started**: 2026-01-04  
**Completed**: 2026-01-04  
**Effort**: 2 hours  
**Priority**: Medium  
**Dependencies**: None  
**Sources/Inputs**: 
- .opencode/command/meta.md (current implementation)
- .opencode/command/research.md (reference pattern)
- .opencode/command/implement.md (reference pattern)
- .opencode/command/plan.md (reference pattern)
- .opencode/agent/subagents/meta.md (meta agent)
- .opencode/specs/state.json (task metadata structure)
- .opencode/context/core/system/routing-guide.md (routing patterns)

**Artifacts**: 
- .opencode/specs/294_revise_meta_command_to_accept_optional_task_number/reports/research-001.md

**Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

---

## Executive Summary

This research analyzes the current /meta command implementation and compares it with the /research, /implement, and /plan commands to identify the changes needed to support an optional task number argument. The /meta command currently supports two modes: Prompt Mode (with arguments) and Interactive Mode (no arguments). The proposed enhancement will add a third mode: Task Mode (with task number), enabling users to run /meta on existing tasks to generate meta-related implementation plans.

**Key Findings**:
1. /research, /implement, and /plan commands all follow a consistent 2-stage pattern: ParseAndValidate → Delegate
2. Task number parsing extracts the first token from $ARGUMENTS and validates it as an integer
3. Task metadata is extracted from state.json (8x faster than TODO.md parsing)
4. Language-based routing uses the extracted language field to determine target agent
5. /meta command currently has an 8-stage workflow that needs to be adapted for task-based invocation
6. Backward compatibility can be maintained by detecting task number vs. prompt vs. no arguments

**Recommendations**:
1. Add Stage 1 (ParseAndValidate) to /meta command for task number detection
2. Implement three-mode detection: Task Mode (integer first token) → Prompt Mode (non-integer arguments) → Interactive Mode (no arguments)
3. Extract task metadata from state.json when task number provided
4. Adapt meta agent workflow to skip interview stages when task context is provided
5. Maintain full backward compatibility with existing /meta usage patterns

---

## Context & Scope

### Research Objective

Analyze how /research, /implement, and /plan commands parse task numbers and extract metadata, then design a similar pattern for /meta command that maintains backward compatibility with existing usage modes.

### Current /meta Command Behavior

The /meta command currently supports two modes:

1. **Prompt Mode** (with $ARGUMENTS): 
   - User provides requirements directly: `/meta "I want to revise my opencode system..."`
   - Skips Stage 1 (InitiateInterview)
   - Parses target_domain from $ARGUMENTS
   - Proceeds to Stage 2 (GatherDomainInformation) with pre-populated context

2. **Interactive Mode** (no $ARGUMENTS):
   - User provides no arguments: `/meta`
   - Executes full 8-stage interactive interview
   - Gathers requirements through guided questions

### Desired Enhancement

Add a third mode:

3. **Task Mode** (with task number):
   - User provides task number: `/meta 294`
   - Extracts task metadata from state.json
   - Uses task description and context to generate meta-related plans
   - Skips interactive interview stages
   - Maintains backward compatibility with Prompt Mode and Interactive Mode

---

## Key Findings

### Finding 1: Consistent Command Parsing Pattern

All workflow commands (/research, /implement, /plan) follow a consistent 2-stage pattern:

**Stage 1: ParseAndValidate**
- Parse task number from $ARGUMENTS (first token)
- Validate state.json exists and is valid JSON
- Lookup task in state.json by project_number
- Extract all metadata at once (language, status, description, priority, etc.)
- Validate task status allows the operation
- Extract optional custom prompt from remaining tokens
- Determine target agent based on language

**Stage 2: Delegate**
- Invoke target agent via task tool
- Wait for agent to complete
- Relay result to user

**Example from /research command** (lines 26-83):

```markdown
<stage id="1" name="ParseAndValidate">
  <action>Parse task number and lookup in state.json</action>
  <process>
    1. Parse task number from $ARGUMENTS
       - $ARGUMENTS contains: "197" or "197 Focus on CLI integration"
       - Extract first token as task_number
       - Validate is integer
    
    2. Validate state.json exists and is valid
       - Check .opencode/specs/state.json exists
       - Validate is valid JSON with jq
       - If missing/corrupt: Return error "Run /meta to regenerate state.json"
    
    3. Lookup task in state.json
       - Use jq to find task by project_number:
         task_data=$(jq -r --arg num "$task_number" \
           '.active_projects[] | select(.project_number == ($num | tonumber))' \
           .opencode/specs/state.json)
       - If task_data is empty: Return error "Task $task_number not found"
    
    4. Extract all metadata at once
       - language=$(echo "$task_data" | jq -r '.language // "general"')
       - status=$(echo "$task_data" | jq -r '.status')
       - project_name=$(echo "$task_data" | jq -r '.project_name')
       - description=$(echo "$task_data" | jq -r '.description // ""')
       - priority=$(echo "$task_data" | jq -r '.priority')
    
    5. Validate task status allows research
       - If status is "completed": Return error "Task $task_number already completed"
    
    6. Extract research focus from $ARGUMENTS if present
       - If $ARGUMENTS has multiple tokens: research_focus = remaining tokens
       - Else: research_focus = ""
    
    7. Determine target agent based on language
       - lean → lean-research-agent
       - general → researcher
  </process>
  <checkpoint>Task validated, metadata extracted, target agent determined</checkpoint>
</stage>
```

**Key Observations**:
- Task number is always the first token
- Validation happens before delegation
- Metadata extraction uses jq for efficiency (8x faster than grep)
- Custom prompts are optional (remaining tokens after task number)
- Language-based routing determines target agent

### Finding 2: Task Metadata Structure in state.json

Task metadata in state.json includes all fields needed for context:

```json
{
  "project_number": 294,
  "project_name": "revise_meta_command_to_accept_optional_task_number",
  "type": "feature",
  "phase": "not_started",
  "status": "not_started",
  "priority": "medium",
  "language": "markdown",
  "created": "2026-01-05T03:39:48Z",
  "last_updated": "2026-01-05T03:39:48Z"
}
```

**Available Fields**:
- `project_number`: Task number (integer)
- `project_name`: Slug for directory naming
- `type`: Task type (feature, bugfix, meta, etc.)
- `phase`: Current phase (not_started, research_in_progress, etc.)
- `status`: Current status (not_started, researching, researched, etc.)
- `priority`: Priority level (high, medium, low)
- `language`: Task language (lean, markdown, general, etc.)
- `description`: Task description (from TODO.md, optional)
- `created`: Creation timestamp
- `last_updated`: Last update timestamp
- `artifacts`: Array of artifact paths (optional)
- `plan_path`: Path to implementation plan (optional)

**Extraction Pattern**:

```bash
# Extract task metadata from state.json
task_data=$(jq -r --arg num "$task_number" \
  '.active_projects[] | select(.project_number == ($num | tonumber))' \
  .opencode/specs/state.json)

# Extract specific fields
language=$(echo "$task_data" | jq -r '.language // "general"')
status=$(echo "$task_data" | jq -r '.status')
project_name=$(echo "$task_data" | jq -r '.project_name')
description=$(echo "$task_data" | jq -r '.description // ""')
priority=$(echo "$task_data" | jq -r '.priority')
```

### Finding 3: Three-Mode Detection Pattern

To support task number, prompt, and no arguments, the command needs to detect which mode to use:

**Mode Detection Logic**:

```bash
# Check if $ARGUMENTS is empty
if [ -z "$ARGUMENTS" ]; then
  mode="interactive"
  # Execute full 8-stage interview
else
  # Extract first token
  first_token=$(echo "$ARGUMENTS" | awk '{print $1}')
  
  # Check if first token is an integer (task number)
  if [[ "$first_token" =~ ^[0-9]+$ ]]; then
    mode="task"
    task_number="$first_token"
    # Extract optional custom prompt (remaining tokens)
    custom_prompt=$(echo "$ARGUMENTS" | cut -d' ' -f2-)
    # Lookup task in state.json and extract metadata
  else
    mode="prompt"
    target_domain="$ARGUMENTS"
    # Parse target_domain to extract domain, purpose, requirements
  fi
fi
```

**Mode Behaviors**:

1. **Task Mode** (`/meta 294` or `/meta 294 custom prompt`):
   - Parse task number from first token
   - Validate task exists in state.json
   - Extract task metadata (description, language, priority, etc.)
   - Use task description as domain context
   - Skip interview stages (Stage 1-6)
   - Generate implementation plan for task
   - Create plan artifact in task directory
   - Update task status to [PLANNED]

2. **Prompt Mode** (`/meta "I want to revise..."`):
   - Parse target_domain from $ARGUMENTS
   - Extract domain, purpose, requirements from prompt
   - Skip Stage 1 (InitiateInterview)
   - Proceed to Stage 2 with pre-populated context
   - Execute remaining stages (2-8)
   - Create new tasks with plan artifacts

3. **Interactive Mode** (`/meta`):
   - Execute full 8-stage interview
   - Gather requirements through guided questions
   - Create new tasks with plan artifacts

### Finding 4: Current /meta Command Structure

The /meta command currently has an 8-stage workflow:

**Stage 0: DetectExistingProject**
- Scan for existing .opencode directory
- Offer merge strategies if found
- Determine integration approach

**Stage 1: InitiateInterview** (CONDITIONAL: Skip if target_domain provided)
- Explain meta-programming process
- Set expectations for interview stages
- Confirm user readiness to proceed

**Stage 2: GatherDomainInformation** (adaptive based on mode)
- Collect domain, purpose, and target user information
- Pre-populate if Prompt Mode
- Ask questions if Interactive Mode

**Stage 3: IdentifyUseCases**
- Explore top 3-5 use cases
- Assess complexity and dependencies
- Prioritize capabilities

**Stage 4: AssessComplexity**
- Determine agent count and hierarchy
- Identify knowledge requirements
- Plan state management approach

**Stage 5: IdentifyIntegrations**
- Discover external tool requirements
- Plan file operations and custom commands
- Map integration points

**Stage 6: ReviewAndConfirm**
- Present comprehensive architecture summary
- Get user confirmation
- Validate understanding before generation

**Stage 7: CreateTasksWithArtifacts**
- Determine task breakdown based on system complexity
- Create project directories in .opencode/specs/NNN_*/
- Generate plan artifacts ONLY (plans/implementation-001.md)
- Create task entries in TODO.md with Type field set to 'meta'
- Update state.json with task metadata
- Validate all artifacts

**Stage 8: DeliverTaskSummary**
- Present task list with plan artifact links
- Provide usage instructions for /implement command
- Create git commit with TODO.md, state.json, and plan artifacts
- Return standardized format with task metadata

**Key Observations**:
- Stage 1 is already conditional (skipped in Prompt Mode)
- Stages 2-6 gather requirements through interview or prompt parsing
- Stage 7 creates tasks and plan artifacts
- Stage 8 delivers summary and creates git commit

### Finding 5: Adaptation Strategy for Task Mode

When /meta is invoked with a task number, the workflow should adapt:

**Task Mode Workflow**:

1. **Stage 1: ParseAndValidate** (NEW)
   - Parse task number from $ARGUMENTS
   - Validate task exists in state.json
   - Extract task metadata
   - Determine if task is suitable for /meta (type="meta" or requires meta planning)
   - Extract optional custom prompt

2. **Stage 2-6: Skip Interview** (ADAPTED)
   - Skip all interview stages (requirements already defined in task)
   - Use task metadata as context:
     - domain = inferred from task description
     - purpose = task description
     - target_users = inferred from task context
     - use_cases = derived from task requirements
     - complexity = estimated from task effort
     - integrations = identified from task description

3. **Stage 7: CreatePlanArtifact** (ADAPTED)
   - Create plan artifact in existing task directory (.opencode/specs/{task_number}_{slug}/)
   - Generate implementation plan based on task description
   - Follow plan.md template standard
   - Update task status to [PLANNED]

4. **Stage 8: DeliverPlanSummary** (ADAPTED)
   - Present plan artifact link
   - Provide usage instructions for /implement command
   - Create git commit with plan artifact
   - Return standardized format

**Comparison with /plan Command**:

The /meta command in Task Mode would be similar to /plan command but with meta-specific planning:

| Aspect | /plan Command | /meta in Task Mode |
|--------|---------------|-------------------|
| Input | Task number | Task number |
| Validation | Parse and validate task | Parse and validate task |
| Context | Extract from state.json | Extract from state.json |
| Planning | General implementation plan | Meta-specific implementation plan |
| Artifact | plans/implementation-001.md | plans/implementation-001.md |
| Status | [PLANNED] | [PLANNED] |
| Agent | planner or lean-planner | meta (adapted workflow) |

**Key Difference**: /meta in Task Mode would generate meta-specific implementation plans (for creating agents, commands, context files) rather than general implementation plans.

---

## Detailed Analysis

### Analysis 1: Argument Parsing Implementation

**Current /meta Command Argument Handling**:

The /meta command currently uses `$ARGUMENTS` directly as `target_domain`:

```markdown
<target_domain>
$ARGUMENTS
</target_domain>
```

**Mode Detection in Stage 1**:

```markdown
1. Check if target_domain is non-empty:
   a. If target_domain is non-empty (Prompt Mode):
      - Log: "[INFO] Prompt mode detected - skipping interactive interview"
      - Parse target_domain to extract initial context
      - Skip to Stage 2 immediately
   
   b. If target_domain is empty (Interactive Mode):
      - Continue with interactive interview below
```

**Proposed Enhancement**:

Add a new Stage 1 (ParseAndValidate) before the current Stage 1 (InitiateInterview):

```markdown
<stage id="1" name="ParseAndValidate">
  <action>Parse arguments and determine mode (Task/Prompt/Interactive)</action>
  <process>
    1. Check if $ARGUMENTS is empty:
       - If empty: Set mode="interactive", skip to Stage 2 (InitiateInterview)
    
    2. Extract first token from $ARGUMENTS:
       - first_token=$(echo "$ARGUMENTS" | awk '{print $1}')
    
    3. Check if first token is an integer (task number):
       - if [[ "$first_token" =~ ^[0-9]+$ ]]; then
           mode="task"
           task_number="$first_token"
         else
           mode="prompt"
           target_domain="$ARGUMENTS"
         fi
    
    4. If mode="task":
       a. Validate state.json exists and is valid
       b. Lookup task in state.json by project_number
       c. Extract task metadata (language, status, description, priority, etc.)
       d. Validate task status allows planning
       e. Extract optional custom prompt from remaining tokens
       f. Store task context for later stages
       g. Skip to Stage 7 (CreatePlanArtifact) - adapted for single task
    
    5. If mode="prompt":
       a. Store target_domain for Stage 2
       b. Skip to Stage 2 (GatherDomainInformation)
    
    6. If mode="interactive":
       a. Skip to Stage 2 (InitiateInterview)
  </process>
  <checkpoint>Mode determined, arguments parsed, context prepared</checkpoint>
</stage>
```

**Renumbering Impact**:

Adding Stage 1 (ParseAndValidate) would shift all existing stages:

- Current Stage 0 (DetectExistingProject) → Stage 0 (unchanged)
- NEW Stage 1 (ParseAndValidate) → Stage 1
- Current Stage 1 (InitiateInterview) → Stage 2
- Current Stage 2 (GatherDomainInformation) → Stage 3
- Current Stage 3 (IdentifyUseCases) → Stage 4
- Current Stage 4 (AssessComplexity) → Stage 5
- Current Stage 5 (IdentifyIntegrations) → Stage 6
- Current Stage 6 (ReviewAndConfirm) → Stage 7
- Current Stage 7 (CreateTasksWithArtifacts) → Stage 8
- Current Stage 8 (DeliverTaskSummary) → Stage 9

**Alternative: Keep Stage Numbering**:

To avoid renumbering, we could make Stage 1 conditional:

```markdown
<stage id="1" name="ParseAndValidate">
  <action>Parse arguments and determine mode (CONDITIONAL: Execute only if $ARGUMENTS provided)</action>
  <process>
    1. If $ARGUMENTS is empty:
       - Set mode="interactive"
       - Skip to Stage 2 (InitiateInterview)
    
    2. If $ARGUMENTS is non-empty:
       - Extract first token
       - Detect if task number (integer) or prompt (non-integer)
       - Set mode="task" or mode="prompt"
       - Parse and validate accordingly
       - Skip to appropriate stage based on mode
  </process>
</stage>

<stage id="2" name="InitiateInterview">
  <action>Explain meta-programming process (CONDITIONAL: Execute only if mode="interactive")</action>
  ...
</stage>
```

This approach maintains the existing stage numbering while adding the new functionality.

### Analysis 2: State.json Metadata Extraction

**Extraction Pattern from /research Command**:

```bash
# Validate state.json exists and is valid
if [ ! -f ".opencode/specs/state.json" ]; then
  echo "[FAIL] state.json not found"
  exit 1
fi

if ! jq empty .opencode/specs/state.json 2>/dev/null; then
  echo "[FAIL] state.json is not valid JSON"
  exit 1
fi

# Lookup task in state.json
task_data=$(jq -r --arg num "$task_number" \
  '.active_projects[] | select(.project_number == ($num | tonumber))' \
  .opencode/specs/state.json)

if [ -z "$task_data" ]; then
  echo "[FAIL] Task $task_number not found in state.json"
  exit 1
fi

# Extract all metadata at once
language=$(echo "$task_data" | jq -r '.language // "general"')
status=$(echo "$task_data" | jq -r '.status')
project_name=$(echo "$task_data" | jq -r '.project_name')
description=$(echo "$task_data" | jq -r '.description // ""')
priority=$(echo "$task_data" | jq -r '.priority')
type=$(echo "$task_data" | jq -r '.type // "general"')
```

**Metadata Fields Useful for /meta in Task Mode**:

- `project_number`: Task number (for directory naming and references)
- `project_name`: Slug (for directory path)
- `description`: Task description (provides context for planning)
- `type`: Task type (should be "meta" for meta-related tasks)
- `priority`: Priority level (affects planning depth)
- `language`: Task language (affects tool selection)
- `status`: Current status (validates task is not completed)
- `artifacts`: Existing artifacts (check if plan already exists)

**Usage in Task Mode**:

```bash
# After extracting metadata, use it to populate context:

# Domain context from task description
domain=$(echo "$description" | grep -oP '(?<=for ).*?(?= system)' || echo "custom")

# Purpose from task description
purpose="$description"

# Target users inferred from domain
if [[ "$description" =~ "proof" || "$description" =~ "lean" ]]; then
  target_users="Researchers and theorem provers"
elif [[ "$description" =~ "development" || "$description" =~ "code" ]]; then
  target_users="Software developers"
else
  target_users="System users"
fi

# Use cases derived from task description
# (parse action items or acceptance criteria from TODO.md)

# Complexity estimated from effort
# (extract from TODO.md or default to "moderate")
```

### Analysis 3: Backward Compatibility Considerations

**Current Usage Patterns**:

1. **Interactive Mode**: `/meta`
   - No arguments provided
   - Full 8-stage interview
   - Creates multiple tasks

2. **Prompt Mode**: `/meta "I want to revise my opencode system..."`
   - Arguments provided (non-integer first token)
   - Skips Stage 1 (InitiateInterview)
   - Parses target_domain from arguments
   - Creates multiple tasks

**New Usage Pattern**:

3. **Task Mode**: `/meta 294` or `/meta 294 custom prompt`
   - Arguments provided (integer first token)
   - Skips interview stages
   - Extracts task context from state.json
   - Creates plan artifact for single task

**Compatibility Matrix**:

| Input | Current Behavior | New Behavior | Compatible? |
|-------|------------------|--------------|-------------|
| `/meta` | Interactive Mode | Interactive Mode | ✅ Yes |
| `/meta "prompt"` | Prompt Mode | Prompt Mode | ✅ Yes |
| `/meta 294` | Prompt Mode (treats "294" as domain) | Task Mode | ⚠️ Breaking Change |
| `/meta 294 prompt` | Prompt Mode | Task Mode with custom prompt | ⚠️ Breaking Change |

**Potential Breaking Change**:

If a user currently runs `/meta 294` expecting it to be treated as a domain prompt (e.g., "294" as a project code), the new behavior would break that usage.

**Mitigation Strategy**:

1. **Document the change**: Clearly document that integer-only arguments are now treated as task numbers
2. **Validation**: Add validation to check if task number exists before treating as Task Mode
3. **Fallback**: If task number not found, fall back to Prompt Mode with warning
4. **User guidance**: Update documentation and examples to show new usage pattern

**Recommended Validation**:

```bash
# If first token is integer
if [[ "$first_token" =~ ^[0-9]+$ ]]; then
  # Check if task exists in state.json
  task_data=$(jq -r --arg num "$first_token" \
    '.active_projects[] | select(.project_number == ($num | tonumber))' \
    .opencode/specs/state.json)
  
  if [ -z "$task_data" ]; then
    # Task not found - fall back to Prompt Mode with warning
    echo "[WARN] Task $first_token not found in state.json"
    echo "[WARN] Treating '$ARGUMENTS' as domain prompt instead"
    mode="prompt"
    target_domain="$ARGUMENTS"
  else
    # Task found - use Task Mode
    mode="task"
    task_number="$first_token"
  fi
fi
```

This approach maintains backward compatibility by falling back to Prompt Mode if the integer doesn't match a task number.

### Analysis 4: Workflow Adaptation for Task Mode

**Current Workflow (Prompt/Interactive Mode)**:

```
Stage 0: DetectExistingProject
  ↓
Stage 1: InitiateInterview (skip if Prompt Mode)
  ↓
Stage 2: GatherDomainInformation (pre-populate if Prompt Mode)
  ↓
Stage 3: IdentifyUseCases
  ↓
Stage 4: AssessComplexity
  ↓
Stage 5: IdentifyIntegrations
  ↓
Stage 6: ReviewAndConfirm
  ↓
Stage 7: CreateTasksWithArtifacts (creates MULTIPLE tasks)
  ↓
Stage 8: DeliverTaskSummary
```

**Proposed Workflow (Task Mode)**:

```
Stage 1: ParseAndValidate
  ↓ (detect mode="task")
  ↓
Stage 7: CreatePlanArtifact (ADAPTED for single task)
  ↓
Stage 8: DeliverPlanSummary (ADAPTED for single task)
```

**Stage 7 Adaptation for Task Mode**:

Instead of creating multiple tasks, create a plan artifact for the single task:

```markdown
<stage id="7" name="CreatePlanArtifact">
  <action>Create implementation plan for task (ADAPTED for Task Mode)</action>
  <process>
    1. If mode="task":
       a. Use existing task directory: .opencode/specs/{task_number}_{project_name}/
       b. Create plans/ subdirectory if not exists
       c. Generate plan artifact: plans/implementation-001.md
       d. Include metadata:
          - Task: {task_number} - {description}
          - Status: [NOT STARTED]
          - Effort: {estimated_hours} hours
          - Priority: {priority}
          - Type: {type}
          - Dependencies: {dependencies}
       e. Include sections:
          - Overview (from task description)
          - Goals & Non-Goals
          - Implementation Phases (1-2 hours each)
          - Testing & Validation
          - Artifacts & Outputs
       f. Write plan artifact to disk
       g. Validate plan artifact exists and is non-empty
    
    2. If mode="prompt" or mode="interactive":
       a. Execute current Stage 7 logic (create multiple tasks)
  </process>
  <validation>
    - Plan artifact must exist and be non-empty
    - Plan must follow plan.md template standard
  </validation>
  <checkpoint>Plan artifact created for task</checkpoint>
</stage>
```

**Stage 8 Adaptation for Task Mode**:

```markdown
<stage id="8" name="DeliverPlanSummary">
  <action>Present plan artifact and usage instructions (ADAPTED for Task Mode)</action>
  <process>
    1. If mode="task":
       a. Format plan presentation:
          "Implementation plan created for task {task_number}!
          
          TASK: {task_number} - {description}
          STATUS: [PLANNED]
          PLAN: {plan_path}
          EFFORT: {estimated_hours} hours
          
          USAGE INSTRUCTIONS:
          1. Review the plan artifact:
             - Plan includes detailed phases, estimates, and acceptance criteria
             - Plan is self-documenting with metadata and phase breakdown
          
          2. Implement task using /implement command:
             - Run `/implement {task_number}` when ready
             - Meta task will route to meta subagents
          
          NEXT STEPS:
          - Review plan artifact at {plan_path}
          - Run `/implement {task_number}` to start implementation"
       
       b. Create git commit:
          - Delegate to git-workflow-manager
          - Commit message: "task {task_number}: implementation plan created"
          - Include: TODO.md, state.json, plan artifact
       
       c. Return standardized format:
          {
            "status": "completed",
            "summary": "Created implementation plan for task {task_number}. Review plan and run /implement to execute.",
            "artifacts": [
              {
                "type": "plan",
                "path": "{plan_path}",
                "summary": "Task {task_number}: {description} ({estimated_hours} hours)"
              }
            ],
            "metadata": {
              "session_id": "{session_id}",
              "duration_seconds": {duration},
              "agent_type": "meta",
              "mode": "task",
              "task_number": {task_number}
            },
            "errors": [],
            "next_steps": "Review plan at {plan_path} and run /implement {task_number}"
          }
    
    2. If mode="prompt" or mode="interactive":
       a. Execute current Stage 8 logic (deliver task summary for multiple tasks)
  </process>
</stage>
```

### Analysis 5: Comparison with /plan Command

**Similarities**:

1. Both accept task number as first argument
2. Both validate task exists in state.json
3. Both extract task metadata
4. Both create plan artifact in task directory
5. Both update task status to [PLANNED]
6. Both create git commit with plan artifact

**Differences**:

| Aspect | /plan Command | /meta in Task Mode |
|--------|---------------|-------------------|
| **Purpose** | General implementation planning | Meta-specific implementation planning |
| **Agent** | planner or lean-planner | meta (adapted workflow) |
| **Workflow** | 2-stage (ParseAndValidate → Delegate) | 9-stage (with conditional skipping) |
| **Plan Content** | General implementation phases | Meta-specific phases (agent creation, command creation, etc.) |
| **Routing** | Language-based (lean → lean-planner) | Type-based (meta → meta) |
| **Interview** | No interview | Optional interview (if mode="interactive") |

**When to Use Each**:

- **Use /plan**: For general implementation planning (code, documentation, configuration)
- **Use /meta**: For meta-programming tasks (creating agents, commands, context files, system architecture)

**Example Scenarios**:

1. **General Task**: "Implement proof search optimization"
   - Use: `/plan 260` → Creates general implementation plan
   - Agent: planner or lean-planner
   - Plan: Phases for code implementation, testing, documentation

2. **Meta Task**: "Create custom agent for proof verification"
   - Use: `/meta 294` → Creates meta-specific implementation plan
   - Agent: meta
   - Plan: Phases for agent design, workflow definition, context organization

**Potential Confusion**:

Users might be confused about when to use /plan vs. /meta for planning. Clear documentation is needed:

- **Use /plan** for implementation planning of existing features/fixes
- **Use /meta** for system architecture and meta-programming tasks
- **Use /meta with task number** when task is already defined and needs meta-specific planning
- **Use /meta without task number** when creating new system architecture from scratch

---

## Code Examples

### Example 1: Task Number Parsing (from /research command)

```bash
# Parse task number from $ARGUMENTS
task_number=$(echo "$ARGUMENTS" | awk '{print $1}')

# Validate is integer
if ! [[ "$task_number" =~ ^[0-9]+$ ]]; then
  echo "[FAIL] Task number must be an integer. Got: $task_number"
  echo "Usage: /research TASK_NUMBER [PROMPT]"
  exit 1
fi

echo "[INFO] Task number: $task_number"
```

### Example 2: State.json Validation and Lookup (from /implement command)

```bash
# Validate state.json exists and is valid
if [ ! -f ".opencode/specs/state.json" ]; then
  echo "[FAIL] state.json not found"
  echo "Recommendation: Run /meta to regenerate state.json"
  exit 1
fi

if ! jq empty .opencode/specs/state.json 2>/dev/null; then
  echo "[FAIL] state.json is not valid JSON"
  echo "Recommendation: Check state.json syntax"
  exit 1
fi

# Lookup task in state.json
task_data=$(jq -r --arg num "$task_number" \
  '.active_projects[] | select(.project_number == ($num | tonumber))' \
  .opencode/specs/state.json)

if [ -z "$task_data" ]; then
  echo "[FAIL] Task $task_number not found in state.json"
  exit 1
fi

echo "[PASS] Task $task_number found in state.json"
```

### Example 3: Metadata Extraction (from /plan command)

```bash
# Extract all metadata at once
language=$(echo "$task_data" | jq -r '.language // "general"')
status=$(echo "$task_data" | jq -r '.status')
project_name=$(echo "$task_data" | jq -r '.project_name')
description=$(echo "$task_data" | jq -r '.description // ""')
priority=$(echo "$task_data" | jq -r '.priority')
plan_path=$(echo "$task_data" | jq -r '.plan_path // ""')

echo "[INFO] Task metadata extracted:"
echo "  Language: $language"
echo "  Status: $status"
echo "  Project: $project_name"
echo "  Priority: $priority"
```

### Example 4: Three-Mode Detection for /meta

```bash
# Mode detection for /meta command
if [ -z "$ARGUMENTS" ]; then
  # No arguments - Interactive Mode
  mode="interactive"
  echo "[INFO] Interactive mode detected - starting guided interview"
else
  # Arguments provided - detect Task Mode vs. Prompt Mode
  first_token=$(echo "$ARGUMENTS" | awk '{print $1}')
  
  if [[ "$first_token" =~ ^[0-9]+$ ]]; then
    # First token is integer - check if task exists
    task_data=$(jq -r --arg num "$first_token" \
      '.active_projects[] | select(.project_number == ($num | tonumber))' \
      .opencode/specs/state.json 2>/dev/null)
    
    if [ -z "$task_data" ]; then
      # Task not found - fall back to Prompt Mode
      echo "[WARN] Task $first_token not found in state.json"
      echo "[WARN] Treating '$ARGUMENTS' as domain prompt instead"
      mode="prompt"
      target_domain="$ARGUMENTS"
    else
      # Task found - Task Mode
      mode="task"
      task_number="$first_token"
      # Extract optional custom prompt (remaining tokens)
      custom_prompt=$(echo "$ARGUMENTS" | cut -d' ' -f2-)
      echo "[INFO] Task mode detected - task $task_number"
    fi
  else
    # First token is not integer - Prompt Mode
    mode="prompt"
    target_domain="$ARGUMENTS"
    echo "[INFO] Prompt mode detected - using provided requirements"
  fi
fi
```

### Example 5: Conditional Stage Execution

```markdown
<stage id="1" name="ParseAndValidate">
  <action>Parse arguments and determine mode</action>
  <process>
    1. Detect mode (task/prompt/interactive) using logic from Example 4
    
    2. If mode="task":
       - Validate task exists
       - Extract task metadata
       - Skip to Stage 7 (CreatePlanArtifact)
    
    3. If mode="prompt":
       - Parse target_domain
       - Skip to Stage 3 (GatherDomainInformation)
    
    4. If mode="interactive":
       - Proceed to Stage 2 (InitiateInterview)
  </process>
  <checkpoint>Mode determined, context prepared</checkpoint>
</stage>

<stage id="2" name="InitiateInterview">
  <action>Explain meta-programming process (CONDITIONAL: Execute only if mode="interactive")</action>
  <process>
    1. Check mode:
       - If mode != "interactive": Skip this stage
       - If mode == "interactive": Execute interview initiation
    
    2. Welcome user and explain the process
    3. Ask: "Are you ready to begin?"
    4. Wait for user confirmation
  </process>
  <checkpoint>User ready to proceed (or stage skipped)</checkpoint>
</stage>
```

---

## Decisions

### Decision 1: Add Stage 1 (ParseAndValidate) to /meta Command

**Decision**: Add a new Stage 1 (ParseAndValidate) to the /meta command that detects mode (task/prompt/interactive) and parses arguments accordingly.

**Rationale**:
- Consistent with /research, /implement, and /plan commands
- Enables task number support while maintaining backward compatibility
- Provides clear separation between argument parsing and workflow execution

**Implementation**:
- Insert Stage 1 before current Stage 1 (InitiateInterview)
- Renumber existing stages: Stage 1 → Stage 2, Stage 2 → Stage 3, etc.
- Make all stages conditional based on detected mode

### Decision 2: Use Three-Mode Detection Pattern

**Decision**: Implement three-mode detection: Task Mode (integer first token) → Prompt Mode (non-integer arguments) → Interactive Mode (no arguments).

**Rationale**:
- Maintains full backward compatibility with existing usage
- Provides clear, predictable behavior based on input
- Follows established pattern from other commands

**Implementation**:
- Check if $ARGUMENTS is empty → Interactive Mode
- Check if first token is integer and task exists → Task Mode
- Otherwise → Prompt Mode
- Fall back to Prompt Mode if task number not found (with warning)

### Decision 3: Extract Task Metadata from state.json

**Decision**: Use state.json as the authoritative source for task metadata extraction, following the pattern from /research, /implement, and /plan commands.

**Rationale**:
- 8x faster than TODO.md parsing
- Single source of truth for task metadata
- Consistent with other workflow commands
- Enables efficient metadata extraction

**Implementation**:
- Use jq to lookup task by project_number
- Extract all metadata fields at once
- Validate task exists before proceeding
- Use metadata to populate context for planning

### Decision 4: Adapt Workflow for Task Mode

**Decision**: When mode="task", skip interview stages (2-6) and jump directly to Stage 7 (CreatePlanArtifact) with adapted logic for single task.

**Rationale**:
- Task context already defined in state.json
- No need for interactive interview
- Faster workflow for existing tasks
- Consistent with /plan command behavior

**Implementation**:
- Stage 1: Detect mode="task" and extract metadata
- Skip Stages 2-6 (interview stages)
- Stage 7: Create plan artifact for single task (not multiple tasks)
- Stage 8: Deliver plan summary for single task

### Decision 5: Maintain Backward Compatibility with Fallback

**Decision**: If first token is integer but task not found, fall back to Prompt Mode with warning instead of failing.

**Rationale**:
- Prevents breaking existing usage where user might use numbers as domain codes
- Provides graceful degradation
- Warns user about unexpected behavior
- Maintains usability

**Implementation**:
- Check if task exists in state.json
- If not found: Log warning and treat as Prompt Mode
- If found: Use Task Mode
- Document the behavior clearly

---

## Recommendations

### Recommendation 1: Implement Three-Mode Support in /meta Command

**Priority**: High  
**Effort**: 4-6 hours

**Description**: Add Stage 1 (ParseAndValidate) to /meta command to support three modes: Task Mode (with task number), Prompt Mode (with prompt), and Interactive Mode (no arguments).

**Implementation Steps**:

1. **Add Stage 1 (ParseAndValidate)** (1 hour):
   - Insert new stage before current Stage 1
   - Implement three-mode detection logic
   - Parse task number and validate if Task Mode
   - Extract task metadata from state.json
   - Determine which stages to execute based on mode

2. **Renumber Existing Stages** (30 minutes):
   - Current Stage 1 → Stage 2
   - Current Stage 2 → Stage 3
   - Current Stage 3 → Stage 4
   - Current Stage 4 → Stage 5
   - Current Stage 5 → Stage 6
   - Current Stage 6 → Stage 7
   - Current Stage 7 → Stage 8
   - Current Stage 8 → Stage 9

3. **Make Stages Conditional** (1 hour):
   - Add mode checks to each stage
   - Skip Stages 2-7 if mode="task"
   - Skip Stage 2 if mode="prompt"
   - Execute all stages if mode="interactive"

4. **Adapt Stage 8 for Task Mode** (1.5 hours):
   - Add conditional logic for mode="task"
   - Create plan artifact for single task (not multiple tasks)
   - Use existing task directory
   - Follow plan.md template standard
   - Update task status to [PLANNED]

5. **Adapt Stage 9 for Task Mode** (1 hour):
   - Add conditional logic for mode="task"
   - Present plan artifact link
   - Provide usage instructions for /implement
   - Create git commit with plan artifact
   - Return standardized format

6. **Test All Three Modes** (1 hour):
   - Test Task Mode: `/meta 294`
   - Test Prompt Mode: `/meta "I want to revise..."`
   - Test Interactive Mode: `/meta`
   - Verify backward compatibility
   - Verify plan artifacts created correctly

**Expected Outcome**:
- /meta command supports task number argument
- Backward compatibility maintained
- Consistent with /research, /implement, /plan commands
- Clear documentation of three modes

### Recommendation 2: Update /meta Command Documentation

**Priority**: High  
**Effort**: 1-2 hours

**Description**: Update .opencode/command/meta.md to document the new task number support and three-mode behavior.

**Documentation Updates**:

1. **Update Usage Section**:
   ```markdown
   ## Usage
   
   ```
   /meta [TASK_NUMBER | PROMPT]
   ```
   
   - **With task number**: Provide task number to create implementation plan for existing task
   - **With prompt**: Provide requirements directly, skip interactive interview
   - **Without arguments**: Start interactive interview to gather requirements
   ```

2. **Add Examples**:
   ```markdown
   ### Examples
   
   ```
   # Example 1: Task mode - create plan for existing task
   /meta 294
   
   # Example 2: Task mode with custom prompt
   /meta 294 "Focus on agent architecture"
   
   # Example 3: Prompt mode - provide requirements directly
   /meta "I want to revise my opencode system to add proof verification capabilities"
   
   # Example 4: Interactive mode - guided interview
   /meta
   > [Interactive interview follows]
   ```
   ```

3. **Update Workflow Section**:
   - Document three modes: Task Mode, Prompt Mode, Interactive Mode
   - Explain when each mode is used
   - Show stage execution flow for each mode

4. **Add Mode Detection Section**:
   - Explain how mode is detected
   - Document fallback behavior
   - Provide troubleshooting guidance

**Expected Outcome**:
- Clear documentation of new functionality
- Users understand when to use each mode
- Examples demonstrate all three modes

### Recommendation 3: Update meta.md Agent to Handle Task Context

**Priority**: High  
**Effort**: 2-3 hours

**Description**: Update .opencode/agent/subagents/meta.md to handle task context when invoked in Task Mode.

**Agent Updates**:

1. **Add Task Context Handling** (1 hour):
   - Detect if task_number provided in delegation context
   - Extract task metadata from delegation context
   - Use task description as domain context
   - Infer use cases from task requirements

2. **Adapt Stage Execution** (1 hour):
   - Skip interview stages if task context provided
   - Jump directly to plan creation
   - Use task metadata to populate plan template

3. **Update Return Format** (30 minutes):
   - Include task_number in metadata
   - Include mode in metadata
   - Return single plan artifact (not multiple tasks)

4. **Test Task Mode Invocation** (30 minutes):
   - Test with sample task
   - Verify plan artifact created
   - Verify status updated to [PLANNED]
   - Verify git commit created

**Expected Outcome**:
- meta agent handles task context correctly
- Plan artifacts created for single task
- Consistent with planner agent behavior

### Recommendation 4: Add Validation for Task Type

**Priority**: Medium  
**Effort**: 1 hour

**Description**: Add validation to check if task is suitable for /meta command (type="meta" or requires meta planning).

**Validation Logic**:

```bash
# Extract task type from metadata
type=$(echo "$task_data" | jq -r '.type // "general"')

# Validate task type is suitable for /meta
if [[ "$type" != "meta" ]]; then
  echo "[WARN] Task $task_number has type '$type' (not 'meta')"
  echo "[WARN] /meta is designed for meta-programming tasks"
  echo "[INFO] Consider using /plan for general implementation planning"
  echo ""
  echo "Continue anyway? (y/n)"
  read -r response
  if [[ "$response" != "y" ]]; then
    echo "[INFO] Cancelled by user"
    exit 0
  fi
fi
```

**Rationale**:
- Prevents confusion about when to use /meta vs. /plan
- Provides guidance to users
- Allows override if user knows what they're doing

**Expected Outcome**:
- Clear guidance on when to use /meta
- Reduced confusion between /meta and /plan
- User can override if needed

### Recommendation 5: Create Integration Tests

**Priority**: Medium  
**Effort**: 2-3 hours

**Description**: Create integration tests to verify all three modes work correctly and maintain backward compatibility.

**Test Cases**:

1. **Task Mode Tests**:
   - Test with valid task number
   - Test with invalid task number (should fall back to Prompt Mode)
   - Test with task number and custom prompt
   - Verify plan artifact created
   - Verify status updated to [PLANNED]

2. **Prompt Mode Tests**:
   - Test with non-integer prompt
   - Test with integer prompt that doesn't match task (should use Prompt Mode)
   - Verify multiple tasks created
   - Verify plan artifacts created for all tasks

3. **Interactive Mode Tests**:
   - Test with no arguments
   - Verify full interview executed
   - Verify multiple tasks created

4. **Backward Compatibility Tests**:
   - Test existing usage patterns
   - Verify no breaking changes
   - Verify fallback behavior works

**Expected Outcome**:
- Comprehensive test coverage
- Confidence in backward compatibility
- Early detection of regressions

---

## Risks & Mitigations

### Risk 1: Breaking Backward Compatibility

**Risk**: Users who currently use `/meta 294` expecting it to be treated as a domain prompt will experience breaking changes.

**Likelihood**: Low  
**Impact**: Medium

**Mitigation**:
1. Implement fallback to Prompt Mode if task number not found
2. Log warning when falling back
3. Document the change clearly
4. Provide migration guide for affected users
5. Test with existing usage patterns

**Contingency**:
- If breaking changes detected, add flag to force Prompt Mode: `/meta --prompt 294`
- Document flag usage for edge cases

### Risk 2: Confusion Between /meta and /plan

**Risk**: Users might be confused about when to use /meta vs. /plan for planning tasks.

**Likelihood**: Medium  
**Impact**: Low

**Mitigation**:
1. Add validation to check task type (warn if not "meta")
2. Document clear guidelines on when to use each command
3. Provide examples for both commands
4. Add help text to command output

**Contingency**:
- Add cross-reference in documentation: "For general implementation planning, use /plan"
- Add suggestion in /meta output: "Hint: Use /plan for non-meta tasks"

### Risk 3: Stage Renumbering Complexity

**Risk**: Renumbering stages from 1-8 to 1-9 might introduce errors or inconsistencies.

**Likelihood**: Low  
**Impact**: Medium

**Mitigation**:
1. Use systematic find-and-replace for stage numbers
2. Update all stage references in documentation
3. Test all stage transitions
4. Verify stage checkpoints work correctly

**Contingency**:
- If renumbering causes issues, use conditional Stage 1 without renumbering
- Keep existing stage numbers and make Stage 1 optional

### Risk 4: Metadata Extraction Failures

**Risk**: Task metadata might be incomplete or missing in state.json, causing extraction failures.

**Likelihood**: Low  
**Impact**: Medium

**Mitigation**:
1. Use default values for missing fields (e.g., `language // "general"`)
2. Validate required fields exist before proceeding
3. Provide clear error messages if validation fails
4. Fall back to Prompt Mode if metadata incomplete

**Contingency**:
- If metadata extraction fails, prompt user for missing information
- Offer to update state.json with missing metadata

### Risk 5: Workflow Adaptation Complexity

**Risk**: Adapting the 8-stage workflow for Task Mode might introduce complexity and maintenance burden.

**Likelihood**: Medium  
**Impact**: Low

**Mitigation**:
1. Use clear conditional logic for mode detection
2. Document mode-specific behavior in each stage
3. Keep Task Mode logic simple (skip stages, don't modify them)
4. Test all three modes thoroughly

**Contingency**:
- If complexity becomes unmanageable, create separate command: `/meta-plan TASK_NUMBER`
- Keep /meta focused on system creation, use /meta-plan for task planning

---

## Appendix: Sources and Citations

### Source 1: /research Command Implementation

**File**: `.opencode/command/research.md`  
**Lines**: 1-115  
**Relevance**: Reference pattern for task number parsing, state.json metadata extraction, and language-based routing

**Key Excerpts**:
- Lines 26-65: Stage 1 (ParseAndValidate) implementation
- Lines 29-32: Task number parsing from $ARGUMENTS
- Lines 40-44: state.json lookup using jq
- Lines 46-51: Metadata extraction pattern
- Lines 61-63: Language-based routing logic

### Source 2: /implement Command Implementation

**File**: `.opencode/command/implement.md`  
**Lines**: 1-122  
**Relevance**: Reference pattern for task validation, status checking, and custom prompt extraction

**Key Excerpts**:
- Lines 26-66: Stage 1 (ParseAndValidate) implementation
- Lines 29-32: Task number parsing with range support
- Lines 53-55: Task status validation
- Lines 57-59: Custom prompt extraction
- Lines 61-64: Language-based routing with meta type support

### Source 3: /plan Command Implementation

**File**: `.opencode/command/plan.md`  
**Lines**: 1-213  
**Relevance**: Reference pattern for planning workflow, plan artifact creation, and status updates

**Key Excerpts**:
- Lines 39-82: Stage 1 (ParseAndValidate) implementation
- Lines 59-65: Metadata extraction including plan_path
- Lines 67-68: Task status validation
- Lines 70-71: Plan existence check
- Lines 110-148: Planner responsibilities and quality standards

### Source 4: /meta Command Current Implementation

**File**: `.opencode/command/meta.md`  
**Lines**: 1-255  
**Relevance**: Current /meta command structure, workflow stages, and mode detection

**Key Excerpts**:
- Lines 24: Current usage pattern (no task number support)
- Lines 32-34: Two-mode support (Prompt/Interactive)
- Lines 72-132: 8-stage workflow description
- Lines 177-185: Interview patterns and progressive disclosure

### Source 5: meta Agent Implementation

**File**: `.opencode/agent/subagents/meta.md`  
**Lines**: 1-769  
**Relevance**: meta agent workflow, mode detection, and stage execution

**Key Excerpts**:
- Lines 89-107: Mode detection logic (prompt vs. interactive)
- Lines 146-192: Stage 1 (InitiateInterview) conditional execution
- Lines 194-260: Stage 2 (GatherDomainInformation) adaptive questioning
- Lines 471-564: Stage 7 (CreateTasksWithArtifacts) implementation
- Lines 566-648: Stage 8 (DeliverTaskSummary) return format

### Source 6: state.json Structure

**File**: `.opencode/specs/state.json`  
**Lines**: 1-100 (sample)  
**Relevance**: Task metadata structure and available fields

**Key Fields**:
- `project_number`: Task number (integer)
- `project_name`: Slug for directory naming
- `type`: Task type (feature, bugfix, meta, etc.)
- `status`: Current status
- `language`: Task language
- `description`: Task description
- `priority`: Priority level
- `artifacts`: Array of artifact paths

### Source 7: Routing Guide

**File**: `.opencode/context/core/system/routing-guide.md`  
**Lines**: 1-150  
**Relevance**: Language-based routing patterns and metadata extraction

**Key Excerpts**:
- Lines 42-92: Language extraction and routing logic
- Lines 64-69: Language → Agent routing table
- Lines 77-91: Routing validation patterns
- Lines 95-113: Implementation status and routing configuration

---

## Conclusion

This research provides a comprehensive analysis of how to revise the /meta command to accept an optional task number argument while maintaining backward compatibility. The proposed solution follows the established pattern from /research, /implement, and /plan commands, implementing three-mode detection (Task/Prompt/Interactive) and adapting the workflow accordingly.

**Key Takeaways**:

1. **Consistent Pattern**: Follow the 2-stage ParseAndValidate → Delegate pattern from other workflow commands
2. **Three-Mode Support**: Detect Task Mode (integer first token), Prompt Mode (non-integer arguments), or Interactive Mode (no arguments)
3. **State.json Metadata**: Use state.json as authoritative source for task metadata (8x faster than TODO.md)
4. **Workflow Adaptation**: Skip interview stages (2-6) when task context provided, jump to plan creation
5. **Backward Compatibility**: Fall back to Prompt Mode if task number not found, maintain existing usage patterns

**Implementation Effort**: 8-12 hours total
- Stage 1 implementation: 4-6 hours
- Documentation updates: 1-2 hours
- Agent updates: 2-3 hours
- Testing and validation: 1-2 hours

**Next Steps**:
1. Review research findings and recommendations
2. Create implementation plan for /meta command revision
3. Implement Stage 1 (ParseAndValidate) with three-mode detection
4. Adapt workflow stages for Task Mode
5. Update documentation and examples
6. Test all three modes thoroughly
7. Deploy and monitor for issues
