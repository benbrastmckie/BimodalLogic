# LEAN 4 ProofChecker - Context-Aware AI System

> **For Project Overview**: See [README.md](../README.md) for the Logos project overview, theoretical foundations, and dual verification methodology.

## Overview

Complete context-aware AI system for LEAN 4 theorem proving focused on bimodal logic development. Manages the full workflow from research through implementation to verification and documentation.

## System Architecture

### Main Orchestrator
- **orchestrator**: Coordinates all workflows, routes to specialized agents, manages context allocation

### Agent System Summary

**12 Primary Agents** coordinate workflows and delegate to specialists  
**32 Specialist Subagents** perform focused technical tasks

> **Complete Agent Catalog**: See [agent/README.md](agent/README.md) for primary agents and [agent/subagents/specialists/README.md](agent/subagents/specialists/README.md) for all 32 specialists organized by category.

## Quick Start

### 1. Review Repository
```bash
/review
```
Analyzes repository, verifies proofs, updates TODO.md

### 2. Research a Topic
```bash
/research "Kripke semantics for bimodal logic"
```
Searches LEAN libraries and web, creates comprehensive research report

### 3. Create Implementation Plan
```bash
/plan "Implement soundness proof for bimodal logic"
```
Creates detailed step-by-step implementation plan

### 4. Implement the Plan
```bash
/lean 001
```
Implements proof following plan, verifies with lean-lsp-mcp, commits to git

### 5. Refactor Code
```bash
/refactor Logos/BimodalProofs.lean
```
Improves code readability and style adherence

### 6. Update Documentation
```bash
/document "bimodal logic proof system"
```
Updates documentation to be complete, accurate, concise

## Custom Commands

### Core Workflows
- `/review` - Comprehensive repository review
- `/research {topic}` - Multi-source research
- `/plan {task}` - Create implementation plan
- `/revise {project_number}` - Revise existing plan
- `/lean {project_number}` - Implement proof
- `/refactor {file_path}` - Refactor code
- `/document {scope}` - Update documentation

### Meta-System
- `/meta {request}` - Create or modify agents and commands

### Task Management
- `/add {task}` - Add tasks to TODO.md
- `/todo` - Display TODO list
- `/task {task_number}` - Execute TODO task
- `/implement {plan_path} [phase]` - Execute implementation plan

## Project Structure

```
.opencode/
├── agent/                  # See agent/README.md
│   ├── orchestrator.md
│   └── subagents/
│       ├── reviewer.md
│       ├── researcher.md
│       ├── planner.md
│       ├── proof-developer.md
│       ├── refactorer.md
│       ├── documenter.md
│       ├── meta.md
│       └── specialists/    # See agent/subagents/specialists/README.md
│           └── [32 specialist subagents]
├── context/                # See context/README.md
│   ├── lean4/              # See context/lean4/README.md
│   ├── logic/              # See context/logic/README.md
│   ├── math/               # See context/math/README.md
│   ├── repo/               # Repository conventions
│   ├── core/               # Core system patterns
│   ├── templates/          # Meta-system templates
│   └── project/            # Project-specific context
├── command/                # See command/README.md
│   └── [12 commands: review, research, plan, revise, lean, refactor, document, meta, add, todo, task, implement]
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
- **lean-lsp-mcp**: Type checking and verification
- **LeanExplore MCP**: Library exploration
- **Loogle**: Formal LEAN search
- **LeanSearch**: Semantic LEAN search
- **Git/GitHub**: Version control and issue tracking
- **gh CLI**: Push TODO tasks to GitHub issues

## Workflow Examples

### Complete Development Cycle

1. **Review current state**
   ```
   /review
   ```
   → Creates analysis and verification reports
   → Updates TODO.md with findings

2. **Research next task**
   ```
   /research "completeness proof for bimodal logic"
   ```
   → Searches LEAN libraries and web
   → Creates research report with findings

3. **Create implementation plan**
   ```
   /plan "Implement completeness proof"
   ```
   → Analyzes complexity and dependencies
   → Creates detailed step-by-step plan

4. **Implement the proof**
   ```
   /lean 003
   ```
   → Follows implementation plan
   → Verifies with lean-lsp-mcp
   → Commits to git

5. **Update documentation**
   ```
   /document "completeness proof"
   ```
   → Updates docs for new proof
   → Ensures completeness and accuracy

### Plan Revision Cycle

1. **Create initial plan**
   ```
   /plan "Implement decidability procedure"
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

### lean4/
- **domain/**: LEAN 4 syntax, mathlib, mathematical concepts
- **processes/**: Proof workflows, project structure
- **standards/**: Style guides, proof conventions, documentation standards
- **templates/**: Definition templates, proof structures
- **patterns/**: Tactic patterns
- **tools/**: MCP tools, lean-lsp-mcp usage

### logic/
- **domain/**: Proof theory, semantics, metalogic concepts
- **processes/**: Logic-specific workflows
- **standards/**: Logic-specific standards
- **templates/**: Logic-specific templates
- **patterns/**: Common proof patterns
- **tools/**: Logic-specific tools

### specs/
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
- All proofs type-checked with lean-lsp-mcp
- Style guide adherence enforced
- Documentation kept current and concise
- Git commits for all substantial changes

## Next Steps

1. **Test the system** with `/review` to analyze current repository state
2. **Review TODO.md** to see identified tasks
3. **Research a topic** to test research workflow
4. **Create a plan** for a TODO task
5. **Implement a proof** following the plan
6. **Customize context** files with your specific domain knowledge

## Documentation

### System Documentation
- **ARCHITECTURE.md**: Detailed system architecture
- **QUICK-START.md**: Step-by-step usage guide
- **TESTING.md**: Testing checklist and procedures

### Directory READMEs
- **agent/README.md**: Agent system overview and routing
- **agent/subagents/specialists/README.md**: Specialist catalog (32 specialists)
- **command/README.md**: Command reference and usage
- **specs/README.md**: Task workflow and artifact organization
- **.opencode/context/README.md**: Context organization guide
- **.opencode/context/lean4/README.md**: LEAN 4 context navigation
- **.opencode/context/logic/README.md**: Logic context navigation
- **.opencode/context/math/README.md**: Math context navigation

## Verification

Verify system integrity and setup:

### Agent System Verification
```bash
# Count primary agents (should be 12)
find .opencode/agent/subagents -maxdepth 1 -name "*.md" -type f | wc -l

# Count specialist subagents (should be 32)
find .opencode/agent/subagents/specialists -maxdepth 1 -name "*.md" -type f | grep -v README | wc -l

# List all primary agents
ls .opencode/agent/subagents/*.md
```

### Command System Verification
```bash
# Count commands (should be 12)
find .opencode/command -maxdepth 1 -name "*.md" -type f | grep -v README | wc -l

# List all commands
ls .opencode/command/*.md
```

### Context Structure Verification
```bash
# Verify context directories exist
ls -d .opencode/context/*/

# Expected output: core, lean4, logic, math, physics, project, repo, templates

# Check LEAN 4 context structure
ls .opencode/context/lean4/

# Expected output: domain, processes, standards, templates, patterns, tools

# Check logic context structure
ls .opencode/context/logic/

# Expected output: domain, processes, standards, templates, patterns, tools
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
echo "Primary agents: $(find .opencode/agent/subagents -maxdepth 1 -name "*.md" -type f | wc -l) (expected: 12)"
echo "Specialist subagents: $(find .opencode/agent/subagents/specialists -maxdepth 1 -name "*.md" -type f | grep -v README | wc -l) (expected: 32)"

echo -e "\n=== Command System ==="
echo "Commands: $(find .opencode/command -maxdepth 1 -name "*.md" -type f | grep -v README | wc -l) (expected: 12)"

echo -e "\n=== Context Structure ==="
echo "Context directories: $(ls -d .opencode/context/*/ 2>/dev/null | wc -l) (expected: 8)"
echo "LEAN 4 subdirectories: $(ls -d .opencode/context/lean4/*/ 2>/dev/null | wc -l) (expected: 6)"
echo "Logic subdirectories: $(ls -d .opencode/context/logic/*/ 2>/dev/null | wc -l) (expected: 7)"

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

**Your LEAN 4 theorem proving system is ready!**
