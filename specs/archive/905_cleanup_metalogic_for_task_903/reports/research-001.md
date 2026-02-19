# Research Report: Task #905

**Task**: Clean up the metalogic by moving anything not needed into Boneyard/ before implementing task 903's completeness proof restructuring
**Date**: 2026-02-19
**Focus**: Identify which metalogic files are needed vs. not needed for task 903

## Summary

Task 903's plan creates a new `Representation.lean` file that builds a canonical TaskFrame, TaskModel, and WorldHistory from a constant-family BMCS, then proves a truth lemma and derives standard completeness theorems. The implementation depends on a well-defined subset of the Bundle/ infrastructure (BMCS definitions, modal saturation, coherent construction, temporal coherent construction, truth lemma, completeness) plus all of Core/, Soundness, and the Semantics definitions. Seven orphan files in Bundle/ totaling 6,191 lines are confirmed safe to move to Boneyard. An additional file (SaturatedConstruction.lean, 1,414 lines) is also a Boneyard candidate since its only consumer is FinalConstruction.lean (itself a Boneyard candidate). The RecursiveSeed chain (12,564 lines) should be deferred pending task 864.

## Findings

### 1. Files NEEDED for Task 903 (KEEP)

These files are directly required by the task 903 implementation plan or are dependencies of required files.

#### A. Core Infrastructure (required by everything)

| File | Lines | Sorries | Role |
|------|-------|---------|------|
| Core/MaximalConsistent.lean | 56 | 0 | Lindenbaum's lemma, MCS definition |
| Core/MCSProperties.lean | 362 | 0 | MCS closure under derivation |
| Core/DeductionTheorem.lean | 457 | 0 | Hilbert-style deduction theorem |
| Core/RestrictedMCS.lean | 443 | 0 | Restricted MCS (used by SaturatedConstruction) |
| Core/Core.lean | 24 | 0 | Aggregator module |

**Total Core**: 1,342 lines, 0 sorries. All sorry-free and foundational.

#### B. BMCS Critical Path (the completeness chain)

| File | Lines | Sorries | Axioms | Role |
|------|-------|---------|--------|------|
| IndexedMCSFamily.lean | 213 | 0 | 0 | Temporal MCS families |
| TemporalContent.lean | 28 | 0 | 0 | Temporal content definitions |
| BMCS.lean | 263 | 0 | 0 | Bundle structure, modal_forward/backward |
| BMCSTruth.lean | 478 | 0 | 0 | bmcs_truth_at definition |
| ModalSaturation.lean | 604 | 1 | 0 | Modal saturation predicates |
| TruthLemma.lean | 651 | 9 | 0 | BMCS truth lemma (forward sorry-free) |
| Construction.lean | 429 | 0 | 1 (FALSE) | BMCS from consistent context |
| CoherentConstruction.lean | 1,625 | 6 | 1 | Coherent witness chain construction |
| TemporalCoherentConstruction.lean | 938 | 12 | 1 | temporal_backward_G/H, fully_saturated_bmcs_exists_int |
| DovetailingChain.lean | 666 | 9 | 0 | Dovetailing chain construction |
| Completeness.lean | 476 | 2 | 0 | bmcs_representation, bmcs_weak/strong_completeness |

**Total BMCS Critical Path**: 6,371 lines.

**Why each file is needed**:
- **BMCS.lean**: Defines the BMCS structure with modal_forward/backward -- task 903 builds on these
- **BMCSTruth.lean**: Defines bmcs_truth_at -- task 903's bridge uses this
- **CoherentConstruction.lean**: Imported by TruthLemma.lean and TemporalCoherentConstruction.lean (3 active importers). Provides BoxContent, WitnessSeed, CoherentBundle, and the coherent witness chain. CANNOT be moved.
- **TemporalCoherentConstruction.lean**: Provides temporal_backward_G and temporal_backward_H (reused in Phase 4 of task 903) and fully_saturated_bmcs_exists_int (the main construction axiom)
- **Construction.lean**: Contains singleFamily_modal_backward_axiom (FALSE, to be REMOVED in Phase 5) and construct_bmcs. The FALSE axiom removal is part of task 903's plan, but the file itself stays.
- **Completeness.lean**: Provides bmcs_representation (the foundation for standard_representation) and CanonicalWorldState definition (line 647)
- **DovetailingChain.lean**: Imported by TemporalCoherentConstruction.lean and SeedCompletion.lean
- **ModalSaturation.lean**: Imported by CoherentConstruction.lean, Construction.lean, SaturatedConstruction.lean, TemporalLindenbaum.lean
- **TruthLemma.lean**: Imports CoherentConstruction.lean; provides BMCS truth lemma forward direction

#### C. Soundness and Completeness Infrastructure

| File | Lines | Sorries | Role |
|------|-------|---------|------|
| Soundness.lean | 709 | 0 | Standard soundness theorem (sorry-free) |
| SoundnessLemmas.lean | 966 | 1 | Bridge theorems for soundness |
| Completeness.lean (top-level) | 649 | 0 | CanonicalWorldState definition, MCS closure |

**Total**: 2,324 lines.

#### D. Decidability (independent, keep for overall project)

| Directory | Lines | Sorries | Role |
|-----------|-------|---------|------|
| Decidability/ (8 files) | 2,161 | 0 | Tableau-based decision procedure |

Not directly needed by task 903 but part of the active metalogic. No cleanup needed.

#### E. FMP (independent, keep for overall project)

| Directory | Lines | Sorries | Role |
|-----------|-------|---------|------|
| FMP/ (4 files) | 2,025 | ~2 | Finite Model Property approach |

Not directly needed by task 903 but part of the active metalogic. No cleanup needed.

#### F. Algebraic (independent, keep for future work)

| Directory | Lines | Sorries | Role |
|-----------|-------|---------|------|
| Algebraic/ (6 files) | 2,154 | 0 | Lindenbaum quotient, Boolean algebra, interior operators |

Self-contained (no external importers), sorry-free. Independent research line. Keep as-is.

### 2. Files NOT NEEDED for Task 903 (BONEYARD CANDIDATES)

#### Tier 1: Orphan Files (confirmed zero importers)

These files have zero external importers -- nothing in the active codebase imports them.

| File | Lines | Sorries | Axioms | Reason for Boneyard |
|------|-------|---------|--------|---------------------|
| PreCoherentBundle.lean | 441 | 6 | 0 | Self-documented as MATHEMATICALLY BLOCKED; superseded by CoherentConstruction.lean |
| TemporalChain.lean | 555 | 14 | 0 | Superseded by DovetailingChain.lean (which explicitly notes "Progress Over TemporalChain.lean") |
| WeakCoherentBundle.lean | 1,134 | 7 | 1 | Never integrated; abandoned approach with WeakBMCS |
| UnifiedChain.lean | 429 | 9 | 0 | All key lemmas have sorry; not used by anything |
| ZornFamily.lean | 1,907 | 11 | 0 | Experimental Zorn-based construction; orphan |
| TemporalLindenbaum.lean | 1,147 | 9 | 0 | Failed at closing temporal saturation gap; orphan |
| FinalConstruction.lean | 578 | 32 | 0 | All key theorems have sorry; orphan (imports SaturatedConstruction which is also orphan) |

**Total Tier 1**: 6,191 lines, 88 sorries, 1 axiom. All confirmed orphans with zero external importers.

#### Tier 2: SaturatedConstruction.lean (newly identified)

| File | Lines | Sorries | Axioms | Reason for Boneyard |
|------|-------|---------|--------|---------------------|
| SaturatedConstruction.lean | 1,414 | 12 | 0 | Only imported by FinalConstruction.lean (itself a Tier 1 Boneyard candidate). Contains closure-based saturation approach that is not on the critical path. References TemporalLindenbaum.lean (Tier 1 candidate) in comments. |

**Note**: SaturatedConstruction.lean is NOT listed in task 903's Phase 5 Boneyard list but should be included since its sole consumer (FinalConstruction.lean) is being moved.

**Total Tier 1 + Tier 2**: 7,605 lines, 100 sorries, 1 axiom.

#### Tier 3: RecursiveSeed Chain (DEFER -- task 864 active)

| File | Lines | Sorries | Axioms |
|------|-------|---------|--------|
| RecursiveSeed/Core.lean | 758 | 0 | 0 |
| RecursiveSeed/Builder.lean | 6,031 | 12 | 0 |
| RecursiveSeed/Worklist.lean | 876 | 1 | 0 |
| RecursiveSeed/Consistency.lean | 718 | 6 | 0 |
| RecursiveSeed/Closure.lean | 3,549 | 4 | 0 |
| RecursiveSeed.lean | 12 | 0 | 0 |
| SeedCompletion.lean | 374 | 5 | 0 |
| SeedBMCS.lean | 246 | 6 | 0 |

**Total RecursiveSeed**: 12,564 lines, 34 sorries, 0 axioms.

**Status**: Entirely disconnected from the critical path (nothing imports SeedBMCS.lean, and SeedCompletion.lean is not imported by critical path files). However, task 864 is actively working on RecursiveSeed, so moving these to Boneyard would disrupt that work. DEFER.

### 3. Import Dependency Analysis

The critical path import graph (simplified) is:

```
Core/MaximalConsistent -> Core/MCSProperties -> Core/DeductionTheorem
     |
     v
IndexedMCSFamily -> BMCS -> BMCSTruth
     |                |
     |                v
     |           ModalSaturation
     |                |
     v                v
TemporalContent  Construction -> CoherentConstruction
     |                               |
     v                               v
DovetailingChain        TemporalCoherentConstruction
     |                               |
     v                               v
     +-------> TruthLemma <----------+
                    |
                    v
               Completeness
                    |
                    v
            [NEW: Representation.lean]
```

The Boneyard candidates (PreCoherentBundle, TemporalChain, WeakCoherentBundle, UnifiedChain, ZornFamily, TemporalLindenbaum, FinalConstruction, SaturatedConstruction) have NO incoming edges from this critical path graph. They are dead-end nodes.

### 4. Impact of Boneyard Moves on Task 903

Moving the Tier 1 + Tier 2 files to Boneyard has the following effects:

**Positive impacts**:
- Removes 7,605 lines of dead code from active Metalogic/Bundle/
- Eliminates 100 sorries and 1 axiom from the active sorry/axiom counts
- Reduces build time (fewer files to compile)
- Clears conceptual clutter before task 903 implementation
- Makes the active critical path easier to understand

**Zero risk impacts**:
- No files in the critical path import any Boneyard candidate
- No definitions from Boneyard candidates are referenced in critical path code
- The import chain from Completeness.lean (the top of the BMCS chain) does not reach any candidate

**Things to watch**:
- `SaturatedConstruction.lean` should be added to the Boneyard list (not in task 903's plan but should be)
- The `Metalogic/Metalogic.lean` aggregator does NOT import any Boneyard candidates (confirmed)
- `CoherentConstruction.lean` must NOT be moved (3 active importers) despite having the `saturated_extension_exists` axiom

### 5. Specific Actions for Task 903's Phase 5 Cleanup

The implementation plan's Phase 5 lists 7 files to move to `Theories/Bimodal/Boneyard/Bundle/`. Based on this research:

**Confirmed safe to move (matches plan)**:
1. PreCoherentBundle.lean (441 lines)
2. TemporalChain.lean (555 lines)
3. WeakCoherentBundle.lean (1,134 lines)
4. UnifiedChain.lean (429 lines)
5. ZornFamily.lean (1,907 lines)
6. TemporalLindenbaum.lean (1,147 lines)
7. FinalConstruction.lean (578 lines)

**Additional candidate (not in plan)**:
8. SaturatedConstruction.lean (1,414 lines) -- sole consumer is FinalConstruction.lean

**NOT safe to move (despite appearing abandoned)**:
- CoherentConstruction.lean -- imported by TruthLemma.lean, TemporalCoherentConstruction.lean, WeakCoherentBundle.lean (3 active importers)
- DovetailingChain.lean -- imported by TemporalCoherentConstruction.lean, SeedCompletion.lean

**Deferred (task 864)**:
- RecursiveSeed/ chain + SeedBMCS.lean + SeedCompletion.lean (12,564 lines)

### 6. FALSE Axiom Removal

Task 903 Phase 5 calls for removing `singleFamily_modal_backward_axiom` from Construction.lean. This is confirmed safe:

- The axiom is at line 219 of Construction.lean
- It is explicitly marked as DEPRECATED in comments (lines 188-210)
- It is only used by `singleFamilyBMCS` at line 255
- `singleFamilyBMCS` is used by `construct_bmcs` and subsequently by the BMCS completeness chain
- However, `construct_saturated_bmcs_int` in TemporalCoherentConstruction.lean provides a CORRECT replacement that does not use this FALSE axiom
- The completeness chain in Completeness.lean uses `construct_saturated_bmcs_int`, NOT `construct_bmcs` directly

**Recommendation**: Remove the axiom but keep the `construct_bmcs` function with a sorry-backed `modal_backward` (replacing the FALSE axiom with a sorry) and a deprecation comment. Or remove `construct_bmcs` entirely if nothing else uses it.

## Recommendations

1. **Move Tier 1 files (7 files, 6,191 lines) to Boneyard** -- all confirmed orphans, zero risk
2. **Also move SaturatedConstruction.lean (1,414 lines)** -- sole consumer is FinalConstruction.lean (being moved)
3. **Do NOT move CoherentConstruction.lean or DovetailingChain.lean** -- active importers on the critical path
4. **Defer RecursiveSeed chain** -- task 864 is active
5. **Remove FALSE axiom singleFamily_modal_backward_axiom** from Construction.lean as planned
6. **Keep all Core/, Soundness, Decidability, FMP, Algebraic files** -- none are candidates for Boneyard
7. **Create Boneyard/Bundle/ directory** if it does not already exist

## References

- Task 903 plan: `/home/benjamin/Projects/ProofChecker/specs/903_restructure_completeness_proof_bimodal_semantics/plans/implementation-001.md`
- Task 903 research-001: `/home/benjamin/Projects/ProofChecker/specs/903_restructure_completeness_proof_bimodal_semantics/reports/research-001.md`
- Task 903 research-002: `/home/benjamin/Projects/ProofChecker/specs/903_restructure_completeness_proof_bimodal_semantics/reports/research-002.md`
- Active Metalogic: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/`
- Existing Boneyard: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Boneyard/`

## Next Steps

Run `/plan 905` to create an implementation plan for the cleanup, covering:
1. File moves to Boneyard/Bundle/
2. FALSE axiom removal
3. Build verification after moves
4. Import chain verification
