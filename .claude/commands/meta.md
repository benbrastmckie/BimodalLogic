---
description: Interactive system builder that creates TASKS for agent architecture changes (never implements directly)
allowed-tools: Skill, Bash(jq:*), Bash(git:*), Bash(mkdir:*), Bash(date:*), Bash(od:*), Bash(tr:*), Read, Edit
argument-hint: [PROMPT] | --analyze
model: claude-opus-4-5-20251101
---

# /meta Command

Interactive system builder that delegates to `skill-meta` for creating TASKS for .claude/ system changes. This command NEVER implements changes directly - it only creates tasks.

## Arguments

- No args: Start interactive interview (7 stages)
- `PROMPT` - Direct analysis of change request (abbreviated flow)
- `--analyze` - Analyze existing .claude/ structure (read-only)

## Constraints

**FORBIDDEN** - This command MUST NOT:
- Directly create commands, skills, rules, or context files
- Directly modify CLAUDE.md or ARCHITECTURE.md
- Implement any work without user confirmation
- Write any files outside specs/

**REQUIRED** - This command MUST:
- Track all work via tasks in TODO.md + state.json
- Require explicit user confirmation before creating any tasks
- Create task directories for each task
- Delegate execution to skill-meta

## Execution

### CHECKPOINT 1: GATE IN (Preflight)

1. **Generate Session ID**
   ```bash
   session_id="sess_$(date +%s)_$(od -An -N3 -tx1 /dev/urandom | tr -d ' ')"
   ```

2. **Determine Mode**
   ```bash
   args="$ARGUMENTS"

   if [ -z "$args" ]; then
     mode="interactive"
     prompt=""
   elif [ "$args" = "--analyze" ]; then
     mode="analyze"
     prompt=""
   else
     mode="prompt"
     prompt="$args"
   fi
   ```

3. **Create Meta Directory** (for metadata file)
   ```bash
   mkdir -p specs/.meta
   ```

**On GATE IN success**: Mode determined. **IMMEDIATELY CONTINUE** to STAGE 2 below.

### STAGE 2: DELEGATE

**EXECUTE NOW**: After CHECKPOINT 1 passes, immediately invoke the Skill tool.

**Invoke the Skill tool NOW** with:
```
skill: "skill-meta"
args: "mode={mode} session_id={session_id} prompt={prompt}"
```

The skill will spawn `meta-builder-agent` which:
- **Interactive mode**: Runs 7-stage interview with user confirmation
- **Prompt mode**: Analyzes request and proposes task breakdown
- **Analyze mode**: Inventories existing components and provides recommendations

**On DELEGATE success**: Skill returns text summary. **IMMEDIATELY CONTINUE** to CHECKPOINT 2 below.

### CHECKPOINT 2: GATE OUT (Postflight)

1. **Read Metadata File**
   ```bash
   metadata_file="specs/.meta/meta-return-meta.json"

   if [ ! -f "$metadata_file" ]; then
     echo "Error: Meta metadata file not found at $metadata_file"
     echo "The skill may have failed to complete properly"
     exit 1
   fi

   # Extract metadata
   meta_status=$(jq -r '.status // "unknown"' "$metadata_file")
   meta_summary=$(jq -r '.summary // ""' "$metadata_file")
   tasks_created=$(jq -r '.metadata.tasks_created // 0' "$metadata_file")
   result_mode=$(jq -r '.metadata.mode // "unknown"' "$metadata_file")
   ```

2. **Validate Required Fields**
   ```bash
   if [ "$meta_status" = "unknown" ] || [ -z "$meta_status" ]; then
     echo "Error: Missing or invalid status in meta metadata"
     exit 1
   fi

   if [ -z "$meta_summary" ]; then
     echo "Error: Missing summary in meta metadata"
     exit 1
   fi
   ```

3. **Process Based on Status**

   **If meta_status is "tasks_created" or "completed"**:
   Proceed to CHECKPOINT 3 for git commit (if tasks were created).

   **If meta_status is "analyzed"**:
   No tasks created, no commit needed. Skip to output.

   **If meta_status is "cancelled"**:
   User cancelled, no commit needed. Skip to output.

4. **Cleanup Metadata File**
   ```bash
   rm -f "$metadata_file"
   ```

**On GATE OUT success**: Results processed. **IMMEDIATELY CONTINUE** to CHECKPOINT 3 below (if tasks created).

### CHECKPOINT 3: COMMIT (if tasks created)

Only commit if tasks were created (status is "tasks_created"):

```bash
if [ "$meta_status" = "tasks_created" ] && [ "$tasks_created" -gt 0 ]; then
  git add -A
  git commit -m "$(cat <<'EOF'
meta: create {tasks_created} task(s)

Session: {session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
fi
```

Commit failure is non-blocking (log and continue).

## Output

### Tasks Created

```
## Tasks Created

Created {tasks_created} task(s):

{task list from summary}

**Next Steps**:
1. Review tasks in TODO.md
2. Run `/research {first_task_number}` to begin research on first task
3. Progress through /research -> /plan -> /implement cycle
```

### Analysis Output

```
## Current .claude/ Structure

{analysis summary from agent}

**Recommendations**:
{recommendations from agent}
```

### User Cancelled

```
Task creation cancelled. No tasks were created.
Run /meta again when ready.
```

## Modes Summary

### Interactive Mode (no arguments)

Full 7-stage interview:
1. DetectExistingSystem - Inventory current components
2. InitiateInterview - Explain process
3. GatherDomainInfo - Purpose and scope questions
4. IdentifyUseCases - Task breakdown
5. AssessComplexity - Effort and priority
6. ReviewAndConfirm - Mandatory confirmation
7. CreateTasks - Update TODO.md and state.json

Uses AskUserQuestion for multi-turn conversation.

### Prompt Mode (with text argument)

Abbreviated flow:
1. Parse prompt for keywords and intent
2. Check for related existing tasks
3. Propose task breakdown
4. Confirm with user
5. Create tasks

Example: `/meta "add a new command for exporting logs"`

### Analyze Mode (--analyze)

Read-only system analysis:
- Inventory all commands, skills, agents, rules
- Count active tasks
- Provide recommendations
- No tasks created

Example: `/meta --analyze`

## Error Handling

### GATE IN Failure
- Invalid arguments: Return error with usage

### DELEGATE Failure
- Skill fails: Report error
- Timeout: Partial progress may be lost for interactive mode

### GATE OUT Failure
- Missing metadata file: Report error
- Invalid status: Report error
