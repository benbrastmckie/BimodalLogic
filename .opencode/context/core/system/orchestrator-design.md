# Orchestrator Design

**Version**: 5.0  
**Created**: 2025-12-29  
**Purpose**: Document the smart coordinator pattern and orchestrator architecture

---

## Design Philosophy

The orchestrator is a **smart coordinator**, not a workflow executor. It handles:
- **Preflight**: Validation and safety checks
- **Routing**: Language extraction and agent selection
- **Delegation**: Context preparation and agent invocation
- **Postflight**: Return validation and cleanup

It does NOT handle:
- Workflow execution (delegated to agents)
- Status updates (delegated to status-sync-manager)
- Git commits (delegated to git-workflow-manager)
- Business logic (delegated to domain agents)

---

## Seven-Stage Workflow

### Stage 1: ParseCommand
**Purpose**: Extract command name and arguments from user input

**Actions**:
- Parse command name (e.g., "plan", "research", "implement")
- Extract arguments (task number, flags, prompts)
- Validate argument format

**Output**: Parsed command and arguments

---

### Stage 2: PreflightValidation
**Purpose**: Validate request before delegation

**Checks**:
- Task number is valid integer
- Task exists in TODO.md
- Delegation depth < 3
- No cycles in delegation path
- Session ID is unique

**Output**: Validation result (pass/fail)

**On Failure**: Return error immediately, don't delegate

---

### Stage 3: DetermineRouting
**Purpose**: Determine target agent based on command configuration

**For Language-Based Routing** (routing.language_based: true):
1. Extract language from:
   - Priority 1: Project state.json (task-specific)
   - Priority 2: TODO.md task entry (task default)
   - Priority 3: Default "general" (fallback)

2. Map language to agent:
   - /research: lean → lean-research-agent, default → researcher
   - /implement: lean → lean-implementation-agent, default → implementer

**For Direct Routing** (routing.language_based: false):
- Use routing.target_agent from command frontmatter
- Examples: /plan → planner, /revise → reviser

**Output**: Target agent name

---

### Stage 4: PrepareContext
**Purpose**: Prepare delegation context for agent

**Actions**:
- Generate unique session ID (sess_{timestamp}_{random_6char})
- Build delegation context:
  ```json
  {
    "session_id": "sess_1735460684_a1b2c3",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "{command}", "{agent}"],
    "timeout": 3600,
    "task_context": {
      "task_number": 244,
      "description": "...",
      "language": "lean"
    }
  }
  ```
- Register session in delegation registry
- Set timeout deadline

**Output**: Delegation context

---

### Stage 5: InvokeAgent
**Purpose**: Delegate to target agent

**Actions**:
- Load agent file (.opencode/agent/subagents/{agent}.md)
- Invoke agent with delegation context
- Wait for agent return (with timeout)

**Output**: Agent return object

**On Timeout**: Return partial status with timeout error

---

### Stage 6: ValidateReturn
**Purpose**: Validate agent return format

**Checks**:
- Return is valid JSON
- Required fields present (status, summary, artifacts, metadata, session_id)
- Status is valid enum (completed|partial|failed|blocked)
- session_id matches expected
- Summary <100 tokens
- Artifacts exist on disk (if status=completed)

**Output**: Validation result

**On Failure**: Log error, return failed status

---

### Stage 7: PostflightCleanup
**Purpose**: Cleanup and format final return

**Actions**:
- Remove session from delegation registry
- Format return for user
- Log completion to session log

**Output**: Final return to user

---

## Context Budget

The orchestrator maintains a minimal context budget:

**Budget**: <5% of context window (~10KB)

**Always Loaded**:
- core/system/routing-guide.md (~9KB)
- core/workflows/delegation-guide.md (~2KB)

**Total**: ~11KB (within budget)

This enables the orchestrator to:
- Make routing decisions
- Enforce delegation safety
- Validate returns

Without loading:
- Domain-specific knowledge (loaded by agents)
- Workflow details (owned by agents)
- Business logic (owned by agents)

---

## Language Extraction Logic

### Priority 1: Project state.json
**Path**: `.opencode/specs/{task_number}_{slug}/state.json`

**Field**: `language`

**Example**:
```json
{
  "task_number": 244,
  "language": "lean",
  ...
}
```

**When to use**: Task has project directory with state.json

---

### Priority 2: TODO.md
**Path**: `.opencode/specs/TODO.md`

**Field**: `**Language**:` in task entry

**Example**:
```markdown
### 244. Implement feature X
- **Language**: lean
```

**When to use**: Task exists in TODO.md (always)

---

### Priority 3: Default
**Value**: "general"

**When to use**: Language not found in state.json or TODO.md (rare)

---

## Routing Configuration

Commands specify routing in frontmatter:

### Direct Routing
```yaml
routing:
  language_based: false
  target_agent: planner
```

**Used by**: /plan, /revise, /review, /todo, /task

---

### Language-Based Routing
```yaml
routing:
  language_based: true
  lean: lean-research-agent
  default: researcher
```

**Used by**: /research, /implement

---

## Delegation Safety

### Cycle Detection
Before delegating, check if target agent is in delegation_path:

```
delegation_path: ["orchestrator", "implement", "task-executor"]
target: "task-executor"
Result: ❌ CYCLE DETECTED - Block delegation
```

### Depth Limits
Maximum delegation depth: 3 levels

```
Level 0: User → Orchestrator
Level 1: Orchestrator → Command → Agent
Level 2: Agent → Utility (status-sync-manager, git-workflow-manager)
Level 3: Utility → Sub-Utility (rare)
```

### Timeout Enforcement
All delegations have timeouts:

| Command | Default Timeout | Max Timeout |
|---------|----------------|-------------|
| /research | 3600s (1 hour) | 7200s (2 hours) |
| /plan | 1800s (30 min) | 3600s (1 hour) |
| /implement | 7200s (2 hours) | 14400s (4 hours) |

---

## Validation Strategy

### What Orchestrator Validates
✅ Task exists in TODO.md  
✅ Task number format  
✅ Delegation safety (cycles, depth)  
✅ Return format (JSON schema)  
✅ Session ID match  

### What Orchestrator Does NOT Validate
❌ Plan exists (agent concern)  
❌ Research complete (agent concern)  
❌ File permissions (agent concern)  
❌ Domain rules (agent concern)  
❌ Artifact format (agent concern)  

See `core/system/validation-strategy.md` for detailed philosophy.

---

## Error Handling

### Validation Errors
**When**: Preflight validation fails  
**Action**: Return error immediately, don't delegate  
**Example**: "Task 999 not found in TODO.md"

### Agent Errors
**When**: Agent returns failed status  
**Action**: Return agent error to user  
**Example**: "Plan already exists at path/to/plan.md"

### Timeout Errors
**When**: Agent doesn't return within timeout  
**Action**: Return partial status with timeout error  
**Example**: "Implementation timed out after 7200s"

---

## Session Tracking

### Session ID Format
```
sess_{timestamp}_{random_6char}
Example: sess_1735460684_a1b2c3
```

### Delegation Registry
In-memory registry of active sessions:

```json
{
  "sess_1735460684_a1b2c3": {
    "command": "implement",
    "subagent": "task-executor",
    "task_number": 191,
    "start_time": "2025-12-26T10:00:00Z",
    "timeout": 7200,
    "deadline": "2025-12-26T12:00:00Z",
    "status": "running",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "implement", "task-executor"]
  }
}
```

Updated in Stage 4 (PrepareContext) and Stage 7 (PostflightCleanup).

---

## Design Principles

### 1. Minimal Context
Orchestrator loads <5% context window to stay lightweight

### 2. Smart Coordination
Handles preflight/postflight, delegates workflow execution

### 3. Language Awareness
Extracts language and routes to appropriate agents

### 4. Safety First
Enforces delegation safety (cycles, depth, timeouts)

### 5. Validation Boundaries
Validates structure, not business logic

### 6. Agent Ownership
Agents own workflows, orchestrator just coordinates

---

## Related Documentation

- `.opencode/context/core/system/routing-guide.md` - Routing rules and language mapping
- `.opencode/context/core/workflows/delegation-guide.md` - Delegation safety patterns
- `.opencode/context/core/system/validation-strategy.md` - Validation philosophy
- `.opencode/context/core/standards/subagent-return-format.md` - Return format standard
- `.opencode/agent/orchestrator.md` - Orchestrator implementation
