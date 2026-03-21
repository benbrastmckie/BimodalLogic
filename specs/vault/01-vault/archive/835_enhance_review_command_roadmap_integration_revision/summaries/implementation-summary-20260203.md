# Implementation Summary: Task #835

**Completed**: 2026-02-03
**Duration**: ~45 minutes

## Changes Made

Extended the /review command with bidirectional ROADMAP.md integration:
1. Added Section 1.6 to load and parse Strategies and Ambitions sections at review start
2. Extended Section 4 review report template with Roadmap Context and Roadmap Revisions sections
3. Added Section 6.5 for roadmap revision logic (strategy status updates, new ambition proposals, gap notes)
4. Added Section 8.5 for task suggestions output following /todo and /learn patterns
5. Updated Section 7 git commit message to include strategy/ambition counts
6. Updated Section 8 output to show roadmap revision summary and task suggestions

## Files Modified

- `.claude/commands/review.md` - Extended with new sections:
  - Section 1.6: Load ROADMAP Context (Strategies and Ambitions parsing with fallback)
  - Section 4: Extended report template with Roadmap Context and Roadmap Revisions sections
  - Section 6.5: Revise ROADMAP.md Based on Findings (5 subsections for strategy updates, ambition proposals, task linking, gap notes)
  - Section 7: Updated commit message format with strategy/ambition counts
  - Section 8: Updated output to include roadmap revisions summary
  - Section 8.5: Task Suggestions (4 subsections for collection, prioritization, formatting, and variables)

## Key Features

### Roadmap Context Loading (Section 1.6)
- Parses `## Strategies` section for active experiments with status, hypothesis, and focus areas
- Parses `## Ambitions` section for goals with priority, timeframe, and success criteria
- Builds `roadmap_context` with `review_focus` for guiding review attention
- Graceful fallback when sections are not populated (with info message)

### Roadmap Revision (Section 6.5)
- Strategy status updates: ACTIVE -> CONCLUDED/PAUSED based on review findings
- Ambition proposals: Identifies gaps and formulates new ambitions with user approval
- Task linking: Connects newly created tasks to roadmap items
- Gap notes: Adds architectural concerns to Open Questions section
- Uses AskUserQuestion for all status changes and ambition proposals

### Task Suggestions (Section 8.5)
- Collects from 4 sources: review issues, ambition criteria, strategy focus, stale tasks
- Prioritization scoring based on severity, roadmap priority, and staleness
- Limits to 3-5 actionable suggestions with suggested commands
- Follows /todo and /learn output patterns

## Verification

- All 5 phases executed sequentially
- Plan file markers updated from [NOT STARTED] to [COMPLETED]
- File modifications verified with Read tool
- Section numbering preserved (1.5 -> 1.6 -> 2 -> ... -> 6 -> 6.5 -> 7 -> 8 -> 8.5)

## Notes

- Strategies/Ambitions sections in ROAD_MAP.md are currently placeholder text (dependency on Task 833)
- Fallback behavior ensures /review works without populated sections
- User approval required for all roadmap modifications via AskUserQuestion
- No changes to existing roadmap annotation logic (Section 2.5.2-2.5.3)
