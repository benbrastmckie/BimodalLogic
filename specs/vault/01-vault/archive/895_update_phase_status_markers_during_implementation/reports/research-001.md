# Research Report: Task #895

**Task**: 895 - Update phase status markers during implementation
**Date**: 2026-02-17
**Focus**: Identify where phase status markers are handled and determine modification points

## Summary

Phase status markers are currently updated at multiple levels: skills handle task-level status (TODO.md, state.json, plan file header), while implementation agents handle phase-level status within plan files. The current behavior already includes updating phases to `[IN PROGRESS]` before work begins, but this happens within the implementation agent's Phase Checkpoint Protocol. The task requests making this behavior more explicit and ensuring status is updated to terminal states (`[COMPLETE]`, `[PARTIAL]`, `[BLOCKED]`) before proceeding to the next phase or returning.

## Findings

### 1. Current Phase Status Handling Architecture

**Two-Level Status Management**:

| Level | Location | Who Updates | Statuses |
|-------|----------|-------------|----------|
| Task-level | TODO.md, state.json, plan header | Skills (postflight) | `[IMPLEMENTING]`, `[COMPLETED]`, `[PARTIAL]` |
| Phase-level | Plan file phases | Implementation agents | `[NOT STARTED]`, `[IN PROGRESS]`, `[COMPLETED]`, `[PARTIAL]`, `[BLOCKED]` |

### 2. Files That Handle Phase Status

**Implementation Agents** (primary phase status handlers):
- `.claude/agents/general-implementation-agent.md` - Lines 138-167 (Phase Checkpoint Protocol)
- `.claude/agents/lean-implementation-agent.md` - Delegates to `lean-implementation-flow.md`

**Skills** (handle task-level status and plan header):
- `.claude/skills/skill-implementer/SKILL.md` - Lines 387-420 (update plan Status field)
- `.claude/skills/skill-lean-implementation/SKILL.md` - Lines 375-394 (similar pattern)
- `.claude/skills/skill-team-implement/SKILL.md` - Lines 269-279 (marks phases for teammates)

**Rules/Formats**:
- `.claude/rules/artifact-formats.md` - Lines 257-265 (defines phase status markers)

### 3. Current Implementation Agent Behavior

From `general-implementation-agent.md`, the Phase Checkpoint Protocol (Stage 4):

```
For each phase starting from resume point:

A. Mark Phase In Progress
   Edit plan file: Change phase status to [IN PROGRESS]

B. Execute Steps
   ...

C. Verify Phase Completion
   ...

D. Mark Phase Complete
   Edit plan file: Change phase status to [COMPLETED]
```

**Current behavior IS correct** - phases are marked `[IN PROGRESS]` before work and `[COMPLETED]` after. However:
1. The status `[PARTIAL]` and `[BLOCKED]` are documented but not explicitly shown in the protocol
2. The skill-level postflight updates plan file Status header, not individual phases

### 4. Gap Analysis

**What the task description requests**:
1. Update each phase to `[IMPLEMENTING]` before starting work on that phase
2. Update to `[COMPLETE]`, `[PARTIAL]`, or `[BLOCKED]` after work concludes
3. Do this before proceeding to the next phase or handing off to another subagent

**Current state**:
1. `[IN PROGRESS]` is used (not `[IMPLEMENTING]`) - this is a terminology question
2. Terminal states are documented but protocol only shows `[COMPLETED]` explicitly
3. Phase updates happen, but error/partial paths may not always update status

**Note on Terminology**: The task description mentions `[IMPLEMENTING]` for phases, but the artifact-formats.md standard uses `[IN PROGRESS]` for phases. The `[IMPLEMENTING]` status is used for task-level status in TODO.md/state.json. This may be an oversight in the task description, or it may indicate a desire to align terminology.

### 5. Files Requiring Modification

**Primary targets** (agent definitions - where phase status is actually updated):

1. **`.claude/agents/general-implementation-agent.md`**
   - Enhance Phase Checkpoint Protocol to explicitly handle `[PARTIAL]` and `[BLOCKED]`
   - Ensure status update happens BEFORE git commit and BEFORE proceeding to next phase
   - Add explicit status update on error paths

2. **`.claude/agents/lean-implementation-agent.md`**
   - Similar changes (delegates to lean-implementation-flow.md)

3. **`.claude/context/project/lean4/agents/lean-implementation-flow.md`**
   - Actual detailed execution flow for Lean implementation
   - Needs same phase status update patterns

**Secondary targets** (for team mode):

4. **`.claude/skills/skill-team-implement/SKILL.md`**
   - Already mentions marking phases `[IN PROGRESS]` then `[COMPLETED]` (line 273)
   - May need explicit `[PARTIAL]`/`[BLOCKED]` handling for teammate failures

5. **`.claude/utils/team-wave-helpers.md`**
   - Teammate prompt templates say "Mark phase [COMPLETED] in plan file" (line 453)
   - Could add explicit status handling for error cases

**Documentation targets** (ensure consistency):

6. **`.claude/rules/artifact-formats.md`**
   - Already defines the markers correctly
   - May need to clarify when each terminal status should be used

### 6. Recommended Changes

**Change 1: Enhance Agent Phase Checkpoint Protocol**

In `general-implementation-agent.md`, modify Stage 4 to:

```markdown
### Stage 4: Execute File Operations Loop

For each phase starting from resume point:

**A. Mark Phase In Progress**
Edit plan file: Change phase status to `[IN PROGRESS]`

**B. Execute Steps**
For each step in the phase:
1. Read existing files (if modifying)
2. Create or modify files
3. Verify step completion

**On step failure**:
- Document the failure
- Mark phase `[PARTIAL]` if some progress made, `[BLOCKED]` if cannot proceed
- Write Progress subsection with failure details
- Proceed to Stage 4E (skip remaining steps)

**C. Verify Phase Completion**
Run phase verification criteria

**On verification failure**:
- Mark phase `[PARTIAL]` if progress made, `[BLOCKED]` if verification shows fundamental issue
- Proceed to Stage 4E

**D. Mark Phase Complete**
Edit plan file: Change phase status to `[COMPLETED]`

**E. Phase Checkpoint** (always runs)
1. Write Progress subsection to plan file
2. Update summary file with Phase Entry
3. Git commit phase changes
4. Update metadata partial_progress

**F. Decide Next Action**
- If phase `[COMPLETED]`: Proceed to next phase
- If phase `[PARTIAL]` or `[BLOCKED]`: Update metadata and return
```

**Change 2: Add Status Update Before Subagent Handoff**

In skill files (`skill-implementer`, `skill-lean-implementation`), ensure the plan file phase status is updated before invoking subagent (not after). Currently, the skill preflight updates task-level status but not phase-level. For phase-level, this already happens in the agent's Stage 4A.

**Change 3: Explicit Partial/Blocked Handling in Team Mode**

In `skill-team-implement`, when a phase teammate fails:
- Spawn debugger OR mark phase `[PARTIAL]`/`[BLOCKED]`
- Update plan file with phase status before spawning successor or returning

### 7. Terminology Clarification

The task description uses `[IMPLEMENTING]` for phases, but the established artifact-formats.md standard uses:
- **Task-level (TODO.md)**: `[IMPLEMENTING]`
- **Phase-level (plan file phases)**: `[IN PROGRESS]`

**Recommendation**: Keep the existing terminology to avoid breaking changes. The task description's `[IMPLEMENTING]` should be interpreted as "the equivalent phase-level status", which is `[IN PROGRESS]`.

### 8. Risks and Edge Cases

| Risk | Impact | Mitigation |
|------|--------|------------|
| Agent interrupted before status update | Phase stuck in wrong state | Early status update pattern (already done for `[IN PROGRESS]`) |
| Git commit fails after status update | Status shows complete but changes not committed | Check git result, keep `[IN PROGRESS]` on commit failure |
| Multiple agents updating same phase (team mode) | Race condition | Each phase assigned to one teammate only |
| Phase marked `[COMPLETED]` but downstream phase fails | Misleading status | Correct - each phase has its own status |

## Recommendations

1. **Primary Change**: Update `general-implementation-agent.md` and `lean-implementation-agent.md` (via `lean-implementation-flow.md`) to explicitly handle `[PARTIAL]` and `[BLOCKED]` status updates in the error paths

2. **Verification**: Ensure the git commit step in Phase Checkpoint Protocol happens AFTER the status update

3. **Team Mode**: Update `skill-team-implement` to handle phase status when teammates fail or timeout

4. **No Terminology Change**: Keep using `[IN PROGRESS]` for phases (not `[IMPLEMENTING]`) to maintain consistency with artifact-formats.md

5. **Add Status Decision Tree**: Document when to use each terminal status:
   - `[COMPLETED]`: All steps done, verification passed
   - `[PARTIAL]`: Some steps done, can resume later
   - `[BLOCKED]`: Cannot proceed without external change

## References

- `.claude/agents/general-implementation-agent.md` - Primary implementation agent
- `.claude/agents/lean-implementation-agent.md` - Lean-specific agent
- `.claude/skills/skill-implementer/SKILL.md` - General implementation skill
- `.claude/skills/skill-lean-implementation/SKILL.md` - Lean implementation skill
- `.claude/skills/skill-team-implement/SKILL.md` - Team implementation skill
- `.claude/rules/artifact-formats.md` - Status marker definitions
- `.claude/utils/team-wave-helpers.md` - Teammate prompt templates

## Next Steps

1. Create implementation plan with phases:
   - Phase 1: Update general-implementation-agent.md Phase Checkpoint Protocol
   - Phase 2: Update lean-implementation-flow.md with same patterns
   - Phase 3: Update skill-team-implement for teammate failure handling
   - Phase 4: Update artifact-formats.md with status decision tree
   - Phase 5: Verify consistency and test
