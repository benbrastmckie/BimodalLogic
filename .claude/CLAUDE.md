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

All workflow commands follow a three-checkpoint pattern where **commands own all checkpoint operations**. Skills are thin wrappers that only delegate to subagents.

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

### Checkpoint Ownership

| Checkpoint | Owner | Operations |
|------------|-------|------------|
| GATE IN | Command | Generate session_id, validate, update to "in progress" |
| DELEGATE | Skill | Validate inputs, invoke subagent via Task tool |
| GATE OUT | Command | Read metadata, update to "completed", link artifacts |
| COMMIT | Command | Git commit with session_id |

**Why commands?** Skill postflight code may not execute due to Claude Code Issue #17351. Command code always executes, ensuring reliable checkpoint completion.

### Session Tracking

Each command generates a session ID at GATE IN: `sess_{timestamp}_{random}`

Session ID is:
- Passed through delegation to skill/agent
- Included in error logs for traceability
- Included in git commits for correlation

### Metadata File Exchange

Subagents communicate results via metadata files:
- Location: `specs/{N}_{SLUG}/.meta/{operation}-return-meta.json`
- Created by: Subagent (before returning)
- Read by: Command (in GATE OUT)
- Contains: status, summary, artifacts, completion_data

### Checkpoint Details

Reference: `.claude/context/core/patterns/checkpoint-in-commands.md`

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
Moves completed/abandoned tasks to archive/. For non-meta tasks, updates ROAD_MAP.md with completion annotations. For meta tasks, displays CLAUDE.md modification suggestions for user review.

### /errors - Analyze error patterns
Reads errors.json, creates fix plans

### /meta - System builder
Interactive system builder that creates TASKS for .claude/ changes. Uses skill-meta -> meta-builder-agent delegation. Supports three modes: interactive interview, prompt analysis, and system analysis (--analyze).

### /learn - Scan for tags, create tasks interactively
```
/learn [PATH...]   # Scan for FIX:/NOTE:/TODO: tags
```
Scans source files for embedded tags. Displays findings, then prompts for interactive task type and TODO item selection before creating tasks. Users always see what was found before any tasks are created.

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
      "priority": "high",
      "completion_summary": "Required when status=completed. 1-3 sentence description.",
      "roadmap_items": ["Optional explicit roadmap item texts to match"]
    }
  ]
}
```

### Completion Summary Workflow

When a task is completed via `/implement`:
1. The `completion_summary` field is populated with a 1-3 sentence description of what was accomplished
2. For non-meta tasks: Optional `roadmap_items` array can specify explicit ROAD_MAP.md item texts to match
3. For meta tasks: Optional `claudemd_suggestions` object can propose CLAUDE.md modifications

When `/todo` archives completed tasks:

**Non-meta tasks** (language != "meta"):
1. Extracts `completion_summary` and `roadmap_items` via jq
2. Matches against ROAD_MAP.md using: explicit roadmap_items (priority 1), exact (Task N) references (priority 2)
3. Annotates matched items with completion date and task reference

**Meta tasks** (language == "meta"):
1. Extracts `claudemd_suggestions` object if present
2. Displays suggested CLAUDE.md modifications for user review (add/update/remove actions)
3. User manually applies suggestions - changes are NOT automatic
4. Tasks with action "none" or missing suggestions are acknowledged without action

This separation ensures:
- Project roadmap tracks external deliverables (features, proofs, documentation)
- Development system documentation (CLAUDE.md) tracks internal tool/workflow changes
- Meta task changes require user review before applying to prevent accidental bloat

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

### Thin Wrapper Pattern

Workflow skills are **thin wrappers** that only:
1. Validate inputs from the calling command
2. Prepare delegation context
3. Invoke a subagent via Task tool
4. Return the subagent's text summary

**Skills do NOT**:
- Handle checkpoints (preflight/postflight)
- Update state.json or TODO.md
- Link artifacts
- Create git commits

All checkpoint operations are handled by the **calling command**.

```yaml
---
name: skill-{name}
description: {description}
allowed-tools: Task
---
```

Reference: `.claude/context/core/patterns/thin-wrapper-skill.md`

### Checkpoint Responsibility Split

| Component | Responsibility |
|-----------|---------------|
| **Command** | GATE IN: validate, update to "in progress" |
| **Skill** | DELEGATE: validate inputs, invoke subagent |
| **Subagent** | Execute work, write metadata file, return text summary |
| **Command** | GATE OUT: read metadata, update to "completed", link artifacts |
| **Command** | COMMIT: git commit with session_id |

### Lazy Context Loading

Context is loaded lazily:
1. **Delegating skills**: Use Task tool to spawn subagents which load their own context
2. **Direct skills**: Document required context via @-references in a "Context Loading" section

Reference `@.claude/context/index.md` for the full context discovery index.

### Custom Agent Registration

Custom agents in `.claude/agents/` **require YAML frontmatter** to be recognized by Claude Code:

```yaml
---
name: {agent-name}
description: {one-line description}
---
```

Without frontmatter, Claude Code silently ignores agent files. Agent registration takes effect on session restart.

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
| skill-learn | (direct execution) | Interactive tag scanning and task creation from source comments |
| skill-status-sync | (direct execution) | Atomic status updates for task state |
| skill-document-converter | document-converter-agent | Document format conversion (PDF/DOCX to Markdown, etc.) |
| skill-refresh | (direct execution) | Manage orphaned processes and project file cleanup |

### Benefits

- **Reliability**: Checkpoints in commands always execute
- **Token Efficiency**: Context loaded only in subagent conversation
- **Isolation**: Subagent context doesn't bloat parent conversation
- **Reusability**: Same subagent usable from multiple entry points
- **Maintainability**: Skills = routing, Agents = execution

### Related Documentation

- `.claude/context/core/formats/subagent-return.md` - Return format standard
- `.claude/context/core/orchestration/orchestration-core.md` - Delegation patterns
- `.claude/context/core/architecture/system-overview.md` - Three-layer architecture overview
- `.claude/context/core/architecture/component-checklist.md` - Component creation decision tree
- `.claude/context/core/architecture/generation-guidelines.md` - Templates for /meta agent
- `.claude/context/core/patterns/thin-wrapper-skill.md` - Skill delegation pattern
- `.claude/context/core/patterns/checkpoint-execution.md` - Command checkpoint pattern
- `.claude/docs/architecture/system-overview.md` - User-facing architecture overview

## Session Maintenance

Claude Code resources can accumulate over time. Use the `/refresh` command to manage:
- **Orphaned processes**: Detached Claude processes consuming memory
- **Directory cleanup**: Old files in `~/.claude/` (projects, debug, file-history, todos, etc.)

### Quick Commands

| Command | Description |
|---------|-------------|
| `/refresh` | Interactive: cleanup processes, then select age threshold for directories |
| `/refresh --dry-run` | Preview both cleanups without making changes |
| `/refresh --force` | Execute both cleanups immediately (8-hour default) |

### Age Threshold Options

When running `/refresh` interactively, you'll be prompted to select an age threshold:
- **8 hours (default)** - Remove files older than 8 hours
- **2 days** - Remove files older than 2 days (conservative)
- **Clean slate** - Remove everything except safety margin (1 hour)

### Cleanable Directories

The following directories in `~/.claude/` are cleaned based on age:
- `projects/` - Session .jsonl files and subdirectories
- `debug/` - Debug output files
- `file-history/` - File version snapshots
- `todos/` - Todo list backups
- `session-env/` - Environment snapshots
- `telemetry/` - Usage telemetry data
- `shell-snapshots/` - Shell state
- `plugins/cache/` - Old plugin versions
- `cache/` - General cache

### Shell Aliases (Optional)

Install convenience aliases:
```bash
.claude/scripts/install-aliases.sh
```

This adds: `claude-refresh`, `claude-refresh-force`

### Safety

**Process cleanup**:
- Only targets orphaned processes (no controlling terminal)
- Active sessions are never affected

**Directory cleanup**:
- Never deletes: `sessions-index.json`, `settings.json`, `.credentials.json`, `history.jsonl`
- Never deletes files modified within the last hour (safety margin)
- Age threshold selectable interactively or defaults to 8 hours with `--force`

## Important Notes

- Always update status BEFORE starting work (preflight)
- Always update status AFTER completing work (postflight)
- State.json is source of truth for machine operations
- TODO.md is source of truth for user visibility
- Git commits are non-blocking (failures logged, not fatal)
