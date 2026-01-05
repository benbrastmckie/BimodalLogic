# Routing Guide - Lightweight Command Routing Context

**Version**: 1.0  
**Created**: 2025-12-29 (Task 244 Phase 1)  
**Purpose**: Lightweight routing context for orchestrator Stages 1-3 (command parsing and delegation preparation)

---

## Overview

This guide provides the minimal context needed for orchestrator routing decisions (Stages 1-3). It replaces loading heavy context files during routing, reducing context window usage from 60-70% to <15%.

**Usage**: Load this file during orchestrator Stages 1-3 instead of full context system.

---

## Command → Agent Mapping

### Workflow Commands

Commands that follow the 8-stage command-lifecycle.md pattern:

| Command | Agent | Description |
|---------|-------|-------------|
| `/research` | `subagents/researcher` | Conduct research, create reports, update [RESEARCHED] status |
| `/plan` | `subagents/planner` | Create implementation plans, update [PLANNED] status |
| `/implement` | `task-executor` | Execute phased implementation, update [IMPLEMENTED] status |
| `/revise` | `subagents/reviser` | Revise artifacts based on feedback, update status |
| `/task` | `subagents/status-sync-manager` | Create new task entries in TODO.md with atomic state updates |

**Routing Pattern**: Command file frontmatter specifies `agent:` field, orchestrator delegates directly.

### Direct Agent Commands

Commands that invoke agents directly without command-lifecycle.md:

| Command | Agent | Description |
|---------|-------|-------------|
| `/status` | `status-sync-manager` | Synchronize task status across TODO.md and state.json |
| `/commit` | `git-workflow-manager` | Create targeted git commits for task artifacts |

---

## Language-Based Routing

### Language Extraction

Extract language from task entry in TODO.md:

```bash
# Extract language field from task entry
language=$(grep -A 20 "^### ${task_number}\." .opencode/specs/TODO.md | grep "Language" | sed 's/\*\*Language\*\*: //')

# Validate extraction succeeded
if [ -z "$language" ]; then
  language="general"
  echo "[WARN] Language not found for task ${task_number}, defaulting to 'general'"
else
  echo "[INFO] Task ${task_number} language: ${language}"
fi
```

### Language → Agent Routing

| Language | Research Agent | Implementation Agent | Notes |
|----------|---------------|---------------------|-------|
| `lean` | `lean-research-agent` | `lean-implementation-agent` | Lean 4 proof development with LSP/Loogle/LeanSearch |
| `markdown` | `researcher` | `implementer` | Documentation and markdown files |
| `python` | `researcher` | `implementer` | Python code (future: python-specific agents) |
| `general` | `researcher` | `implementer` | Default for unspecified language |

**Critical**: Always extract language explicitly. DO NOT assume language without extraction.

### Routing Validation

Before delegating to agent, verify routing is correct:

```bash
# Validate lean routing
if [ "$language" == "lean" ] && [[ ! "$agent" =~ ^lean- ]]; then
  echo "[FAIL] Routing validation failed: language=lean but agent=${agent}"
  exit 1
fi

# Validate non-lean routing
if [ "$language" != "lean" ] && [[ "$agent" =~ ^lean- ]]; then
  echo "[FAIL] Routing validation failed: language=${language} but agent=${agent}"
  exit 1
fi

echo "[PASS] Routing validation succeeded"
```

### Implementation Status

**Stage 2 (DetermineRouting) Implementation:**
- ✅ Language extraction from state.json (Priority 1)
- ✅ Language extraction from TODO.md (Priority 2)
- ✅ Default to "general" fallback (Priority 3)
- ✅ Routing table lookup from command frontmatter
- ✅ Agent file existence validation
- ✅ Language/agent capability validation
- ✅ Logging for routing decisions

**Stage 4 (ValidateReturn) Artifact Validation:**
- ✅ Artifacts array non-empty check (prevents phantom research)
- ✅ Artifact file existence check
- ✅ Artifact file non-empty check (size > 0)
- ✅ Validation logging ([PASS]/[FAIL])

**Commands with Language-Based Routing:**
- ✅ /research (lean → lean-research-agent, default → researcher)
- ✅ /implement (lean → lean-implementation-agent, default → implementer)

---

## Delegation Preparation

### Session ID Generation

Generate unique session ID for tracking:

```bash
timestamp=$(date +%s)
random=$(openssl rand -hex 3)
session_id="sess_${timestamp}_${random}"
```

### Delegation Context Structure

```json
{
  "session_id": "sess_1735460684_a1b2c3",
  "delegation_depth": 1,
  "delegation_path": ["orchestrator", "{command}", "{agent}"],
  "timeout": 3600,
  "task_context": {
    "task_number": 244,
    "description": "Phase 1: Context Index and /research Frontmatter Prototype",
    "language": "markdown"
  }
}
```

### Timeout Configuration

| Command | Default Timeout | Max Timeout | Notes |
|---------|----------------|-------------|-------|
| `/research` | 3600s (1 hour) | 7200s (2 hours) | Research can be time-intensive |
| `/plan` | 1800s (30 min) | 3600s (1 hour) | Planning is typically faster |
| `/implement` | 7200s (2 hours) | 14400s (4 hours) | Implementation can be complex |
| `/revise` | 1800s (30 min) | 3600s (1 hour) | Revisions are typically focused |

### Delegation Safety

**Max Delegation Depth**: 3 levels

```
Level 0: User
Level 1: Orchestrator → Command
Level 2: Command → Agent
Level 3: Agent → Utility (status-sync-manager, git-workflow-manager)
```

**Cycle Detection**: Track delegation_path to prevent cycles.

**Timeout Enforcement**: Monitor deadline, recover partial results on timeout.

---

## Command Argument Parsing

### Standard Argument Pattern

Most commands follow this pattern:

```
/{command} TASK_NUMBER [ADDITIONAL_ARGS]
```

Examples:
- `/research 244`
- `/research 244 "Focus on routing patterns"`
- `/plan 244 --phased`
- `/implement 244`

### Argument Extraction

```bash
# Extract task number (first argument)
task_number=$(echo "$ARGUMENTS" | awk '{print $1}')

# Extract remaining arguments (optional)
remaining_args=$(echo "$ARGUMENTS" | cut -d' ' -f2-)

# Validate task number is integer
if ! [[ "$task_number" =~ ^[0-9]+$ ]]; then
  echo "[FAIL] Task number must be an integer. Got: ${task_number}"
  exit 1
fi

# Verify task exists in TODO.md
if ! grep -q "^### ${task_number}\." .opencode/specs/TODO.md; then
  echo "[FAIL] Task ${task_number} not found in TODO.md"
  exit 1
fi
```

### Flag Parsing

Some commands support flags:

| Command | Flag | Description |
|---------|------|-------------|
| `/research` | `--divide` | Subdivide research into multiple topics |
| `/plan` | `--phased` | Create phased implementation plan |
| `/implement` | `--resume` | Resume from incomplete phase |

---

## Status Transitions

### Status Markers

Commands update task status using text-based markers:

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

### Status Update Delegation

**CRITICAL**: Status updates MUST be delegated to status-sync-manager for atomic synchronization.

```json
{
  "agent": "status-sync-manager",
  "task_number": 244,
  "new_status": "researched",
  "timestamp": "2025-12-29T08:13:37Z",
  "artifacts": [
    ".opencode/specs/244_phase_1_context_index_and_research_frontmatter_prototype/reports/research-001.md"
  ]
}
```

**DO NOT** update TODO.md or state.json directly. Always delegate to status-sync-manager.

---

## Error Handling

### Common Routing Errors

| Error | Cause | Resolution |
|-------|-------|------------|
| Task not found | Task number doesn't exist in TODO.md | Verify task number, check TODO.md |
| Invalid language | Language extraction failed | Default to "general", log warning |
| Routing mismatch | Language doesn't match agent | Abort with validation error |
| Missing agent | Command frontmatter missing `agent:` field | Add frontmatter to command file |
| Delegation cycle | Agent tries to delegate back to caller | Abort with cycle detection error |
| Timeout exceeded | Agent execution exceeds timeout | Recover partial results, log timeout |

### Error Response Format

```json
{
  "status": "failed",
  "summary": "Routing failed: Task 244 not found in TODO.md",
  "errors": [{
    "type": "validation",
    "message": "Task 244 not found in TODO.md",
    "code": "TASK_NOT_FOUND",
    "recoverable": false,
    "recommendation": "Verify task number exists in .opencode/specs/TODO.md"
  }],
  "metadata": {
    "session_id": "sess_1735460684_a1b2c3",
    "agent_type": "orchestrator",
    "delegation_depth": 0
  }
}
```

---

## Context Loading Strategy

### Routing Stage (Stages 1-3)

**Load**: This file only (routing-guide.md)

**DO NOT Load**:
- subagent-return-format.md (11KB)
- subagent-delegation-guide.md (18KB)
- status-markers.md (27KB)
- command-lifecycle.md (15KB)

**Rationale**: Routing decisions don't require detailed workflow context. Load only what's needed for command parsing and agent selection.

### Execution Stage (Stage 4+)

**Load**: Context files needed for specific workflow

See `.opencode/context/index.md` for execution context loading patterns.

---

## Quick Reference

### Routing Checklist

- [ ] Parse command and extract task number
- [ ] Validate task exists in TODO.md
- [ ] Extract language from task entry
- [ ] Determine target agent based on command + language
- [ ] Validate routing (language matches agent)
- [ ] Generate session ID
- [ ] Prepare delegation context
- [ ] Set timeout based on command type
- [ ] Check delegation depth < 3
- [ ] Delegate to agent

### Context Budget

- **Routing Stage**: <10% context window (this file only, ~200 lines)
- **Execution Stage**: 90% context window available (selective loading)

---

## Troubleshooting

### Phantom Research (Status Updated but No Artifacts)

**Symptom:** Task status shows [RESEARCHED] but no research report exists.

**Root Cause:** Agent returned status="completed" without creating artifacts.

**Detection:** Stage 4 artifact validation catches this:
```
[FAIL] Agent returned 'completed' status but created no artifacts
Error: Phantom research detected: status=completed but no artifacts
```

**Prevention:** Orchestrator Stage 4 now validates:
1. Artifacts array is non-empty (if status=completed)
2. All artifact files exist on disk
3. All artifact files are non-empty (size > 0)

**Recovery:**
1. Reset task status to [NOT STARTED]
2. Re-run command: `/research {task_number}`
3. Verify artifacts created after completion

### Language Routing Mismatch

**Symptom:** Lean task routed to general researcher (or vice versa).

**Root Cause:** Language extraction failed or routing validation skipped.

**Detection:** Stage 2 routing validation catches this:
```
[FAIL] Routing validation failed: language=lean but agent=researcher
Error: Routing mismatch: Lean task must route to lean-* agent
```

**Prevention:** Orchestrator Stage 2 now validates:
1. If language="lean": Agent must start with "lean-"
2. If language!="lean": Agent must NOT start with "lean-"

**Recovery:**
1. Verify **Language** field in TODO.md task entry
2. Verify routing configuration in command frontmatter
3. Re-run command after fixing language field

### Language Extraction Failed

**Symptom:** Warning message "Language not found for task {N}, defaulting to 'general'".

**Root Cause:** Task entry missing **Language** field in TODO.md.

**Detection:** Stage 2 language extraction logs warning:
```
[WARN] Language not found for task 258, defaulting to 'general'
```

**Fix:**
1. Add **Language** field to task entry in TODO.md:
   ```markdown
   ### 258. Resolve Truth.lean sorries
   - **Status**: [NOT STARTED]
   - **Language**: lean
   - **Priority**: High
   ```
2. Re-run command

### Agent File Not Found

**Symptom:** Error "Agent file not found: {agent}".

**Root Cause:** Routing configuration references non-existent agent.

**Detection:** Stage 2 agent file validation:
```
[FAIL] Agent file not found: lean-research-agent
```

**Fix:**
1. Verify agent file exists: `.opencode/agent/subagents/{agent}.md`
2. Fix routing configuration in command frontmatter
3. Create missing agent file if needed

### Routing Logs

**Example successful routing (Lean task):**
```
[INFO] Task 258 language: lean
[INFO] Routing to lean-research-agent (language=lean)
[PASS] Routing validation succeeded
```

**Example successful routing (Markdown task):**
```
[INFO] Task 256 language: markdown
[INFO] Routing to researcher (language=markdown)
[PASS] Routing validation succeeded
```

**Example failed routing (mismatch):**
```
[INFO] Task 258 language: lean
[INFO] Routing to researcher (language=lean)
[FAIL] Routing validation failed: language=lean but agent=researcher
Error: Routing mismatch: Lean task must route to lean-* agent
```

---

**End of Routing Guide**
