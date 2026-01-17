# Implementation Plan: Task #536

**Task**: Refactor Dispatch/Routing Skills to Use Haiku
**Version**: 001
**Created**: 2026-01-17
**Language**: meta
**Session ID**: sess_1768660132_130ba0

## Overview

This task aimed to configure dispatch/routing skills (skill-orchestrator, skill-status-sync, skill-git-workflow) to use Haiku for cost/latency optimization. However, architectural analysis reveals this is **not applicable** in the current design.

## Architectural Analysis

### Skills vs Agents

| Component | Execution Context | Model Selection |
|-----------|-------------------|-----------------|
| **Agents** (.claude/agents/) | Spawned as subagents via Task tool | Frontmatter `model:` field |
| **Skills** (.claude/skills/) | Execute in main conversation | Inherit main conversation model |

### Target Skills Analysis

1. **skill-orchestrator**: Routes to other agents via Task tool. The spawned agents have their own model settings (now configured in Task 535).

2. **skill-status-sync**: Executes directly using Read, Write, Edit, Bash. No subagent spawning. Runs in main conversation context.

3. **skill-git-workflow**: Executes directly using Bash. No subagent spawning. Runs in main conversation context.

### Conclusion

Skills that don't spawn subagents cannot have independent model settings. They execute in the main conversation's model context (typically Opus for interactive sessions).

## Phases

### Phase 1: Document Architecture Limitation

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Document that skills inherit the main conversation model
2. Update task description to reflect this finding
3. Consider if lightweight dispatch agents should be created for Haiku optimization

**Options for Future Consideration**:

**Option A**: Accept current design (skills run in main context)
- Pros: Simple, no code changes needed
- Cons: No Haiku optimization for dispatch operations

**Option B**: Create lightweight dispatch agents
- Create `dispatch-agent` with `model: haiku` for simple routing
- Have skill-orchestrator spawn this agent for lightweight operations
- Pros: Achieves Haiku optimization
- Cons: Adds complexity, may not be worth it for simple operations

**Recommendation**: Accept Option A. The dispatch operations are fast enough that Haiku optimization provides minimal benefit. The main cost/latency savings come from using Sonnet (vs Opus) for heavy-lifting agents, which is already done in Task 535.

---

## Dependencies

- Task 534 (completed) - Research findings clarified architecture
- Task 535 (completed) - Agents now have explicit model settings

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Haiku limitation with tool_reference | High | Not applicable - skills don't run as Haiku subagents |

## Success Criteria

- [x] Architecture limitation documented
- [ ] Task marked as N/A or completed with explanation
