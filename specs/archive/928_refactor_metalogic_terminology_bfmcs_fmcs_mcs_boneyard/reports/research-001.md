# Research Report: Task #928

**Task**: 928 - Refactor metalogic terminology (BMCS->BFMCS, FMCS, MCS) and archive to Boneyard
**Date**: 2026-02-25
**Mode**: Team Research (2 teammates)
**Session**: sess_1740528000_r928t

## Summary

A comprehensive review of the metalogic reveals that **task 925 Phase 2 (Boneyard cleanup) was entirely skipped**, leaving constant family constructions and `CoherentConstruction.lean` in active code. The terminology rename from task 925 Phase 1 was also partial - only a type alias was created (`abbrev FMCS := BFMCS`) rather than a true rename. The sorry-free completeness chain in `ChainBundleBMCS.lean` is publication-ready, but documentation is stale and the legacy chain contains 5 sorries and 2 custom axioms. Critically, the task 928 proposal to "rename BMCS to BFMCS" would create confusion; a cleaner approach is to complete the FMCS rename from task 925.

## Key Findings

### 1. Task 925 Phases Were Incomplete

| Phase | Planned | Actual Status |
|-------|---------|---------------|
| Phase 1: Terminology | Rename BFMCS structure to FMCS, update all files | **PARTIAL**: Only created `abbrev FMCS := BFMCS` alias |
| Phase 2: Boneyard | Move CoherentConstruction.lean, constant families to Boneyard | **NOT STARTED**: All files remain in active code |

The implementation summary from task 925 acknowledged: "Phase 2 (Boneyard cleanup): File reorganization, not blocking completeness."

### 2. Terminology State is Confusing

**Current usage counts** (active Metalogic only):
- `BFMCS`: 264 occurrences across 20 files
- `FMCS`: 34 occurrences across 5 files
- `BMCS`: 360 occurrences across 20 files
- `MCS`: 677 occurrences (consistent)

**The problem with task 928's proposal**:
- Task description says "Rename BMCS to BFMCS throughout to clarify it is a Bundle of FMCSs"
- But `BFMCS` is already the name of the single-family structure (264 occurrences)
- This would create a naming collision where "BFMCS" means both "single family" and "bundle of families"

**Recommended approach**: Complete the task 925 rename properly:
- **MCS** = Maximal Consistent Set (single set) - already consistent
- **FMCS** = Family of MCS (single time-indexed family) - rename `BFMCS` structure to `FMCS`
- **BMCS** = Bundle of MCS families - already correct, no change needed

### 3. Sorry/Axiom Analysis

**Active sorries (5 total)**:
| File | Location | Sorry | Category |
|------|----------|-------|----------|
| `Construction.lean` | line 197 | `singleFamilyBMCS.modal_backward` | Legacy chain |
| `TemporalCoherentConstruction.lean` | line 613 | `temporal_coherent_family_exists` | Legacy chain |
| `TemporalCoherentConstruction.lean` | line 819 | `fully_saturated_bmcs_exists_int` | Legacy chain |
| `DovetailingChain.lean` | line 1869 | `buildDovetailingChainFamily_forward_F` | Fundamental obstacle |
| `DovetailingChain.lean` | line 1881 | `buildDovetailingChainFamily_backward_P` | Fundamental obstacle |

**Active axioms (2 custom)**:
| File | Location | Axiom | Category |
|------|----------|-------|----------|
| `TemporalCoherentConstruction.lean` | line 755 | `fully_saturated_bmcs_exists` | Legacy chain |
| `CoherentConstruction.lean` | line 871 | `saturated_extension_exists` | Legacy chain |

**Publication readiness**:
- **Sorry-free chain** (`ChainBundleBMCS.lean`): Publication-ready. Uses only standard Lean axioms (propext, Classical.choice, Quot.sound).
- **Standard semantics chain** (`Representation.lean`): Has technical debt. Depends on sorry-backed `fully_saturated_bmcs_exists_int`.

### 4. Boneyard Candidates

**Priority 1 - CoherentConstruction.lean** (CRITICAL - was planned for Phase 2):
- Contains dead constant-family code, 63 BFMCS references
- Contains 1 custom axiom (`saturated_extension_exists`)
- Currently imported by TemporalCoherentConstruction.lean and TruthLemma.lean
- Entire file should be moved to `Boneyard/Bundle/`

**Priority 2 - Constant family definitions**:
- `constantBFMCS` in Construction.lean (lines 91-114)
- `constantWitnessFamily`, `constructWitnessFamily` in ModalSaturation.lean (lines 248-288)
- `IsConstantFamily` predicate in CoherentConstruction.lean

**Priority 3 - Legacy sorry-backed constructions**:
- `singleFamilyBMCS` in Construction.lean (lines 178-199, has sorry)
- `construct_temporal_bmcs` in TemporalCoherentConstruction.lean (depends on constant families)

### 5. Documentation Issues

**Stale README files**:
- `Bundle/README.md` and `Metalogic/README.md` still reference `IndexedMCSFamily.lean` (renamed to BFMCS.lean in task 914)
- Architecture diagrams show outdated file structure
- Sorry counts are incorrect

**Metalogic.lean table is wrong**:
- Claims 7 sorries (actual: 5)
- Claims 4 sorries in DovetailingChain (actual: 2)
- Missing module entries for: FMCS.lean, ChainFMCS.lean, ChainBundleBMCS.lean, CanonicalEmbedding.lean, CanonicalQuotient.lean, CanonicalReachable.lean, WitnessGraph.lean, CanonicalFrame.lean, CanonicalBFMCS.lean, TemporalContent.lean

### 6. Code Quality Issues

- `CanonicalBFMCS.lean` was never renamed to `CanonicalFMCS.lean` (planned in Phase 1)
- `CanonicalWorldState` defined in both Completeness.lean and Representation.lean (duplicate)
- Import chain pollution: even sorry-free chain transitively imports CoherentConstruction.lean

## Synthesis

### Conflicts Resolved
No significant conflicts between teammate findings. Both agreed on core issues.

### Recommended Implementation Approach

**Phase 1: Terminology Rename (BFMCS → FMCS)**
1. Rename `structure BFMCS` to `structure FMCS` in BFMCS.lean
2. Update all 264 BFMCS occurrences to FMCS
3. Rename `CanonicalBFMCS.lean` to `CanonicalFMCS.lean`
4. Remove or repurpose `FMCS.lean` (currently just an alias)
5. Keep `BMCS` as-is (it correctly means "bundle")

**Phase 2: Boneyard Cleanup (complete task 925 Phase 2)**
1. Create `Theories/Bimodal/Boneyard/Bundle/` directory
2. Move `CoherentConstruction.lean` to Boneyard
3. Extract and move constant family definitions
4. Audit and fix imports in TemporalCoherentConstruction.lean, TruthLemma.lean
5. Update Boneyard README

**Phase 3: Documentation Update**
1. Update `Metalogic.lean` sorry table and module listing
2. Update `Bundle/README.md` and `Metalogic/README.md`
3. Update architecture diagrams
4. Remove stale IndexedMCSFamily references

**Phase 4: Code Cleanup**
1. Remove `CanonicalWorldState` duplicate
2. Clean up import chain pollution
3. Remove TODO comments that have been addressed

### Do NOT Implement
- Renaming `BMCS` to `BFMCS` (creates confusion with existing BFMCS)
- Phase 6 timeshift closure corrections (found to be inapplicable to any construction)

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| researcher-terminology | Terminology analysis, task 925 review | completed | HIGH |
| researcher-cleanup | Shortcomings, cleanup, publication readiness | completed | HIGH |

## Effort Estimate

| Phase | Effort |
|-------|--------|
| Phase 1: Terminology Rename | 3-4 hours |
| Phase 2: Boneyard Cleanup | 2-3 hours |
| Phase 3: Documentation Update | 1-2 hours |
| Phase 4: Code Cleanup | 1-2 hours |
| **Total** | **7-11 hours** |

## References

- specs/925_redesign_bmcs_completeness_mcs_accessibility/plans/implementation-001.md (Phase 1, 2 incomplete)
- Teammate A findings: research-001-teammate-a-findings.md
- Teammate B findings: research-001-teammate-b-findings.md
