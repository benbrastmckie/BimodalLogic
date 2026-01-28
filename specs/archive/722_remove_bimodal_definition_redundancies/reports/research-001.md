# Research Report: Task #722

**Task**: Remove redundant definitions from Bimodal project
**Started**: 2026-01-28T20:19:30Z
**Completed**: 2026-01-28T20:25:00Z
**Effort**: 4-6 hours
**Priority**: Medium
**Dependencies**: None
**Sources/Inputs**: Codebase analysis via Grep, file structure analysis
**Artifacts**: This report
**Standards**: report-format.md

## Executive Summary

- The Bimodal project contains **significant redundancy** across Boneyard subdirectories
- Key definitions like `SetMaximalConsistent`, `SetConsistent`, `Consistent`, `set_lindenbaum`, `CanonicalWorldState`, and `closure` are defined **3-4 times** in different locations
- The active code (`Metalogic/`) already re-exports from `Boneyard/Metalogic_v2/Core/` and uses `hiding` clauses to manage conflicts
- Recommended approach: Consolidate to single canonical definitions in `Metalogic_v2/Core/` and update all imports

## Context & Scope

### Task Description
Remove redundant/duplicate definitions throughout the Bimodal/ project to maintain a consistent and maintainable theory. The example given was `SetMaximalConsistent` with two definitions.

### Analysis Scope
- Searched entire `Theories/Bimodal/` directory
- Examined definition locations and import patterns
- Identified usage patterns across active and deprecated code

## Findings

### 1. Identified Redundant Definitions

#### SetMaximalConsistent (4 definitions)
| Location | Namespace | Status |
|----------|-----------|--------|
| `Boneyard/Metalogic_v2/Core/MaximalConsistent.lean:94` | `Bimodal.Metalogic_v2.Core` | **CANONICAL** (exported by Core) |
| `Boneyard/Metalogic/Completeness.lean:136` | `Bimodal.Boneyard.Metalogic` | Duplicate |
| `Boneyard/Metalogic/Representation/CanonicalModel.lean:68` | `Bimodal.Boneyard.Metalogic.Representation` | Duplicate |
| `docs/user-guide/ARCHITECTURE.md:608` | Documentation | Not real code |

#### SetConsistent (4 definitions)
| Location | Namespace | Status |
|----------|-----------|--------|
| `Boneyard/Metalogic_v2/Core/MaximalConsistent.lean:87` | `Bimodal.Metalogic_v2.Core` | **CANONICAL** |
| `Boneyard/Metalogic/Completeness.lean:129` | `Bimodal.Boneyard.Metalogic` | Duplicate |
| `Boneyard/Metalogic/Representation/CanonicalModel.lean:61` | `Bimodal.Boneyard.Metalogic.Representation` | Duplicate |
| `docs/user-guide/ARCHITECTURE.md:605` | Documentation | Not real code |

#### Consistent (6+ definitions)
| Location | Status |
|----------|--------|
| `Boneyard/Metalogic_v2/Core/MaximalConsistent.lean:58` | **CANONICAL** |
| `Boneyard/Metalogic_v2/Core/Basic.lean:41` | Duplicate (different definition style) |
| `Boneyard/Metalogic/Completeness.lean:99` | Duplicate |
| `Boneyard/Metalogic/Representation/CanonicalModel.lean:52` | Duplicate |
| `Boneyard/Metalogic/Core/Basic.lean:18` | Duplicate |
| `Boneyard/Metalogic/Core/Basic.lean:26` | `Consistent'` variant |

#### set_lindenbaum (3 definitions)
| Location | Status |
|----------|--------|
| `Boneyard/Metalogic_v2/Core/MaximalConsistent.lean:290` | **CANONICAL** |
| `Boneyard/Metalogic/Completeness.lean:360` | Duplicate |
| `Boneyard/Metalogic/Representation/CanonicalModel.lean:139` | Duplicate |

#### CanonicalWorldState (3 definitions)
| Location | Status |
|----------|--------|
| `Boneyard/Metalogic_v2/Representation/CanonicalModel.lean:65` | Used by Metalogic_v2 |
| `Boneyard/Metalogic/Completeness.lean:1413` | Used by Metalogic (deprecated) |
| `Boneyard/Metalogic/Representation/CanonicalModel.lean:186` | Duplicate |

#### closure/closureWithNeg (Duplicate sets)
| Location | Purpose |
|----------|---------|
| `Boneyard/Metalogic_v2/Representation/Closure.lean:67,118` | Used by Metalogic_v2 decidability |
| `Boneyard/Metalogic/Completeness/FiniteCanonicalModel.lean:335,481` | Used by Metalogic decidability |
| `Boneyard/Metalogic_v2/Decidability/SignedFormula.lean:228,236` | `closureFinset`, `closureSizeOf` variants |

### 2. Current Architecture

The project has **three parallel metalogic implementations**:

```
Theories/Bimodal/
├── Metalogic/                    # Active: Universal parametric canonical model
│   ├── Core/MaximalConsistent.lean  # RE-EXPORTS from Boneyard/Metalogic_v2/Core
│   └── Representation/              # Uses Core definitions
│
├── Boneyard/Metalogic/           # Deprecated: Original attempt
│   ├── Completeness.lean         # Contains many duplicate definitions
│   ├── Representation/           # More duplicates
│   └── Decidability/             # Uses its own closure definitions
│
└── Boneyard/Metalogic_v2/        # Semi-active: FMP approach
    ├── Core/                     # CANONICAL source for MCS definitions
    ├── Representation/           # Used for FMP proof
    └── Decidability/             # Used for decision procedure
```

### 3. Import Pattern Analysis

**Active Metalogic imports from Boneyard:**
- `IndexedMCSFamily.lean` imports `Boneyard/Metalogic.Completeness` for `set_mcs_closed_under_derivation`
- `CoherentConstruction.lean` imports `Boneyard/Metalogic.Completeness` for `set_mcs_all_future_all_future`
- `TruthLemma.lean` imports from both `Metalogic.Core` and `Boneyard.Metalogic`
- Uses `hiding SetMaximalConsistent SetConsistent Consistent set_lindenbaum` to avoid conflicts

**Key insight**: Active code already knows about the redundancy and uses `hiding` clauses.

### 4. Complexity Assessment

| Category | Count | Effort |
|----------|-------|--------|
| Core MCS definitions (SetConsistent, SetMaximalConsistent, etc.) | ~15 duplicates | High - widely used |
| Lindenbaum/closure lemmas | ~10 duplicates | Medium |
| CanonicalWorldState/Frame structures | ~6 duplicates | Medium |
| Helper lemmas (mcs_*, set_mcs_*) | ~50+ duplicates | High - need careful mapping |

## Decisions

1. **Canonical source**: `Boneyard/Metalogic_v2/Core/MaximalConsistent.lean` for MCS definitions
2. **Export pattern**: `Metalogic/Core/MaximalConsistent.lean` already re-exports correctly
3. **Approach**: Incremental consolidation rather than big-bang refactor

## Recommendations

### Phase 1: Audit Import Dependencies
1. Map all files that import from `Boneyard/Metalogic/Completeness.lean`
2. Identify which definitions are actually used from each import
3. Document the dependency graph

### Phase 2: Consolidate Core MCS Definitions
1. Keep `Boneyard/Metalogic_v2/Core/MaximalConsistent.lean` as canonical source
2. Remove duplicate definitions from:
   - `Boneyard/Metalogic/Completeness.lean` (lines 99-142)
   - `Boneyard/Metalogic/Representation/CanonicalModel.lean` (lines 52-74)
3. Update imports to use `Metalogic.Core` re-exports

### Phase 3: Consolidate MCS Lemmas
1. Move essential lemmas (`set_mcs_closed_under_derivation`, `set_mcs_all_future_all_future`, etc.) to Core
2. Remove duplicates from Completeness.lean
3. Update import paths in active code

### Phase 4: Consolidate Closure Definitions
1. Determine canonical location for `closure`/`closureWithNeg`
2. Likely keep in `Metalogic_v2/Representation/Closure.lean`
3. Update decidability code to use single source

### Phase 5: Clean Up Dead Code
1. Identify files in Boneyard that are completely unused
2. Consider removing or marking more clearly as deprecated

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking active builds | High | Run `lake build` after each change |
| Missing hidden dependencies | Medium | Search for fully qualified names before removal |
| Regression in proofs | Medium | Ensure all theorems still compile |
| Scope creep | Medium | Focus on most-used definitions first |

## Success Criteria

- [ ] `lake build` passes with no new errors
- [ ] Each core MCS definition exists in exactly one location
- [ ] No `hiding` clauses needed for MCS definitions in active code
- [ ] Import statements simplified in active files

## Appendix

### Search Queries Used
- `^def SetMaximalConsistent` - Found 4 definitions
- `^def SetConsistent` - Found 4 definitions
- `^def Consistent` - Found 6+ definitions
- `^theorem set_lindenbaum` - Found 3 definitions
- `^def CanonicalWorldState` - Found 3 definitions
- `import Bimodal.Boneyard` - Traced import dependencies

### Files to Modify (Preliminary List)
1. `Boneyard/Metalogic/Completeness.lean` - Remove duplicate MCS definitions
2. `Boneyard/Metalogic/Representation/CanonicalModel.lean` - Remove duplicate definitions
3. `Metalogic/Core/MaximalConsistent.lean` - Extend re-exports if needed
4. `Metalogic/Representation/IndexedMCSFamily.lean` - Simplify imports
5. `Metalogic/Representation/CoherentConstruction.lean` - Simplify imports
6. `Metalogic/Representation/TruthLemma.lean` - Simplify imports

### Files That May Be Completely Removable
- `Boneyard/Metalogic/Representation/CanonicalModel.lean` - if no unique content
- Portions of `Boneyard/Metalogic/Completeness.lean` - deprecated Duration construction

## Next Steps

Proceed to `/plan 722` to create a phased implementation plan addressing the redundancies in order of priority and risk.
