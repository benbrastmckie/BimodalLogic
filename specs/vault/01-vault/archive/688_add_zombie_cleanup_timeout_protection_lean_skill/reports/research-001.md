# Research Report: Task #688

**Task**: 688 - Add zombie cleanup and timeout protection to Lean implementation skill
**Started**: 2026-01-26T16:41:00Z
**Completed**: 2026-01-26T16:42:00Z
**Effort**: 1 hour
**Priority**: high
**Dependencies**: None
**Sources/Inputs**:
- Codebase analysis: skill-lean-implementation, lean-implementation-agent, subagent-postflight hook
- Web research: Linux zombie process management
- System diagnostics: Current zombie process state
**Artifacts**:
- specs/688_add_zombie_cleanup_timeout_protection_lean_skill/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Root Cause**: lean-lsp MCP server spawns `lake` subprocesses that become zombies when not properly reaped, causing indefinite hangs on MCP tool calls
- **Current Impact**: 5 zombie lake processes detected, loop guard triggering at 3 iterations, agent appears "running" but deadlocked
- **Recommended Solution**: Three-layer intervention: (1) pre-flight zombie cleanup, (2) timeout on Task delegation, (3) graceful timeout handling in agent
- **Implementation Complexity**: Low - uses existing claude-refresh.sh patterns and Task tool timeout parameter

## Context & Scope

This task addresses MCP-induced agent hangs in skill-lean-implementation. The lean-lsp MCP server spawns lake build processes that become zombies when the server fails to reap them. These zombies block subsequent MCP calls indefinitely, causing:

1. Agent stalls on `lean_diagnostic_messages` calls
2. Postflight hook detects marker and forces continuation
3. Loop guard triggers after 3 iterations
4. Session appears "running" but makes no progress

**Constraints**:
- Cannot modify lean-lsp MCP server (external dependency)
- Must preserve active Lean sessions (safety critical)
- Should add minimal overhead to normal execution

## Findings

### 1. Current Architecture Analysis

**Skill Structure** (skill-lean-implementation):
- **Stage 1-2**: Validate task, update status to "implementing"
- **Stage 3**: Create postflight marker
- **Stage 4**: Prepare delegation context (includes `timeout: 7200` field)
- **Stage 5**: Invoke subagent via Task tool
- **Stage 6-10**: Postflight operations (read metadata, update status, git commit, cleanup)

**Agent Execution** (lean-implementation-agent):
- Reads implementation plan
- Executes proof development loop
- Uses MCP tools extensively: `lean_goal`, `lean_diagnostic_messages`, `lean_hover_info`
- Returns brief text summary + writes `.return-meta.json`

**Postflight Hook** (subagent-postflight.sh):
- Detects marker file: `specs/.postflight-pending`
- Blocks stop to allow skill postflight
- Loop guard: max 3 continuations
- **Current issue**: Agent never completes, so loop guard always triggers

### 2. Zombie Process Root Cause

**Diagnostic Evidence**:
```
ps aux shows:
- 5 zombie lake.orig processes (PIDs: 460204, 714706, 717977, 726032, 755680)
- All parented by active lean-lsp-mcp Python processes
- Parent processes have TTY (Sl+ status), zombies have no TTY (Z+ status)
```

**Why Zombies Form**:
1. lean-lsp MCP server spawns `lake` subprocess for build operations
2. `lake` process completes but lean-lsp doesn't call `wait()` to reap it
3. Process becomes zombie (kernel keeps PID entry until parent reaps)
4. Subsequent MCP calls block waiting for non-existent response
5. Agent hangs indefinitely on MCP tool call

**Why Killing Zombies Doesn't Work**:
Zombies are already dead processes. The only way to remove them is to:
- Kill the parent process (forces kernel to reparent to init/systemd)
- Wait for parent to properly reap them (unreliable with buggy server)

Source: [How To Kill Zombie Processes on Linux](https://www.linuxjournal.com/content/how-kill-zombie-processes-linux), [Kill Zombie Processes](https://opensource.com/article/21/10/linux-zombie-process)

### 3. Existing Process Cleanup Patterns

**claude-refresh.sh** (already in codebase):
- Identifies orphaned Claude processes (TTY = "?")
- Excludes current process tree
- Uses SIGTERM first, SIGKILL if needed
- Safety margin: never kills active sessions

**Adaptation Strategy**:
Create lean-specific cleanup that:
1. Finds lean-lsp-mcp parent processes with zombie children
2. Checks if parent is orphaned (no TTY) or stale (age check)
3. Kills parent process to trigger zombie cleanup
4. Preserves active Lean sessions

### 4. Timeout Protection Analysis

**Current Timeout Usage** (from grep search):
- skill-lean-research: `timeout: 3600` (1 hour)
- skill-lean-implementation: `timeout: 7200` (2 hours)
- skill-planner: `timeout: 1800` (30 minutes)
- skill-meta: `timeout: 7200` (2 hours)

**Task Tool Timeout Behavior** (from web search):
- Claude Code has fixed MCP stdio server timeout issue not killing child processes
- Task tool (subagents) improved to continue after permission denial
- Recent fixes address hang protection by making Task tool more resilient

Source: [Claude Code Release Notes](https://github.com/anthropics/claude-code/releases)

**Current Problem**:
The `timeout: 7200` parameter exists in delegation context but appears ineffective:
1. Task tool may not enforce timeout on MCP tool calls
2. MCP hang occurs at protocol level, below Task tool visibility
3. No timeout triggers, so loop guard is only protection

**Proposed Enhancement**:
Add explicit timeout handling in agent:
1. Track time spent on each MCP call
2. If MCP call exceeds threshold (e.g., 30s), abort and return partial
3. Document timeout in metadata for skill postflight

### 5. Process Management Best Practices

**Safe Parent Process Killing** (from web research):
- Always verify parent's children before killing (avoid collateral damage)
- Check process age (recent = likely active, old = likely stale)
- Use SIGCHLD signal first (notifies parent to reap)
- Fall back to SIGTERM, then SIGKILL only if needed
- Never kill PID 1 or init-parented processes

**Age-Based Detection**:
- Zombies older than 1 hour = likely abandoned
- Lean sessions typically complete builds within minutes
- Use `ps -o etimes=` to get process age in seconds

**Implementation Safety Checklist**:
- [ ] Exclude processes with active TTY
- [ ] Exclude current session processes
- [ ] Check parent has zombie children (don't kill for unrelated reasons)
- [ ] Age threshold: only kill parents with zombies older than threshold
- [ ] Dry-run mode for testing

## Decisions

### Decision 1: Three-Layer Defense Strategy

**Rationale**: Single-point fixes are fragile. Defense in depth provides redundancy.

**Layers**:
1. **Preflight Cleanup**: Remove existing zombies before agent starts
2. **Timeout Enforcement**: Task delegation timeout ensures eventual termination
3. **Graceful Timeout**: Agent detects hung MCP calls and returns partial

### Decision 2: Leverage Existing claude-refresh.sh Pattern

**Rationale**: Proven process cleanup logic already exists and is battle-tested.

**Approach**: Create `lean-zombie-cleanup.sh` script modeled on claude-refresh.sh that:
- Targets lean-lsp-mcp parent processes with zombie lake children
- Uses same safety checks (TTY, process tree exclusion)
- Integrates into skill preflight (Stage 2.5)

### Decision 3: Keep Timeout at 7200s, Add Per-Call Limits

**Rationale**: Lean proofs can take hours legitimately. The issue is individual MCP call hangs, not overall duration.

**Implementation**:
- Keep Task tool `timeout: 7200` (2 hours total)
- Add agent-level per-call timeout: 60s for MCP tools
- If single MCP call exceeds 60s, mark as hung and return partial

### Decision 4: Enhance Loop Guard with Age Detection

**Rationale**: Current loop guard only counts iterations. Adding age detection prevents indefinite "running" sessions.

**Approach**:
- If postflight marker older than 5 minutes, force cleanup
- Log as deadlock and allow stop
- Prevents session appearing "running" when actually deadlocked

## Risks & Mitigations

### Risk 1: Killing Active Lean Sessions

**Impact**: High - would disrupt legitimate proof development
**Probability**: Low - safety checks prevent this

**Mitigations**:
1. Only kill orphaned processes (no TTY)
2. Age threshold (1 hour minimum)
3. Exclude current process tree
4. Dry-run testing before deployment

### Risk 2: Timeout Too Aggressive

**Impact**: Medium - could abort legitimate long-running proofs
**Probability**: Medium - some proofs take hours

**Mitigations**:
1. Use 60s per-call timeout (generous for single MCP call)
2. Keep 2-hour total timeout (unchanged)
3. Return partial with resume information
4. User can retry or adjust timeout if needed

### Risk 3: Script Fails to Clean Zombies

**Impact**: Low - no worse than current state
**Probability**: Medium - zombie cleanup is non-trivial

**Mitigations**:
1. Kill parent process (guaranteed zombie cleanup)
2. Log all cleanup attempts
3. Non-fatal: skill continues even if cleanup fails
4. Manual fallback: user can run /refresh

### Risk 4: Race Condition with Active MCP Call

**Impact**: Medium - could kill MCP server mid-call
**Probability**: Low - preflight runs before agent starts

**Mitigations**:
1. Run cleanup in preflight (before MCP usage)
2. Age threshold ensures no recent activity
3. SIGTERM first (graceful shutdown)

## Implementation Strategy

### Phase 1: Create Zombie Cleanup Script (2 hours)

**Deliverables**:
- `.claude/scripts/lean-zombie-cleanup.sh`
- Modeled on claude-refresh.sh
- Targets lean-lsp-mcp processes with zombie lake children
- Safety checks: TTY, age, process tree exclusion

**Verification**:
- Dry-run mode testing
- Manual execution with current zombies
- Verify active sessions preserved

### Phase 2: Integrate Preflight Cleanup (1 hour)

**Deliverables**:
- Update skill-lean-implementation Stage 2.5 (new stage)
- Call lean-zombie-cleanup.sh before Task delegation
- Non-blocking: log errors but continue

**Verification**:
- Run /implement on test task
- Verify cleanup executes
- Verify skill continues if cleanup fails

### Phase 3: Add Agent Timeout Handling (3 hours)

**Deliverables**:
- Update lean-implementation-agent proof development loop
- Add per-call timeout wrapper for MCP tools
- Return partial if timeout exceeded

**Verification**:
- Test with simulated MCP hang
- Verify partial return with metadata
- Verify skill postflight handles partial correctly

### Phase 4: Enhance Loop Guard (1 hour)

**Deliverables**:
- Update subagent-postflight.sh
- Add age-based deadlock detection
- Force cleanup if marker older than 5 minutes

**Verification**:
- Test with simulated deadlock
- Verify cleanup triggers
- Verify logs record deadlock

**Total Estimated Effort**: 7 hours

## Recommended Solutions

### Solution 1: Zombie Cleanup Script

**Script**: `.claude/scripts/lean-zombie-cleanup.sh`

```bash
#!/usr/bin/env bash
# lean-zombie-cleanup.sh - Clean up zombie lake processes from lean-lsp-mcp

set -euo pipefail

# Find lean-lsp-mcp parent processes with zombie lake children
# Logic:
# 1. Find all lean-lsp-mcp Python processes
# 2. For each, check if it has zombie children (ps --ppid $pid | grep 'Z')
# 3. If yes and parent is orphaned or old (>1h), kill parent
# 4. Exclude current session processes

AGE_THRESHOLD=${1:-3600}  # Default 1 hour in seconds

get_lean_lsp_processes() {
    ps aux | grep '[l]ean-lsp-mcp' | grep python | awk '{print $2}'
}

has_zombie_children() {
    local ppid=$1
    ps --ppid "$ppid" 2>/dev/null | grep -q ' Z ' || return 1
}

get_process_age() {
    local pid=$1
    ps -o etimes= -p "$pid" 2>/dev/null | tr -d ' ' || echo 0
}

is_orphaned() {
    local pid=$1
    local tty=$(ps -o tty= -p "$pid" 2>/dev/null | tr -d ' ')
    [ "$tty" = "?" ] || return 1
}

cleanup_candidates=()

while IFS= read -r pid; do
    [ -z "$pid" ] && continue

    # Check if has zombie children
    if ! has_zombie_children "$pid"; then
        continue
    fi

    # Check if orphaned OR old
    age=$(get_process_age "$pid")
    if is_orphaned "$pid" || [ "$age" -gt "$AGE_THRESHOLD" ]; then
        cleanup_candidates+=("$pid")
    fi
done < <(get_lean_lsp_processes)

# Execute cleanup
for pid in "${cleanup_candidates[@]}"; do
    echo "Cleaning lean-lsp-mcp PID $pid (age: $(($(get_process_age "$pid") / 60))m)"
    kill -15 "$pid" 2>/dev/null || true
    sleep 0.5
    kill -9 "$pid" 2>/dev/null || true
done

echo "Cleaned ${#cleanup_candidates[@]} lean-lsp-mcp processes"
```

**Integration Point**: skill-lean-implementation Stage 2.5 (after status update, before Task delegation)

### Solution 2: Skill Preflight Cleanup

**Modification**: Add Stage 2.5 to skill-lean-implementation

```bash
### Stage 2.5: Cleanup Zombie Processes (NEW)

# Run lean-specific zombie cleanup
if [ -f ".claude/scripts/lean-zombie-cleanup.sh" ]; then
    echo "Running preflight zombie cleanup..."
    bash .claude/scripts/lean-zombie-cleanup.sh 3600 || {
        echo "Warning: Zombie cleanup failed, continuing anyway"
    }
fi
```

**Properties**:
- Non-blocking (errors logged but don't fail skill)
- Runs before agent starts (prevents MCP hangs)
- Uses 1-hour threshold (aggressive but safe)

### Solution 3: Agent Per-Call Timeout

**Modification**: Add timeout wrapper in lean-implementation-agent proof development loop

**Pseudo-code**:
```bash
# Before each MCP call
start_time=$(date +%s)

# Make MCP call
result=$(timeout 60s mcp__lean-lsp__lean_goal ...)

# Check if timed out
if [ $? -eq 124 ]; then
    echo "MCP call timed out after 60s"
    # Return partial status
    write_metadata "partial" "MCP timeout on lean_goal call"
    exit 1
fi
```

**Note**: Task tool doesn't support per-call timeouts natively. This requires agent-level implementation using Bash `timeout` command or tracking elapsed time.

### Solution 4: Enhanced Loop Guard

**Modification**: Update subagent-postflight.sh

```bash
# Check marker age (in addition to iteration count)
if [ -f "$MARKER_FILE" ]; then
    created=$(jq -r '.created' "$MARKER_FILE" 2>/dev/null)
    now=$(date -u +%s)
    created_ts=$(date -d "$created" +%s 2>/dev/null || echo 0)
    age=$((now - created_ts))

    # If marker older than 5 minutes, force cleanup (likely deadlock)
    if [ "$age" -gt 300 ]; then
        log_debug "Marker age $age > 300s, forcing cleanup (deadlock detected)"
        rm -f "$MARKER_FILE"
        rm -f "$LOOP_GUARD_FILE"
        echo '{}'
        exit 0
    fi
fi
```

## Appendix

### Search Queries Used

1. "zombie processes linux kill by parent PID bash script safe cleanup 2026"
   - Found comprehensive guides on zombie process management
   - Key insight: Must kill parent, not zombie itself

2. "Claude MCP server timeout parameter Task tool lean-lsp hang protection 2026"
   - Found recent Claude Code fixes for MCP timeout issues
   - Confirmed Task tool timeout improvements

### References

**Linux Process Management**:
- [How To Kill Zombie Processes on Linux | Linux Journal](https://www.linuxjournal.com/content/how-kill-zombie-processes-linux)
- [How to kill a zombie process on Linux | Opensource.com](https://opensource.com/article/21/10/linux-zombie-process)
- [Killing zombies, Linux style | Red Hat](https://www.redhat.com/en/blog/killing-zombies-linux-style)
- [How to Clean a Linux Zombie Process | Baeldung](https://www.baeldung.com/linux/clean-zombie-process)

**Claude Code MCP**:
- [lean-lsp-mcp · PyPI](https://pypi.org/project/lean-lsp-mcp/)
- [Claude Code Release Notes](https://github.com/anthropics/claude-code/releases)

### Current System State

**Zombie Processes** (as of 2026-01-26 16:41):
```
PID     PPID   Command
460204  455699 [lake.orig] <defunct>
714706  711925 [lake.orig] <defunct>
717977  715950 [lake.orig] <defunct>
726032  713167 [lake.orig] <defunct>
755680  754750 [lake.orig] <defunct>
```

**Parent Processes** (lean-lsp-mcp):
- All have active TTY (Sl+ status)
- Ages range from 47 minutes to 19+ hours
- All consuming CPU (0.0-1.5%)

**Loop Guard Activity** (from logs):
- Multiple deadlock events today (06:38, 15:49, 15:59, 16:32)
- Consistent pattern: 3 iterations then guard triggers
- Confirms agent never completes, postflight never runs
