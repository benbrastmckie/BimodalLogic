# Meta Context README

## Purpose

System-building context for creating and modifying agents, commands, and workflows in the ProofChecker task management system. Use these files when extending the `.claude/` infrastructure or learning system design patterns.

## Files

| File | Content |
|------|---------|
| `meta-guide.md` | Complete guide for `/meta` command: interview patterns, output structure, XML optimization |
| `architecture-principles.md` | Design principles for agent hierarchies, tool selection, error handling |
| `context-revision-guide.md` | How to maintain and refactor context files; lazy loading patterns |
| `domain-patterns.md` | Templates for domain-specific context organization |
| `interview-patterns.md` | Structured interview techniques for requirements gathering |
| `standards-checklist.md` | Quality checklist for new agents and commands |

## When to Load

Load these files when:
- Creating new agents or commands via `/meta`
- Refactoring existing `.claude/` infrastructure
- Understanding system architecture decisions
- Designing new context hierarchies

## Related Context

- `project/processes/` - Workflow templates for research, planning, implementation
- `core/standards/` - Cross-project standards (commands.md, agents.md)
- `core/templates/` - Reusable templates for common artifacts
