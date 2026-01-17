# Implementation Plan: Task #564 (Revised v003)

- **Task**: 564 - Memory Issues with Status-Sync-Agent Architecture
- **Version**: 003
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Priority**: Critical
- **Dependencies**: None
- **Research Inputs**: specs/564_memory_issues_status_sync_agent/reports/research-001.md
- **Previous Plan**: implementation-002.md
- **Revision Reason**: Expand Phase 2 to comprehensively update all 17 files referencing status-sync-agent to prevent future recurrence
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Convert skill-status-sync from a **forked** skill (spawning status-sync-agent subagent) to a **direct execution** skill, then **comprehensively remove** all status-sync-agent references from the entire `.claude/` directory to prevent future issues.

### Revision Summary

**v001**: Inline status logic into commands, deprecate skill-status-sync
**v002**: Keep skill-status-sync, convert to direct execution, remove status-sync-agent (minimal cleanup)
**v003**: Same as v002, but with comprehensive documentation cleanup across all 17 affected files

### Files with References (from grep)

```
.claude/CLAUDE.md
.claude/agents/status-sync-agent.md                    # DELETE
.claude/skills/skill-status-sync/SKILL.md              # REWRITE (Phase 1)
.claude/commands/research.md                           # Update reference
.claude/commands/implement.md                          # Update reference
.claude/commands/plan.md                               # Update reference
.claude/commands/revise.md                             # Update reference
.claude/context/index.md                               # Update reference
.claude/context/core/patterns/inline-status-update.md  # Update/consolidate
.claude/context/core/patterns/skill-lifecycle.md       # Update reference
.claude/context/core/templates/command-template.md     # Update reference
.claude/context/core/checkpoints/checkpoint-gate-in.md # Update reference
.claude/context/core/checkpoints/checkpoint-gate-out.md # Update reference
.claude/context/core/orchestration/state-lookup.md     # Update reference
.claude/context/core/patterns/anti-stop-patterns.md    # Update reference
.claude/docs/guides/component-selection.md             # Update reference
.claude/docs/README.md                                 # Update reference
```

## Goals & Non-Goals

**Goals**:
- Eliminate memory exhaustion during command execution
- Preserve skill-status-sync as the interface for status updates
- Comprehensively remove status-sync-agent from all documentation
- Prevent future recurrence by updating patterns and templates

**Non-Goals**:
- Modifying command execution logic (only references)
- Creating entirely new documentation structure

## Implementation Phases

### Phase 1: Convert skill-status-sync to Direct Execution [COMPLETED]

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

### Phase 2: Delete status-sync-agent and Update Core Docs [COMPLETED]

**Goal**: Remove status-sync-agent and update primary documentation

**Tasks**:
- [ ] Delete `.claude/agents/status-sync-agent.md`
- [ ] Update `.claude/CLAUDE.md`:
  - Remove status-sync-agent from skill-to-agent mapping table
  - Update any workflow descriptions mentioning the agent
  - Note that skill-status-sync now uses direct execution
- [ ] Update `.claude/context/index.md` to remove status-sync-agent references
- [ ] Update `.claude/docs/README.md` to reflect architecture change
- [ ] Update `.claude/docs/guides/component-selection.md` to reflect direct execution pattern

**Timing**: 30 minutes

**Files to modify**:
- `.claude/agents/status-sync-agent.md` - **DELETE**
- `.claude/CLAUDE.md` - Update skill-to-agent mapping
- `.claude/context/index.md` - Remove agent reference
- `.claude/docs/README.md` - Update if needed
- `.claude/docs/guides/component-selection.md` - Update if needed

**Verification**:
- `status-sync-agent.md` no longer exists
- CLAUDE.md skill-to-agent table has no status-sync-agent entry
- No broken references in index.md

---

### Phase 3: Update Command References [COMPLETED]

**Goal**: Update command files to reflect that skill-status-sync is now direct execution (no functional changes, just comment/documentation updates)

**Tasks**:
- [ ] Update `.claude/commands/research.md` - Remove any subagent-specific comments
- [ ] Update `.claude/commands/plan.md` - Remove any subagent-specific comments
- [ ] Update `.claude/commands/implement.md` - Remove any subagent-specific comments
- [ ] Update `.claude/commands/revise.md` - Remove any subagent-specific comments

**Timing**: 15 minutes

**Files to modify**:
- `.claude/commands/research.md`
- `.claude/commands/plan.md`
- `.claude/commands/implement.md`
- `.claude/commands/revise.md`

**Note**: Commands still invoke `skill-status-sync` the same way - only internal comments or documentation references change.

**Verification**:
- Commands still reference skill-status-sync (not status-sync-agent)
- No mentions of "subagent" or "forked" pattern for status sync

---

### Phase 4: Update Context and Pattern Files [IN PROGRESS]

**Goal**: Update patterns, templates, and checkpoint files to reflect the direct execution model

**Tasks**:
- [ ] Update `.claude/context/core/patterns/inline-status-update.md` - Consolidate with new skill pattern
- [ ] Update `.claude/context/core/patterns/skill-lifecycle.md` - Note direct execution variant
- [ ] Update `.claude/context/core/patterns/anti-stop-patterns.md` - Remove any status-sync-agent examples
- [ ] Update `.claude/context/core/templates/command-template.md` - Update skill invocation guidance
- [ ] Update `.claude/context/core/checkpoints/checkpoint-gate-in.md` - Update skill reference
- [ ] Update `.claude/context/core/checkpoints/checkpoint-gate-out.md` - Update skill reference
- [ ] Update `.claude/context/core/orchestration/state-lookup.md` - Update any agent references

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/core/patterns/inline-status-update.md`
- `.claude/context/core/patterns/skill-lifecycle.md`
- `.claude/context/core/patterns/anti-stop-patterns.md`
- `.claude/context/core/templates/command-template.md`
- `.claude/context/core/checkpoints/checkpoint-gate-in.md`
- `.claude/context/core/checkpoints/checkpoint-gate-out.md`
- `.claude/context/core/orchestration/state-lookup.md`

**Verification**:
- No references to status-sync-agent in any pattern/template files
- Direct execution pattern documented where relevant

---

### Phase 5: Final Verification and Integration Test [NOT STARTED]

**Goal**: Verify complete removal and test functionality

**Tasks**:
- [ ] Run `grep -r "status-sync-agent" .claude/` - must return empty
- [ ] Run `/research` on a test task
- [ ] Run `/plan` on the same task
- [ ] Verify no memory issues
- [ ] Verify state.json and TODO.md synchronized

**Timing**: 15 minutes

**Files to modify**:
- None (testing only)

**Verification**:
- `grep -r "status-sync-agent" .claude/` returns nothing
- Complete command sequence without memory crashes
- All status transitions correct
- All artifacts properly linked

## Testing & Validation

- [ ] skill-status-sync preflight_update works: status changes in both files
- [ ] skill-status-sync postflight_update works: status changes + artifacts linked
- [ ] skill-status-sync artifact_link works: single artifact added idempotently
- [ ] No memory issues during multi-command sequences
- [ ] Commands (/research, /plan, /implement) still work unchanged
- [ ] Zero grep matches for "status-sync-agent" in .claude/

## Artifacts & Outputs

**Deleted**:
- `.claude/agents/status-sync-agent.md`

**Modified**:
- `.claude/skills/skill-status-sync/SKILL.md` - Rewritten to direct execution
- `.claude/CLAUDE.md` - Updated documentation
- `.claude/context/index.md`
- `.claude/commands/{research,plan,implement,revise}.md`
- `.claude/context/core/patterns/*.md` (3 files)
- `.claude/context/core/templates/command-template.md`
- `.claude/context/core/checkpoints/*.md` (2 files)
- `.claude/context/core/orchestration/state-lookup.md`
- `.claude/docs/README.md`
- `.claude/docs/guides/component-selection.md`

**Created**:
- `specs/564_memory_issues_status_sync_agent/summaries/implementation-summary-YYYYMMDD.md`

## Comparison with Previous Plans

| Aspect | v001 | v002 | v003 |
|--------|------|------|------|
| Phases | 7 | 3 | 5 |
| Files modified | 8+ | 3 | 17 |
| skill-status-sync | Deprecated | Converted | Converted |
| status-sync-agent | Deprecated | Deleted | Deleted + refs removed |
| Documentation cleanup | Partial | Minimal | Comprehensive |
| Future-proofing | Low | Medium | High |

## Rollback/Contingency

If direct execution causes issues:

1. Restore skill-status-sync from git history
2. Restore status-sync-agent from git history
3. Revert documentation changes with `git checkout`
4. Consider v001 approach (inline in commands) as fallback
