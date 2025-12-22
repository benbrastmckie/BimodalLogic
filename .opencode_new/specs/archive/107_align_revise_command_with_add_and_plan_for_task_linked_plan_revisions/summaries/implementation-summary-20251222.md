# Implementation Summary: Align /revise with /add and /plan

**Task:** #107  
**Date:** 2025-12-22  
**Status:** Completed

## Scope
- Harmonized `/revise {task_number} "prompt"` with `/add` and `/plan` contracts.
- Added guardrails for task/plan resolution, versioning, and state/TODO/doc synchronization without creating new project directories or altering numbering.

## Key Changes
- Updated `.opencode/command/revise.md` to require existing plan links, increment plan versions in-place, and sync TODO/state/doc references with clear error handling.
- Clarified `/plan` and `/add` contracts to document directory creation boundaries and the `/revise` dependency on existing plan links.
- Documented revision boundaries in `artifact-management.md` plus registry/status docs (FEATURE_REGISTRY.md, IMPLEMENTATION_STATUS.md).
- Marked Task 107 complete with acceptance criteria satisfied.

## Next Steps
- Use `/implement` on future tasks with existing plan links to exercise the revised `/revise` workflow.
- When revising a task lacking a plan link, instruct users to run `/plan {task}` first per the new guardrails.
