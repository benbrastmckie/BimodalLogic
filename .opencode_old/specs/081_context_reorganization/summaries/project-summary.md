# Project Summary: Context Directory Reorganization

**Project**: #081
**Type**: Maintenance
**Status**: Planned
**Created**: 2025-12-20

## Overview

Reorganize `.opencode/context/` directory to eliminate redundancy and improve organization by consolidating logic domain files, moving type theory to LEAN 4 domain, and integrating project context into core system.

## Scope

**Files to Move**: 6
- 3 logic domain files (metalogic, proof-theory, semantics)
- 1 type theory file
- 2 project context files

**Files to Update**: 14 (40 total references)
- 4 index/README files
- 4 command files
- 1 documentation file
- 5 specs files

**Directories to Remove**: 5 empty source directories

## Complexity

**Level**: MODERATE
**Estimated Effort**: 3.5 hours
**Risk**: MEDIUM (manageable with systematic testing)

## Key Decisions

1. **Replace** brief metalogic/proof-theory files with comprehensive versions
2. **Keep both** Kripke and task semantics files (different frameworks)
3. **Move** type theory to `lean4/domain/` (LEAN 4 content)
4. **Move** project context to `core/system/` (core concerns)
5. **Fix** path inconsistencies in command files

## Benefits

- Eliminate redundancy (brief vs detailed files)
- Clear separation of concerns (logic/lean4/core)
- Improved organization and discoverability
- Standardized file paths across system
- Better distinction between Kripke and task semantics

## Risks and Mitigation

**Risks**:
- Breaking agent context loading
- Broken markdown links
- Loss of information during merges

**Mitigation**:
- Systematic reference updates with verification
- Comprehensive testing after each phase
- Backup before starting
- Clear naming conventions

## Artifacts

- **Plan**: `plans/implementation-001.md` (comprehensive 7-phase plan)
- **Summary**: `summaries/plan-summary.md` (key steps overview)
- **State**: `state.json` (project tracking)

## Next Steps

1. Review and approve implementation plan
2. Execute Phase 1: Preparation and Backup
3. Execute Phases 2-7: File moves, integration, updates, validation
4. Verify all success criteria met
5. Update TODO.md and mark project complete
