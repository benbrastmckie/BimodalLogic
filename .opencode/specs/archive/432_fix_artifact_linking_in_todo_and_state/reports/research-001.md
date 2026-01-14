# Research Report: Task #432

**Task**: Fix artifact linking in TODO.md and state.json
**Date**: 2026-01-12
**Focus**: Identify root cause of missing Summary link in task 429 and systematic artifact linking failures

## Summary

The artifact linking failure for task 429 stems from a gap between documented instructions and actual execution. While skill-status-sync documents the patterns and commands reference the patterns, there is no enforced mechanism to ensure artifact links are added to TODO.md. The state.json correctly records artifacts, but the TODO.md artifact linking step is effectively optional and often skipped.

## Findings

### 1. Verified Issue: Task 429 Summary Link Missing

**Evidence**:
- state.json correctly contains all 3 artifacts for task 429:
  - `research-001.md` (type: research)
  - `implementation-001.md` (type: plan)
  - `implementation-summary-20260112.md` (type: summary)
- TODO.md task 429 entry only has 2 links:
  - Research link: present
  - Plan link: present
  - **Summary link: MISSING**

The implementation completed successfully (summary file exists at `.claude/specs/429_extend_command_skill_agent_integration_to_meta/summaries/implementation-summary-20260112.md`) but the link was never added to TODO.md.

### 2. Architecture Gap Analysis

#### What's Documented (command files)

**implement.md Step 8** says:
```
**TODO.md** (via Edit tool):
- Update status marker to `[COMPLETED]`
- Add Completed date
- Add Summary link
```

**research.md Step 6** says:
```
**TODO.md** (via Edit tool):
- Update status marker to `[RESEARCHED]`
- Add research report link if not already present
```

**plan.md Step 7** says:
```
**TODO.md** (via Edit tool):
- Update status marker to `[PLANNED]`
- Add plan link if not already present
```

#### What's Actually Happening

The command files provide high-level instructions but:
1. No explicit Edit patterns (old_string/new_string) for artifact linking
2. No error handling if artifact linking fails
3. No verification that link was added

The commands primarily focus on:
- Updating status marker (consistently implemented)
- Adding artifact to state.json (handled by subagents)
- Git commits (consistently implemented)

The "Add [X] link" instruction is treated as optional/implicit rather than a required step with verification.

### 3. Prior Fix (Task 386) Was Documentation-Only

Task 386 "fixed" artifact linking by adding detailed documentation to skill-status-sync:
- Added TODO.md artifact linking patterns (lines 164-261)
- Added verification patterns (lines 263-326)
- Documented Edit tool patterns for each artifact type

However, the fix was **documentation only** - it documents HOW to link artifacts but doesn't enforce WHEN or WHERE to link them. The skill-status-sync is referenced by commands but not invoked with artifact_add operations.

### 4. Root Cause: Missing Artifact Linking Enforcement

The fundamental issue is that artifact linking is:
1. **Documented in skill-status-sync** but not consistently invoked
2. **Mentioned in command files** but as prose instructions, not enforced steps
3. **Not verified** after supposed execution

The subagents (general-implementation-agent, etc.) return artifacts in their JSON response, but the commands don't have explicit postflight logic to:
1. Extract artifacts from subagent return
2. Add each artifact to state.json via jq
3. Add each artifact link to TODO.md via Edit
4. Verify links were added

### 5. Specific Gap in /implement Command

The implement.md command flow:
1. Step 5: Update status to IMPLEMENTING (works)
2. Step 6: Invoke skill (works, subagent returns artifacts)
3. Step 7: Handle skill result (just checks status)
4. Step 8: Update status to COMPLETED (partially works)
   - Status update: works
   - Completed date: sometimes
   - **Summary link: NOT IMPLEMENTED**
5. Step 9: Git commit (works)

Step 8's "Add Summary link" is an instruction with no implementation details.

### 6. State.json Artifact Tracking Works

The subagents correctly add artifacts to state.json. This is likely done within the subagent execution or by skill-status-sync patterns being followed for state.json (the jq patterns are explicit and easy to execute).

The problem is specifically with TODO.md artifact linking, which requires:
1. Finding the correct task entry
2. Determining correct insertion point
3. Using Edit tool with correct old_string/new_string
4. Handling edge cases (existing links, multiple artifacts)

This is more complex than jq operations on state.json.

### 7. Similar Issues Across Commands

This is not isolated to /implement:
- /research: "Add research report link if not already present" - vague instruction
- /plan: "Add plan link if not already present" - vague instruction
- /implement: "Add Summary link" - vague instruction

All three suffer from the same gap between documentation and enforcement.

## Recommendations

### 1. Add Explicit Artifact Linking Step to Commands

Each command should have an explicit artifact linking step AFTER receiving subagent return:

```markdown
### N+1. Link Artifacts to TODO.md

For each artifact in skill result:

**Add to state.json** (via jq):
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg path "{artifact_path}" \
   --arg type "{artifact_type}" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    last_updated: $ts,
    artifacts: ((.artifacts // []) + [{"path": $path, "type": $type}])
  }' .claude/specs/state.json > /tmp/state.json && \
  mv /tmp/state.json .claude/specs/state.json
```

**Add to TODO.md** (via Edit tool):
- Use skill-status-sync patterns for artifact type
- Find insertion point after Language/Research/Plan line
- Add formatted link
```

### 2. Create Explicit Edit Patterns Per Command

**implement.md** should include:
```markdown
For summary artifact, use Edit tool:
- old_string: "- **Plan**: [implementation-{NNN}.md]({plan_path})"
- new_string: "- **Plan**: [implementation-{NNN}.md]({plan_path})\n- **Summary**: [implementation-summary-{DATE}.md]({summary_path})"
```

**research.md** should include:
```markdown
For research artifact, use Edit tool:
- old_string: "- **Language**: {language}"
- new_string: "- **Language**: {language}\n- **Research**: [research-{NNN}.md]({research_path})"
```

**plan.md** should include:
```markdown
For plan artifact, use Edit tool:
- old_string: "- **Research**: [research-{NNN}.md]({research_path})"
- new_string: "- **Research**: [research-{NNN}.md]({research_path})\n- **Plan**: [implementation-{NNN}.md]({plan_path})"

Or if no research link exists:
- old_string: "- **Language**: {language}"
- new_string: "- **Language**: {language}\n- **Plan**: [implementation-{NNN}.md]({plan_path})"
```

### 3. Add Artifact Link Verification Step

After artifact linking, verify links exist:
```markdown
### N+2. Verify Artifact Links

For each artifact path in skill result:
```bash
if ! grep -A 30 "^### ${task_number}\." .claude/specs/TODO.md | grep -q "{artifact_path}"; then
  echo "WARNING: Artifact not linked in TODO.md: {artifact_path}"
  echo "Manual fix needed"
fi
```

### 4. Handle Edge Cases

Document handling of:
1. **Existing links**: Update rather than duplicate
2. **Multiple artifacts of same type**: Show latest (current policy)
3. **Missing prerequisite links**: Handle gracefully (e.g., plan link without research)

### 5. Consider Creating artifact-link-manager Utility

A dedicated skill/utility to handle artifact linking consistently across all commands:
- Input: task_number, artifact_path, artifact_type
- Output: Success/failure with details
- Handles all edge cases in one place

## References

- `.claude/specs/429_extend_command_skill_agent_integration_to_meta/` - Affected task with missing summary link
- `.claude/commands/implement.md` - Implementation command (lines 176-180)
- `.claude/commands/research.md` - Research command (lines 133-135)
- `.claude/commands/plan.md` - Plan command (lines 131-133)
- `.claude/skills/skill-status-sync/SKILL.md` - Documented patterns (lines 164-326)
- `.claude/specs/archive/386_fix_command_artifact_linking_in_todo_md/` - Prior fix attempt

## Next Steps

1. **Immediate**: Update commands with explicit artifact linking steps and Edit patterns
2. **Short-term**: Add verification steps to catch linking failures
3. **Medium-term**: Consider artifact-link-manager for centralized handling
4. **Ongoing**: Audit existing tasks for missing links and fix them
