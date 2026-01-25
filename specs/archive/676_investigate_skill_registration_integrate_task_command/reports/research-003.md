# Research Findings: Task #676 Plan Revision

**Date**: 2026-01-25
**Focus**: Why preflight/postflight fail when skills invoke subagents
**Session**: sess_1769375878_e93b61

## User Clarifications Incorporated

1. Do NOT archive .opencode/ - preserve as-is
2. Skills ARE being invoked (not bypassed via simulation code)
3. ACTUAL problem: preflight/postflight don't reliably execute when skills invoke subagents
4. Do not rely on hooks unless required

---

## Root Cause Analysis

### The Real Problem: GitHub Issue #17351

**Finding**: Claude Code has a known architectural limitation documented in Issue #17351:
- When a skill invokes another skill or spawns a subagent via Task tool, control does NOT return to the invoking skill
- Instead, control returns to the **main session context**
- This means postflight code written in the skill NEVER executes

**Evidence from Documentation**:
```
Claude Code has a known limitation (GitHub Issue #17351): nested skills return
to the main session instead of the invoking skill. This causes workflow
interruptions requiring user "continue" input between skill return and
orchestrator postflight.
```
Source: `.claude/context/core/patterns/postflight-control.md` (line 9)

### Current Architecture Flow (BROKEN)

```
User invokes /research 123
    |
    v
skill-researcher executes:
  - Stage 1: Input Validation        [RUNS]
  - Stage 2: Preflight Update        [RUNS]
  - Stage 3: Create Postflight Marker [RUNS]
  - Stage 4: Prepare Delegation      [RUNS]
  - Stage 5: Invoke Subagent (Task)  [RUNS]
    |
    +---> general-research-agent     [RUNS, COMPLETES]
    |         |
    |         v
    |     Returns to MAIN SESSION (Issue #17351)
    |
  - Stage 6: Parse Return            [NEVER RUNS]
  - Stage 7: Update Status           [NEVER RUNS]
  - Stage 8: Link Artifacts          [NEVER RUNS]
  - Stage 9: Git Commit              [NEVER RUNS]
  - Stage 10: Cleanup                [NEVER RUNS]
  - Stage 11: Return                 [NEVER RUNS]
```

**Result**: Task stuck in [RESEARCHING], artifacts created but not linked, no git commit.

### Current Hook-Based Workaround (PARTIALLY WORKING)

The project has implemented SubagentStop hooks to address this:

```json
"SubagentStop": [
  {
    "matcher": "*",
    "hooks": [
      {
        "type": "command",
        "command": "bash .claude/hooks/subagent-postflight.sh"
      }
    ]
  }
]
```

**Why hooks alone are insufficient**:
1. Hooks fire in the main session context, not the skill context
2. Hook has no access to skill's local variables (session_id, task_number, etc.)
3. Hook must re-derive all context from marker files
4. Race conditions possible if marker files are stale
5. Loop guards add complexity (max 3 continuations)

---

## Architecture Options Analysis

### Option A: Continue With Hooks (Current Path)

**How it works**:
- Skill creates `.postflight-pending` marker before invoking subagent
- SubagentStop hook blocks premature termination
- Hook reads marker, performs postflight operations

**Pros**:
- Already partially implemented
- Works with Claude Code's architecture

**Cons**:
- Hook executes in wrong context (main session, not skill)
- Must pass all state via marker files
- Complex error recovery
- User reports it "doesn't always work reliably"
- Three-iteration loop guard is a symptom of fragility

**Verdict**: Current implementation is correct but unreliable. The unreliability likely stems from:
1. Marker file race conditions
2. Context loss between skill and hook
3. Loop guard triggering incorrectly

### Option B: Skills Handle Everything Inline (No Subagents)

**How it works**:
- Skills do NOT spawn subagents via Task tool
- Skills execute all work inline in their own context
- Preflight/postflight execute naturally in sequence

**Pros**:
- No Issue #17351 problem (no subagent return)
- Simpler control flow
- Reliable execution

**Cons**:
- Skills cannot delegate to specialized agents
- All context loaded into main conversation
- Defeats purpose of subagent architecture
- Cannot use parallel execution

**Verdict**: Viable for simple commands but sacrifices agent specialization.

### Option C: Commands Handle Checkpoints, Skills Execute Work

**How it works**:
- Commands (markdown files) handle GATE IN and GATE OUT
- Commands invoke skills for the actual work
- Skills do NOT handle preflight/postflight (commands do)
- Commands validate skill completion via metadata files

```
/research.md:
  1. GATE IN: Update status, generate session_id
  2. DELEGATE: Invoke skill-researcher
  3. GATE OUT: Read .return-meta.json, update status, link artifacts
  4. COMMIT: Git commit
```

**Pros**:
- Checkpoints execute in stable context (command context)
- Issue #17351 doesn't affect commands
- Skills stay focused on research/planning/implementation
- Clean separation of concerns

**Cons**:
- Requires restructuring existing skills
- Skills must write metadata files reliably
- Commands become more complex

**Verdict**: Best structural fix. Moves checkpoint responsibility to stable context.

### Option D: Subagent-Scoped PostToolUse Hooks

**How it works**:
- Define PostToolUse hooks scoped to specific subagents
- Hooks fire after subagent completes, still in skill context
- Use hooks to trigger postflight operations

**Evidence from Claude Code docs**:
```yaml
hooks:
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "./scripts/run-linter.sh"
```

**Problem**: PostToolUse hooks fire AFTER each tool use, not after subagent completion. The subagent uses many tools internally. This doesn't solve the return-to-main-session issue.

**Verdict**: Does not address Issue #17351.

---

## Recommended Solution: Option C (Commands Handle Checkpoints)

### Architectural Principle

**Move checkpoint responsibility UP the call stack to a stable context**:
- Commands execute in the main conversation context
- Commands don't have the "return to wrong context" problem
- Commands can reliably read metadata files after skill completes

### Implementation Pattern

**Command Responsibility** (in .md file):
```markdown
## Execution

### CHECKPOINT 1: GATE IN
1. Generate session_id
2. Read task from state.json
3. Validate status allows operation
4. Update state.json to [RESEARCHING]
5. Update TODO.md to [RESEARCHING]
6. Record session_id for later

### STAGE 2: DELEGATE
Invoke skill-researcher with:
- task_number
- session_id
- focus_prompt

The skill:
- Invokes general-research-agent
- Agent writes metadata to .return-meta.json
- Agent returns brief summary

### CHECKPOINT 2: GATE OUT
After skill returns:
1. Read specs/{N}_{SLUG}/.return-meta.json
2. Validate metadata matches expected schema
3. Verify artifacts exist and are non-empty
4. Update state.json to [RESEARCHED]
5. Update TODO.md to [RESEARCHED]
6. Link artifacts in state.json and TODO.md

### CHECKPOINT 3: COMMIT
Git commit with session_id
```

**Skill Responsibility** (simplified):
```markdown
# skill-researcher

## Execution

1. Validate inputs
2. Invoke general-research-agent via Task tool
3. Return agent's brief summary

## NO Preflight/Postflight
Commands handle all status updates.
This skill focuses only on orchestrating research.
```

### Why This Works

1. **Commands execute in main context**: No subagent return issue
2. **Skills stay simple**: Just orchestrate agent execution
3. **Agents stay unchanged**: Still write metadata files
4. **Checkpoints are guaranteed**: Command context is stable
5. **No hooks required**: Natural execution flow

### Migration Path

**Phase 1**: Modify one command (/research) as proof of concept
1. Move preflight operations from skill to command
2. Simplify skill-researcher to just invoke agent
3. Move postflight operations from skill to command
4. Test end-to-end

**Phase 2**: Apply pattern to /plan and /implement

**Phase 3**: Remove obsolete hook code (SubagentStop, marker files)

---

## Alternative Refinement: Fix Hook Reliability

If migrating to Option C is too disruptive, improve current hooks:

### Issue 1: Context Loss
**Fix**: Write ALL needed context to marker file
```json
{
  "session_id": "...",
  "task_number": 123,
  "project_name": "task_slug",
  "expected_metadata": "specs/123_task_slug/.return-meta.json",
  "preflight_completed": true,
  "original_status": "not_started"
}
```

### Issue 2: Race Conditions
**Fix**: Add file locking or use atomic operations
```bash
# Use mv for atomic writes
echo '...' > /tmp/marker.$$ && mv /tmp/marker.$$ specs/.postflight-pending
```

### Issue 3: Loop Guard Fragility
**Fix**: More robust completion detection
```bash
# Check if metadata file exists AND has expected session_id
if [ -f "$metadata_file" ] && jq -e ".metadata.session_id == \"$expected_sid\"" "$metadata_file"; then
  # Legitimate completion
else
  # Not ready yet
fi
```

---

## Key Questions Answered

**Q: Why do preflight/postflight sometimes not execute?**
A: Issue #17351 - subagent returns to main session, not invoking skill. Postflight code in skill never runs.

**Q: What's the recommended Claude Code 2026 pattern?**
A: Commands should handle orchestration (checkpoints). Skills should delegate to agents. Agents do the work. See Option C.

**Q: Are hooks required?**
A: Not if commands handle checkpoints. Hooks are a workaround for the subagent return issue, not a fundamental requirement.

**Q: How should state updates be structured for reliability?**
A: Move them to the command level where they execute in a stable context, not inside skills that delegate to subagents.

---

## Actionable Recommendations for Plan v3

1. **Remove Phases for .opencode archival** - User wants to preserve it

2. **Change root cause framing**: From "simulation code" to "checkpoint operations in wrong context"

3. **Add Phase: Migrate checkpoints to commands**
   - Move preflight from skill to command
   - Move postflight from skill to command
   - Skills become thin wrappers that just invoke agents

4. **Simplify skills**:
   - Remove 11-stage pattern from skills
   - Skills: validate inputs, invoke agent, return result
   - Commands: all checkpoint operations

5. **Optional: Remove hook complexity**
   - If Option C works, SubagentStop hooks become unnecessary
   - Marker files become unnecessary
   - Loop guards become unnecessary

6. **Test approach with /research first**
   - Lowest risk command to modify
   - Validates pattern before wider rollout

---

## References

- Claude Code Subagents Documentation: https://code.claude.com/docs/en/sub-agents
- GitHub Issue #17351: Nested skills return to main session
- `.claude/context/core/patterns/postflight-control.md` - Current hook pattern
- `.claude/context/core/troubleshooting/workflow-interruptions.md` - Known issues
- `.claude/skills/skill-researcher/SKILL.md` - Current 11-stage pattern
- `.claude/hooks/subagent-postflight.sh` - Current hook implementation
