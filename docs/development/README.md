# Development Documentation

[Back to Documentation](../README.md)

Developer standards, conventions, and contribution guides for the ProofChecker project. These documents
establish coding practices, quality standards, and workflow patterns for contributors.

**Audience**: Developers, contributors, documentation authors

## Documentation Overview

Development documentation is organized into categories for easy navigation. For TODO management
workflow and task lifecycle, see [ProjectInfo/MAINTENANCE.md](../project-info/MAINTENANCE.md).

## Standards and Style

Core standards for code quality and consistency:

| Document | Description |
|----------|-------------|
| [LEAN_STYLE_GUIDE.md](LEAN_STYLE_GUIDE.md) | Comprehensive coding conventions and documentation requirements |
| [REFERENCE_NORMAL_FORM.md](REFERENCE_NORMAL_FORM.md) | The shape of every `## References` block, and the gate baselines a docstring sweep holds constant |
| [TESTING_STANDARDS.md](TESTING_STANDARDS.md) | Test requirements, coverage targets, and test patterns |
| [QUALITY_METRICS.md](QUALITY_METRICS.md) | Quality targets and performance benchmarks |

## Practical Guides

Hands-on guides for specific development tasks:

| Document | Description |
|----------|-------------|
| [BENCHMARKING_GUIDE.md](BENCHMARKING_GUIDE.md) | Performance benchmarking standards and CI integration |
| [METAPROGRAMMING_GUIDE.md](METAPROGRAMMING_GUIDE.md) | Lean 4 metaprogramming fundamentals for tactics |
| [NONCOMPUTABLE_GUIDE.md](NONCOMPUTABLE_GUIDE.md) | Handling noncomputable definitions and Classical logic |
| [PROPERTY_TESTING_GUIDE.md](PROPERTY_TESTING_GUIDE.md) | Property-based testing patterns and Plausible usage |

## Project Organization

Directory structure and documentation patterns:

| Document | Description |
|----------|-------------|
| [MODULE_ORGANIZATION.md](MODULE_ORGANIZATION.md) | Directory structure and namespace patterns |
| [MODULE_INVARIANTS.md](MODULE_INVARIANTS.md) | The scripted structural gate: what `scripts/check-module-invariants.sh` checks and how to extend it |
| [MODULE_RELOCATION.md](MODULE_RELOCATION.md) | How to move Lean modules: the rewrite classes of `scripts/move-modules.py`, gate-widening order, the traps past moves surfaced, and the pre-move checklist |
| [MODULE_SYSTEM_EVALUATION.md](MODULE_SYSTEM_EVALUATION.md) | Evaluation of adopting the Lean module system: probes on the pinned toolchain, the bottom-up and exposure constraints, the local cost inventory, and the recommended programme order |
| [PUBLICATION_REFACTOR.md](PUBLICATION_REFACTOR.md) | The dependency-ordered refactor programme to publication standard: convention map, target layout, templates, measurements, phases and follow-up split |
| [DIRECTORY_README_STANDARD.md](DIRECTORY_README_STANDARD.md) | README documentation standard for directories |

## Contribution Workflow

Guidelines for contributing to the project:

| Document | Description |
|----------|-------------|
| [CONTRIBUTING.md](../../CONTRIBUTING.md) | Contribution guidelines and pull request workflow |
| [VERSIONING.md](VERSIONING.md) | Semantic versioning policy |

## Quality Assurance

Documentation quality and review processes:

| Document | Description |
|----------|-------------|
| [DOC_QUALITY_CHECKLIST.md](DOC_QUALITY_CHECKLIST.md) | Documentation quality assurance checklist |

## Recommended Reading Order

### For New Contributors

1. **[CONTRIBUTING.md](../../CONTRIBUTING.md)** - Start here for contribution workflow
2. **[LEAN_STYLE_GUIDE.md](LEAN_STYLE_GUIDE.md)** - Coding conventions to follow
3. **[TESTING_STANDARDS.md](TESTING_STANDARDS.md)** - Test requirements for PRs

### For Tactic Developers

1. **[METAPROGRAMMING_GUIDE.md](METAPROGRAMMING_GUIDE.md)** - Lean 4 metaprogramming
2. **[LEAN_STYLE_GUIDE.md](LEAN_STYLE_GUIDE.md)** - Tactic documentation conventions
3. **[TESTING_STANDARDS.md](TESTING_STANDARDS.md)** - Testing custom tactics

### For Documentation Authors

1. **[DIRECTORY_README_STANDARD.md](DIRECTORY_README_STANDARD.md)** - README patterns
2. **[DOC_QUALITY_CHECKLIST.md](DOC_QUALITY_CHECKLIST.md)** - Quality requirements
3. **[LEAN_STYLE_GUIDE.md](LEAN_STYLE_GUIDE.md)** - Docstring conventions

## Related Documentation

- [Project Status](../project-info/) - Implementation status and registries
- [User Guides](../user-guide/) - End-user documentation
- [TODO Workflow](../project-info/MAINTENANCE.md) - Task management and git-based history model

---

[Back to Documentation](../README.md)
