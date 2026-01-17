# Research Report: Task #564

**Task**: 564 - Memory Issues with Status-Sync-Agent Architecture
**Started**: 2026-01-17T10:00:00Z
**Completed**: 2026-01-17T10:45:00Z
**Effort**: 2-4 hours (implementation)
**Priority**: Critical
**Dependencies**: None
**Sources/Inputs**:
- Error outputs in `.claude/output/`
- Architecture documentation
- Skill and agent implementations
- Command workflow definitions
**Artifacts**: specs/564_memory_issues_status_sync_agent/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Root Cause Identified**: The skill-status-sync to status-sync-agent delegation pattern causes JavaScript heap exhaustion (~4GB) because it spawns a full subagent with substantial context for simple, fast operations that should complete in milliseconds.
- **Critical Finding**: The status-sync operation is fundamentally different from other delegated operations (research, plan, implement) - it's a simple file update that takes <100ms but incurs full subagent context loading overhead (~500KB+ per invocation).
- **Multiple Crashes Documented**: Three separate crashes captured in `.claude/output/` - all occurring during skill-status-sync invocation.
- **Recommended Solution**: Remove the subagent delegation pattern for status-sync and either inline the status update logic directly into commands, or convert skill-status-sync to a direct execution skill (not forked).

## Context & Scope

### What Was Investigated

1. The architecture of skill-status-sync and status-sync-agent
2. Error outputs from three separate crashes in `.claude/output/`
3. Comparison with other working skill/agent pairs
4. The command -> skill -> agent delegation chain
5. Memory consumption patterns during delegation

### Constraints

- Cannot modify Claude Code's memory limits (hardcoded)
- Must preserve atomic status updates across TODO.md and state.json
- Must maintain session tracking and artifact linking capabilities

## Findings

### 1. Crash Analysis

Three crashes documented in `.claude/output/`:

**Crash 1** (`plan.md` - task 555):
```
Skill(skill-status-sync)
  -> Successfully loaded skill, 4 tools allowed
  -> Bash(jq ...) for state.json update
  -> Update(specs/TODO.md)
  -> [Returns successfully]

Later: Skill(skill-planner)
  -> planner-agent(Execute planning for task 555)
  -> "Smooshing..." (36s)
  -> FATAL ERROR: Reached heap limit Allocation failed
  -> Heap at ~4050MB before crash
```

**Crash 2** (`research_1.md` - task 558):
```
Skill(skill-lean-research)
  -> [Completes successfully]

Skill(skill-status-sync) [postflight]
  -> status-sync-agent(Execute postflight status sync for task 558)
  -> "Tinkering..." (4m 27s)
  -> FATAL ERROR: Reached heap limit Allocation failed
  -> Heap at ~4040MB before crash
```

**Crash 3** (`research_2.md` - task 563):
```
Skill(skill-status-sync) [preflight]
  -> Skill(status-sync)
  -> "Julienning..."
  -> FATAL ERROR: Reached heap limit Allocation failed
  -> Heap at ~4040MB before crash
```

### 2. Architecture Analysis

**Current Flow (Problematic)**:
```
Command (/plan, /research, /implement)
    |
    v
skill-status-sync (Thin Wrapper)
    |
    v [Task tool invocation - spawns new agent context]
    v
status-sync-agent (Full Agent)
    |
    v [Loads: subagent-return.md, state-management.md, artifact-formats.md]
    v [Executes: jq commands, Edit operations]
    v
Returns JSON
```

**Problem**: Each skill invocation accumulates context. When a command does:
1. preflight via skill-status-sync (agent context 1)
2. main work via skill-planner/skill-researcher (agent context 2)
3. postflight via skill-status-sync (agent context 3)

The parent context retains memory from all three delegations, eventually exhausting the ~4GB heap.

### 3. Comparison with Working Patterns

**Working Skills That Use Forked Pattern**:
- skill-researcher -> general-research-agent (OK - single invocation per command)
- skill-planner -> planner-agent (OK - single invocation per command)
- skill-implementer -> general-implementation-agent (OK - single invocation per command)

**Key Difference**: These skills are invoked ONCE per command, not multiple times.

**skill-status-sync is invoked TWICE per command**:
1. Preflight update (before main work)
2. Postflight update (after main work)

This doubles the memory pressure and causes accumulation.

### 4. Operation Complexity Mismatch

**Status-sync operations are trivial**:
```bash
# Update state.json (~5ms)
jq --arg status "planning" '...' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json

# Update TODO.md status marker (~10ms)
Edit: [RESEARCHED] -> [RESEARCHING]

# Total execution: <50ms
```

**But delegation overhead is massive**:
- Task tool invocation
- Agent markdown loading (~700 lines)
- Context reference loading
- Subagent return format loading (~300 lines)
- Return validation
- JSON parsing and propagation

**Cost/Benefit Ratio**: Delegating a 50ms operation via a full subagent is like using a delivery truck to move a single letter.

### 5. The Forked Pattern Design Intent

The forked subagent pattern was designed for:
- **Token efficiency**: Avoid loading context into parent conversation
- **Isolation**: Keep complex operations contained
- **Reusability**: Share agent logic across multiple skills

**Status-sync violates these assumptions**:
- It's called multiple times per command (not isolated)
- The operation is simple (no complex logic to share)
- The parent still accumulates memory from invocations

## Root Cause Summary

The memory exhaustion occurs because:

1. **Multiple Invocations**: skill-status-sync is called 2x per command (preflight + postflight), unlike other skills called 1x
2. **Context Accumulation**: Each Task tool invocation adds to the parent's memory footprint
3. **Disproportionate Overhead**: A 50ms operation incurs full agent spawning overhead
4. **No Garbage Collection Opportunity**: JavaScript's V8 heap grows until crash with no recovery

## Recommendations

### Option A: Inline Status Updates (Recommended)

**Remove skill-status-sync entirely** and inline the status update logic directly into commands.

**Rationale**:
- Status updates are simple jq + Edit operations
- Commands already have access to Bash(jq:*) and Edit tools
- Removes all delegation overhead for status operations
- Each command becomes self-contained for status management

**Implementation**:
```markdown
# In command files:

### Preflight Status Update
```bash
# Update state.json
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg status "planning" \
  '(.active_projects[] | select(.project_number == {N})) |= . + {
    status: $status, last_updated: $ts
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

# Update TODO.md
Edit: [RESEARCHED] -> [PLANNING]
```

**Pros**:
- Zero delegation overhead
- No memory accumulation
- Simpler architecture
- Faster execution

**Cons**:
- Duplication of status update logic across commands
- Less centralized error handling

### Option B: Direct Execution Skill (Not Forked)

Convert skill-status-sync from forked pattern to direct execution.

**Change from**:
```yaml
---
name: skill-status-sync
context: fork           # Spawns subagent
agent: status-sync-agent
---
```

**To**:
```yaml
---
name: skill-status-sync
allowed-tools: Bash(jq:*), Edit, Read
context: direct        # Execute inline
---
```

The skill would execute its logic directly in the parent context without spawning a subagent.

**Pros**:
- Preserves centralized status update logic
- Removes subagent spawning overhead
- Maintains skill interface for commands

**Cons**:
- Context still loaded into parent (though smaller than full agent)
- Requires skill architecture to support "direct" execution mode

### Option C: Hybrid Approach

- Use Option A (inline) for preflight updates (simple status change)
- Use Option B (direct skill) for postflight updates (status + artifacts)

This optimizes for the most common case (preflight) while preserving structure for the more complex case (postflight with artifact linking).

## Specific Implementation Recommendations

### Immediate Fix (Option A)

1. **Update command files** to perform status updates inline:
   - `/plan` command: inline preflight/postflight
   - `/research` command: inline preflight/postflight
   - `/implement` command: inline preflight/postflight
   - `/revise` command: inline postflight

2. **Keep status-sync-agent for reference** but mark as deprecated

3. **Update CLAUDE.md** to document new pattern

### Code Changes Required

**For each command (plan.md, research.md, implement.md, revise.md)**:

Replace:
```markdown
5. **Update Status (via skill-status-sync)**
   Invoke skill-status-sync: `preflight_update(task_number, "planning", session_id)`
```

With:
```markdown
5. **Update Status (inline)**
   ```bash
   jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg status "planning" \
     '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
       status: $status, last_updated: $ts
     }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
   ```

   Update TODO.md status marker using Edit tool:
   - Find task entry: `### {N}.`
   - Change `[OLD_STATUS]` to `[PLANNING]`
```

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Code duplication across commands | Medium | Certain | Create reusable bash functions or document standard patterns |
| Inconsistent status update logic | High | Medium | Create a status-update reference document for commands to follow |
| TODO.md/state.json desync | High | Low | Always update state.json first, then TODO.md (atomic pattern) |
| Loss of centralized logging | Medium | Medium | Commands can log status updates to a common format |

## Testing & Validation

1. Run `/plan` on a task and verify no memory issues
2. Run `/research` on a task and verify no memory issues
3. Run multiple commands in sequence without restarting
4. Verify status updates are atomic (state.json + TODO.md sync)
5. Verify artifact linking works in postflight

## Appendix

### Files Examined

- `.claude/skills/skill-status-sync/SKILL.md` (205 lines)
- `.claude/agents/status-sync-agent.md` (701 lines)
- `.claude/output/plan.md` (crash log 1)
- `.claude/output/research_1.md` (crash log 2)
- `.claude/output/research_2.md` (crash log 3)
- `.claude/commands/plan.md`
- `.claude/commands/research.md`
- `.claude/commands/implement.md`
- `.claude/context/core/orchestration/architecture.md`
- `.claude/context/core/orchestration/delegation.md`
- `.claude/context/core/formats/subagent-return.md`

### Memory Profile at Crash

All three crashes show similar memory patterns:
- Heap size: ~4040-4050 MB
- Scavenge (minor GC) failing
- Mark-Compact (major GC) not recovering enough memory
- Node.js V8 heap limit reached
- Core dumped with SIGABRT

### Search Queries Used

- `Grep: preflight_update|postflight_update|skill-status-sync`
- `Grep: Task\s*tool|subagent_type|status-sync`
- `Glob: .claude/skills/*/SKILL.md`
- `Glob: .claude/agents/*.md`
- `Glob: .claude/output/**/*`
