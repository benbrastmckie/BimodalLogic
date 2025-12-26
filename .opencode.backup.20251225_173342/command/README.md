---
description: "Command directory overview and standards"
context_level: 1
language: markdown
---

# Custom Commands

**Purpose**: User-facing command interface for AI agent workflows (research → plan → implement → review → maintain). All command docs follow the YAML front matter + XML/@subagent structure defined in `.opencode/context/common/standards/commands.md` and the template in `.opencode/context/common/templates/command-template.md`.

## Directory

- add.md — add tasks to TODO/state
- context.md — context navigation/help
- document.md — documentation maintenance
- implement.md — execute implementation plans
- lean.md — Lean-specific implementation orchestrator
- meta.md — create/modify agents and commands
- plan.md — create implementation plans
- refactor.md — code refactoring
- research.md — multi-source research
- review.md — repository review/verification
- revise.md — revise existing plans
- task.md — execute TODO tasks by number
- todo.md — display/manage TODO list

## Standards (must comply)
- YAML front matter: name, agent, description, context_level, language.
- Context Loaded list with `@` paths (minimal, precise).
- XML sections (ordered): `<context>`, `<role>`, `<task>`, `<workflow_execution>`, `<routing_intelligence>`, `<artifact_management>`, `<quality_standards>`, `<usage_examples>`, `<validation>`.
- Status markers and timestamps per `status-markers.md`.
- Lazy directory creation per `artifact-management.md` (only create roots/subdirs when writing artifacts; create the minimum subdir required).
- Language/Lean routing: TODO `Language` is authoritative; `--lang` overrides; plan `lean:` is secondary. Validate `lean-lsp` MCP before Lean execution.
- Registry/state sync: when commands change implementation status or sorry/tactic counts, also update TODO, `.opencode/specs/state.json`, IMPLEMENTATION_STATUS.md, SORRY_REGISTRY.md, and TACTIC_REGISTRY.md (skip on dry-run).
- No emojis anywhere in commands or artifacts.

## Usage Snapshot

| Command | Primary Agent | Context Level | Typical Scope |
|---------|---------------|---------------|---------------|
| /review | reviewer | 3 | Repo-wide analysis/verification |
| /research | researcher | 3 (broad) | Multi-source research |
| /plan | planner | 2 | Implementation plans |
| /revise | planner | 2 | Plan revisions |
| /implement | implementer | 2 | Execute plans |
| /task | orchestrator | 2 | Execute TODO tasks (batch-aware) |
| /add | task-adder | 1 | Add tasks to TODO/state |
| /todo | task-adder | 1 | Display/manage TODO list |
| /refactor | refactorer | 1-2 | Code refactoring |
| /document | documenter | 2 | Documentation updates |
| /lean | lean-implementation-orchestrator | 2 | Lean implementation |
| /meta | meta | 2 | Agent/command creation |
| /context | orchestrator | 1 | Context navigation/help |

## Migration Notes
- All command docs now use the YAML + XML structure and reference the new standard/template.
- Dry-runs/health-checks must not create project directories or write registries.
- Summaries must be emitted/updated when artifacts are produced and linked from TODO/state.
