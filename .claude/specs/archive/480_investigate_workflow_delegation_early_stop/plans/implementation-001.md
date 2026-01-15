# Implementation Plan: Task #480

- **Task**: 480 - Investigate workflow delegation early stop
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: .claude/specs/480_investigate_workflow_delegation_early_stop/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Fix workflow delegation early stop by updating agent and skill files to use contextual status values instead of "completed" and removing "Task complete" language. Research identified that Claude interprets "completed" as a stop signal, causing workflows to halt before orchestrator postflight runs. The fix requires updating 6 agent return schemas and 3 skill next_steps fields.

### Research Integration

Key findings from research-001.md:
- **Root Cause**: Agent files use `"status": "completed"` despite subagent-return.md explicitly removing this value
- **6 Agent Files Affected**: All agent files have inconsistent status values in their return format schemas
- **3 Skill Files Affected**: Use `"next_steps": "Task complete"` which triggers stop behavior
- **Validated Pattern**: skill-status-sync already implements correct anti-stop patterns (lines 53, 80, 121, 622)
- **External Confirmation**: GitHub issues #6159 and #599 confirm this is known Claude Code behavior

## Goals & Non-Goals

**Goals**:
- Update all 6 agent files to use contextual status values (researched, planned, implemented)
- Remove "Task complete" language from 3 skill files
- Add anti-stop instructions to agent Critical Requirements sections
- Ensure consistency with existing subagent-return.md specification

**Non-Goals**:
- Implementing state machine patterns (optional enhancement per research)
- Modifying Claude Code behavior itself
- Updating orchestrator delegation context (lower priority per research)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Claude ignores anti-stop language | High | Medium | Multiple reinforcement points, use CRITICAL markers |
| Changes break existing workflows | Medium | Low | Test each agent type after changes |
| Inconsistency in find/replace | Low | Medium | Verify each file after edit |
| Missing some occurrences | Medium | Low | Use Grep to verify no "completed" remains |

## Implementation Phases

### Phase 1: Fix Agent Return Format Schemas [NOT STARTED]

**Goal**: Update all 6 agent files to replace `"completed"` with contextual status values in their return format schemas

**Tasks**:
- [ ] Update general-research-agent.md: change `"completed|partial|failed"` to `"researched|partial|failed"`
- [ ] Update lean-research-agent.md: change `"completed|partial|failed"` to `"researched|partial|failed"`
- [ ] Update planner-agent.md: change `"completed|partial|failed"` to `"planned|partial|failed"`
- [ ] Update general-implementation-agent.md: change `"completed|partial|failed"` to `"implemented|partial|failed"`
- [ ] Update lean-implementation-agent.md: change `"completed|partial|failed"` to `"implemented|partial|failed"`
- [ ] Update latex-implementation-agent.md: change `"completed|partial|failed"` to `"implemented|partial|failed"`

**Timing**: 45 minutes

**Files to modify**:
- `.claude/agents/general-research-agent.md` - Line 205 area
- `.claude/agents/lean-research-agent.md` - Line 212 area
- `.claude/agents/planner-agent.md` - Line 223 area
- `.claude/agents/general-implementation-agent.md` - Line 176 area
- `.claude/agents/lean-implementation-agent.md` - Line 206 area
- `.claude/agents/latex-implementation-agent.md` - Line 214 area

**Verification**:
- Grep for `"completed|partial|failed"` returns 0 matches in agents/
- Grep for contextual values (researched, planned, implemented) finds expected patterns

---

### Phase 2: Fix Skill "Task complete" Language [NOT STARTED]

**Goal**: Replace "Task complete" with non-terminal language in skill next_steps fields

**Tasks**:
- [ ] Update skill-latex-implementation/SKILL.md: change `"next_steps": "Task complete"` to `"next_steps": "Implementation finished. Run /task --sync to verify."`
- [ ] Update skill-lean-implementation/SKILL.md: change `"next_steps": "Task complete"` to `"next_steps": "Implementation finished. Run /task --sync to verify."`
- [ ] Update skill-implementer/SKILL.md: change `"next_steps": "Task complete"` to `"next_steps": "Implementation finished. Run /task --sync to verify."`

**Timing**: 20 minutes

**Files to modify**:
- `.claude/skills/skill-latex-implementation/SKILL.md` - Line 161 area
- `.claude/skills/skill-lean-implementation/SKILL.md` - Line 154 area
- `.claude/skills/skill-implementer/SKILL.md` - Line 138 area

**Verification**:
- Grep for `"Task complete"` returns 0 matches in skills/
- Grep for `"Implementation finished"` finds 3 matches

---

### Phase 3: Add Anti-Stop Instructions to Agents [NOT STARTED]

**Goal**: Add explicit anti-stop instructions to each agent's Critical Requirements section

**Tasks**:
- [ ] Add anti-stop MUST NOT section to general-research-agent.md
- [ ] Add anti-stop MUST NOT section to lean-research-agent.md
- [ ] Add anti-stop MUST NOT section to planner-agent.md
- [ ] Add anti-stop MUST NOT section to general-implementation-agent.md
- [ ] Add anti-stop MUST NOT section to lean-implementation-agent.md
- [ ] Add anti-stop MUST NOT section to latex-implementation-agent.md

**Anti-stop text to add to each MUST NOT section**:
```
- Return the word "completed" as a status value (triggers Claude stop behavior)
- Use phrases like "task is complete", "work is done", or "finished" in summaries
- Assume your return ends the workflow (orchestrator continues with postflight)
```

**Timing**: 45 minutes

**Files to modify**:
- `.claude/agents/general-research-agent.md` - Critical Requirements section
- `.claude/agents/lean-research-agent.md` - Critical Requirements section
- `.claude/agents/planner-agent.md` - Critical Requirements section
- `.claude/agents/general-implementation-agent.md` - Critical Requirements section
- `.claude/agents/lean-implementation-agent.md` - Critical Requirements section
- `.claude/agents/latex-implementation-agent.md` - Critical Requirements section

**Verification**:
- Each agent file contains "triggers Claude stop behavior" text
- Each agent file MUST NOT section includes the three anti-stop items

---

### Phase 4: Verification and Testing [NOT STARTED]

**Goal**: Verify all changes are consistent and no stop-triggering patterns remain

**Tasks**:
- [ ] Run Grep for `"status": "completed"` in .claude/ - expect 0 matches
- [ ] Run Grep for `"Task complete"` in .claude/ - expect 0 matches (or only in documentation)
- [ ] Run Grep for `"completed|partial|failed"` in agents/ - expect 0 matches
- [ ] Verify subagent-return.md still has correct specification (unchanged)
- [ ] Document verification results in implementation summary

**Timing**: 20 minutes

**Verification**:
- All grep searches return expected results
- No regressions in subagent-return.md specification

## Testing & Validation

- [ ] Grep verification: no "completed" status values in agent schemas
- [ ] Grep verification: no "Task complete" in skill next_steps
- [ ] Grep verification: anti-stop language present in all 6 agent files
- [ ] Manual review: spot-check 2 agent files for consistency

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (on completion)
- Modified files:
  - 6 agent files in `.claude/agents/`
  - 3 skill files in `.claude/skills/`

## Rollback/Contingency

If changes cause unexpected behavior:
1. Revert using git: `git checkout HEAD~1 -- .claude/agents/ .claude/skills/`
2. Individual file reverts possible since changes are isolated
3. Previous patterns preserved in git history for reference
