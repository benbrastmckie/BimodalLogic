# Research Report: .opencode/ README Documentation Implementation Plan

**Project**: #066_opencode_readme_documentation  
**Date**: December 20, 2025  
**Research Type**: Comprehensive (Directory Analysis + Documentation Standards + Best Practices)  
**Researcher**: Research Coordinator

---

## Executive Summary

This research provides a systematic implementation plan for adding README.md files to the
.opencode/ directory structure. Analysis reveals that the .opencode/ system currently has
**4 existing README files** but is missing **critical navigation READMEs** in 8+ subdirectories.
The research synthesizes documentation standards from multiple sources to create a practical,
maintainable README hierarchy optimized for both human developers and AI agent consumption.

**Key Findings:**
1. Current .opencode/ has excellent top-level README but lacks subdirectory navigation
2. Documentation standards emphasize "fresh and minimal" over "comprehensive but stale"
3. AI agents benefit from hierarchical organization with consistent patterns
4. Recommended approach: Add 8 strategic READMEs following 3 standard templates
5. Implementation complexity: LOW (2-3 hours total effort)

---

## Research Question

**Primary Question**: How should we systematically add README.md files to .opencode/
subdirectories to improve navigation and AI agent context understanding?

**Sub-Questions**:
1. Which subdirectories need README files?
2. What should each README contain?
3. What templates/standards should we follow?
4. How do we maintain consistency and avoid documentation bloat?

---

## Sources Consulted

### Internal Sources
- **.opencode/ directory structure** - Complete mapping of 4 top-level directories
- **documentation-standards.md** - .opencode AI system documentation conventions
- **artifact-management.md** - Artifact organization standards
- **Existing READMEs** - Analysis of 4 current README files
- **DIRECTORY_README_STANDARD.md** - LEAN 4 project README conventions

### External Sources (via web-research-specialist)
- **GitHub Documentation** - Official README best practices
- **Google Style Guide** - Documentation best practices
- **Write the Docs** - Community-driven documentation standards
- **Diátaxis Framework** - Four documentation types (Tutorial, How-to, Reference, Explanation)
- **Awesome README** - Curated examples and patterns

**Specialist Report**: `.opencode/specs/066_opencode_readme_documentation/findings/
web-research-findings.md`

---

## Section 1: Current .opencode/ Directory Structure

### 1.1 Complete Directory Map

```
.opencode/
├── README.md                           ✅ EXISTS (279 lines, comprehensive)
├── ARCHITECTURE.md                     ✅ EXISTS
├── QUICK-START.md                      ✅ EXISTS
├── TESTING.md                          ✅ EXISTS
├── STATUS_MARKER_STANDARDIZATION_SUMMARY.md  ✅ EXISTS
│
├── agent/                              ❌ NO README
│   ├── orchestrator.md
│   └── subagents/                      ❌ NO README
│       ├── batch-task-orchestrator.md
│       ├── documenter.md
│       ├── implementation-orchestrator.md
│       ├── implementer.md
│       ├── meta.md
│       ├── planner.md
│       ├── proof-developer.md
│       ├── refactorer.md
│       ├── researcher.md
│       ├── reviewer.md
│       ├── task-adder.md
│       ├── task-executor.md
│       └── specialists/                ❌ NO README (31 files!)
│           ├── batch-status-manager.md
│           ├── code-reviewer.md
│           ├── complexity-analyzer.md
│           ├── concept-explainer.md
│           ├── dependency-analyzer.md
│           ├── dependency-mapper.md
│           ├── doc-analyzer.md
│           ├── doc-writer.md
│           ├── documentation-generator.md
│           ├── error-diagnostics.md
│           ├── example-builder.md
│           ├── git-workflow-manager.md
│           ├── lean-search-specialist.md
│           ├── learning-path-generator.md
│           ├── library-navigator.md
│           ├── loogle-specialist.md
│           ├── metaprogramming-specialist.md
│           ├── performance-profiler.md
│           ├── proof-optimizer.md
│           ├── proof-simplifier.md
│           ├── proof-strategy-advisor.md
│           ├── refactoring-assistant.md
│           ├── style-checker.md
│           ├── syntax-validator.md
│           ├── tactic-recommender.md
│           ├── tactic-specialist.md
│           ├── task-dependency-analyzer.md
│           ├── term-mode-specialist.md
│           ├── test-generator.md
│           ├── todo-manager.md
│           └── verification-specialist.md
│
├── command/                            ❌ NO README
│   ├── add.md
│   ├── document.md
│   ├── implement.md
│   ├── lean.md
│   ├── meta.md
│   ├── plan.md
│   ├── refactor.md
│   ├── research.md
│   ├── review.md
│   ├── revise.md
│   ├── task.md
│   └── todo.md
│
├── .opencode/context/                            ✅ HAS README (331 lines, excellent)
│   ├── README.md
│   ├── lean4/                          ❌ NO README
│   │   ├── processes/
│   │   │   └── maintenance-workflow.md
│   │   └── templates/
│   │       └── maintenance-report-template.md
│   ├── logic/                          ❌ NO README
│   │   ├── domain/
│   │   │   ├── metalogic-concepts.md
│   │   │   ├── proof-theory-concepts.md
│   │   │   ├── task-semantics.md
│   │   │   └── kripke-semantics-overview.md
│   ├── math/                           ❌ NO README
│   │   ├── algebra/
│   │   │   ├── groups-and-monoids.md
│   │   │   └── rings-and-fields.md
│   │   ├── lattice-theory/
│   │   │   └── lattices.md
│   │   ├── order-theory/
│   │   │   └── partial-orders.md
│   │   └── topology/
│   │       └── topological-spaces.md
│   ├── physics/                        ❌ NO README
│   │   └── dynamical-systems/
│   │       └── dynamical-systems.md
│   └── repo/                           ❌ NO README
│       ├── documentation-standards.md
│       ├── project-structure.md
│       ├── state-schema.md
│       └── status-markers.md
│
└── specs/                              ❌ NO README
    ├── TODO.md
    ├── state.json
    ├── 002_lean_test_moderate/
    ├── 003_lean_test_complex/
    ├── 005_research_task_vs_lean_implement/
    ├── 006_enhance_task_routing/
    ├── 006_review_20251220/
    ├── 057_deep_embedding_research/
    ├── 060_remove_backup_artifacts/
    ├── 064_git_workflow_manager/
    ├── 065_logic_processes/
    ├── 072_phase1_migration/
    ├── 075_automation_migration/        ✅ HAS README (project-specific)
    ├── 076_test_migration/
    ├── 077_documentation_updates/
    ├── 078_final_verification/
    ├── archive/
    ├── lean_command_enhancement/        ✅ HAS README (project-specific)
    └── maintenance/
```

### 1.2 Gap Analysis

**Existing READMEs (4)**:
1. `.opencode/README.md` - Excellent system overview (279 lines)
2. `.opencode/context/README.md` - Excellent context organization guide (331 lines)
3. `.opencode/specs/075_automation_migration/README.md` - Project-specific
4. `.opencode/specs/lean_command_enhancement/README.md` - Project-specific

**Missing READMEs (8 critical)**:
1. `.opencode/agent/README.md` - Agent system overview
2. `.opencode/agent/subagents/README.md` - Subagent organization
3. `.opencode/agent/subagents/specialists/README.md` - Specialist catalog (31 files!)
4. `.opencode/command/README.md` - Command reference
5. `.opencode/context/lean4/README.md` - LEAN 4 context organization
6. `.opencode/context/logic/README.md` - Logic context organization
7. `.opencode/context/math/README.md` - Math context organization
8. `.opencode/specs/README.md` - Specifications and task workflow

**Optional READMEs (not recommended)**:
- `.opencode/context/repo/` - Only 4 files, parent README sufficient
- `.opencode/context/physics/` - Only 1 subdirectory, parent README sufficient
- Individual project directories in specs/ - Use project-specific READMEs as needed

---

## Section 2: Documentation Standards Analysis

### 2.1 Key Principles from documentation-standards.md

**Core Principles**:
1. **Clear**: Use precise technical language without ambiguity
2. **Concise**: Avoid bloat, historical mentions, and redundancy
3. **Accurate**: Document current state only, not past versions or future plans
4. **Consistent**: Follow established patterns and conventions
5. **AI-Optimized**: Structure for efficient AI agent parsing and understanding

**Directory README Standards** (from documentation-standards.md):

**When README Required**:
- Top-level source directories
- Test directories with 3+ subdirectories
- Example/archive directories
- Multi-subdirectory documentation roots

**When README Not Required**:
- Single-module directories with excellent module documentation
- Subdirectories when parent README provides sufficient navigation
- Build/output directories
- Directories with <3 files that are self-explanatory

**README Structure**:
1. **Title**: Directory name as H1
2. **Purpose**: 1-2 sentence description
3. **Organization**: Subdirectory listing with brief descriptions
4. **Quick Reference**: Where to find specific functionality
5. **Usage**: How to build, test, or run (if applicable)
6. **Related Documentation**: Links to relevant docs

**README Anti-Patterns**:
- Duplicating module docstrings
- Describing files/structure that no longer exists
- Creating READMEs for simple directories
- Including implementation details better suited for code comments

### 2.2 Best Practices from Web Research

**Google's "Minimum Viable Documentation" Principle**:
> "A small set of fresh and accurate docs is better than a large assembly of
> 'documentation' in various states of disrepair."

**Key Insight**: Docs work best when they are **"alive but frequently trimmed, like a
bonsai tree"**.

**The Documentation Spectrum** (from least to most detailed):
1. Meaningful names (self-documenting code)
2. Inline comments (why, not what)
3. Method/class comments (API contracts)
4. **README.md** (directory orientation and pointers) ← Our focus
5. docs/ (detailed guides and tutorials)
6. Design docs (architecture decisions)
7. External docs (wikis, sites)

**Diátaxis Framework - Four Documentation Types**:
1. **Tutorials** - Learning-oriented ("I want to learn")
2. **How-to Guides** - Task-oriented ("I want to accomplish X")
3. **Reference** - Information-oriented ("I need to look up X")
4. **Explanation** - Understanding-oriented ("I want to understand why")

**Application to .opencode/ READMEs**:
- READMEs should be **Reference** type (information-oriented)
- Focus on **navigation** and **quick lookup**
- Link to **How-to Guides** and **Explanations** in other docs

**AI/LLM Consumption Best Practices**:
1. **Hierarchical Organization** - Each directory level has its own README
2. **Consistent Patterns** - Same section headings across similar documents
3. **Explicit Cross-References** - Relative links, "See also" sections
4. **Metadata and Context** - Purpose, audience, last updated date

---

## Section 3: Existing README Analysis

### 3.1 .opencode/README.md Analysis

**Strengths**:
- Comprehensive system overview (279 lines)
- Clear architecture description
- Excellent quick start examples
- Well-organized project structure diagram
- Good workflow examples
- Performance characteristics included

**Structure**:
1. Overview
2. System Architecture (orchestrator, agents, specialists)
3. Quick Start (7 command examples)
4. Custom Commands
5. Project Structure (directory tree)
6. Key Features
7. Workflow Examples
8. Context Files
9. Performance Characteristics
10. Next Steps
11. Documentation links
12. Support

**Lessons Learned**:
- Comprehensive top-level README is valuable
- Directory tree visualization aids understanding
- Workflow examples demonstrate usage
- Links to detailed documentation prevent bloat

### 3.2 .opencode/context/README.md Analysis

**Strengths**:
- Excellent organization guide (331 lines)
- Clear directory structure with descriptions
- Context allocation levels explained
- File size guidelines provided
- Usage guidelines for agents
- Context protection pattern explained
- Maintenance guidelines included

**Structure**:
1. Overview
2. Directory Structure (detailed tree)
3. Context Categories (lean4/, logic/, math/, physics/, repo/, core/, builder-templates/,
   project/)
4. Usage Guidelines (context allocation levels)
5. File Size Guidelines
6. Naming Conventions
7. How Agents Use Context
8. Context Protection Pattern
9. Adding New Context
10. Context File Structure
11. Maintenance
12. Future Additions
13. Performance Characteristics
14. References

**Lessons Learned**:
- Detailed subdirectory descriptions are valuable
- Explaining how agents use the directory is important
- Maintenance guidelines prevent documentation decay
- Future additions section provides roadmap

### 3.3 Project-Specific README Analysis

**075_automation_migration/README.md** (214 lines):
- Task-specific overview
- Artifacts listing with descriptions
- Quick summary of changes
- Technical highlights
- Validation checklist
- Context (migration timeline)
- Related documentation
- Files modified
- Lessons learned
- Next steps

**lean_command_enhancement/README.md** (479 lines):
- Comprehensive project documentation
- Quick links to detailed docs
- Architecture overview
- Performance metrics
- Flag reference
- Example scenarios
- Project status
- Documentation index

**Lessons Learned**:
- Project-specific READMEs can be more detailed
- Quick links section aids navigation
- Status tracking is valuable
- Examples and metrics demonstrate value

---

## Section 4: Recommended README Templates

### 4.1 Template A: Agent/Command Directory README

**Use Case**: `.opencode/agent/README.md`, `.opencode/command/README.md`

**Target Length**: 60-100 lines

**Structure**:
```markdown
# [Directory Name]

**Purpose**: [One-line description]  
**Last Updated**: [Date]

## Overview

[2-3 paragraphs explaining what this directory contains and its role in the system]

## Directory Structure

- `file1.md` - [Brief description]
- `file2.md` - [Brief description]
- `subdirectory/` - [Brief description with link to subdirectory README]

## Quick Reference

[Table or list of most commonly accessed files/features]

## Usage

[How agents/users interact with these files]

## Related Documentation

- [Link to parent README]
- [Link to related directories]
- [Link to architecture docs]

## Contributing

[Guidelines for adding new agents/commands]
```

### 4.2 Template B: Specialist Catalog README

**Use Case**: `.opencode/agent/subagents/specialists/README.md`

**Target Length**: 100-150 lines

**Structure**:
```markdown
# Specialist Subagents

**Purpose**: Specialized agents for specific technical tasks  
**Last Updated**: [Date]

## Overview

[2-3 paragraphs explaining specialist role in the system]

## Available Specialists

### [Category 1]
- **[specialist-name.md]** - [One-line description]
- **[specialist-name.md]** - [One-line description]

### [Category 2]
- **[specialist-name.md]** - [One-line description]
- **[specialist-name.md]** - [One-line description]

[Repeat for all categories]

## Specialist Categories

[Explanation of how specialists are organized]

## Using Specialists

[How to invoke specialists, routing patterns]

## Adding New Specialists

[Link to specialist template and creation guide]

## Related Documentation

- [Link to subagent overview]
- [Link to orchestrator]
- [Link to builder templates]
```

**Categories for Specialists**:
1. **Proof Development** (5 specialists)
2. **Code Quality** (4 specialists)
3. **Documentation** (4 specialists)
4. **Research** (3 specialists)
5. **Analysis** (5 specialists)
6. **Workflow** (3 specialists)
7. **Testing** (2 specialists)
8. **Learning** (2 specialists)
9. **Utilities** (3 specialists)

### 4.3 Template C: Context Domain README

**Use Case**: `.opencode/context/lean4/README.md`, `.opencode/context/logic/README.md`,
`.opencode/context/math/README.md`

**Target Length**: 80-120 lines

**Structure**:
```markdown
# [Domain Name] Context

**Purpose**: [Domain] knowledge for AI agents  
**Last Updated**: [Date]

## Overview

[2-3 paragraphs explaining this domain's role in the system]

## Organization

This directory is organized into:

### [Subdirectory 1]/
[Description of subdirectory purpose and contents]

Files:
- `file1.md` - [Description]
- `file2.md` - [Description]

### [Subdirectory 2]/
[Description of subdirectory purpose and contents]

Files:
- `file1.md` - [Description]
- `file2.md` - [Description]

## Quick Reference

[Table mapping concepts to files]

## Usage by Agents

[How agents use this context, context allocation patterns]

## Adding New Context

[Guidelines for adding new context files to this domain]

## Related Context

- [Link to related domain context]
- [Link to parent context README]
- [Link to external resources]
```

### 4.4 Template D: Specs Directory README

**Use Case**: `.opencode/specs/README.md`

**Target Length**: 100-150 lines

**Structure**:
```markdown
# Specifications - Task Work Products

**Purpose**: Task specifications, plans, reports, and work products  
**Last Updated**: [Date]

## Overview

[2-3 paragraphs explaining specs directory organization and purpose]

## Directory Structure

Each task gets a directory named `NNN_task_name/` containing:
- `state.json` - Task state tracking
- `plans/` - Implementation plans (versioned)
- `reports/` - Research and analysis reports
- `summaries/` - Brief summaries
- `README.md` - Project-specific overview (optional)

## Special Directories

### TODO.md
[Description of master task list]

### state.json
[Description of global state file]

### archive/
[Description of archived tasks]

### maintenance/
[Description of maintenance reports]

## Task Lifecycle

[Explanation of task states and workflow]

## Project Numbering

[Explanation of NNN numbering scheme]

## Archive Policy

[When and how tasks are archived]

## Related Documentation

- [Link to project-structure.md]
- [Link to state-schema.md]
- [Link to task command]
```

---

## Section 5: Implementation Recommendations

### 5.1 Priority Mapping

**High Priority (Create First)**:
1. `.opencode/agent/README.md` - Critical for understanding agent system
2. `.opencode/agent/subagents/specialists/README.md` - 31 files need organization!
3. `.opencode/command/README.md` - Essential for command reference
4. `.opencode/specs/README.md` - Important for task workflow understanding

**Medium Priority (Create Second)**:
5. `.opencode/context/lean4/README.md` - Helps navigate LEAN 4 context
6. `.opencode/context/logic/README.md` - Helps navigate logic context
7. `.opencode/context/math/README.md` - Helps navigate math context

**Low Priority (Optional)**:
8. `.opencode/agent/subagents/README.md` - Only 12 files, may not need separate README

### 5.2 Recommended Content for Each README

#### 1. .opencode/agent/README.md

**Template**: A (Agent/Command Directory)  
**Estimated Length**: 80-100 lines

**Key Sections**:
- Overview of agent system architecture
- Directory structure (orchestrator.md, subagents/)
- Agent hierarchy (orchestrator → subagents → specialists)
- Quick reference table of primary agents
- How agents are invoked
- Link to subagents/ README
- Link to ARCHITECTURE.md
- Contributing guidelines (how to add new agents)

**Quick Reference Table**:
| Agent | Purpose | File |
|-------|---------|------|
| Orchestrator | Main coordinator | orchestrator.md |
| Reviewer | Repository analysis | subagents/reviewer.md |
| Researcher | Multi-source research | subagents/researcher.md |
| ... | ... | ... |

#### 2. .opencode/agent/subagents/specialists/README.md

**Template**: B (Specialist Catalog)  
**Estimated Length**: 120-150 lines

**Key Sections**:
- Overview of specialist role
- Available specialists organized by category
- Specialist categories explanation
- Using specialists (routing patterns)
- Adding new specialists
- Related documentation

**Specialist Categories**:
1. **Proof Development** (5): tactic-specialist, term-mode-specialist,
   metaprogramming-specialist, proof-strategy-advisor, tactic-recommender
2. **Code Quality** (4): code-reviewer, style-checker, refactoring-assistant,
   syntax-validator
3. **Documentation** (4): doc-analyzer, doc-writer, documentation-generator,
   concept-explainer
4. **Research** (3): lean-search-specialist, loogle-specialist, web-research-specialist
5. **Analysis** (5): complexity-analyzer, dependency-analyzer, dependency-mapper,
   performance-profiler, verification-specialist
6. **Workflow** (3): git-workflow-manager, todo-manager, batch-status-manager
7. **Testing** (2): test-generator, example-builder
8. **Learning** (2): learning-path-generator, library-navigator
9. **Optimization** (3): proof-optimizer, proof-simplifier, error-diagnostics

#### 3. .opencode/command/README.md

**Template**: A (Agent/Command Directory)  
**Estimated Length**: 90-110 lines

**Key Sections**:
- Overview of command system
- Available commands with descriptions
- Command structure explanation
- Usage examples
- Related documentation (agent system, workflows)

**Command Table**:
| Command | Purpose | Agent |
|---------|---------|-------|
| /review | Repository analysis | reviewer |
| /research | Multi-source research | researcher |
| /plan | Implementation planning | planner |
| ... | ... | ... |

#### 4. .opencode/specs/README.md

**Template**: D (Specs Directory)  
**Estimated Length**: 110-140 lines

**Key Sections**:
- Overview of specs directory
- Directory structure (NNN_task_name/ pattern)
- Special directories (TODO.md, state.json, archive/, maintenance/)
- Task lifecycle explanation
- Project numbering scheme
- Archive policy
- Related documentation

#### 5. .opencode/context/lean4/README.md

**Template**: C (Context Domain)  
**Estimated Length**: 80-100 lines

**Key Sections**:
- Overview of LEAN 4 context
- Organization (processes/, templates/)
- Quick reference (concept → file mapping)
- Usage by agents
- Adding new context
- Related context (logic/, math/)

**Note**: Currently only has 2 subdirectories (processes/, templates/), so this README
should be lightweight and focus on what's planned vs. what exists.

#### 6. .opencode/context/logic/README.md

**Template**: C (Context Domain)  
**Estimated Length**: 100-120 lines

**Key Sections**:
- Overview of logic context
- Organization (domain/, metalogic/, proof-theory/, semantics/, type-theory/)
- Quick reference table
- Usage by agents
- Adding new context
- Related context (lean4/, math/)

**Quick Reference Table**:
| Concept | File |
|---------|------|
| Proof theory basics | domain/proof-theory-concepts.md |
| Task semantics | domain/task-semantics.md |
| Soundness/completeness | domain/metalogic-concepts.md |
| ... | ... |

#### 7. .opencode/context/math/README.md

**Template**: C (Context Domain)  
**Estimated Length**: 90-110 lines

**Key Sections**:
- Overview of math context
- Organization (algebra/, lattice-theory/, order-theory/, topology/)
- Quick reference table
- Usage by agents
- Adding new context
- Related context (logic/, physics/)

### 5.3 Standard Template Structure

All READMEs should follow this consistent structure:

```markdown
# [Directory Name]

**Purpose**: [One-line description]  
**Last Updated**: [Date]

## Overview

[2-3 paragraphs]

## [Main Content Sections]

[Varies by template]

## Related Documentation

- [Parent directory README]
- [Related directories]
- [External resources]

## [Optional: Contributing/Maintenance]

[Guidelines for updates]
```

**Formatting Standards** (from documentation-standards.md):
- Maximum 100 characters per line
- ATX-style headings (`#`, `##`, `###`)
- Unicode box-drawing for directory trees
- Backticks around formal symbols
- Relative paths for internal links

### 5.4 Cross-Reference Strategy

**Bidirectional Links**:
- Parent README links to subdirectory READMEs
- Subdirectory READMEs link back to parent
- Related directories link to each other

**Example**:
- `.opencode/README.md` → Links to `agent/README.md`, `command/README.md`,
  `.opencode/context/README.md`, `specs/README.md`
- `.opencode/agent/README.md` → Links back to `.opencode/README.md`, links to
  `subagents/specialists/README.md`
- `.opencode/agent/subagents/specialists/README.md` → Links back to `agent/README.md`,
  links to individual specialist files

**Navigation Aids**:
- Table of contents for long READMEs (>100 lines)
- "See also" sections at bottom
- Quick reference tables for lookup

### 5.5 Maintenance Strategy

**Update Triggers**:
- Adding or removing subdirectories → Update parent README
- Adding or removing files → Update directory README if significant
- Renaming files → Update all READMEs that reference them
- Changing organization → Update affected READMEs

**Review Cycle**:
- Monthly review of all READMEs for accuracy
- Update "Last Updated" date when making changes
- Check for broken links
- Verify file references are current

**Quality Checklist** (from documentation-standards.md):
- [ ] Content is clear and technically precise
- [ ] No historical information or version mentions
- [ ] No emojis used
- [ ] Line length ≤ 100 characters
- [ ] ATX-style headings used
- [ ] Code blocks have language specification
- [ ] Unicode file trees used for directory structures
- [ ] Formal symbols wrapped in backticks
- [ ] Internal links use relative paths
- [ ] External links are accessible
- [ ] Cross-references are accurate
- [ ] No duplication of information
- [ ] Examples are concrete and verifiable

---

## Section 6: Gap Analysis and Recommendations

### 6.1 Current State Assessment

**Strengths**:
- Excellent top-level README (.opencode/README.md)
- Comprehensive context README (context/README.md)
- Good documentation standards in place
- Clear project structure

**Weaknesses**:
- Missing navigation READMEs in 8 critical subdirectories
- Specialist directory (31 files) has no organization guide
- Command directory lacks reference guide
- Specs directory workflow not documented

**Opportunities**:
- Add strategic READMEs to improve navigation
- Organize specialists by category for easier discovery
- Create command reference for quick lookup
- Document task workflow in specs/

**Threats**:
- Documentation bloat if READMEs are too detailed
- Maintenance burden if too many READMEs created
- Duplication if READMEs repeat information from other docs

### 6.2 Recommended Approach

**Philosophy**: "Minimal, Fresh, Strategic"

**Principles**:
1. **Add READMEs only where they provide clear navigation value**
2. **Keep READMEs focused on orientation and quick reference**
3. **Link to detailed documentation rather than duplicating it**
4. **Use consistent templates for maintainability**
5. **Update READMEs with code changes**

**Recommended READMEs (8 total)**:
1. `.opencode/agent/README.md` - HIGH PRIORITY
2. `.opencode/agent/subagents/specialists/README.md` - HIGH PRIORITY
3. `.opencode/command/README.md` - HIGH PRIORITY
4. `.opencode/specs/README.md` - HIGH PRIORITY
5. `.opencode/context/lean4/README.md` - MEDIUM PRIORITY
6. `.opencode/context/logic/README.md` - MEDIUM PRIORITY
7. `.opencode/context/math/README.md` - MEDIUM PRIORITY
8. `.opencode/agent/subagents/README.md` - LOW PRIORITY (optional)

**Not Recommended**:
- `.opencode/context/repo/README.md` - Only 4 files, parent README sufficient
- `.opencode/context/physics/README.md` - Only 1 subdirectory, parent README sufficient
- Individual project READMEs in specs/ - Create as needed per project

### 6.3 Implementation Complexity

**Estimated Effort**:
- **High Priority READMEs (4)**: 2 hours total
  - agent/README.md: 30 minutes
  - agent/subagents/specialists/README.md: 45 minutes (categorization required)
  - command/README.md: 30 minutes
  - specs/README.md: 45 minutes

- **Medium Priority READMEs (3)**: 1.5 hours total
  - context/lean4/README.md: 30 minutes
  - context/logic/README.md: 30 minutes
  - context/math/README.md: 30 minutes

- **Low Priority READMEs (1)**: 30 minutes
  - agent/subagents/README.md: 30 minutes

**Total Estimated Effort**: 4 hours

**Complexity**: LOW
- Templates are well-defined
- Content is straightforward (navigation and organization)
- No complex technical content required
- Existing READMEs provide good examples

**Risk**: LOW
- READMEs are documentation only, no code changes
- Easy to update or revise if needed
- Low maintenance burden with consistent templates

---

## Section 7: Specialist Categorization

### 7.1 Proposed Specialist Categories

**Category 1: Proof Development (5 specialists)**
- `tactic-specialist.md` - Implements tactic-based LEAN 4 proofs
- `term-mode-specialist.md` - Implements term-mode LEAN 4 proofs
- `metaprogramming-specialist.md` - Implements custom tactics and metaprogramming
- `proof-strategy-advisor.md` - Suggests high-level proof strategies
- `tactic-recommender.md` - Suggests relevant tactics based on proof goal

**Category 2: Code Quality (4 specialists)**
- `code-reviewer.md` - Automated code review for LEAN 4
- `style-checker.md` - Checks LEAN 4 code adherence to style guide
- `refactoring-assistant.md` - Safe refactoring operations for LEAN 4 code
- `syntax-validator.md` - Real-time syntax validation through LSP integration

**Category 3: Documentation (4 specialists)**
- `doc-analyzer.md` - Analyzes documentation gaps and bloat
- `doc-writer.md` - Writes and updates documentation
- `documentation-generator.md` - Auto-generates documentation for LEAN 4 code
- `concept-explainer.md` - Generates natural language explanations of LEAN 4 concepts

**Category 4: Research (3 specialists)**
- `lean-search-specialist.md` - Semantic search of LEAN libraries using LeanSearch
- `loogle-specialist.md` - Formal search of LEAN libraries using type signatures
- `web-research-specialist.md` - Web research for mathematical concepts and papers

**Category 5: Analysis (5 specialists)**
- `complexity-analyzer.md` - Analyzes task complexity and estimates effort
- `dependency-analyzer.md` - Analyzes module dependencies and suggests optimizations
- `dependency-mapper.md` - Maps dependencies and required imports
- `performance-profiler.md` - Profiles LEAN 4 proof compilation performance
- `verification-specialist.md` - Verifies LEAN 4 proofs against standards

**Category 6: Workflow (3 specialists)**
- `git-workflow-manager.md` - Git workflow automation and repository management
- `todo-manager.md` - Manages TODO.md updates based on review findings
- `batch-status-manager.md` - Manages TODO.md updates atomically, tracks batch state

**Category 7: Testing (2 specialists)**
- `test-generator.md` - Generates tests and counterexamples for LEAN 4 theorems
- `example-builder.md` - Generates illustrative examples for LEAN 4 theorems

**Category 8: Learning (2 specialists)**
- `learning-path-generator.md` - Generates personalized learning paths for LEAN 4
- `library-navigator.md` - Searches and navigates theorem libraries

**Category 9: Optimization (3 specialists)**
- `proof-optimizer.md` - Analyzes and optimizes existing LEAN 4 proofs
- `proof-simplifier.md` - Identifies opportunities to simplify LEAN 4 proofs
- `error-diagnostics.md` - Categorizes errors and suggests fixes for LEAN 4 diagnostics

**Category 10: Task Management (1 specialist)**
- `task-dependency-analyzer.md` - Analyzes task dependencies, builds DAG, detects cycles

### 7.2 Categorization Rationale

**Grouping Strategy**:
- **By Function**: What the specialist does (proof development, code quality, etc.)
- **By User Need**: When would a user need this specialist?
- **By Workflow Stage**: Where in the development workflow does this fit?

**Benefits**:
- Easier discovery ("I need to improve code quality" → Category 2)
- Logical organization for README
- Clear separation of concerns
- Helps users understand specialist ecosystem

---

## Section 8: Key Findings Summary

### 8.1 Directory Structure Findings

1. **Current State**: .opencode/ has 4 existing READMEs (top-level and context/), but
   missing 8 critical navigation READMEs in subdirectories
2. **Biggest Gap**: agent/subagents/specialists/ has 31 files with no organization guide
3. **Organization Pattern**: Hierarchical structure with clear separation (agent/,
   command/, context/, specs/)
4. **Existing Quality**: Top-level READMEs are excellent examples (comprehensive,
   well-structured, good navigation)

### 8.2 Documentation Standards Findings

1. **Core Principle**: "Fresh and minimal" beats "comprehensive but stale"
2. **README Purpose**: Navigation and orientation, not detailed documentation
3. **AI Optimization**: Hierarchical organization with consistent patterns aids LLM
   consumption
4. **Maintenance**: Update docs with code changes, delete dead documentation
5. **Anti-Patterns**: Avoid duplication, outdated info, over-documentation

### 8.3 Best Practices Findings

1. **Diátaxis Framework**: READMEs should be Reference type (information-oriented)
2. **Progressive Disclosure**: Start with essentials, link to detailed docs
3. **Consistent Templates**: Use standard structure for maintainability
4. **Cross-References**: Bidirectional links between parent and child READMEs
5. **Quality Checklist**: Follow documentation-standards.md requirements

### 8.4 Implementation Findings

1. **Recommended Approach**: Add 8 strategic READMEs using 4 standard templates
2. **Priority Order**: High (4), Medium (3), Low (1)
3. **Estimated Effort**: 4 hours total (LOW complexity)
4. **Risk Level**: LOW (documentation only, easy to update)
5. **Maintenance**: Monthly review cycle, update with code changes

---

## Section 9: Recommendations

### 9.1 Immediate Actions (Week 1)

**Create High Priority READMEs (4)**:
1. `.opencode/agent/README.md`
   - Use Template A (Agent/Command Directory)
   - Include agent hierarchy diagram
   - Link to subagents/ and specialists/
   - Estimated: 30 minutes

2. `.opencode/agent/subagents/specialists/README.md`
   - Use Template B (Specialist Catalog)
   - Organize 31 specialists into 10 categories
   - Include quick reference table
   - Estimated: 45 minutes

3. `.opencode/command/README.md`
   - Use Template A (Agent/Command Directory)
   - Include command reference table
   - Link to agent system
   - Estimated: 30 minutes

4. `.opencode/specs/README.md`
   - Use Template D (Specs Directory)
   - Explain task lifecycle and numbering
   - Document archive policy
   - Estimated: 45 minutes

**Update Existing READMEs**:
- `.opencode/README.md` - Add links to new subdirectory READMEs
- `.opencode/context/README.md` - Add links to new domain READMEs

### 9.2 Short-Term Actions (Week 2-3)

**Create Medium Priority READMEs (3)**:
5. `.opencode/context/lean4/README.md`
   - Use Template C (Context Domain)
   - Document current structure (processes/, templates/)
   - Note planned additions
   - Estimated: 30 minutes

6. `.opencode/context/logic/README.md`
   - Use Template C (Context Domain)
   - Organize 5 subdirectories
   - Include quick reference table
   - Estimated: 30 minutes

7. `.opencode/context/math/README.md`
   - Use Template C (Context Domain)
   - Organize 4 subdirectories
   - Include quick reference table
   - Estimated: 30 minutes

### 9.3 Optional Actions (As Needed)

**Create Low Priority READMEs (1)**:
8. `.opencode/agent/subagents/README.md`
   - Use Template A (Agent/Command Directory)
   - Only if 12 subagent files become difficult to navigate
   - Estimated: 30 minutes

**Project-Specific READMEs**:
- Create READMEs for individual projects in specs/ as needed
- Follow examples from 075_automation_migration/ and lean_command_enhancement/
- Include: overview, artifacts, quick summary, validation, context, next steps

### 9.4 Maintenance Recommendations

**Monthly Review**:
- Check all READMEs for accuracy
- Verify file references are current
- Update "Last Updated" dates
- Check for broken links

**Update Triggers**:
- Adding/removing subdirectories → Update parent README
- Adding/removing significant files → Update directory README
- Renaming files → Update all referencing READMEs
- Changing organization → Update affected READMEs

**Quality Assurance**:
- Use documentation-standards.md quality checklist
- Automated link checking (future enhancement)
- Peer review for new READMEs
- Consistency checks across similar READMEs

### 9.5 Future Enhancements

**Documentation Improvements**:
- Create comprehensive index of all .opencode/ documentation
- Build glossary of terms
- Develop learning paths for new users
- Add interactive examples

**Automation**:
- Automated link checking in CI/CD
- Consistency validation across READMEs
- Auto-generated file listings
- Documentation coverage metrics

**Advanced Features**:
- Searchable documentation
- Version-aware documentation
- Interactive navigation
- Documentation usage analytics

---

## Section 10: Blockers and Questions

### 10.1 Identified Blockers

**None identified**. Implementation is straightforward with well-defined templates and
clear requirements.

### 10.2 Open Questions

1. **Specialist Categorization**: Is the proposed 10-category organization optimal, or
   should we use fewer/different categories?
   - **Recommendation**: Start with 10 categories, consolidate if needed based on usage

2. **README Length**: Should we enforce strict length limits (e.g., 100 lines max)?
   - **Recommendation**: Use target ranges (60-150 lines) but allow flexibility for
     complex directories

3. **Update Frequency**: How often should READMEs be reviewed for accuracy?
   - **Recommendation**: Monthly review cycle, plus updates triggered by code changes

4. **Automation**: Should we automate any README generation or validation?
   - **Recommendation**: Start manual, add automation later (link checking, consistency
     validation)

5. **Project-Specific READMEs**: Should all projects in specs/ have READMEs?
   - **Recommendation**: Create as needed for complex projects, not required for simple
     tasks

---

## Section 11: Success Metrics

### 11.1 Implementation Success

**Completion Criteria**:
- [ ] 8 recommended READMEs created
- [ ] All READMEs follow standard templates
- [ ] Cross-references are bidirectional and accurate
- [ ] Existing READMEs updated with links to new READMEs
- [ ] All READMEs pass documentation-standards.md quality checklist

**Quality Metrics**:
- Line length ≤ 100 characters: 100% compliance
- ATX-style headings: 100% compliance
- Relative links for internal references: 100% compliance
- No broken links: 100% compliance
- Consistent structure across similar READMEs: 100% compliance

### 11.2 Usage Success

**User Experience Metrics**:
- Time to find specific specialist: <30 seconds (with specialists/README.md)
- Time to understand command system: <5 minutes (with command/README.md)
- Time to navigate context domains: <2 minutes (with domain READMEs)
- Time to understand task workflow: <5 minutes (with specs/README.md)

**AI Agent Metrics**:
- Context loading efficiency: Improved (hierarchical navigation)
- Relevant file discovery: Faster (quick reference tables)
- Cross-domain understanding: Better (explicit cross-references)

### 11.3 Maintenance Success

**Sustainability Metrics**:
- README update frequency: Monthly minimum
- Broken link rate: <1%
- Outdated information rate: <5%
- Documentation debt: Tracked and addressed quarterly

---

## Conclusion

This research provides a comprehensive, practical implementation plan for adding README.md
files to the .opencode/ directory structure. The recommended approach is **minimal,
strategic, and maintainable**, focusing on 8 critical READMEs that provide clear
navigation value without creating documentation bloat.

**Key Recommendations**:
1. Create 8 strategic READMEs using 4 standard templates
2. Prioritize high-value directories (agent/, command/, specs/, specialists/)
3. Follow "fresh and minimal" philosophy from Google and Write the Docs
4. Use consistent structure and cross-references for AI optimization
5. Implement monthly review cycle for maintenance

**Implementation Complexity**: LOW (4 hours total effort)  
**Risk Level**: LOW (documentation only, easy to update)  
**Expected Impact**: HIGH (significantly improved navigation and discoverability)

The proposed README hierarchy will transform the .opencode/ directory from a collection
of files into a well-organized, easily navigable knowledge base optimized for both human
developers and AI agents.

---

## Appendix A: Template Specifications

### Template A: Agent/Command Directory README

```markdown
# [Directory Name]

**Purpose**: [One-line description]  
**Last Updated**: [Date]

## Overview

[2-3 paragraphs explaining what this directory contains and its role in the system]

## Directory Structure

- `file1.md` - [Brief description]
- `file2.md` - [Brief description]
- `subdirectory/` - [Brief description with link to subdirectory README]

## Quick Reference

[Table or list of most commonly accessed files/features]

## Usage

[How agents/users interact with these files]

## Related Documentation

- [Link to parent README]
- [Link to related directories]
- [Link to architecture docs]

## Contributing

[Guidelines for adding new agents/commands]
```

**Target Length**: 60-100 lines  
**Use Cases**: agent/, command/

### Template B: Specialist Catalog README

```markdown
# Specialist Subagents

**Purpose**: Specialized agents for specific technical tasks  
**Last Updated**: [Date]

## Overview

[2-3 paragraphs explaining specialist role in the system]

## Available Specialists

### [Category 1]
- **[specialist-name.md]** - [One-line description]
- **[specialist-name.md]** - [One-line description]

### [Category 2]
- **[specialist-name.md]** - [One-line description]
- **[specialist-name.md]** - [One-line description]

[Repeat for all categories]

## Specialist Categories

[Explanation of how specialists are organized]

## Using Specialists

[How to invoke specialists, routing patterns]

## Adding New Specialists

[Link to specialist template and creation guide]

## Related Documentation

- [Link to subagent overview]
- [Link to orchestrator]
- [Link to builder templates]
```

**Target Length**: 100-150 lines  
**Use Cases**: agent/subagents/specialists/

### Template C: Context Domain README

```markdown
# [Domain Name] Context

**Purpose**: [Domain] knowledge for AI agents  
**Last Updated**: [Date]

## Overview

[2-3 paragraphs explaining this domain's role in the system]

## Organization

This directory is organized into:

### [Subdirectory 1]/
[Description of subdirectory purpose and contents]

Files:
- `file1.md` - [Description]
- `file2.md` - [Description]

### [Subdirectory 2]/
[Description of subdirectory purpose and contents]

Files:
- `file1.md` - [Description]
- `file2.md` - [Description]

## Quick Reference

[Table mapping concepts to files]

## Usage by Agents

[How agents use this context, context allocation patterns]

## Adding New Context

[Guidelines for adding new context files to this domain]

## Related Context

- [Link to related domain context]
- [Link to parent context README]
- [Link to external resources]
```

**Target Length**: 80-120 lines  
**Use Cases**: context/lean4/, context/logic/, context/math/

### Template D: Specs Directory README

```markdown
# Specifications - Task Work Products

**Purpose**: Task specifications, plans, reports, and work products  
**Last Updated**: [Date]

## Overview

[2-3 paragraphs explaining specs directory organization and purpose]

## Directory Structure

Each task gets a directory named `NNN_task_name/` containing:
- `state.json` - Task state tracking
- `plans/` - Implementation plans (versioned)
- `reports/` - Research and analysis reports
- `summaries/` - Brief summaries
- `README.md` - Project-specific overview (optional)

## Special Directories

### TODO.md
[Description of master task list]

### state.json
[Description of global state file]

### archive/
[Description of archived tasks]

### maintenance/
[Description of maintenance reports]

## Task Lifecycle

[Explanation of task states and workflow]

## Project Numbering

[Explanation of NNN numbering scheme]

## Archive Policy

[When and how tasks are archived]

## Related Documentation

- [Link to project-structure.md]
- [Link to state-schema.md]
- [Link to task command]
```

**Target Length**: 100-150 lines  
**Use Cases**: specs/

---

## Appendix B: Specialist Categorization Reference

### Complete Specialist List by Category

**1. Proof Development (5)**
- tactic-specialist.md
- term-mode-specialist.md
- metaprogramming-specialist.md
- proof-strategy-advisor.md
- tactic-recommender.md

**2. Code Quality (4)**
- code-reviewer.md
- style-checker.md
- refactoring-assistant.md
- syntax-validator.md

**3. Documentation (4)**
- doc-analyzer.md
- doc-writer.md
- documentation-generator.md
- concept-explainer.md

**4. Research (3)**
- lean-search-specialist.md
- loogle-specialist.md
- web-research-specialist.md

**5. Analysis (5)**
- complexity-analyzer.md
- dependency-analyzer.md
- dependency-mapper.md
- performance-profiler.md
- verification-specialist.md

**6. Workflow (3)**
- git-workflow-manager.md
- todo-manager.md
- batch-status-manager.md

**7. Testing (2)**
- test-generator.md
- example-builder.md

**8. Learning (2)**
- learning-path-generator.md
- library-navigator.md

**9. Optimization (3)**
- proof-optimizer.md
- proof-simplifier.md
- error-diagnostics.md

**10. Task Management (1)**
- task-dependency-analyzer.md

**Total**: 31 specialists

---

**End of Research Report**

*This comprehensive research report provides all necessary information to implement a
systematic README documentation strategy for the .opencode/ directory structure, optimized
for both human developers and AI agent consumption.*
