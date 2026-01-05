# Creating Commands Guide

## Overview

This guide provides a streamlined walkthrough for creating new commands in the ProofChecker .opencode system.

## Prerequisites

Before creating a new command, understand:

1. **Command Structure**: Simple frontmatter + usage documentation
2. **Routing**: Orchestrator routes to target agent specified in frontmatter
3. **Argument Handling**: Subagents parse their own arguments from original prompt
4. **Return Format**: Standard subagent return schema

**Required Reading**:
- `.opencode/agent/orchestrator.md` - Simple routing logic
- `.opencode/context/core/standards/delegation.md` - Subagent return format

## Step-by-Step Process

### Step 1: Determine Target Agent

**Question**: Which subagent will handle this command?

- `/research` → researcher (or lean-research-agent for Lean tasks)
- `/plan` → planner (or lean-planner for Lean tasks)
- `/implement` → implementer (or lean-implementation-agent for Lean tasks)
- `/revise` → planner
- `/review` → reviewer

**Routing Options**:
- **Simple**: One agent for all tasks
- **Language-based**: Different agents based on task language (lean vs general)

### Step 2: Create Command File

Create `.opencode/command/{command-name}.md` with this structure:

**Simple Command Template**:

```markdown
---
name: {command-name}
agent: {target-agent}
description: "{Brief description}"
timeout: 3600
---

# /{command-name} - {Title}

{Brief description of what this command does}

## Usage

\`\`\`bash
/{command-name} TASK_NUMBER [PROMPT]
/{command-name} 196
/{command-name} 196 "Custom focus"
\`\`\`

## What This Does

1. Routes to {agent} subagent
2. Agent executes workflow
3. Creates artifacts
4. Updates task status
5. Creates git commit

See `.opencode/agent/subagents/{agent}.md` for details.
```

**Language-Based Routing Template**:

```markdown
---
name: {command-name}
agent: {default-agent}
description: "{Brief description}"
timeout: 3600
routing:
  language_based: true
  lean: {lean-agent}
  default: {default-agent}
---

# /{command-name} - {Title}

{Brief description}

## Usage

\`\`\`bash
/{command-name} TASK_NUMBER [PROMPT]
\`\`\`

## What This Does

1. Routes to appropriate agent based on task language
2. Agent executes workflow
3. Creates artifacts
4. Updates task status
5. Creates git commit

## Language-Based Routing

| Language | Agent | Tools |
|----------|-------|-------|
| lean | {lean-agent} | {lean-specific tools} |
| general | {default-agent} | {general tools} |

See `.opencode/agent/subagents/{agent}.md` for details.
```

### Step 3: Create or Update Subagent

If creating a new subagent, it must:

1. **Parse arguments from original prompt** (Step 0)
   - Extract task number from prompt string
   - Example: "/command 271" → task_number = 271
   
2. **Validate task exists** (Step 0)
   - Check task exists in TODO.md
   - Return error if not found
   
3. **Update status** (Step 0)
   - Delegate to status-sync-manager
   - Set appropriate starting status
   
4. **Execute workflow** (Steps 1-N)
   - Perform actual work
   - Create artifacts
   
5. **Return standardized result** (Final step)
   - Use subagent-return-format.md schema
   - Include artifacts, summary, status

**Step 0 Template**:

```xml
<step_0_preflight>
  <action>Preflight: Parse arguments, validate task, update status</action>
  <process>
    1. Parse task number from prompt:
       - Prompt format: "/{command} 271" or "271" or "/{command} 271 extra"
       - Extract first integer from prompt string
       - If no integer found: Return error "Task number required"
    
    2. Validate task exists:
       - Read .opencode/specs/TODO.md
       - Find task entry: grep "^### ${task_number}\."
       - If not found: Return error "Task {task_number} not found"
    
    3. Update status to [{STATUS}]:
       - Delegate to status-sync-manager
       - Validate status update succeeded
    
    4. Proceed to execution
  </process>
  <checkpoint>Task validated and status updated</checkpoint>
</step_0_preflight>
```

### Step 4: Test Command

Test your new command:

```bash
# Create test task in TODO.md if needed
/todo add "Test task for new command"

# Test command
/{command-name} {task-number}

# Verify:
# 1. Command routes to correct agent
# 2. Agent receives original prompt
# 3. Agent parses arguments correctly
# 4. Artifacts created
# 5. Status updated
# 6. Git commit created
```

## Key Principles

1. **Simple Routing**: Orchestrator just routes, doesn't parse
2. **Subagent Ownership**: Subagents parse their own arguments
3. **Original Prompts**: Always pass user's original prompt unchanged
4. **Trust Model**: Trust subagents to handle their workflows
5. **Minimal Documentation**: Command files should be <50 lines

## Examples

See existing command files:
- `.opencode/command/research.md` - Language-based routing example
- `.opencode/command/plan.md` - Simple routing example
- `.opencode/command/implement.md` - Language-based with resume support

See existing subagents:
- `.opencode/agent/subagents/researcher.md` - General research workflow
- `.opencode/agent/subagents/planner.md` - Planning workflow
- `.opencode/agent/subagents/implementer.md` - Implementation workflow

## Troubleshooting

**Command not found**:
- Check file exists: `.opencode/command/{name}.md`
- Check frontmatter has `name` field

**Arguments not parsed**:
- Check subagent Step 0 extracts task number from prompt
- Verify orchestrator passes original prompt unchanged

**Wrong agent invoked**:
- Check frontmatter `agent` field
- Check `routing` configuration if language-based

**Status not updated**:
- Check subagent delegates to status-sync-manager
- Verify status-sync-manager return validated

## Migration from Old System

If migrating from the old system (v5.0 orchestrator):

**Old Pattern** (Orchestrator parsed arguments):
```
User: /research 271
Orchestrator: Parse 271, format as "Task: 271"
Subagent: Receive "Task: 271", re-parse to get 271
```

**New Pattern** (Subagent parses arguments):
```
User: /research 271
Orchestrator: Pass "/research 271" unchanged
Subagent: Receive "/research 271", parse to get 271
```

**Changes Required**:
1. Orchestrator: Remove argument parsing (already done in v6.0)
2. Command files: Remove workflow stages, simplify to routing metadata
3. Subagents: Simplify Step 0 to parse from original prompt

---

**Last Updated**: 2026-01-04 (v6.0 - Simplified architecture)
