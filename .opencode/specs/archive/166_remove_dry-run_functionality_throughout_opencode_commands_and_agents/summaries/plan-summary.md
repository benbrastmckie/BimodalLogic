# Plan Summary: Remove Dry-Run Functionality Throughout .opencode Commands and Agents

**Version**: 001
**Complexity**: Moderate
**Estimated Effort**: 2.5-3.5 hours
**Status**: [IN PROGRESS]
**Created**: 2025-12-24

## Key Steps

1. **Inventory and Documentation** (30-45 min): Create comprehensive inventory of all 49+ dry-run references across 17 files; document preservation boundaries for lazy creation, status markers, and registry sync.

2. **Update Standards and Templates** (20-30 min): Remove dry-run from foundational standards (commands.md, tasks.md, git-commits.md) to establish new baseline without dry-run functionality.

3. **Remove Dry-Run from High-Usage Commands** (60-75 min): Update optimize.md (13 refs), plan.md (8 refs), research.md (7 refs), and revise.md (6 refs); preserve MCP validation, status markers, and lazy creation.

4. **Remove Dry-Run from Remaining Commands** (45-60 min): Update 9 remaining command files (meta, review, refactor, lean, implement, document, context, add, README) with same preservation rules.

5. **Remove Dry-Run from Agent Files** (15-20 min): Update batch-task-orchestrator.md and any other agent files; preserve validation and status tracking logic.

6. **Comprehensive Testing and Validation** (30-45 min): Test lazy directory creation, status marker flows, language routing, registry sync, and command execution; verify complete removal via grep searches.

7. **Update TODO and State** (10-15 min): Mark task 166 as complete in TODO.md and state.json; create plan summary.

## Dependencies

- **Preserve**: Lazy directory creation (no dirs without artifacts)
- **Preserve**: Status marker flows (NOT STARTED → IN PROGRESS → COMPLETED)
- **Preserve**: TODO/state sync and registry integrity
- **Preserve**: Language metadata routing (Lean detection and MCP validation)
- **Preserve**: Pre-flight validation (task checks, input validation, MCP pings)

## Success Criteria

- All 49+ dry-run references removed from 17 files (13 commands, 1 agent, 3 standards)
- No `dry_run:` YAML fields remain in command files
- No `--dry-run` or `--routing-check` flags in usage/examples
- Lazy directory creation still works (no dirs without artifacts)
- Status markers sync correctly across TODO/plan/state
- Language routing works (Lean detection, MCP validation)
- Registry sync intact (IMPLEMENTATION_STATUS, SORRY_REGISTRY, TACTIC_REGISTRY)
- All manual tests pass (lazy creation, status markers, command execution)
- Grep searches confirm complete removal

## Risks & Mitigations

- **Risk**: Accidentally removing essential pre-flight validation
  - **Mitigation**: Carefully distinguish dry-run logic from general validation; preserve all MCP validation, task checks, input validation

- **Risk**: Incomplete removal leading to inconsistent behavior
  - **Mitigation**: Use comprehensive grep searches; create inventory checklist before changes

- **Risk**: Breaking lazy directory creation or status marker synchronization
  - **Mitigation**: Review artifact-management.md and status-markers.md before changes; test thoroughly after each phase

## Full Plan

See: .opencode/specs/166_remove_dry-run_functionality_throughout_opencode_commands_and_agents/plans/implementation-001.md
