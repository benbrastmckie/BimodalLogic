# Logos Documentation

Comprehensive documentation hub for the Logos project.

## Documentation Organization

Documentation is organized into five categories:

### UserGuide/
User-facing documentation for working with Logos:
- **METHODOLOGY.md**: Philosophical foundations and Logos layer architecture
- **ARCHITECTURE.md**: System design and TM logic specification
- **TUTORIAL.md**: Getting started guide for new users
- **EXAMPLES.md**: Usage examples and proof patterns
- **INTEGRATION.md**: Integration with model checkers and other tools

**Audience**: Users of the library, learners, researchers

### Research/
Research vision and planned architecture. For implementation status, see [ProjectInfo/IMPLEMENTATION_STATUS.md](ProjectInfo/IMPLEMENTATION_STATUS.md).

- **README.md**: Research documentation overview
- **DUAL_VERIFICATION.md**: RL training architecture design
- **PROOF_LIBRARY_DESIGN.md**: Theorem caching design
- **LAYER_EXTENSIONS.md**: Layers 1-3 extension specifications

**Audience**: Researchers, future contributors, AI safety researchers

### ProjectInfo/
Project status and contribution information:
- **IMPLEMENTATION_STATUS.md**: Module-by-module status tracking with verification commands
- **KNOWN_LIMITATIONS.md**: Gaps, explanations, workarounds, and roadmap
- **SORRY_REGISTRY.md**: Technical debt tracking (sorry placeholders with resolution context)
- **MAINTENANCE.md**: TODO management workflow (git-based history model)
- **CONTRIBUTING.md**: Contribution guidelines and workflow
- **VERSIONING.md**: Semantic versioning policy

**Audience**: Contributors, maintainers, potential contributors

### Development/
Developer standards and conventions:
- **DIRECTORY_README_STANDARD.md**: Directory-level documentation standard
- **DOC_QUALITY_CHECKLIST.md**: Documentation quality assurance checklist
- **LEAN_STYLE_GUIDE.md**: Coding conventions and documentation requirements
- **METAPROGRAMMING_GUIDE.md**: LEAN 4 metaprogramming fundamentals for tactics
- **MODULE_ORGANIZATION.md**: Directory structure and namespace patterns
- **PHASED_IMPLEMENTATION.md**: Implementation roadmap with execution waves
- **QUALITY_METRICS.md**: Quality targets and performance benchmarks
- **TACTIC_DEVELOPMENT.md**: Custom tactic development patterns
- **TESTING_STANDARDS.md**: Test requirements and coverage targets

**Audience**: Developers, contributors, code reviewers

### Reference/
Reference materials:
- **OPERATORS.md**: Formal symbols reference (Unicode notation guide)
- **GLOSSARY.md**: Terminology mapping and key concepts

**Audience**: All users (quick reference)

## Quick Links

### For New Users
- [Getting Started](UserGuide/TUTORIAL.md) - Begin here
- [Architecture Overview](UserGuide/ARCHITECTURE.md) - Understand TM logic
- [Usage Examples](UserGuide/EXAMPLES.md) - Learn by example

### For Contributors
- [Implementation Status](ProjectInfo/IMPLEMENTATION_STATUS.md) - What's implemented
- [Known Limitations](ProjectInfo/KNOWN_LIMITATIONS.md) - What needs work
- [Sorry Registry](ProjectInfo/SORRY_REGISTRY.md) - Technical debt tracking
- [Maintenance Workflow](ProjectInfo/MAINTENANCE.md) - TODO and documentation procedures
- [Contributing Guidelines](ProjectInfo/CONTRIBUTING.md) - How to contribute
- [Style Guide](Development/LEAN_STYLE_GUIDE.md) - Coding standards

### For Developers
- [Testing Standards](Development/TESTING_STANDARDS.md) - Test requirements
- [Module Organization](Development/MODULE_ORGANIZATION.md) - Project structure
- [Tactic Development](Development/TACTIC_DEVELOPMENT.md) - Custom tactics
- [Metaprogramming Guide](Development/METAPROGRAMMING_GUIDE.md) - LEAN 4 tactics
- [Phased Implementation](Development/PHASED_IMPLEMENTATION.md) - Execution roadmap
- [Quality Metrics](Development/QUALITY_METRICS.md) - Quality targets
- [Documentation Quality](Development/DOC_QUALITY_CHECKLIST.md) - Quality assurance

### Quick Reference
- [Operators Reference](Reference/OPERATORS.md) - Symbol notation guide
- [Terminology Glossary](Reference/GLOSSARY.md) - Key concepts and definitions

### For Researchers
- [Logos Methodology](UserGuide/METHODOLOGY.md) - Philosophical foundations
- [Research Overview](Research/README.md) - Research documentation index
- [Dual Verification](Research/DUAL_VERIFICATION.md) - RL training architecture
- [Layer Extensions](Research/LAYER_EXTENSIONS.md) - Layers 1-3 specifications

## Documentation Update Workflow

When updating documentation:

1. **User-facing changes**: Update relevant UserGuide/ files first
   - New features → TUTORIAL.md and EXAMPLES.md
   - Logic changes → ARCHITECTURE.md
   - Integration changes → INTEGRATION.md

2. **Implementation changes**: Update ProjectInfo/IMPLEMENTATION_STATUS.md
   - Mark modules as complete when fully implemented
   - Update completion percentages
   - Add verification commands

3. **New limitations**: Document in ProjectInfo/KNOWN_LIMITATIONS.md
   - Explain why limitation exists
   - Provide workarounds
   - Add to roadmap

4. **Style/standard changes**: Update Development/ standards files
   - Coding conventions → LEAN_STYLE_GUIDE.md
   - Test patterns → TESTING_STANDARDS.md
   - Directory structure → MODULE_ORGANIZATION.md

5. **Cross-references**: Ensure all links remain valid
   - Check links in updated files
   - Update README.md and CLAUDE.md if structure changes
   - Run link checker if available

## Documentation Standards

All documentation files follow:
- **Line limit**: 100 characters per line
- **Markdown formatting**: Standard Markdown conventions
- **Formal symbols**: Unicode operators must use backticks (e.g., `□`, `◇`, `△`, `▽`)
- **Headings**: Use ATX-style headings (`#`, `##`, `###`)
- **Code blocks**: Always specify language (```lean, ```bash)

For detailed documentation standards, see:
- [Formal Symbol Backtick Standard](../../.claude/docs/reference/standards/documentation-standards.md#formal-symbol-backtick-standard)
- [LEAN Style Guide - Code Comments](Development/LEAN_STYLE_GUIDE.md#code-comments-with-formal-symbols)

## Building Documentation

### LEAN API Documentation

Generate LEAN API documentation with doc-gen4:

```bash
# Generate documentation
lake build :docs

# Documentation will be in .lake/build/doc/
```

### Reading Documentation

All Markdown documentation can be read:
- In VS Code with Markdown preview (`Ctrl+Shift+V`)
- On GitHub (automatic rendering)
- In any Markdown viewer
- In plain text (readable even without rendering)

## Finding Information

### "How do I...?"
- **Learn Logos**: Start with [TUTORIAL.md](UserGuide/TUTORIAL.md)
- **Understand TM logic**: Read [ARCHITECTURE.md](UserGuide/ARCHITECTURE.md)
- **See examples**: Check [EXAMPLES.md](UserGuide/EXAMPLES.md)
- **Contribute**: Read [CONTRIBUTING.md](ProjectInfo/CONTRIBUTING.md)
- **Write tests**: See [TESTING_STANDARDS.md](Development/TESTING_STANDARDS.md)

### "What is the status of...?"
- **Module completion**: Check [IMPLEMENTATION_STATUS.md](ProjectInfo/IMPLEMENTATION_STATUS.md)
- **Known issues**: See [KNOWN_LIMITATIONS.md](ProjectInfo/KNOWN_LIMITATIONS.md)
- **Planned features**: Look in KNOWN_LIMITATIONS.md Section 7

### "Where is the specification for...?"
- **TM logic axioms**: [ARCHITECTURE.md](UserGuide/ARCHITECTURE.md) Section 2
- **Task semantics**: [ARCHITECTURE.md](UserGuide/ARCHITECTURE.md) Section 3
- **Perpetuity principles**: [ARCHITECTURE.md](UserGuide/ARCHITECTURE.md) Section 5
- **Operator symbols**: [OPERATORS.md](Reference/OPERATORS.md)

## Documentation Quality

We maintain high documentation quality through:
- **Accuracy**: Documentation matches implementation
- **Completeness**: All public APIs are documented
- **Clarity**: Clear, concise explanations
- **Examples**: Concrete usage examples
- **Up-to-date**: Regular synchronization with code

If you find documentation issues:
1. Check if information is in a different document
2. Consult source code docstrings (often most up-to-date)
3. Open an issue with `documentation` label
4. Submit a pull request to fix it

## Related Files

- [../README.md](../README.md) - Project overview and installation
- [../CLAUDE.md](../CLAUDE.md) - AI assistant configuration
- [../Archive/README.md](../Archive/README.md) - Pedagogical examples
- [../Logos/README.md](../Logos/README.md) - Source directory guide
- [../LogosTest/README.md](../LogosTest/README.md) - Test suite guide

## Navigation

- **Up**: [Logos Root](../)
- **Source Code**: [Logos/](../Logos/)
- **Tests**: [LogosTest/](../LogosTest/)
- **Examples**: [Archive/](../Archive/)
