---
name: test-lean-research
description: Research Lean 4 and Mathlib for theorem proving tasks (context:fork test). Invoke for testing context isolation with full Lean MCP tooling.
context: fork
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, mcp__lean-lsp__lean_leansearch, mcp__lean-lsp__lean_loogle, mcp__lean-lsp__lean_leanfinder, mcp__lean-lsp__lean_local_search, mcp__lean-lsp__lean_hover_info, mcp__lean-lsp__lean_state_search, mcp__lean-lsp__lean_hammer_premise, mcp__lean-lsp__lean_goal, mcp__lean-lsp__lean_file_outline, mcp__lean-lsp__lean_diagnostic_messages, mcp__lean-lsp__lean_completions, mcp__lean-lsp__lean_declaration_file, mcp__lean-lsp__lean_run_code
user-invocable: true
---

# Test Lean Research Skill (context:fork)

This is a TEST version of skill-lean-research that uses `context: fork` instead of direct execution.
It enables A/B testing of context isolation with full Lean MCP tooling.

**Purpose**: Test whether `context: fork` properly isolates the conversation context while still
providing access to Lean MCP tools. This is a controlled experiment before potentially migrating
production skills to use context:fork.

**Production Skill**: skill-lean-research (uses direct execution)

## Test Verification

When invoked, this skill will:

1. **Report Context State** - What context is visible to this skill
2. **Test MCP Tool Access** - Verify Lean MCP tools are accessible
3. **Perform Research** - Execute actual Lean research to test full workflow
4. **Return Results** - Report findings back to main conversation

## Context Isolation Test

If `context: fork` is WORKING:
- This skill should NOT see messages from before `/test-lean-research` was invoked
- This skill should ONLY have access to the tools listed in `allowed-tools`
- The main conversation should not be polluted with skill internals
- Lean MCP tools should still be accessible

If `context: fork` is NOT WORKING:
- The skill will run inline in the main conversation
- Previous context will be visible
- All tools from the main session will be available

---

## Execution Flow

### Stage 1: Context Verification

Report on context isolation status:
- Am I running in an isolated context?
- What tools do I have access to?
- Can I see parent conversation history?

### Stage 2: Input Validation

Validate required inputs:
- `task_number` - Must be provided and exist in state.json
- `focus_prompt` - Optional focus for research direction

```bash
# Lookup task
task_data=$(jq -r --argjson num "$task_number" \
  '.active_projects[] | select(.project_number == $num)' \
  specs/state.json)

# Validate exists
if [ -z "$task_data" ]; then
  return error "Task $task_number not found"
fi

# Extract fields
language=$(echo "$task_data" | jq -r '.language // "general"')
status=$(echo "$task_data" | jq -r '.status')
project_name=$(echo "$task_data" | jq -r '.project_name')
description=$(echo "$task_data" | jq -r '.description // ""')
```

---

### Stage 3: MCP Tool Access Test

Verify Lean MCP tools are accessible from this forked context:

```
Test 1: lean_local_search - Try a simple search
Test 2: lean_leansearch (if Test 1 passes) - Try natural language search
Test 3: lean_hover_info (if above pass) - Try getting type info
```

If tools fail, document the failure and return partial results.

---

### Stage 4: Execute Research

Follow the same research flow as skill-lean-research:

1. **Analyze Task** - Understand what needs to be researched
2. **Primary Searches** - Execute appropriate searches based on task
3. **Synthesize Findings** - Compile discovered information

### Search Decision Tree
1. "Does X exist locally?" -> lean_local_search (no rate limit)
2. "I need a lemma that says X" -> lean_leansearch (3 req/30s)
3. "Find lemma with type pattern" -> lean_loogle (3 req/30s)
4. "What's the Lean name for concept X?" -> lean_leanfinder (10 req/30s)
5. "What closes this goal?" -> lean_state_search (3 req/30s)

---

### Stage 5: Create Research Report

Create directory and write report.

**Path**: `specs/{N}_{SLUG}/reports/research-{NNN}.md`

Ensure directory exists:
```bash
mkdir -p "specs/${task_number}_${project_name}/reports"
```

**Note**: Append "(via context:fork test)" to report header to distinguish from production.

---

### Stage 6: Return Results

Return a brief text summary with context:fork test observations:

```
test-lean-research completed for task {N} (context:fork test):

Context Isolation Status:
- Forked context: Yes/No (based on observations)
- Parent conversation visible: Yes/No
- Tool access: Limited to allowed-tools / Full session tools

Research Results:
- Found {count} relevant Mathlib theorems
- Identified proof strategy: {strategy}
- Created report at specs/{N}_{SLUG}/reports/research-{NNN}.md

Note: This was executed via context:fork test skill.
```

---

## Error Handling

### MCP Tool Failures
If MCP tools are not accessible from forked context:
1. Log the failure (which tools failed)
2. Return partial status with diagnostic information
3. Recommend whether context:fork is viable for Lean skills

### Context Isolation Failure
If context is not isolated:
1. Note that context:fork is not working
2. Continue with research anyway (graceful degradation)
3. Report findings in return summary

---

## Test Comparison

After running this skill, compare with:
1. **test-context-fork** - Basic isolation test (simpler, no MCP)
2. **skill-lean-research** - Production direct execution

Expected outcomes:
- test-context-fork: Isolated, basic tools work
- test-lean-research (this): Isolated, MCP tools work (if context:fork supports MCP)
- skill-lean-research: Not isolated (direct execution), MCP tools work

If this test shows MCP tools work with context:fork, it validates migrating Lean skills
from direct execution to context:fork for better context isolation.
