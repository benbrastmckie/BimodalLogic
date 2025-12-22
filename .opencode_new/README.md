# .opencode - Context-Aware AI Agent System

> **For Project Overview**: See [README.md](../README.md) for project-specific information and development methodology.

## Overview

General-purpose AI agent system for software development. Manages the complete workflow from research through implementation to verification and documentation across any programming language or framework.

## System Architecture

### Main Orchestrator
- **orchestrator**: Coordinates all workflows, routes to specialized agents, manages context allocation

### Agent System Summary

**10 Primary Agents** coordinate workflows and delegate to specialists  
**19 Specialist Subagents** perform focused technical tasks

> **Complete Agent Catalog**: See [agent/README.md](agent/README.md) for primary agents and [agent/subagents/specialists/README.md](agent/subagents/specialists/README.md) for all 19 specialists organized by category.

### Guardrails & Standards Quicklinks
- Lazy directory creation and command contracts: [context/common/system/artifact-management.md](context/common/system/artifact-management.md)
- Status markers (canonical set + timestamps): [context/common/system/status-markers.md](context/common/system/status-markers.md)
- Task/plan/state sync rules: [context/common/standards/tasks.md](context/common/standards/tasks.md), [context/common/system/state-schema.md](context/common/system/state-schema.md)
- Artifact standards: [context/common/standards/plan.md](context/common/standards/plan.md), [context/common/standards/report.md](context/common/standards/report.md), [context/common/standards/summary.md](context/common/standards/summary.md)
- Documentation conventions: [context/common/standards/documentation.md](context/common/standards/documentation.md)

## Quick Start

### 1. Review Repository
```bash
/review
```
Analyzes repository, verifies code quality, updates TODO.md

### 2. Research a Topic
```bash
/research "best practices for REST API design"
```
Searches web and documentation, creates comprehensive research report

### 3. Create Implementation Plan
```bash
/plan "Implement user authentication system"
```
Creates detailed step-by-step implementation plan

### 4. Implement the Plan
```bash
/implement 001
```
Implements features following plan, runs tests, commits to git

### 5. Refactor Code
```bash
/refactor src/api/users.py
```
Improves code readability and style adherence

### 6. Update Documentation
```bash
/document "authentication system"
```
Updates documentation to be complete, accurate, concise

## Custom Commands

### Core Workflows
- `/review` - Comprehensive repository review
- `/research {topic}` - Multi-source research
- `/plan {task}` - Create implementation plan
- `/revise {project_number}` - Revise existing plan
- `/implement {project_number}` - Execute implementation plan
- `/refactor {file_path}` - Refactor code
- `/document {scope}` - Update documentation

### Meta-System
- `/meta {request}` - Create or modify agents and commands

### Task Management
- `/add {task}` - Add tasks to TODO.md
- `/todo` - Display TODO list
- `/task {task_number}` - Execute TODO task

## Project Structure

```
.opencode/
├── agent/                  # See agent/README.md
│   ├── orchestrator.md
│   └── subagents/
│       ├── reviewer.md
│       ├── researcher.md
│       ├── planner.md
│       ├── developer.md
│       ├── refactorer.md
│       ├── documenter.md
│       ├── meta.md
│       └── specialists/    # See agent/subagents/specialists/README.md
│           └── [19 specialist subagents]
├── context/                # See context/README.md
│   ├── project/            # Project-specific context
│   ├── repo/               # Repository conventions
│   ├── core/               # Core system patterns
│   └── templates/          # Meta-system templates
├── command/                # See command/README.md
│   └── [11 commands: review, research, plan, revise, implement, refactor, document, meta, add, todo, task]
├── specs/                  # See specs/README.md
│   ├── TODO.md             # Master task list
│   ├── state.json          # Global state
│   └── NNN_project_name/   # Project directories
│       ├── reports/
│       ├── plans/
│       ├── summaries/
│       └── state.json
└── [documentation files]
```

**Lazy creation & responsibilities**
- Create the project root only when writing the first artifact. Create only the subdirectory needed at write time (reports/ for research/review, plans/ for plan/revise, summaries/ only when emitting summaries). No placeholder files.
- Project `state.json` is written alongside artifact creation; global state follows artifact writes. See `context/common/system/artifact-management.md` and `context/common/system/state-schema.md`.
- `/task` and `/implement` reuse the plan link in TODO.md when present and update plan phases in place with status markers; `/plan` and `/revise` reuse linked research inputs.

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
- `/task` and `/implement` update linked plan phases; status changes must be reflected in TODO and state alongside artifact writes.

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

1. **Review current state**
   ```
   /review
   ```
   → Creates analysis and code quality reports
   → Updates TODO.md with findings

2. **Research next task**
   ```
   /research "OAuth 2.0 implementation best practices"
   ```
   → Searches web and documentation
   → Creates research report with findings

3. **Create implementation plan**
   ```
   /plan "Implement OAuth 2.0 authentication"
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

1. **Create initial plan**
   ```
   /plan "Implement payment processing system"
   ```
   → Creates plans/implementation-001.md

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
3. **Research a topic** to test research workflow
4. **Create a plan** for a TODO task
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
# Count primary agents (should be 10)
find .opencode/agent/subagents -maxdepth 1 -name "*.md" -type f | wc -l

# Count specialist subagents (should be 19)
find .opencode/agent/subagents/specialists -maxdepth 1 -name "*.md" -type f | grep -v README | wc -l

# List all primary agents
ls .opencode/agent/subagents/*.md
```

### Command System Verification
```bash
# Count commands (should be 11)
find .opencode/command -maxdepth 1 -name "*.md" -type f | grep -v README | wc -l

# List all commands
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
echo "Primary agents: $(find .opencode/agent/subagents -maxdepth 1 -name "*.md" -type f | wc -l) (expected: 10)"
echo "Specialist subagents: $(find .opencode/agent/subagents/specialists -maxdepth 1 -name "*.md" -type f | grep -v README | wc -l) (expected: 19)"

echo -e "\n=== Command System ==="
echo "Commands: $(find .opencode/command -maxdepth 1 -name "*.md" -type f | grep -v README | wc -l) (expected: 11)"

echo -e "\n=== Context Structure ==="
echo "Context directories: $(ls -d .opencode/context/*/ 2>/dev/null | wc -l) (expected: 4)"

echo -e "\n=== Specs Directory ==="
echo "TODO.md: $(test -f .opencode/specs/TODO.md && echo "✓" || echo "✗")"
echo "state.json: $(test -f .opencode/specs/state.json && echo "✓" || echo "✗")"
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
