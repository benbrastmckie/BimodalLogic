# Research Report: Task #480

**Task**: 480 - Investigate workflow delegation early stop issues
**Started**: 2026-01-13T20:18:00Z
**Completed**: 2026-01-13T20:45:00Z
**Effort**: 3-4 hours (estimated for fix implementation)
**Priority**: High
**Dependencies**: None
**Sources/Inputs**:
- Codebase analysis (.claude/agents/, .claude/skills/, .claude/context/)
- GitHub Issues: anthropics/claude-code#6159, anthropics/claude-code-action#599
- Anthropic documentation: claude-code-best-practices
- subagent-return.md specification
**Artifacts**: - specs/480_investigate_workflow_delegation_early_stop/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Root Cause Identified**: Multiple agent files still use `"status": "completed"` in their return format examples, despite `subagent-return.md` explicitly stating this value was removed because "Claude interprets it as a stop signal"
- **6 Agent Files Affected**: All agent files (general-research-agent, lean-research-agent, planner-agent, general-implementation-agent, lean-implementation-agent, latex-implementation-agent) have inconsistent status values
- **External Validation**: GitHub issues #6159 and #599 confirm this is a known Claude Code bug where the agent "terminates prematurely without completing all todos" and "provides a summary as if the entire task is complete"
- **Recommended Fix**: Update all agent files to use contextual status values (researched, planned, implemented) and add explicit anti-stop language

## Context & Scope

Task 480 investigates why workflow delegation causes agents to stop early. Previous fix attempts (tasks 474, 467, 462) did not resolve the issue. This research examines:
1. Codebase patterns in `.claude/output/` logs
2. Agent and skill return format specifications
3. External documentation and GitHub issues about Claude Code behavior
4. Best practices from Anthropic engineering documentation

## Findings

### Finding 1: Inconsistent Status Values in Agent Files

The `subagent-return.md` specification (lines 52-66) explicitly documents:

```
**Success values** (use instead of "completed" to avoid triggering stop behavior):
- `researched`: Research task completed, report created
- `planned`: Planning task completed, plan created
- `implemented`: Implementation task completed, code/files created

**Rationale**: The value "completed" was removed because Claude interprets it as a stop signal, causing workflow commands to halt prematurely after skill returns.
```

However, **6 out of 6 agent files** still document `"status": "completed|partial|failed"` in their return format:

| File | Line | Issue |
|------|------|-------|
| `general-research-agent.md` | 205 | `"status": "completed\|partial\|failed"` |
| `lean-research-agent.md` | 212 | `"status": "completed\|partial\|failed"` |
| `planner-agent.md` | 223 | `"status": "completed\|partial\|failed"` |
| `general-implementation-agent.md` | 176 | `"status": "completed\|partial\|failed"` |
| `lean-implementation-agent.md` | 206 | `"status": "completed\|partial\|failed"` |
| `latex-implementation-agent.md` | 214 | `"status": "completed\|partial\|failed"` |

The examples sections do show correct values (e.g., `"status": "researched"` at line 300 in general-research-agent.md), but the schema definition uses "completed".

### Finding 2: "Task complete" in next_steps Fields

Three skill files use `"next_steps": "Task complete"` which may trigger stop behavior:

| File | Line |
|------|------|
| `skill-latex-implementation/SKILL.md` | 161 |
| `skill-lean-implementation/SKILL.md` | 154 |
| `skill-implementer/SKILL.md` | 138 |

### Finding 3: GitHub Issues Confirm This is a Known Bug

**GitHub Issue #6159** (anthropics/claude-code, closed as duplicate):
- Reports Claude stopping after completing only 5 of 10 todo items
- "Claude correctly generates a detailed plan and creates a TodoWrite list to track progress"
- "It completes only a portion of the planned tasks (typically the first few phases)"
- "It then stops and provides a summary as if the entire task is complete"
- Identified root cause: "lacks a 'plan execution loop' mechanism"

**GitHub Issue #599** (anthropics/claude-code-action, open):
- "Claude Code Action is tuned to 'complete tasks' rather than actually completing tasks"
- Uses ~10-15 of 30 configured max turns but stops anyway
- "The base/beta version performs much better with fewer missed todos"
- The issue is particularly acute in v1 release

### Finding 4: Anthropic Best Practices Recommendations

From [Claude Code: Best practices for agentic coding](https://www.anthropic.com/engineering/claude-code-best-practices):

1. **Use Checklists**: "Use a Markdown file as a checklist and working scratchpad" for large tasks
2. **Explicit Planning Gates**: "Make a plan for how to approach a specific problem" and "explicitly tell it not to code until you've confirmed"
3. **Context Reset**: "Use `/clear` command frequently between tasks to reset context window"
4. **Course Correction**: Four mechanisms - make plans first, Escape to interrupt, double-Escape to edit, ask Claude to undo

### Finding 5: skill-status-sync Already Has Correct Pattern

The `skill-status-sync/SKILL.md` correctly implements anti-stop patterns:
- Line 53: `Returns "status": "synced" (not "completed") to avoid triggering Claude's stop behavior`
- Line 80: `Returns "status": "{target_status}" (e.g., "planned", "researched", "implemented")`
- Line 121: `Returns "status": "linked" (not "completed") to avoid triggering Claude's stop behavior`
- Line 622: `The value "completed" is avoided because Claude interprets it as a stop signal`

This proves the project already has the correct pattern - it just hasn't been consistently applied to agents.

### Finding 6: Output Log Analysis

The `.claude/output/research.md` log shows a successful workflow pattern:
1. GATE IN (preflight): Status update to [RESEARCHING]
2. DELEGATE: Skill invocation
3. GATE OUT (postflight): Status update to [RESEARCHED]
4. COMMIT: Git commit

The skill shows `Done` after delegation (line 63: `Skill(skill-researcher) ⎿ Done`), but the orchestrator correctly continues to GATE OUT. This suggests the issue may be intermittent or context-dependent.

### Finding 7: Additional Stop Trigger Patterns

Patterns that may trigger early stop:
1. Words/phrases: "completed", "finished", "done", "task complete", "work is done"
2. TodoWrite with all items checked
3. Summary-like responses that feel conclusive
4. Return status indicating finality

## Decisions

Based on research findings:

1. **Update all agent files** to use contextual status values matching subagent-return.md
2. **Remove "Task complete"** from next_steps fields in skill files
3. **Add explicit continuation language** to agent instructions (e.g., "After returning, orchestrator will continue to GATE OUT")
4. **Consider adding anti-stop markers** to delegation contexts

## Recommendations

### Priority 1: Fix Agent Return Format Schemas (High Impact, Low Effort)

Update all 6 agent files to change the return format schema from:
```json
"status": "completed|partial|failed"
```
To:
```json
"status": "researched|partial|failed"  // for research agents
"status": "planned|partial|failed"     // for planner agent
"status": "implemented|partial|failed" // for implementation agents
```

### Priority 2: Fix "Task complete" in Skills (Medium Impact, Low Effort)

Replace `"next_steps": "Task complete"` with `"next_steps": "Implementation finished. Run /task --sync to verify."` or similar non-terminal language.

### Priority 3: Add Anti-Stop Instructions to Agents (Medium Impact, Medium Effort)

Add to each agent's Critical Requirements section:
```markdown
**Anti-Stop Behavior**:
- NEVER use the word "completed" in status fields
- NEVER say "task is complete" or "work is done" in summaries
- After returning JSON, orchestrator will continue with postflight updates
- Your return does NOT end the workflow - more steps follow
```

### Priority 4: Review Orchestrator Delegation Context (Low Priority)

Consider adding explicit instructions to the delegation prompt:
```
IMPORTANT: After you return your JSON result, the orchestrator will perform
additional operations (postflight status update, artifact linking, git commit).
Your return does NOT signal the end of the workflow.
```

### Priority 5: Implement State Machine Pattern (Optional Enhancement)

Based on GitHub feedback, consider implementing a more explicit state machine:
- Define explicit "Executing Plan" state
- Block stop action while pending tasks remain
- Require explicit transition to "Plan Complete" state

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Claude ignores anti-stop language | High | Medium | Multiple reinforcement points, use CRITICAL markers |
| Changes break existing workflows | Medium | Low | Incremental changes, test each agent type |
| Inconsistency across agent types | Low | Medium | Use find/replace with verification |
| Claude Code updates change behavior | Medium | Low | Document Claude Code version, re-test on updates |

## Appendix

### Search Queries Used

1. `"status": "completed"` in .claude/ - Found 20+ occurrences
2. `complete|finish|done` patterns - Found "Task complete" in 3 skill files
3. `early stop|premature|termination` on GitHub - Found issues #6159, #599
4. `Claude Code best practices` - Found Anthropic engineering blog

### References

- [Claude Code: Best practices for agentic coding](https://www.anthropic.com/engineering/claude-code-best-practices)
- [GitHub Issue #6159: Agent Reliability - Claude Stops Mid-Task](https://github.com/anthropics/claude-code/issues/6159)
- [GitHub Issue #599: Premature Task Termination](https://github.com/anthropics/claude-code-action/issues/599)
- `.claude/context/core/formats/subagent-return.md` (lines 52-66)
- `.claude/skills/skill-status-sync/SKILL.md` (anti-stop pattern reference)

### Files Requiring Updates

**Agent Files** (schema fix):
1. `/home/benjamin/Projects/ProofChecker/.claude/agents/general-research-agent.md` - Line 205
2. `/home/benjamin/Projects/ProofChecker/.claude/agents/lean-research-agent.md` - Line 212
3. `/home/benjamin/Projects/ProofChecker/.claude/agents/planner-agent.md` - Line 223
4. `/home/benjamin/Projects/ProofChecker/.claude/agents/general-implementation-agent.md` - Line 176
5. `/home/benjamin/Projects/ProofChecker/.claude/agents/lean-implementation-agent.md` - Line 206
6. `/home/benjamin/Projects/ProofChecker/.claude/agents/latex-implementation-agent.md` - Line 214

**Skill Files** ("Task complete" fix):
1. `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-latex-implementation/SKILL.md` - Line 161
2. `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-lean-implementation/SKILL.md` - Line 154
3. `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-implementer/SKILL.md` - Line 138

**Documentation Files** (optional consistency):
- `.claude/ARCHITECTURE.md`
- `.claude/docs/templates/agent-template.md`
- `.claude/docs/guides/creating-agents.md`
