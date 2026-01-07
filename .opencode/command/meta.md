---
name: meta
agent: orchestrator
description: "Interactive system builder that creates complete context-aware AI architectures tailored to user domains"
context_level: 2
language: markdown
routing:
  default: meta
timeout: 7200
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/formats/subagent-return.md"
    - "core/workflows/status-transitions.md"
  optional:
    - "project/meta/interview-patterns.md"
    - "project/meta/architecture-principles.md"
    - "project/meta/domain-patterns.md"
    - "core/templates/agent-template.md"
  max_context_size: 60000
---

**Task Input (optional):** $ARGUMENTS (task number, user prompt, or empty; e.g., `/meta 294`, `/meta "I want to revise my opencode system..."`, or `/meta`)

**Usage:** `/meta [TASK_NUMBER | PROMPT]`

# /meta Command

## Purpose

The `/meta` command is a system builder that creates complete .opencode architectures. It can work in three modes:
1. **Task Mode** (with task number): Creates implementation plan for existing meta task
2. **Prompt Mode** (with text prompt): Accepts requirements directly and proceeds with system generation
3. **Interactive Mode** (no arguments): Conducts guided interview to gather requirements

**Use this command when you need to**:
- Create a new .opencode system for a specific domain
- Extend an existing .opencode system with new capabilities
- Design and generate custom agents and commands
- Organize context files for a new domain or workflow

---

## Usage

```
/meta [TASK_NUMBER | PROMPT]
```

- **With task number**: Create implementation plan for existing meta task
- **With prompt**: Provide requirements directly, skip interactive interview
- **Without arguments**: Start interactive interview to gather requirements

### Examples

```
# Example 1: Task mode - create plan for existing task
/meta 294

# Example 2: Prompt mode - provide requirements directly
/meta "I want to revise my opencode system to add proof verification capabilities"

# Example 3: Prompt mode - create new system
/meta "Create a system for managing customer support tickets with automated routing"

# Example 4: Interactive mode - guided interview
/meta
> [Interactive interview follows]
```

---

## Workflow

This command delegates to the `meta` agent, which executes a 9-stage workflow:

**Task Mode (with task number):**
- Stage 1 detects task number and extracts metadata from state.json
- Skips Stages 2-7 (interview stages)
- Proceeds directly to Stage 8 (CreateTasksWithArtifacts) to create plan for single task
- Continues to Stage 9 (DeliverTaskSummary)

**Prompt Mode (with text prompt):**
- Stage 1 detects prompt mode
- Skips Stage 2 (InitiateInterview)
- Uses $ARGUMENTS as target_domain
- Proceeds to Stage 3 (GatherDomainInformation) with domain context
- Continues through remaining stages

**Interactive Mode (no $ARGUMENTS):**
- Stage 1 detects interactive mode
- Executes full 9-stage interactive interview
- Gathers requirements through guided questions

### Stage 0: Detect Existing Project
- Scans for existing .opencode directory
- Offers merge strategies if found (extend, separate, replace, cancel)
- Determines integration approach

### Stage 1: Parse and Validate (NEW)
- Detects mode: Task Mode (integer) → Prompt Mode (text) → Interactive Mode (empty)
- **Task Mode**: Parses task number, validates in state.json, extracts metadata
- **Prompt Mode**: Parses prompt text for domain context
- **Interactive Mode**: Prepares for full interview
- Determines which stages to execute based on mode

### Stage 2: Initiate Interview
- **Conditional**: Skipped in Task Mode and Prompt Mode
- Explains the meta-programming process
- Sets expectations for interview stages
- Confirms user readiness to proceed

### Stage 3: Gather Domain Information
- **Conditional**: Skipped in Task Mode; pre-populated in Prompt Mode
- Asks about domain, purpose, and target users
- Captures high-level requirements
- Identifies domain type (development, business, hybrid, formal verification)

### Stage 4: Identify Use Cases
- **Conditional**: Skipped in Task Mode
- Explores top 3-5 use cases
- Assesses complexity and dependencies
- Prioritizes capabilities

### Stage 5: Assess Complexity
- **Conditional**: Skipped in Task Mode
- Determines agent count and hierarchy
- Identifies knowledge types needed
- Plans state management approach

### Stage 6: Identify Integrations
- **Conditional**: Skipped in Task Mode
- Discovers external tool requirements
- Plans file operations and custom commands
- Maps integration points

### Stage 7: Review and Confirm
- **Conditional**: Skipped in Task Mode
- Presents comprehensive architecture summary
- Gets user confirmation
- Validates understanding before generation

### Stage 8: Create Tasks With Artifacts
- **Task Mode**: Creates single plan artifact for existing task in task directory
- **Prompt/Interactive Mode**: Creates multiple tasks with plan artifacts
- Generates plan artifacts (plans/implementation-001.md)
- Creates/updates task entries in TODO.md with Type field set to 'meta'
- Updates state.json with task metadata
- Validates all artifacts

### Stage 9: Deliver Task Summary
- **Task Mode**: Presents plan artifact link and usage instructions for /implement
- **Prompt/Interactive Mode**: Presents task list with plan artifact links
- Provides usage instructions for /implement command
- Explains meta task routing to meta subagents
- Creates git commit with artifacts
- Returns standardized format with task metadata

---

## Mode Detection

The /meta command automatically detects which mode to use based on $ARGUMENTS:

1. **Task Mode Detection**:
   - First token is an integer (e.g., "294")
   - Task exists in state.json
   - If task not found: Falls back to Prompt Mode with warning

2. **Prompt Mode Detection**:
   - First token is non-integer text (e.g., "I want to...")
   - OR task number not found in state.json

3. **Interactive Mode Detection**:
   - No arguments provided

### When to Use /meta vs /plan

- **Use /meta for meta tasks**: Tasks that involve creating/modifying .opencode system components (agents, commands, context files)
- **Use /plan for implementation tasks**: Tasks that involve implementing features, fixing bugs, or adding functionality to your project

**Examples**:
- `/meta 294` - Create plan for meta task 294 (revise /meta command)
- `/plan 315` - Create plan for implementation task 315 (resolve Axiom blocker)

---

## Artifacts

This command creates the following artifacts:

- **Task Entries**: `.opencode/specs/TODO.md`
  - Task entries for each component to be implemented
  - Type field set to 'meta' for meta-related tasks
  - Status set to [NOT STARTED]
  - Links to plan artifacts

- **Plan Artifacts**: `.opencode/specs/NNN_task_name/plans/implementation-001.md`
  - Detailed implementation plans for each task
  - Self-documenting with metadata, phases, and estimates
  - Follows plan.md standard
  - ONLY artifact type created (no research or summary artifacts)

- **State Tracking**: Updates to `.opencode/specs/state.json`
  - Task metadata in active_projects array
  - Incremented next_project_number for each task
  - Type field set to 'meta' for meta tasks

- **Git Commit**: Scoped commit with all artifacts
  - Commit message: "meta: create tasks for {domain} system ({N} tasks)"
  - Includes: TODO.md, state.json, all task directories with plan artifacts

**Note**: The /meta command creates TASKS with PLAN ARTIFACTS, not the final system. Use `/implement {task_number}` to implement each task, which will route to meta subagents (domain-analyzer, workflow-designer, agent-generator, command-creator, context-organizer) to create the actual agents, commands, and context files.

---

## Prerequisites

- Clear understanding of your domain and use cases
- Ability to answer questions about:
  - Domain purpose and target users
  - Key use cases and workflows
  - Complexity and integration requirements
- Time to complete interactive interview (15-30 minutes)
- Existing .opencode system (optional, for extension scenarios)

---

## Interview Patterns

The /meta command uses **progressive disclosure** to gather information:

1. **Broad Questions First**: Start with domain and purpose
2. **Drill Into Specifics**: Based on responses, ask targeted questions
3. **Adaptive Questioning**: Adjust to user's technical level
4. **Example-Driven**: Provide concrete examples for every question
5. **Validation Checkpoints**: Confirm understanding before proceeding

### Domain Type Detection

The command automatically detects domain type to provide relevant guidance:

- **Development**: Code, testing, build, deploy workflows
- **Business**: E-commerce, support, marketing, content management
- **Hybrid**: Data engineering, product management, analytics
- **Formal Verification**: Proof systems, theorem proving, verification (ProofChecker-specific)

---

## Architecture Principles

Systems generated by /meta follow these principles:

1. **Modular Design**: Small, focused files (50-200 lines)
2. **Hierarchical Organization**: Orchestrator + subagents pattern
3. **Context Efficiency**: 80% Level 1, 20% Level 2, rare Level 3
4. **Workflow-Driven**: Design workflows first, then agents
5. **Research-Backed**: Stanford/Anthropic XML optimization patterns

---

## Merge Strategies

When extending an existing .opencode system, /meta offers:

- **Extend Existing System** (recommended): Add new capabilities to current system
- **Create Separate System**: Build independent system for multi-domain projects
- **Replace Existing System**: Replace current system (with backup)
- **Cancel**: Exit without changes

---

## Quality Standards

All generated artifacts follow current ProofChecker standards:

- **Frontmatter Delegation**: Commands <300 lines, agents own workflow
- **8-Stage Workflow**: All agents implement complete workflow with Stage 7 critical
- **Context Efficiency**: Lazy loading, context index integration
- **Validation**: Pre-execution and post-execution checks
- **Git Workflow**: Scoped commits via git-workflow-manager
- **Status Tracking**: Atomic updates via status-sync-manager
- **NO EMOJI**: Text-based status indicators ([PASS]/[FAIL]/[WARN])

---

## Related Commands

- `/research`: Conduct research before using /meta to understand domain
- `/plan`: Create implementation plans for generated components
- `/implement`: Execute implementation of generated agents/commands

---

## See Also

- **Agent**: `.opencode/agent/subagents/meta/`
- **Subagents**: domain-analyzer, agent-generator, workflow-designer, command-creator, context-organizer
- **Context Files**: `.opencode/context/core/` (workflows/, standards/, templates/)
- **Workflow Standard**: `.opencode/context/core/workflows/agent-workflow.md`
- **Return Format**: `.opencode/context/core/formats/subagent-return.md`

---

**Command Version**: 1.0  
**Last Updated**: 2025-12-29  
**Maintained By**: ProofChecker Development Team
