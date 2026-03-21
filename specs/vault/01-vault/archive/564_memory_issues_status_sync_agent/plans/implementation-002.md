# Implementation Plan: Task #564 (Revised)

- **Task**: 564 - Memory Issues with Status-Sync-Agent Architecture
- **Version**: 002
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Priority**: Critical
- **Dependencies**: None
- **Research Inputs**: specs/564_memory_issues_status_sync_agent/reports/research-001.md
- **Previous Plan**: implementation-001.md
- **Revision Reason**: Preserve skill-status-sync but convert from forked to direct execution pattern
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Convert skill-status-sync from a **forked** skill (spawning status-sync-agent subagent) to a **direct execution** skill that performs status updates inline. This preserves the centralized status update interface while eliminating the memory-exhausting subagent delegation pattern.

### Revision Summary

**Previous plan (v001)**: Inline status update logic directly into each command file, deprecating skill-status-sync entirely.

**Revised plan (v002)**: Keep skill-status-sync as the interface, but change its execution mode from `context: fork` to direct execution with `allowed-tools`.

### Key Change

**Before**:
```yaml
---
name: skill-status-sync
context: fork           # Spawns subagent (CAUSES MEMORY ISSUES)
agent: status-sync-agent
allowed-tools: Task
---
```

**After**:
```yaml
---
name: skill-status-sync
allowed-tools: Bash, Edit, Read
---
# Skill executes directly in parent context (NO SUBAGENT)
```

## Goals & Non-Goals

**Goals**:
- Eliminate memory exhaustion during command execution
- Preserve skill-status-sync as the interface for status updates
- Maintain atomic status updates across TODO.md and state.json
- Keep commands unchanged (they still invoke skill-status-sync)

**Non-Goals**:
- Modifying command files
- Creating new pattern documentation
- Supporting status-sync-agent for future use

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| SKILL.md grows too large | Low | Medium | Keep implementation concise with jq inline |
| Loss of agent context isolation | Low | Low | Status operations are simple, don't need isolation |
| Skill context loads into parent | Low | Low | Only ~200 lines, much smaller than full agent (~700 lines) |

## Implementation Phases

### Phase 1: Convert skill-status-sync to Direct Execution [NOT STARTED]

**Goal**: Transform skill-status-sync from forked (subagent) to direct execution pattern

**Tasks**:
- [ ] Rewrite `.claude/skills/skill-status-sync/SKILL.md` frontmatter to remove fork/agent fields
- [ ] Add `allowed-tools: Bash, Edit, Read` for direct execution
- [ ] Embed the status update logic directly in the skill (jq commands + Edit patterns)
- [ ] Preserve the same API operations (preflight_update, postflight_update, artifact_link)
- [ ] Maintain the same return format for callers

**Timing**: 45 minutes

**Files to modify**:
- `.claude/skills/skill-status-sync/SKILL.md` - Complete rewrite to direct execution

**Implementation Details**:

The skill will execute these operations directly:

**preflight_update**:
```bash
# Update state.json
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg status "{target_status}" \
  '(.active_projects[] | select(.project_number == {N})) |= . + {
    status: $status, last_updated: $ts
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```
Then Edit TODO.md to change `[OLD_STATUS]` to `[NEW_STATUS]`.

**postflight_update**:
Same as preflight, plus artifact linking via jq:
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --argjson arts '[{...}]' \
  '(.active_projects[] | select(.project_number == {N})) |= . + {
    status: $status, last_updated: $ts, artifacts: (.artifacts + $arts)
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

**Verification**:
- Skill file has no `context: fork` or `agent:` fields
- Skill has `allowed-tools: Bash, Edit, Read`
- Skill contains inline jq commands for state updates

---

### Phase 2: Remove status-sync-agent [NOT STARTED]

**Goal**: Remove the now-unused status-sync-agent

**Tasks**:
- [ ] Delete `.claude/agents/status-sync-agent.md`
- [ ] Update `.claude/CLAUDE.md` skill-to-agent mapping table (remove status-sync-agent entry)
- [ ] Remove any references to status-sync-agent in documentation

**Timing**: 15 minutes

**Files to modify**:
- `.claude/agents/status-sync-agent.md` - Delete
- `.claude/CLAUDE.md` - Update skill-to-agent mapping

**Verification**:
- `status-sync-agent.md` no longer exists
- CLAUDE.md no longer references status-sync-agent
- `grep -r "status-sync-agent" .claude/` returns nothing

---

### Phase 3: Integration Test [NOT STARTED]

**Goal**: Verify the converted skill works without memory issues

**Tasks**:
- [ ] Run `/research` on a test task (invokes skill-status-sync preflight + postflight)
- [ ] Verify status transitions correctly
- [ ] Run `/plan` on the same task
- [ ] Monitor for memory issues throughout
- [ ] Verify state.json and TODO.md remain synchronized

**Timing**: 15 minutes

**Files to modify**:
- None (testing only)

**Verification**:
- Complete `/research` and `/plan` sequence without memory crashes
- All status transitions correct
- All artifacts properly linked
- state.json and TODO.md synchronized

## Testing & Validation

- [ ] skill-status-sync preflight_update works: status changes in both files
- [ ] skill-status-sync postflight_update works: status changes + artifacts linked
- [ ] skill-status-sync artifact_link works: single artifact added idempotently
- [ ] No memory issues during multi-command sequences
- [ ] Commands (/research, /plan, /implement) still work unchanged

## Artifacts & Outputs

- `.claude/skills/skill-status-sync/SKILL.md` - Rewritten to direct execution
- `.claude/agents/status-sync-agent.md` - Deleted
- `.claude/CLAUDE.md` - Updated documentation
- `specs/564_memory_issues_status_sync_agent/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Comparison with Previous Plan

| Aspect | v001 (Previous) | v002 (Revised) |
|--------|-----------------|----------------|
| Phases | 7 | 3 |
| Files modified | 8+ | 3 |
| Commands modified | 4 (research, plan, implement, revise) | 0 |
| skill-status-sync | Deprecated | Preserved (converted) |
| status-sync-agent | Deprecated | Deleted |
| Complexity | Higher (spread changes) | Lower (focused change) |
| Interface change | Yes (commands do inline) | No (commands unchanged) |

## Rollback/Contingency

If direct execution causes issues:

1. Restore skill-status-sync from git history
2. Restore status-sync-agent from git history
3. Consider v001 approach (inline in commands) as fallback
