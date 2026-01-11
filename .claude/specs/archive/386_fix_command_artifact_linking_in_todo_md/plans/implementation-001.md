# Implementation Plan: Task #386

**Task**: Fix command artifact linking in TODO.md
**Version**: 001
**Created**: 2026-01-11
**Language**: meta

## Overview

The skill-status-sync skill has logic for adding artifacts to state.json but lacks corresponding logic for adding artifact links to TODO.md. This plan adds the missing TODO.md artifact linking, implements verification, and audits existing tasks for missing links.

## Phases

### Phase 1: Add TODO.md Artifact Linking to skill-status-sync

**Estimated effort**: 1 hour
**Status**: [COMPLETED]

**Objectives**:
1. Add artifact linking patterns for TODO.md in skill-status-sync SKILL.md
2. Document the Edit patterns for each artifact type (research, plan, summary)
3. Handle the case where artifact link already exists (update vs insert)

**Files to modify**:
- `.claude/skills/skill-status-sync/SKILL.md` - Add TODO.md artifact linking section

**Steps**:
1. Read current skill-status-sync SKILL.md to understand existing structure
2. Add new section "TODO.md Artifact Linking" after the "Artifact Addition" section
3. Document patterns for each artifact type:
   - Research: `- **Research**: [research-{NNN}.md]({path})`
   - Plan: `- **Plan**: [implementation-{NNN}.md]({path})`
   - Summary: `- **Summary**: [implementation-summary-{DATE}.md]({path})`
4. Add logic for finding correct insertion point (after Language line, before Description)
5. Document handling of multiple artifacts of same type (show latest only or all)

**Verification**:
- skill-status-sync SKILL.md contains complete TODO.md artifact linking patterns
- Patterns match the format in state-management.md

---

### Phase 2: Add Verification Step

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Add defense-in-depth verification to skill-status-sync
2. Verify artifact links exist in TODO.md after operations
3. Provide clear warning messages for failures

**Files to modify**:
- `.claude/skills/skill-status-sync/SKILL.md` - Add verification section

**Steps**:
1. Add "Verification" section after artifact linking
2. Document grep-based verification pattern:
   ```bash
   # Verify artifact link exists in TODO.md
   if ! grep -q "$artifact_path" .claude/specs/TODO.md; then
     echo "WARNING: Artifact not linked in TODO.md: $artifact_path"
   fi
   ```
3. Add verification to the two-phase commit pattern
4. Document expected behavior when verification fails

**Verification**:
- Verification step documented in skill-status-sync
- Clear warning messages defined for linking failures

---

### Phase 3: Fix Existing Task Links

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Identify tasks with missing artifact links in TODO.md
2. Add missing links to affected tasks
3. Sync state.json artifacts arrays with TODO.md links

**Files to modify**:
- `.claude/specs/TODO.md` - Add missing artifact links
- `.claude/specs/state.json` - Add missing artifacts arrays where needed

**Steps**:
1. Query state.json for tasks with artifacts that aren't linked in TODO.md
   ```bash
   # For each task with artifacts, check if links exist in TODO.md
   ```
2. Fix identified discrepancies:
   - Task 385: Add research-002.md link (if keeping multiple) or verify latest is shown
   - Task 380: Add artifacts array to state.json
3. Verify all tasks have consistent artifacts in both files

**Verification**:
- All tasks with artifacts in state.json have corresponding links in TODO.md
- All tasks with links in TODO.md have corresponding artifacts in state.json

---

### Phase 4: Test End-to-End

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Verify artifact linking works for all command types
2. Document test cases and expected behavior
3. Ensure no regressions in existing functionality

**Files to modify**:
- None (testing only)

**Steps**:
1. Review this task (386) as test case for /research and /plan commands
2. Verify research artifact was correctly linked in both state.json and TODO.md
3. Verify plan artifact will be correctly linked after this plan is created
4. Document any edge cases discovered during testing

**Verification**:
- Task 386 has correct artifact links after /research and /plan
- All workflow commands produce consistent artifact links

---

## Dependencies

- None (self-contained fix)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Edit patterns fail on edge case TODO.md formats | Medium | Low | Test with various task entry formats |
| Multiple artifacts of same type cause conflicts | Low | Medium | Document clear policy (show latest only) |
| Verification false positives due to path format differences | Low | Medium | Normalize paths before comparison |

## Success Criteria

- [ ] skill-status-sync SKILL.md documents TODO.md artifact linking
- [ ] Verification step added to catch linking failures
- [ ] All existing tasks have consistent artifact links
- [ ] Task 386 artifacts correctly linked as proof of fix

## Rollback Plan

If implementation causes issues:
1. Revert changes to skill-status-sync SKILL.md
2. Manually fix any incorrectly modified TODO.md entries
3. Git revert to previous commit if needed
