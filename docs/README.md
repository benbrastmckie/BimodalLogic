# ProofChecker Documentation

Project-wide documentation hub for the ProofChecker formal verification project.

> **For AI-Assisted Development**: See [.claude/README.md](../.claude/README.md) for the
> Claude Code configuration and task management system.

## Framework Overview

ProofChecker implements formal logic theories in Lean 4 with shared infrastructure for syntax, proof systems, semantics, and metalogic. The project's primary focus is **Logos**, a hyperintensional logic supporting layered extensions for explanatory, epistemic, and normative reasoning.

**Bimodal** provides a complete intensional logic (TM bimodal) that serves as an excellent starting point for newcomers and a comparison baseline demonstrating what purely intensional semantics can and cannot express.

The contrast between theories illuminates the power of hyperintensional semantics for distinguishing necessarily equivalent propositions.

**Getting Started**: Newcomers may find it helpful to start with Bimodal to understand modal-temporal reasoning, then explore Logos's hyperintensional extensions for more expressive capabilities.

## Theory-Specific Documentation

For documentation specific to each logic theory, see:

| Theory | Description | Documentation |
|--------|-------------|---------------|
| **Logos** (primary) | Second-order hyperintensional logic | [Logos/docs/](../Logos/docs/) |
| **Bimodal** | Propositional intensional logic (complete) | [Bimodal/docs/](../Bimodal/docs/) |

### Quick Access by Need

| Need | Bimodal | Logos |
|------|---------|-------|
| Quick start | [Quick Start](../Bimodal/docs/user-guide/QUICKSTART.md) | [Quick Start](../Logos/docs/user-guide/QUICKSTART.md) |
| Axiom reference | [Axioms](../Bimodal/docs/reference/AXIOM_REFERENCE.md) | [Axioms](../Logos/docs/reference/AXIOM_REFERENCE.md) |
| Implementation status | [Status](../Bimodal/docs/project-info/IMPLEMENTATION_STATUS.md) | [Status](../Logos/docs/project-info/IMPLEMENTATION_STATUS.md) |
| Known limitations | [Limitations](../Bimodal/docs/project-info/KNOWN_LIMITATIONS.md) | [Limitations](../Logos/docs/project-info/KNOWN_LIMITATIONS.md) |

**Theory comparison**: [Research/theory-comparison.md](Research/theory-comparison.md)

## Project-Wide Documentation

This directory contains documentation applicable to **all theories**:

- **Development standards** - Apply to all Lean code
- **Installation guides** - Project-wide setup
- **Architecture decisions** - Cross-cutting concerns
- **Research methodology** - Shared approaches

## Documentation Organization

### Installation/

Setup and configuration guides:

- [README.md](Installation/README.md) - Installation overview and quick start
- [CLAUDE_CODE.md](Installation/CLAUDE_CODE.md) - AI-assisted installation (recommended)
- [BASIC_INSTALLATION.md](Installation/BASIC_INSTALLATION.md) - Manual installation
- [GETTING_STARTED.md](Installation/GETTING_STARTED.md) - Terminal basics and editor setup
- [USING_GIT.md](Installation/USING_GIT.md) - Git/GitHub configuration

**Audience**: New users, contributors setting up development environment

### UserGuide/

Project-wide user documentation:

- [README.md](UserGuide/README.md) - Directory overview
- [INTEGRATION.md](UserGuide/INTEGRATION.md) - Integration with model checkers and other tools
- [MCP_INTEGRATION.md](UserGuide/MCP_INTEGRATION.md) - MCP server integration (advanced)

> **Theory-specific guides**: See [Bimodal/docs/user-guide/](../Bimodal/docs/user-guide/)
> for tutorials, examples, and architecture documentation.

**Audience**: Users integrating ProofChecker with external tools

### Research/

Project-wide research documents:

- [README.md](Research/README.md) - Research documentation overview
- [theory-comparison.md](Research/theory-comparison.md) - Comparison of Bimodal and Logos
- [dual-verification.md](Research/dual-verification.md) - RL training architecture design
- [proof-library-design.md](Research/proof-library-design.md) - Theorem caching design

> **Theory-specific research**: See [Logos/docs/research/](../Logos/docs/research/)
> and [Bimodal/docs/research/](../Bimodal/docs/research/).

**Audience**: Researchers, architects

### ProjectInfo/

Project-wide status and tracking:

- [README.md](ProjectInfo/README.md) - Directory overview
- [FEATURE_REGISTRY.md](ProjectInfo/FEATURE_REGISTRY.md) - Feature tracking and capabilities
- [IMPLEMENTATION_STATUS.md](ProjectInfo/IMPLEMENTATION_STATUS.md) - Module-by-module status
  tracking with verification commands
- [MAINTENANCE.md](ProjectInfo/MAINTENANCE.md) - TODO management workflow
- [SORRY_REGISTRY.md](ProjectInfo/SORRY_REGISTRY.md) - Technical debt tracking

> **Theory-specific status**: See theory ProjectInfo directories for implementation status.

**Audience**: Contributors, maintainers

### Development/

Developer standards, conventions, and contribution workflow:

- [README.md](Development/README.md) - Directory overview and reading order
- [CONTRIBUTING.md](Development/CONTRIBUTING.md) - Contribution guidelines and workflow
- [DIRECTORY_README_STANDARD.md](Development/DIRECTORY_README_STANDARD.md) - Directory-level
  documentation standard
- [DOC_QUALITY_CHECKLIST.md](Development/DOC_QUALITY_CHECKLIST.md) - Documentation quality
  assurance checklist
- [LATEX_STANDARDS.md](Development/LATEX_STANDARDS.md) - LaTeX documentation standards and
  conventions
- [LEAN_STYLE_GUIDE.md](Development/LEAN_STYLE_GUIDE.md) - Coding conventions and documentation
  requirements
- [METAPROGRAMMING_GUIDE.md](Development/METAPROGRAMMING_GUIDE.md) - LEAN 4 metaprogramming
  fundamentals for tactics
- [MODULE_ORGANIZATION.md](Development/MODULE_ORGANIZATION.md) - Directory structure and
  namespace patterns
- [NONCOMPUTABLE_GUIDE.md](Development/NONCOMPUTABLE_GUIDE.md) - Handling noncomputable
  definitions and Classical logic
- [PHASED_IMPLEMENTATION.md](Development/PHASED_IMPLEMENTATION.md) - Implementation roadmap
  with execution waves
- [PROPERTY_TESTING_GUIDE.md](Development/PROPERTY_TESTING_GUIDE.md) - Property-based testing
  patterns and Plausible usage
- [QUALITY_METRICS.md](Development/QUALITY_METRICS.md) - Quality targets and performance benchmarks
- [TESTING_STANDARDS.md](Development/TESTING_STANDARDS.md) - Test requirements and coverage targets
- [VERSIONING.md](Development/VERSIONING.md) - Semantic versioning policy

**Audience**: Developers, contributors

### Reference/

Project-wide reference materials:

- [README.md](Reference/README.md) - Directory overview and quick lookup guide
- [API_REFERENCE.md](Reference/API_REFERENCE.md) - API documentation

> **Theory-specific reference**: See [Logos/docs/reference/](../Logos/docs/reference/)
> for Logos glossary and operators, [Bimodal/docs/reference/](../Bimodal/docs/reference/)
> for TM operators and axioms.

**Audience**: All users looking up APIs

### Architecture/

Architectural Decision Records (ADRs):

- [README.md](Architecture/README.md) - ADR catalog and guidance
- [ADR-001-Classical-Logic-Noncomputable.md](Architecture/ADR-001-Classical-Logic-Noncomputable.md) -
  Classical logic for metalogic
- [ADR-004-Remove-Project-Level-State-Files.md](Architecture/ADR-004-Remove-Project-Level-State-Files.md) -
  State file architecture

**Audience**: Architects, maintainers

## Quick Links by Audience

### For New Users

1. [Installation](Installation/README.md) - Set up ProofChecker
2. [Claude Code Setup](Installation/CLAUDE_CODE.md) - AI-assisted installation (recommended)
3. [Getting Started](Installation/GETTING_STARTED.md) - Terminal and editor basics
4. [Bimodal Tutorial](../Bimodal/docs/user-guide/TUTORIAL.md) - Start writing proofs
5. [TM Architecture](../Bimodal/docs/user-guide/ARCHITECTURE.md) - Understand TM logic

### For Contributors

1. [Implementation Status](ProjectInfo/IMPLEMENTATION_STATUS.md) - What's implemented
2. [Sorry Registry](ProjectInfo/SORRY_REGISTRY.md) - Technical debt tracking
3. [Contributing Guidelines](Development/CONTRIBUTING.md) - How to contribute
4. [Style Guide](Development/LEAN_STYLE_GUIDE.md) - Coding standards
5. [Maintenance Workflow](ProjectInfo/MAINTENANCE.md) - TODO and documentation procedures

### For Developers

1. [Testing Standards](Development/TESTING_STANDARDS.md) - Test requirements
2. [Module Organization](Development/MODULE_ORGANIZATION.md) - Project structure
3. [Metaprogramming Guide](Development/METAPROGRAMMING_GUIDE.md) - LEAN 4 tactics
4. [Phased Implementation](Development/PHASED_IMPLEMENTATION.md) - Execution roadmap
5. [Quality Metrics](Development/QUALITY_METRICS.md) - Quality targets

### For Researchers

1. [Research Overview](Research/README.md) - Research documentation index
2. [Theory Comparison](Research/theory-comparison.md) - Bimodal vs Logos
3. [Logos Methodology](../Logos/docs/user-guide/METHODOLOGY.md) - Philosophical foundations
4. [Logos Semantics](../Logos/docs/research/recursive-semantics.md) - Full specification

### Quick Reference

- [TM Operators](../Bimodal/docs/reference/OPERATORS.md) - Symbol notation guide
- [Logos Glossary](../Logos/docs/reference/GLOSSARY.md) - Key concepts

## By Use Case

### I want to understand the theory

**Start with**:
1. [Project README](../README.md) - Project overview and motivations
2. [Theory Comparison](Research/theory-comparison.md) - Bimodal vs Logos differences
3. Theory-specific documentation:
   - Bimodal: [Architecture](../Bimodal/docs/user-guide/ARCHITECTURE.md)
   - Logos: [Methodology](../Logos/docs/user-guide/METHODOLOGY.md)

### I want to write proofs

**Start with**:
1. Theory quick start:
   - Bimodal: [Quick Start](../Bimodal/docs/user-guide/QUICKSTART.md)
   - Logos: [Quick Start](../Logos/docs/user-guide/QUICKSTART.md)
2. [LEAN Style Guide](Development/LEAN_STYLE_GUIDE.md) - Coding conventions
3. Theory-specific tutorials and examples in theory UserGuide/ directories

### I want to integrate with external tools

**Start with**:
1. [Integration Guide](UserGuide/INTEGRATION.md) - Model-Checker integration
2. [MCP Integration](UserGuide/MCP_INTEGRATION.md) - MCP server integration
3. [Dual Verification](Research/dual-verification.md) - Training architecture

### I want to contribute

**Start with**:
1. [Contributing Guide](Development/CONTRIBUTING.md) - Contribution workflow
2. [Implementation Status](ProjectInfo/IMPLEMENTATION_STATUS.md) - What's implemented
3. [Sorry Registry](ProjectInfo/SORRY_REGISTRY.md) - Technical debt tracking
4. [TODO.md](../.claude/specs/TODO.md) - Active tasks

## Documentation Update Workflow

When updating documentation:

1. **Theory-specific changes**: Update theory docs/ directories
   - Bimodal changes -> Bimodal/docs/
   - Logos changes -> Logos/docs/
   - New features/tutorials -> theory UserGuide/
   - Operators/axioms -> theory Reference/

2. **Project-wide changes**: Update this docs/ directory
   - Installation guides -> Installation/
   - Development standards -> Development/
   - Architecture decisions -> Architecture/

3. **Implementation changes**: Update appropriate ProjectInfo/
   - Theory status -> theory ProjectInfo/IMPLEMENTATION_STATUS.md
   - Project status -> docs/project-info/IMPLEMENTATION_STATUS.md

4. **Style/standard changes**: Update Development/ standards files
   - Coding conventions -> LEAN_STYLE_GUIDE.md
   - Test patterns -> TESTING_STANDARDS.md
   - Directory structure -> MODULE_ORGANIZATION.md

5. **Cross-references**: Ensure all links remain valid
   - Check links in updated files
   - Update README.md files if structure changes
   - Run link checker if available

## Documentation Standards

All documentation files follow:

- **Line limit**: 100 characters per line
- **Markdown formatting**: Standard Markdown conventions
- **Formal symbols**: Unicode operators must use backticks (e.g., `[]`, `<>`)
- **Headings**: Use ATX-style headings (`#`, `##`, `###`)
- **Code blocks**: Always specify language (```lean, ```bash)

For detailed documentation standards, see:

- [LEAN Style Guide - Code Comments](Development/LEAN_STYLE_GUIDE.md#code-comments-with-formal-symbols)

### Building Documentation

Generate LEAN API documentation with doc-gen4:

```bash
# Generate documentation
lake build :docs

# Documentation will be in .lake/build/doc/
```

## External Resources

- [LEAN 4 Manual](https://lean-lang.org/lean4/doc/) - Official LEAN 4 documentation
- [Mathlib4 Docs](https://leanprover-community.github.io/mathlib4_docs/) - Mathlib4 API
- [Lean Zulip](https://leanprover.zulipchat.com/) - Community chat

## Related Repositories

- [Model-Checker](https://github.com/benbrastmckie/ModelChecker) - Semantic verification
- [LogicNotes](https://github.com/benbrastmckie/LogicNotes) - Theoretical foundations

---

_Last updated: January 2026_
