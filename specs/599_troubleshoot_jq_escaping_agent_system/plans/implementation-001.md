# Implementation Plan: Task #599

- **Task**: 599 - Troubleshoot jq Escaping in Agent System
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/599_troubleshoot_jq_escaping_agent_system/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This plan addresses jq command escaping issues caused by Claude Code's Bash tool bug (Issue #1132). The bug injects `< /dev/null` into commands containing pipe operators (`|`) inside quoted strings, corrupting jq filter expressions like `map(select(.type != "X"))`. The fix involves replacing affected patterns with two-step jq commands that avoid the problematic pipe positioning, and documenting correct patterns in a new context file.

### Research Integration

Key findings from research-001.md:
- Root cause is Claude Code Bash tool escaping mechanism
- 14 instances across 10 files use the problematic pattern
- Recommended fix: Split into two-step operations OR use `unique_by` after appending
- Bug is marked NOT_PLANNED upstream, so workaround is necessary

## Goals & Non-Goals

**Goals**:
- Fix all 14 instances of affected jq patterns across 10 files
- Create documentation for correct jq patterns to prevent recurrence
- Maintain semantic equivalence of state.json updates
- Ensure all files follow consistent pattern post-fix

**Non-Goals**:
- Fixing the upstream Claude Code bug
- Refactoring unrelated jq commands that work correctly
- Changing the overall artifact linking workflow

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Two-step operations less atomic | Medium | Low | Use temp files with atomic mv; changes isolated to single task |
| Pattern inconsistency across files | Medium | Medium | Use single template, apply uniformly |
| Future upstream fix makes workaround unnecessary | Low | Low | Document version notes; easy to revert |
| Breaking existing functionality | High | Low | Test each file's pattern manually after edit |

## Implementation Phases

### Phase 1: Create Documentation [NOT STARTED]

**Goal**: Document the bug, correct patterns, and testing procedures for future reference

**Tasks**:
- [ ] Create `.claude/context/core/patterns/jq-escaping-workarounds.md`
- [ ] Document the Claude Code bug and symptoms
- [ ] Provide working pattern templates for artifact updates
- [ ] Include testing checklist

**Timing**: 30 minutes

**Files to create**:
- `.claude/context/core/patterns/jq-escaping-workarounds.md` - new documentation file

**Verification**:
- Documentation file exists and is properly linked
- Patterns are clear and copy-pasteable

---

### Phase 2: Fix Core Pattern File [NOT STARTED]

**Goal**: Update the inline-status-update.md reference pattern that other files follow

**Tasks**:
- [ ] Update research postflight pattern (line 81)
- [ ] Update planning postflight pattern (line 102)
- [ ] Update implementation postflight pattern (line 123)
- [ ] Add reference to new documentation file

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/core/patterns/inline-status-update.md` - 3 pattern updates

**Verification**:
- All three postflight patterns use two-step approach
- No `map(select(.type != ...))` patterns remain in file

---

### Phase 3: Fix Skill Files (Research/Planning) [NOT STARTED]

**Goal**: Update skill files that handle research and planning postflight

**Tasks**:
- [ ] Update skill-researcher/SKILL.md (line 150)
- [ ] Update skill-planner/SKILL.md (line 157)
- [ ] Update skill-lean-research/SKILL.md (line 155)

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-researcher/SKILL.md` - postflight pattern
- `.claude/skills/skill-planner/SKILL.md` - postflight pattern
- `.claude/skills/skill-lean-research/SKILL.md` - postflight pattern

**Verification**:
- Each file uses two-step jq pattern
- Pattern matches documentation template

---

### Phase 4: Fix Skill Files (Implementation) [NOT STARTED]

**Goal**: Update skill files that handle implementation postflight

**Tasks**:
- [ ] Update skill-implementer/SKILL.md (line 160)
- [ ] Update skill-lean-implementation/SKILL.md (line 171)
- [ ] Update skill-latex-implementation/SKILL.md (line 173)

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-implementer/SKILL.md` - postflight pattern
- `.claude/skills/skill-lean-implementation/SKILL.md` - postflight pattern
- `.claude/skills/skill-latex-implementation/SKILL.md` - postflight pattern

**Verification**:
- Each file uses two-step jq pattern
- Pattern matches documentation template

---

### Phase 5: Fix Command Files [NOT STARTED]

**Goal**: Update command files with jq patterns

**Tasks**:
- [ ] Update commands/task.md recover pattern (line 138)
- [ ] Update commands/task.md abandon pattern (line 252)
- [ ] Update commands/revise.md plan update pattern (line 76)

**Timing**: 30 minutes

**Files to modify**:
- `.claude/commands/task.md` - 2 pattern updates (recover and abandon operations)
- `.claude/commands/revise.md` - 1 pattern update

**Verification**:
- Recover and abandon operations use working jq patterns
- Revise plan update uses working pattern

---

### Phase 6: Verification and Testing [NOT STARTED]

**Goal**: Verify all patterns work correctly and document testing

**Tasks**:
- [ ] Test sample jq command from each category
- [ ] Run grep to confirm no problematic patterns remain
- [ ] Update context index if needed
- [ ] Create implementation summary

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/index.md` - add link to new documentation (if needed)
- `specs/599_troubleshoot_jq_escaping_agent_system/summaries/implementation-summary-YYYYMMDD.md` - create summary

**Verification**:
- `grep -r "map(select(.type !=" .claude/` returns no results
- `grep -r "map(select(.project_number !=" .claude/` returns no results
- Sample commands execute without error

## Testing & Validation

- [ ] Grep confirms no remaining `map(select(.field !=` patterns in .claude/
- [ ] Sample jq command with artifact update works in Bash tool
- [ ] Documentation file is accessible and correctly formatted
- [ ] All modified skill files maintain structural consistency

## Artifacts & Outputs

- `.claude/context/core/patterns/jq-escaping-workarounds.md` - new documentation
- `specs/599_troubleshoot_jq_escaping_agent_system/plans/implementation-001.md` - this plan
- `specs/599_troubleshoot_jq_escaping_agent_system/summaries/implementation-summary-YYYYMMDD.md` - completion summary
- 10 modified files with corrected jq patterns

## Rollback/Contingency

If the new patterns cause issues:
1. Revert to previous file versions via git: `git checkout HEAD~1 -- <file>`
2. Document the specific failure case
3. Consider alternative workaround from research (script file approach)

The two-step approach is semantically equivalent to the original single-command approach, so rollback should be straightforward if needed.

## Replacement Pattern Reference

### Original (Broken)

```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "researched" \
   --arg path "$artifact_path" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: $status,
    last_updated: $ts,
    researched: $ts,
    artifacts: ((.artifacts // []) | map(select(.type != "research"))) + [{"path": $path, "type": "research"}]
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

### Replacement (Working)

```bash
# Step 1: Update status and timestamps
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "researched" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: $status,
    last_updated: $ts,
    researched: $ts
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json

# Step 2: Add artifact (append then dedupe by type)
jq --arg path "$artifact_path" \
  '(.active_projects[] | select(.project_number == '$task_number')).artifacts =
    ([(.active_projects[] | select(.project_number == '$task_number')).artifacts // [] | .[] | select(.type != "research")] + [{"path": $path, "type": "research"}])' \
  specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

### Alternative: del() approach

```bash
# Single command using del() instead of map(select(!=))
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "researched" \
   --arg path "$artifact_path" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= (
    del(.artifacts[] | select(.type == "research")) |
    . + {
      status: $status,
      last_updated: $ts,
      researched: $ts,
      artifacts: ((.artifacts // []) + [{"path": $path, "type": "research"}])
    }
  )' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```
