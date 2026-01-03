# Routing Logic Standard

## Overview

This standard defines how the orchestrator determines which agent to route commands to, including language-based routing for Lean-specific tasks.

## Language Extraction

For commands with `routing.language_based: true`, extract language from task metadata.

### Priority Order

1. **Priority 1**: Project state.json (task-specific)
2. **Priority 2**: TODO.md task entry (**Language** field)
3. **Priority 3**: Default "general" (fallback)

### Implementation

#### Priority 1: Project state.json

```bash
# Find task directory
task_dir=$(find .opencode/specs -maxdepth 1 -type d -name "${task_number}_*" | head -n 1)

# Extract language from state.json
if [ -n "$task_dir" ] && [ -f "${task_dir}/state.json" ]; then
  language=$(jq -r '.language // empty' "${task_dir}/state.json")
  
  if [ -n "$language" ]; then
    echo "[INFO] Language extracted from state.json: ${language}"
    # Use this language, skip to agent mapping
  fi
fi
```

#### Priority 2: TODO.md task entry

```bash
# Extract task entry (20 lines after task header)
task_entry=$(grep -A 20 "^### ${task_number}\." .opencode/specs/TODO.md)

# Extract Language field
language=$(echo "$task_entry" | grep "Language" | sed 's/\*\*Language\*\*: //' | tr -d ' ')

if [ -n "$language" ]; then
  echo "[INFO] Language extracted from TODO.md: ${language}"
  # Use this language, skip to agent mapping
fi
```

#### Priority 3: Default fallback

```bash
# If language still not found, default to "general"
language=${language:-general}

echo "[WARN] Language not found for task ${task_number}, defaulting to 'general'"
```

## Agent Mapping

Map extracted language to appropriate agent using routing table from command frontmatter.

### Routing Tables

Commands define routing in frontmatter:

```yaml
routing:
  language_based: true
  lean: lean-research-agent      # Agent for Lean tasks
  default: researcher             # Agent for all other tasks
```

### Mapping Logic

```bash
# Read routing table from command frontmatter
lean_agent=$(yq '.routing.lean' .opencode/command/${command}.md)
default_agent=$(yq '.routing.default' .opencode/command/${command}.md)

# Map language to agent
if [ "$language" == "lean" ]; then
  target_agent="$lean_agent"
  echo "[INFO] Routing to ${target_agent} (language=lean)"
else
  target_agent="$default_agent"
  echo "[INFO] Routing to ${target_agent} (language=${language})"
fi
```

### Common Routing Tables

| Command | Language | Agent |
|---------|----------|-------|
| /research | lean | lean-research-agent |
| /research | general | researcher |
| /implement | lean | lean-implementation-agent |
| /implement | general | implementer |
| /plan | any | planner (no language-based routing) |
| /review | any | reviewer (no language-based routing) |

## Routing Validation

Validate routing decision before delegation.

### Validation Steps

1. **Verify agent file exists**
   ```bash
   agent_file=".opencode/agent/subagents/${target_agent}.md"
   
   if [ ! -f "$agent_file" ]; then
     echo "[FAIL] Agent file not found: ${target_agent}"
     exit 1
   fi
   
   echo "[PASS] Agent file exists: ${agent_file}"
   ```

2. **Verify language matches agent capabilities**
   ```bash
   # Lean tasks must route to lean-* agents
   if [ "$language" == "lean" ] && [[ ! "$target_agent" =~ ^lean- ]]; then
     echo "[FAIL] Routing validation failed: language=lean but agent=${target_agent}"
     echo "Error: Lean task must route to lean-* agent"
     exit 1
   fi
   
   # Non-lean tasks must NOT route to lean-* agents
   if [ "$language" != "lean" ] && [[ "$target_agent" =~ ^lean- ]]; then
     echo "[FAIL] Routing validation failed: language=${language} but agent=${target_agent}"
     echo "Error: Non-lean task cannot route to lean-* agent"
     exit 1
   fi
   
   echo "[PASS] Routing validation succeeded"
   ```

3. **Update delegation path**
   ```bash
   delegation_path=["orchestrator", "${command}", "${target_agent}"]
   ```

## Direct Routing

For commands with `routing.language_based: false`, use direct routing.

### Implementation

```bash
# Read target_agent from command frontmatter
target_agent=$(yq '.routing.target_agent' .opencode/command/${command}.md)

# Verify agent file exists
agent_file=".opencode/agent/subagents/${target_agent}.md"

if [ ! -f "$agent_file" ]; then
  echo "[FAIL] Agent file not found: ${target_agent}"
  exit 1
fi

echo "[INFO] Routing to ${target_agent} (direct command)"
```

### Commands Using Direct Routing

| Command | Target Agent | Reason |
|---------|--------------|--------|
| /plan | planner | Planning is language-agnostic |
| /review | reviewer | Review is language-agnostic |
| /todo | (orchestrator) | No delegation |
| /task | (orchestrator) | No delegation |
| /errors | error-diagnostics-agent | Error analysis is language-agnostic |

## Error Handling

### Language Extraction Failed

**Symptom**: Cannot extract language from state.json or TODO.md

**Action**: Default to "general" and log warning

```bash
language=${language:-general}
echo "[WARN] Language not found for task ${task_number}, defaulting to 'general'"
```

**Impact**: Task routes to general agent instead of Lean-specific agent

**Resolution**: Add **Language** field to task entry in TODO.md

### Agent File Not Found

**Symptom**: Routing validation fails because agent file doesn't exist

**Action**: Abort with error

```bash
echo "[FAIL] Agent file not found: ${target_agent}"
echo "Error: Cannot route to ${target_agent} - agent file missing"
echo "Expected path: .opencode/agent/subagents/${target_agent}.md"
exit 1
```

**Resolution**: Create missing agent file or fix routing configuration

### Routing Mismatch

**Symptom**: Language doesn't match agent capabilities

**Action**: Abort with error

```bash
echo "[FAIL] Routing validation failed: language=${language} but agent=${target_agent}"
echo "Error: Lean task must route to lean-* agent"
exit 1
```

**Resolution**: Fix routing table in command frontmatter or correct task language

## Logging

All routing decisions are logged for debugging.

### Log Format

```
[INFO] Task {N} language: {language}
[INFO] Routing to {agent} (language={language})
[PASS] Routing validation succeeded
```

### Example Log

```
[INFO] Task 258 language: lean
[INFO] Routing to lean-research-agent (language=lean)
[PASS] Agent file exists: .opencode/agent/subagents/lean-research-agent.md
[PASS] Routing validation succeeded
```

## See Also

- Orchestrator: `.opencode/agent/orchestrator.md`
- Command Template: `.opencode/context/core/templates/command-template.md`
- Delegation Standard: `.opencode/context/core/standards/delegation.md`
- Command Argument Handling: `.opencode/context/core/standards/command-argument-handling.md`
