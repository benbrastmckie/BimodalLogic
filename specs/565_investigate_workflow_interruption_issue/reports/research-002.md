# Research Report: Task #565 (Supplemental)

**Task**: 565 - Investigate Workflow Interruption Issue (JavaScript Memory Focus)
**Started**: 2026-01-18T02:00:00Z
**Completed**: 2026-01-18T02:45:00Z
**Effort**: 1-2 hours
**Priority**: High
**Dependencies**: research-001.md findings
**Sources/Inputs**:
- Web research on Claude Code memory issues
- GitHub issues from anthropics/claude-code repository
- Node.js memory management documentation
- Agent system architecture files
- Claude Code subagent documentation
**Artifacts**: specs/565_investigate_workflow_interruption_issue/reports/research-002.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Root cause confirmed**: JavaScript heap exhaustion during subagent spawning is a known issue affecting Claude Code users across platforms, documented in multiple GitHub issues (#18011, #5066, #2278, #1421, others)
- **Memory accumulation mechanism**: V8 heap accumulates from (1) conversation context retention, (2) tool result processing, (3) compaction summaries not being garbage collected, and (4) ChildProcess instances retained after subprocess exit
- **Six mitigation strategies identified**, ranging from immediate workarounds (NODE_OPTIONS, session restarts) to architectural changes (context trimming, direct execution conversion)
- **Anthropic response**: Issues remain open without official fixes as of January 2026, suggesting this is an upstream limitation rather than a bug we can fix directly

## Context & Scope

### Focus of This Research

This supplemental report focuses specifically on the question from research-001.md: "Why does the JavaScript process accumulate memory during subagent spawning?" and provides a comprehensive range of solutions.

### Key Questions Addressed

1. What is the memory accumulation mechanism in Claude Code?
2. Is this a known issue? What has Anthropic said?
3. What workarounds exist (immediate, short-term, long-term)?
4. How can the agent system be modified to reduce memory pressure?

## Findings

### Finding 1: Confirmed Known Issue (CONFIDENCE: 95%)

Multiple GitHub issues document identical symptoms:

| Issue | Title | Status | Date |
|-------|-------|--------|------|
| [#18011](https://github.com/anthropics/claude-code/issues/18011) | Memory leak causing V8 OOM crashes | Open | Jan 2026 |
| [#5066](https://github.com/anthropics/claude-code/issues/5066) | Node.js Heap Overflow in Sub-Agents | Closed (dup) | Aug 2025 |
| [#10592](https://github.com/anthropics/claude-code/issues/10592) | Heap OOM parsing large .claude.json | Open | Oct 2025 |
| [#3931](https://github.com/anthropics/claude-code/issues/3931) | Fatal Memory Allocation cross-platform | Open | Jul 2025 |
| [#2278](https://github.com/anthropics/claude-code/issues/2278) | Heap Out of Memory Error | Open | Jun 2025 |
| [#1421](https://github.com/anthropics/claude-code/issues/1421) | Recurring crashes while 'thinking' | Open | May 2025 |

**Key insight from issue #18011**: Sessions with 35MB state (1,467 JSONL entries) and 155k+ tokens show progressive memory growth. 7+ auto-compactions show memory leaks with each cycle - suggesting summaries/context are not properly garbage collected.

### Finding 2: Memory Accumulation Mechanism (CONFIDENCE: 90%)

The V8 heap accumulates memory from multiple sources:

#### Source 1: Conversation Context Retention
```
Each API call includes full conversation history
  -> Turn 50 = 50 exchanges worth of tokens
  -> Without compaction, this grows unbounded
  -> Compaction creates summaries that also accumulate
```

#### Source 2: Tool Result Processing (SetConstructor)
From issue #18011 crash analysis:
```
3 parallel tool calls (2x Grep, 1x Read)
Grep returned 128 lines
CRASH during SetConstructor (V8 building Set from tool results)
```
Tool outputs may not be properly garbage collected after processing.

#### Source 3: ChildProcess Retention (Node.js Bug)
From [Node.js issue #15651](https://github.com/nodejs/node/issues/15651):
```
"Even after child-processes exited, ChildProcess-instances
are retained in the master process"

Using subprocess.disconnect() partly fixes the issue
Full fix required cleanup of net.Server#_workers array
```

The Task tool spawns subagents as child processes. If Claude Code doesn't properly disconnect/cleanup, ChildProcess instances accumulate.

#### Source 4: Background Process Leaks
From issue #18011: "Idle sessions crash despite no active tool usage, indicating MCP polling, event listeners, or statusline updates leak memory."

### Finding 3: Platform/Configuration Independence (CONFIDENCE: 85%)

Issue #3931 reports: "Crashes occur well before system memory limits, and NODE_OPTIONS is respected with heap limits increasing as expected, but crashes still occur."

This indicates the problem is not simply heap size limitation - there's genuine memory leak behavior. However, increasing heap size does delay crashes.

Verified cross-platform:
- Linux (WSL2 Ubuntu, NixOS)
- macOS (Apple Silicon)
- Windows (32GB systems)

### Finding 4: Subagent Context Model (CONFIDENCE: 90%)

From [Claude Code documentation](https://code.claude.com/docs/en/sub-agents):

> "Each subagent invocation creates a new instance with fresh context. Subagents receive only their system prompt plus basic environment details, not the full Claude Code system prompt."

This isolation is intentional and beneficial - the problem is the JavaScript process hosting the subagent, not the subagent's context itself.

From [RichSnapp's analysis](https://www.richsnapp.com/article/2025/10-05-context-management-with-subagents-in-claude-code):

> "Running N tasks means (X + Y + Z) * N tokens in your main window. The subagent solution is to farm out work to specialized agents which only return final answers."

The agent system already follows this pattern. The memory issue is in Claude Code's JavaScript runtime, not in our agent architecture.

## Mitigation Strategies

### Strategy 1: Increase V8 Heap Size (IMMEDIATE, LOW EFFORT)

**Implementation**:
```bash
# Add to shell profile (~/.bashrc, ~/.zshrc, etc.)
export NODE_OPTIONS="--max-old-space-size=8192"
```

**Tradeoffs**:
| Pro | Con |
|-----|-----|
| Immediate effect | Delays crash, doesn't fix leak |
| No code changes needed | Requires 8GB+ available RAM |
| Works cross-platform | May cause system memory pressure |

**Memory sizing guide** (from [AppSignal](https://blog.appsignal.com/2021/12/08/nodejs-memory-limits-what-you-should-know.html)):
```
System RAM | Recommended --max-old-space-size
8GB        | 4096 (4GB)
16GB       | 8192 (8GB)
32GB       | 16384 (16GB)
64GB       | 24576 (24GB)
```

### Strategy 2: Session Restart Cadence (IMMEDIATE, LOW EFFORT)

**Pattern**:
```
Every 3-5 commands: exit claude, restart fresh
After any /implement: restart (highest memory operation)
After OOM warning signs: restart immediately
```

**Warning signs**:
- Long pauses before "thinking"
- Slowdown in tool response times
- Auto-compaction triggered

**Documentation addition** (to CLAUDE.md):
```markdown
## Memory Management

Claude Code sessions accumulate memory during subagent operations.
To prevent OOM crashes:

1. Restart Claude Code every 3-5 workflow commands
2. Restart after any /implement command completes
3. If response becomes slow, restart immediately
4. Use `export NODE_OPTIONS="--max-old-space-size=8192"` for larger heap
```

### Strategy 3: Reduce Context File Sizes (SHORT-TERM, MEDIUM EFFORT)

Current context file sizes:
```
33KB  state-management.md
25KB  state-lookup.md
24KB  architecture.md
24KB  delegation.md
23KB  error-handling.md
22KB  routing.md
22KB  orchestrator.md
22KB  command-structure.md
... (~1MB total in .claude/context/)
```

**Reduction targets**:
1. **Split large files**: state-management.md (33KB) -> state-read.md + state-write.md
2. **Remove redundancy**: Many files repeat similar patterns
3. **Extract examples**: Move examples to separate reference files loaded on-demand

**Estimated reduction**: 30-40% by deduplication and splitting.

### Strategy 4: Convert More Skills to Direct Execution (SHORT-TERM, MEDIUM EFFORT)

Task 564 converted `skill-status-sync` from forked to direct execution. Same pattern can apply to:

| Skill | Current | Candidate for Direct? |
|-------|---------|----------------------|
| skill-git-workflow | forked | Yes - simple git operations |
| skill-orchestrator | direct | Already direct |
| skill-status-sync | direct | Already converted (Task 564) |

**Pattern**: Skills that perform simple, deterministic operations without needing extensive context can run directly in the main conversation.

### Strategy 5: Minimize Agent Prompt Sizes (MEDIUM-TERM, MEDIUM EFFORT)

Current agent sizes:
```
16KB  meta-builder-agent.md
14KB  latex-implementation-agent.md
14KB  lean-implementation-agent.md
12KB  general-implementation-agent.md
12KB  lean-research-agent.md
11KB  general-research-agent.md
11KB  planner-agent.md
9KB   document-converter-agent.md
```

**Reduction strategies**:
1. **Move examples to @-references**: "See X for examples" instead of inline
2. **Create focused variants**: meta-builder-research-agent vs meta-builder-implement-agent
3. **Use inheritance pattern**: Base agent + domain-specific additions

**Estimated impact**: 20-30% reduction possible.

### Strategy 6: External Process Delegation (LONG-TERM, HIGH EFFORT)

Instead of Claude Code's Task tool, delegate heavy operations to external processes:

**Approach A: Parallel `claude -p` scripts**
```bash
# Instead of Task tool subagent:
claude -p "in /pathA research X" &
claude -p "in /pathB research Y" &
wait
```

This spawns separate Claude Code processes, each with fresh heap.

**Approach B: Bash-based orchestration**
```bash
# research.sh
#!/bin/bash
claude -p "Research task $1" > "specs/$1/reports/research.md"
```

The main session invokes scripts rather than subagents.

**Tradeoffs**:
| Pro | Con |
|-----|-----|
| Each process has fresh heap | Loses integration with main session |
| True parallelism | Complex coordination |
| Scalable | Requires external scripting |

## Recommendations Matrix

| Strategy | Impact | Effort | Timeline | Recommendation |
|----------|--------|--------|----------|----------------|
| NODE_OPTIONS 8GB | Medium | Low | Immediate | **Do now** |
| Session restart cadence | Medium | Low | Immediate | **Do now** |
| Document in CLAUDE.md | Low | Low | Immediate | **Do now** |
| Reduce context sizes | Medium | Medium | 1-2 weeks | Plan task |
| More direct execution | Medium | Medium | 1-2 weeks | Plan task |
| Minimize agent prompts | Low | Medium | 2-4 weeks | Consider |
| External delegation | High | High | Long-term | Investigate only |

## Decisions Made

1. **Do NOT attempt to fix Claude Code internals** - This is an upstream issue that Anthropic needs to address. Our mitigations are workarounds.

2. **Session restarts are acceptable** - Given that each workflow command is self-contained with state in state.json, restarting between commands loses no critical state.

3. **Focus on reducing memory pressure** - Converting skills to direct execution and trimming context files are within our control and provide measurable benefit.

4. **Monitor Anthropic's GitHub** - Issues #18011 and #5066 may receive fixes. Check periodically.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| 8GB heap insufficient for long sessions | High | Medium | Combine with session restarts |
| Users forget to restart | Medium | High | Add warning to CLAUDE.md prominently |
| Context reduction breaks functionality | Medium | Low | Test thoroughly; keep backups |
| Direct execution increases main context | Low | Medium | Only convert truly simple skills |

## Appendix

### Search Queries Used

- "Claude Code CLI memory usage subagent forking JavaScript heap exhaustion"
- "Node.js JavaScript heap memory leak Task tool subprocess spawning"
- "Claude Code Task tool subagent context accumulation memory workaround"
- "Node.js V8 heap memory --max-old-space-size increase"

### GitHub Issues Examined

- [#18011](https://github.com/anthropics/claude-code/issues/18011) - Most detailed crash analysis
- [#5066](https://github.com/anthropics/claude-code/issues/5066) - Sub-agent specific
- [#15651](https://github.com/nodejs/node/issues/15651) - Node.js fork() leak (fixed, but similar pattern)
- [#3931](https://github.com/anthropics/claude-code/issues/3931) - Cross-platform confirmation

### External References

- [Node.js Memory Limits](https://blog.appsignal.com/2021/12/08/nodejs-memory-limits-what-you-should-know.html) - AppSignal guide
- [Context Management with Subagents](https://www.richsnapp.com/article/2025/10-05-context-management-with-subagents-in-claude-code) - Best practices
- [Claude Code Subagent Docs](https://code.claude.com/docs/en/sub-agents) - Official documentation
- [Understanding --max-old-space-size](https://medium.com/@nagasai317/understanding-max-old-space-size-in-node-js-a-deep-dive-into-memory-management-7955e9d79ad0) - Deep dive

### Agent System Size Analysis

**Total sizes**:
```
.claude/agents/     ~100KB (8 files)
.claude/skills/     ~53KB (11 files)
.claude/context/    ~1MB (97 files)
.claude/CLAUDE.md   ~12KB
```

**Largest context files** (candidates for splitting):
```
33KB  core/orchestration/state-management.md
25KB  core/orchestration/state-lookup.md
24KB  core/orchestration/architecture.md
24KB  core/orchestration/delegation.md
23KB  core/standards/error-handling.md
```

## Confidence Levels Summary

| Finding | Confidence | Basis |
|---------|------------|-------|
| Known issue in Claude Code | 95% | Multiple GitHub issues, cross-platform reports |
| Memory accumulation mechanism | 90% | Issue #18011 detailed crash analysis |
| Context model is correct | 90% | Official docs confirm subagent isolation |
| Platform independence | 85% | Reports from Linux, macOS, Windows |
| NODE_OPTIONS workaround effective | 80% | User reports, but delays not prevents |
