# Research Report: Task #872

**Task**: 872 - Add language-aware teammate routing to team skills
**Started**: 2026-02-11T00:00:00Z
**Completed**: 2026-02-11T00:30:00Z
**Effort**: Medium (3-5 hours implementation)
**Dependencies**: None (builds on existing infrastructure)
**Sources/Inputs**: Codebase exploration (.claude/skills/, .claude/agents/)
**Artifacts**: specs/872_language_aware_teammate_routing_team_skills/reports/research-001.md
**Standards**: report-format.md

## Executive Summary

- Team skills (skill-team-research, skill-team-plan, skill-team-implement) currently spawn generic teammates without language routing
- Single-agent skills already implement language routing (skill-researcher vs skill-lean-research, skill-implementer vs skill-lean-implementation)
- The fix requires modifying teammate prompt generation in all three team skills to include agent selection based on task language
- For Lean tasks, teammates should use lean-research-agent or lean-implementation-agent patterns with access to lean-lsp MCP tools
- Implementation is straightforward: add language check before teammate spawning, adjust prompts accordingly

## Context & Scope

### Problem Statement

Task 870 (Zorn family temporal coherence) demonstrated the failure case where `skill-team-implement` bypassed language routing:

> I jumped straight into implementing Phase 1 directly instead of:
> 1. Analyzing the phase dependencies
> 2. Spawning specialized lean-implementation-agent teammates for each phase
> 3. Coordinating their work and collecting results

The root cause: team skills treat all tasks identically regardless of language, spawning generic teammates that lack access to language-specific tools (e.g., lean-lsp MCP tools for Lean tasks).

### Scope

- Modify three team skills: skill-team-research, skill-team-plan, skill-team-implement
- Add language detection and routing logic
- Update teammate prompts to include appropriate agent patterns
- Ensure MCP tool access for Lean teammates

## Findings

### 1. Current Teammate Spawning Pattern

Team skills currently spawn teammates using TeammateTool with generic prompts:

**skill-team-research** (lines 145-207):
```
Teammate A - Primary Angle:
"Research task {task_number}: {description}
Focus on implementation approaches and patterns.
Output your findings to: specs/{N}_{SLUG}/reports/teammate-a-findings.md"
```

**skill-team-implement** (lines 125-153):
```
Teammate Prompt (Phase Implementer):
"Implement phase {P} of task {task_number}: {phase_description}
Files to modify: {files_list}
When complete: Mark phase as [COMPLETED] in plan file"
```

These prompts do **not**:
- Specify which agent pattern to use
- Include language-specific context references
- Provide access to MCP tools

### 2. Language Field Access

The language field is already extracted in Stage 1 of all team skills:

```bash
# From skill-team-research SKILL.md (lines 52-64)
task_data=$(jq -r --argjson num "$task_number" \
  '.active_projects[] | select(.project_number == $num)' \
  specs/state.json)

language=$(echo "$task_data" | jq -r '.language // "general"')
```

**Available languages** (from CLAUDE.md):
- `lean` - Lean 4 theorem proving
- `latex` - LaTeX documents
- `typst` - Typst documents
- `general` - General programming
- `meta` - System/meta tasks
- `markdown` - Documentation

### 3. Agent Mapping (Single-Agent Pattern)

The single-agent skills already implement language routing. This pattern should be replicated:

| Language | Research Agent | Implementation Agent |
|----------|----------------|---------------------|
| `lean` | lean-research-agent | lean-implementation-agent |
| `latex` | general-research-agent | latex-implementation-agent |
| `typst` | general-research-agent | typst-implementation-agent |
| `general` | general-research-agent | general-implementation-agent |
| `meta` | general-research-agent | general-implementation-agent |
| `markdown` | general-research-agent | general-implementation-agent |

### 4. Lean Agent Requirements

**lean-research-agent** (from agents/lean-research-agent.md):
- Access to lean-lsp MCP tools (lean_leansearch, lean_loogle, lean_leanfinder, etc.)
- Must load: `.claude/context/project/lean4/tools/mcp-tools-guide.md`
- Must follow: `.claude/context/project/lean4/agents/lean-research-flow.md`
- Blocked tools: lean_diagnostic_messages, lean_file_outline

**lean-implementation-agent** (from agents/lean-implementation-agent.md):
- Access to lean-lsp MCP tools (lean_goal, lean_multi_attempt, lean_state_search, etc.)
- Must load: `.claude/context/project/lean4/tools/mcp-tools-guide.md`
- Must load: `.claude/context/project/lean4/patterns/tactic-patterns.md`
- Must verify proofs with `lean_goal` and `lake build`
- Blocked tools: lean_diagnostic_messages, lean_file_outline

### 5. MCP Tool Access for Teammates

**Critical Finding**: MCP tools configured at project scope may not be available to subagents (Claude Code issues #13898, #14496).

From lean-research-agent.md:
> **MCP Scope Note**: Due to Claude Code platform limitations (issues #13898, #14496), this subagent requires lean-lsp to be configured in user scope (`~/.claude.json`). Run `.claude/scripts/setup-lean-mcp.sh` if MCP tools return errors or produce hallucinated results.

**Implication**: Teammates spawned by team skills will have the same limitation. The `.claude/scripts/setup-lean-mcp.sh` script must have been run for Lean teammates to function correctly.

### 6. Teammate Prompt Structure for Language-Aware Routing

Based on the existing agent definitions, teammate prompts for Lean tasks should include:

**For lean-research-agent pattern**:
```
You are a Lean 4 research specialist working as part of a team.

Research task {task_number}: {description}
Focus on: {specific_angle}

REQUIRED: Load and follow @.claude/agents/lean-research-agent.md for execution patterns.
REQUIRED: Load @.claude/context/project/lean4/tools/mcp-tools-guide.md for MCP tool usage.

Use lean-lsp MCP tools:
- lean_local_search (always use first to verify lemmas exist)
- lean_leansearch (natural language search)
- lean_loogle (type pattern search)
- lean_leanfinder (semantic search)

BLOCKED TOOLS (DO NOT CALL):
- lean_diagnostic_messages
- lean_file_outline

Output your findings to: specs/{N}_{SLUG}/reports/teammate-{letter}-findings.md
```

**For lean-implementation-agent pattern**:
```
You are a Lean 4 implementation specialist working as part of a team.

Implement phase {P} of task {task_number}: {phase_description}

REQUIRED: Load and follow @.claude/agents/lean-implementation-agent.md for execution patterns.
REQUIRED: Load @.claude/context/project/lean4/tools/mcp-tools-guide.md for MCP tool usage.

Use lean-lsp MCP tools:
- lean_goal (MOST IMPORTANT - use constantly!)
- lean_multi_attempt (try tactics without editing file)
- lean_state_search (find lemmas to close goal)

BLOCKED TOOLS (DO NOT CALL):
- lean_diagnostic_messages
- lean_file_outline

Files to modify: {files_list}
Verification: Run `lake build` after changes

Output results to: specs/{N}_{SLUG}/phases/phase-{P}-results.md
```

### 7. Required Modifications

**skill-team-research/SKILL.md**:
1. Add Stage 5a: Language Routing Decision
   - Check `language` variable
   - Set `agent_pattern` and `context_refs` based on language
2. Modify Stage 5: Spawn Research Wave
   - Include agent pattern instructions in teammate prompts
   - Include blocked tools list for Lean tasks
   - Include required context references

**skill-team-plan/SKILL.md**:
1. Add Stage 5a: Language Routing Decision
   - Planner teammates are generally language-agnostic
   - However, Lean tasks may benefit from Lean-aware planners that understand proof structure
2. Modify Stage 6: Spawn Planning Wave
   - For Lean tasks, include reference to tactic-patterns.md for phase planning
   - For Lean tasks, note that phases should correspond to proof milestones

**skill-team-implement/SKILL.md**:
1. Add Stage 5a: Language Routing Decision
   - Check `language` variable
   - Set `agent_pattern` based on language
2. Modify Stage 6: Execute Implementation Waves
   - Include agent pattern instructions in phase implementer prompts
   - Include blocked tools list for Lean tasks
   - Include verification requirements (lake build for Lean)
3. Modify Stage 7: Handle Implementation Errors (Debugger)
   - For Lean tasks, include lean_goal usage for error analysis

## Decisions

1. **Agent Pattern Inclusion**: Teammate prompts will include explicit instructions to load and follow the appropriate agent definition file (e.g., `@.claude/agents/lean-research-agent.md`).

2. **MCP Tool Explicit Listing**: Teammate prompts will explicitly list available MCP tools rather than relying on implicit inheritance, since teammates are separate Claude instances.

3. **Blocked Tools Warning**: All Lean teammate prompts will include explicit blocked tools warnings to prevent incorrect behavior.

4. **Verification Requirements**: Lean implementation teammates will be instructed to run `lake build` as verification.

5. **No Separate Lean Planner**: The planner-agent is language-agnostic; Lean-specific planning is handled by including relevant context references rather than creating a separate lean-planner-agent.

## Risks & Mitigations

### Risk 1: MCP Tools Unavailable to Teammates

**Risk**: MCP tools may not be available to teammates due to scope limitations.

**Mitigation**:
- Document requirement for user-scope MCP configuration
- Include fallback instructions in teammate prompts for when MCP tools fail
- Teammates should continue with codebase-only findings if MCP tools are unavailable

### Risk 2: Increased Prompt Complexity

**Risk**: Language-aware prompts are significantly longer, potentially hitting token limits.

**Mitigation**:
- Use @-references for context loading (deferred loading pattern)
- Keep core instructions minimal, delegate to agent definition files
- Test prompt sizes to ensure they remain within limits

### Risk 3: Teammate Coordination Issues

**Risk**: Lean teammates working in parallel may create conflicting changes to the same file.

**Mitigation**:
- Phase dependency analysis should prevent parallel work on dependent phases
- Implementation plan should specify file ownership per phase
- Team lead verifies no conflicts before committing

## Implementation Recommendations

### Phase 1: skill-team-research modifications
- Easiest to implement first
- Low risk (research doesn't modify files)
- Can be tested independently

### Phase 2: skill-team-implement modifications
- Most critical change (addresses task 870 failure)
- Requires careful testing with Lean tasks
- Consider implementing for Lean only first, then generalizing

### Phase 3: skill-team-plan modifications
- Lowest priority
- Planner is mostly language-agnostic
- Only add Lean context references, no major structural changes

### Estimated Effort

- skill-team-research: 1-2 hours
- skill-team-implement: 2-3 hours (more complex due to debugger logic)
- skill-team-plan: 30 minutes
- Testing and validation: 1 hour
- **Total**: 4-6 hours

## Appendix

### Key Files Examined

1. `.claude/skills/skill-team-research/SKILL.md` - Team research orchestration
2. `.claude/skills/skill-team-plan/SKILL.md` - Team planning orchestration
3. `.claude/skills/skill-team-implement/SKILL.md` - Team implementation orchestration
4. `.claude/agents/lean-research-agent.md` - Lean research agent definition
5. `.claude/agents/lean-implementation-agent.md` - Lean implementation agent definition
6. `.claude/agents/general-research-agent.md` - General research agent definition
7. `.claude/agents/general-implementation-agent.md` - General implementation agent definition
8. `.claude/context/core/patterns/team-orchestration.md` - Wave coordination patterns
9. `.claude/utils/team-wave-helpers.md` - Reusable team patterns
10. `.claude/skills/skill-researcher/SKILL.md` - Single-agent research (reference for routing)
11. `.claude/skills/skill-lean-research/SKILL.md` - Lean research skill (reference for routing)
12. `.claude/skills/skill-implementer/SKILL.md` - Single-agent implementation (reference)
13. `.claude/skills/skill-lean-implementation/SKILL.md` - Lean implementation skill (reference)
14. `.claude/output/implement.md` (lines 1740-1770) - Evidence of failure case

### Search Queries Used

1. Codebase: `TeammateTool|Teammate|teammate` in .claude/
2. Codebase: `spawn` in .claude/skills/
3. Codebase: Agent definitions in .claude/agents/
