# Research Report: Task #548

**Task**: 548 - fix_skill_to_agent_delegation_pattern
**Started**: 2026-01-17T17:15:00Z
**Completed**: 2026-01-17T17:45:00Z
**Effort**: 2-3 hours
**Priority**: High
**Dependencies**: None
**Sources/Inputs**:
- Claude Code official documentation (anthropic.com, code.claude.com)
- Task 539 research (root cause analysis)
- Task 534 research (model selection mechanisms)
- Codebase analysis (.claude/skills/, .claude/agents/)
- Community resources (github.com/wshobson/agents, github.com/hesreallyhim/awesome-claude-code)
**Artifacts**: specs/548_fix_skill_to_agent_delegation_pattern/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Root cause confirmed**: Skills use ambiguous prose instructions for agent invocation, causing Claude to call `Skill()` instead of `Task()` when delegating to agents
- **7 skills affected**: All forked skills with `agent:` frontmatter field need explicit Task tool invocation directives
- **Claude Code 2026 best practices**: Focus on explicit instructions, test verification loops, and minimal context loading
- **Recommended fix**: Add clear, unambiguous `CRITICAL` directive to each skill specifying Task tool usage
- **Alternative approach**: Consider removing `agent:` field from frontmatter to avoid confusion

## Context & Scope

This research addresses the root cause identified in Task 539: the skill-to-agent delegation pattern fails because skills use ambiguous prose like "Invoke `general-research-agent` via Task tool with..." instead of explicit tool invocation directives. Claude interprets the `agent:` frontmatter field and pattern-matches to `Skill()` instead of `Task()`, causing failures and OOM crashes.

The focus is on:
1. Understanding Claude Code best practices for 2026
2. Analyzing the current command-skill-agent architecture
3. Identifying the most natural improvements to fix the delegation issue

## Findings

### 1. Root Cause: Ambiguous Skill Instructions

**Evidence from Task 539 research-002.md**:
```
The **actual root cause** is that the refactored skill-researcher is calling
`Skill(general-research-agent)` instead of `Task(general-research-agent)`.
Since `general-research-agent` is an agent (in `.claude/agents/`), not a
skill (in `.claude/skills/`), this invocation is invalid.
```

**Tool Directory Mapping**:
| Directory | Tool | Purpose |
|-----------|------|---------|
| `.claude/skills/` | Skill tool | Invoke skills (SKILL.md files) |
| `.claude/agents/` | Task tool | Spawn subagents (agent .md files) |
| `.claude/commands/` | Direct execution | User-invoked via /command |

**Current Problem in Skills**:
```markdown
### 3. Invoke Subagent

Invoke `general-research-agent` via Task tool with:
- Task context (number, name, description, language)
```

This prose instruction is **not actionable**. Claude sees `agent: general-research-agent` in frontmatter and incorrectly calls `Skill(general-research-agent)`.

### 2. Claude Code 2026 Best Practices

**From official Anthropic documentation** ([source](https://www.anthropic.com/engineering/claude-code-best-practices)):

#### a) Explicit Instructions Over Prose
- Treat CLAUDE.md and skill files like prompts requiring iterative refinement
- Use explicit, actionable directives rather than descriptive prose
- Focus on what actually improves instruction-following

#### b) Test-Driven Verification
Boris Cherny (Claude Code creator) emphasizes: "Claude tests every single change I land... giving the AI a way to verify its own work improves the quality of the final result by 2-3x."

#### c) Slash Commands for Repeated Workflows
- Store prompt templates in `.claude/commands/` as Markdown
- Check into git for team availability
- Use `$ARGUMENTS` keyword for parameterized execution

#### d) Subagent Delegation
- Use Task(...) for spawning agent clones
- Put key context in CLAUDE.md
- Let main agent decide when/how to delegate

### 3. Current Skill Architecture Analysis

**7 affected skills with `agent:` frontmatter**:

| Skill | Agent | Status |
|-------|-------|--------|
| skill-researcher | general-research-agent | Needs fix |
| skill-lean-research | lean-research-agent | Needs fix |
| skill-planner | planner-agent | Needs fix |
| skill-implementer | general-implementation-agent | Needs fix |
| skill-lean-implementation | lean-implementation-agent | Needs fix |
| skill-latex-implementation | latex-implementation-agent | Needs fix |
| skill-meta | meta-builder-agent | Needs fix |

**Common pattern across all skills**:
```yaml
---
name: skill-{name}
allowed-tools: Task
context: fork
agent: {agent-name}
---

### 3. Invoke Subagent

Invoke `{agent-name}` via Task tool with:
- Task context (number, name, description, language)
```

This pattern is **structurally correct** but **instructionally ambiguous**.

### 4. Thin Wrapper Template Analysis

The `thin-wrapper-skill.md` template provides correct guidance:
```markdown
**Task tool parameters**:
- `subagent_type`: The agent name from frontmatter
- `prompt`: Task context + focus prompt
- `description`: "Execute {operation} for task {N}"
```

However, this is reference documentation, not embedded in the skills themselves.

### 5. Industry Patterns from Community

**From github.com/wshobson/agents**:
- **Plugin-based containment**: Agents bundled within plugins
- **Three-tier model strategy**: Opus for complex tasks, Sonnet for standard, Haiku for fast operations
- **Progressive disclosure**: Skills load knowledge only when activated

**From github.com/hesreallyhim/awesome-claude-code**:
- Curated list of skills, hooks, slash-commands, agent orchestrators
- Demonstrates community patterns for agent coordination

### 6. Model Selection Findings (from Task 534)

**Key insight**: The `model` field IS supported in agent YAML frontmatter but is not currently used in this project's agents.

Supported values: `sonnet`, `opus`, `haiku`, `inherit`

**Recommendation for future work**: After fixing the delegation issue, add explicit model fields to optimize cost/capability trade-offs.

## Recommendations

### Primary Fix: Explicit Task Tool Directive

Replace ambiguous prose with explicit, unambiguous directive in all 7 skills:

**Before (ambiguous)**:
```markdown
### 3. Invoke Subagent

Invoke `general-research-agent` via Task tool with:
- Task context (number, name, description, language)
- Delegation context (session_id, depth, path)
```

**After (explicit)**:
```markdown
### 3. Invoke Subagent

**CRITICAL**: You MUST use the Task tool (NOT Skill tool) to spawn the subagent.
The `agent` field in frontmatter specifies the subagent_type for the Task tool.

**Required Tool Invocation**:
- Tool: `Task` (NOT `Skill` - agents are in .claude/agents/, not .claude/skills/)
- Parameter `subagent_type`: `"general-research-agent"` (from frontmatter agent field)
- Parameter `prompt`: Include task context, delegation context, and focus prompt
- Parameter `description`: "Execute research for task {N}"

**DO NOT** call `Skill(general-research-agent)` - this will fail because the agent
is not a skill. Only use the Task tool for agent delegation.
```

### Alternative Fix: Remove agent: Frontmatter

Consider removing the non-standard `agent:` field entirely to avoid confusion:

```yaml
---
name: skill-researcher
description: Research tasks using web search and codebase exploration
allowed-tools: Task
context: fork
# agent field removed - specify in instruction body instead
---
```

Then embed the agent name directly in the instruction text where the Task tool is invoked.

### Future Improvements

1. **Add model fields to agents** - Based on Task 534 research, assign appropriate models:
   - Opus for complex tasks (lean-implementation-agent)
   - Sonnet for standard tasks (general-research-agent, planner-agent)
   - Haiku for fast tasks (status operations, validation)

2. **Verification loops** - Following Boris Cherny's pattern, add verification steps to implementation skills

3. **Progressive disclosure** - Document that skills use lazy context loading; context is loaded by subagents, not skills

## Decisions

1. **Fix approach**: Add explicit Task tool directive (recommended over removing agent: field)
2. **Scope**: All 7 forked skills require the same fix pattern
3. **Testing**: New Claude Code session required after fix (old sessions have cached context)
4. **Documentation**: Update thin-wrapper-skill.md template to emphasize Task vs Skill distinction

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Fix doesn't reach all 7 skills | High | Low | Create checklist, verify each file |
| Old sessions have cached bad context | Medium | High | Document: start fresh sessions after fix |
| Prose instructions still ambiguous | Medium | Low | Use CRITICAL formatting, bold, caps |
| agent: field continues to confuse | Low | Medium | Consider removing field in future iteration |
| Model tiering not addressed | Low | Low | Separate task (549-553) for model optimization |

## Appendix

### Files to Modify

1. `.claude/skills/skill-researcher/SKILL.md`
2. `.claude/skills/skill-lean-research/SKILL.md`
3. `.claude/skills/skill-planner/SKILL.md`
4. `.claude/skills/skill-implementer/SKILL.md`
5. `.claude/skills/skill-lean-implementation/SKILL.md`
6. `.claude/skills/skill-latex-implementation/SKILL.md`
7. `.claude/skills/skill-meta/SKILL.md`

### Search Queries Used

1. "Claude Code best practices 2026 workflow automation skills agents"
2. Official documentation fetch from anthropic.com/engineering/claude-code-best-practices
3. Common workflows from code.claude.com/docs/en/common-workflows
4. Community patterns from github.com/wshobson/agents

### References

- [Claude Code Best Practices - Anthropic](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Claude Code Common Workflows](https://code.claude.com/docs/en/common-workflows)
- [Boris Cherny's Claude Code Workflow - InfoQ](https://www.infoq.com/news/2026/01/claude-code-creator-workflow/)
- [10 Claude Code Productivity Tips 2026](https://www.f22labs.com/blogs/10-claude-code-productivity-tips-for-every-developer/)
- [Intelligent Automation Agents - GitHub](https://github.com/wshobson/agents)
- [Awesome Claude Code - GitHub](https://github.com/hesreallyhim/awesome-claude-code)

### Explicit Fix Template

The following template should be added to section "3. Invoke Subagent" in each skill:

```markdown
### 3. Invoke Subagent

**CRITICAL**: You MUST use the Task tool (NOT Skill tool) to spawn the subagent.

The `agent` field in this skill's frontmatter specifies the target: `{AGENT_NAME}`

**Invocation Requirements**:
```
Tool: Task (NOT Skill)
Parameters:
  - subagent_type: "{AGENT_NAME}"
  - prompt: [Include task_context, delegation_context, focus_prompt if present]
  - description: "Execute {OPERATION} for task {N}"
```

**WARNING**: Do NOT use `Skill({AGENT_NAME})` - this will FAIL.
Agents live in `.claude/agents/`, not `.claude/skills/`.
The Skill tool can only invoke skills from `.claude/skills/`.
```

Replace `{AGENT_NAME}` and `{OPERATION}` appropriately for each skill.
