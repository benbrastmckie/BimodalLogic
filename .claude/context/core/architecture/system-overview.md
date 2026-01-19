# System Architecture Overview

**Version**: 1.0
**Created**: 2026-01-19
**Purpose**: Consolidated architecture reference for agents generating new components
**Audience**: /meta agent, system developers, architecture reviewers

---

## Three-Layer Architecture

The ProofChecker agent system implements a three-layer delegation pattern separating concerns into distinct execution layers.

```
                         USER INPUT
                              |
                              v
                    +-----------------+
     Layer 1:       |    Commands     |  User-facing entry points
     (Commands)     |  (/research,    |  Parse $ARGUMENTS
                    |   /plan, etc.)  |  Route to skills
                    +-----------------+
                              |
                              v
                    +-----------------+
     Layer 2:       |     Skills      |  Thin wrappers with validation
     (Skills)       | (skill-lean-    |  Prepare delegation context
                    |  research, etc.)|  Invoke agents via Task tool
                    +-----------------+
                              |
                              v
                    +-----------------+
     Layer 3:       |     Agents      |  Full execution components
     (Agents)       | (lean-research- |  Load context on-demand
                    |  agent, etc.)   |  Create artifacts
                    +-----------------+
                              |
                              v
                        ARTIFACTS
               (reports, plans, summaries)
```

---

## Component Responsibilities Matrix

| Aspect | Command | Skill | Agent |
|--------|---------|-------|-------|
| **Location** | `.claude/commands/` | `.claude/skills/skill-*/SKILL.md` | `.claude/agents/*.md` |
| **User-facing** | Yes | No | No |
| **Invocation** | `/command` syntax | Via Command routing | Via Task tool from Skill |
| **Context loading** | None | Minimal | Full (lazy loading) |
| **Input validation** | Basic parsing | Delegation validation | Execution validation |
| **Execution** | Route only | Validate + delegate | Full workflow |
| **Artifact creation** | No | No | Yes |
| **Return format** | N/A | Pass-through | Standardized JSON |

---

## Layer Details

### Layer 1: Commands

**Purpose**: User-facing entry points that parse arguments and route to skills.

**Key characteristics**:
- Parse `$ARGUMENTS` from user input
- Determine target skill based on routing rules
- Pass arguments to skill via orchestrator
- Minimal logic (routing only)

**Structure requirements**:
- YAML frontmatter with routing table
- Command name, description, usage examples
- No execution logic embedded

**Example routing**:
```yaml
---
routing:
  lean: skill-lean-research
  general: skill-researcher
  default: skill-researcher
---
```

**Reference**: @.claude/docs/guides/creating-commands.md

---

### Layer 2: Skills

**Purpose**: Thin wrappers that validate inputs and delegate to agents.

**Key characteristics**:
- Use `context: fork` to avoid loading heavy context
- Validate inputs before delegation
- Prepare delegation context (session_id, depth, path)
- Invoke agent via **Task tool** (not Skill tool)
- Validate agent return matches schema
- Pass-through return to caller

**Thin Wrapper Pattern**:
```yaml
---
name: skill-{name}
description: {description}
allowed-tools: Task
context: fork
agent: {agent-name}
---
```

**Critical**: Skills delegate via Task tool, not Skill tool. Agents live in `.claude/agents/`, not `.claude/skills/`.

**Reference**: @.claude/context/core/templates/thin-wrapper-skill.md

---

### Layer 3: Agents

**Purpose**: Full execution components that do the actual work.

**Key characteristics**:
- Load context on-demand via @-references
- Execute multi-step workflows
- Create artifacts in proper locations
- Return standardized JSON format
- Handle errors with recovery information

**Execution pattern**:
1. Parse delegation context
2. Load required context files
3. Execute workflow steps
4. Create artifacts
5. Return JSON result

**Return format**:
```json
{
  "status": "researched|planned|implemented|partial|failed|blocked",
  "summary": "Brief 2-5 sentence summary (<100 tokens)",
  "artifacts": [{...}],
  "metadata": {
    "session_id": "sess_{timestamp}_{random}",
    "agent_type": "{name}",
    "delegation_depth": N,
    "delegation_path": [...]
  },
  "errors": [...],
  "next_steps": "..."
}
```

**Critical**: Never use "completed" as status value - triggers Claude stop behavior.

**Reference**: @.claude/context/core/formats/subagent-return.md

---

## Delegation Flow

### Standard Execution Flow

```
User: "/research 259"
         |
         v
+-------------------+
| 1. Command parses |  Extract task_number=259
|    $ARGUMENTS     |  Determine language=lean
+-------------------+
         |
         v
+-------------------+
| 2. Route to skill |  language=lean -> skill-lean-research
|    by language    |
+-------------------+
         |
         v
+-------------------+
| 3. Skill prepares |  session_id: sess_1736700000_abc123
|    delegation     |  delegation_depth: 1
|    context        |  delegation_path: [orchestrator, research, ...]
+-------------------+
         |
         v
+-------------------+
| 4. Skill invokes  |  Task tool with subagent_type: lean-research-agent
|    agent via Task |  Pass: task_context, delegation_context
+-------------------+
         |
         v
+-------------------+
| 5. Agent loads    |  @.claude/context/project/lean4/...
|    context        |  @specs/state.json
|    on-demand      |  Task details from TODO.md
+-------------------+
         |
         v
+-------------------+
| 6. Agent executes |  Use MCP tools (lean_leansearch, etc.)
|    workflow       |  Gather findings
+-------------------+
         |
         v
+-------------------+
| 7. Agent creates  |  specs/259_{slug}/reports/research-001.md
|    artifacts      |
+-------------------+
         |
         v
+-------------------+
| 8. Agent returns  |  {"status": "researched", "artifacts": [...]}
|    JSON           |
+-------------------+
         |
         v
+-------------------+
| 9. Skill validates|  Check return schema
|    return         |  Verify session_id matches
+-------------------+
         |
         v
+-------------------+
| 10. Postflight    |  Update TODO.md: [RESEARCHED]
|     (checkpoint)  |  Update state.json
|                   |  Git commit
+-------------------+
```

---

## Checkpoint-Based Execution

All workflow commands follow a three-checkpoint pattern:

```
┌──────────────────────────────────────────────────────────────┐
│  CHECKPOINT 1    -->    STAGE 2    -->    CHECKPOINT 2    -->│
│   GATE IN               DELEGATE          GATE OUT           │
│  (Preflight)          (Skill/Agent)     (Postflight)         │
│                                                    |         │
│                                             CHECKPOINT 3     │
│                                               COMMIT         │
└──────────────────────────────────────────────────────────────┘
```

### Checkpoint Details

| Checkpoint | Purpose | Key Operations |
|------------|---------|----------------|
| GATE IN | Preflight validation | Generate session_id, validate task exists, update status to "in_progress" variant |
| DELEGATE | Execute work | Route to skill, skill invokes agent, agent creates artifacts |
| GATE OUT | Postflight validation | Validate return, link artifacts, update status to success variant |
| COMMIT | Finalize | Git commit with session_id, return result to user |

**Reference**: @.claude/context/core/checkpoints/

---

## Session Tracking

Every delegation has a unique session ID for traceability:

**Format**: `sess_{unix_timestamp}_{6_char_random}`
**Example**: `sess_1736700000_abc123`

**Generation**:
```bash
session_id="sess_$(date +%s)_$(od -An -N3 -tx1 /dev/urandom | tr -d ' ')"
```

**Usage**:
- Generated at GATE IN checkpoint
- Passed through delegation context to agent
- Returned in agent metadata
- Included in git commit message
- Logged in errors.json for traceability

---

## Language-Based Routing

Tasks route to specialized skills/agents based on their `language` field:

| Language | Research | Planning | Implementation |
|----------|----------|----------|----------------|
| `lean` | skill-lean-research -> lean-research-agent | skill-planner -> planner-agent | skill-lean-implementation -> lean-implementation-agent |
| `general` | skill-researcher -> general-research-agent | skill-planner -> planner-agent | skill-implementer -> general-implementation-agent |
| `meta` | skill-researcher -> general-research-agent | skill-planner -> planner-agent | skill-implementer -> general-implementation-agent |
| `latex` | skill-researcher -> general-research-agent | skill-planner -> planner-agent | skill-latex-implementation -> latex-implementation-agent |

---

## Error Handling

Errors propagate upward through the layers with structured information:

```
Agent Error
    |
    v
Agent returns: {"status": "failed", "errors": [{...}]}
    |
    v
Skill validates return, passes through error
    |
    v
Orchestrator receives error, handles based on severity:
  - Critical: Log to errors.json, return to user
  - Recoverable: Suggest retry/resume
  - Partial: Save progress, enable resume
```

**Error object schema**:
```json
{
  "type": "timeout|validation|execution|tool_unavailable",
  "message": "Human-readable description",
  "code": "ERROR_CODE",
  "recoverable": true,
  "recommendation": "What to do next"
}
```

---

## Delegation Depth Limits

Prevent infinite delegation loops with depth tracking:

| Depth | Layer | Example |
|-------|-------|---------|
| 0 | Orchestrator | User -> Orchestrator |
| 1 | Command/Skill | Orchestrator -> Command -> Skill |
| 2 | Agent | Skill -> Agent |
| 3 | Sub-agent (rare) | Agent -> Utility Agent |

**Maximum depth**: 3 levels (hard limit)

**Enforcement**: Check `delegation_depth < 3` before delegating.

---

## Related Documentation

### Detailed Patterns
- @.claude/context/core/orchestration/delegation.md - Full delegation standard
- @.claude/context/core/orchestration/architecture.md - Three-layer detailed explanation

### Templates
- @.claude/context/core/templates/thin-wrapper-skill.md - Skill template
- @.claude/context/core/templates/subagent-template.md - Agent template
- @.claude/context/core/templates/command-template.md - Command template

### Return Formats
- @.claude/context/core/formats/subagent-return.md - Agent return schema
- @.claude/context/core/formats/return-metadata-file.md - File-based return pattern

### Anti-Patterns
- @.claude/context/core/patterns/anti-stop-patterns.md - Patterns that cause workflow early stop
