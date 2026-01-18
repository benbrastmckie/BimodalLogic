# ProofChecker Development System

This project uses a structured task management and agent orchestration system for Lean 4 theorem proving and research workflows.

## Quick Reference

- **Task List**: @specs/TODO.md
- **Machine State**: @specs/state.json
- **Error Tracking**: @specs/errors.json
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

docs/           # Project documentation
specs/           # Task management artifacts
.claude/                 # Claude Code configuration
```

## Task Management

### Status Markers
Tasks progress through these states:
- `[NOT STARTED]` - Initial state
- `[RESEARCHING]` → `[RESEARCHED]` - Research phase
- `[PLANNING]` → `[PLANNED]` - Planning phase
- `[IMPLEMENTING]` → `[COMPLETED]` - Implementation phase
- `[BLOCKED]`, `[ABANDONED]`, `[PARTIAL]`, `[EXPANDED]` - Terminal/exception states

### Task Artifact Paths
```
specs/{N}_{SLUG}/
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

## Checkpoint-Based Execution Model

All workflow commands follow a three-checkpoint pattern:

```
┌─────────────────────────────────────────────────────────────┐
│  CHECKPOINT 1    →    STAGE 2    →    CHECKPOINT 2    →    │
│   GATE IN             DELEGATE         GATE OUT            │
│  (Preflight)        (Skill/Agent)    (Postflight)          │
│                                                 ↓          │
│                                          CHECKPOINT 3      │
│                                            COMMIT          │
└─────────────────────────────────────────────────────────────┘
```

### Session Tracking

Each command generates a session ID at GATE IN: `sess_{timestamp}_{random}`

Session ID is:
- Passed through delegation to skill/agent
- Included in error logs for traceability
- Included in git commits for correlation

### Checkpoint Details

Reference: `.claude/context/core/checkpoints/`

---

## Command Workflows

All commands use checkpoint-based execution via skill-status-sync.

### /task - Create or manage tasks
```
/task "Description"          # Create new task
/task --recover 343-345      # Recover from archive
/task --expand 326           # Expand into subtasks
/task --sync                 # Sync TODO.md with state.json
/task --abandon 343-345      # Archive tasks
```

### /research N [focus] - Research a task
GATE IN → Validate, update to [RESEARCHING]
DELEGATE → Route by language (lean→skill-lean-research, other→skill-researcher)
GATE OUT → Link report artifact, update to [RESEARCHED]
COMMIT → Git commit with session ID

### /plan N - Create implementation plan
GATE IN → Validate, update to [PLANNING]
DELEGATE → skill-planner creates phased plan
GATE OUT → Link plan artifact, update to [PLANNED]
COMMIT → Git commit with session ID

### /implement N - Execute implementation
GATE IN → Validate, find resume point, update to [IMPLEMENTING]
DELEGATE → Route by language (lean→skill-lean-implementation, etc.)
GATE OUT → Link summary artifact, update to [COMPLETED]
COMMIT → Git commit with session ID

### /revise N - Create new plan version
Increments plan version (implementation-002.md, etc.)

### /review - Analyze codebase
Code review and registry updates

### /todo - Archive completed tasks
Moves completed/abandoned tasks to archive/

### /errors - Analyze error patterns
Reads errors.json, creates fix plans

### /meta - System builder
Interactive system builder that creates TASKS for .claude/ changes. Uses skill-meta -> meta-builder-agent delegation. Supports three modes: interactive interview, prompt analysis, and system analysis (--analyze).

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

Commits are scoped to task operations with session tracking:
```
task {N}: {action}

Session: sess_{timestamp}_{random}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

Standard actions:
- `task {N}: create {title}`
- `task {N}: complete research`
- `task {N}: create implementation plan`
- `task {N} phase {P}: {phase_name}`
- `task {N}: complete implementation`
- `todo: archive {N} completed tasks`
- `errors: create fix plan for {N} errors`

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
- @.claude/rules/state-management.md - Task state patterns (paths: specs/**)
- @.claude/rules/git-workflow.md - Commit conventions
- @.claude/rules/lean4.md - Lean development patterns (paths: **/*.lean)
- @.claude/rules/error-handling.md - Error recovery patterns (paths: .claude/**)
- @.claude/rules/artifact-formats.md - Report/plan formats (paths: specs/**)
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

## Skill Architecture

### Lazy Context Loading

All skills use lazy context loading - context is never loaded eagerly via frontmatter arrays. Instead:

1. **Delegating skills**: Use Task tool to spawn subagents which load their own context
2. **Direct skills**: Document required context via @-references in a "Context Loading" section

Reference `@.claude/context/index.md` for the full context discovery index.

### Thin Wrapper Skill Pattern

Workflow skills use a thin wrapper pattern that delegates to subagents via the Task tool:

```yaml
---
name: skill-{name}
description: {description}
allowed-tools: Task
---
```

**Key characteristics**:
- Skills contain minimal routing logic only
- All context loading happens in the subagent (via Task tool)
- Skill instructions specify which agent to invoke (e.g., `subagent_type: "general-research-agent"`)
- No `context: fork` or `agent:` fields needed - delegation is explicit via Task tool

**When NOT to use thin wrapper pattern**:
- Skills that execute work directly without spawning a subagent (e.g., skill-status-sync)
- Skills that need to process results before returning (use direct execution instead)

### Custom Agent Registration

Custom agents in `.claude/agents/` **require YAML frontmatter** to be recognized by Claude Code:

```yaml
---
name: {agent-name}
description: {one-line description}
---
```

Without frontmatter, Claude Code silently ignores agent files and they won't appear as valid `subagent_type` values. Agent registration takes effect on session restart.

### Skill-to-Agent Mapping

| Skill | Agent | Purpose |
|-------|-------|---------|
| skill-lean-research | lean-research-agent | Lean 4/Mathlib research |
| skill-researcher | general-research-agent | General web/codebase research |
| skill-planner | planner-agent | Implementation plan creation |
| skill-implementer | general-implementation-agent | General file implementation |
| skill-lean-implementation | lean-implementation-agent | Lean proof implementation |
| skill-latex-implementation | latex-implementation-agent | LaTeX document implementation |
| skill-meta | meta-builder-agent | System building and task creation |
| skill-status-sync | (direct execution) | Atomic status updates for task state |
| skill-document-converter | document-converter-agent | Document format conversion (PDF/DOCX to Markdown, etc.) |

### Thin Wrapper Execution Flow

All delegating skills follow this 5-step pattern:

1. **Input Validation** - Verify task exists, status allows operation
2. **Context Preparation** - Build delegation context with session_id
3. **Invoke Subagent** - Call Task tool with target agent
4. **Return Validation** - Verify return matches `subagent-return.md` schema
5. **Return Propagation** - Pass validated result to caller

### Benefits

- **Token Efficiency**: Context loaded only in subagent conversation
- **Isolation**: Subagent context doesn't bloat parent conversation
- **Reusability**: Same subagent usable from multiple entry points
- **Maintainability**: Skills = routing, Agents = execution

### Related Documentation

- `.claude/context/core/formats/subagent-return.md` - Return format standard
- `.claude/context/core/orchestration/delegation.md` - Delegation patterns

## Important Notes

- Always update status BEFORE starting work (preflight)
- Always update status AFTER completing work (postflight)
- State.json is source of truth for machine operations
- TODO.md is source of truth for user visibility
- Git commits are non-blocking (failures logged, not fatal)
