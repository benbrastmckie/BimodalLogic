# Specialist Subagents

**Purpose**: Specialized agents for focused technical tasks  
**Last Updated**: December 20, 2025

## Overview

Specialist subagents perform focused technical work delegated by primary
agents. Each specialist handles a specific domain (proof development, code
quality, documentation, research, etc.) and follows the context protection
pattern: receive minimal context, create detailed artifacts in
`.opencode/specs/`, and return only file references and brief summaries.

This architecture protects the orchestrator's context window while preserving
all detailed work in artifacts. Specialists are organized into 10 functional
categories for easy discovery and logical delegation patterns.

## Available Specialists

### Proof Development
- **tactic-specialist.md** - Implements tactic-based LEAN 4 proofs using
  common proof tactics
- **term-mode-specialist.md** - Implements term-mode LEAN 4 proofs using
  type-guided construction
- **metaprogramming-specialist.md** - Implements custom tactics and
  metaprogramming in LEAN 4
- **proof-strategy-advisor.md** - Suggests high-level proof strategies and
  generates proof skeletons
- **tactic-recommender.md** - Suggests relevant tactics based on proof goal
  state and context

### Code Quality
- **code-reviewer.md** - Automated code review for LEAN 4 using multiple
  specialist checks
- **style-checker.md** - Checks LEAN 4 code adherence to style guide and
  coding conventions
- **refactoring-assistant.md** - Safe refactoring operations for LEAN 4 code
- **syntax-validator.md** - Real-time syntax validation and error detection
  through LSP integration

### Documentation
- **doc-analyzer.md** - Analyzes documentation gaps and bloat for LEAN 4 code
  and project docs
- **doc-writer.md** - Writes and updates documentation for LEAN 4 code and
  project documentation
- **documentation-generator.md** - Auto-generates documentation for LEAN 4
  code
- **concept-explainer.md** - Generates natural language explanations of LEAN 4
  concepts

### Research
- **lean-search-specialist.md** - Semantic search of LEAN libraries using
  LeanSearch MCP
- **loogle-specialist.md** - Formal search of LEAN libraries using type
  signatures via Loogle API
- **web-research-specialist.md** - Web research for mathematical concepts,
  papers, and documentation

### Analysis
- **complexity-analyzer.md** - Analyzes task complexity and estimates effort
  for implementation planning
- **dependency-analyzer.md** - Analyzes module dependencies and suggests
  optimizations
- **dependency-mapper.md** - Maps dependencies and required imports for LEAN 4
  implementations
- **performance-profiler.md** - Profiles LEAN 4 proof compilation performance
  and identifies bottlenecks
- **verification-specialist.md** - Verifies LEAN 4 proofs against standards
  and conventions

### Workflow
- **git-workflow-manager.md** - Git workflow automation and repository
  management
- **todo-manager.md** - Manages TODO.md updates based on review findings and
  project progress
- **batch-status-manager.md** - Manages TODO.md updates atomically, tracks
  batch execution state

### Testing
- **test-generator.md** - Generates tests and counterexamples for LEAN 4
  theorems
- **example-builder.md** - Generates illustrative examples for LEAN 4
  theorems, definitions, and tactics

### Learning
- **learning-path-generator.md** - Generates personalized learning paths for
  LEAN 4 concepts
- **library-navigator.md** - Searches and navigates theorem libraries using
  Loogle and LeanSearch

### Optimization
- **proof-optimizer.md** - Analyzes and optimizes existing LEAN 4 proofs for
  size and performance
- **proof-simplifier.md** - Identifies opportunities to simplify LEAN 4 proofs
  and suggests improvements
- **error-diagnostics.md** - Categorizes errors and suggests fixes for LEAN 4
  diagnostics

### Task Management
- **task-dependency-analyzer.md** - Analyzes task dependencies, builds DAG,
  detects cycles, performs topological sort

## Specialist Categories

Specialists are organized by function and workflow stage to facilitate
discovery and delegation. The categorization strategy groups specialists by
what they do (proof development, code quality) and when they're needed in the
development workflow.

**Category Descriptions**:
1. **Proof Development**: Core proof implementation using tactics, term-mode,
   and metaprogramming
2. **Code Quality**: Style checking, review, refactoring, and syntax
   validation
3. **Documentation**: Analysis, writing, generation, and explanation of
   documentation
4. **Research**: Library search (semantic and formal) and web research for
   mathematical concepts
5. **Analysis**: Complexity, dependency, performance analysis and verification
6. **Workflow**: Git automation, TODO management, and batch status tracking
7. **Testing**: Test and example generation for theorems and definitions
8. **Learning**: Learning path generation and library navigation assistance
9. **Optimization**: Proof optimization, simplification, and error diagnostics
10. **Task Management**: Task dependency analysis and workflow orchestration

## Using Specialists

### Invocation Pattern

Specialists are invoked by primary agents, not directly by users:

1. **Primary agent** receives task from orchestrator
2. **Analyzes** task and determines which specialists are needed
3. **Routes** to specialist with focused context and specific instructions
4. **Specialist** creates detailed artifact in `.opencode/specs/NNN_project/`
5. **Returns** artifact file path and brief summary (2-5 sentences)
6. **Primary agent** aggregates specialist results and returns to orchestrator

### Context Allocation

Specialists receive minimal, focused context:
- **Level 1**: Single domain file (most common)
- **Level 2**: 2-3 related files (moderate complexity)
- **Level 3**: Rarely used by specialists

### Artifact Creation

All specialists create artifacts following standard patterns:
- **Reports**: `reports/{type}-{NNN}.md` (research, analysis, verification)
- **Plans**: `plans/implementation-{NNN}.md` (versioned plans)
- **Summaries**: `summaries/{type}-summary.md` (brief overviews)

### Return Value Pattern

Specialists return structured summaries:
```json
{
  "artifact_path": ".opencode/specs/066_project/reports/research-001.md",
  "summary": "Brief 2-5 sentence summary of findings",
  "key_findings": ["Finding 1", "Finding 2"],
  "status": "completed"
}
```

## Adding New Specialists

To create a new specialist:

1. Identify focused, reusable technical task
2. Determine appropriate category
3. Use [subagent-template.md](../../../context/templates/subagent-template.md)
4. Define artifact creation pattern
5. Document return value format
6. Test context protection (returns references, not full artifacts)
7. Update this README with new specialist entry

See [BUILDER-GUIDE.md](../../../context/templates/BUILDER-GUIDE.md)
for detailed instructions on creating specialists.

## Related Documentation

- [Parent Agent README](../README.md) - Agent system overview
- [Orchestrator](../../orchestrator.md) - Main coordinator
- [Builder Templates](../../../context/templates/README.md) - Creation
  guides
- [Context Guide](../../../context/core/system/context-guide.md) - Context
  management
