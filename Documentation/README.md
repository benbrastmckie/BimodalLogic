# Logos Documentation

Comprehensive documentation hub for the Logos project.

## Documentation Organization

Documentation is organized into five categories:

### UserGuide/

User-facing documentation for working with Logos:

- [METHODOLOGY.md](UserGuide/METHODOLOGY.md): Philosophical foundations and Logos layer architecture
- [ARCHITECTURE.md](UserGuide/ARCHITECTURE.md): System design and TM logic specification
- [TUTORIAL.md](UserGuide/TUTORIAL.md): Getting started guide for new users
- [EXAMPLES.md](UserGuide/EXAMPLES.md): Usage examples and proof patterns
- [INTEGRATION.md](UserGuide/INTEGRATION.md): Integration with model checkers and other tools

### Research/

Research vision and planned architecture. For implementation status, see
[ProjectInfo/IMPLEMENTATION_STATUS.md](ProjectInfo/IMPLEMENTATION_STATUS.md).

- [README.md](Research/README.md) - Research documentation overview
- [DUAL_VERIFICATION.md](Research/DUAL_VERIFICATION.md) - RL training architecture design
- [PROOF_LIBRARY_DESIGN.md](Research/PROOF_LIBRARY_DESIGN.md) - Theorem caching design
- [LAYER_EXTENSIONS.md](Research/LAYER_EXTENSIONS.md) - Layers 1-3 extension specifications

### ProjectInfo/

Project status and tactic documentation:

- [IMPLEMENTATION_STATUS.md](ProjectInfo/IMPLEMENTATION_STATUS.md) - Module-by-module status
  tracking with verification commands (includes Known Limitations section)
- [SORRY_REGISTRY.md](ProjectInfo/SORRY_REGISTRY.md) - Technical debt tracking (sorry
  placeholders with resolution context)
- [TACTIC_DEVELOPMENT.md](ProjectInfo/TACTIC_DEVELOPMENT.md) - Custom tactic development patterns

### Development/

Developer standards, conventions, and contribution workflow:

- [CONTRIBUTING.md](Development/CONTRIBUTING.md) - Contribution guidelines and workflow
- [DIRECTORY_README_STANDARD.md](Development/DIRECTORY_README_STANDARD.md) -
  Directory-level documentation standard
- [DOC_QUALITY_CHECKLIST.md](Development/DOC_QUALITY_CHECKLIST.md) - Documentation
  quality assurance checklist
- [LEAN_STYLE_GUIDE.md](Development/LEAN_STYLE_GUIDE.md) - Coding conventions and
  documentation requirements
- [MAINTENANCE.md](Development/MAINTENANCE.md) - TODO management workflow (git-based history model)
- [METAPROGRAMMING_GUIDE.md](Development/METAPROGRAMMING_GUIDE.md) - LEAN 4
  metaprogramming fundamentals for tactics
- [MODULE_ORGANIZATION.md](Development/MODULE_ORGANIZATION.md) - Directory structure
  and namespace patterns
- [PHASED_IMPLEMENTATION.md](Development/PHASED_IMPLEMENTATION.md) - Implementation
  roadmap with execution waves
- [QUALITY_METRICS.md](Development/QUALITY_METRICS.md) - Quality targets and performance benchmarks
- [TESTING_STANDARDS.md](Development/TESTING_STANDARDS.md) - Test requirements and coverage targets
- [VERSIONING.md](Development/VERSIONING.md) - Semantic versioning policy

### Reference/

Reference materials:

- [OPERATORS.md](Reference/OPERATORS.md) - Formal symbols reference (Unicode notation guide)
- [GLOSSARY.md](Reference/GLOSSARY.md) - Terminology mapping and key concepts

## Quick Links

### For New Users

- [Getting Started](UserGuide/TUTORIAL.md) - Begin here
- [Architecture Overview](UserGuide/ARCHITECTURE.md) - Understand TM logic
- [Usage Examples](UserGuide/EXAMPLES.md) - Learn by example

### For Contributors

- [Implementation Status](ProjectInfo/IMPLEMENTATION_STATUS.md) - What's implemented
- [Implementation Status - Known Limitations](ProjectInfo/IMPLEMENTATION_STATUS.md#known-limitations) -
  What needs work
- [Sorry Registry](ProjectInfo/SORRY_REGISTRY.md) - Technical debt tracking
- [Maintenance Workflow](ProjectInfo/MAINTENANCE.md) - TODO and documentation procedures
- [Contributing Guidelines](Development/CONTRIBUTING.md) - How to contribute
- [Style Guide](Development/LEAN_STYLE_GUIDE.md) - Coding standards

### For Developers

- [Testing Standards](Development/TESTING_STANDARDS.md) - Test requirements
- [Module Organization](Development/MODULE_ORGANIZATION.md) - Project structure
- [Tactic Development](ProjectInfo/TACTIC_DEVELOPMENT.md) - Custom tactics
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

3. **New limitations**: Document in ProjectInfo/IMPLEMENTATION_STATUS.md Known Limitations section
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
- **Code blocks**: Always specify language (`lean, `bash)

For detailed documentation standards, see:

- [Formal Symbol Backtick Standard](../../.claude/docs/reference/standards/documentation-standards.md#formal-symbol-backtick-standard)
- [LEAN Style Guide - Code Comments](Development/LEAN_STYLE_GUIDE.md#code-comments-with-formal-symbols)

### Building Documentation

Generate LEAN API documentation with doc-gen4:

```bash
# Generate documentation
lake build :docs

# Documentation will be in .lake/build/doc/
```
