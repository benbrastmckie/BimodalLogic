# Research Report: Task #549 - Fixed Model-to-Agent Mapping

**Task**: 549 - research_intelligent_model_routing_architecture
**Started**: 2026-01-17T20:32:19Z
**Completed**: 2026-01-17T20:45:00Z
**Effort**: 2-3 hours
**Priority**: high
**Dependencies**: 548 (skill-to-agent delegation pattern)
**Sources/Inputs**: Claude Code official documentation, GitHub issues, codebase analysis, web search
**Artifacts**: specs/549_research_intelligent_model_routing_architecture/reports/research-002.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Fixed model assignment via agent YAML frontmatter IS supported** using the `model` field with values: `opus`, `sonnet`, `haiku`, or `inherit`
- **Task tool model parameter has a known bug** (GitHub #11682) causing 404 errors - use frontmatter instead
- **Haiku has a critical limitation** (GitHub #14863): fails with "tool_reference blocks not supported" when agents use many tools
- **Recommended assignment**: Opus for lean-implementation-agent (complex theorem proving), Sonnet for planner/latex/general agents, Haiku NOT recommended due to tool_reference bug
- **Implementation path**: Add `model:` field to all 7 agent frontmatter files

## Context & Scope

### Research Focus

This report supplements research-001.md with specific focus on:
1. Fixed model assignment per agent type (not dynamic routing)
2. Claude Code Task tool model parameter mechanism
3. Agent-level model configuration via YAML frontmatter
4. Cost optimization through fixed model tiers
5. Integration with existing language-based routing

### User Requirements

1. Lean implementation agents need Opus for complex theorem proving
2. LaTeX planning can use Sonnet
3. Fast routing operations could use Haiku (but see limitations below)

## Findings

### 1. Agent YAML Frontmatter Model Field

The `model` field is **officially supported** in Claude Code agent frontmatter.

#### Syntax

```yaml
---
name: agent-name
description: Agent description
model: opus  # Optional: opus | sonnet | haiku | inherit
---
```

#### Supported Values

| Value | Model | Input/Output Cost (per 1M tokens) | Use Case |
|-------|-------|-----------------------------------|----------|
| `opus` | Claude Opus 4.5 | $5/$25 | Complex reasoning, theorem proving |
| `sonnet` | Claude Sonnet 4.5 | $3/$15 | Standard development, balanced |
| `haiku` | Claude Haiku 4.5 | $1/$5 | Fast, simple tasks |
| `inherit` | Parent's model | Varies | Consistency with main conversation |
| (omitted) | Sonnet (default) | $3/$15 | Default behavior |

#### Behavior Priority

1. **Explicit frontmatter `model` field** - Highest priority, always used
2. **Task tool `model` parameter** - Should work but has bug (see section 3)
3. **Default** - Sonnet when nothing specified

Source: [Claude Code Subagents Documentation](https://code.claude.com/docs/en/sub-agents)

### 2. Current State of This Project's Agents

Analysis of `/home/benjamin/Projects/ProofChecker/.claude/agents/` shows **7 agents**, none with explicit model fields:

| Agent | Current Model | Effective Cost |
|-------|---------------|----------------|
| `lean-implementation-agent` | sonnet (default) | $3/$15 |
| `lean-research-agent` | sonnet (default) | $3/$15 |
| `planner-agent` | sonnet (default) | $3/$15 |
| `general-research-agent` | sonnet (default) | $3/$15 |
| `general-implementation-agent` | sonnet (default) | $3/$15 |
| `latex-implementation-agent` | sonnet (default) | $3/$15 |
| `meta-builder-agent` | sonnet (default) | $3/$15 |

**Current frontmatter example** (lean-implementation-agent.md):
```yaml
---
name: lean-implementation-agent
description: Implement Lean 4 proofs following implementation plans
---
```

**No model field** - defaults to Sonnet.

### 3. Task Tool Model Parameter Bug (GitHub #11682)

**Critical Bug**: The Task tool's `model` parameter causes API 404 errors.

#### Error

```json
{
  "type": "error",
  "error": {
    "type": "not_found_error",
    "message": "model: sonnet"
  }
}
```

#### Root Cause

Short model aliases (`sonnet`, `opus`, `haiku`) are not being resolved to full model IDs (`claude-sonnet-4-5-20250929`, etc.) before API calls.

#### Workaround

**Do NOT rely on Task tool `model` parameter**. Instead:
1. Use `model:` field in agent YAML frontmatter (confirmed working)
2. The subagent will inherit parent's model if no frontmatter model is specified

#### Status

- **Closed as duplicate** of #9243 (November 19, 2025)
- **Marked as regression** ("worked in previous version")

**Implication**: Fixed model assignment MUST be done via frontmatter, not dynamic Task tool parameters.

Source: [GitHub Issue #11682](https://github.com/anthropics/claude-code/issues/11682)

### 4. Haiku Tool Reference Limitation (GitHub #14863)

**Critical Limitation**: Haiku agents fail when many tools are enabled.

#### Error

```
API Error: 400 {"type":"error","error":{"type":"invalid_request_error",
"message":"'claude-haiku-4-5-20251001' does not support tool_reference blocks.
This feature is only available on Claude Sonnet 4+, Opus 4+, and newer models."}}
```

#### Cause

Claude Code v2.0.73+ uses "tool search" optimization (via `tool_reference` blocks) for large tool catalogs. Haiku does NOT support this feature.

#### Affected Scenarios

Haiku agents fail when using:
- Lean MCP tools (11+ tools)
- Agents with many allowed tools (>10)
- Any configuration where tool search is triggered

#### Workarounds

1. **Environment variable**: `ENABLE_TOOL_SEARCH=false` (globally disables tool search)
2. **Use Sonnet/Opus instead** for agents with many tools
3. **Limit tool count** for Haiku agents to <10 tools

#### Status

- **OPEN** as of December 2025
- Fix promised for Claude Code v2.0.76

**Implication**: Haiku is NOT safe for this project's agents due to Lean MCP tool count.

Source: [GitHub Issue #14863](https://github.com/anthropics/claude-code/issues/14863)

### 5. Recommended Fixed Model Assignments

Based on task complexity, tool requirements, and cost optimization:

| Agent | Recommended Model | Rationale |
|-------|-------------------|-----------|
| `lean-implementation-agent` | `opus` | Complex theorem proving requires maximum reasoning capability |
| `lean-research-agent` | `opus` | Lean/Mathlib search requires deep understanding |
| `planner-agent` | `sonnet` | Structured planning is balanced complexity |
| `general-research-agent` | `sonnet` | Web search + synthesis is moderate complexity |
| `general-implementation-agent` | `sonnet` | File operations are standard complexity |
| `latex-implementation-agent` | `sonnet` | Template-based work is moderate complexity |
| `meta-builder-agent` | `sonnet` | System building requires structured output |

**Why NOT Haiku for any agent**:
1. All agents use multiple tools (>5)
2. Lean agents use 11+ MCP tools
3. tool_reference bug makes Haiku unreliable for tool-heavy agents

### 6. Cost Impact Analysis

#### Current Costs (all Sonnet)

| Agent Type | Typical Input | Typical Output | Cost per Task |
|------------|---------------|----------------|---------------|
| Research | ~50K tokens | ~10K tokens | $0.30 |
| Planning | ~30K tokens | ~8K tokens | $0.21 |
| Implementation | ~100K tokens | ~20K tokens | $0.60 |

#### With Recommended Tiers

| Agent | Model | Input | Output | Cost per Task | Change |
|-------|-------|-------|--------|---------------|--------|
| lean-implementation | opus | 100K | 20K | $1.00 | +67% |
| lean-research | opus | 50K | 10K | $0.50 | +67% |
| planner | sonnet | 30K | 8K | $0.21 | 0% |
| general-research | sonnet | 50K | 10K | $0.30 | 0% |
| general-implementation | sonnet | 100K | 20K | $0.60 | 0% |
| latex-implementation | sonnet | 50K | 15K | $0.37 | 0% |
| meta-builder | sonnet | 30K | 10K | $0.24 | 0% |

**Net Impact**: Lean tasks cost ~67% more, but gain maximum reasoning capability for complex proofs.

### 7. Implementation Pattern

#### Adding Model Field to Agent Frontmatter

**Example for lean-implementation-agent.md**:

```yaml
---
name: lean-implementation-agent
description: Implement Lean 4 proofs following implementation plans
model: opus
---
```

**Example for planner-agent.md**:

```yaml
---
name: planner-agent
description: Create phased implementation plans from research findings
model: sonnet
---
```

#### No Skill Changes Required

Skills already use the forked subagent pattern with Task tool. The model is determined by the agent frontmatter, not the skill. No changes to skill files needed.

#### No Orchestrator Changes Required

The orchestrator routes by language to skills, which spawn agents. Model selection is delegated to the agent layer via frontmatter.

### 8. Alternative: Model-Specific Agent Variants

If dynamic model selection becomes needed later, create variants:

```
.claude/agents/
├── lean-implementation-agent.md          # Default (opus)
├── lean-implementation-agent-quick.md    # Sonnet variant for simple proofs
├── research-agent.md                     # Default (sonnet)
├── research-agent-deep.md                # Opus for complex research
```

Skills can then route to variants based on task metadata. This is **not recommended** for initial implementation - start with fixed assignments.

## Decisions

1. **Model assignment mechanism**: Use agent YAML frontmatter `model:` field (not Task tool parameter)
2. **Haiku usage**: Do NOT use Haiku for any agent due to tool_reference bug
3. **Lean agents**: Assign to Opus for maximum theorem proving capability
4. **All other agents**: Keep at Sonnet (good balance of cost/capability)
5. **Skill changes**: None required - models are at agent layer

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Task tool model param bug not fixed | High | Low | Already mitigated by using frontmatter |
| Haiku tool_reference bug persists | Medium | High | Don't use Haiku; set `ENABLE_TOOL_SEARCH=false` as fallback |
| Opus costs too high for frequent Lean work | Medium | Medium | Monitor usage; can downgrade to Sonnet if quality sufficient |
| Frontmatter model field behavior changes | Low | High | Pin to specific model versions if needed |
| Agent not discovered after adding model field | Low | Medium | Restart session after modifying agent files |

## Appendix

### Search Queries Used

1. "Claude Code Task tool model parameter subagent 2026 API specification"
2. "Claude Code agent YAML frontmatter model field opus sonnet haiku specification 2026"
3. "Claude Code cost optimization model tiering Opus Sonnet Haiku best practices 2026"
4. "Claude Code subagent model parameter ignored bug 2026 workaround frontmatter"

### Key References

**Official Documentation**:
- [Claude Code Subagents Documentation](https://code.claude.com/docs/en/sub-agents)
- [Claude Model Configuration Guide](https://support.claude.com/en/articles/11940350-claude-code-model-configuration)

**GitHub Issues**:
- [#11682: Task Tool Model Parameter Causes API 404 Error](https://github.com/anthropics/claude-code/issues/11682)
- [#14863: Haiku agents fail with "tool_reference blocks not supported"](https://github.com/anthropics/claude-code/issues/14863)
- [#9243: Invalid Model Name 'sonnet'](https://github.com/anthropics/claude-code/issues/9243)

**Best Practices**:
- [eesel.ai: Complete Guide to Model Configuration in Claude Code](https://www.eesel.ai/blog/model-configuration-claude-code)
- [Claude Code Customization Guide](https://alexop.dev/posts/claude-code-customization-guide-claudemd-skills-subagents/)
- [PubNub: Best Practices for Claude Code Subagents](https://www.pubnub.com/blog/best-practices-for-claude-code-sub-agents/)
- [ClaudeLog: Task and Agent Tools](https://claudelog.com/mechanics/task-agent-tools/)

**Cost Analysis**:
- [Anthropic Claude API Pricing 2026](https://www.metacto.com/blogs/anthropic-api-pricing-a-full-breakdown-of-costs-and-integration)
- [Claude Model Comparison](https://www.dataannotation.tech/developers/which-claude-model-is-best-for-coding)

### Related Codebase Files

- `/home/benjamin/Projects/ProofChecker/.claude/agents/lean-implementation-agent.md`
- `/home/benjamin/Projects/ProofChecker/.claude/agents/planner-agent.md`
- `/home/benjamin/Projects/ProofChecker/.claude/agents/general-research-agent.md`
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-lean-implementation/SKILL.md`
- `/home/benjamin/Projects/ProofChecker/specs/534_research_claude_code_model_selection/reports/research-001.md`

## Next Steps

1. Run /plan 549 to create implementation plan for adding model fields to all 7 agents
2. Implementation should be straightforward: add one line (`model: opus` or `model: sonnet`) to each agent frontmatter
3. Test by running /research and /implement on Lean vs non-Lean tasks
4. Monitor for Haiku tool_reference fix in future Claude Code versions
