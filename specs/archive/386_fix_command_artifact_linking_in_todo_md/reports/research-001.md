# Research Report: Task #386

**Task**: Fix command artifact linking in TODO.md
**Date**: 2026-01-11
**Focus**: Identify root cause of artifact linking failures between state.json and TODO.md

## Summary

The artifact linking failure stems from a gap between documented architecture (postflight pattern) and actual implementation (skill-status-sync). Commands reference `status-sync-manager` subagent that doesn't exist, and the actual skill-status-sync only documents adding artifacts to state.json without corresponding TODO.md updates. Additional research reveals that multiple research reports for the same task are not being linked.

## Findings

### 1. Documented vs Actual Architecture

**Documented (postflight-pattern.md)**:
- References `status-sync-manager` subagent at `.claude/agent/subagents/status-sync-manager.md`
- References `git-workflow-manager` subagent
- Describes full postflight with artifact validation and linking

**Actual Implementation**:
- NO `status-sync-manager` subagent exists
- NO `git-workflow-manager` subagent exists
- Only `skill-status-sync` skill exists at `.claude/skills/skill-status-sync/SKILL.md`
- Only `skill-git-workflow` skill exists at `.claude/skills/skill-git-workflow/SKILL.md`

### 2. Command Files Reference Non-Existent Components

All four workflow commands reference "skill-status-sync" for atomic updates:
- `/research` (lines 54-61, 140-149)
- `/plan` (lines 60-67, 152-164)
- `/implement` (lines 76-83, 140-150)
- `/revise` (lines 126-136)

Each command says:
```
Invoke skill-status-sync for atomic update:
- task_number: {N}
- operation: status_update
- new_status: {status}
- artifact_path: {path}
- artifact_type: {type}
```

### 3. skill-status-sync Implementation Gap

The skill-status-sync SKILL.md documents:

**State.json Update (Lines 147-157)**:
```bash
# Add artifact to task in state.json
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg path "$artifact_path" \
   --arg type "$artifact_type" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    last_updated: $ts,
    artifacts: ((.artifacts // []) + [{"path": $path, "type": $type}])
  }' .claude/specs/state.json > /tmp/state.json && \
  mv /tmp/state.json .claude/specs/state.json
```

**CRITICAL MISSING**: There is NO corresponding code to add artifact links to TODO.md!

The skill only documents:
- Status updates in TODO.md (changing `[NOT STARTED]` to `[RESEARCHED]`)
- Artifact additions to state.json
- But NOT artifact link additions to TODO.md

### 4. Evidence of Missing Links

**Task 385** demonstrates the issue:
- state.json has 3 artifacts: research-001.md, research-002.md, implementation-001.md
- TODO.md only shows 2 links: research-001.md and implementation-001.md
- **research-002.md was NEVER linked in TODO.md**

**Task 380** shows inverse problem:
- TODO.md has all artifact links (research, plan, summary)
- state.json has NO artifacts array at all!

### 5. Root Cause Analysis

The artifact linking failure occurs because:

1. **Missing TODO.md Artifact Linking Logic**: skill-status-sync has jq patterns for state.json artifact addition but no corresponding Edit patterns for TODO.md artifact linking

2. **Inconsistent Manual Application**: Some tasks get links manually added, others don't

3. **No Verification Step**: Unlike the postflight-pattern.md which describes verification, actual implementation has no defense-in-depth to catch missing links

### 6. State-Management Rules (state-management.md)

The documented artifact linking format in state-management.md (lines 79-93) shows:

```markdown
### Research Completion
- **Status**: [RESEARCHED]
- **Research**: [.claude/specs/{N}_{SLUG}/reports/research-001.md]

### Plan Completion
- **Status**: [PLANNED]
- **Plan**: [.claude/specs/{N}_{SLUG}/plans/implementation-001.md]

### Implementation Completion
- **Status**: [COMPLETED]
- **Completed**: 2026-01-08
- **Summary**: [.claude/specs/{N}_{SLUG}/summaries/implementation-summary-20260108.md]
```

But there's no code in skill-status-sync that implements these patterns!

## Recommendations

### 1. Add TODO.md Artifact Linking to skill-status-sync

Add Edit patterns for artifact linking after state.json update:

```bash
# After state.json artifact addition, add link to TODO.md
# Find task entry line
task_line=$(grep -n "^### ${task_number}\." .claude/specs/TODO.md | cut -d: -f1)

# Add artifact link after Status line
case "$artifact_type" in
  "research")
    # Add: - **Research**: [link]
    ;;
  "plan")
    # Add: - **Plan**: [link]
    ;;
  "summary")
    # Add: - **Summary**: [link]
    ;;
esac
```

### 2. Handle Multiple Artifacts of Same Type

The current TODO.md format only shows one Research link, but tasks can have multiple research reports (e.g., task 385). Consider:
- Showing only the latest artifact of each type
- Or showing all artifacts with numbered links

### 3. Add Verification Step

Implement the defense-in-depth pattern from postflight-pattern.md:
```bash
# Verify artifact link exists in TODO.md
if ! grep -q "$artifact_path" .claude/specs/TODO.md; then
  echo "WARNING: Artifact not linked in TODO.md: $artifact_path"
fi
```

### 4. Audit Affected Commands

All four commands need updates:
- `/research` - Add TODO.md Research link after research completion
- `/plan` - Add TODO.md Plan link after plan creation
- `/implement` - Add TODO.md Summary link after implementation completion
- `/revise` - Update TODO.md Plan link with new version

## References

- `.claude/skills/skill-status-sync/SKILL.md` - Current implementation (incomplete)
- `.claude/context/core/orchestration/postflight-pattern.md` - Documented pattern (not implemented)
- `.claude/rules/state-management.md` - Artifact link format specification
- `.claude/commands/research.md` - References skill-status-sync
- `.claude/commands/plan.md` - References skill-status-sync
- `.claude/commands/implement.md` - References skill-status-sync
- `.claude/commands/revise.md` - References skill-status-sync

## Next Steps

1. **Phase 1**: Update skill-status-sync to add TODO.md artifact links
2. **Phase 2**: Add verification step to catch linking failures
3. **Phase 3**: Audit existing tasks for missing links and fix them
4. **Phase 4**: Test all four commands end-to-end
