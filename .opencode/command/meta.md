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

**Task Input (optional):** $ARGUMENTS (description, --ask description, or empty)

**Usage:** `/meta [--ask] [DESCRIPTION]`

# /meta Command

## Purpose

The `/meta` command creates tasks to implement new .opencode system capabilities. It supports three modes:

1. **Direct Mode** (`/meta {description}`): Creates tasks immediately from description
2. **Clarification Mode** (`/meta --ask {description}`): Asks follow-up questions before creating tasks
3. **Interactive Mode** (`/meta`): Conducts full guided interview to gather requirements

**Use this command when you need to**:
- Create a new .opencode system for a specific domain
- Extend an existing .opencode system with new capabilities
- Design and generate custom agents and commands
- Organize context files for a new domain or workflow

---

## Usage

```
/meta [--ask] [DESCRIPTION]
```

- **Direct Mode**: Provide description, tasks created immediately
- **Clarification Mode**: Provide description with --ask flag, answer follow-up questions
- **Interactive Mode**: No arguments, full guided interview

### Examples

```
# Example 1: Direct mode - create tasks immediately
/meta "Add proof verification capabilities to the system"

# Example 2: Direct mode - create new system
/meta "Create a system for managing customer support tickets with automated routing"

# Example 3: Clarification mode - ask follow-up questions
/meta --ask "Improve the testing workflow"

# Example 4: Interactive mode - full guided interview
/meta
> [Interactive interview follows]
```

---

## Workflow

This command delegates to the `meta` agent, which executes a 9-stage workflow:

**Direct Mode (with description):**
- Stage 1 detects Direct Mode
- Skips Stages 2-7 (interview stages)
- Infers all requirements from description
- Proceeds directly to Stage 8 (CreateTasksWithArtifacts)
- Continues to Stage 9 (DeliverTaskSummary)

**Clarification Mode (with --ask description):**
- Stage 1 detects Clarification Mode
- Skips Stage 2 (InitiateInterview)
- Asks 3-5 targeted follow-up questions in Stages 3-6
- Proceeds to Stage 7 (brief confirmation)
- Continues to Stages 8-9

**Interactive Mode (no arguments):**
- Stage 1 detects Interactive Mode
- Executes full 9-stage interactive interview
- Gathers requirements through guided questions

### Stage 0: Detect Existing Project
- Scans for existing .opencode directory
- Offers merge strategies if found (extend, separate, replace, cancel)
- Determines integration approach

### Stage 1: Parse and Validate
- Detects mode: --ask flag → Clarification Mode, description → Direct Mode, empty → Interactive Mode
- **Direct Mode**: Parses description for inference
- **Clarification Mode**: Parses description after --ask flag
- **Interactive Mode**: Prepares for full interview
- Determines which stages to execute based on mode

### Stage 2: Initiate Interview
- **Conditional**: Skipped in Direct Mode and Clarification Mode
- Explains the meta-programming process
- Sets expectations for interview stages
- Confirms user readiness to proceed

### Stage 3: Gather Domain Information
- **Direct Mode**: Infers domain/purpose/target_users from description, no questions
- **Clarification Mode**: Asks 2-3 targeted questions for ambiguous information
- **Interactive Mode**: Full questioning about domain, purpose, and target users
- Identifies domain type (development, business, hybrid, formal verification)

### Stage 4: Identify Use Cases
- **Direct Mode**: Infers 3-5 use cases from description, no questions
- **Clarification Mode**: Asks 1-2 questions to confirm/refine use cases
- **Interactive Mode**: Full questioning about top 3-5 use cases
- Assesses complexity and dependencies

### Stage 5: Assess Complexity
- **Direct Mode**: Infers agent count/hierarchy from use cases, no questions
- **Clarification Mode**: Asks 1 question to confirm architecture recommendation
- **Interactive Mode**: Full questioning about agent count, hierarchy, knowledge areas
- Plans state management approach

### Stage 6: Identify Integrations
- **Direct Mode**: Infers external tools/file types/commands from domain, no questions
- **Clarification Mode**: Asks 1 question to confirm integrations
- **Interactive Mode**: Full questioning about external tools, file types, custom commands
- Maps integration points

### Stage 7: Review and Confirm
- **Direct Mode**: Skipped, proceeds directly to task creation
- **Clarification Mode**: Brief confirmation with option to revise
- **Interactive Mode**: Full architecture summary and confirmation
- Validates understanding before generation

### Stage 8: Create Tasks With Artifacts
- All modes create multiple tasks with plan artifacts
- Generates plan artifacts (plans/implementation-001.md)
- Creates task entries in TODO.md with Type field set to 'meta'
- Updates state.json with task metadata
- Validates all artifacts

### Stage 9: Deliver Task Summary
- All modes present task list with plan artifact links
- Provides usage instructions for /implement command
- Explains meta task routing to meta subagents
- Creates git commit with artifacts
- Returns standardized format with task metadata

---

## Mode Detection

The /meta command automatically detects which mode to use based on $ARGUMENTS:

1. **Direct Mode Detection**:
   - Description provided without --ask flag
   - Example: `/meta "Add proof verification"`
   - Behavior: Creates tasks immediately, no questions asked

2. **Clarification Mode Detection**:
   - Description provided with --ask flag
   - Example: `/meta --ask "Improve testing"`
   - Behavior: Asks 3-5 targeted follow-up questions, then creates tasks

3. **Interactive Mode Detection**:
   - No arguments provided
   - Example: `/meta`
   - Behavior: Conducts full guided interview (6 stages)

### When to Use Each Mode

- **Use Direct Mode** when requirements are clear and complete
- **Use Clarification Mode** when requirements are somewhat clear but may need refinement
- **Use Interactive Mode** when requirements are unclear or complex

**Examples**:
- `/meta "Add proof verification capabilities"` - Clear requirement, use Direct Mode
- `/meta --ask "Improve the workflow"` - Vague requirement, use Clarification Mode
- `/meta` - No idea what you need, use Interactive Mode

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
