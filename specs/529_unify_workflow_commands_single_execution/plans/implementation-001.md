# Implementation Plan: Task #529

**Task**: 529 - Unify Workflow Commands into Single-Execution Pattern
**Version**: 001
**Created**: 2026-01-17
**Session ID**: sess_1768659461_df9d16
**Language**: meta
**Estimated Effort**: 4-6 hours

## Overview

Refactor workflow commands to use **Option B (In Skill)** architecture where:
- **Commands** are thin routers (validate → delegate → commit)
- **Skills** own the complete lifecycle (preflight → agent → postflight → return)
- **Agents** remain isolated work units (no state management)

This eliminates the 3-skill invocation pattern that causes halting, reducing to 1 skill per workflow.

## Architecture Summary

### Before (3 Skills per Workflow)
```
/research N
├── GATE IN: Skill(skill-status-sync) preflight    ← HALT RISK
├── DELEGATE: Skill(skill-researcher)              ← HALT RISK
├── GATE OUT: Skill(skill-status-sync) postflight  ← HALT RISK
└── COMMIT: Bash
```

### After (1 Skill per Workflow)
```
/research N
├── VALIDATE: Inline task lookup and validation
├── DELEGATE: Skill(skill-researcher)
│   ├── Preflight: Inline status update
│   ├── Agent: Task(general-research-agent)
│   ├── Postflight: Inline status update
│   └── Return: JSON with artifacts
└── COMMIT: Bash git commit
```

## Phases

---

### Phase 1: Create Reusable Status Update Patterns

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Create documented patterns for inline status updates
2. Provide copy-paste snippets for all skills
3. Include preflight, postflight, and artifact linking patterns

**Files to create**:
- `.claude/context/core/patterns/skill-lifecycle.md` - Self-contained skill pattern
- `.claude/context/core/patterns/inline-status-update.md` - Status update snippets

**Steps**:
1. Create `skill-lifecycle.md` documenting the self-contained skill pattern
2. Create `inline-status-update.md` with bash/jq snippets:
   - Preflight: Update state.json status + TODO.md marker
   - Postflight: Update state.json status + link artifacts + TODO.md
   - Error handling: Rollback on failure
3. Update `.claude/context/index.md` to reference new patterns

**Verification**:
- Patterns are complete and well-documented
- Snippets are tested manually

---

### Phase 2: Refactor Research Skills

**Estimated effort**: 1.5 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Add preflight/postflight to skill-researcher
2. Add preflight/postflight to skill-lean-research
3. Skills become self-contained workflows

**Files to modify**:
- `.claude/skills/skill-researcher/SKILL.md`
- `.claude/skills/skill-lean-research/SKILL.md`

**Steps**:

For each skill:
1. Add **Section 0: Preflight** before current execution:
   ```markdown
   ### 0. Preflight Status Update

   Update task to "researching" before starting work:

   ```bash
   # Update state.json
   jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      --arg status "researching" \
      --arg sid "$session_id" \
     '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
       status: $status, last_updated: $ts, session_id: $sid
     }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
   ```

   Then Edit TODO.md: `[NOT STARTED]` or `[RESEARCHED]` → `[RESEARCHING]`
   ```

2. Add **Section 5: Postflight** after current return validation:
   ```markdown
   ### 5. Postflight Status Update

   Update task to "researched" after successful agent return:

   ```bash
   # Update state.json with status and artifact
   jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      --arg status "researched" \
      --arg path "$artifact_path" \
     '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
       status: $status, last_updated: $ts, researched: $ts,
       artifacts: (.artifacts // []) + [{"path": $path, "type": "research"}]
     }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
   ```

   Then Edit TODO.md:
   - `[RESEARCHING]` → `[RESEARCHED]`
   - Add research artifact link
   ```

3. Update allowed-tools in frontmatter: Add `Bash(jq:*)`, `Edit`

**Verification**:
- Skills have Preflight (Section 0) and Postflight (Section 5)
- Frontmatter includes necessary tools
- Agent delegation remains in Section 3

---

### Phase 3: Refactor Planner Skill

**Estimated effort**: 45 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Add preflight/postflight to skill-planner
2. Skill becomes self-contained workflow

**Files to modify**:
- `.claude/skills/skill-planner/SKILL.md`

**Steps**:
1. Add **Section 0: Preflight** (update to "planning")
2. Add **Section 5: Postflight** (update to "planned", link plan artifact)
3. Update allowed-tools: Add `Bash(jq:*)`, `Edit`

**Pattern differences from research skills**:
- Status values: "planning" → "planned" (instead of researching → researched)
- Artifact type: "plan" (instead of "research")

**Verification**:
- Skill has complete lifecycle
- Status transitions are correct for planning workflow

---

### Phase 4: Refactor Implementation Skills

**Estimated effort**: 1.5 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Add preflight/postflight to skill-implementer
2. Add preflight/postflight to skill-lean-implementation
3. Add preflight/postflight to skill-latex-implementation
4. All implementation skills become self-contained

**Files to modify**:
- `.claude/skills/skill-implementer/SKILL.md`
- `.claude/skills/skill-lean-implementation/SKILL.md`
- `.claude/skills/skill-latex-implementation/SKILL.md`

**Steps**:

For each skill:
1. Add **Section 0: Preflight** (update to "implementing")
2. Add **Section 5: Postflight**:
   - On completion: Update to "completed", link summary artifact
   - On partial: Keep "implementing", note resume point
3. Update allowed-tools: Add `Bash(jq:*)`, `Edit`

**Pattern differences**:
- Status values: "implementing" → "completed" or remains "implementing" (partial)
- Artifact type: "summary" on completion
- Additional field: "completed" timestamp on success

**Verification**:
- All 3 implementation skills have complete lifecycle
- Handle both completion and partial cases

---

### Phase 5: Simplify Commands

**Estimated effort**: 1 hour
**Status**: [NOT STARTED]

**Objectives**:
1. Simplify /research command (remove GATE IN/OUT checkpoints)
2. Simplify /plan command (same)
3. Simplify /implement command (same)
4. Commands become thin routers

**Files to modify**:
- `.claude/commands/research.md`
- `.claude/commands/plan.md`
- `.claude/commands/implement.md`

**Steps**:

For each command, transform from:
```markdown
### CHECKPOINT 1: GATE IN
1. Generate Session ID
2. Lookup Task
3. Validate
4. Update Status (via skill-status-sync)  ← REMOVE
5. Verify                                   ← REMOVE

### STAGE 2: DELEGATE
Invoke Skill...

### CHECKPOINT 2: GATE OUT
1. Validate Return
2. Verify Artifacts
3. Update Status (via skill-status-sync)  ← REMOVE
4. Verify                                   ← REMOVE

### CHECKPOINT 3: COMMIT
Git commit...
```

To:
```markdown
### CHECKPOINT 1: VALIDATE
1. Generate Session ID
2. Lookup Task
3. Validate status allows operation
(No status update - skill handles it)

### CHECKPOINT 2: DELEGATE
Invoke Skill with task context and session ID.
Skill handles preflight, agent delegation, and postflight internally.

### CHECKPOINT 3: COMMIT
Git commit on successful return.
```

**Verification**:
- Commands are <30 lines each
- No skill-status-sync invocations
- Only 1 Skill invocation per command

---

### Phase 6: Update Documentation

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Mark skill-status-sync as deprecated for workflow use
2. Update CLAUDE.md checkpoint documentation
3. Document the new architecture

**Files to modify**:
- `.claude/skills/skill-status-sync/SKILL.md` - Add deprecation notice
- `.claude/CLAUDE.md` - Update checkpoint model section
- `.claude/ARCHITECTURE.md` - Update skill-agent relationship docs

**Steps**:
1. Add to skill-status-sync header:
   ```markdown
   > **Note**: This skill is deprecated for workflow commands (/research, /plan, /implement).
   > Those commands now use self-contained skills with inline status updates.
   > skill-status-sync remains available for debugging and direct invocation via /task --sync.
   ```

2. Update CLAUDE.md Checkpoint-Based Execution Model to reflect simplified flow

3. Update ARCHITECTURE.md skill descriptions

**Verification**:
- Deprecation clearly documented
- Architecture docs match implementation

---

### Phase 7: Test Full Workflows

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Test /research workflow completes without "continue"
2. Test /plan workflow completes without "continue"
3. Test /implement workflow completes without "continue"
4. Verify state consistency

**Steps**:
1. Create a test task for validation
2. Run `/research {N}` - verify:
   - Single skill invocation
   - No "continue" prompts
   - Status transitions: NOT STARTED → RESEARCHING → RESEARCHED
   - Artifacts linked correctly
3. Run `/plan {N}` - verify same patterns
4. Run `/implement {N}` - verify same patterns
5. Check state.json and TODO.md are synchronized

**Verification**:
- All workflows complete in single execution
- No halting after skill returns
- State files consistent

---

## Dependencies

- Research reports provide architectural guidance
- Patterns from Phase 1 are used in Phases 2-4
- Skills must be updated (Phases 2-4) before commands (Phase 5)

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Skills become complex | Medium | Clear section markers, documented patterns |
| Inconsistent implementations | Medium | Use same template for all skills |
| Agent failures leave bad state | Medium | Postflight only on success, error handling |
| Missing edge cases | Low | Test each workflow type |
| skill-status-sync orphaned | Low | Keep for debugging/direct use |

## Success Criteria

- [ ] Phase 1: Pattern documentation complete
- [ ] Phase 2: Research skills have preflight/postflight
- [ ] Phase 3: Planner skill has preflight/postflight
- [ ] Phase 4: Implementation skills have preflight/postflight
- [ ] Phase 5: Commands simplified to <30 lines each
- [ ] Phase 6: Documentation updated
- [ ] Phase 7: All workflows complete without "continue"

## Rollback Plan

If implementation causes issues:
1. Git revert to pre-implementation state
2. Restore original command files from git history
3. Restore original skill files from git history
4. skill-status-sync remains functional as fallback

## Files Summary

**New Files (2)**:
- `.claude/context/core/patterns/skill-lifecycle.md`
- `.claude/context/core/patterns/inline-status-update.md`

**Modified Skills (6)**:
- `.claude/skills/skill-researcher/SKILL.md`
- `.claude/skills/skill-lean-research/SKILL.md`
- `.claude/skills/skill-planner/SKILL.md`
- `.claude/skills/skill-implementer/SKILL.md`
- `.claude/skills/skill-lean-implementation/SKILL.md`
- `.claude/skills/skill-latex-implementation/SKILL.md`

**Modified Commands (3)**:
- `.claude/commands/research.md`
- `.claude/commands/plan.md`
- `.claude/commands/implement.md`

**Documentation Updates (3)**:
- `.claude/skills/skill-status-sync/SKILL.md`
- `.claude/CLAUDE.md`
- `.claude/ARCHITECTURE.md`

**Total Files**: 14
