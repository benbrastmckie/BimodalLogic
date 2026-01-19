# Claude Agent System Documentation

[Back to ProofChecker](../../README.md) | [Architecture](../ARCHITECTURE.md) | [CLAUDE.md](../CLAUDE.md)

This documentation provides comprehensive coverage of the `.claude/` agent system for ProofChecker development.

---

## Documentation Map

```
.claude/docs/
├── README.md                    # This file - documentation hub
├── guides/                      # How-to guides
│   ├── user-installation.md    # Quick-start for new users
│   ├── copy-claude-directory.md # Copy .claude/ to another project
│   ├── component-selection.md  # When to create command vs skill vs agent
│   ├── creating-commands.md    # How to create commands
│   ├── creating-skills.md      # How to create skills
│   ├── creating-agents.md      # How to create agents
│   ├── context-loading-best-practices.md # Context loading patterns
│   └── permission-configuration.md # Permission setup
├── examples/                    # Integration examples
│   └── research-flow-example.md # End-to-end research flow
├── templates/                   # Reusable templates
│   ├── README.md               # Template overview
│   ├── command-template.md     # Command template
│   └── agent-template.md       # Agent template
├── architecture/               # Architecture documentation
│   ├── system-overview.md      # Three-layer architecture overview
│   └── orchestrator-workflow-execution-issue.md
├── troubleshooting/            # Problem resolution
│   └── status-conflicts.md     # Status sync issues
└── migrations/                 # Migration guides
    └── 001-openagents-migration/
```

---

## Quick Start

### For New Users

1. **[User Installation Guide](guides/user-installation.md)** - Start here! Install Claude Code, set up ProofChecker, and learn the basics.

2. **[Copy .claude/ Directory](guides/copy-claude-directory.md)** - Install the agent system in another project.

### Essential Commands

```bash
# Task Management
/task "Add new feature"          # Create new task
/task --sync                     # Sync TODO.md with state.json
/task --abandon 123              # Abandon task

# Development Workflow
/research 123                    # Research task
/plan 123                        # Create implementation plan
/implement 123                   # Execute implementation
/revise 123                      # Revise plan

# Maintenance
/review                          # Code review
/errors                          # Analyze errors
/todo                            # Archive completed tasks
/meta                            # System builder
```

### Key Paths

| Path | Description |
|------|-------------|
| `specs/TODO.md` | User-facing task list |
| `specs/state.json` | Machine-readable state |
| `specs/errors.json` | Error tracking |
| `specs/{N}_{SLUG}/` | Task artifacts |
| `.claude/commands/` | Slash command definitions |
| `.claude/skills/` | Specialized agent skills |
| `.claude/rules/` | Automatic behavior rules |
| `.claude/context/` | Domain knowledge and standards |

---

## System Overview

The `.claude/` directory implements a task management and automation system for ProofChecker development with Lean 4 and Mathlib.

### Core Components

| Component | Location | Purpose |
|-----------|----------|---------|
| Commands | `commands/` | User-invocable operations via `/command` |
| Skills | `skills/` | Specialized execution agents |
| Rules | `rules/` | Automatic behaviors based on paths |
| Context | `context/` | Domain knowledge and standards |
| Specs | `specs/` | Task artifacts and state |

### Architecture Principles

1. **Task-Based Workflow**: All work is tracked as numbered tasks
2. **Language-Based Routing**: Tasks route to specialized skills by language (Lean vs general)
3. **Atomic State Sync**: TODO.md and state.json stay synchronized
4. **Resume Support**: Interrupted work continues from checkpoint
5. **Git Integration**: Scoped commits after each operation

---

## Commands (9)

Commands are user-invocable operations triggered by `/command` syntax.

| Command | Purpose | Arguments |
|---------|---------|-----------|
| /task | Create, manage, sync tasks | `"description"` or flags |
| /research | Conduct research | `TASK_NUMBER [focus]` |
| /plan | Create implementation plans | `TASK_NUMBER` |
| /implement | Execute implementation | `TASK_NUMBER` |
| /revise | Revise plan | `TASK_NUMBER` |
| /review | Code review | `[scope]` |
| /errors | Analyze errors | (reads errors.json) |
| /todo | Archive completed tasks | (no args) |
| /meta | System builder | `[domain]` or flags |

See [`.claude/commands/`](../commands/) for command definitions.

---

## Skills (9)

Skills are specialized agents invoked by commands or the orchestrator. They use the **thin wrapper pattern** to delegate to agents.

### Core Skills

| Skill | Purpose |
|-------|---------|
| skill-orchestrator | Central routing and coordination |
| skill-status-sync | Atomic multi-file status updates |
| skill-git-workflow | Scoped git commits |

### Research Skills

| Skill | Agent |
|-------|-------|
| skill-researcher | general-research-agent |
| skill-lean-research | lean-research-agent |

### Implementation Skills

| Skill | Agent |
|-------|-------|
| skill-planner | planner-agent |
| skill-implementer | general-implementation-agent |
| skill-lean-implementation | lean-implementation-agent |
| skill-latex-implementation | latex-implementation-agent |

See [`.claude/skills/`](../skills/) for skill definitions.

---

## Agents (6)

Agents are execution components invoked by skills via the Task tool.

| Agent | Purpose |
|-------|---------|
| general-research-agent | Web/codebase research for general tasks |
| lean-research-agent | Lean 4/Mathlib research with MCP tools |
| planner-agent | Create phased implementation plans |
| general-implementation-agent | General file implementation |
| lean-implementation-agent | Lean proof implementation |
| latex-implementation-agent | LaTeX document implementation |

See [`.claude/agents/`](../agents/) for agent definitions.

---

## Task Lifecycle

```
[NOT STARTED] -> [RESEARCHING] -> [RESEARCHED]
                                      |
                                      v
                            [PLANNING] -> [PLANNED]
                                            |
                                            v
                                [IMPLEMENTING] -> [COMPLETED]
                                       |
                                       v
                                  [PARTIAL] (enables resume)

Any state -> [BLOCKED] (with reason)
Any state -> [ABANDONED] (moves to archive)
```

### Typical Development Cycle

```bash
# 1. Create task
/task "Prove modal distribution theorem"     # Creates task #351

# 2. Research
/research 351                       # Creates research report
/research 351 "Kripke semantics"   # With specific focus

# 3. Plan
/plan 351                           # Creates implementation plan

# 4. Implement
/implement 351                      # Executes with proof checking
# If interrupted: /implement 351    # Resumes from checkpoint

# 5. Archive when done
/todo                               # Archives completed tasks
```

---

## Language-Based Routing

Tasks route to specialized skills based on their `language` field:

| Language | Research Skill | Implementation Skill |
|----------|---------------|---------------------|
| `lean` | skill-lean-research | skill-lean-implementation |
| `general` | skill-researcher | skill-implementer |
| `meta` | skill-researcher | skill-implementer |

### Language Detection (for /task)

| Keywords in Description | Detected Language |
|------------------------|-------------------|
| lean, theorem, proof, lemma, Mathlib, tactic | lean |
| agent, command, skill, meta | meta |
| (default) | general |

---

## Lean 4 Integration

### MCP Tools (via lean-lsp server)

| Tool | Purpose |
|------|---------|
| `lean_goal` | Proof state at position (use often!) |
| `lean_diagnostic_messages` | Compiler errors/warnings |
| `lean_hover_info` | Type signatures and docs |
| `lean_completions` | IDE autocomplete |
| `lean_leansearch` | Natural language -> Mathlib |
| `lean_loogle` | Type pattern search |
| `lean_leanfinder` | Semantic concept search |
| `lean_multi_attempt` | Test tactics without editing |
| `lean_local_search` | Fast local declaration search |

### Search Decision Tree

1. "Does X exist locally?" -> lean_local_search
2. "I need a lemma that says X" -> lean_leansearch
3. "Find lemma with type pattern" -> lean_loogle
4. "What's the Lean name for concept X?" -> lean_leanfinder
5. "What closes this goal?" -> lean_state_search

---

## Artifacts

Tasks produce artifacts stored in `specs/{N}_{SLUG}/`:

### Directory Structure

```
specs/{N}_{SLUG}/
├── reports/
│   └── research-001.md         # Research report
├── plans/
│   └── implementation-001.md   # Implementation plan
└── summaries/
    └── implementation-summary-{DATE}.md
```

### Artifact Formats

| Type | Location | Purpose |
|------|----------|---------|
| Research Report | `reports/research-{NNN}.md` | Research findings |
| Implementation Plan | `plans/implementation-{NNN}.md` | Phased plan |
| Summary | `summaries/implementation-summary-{DATE}.md` | Completion summary |

### Placeholder Conventions

| Placeholder | Format | Usage |
|-------------|--------|-------|
| `{N}` | Unpadded | Task numbers, counts |
| `{NNN}` | 3-digit padded | Artifact versions |
| `{DATE}` | YYYYMMDD | Date stamps |
| `{SLUG}` | snake_case | Task slug |

See `.claude/rules/artifact-formats.md` for complete documentation.

---

## State Management

### Dual-File System

| File | Purpose | Format |
|------|---------|--------|
| `TODO.md` | User-facing task list | Markdown |
| `state.json` | Machine-readable state | JSON |

### Synchronization

Both files MUST stay synchronized. Updates use two-phase commit:

1. Read both files
2. Prepare updates in memory
3. Write state.json first (machine state)
4. Write TODO.md second (user-facing)
5. Rollback all on any failure

---

## Git Integration

### Commit Message Format

```
task {N}: {action} {description}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

### Commit Actions

| Operation | Commit Message |
|-----------|----------------|
| Create task | `task {N}: create {title}` |
| Complete research | `task {N}: complete research` |
| Create plan | `task {N}: create implementation plan` |
| Complete phase | `task {N} phase {P}: {phase_name}` |
| Complete implementation | `task {N}: complete implementation` |
| Archive tasks | `todo: archive {N} completed tasks` |

---

## Related Documentation

### For New Users
- [User Installation Guide](guides/user-installation.md) - Quick-start for Claude Code and ProofChecker
- [Copy .claude/ Directory](guides/copy-claude-directory.md) - Install agent system elsewhere

### System Architecture
- [System Overview](architecture/system-overview.md) - Three-layer architecture overview
- [ARCHITECTURE.md](../ARCHITECTURE.md) - Detailed system architecture
- [CLAUDE.md](../CLAUDE.md) - Quick reference entry point

### Component Development
- [Component Selection](guides/component-selection.md) - When to create command vs skill vs agent
- [Creating Commands](guides/creating-commands.md) - How to create commands
- [Creating Skills](guides/creating-skills.md) - How to create skills (thin wrapper pattern)
- [Creating Agents](guides/creating-agents.md) - How to create agents (execution components)
- [Context Loading](guides/context-loading-best-practices.md) - Context loading patterns

### Examples
- [Research Flow Example](examples/research-flow-example.md) - End-to-end command flow

### ProofChecker Documentation
- [README.md](../../README.md) - Main project documentation
- [docs/](../../docs/) - Project documentation

---

[Back to ProofChecker](../../README.md) | [Architecture](../ARCHITECTURE.md) | [CLAUDE.md](../CLAUDE.md)
