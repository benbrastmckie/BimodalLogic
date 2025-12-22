# Implementation Summary: Enhance /todo to reorganize pending tasks by kind while preserving numbering
- **Task**: 113 - Enhance /todo to reorganize pending tasks by kind while preserving numbering
- **Status**: [COMPLETED]
- **Started**: 2025-12-22T21:25:00Z
- **Completed**: 2025-12-22T21:45:00Z
- **Artifacts**: plans/implementation-001.md

## Overview
Documented grouping rules for /todo so pending tasks can be reorganized by kind without renumbering or creating project directories. Reinforced that reorganization is metadata-only and must respect lazy directory creation.

## What Changed
- Added guidance to tasks.md for regrouping pending tasks by kind while preserving numbering and metadata.
- Stated explicitly that /todo reorganization must not create or modify project directories or artifacts.
- Clarified status wording alignment with status-markers and lazy creation practices.

## Decisions
- Keep numbering stable; grouping is purely presentational.
- Maintain directory creation prohibition during /todo maintenance/reorg operations.

## Impacts
- /todo behavior is clearer and safer for maintenance and categorization.
- Downstream commands have explicit guardrails preventing accidental directory creation.

## Follow-ups
- If command implementations are updated, ensure loaders include tasks.md guidance and enforce no-directory-creation checks.

## References
- plans/implementation-001.md
- .opencode/context/common/standards/tasks.md
