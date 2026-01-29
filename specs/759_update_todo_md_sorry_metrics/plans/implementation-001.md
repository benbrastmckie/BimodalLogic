# Implementation Plan: Task #759

- **Task**: 759 - update_todo_md_sorry_metrics
- **Status**: [COMPLETED]
- **Effort**: 2.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/759_update_todo_md_sorry_metrics/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Update TODO.md header metrics to reflect current sorry count and establish systematic metrics synchronization. The research found that TODO.md has repository-wide metrics (sorry_count, axiom_count, build_errors) that are never automatically updated by any command, causing drift from actual values. This plan addresses the immediate discrepancy (sorry_count showing 205 vs actual 275) and adds metrics sync capability to the /todo command.

### Research Integration

- Research report: specs/759_update_todo_md_sorry_metrics/reports/research-001.md (integrated 2026-01-29)
- Key findings: TODO.md header has YAML frontmatter metrics not present in state.json; no command systematically updates these; /review computes but doesn't persist; /todo is natural place for periodic sync

## Goals & Non-Goals

**Goals**:
- Update TODO.md header to show correct sorry_count (275 vs stale 205)
- Add repository_health section to state.json schema
- Add metrics sync step (Section 5.7) to /todo command
- Ensure metrics are updated each time /todo runs

**Non-Goals**:
- Creating separate /metrics command (deferred per Priority 5)
- Modifying /review to persist metrics (separate task)
- Modifying /implement to track sorry changes (separate task)
- Real-time metrics tracking (periodic sync is sufficient)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| TODO.md frontmatter parsing breaks | H | L | Test YAML parsing with edge cases; use robust pattern matching |
| state.json schema change breaks queries | M | L | Backwards-compatible additions only; test existing jq queries |
| Slow sorry count on large repos | L | M | Grep is fast; cache result in state.json for subsequent operations |
| Task count mismatch between state.json and TODO.md | M | M | Compute from state.json (source of truth), not re-parse TODO.md |

## Implementation Phases

### Phase 1: Fix Immediate Metrics Discrepancy [COMPLETED]

**Goal**: Update TODO.md header to show accurate sorry_count

**Tasks**:
- [ ] Compute current sorry_count: `grep -r "sorry" Theories/ --include="*.lean" | wc -l`
- [ ] Compute current axiom_count: `grep -r "^axiom " Theories/ --include="*.lean" | wc -l`
- [ ] Update TODO.md header YAML frontmatter with corrected values
- [ ] Update last_assessed timestamp to current date

**Timing**: 30 minutes

**Files to modify**:
- `specs/TODO.md` - Update technical_debt section in YAML frontmatter

**Verification**:
- `grep "sorry_count" specs/TODO.md` shows correct value
- `grep "axiom_count" specs/TODO.md` shows correct value
- Header parses as valid YAML

---

### Phase 2: Add Repository Metrics to state.json Schema [COMPLETED]

**Goal**: Establish state.json as source of truth for repository-wide metrics

**Tasks**:
- [ ] Add repository_health section to state.json with sorry_count, axiom_count, build_errors, last_assessed
- [ ] Update state-template.json with new schema fields
- [ ] Update state-management.md to document new fields
- [ ] Verify existing jq queries still work

**Timing**: 45 minutes

**Files to modify**:
- `specs/state.json` - Add repository_health section
- `.claude/context/core/templates/state-template.json` - Add schema for repository_health
- `.claude/rules/state-management.md` - Document new fields

**Verification**:
- `jq '.repository_health' specs/state.json` returns valid object
- Existing state.json queries still work
- Documentation matches implementation

---

### Phase 3: Add Metrics Sync to /todo Command [COMPLETED]

**Goal**: Automatically sync repository metrics when /todo runs

**Tasks**:
- [ ] Add Section 5.7 "Sync Repository Metrics" to todo.md command
- [ ] Implement sorry_count computation step
- [ ] Implement axiom_count computation step
- [ ] Implement task_counts computation from state.json
- [ ] Add step to update state.json repository_health
- [ ] Add step to regenerate TODO.md frontmatter from state.json

**Timing**: 1 hour

**Files to modify**:
- `.claude/commands/todo.md` - Add Section 5.7 for metrics sync

**Verification**:
- /todo command includes metrics sync steps
- Steps use correct grep patterns
- Steps properly update both state.json and TODO.md

---

### Phase 4: Documentation and Testing [COMPLETED]

**Goal**: Document the new capability and verify end-to-end flow

**Tasks**:
- [ ] Update CLAUDE.md to mention metrics sync in /todo description
- [ ] Test full /todo workflow with metrics sync
- [ ] Verify metrics are correctly computed and persisted
- [ ] Create implementation summary

**Timing**: 15 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - Update /todo command description if needed
- `specs/759_update_todo_md_sorry_metrics/summaries/implementation-summary-20260129.md` - Create summary

**Verification**:
- Documentation accurately describes metrics sync
- End-to-end test shows correct metrics in TODO.md and state.json

---

## Testing & Validation

- [ ] Compute sorry_count manually and verify matches TODO.md header
- [ ] Compute axiom_count manually and verify matches TODO.md header
- [ ] Verify state.json has repository_health section with valid data
- [ ] Run simulated /todo workflow and verify metrics sync steps execute
- [ ] Verify TODO.md frontmatter is valid YAML after update
- [ ] Verify existing jq queries against state.json still work

## Artifacts & Outputs

- `specs/759_update_todo_md_sorry_metrics/plans/implementation-001.md` - This plan
- `specs/759_update_todo_md_sorry_metrics/summaries/implementation-summary-20260129.md` - Implementation summary (Phase 4)
- Updated `specs/TODO.md` - Corrected metrics (Phase 1)
- Updated `specs/state.json` - Repository health section (Phase 2)
- Updated `.claude/commands/todo.md` - Metrics sync section (Phase 3)

## Rollback/Contingency

If implementation causes issues:
1. Revert state.json to remove repository_health section
2. Revert TODO.md frontmatter to previous values
3. Revert todo.md command to remove Section 5.7
4. All changes are additive and can be cleanly reverted via git

If metrics sync is too slow:
- Add --skip-metrics flag to /todo for quick archival-only runs
- Reduce grep scope to specific directories
