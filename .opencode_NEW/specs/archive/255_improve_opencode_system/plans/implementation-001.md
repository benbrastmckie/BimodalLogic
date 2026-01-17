# ProofChecker .opencode System Improvement Plan

**Version**: 1.0  
**Created**: 2025-12-29  
**Status**: Ready for Manual Execution  
**Estimated Total Effort**: 8-12 hours

---

## Overview

This plan restructures the ProofChecker .opencode system to implement:
1. Clean `core/` and `project/` context organization
2. Streamlined orchestrator (smart coordinator pattern)
3. Thin command files (declarative workflow setup)
4. Language-based routing via orchestrator
5. Clear validation strategy

**Important**: `specs/` remains unchanged. All tasks, TODO.md, state.json, and project directories stay exactly as they are.

---

## Table of Contents

1. [Phase 1: Context Directory Reorganization](#phase-1-context-directory-reorganization)
2. [Phase 2: Orchestrator Streamlining](#phase-2-orchestrator-streamlining)
3. [Phase 3: Command File Simplification](#phase-3-command-file-simplification)
4. [Phase 4: Documentation Updates](#phase-4-documentation-updates)
5. [Final Verification](#final-verification)
6. [Rollback Plan](#rollback-plan)
7. [Success Criteria](#success-criteria)

---

## Phase 1: Context Directory Reorganization

**Goal**: Restructure `.opencode/context/` into clean `core/` and `project/` hierarchy  
**Effort**: 2-3 hours  
**Risk**: Medium (many file moves, many reference updates)

### Step 1.1: Create New Directory Structure

```bash
cd /home/benjamin/Projects/ProofChecker/.opencode/context

# Create core/ subdirectories
mkdir -p core/standards
mkdir -p core/workflows
mkdir -p core/system
mkdir -p core/templates

# Project structure already exists, just verify
ls -la project/
```

**Expected Result**: New `core/` directory with 4 subdirectories

---

### Step 1.2: Create New Core Files

Create the following new files in `context/core/`:

#### File 1: `core/system/context-loading-strategy.md`

```markdown
# Context Loading Strategy

## Three-Tier Loading

### Tier 1: Orchestrator (Minimal)
**Budget**: <5% of context window (~10KB)

**Always Loaded**:
- core/system/routing-guide.md (routing rules, language mapping)
- core/workflows/delegation-guide.md (safety patterns)

**Purpose**: Enable routing decisions and delegation safety checks

### Tier 2: Commands (Targeted)
**Budget**: 10-20% of context window (~20-40KB)

**Loaded by Command**:
- core/standards/subagent-return-format.md (validate returns)
- core/workflows/status-transitions.md (status markers)
- Command-specific standards (e.g., plan-template.md for /plan)

**Purpose**: Enable command-specific validation and formatting

### Tier 3: Agents (Domain-Specific)
**Budget**: 60-80% of context window (~120-160KB)

**Loaded by Agent**:
- project/lean4/* (for lean-implementation-agent)
- project/logic/* (for logic-specific tasks)
- core/templates/* (for artifact generation)

**Purpose**: Enable domain-specific work with full context

## Loading Mechanism

Commands specify context in frontmatter:
```yaml
context_loading:
  strategy: lazy  # or eager
  required:
    - "core/standards/subagent-return-format.md"
  optional:
    - "core/standards/plan-template.md"
  max_context_size: 50000
```

Agents specify context in frontmatter:
```yaml
context_loading:
  strategy: lazy
  required:
    - "project/lean4/domain/lean4-syntax.md"
    - "project/lean4/tools/lsp-integration.md"
  optional:
    - "project/lean4/patterns/tactic-patterns.md"
  max_context_size: 150000
```

## Context Budget Enforcement

- Orchestrator: Enforce max_context_size from frontmatter
- Log warning if context exceeds budget
- Prioritize required over optional files
- Truncate optional files if needed to stay within budget

## File Organization

### core/standards/
Standard formats and templates that apply across all projects:
- subagent-return-format.md
- plan-template.md
- research-report-format.md
- task-format.md
- git-commit-format.md

### core/workflows/
Common workflow patterns and guides:
- delegation-guide.md
- status-transitions.md
- error-handling-patterns.md
- resume-workflow.md

### core/system/
System-level configuration and guides:
- routing-guide.md
- orchestrator-guide.md
- context-loading-strategy.md (this file)
- validation-strategy.md

### core/templates/
Reusable templates for creating new components:
- command-template.md
- agent-template.md
- context-file-template.md

### project/
Project-specific domain knowledge (ProofChecker):
- lean4/ - Lean 4 theorem proving
- logic/ - Modal and temporal logic
- math/ - Mathematical domains
- physics/ - Physics domains
- repo/ - Repository-specific knowledge
```

#### File 2: `core/system/validation-strategy.md`

```markdown
# Validation Strategy

## Orchestrator Validation Philosophy

The orchestrator validates **structural correctness** and **safety constraints**, not business logic or domain-specific rules.

## High-Value Checks (DO Validate)

### Task Number Validation
**When**: Command requires task_number parameter
**Checks**:
- Task number is integer (regex: `^\d+$`)
- Task exists in TODO.md (grep `^### {number}\.`)
- Extract task status (for status transition validation)
- Extract task language (for routing)

**Cost**: ~50ms (file read + grep)  
**Benefit**: Prevents 80% of user errors  
**Verdict**: ✅ Worth it

### Delegation Safety Checks
**When**: Every delegation
**Checks**:
- delegation_depth ≤ 3
- No cycles in delegation_path (target not in path)
- session_id is unique (not in active registry)

**Cost**: ~5ms (in-memory checks)  
**Benefit**: Prevents infinite loops and hangs  
**Verdict**: ✅ Worth it

### Command Argument Validation
**When**: Parsing command arguments
**Checks**:
- Required arguments present
- Argument types correct (integer, string, etc.)
- Flag syntax valid

**Cost**: ~1ms (string parsing)  
**Benefit**: Clear error messages for user  
**Verdict**: ✅ Worth it

### Return Format Validation
**When**: Receiving subagent return
**Checks**:
- Return is valid JSON
- Required fields present (status, summary, artifacts, metadata, session_id)
- Status is valid enum (completed|partial|failed|blocked)
- session_id matches expected
- Summary <100 tokens

**Cost**: ~10ms (JSON parsing + validation)  
**Benefit**: Ensures consistent return handling  
**Verdict**: ✅ Worth it

## Low-Value Checks (DON'T Validate)

### Business Logic Validation
**Examples**:
- Plan file already exists (let planner check and warn)
- Task has research artifacts (let planner harvest if available)
- Specific file permissions (let agent fail with clear error)

**Rationale**: These are agent-specific concerns, not orchestrator concerns  
**Verdict**: ❌ Skip - Let agents handle

### Deep Validation
**Examples**:
- Plan file format/structure (let planner validate)
- Research report completeness (let researcher validate)
- Implementation correctness (let implementer validate)
- Lean syntax correctness (let lean-implementation-agent validate)

**Rationale**: Orchestrator shouldn't understand domain-specific formats  
**Verdict**: ❌ Skip - Let agents handle

### Artifact Existence (Partial)
**When to check**: Only if status=completed
**When to skip**: If status=partial or failed

**Rationale**: 
- Completed tasks MUST have artifacts (worth validating)
- Partial/failed tasks MAY have artifacts (not worth validating)

**Verdict**: ✅ Validate for completed, ❌ Skip for partial/failed

## Validation Stages

### Stage 2: PreflightValidation
**Validates**:
- Task number (if required)
- Task exists in TODO.md
- Delegation safety (cycles, depth)
- Session ID uniqueness

**Does NOT validate**:
- Business logic (plan exists, etc.)
- File permissions
- Domain-specific rules

### Stage 6: ValidateReturn
**Validates**:
- Return format (JSON schema)
- Required fields present
- session_id matches
- Status enum valid
- Summary token limit
- Artifacts exist (if status=completed)

**Does NOT validate**:
- Artifact content/format
- Business logic correctness
- Domain-specific rules

## Error Handling

### Validation Failures
**Orchestrator validation fails** → Return error immediately, don't delegate

**Agent validation fails** → Agent returns failed status with clear error message

### Error Messages
**Good** (orchestrator): "Task 999 not found in TODO.md"  
**Good** (agent): "Plan already exists at path/to/plan.md. Use /revise to update."

**Bad** (orchestrator): "Plan already exists" (business logic, not orchestrator concern)  
**Bad** (agent): "Invalid task number" (should be caught by orchestrator)

## Summary

| Validation Type | Orchestrator | Agent |
|----------------|--------------|-------|
| Task exists | ✅ | ❌ |
| Task number format | ✅ | ❌ |
| Delegation safety | ✅ | ❌ |
| Return format | ✅ | ❌ |
| Plan exists | ❌ | ✅ |
| Research complete | ❌ | ✅ |
| File permissions | ❌ | ✅ |
| Domain rules | ❌ | ✅ |
| Artifact format | ❌ | ✅ |
```

#### File 3: `core/workflows/delegation-guide.md`

```markdown
# Delegation Guide

## Session ID Tracking

Every delegation has a unique session ID:
```
Format: sess_{timestamp}_{random_6char}
Example: sess_1735460684_a1b2c3
```

Generated by orchestrator in Stage 4 (PrepareContext).

## Delegation Context Structure

```json
{
  "session_id": "sess_1735460684_a1b2c3",
  "delegation_depth": 1,
  "delegation_path": ["orchestrator", "{command}", "{agent}"],
  "timeout": 3600,
  "task_context": {
    "task_number": 244,
    "description": "...",
    "language": "lean"
  }
}
```

## Delegation Depth Limits

```
Level 0: User → Orchestrator
Level 1: Orchestrator → Command → Agent
Level 2: Agent → Utility Agent (status-sync-manager, git-workflow-manager)
Level 3: Utility → Sub-Utility (rare, e.g., atomic-task-numberer)
```

**Maximum depth**: 3 levels  
**Enforcement**: Orchestrator Stage 2 (PreflightValidation)

## Cycle Detection

Before delegating, check if target agent is already in delegation_path.

**Example**:
```
delegation_path: ["orchestrator", "implement", "task-executor"]
target: "task-executor"
Result: ❌ CYCLE DETECTED - Block delegation
```

## Timeout Configuration

| Command | Default Timeout | Max Timeout |
|---------|----------------|-------------|
| /research | 3600s (1 hour) | 7200s (2 hours) |
| /plan | 1800s (30 min) | 3600s (1 hour) |
| /implement | 7200s (2 hours) | 14400s (4 hours) |
| /revise | 1800s (30 min) | 3600s (1 hour) |
| /review | 3600s (1 hour) | 7200s (2 hours) |

## Delegation Registry

Orchestrator maintains in-memory registry:

```json
{
  "sess_1735460684_a1b2c3": {
    "command": "implement",
    "subagent": "task-executor",
    "task_number": 191,
    "start_time": "2025-12-26T10:00:00Z",
    "timeout": 7200,
    "deadline": "2025-12-26T12:00:00Z",
    "status": "running",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "implement", "task-executor"]
  }
}
```

Updated in Stage 4 (PrepareContext) and Stage 7 (PostflightCleanup).

## Safety Guarantees

1. **No Infinite Loops**: Cycle detection prevents A→B→A patterns
2. **No Runaway Depth**: Max depth of 3 prevents deep chains
3. **No Indefinite Waits**: Timeout enforcement with graceful degradation
4. **Session Tracking**: Unique IDs enable debugging and monitoring
```

#### File 4: `core/workflows/status-transitions.md`

```markdown
# Status Transitions

## Status Markers

| Status | Marker | Description |
|--------|--------|-------------|
| Not Started | `[NOT STARTED]` | Task created but not begun |
| Researching | `[RESEARCHING]` | Research in progress |
| Researched | `[RESEARCHED]` | Research completed |
| Planning | `[PLANNING]` | Planning in progress |
| Planned | `[PLANNED]` | Plan created |
| Implementing | `[IMPLEMENTING]` | Implementation in progress |
| Implemented | `[IMPLEMENTED]` | Implementation completed |
| Testing | `[TESTING]` | Testing in progress |
| Completed | `[COMPLETED]` | Task fully completed |
| Blocked | `[BLOCKED]` | Task blocked by dependency |
| Abandoned | `[ABANDONED]` | Task abandoned |

## Valid Transitions

```
[NOT STARTED] → [RESEARCHING] → [RESEARCHED] → [PLANNING] → [PLANNED] → [IMPLEMENTING] → [COMPLETED]
              ↘                ↗              ↘            ↗
                [PLANNING]                      [IMPLEMENTING]
```

**Shortcuts allowed**:
- `[NOT STARTED]` → `[PLANNING]` (skip research)
- `[NOT STARTED]` → `[IMPLEMENTING]` (skip research and planning)
- `[RESEARCHED]` → `[IMPLEMENTING]` (skip planning)

**Any status** → `[BLOCKED]` or `[ABANDONED]`

## Command → Status Mapping

| Command | Start Status | End Status |
|---------|-------------|------------|
| /research | [RESEARCHING] | [RESEARCHED] |
| /plan | [PLANNING] | [PLANNED] |
| /implement | [IMPLEMENTING] | [COMPLETED] |
| /revise | (no change) | (no change) |
| /review | (creates new tasks) | N/A |

## Status Update Delegation

**CRITICAL**: All status updates MUST be delegated to status-sync-manager for atomic synchronization.

**DO NOT** update TODO.md or state.json directly.

```json
{
  "agent": "status-sync-manager",
  "task_number": 244,
  "new_status": "researched",
  "timestamp": "2025-12-29T08:13:37Z",
  "artifacts": [
    "specs/244_phase_1/reports/research-001.md"
  ]
}
```

## Atomic Synchronization

status-sync-manager updates atomically:
1. TODO.md (status marker, timestamps, artifact links)
2. state.json (status field, timestamps, artifact_paths)
3. Project state.json (if exists)
4. Plan file (phase status markers, if plan exists)

**Two-phase commit**: All files updated or all rolled back on failure.
```

#### File 5: `core/standards/subagent-return-format.md`

```markdown
# Subagent Return Format Standard

## Schema

All subagents MUST return this JSON structure:

```json
{
  "status": "completed|partial|failed|blocked",
  "summary": "Brief 2-5 sentence summary (<100 tokens)",
  "artifacts": [
    {
      "type": "plan|report|summary|implementation|documentation",
      "path": "relative/path/to/artifact.md",
      "summary": "Brief description of artifact"
    }
  ],
  "metadata": {
    "session_id": "sess_1735460684_a1b2c3",
    "duration_seconds": 123,
    "agent_type": "planner|researcher|implementer|...",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "plan", "planner"]
  },
  "errors": [
    {
      "type": "validation|execution|timeout|...",
      "message": "Clear error description",
      "recoverable": true|false,
      "recommendation": "How to fix or retry"
    }
  ],
  "next_steps": "What user should do next (if applicable)"
}
```

## Field Specifications

### status (required)
**Type**: enum  
**Values**: `completed`, `partial`, `failed`, `blocked`  
**Description**:
- `completed`: Task fully completed, all artifacts created
- `partial`: Task partially completed, some artifacts created, can resume
- `failed`: Task failed, no usable artifacts, cannot resume
- `blocked`: Task blocked by external dependency, can retry later

### summary (required)
**Type**: string  
**Constraints**: <100 tokens (~400 characters)  
**Description**: Brief 2-5 sentence summary of what was done  
**Purpose**: Protects orchestrator context window from bloat

### artifacts (required)
**Type**: array of objects  
**Can be empty**: Yes (if status=failed or blocked)  
**Description**: List of files created by agent

**Artifact object**:
```json
{
  "type": "plan|report|summary|implementation|documentation",
  "path": "relative/path/from/project/root",
  "summary": "Brief description"
}
```

### metadata (required)
**Type**: object  
**Required fields**:
- `session_id`: Must match expected session_id from delegation
- `agent_type`: Name of agent (planner, researcher, etc.)
- `delegation_depth`: Current depth in delegation chain
- `delegation_path`: Full path from orchestrator to this agent

**Optional fields**:
- `duration_seconds`: How long agent took
- `phase_count`: Number of phases (for plans)
- `estimated_hours`: Effort estimate (for plans)
- `findings_count`: Number of findings (for research)

### errors (optional)
**Type**: array of objects  
**Required if**: status != completed  
**Description**: List of errors encountered

**Error object**:
```json
{
  "type": "validation|execution|timeout|permission|...",
  "message": "Clear, actionable error message",
  "recoverable": true|false,
  "recommendation": "How to fix or what to do next"
}
```

### next_steps (optional)
**Type**: string  
**Description**: What user should do next (e.g., "Run /implement 244")

## Validation Rules

### Orchestrator Validation (Stage 6)

1. **JSON Validity**: Return must be valid JSON
2. **Required Fields**: status, summary, artifacts, metadata must be present
3. **Status Enum**: status must be one of: completed, partial, failed, blocked
4. **Session ID Match**: metadata.session_id must match expected session_id
5. **Summary Length**: summary must be <100 tokens
6. **Artifacts Exist**: If status=completed, all artifact paths must exist on disk

### Validation Failures

If validation fails:
1. Log error to errors.json
2. Return failed status to user
3. Include validation errors in response
4. Recommendation: "Fix {agent} subagent return format"

## Examples

### Completed Plan
```json
{
  "status": "completed",
  "summary": "Created implementation plan for task 244 with 3 phases. Plan focuses on context reorganization, orchestrator streamlining, and command simplification. Estimated effort: 8 hours.",
  "artifacts": [
    {
      "type": "plan",
      "path": "specs/244_context_refactor/plans/implementation-001.md",
      "summary": "3-phase implementation plan"
    }
  ],
  "metadata": {
    "session_id": "sess_1735460684_a1b2c3",
    "duration_seconds": 245,
    "agent_type": "planner",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "plan", "planner"],
    "phase_count": 3,
    "estimated_hours": 8
  },
  "next_steps": "Run /implement 244 to execute the plan"
}
```

### Failed Research
```json
{
  "status": "failed",
  "summary": "Research failed due to network timeout when accessing LeanSearch API. No research artifacts created.",
  "artifacts": [],
  "metadata": {
    "session_id": "sess_1735460684_xyz789",
    "duration_seconds": 30,
    "agent_type": "lean-research-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "research", "lean-research-agent"]
  },
  "errors": [
    {
      "type": "timeout",
      "message": "LeanSearch API request timed out after 30s",
      "recoverable": true,
      "recommendation": "Check network connection and retry with /research 245"
    }
  ],
  "next_steps": "Retry after checking network connection"
}
```

### Partial Implementation
```json
{
  "status": "partial",
  "summary": "Completed phases 1-2 of 3. Phase 3 interrupted due to timeout. Implementation files created for phases 1-2.",
  "artifacts": [
    {
      "type": "implementation",
      "path": "src/module_a.lean",
      "summary": "Phase 1 implementation"
    },
    {
      "type": "implementation",
      "path": "src/module_b.lean",
      "summary": "Phase 2 implementation"
    },
    {
      "type": "summary",
      "path": "specs/246_feature/summaries/implementation-summary.md",
      "summary": "Partial implementation summary"
    }
  ],
  "metadata": {
    "session_id": "sess_1735460684_abc123",
    "duration_seconds": 7200,
    "agent_type": "lean-implementation-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "implement", "lean-implementation-agent"]
  },
  "errors": [
    {
      "type": "timeout",
      "message": "Implementation timed out after 7200s during phase 3",
      "recoverable": true,
      "recommendation": "Resume with /implement 246 to continue from phase 3"
    }
  ],
  "next_steps": "Run /implement 246 to resume from phase 3"
}
```
```

---

### Step 1.3: Move Existing Files

```bash
cd /home/benjamin/Projects/ProofChecker/.opencode/context

# Move system files to core/system/
mv system/orchestrator-guide.md core/system/
mv system/routing-guide.md core/system/

# Remove old system directory
rmdir system/
```

**Expected Result**: 
- `context/system/` removed
- `context/core/system/` contains 4 files (2 moved + 2 new)

---

### Step 1.4: Update Orchestrator Context References

**File**: `.opencode/agent/orchestrator.md`

**Find lines 10-16** (frontmatter context_loading):
```yaml
# OLD
context_loading:
  strategy: minimal
  index: ".opencode/context/index.md"
  required:
    - "core/standards/command-structure.md"
    - "system/routing-guide.md"
  max_context_size: 10000
```

**Replace with**:
```yaml
# NEW
context_loading:
  strategy: minimal
  index: ".opencode/context/index.md"
  required:
    - "core/system/routing-guide.md"
    - "core/workflows/delegation-guide.md"
  max_context_size: 10000
```

**Find lines 586-591** (notes section):
```markdown
# OLD
For detailed workflow documentation, see:
  - `.opencode/context/system/routing-guide.md`
  - `.opencode/context/core/standards/command-structure.md`
  - Individual command files in `.opencode/command/`
  - Individual subagent files in `.opencode/agent/subagents/`
```

**Replace with**:
```markdown
# NEW
For detailed workflow documentation, see:
  - `.opencode/context/core/system/routing-guide.md`
  - `.opencode/context/core/workflows/delegation-guide.md`
  - `.opencode/context/core/system/validation-strategy.md`
  - Individual command files in `.opencode/command/`
  - Individual subagent files in `.opencode/agent/subagents/`
```

---

### Step 1.5: Update Command Context References

Update context_loading in each command file:

#### `/plan` command (`.opencode/command/plan.md`)

**Find lines 6-17**:
```yaml
# OLD
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/standards/subagent-return-format.md"
    - "core/standards/status-markers.md"
    - "system/routing-guide.md"
  optional:
    - "project/processes/planning-workflow.md"
    - "core/standards/plan.md"
  max_context_size: 50000
```

**Replace with**:
```yaml
# NEW
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/standards/subagent-return-format.md"
    - "core/workflows/status-transitions.md"
    - "core/system/routing-guide.md"
  optional:
    - "project/lean4/processes/end-to-end-proof-workflow.md"
  max_context_size: 50000
```

#### `/research` command (`.opencode/command/research.md`)

**Find lines 7-19**:
```yaml
# OLD
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/standards/subagent-return-format.md"
    - "core/standards/status-markers.md"
    - "system/routing-guide.md"
  optional:
    - "project/processes/research-workflow.md"
  max_context_size: 50000
```

**Replace with**:
```yaml
# NEW
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/standards/subagent-return-format.md"
    - "core/workflows/status-transitions.md"
    - "core/system/routing-guide.md"
  optional:
    - "project/lean4/tools/leansearch-api.md"
    - "project/lean4/tools/loogle-api.md"
  max_context_size: 50000
```

#### `/implement` command (`.opencode/command/implement.md`)

**Find lines 10-19**:
```yaml
# OLD
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/standards/subagent-return-format.md"
    - "core/standards/status-markers.md"
    - "system/routing-guide.md"
  optional:
    - "project/processes/implementation-workflow.md"
  max_context_size: 50000
```

**Replace with**:
```yaml
# NEW
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/standards/subagent-return-format.md"
    - "core/workflows/status-transitions.md"
    - "core/system/routing-guide.md"
  optional:
    - "project/lean4/processes/end-to-end-proof-workflow.md"
  max_context_size: 50000
```

**Repeat similar updates for**:
- `/revise` command
- `/review` command
- `/todo` command
- `/task` command
- `/errors` command
- `/meta` command

---

### Step 1.6: Update Context README

**File**: `.opencode/context/README.md`

**Replace entire file content**:

```markdown
# Context Organization

**Version**: 2.0  
**Updated**: 2025-12-29  
**Purpose**: Organize context files for efficient loading and clear separation of concerns

---

## Directory Structure

```
.opencode/context/
├── core/                           # General/reusable context
│   ├── standards/                  # Quality standards, formats
│   │   └── subagent-return-format.md
│   ├── workflows/                  # Common workflow patterns
│   │   ├── delegation-guide.md
│   │   └── status-transitions.md
│   ├── system/                     # System-level guides
│   │   ├── routing-guide.md
│   │   ├── orchestrator-guide.md
│   │   ├── context-loading-strategy.md
│   │   └── validation-strategy.md
│   └── templates/                  # Reusable templates
│       ├── command-template.md
│       └── agent-template.md
│
├── project/                        # ProofChecker-specific context
│   ├── lean4/                      # Lean 4 domain knowledge
│   │   ├── domain/
│   │   ├── patterns/
│   │   ├── processes/
│   │   ├── standards/
│   │   ├── templates/
│   │   └── tools/
│   ├── logic/                      # Logic domain knowledge
│   │   ├── domain/
│   │   ├── processes/
│   │   └── standards/
│   ├── math/                       # Math domain knowledge
│   │   ├── algebra/
│   │   ├── lattice-theory/
│   │   ├── order-theory/
│   │   └── topology/
│   ├── physics/                    # Physics domain knowledge
│   │   └── dynamical-systems/
│   └── repo/                       # Repository-specific
│       ├── project-overview.md
│       └── self-healing-implementation-details.md
│
└── README.md                       # This file
```

---

## Core vs Project

### core/
**Purpose**: General, reusable context applicable to any project

**Contents**:
- Standards (return formats, templates)
- Workflows (delegation, status transitions)
- System guides (routing, orchestrator, validation)
- Templates (for creating new components)

**When to use**: Context that doesn't depend on ProofChecker specifics

### project/
**Purpose**: ProofChecker-specific domain knowledge

**Contents**:
- Lean 4 theorem proving knowledge
- Logic domain knowledge (modal, temporal)
- Math domain knowledge (algebra, topology, etc.)
- Physics domain knowledge
- Repository-specific information

**When to use**: Context specific to ProofChecker's domains

---

## Context Loading Strategy

### Three-Tier Loading

**Tier 1: Orchestrator (Minimal)**
- Budget: <5% context window (~10KB)
- Files: routing-guide.md, delegation-guide.md
- Purpose: Routing and delegation safety

**Tier 2: Commands (Targeted)**
- Budget: 10-20% context window (~20-40KB)
- Files: subagent-return-format.md, status-transitions.md, command-specific
- Purpose: Command validation and formatting

**Tier 3: Agents (Domain-Specific)**
- Budget: 60-80% context window (~120-160KB)
- Files: project/lean4/*, project/logic/*, etc.
- Purpose: Domain-specific work with full context

See `core/system/context-loading-strategy.md` for details.

---

## File Naming Conventions

- Use kebab-case: `subagent-return-format.md`
- Be descriptive: `context-loading-strategy.md` not `loading.md`
- Group by purpose: `delegation-guide.md` in workflows/, not system/

---

## Adding New Context Files

### For General/Reusable Context
Add to `core/`:
- Standards → `core/standards/`
- Workflows → `core/workflows/`
- System guides → `core/system/`
- Templates → `core/templates/`

### For ProofChecker-Specific Context
Add to `project/`:
- Lean 4 → `project/lean4/`
- Logic → `project/logic/`
- Math → `project/math/`
- Physics → `project/physics/`
- Repo-specific → `project/repo/`

---

## Migration from Old Structure

**Old** → **New**:
- `system/routing-guide.md` → `core/system/routing-guide.md`
- `system/orchestrator-guide.md` → `core/system/orchestrator-guide.md`
- All project-specific files remain in `project/`

**Removed**:
- `system/` directory (merged into `core/system/`)

**Added**:
- `core/standards/`
- `core/workflows/`
- `core/templates/`
- `core/system/context-loading-strategy.md`
- `core/system/validation-strategy.md`
```

---

### Step 1.7: Verify Phase 1 Completion

**Checklist**:
- [ ] `context/core/` directory exists with 4 subdirectories
- [ ] `context/system/` directory removed
- [ ] All files moved to new locations
- [ ] New files created (5 new files in core/)
- [ ] Orchestrator frontmatter updated
- [ ] All command frontmatter updated (8 commands)
- [ ] Context README.md updated
- [ ] No broken references (grep for old paths)

**Verification commands**:
```bash
cd /home/benjamin/Projects/ProofChecker/.opencode

# Check structure
ls -la context/core/
ls -la context/core/standards/
ls -la context/core/workflows/
ls -la context/core/system/
ls -la context/core/templates/

# Verify old directory removed
ls context/system/ 2>&1 | grep "No such file"

# Check for old references
grep -r "system/routing-guide" . --include="*.md" | grep -v "core/system"
grep -r "system/orchestrator-guide" . --include="*.md" | grep -v "core/system"

# Should return no results if migration complete
```

---

## Phase 2: Orchestrator Streamlining

**Goal**: Simplify orchestrator to 7 stages with smart coordinator pattern  
**Effort**: 3-4 hours  
**Risk**: High (core routing logic changes)

### Step 2.1: Backup Current Orchestrator

```bash
cd /home/benjamin/Projects/ProofChecker/.opencode/agent
cp orchestrator.md orchestrator.md.backup
```

---

### Step 2.2: Update Orchestrator Frontmatter

**File**: `.opencode/agent/orchestrator.md`

**Find lines 1-23** (entire frontmatter):
```yaml
---
name: orchestrator
version: 4.0
type: router
description: "Lightweight command routing with delegation safety and cycle detection"
mode: primary
temperature: 0.1
max_tokens: 2000
timeout: 60
context_loading:
  strategy: minimal
  index: ".opencode/context/index.md"
  required:
    - "core/standards/command-structure.md"
    - "system/routing-guide.md"
  max_context_size: 10000
delegation:
  max_depth: 3
  timeout_default: 3600
  cycle_detection: true
  session_format: "sess_{timestamp}_{random_6char}"
created: 2025-12-29
---
```

**Replace with**:
```yaml
---
name: orchestrator
version: 5.0
type: router
description: "Smart coordinator with preflight/postflight and language-based routing"
mode: primary
temperature: 0.1
max_tokens: 2000
timeout: 60
context_loading:
  strategy: minimal
  index: ".opencode/context/index.md"
  required:
    - "core/system/routing-guide.md"
    - "core/workflows/delegation-guide.md"
  max_context_size: 10000
delegation:
  max_depth: 3
  timeout_default: 3600
  cycle_detection: true
  session_format: "sess_{timestamp}_{random_6char}"
created: 2025-12-29
updated: 2025-12-29
---
```

---

### Step 2.3: Replace Workflow Execution Section

**File**: `.opencode/agent/orchestrator.md`

**Find lines 53-424** (entire `<workflow_execution>` section)

**Replace with** (see PHASE_2_WORKFLOW_EXECUTION.md for full content - this is a large replacement)

Due to length, the full workflow_execution replacement is provided in a separate section below.

---

### Step 2.4: Update Routing Intelligence Section

**File**: `.opencode/agent/orchestrator.md`

**Find lines 426-450** (`<routing_intelligence>` section)

**Replace with**:
```markdown
<routing_intelligence>
  <command_routing>
    All commands route through orchestrator (agent: orchestrator in frontmatter).
    Orchestrator determines target agent based on command routing configuration.
  </command_routing>
  
  <language_routing>
    Commands with `routing.language_based: true` use language extraction:
    
    1. Extract language:
       - Priority 1: Project state.json (task-specific)
       - Priority 2: TODO.md task entry (task default)
       - Priority 3: Default "general" (fallback)
    
    2. Map language to agent:
       - /research: lean → lean-research-agent, default → researcher
       - /implement: lean → lean-implementation-agent, default → implementer
    
    3. Validate routing:
       - Verify agent file exists
       - Verify language matches agent capabilities
    
    See Stage 3 (DetermineRouting) for detailed logic.
  </language_routing>
  
  <direct_routing>
    Commands with `routing.language_based: false` use direct routing:
    
    - /plan → planner (no language extraction)
    - /revise → reviser (no language extraction)
    - /review → reviewer (no language extraction)
    - /todo → (no delegation, orchestrator handles directly)
    - /task → (no delegation, orchestrator handles directly)
    
    Target agent specified in `routing.target_agent` frontmatter field.
  </direct_routing>
  
  <context_allocation>
    Three-tier loading strategy:
    
    - Tier 1 (Orchestrator): Minimal context for routing decisions
      Budget: <5% context window (~10KB)
      Files: routing-guide.md, delegation-guide.md
    
    - Tier 2 (Commands): Targeted context for validation
      Budget: 10-20% context window (~20-40KB)
      Files: subagent-return-format.md, status-transitions.md
    
    - Tier 3 (Agents): Domain-specific context for work
      Budget: 60-80% context window (~120-160KB)
      Files: project/lean4/*, project/logic/*, etc.
    
    See `.opencode/context/core/system/context-loading-strategy.md` for details.
  </context_allocation>
</routing_intelligence>
```

---

### Step 2.5: Update Notes Section

**File**: `.opencode/agent/orchestrator.md`

**Find lines 578-591** (`<notes>` section)

**Replace with**:
```markdown
<notes>
  - **Smart Coordinator**: Handles preflight validation and postflight cleanup
  - **Language-Based Routing**: Extracts language from project state.json or TODO.md
  - **Delegation Safety**: Cycle detection, depth limits, timeout enforcement
  - **Session Tracking**: Unique session IDs for all delegations
  - **Return Validation**: Validates agent returns against standard format
  - **Minimal Context**: Loads only routing-related context (<5% window)
  - **Agent Ownership**: Agents own their workflows, orchestrator just coordinates
  
  For detailed documentation, see:
  - `.opencode/context/core/system/routing-guide.md` - Routing rules and language mapping
  - `.opencode/context/core/workflows/delegation-guide.md` - Delegation safety patterns
  - `.opencode/context/core/system/validation-strategy.md` - Validation philosophy
  - `.opencode/context/core/standards/subagent-return-format.md` - Return format standard
  - Individual command files in `.opencode/command/` - Command-specific workflows
  - Individual agent files in `.opencode/agent/subagents/` - Agent implementations
</notes>
```

---

### Step 2.6: Verify Phase 2 Completion

**Checklist**:
- [ ] Orchestrator backup created
- [ ] Frontmatter updated (version 5.0, new context paths)
- [ ] Workflow reduced to 7 stages
- [ ] PreflightValidation stage added
- [ ] DetermineRouting stage added with language extraction
- [ ] Routing intelligence section updated
- [ ] Notes section updated
- [ ] File is valid markdown (no syntax errors)

**Verification**:
```bash
# Check orchestrator file size
cd /home/benjamin/Projects/ProofChecker/.opencode/agent
wc -l orchestrator.md  # Should be ~450 lines (down from 592)

# Check for syntax errors (balanced XML tags)
grep -n "^<" orchestrator.md | wc -l  # Count opening tags
grep -n "^</" orchestrator.md | wc -l  # Count closing tags
# Should be equal

# Verify backup exists
ls -la orchestrator.md.backup
```

---

## Phase 3: Command File Simplification

**Goal**: Simplify command files to ~100 lines with declarative workflow setup  
**Effort**: 2-3 hours  
**Risk**: Medium (changes to all command files)

### Step 3.1: Create Command Template

**File**: `.opencode/context/core/templates/command-template.md`

**Create new file** (see full template in separate section below)

---

### Step 3.2: Simplify `/plan` Command

**File**: `.opencode/command/plan.md`

**Current**: 298 lines  
**Target**: ~120 lines

**Replace entire file** (see PHASE_3_PLAN_COMMAND.md for full content)

---

### Step 3.3: Simplify `/research` Command

**File**: `.opencode/command/research.md`

**Current**: 325 lines  
**Target**: ~130 lines

**Replace entire file** (see PHASE_3_RESEARCH_COMMAND.md for full content)

---

### Step 3.4: Simplify `/implement` Command

**File**: `.opencode/command/implement.md`

**Current**: 352 lines  
**Target**: ~140 lines

**Replace entire file** (see PHASE_3_IMPLEMENT_COMMAND.md for full content)

---

### Step 3.5: Simplify Remaining Commands

Apply similar simplification to:

**`/revise` command**:
- Add `routing: { language_based: false, target_agent: reviser }`
- Reduce to ~120 lines
- Use `workflow_setup` pattern

**`/review` command**:
- Add `routing: { language_based: false, target_agent: reviewer }`
- Reduce to ~130 lines (slightly longer due to complexity)
- Use `workflow_setup` pattern

**`/todo` command**:
- Add `routing: { language_based: false }` (no target_agent - orchestrator handles)
- Keep current structure (already fairly simple)

**`/task` command**:
- Add `routing: { language_based: false }` (no target_agent - orchestrator handles)
- Keep current structure (already fairly simple)

**`/errors` command**:
- Add `routing: { language_based: false, target_agent: error-diagnostics-agent }`
- Reduce to ~120 lines

**`/meta` command**:
- Keep current structure (complex system builder)

---

### Step 3.6: Verify Phase 3 Completion

**Checklist**:
- [ ] Command template created
- [ ] `/plan` simplified (~120 lines)
- [ ] `/research` simplified (~130 lines)
- [ ] `/implement` simplified (~140 lines)
- [ ] `/revise` simplified (~120 lines)
- [ ] `/review` simplified (~130 lines)
- [ ] `/errors` simplified (~120 lines)
- [ ] All commands have `routing:` frontmatter
- [ ] All commands reference new context paths
- [ ] All commands use `workflow_setup` section

**Verification**:
```bash
cd /home/benjamin/Projects/ProofChecker/.opencode/command

# Check line counts
wc -l *.md

# Verify routing frontmatter exists
grep -l "routing:" *.md

# Check for old context paths
grep -r "system/routing-guide" . --include="*.md"
# Should return no results
```

---

## Phase 4: Documentation Updates

**Goal**: Update documentation to reflect new architecture  
**Effort**: 1-2 hours  
**Risk**: Low (documentation only)

### Step 4.1: Update ARCHITECTURE.md

**File**: `.opencode/ARCHITECTURE.md`

**Add new section after line 113** (after "Architecture Principles"):

(See PHASE_4_ARCHITECTURE_ADDITION.md for full content)

---

### Step 4.2: Update README.md

**File**: `.opencode/README.md`

**Find line 76** (in "Key Improvements Over Old System" section)

**Add new subsections**:

```markdown
### 9. Smart Coordinator Pattern

**Old System**: Orchestrator was either too simple (just routing) or too complex (workflow execution).

**New System**: Smart coordinator handles preflight/postflight while staying simple:
- Preflight: Validate task exists, check delegation safety
- Routing: Extract language, determine target agent
- Postflight: Cleanup session, format return

### 10. Language-Based Routing

**Old System**: Manual routing, no language awareness.

**New System**: Automatic routing based on task language:
- Lean tasks → lean-specific agents with LSP integration
- Other tasks → general agents
- Language extracted from project state.json or TODO.md

### 11. Clean Context Organization

**Old System**: Scattered context files, unclear organization.

**New System**: Clean `core/` and `project/` hierarchy:
- core/ - General, reusable context
- project/ - ProofChecker-specific domain knowledge
```

---

### Step 4.3: Create Orchestrator Design Doc

**File**: `.opencode/context/core/system/orchestrator-design.md`

**Create new file** (see PHASE_4_ORCHESTRATOR_DESIGN.md for full content)

---

### Step 4.4: Update QUICK-START.md

**File**: `.opencode/QUICK-START.md`

**Add new section after "Common Workflows"**:

```markdown
---

## How Commands Work

### Command Flow

1. **User invokes command**: `/plan 244`
2. **Orchestrator parses**: Extracts task number, reads command file
3. **Preflight validation**: Checks task exists, delegation safety
4. **Routing**: Extracts language, determines target agent
5. **Delegation**: Invokes agent with context
6. **Validation**: Validates agent return format
7. **Return**: Formats and returns result to user

### Language-Based Routing

Some commands route to different agents based on task language:

**`/research`**:
- Lean tasks → lean-research-agent (with LeanSearch, Loogle, LSP)
- Other tasks → researcher (with web search, docs)

**`/implement`**:
- Lean tasks → lean-implementation-agent (with LSP, lake build)
- Other tasks → implementer (with general file operations)

**Language extracted from**:
1. Project state.json (if exists)
2. TODO.md task entry (**Language** field)
3. Default "general" (if not found)

### Command Types

**Workflow Commands** (delegate to agents):
- `/research` - Conduct research
- `/plan` - Create implementation plan
- `/implement` - Execute implementation
- `/revise` - Revise existing artifacts
- `/review` - Analyze codebase

**Direct Commands** (orchestrator handles):
- `/task` - Create new task
- `/todo` - Archive completed tasks

---
```

---

### Step 4.5: Verify Phase 4 Completion

**Checklist**:
- [ ] ARCHITECTURE.md updated with smart coordinator pattern
- [ ] README.md updated with new improvements
- [ ] orchestrator-design.md created
- [ ] QUICK-START.md updated with command flow
- [ ] All documentation references new context paths
- [ ] No broken links in documentation

**Verification**:
```bash
cd /home/benjamin/Projects/ProofChecker/.opencode

# Check for broken context references
grep -r "system/routing-guide" . --include="*.md" | grep -v "core/system"
grep -r "system/orchestrator-guide" . --include="*.md" | grep -v "core/system"

# Should return no results
```

---

## Final Verification

### Complete System Check

**After all phases complete**:

```bash
cd /home/benjamin/Projects/ProofChecker/.opencode

# 1. Verify context structure
ls -la context/core/
ls -la context/core/standards/
ls -la context/core/workflows/
ls -la context/core/system/
ls -la context/core/templates/

# 2. Verify no old paths remain
grep -r "system/routing-guide" . --include="*.md" | grep -v "core/system"
grep -r "system/orchestrator-guide" . --include="*.md" | grep -v "core/system"

# 3. Check orchestrator
wc -l agent/orchestrator.md  # Should be ~450 lines

# 4. Check commands
wc -l command/*.md  # Most should be 100-150 lines

# 5. Verify specs/ unchanged
ls -la specs/
cat specs/TODO.md | head -20
cat specs/state.json | head -20
```

---

## Rollback Plan

If issues arise during implementation:

### Phase 1 Rollback
```bash
cd /home/benjamin/Projects/ProofChecker/.opencode/context

# Restore old structure
mkdir -p system
mv core/system/routing-guide.md system/
mv core/system/orchestrator-guide.md system/
rm -rf core/

# Revert references in orchestrator and commands
# (manual edits required - use git if available)
```

### Phase 2 Rollback
```bash
cd /home/benjamin/Projects/ProofChecker/.opencode/agent
cp orchestrator.md.backup orchestrator.md
```

### Phase 3 Rollback
```bash
# Use git to restore command files
cd /home/benjamin/Projects/ProofChecker
git checkout .opencode/command/
```

### Phase 4 Rollback
```bash
# Use git to restore documentation
cd /home/benjamin/Projects/ProofChecker
git checkout .opencode/README.md
git checkout .opencode/ARCHITECTURE.md
git checkout .opencode/QUICK-START.md
```

---

## Success Criteria

### Phase 1 Success
- [ ] `context/core/` exists with 4 subdirectories
- [ ] `context/system/` removed
- [ ] All context files in new locations
- [ ] All references updated
- [ ] No broken paths

### Phase 2 Success
- [ ] Orchestrator is ~450 lines (down from 592)
- [ ] 7 stages (down from 9)
- [ ] PreflightValidation stage exists
- [ ] DetermineRouting stage exists with language extraction
- [ ] No syntax errors

### Phase 3 Success
- [ ] Commands are 100-150 lines (down from 300-400)
- [ ] All commands have `routing:` frontmatter
- [ ] All commands use `workflow_setup` section
- [ ] All commands reference new context paths
- [ ] No broken references

### Phase 4 Success
- [ ] Documentation updated
- [ ] orchestrator-design.md created
- [ ] No broken links
- [ ] Clear explanation of new architecture

### Overall Success
- [ ] All phases complete
- [ ] System functions correctly
- [ ] `specs/` unchanged
- [ ] TODO.md and state.json unchanged
- [ ] All tasks and projects preserved

---

## Estimated Timeline

| Phase | Effort | Risk | Priority |
|-------|--------|------|----------|
| Phase 1: Context Reorganization | 2-3 hours | Medium | High |
| Phase 2: Orchestrator Streamlining | 3-4 hours | High | High |
| Phase 3: Command Simplification | 2-3 hours | Medium | Medium |
| Phase 4: Documentation Updates | 1-2 hours | Low | Low |

**Total**: 8-12 hours

**Recommended approach**: Execute phases sequentially, verify each phase before proceeding to next.

---

## Notes

- This plan preserves all existing tasks in TODO.md
- All project directories in specs/ remain unchanged
- No changes to state.json structure
- Backward compatibility is NOT maintained for context paths
- Git commits recommended after each phase
- Test basic commands after Phase 2 and Phase 3

---

## Next Steps

1. Review this plan thoroughly
2. Ask any clarifying questions
3. Begin Phase 1 when ready
4. Verify Phase 1 completion before Phase 2
5. Continue sequentially through all phases

**Ready to begin when you are!**
