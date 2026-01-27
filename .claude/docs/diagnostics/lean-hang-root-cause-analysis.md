# Lean /implement Hang Root Cause Analysis

**Date**: 2026-01-27
**Status**: Root cause identified, testing alternative solutions
**Priority**: Critical

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Root Cause Analysis](#root-cause-analysis)
3. [Solutions Attempted](#solutions-attempted)
4. [Current Mitigation System](#current-mitigation-system)
5. [Alternative Solutions](#alternative-solutions)
6. [Recommended Approach](#recommended-approach)
7. [Detection and Monitoring](#detection-and-monitoring)
8. [Testing Checklist](#testing-checklist)

---

## Executive Summary

### The Problem

Lean `/implement` commands hang indefinitely on the first MCP tool call (`lean_diagnostic_messages`), with a **100% hang rate** when multiple Claude Code sessions exist.

### Root Cause

**Multiple concurrent lean-lsp-mcp server instances** running simultaneously, each trying to access the same Lean project:

```
PID 799013: lean-lsp-mcp (session pts/12)
PID 945764: lean-lsp-mcp (session pts/3)
PID 959260: lean-lsp-mcp (session pts/1) ← has zombie child
PID 967445: lean-lsp-mcp (session pts/7)
```

**Conflict Mechanism**:
1. Task tool spawns agent subprocess
2. Agent reads `.mcp.json` configuration
3. Agent spawns **NEW** lean-lsp-mcp server instance
4. Each server spawns its own `lake serve` process
5. Multiple `lake serve` processes fight over `.lake` directory (locks, build artifacts)
6. **Deadlock** occurs on first MCP call → agent hangs forever

### Current Status

- ✅ 4-phase mitigation plan implemented (addresses symptoms, not root cause)
- ✅ Root cause identified (concurrent server instances)
- ⚠️ Solution pending: Need approach that permits multiple concurrent agents

---

## Root Cause Analysis

### Discovery Process

**Initial Hypothesis** (Incorrect):
- Zombie `lake` processes from `leanclient` library bug
- Addressed by: zombie cleanup, pre-build, diagnostic throttling

**Evidence of Deeper Problem**:
1. Transcript shows agent hangs on **FIRST** MCP call (before any zombies form)
2. Pre-build completes successfully, but agent still hangs immediately
3. Progress tracking file never gets created (agent hangs before Stage 1.5)
4. No MCP response data in transcript (call never completes)

**Root Cause Discovery**:
```bash
$ ps aux | grep lean-lsp-mcp
# Found 4 concurrent instances!

$ pstree -p 959260
# One has zombie lake child

$ lsof -p 959260 | grep pipe
# Blocked on pipe I/O - waiting for lake serve response
```

### The Concurrent Server Problem

**Why Multiple Servers Exist**:

1. **User opens multiple Claude Code sessions** (e.g., different terminals/editors)
2. Each session spawns lean-lsp-mcp when it loads `.mcp.json`
3. When `/implement` runs:
   - Skill delegates to agent via Task tool
   - Task tool spawns agent as **subprocess**
   - Subprocess has its own process space
   - Subprocess reads `.mcp.json` → spawns **ANOTHER** lean-lsp-mcp instance

**Result**: N Claude sessions + M concurrent `/implement` calls = N+M lean-lsp-mcp instances

**Why This Causes Deadlock**:

1. **Shared Resource Contention**:
   - `.lake/build/` directory (build artifacts)
   - `.lake/.lake.lock` file (build lock)
   - `.lake/manifest.json` (dependency manifest)

2. **Lock Ordering Issues**:
   - Server A acquires lock on `.lake/build/`
   - Server B waits for build lock
   - Server A tries to update manifest (locked by B's pending build)
   - **Deadlock**: Both wait indefinitely

3. **Zombie Accumulation**:
   - When deadlock occurs, `lake build` subprocess never completes
   - Parent (lean-lsp-mcp) doesn't reap completed children
   - Zombie forms, consuming PID space
   - Next attempt encounters same deadlock + zombie

### Evidence Summary

| Evidence | Observation |
|----------|-------------|
| Process count | 4 concurrent lean-lsp-mcp instances |
| Zombie presence | PID 962167 `[lake.orig] <defunct>` (child of 959260) |
| Hang location | First MCP call in agent (lean_diagnostic_messages) |
| Transcript | Shows MCP call initiated, never returns |
| Progress file | Never created (agent hangs before Stage 1.5) |
| Pre-build | Succeeds (proves lake works when only 1 server exists) |

---

## Solutions Attempted

### Phase 1: Preventive (Pre-Build) - ✅ IMPLEMENTED

**Goal**: Warm lake cache to reduce subprocess spawning

**Implementation**:
- Created `.claude/scripts/lean-pre-build.sh` (120s timeout)
- Integrated as Stage 2.7 in skill (runs before agent delegation)
- Non-blocking: failures logged but don't prevent implementation

**Effectiveness**:
- ✅ Reduces zombie formation **when only 1 server exists**
- ❌ Does NOT solve concurrent server problem (root cause)
- ✅ Still valuable: improves first-call latency

---

### Phase 2: Protective (Build Lock & Throttling) - ✅ IMPLEMENTED

**Goal**: Prevent concurrent `lake build` processes within single agent

**Implementation**:
- Progress tracking: `.agent-progress.json` (session_id, phase, operation)
- Build lock: `.diagnostic-lock` file (prevents concurrent diagnostics)
- `safe_diagnostic_call()` function (acquires lock, increments counters)
- Defensive strategy: throttle calls by ~50%, batch verification

**Effectiveness**:
- ✅ Prevents concurrent builds **within one agent**
- ❌ Does NOT prevent concurrent builds **across agents/servers**
- ❌ Never executes because agent hangs before reaching Stage 1.5

---

### Phase 3: Detective (Hang Detection) - ✅ IMPLEMENTED

**Goal**: Detect hangs faster (2.5 min vs 5 min)

**Implementation**:
- Reduced `MAX_MARKER_AGE_SECS` to 150s (2.5 min)
- Progress staleness check: `check_progress_staleness()` (180s)
- Concurrent build detection: `check_concurrent_builds()` (logs >3 builds)
- Progressive warnings at 90s and 150s

**Effectiveness**:
- ✅ Detects hangs faster (if they occur)
- ❌ Does NOT prevent hangs
- ❌ Progress file check doesn't work (file never created due to early hang)
- ✅ Concurrent build detection useful for diagnosis

---

### Phase 4: Observability (Documentation & Logging) - ✅ IMPLEMENTED

**Goal**: Comprehensive troubleshooting docs and audit trails

**Implementation**:
- Created `.claude/docs/diagnostics/lean-hang-mitigation.md`
- Added troubleshooting section to CLAUDE.md
- Enhanced zombie cleanup with `log_audit()` function
- Three log files: pre-build, postflight, zombie cleanup

**Effectiveness**:
- ✅ Excellent for debugging and understanding the system
- ✅ Enabled discovery of root cause (concurrent servers)
- ❌ Does NOT prevent or fix hangs

---

### Summary: Why Current Mitigation Doesn't Fix Root Cause

| Phase | Addresses | Misses |
|-------|-----------|--------|
| 1 (Pre-build) | Zombie reduction | Concurrent server conflicts |
| 2 (Throttling) | Intra-agent concurrency | Inter-agent/server concurrency |
| 3 (Detection) | Faster hang detection | Hang prevention |
| 4 (Observability) | Diagnosis capability | Root cause fix |

**Conclusion**: All 4 phases address **symptoms** (zombies, slow detection) but not **root cause** (concurrent servers).

---

## Current Mitigation System

### Active Components

1. **Pre-build** (`.claude/scripts/lean-pre-build.sh`):
   - Runs `lake build` before agent starts
   - Warms cache, reduces first-call latency
   - Non-blocking (failures don't prevent implementation)

2. **Zombie Cleanup** (`.claude/scripts/lean-zombie-cleanup.sh`):
   - Kills orphaned lean-lsp-mcp processes with zombie children
   - Age threshold: 5 minutes (configurable)
   - Audit logging to `.claude/logs/zombie-cleanup.log`

3. **Progress Tracking** (agent Stage 1.5):
   - Creates `.agent-progress.json` (heartbeat every 30s)
   - Tracks: session_id, phase, operation, diagnostic_calls, skipped_diagnostics
   - **Note**: Never executes due to early hang

4. **Build Lock** (`safe_diagnostic_call()` function):
   - Creates `.diagnostic-lock` file
   - Prevents concurrent diagnostic calls within agent
   - **Note**: Never executes due to early hang

5. **Hang Detection** (`.claude/hooks/subagent-postflight.sh`):
   - Marker age check: 150s threshold
   - Progress staleness: 180s threshold
   - Concurrent build detection: warns at >3 processes
   - Triggers zombie cleanup on detection

### Limitations

**What Works**:
- Pre-build successfully warms cache (when run with 1 server)
- Zombie cleanup successfully kills orphaned processes
- Hang detection successfully identifies stuck sessions
- Logging provides excellent diagnostic data

**What Doesn't Work**:
- ❌ None of this prevents concurrent server conflicts
- ❌ Agent hangs before progress tracking initializes
- ❌ Build lock never acquired (agent never reaches that code)
- ❌ 100% hang rate when multiple sessions exist

---

## Alternative Solutions

### Option 1: Manual Cleanup via /refresh (RECOMMENDED)

**Approach**: Enhance `/refresh` command to kill all lean-lsp-mcp instances

**Implementation**:
```bash
# In .claude/skills/skill-refresh/SKILL.md

### New Stage: Kill Lean MCP Servers (Optional)

echo "Cleaning up lean-lsp-mcp server instances..."

# Show current instances
INSTANCES=$(pgrep -af "lean-lsp-mcp" | wc -l)
echo "Found $INSTANCES lean-lsp-mcp instances"

if [ "$INSTANCES" -gt 1 ]; then
    echo "⚠️  Multiple instances detected (may cause deadlocks)"

    # Prompt user
    read -p "Kill all lean-lsp-mcp instances? [y/N] " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        pkill -9 -f "lean-lsp-mcp"
        sleep 2

        # Verify cleanup
        REMAINING=$(pgrep -c -f "lean-lsp-mcp" 2>/dev/null || echo "0")
        if [ "$REMAINING" -eq 0 ]; then
            echo "✓ All lean-lsp-mcp instances terminated"
        else
            echo "⚠️  $REMAINING instances still running"
        fi
    fi
fi
```

**Pros**:
- ✅ User controls when cleanup happens
- ✅ Doesn't interfere with concurrent workflows (user chooses timing)
- ✅ Simple implementation
- ✅ Works with existing `/refresh` command

**Cons**:
- ❌ Manual intervention required
- ❌ User must remember to run before Lean tasks
- ❌ Doesn't prevent problem, only fixes after it occurs

---

### Option 2: Automatic Warning System

**Approach**: Detect concurrent servers and warn user BEFORE running `/implement`

**Implementation**:
```bash
# In .claude/skills/skill-lean-implementation/SKILL.md
# Stage 2.4 (NEW): Concurrent Server Detection

### Stage 2.4: Concurrent Server Check (Pre-Delegation Warning)

echo "Checking for concurrent lean-lsp-mcp instances..."

INSTANCES=$(pgrep -af "lean-lsp-mcp" | wc -l)

if [ "$INSTANCES" -gt 2 ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️  WARNING: $INSTANCES lean-lsp-mcp instances detected"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Multiple concurrent instances cause deadlocks."
    echo "Recommendation: Run /refresh to clean up instances first"
    echo ""
    pgrep -af "lean-lsp-mcp" | head -10
    echo ""
    echo "Options:"
    echo "1. Continue anyway (may hang)"
    echo "2. Abort and run /refresh first (recommended)"
    echo ""

    # Non-interactive: just warn and continue
    echo "⚠️  Proceeding with implementation (risk of hang)"
    echo "If hang occurs, press Ctrl+C and run /refresh"
    echo ""
fi
```

**Pros**:
- ✅ User is informed of risk before hang occurs
- ✅ Doesn't kill instances (preserves concurrent workflows)
- ✅ Provides actionable guidance (/refresh)
- ✅ Non-blocking (just warns)

**Cons**:
- ❌ Doesn't prevent the problem
- ❌ Requires user action to fix
- ❌ May cause warning fatigue if always present

---

### Option 3: Shared Server Pool (COMPLEX)

**Approach**: Modify MCP configuration to use single shared server instance

**Requires**:
1. External server management (systemd service, Docker container)
2. TCP socket instead of stdio (multi-client support)
3. Connection pooling/load balancing
4. Session isolation (prevent cross-contamination)

**Implementation** (Conceptual):
```json
// .mcp.json
{
  "mcpServers": {
    "lean-lsp": {
      "type": "tcp",  // Instead of stdio
      "host": "localhost",
      "port": 7777,
      "maxConnections": 10
    }
  }
}
```

**Pros**:
- ✅ Solves root cause (only 1 server instance)
- ✅ Supports multiple concurrent clients
- ✅ No manual cleanup needed

**Cons**:
- ❌ Extremely complex to implement
- ❌ Requires lean-lsp-mcp server modifications (upstream change)
- ❌ May not be supported by lean-lsp-mcp architecture
- ❌ Introduces new failure modes (port conflicts, network issues)

---

### Option 4: Per-Project .lake Directory Isolation

**Approach**: Configure each server instance to use separate `.lake` directory

**Implementation**:
```json
// .mcp.json (multiple configs)
{
  "mcpServers": {
    "lean-lsp-1": {
      "command": "uvx",
      "args": ["lean-lsp-mcp"],
      "env": {
        "LEAN_PROJECT_PATH": "/home/benjamin/Projects/ProofChecker",
        "LAKE_HOME": "/tmp/lake-1"  // Isolated build dir
      }
    },
    "lean-lsp-2": {
      "command": "uvx",
      "args": ["lean-lsp-mcp"],
      "env": {
        "LEAN_PROJECT_PATH": "/home/benjamin/Projects/ProofChecker",
        "LAKE_HOME": "/tmp/lake-2"  // Different build dir
      }
    }
  }
}
```

**Pros**:
- ✅ Eliminates lock contention (each server has own `.lake`)
- ✅ Permits concurrent servers without conflict

**Cons**:
- ❌ May not be supported by lake build system
- ❌ Wastes disk space (duplicate builds)
- ❌ Doesn't share build artifacts (slower overall)
- ❌ Unclear if LAKE_HOME env var exists or works this way

---

### Option 5: Agent-Level Server Reuse

**Approach**: Configure Task tool to reuse parent process's MCP servers

**Requires**:
1. Claude Code modification to support server inheritance
2. Agent subprocess shares parent's MCP connection
3. IPC mechanism for MCP tool calls (from agent → parent → server)

**Implementation**: Not directly controllable by user (requires Claude Code changes)

**Pros**:
- ✅ Solves root cause (no new servers spawned)
- ✅ Natural solution (agents should inherit parent environment)
- ✅ No user intervention needed

**Cons**:
- ❌ Requires Claude Code architectural change
- ❌ Outside our control (must wait for upstream)
- ❌ May have unintended side effects

---

## Recommended Approach

### Immediate Solution (Manual Cleanup)

**Enhance `/refresh` with lean-lsp-mcp cleanup**:

1. Add optional stage to kill all lean-lsp-mcp instances
2. Prompt user for confirmation (shows instance count first)
3. Kill all instances with `pkill -9 -f lean-lsp-mcp`
4. Verify cleanup succeeded
5. User runs this BEFORE starting Lean implementations

**Usage Pattern**:
```bash
# At start of Lean work session
/refresh                 # Clean up stale instances

# Then run Lean implementations
/implement 630           # Now safe (only 1 server will spawn)
```

### Proactive Detection (Warning System)

**Add Stage 2.4 to lean-implementation skill**:

1. Check lean-lsp-mcp instance count
2. If >2 instances, warn user
3. Provide guidance to run /refresh
4. Continue anyway (non-blocking)

**User Experience**:
```
$ /implement 630

⚠️  WARNING: 4 lean-lsp-mcp instances detected
Multiple concurrent instances cause deadlocks.
Recommendation: Run /refresh to clean up instances first

If hang occurs, press Ctrl+C and run /refresh

Proceeding with implementation...
```

### Long-Term Monitoring

**Enhance zombie cleanup logging**:

Already implemented in Phase 4:
- Concurrent build detection in `check_concurrent_builds()`
- Audit logging shows instance counts
- Logs at `.claude/logs/zombie-cleanup.log`

**User can monitor trends**:
```bash
$ grep "concurrent_builds=" .claude/logs/zombie-cleanup.log
[2026-01-27T00:45:00Z] WARNING concurrent_builds=4 (Issue #118 indicator)
[2026-01-27T01:12:00Z] WARNING concurrent_builds=3 (Issue #118 indicator)
```

---

## Detection and Monitoring

### Pre-Implementation Check

**Manual check before running `/implement`**:
```bash
# Count lean-lsp-mcp instances
pgrep -af "lean-lsp-mcp" | wc -l

# If >1, run cleanup
/refresh  # (with enhanced lean-lsp-mcp kill option)
```

### During Implementation

**Monitor for hang indicators**:
1. Agent output stops updating (>2 minutes)
2. Last line shows MCP tool call with no result
3. Progress file doesn't get created (no `.agent-progress.json`)
4. CPU usage on lean-lsp-mcp process goes to 0% (waiting on lock)

**Recovery**:
1. Ctrl+C to abort
2. Run `/refresh` (kill all lean-lsp-mcp instances)
3. Retry `/implement`

### Post-Implementation

**Check logs for patterns**:
```bash
# Check for concurrent builds during last implementation
grep "concurrent_builds" .claude/logs/zombie-cleanup.log | tail -5

# Check for zombie accumulation
grep "ZOMBIES_FOUND" .claude/logs/zombie-cleanup.log | tail -5

# Check postflight hang detection
grep "DEADLOCK DETECTED" .claude/logs/subagent-postflight.log | tail -5
```

---

## Testing Checklist

### Test 1: Clean State (Baseline)

**Setup**:
1. Close all Claude Code sessions except one
2. Run `/refresh` (kill all lean-lsp-mcp instances if present)
3. Verify: `pgrep -c -f "lean-lsp-mcp"` returns 0 or 1

**Execute**:
```bash
/implement 630  # Or any Lean task
```

**Expected Result**:
- ✅ Pre-build runs successfully
- ✅ Agent starts and initializes progress tracking
- ✅ First MCP call (lean_diagnostic_messages) completes
- ✅ Implementation proceeds normally

**If this fails**: Problem is NOT concurrent servers (deeper issue)

---

### Test 2: Concurrent Sessions (Reproduce Problem)

**Setup**:
1. Open 3 Claude Code sessions (3 terminals)
2. Let each spawn lean-lsp-mcp naturally
3. Verify: `pgrep -c -f "lean-lsp-mcp"` returns ≥3

**Execute**:
```bash
/implement 630  # From one session
```

**Expected Result** (current behavior):
- ❌ Agent hangs on first MCP call
- ❌ No progress file created
- ❌ Output frozen at "lean-lsp - Diagnostics (MCP)(...)"

**Expected Result** (after fix):
- ✅ Warning displayed about concurrent instances
- ✅ User guided to run /refresh
- ⚠️  Implementation may hang (as predicted)

---

### Test 3: Manual Cleanup (Solution Validation)

**Setup**:
1. Reproduce problem (Test 2)
2. Abort hung implementation (Ctrl+C)

**Execute**:
```bash
/refresh  # Enhanced with lean-lsp-mcp kill option
# Select "yes" to kill lean-lsp-mcp instances

# Verify cleanup
pgrep -c -f "lean-lsp-mcp"  # Should be 0

# Retry implementation
/implement 630
```

**Expected Result**:
- ✅ /refresh kills all instances
- ✅ Retry implementation succeeds (like Test 1)
- ✅ Only 1 lean-lsp-mcp instance during execution

---

### Test 4: Warning System (Detection Validation)

**Setup**:
1. Spawn multiple lean-lsp-mcp instances (Test 2)
2. Don't run /refresh

**Execute**:
```bash
/implement 630  # Should show warning
```

**Expected Result**:
- ✅ Warning displayed: "N lean-lsp-mcp instances detected"
- ✅ Guidance provided: "Run /refresh to clean up"
- ✅ Process list shown (PIDs of instances)
- ⚠️  Implementation continues (with warning)

---

### Test 5: Monitoring Logs

**Setup**:
1. Run implementation (Test 1 or Test 3)

**Execute**:
```bash
# Check concurrent build detection
grep "concurrent_builds" .claude/logs/zombie-cleanup.log

# Check zombie cleanup events
grep "CLEANUP_START\|ZOMBIES_FOUND" .claude/logs/zombie-cleanup.log

# Check hang detection
grep "DEADLOCK\|HANG DETECTED" .claude/logs/subagent-postflight.log
```

**Expected Result**:
- ✅ Logs show structured audit trail
- ✅ Concurrent build count logged accurately
- ✅ Zombie counts tracked
- ✅ Hang events logged (if occurred)

---

## Implementation Plan for Solutions

### Phase A: Manual Cleanup Enhancement (2-3 hours)

**Modify `/refresh` command**:

1. **Add lean-lsp-mcp kill stage** (`.claude/skills/skill-refresh/SKILL.md`):
   ```bash
   ### Stage X: Lean MCP Server Cleanup (Optional)

   # Count instances
   INSTANCES=$(pgrep -af "lean-lsp-mcp" | wc -l)

   if [ "$INSTANCES" -gt 0 ]; then
       echo "Found $INSTANCES lean-lsp-mcp instance(s)"

       if [ "$INSTANCES" -gt 1 ]; then
           echo "⚠️  Multiple instances may cause deadlocks"
       fi

       # Interactive prompt (unless --force)
       if [ "$FORCE" != "true" ]; then
           read -p "Kill all lean-lsp-mcp instances? [y/N] " -n 1 -r
           echo
       else
           REPLY="y"
       fi

       if [[ $REPLY =~ ^[Yy]$ ]]; then
           pkill -9 -f "lean-lsp-mcp"
           sleep 2

           REMAINING=$(pgrep -c -f "lean-lsp-mcp" 2>/dev/null || echo "0")
           if [ "$REMAINING" -eq 0 ]; then
               echo "✓ All lean-lsp-mcp instances terminated"
           else
               echo "⚠️  $REMAINING instance(s) still running"
           fi
       fi
   else
       echo "No lean-lsp-mcp instances found"
   fi
   ```

2. **Update CLAUDE.md** with usage guidance:
   ```markdown
   ### Running Lean Implementations

   **Best Practice**: Run `/refresh` before Lean tasks to clean up stale MCP servers:

   ```bash
   /refresh          # Kill orphaned processes + lean-lsp-mcp instances
   /implement 630    # Now safe to run
   ```

   **Why**: Multiple concurrent lean-lsp-mcp instances cause deadlocks on MCP tool calls.
   ```

3. **Test**:
   - Spawn multiple instances
   - Run `/refresh`
   - Verify all killed
   - Run `/implement`
   - Verify succeeds

---

### Phase B: Warning System (1-2 hours)

**Add detection to skill**:

1. **Create Stage 2.4** (`.claude/skills/skill-lean-implementation/SKILL.md`):
   ```bash
   ### Stage 2.4: Concurrent Server Detection

   INSTANCES=$(pgrep -af "lean-lsp-mcp" | wc -l)

   if [ "$INSTANCES" -gt 2 ]; then
       echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
       echo "⚠️  WARNING: $INSTANCES lean-lsp-mcp instances detected"
       echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
       echo ""
       echo "Multiple instances increase deadlock risk."
       echo "Recommendation: Abort (Ctrl+C) and run /refresh first"
       echo ""
       echo "Active instances:"
       pgrep -af "lean-lsp-mcp" | head -10
       echo ""
       echo "Proceeding in 5 seconds (Ctrl+C to abort)..."
       sleep 5
   fi
   ```

2. **Test**:
   - Spawn multiple instances
   - Run `/implement`
   - Verify warning shown
   - Verify 5-second delay
   - Verify continues if not aborted

---

### Phase C: Documentation (1 hour)

**Create comprehensive troubleshooting guide**:

1. **This document** (`.claude/docs/diagnostics/lean-hang-root-cause-analysis.md`)
   - ✅ Already created

2. **Update CLAUDE.md**:
   - Add link to root cause analysis
   - Update troubleshooting section with /refresh guidance
   - Add "Before Running Lean Tasks" checklist

3. **Update lean-hang-mitigation.md**:
   - Add section on concurrent server problem
   - Link to this document
   - Update with /refresh enhancement

---

## Success Metrics

### Before Fix (Current State)

| Metric | Current Value |
|--------|---------------|
| Hang rate (multiple sessions) | 100% |
| Hang rate (single session) | ~40% (from earlier analysis) |
| Time to hang | <30 seconds (first MCP call) |
| Manual intervention required | Yes (Ctrl+C + kill processes) |
| User awareness of problem | Low (no warning) |

### After Fix (Target State)

| Metric | Target Value |
|--------|--------------|
| Hang rate (with /refresh) | <10% (only secondary issues) |
| Hang rate (without /refresh) | Still ~100% (but user warned) |
| Time to detection | <5 seconds (warning shows immediately) |
| Manual intervention | Simplified (/refresh command) |
| User awareness | High (warning system) |

---

## Appendix A: Process Tree Analysis

### Healthy State (1 Server)

```
$ pstree -p <lean-lsp-mcp-pid>
lean-lsp-mcp(799013)───lake serve(800000)
```

### Problematic State (4 Servers)

```
$ ps aux | grep lean-lsp-mcp
PID    USER     CMD
799013 benjamin lean-lsp-mcp  ← Session 1 (pts/12)
945764 benjamin lean-lsp-mcp  ← Session 2 (pts/3)
959260 benjamin lean-lsp-mcp  ← Session 3 (pts/1) - has zombie
962167 benjamin [lake] <defunct>  ← Zombie child of 959260
967445 benjamin lean-lsp-mcp  ← Session 4 (pts/7)
```

### After /refresh (Fixed)

```
$ pgrep -af lean-lsp-mcp
# (empty - all killed)

# After first MCP call
$ pgrep -af lean-lsp-mcp
999001 benjamin lean-lsp-mcp  ← Single instance (respawned on demand)
```

---

## Appendix B: Diagnostic Commands

### Quick Health Check

```bash
# Count instances
pgrep -c -f "lean-lsp-mcp"

# If >1, problem likely
```

### Detailed Analysis

```bash
# Show all instances with PIDs
pgrep -af "lean-lsp-mcp"

# Show process tree for each
pstree -p $(pgrep -f "lean-lsp-mcp" | head -1)

# Check for zombies
ps aux | grep -E '[l]ake.*defunct'

# Check .lake directory locks
lsof /home/benjamin/Projects/ProofChecker/.lake 2>/dev/null
```

### Force Cleanup

```bash
# Nuclear option (kills everything)
pkill -9 -f "lean-lsp-mcp"
pkill -9 -f "lake serve"

# Wait for termination
sleep 2

# Verify clean
pgrep -c -f "lean-lsp-mcp"  # Should be 0
```

---

## Appendix C: Known Upstream Issues

### lean-lsp-mcp Issue #115
- **Title**: Server halts on lean_diagnostic_messages after import edits
- **Status**: Fixed in Lean v4.26.0+
- **ProofChecker Status**: Using v4.27.0-rc1 ✅
- **Link**: https://github.com/oOo0oOo/lean-lsp-mcp/issues/115

### lean-lsp-mcp Issue #118
- **Title**: Concurrent builds exhaust memory
- **Status**: Open feature request
- **Impact**: Multiple lake build processes cause memory exhaustion
- **Our Mitigation**: Build lock, diagnostic throttling
- **Link**: https://github.com/oOo0oOo/lean-lsp-mcp/issues/118

### Claude Code Issue #15945
- **Title**: Critical MCP server 16+ hour hang
- **Status**: Open
- **Impact**: 70+ zombie processes, system unresponsive
- **Relevance**: Confirms MCP timeout issues are broader ecosystem problem
- **Link**: https://github.com/anthropics/claude-code/issues/15945

---

**End of Document**
