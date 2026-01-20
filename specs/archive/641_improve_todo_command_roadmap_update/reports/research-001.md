# Research Report: Task #641

**Task**: improve_todo_command_roadmap_update
**Date**: 2026-01-20
**Effort**: 2-3 hours
**Priority**: Medium
**Dependencies**: None (builds on task 638)
**Sources/Inputs**: /todo command output, task 638 artifacts, ROAD_MAP.md, codebase analysis
**Artifacts**: This report
**Standards**: report-format.md

## Executive Summary

- The `/todo` command's roadmap update feature (implemented in task 638) works correctly but is **effectively useless** in its current form
- The feature only matches exact `(Task {N})` patterns, but ROAD_MAP.md contains **zero** such patterns
- This is NOT an order-of-operations issue - the roadmap scan (Step 3.5) correctly occurs BEFORE archival (Step 5)
- The fundamental problem is a **matching strategy gap**: roadmap items don't use task references, so the feature never finds anything to update
- Task 639 was supposed to add title fuzzy matching but was never implemented - this is the missing piece

## Context & Scope

### Problem Statement

User ran `/todo` after task 638 (which implemented roadmap updates) was completed, but the output showed "No roadmap updates needed." The user suspected an order-of-operations bug where archival might happen before roadmap scanning.

### Investigation Approach

1. Analyzed the `/todo` command output log at `.claude/output/todo.md`
2. Reviewed the `/todo` command implementation at `.claude/commands/todo.md`
3. Examined task 638's research, plan, and summary artifacts
4. Verified ROAD_MAP.md contents for `(Task N)` patterns
5. Traced the execution flow in the output log

## Findings

### Finding 1: Order of Operations is Correct

The output log clearly shows the roadmap scan happens BEFORE archival:

| Line | Operation | Description |
|------|-----------|-------------|
| 46-47 | Step 3.5 | `Search(pattern: "\(Task (633|637|638|635|636|634)\)")` - returns 0 |
| 73-77 | Step 5 | `jq --slurpfile main specs/state.json...` - archival operations |

**Conclusion**: The order of operations is NOT the problem. Step 3.5 (scan roadmap) runs correctly before Step 5 (archive tasks).

### Finding 2: ROAD_MAP.md Has Zero Task References

Searched ROAD_MAP.md for `(Task N)` patterns:

```bash
grep -c "(Task [0-9]" specs/ROAD_MAP.md  # Returns: 0
```

The roadmap file (726 lines) contains:
- 79 unchecked items (`- [ ]`)
- 10 checked items (`- [x]`)
- 0 explicit `(Task N)` references

This explains why the feature reports "No roadmap updates needed" - there's nothing to match.

### Finding 3: Task 638 Implementation Was Limited by Design

Task 638's research explicitly noted:

> **Decision**: Exact `(Task {N})` match only for initial implementation; title matching requires user confirmation

The implementation plan deferred title fuzzy matching to task 639:

> Title fuzzy matching planned for future enhancement (task 639)

This was a conscious scope limitation, not a bug.

### Finding 4: Task 639 Never Implemented the Missing Feature

Task 639 "improve_review_roadmap_matching" has status `[NOT STARTED]` in state.json. The critical title fuzzy matching feature that would make roadmap updates useful was never built.

### Finding 5: Matching Strategy Gap Analysis

| Match Type | Task 638 | ROAD_MAP.md | Usefulness |
|------------|----------|-------------|------------|
| Exact `(Task {N})` | Implemented | 0 occurrences | Zero (nothing to match) |
| Title fuzzy | Not implemented | Many potential matches | High (if implemented) |
| File path | Not implemented | Some file references | Medium |

The feature is architecturally complete but practically useless because the only implemented matching strategy has no targets in the roadmap.

### Finding 6: Current Codebase `(Task N)` References

Searched all of specs/ for `(Task N)` patterns:
- Found 100+ occurrences in **archived task artifacts** (research reports, plans)
- Found 0 occurrences in **ROAD_MAP.md**
- Found a few in active task descriptions in TODO.md

The pattern is used in documentation but never in roadmap items.

## Root Cause Analysis

```
User expectation: /todo archives tasks AND updates roadmap checkboxes
Actual behavior: /todo archives tasks but finds no roadmap matches

Root cause chain:
1. ROAD_MAP.md items don't contain (Task N) references
2. The only implemented matching strategy is exact (Task N) matching
3. Therefore: 0 items match, 0 updates occur
4. This is by design (task 638 deferred fuzzy matching to task 639)
5. Task 639 was never implemented
```

## Recommendations

### Option A: Implement Title Fuzzy Matching (Recommended)

Add the title matching that task 639 was supposed to provide, but integrate it directly into `/todo`:

**Matching Strategy**:
```bash
# For each archivable task, tokenize the task name
task_name="fix_roadmap_checkboxes_not_updated"
keywords=$(echo "$task_name" | tr '_' ' ')  # "fix roadmap checkboxes not updated"

# Search for roadmap items containing keywords
grep -n "roadmap.*checkbox" specs/ROAD_MAP.md
```

**Confidence Levels**:
- High (3+ keyword matches): Auto-annotate
- Medium (2 keywords): Auto-annotate with warning
- Low (1 keyword): Skip or ask user

**Pros**: Makes the feature actually useful
**Cons**: Higher risk of false positives, more implementation complexity

### Option B: Add Manual Task References to ROAD_MAP.md

When creating roadmap items, explicitly add `(Task N)` references:

```markdown
# Before
- [ ] Fix proof dependencies

# After
- [ ] Fix proof dependencies (Task 334)
```

**Pros**: Works with existing exact matching, no code changes
**Cons**: Requires discipline, retrofitting existing items is tedious

### Option C: Hybrid Approach

1. Implement conservative title matching (high confidence only)
2. Add `(Task N)` references when creating new roadmap items
3. Periodically run `/review` which has better matching (per roadmap-update.md)

**Pros**: Balances automation with safety
**Cons**: Two different matching strategies may confuse users

### Option D: Consolidate with /review

The `/review` command already has comprehensive roadmap integration. Instead of duplicating matching logic:

1. Remove roadmap updates from `/todo` entirely
2. Document that `/review` handles roadmap annotations
3. Users run `/review` after `/todo` for roadmap cleanup

**Pros**: Single source of truth for roadmap updates
**Cons**: Extra step for users, may feel like regression

## Implementation Recommendation

**Recommended: Option A (Title Fuzzy Matching)** with the following enhancements:

### Phase 1: Title Keyword Extraction
```bash
# Convert task name to keywords
project_name="fix_roadmap_checkboxes_not_updated"
keywords=$(echo "$project_name" | tr '_' ' ' | tr -d '[:punct:]')
```

### Phase 2: Roadmap Item Scanning
```bash
# For each unchecked roadmap item
while IFS= read -r line; do
  line_lower=$(echo "$line" | tr '[:upper:]' '[:lower:]')
  match_count=0
  for keyword in $keywords; do
    if echo "$line_lower" | grep -q "$keyword"; then
      ((match_count++))
    fi
  done
  if [ $match_count -ge 2 ]; then
    # High-confidence match
    matches+=("$line")
  fi
done < <(grep "- \[ \]" specs/ROAD_MAP.md)
```

### Phase 3: Annotation
Apply same annotation format as task 638:
```markdown
- [x] {item} *(Completed: Task {N}, {DATE})*
```

### Safety Enhancements

1. **Require minimum 2 keyword matches** to reduce false positives
2. **Exclude common words**: "fix", "add", "update", "implement", "the", "a", "to"
3. **Preview in dry-run**: Show proposed matches with confidence scores
4. **Skip already-annotated**: Preserve idempotency

## Complexity Assessment

| Component | Effort | Risk |
|-----------|--------|------|
| Keyword extraction | 15 min | Low |
| Roadmap scanning with matching | 30 min | Medium |
| Integration with existing Step 3.5 | 20 min | Low |
| Testing and validation | 30 min | Medium |
| Documentation updates | 15 min | Low |
| **Total** | **~2 hours** | **Medium** |

## Decisions

1. **Root cause**: Feature works correctly but matching strategy has no targets
2. **Not a bug**: This is expected behavior given the implementation scope
3. **Path forward**: Implement title fuzzy matching (Option A)
4. **Task 639 status**: Can be absorbed into task 641 or remain separate

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| False positive matches | Medium | Medium | Require 2+ keyword matches, exclude common words |
| Over-annotation | Low | Low | Skip already-annotated items |
| Performance on large roadmaps | Low | Low | ROAD_MAP.md is ~730 lines, grep is fast |
| User confusion about matching | Medium | Medium | Clear dry-run output showing match reasons |

## Appendix

### Files Examined

- `/home/benjamin/Projects/ProofChecker/.claude/output/todo.md` (execution log, 571 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/commands/todo.md` (command implementation, 631 lines)
- `/home/benjamin/Projects/ProofChecker/specs/ROAD_MAP.md` (roadmap, 726 lines)
- `/home/benjamin/Projects/ProofChecker/specs/archive/638_add_roadmap_update_to_todo_command/reports/research-001.md`
- `/home/benjamin/Projects/ProofChecker/specs/archive/638_add_roadmap_update_to_todo_command/plans/implementation-001.md`
- `/home/benjamin/Projects/ProofChecker/specs/archive/638_add_roadmap_update_to_todo_command/summaries/implementation-summary-20260120.md`
- `/home/benjamin/Projects/ProofChecker/specs/state.json`
- `/home/benjamin/Projects/ProofChecker/.claude/context/core/patterns/roadmap-update.md`

### Key Evidence

**Output log line 46-47 (Step 3.5 execution)**:
```
Search(pattern: "\(Task (633|637|638|635|636|634)\)", path: "specs/ROAD_MAP.md", output_mode: "content")
  ⎿  Found 0 lines
```

**Output log line 566-567 (Summary)**:
```
- No roadmap updates needed (no (Task N) references for archived tasks)
```

**ROAD_MAP.md verification**:
```bash
grep -c "(Task [0-9]" specs/ROAD_MAP.md  # 0
```

### Related Tasks

- **Task 638**: Implemented roadmap update capability with exact matching only
- **Task 639**: Intended to improve roadmap matching - status: NOT STARTED
- **Task 637**: Manually fixed 10 roadmap checkboxes, demonstrating the need

## Next Steps

Run `/plan 641` to create implementation plan for title fuzzy matching integration.
