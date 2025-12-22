# Implementation Summary: Harmonize /todo and /review lifecycle

**Project**: #108  
**Date**: 2025-12-22

## Overview
Aligned responsibilities between `/todo` (cleanup/archival) and `/review` (ambition/gap analysis) to keep TODO/state/archive/status docs synchronized while preserving numbering and lazy directory creation guardrails.

## Key Changes
- Updated `/todo` command spec to own cleanup/archival, migration to archive/state.json, orphan/stale detection, status normalization, and status-doc synchronization without creating new project directories or altering `next_project_number`.
- Updated `/review` command spec to focus on gap-analysis task generation via `/add`, leaving cleanup/archival untouched, enforcing lazy directory creation, and logging ambitions in status docs.
- Synced lifecycle documentation in FEATURE_REGISTRY.md and IMPLEMENTATION_STATUS.md to reflect the split responsibilities and guardrails.

## Files Updated
- `.opencode/command/todo.md`
- `.opencode/command/review.md`
- `Documentation/ProjectInfo/FEATURE_REGISTRY.md`
- `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`
- `.opencode/specs/TODO.md` (status, acceptance criteria, summary link)

## State & Numbering
- No changes to `next_project_number`; no new project directories created. Project marked completed in TODO/state tracking.

## Next Steps
- Exercise `/todo` on a real cleanup scenario to validate archive/state.json population and orphan/stale detection.
- Exercise `/review` gap-analysis flow to generate new tasks via `/add` and verify lazy directory creation enforcement.
