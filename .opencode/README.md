# LEAN 4 ProofChecker - Context-Aware AI System

## Overview

Complete context-aware AI system for LEAN 4 theorem proving focused on bimodal logic development. Manages the full workflow from research through implementation to verification and documentation.

## System Architecture

### Main Orchestrator
- **lean4-orchestrator**: Coordinates all workflows, routes to specialized agents, manages context allocation

### Primary Agents (7)
1. **reviewer**: Repository analysis, proof verification, TODO management
2. **researcher**: Multi-source research (LeanExplore, Loogle, LeanSearch, web)
3. **planner**: Implementation planning with complexity analysis and dependency mapping
4. **proof-developer**: LEAN 4 proof implementation using lean-lsp-mcp
5. **refactorer**: Code quality improvement and style enforcement
6. **documenter**: Documentation maintenance (complete, accurate, concise)
7. **meta**: Agent and command creation/modification

### Specialist Subagents (16)
- **verification-specialist**, **todo-manager**
- **lean-search-specialist**, **loogle-specialist**, **web-research-specialist**
- **complexity-analyzer**, **dependency-mapper**
- **tactic-specialist**, **term-mode-specialist**, **metaprogramming-specialist**
- **style-checker**, **proof-simplifier**
- **doc-analyzer**, **doc-writer**
- **agent-generator**, **command-generator**

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

## Project Structure

```
.opencode/
├── agent/
│   ├── lean4-orchestrator.md
│   └── subagents/
│       ├── reviewer.md
│       ├── researcher.md
│       ├── planner.md
│       ├── proof-developer.md
│       ├── refactorer.md
│       ├── documenter.md
│       ├── meta.md
│       └── specialists/
│           └── [16 specialist subagents]
├── context/
│   ├── lean4/              # LEAN 4 knowledge
│   ├── logic/              # Logic knowledge (proof theory, semantics, metalogic)
│   ├── specs/              # Project management
│   └── builder-templates/  # Meta-system templates
├── command/
│   └── [7 custom commands]
├── specs/
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

- **ARCHITECTURE.md**: Detailed system architecture
- **QUICK-START.md**: Step-by-step usage guide
- **TESTING.md**: Testing checklist and procedures
- **context/README.md**: Context organization guide

## Support

For questions or issues:
1. Review relevant documentation files
2. Check context files for domain knowledge
3. Examine example artifacts in `.opencode/specs/`
4. Use `/meta` to extend the system with new agents or commands

---

**Your LEAN 4 theorem proving system is ready!** 🎉
