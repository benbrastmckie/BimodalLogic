# Context Files Refactor Plan

**Project**: ProofChecker Context Organization Simplification
**Created**: 2026-01-04
**Updated**: 2026-01-04 (Post-Architecture Discovery)
**Status**: DRAFT - Ready for Review

## Executive Summary

The `.opencode/context/core/` directory has accumulated redundant files, unclear organization, and inconsistent naming patterns. This plan reorganizes the context structure to eliminate redundancy, improve clarity, and maintain a clean, maintainable system.

**Critical Requirement**: All references throughout the system must be updated to prevent breaking the agent system.

**CRITICAL ARCHITECTURAL NOTE**: This refactor plan has been updated to reflect the **actual working architecture** discovered during implementation of the argument passing fixes. The ProofChecker system uses a **three-layer delegation pattern** that is fundamentally different from other .opencode systems like OpenAgents. This architecture MUST be preserved and documented in context files.

## Current State Analysis

### Directory Structure

```
.opencode/context/core/
├── schemas/                    # 2 files (JSON schemas)
├── standards/                  # 22 files (mixed content types)
├── system/                     # 9 files (orchestrator & routing)
├── templates/                  # 8 files (agent/command templates)
└── workflows/                  # 6 files (process documentation)
```

**Total**: 47 files across 5 directories

### Identified Issues

#### 1. **Redundant/Overlapping Files**

| File 1 | File 2 | Overlap | Issue |
|--------|--------|---------|-------|
| `standards/delegation.md` | `workflows/delegation-guide.md` | 80% | Same delegation patterns, different organization |
| `system/orchestrator-design.md` | `system/orchestrator-guide.md` | 60% | Design vs usage split unclear |
| `system/routing-guide.md` | `system/routing-logic.md` | 70% | Routing patterns duplicated |
| `standards/subagent-return-format.md` | `standards/command-output.md` | 40% | Both define output formats |
| `system/validation-rules.md` | `system/validation-strategy.md` | 50% | Validation logic split |
| `standards/patterns.md` | `standards/domain-patterns.md` | 30% | Pattern definitions overlap |

**Impact**: 
- Confusion about which file to reference
- Maintenance burden (update in multiple places)
- Context bloat (loading redundant information)

#### 2. **Inconsistent Naming Patterns**

| Pattern | Files | Issue |
|---------|-------|-------|
| Singular vs Plural | `standards/command.md` vs `standards/commands.md` | Inconsistent |
| Hyphenated | `subagent-return-format.md` | Most files use hyphens |
| Non-hyphenated | `orchestrator-design.md` vs `orchestratorguide.md` | Mixed |
| Descriptive suffixes | `-guide.md`, `-standard.md`, `-template.md` | Inconsistent usage |

**Impact**:
- Hard to predict file names
- Difficult to find related files
- Unclear file purpose from name

#### 3. **Unclear Directory Organization**

**`standards/` contains mixed content**:
- Output formats (`subagent-return-format.md`, `command-output.md`)
- Code patterns (`code.md`, `patterns.md`, `xml-patterns.md`)
- Artifact formats (`plan.md`, `report.md`, `summary.md`)
- Process standards (`delegation.md`, `git-safety.md`)
- Meta patterns (`domain-patterns.md`, `architecture-principles.md`)

**Issue**: "Standards" is too broad - unclear what belongs here

**`system/` contains mixed content**:
- Orchestrator docs (`orchestrator-design.md`, `orchestrator-guide.md`)
- Routing logic (`routing-guide.md`, `routing-logic.md`)
- Validation (`validation-rules.md`, `validation-strategy.md`)
- State management (`state-management.md`, `artifact-management.md`)

**Issue**: "System" is vague - could mean many things

**`workflows/` contains mixed content**:
- Process guides (`delegation-guide.md`, `command-lifecycle.md`)
- Status management (`status-transitions.md`, `sessions.md`)
- Meta processes (`interview-patterns.md`, `task-breakdown.md`)

**Issue**: Mix of technical workflows and meta processes

#### 4. **Obsolete/Redundant Files**

Files that may no longer be needed after command argument refactor:

- `standards/command-argument-handling.md` - **DELETE** (per refactor plan)
- `system/validation-rules.md` - **MISSING** (referenced but doesn't exist)
- `workflows/sessions.md` - Describes `.tmp/sessions/` which may not be used
- `standards/domain-patterns.md` - Meta-builder specific, not core
- `standards/architecture-principles.md` - Meta-builder specific, not core

#### 5. **Missing Organization**

**No clear separation between**:
- **Core system files** (orchestrator, routing, delegation)
- **Artifact format specs** (plan, report, summary)
- **Development standards** (code, tests, documentation)
- **Meta-builder files** (domain patterns, architecture principles)

## Critical Architecture Documentation

### ProofChecker's Three-Layer Delegation Pattern

**MUST BE DOCUMENTED IN CONTEXT FILES**

ProofChecker uses a unique three-layer delegation architecture that differs fundamentally from other .opencode systems:

```
Layer 1: Orchestrator (.opencode/agent/orchestrator.md)
- Role: Pure router
- Input: Command name from user (e.g., "/implement 259")
- Process: Load command file, delegate to command file with $ARGUMENTS
- Output: Relays result from command file to user
- Complexity: ~150 lines (v7.0)

Layer 2: Command File (.opencode/command/{command}.md)
- Role: Command-specific argument parsing and routing agent
- Input: $ARGUMENTS from orchestrator (e.g., "259" or "259 custom prompt")
- Has: Full agent structure with <workflow_execution> stages
- Process:
  1. Parse task number from $ARGUMENTS
  2. Validate task exists in TODO.md
  3. Extract language/metadata from task entry
  4. Route to appropriate execution subagent
  5. Delegate with parsed context
- Output: Delegates to execution subagent, relays result
- Complexity: ~150 lines per command

Layer 3: Execution Subagent (.opencode/agent/subagents/{agent}.md)
- Role: Actual work execution
- Input: Parsed task context from command file
- Has: <process_flow> with implementation steps
- Process: Execute task workflow, create artifacts, update status
- Output: Returns result to command file
- Complexity: ~300 lines per subagent
```

**Key Architectural Principles**:

1. **Command Files ARE Agents**: They have `<workflow_execution>`, receive `$ARGUMENTS`, and delegate to subagents
2. **agent: orchestrator Means**: "Orchestrator delegates to THIS COMMAND FILE" (not "orchestrator handles this")
3. **$ARGUMENTS Only Available**: To orchestrator and command files (NOT to execution subagents)
4. **Task-Based Pattern**: Commands take task numbers (e.g., `/implement 259`), not topics
5. **Language-Based Routing**: Command files extract language from TODO.md and route to language-specific subagents

**Why This Architecture Exists**:

- ProofChecker uses **task-based commands** (task numbers from TODO.md)
- Requires validation against TODO.md before execution
- Requires language extraction for routing (lean vs general)
- Each command has different argument patterns (task number, range, custom prompt)
- Command files provide command-specific parsing logic
- Execution subagents receive clean, validated inputs

**This is NOT the OpenAgents Pattern**:

OpenAgents uses topic-based commands (`/research "topic"`) with direct subagent invocation. ProofChecker's task-based pattern requires the three-layer delegation architecture.

**Critical for /meta Command**:

The `/meta` command and its subagents (agent-generator, command-creator, etc.) MUST understand this architecture when:
- Creating new .opencode systems modeled after ProofChecker
- Extending the ProofChecker system with new commands
- Revising existing commands or agents

**Documentation Requirements**:

This architecture MUST be documented in:
1. `orchestration/architecture.md` - Complete three-layer pattern explanation
2. `orchestration/orchestrator.md` - Orchestrator's pure router role
3. `formats/command-structure.md` - Command files as agents with workflows
4. `templates/command-template.md` - Template showing workflow_execution structure
5. Meta-builder context files for system generation

## Proposed Solution

### Design Principles

1. **Single Source of Truth**: Each concept documented in exactly one file
2. **Clear Naming**: Consistent pattern: `{topic}-{type}.md` (e.g., `delegation-guide.md`)
3. **Logical Grouping**: Related files in same directory
4. **Minimal Redundancy**: Merge overlapping files
5. **Clear Purpose**: Directory names indicate content type
6. **Architecture Preservation**: Document ProofChecker's unique three-layer pattern

### New Directory Structure

```
.opencode/context/core/
├── orchestration/              # Orchestrator, routing, delegation (8 files)
│   ├── architecture.md         # **NEW** Three-layer delegation pattern
│   ├── orchestrator.md         # Orchestrator design & usage (merged)
│   ├── routing.md              # Routing logic (merged)
│   ├── delegation.md           # Delegation patterns (merged)
│   ├── validation.md           # Validation rules (merged)
│   ├── state-management.md     # State & artifact management (merged)
│   ├── state-lookup.md         # **EXISTING** Fast state.json lookup patterns
│   └── sessions.md             # Session management (if needed)
│
├── formats/                    # Artifact & output formats (7 files)
│   ├── command-structure.md    # **NEW** Command files as agents
│   ├── subagent-return.md      # Subagent JSON return format
│   ├── command-output.md       # User-facing command output
│   ├── plan-format.md          # Implementation plan structure
│   ├── report-format.md        # Research report structure
│   ├── summary-format.md       # Summary artifact structure
│   └── frontmatter.md          # YAML frontmatter standard
│
├── standards/                  # Development standards (8 files)
│   ├── code-patterns.md        # Code quality patterns (merged)
│   ├── error-handling.md       # Error handling patterns
│   ├── git-safety.md           # Git commit safety
│   ├── documentation.md        # Documentation standards
│   ├── testing.md              # Test standards
│   ├── xml-structure.md        # XML/markdown structure patterns
│   ├── task-management.md      # Task tracking standards
│   └── analysis-framework.md   # Analysis standards
│
├── workflows/                  # Process workflows (4 files)
│   ├── command-lifecycle.md    # 8-stage command workflow
│   ├── status-transitions.md   # Task status state machine
│   ├── task-breakdown.md       # Task decomposition process
│   └── review-process.md       # Review workflow
│
├── templates/                  # File templates (6 files)
│   ├── agent-template.md       # Agent file template
│   ├── subagent-template.md    # Subagent file template
│   ├── command-template.md     # Command file template (with workflows!)
│   ├── orchestrator-template.md # Orchestrator template
│   ├── delegation-context.md   # Delegation context template
│   └── state-template.json     # State.json template
│
└── schemas/                    # JSON schemas (2 files)
    ├── frontmatter-schema.json # YAML frontmatter schema
    └── subagent-frontmatter.yaml # Subagent frontmatter template
```

**Total**: 34 files across 6 directories (down from 47 files)

**Reduction**: 13 files eliminated (28% reduction)

**New Files Added**: 2 critical architecture documentation files
- `orchestration/architecture.md` - Documents three-layer delegation pattern
- `formats/command-structure.md` - Documents command files as agents with workflows

### State Management Optimization (IMPLEMENTED)

**Critical Update**: The system has been optimized to use `state.json` for fast task lookup instead of parsing `TODO.md`. This optimization is now part of the core architecture and must be documented in context files.

**Key Changes**:
- ✅ Command files use `state.json` for task lookup (8x faster: 100ms → 12ms)
- ✅ `jq` queries replace `grep`/`sed` markdown parsing
- ✅ All metadata extracted at once (language, status, description, priority)
- ✅ `status-sync-manager` maintains synchronization between `state.json` and `TODO.md`
- ✅ Read/write separation: reads from `state.json`, writes via `status-sync-manager`

**New Context Files Created**:
- `.opencode/context/core/system/state-lookup.md` - Fast lookup patterns using `jq`

**Files Updated**:
- `.opencode/command/implement.md` - Uses `state.json` lookup in Stage 1
- `.opencode/command/research.md` - Uses `state.json` lookup in Stage 1
- `.opencode/command/plan.md` - Uses `state.json` lookup in Stage 1
- `.opencode/command/revise.md` - Uses `state.json` lookup in Stage 1

**Impact on Context Refactor**:
- `state-lookup.md` must be included in `orchestration/` or `system/` directory
- `state-management.md` must document read/write separation pattern
- Command templates must show `state.json` lookup pattern
- Meta-builder must understand `state.json` optimization when creating new commands

### New Architecture Documentation Files

#### orchestration/architecture.md (NEW)

**Purpose**: Document ProofChecker's unique three-layer delegation pattern and state.json optimization

**Content**:
```markdown
# ProofChecker Architecture: Three-Layer Delegation Pattern

## Overview

ProofChecker uses a unique three-layer delegation architecture that differs from other .opencode systems like OpenAgents. This architecture is essential for task-based commands that require validation against TODO.md and language-based routing.

## The Three Layers

### Layer 1: Orchestrator (Pure Router)
**File**: `.opencode/agent/orchestrator.md`
**Role**: Load command file and delegate with $ARGUMENTS
**Complexity**: ~150 lines

Workflow:
1. Extract command name from user input
2. Load .opencode/command/{command}.md
3. Delegate to command file with $ARGUMENTS
4. Relay result to user

### Layer 2: Command File (Argument Parsing Agent)
**Files**: `.opencode/command/*.md`
**Role**: Parse arguments, validate, route to execution subagent
**Complexity**: ~150 lines per command

Workflow:
1. Receive $ARGUMENTS from orchestrator
2. Parse task number from $ARGUMENTS
3. Validate task exists in TODO.md
4. Extract language/metadata from task entry
5. Route to appropriate execution subagent
6. Delegate with parsed context

### Layer 3: Execution Subagent (Work Executor)
**Files**: `.opencode/agent/subagents/*.md`
**Role**: Execute actual work (research, planning, implementation)
**Complexity**: ~300 lines per subagent

Workflow:
1. Receive parsed context from command file
2. Execute task workflow
3. Create artifacts
4. Update status
5. Return result

## Key Architectural Principles

1. **Command Files ARE Agents**: They have <workflow_execution>, not just metadata
2. **agent: orchestrator**: Means "delegate to this command file", not "orchestrator handles"
3. **$ARGUMENTS Availability**: Only orchestrator and command files have access
4. **Task-Based Pattern**: Commands take task numbers, not topics
5. **Language-Based Routing**: Command files extract language and route accordingly

## Why This Architecture?

ProofChecker's task-based workflow requires:
- Validation against TODO.md before execution
- Language extraction for routing (lean vs general)
- Command-specific argument parsing (task number, range, custom prompt)
- Clean, validated inputs to execution subagents

## Comparison with OpenAgents

| Aspect | OpenAgents | ProofChecker |
|--------|------------|--------------|
| Command pattern | Topic-based | Task-based |
| Arguments | Natural language | Task numbers |
| Validation | None | TODO.md lookup required |
| Routing | Keyword-based | Language-based |
| Command files | Simple metadata | Full agents with workflows |
| Layers | 2 (orchestrator → subagent) | 3 (orchestrator → command → subagent) |

## Critical for System Generation

When using `/meta` to create or extend .opencode systems:

**If modeling after ProofChecker**:
- ✅ Use three-layer delegation
- ✅ Command files have <workflow_execution>
- ✅ Command files parse arguments
- ✅ Execution subagents receive parsed context

**If creating topic-based system**:
- ✅ Use two-layer delegation (like OpenAgents)
- ✅ Command files can be simple metadata
- ✅ Direct subagent invocation possible

**Never mix patterns** - task-based requires three layers!
```

#### formats/command-structure.md (NEW)

**Purpose**: Document command files as agents with workflow execution

**Content**:
```markdown
# Command File Structure: Commands as Agents

## Overview

In ProofChecker's architecture, command files in `.opencode/command/` are NOT just metadata files. They are **full agents** with workflow execution stages.

## Command File Anatomy

### Frontmatter (YAML)
```yaml
---
name: implement
agent: orchestrator  # Orchestrator delegates to THIS FILE
description: "Execute implementation"
timeout: 7200
routing:
  language_based: true
  lean: lean-implementation-agent
  default: implementer
---
```

### Task Input Declaration
```markdown
**Task Input (required):** $ARGUMENTS
```

This declares that the command receives $ARGUMENTS from orchestrator.

### Agent Structure
```xml
<context>
  <system_context>What this command does</system_context>
  <task_context>Specific responsibilities</task_context>
</context>

<role>Command agent role</role>

<task>Parse arguments, validate, route to execution subagent</task>
```

### Workflow Execution (CRITICAL)
```xml
<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse task number and validate</action>
    <process>
      1. Parse task number from $ARGUMENTS
      2. Validate task exists in TODO.md
      3. Extract task description
    </process>
  </stage>
  
  <stage id="2" name="ExtractLanguage">
    <action>Extract language for routing</action>
    <process>
      1. Extract language from TODO.md
      2. Determine target agent
    </process>
  </stage>
  
  <stage id="3" name="Delegate">
    <action>Delegate to execution subagent</action>
    <process>
      1. Invoke target agent with parsed context
      2. Relay result to user
    </process>
  </stage>
</workflow_execution>
```

## Why Commands Have Workflows

1. **$ARGUMENTS Access**: Only orchestrator and command files receive $ARGUMENTS
2. **Command-Specific Parsing**: Each command has different argument patterns
3. **Validation**: Task-based commands must validate against TODO.md
4. **Routing Logic**: Language-based routing requires metadata extraction
5. **Clean Delegation**: Execution subagents receive parsed, validated inputs

## Command File Responsibilities

1. **Parse Arguments**: Extract task number, custom prompt, flags from $ARGUMENTS
2. **Validate Inputs**: Check task exists, validate format
3. **Extract Metadata**: Get language, description, status from TODO.md
4. **Route**: Determine appropriate execution subagent
5. **Delegate**: Invoke subagent with clean, parsed context
6. **Relay**: Pass result back to user

## Common Mistake

**WRONG** (v6.0 attempt):
```yaml
---
agent: implementer  # Direct invocation
---

# Simple metadata file, no workflows
```

**Problem**: Implementer doesn't receive $ARGUMENTS, can't parse task number!

**CORRECT** (working pattern):
```yaml
---
agent: orchestrator  # Delegates to this command file
---

<workflow_execution>
  <!-- Parse, validate, route -->
</workflow_execution>
```

## Template

See `.opencode/context/core/templates/command-template.md` for complete template with workflow stages.
```

### File Consolidation Map

#### Orchestration Directory (7 files - includes 1 new)

| New File | Merged From | Rationale |
|----------|-------------|-----------|
| `architecture.md` | **NEW FILE** | Document three-layer delegation pattern |
| `orchestrator.md` | `system/orchestrator-design.md`<br>`system/orchestrator-guide.md` | Merge design + usage into single reference |
| `routing.md` | `system/routing-guide.md`<br>`system/routing-logic.md` | Merge routing patterns into single file |
| `delegation.md` | `standards/delegation.md`<br>`workflows/delegation-guide.md` | Merge delegation standard + guide |
| `validation.md` | `system/validation-strategy.md`<br>`system/validation-rules.md` (missing) | Merge validation logic |
| `state-management.md` | `system/state-management.md`<br>`system/artifact-management.md` | Merge state + artifact management |
| `sessions.md` | `workflows/sessions.md` | Keep if sessions are used, else delete |

#### Formats Directory (7 files - includes 1 new)

| New File | Merged From | Rationale |
|----------|-------------|-----------|
| `command-structure.md` | **NEW FILE** | Document command files as agents with workflows |
| `subagent-return.md` | `standards/subagent-return-format.md` | Rename for clarity |
| `command-output.md` | `standards/command-output.md` | Keep as-is (clear purpose) |
| `plan-format.md` | `standards/plan.md` | Rename for consistency |
| `report-format.md` | `standards/report.md` | Rename for consistency |
| `summary-format.md` | `standards/summary.md` | Rename for consistency |
| `frontmatter.md` | `standards/frontmatter-standard.md` | Rename for brevity |

#### Standards Directory (8 files)

| New File | Merged From | Rationale |
|----------|-------------|-----------|
| `code-patterns.md` | `standards/code.md`<br>`standards/patterns.md` | Merge code + general patterns |
| `error-handling.md` | `standards/error-handling.md` | Keep as-is |
| `git-safety.md` | `standards/git-safety.md` | Keep as-is |
| `documentation.md` | `standards/documentation.md` | Keep as-is |
| `testing.md` | `standards/tests.md` | Rename for consistency |
| `xml-structure.md` | `standards/xml-patterns.md` | Rename for clarity |
| `task-management.md` | `standards/tasks.md` | Rename for clarity |
| `analysis-framework.md` | `standards/analysis.md` | Rename for clarity |

#### Workflows Directory (4 files)

| New File | Merged From | Rationale |
|----------|-------------|-----------|
| `command-lifecycle.md` | `workflows/command-lifecycle.md` | Keep as-is |
| `status-transitions.md` | `workflows/status-transitions.md` | Keep as-is |
| `task-breakdown.md` | `workflows/task-breakdown.md` | Keep as-is |
| `review-process.md` | `workflows/review.md` | Rename for clarity |

#### Templates Directory (6 files)

| New File | Merged From | Rationale |
|----------|-------------|-----------|
| `agent-template.md` | `templates/agent-templates.md` | Rename (singular) |
| `subagent-template.md` | `templates/subagent-template.md` | Keep as-is |
| `command-template.md` | `templates/command-template.md` | Keep as-is |
| `orchestrator-template.md` | `templates/orchestrator-template.md` | Keep as-is |
| `delegation-context.md` | `templates/delegation-context-template.md` | Shorten name |
| `state-template.json` | `templates/state-template.json` | Keep as-is |

#### Schemas Directory (2 files)

| New File | Merged From | Rationale |
|----------|-------------|-----------|
| `frontmatter-schema.json` | `schemas/frontmatter-schema.json` | Keep as-is |
| `subagent-frontmatter.yaml` | `templates/subagent-frontmatter-template.yaml` | Move to schemas |

#### Files to Delete

| File | Reason |
|------|--------|
| `standards/command-argument-handling.md` | Obsolete (per command refactor plan) |
| `standards/command-structure.md` | Redundant with `command-template.md` |
| `standards/commands.md` | Redundant with `command-template.md` |
| `standards/subagent-structure.md` | Redundant with `subagent-template.md` |
| `standards/domain-patterns.md` | Meta-builder specific, move to project/meta/ |
| `standards/architecture-principles.md` | Meta-builder specific, move to project/meta/ |
| `templates/meta-guide.md` | Meta-builder specific, move to project/meta/ |
| `workflows/interview-patterns.md` | Meta-builder specific, move to project/meta/ |
| `system/context-loading-strategy.md` | Merge into `orchestrator.md` |
| `system/self-healing-guide.md` | Obsolete or move to project-specific |

**Total Deleted**: 10 files

**Meta-builder files to move**: 4 files → `.opencode/context/project/meta/`

### Naming Convention

**Pattern**: `{topic}-{type}.md`

**Types**:
- No suffix: Core reference (e.g., `orchestrator.md`, `routing.md`)
- `-format.md`: Artifact format specs (e.g., `plan-format.md`)
- `-template.md`: File templates (e.g., `agent-template.md`)
- `-process.md`: Workflow processes (e.g., `review-process.md`)

**Examples**:
- ✅ `orchestrator.md` (core reference)
- ✅ `plan-format.md` (artifact format)
- ✅ `agent-template.md` (file template)
- ✅ `review-process.md` (workflow)
- ❌ `orchestrator-guide.md` (redundant suffix)
- ❌ `routing-logic.md` (redundant suffix)

## Reference Update Strategy

### Step 1: Find All References

Search for context file references in:

1. **Agent files** (`.opencode/agent/**/*.md`)
2. **Command files** (`.opencode/command/**/*.md`)
3. **Context files** (`.opencode/context/**/*.md`)
4. **Documentation** (`docs/**/*.md`)

**Search patterns**:
```
@.opencode/context/core/standards/
@.opencode/context/core/system/
@.opencode/context/core/workflows/
@.opencode/context/core/templates/
```

### Step 2: Create Reference Map

Build mapping of old → new paths:

```json
{
  "standards/delegation.md": "orchestration/delegation.md",
  "workflows/delegation-guide.md": "orchestration/delegation.md",
  "system/orchestrator-design.md": "orchestration/orchestrator.md",
  "system/orchestrator-guide.md": "orchestration/orchestrator.md",
  "system/routing-guide.md": "orchestration/routing.md",
  "system/routing-logic.md": "orchestration/routing.md",
  "standards/subagent-return-format.md": "formats/subagent-return.md",
  "standards/plan.md": "formats/plan-format.md",
  "standards/report.md": "formats/report-format.md",
  "standards/summary.md": "formats/summary-format.md",
  "standards/code.md": "standards/code-patterns.md",
  "standards/patterns.md": "standards/code-patterns.md",
  "standards/tests.md": "standards/testing.md",
  "standards/xml-patterns.md": "standards/xml-structure.md",
  "standards/tasks.md": "standards/task-management.md",
  "standards/analysis.md": "standards/analysis-framework.md",
  "workflows/review.md": "workflows/review-process.md",
  "templates/agent-templates.md": "templates/agent-template.md",
  "templates/delegation-context-template.md": "templates/delegation-context.md"
}
```

### Step 3: Update References

For each file containing context references:

1. Read file
2. Find all `@.opencode/context/core/` references
3. Replace with new paths using reference map
4. Validate syntax (ensure @ symbol preserved)
5. Write updated file

**Example transformation**:
```markdown
# Before
See: @.opencode/context/core/standards/delegation.md
See: @.opencode/context/core/workflows/delegation-guide.md

# After
See: @.opencode/context/core/orchestration/delegation.md
```

### Step 4: Validate References

After updates:

1. Check all `@.opencode/context/core/` references resolve to existing files
2. Verify no broken references
3. Test loading context in orchestrator
4. Test command execution

## Implementation Phases

### Phase 1: Backup and Preparation (15 minutes)

**Tasks**:
1. Create backup:
   ```bash
   cp -r .opencode/context/core .opencode/context/core.backup.$(date +%Y%m%d_%H%M%S)
   ```

2. Create new directory structure:
   ```bash
   mkdir -p .opencode/context/core.new/{orchestration,formats,standards,workflows,templates,schemas}
   ```

3. Document all current references:
   ```bash
   grep -r "@.opencode/context/core/" .opencode/agent/ > /tmp/context-refs-agents.txt
   grep -r "@.opencode/context/core/" .opencode/command/ > /tmp/context-refs-commands.txt
   grep -r "@.opencode/context/core/" .opencode/context/ > /tmp/context-refs-context.txt
   ```

**Validation**:
- [ ] Backup created
- [ ] New directories exist
- [ ] Reference list generated

**Estimated Effort**: 15 minutes

### Phase 2: Merge and Create Files (2-3 hours)

**Tasks**:

#### 2.1: Orchestration Directory

1. **Merge `orchestrator.md`**:
   - Read `system/orchestrator-design.md`
   - Read `system/orchestrator-guide.md`
   - Merge into single file with sections:
     - Design Philosophy
     - Workflow Stages
     - Usage Examples
     - Troubleshooting
   - Write to `orchestration/orchestrator.md`

2. **Merge `routing.md`**:
   - Read `system/routing-guide.md`
   - Read `system/routing-logic.md`
   - Merge into single file
   - Write to `orchestration/routing.md`

3. **Merge `delegation.md`**:
   - Read `standards/delegation.md`
   - Read `workflows/delegation-guide.md`
   - Merge into single file
   - Write to `orchestration/delegation.md`

4. **Merge `validation.md`**:
   - Read `system/validation-strategy.md`
   - Create comprehensive validation guide
   - Write to `orchestration/validation.md`

5. **Merge `state-management.md`**:
   - Read `system/state-management.md`
   - Read `system/artifact-management.md`
   - Merge into single file
   - Write to `orchestration/state-management.md`

6. **Copy `sessions.md`** (if needed):
   - Read `workflows/sessions.md`
   - Determine if still used
   - If yes: Copy to `orchestration/sessions.md`
   - If no: Skip (delete)

#### 2.2: Formats Directory

1. **Rename format files**:
   - `standards/subagent-return-format.md` → `formats/subagent-return.md`
   - `standards/command-output.md` → `formats/command-output.md`
   - `standards/plan.md` → `formats/plan-format.md`
   - `standards/report.md` → `formats/report-format.md`
   - `standards/summary.md` → `formats/summary-format.md`
   - `standards/frontmatter-standard.md` → `formats/frontmatter.md`

#### 2.3: Standards Directory

1. **Merge `code-patterns.md`**:
   - Read `standards/code.md`
   - Read `standards/patterns.md`
   - Merge into comprehensive code patterns guide
   - Write to `standards/code-patterns.md`

2. **Rename standard files**:
   - `standards/error-handling.md` → `standards/error-handling.md` (keep)
   - `standards/git-safety.md` → `standards/git-safety.md` (keep)
   - `standards/documentation.md` → `standards/documentation.md` (keep)
   - `standards/tests.md` → `standards/testing.md`
   - `standards/xml-patterns.md` → `standards/xml-structure.md`
   - `standards/tasks.md` → `standards/task-management.md`
   - `standards/analysis.md` → `standards/analysis-framework.md`

#### 2.4: Workflows Directory

1. **Rename workflow files**:
   - `workflows/command-lifecycle.md` → `workflows/command-lifecycle.md` (keep)
   - `workflows/status-transitions.md` → `workflows/status-transitions.md` (keep)
   - `workflows/task-breakdown.md` → `workflows/task-breakdown.md` (keep)
   - `workflows/review.md` → `workflows/review-process.md`

#### 2.5: Templates Directory

1. **Rename template files**:
   - `templates/agent-templates.md` → `templates/agent-template.md`
   - `templates/subagent-template.md` → `templates/subagent-template.md` (keep)
   - `templates/command-template.md` → `templates/command-template.md` (keep)
   - `templates/orchestrator-template.md` → `templates/orchestrator-template.md` (keep)
   - `templates/delegation-context-template.md` → `templates/delegation-context.md`
   - `templates/state-template.json` → `templates/state-template.json` (keep)

#### 2.6: Schemas Directory

1. **Organize schema files**:
   - `schemas/frontmatter-schema.json` → `schemas/frontmatter-schema.json` (keep)
   - `templates/subagent-frontmatter-template.yaml` → `schemas/subagent-frontmatter.yaml`

#### 2.7: Move Meta-Builder Files

1. **Create meta directory**:
   ```bash
   mkdir -p .opencode/context/project/meta
   ```

2. **Move files**:
   - `standards/domain-patterns.md` → `project/meta/domain-patterns.md`
   - `standards/architecture-principles.md` → `project/meta/architecture-principles.md`
   - `templates/meta-guide.md` → `project/meta/meta-guide.md`
   - `workflows/interview-patterns.md` → `project/meta/interview-patterns.md`

**Validation**:
- [ ] All merged files created
- [ ] All renamed files in correct locations
- [ ] Meta-builder files moved
- [ ] No duplicate content

**Estimated Effort**: 2.5 hours

### Phase 3: Update References (1-2 hours)

**Tasks**:

1. **Create reference update script**:
   ```bash
   #!/bin/bash
   # update-context-refs.sh
   
   # Reference map (old → new)
   declare -A ref_map=(
     ["standards/delegation.md"]="orchestration/delegation.md"
     ["workflows/delegation-guide.md"]="orchestration/delegation.md"
     ["system/orchestrator-design.md"]="orchestration/orchestrator.md"
     ["system/orchestrator-guide.md"]="orchestration/orchestrator.md"
     ["system/routing-guide.md"]="orchestration/routing.md"
     ["system/routing-logic.md"]="orchestration/routing.md"
     ["system/validation-strategy.md"]="orchestration/validation.md"
     ["system/state-management.md"]="orchestration/state-management.md"
     ["system/artifact-management.md"]="orchestration/state-management.md"
     ["standards/subagent-return-format.md"]="formats/subagent-return.md"
     ["standards/plan.md"]="formats/plan-format.md"
     ["standards/report.md"]="formats/report-format.md"
     ["standards/summary.md"]="formats/summary-format.md"
     ["standards/frontmatter-standard.md"]="formats/frontmatter.md"
     ["standards/code.md"]="standards/code-patterns.md"
     ["standards/patterns.md"]="standards/code-patterns.md"
     ["standards/tests.md"]="standards/testing.md"
     ["standards/xml-patterns.md"]="standards/xml-structure.md"
     ["standards/tasks.md"]="standards/task-management.md"
     ["standards/analysis.md"]="standards/analysis-framework.md"
     ["workflows/review.md"]="workflows/review-process.md"
     ["templates/agent-templates.md"]="templates/agent-template.md"
     ["templates/delegation-context-template.md"]="templates/delegation-context.md"
   )
   
   # Update references in all files
   for old_path in "${!ref_map[@]}"; do
     new_path="${ref_map[$old_path]}"
     echo "Updating: $old_path → $new_path"
     
     # Update in agent files
     find .opencode/agent -name "*.md" -exec sed -i \
       "s|@.opencode/context/core/$old_path|@.opencode/context/core/$new_path|g" {} \;
     
     # Update in command files
     find .opencode/command -name "*.md" -exec sed -i \
       "s|@.opencode/context/core/$old_path|@.opencode/context/core/$new_path|g" {} \;
     
     # Update in context files
     find .opencode/context -name "*.md" -exec sed -i \
       "s|@.opencode/context/core/$old_path|@.opencode/context/core/$new_path|g" {} \;
   done
   
   echo "Reference update complete"
   ```

2. **Run update script**:
   ```bash
   chmod +x update-context-refs.sh
   ./update-context-refs.sh
   ```

3. **Verify updates**:
   ```bash
   # Check for any remaining old references
   grep -r "@.opencode/context/core/standards/delegation.md" .opencode/
   grep -r "@.opencode/context/core/system/orchestrator-design.md" .opencode/
   # Should return no results
   ```

**Validation**:
- [ ] All references updated
- [ ] No broken references
- [ ] No old paths remain

**Estimated Effort**: 1.5 hours

### Phase 4: Swap Directories (5 minutes)

**Tasks**:

1. **Rename directories**:
   ```bash
   mv .opencode/context/core .opencode/context/core.old
   mv .opencode/context/core.new .opencode/context/core
   ```

2. **Verify structure**:
   ```bash
   tree .opencode/context/core
   ```

**Validation**:
- [ ] New structure in place
- [ ] Old structure preserved as backup

**Estimated Effort**: 5 minutes

### Phase 5: Testing and Validation (1 hour)

**Test Matrix**:

| Test | Command | Expected Result |
|------|---------|-----------------|
| Orchestrator loads | `/plan 196` | Plan created successfully |
| Context loading | Check orchestrator logs | No "file not found" errors |
| Delegation works | `/research 197` | Research report created |
| Routing works | `/implement 196` | Implementation executed |
| Templates accessible | Create new agent | Template loads correctly |

**Validation Checklist**:

- [ ] All commands work (`/plan`, `/research`, `/implement`, `/revise`)
- [ ] No context loading errors in logs
- [ ] All @ references resolve correctly
- [ ] Templates load successfully
- [ ] No broken links in documentation

**Error Handling**:

If any test fails:
1. Check error message for missing file
2. Find file in old structure
3. Verify it was moved/merged correctly
4. Update reference if needed
5. Re-test

**Estimated Effort**: 1 hour

### Phase 6: Cleanup (10 minutes)

**Tasks**:

1. **Remove old directory** (after validation passes):
   ```bash
   rm -rf .opencode/context/core.old
   ```

2. **Remove backup** (optional, after 1 week of stable operation):
   ```bash
   rm -rf .opencode/context/core.backup.*
   ```

3. **Update documentation**:
   - Update `.opencode/context/README.md` with new structure
   - Document new naming conventions
   - Add migration notes

**Validation**:
- [ ] Old directory removed
- [ ] Documentation updated
- [ ] System stable

**Estimated Effort**: 10 minutes

## File Content Guidelines

### Merged File Structure

When merging files, use this structure:

```markdown
# {Topic}

**Version**: {version}
**Last Updated**: {date}
**Purpose**: {one-line purpose}

---

## Quick Reference

{Key points, patterns, or commands}

---

## Overview

{High-level description}

---

## {Section 1}

{Content from first source file}

---

## {Section 2}

{Content from second source file}

---

## Examples

{Practical examples}

---

## Troubleshooting

{Common issues and solutions}

---

## References

{Related files}
```

### File Size Targets

- **Orchestration files**: 200-400 lines (comprehensive reference)
- **Format files**: 100-200 lines (clear specifications)
- **Standard files**: 150-300 lines (detailed guidelines)
- **Workflow files**: 100-250 lines (process documentation)
- **Template files**: 50-150 lines (boilerplate code)

### Content Principles

1. **No Redundancy**: Each concept documented once
2. **Clear Examples**: Every rule has an example
3. **Actionable**: Readers know what to do
4. **Scannable**: Headers, lists, code blocks
5. **Referenced**: Link to related files

## Success Criteria

### Quantitative Metrics

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Total files | 47 | 32 | 32% reduction |
| Redundant files | 10+ | 0 | 100% elimination |
| Avg file size | ~200 lines | ~250 lines | Better consolidation |
| Directory depth | 2 levels | 2 levels | Same (good) |
| Naming consistency | 60% | 100% | 40% improvement |

### Qualitative Metrics

- [ ] **Clarity**: New developer finds files in <2 minutes
- [ ] **Maintainability**: Updates require changing 1 file, not 3
- [ ] **Consistency**: All files follow naming convention
- [ ] **Completeness**: No broken references
- [ ] **Usability**: Context loads <1 second

## Risk Analysis

### High Risk: Breaking References

**Mitigation**:
- Comprehensive reference search before changes
- Automated reference update script
- Thorough testing after updates
- Keep backup until validated

**Contingency**: Restore from backup, fix references manually

### Medium Risk: Content Loss During Merge

**Mitigation**:
- Review merged files carefully
- Compare line counts (merged ≈ sum of sources)
- Validate all sections present
- Keep backup for comparison

**Contingency**: Re-merge from backup sources

### Low Risk: Naming Confusion

**Mitigation**:
- Document naming convention clearly
- Use consistent patterns
- Add README with file index

**Contingency**: Rename files if confusion persists

## Rollback Plan

If issues arise:

1. **Immediate rollback**:
   ```bash
   mv .opencode/context/core .opencode/context/core.failed
   mv .opencode/context/core.old .opencode/context/core
   ```

2. **Restore references**:
   ```bash
   git checkout .opencode/agent/
   git checkout .opencode/command/
   ```

3. **Analyze failure**:
   - Review error logs
   - Identify missing/broken files
   - Document issues

4. **Fix and retry**:
   - Address identified issues
   - Re-run affected phases
   - Re-test

## Post-Implementation

### Monitoring

1. **Track context loading errors**: Should be 0
2. **Monitor file access patterns**: Identify unused files
3. **Measure context load time**: Should be <1 second

### Maintenance

1. **Enforce naming convention**: All new files follow pattern
2. **Prevent redundancy**: Review before adding new files
3. **Regular audits**: Quarterly review for bloat

### Future Enhancements

1. **Context index**: Auto-generated file index
2. **Dependency graph**: Visualize file relationships
3. **Usage analytics**: Track which files are loaded most

## Appendix A: Complete File Mapping

### Orchestration Directory

| Old Path | New Path | Action |
|----------|----------|--------|
| `system/orchestrator-design.md` | `orchestration/orchestrator.md` | Merge (part 1) |
| `system/orchestrator-guide.md` | `orchestration/orchestrator.md` | Merge (part 2) |
| `system/routing-guide.md` | `orchestration/routing.md` | Merge (part 1) |
| `system/routing-logic.md` | `orchestration/routing.md` | Merge (part 2) |
| `standards/delegation.md` | `orchestration/delegation.md` | Merge (part 1) |
| `workflows/delegation-guide.md` | `orchestration/delegation.md` | Merge (part 2) |
| `system/validation-strategy.md` | `orchestration/validation.md` | Create |
| `system/state-management.md` | `orchestration/state-management.md` | Merge (part 1) |
| `system/artifact-management.md` | `orchestration/state-management.md` | Merge (part 2) |
| `workflows/sessions.md` | `orchestration/sessions.md` | Copy (if used) |

### Formats Directory

| Old Path | New Path | Action |
|----------|----------|--------|
| `standards/subagent-return-format.md` | `formats/subagent-return.md` | Rename |
| `standards/command-output.md` | `formats/command-output.md` | Copy |
| `standards/plan.md` | `formats/plan-format.md` | Rename |
| `standards/report.md` | `formats/report-format.md` | Rename |
| `standards/summary.md` | `formats/summary-format.md` | Rename |
| `standards/frontmatter-standard.md` | `formats/frontmatter.md` | Rename |

### Standards Directory

| Old Path | New Path | Action |
|----------|----------|--------|
| `standards/code.md` | `standards/code-patterns.md` | Merge (part 1) |
| `standards/patterns.md` | `standards/code-patterns.md` | Merge (part 2) |
| `standards/error-handling.md` | `standards/error-handling.md` | Copy |
| `standards/git-safety.md` | `standards/git-safety.md` | Copy |
| `standards/documentation.md` | `standards/documentation.md` | Copy |
| `standards/tests.md` | `standards/testing.md` | Rename |
| `standards/xml-patterns.md` | `standards/xml-structure.md` | Rename |
| `standards/tasks.md` | `standards/task-management.md` | Rename |
| `standards/analysis.md` | `standards/analysis-framework.md` | Rename |

### Workflows Directory

| Old Path | New Path | Action |
|----------|----------|--------|
| `workflows/command-lifecycle.md` | `workflows/command-lifecycle.md` | Copy |
| `workflows/status-transitions.md` | `workflows/status-transitions.md` | Copy |
| `workflows/task-breakdown.md` | `workflows/task-breakdown.md` | Copy |
| `workflows/review.md` | `workflows/review-process.md` | Rename |

### Templates Directory

| Old Path | New Path | Action |
|----------|----------|--------|
| `templates/agent-templates.md` | `templates/agent-template.md` | Rename |
| `templates/subagent-template.md` | `templates/subagent-template.md` | Copy |
| `templates/command-template.md` | `templates/command-template.md` | Copy |
| `templates/orchestrator-template.md` | `templates/orchestrator-template.md` | Copy |
| `templates/delegation-context-template.md` | `templates/delegation-context.md` | Rename |
| `templates/state-template.json` | `templates/state-template.json` | Copy |

### Schemas Directory

| Old Path | New Path | Action |
|----------|----------|--------|
| `schemas/frontmatter-schema.json` | `schemas/frontmatter-schema.json` | Copy |
| `templates/subagent-frontmatter-template.yaml` | `schemas/subagent-frontmatter.yaml` | Move |

### Files to Delete

| File | Reason |
|------|--------|
| `standards/command-argument-handling.md` | Obsolete (command refactor) |
| `standards/command-structure.md` | Redundant with template |
| `standards/commands.md` | Redundant with template |
| `standards/subagent-structure.md` | Redundant with template |
| `system/context-loading-strategy.md` | Merge into orchestrator.md |
| `system/self-healing-guide.md` | Obsolete or project-specific |

### Files to Move (Meta-Builder)

| Old Path | New Path |
|----------|----------|
| `standards/domain-patterns.md` | `project/meta/domain-patterns.md` |
| `standards/architecture-principles.md` | `project/meta/architecture-principles.md` |
| `templates/meta-guide.md` | `project/meta/meta-guide.md` |
| `workflows/interview-patterns.md` | `project/meta/interview-patterns.md` |

## Appendix B: Reference Update Examples

### Example 1: Orchestrator Agent

**Before**:
```markdown
context_loading:
  required:
    - "core/system/routing-guide.md"
    - "core/system/routing-logic.md"
    - "core/system/validation-rules.md"
    - "core/workflows/delegation-guide.md"
    - "core/standards/command-argument-handling.md"
```

**After**:
```markdown
context_loading:
  required:
    - "core/orchestration/routing.md"
    - "core/orchestration/validation.md"
    - "core/orchestration/delegation.md"
```

**Changes**:
- Merged routing files: 2 → 1
- Merged delegation files: 2 → 1
- Removed obsolete file: command-argument-handling.md
- Updated directory: system/ → orchestration/

### Example 2: Researcher Subagent

**Before**:
```markdown
context_loading:
  required:
    - "core/standards/delegation.md"
    - "core/system/state-management.md"
    - "core/system/artifact-management.md"
```

**After**:
```markdown
context_loading:
  required:
    - "core/orchestration/delegation.md"
    - "core/orchestration/state-management.md"
```

**Changes**:
- Merged state files: 2 → 1
- Updated directory: standards/ → orchestration/
- Updated directory: system/ → orchestration/

### Example 3: Command File

**Before**:
```markdown
See workflow documentation:
- @.opencode/context/core/workflows/delegation-guide.md
- @.opencode/context/core/standards/subagent-return-format.md
- @.opencode/context/core/standards/plan.md
```

**After**:
```markdown
See workflow documentation:
- @.opencode/context/core/orchestration/delegation.md
- @.opencode/context/core/formats/subagent-return.md
- @.opencode/context/core/formats/plan-format.md
```

**Changes**:
- Updated delegation reference
- Updated directory: standards/ → formats/
- Renamed files for consistency

---

## Appendix C: Meta-Builder Integration Requirements

### Critical: /meta Command Must Understand Architecture

The `/meta` command and its subagents are responsible for creating and extending .opencode agent systems. They MUST understand ProofChecker's three-layer delegation architecture to avoid breaking the system.

### Required Context Files for Meta-Builder

When `/meta` is invoked, it MUST load these context files:

**Architecture Understanding**:
- `core/orchestration/architecture.md` - Three-layer delegation pattern
- `core/formats/command-structure.md` - Command files as agents

**Templates**:
- `core/templates/command-template.md` - Must include workflow_execution
- `core/templates/agent-template.md` - Execution subagent structure
- `core/templates/orchestrator-template.md` - Pure router pattern

**Standards**:
- `core/standards/task-management.md` - Task-based vs topic-based patterns
- `core/workflows/command-lifecycle.md` - How commands execute

### Meta-Builder Subagent Requirements

#### agent-generator.md

**MUST understand**:
- Three-layer delegation pattern
- Command files have workflow_execution
- Execution subagents receive parsed context
- Orchestrator is pure router

**When generating**:
- ✅ Command files: Include <workflow_execution> with parsing stages
- ✅ Execution subagents: Expect parsed context, not raw $ARGUMENTS
- ✅ Orchestrator: Keep as pure router, don't add command-specific logic

#### command-creator.md

**MUST understand**:
- Command files are agents, not metadata
- Must include workflow_execution stages
- Must parse $ARGUMENTS
- Must validate and route

**When creating commands**:
- ✅ Include frontmatter with `agent: orchestrator`
- ✅ Include `**Task Input (required):** $ARGUMENTS`
- ✅ Include <workflow_execution> with stages:
  1. ParseAndValidate
  2. ExtractMetadata (if needed)
  3. Delegate
- ✅ Include routing configuration if language-based

#### context-organizer.md

**MUST ensure**:
- `orchestration/architecture.md` exists and is current
- `formats/command-structure.md` exists and is current
- Templates reflect three-layer pattern
- No contradictory documentation

### Pattern Detection for Meta-Builder

When `/meta` analyzes an existing system or creates a new one, it must detect the pattern:

**Task-Based Pattern** (like ProofChecker):
- Commands take task numbers
- Requires TODO.md validation
- Requires metadata extraction
- **→ Use three-layer delegation**
- **→ Command files have workflows**

**Topic-Based Pattern** (like OpenAgents):
- Commands take natural language topics
- No validation needed
- Simple routing
- **→ Use two-layer delegation**
- **→ Command files can be simple metadata**

### Meta-Builder Validation Checklist

When `/meta` creates or modifies the system, validate:

- [ ] Command files have `agent: orchestrator` (for task-based)
- [ ] Command files have <workflow_execution> (for task-based)
- [ ] Command files parse $ARGUMENTS
- [ ] Execution subagents receive parsed context
- [ ] Orchestrator remains pure router
- [ ] Architecture documentation is current
- [ ] Templates match actual implementation
- [ ] No contradictory patterns mixed

### Error Prevention

**Common mistakes meta-builder must avoid**:

1. ❌ Creating command files without workflows (v6.0 mistake)
2. ❌ Using `agent: {subagent}` for task-based commands
3. ❌ Adding argument parsing to orchestrator
4. ❌ Expecting execution subagents to parse $ARGUMENTS
5. ❌ Mixing task-based and topic-based patterns

**Correct patterns**:

1. ✅ Command files have workflows for task-based systems
2. ✅ Use `agent: orchestrator` to delegate to command file
3. ✅ Keep orchestrator as pure router
4. ✅ Command files parse, execution subagents execute
5. ✅ Choose one pattern and stick to it

### Meta-Builder Context Loading

**Minimum context for system generation**:
```yaml
context_loading:
  required:
    - "core/orchestration/architecture.md"
    - "core/formats/command-structure.md"
    - "core/templates/command-template.md"
    - "core/templates/agent-template.md"
    - "core/standards/task-management.md"
```

**Why these files are critical**:
- `architecture.md`: Understand three-layer pattern
- `command-structure.md`: Know command files are agents
- `command-template.md`: See workflow_execution structure
- `agent-template.md`: See execution subagent structure
- `task-management.md`: Distinguish task-based vs topic-based

### Testing Meta-Builder Understanding

After context refactor, test `/meta` with:

1. **Create new command**: `/meta "Create /analyze command for task analysis"`
   - Verify: Command file has workflow_execution
   - Verify: Command file parses $ARGUMENTS
   - Verify: Routes to execution subagent

2. **Extend system**: `/meta "Add support for batch task operations"`
   - Verify: Preserves three-layer pattern
   - Verify: Doesn't modify orchestrator
   - Verify: Creates command file with workflows

3. **Create new system**: `/meta "Create .opencode system for data pipeline management"`
   - Verify: Asks about task-based vs topic-based
   - Verify: Uses appropriate pattern
   - Verify: Generates correct architecture

### Documentation Updates for Meta-Builder

After context refactor, update:

1. **Meta-builder context files** (`.opencode/context/project/meta/`):
   - Add ProofChecker architecture as example
   - Document three-layer pattern
   - Explain when to use each pattern

2. **Meta-builder agent prompts**:
   - Reference `core/orchestration/architecture.md`
   - Load architecture context before generation
   - Validate against architecture principles

3. **Meta-builder templates**:
   - Update command template with workflows
   - Update agent template for execution subagents
   - Add architecture decision guide

---

**End of Context Refactor Plan**

**Next Steps**:
1. Review this plan (especially architecture documentation sections)
2. Approve or request changes
3. Create backup of .opencode/context/core/
4. Begin Phase 1 implementation
5. Create new architecture documentation files
6. Test thoroughly after each phase
7. Verify /meta command understands new architecture
8. Document any deviations from plan
