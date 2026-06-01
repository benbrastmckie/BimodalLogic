# ProofChecker Documentation

Project-wide documentation hub for the ProofChecker formal verification project.

> **Project Naming**: The repository is named **BimodalLogic**, the project display name is
> **ProofChecker**, the Lake package is named **Logos** (in lakefile.toml), and the primary
> Lean library namespace is **Bimodal** (in `Theories/Bimodal/`). These names serve different
> purposes: the repository name reflects the GitHub URL, the display name appears in user-facing
> documentation, the package name is used by Lake for dependency resolution, and the library
> namespace is used in Lean import statements.

## Framework Overview

ProofChecker implements TM bimodal logic (Tense and Modality) in Lean 4 with verified soundness and completeness proofs.

**Bimodal** is the production-ready implementation providing a complete propositional intensional logic combining S5 modal and linear temporal operators. The implementation includes fully verified soundness, completeness, deduction theorem, and decidability results.

**Getting Started**: See the [Bimodal documentation](../Theories/Bimodal/docs/) for tutorials, examples, and reference materials.

## Theory-Specific Documentation

For documentation specific to the bimodal logic theory, see:

| Theory | Status | Description | Documentation |
|--------|--------|-------------|---------------|
| **Bimodal** | Complete | Propositional intensional logic with soundness/completeness proofs | [Bimodal/docs/](../Theories/Bimodal/docs/) |

### Quick Access by Need

| Need | Bimodal (Complete) |
|------|-------------------|
| Quick start | [Quick Start](../Theories/Bimodal/docs/user-guide/quickstart.md) |
| Axiom reference | [Axioms](../Theories/Bimodal/docs/reference/axiom-reference.md) |
| Implementation status | [Status](../Theories/Bimodal/docs/project-info/implementation-status.md) |
| Known limitations | [Limitations](../Theories/Bimodal/docs/project-info/known-limitations.md) |

**Theory research**: [research/BIMODAL_LOGIC.md](research/BIMODAL_LOGIC.md) - Bimodal logic foundations and theory

## Project-Wide Documentation

This directory contains documentation applicable to **all theories**:

- **Development standards** - Apply to all Lean code
- **Installation guides** - Project-wide setup
- **Architecture decisions** - Cross-cutting concerns
- **Research methodology** - Shared approaches

## Documentation Organization

### Installation/

Setup and configuration guides:

- [README.md](installation/README.md) - Installation overview and quick start
- [BASIC_INSTALLATION.md](installation/BASIC_INSTALLATION.md) - Installation guide (elan, Lean, Lake, Mathlib)

**Audience**: New users, contributors setting up development environment

### user-guide/

Project-wide user documentation:

- [README.md](user-guide/README.md) - Directory overview
- [INTEGRATION.md](user-guide/INTEGRATION.md) - Integration with model checkers and other tools
- [MCP_INTEGRATION.md](user-guide/MCP_INTEGRATION.md) - MCP server integration (advanced)

> **Theory-specific guides**: See [Theories/Bimodal/docs/user-guide/](../Theories/Bimodal/docs/user-guide/)
> for tutorials, examples, and architecture documentation.

**Audience**: Users integrating ProofChecker with external tools

### research/

Project-wide research documents:

- [README.md](research/README.md) - Research documentation overview
- [BIMODAL_LOGIC.md](research/BIMODAL_LOGIC.md) - Bimodal Logic foundations
- [NONCOMPUTABLE.md](research/NONCOMPUTABLE.md) - The `noncomputable` keyword: comprehensive analysis
- [DEDUCTION_THEOREM_NECESSITY.md](research/DEDUCTION_THEOREM_NECESSITY.md) - Why the deduction theorem must be noncomputable
- [DUAL_VERIFICATION.md](research/DUAL_VERIFICATION.md) - RL training architecture design
- [PROOF_LIBRARY_DESIGN.md](research/PROOF_LIBRARY_DESIGN.md) - Theorem caching design
- [PROPERTY_BASED_TESTING_LEAN4.md](research/PROPERTY_BASED_TESTING_LEAN4.md) - Property-based testing research
- [competitive-landscape.md](research/competitive-landscape.md) - BMLogic-Bench competitive analysis (13-dimension matrix, 12 benchmarks)

> **Theory-specific research**: See [Theories/Bimodal/docs/research/](../Theories/Bimodal/docs/research/).

**Audience**: Researchers, architects

### project-info/

Project-wide status and tracking:

- [README.md](project-info/README.md) - Directory overview
- [FEATURE_REGISTRY.md](project-info/FEATURE_REGISTRY.md) - Feature tracking and capabilities
- [implementation-status.md](project-info/implementation-status.md) - Module-by-module status tracking with verification commands
- [MAINTENANCE.md](project-info/MAINTENANCE.md) - TODO management workflow
- [SORRY_REGISTRY.md](project-info/SORRY_REGISTRY.md) - Technical debt tracking

> **Theory-specific status**: See theory project-info directories for implementation status.

**Audience**: Contributors, maintainers

### development/

Developer standards, conventions, and contribution workflow:

- [README.md](development/README.md) - Directory overview and reading order
- [BENCHMARKING_GUIDE.md](development/BENCHMARKING_GUIDE.md) - Performance benchmarking and profiling guide
- [CI_CD_PROCESS.md](development/CI_CD_PROCESS.md) - Continuous integration and deployment pipeline
- [CONTRIBUTING.md](development/CONTRIBUTING.md) - Contribution guidelines and workflow
- [DIRECTORY_README_STANDARD.md](development/DIRECTORY_README_STANDARD.md) - Directory-level documentation standard
- [DOC_QUALITY_CHECKLIST.md](development/DOC_QUALITY_CHECKLIST.md) - Documentation quality assurance checklist
- [LATEX_STANDARDS.md](development/LATEX_STANDARDS.md) - LaTeX documentation standards and conventions
- [LEAN_STYLE_GUIDE.md](development/LEAN_STYLE_GUIDE.md) - Coding conventions and documentation requirements
- [METAPROGRAMMING_GUIDE.md](development/METAPROGRAMMING_GUIDE.md) - LEAN 4 metaprogramming fundamentals for tactics
- [MODULE_ORGANIZATION.md](development/MODULE_ORGANIZATION.md) - Directory structure and namespace patterns
- [NONCOMPUTABLE_GUIDE.md](development/NONCOMPUTABLE_GUIDE.md) - Handling noncomputable definitions and Classical logic
- [PHASED_IMPLEMENTATION.md](development/PHASED_IMPLEMENTATION.md) - Implementation roadmap with execution waves
- [PROPERTY_TESTING_GUIDE.md](development/PROPERTY_TESTING_GUIDE.md) - Property-based testing patterns and Plausible usage
- [QUALITY_METRICS.md](development/QUALITY_METRICS.md) - Quality targets and performance benchmarks
- [TESTING_STANDARDS.md](development/TESTING_STANDARDS.md) - Test requirements and coverage targets
- [VERSIONING.md](development/VERSIONING.md) - Semantic versioning policy

**Audience**: Developers, contributors

### reference/

Project-wide reference materials:

- [README.md](reference/README.md) - Directory overview and quick lookup guide
- [API_REFERENCE.md](reference/API_REFERENCE.md) - API documentation

> **Theory-specific reference**: See [Theories/Bimodal/docs/reference/](../Theories/Bimodal/docs/reference/)
> for TM operators and axioms.

**Audience**: All users looking up APIs

### architecture/

Architectural Decision Records (ADRs) and system architecture documentation:

- [README.md](architecture/README.md) - ADR catalog and guidance
- [ADR-001-Classical-Logic-Noncomputable.md](architecture/ADR-001-Classical-Logic-Noncomputable.md) - Classical logic for metalogic
- [ADR-004-Remove-Project-Level-State-Files.md](architecture/ADR-004-Remove-Project-Level-State-Files.md) - State file architecture
- [BFMCS_architecture.md](architecture/BFMCS_architecture.md) - BFMCS proof architecture (base completeness construction)

**Audience**: Architects, maintainers

### training/

Training data pipeline documentation:

- [README.md](training/README.md) - Directory overview and document index
- [PIPELINE.md](training/PIPELINE.md) - Dual-signal training data pipeline reference (all 6 Lean modules, JSON schemas, [BimodalHarness](https://github.com/benbrastmckie/BimodalHarness) integration)
- [PUBLISHING_GUIDE.md](training/PUBLISHING_GUIDE.md) - Consumer quick-start and maintainer workflow for Hugging Face Hub publishing

**Audience**: ML researchers, contributors working on neural proof search

## Quick Links by Audience

### For New Users

1. [Installation](installation/README.md) - Set up ProofChecker
2. [Basic Installation](installation/BASIC_INSTALLATION.md) - Step-by-step setup guide
3. [Bimodal Tutorial](../Theories/Bimodal/docs/user-guide/tutorial.md) - Start writing proofs
4. [TM Architecture](../Theories/Bimodal/docs/user-guide/architecture.md) - Understand TM logic

### For Contributors

1. [Implementation Status](project-info/implementation-status.md) - What's implemented
2. [Sorry Registry](project-info/SORRY_REGISTRY.md) - Technical debt tracking
3. [Contributing Guidelines](development/CONTRIBUTING.md) - How to contribute
4. [Style Guide](development/LEAN_STYLE_GUIDE.md) - Coding standards
5. [Maintenance Workflow](project-info/MAINTENANCE.md) - TODO and documentation procedures

### For Developers

1. [Testing Standards](development/TESTING_STANDARDS.md) - Test requirements
2. [Module Organization](development/MODULE_ORGANIZATION.md) - Project structure
3. [Metaprogramming Guide](development/METAPROGRAMMING_GUIDE.md) - LEAN 4 tactics
4. [Phased Implementation](development/PHASED_IMPLEMENTATION.md) - Execution roadmap
5. [Quality Metrics](development/QUALITY_METRICS.md) - Quality targets

### For Researchers

1. [Research Overview](research/README.md) - Research documentation index
2. [Bimodal Logic](research/BIMODAL_LOGIC.md) - Theoretical foundations

### Quick Reference

- [TM Operators](../Theories/Bimodal/docs/reference/operators.md) - Symbol notation guide

## By Use Case

### I want to understand the theory

**Start with**:
1. [Project README](../README.md) - Project overview and motivations
2. [Bimodal Architecture](../Theories/Bimodal/docs/user-guide/architecture.md) - The complete, verified system
3. [Bimodal Logic](research/BIMODAL_LOGIC.md) - Theoretical foundations

### I want to write proofs

**Start with Bimodal** (complete implementation):
1. [Bimodal Quick Start](../Theories/Bimodal/docs/user-guide/quickstart.md) - Get started
2. [Bimodal Tutorial](../Theories/Bimodal/docs/user-guide/tutorial.md) - Step-by-step guide
3. [LEAN Style Guide](development/LEAN_STYLE_GUIDE.md) - Coding conventions
4. [Bimodal Examples](../Theories/Bimodal/docs/user-guide/examples.md) - Worked examples

### I want to integrate with external tools

**Start with**:
1. [Integration Guide](user-guide/INTEGRATION.md) - Model-Checker integration
2. [MCP Integration](user-guide/MCP_INTEGRATION.md) - MCP server integration
3. [Dual Verification](research/DUAL_VERIFICATION.md) - Training architecture

### I want to contribute

**Start with**:
1. [Contributing Guide](development/CONTRIBUTING.md) - Contribution workflow
2. [Implementation Status](project-info/implementation-status.md) - What's implemented
3. [Sorry Registry](project-info/SORRY_REGISTRY.md) - Technical debt tracking
4. [TODO.md](../specs/TODO.md) - Active tasks

## Documentation Update Workflow

When updating documentation:

1. **Theory-specific changes**: Update theory docs/ directories
   - Bimodal changes -> Theories/Bimodal/docs/
   - New features/tutorials -> theory user-guide/
   - Operators/axioms -> theory reference/

2. **Project-wide changes**: Update this docs/ directory
   - Installation guides -> installation/
   - Development standards -> development/
   - Architecture decisions -> architecture/

3. **Implementation changes**: Update appropriate project-info/
   - Theory status -> theory project-info/implementation-status.md
   - Project status -> docs/project-info/implementation-status.md

4. **Style/standard changes**: Update development/ standards files
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

- [LEAN Style Guide - Code Comments](development/LEAN_STYLE_GUIDE.md#code-comments-with-formal-symbols)

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

- [BimodalHarness](https://github.com/benbrastmckie/BimodalHarness) - AlphaZero-style neural proof search training
- [Model-Checker](https://github.com/benbrastmckie/ModelChecker) - Semantic verification

---

_Last updated: March 2026_
