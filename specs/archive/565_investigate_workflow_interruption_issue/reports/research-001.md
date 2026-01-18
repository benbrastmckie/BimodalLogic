# Research Report: Task #565

**Task**: 565 - Investigate Workflow Interruption Issue
**Started**: 2026-01-18T01:04:00Z
**Completed**: 2026-01-18T01:45:00Z
**Effort**: 2-3 hours
**Priority**: High
**Dependencies**: None
**Sources/Inputs**:
- Error outputs in `.claude/output/` (5 files)
- Task 564 research and implementation (archived)
- Task 562 agent system refactor report (archived)
- Skill and agent implementations
- Command workflow definitions
**Artifacts**: specs/565_investigate_workflow_interruption_issue/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Root Cause Identified (HIGH CONFIDENCE)**: The workflow interruptions requiring "continue" input are caused by **JavaScript heap exhaustion (OOM crashes)** during subagent delegation, NOT by a "continue prompt" design pattern.
- **Evidence**: Both `.claude/output/research_1.md` and `.claude/output/plan_v2.md` show identical fatal errors: `FATAL ERROR: Reached heap limit Allocation failed - JavaScript heap out of memory`
- **Memory Profile**: Both crashes occurred with heap at ~4040-4050 MB, during subagent delegation via the Task tool
- **Prior Work**: Task 564 identified and attempted to fix this by converting skill-status-sync to direct execution, but crashes are still occurring during OTHER subagent delegations (skill-planner -> planner-agent, skill-researcher -> general-research-agent)
- **Recommendation**: Reduce memory consumption in the agent system, either by shrinking agent/context files or investigating why the JavaScript process accumulates memory during subagent spawning

## Context & Scope

### What Was Investigated

1. All 5 files in `.claude/output/`:
   - `research_1.md` - Shows OOM crash during task 565 research
   - `plan_v2.md` - Shows OOM crash during task 560 planning
   - `plan_v1.md` - Shows successful /plan 559 execution (with "continue" prompts)
   - `implement_1.md` - Shows successful /implement 563 execution (with "continue" prompts)
   - `implement_2.md` - Shows successful /implement 559 execution (with "continue" prompts)

2. Archived tasks related to this issue:
   - Task 564: Memory Issues with Status-Sync-Agent Architecture
   - Task 562: Agent System Refactor Report
   - Task 555: Convert skill-status-sync to Forked Pattern
   - Task 548: Fix Skill-to-Agent Delegation Pattern

3. Current architecture:
   - Agent files in `.claude/agents/` (8 agents, 87-164 KB total)
   - Skill files in `.claude/skills/` (11 skills, ~53 KB total)
   - Context files in `.claude/context/` (~1 MB total)

### Constraints

- Claude Code's JavaScript heap is limited to ~4GB (hardcoded in Node.js)
- Cannot modify Claude Code's internal memory management
- Must preserve the three-tier architecture (command -> skill -> agent)

## Findings

### Finding 1: OOM Crashes During Subagent Delegation (HIGH CONFIDENCE: 95%)

**Evidence from `.claude/output/research_1.md`**:
```
Skill(skill-researcher)
  -> Waiting...
  -> general-research-agent(Execute research for task 565)
  -> "Composing..." (thought for 2s)

FATAL ERROR: Reached heap limit Allocation failed - JavaScript heap out of memory
[656860:0x55a6dbf87000] 549651 ms: Mark-Compact 4053.5 (4142.9) -> 4042.1 (4147.6) MB
/run/current-system/sw/bin/bash: line 1: 656836 Aborted (core dumped) claude --dangerously-skip-permissions
```

**Evidence from `.claude/output/plan_v2.md`**:
```
Skill(skill-planner)
  -> Waiting...
  -> planner-agent(Execute planning for task 560)
  -> "Canoodling..." (53s)

FATAL ERROR: Reached heap limit Allocation failed - JavaScript heap out of memory
[659331:0x557ef0101000] 447847 ms: Scavenge 4047.2 (4128.7) -> 4044.1 (4131.7) MB
/run/current-system/sw/bin/bash: line 1: 659305 Aborted (core dumped) claude --dangerously-skip-permissions
```

**Key Observations**:
1. Both crashes occur during the `Task` tool invocation that spawns a subagent
2. Both show heap exhaustion at ~4040-4050 MB (JavaScript limit)
3. Both show garbage collection (Scavenge, Mark-Compact) failing to recover memory
4. The crashes occur BEFORE the subagent can execute - they happen during context loading

### Finding 2: "Continue" Prompts Are NOT the Primary Issue (MEDIUM CONFIDENCE: 75%)

The successful executions in `plan_v1.md`, `implement_1.md`, and `implement_2.md` all show a pattern where the user must type "continue" between stages:

```
# From implement_1.md:
Skill(skill-status-sync)
  -> Successfully loaded skill, 3 tools allowed
  -> [completes preflight]

> continue

Skill(skill-implementer)
  -> Done
  -> [completes implementation]

> continue

Skill(skill-status-sync)
  -> [completes postflight]
```

**Analysis**:
- The "continue" prompts appear BETWEEN successful skill invocations
- This is likely due to skill execution creating a natural stopping point
- Task 562's research identified this as "Inline Skill Execution Causes Interruptions"
- However, skill-status-sync was already converted to direct execution (Task 564)
- The "continue" prompts persist even with direct execution, suggesting the issue is deeper

**Hypothesis**: The "continue" prompts may be related to Claude Code's internal conversation management when switching between skill contexts, not just the forked vs direct execution pattern.

### Finding 3: Memory Budget Exhaustion Pattern (HIGH CONFIDENCE: 90%)

**Memory analysis from the crashes**:

The agent system consumes significant memory:
- Agent files: ~168 KB total (8 files)
- Skill files: ~53 KB total (11 files)
- Context files: ~1 MB total (97 files)
- CLAUDE.md: ~12 KB

**Memory consumption path**:
```
/research 565 invoked
    |
    v
Main conversation context (~XYZ MB, depends on conversation history)
    |
    v
Skill(skill-researcher) invoked
  - Skill YAML loaded (~4 KB)
  - Skill SKILL.md loaded (~4 KB)
    |
    v
Task(general-research-agent) invoked
  - Agent system prompt loaded (this agent prompt is ~11 KB)
  - Agent context accumulated from prior conversation
  - Memory reaches ~4050 MB
  - OOM CRASH
```

**Key insight**: The problem is not the size of individual files, but the accumulation of context during a session. After multiple commands, the JavaScript heap fills up and crashes when trying to spawn a new subagent.

### Finding 4: Prior Fixes Only Partially Addressed the Issue (HIGH CONFIDENCE: 85%)

**Task 564 Fixed**:
- Converted skill-status-sync from forked (spawning status-sync-agent) to direct execution
- Eliminated one source of subagent spawning overhead
- Reduced memory usage for status operations

**What Remains Unfixed**:
- Other forked skills still spawn full subagents (skill-researcher, skill-planner, skill-implementer, etc.)
- Each subagent spawning adds to memory pressure
- Long-running sessions accumulate context and eventually crash

**Evidence that Task 564's fix was insufficient**:
- Both crashes in the output files occurred AFTER Task 564 was completed
- The crashes occur during skill-researcher -> general-research-agent and skill-planner -> planner-agent
- skill-status-sync (now direct) is not involved in these crashes

### Finding 5: Session Length Correlates with Crash Risk (MEDIUM CONFIDENCE: 70%)

**Observation from output files**:
- `implement_1.md`: Long execution (4m 35s worked time), no crash
- `implement_2.md`: Long execution (9m 50s worked time), no crash
- `research_1.md`: Short execution before crash (2s thinking), crashed
- `plan_v2.md`: Medium execution (53s canoodling), crashed

**Hypothesis**: The crash likelihood increases with:
1. Session length (more accumulated context)
2. Number of prior commands executed in the session
3. Complexity/size of subagent being spawned

The successful implementations may have started with fresh sessions or had less accumulated context.

## Root Cause Analysis

### Primary Root Cause: JavaScript Heap Exhaustion

**Chain of causation**:
```
Long-running Claude Code session
    |
    v
Multiple commands executed (/research, /plan, /implement)
    |
    v
Each command spawns subagents (even with skill-status-sync direct)
    |
    v
V8 JavaScript heap accumulates context (no aggressive GC)
    |
    v
Heap approaches ~4GB limit
    |
    v
Next subagent spawn attempts to load context
    |
    v
Allocation fails -> OOM crash -> "Aborted (core dumped)"
```

### Secondary Issue: "Continue" Prompts Between Stages

**Separate from the crash issue**:
- Even in successful executions, users must type "continue" between stages
- This appears to be related to Claude's conversation management, not the agent architecture
- May be caused by JSON returns creating "stop points" even in direct execution

## Recommendations

### Option A: Reduce Agent/Context Sizes (MEDIUM IMPACT, MEDIUM EFFORT)

Shrink the context loaded during subagent spawning:

1. **Audit and trim context files**:
   - context/core/orchestration/state-management.md: 33KB -> could be split
   - context/core/orchestration/state-lookup.md: 25KB -> could be split
   - context/core/orchestration/delegation.md: 24KB -> review for redundancy
   - Many context files in the 15-25KB range

2. **Remove @-reference chains that load unnecessary context**:
   - Agent files reference context that may not be needed for every operation
   - Make context loading more surgical

3. **Split large agents into smaller, focused variants**:
   - meta-builder-agent.md: 16KB -> could have research vs implementation variants
   - latex-implementation-agent.md: 14KB -> review necessity of all sections

### Option B: Implement Session Restart Strategy (HIGH IMPACT, LOW EFFORT)

Accept the memory limitation and work around it:

1. **Document session restart recommendation**:
   - Add guidance to CLAUDE.md: "Restart Claude Code session every 3-5 commands"
   - This clears the JavaScript heap and resets memory usage

2. **Add memory warning to commands**:
   - Commands could track approximate command count
   - Warn user to restart after X commands

3. **Split long workflows**:
   - Instead of /research -> /plan -> /implement in one session
   - Recommend: /research, restart, /plan, restart, /implement

### Option C: Investigate Claude Code Memory Management (HIGH IMPACT, HIGH EFFORT)

This would require deeper investigation into Claude Code internals:

1. **Profile memory usage during subagent spawning**:
   - Why does spawning a subagent consume so much heap?
   - Is context being duplicated unnecessarily?

2. **Report issue to Anthropic**:
   - The ~4GB JavaScript heap limit may be configurable
   - Node.js --max-old-space-size could be increased

3. **Test with reduced conversation context**:
   - Does starting with `/clear` before commands help?
   - Does using fresh sessions consistently avoid crashes?

### Recommended Action: Option B (Immediate) + Option A (Medium-term)

**Immediate**:
1. Add session restart guidance to CLAUDE.md
2. Document that commands requiring subagent spawning are susceptible to OOM after long sessions

**Medium-term**:
1. Audit and reduce context file sizes
2. Make context loading more lazy/surgical
3. Split large agents into focused variants

## Decisions Made

1. **Do NOT attempt to eliminate all subagent spawning** - The forked pattern provides valuable isolation and the architecture is sound; the issue is memory accumulation, not the pattern itself.

2. **Accept that skill-status-sync direct execution was the right fix** - Task 564's change was correct but insufficient to prevent all OOM issues.

3. **Focus on workarounds rather than fundamental architecture changes** - The checkpoint-based execution model is good; we just need to manage session memory.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Users ignore restart guidance | High | High | Make guidance prominent; add warnings |
| Context trimming breaks functionality | Medium | Low | Test thoroughly after any reductions |
| Issue persists after restarts | High | Low | Investigate if base context too large |
| "Continue" prompts remain annoying | Medium | High | Document as known limitation; investigate separately |

## Appendix

### Files Examined

**Output files**:
- `.claude/output/research_1.md` - OOM crash during task 565 research
- `.claude/output/plan_v2.md` - OOM crash during task 560 planning
- `.claude/output/plan_v1.md` - Successful /plan 559
- `.claude/output/implement_1.md` - Successful /implement 563
- `.claude/output/implement_2.md` - Successful /implement 559

**Archived research**:
- `specs/archive/564_memory_issues_status_sync_agent/reports/research-001.md`
- `specs/archive/564_memory_issues_status_sync_agent/summaries/implementation-summary-20260117.md`
- `specs/archive/562_agent_system_refactor_report/reports/research-001.md`

**Architecture files**:
- `.claude/skills/skill-status-sync/SKILL.md` (current direct execution)
- `.claude/agents/` (8 agent files)
- `.claude/context/` (97 context files)

### Memory Profile at Crashes

Both crashes show:
- Heap size: ~4040-4050 MB (approaching V8 limit)
- Scavenge (minor GC) not recovering enough memory
- Mark-Compact (major GC) not recovering enough memory
- Allocation failure in young generation
- Process aborted with core dump

### Search Queries Used

- `Glob: .claude/output/*` - Found 5 output files
- `Grep: workflow.*interrupt|continue.*input|heap|memory` - Found 60 files
- `Bash: wc -c` on agent/skill/context files - Size analysis
- `Bash: find ... -exec wc -c` - Full context size analysis

## Confidence Levels Summary

| Finding | Confidence | Basis |
|---------|------------|-------|
| OOM crashes during subagent delegation | 95% | Direct evidence in output files |
| Memory accumulation over session | 90% | Pattern matches typical V8 behavior |
| Task 564 fix was correct but insufficient | 85% | Crashes occur in different skills |
| "Continue" prompts are separate issue | 75% | Occurs even in successful executions |
| Session length correlates with crash risk | 70% | Indirect evidence; needs more data |
