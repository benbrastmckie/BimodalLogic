# Research Report: Task #462

**Task**: Fix workflow command delegation
**Date**: 2026-01-12
**Session ID**: sess_1768279142_430ffb
**Focus**: Root cause analysis for /research and /implement stopping after preflight

## Summary

The /research and /implement commands complete their CHECKPOINT 1 (GATE IN) via skill-status-sync but fail to proceed to STAGE 2 delegation. The root cause is that command files describe workflow as documentation but lack executable instructions that clearly direct Claude to continue execution after preflight. The /meta command works because it directly delegates without a preflight phase, demonstrating the pattern needed.

## Findings

### 1. Command File Structure Analysis

**research.md and implement.md** (failing):
```markdown
### CHECKPOINT 1: GATE IN
4. **Update Status (via skill-status-sync)**
   Invoke skill-status-sync: `preflight_update(task_number, "researching", session_id)`

### STAGE 2: DELEGATE
Invoke skill with:
- task_number: {N}
- focus_prompt: {optional focus}
- session_id: {session_id}
```

**Problem**: The "Invoke skill with" is descriptive documentation, not an executable instruction. Claude interprets this as describing what *should* happen, not what Claude *must do*.

**meta.md** (working):
```markdown
### 2. Delegate to Skill
Invoke skill-meta via Skill tool with:
- Mode (interactive, prompt, or analyze)
- Prompt (if provided)
```

**Difference**: /meta has no preflight checkpoint that could be mistaken as "completion" - it immediately delegates after mode detection.

### 2. Execution Flow Problem

The command lifecycle intends:
```
CHECKPOINT 1 (GATE IN) -> STAGE 2 (DELEGATE) -> CHECKPOINT 2 (GATE OUT) -> CHECKPOINT 3 (COMMIT)
```

What actually happens:
```
CHECKPOINT 1 (GATE IN) -> [STOP]
```

Claude completes skill-status-sync for preflight and then stops because:
1. The status update succeeds (task marked [RESEARCHING])
2. No explicit "now continue to STAGE 2" instruction
3. The descriptive "Invoke skill with" pattern doesn't trigger action

### 3. Skill Tool Integration

The `allowed-tools` header correctly includes `Skill`:
```yaml
allowed-tools: Skill, Bash(jq:*), Bash(git:*), Read, Edit
```

But the body text "Invoke skill with:" is ambiguous. Compare to working patterns:
- `/meta`: "Invoke skill-meta via Skill tool"
- skill-researcher.md: "Invoke `general-research-agent` via Task tool"

### 4. Two-Phase Execution Pattern

The checkpoint-based model requires skills that:
1. Complete preflight (skill-status-sync)
2. Proceed to core work (skill-researcher or skill-lean-research)
3. Complete postflight (skill-status-sync again)
4. Commit changes

The command files document this but don't enforce continuation between phases.

### 5. Evidence from skill-status-sync

skill-status-sync returns:
```json
{
  "status": "completed",
  "summary": "Updated task #N to [STATUS]"
}
```

This successful return may be interpreted as "command complete" rather than "preflight complete, continue to next stage."

### 6. Comparison with Thin Wrapper Skills

The thin wrapper skill pattern (skill-researcher, skill-implementer) works correctly when invoked directly. The issue is in the command -> skill transition, not the skill -> agent transition.

```
/research -> [PREFLIGHT via skill-status-sync] -> [STOP]
                                                   |
                                                   X should continue to
                                                   v
                                            skill-researcher -> general-research-agent
```

## Root Cause

**Command files use descriptive language instead of imperative instructions for STAGE 2 delegation.** After completing preflight, Claude has no clear directive to continue execution. The command file reads as documentation rather than an executable script.

## Recommendations

### Option A: Add Explicit Continuation Instruction (Minimal Change)

Add explicit "CONTINUE TO STAGE 2" directive after preflight:

```markdown
### CHECKPOINT 1: GATE IN
[existing content]

**GATE IN COMPLETE - PROCEED TO STAGE 2**

### STAGE 2: DELEGATE

**Execute Now**: Use the Skill tool to invoke the appropriate research skill:

For `lean` language tasks:
```
Skill(skill: "skill-lean-research", args: "task_number={N} session_id={session_id}")
```

For other languages:
```
Skill(skill: "skill-researcher", args: "task_number={N} focus={focus} session_id={session_id}")
```
```

### Option B: Restructure Command as Single Skill Delegation (Recommended)

Consolidate the three-checkpoint pattern into a single orchestrating skill:

1. Create `skill-research-orchestrator` that:
   - Performs GATE IN (preflight)
   - Delegates to skill-researcher or skill-lean-research
   - Performs GATE OUT (postflight)
   - Creates git commit

2. Simplify command to single delegation:
```markdown
### Execution

Invoke skill-research-orchestrator via Skill tool with:
- task_number: {N}
- focus_prompt: {optional}
```

This matches the /meta pattern which works successfully.

### Option C: Add Skill Invocation Code Block

Make the skill invocation explicit and executable:

```markdown
### STAGE 2: DELEGATE

**EXECUTE THIS STEP**:

Determine target skill by language:
| lean | skill-lean-research |
| other | skill-researcher |

Invoke using Skill tool:
```python
# Execute this delegation
result = Skill(
    skill="skill-researcher",  # or skill-lean-research for lean tasks
    args=f"task_number={task_number} session_id={session_id}"
)
```

Then proceed to CHECKPOINT 2 with the result.
```

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Option A is still ambiguous | May not fully fix | Test before committing |
| Option B requires new skill | More files to maintain | Reuse existing skill patterns |
| Changes break working commands | Regression | Test /meta still works |
| Session ID not passed correctly | Lost traceability | Verify in skill invocation |

## Decision

**Recommendation: Option A (minimal change) as immediate fix, consider Option B for future consolidation.**

Option A requires the least change and directly addresses the root cause. The key insight is that Claude needs imperative instructions ("Execute Now: Use the Skill tool") not descriptive statements ("Invoke skill with").

## Next Steps

1. Create implementation plan with phased approach:
   - Phase 1: Fix /research command with explicit Skill invocation
   - Phase 2: Fix /implement command similarly
   - Phase 3: Test both commands work end-to-end
   - Phase 4: Update documentation to clarify command patterns

2. Run `/plan 462` to create detailed implementation plan

## Appendix

### Files Examined

**Command files**:
- `.claude/commands/research.md` - Lines 1-121
- `.claude/commands/implement.md` - Lines 1-176
- `.claude/commands/meta.md` - Lines 1-190

**Skill files**:
- `.claude/skills/skill-researcher/SKILL.md`
- `.claude/skills/skill-implementer/SKILL.md`
- `.claude/skills/skill-status-sync/SKILL.md`
- `.claude/skills/skill-meta/SKILL.md`
- `.claude/skills/skill-orchestrator/SKILL.md`

**Context files**:
- `.claude/context/core/checkpoints/README.md`
- `.claude/context/core/checkpoints/checkpoint-gate-in.md`
- `.claude/context/core/workflows/command-lifecycle.md`
- `.claude/context/core/orchestration/delegation.md`
- `.claude/context/core/templates/thin-wrapper-skill.md`

**Agent files**:
- `.claude/agents/general-research-agent.md`

### Search Queries Used

1. Glob: `.claude/skills/**/*.md` - Found 10 skill files
2. Glob: `.claude/commands/**/*.md` - Found 9 command files
3. Glob: `.claude/context/core/**/*.md` - Found 47 context files
4. Read: All key files for command, skill, and checkpoint patterns
