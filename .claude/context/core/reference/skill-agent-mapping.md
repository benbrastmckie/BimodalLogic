# Skill-to-Agent Mapping

Reference for skill delegation and language-based routing.

## Core Mappings

| Skill | Agent | Purpose |
|-------|-------|---------|
| skill-lean-research | lean-research-agent | Lean 4/Mathlib research |
| skill-lean-implementation | lean-implementation-agent | Lean proof implementation |
| skill-researcher | general-research-agent | General web/codebase research |
| skill-planner | planner-agent | Implementation plan creation |
| skill-implementer | general-implementation-agent | General file implementation |
| skill-latex-implementation | latex-implementation-agent | LaTeX document implementation |
| skill-typst-implementation | typst-implementation-agent | Typst document implementation |
| skill-meta | meta-builder-agent | System building and task creation |
| skill-document-converter | document-converter-agent | Document format conversion |
| skill-status-sync | (direct execution) | Atomic status updates |
| skill-refresh | (direct execution) | Process and file cleanup |
| skill-lake-repair | (direct execution) | Build with error repair |
| skill-team-research | (team lead) | Multi-agent parallel research |
| skill-team-plan | (team lead) | Multi-agent parallel planning |
| skill-team-implement | (team lead) | Multi-agent parallel implementation |

## Language Routing

Commands route to skills based on task language:

| Language | Research Skill | Implementation Skill |
|----------|---------------|---------------------|
| `lean` | skill-lean-research | skill-lean-implementation |
| `latex` | skill-researcher | skill-latex-implementation |
| `typst` | skill-researcher | skill-typst-implementation |
| `general` | skill-researcher | skill-implementer |
| `meta` | skill-researcher | skill-implementer |
| `markdown` | skill-researcher | skill-implementer |

## Team Skill Language Routing

Team skills route teammates to language-appropriate agents and models:
- For Lean tasks: teammates use lean-research-agent/lean-implementation-agent patterns
- Teammates have access to lean-lsp MCP tools and blocked tool warnings
- See `.claude/utils/team-wave-helpers.md#language-routing-pattern` for full configuration

## Team Skill Model Defaults

| Language | Default Model | Rationale |
|----------|---------------|-----------|
| `lean` | Opus | Complex theorem proving benefits from most capable model |
| `latex` | Sonnet | Document generation well-handled by Sonnet |
| `typst` | Sonnet | Similar to LaTeX |
| `meta` | Sonnet | System tasks well-handled by Sonnet |
| `general` | Sonnet | Consistent model for all non-Lean tasks |

Model is enforced via TeammateTool `model` parameter. Prompt text provides secondary guidance.

## Direct Execution Skills

Some skills execute directly without delegating to an agent:
- **skill-status-sync**: Atomic TODO.md + state.json updates
- **skill-refresh**: Process cleanup and file management
- **skill-lake-repair**: Build with automatic error repair loop
