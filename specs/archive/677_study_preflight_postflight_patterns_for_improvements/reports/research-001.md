# Research Report: Task #677

**Task**: 677 - Study preflight/postflight patterns for improvements
**Started**: 2026-01-25T22:00:00Z
**Completed**: 2026-01-25T23:45:00Z
**Effort**: 1.75 hours
**Priority**: High
**Dependencies**: Task 675 (research report analyzed)
**Sources/Inputs**:
- Task 675 research report (comprehensive checkpoint bypass analysis)
- Command scripts (.claude/commands/{research,plan,implement}.{sh,md})
- Skill definitions (.claude/skills/{skill-researcher,skill-planner,skill-implementer}/SKILL.md)
- Metadata format documentation (.claude/context/core/formats/return-metadata-file.md)
- State management rules (.claude/rules/state-management.md)
- Checkpoint pattern documentation (.claude/context/core/patterns/checkpoint-execution.md)
- jq escaping workarounds (.claude/context/core/patterns/jq-escaping-workarounds.md)
- Git workflow rules (.claude/rules/git-workflow.md)

**Artifacts**:
- This research report at specs/677_study_preflight_postflight_patterns_for_improvements/reports/research-001.md

**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Root Cause Confirmed**: Commands (.sh files) implement checkpoints inline with simulation code, completely bypassing skills and agents
- **Skill Architecture is Correct**: All skills properly implement skill-internal postflight (11-stage pattern), but are never invoked
- **Dual File Confusion**: .sh executable scripts and .md documentation files exist for same commands, creating implementation-documentation drift
- **Key Finding**: The system is 90% correctly designed but 0% correctly wired - skills exist and work, they're just not called
- **Critical Inefficiency**: Duplicate state update logic in both commands (simulation) and skills (real implementation)
- **Recommended Solution**: Migrate commands from bash scripts to markdown-only skill invocations (3-phase implementation)

## Context & Scope

Task 677 builds on Task 675's findings to identify specific improvements to preflight/postflight patterns that can improve performance and efficiency without adding needless complexity.

Research focuses on:
1. Command preflight patterns and where they fail
2. Skill postflight patterns and why they're bypassed
3. Agent return metadata patterns and validation gaps
4. State synchronization efficiency issues
5. Git commit timing and error handling

The goal is to document the **current state** vs **intended state** and provide a **concrete roadmap** for fixing the checkpoint pattern enforcement.

## Findings

### 1. Command Preflight Patterns

**Current Implementation** (research.sh, plan.sh, implement.sh):

Commands perform preflight inline:

```bash
# Lines 90-127 in research.sh
# Preflight status update
timestamp_iso=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Update state.json
jq --arg num "$task_number" \
   --arg status "researching" \
   --arg ts "$timestamp_iso" \
   '(.active_projects[] | select(.project_number == ($num | tonumber))) |= . + {
     status: $status,
     last_updated: $ts,
     researching: $ts
   }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json

# Update TODO.md
sed -i "s/### ${task_number}\./&\n- **Status**: [RESEARCHING]/" specs/TODO.md
```

**Issues**:
1. **Duplication**: Same logic exists in skill-researcher/SKILL.md (Stage 2)
2. **Coupling**: Commands tightly coupled to state.json schema
3. **Validation**: sed command is fragile (line-based, no validation)
4. **Atomicity**: Two separate file updates, no rollback on partial failure

**Intended Pattern** (from checkpoint-execution.md):

Commands should ONLY:
1. Generate session_id
2. Validate task exists and status allows operation
3. Invoke skill (skill handles preflight)
4. Verify skill completed

**Gap**: Commands do skills' work, making skills redundant.

---

### 2. Skill Postflight Patterns

**Current Implementation** (skill-researcher/SKILL.md):

Skills correctly implement 11-stage pattern:

```
Stage 1: Input Validation
Stage 2: Preflight Status Update (UPDATE state.json, TODO.md)
Stage 3: Create Postflight Marker (specs/.postflight-pending)
Stage 4: Prepare Delegation Context
Stage 5: Invoke Subagent (Task tool with subagent_type)
Stage 6: Parse Metadata File (.return-meta.json)
Stage 7: Update Task Status (Postflight - UPDATE state.json, TODO.md)
Stage 8: Link Artifacts (ADD to state.json.artifacts[])
Stage 9: Git Commit
Stage 10: Cleanup (remove markers, metadata)
Stage 11: Return Brief Summary
```

**Analysis**:
- ✅ Preflight AND postflight in one place (atomic)
- ✅ Postflight marker prevents premature termination
- ✅ Metadata file validation
- ✅ Two-step jq pattern for Issue #1132
- ✅ Non-blocking git commit
- ✅ Cleanup ensures no state leakage

**Problem**: **Skills are never invoked**.

Commands bypass skills entirely:

```bash
# research.sh lines 385-388
# For now, we'll simulate the delegation with a placeholder
# In a real implementation, this would invoke the Task tool
echo "Note: Full delegation implementation requires Task tool integration"
echo "Proceeding with simulation..."
```

**Result**: All skill postflight infrastructure (markers, metadata validation, atomic updates) is unused.

---

### 3. Agent Return Metadata Patterns

**v2 Pattern** (return-metadata-file.md):

Agents write metadata to file:
```json
{
  "status": "researched|planned|implemented|partial|failed",
  "artifacts": [
    {
      "type": "report|plan|summary",
      "path": "specs/677_slug/reports/research-001.md",
      "summary": "Brief 1-sentence description"
    }
  ],
  "next_steps": "Run /plan 677",
  "metadata": {
    "session_id": "sess_1737842000_def456",
    "agent_type": "general-research-agent",
    "duration_seconds": 180,
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "research", "skill-researcher", "general-research-agent"]
  }
}
```

**Skills read and validate**:
```bash
# Stage 6 in skill-researcher
if [ -f "$metadata_file" ] && jq empty "$metadata_file" 2>/dev/null; then
    status=$(jq -r '.status' "$metadata_file")
    artifact_path=$(jq -r '.artifacts[0].path // ""' "$metadata_file")
    artifact_summary=$(jq -r '.artifacts[0].summary // ""' "$metadata_file")
else
    echo "Error: Invalid or missing metadata file"
    status="failed"
fi
```

**Current Reality** (commands bypass this):

Commands create FAKE metadata:
```bash
# research.sh lines 420-430 (simulation code)
metadata_file="$task_dir/.meta/research-return-meta.json"
cat > "$metadata_file" <<EOF
{
  "status": "completed",
  "summary": "Research completed for task #$task_number: $task_description",
  "artifacts": ["$report_file"],
  "session_id": "$session_id",
  "timestamp": "$timestamp_iso"
}
EOF
```

**Issues**:
1. **No validation**: Fake metadata isn't validated against schema
2. **Wrong status**: Uses "completed" instead of "researched" (violates anti-stop pattern)
3. **Missing fields**: No agent_type, delegation_path, or artifact.type
4. **No agent execution**: No real work happened, just stub creation

**Validation Gap**: Commands don't check:
- Metadata schema validity
- Artifact file exists and is non-empty
- session_id matches expected value
- agent_type is correct for language routing

---

### 4. State Synchronization Between TODO.md and state.json

**Current Pattern**:

Commands and skills both update state:

**Commands (preflight)**:
```bash
# Update state.json
jq ... > /tmp/state.json && mv /tmp/state.json specs/state.json

# Update TODO.md
sed -i "s/### ${task_number}\./&\n- **Status**: [RESEARCHING]/" specs/TODO.md
```

**Commands (postflight)**:
```bash
# Update state.json
jq ... > /tmp/state.json && mv /tmp/state.json specs/state.json

# Update TODO.md
sed -i "s/\[RESEARCHING\]/[RESEARCHED]/" specs/TODO.md
```

**Analysis**:

**Inefficiencies**:
1. **Duplicate updates**: Both preflight and postflight touch both files
2. **No atomicity**: If sed fails, state.json is updated but TODO.md isn't
3. **No rollback**: Partial updates leave inconsistent state
4. **Fragile sed**: Line-based pattern matching breaks on format changes

**Two-Phase Update Pattern** (state-management.md):

Documented pattern:
```
1. Read both files
2. Prepare updates in memory
3. Write state.json (machine state)
4. Write TODO.md (user-facing)
5. If either fails, log error
```

**Gap**: Commands don't follow this pattern. Updates are imperative, not transactional.

**Efficiency Improvements Possible**:

1. **Single Update Point**: Skills handle ALL state updates (preflight + postflight)
2. **Atomic Updates**: Use Edit tool for TODO.md (validates before writing)
3. **Rollback Support**: Prepare updates, validate, then write
4. **Idempotency**: Check if artifact already linked before adding

**jq Escaping Issue** (Issue #1132):

Current workaround uses two-step jq:
```bash
# Step 1: Filter out existing research artifacts
jq '(.active_projects[] | select(.project_number == '$task_number')).artifacts =
    [(.active_projects[] | select(.project_number == '$task_number')).artifacts // [] | .[] | select(.type != "research")]' \
  specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json

# Step 2: Add new research artifact
jq --arg path "$artifact_path" \
   --arg type "$artifact_type" \
   --arg summary "$artifact_summary" \
  '(.active_projects[] | select(.project_number == '$task_number')).artifacts += [{"path": $path, "type": $type, "summary": $summary}]' \
  specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

**Inefficiency**: Two jq processes, two file writes.

**Alternative** (not affected by Issue #1132):
```bash
# Use del() instead of map(select(!=))
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "researched" \
   --arg path "$artifact_path" \
   --arg type "$artifact_type" \
   --arg summary "$artifact_summary" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= (
    del(.artifacts[] | select(.type == "research")) |
    . + {
      status: $status,
      last_updated: $ts,
      researched: $ts,
      artifacts: ((.artifacts // []) + [{"path": $path, "type": $type, "summary": $summary}])
    }
  )' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

**Benefit**: Single jq invocation, atomic update.

**Note**: Skills already use two-step pattern correctly. Commands don't need this if they delegate to skills.

---

### 5. Git Commit Timing and Error Handling

**Current Pattern** (research.sh lines 490-507):

```bash
git add -A
git commit -m "$(cat <<EOF
task ${task_number}: complete research

${research_summary}

Session: ${session_id}

Co-Authored-By: OpenCode <noreply@opencode.ai>
EOF
)" 2>/dev/null

if [ $? -eq 0 ]; then
  echo "✓ Research committed successfully"
else
  echo "⚠ Warning: Failed to commit research (non-blocking)"
fi
```

**Analysis**:

**Correct Aspects**:
- ✅ Non-blocking (errors don't fail operation)
- ✅ Session ID included for traceability
- ✅ Commit message follows convention (task {N}: {action})
- ✅ Co-authored attribution

**Issues**:
1. **Silent failure**: `2>/dev/null` hides error details
2. **No error logging**: Failed commits not recorded in errors.json
3. **No retry**: Transient failures (lock conflicts) aren't retried
4. **Timing**: Commits happen in commands, duplicating skill logic

**Skill Pattern** (skill-researcher Stage 9):

```bash
git add -A
git commit -m "task ${task_number}: complete research

Session: ${session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

**No error handling shown** (assumption: non-blocking).

**Recommended Improvements**:

1. **Log commit failures** to errors.json:
```bash
if ! git commit ... 2>&1; then
  error_msg=$(git commit ... 2>&1)
  jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
     --arg sid "$session_id" \
     --arg msg "Git commit failed: $error_msg" \
    '.errors += [{
      "id": ("err_" + ($ts | gsub("[^0-9]"; ""))),
      "timestamp": $ts,
      "type": "git_commit_failure",
      "severity": "low",
      "message": $msg,
      "context": {"session_id": $sid, "command": "/research", "task": '$task_number'},
      "recovery": {"suggested_action": "Manual commit or retry command", "auto_recoverable": false},
      "fix_status": "unfixed"
    }]' specs/errors.json > /tmp/errors.json && mv /tmp/errors.json specs/errors.json
fi
```

2. **Retry transient failures** (lock conflicts):
```bash
commit_with_retry() {
  for i in {1..3}; do
    if git commit -m "$1" 2>&1; then
      return 0
    fi
    sleep 1
  done
  return 1
}
```

3. **Consolidate commit logic**: Skills handle all commits (commands don't commit)

---

### 6. Architectural Assessment: Layer Separation

**Three-Layer Architecture**:

```
Layer 1: Commands (.claude/commands/*.md)
  Role: User-facing entry points
  Should: Validate, invoke skill, verify, commit
  Currently: Do everything inline (bypass Layer 2)

Layer 2: Skills (.claude/skills/*/SKILL.md)
  Role: Orchestration wrappers
  Should: Preflight, delegate, postflight
  Currently: Correctly implemented but NEVER INVOKED

Layer 3: Agents (.claude/agents/*.md)
  Role: Work execution
  Should: Research/plan/implement, create artifacts
  Currently: Correctly implemented but NEVER INVOKED
```

**Intended Execution Flow**:
```
User → Command (GATE IN: validate)
           ↓
       Skill (preflight: update status)
           ↓
       Skill (DELEGATE: invoke agent)
           ↓
       Agent (work: create artifacts, metadata)
           ↓
       Agent (return: brief text summary)
           ↓
       Skill (postflight: read metadata, update state, link artifacts)
           ↓
       Skill (return: brief summary to command)
           ↓
       Command (GATE OUT: verify skill completed)
           ↓
       Command (COMMIT: git commit)
```

**Actual Execution Flow**:
```
User → Command (GATE IN: validate)
           ↓
       Command (preflight: update status)  ← WRONG LAYER
           ↓
       Command (simulate: create stubs)   ← WRONG LAYER
           ↓
       Command (fake metadata)            ← WRONG LAYER
           ↓
       Command (postflight: update status) ← WRONG LAYER
           ↓
       Command (GATE OUT: read fake metadata) ← VALIDATES NOTHING
           ↓
       Command (COMMIT: git commit)
           ↓
       Skills/Agents: NOT EXECUTED
```

**Violations of Separation of Concerns**:

| Responsibility | Should Be In | Currently In | Consequence |
|----------------|--------------|--------------|-------------|
| Preflight status update | Skill | Command | Duplication |
| Agent delegation | Skill | Command (simulated) | No real work |
| Artifact creation | Agent | Command (stub) | Fake results |
| Metadata validation | Skill | Command (skipped) | No validation |
| Postflight status update | Skill | Command | Duplication |
| Artifact linking | Skill | Command | Duplication |
| Git commit | Command | Both | Potential double-commit |

---

### 7. Comparison: Documented vs Implemented Patterns

**Command Documentation** (.claude/commands/research.md):

```markdown
### STAGE 2: DELEGATE

**EXECUTE NOW**: After CHECKPOINT 1 passes, immediately invoke the Skill tool.

**Language-Based Routing**:
| Language | Skill to Invoke |
|----------|-----------------|
| `lean` | `skill-lean-research` |
| `general`, `meta`, `markdown`, `latex` | `skill-researcher` |

**Invoke the Skill tool NOW** with:
task: "Research Task ${task_number}"
prompt: "Research task number ${task_number}..."
subagent_type: "{skill-name from table above}"
```

**Command Implementation** (.claude/commands/research.sh):

```bash
# Language-based routing
case "$task_language" in
  "lean")
    subagent="lean-research-agent"
    ;;
  *)
    subagent="general-research-agent"
    ;;
esac

echo "Delegating to $subagent for $task_language research..."
echo "Note: Full delegation implementation requires Task tool integration"
echo "Proceeding with simulation..."
```

**Gap**: Routing logic exists but delegation is simulated.

**Skill Documentation** (skill-researcher/SKILL.md):

Stage 2: Preflight Status Update
Stage 5: Invoke Subagent via Task tool
Stage 7: Update Task Status (Postflight)
Stage 9: Git Commit

**Skill Implementation**: Same stages correctly implemented.

**Agent Documentation** (general-research-agent.md):

Stage 6: Write Metadata File
Stage 7: Return Brief Text Summary

**Agent Implementation**: Correctly implemented (when invoked).

**Assessment**: Documentation-code mismatch exists ONLY in commands. Skills and agents match their specs.

---

### 8. Efficiency Analysis

**Current System**:

| Operation | Command Overhead | Skill Overhead | Agent Overhead | Total |
|-----------|------------------|----------------|----------------|-------|
| Parse args | 1 bash subprocess | - | - | 1 |
| Validate task | 1 jq call | - | - | 1 |
| Preflight update | 2 writes (state.json, TODO.md) | - | - | 2 |
| Simulate work | 2 writes (report stub, metadata stub) | - | - | 2 |
| Postflight update | 2 writes (state.json, TODO.md) | - | - | 2 |
| Git commit | 1 git subprocess | - | - | 1 |
| **Total** | **9 operations** | **0** | **0** | **9** |

**Correct System** (if skills were invoked):

| Operation | Command Overhead | Skill Overhead | Agent Overhead | Total |
|-----------|------------------|----------------|----------------|-------|
| Parse args | 1 bash subprocess | - | - | 1 |
| Validate task | 1 jq call | - | - | 1 |
| Invoke skill | 1 Skill tool call | - | - | 1 |
| Skill: preflight | - | 2 writes (state.json, TODO.md) | - | 2 |
| Skill: delegate | - | 1 Task tool call | - | 1 |
| Agent: research | - | - | Web/file I/O | N |
| Agent: metadata | - | - | 1 write | 1 |
| Skill: postflight | - | 2 writes (state.json, TODO.md) | - | 2 |
| Skill: artifact link | - | 2 jq calls (Issue #1132 workaround) | - | 2 |
| Skill: commit | - | 1 git subprocess | - | 1 |
| **Total** | **4 operations** | **9 operations** | **N+1** | **13+N** |

**Analysis**:

Current system is **faster** but produces **fake results** (no real research).

Correct system has **overhead** but produces **real results**.

**Optimization Opportunity**: If we migrate to markdown-only commands:

| Operation | Overhead | Notes |
|-----------|----------|-------|
| Parse args | 0 | Claude Code handles |
| Validate task | Skill | Skill reads state.json |
| Invoke skill | 0 | Direct Skill tool call |
| Skill: all operations | Same | 9 operations |
| Agent: work | N+1 | Real research |
| **Total** | **9+N** | **4 fewer than current correct** |

**Benefit**: Eliminating command layer reduces overhead by ~30%.

---

## Decisions

### Decision 1: Recommendation Strategy

**Chosen**: Phased migration approach
**Alternatives Considered**:
- Big-bang replacement (too risky)
- Keep both patterns (maintains technical debt)

**Rationale**: Phased approach allows:
- Incremental validation
- Rollback if issues found
- Learning from first migration (research) before doing others

### Decision 2: Command File Format

**Chosen**: Markdown-only commands (delete .sh files)
**Alternatives Considered**:
- Bash scripts that invoke Claude (subprocess overhead)
- Generate .sh from .md (added complexity)

**Rationale**:
- Aligns with Claude Code's skill model
- Single source of truth (no drift)
- Impossible to bypass skills (no inline logic)
- Simpler architecture

### Decision 3: jq Escaping Workaround

**Chosen**: Keep two-step pattern in skills
**Alternatives Considered**:
- Use del() approach (single jq call)
- Wait for Claude Code fix (marked NOT_PLANNED)

**Rationale**:
- Two-step pattern is proven and working
- Skills already implement it correctly
- del() approach is less clear (harder to maintain)
- Upstream fix unlikely

### Decision 4: State Update Ownership

**Chosen**: Skills own ALL state updates (preflight + postflight)
**Alternatives Considered**:
- Commands do preflight, skills do postflight (split ownership)
- Commands do all updates (current pattern)

**Rationale**:
- Atomic updates (skill handles both in transaction)
- Single responsibility
- Easier to ensure TODO.md/state.json stay synced
- Rollback support (skill can revert both on error)

### Decision 5: Commit Error Handling

**Chosen**: Log failures to errors.json, don't retry
**Alternatives Considered**:
- Retry with exponential backoff
- Fail operation on commit error

**Rationale**:
- Commits are non-blocking (work is done)
- Lock conflicts are rare (single-user system)
- Logging enables manual recovery
- Retry adds complexity for little gain

---

## Recommendations

### Priority Matrix

| Recommendation | Impact | Effort | Complexity | Priority |
|----------------|--------|--------|------------|----------|
| 1. Remove simulation code | High | Low | Low | **P0** |
| 2. Enforce skill delegation | High | Medium | Medium | **P0** |
| 3. Migrate to markdown commands | High | High | Medium | **P1** |
| 4. Add validation guards | Medium | Low | Low | **P1** |
| 5. Improve commit logging | Low | Low | Low | **P2** |
| 6. Optimize jq calls (del) | Low | Medium | Medium | **P3** |

---

### Recommendation 1: Remove Simulation Code (P0)

**Problem**: Commands create stub artifacts instead of invoking skills.

**Solution**: Replace simulation with real skill invocation.

**Implementation**:

Replace this (research.sh lines 385-430):
```bash
# For now, we'll simulate the delegation with a placeholder
echo "Note: Full delegation implementation requires Task tool integration"
echo "Proceeding with simulation..."

# Create a sample research report (FAKE)
report_file="$task_dir/reports/research-$session_id.md"
cat > "$report_file" <<EOF
# Research Report for Task #$task_number
...
EOF

# Create metadata file (FAKE)
metadata_file="$task_dir/.meta/research-return-meta.json"
cat > "$metadata_file" <<EOF
{ "status": "completed", ... }
EOF
```

With this:
```bash
# Invoke skill-researcher
invoke_skill "skill-researcher" \
  task_number="$task_number" \
  session_id="$session_id" \
  focus_prompt="$focus_prompt" \
  language="$task_language"

# Skill handles all postflight internally
# Result is validated metadata file
```

**Benefit**: Real research happens, real artifacts created.

**Effort**: 1 hour (per command, 3 commands total = 3 hours).

---

### Recommendation 2: Enforce Skill Delegation Contract (P0)

**Problem**: Commands can bypass skills silently.

**Solution**: Add validation that skills were actually invoked.

**Implementation**:

After skill invocation, verify postflight marker was created and cleaned up:

```bash
# In CHECKPOINT 2 (GATE OUT)
validate_skill_delegation() {
  local metadata_file="$1"
  local expected_status="$2"

  # Check metadata file exists and is valid JSON
  if ! [ -f "$metadata_file" ] || ! jq empty "$metadata_file" 2>/dev/null; then
    echo "ERROR: Skill did not create valid metadata file"
    echo "This indicates the skill was not invoked or failed"
    exit 1
  fi

  # Check required fields
  if ! jq -e '.status and .artifacts and .metadata.session_id' "$metadata_file" >/dev/null; then
    echo "ERROR: Metadata missing required fields"
    exit 1
  fi

  # Verify status
  actual_status=$(jq -r '.status' "$metadata_file")
  if [ "$actual_status" != "$expected_status" ] && [ "$actual_status" != "partial" ]; then
    echo "ERROR: Unexpected status: $actual_status (expected: $expected_status)"
    exit 1
  fi

  # Verify artifacts exist and are non-empty
  jq -r '.artifacts[].path' "$metadata_file" | while read artifact_path; do
    if ! [ -s "$artifact_path" ]; then
      echo "ERROR: Artifact missing or empty: $artifact_path"
      exit 1
    fi
  done

  # Check postflight marker was cleaned up (proves skill completed postflight)
  if [ -f "specs/.postflight-pending" ]; then
    echo "ERROR: Postflight marker not cleaned up"
    echo "Skill may have failed during postflight operations"
    exit 1
  fi

  return 0
}

# Use in command
validate_skill_delegation "$metadata_file" "researched"
```

**Benefit**: Impossible to bypass skills, enforces correct execution flow.

**Effort**: 2 hours (create library, integrate into 3 commands).

---

### Recommendation 3: Migrate Commands to Markdown-Only (P1)

**Problem**: Dual .sh/.md files create drift, shell scripts enable bypass.

**Solution**: Delete .sh files, make .md files the ONLY command files.

**Implementation**:

Convert research.sh to research.md:

**Before** (.claude/commands/research.sh - 525 lines of bash):
```bash
#!/usr/bin/env bash
set -euo pipefail
# ... full checkpoint implementation inline ...
```

**After** (.claude/commands/research.md - ~80 lines of markdown):
```markdown
---
description: Research a task and create reports
allowed-tools: Skill, Bash(jq:*), Bash(git:*), Read
argument-hint: TASK_NUMBER [FOCUS]
model: claude-opus-4-5-20251101
---

# /research Command

Research a task by delegating to the appropriate research skill.

## Arguments

- `$1` - Task number (required)
- Remaining args - Optional focus/prompt

## Execution

### CHECKPOINT 1: GATE IN

1. Generate session_id
2. Read task from state.json (jq)
3. Validate task exists and status allows research
4. ABORT if validation fails

### STAGE 2: DELEGATE

Invoke skill based on language:
- lean → skill-lean-research
- other → skill-researcher

Use Skill tool with args:
- task_number
- session_id
- focus_prompt
- language

Skill handles ALL work (preflight, delegation, postflight).

### CHECKPOINT 2: GATE OUT

Verify skill completed:
1. Read metadata file
2. Validate schema (required fields present)
3. Verify artifacts exist and are non-empty
4. Confirm postflight marker cleaned up

### CHECKPOINT 3: COMMIT

(Optional - skills handle git commits)
Or: Final verification commit with session ID.

## Output

Display skill's return summary.
```

**Migration Steps**:

1. Add frontmatter to research.md (allowed-tools, model)
2. Simplify GATE IN to just validation (no state updates)
3. Replace DELEGATE simulation with Skill tool call
4. Replace GATE OUT inline updates with validation only
5. Test command works via Claude Code
6. Delete research.sh
7. Repeat for plan.md, implement.md

**Benefit**:
- Single source of truth (no drift)
- Impossible to implement inline logic
- Simpler (80 lines vs 525 lines)
- Natural skill invocation

**Effort**: 6 hours (2 hours per command × 3).

---

### Recommendation 4: Add Checkpoint Guard Rails (P1)

**Problem**: No runtime enforcement prevents checkpoint bypass.

**Solution**: Checkpoint state machine tracks progression.

**Implementation**:

```bash
# Track checkpoint progression
checkpoint_state_file="specs/.checkpoint-state-${session_id}.json"

checkpoint_gate_in() {
  echo '{"checkpoint": "GATE_IN", "session_id": "'$session_id'", "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'", "completed": true}' \
    > "$checkpoint_state_file"
}

checkpoint_delegate() {
  # Verify GATE_IN completed
  if ! jq -e '.checkpoint == "GATE_IN" and .completed == true' "$checkpoint_state_file" >/dev/null 2>&1; then
    echo "ERROR: Cannot DELEGATE - GATE_IN not completed"
    exit 1
  fi

  jq '.checkpoint = "DELEGATE" | .skill_invoked = true | .timestamp = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' \
    "$checkpoint_state_file" > /tmp/checkpoint.json && mv /tmp/checkpoint.json "$checkpoint_state_file"
}

checkpoint_gate_out() {
  # Verify DELEGATE completed
  if ! jq -e '.checkpoint == "DELEGATE" and .skill_invoked == true' "$checkpoint_state_file" >/dev/null 2>&1; then
    echo "ERROR: Cannot GATE_OUT - DELEGATE not completed"
    exit 1
  fi

  jq '.checkpoint = "GATE_OUT" | .postflight_verified = true | .timestamp = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' \
    "$checkpoint_state_file" > /tmp/checkpoint.json && mv /tmp/checkpoint.json "$checkpoint_state_file"
}

checkpoint_commit() {
  # Verify GATE_OUT completed
  if ! jq -e '.checkpoint == "GATE_OUT" and .postflight_verified == true' "$checkpoint_state_file" >/dev/null 2>&1; then
    echo "ERROR: Cannot COMMIT - GATE_OUT not completed"
    exit 1
  fi

  # Cleanup
  rm -f "$checkpoint_state_file"
}
```

**Usage in commands**:
```bash
checkpoint_gate_in
# ... validation ...
checkpoint_delegate
# ... skill invocation ...
checkpoint_gate_out
# ... verification ...
checkpoint_commit
```

**Benefit**: Makes checkpoint bypass impossible, enforces correct flow.

**Effort**: 3 hours (library + integration).

---

### Recommendation 5: Improve Git Commit Logging (P2)

**Problem**: Commit failures are silent, not logged.

**Solution**: Log failures to errors.json, capture error details.

**Implementation**:

```bash
commit_with_logging() {
  local task_num="$1"
  local action="$2"
  local session_id="$3"

  if git add -A && git commit -m "task ${task_num}: ${action}

Session: ${session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>" 2>&1; then
    echo "✓ Committed successfully"
    return 0
  else
    error_msg=$(git commit -m "..." 2>&1)
    echo "⚠ Warning: Commit failed (non-blocking)"

    # Log to errors.json
    jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
       --arg sid "$session_id" \
       --arg msg "Git commit failed: $error_msg" \
       --argjson task "$task_num" \
      '.errors += [{
        "id": ("err_" + ($ts | gsub("[^0-9]"; ""))),
        "timestamp": $ts,
        "type": "git_commit_failure",
        "severity": "low",
        "message": $msg,
        "context": {"session_id": $sid, "command": "/research", "task": $task},
        "recovery": {"suggested_action": "Manual commit or retry", "auto_recoverable": false},
        "fix_status": "unfixed"
      }]' specs/errors.json > /tmp/errors.json && mv /tmp/errors.json specs/errors.json 2>/dev/null || true

    return 1
  fi
}
```

**Benefit**: Commit failures are traceable, errors.json provides recovery guidance.

**Effort**: 1 hour.

---

### Recommendation 6: Optimize jq Calls with del() (P3)

**Problem**: Two-step jq pattern for Issue #1132 requires 2 jq processes.

**Solution**: Use del() approach for single-pass updates.

**Implementation**:

Replace two-step pattern:
```bash
# Step 1: Filter
jq '(.active_projects[] | select(.project_number == '$task_number')).artifacts =
    [... | select(.type != "research")]' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json

# Step 2: Add
jq --arg path "$artifact_path" \
  '(.active_projects[] | select(.project_number == '$task_number')).artifacts += [{"path": $path, "type": "research"}]' \
  specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

With single-step del():
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "researched" \
   --arg path "$artifact_path" \
   --arg type "research" \
   --arg summary "$artifact_summary" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= (
    del(.artifacts[] | select(.type == "research")) |
    . + {
      status: $status,
      last_updated: $ts,
      researched: $ts,
      artifacts: ((.artifacts // []) + [{"path": $path, "type": $type, "summary": $summary}])
    }
  )' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

**Benefit**: 50% fewer jq processes, atomic update.

**Risk**: del() syntax less familiar, may be harder to maintain.

**Recommendation**: Test thoroughly, document pattern.

**Effort**: 2 hours (update 3 skills, test).

---

## Implementation Approach

### Phase 1: Add Validation (Non-Breaking) - 3 hours

**Goal**: Detect when delegation is bypassed without breaking current functionality.

**Tasks**:
1. Create `.claude/lib/validate-delegation.sh` library (1h)
2. Add validation calls to commands (warnings only, non-failing) (1h)
3. Add commit logging to errors.json (1h)

**Deliverables**:
- Validation library
- Commands log warnings when skills bypassed
- Commit failures logged to errors.json

**Success Criteria**:
- Commands run without breaking
- Warnings appear when simulation code runs
- errors.json contains commit failure entries

---

### Phase 2: Implement Real Skill Delegation (Breaking) - 4 hours

**Goal**: Replace simulation code with actual skill invocation.

**Tasks**:
1. Update research.sh to invoke skill-researcher (1h)
2. Update plan.sh to invoke skill-planner (1h)
3. Update implement.sh to invoke skill-implementer (1h)
4. Make validation failures fatal (30m)
5. Test all three commands end-to-end (30m)

**Deliverables**:
- Commands delegate to skills (no simulation)
- Skills execute and perform postflight
- Validation enforces checkpoint pattern

**Success Criteria**:
- /research creates real report via agent
- /plan creates real plan via agent
- /implement executes real phases
- All postflight operations execute correctly

---

### Phase 3: Migrate to Markdown-Only Commands (Major Refactor) - 6 hours

**Goal**: Eliminate .sh files, use Claude Code's skill invocation.

**Tasks**:
1. Add frontmatter to research.md (allowed-tools, model) (30m)
2. Simplify research.md to validation + Skill call + verification (1h)
3. Test research.md executes via Claude Code (30m)
4. Delete research.sh (5m)
5. Repeat for plan.md (2h)
6. Repeat for implement.md (2h)

**Deliverables**:
- Single .md file per command
- No shell scripts
- Pure skill delegation
- Simplified architecture

**Success Criteria**:
- All commands work via markdown files
- No .sh files remain
- Documentation and implementation unified

---

### Phase 4: Add Guard Rails (Hardening) - 3 hours

**Goal**: Make checkpoint bypass impossible.

**Tasks**:
1. Implement checkpoint state machine (1.5h)
2. Add pre-commit hooks for validation (1h)
3. Create runtime guards (30m)

**Deliverables**:
- Checkpoint state enforcement
- Pre-commit validation
- Runtime guards

**Success Criteria**:
- Cannot skip checkpoints
- Pre-commit hooks prevent simulation code
- Runtime errors if checkpoints violated

---

## Risks & Mitigations

### Risk 1: Breaking Existing Workflows

**Risk**: Removing simulation code breaks current command execution.

**Impact**: High (commands unusable)

**Likelihood**: Medium (skill invocation may have issues)

**Mitigation**:
- Phase 1 adds validation without breaking
- Test skill delegation in isolated task first
- Keep .sh files until Phase 3 (rollback path)
- Document migration for users

---

### Risk 2: Skill Tool Invocation Complexity

**Risk**: Invoking skills from markdown commands may not work as expected.

**Impact**: High (blocks Phase 3)

**Likelihood**: Medium (Claude Code skill model may have limitations)

**Mitigation**:
- Test skill invocation in prototype command first
- Review Claude Code documentation for skill invocation
- Start with one command (research) before migrating all
- Keep bash option (invoke via subprocess) as fallback

---

### Risk 3: Performance Degradation

**Risk**: Skill delegation may add latency vs direct implementation.

**Impact**: Medium (slower operations)

**Likelihood**: Low (delegation overhead is small)

**Mitigation**:
- Measure baseline performance with simulation code
- Measure performance with real skill delegation
- Optimize if needed (caching, parallel execution)
- Accept small overhead for correctness

---

### Risk 4: Metadata File Race Conditions

**Risk**: Concurrent operations may corrupt metadata files.

**Impact**: Medium (state corruption)

**Likelihood**: Low (single-user system)

**Mitigation**:
- Include session_id in metadata file path for uniqueness
- Add validation that session_id matches expected value
- Detect and report stale metadata files
- Use file locking if needed

---

## Concrete Action Items (Prioritized)

### Immediate (P0) - Must fix before system is production-ready

1. **Remove simulation code from research.sh** (1h)
   - Replace lines 385-430 with real skill invocation
   - Verify skill-researcher is invoked
   - Test creates real research report

2. **Remove simulation code from plan.sh** (1h)
   - Replace simulation with skill-planner invocation
   - Test creates real implementation plan

3. **Remove simulation code from implement.sh** (1h)
   - Replace simulation with skill-implementer invocation
   - Test executes real phases

4. **Add validation guards to all commands** (2h)
   - Create validation library
   - Verify metadata schema
   - Check artifacts exist and non-empty
   - Confirm postflight marker cleanup

### Short-term (P1) - Improves architecture significantly

5. **Migrate research.sh to research.md** (2h)
   - Add frontmatter
   - Simplify to validation + Skill call
   - Delete .sh file

6. **Migrate plan.sh to plan.md** (2h)

7. **Migrate implement.sh to implement.md** (2h)

8. **Add checkpoint state machine** (3h)
   - Prevent checkpoint bypass
   - Enforce correct flow

### Medium-term (P2) - Quality of life improvements

9. **Add commit failure logging** (1h)
   - Log to errors.json
   - Capture error details

10. **Create pre-commit hooks** (1h)
    - Prevent simulation code from merging
    - Validate checkpoint pattern

### Long-term (P3) - Optimizations

11. **Optimize jq calls with del()** (2h)
    - Replace two-step pattern
    - Test thoroughly

12. **Add retry logic for transient commit failures** (1h)
    - Handle lock conflicts
    - Exponential backoff

---

## Success Metrics

| Metric | Current | Target | How to Measure |
|--------|---------|--------|----------------|
| Skills invoked per command | 0% | 100% | Check postflight marker creation |
| Agents executed per operation | 0% | 100% | Check metadata file validity |
| Validation failures caught | 0% | 100% | Run /research with invalid task |
| Checkpoint bypass possible | Yes | No | Try skipping skill delegation |
| Command file count | 6 (.sh + .md) | 3 (.md only) | ls .claude/commands/ |
| State update duplication | 100% | 0% | Only skills update state |
| Commit failures logged | 0% | 100% | Trigger commit failure, check errors.json |

---

## Appendix

### Search Queries Used

1. Read: `.claude/commands/research.{sh,md}`
2. Read: `.claude/commands/plan.{sh,md}`
3. Read: `.claude/commands/implement.{sh,md}`
4. Read: `.claude/skills/skill-researcher/SKILL.md`
5. Read: `.claude/skills/skill-planner/SKILL.md`
6. Read: `.claude/skills/skill-implementer/SKILL.md`
7. Read: `.claude/context/core/formats/return-metadata-file.md`
8. Read: `.claude/context/core/patterns/checkpoint-execution.md`
9. Read: `.claude/context/core/patterns/jq-escaping-workarounds.md`
10. Read: `.claude/rules/state-management.md`
11. Read: `.claude/rules/git-workflow.md`
12. Read: Task 675 research report

### References

**Checkpoint Pattern**:
- `.claude/context/core/patterns/checkpoint-execution.md` - 3-checkpoint model
- `.claude/CLAUDE.md` - Checkpoint-Based Execution Model section

**Skills**:
- `.claude/skills/skill-researcher/SKILL.md` - 11-stage pattern
- `.claude/skills/skill-planner/SKILL.md` - 11-stage pattern
- `.claude/skills/skill-implementer/SKILL.md` - 11-stage pattern with completion_data

**Commands**:
- `.claude/commands/research.sh` - Bash implementation (simulation)
- `.claude/commands/research.md` - Documentation (intended pattern)

**State Management**:
- `.claude/rules/state-management.md` - Two-phase update pattern
- `.claude/context/core/formats/return-metadata-file.md` - v2 metadata schema

**Git Workflow**:
- `.claude/rules/git-workflow.md` - Commit conventions, session ID format

**Known Issues**:
- `.claude/context/core/patterns/jq-escaping-workarounds.md` - Issue #1132 workaround

### Key Files Analyzed

**Commands** (6 files):
- research.sh (525 lines) - Contains simulation code
- research.md (282 lines) - Documents intended pattern
- plan.sh (similar structure)
- plan.md (120 lines)
- implement.sh (similar structure)
- implement.md (196 lines)

**Skills** (3 analyzed):
- skill-researcher/SKILL.md (308 lines) - Correctly implemented
- skill-planner/SKILL.md (335 lines) - Correctly implemented
- skill-implementer/SKILL.md (409 lines) - Correctly implemented

**Patterns** (5 analyzed):
- checkpoint-execution.md - Quick reference
- return-metadata-file.md - File-based metadata schema
- jq-escaping-workarounds.md - Issue #1132 patterns
- state-management.md - Two-phase update
- git-workflow.md - Commit format

### Total Estimated Effort

| Phase | Tasks | Hours |
|-------|-------|-------|
| Phase 1: Validation | Non-breaking validation layer | 3 |
| Phase 2: Real Delegation | Remove simulation, invoke skills | 4 |
| Phase 3: Markdown Migration | Delete .sh, unify with .md | 6 |
| Phase 4: Guard Rails | Checkpoint enforcement | 3 |
| **Total** | | **16 hours** |

**Critical Path**: Phase 1 → Phase 2 (7 hours) gets system working correctly.

Phase 3 + 4 are architectural improvements (9 hours).
