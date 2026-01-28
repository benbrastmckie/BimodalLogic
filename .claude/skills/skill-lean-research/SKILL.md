---
name: skill-lean-research
description: Research Lean 4 and Mathlib for theorem proving tasks. Invoke for Lean-language research using LeanSearch, Loogle, and lean-lsp tools.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, mcp__lean-lsp__lean_leansearch, mcp__lean-lsp__lean_loogle, mcp__lean-lsp__lean_leanfinder, mcp__lean-lsp__lean_local_search, mcp__lean-lsp__lean_hover_info, mcp__lean-lsp__lean_state_search, mcp__lean-lsp__lean_hammer_premise, mcp__lean-lsp__lean_goal, mcp__lean-lsp__lean_file_outline, mcp__lean-lsp__lean_diagnostic_messages, mcp__lean-lsp__lean_completions, mcp__lean-lsp__lean_declaration_file, mcp__lean-lsp__lean_run_code
---

# Lean Research Skill

Direct execution skill for Lean 4 research. Executes MCP tools directly instead of delegating to a subagent.

**Note**: This skill was refactored from thin wrapper delegation pattern to direct execution to fix
MCP tool hanging issues in subagents (Claude Code bugs #15945, #13254, #4580).

## Context References

Load on-demand using @-references:

**Always Load**:
- `@.claude/context/project/lean4/tools/mcp-tools-guide.md` - Full MCP tool reference

**Load When Creating Report**:
- `@.claude/context/core/formats/report-format.md` - Research report structure

**Load for Pattern Reference**:
- `@.claude/context/core/patterns/jq-escaping-workarounds.md` - jq escaping patterns (Issue #1132)

## Trigger Conditions

This skill activates when:
- Task language is "lean"
- Research involves Mathlib, theorems, or proofs
- Lean-specific MCP tools are needed

---

## Execution Flow

### Stage 1: Input Validation

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

### Stage 2: Preflight Status Update

Update task status to "researching" BEFORE starting research.

**Update state.json**:
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "researching" \
   --arg sid "$session_id" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: $status,
    last_updated: $ts,
    session_id: $sid
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

**Update TODO.md**: Use Edit tool to change status marker from `[NOT STARTED]` or `[RESEARCHED]` to `[RESEARCHING]`.

---

### Stage 3: Create Postflight Marker

Create the marker file to prevent premature termination:

```bash
cat > specs/.postflight-pending << EOF
{
  "session_id": "${session_id}",
  "skill": "skill-lean-research",
  "task_number": ${task_number},
  "operation": "research",
  "reason": "Postflight pending: status update, artifact linking, git commit",
  "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "stop_hook_active": false
}
EOF
```

---

### Stage 4: Analyze Task and Determine Search Strategy

Based on task description and focus:

1. **Theorem Discovery**: Need natural language -> use leansearch
2. **Type Matching**: Have specific type signature -> use loogle
3. **Conceptual Search**: Looking for mathematical concept -> use leanfinder
4. **Goal-Directed**: Have specific proof goal -> use state_search
5. **Local Verification**: Check what exists in project -> use local_search

---

### Stage 5: Execute Primary Searches

Execute searches based on strategy. Use the Search Decision Tree:

1. "Does X exist locally?" -> lean_local_search (no rate limit, always try first)
2. "I need a lemma that says X" (natural language) -> lean_leansearch (3 req/30s)
3. "Find lemma with type pattern like A -> B -> C" -> lean_loogle (3 req/30s)
4. "What's the Lean name for mathematical concept X?" -> lean_leanfinder (10 req/30s)
5. "What lemma closes this specific goal?" -> lean_state_search (3 req/30s)
6. "What premises should I feed to simp/aesop?" -> lean_hammer_premise (3 req/30s)

**After Finding a Candidate Name**:
1. `lean_local_search` to verify it exists in project/mathlib
2. `lean_hover_info` to get full type signature and docs

### Rate Limit Management

- Track request counts per tool
- Space out rate-limited calls
- Prefer lean_leanfinder (10/30s) over leansearch/loogle (3/30s) when both work
- Use lean_local_search freely (no limit)

### Rate Limits Reference

| Tool | Limit |
|------|-------|
| `lean_local_search` | No limit |
| `lean_leanfinder` | 10 req/30s |
| `lean_leansearch` | 3 req/30s |
| `lean_loogle` | 3 req/30s |
| `lean_state_search` | 3 req/30s |
| `lean_hammer_premise` | 3 req/30s |

### Search Fallback Chain

When primary search fails, try this chain:

```
Primary: leansearch (natural language)
    | no results
    v
Fallback 1: loogle (type pattern extracted from description)
    | no results
    v
Fallback 2: leanfinder (semantic/conceptual)
    | no results
    v
Fallback 3: local_search with broader terms
    | no results
    v
Return partial status with recommendations
```

### MCP Tool Error Recovery

When MCP tool calls fail (AbortError -32001 or similar):

1. **Log the error context** (tool name, operation, task number, session_id)
2. **Retry once** after 5-second delay for timeout errors
3. **Try alternative search tool** per this fallback table:

| Primary Tool | Alternative 1 | Alternative 2 |
|--------------|---------------|---------------|
| `lean_leansearch` | `lean_loogle` | `lean_leanfinder` |
| `lean_loogle` | `lean_leansearch` | `lean_leanfinder` |
| `lean_leanfinder` | `lean_leansearch` | `lean_loogle` |
| `lean_local_search` | (no alternative) | Continue with partial |

4. **If all fail**: Continue with codebase-only findings
5. **Document in report** what searches failed and recommendations

---

### Stage 6: Synthesize Findings

Compile discovered information:
- Relevant theorems/lemmas with type signatures
- Documentation excerpts
- Usage patterns from existing code
- Potential proof strategies

---

### Stage 7: Create Research Report

Create directory and write report.

**Path**: `specs/{N}_{SLUG}/reports/research-{NNN}.md`

Ensure directory exists:
```bash
mkdir -p "specs/${task_number}_${project_name}/reports"
```

**Structure**:
```markdown
# Research Report: Task #{N}

**Task**: {id} - {title}
**Started**: {ISO8601}
**Completed**: {ISO8601}
**Effort**: {estimate}
**Priority**: {priority}
**Dependencies**: {list or None}
**Sources/Inputs**: - Mathlib, lean_leansearch, lean_loogle, etc.
**Artifacts**: - path to this report
**Standards**: report-format.md

## Executive Summary
- Key finding 1
- Key finding 2
- Recommended approach

## Context & Scope
{What was researched, constraints}

## Findings
### Relevant Theorems
- `Theorem.name` : {type signature}
  - {description, usage}

### Proof Strategies
- {Recommended approaches}

### Dependencies
- {Required imports, lemmas}

## Decisions
- {Explicit decisions made during research}

## Recommendations
1. {Prioritized recommendations}

## Risks & Mitigations
- {Potential issues and solutions}

## Appendix
- Search queries used
- References to Mathlib documentation
```

---

### Stage 8: Update Task Status (Postflight)

If research is complete, update state.json and TODO.md:

**Update state.json**:
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "researched" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: $status,
    last_updated: $ts,
    researched: $ts
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

**Update TODO.md**: Use Edit tool to change status marker from `[RESEARCHING]` to `[RESEARCHED]`.

**On partial/failed**: Keep status as "researching" for resume.

---

### Stage 9: Link Artifacts

Add artifact to state.json with summary.

**IMPORTANT**: Use two-step jq pattern to avoid Issue #1132 escaping bug. See `jq-escaping-workarounds.md`.

```bash
artifact_path="specs/${task_number}_${project_name}/reports/research-001.md"
artifact_type="research"
artifact_summary="Research report with theorem findings and proof strategy"

if [ -n "$artifact_path" ]; then
    # Step 1: Filter out existing research artifacts (two-step pattern for Issue #1132)
    jq '(.active_projects[] | select(.project_number == '$task_number')).artifacts =
        [(.active_projects[] | select(.project_number == '$task_number')).artifacts // [] | .[] | select(.type != "research")]' \
      specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json

    # Step 2: Add new research artifact
    jq --arg path "$artifact_path" \
       --arg type "$artifact_type" \
       --arg summary "$artifact_summary" \
      '(.active_projects[] | select(.project_number == '$task_number')).artifacts += [{"path": $path, "type": $type, "summary": $summary}]' \
      specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
fi
```

**Update TODO.md**: Add research artifact link:
```markdown
- **Research**: [research-{NNN}.md]({artifact_path})
```

---

### Stage 10: Git Commit

Commit changes with session ID:

```bash
git add -A
git commit -m "task ${task_number}: complete research

Session: ${session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

### Stage 11: Cleanup

Remove marker files:

```bash
rm -f specs/.postflight-pending
rm -f specs/.postflight-loop-guard
```

---

### Stage 12: Return Brief Summary

Return a brief text summary (NOT JSON). Example:

```
Research completed for task {N}:
- Found {count} relevant Mathlib theorems
- Identified proof strategy: {strategy}
- Created report at specs/{N}_{SLUG}/reports/research-{NNN}.md
- Status updated to [RESEARCHED]
- Changes committed
```

---

## Error Handling

### Input Validation Errors
Return immediately with error message if task not found.

### MCP Tool Failures
Apply recovery pattern: retry once, try alternative tool, continue with available info.
See Stage 5 for fallback chain.

### Git Commit Failure
Non-blocking: Log failure but continue with success response.

### Rate Limit Handling

When a search tool rate limit is hit:
1. Switch to alternative tool (leansearch <-> loogle <-> leanfinder)
2. Use lean_local_search (no limit) for verification
3. If all limited, wait briefly and continue with partial results

### No Results Found

If searches yield no useful results:
1. Try broader/alternative search terms
2. Search for related concepts
3. Return partial status with:
   - What was searched
   - Recommendations for alternative queries
   - Suggestion to manually search Mathlib docs

---

## Return Format

This skill returns a **brief text summary** (NOT JSON).

Example successful return:
```
Research completed for task 259:
- Found 5 relevant Mathlib theorems for completeness proof
- Identified proof strategy using structural induction
- Created report at specs/259_prove_completeness/reports/research-001.md
- Status updated to [RESEARCHED]
- Changes committed with session sess_1736700000_abc123
```

Example partial return:
```
Research partially completed for task 259:
- Found 2 theorems before rate limit
- Partial report created at specs/259_prove_completeness/reports/research-001.md
- Status remains [RESEARCHING] - run /research 259 to continue
```
