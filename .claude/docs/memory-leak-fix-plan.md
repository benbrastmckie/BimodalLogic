# Memory Leak Fix Plan

**Created**: 2026-01-18
**Issue**: JavaScript heap out of memory errors during /implement delegation to lean-implementation-agent
**Root Causes**: Zombie processes, uncleaned agent contexts, infinite context accumulation

---

## Root Cause Summary

### 1. Zombie Process Accumulation
- **Symptom**: 9+ Claude processes running simultaneously (3GB+ memory total)
- **Cause**: Spawned agent conversations not terminated after completion
- **Evidence**: `ps aux | grep claude` shows processes from Jan 17 still running

### 2. Delegation Chain Memory Amplification
- **Current Flow**: User → /implement → skill-lean-implementation → lean-implementation-agent
- **Problem**: Each delegation spawns a new conversation context without cleanup
- **Impact**: 3x memory multiplication per task

### 3. Unbounded Context Accumulation
- **Location**: lean-implementation-agent proof development loop (lines 111-147)
- **Problem**: Iterative proof attempts accumulate:
  - File reads (Read tool outputs)
  - MCP tool results (lean_goal, lean_diagnostic_messages)
  - Multi-attempt results (lean_multi_attempt returns arrays)
  - Conversation history grows without eviction

### 4. No Resource Limits
- **Problem**: No enforcement of:
  - Maximum context size per agent
  - Maximum delegation depth timeout with cleanup
  - Zombie process detection and cleanup

---

## Proposed Fixes

### Priority 1: Immediate Mitigation (Day 1)

#### Fix 1.1: Add Process Cleanup to Commands

**File**: `.claude/commands/implement.md`

Add to CHECKPOINT 3 (COMMIT):
```markdown
### Process Cleanup

After git commit:
```bash
# Terminate spawned agent processes
# (Task tool spawns subprocess - ensure it's cleaned up)
ps aux | grep -E "claude.*implement.*569" | grep -v grep | awk '{print $2}' | xargs -r kill 2>/dev/null || true
```
```

**Rationale**: Explicitly kill zombie processes after task completion.

#### Fix 1.2: Add Resource Limits to Agent Spawning

**File**: `.claude/skills/skill-lean-implementation/SKILL.md`

Modify Section 3 (Invoke Subagent) to add max_turns limit:
```markdown
### 3. Invoke Subagent

**Tool Invocation**:
```
Tool: Task
Parameters:
  - subagent_type: "lean-implementation-agent"
  - prompt: [delegation context]
  - description: "Execute Lean implementation for task {N}"
  - max_turns: 50  # CRITICAL: Limit agent conversation depth
```
```

**Rationale**: The `max_turns` parameter (documented in Task tool) limits conversation rounds, preventing infinite context accumulation.

#### Fix 1.3: Add Memory Budget to Agent Instructions

**File**: `.claude/agents/lean-implementation-agent.md`

Add new section after line 68 (Context References):
```markdown
## Memory Budget

**CRITICAL**: This agent MUST operate within strict memory limits to prevent OOM errors.

### Conversation Turn Limit
- **Maximum turns**: 50 (enforced by caller's max_turns parameter)
- **Turn budget per phase**: ~10 turns average
- **When approaching limit**: Return partial status, log phase resume point

### Context Size Limit
- **Maximum context references**: 5 files per phase
- **File size limit**: Skip files >10MB (use Grep/Glob instead of Read)
- **MCP result caching**: Store only final lean_goal state, discard intermediate attempts

### Cleanup Strategy

After each phase completion:
1. Do NOT re-read completed proofs (assume they're correct)
2. Clear intermediate lean_multi_attempt results from memory
3. Use lean_diagnostic_messages only once per file modification
4. Rely on plan file phase markers instead of re-scanning files
```

**Rationale**: Explicit memory budget prevents unbounded growth.

---

### Priority 2: Architectural Refactor (Week 1)

#### Fix 2.1: Flatten Delegation Chain

**Current**: User → /implement → skill-lean-implementation → lean-implementation-agent (3 levels)

**Proposed**: User → /implement → lean-implementation-agent (2 levels)

**Changes**:
1. Remove `skill-lean-implementation` thin wrapper
2. Move validation logic from skill to /implement command
3. Direct Task tool invocation from /implement

**File**: `.claude/commands/implement.md` (STAGE 2: DELEGATE)

Replace:
```markdown
Invoke the Skill tool with skill-lean-implementation
```

With:
```markdown
**Language-Based Direct Delegation**:

| Language | Agent to Spawn |
|----------|----------------|
| `lean` | `lean-implementation-agent` |
| `latex` | `latex-implementation-agent` |
| `general` | `general-implementation-agent` |

Invoke Task tool with:
```bash
Task(
  subagent_type: "{agent from table}",
  prompt: "task_number={N} plan_path={path} session_id={session_id}",
  description: "Execute implementation for task {N}",
  max_turns: 50
)
```
```

**Rationale**: Reduce delegation depth from 3→2, eliminate skill wrapper overhead.

#### Fix 2.2: Implement Agent Session Cleanup

**File**: `.claude/agents/lean-implementation-agent.md`

Add to Stage 7 (Return Structured JSON), after line 231:
```markdown
### Stage 8: Session Cleanup (NEW)

Before returning, clean up the agent session:

```bash
# Clear large context references from memory
unset lean_goal_cache
unset file_read_cache

# Log session completion for monitoring
echo "[CLEANUP] Session ${session_id} completed, releasing resources"

# Note: Process termination handled by Task tool caller
```

Return JSON as specified in Stage 7.
```

**Rationale**: Explicit cleanup step reduces memory footprint before agent termination.

#### Fix 2.3: Add Zombie Process Monitoring

**File**: `.claude/hooks/post-session-hook.sh` (create new)

```bash
#!/bin/bash
# Post-session cleanup hook
# Runs after every command session completes

# Find and kill Claude processes older than 1 hour that are idle
ps aux | grep claude | awk '{if ($10 ~ /S/) print $2,$9}' | while read pid time; do
  # Parse time (HH:MM format), kill if > 1 hour
  hours=$(echo $time | cut -d: -f1)
  if [ "$hours" -gt 1 ]; then
    echo "Killing idle Claude process $pid (runtime: $time)"
    kill -15 $pid 2>/dev/null || true
  fi
done
```

**Activation**: Add to `.claude/settings.json`:
```json
{
  "hooks": {
    "post-session": ".claude/hooks/post-session-hook.sh"
  }
}
```

**Rationale**: Automatic zombie process cleanup prevents multi-day accumulation.

---

### Priority 3: Monitoring & Prevention (Week 2)

#### Fix 3.1: Add Memory Usage Tracking

**File**: `.claude/agents/lean-implementation-agent.md`

Add to Stage 1 (Parse Delegation Context):
```markdown
Track memory usage throughout execution:

```bash
# Record starting memory
start_mem=$(ps -o rss= -p $$)
echo "[MEMORY] Agent started: ${start_mem}KB"

# Set trap to log memory at key checkpoints
log_memory() {
  current_mem=$(ps -o rss= -p $$)
  delta=$((current_mem - start_mem))
  echo "[MEMORY] Checkpoint $1: ${current_mem}KB (Δ${delta}KB)"
}

# Log at phase boundaries
trap 'log_memory "phase_${phase_number}"' DEBUG
```
```

**Rationale**: Visibility into memory growth patterns enables early detection.

#### Fix 3.2: Add Circuit Breaker

**File**: `.claude/agents/lean-implementation-agent.md`

Add to Stage 4 (Execute Proof Development Loop):
```markdown
### Circuit Breaker Pattern

Before each proof development iteration:

```bash
# Check memory threshold
current_mem=$(ps -o rss= -p $$)
if [ "$current_mem" -gt 2000000 ]; then  # 2GB limit
  echo "[CIRCUIT BREAKER] Memory limit exceeded: ${current_mem}KB"

  # Save progress
  mark_phase_partial

  # Return partial status
  return_json '{
    "status": "partial",
    "summary": "Memory limit exceeded, partial progress saved",
    "errors": [{
      "type": "resource_limit",
      "message": "Agent exceeded 2GB memory limit",
      "recoverable": true,
      "recommendation": "Resume with /implement {N} after system cleanup"
    }]
  }'

  exit 0
fi
```
```

**Rationale**: Graceful degradation prevents hard OOM crashes.

---

## Implementation Order

1. **Day 1** (Immediate):
   - Fix 1.2: Add max_turns limit (5 minutes)
   - Fix 1.3: Add memory budget docs (10 minutes)
   - Manual cleanup: `killall claude` (1 minute)

2. **Day 2-3** (Critical):
   - Fix 2.1: Flatten delegation chain (2 hours)
   - Fix 2.3: Zombie process monitoring (1 hour)

3. **Week 1** (Important):
   - Fix 2.2: Agent session cleanup (1 hour)
   - Fix 3.2: Circuit breaker (2 hours)

4. **Week 2** (Enhancement):
   - Fix 3.1: Memory usage tracking (1 hour)
   - Testing and validation (4 hours)

---

## Testing Plan

### Test 1: Verify Process Cleanup
```bash
# Before: Count Claude processes
ps aux | grep claude | wc -l

# Run: /implement 569
claude /implement 569

# After: Verify process count decreased
ps aux | grep claude | wc -l
```

**Expected**: Process count returns to baseline ±1.

### Test 2: Verify Memory Limit
```bash
# Run with memory monitoring
while true; do
  ps aux | grep 'claude.*implement' | awk '{print $6}' | head -1
  sleep 5
done
```

**Expected**: Memory usage stays <2GB throughout execution.

### Test 3: Verify max_turns Enforcement
```bash
# Check agent output for turn count
grep -i "turn\|round" /tmp/claude-agent-*.log
```

**Expected**: Agent terminates at turn 50 max.

---

## Success Criteria

- [ ] Zero OOM errors during /implement execution
- [ ] Claude process count stays ≤3 during normal operation
- [ ] Memory usage per agent stays <2GB
- [ ] Zombie processes auto-cleaned within 1 hour
- [ ] All tests pass for 5 consecutive /implement runs

---

## Rollback Plan

If fixes cause regressions:

1. **Revert max_turns limit**: Remove from skill-lean-implementation/SKILL.md
2. **Revert delegation flattening**: Restore skill wrapper
3. **Disable zombie cleanup hook**: Remove from settings.json

Rollback commands:
```bash
git log --oneline | grep -i "memory\|oom\|cleanup"  # Find fix commits
git revert <commit-hash>  # Revert specific fix
```

---

## Related Issues

- **Task 565**: Workflow interruption (may be related to zombie processes)
- **Delegation standard**: `.claude/context/core/orchestration/delegation.md` (needs max_turns guidance)

---

## References

- Out of memory output: `.claude/output/implement.md` lines 105-150
- Agent definition: `.claude/agents/lean-implementation-agent.md`
- Skill wrapper: `.claude/skills/skill-lean-implementation/SKILL.md`
- Task tool documentation: Claude Code CLI reference (max_turns parameter)
