# Research Report: Add /meta Command from OpenAgents with System-Builder Subagents

**Task Number**: 256  
**Research Date**: 2025-12-29  
**Researcher**: researcher (automated)  
**Status**: [RESEARCHED]

---

## Executive Summary

This research analyzes the /meta command from OpenAgents and develops an integration strategy for ProofChecker that maintains the high standards established in tasks 244-247 (OpenAgents migration refactor). The analysis reveals that the /meta command is a sophisticated interactive system builder that creates complete .opencode architectures through guided interviews. Integration requires adapting the command to ProofChecker's frontmatter delegation pattern, renaming system-builder/ to meta/, and ensuring all subagents follow current XML optimization and context efficiency standards.

**Key Findings**:
1. OpenAgents /meta command is 862 lines with 8-stage workflow (DetectExistingProject → DeliverSystem)
2. Backup version is 921 lines with similar structure but includes ProofChecker-specific domain examples
3. Current system-builder agents (5 total) are well-structured with frontmatter but need updates for current standards
4. Integration requires frontmatter delegation pattern, lazy context loading, and git-workflow-manager integration
5. Context organization must avoid bloat through focused files and lazy loading

**Recommendations**:
1. Adopt frontmatter delegation pattern from tasks 244-247 (command 144 lines, agent owns workflow)
2. Rename .opencode/agent/subagents/system-builder/ to .opencode/agent/subagents/meta/
3. Update all 5 meta subagents to follow current XML optimization patterns
4. Create focused context files (<200 lines each) with lazy loading
5. Integrate with status-sync-manager and git-workflow-manager for state tracking

---

## 1. OpenAgents /meta Command Analysis

### 1.1 Structure and Features

**File**: `/home/benjamin/Projects/OpenAgents/.opencode/command/meta.md`  
**Size**: 862 lines  
**Format**: Frontmatter delegation with embedded workflow documentation

**Frontmatter**:
```yaml
---
description: "Interactive system builder that creates complete context-aware AI architectures tailored to user domains"
---
```

**Key Features**:
1. **8-Stage Interactive Workflow**:
   - Stage 0: DetectExistingProject (scan for existing .opencode, offer merge options)
   - Stage 1: InitiateInterview (explain process, set expectations)
   - Stage 2: GatherDomainInfo (domain, purpose, users)
   - Stage 2.5: DetectDomainType (classify as development/business/hybrid)
   - Stage 3: IdentifyUseCases (top 3-5 use cases, complexity, dependencies)
   - Stage 4: AssessComplexity (agent count, knowledge types, state management)
   - Stage 5: IdentifyIntegrations (external tools, file operations, custom commands)
   - Stage 6: ReviewAndConfirm (present architecture summary, get confirmation)
   - Stage 7: GenerateSystem (route to @builder with Level 2 context)
   - Stage 8: DeliverSystem (present completed system with documentation)

2. **Merge Strategy Support**:
   - Extend Existing System (recommended for adding capabilities)
   - Create Separate System (for multi-domain projects)
   - Replace Existing System (with backup)
   - Cancel

3. **Domain Type Detection**:
   - Development (code, testing, build, deploy)
   - Business (e-commerce, support, marketing, content)
   - Hybrid (data engineering, product management)
   - Identifies relevant existing agents for each domain type

4. **Routing Intelligence**:
   - Routes to @builder for system generation
   - Routes to @subagents/builder/domain-analyzer for complex domains
   - Uses @ symbol pattern for subagent references
   - Specifies context levels (Level 1/2/3) for each route

5. **Architecture Principles**:
   - Modular design (50-200 line files)
   - Hierarchical organization (orchestrator + subagents)
   - Context efficiency (80% Level 1, 20% Level 2, rare Level 3)
   - Workflow-driven design
   - Research-backed XML patterns

### 1.2 Workflow Execution Pattern

The /meta command uses a **progressive disclosure** interview pattern:
1. Start with broad questions (domain, purpose)
2. Drill into specifics based on responses
3. Adapt questions based on domain type
4. Validate understanding at each checkpoint
5. Present comprehensive summary for confirmation
6. Generate complete system after confirmation

**Context Allocation Strategy**:
- Level 1 (isolation): User provides clear requirements upfront
- Level 2 (filtered): Standard interview process (most common)
- Level 3 (full): Complex domain requiring extensive guidance

**Routing Pattern**:
```xml
<route to="@builder" when="user_confirms_architecture">
  <context_level>Level 2 - Filtered Context</context_level>
  <pass_data>
    - interview_responses (all captured data)
    - architecture_summary (generated plan)
    - component_specifications (detailed specs)
    - file_structure_plan (directory layout)
  </pass_data>
  <expected_return>
    - complete_file_structure (all generated files)
    - validation_report (quality checks)
    - documentation (usage guides)
  </expected_return>
</route>
```

### 1.3 Quality Standards

**Interview Patterns**:
- Progressive disclosure (broad → specific)
- Adaptive questioning (adjust to user's technical level)
- Example-driven (concrete examples for every question)
- Validation checkpoints (confirm understanding before proceeding)

**Architecture Principles**:
- Modular design (small, focused files)
- Hierarchical organization (manager-worker pattern)
- Context efficiency (prefer Level 1 context)
- Workflow-driven (design workflows first, then agents)
- Research-backed (Stanford/Anthropic XML patterns)

**Validation Gates**:
- Pre-flight: User understands process, has clarity on domain
- Mid-flight: Each phase captures complete information
- Post-flight: Generated system matches confirmed architecture

---

## 2. Backup Version Comparison

### 2.1 Differences from OpenAgents Version

**File**: `.opencode.backup.20251225_173342/command/meta.md`  
**Size**: 921 lines (59 lines longer than OpenAgents version)

**Key Differences**:

1. **Frontmatter Structure** (Lines 1-15):
   - Backup includes additional metadata:
     ```yaml
     ---
     name: meta
     agent: orchestrator
     description: "..."
     context_level: 2
     language: markdown
     subagents:
       - meta
       - agent-generator
       - command-generator
     mcp_requirements: []
     registry_impacts: []
     creates_root_on: "When generating a new .opencode system after user confirmation"
     creates_subdir: []
     ---
     ```
   - OpenAgents version has minimal frontmatter (just description)

2. **Context Loading Declaration** (Lines 17-21):
   - Backup explicitly lists context files:
     ```
     Context Loaded:
     @context/core/templates/
     @context/core/system/context-guide.md
     @context/core/standards/patterns.md
     @context/context/index.md
     ```
   - OpenAgents version has no context loading declaration

3. **ProofChecker-Specific Domain Examples** (Lines 238-239, 255, 273, 309-310, 397-398, 426-427, 450, 531):
   - Backup adds "Formal verification and proof systems" to domain examples
   - Adds "Develop and verify formal proofs" to purpose examples
   - Adds "Researchers and academics", "Mathematicians and logicians" to user examples
   - Adds formal_verification_indicators classification
   - Adds proof-specific command examples (/prove, /verify)
   - Adds "Proof development requires verification" to dependency examples

4. **Context File Paths** (Lines 43, 68-72):
   - Backup references ProofChecker-specific context structure:
     ```
     context/common/**/*.md
     context/project/{logic,lean4,math,physics,repo}/**/*.md
     ```
   - OpenAgents version has generic context/ structure

5. **Agent Routing** (Lines 627, 803):
   - Backup routes to `@subagents/meta` (subagents directory)
   - OpenAgents routes to `@builder` (top-level agent)

6. **Git Workflow Integration** (Lines 899-901):
   - Backup adds git_commits quality standard:
     ```xml
     <git_commits>
       When meta writes or modifies files, use git-commits.md + git-workflow-manager 
       to stage only generated/updated files and commit with scoped messages after 
       validation; avoid blanket adds.
     </git_commits>
     ```
   - OpenAgents version has no git workflow integration

### 2.2 What Should Be Preserved

**From Backup Version**:
1. **Frontmatter metadata** (agent, context_level, language, subagents, etc.)
2. **ProofChecker-specific domain examples** (formal verification, proof systems)
3. **Git workflow integration** (git-workflow-manager for commits)
4. **ProofChecker context structure** (project/{logic,lean4,math,physics,repo})

**From OpenAgents Version**:
1. **Cleaner workflow structure** (better organized stages)
2. **Comprehensive interview patterns** (progressive disclosure, adaptive questioning)
3. **Routing intelligence section** (analyze → allocate → execute)
4. **Architecture principles section** (modular, hierarchical, context-efficient)

### 2.3 What Should Be Updated

**For Current Standards (Tasks 244-247)**:
1. **Frontmatter delegation pattern**: Command should be thin delegation layer (~144 lines)
2. **Workflow ownership**: Agent owns 8-stage workflow, not command
3. **Lazy context loading**: Use context index, load on-demand
4. **Git workflow integration**: Use git-workflow-manager for scoped commits
5. **NO EMOJI**: Remove all emoji from documentation (per documentation.md standards)

---

## 3. Current System-Builder Agents Analysis

### 3.1 Agent Inventory

**Location**: `.opencode/agent/subagents/system-builder/`  
**Agent Count**: 5

1. **domain-analyzer.md** (508 lines)
   - Analyzes user domains to identify core concepts, recommended agents, context structure
   - Frontmatter: name, version, description, mode, agent_type, temperature, max_tokens, timeout, tools, permissions, context_loading, delegation, lifecycle
   - Well-structured with inputs_required, process_flow, domain_patterns, constraints, output_specification, validation_checks

2. **agent-generator.md** (534 lines)
   - Generates XML-optimized agent files (orchestrator and subagents)
   - Frontmatter: name, version, description, mode, agent_type, temperature, max_tokens, timeout, tools, permissions, context_loading, delegation, lifecycle
   - Includes xml_optimization_patterns, agent_type_templates, constraints, output_specification, validation_checks

3. **workflow-designer.md** (298 lines)
   - Designs complete workflow definitions with context dependencies and success criteria
   - Frontmatter: name, version, description, mode, agent_type, temperature, max_tokens, timeout, tools, permissions, context_loading, delegation, lifecycle
   - Includes workflow_patterns, constraints, output_specification, validation_checks

4. **command-creator.md** (267 lines)
   - Creates custom slash commands with clear syntax, routing, and documentation
   - Frontmatter: name, version, description, mode, agent_type, temperature, max_tokens, timeout, tools, permissions, context_loading, delegation, lifecycle
   - Includes command_patterns, constraints, output_specification, validation_checks, design_principles

5. **context-organizer.md** (427 lines)
   - Organizes and generates context files (domain, processes, standards, templates)
   - Frontmatter: name, version, description, mode, agent_type, temperature, max_tokens, timeout, tools, permissions, context_loading, delegation, lifecycle
   - Includes file_organization_principles, constraints, output_specification, validation_checks, organization_principles

### 3.2 Current Capabilities

**Strengths**:
1. **Comprehensive frontmatter**: All agents have detailed frontmatter with context_loading, delegation, lifecycle
2. **XML structure**: All agents use XML tags for organization (context, role, task, process_flow, etc.)
3. **Validation checks**: All agents have pre_execution and post_execution validation
4. **Clear constraints**: All agents define must/must_not constraints
5. **Output specifications**: All agents provide YAML/JSON output format examples

**Gaps for Current Standards**:
1. **NO 8-stage workflow**: Agents don't follow the 8-stage workflow pattern from tasks 244-247
2. **NO status-sync-manager integration**: No atomic status updates to TODO.md and state.json
3. **NO git-workflow-manager integration**: No scoped git commits after artifact creation
4. **NO subagent-return-format.md compliance**: Return formats don't match standardized format
5. **Context loading strategy**: Uses lazy loading but doesn't reference context index
6. **Lifecycle stage**: All specify "stage: 4" but don't implement full 8-stage workflow

### 3.3 Needed Updates

**For Current Standards Compliance**:

1. **8-Stage Workflow Implementation**:
   - Stage 1: Input Validation
   - Stage 2: Context Loading (use context index)
   - Stage 3: Core Execution (current process_flow)
   - Stage 4: Output Generation
   - Stage 5: Artifact Creation
   - Stage 6: Return Formatting (subagent-return-format.md)
   - Stage 7: Artifact Validation, Status Updates, Git Commits
   - Stage 8: Cleanup

2. **Status-Sync-Manager Integration**:
   - Invoke status-sync-manager for atomic TODO.md and state.json updates
   - Pass task_number, new_status, timestamp, session_id, delegation context
   - Validate return status and files_updated

3. **Git-Workflow-Manager Integration**:
   - Invoke git-workflow-manager for scoped commits
   - Pass scope_files, message_template, task_context, session_id, delegation context
   - Validate return status and commit hash

4. **Subagent Return Format**:
   - Return standardized format with status, summary, artifacts, metadata, errors, next_steps
   - Summary field <100 tokens (context window protection)
   - Artifacts array with type, path, summary
   - Metadata with session_id, duration_seconds, agent_type, delegation_depth, delegation_path

5. **Context Index Integration**:
   - Reference `.opencode/context/index.md` in context_loading.index
   - Load only required context files on-demand
   - Avoid loading context during routing (only during execution)

6. **NO EMOJI Compliance**:
   - Remove all emoji from agent files
   - Use text-based status indicators ([PASS]/[FAIL]/[WARN])

---

## 4. Integration Requirements

### 4.1 Orchestrator Integration

**Current Orchestrator Pattern** (from tasks 244-247):
```yaml
---
agent: orchestrator
---
```

**Routing Logic**:
1. Parse command frontmatter to extract `agent:` field
2. Validate agent file exists
3. Load agent file
4. Delegate request to agent
5. Return agent response

**For /meta Command**:
- Frontmatter should specify `agent: orchestrator` (meta command handles routing internally)
- OR frontmatter should specify `agent: meta` (new meta agent in subagents/meta/)
- Recommendation: Use `agent: meta` pattern for consistency with other commands

### 4.2 Context File Organization

**Current Context Structure** (from task 246):
```
.opencode/context/
├── index.md (lazy-loading entry point)
├── core/
│   ├── standards/
│   │   ├── delegation.md
│   │   └── subagent-return-format.md
│   ├── system/
│   │   └── state-management.md
│   └── workflows/
│       └── status-transitions.md
├── common/ (legacy, being phased out)
└── project/ (domain-specific)
```

**For /meta Command Context**:
1. **Create focused context files** (<200 lines each):
   - `.opencode/context/meta/interview-patterns.md` (progressive disclosure, adaptive questioning)
   - `.opencode/context/meta/architecture-principles.md` (modular, hierarchical, context-efficient)
   - `.opencode/context/meta/domain-patterns.md` (ecommerce, data engineering, customer support, etc.)
   - `.opencode/context/meta/agent-templates.md` (orchestrator, research, validation, processing, generation)

2. **Update context index** (`.opencode/context/index.md`):
   - Add meta/ section with lazy-loading references
   - Document when to load each meta context file

3. **Avoid context bloat**:
   - Don't load meta context during routing (only during execution)
   - Load only required context files based on interview stage
   - Use lazy loading strategy from context_loading.strategy

### 4.3 State.json Tracking Requirements

**Current State Schema** (v1.1.0):
```json
{
  "project_number": 256,
  "project_name": "add_meta_command",
  "type": "feature",
  "phase": "implementation_completed",
  "status": "completed",
  "priority": "medium",
  "language": "markdown",
  "created": "2025-12-29T00:00:00Z",
  "started": "2025-12-29",
  "completed": "2025-12-29",
  "last_updated": "2025-12-29",
  "artifacts": [
    ".opencode/command/meta.md",
    ".opencode/agent/subagents/meta/domain-analyzer.md",
    ".opencode/agent/subagents/meta/agent-generator.md",
    ".opencode/agent/subagents/meta/workflow-designer.md",
    ".opencode/agent/subagents/meta/command-creator.md",
    ".opencode/agent/subagents/meta/context-organizer.md"
  ]
}
```

**Integration Points**:
1. **Task creation**: /meta command should create tasks in TODO.md via status-sync-manager
2. **Status transitions**: [NOT STARTED] → [RESEARCHING] → [RESEARCHED] → [PLANNED] → [IMPLEMENTING] → [COMPLETED]
3. **Artifact tracking**: All generated files tracked in state.json artifacts array
4. **Timestamp recording**: ISO 8601 format for all timestamps

### 4.4 Git Workflow Integration

**Current Git Pattern** (from git-workflow-manager):
```bash
# Invoke git-workflow-manager for scoped commits
delegation_context = {
  "scope_files": [
    ".opencode/command/meta.md",
    ".opencode/agent/subagents/meta/*.md",
    ".opencode/context/meta/*.md",
    ".opencode/specs/TODO.md",
    ".opencode/specs/state.json"
  ],
  "message_template": "task 256: add /meta command with system-builder subagents",
  "task_context": {
    "task_number": 256,
    "description": "add /meta command"
  },
  "session_id": "sess_20251229_task256",
  "delegation_depth": 2,
  "delegation_path": ["orchestrator", "meta", "git-workflow-manager"]
}
```

**Integration Requirements**:
1. **Scoped commits**: Only stage generated/updated files (no blanket `git add .`)
2. **Descriptive messages**: Include task number and brief description
3. **Validation**: Verify commit created successfully, log commit hash
4. **Error handling**: Log warning if commit fails (non-critical, don't fail command)

---

## 5. Standards Compliance

### 5.1 Frontmatter Delegation Pattern (ADR-003)

**Current Pattern** (from tasks 244-247):
```yaml
---
name: research
agent: orchestrator
description: "Conduct research and create reports with [RESEARCHED] status"
context_level: 2
language: markdown
routing:
  language_based: true
  lean: lean-research-agent
  default: researcher
timeout: 3600
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/standards/subagent-return-format.md"
    - "core/workflows/status-transitions.md"
    - "core/system/routing-guide.md"
  optional:
    - "project/lean4/tools/leansearch-api.md"
  max_context_size: 50000
---
```

**For /meta Command**:
```yaml
---
name: meta
agent: orchestrator
description: "Interactive system builder that creates complete context-aware AI architectures"
context_level: 2
language: markdown
routing:
  default: meta
timeout: 7200
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/standards/subagent-return-format.md"
    - "core/workflows/status-transitions.md"
  optional:
    - "meta/interview-patterns.md"
    - "meta/architecture-principles.md"
    - "meta/domain-patterns.md"
  max_context_size: 60000
---
```

**Command File Structure** (target <300 lines):
```markdown
---
[frontmatter]
---

# /meta Command

## Purpose
[Brief description]

## Usage
[Syntax and examples]

## Workflow
[High-level workflow description - delegates to meta agent]

## Artifacts
[What gets created]

## Prerequisites
[What's needed]

## Related Commands
[Links to related commands]
```

### 5.2 XML Optimization Patterns

**Current Standards** (from agent-generator.md):

1. **Optimal Component Sequence**:
   - Context (hierarchical: system→domain→task→execution)
   - Role (clear identity and expertise)
   - Task (specific objective)
   - Instructions/Workflow (detailed procedures)
   - Examples (when needed)
   - Constraints (boundaries)
   - Validation (quality checks)

2. **Component Ratios**:
   - Role: 5-10% of total prompt
   - Context: 15-25% hierarchical information
   - Instructions: 40-50% detailed procedures
   - Examples: 20-30% when needed
   - Constraints: 5-10% boundaries

3. **Routing Patterns**:
   - Subagent references: Always use @ symbol (e.g., @domain-analyzer)
   - Delegation syntax: Route to @{agent-name} when {condition}
   - Context specification: Always specify context_level for each route
   - Return specification: Define expected_return for every subagent call

4. **Workflow Patterns**:
   - Stage structure: id, name, action, prerequisites, process, checkpoint, outputs
   - Decision trees: Use if/else logic with clear conditions
   - Validation gates: Checkpoints with numeric thresholds (e.g., 8+ to proceed)
   - Failure handling: Define what happens when validation fails

### 5.3 Context Efficiency (ADR-001)

**Lazy Loading Strategy**:
1. **Context Index** (`.opencode/context/index.md`):
   - Single entry point for all context discovery
   - Lists all available context files with descriptions
   - Agents load index first, then load required files on-demand

2. **Loading Stages**:
   - **Routing**: Load only context index (5% context usage)
   - **Execution**: Load required context files based on task (varies)
   - **Never**: Load all context files upfront (old pattern)

3. **Context File Size**:
   - Target: 50-200 lines per file
   - Maximum: 300 lines per file
   - Rationale: Small files easier to load selectively

4. **Context Categories**:
   - **core/**: System-wide standards and workflows (always available)
   - **common/**: Legacy context (being phased out)
   - **project/**: Domain-specific context (load on-demand)
   - **meta/**: Meta-programming context (load for /meta command only)

### 5.4 Validation Requirements

**Pre-Execution Validation**:
1. Verify all required parameters provided
2. Validate parameter types and formats
3. Check prerequisites (files exist, dependencies met)
4. Validate delegation depth (must be < 3)
5. Return error if validation fails

**Post-Execution Validation**:
1. Verify all artifacts created successfully
2. Verify artifacts are non-empty
3. Verify artifacts contain required sections
4. Verify artifacts within size limits
5. Verify return format matches subagent-return-format.md
6. Verify TODO.md and state.json updated (if applicable)
7. Verify git commit created (if applicable)

**Validation Thresholds**:
- Quality score: 8+/10 to pass
- File size: <300 lines for commands, <600 lines for agents
- Context usage: <10% during routing, <50% during execution
- Stage 7 execution rate: 100% (critical)

---

## 6. Recommendations

### 6.1 Implementation Approach

**Phase 1: Command Migration** (2-3 hours):
1. Create `.opencode/command/meta.md` using frontmatter delegation pattern
2. Adapt from OpenAgents version with ProofChecker-specific examples
3. Target <300 lines (thin delegation layer)
4. Include frontmatter with agent routing, context loading, timeout
5. Document 8-stage workflow at high level (delegates to meta agent)

**Phase 2: Directory Rename** (1 hour):
1. Rename `.opencode/agent/subagents/system-builder/` to `.opencode/agent/subagents/meta/`
2. Update all internal references to new directory
3. Update context index to reference meta/ instead of system-builder/
4. Verify no broken links or references

**Phase 3: Agent Updates** (4-6 hours):
1. Update all 5 meta subagents to follow 8-stage workflow pattern
2. Add status-sync-manager integration for atomic status updates
3. Add git-workflow-manager integration for scoped commits
4. Update return formats to match subagent-return-format.md
5. Remove all emoji, use text-based status indicators
6. Validate against current standards (ADR-001, ADR-002, ADR-003)

**Phase 4: Context Organization** (2-3 hours):
1. Create focused context files in `.opencode/context/meta/`:
   - interview-patterns.md (progressive disclosure, adaptive questioning)
   - architecture-principles.md (modular, hierarchical, context-efficient)
   - domain-patterns.md (ecommerce, data engineering, customer support, etc.)
   - agent-templates.md (orchestrator, research, validation, processing, generation)
2. Update context index with meta/ section
3. Ensure all files <200 lines
4. Document lazy loading strategy

**Phase 5: Integration Testing** (2-3 hours):
1. Test /meta command with simple domain
2. Verify frontmatter delegation works
3. Verify 8-stage workflow executes correctly
4. Verify artifacts created successfully
5. Verify TODO.md and state.json updated
6. Verify git commit created
7. Measure context usage (target <10% during routing)

**Phase 6: Documentation** (1-2 hours):
1. Update README or guide with /meta command usage
2. Document interview process and workflow
3. Provide examples for common domains
4. Document integration with status-sync-manager and git-workflow-manager
5. Add troubleshooting tips

**Total Estimated Effort**: 12-18 hours (within 8-12 hour task estimate with some buffer)

### 6.2 Context File Organization Strategy

**Avoid Bloat Through**:
1. **Focused Files**: Each file serves ONE clear purpose (50-200 lines)
2. **Lazy Loading**: Load only required files based on interview stage
3. **Clear Naming**: File names clearly indicate contents
4. **No Duplication**: Each piece of knowledge exists in exactly one file
5. **Documented Dependencies**: Files list what other files they depend on

**Context Loading Strategy**:
```yaml
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/standards/subagent-return-format.md"  # Always needed
    - "core/workflows/status-transitions.md"      # Always needed
  optional:
    - "meta/interview-patterns.md"                # Load during interview stages
    - "meta/architecture-principles.md"           # Load during architecture design
    - "meta/domain-patterns.md"                   # Load during domain analysis
    - "meta/agent-templates.md"                   # Load during agent generation
  max_context_size: 60000
```

**Loading Stages**:
- **Stage 0-1** (DetectExistingProject, InitiateInterview): Load index only
- **Stage 2-2.5** (GatherDomainInfo, DetectDomainType): Load interview-patterns.md, domain-patterns.md
- **Stage 3-5** (IdentifyUseCases, AssessComplexity, IdentifyIntegrations): Load architecture-principles.md
- **Stage 6** (ReviewAndConfirm): Load agent-templates.md
- **Stage 7-8** (GenerateSystem, DeliverSystem): Delegate to meta subagents (they load their own context)

### 6.3 Standards Alignment

**Align with Tasks 244-247 Patterns**:

1. **Frontmatter Delegation** (ADR-003):
   - Command file <300 lines (thin delegation layer)
   - Agent owns 8-stage workflow
   - Frontmatter specifies agent, context_level, routing, timeout, context_loading

2. **Context Index** (ADR-001):
   - Use `.opencode/context/index.md` as single entry point
   - Load only required context files on-demand
   - Reduce routing context from 30-40% to <10%

3. **Agent Workflow Ownership** (ADR-002):
   - Agents own complete 8-stage workflow
   - Stage 7 (Artifact Validation, Status Updates, Git Commits) is critical
   - Use status-sync-manager for atomic TODO.md and state.json updates
   - Use git-workflow-manager for scoped commits

4. **Subagent Return Format**:
   - Return standardized format with status, summary, artifacts, metadata, errors, next_steps
   - Summary field <100 tokens (context window protection)
   - Artifacts array with type, path, summary
   - Metadata with session_id, duration_seconds, agent_type, delegation_depth, delegation_path

5. **NO EMOJI Compliance**:
   - Remove all emoji from command and agent files
   - Use text-based status indicators ([PASS]/[FAIL]/[WARN])
   - Follow documentation.md standards

### 6.4 Validation Checklist

**Command File Validation**:
- [ ] Frontmatter includes agent, context_level, routing, timeout, context_loading
- [ ] Command file <300 lines
- [ ] No embedded routing logic (delegated to agent)
- [ ] No embedded workflow execution (delegated to agent)
- [ ] Documentation complete (purpose, usage, examples, workflow, artifacts)
- [ ] NO EMOJI (text-based status indicators only)

**Agent File Validation**:
- [ ] 8-stage workflow implemented (all stages present)
- [ ] Stage 7 (Artifact Validation, Status Updates, Git Commits) implemented
- [ ] Status-sync-manager integration for atomic status updates
- [ ] Git-workflow-manager integration for scoped commits
- [ ] Return format matches subagent-return-format.md
- [ ] Summary field <100 tokens
- [ ] Context loading uses context index
- [ ] NO EMOJI (text-based status indicators only)

**Context File Validation**:
- [ ] All files <200 lines (target) or <300 lines (maximum)
- [ ] No duplication across files
- [ ] Dependencies documented
- [ ] Clear, descriptive file names
- [ ] Lazy loading strategy documented
- [ ] Context index updated with meta/ section

**Integration Validation**:
- [ ] /meta command routes to meta agent successfully
- [ ] 8-stage workflow executes correctly
- [ ] Artifacts created successfully
- [ ] TODO.md and state.json updated atomically
- [ ] Git commit created with scoped files
- [ ] Context usage <10% during routing
- [ ] NO EMOJI in any generated files

---

## 7. Key Findings Summary

### 7.1 OpenAgents /meta Command

**Structure**: 862-line command with 8-stage interactive workflow (DetectExistingProject → DeliverSystem)

**Key Features**:
- Progressive disclosure interview pattern (broad → specific)
- Domain type detection (development, business, hybrid)
- Merge strategy support (extend, separate, replace)
- Routing intelligence (@ symbol pattern, context levels)
- Architecture principles (modular, hierarchical, context-efficient)

**Strengths**:
- Comprehensive interview process
- Well-organized workflow stages
- Clear routing patterns
- Research-backed XML optimization

**Gaps for ProofChecker**:
- No frontmatter delegation pattern
- No lazy context loading
- No status-sync-manager integration
- No git-workflow-manager integration
- Includes emoji (violates NO EMOJI standard)

### 7.2 Backup Version

**Structure**: 921-line command (59 lines longer than OpenAgents)

**Key Additions**:
- Detailed frontmatter metadata (agent, context_level, subagents, etc.)
- ProofChecker-specific domain examples (formal verification, proof systems)
- Git workflow integration (git-workflow-manager)
- ProofChecker context structure (project/{logic,lean4,math,physics,repo})

**Strengths**:
- More complete frontmatter
- ProofChecker-specific examples
- Git workflow integration

**Gaps**:
- Still too long (921 lines vs. 300 line target)
- Embedded workflow (should be in agent)
- Includes emoji (violates NO EMOJI standard)

### 7.3 Current System-Builder Agents

**Inventory**: 5 agents (domain-analyzer, agent-generator, workflow-designer, command-creator, context-organizer)

**Strengths**:
- Comprehensive frontmatter with context_loading, delegation, lifecycle
- XML structure (context, role, task, process_flow, etc.)
- Validation checks (pre_execution, post_execution)
- Clear constraints (must/must_not)
- Output specifications (YAML/JSON examples)

**Gaps**:
- No 8-stage workflow implementation
- No status-sync-manager integration
- No git-workflow-manager integration
- No subagent-return-format.md compliance
- Context loading doesn't reference context index
- Includes emoji (violates NO EMOJI standard)

### 7.4 Integration Requirements

**Orchestrator Integration**:
- Use frontmatter delegation pattern (agent: meta)
- Route to meta agent based on frontmatter
- Validate agent file exists and load

**Context Organization**:
- Create focused files in .opencode/context/meta/ (<200 lines each)
- Update context index with meta/ section
- Use lazy loading strategy (load on-demand)

**State Tracking**:
- Use status-sync-manager for atomic TODO.md and state.json updates
- Track all generated files in state.json artifacts array
- Record timestamps in ISO 8601 format

**Git Workflow**:
- Use git-workflow-manager for scoped commits
- Stage only generated/updated files (no blanket adds)
- Include task number in commit message
- Validate commit created successfully

### 7.5 Standards Compliance

**Frontmatter Delegation** (ADR-003):
- Command <300 lines (thin delegation layer)
- Agent owns 8-stage workflow
- Frontmatter specifies routing metadata

**Context Index** (ADR-001):
- Use .opencode/context/index.md as entry point
- Load only required files on-demand
- Reduce routing context to <10%

**Agent Workflow Ownership** (ADR-002):
- Agents own complete 8-stage workflow
- Stage 7 is critical (artifact validation, status updates, git commits)
- Use status-sync-manager and git-workflow-manager

**Validation Requirements**:
- Pre-execution: Validate inputs, prerequisites, delegation depth
- Post-execution: Validate artifacts, return format, status updates, git commits
- Quality threshold: 8+/10 to pass

---

## 8. Sources and Citations

### 8.1 Primary Sources

1. **OpenAgents /meta Command**:
   - File: `/home/benjamin/Projects/OpenAgents/.opencode/command/meta.md`
   - Size: 862 lines
   - Date: 2025-12-29 (accessed)

2. **Backup /meta Command**:
   - File: `.opencode.backup.20251225_173342/command/meta.md`
   - Size: 921 lines
   - Date: 2025-12-25 (backup created)

3. **Current System-Builder Agents**:
   - Location: `.opencode/agent/subagents/system-builder/`
   - Files: domain-analyzer.md (508 lines), agent-generator.md (534 lines), workflow-designer.md (298 lines), command-creator.md (267 lines), context-organizer.md (427 lines)
   - Date: 2025-12-29 (accessed)

### 8.2 Reference Documentation

4. **ADR-003: Frontmatter Delegation Pattern**:
   - File: `.opencode/docs/migrations/001-openagents-migration/adr/ADR-003-frontmatter-delegation.md`
   - Key Decision: Commands <300 lines, agent owns workflow
   - Date: 2025-12-28

5. **ADR-001: Context Index (Lazy-Loading Pattern)**:
   - File: `.opencode/docs/migrations/001-openagents-migration/adr/ADR-001-context-index.md`
   - Key Decision: Use context index, load on-demand
   - Date: 2025-12-28

6. **ADR-002: Agent Workflow Ownership Pattern**:
   - File: `.opencode/docs/migrations/001-openagents-migration/adr/ADR-002-agent-workflow-ownership.md`
   - Key Decision: Agents own 8-stage workflow, Stage 7 is critical
   - Date: 2025-12-28

7. **OpenAgents Migration README**:
   - File: `.opencode/docs/migrations/001-openagents-migration/README.md`
   - Summary: 60-hour migration, 85-87% context reduction, 100% reliability
   - Date: 2025-12-29

8. **Command Template**:
   - File: `.opencode/docs/templates/command-template.md`
   - Template for creating new commands
   - Date: 2025-12-29

9. **Agent Template**:
   - File: `.opencode/docs/templates/agent-template.md`
   - Template for creating new agents with 8-stage workflow
   - Date: 2025-12-29

### 8.3 Current Implementation Examples

10. **/research Command**:
    - File: `.opencode/command/research.md`
    - Size: 144 lines (frontmatter delegation pattern)
    - Example of current command standard

11. **researcher Agent**:
    - File: `.opencode/agent/subagents/researcher.md`
    - Size: 534 lines (8-stage workflow implementation)
    - Example of current agent standard

12. **State Schema**:
    - File: `.opencode/specs/state.json`
    - Version: 1.1.0
    - Schema for task tracking

---

## 9. Next Steps

### 9.1 Immediate Actions

1. **Create Implementation Plan**:
   - Break down 6 phases into detailed tasks
   - Estimate effort for each task
   - Identify dependencies and blockers
   - Create timeline and milestones

2. **Prepare Development Environment**:
   - Create task directory: `.opencode/specs/256_add_meta_command/`
   - Create subdirectories: reports/, plans/, summaries/
   - Set up git branch for development (optional)

3. **Review with Stakeholders**:
   - Review research findings with team
   - Validate approach and recommendations
   - Get approval to proceed with implementation

### 9.2 Implementation Sequence

**Phase 1: Command Migration** (2-3 hours):
- Create `.opencode/command/meta.md`
- Adapt from OpenAgents with ProofChecker examples
- Target <300 lines
- Include frontmatter delegation

**Phase 2: Directory Rename** (1 hour):
- Rename system-builder/ to meta/
- Update all references
- Verify no broken links

**Phase 3: Agent Updates** (4-6 hours):
- Update 5 meta subagents to 8-stage workflow
- Add status-sync-manager integration
- Add git-workflow-manager integration
- Update return formats

**Phase 4: Context Organization** (2-3 hours):
- Create focused context files in meta/
- Update context index
- Ensure all files <200 lines

**Phase 5: Integration Testing** (2-3 hours):
- Test /meta command end-to-end
- Verify all integration points
- Measure context usage

**Phase 6: Documentation** (1-2 hours):
- Update README or guide
- Document usage and examples
- Add troubleshooting tips

### 9.3 Success Criteria

**Command File**:
- [ ] <300 lines (thin delegation layer)
- [ ] Frontmatter delegation pattern
- [ ] NO EMOJI (text-based status indicators)
- [ ] Complete documentation

**Agent Files**:
- [ ] 8-stage workflow implemented
- [ ] Stage 7 (Artifact Validation, Status Updates, Git Commits) implemented
- [ ] Status-sync-manager integration
- [ ] Git-workflow-manager integration
- [ ] Return format matches subagent-return-format.md
- [ ] NO EMOJI (text-based status indicators)

**Context Files**:
- [ ] All files <200 lines
- [ ] No duplication
- [ ] Dependencies documented
- [ ] Context index updated

**Integration**:
- [ ] /meta command routes successfully
- [ ] 8-stage workflow executes correctly
- [ ] Artifacts created successfully
- [ ] TODO.md and state.json updated
- [ ] Git commit created
- [ ] Context usage <10% during routing

---

## Conclusion

The /meta command from OpenAgents is a sophisticated interactive system builder that can be successfully integrated into ProofChecker by following the frontmatter delegation pattern, lazy context loading, and agent workflow ownership patterns established in tasks 244-247. The current system-builder agents provide a solid foundation but require updates to follow the 8-stage workflow pattern, integrate with status-sync-manager and git-workflow-manager, and comply with current standards (NO EMOJI, subagent-return-format.md, context index).

The recommended implementation approach involves 6 phases (12-18 hours total effort) that progressively migrate the command, rename the directory, update the agents, organize context files, test integration, and document usage. This approach maintains the high standards from the OpenAgents migration refactor while enabling powerful meta-programming capabilities for the ProofChecker .opencode system.

**Research Status**: [COMPLETED]  
**Recommendation**: Proceed with implementation following the 6-phase approach outlined in this report.

---

**Report Version**: 1.0  
**Last Updated**: 2025-12-29  
**Maintained By**: ProofChecker Development Team
