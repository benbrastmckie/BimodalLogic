# Documentation Navigation Guide

This guide helps you find the right documentation for your needs.

## Theory-Specific Documentation

| Need | Bimodal | Logos |
|------|---------|-------|
| Quick start | [Bimodal Quick Start](../Bimodal/Documentation/UserGuide/QUICKSTART.md) | [Logos Quick Start](../Logos/Documentation/UserGuide/QUICKSTART.md) |
| Axiom reference | [Bimodal Axioms](../Bimodal/Documentation/Reference/AXIOM_REFERENCE.md) | [Logos Axioms](../Logos/Documentation/Reference/AXIOM_REFERENCE.md) |
| Implementation status | [Bimodal Status](../Bimodal/Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) | [Logos Status](../Logos/Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) |
| Known limitations | [Bimodal Limits](../Bimodal/Documentation/ProjectInfo/KNOWN_LIMITATIONS.md) | [Logos Limits](../Logos/Documentation/ProjectInfo/KNOWN_LIMITATIONS.md) |

**Theory comparison**: [THEORY_COMPARISON.md](Research/THEORY_COMPARISON.md)

## Project-Wide Quick Links

### Getting Started
- **New to ProofChecker?** → [Tutorial](UserGuide/TUTORIAL.md)
- **Want to see examples?** → [Examples](UserGuide/EXAMPLES.md)
- **Using AI assistance?** → [.opencode/README.md](../.opencode/README.md)
- **Quick start with AI?** → [.opencode/QUICK-START.md](../.opencode/QUICK-START.md)

### Development
- **Contributing code?** → [Contributing Guide](Development/CONTRIBUTING.md)
- **Writing proofs?** → [LEAN Style Guide](Development/LEAN_STYLE_GUIDE.md)
- **Using AI tools?** → [.opencode/QUICK-START.md](../.opencode/QUICK-START.md)
- **Developing tactics?** → [Tactic Development](UserGuide/TACTIC_DEVELOPMENT.md)

### Reference
- **Looking up operators?** → [Operators Reference](Reference/OPERATORS.md)
- **Need definitions?** → [Glossary](Reference/GLOSSARY.md)
- **Checking status?** → [Implementation Status](ProjectInfo/IMPLEMENTATION_STATUS.md)
- **Tracking tasks?** → [TODO](../TODO.md)

### Research
- **Understanding theory?** → [Conceptual Engineering](Research/CONCEPTUAL_ENGINEERING.md)
- **Verification approach?** → [Dual Verification](Research/DUAL_VERIFICATION.md)
- **Extending layers?** → [Layer Extensions](Research/LAYER_EXTENSIONS.md)
- **Proof library design?** → [Proof Library Design](Research/PROOF_LIBRARY_DESIGN.md)

### AI System
- **AI system overview?** → [.opencode/README.md](../.opencode/README.md)
- **System architecture?** → [.opencode/ARCHITECTURE.md](../.opencode/ARCHITECTURE.md)
- **Available commands?** → [.opencode/command/README.md](../.opencode/command/README.md)
- **Agent catalog?** → [.opencode/agent/README.md](../.opencode/agent/README.md)

---

## Documentation Structure

### Project Documentation (Documentation/)
Theoretical foundations, user guides, and development standards for the Logos formal language.

**Location**: `/Documentation/`

**Purpose**: Logos theory, methodology, implementation, and development standards

**Key Files**:
- [README.md](README.md) - Documentation hub
- [NAVIGATION.md](NAVIGATION.md) - This file

### AI System Documentation (.opencode/)
AI-assisted development system with agents, commands, and workflows for LEAN 4 theorem proving.

**Location**: `/.opencode/`

**Purpose**: Automated research, planning, implementation, verification, and documentation workflows

**Key Files**:
- [README.md](../.opencode/README.md) - AI system overview
- [ARCHITECTURE.md](../.opencode/ARCHITECTURE.md) - System architecture
- [QUICK-START.md](../.opencode/QUICK-START.md) - Step-by-step usage

### Code Documentation
Inline documentation in LEAN 4 source files with module-level docstrings.

**Location**: `/Logos/`, `/LogosTest/`

**Purpose**: API documentation, implementation details, proof strategies

**Access**: See [Module Organization](Development/MODULE_ORGANIZATION.md)

---

## By Use Case

### I want to understand Logos theory

**Path**:
1. [README.md](../README.md) - Project overview and motivations
2. [Methodology](UserGuide/METHODOLOGY.md) - Philosophical foundations and layer architecture
3. [Conceptual Engineering](Research/CONCEPTUAL_ENGINEERING.md) - Philosophical methodology
4. [Dual Verification](Research/DUAL_VERIFICATION.md) - RL training architecture
5. [Architecture](UserGuide/ARCHITECTURE.md) - TM logic specification

**Key Concepts**:
- Hyperintensional semantics
- Task semantics framework
- Progressive operator methodology
- Dual verification architecture

### I want to write proofs in Logos

**Path**:
1. [Tutorial](UserGuide/TUTORIAL.md) - Getting started guide
2. [Examples](UserGuide/EXAMPLES.md) - Modal, temporal, bimodal examples
3. [LEAN Style Guide](Development/LEAN_STYLE_GUIDE.md) - Coding conventions
4. [.opencode/README.md](../.opencode/README.md) - AI assistance for proof development

**AI Workflow**:
```bash
/research "modal logic proof patterns"  # Research phase
/plan "Implement theorem X"             # Planning phase
/lean 042                               # Implementation phase
/document "theorem X"                   # Documentation phase
```

**Key Resources**:
- [Operators Reference](Reference/OPERATORS.md) - Symbol notation
- [Tactic Development](UserGuide/TACTIC_DEVELOPMENT.md) - Custom tactics
- [Testing Standards](Development/TESTING_STANDARDS.md) - Test requirements

### I want to extend Logos

**Path**:
1. [Contributing Guide](Development/CONTRIBUTING.md) - Contribution workflow
2. [Layer Extensions](Research/LAYER_EXTENSIONS.md) - Layers 1-3 specifications
3. [Metaprogramming Guide](Development/METAPROGRAMMING_GUIDE.md) - LEAN 4 tactics
4. [.opencode/agent/subagents/meta.md](../.opencode/agent/subagents/meta.md) - Extending AI system

**Extension Types**:
- **New operators**: Add to syntax, axioms, semantics
- **New tactics**: Metaprogramming guide + tactic development
- **New layers**: Layer extensions research
- **AI agents**: Meta system for agent creation

**Key Resources**:
- [Module Organization](Development/MODULE_ORGANIZATION.md) - Project structure
- [Quality Metrics](Development/QUALITY_METRICS.md) - Quality targets
- [Phased Implementation](Development/PHASED_IMPLEMENTATION.md) - Implementation roadmap

### I want to integrate Logos into my application

**Path**:
1. [Integration Guide](UserGuide/INTEGRATION.md) - Model-Checker integration
2. [Methodology](UserGuide/METHODOLOGY.md) - Application domains
3. [Architecture](UserGuide/ARCHITECTURE.md) - API design
4. [.opencode/README.md](../.opencode/README.md) - Development workflow

**Integration Points**:
- **Model-Checker**: Semantic verification (Z3-based)
- **External Tools**: SMT-LIB export
- **API**: Formula exchange interface
- **AI System**: Automated development workflows

**Key Resources**:
- [Dual Verification](Research/DUAL_VERIFICATION.md) - Training architecture
- [Implementation Status](ProjectInfo/IMPLEMENTATION_STATUS.md) - Current capabilities
- [Versioning](Development/VERSIONING.md) - Version policy

### I want to contribute to Logos

**Path**:
1. [Contributing Guide](Development/CONTRIBUTING.md) - Contribution workflow
2. [Implementation Status](ProjectInfo/IMPLEMENTATION_STATUS.md) - What's implemented
3. [Sorry Registry](ProjectInfo/SORRY_REGISTRY.md) - Technical debt tracking
4. [TODO](../TODO.md) - Active tasks

**Development Workflow**:
1. **Setup**: Fork repository, install dependencies
2. **Find Task**: Check TODO.md or Implementation Status
3. **Research**: Use `/research` command for background
4. **Plan**: Use `/plan` command for implementation plan
5. **Implement**: Follow TDD, use `/lean` command
6. **Test**: Ensure all tests pass
7. **Document**: Use `/document` command
8. **Submit**: Create PR following guidelines

**Key Resources**:
- [LEAN Style Guide](Development/LEAN_STYLE_GUIDE.md) - Coding standards
- [Testing Standards](Development/TESTING_STANDARDS.md) - Test requirements
- [Maintenance](ProjectInfo/MAINTENANCE.md) - TODO workflow
- [.opencode/README.md](../.opencode/README.md) - AI-assisted development

### I want to use the AI system

**Path**:
1. [.opencode/README.md](../.opencode/README.md) - AI system overview
2. [.opencode/QUICK-START.md](../.opencode/QUICK-START.md) - Step-by-step usage
3. [.opencode/command/README.md](../.opencode/command/README.md) - Command reference
4. [.opencode/agent/README.md](../.opencode/agent/README.md) - Agent catalog

**Available Commands**:
- `/research` - Multi-source research with LEAN library exploration
- `/plan` - Create detailed implementation plans
- `/lean` - Implement proofs with verification
- `/refactor` - Code quality improvements
- `/document` - Update documentation
- `/review` - Repository analysis and task identification
- `/meta` - Extend the AI system

**Key Resources**:
- [.opencode/ARCHITECTURE.md](../.opencode/ARCHITECTURE.md) - System design
- [.opencode/agent/subagents/specialists/README.md](../.opencode/agent/subagents/specialists/README.md) - 32 specialists
- [.opencode/context/README.md](../.opencode/context/README.md) - Context organization

---

## Complete File Listing

### UserGuide/ (6 files)
User-facing documentation for working with Logos:

- [ARCHITECTURE.md](UserGuide/ARCHITECTURE.md) - TM logic specification
- [EXAMPLES.md](UserGuide/EXAMPLES.md) - Usage examples and proof patterns
- [INTEGRATION.md](UserGuide/INTEGRATION.md) - Model-Checker integration
- [METHODOLOGY.md](UserGuide/METHODOLOGY.md) - Philosophical foundations
- [TACTIC_DEVELOPMENT.md](UserGuide/TACTIC_DEVELOPMENT.md) - Custom tactic development
- [TUTORIAL.md](UserGuide/TUTORIAL.md) - Getting started guide

### Development/ (10 files)
Developer standards, conventions, and contribution workflow:

- [CONTRIBUTING.md](Development/CONTRIBUTING.md) - Contribution guidelines
- [DIRECTORY_README_STANDARD.md](Development/DIRECTORY_README_STANDARD.md) - Documentation standard
- [DOC_QUALITY_CHECKLIST.md](Development/DOC_QUALITY_CHECKLIST.md) - Quality assurance
- [LEAN_STYLE_GUIDE.md](Development/LEAN_STYLE_GUIDE.md) - Coding conventions
- [METAPROGRAMMING_GUIDE.md](Development/METAPROGRAMMING_GUIDE.md) - LEAN 4 metaprogramming
- [MODULE_ORGANIZATION.md](Development/MODULE_ORGANIZATION.md) - Project structure
- [PHASED_IMPLEMENTATION.md](Development/PHASED_IMPLEMENTATION.md) - Implementation roadmap
- [QUALITY_METRICS.md](Development/QUALITY_METRICS.md) - Quality targets
- [TESTING_STANDARDS.md](Development/TESTING_STANDARDS.md) - Test requirements
- [VERSIONING.md](Development/VERSIONING.md) - Semantic versioning policy

### ProjectInfo/ (5 files)
Project status and tracking:

- [FEATURE_REGISTRY.md](ProjectInfo/FEATURE_REGISTRY.md) - Feature tracking and capabilities
- [IMPLEMENTATION_STATUS.md](ProjectInfo/IMPLEMENTATION_STATUS.md) - Module-by-module status
- [MAINTENANCE.md](ProjectInfo/MAINTENANCE.md) - TODO management workflow
- [SORRY_REGISTRY.md](ProjectInfo/SORRY_REGISTRY.md) - Technical debt tracking
- [TACTIC_REGISTRY.md](ProjectInfo/TACTIC_REGISTRY.md) - Tactic implementation status

### Research/ (5 files)
Research vision and planned architecture:

- [README.md](Research/README.md) - Research documentation overview
- [CONCEPTUAL_ENGINEERING.md](Research/CONCEPTUAL_ENGINEERING.md) - Philosophical methodology
- [DUAL_VERIFICATION.md](Research/DUAL_VERIFICATION.md) - RL training architecture
- [LAYER_EXTENSIONS.md](Research/LAYER_EXTENSIONS.md) - Layers 1-3 specifications
- [PROOF_LIBRARY_DESIGN.md](Research/PROOF_LIBRARY_DESIGN.md) - Theorem caching design

### Reference/ (2 files)
Quick reference materials:

- [GLOSSARY.md](Reference/GLOSSARY.md) - Terminology and key concepts
- [OPERATORS.md](Reference/OPERATORS.md) - Formal symbols reference

### AI System/ (.opencode/) (43+ files)
Context-aware development system:

**Core Documentation**:
- [README.md](../.opencode/README.md) - AI system overview
- [ARCHITECTURE.md](../.opencode/ARCHITECTURE.md) - System architecture
- [QUICK-START.md](../.opencode/QUICK-START.md) - Step-by-step usage
- [SYSTEM_SUMMARY.md](../.opencode/SYSTEM_SUMMARY.md) - Quick reference

**Agent System**:
- [agent/README.md](../.opencode/agent/README.md) - 12 primary agents
- [agent/subagents/specialists/README.md](../.opencode/agent/subagents/specialists/README.md) - 32 specialists

**Commands**:
- [command/README.md](../.opencode/command/README.md) - 12 commands

**Context**:
- [context/README.md](../.opencode/context/README.md) - Context organization
- [context/lean4/](../.opencode/context/lean4/) - LEAN 4 domain knowledge
- [context/logic/](../.opencode/context/logic/) - Logic domain knowledge

**Specifications**:
- [specs/README.md](../.opencode/specs/README.md) - Project artifacts

---

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
   - Update this NAVIGATION.md if new files added

6. **AI system changes**: Update .opencode/ documentation
   - New agents → agent/README.md
   - New commands → command/README.md
   - New context → context/README.md

---

## Documentation Standards

All documentation files follow:

- **Line limit**: 100 characters per line
- **Markdown formatting**: Standard Markdown conventions
- **Formal symbols**: Unicode operators must use backticks (e.g., `□`, `◇`, `△`, `▽`)
- **Headings**: Use ATX-style headings (`#`, `##`, `###`)
- **Code blocks**: Always specify language (```lean, ```bash)

For detailed documentation standards, see:
- [LEAN Style Guide - Code Comments](Development/LEAN_STYLE_GUIDE.md#code-comments-with-formal-symbols)

---

## Quick Command Reference

### AI System Commands

```bash
# Research
/research "topic"              # Multi-source research

# Planning
/plan "task description"       # Create implementation plan

# Implementation
/lean <project_id>             # Implement LEAN 4 proofs

# Code Quality
/refactor <file_path>          # Improve code quality

# Documentation
/document "topic"              # Update documentation

# Repository Analysis
/review                        # Analyze repository

# System Extension
/meta "agent/command request"  # Extend AI system
```

### Verification Commands

```bash
# Build and test
lake build                     # Build project
lake test                      # Run tests
lake lint                      # Run linter

# Check implementation
grep -c "sorry" Logos/**/*.lean           # Count sorry placeholders
grep -c "axiom" Logos/**/*.lean           # Count axioms

# Verify AI system
ls .opencode/agent/subagents/*.md | wc -l              # Count primary agents (12)
ls .opencode/agent/subagents/specialists/*.md | wc -l  # Count specialists (32)
```

---

## Related Resources

### External Documentation
- [LEAN 4 Manual](https://lean-lang.org/lean4/doc/) - Official LEAN 4 documentation
- [Mathlib4 Docs](https://leanprover-community.github.io/mathlib4_docs/) - Mathlib4 API
- [Lean Zulip](https://leanprover.zulipchat.com/) - Community chat

### Project Repositories
- [Logos](https://github.com/benbrastmckie/Logos) - This repository
- [Model-Checker](https://github.com/benbrastmckie/ModelChecker) - Semantic verification
- [LogicNotes](https://github.com/benbrastmckie/LogicNotes) - Theoretical foundations

### Research Papers
- Brast-McKie (2025) - "The Construction of Possible Worlds"
- Brast-McKie (2025) - "Counterfactual Worlds"
- Brast-McKie (2021) - "Identity and Aboutness"

---

_Last updated: 2025-12-20_
