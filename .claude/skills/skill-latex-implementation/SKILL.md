---
name: skill-latex-implementation
description: Implement LaTeX documents following a plan. Invoke for LaTeX-language implementation tasks.
allowed-tools: Task
context: fork
agent: latex-implementation-agent
# Original context (now loaded by subagent):
#   - .claude/context/project/latex/README.md
#   - .claude/context/project/latex/standards/latex-style-guide.md
#   - .claude/context/project/latex/standards/notation-conventions.md
#   - .claude/context/project/latex/standards/document-structure.md
#   - .claude/context/project/latex/patterns/theorem-environments.md
#   - .claude/context/project/latex/patterns/cross-references.md
#   - .claude/context/project/latex/templates/subfile-template.md
#   - .claude/context/project/latex/tools/compilation-guide.md
#   - .claude/context/project/logic/standards/notation-standards.md
# Original tools (now used by subagent):
#   - Read, Write, Edit, Glob, Grep
#   - Bash(pdflatex *, latexmk *, bibtex *, biber *)
---

# LaTeX Implementation Skill

Thin wrapper that delegates LaTeX document implementation to `latex-implementation-agent` subagent.

## Context Pointers

Reference (do not load eagerly):
- Path: `.claude/context/core/validation.md`
- Purpose: Return validation at CHECKPOINT 2
- Load at: Subagent execution only

Note: This skill is a thin wrapper. Context is loaded by the delegated agent, not this skill.

## Trigger Conditions

This skill activates when:
- Task language is "latex"
- /implement command targets a LaTeX task
- Documents, papers, or formatted output needs to be created

---

## Execution

### 1. Input Validation

Validate required inputs:
- `task_number` - Must be provided and exist in state.json
- Task status must allow implementation (planned, implementing, partial)

```bash
# Lookup task
task_data=$(jq -r --arg num "$task_number" \
  '.active_projects[] | select(.project_number == ($num | tonumber))' \
  .claude/specs/state.json)

# Validate exists
if [ -z "$task_data" ]; then
  return error "Task $task_number not found"
fi

# Extract fields
language=$(echo "$task_data" | jq -r '.language // "general"')
status=$(echo "$task_data" | jq -r '.status')
project_name=$(echo "$task_data" | jq -r '.project_name')
description=$(echo "$task_data" | jq -r '.description // ""')

# Validate language
if [ "$language" != "latex" ]; then
  return error "Task $task_number is not a LaTeX task"
fi

# Validate status
if [ "$status" = "completed" ]; then
  return error "Task already completed"
fi
```

### 2. Context Preparation

Prepare delegation context:

```json
{
  "session_id": "sess_{timestamp}_{random}",
  "delegation_depth": 1,
  "delegation_path": ["orchestrator", "implement", "skill-latex-implementation"],
  "timeout": 3600,
  "task_context": {
    "task_number": N,
    "task_name": "{project_name}",
    "description": "{description}",
    "language": "latex"
  },
  "plan_path": ".claude/specs/{N}_{SLUG}/plans/implementation-{NNN}.md"
}
```

### 3. Invoke Subagent

Invoke `latex-implementation-agent` via Task tool with:
- Task context (number, name, description, language)
- Delegation context (session_id, depth, path)
- Plan path for execution

The subagent will:
- Load LaTeX-specific context files (style guide, notation conventions, etc.)
- Create/modify .tex files
- Execute compilation loop (pdflatex/latexmk)
- Handle bibliography processing (bibtex/biber)
- Create implementation summary
- Return standardized JSON result

### 4. Return Validation

Validate return matches `subagent-return.md` schema:
- Status is one of: completed, partial, failed, blocked
- Summary is non-empty and <100 tokens
- Artifacts array present (source files, compiled PDF, summary)
- Metadata contains session_id, agent_type, delegation info

### 5. Return Propagation

Return validated result to caller without modification.

---

## Return Format

See `.claude/context/core/formats/subagent-return.md` for full specification.

Expected successful return:
```json
{
  "status": "completed",
  "summary": "Implemented N document sections with successful compilation",
  "artifacts": [
    {
      "type": "implementation",
      "path": "docs/output.tex",
      "summary": "LaTeX source file"
    },
    {
      "type": "output",
      "path": "docs/output.pdf",
      "summary": "Compiled PDF document"
    },
    {
      "type": "summary",
      "path": ".claude/specs/{N}_{SLUG}/summaries/implementation-summary-{DATE}.md",
      "summary": "Implementation completion summary"
    }
  ],
  "metadata": {
    "session_id": "sess_...",
    "agent_type": "latex-implementation-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "implement", "latex-implementation-agent"]
  },
  "next_steps": "Task complete"
}
```

Expected partial return (compilation error/timeout):
```json
{
  "status": "partial",
  "summary": "Implemented 3/5 sections, compilation error in section 4",
  "artifacts": [...],
  "errors": [{
    "type": "execution",
    "message": "LaTeX compilation failed: undefined reference",
    "recoverable": true,
    "recommendation": "Fix cross-reference and recompile"
  }],
  "next_steps": "Run /implement {N} to resume"
}
```

---

## Error Handling

### Input Validation Errors
Return immediately with failed status if task not found, wrong language, or status invalid.

### Subagent Errors
Pass through the subagent's error return verbatim.

### Timeout
Return partial status if subagent times out (default 3600s).
