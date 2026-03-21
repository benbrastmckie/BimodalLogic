# Research Report: Task #879

**Task**: 879 - Investigate and fix team mode context limit failures
**Started**: 2026-02-12T17:00:00Z
**Completed**: 2026-02-12T17:45:00Z
**Effort**: 2 hours
**Dependencies**: None
**Sources/Inputs**: implement.md output, Claude Code documentation, GitHub issues, codebase patterns
**Artifacts**: specs/879_team_mode_context_limit_failures/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Team mode implementation DID work correctly (agents spawned successfully for Wave 3)
- Agent ad8d16b hit context limit during complex Lean proof work (Phase 3: GH-controlled Lindenbaum)
- Root cause: Lean implementation work consumes context rapidly through repeated lean_goal calls, file reads, and verbose proof state outputs
- Context exhaustion is a fundamental constraint of the Claude context window when working on multi-hour proof engineering tasks
- Mitigations available but all involve tradeoffs (chunking phases, using /compact, or accepting partial progress)

## Context & Scope

### What Was Investigated

1. **The implement.md output** showing the exact failure point
2. **Team mode architecture** and teammate execution patterns
3. **Lean implementation agent patterns** that consume context
4. **Claude Code context management** features and known bugs
5. **Mitigation strategies** for long-running agent tasks

### Constraints

- Claude Code teammates cannot currently use /compact automatically
- Teammates have their own independent context windows
- No session resumption with in-process teammates
- Agent teams add coordination overhead and use significantly more tokens

## Findings

### 1. Failure Analysis from implement.md

**What Happened**:
```
Wave 3: [Phase 3, Phase 4] - parallel (both depend only on Phase 2)

● 2 lean-implementation-agent agents launched
   ├─ Phase 3: GH-controlled Lindenbaum
   └─ Phase 4: Seed consistency proofs

● Task Output ad8d16b
  ⎿  Task is still running…
  ⎿  Context limit reached · /compact or /clear to continue
```

**Key Observations**:
- Both agents spawned successfully
- Agent ad8d16b (Phase 3) exhausted context during execution
- Agent ad7d59c (Phase 4) may have succeeded or had similar issues
- The failure occurred mid-execution, not during startup

### 2. Context Consumption Patterns in Lean Implementation

**High-Context-Consuming Operations**:

| Operation | Token Cost | Frequency in Lean Work |
|-----------|-----------|----------------------|
| `lean_goal` calls | 500-2000 tokens each | Very high (recommended after every tactic) |
| File reads (Read tool) | 1000-5000 tokens | Frequent (large Lean files) |
| Proof state output | 200-1000 tokens | Accumulates with each goal check |
| `lean_multi_attempt` | 1000-3000 tokens | Moderate (exploratory) |
| `lake build` output | 500-2000 tokens | After each change |
| Error messages and diagnostics | Variable | When debugging |

**Context Budget Estimation**:

For a 200k token context window:
- System prompt + CLAUDE.md: ~5k tokens
- MCP tool definitions: ~18k tokens
- Plan file + phase details: ~3k tokens
- Working context: ~174k tokens remaining

For Phase 3 (GH-controlled Lindenbaum, 6-8 hour estimate):
- If checking lean_goal after every tactic (recommended): ~100+ calls
- Each call: ~1000 tokens average
- Goal checks alone: ~100k tokens
- File reads, edits, and outputs: ~50k+ tokens
- **Total estimated: 150k+ tokens** - approaching or exceeding limit

### 3. Claude Code Context Management Features

**Available Features**:
- `/compact` - Summarizes conversation, reduces context
- `/clear` - Clears context completely
- `autoCompact` setting - Automatic compaction when limits approached

**Known Bug (GitHub Issue #18159)**:
- Context limit reached even with 14-31% free space
- Stale token calculations not updating after compaction
- Status bar shows "0% remaining" while /context shows free space
- Affects Claude Opus 4.5 with extended thinking enabled

**Teammate Limitations**:
- Teammates cannot receive /compact commands during execution
- No automatic mid-task compaction available
- Teammates must be interrupted or killed to compact
- No session resumption with in-process teammates after interruption

### 4. Agent Team Token Costs

Per [Claude Code documentation](https://code.claude.com/docs/en/agent-teams):
- Agent teams use **significantly more tokens** than single sessions
- Each teammate has its own context window
- Token usage scales with number of active teammates
- Coordination overhead adds additional cost

**Implications for Lean Tasks**:
- Complex theorem proving (like Phase 3) can consume entire context window
- Multi-hour phases are at high risk of context exhaustion
- Parallel execution doubles/triples total token consumption

### 5. Patterns Contributing to Context Exhaustion

**Lean-Specific Patterns**:
1. **Verbose proof states**: Goal states with many hypotheses generate large outputs
2. **Tactic exploration**: lean_multi_attempt with many options
3. **Search tool usage**: lean_state_search and lean_hammer_premise return extensive results
4. **File reads**: ZornFamily.lean is 2000+ lines
5. **Iterative editing**: Multiple edit cycles accumulate context

**General Patterns**:
1. **Long conversations**: Each tool call/response accumulates
2. **Error recovery cycles**: Debug attempts add context
3. **Plan and context loading**: Initial context budget consumption
4. **Output verbosity**: Detailed progress reporting

## Mitigation Strategies

### Strategy 1: Phase Chunking (Recommended for Planning)

**Approach**: Break multi-hour phases into smaller sub-phases (30-60 min each)

**Pros**:
- Natural commit points for progress
- Enables resumption from partial completion
- Fits within context budget

**Cons**:
- Requires replanning existing tasks
- Overhead of phase transitions

**Implementation**:
- During `/plan`, estimate context consumption
- Split phases expected to exceed 60 minutes
- Add explicit save/verify points

### Strategy 2: Context-Aware Agent Prompts

**Approach**: Instruct agents to be context-efficient

**Prompt Additions**:
```
## Context Management
- Minimize lean_goal calls to 1 per tactic block (not per tactic)
- Use lean_multi_attempt to batch tactic exploration
- Avoid re-reading large files; use targeted line ranges
- Write progress to files frequently (enables resume)
- If approaching context limit, save progress and return partial
```

**Pros**:
- No structural changes needed
- Can be implemented immediately

**Cons**:
- May reduce proof quality (fewer state checks)
- Relies on agent adherence

### Strategy 3: Manual Intervention Points

**Approach**: Design workflows with human checkpoints

**Implementation**:
- Wave 3 phases start but lead monitors progress
- At 70% context usage, lead alerts user
- User can pause, compact, resume

**Pros**:
- Human oversight
- No automatic complexity

**Cons**:
- Requires active monitoring
- Breaks "fire and forget" team mode

### Strategy 4: Accept Partial Progress as Normal

**Approach**: Design for failure and recovery

**Implementation**:
- Agents write progress to phase result files continuously
- On context limit, return `partial` status with resume point
- Next `/implement` invocation resumes from partial
- Already partially supported via `[PARTIAL]` status markers

**Pros**:
- Aligns with existing error handling patterns
- No fundamental architecture change

**Cons**:
- Multiple runs needed for complex phases
- Coordination overhead

### Strategy 5: Single-Agent Fallback for Complex Phases

**Approach**: Route high-complexity phases to single agent with /compact capability

**Implementation**:
```
IF phase.estimated_effort > "4 hours":
    # Use single-agent mode with periodic /compact
    skill-lean-implementation (non-team)
ELSE:
    # Use teammate
    spawn_teammate()
```

**Pros**:
- Single agent CAN use /compact
- More reliable for long tasks

**Cons**:
- Loses parallelization benefits
- Contradicts --team flag intent

## Recommendations

### Immediate (For Task 870 Recovery)

1. **Mark Phase 3 as [PARTIAL]** in implementation-004.md
2. **Resume with single-agent** `/implement 870` to complete Phase 3
3. **Document partial progress** from agent ad8d16b output

### Short-Term (System Improvements)

1. **Update planner-agent** to estimate context consumption
2. **Split phases exceeding 60 minutes** into sub-phases
3. **Add context-efficiency guidance** to lean-implementation-agent prompt
4. **Document in error-handling.md** context limit as known teammate failure mode

### Long-Term (Architecture)

1. **Investigate Claude Code feature request** for teammate /compact support
2. **Consider subagent fallback** for complex phases (subagents return summarized results)
3. **Add context monitoring** to team lead for proactive intervention

## Decisions Made During Research

1. **Root cause identified**: Context exhaustion from Lean proof work, not team mode bug
2. **Primary mitigation selected**: Phase chunking + context-aware prompts
3. **Recovery approach**: Accept partial and resume with single-agent

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Context limit during any Lean phase | High | Medium | Phase chunking, partial acceptance |
| Phase 3 cannot be completed | Low | High | Sub-phase breakdown, manual intervention |
| Team mode unusable for Lean | Medium | Medium | Use for parallel research, single-agent for implementation |

## Appendix

### Search Queries Used
- "Claude Code context limit exceeded subagent teammate workaround 2026"
- Codebase patterns for team-wave-helpers, lean-implementation-agent

### References
- [Claude Code Agent Teams Documentation](https://code.claude.com/docs/en/agent-teams)
- [GitHub Issue #18159: Context limit reached with free space](https://github.com/anthropics/claude-code/issues/18159)
- [GitHub Issue #24773: Feature request for custom agent definitions](https://github.com/anthropics/claude-code/issues/24773)
- `.claude/docs/guides/context-loading-best-practices.md`
- `.claude/agents/lean-implementation-agent.md`
- `.claude/skills/skill-team-implement/SKILL.md`
- `.claude/utils/team-wave-helpers.md`
