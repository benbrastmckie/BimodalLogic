# Research Report: Task #591

**Task**: 591 - Find and Fix Double Forking in Skill-Agent Delegation
**Started**: 2026-01-18
**Completed**: 2026-01-18
**Effort**: 3-4 hours
**Priority**: High
**Dependencies**: None
**Sources/Inputs**: Codebase analysis, Claude Code official documentation, GitHub issues, existing project documentation
**Artifacts**: This report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Finding 1**: There is NO double forking issue in the current architecture. The concern was based on a misunderstanding of what `context: fork` does.
- **Finding 2**: `context: fork` creates an isolated **conversation context** (separate context window), NOT a subprocess. The Task tool ALSO creates an isolated conversation context (separate subprocess/context window).
- **Finding 3**: However, using BOTH `context: fork` AND Task tool invocation is **redundant** and creates unnecessary overhead, though not double subprocesses in the problematic sense.
- **Recommendation**: Remove `context: fork` from thin wrapper skills that use the Task tool, OR remove Task tool invocation and rely solely on `context: fork` with the `agent:` field.

## Context & Scope

### Research Question
Does the current skill-to-agent delegation architecture create "double forking" where:
1. `context: fork` in skill frontmatter spawns one subprocess
2. Task tool invocation inside that skill spawns another subprocess

### Scope
- All skills with `context: fork` that invoke the Task tool
- Understanding of Claude Code's context isolation mechanisms
- Analysis of memory and performance implications

## Findings

### 1. What `context: fork` Actually Does

**Key Discovery**: `context: fork` creates an **isolated conversation context**, NOT an OS subprocess.

From [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills):
> "Use `context: fork` to run a Skill in an isolated sub-agent context with its own conversation history. This is useful for Skills that perform complex multi-step operations without cluttering the main conversation."

**Characteristics**:
- Creates a separate conversation/context window
- Skill instructions run in this isolated context
- Only results return to the main conversation
- The `agent:` field specifies which agent type to use for the forked context

### 2. What Task Tool Does

From [Claude Code Subagents Documentation](https://code.claude.com/docs/en/sub-agents):
> "Each subagent runs in its own context window with a custom system prompt, specific tool access, and independent permissions."

**Characteristics**:
- Creates a separate subprocess with its own context window
- Agent definition provides system prompt and tool configuration
- Results return to caller
- **Critical constraint**: Subagents cannot spawn other subagents

### 3. The Redundancy Problem

When a skill has BOTH:
```yaml
---
name: skill-researcher
context: fork
agent: general-research-agent
allowed-tools: Task
---
```

AND the skill instructions say:
```
Invoke Task tool with subagent_type: "general-research-agent"
```

**What happens**:
1. Skill invocation with `context: fork` creates Context A (forked context)
2. Inside Context A, Task tool invocation creates Context B (subagent context)
3. Work happens in Context B
4. Results return to Context A, then to main conversation

**This is NOT double forking in a harmful sense, but it IS redundant**:
- Context A exists only to invoke the Task tool
- Context A doesn't do any meaningful work
- The skill wrapper adds ~100 tokens of overhead per invocation

### 4. Current Skill Configurations

| Skill | Has `context: fork` | Has `agent:` field | Uses Task tool | Redundant? |
|-------|---------------------|-------------------|----------------|------------|
| skill-researcher | Yes | general-research-agent | Yes | **YES** |
| skill-lean-research | Yes | lean-research-agent | Yes | **YES** |
| skill-planner | Yes | planner-agent | Yes | **YES** |
| skill-implementer | Yes | general-implementation-agent | Yes | **YES** |
| skill-lean-implementation | Yes | lean-implementation-agent | Yes | **YES** |
| skill-latex-implementation | Yes | latex-implementation-agent | Yes | **YES** |
| skill-meta | Yes | meta-builder-agent | Yes | **YES** |
| skill-document-converter | Yes | document-converter-agent | Yes | **YES** |
| skill-status-sync | No | N/A | No | No |
| skill-orchestrator | No | N/A | Yes (intentionally) | No |
| skill-git-workflow | No | N/A | No | No |

**All 8 forked skills are redundant in their current configuration.**

### 5. The Known Bug (Now Fixed)

From [GitHub Issue #17283](https://github.com/anthropics/claude-code/issues/17283):
> "When a skill is invoked via the Skill tool, the `context: fork` and `agent:` frontmatter fields are **ignored**. The skill runs in the main conversation context instead of spawning the specified subagent."

**Status**: COMPLETED (fixed as of ~Jan 10, 2026)

This means `context: fork` + `agent:` field now WORKS as intended. The skill instructions would run inside the specified agent context automatically, WITHOUT needing to invoke the Task tool manually.

### 6. The Nested Skills Bug (Still Open)

From [GitHub Issue #17351](https://github.com/anthropics/claude-code/issues/17351):
> "When a skill invokes another skill explicitly using `Skill(...)`, the execution flow breaks: control returns to the main session context instead of the invoking skill context after completion."

**Status**: OPEN

This affects the skill-orchestrator pattern but NOT the direct skill-to-agent delegation.

### 7. Memory Impact Analysis

**Current redundant flow**:
```
Main (~200 tokens)
  -> Skill Fork Context A (~100 tokens overhead)
    -> Agent Context B (~5000-20000 tokens actual work)
```

**Optimized flow (remove redundancy)**:
```
Main (~200 tokens)
  -> Agent Context (~5000-20000 tokens actual work)
```

**Savings**: ~100 tokens per invocation, elimination of unnecessary context creation overhead.

### 8. Two Architectural Options

#### Option A: Remove `context: fork`, Keep Task Tool

**Change skills to**:
```yaml
---
name: skill-researcher
description: ...
allowed-tools: Task
# NO context: fork
# NO agent: field
---
```

**Keep the Task tool invocation** in skill instructions.

**Pros**:
- Skill runs in main context (minimal overhead)
- Task tool provides context isolation
- More explicit delegation
- Works today with current Claude Code

**Cons**:
- Skill instructions consume tokens in main context (~100 tokens)

#### Option B: Keep `context: fork` + `agent:`, Remove Task Tool

**Change skills to**:
```yaml
---
name: skill-researcher
description: ...
context: fork
agent: general-research-agent
allowed-tools: Read, Write, Edit, Glob, Grep, WebSearch, WebFetch
# NO Task tool needed
---
```

**Move agent instructions to skill body** (or merge skill and agent into one file).

**Pros**:
- Single configuration point
- Automatic context forking
- Cleaner architecture

**Cons**:
- Depends on `context: fork` + `agent:` working correctly (was bugged, now fixed)
- Requires merging skill and agent documentation
- May conflict with direct Task tool invocation from orchestrator

## Decisions

Based on this research:

1. **The "double forking" concern was overblown** - there's no memory multiplication from nested subprocesses, just redundant context creation.

2. **Recommend Option A (Remove `context: fork`, keep Task tool)** because:
   - It's more explicit about delegation
   - It doesn't depend on the recently-fixed `context: fork` bug
   - It preserves the thin wrapper pattern (skill = routing, agent = execution)
   - It maintains compatibility with direct Task tool invocation from commands

3. **Alternative consideration**: If Claude Code's `context: fork` + `agent:` is now reliable, Option B could provide cleaner architecture in the future.

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Removing `context: fork` might increase main context size | Low - skill instructions are ~100 tokens | Monitor context growth; skill body is minimal |
| Bug #17351 (nested skills) affects orchestration | Medium - already affects skill-orchestrator | Use direct Task delegation, avoid Skill tool chaining |
| `context: fork` behavior changes in future updates | Low | Stay on explicit Task tool delegation (Option A) |

## Implementation Recommendations

### Phase 1: Remove Redundancy (Recommended)

For all 8 redundant skills, update frontmatter:

**Before**:
```yaml
---
name: skill-researcher
description: ...
allowed-tools: Task
context: fork
agent: general-research-agent
---
```

**After**:
```yaml
---
name: skill-researcher
description: ...
allowed-tools: Task
---
```

Keep the Task tool invocation in the skill body unchanged.

### Phase 2: Update Documentation

Update `.claude/CLAUDE.md` Skill Architecture section:
- Remove references to `context: fork` for thin wrapper skills
- Clarify that `context: fork` is for skills that do work directly (not delegate)
- Document when `context: fork` IS appropriate

### Phase 3: Verify No Regression

Test each modified skill:
```bash
/research 999  # General research
/plan 999      # Planning
/implement 999 # Implementation
```

Monitor for:
- Context size in main conversation
- Agent behavior unchanged
- Return format unchanged

## Appendix

### Search Queries Used
1. `Claude Code "context: fork" skill behavior subprocess documentation 2026`
2. `Claude Code Task tool subagent_type spawn subprocess memory isolation documentation`
3. `Claude Code "context: fork" skill Task tool subprocess isolation nested subagent behavior 2026`

### References

- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)
- [Claude Code Subagents Documentation](https://code.claude.com/docs/en/sub-agents)
- [GitHub Issue #17283: Skill tool should honor `context: fork`](https://github.com/anthropics/claude-code/issues/17283) (COMPLETED)
- [GitHub Issue #17351: Nested skills context return bug](https://github.com/anthropics/claude-code/issues/17351) (OPEN)
- `.claude/docs/skills-vs-agents-context-behavior.md` (local)
- `.claude/docs/research-skill-agent-contexts.md` (local)
- `.claude/docs/memory-leak-fix-plan.md` (local)

### Files Examined

**Skills with `context: fork`**:
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-researcher/SKILL.md`
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-lean-implementation/SKILL.md`
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-implementer/SKILL.md`
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-meta/SKILL.md`
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-lean-research/SKILL.md`
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-planner/SKILL.md`
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-latex-implementation/SKILL.md`
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-document-converter/SKILL.md`

**Skills without `context: fork`**:
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-status-sync/SKILL.md`
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-orchestrator/SKILL.md`
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-git-workflow/SKILL.md`

## Next Steps

Run `/plan 591` to create implementation plan for removing redundant `context: fork` from thin wrapper skills.
