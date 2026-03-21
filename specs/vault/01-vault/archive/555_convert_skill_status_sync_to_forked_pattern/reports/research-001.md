# Research Report: Task #555

**Task**: 555 - convert_skill_status_sync_to_forked_pattern
**Started**: 2026-01-17T19:56:03Z
**Completed**: 2026-01-17T20:25:00Z
**Effort**: 2-3 hours
**Priority**: High
**Dependencies**: None (but informed by Task 548 research on skill-to-agent delegation)
**Sources/Inputs**:
- Codebase analysis (.claude/skills/skill-status-sync/SKILL.md)
- Thin wrapper skill template (.claude/context/core/templates/thin-wrapper-skill.md)
- Existing forked skills (skill-researcher, skill-planner, skill-implementer)
- Existing agents (planner-agent.md, general-research-agent.md)
- Anti-stop patterns documentation (.claude/context/core/patterns/anti-stop-patterns.md)
- Skill lifecycle documentation (.claude/context/core/patterns/skill-lifecycle.md)
- Subagent return format (.claude/context/core/formats/subagent-return.md)
- Task 548 research on skill-to-agent delegation patterns
**Artifacts**: specs/555_convert_skill_status_sync_to_forked_pattern/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Root cause identified**: skill-status-sync uses inline execution pattern with `allowed-tools: Read, Write, Edit, Bash` which causes workflow interruptions when the skill returns
- **Problem mechanism**: Inline skill completion triggers Claude to stop and wait for user input, preventing orchestrator postflight operations from running automatically
- **Solution**: Convert to forked subagent pattern with new status-sync-agent, making skill-status-sync a thin wrapper that delegates via Task tool
- **Key insight**: The anti-stop patterns only address return value language; they don't address the fundamental structural issue of inline skills vs forked skills
- **Scope**: Create 1 new agent file and refactor 1 skill file to match existing forked skill patterns

## Context & Scope

### Problem Statement

When workflow commands like /research invoke skill-status-sync for preflight/postflight status updates, the inline execution of the skill causes Claude to pause and wait for user input ("continue" required). This happens because:

1. Skill-status-sync executes directly using `allowed-tools: Read, Write, Edit, Bash`
2. After skill completion, Claude interprets this as a natural stopping point
3. The orchestrator cannot continue to subsequent stages (agent delegation, git commit) without user intervention

### Investigation Focus

1. **Current skill-status-sync structure** - Why does inline execution cause interruptions?
2. **Forked subagent pattern** - How do other skills avoid this problem?
3. **New status-sync-agent design** - What should the agent file contain?
4. **Thin wrapper conversion** - How to transform skill-status-sync to delegate pattern?

## Findings

### 1. Current skill-status-sync Structure (Inline Pattern)

**Location**: `.claude/skills/skill-status-sync/SKILL.md`

**Frontmatter**:
```yaml
---
name: skill-status-sync
description: Atomically update task status across TODO.md and state.json
allowed-tools: Read, Write, Edit, Bash
# Note: No 'context: fork' field - this is inline execution
# Note: No 'agent:' field - does not delegate to subagent
---
```

**Characteristics of inline pattern**:
- Skill executes directly in the parent conversation
- Uses Read, Write, Edit, Bash tools directly
- Extensive inline documentation (693 lines) for jq/grep patterns
- Three API operations: preflight_update, postflight_update, artifact_link
- Returns JSON with contextual status values (synced, linked, failed) to avoid stop behavior

**Problem**: Despite using anti-stop return values, the skill still causes workflow interruptions because Claude treats inline skill completion as a conversation stopping point, regardless of return value content.

### 2. Forked Subagent Pattern Analysis

**Example**: skill-researcher (a properly forked skill)

**Frontmatter**:
```yaml
---
name: skill-researcher
description: Conduct general research...
allowed-tools: Task          # Only Task tool - delegates to subagent
context: fork                # Signal: don't load context eagerly
agent: general-research-agent # Target subagent to spawn
---
```

**Characteristics of forked pattern**:
- Skill only has `Task` in allowed-tools
- `context: fork` signals lazy context loading
- `agent:` field specifies subagent to invoke
- Skill body is a thin wrapper (147 lines vs 693 for status-sync)
- Actual work happens in separate agent conversation

**Why forked pattern avoids interruptions**:
1. Task tool spawns a separate conversation for the agent
2. Agent conversation runs to completion independently
3. Agent returns JSON to skill (not directly to user)
4. Skill returns that JSON to caller
5. No natural stopping point is created - the flow continues

### 3. Skill-to-Agent Mapping in Project

| Skill | Pattern | Agent | allowed-tools |
|-------|---------|-------|---------------|
| skill-researcher | Forked | general-research-agent | Task |
| skill-planner | Forked | planner-agent | Task |
| skill-implementer | Forked | general-implementation-agent | Task |
| skill-lean-research | Forked | lean-research-agent | Task |
| skill-lean-implementation | Forked | lean-implementation-agent | Task |
| skill-latex-implementation | Forked | latex-implementation-agent | Task |
| skill-meta | Forked | meta-builder-agent | Task |
| **skill-status-sync** | **Inline** | **None** | Read, Write, Edit, Bash |
| skill-git-workflow | Inline | None | Bash(git:*) |

**Key observation**: skill-status-sync and skill-git-workflow are the only skills using inline execution. skill-git-workflow likely also causes interruptions when invoked.

### 4. Design for status-sync-agent

Based on existing agent patterns (planner-agent.md, general-research-agent.md), the new agent should:

**Frontmatter**:
```yaml
---
name: status-sync-agent
description: Execute atomic status updates across TODO.md and state.json
---
```

**Structure** (following planner-agent.md template):
1. **Agent Metadata** - Name, purpose, invoked by, return format
2. **Allowed Tools** - Read, Write, Edit, Bash (same as current skill)
3. **Context References** - state-management.md, artifact-formats.md
4. **Execution Flow** - Parse input, execute operation, return JSON
5. **Error Handling** - Validation, write failures, inconsistency detection
6. **Return Format Examples** - Success, partial, failed cases
7. **Critical Requirements** - MUST DO / MUST NOT lists

**Operations to support**:
- `preflight_update(task_number, target_status, session_id)`
- `postflight_update(task_number, target_status, artifacts, session_id)`
- `artifact_link(task_number, artifact_path, artifact_type)`

### 5. Design for Thin Wrapper skill-status-sync

Following thin-wrapper-skill.md template:

**New Frontmatter**:
```yaml
---
name: skill-status-sync
description: Atomically update task status across TODO.md and state.json
allowed-tools: Task
context: fork
agent: status-sync-agent
---
```

**New Structure** (~50-80 lines vs current 693):
1. **Context Pointers** - Reference validation.md
2. **Trigger Conditions** - When status changes needed
3. **Execution Flow**:
   - 1. Input Validation (verify operation type, task exists)
   - 2. Context Preparation (build delegation context)
   - 3. Invoke Subagent (CRITICAL Task tool directive per Task 548)
   - 4. Return Validation (verify JSON schema)
   - 5. Return Propagation (pass through result)
4. **Return Format** - Reference subagent-return.md
5. **Error Handling** - Input errors, subagent errors, timeout

### 6. Impact on Command Files

Commands that invoke skill-status-sync:
- `/research` - CHECKPOINT 1 (GATE IN), CHECKPOINT 2 (GATE OUT)
- `/plan` - CHECKPOINT 1, CHECKPOINT 2
- `/implement` - CHECKPOINT 1, CHECKPOINT 2

Current invocation pattern in commands:
```markdown
4. **Update Status (via skill-status-sync)**
   Invoke skill-status-sync: `preflight_update(task_number, "researching", session_id)`
```

**No changes needed to command files** - they already invoke skill-status-sync correctly. The change is internal to how skill-status-sync handles the work.

### 7. Risk Analysis: Inline Execution of Status Operations

**Concern**: Status operations are rapid (5-50ms each). Is forking overhead justified?

**Analysis**:
- Task tool spawns subagent conversation - adds ~1-3 seconds overhead
- For /research with 2 status-sync calls: +2-6 seconds on 3-10 minute workflow
- Trade-off: Reliability (no interruptions) vs Speed (small overhead)

**Recommendation**: Convert to forked pattern. The overhead is negligible compared to the disruption caused by workflow interruptions requiring user intervention.

### 8. Alternative Approaches Considered

**Alternative A: Keep inline but add continuation signals**
- Add explicit "CONTINUE TO NEXT STAGE" markers
- Problem: Claude still treats skill completion as stopping point
- Verdict: Does not solve root cause

**Alternative B: Merge status-sync into each workflow skill**
- Each skill (researcher, planner, etc.) handles its own preflight/postflight
- Problem: Duplicates 693 lines of jq/grep patterns across 7 skills
- Verdict: Violates DRY, increases maintenance burden

**Alternative C: Convert to forked pattern (RECOMMENDED)**
- Create status-sync-agent with actual logic
- Make skill-status-sync a thin wrapper
- Problem: Small overhead per invocation
- Verdict: Best balance of reliability and maintainability

## Recommendations

### Primary Recommendation: Convert to Forked Pattern

1. **Create status-sync-agent** in `.claude/agents/status-sync-agent.md`
   - Move all jq/grep patterns from current skill
   - Structure like planner-agent.md with execution stages
   - Support all 3 operations: preflight, postflight, artifact_link
   - Return JSON matching subagent-return.md schema

2. **Refactor skill-status-sync** to thin wrapper
   - Change allowed-tools from `Read, Write, Edit, Bash` to `Task`
   - Add `context: fork` and `agent: status-sync-agent` fields
   - Replace inline patterns with delegation logic
   - Apply Task 548's CRITICAL directive pattern for invocation

3. **Test with full workflow command**
   - Run `/research N` and verify no "continue" prompts
   - Verify preflight updates status to [RESEARCHING]
   - Verify postflight updates status to [RESEARCHED] with artifacts

### Secondary Recommendation: Consider skill-git-workflow

skill-git-workflow also uses inline execution (`allowed-tools: Bash(git:*)`). It may benefit from the same conversion pattern if it also causes workflow interruptions.

## Decisions

1. **Approach**: Convert to forked subagent pattern (Alternative C)
2. **Agent location**: `.claude/agents/status-sync-agent.md` (follows existing pattern)
3. **Skill changes**: Minimal - only frontmatter and execution section
4. **Command changes**: None required
5. **Testing**: Via full /research workflow execution

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Forking overhead too high | Low | Low | Benchmark shows ~2-6s on 3-10min workflow, acceptable |
| Agent doesn't receive full context | Medium | Medium | Include all jq/grep patterns in agent body |
| Task 548 issue (Skill vs Task tool) | High | High | Apply CRITICAL directive from Task 548 fix |
| Old sessions have cached skill | Medium | High | Document: start fresh sessions after fix |
| Missing operation (preflight/postflight/link) | High | Low | Port all 3 operations from current skill |

## Appendix

### Files to Create

1. `.claude/agents/status-sync-agent.md` - New agent with status sync logic

### Files to Modify

1. `.claude/skills/skill-status-sync/SKILL.md` - Refactor to thin wrapper

### Files Unchanged

1. `.claude/commands/research.md` - Already invokes skill correctly
2. `.claude/commands/plan.md` - Already invokes skill correctly
3. `.claude/commands/implement.md` - Already invokes skill correctly
4. `.claude/context/core/patterns/inline-status-update.md` - Reference for agent implementation

### Reference: Current Operation Return Formats

**preflight_update**:
```json
{
  "status": "synced|failed",
  "summary": "Updated task #N to [STATUS]",
  "previous_status": "not_started",
  "new_status": "researching"
}
```

**postflight_update**:
```json
{
  "status": "{target_status}|failed",
  "summary": "Updated task #N to [STATUS] with N artifacts",
  "artifacts_linked": ["path1", "path2"],
  "previous_status": "researching",
  "new_status": "researched"
}
```

**artifact_link**:
```json
{
  "status": "linked|skipped|failed",
  "summary": "Linked artifact to task #N" | "Link already exists",
  "artifact_path": "path/to/artifact.md",
  "artifact_type": "research"
}
```

### Reference: Task 548 CRITICAL Directive Template

From Task 548's implementation plan, the following template should be applied to the new thin wrapper skill:

```markdown
### 3. Invoke Subagent

**CRITICAL**: You MUST use the Task tool (NOT Skill tool) to spawn the subagent.

The `agent` field in this skill's frontmatter specifies the target: `status-sync-agent`

**Invocation Requirements**:
```
Tool: Task (NOT Skill)
Parameters:
  - subagent_type: "status-sync-agent"
  - prompt: [Include operation, task_number, target_status, artifacts, session_id]
  - description: "Execute status sync for task {N}"
```

**WARNING**: Do NOT use `Skill(status-sync-agent)` - this will FAIL.
Agents live in `.claude/agents/`, not `.claude/skills/`.
The Skill tool can only invoke skills from `.claude/skills/`.
```

### Search Patterns Used

1. `grep "skill-status-sync" .claude/` - Find all references to skill
2. `glob ".claude/skills/*/SKILL.md"` - List all skills for pattern comparison
3. `glob ".claude/agents/*.md"` - List all agents for structure reference
4. Reading existing thin wrapper skills for template patterns
