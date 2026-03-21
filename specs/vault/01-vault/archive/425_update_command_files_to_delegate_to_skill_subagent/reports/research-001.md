# Research Report: Task #415

**Task**: Update command files to delegate to skill/subagent system
**Date**: 2026-01-12
**Focus**: Research all commands that could benefit from delegating to appropriate skill/subagent systems instead of executing inline

## Summary

The current command files (`.claude/commands/*.md`) execute inline rather than delegating to the skill → subagent chain established in tasks 409-414. Three primary workflow commands (/research, /plan, /implement) should be updated to delegate to their corresponding skills, while five auxiliary commands (/task, /review, /todo, /meta, /errors, /revise) do not require subagent delegation due to their nature.

## Findings

### Current Command Architecture

All 9 command files in `.claude/commands/` currently specify full `allowed-tools` lists and describe inline execution steps:

| Command | Current allowed-tools | Inline? |
|---------|----------------------|---------|
| /research | Read, Write, Edit, Glob, Grep, WebSearch, WebFetch, Bash, TodoWrite, lean MCP tools | Yes |
| /plan | Read, Write, Edit, Glob, Grep, Bash, TodoWrite | Yes |
| /implement | Read, Write, Edit, Glob, Grep, Bash, Task, TodoWrite, lean MCP tools | Yes |
| /task | Read, Edit, Bash (limited), TodoWrite | Yes |
| /review | Read, Write, Edit, Glob, Grep, Bash, TodoWrite, lean MCP tools | Yes |
| /todo | Read, Write, Edit, Glob, Grep, Bash, TodoWrite, AskUserQuestion | Yes |
| /meta | Read, Write, Edit, Glob, Grep, Bash, Task, TodoWrite, AskUserQuestion | Yes |
| /errors | Read, Write, Edit, Glob, Grep, Bash, TodoWrite, Task | Yes |
| /revise | Read, Write, Edit, Glob, Grep, Bash, TodoWrite | Yes |

### Available Skill → Agent Infrastructure

Tasks 409-414 established this delegation chain:

| Skill | Agent | Purpose |
|-------|-------|---------|
| skill-lean-research | lean-research-agent | Lean 4/Mathlib research |
| skill-researcher | general-research-agent | General web/codebase research |
| skill-planner | planner-agent | Implementation plan creation |
| skill-implementer | general-implementation-agent | General implementation |
| skill-lean-implementation | lean-implementation-agent | Lean proof implementation |
| skill-latex-implementation | latex-implementation-agent | LaTeX document implementation |

### Commands That SHOULD Delegate to Subagents

**1. /research** - Token-heavy operation
- Language detection: lean → skill-lean-research, else → skill-researcher
- Benefits: Token efficiency, isolation, specialized tool access
- Required changes: Reduce `allowed-tools` to `Skill, Bash(jq:*), Read`
- New execution: Look up task language, invoke appropriate skill via Skill tool

**2. /plan** - Moderate token usage
- All languages → skill-planner
- Benefits: Consistent planning patterns, context isolation
- Required changes: Reduce `allowed-tools` to `Skill, Bash(jq:*), Read`
- New execution: Invoke skill-planner via Skill tool

**3. /implement** - Heaviest token usage
- Language detection: lean → skill-lean-implementation, latex → skill-latex-implementation, else → skill-implementer
- Benefits: Highest token savings, specialized tool access, resume support
- Required changes: Reduce `allowed-tools` to `Skill, Bash(jq:*), Read`
- New execution: Look up task language, invoke appropriate skill via Skill tool

### Commands That Should NOT Delegate

**4. /task** - State management only
- Purpose: CRUD operations on TODO.md and state.json
- No heavy computation, no file exploration
- Explicit constraint: "ONLY touches files in `specs/`"
- Keep inline execution

**5. /todo** - Archive operations
- Purpose: Move completed tasks to archive
- Involves user prompts (AskUserQuestion) for orphan handling
- State management operations, not content generation
- Keep inline execution

**6. /meta** - Interactive interview + task creation
- Purpose: Guide user through task creation
- Multi-stage interview with checkpoints
- Uses AskUserQuestion extensively
- Creates tasks, not content
- Keep inline execution

**7. /review** - Could benefit but lower priority
- Purpose: Analyze codebase and create reports
- Mixed behavior: some analysis, some state updates
- Could eventually delegate to review-agent (not yet exists)
- Keep inline for now, consider future enhancement

**8. /errors** - Analysis + task creation
- Purpose: Analyze errors.json, create fix plans
- --fix mode delegates to implementation
- Keep inline for now, consider future enhancement

**9. /revise** - Plan revision
- Purpose: Create new plan version OR update description
- Calls skill-status-sync for atomic updates
- Could delegate to planner-agent for plan revision
- Keep inline for now, simpler hybrid approach

### Delegation Pattern for Commands

Commands that delegate should follow this pattern:

```markdown
---
description: {description}
allowed-tools: Skill, Bash(jq:*), Read
argument-hint: TASK_NUMBER
---

# /{command} Command

## Arguments
- `$1` - Task number (required)

## Execution

### 1. Parse and Validate
Look up task in state.json, extract language and status.

### 2. Validate Status
Check task status allows the operation.

### 3. Update Status
Invoke skill-status-sync for preflight status update.

### 4. Route by Language and Invoke Skill
Based on task language, invoke appropriate skill via Skill tool:
- lean → skill-{operation}-lean or skill-lean-{operation}
- latex → skill-latex-{operation}
- general/meta/markdown → skill-{operation}

The skill will spawn a subagent via Task tool.

### 5. Handle Return
Receive JSON result from skill, propagate to user.

### 6. Update Status
Invoke skill-status-sync for postflight status update.

### 7. Git Commit
Commit changes.

### 8. Output
Display summary to user.
```

### Status Sync Considerations

Commands currently call skill-status-sync for atomic state updates. This should continue, but the skill invocation should happen between pre-flight and post-flight status updates:

1. Preflight: Update status to "in progress" state (researching/planning/implementing)
2. Invoke skill → subagent does work
3. Postflight: Update status to "completed" state (researched/planned/completed)

The skill/subagent handles the actual work, while the command handles status transitions and git commits.

## Recommendations

### Phase 1: Update Primary Workflow Commands (Priority)
1. Update `/research` to delegate to skill-lean-research or skill-researcher
2. Update `/plan` to delegate to skill-planner
3. Update `/implement` to delegate to skill-lean-implementation, skill-latex-implementation, or skill-implementer

### Phase 2: Consider Future Enhancements (Optional)
4. Create review-agent for /review delegation (new agent needed)
5. Update /revise to delegate plan revision to planner-agent (partial delegation)

### Implementation Strategy

For each command update:
1. Reduce `allowed-tools` to minimal set: `Skill, Bash(jq:*), Read`
2. Keep task validation and status lookup (uses jq)
3. Replace inline execution with Skill tool invocation
4. Keep status updates (skill-status-sync) and git commits in command
5. Update output format to show subagent results

### Key Files to Modify

- `.claude/commands/research.md` - Full rewrite
- `.claude/commands/plan.md` - Full rewrite
- `.claude/commands/implement.md` - Full rewrite

### Files to Leave Unchanged

- `.claude/commands/task.md` - State management, no heavy work
- `.claude/commands/todo.md` - Archive operations, interactive
- `.claude/commands/meta.md` - Interview-based, creates tasks
- `.claude/commands/review.md` - Keep inline for now
- `.claude/commands/errors.md` - Keep inline for now
- `.claude/commands/revise.md` - Keep inline for now

## References

- `.claude/skills/skill-lean-research/SKILL.md` - Thin wrapper pattern example
- `.claude/agents/lean-research-agent.md` - Agent execution pattern
- `specs/409_*/summaries/implementation-summary-20260112.md` - Task 409 implementation
- `.claude/CLAUDE.md` - Skill architecture documentation

## Next Steps

1. Create implementation plan with 3 phases (one per command)
2. Update /research command first as proof of concept
3. Update /plan command
4. Update /implement command
5. Test full workflow: /research → /plan → /implement
6. Verify subagents are being spawned correctly
