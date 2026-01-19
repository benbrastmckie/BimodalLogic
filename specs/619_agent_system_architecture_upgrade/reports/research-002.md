# Research Report: Task #619 (Supplemental)

**Task**: 619 - agent_system_architecture_upgrade
**Started**: 2026-01-19T21:08:00Z
**Completed**: 2026-01-19T21:25:00Z
**Effort**: Medium (research phase)
**Priority**: Medium
**Dependencies**: research-001.md
**Sources/Inputs**: Official Claude Code documentation, GitHub issues, Anthropic engineering blogs
**Artifacts**: This report (supplements research-001.md)
**Standards**: report-format.md, subagent-return.md

---

## Executive Summary

- **context:fork IS a real Claude Code feature** - Added in v2.1.0 (January 9, 2026) and officially documented at code.claude.com/docs/en/skills
- **HOWEVER, it is currently BROKEN** - GitHub issue #16803 confirms the feature does not work as documented; skills with `context: fork` still run inline in the main conversation
- **The current ProofChecker workaround (Task tool delegation) is the CORRECT approach** - Official documentation recommends subagent delegation via Task tool for context isolation
- **Recommendation**: Remove `context: fork` from skill frontmatter until Anthropic fixes the bug; continue using Task tool pattern

---

## Context & Scope

### Research Questions (from user request)

1. Does `context: fork` exist as a feature of Claude Code skills?
2. What does official 2026 documentation say about skill frontmatter options?
3. What are best practices for passing context to skills/agents without polluting primary context?
4. How do official sources compare to what research-001.md found?

### Constraints

- Focus specifically on the context:fork question
- Use official 2026 sources (Anthropic documentation, GitHub issues)
- Supplement, not replace, research-001.md

---

## Findings

### Finding 1: context:fork IS a Real Claude Code Feature

**Status**: CONFIRMED - It is an official feature added in Claude Code v2.1.0

**Evidence from official documentation** ([code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills)):

> The `context` field can be set to `fork` to run the Skill in an isolated sub-agent context with its own conversation history. This is useful for Skills that perform complex multi-step operations without cluttering the main conversation.

**Official frontmatter fields** for skills:

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Skill name (lowercase, alphanumeric + hyphens, max 64 chars) |
| `description` | Yes | What the Skill does and when to use it (max 1024 chars) |
| `allowed-tools` | No | Tools Claude can use without asking permission |
| `model` | No | Specific Claude model to use when Skill is active |
| `context` | No | Set to `fork` to run in isolated sub-agent context |
| `agent` | No | Which agent type to use when `context: fork` is set |
| `hooks` | No | Define lifecycle hooks (PreToolUse, PostToolUse, Stop) |
| `user-invocable` | No | Controls visibility in slash command menu (default true) |

**Example from official docs**:
```yaml
---
name: code-analysis
description: Analyze code quality and generate detailed reports
context: fork
agent: Explore
---
```

### Finding 2: context:fork is Currently BROKEN

**Status**: CONFIRMED - Feature does not work as documented

**Evidence from GitHub issue [#16803](https://github.com/anthropics/claude-code/issues/16803)**:

> The `context: fork` feature added in v2.1.0 is not functioning as documented. Skills with `context: fork` in their YAML frontmatter should execute in a forked sub-agent context with isolated conversation history, but instead they run inline in the main conversation context.

**Issue status**:
- Reported in: v2.1.1
- Still broken in: v2.1.3, v2.1.5
- Status: OPEN (as of January 15, 2026)
- No official Anthropic response visible

**Related issues**:
- [#17283](https://github.com/anthropics/claude-code/issues/17283): Feature request for Skill tool to honor `context: fork` and `agent:` fields (closed/completed but issue persists)
- [#18394](https://github.com/anthropics/claude-code/issues/18394): Duplicate bug report
- [#18840](https://github.com/anthropics/claude-code/issues/18840): Skill-as-Agent execution mode request

### Finding 3: The ProofChecker Task Tool Pattern is the Correct Workaround

**Status**: CONFIRMED - Task tool delegation is the recommended approach

**From official subagent documentation** ([code.claude.com/docs/en/sub-agents](https://code.claude.com/docs/en/sub-agents)):

> Subagents maintain separate context from the main agent, preventing information overload and keeping interactions focused. This isolation ensures that specialized tasks don't pollute the main conversation context.

> Background agents with `run_in_background=true` isolate their context. Have them write results to files in `.claude/cache/agents/<agent-type>/`.

**Recommended pattern** (from alexop.dev):

> Use the Task tool to spawn parallel contexts with isolated environments. The framework emphasizes context isolation by design rather than dynamic forking. If you need parallel analysis, subagents are the intended solution.

**Key insight**: The ProofChecker system's current approach of:
1. Skills delegating via Task tool
2. Agents loading context on-demand
3. File-based metadata exchange (`.return-meta.json`)

...is **exactly the pattern recommended** when `context: fork` doesn't work.

### Finding 4: Official Claude Code 2.1.0 Feature List

**From official release notes** ([threads.com/@boris_cherny](https://www.threads.com/@boris_cherny/post/DTOyRyBD018)):

Claude Code 2.1.0 shipped with 1,096 commits, including:
- Skills: forked context, hot reload, custom agent support, invoke with /
- Add hooks directly to agents & skills frontmatter
- Agent-scoped hooks (PreToolUse, PostToolUse, Stop)
- Shift+enter for newlines
- Language setting for response language (e.g., Japanese, Spanish)

**The `context: fork` feature was officially added**, but the implementation has bugs preventing proper functioning.

### Finding 5: Skill vs Subagent Architecture Clarified

**From official documentation**:

| Aspect | Skills (default) | Skills (`context: fork`) | Subagents (Task tool) |
|--------|-----------------|--------------------------|----------------------|
| Context isolation | No | Yes (when working) | Yes |
| Parent context access | Full | None (when working) | None |
| Implementation status | Working | BROKEN | Working |
| Token efficiency | Low | High (when working) | High |

**Key distinction**:
- Skills by default share parent context (can access conversation history)
- `context: fork` SHOULD create isolated context (currently broken)
- Subagents via Task tool ALWAYS have isolated context (working)

### Finding 6: Skills Field for Subagents

**Important for architecture upgrade**:

Subagents do NOT automatically inherit skills from the main conversation. To give a subagent access to skills, list them in the subagent's `skills` field:

```yaml
---
name: code-reviewer
description: Review code for quality and best practices
skills: pr-review, security-check
---
```

The full content of each listed Skill is **injected into the subagent's context at startup**, not just made available for invocation.

---

## Reconciliation with research-001.md

### What research-001.md Got Right

1. **"context forking" doesn't work as expected** - Correct, the feature is broken
2. **Task tool delegation is the right approach** - Confirmed by official docs
3. **Remove references to context: fork** - Partially correct; keep the references but note the bug

### What Needs Updating

1. **research-001.md says**: "It's not an actual Claude Code feature"
   - **Update**: It IS a feature, it's just currently broken

2. **research-001.md says**: "Do not adopt context: fork"
   - **Update**: Monitor the GitHub issue; adopt when fixed

3. **Documentation references context: fork** in thin-wrapper-skill.md and elsewhere
   - **Update**: Add note that feature is broken; Task tool is the working alternative

---

## Recommendations

### Priority 1: Update Documentation (Immediate)

Add a note to `.claude/context/core/patterns/thin-wrapper-skill.md` and similar files:

```markdown
**Note**: While `context: fork` is an official Claude Code feature (added v2.1.0),
it is currently broken (GitHub #16803). Use Task tool delegation instead for
reliable context isolation.
```

### Priority 2: Monitor GitHub Issue

Track [#16803](https://github.com/anthropics/claude-code/issues/16803) for resolution. When fixed:
1. Update skills to use `context: fork` + `agent:` frontmatter
2. Simplify skill bodies (remove manual Task tool invocation)
3. Update documentation

### Priority 3: Keep Current Architecture

The ProofChecker system's current approach is correct:
- Skills as thin wrappers with Task tool delegation
- Agents loading context on-demand
- File-based metadata exchange

This pattern will continue working whether or not `context: fork` gets fixed.

### Priority 4: Consider Native Subagent Integration

When Claude Code 2.x stabilizes:
1. Use `skills:` field in subagent frontmatter to pass skills
2. Use built-in subagent resume capability
3. Consider background execution for parallel workflows

---

## Decisions

1. **Keep Task tool delegation pattern** - It works, it's documented, it's the official workaround
2. **Do not remove context: fork references entirely** - Document the bug instead
3. **Add bug notes to documentation** - Users should know the feature status
4. **Monitor GitHub for fix** - Be ready to adopt when working

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| context: fork gets fixed, system already works | Low | Easy migration path exists |
| context: fork never gets fixed | Low | Current approach is sustainable |
| Documentation confusion about context: fork | Medium | Add clear notes about bug status |
| Anthropic changes subagent API | Medium | Monitor release notes, test on update |

---

## Appendix

### Search Queries Used

1. "Claude Code skills context fork 2026 frontmatter options"
2. "anthropic claude code skills documentation YAML frontmatter 2026"
3. "claude code skill context inherit fork agent delegation 2026"
4. "claude code 2.1 context fork skill frontmatter fix release notes 2026"
5. "claude code skill subagent context isolation workaround Task tool 2026"

### Key Sources (Official)

- [Agent Skills - Claude Code Docs](https://code.claude.com/docs/en/skills) - Official skill documentation
- [Create custom subagents - Claude Code Docs](https://code.claude.com/docs/en/sub-agents) - Official subagent documentation
- [GitHub Issue #16803](https://github.com/anthropics/claude-code/issues/16803) - Bug report for context: fork
- [GitHub Issue #17283](https://github.com/anthropics/claude-code/issues/17283) - Feature request for Skill tool to honor frontmatter
- [Claude Code 2.1.0 Release](https://www.threads.com/@boris_cherny/post/DTOyRyBD018) - Official release announcement
- [alexop.dev - Claude Code Full Stack](https://alexop.dev/posts/understanding-claude-code-full-stack/) - Best practices guide

### Verified Frontmatter Fields (Official)

From code.claude.com/docs/en/skills:

```yaml
---
name: string (required, max 64 chars, lowercase + hyphens)
description: string (required, max 1024 chars)
allowed-tools: string | list (optional)
model: string (optional, e.g., "claude-sonnet-4-20250514")
context: "fork" (optional, creates isolated context)
agent: string (optional, e.g., "Explore", "Plan", "general-purpose", or custom)
hooks: object (optional, PreToolUse/PostToolUse/Stop)
user-invocable: boolean (optional, default true)
---
```

---

## Next Steps

Run `/plan 619` to create an implementation plan that:
1. Updates documentation to note context: fork bug status
2. Keeps Task tool delegation as primary pattern
3. Prepares for future adoption when bug is fixed
