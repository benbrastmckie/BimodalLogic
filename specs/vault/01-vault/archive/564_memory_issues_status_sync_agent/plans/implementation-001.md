# Implementation Plan: Task #564

- **Task**: 564 - Memory Issues with Status-Sync-Agent Architecture
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Priority**: Critical
- **Dependencies**: None
- **Research Inputs**: specs/564_memory_issues_status_sync_agent/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Remove the subagent delegation pattern for status-sync operations and inline status update logic directly into command files. The research identified that skill-status-sync is called twice per command (preflight + postflight), unlike other skills called once, causing memory accumulation that exhausts the JavaScript V8 heap (~4GB limit). The solution eliminates delegation overhead for trivial 50ms operations.

### Research Integration

Key findings from research-001.md:
- Three documented crashes all during skill-status-sync invocation
- Each Task tool invocation adds to parent memory footprint with no garbage collection opportunity
- Status updates are simple jq + Edit operations that don't warrant full agent spawning
- Option A (inline status updates) recommended as simplest and most effective fix

## Goals & Non-Goals

**Goals**:
- Eliminate memory exhaustion during command execution
- Preserve atomic status updates across TODO.md and state.json
- Maintain session tracking capabilities
- Keep artifact linking functionality in postflight operations

**Non-Goals**:
- Modifying Claude Code's memory limits (not possible)
- Preserving the skill-status-sync / status-sync-agent delegation pattern
- Supporting status-sync as a standalone user-facing command

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Code duplication across commands | Medium | High | Create documented standard patterns for status updates |
| Inconsistent status update logic | High | Medium | Use consistent jq queries and Edit patterns |
| TODO.md/state.json desync | High | Low | Always update state.json first, verify both writes |
| Loss of centralized error handling | Medium | Medium | Each command handles its own status errors |
| Regression in artifact linking | High | Low | Verify postflight operations in testing |

## Implementation Phases

### Phase 1: Create Status Update Patterns Documentation [NOT STARTED]

**Goal**: Document reusable patterns for inline status updates that commands will use

**Tasks**:
- [ ] Create `.claude/context/core/patterns/status-update-patterns.md` with preflight and postflight jq templates
- [ ] Document state.json update patterns (jq commands)
- [ ] Document TODO.md update patterns (Edit tool usage)
- [ ] Include artifact linking patterns for postflight
- [ ] Add error handling patterns for failed writes

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/core/patterns/status-update-patterns.md` (create)

**Verification**:
- Pattern document exists with complete templates
- jq commands tested manually on sample state.json

---

### Phase 2: Update /research Command [NOT STARTED]

**Goal**: Replace skill-status-sync calls with inline status updates in research.md

**Tasks**:
- [ ] Read current `.claude/commands/research.md` structure
- [ ] Replace preflight skill-status-sync call with inline jq + Edit
- [ ] Replace postflight skill-status-sync call with inline jq + Edit + artifact link
- [ ] Update command to use session_id directly without delegation
- [ ] Remove skill-status-sync invocation references

**Timing**: 30 minutes

**Files to modify**:
- `.claude/commands/research.md` - inline preflight and postflight status updates

**Verification**:
- Run `/research` on a test task
- Verify no memory issues during execution
- Verify status transitions correctly in both TODO.md and state.json
- Verify research artifact is linked in state.json

---

### Phase 3: Update /plan Command [NOT STARTED]

**Goal**: Replace skill-status-sync calls with inline status updates in plan.md

**Tasks**:
- [ ] Read current `.claude/commands/plan.md` structure
- [ ] Replace preflight skill-status-sync call with inline jq + Edit
- [ ] Replace postflight skill-status-sync call with inline jq + Edit + artifact link
- [ ] Update command to use session_id directly without delegation
- [ ] Remove skill-status-sync invocation references

**Timing**: 30 minutes

**Files to modify**:
- `.claude/commands/plan.md` - inline preflight and postflight status updates

**Verification**:
- Run `/plan` on a test task
- Verify no memory issues during execution
- Verify status transitions correctly ([RESEARCHED] -> [PLANNING] -> [PLANNED])
- Verify plan artifact is linked in state.json

---

### Phase 4: Update /implement Command [NOT STARTED]

**Goal**: Replace skill-status-sync calls with inline status updates in implement.md

**Tasks**:
- [ ] Read current `.claude/commands/implement.md` structure
- [ ] Replace preflight skill-status-sync call with inline jq + Edit
- [ ] Replace postflight skill-status-sync call with inline jq + Edit + artifact link
- [ ] Handle phase-level status updates for multi-phase implementations
- [ ] Update command to use session_id directly without delegation
- [ ] Remove skill-status-sync invocation references

**Timing**: 30 minutes

**Files to modify**:
- `.claude/commands/implement.md` - inline preflight and postflight status updates

**Verification**:
- Run `/implement` on a test task
- Verify no memory issues during execution
- Verify status transitions correctly ([PLANNED] -> [IMPLEMENTING] -> [COMPLETED])
- Verify summary artifact is linked in state.json

---

### Phase 5: Update /revise Command [NOT STARTED]

**Goal**: Replace skill-status-sync calls with inline status updates in revise.md

**Tasks**:
- [ ] Read current `.claude/commands/revise.md` structure
- [ ] Replace postflight skill-status-sync call with inline jq + Edit + artifact link
- [ ] Update command to use session_id directly without delegation
- [ ] Remove skill-status-sync invocation references

**Timing**: 15 minutes

**Files to modify**:
- `.claude/commands/revise.md` - inline postflight status updates

**Verification**:
- Run `/revise` on a test task with existing plan
- Verify new plan version is created
- Verify artifact is linked in state.json

---

### Phase 6: Deprecate Status-Sync Infrastructure [NOT STARTED]

**Goal**: Mark status-sync-agent and skill-status-sync as deprecated, update documentation

**Tasks**:
- [ ] Add deprecation notice to `.claude/agents/status-sync-agent.md` header
- [ ] Add deprecation notice to `.claude/skills/skill-status-sync/SKILL.md` header
- [ ] Update `.claude/CLAUDE.md` skill-to-agent mapping table
- [ ] Update `.claude/ARCHITECTURE.md` if it references status-sync pattern
- [ ] Remove skill-status-sync from command workflow descriptions in CLAUDE.md

**Timing**: 30 minutes

**Files to modify**:
- `.claude/agents/status-sync-agent.md` - add deprecation notice
- `.claude/skills/skill-status-sync/SKILL.md` - add deprecation notice
- `.claude/CLAUDE.md` - update documentation
- `.claude/ARCHITECTURE.md` - update if needed

**Verification**:
- Deprecation notices visible in files
- Documentation reflects new inline pattern
- No references to skill-status-sync in workflow descriptions

---

### Phase 7: Multi-Command Integration Test [NOT STARTED]

**Goal**: Verify memory stability across multiple sequential commands

**Tasks**:
- [ ] Run `/research` on a task
- [ ] Run `/plan` on the same task
- [ ] Run `/implement` (at least first phase) on the same task
- [ ] Monitor for memory issues throughout sequence
- [ ] Verify state.json and TODO.md remain synchronized

**Timing**: 15 minutes

**Files to modify**:
- None (testing only)

**Verification**:
- Complete sequence without memory crashes
- All status transitions correct
- All artifacts properly linked
- state.json and TODO.md synchronized

## Testing & Validation

- [ ] Individual command tests: /research, /plan, /implement, /revise each work in isolation
- [ ] Sequential command test: multiple commands in single session without memory issues
- [ ] State synchronization: TODO.md and state.json stay consistent after each operation
- [ ] Artifact linking: Research reports, plans, and summaries properly linked in state.json
- [ ] Error handling: Graceful handling when state update fails

## Artifacts & Outputs

- `.claude/context/core/patterns/status-update-patterns.md` - New pattern documentation
- `.claude/commands/research.md` - Updated with inline status updates
- `.claude/commands/plan.md` - Updated with inline status updates
- `.claude/commands/implement.md` - Updated with inline status updates
- `.claude/commands/revise.md` - Updated with inline status updates
- `.claude/agents/status-sync-agent.md` - Deprecated
- `.claude/skills/skill-status-sync/SKILL.md` - Deprecated
- `.claude/CLAUDE.md` - Updated documentation
- `specs/564_memory_issues_status_sync_agent/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If inline status updates cause issues:

1. **Revert command files** to pre-change versions using git
2. **Remove deprecation notices** from status-sync-agent and skill-status-sync
3. **Investigate alternative approaches**:
   - Option B from research: Convert skill-status-sync to direct execution (non-forked)
   - Option C from research: Hybrid approach (inline preflight, skill postflight)

The deprecated files are kept (not deleted) specifically to enable easy rollback if needed.
