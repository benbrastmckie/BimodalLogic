# Context Loading Strategy

## Three-Tier Loading

### Tier 1: Orchestrator (Minimal)
**Budget**: <5% of context window (~10KB)

**Always Loaded**:
- core/system/routing-guide.md (routing rules, language mapping)
- core/workflows/delegation-guide.md (safety patterns)

**Purpose**: Enable routing decisions and delegation safety checks

### Tier 2: Commands (Targeted)
**Budget**: 10-20% of context window (~20-40KB)

**Loaded by Command**:
- core/standards/subagent-return-format.md (validate returns)
- core/workflows/status-transitions.md (status markers)
- Command-specific standards (e.g., plan-template.md for /plan)

**Purpose**: Enable command-specific validation and formatting

### Tier 3: Agents (Domain-Specific)
**Budget**: 60-80% of context window (~120-160KB)

**Loaded by Agent**:
- project/lean4/* (for lean-implementation-agent)
- project/logic/* (for logic-specific tasks)
- core/templates/* (for artifact generation)

**Purpose**: Enable domain-specific work with full context

## Loading Mechanism

Commands specify context in frontmatter:
```yaml
context_loading:
  strategy: lazy  # or eager
  required:
    - "core/standards/subagent-return-format.md"
  optional:
    - "core/standards/plan-template.md"
  max_context_size: 50000
```

Agents specify context in frontmatter:
```yaml
context_loading:
  strategy: lazy
  required:
    - "project/lean4/domain/lean4-syntax.md"
    - "project/lean4/tools/lsp-integration.md"
  optional:
    - "project/lean4/patterns/tactic-patterns.md"
  max_context_size: 150000
```

## Context Budget Enforcement

- Orchestrator: Enforce max_context_size from frontmatter
- Log warning if context exceeds budget
- Prioritize required over optional files
- Truncate optional files if needed to stay within budget

## File Organization

### core/standards/
Standard formats and templates that apply across all projects:
- subagent-return-format.md
- plan-template.md
- research-report-format.md
- task-format.md
- git-commit-format.md

### core/workflows/
Common workflow patterns and guides:
- delegation-guide.md
- status-transitions.md
- error-handling-patterns.md
- resume-workflow.md

### core/system/
System-level configuration and guides:
- routing-guide.md
- orchestrator-guide.md
- context-loading-strategy.md (this file)
- validation-strategy.md

### core/templates/
Reusable templates for creating new components:
- command-template.md
- agent-template.md
- context-file-template.md

### project/
Project-specific domain knowledge (ProofChecker):
- lean4/ - Lean 4 theorem proving
- logic/ - Modal and temporal logic
- math/ - Mathematical domains
- physics/ - Physics domains
- repo/ - Repository-specific knowledge
