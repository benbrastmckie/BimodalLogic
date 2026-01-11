# ProofChecker Development System

This project uses a structured task management and agent orchestration system for Lean 4 theorem proving and research workflows.

## Quick Reference

- **Task List**: @.claude/specs/TODO.md
- **Machine State**: @.claude/specs/state.json
- **Error Tracking**: @.claude/specs/errors.json
- **Architecture**: @.claude/ARCHITECTURE.md

## System Overview

ProofChecker is a formal verification project implementing modal, temporal, and epistemic logics in Lean 4 with Mathlib. The development workflow uses numbered tasks with structured research → plan → implement cycles.

### Project Structure

```
Logos/                    # Lean 4 source code (layered logic system)
├── Layer0/              # Classical propositional logic
├── Layer1/              # Modal logic extensions
├── Layer2/              # Temporal logic
└── Shared/              # Common definitions

Documentation/           # Project documentation
.claude/specs/           # Task management artifacts
.claude/                 # Claude Code configuration
```

## Task Management

### Status Markers
Tasks progress through these states:
- `[NOT STARTED]` - Initial state
- `[RESEARCHING]` → `[RESEARCHED]` - Research phase
- `[PLANNING]` → `[PLANNED]` - Planning phase
- `[IMPLEMENTING]` → `[COMPLETED]` - Implementation phase
- `[BLOCKED]`, `[ABANDONED]`, `[PARTIAL]` - Terminal/exception states

### Task Artifact Paths
```
.claude/specs/{N}_{SLUG}/
├── reports/                    # Research artifacts
│   └── research-{NNN}.md
├── plans/                      # Implementation plans
│   └── implementation-{NNN}.md
└── summaries/                  # Completion summaries
    └── implementation-summary-{DATE}.md
```

**Note**: `{N}` = unpadded task number, `{NNN}` = 3-digit padded artifact version. See @.claude/rules/artifact-formats.md for full conventions.

### Language-Based Routing

Tasks have a `Language` field that determines tool selection:

| Language | Research Tools | Implementation Tools |
|----------|----------------|---------------------|
| `lean` | lean_leansearch, lean_loogle, lean_leanfinder | lean_goal, lean_diagnostic_messages, lean_hover_info |
| `latex` | WebSearch, WebFetch, Read | Read, Write, Edit, Bash (pdflatex, latexmk) |
| `general` | WebSearch, WebFetch, Read | Read, Write, Edit, Bash |
| `meta` | Read, Grep, Glob | Write, Edit |

## Command Workflows

### /task - Create or manage tasks
```
/task "Description"          # Create new task
/task --recover 343-345      # Recover from archive
/task --divide 326           # Split into subtasks
/task --sync                 # Sync TODO.md with state.json
/task --abandon 343-345      # Archive tasks
```

### /research N [focus] - Research a task
1. Validate task exists
2. Update status to [RESEARCHING]
3. Execute research (language-routed)
4. Create report in .claude/specs/{N}_{SLUG}/reports/
5. Update status to [RESEARCHED]
6. Git commit

### /plan N - Create implementation plan
1. Validate task is [RESEARCHED] or [NOT STARTED]
2. Update status to [PLANNING]
3. Create phased plan with steps
4. Write to .claude/specs/{N}_{SLUG}/plans/
5. Update status to [PLANNED]
6. Git commit

### /implement N - Execute implementation
1. Validate task is [PLANNED] or [IMPLEMENTING]
2. Load plan, find resume point
3. Update status to [IMPLEMENTING]
4. Execute phases sequentially
5. Update status to [COMPLETED]
6. Create summary, git commit

### /revise N - Create new plan version
Increments plan version (implementation-002.md, etc.)

### /review - Analyze codebase
Code review and registry updates

### /todo - Archive completed tasks
Moves completed/abandoned tasks to archive/

### /errors - Analyze error patterns
Reads errors.json, creates fix plans

### /meta - System builder
Interactive agent system generator

## State Synchronization

**Critical**: TODO.md and state.json must stay synchronized.

### Two-Phase Update Pattern
1. Read both files
2. Prepare updates in memory
3. Write state.json first (machine state)
4. Write TODO.md second (user-facing)
5. If either fails, log error

### state.json Structure
```json
{
  "next_project_number": 346,
  "active_projects": [
    {
      "project_number": 334,
      "project_name": "task_slug",
      "status": "planned",
      "language": "lean",
      "priority": "high"
    }
  ]
}
```

## Git Commit Conventions

Commits are scoped to task operations:
```
task {N}: create {title}
task {N}: complete research
task {N}: create implementation plan
task {N} phase {P}: {phase_name}
task {N}: complete implementation
todo: archive {N} completed tasks
errors: create fix plan for {N} errors
```

## Lean 4 Integration

### MCP Tools (via lean-lsp server)
- `lean_goal` - Proof state at position (use often!)
- `lean_diagnostic_messages` - Compiler errors/warnings
- `lean_hover_info` - Type signatures and docs
- `lean_completions` - IDE autocomplete
- `lean_leansearch` - Natural language → Mathlib
- `lean_loogle` - Type pattern search
- `lean_leanfinder` - Semantic concept search
- `lean_multi_attempt` - Test tactics without editing
- `lean_local_search` - Fast local declaration search

### Search Decision Tree
1. "Does X exist locally?" → lean_local_search
2. "I need a lemma that says X" → lean_leansearch
3. "Find lemma with type pattern" → lean_loogle
4. "What's the Lean name for concept X?" → lean_leanfinder
5. "What closes this goal?" → lean_state_search

## Rules References

Core rules (automatically applied based on file paths):
- @.claude/rules/state-management.md - Task state patterns (paths: .claude/specs/**)
- @.claude/rules/git-workflow.md - Commit conventions
- @.claude/rules/lean4.md - Lean development patterns (paths: **/*.lean)
- @.claude/rules/error-handling.md - Error recovery patterns (paths: .claude/**)
- @.claude/rules/artifact-formats.md - Report/plan formats (paths: .claude/specs/**)
- @.claude/rules/workflows.md - Command lifecycle patterns (paths: .claude/**)

## Project Context Imports

Domain knowledge (load as needed):
- @.claude/context/project/lean4/tools/mcp-tools-guide.md - Lean MCP tools reference
- @.claude/context/project/lean4/patterns/tactic-patterns.md - Lean tactic usage
- @.claude/context/project/logic/domain/kripke-semantics-overview.md - Modal logic semantics
- @.claude/context/project/repo/project-overview.md - Project structure

## Error Handling

### On Command Failure
- Keep task in current status (don't regress)
- Log error to errors.json if persistent
- Preserve partial progress for resume

### On Timeout
- Mark current phase [PARTIAL]
- Next /implement resumes from incomplete phase

## Session Patterns

### Starting Work on a Task
```
1. Read TODO.md to find task
2. Check current status
3. Use appropriate command (/research, /plan, /implement)
```

### Resuming Interrupted Work
```
1. /implement N automatically detects resume point
2. Continues from last incomplete phase
3. No manual intervention needed
```

## Important Notes

- Always update status BEFORE starting work (preflight)
- Always update status AFTER completing work (postflight)
- State.json is source of truth for machine operations
- TODO.md is source of truth for user visibility
- Git commits are non-blocking (failures logged, not fatal)
