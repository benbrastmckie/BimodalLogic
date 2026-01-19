# Research Report: Task #621

**Task**: 621 - Analyze Plan Errors and Improve Agent Execution
**Started**: 2026-01-19T12:30:00Z
**Completed**: 2026-01-19T12:45:00Z
**Effort**: 1 hour
**Priority**: High
**Dependencies**: None
**Sources/Inputs**:
- .claude/output/plan.md (execution log)
- .claude/skills/skill-planner/SKILL.md
- .claude/agents/planner-agent.md
- .claude/context/core/patterns/*.md (jq-escaping-workarounds, postflight-control, inline-status-update)
- .claude/rules/*.md (state-management, workflows, error-handling)
**Artifacts**: specs/621_analyze_plan_errors_improve_agent_execution/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

Analysis of `/plan 607` execution log reveals a **documented but not consistently applied** jq escaping bug (Claude Code Issue #1132) causing postflight failures. The skill-planner attempted to use jq patterns with `select(.type != "plan")` which triggers Claude Code's `< /dev/null` injection bug. Despite having documented workarounds in `jq-escaping-workarounds.md`, the skill definition file does not reference or enforce these patterns.

**Key Findings**:
1. The jq escaping bug is well-documented but skills don't consistently use the two-step workaround
2. Skill-planner eventually recovered using a file-based jq approach, demonstrating ad-hoc recovery
3. The system lacks enforcement mechanisms to ensure documented patterns are followed
4. Error logging to errors.json did not capture the jq failures
5. The overall operation succeeded despite multiple errors, showing resilience but wasting tokens

**Recommended Approach**:
1. Add explicit references to jq-escaping-workarounds.md in all skills that use jq
2. Create reusable shell scripts for common postflight patterns
3. Improve error logging to capture jq failures with session tracking

## Context & Scope

This research analyzes errors observed in the `/plan 607` command execution, specifically:
- Multiple jq parse errors during postflight status updates
- Error recovery patterns that succeeded after retries
- Gap between documented patterns and actual skill implementations

The plan.md file captures a complete `/plan` command execution with visible error output from lines 78-114 showing 3 failed jq attempts before success.

## Findings

### 1. Error Pattern Analysis

**Error Location**: Lines 78-114 of plan.md

**Error Type**: jq syntax errors from Claude Code Bash tool injection bug

**Error Messages**:
```
jq: error: syntax error, unexpected INVALID_CHARACTER, expecting ';' or ')'
jq: error: try .["field"] instead of .field for unusually named fields
jq: 2 compile errors
```

**Root Cause**: The jq filter attempted to use:
```jq
artifacts: ([.artifacts // [] | .[] | select(.type \!= "plan")] + [...])
```

This pattern contains a pipe (`|`) inside a quoted string that triggers Claude Code Issue #1132. The Bash tool injects `< /dev/null` into the command, corrupting the jq expression.

**Recovery Method**: After 3 failed attempts, the skill used a file-based approach:
```bash
cat > /tmp/update_state.jq << 'JQEOF'
(.active_projects[] | select(.project_number == 607)) |= . + {...}
JQEOF
```

This workaround succeeded because the jq filter is written to a file first, avoiding the shell pipe interpretation.

### 2. Documentation vs Implementation Gap

**Documented Pattern** (jq-escaping-workarounds.md lines 30-50):
```bash
# Two-Step Approach (Recommended)
# Step 1: Update status and timestamps (no artifact manipulation)
jq --arg ts "..." --arg status "planned" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: $status, last_updated: $ts, planned: $ts
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json

# Step 2: Update artifacts separately
jq --arg path "$artifact_path" \
  '(.active_projects[] | select(.project_number == '$task_number')).artifacts = ...'
```

**Actual Implementation** (skill-planner SKILL.md lines 203-214):
```bash
# Uses problematic single-step pattern
jq --arg path "$artifact_path" \
   --arg type "$artifact_type" \
   --arg summary "$artifact_summary" \
  '(.active_projects[] | select(.project_number == '$task_number')).artifacts =
    ([(.active_projects[] | select(.project_number == '$task_number')).artifacts // [] | .[] | select(.type != "plan")] +
     [{"path": $path, "type": $type, "summary": $summary}])'
```

**Gap**: The skill-planner SKILL.md doesn't reference jq-escaping-workarounds.md and uses the problematic pattern that's explicitly marked as "BROKEN" in the workarounds document.

### 3. Skills Lacking Workaround References

Examined skills that use jq for state updates:

| Skill | Uses jq | References Workarounds | Status |
|-------|---------|------------------------|--------|
| skill-planner | Yes | No | Vulnerable |
| skill-status-sync | Yes | No | Vulnerable |
| skill-lean-research | Unknown | N/A | Needs audit |
| skill-researcher | Unknown | N/A | Needs audit |
| skill-implementer | Unknown | N/A | Needs audit |

### 4. Error Logging Gap

**Observed**: The jq failures were NOT logged to errors.json
**Expected**: All errors during command execution should be logged with session_id

The errors.json file only has one entry from 2026-01-15 (git_commit_failure), and the session_id format doesn't match current patterns.

**Current Error Schema** (from errors.json):
```json
{
  "id": "err_{timestamp}",
  "type": "error_type",
  "context": { "session_id": "...", "command": "...", "checkpoint": "..." },
  "trajectory": { "delegation_path": [...] },
  "fix_status": "unfixed"
}
```

The jq failures would benefit from a new error type: `jq_parse_failure` with fields for:
- Original jq command attempted
- Error message from jq
- Recovery action taken
- Success/failure of recovery

### 5. Resilience Patterns Observed

**Positive**: The system demonstrated resilience through:
1. Multiple retry attempts with different approaches
2. Eventually succeeding via file-based jq workaround
3. Completing the full command lifecycle despite errors
4. Proper cleanup of postflight markers

**Negative**: This resilience came at the cost of:
1. Wasted tokens on failed attempts (~3 jq calls)
2. No error logging for future prevention
3. Ad-hoc recovery rather than prescribed pattern

### 6. Postflight Control Pattern Effectiveness

The `specs/.postflight-pending` marker file pattern successfully prevented workflow interruption:
- Marker created at line 56-58
- Subagent completed and returned
- Postflight operations executed despite errors
- Marker cleaned up at lines 159-162

This indicates the postflight control pattern is working as designed.

## Recommendations

### Immediate Actions (High Priority)

1. **Update skill-planner SKILL.md**
   - Add context reference to jq-escaping-workarounds.md
   - Replace Stage 8 artifact linking with two-step pattern
   - Add explicit note: "Use two-step jq pattern - see jq-escaping-workarounds.md"

2. **Update skill-status-sync SKILL.md**
   - Same changes as skill-planner
   - This skill is the canonical status update mechanism

3. **Audit all skills using jq**
   - Search for `jq` usage in all SKILL.md files
   - Verify workaround patterns are used
   - Add references where missing

### Short-Term Actions (Medium Priority)

4. **Create reusable shell scripts**
   - `.claude/scripts/postflight-research.sh`
   - `.claude/scripts/postflight-plan.sh`
   - `.claude/scripts/postflight-implement.sh`

   These scripts would encapsulate the correct two-step jq patterns, reducing copy/paste errors.

5. **Improve error logging in skills**
   - Add error logging for jq failures
   - Include session_id for correlation
   - Log both failure and recovery attempts

### Long-Term Actions (Lower Priority)

6. **Consider Python-based state updates**
   - jq shell escaping is fundamentally fragile
   - Python script could be more reliable
   - Would need `.claude/scripts/update-state.py`

7. **Add pre-commit hook for skill validation**
   - Warn if jq patterns don't match known-safe templates
   - Ensure workaround references are present

## Decisions

1. **Do not change jq-escaping-workarounds.md** - It already documents the correct patterns
2. **Focus on skill enforcement** - The gap is implementation, not documentation
3. **Prioritize skill-planner first** - Highest usage, most visible failures
4. **Log jq errors even when recovered** - Helps track pattern effectiveness

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Skills continue using broken patterns | High - repeated failures | High - no enforcement | Add explicit references and audit |
| Shell scripts introduce new bugs | Medium | Low | Test scripts thoroughly before deployment |
| Python solution adds complexity | Medium | Medium | Keep as optional improvement |
| More errors go unlogged | Low | High currently | Add error logging to skills |

## Appendix

### Search Queries Used

1. `Glob(".claude/skills/**/*.md")` - Found 12 skill files
2. `Glob(".claude/agents/**/*.md")` - Found 8 agent files
3. `Glob(".claude/context/core/patterns/*.md")` - Found 9 pattern files
4. `Read` of key files: skill-planner, planner-agent, skill-status-sync, jq-escaping-workarounds.md

### Files Examined

- `/home/benjamin/Projects/ProofChecker/.claude/output/plan.md` - Primary error source
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-planner/SKILL.md` - Vulnerable pattern
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-status-sync/SKILL.md` - Vulnerable pattern
- `/home/benjamin/Projects/ProofChecker/.claude/agents/planner-agent.md` - Subagent definition
- `/home/benjamin/Projects/ProofChecker/.claude/context/core/patterns/jq-escaping-workarounds.md` - Correct patterns
- `/home/benjamin/Projects/ProofChecker/.claude/context/core/patterns/postflight-control.md` - Marker protocol
- `/home/benjamin/Projects/ProofChecker/.claude/context/core/patterns/inline-status-update.md` - Update patterns
- `/home/benjamin/Projects/ProofChecker/.claude/rules/state-management.md` - State rules
- `/home/benjamin/Projects/ProofChecker/.claude/rules/workflows.md` - Workflow patterns
- `/home/benjamin/Projects/ProofChecker/.claude/rules/error-handling.md` - Error patterns
- `/home/benjamin/Projects/ProofChecker/specs/errors.json` - Error log (gap observed)

### Error Pattern from plan.md

Lines 78-114 show the progression:
```
Attempt 1: select(.type \!= "plan") - INVALID_CHARACTER error
Attempt 2: select(.type \!= "plan") - Same error (retry without fix)
Attempt 3: select(.type | . \!= "plan") - Still fails
Attempt 4: File-based jq approach - SUCCESS
```

This shows the LLM attempting variations of the broken pattern before discovering the file workaround independently.
