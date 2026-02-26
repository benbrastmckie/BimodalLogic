# Implementation Plan: Task #942 (Revision 2)

- **Task**: 942 - update_todo_command_changelog_integration
- **Status**: [NOT STARTED]
- **Effort**: 0.25 hours
- **Dependencies**: Task 941 (completed)
- **Research Inputs**: Research found Task 941 already completed primary migration
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false
- **Revision Notes**: Clean-break approach - no backward compatibility documentation needed

## Overview

Minimal cleanup task to finalize the /todo command's changelog integration. Task 941 already completed the primary migration. Remaining work: remove obsolete "Task 941" references and add schema reference. Following clean-break approach - no backward compatibility notes needed.

### Revision from v001

**Removed**:
- Backward compatibility documentation (clean-break approach)

**Simplified**:
- More concise reference updates

## Goals & Non-Goals

**Goals**:
- Remove obsolete "Task 941" references (4 locations)
- Add schema reference to changelog-format.md

**Non-Goals**:
- Modifying Step 5.8 logic (already correct)
- Backward compatibility documentation (clean-break)
- Creating CHANGE_LOG.md (done by Task 941)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Edit breaks existing logic | Medium | Low | Surgical edits only |

## Implementation Phases

### Phase 1: Clean Up References [NOT STARTED]

- **Dependencies:** None
- **Goal:** Remove obsolete references and add schema link

**Tasks**:
- [ ] Edit line 563: Change "Run Task 941 to create the changelog file" to "Create the file to enable changelog tracking"
- [ ] Edit line 1071: Change "(requires Task 941)" to "(see changelog-format.md)"
- [ ] Edit line 1334: Same update
- [ ] Edit line 1705: Change "Task 941 must be implemented first" to "File must exist (see changelog-format.md)"
- [ ] Add schema reference after Entry Format in Changelog Updates section
- [ ] Verify: `grep -c "Task 941" .claude/commands/todo.md` returns 0

**Timing:** 15 minutes

**Files to modify**:
- `.claude/commands/todo.md` - 4 reference updates + schema link

**Verification**:
- No "Task 941" references remain
- Schema reference present

## Testing & Validation

- [ ] `grep -c "Task 941" .claude/commands/todo.md` returns 0
- [ ] changelog-format.md referenced in documentation

## Artifacts & Outputs

- plans/implementation-002.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (on completion)

## Rollback/Contingency

- Git revert single commit if any issues
- Documentation-only changes, no runtime impact
