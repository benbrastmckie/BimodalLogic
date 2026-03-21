# Research Report: Task #885

**Task**: 885 - Blocker Detection and User Review Triggers
**Date**: 2026-02-16
**Focus**: Define blocker types that require user review vs auto-continuable partial completions
**Session**: sess_1771308208_c8eb00

## Summary

This research identifies two categories of partial completions: (1) **soft blockers** that allow auto-continuation and (2) **hard blockers** that require user review. The existing metadata schema already supports `errors` array with `recoverable` field, but lacks a top-level signal for skills to check before auto-continuing. The recommended approach adds `requires_user_review` boolean with `review_reason` string to the metadata schema, and updates agent documentation with blocker detection guidance.

## Findings

### Current Metadata Schema Analysis

The existing `return-metadata-file.md` schema supports:

| Field | Purpose | Current Usage |
|-------|---------|---------------|
| `status` | Overall completion state | `partial`, `failed`, `blocked` for non-success |
| `errors[]` | Structured error list | Each error has `type`, `message`, `recoverable`, `recommendation` |
| `partial_progress` | Resume point tracking | `stage`, `details`, `phases_completed`, `phases_total`, `handoff_path` |

**Key Gap**: While individual errors have `recoverable: boolean`, there is no **top-level signal** that tells skills "do not auto-continue without user review." Skills currently only check `status == "partial"` and resume unconditionally.

### Blocker Taxonomy

Based on analysis of error-handling.md, agent definitions, and skill postflight patterns:

#### Soft Blockers (Auto-Continuable)

These are normal partial completions where `/implement` can safely resume:

| Blocker Type | Description | Example |
|--------------|-------------|---------|
| `timeout` | Operation exceeded time limit | Context exhaustion handoff |
| `context_exhaustion_handoff` | Agent approaching context limit | Normal handoff to successor |
| `phase_incomplete` | Phase not finished but progress made | Proof stuck at specific tactic |
| `mcp_transient` | MCP tool had transient failure | Network timeout, retry may succeed |

**Common Pattern**: The situation is recoverable by the system without human intervention. A successor agent can continue with the handoff.

#### Hard Blockers (Require User Review)

These are blockers where auto-continuation would be counterproductive:

| Blocker Type | Description | Example |
|--------------|-------------|---------|
| `mathematically_false` | Theorem/lemma appears to be false | Counterexample found, no proof exists |
| `missing_dependency` | Required external dependency unavailable | Missing library, axiom, or import |
| `unresolvable_build_error` | Build fails with no clear fix path | Type error in external dependency |
| `invalid_specification` | Task description or plan is flawed | Research shows approach is impossible |
| `resource_exhausted` | Critical resource permanently unavailable | Required MCP tool consistently failing |
| `strategy_failed` | All planned approaches exhausted | Tried all tactics in plan, none work |

**Common Pattern**: The situation requires human judgment to decide the next step. Auto-continuing would waste resources.

### Existing Error Recovery Patterns

From `error-handling.md`:

```json
{
  "errors": [
    {
      "type": "validation|execution|timeout",
      "message": "Error description",
      "recoverable": true,
      "recommendation": "How to fix"
    }
  ]
}
```

The `recoverable` field is per-error, not a top-level signal. Skills would need to iterate all errors to determine if any are non-recoverable.

### Skill Postflight Current Behavior

From `skill-implementer/SKILL.md` and `skill-lean-implementation/SKILL.md`:

**Stage 7: Update Task Status (Postflight)**

- If `status == "implemented"`: Update to "completed"
- If `status == "partial"`: Keep as "implementing", update resume point

**No check for "should we stop for user review?"**

Current pattern enables implicit auto-continuation:
```bash
# Next /implement invocation resumes
# No mechanism to block this for hard blockers
```

### Related Architecture: Task 883

Task 883 implemented incremental handoff architecture for context exhaustion. Key insight: context exhaustion is **expected**, not an error. The `partial_progress.stage = "context_exhaustion_handoff"` pattern enables successors to continue.

This task (885) addresses the inverse: when should the system NOT auto-continue?

## Recommendations

### 1. Schema Changes for return-metadata-file.md

Add two new optional fields at the top level:

```json
{
  "status": "partial",
  "requires_user_review": true,
  "review_reason": "Theorem appears mathematically false - counterexample found at line 342",
  ...
}
```

| Field | Type | When Required | Description |
|-------|------|---------------|-------------|
| `requires_user_review` | boolean | Optional (default false) | True if human must review before continuing |
| `review_reason` | string | Required if requires_user_review | 1-2 sentence explanation of why user review needed |

**Design Rationale**:
- Top-level field for fast skill check (no error array iteration)
- Explicit reason prevents "why did it stop?" confusion
- Boolean + reason pattern mirrors existing `recoverable + recommendation`

### 2. Skill Postflight Updates

Add check before auto-continuation message:

```bash
# In Stage 7, after reading metadata
requires_review=$(jq -r '.requires_user_review // false' "$metadata_file")
review_reason=$(jq -r '.review_reason // ""' "$metadata_file")

if [ "$requires_review" = "true" ]; then
    # Do NOT suggest auto-resume
    echo "USER REVIEW REQUIRED: $review_reason"
    echo "After resolving, run /implement $task_number to continue"
else
    # Normal partial - suggest resume
    echo "Run /implement $task_number to resume"
fi
```

### 3. Agent Detection Guidance

Add blocker detection section to lean-implementation-agent.md and general-implementation-agent.md:

#### Blocker Detection Criteria

Agents SHOULD set `requires_user_review: true` when:

1. **Proof appears impossible**: After exhausting planned approaches, no viable path found
2. **Counterexample identified**: Found concrete case where theorem is false
3. **Missing external dependency**: Required library, axiom, or import is unavailable
4. **Build fails with no fix path**: Error in code agent cannot modify
5. **Plan is invalid**: Research or implementation reveals plan cannot work
6. **Resource permanently unavailable**: MCP tool failing repeatedly with no alternative

Agents should NOT set this flag for:
- Normal timeout/context exhaustion
- Transient MCP failures
- Partial phase completion with clear next steps
- Handoff to successor

#### Decision Tree

```
Is the blocker fixable by a successor agent?
  └─ YES → Normal partial, do NOT set requires_user_review
  └─ NO → Requires human judgment?
       └─ NO → Failed status (not partial)
       └─ YES → Set requires_user_review: true with reason
```

### 4. Error Type Additions

Add new error types to error-handling.md for hard blockers:

```markdown
### Mathematical Errors
- `mathematically_false` - Theorem or lemma appears to be false
- `strategy_exhausted` - All planned approaches failed

### Specification Errors
- `invalid_specification` - Task description or plan is flawed
- `missing_dependency` - Required external dependency unavailable
```

## Schema Changes Summary

### return-metadata-file.md

**New optional fields**:

```json
{
  "requires_user_review": true,
  "review_reason": "Brief explanation of why user review is needed"
}
```

**Include if**: Agent encounters a hard blocker (see taxonomy above)

**Effect**: Skill postflight checks this flag before suggesting auto-resume

### lean-implementation-agent.md

**Add section**: "Blocker Detection"
- Criteria for setting `requires_user_review`
- Decision tree for soft vs hard blockers
- Examples of each blocker type

**Add to MUST DO**:
- "Set `requires_user_review: true` with `review_reason` when encountering hard blockers"

### general-implementation-agent.md

**Add section**: "Blocker Detection"
- Same structure as lean agent
- Language-appropriate examples (build errors, missing dependencies)

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Over-flagging (too many user reviews) | Medium | Clear criteria list, examples of what NOT to flag |
| Under-flagging (missing hard blockers) | Low | Conservative default is to flag uncertain cases |
| Agent confusion on when to flag | Medium | Decision tree with concrete examples |
| Schema migration for existing metadata | Low | Field is optional, old metadata works unchanged |

## Next Steps

Run `/plan 885` to create implementation plan with phases:
1. Update return-metadata-file.md schema
2. Update lean-implementation-agent.md with blocker detection
3. Update general-implementation-agent.md with blocker detection
4. Update skill postflight patterns (skill-implementer, skill-lean-implementation)
5. Update error-handling.md with new error types

## References

- `.claude/context/core/formats/return-metadata-file.md` - Current metadata schema
- `.claude/agents/lean-implementation-agent.md` - Lean agent definition
- `.claude/agents/general-implementation-agent.md` - General agent definition
- `.claude/rules/error-handling.md` - Error taxonomy and recovery patterns
- `.claude/skills/skill-implementer/SKILL.md` - General skill postflight
- `.claude/skills/skill-lean-implementation/SKILL.md` - Lean skill postflight
- Task 883 - Incremental handoff architecture (context exhaustion handling)
