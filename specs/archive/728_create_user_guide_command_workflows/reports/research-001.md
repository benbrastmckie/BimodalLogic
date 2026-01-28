# Research Report: Task #728

**Task**: 728 - create_user_guide_command_workflows
**Started**: 2026-01-28T12:00:00Z
**Completed**: 2026-01-28T12:30:00Z
**Effort**: 2 hours
**Priority**: medium
**Dependencies**: None
**Sources/Inputs**: Codebase exploration (.claude/commands/, .claude/skills/, .claude/docs/)
**Artifacts**: specs/728_create_user_guide_command_workflows/reports/research-001.md
**Standards**: report-format.md

---

## Executive Summary

- Identified 13 commands organized into core workflow commands and maintenance/utility commands
- Core workflow follows: `/task` -> `/research` -> `/plan` -> `/implement` with `/revise` for refinement
- Maintenance commands handle system health: `/todo`, `/review`, `/refresh`, `/lake`, `/errors`
- Utility commands: `/meta` (system building), `/learn` (tag extraction), `/convert` (document conversion)
- Existing documentation in `.claude/docs/` provides architecture guides but lacks user-facing command workflow documentation

---

## Context & Scope

The goal is to create a user guide documenting all command workflows for the ProofChecker `.claude/` task management system. The research focused on:

1. Understanding each command's purpose, arguments, and workflow
2. Identifying relationships between commands
3. Documenting the complete task lifecycle
4. Mapping maintenance and utility commands
5. Determining the best structure for the user guide

---

## Findings

### 1. Command Inventory

The system has 13 commands in `.claude/commands/`:

| Command | Category | Description |
|---------|----------|-------------|
| `/task` | Core Workflow | Create, recover, expand, sync, abandon, or review tasks |
| `/research` | Core Workflow | Research a task and create reports |
| `/plan` | Core Workflow | Create implementation plan for a task |
| `/implement` | Core Workflow | Execute implementation with resume support |
| `/revise` | Core Workflow | Create new plan version or update task description |
| `/todo` | Maintenance | Archive completed and abandoned tasks |
| `/review` | Maintenance | Analyze codebase and create review reports |
| `/refresh` | Maintenance | Clean orphaned processes and old files in ~/.claude/ |
| `/lake` | Maintenance | Run Lean build with automatic error repair |
| `/errors` | Maintenance | Analyze error patterns and create fix plans |
| `/meta` | Utility | Interactive system builder for .claude/ changes |
| `/learn` | Utility | Scan for FIX:/NOTE:/TODO: tags and create tasks |
| `/convert` | Utility | Convert documents between formats |

### 2. Core Workflow: Task Lifecycle

The primary workflow follows this progression:

```
/task "Description"
    |
    v
/research N [focus]     <- Repeatable
    |
    v
/plan N
    |
    v
/revise N [reason]      <- Optional, zero or more times
    |
    v
/implement N            <- Repeatable if interrupted
    |
    v
/todo                   <- Archive when complete
```

#### Status Transitions

| Status | Command | Next Status |
|--------|---------|-------------|
| `[NOT STARTED]` | `/research N` | `[RESEARCHING]` -> `[RESEARCHED]` |
| `[RESEARCHED]` | `/plan N` | `[PLANNING]` -> `[PLANNED]` |
| `[PLANNED]` | `/revise N` | `[PLANNED]` (new plan version) |
| `[PLANNED]` | `/implement N` | `[IMPLEMENTING]` -> `[COMPLETED]` |
| `[IMPLEMENTING]` | `/implement N` (resume) | `[COMPLETED]` or `[PARTIAL]` |
| `[COMPLETED]` | `/todo` | Archived |

### 3. `/task` Command Details

The most feature-rich command with multiple modes:

| Mode | Syntax | Purpose |
|------|--------|---------|
| Create | `/task "Description"` | Create new task |
| Recover | `/task --recover N` or `--recover N-M` | Recover archived tasks |
| Expand | `/task --expand N [prompt]` | Break task into subtasks |
| Sync | `/task --sync` | Synchronize TODO.md with state.json |
| Abandon | `/task --abandon N` or `--abandon N-M` | Archive tasks as abandoned |
| Review | `/task --review N` | Review task completion and create follow-ups |

**Language Detection**: Automatically detects task language from keywords:
- "lean", "theorem", "proof", "lemma", "Mathlib" -> `lean`
- "meta", "agent", "command", "skill" -> `meta`
- Otherwise -> `general`

### 4. `/research` Command Details

- **Syntax**: `/research N [focus]`
- **Repeatable**: Yes, can run multiple times to add research
- **Language Routing**:
  - `lean` -> `skill-lean-research`
  - Other -> `skill-researcher`
- **Output**: Creates `specs/{N}_{SLUG}/reports/research-{NNN}.md`

### 5. `/plan` Command Details

- **Syntax**: `/plan N`
- **Prerequisites**: Task should exist (ideally researched first)
- **Output**: Creates `specs/{N}_{SLUG}/plans/implementation-{NNN}.md`
- **Phased Structure**: Plans are broken into phases with:
  - Goal for each phase
  - Steps to execute
  - Verification criteria

### 6. `/revise` Command Details

- **Syntax**: `/revise N [reason]`
- **Purpose**: Create new plan version or update task description
- **Behavior**:
  - For `planned`/`implementing`/`partial`/`blocked` status: Creates new plan version
  - For `not_started`/`researched` status: Updates task description
- **Output**: Creates `specs/{N}_{SLUG}/plans/implementation-{NNN}.md` (incremented version)

### 7. `/implement` Command Details

- **Syntax**: `/implement N [--force]`
- **Resume Support**: Automatically detects incomplete phases and resumes
- **Language Routing**:
  - `lean` -> `skill-lean-implementation`
  - `latex` -> `skill-latex-implementation`
  - Other -> `skill-implementer`
- **Phase Markers**: `[NOT STARTED]`, `[IN PROGRESS]`, `[COMPLETED]`, `[PARTIAL]`
- **Output**: Creates `specs/{N}_{SLUG}/summaries/implementation-summary-{DATE}.md`

### 8. Maintenance Commands

#### `/todo`

- **Syntax**: `/todo [--dry-run]`
- **Purpose**: Archive completed and abandoned tasks
- **Features**:
  - Moves tasks to `specs/archive/`
  - Updates ROAD_MAP.md with completion annotations
  - Handles orphaned and misplaced directories
  - Processes meta task CLAUDE.md suggestions

#### `/review`

- **Syntax**: `/review [SCOPE] [--create-tasks]`
- **Purpose**: Analyze codebase, identify issues, create reports
- **Scope**: File path, directory, or "all"
- **Features**:
  - Checks for TODOs, FIXMEs, code smells
  - For Lean: Checks sorries, axioms, build status
  - Roadmap progress tracking
  - Optional task creation for issues

#### `/refresh`

- **Syntax**: `/refresh [--dry-run] [--force]`
- **Purpose**: Clean Claude Code resources
- **Features**:
  - Terminate orphaned processes
  - Clean old files in ~/.claude/ directories
  - Interactive age threshold selection (8h, 2d, or clean slate)

#### `/lake`

- **Syntax**: `/lake [--clean] [--max-retries N] [--dry-run] [--module NAME]`
- **Purpose**: Run Lean build with automatic error repair
- **Auto-Fixable Errors**:
  - Missing pattern match cases -> Add `| {case} => sorry` branches
  - Unused variables -> Rename to `_{name}`
  - Unused imports -> Remove import line
- **Features**: Iterative build-fix loop, task creation for unfixable errors

#### `/errors`

- **Syntax**: `/errors [--fix N]`
- **Purpose**: Analyze errors.json, identify patterns, create fix plans
- **Features**:
  - Groups errors by type, severity, recurrence
  - Creates analysis reports in `specs/errors/`
  - Optional fix mode for specific error tasks

### 9. Utility Commands

#### `/meta`

- **Syntax**: `/meta [PROMPT] | --analyze`
- **Purpose**: Interactive system builder for .claude/ changes
- **Modes**:
  - Interactive (no args): 7-stage interview process
  - Prompt mode: Abbreviated flow for direct requests
  - Analyze mode (--analyze): Read-only system analysis
- **Constraint**: Creates TASKS only, never implements directly

#### `/learn`

- **Syntax**: `/learn [PATH...]`
- **Purpose**: Scan for FIX:/NOTE:/TODO: tags and create tasks
- **Interactive Flow**:
  1. Scan files for tags
  2. Display tag summary
  3. Prompt for task type selection
  4. Optional TODO item selection
  5. Optional topic grouping for multiple TODOs
  6. Create selected tasks
- **Tag Types**:
  - `FIX:` -> fix-it-task (grouped)
  - `NOTE:` -> fix-it-task + learn-it-task (with dependency)
  - `TODO:` -> todo-task (individual or grouped by topic)

#### `/convert`

- **Syntax**: `/convert SOURCE_PATH [OUTPUT_PATH]`
- **Purpose**: Convert documents between formats
- **Supported Conversions**:
  - PDF/DOCX/XLSX/PPTX/HTML -> Markdown
  - Markdown -> PDF
- **Tools Used**: markitdown, pandoc, typst

### 10. Checkpoint-Based Execution Pattern

All commands follow a consistent execution pattern:

```
CHECKPOINT 1: GATE IN
  - Generate session ID
  - Validate arguments
  - Check task exists and status allows operation
  - Update status to "in progress" variant

STAGE 2: DELEGATE
  - Route to appropriate skill/agent based on language
  - Execute the workflow

CHECKPOINT 2: GATE OUT
  - Validate return from skill/agent
  - Verify artifacts exist
  - Verify status updated correctly

CHECKPOINT 3: COMMIT
  - Git commit with standardized message format
  - Non-blocking (failures logged but don't stop command)
```

### 11. Existing Documentation Structure

Current documentation in `.claude/docs/`:

```
.claude/docs/
├── README.md                    # Documentation hub
├── guides/
│   ├── user-installation.md    # Quick-start for new users
│   ├── copy-claude-directory.md
│   ├── component-selection.md
│   ├── creating-commands.md
│   ├── creating-skills.md
│   ├── creating-agents.md
│   ├── context-loading-best-practices.md
│   └── permission-configuration.md
├── examples/
│   ├── research-flow-example.md
│   └── learn-flow-example.md
├── templates/
│   ├── README.md
│   ├── command-template.md
│   └── agent-template.md
└── architecture/
    └── system-overview.md
```

**Gap Identified**: No user-facing command workflow documentation. The existing docs focus on:
- Installation and setup
- Creating new components (commands, skills, agents)
- Architecture and internals

What's missing:
- Comprehensive command reference for end users
- Workflow tutorials (how to use the system)
- Command flag documentation

---

## Recommendations

### 1. User Guide Structure

Create `user-guide.md` in `.claude/docs/guides/` with sections:

```markdown
1. Quick Start
   - Getting started with /task
   - Your first workflow cycle

2. Core Workflow Commands
   - /task (all flags)
   - /research
   - /plan
   - /revise
   - /implement

3. Maintenance Commands
   - /todo
   - /review
   - /refresh
   - /lake
   - /errors

4. Utility Commands
   - /meta
   - /learn
   - /convert

5. Workflow Examples
   - Creating and completing a task
   - Recovering from errors
   - System maintenance

6. Reference Tables
   - Status transitions
   - Language routing
   - Command quick reference
```

### 2. README Update

Add a brief overview and link in `.claude/docs/README.md`:
- Add "User Guide" section under Guides
- Link to the new user-guide.md

### 3. Documentation Style

Based on existing patterns:
- Use tables for quick reference
- Include code examples with actual command syntax
- Show expected output for common scenarios
- Keep focused on user perspective (not implementation details)

---

## Decisions

1. **Location**: Place user guide at `.claude/docs/guides/user-guide.md` to maintain consistency with existing guide structure
2. **Scope**: Focus on command usage from user perspective, not internal implementation
3. **Format**: Use markdown with tables, code blocks, and clear section headers
4. **Cross-references**: Link to existing docs (architecture, examples) rather than duplicating

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Documentation becomes stale | Include version/update date in header |
| Too much detail | Focus on common use cases, link to command files for full details |
| Missing edge cases | Include troubleshooting section with common issues |

---

## Appendix

### Search Queries Used

1. `Glob .claude/skills/**/SKILL.md` - Found 15 skill files
2. `Glob .claude/commands/*.md` - Found 13 command files
3. `Read .claude/docs/README.md` - Examined existing documentation structure
4. `Read .claude/README.md` - Comprehensive architecture documentation

### Key Files Referenced

- `.claude/commands/task.md` - 494 lines, most complex command
- `.claude/commands/todo.md` - 1114 lines, handles archival workflow
- `.claude/commands/implement.md` - 198 lines, phase execution
- `.claude/commands/research.md` - 123 lines, research delegation
- `.claude/commands/plan.md` - 120 lines, plan creation
- `.claude/commands/revise.md` - 211 lines, plan revision
- `.claude/commands/review.md` - 449 lines, codebase review
- `.claude/commands/refresh.md` - 182 lines, cleanup utility
- `.claude/commands/lake.md` - 544 lines, Lean build with repair
- `.claude/commands/errors.md` - 192 lines, error analysis
- `.claude/commands/meta.md` - 190 lines, system builder
- `.claude/commands/learn.md` - 260 lines, tag extraction
- `.claude/commands/convert.md` - 257 lines, document conversion
