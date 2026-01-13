# Implementation Plan: Task #474

- **Task**: 474 - Fix skill return "status": "completed" field causing premature stops
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Priority**: High
- **Dependencies**: None (builds on tasks 462, 467)
- **Research Inputs**: Task 467 research-001.md (analyzed root cause)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Fix the root cause of workflow commands stopping prematurely after skill returns. The problem: skills return JSON with `"status": "completed"` which Claude interprets as a signal to stop execution. This plan changes the field to non-triggering terminology (`"outcome"` instead of `"status"`) across all skill and agent return formats.

Tasks 462 and 467 added continuation markers ("IMMEDIATELY CONTINUE") as a workaround, but the root issue remains: the `"status": "completed"` field in skill returns acts as a stop signal. This plan addresses the root cause.

### Research Integration

From task 467 research-001.md:
- **Finding 5**: "Claude's interpretation of skill returns as transaction boundaries" - the `"status": "completed"` JSON field triggers Claude to treat the return as a stopping point
- **Recommendation**: Change to non-triggering terminology

## Goals & Non-Goals

**Goals**:
- Replace `"status"` field with `"outcome"` in all skill/agent return formats
- Update subagent-return.md schema definition
- Update all skill SKILL.md files (9 files)
- Update all agent .md files (7 files)
- Update orchestrator validation logic references
- Ensure backward compatibility (accept both during transition)

**Non-Goals**:
- Removing continuation markers (they provide defense-in-depth)
- Changing task status values (researching, planned, etc.) - these are different
- Modifying state.json structure (task status != skill return status)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Break existing validation logic | High | Medium | Search for all "status" references before changing |
| Miss files containing the pattern | Medium | Low | Use comprehensive grep to identify all files |
| Confusion between task status and outcome | Low | Medium | Document distinction clearly |
| Claude still stops despite change | Medium | Low | Keep continuation markers as backup |

## Implementation Phases

### Phase 1: Update Core Schema [NOT STARTED]

**Goal**: Update the authoritative subagent-return.md schema to use `"outcome"` instead of `"status"`

**Tasks**:
- [ ] Update `.claude/context/core/formats/subagent-return.md`
  - Change `"status"` to `"outcome"` in schema
  - Update field specification section
  - Update all examples
  - Add note about rationale (avoiding trigger word)
- [ ] Add explicit note explaining why "outcome" was chosen over "status"

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/core/formats/subagent-return.md` - Primary schema definition

**Verification**:
- Schema shows `"outcome"` field with same enum values
- All examples updated consistently
- Rationale documented

---

### Phase 2: Update Skill Files [NOT STARTED]

**Goal**: Update all skill SKILL.md files to use `"outcome"` in their return format documentation

**Tasks**:
- [ ] Update `.claude/skills/skill-status-sync/SKILL.md`
  - API Operations return format (preflight_update, postflight_update, artifact_link)
  - Return Format section (line ~596-608)
  - Error Handling section (lines ~615-658)
- [ ] Update `.claude/skills/skill-git-workflow/SKILL.md`
  - Return examples (lines ~206-228)
- [ ] Update `.claude/skills/skill-planner/SKILL.md`
  - Return Format section (lines ~121-135)
- [ ] Update `.claude/skills/skill-researcher/SKILL.md`
  - Return Format section (lines ~114-128)
- [ ] Update `.claude/skills/skill-lean-research/SKILL.md`
  - Return Format section (lines ~119-133)
- [ ] Update `.claude/skills/skill-implementer/SKILL.md`
  - Return Format section (lines ~121-153)
- [ ] Update `.claude/skills/skill-lean-implementation/SKILL.md`
  - Return Format section (lines ~132-171)
- [ ] Update `.claude/skills/skill-latex-implementation/SKILL.md`
  - Return Format section (lines ~134-178)
- [ ] Update `.claude/skills/skill-meta/SKILL.md`
  - Return Format section (lines ~113-179)

**Timing**: 45 minutes

**Files to modify**:
- All 9 skill files in `.claude/skills/*/SKILL.md`

**Verification**:
- All skill files show `"outcome"` instead of `"status"` in returns
- Error returns still use `"outcome": "failed"`
- No remaining `"status": "completed"` patterns in skills

---

### Phase 3: Update Agent Files [NOT STARTED]

**Goal**: Update all agent .md files to use `"outcome"` in their return format documentation

**Tasks**:
- [ ] Update `.claude/agents/planner-agent.md`
  - Return Format Examples section
  - Failed/Partial/Completed examples
- [ ] Update `.claude/agents/lean-research-agent.md`
  - Return Format Examples section
- [ ] Update `.claude/agents/general-research-agent.md`
  - Return Format Examples section
- [ ] Update `.claude/agents/lean-implementation-agent.md`
  - Return Format Examples section
- [ ] Update `.claude/agents/general-implementation-agent.md`
  - Return Format Examples section
- [ ] Update `.claude/agents/latex-implementation-agent.md`
  - Return Format Examples section
- [ ] Update `.claude/agents/meta-builder-agent.md`
  - Return Format Examples section

**Timing**: 45 minutes

**Files to modify**:
- All 7 agent files in `.claude/agents/*.md`

**Verification**:
- All agent files show `"outcome"` instead of `"status"` in returns
- Return schema matches subagent-return.md

---

### Phase 4: Update Supporting Documentation [NOT STARTED]

**Goal**: Update any other documentation referencing the return format

**Tasks**:
- [ ] Search for remaining `"status": "completed"` patterns in `.claude/`
- [ ] Update `.claude/context/core/orchestration/validation.md` if present
- [ ] Update `.claude/docs/guides/creating-agents.md`
- [ ] Update `.claude/docs/guides/creating-skills.md`
- [ ] Update `.claude/docs/templates/agent-template.md`
- [ ] Update `.claude/docs/examples/research-flow-example.md`
- [ ] Update `.claude/ARCHITECTURE.md` if it references return format

**Timing**: 30 minutes

**Files to modify**:
- Various documentation files in `.claude/docs/`, `.claude/context/`

**Verification**:
- grep for `"status": "completed"` returns no matches in `.claude/` (except state.json task status)
- Documentation is consistent

---

### Phase 5: Verification and Summary [NOT STARTED]

**Goal**: Verify all changes are consistent and create implementation summary

**Tasks**:
- [ ] Run comprehensive grep for remaining `"status"` patterns
  - `grep -r '"status":.*"completed"' .claude/` should only match state.json/TODO.md (task status)
- [ ] Verify skill-status-sync can still be invoked without errors
- [ ] Verify continuation markers from task 467 are still in place
- [ ] Create implementation summary

**Timing**: 30 minutes

**Verification**:
- No workflow-stopping `"status": "completed"` patterns remain in skill/agent returns
- Task status in state.json unchanged (uses different context)
- Commands run without "completed" trigger stops

## Testing & Validation

- [ ] grep verification: `grep -r '"status":\s*"completed"' .claude/ --include="*.md"` excludes state.json
- [ ] Run `/research` on a test task - should not stop after preflight
- [ ] Run `/plan` on a test task - should complete full workflow
- [ ] Verify skill-status-sync returns still parse correctly

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (on completion)
- Modified files:
  - 1 schema file (subagent-return.md)
  - 9 skill files
  - 7 agent files
  - ~5-10 documentation files

## Rollback/Contingency

If the change causes issues:
1. The old field name can be restored via git revert
2. Continuation markers from task 467 remain as fallback
3. Both field names could be supported during transition if needed

## Notes

- The `"status"` field in state.json for task status (researching, planned, completed) is DIFFERENT from skill return status
- This change only affects skill/agent return format documentation, not actual task tracking
- Tasks 462 and 467's continuation markers should remain as defense-in-depth
