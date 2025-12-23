# Implementation Plan: .opencode/ README Documentation

**Project**: #066_opencode_readme_documentation  
**Version**: 1.0.0  
**Date**: December 20, 2025  
**Complexity**: LOW  
**Estimated Effort**: 4 hours total

## Executive Summary

This implementation plan provides a detailed, step-by-step approach to adding README.md
files to 8 strategic subdirectories within the .opencode/ system. The plan follows the
"fresh and minimal" documentation philosophy, using 4 standard templates to create
consistent, maintainable navigation aids optimized for both human developers and AI
agent consumption.

**Key Objectives**:
1. Add 8 README.md files to critical subdirectories lacking navigation
2. Organize 31 specialist subagents into 10 logical categories
3. Establish 4 standard templates for consistency and maintainability
4. Create bidirectional cross-references for hierarchical navigation
5. Maintain documentation quality standards from documentation-standards.md

**Implementation Approach**: Phased rollout in 3 priority levels (High, Medium, Low)
with immediate focus on high-value directories (agent/, command/, specs/, specialists/).

## Task Description

Based on research report `.opencode/specs/066_opencode_readme_documentation/reports/
research-001.md`, implement a systematic README documentation strategy for the
.opencode/ directory structure. Current state shows 4 existing READMEs but 8 critical
gaps, most notably the specialists/ directory with 31 files lacking organization.

**Scope**:
- Create 8 new README.md files following standard templates
- Update 2 existing READMEs with cross-references
- Define and document 4 standard templates
- Organize specialists into 10 categories
- Ensure compliance with documentation-standards.md

**Out of Scope**:
- Project-specific READMEs in specs/ subdirectories (create as needed)
- READMEs for directories with <3 files (repo/, physics/)
- Automated validation tooling (future enhancement)

## Complexity Assessment

**Level**: LOW  
**Estimated Effort**: 4 hours  
**Required Knowledge**: 
- .opencode/ directory structure and organization
- Documentation standards from documentation-standards.md
- Existing README patterns from .opencode/README.md and context/README.md
- Agent system architecture and specialist categorization

**Potential Challenges**:
1. **Specialist Categorization**: Organizing 31 specialists into logical categories
   - Mitigation: Use research-provided 10-category structure
2. **Cross-Reference Consistency**: Ensuring bidirectional links are accurate
   - Mitigation: Systematic verification checklist
3. **Template Adherence**: Maintaining consistency across 8 READMEs
   - Mitigation: Use templates as strict guides, validate against standards
4. **Documentation Bloat**: Avoiding over-documentation
   - Mitigation: Follow 60-150 line target ranges, link to detailed docs

## Dependencies

### Required Context Files
- `.opencode/specs/066_opencode_readme_documentation/reports/research-001.md`
- `.opencode/context/repo/documentation-standards.md`
- `.opencode/README.md` (existing top-level README)
- `.opencode/context/README.md` (existing context README)

### Required Directory Analysis
- `.opencode/agent/` - 1 file (orchestrator.md)
- `.opencode/agent/subagents/` - 12 files (subagent definitions)
- `.opencode/agent/subagents/specialists/` - 31 files (specialist definitions)
- `.opencode/command/` - 12 files (command definitions)
- `.opencode/specs/` - TODO.md, state.json, project directories
- `.opencode/context/lean4/` - 2 subdirectories (processes/, templates/)
- `.opencode/context/logic/` - 5 subdirectories (domain/, metalogic/, etc.)
- `.opencode/context/math/` - 4 subdirectories (algebra/, topology/, etc.)

### Prerequisites
None - This is a documentation-only task with no code dependencies.

### Library Functions
Not applicable - No LEAN 4 code involved.

## Standard Templates

### Template A: Agent/Command Directory README

**Use Cases**: `.opencode/agent/README.md`, `.opencode/command/README.md`  
**Target Length**: 60-100 lines  
**Purpose**: Provide overview and quick reference for agent/command directories

**Structure**:
```markdown
# [Directory Name]

**Purpose**: [One-line description]  
**Last Updated**: [Date]

## Overview

[2-3 paragraphs explaining what this directory contains and its role in the
system. Include architecture context and how it fits into the larger .opencode/
system.]

## Directory Structure

- `file1.md` - [Brief description of purpose and functionality]
- `file2.md` - [Brief description of purpose and functionality]
- `subdirectory/` - [Brief description with link to subdirectory README]

## Quick Reference

[Table or list of most commonly accessed files/features with one-line
descriptions. For agents: routing patterns. For commands: usage syntax.]

| Item | Purpose | Details |
|------|---------|---------|
| ... | ... | ... |

## Usage

[How agents/users interact with these files. Include invocation patterns,
routing logic, or command syntax as appropriate.]

## Related Documentation

- [Link to parent README]
- [Link to related directories]
- [Link to architecture docs]

## Contributing

[Guidelines for adding new agents/commands. Link to builder templates if
applicable.]
```

**Required Sections**: Title, Purpose, Overview, Directory Structure, Quick
Reference, Usage, Related Documentation  
**Optional Sections**: Contributing, Examples, Common Patterns

**Customization Guidelines**:
- Adapt Quick Reference format to content (table vs. list)
- Include routing patterns for agents, syntax for commands
- Link to builder-templates for meta-system guidance
- Keep Overview focused on current state, not history

### Template B: Specialist Catalog README

**Use Cases**: `.opencode/agent/subagents/specialists/README.md`  
**Target Length**: 100-150 lines  
**Purpose**: Organize and categorize specialist subagents for easy discovery

**Structure**:
```markdown
# Specialist Subagents

**Purpose**: Specialized agents for specific technical tasks  
**Last Updated**: [Date]

## Overview

[2-3 paragraphs explaining specialist role in the system. Cover: what
specialists are, how they differ from primary agents, when they're invoked,
and their role in context protection.]

## Available Specialists

### [Category 1 Name]
- **[specialist-name.md]** - [One-line description of purpose and use case]
- **[specialist-name.md]** - [One-line description of purpose and use case]

### [Category 2 Name]
- **[specialist-name.md]** - [One-line description of purpose and use case]
- **[specialist-name.md]** - [One-line description of purpose and use case]

[Repeat for all 10 categories]

## Specialist Categories

[Explanation of how specialists are organized into categories. Describe the
categorization strategy (by function, workflow stage, user need) and benefits
of this organization.]

**Category Descriptions**:
1. **[Category 1]**: [Purpose and scope]
2. **[Category 2]**: [Purpose and scope]
[... all 10 categories]

## Using Specialists

[How specialists are invoked. Cover: routing from primary agents, context
allocation patterns, artifact creation, and return value patterns (references
+ summaries).]

## Adding New Specialists

[Link to specialist template and creation guide. Include guidelines for
determining when a new specialist is needed vs. extending existing specialist.]

See: [Subagent Template](../../../context/builder-templates/subagent-template.md)

## Related Documentation

- [Parent Agent README](../README.md)
- [Orchestrator](../../orchestrator.md)
- [Builder Templates](../../../context/builder-templates/README.md)
```

**Required Sections**: Title, Purpose, Overview, Available Specialists,
Specialist Categories, Using Specialists, Adding New Specialists, Related
Documentation

**Customization Guidelines**:
- Use 10 categories from research report (Proof Development, Code Quality,
  Documentation, Research, Analysis, Workflow, Testing, Learning, Optimization,
  Task Management)
- Keep specialist descriptions to one line each
- Explain categorization rationale clearly
- Link to builder templates for meta-system

### Template C: Context Domain README

**Use Cases**: `.opencode/context/lean4/README.md`, `.opencode/context/logic/
README.md`, `.opencode/context/math/README.md`  
**Target Length**: 80-120 lines  
**Purpose**: Navigate domain-specific context files and subdirectories

**Structure**:
```markdown
# [Domain Name] Context

**Purpose**: [Domain] knowledge for AI agents  
**Last Updated**: [Date]

## Overview

[2-3 paragraphs explaining this domain's role in the system. Cover: what
knowledge is provided, which agents use it, how it fits into the larger
context organization, and context allocation patterns.]

## Organization

This directory is organized into:

### [Subdirectory 1]/
[Description of subdirectory purpose and contents. Explain what knowledge
area it covers and when agents would use it.]

**Files**:
- `file1.md` - [Description of specific knowledge provided]
- `file2.md` - [Description of specific knowledge provided]

### [Subdirectory 2]/
[Description of subdirectory purpose and contents.]

**Files**:
- `file1.md` - [Description of specific knowledge provided]
- `file2.md` - [Description of specific knowledge provided]

[Repeat for all subdirectories]

## Quick Reference

[Table mapping concepts/topics to specific files for fast lookup]

| Concept/Topic | File | Subdirectory |
|---------------|------|--------------|
| ... | ... | ... |

## Usage by Agents

[How agents use this context. Cover: which agents access this domain, typical
context allocation levels (1-3), and common usage patterns.]

**Context Allocation**:
- **Level 1**: [Typical single-file usage]
- **Level 2**: [Multi-file usage scenarios]
- **Level 3**: [Comprehensive domain usage]

## Adding New Context

[Guidelines for adding new context files to this domain. Include: when to add,
where to add, file size guidelines (50-200 lines), and structure requirements.]

## Related Context

- [Link to related domain context directories]
- [Link to parent context README]
- [Link to external resources if applicable]
```

**Required Sections**: Title, Purpose, Overview, Organization, Quick Reference,
Usage by Agents, Adding New Context, Related Context

**Customization Guidelines**:
- Adapt to current directory structure (some domains have more subdirectories)
- Include planned additions if directory is sparse
- Provide concrete concept-to-file mappings in Quick Reference
- Explain context allocation patterns specific to this domain

### Template D: Specs Directory README

**Use Cases**: `.opencode/specs/README.md`  
**Target Length**: 100-150 lines  
**Purpose**: Document task workflow, project organization, and artifact structure

**Structure**:
```markdown
# Specifications - Task Work Products

**Purpose**: Task specifications, plans, reports, and work products  
**Last Updated**: [Date]

## Overview

[2-3 paragraphs explaining specs directory organization and purpose. Cover:
what artifacts are stored here, how projects are organized, the relationship
to TODO.md, and the role in the task workflow.]

## Directory Structure

Each task gets a directory named `NNN_task_name/` containing:

```
NNN_task_name/
├── reports/
│   ├── research-001.md
│   ├── analysis-001.md
│   └── verification-001.md
├── plans/
│   ├── implementation-001.md
│   └── implementation-002.md
├── summaries/
│   ├── project-summary.md
│   └── research-summary.md
└── state.json
```

**Subdirectories**:
- `reports/` - Research and analysis reports
- `plans/` - Implementation plans (versioned)
- `summaries/` - Brief summaries for quick reference
- `state.json` - Project-specific state tracking

## Special Files and Directories

### TODO.md
[Description of master task list, format, priority levels, and linking to
projects]

### state.json
[Description of global state file, schema reference, and synchronization]

### archive/
[Description of archived tasks, when tasks are archived, and archive structure]

### maintenance/
[Description of maintenance reports and operations tracking]

## Task Lifecycle

[Explanation of task states and workflow from creation through completion]

**States**:
1. **Planned**: Task identified, added to TODO.md
2. **Researched**: Research report created
3. **Planned**: Implementation plan created
4. **In Progress**: Implementation underway
5. **Completed**: Implementation finished, verified
6. **Archived**: Task archived after completion

## Project Numbering

[Explanation of NNN numbering scheme, rules, and conventions]

**Format**: `NNN_descriptive_task_name`
- NNN: Zero-padded 3-digit sequential number
- Start at 001, increment sequentially
- Never reuse numbers
- Use descriptive, lowercase names with underscores

## Artifact Naming Conventions

[Conventions for naming reports, plans, and summaries within projects]

**Reports**: `{type}-NNN.md` (research-001.md, analysis-001.md, etc.)  
**Plans**: `implementation-NNN.md` (version number)  
**Summaries**: `{type}-summary.md` (project-summary.md, etc.)

## Archive Policy

[When and how tasks are archived]

**Archive Criteria**:
- Task completed and verified
- No active dependencies
- Documentation updated
- Artifacts preserved

## Related Documentation

- [Artifact Management Guide](../context/core/system/artifact-management.md)
- [State Schema Reference](../context/repo/state-schema.md)
- [Documentation Standards](../context/repo/documentation-standards.md)
```

**Required Sections**: Title, Purpose, Overview, Directory Structure, Special
Files and Directories, Task Lifecycle, Project Numbering, Artifact Naming
Conventions, Archive Policy, Related Documentation

**Customization Guidelines**:
- Include concrete examples of project directories
- Explain state management clearly
- Link to detailed schema documentation
- Provide task lifecycle diagram if helpful

## Implementation Steps

### Phase 1: High Priority READMEs (2 hours)

#### Step 1: Create .opencode/agent/README.md

**Action**: Create agent system overview README  
**File**: `.opencode/agent/README.md`  
**Template**: A (Agent/Command Directory)  
**Estimated Time**: 30 minutes

**Tasks**:
1. Read orchestrator.md to understand agent architecture
2. List all files in agent/ directory
3. Apply Template A structure
4. Create Quick Reference table with agent hierarchy
5. Explain routing from orchestrator to subagents
6. Link to subagents/ directory (note: README to be created)
7. Link to ARCHITECTURE.md and parent README
8. Include contributing guidelines with link to builder-templates

**Key Content**:
- Overview: Agent system architecture (orchestrator → subagents → specialists)
- Directory Structure: orchestrator.md, subagents/
- Quick Reference: Table of primary agents with routing patterns
- Usage: How orchestrator routes to agents
- Related Documentation: Links to ARCHITECTURE.md, subagents/, builder-templates

**Verification**:
- [ ] Line length ≤ 100 characters
- [ ] ATX-style headings
- [ ] Relative links for internal references
- [ ] No emojis
- [ ] Length: 60-100 lines
- [ ] Follows Template A structure

#### Step 2: Create .opencode/agent/subagents/specialists/README.md

**Action**: Create specialist catalog with 10 categories  
**File**: `.opencode/agent/subagents/specialists/README.md`  
**Template**: B (Specialist Catalog)  
**Estimated Time**: 45 minutes

**Tasks**:
1. List all 31 specialist files in directory
2. Apply Template B structure
3. Organize specialists into 10 categories (from research report):
   - Proof Development (5)
   - Code Quality (4)
   - Documentation (4)
   - Research (3)
   - Analysis (5)
   - Workflow (3)
   - Testing (2)
   - Learning (2)
   - Optimization (3)
   - Task Management (1)
4. Write one-line description for each specialist
5. Explain categorization strategy
6. Document specialist invocation patterns
7. Link to builder-templates for creating new specialists

**Key Content**:
- Overview: Specialist role in context protection and delegation
- Available Specialists: All 31 specialists organized by category
- Specialist Categories: Explanation of 10 categories
- Using Specialists: Routing patterns, context allocation, artifact creation
- Adding New Specialists: Link to subagent-template.md

**Specialist Categorization** (from research report):

**1. Proof Development (5)**:
- tactic-specialist.md - Implements tactic-based LEAN 4 proofs
- term-mode-specialist.md - Implements term-mode LEAN 4 proofs
- metaprogramming-specialist.md - Implements custom tactics and metaprogramming
- proof-strategy-advisor.md - Suggests high-level proof strategies
- tactic-recommender.md - Suggests relevant tactics based on proof goal

**2. Code Quality (4)**:
- code-reviewer.md - Automated code review for LEAN 4
- style-checker.md - Checks LEAN 4 code adherence to style guide
- refactoring-assistant.md - Safe refactoring operations for LEAN 4 code
- syntax-validator.md - Real-time syntax validation through LSP integration

**3. Documentation (4)**:
- doc-analyzer.md - Analyzes documentation gaps and bloat
- doc-writer.md - Writes and updates documentation
- documentation-generator.md - Auto-generates documentation for LEAN 4 code
- concept-explainer.md - Generates natural language explanations

**4. Research (3)**:
- lean-search-specialist.md - Semantic search of LEAN libraries using LeanSearch
- loogle-specialist.md - Formal search using type signatures via Loogle API
- web-research-specialist.md - Web research for mathematical concepts and papers

**5. Analysis (5)**:
- complexity-analyzer.md - Analyzes task complexity and estimates effort
- dependency-analyzer.md - Analyzes module dependencies and suggests optimizations
- dependency-mapper.md - Maps dependencies and required imports
- performance-profiler.md - Profiles LEAN 4 proof compilation performance
- verification-specialist.md - Verifies LEAN 4 proofs against standards

**6. Workflow (3)**:
- git-workflow-manager.md - Git workflow automation and repository management
- todo-manager.md - Manages TODO.md updates based on review findings
- batch-status-manager.md - Manages TODO.md updates atomically

**7. Testing (2)**:
- test-generator.md - Generates tests and counterexamples for LEAN 4 theorems
- example-builder.md - Generates illustrative examples for LEAN 4 theorems

**8. Learning (2)**:
- learning-path-generator.md - Generates personalized learning paths for LEAN 4
- library-navigator.md - Searches and navigates theorem libraries

**9. Optimization (3)**:
- proof-optimizer.md - Analyzes and optimizes existing LEAN 4 proofs
- proof-simplifier.md - Identifies opportunities to simplify LEAN 4 proofs
- error-diagnostics.md - Categorizes errors and suggests fixes

**10. Task Management (1)**:
- task-dependency-analyzer.md - Analyzes task dependencies, builds DAG, detects
  cycles

**Verification**:
- [ ] All 31 specialists listed
- [ ] Organized into 10 categories
- [ ] One-line description for each
- [ ] Line length ≤ 100 characters
- [ ] ATX-style headings
- [ ] Length: 100-150 lines
- [ ] Follows Template B structure

#### Step 3: Create .opencode/command/README.md

**Action**: Create command reference guide  
**File**: `.opencode/command/README.md`  
**Template**: A (Agent/Command Directory)  
**Estimated Time**: 30 minutes

**Tasks**:
1. List all 12 command files in directory
2. Apply Template A structure
3. Create Quick Reference table with command syntax and purpose
4. Explain command invocation and routing to agents
5. Link to agent system and workflows
6. Include contributing guidelines for adding new commands

**Key Content**:
- Overview: Custom command system and routing
- Directory Structure: All 12 command files
- Quick Reference: Table mapping commands to agents and purposes
- Usage: Command invocation syntax and patterns
- Related Documentation: Links to agent/, QUICK-START.md, builder-templates

**Command Reference Table**:
| Command | Purpose | Agent | Syntax |
|---------|---------|-------|--------|
| /review | Repository analysis | reviewer | `/review` |
| /research | Multi-source research | researcher | `/research "{topic}"` |
| /plan | Implementation planning | planner | `/plan "{task}"` |
| /revise | Plan revision | planner | `/revise {project_number}` |
| /lean | Proof implementation | proof-developer | `/lean {project_number}` |
| /refactor | Code refactoring | refactorer | `/refactor {file_path}` |
| /document | Documentation updates | documenter | `/document "{scope}"` |
| /meta | Agent/command creation | meta | `/meta "{request}"` |
| /add | Add TODO tasks | task-adder | `/add "{task}"` |
| /todo | TODO management | task-adder | `/todo` |
| /task | Execute TODO task | task-executor | `/task {task_number}` |
| /implement | General implementation | implementer | `/implement "{description}"` |

**Verification**:
- [ ] All 12 commands listed
- [ ] Command syntax included
- [ ] Agent routing documented
- [ ] Line length ≤ 100 characters
- [ ] Length: 60-100 lines
- [ ] Follows Template A structure

#### Step 4: Create .opencode/specs/README.md

**Action**: Create specs directory and task workflow documentation  
**File**: `.opencode/specs/README.md`  
**Template**: D (Specs Directory)  
**Estimated Time**: 45 minutes

**Tasks**:
1. Analyze specs/ directory structure
2. Apply Template D structure
3. Document project numbering scheme (NNN_task_name)
4. Explain artifact organization (reports/, plans/, summaries/)
5. Document task lifecycle and states
6. Explain TODO.md format and linking
7. Document archive policy
8. Link to project-structure.md and state-schema.md

**Key Content**:
- Overview: Task work products and project organization
- Directory Structure: NNN_task_name/ pattern with subdirectories
- Special Files: TODO.md, state.json, archive/, maintenance/
- Task Lifecycle: States from planned through archived
- Project Numbering: NNN format and rules
- Artifact Naming: Conventions for reports, plans, summaries
- Archive Policy: When and how tasks are archived

**Verification**:
- [ ] Project structure clearly documented
- [ ] Task lifecycle explained
- [ ] Numbering scheme detailed
- [ ] Line length ≤ 100 characters
- [ ] Length: 100-150 lines
- [ ] Follows Template D structure

### Phase 2: Medium Priority READMEs (1.5 hours)

#### Step 5: Create .opencode/context/lean4/README.md

**Action**: Create LEAN 4 context navigation README  
**File**: `.opencode/context/lean4/README.md`  
**Template**: C (Context Domain)  
**Estimated Time**: 30 minutes

**Tasks**:
1. Analyze lean4/ directory structure (processes/, templates/)
2. Apply Template C structure
3. Document current subdirectories and files
4. Create Quick Reference mapping concepts to files
5. Explain usage by agents (which agents, context levels)
6. Document guidelines for adding new context
7. Link to related context (logic/, math/) and parent README

**Key Content**:
- Overview: LEAN 4 knowledge for AI agents
- Organization: processes/ (maintenance-workflow.md), templates/
  (maintenance-report-template.md)
- Quick Reference: Concept-to-file mapping
- Usage by Agents: proof-developer, refactorer, implementer use patterns
- Adding New Context: File size guidelines, structure requirements
- Related Context: Links to logic/, math/, parent README

**Note**: This directory is currently sparse (2 subdirectories). Focus on what
exists and note planned additions from context/README.md.

**Verification**:
- [ ] Current structure documented
- [ ] Concept mapping provided
- [ ] Agent usage patterns explained
- [ ] Line length ≤ 100 characters
- [ ] Length: 80-120 lines
- [ ] Follows Template C structure

#### Step 6: Create .opencode/context/logic/README.md

**Action**: Create logic context navigation README  
**File**: `.opencode/context/logic/README.md`  
**Template**: C (Context Domain)  
**Estimated Time**: 30 minutes

**Tasks**:
1. Analyze logic/ directory structure (5 subdirectories)
2. Apply Template C structure
3. Document all subdirectories: domain/, metalogic/, proof-theory/, semantics/,
   type-theory/
4. List all files in each subdirectory
5. Create Quick Reference mapping logic concepts to files
6. Explain usage by agents (proof-developer, researcher patterns)
7. Link to related context (lean4/, math/)

**Key Content**:
- Overview: Logic theory knowledge for bimodal logic development
- Organization: 5 subdirectories with detailed file listings
- Quick Reference: Concept-to-file mapping (Kripke semantics, proof theory,
  soundness/completeness, etc.)
- Usage by Agents: proof-developer, researcher, planner use patterns
- Adding New Context: Guidelines for logic-specific context
- Related Context: Links to lean4/, math/, parent README

**Quick Reference Table**:
| Concept | File | Subdirectory |
|---------|------|--------------|
| Proof theory basics | proof-theory-concepts.md | domain/ |
| Task semantics | task-semantics.md | domain/ |
| Soundness/completeness | metalogic-concepts.md | domain/ |
| Dependent types | dependent-types.md | ../lean4/domain/ |
| Metalogic concepts | metalogic-concepts.md | domain/ |
| Kripke semantics | kripke-semantics-overview.md | domain/ |

**Verification**:
- [ ] All 5 subdirectories documented
- [ ] All files listed with descriptions
- [ ] Concept mapping comprehensive
- [ ] Line length ≤ 100 characters
- [ ] Length: 80-120 lines
- [ ] Follows Template C structure

#### Step 7: Create .opencode/context/math/README.md

**Action**: Create math context navigation README  
**File**: `.opencode/context/math/README.md`  
**Template**: C (Context Domain)  
**Estimated Time**: 30 minutes

**Tasks**:
1. Analyze math/ directory structure (4 subdirectories)
2. Apply Template C structure
3. Document all subdirectories: algebra/, lattice-theory/, order-theory/,
   topology/
4. List all files in each subdirectory
5. Create Quick Reference mapping math concepts to files
6. Explain usage by agents (proof-developer, researcher patterns)
7. Link to related context (logic/, physics/)

**Key Content**:
- Overview: Mathematical domain knowledge from mathlib4
- Organization: 4 subdirectories with file listings
- Quick Reference: Concept-to-file mapping (groups, rings, lattices, topology,
  etc.)
- Usage by Agents: proof-developer, researcher use patterns
- Adding New Context: Guidelines for math-specific context
- Related Context: Links to logic/, physics/, parent README

**Quick Reference Table**:
| Concept | File | Subdirectory |
|---------|------|--------------|
| Groups and monoids | groups-and-monoids.md | algebra/ |
| Rings and fields | rings-and-fields.md | algebra/ |
| Lattices | lattices.md | lattice-theory/ |
| Partial orders | partial-orders.md | order-theory/ |
| Topological spaces | topological-spaces.md | topology/ |

**Verification**:
- [ ] All 4 subdirectories documented
- [ ] All files listed with descriptions
- [ ] Concept mapping comprehensive
- [ ] Line length ≤ 100 characters
- [ ] Length: 80-120 lines
- [ ] Follows Template C structure

### Phase 3: Update Existing READMEs (30 minutes)

#### Step 8: Update .opencode/README.md

**Action**: Add cross-references to new subdirectory READMEs  
**File**: `.opencode/README.md`  
**Estimated Time**: 15 minutes

**Tasks**:
1. Read current .opencode/README.md
2. Locate "Project Structure" section
3. Add links to new READMEs in directory tree
4. Update "Documentation" section with new README references
5. Verify all links are relative and correct

**Changes**:
- In Project Structure section, add links:
  - `agent/` → `agent/README.md`
  - `command/` → `command/README.md`
  - `specs/` → `specs/README.md`
  - `subagents/specialists/` → `agent/subagents/specialists/README.md`
- In Documentation section, add:
  - `agent/README.md` - Agent system overview
  - `command/README.md` - Command reference
  - `specs/README.md` - Task workflow guide

**Verification**:
- [ ] Links added to Project Structure
- [ ] Links added to Documentation section
- [ ] All links use relative paths
- [ ] No broken links
- [ ] Line length maintained ≤ 100 characters

#### Step 9: Update .opencode/context/README.md

**Action**: Add cross-references to new domain READMEs  
**File**: `.opencode/context/README.md`  
**Estimated Time**: 15 minutes

**Tasks**:
1. Read current .opencode/context/README.md
2. Locate "Directory Structure" section
3. Add links to new domain READMEs
4. Update domain descriptions to reference READMEs
5. Verify all links are relative and correct

**Changes**:
- In Directory Structure section, add links:
  - `lean4/` → `lean4/README.md`
  - `logic/` → `logic/README.md`
  - `math/` → `math/README.md`
- In Context Categories section, update:
  - lean4/ description: "See [lean4/README.md](lean4/README.md) for details"
  - logic/ description: "See [logic/README.md](logic/README.md) for details"
  - math/ description: "See [math/README.md](math/README.md) for details"

**Verification**:
- [ ] Links added to Directory Structure
- [ ] Domain descriptions updated
- [ ] All links use relative paths
- [ ] No broken links
- [ ] Line length maintained ≤ 100 characters

### Phase 4: Validation and Documentation (30 minutes)

#### Step 10: Validate All READMEs

**Action**: Systematic validation against documentation-standards.md  
**Estimated Time**: 20 minutes

**Tasks**:
1. Run quality checklist on each README
2. Verify line length ≤ 100 characters
3. Check ATX-style headings
4. Verify formal symbols wrapped in backticks (if any)
5. Validate all internal links resolve
6. Check cross-references are bidirectional
7. Verify no emojis used
8. Confirm length targets met (60-150 lines)

**Quality Checklist** (per README):
- [ ] Content is clear and technically precise
- [ ] No historical information or version mentions
- [ ] No emojis used
- [ ] Line length ≤ 100 characters
- [ ] ATX-style headings used
- [ ] Code blocks have language specification (if any)
- [ ] Unicode file trees used for directory structures
- [ ] Formal symbols wrapped in backticks (if any)
- [ ] Internal links use relative paths
- [ ] External links are accessible (if any)
- [ ] Cross-references are accurate
- [ ] No duplication of information
- [ ] Examples are concrete and verifiable (if any)

**Files to Validate**:
1. `.opencode/agent/README.md`
2. `.opencode/agent/subagents/specialists/README.md`
3. `.opencode/command/README.md`
4. `.opencode/specs/README.md`
5. `.opencode/context/lean4/README.md`
6. `.opencode/context/logic/README.md`
7. `.opencode/context/math/README.md`
8. `.opencode/README.md` (updated)
9. `.opencode/context/README.md` (updated)

**Verification**:
- [ ] All 9 files pass quality checklist
- [ ] All internal links verified
- [ ] Cross-references bidirectional
- [ ] Length targets met

#### Step 11: Create Implementation Summary

**Action**: Document what was implemented  
**File**: `.opencode/specs/066_opencode_readme_documentation/summaries/
implementation-summary.md`  
**Estimated Time**: 10 minutes

**Tasks**:
1. List all 8 new READMEs created
2. List 2 existing READMEs updated
3. Document specialist categorization (10 categories, 31 specialists)
4. Note template definitions (4 templates)
5. Record validation results
6. Include metrics (total lines, files created, links added)

**Content**:
- Files Created: 8 new READMEs
- Files Updated: 2 existing READMEs
- Specialist Organization: 10 categories, 31 specialists
- Templates Defined: 4 standard templates
- Validation: All files pass quality checklist
- Metrics: Total lines, cross-references, coverage

**Verification**:
- [ ] All files listed
- [ ] Metrics accurate
- [ ] Summary concise (1-2 pages)

## File Structure

```
.opencode/
├── README.md                                    # UPDATED with links
├── agent/
│   ├── README.md                                # NEW (Template A)
│   └── subagents/
│       └── specialists/
│           └── README.md                        # NEW (Template B)
├── command/
│   └── README.md                                # NEW (Template A)
├── .opencode/context/
│   ├── README.md                                # UPDATED with links
│   ├── lean4/
│   │   └── README.md                            # NEW (Template C)
│   ├── logic/
│   │   └── README.md                            # NEW (Template C)
│   └── math/
│       └── README.md                            # NEW (Template C)
└── specs/
    ├── README.md                                # NEW (Template D)
    └── 066_opencode_readme_documentation/
        ├── plans/
        │   └── implementation-001.md            # THIS FILE
        ├── reports/
        │   └── research-001.md
        ├── summaries/
        │   ├── research-summary.md
        │   └── implementation-summary.md        # NEW
        └── state.json
```

## Verification Checkpoints

### Phase 1 Checkpoints
- [ ] Step 1: .opencode/agent/README.md created and validated
- [ ] Step 2: .opencode/agent/subagents/specialists/README.md created with 10
      categories
- [ ] Step 3: .opencode/command/README.md created and validated
- [ ] Step 4: .opencode/specs/README.md created and validated
- [ ] Phase 1 complete: 4 high-priority READMEs created (2 hours)

### Phase 2 Checkpoints
- [ ] Step 5: .opencode/context/lean4/README.md created and validated
- [ ] Step 6: .opencode/context/logic/README.md created and validated
- [ ] Step 7: .opencode/context/math/README.md created and validated
- [ ] Phase 2 complete: 3 medium-priority READMEs created (1.5 hours)

### Phase 3 Checkpoints
- [ ] Step 8: .opencode/README.md updated with cross-references
- [ ] Step 9: .opencode/context/README.md updated with cross-references
- [ ] Phase 3 complete: 2 existing READMEs updated (30 minutes)

### Phase 4 Checkpoints
- [ ] Step 10: All 9 files validated against quality checklist
- [ ] Step 11: Implementation summary created
- [ ] Phase 4 complete: Validation and documentation finished (30 minutes)

### Overall Checkpoints
- [ ] All 8 new READMEs created
- [ ] All 2 existing READMEs updated
- [ ] All 31 specialists categorized into 10 categories
- [ ] All 4 templates defined and documented
- [ ] All cross-references bidirectional and accurate
- [ ] All files pass documentation-standards.md quality checklist
- [ ] Total effort: ~4 hours

## Success Criteria

### Functional Success
1. **Navigation Improvement**: Users can quickly find relevant agents, commands,
   and context files
2. **Specialist Discovery**: 31 specialists organized into logical categories
   for easy discovery
3. **Workflow Understanding**: Task workflow and artifact organization clearly
   documented
4. **Consistency**: All READMEs follow standard templates and conventions

### Quality Success
1. **Standards Compliance**: All READMEs pass documentation-standards.md quality
   checklist
2. **Cross-Reference Accuracy**: All internal links resolve correctly
3. **Bidirectional Links**: Parent and child READMEs link to each other
4. **Length Targets**: All READMEs within target ranges (60-150 lines)
5. **No Bloat**: Documentation is "fresh and minimal" per Google's principle

### Usability Success
1. **Quick Lookup**: Users can find specific information in <30 seconds
2. **Clear Organization**: Directory structure is immediately understandable
3. **AI Optimization**: Hierarchical organization aids LLM consumption
4. **Maintainability**: Templates make updates straightforward

### Metrics
- **Files Created**: 8 new READMEs
- **Files Updated**: 2 existing READMEs
- **Specialists Organized**: 31 specialists in 10 categories
- **Templates Defined**: 4 standard templates
- **Cross-References**: ~20-30 bidirectional links
- **Total Lines**: ~800-1000 lines across all READMEs
- **Coverage**: 100% of critical subdirectories documented

## Related Research

- [Research Report](../reports/research-001.md) - Comprehensive research on
  README implementation
- [Research Summary](../summaries/research-summary.md) - Brief research findings
- [Web Research Findings](../findings/web-research-findings.md) - External best
  practices

## Notes

### Implementation Strategy
- **Phased Approach**: High → Medium → Low priority ensures critical gaps
  addressed first
- **Template-Driven**: Using 4 standard templates ensures consistency and
  maintainability
- **Validation-Focused**: Systematic quality checks prevent documentation debt
- **Cross-Reference Heavy**: Bidirectional links create robust navigation

### Specialist Categorization Rationale
The 10-category organization groups specialists by function and workflow stage:
- **Proof Development**: Core proof implementation specialists
- **Code Quality**: Style, review, refactoring specialists
- **Documentation**: Doc analysis, writing, generation specialists
- **Research**: Library search and web research specialists
- **Analysis**: Complexity, dependency, performance specialists
- **Workflow**: Git, TODO, batch management specialists
- **Testing**: Test and example generation specialists
- **Learning**: Learning paths and library navigation specialists
- **Optimization**: Proof optimization and simplification specialists
- **Task Management**: Dependency analysis specialist

This organization makes specialist discovery intuitive: "I need to improve code
quality" → Code Quality category.

### Maintenance Considerations
- **Monthly Review**: Check all READMEs for accuracy
- **Update Triggers**: Add/remove files → update directory README
- **Link Validation**: Verify links remain valid
- **Template Adherence**: New READMEs should follow templates

### Future Enhancements
- **Automated Link Checking**: CI/CD integration for link validation
- **Consistency Validation**: Automated template compliance checking
- **Documentation Coverage**: Metrics for README coverage
- **Interactive Navigation**: Potential for enhanced navigation tools

### Low Priority README
The plan includes `.opencode/agent/subagents/README.md` as low priority
(optional). This directory has 12 subagent files, which may not require a
separate README since the parent agent/README.md can provide sufficient
navigation. Create only if user requests or if navigation becomes difficult.

## Version History

**Version 1.0.0** (December 20, 2025):
- Initial implementation plan
- 8 READMEs to create, 2 to update
- 4 standard templates defined
- 31 specialists organized into 10 categories
- Phased approach: High (2h) → Medium (1.5h) → Update (30m) → Validate (30m)
- Total effort: 4 hours
