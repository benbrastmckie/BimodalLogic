# Research Report: Task #411

**Task**: 411 - Create lean-research-agent subagent with lazy context
**Date**: 2026-01-12
**Focus**: Agent architecture, MCP tool integration, return format requirements

## Summary

This research analyzed the existing skill-lean-research thin wrapper and the context/tools it references to design a lean-research-agent subagent. The subagent must load Lean-specific context files on-demand, use MCP search tools for Mathlib exploration, and return structured JSON matching the subagent-return.md schema.

## Findings

### 1. Existing Skill Interface

The `skill-lean-research/SKILL.md` already defines the integration contract:

**Frontmatter**:
```yaml
name: skill-lean-research
allowed-tools: Task
context: fork
agent: lean-research-agent
```

**Original context files** (to be loaded by subagent):
- `.claude/context/project/lean4/tools/mcp-tools-guide.md` (398 lines)
- `.claude/context/project/lean4/tools/leansearch-api.md` (492 lines)
- `.claude/context/project/lean4/tools/loogle-api.md` (572 lines)

**Original tools** (to be used by subagent):
- File tools: Read, Write, Edit, Glob, Grep
- MCP tools: lean_leansearch, lean_loogle, lean_leanfinder, lean_local_search, lean_hover_info, lean_state_search, lean_hammer_premise

### 2. MCP Tools and Search Decision Tree

The search decision tree from `mcp-tools-guide.md`:

| Question | Tool |
|----------|------|
| "Does X exist locally?" | `lean_local_search` (no rate limit) |
| "I need a lemma that says X" | `lean_leansearch` (3 req/30s) |
| "Find lemma with type pattern" | `lean_loogle` (3 req/30s) |
| "What's the Lean name for concept X?" | `lean_leanfinder` (10 req/30s) |
| "What closes this goal?" | `lean_state_search` (3 req/30s) |
| "What to feed simp?" | `lean_hammer_premise` (3 req/30s) |

**Verification pattern**: After finding a name, use:
1. `lean_local_search` to verify it exists
2. `lean_hover_info` for full signature

### 3. Return Format Requirements

From `subagent-return.md`, the agent MUST return:

```json
{
  "status": "completed|partial|failed|blocked",
  "summary": "Brief 2-5 sentence summary (<100 tokens)",
  "artifacts": [
    {
      "type": "report",
      "path": "specs/{N}_{SLUG}/reports/research-{NNN}.md",
      "summary": "Brief description"
    }
  ],
  "metadata": {
    "session_id": "sess_{timestamp}_{random}",
    "duration_seconds": 123,
    "agent_type": "lean-research-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "research", "lean-research-agent"]
  },
  "errors": [],
  "next_steps": "Run /plan {N} to create implementation plan"
}
```

**Critical**: The orchestrator appends JSON format instructions to all subagent invocations. The agent MUST return ONLY valid JSON, not plain text or markdown narrative.

### 4. Report Format Requirements

From `report-format.md`, research reports must include:

- **Metadata**: Task, Started, Completed, Effort, Priority
- **Structure**: Executive Summary, Context & Scope, Findings, Decisions, Recommendations, Appendix
- **Guidelines**: No emojis, no status markers (those go in TODO.md), cite sources/paths

### 5. Delegation Context

The skill passes delegation context to the subagent:
```json
{
  "session_id": "sess_{timestamp}_{random}",
  "delegation_depth": 1,
  "delegation_path": ["orchestrator", "research", "skill-lean-research"],
  "timeout": 3600,
  "task_context": {
    "task_number": N,
    "task_name": "{project_name}",
    "description": "{description}",
    "language": "lean"
  },
  "focus_prompt": "{optional focus}"
}
```

### 6. Agent Directory Structure

Task 409 summary indicates agents should be created in `.claude/agents/` directory. Since no agents exist yet (Glob returned empty), this will be the first agent file.

### 7. Lazy Context Loading Pattern

From `context/index.md`, the pattern is:
- Load NO context during routing (Stages 1-3)
- Load only needed files during execution (Stage 4+)
- Use @-references: `@.claude/context/project/lean4/tools/mcp-tools-guide.md`

The subagent should reference context files on-demand, not load them eagerly in frontmatter.

## Recommendations

### Agent File Structure

Create `.claude/agents/lean-research-agent.md` with:

1. **Frontmatter**:
   - `name: lean-research-agent`
   - `description: Research agent for Lean 4 and Mathlib theorem discovery`
   - `allowed-tools: Read, Write, Edit, Glob, Grep, Bash, mcp__lean-lsp__*`
   - No eager context loading (use @-references in body)

2. **Context References** (loaded on-demand):
   - `@.claude/context/project/lean4/tools/mcp-tools-guide.md`
   - `@.claude/context/project/lean4/tools/leansearch-api.md`
   - `@.claude/context/project/lean4/tools/loogle-api.md`
   - `@.claude/context/core/formats/report-format.md`
   - `@.claude/context/core/formats/subagent-return.md`

3. **Execution Flow**:
   - Stage 1: Parse task context from delegation
   - Stage 2: Determine search strategy based on task description/focus
   - Stage 3: Execute searches using decision tree
   - Stage 4: Synthesize findings into research report
   - Stage 5: Return structured JSON

4. **Search Strategy Selection**:
   - If task mentions specific theorem names: Start with `lean_local_search`
   - If task is exploratory: Use `lean_leansearch` or `lean_leanfinder`
   - If task specifies type patterns: Use `lean_loogle`
   - If researching specific proof state: Use `lean_state_search`

### Artifact Creation

The agent must:
1. Create directory: `specs/{N}_{SLUG}/reports/` (if not exists)
2. Find next report number (research-001.md, research-002.md, etc.)
3. Write report following `report-format.md` structure
4. Return JSON with artifact path

### Error Handling

The agent should handle:
- MCP tool timeouts (rate limits)
- No results found (suggest alternative queries)
- Invalid task number (fail fast)
- Network errors (return partial with recoverable error)

## References

- Skill definition: `.claude/skills/skill-lean-research/SKILL.md`
- MCP tools guide: `.claude/context/project/lean4/tools/mcp-tools-guide.md`
- LeanSearch API: `.claude/context/project/lean4/tools/leansearch-api.md`
- Loogle API: `.claude/context/project/lean4/tools/loogle-api.md`
- Return format: `.claude/context/core/formats/subagent-return.md`
- Report format: `.claude/context/core/formats/report-format.md`
- Thin wrapper template: `.claude/context/core/templates/thin-wrapper-skill.md`
- Delegation patterns: `.claude/context/core/orchestration/delegation.md`
- Context index: `.claude/context/index.md`
- Task 409 summary: `specs/409_convert_workflow_skills_to_forked_subagent_pattern/summaries/implementation-summary-20260112.md`

## Next Steps

1. Proceed to `/plan 411` to create a phased implementation plan
2. The plan should define the agent file structure and execution logic
3. Implementation will create `.claude/agents/lean-research-agent.md`
