# .opencode System

**Version**: 2.0  
**Status**: Active  
**Created**: 2025-12-26

---

## What is this?

The .opencode system is a task management and automation framework for software development projects, with specialized support for Lean 4 theorem proving. It provides structured workflows for research, planning, and implementation with built-in safety mechanisms and error tracking.

---

## Key Features

### Structured Task Management

- Create tasks with `/task`
- Conduct research with `/research`
- Create implementation plans with `/plan`
- Execute implementations with `/implement`
- Resume interrupted work automatically

### Delegation Safety

Version 2.0 includes comprehensive safety mechanisms to prevent delegation hangs and infinite loops:

- **Session ID Tracking**: Every delegation has a unique identifier
- **Cycle Detection**: Prevents infinite delegation loops
- **Depth Limits**: Maximum delegation depth of 3 levels
- **Timeout Enforcement**: All operations have timeouts with graceful degradation
- **Return Validation**: All subagent returns validated against standard format

### Atomic State Synchronization

Status changes are synchronized atomically across multiple files:

- TODO.md (user-facing task list)
- state.json (machine-readable state)
- Plan files (phase tracking)

Two-phase commit ensures consistency with rollback on failure.

### Language-Specific Routing

Tasks are automatically routed to appropriate agents based on language:

- **Lean tasks**: Use lean-lsp-mcp for compilation and diagnostics
- **General tasks**: Use standard development tools
- **Future**: Python, JavaScript, Rust-specific agents

### Error Tracking and Analysis

All errors logged to errors.json with:

- Error type and severity
- Context (command, task, agent)
- Fix status tracking
- Recurrence detection
- Automatic fix plan generation with `/errors`

### Automatic Git Commits

Git commits created automatically after:

- Task completion
- Phase completion
- Research completion
- Plan creation

Commits are scoped (only relevant files) with clear, formatted messages.

---

## Key Improvements Over Old System

Version 2.0 is a complete clean-break refactor addressing critical issues:

### 1. No More Delegation Hangs

**Old System**: Commands would invoke subagents but never receive results, causing indefinite hangs.

**New System**: Explicit return handling stages (ReceiveResults, ProcessResults) with timeout enforcement.

### 2. Cycle Detection

**Old System**: No cycle detection, could create infinite delegation loops.

**New System**: Delegation path tracking with cycle detection before routing.

### 3. Timeout Enforcement

**Old System**: No timeouts, indefinite waits possible.

**New System**: All delegations have timeouts (3600s default) with graceful degradation.

### 4. Standardized Returns

**Old System**: Inconsistent return formats, difficult to parse.

**New System**: All subagents follow standardized return format with validation.

### 5. Atomic Status Updates

**Old System**: Race conditions when updating TODO.md and state.json.

**New System**: Two-phase commit with rollback on failure.

### 6. Automatic Git Commits

**Old System**: No automatic commits, manual commit required.

**New System**: Automatic scoped commits with clear messages.

### 7. Error Tracking

**Old System**: No error tracking, issues lost.

**New System**: All errors logged to errors.json with analysis and fix planning.

### 8. Resume Support

**Old System**: Restart from scratch if interrupted.

**New System**: Automatic resume from last completed phase.

---

## Quick Start

### Create Your First Task

```
/task Implement feature X with Y functionality
```

Returns: `Created task 192`

### Simple Task (No Plan)

```
/implement 192
```

Executes implementation directly, creates git commit, marks complete.

### Complex Task (With Research and Plan)

```
/research 192
/plan 192
/implement 192
```

Research → Plan → Implement workflow with automatic status tracking.

### Resume Interrupted Work

```
/implement 192
```

If interrupted, run the same command again. The system automatically resumes from the last completed phase.

### Analyze Errors

```
/errors
```

Analyzes errors.json, creates fix plan, creates TODO task for fixes.

### Build Custom System Architecture

```
/meta "Create a system for managing e-commerce orders"
```

Launches an interactive interview process to:
- Gather domain and purpose information
- Identify use cases and workflows
- Design agent architecture (orchestrator + specialized subagents)
- Generate context files (domain knowledge, processes, standards, templates)
- Create custom commands and workflows
- Generate complete .opencode structure tailored to your domain

The system builder creates production-ready AI agent systems following research-backed patterns for optimal performance.

---

## Documentation

### Getting Started

- **Quick Start Guide**: [QUICK-START.md](QUICK-START.md)
  - Prerequisites
  - Common workflows
  - Command reference
  - Troubleshooting

### System Architecture

- **Architecture Guide**: [ARCHITECTURE.md](ARCHITECTURE.md)
  - System overview
  - Architecture principles
  - Component hierarchy
  - Delegation flow
  - State management
  - Git workflow

### Testing

- **Testing Guide**: [TESTING.md](TESTING.md)
  - Component testing
  - Integration testing
  - Delegation safety testing
  - Language routing testing
  - Error recovery testing

### Standards and Patterns

- **Delegation Guide**: [context/common/workflows/subagent-delegation-guide.md](context/common/workflows/subagent-delegation-guide.md)
  - Session ID tracking
  - Cycle detection
  - Timeout enforcement
  - Return validation

- **Return Format Standard**: [context/common/standards/subagent-return-format.md](context/common/standards/subagent-return-format.md)
  - Standardized return format
  - Field specifications
  - Validation requirements
  - Examples

---

## Commands

All commands include explicit argument parsing specifications that tell the orchestrator exactly how to extract parameters from user input. This ensures reliable command invocation with clear error messages.

### Task Management

- `/task <description>` - Create new task
  - Example: `/task Implement feature X`
- `/todo` - Clean completed tasks from TODO.md

### Research and Planning

- `/research <number> [prompt]` - Conduct research
  - Required: Task number (integer)
  - Optional: Additional context/focus
  - Example: `/research 197`
  - Example: `/research 197 "Focus on CLI integration"`
  
- `/plan <number> [prompt]` - Create implementation plan
  - Required: Task number (integer)
  - Optional: Planning context
  - Example: `/plan 196`
  - Example: `/plan 196 "Emphasize testing"`
  
- `/revise <number> [prompt]` - Revise existing plan
  - Required: Task number (integer)
  - Optional: Revision reason
  - Example: `/revise 196`
  - Example: `/revise 196 "Simplify approach"`

### Implementation

- `/implement <number> [prompt]` - Execute implementation
  - Required: Task number (integer)
  - Optional: Implementation context
  - Example: `/implement 196`
  - Example: `/implement 196 "Focus on error handling"`
  
- `/implement <start>-<end> [prompt]` - Execute range of tasks
  - Required: Task range (format: N-M)
  - Optional: Batch context
  - Example: `/implement 105-107`
  - Example: `/implement 105-107 "Batch implementation"`

### Analysis

- `/review` - Analyze codebase and update registries
- `/errors [--all] [--type <type>]` - Analyze errors and create fix plans

### System Building

- `/meta <domain_description>` - Interactive system builder to create custom .opencode architectures for new domains
  - Example: `/meta "Create a system for managing e-commerce orders"`

---

## Project Structure

```
.opencode/
├── agent/
│   ├── orchestrator.md              # Central coordination
│   └── subagents/                   # Worker agents
│       ├── atomic-task-numberer.md
│       ├── status-sync-manager.md
│       ├── researcher.md
│       ├── planner.md
│       ├── implementer.md
│       ├── task-executor.md
│       ├── lean-implementation-agent.md
│       ├── lean-research-agent.md
│       ├── error-diagnostics-agent.md
│       ├── git-workflow-manager.md
│       └── system-builder/          # System architecture generation
│           ├── agent-generator.md
│           ├── command-creator.md
│           ├── context-organizer.md
│           ├── domain-analyzer.md
│           └── workflow-designer.md
├── command/                         # User commands
│   ├── task.md
│   ├── research.md
│   ├── plan.md
│   ├── implement.md
│   ├── revise.md
│   ├── review.md
│   ├── todo.md
│   ├── errors.md
│   └── meta.md                      # System builder
├── context/                         # Context files
│   ├── common/                      # Common context
│   │   ├── standards/
│   │   ├── system/
│   │   ├── templates/
│   │   └── workflows/
│   └── project/                     # Project-specific context
│       ├── lean4/
│       ├── logic/
│       ├── math/
│       └── repo/
├── specs/                           # Task artifacts
│   ├── TODO.md                      # Task list
│   ├── state.json                   # Project state
│   ├── errors.json                  # Error tracking
│   └── {task_number}_{topic}/       # Per-task directories
│       ├── plans/
│       ├── reports/
│       └── summaries/
├── ARCHITECTURE.md                  # System architecture
├── QUICK-START.md                   # Quick start guide
├── TESTING.md                       # Testing guide
└── README.md                        # This file
```

---

## Status Markers

Tasks progress through these states:

1. `[NOT STARTED]` - Task created
2. `[IN PROGRESS]` - Task actively being worked on
3. `[RESEARCHED]` - Research completed (optional)
4. `[PLANNED]` - Plan created (optional)
5. `[COMPLETED]` - Task fully completed
6. `[ABANDONED]` - Task abandoned

---

## Language Support

### Lean 4

- Specialized agents: lean-implementation-agent, lean-research-agent
- Tool integration: lean-lsp-mcp for compilation and diagnostics
- Context loading: .opencode/context/project/lean4/
- Graceful degradation if tools unavailable

### General Development

- Languages: Markdown, Python, JavaScript, etc.
- Standard agents: researcher, implementer
- Future: Language-specific agents for Python, JavaScript, Rust

---

## Error Handling

All errors are logged to errors.json with:

- Error type (delegation_hang, timeout, status_sync_failure, etc.)
- Severity (critical, high, medium, low)
- Context (command, task, agent, session)
- Fix status tracking
- Recurrence detection

Use `/errors` to analyze patterns and create fix plans automatically.

---

## Git Workflow

### Automatic Commits

Commits created automatically after:
- Task completion
- Phase completion
- Research completion
- Plan creation

### Commit Message Format

- Per-phase: `task {number} phase {N}: {description}`
- Full task: `task {number}: {description}`
- Other: `{type}: {description}`

### Scoped Commits

Only relevant files committed:
- Implementation files
- Tracking files (TODO.md, state.json, plan file)
- Excludes unrelated changes

### Non-Blocking Failures

Git commit failures are logged but do NOT fail the task.

---

## Troubleshooting

### Delegation Hangs

Should not happen in v2.0. If it does, report as critical bug.

### Tool Unavailable

Lean agents fall back to direct file modification if lean-lsp-mcp unavailable.

### Git Commit Failures

Logged to errors.json but non-blocking. Manual commit if needed.

### Status Sync Failures

Retry logic with exponential backoff. Rollback on failure.

### Timeout During Implementation

Resume with `/implement {number}` to continue from last completed phase.

---

## Contributing

To extend the system:

1. **New Commands**: Add to `.opencode/command/`
2. **New Subagents**: Add to `.opencode/agent/subagents/`
3. **New Specialists**: Add to `.opencode/agent/subagents/specialists/`
4. **New Language Support**: Update orchestrator routing logic
5. **New Error Types**: Add to errors.json schema

Follow existing patterns and standards:
- Delegation guide for safety
- Return format standard for consistency
- Template files for structure

---

## Version History

### Version 2.0 (2025-12-26)

Complete clean-break refactor addressing Task 191 issues:

- Added delegation safety (session tracking, cycle detection, depth limits, timeouts)
- Standardized return format for all subagents
- Atomic status synchronization with two-phase commit
- Language-based routing (Lean vs general)
- Error tracking and analysis with /errors command
- Automatic git commits with scoped changes
- Resume support for interrupted implementations
- Comprehensive documentation (ARCHITECTURE, QUICK-START, TESTING)

### Version 1.0 (Previous)

Initial implementation (deprecated due to critical issues).

---

## License

See project LICENSE file.

---

## Support

For issues or questions:

1. Check [QUICK-START.md](QUICK-START.md) for common workflows
2. Review [ARCHITECTURE.md](ARCHITECTURE.md) for system details
3. Check errors.json for logged errors
4. Run `/errors` to analyze error patterns
5. Create a task to fix the issue

---

## Acknowledgments

Built on lessons learned from Task 191 analysis. Special thanks to the research and planning phases that identified root causes and guided the clean-break refactor.
