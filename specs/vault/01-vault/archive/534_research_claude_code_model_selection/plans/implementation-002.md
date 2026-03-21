# Implementation Plan: Task #534 (Revised v002)

- **Task**: 534 - research_claude_code_model_selection
- **Version**: 002
- **Status**: [NOT STARTED]
- **Effort**: 1 hour (porting documentation, no implementation)
- **Priority**: High
- **Dependencies**: Task 564 completed (status-sync-agent removal)
- **Research Inputs**: specs/534_research_claude_code_model_selection/reports/research-001.md
- **Previous Plan**: implementation-001.md
- **Revision Reason**: Incorporate Task 564 architectural changes (status-sync-agent → direct execution) for porting to protocol/.claude/ system
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This revision expands Task 534 from a pure research task into a documentation task that captures both:
1. **Model selection findings** (from original research-001.md)
2. **Architectural changes from Task 564** (status-sync-agent → direct execution pattern)

These changes need to be documented for porting to the `protocol/.claude/` agent system.

### Revision Summary

**v001**: Research-only task, documented model selection mechanism, created follow-up tasks 535-539
**v002**: Add documentation of Task 564 changes for `protocol/.claude/` porting reference

## Changes to Port from Task 564

Task 564 addressed a critical memory exhaustion issue by converting the `skill-status-sync` from a **forked skill** (spawning status-sync-agent subagent) to a **direct execution skill**.

### Key Architectural Changes

| Component | Before (Forked) | After (Direct Execution) |
|-----------|-----------------|--------------------------|
| `skill-status-sync` | `context: fork`, `agent: status-sync-agent` | `allowed-tools: Bash, Edit, Read` |
| `status-sync-agent.md` | Existed | **DELETED** |
| Status updates | Via subagent delegation | Inline jq + Edit commands |

### Files Modified in Task 564

**Deleted**:
- `.claude/agents/status-sync-agent.md`

**Rewritten**:
- `.claude/skills/skill-status-sync/SKILL.md` - Converted to direct execution pattern

**Updated (17 files total)**:
- `.claude/CLAUDE.md` - Updated skill-to-agent mapping
- `.claude/commands/research.md`
- `.claude/commands/plan.md`
- `.claude/commands/implement.md`
- `.claude/commands/revise.md`
- `.claude/context/index.md`
- `.claude/context/core/patterns/inline-status-update.md`
- `.claude/context/core/patterns/skill-lifecycle.md`
- `.claude/context/core/patterns/anti-stop-patterns.md`
- `.claude/context/core/templates/command-template.md`
- `.claude/context/core/checkpoints/checkpoint-gate-in.md`
- `.claude/context/core/checkpoints/checkpoint-gate-out.md`
- `.claude/context/core/orchestration/state-lookup.md`
- `.claude/docs/README.md`
- `.claude/docs/guides/component-selection.md`

### Direct Execution Pattern

The new `skill-status-sync` uses inline shell commands:

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

### Memory Issue Root Cause

The forked skill pattern (spawning status-sync-agent) caused memory exhaustion during command execution because:
1. Each status update required spawning a new subagent
2. Subagent context loading added memory pressure
3. Multi-step commands (research → plan → implement) accumulated memory usage

The direct execution pattern eliminates subagent spawning overhead.

## Goals & Non-Goals

**Goals**:
- Document model selection mechanism for porting (DONE in v001)
- Document Task 564 architectural changes for porting (NEW in v002)
- Provide comprehensive reference for `protocol/.claude/` migration

**Non-Goals**:
- Implementing changes in this repository (delegated to tasks 535-539 for model changes)
- Implementing in `protocol/.claude/` (separate task in that project)

## Implementation Phases

### Phase 1: Research Completion [COMPLETED]

*From v001 - no changes*

**Goal**: Complete research and documentation of model selection mechanism.

**Completed**: 2026-01-17

### Phase 2: Task 564 Documentation [NOT STARTED]

**Goal**: Document the Task 564 changes for porting reference.

**Tasks**:
- [ ] Create porting reference document in `specs/534_research_claude_code_model_selection/`
- [ ] Include before/after comparison for skill-status-sync
- [ ] Document the direct execution pattern
- [ ] List all files modified in Task 564
- [ ] Include verification checklist for porting

**Timing**: 30 minutes

**Files to create**:
- `specs/534_research_claude_code_model_selection/reports/porting-reference-task564.md`

**Verification**:
- Porting reference includes complete file list
- Direct execution pattern documented with examples
- Before/after comparison included

---

### Phase 3: Porting Checklist [NOT STARTED]

**Goal**: Create a checklist for porting both model selection and status-sync changes to `protocol/.claude/`.

**Tasks**:
- [ ] Create comprehensive porting checklist
- [ ] Organize by component (agents, skills, commands, context)
- [ ] Include verification steps

**Timing**: 15 minutes

**Files to create**:
- `specs/534_research_claude_code_model_selection/reports/porting-checklist.md`

**Verification**:
- Checklist covers both model selection and status-sync changes
- Verification steps included

---

## Follow-Up Tasks

### From v001 (Model Selection)
| Task | Description | Recommended Action |
|------|-------------|-------------------|
| 535 | Add model field to lean-research-agent | Set `model: opus` |
| 536 | Add model field to lean-implementation-agent | Set `model: opus` |
| 537 | Add model field to remaining agents | Set `model: sonnet` for 5 agents |
| 538 | Update CLAUDE.md with model field documentation | Add to Skill Architecture section |
| 539 | Create model selection validation tests | Test frontmatter vs Task tool |

### From v002 (Task 564 Changes)
These changes are already implemented in ProofChecker/.claude/ and need to be ported to protocol/.claude/:
- Convert skill-status-sync to direct execution
- Delete status-sync-agent
- Update all 17 documentation files

## Summary of Changes to Port

### Model Selection (from research-001.md)
1. Add `model` field to agent YAML frontmatter
2. Recommended values: `opus` for Lean agents, `sonnet` for others
3. Update CLAUDE.md skill-to-agent table to include model column

### Status-Sync Architecture (from Task 564)
1. Convert skill-status-sync from forked to direct execution
2. Delete status-sync-agent.md
3. Update 17 documentation files to remove status-sync-agent references
4. Verify with `grep -r "status-sync-agent" .claude/` returns nothing

## Testing & Validation

- [x] Research report contains all required sections (from v001)
- [ ] Porting reference document created
- [ ] Porting checklist created
- [ ] All Task 564 changes documented

## Artifacts & Outputs

**From v001**:
- specs/534_research_claude_code_model_selection/reports/research-001.md (created)
- specs/534_research_claude_code_model_selection/plans/implementation-001.md

**From v002**:
- specs/534_research_claude_code_model_selection/plans/implementation-002.md (this file)
- specs/534_research_claude_code_model_selection/reports/porting-reference-task564.md (to create)
- specs/534_research_claude_code_model_selection/reports/porting-checklist.md (to create)

## Rollback/Contingency

Not applicable - this is a documentation task with no code changes.
