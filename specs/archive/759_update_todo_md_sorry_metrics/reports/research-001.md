# Research Report: Task #759

**Task**: update_todo_md_sorry_metrics
**Date**: 2026-01-29
**Focus**: Review all commands that update repo-wide metadata (sorry count, task counts, etc.) to identify candidate improvements for /todo command

## Executive Summary

- TODO.md header contains YAML frontmatter with repo-wide metrics that are NOT in state.json
- state.json is supposed to be the source of truth, but TODO.md has metrics that state.json lacks
- The /review command computes sorry_count but never persists it to either file
- The /todo command focuses only on task archival, not repo-wide metric synchronization
- Key improvement: Add a "sync metrics" step to /todo that updates TODO.md header from computed values

## Current State Analysis

### Metadata Locations

**TODO.md Header (YAML Frontmatter)**:
```yaml
next_project_number: 760
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-17T02:30:00Z
task_counts:
  active: 10
  completed: 317
  in_progress: 3
  not_started: 5
  abandoned: 21
  total: 341
priority_distribution:
  critical: 0
  high: 4
  medium: 4
  low: 5
technical_debt:
  sorry_count: 205       # STALE - actual count is 275!
  axiom_count: 15
  build_errors: 0
  status: manageable
```

**state.json**:
```json
{
  "metadata": {...},
  "active_projects": [...],
  "completed_projects": [...],
  "next_project_number": 760,
  "task_counts": {
    "active": 15,
    "not_started": 8,
    "total": 334
  }
}
```

### Key Discrepancy

| Field | TODO.md Header | state.json | Actual |
|-------|---------------|------------|--------|
| sorry_count | 205 | NOT PRESENT | 275 |
| axiom_count | 15 | NOT PRESENT | ~7 (per SORRY_REGISTRY) |
| build_errors | 0 | NOT PRESENT | Unknown |
| task_counts.active | 10 | 15 | 15 |
| task_counts.total | 341 | 334 | Unknown |

**Root Problem**: TODO.md has repo-wide technical debt metrics that:
1. Are not present in state.json (the supposed source of truth)
2. Are never systematically updated by any command
3. Drift out of sync over time

## Commands Review

### Commands That Should Update Metrics

| Command | Computes Metrics | Persists to state.json | Persists to TODO.md |
|---------|-----------------|----------------------|-------------------|
| `/review` | Yes (sorry_count) | No | No |
| `/lake` | Yes (build_errors) | No | No |
| `/todo` | No | No | No |
| `/task` | No | task_counts indirectly | No |
| `/implement` | No | No | No |

### Detailed Command Analysis

#### /review Command

**What it does**:
- Step 2.5.2: `grep -r "sorry" Logos/ --include="*.lean" | wc -l` to count sorries
- Reports in review report under "Code Quality Metrics"
- Creates `specs/reviews/review-{DATE}.md` with metrics

**Gap**: Never updates TODO.md header or state.json with computed metrics.

#### /lake Command

**What it does**:
- Runs `lake build` and parses errors
- Creates tasks for unfixable errors
- Reports build status

**Gap**: Never updates `build_errors` count in TODO.md header.

#### /todo Command

**What it does**:
- Archives completed/abandoned tasks
- Updates ROAD_MAP.md with completions
- Handles orphaned directories
- Processes CLAUDE.md suggestions from meta tasks

**Gap**:
- Never recomputes or updates repository-wide metrics
- Does not sync task_counts between state.json and TODO.md
- Does not update sorry_count, axiom_count, build_errors

#### /task Command

**What it does**:
- Creates new tasks in state.json and TODO.md
- Updates next_project_number in both files

**Gap**: Does not update task_counts fields.

#### /implement Command

**What it does**:
- Executes implementation phases
- Updates task status to completed
- Adds completion_summary to state.json

**Gap**: Does not update sorry_count even when implementation changes proof files.

### External Registries

**SORRY_REGISTRY.md** (`docs/project-info/`):
- Manually maintained
- Claims "Total Active Placeholders: 46" (also stale)
- Has verification commands that should be run

**IMPLEMENTATION_STATUS.md** (`docs/project-info/`):
- Claims "Sorry count: 46 active placeholders" (from 2026-01-15)
- Also stale vs actual count of 275

## Gap Analysis

### Missing Updates

1. **sorry_count**: Never automatically updated by any command
   - `/review` computes but doesn't persist
   - `/implement` doesn't recompute after proof changes
   - `/todo` doesn't compute

2. **axiom_count**: Never automatically updated
   - No command computes axiom count

3. **build_errors**: Never automatically updated
   - `/lake` runs builds but doesn't persist error count

4. **task_counts**: Partially maintained
   - state.json has limited version
   - TODO.md header has expanded version
   - Neither is systematically updated

5. **repository_health**: Stale
   - last_assessed shows 2026-01-17
   - overall_score based on outdated metrics

### Missing Source of Truth

state.json should have:
```json
{
  "repository_health": {
    "overall_score": 90,
    "last_assessed": "ISO8601",
    "production_readiness": "improved"
  },
  "technical_debt": {
    "sorry_count": 275,
    "axiom_count": 7,
    "build_errors": 0,
    "status": "manageable"
  },
  "task_counts": {
    "active": 15,
    "completed": 317,
    "in_progress": 3,
    "not_started": 5,
    "abandoned": 21,
    "total": 341
  }
}
```

TODO.md header should be synced FROM state.json, not the other way around.

## Improvement Recommendations

### Priority 1: Add Metrics Sync to /todo

**What**: Add a "sync repository metrics" step to /todo command (Section 5.7)

**Why**: /todo is the natural place for periodic cleanup and sync operations

**How**:
```markdown
### 5.7. Sync Repository Metrics

**Step 5.7.1: Compute current metrics**:
```bash
# Count sorries
sorry_count=$(grep -r "sorry" Theories/ --include="*.lean" | wc -l)

# Count axioms
axiom_count=$(grep -r "^axiom " Theories/ --include="*.lean" | wc -l)

# Count tasks by status from state.json
active_count=$(jq '.active_projects | length' specs/state.json)
completed_count=$(jq '.completed_projects | length' specs/archive/state.json)
# etc.
```

**Step 5.7.2: Update state.json with repository_health**:
```bash
jq --arg sorry "$sorry_count" --arg axiom "$axiom_count" \
   --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   '. + {
     "repository_health": {
       "last_assessed": $ts,
       "sorry_count": ($sorry | tonumber),
       "axiom_count": ($axiom | tonumber)
     }
   }' specs/state.json
```

**Step 5.7.3: Regenerate TODO.md frontmatter from state.json**
```

### Priority 2: Add state.json Schema for Repository Metrics

**What**: Add `repository_health` and `technical_debt` sections to state.json schema

**Why**: state.json should be the single source of truth

**Where**: Update `.claude/context/core/templates/state-template.json`

### Priority 3: Update /review to Persist Metrics

**What**: After computing sorry_count and metrics in Step 2.5.2, persist to state.json

**Why**: /review is explicitly computing these values but throwing them away

**How**: Add step 4.6 to write computed metrics to state.json

### Priority 4: Add --metrics Flag to /todo

**What**: `--metrics` flag to ONLY sync metrics without archiving

**Why**: Allow metrics update independent of task archival

**Example**: `/todo --metrics` - just updates counts without archiving

### Priority 5: Create /metrics Command (Optional)

**What**: Dedicated command for repository health metrics

**Why**: Separation of concerns - /todo is for task archival

**How**: Simple command that:
1. Computes sorry_count, axiom_count, build_errors
2. Computes task_counts from state.json
3. Updates state.json repository_health
4. Syncs TODO.md frontmatter
5. Optionally runs lake build to check build status

## Implementation Approach

### Phase 1: state.json Schema Update
1. Add `repository_health` section to state.json
2. Add `technical_debt` section to state.json
3. Migrate existing task_counts to expanded format

### Phase 2: /todo Metrics Sync
1. Add Section 5.7 to compute and persist metrics
2. Add --metrics flag for metrics-only operation
3. Update Section 6 (git commit) to include metrics sync

### Phase 3: /review Integration
1. Add step 4.6 to persist computed metrics
2. Update state.json with sorry_count after scan

### Phase 4: Documentation
1. Update CLAUDE.md State Synchronization section
2. Update state-management.md with new fields
3. Document when metrics are updated

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Slow sorry count computation on large repos | /todo becomes slow | Cache in state.json, only recompute periodically |
| TODO.md frontmatter format breaks | Parsing errors | Use robust YAML parsing, test edge cases |
| state.json schema change breaks existing queries | Commands fail | Backwards-compatible additions only |

## Next Steps

Run `/plan 759` to create implementation plan based on these findings.

## Appendix: Search Queries Used

- `grep -r "sorry" Theories/ --include="*.lean" | wc -l` - Count current sorries
- `grep sorry_count .claude/` - Find metadata references
- `grep task_counts .claude/` - Find task count handling
- Reviewed: /todo, /review, /lake, /task, /implement commands

## References

- `specs/TODO.md` - Current header format
- `specs/state.json` - Current structure
- `.claude/commands/todo.md` - /todo implementation
- `.claude/commands/review.md` - /review implementation
- `.claude/context/core/templates/state-template.json` - Schema template
- `docs/project-info/SORRY_REGISTRY.md` - Manual sorry tracking
