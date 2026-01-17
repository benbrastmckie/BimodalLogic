# Research Report: Task #539 (Revision 002)

**Task**: 539 - test_validate_model_tiering
**Date**: 2026-01-17
**Session ID**: sess_1768662432_1b38fa
**Focus**: Correct diagnosis of `/research 541` failures after recent refactor

## Executive Summary

The previous research report (research-001.md) **incorrectly attributed** the failures to a V8 memory leak (GitHub #18011). While that issue exists, it is **NOT the root cause** of the consistent `/research` failures.

The **actual root cause** is that the refactored skill-researcher is calling `Skill(general-research-agent)` instead of `Task(general-research-agent)`. Since `general-research-agent` is an agent (in `.claude/agents/`), not a skill (in `.claude/skills/`), this invocation is invalid and causes the system to fail.

## Evidence

### Crash Log Analysis

All three crash logs (`research_1.md`, `research_2.md`, `research_3.md`) show the same pattern:

```
Skill(skill-researcher)
   Skill(general-research-agent)    <-- WRONG TOOL
```

The sequence should be:
```
Skill(skill-researcher)
   Task(general-research-agent)     <-- CORRECT TOOL
```

### Key Observations

1. **Skill tool** invokes skills from `.claude/skills/` directory
2. **Task tool** spawns subagents from `.claude/agents/` directory
3. `general-research-agent` exists in `.claude/agents/`, NOT `.claude/skills/`
4. Therefore, `Skill(general-research-agent)` is an invalid invocation

### Why This Session Works (Old Context)

This research session was started **before** the task 535 commit that refactored the skills. The session has the **old skill definitions** loaded in its context cache, which use the correct patterns. New sessions load the refactored skills and encounter this bug.

### The Refactor Change

**Before (task 535)** - `skill-researcher/SKILL.md`:
```yaml
allowed-tools: Task
# Simple thin wrapper - delegates to agent
```

**After (task 535)**:
```yaml
allowed-tools: Task, Bash(jq:*), Read, Edit, Glob, Grep
agent: general-research-agent
# Self-contained workflow with preflight/postflight
```

The refactored skill adds preflight/postflight status updates but the actual agent invocation mechanism became ambiguous, leading Claude to use `Skill()` instead of `Task()`.

### Memory Exhaustion is a Symptom, Not Cause

The OOM crashes happen because:
1. Invalid `Skill(general-research-agent)` call is attempted
2. System cannot find skill "general-research-agent"
3. Error handling or retry logic consumes excessive memory
4. Eventually V8 heap exhausts

The 4GB heap limit is normal; the problem is the infinite/recursive error state triggered by the invalid invocation.

## Root Cause

**The skill-researcher SKILL.md lacks explicit Task tool invocation syntax**, causing Claude to misinterpret the `agent:` frontmatter field and use `Skill()` instead of `Task()`.

The skill content says:
```markdown
### 3. Invoke Subagent

Invoke `general-research-agent` via Task tool with:
```

But this is prose, not an actionable directive. Claude sees the `agent: general-research-agent` in frontmatter and pattern-matches to `Skill(general-research-agent)`.

## Recommendations

### Immediate Fix (High Priority)

Add explicit Task tool invocation instruction to all forked skills. Replace vague prose with explicit directive:

**Current (vague)**:
```markdown
### 3. Invoke Subagent

Invoke `general-research-agent` via Task tool with:
- Task context (number, name, description, language)
```

**Fixed (explicit)**:
```markdown
### 3. Invoke Subagent

**CRITICAL**: You MUST use the Task tool (NOT Skill tool) to spawn the subagent.
The agent field in frontmatter specifies the subagent_type for the Task tool.

Call the Task tool with:
- subagent_type: "general-research-agent" (from frontmatter agent field)
- prompt: Include task context, delegation context, and focus prompt

DO NOT use Skill() - agents are in .claude/agents/, not .claude/skills/
```

### Affected Files

All skills with `agent:` frontmatter field need this fix:

| Skill File | Agent Field |
|------------|-------------|
| `.claude/skills/skill-researcher/SKILL.md` | general-research-agent |
| `.claude/skills/skill-lean-research/SKILL.md` | lean-research-agent |
| `.claude/skills/skill-planner/SKILL.md` | planner-agent |
| `.claude/skills/skill-implementer/SKILL.md` | general-implementation-agent |
| `.claude/skills/skill-lean-implementation/SKILL.md` | lean-implementation-agent |
| `.claude/skills/skill-latex-implementation/SKILL.md` | latex-implementation-agent |
| `.claude/skills/skill-meta/SKILL.md` | meta-builder-agent |

### Alternative Fix: Remove agent: Frontmatter

Consider removing the `agent:` field from skill frontmatter since it's not a standard Claude Code field and may cause confusion:

```yaml
---
name: skill-researcher
description: Research tasks using web search and codebase exploration
allowed-tools: Task, Bash(jq:*), Read, Edit, Glob, Grep
context: fork
# agent field removed - specify in instruction body instead
---
```

Then specify the agent name explicitly in the instruction text.

## Testing Verification

After applying the fix:

1. Start a **fresh Claude Code session** (not this one - it has old context)
2. Run `/research 541` or create a test task
3. Verify the log shows `Task(general-research-agent)` NOT `Skill(general-research-agent)`
4. Verify research completes without OOM crash

## Previous Report Assessment

The research-001.md report was **well-intentioned but incorrect**:

| Claim | Assessment |
|-------|------------|
| Root cause is GitHub #18011 memory leak | **INCORRECT** - That bug exists but isn't causing these crashes |
| OOM is from V8 heap accumulation | **PARTIALLY CORRECT** - OOM happens but due to invalid invocation |
| Agent files are 465 lines average | **CORRECT** - But not the cause |
| Progressive disclosure would help | **CORRECT** - But won't fix the invocation bug |

The real issue is architectural: **skills are calling Skill() when they should call Task()**.

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Fix doesn't reach all skills | High | Create checklist, verify each file |
| Old sessions have cached bad context | Medium | Document: start fresh sessions after fix |
| Prose instructions still ambiguous | Medium | Use bold/caps formatting for critical directives |

## Next Steps

1. **Create fix task** - Task to update all 7 affected skill files
2. **Apply fixes** - Add explicit Task tool invocation instructions
3. **Test in fresh session** - Verify `/research` works
4. **Document pattern** - Add to skill development guidelines

## Appendix: Tool Invocation Reference

| Directory | Tool | Usage |
|-----------|------|-------|
| `.claude/skills/` | Skill tool | Invoke skills (SKILL.md files) |
| `.claude/agents/` | Task tool | Spawn subagents (agent .md files) |
| `.claude/commands/` | Direct execution | User-invoked via /command |

This distinction is critical for the forked subagent pattern to work correctly.
