# Implementation Plan: Task #835

- **Task**: 835 - enhance_review_command_roadmap_integration_revision
- **Status**: [IMPLEMENTING]
- **Effort**: 4.5 hours
- **Dependencies**: Task 833 (Strategies/Ambitions/Changelog sections in ROADMAP.md)
- **Research Inputs**: specs/835_enhance_review_command_roadmap_integration_revision/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Extend the /review command to integrate bidirectionally with ROADMAP.md. The current implementation reads roadmap state and annotates completed items, but lacks the ability to use roadmap context (Strategies/Ambitions) to inform review focus and to revise the roadmap based on review findings. This plan adds three new sections: roadmap context loading at start (Step 1.5), roadmap revision based on findings (Step 6.5), and task suggestions output (Step 8.5).

### Research Integration

Research report (research-001.md) identified:
- Current /review has roadmap reading (Section 2.5) and annotation (Section 2.5.3) but no revision capability
- Strategies and Ambitions sections do not currently exist in ROAD_MAP.md (dependency on Task 833)
- /todo command (Section 7.5) provides a model for task suggestions output
- Recommendation: Keep inline execution, extend existing logic rather than creating skill-reviewer

## Goals & Non-Goals

**Goals**:
- Load Strategies and Ambitions sections at review start to inform focus areas
- Revise ROADMAP.md based on review findings (update strategy statuses, propose new ambitions)
- Output task suggestions based on findings similar to /learn and /todo patterns
- Gracefully handle missing Strategies/Ambitions sections with fallback behavior

**Non-Goals**:
- Creating a separate skill-reviewer subagent (keep inline execution)
- Automatic creation of Strategies/Ambitions sections (handled by Task 833)
- Changing existing roadmap annotation logic (Section 2.5.2-2.5.3)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Strategies/Ambitions sections don't exist | Medium | High | Graceful fallback with info message; document dependency on Task 833 |
| Review output becomes too long | Low | Medium | Keep task suggestions concise (3-5 items); use summary format |
| Circular dependency between read/write phases | Medium | Low | Clear separation: Steps 1.5/2.5 read, Steps 6.5 write |
| Roadmap revision conflicts with manual edits | Medium | Low | Use safe Edit patterns; skip already-modified sections |

## Implementation Phases

### Phase 1: Add Roadmap Context Loading (Step 1.5) [COMPLETED]

**Goal**: Load and parse Strategies and Ambitions sections from ROAD_MAP.md at review start to inform the review analysis.

**Tasks**:
- [ ] Insert new Section 1.5 "Load ROADMAP Context" after Section 1 "Parse Arguments"
- [ ] Add parsing logic for `## Strategies` section structure
- [ ] Add parsing logic for `## Ambitions` section structure
- [ ] Build `roadmap_context` JSON structure with strategies and ambitions data
- [ ] Implement fallback behavior when sections don't exist (log info, continue without)
- [ ] Add roadmap_context variables for use in later sections

**Timing**: 1 hour

**Files to modify**:
- `.claude/commands/review.md` - Insert Section 1.5 after Section 1

**Verification**:
- Section 1.5 parses existing Strategies section if present
- Section 1.5 logs info message if sections missing
- roadmap_context structure is built and available for Section 2

---

### Phase 2: Extend Review Report Format (Section 4) [COMPLETED]

**Goal**: Update the review report template to include roadmap context and revision summary sections.

**Tasks**:
- [ ] Add "## Roadmap Context" section to review report template
- [ ] Add "### Active Strategies" subsection showing strategies that informed review
- [ ] Add "### Ambition Progress" subsection showing progress on ambition criteria
- [ ] Add "## Roadmap Revisions" section to document changes made
- [ ] Add "### Strategy Updates" subsection for status changes
- [ ] Add "### Proposed Ambitions" subsection for gap-identified ambitions

**Timing**: 0.75 hours

**Files to modify**:
- `.claude/commands/review.md` - Extend Section 4 review report template

**Verification**:
- Review report template includes all new sections
- Sections are properly formatted with markdown headers
- Template handles case when no roadmap context is available

---

### Phase 3: Add Roadmap Revision Step (Step 6.5) [COMPLETED]

**Goal**: Implement roadmap revision logic to update strategy statuses and propose new ambitions based on review findings.

**Tasks**:
- [ ] Insert new Section 6.5 "Revise ROADMAP.md Based on Findings" after Section 6
- [ ] Add Section 6.5.1 "Strategy Status Updates" with logic to:
  - Check if review findings relate to ACTIVE strategies
  - Propose status changes (ACTIVE -> COMPLETED or PAUSED)
  - Use Edit tool with exact string matching
- [ ] Add Section 6.5.2 "Propose New Ambitions" with logic to:
  - Identify significant gaps not covered by existing ambitions
  - Formulate ambition proposal with criteria
  - Use AskUserQuestion for approval before adding
- [ ] Add Section 6.5.3 "Update Active Tasks Section" to sync newly created tasks
- [ ] Add Section 6.5.4 "Add Gap Notes" to document architectural concerns in Open Questions
- [ ] Track changes for report (`annotations_made`, `strategies_updated`, `ambitions_proposed`)

**Timing**: 1.5 hours

**Files to modify**:
- `.claude/commands/review.md` - Insert Section 6.5 after Section 6

**Verification**:
- Strategy status changes use safe Edit patterns
- User approval required for new ambitions
- Skip already-modified sections to avoid conflicts
- Change tracking populated for report output

---

### Phase 4: Add Task Suggestions Output (Step 8.5) [COMPLETED]

**Goal**: Add task suggestions section to review output, following /todo and /learn patterns.

**Tasks**:
- [ ] Insert new Section 8.5 "Task Suggestions" at end of Section 8 "Output"
- [ ] Define suggestion sources:
  - Issues identified in review (not converted to tasks)
  - Incomplete roadmap items from Strategies/Ambitions
  - Stale tasks in TODO.md (>7 days not_started)
  - Follow-up opportunities from completed phases
- [ ] Implement suggestion prioritization based on:
  - Severity of unfixed issues
  - Strategy priority (ACTIVE strategies first)
  - Ambition progress (near-complete criteria first)
- [ ] Format output following /todo pattern with "Recommended Next Steps"
- [ ] Limit to 3-5 suggestions to keep output focused

**Timing**: 1 hour

**Files to modify**:
- `.claude/commands/review.md` - Insert Section 8.5 at end of Section 8

**Verification**:
- Task suggestions appear after main output
- Suggestions are prioritized and limited to 3-5
- Format matches /todo command pattern
- Suggestions include actionable next commands (/research, /plan, /implement)

---

### Phase 5: Update Git Commit and Final Output [COMPLETED]

**Goal**: Update commit message format and final output to reflect new roadmap revision capabilities.

**Tasks**:
- [ ] Update Section 7 "Git Commit" message template to include:
  - `Strategies: {N} updated`
  - `Ambitions: {N} proposed`
- [ ] Update Section 8 "Output" summary to include:
  - Strategy status changes
  - Proposed ambitions (pending user approval)
  - Task suggestions summary
- [ ] Ensure roadmap changes are included in git add if modified
- [ ] Add summary line for task suggestions at end of output

**Timing**: 0.25 hours

**Files to modify**:
- `.claude/commands/review.md` - Update Sections 7 and 8

**Verification**:
- Commit message includes strategy and ambition counts
- Final output shows all roadmap-related changes
- Task suggestions appear at end with summary count

## Testing & Validation

- [ ] Run /review with existing ROAD_MAP.md (no Strategies/Ambitions) - should complete with info messages
- [ ] Verify Section 1.5 fallback when sections don't exist
- [ ] Verify Section 6.5 skips revision when no roadmap context
- [ ] Verify task suggestions appear even without roadmap context
- [ ] After Task 833: Run /review with Strategies/Ambitions sections - should parse and use
- [ ] Verify strategy status update uses safe Edit patterns
- [ ] Verify ambition proposal requires user approval via AskUserQuestion

## Artifacts & Outputs

- `.claude/commands/review.md` - Extended with Sections 1.5, 6.5, 8.5 and updated report template
- Plans/implementation-001.md (this file)
- Summaries/implementation-summary-YYYYMMDD.md (after completion)

## Rollback/Contingency

If implementation causes issues:
1. Sections 1.5, 6.5, and 8.5 can be removed independently
2. Original Section 4 report template can be restored from git history
3. Fallback behavior ensures review works without Strategies/Ambitions sections
4. No changes to core roadmap annotation logic (2.5.2-2.5.3) reduces rollback scope
