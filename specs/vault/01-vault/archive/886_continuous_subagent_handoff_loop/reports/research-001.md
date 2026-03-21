# Research Report: Task #886

**Task**: Continuous Subagent Handoff Loop
**Date**: 2026-02-17
**Focus**: Loop architecture for auto-resuming partial implementations

## Summary

Both `skill-implementer` and `skill-lean-implementation` can be modified to implement a continuous handoff loop by inserting loop control after Stage 6 (metadata reading). The `requires_user_review` flag from task 885 provides the gating mechanism. Loop control should be added as a new Stage 6a between metadata parsing and status update.

## Findings

### 1. Current Skill Postflight Structure

Both implementation skills follow the same 11-stage flow:

| Stage | Purpose | Key Actions |
|-------|---------|-------------|
| 1 | Input Validation | Check task exists, status valid |
| 2 | Preflight Status Update | Set [IMPLEMENTING] |
| 3 | Create Postflight Marker | Prevent premature termination |
| 4 | Prepare Delegation Context | Build context JSON |
| 5 | Invoke Subagent | Task tool with agent type |
| 5a | Validate Return Format | Warn if JSON to console |
| **6** | **Parse Metadata File** | Read `.return-meta.json` |
| 7 | Update Task Status | Based on status field |
| 8 | Link Artifacts | Add to state.json |
| 9 | Git Commit | Stage and commit |
| 10 | Cleanup | Remove marker/metadata files |
| 11 | Return Summary | Brief text output |

**Insertion point**: After Stage 6 (Parse Metadata File), before Stage 7 (Update Task Status).

### 2. Metadata Integration Points

From task 885, the `requires_user_review` field is defined in `return-metadata-file.md`:

```json
{
  "status": "partial",
  "requires_user_review": false,  // Default: auto-continuable
  "partial_progress": {
    "stage": "phase_incomplete",
    "phases_completed": 2,
    "phases_total": 4
  }
}
```

The skill must check:
1. `status == "partial"` - Work is incomplete
2. `requires_user_review != true` (treat missing as false) - No hard blocker
3. Iteration count < max_iterations - Loop guard not exhausted

### 3. Handoff Context From Dependencies

**Task 883 (Incremental Handoff Architecture)**:
- Handoffs written to `specs/{N}_{SLUG}/handoffs/phase-{P}-handoff-{TIMESTAMP}.md`
- Metadata includes `handoff_path` in `partial_progress`
- Handoffs are ~40 lines with "Immediate Next Action" section

**Task 884 (Incremental Summary Updates)**:
- Summary file updated per phase at `specs/{N}_{SLUG}/summaries/implementation-summary-{DATE}.md`
- Contains Phase Log with session entries
- Tracks `phases_completed` / `phases_total`

For loop re-invocation, the successor subagent needs:
1. Plan path (unchanged)
2. Session ID (can reuse or generate new per iteration)
3. Resume point from `partial_progress.phases_completed`
4. Optional: handoff path for context exhaustion cases

### 4. Loop Stop Conditions

Based on blocker taxonomy from task 885:

| Condition | Action |
|-----------|--------|
| `status == "implemented"` | Exit loop, proceed to postflight |
| `status == "partial" && requires_user_review == true` | Exit loop, report blocker |
| `status == "partial" && requires_user_review != true` | Continue loop (re-invoke) |
| `status == "blocked"` | Exit loop, report blocker |
| `status == "failed"` | Exit loop, report failure |
| `iteration_count >= max_iterations` | Exit loop, report limit |

### 5. Loop Implementation Pattern

```bash
# Stage 6a: Continuous Handoff Loop
iteration_count=0
max_iterations=${MAX_ITERATIONS:-5}  # Configurable, default 5

while true; do
    iteration_count=$((iteration_count + 1))

    # Read metadata (from Stage 6)
    status=$(jq -r '.status' "$metadata_file")
    requires_review=$(jq -r '.requires_user_review // false' "$metadata_file")

    # Stop condition checks
    if [ "$status" == "implemented" ]; then
        break  # Success - proceed to postflight
    fi

    if [ "$status" == "blocked" ] || [ "$status" == "failed" ]; then
        break  # Hard failure
    fi

    if [ "$status" == "partial" ]; then
        if [ "$requires_review" == "true" ]; then
            break  # Hard blocker - user must review
        fi

        if [ "$iteration_count" -ge "$max_iterations" ]; then
            break  # Iteration limit reached
        fi

        # Auto-continue: re-invoke subagent
        # Update delegation context with:
        #   - resume_phase from partial_progress
        #   - handoff_path if present
        #   - incremented iteration in metadata

        # Re-invoke subagent (Stage 5)
        # Then re-read metadata (Stage 6)
        continue
    fi
done
```

### 6. Context Passage Between Iterations

Each iteration should pass to the successor:

| Field | Source | Purpose |
|-------|--------|---------|
| `resume_phase` | `partial_progress.phases_completed + 1` | Start from next incomplete phase |
| `handoff_path` | `partial_progress.handoff_path` (if present) | Context exhaustion handoff |
| `iteration` | Loop counter | Track for limit enforcement |
| `session_id` | Generate new per iteration | Git commit attribution |
| `plan_path` | Unchanged | Implementation plan |

### 7. Files to Modify

| File | Changes |
|------|---------|
| `.claude/skills/skill-implementer/SKILL.md` | Add Stage 6a loop after Stage 6 |
| `.claude/skills/skill-lean-implementation/SKILL.md` | Add Stage 6a loop after Stage 6 |
| `.claude/commands/implement.md` | Document auto-resume behavior |

### 8. Commit Strategy for Loop

Each iteration should commit its progress:
1. After each subagent returns partial, commit the phase progress
2. Clear metadata file for clean re-read on next iteration
3. Keep postflight marker until final exit

This prevents work loss if the loop is interrupted.

## Recommendations

### Phase 1: Add Loop Infrastructure

Add Stage 6a to both skill files:
- Loop control with max_iterations check
- Re-invocation logic with updated context
- Per-iteration commit for safety

### Phase 2: Update Delegation Context

Modify Stage 4 to accept:
- `resume_phase` for phase targeting
- `handoff_path` for context exhaustion
- `iteration` for debugging/logging

### Phase 3: Update implement.md

Add section documenting:
- Auto-resume behavior for partial completions
- Stop conditions (implemented, blocked, requires_user_review, iteration limit)
- How to disable (--no-loop flag or MAX_ITERATIONS=1)

### Phase 4: Add Loop Guards

Implement safety measures:
- `.postflight-loop-guard` file with iteration count
- Max iterations config (default 5)
- Exponential backoff if same error repeats

## Implementation Considerations

### Iteration Limit Rationale

The default of 5 iterations balances:
- Typical proof: 1-2 iterations sufficient
- Complex proof: 3-4 iterations for large phases
- Safety: Prevents infinite loops from oscillating failures

### Session ID Strategy

Two options:
1. **Single session**: Same session ID for all iterations (tracks related commits)
2. **Per-iteration**: New session ID per iteration (cleaner git history)

Recommendation: Use single session ID with iteration suffix (e.g., `sess_123_abc_iter2`)

### Error Accumulation

If multiple iterations fail with different errors:
- Accumulate errors in metadata across iterations
- On loop exit, report all accumulated errors
- This helps diagnose oscillating failures

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Infinite loop | Resource exhaustion | max_iterations guard (default 5) |
| Oscillating failures | Wasted iterations | Track error hashes, exit on repeat |
| Context exhaustion in skill | Skill hangs | Handoff written by agent, skill reads minimal |
| Lost progress | Work wasted | Per-iteration commits |

## Next Steps

Run `/plan 886` to create implementation plan with:
- Phase 1: Modify skill-implementer with loop
- Phase 2: Modify skill-lean-implementation with loop
- Phase 3: Update implement.md documentation
- Phase 4: Add loop guard file pattern
- Phase 5: Testing and verification

## References

- `.claude/skills/skill-implementer/SKILL.md` - Current skill structure (441 lines)
- `.claude/skills/skill-lean-implementation/SKILL.md` - Current skill structure (410 lines)
- `.claude/context/core/formats/return-metadata-file.md` - Metadata schema with requires_user_review
- `.claude/context/core/formats/handoff-artifact.md` - Handoff document schema
- `specs/884_incremental_summary_updates_per_phase/summaries/implementation-summary-20260216.md` - Task 884 summary
- `specs/885_blocker_detection_user_review_triggers/summaries/implementation-summary-20260216.md` - Task 885 summary
