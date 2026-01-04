# .opencode Quick Start Guide

**Version**: 2.0  
**Status**: Active  
**Created**: 2025-12-26

---

## Getting Started

### Prerequisites

1. **Git Repository**: The .opencode system requires a git repository
2. **Lean 4 Projects** (optional): Install lean-lsp-mcp for Lean-specific features
   ```bash
   uvx lean-lsp-mcp
   ```
3. **MCP Configuration**: Ensure .mcp.json is configured (if using Lean tools)

### Your First Task

Create a task using the `/task` command:

```
/task Implement feature X with Y functionality
```

This will:
- Assign a unique task number (e.g., 191)
- Create entry in TODO.md with [NOT STARTED] status
- Update state.json
- Return task number to you

---

## Common Workflows

### Workflow 1: Simple Task (No Plan)

For simple tasks that don't need a detailed plan:

```
1. /task Fix typo in README.md
   → Returns: "Created task 192"

2. /implement 192
   → Executes implementation directly
   → Creates git commit
   → Updates status to [COMPLETED]
```

**When to use**: Tasks under 1 hour, clear requirements, no research needed

### Workflow 2: Complex Task (With Research and Plan)

For complex tasks requiring research and planning:

```
1. /task Integrate LeanSearch API for proof search
   → Returns: "Created task 193"

2. /research 193
   → Conducts research on LeanSearch API
   → Creates research report and summary
   → Updates status to [RESEARCHED]
   → Creates git commit

3. /plan 193
   → Harvests research findings
   → Creates phased implementation plan
   → Updates status to [PLANNED]
   → Creates git commit

4. /implement 193
   → Executes plan phase by phase
   → Creates git commit per phase
   → Updates status to [COMPLETED]
```

**When to use**: Tasks over 2 hours, unclear requirements, needs research

### Workflow 3: Resuming Interrupted Work

If implementation times out or is interrupted:

```
1. /implement 193
   → Starts implementation
   → Completes phases 1-2
   → Times out after 2 hours
   → Returns: "Partial completion. Resume with /implement 193"

2. /implement 193
   → Checks plan file for completed phases
   → Resumes from phase 3
   → Continues until complete or timeout
```

**Resume logic**: The system automatically detects completed phases and resumes from the first incomplete phase.

### Workflow 4: Error Analysis and Fixing

When errors occur, analyze and create fix plans:

```
1. /errors
   → Analyzes errors.json
   → Groups errors by type and root cause
   → Checks historical fix effectiveness
   → Creates fix plan
   → Creates TODO task for fixes
   → Returns: "Created task 194 to fix 5 delegation_hang errors"

2. /implement 194
   → Executes fix plan
   → Resolves errors
   → Updates errors.json with fix status
```

**Error types**: delegation_hang, timeout, status_sync_failure, git_commit_failure, tool_unavailable, build_error

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

## Command Reference

### /task - Create Tasks

**Syntax**: `/task <description>`

**Purpose**: Create a new task in TODO.md

**Example**:
```
/task Implement proof search caching with memoization
```

**Returns**: Task number

**Options**:
- Automatically detects language from description
- Assigns priority based on keywords (critical, urgent, etc.)

---

### /research - Conduct Research

**Syntax**: `/research <task_number> [--divide]`

**Purpose**: Research a topic and create detailed report

**Example**:
```
/research 195
/research 195 --divide  # Subdivide topic into subtopics
```

**Returns**: Research report and summary paths

**Output**:
- `.opencode/specs/{task_number}_{topic}/reports/research-001.md`
- `.opencode/specs/{task_number}_{topic}/summaries/research-summary.md`

**Status Change**: [NOT STARTED] → [RESEARCHED]

**Git Commit**: `task {number}: research completed`

---

### /plan - Create Implementation Plan

**Syntax**: `/plan <task_number>`

**Purpose**: Create phased implementation plan

**Example**:
```
/plan 195
```

**Returns**: Plan path with phase breakdown

**Output**:
- `.opencode/specs/{task_number}_{topic}/plans/implementation-001.md`

**Status Change**: [RESEARCHED] → [PLANNED] (or [NOT STARTED] → [PLANNED])

**Git Commit**: `task {number}: plan created`

**Plan Structure**:
- Metadata (effort, language, type)
- Overview (problem, scope, constraints)
- Phases (each 1-2 hours)
- Testing and validation
- Rollback/contingency

---

### /implement - Execute Implementation

**Syntax**: `/implement <task_number>` or `/implement <start>-<end>`

**Purpose**: Execute implementation with resume support

**Examples**:
```
/implement 195           # Single task
/implement 195-197       # Range of tasks (sequential)
```

**Returns**: Implementation summary and artifacts

**Status Change**: [PLANNED] → [COMPLETED] (or [NOT STARTED] → [COMPLETED] for simple tasks)

**Git Commits**:
- Per phase: `task {number} phase {N}: {phase_description}`
- Full task: `task {number}: {task_description}`

**Resume Support**:
- Checks plan file for completed phases
- Resumes from first [NOT STARTED] or [IN PROGRESS] phase
- Handles timeouts gracefully with partial results

**Timeout**: 7200s (2 hours) - returns partial results if exceeded

---

### /revise - Revise Plan

**Syntax**: `/revise <task_number>`

**Purpose**: Create new plan version without changing task status

**Example**:
```
/revise 195
```

**Returns**: New plan version path

**Output**:
- `.opencode/specs/{task_number}_{topic}/plans/implementation-002.md`

**Status Change**: None (preserves current status)

**Git Commit**: `task {number}: plan revised to v{N}`

**Use Cases**:
- Plan needs adjustment after starting implementation
- New information discovered during research
- Scope changed

---

### /review - Analyze Codebase

**Syntax**: `/review`

**Purpose**: Analyze codebase and update registries

**Example**:
```
/review
```

**Returns**: Analysis summary and created tasks

**Updates**:
- `IMPLEMENTATION_STATUS.md`
- `SORRY_REGISTRY.md`
- `TACTIC_REGISTRY.md`
- `FEATURE_REGISTRY.md`

**Creates Tasks**: For identified work (missing tests, incomplete features, etc.)

**Git Commit**: `review: update registries and create tasks`

---

### /todo - Maintain TODO.md

**Syntax**: `/todo`

**Purpose**: Clean completed and abandoned tasks from TODO.md

**Example**:
```
/todo
```

**Returns**: Number of tasks cleaned

**Behavior**:
- Scans for [COMPLETED] and [ABANDONED] tasks
- Confirms with user if > 5 tasks to remove
- Removes from TODO.md
- Updates state.json
- Preserves task numbering (no renumbering)

**Git Commit**: `todo: clean {N} completed tasks`

---

### /errors - Analyze Errors

**Syntax**: `/errors [--all] [--type <type>]`

**Purpose**: Analyze errors.json and create fix plans

**Examples**:
```
/errors                    # Analyze unaddressed errors only
/errors --all              # Analyze all errors
/errors --type timeout     # Filter to specific error type
```

**Returns**: Error analysis and fix plan task number

**Process**:
1. Groups errors by type and root cause
2. Checks historical fix effectiveness
3. Identifies recurring errors
4. Recommends specific fixes
5. Creates implementation plan for fixes
6. Creates TODO task linking fix plan
7. Updates errors.json with fix references

**Git Commit**: `errors: create fix plan for {N} {type} errors (task {number})`

---

## Troubleshooting

### Issue: Delegation Hangs

**Symptom**: Command invokes subagent but never returns

**Cause**: Missing ReceiveResults stage or timeout not set (should not happen in v2.0)

**Fix**:
1. Check command has ReceiveResults stage
2. Verify timeout is set (default 3600s)
3. Check subagent returns standardized format
4. Report issue if occurs (this is a critical bug)

**Prevention**: All v2.0 commands follow standard delegation pattern with explicit return handling

---

### Issue: Tool Unavailable

**Symptom**: "lean-lsp-mcp not available" error

**Cause**: lean-lsp-mcp not installed or not configured in .mcp.json

**Fix**:
```bash
# Install lean-lsp-mcp
uvx lean-lsp-mcp

# Verify .mcp.json configuration
cat .mcp.json
```

**Graceful Degradation**: Lean agents fall back to direct file modification if tool unavailable

---

### Issue: Git Commit Failures

**Symptom**: "Git commit failed" in return message

**Cause**: Nothing to commit, merge conflict, or git not configured

**Fix**:
```bash
# Check git status
git status

# Check git configuration
git config user.name
git config user.email

# Manual commit if needed
git add <files>
git commit -m "task {number}: {description}"
```

**Non-Blocking**: Git commit failures are logged but do NOT fail the task

---

### Issue: Status Sync Failures

**Symptom**: "Status sync failed" error

**Cause**: Concurrent file updates or file I/O error

**Fix**:
1. Retry the command (status-sync-manager has retry logic)
2. Check file permissions on TODO.md and state.json
3. Check for file locks or concurrent processes

**Recovery**: status-sync-manager uses two-phase commit with rollback on failure

---

### Issue: Timeout During Implementation

**Symptom**: "Implementation timed out after 7200s"

**Cause**: Task too complex for 2-hour timeout

**Fix**:
1. Resume with `/implement {number}` (continues from last completed phase)
2. Break task into smaller phases (revise plan)
3. Increase timeout (future enhancement)

**Partial Results**: Timeout returns partial results with completed phases

---

## Tips and Best Practices

### 1. Use Research for Unfamiliar Topics

Always research before planning for topics you're not familiar with:
```
/task Integrate new API
/research {number}      # Research API first
/plan {number}          # Plan based on research
/implement {number}     # Execute plan
```

### 2. Break Large Tasks into Phases

Use planning to break large tasks (> 4 hours) into manageable phases:
- Each phase should be 1-2 hours
- Phases should be sequential and logical
- Clear acceptance criteria per phase

### 3. Resume Interrupted Work

Don't restart from scratch if interrupted:
```
/implement {number}     # Times out after phase 2
/implement {number}     # Resumes from phase 3
```

### 4. Analyze Errors Regularly

Run `/errors` periodically to catch recurring issues:
```
/errors                 # Weekly or after major work
```

### 5. Clean TODO.md Periodically

Keep TODO.md manageable by cleaning completed tasks:
```
/todo                   # Monthly or when TODO.md gets long
```

### 6. Use Language Field

Specify language for proper routing:
- Lean tasks get lean-lsp-mcp integration
- General tasks use standard tools

Language is auto-detected but can be specified in task description.

---

## Next Steps

- Read full architecture: `.opencode/ARCHITECTURE.md`
- Review testing guide: `.opencode/TESTING.md`
- Explore delegation patterns: `.opencode/context/core/workflows/subagent-delegation-guide.md`
- Check return format standard: `.opencode/context/core/standards/subagent-return-format.md`

---

## Getting Help

If you encounter issues:

1. Check this guide for troubleshooting
2. Review ARCHITECTURE.md for system details
3. Check errors.json for logged errors
4. Run `/errors` to analyze error patterns
5. Create a task to fix the issue
