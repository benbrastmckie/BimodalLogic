# Implementation Summary: Harmonize /implement and /task command flows for plan-driven execution

- **Task**: 115 - Harmonize /implement and /task command flows for plan-driven execution
- **Date**: 2025-12-22
- **Status**: [COMPLETED]
- **Scope**: Align /implement and /task behaviors for plan-driven execution with consistent status syncing, lazy directory creation, and plan path reuse.

## What Changed
- Updated `.opencode/command/implement.md` to require a plan path, load status/artifact standards, enforce lazy directory creation, sync TODO/state, and fail fast when the plan path is missing.
- Added command-integration guidance to `.opencode/context/common/standards/tasks.md` covering /task plan reuse and /implement plan requirements.
- Extended `.opencode/context/common/system/artifact-management.md` with contract notes for /task and /implement, emphasizing plan reuse and lazy directory creation.

## Artifacts & Files Modified
- `.opencode/command/implement.md`
- `.opencode/context/common/standards/tasks.md`
- `.opencode/context/common/system/artifact-management.md`

## Verification
- Acceptance criteria addressed: /implement plan-path requirement and lazy creation guardrail documented; /task plan reuse and TODO/state sync documented; usage/help behaviors clarified.

## Next Steps
- Add runtime validation to /implement and /task executors to enforce plan-path presence and lazy directory creation at execution time.
