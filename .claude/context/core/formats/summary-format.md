# Summary Artifact Standard

**Scope:** Implementation summaries, plan summaries, research summaries, and project rollups produced by /implement, /plan, /research, /review, and related agents.

## Metadata (required)
- **Task**: `{id} - {title}`
- **Status**: `[NOT STARTED]` | `[IN PROGRESS]` | `[BLOCKED]` | `[ABANDONED]` | `[COMPLETED]`
- **Started**: `{ISO8601}` when summary drafting begins
- **Completed**: `{ISO8601}` when published
- **Effort**: `{estimate}` (time to produce summary)
- **Dependencies**: `{list or None}`
- **Artifacts**: list of linked artifacts summarized
- **Standards**: status-markers.md, artifact-management.md, tasks.md, this file

## Structure
1. **Overview** – 2-3 sentences on scope and context.
2. **What Changed** – bullets of key changes/deltas.
3. **Decisions** – bullets of decisions made.
4. **Impacts** – bullets on downstream effects.
5. **Follow-ups** – bullets with owners/due dates if applicable.
6. **References** – paths to artifacts informing the summary.

## Status Marker Usage
- Mark summary status and include Started/Completed timestamps.
- Avoid emojis; rely on text markers only.

## Writing Guidance
- Keep concise (<= 1 page).
- Use bullet lists for clarity.
- Reflect status of underlying work accurately.
- Lazy directory creation: create `summaries/` only when writing this file.

## Example Skeleton (Single-Completion)
```
# Implementation Summary: {title}
- **Task**: {id} - {title}
- **Status**: [COMPLETED]
- **Started**: 2025-12-22T10:00:00Z
- **Completed**: 2025-12-22T10:20:00Z
- **Artifacts**: plans/implementation-001.md

## Overview
...

## What Changed
- ...

## Decisions
- ...

## Impacts
- ...

## Follow-ups
- ...

## References
- ...
```

---

## Incremental Summary Format

For multi-phase implementations, summaries become **running logs** updated after each phase completes. This enables visibility into partial progress and maintains an audit trail across sessions.

### When to Use
- Multi-phase implementation plans (2+ phases)
- Tasks that may span multiple sessions
- Any implementation where partial progress visibility is valuable

### Header (Updated Each Phase)

```markdown
# Implementation Summary: Task #{N}

**Task**: {title}
**Status**: [IN PROGRESS] | [COMPLETED]
**Started**: {ISO_DATE}
**Completed**: {ISO_DATE} (only when all phases done)
**Language**: {lean|meta|general|...}
```

**Status Values**:
- `[IN PROGRESS]` - Some phases complete, more remaining
- `[COMPLETED]` - All phases finished successfully
- `[PARTIAL]` - Implementation paused/blocked mid-phase

### Phase Log Section

The Phase Log contains one entry per completed phase, appended as phases finish:

```markdown
---

## Phase Log

### Phase N: {Phase Name} [COMPLETED]

**Session**: {YYYY-MM-DD}, {session_id}
**Duration**: ~{N} minutes

**Changes Made**:
- {High-level description of what was accomplished}

**Files Modified**:
- `path/to/file.ext` - {change description}

**Files Created**:
- `path/to/new-file.ext` - {purpose}

**Verification**:
- {Build result, test result, or manual verification}

---
```

### Phase Entry Schema

| Field | Required | Description |
|-------|----------|-------------|
| Phase header | Yes | `### Phase N: {Name} [{STATUS}]` |
| Session | Yes | Date and session_id from delegation context |
| Duration | Optional | Approximate time spent |
| Changes Made | Yes | Bullet list of accomplishments |
| Files Modified | Yes | Paths with descriptions |
| Files Created | Optional | New files with purposes |
| Verification | Yes | Build/test results |

### Cumulative Statistics Section

At the end of the summary, maintain running totals:

```markdown
---

## Cumulative Statistics

| Metric | Value |
|--------|-------|
| Phases Completed | {N} of {M} |
| Files Modified | {count} |
| Files Created | {count} |
| Files Deleted | {count} |
| Sorries Delta | {before} -> {after} (Lean only) |
| Build Status | Pass/Fail |
| Overall Status | In Progress/Completed |
```

### Progress vs Summary Distinction

**Progress Subsection** (in plan files):
- Tracks attempts, approaches tried, failures
- Lives in `plans/implementation-{NNN}.md`
- Format: Session header + action verbs (Added, Fixed, Attempted)
- Purpose: Enable resume, prevent re-trying failed approaches

**Summary Phase Entry** (in summary files):
- Documents outcomes and final changes
- Lives in `summaries/implementation-summary-{DATE}.md`
- Format: Phase header + Changes Made + Files + Verification
- Purpose: Audit trail, visibility, artifact linking

Both exist for the same phase but serve different purposes. Progress tracks the journey; Summary documents the destination.

### Create-or-Append Logic

When updating summary after a phase:

1. **Check if summary exists** at `specs/{N}_{SLUG}/summaries/implementation-summary-{DATE}.md`
2. **If not exists**: Create with header and first Phase Entry
3. **If exists**: Append new Phase Entry to Phase Log section
4. **Always update**: Cumulative Statistics section
5. **On final phase**: Change header Status to `[COMPLETED]`, add Completed timestamp

### Incremental Summary Skeleton

```markdown
# Implementation Summary: Task #{N}

**Task**: {title}
**Status**: [IN PROGRESS]
**Started**: {ISO_DATE}
**Language**: {language}

---

## Phase Log

### Phase 0: {Name} [COMPLETED]

**Session**: {YYYY-MM-DD}, {session_id}
**Duration**: ~{N} minutes

**Changes Made**:
- {description}

**Files Modified**:
- `path/to/file` - {change}

**Verification**:
- {result}

---

### Phase 1: {Name} [COMPLETED]

**Session**: {YYYY-MM-DD}, {session_id}

**Changes Made**:
- {description}

**Files Modified**:
- `path/to/file` - {change}

**Verification**:
- {result}

---

## Cumulative Statistics

| Metric | Value |
|--------|-------|
| Phases Completed | 2 of 5 |
| Files Modified | 8 |
| Files Created | 2 |
| Overall Status | In Progress |
```
