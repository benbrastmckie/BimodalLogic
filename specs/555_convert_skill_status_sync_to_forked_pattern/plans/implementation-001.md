# Implementation Plan: Task #555

- **Task**: 555 - convert_skill_status_sync_to_forked_pattern
- **Status**: [NOT STARTED]
- **Effort**: 2-3 hours
- **Priority**: High
- **Dependencies**: None (informed by Task 548 research on skill-to-agent delegation)
- **Research Inputs**: specs/555_convert_skill_status_sync_to_forked_pattern/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Convert skill-status-sync from inline execution pattern to forked subagent pattern to fix workflow interruptions. Currently, skill-status-sync uses `allowed-tools: Read, Write, Edit, Bash` which causes Claude to pause for user input after skill completion, preventing orchestrator postflight operations from running automatically. The fix creates a new status-sync-agent containing the status sync logic and converts skill-status-sync into a thin wrapper that delegates via the Task tool.

### Research Integration

Research report (research-001.md) identified:
- Root cause: Inline skill completion triggers Claude stop behavior
- Solution: Forked subagent pattern (same as skill-researcher, skill-planner, etc.)
- Task 548 provides the CRITICAL directive template for Task tool invocation
- Three operations to port: preflight_update, postflight_update, artifact_link
- No changes needed to command files (already invoke skill correctly)

## Goals & Non-Goals

**Goals**:
- Create status-sync-agent with all three API operations (preflight_update, postflight_update, artifact_link)
- Convert skill-status-sync to thin wrapper pattern with `allowed-tools: Task`
- Ensure workflow commands (/research, /plan, /implement) no longer require "continue" prompts after status updates
- Apply Task 548's CRITICAL directive pattern to prevent Skill vs Task tool confusion

**Non-Goals**:
- Converting skill-git-workflow to forked pattern (separate task)
- Optimizing jq/grep patterns (preserve existing logic)
- Adding new operations to status-sync API

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Forking overhead too high | Low | Low | Research shows ~2-6s on 3-10min workflow, acceptable |
| Agent doesn't receive full context | Medium | Medium | Include all jq/grep patterns from current skill |
| Task 548 issue (Skill vs Task tool) | High | High | Apply CRITICAL directive from Task 548 fix |
| Old sessions have cached skill | Medium | High | Document: start fresh sessions after fix |
| Missing operation during port | High | Low | Port all 3 operations, verify against current skill |

## Implementation Phases

### Phase 1: Create status-sync-agent [NOT STARTED]

**Goal**: Create the new agent file with all status sync logic ported from current skill

**Tasks**:
- [ ] Create `.claude/agents/status-sync-agent.md` with YAML frontmatter
- [ ] Add Agent Metadata section (name, purpose, invoked by, return format)
- [ ] Add Allowed Tools section (Read, Write, Edit, Bash)
- [ ] Add Context References section (state-management.md, artifact-formats.md)
- [ ] Port Execution Flow with 3 stages: Parse Input, Execute Operation, Return JSON
- [ ] Port all lookup patterns (task lookup, field extraction, status validation)
- [ ] Port all update patterns (status update, artifact addition, TODO.md linking)
- [ ] Port two-phase commit pattern (prepare, commit, verify)
- [ ] Add Error Handling section with all error cases
- [ ] Add Return Format Examples section (preflight, postflight, artifact_link success/failure)
- [ ] Add Critical Requirements (MUST DO / MUST NOT lists)
- [ ] Ensure anti-stop pattern: return "synced", "linked", etc., never "completed"

**Timing**: 1.5 hours

**Files to create**:
- `.claude/agents/status-sync-agent.md` - New agent file (~500-600 lines)

**Verification**:
- Agent file exists with correct frontmatter
- All 3 operations documented with input/execution/output
- Return format matches subagent-return.md schema
- Anti-stop patterns applied (no "completed" in return values)

---

### Phase 2: Convert skill-status-sync to thin wrapper [NOT STARTED]

**Goal**: Transform skill-status-sync from inline execution to delegation pattern

**Tasks**:
- [ ] Update frontmatter: change `allowed-tools` from `Read, Write, Edit, Bash` to `Task`
- [ ] Add `context: fork` field to frontmatter
- [ ] Add `agent: status-sync-agent` field to frontmatter
- [ ] Replace inline documentation with thin wrapper structure
- [ ] Add Context Pointers section (reference validation.md)
- [ ] Add Trigger Conditions section (when status changes needed)
- [ ] Add Execution section with 5-step flow:
  - 1. Input Validation (verify operation type, task exists)
  - 2. Context Preparation (build delegation context with session_id)
  - 3. Invoke Subagent (CRITICAL Task tool directive from Task 548)
  - 4. Return Validation (verify JSON schema)
  - 5. Return Propagation (pass through result)
- [ ] Add Return Format section (reference subagent-return.md)
- [ ] Add Error Handling section (input errors, subagent errors, timeout)
- [ ] Apply CRITICAL directive: "You MUST use the Task tool (NOT Skill tool)"

**Timing**: 45 minutes

**Files to modify**:
- `.claude/skills/skill-status-sync/SKILL.md` - Refactor to ~80-100 lines

**Verification**:
- Frontmatter has `allowed-tools: Task`, `context: fork`, `agent: status-sync-agent`
- CRITICAL directive present in Invoke Subagent section
- File is significantly smaller (~100 lines vs original 693)

---

### Phase 3: Update documentation and verify consistency [NOT STARTED]

**Goal**: Update CLAUDE.md skill-to-agent mapping and verify integration

**Tasks**:
- [ ] Update CLAUDE.md skill-to-agent mapping table to include status-sync-agent
- [ ] Verify skill-status-sync appears correctly in skill listing
- [ ] Check that no command files need modification (they invoke skill-status-sync, not the agent directly)
- [ ] Verify agent frontmatter will be recognized by Claude Code (requires session restart)

**Timing**: 15 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - Add status-sync-agent to mapping table

**Verification**:
- Skill-to-agent mapping table includes new entry
- No broken references in command files

---

### Phase 4: Testing and validation [NOT STARTED]

**Goal**: Verify the conversion works correctly through workflow execution

**Tasks**:
- [ ] Start fresh Claude Code session (required for agent registration)
- [ ] Test preflight_update via `/research N` command (observe status change to [RESEARCHING])
- [ ] Verify no "continue" prompt after preflight status update
- [ ] Verify postflight status update works (status changes to [RESEARCHED])
- [ ] Verify artifact linking works (research report linked in TODO.md)
- [ ] Verify git commit stage executes without user intervention
- [ ] Document any issues found

**Timing**: 30 minutes

**Files to modify**:
- None (testing only)

**Verification**:
- Full /research workflow completes without "continue" prompts
- Status updates reflected in both TODO.md and state.json
- Artifacts linked correctly
- Git commit executes automatically

## Testing & Validation

- [ ] Agent file has correct YAML frontmatter (name, description fields)
- [ ] Skill file has correct frontmatter (allowed-tools: Task, context: fork, agent: status-sync-agent)
- [ ] preflight_update returns `{"status": "synced", ...}`
- [ ] postflight_update returns `{"status": "{target_status}", ...}`
- [ ] artifact_link returns `{"status": "linked", ...}` or `{"status": "skipped", ...}`
- [ ] No "completed" string appears in any return value
- [ ] Full /research workflow runs without user intervention
- [ ] CLAUDE.md skill-to-agent table is updated

## Artifacts & Outputs

- `.claude/agents/status-sync-agent.md` - New agent file
- `.claude/skills/skill-status-sync/SKILL.md` - Refactored thin wrapper
- `.claude/CLAUDE.md` - Updated skill-to-agent mapping
- `specs/555_convert_skill_status_sync_to_forked_pattern/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If the conversion causes issues:
1. Restore original skill-status-sync from git: `git checkout HEAD~1 -- .claude/skills/skill-status-sync/SKILL.md`
2. Delete the new agent file: `rm .claude/agents/status-sync-agent.md`
3. Revert CLAUDE.md changes: `git checkout HEAD~1 -- .claude/CLAUDE.md`
4. Start fresh session to clear cached skill definitions

The original inline pattern is functional (just causes interruptions), so rollback restores working state while investigation continues.
