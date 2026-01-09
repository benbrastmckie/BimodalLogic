---
description: Research a task and create reports
allowed-tools: Read, Write, Edit, Glob, Grep, WebSearch, WebFetch, Bash(git:*), TodoWrite, mcp__lean-lsp__lean_leansearch, mcp__lean-lsp__lean_loogle, mcp__lean-lsp__lean_leanfinder, mcp__lean-lsp__lean_local_search
argument-hint: TASK_NUMBER [FOCUS]
model: claude-opus-4-5-20251101
---

# /research Command

Conduct research for a task and create a research report.

## Arguments

- `$1` - Task number (required)
- Remaining args - Optional focus/prompt for research direction

## Execution

### 1. Parse and Validate

```
task_number = first token from $ARGUMENTS
focus_prompt = remaining tokens (optional)
```

**Lookup task via jq** (see skill-status-sync for patterns):
```bash
task_data=$(jq -r --arg num "$task_number" \
  '.active_projects[] | select(.project_number == ($num | tonumber))' \
  .claude/specs/state.json)

# Validate task exists
if [ -z "$task_data" ]; then
  echo "Error: Task $task_number not found in state.json"
  exit 1
fi

# Extract fields
language=$(echo "$task_data" | jq -r '.language // "general"')
status=$(echo "$task_data" | jq -r '.status')
project_name=$(echo "$task_data" | jq -r '.project_name')
description=$(echo "$task_data" | jq -r '.description // ""')
```

### 2. Validate Status

Allowed statuses: not_started, planned, partial, blocked
- If completed/abandoned: Error with recommendation
- If researching: Warn about stale status
- If already researched: Note existing report, offer --force

### 3. Update Status to RESEARCHING

**Invoke skill-status-sync** for atomic update:
- task_number: {N}
- operation: status_update
- new_status: researching

This updates both files atomically:
1. state.json: status = "researching" (via jq)
2. TODO.md: Status: [RESEARCHING] (via grep + Edit)

### 4. Route by Language

**If language == "lean":**
Use Lean-specific search tools:
- `lean_leansearch` - Natural language queries about Mathlib
- `lean_loogle` - Type signature pattern matching
- `lean_leanfinder` - Semantic concept search
- `lean_local_search` - Check local declarations

Search strategy:
1. Search for relevant theorems/lemmas
2. Find similar proofs in Mathlib
3. Identify required imports
4. Note proof patterns and tactics

**If language == "general" or other:**
Use web and codebase search:
- `WebSearch` - External documentation/tutorials
- `WebFetch` - Retrieve specific pages
- `Read`, `Grep`, `Glob` - Codebase exploration

Search strategy:
1. Search for relevant documentation
2. Find similar implementations
3. Identify patterns and best practices
4. Note dependencies and considerations

### 5. Create Research Report

Create directory if needed:
```
mkdir -p .claude/specs/{N}_{SLUG}/reports/
```

Find next report number (research-001.md, research-002.md, etc.)

Write report to `.claude/specs/{N}_{SLUG}/reports/research-{NNN}.md`:

```markdown
# Research Report: Task #{N}

**Task**: {title}
**Date**: {ISO_DATE}
**Focus**: {focus_prompt or "General research"}

## Summary

{2-3 sentence overview of findings}

## Findings

### {Topic 1}

{Detailed findings}

### {Topic 2}

{Detailed findings}

## Recommendations

1. {Approach recommendation}
2. {Key considerations}
3. {Potential challenges}

## References

- {Source 1}
- {Source 2}

## Next Steps

{Suggested next actions for planning/implementation}
```

### 6. Update Status to RESEARCHED

**Invoke skill-status-sync** for atomic update:
- task_number: {N}
- operation: status_update
- new_status: researched
- artifact_path: .claude/specs/{N}_{SLUG}/reports/research-{NNN}.md
- artifact_type: research

This updates both files atomically:
1. state.json: status = "researched", artifacts += [{path, type}] (via jq)
2. TODO.md: Status: [RESEARCHED], add Research link (via grep + Edit)

### 7. Git Commit

```bash
git add .claude/specs/
git commit -m "task {N}: complete research"
```

### 8. Output

```
Research completed for Task #{N}

Report: .claude/specs/{N}_{SLUG}/reports/research-{NNN}.md

Key findings:
- {finding 1}
- {finding 2}

Status: [RESEARCHED]
Next: /plan {N}
```
