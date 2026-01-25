# Checkpoint-in-Commands Pattern

**Version**: 1.0
**Created**: 2026-01-25
**Purpose**: Document the architectural decision to place checkpoints in commands, not skills
**Audience**: Command developers, /meta agent

---

## Overview

All workflow commands follow a three-checkpoint pattern where the COMMAND handles all state management operations. Skills are thin wrappers that only delegate to subagents.

```
┌─────────────────────────────────────────────────────────────┐
│  CHECKPOINT 1    →    STAGE 2    →    CHECKPOINT 2    →    │
│   GATE IN             DELEGATE         GATE OUT            │
│  (Preflight)        (Skill/Agent)    (Postflight)          │
│                                                 ↓          │
│                                          CHECKPOINT 3      │
│                                            COMMIT          │
└─────────────────────────────────────────────────────────────┘
```

---

## Rationale

### Why Commands, Not Skills?

1. **Reliability**: Command code always executes. Skill postflight code may not execute due to Claude Code Issue #17351.

2. **Separation of Concerns**: Commands handle workflow (state, artifacts, git). Skills handle delegation (invoke subagent, return result).

3. **Uniformity**: All commands follow the same checkpoint pattern regardless of which skill they invoke.

4. **Observability**: Checkpoints are visible in command files, not scattered across skills.

### Industry Validation

Research (Task #676, research-004.md) identified 9 industry patterns that support this approach:

| Pattern | Alignment |
|---------|-----------|
| API Gateway | Commands = gateway layer, checkpoints = cross-cutting concerns |
| Command Pattern | Commands are invokers; skills are receivers |
| CQRS | Commands handle writes (state updates) |
| Workflow Orchestration | Setup/teardown at workflow (command) level |
| SRP | Skills focus on single responsibility (delegation) |

---

## Checkpoint Structure

### CHECKPOINT 1: GATE IN (Preflight)

**Purpose**: Validate inputs and update status to "in progress"

**Operations**:
1. Generate session_id
2. Parse and validate arguments
3. Lookup task in state.json
4. Validate status allows operation
5. Extract task metadata
6. Create task directory (if needed)
7. Update state.json to "{operation}ing" status
8. Update TODO.md to [{OPERATION}ING]

**On Failure**: Return error immediately. Do not modify state.

### STAGE 2: DELEGATE

**Purpose**: Invoke skill to execute the operation

**Operations**:
1. Invoke Skill tool with:
   - task_number
   - session_id
   - task_dir
   - Operation-specific parameters

2. Skill invokes subagent via Task tool

3. Subagent:
   - Executes work
   - Creates artifacts
   - Writes metadata to `{task_dir}/.meta/{operation}-return-meta.json`
   - Returns brief text summary

**On Failure**: Skill returns error text. Command proceeds to GATE OUT with error handling.

### CHECKPOINT 2: GATE OUT (Postflight)

**Purpose**: Process results and update status to "completed"

**Operations**:
1. Read metadata file from `{task_dir}/.meta/{operation}-return-meta.json`
2. Validate required fields (status, summary, artifacts)
3. Verify artifacts exist on disk
4. Update state.json:
   - Change status to "{operation}ed" or keep "{operation}ing" if partial
   - Add completion fields (completion_summary, etc.)
5. Update TODO.md:
   - Change marker to [{OPERATION}ED] or keep [{OPERATION}ING]
   - Add artifact links
6. Link artifacts to state.json artifacts array
7. Clean up metadata file

**On Failure**: Keep status as "{operation}ing" for retry.

### CHECKPOINT 3: COMMIT

**Purpose**: Create git commit tracking the operation

**Operations**:
```bash
git add -A
git commit -m "$(cat <<'EOF'
task {N}: {action}

Session: {session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

**On Failure**: Non-blocking. Log error and continue.

---

## Metadata File Exchange

Commands and subagents communicate via metadata files:

### Location
```
specs/{N}_{SLUG}/.meta/{operation}-return-meta.json
```

### Schema
```json
{
  "status": "researched|planned|implemented|partial|failed",
  "summary": "Brief text summary (<100 tokens)",
  "artifacts": [
    {
      "type": "research|plan|summary|implementation",
      "path": "relative/path/to/artifact.md",
      "summary": "Brief description of artifact"
    }
  ],
  "completion_data": {
    "completion_summary": "1-3 sentence description",
    "claudemd_suggestions": "For meta tasks: description of .claude/ changes or 'none'",
    "roadmap_items": ["For non-meta tasks: explicit roadmap items"]
  },
  "metadata": {
    "session_id": "sess_...",
    "agent_type": "general-research-agent",
    "duration_seconds": 123
  }
}
```

### Lifecycle
1. Command creates task directory with `.meta/` subdirectory
2. Skill passes `metadata_file_path` to subagent
3. Subagent writes metadata file before returning
4. Command reads metadata file in GATE OUT
5. Command deletes metadata file after processing

---

## Command Template

```markdown
---
description: {description}
allowed-tools: Skill, Bash(jq:*), Bash(git:*), Bash(mkdir:*), Bash(date:*), Bash(od:*), Bash(tr:*), Read, Edit
argument-hint: TASK_NUMBER
model: claude-opus-4-5-20251101
---

# /{command} Command

{Description of command}

## Arguments

- `$1` - Task number (required)

## Execution

### CHECKPOINT 1: GATE IN (Preflight)

1. **Generate Session ID**
2. **Parse Arguments**
3. **Lookup Task**
4. **Validate Task Exists**
5. **Validate Status**
6. **Extract Task Metadata**
7. **Create Task Directory**
8. **Preflight Status Update**

### STAGE 2: DELEGATE

Invoke skill with inputs.

### CHECKPOINT 2: GATE OUT (Postflight)

1. **Read Metadata File**
2. **Validate Required Fields**
3. **Verify Artifacts**
4. **Postflight Status Update**
5. **Link Artifacts**
6. **Cleanup Metadata File**

### CHECKPOINT 3: COMMIT

Git commit with session ID.

## Error Handling

{Error handling guidance}
```

---

## Migration from Skill-Based Checkpoints

If migrating existing skills that have checkpoint code:

1. **Identify checkpoint code** in skill (status updates, artifact linking, git commits)
2. **Move to command** GATE IN and GATE OUT sections
3. **Simplify skill** to thin wrapper pattern
4. **Update skill** to pass `metadata_file_path` to subagent
5. **Verify** command handles all state management

---

## Related Documentation

- @.claude/context/core/patterns/thin-wrapper-skill.md - Skill pattern
- @.claude/context/core/formats/subagent-return.md - Metadata file schema
- @.claude/CLAUDE.md - Checkpoint-Based Execution Model section
- @specs/676_investigate_skill_registration_integrate_task_command/reports/research-004.md - Industry validation
