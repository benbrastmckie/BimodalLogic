# Research Report: Task #562

**Task**: 562 - agent_system_refactor_report
**Started**: 2026-01-17T21:35:00Z
**Completed**: 2026-01-17T22:00:00Z
**Effort**: 2-3 hours
**Priority**: Medium
**Dependencies**: None
**Sources/Inputs**:
- ProofChecker task archive (specs/archive/)
- ProofChecker .claude/ agent system
- Completed refactor tasks: 480, 539, 541, 548, 555
**Artifacts**: specs/562_agent_system_refactor_report/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

This report documents the agent system refactors completed in ProofChecker's `.claude/` system during January 2026 that addressed critical issues with skill-to-agent delegation failures, workflow interruptions ("continue" prompts), and premature task termination. The changes can be replicated in `protocol/.claude/` to achieve similar improvements.

**Key Issues Resolved**:
1. Skills incorrectly calling `Skill()` instead of `Task()` for agent delegation
2. Inline skill execution causing workflow interruptions requiring user "continue" prompts
3. Agents returning `"status": "completed"` triggering Claude's stop behavior prematurely

**Primary Solutions**:
1. Add explicit CRITICAL Task tool directives to all forked skills
2. Convert inline-execution skills to forked subagent pattern
3. Implement anti-stop patterns (contextual status values instead of "completed")

## Context & Scope

### The Problem

ProofChecker's agent system experienced systematic failures where:
- Workflow commands (/research, /plan, /implement) would abort midway
- Users needed to type "continue" to resume after skill invocations
- OOM crashes occurred from recursive error states when skills called wrong tools
- Tasks would prematurely terminate claiming "complete" when work remained

### Root Cause Analysis Chain

The following tasks progressively identified and fixed the root causes:

| Task | Focus | Key Finding |
|------|-------|-------------|
| 480 | Investigate early stop | Agents returning `"completed"` triggers Claude stop |
| 539 | Test model tiering | Skills calling `Skill()` instead of `Task()` for agents |
| 541 | Progressive disclosure | Architecture well-designed but invocation pattern ambiguous |
| 548 | Fix delegation pattern | Added explicit Task tool directives to 7 forked skills |
| 555 | Convert status-sync | Inline execution causes interruptions; forked pattern solves |

## Finding 1: Skill-to-Agent Delegation Confusion

### Problem Description

Skills with `agent:` frontmatter field caused Claude to invoke agents using `Skill()` instead of `Task()`:

```
Expected: Skill(skill-researcher) -> Task(general-research-agent)
Actual:   Skill(skill-researcher) -> Skill(general-research-agent)  # WRONG
```

Since agents live in `.claude/agents/` (not `.claude/skills/`), the `Skill()` call fails.

### Root Cause

The `agent:` field in skill frontmatter is a **custom convention**, not a native Claude Code field. Claude pattern-matches this field and incorrectly uses `Skill()` instead of `Task()`.

**Problematic Pattern**:
```markdown
### 3. Invoke Subagent

Invoke `general-research-agent` via Task tool with:
- Task context (number, name, description, language)
```

This prose is not actionable enough for Claude to reliably use the correct tool.

### Solution: Explicit Task Tool Directive (Task 548)

Add CRITICAL directive to all forked skills:

```markdown
### 3. Invoke Subagent

**CRITICAL**: You MUST use the **Task** tool to spawn the subagent.

The `agent` field in this skill's frontmatter specifies the target: `{AGENT_NAME}`

**Required Tool Invocation**:
Tool: Task (NOT Skill)
Parameters:
  - subagent_type: "{AGENT_NAME}"
  - prompt: [Include task_context, delegation_context, focus_prompt if present]
  - description: "Execute {OPERATION} for task {N}"

**DO NOT** use `Skill({AGENT_NAME})` - this will FAIL.
Agents live in `.claude/agents/`, not `.claude/skills/`.
The Skill tool can only invoke skills from `.claude/skills/`.
```

### Affected Files

All skills with `context: fork` and `agent:` frontmatter need this fix:
- skill-researcher -> general-research-agent
- skill-lean-research -> lean-research-agent
- skill-planner -> planner-agent
- skill-implementer -> general-implementation-agent
- skill-lean-implementation -> lean-implementation-agent
- skill-latex-implementation -> latex-implementation-agent
- skill-meta -> meta-builder-agent

### Reference Links

- Research: [specs/archive/548_fix_skill_to_agent_delegation_pattern/reports/research-001.md](/home/benjamin/Projects/ProofChecker/specs/archive/548_fix_skill_to_agent_delegation_pattern/reports/research-001.md)
- Plan: [specs/archive/548_fix_skill_to_agent_delegation_pattern/plans/implementation-001.md](/home/benjamin/Projects/ProofChecker/specs/archive/548_fix_skill_to_agent_delegation_pattern/plans/implementation-001.md)
- Summary: [specs/archive/548_fix_skill_to_agent_delegation_pattern/summaries/implementation-summary-20260117.md](/home/benjamin/Projects/ProofChecker/specs/archive/548_fix_skill_to_agent_delegation_pattern/summaries/implementation-summary-20260117.md)

---

## Finding 2: Inline Skill Execution Causes Interruptions

### Problem Description

Skills that execute directly (using `allowed-tools: Read, Write, Edit, Bash` instead of `allowed-tools: Task`) cause workflow interruptions. After the skill completes and returns JSON, Claude interprets this as a stopping point and waits for user input.

**Symptom**: Users see skill output, then must type "continue" to proceed with postflight operations.

### Root Cause

Inline skill execution creates natural "stopping points":
1. Skill executes directly using Read, Write, Edit, Bash
2. Skill returns JSON result
3. Claude interprets JSON output as "response complete"
4. User must say "continue" to resume orchestrator flow

Forked skills (using `allowed-tools: Task`) avoid this because:
1. Task tool spawns separate conversation for agent
2. Agent runs to completion independently
3. Agent returns result to skill (not directly to user)
4. Parent conversation automatically continues

### Solution: Convert to Forked Subagent Pattern (Task 555)

Transform inline skills into thin wrappers that delegate to agents.

**Before (inline execution)**:
```yaml
---
name: skill-status-sync
allowed-tools: Read, Write, Edit, Bash  # Direct execution
# No context: fork
# No agent: field
---
# 693 lines of inline jq/grep patterns
```

**After (forked pattern)**:
```yaml
---
name: skill-status-sync
allowed-tools: Task           # Only delegates
context: fork                  # Signal: lazy context loading
agent: status-sync-agent       # Target subagent
---
# ~200 lines thin wrapper + CRITICAL Task tool directive
```

Then create the actual agent file with the execution logic.

### Reference Links

- Research: [specs/archive/555_convert_skill_status_sync_to_forked_pattern/reports/research-001.md](/home/benjamin/Projects/ProofChecker/specs/archive/555_convert_skill_status_sync_to_forked_pattern/reports/research-001.md)
- Plan: [specs/archive/555_convert_skill_status_sync_to_forked_pattern/plans/implementation-001.md](/home/benjamin/Projects/ProofChecker/specs/archive/555_convert_skill_status_sync_to_forked_pattern/plans/implementation-001.md)
- Summary: [specs/archive/555_convert_skill_status_sync_to_forked_pattern/summaries/implementation-summary-20260117.md](/home/benjamin/Projects/ProofChecker/specs/archive/555_convert_skill_status_sync_to_forked_pattern/summaries/implementation-summary-20260117.md)

---

## Finding 3: "Completed" Status Triggers Premature Stop

### Problem Description

Agent files returned `"status": "completed"` which triggers Claude's stop behavior, causing workflows to terminate before postflight operations (artifact linking, git commit) execute.

### Root Cause

Claude Code interprets certain words/phrases as signals to stop:
- "completed", "finished", "done"
- "task complete", "work is done"
- Summary-like responses that feel conclusive

### Solution: Anti-Stop Patterns (Task 480)

Replace terminal status values with contextual ones:

| Operation | Bad Status | Good Status |
|-----------|------------|-------------|
| Research | completed | researched |
| Planning | completed | planned |
| Implementation | completed | implemented |
| Status sync | completed | synced |
| Artifact link | completed | linked |

**Add to agent Critical Requirements**:
```markdown
**MUST NOT**:
- Return the word "completed" as a status value
- Use phrases like "task is complete", "work is done", or "finished" in summaries
- Assume your return ends the workflow (orchestrator continues with postflight)
```

### Reference Links

- Research: [specs/archive/480_investigate_workflow_delegation_early_stop/reports/research-001.md](/home/benjamin/Projects/ProofChecker/specs/archive/480_investigate_workflow_delegation_early_stop/reports/research-001.md)
- Plan: [specs/archive/480_investigate_workflow_delegation_early_stop/plans/implementation-001.md](/home/benjamin/Projects/ProofChecker/specs/archive/480_investigate_workflow_delegation_early_stop/plans/implementation-001.md)
- Summary: [specs/archive/480_investigate_workflow_delegation_early_stop/summaries/implementation-summary-20260113.md](/home/benjamin/Projects/ProofChecker/specs/archive/480_investigate_workflow_delegation_early_stop/summaries/implementation-summary-20260113.md)

---

## Finding 4: Architecture Validation (Task 541)

### Confirmed Good Patterns

Task 541's research validated that the overall architecture follows 2026 Claude Code best practices:

| Pattern | Status | Assessment |
|---------|--------|------------|
| Three-tier hierarchy (command-skill-agent) | Implemented | Good separation of concerns |
| Lazy context loading via `context: fork` | Implemented | Prevents context bloat |
| Standardized return format (subagent-return.md) | Implemented | Enables validation |
| Session ID tracking | Implemented | Full traceability |
| Anti-stop patterns | Documented | Contextual status values |
| Model tiering (sonnet/opus/haiku) | Implemented | Cost optimization |
| Language-based routing | Implemented | Lean vs general agents |

### Tool Directory Mapping

This critical distinction was not well documented:

| Directory | Tool | Usage |
|-----------|------|-------|
| `.claude/skills/` | Skill tool | Invoke skills (SKILL.md files) |
| `.claude/agents/` | Task tool | Spawn subagents (agent .md files) |
| `.claude/commands/` | Direct | User-invoked via /command |

### Reference Links

- Research: [specs/archive/541_progressive_disclosure_refactor/reports/research-001.md](/home/benjamin/Projects/ProofChecker/specs/archive/541_progressive_disclosure_refactor/reports/research-001.md)
- Plan: [specs/archive/541_progressive_disclosure_refactor/plans/implementation-001.md](/home/benjamin/Projects/ProofChecker/specs/archive/541_progressive_disclosure_refactor/plans/implementation-001.md)

---

## Implementation Checklist for protocol/.claude/

### Phase 1: Audit Current State

1. List all skills with `agent:` frontmatter field
2. Identify which skills use inline execution (`allowed-tools: Read, Write, Edit, Bash`)
3. Check all agent return format schemas for `"completed"` status values

### Phase 2: Fix Skill-to-Agent Delegation (Priority 1)

For each skill with `context: fork` and `agent:` field:

1. Locate the "Invoke Subagent" section
2. Add the CRITICAL Task tool directive (template in Finding 1)
3. Ensure agent name matches frontmatter `agent:` field

### Phase 3: Convert Inline Skills to Forked Pattern (Priority 2)

For each skill using inline execution:

1. Create new agent file in `.claude/agents/` with execution logic
2. Update skill to thin wrapper with `allowed-tools: Task`
3. Add `context: fork` and `agent:` fields to skill frontmatter
4. Add CRITICAL Task tool directive to skill

### Phase 4: Implement Anti-Stop Patterns (Priority 3)

In all agent files:

1. Replace `"completed"` with contextual status values
2. Add MUST NOT requirements about stop-triggering language
3. Update examples to show correct status values

### Phase 5: Update Documentation

1. Add tool directory mapping table to CLAUDE.md
2. Update skill-to-agent mapping table
3. Document fresh session requirement after changes

---

## All Relevant Artifact Links

### Task 480: Investigate Early Stop
- [Research](/home/benjamin/Projects/ProofChecker/specs/archive/480_investigate_workflow_delegation_early_stop/reports/research-001.md)
- [Plan](/home/benjamin/Projects/ProofChecker/specs/archive/480_investigate_workflow_delegation_early_stop/plans/implementation-001.md)
- [Summary](/home/benjamin/Projects/ProofChecker/specs/archive/480_investigate_workflow_delegation_early_stop/summaries/implementation-summary-20260113.md)

### Task 539: Test Model Tiering (Root Cause Discovery)
- [Research 002](/home/benjamin/Projects/ProofChecker/specs/archive/539_test_validate_model_tiering/reports/research-002.md)
- [Plan](/home/benjamin/Projects/ProofChecker/specs/archive/539_test_validate_model_tiering/plans/implementation-002.md)
- [Summary](/home/benjamin/Projects/ProofChecker/specs/archive/539_test_validate_model_tiering/summaries/implementation-summary-20260117.md)

### Task 541: Progressive Disclosure Refactor
- [Research](/home/benjamin/Projects/ProofChecker/specs/archive/541_progressive_disclosure_refactor/reports/research-001.md)
- [Plan](/home/benjamin/Projects/ProofChecker/specs/archive/541_progressive_disclosure_refactor/plans/implementation-001.md)

### Task 548: Fix Skill-to-Agent Delegation Pattern
- [Research 001](/home/benjamin/Projects/ProofChecker/specs/archive/548_fix_skill_to_agent_delegation_pattern/reports/research-001.md)
- [Research 002](/home/benjamin/Projects/ProofChecker/specs/archive/548_fix_skill_to_agent_delegation_pattern/reports/research-002.md)
- [Plan](/home/benjamin/Projects/ProofChecker/specs/archive/548_fix_skill_to_agent_delegation_pattern/plans/implementation-001.md)
- [Summary](/home/benjamin/Projects/ProofChecker/specs/archive/548_fix_skill_to_agent_delegation_pattern/summaries/implementation-summary-20260117.md)

### Task 555: Convert skill-status-sync to Forked Pattern
- [Research](/home/benjamin/Projects/ProofChecker/specs/archive/555_convert_skill_status_sync_to_forked_pattern/reports/research-001.md)
- [Plan](/home/benjamin/Projects/ProofChecker/specs/archive/555_convert_skill_status_sync_to_forked_pattern/plans/implementation-001.md)
- [Summary](/home/benjamin/Projects/ProofChecker/specs/archive/555_convert_skill_status_sync_to_forked_pattern/summaries/implementation-summary-20260117.md)

---

## Recommendations

### For protocol/.claude/ Migration

1. **Start with Task 548 fixes** - Add CRITICAL Task tool directives to all forked skills first; this is the most impactful fix

2. **Audit inline skills** - Identify any skills using inline execution (`allowed-tools` with Read, Write, Edit, Bash) and consider converting to forked pattern

3. **Update anti-stop patterns** - Ensure no agent returns `"status": "completed"`; use contextual values

4. **Fresh sessions required** - After applying fixes, users must start fresh Claude Code sessions to load new context

5. **Test incrementally** - Apply fixes to one skill at a time and test workflows

### Critical Success Factors

- **Be explicit**: Prose instructions like "use Task tool" are not actionable enough; use CRITICAL directives with exact parameters
- **Fresh sessions**: Old sessions cache skill definitions; always restart after changes
- **Avoid stop triggers**: Never use "completed", "finished", "done" in agent returns

## Next Steps

1. Copy this report to `/home/benjamin/Projects/protocol/specs/`
2. Create migration task in protocol's TODO.md
3. Apply fixes phase by phase following the checklist
4. Test each workflow command after changes
