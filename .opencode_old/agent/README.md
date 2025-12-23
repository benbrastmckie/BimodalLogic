# Agent System

**Purpose**: AI agent orchestration and delegation system  
**Last Updated**: December 20, 2025

## Overview

The agent system provides hierarchical AI orchestration for LEAN 4 theorem
proving workflows. The orchestrator coordinates all workflows, routes tasks to
specialized primary agents, and manages context allocation to prevent context
window bloat. Primary agents delegate focused work to specialist subagents,
which create detailed artifacts and return only references and summaries.

This three-tier architecture (orchestrator → primary agents → specialists)
enables complex workflows while maintaining efficient context usage through
the context protection pattern.

## Directory Structure

- `orchestrator.md` - Main coordinator for all workflows and routing
- `subagents/` - Primary agents and specialist subagents
  - See [subagents/specialists/README.md](subagents/specialists/README.md)
    for specialist catalog

## Quick Reference

| Agent | Purpose | Routing Pattern |
|-------|---------|-----------------|
| orchestrator | Main coordinator | Routes to primary agents |
| reviewer | Repository analysis | Routes to verification, TODO specialists |
| researcher | Multi-source research | Routes to search specialists |
| planner | Implementation planning | Routes to complexity, dependency specialists |
| proof-developer | LEAN 4 proof implementation | Routes to proof specialists |
| refactorer | Code quality improvement | Routes to style, refactoring specialists |
| documenter | Documentation maintenance | Routes to doc specialists |
| meta | Agent/command creation | Routes to generator specialists |
| task-executor | TODO task execution | Routes based on task type |
| task-adder | TODO task management | Routes to complexity, TODO specialists |
| implementer | General implementation | Routes to appropriate specialists |
| batch-task-orchestrator | Batch task execution | Routes to dependency, status specialists |
| implementation-orchestrator | Plan execution | Routes to implementer |

## Usage

### Agent Invocation

Agents are invoked through custom commands or direct routing:

```bash
/review              # Routes to reviewer agent
/research "topic"    # Routes to researcher agent
/plan "task"         # Routes to planner agent
/lean 001            # Routes to proof-developer agent
```

### Routing Logic

1. **Orchestrator** receives user request
2. **Analyzes** request type and complexity
3. **Allocates** appropriate context level (1-3)
4. **Routes** to primary agent with context references
5. **Primary agent** delegates to specialists as needed
6. **Specialists** create artifacts, return references
7. **Orchestrator** receives summary and presents to user

### Context Protection

All agents follow the context protection pattern:
- Receive context file references from `.opencode/context/` (not full content)
- Load only necessary context files
- Create detailed artifacts in `.opencode/specs/`
- Return file references + brief summaries

## Related Documentation

- [Main README](../README.md) - System overview
- [Specialist Catalog](subagents/specialists/README.md) - 32 specialist subagents
- [ARCHITECTURE.md](../ARCHITECTURE.md) - Detailed architecture
- [Builder Templates](../context/templates/README.md) - Agent creation guides

## Contributing

To add a new agent:

1. Determine agent type (primary agent vs. specialist)
2. Use appropriate template from
   [templates/](../context/templates/)
3. Define routing patterns and context allocation
4. Document specialist delegation if applicable
5. Update this README with new agent entry
6. Test routing and context protection

See [BUILDER-GUIDE.md](../context/templates/BUILDER-GUIDE.md) for
detailed instructions.
