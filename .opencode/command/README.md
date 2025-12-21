# Custom Commands

**Purpose**: User-facing command interface for AI agent workflows  
**Last Updated**: December 20, 2025

## Overview

Custom commands provide a streamlined interface for invoking AI agent
workflows. Each command routes to a specific primary agent with appropriate
context allocation and task-specific instructions. Commands follow a
consistent syntax pattern and handle common development workflows from
research through implementation to verification.

The command system abstracts the complexity of agent routing and context
management, providing users with simple, memorable commands for complex
multi-agent workflows.

## Directory Structure

All 12 commands are located in this directory:

- `add.md` - Add tasks to TODO.md with intelligent breakdown
- `document.md` - Documentation maintenance and updates
- `implement.md` - Execute implementation plans
- `lean.md` - LEAN 4 proof implementation
- `meta.md` - Create or modify agents and commands
- `plan.md` - Create implementation plans
- `refactor.md` - Code refactoring and quality improvement
- `research.md` - Multi-source research
- `review.md` - Repository analysis and verification
- `revise.md` - Revise existing implementation plans
- `task.md` - Execute TODO tasks
- `todo.md` - TODO management and display

## Quick Reference

| Command | Purpose | Agent | Syntax |
|---------|---------|-------|--------|
| /review | Repository analysis and verification | reviewer | `/review` |
| /research | Multi-source research | researcher | `/research "{topic}"` |
| /plan | Create implementation plan | planner | `/plan "{task}"` |
| /revise | Revise implementation plan | planner | `/revise {project_number}` |
| /lean | Implement LEAN 4 proof | proof-developer | `/lean {project_number}` |
| /refactor | Refactor code | refactorer | `/refactor {file_path}` |
| /document | Update documentation | documenter | `/document "{scope}"` |
| /meta | Create/modify agents/commands | meta | `/meta "{request}"` |
| /add | Add TODO tasks | task-adder | `/add "{task}"` |
| /todo | Display TODO list | task-adder | `/todo` |
| /task | Execute TODO task | task-executor | `/task {task_number}` |
| /implement | Execute implementation plan | implementation-orchestrator | `/implement {plan_path} [phase]` |

## Usage

### Basic Workflow

**1. Review repository state**
```bash
/review
```
Analyzes repository, verifies proofs, updates TODO.md with findings.

**2. Research a topic**
```bash
/research "Kripke semantics for bimodal logic"
```
Searches LEAN libraries (LeanSearch, Loogle) and web, creates comprehensive
research report.

**3. Create implementation plan**
```bash
/plan "Implement soundness proof for bimodal logic"
```
Analyzes complexity and dependencies, creates detailed step-by-step
implementation plan.

**4. Implement the plan**
```bash
/lean 001
```
Implements proof following plan, verifies with lean-lsp-mcp, commits to git.

**5. Refactor code**
```bash
/refactor Logos/Core/Semantics/Truth.lean
```
Improves code readability, enforces style guide, simplifies proofs.

**6. Update documentation**
```bash
/document "bimodal logic proof system"
```
Updates documentation to be complete, accurate, and concise.

### Advanced Workflows

**Plan revision cycle**
```bash
/plan "Implement decidability procedure"  # Creates implementation-001.md
/revise 004                               # Creates implementation-002.md
/revise 004                               # Creates implementation-003.md
```

**Task management**
```bash
/add "Prove soundness theorem for bimodal logic"  # Adds to TODO.md
/todo                                              # Displays TODO list
/task 63                                           # Executes task #63
```

**Meta-system operations**
```bash
/meta "Create specialist for proof search strategies"
/meta "Add command for batch proof verification"
```

## Command Structure

### Invocation Pattern

Commands follow consistent patterns:
- **No arguments**: `/review`, `/todo`
- **String argument**: `/research "{topic}"`, `/document "{scope}"`
- **Number argument**: `/lean {project_number}`, `/task {task_number}`
- **Path argument**: `/refactor {file_path}`
- **Mixed arguments**: `/implement {plan_path} [phase_number]`

### Routing Logic

1. **Command invoked** by user
2. **Orchestrator** parses command and arguments
3. **Routes** to appropriate primary agent
4. **Allocates** context based on command type
5. **Agent** executes workflow, delegates to specialists
6. **Returns** summary and artifact references to user

### Context Allocation

Commands automatically allocate appropriate context levels from `.opencode/context/`:
- **Level 1**: `/refactor`, `/document`, `/add`, `/todo` (focused, single-domain)
- **Level 2**: `/plan`, `/lean`, `/task`, `/implement` (multi-domain, moderate complexity)
- **Level 3**: `/review`, `/research` (comprehensive, complex analysis)

## Related Documentation

- [Main README](../README.md) - System overview
- [Agent System](../agent/README.md) - Agent architecture
- [QUICK-START.md](../QUICK-START.md) - Step-by-step usage guide
- [Context Guide](../context/README.md) - Context organization and usage

## Contributing

To add a new command:

1. Identify common workflow that needs streamlined interface
2. Determine which primary agent should handle the command
3. Use command template pattern from existing commands
4. Define command syntax and argument parsing
5. Document routing logic and context allocation
6. Add command entry to this README
7. Test command invocation and agent routing

Command files should include:
- Command description and purpose
- Syntax and argument specification
- Routing target (which agent)
- Context allocation level
- Example usage
- Expected artifacts and return values

See existing command files for examples and patterns.
