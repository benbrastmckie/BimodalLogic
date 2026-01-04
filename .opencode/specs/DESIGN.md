# ProofChecker .opencode System Design

**Version**: 1.0  
**Created**: 2026-01-03  
**Status**: Active  
**Purpose**: Comprehensive design documentation for the ProofChecker .opencode agent system

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [System Architecture](#system-architecture)
3. [Core Principles](#core-principles)
4. [Component Overview](#component-overview)
5. [Command System](#command-system)
6. [Agent System](#agent-system)
7. [Workflow Patterns](#workflow-patterns)
8. [Context Management](#context-management)
9. [State Management](#state-management)
10. [Delegation Model](#delegation-model)
11. [Best Practices](#best-practices)
12. [Comparison with OpenAgents](#comparison-with-openagents)

---

## Executive Summary

The ProofChecker .opencode system is a context-aware AI agent architecture designed for managing Lean 4 formal verification projects. The system follows a hierarchical orchestrator-subagent pattern inspired by the OpenAgents architecture, with specialized enhancements for Lean 4 development workflows.

### Key Design Goals

1. **Context Window Protection**: Minimize context usage through lazy loading, artifact management, and metadata passing
2. **Workflow Separation**: Maintain clear boundaries between research, planning, implementation, and review phases
3. **Language-Based Routing**: Automatically route tasks to appropriate specialized agents (Lean vs general)
4. **Atomic State Updates**: Ensure consistency across TODO.md, state.json, and project files
5. **Standardized Pre/Post-Flight Sequences**: Execute consistent setup and cleanup for all commands

### Architecture Summary

```
User Input → Orchestrator → Command Parser → Subagent Router → Specialized Subagent → Task Execution
                ↓                                                          ↓
           Context Loader                                          Artifact Creation
                ↓                                                          ↓
           Validation                                              Status Sync Manager
                                                                           ↓
                                                                    Git Workflow Manager
```

---

## System Architecture

### Directory Structure

```
.opencode/
├── agent/
│   ├── orchestrator.md                    # Primary routing agent
│   └── subagents/
│       ├── researcher.md                  # General research agent
│       ├── lean-research-agent.md         # Lean-specific research
│       ├── planner.md                     # General planning agent
│       ├── lean-planner.md                # Lean-specific planning
│       ├── implementer.md                 # General implementation
│       ├── lean-implementation-agent.md   # Lean implementation
│       ├── reviewer.md                    # Codebase review
│       ├── status-sync-manager.md         # Atomic status updates
│       ├── git-workflow-manager.md        # Git commit management
│       └── meta.md                        # System modification
├── command/
│   ├── research.md                        # /research command
│   ├── plan.md                            # /plan command
│   ├── revise.md                          # /revise command
│   ├── implement.md                       # /implement command
│   ├── review.md                          # /review command
│   ├── task.md                            # /task command
│   ├── todo.md                            # /todo command
│   └── meta.md                            # /meta command
├── context/
│   ├── core/
│   │   ├── standards/                     # Quality standards
│   │   ├── system/                        # System specifications
│   │   ├── templates/                     # Reusable templates
│   │   └── workflows/                     # Workflow definitions
│   └── project/
│       └── lean4/                         # Lean 4 specific context
└── specs/
    ├── state.json                         # Global state
    ├── TODO.md                            # User-facing task list
    └── NNN_project_name/                  # Project directories
        ├── reports/                       # Research artifacts
        ├── plans/                         # Implementation plans
        └── summaries/                     # Brief summaries
```

---

## Core Principles

### 1. Orchestrator-Centric Design

**All commands run through the Orchestrator agent**, which serves as the primary entry point and router. The Orchestrator is responsible for:

- Parsing command arguments correctly
- Validating inputs and prerequisites
- Loading minimal context (routing-guide.md, validation-rules.md)
- Routing to appropriate subagents
- Managing delegation safety (cycles, timeouts, session tracking)
- Validating subagent returns
- Relaying results to users

**Key Insight**: The Orchestrator protects its context window by delegating all substantive work to specialized subagents.

### 2. Context Window Protection

The system employs multiple strategies to minimize context usage:

#### Lazy Context Loading
- Load only required context files for each stage
- Use context index for fast lookups
- Avoid loading full artifact content into context

#### Metadata Passing
- Subagents return artifact links + brief summaries (NOT full content)
- Orchestrator reads metadata only, not file content
- Summary artifacts (<100 tokens) for multi-file outputs

#### Frontmatter Delegation
- Commands specify target agents in frontmatter
- Orchestrator reads command frontmatter, not full command logic
- Subagents own workflow execution logic

### 3. Standardized Pre-Flight and Post-Flight Sequences

All commands follow a consistent lifecycle pattern:

#### Pre-Flight (Orchestrator Stages 1-3)
1. **PreflightValidation**: Parse arguments, validate task exists, check prerequisites
2. **DetermineRouting**: Extract language, map to agent using routing table
3. **RegisterAndDelegate**: Create session, format prompt, invoke subagent

#### Execution (Subagent)
- Subagent executes workflow-specific logic
- Creates artifacts following artifact-management.md standards
- Returns metadata (artifact links + summaries), NOT full content

#### Post-Flight (Orchestrator Stages 4-5)
4. **ValidateReturn**: Verify JSON structure, check artifacts exist and are non-empty
5. **PostflightCleanup**: Update session registry, relay result to user

### 4. Language-Based Routing

Tasks are automatically routed to specialized agents based on language. The `/research`, `/plan`, `/revise`, and `/implement` commands all use language-based routing to invoke the appropriate specialized agents.

**Routing Table**:

| Language | Research Agent | Planning Agent | Implementation Agent |
|----------|----------------|----------------|---------------------|
| lean | lean-research-agent | lean-planner | lean-implementation-agent |
| markdown | researcher | planner | implementer |
| python | researcher | planner | implementer |
| general | researcher | planner | implementer |

**Note**: The routing table is extensible. Future enhancements may include language-specific agents for Python, TypeScript, or other languages. Each language can have specialized agents for research, planning/revision, and implementation phases.

**Language Extraction Priority**:
1. Project state.json (`language` field)
2. TODO.md task entry (`**Language**` field)
3. Default to "general" if not found

**Commands Using Language-Based Routing**:
- `/research NNN` - Routes to Research Agent based on task language
- `/plan NNN` - Routes to Planning Agent based on task language
- `/revise NNN` - Routes to Planning Agent based on task language (same as /plan)
- `/implement NNN` - Routes to Implementation Agent based on task language

### 5. Atomic State Updates

Status updates across multiple files (TODO.md, state.json, project state.json) are performed atomically using the `status-sync-manager` subagent with two-phase commit:

**Phase 1 (Prepare)**:
- Read all files into memory
- Validate status transitions
- Prepare all updates
- Abort if any validation fails

**Phase 2 (Commit)**:
- Write files in dependency order
- Verify each write
- Rollback on any failure
- Guarantee: all files updated or none updated

---

## Component Overview

### Orchestrator Agent

**File**: `.opencode/agent/orchestrator.md`

**Responsibilities**:
- Command routing and validation
- Argument parsing and normalization
- Language-based agent selection
- Delegation safety (cycle detection, timeout enforcement)
- Return validation
- Session tracking

**Context Loading**: Minimal (routing-guide.md, validation-rules.md, command frontmatter only)

**Performance**: 60-70% context reduction vs loading full command logic

### Commands

Commands define the user interface and specify routing behavior via frontmatter:

**Example: /research command**
```yaml
---
name: research
agent: orchestrator
description: "Conduct research and create reports"
routing:
  language_based: true
  lean: lean-research-agent
  markdown: researcher
  python: researcher
  default: researcher
context_loading:
  strategy: lazy
  required:
    - "core/standards/delegation.md"
    - "core/system/state-management.md"
---
```

**Example: /plan command**
```yaml
---
name: plan
agent: orchestrator
description: "Create implementation plans"
routing:
  language_based: true
  lean: lean-planner
  markdown: planner
  python: planner
  default: planner
context_loading:
  strategy: lazy
  required:
    - "core/standards/delegation.md"
    - "core/system/state-management.md"
---
```

**Key Commands**:

#### `/research NNN [DESCRIPTION]`
- **Purpose**: Conduct research, create reports, update status to [RESEARCHED]
- **Arguments**: Mandatory task number, optional description
- **Routing**: Language-based (lean-research-agent or researcher)
- **Artifacts**: Research reports in `reports/research-NNN.md`
- **Status Transition**: [NOT STARTED] → [RESEARCHING] → [RESEARCHED]

#### `/plan NNN [DESCRIPTION]`
- **Purpose**: Create implementation plans based on research
- **Arguments**: Mandatory task number, optional description
- **Routing**: Language-based (lean-planner or planner)
- **Artifacts**: Implementation plans in `plans/implementation-NNN.md`
- **Status Transition**: [RESEARCHED] → [PLANNING] → [PLANNED]

#### `/revise NNN DESCRIPTION`
- **Purpose**: Revise existing plans with new requirements
- **Arguments**: Mandatory task number AND description
- **Routing**: Language-based (lean-planner or planner, same routing as /plan)
- **Artifacts**: Revised plans (increments version number)
- **Status Transition**: [PLANNED] → [REVISING] → [REVISED]

#### `/implement NNN [DESCRIPTION]`
- **Purpose**: Execute implementation following plan
- **Arguments**: Mandatory task number, optional description
- **Routing**: Language-based (lean-implementation-agent or implementer)
- **Artifacts**: Implementation files + implementation summary
- **Status Transition**: [PLANNED] → [IMPLEMENTING] → [COMPLETED]

#### `/task DESCRIPTION`
- **Purpose**: Create new task in TODO.md and state.json
- **Arguments**: Mandatory description
- **Routing**: Direct to task-executor
- **Behavior**: 
  - Looks up `next_project_number` in state.json
  - Creates task in TODO.md with proper metadata
  - Updates state.json with new task entry
  - Does NOT create project directory (lazy creation on research/plan)

#### `/review`
- **Purpose**: Comprehensive codebase review
- **Arguments**: None
- **Routing**: Direct to reviewer
- **Behavior**:
  - Reviews entire repository
  - Updates registries (SORRY, TACTIC, FEATURE, IMPLEMENTATION_STATUS)
  - Presents tasks to user for confirmation
  - Creates confirmed tasks in TODO.md and state.json

#### `/todo`
- **Purpose**: Archive completed/abandoned tasks
- **Arguments**: None
- **Routing**: Direct to todo-manager
- **Behavior**:
  - Migrates completed/abandoned tasks to specs/archive/
  - Moves project directories
  - Updates state.json and archive/state.json

#### `/meta PROMPT`
- **Purpose**: Modify or extend the agent system itself
- **Arguments**: Optional prompt (if empty, starts interactive interview)
- **Routing**: Direct to meta agent
- **Behavior**:
  - Accepts prompt directly OR starts interactive interview
  - Creates tasks with linked artifacts (research, plans)
  - Does NOT implement changes (user runs /implement for each task)
  - Uses next_project_number for task numbering

### Subagents

#### Researcher / Lean Research Agent

**Responsibilities**:
- Execute research using appropriate tools (web search or Lean-specific APIs)
- Create comprehensive research reports
- Update task status to [RESEARCHED]
- Create git commits for research artifacts

**CRITICAL CONSTRAINT**: The researcher agent must ONLY conduct research and create research artifacts. It must NOT implement tasks or change status to [COMPLETED]. This separation is essential for workflow integrity.

**Artifact Pattern**: Single research report (no summary artifact needed)

**Return Format**:
```json
{
  "status": "completed",
  "task_number": 258,
  "artifacts": [
    {
      "type": "research_report",
      "path": ".opencode/specs/258_*/reports/research-001.md",
      "summary": "Research found 3 sorries in Truth.lean already resolved in Task 213..."
    }
  ],
  "summary": "Research completed. All sorries already resolved. Task is obsolete."
}
```

#### Planner / Lean Planner

**Responsibilities**:
- Harvest linked research artifacts from TODO.md
- Create implementation plans with phases, estimates, complexity
- Include research inputs section in plan
- Update task status to [PLANNED]
- Handle plan revisions (via /revise command)

**Language-Specific Variants**:
- **planner**: General planning agent for markdown, python, and general tasks
- **lean-planner**: Lean 4-specific planning agent with knowledge of Lean proof strategies, tactic patterns, and mathlib integration

**Research Integration**: Plans must cite linked research artifacts or explicitly state none linked.

**Artifact Pattern**: Single plan (self-documenting, no summary needed)

#### Implementer / Lean Implementation Agent

**Responsibilities**:
- Execute implementation following plan
- Create implementation files
- Create implementation summary for multi-file outputs
- Update task status to [COMPLETED]
- Create git commits

**Artifact Pattern**: N implementation files + 1 summary artifact

**Return Format**:
```json
{
  "status": "completed",
  "task_number": 267,
  "artifacts": [
    {
      "type": "implementation_file",
      "path": "path/to/file1.md",
      "summary": "Moved interview-patterns.md to core/workflows/"
    },
    {
      "type": "implementation_summary",
      "path": ".opencode/specs/267_*/summaries/implementation-summary-20260103.md",
      "summary": "Integration completed. 4 files moved, all references updated."
    }
  ],
  "summary": "Integration completed successfully."
}
```

#### Status Sync Manager

**Responsibilities**:
- Atomic multi-file status updates
- Two-phase commit protocol
- Rollback on failure
- Consistency guarantees

**Usage**:
```
status_sync_manager.mark_researched(task_number, timestamp, artifact_path)
status_sync_manager.mark_planned(task_number, timestamp, plan_path)
status_sync_manager.mark_completed(task_number, timestamp)
```

#### Git Workflow Manager

**Responsibilities**:
- Create standardized git commits
- Auto-generated commit messages
- Pre-commit hook handling
- Commit history tracking

---

## Command System

### Argument Parsing Standard

All commands follow the standard defined in `.opencode/context/core/standards/command-argument-handling.md`:

#### Task-Based Commands (research, plan, implement, revise)

**OpenCode provides**: `$ARGUMENTS` variable (raw user input)

**Orchestrator Stage 1 (PreflightValidation)**:
1. Parse task number from `$ARGUMENTS`
2. Validate task number is integer
3. Validate task exists in TODO.md
4. Store `task_number` in delegation context

**Orchestrator Stage 3 (RegisterAndDelegate)**:
1. Format prompt as: `"Task: {task_number}"`
2. Pass formatted prompt to subagent
3. Example: `/research 258` → prompt = `"Task: 258"`

**Subagent receives**: `"Task: 258"` (NOT raw `$ARGUMENTS`)

#### Direct Commands (meta, review, todo)

**OpenCode provides**: `$ARGUMENTS` variable (may be empty)

**Orchestrator Stage 1**:
1. Pass `$ARGUMENTS` as-is (no parsing needed)

**Orchestrator Stage 3**:
1. Pass `$ARGUMENTS` directly to subagent
2. Example: `/meta "build proof system"` → prompt = `"build proof system"`
3. Example: `/review` → prompt = `""`

**Subagent receives**: Raw `$ARGUMENTS` (can be empty string)

### Command Frontmatter Pattern

Commands use YAML frontmatter to specify routing and context requirements:

```yaml
---
name: research
agent: orchestrator                # Always orchestrator
routing:
  language_based: true             # Enable language routing
  lean: lean-research-agent        # Lean tasks route here
  default: researcher              # Non-Lean tasks route here
context_loading:
  strategy: lazy                   # Lazy load context
  required:                        # Required context files
    - "core/standards/delegation.md"
    - "core/system/state-management.md"
---
```

### Command Lifecycle

```
┌─────────────────────────────────────────────────────────────────┐
│ Stage 1: PreflightValidation (Orchestrator)                     │
│ - Parse $ARGUMENTS variable                                     │
│ - Validate task exists in TODO.md                               │
│ - Load command frontmatter                                      │
│ - Prepare delegation context                                    │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Stage 2: DetermineRouting (Orchestrator)                        │
│ - Extract language from state.json or TODO.md                   │
│ - Map language to agent using routing table                     │
│ - Validate routing decision                                     │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Stage 3: RegisterAndDelegate (Orchestrator)                     │
│ - Register session in registry                                  │
│ - Format prompt: "Task: {task_number}" for task-based commands  │
│ - Invoke subagent with formatted prompt                         │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Subagent Execution                                              │
│ - Parse "Task: NNN" format                                      │
│ - Execute workflow-specific logic                               │
│ - Create artifacts (lazy directory creation)                    │
│ - Update status via status-sync-manager                         │
│ - Create git commits via git-workflow-manager                   │
│ - Return metadata (artifact links + summaries)                  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Stage 4: ValidateReturn (Orchestrator)                          │
│ - Validate JSON structure                                       │
│ - Verify required fields present                                │
│ - Check artifacts exist on disk                                 │
│ - Verify artifacts are non-empty (prevents phantom research)    │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Stage 5: PostflightCleanup (Orchestrator)                       │
│ - Update session registry                                       │
│ - Relay result to user                                          │
└─────────────────────────────────────────────────────────────────┘
```

---

## Agent System

### Orchestrator Design

The Orchestrator follows a **minimal context, maximum delegation** pattern:

**Context Loading**: Only 3-5 small files
- routing-guide.md (routing logic)
- validation-rules.md (return validation)
- command-argument-handling.md (argument parsing)
- Command frontmatter (target agent, routing table)

**NOT Loaded**:
- Full command logic (delegated to subagents)
- Workflow execution details (owned by subagents)
- Domain-specific knowledge (passed to subagents as needed)

**Result**: 60-70% context reduction vs loading full command files

### Subagent Design

Subagents own workflow execution logic and domain expertise:

**YAML Frontmatter**:
```yaml
---
name: researcher
type: specialist
description: "Conducts research and creates reports"
mode: autonomous
temperature: 0.2
tools:
  read: true
  write: true
  bash: true
  webfetch: true
context_loading:
  strategy: lazy
  required:
    - "core/standards/research-quality.md"
    - "core/system/artifact-management.md"
---
```

**XML Workflow Structure**:
```xml
<workflow_execution>
  <stage id="1" name="ParseTask">
    <action>Parse "Task: NNN" format and extract task number</action>
    <process>
      1. Validate prompt format
      2. Extract task number
      3. Validate task exists in TODO.md
    </process>
    <checkpoint>Task number extracted and validated</checkpoint>
  </stage>

  <stage id="2" name="ExecuteResearch">
    <action>Conduct research using appropriate tools</action>
    ...
  </stage>

  <stage id="3" name="CreateArtifacts">
    <action>Create research report with lazy directory creation</action>
    ...
  </stage>

  <stage id="4" name="UpdateStatus">
    <action>Update status to [RESEARCHED] via status-sync-manager</action>
    ...
  </stage>
</workflow_execution>
```

### Return Format Standard

All subagents must return JSON with this structure:

```json
{
  "status": "completed" | "failed" | "partial",
  "task_number": 258,
  "artifacts": [
    {
      "type": "research_report" | "implementation_plan" | "implementation_file" | "summary",
      "path": ".opencode/specs/258_*/reports/research-001.md",
      "summary": "Brief 1-2 sentence summary of artifact content"
    }
  ],
  "summary": "3-5 sentence overall summary of work completed",
  "validated_artifacts": true,
  "session_id": "sess_20260103_abc123"
}
```

**CRITICAL**: Return artifact metadata (paths + summaries), NOT full artifact content.

---

## Workflow Patterns

### Research Workflow

```
/research 258
     ↓
Orchestrator Stage 1: Parse arguments, validate task 258 exists
     ↓
Orchestrator Stage 2: Extract language from TODO.md → "lean"
     ↓
Orchestrator Stage 3: Route to lean-research-agent with "Task: 258"
     ↓
Lean Research Agent:
  - Extract task number from "Task: 258"
  - Update status: [NOT STARTED] → [RESEARCHING]
  - Execute research using LeanExplore, Loogle, LeanSearch
  - Create project directory: .opencode/specs/258_resolve_truth_lean_sorries/
  - Create reports/ subdirectory (lazy)
  - Write report: reports/research-001.md
  - Update status: [RESEARCHING] → [RESEARCHED] (atomic via status-sync-manager)
  - Create git commit
  - Return metadata (artifact path + summary)
     ↓
Orchestrator Stage 4: Validate return, verify artifacts exist
     ↓
Orchestrator Stage 5: Relay result to user
```

### Plan Workflow

```
/plan 258
     ↓
Orchestrator: Route to planner with "Task: 258"
     ↓
Planner:
  - Extract task number from "Task: 258"
  - Read TODO.md to find linked research artifacts
  - Update status: [RESEARCHED] → [PLANNING]
  - Create plan with research inputs section
  - Create project directory if needed
  - Create plans/ subdirectory (lazy)
  - Write plan: plans/implementation-001.md
  - Update status: [PLANNING] → [PLANNED] (atomic)
  - Create git commit
  - Return metadata
     ↓
Orchestrator: Validate and relay
```

### Implement Workflow

```
/implement 258
     ↓
Orchestrator: Route to lean-implementation-agent with "Task: 258"
     ↓
Lean Implementation Agent:
  - Extract task number
  - Read plan from TODO.md link
  - Update status: [PLANNED] → [IMPLEMENTING]
  - Execute implementation following plan phases
  - Create implementation files
  - Create summaries/ subdirectory (lazy)
  - Write summary: summaries/implementation-summary-20260103.md
  - Update status: [IMPLEMENTING] → [COMPLETED] (atomic)
  - Create git commit
  - Return metadata (files + summary)
     ↓
Orchestrator: Validate and relay
```

### Review Workflow

```
/review
     ↓
Orchestrator: Route to reviewer with ""
     ↓
Reviewer:
  - Analyze entire codebase
  - Update registries (SORRY, TACTIC, FEATURE, IMPLEMENTATION_STATUS)
  - Identify follow-up tasks
  - Present tasks to user for confirmation
  - Create confirmed tasks in TODO.md using next_project_number
  - Update state.json with new tasks
  - Create review summary artifact
  - Return metadata
     ↓
Orchestrator: Relay to user
```

### Task Creation Workflow

```
/task "Fix context directory structure"
     ↓
Orchestrator: Route to task-executor with full description
     ↓
Task Executor:
  - Parse description
  - Look up next_project_number in state.json
  - Create task in TODO.md with proper format:
    - Task number from next_project_number
    - Status: [NOT STARTED]
    - Priority, Language, Dependencies
  - Update state.json:
    - Add task to active_projects
    - Increment next_project_number
  - Do NOT create project directory (lazy creation on research/plan)
  - Return metadata
     ↓
Orchestrator: Relay to user
```

### Meta Workflow

```
/meta "Revise /meta command to accept prompts"
     ↓
Orchestrator: Route to meta agent with full prompt
     ↓
Meta Agent:
  - Check if prompt provided (non-empty)
  - If prompt: Use as target_domain, skip interactive interview
  - If no prompt: Start interactive interview
  - Conduct research on current system
  - Identify needed changes
  - Create tasks in TODO.md using next_project_number:
    - Research task (if needed)
    - Plan task (if needed)
    - Implementation task(s)
  - Link research/plan artifacts to tasks
  - Do NOT implement changes (user runs /implement for each task)
  - Return metadata with created task numbers
     ↓
Orchestrator: Relay to user
```

---

## Context Management

### Context Loading Strategy

The system uses **lazy loading** with a **context index** for fast lookups:

**Context Index**: `.opencode/context/index.md`
- Maps context categories to file paths
- Enables quick lookup without scanning directories
- Updated when context files added/removed

**Lazy Loading**:
```yaml
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/standards/delegation.md"
    - "core/system/state-management.md"
  optional:
    - "project/lean4/tools/leansearch-api.md"
  max_context_size: 50000
```

**Loading Process**:
1. Agent starts with minimal context (frontmatter only)
2. Load required context files from index
3. Load optional files if under max_context_size
4. Execute workflow stages
5. Load additional context as needed (lazy)

### Context Organization

```
context/
├── core/                          # General context (all projects)
│   ├── standards/                 # Quality standards
│   │   ├── delegation.md
│   │   ├── plan.md
│   │   ├── report.md
│   │   └── tasks.md
│   ├── system/                    # System specifications
│   │   ├── artifact-management.md
│   │   ├── routing-guide.md
│   │   ├── state-management.md
│   │   └── validation-rules.md
│   ├── templates/                 # Reusable templates
│   │   ├── agent-templates.md
│   │   ├── command-template.md
│   │   └── subagent-template.md
│   └── workflows/                 # Workflow definitions
│       ├── command-lifecycle.md
│       ├── delegation-guide.md
│       └── interview-patterns.md
└── project/                       # Project-specific context
    └── lean4/                     # Lean 4 specific
        ├── tools/
        │   ├── leansearch-api.md
        │   ├── loogle-api.md
        │   └── lean-lsp-mcp.md
        └── standards/
            └── lean-style-guide.md
```

### Context File Standards

**Size**: 50-200 lines per file (modular, focused)

**Format**:
```markdown
# Title

**Purpose**: Clear statement of file purpose

## Section 1

Content...

## Section 2

Content...
```

**NO EMOJIS**: Per documentation.md standards, no emojis in any files

---

## State Management

### State File Locations

```
.opencode/specs/
├── state.json                     # Global state (next_project_number, active/completed tasks)
├── TODO.md                        # User-facing task list
├── archive/
│   └── state.json                 # Archived projects
├── maintenance/
│   └── state.json                 # Maintenance tracking
└── NNN_project_name/              # Project directories
    ├── reports/
    ├── plans/
    ├── summaries/
    └── state.json                 # Project-specific state (optional)
```

### Global State Schema

**File**: `.opencode/specs/state.json`

```json
{
  "_schema_version": "1.1.0",
  "_last_updated": "2026-01-03T18:18:35Z",
  "next_project_number": 271,
  "project_numbering": {
    "min": 0,
    "max": 999,
    "policy": "increment_modulo_1000"
  },
  "active_projects": [
    {
      "project_number": 258,
      "project_name": "resolve_truth_lean_sorries",
      "type": "research",
      "phase": "researched",
      "status": "researched",
      "priority": "medium",
      "language": "lean",
      "created_at": "2026-01-03T10:00:00Z",
      "updated_at": "2026-01-03T10:30:00Z",
      "artifacts": [
        ".opencode/specs/258_resolve_truth_lean_sorries/reports/research-001.md"
      ]
    }
  ],
  "completed_projects": [...],
  "repository_health": {
    "last_assessed": "2025-12-29T00:05:34Z",
    "overall_score": 92,
    "sorry_count": 6,
    "axiom_count": 11
  }
}
```

**Key Fields**:
- `next_project_number`: Auto-increments for new tasks
- `language`: Used for routing (lean, markdown, python, general)
- `artifacts`: Tracks all created artifacts

### TODO.md Format

**File**: `.opencode/specs/TODO.md`

```markdown
### 258. Resolve Truth.lean Sorries
- **Effort**: 10-20 hours
- **Status**: [RESEARCHED]
- **Started**: 2026-01-03
- **Completed**: 2026-01-03
- **Priority**: Medium
- **Language**: lean
- **Research Artifacts**:
  - Main Report: .opencode/specs/258_resolve_truth_lean_sorries/reports/research-001.md
  - Summary: .opencode/specs/258_resolve_truth_lean_sorries/summaries/research-summary.md

**Description**: Resolve 3 remaining sorry placeholders in Truth.lean...
```

### Status Transitions

```
[NOT STARTED] → [RESEARCHING] → [RESEARCHED] → [PLANNING] → [PLANNED] → [IMPLEMENTING] → [COMPLETED]
                      ↓                            ↓            ↓            ↓
                 [BLOCKED]                    [REVISING]    [PARTIAL]    [BLOCKED]
                      ↓                            ↓                         ↓
                 [ABANDONED]                  [REVISED] ────────────────────→
```

**Status Sync Manager** ensures atomic updates across:
- TODO.md (status marker, timestamps, artifact links)
- state.json (status, timestamps, artifact paths)
- Project state.json (if exists)

---

## Delegation Model

### Delegation Safety

The Orchestrator enforces delegation safety with:

1. **Cycle Detection**: Prevent circular delegation chains
2. **Depth Limits**: Maximum delegation depth of 3
3. **Timeout Enforcement**: Each delegation has timeout deadline
4. **Session Tracking**: Unique session IDs for all delegations

### Session Format

```json
{
  "session_id": "sess_20260103_abc123",
  "command": "research",
  "subagent": "lean-research-agent",
  "start_time": "2026-01-03T18:00:00Z",
  "timeout": 3600,
  "deadline": "2026-01-03T19:00:00Z",
  "status": "running",
  "delegation_depth": 1,
  "delegation_path": ["orchestrator", "research", "lean-research-agent"]
}
```

### Delegation Context

When delegating, the Orchestrator passes:

```json
{
  "session_id": "sess_20260103_abc123",
  "delegation_depth": 1,
  "delegation_path": ["orchestrator", "research", "lean-research-agent"],
  "timeout": 3600,
  "max_depth": 3,
  "parent_session": null
}
```

**Subagents receive**:
- Formatted prompt: `"Task: 258"` (NOT raw `$ARGUMENTS`)
- Delegation context (session tracking)
- Timeout deadline

**Subagents return**:
- Status (completed, failed, partial)
- Artifacts array (metadata only)
- Summary (brief description)
- Session ID (for validation)

---

## Best Practices

### For Commands

1. **Specify routing in frontmatter**: Use `routing.language_based: true` for language routing
2. **Load minimal context**: Only load required standards/workflows
3. **Delegate execution**: Commands specify what to do, subagents do the work
4. **Validate arguments**: Always validate task numbers exist before delegating

### For Subagents

1. **Parse prompt format**: Expect `"Task: NNN"` format from task-based commands
2. **Use lazy directory creation**: Create project dirs only when writing first artifact
3. **Return metadata, not content**: Return artifact paths + summaries (< 100 tokens)
4. **Validate artifacts**: Ensure files exist and are non-empty before returning
5. **Use status-sync-manager**: Always use atomic updates for status changes
6. **Follow NO EMOJI standard**: No emojis in any artifacts or communication

### For Artifact Management

1. **Lazy directory creation**: 
   - Create project root ONLY when writing first artifact
   - Create subdirectories (reports/, plans/, summaries/) ONLY when writing to them
   - NEVER pre-create directories or placeholder files

2. **Artifact patterns**:
   - Research: 1 report (no summary needed)
   - Plan: 1 plan (self-documenting, no summary needed)
   - Implementation: N files + 1 summary (required for multi-file)

3. **Summary artifacts**:
   - Create ONLY for multi-file outputs
   - Keep under 100 tokens (~400 characters)
   - Do NOT duplicate content from detailed artifacts

### For Context Management

1. **Use context index**: Always load from index for fast lookups
2. **Specify required vs optional**: Mark required context in frontmatter
3. **Respect max_context_size**: Stay under limits to protect context window
4. **Keep files modular**: 50-200 lines per file, single responsibility

### For State Management

1. **Use atomic updates**: Always use status-sync-manager for multi-file updates
2. **Follow status transitions**: Validate transitions before updating
3. **Include timestamps**: All status changes require timestamps
4. **Track artifacts**: Update artifact arrays when creating new artifacts

---

## Comparison with OpenAgents

### Similarities

Both systems follow similar architectural patterns:

1. **Orchestrator-Subagent Pattern**: Main orchestrator routes to specialized subagents
2. **Frontmatter Delegation**: Commands specify target agents in frontmatter
3. **Context Window Protection**: Minimize context through lazy loading and metadata passing
4. **XML-Optimized Agents**: Use XML structure for workflows and context
5. **Session Tracking**: Track delegations with session IDs and depth limits

### Key Differences

| Aspect | ProofChecker | OpenAgents |
|--------|--------------|-----------|
| **Primary Domain** | Lean 4 formal verification | General software development |
| **Language Routing** | Automatic routing based on task language | Manual agent selection |
| **Specialized Agents** | lean-research-agent, lean-planner, lean-implementation-agent | Lean-specific orchestrator |
| **Tool Integration** | LeanExplore, Loogle, LeanSearch, lean-lsp-mcp | Standard dev tools |
| **State Management** | TODO.md + state.json + project state.json | specs/TODO.md + specs/state.json |
| **Project Directories** | Optional project state.json | Not used |
| **Status Markers** | Command-specific ([RESEARCHING], [PLANNED]) | Standard only |
| **Meta Command** | Creates tasks (no implementation) | Full system generation |

### Architectural Insights from OpenAgents

The OpenAgents system demonstrates several patterns that influenced ProofChecker:

1. **Minimal Orchestrator**: OpenAgents orchestrator loads only routing-guide.md, achieving maximum context efficiency

2. **Frontmatter-Based Routing**: Commands use frontmatter to specify target agents, eliminating need for complex routing logic in orchestrator

3. **Lazy Context Loading**: Context index enables fast lookup without scanning directories

4. **Session-Based Temporary Context**: Temporary context for sessions (not implemented in ProofChecker yet)

5. **Meta System Builder**: Interactive interview process for creating complete agent systems (adapted in ProofChecker /meta)

### ProofChecker Innovations

ProofChecker extends OpenAgents patterns with:

1. **Language-Based Routing**: Automatic routing to specialized agents based on task language

2. **Atomic Status Updates**: Two-phase commit via status-sync-manager ensures consistency

3. **Command-Specific Status Markers**: Fine-grained status tracking ([RESEARCHING], [PLANNING], [IMPLEMENTING])

4. **Artifact Validation**: Prevents "phantom research" by verifying artifacts exist and are non-empty

5. **Task-Based Argument Parsing**: Standardized `"Task: NNN"` format for consistency across commands

---

## Future Enhancements

### Planned Improvements

1. **Session-Based Temporary Context**: Following OpenAgents pattern for temporary context
2. **Context Consolidation**: Merge common/ and core/ directories (task 265)
3. **Improved /meta Command**: Accept prompts directly without interactive interview (task 269)
4. **Enhanced Argument Parsing**: Better handling of optional flags and parameters (task 268)
5. **Proof-Specific Workflows**: Specialized workflows for Lean proof development

### Migration Path

The system is designed for incremental migration to the OpenAgents architecture:

**Phase 1** (Completed): Context index and frontmatter delegation  
**Phase 2** (Completed): Migrate commands to frontmatter pattern  
**Phase 3** (Partial): Context consolidation and cleanup  
**Phase 4** (Planned): Testing and validation infrastructure  

See task 240 research for detailed migration analysis.

---

## Conclusion

The ProofChecker .opencode system implements a hierarchical orchestrator-subagent architecture optimized for Lean 4 formal verification workflows. By following the core principles of minimal context loading, atomic state updates, language-based routing, and standardized pre/post-flight sequences, the system achieves:

- **60-70% context reduction** through lazy loading and metadata passing
- **Atomic consistency** across multiple state files via two-phase commit
- **Specialized tool integration** for Lean 4 development
- **Clear workflow separation** between research, planning, and implementation
- **Production-ready reliability** through validation and safety checks

The architecture draws heavily from OpenAgents patterns while introducing innovations specific to formal verification, particularly language-based routing and Lean-specific tool integration.

For detailed implementation specifications, refer to:
- Command Lifecycle: `.opencode/context/core/workflows/command-lifecycle.md`
- State Management: `.opencode/context/core/system/state-management.md`
- Artifact Management: `.opencode/context/core/system/artifact-management.md`
- Routing Logic: `.opencode/context/core/system/routing-logic.md`
