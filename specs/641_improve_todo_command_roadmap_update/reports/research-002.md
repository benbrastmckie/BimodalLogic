# Supplemental Research Report: Task #641

**Task**: improve_todo_command_roadmap_update
**Date**: 2026-01-20
**Focus**: Analysis of /revise command for similar issues
**Session ID**: sess_1768932190_4a03c2
**Prior Research**: research-001.md

## Executive Summary

- The `/revise` command does **NOT** have roadmap update issues - it is correctly scoped for plan versioning and description updates only
- Both `/todo` and `/review` share roadmap update responsibilities but with different matching strategies
- The core issue identified in research-001.md (matching strategy gap) applies equally to `/review`
- Task 639 was intended to fix `/review` matching; task 641 should focus on `/todo` or consolidate both
- Recommendation: Consolidate roadmap matching into a **shared utility pattern** that both commands use

## Context & Scope

### Focus Prompt Analysis

The focus prompt requested analysis of the `/revise` command "which likely has similar issues." After examination, `/revise` does NOT interact with ROAD_MAP.md at all - it handles:

1. **Plan revision** (creating implementation-002.md, etc.)
2. **Description updates** (for tasks without plans)

This is correct behavior. Roadmap updates are appropriately delegated to `/todo` (at archival) and `/review` (comprehensive analysis).

### Investigation Approach

1. Analyzed `/revise` command structure (211 lines)
2. Compared `/todo` and `/review` roadmap integration patterns
3. Examined shared matching strategy documentation
4. Identified architectural patterns for consolidation

## Findings

### Finding 1: /revise Command is Correctly Scoped

The `/revise` command (`.claude/commands/revise.md`) handles two scenarios:

| Scenario | Trigger | Action |
|----------|---------|--------|
| Plan Revision | Status: planned, implementing, partial, blocked | Creates new plan version (implementation-002.md, etc.) |
| Description Update | Status: not_started, researched | Updates task description in state.json and TODO.md |

**Key observation**: Neither scenario involves ROAD_MAP.md. This is appropriate because:
- Plan revisions don't complete work (no roadmap progress)
- Description updates don't complete work either

**Conclusion**: `/revise` has no roadmap issues to fix.

### Finding 2: /todo and /review Share Roadmap Responsibilities

Both commands interact with ROAD_MAP.md but with different purposes:

| Command | Purpose | When Triggered | Matching Strategy |
|---------|---------|----------------|-------------------|
| `/todo` | Mark items complete at archival | Task archived (completed/abandoned) | Exact `(Task {N})` only |
| `/review` | Comprehensive roadmap analysis | Periodic code review | Exact + fuzzy title + file path |

**Current state in ROAD_MAP.md**:
- 79 unchecked items (`- [ ]`)
- 10 checked items (`- [x]`)
- 0 explicit `(Task N)` references

This means:
- `/todo` can never find matches (no `(Task N)` patterns exist)
- `/review` could potentially match via fuzzy title, but this is unreliable

### Finding 3: Task 639 Was Designed for /review, Not /todo

Task 639 description from TODO.md:

> Improve the reliability of ROAD_MAP.md checkbox matching in the /review command. Current issues: (1) Fuzzy title matching is unreliable, (2) No explicit task-to-roadmap mapping exists, (3) Task 637 had to be manually created to fix checkboxes. Solutions: (1) Add `roadmap_items` field to state.json entries for explicit task-roadmap linking, (2) Update /review to use explicit mappings first, fall back to fuzzy matching, (3) Update /task create to optionally specify linked roadmap items, (4) Improve fuzzy matching heuristics.

Task 639 proposes a valuable solution: **explicit task-to-roadmap mappings** in state.json. However:
- It only mentions `/review`, not `/todo`
- It doesn't address the fundamental issue that `/todo` uses exact matching only

### Finding 4: Matching Strategy Comparison

**`/todo` command (Step 3.5)**:
```bash
matches=$(grep -n "(Task ${project_num})" specs/ROAD_MAP.md 2>/dev/null || true)
```
- Single strategy: exact `(Task {N})` match
- No fallback
- Documented as "Title fuzzy matching planned for future enhancement (task 639)"

**`/review` command (Step 2.5.2)**:
```markdown
| Match Type | Confidence | Action |
|------------|------------|--------|
| Item contains `(Task {N})` | High | Auto-annotate |
| Item text matches task title | Medium | Suggest annotation |
| Item's file path exists | Medium | Suggest annotation |
| Partial keyword match | Low | Report only |
```
- Multiple strategies with confidence levels
- But "fuzzy title matching is unreliable" per task 639

**Key insight**: `/review` has better matching architecture but unreliable implementation. `/todo` has simpler matching but zero coverage.

### Finding 5: Shared Utility Pattern Opportunity

Currently, both commands implement matching logic inline:
- `/todo`: Lines 136-166 (exact match only)
- `/review`: Lines 105-156 (multi-strategy but unreliable)

A shared utility would:
1. Centralize matching logic
2. Enable consistent improvements
3. Allow both commands to benefit from task 639 work

**Proposed shared pattern** (`.claude/context/core/patterns/roadmap-matching.md`):

```markdown
# Roadmap Matching Pattern

## Matching Strategies (Priority Order)

1. **Explicit mapping** (state.json `roadmap_items` field) - Highest confidence
2. **Exact reference** (`(Task {N})` in roadmap) - High confidence
3. **Title keyword match** (2+ non-common keywords) - Medium confidence
4. **File path existence** (referenced path exists) - Medium confidence

## Shared Implementation

All roadmap-matching commands should:
1. Check explicit mappings first (if 639 implemented)
2. Fall back to exact reference matching
3. Optionally use fuzzy matching (configurable)

## Common Keywords to Exclude

fix, add, update, implement, improve, create, remove, the, a, to, in, for, of, with
```

### Finding 6: Command Architecture Comparison

| Aspect | /todo | /review | /revise |
|--------|-------|---------|---------|
| Roadmap interaction | Yes (Step 3.5, 5.5) | Yes (Step 2.5.x) | No |
| Matching strategy | Exact only | Multi-strategy | N/A |
| When updates occur | At archival | At review | Never |
| Confidence levels | None | High/Medium/Low | N/A |
| User confirmation | No | Yes (for medium) | N/A |

## Recommendations

### Option A: Extend Task 641 Scope (Recommended)

Consolidate roadmap improvements for both `/todo` and `/review`:

1. **Create shared matching utility** (`roadmap-matching.md` pattern)
2. **Implement title keyword matching** for `/todo` (from research-001.md)
3. **Absorb task 639** into task 641 as a subtask or close as duplicate
4. **Update both commands** to use shared pattern

**Pros**: Single source of truth, consistent behavior
**Cons**: Larger scope, more implementation work

### Option B: Split Work Across Tasks

- **Task 641**: Fix `/todo` with title keyword matching (as in research-001.md)
- **Task 639**: Fix `/review` with explicit mappings and improved fuzzy matching

**Pros**: Smaller, focused tasks
**Cons**: Duplicate effort, potential inconsistency

### Option C: Consolidate Roadmap Updates to /review Only

- Remove roadmap updates from `/todo` entirely
- Document that `/review` handles all roadmap annotations
- Users run `/review` periodically for roadmap maintenance

**Pros**: Single responsibility
**Cons**: Feels like regression from task 638, extra step for users

## Implementation Recommendation

**Recommended: Option A** with the following approach:

### Phase 1: Create Shared Pattern
Create `.claude/context/core/patterns/roadmap-matching.md` documenting:
- Matching strategies with confidence levels
- Common keywords to exclude
- Implementation guidelines

### Phase 2: Implement Title Keyword Matching
Add to `/todo` command (Step 3.5):
```bash
# After exact match check, try title keyword matching
if [ -z "$matches" ]; then
  # Extract keywords from task name
  keywords=$(echo "$project_name" | tr '_' ' ' | tr -s ' ')

  # Search for lines containing 2+ keywords
  for line in $(grep -n "^\- \[ \]" specs/ROAD_MAP.md); do
    line_lower=$(echo "$line" | tr '[:upper:]' '[:lower:]')
    match_count=0
    for keyword in $keywords; do
      # Skip common words
      case "$keyword" in
        fix|add|update|implement|improve|create|remove|the|a|to|in|for|of|with) continue ;;
      esac
      if echo "$line_lower" | grep -qw "$keyword"; then
        ((match_count++))
      fi
    done
    if [ $match_count -ge 2 ]; then
      # High-confidence fuzzy match
      fuzzy_matches+=("$line")
    fi
  done
fi
```

### Phase 3: Apply Same Pattern to /review
Update `/review` to use consistent matching logic from shared pattern.

### Phase 4: Prepare for Task 639 Explicit Mappings
Document how `roadmap_items` field would integrate with shared pattern when task 639 is implemented.

## Task Scope Decision

**Recommendation**: Expand task 641 description to include:

1. `/todo` title keyword matching (primary)
2. Shared roadmap-matching.md pattern creation
3. `/review` matching alignment (if time permits)

Mark task 639 as a **dependency** or **subtask** for the explicit mapping feature, which can be implemented later.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Scope creep | Medium | Medium | Clearly define Phase 1-2 as minimum viable |
| Inconsistent matching | High | Low | Shared pattern ensures consistency |
| False positives from fuzzy matching | Medium | Medium | Require 2+ keyword matches, exclude common words |
| Task 639 work duplicated | Low | Low | Document relationship, mark as related |

## Appendix

### Files Examined

- `/home/benjamin/Projects/ProofChecker/.claude/commands/revise.md` (211 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/commands/todo.md` (631 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/commands/review.md` (449 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/context/core/patterns/roadmap-update.md` (101 lines)
- `/home/benjamin/Projects/ProofChecker/specs/ROAD_MAP.md` (first 150 lines + pattern search)
- `/home/benjamin/Projects/ProofChecker/specs/TODO.md` (task 639 description)
- `/home/benjamin/Projects/ProofChecker/specs/state.json` (task 639 status)

### ROAD_MAP.md Statistics

| Metric | Count |
|--------|-------|
| Unchecked items (`- [ ]`) | 79 |
| Checked items (`- [x]`) | 10 |
| Explicit `(Task N)` references | 0 |

### Related Tasks

- **Task 638**: Implemented roadmap update in `/todo` (exact matching only) - COMPLETED
- **Task 639**: Improve `/review` roadmap matching - NOT STARTED
- **Task 637**: Manual roadmap checkbox fixes - COMPLETED
- **Task 641**: This task - improve `/todo` roadmap updates

### /revise Command Structure Summary

```
CHECKPOINT 1: GATE IN
  - Generate session ID
  - Lookup task
  - Route by status:
    * planned/implementing/partial/blocked -> Stage 2A (Plan Revision)
    * not_started/researched -> Stage 2B (Description Update)
    * completed/abandoned -> ABORT

STAGE 2A: Plan Revision
  - Load current plan
  - Analyze changes
  - Create new version (implementation-002.md, etc.)
  - Update status to "planned"

STAGE 2B: Description Update
  - Read current description
  - Validate revision reason provided
  - Update state.json and TODO.md

CHECKPOINT 2: GATE OUT
  - Verify artifacts created/updated

CHECKPOINT 3: COMMIT
  - Git commit with session ID
```

**No roadmap interaction in any stage** - correctly scoped command.

## Next Steps

1. Run `/plan 641` to create implementation plan incorporating both research reports
2. Consider absorbing task 639 or marking as subtask
3. Implement shared matching pattern and title keyword matching
