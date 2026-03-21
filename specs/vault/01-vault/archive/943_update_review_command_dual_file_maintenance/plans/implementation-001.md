# Implementation Plan: Update /review Command Dual File Maintenance

- **Task**: 943 - update_review_command_dual_file_maintenance
- **Status**: [NOT STARTED]
- **Effort**: 1 hour
- **Dependencies**: Task 941 (CHANGE_LOG.md creation)
- **Research Inputs**: specs/943_update_review_command_dual_file_maintenance/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Update the /review command to maintain both ROAD_MAP.md and CHANGE_LOG.md. The modification adds Step 1.7 to load CHANGE_LOG.md for historical context, and Step 6.6 to update CHANGE_LOG.md with significant review findings. The implementation follows existing patterns established for ROAD_MAP.md handling (Steps 1.6 and 6.5).

### Research Integration

The research report (research-001.md) identified:
- Current /review structure (8 steps, 1344 lines)
- CHANGE_LOG.md schema from Task 941
- Existing ROAD_MAP.md patterns to follow
- Entry worthiness criteria for changelog updates
- ~80-100 lines of new content required

## Goals & Non-Goals

**Goals**:
- Add Step 1.7 to load CHANGE_LOG.md and build `changelog_context`
- Add Step 6.6 to update CHANGE_LOG.md with significant review findings
- Update Step 4 report template to include changelog context section
- Update Step 7 commit message to track changelog updates
- Update Step 8 output to show changelog update status

**Non-Goals**:
- Changing ROAD_MAP.md handling (already implemented)
- Modifying changelog-format.md (finalized by Task 941)
- Changing /todo command's changelog update pattern

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Large changelog slows parsing | Medium | Low | Limit to 30-day window by default |
| Edit conflicts with /todo updates | Low | Low | Both use same edit pattern; conflicts rare |
| Review entries clutter changelog | Low | Low | Entry worthiness criteria filter minor reviews |

## Implementation Phases

### Phase 1: Add Changelog Loading (Step 1.7) [COMPLETED]

- **Dependencies:** None
- **Goal:** Enable /review to load historical context from CHANGE_LOG.md

**Tasks:**
- [ ] Add Step 1.7 header after Step 1.6 in `.claude/commands/review.md`
- [ ] Implement Section 1.7.1: Parse Changelog Entries (30-day window)
- [ ] Implement Section 1.7.2: Fallback Behavior for missing/empty file
- [ ] Define `changelog_context` structure with fields: recent_entries, entry_count, date_range, loaded_successfully
- [ ] Define `recent_task_numbers` variable for duplicate detection

**Timing:** 30 minutes

**Files to modify:**
- `.claude/commands/review.md` - Insert Step 1.7 after Step 1.6 (~40 lines)

**Verification:**
- Step 1.7 appears between Step 1.6 and Step 2
- `changelog_context` structure documented with JSON schema
- Fallback behavior defined for missing file

**Progress:**

**Session: 2026-02-26, sess_1772139996_4617**
- Added: Step 1.7 header and subsections 1.7.1-1.7.2 to `.claude/commands/review.md` (after Step 1.6)
- Added: `changelog_context` JSON structure with fields: recent_entries, entry_count, date_range, loaded_successfully
- Added: `recent_task_numbers` variable definition
- Completed: All Phase 1 tasks

---

### Phase 2: Add Changelog Updates and Output Integration [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Enable /review to update CHANGE_LOG.md and report changelog context

**Tasks:**
- [ ] Update Step 4 report template to include "Changelog Context" section
- [ ] Add Step 6.6 header after Step 6.5
- [ ] Implement Section 6.6.1: Determine Entry Worthiness (Critical/High criteria)
- [ ] Implement Section 6.6.2: Compose Changelog Entry (per changelog-format.md)
- [ ] Implement Section 6.6.3: Insert Entry (with date header logic)
- [ ] Implement Section 6.6.4: Track Changes (changelog_updated variable)
- [ ] Update Step 7 commit message format to include changelog update tracking
- [ ] Update Step 8 output to show changelog update status

**Timing:** 30 minutes

**Files to modify:**
- `.claude/commands/review.md` - Update Step 4 (~15 lines), add Step 6.6 (~50 lines), update Step 7 (~3 lines), update Step 8 (~5 lines)

**Verification:**
- Step 6.6 appears between Step 6.5 and Step 7
- Entry worthiness criteria match research recommendations
- Edit patterns consistent with existing ROAD_MAP.md patterns in Step 6.5
- Commit message includes changelog tracking
- Output section includes changelog update status

**Progress:**

**Session: 2026-02-26, sess_1772139996_4617**
- Added: "Changelog Context" section to Step 4 report template (after Roadmap Context)
- Added: Step 6.6 with subsections 6.6.1-6.6.4 after Step 6.5
- Added: Entry worthiness criteria (Critical/High issues, roadmap changes, tasks created, full scope)
- Added: Changelog entry composition with "Review {DATE}" format distinct from task entries
- Added: Insert logic with date-header detection
- Added: `changelog_updated` and `changelog_entry` tracking variables
- Updated: Step 7 git commit to stage CHANGE_LOG.md and include changelog line in message
- Updated: Step 8 output to show changelog update status (entry added / failed / no entry)
- Completed: All Phase 2 tasks

---

## Testing & Validation

- [ ] Review.md parses without errors (no syntax issues in markdown)
- [ ] Step numbering is correct (1.7 after 1.6, 6.6 after 6.5)
- [ ] All new sections reference correct variable names
- [ ] Edit patterns in Step 6.6 follow Step 6.5 conventions
- [ ] Cross-references to changelog-format.md are correct

## Artifacts & Outputs

- `.claude/commands/review.md` - Updated with ~110 lines of new content
- `specs/943_update_review_command_dual_file_maintenance/summaries/implementation-summary-20260226.md` - Post-implementation summary

## Rollback/Contingency

Rollback: `git checkout HEAD~1 -- .claude/commands/review.md`

The changes are additive and contained within a single file. If issues arise, the new steps can be commented out or removed without affecting existing functionality.
