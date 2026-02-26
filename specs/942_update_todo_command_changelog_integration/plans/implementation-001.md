# Implementation Plan: Task #942

- **Task**: 942 - update_todo_command_changelog_integration
- **Status**: [NOT STARTED]
- **Effort**: 0.5 hours
- **Dependencies**: Task 941 (completed)
- **Research Inputs**: Research found Task 941 already completed primary migration
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Minimal cleanup task to finalize the /todo command's changelog integration with CHANGE_LOG.md. Task 941 already completed the primary migration (Step 5.8 file path, grep patterns, existence checks, error messages). Remaining work: remove obsolete "Task 941" references, add backward compatibility notes, and add schema reference.

### Research Integration

Research confirmed:
- Step 5.8 already updated to use specs/CHANGE_LOG.md
- All grep patterns and existence checks already target CHANGE_LOG.md
- 4 obsolete "Task 941" references remain at lines 563, 1071, 1334, 1705
- Backward compatibility documentation is missing
- Schema reference to changelog-format.md is missing

## Goals & Non-Goals

**Goals**:
- Remove obsolete "Task 941" references (4 locations)
- Add backward compatibility notes to documentation section
- Add schema reference to changelog-format.md

**Non-Goals**:
- Modifying Step 5.8 logic (already correct)
- Changing any grep patterns or file paths (already correct)
- Creating CHANGE_LOG.md (Task 941's responsibility)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Edit breaks existing logic | Medium | Low | Surgical edits only, no logic changes |
| Missing a reference | Low | Low | grep verification step |

## Implementation Phases

### Phase 1: Update References and Documentation [NOT STARTED]

- **Dependencies:** None
- **Goal:** Remove obsolete "Task 941" references and add missing documentation

**Tasks**:
- [ ] Edit line 563: Change "Run Task 941 to create the changelog file" to "Create it to enable changelog tracking"
- [ ] Edit line 1071: Change "(requires Task 941)" to "Run `/meta-task` with description 'create specs/CHANGE_LOG.md from changelog-format.md'"
- [ ] Edit line 1334: Change "(requires Task 941)" to same as above
- [ ] Edit line 1705: Change "Task 941 must be implemented first (creates the CHANGE_LOG.md file)" to "specs/CHANGE_LOG.md must exist (see `.claude/context/core/formats/changelog-format.md`)"
- [ ] Add schema reference after "Entry Format" subsection in Changelog Updates documentation
- [ ] Add backward compatibility notes to Changelog Updates documentation:
  - Graceful skip when CHANGE_LOG.md missing
  - No migration needed for existing entries (ROAD_MAP.md history preserved)
  - Future runs append to CHANGE_LOG.md only
- [ ] Verify no remaining "Task 941" references with grep

**Timing:** 30 minutes

**Files to modify**:
- `.claude/commands/todo.md` - Remove 4 obsolete references, add documentation

**Verification**:
- `grep -n "Task 941" .claude/commands/todo.md` returns empty
- Documentation section includes backward compatibility notes
- Schema reference to changelog-format.md is present

## Testing & Validation

- [ ] Verify all "Task 941" references removed: `grep -c "Task 941" .claude/commands/todo.md` returns 0
- [ ] Verify backward compatibility notes present in Changelog Updates section
- [ ] Verify schema reference present
- [ ] Manual review of changes for correctness

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (on completion)

## Rollback/Contingency

- Git revert single commit if any issues discovered
- Changes are documentation-only, no runtime impact
