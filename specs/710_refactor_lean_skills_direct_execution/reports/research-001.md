# Research Report: Task #710

**Task**: 710 - Refactor Lean skills from subagent delegation to direct execution
**Started**: 2026-01-28T14:15:33Z
**Completed**: 2026-01-28T14:45:00Z
**Effort**: Medium (4-6 hours implementation)
**Priority**: High (blocking Lean workflow reliability)
**Dependencies**: None
**Sources/Inputs**: Codebase analysis of .claude/skills/ and .claude/agents/
**Artifacts**: - specs/710_refactor_lean_skills_direct_execution/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Current Lean skills use thin wrapper pattern delegating to subagents via Task tool
- MCP tools hang indefinitely in subagents due to Claude Code bugs (#15945, #13254, #4580) with no timeout mechanism
- Solution: Move MCP tool invocations from agents directly into skills, eliminating the problematic delegation layer
- Direct execution pattern already exists (skill-status-sync, skill-learn) and provides a proven template
- Migration preserves all functionality while improving reliability

## Context & Scope

### Problem Statement

The current architecture routes Lean operations through a two-layer delegation:

```
orchestrator → skill-lean-research → Task tool → lean-research-agent
orchestrator → skill-lean-implementation → Task tool → lean-implementation-agent
```

MCP tools (lean_goal, lean_leansearch, etc.) in subagents hang indefinitely with no timeout mechanism due to Claude Code platform bugs. When MCP calls hang, the entire subagent becomes unresponsive, losing all progress.

### Root Cause

Multiple Claude Code issues contribute to the hanging behavior:
1. **#15945** - MCP tools in subagents lack timeout enforcement
2. **#13254** - Subagent spawning creates isolated context without proper MCP lifecycle management
3. **#4580** - Task tool doesn't propagate abort signals to MCP calls
4. **#6594** - Shared AbortController cascading can cause unrelated tool failures

### Scope of Refactor

Two skills require migration:
1. `skill-lean-research` - Currently delegates to `lean-research-agent`
2. `skill-lean-implementation` - Currently delegates to `lean-implementation-agent`

## Findings

### Current Architecture Analysis

#### skill-lean-research (312 lines)

**Current Pattern**: Thin wrapper with internal postflight

**Execution Flow**:
1. Input validation (task exists, correct status)
2. Preflight status update to [RESEARCHING]
3. Create postflight marker file
4. Prepare delegation context
5. **Invoke Task tool with lean-research-agent** (PROBLEM AREA)
6. Read metadata file from subagent return
7. Postflight status update to [RESEARCHED]
8. Link artifacts
9. Git commit
10. Cleanup

**MCP Tools Used** (in lean-research-agent):
- `lean_leansearch` (rate limited 3/30s)
- `lean_loogle` (rate limited 3/30s)
- `lean_leanfinder` (rate limited 10/30s)
- `lean_local_search` (no limit)
- `lean_hover_info` (no limit)
- `lean_state_search` (rate limited 3/30s)
- `lean_hammer_premise` (rate limited 3/30s)

#### skill-lean-implementation (390 lines)

**Current Pattern**: Thin wrapper with internal postflight

**Execution Flow**:
1. Input validation (task exists, status allows implementation, language is lean)
2. Preflight status update to [IMPLEMENTING]
3. Create postflight marker file
4. Prepare delegation context
5. **Invoke Task tool with lean-implementation-agent** (PROBLEM AREA)
6. Read metadata file from subagent return
7. Postflight status update to [COMPLETED] or keep [IMPLEMENTING] for partial
8. Link artifacts
9. Git commit
10. Cleanup

**MCP Tools Used** (in lean-implementation-agent):
- `lean_goal` (most important, no limit)
- `lean_diagnostic_messages` (no limit)
- `lean_hover_info` (no limit)
- `lean_completions` (no limit)
- `lean_multi_attempt` (no limit)
- `lean_local_search` (no limit)
- `lean_state_search` (rate limited)
- `lean_hammer_premise` (rate limited)
- `lean_build` (no limit, but slow)

### Agent Logic to Move

#### lean-research-agent.md (144 lines)

**Logic to preserve**:
1. Early metadata initialization
2. Parse delegation context
3. Search decision tree logic:
   - "Does X exist locally?" → lean_local_search
   - "I need a lemma that says X" → lean_leansearch
   - "Find lemma with type pattern" → lean_loogle
   - "What's the Lean name for concept X?" → lean_leanfinder
   - "What closes this goal?" → lean_state_search
4. Rate limit management (track requests, space calls)
5. Search fallback chain (leansearch → loogle → leanfinder → local_search)
6. Finding synthesis
7. Research report creation

**Context Loading** (lazy references):
- `@.claude/context/project/lean4/tools/mcp-tools-guide.md`
- `@.claude/context/core/formats/return-metadata-file.md`
- `@.claude/context/project/lean4/agents/lean-research-flow.md`
- `@.claude/context/core/formats/report-format.md`

#### lean-implementation-agent.md (136 lines)

**Logic to preserve**:
1. Early metadata initialization
2. Parse implementation plan (phases, steps, verification criteria)
3. Find resume point from plan status markers
4. Proof development loop:
   - Mark phase [IN PROGRESS]
   - Read target file, locate proof point
   - Check proof state with lean_goal
   - Iterate with lean_multi_attempt, lean_state_search, lean_hammer_premise
   - Apply tactics via Edit tool
   - Verify with lean_diagnostic_messages
   - Run lake build
   - Mark phase [COMPLETED]
5. Phase checkpoint protocol (git commit per phase)
6. Implementation summary creation
7. Completion data generation (completion_summary, roadmap_items)

**Context Loading** (lazy references):
- `@.claude/context/project/lean4/tools/mcp-tools-guide.md`
- `@.claude/context/core/formats/return-metadata-file.md`
- `@.claude/context/project/lean4/agents/lean-implementation-flow.md`
- `@.claude/context/project/lean4/patterns/tactic-patterns.md`
- `@.claude/context/project/lean4/style/lean4-style-guide.md`

### Direct Execution Pattern Analysis

#### skill-status-sync (295 lines)

**Pattern**: Direct execution skill for atomic status synchronization

**Key characteristics**:
```yaml
name: skill-status-sync
description: Atomically update task status across TODO.md and state.json
allowed-tools: Bash, Edit, Read
```

**No Task tool** - all work done inline with Bash/Edit/Read

**Execution pattern**:
1. Input validation directly in skill
2. Execute operations using jq (Bash) and Edit tools
3. Return JSON result directly
4. No subagent, no delegation context, no metadata file exchange

#### skill-learn (677 lines)

**Pattern**: Direct execution skill with interactive user prompts

**Key characteristics**:
```yaml
name: skill-learn
description: Scan codebase for tags and create structured tasks
allowed-tools: Bash, Grep, Read, Write, Edit, AskUserQuestion
```

**No Task tool** - all work done inline

**Execution pattern**:
1. Parse arguments
2. Generate session ID inline
3. Execute tag extraction using Grep/Bash
4. Display results
5. Interactive selection via AskUserQuestion
6. Create tasks using jq/Edit
7. Git commit
8. Return summary

### Pattern Comparison

| Aspect | Thin Wrapper (Current) | Direct Execution (Target) |
|--------|------------------------|---------------------------|
| **Delegation** | Task tool → subagent | None, inline execution |
| **MCP Invocation** | In subagent (hangs) | In skill (main context) |
| **Context Loading** | Subagent loads context | Skill loads context via @-references |
| **Metadata Exchange** | Via .return-meta.json file | Direct return (text or JSON) |
| **Error Recovery** | Subagent handles | Skill handles directly |
| **Allowed Tools** | Task | Bash, Edit, Read, Write, MCP tools |

## Recommendations

### Migration Strategy

#### Phase 1: Update Skill Frontmatter

**skill-lean-research**:
```yaml
---
name: skill-lean-research
description: Research Lean 4 and Mathlib for theorem proving tasks. Direct execution pattern.
allowed-tools: Bash, Edit, Read, Write, Glob, Grep, mcp__lean-lsp__lean_leansearch, mcp__lean-lsp__lean_loogle, mcp__lean-lsp__lean_leanfinder, mcp__lean-lsp__lean_local_search, mcp__lean-lsp__lean_hover_info, mcp__lean-lsp__lean_state_search, mcp__lean-lsp__lean_hammer_premise
---
```

**skill-lean-implementation**:
```yaml
---
name: skill-lean-implementation
description: Implement Lean 4 proofs and definitions. Direct execution pattern.
allowed-tools: Bash, Edit, Read, Write, Glob, Grep, mcp__lean-lsp__lean_goal, mcp__lean-lsp__lean_diagnostic_messages, mcp__lean-lsp__lean_hover_info, mcp__lean-lsp__lean_completions, mcp__lean-lsp__lean_multi_attempt, mcp__lean-lsp__lean_local_search, mcp__lean-lsp__lean_state_search, mcp__lean-lsp__lean_hammer_premise, mcp__lean-lsp__lean_build
---
```

#### Phase 2: Inline Agent Logic

Move the following from agents to skills:

**For skill-lean-research**:
1. Search decision tree (Stage 2 from lean-research-flow.md)
2. Search execution with rate limit management (Stage 3)
3. Findings synthesis (Stage 4)
4. Report creation (Stage 5)
5. Error recovery patterns

**For skill-lean-implementation**:
1. Plan parsing and resume point detection (Stages 2-3)
2. Proof development loop (Stage 4)
3. Phase checkpoint protocol
4. Build verification (Stage 5)
5. Summary creation (Stage 6)
6. Completion data generation (Stage 6a)

#### Phase 3: Remove Task Tool Invocation

Replace Stage 5 (Invoke Subagent) in both skills with inline execution:

**Before** (skill-lean-research):
```
### Stage 5: Invoke Subagent
Tool: Task
  - subagent_type: "lean-research-agent"
  - prompt: [context]
```

**After**:
```
### Stage 5: Execute Research (Inline)

#### 5.1: Determine Search Strategy
Based on task description and focus_prompt, determine primary search approach...

#### 5.2: Execute Searches
Use lean_local_search first (no rate limit), then rate-limited tools as needed...

#### 5.3: Synthesize Findings
Compile discovered theorems with type signatures...

#### 5.4: Create Report
Write to specs/{N}_{SLUG}/reports/research-{NNN}.md...
```

#### Phase 4: Simplify Return Pattern

Since there's no subagent, no need for metadata file exchange:

**Before**:
- Subagent writes metadata to `.return-meta.json`
- Skill reads metadata file (Stage 6)
- Skill extracts status, artifacts, completion_data

**After**:
- Skill tracks status, artifacts, completion_data in variables
- Skill updates state.json and TODO.md directly
- Return brief text summary

#### Phase 5: Update Context References

The skills should now include context loading sections (like skill-learn does):

```markdown
## Context Loading

Load on-demand via @-references:

**Always Load**:
- `@.claude/context/project/lean4/tools/mcp-tools-guide.md` - MCP tool reference

**For Research**:
- `@.claude/context/core/formats/report-format.md` - Report structure

**For Implementation**:
- `@.claude/context/project/lean4/patterns/tactic-patterns.md` - Tactic usage
```

### Files to Modify

1. `.claude/skills/skill-lean-research/SKILL.md` - Major rewrite
2. `.claude/skills/skill-lean-implementation/SKILL.md` - Major rewrite
3. `.claude/CLAUDE.md` - Update Skill-to-Agent Mapping table (remove lean agent entries)

### Files to Potentially Deprecate

1. `.claude/agents/lean-research-agent.md` - Logic moved to skill
2. `.claude/agents/lean-implementation-agent.md` - Logic moved to skill
3. `.claude/context/project/lean4/agents/lean-research-flow.md` - Inline in skill
4. `.claude/context/project/lean4/agents/lean-implementation-flow.md` - Inline in skill

**Note**: Consider keeping agent files with deprecation notice for reference, or archive them.

## Decisions

1. **Use direct execution pattern** - Aligns with skill-status-sync and skill-learn patterns
2. **Inline all agent logic into skills** - No separate flow files; skill contains full execution
3. **Keep postflight in skill** - Already handled internally, no change needed
4. **Preserve error recovery patterns** - MCP recovery logic moves to skill
5. **Keep early metadata pattern** - Useful for interruption recovery even without subagent

## Risks & Mitigations

### Risk 1: Context Window Bloat

**Concern**: Moving agent logic into skills increases skill size

**Mitigation**:
- Use lazy context loading via @-references (don't load upfront)
- Reference mcp-tools-guide.md and tactic-patterns.md only when needed
- Skill size increase is acceptable (from ~300 lines to ~600-800 lines)

### Risk 2: Losing Subagent Isolation

**Concern**: Subagent provided context isolation; now skill accumulates context

**Mitigation**:
- The main conversation already accumulates context
- Skills invoke MCP tools directly in the same context as other operations
- Context budget for Lean operations is reasonable (~20-30KB)

### Risk 3: MCP Tool Availability

**Concern**: MCP tools configured in user scope may still have issues

**Mitigation**:
- Keep MCP recovery pattern in skill
- Retry once, try alternative tool, continue with available info
- Main conversation has better error handling than subagent

### Risk 4: Rate Limit Management

**Concern**: Skills must now track rate limits that were agent's responsibility

**Mitigation**:
- Add rate limit tracking variables in skill execution
- Space out calls to rate-limited tools
- Prefer lean_local_search (unlimited) over leansearch/loogle (3/30s)

## Appendix

### Migration Checklist

- [ ] Update skill-lean-research frontmatter (allowed-tools)
- [ ] Inline lean-research-agent logic into skill-lean-research
- [ ] Add context loading section to skill-lean-research
- [ ] Replace Task tool invocation with inline execution (research)
- [ ] Test skill-lean-research with /research command
- [ ] Update skill-lean-implementation frontmatter (allowed-tools)
- [ ] Inline lean-implementation-agent logic into skill-lean-implementation
- [ ] Add context loading section to skill-lean-implementation
- [ ] Replace Task tool invocation with inline execution (implementation)
- [ ] Test skill-lean-implementation with /implement command
- [ ] Update CLAUDE.md Skill-to-Agent Mapping table
- [ ] Add deprecation notices to agent files
- [ ] Update thin-wrapper-skill.md documentation

### References

- GitHub Issues: #15945, #13254, #4580, #6594 (Claude Code bugs)
- lean-lsp-mcp Issues: #118, #115 (MCP timeout issues)
- skill-status-sync (direct execution pattern example)
- skill-learn (direct execution with interactive prompts)
- mcp-tools-guide.md (full MCP tool reference)
- mcp-tool-recovery.md (error recovery patterns)
