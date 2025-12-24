# .opencode - Context-Aware AI Agent System

> **For Project Overview**: See [README.md](../README.md) for project-specific information and development methodology.

## Overview

General-purpose AI agent system for software development. Manages the complete workflow from research through implementation to verification and documentation across any programming language or framework.

## System Architecture

### Main Orchestrator
- **orchestrator**: Coordinates all workflows, routes to specialized agents, manages context allocation

### Agent System Summary

**Workflow and utility agents** live in `agent/subagents/*.md` (orchestrator plus reviewer, researcher, planner, implementer, lean-implementation-orchestrator, refactorer, documenter, meta, task-adder, task-executor, context-refactor, implementation-orchestrator, proof/lean specialists, etc.).
**Specialist helpers (20)** live in `agent/subagents/specialists/*.md` and are referenced directly from the workflow agents (no separate README).

### Guardrails & Standards Quicklinks
- Lazy directory creation and command contracts: [context/common/system/artifact-management.md](context/common/system/artifact-management.md)
- Status markers (canonical set + timestamps): [context/common/system/status-markers.md](context/common/system/status-markers.md)
- Task/plan/state sync rules: [context/common/standards/tasks.md](context/common/standards/tasks.md), [context/common/system/state-schema.md](context/common/system/state-schema.md)
- Artifact standards: [context/common/standards/plan.md](context/common/standards/plan.md), [context/common/standards/report.md](context/common/standards/report.md), [context/common/standards/summary.md](context/common/standards/summary.md)
- Documentation conventions: [context/common/standards/documentation.md](context/common/standards/documentation.md)

## Quick Start

### Basic workflow: `/add` → `/research` → `/plan` → `/implement`
1. **Add the task to TODO**
   ```bash
   /add "Implement user authentication"
   ```
   Creates a TODO entry with an ID (view it with `/todo`).

2. **Research for that TODO**
   ```bash
   /research 001
   ```
   Uses the project number from `/add` and produces a research report you can reference when planning.

3. **Plan the implementation**
   ```bash
   /plan 001
   ```
   Builds a step-by-step plan for that project, reusing any linked research.

4. **Execute the TODO via `/implement`**
   ```bash
   /implement 001
   ```
   Follows the plan phases, updates status markers, and runs the work.

### Additional quick commands
- `/review` — Analyze repository state and update TODO.md
- `/implement {project_number}` — Execute a plan directly by project ID
- `/refactor {file_path}` — Improve readability and style adherence
- `/document {scope}` — Update documentation for a feature or area


## Custom Commands

### Core Workflows
- `/review` - Comprehensive repository review
- `/research {project_number}` - Research linked to a TODO created via `/add`
- `/plan {project_number}` - Create implementation plan for a TODO entry
- `/revise {project_number}` - Revise existing plan
- `/implement {project_number}` - Execute implementation plan
- `/refactor {file_path}` - Refactor code
- `/document {scope}` - Update documentation

### Meta-System
- `/meta {request}` - Create or modify agents and commands

### Task Management
- `/add {task}` - Add tasks to TODO.md
- `/todo` - Display TODO list
- `/implement {task_number}` - Execute TODO task

## Project Structure

```
.opencode/
├── agent/
│   ├── orchestrator.md
│   └── subagents/          # Workflow + utility agents
│       ├── *.md            # reviewer, researcher, planner, implementer, lean-implementation-orchestrator, refactorer, documenter, meta, task-* , context-refactor, implementation-orchestrator, proof helpers, etc.
│       └── specialists/    # 20 focused helpers (style-checker, doc-writer, git-workflow-manager, etc.)
├── context/                # See context/README.md
│   ├── common/             # standards/, system/, templates/, workflows/
│   ├── project/            # domain overlays (logic, lean4, math, physics, repo)
│   └── index.md, README.md
├── command/                # User-facing commands (add, context, document, implement, lean, meta, optimize, plan, refactor, research, review, revise, task, todo)
├── specs/                  # See specs/README.md
│   ├── TODO.md             # Master task list
│   ├── state.json          # Global state
│   └── NNN_project_name/   # Project directories with reports/, plans/, summaries/, state.json
└── [documentation files]
```

**Lazy creation & responsibilities**
- Create the project root only when writing the first artifact. Create only the subdirectory needed at write time (reports/ for research/review, plans/ for plan/revise, summaries/ only when emitting summaries). No placeholder files.
- Project `state.json` is written alongside artifact creation; global state follows artifact writes. See `context/common/system/artifact-management.md` and `context/common/system/state-schema.md`.
- `/implement` reuses the plan link in TODO.md when present and updates plan phases in place with status markers; `/plan` and `/revise` reuse linked research inputs.

## Key Features

### Context Protection
All primary agents use specialist subagents that:
- Create detailed artifacts in `.opencode/specs/NNN_project/`
- Return only file references and brief summaries
- Protect orchestrator context window from bloat

### Artifact Organization
Standardized structure in `.opencode/specs/`:
- **reports/**: Research, analysis, verification reports
- **plans/**: Implementation plans (versioned)
- **summaries/**: Brief summaries for quick reference
- **state.json**: Project and global state tracking

### Status markers & sync
- Use canonical markers `[NOT STARTED]`, `[IN PROGRESS]`, `[BLOCKED]`, `[ABANDONED]`, `[COMPLETED]` with timestamps per `context/common/system/status-markers.md`.
- Mirror markers across TODO.md (date-only), plan phases (ISO 8601), and state files (lowercase values) per `context/common/standards/tasks.md` and `context/common/system/state-schema.md`.
- `/implement` updates linked plan phases; status changes must be reflected in TODO and state alongside artifact writes.

### Version Control
- Implementation plans versioned (implementation-001.md, implementation-002.md, ...)
- `/revise` command creates new version with incremented number
- Git commits after substantial changes

### State Management
- Project state: `.opencode/specs/NNN_project/state.json`
- Global state: `.opencode/specs/state.json`
- User-facing: `.opencode/specs/TODO.md`
- Automatic synchronization

### Tool Integration
- **Git/GitHub**: Version control and issue tracking
- **gh CLI**: Push TODO tasks to GitHub issues
- **Language-specific tools**: Linters, formatters, test runners
- **Web search**: Research and documentation lookup

## Workflow Examples

### Complete Development Cycle

1. **Add TODO and note project number**
   ```
   /add "Implement OAuth 2.0 authentication"
   /todo   # confirms assigned number (e.g., 003)
   ```
   → Creates TODO entry (project 003) for the feature

2. **Research that TODO**
   ```
   /research 003
   ```
   → Searches web and documentation
   → Creates research report with findings

3. **Create implementation plan**
   ```
   /plan 003
   ```
   → Analyzes complexity and dependencies
   → Creates detailed step-by-step plan

4. **Implement the feature**
   ```
   /implement 003
   ```
   → Follows implementation plan
   → Runs tests and validation
   → Commits to git

5. **Update documentation**
   ```
   /document "authentication system"
   ```
   → Updates docs for new feature
   → Ensures completeness and accuracy

### Plan Revision Cycle

1. **Create initial plan for TODO**
   ```
   /plan 004
   ```
   → Creates plans/implementation-001.md for project 004

2. **Discover issues during implementation**
   ```
   /revise 004
   ```
   → Creates plans/implementation-002.md
   → Includes revision notes

3. **Further refinement needed**
   ```
   /revise 004
   ```
   → Creates plans/implementation-003.md

## Context Files

### project/
- **domain/**: Project-specific domain knowledge
- **processes/**: Project-specific workflows
- **standards/**: Code style guides and conventions
- **templates/**: Code templates and boilerplate
- **patterns/**: Common design patterns

### core/
- **system/**: System architecture and patterns
- **workflows/**: Standard development workflows
- **standards/**: General coding standards

### repo/
- **project-structure.md**: Project organization guide
- **artifact-organization.md**: Artifact naming and structure
- **state-management.md**: State file formats and synchronization

## Performance Characteristics

### Context Efficiency
- **80%** of tasks use Level 1 context (1-2 files, isolated)
- **20%** of tasks use Level 2 context (3-4 files, filtered)
- **<5%** of tasks use Level 3 context (4-6 files, comprehensive)

### Routing Accuracy
- Correct agent selection: >95%
- Appropriate context allocation: >90%
- Successful artifact creation: >98%

### Quality Standards
- All code tested and validated
- Style guide adherence enforced
- Documentation kept current and concise
- Git commits for all substantial changes

## Next Steps

1. **Test the system** with `/review` to analyze current repository state
2. **Review TODO.md** to see identified tasks
3. **Research a TODO** using `/research {project_number}` from `/add`
4. **Create a plan** with `/plan {project_number}` for that TODO
5. **Implement a feature** following the plan
6. **Customize context** files with your specific domain knowledge

## Documentation

### System Documentation
- **ARCHITECTURE.md**: Detailed system architecture
- **QUICK-START.md**: Step-by-step usage guide
- **TESTING.md**: Testing checklist and procedures

### Directory READMEs
- **agent/README.md**: Agent system overview and routing
- **agent/subagents/specialists/README.md**: Specialist catalog (19 specialists)
- **command/README.md**: Command reference and usage
- **specs/README.md**: Task workflow and artifact organization
- **context/README.md**: Context organization guide

## Verification

Verify system integrity and setup. Use canonical status markers (see `context/common/system/status-markers.md`) and respect lazy directory creation (see `context/common/system/artifact-management.md`) when running commands.

### Agent System Verification
```bash
# List workflow/utility agents
ls .opencode/agent/subagents/*.md

# List specialist helpers (should return 20 files)
find .opencode/agent/subagents/specialists -maxdepth 1 -name "*.md" -type f | sort
```

### Command System Verification
```bash
# List all commands (expect add, context, document, implement, lean, meta, optimize, plan, refactor, research, review, revise, task, todo)
ls .opencode/command/*.md
```

### Context Structure Verification
```bash
# Verify context directories exist
ls -d .opencode/context/*/

# Expected output: builder-templates, core, project, repo
```

### Specs Directory Verification
```bash
# Check specs structure
ls .opencode/specs/

# Verify TODO.md exists
test -f .opencode/specs/TODO.md && echo "TODO.md exists" || echo "TODO.md missing"

# Verify state.json exists
test -f .opencode/specs/state.json && echo "state.json exists" || echo "state.json missing"

# Count project directories
find .opencode/specs -maxdepth 1 -type d -name "[0-9]*" | wc -l
```

### Complete System Verification
```bash
# Run all verification checks
echo "=== Agent System ==="
echo "Workflow/utility agents:" && ls .opencode/agent/subagents/*.md

echo -e "\nSpecialist helpers (target: 20)"
find .opencode/agent/subagents/specialists -maxdepth 1 -name "*.md" -type f | sort

echo -e "\n=== Command System ==="
ls .opencode/command/*.md

echo -e "\n=== Context Structure ==="
ls -d .opencode/context/*/

echo -e "\n=== Specs Directory ==="
echo "TODO.md: $(test -f .opencode/specs/TODO.md && echo "present" || echo "missing")"
echo "state.json: $(test -f .opencode/specs/state.json && echo "present" || echo "missing")"
echo "Project directories: $(find .opencode/specs -maxdepth 1 -type d -name "[0-9]*" | wc -l)"
```

## Support

For questions or issues:
1. Review relevant documentation files
2. Check context files for domain knowledge
3. Examine example artifacts in `.opencode/specs/`
4. Use `/meta` to extend the system with new agents or commands
5. Run verification commands to check system integrity

---

**Your AI-powered development system is ready!**
