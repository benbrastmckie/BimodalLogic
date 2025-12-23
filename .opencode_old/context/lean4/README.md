# LEAN 4 Context

**Purpose**: LEAN 4 language and theorem proving knowledge for AI agents  
**Last Updated**: December 20, 2025

## Overview

This directory provides LEAN 4 specific knowledge for AI agents working on
theorem proving tasks. It contains workflows, templates, and best practices
for LEAN 4 development, focusing on practical guidance for proof
implementation, project structure, and maintenance operations.

The context is organized to support agents at different stages of the
development workflow, from initial proof planning through implementation to
maintenance and refactoring. Agents use this context to understand LEAN 4
syntax, mathlib organization, and project-specific conventions.

## Organization

This directory is organized into:

### processes/

Workflow guides for LEAN 4 development processes.

**Files**:
- `maintenance-workflow.md` - Repository maintenance procedures, cleanup
  operations, and periodic review workflows

### templates/

Boilerplate templates for LEAN 4 artifacts.

**Files**:
- `maintenance-report-template.md` - Template for maintenance operation
  reports and documentation

## Quick Reference

| Concept/Topic | File | Subdirectory |
|---------------|------|--------------|
| Maintenance workflow | maintenance-workflow.md | processes/ |
| Maintenance reports | maintenance-report-template.md | templates/ |

**Note**: This directory is currently focused on maintenance workflows. For
comprehensive LEAN 4 knowledge including syntax, mathlib, proof patterns, and
style guides, see the parent [context/](../README.md) directory which
references additional LEAN 4 resources.

## Usage by Agents

### Primary Users

- **proof-developer**: Uses maintenance workflows for code organization
- **refactorer**: Uses maintenance workflows for cleanup operations
- **implementer**: Uses templates for maintenance reports
- **reviewer**: Uses maintenance workflows for periodic reviews

### Context Allocation

- **Level 1**: Single file (maintenance-workflow.md for specific operations)
- **Level 2**: Both files (comprehensive maintenance context)
- **Level 3**: Rarely needed (maintenance is typically focused)

### Common Usage Patterns

**Maintenance Operations**:
1. Agent receives maintenance task
2. Loads `processes/maintenance-workflow.md`
3. Follows workflow steps
4. Creates report using `templates/maintenance-report-template.md`
5. Returns report reference and summary

## Adding New Context

### When to Add

- New LEAN 4 workflow identified (proof development, testing, etc.)
- New template needed for common artifacts
- New best practices or conventions established
- New tool integration requires documentation

### Where to Add

- **Workflows**: Add to `processes/` subdirectory
- **Templates**: Add to `templates/` subdirectory
- **Standards**: Consider adding `standards/` subdirectory for style guides
- **Patterns**: Consider adding `patterns/` subdirectory for common patterns

### Guidelines

- Keep files focused (50-200 lines)
- Use concrete examples
- Include verification procedures
- Link to related context files
- Follow documentation-standards.md format

### Planned Additions

Based on parent context organization, planned additions include:
- `domain/` - LEAN 4 syntax, mathlib overview, key concepts
- `standards/` - Style guides, proof conventions, documentation standards
- `patterns/` - Tactic patterns, proof patterns
- `tools/` - MCP tools guide, lean-lsp-mcp usage

## Related Context

- [Parent Context README](../README.md) - Overall context organization
- [Logic Context](../logic/README.md) - Logic theory knowledge
- [Math Context](../math/README.md) - Mathematical domain knowledge
- [Core Standards](../core/standards/) - System-wide quality standards
- [Builder Templates](../templates/README.md) - Meta-system templates

## External Resources

- [LEAN 4 Documentation](https://leanprover.github.io/lean4/doc/)
- [Mathlib4 Documentation](https://leanprover-community.github.io/mathlib4_docs/)
- [Mathematics in Lean](https://leanprover-community.github.io/mathematics_in_lean/)
- [Theorem Proving in Lean 4](https://leanprover.github.io/theorem_proving_in_lean4/)
