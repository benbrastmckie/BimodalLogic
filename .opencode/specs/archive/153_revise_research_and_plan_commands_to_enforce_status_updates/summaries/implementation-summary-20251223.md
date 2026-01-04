# Implementation Summary - 2025-12-23

## Task
- **153. Revise /research and /plan commands to enforce status updates**
- **Scope**: Align command flows with status-marker lifecycle so research and planning set `[IN PROGRESS]` immediately and land on `[RESEARCHED]` or `[PLANNED]` upon completion while honoring lazy directory creation and state/TODO sync.

## Changes
1) **/research command**: Explicitly requires preflight `[IN PROGRESS]` before routing; postflight now sets TODO/state to `[RESEARCHED]` with timestamps, keeps lazy creation to reports only, and records phase/status `researched` in state.
2) **/plan command**: Preflight `[IN PROGRESS]` before routing; plan creation keeps plan-level `[IN PROGRESS]` while phases remain `[NOT STARTED]`; postflight sets TODO/state to `[PLANNED]` with timestamps and status `planned` without extra subdir creation.
3) **Status markers standard**: Added command-specific completion markers `[RESEARCHED]` and `[PLANNED]`, clarified required timestamps, lazy-creation guardrail, and expanded state status values (`researched`, `planned`).

## Files Touched
- `.opencode/command/research.md`
- `.opencode/command/plan.md`
- `.opencode/context/core/system/status-markers.md`

## Status
- TODO/state updated to reflect work completion and summary link. No plans or reports were created for this task.
