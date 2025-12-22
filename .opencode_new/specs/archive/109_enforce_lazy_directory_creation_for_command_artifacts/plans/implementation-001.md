# Implementation Plan: Enforce lazy directory creation for command artifacts

**Project**: #109_enforce_lazy_directory_creation_for_command_artifacts  
**Version**: 001  
**Date**: 2025-12-22  
**Complexity**: Moderate (documentation + contract enforcement across commands/agents)

## Overview
Standardize and enforce lazy directory creation for all command/agent artifacts so project roots and subdirectories are only created when writing artifacts, eliminating pre-created empty folders and `.gitkeep` placeholders.

## Objectives
- Update artifact-management standards to explicitly require lazy creation for project roots and subdirectories.
- Audit and revise /research, /plan, /review commands and their subagents to avoid pre-creating trees; use /todo as the guardrail template.
- Remove existing placeholder directories/files (e.g., .gitkeep) and ensure state/TODO/doc references align with the lazy creation contract.
- Add enforcement guidance/guardrails to prevent premature directory creation or state writes absent artifacts.

## Scope / Out-of-scope
- In-scope: Command and agent specifications (/research, /plan, /review, /todo); artifact-management.md; removal of placeholder files in specs; state/TODO/doc reference alignment.
- Out-of-scope: Implementing new runtime tooling beyond documentation/contract updates; changes to numbering schemes or unrelated command behaviors.

## Assumptions / Constraints
- Follow existing standards: state-schema.md, artifact-management.md, tasks.md, patterns.md, task-breakdown.md.
- Project directory already allocated (#109); plans/ created only for this plan file; avoid creating reports/ or summaries/.
- Command files reside in `.opencode/commands/`; agent specs in `.opencode/agent/subagents/` (or similar paths noted in research).
- Lazy creation must apply to both project roots and subdirectories; no `.gitkeep` placeholders.

## Research Inputs
- `.opencode/specs/109_enforce_lazy_directory_creation_for_command_artifacts/reports/research-001.md`

## Risks / Dependencies
- Missing a hidden/pre-existing placeholder directory could leave inconsistency—requires careful inventory.
- Over-tight guardrails might block legitimate artifact writes if conditions are misdocumented.
- Coordination risk: commands and subagents must share the same contract language to avoid drift.

## Phases / Tasks (with estimates & verification)

### Phase 1 (≈1h): Update standards for lazy creation
- Edit `artifact-management.md` to: (a) explicitly state lazy creation for project roots and each subdir; (b) forbid pre-creating unused subdirs and `.gitkeep`; (c) clarify state-write timing (only when an artifact is produced).
- Cross-reference acceptance criteria in the doc where appropriate.
- **Verification:** Standard shows explicit lazy-creation rule for roots and subdirs; `.gitkeep` prohibition noted; state-write timing documented.

### Phase 2 (≈1h): Audit and revise command/agent contracts
- Audit `/research`, `/plan`, `/review`, `/todo` command docs to identify any premature directory creation; document inventory findings inline or in notes.
- Revise `/research` and `/plan` docs to create project root only when writing the first artifact and only the needed subdir (`reports/` or `plans/`) at that time; explicitly forbid pre-creating other subdirs or placeholders.
- Update subagent specs: researcher, planner, reviewer to align with lazy creation (gate directory creation to artifact write, remove assumptions of existing subdirs).
- Preserve `/todo` guardrails as reference; ensure language matches standard.
- **Verification:** Each command/agent doc contains clear guardrails preventing pre-creation; inventory of prior premature behaviors recorded; contracts match lazy creation standard.

### Phase 3 (≈1h): Cleanup and state/TODO/doc alignment
- Remove `.gitkeep` placeholders and any pre-created empty subdirs discovered (e.g., project 108 paths noted in research).
- Ensure no instructions remain to create summaries/ or other unused subdirs; confirm state files are only written when artifacts are created.
- Update TODO/state/doc references if any were relying on pre-created folders; ensure links remain valid after cleanup.
- **Verification:** No `.gitkeep` files remain in specs; directory tree contains only artifact-driven subdirs; TODO/state/doc references remain intact and reflect lazy creation standard.

## Deliverables
- Updated `artifact-management.md` with explicit lazy creation rules and state-write timing.
- Revised command and agent specs (/research, /plan, /review, /todo, and associated subagents) with guardrails and inventory notes.
- Placeholder cleanup (removed `.gitkeep` and empty subdirs) and any adjusted TODO/state/doc references.

## Success Criteria
- Lazy directory creation documented for project roots and subdirectories (acceptance 1).
- Inventory completed for commands/agents with premature creation behaviors (acceptance 2).
- Guardrails added so commands/agents create dirs only when writing artifacts; no `.gitkeep` creation (acceptance 3).
- TODO/state/doc references updated as needed to reflect the standard/command contracts (acceptance 4).

## Testing / Validation
- Manual doc check: confirm standard and command/agent docs include lazy-creation guardrails and forbid placeholders.
- File system check: ensure identified `.gitkeep` files and empty subdirs are removed post-cleanup.
- Spot-run through command workflows (dry-run reasoning) to confirm no step requires pre-existing subdirs beyond artifact-driven creation.

## Timeline / Estimate
- Total ≈ 3 hours (3 phases × ~1h each). Tasks are independent per phase but should be executed in order to avoid drift.

## Next Steps
- Execute Phase 1 updates to artifact-management.md.
- Proceed with command/agent audits and revisions (Phase 2).
- Perform cleanup and reference alignment (Phase 3), then re-verify acceptance criteria.
