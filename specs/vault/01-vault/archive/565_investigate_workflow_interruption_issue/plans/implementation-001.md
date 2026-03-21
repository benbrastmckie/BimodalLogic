# Implementation Plan: Task #565

- **Task**: 565 - Investigate Workflow Interruption Issue
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/565_investigate_workflow_interruption_issue/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This plan addresses JavaScript heap exhaustion (OOM crashes) occurring during subagent delegation in the Claude Code agent system. Research identified that crashes occur at ~4040-4050 MB heap usage when spawning subagents via the Task tool. The solution combines immediate documentation of workarounds with medium-term context file optimization to reduce memory pressure.

### Research Integration

Key findings from research-001.md:
- Root cause: V8 JavaScript heap exhaustion during subagent spawning (95% confidence)
- Memory accumulates over session lifetime; crashes occur during Task tool invocation
- Task 564's fix (skill-status-sync direct execution) was correct but insufficient
- "Continue" prompts between stages are a separate issue from OOM crashes

## Goals & Non-Goals

**Goals**:
- Document session restart guidance to prevent OOM crashes
- Add memory-aware usage patterns to CLAUDE.md
- Audit and reduce oversized context files (>20KB)
- Improve lazy context loading patterns

**Non-Goals**:
- Eliminate all subagent spawning (architecture is sound)
- Fix "continue" prompts issue (separate investigation needed)
- Modify Claude Code internals or JavaScript heap limits
- Fundamental architecture changes to checkpoint model

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Users ignore restart guidance | High | High | Make guidance prominent in CLAUDE.md; add to agent system prompts |
| Context trimming breaks functionality | Medium | Low | Test carefully after each reduction; keep backups |
| Issue persists after optimizations | Medium | Medium | Session restart remains fallback; document as known limitation |
| Splitting files creates maintenance burden | Low | Medium | Keep related content in same file section; document organization |

## Implementation Phases

### Phase 1: Document Session Management Guidance [NOT STARTED]

**Goal**: Add prominent documentation about session restart patterns to prevent OOM crashes

**Tasks**:
- [ ] Add "Session Memory Management" section to CLAUDE.md
- [ ] Document recommended session restart frequency (every 3-5 commands)
- [ ] Add workflow patterns for long task sequences (restart between stages)
- [ ] Document that `/clear` does not free V8 heap memory

**Timing**: 30 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - Add session management guidance section

**Verification**:
- New section clearly explains memory limitation
- Restart guidance is actionable and prominent
- Patterns for long workflows are documented

---

### Phase 2: Audit and Catalog Large Context Files [NOT STARTED]

**Goal**: Identify context files contributing most to memory pressure

**Tasks**:
- [ ] Generate size report for all files in `.claude/context/`
- [ ] Identify files >20KB that load during subagent spawning
- [ ] Catalog which agents load which context files
- [ ] Create prioritized reduction list based on load frequency and size

**Timing**: 30 minutes

**Files to modify**:
- None (analysis phase)

**Verification**:
- Complete size inventory exists
- Top 10 largest files identified
- Agent-to-context mapping documented

---

### Phase 3: Optimize Largest Context Files [NOT STARTED]

**Goal**: Reduce memory footprint of largest context files without losing functionality

**Tasks**:
- [ ] Review state-management.md (33KB) for content that can be extracted
- [ ] Review state-lookup.md (25KB) for redundancy with state-management.md
- [ ] Review delegation.md (24KB) for unnecessary duplication
- [ ] Split or consolidate files where appropriate
- [ ] Update @-references in agents that load these files

**Timing**: 45 minutes

**Files to modify**:
- `.claude/context/core/orchestration/state-management.md` - Optimize content
- `.claude/context/core/orchestration/state-lookup.md` - Reduce redundancy
- `.claude/context/core/orchestration/delegation.md` - Trim examples
- Agent files referencing these contexts (update paths if split)

**Verification**:
- Combined size reduction of >30%
- No broken @-references
- Agent system still functions correctly

---

### Phase 4: Improve Agent Context Loading Patterns [NOT STARTED]

**Goal**: Ensure agents load only necessary context for their operations

**Tasks**:
- [ ] Review each agent file for unnecessary context loading
- [ ] Convert eager @-references to on-demand loading instructions
- [ ] Document context loading requirements in agent headers
- [ ] Test agent execution to verify no missing context

**Timing**: 30 minutes

**Files to modify**:
- `.claude/agents/general-research-agent.md` - Review context refs
- `.claude/agents/planner-agent.md` - Review context refs
- `.claude/agents/general-implementation-agent.md` - Review context refs
- Other agent files as needed

**Verification**:
- Agents explicitly document required context
- No unnecessary context loaded eagerly
- Agents still function correctly

---

### Phase 5: Create Implementation Summary [NOT STARTED]

**Goal**: Document changes made and verify improvements

**Tasks**:
- [ ] Create implementation summary documenting all changes
- [ ] List memory reduction achieved per file
- [ ] Document session management guidance added
- [ ] Note any remaining issues for future work

**Timing**: 15 minutes

**Files to modify**:
- `specs/565_investigate_workflow_interruption_issue/summaries/implementation-summary-YYYYMMDD.md` (create)

**Verification**:
- Summary accurately reflects all changes
- Metrics documented where available
- Next steps identified if any

## Testing & Validation

- [ ] Verify CLAUDE.md renders correctly with new section
- [ ] Verify context files still load without errors
- [ ] Verify agent files have valid @-references
- [ ] Manual test: Run /research, /plan, /implement sequence to verify no regressions
- [ ] Confirm session restart guidance is actionable

## Artifacts & Outputs

- `specs/565_investigate_workflow_interruption_issue/plans/implementation-001.md` (this file)
- `specs/565_investigate_workflow_interruption_issue/summaries/implementation-summary-YYYYMMDD.md`
- Updated `.claude/CLAUDE.md` with session management section
- Optimized context files in `.claude/context/`

## Rollback/Contingency

- All original context files can be restored from git
- If context trimming causes issues, revert specific files and note in errors.json
- Session restart guidance is additive and can be removed if unhelpful
- Document any failed optimization attempts for future reference
