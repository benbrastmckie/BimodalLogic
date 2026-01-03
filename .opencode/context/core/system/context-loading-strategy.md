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

---

## Directory Structure

The `.opencode/context/` directory is organized into top-level directories:

- `core/`: Contains context files that are common across all repositories and not specific to any single project. This is for universal, boilerplate context.
- `project/`: Contains context files that are specific to the current repository. This allows for project-specific context without cluttering the common context.

### Core Directory Structure

The `core/` directory contains subdirectories for different types of common context:

- `core/standards/`: Defines standards for code, documentation, testing, and analysis.
- `core/system/`: Contains general system-level context, such as this guide, artifact management, and state schemas.
- `core/templates/`: Provides templates for agents, orchestrators, and other system components.
- `core/workflows/`: Outlines standard workflows for delegation, review, and task breakdown.

### Project-Specific Directory Structure

The `project/` directory contains subdirectories that are specific to the needs of the project. These directories are generally topic-specific and not predefined, with the exception of the `repo` directory.

- **Topic-Specific Directories**: These directories contain context for specific domains. Examples in this project include:
  - `project/lean4/`: For projects related to Lean 4.
  - `project/logic/`: For projects involving formal logic.
  - `project/math/`: For mathematical domain knowledge.
  - `project/physics/`: For physics-related concepts.

- **`project/repo/`**: This directory is a standard project-specific directory that contains context related to the repository itself, such as the project overview.

This structure provides a clear separation between common and project-specific context, making it easier to manage and scale the context files.

---

## Context File References

Commands and agents reference context files using the `@` prefix in their context loading sections:

```markdown
Context Loaded:
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@.opencode/context/core/system/state-management.md
```

---

## Self-Healing Infrastructure

The OpenCode system implements **automatic self-healing** for missing infrastructure files. When a command needs state.json or errors.json and they don't exist, they are automatically created from templates using data from .opencode/specs/TODO.md.

**File Types**:
- **Auto-Created**: state.json, errors.json (created from templates)
- **Required**: .opencode/specs/TODO.md, context files (fail with clear error if missing)
- **Optional**: Project-specific configs (skip if missing)

**User Experience**: On first run or after file deletion, you'll see:
```
Note: Created .opencode/specs/state.json from template
Initialized with 37 tasks from .opencode/specs/TODO.md
```

**For Details**: See `.opencode/context/core/system/self-healing-guide.md`

---

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
