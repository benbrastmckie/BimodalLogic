# Implementation Plan: Task #594 (v2)

- **Task**: 594 - Fix Progress Interruptions in Agent System
- **Status**: [NOT STARTED]
- **Effort**: 6.5 hours
- **Priority**: High
- **Version**: 002
- **Previous Version**: [implementation-001.md](implementation-001.md)
- **Dependencies**: 591 (completed - double forking fix)
- **Research Inputs**:
  - [research-001.md](../reports/research-001.md) - Root cause analysis
  - [research-002.md](../reports/research-002.md) - Gap analysis of all skills/commands
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Revision Summary

**Changes from v001:**
1. Explicit /revise command handling added to Phase 1 (was only mentioned, now detailed)
2. Exclusion criteria added to Phase 7 documentation updates
3. Summary matrix added showing all components and their classification
4. Clarified that non-workflow components are intentionally excluded

## Overview

Fix progress interruptions requiring "continue" prompts during workflow commands by consolidating the multi-skill checkpoint pattern into single skill invocations with inline status updates. The current architecture invokes skill-status-sync separately for GATE IN and GATE OUT, creating 3-4 halt boundaries per command. By moving preflight/postflight updates into the primary workflow skills, we reduce halt points from 3-4 to 1.

### Research Integration

**From research-001.md** (Root cause):
1. Each skill invocation creates a halt boundary where Claude may pause
2. Current pattern: GATE IN (skill-status-sync) -> DELEGATE (primary skill) -> GATE OUT (skill-status-sync) -> COMMIT
3. Solution: Move preflight/postflight inline into primary skills
4. Inline patterns already documented in `.claude/context/core/patterns/inline-status-update.md`
5. Anti-stop patterns must be audited to prevent JSON output triggering stops

**From research-002.md** (Gap analysis):
1. 6 workflow skills need inline updates (all covered)
2. 5 other skills are correctly EXCLUDED (utility, router, mechanism, task-creator patterns)
3. 4 workflow commands need updates: /research, /plan, /implement, /revise
4. 6 other commands are correctly EXCLUDED (report, error-system, task-creator, archive, utility, CRUD patterns)

## Component Classification

### Workflow Components (INCLUDE in refactor)

| Component | Type | Pattern |
|-----------|------|---------|
| skill-researcher | skill | thin wrapper + Task |
| skill-planner | skill | thin wrapper + Task |
| skill-implementer | skill | thin wrapper + Task |
| skill-lean-research | skill | thin wrapper + Task |
| skill-lean-implementation | skill | thin wrapper + Task |
| skill-latex-implementation | skill | thin wrapper + Task |
| /research | command | workflow command |
| /plan | command | workflow command |
| /implement | command | workflow command |
| /revise | command | workflow command |

### Non-Workflow Components (EXCLUDE from refactor)

| Component | Type | Exclusion Reason |
|-----------|------|------------------|
| skill-git-workflow | utility | No task state management |
| skill-orchestrator | router | Delegates state management |
| skill-status-sync | mechanism | IS the status update mechanism |
| skill-meta | task-creator | Creates tasks, no transitions |
| skill-document-converter | utility | Standalone file conversion |
| /review | report | Creates reports, not transitions |
| /errors | error-system | Separate error tracking system |
| /meta | task-creator | Creates tasks via skill-meta |
| /todo | archive | Operates on terminal states only |
| /convert | utility | Standalone file conversion |
| /task | CRUD | Task management, not workflow |

## Goals & Non-Goals

**Goals**:
- Reduce halt boundaries per command from 3-4 to 1
- Maintain atomic status updates (state.json + TODO.md synchronized)
- Preserve checkpoint verification semantics
- Keep existing artifact and error handling patterns
- Document exclusion criteria for non-workflow components

**Non-Goals**:
- Eliminating skill-status-sync entirely (still useful for standalone operations)
- Changing the subagent return format
- Modifying git commit patterns
- Adding inline updates to non-workflow components

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking existing workflows | High | Medium | Incremental migration per skill; test each before proceeding |
| Losing checkpoint verification | Medium | Low | Keep inline verification logic identical to skill-status-sync |
| Status sync failures | Medium | Low | Atomic jq patterns with temp file already documented |
| Increased skill complexity | Low | Medium | Reuse patterns from inline-status-update.md directly |
| Anti-stop patterns missed | Medium | Medium | Systematic audit of all agent return examples |

## Implementation Phases

### Phase 1: Modify Command Files to Remove skill-status-sync Invocations [NOT STARTED]

**Goal**: Update /research, /plan, /implement, /revise command files to remove explicit skill-status-sync invocations for GATE IN and GATE OUT, keeping only the primary skill invocation.

**Tasks**:
- [ ] Update `.claude/commands/research.md`:
  - Remove step 4 "Update Status (via skill-status-sync)" from GATE IN
  - Remove step 3 "Update Status (via skill-status-sync)" from GATE OUT
  - Keep inline validation using Bash/jq
  - Update "On success" text to remove skill invocation references
- [ ] Update `.claude/commands/plan.md` with same changes
- [ ] Update `.claude/commands/implement.md` with same changes
- [ ] Update `.claude/commands/revise.md`:
  - Remove "Update Status (via skill-status-sync)" from CHECKPOINT 2 GATE OUT
  - For Stage 2A (Plan Revision): inline postflight becomes skill responsibility
  - For Stage 2B (Description Update): inline jq/Edit already present, no change needed
  - Ensure consistent pattern with other workflow commands

**Timing**: 1.5 hours

**Files to modify**:
- `.claude/commands/research.md` - Remove skill-status-sync invocations
- `.claude/commands/plan.md` - Remove skill-status-sync invocations
- `.claude/commands/implement.md` - Remove skill-status-sync invocations
- `.claude/commands/revise.md` - Remove skill-status-sync invocation from Stage 2A

**Verification**:
- Commands reference only single primary skill invocation
- GATE IN/OUT sections contain only validation, not skill invocations
- Document flow shows: Validate -> Skill(primary) -> Commit

---

### Phase 2: Add Inline Preflight/Postflight to skill-researcher [NOT STARTED]

**Goal**: Add inline status update logic to skill-researcher so it handles its own preflight (researching) and postflight (researched) status transitions.

**Tasks**:
- [ ] Add new section "### 0. Preflight Status Update" before "### 1. Input Validation"
- [ ] Include jq command to update state.json status to "researching"
- [ ] Include Edit pattern to update TODO.md status marker
- [ ] Add session_id to state.json update for traceability
- [ ] Add new section "### 5. Postflight Status Update" after "### 4. Return Validation"
- [ ] Include jq command to update state.json status to "researched"
- [ ] Include Edit pattern to update TODO.md status marker and add artifact link
- [ ] Update allowed-tools to include `Bash, Edit, Read, Task` (add Bash, Edit, Read)
- [ ] Add reference to inline-status-update.md in skill file

**Timing**: 1 hour

**Files to modify**:
- `.claude/skills/skill-researcher/SKILL.md` - Add preflight/postflight sections, update allowed-tools

**Verification**:
- Skill includes sections 0 and 5 for status updates
- allowed-tools includes Bash, Edit, Read in addition to Task
- jq commands match patterns in inline-status-update.md
- Postflight includes artifact linking

---

### Phase 3: Add Inline Preflight/Postflight to skill-planner [NOT STARTED]

**Goal**: Add inline status update logic to skill-planner for planning/planned transitions.

**Tasks**:
- [ ] Add "### 0. Preflight Status Update" section with planning status update
- [ ] Add "### 5. Postflight Status Update" section with planned status update
- [ ] Update allowed-tools to include `Bash, Edit, Read, Task`
- [ ] Add reference to inline-status-update.md

**Timing**: 0.5 hours

**Files to modify**:
- `.claude/skills/skill-planner/SKILL.md` - Add preflight/postflight sections

**Verification**:
- Skill includes status update sections
- Status transitions match planning -> planned
- Artifact linking included for plan files

---

### Phase 4: Add Inline Preflight/Postflight to skill-implementer [NOT STARTED]

**Goal**: Add inline status update logic to skill-implementer for implementing/implemented transitions.

**Tasks**:
- [ ] Add "### 0. Preflight Status Update" section with implementing status update
- [ ] Add "### 5. Postflight Status Update" section with conditional logic:
  - If result.status == "implemented": update to completed
  - If result.status == "partial": keep as implementing, note resume point
- [ ] Update allowed-tools to include `Bash, Edit, Read, Task`
- [ ] Add reference to inline-status-update.md
- [ ] Handle partial completion case in postflight

**Timing**: 0.75 hours

**Files to modify**:
- `.claude/skills/skill-implementer/SKILL.md` - Add preflight/postflight sections

**Verification**:
- Skill handles both complete and partial outcomes
- Status transitions match implementing -> completed/implementing
- Summary artifact linking included

---

### Phase 5: Add Inline Preflight/Postflight to Lean and LaTeX Skills [NOT STARTED]

**Goal**: Apply same inline pattern to skill-lean-research, skill-lean-implementation, and skill-latex-implementation.

**Tasks**:
- [ ] Update `.claude/skills/skill-lean-research/SKILL.md` with preflight/postflight sections
- [ ] Update `.claude/skills/skill-lean-implementation/SKILL.md` with preflight/postflight sections
- [ ] Update `.claude/skills/skill-latex-implementation/SKILL.md` with preflight/postflight sections
- [ ] Ensure all use consistent patterns from inline-status-update.md

**Timing**: 1 hour

**Files to modify**:
- `.claude/skills/skill-lean-research/SKILL.md` - Add preflight/postflight
- `.claude/skills/skill-lean-implementation/SKILL.md` - Add preflight/postflight
- `.claude/skills/skill-latex-implementation/SKILL.md` - Add preflight/postflight

**Verification**:
- All implementation/research skills include inline status updates
- Consistent patterns across all skills

---

### Phase 6: Audit and Strengthen Anti-Stop Patterns [NOT STARTED]

**Goal**: Audit all agent files and skill returns to ensure no stop-trigger content exists.

**Tasks**:
- [ ] Scan all `.claude/agents/*.md` files for forbidden patterns:
  - `"status": "completed"` (should be contextual: researched, planned, implemented)
  - Phrases: "Task complete", "work is done", "finished"
- [ ] Update any agent return examples that use forbidden patterns
- [ ] Verify MUST NOT sections include anti-stop items in all agents
- [ ] Check `.claude/skills/*/SKILL.md` return format examples
- [ ] Add grep check commands to documentation or CI

**Timing**: 0.75 hours

**Files to modify**:
- `.claude/agents/general-research-agent.md` - Verify anti-stop compliance
- `.claude/agents/planner-agent.md` - Verify anti-stop compliance
- `.claude/agents/general-implementation-agent.md` - Verify anti-stop compliance
- `.claude/agents/lean-research-agent.md` - Verify anti-stop compliance
- `.claude/agents/lean-implementation-agent.md` - Verify anti-stop compliance
- `.claude/agents/latex-implementation-agent.md` - Verify anti-stop compliance
- `.claude/agents/meta-builder-agent.md` - Verify anti-stop compliance
- `.claude/context/core/patterns/anti-stop-patterns.md` - Add any new patterns found

**Verification**:
- `grep '"status": "completed' .claude/agents/*.md` returns no matches
- `grep -i "Task complete" .claude/agents/*.md` returns no matches
- All agents have explicit anti-stop MUST NOT items

---

### Phase 7: Update Pattern Documentation and Add Exclusion Criteria [NOT STARTED]

**Goal**: Update skill-lifecycle.md and related docs to reflect new consolidated architecture, and document which components are excluded and why.

**Tasks**:
- [ ] Update `.claude/context/core/patterns/skill-lifecycle.md`:
  - Mark "After (1 Skill)" as current standard
  - Remove "Before (3 Skills)" as deprecated
  - Update execution flow diagram
  - Add section documenting exclusion criteria
- [ ] Update `.claude/CLAUDE.md` Checkpoint-Based Execution Model section:
  - Clarify that skills handle their own preflight/postflight
  - Update diagram if needed
  - Add note about excluded components
- [ ] Verify inline-status-update.md patterns match what was implemented
- [ ] Add note to skill-status-sync/SKILL.md that it's for standalone use only
- [ ] Add exclusion criteria documentation:
  - Utility pattern: Provides utility function, no task state
  - Task creation pattern: Creates tasks, no transitions
  - Routing pattern: Routes only, delegates state management
  - Terminal state pattern: Operates on completed/abandoned states
  - Non-task pattern: Operates on different data (errors, reviews)
  - Mechanism pattern: IS the status update mechanism

**Timing**: 1 hour

**Files to modify**:
- `.claude/context/core/patterns/skill-lifecycle.md` - Mark new pattern as standard, add exclusions
- `.claude/CLAUDE.md` - Update checkpoint execution model
- `.claude/skills/skill-status-sync/SKILL.md` - Add standalone use note

**Verification**:
- Documentation reflects consolidated single-skill pattern
- skill-status-sync documented as standalone utility
- Exclusion criteria clearly documented with examples

## Testing & Validation

- [ ] Run `/research` on a test task - verify 0-1 continue prompts
- [ ] Run `/plan` on a test task - verify 0-1 continue prompts
- [ ] Run `/implement` on a test task - verify 0-1 continue prompts
- [ ] Run `/revise` on a test task - verify 0-1 continue prompts
- [ ] Verify status transitions work correctly (check TODO.md and state.json)
- [ ] Verify artifact linking works in postflight
- [ ] Verify git commits still execute correctly
- [ ] Test partial implementation scenario (timeout simulation)

## Artifacts & Outputs

**Modified command files**:
- research.md, plan.md, implement.md, revise.md

**Modified skill files**:
- skill-researcher, skill-planner, skill-implementer
- skill-lean-research, skill-lean-implementation, skill-latex-implementation

**Updated documentation**:
- skill-lifecycle.md, CLAUDE.md, skill-status-sync/SKILL.md

**Audited agent files**:
- All agents in `.claude/agents/` verified for anti-stop compliance

## Rollback/Contingency

If implementation causes workflow failures:
1. Revert command file changes to restore skill-status-sync invocations
2. Revert skill files to remove inline status updates
3. skill-status-sync remains functional as fallback
4. Git history preserves all previous versions for recovery

Phase-by-phase commits enable granular rollback if specific changes cause issues.
