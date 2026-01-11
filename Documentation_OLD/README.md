# Logos Documentation

Comprehensive documentation hub for the Logos project.

> **For AI-Assisted Development**: See [../.opencode/README.md](../.opencode/README.md) for the AI agent system that automates research, planning, implementation, and documentation workflows.

## Documentation Organization

Documentation is organized into eight categories. See also [NAVIGATION.md](NAVIGATION.md) for an
alternative navigation style with detailed use-case guides.

### Installation/

Setup and configuration guides:

- [README.md](Installation/README.md) - Installation overview and quick start
- [CLAUDE_CODE.md](Installation/CLAUDE_CODE.md) - AI-assisted installation (recommended)
- [BASIC_INSTALLATION.md](Installation/BASIC_INSTALLATION.md) - Manual installation
- [GETTING_STARTED.md](Installation/GETTING_STARTED.md) - Terminal basics and editor setup
- [USING_GIT.md](Installation/USING_GIT.md) - Git/GitHub configuration

### UserGuide/

User-facing documentation for working with Logos:

- [README.md](UserGuide/README.md) - Directory overview and reading order
- [METHODOLOGY.md](UserGuide/METHODOLOGY.md) - Philosophical foundations and layer architecture
- [ARCHITECTURE.md](UserGuide/ARCHITECTURE.md) - System design and TM logic specification
- [TUTORIAL.md](UserGuide/TUTORIAL.md) - Getting started guide for new users
- [EXAMPLES.md](UserGuide/EXAMPLES.md) - Usage examples and proof patterns
- [INTEGRATION.md](UserGuide/INTEGRATION.md) - Integration with model checkers and other tools
- [MCP_INTEGRATION.md](UserGuide/MCP_INTEGRATION.md) - MCP server integration (advanced)
- [TACTIC_DEVELOPMENT.md](UserGuide/TACTIC_DEVELOPMENT.md) - Custom tactic development guide

### Research/

Research vision and planned architecture. For implementation status, see
[ProjectInfo/IMPLEMENTATION_STATUS.md](ProjectInfo/IMPLEMENTATION_STATUS.md).

- [README.md](Research/README.md) - Research documentation overview
- [DUAL_VERIFICATION.md](Research/DUAL_VERIFICATION.md) - RL training architecture design
- [PROOF_LIBRARY_DESIGN.md](Research/PROOF_LIBRARY_DESIGN.md) - Theorem caching design
- [LAYER_EXTENSIONS.md](Research/LAYER_EXTENSIONS.md) - Layers 1-3 extension specifications

### ProjectInfo/

Project status, feature tracking, and registries:

- [README.md](ProjectInfo/README.md) - Directory overview and Five-Document Model
- [FEATURE_REGISTRY.md](ProjectInfo/FEATURE_REGISTRY.md) - Feature tracking and capabilities
- [IMPLEMENTATION_STATUS.md](ProjectInfo/IMPLEMENTATION_STATUS.md) - Module-by-module status
  tracking with verification commands (includes Known Limitations section)
- [MAINTENANCE.md](ProjectInfo/MAINTENANCE.md) - TODO management workflow (git-based history
  model, Five-Document Model)
- [SORRY_REGISTRY.md](ProjectInfo/SORRY_REGISTRY.md) - Technical debt tracking (sorry
  placeholders with resolution context)
- [TACTIC_REGISTRY.md](ProjectInfo/TACTIC_REGISTRY.md) - Registry of planned and completed tactics

### Development/

Developer standards, conventions, and contribution workflow:

- [README.md](Development/README.md) - Directory overview and reading order
- [CONTRIBUTING.md](Development/CONTRIBUTING.md) - Contribution guidelines and workflow
- [DIRECTORY_README_STANDARD.md](Development/DIRECTORY_README_STANDARD.md) -
  Directory-level documentation standard
- [DOC_QUALITY_CHECKLIST.md](Development/DOC_QUALITY_CHECKLIST.md) - Documentation
  quality assurance checklist
- [LEAN_STYLE_GUIDE.md](Development/LEAN_STYLE_GUIDE.md) - Coding conventions and
  documentation requirements
- [METAPROGRAMMING_GUIDE.md](Development/METAPROGRAMMING_GUIDE.md) - LEAN 4
  metaprogramming fundamentals for tactics
- [MODULE_ORGANIZATION.md](Development/MODULE_ORGANIZATION.md) - Directory structure
  and namespace patterns
- [NONCOMPUTABLE_GUIDE.md](Development/NONCOMPUTABLE_GUIDE.md) - Handling noncomputable
  definitions and Classical logic
- [PHASED_IMPLEMENTATION.md](Development/PHASED_IMPLEMENTATION.md) - Implementation
  roadmap with execution waves
- [PROPERTY_TESTING_GUIDE.md](Development/PROPERTY_TESTING_GUIDE.md) - Property-based
  testing patterns and Plausible usage
- [QUALITY_METRICS.md](Development/QUALITY_METRICS.md) - Quality targets and performance benchmarks
- [TESTING_STANDARDS.md](Development/TESTING_STANDARDS.md) - Test requirements and coverage targets
- [VERSIONING.md](Development/VERSIONING.md) - Semantic versioning policy

### Reference/

Reference materials:

- [README.md](Reference/README.md) - Directory overview and quick lookup guide
- [API_REFERENCE.md](Reference/API_REFERENCE.md) - Logos API documentation
- [GLOSSARY.md](Reference/GLOSSARY.md) - Terminology mapping and key concepts
- [OPERATORS.md](Reference/OPERATORS.md) - Formal symbols reference (Unicode notation guide)

### Architecture/

Architectural Decision Records (ADRs):

- [README.md](Architecture/README.md) - ADR catalog and guidance
- [ADR-001-Classical-Logic-Noncomputable.md](Architecture/ADR-001-Classical-Logic-Noncomputable.md) -
  Classical logic for metalogic
- [ADR-004-Remove-Project-Level-State-Files.md](Architecture/ADR-004-Remove-Project-Level-State-Files.md) -
  State file architecture

### AI System/ (.opencode/)

Context-aware development system for automated workflows:

- [AI System Overview](../.opencode/README.md) - Complete system documentation
- [Architecture](../.opencode/ARCHITECTURE.md) - Detailed system architecture
- [Quick Start](../.opencode/QUICK-START.md) - Step-by-step usage guide
- [Agent Catalog](../.opencode/agent/README.md) - Primary agents and routing
- [Specialist Catalog](../.opencode/agent/subagents/specialists/README.md) - All 32 specialists
- [Command Reference](../.opencode/command/README.md) - Command usage and examples
- [Context Organization](../.opencode/context/README.md) - Context file structure

## Quick Links

### For New Users

- [Installation](Installation/README.md) - Set up ProofChecker
- [Claude Code Setup](Installation/CLAUDE_CODE.md) - AI-assisted installation (recommended)
- [Getting Started](Installation/GETTING_STARTED.md) - Terminal and editor basics
- [Tutorial](UserGuide/TUTORIAL.md) - Start writing proofs
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
- [Tactic Development](UserGuide/TACTIC_DEVELOPMENT.md) - Custom tactic development guide
- [Tactic Registry](ProjectInfo/TACTIC_REGISTRY.md) - Tactic implementation status
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

### For AI-Assisted Development

- [AI System Overview](../.opencode/README.md) - Complete AI system documentation
- [Research Command](../.opencode/command/research.md) - Automated research workflow
- [Plan Command](../.opencode/command/plan.md) - Implementation planning workflow
- [LEAN Command](../.opencode/command/lean.md) - Proof development workflow
- [Document Command](../.opencode/command/document.md) - Documentation workflow

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
   - Update README.md if structure changes
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
