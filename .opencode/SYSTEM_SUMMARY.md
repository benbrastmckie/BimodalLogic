# .opencode AI Agent System - System Summary

> **For detailed information**: See [README.md](README.md) for quick start and [ARCHITECTURE.md](ARCHITECTURE.md) for complete architecture details.

## System Overview

**Status**: PRODUCTION READY  
**Domain**: General Software Development  
**Base**: Language-agnostic AI agent system  
**Architecture**: Hierarchical agent system with context protection

Complete context-aware AI system for software development, managing the full workflow from research through implementation to verification and documentation.

---

## Quick Reference

### System Components

| Component | Count | Documentation |
|-----------|-------|---------------|
| **Orchestrator** | 1 | [agent/orchestrator.md](agent/orchestrator.md) |
| **Workflow/Utility Agents** | see `agent/subagents/*.md` | directory listing |
| **Specialists** | 20 | `agent/subagents/specialists/*.md` |
| **Commands** | 14 | [command/README.md](command/README.md) |
| **Context Files** | 10+ | [context/README.md](context/README.md) |

### File Organization

```
.opencode/
├── agent/                  # orchestrator + workflow/utility agents + specialists
├── command/                # 14 custom commands
├── context/                # Modular knowledge base
│   ├── common/             # standards/, system/, templates/, workflows/
│   └── project/            # domain overlays (logic, lean4, math, physics, repo)
├── specs/                  # Project artifacts and state
│   ├── TODO.md             # Master task list
│   ├── state.json          # Global state
│   └── NNN_project/        # Individual projects (reports/, plans/, summaries/, state.json)
└── [documentation files]
```

**Note**: Single unified `context/` directory - all context files are in one location.

### Directory Responsibilities & Guardrails

- **Lazy creation**: Create project root only when writing the first artifact; create only the needed subdirectory (reports/, plans/, summaries/) at write time; never add placeholder files. See [context/common/system/artifact-management.md](context/common/system/artifact-management.md).
- **State timing**: Write project `state.json` only alongside an emitted artifact; global state updates follow artifact writes. See [context/common/system/state-schema.md](context/common/system/state-schema.md).
- **Plan/research reuse**: `/plan` and `/revise` reuse linked research inputs; `/task` and `/implement` reuse the plan path attached in TODO.md and update that plan in place with status markers.
- **Summaries**: Emit summaries only when an artifact is produced that requires one; do not pre-create summaries/.

### Agent & Command Map (responsibilities + creation guardrails)

| Command | Primary Agent | Creates/Updates | Guardrails |
|---------|----------------|-----------------|------------|
| `/research` | researcher | `reports/` | Create project root and `reports/` only when writing the first report. |
| `/plan`, `/revise` | planner | `plans/` | Create project root + `plans/` only when emitting the plan; reuse linked research inputs. |
| `/implement`, `/lean` | implementer / lean-implementation-orchestrator | plan phases + emitted artifacts | Require plan path; update plan status markers; create only the subdir needed for emitted artifact; state sync with artifact write. |
| `/task` | task-executor | plan phases + emitted artifacts | Reuse plan link when present; may run without plan; adhere to lazy creation; state/TODO sync when artifacts written. |
| `/review` | reviewer | `reports/` or `summaries/` | Create only the needed subdir when writing the report/summary; no placeholders. |
| `/document` | documenter | documentation + `summaries/` | Create summaries/ only when writing summary; follow documentation standards. |
| `/refactor` | refactorer | code + optional reports | Create artifacts only when produced; keep lazy creation. |
| `/optimize` | performance-profiler (via optimize command) | performance reports | Create reports only when writing diagnostics. |
| `/add`, `/todo` | task-adder | TODO/state | No artifact roots created. |
| `/context` | orchestrator | none | Navigation only. |
| `/meta` | meta | agent/command files | No specs artifacts created by default. |

### Status Markers & Sync

- Use canonical markers: `[NOT STARTED]`, `[IN PROGRESS]`, `[BLOCKED]`, `[ABANDONED]`, `[COMPLETED]` with timestamps. See [context/common/system/status-markers.md](context/common/system/status-markers.md).
- Mirror markers and timestamps across TODO entries, plan phases, and state files. State values use lowercase (`in_progress`, `completed`, etc.).
- `/task` and `/implement` update the linked plan phases in place; TODO/state must reflect the same status transitions.
- Follow [context/common/standards/tasks.md](context/common/standards/tasks.md) and [context/common/system/state-schema.md](context/common/system/state-schema.md) for synchronization rules.

---

## Core Workflows

For step-by-step guides, see [QUICK-START.md](QUICK-START.md).

### Complete Development Cycle

```bash
/review                        # Analyze repository, verify code quality
/research "topic"              # Multi-source research
/plan "task"                   # Create implementation plan
/implement NNN                 # Implement feature following plan
/refactor path/to/file         # Improve code quality
/document "scope"              # Update documentation
```

### All Available Commands

See [command/README.md](command/README.md) for complete command reference.

| Command | Purpose | Agent |
|---------|---------|-------|
| `/review` | Repository analysis & verification | reviewer |
| `/research {topic}` | Multi-source research | researcher |
| `/plan {task}` | Create implementation plan | planner |
| `/revise {project}` | Revise existing plan | planner |
| `/implement {project}` | Execute implementation plan | developer |
| `/refactor {file}` | Refactor code | refactorer |
| `/document {scope}` | Update documentation | documenter |
| `/task {description}` | Execute generic task | task-executor |
| `/add {tasks}` | Add tasks to TODO | task-adder |
| `/todo {operation}` | Manage TODO.md | task-executor |
| `/meta {request}` | Create/modify agents or commands | meta |

---

## Key Features

### 1. Context Protection Architecture

All agents follow this pattern to prevent context window bloat:

1. **Receive**: Minimal context + task specification
2. **Delegate**: Route to specialist subagents
3. **Create**: Detailed artifacts in `.opencode/specs/NNN_project/`
4. **Return**: File references + brief summaries only
5. **Protect**: Orchestrator never loads full artifacts

See [ARCHITECTURE.md § Context Protection Pattern](ARCHITECTURE.md#context-protection-pattern) for details.

### 2. Three-Level Context Allocation

- **Level 1 (80%)**: 1-2 context files - simple, focused tasks
- **Level 2 (20%)**: 3-4 context files - moderate complexity
- **Level 3 (<5%)**: 4-6 context files - complex tasks requiring broad knowledge

See [ARCHITECTURE.md § Context Management](ARCHITECTURE.md#context-management) for allocation strategy.

### 3. Project-Based Artifact Management

```
.opencode/specs/NNN_project_name/
├── reports/         # Research, analysis, verification reports
├── plans/           # Implementation plans (versioned)
├── summaries/       # Brief summaries for quick reference
└── state.json       # Project state tracking
```

See [specs/README.md](specs/README.md) for artifact organization details.

### 4. Comprehensive Knowledge Base

| Domain | Location | Files | Documentation |
|--------|----------|-------|---------------|
| **Project** | `context/project/` | Varies | Project-specific knowledge |
| **Repository** | `context/repo/` | 3+ | Repository conventions |
| **System** | `context/common/` | 5+ | Core patterns and standards |
| **Templates** | `context/templates/` | 3+ | Meta-system templates |

**All context files follow consistent structure**: Overview, Core Concepts, Common Patterns, Examples, Business Rules, Pitfalls, Relationships.

See [context/README.md](context/README.md) for complete organization guide.

### 5. Tool Integration

| Tool | Purpose | Integration |
|------|---------|-------------|
| **Git/GitHub** | Version control | All implementation agents |
| **gh CLI** | GitHub issue management | todo-manager |
| **Web Search** | Research and documentation | researcher |
| **Language Tools** | Linters, formatters, test runners | developer, refactorer |

See [context/common/](context/common/) for tool integration patterns.

---

## Agent System

The system uses a three-tier architecture: **orchestrator** → **10 primary agents** → **19 specialist subagents**.

### Agent Hierarchy

**Orchestrator** (1): Main coordinator for all workflows and routing  
**Primary Agents** (10): Coordinate workflows and delegate to specialists  
**Specialist Subagents** (19): Perform focused technical tasks in functional categories

### Key Architectural Patterns

- **Context Protection**: Specialists create detailed artifacts, return only references
- **Hierarchical Delegation**: Orchestrator → Primary → Specialists
- **Artifact-Based Communication**: File references instead of full content passing
- **Specialist Coordination**: Primary agents coordinate multiple specialists for complex tasks

> **Complete Agent Catalog**: See [agent/README.md](agent/README.md) for all 10 primary agents and [agent/subagents/specialists/README.md](agent/subagents/specialists/README.md) for all 19 specialists organized by category.

---

## Context System

### Organization Principles

**Single Unified Directory**: All context files are in `context/` directory.

**Modular Design**: Files are 50-200 lines each, focused on specific topics.

**Just-in-Time Loading**: Agents load only necessary context files (3-level allocation).

**Consistent Structure**: All context files follow standard template with Overview, Concepts, Patterns, Examples, etc.

See [context/README.md](context/README.md) for complete organization guide.

### Key Context Areas

**Project Knowledge** (`context/project/`):
- Project-specific domain knowledge
- Custom workflows and processes
- Project standards and conventions

**Repository Conventions** (`context/repo/`):
- Project structure guidelines
- Artifact organization standards
- State management schemas

**System Knowledge** (`context/common/`):
- Core patterns and standards
- System workflows
- General development best practices

**Meta-System** (`context/templates/`):
- Agent templates
- Command templates
- Builder guides

---

## State Management

### Project State

Each project has state tracked in `.opencode/specs/NNN_project/state.json`:

```json
{
  "project_name": "bimodal_proof_system",
  "project_number": 1,
  "type": "implementation",
  "phase": "planning",
  "status": "active",
  "reports": ["reports/research-001.md"],
  "plans": ["plans/implementation-001.md"]
}
```

### Global State

System-wide state in `.opencode/specs/state.json` tracks active projects, completed projects, next project number.

### TODO Management

User-facing task list in `.opencode/specs/TODO.md` synchronized by todo-manager specialist.

See [specs/README.md](specs/README.md) for state management details.

---

## Performance & Quality

### Performance Characteristics

- **Context Efficiency**: 80% reduction vs. loading all context
- **Routing Accuracy**: >95% correct agent selection
- **Task Success Rate**: >95%
- **XML Optimization**: +17% overall performance improvement

See [ARCHITECTURE.md § Performance Characteristics](ARCHITECTURE.md#performance-characteristics) for benchmarks.

### Quality Standards

- **Code Quality**: All code tested and validated
- **Style Adherence**: Enforced by style-checker specialist
- **Documentation**: Complete, accurate, concise (enforced by doc-analyzer)
- **Git Commits**: Automatic commits for substantial changes

See [ARCHITECTURE.md § Quality Standards](ARCHITECTURE.md#quality-standards) for details.

---

## Extensibility

### Adding New Components

```bash
# Create new agent
/meta "Create agent that analyzes code performance and suggests optimizations"

# Create new command
/meta "Create command /optimize that runs performance analysis"

# Modify existing agent
/meta "Modify researcher agent to add support for technical documentation search"
```

### Adding Context

Simply create new files in `context/` following existing patterns and structure. See [context/README.md § Adding New Context](context/README.md#adding-new-context).

---

## Getting Started

1. **Quick Start**: See [QUICK-START.md](QUICK-START.md) for step-by-step usage guide
2. **System Testing**: See [TESTING.md](TESTING.md) for comprehensive testing checklist
3. **Architecture**: See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed system design
4. **Agent Reference**: See [agent/README.md](agent/README.md) for agent catalog
5. **Command Reference**: See [command/README.md](command/README.md) for all commands
6. **Context Guide**: See [context/README.md](context/README.md) for knowledge organization

---

## What Makes This System Special

### Research-Backed Design
- XML optimization from Stanford/Anthropic research (+25% consistency, +20% routing accuracy)
- Hierarchical agent patterns for efficiency
- Context protection for scalability
- Evidence-based 3-level context allocation (80/20/<5)

### Comprehensive Knowledge Base
- **10+ context files** for core system and project-specific knowledge
- **Consistent structure** with examples, patterns, pitfalls
- **Modular design** (50-200 lines per file) for easy maintenance
- **Just-in-time loading** for optimal performance

### Production-Ready Workflows
- **Complete development cycle**: research → plan → implement → verify → document
- **Version-controlled plans** with revision support
- **Automated verification** and git integration
- **State management** with TODO synchronization

### Intelligent Agent Coordination
- **30 total agents** (1 orchestrator + 10 primary + 19 specialists)
- **Context protection** prevents bloat
- **Reference-based communication** (not full artifact passing)
- **Specialist coordination** for complex tasks

---

## Support & Documentation

### Documentation Hierarchy

1. **README.md** - System overview and quick start
2. **QUICK-START.md** - Step-by-step usage guide
3. **ARCHITECTURE.md** - Detailed system architecture
4. **TESTING.md** - Testing checklist and procedures
5. **SYSTEM_SUMMARY.md** - This file (quick reference)

### Directory READMEs

- [agent/README.md](agent/README.md) - Agent system overview
- [agent/subagents/specialists/README.md](agent/subagents/specialists/README.md) - Specialist catalog
- [command/README.md](command/README.md) - Command reference
- [specs/README.md](specs/README.md) - Artifact organization
- [context/README.md](context/README.md) - Context organization

### Getting Help

1. Review relevant documentation files (linked above)
2. Check context files in `context/` for domain knowledge
3. Examine example artifacts in `specs/` for patterns
4. Use `/meta` to extend system with new agents or commands

---

**Your AI-powered development system is ready!**

---

**Generated**: December 2025  
**Version**: 3.0.0 (Generalized for software development)  
**For Project**: General-purpose AI agent system
