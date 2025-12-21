# Web Research Findings: README.md Best Practices and Documentation Hierarchies

**Research Date:** December 20, 2025  
**Research Focus:** README.md best practices, documentation hierarchies, and patterns for AI/LLM-consumable documentation  
**Researcher:** Web Research Specialist

---

## Executive Summary

This research synthesizes best practices from authoritative sources including GitHub, Write the Docs, Google Style Guide, and the Diátaxis framework. Key findings emphasize that effective README hierarchies should be **minimal yet comprehensive**, **actively maintained**, and **structured around user needs**. For AI agent systems, documentation should follow the "Docs as Code" philosophy with clear separation of concerns, systematic organization, and machine-readable structure.

**Critical Insights:**
1. **Less is More**: A small set of fresh, accurate docs beats extensive but outdated documentation
2. **Hierarchical Clarity**: Each directory level should have a README that orients users and points to deeper resources
3. **Four Documentation Types**: Tutorials, How-to Guides, Reference, and Explanation serve distinct user needs
4. **Update with Code**: Documentation changes should accompany code changes in the same commit
5. **AI-Friendly Structure**: Systematic organization, consistent patterns, and clear navigation aids both humans and LLMs

---

## 1. README.md Best Practices for Developer Documentation

### 1.1 Core Principles from GitHub Documentation

**Source:** [GitHub Docs - About READMEs](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes)

#### Essential README Content
A README should communicate:
- **What the project does** - Clear, concise description
- **Why the project is useful** - Value proposition
- **How users can get started** - Installation and quickstart
- **Where users can get help** - Support channels
- **Who maintains and contributes** - Ownership and contribution info

#### README Placement Strategy
GitHub recognizes READMEs in this priority order:
1. `.github/` directory (highest priority)
2. Repository root directory
3. `docs/` directory

**Implication for .opencode/**: Place primary README at root, with subdirectory READMEs for navigation.

#### File Size Considerations
- Content beyond 500 KiB will be truncated
- Keep READMEs focused and link to detailed documentation

#### Auto-Generated Features
- **Table of Contents**: Automatically generated from section headings
- **Section Links**: Hoverable anchor links for all headings
- **Relative Links**: Use relative paths for cross-referencing within repo

### 1.2 Google's Documentation Best Practices

**Source:** [Google Style Guide - Documentation Best Practices](https://google.github.io/styleguide/docguide/best_practices.html)

#### Minimum Viable Documentation
> "A small set of fresh and accurate docs is better than a large assembly of 'documentation' in various states of disrepair."

**Key Principle**: Docs work best when they are **alive but frequently trimmed, like a bonsai tree**.

#### The Documentation Spectrum
Google identifies a hierarchy of documentation types:

1. **Meaningful Names** - Code that self-documents through clear naming
2. **Inline Comments** - Why the code exists, not what it does
3. **Method/Class Comments** - API contracts and usage
4. **README.md** - Directory orientation and pointers
5. **docs/** - Detailed guides and tutorials
6. **Design Docs/PRDs** - Architecture decisions (archived after implementation)
7. **External Docs** - Wikis, sites (linked from README)

#### README.md Specific Guidelines
A good README.md should answer:
- What is this directory intended to hold?
- Which files should developers look at first?
- Who maintains this directory?
- Where can I learn more?

#### Critical Rules
- **Update Docs with Code**: Change documentation in the same commit/PR as code changes
- **Delete Dead Documentation**: Dead docs are worse than no docs
- **Avoid Duplication**: Link to canonical sources, don't recreate them
- **Prefer Good Over Perfect**: Ship useful docs, iterate to improve

### 1.3 Write the Docs Community Standards

**Source:** [Write the Docs - Beginner's Guide](https://www.writethedocs.org/guide/writing/beginners-guide-to-docs/)

#### Why Write Documentation?
1. **Understand your code in 6 months** - Future you needs documentation
2. **Get people to use your code** - Solves discovery and adoption barriers
3. **Increase contributions** - Lowers barrier to entry for contributors
4. **Improve your code** - Writing docs forces design clarity
5. **Improve technical writing** - Practice makes perfect

#### What to Include
**For Users:**
- Problem the code solves
- Small code example
- Installation instructions
- Link to code and issue tracker

**For Developers:**
- How to contribute
- Development setup
- Testing instructions
- Code of conduct

#### README Template Structure
```markdown
$project
========

$project solves the problem of [clear problem statement]

Features
--------
- Feature 1
- Feature 2

Installation
------------
[Simple installation steps]

Contribute
----------
- Issue Tracker: [link]
- Source Code: [link]

Support
-------
[How to get help]

License
-------
[License type]
```

### 1.4 Awesome README Patterns

**Source:** [Awesome README Collection](https://github.com/matiassingers/awesome-readme)

#### Common Elements in Beautiful READMEs
- **Project Logo** - Visual identity
- **Badges** - Build status, version, coverage, etc.
- **GIF/Video Demos** - Show, don't just tell
- **Table of Contents** - Easy navigation for long READMEs
- **Clear Sections** - Consistent structure across projects
- **Code Examples** - Practical usage demonstrations
- **Screenshots** - Visual proof of functionality
- **Contributing Guidelines** - Clear contribution process
- **License Information** - Legal clarity

#### Anti-Patterns to Avoid
- Outdated information
- Overly long without structure
- Missing installation instructions
- No examples
- Unclear purpose
- Dead links

---

## 2. Documentation Patterns for AI Agent Systems

### 2.1 Docs as Code Philosophy

**Source:** [Write the Docs - Docs as Code](https://www.writethedocs.org/guide/docs-as-code/)

#### Core Principles
Documentation as Code means using the same tools as code:
- **Issue Trackers** - Track documentation bugs and improvements
- **Version Control (Git)** - Track changes, enable collaboration
- **Plain Text Markup** - Markdown, reStructuredText, AsciiDoc
- **Code Reviews** - Review documentation changes
- **Automated Tests** - Validate documentation accuracy

#### Benefits for AI/Agent Systems
1. **Integration with Development** - Writers and developers collaborate
2. **Automated Validation** - CI/CD can check docs for broken links, outdated info
3. **Version Synchronization** - Docs stay in sync with code
4. **Ownership Culture** - Everyone feels responsible for documentation

#### Implementation for .opencode/
- Store all documentation in Git alongside code
- Use Markdown for all documentation
- Implement automated checks for documentation quality
- Review documentation changes in PRs
- Use consistent file naming and directory structure

### 2.2 Context Management for LLMs

**Key Insight**: LLMs benefit from systematic, hierarchical organization with clear navigation paths.

#### Optimal Structure for AI Consumption
1. **Hierarchical Organization**
   - Top-level README provides overview and navigation
   - Each subdirectory has its own README
   - Deep nesting (3+ levels) should include breadcrumb navigation

2. **Consistent Patterns**
   - Use same section headings across similar documents
   - Maintain consistent file naming conventions
   - Use standard templates for common document types

3. **Explicit Cross-References**
   - Use relative links for internal references
   - Provide "See also" sections
   - Include navigation aids (TOC, breadcrumbs, "Back to top")

4. **Metadata and Context**
   - Include document purpose at the top
   - State intended audience
   - Provide last updated date
   - Link to related documents

#### Directory-Level README Pattern
```markdown
# [Directory Name]

**Purpose**: [One-line description]
**Audience**: [Who should read this]
**Last Updated**: [Date]

## Overview
[2-3 paragraph description of directory contents]

## Contents
- `file1.md` - [Description]
- `file2.md` - [Description]
- `subdir/` - [Description]

## Quick Start
[Most common use case]

## Related Documentation
- [Link to parent README]
- [Link to related directories]
- [Link to external resources]
```

### 2.3 Modular Knowledge Bases

**Principle**: Break documentation into focused, single-purpose modules that can be composed.

#### Module Design Patterns
1. **Concept Modules** - Define a single concept
2. **Process Modules** - Describe a workflow or procedure
3. **Reference Modules** - Provide lookup information
4. **Example Modules** - Demonstrate usage

#### Composition Strategies
- **Index Documents** - Aggregate related modules
- **Navigation Documents** - Guide users through learning paths
- **Cross-Reference Networks** - Link related concepts

#### For AI Agents
- Each module should be independently understandable
- Modules should declare their dependencies
- Use consistent structure within module types
- Provide machine-readable metadata (YAML frontmatter)

---

## 3. Technical Documentation Standards

### 3.1 The Diátaxis Framework

**Source:** [Diátaxis Documentation Framework](https://diataxis.fr/)

#### Four Documentation Types
Diátaxis identifies four distinct user needs and corresponding documentation forms:

| Type | Purpose | User Need | Form |
|------|---------|-----------|------|
| **Tutorials** | Learning-oriented | "I want to learn" | Lessons that teach |
| **How-to Guides** | Task-oriented | "I want to accomplish X" | Steps to solve problems |
| **Reference** | Information-oriented | "I need to look up X" | Technical descriptions |
| **Explanation** | Understanding-oriented | "I want to understand why" | Clarification and discussion |

#### The Diátaxis Map
```
                Study (Acquisition)
                        |
    Tutorials --------- + --------- Explanation
        |                               |
    Practical                       Theoretical
        |                               |
    How-to Guides ----- + --------- Reference
                        |
                Work (Application)
```

#### Application to .opencode/
- **Tutorials**: Step-by-step guides for new users (e.g., "Getting Started with .opencode")
- **How-to Guides**: Task-specific instructions (e.g., "How to Add a New Specialist")
- **Reference**: API documentation, command reference, file format specs
- **Explanation**: Architecture decisions, design philosophy, conceptual overviews

### 3.2 README Templates and Standard Sections

#### Comprehensive README Template
Based on synthesis of all sources:

```markdown
# Project Name

[Project logo/banner if applicable]

**[One-line description of what the project does]**

[Badges: build status, version, license, etc.]

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [Support](#support)
- [License](#license)

## Overview
[2-3 paragraphs explaining:
- What problem this solves
- Why it exists
- Who should use it]

## Features
- Feature 1 with brief description
- Feature 2 with brief description
- Feature 3 with brief description

## Installation
### Prerequisites
- Requirement 1
- Requirement 2

### Steps
```bash
# Installation commands
```

## Quick Start
```language
# Minimal working example
```

[Link to full documentation for advanced usage]

## Documentation
- [User Guide](docs/user-guide.md)
- [API Reference](docs/api-reference.md)
- [Architecture](docs/architecture.md)
- [Contributing Guide](CONTRIBUTING.md)

## Contributing
We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md).

- [Issue Tracker](link)
- [Source Code](link)
- [Code of Conduct](CODE_OF_CONDUCT.md)

## Support
- [Documentation](link)
- [FAQ](link)
- [Community Forum](link)
- [Email](email)

## License
[License name and link]

## Acknowledgments
[Credits and thanks]
```

### 3.3 Documentation Anti-Patterns

#### Common Mistakes to Avoid
1. **The FAQ Trap**
   - FAQs become dumping grounds for miscellaneous content
   - Quickly outdated
   - Hard to search and maintain
   - **Better**: Integrate answers into proper documentation sections

2. **The Duplication Problem**
   - Same information in multiple places
   - Inconsistencies when one copy is updated
   - **Better**: Single source of truth with links

3. **The Outdated Documentation Problem**
   - Documentation that contradicts current code
   - **Better**: Update docs with code changes, automated checks

4. **The Wall of Text**
   - No structure, headings, or visual breaks
   - **Better**: Use headings, lists, code blocks, images

5. **The Missing Context**
   - Assumes too much prior knowledge
   - **Better**: Define terms, link to prerequisites

### 3.4 Balancing Completeness vs. Conciseness

#### The Goldilocks Principle
- **Too Short**: Users can't accomplish their goals
- **Too Long**: Users can't find what they need
- **Just Right**: Comprehensive but well-organized

#### Strategies
1. **Progressive Disclosure**
   - Start with essentials
   - Link to detailed documentation
   - Use expandable sections for optional content

2. **Layered Documentation**
   - README: Quick overview and navigation
   - Getting Started: First steps
   - User Guide: Comprehensive usage
   - Reference: Complete API/command documentation
   - Architecture: Deep technical details

3. **The 80/20 Rule**
   - README covers 80% of use cases
   - Detailed docs cover the remaining 20%

### 3.5 Maintenance and Update Strategies

#### Keeping Documentation Fresh
1. **Documentation Debt**
   - Track documentation issues like code bugs
   - Regular documentation review cycles
   - Assign documentation ownership

2. **Automated Checks**
   - Link validation
   - Code example testing
   - Version number consistency
   - Spelling and grammar

3. **Documentation Reviews**
   - Include docs in code review process
   - Require documentation updates for new features
   - Block merges without documentation

4. **Deprecation Strategy**
   - Mark outdated sections clearly
   - Provide migration paths
   - Remove deprecated content after grace period

---

## 4. Specific Recommendations for .opencode/ Directory Structure

### 4.1 Current State Analysis

The `.opencode/` directory currently contains:
- `agent/` - Agent and specialist definitions
- `command/` - Command specifications
- `.opencode/context/` - Domain knowledge and standards
- `specs/` - Task specifications and work products
- Top-level documentation files

### 4.2 README Hierarchy Recommendations

#### Level 1: .opencode/README.md (Root)
**Purpose**: Orient users to the entire .opencode system

**Recommended Structure**:
```markdown
# .opencode/ - AI Agent System Documentation

**Purpose**: This directory contains all documentation and specifications for the AI agent system that assists with ProofChecker development.

## Quick Navigation
- [Agent System](agent/README.md) - Agent architecture and specialist definitions
- [Commands](command/README.md) - Available commands and their usage
- [Context](.opencode/context/README.md) - Domain knowledge and standards
- [Specifications](specs/README.md) - Task specifications and work products

## Overview
[2-3 paragraphs explaining the .opencode system]

## Getting Started
[Link to getting started guide]

## Architecture
[Link to ARCHITECTURE.md]

## For Contributors
[Link to contribution guidelines]
```

#### Level 2: Subdirectory READMEs

**agent/README.md**:
```markdown
# Agent System

**Purpose**: Defines the orchestrator, subagents, and specialists that comprise the AI agent system.

## Directory Structure
- `orchestrator.md` - Main orchestrator specification
- `subagents/` - Subagent definitions
  - `specialists/` - Specialist agent definitions

## Agent Hierarchy
[Diagram or description of agent relationships]

## Adding a New Specialist
[Link to how-to guide]

## See Also
- [Command Reference](../command/README.md)
- [Architecture](../ARCHITECTURE.md)
```

**command/README.md**:
```markdown
# Command Reference

**Purpose**: Specifications for all available commands in the .opencode system.

## Available Commands
- `add.md` - Add new tasks
- `document.md` - Generate documentation
- `implement.md` - Implement features
- [etc.]

## Command Structure
[Explanation of command specification format]

## See Also
- [Agent System](../agent/README.md)
- [Task Workflow](../context/workflows/README.md)
```

**context/README.md**:
```markdown
# Context - Domain Knowledge and Standards

**Purpose**: Centralized knowledge base for domain concepts, standards, and best practices.

## Organization
- `lean4/` - Lean 4 language and ecosystem knowledge
- `logic/` - Logic and proof theory concepts
- `math/` - Mathematical concepts
- `repo/` - Repository-specific standards

## Using Context Documents
[Explanation of how agents use context]

## Contributing to Context
[Guidelines for adding new context]
```

**specs/README.md**:
```markdown
# Specifications - Task Work Products

**Purpose**: Contains all task specifications, plans, reports, and work products.

## Directory Structure
Each task gets a directory named `NNN_task_name/` containing:
- `state.json` - Task state tracking
- `plans/` - Implementation plans
- `reports/` - Research and analysis reports
- `summaries/` - Task summaries

## Task Lifecycle
[Explanation of task states and workflow]

## Archive Policy
[When and how tasks are archived]

## See Also
- [Task Command](../command/task.md)
- [State Schema](../context/repo/state-schema.md)
```

#### Level 3: Specialist READMEs

For directories with many similar files (e.g., `agent/subagents/specialists/`):

```markdown
# Specialists

**Purpose**: Specialized agents for specific technical tasks.

## Available Specialists
### Code Analysis
- `complexity-analyzer.md` - Analyzes code complexity
- `dependency-analyzer.md` - Maps dependencies
- `style-checker.md` - Enforces style guidelines

### Documentation
- `doc-analyzer.md` - Analyzes documentation quality
- `doc-writer.md` - Generates documentation
- `documentation-generator.md` - Creates comprehensive docs

[etc., organized by category]

## Specialist Template
[Link to template for creating new specialists]

## See Also
- [Subagent Overview](../README.md)
- [Creating Specialists](../../docs/creating-specialists.md)
```

### 4.3 Navigation Patterns

#### Breadcrumb Navigation
Include at top of deep documents:
```markdown
[.opencode](../../README.md) > [context](../README.md) > [lean4](README.md) > processes
```

#### Cross-Reference Sections
Include at bottom of documents:
```markdown
## Related Documentation
- [Parent Topic](../README.md)
- [Related Concept](../related/concept.md)
- [External Resource](https://example.com)

## See Also
- [Glossary](../../glossary.md)
- [Index](../../index.md)
```

#### Index Documents
Create index documents for large sections:
```markdown
# Index - Lean 4 Context

## By Category
### Syntax
- [Formula Syntax](syntax/formula.md)
- [Tactic Syntax](syntax/tactics.md)

### Semantics
- [Kripke Semantics](semantics/kripke.md)
- [Truth Definitions](semantics/truth.md)

## Alphabetical
- [Axioms](proof-system/axioms.md)
- [Completeness](metalogic/completeness.md)
[etc.]
```

### 4.4 Metadata Standards

#### YAML Frontmatter
For machine-readable metadata:
```yaml
---
title: "Document Title"
type: "reference|tutorial|how-to|explanation"
audience: "developers|users|contributors"
status: "draft|review|published|deprecated"
last_updated: "2025-12-20"
tags: ["tag1", "tag2"]
related:
  - path/to/related1.md
  - path/to/related2.md
---
```

#### Document Headers
For human-readable context:
```markdown
# Document Title

**Purpose**: [One-line description]
**Audience**: [Who should read this]
**Prerequisites**: [What you should know first]
**Last Updated**: December 20, 2025

[Document content...]
```

---

## 5. Implementation Recommendations

### 5.1 Immediate Actions

1. **Create Missing READMEs**
   - `.opencode/README.md` - System overview
   - `.opencode/agent/README.md` - Agent system guide
   - `.opencode/command/README.md` - Command reference
   - `.opencode/context/README.md` - Context organization
   - `.opencode/specs/README.md` - Specifications guide

2. **Standardize Existing Documentation**
   - Add consistent headers to all documents
   - Include navigation aids (TOC, breadcrumbs)
   - Add cross-references and "See Also" sections

3. **Implement Documentation Standards**
   - Create templates for common document types
   - Define metadata standards
   - Establish naming conventions

### 5.2 Medium-Term Improvements

1. **Documentation Testing**
   - Automated link checking
   - Code example validation
   - Consistency checks

2. **Documentation Review Process**
   - Include docs in PR reviews
   - Regular documentation audits
   - Deprecation and cleanup cycles

3. **Enhanced Navigation**
   - Create comprehensive index
   - Build glossary of terms
   - Develop learning paths

### 5.3 Long-Term Vision

1. **Interactive Documentation**
   - Searchable documentation
   - Interactive examples
   - Version-aware documentation

2. **Documentation Metrics**
   - Track documentation coverage
   - Monitor documentation usage
   - Measure documentation quality

3. **Community Documentation**
   - Contribution guidelines
   - Documentation style guide
   - Community examples and tutorials

---

## 6. Key Takeaways

### For README Files
1. **Keep them fresh** - Better to have less documentation that's accurate than more that's outdated
2. **Orient, don't overwhelm** - README should point to detailed docs, not contain everything
3. **Update with code** - Documentation changes should accompany code changes
4. **Use hierarchy** - Each directory level should have its own README
5. **Link, don't duplicate** - Single source of truth with cross-references

### For AI/LLM Consumption
1. **Systematic organization** - Consistent patterns and structure
2. **Explicit navigation** - Clear paths between related documents
3. **Modular design** - Self-contained, composable documentation units
4. **Rich metadata** - Both human and machine-readable context
5. **Progressive disclosure** - Layer information from overview to detail

### For Documentation Quality
1. **Four types matter** - Tutorials, How-to, Reference, Explanation serve different needs
2. **Delete dead docs** - Outdated documentation is worse than no documentation
3. **Docs as code** - Use same tools and workflows as code development
4. **Test your docs** - Automated validation catches errors early
5. **Iterate continuously** - Documentation is never "done"

---

## 7. References and Sources

### Primary Sources
1. **GitHub Documentation**
   - [About READMEs](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes)
   - Official guidance on README files and repository documentation

2. **Write the Docs**
   - [Beginner's Guide to Documentation](https://www.writethedocs.org/guide/writing/beginners-guide-to-docs/)
   - [Docs as Code](https://www.writethedocs.org/guide/docs-as-code/)
   - Community-driven best practices and standards

3. **Google Style Guide**
   - [Documentation Best Practices](https://google.github.io/styleguide/docguide/best_practices.html)
   - Industry-leading documentation standards

4. **Diátaxis Framework**
   - [Diátaxis Documentation System](https://diataxis.fr/)
   - Systematic approach to documentation organization

5. **Awesome README**
   - [Curated List of Great READMEs](https://github.com/matiassingers/awesome-readme)
   - Examples and patterns from successful projects

6. **Make a README**
   - [README Guide and Template](https://www.makeareadme.com/)
   - Practical guide with editable template

### Recommended Reading
- "Docs Like Code" by Anne Gentle
- "Modern Technical Writing" by Andrew Etter
- "Crafting Docs for Success" by Diana Lakatos
- "Docs for Developers" by Jared Bhatti et al.

### Tools and Resources
- [CommonMark](https://commonmark.org/) - Markdown specification
- [Shields.io](https://shields.io/) - Badge generation
- [Read the Docs](https://readthedocs.org/) - Documentation hosting
- [MkDocs](https://www.mkdocs.org/) - Documentation site generator

---

## Appendix A: README Checklist

Use this checklist when creating or reviewing README files:

### Essential Elements
- [ ] Clear project name
- [ ] One-line description
- [ ] Table of contents (for long READMEs)
- [ ] Overview/description section
- [ ] Installation instructions
- [ ] Quick start example
- [ ] Link to full documentation
- [ ] Contributing guidelines
- [ ] License information

### Quality Indicators
- [ ] Up-to-date information
- [ ] Working code examples
- [ ] Valid links
- [ ] Clear structure with headings
- [ ] Appropriate length (not too short, not too long)
- [ ] Visual aids (screenshots, diagrams) where helpful
- [ ] Contact/support information

### Navigation Aids
- [ ] Links to related documentation
- [ ] Breadcrumb navigation (for deep hierarchies)
- [ ] "See also" section
- [ ] Back to top links (for long documents)

### Maintenance
- [ ] Last updated date
- [ ] Ownership/maintainer information
- [ ] Deprecation notices (if applicable)
- [ ] Migration guides (if applicable)

---

## Appendix B: Documentation Templates

### Template: Directory README
```markdown
# [Directory Name]

**Purpose**: [One-line description of directory contents]
**Last Updated**: [Date]

## Overview
[2-3 paragraphs explaining what this directory contains and why it exists]

## Contents
- `file1.md` - [Brief description]
- `file2.md` - [Brief description]
- `subdirectory/` - [Brief description]

## Quick Reference
[Most common use cases or entry points]

## Organization
[Explanation of how contents are organized]

## Related Documentation
- [Link to parent README]
- [Link to related directories]
- [Link to external resources]

## Contributing
[Guidelines for adding to this directory]
```

### Template: Specialist Definition
```markdown
# [Specialist Name]

**Role**: [One-line description of specialist's purpose]
**Domain**: [Primary domain of expertise]
**Last Updated**: [Date]

## Purpose
[Detailed explanation of what this specialist does and when to use it]

## Capabilities
- Capability 1
- Capability 2
- Capability 3

## Input Requirements
[What information the specialist needs to function]

## Output Format
[What the specialist produces]

## Usage Examples
[Concrete examples of specialist invocation]

## Related Specialists
- [Link to related specialist 1]
- [Link to related specialist 2]

## See Also
- [Link to relevant context]
- [Link to relevant commands]
```

### Template: How-To Guide
```markdown
# How to [Task Name]

**Goal**: [What you'll accomplish]
**Prerequisites**: [What you need to know/have first]
**Time Required**: [Estimated time]
**Last Updated**: [Date]

## Overview
[Brief explanation of the task and why you'd do it]

## Steps

### Step 1: [First Step]
[Detailed instructions]

```language
# Code example if applicable
```

### Step 2: [Second Step]
[Detailed instructions]

### Step 3: [Third Step]
[Detailed instructions]

## Verification
[How to verify you've completed the task successfully]

## Troubleshooting
[Common issues and solutions]

## Next Steps
[What to do after completing this task]

## Related Guides
- [Link to related how-to]
- [Link to related tutorial]
```

---

**End of Research Findings**

*This document synthesizes best practices from multiple authoritative sources to provide comprehensive guidance on README files and documentation hierarchies, with specific focus on AI/LLM-consumable documentation patterns.*
